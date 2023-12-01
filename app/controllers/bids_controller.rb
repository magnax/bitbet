# encoding = utf-8
class BidsController < ApplicationController
  def new; end

  def create
    @bet = Bet.find(params[:bet_id])
    @bid = @bet.bids.build(bid_params)
    bid_amount_in_stc = bid_params[:amount_in_stc]
    if @bid.save
      flash[:success] = "Pomyślnie obstawiłeś zdarzenie!"
      redirect_to bet_path(@bet)
    else
      @bid.amount_in_stc = bid_amount_in_stc
      render template: 'bets/show'
    end
  end

  private

  def bid_params
    params.require(:bid).permit(:user_id, :bet_id, :amount_in_stc, :positive)
  end
end
