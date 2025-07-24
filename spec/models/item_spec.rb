require 'rails_helper'

RSpec.describe Item, type: :model do
  let!(:user) { create(:user) }
  let!(:house) { create(:house) }
  let!(:room) { create(:room, house: house) }
  let!(:box) { create(:box, house: house) }

  subject {
      described_class.new(
        name: 'Screwdriver',
        notes: 'flathead',
        user: user,
        house: house,
        room: room,
        box: box
      )
    }

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:house) }
    it { should belong_to(:room) }
    it { should belong_to(:box).optional(true) }
    it { should have_and_belong_to_many(:tags) }
    it { should have_one_attached(:image) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:notes).is_at_most(255) }
  end

  context "in a box that's in a different house to the item" do
    let!(:house) { create(:house) }
    let!(:different_house) { create(:house) }
    let!(:box_in_different_house) { create(:box, house: different_house) }
    let!(:item) { build(:item, box: box_in_different_house, house: house)}

    it 'is invalid' do
      expect(item).to be_invalid
    end
  end

  context "in a box that's in the same house as the item" do
    let!(:house) { create(:house) }
    let!(:box) { create(:box, house: house) }
    let!(:item) { build(:item, box: box, house: house)}

    it 'is valid' do
      expect(item).to be_valid
    end
  end

  context 'the room is in a different house to the item' do
    let!(:house) { create(:house) }
    let!(:room) { create(:room, house: house) }
    let!(:different_house) { create(:house) }
    let!(:room_in_different_house) { create(:room, house: different_house) }
    let!(:item) { build(:item, room: room_in_different_house, house: house)}

    it "is invalid" do
      expect(item).to be_invalid
    end
  end


  context 'the room is in the same house as the item' do
    let!(:house) { create(:house) }
    let!(:room) { create(:room, house: house) }
    let!(:item) { build(:item, room: room, house: house)}

    it 'is valid' do
      expect(item).to be_valid
    end
  end

  describe ".search" do
    let!(:item) { create(
                    :item,
                    name: "Screwdriver",
                    notes: "flathead",
                    box: box,
                    room: room,
                    house: house
                  )
                }
    let!(:tag) { create(:tag, name: "tool") }

    before { item.tags << tag }

    it "returns items matching name" do
      expect(Item.search("screw")).to include(item)
    end

    it "returns items matching notes" do
      expect(Item.search("flat")).to include(item)
    end

    it "returns items matching tag name" do
      expect(Item.search("tool")).to include(item)
    end

    it "returns nothing for blank input" do
      expect(Item.search(nil)).to be_empty
    end
  end

  context 'has an image' do
    before do
      subject.image.attach(io: File.open(Rails.root.join("spec/fixtures/screwdriver.jpg")), filename: "image.jpg")
    end

    it "purges image on save if asked" do
      subject.remove_image = "1"
      subject.save!

      expect(subject.image).not_to be_attached
    end
  end
end
