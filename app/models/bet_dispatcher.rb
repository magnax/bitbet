class BetDispatcher
  include BitcoinHelper
  include BetsHelper

  CREATOR_COMMISSION = 0.05
  SERVICE_FEE        = 0.05

  def initialize(bet)
    @bet = bet
    @winning_sum = bet.positive ? bet.sum_positive : bet.sum_negative
    @losing_sum = bet.sum_total - @winning_sum
    @bidders = get_bidders
  end

  def get_bidders
    bidders = {}
    @bet.participants.distinct.each do |p|
      bidders[p.id] = 0
    end
    bidders
  end

  def dispatch_bids
    sum_of_wins = 0
    @bet.bids.each do |b|
      if b.positive == @bet.positive
        # winning bid
        wins = (b.amount.to_f / @winning_sum * sum_to_dispose).to_i
        @bidders[b.user_id] += wins
        sum_of_wins += wins
      else
        # loosing bid
        @bidders[b.user_id] -= b.amount
        bc.move "user_#{b.user_id}", 'tmp_loss', stc_to_btc(b.amount)
      end
    end
    sum_of_wins
  end

  def set_creator_commission
    Operation.create({
                       user_id: @bet.user_id,
                       amount: creator_commission.to_i,
                       bet_id: @bet.id,
                       operation_type: 'commission'
                     })
  end

  def set_fee(amount)
    Fee.create({ bet_id: @bet.id, amount: amount.to_i })
    bc.move 'tmp_loss', 'fees', stc_to_btc(amount)
  end

  def dispatch_bidders
    # pętla do przelewów dla poszczególnych obstawiających
    @bidders.each do |user_id, amount|
      bc.move 'tmp_loss', "user_#{user_id}", stc_to_btc(amount) if amount.positive?
      # zarejestrować operację w systemie
      Operation.create({
                         user_id: user_id,
                         amount: amount.to_i.abs,
                         bet_id: @bet.id,
                         operation_type: amount.positive? ? 'prize' : 'loss'
                       })
    end
  end

  def creator_commission
    CREATOR_COMMISSION * @losing_sum
  end

  def fee_amount(sum_of_wins)
    @losing_sum - sum_of_wins
  end

  def sum_to_dispose
    @losing_sum - ((SERVICE_FEE + CREATOR_COMMISSION) * @losing_sum)
  end

  def run
    return unless @winning_sum && @losing_sum

    sum_of_wins = dispatch_bids
    set_creator_commission
    dispatch_bidders
    set_fee(fee_amount(sum_of_wins))
  end

  private

  def bc
    Bitcoin::Client.new
  end
end
