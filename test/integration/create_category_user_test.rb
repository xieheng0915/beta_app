require 'test_helper'

class CreateCategoryUserTest < ActionDispatch::IntegrationTest
  setup do
    @normal_user = User.create(username: "joice", email: "joice@example.com", password: "password", admin: false)
    sign_in_as(@normal_user)
  end

  test "get new category form and reject creating category" do
    get "/categories/new"
    assert_no_difference 'Category.count' do 
      post categories_path, params: { category: { name: "Cooking" } }

    end
    follow_redirect!
    assert_response :success
    assert_select 'div.alert'
  end

end
