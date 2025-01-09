require 'rails_helper'

RSpec.describe User, type: :model do
  describe "is valid" do
    it "is valid when email is valid" do
      user = build(:user)
      expect(user).to be_valid
    end
  end

  describe "is invalid" do
    it "when without pass" do
      user = build(:user, :without_password)
      expect(user).to be_invalid
    end

    it "when pass is minus than 8" do
      user = build(:user, :with_short_password)
      expect(user).to be_invalid
    end

    it "when pass and confirm pass are different" do
      user = build(:user, :with_mismatched_password)
      expect(user).to be_invalid
    end

    it "when pass contains spaces" do
      user = build(:user, :with_spaced_pass)
      expect(user).to be_invalid
    end

    it "when pass contains invalid chars" do
      user = build(:user, :with_invalid_pass_chars)
      expect(user.password_does_not_contain_invalid_chars).to be_truthy
    end
  end

  describe "returns" do
    it "false when password is not present" do
      user = build(:user, :without_password)
      expect(user.password_present?).to be_falsey
    end

    it "true when password is present" do
      user = build(:user)
      expect(user.password_present?).to be_truthy
    end
  end

  describe "About relations" do
    it "is valid if User creating a commission after his create" do
      user = create(:user)

      expect {
        user.generate_commission
      }.to change { Commission.all.count }.by(1)

      expect(user.commission).to be_present
    end
  end
end
