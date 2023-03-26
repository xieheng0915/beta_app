##### add admin authorization 
Add admin role,only admin can add/update/del users and articles, general users can only edit their own articles.   
- run "rails generate migration add_admin_to_users" 
- open migration file, add: 
```
class AddAdminToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :admin, :boolean, default: false
  end
end
```
- run "rails db:migrate"
- run "rails c" and check the column has been added with default value
```
>user = User.first
>user.admin?  // check the admin value
>user.toggle!(:admin) // update boolean value
```
- add Admin mark in view:  
```_navigation.html.erb
<a class="nav-link dropdown-toggle" href="#" role="button" data-toggle="dropdown" aria-expanded="false">
  <%= "Admin" if current_user.admin? %> Profile [<%= current_user.username %>]
</a>
```
- let admin have the authority to edit articles:  
```_article.html.erb
<% if logged_in? && (article.user == current_user || current_user.admin?)  %>
  <%= link_to 'Edit', edit_article_path(article), class: "btn btn-outline-info" %>
  <%= link_to 'Delete', article, method: :delete, data: { confirm: 'Are you sure?'}, class: "btn btn-outline-danger" %>
<% end %>
```  
- add admin permit in controller layer
```articles_controller.rb
def require_same_user
  if current_user != @article.user && !current_user.admin?
    flash[:notice] = "You can only edit or delete your own article"
    redirect_to @article
  end
end
```
- same to add articles/show.html.erb, allow admin to edit all articles.   
```
<% if logged_in? && (@article.user == current_user || current_user.admin?) %> 
  <%= link_to 'Edit', edit_article_path(@article), class: "btn btn-outline-info" %>
  <%= link_to 'Delete', @article, method: :delete, data: { confirm: 'Are you sure?'}, class: "btn btn-outline-danger" %>
<% end %>
```
- allow admin to delete user but not edit the user profile
```users/index.html.erb
 <% if logged_in? %>
  <% if user == current_user %>
    <%= link_to 'Edit profile', edit_user_path(user), class: "btn btn-outline-info" %>
  <% end %>
  <% if current_user.admin? %>
    <%= link_to 'Delete user', user_path(user), class: "btn btn-outline-danger", method: :delete, data: {confirm: "Are you sure you want to delete the user account and associated all articles?"} %>
  <% end %>
<% end %>
```
- update controller layer to allow admin to do delete action  
```
def require_same_user
  if current_user != @user && !current_user.admin?
    flash[:notice] = "You can only edit or delete your own profile"
    redirect_to @user
  end
end
```
- To prevent logged out automatically from admin role, need to further update source code   
```
def destroy
  @user.destroy
  session[:user_id] = nil if @user == current_user // added if condition here
  flash[:notice] = "Account and all associated articles are deleted successfully."
  redirect_to articles_path
end
```






