###### push to heroku and run rails console in heroku side
- run "git push heroku master"
- run "heroku run rails db:migrate" to build up database in server side
- run "heroku run rails console" to access heroku console
- in console, clear all data
```
>Article.delete_all
```