# frozen_string_literal: true

require 'spec_helper'

describe 'prometheus::server::service' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) { { 'version' => '2.27.1', 'data_dir' => '/data' } }

      it { is_expected.to compile }
    end
  end
end
