class Account < ActiveRecord::Base

  validates :nr, presence: true
  validates_uniqueness_of :nr
  validate :valid_bitcoin_address

  belongs_to :user

  default_scope lambda { order('accounts.created_at DESC') }
  scope :deposit, lambda { where('accounts.account_type = ?', 'deposit') }
  scope :withdraw, lambda { where('accounts.account_type = ?', 'withdraw') }

  def bitcoin_client
    Bitcoin::Client.new
  end

  private

  def valid_bitcoin_address
    begin
      if !bitcoin_client.validateaddress(nr)['isvalid']
        errors.add(:nr, :not_valid)
      end
    rescue Bitcoin::ConnectionError => e
      errors.add(:nr, :client_not_working)
      raise e if account_type == 'deposit'
    end
  end
end
