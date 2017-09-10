json.extract! user, :id, :userid, :name, :q1, :q2, :q3, :q4, :q5, :created_at, :updated_at
json.url user_url(user, format: :json)
