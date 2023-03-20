##### continuously develop after release as product
- (1) Suppose the website has released and after that new features continuously developed and released, in that case, we create branches in git, after test, merge branch to master.
```
git branch -b feature-new
git checkout feature-new
git checkout master
```

- (2) create table
```
rails generate migrate create_users
// open migrate file add columns
rails db:migrate //table is added to schema file
```
- (3) create model User.rb under app/model folder
- (4) run 'rails console' ('rails c')
-  