class User < ActiveRecord::Base
  include BitcoinHelper

  before_save { self.email = email.downcase }
  before_create :create_remember_token

  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

  has_secure_password
  validates :password, length: { minimum: 6 }

  # bets created by user
  has_many :bets
  has_many :bids
  # bets in which user participating
  has_many :bidded_bets, through: :bids, source: :bet
  has_many :accounts
  has_many :operations

  def self.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def self.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def available_funds
    operations.incomings.sum(:amount) - operations.outgoings.sum(:amount) - frozen_funds
  end

  def frozen_funds
    bidded_bets.open.sum('bids.amount')
  end

  def deposit_address
    accounts.deposit.any? ? accounts.deposit.first.nr : nil
  end

  def withdrawal_address
    accounts.withdraw.any? ? accounts.withdraw.first.nr : nil
  end

  def build_account(params)
    accounts.build(params)
  end

  def referrals
    []
  end

  def created_bets
    bets.created
  end

  def active_bets
    bets.active
  end

  def waiting_bets
    bets.waiting
  end

  def closed_bets
    bets.closed
  end

  def rejected_bets
    bets.rejected
  end

  def active_bids
    bidded_bets.open.group(:bet_id, 'bets.created_at')
  end

  def closed_bids
    bidded_bets.closed.group(:bet_id, 'bets.created_at')
  end

  def deposits
    operations.incomings
  end

  def withdrawals
    operations.outgoings
  end

  def get_last_deposit_id
    deposits.pluck(:txid)
  end

  def create_new_deposit(transaction)
    operations.build(
      :amount => (BigDecimal(transaction['amount'].to_s) * 100_000_000.0).to_i,
      :account_id => nil,
      :bet_id => nil,
      :operation_type => 'receive',
      :txid => transaction['txid'],
      :time => transaction['time'],
      :timereceived => transaction['timereceived']
    )
  end

  private

  def create_remember_token
    self.remember_token = User.encrypt(User.new_remember_token)
  end
end
