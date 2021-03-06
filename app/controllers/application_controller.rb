class ApplicationController < ActionController::Base
  
  protect_from_forgery

  include SessionHelper
  
  helper_method :current_user
  helper_method :logged_in?
  helper_method :can_edit?
  helper_method :is_admin?
  helper_method :can_delete?
  helper_method :can_manage_user?
  helper_method :administrator?
  helper_method :friendship_status
  helper_method :user_has_pending_friendships?
  helper_method :user_has_friendship_requests?
  helper_method :pending_friendships
  helper_method :is_already_a_friend?
  
  private
  def current_user
	  @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def logged_in?
  	true if current_user
  end

  def is_admin?
    current_user.admin?
  end

  def can_edit? resource
    true if is_admin? || current_user.id == resource.user_id
  end

  def can_delete? resource
    true if is_admin?
  end

  def can_manage resource 
    true if is_admin? || current_user.id == resource.user_id
  end

  def can_manage_user user
    true if is_admin? || current_user.id == user.id    
  end
  
  def administrator? user
    @administrator = User.find(user.id)
    true if @administrator.admin?    
  end

  # Return an appropriate friendship status message.
  def friendship_status(user,friend)
    friendship = Friendship.find_by_user_id_and_friend_id(current_user,friend)
    return "#{friend.username} is not your friend (yet)" if friendship.nil?
    case friendship.status
    when 'requested'
      "#{friend.username} would like to be your friend."
    when 'pending'
      "You have requested friendship from #{friend.username}."
    when 'accepted'
      "#{friend.username} is your friend."
    end
  end

  def user_has_pending_friendships?(user)
    user = current_user
    @user = User.find(current_user.id)
    true if @user.user_pending_friendships
  end

  def user_has_friendship_requests?(user)
    user = current_user
    @user = User.find(current_user.id)
    true if @user.user_friendship_requests
  end

  def pending_friendships
    current_user.user_pending_friendships
  end

  def is_already_a_friend?(user)
    true if current_user.accepted_friends.include?(user)
  end

  # since this method is used by almost all controllers i have moved it to the 
  # application controller after refactoring the codebase
  def authorize_user
    unless logged_in?
      store_location
      redirect_to log_in_path, :notice => "You must be logged in to do that"
    end
  end

  def track_activity(trackable, action = params[:action])
    current_user.activities.create! action: action, trackable: trackable 
  end

end
