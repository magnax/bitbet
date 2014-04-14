#encoding = utf-8
class BetsController < ApplicationController
  before_action :signed_in_user, only: [:create, :new]
  before_action :admin_user, only: [
    :publish, :ban, :reject, :destroy, :end_bet, :settle]
  before_action :find_bet_by_id, except: [ :index, :new, :create, :bet404 ]

  def index
    @bets = Bet.for_display(params.merge({ :user => current_user }))
    @status_names = Bet.status_names(current_user)
    @order_names = Bet.order_names
    @status = @status_names.keys.include?(params[:status]) ? @status_names[params[:status]] : 'widoczne'
  end

  def new
    @bet = Bet.new
  end

  def create
    @bet = current_user.bets.build(bet_params)
    if @bet.save
      flash[:success] = I18n.t 'flash.success.bet_added'
      redirect_to root_path
    else
      render 'new'
    end
  end

  def show
    redirect_to bet404_path unless bet_visible_for_all
    @bid = Bid.new(:bet => @bet)
  end

  def publish
    @bet.publish!
    flash[:success] = I18n.t 'flash.success.bet_published'
    redirect_to @bet
  end

  def ban
    @bet.ban!
    flash[:success] = I18n.t 'flash.success.bet_banned'
    redirect_to @bet
  end

  def reject
    @bet.reject!
    flash[:success] = I18n.t 'flash.success.bet_rejected'
    redirect_to @bet
  end

  def bet404
  end

  def destroy
    flash[:success] = "Usunięto zdarzenie! (ale tak naprawdę to jeszcze nie ma usuwania ;))"
    redirect_to root_path
  end

  def end_bet
    redirect_to @bet, :flash => {
      :error => I18n.t('flash.error.cannot_settle') } if @bet.closed?
  end

  def settle
    @bet.settle(params[:positive] ? true : false)
    redirect_to @bet, :flash => {
      :success => I18n.t('flash.success.bet_settled') }
  end

  private

  def bet_params
    params.require(:bet).permit(:name, :text, :category_id,
      :deadline, :event_at)
  end

  def find_bet_by_id
    @bet = Bet.find_by_id(params[:id])
    redirect_to bet404_path unless @bet
  end

  def bet_visible_for_all
    @bet.visible? || current_user.admin?
  end
end
