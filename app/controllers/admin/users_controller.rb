class Admin::UsersController < Admin::BaseController
  def create
    user = User.find_by(email: params.require(:email).to_s.strip.downcase)

    if user.nil?
      redirect_to admin_dashboard_path, alert: "No user found for that email address."
      return
    end

    user.update!(role: "admin")
    redirect_to admin_dashboard_path, notice: "#{user.display_name} is now an admin."
  end

  def destroy
    user = User.find(params[:id])

    if User.admins.count == 1 && user.admin?
      redirect_to admin_dashboard_path, alert: "You cannot remove the last active admin."
      return
    end

    user.update!(role: "user")
    redirect_to admin_dashboard_path, notice: "#{user.display_name} was removed from admins."
  end
end
