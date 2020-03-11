# Locatine

Locatine is a proxy between your code and selenium.

It remembers element when you are finding it via selenium.

It stores the findings to the json file for the future use.

On the next search if element is lost Locatine will try to find it anyway using previously collected information.

So your locator will be a little bit more stable than before.

That's it.

## Stage of development:

Version of Locatine is **0.03050**. The 4th version since rewriting. 5-15 next versions is dedicated to bug fixing, tweaking.

## Attention

This version of Locatine is not compatible to previous.

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

1. Be sure that you have [Chrome browser](https://www.google.com/chrome/browser/desktop/) installed.
2. Be sure that you have [chromedriver](https://chromedriver.chromium.org/) installed.
3. Write the code (using your language - ruby is an example)

```ruby
driver = Selenium::WebDriver.for :remote, url: "http://localhost:7733/wd/hub", desired_capabilities: :chrome
driver.navigate.to("yourpage.com.com")
driver.find_element(xpath: "//*[@id = 'element']")
driver.quit
```

4. Run the locatine daemon

```
    $ SELENIUM=http://localhost:4444 locatine-daemon.rb --port=7733
```

5. SELENIUM - is for url where selenium hub is started, port is the port for your code to connect. 4444 and 7733 are defaults.
6. Run your code
7. Data of element will be stored to ./default.json file.
8. Now if id of your element is changed on the page Locatine will show a warning and gonna try to retrieve it.
9. See [example](https://github.com/sseleznevqa/locatine/tree/master/examples) to see how it really works.

## Session

Each time when you initializing new selenium session, locatine session is created as well.

It is used to store default options for search.

There are two ways to set options of the session:

The most simple is to send it via desired capabilities like (ruby example again)

```ruby
caps = Selenium::WebDriver::Remote::Capabilities.
                 chrome('locatine' => {'json' => '/your/path/elements.json'})
driver = Selenium::WebDriver.
   for :remote, url: "http://localhost:7733/wd/hub", desired_capabilities: caps
```

This way is recommended because of the simplicity.

Another way is to set options after the session was created by making [POST request to '/locatine/session/%session_id%'](https://github.com/sseleznevqa/locatine#post-to-wdhubsession)

## Settings to pass

### json

Provide a string here.

Default is 'locatine-working-dir/locatine_files/default.json'

**json** is the path of the file that will be used to store data collected about elements by locatine-daemon.

It is recommended to use a different json for every test (or test group) in order to have lots of small and easily readable files and not the giant one.

**NOTE! Only unix filesystems are supported so far.**

### depth

Provide a non negative integer here.

Default is 3

**depth** value shows how deeply locatine will research the element.

0 - means that only the retrieved element will be remembered.

```html
<div id="element to find"></div>
```

1 - means that the retrieved element and its ancestor will be examined:

```html
<div id="ancestor">
  <div id="element to find"></div>
</div>
```

2 - means that two ancestors will be remembered.

And so on and so forth.

The higher depth the more easily locatine-daemon will find the element including the case when the element is lost (attributes are changed).

On the other side large depth is making internal locator more unstable since it is requires stability of all the ancestors as well.

Read more about [finding elements](https://github.com/sseleznevqa/locatine#finding-elements)

**NOTE! Taking additional information (larger depth) costs an additional time while retrieving element and when looking for the lost one**

### trusted

Provide an array of strings here.

Default is []

Usually if some attribute or tag or text is changing locatine is marking it as untrusted data and not using it in search till it appears enough times to be considered stable again.

But locatine will always use for search for element something that is listed as trusted here.

Use attribute name (like ['id']) for id attribute, use ['text'] for text and ['tag'] to trust the tag of element.

**NOTE! ['text'] will affect both - text of element and attribute of element that is named 'text'**

### untrusted

Provide an array of strings here.

Default is []

Working completely opposite to [trusted](https://github.com/sseleznevqa/locatine#trusted)

Locatine will never consider reliable attributes or text or tag if it is listed as untrusted. It will be never used to search elements.

Use attribute name (like ['id']) for id attribute, use ['text'] for text and ['tag'] to untrust the tag of element.

**NOTE! ['text'] will affect both - text of element and attribute of element that is named 'text'**

### stability

Provide a positive integer here.

Default is 10

At first locatine trusts everything except [untrusted](https://github.com/sseleznevqa/locatine#untrusted). But sometimes attribute value, text or tag changes. In that case those new values will be not used in search anymore.

**stability** shows how much times new attribute or text or tag should be found without changes to be considered reliable to be used for search once again.

### tolerance

Provide an integer in a range from 0 to 100

Default is 50

If your element is changed locatine is trying to find it anyway. Tolerance shows how similar the new element should be to the ild one to be returned.

Example:

```html
<!--Old element-->
<div id="too" class="old one">element</div>
<!--New element-->
<div id="too" class="new one">element</div>
```

5 pieces of information will be collected about an old element (tag == div, id == too, class == old, class ==one, text == element)

4 parts are staying the same after changes. So similarity will be counted like (4*100/5 == 80)

Since similarity(80)>=100-tolerance(50) the new element will be returned.

But for the case:

```html
<!--Old element-->
<div id="too" class="old one">element</div>
<!--New element-->
<div id="lost" class="new two">element</div>
```

Similarity will be only 40 which is less than 100-50. It means that no element will be returned.

So default tolerance == 50 means that at least 50% of element data should be equal to stored data for element to be found.

Only data of the element itself is counted here.

**NOTE! 0 (zero tolerance) means that locatine will not even try to find the lost element. 100 tolerance is too opportunistic**

### timeout

Provide an positive integer here (up to 25 is recommended)

Default is 25

**timeout** shows the maximum amount of seconds locatine will try to find something.

Since default net timeout for most selenium implementations is 30 seconds, 25 is a good idea.

**NOTE! It's not an exact time. When timeout is reached it means for locatine that it is time to finish the party. But it cannot be finished instantly and the speed of the process may slightly vary.**

## Finding elements

All the requests that are retrieving elements are wrapped by locatine-daemon.

```ruby
caps = Selenium::WebDriver::Remote::Capabilities.chrome('locatine' =>
                                         {'json' => "#{Dir.pwd}/elements.json"})
driver = Selenium::WebDriver.for :remote,
                                 url: "http://localhost:7733/wd/hub",
                                 desired_capabilities: caps
# Page that has <div id='element' class='1 2 3'>Text</div>
driver.navigate.to page 1
# Getting element for the first ешьу
element = driver.find_element(xpath: "//*[@id='element']")
# We are changing id of the element
driver.execute_script("arguments[0].setAttribute('id', 'lost')", element)
# Element is gonna be found. Even with locator that is broken
expect(driver.find_element(xpath: "//*[@id='element']").text).to eq "Text"
driver.quit
```

When locatine sees some locator for the first time it is not only returning the element& It is collecting some info about it. As the result if locator will suddenly become broken locatine will make an attempt to find the element using the data collected.

### Magic comments

If the usual locator only is provided locatine will treat it like a name for element. But if you want you can force locatine to remember it by name defined by you.

Just add name at the end of xpath like ['*name*'] or like /\**name*\*/ after css selector. For example:

```ruby
element = driver.find_element(xpath: "//*[@id='element']['test element']")
element = driver.find_element(css: "#element/*test element*/")
```

**NOTE! Those locators are valid.  If you will switch back to selenium-webdriver it will work normally. The 'test element' text will be treated like a comment that is not affecting the locator body.**

Once defined with name it can be called without locator part at all:

```ruby
element = driver.find_element(xpath: "['test element']")
element = driver.find_element(css: "/*test element*/")
```

**NOTE! Locators above will work only with locatine!**

### Dynamic locators

Always add names to dynamic locators. For example if you have some account_id which is new for every test and goes to an id attribute do

```ruby
account_id #=> 1234567890
element = driver.find_element(xpath: "//*[@id='#{account_id}']['test element']")
element = driver.find_element(css: "##{account_id}/*test element*/")
```

**NOTE! If there will be no name for the element that is changing locator for each run locatine will treat it like a new element each time. That will lead to overcrowding of your json file**

### Zero tolerance shortcut

If you need to check that element exists or not most probably you do not want locatine to look for the similar one. You can set zero tolerance (return only 100% same element) by adding word 'exactly' to the name.

```ruby
element = driver.
              find_element(xpath: "//*[@id='element']['exactly test element']")
element = driver.find_element(css: "#element/*exactly test element*/")
```

**NOTE! Zero tolerance will be used for that particular search only. Other searches will use session values**

### Other ways to pass data to locatine

There is another way to pass data to locatine. You can provide a json string as a comment.

```ruby
require 'json' # That is to make everything a little bit simpler
params = {name: "test element", tolerance: 0}.to_json
#=> {\"name\":\"test element\",\"tolerance\":0}
element = driver.find_element(xpath: "//*[@id='element'][#{params}']")
element = driver.find_element(css: "#element/*#{params}*/")
```

**NOTE! Those requests will provide same results as previous because they have identical meaning**

Like that you can set for each search any custom options (except json)

For more information about possible options read [here](https://github.com/sseleznevqa/locatine#session)

Additionally you can provide a custom locator inside of the comment json string.

We are using 'json' library to make json string here.

```ruby
require 'json'
xpath_params = {name: "test element",
                tolerance: 0,
                locator: {using: "xpath", value: "//*[@id='element']"}}.to_json
css_params = {name: "test element",
              tolerance: 0,
              locator: {using: "css selector", value: "#element"}}.to_json
element = driver.find_element(xpath: "['#{xpath_params}']")
element = driver.find_element(css: "/*#{css_params}*/")
```

For more information about locators read about [locator strategies](https://www.w3.org/TR/webdriver/#locator-strategies)

### locatine locator strategy

Locatine also provides its own locator strategy == 'locatine'. In order to use it you need to inject it to the code of selenium-webdriver implementation.

See it's done for ruby [here](https://github.com/sseleznevqa/locatine/tree/master/spec/e2e_spec.rb#L5-L11)

When it's done you can use:

```ruby
require 'json'
xpath_params = {name: "test element",
                tolerance: 0,
                locator: {using: "xpath", value: "//*[@id='element']"}}.to_json
css_params = {name: "test element",
              tolerance: 0,
              locator: {using: "css selector", value: "#element"}}.to_json
element = driver.find_element(locatine: xpath_params)
element = driver.find_element(locatine: css_params)
# As well as
element = driver.find_element(locatine: "test element")
# And also
element = driver.find_element(locatine: "exactly test element")
```

### Locatine locators

In some cases you can even forget about classic locators

For example have element

```html
<input id="important" type="button" value="click me"></input>
```

Let's pretend that id == important is a uniq attribute for the page (it should be so). In that case you can do:

```ruby
element = driver.find_element(css: "/*important input*/")
```

Locatine will try to find it by those two words. If the id is really uniq it will return the desired element.

There is a [Locatine Name Helper chrome extension](https://chrome.google.com/webstore/detail/locatine-locator-helper/heeoaalghiamfjphdlieoblmodpcficg). This app is for creating good locatine locators (it is creating a pair - most uniq attribute value + tag for selected element, elements). Note that the app is an early draft. It's gonne be better with time.

**NOTE! Locatine locators case insensitive.**

**NOTE! Locatine does not count text while looking for element.**

**NOTE! Locatine tends to think that the last word of your locator is a tag**

## Locatine daemon API

When locatine-daemon is started it is reacting to several requests:
Almost all post data should be transfered as a valid json.

### GET to '/'

Redirect to this page.

### GET to '/locatine/stop'

Stops locatine-daemon

Returns

```
{"result": "dead"}
```

### POST to '/locatine/session/%session_id%'

Data to post (example):

```
"{\"json\":\"./daemon.json\"}"
```

That will force session with *%session_id%* number to read\write data using ./daemon.json file.

For more information about possible options read [here](https://github.com/sseleznevqa/locatine#session)

Response:

```
{ \"results\": {\"json\":\"./daemon.json\"} }
```

### POST to '/wd/hub/session'

Just the same rules as for [usual selenium session](https://www.w3.org/TR/webdriver/#new-session-0)

The only change that you can set locatine defaults via providing it in desired capabilities like:

```
{...
"desiredCapabilities": {
  ...
  "locatine": {"json": "./daemon.json"},
  ...
  }
}
```

That will force new session to read\write data using ./daemon.json file.

For more information about possible options read [here](https://github.com/sseleznevqa/locatine#session)

### POST to '/wd/hub/session/%session_id%/element'

That will try to return element using %session_id%.

Rules are the same as for [usual selenium call](https://www.w3.org/TR/webdriver/#find-element)

But you can provide magic locator comments for xpath and css. Or use 'locatine' element retrieve strategy.

More information is [here](https://github.com/sseleznevqa/locatine#finding-elements)

### POST to '/wd/hub/session/%session_id%/element/%element_id%/element'

That will try to return element under %element_id% using %session_id%.

Rules are the same as for [usual selenium call](https://www.w3.org/TR/webdriver/#find-element-from-element)

But you can provide magic locator comments for xpath and css. Or use 'locatine' element retrieve strategy.

More information is [here](https://github.com/sseleznevqa/locatine#finding-elements)

### POST to '/wd/hub/session/%session_id%/elements'

That will try to return element using %session_id%.

Rules are the same as for [usual selenium call](https://www.w3.org/TR/webdriver/#find-elements)

But you can provide magic locator comments for xpath and css. Or use 'locatine' element retrieve strategy.

More information is [here](https://github.com/sseleznevqa/locatine#finding-elements)

### POST to '/wd/hub/session/%session_id%/element/%element_id%/elements'

That will try to return element under %element_id% using %session_id%.

Rules are the same as for [usual selenium call](https://www.w3.org/TR/webdriver/#find-elements-from-element)

But you can provide magic locator comments for xpath and css. Or use 'locatine' element retrieve strategy.

More information is [here](https://github.com/sseleznevqa/locatine#finding-elements)

### Other calls to /wd/hub...

Any other call will be simply redirected to selenium webdriver hub.
