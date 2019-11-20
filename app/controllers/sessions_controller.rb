class SessionsController < ApplicationController
  before_action :load_user, only: :create

  def new; end

  def create
    if @user&.authenticate params[:session][:password]
      if @user.activated?
        log_in @user
        check_remember params[:session][:remember_me]
        redirect_back_or @user
      else
        flash[:warning] = t ".message"
        redirect_to root_path
      end
    else
      flash.now[:danger] = t ".errors"
      render :new
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_path
  end

  private

  def check_remember _remember
    if params[:session][:remember_me] == Settings.remember_checked
      remember @user
    else
      forget @user
    end
  end

  def load_user
    @user = User.find_by email: params[:session][:email].downcase
    return if @user

    flash[:danger] = t ".errors"
    redirect_to login_path
  end
end
