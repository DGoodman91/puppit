# frozen_string_literal: true

require 'spec_helper'

describe 'prometheus::exporter::node' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) { { 'version' => '1.1.2', 'prometheus_host' => '127.0.0.1' } }

      it { is_expected.to compile }
    end
  end
end
