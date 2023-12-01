# encoding = utf-8
class Operation < ActiveRecord::Base
  include BitcoinHelper
  include CheckUser

  validates :amount_in_stc, presence: true, exclusion: { in: [0] }
  validate :available_funds

  belongs_to :user
  belongs_to :bet
  belongs_to :account

  default_scope -> { order('operations.created_at DESC') }
  scope :deposits, -> { where('operations.operation_type = ?', 'receive') }
  scope :winnings, -> { where('operations.operation_type = ?', 'prize') }
  scope :incomings, -> { where('operations.operation_type in (?)', %w[receive prize]) }
  scope :withdraws, -> { where('operations.operation_type = ?', 'send') }
  scope :losings, -> { where('operations.operation_type = ?', 'loss') }
  scope :outgoings, -> { where('operations.operation_type in (?)', %w[send loss]) }
  scope :commissions, -> { where('operations.operation_type = ?', 'commission') }

  def self.check_deposits
    puts '666 new deposits'
  end

  def self.types
    {
      'receive' => 'Wpłata',
      'send' => 'Wypłata z konta',
      'prize' => 'Wygrana',
      'loss' => 'Przegrana',
      'commission' => 'Prowizja'
    }
  end
end
