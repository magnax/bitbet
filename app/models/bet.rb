#encoding = utf-8
class Bet < ActiveRecord::Base
  include BitcoinHelper
  include BetsHelper

  default_scope lambda { order('bets.created_at DESC') }

  scope :visible, lambda { where('bets.published_at IS NOT NULL and bets.banned = ?', false) }
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
  belongs_to :user
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
    scope1 = status_names(params[:user]).keys.include?(params[:status]) ? Bet.send(params[:status]) : Bet.visible
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
    close_and_save_with(positive)
    bet_dispatcher = BetDispatcher.new(self)
    bet_dispatcher.run
  end

private

  def Bet.status_names(user)
    statuses = {
      'active' => 'aktywne',
      'waiting'  => 'oczekujące',
      'visible' => 'widoczne',
      'closed' => 'zakończone',
    }
    if !user.nil? && user.admin?
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
      errors.add(:deadline, :past)
    end
    if deadline.present? && event_at.present?
      if deadline > event_at
        errors.add(:deadline, :too_late)
      elsif deadline == event_at
        errors.add(:deadline, :the_same)
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

  def close_and_save_with(positive)
    self.closed_at = DateTime.now
    self.positive = positive
    return self.save(validate: false)
  end
end
