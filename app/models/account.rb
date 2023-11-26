class Account < ActiveRecord::Base
  validates :nr, presence: true
  validates_uniqueness_of :nr
  validate :valid_bitcoin_address

  belongs_to :user

  default_scope -> { order('accounts.created_at DESC') }
  scope :deposit, -> { where('accounts.account_type = ?', 'deposit') }
  scope :withdraw, -> { where('accounts.account_type = ?', 'withdraw') }

  def bitcoin_client
    Bitcoin::Client.new
  end

  private

  def valid_bitcoin_address
    errors.add(:nr, :not_valid) unless bitcoin_client.validateaddress(nr)['isvalid']
  rescue Bitcoin::ConnectionError => e
    errors.add(:nr, :client_not_working)
    raise e if account_type == 'deposit'
  end
end
