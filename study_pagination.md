###### pagination

- (1) resources and reference: [pagination tool](https://github.com/mislav/will_paginate)
- copy gem to gem file
- run "bundle install" to install
- (2) To change listing page to the page having pagination, in articles_controller, change "@articles=Article.all" to below:  
```
  def index
    @articles = Article.paginate(page: params[:page], per_page: 5)
  end
```
- (3) add pagination to view, in articles/index.html.erb, add
```
<%= will_paginate @articles %>
```
- (4) Stylish page
copy [css stylish code for pagination](http://mislav.github.io/will_paginate/pagination.css) to app/stylesheet/custom.css.scss, and copy html code from [Digg-style, extra content](http://mislav.github.io/will_paginate/) change code to flickr_pagination as below
```index.html.erb
<div class="flickr_pagination">
  <%= will_paginate @articles, :container => false %>
</div>

<%= render 'article' %>

<div class="flickr_pagination mb-4"> <!-- => "mb-4": add some margin in the bottom(bs) >
  <%= will_paginate @articles, :container => false %>
</div>
```

- (5) Same for users listing and show page
```
  def index
    @users = User.paginate(page: params[:page], per_page: 5)
  end

  def show
    @user = User.find(params[:id])
    @articles = @user.articles.paginate(page: params[:page], per_page: 3)
  end
```
View page for show.html.erb
```
<div class="flickr_pagination">
  <%= will_paginate @articles, :container => false %>
</div>

<%= render 'articles/article' %>

<div class="flickr_pagination mb-4">
  <%= will_paginate @articles, :container => false %>
</div>
```
And for users/index.html.erb
```
<div class="flickr_pagination mb-4">
  <%= will_paginate @users, :container => false %>
</div>
```

###### Add login form
- (1) add routes 
```
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
```
- (2) added session controller with new, create and destroy actions
- (3) add sessions folder under app/views and create new.html.erb template to display the login form.

- (4) add create and destroy actions:
```
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      session[:user_id] = user.id //create tamperproof session
      flash[:notice] = "Logged in successfully"
      redirect_to user
    else
      flash.now[:alert] = "There was something wrong with your login detail info."
      render 'new'
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:notice] = "Logged out."
    redirect_to root_path
  end
  ```
  - (5) Add entry point in view layer.
  ```
  <li class="nav-item">
    <%= link_to 'Log in', login_path, class: "nav-link" %>
  </li>
  <li class="nav-item">
    <%= link_to 'Log out', logout_path, class: "nav-link", method: :delete %>
  </li>
  ```
  - (6) Add toggle link to show "login" or "logout"
  in application_helper, add below code: 
  ```
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
    # ||= means if current_user exist, return current_user, if not, find in db
  end

  def logged_in?
    # return a boolean 
    !!current_user
  end
  ```
  In view, add if/else between login and logout button, to optimize and user friendly display, added current user link and sign up link as well. 
  ```
  <% if logged_in? %>
    <li class="nav-item">
      <%= link_to current_user.username, user_path(current_user), class: "nav-link" %>
    </li>
    <li class="nav-item">
      <%= link_to 'Log out', logout_path, class: "nav-link", method: :delete %>
    </li>
  <% else %>
    <li class="nav-item">
      <%= link_to 'Log in', login_path, class: "nav-link" %>
    </li>
    <li class="nav-item">
      <%= link_to 'Sign up', signup_path, class: "nav-link" %>
    </li>
  <% end %>
  ```
  - (7) Since when user is created, session is also created, so add code in users_controller.rb as below:
  ```
  def create
    @user = User.new(user_params)
    if  @user.save
      session[:user_id] = @user.id #added session creation here 
      flash[:notice] = "Welcome to Beta blog, #{@user.username}, You have signed up successfully."
      redirect_to articles_path
    else
      render 'new'
    end
  end
  ```
  - (8) clean up code add before_action same as in articles_controller.rb
  ```
  before_action :set_user, only: [:show, :edit, :update]
  #...
  private
  def set_user
    @user = User.find(params[:id])
  end
  ```
  and delete duplicated code in #show/edit/update



    

