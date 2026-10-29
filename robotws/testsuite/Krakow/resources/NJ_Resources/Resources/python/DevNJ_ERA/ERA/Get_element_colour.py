# -*- coding: utf-8 -*-
"""
:author: fuzeng.zhu
:contact: fuzeng.zhu@nokia-sbell.com
"""
import time
import os
from robot.api import logger


def get_elem_main_color(wd, elem, screenshot_folder="/tmp/selenium_tmp/", debug=False):
    cmd_check = "pip freeze | grep -i pillow"
    check_lib = os.popen(cmd_check)
    if 'Pillow' in check_lib.read():
        logger.info("Pillow has been installed", also_console=True)
    else:
        logger.info("Start to install pillow", also_console=True)
        cmd_install_pillow = "pip install Pillow"
        os.system(cmd_install_pillow)
    from PIL import Image
    if not os.path.exists(screenshot_folder):
        os.makedirs(screenshot_folder)
    screenshot_name = "scr_{}.png".format(time.strftime("%Y_%m_%d_%H_%M_%S", time.localtime(time.time())))
    screenshot_path = os.path.join(screenshot_folder, screenshot_name)
    try:
        wd.save_screenshot(screenshot_path)
        window_width = wd.get_window_size().get("width")
        img = Image.open(screenshot_path)
        ratio = img.size[0] / window_width
        left, top, width, height = (elem.location['x'], elem.location['y'], elem.size['width'], elem.size['height'])
        if width <= 0 or height <= 0:
            raise Exception("Element size error, width {} height {}".format(width, height))
        crop_rect = (left * ratio, top * ratio, (left + width) * ratio, (top + height) * ratio)
        elem_img = img.crop(crop_rect).convert("RGBA")

        elem_cropped_name = "elem_{}.png".format(time.strftime("%Y_%m_%d_%H_%M_%S", time.localtime(time.time())))
        elem_cropped_path = os.path.join(screenshot_folder, elem_cropped_name)
        elem_img.save(elem_cropped_path)

        elem_colors = elem_img.getcolors(elem_img.size[0] * elem_img.size[1])
        hex_main_color = "#" + "".join([hex(c)[2:].upper().rjust(2, '0') for c in list(max(elem_colors)[1])[0:3]])
        return hex_main_color
    finally:
        if not debug:
            for p in [screenshot_path, elem_cropped_path]:
                if os.path.exists(p):
                    os.remove(p)
