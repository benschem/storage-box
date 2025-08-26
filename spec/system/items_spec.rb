# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Items', type: :system do
  let!(:user) { create(:user) }
  let!(:house) { create(:house) }
  let!(:items) { create_list(:item, 3, user: user, house: house) }

  before do
    house.users << user

    visit new_user_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log in'
  end

  context 'when user views all their items' do
    before do
      visit items_path
    end

    it 'displays a list of items' do
      aggregate_failures do
        expect(page).to have_content(/#{Regexp.escape(items.first.name)}/i)
        expect(page).to have_content(/#{Regexp.escape(items.second.name)}/i)
        expect(page).to have_content(/#{Regexp.escape(items.third.name)}/i)
      end
    end
  end

  context 'when user searches for a particular item' do
    before do
      create_list(:item, 20, user: user, house: house) # push original items off page - pagy limit is 20
      fill_in 'Search', with: items.first.name
    end

    it 'returns matching items' do
      expect(page).to have_content(/#{Regexp.escape(items.first.name)}/i)
    end
  end

  context 'when user views one item'
  context 'when user adds an item'
  context 'when user edits an item'
  context 'when user deletes an item'

  context 'when user filters by house'
  context 'when user filters by room'
  context 'when user filters by box'
  context 'when user filters by boxed'
  context 'when user filters by unboxed'
  context 'when user filters by tag'

  context 'when user sorts by date created'
  context 'when user sorts by date modified'
  context 'when user sorts by name'
  context 'when user sorts by asc'
  context 'when user sorts by desc'
end
