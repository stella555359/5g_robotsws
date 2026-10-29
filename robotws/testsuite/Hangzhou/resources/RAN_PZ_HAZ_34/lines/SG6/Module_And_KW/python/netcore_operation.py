import os
import time
from taf.internal.aliasing import aliasing_scope
try:
    from selenium import webdriver
    from selenium.webdriver.chrome.options import Options
    from selenium.webdriver.common.by import By
    from selenium.webdriver.common.action_chains import ActionChains
    from taf.selenium.core.webdrivers import CustomWebDriverChrome
except BaseException:
    os.system("pip install taf.selenium.core")
    from selenium import webdriver
    from selenium.webdriver.chrome.options import Options
    from selenium.webdriver.common.by import By
    from selenium.webdriver.common.action_chains import ActionChains
    from taf.selenium.core.webdrivers import CustomWebDriverChrome
import requests
requests.urllib3.verify = False


class BaseWeb:
    def __init__(self, driver=None, output_dir=None):
        if output_dir is None:
            output_dir = "~/"
            self.driver = CustomWebDriverChrome(output_dir)
            # os.system("chmod 777 /opt/ute/chromedriver/chromedriver")
            # print(os.system("/opt/ute/chromedriver/chromedriver --version"))
            # chrome_options = Options()
            # # chrome_options.add_argument('--headless')
            # chrome_options.add_argument('--no-sandbox')
            # chrome_options.add_argument('--disable-dev-shm-usage')
            # # chrome_options.add_argument('--remote-debugging-port=9222')
            # # chrome_options.add_argument('--ignore-certificate-errors')
            # self.driver = webdriver.Chrome(
            #     executable_path=r'/opt/ute/chromedriver/chromedriver',
            #     chrome_options=chrome_options)
        else:
            self.driver = driver

    def wait_for_element(self, element_id, by=By.ID, wait_time=10):
        t = time.time()
        while time.time() - t < wait_time:
            try:
                self.driver.find_element(by, element_id)
                return True
            except Exception as e:
                print("Can't find the element {}".format(element_id))
        return False


class CoreNetWeb(BaseWeb):
    def __init__(self):
        BaseWeb.__init__(self)

    def login(self, host="10.110.137.235",
              port="8443", version="v23_2", username="pz1test", password="System!123"):
        self.driver.get("https://{}:{}/servicemanager/{}/".format(host,
                                                                  port,
                                                                  version))
        self.driver.implicitly_wait(5)
        exist = self.wait_for_element("details-button", By.ID)
        if exist:
            self.driver.find_element_by_id("details-button").click()
            time.sleep(1)
            self.driver.find_element_by_id("proceed-link").click()
        self.driver.find_element(By.ID, "input_0").send_keys(username)
        self.driver.find_element(By.ID, "input_1").send_keys(password)
        self.driver.find_element(By.ID, "login").click()
        time.sleep(1)
        exist = self.wait_for_element("modal-dialog", By.CLASS_NAME)
        if exist:
            self.close_dialog()

    def close_dialog(self, element_id="Cancel"):
        self.driver.find_element_by_id(element_id).click()

    def control_page_go_to_other_page(self, element_id):
        self.driver.find_element_by_id(element_id).click()


class SubscriberManager(BaseWeb):
    EDIT_8888_element = "row0jqxGrid4"

    def __init__(self, driver):
        BaseWeb.__init__(self, driver=driver)

    def _navbar(self, element_id):
        self.driver.find_element_by_id(element_id).click()

    def device_search_criteria_baseon_identifier(
            self, identifier="460023100008888"):
        self._navbar(element_id="submenuLink__device_")
        time.sleep(1)
        self.driver.find_element_by_xpath(
            "//md-select//div[contains(text(),'Identifier')]").click()
        time.sleep(1)
        exist = self.wait_for_element(
            "//md-select-menu//md-option[@value='Identifier']", By.XPATH)
        time.sleep(1)
        if exist:
            self.driver.find_element_by_xpath(
                "//md-select-menu//md-option[@value='Identifier']").click()

        self.driver.find_element_by_xpath(
            "//md-select//div[contains(text(),'E164')]").click()
        time.sleep(1)
        self.driver.find_element_by_xpath(
            "//md-select-menu//md-option[@value='IMSI']").click()
        time.sleep(1)
        self.driver.find_element_by_id("identifierID").send_keys(identifier)
        time.sleep(1)
        self.driver.find_element_by_xpath(
            "//md-input-container//button//i[text()='search']").click()

    def edit_the_device(self):
        ActionChains(self.driver).move_to_element(
            self.driver.find_element_by_xpath("//div[@class='gridRow'][1]")).perform()
        exist = self.wait_for_element(
            "//div[@class='gridRow'][1]//span//div[@id='edit']", By.XPATH)
        print(exist)
        # click edit button
        self.driver.find_element_by_xpath(
            "//div[@class='gridRow'][1]//span//div[@id='edit']").click()
        # for custom data click, will change to custom data page
        ActionChains(self.driver).move_to_element(
            self.driver.find_element_by_xpath("//div[@class='stepsWindow']")).perform()
        self.driver.find_element_by_xpath(
            "//div[@class='stepsWindow']//div[contains(text(),'Custom Data')]").click()

    def delete_test_custom_data(self):
        js = "return document.evaluate(\"//button[contains(@class, 'pull-right')]\",document).iterateNext().click()"
        self.driver.execute_script(js)

    def add_test_custom_data(self, rule):
        input_elements = self.driver.find_elements_by_xpath(
            "//*[@id='par.value.value']")
        need_add = True
        for element in input_elements:
            v = element.get_attribute("value")
            if v == rule:
                need_add = False
        if need_add:
            # for Add Custom Data
            ActionChains(self.driver).move_to_element(
                self.driver.find_element_by_xpath("//group-panel//button[@name='addRow']")).perform()
            self.driver.find_element_by_xpath(
                "//group-panel//button[@name='addRow']").click()
            # select key is Test
            exist = self.wait_for_element(
                "//group-panel//md-select-value//span[contains(text(),'Select...')]", By.XPATH)
            print(exist)
            ActionChains(self.driver).move_to_element(
                self.driver.find_element_by_xpath(
                    "//group-panel//md-select-value//span[contains(text(),'Select...')][1]/../..")).perform()
            self.driver.find_element_by_xpath(
                "//group-panel//md-select-value//span[contains(text(),'Select...')][1]/../..").click()
            ActionChains(self.driver).move_to_element(
                self.driver.find_element_by_xpath(
                    "//div[contains(@class,'md-active md-clickable')]//md-option[@value='TEST'][1]")
            ).perform()
            self.driver.find_element_by_xpath(
                "//div[contains(@class,'md-active md-clickable')]//md-option[@value='TEST'][1]"
            ).click()
            # input the test seq
            time.sleep(1)
            self.driver.find_element_by_xpath(
                "//*[@id='par.value.value']").clear()
            self.driver.find_element_by_xpath(
                "//*[@id='par.value.value']").send_keys(rule)

        # save and send
        time.sleep(3)
        ret = self.wait_for_element("//div[contains(@class,'buttonArea')]//button[@id='buttonFormValid']",
                                    By.XPATH)
        print(ret)
        js = "return document.getElementById('buttonFormValid').click()"
        self.driver.execute_script(js)
        print("change rule {} success".format(rule))


class CoreNetInterface():
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'
    # ROBOT_LIBRARY_DOC_FORMAT = 'reST'
    __version__ = '0.1'

    def __init__(self):
        pass

    def setup(self,
              host="10.110.137.235",
              port="8443", version="v23_2", username="pz1test", password="System!123"):
        self.coreweb = CoreNetWeb()
        self.coreweb.login(host=host,
                           port=port,
                           version=version,
                           username=username,
                           password=password)

    def send_custom_rule(self, identifier="460023100008888",
                         rule="PZ1-ADD-5QI9"):
        self.coreweb.control_page_go_to_other_page(
            element_id="_subscriber_manager_")
        sub_web = SubscriberManager(driver=self.coreweb.driver)
        sub_web.device_search_criteria_baseon_identifier(identifier=identifier)
        sub_web.edit_the_device()
        sub_web.delete_test_custom_data()
        sub_web.add_test_custom_data(rule=rule)

    def teardown(self):
        self.coreweb.driver.close()
        self.coreweb.driver.quit()


class CoreNetApi():
    def __init__(self):
        pass

    def setup(self,
              host="10.110.137.235",
              port="8443", version="v23_2", username="pz1test", password="System!123"):
        self.baseurl = "https://{}:{}/services/ServiceManager/subscriber/".format(
            host, port)
        print(self.baseurl)
        self.ctx = {
            'headers': {'Content-Type': 'application/json'},
            'auth': ('pz1test', 'System!123')
        }

    def send_custom_rule(self, identifier="460023100008888",
                         rule="PZ1-ADD-5QI9"):
        payload = "imsi={}&rule_name={}".format(identifier, rule)
        rep = requests.request("POST",
                               url="https://newhorizons.srn.dyn.nesc.nokia.net/api/selfservice/ncp_api_update_device",
                               headers={
                                   'Content-Type': 'application/x-www-form-urlencoded',
                                   'Authorization': 'Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.' +
                                   "eyJ1aWQiOiJwejFfaHo3IiwiZW1haWwiOiJ3aW5uaWUuaGVAbm9raWEtc2Jlb" +
                                   "GwuY29tIiwiZGlzcGxheW5hbWUiOiJQejEgSHo3IiwibnNuY2l0eSI6Ikhhbmd" +
                                   "6aG91Iiwicm9sZXMiOlsicHoxX2h6N19hdXRvbWF0aW9u" +
                                   "Il0sImV4cCI6MjAxNDYxNzMwMi4yMTM5ODJ9." +
                                   "uc-l6wYhtI59LggqGqC-1qm6LvjNfXWRB1BdhUb3gMu9V7woLgz0Z_RPBW7WitwZ5nrnrkJbylz5-" +
                                   "UwyOphCVpkeiKrCTc4iJL8sUtNPomZfCYjdwjWZ3KltM8BZ4jkt3bx_" +
                                   "uSarHvpwCOfDwGvWvFdw2S5C68xrB6eif2JVCuUT2l_dph44U4mZJ_" +
                                   "b4k4uuyiSxot2qXyRsMNGLTkBp2aplgNQuEp0DsXFpixQ9EvQvQ15NG0W5XHRLircFnVIWePVv9" +
                                   'yWcwhQYB0BRCz31XnnVcWc9XZa91W_EuRFCsmNrArXolVMK0EmbxKyEUMxqgARv57ue2ECnuWYoiEBJ6Q'
                               },
                               verify=False,
                               data=payload)

        if rep.status_code == 200:
            text = rep.text
            print(text)
            return "success send {} {}".format(identifier, rule)
        return "failure send {} {}".format(identifier, rule)


if __name__ == '__main__':
    # interface = CoreNetInterface()
    interface = CoreNetApi()
    interface.setup()
    interface.send_custom_rule()
