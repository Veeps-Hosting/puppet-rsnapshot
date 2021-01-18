require 'spec_helper'
describe 'rsnapshot' do
  context 'with defaults for all parameters' do
    it { is_expected.to contain_class('rsnapshot') }
  end
end
