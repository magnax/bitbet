class OperationsController < ApplicationController
  before_action :signed_in_user

  def create
    begin
      @operation = current_user.operations.withdraws.build(operations_params)
      if @operation.valid?
        txid = bitcoin_client.sendfrom(
          "user_#{current_user.id}",
          current_user.withdrawal_address,
          @operation.amount_in_stc
        )
        @operation.operation_type = 'send'
        @operation.txid = txid
        @operation.time = @operation.timereceived = DateTime.now
        if @operation.save
          redirect_to user_path(current_user), flash: {
            success: I18n.t('flash.success.withdrawal_amount', amount: @operation.amount_in_stc.to_s.gsub('.', ','))
          } and return
        end
      end
    rescue Bitcoin::ConnectionError
      flash.now[:error] = I18n.t('flash.error.withdraw')
    end
    render 'withdraw'
  end

  def withdraw
    @operation = current_user.operations.withdraws.new
  end

  private

  def operations_params
    params.require(:operation).permit(:user_id, :amount_in_stc)
  end
end
