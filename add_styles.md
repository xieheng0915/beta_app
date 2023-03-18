##### Front-end styling

_Reference:_
+ [Bootstrap](https://getbootstrap.com/)
+ [Semantic UI](https://semantic-ui.com/)
+ [Materialize CSS](https://materializecss.com/)
+ [MDN doc](https://developer.mozilla.org/en-US/docs/Web/HTML)
+ [Shay Howe](https://learn.shayhowe.com/)
+ mockup tool: [Balsamiq](https://balsamiq.com/)

 _you can use cdn, paste code to html, but you also can install bootstrap in ruby env, save cp+paste work._

###### Install bootstrap to rails 6
- [Add Bootstrap 4 to your Ruby on Rails 6 application](https://www.mashrurhossain.com/blog/rails6bootstrap4)
- (1) install boostrap by command:
```
  yarn add bootstrap@4.6.2 jquery popper.js
```
here use 4.x instead of 5.x because I want to use jumbotron in v4.x and 4.6.2 is the latest version of 4.x family.   
- (2) After installation, open package.json, confirm below is added.
```
  "bootstrap": "4.6.2",
  "jquery": "^3.6.4",
  "popper.js": "^1.16.1",
```
- (3) cp navbar code to application.html.erb file 
- (4) add config in app/assets/stylesheets/application.css, then reload homepage again, confirm navbar is activated.  
```
*= require bootstrap //new added
*= require_tree .
*= require_self
```
- (5) add js code to app/javascript/packs/application.js
```
import "bootstrap"
```
- (6) add below js code to config/webpack/environment.js
```
const webpack = require("webpack")

environment.plugins.append("Provide", new webpack.ProvidePlugin({
  $: 'jquery',
  jQuery: 'jquery',
  Popper: ['popper.js', 'default']
}))
```
- (7) Add container section into application.html.erb 
- (8) Use bootstrap color configuraion, create a new file: custom.css.scss under app/assets/stylesheets folder, import bootstrap and customize the style.  
```
@import 'bootstrap/dist/css/bootstrap';

.navbar {
  background-color: #FDF6EA !important;
  }
  
.navbar-brand {
  font-size: 3rem;
}  
  
h1 {
  color: darkblue;
}
```



