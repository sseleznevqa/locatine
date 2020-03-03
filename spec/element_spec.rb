# frozen_string_literal: true

require 'spec_helper'
describe 'element' do
  it 'fails to init without data' do
    expect { Locatine::Element.new('123', nil) }.to raise_error ArgumentError
  end

  it 'inits sometimes' do
    element = Locatine::Element.new('123', '1213')
    expect(element.answer).to eq '1213'
  end
end
