require 'webmock/rspec'
require 'dpl2'
require 'support'

RSpec.configure do |c|
  c.include Support::Cl
  c.include Support::Ctx
  c.include Support::Env
  c.include Support::File
  c.include Support::Fixtures
  c.include Support::Matchers
  c.include Support::MemFs, memfs: true
end
