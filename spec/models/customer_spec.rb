require 'rails_helper'

describe Customer, 'バリデーション' do
  let(:customer) { FactoryGirl.build(:customer) }

  example '妥当なオブジェクト' do
    expect(customer).to be_valid
  end

  %w{family_name given_name family_name_kana given_name_kana}.each do |column_name|
    example "#{column_name}は空であってはならない" do
      customer[column_name] = ''
      expect(customer).not_to be_valid
      expect(customer.errors[column_name]).to be_present
    end

    example "#{column_name}は40文字以内" do
      customer[column_name] = 'ア' * 41
      expect(customer).not_to be_valid
      expect(customer.errors[column_name]).to be_present
    end

    example "#{column_name}に含まれる半角カナは全角カナに交換して受け入れる" do
      customer[column_name] = 'ｱｲｳ'
      expect(customer).to be_valid
      expect(customer[column_name]).to eq('アイウ')
    end
  end

  %w{family_name given_name}.each do |column_name|
    example "#{column_name}は漢字、ひらがな、カタカナを含んでもよい" do
      customer[column_name] = '亜あアーン'
      expect(customer).to be_valid
    end

    example "#{column_name}は漢字、ひらがな、カタカナ以外の文字を含まない" do
      %w(A 1 @).each do |value|
        customer[column_name] = value
        expect(customer).not_to be_valid
        expect(customer[column_name]).to be_present
      end
    end
  end

  %w(family_name_kana given_name_kana).each do |column_name|
    example "#{column_name}はカタカナを含んでも良い" do
      customer[column_name] = 'アイウ'
      expect(customer).to be_valid
    end

    example "#{column_name}はカタカナ以外の文字を含まない" do
      %w(亜 A 1 @).each do |value|
        customer[column_name] = value
        expect(customer).not_to be_valid
        expect(customer.errors[column_name]).to be_present
      end
    end

    example "#{column_name}に含まれるひらがなはカタカナに交換して受け入れる" do
      customer[column_name] = 'あいう'
      expect(customer).to be_valid
      expect(customer[column_name]).to eq('アイウ')
    end
  end
end

describe Customer, '.authenticate' do
  let(:customer) {create(:customer, username: 'taro', password: 'correct_password')}

  example 'ユーザー名とパスワードに該当するCustomerオブジェクトを返す' do
    result = Customer.authenticate(customer.username, 'correct_password')
    expect(result).to eq(customer)
  end

  example 'パスワードが一致しない場合nilを返す' do
    result = Customer.authenticate(customer.username, 'wrong_password')
    expect(result).to be_nil
  end

  example '該当するユーザー名が存在しない場合はnilを返す' do
    result = Customer.authenticate('hanako', 'any_string')
    expect(result).to be_nil
  end
end
