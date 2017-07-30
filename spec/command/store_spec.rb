require File.expand_path('../../spec_helper', __FILE__)

module Pod
  describe Command::Store do
    describe 'CLAide' do
      it 'registers it self' do
        Command.parse(%w{ store }).should.be.instance_of Command::Store
      end
    end
  end
end

