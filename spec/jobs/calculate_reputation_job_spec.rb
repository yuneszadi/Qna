require 'spec_helper'

RSpec.describe CalculateReputationJob, type: :job do
  let(:user) { create(:user) }
  let(:question) { create(:question, user: user) } 

  it 'calculate and update user reputation' do
    expect(Reputation).to receive(:calculate).with(question).and_return(5)
    expect { CalculateReputationJob.perform_now(question) }.to change(user, :reputation).by(5)
  end
end
