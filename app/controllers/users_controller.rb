class UsersController < ApplicationController
  before_action :logged_in_user, except: %i(show create new)
  before_action :load_user, except: %i(index new create)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy

  def index
    @users = User.paginate page: params[:page]
  end

  def show
    return if @user

    flash[:danger] = t "controllers.users.nonexist"
    redirect_to root_path
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      flash[:success] = t "controllers.users.welcome"
      log_in @user
      redirect_to @user
    else
      render :new
    end
  end

  def edit; end

  def update
    if @user.update user_params
      flash[:success] = t "controllers.users.updated"
      redirect_to @user
    else
      flash[:danger] = t "controllers.users.not_updated"
      render :edit
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t "controllers.users.deleted"
      redirect_to users_path
    else
      flash[:danger] = t "controllers.users.not_deleted"
      render :index
    end
  end

  private
  
  def user_params
    params.require(:user).permit(:name, :email, :password,
                                 :password_confirmation)
  end

  # Confirms a logged-in user.
  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = t "controllers.users.warning"
    redirect_to login_path
  end
end

# Confirms the correct user.
def correct_user
  return if current_user? @user
  
  flash[:danger] = t "controllers.users.not_allowed"
  redirect_to root_path
end

# Confirms an admin user.
def admin_user
  return if current_user.admin?

  flash[:danger] = t "controllers.users.not_allowed"
  redirect_to root_path
end

def load_user
  @user = User.find_by id: params[:id]
  return if @user

  flash[:danger] = t "controllers.users.nonexist"
  redirect_to root_path
end
