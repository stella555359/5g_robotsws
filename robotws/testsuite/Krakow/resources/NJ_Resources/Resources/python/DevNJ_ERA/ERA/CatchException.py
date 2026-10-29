# -*- coding: utf-8 -*-
"""
:author: longmei.zhao
:contact: longmei.zhao@nokia-sbell.com
"""
import os
import tempfile
from functools import wraps
from robot.api import logger


class CatchException(object):

    def __init__(self, driver, ui_timeout=5):
        self._driver = driver
        self.ui_timeout = ui_timeout
        self.screenshot_dir = tempfile.mkdtemp(
            prefix='{}_screenshots_'.format(self.__class__.__name__))

    def save_screenshot(self, screenshot_name):
        """
        save_screenshot function, help user to save a screenshot
        :param screenshot_name: screenshot file name, eg. screenshot_1.png
        """
        if not os.path.exists(self.screenshot_dir):
            os.makedirs(self.screenshot_dir)
        screenshot_path = os.path.join(self.screenshot_dir, screenshot_name)
        self._driver.save_screenshot(screenshot_path)
        logger.info('Screenshot save to {}'.format(screenshot_path), also_console=True)


def catch_exception(func):
    """
    Decorator for keywords need to catch exception and save screenshot
    """

    @wraps(func)
    def interface_func(*args, **kwargs):
        try:
            outcome = func(*args, **kwargs)
        except Exception as e:
            logger.error("Exception:{}".format(str(e)))
            driver = args[0]._driver
            CatchException(driver).save_screenshot('{}.png'.format(func.__name__))
            raise
        return outcome

    return interface_func
