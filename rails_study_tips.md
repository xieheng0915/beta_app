### tips to change env from rails 6 to rails 7
```
rvm list rubies
```
or
```
rvm list
```
Use this to check rubies versions, and switch ruby from current v2.6.10 to v.3.0.0, because required ruby version for rails should be higher than v2.7.x
```
ruby --default use v3.0.0
```

In case you need to update, please install the latest version.

```
gem install rails -v 7.x.x.x
```
or just use
```
gem install rails
```
This will install the latest version 

**Please ensure rails project managed in rails_7_space**

### Create app with rails:  
```
rails new your_app_name
```

##### issue1: dlopen puma loadError

- ensure yarn is installed, if not "gem install yarn" to install 
- loaderror: puma server: 
Error message: 
> <internal:/Users/username/.rvm/rubies/ruby-3.0.0/lib/ruby/3.0.0/rubygems/core_ext/kernel_require.rb>:85:in `require': dlopen(/Users/username/.rvm/gems/ruby-3.0.0/gems/puma-6.1.1/lib/puma/puma_http11.bundle, 0x0009): symbol not found in flat namespace (_SSL_get1_peer_certificate) - /Users/username/.rvm/gems/ruby-3.0.0/gems/puma-6.1.1/lib/puma/puma_http11.bundle (LoadError)
Reason:  it looks like rails 3.0.x is not compatible with openssl version, should stay in ruby 2.7.  
[referred issue discussion tip](https://github.com/puma/puma/issues/2790)  
to check openssl version:  
```
openssl version
```
currently openssl show: 3.0.7.1  
```
rvm list
rvm list known //check what version could install
rvm install 2.7.2 // install version
rvm --default use 2.7.2 //set default version
```

- When you switch to different ruby version, you need to reinstall rails 
  [Getting Started with Rails:](https://guides.rubyonrails.org/v5.1/getting_started.html)

*1st step:* tried to switch to ruby 2.7.2, but it didn't work, then delete rails 7.0.4.3, try to switch to rails 6.0.2, please pay attention to deletion steps, you need to delete railities (global setting) as well, refer to below:  
[How to uninstall a specific version of Rails from your development machine
](https://www.aloucaslabs.com/miniposts/how-to-uninstall-a-specific-version-of-rails-from-your-development-machine)


- To remove ruby version by rvm: 
  ```
  rvm list rubies
  rvm uninstall 3.0.0 
  ```

*2nd step:* puma version (v5.6.x) doesn't compatible with openssl version (3.0.x), try to remove puma and install v4.x
[Error installing puma: ERROR: Failed to build gem native extension](https://github.com/puma/puma/issues/2328)
  ```
  gem uninstall puma

  ```
  check openssl version
  ```
  openssl version
  ```

Finally, puma 4.2.1 + openssl 3.0.x + rails 6.0.2 works.  
Maybe we can reinstall openssl to lower version instead, not verified here. 
  ```
  gem install rails -v '6.0.2'
  rails -v
  gem install puma -v '4.2.1'
  puma -v
  rails new app_name
  cd app_name
  rails s
  ```

  
##### how to confirm kernal version in mac os
```
sysctl kern.version
sysctl kern.ostype
sysctl kern.osrelease
sysctl kern.osrevision
```  

##### upload to github and sync with remote branches continuously
- Local env
  ```
  git status
  git add -A
  git commit -m "comments"
  git status
  ```
- Remote github 
  ```
  git remote add origin git@your_git_ssh_link.git
  git remote -v
  git branch -M master
  git push -u origin master
  ```

- to reject lastest changes, can use below:  
  ```
  git checkout -f
  ```
  If you have error when upload your source code, need to add SSH key first.  


##### add basic controllers and features
- app_name/app/config/routes.rb add:
  ```
  root 'pages#home'
  ```
- use command line to create controller and view:
  ```
  rails create controller pages
  ```
- add code in pages_controller.rb and in app/views folder, add home.html.erb, add some code to check the real-time update in localhost:3000
- add about page: 
  in route.rb, add:
  ```
  get 'about', to: 'pages#about'
  ```
  in pages_controller.rb
  ```
  def about
  end
  ```
  add about.html.erb, add some code, then check localhost:3000/about    


##### Deploy app to heroku 

- preparation of heroku, sign up 
- preparation of heroku, install heroku cli, [The Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli)
  ```
  brew tap heroku/brew && brew install heroku
  ```  
  **If you have multiple ruby environment with rvm, when you switch to different ruby version env, you need to reinstall all the packages, including heroku cli.**  

- edit gemfile, remove local database sqlite,
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

##### issue2: gem install pg failed

[CANNOT INSTALL ‘PG’ GEM IN MAC OSX](https://medium.com/@naveeninja/cannot-install-pg-gem-in-mac-osx-ddd9e3df1748)

```
find / -name “pg_config”
gem install pg -- --with-pg-config=/usr/local/Cellar/libpq/15.2/bin/pg_config
```
The reason is pg library need to be installed before installation.  

Then run "bundle install" again. 


- deploy to heroku by cli
  ```
  heroku --version
  heroku login //open browser
  cd app_root_folder
  heroku create
  git push heroku master 
  ```
  **tip: If you haven't upload latest version to github, you need to git push to github before push to heroku git**

  ##### issue3: heroku push rejected
  error message: 
   >remote:  !
    remote:  !     The Ruby version you are trying to install does not exist on this stack.
    remote:  !
    remote:  !     You are trying to install ruby-2.7.2 on heroku-22.
    remote:  !
    remote:  !     Ruby ruby-2.7.2 is present on the following stacks:
    remote:  !
    remote:  !     - heroku-18
    remote:  !     - heroku-20
    remote:  !
    remote:  !     Heroku recommends you use the latest supported Ruby version listed here:
    remote:  !     https://devcenter.heroku.com/articles/ruby-support#supported-runtimes
    remote:  !
    remote:  !     For more information on syntax for declaring a Ruby version see:
    remote:  !     https://devcenter.heroku.com/articles/ruby-versions
    remote:  !

  - (1) switch heroku stack-22 to stack-20 then redo git push to heroku, but rejected again.  
  ```
  heroku create
  heroku stack
  heroku stack:set stack-20
  git push heroku master
  ```

  or 
  ```
  heroku create --stack heroku-20
  git remote -v
  git remote remove heroku //remove previous repository in heroku
  git remote -v //check again
  heroku git:remote -a frozen-sierra-38859 //set remote repo 
  git push heroku master
  ```
  [Deploying with git](https://devcenter.heroku.com/articles/git)

  - (2) Install npm and yarn to ensure package-lock.json, and yarn.lock updated to latest version, but this still failed.
  [Troubleshooting Node.js Deploys](https://devcenter.heroku.com/articles/troubleshooting-node-deploys)

  - (3) remove remote heroku repo, add version in package.json file and used buildpacks
  Tip: you have to **stop local server before push to heroku server**
  ```
  heroku buildpacks:set heroku/nodejs
  ```
  ```package.json
  "engines": {
    "node": "14.x",
    "npm": "6.x",
    "yarn": "1.x"
  },
  ```
  delete lock files: 
  ```
  git rm package-lock.json
  git rm yarn.lock
  ```
  then start from 'heroku create --stack:set stack-20' and git push to heroku again

  [Troubleshooting Node.js Deploys](https://devcenter.heroku.com/articles/troubleshooting-node-deploys)

  Finally deploy succeeded, but application has error, didn't show properly. 
  use 'heroku logs -tail', found below error message: 
  >2018-12-06T17:01:39.670033+00:00 heroku[web.1]: Starting process with command `npm start`
  2018-12-06T17:01:37.789569+00:00 app[api]: Scaled to web@1:Free by user xxxxxxxx@xxxx.com
  2018-12-06T17:01:38.000000+00:00 app[api]: Build succeeded
  2018-12-06T17:01:37.767042+00:00 app[api]: Release v3 created by user xxxxxxxx@xxxx.com
  2018-12-06T17:01:41.658747+00:00 app[web.1]: **npm ERR! missing script: start**
  2018-12-06T17:01:41.665561+00:00 app[web.1]:
  2018-12-06T17:01:41.665874+00:00 app[web.1]: npm ERR! A complete log of this run can be found in:
  2018-12-06T17:01:41.666017+00:00 app[web.1]: npm ERR!     /app/.npm/_logs/2018-12-06T17_01_41_660Z-debug.log
  2018-12-06T17:01:41.736904+00:00 heroku[web.1]: State changed from starting to crashed
  2018-12-06T17:01:41.738983+00:00 heroku[web.1]: State changed from crashed to starting
  2018-12-06T17:01:41.719407+00:00 heroku[web.1]: Process exited with status 1

- (4) add heroku buildpacks 
  ```
  bundle clean --force
  gem uninstall bundler
  gem install bundler
  rm Gemfile.lock
  bundle lock --add-platform x86_64-linux
  bundle install --without production
  ```
  Then here you need to git commit to remote as always.
  and: 
  ```
  heroku apps:destroy //this command can delete remote repo directly.
  heroku create --stack heroku-20
  heroku buildpacks:set heroku/nodejs
  heroku buildpacks:add heroku/ruby  //this is the key of final step
  ```
  finally: 
  ```
  git commit -a -m "retry building"
  git push heroku master
  heroku logs --tail
  heroku run rails db:migrate //run migrate files
  ```

  [Ruby on Rails チュートリアル第1章で Heroku へのデプロイに失敗 (2周目)](https://dhtakeuti.hatenablog.com/entry/2018/12/11/142638)

  
  - rename application name: 
  ```
  heroku open
  heroku rename alpha-app-6
  ```

  