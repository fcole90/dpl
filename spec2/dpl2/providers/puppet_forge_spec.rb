describe Dpl::Providers::PuppetForge do
  let(:args) { |e| %w(--user user --password pass) + args_from_description(e) }

  chdir 'tmp'
  file 'metadata.json', JSON.dump(name: 'author-module')

  let(:face)  { double(build: nil) }
  let(:forge) { double(username: 'user', push!: nil) }

  before { allow(Blacksmith::Forge).to receive(:new).and_return(forge) }
  before { allow(Puppet::Face).to receive(:[]).and_return(face) }

  before { subject.run }

  describe 'by default' do
    it { should have_run '[info] Uploading to Puppet Forge user/module' }
    it { expect(Blacksmith::Forge).to have_received(:new).with('user', 'pass', 'https://forgeapi.puppetlabs.com/') }
    it { expect(forge).to have_received :push! }
  end
end

