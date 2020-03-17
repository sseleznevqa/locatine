from selenium import webdriver
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities
import os
import unittest
import time
import requests

class SimplePythonTest(unittest.TestCase):

    def setUp(self):
        os.system('locatine-daemon.rb &')
        time.sleep(10)
        self.driver = webdriver.Remote(
           command_executor='http://127.0.0.1:7733/wd/hub',
           desired_capabilities=DesiredCapabilities.CHROME)
        self.page = os.path.abspath("page1.html")

    def test_it_out(self):
        driver = self.driver
        driver.get("file://" + self.page)
        elem = driver.find_element_by_xpath("//div[@id='good']['good div']")
        elem = driver.find_element_by_xpath("['good div']")
        self.assertIn("Text", elem.text)
        driver.execute_script("arguments[0].setAttribute('id', 'bad')", elem)
        elem = driver.find_element_by_xpath("['good div']")
        self.assertIn("Text", elem.text)

    def tearDown(self):
        self.driver.close()
        requests.get(url = "http://localhost:7733/locatine/stop")

if __name__ == "__main__":
    unittest.main()
