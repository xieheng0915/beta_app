###### continuously develop after release as product
- (1) Suppose the website has released and after that new features continuously developed and released, in that case, we create branches in git, after test, merge branch to master.
```
git branch -b feature-new
git checkout feature-new
git branch
```

- (2) create table
```
rails generate migrate create_users
// open migrate file add columns
rails db:migrate //table is added to schema file
```
- (3) create model User.rb under app/model folder
- (4) run 'rails console' ('rails c'), add some data, exit
- (5) git commit to the branch
```
git add -A
git commit -m "comments"
```
- (6) merge branch
```
git checkout master
git merge feature-new
```
- (7) delete the branch
```
git branch -d feature-new
git branch -D feature-new //to delete a branch not merged to master
```

- (8) repeat above steps to craete new features.
- Some useful commands in rails console
```
>reload!
>user = User.new(usernmame: "a", email: "aa@bb.cc") //violate the validation rule
>user.valid? //->false
>user.errors.full_messages //print out errors
```
[Validate for rails:](https://guides.rubyonrails.org/active_record_validations.html)
[A tester to test email regex validation](https://rubular.com/)

###### association: one-to-many
- user : 1<->* : articles, 
In user.rb, add:  
```
has_many :articles
```
In article.rb, add: 
```
belongs_to :user
```
- run "rails c" 
```
>article = Article.first
>user.articles << article
>user.article
>article.user
```

###### Add bcrypt feature
- enable gem bcrypt in gemfile
```
gem 'bcrypt', '~> 3.1.7'
```
- run "bundle install"
- add "add_secure_password" in user.rb
- run "rails generate migration add_password_digest_to_users"
- open new created migration file, add: 
```
class AddPasswordDigestToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :password_digest, :string
  end
end
```
- run "rails db:migrate"
- run "rails c", check "User.all", confirm password_digest column is generated.
```
BCrypt::Password.create("password123") //check it is converted to hash pwd
user=User.first
user.password="password123"
user.save //check password is converted to hash automatically
user.authenticate("wrongpassword") //check returned false
user.authenticate("password") //check returned user object
```

