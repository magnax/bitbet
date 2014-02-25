#encoding = utf-8
class BetsController < ApplicationController
  before_action :signed_in_user, only: [:create, :new]
  before_action :admin_user, only: [:publish, :end_bet, :settle]
  before_action :bitcoin_client, only: [ :end_bet, :settle ]

  def index
  	@bets = Bet.for_display(params)
  	@status_names = Bet.status_names(current_user.admin?)
  	@order_names = Bet.order_names
  	@status = @status_names.keys.include?(params[:status]) ? @status_names[params[:status]] : 'widoczne'
  end

  def new
  	@bet = Bet.new
  end

  def create
  	@bet = current_user.bets.build(bet_params)
  	if @bet.save
      flash[:success] = "Pomyślnie dodano nowe zdarzenie. Będzie widoczne po akceptacji."
  		redirect_to root_path
  	else
  		render 'new'
  	end
  end

  def show
    @bet = Bet.find(params[:id])
    if @bet.visible? || current_user.admin?
      @bid = Bid.new(:bet => @bet)
    else
      redirect_to bet404_path
    end
  end

  def publish
    bet = Bet.find(params[:id])
    bet.publish!
    flash[:success] = "Pomyślnie opublikowałeś zdarzenie!"
    redirect_to bet
  end

  def ban
    bet = Bet.find(params[:id])
    bet.ban!
    flash[:success] = "Zdarzenie zbanowane!"
    redirect_to bet
  end

  def reject
    bet = Bet.find(params[:id])
    bet.reject!
    flash[:success] = "Zdarzenie odrzucone!"
    redirect_to bet
  end

  def bet404
  end

  def destroy
    flash[:success] = "Usunięto zdarzenie! (ale tak naprawdę to jeszcze nie ma usuwania ;))"
    redirect_to root_path
  end

  def end_bet
    @bet = Bet.find(params[:id])
    if !@bet.visible?
      redirect_to @bet, :flash => {:error => "Tego zdarzenia się nie rozlicza"}
    end
  end

  def settle
    @bet = Bet.find(params[:id])
    @bet.settle(params[:positive] ? true : false)
    flash[:success] = "Zdarzenie zostało zakończone"
    redirect_to @bet
  end

  private

	def bet_params
		params.require(:bet).permit(:name, :text, :category_id, :deadline, :event_at) 
	end

end
