class BetsController < ApplicationController

  def index
  	@bets = Bet.for_display(params)
  	@status_names = Bet.status_names
  	@order_names = Bet.order_names
  	@categories = Category.all
  	@status = @status_names.keys.include?(params[:status]) ? @status_names[params[:status]] : 'widoczne'
  end

  def new
  	@bet = Bet.new
  end

  def create
  	@bet = Bet.new(bet_params)
  	if @bet.save
  		redirect_to root_path
  	else
  		render 'new'
  	end
  end

  def show
    @bet = Bet.find(params[:id])
    @bid = Bid.new(:bet => @bet)
  end

  private

  	def bet_params
  		params.require(:bet).permit(:name, :text, :category_id, :deadline, :event_at) 
  	end

end
