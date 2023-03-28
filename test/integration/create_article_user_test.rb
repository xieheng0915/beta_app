require 'test_helper'

class CreateArticleUserTest < ActionDispatch::IntegrationTest
  setup do
    @normal_user = User.create(username: "joice", email: "joice@example.com", password: "password", admin: false)
    sign_in_as(@normal_user)
  end

  test "get new article form and create article" do
    get "/articles/new"
    assert_response :success
    assert_difference 'Article.count', 1 do 
      post articles_path, params: { article: { title: "test new article", 
                              description: "description of new article for integration test", 
                              category_ids: "4,5" } }
      assert_response :redirect
    end
    follow_redirect!
    assert_response :success
    assert_match "5", response.body
    assert_match "4", response.body
    assert_select 'div.alert'
  end
end
