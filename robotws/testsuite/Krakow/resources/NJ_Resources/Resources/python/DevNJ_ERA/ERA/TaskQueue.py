# -*- coding: utf-8 -*-
"""
:author: longmei.zhao
:contact: longmei.zhao@nokia-sbell.com
"""
import time
from selenium.webdriver.support.ui import WebDriverWait as Wait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from robot.api import logger


class TaskQueue(object):

    def __init__(self, driver, ui_timeout=5):
        self._driver = driver
        self.ui_timeout = ui_timeout

    def send_task_queue(self, timeout=5):
        """
        Main Function:
           This keyword is for send tasks.
        Arguments:
           :param timeout: wait for task queue
        Examples:
           | send_task_queue |
        """
        _xpath_task_queue = "//ul[contains(@class, 'navbar-right')]//a[@title='Task Queue']"
        _xpath_task_queue_span = "{}//span[contains(@class, 'badge-notify') and text()!=0]".format(_xpath_task_queue)
        _xpath_pending_tasks = "//h4[contains(text(), 'Pending Tasks ')]"
        _xpath_apply_tasks = "//div//a[@id='apply']"
        _xpath_apply_tasks_status = "//div[contains(text(), 'Changes are being validated')]"
        _xpath_close = "//a[contains(text(), 'Close')]"

        logger.info("Start to apply all tasks", also_console=True)
        Wait(self._driver, timeout).until(EC.visibility_of_element_located((By.XPATH, _xpath_task_queue_span)))
        self._driver.find_element(By.XPATH, _xpath_task_queue).click()
        Wait(self._driver, self.ui_timeout).until(EC.visibility_of_element_located((By.XPATH, _xpath_pending_tasks)))
        self._driver.find_element(By.XPATH, _xpath_apply_tasks).click()
        try:
            alert = self._driver.switch_to_alert()
            alert.accept()
        except Exception as e:
            pass
        Wait(self._driver, timeout*2).until(
            EC.visibility_of_element_located((By.XPATH, _xpath_apply_tasks_status)))
        self._driver.find_element(By.XPATH, _xpath_close).click()
