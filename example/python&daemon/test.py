#TODO::::
# We must to ensure that both sides using the same chromedriver. So locatine daemon should eat the path

from selenium import webdriver
import requests
import os
from selenium.webdriver.chrome.options import Options
import time
from webdriver_manager.chrome import ChromeDriverManager

# Taking app path
print("Trying to take app path...")
answer = requests.get(url = "http://localhost:7733/app")
app = answer.json()['app']
print(f"App path = {app}")

# Taking chromedriver path
print("Trying to take chromedriver path...")
answer = requests.get(url = "http://localhost:7733/chromedriver")
chrome_path = answer.json()['path']
print(f"Chromedriver path = {chrome_path}")

# Running the browser
print("Running browser")
chrome_options = Options()
chrome_options.add_argument(f"--load-extension={app}")
driver = webdriver.Chrome(chrome_path, options = chrome_options)
print("Browser is at large. I hope")

# Connecting to browser
print("Providing browser data to locatine daemon")
session = driver.session_id
data = {'browser': 'chrome',
        'session_id': session,
        'url': f"http://127.0.0.1:{driver.service.port}/"}
answer = requests.post(url = "http://localhost:7733/connect", json = data)
print(f"Daemon responded with = {answer.json()['result']}")

# Turning learn to true
print("Turning learn mode on")
data = {'learn': 'true'}
answer = requests.post(url = "http://localhost:7733/set", json = data)
print(f"Daemon responded with = {answer.json()['result']}")

# Going to google
driver.get("http://www.google.com")

# Taking our element
print("Getting element via daemon")
data = {'name': 'search q'}
answer = requests.post(url = "http://localhost:7733/lctr", json = data)
xpath = answer.json()['xpath']
print(f"XPATH is = {xpath}")

# Turning learn off
print("Turning learn mode off")
data = {'learn': 'false'}
answer = requests.post(url = "http://localhost:7733/set", json = data)
print(f"Daemon responded with = {answer.json()['result']}")

# Taking our element
print("Getting element via daemon")
data = {'name': 'search q'}
answer = requests.post(url = "http://localhost:7733/lctr", json = data)
xpath = answer.json()['xpath']
print(f"XPATH is = {xpath}")

elem = driver.find_element_by_xpath(xpath)
elem.clear()
elem.send_keys("Yahooo!")
time.sleep(30)
driver.close()
