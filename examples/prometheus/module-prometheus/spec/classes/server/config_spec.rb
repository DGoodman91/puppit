# frozen_string_literal: true

require 'spec_helper'

describe 'prometheus::server::config' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:pre_condition) { 'class { "prometheus::server::service": version => "2.27.1", data_dir => "/data" }' }
      let(:params) { { 'version' => '2.27.1', 'static_node_targets' => ['127.0.0.1:9100'] } }

      it { is_expected.to compile }
    end
  end
end
