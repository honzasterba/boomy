class AdminController < ApplicationController
  layout "content"
  
  def destroy
    boom = Boom.find(params[:id])
    boom.destroy
    flash[:notice] = "Admin: Boom smazán."
    redirect_to :controller => "boom"
  end
  
  def form
    @boom = Boom.find(params[:id])
    @tags = @boom.tags_str
    if params[:boom] and params[:tags]
      if @boom.update_with_tags(params[:boom], params[:tags])
        flash[:notice] = "Admin: Boom upraven."
        redirect_to :controller => "boom"
      end
    end
  end
  
  def stats
    @users = User.find_all
    @booms = Boom.find_all.size
    @tags = Tag.find(:all, :order => "popularity DESC")
  end
  
  protected
    def check_user_is_admin
      if !act_user || !act_user.admin?
        redirect_to :controller => "boom"
        return false
      end
      return true
    end
    before_filter :check_user_is_admin
end
