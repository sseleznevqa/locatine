# Version 0.00463
First release. Locatine can
- store information about element (elements) to json
- find element\\elements by stored information
- find element\\elements even if some attributes are unstable
- find element\\elements even if some stable attributes were changed
- define element through user selection in browser
- define element through user selection in devtools
- Suggest most relevant element by name
- work within iframe
- use normal watir locators
- return locators suitable for watir (selenium, capybara, etc.)
- launch browser
- do couple of other pretty things

# Version 0.00506
- Some comments are fixed
- Guessing for too short name is turned off
- Algorithms are fixed so their performance is highly increased

# Version 0.00552
- Minor fixes in README.md
- Fixed giant bug with titles and iframes
- Fixed bug with getting stable attributes when there are no attributes of element at all
- Fixed bug with Clear selection

# Version 0.00695
- More titles for application
- Fixed bug with no turning on waiting from ruby
- First tests are added (Instance creation)
- Minor fixes in README.md

# Version 0.0092
- Fixed critical bug with the gemspec file!
- Now locatine returning nil if there is exact and nothing was found
- Now it is possible to determine type of output Array\\Collection or single element
- Bug with lctr is fixed

# Version 0.01084
- E2E tests are added (covering main user cases)
- Fixed bug with locatine was finding itself
- Fixed bug with non-working lctr

# Version 0.01100
- Information about "collect" is added to readme
- Full rubocoping
- Many little fixes and tweaks

# Version 0.01135
- Search for lost element is improved. Now it is not relay on stability of a DOM tree structure.
- Tolerance added in order to ensure that locatine is not too loyal.
- Now exact option will be ignored if element is not stable still (was found once only)

# Version 0.01215
- Forgotten feature with changing data file on fly is implemented
- Test with vars added to E2E
- E2E test for lctr is added

# Version 0.01300
- Little example added
- Little iframe fix
- Fixed annoying bug with loosing element information on transfer from app to ruby
- Fixed bug with loosing element that's changing after click (or constantly)

# Version 0.01309
- Little bug about selecting element with devtools is fixed
- Searching for element now is slower but now we are using css values too

# Version 0.01439
- Now we are storing x,y and size and using it in search (well, not often)
- Fixed bug with quotation marks in attribute and text
- Fixed bug with page reloading with devtools opened in the learn mode
- visual_search option is added in order to turn off css and position search by default (since css seems to be much less stable than html)

# Version 0.01454
- Tests are improved
- Fixed bug with look_in
- Deleted error raising which is already raised by Watir

# Version 0.01546
- Fixed bug with tolerance in find
- Changed logic of tolerance
- Changed logic of exact
- Changed logic of determining stability of the element
- Readme slightly rewrited
- Tests are added

# Version 0.01659
- Little more sense for JS code
- Some new tests
- Fixed bug with confirm when nothing selected

# Version 0.01811
- Changed structure of the project
- Better logs
- Little dictionary module Saying is here

# Version 0.01822
- Locatine will warn if you will try to add element that was already added with other name

# Version 0.01839
- Fixed bug with guessing when elements are not stale
- Fixed little typo
- Scope introduced
- In some conditions element can have no predefined name now
- If there is no name provided Locatine will suggest some
- User can change the name of element while defining.
- Fixed an invisible bug with decline
- Fixed a bug with message 'element was already defined' appearing without a reason
- Abort button added. It will stop the element selection forcedly.
- Fixed bug with loosing element on the page when it has no content
- We will not highlight more than 50 elements. That's too long
- README is updated

# Version 0.01971
- Couple of Scope methods are introduced. Now scope is useful.

# Version 0.02007
- Micro refactoring
- You can confirm element selection with ENTER now (Well it may confirm also a form... so...)
- Titles now flashing on the main selecting screen. So you may not really look into app control panel, sometimes

# Version 0.02058
- More shortcuts for find
- exact is splitted into two separate flags - (no_fail, and exact)
- Now in the learn mode redefining is causing dropping of all the previously stored data.

# Version 0.02247
- Showstopper bug is fixed. It was impossible to select more than 50 elements!
- Now we can process twins elements properly
- Warning about negative expressions is added.
- Fixed bug with loosing additional element data
- chromedriver-helper is switched to webdrivers. Ty and bye flavorjones. Hello titusfortner!

# Version 0.02327
- Trusted//untrusted feature added.

# Version 0.02432
- Locatine Daemon is introduced!

# Version 0.02535
- Fixed bug with installation
- Autolearn (on\off) feature added

# Version 0.02539
- Refactoring
- Simplified logic for searching by coordinates.
- Changed the way of finding lost elements in order to speed it up.
- Changed the way of guessing element while learn (It is faster and more simple)

# Version 0.02542
- Fixed bug with app loosing context after page reloading or on an empty page.
- Some lost debug is removed
- Fixed bug with detecting unstable page

# Version 0.02637
- Fixed bug with unnecessary screen title appearing after defining of an element
- Iframe inside iframe case reviewed
- Little CSS tweak
- Fixed bug with quotes in attribute value causing element loss
- Little improve for xpath creation algorithm
