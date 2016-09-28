

log "one" do
  notifies :write, 'log[two]', :delayed
end

# this is legitimately testing a 'strange' notification bug
# where calling an LWRP provider that did use_inline_resources
# (but not calling a custom resource) caused delayed notifications
# to double-fire.
an_lwrp_provider "foo"

log "two" do
  action :nothing
end
