json.array!(@users) do |user|
  json.extract! user, :id, :name, :email, :password, :password_confirmation, :token
  json.url user_url(user, format: :json)
end
