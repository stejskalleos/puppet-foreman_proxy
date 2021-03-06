require 'spec_helper'

describe 'foreman_proxy::plugin::pulp' do
  on_plugin_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:pre_condition) { 'include foreman_proxy' }
      let(:etc_dir) { '/etc' }

      describe 'with default settings' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_foreman_proxy__plugin('pulp') }

        it 'should configure pulp.yml' do
          is_expected.to contain_file("#{etc_dir}/foreman-proxy/settings.d/pulp.yml")
            .with_ensure('file')
            .with_owner('root')
            .with_group('foreman-proxy')

          verify_exact_contents(catalogue, "#{etc_dir}/foreman-proxy/settings.d/pulp.yml", [
                                  '---',
                                  ':enabled: https',
                                  ":pulp_url: https://#{facts[:fqdn]}/pulp",
                                  ':pulp_dir: /var/lib/pulp',
                                  ':pulp_content_dir: /var/lib/pulp/content',
                                  ':puppet_content_dir: /etc/puppetlabs/code/environments',
                                  ':mongodb_dir: /var/lib/mongodb'
                                ])
        end

        it 'should configure pulpnode.yml' do
          is_expected.to contain_file("#{etc_dir}/foreman-proxy/settings.d/pulpnode.yml")
            .with_ensure('file')
            .with_owner('root')
            .with_group('foreman-proxy')

          verify_exact_contents(catalogue, "#{etc_dir}/foreman-proxy/settings.d/pulpnode.yml", [
                                  '---',
                                  ':enabled: false',
                                  ":pulp_url: https://#{facts[:fqdn]}/pulp",
                                  ':pulp_dir: /var/lib/pulp',
                                  ':pulp_content_dir: /var/lib/pulp/content',
                                  ':puppet_content_dir: /etc/puppetlabs/code/environments',
                                  ':mongodb_dir: /var/lib/mongodb'
                                ])
        end

        it 'should configure pulpcore.yml' do
          is_expected.to contain_file("#{etc_dir}/foreman-proxy/settings.d/pulpcore.yml")
            .with_ensure('file')
            .with_owner('root')
            .with_group('foreman-proxy')

          verify_exact_contents(catalogue, "#{etc_dir}/foreman-proxy/settings.d/pulpcore.yml", [
                                  '---',
                                  ':enabled: false',
                                  ":pulp_url: https://#{facts[:fqdn]}",
                                  ":content_app_url: https://#{facts[:fqdn]}/pulp/content",
                                  ':mirror: false'
                                ])
        end

        it 'should remove pulp3.yml' do
          is_expected.to contain_file("#{etc_dir}/foreman-proxy/settings.d/pulp3.yml")
            .with_ensure('absent')
	end
      end

      describe 'with overrides' do
        let :params do
          {
            pulpnode_enabled: true,
            pulpcore_enabled: true,
            pulpcore_mirror: true,
            pulpcore_api_url: 'https://pulpcore.example.com',
            pulpcore_content_url: 'https://pulpcore.example.com/pulp/content',
            pulp_url: 'https://pulp.example.com',
            pulp_dir: '/tmp/pulp',
            pulp_content_dir: '/tmp/content',
            puppet_content_dir: '/tmp/puppet',
            mongodb_dir: '/tmp/mongodb',
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_foreman_proxy__plugin('pulp') }

        it 'should configure pulp.yml' do
          verify_exact_contents(catalogue, "#{etc_dir}/foreman-proxy/settings.d/pulp.yml", [
                                  '---',
                                  ':enabled: https',
                                  ':pulp_url: https://pulp.example.com',
                                  ':pulp_dir: /tmp/pulp',
                                  ':pulp_content_dir: /tmp/content',
                                  ':puppet_content_dir: /tmp/puppet',
                                  ':mongodb_dir: /tmp/mongodb'
                                ])
        end

        it 'should configure pulpnode.yml' do
          verify_exact_contents(catalogue, "#{etc_dir}/foreman-proxy/settings.d/pulpnode.yml", [
                                  '---',
                                  ':enabled: https',
                                  ':pulp_url: https://pulp.example.com',
                                  ':pulp_dir: /tmp/pulp',
                                  ':pulp_content_dir: /tmp/content',
                                  ':puppet_content_dir: /tmp/puppet',
                                  ':mongodb_dir: /tmp/mongodb'
                                ])
        end

        it 'should configure pulpcore.yml' do
          verify_exact_contents(catalogue, "#{etc_dir}/foreman-proxy/settings.d/pulpcore.yml", [
                                  '---',
                                  ':enabled: https',
                                  ':pulp_url: https://pulpcore.example.com',
                                  ":content_app_url: https://pulpcore.example.com/pulp/content",
                                  ':mirror: true'
                                ])
        end
      end
    end
  end
end
