desc "Lists the users of the organization"
task :list_users do

  query_options = {}

  all = UserService.get_all(query_options)
  puts "users (all): #{JSON.pretty_generate(all.to_a)}"

  by_name = all.lazy.select { |user| user["name"] == "Josh Sherman" }.to_a
  puts "users by name: #{JSON.pretty_generate(by_name.to_a)}"

end
