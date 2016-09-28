require 'tmpdir'
require 'chef/version'

describe "compat_resource cookbook" do
  let(:chef_repo_path) { Dir.mktmpdir }
  let(:cookbooks_path) { path = File.join(chef_repo_path, 'cookbooks'); Dir.mkdir(path); path }
  before do
    File.symlink(File.expand_path('../data/config.rb', __FILE__),
                 File.join(chef_repo_path, 'config.rb'))
    File.symlink(File.expand_path('../..', __FILE__),
                 File.join(cookbooks_path, 'compat_resource'))
    File.symlink(File.expand_path('../data/cookbooks/test', __FILE__),
                 File.join(cookbooks_path, 'test'))
    File.symlink(File.expand_path('../data/cookbooks/future', __FILE__),
                 File.join(cookbooks_path, 'future'))
    File.symlink(File.expand_path('../data/cookbooks/normal', __FILE__),
                 File.join(cookbooks_path, 'normal'))
    File.symlink(File.expand_path('../data/cookbooks/hybrid', __FILE__),
                 File.join(cookbooks_path, 'hybrid'))
    File.symlink(File.expand_path('../data/cookbooks/notifications', __FILE__),
                 File.join(cookbooks_path, 'notifications'))
    File.symlink(File.expand_path('../data/cookbooks/strange_notifications', __FILE__),
                 File.join(cookbooks_path, 'strange_notifications'))
    File.symlink(File.expand_path('../data/cookbooks/before', __FILE__),
                 File.join(cookbooks_path, 'before'))
    File.symlink(File.expand_path('../data/cookbooks/cloning', __FILE__),
                 File.join(cookbooks_path, 'cloning'))
    File.symlink(File.expand_path('../data/cookbooks/unmodified', __FILE__),
                 File.join(cookbooks_path, 'unmodified'))
  end

  require 'chef/mixin/shell_out'
  include Chef::Mixin::ShellOut
  before :all do
    FileUtils.rm_f(File.expand_path('../data/Gemfile.lock', __FILE__))
    Bundler.with_clean_env do
      shell_out!("bundle install --gemfile #{File.expand_path('../data/Gemfile', __FILE__)}")
    end
  end

  def run_chef(args)
    Bundler.with_clean_env do
      shell_out!("bundle exec chef-client -c #{File.join(chef_repo_path, 'config.rb')} -F doc #{args}",
                 environment: { 'BUNDLE_GEMFILE' => File.expand_path('../data/Gemfile', __FILE__) })
    end
  end

  it "should work with before notifications" do
    result = run_chef("-o before")
    expect(result.stdout).to match(/.*INFO: log\[the notify\] running why-run write action to support before action.*INFO: the notify.*INFO: before.*INFO: the notify.*/m)
  end

  it "should handle new-style recursive notifications" do
    result = run_chef("-o notifications")
  end

  it "should fix https://github.com/chef-cookbooks/compat_resource/issues/99" do
    result = run_chef("-o strange_notifications::one")
    expect(result.stdout).to match(/INFO: Processing log\[it worked\] action write/)
  end

  it "should fix https://github.com/chef-cookbooks/compat_resource/issues/87" do
    result = run_chef("-o strange_notifications::two")
    expect(result.stdout.scan("INFO: Processing log\[two\] action write").size).to eq(1)  # appears once
  end

  it "should definitely run a bunch of resources if we don't depend on compat_resource" do
    result = run_chef("-o unmodified")
  end

  it "should run a bunch of resources in a mixed-run" do
    result = run_chef("-o unmodified,test")
  end

  it "should not clone resources from the outer run context" do
    result = run_chef("-o future::declare_resource,cloning::default")
    expect(result.stdout).not_to match(/3694/)
  end

  it "when chef-client runs the test recipe, it succeeds" do
    result = run_chef("-o test::test,test")
#     expect(result.stdout).to match(/
# Recipe: test::test
#   \* future_resource\[sets neither x nor y\] action create \(up to date\)
#   \* future_resource\[sets both x and y\] action create
#     - update sets both x and y
#     -   set x to "hi" \(was "initial_x"\)
#     -   set y to 10 \(was 2\)
#   \* future_resource\[sets neither x nor y explicitly\] action create \(up to date\)
#   \* future_resource\[sets only y\] action create
#     - update sets only y
#     -   set y to 20 (was 10)
#   \* future_resource\[deletes resource\] action delete \(up to date\)
#   \* future_resource\[sets x and y via creation\] action create
#     - create sets x and y via creation
#     -   set x to "hi"
#     -   set y to 20
#   \* future_resource\[deletes resource again\] action delete \(up to date\)
#   \* future_resource\[sets x and y to their defaults via creation\] action create
#     - create sets x and y to their defaults via creation
#     -   set x to "16" \(default value\)
#     -   set y to 4 \(default value\)
# /)
  end
  if Gem::Requirement.new("< 12.6").satisfied_by?(Gem::Version.new(Chef::VERSION))
    it "when chef-client tries to declare_resource with extra parameters, it fails" do
      expect {
        run_chef("-o normal::declare_resource")
      }.to raise_error(Mixlib::ShellOut::ShellCommandFailed)
    end
  end
end
