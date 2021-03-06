class PaymentInfosController < ApplicationController
  before_filter :client_or_programmer_required
  load_and_authorize_resource

  def edit
    @payment_info = PaymentInfo.find_or_create_by(user_id: current_user.id)
    @cards = @payment_info.get_cards
  end

  def update
    payment_info = PaymentInfo.find_or_create_by(user_id: current_user.id)
    if params[:error]
      if params[:error].kind_of?(Hash)
        # TODO: If the key refers to one of the fields, the error should be displayed inline.
        flash[:errors] = params[:error].map{ |key, value| "#{key}: #{value}" }
      else
        # Once the Balanced API started returning an array for some reason
        generic_error
      end
    elsif params[:data] && params[:data][:security_code_check] == 'failed'
      flash[:alert] = 'Your security code is invalid, please try again.'
    elsif params[:data] && params[:data][:uri]
      payment_info.associate_card(params[:data][:uri])
      flash[:notice] = 'Your payment details have been successfully saved.'
    else
      generic_error
    end
    render json: {redirect_to: edit_user_payment_info_path(params[:user_id].to_i)}
  end

  private

  def generic_error
    flash[:alert] = 'There was something wrong with processing the payment details.'
  end
end
