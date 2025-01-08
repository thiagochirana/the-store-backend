require 'rails_helper'

RSpec.describe User, type: :model do
  describe "associações" do
    it { should have_one(:commission) }
    it { should have_many(:salespersons) }
    it { should belong_to(:shopowner) }
    it { should have_many(:payments) }
  end

  describe "validações" do
    subject { create(:user) }

    it { should validate_presence_of(:password).on(:create) }
    it { should validate_length_of(:password).is_at_least(8).on(:create) }

    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should allow_value("email@example.com").for(:email) }
    it { should_not allow_value("invalid_email").for(:email) }

    it "normaliza o email removendo espaços e aplicando letras minúsculas" do
      user = create(:user, email: "   TEST@EXAMPLE.COM   ")
      expect(user.email).to eq("test@example.com")
    end

    context "validação de senha" do
      it "não permite espaços na senha" do
        user = build(:user, password: "senha com espaço")
        expect(user).to be_invalid
        expect(user.errors[:password]).to include("não pode conter espaços")
      end

      it "não permite caracteres especiais como acentos ou ç" do
        user = build(:user, password: "senhaçãõé")
        expect(user).to be_invalid
        expect(user.errors[:password]).to include("não pode conter acentos ou caracteres especiais como Ç")
      end
    end
  end

  describe "callbacks" do
    it "cria uma comissão após criar o usuário" do
      user = create(:user)
      expect(user.commission).to be_present
    end
  end

  describe "métodos privados" do
    let(:user) { create(:user) }

    describe "#generate_commission" do
      it "gera uma comissão para o usuário após ser criado" do
        commission = user.commission
        expect(commission).to be_present
        expect(commission.user).to eq(user)
      end
    end
  end
end
