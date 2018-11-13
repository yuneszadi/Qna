require_relative 'acceptance_helper'

feature 'Add files to answer', %q{
  In oreder to illustrate my answer
  As an answer's author
  i'd like to be able to attach files
} do

  given(:user) { create(:user) }
  given(:question) { create(:question) }

  background do
    sign_in(user)
    visit question_path(question)
  end

  scenario 'User adds file to answer', js: true do
      fill_in 'Body' , with: 'Answer body'
      attach_file 'File', "#{Rails.root}/spec/spec_helper.rb"
      click_on 'Create answer'
      expect(page).to have_link 'spec_helper.rb', href: '/uploads/attachment/file/1/spec_helper.rb'
    end
end
