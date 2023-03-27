###### hotkey for ruby on rails (mac)
select the target lines, **"command + /"** comment out multiple line with single line comment "#" in each line.
select the target lines, **"option + shift + A"** comment out multiple line with "=begin" and "=end"

###### Test-driven development: add testing rails application
[Testing on rails applications:](https://guides.rubyonrails.org/testing.html)  
**unit test of model**
- folder: app_root/test/models, add category_test.rb  
```
require 'test_helper'
class CategoryTest < ActiveSupport::Testcase
end
```
- goto terminal, in application root path, run "rails test", this will run all tests.
- add test case, and error said no category  
```category_test.rb
class CategoryTest < ActiveSupport::TestCase

  test "category should be valid" do 
    @category = Category.new(name: "Sports")
    assert @category.valid?
  end
end
```
- add category model: app/model/category.rb
```
class Category < ApplicationRecord
end
```
- run test case again, saying could find categories table.
- Build table, in terminal, run "rails generate migration create_categories"
- Open migration file add columns:  
```
class CreateCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :categories do |t|
      t.string :name
      t.timestamps
    end
  end
end
```  
- run "rails db:migrate", open schema.rb,confirm the table structure, then run "rails test" again, the errors disappeared, test passed.   
- Another way to confirm is to run "rails c" and check category has been created.  
Repeat the above process, write test case first, then add code.   
sample: category_test.rb and model/category.rb  

**unit test/functional test of controller**
- use scaffold to generate test for controller unit_testcases
```terminal
rails generate test_unit:scaffold category
```
result:   
```
Running via Spring preloader in process 25805
create  test/controllers/categories_controller_test.rb
create  test/system/categories_test.rb
```  
you can comment out those not needed test cases.   

- To run tests with other modes:   
```
rails test test/controllers //run test under particular folder
rails test test/controllers/categories_controller_test.rb
```  
- add routes, rerun tests, error msg changed
- add controller, rerun tests, error msg showing no actions
- add actions: new,index,show, rerun tests, errors show no templates
- add view/categories/show|index|new.html.erb, rerun tests, passed. 


###### develop category creation feature
- activate below test code and add some params.  
```
test "should create category" do
  assert_difference('Category.count', 1) do
    post categories_url, params: { category: { name: "Travel" } }
  end

  assert_redirected_to category_url(Category.last)
end
```
- add new.html.erb contents
- add new and create actions in categories controller
- rerun test, and confirm tests passed.  
- run rails console to check database 
- create a new category from client end and check the result.

###### add show category feature
**create Integration test cases**   
- Terminal, run "rails generate integration_test create_category"
```
❯ rails generate integration_test create_category
Running via Spring preloader in process 32550
invoke  test_unit
create    test/integration/create_category_test.rb
```   
An integration test case will be generated in test/integration folder. 
- Edit test case file (create_category_test.rb)   
```
require 'test_helper'

class CreateCategoryTest < ActionDispatch::IntegrationTest
  test "get new category form and create category" do
    get "/categories/new"
    assert_response :success
    assert_difference 'Category.count', 1 do 
      post categories_path, params: { category: { name: "Sports" } }
    end
  end
end
```
- run test and error msg said "Sports" are not shown in the view page
- add category name to view: 
```
<h1 class="text-center mt-4"><%= @category.name %> </h1>
```
- rerun test, showing nil class, add below code to controller
```
def show
  @category = Category.find(params[:id])
end
``` 
- rerun test and pass all cases
- Continue to add more integration test cases
```
test "get new category form and reject invalid category submission" do
  get "/categories/new"
  assert_response :success
  assert_no_difference 'Category.count' do 
    post categories_path, params: { category: { name: " " } }
  end
  assert_match "Sports", response.body
  assert_select 'div.alert'  # check if UI have alerting messages in _error.html.erb
  assert_select 'h4.alert-heading'
end
```  
###### create category list (index) by starting with integration test cases
- generate test case
```
❯ rails generate integration_test list_categories
Running via Spring preloader in process 35040
invoke  test_unit
create    test/integration/list_categories_test.rb
```
- add test case for category listing:
```
require 'test_helper'

class ListCategoriesTest < ActionDispatch::IntegrationTest
  def setup
    @category = Category.create(name: "Sports")
    @category2 = Category.create(name: "Travel")
  end

  test "should show categories listing" do
    get '/categories'
    assert_select "a[href=?]", category_path(@category), text: @category.name
    assert_select "a[href=?]", category_path(@category2), text: @category2.name

  end
end
```
- run test and confirm error saying not found categories 
- add contents of index.html.erb
- rerun test and found no object found (nil class), need to add to index action in controller

###### add pagination for categories
- add view pagination (refer to articles index page)
```
<div class="flickr_pagination">
  <%= will_paginate @categories, :container => false %>
</div>
```
- add pagination to controller (refer to article index action)
```
  def index
    @categories = Category.paginate(page: params[:page], per_page: 5)
  end
```
- rerun test, ensure all test cases passed

###### restrict category access only to admin
- add test case in categories_controller_test.rb
```
test "should not create category if not admin" do
  assert_no_difference('Category.count') do
    post categories_url, params: { category: { name: "Travel" } }
  end
```
- run controller test: "rails test test/controllers/categories_controller_test.rb" and confirm error msg
- add admin restriction code in categories controller
```
  before_action :require_admin, except: [:index, :show]
  #...
  def require_admin
    if !(logged_in? && current_user.admin?)
      flash[:alert] = "Only admins can perform that action"
      redirect_to categories_path
    end
  end
```
- rerun test and this test case passed but previous test failed, which is correct result, because no admin user created for this test.  
  - (1) create admin user 
  ```
    @admin_user = User.create(username: "johndoe", email: "johndoe@example.com", password: "password", admin: true)
  ```
  - (2) add sign in function in test_helper
  ```
    def sign_in_as(user)
      post login_path, params: { session: { email: user.email, password: "password"} }
    end
  ```
  - (3) add sign in as admin before each test case
  ```
    test "should get new" do
      sign_in_as(@admin_user)  # added here
      get new_category_url
      assert_response :success
    end

    test "should create category" do
      sign_in_as(@admin_user)  # added here
      assert_difference('Category.count', 1) do
        post categories_url, params: { category: { name: "Travel" } }
      end

      assert_redirected_to category_url(Category.last)
    end
  ```
- rerun test and confirm all test cases passed  
- run the integration test by run "rails test" should have errors, need to add admin user before test as well, in test/integration/create_category_test.rb, add:  
```
  setup do
    @admin_user = User.create(username: "johndoe", email: "johndoe@example.com", password: "password", admin: true)
    sign_in_as(@admin_user)
  end
```
- rerun test and confirmed all tests passing
- Also confirm from UI 
- Add entry in navigation bar
```
  <li class="nav-item dropdown">
    <a class="nav-link dropdown-toggle" href="#" role="button" data-toggle="dropdown" aria-expanded="false">
      Categories
    </a>
    <div class="dropdown-menu">
      <% if logged_in? && current_user.admin? %>
        <%= link_to 'Create new category', new_category_path, class: "dropdown-item" %>
      <% end %>
      <%= link_to 'View categories', categories_path, class: "dropdown-item" %>
    </div>
  </li>
```

###### add many-to-many association  
[official doc: has-many through association 2.4](https://guides.rubyonrails.org/association_basics.html#the-has-many-through-association)

- run "rails generate migration create_article_categories"
```
❯ rails generate migration create_article_categories
Running via Spring preloader in process 43621
invoke  active_record
create    db/migrate/20230326162311_create_article_categories.rb
```
- add code to migration file under db folder
```
class CreateArticleCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :article_categories do |t|
      t.integer :article_id
      t.integer :category_id
    end
  end
end
```
- run "rails db:migrate"
- add model file article_category.rb
```
class ArticleCategory < ApplicationRecord
  belongs_to :article
  belongs_to :category
end
```
in article.rb, add : 
```
  has_many :article_categories
  has_many :categories, through: :article_categories
```
in category.rb, add: 
```
  has_many :article_categories
  has_many :articles, through: :article_categories
```
- run "rails c" and "reload!", check the relationship has built up
```
>article = Article.last
>article.categories
>category = Category.last
>category.articles
```
- associate in console
```
>category.articles << article
>category.articles  // check they're associated already
>category.articles << Article.first // associate more articles
>category.articles //confirm there are 2 articles associated with this category
>category.articles.count // =>2
>article.categories
>article.categories << Category.first // add one more category
>article.categories.count // =>2
```
- add category_ids in controller, article params  
```
  def article_params
    params.require(:article).permit(:title, :description,  category_ids: [])
  end
```
- add association from UI client side, add dropdown list in frontend
[official doc: how to add select box with ease 3.2,3.3](https://guides.rubyonrails.org/v6.0/form_helpers.html#making-select-boxes-with-ease)   
**Be careful to use v6.0 doc here**  

- add this to view/articles/_form.html.erb
```
<div class="form-group row">
  <%= f.label :category, class: "col-2 col-form-label text-light" %>
  <div class="col-10">
  <%= f.collection_select(:category_ids, Category.all, :id, :name) %>
  </div>
</div>
```
- change to prompt, multiple options and change the code:  
[collection select sample](https://apidock.com/rails/ActionView/Helpers/FormOptionsHelper/collection_select)  
[stackoverflow: collection select multiple options](https://stackoverflow.com/questions/18074710/select-multiple-options-in-a-collection-select-rails)  
```
<%= f.collection_select(:category_id, Category.all, :id, :name, { prompt: "Make your selection from the list below (can be empty)"}, { multiple: true}) %>
``` 
- add bootstrap stylish code  
[refer: bootstrap: component -> form -> select menu](https://getbootstrap.com/docs/4.5/components/forms/)   
``` 
<%= f.collection_select(:category_id, Category.all, :id, :name, { prompt: "Make your selection from the list below (can be empty)"}, { multiple: true, size: 3, class: "custom-select shadow rounded"}) %>
```  
"size: 3" : define the height of select menu.  

###### display categories on view page
- **show page:** add category name under each article detail page, instead of iteration, rails provide "render @article.categories" method to render each category object as categories partial.  
```
<% if @article.categories.any? %>
  <%= render @article.categories %> 
<% end %>
```  
and partial is defined in view/categories/_category.html.erb  
```
<%= category.name %>
```  
reload the webpage, category names are shown under the gravator image.  
- add stylish badge
  - (1) add space with gravatar image with "mt-2"
  ```
  <div class="mt-2"><%= render @article.categories %></div> 
  ```
  - (2) add stylish code in category object
  [refer: badge by bootstrap: pill badge](https://getbootstrap.com/docs/4.0/components/badge/)
  ```_category.html.erb
  <%= link_to category.name, category_path(category), class: "badge badge-pill badge-info mr-1" %>  
  ```   
  "mr-1" add margin between badges  

- **index page:** same add badges to _article.html.erb as below
```
<% if article.user %>
  by <%= link_to article.user.username, user_path(article.user) %>
<% end %>
<% if article.categories.any? %>
  <div class="mt-2"><%= render article.categories %></div> 
<% end %>
</div>
```
- and this badges are activated in user profiles, since they are using _article.html.erb as well.  

###### enrich category list(index) and show page
- **category list page** add articles number of category in each category card, <p></p> section is copied from users/index.html.erb  
```
<div class="card-body">
  <h5 class="card-title"><%= link_to category.name, category_path(category), class: "text-success" %></h5>
  <p class="card-text"><%= pluralize(category.articles.count, "article")%></p>
</div>
```  
- **show page of each category** add all articles belongs to that category, similarly copy from users/show.html.erb to categories/show.html.erb and customize to category.(refer to categories/show.html.erb)  
- To get articles of category, in categories_controller.rb show action:  
```
  def show
    @category = Category.find(params[:id])
    # find articles belongs to the category with pagination
    @articles = @category.articles.paginate(page: params[:page], per_page: 3)
  end
``` 
###### add "edit" category name action: 
- create categories/edit.html.erb
- create _form.html.erb, and separate core code from new.html.erb to _form.html.erb, in new file add "<%= render 'form' %>"
- copy left part of new.html.erb to edit.html.erb 
(refer to source code of new/edit/_form.html.erb)  












