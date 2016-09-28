log "the notify" do
  notifies :write, "log[before]", :before
end

log "before" do
  action :nothing
end
