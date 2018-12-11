require 'rails_helper'

RSpec.describe Ability, type: :model do

  subject(:ability) { Ability.new(user)}

  describe 'for guest' do
    let(:user) { nil }

    it { should be_able_to :read, :all }
    it { should_not be_able_to :manage, :all }
  end

  describe 'for admin' do
    let(:user) { create(:user, admin: true) }

    it { should be_able_to :manage, :all }
  end

  describe 'for user' do
    let(:user) { create(:user, admin: false) }
    let(:other) { create(:user, admin: false) }
    let(:question) { create(:question, user: user) }
    let(:question_of_other_user) { create(:question, user: other) }
    let!(:vote) { create(:vote, votable: question_of_other_user, user: user) }

    describe 'base' do
      it { should_not be_able_to :manage, :all }
      it { should be_able_to :read, :all }
    end

    describe 'create' do
      it { should be_able_to :create, Question }
      it { should be_able_to :create, Answer }
      it { should be_able_to :create, Subscription }
    end

    describe 'update' do
      it { should be_able_to :update, create(:question, user: user), user: user }
      it { should_not be_able_to :update, create(:question, user: other), user: user }

      it { should be_able_to :update, create(:answer, user: user), user: user }
      it { should_not be_able_to :update, create(:answer, user: other), user: user }
    end

    describe 'destroy' do
      it { should be_able_to :destroy, create(:question, user: user), user: user }
      it { should_not be_able_to :destroy, create(:question, user: other), user: user }

      it { should be_able_to :destroy, create(:answer, user: user), user: user }
      it { should_not be_able_to :destroy, create(:answer, user: other), user: user }

      it { should be_able_to :destroy, create(:attachment, attachable: question), user: user }
      it { should_not be_able_to :destroy, create(:attachment, attachable: question_of_other_user), user: user }

      it { should be_able_to :destroy, create(:subscription, user: user), user: user }
      it { should_not be_able_to :destroy, create(:subscription, user: other), user: user }
    end

    describe 'voted' do
      context 'for author' do
        it { should_not be_able_to :like, create(:answer, user: user), user: user }
        it { should_not be_able_to :dislike, create(:answer, user: user), user: user }
      end

      context 'for non-author' do
        it { should be_able_to :like, create(:question, user: other), user: user }
        it { should be_able_to :dislike, create(:question, user: other), user: user }
      end
    end

    describe 'commented' do
      it { should be_able_to :create, Comment }
    end
  end
end
