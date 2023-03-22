class UsersController < ApplicationController
  def show
  end

  def new
    @user = User.new
  end

  def edit
    @user = User.find(params[:id])
  end

  def create
    #byebug
    @user = User.new(user_params)
    if  @user.save
      flash[:notice] = "Welcome to Beta blog, #{@user.username}, You have signed up successfully."
      redirect_to articles_path  
    else
      render 'new'
    end
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:notice] = "User has been updated successfully."
      redirect_to articles_path
    else
      render 'edit'
    end
  end

  private
  def user_params
    params.require(:user).permit(:username, :email, :password)
  end


end