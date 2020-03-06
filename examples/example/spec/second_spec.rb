require 'spec_helper'

describe 'second' do

  it "works" do
    browser.navigate.to page 1
    element = find(data: "good div")
    browser.execute_script("arguments[0].setAttribute('id', 'lost')", element)
    expect(find(data: "good div").text).to eq "Text"
  end

end
