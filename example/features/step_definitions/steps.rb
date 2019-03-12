Given("I visit {string}") do |path|
  @browser.goto @base_url + path
  set_page
end

When(/^I (.*) the ([^"]*)$/) do |action, name|
  @search.find(name: name).send(action.to_sym)
  set_page
end

When(/^I (.*) the (.*) with "(.*)"$/) do |action, name, value|
  @search.find(name: name).send(action.to_sym, value)
  set_page
end

Then(/^the (\d\S*).. element of (.*) collection should include "(.*)"$/) do |i, name, string|
  expect(@search.collect(name: name)[i.to_i].text).to include(string)
end

Then("I look into {string} component") do |component|
  @component = component
  set_page
end

Then("I look on the page") do |component|
  @component = nil
  set_page
end
