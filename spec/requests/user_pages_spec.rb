# frozen_string_literal: true

require 'spec_helper'

describe 'User pages' do
  context 'for guest user' do
    it 'shows form for create new user' do
      visit new_user_path
      expect(page).to have_content 'New user registration'
    end

    describe 'Fail to create new user' do
      before do
        visit new_user_path
      end

      it 'renders form and error message' do
        expect do
          click_button 'Register'
          expect(page).to have_content 'New user registration'
          expect(page).to have_content 'User name cannot be blank'
        end.to_not change(User, :count)
      end
    end
  end
end
