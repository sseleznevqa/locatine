# Locatine

Element location tool based on Watir.

You are asking Locatine to find element for you.

It is asking you what element do you mean.

It is remembering your answer and collecting information about selected element.

After that it is finding element by itself.

If your element will be lost (due to id change for example) locatine will locate the most similar element.

That's it.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'locatine'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install locatine

## Usage

1. Be sure that you have [Chrome browser](https://www.google.com/chrome/browser/desktop/) installed. It should work with any browser but something you can do in Chrome only
2. Write the code
```ruby
require 'locatine'
s = Locatine::Search.new
s.browser.goto("yourpage.com.com")
s.find(name: "element", scope: "Main").click
```
3. Run it in terminal with parameter LEARN=1 approximately like:

    $ LEARN=1 ruby path_to_your_test.rb

4. It will open the browser and transfer you to the yourpage.com.com
5. Select element to represent *element* in the *Main* scope (you can click on it or select it in devtools)
6. Click Locatine application icon at the browser panel
7. And confirm the selection

![Steps 4-5-6](readme/567.png)

8. Now you can run the test without LEARN parameter and it will work.

## Locatine::Search options

```ruby
Locatine::Search.new(json: "./Locatine_files/default.json",
                     depth: 3,
                     browser: nil,
                     learn: ENV['LEARN'].nil? ? false : true,
                     stability_limit: 10,
                     scope: "Default",
                     tolerance: 33)
```
**json** the file where data collected about elements will be stored

**depth** shows how many info will be stored about each element
- 0 = everything about the element
- 1 = everything about the element and the parent of it
- 2 = everything about the element and the parent of it + one more parent

**browser** if not provided new Watir::Browser will be started. Do not provide browser if you are going to use learn mode

**learn** mode is used to train locatine to search your elements. By default is false. But if you are starting your test like:

    $ LEARN=true ruby path_to_your_test.rb

it will turn learn to true by default.

**scope** is setting that is representing default scope (group) where elements will be stored by default

**stability_limit** shows how much times attribute should be present to be considered a trusted one

You can get or set these values on fly. Like:
```ruby
s = Locatine.Search.new(learn: true)
s.learn #=> true
s.learn = false
```

**tolerance** If metrics of element (including attributes, text, css values and tags) were changed Locatine will find and suggest the most similar one. Tolerance is showing how resembling in per cent new element should be to old one. If 100 - locatine will find nothing. If 50 it is enough for element to have only half of parameters of old element we are looking for to be returned. If 0 - at least something is found - it goes. Default if 33.

## Locatine::Search find options

```ruby
s.find(name: "some name",
       scope: "Default",
       exact: false,
       locator: {},
       vars: {},
       look_in: nil,
       iframe: nil,
       return_locator: false,
       collection: false,
       tolerance: nil)
```
**name** should be always provided. Name of element to look for. Must be uniq one per scope. Ideally name should be made of 2-4 words separated by spaces describing its nature ("pay bill button", "search input", etc.) It will help Locatine to find them.

**scope** group of elements. Must be uniq per file. This is to help to store elements with same names from different pages in one file

**exact** unless it is true locatine will always try to find lost element using all the power it has. Use exact: true if you want to assert that your element is not present. In that case locatine will return nil if nothing was found.

**locator** you may provide your own locator to use. Same syntax as in Watir:
```ruby
find(name: "element with custom locator", locator: {xpath: "//custom"})
```

**vars** are used to pass dynamic attributes.
For example you have created an account on your site with
```ruby
name == "stablePart_qljcrt24jh"
```
where
```ruby
random_string == "qljcrt24jh"
```
was generated by random. Now you need to find the element with this part on the page. You can do
```ruby
random_string #=> "qljcrt24jh"
find(name: "account name", vars: {text: random_string})
```
Next time when your test will generate another random_string it will use new value. It works with attributes (use names of attributes for it) as well.
And if you do not like it you can do:
```ruby
random_string #=> "qljcrt24jh"
find(name: "account name", locator:{text: "stablePart_#{random_string}")
```

**look_in** is for method name taken from Watir::Browser item. It should be a method that returns collection of elements like (text_fields, divs, links, etc.). If this option is stated locatine will look for your element only among elements of that kind. Be careful with it in a learn mode. If your look_in setting and real element are from different types. Locatine will be unable to find it.

**iframe** that is in order to find element inside of an iframe

**return_locator** true is returning the locator of the element instead of element. Use with care if attributes of your elements are dynamic and you are in a learning mode.

**collection** if true array of elements will be returned. If false only the one element will be returned.

**tolerance** You can state custom tolerance for the element.

## Other ways to use find

If the scope is set and you do not want to provide any additional options you can do:
```ruby
s = Locatine.Search.new
s.find("just name of element")
```
Also you can do:
```ruby
s = Locatine.Search.new
s.browser.button(s.lctr("name of the button"))
# or
s.browser.button(s.lctr(name: "name of the button", scope: "Some form"))
# or
s.browser.button(s.lctr("name of the button", scope: "Some form"))
```
That may be helpful in case of migration from plain watir to watir + locatine

If you want to find collection of elements you can use:
```ruby
s = Locatine.Search.new
s.collect("group of elements") # Will return an array
```


## What else?

Version of Locatine is 0.01439 only. It means so far this is an early alfa. You can use it in a real project if you are really risky person.
