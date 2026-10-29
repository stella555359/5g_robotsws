from taf.transport.ssh import ssh
from taf.sbts.oam.coam.admin import admin
from taf.gnb.oam.coam.cu import cu as cu_admin
from taf.gnb.oam.coam.vdu import Vdu as vdu_admin
from selenium.common.exceptions import WebDriverException
from taf.selenium.sbts import sbts
import re
import subprocess
import os
from contextlib import contextmanager


class SaveScreenshot():
    def __init__(self, output_path="/tmp/SCREENSHOTS/"):
        self.output_path = output_path
        os.makedirs(self.output_path, exist_ok=True)
        self.sbts_obj = sbts()
        self.gNB_url = "https://192.168.255.129/#/login"
        self.username = "Nemuadmin"
        self.password = "nemuuser"
        self.site_view_screenshot = "site_view_screenshot"
        self.alarm_page_screenshot = "alarm_page_screenshot"
        self.detail_site_view_screenshot = "detail_site_view_screenshot"

    def login_to_gnb_and_capture_screenshot(self):
        try:
            self.sbts_obj.enable_virtual_display()
            self.sbts_obj.login(url=self.gNB_url, username=self.username, password=self.password)
            self.get_site_view_screenshot()
            self.get_alarm_page_screenshot()
            self.get_detailed_site_view_screenshot()
        except Exception as e:
            print("GUI screenshot collection failed:", e)
        finally:
            try:
                self.sbts_obj.logout()
            except Exception as e:
                print("Logout failed:", e)
            try:
                self.sbts_obj.close_browser()
            except Exception as e:
                print("Close browser failed:", e)
            try:
                self.sbts_obj.disable_virtual_display()
            except Exception as e:
                print("Disable virtual display failed:", e)

    def get_detailed_site_view_screenshot(self):
        self.sbts_obj.get_gnss_info(type_='GNSSE', gnss_index=1, sbts=None)
        print("Capturing detailed site view screenshot...")
        success = self.sbts_obj.save_screenshot(self.detail_site_view_screenshot, screenshot_dir=self.output_path)
        print(
          f"Screenshot success: {success}, path: "
          f"{os.path.join(self.output_path, self.detail_site_view_screenshot)}.png")

    def get_alarm_page_screenshot(self):
        self.sbts_obj.get_active_alarm_info(alarm_filter=None, timeout=10, sbts=None)
        print("Capturing alarm page screenshot...")
        success = self.sbts_obj.save_screenshot(self.alarm_page_screenshot, screenshot_dir=self.output_path)
        print(f"Screenshot success: {success}, path: {os.path.join(self.output_path, self.alarm_page_screenshot)}.png")

    def get_site_view_screenshot(self):
        print("Capturing site view screenshot...")
        success = self.sbts_obj.save_screenshot(self.site_view_screenshot, screenshot_dir=self.output_path)
        print(f"Screenshot success: {success}, path: {os.path.join(self.output_path, self.site_view_screenshot)}.png")

    def collect_screenshot(self):
        ss = SaveScreenshot(output_path="/tmp/SCREENSHOTS/")
        ss.login_to_gnb_and_capture_screenshot()


if __name__ == "__main__":
    pass
