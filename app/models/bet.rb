#encoding = utf-8
class Bet < ActiveRecord::Base
include BitcoinHelper
include BetsHelper

	default_scope lambda { order('bets.created_at DESC') }

	scope :visible, lambda { where('bets.published_at IS NOT NULL and bets.banned = ?', 0) }
	scope :open, lambda { visible.where('bets.closed_at IS NULL') }
	scope :active, lambda { open.where('bets.deadline > ? and bets.closed_at IS NULL', Time.now.strftime("%Y-%m-%d")) }
	scope :waiting, lambda { open.where('bets.deadline <= ? and bets.closed_at IS NULL', Time.now.strftime("%Y-%m-%d")) }
	scope :closed, lambda { visible.where('bets.closed_at IS NOT NULL') }
	scope :created, lambda { where('bets.published_at IS NULL and bets.closed_at IS NULL') }
	scope :rejected, lambda { where('bets.published_at IS NULL and bets.closed_at IS NOT NULL') }
	scope :banned, lambda { where('bets.banned = ?', 1) }

	scope :oldest, lambda { order('created_at ASC') }
	scope :newest, lambda { order('created_at DESC') }

	belongs_to :category
	has_many :bids
	has_many :participants, through: :bids, source: :user

	validates :name, presence: true, length: { minimum: 10 }
	validates :text, presence: true
	validates :category_id, presence: true
	validates :deadline, presence: true
	validate :proper_deadline_date
	validates :event_at, presence: true
	validate :proper_event_date

	def Bet.for_display(params)
		scope1 = status_names(true).keys.include?(params[:status]) ? Bet.send(params[:status]) : Bet.visible
		if scope1 && !params[:order].nil?
			scope2 = Bet.send(params[:order])
		end
		merged = scope1 ? scope1.merge(scope2) : nil
		if merged && !params[:category].nil?
			scope3 = Bet.where('category_id = ?', params[:category])
		end
		merged = merged ? merged.merge(scope3) : []
	end

	def publish!
		self.published_at = Time.now
		self.save
	end

	def ban!
		self.banned = true
		self.save
	end

	def reject!
		self.closed_at = Time.now
		self.save
	end

	def sum_positive
		bids.positive.sum('amount')
	end

	def sum_negative
		bids.negative.sum('amount')
	end

	def sum_total
		sum_positive + sum_negative   
	end

	def visible?
		published? && !banned?
	end

	def active?
		visible? && !closed? && self.deadline >= Time.now
	end

	def waiting?
		visible? && !closed? && self.deadline < Time.now
	end

	def banned?
		self.banned
	end

	def closed?
		!self.closed_at.nil?
	end

	def settled?
		visible? && closed?
	end

	def created?
		!published? && !banned? && !closed?
	end

	def published?
		!self.published_at.nil?
	end

	def status
		if created?
			"new"
		elsif active?
			"active"
		elsif waiting?
			"waiting"
		elsif banned?
			"banned"
		elsif settled?
			"settled"			
		else				
			"rejected"	
		end
	end

	def settle(positive)
		self.closed_at = DateTime.now
		self.positive = positive
		if self.save(validate: false)
			#łączna suma wygranych bidów
			winning_sum = positive ? sum_positive : sum_negative
			#łączna suma przegranych bidów
			losing_sum = sum_total - winning_sum
			#ogólna, wstępna prowizja (serwis, twórca)
			interest_total = 0.10 * losing_sum
			#prowizja dla serwisu
			fee_amount = 0.05 * losing_sum
			#suma do rozdziału dla wygrywających
			sum_to_dispose = losing_sum - interest_total
			#tabela dla sum wypłaconych poszczególnym obstawiającym
			bidders = {}
			self.participants.distinct.each do |p|
				bidders[p.id] = 0
			end
			#pętla rozliczająca poszczególne obstawienia (bidy)
			sum_of_wins = 0
			bids.each do |b|
				if b.positive == positive
					#bid wygrywający
					wins = b.amount.to_f / winning_sum * sum_to_dispose
					bidders[b.user_id] += wins.to_i
					sum_of_wins += wins.to_i
				else
					#bid przegrywający
					bidders[b.user_id] -= b.amount
					#bc.move "user_#{b.user_id}", "tmp_loss", stc_to_btc(b.amount)
				end
			end
			#końcowa prowizja (uwzględnia zaokrąglenia)
			end_interest = losing_sum - sum_of_wins
			#przelew prowizji dla twórcy zdarzenia
			creator_commission = 0.05 * losing_sum
			operation = Operation.create( {
				user_id: self.user_id,
				amount: creator_commission.to_i,
				bet_id: self.id,
				operation_type: "commission" 
			})
			#pętla do przelewów dla poszczególnych obstawiających
			bidders.each do |user_id, amount|
				if amount > 0
					#kwotę wygranej przenieść z konta systemowego na konto usera
					#bc.move "tmp_loss", "user_#{b.user_id}", stc_to_btc(amount)
					#typ operacji - wygrana ("prize")
					operation_type = "prize"
				else
					#typ operacji - strata ("loss")
					operation_type = "loss"
				end
				#zarejestrować operację w systemie
				operation = Operation.create({
					user_id: user_id,
					amount: amount.to_i.abs,
					bet_id: self.id,
					operation_type: operation_type 
				})
			end
			#prowizja dla serwisu
			Fee.create({ bet_id: id, amount: fee_amount.to_i })
			#bc.move "tmp_loss", "fees", stc_to_btc(fee_amount)
		end			
	end

private

	def Bet.status_names(admin)
		statuses = { 
			'active' => 'aktywne', 
			'waiting'  => 'oczekujące',
			'visible' => 'widoczne',
			'closed' => 'zakończone',
		} 
		if admin == true
			return statuses.merge({
				'created' => 'nowe',
				'rejected' => 'odrzucone', 
				'banned' => 'usunięte' 
			})
		end
		statuses
	end

	def Bet.order_names
		{ 'oldest' => 'najstarsze', 'newest' => 'najnowsze' }
	end

	def proper_deadline_date
	    if deadline.present? && deadline <= Date.today
	      errors.add(:deadline, "can't be in the past")
	    end
	    if deadline.present? && event_at.present?
	    	if deadline > event_at
	      		errors.add(:deadline, "can't be after event date")
	      	elsif deadline == event_at
	      		errors.add(:deadline, "can't be the same as event date")
	     	end	      			
	    end
	end

	def proper_event_date
	    if event_at.present? && event_at <= 3.days.ago.to_date
	      errors.add(:event_at, "can't be in the past or less than 3 days from now")
	    end
	    if event_at.present? && event_at > 1.years.from_now.to_date
	      errors.add(:event_at, "can't be more than a year from today")
	    end
	end

end
