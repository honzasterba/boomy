class BoomController < ApplicationController
  
  layout "content"
  filter_parameter_logging :pass
  
  PER_PAGE = 10
  
  def index
    @title = "Nejlepší za posledních 7 dnů"
    @booms_pages, @booms = paginate :booms, 
        :per_page => PER_PAGE,
        :order => 'popularity DESC',
        :conditions => ['created_at > ?', 1.weeks.ago]        
  end
  
  def novinky
    @title = "Nejnovější"
    @booms_pages, @booms = paginate :booms, 
      :per_page => PER_PAGE,
      :order => 'created_at DESC'
    respond_to do |format|
      format.html
      format.rss { render :layout => false, :action => "rss" }
    end
  end
  
  def best_of
    @title = "Nejlepší"
    @booms_pages, @booms = paginate :booms, 
      :per_page => PER_PAGE,
      :order => 'popularity DESC'
  end
  
  def user
    @user = User.find_by_id(params[:id])
    if !@user
      render :action => "not_found", :status => 404
      return
    end
    @title = "Vše co přidal #{@user.nick}"
    page = (params[:page] || 1).to_i
    @booms = @user.booms[PER_PAGE*(page-1), PER_PAGE]
    @booms_pages = Paginator.new(self, @user.booms.size, PER_PAGE, page)
  end
  
  def tag
    @tag = Tag.find_by_id(params[:id])
    if !@tag
      render :action => "not_found", :status => 404
      return
    end
    if !@tag
      render :action => "not_found", :status => 404
    end
    @title = "Vše s tagem #{@tag.name}"
    page = (params[:page] || 1).to_i
    @booms = @tag.booms[PER_PAGE*(page-1), PER_PAGE]
    @booms_pages = Paginator.new(self, @tag.booms.size, PER_PAGE, page)
  end  
  
  def rate
    return if check_action
    @boom = Boom.find_by_id(params[:id])
    if !@boom
      flash[:notice] = "Odkaz nebyl nalezen."
      redirect_to :action => "index"
      return
    end
    if !@boom.has_user(act_user)
      Point.create(:boom => @boom, :user => act_user)
      @boom.reload
      flash[:notice] = "Bod přidán!"
    else
      flash[:notice] = "Tohle už si hodnotil."
    end
    redirect_to :action => "detail", :id => @boom
  end
  
  def a_rate
    @boom = Boom.find_by_id(params[:id])
    if !@boom
      render :text => ""
      return
    elsif !act_user
      render :partial => "shared/tools_voted", :locals => { :boom => @boom }
      return
    end
    if !@boom.has_user(act_user)
      Point.create(:boom => @boom, :user => act_user)
      @boom.reload
    end
    render :partial => "shared/tools_voted", :locals => { :boom => @boom }
  end
  
  def detail
    begin
      @boom = Boom.find(params[:id])
    rescue
      render :action => "not_found", :status => 404
    end
  end
  
  def add
    return if check_action
    if params[:boom]
      @boom = Boom.new(params[:boom])
      @boom.user = act_user
      if (b = Boom.find_by_link(params[:boom][:link]))
        @boom = b
        Point.create!(:boom => @boom, :user => act_user)
        flash[:notice] = "Přidal jsi bod. Díky!"
        redirect_to :action => "detail", :id => @boom
      elsif @boom.save_with_tags(params[:tags])
        flash[:notice] = "Okdaz přidán. Díky!"
        redirect_to :action => "novinky"
      else
        @tags = params[:tags]
      end
    elsif params[:link]
      @boom = Boom.new(:link => params[:link], :title => params[:title])
      if (b = Boom.find_by_link(params[:link]))
        @boom = b
        point = Point.new(:boom => @boom, :user => act_user)
        if point.save
          flash[:notice] = "Přidal jsi bod. Díky!"
        else
          flash[:notice] = "Tohle už jsi hodnotil."
        end
        redirect_to :action => "detail", :id => @boom
      end
    else
      @boom = Boom.new
    end
  end
  
  def logout
    session[:user] = nil
    cookies.delete [:user_token]
    redirect_to :action => "index"
    flash[:notice] = "Byl jsi odhlášen."
  end
  
  def login
    if params[:user]
      @user = User.new(params[:user])
      @captcha = MathCaptcha.check_and_save(params[:captcha], session, @user)
      if @captcha.nil?
        flash[:notice] = 'Registrace byla úspěšná a byl jsi úspěšně přihlášen.'
        session[:user] = @user.id
        redirect_after_login
      else
        @user.password = @user.password_confirmation = nil
        flash[:notice] = "Registrace se nezdařila. Oprav chyby v zadání."
        render :action => "login"
      end      
    elsif params[:email] || params[:pass]
      user = User.find_by_email_and_password(params[:email], User.sha1(params[:pass]))
      if user
        session[:user] = user.id
        if params[:remember]
          cookies[:user_token] = { :value => user.password, :expires => 12.years.from_now, :path => "/" }
        else
          cookies.delete :user_token
        end
        flash[:notice] = "Byl jsi úspěšně přihlášen."
        redirect_after_login
      else
        flash[:notice] = "Neplatný email nebo heslo."
        redirect_to :action => "login"
      end
      @user = User.new
      @captcha = MathCaptcha.create(session)
    else
      @user = User.new
      @captcha = MathCaptcha.create(session)
    end
  end
  
  def forgot_pass
    user = User.find_by_email(params[:email])
    if !user 
      flash[:notice] = "Uživatel se zadaným emailem nebyl nalezen."
    else
      new_pass = user.reset_password!
      Notifications.deliver_forgot_password(user, new_pass)
      flash[:notice] = "Heslo bylo přenastaveno a odesláno na tvůj email."
    end
    redirect_to :action => "login"
  end
  
  def change_pass
    if !params[:password] or params[:password].strip == ""
    else
      if params[:password] == params[:password_confirmation]
        act_user.password = params[:password]
        if act_user.save
          flash[:notice] = "Heslo úspěšně změněno!"
        else
          flash[:notice] = "Změna hesla se nezdařila."
        end
      else
        flash[:notice] = "Hesla se neshodují. Zkus to znova."
      end
      redirect_to :action => "change_pass"
    end
  end
  
  def not_found
    render :action => "not_found", :status => 404
  end
  
  protected
    def redirect_after_login
      if session[:login_redirect]
        redirect_to session[:login_redirect]
      else
        redirect_to :action => "index"
      end
    end
    
    def check_action
      if ["add", "rate"].rindex(params[:action]) and !act_user
        session[:login_redirect] = request.request_uri
        flash[:notice] = "Nejdřiv se musíš přihlásit."
        redirect_to :action => "login"
        return true
      else
        return false
      end
    end
    
    def clean_redirect
      session[:login_redirect] = nil if params[:action] != "login"
    end
    before_filter :clean_redirect
end
