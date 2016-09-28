
file "/tmp/foo.xy" do
  action :delete
end

file "/tmp/foo.xy" do
  content "some stuff"
  notifies :run, 'execute[true]', :immediately
end

execute "true" do
  not_if "false"
end
