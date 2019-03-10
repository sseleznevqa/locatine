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
