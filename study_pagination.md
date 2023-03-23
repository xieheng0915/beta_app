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

