#encoding = utf-8
class BidsController < ApplicationController

  def new
  end

  def create
  	@bet = Bet.find(params[:bet_id])
  	@bid = @bet.bids.build(bid_params)
  	if @bid.save
  		flash[:success] = "Pomyślnie obstawiłeś zdarzenie!" 
  		redirect_to bet_path(@bet)
  	else
  		@bid.amount = bid_params[:amount]
  		render :template => 'bets/show'
  	end
  end

  private

  	def bid_params
  		params.require(:bid).permit(:user_id, :bet_id, :amount, :positive) 
  	end



end
