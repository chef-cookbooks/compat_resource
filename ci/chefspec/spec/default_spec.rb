#
# Cookbook:: sk_test
# Spec:: default
#
# Copyright:: 2016, The Authors, All Rights Reserved.

require 'spec_helper'

describe 'test::default' do
  context 'basic flame tests' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '16.04')
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'has a resource in the run' do
      expect(chef_run).to create_file('/tmp/foo.xyz')
    end
  end
end
