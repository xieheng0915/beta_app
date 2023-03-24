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


###### create article by current user
- (1) To let the author be the current user, change code in articles_controller
from  
```
@article.user = User.first # this is a temporary solution
```
to 
```
@article.user = current_user
```
- (2) But this couldn't work since helper method can't be accessed by controllers directly, so move current_user def from helper to application_controller instead.
```
class ApplicationController < ActionController::Base
  
  helper_method :current_user
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
end
```
- (3) To make sure view page could continuously use current_user, add "helper_method :current_user" on top of action in applicaiton controller.

- (4) Same, when user logged in, even he click the logo home icon, he should be redirected to articles listing page instead, only after he logged out, be redirected to the home page with "sign up" button.  
Therefore, add below code to pages_controller.rb:  
```
def home
  redirect_to articles_path if logged_in?
end
```
- (5) To ensure logged_in could be accessed by all controllers, same as current_user moved from helper to application controller.  
```
class ApplicationController < ActionController::Base

  helper_method :current_user, :logged_in?
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def logged_in?
    !!current_user
  end
end
```

###### Restrict actions from UI
- (1) articles should be edited and deleted only logged in user and the article author himself, so add the judgement here in _article.html.erb  
```
<% if logged_in? && article.user == current_user %>
  <%= link_to 'Edit', edit_article_path(article), class: "btn btn-outline-info" %>
  <%= link_to 'Delete', article, method: :delete, data: { confirm: 'Are you sure?'}, class: "btn btn-outline-danger" %>
<% end %>
```
- (2) Same in show.html.erb
```
<% if logged_in? && @article.user == current_user %> 
  <%= link_to 'Edit', edit_article_path(@article), class: "btn btn-outline-info" %>
  <%= link_to 'Delete', @article, method: :delete, data: { confirm: 'Are you sure?'}, class: "btn btn-outline-danger" %>
<% end %>
``` 
- (3) Same for users page (bloggers list)
```
<% if logged_in? && user == current_user %>
  <%= link_to 'Edit profile', edit_user_path(user), class: "btn btn-outline-info" %>
<% end %>
```    
- (4) And same, do not display "edit your profile" button in other bloggers profile page, in app/view/users/show.html.erb  
```
<% if logged_in? && @user == current_user %>
  <div class="text-center mt-4">
    <%= link_to "Edit your profile", edit_user_path(@user), class: "btn btn-outline-info" %>
  </div>
<% end %>
```

###### navigation restriction
- (1) change username to drop down list and add view/edit profile links
```
<% if logged_in? %>
  <li class="nav-item dropdown">
    <a class="nav-link dropdown-toggle" href="#" role="button" data-toggle="dropdown" aria-expanded="false">
      Profile [<%= current_user.username %>]
    </a>
    <div class="dropdown-menu">
      <%= link_to 'View profile', user_path(current_user), class: "dropdown-item" %>
      <%= link_to 'Edit profile', edit_user_path(current_user), class: "dropdown-item" %>
    </div>       
  </li>
```

###### restrict access from url 
- (1) to restrict unloggedin user access for articles
```application_controller.rb
  def require_user
    if !logged_in?
      flash[:alert] = "You must be logged in to perform this action."
      redirect_to login_path
    end
  end
```
in artciles controller, add below code:   
```articles_controller.rb
before_action :require_user, except: [:show, :index]
```

- (2) to ensure articles could only be editted or destroyed by the author, a logged in user couldn't edit/destroy other author's article by direct url access.   
in articles controller, add: 
```
  def require_same_user
    if current_user != @article.user
      flash[:notice] = "You can only edit or delete your own article"
      redirect_to @article
    end
  end
  ```
  and  
  ```
  before_action :set_user, only: [:show, :edit, :update]
  #check here for require_user, use only not except, because new/create is used for new user signup, should be available without logged in.
  before_action :require_user, only: [:edit, :update]  
  before_action :require_same_user, only: [:edit, :update]
  ```
  "require_same_user" has be to put after require_user to make sure this action is taken after check logged in status.  

- (3) Same to users 
```
  before_action :set_user, only: [:show, :edit, :update]
  before_action :require_user, except: [:show, :index]
  before_action :require_same_user, only: [:edit, :update]
```
and  
```
  def require_same_user
    if current_user != @user
      flash[:notice] = "You can only edit or delete your own profile"
      redirect_to @user
    end
  end
```

###### destroy user 
- (1) Add an entry link in navigation, use "text-danger" to highlight this link
```navigation.html.erb
<%= link_to 'Delete profile', user_path(current_user), class: "dropdown-item text-danger", method: :delete, data: { confirm: "Are you sure"} %>
```
- (2) Add destroy action in controller, routes have already generated, so omitted here. 
```
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :require_user, only: [:edit, :update]
  before_action :require_same_user, only: [:edit, :update, :destroy]
```
and  
```
  def destroy
    @user.destroy
    session[:user_id] = nil
    flash[:notice] = "Account and all associated articles are deleted successfully."
    redirect_to root_path
  end
```
- (3) To make sure articles could be deleted accordingly when user is deleted, need to add below code in model: user.rb, to show the dependent relationship of users and articles     
```
  has_many :articles, dependent: :destroy
```  








