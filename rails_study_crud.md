##### Create app general process and create table by hand

+ 1: 
  ```
  rails new app_name
  cd app_name
  rails s // start server
  ```
+ 2, app_name/config/routes.rb
  ```
  root 'pgaes#home'
  get 'about', to: 'pages#about'
  ```
+ 3, add controller, app/controller/pages_controller.rb
  ```
  class PageController < ApplicationController
    def home
    end

    def about
    end
  end
  ```
+ 4, add view, app_name/app/view/pages/action_name.html.erb
  ```home.html.erb
  <h1>Home page</h1>
  <p>Hello rails.</p>
  ```
+ 5, add tables: [refer to Generate CRUD by command](#generate-crud-by-command)
  
+ 6, add model: app_name/app/model/article.rb, then use 'rails c' console to load Article model, after that, [refer to rails console](#rails-console)

+ 7, add routes in route,controller, view as well, [refer to display&controller&model CRUD features](#displaycontrollermodel-crud-features)
  ```
  resources :articles
  ```
 Use 'rails routes --expanded' to generate routes by command, here all the CRUD routes are generated.
+ 8, routes.rb, change configuration to below:
  ```
  resources :articles, only: [:show]
  ```
  Use 'rails routes --expanded' to generate routes again, here only show 
  ```
  --[ Route 3 ]--------------------------------------------------------------
  Prefix            | article
  Verb              | GET
  URI               | /articles/:id(.:format)
  Controller#Action | articles#show
  ```








  
##### Generate CRUD by command
  ```
  rails generate scaffold Article title:string description:text //create controller, db, view, test etc. 
  rails db:migrate // create db schema.sql
  rails route --expanded //show crud apis on command line with better format
  ```
  then open localhost:3000/articles to confirm

  - (1) to create table only
  ```
  rails generate migration create_students
  ```
  - (2) Open migration file add columns, file in app_name/db/migration folder
  - (3) command line: 
  ```
  rails db:migrate
  ```
  therefore, table will be added in schema.rb
  - (4) If you want to edit, one way is to add column and execute below command line: 
  ```
  rails db:rollback //delete the previous table
  rails db:migrate
  ```
  - (5) Or you can generate a new migration file and do the change
  ```
  rails generate migration add_colomun_to_student
  ```
  then add contents in the new migration file and execute "rails db:migrate" again.
  ```migration file
  class AddTimestampsToStudents < ActiveRecord::Migration[6.0]
    def change
      add_column :students, :created_at, :date_time
    end
  end
  ```

  
###### rails console
- Create
```
rails c //to start rails console
exit // to quit rails console
Article.all // if Article mode is null, it will show loading an empty collection; if not, show all the data sets
Article.create(title: "forth article", description: "desc. of the forth article.")
article = Article.new
article.title="fifth article"
article.description="desc. of the fifth article"
article.save
article = Article.new(title: "the eighth article", description: "desc. of the eighth article.")
article.save
```

- Read/Update
```
Article.find(2)
Article.first
Article.last
article=Article.find(2)
articles=Article.all
article.title
article.description
article.description="edited - description of second article"
article.save //save to db
```

- Delete
```
article=Article.last
article.destroy //no need to save
Article.all
```

###### validation
```article.rb
class Article < ApplicationRecord
  validates :title, presence: true
end
```
in rails console:
```
reload! // to enable the validation
article=Article.new(description: "desc of a null title art")
article.save // show false, when check with Article.all, the new record is not updated to db.
article.errors.full_messages // show all the error messages
```

Add more constrains: 
```article.rb
class Article < ApplicationRecord
  validates :title, presence: true, length: {minimum: 6, maximum: 100}
  validates :description, presence: true, length: {minimum: 10, maximum: 300}
end
```

[More validations: ](https://guides.rubyonrails.org/active_record_validations.html)



  
  

###### display&controller&model CRUD features  
- (1) add resource set in routes.rb
```
resources :articles, only: [:show]
```
Here use 'rails routes --expanded' to check the detail and set up, if omit 'only:' set, all the resources are accessible.  

- (2) for controller file: articles.controller.rb
```
class ArticleController < ApplicationController
  def show
    byebug //to enable byebug console
    //Call 'byebug' anywhere in the code to stop execution and get a debugger console
    @article = Article.find(params[:id]) 
  end
end
```
- (3) Add views/articles/show.html.rb
```
<h1>showing article details</h1>
<p><strong>Title: </strong><%= @article.title %></p>
<p><strong>Description: </strong><%= @article.description %></p>
```
here '<% %>' is ruby tag, and '=' is evaluate the code  

**If you have already created articles crud by command, above doesn't work anymore.this will conflict with index action.**

###### Add articles list page

- (1) routes.rb

```routes.rb
resources :articles, only: [:show, :index]
```
run 'rails routes --expanded' to make sure articles#index is generated
```
--[ Route 3 ]-------------------------------------------------------------------------------------------------
Prefix            | articles
Verb              | GET
URI               | /articles(.:format)
Controller#Action | articles#index
```

- (2) in cotroller file: 
```
def index
  @articles = Article.all
end
```
- (3) add index.html.erb
```
<table>
  <thead>
  
    <th>Title</th>
    <th>Description</th>
    <th>Actions</th>
  </thead>
  <tbody>
    <% @articles.each do |article| %>
      <tr>
      <td><%= article.title %></td>
      <td><%= article.description %></td>
      <td>palceholder</td>
      </tr>
    <% end %>
  </tbody>
</table>
```

###### Build a new article action

- (1) add route in routes.rb
  ```
  Rails.application.routes.draw do
    root 'pages#home'
    get 'about', to: 'pages#about'
    resources :articles, only: [:show, :index, :new, :create]
  end

  ```
- (2) 'rails routes --expanded' to generate below routes: 
  ```
  --[ Route 4 ]-------------------------------------------------------------------------------------------------
  Prefix            |
  Verb              | POST
  URI               | /articles(.:format)
  Controller#Action | articles#create
  --[ Route 5 ]-------------------------------------------------------------------------------------------------
  Prefix            | new_article
  Verb              | GET
  URI               | /articles/new(.:format)
  Controller#Action | articles#new
  ```
- (3) Add action in controller
  ```
  def new
  end

  def create
    render plain: params[:article]
  end
  ```
- (4) add new.html.erb, this use form_with, which is using **ajax** by default
  [refer to form_helper here:](https://guides.rubyonrails.org/v6.0/form_helpers.html)

  sample code as below, Here local:true means use standard HTTP post instead of remotely using ajax. 
  ```
  <h1>Create a new article</h1>
  <%= form_with scope: :article, url: articles_path, local: true do |f|  %>

  <p>
  <%= f.label :title %>
  <br/>
  <%= f.text_field :title %>
  </p>

  <p>
    <%= f.label :description %>
    <br/>
    <%= f.text_area :description %>
  </p>

  <p>
    <%= f.submit %>
  </p>

  <% end %>
  ```

- (5) Save to db
  change controller to below:  
  ```articles_controler.rb
  def create
    #render plain: params[:article]
    @article = Article.new(params.require(:article).permit(:title, :description))
    #render plain: @article.inspect
    @article.save
    redirect_to article_path(@article) // redirect to localhost:3000/articles/{id}
    redirect_to @article //shortened, same effect.
  end
  ```

  - (6) validation and fresh messages
  
  Controller file: 
  ```
  def new
    #Create a new object instance to prevent null when first loading the page.
    @article = Article.new
  end

  def create
    #render plain: params[:article]
    @article = Article.new(params.require(:article).permit(:title, :description))
    #render plain: @article.inspect
    if  @article.save
      #redirect_to article_path(@article)
      redirect_to @article  
    else
      render 'new'
    end

  end
  ```
  new.html.erb, added error message displaying area:  
  ```
  <% if @article.errors.any? %>
  <h2>The following errors prevent the article to be submitted successfully.</h2>
  <% @article.errors.full_messages.each do |msg| %>
    <li><%= msg %></li>
    <% end %>
  <% end %>
  ```

- (7) flash message to notify user when successfully created record
in articles_controller.rb, add one line flash[:notice] 
  ```
  if  @article.save
    flash[:notice] = "Article was created successfully."
    #redirect_to article_path(@article)
    redirect_to @article  
  else
    render 'new'
  end
  ```

in application.html.erb, add common messages as below:  
  ```
  <% flash.each do |name,msg| %>
    <%= msg %> 
  <% end %>
  ```     

###### Update an article action (edit & update)
- (1) Add ':edit'and ':update' in routes.rb
- (2) Add 'edit' and 'update' action in controller
- (3) Run 'rails routes --expanded' to generate route
- (4) create edit.html.erb, copy from new.html.erb and update
- (5) add code in controller
```
  def edit
    @article = Article.find(params[:id])
  end
```
```
  def update
    @article = Article.find(params[:id])
    if @article.update(params.require(:article).permit(:title, :description))
      flash[:notice] = "Article was updated successfully."
      redirect_to @article
    else
      render 'edit'
    end
  end
```

###### Delete an article action (destroy)
- REST: mapping HTTP verbs (get, post, put/patch, delete) to CRUD actions
- (1) replace routes.rb as below, but this also expose all Restful API: 
```
  #resources :articles, only: [:show, :index, :new, :create, :edit, :update]
  resources :articles
```
- (2) execute 'rails routes --expanded' again
- (3) In index.html.erb, add delete link for each item.
```
<td><%= link_to 'Delete', article_path(article), method: :delete %></td>
```
  
###### Add layout links
- (1) same to add show and edit button, pick up 'edit_article' from 'rails routes' list, the prefix and verb, and get method could be omitted. 
```
  <td><%= link_to 'Show', article_path(article) %></td>
  <td><%= link_to 'Edit', edit_article_path(article) %></td>
```

- (2) add new article link
```
<%= link_to 'Create new article', new_article_path %>
```

- (3) add more links in show.html.erb
```
<%= link_to 'Edit', edit_article_path(@article) %> |
<%= link_to 'Delete', article_path(@article), method: :delete, data: { confirm: "Are you sure?" } %> |
<%= link_to 'Return to articles listing', articles_path %>
```
- (4) add confirmation modal before deleting
```
<td><%= link_to 'Delete', article_path(article), method: :delete, data: { confirm: "Are you sure?" } %></td>
```
- (5) in new.html.erb and edit.html.erb, add link back to list
```
<%= link_to 'Return to articles listing', articles_path %>
```

- (6) Add link to home and about pages
```
<%= link_to 'Articles listing', articles_path %> | 
<%= link_to 'About page', about_path %>
```
and 
```
<%= link_to 'Articles listing', articles_path %> | 
<%= link_to 'Home page', root_path %>
```

###### Rafactoring and DRY code
- Refactor controller:
  + before refactoring: 
    each action has duplicated methods 
  + after refactoring:
  extract duplicated parts, private method to the bottom:  
  ```
    private
    def set_article
      @article = Article.find(params[:id]) 
    end

    def article_params
      params.require(:article).permit(:title, :description)
    end
  ```
  add here in the begining of controller, declare the methods using this part: 
  ```
  before_action :set_article, only: [:show, :edit, :update, :destroy]
  ```
  and replace some places with private methods name.  

- Refactor view page: 
  + Extract the common part to new html, the file name have to start with "_", eg: "_message.html.erb" and render this page in the original html. (pay attention to the path of message file)
  ```
   <%= render 'layouts/messages' %>
  ```
  same as _form.html.erb with edit and new files.
  **new.html.erb has different contents with edit page,but unified with edit page contents, because url can be omitted here**
  ```new.html.erb
  <%= form_with scope: article, url: article_path, local: true do |f|  %>
  ```

  ```edit.html.erb
  <%= form_with(model: @article, local: true) do |f|  %>
  ```
  
  ###### deploy to heroku
  - (0) Install heroku cli and sign up to heroku site in advance
  - (1) edit gemfile, remove local database sqlite,
  ```
  group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'sqlite3', '~> 1.4'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  end
  ```

  and install postgresql: 
  ```
  group :production do
  gem 'pg'
  end
  ```

  - (3) Edit package.json
  ```package.json
    "engines": {
      "node": "14.x",
      "npm": "6.x",
      "yarn": "1.x"
    },
  ```
  - (4) run bundle install
  ```
    bundle install --without production
  ```
  - (4a) if (4) has error, use below command to rebuild
    + delete lock files: 
    ```
      git rm package-lock.json
      git rm yarn.lock
    ```
    + reinstall bundler
    ```
      bundle clean --force
      gem uninstall bundler
      gem install bundler
      rm Gemfile.lock
      bundle lock --add-platform x86_64-linux
      bundle install --without production
    ```
    + add buildpacks
    ```
      heroku apps:destroy //this command can delete remote repo directly.
      heroku create --stack heroku-20
      heroku buildpacks:set heroku/nodejs
      heroku buildpacks:add heroku/ruby  //this is the key of final step
    ```
    + repush to heroku 
    ```
      git commit -a -m "retry building"
      git push heroku master
      heroku logs --tail
      heroku run rails db:migrate //run migrate files
    ```

  - (5) add migrate files
  ```
    heroku run rails db:migrate //run migrate files
  ``` 
  - (6) rename repo from random name to your app name 
  ```
    heroku open
    heroku rename your_app_name
  ```

  ##### Routing update work 
  ```
  git add -A
  git commit -m "commit comments"
  git push origin master //to github repo
  git push heroku master //to heroku repo
  heroku run rails db:migrate //if any update on database, don't forget this step
  ```













