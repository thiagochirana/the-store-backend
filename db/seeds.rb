User.find_or_create_by!(
  email: "boss1@the-store.com"
) do |user|
  user.name = 'Chefe admin'
  user.role = :shopowner
  user.password = "123456789"
  user.password_confirmation = "123456789"
end

User.find_or_create_by!(
  email: "boss2@the-store.com"
) do |user|
  user.name = 'Chefe admin'
  user.role = :shopowner
  user.password = "123456789"
  user.password_confirmation = "123456789"
end
