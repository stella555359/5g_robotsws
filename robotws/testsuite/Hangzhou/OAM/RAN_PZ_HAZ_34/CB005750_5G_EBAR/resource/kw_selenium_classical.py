#!/usr/bin/env python
# -*- coding: utf-8 -*-
# ----------------------------------------------------------------------
#
# File: kw_selenium_classical.py
#
# ----------------------------------------------------------------------

# from __future__ import print_function

import os
import collections
import sys
import re
import json
import requests
from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger
# sys.path.append('/home/ute/Projects/robotws5g/resources/python_libs/')
# import dynamic_import_selenium
from taf.rfrl.common_resources.python import dynamic_import_selenium
# from dynamic_import_selenium.selenium_coam import selenium_coam as selenium_coam
# from taf.sbts.oam.coam.admin import admin
# from taf.selenium.gnb.oam.coam.classical import classical as selenium_coam_classical

__all__ = ["kw_selenium_classical"]


# ----------------------------------------------------------------------
# CLASS kw_selenium_classical
# ----------------------------------------------------------------------

class kw_selenium_classical(object):

    # ------------------------------------------------------------------
    # Robot Framework keywords.
    # ------------------------------------------------------------------

    ROBOT_LIBRARY_SCOPE = 'GLOBAL'
    ROBOT_LIBRARY_VERSION = '1.0'

    # ------------------------------------------------------------------
    # Constructor / initializer.
    # ------------------------------------------------------------------

    def __init__(self):

        # Classical DU WebEM.
        # self.url = "https://192.168.255.1/"
        self.url = "https://192.168.255.129/"
        self.username = 'Nemuadmin'
        self.password = 'nemuuser'
        self.browser = 'Firefox'
        self.width = 1920
        self.height = 1280

    # ==================================================================
    # RELEATED TO CONNECTION.
    # ==================================================================

    # ------------------------------------------------------------------
    # METHOD open_session
    # ------------------------------------------------------------------

    def open_session(self,
                     url='https://192.168.255.129',
                     username='Nemuadmin',
                     password='nemuuser'):

        self.url = url
        self.username = username
        self.password = password

        return self.__login()

    # ------------------------------------------------------------------
    # METHOD close_session
    # ------------------------------------------------------------------

    def close_session(self):
        return self.__logout()

    # ------------------------------------------------------------------
    # PRIVATE METHOD __login
    # ------------------------------------------------------------------

    def __login(self):
        logger.info("\nkw_selenium_classical::login()", also_console=True)
        logger.info("- INPUT: self.url = {}".format(self.url), also_console=True)
        self.sel_coam = dynamic_import_selenium.selenium_coam()
        # self.sel_coam = selenium_coam()
        logger.info("\ndynamic_import_selenium.selenium_coam in use()", also_console=True)
        # Open DU WebEM session in headless mode.
        self.sel_coam.enable_virtual_display(width=self.width, height=self.height)
        error_msg = self.sel_coam.login(self.url, self.username, self.password, browser=self.browser)
        if error_msg is not None:
            logger.info("ERROR: sel_coam.login() failed - error_msg = {}".format(error_msg), also_console=True)
            return False

        self.sel_coam.disable_message_box()
        if self.sel_coam.start_up_view_window_exists():
            self.sel_coam.close_start_up_view_window()

        return True

    # ------------------------------------------------------------------
    # PRIVATE METHOD __logout
    # ------------------------------------------------------------------

    def __logout(self):
        logger.info("\nkw_selenium_classical::logout()", also_console=True)

        # Close DU WebEM session.
        try:
            self.sel_coam.logout()
        except Exception as e:
            logger.info("EXCEPTION: sel_coam.logout() failed - e = [{}]".format(e), also_console=True)

        # Disable virtual display.
        try:
            self.sel_coam.disable_virtual_display()
        except Exception as e:
            logger.info("EXCEPTION: sel_coam.disable_virtual_display() failed - e = [{}]".format(e), also_console=True)

        return True

    # ==================================================================
    # RELEATED TO SFP/LANE.
    # ==================================================================

    # ------------------------------------------------------------------
    # METHOD lock_sfp_lane
    # ------------------------------------------------------------------

    def lock_sfp_lane(self, hw_name="BBMOD", sfp_port="RF1", lane_id="LANE-1"):

        sel_coam = selenium_coam_classical()

        sel_coam.enable_virtual_display(width=self.width, height=self.height)
        sel_coam.login(self.url, self.username, self.password, browser=self.browser)
        sel_coam.disable_message_box()

        if sel_coam.start_up_view_window_exists():
            sel_coam.close_start_up_view_window()

        sel_coam.lock_lane_from_sfp(hw_name, sfp_port, lane_id)

        sel_coam.disable_virtual_display()

    # ------------------------------------------------------------------
    # METHOD unlock_sfp_lane
    # ------------------------------------------------------------------

    def unlock_sfp_lane(self, hw_name="BBMOD", sfp_port="RF1", lane_id="LANE-1"):

        sel_coam = selenium_coam_classical()

        sel_coam.enable_virtual_display(width=self.width, height=self.height)
        sel_coam.login(self.url, self.username, self.password, browser=self.browser)
        sel_coam.disable_message_box()

        if sel_coam.start_up_view_window_exists():
            sel_coam.close_start_up_view_window()

        sel_coam.unlock_lane_from_sfp(hw_name, sfp_port, lane_id)

        sel_coam.disable_virtual_display()

    # ==================================================================
    # RELATED TO SCF.
    # ==================================================================

    # ------------------------------------------------------------------
    # METHOD save_scf_file
    # ------------------------------------------------------------------

    def save_scf_file(self, save_configuration_type=0,
                      url='https://192.168.255.129',
                      username='Nemuadmin',
                      password='nemuuser'):
        # logger.info("kw_selenium_classical::save_scf_file()", also_console=True)
        # logger.info("- INPUT: save_configuration_type = {}".format(save_configuration_type), also_console=True)
        # logger.info("- INPUT: url = {}".format(url), also_console=True)

        self.url = url
        self.username = username
        self.password = password

        if not self.__login():
            logger.info("ERROR: kw_selenium_classical::__login() processing failed!", also_console=True)
            return None

        scf_file_path = None

        try:
            scf_file_path = self.sel_coam.save_bts_configuration(save_configuration_type)
        except Exception as e:
            logger.info("EXCEPTION: sel_coam.save_bts_configuration() processing failed - e = [{}]"
                        .format(e), also_console=True)
        finally:
            self.__logout()

        return scf_file_path

    # ------------------------------------------------------------------
    # METHOD perform_commissioning
    # ------------------------------------------------------------------

    def perform_commissioning(self, du_scf_path):
        logger.info("\nkw_selenium_classical::perform_commissioning()", also_console=True)
        logger.info("- INPUT: du_scf_path = {}".format(du_scf_path), also_console=True)

        if not self.__login():
            logger.info("ERROR: kw_selenium_classical::login() processing failed!", also_console=True)
            return False

        # STEP 1 : upload DU SCF file via DU WebEM.sel_coam
        logger.info("\nSTEP 1 : UPLOAD PLAN FILE in progress...", also_console=True)
        if not self.sel_coam.load_commissioning_file_and_check_load_status(du_scf_path):
            logger.info("ERROR: load_commissioning_file_and_check_load_status() processing failed!", also_console=True)
            self.__logout()
            return False

        # STEP 2 : validate plan.
        logger.info("\nSTEP 2 - PLAN VALIDATION in progress...", also_console=True)
        try:
            self.sel_coam.validate_plan()
        except Exception as e:
            logger.info("EXCEPTION : sel_coam.validate_plan() failed - e = [{}]".format(e), also_console=True)
            self.__logout()
            return False

        # STEP 3 : activate plan.
        logger.info("\nSTEP 3 - PLAN ACTIVATION in progress...", also_console=True)
        try:
            self.sel_coam.activate_plan(activate_plan_despite_errors=True)
        except Exception as e:
            logger.info("EXCEPTION : sel_coam.activate_plan() failed - e = [{}]".format(e), also_console=True)
            self.__logout()
            return False

        self.__logout()
        return True

    # ------------------------------------------------------------------
    # METHOD get_mrbts_id
    # ------------------------------------------------------------------

    def get_mrbts_id(self, scf_path):
        with open(scf_path, 'r+') as fh:
            xml = fh.read()
            rule = r'.*MRBTS\" distName=\"(.*?)\" version='
            mrbts_idlist = re.findall(rule, xml)
            mrbts_id = ""
            mrbts_id = mrbts_id.join(mrbts_idlist)
            return mrbts_id

    # ------------------------------------------------------------------
    # METHOD get_nrbts_id
    # ------------------------------------------------------------------

    def get_nrbts_id(self, scf_path):
        with open(scf_path, 'r+') as f:
            xml = f.read()
            rule = r'.*NRBTS\" distName=\".*\/(.*?)\" version='
            nrbts_idlist = re.findall(rule, xml)
            nrbts_id = ""
            nrbts_id = nrbts_id.join(nrbts_idlist)
            return nrbts_id

    # ==================================================================
    # RELATED TO EQUIPMENT STATUS.
    # ==================================================================

    # ------------------------------------------------------------------
    # METHOD get_hw_info
    # ------------------------------------------------------------------

    def get_hw_info(self, hw_name):
        logger.info("kw_selenium_classical::get_hw_info()", also_console=True)
        logger.info("- INPUT : hw_name = {}".format(hw_name), also_console=True)
        return self.sel_coam.get_hw_info(hw_name)

    # ------------------------------------------------------------------
    # METHOD get_hw_parameters
    # ------------------------------------------------------------------

    def get_hw_parameters(self, hw_type='SMOD'):
        logger.info("kw_selenium_classical::get_hw_parameters()", also_console=True)
        return self.sel_coam.get_hw_parameters(hw_type)

    # ------------------------------------------------------------------
    # METHOD get_parameter_value
    # ------------------------------------------------------------------

    def get_parameter_value(self, dist_name, parameter_name, abbreviation):
        logger.info("kw_selenium_classical::get_parameter_value()", also_console=True)
        logger.info("- INPUT : dist_name      = {}".format(dist_name), also_console=True)
        logger.info("- INPUT : parameter_name = {}".format(parameter_name), also_console=True)
        logger.info("- INPUT : abbreviation   = {}".format(abbreviation), also_console=True)

        parameter_value = None
        try:
            # Invoke keyword for getting parameter value at Parameter Editor view.
            parameter_value = self.sel_coam.get_parameter_value(dist_name,
                                                                filter_param=parameter_name,
                                                                node_index=None,
                                                                abbr=abbreviation)
        except Exception as e:
            logger.info("EXCEPTION : sel_coam.get_parameter_value() failed - e = [{}]".format(e), also_console=True)
            return None

        logger.info("- OUTPUT : parameter_value = {}".format(parameter_value), also_console=True)
        return parameter_value

    # ------------------------------------------------------------------
    # METHOD get_bts_status
    # ------------------------------------------------------------------

    def get_bts_status(self):
        logger.info("kw_selenium_classical::get_bts_status()", also_console=True)
        return self.sel_coam.get_bts_status()

    # ------------------------------------------------------------------
    # METHOD get_ru_info
    # ------------------------------------------------------------------

    def get_ru_info(self):
        logger.info("kw_selenium_classical::get_ru_info()", also_console=True)
        return self.sel_coam.get_ru_info()

    # ------------------------------------------------------------------
    # METHOD get_gnss_info
    # ------------------------------------------------------------------

    def get_gnss_info(self):
        logger.info("kw_selenium_classical::get_gnss_info()", also_console=True)
        gnss_info = self.sel_coam.get_gnss_info()
        return gnss_info

    # ------------------------------------------------------------------
    # METHOD get_cell_info
    # ------------------------------------------------------------------

    def get_cell_info(self, cell_index=1):
        logger.info("kw_selenium_classical::get_cell_info()", also_console=True)
        cell_info = self.sel_coam.get_cell_info(cell_index)
        return cell_info

    # ------------------------------------------------------------------
    # METHOD is_unit_operational
    # ------------------------------------------------------------------

    def is_unit_operational(self, dist_name):
        logger.info("kw_selenium_classical::is_unit_operational()", also_console=True)
        logger.info("- INPUT : dist_name = {}".format(dist_name), also_console=True)

        administrativeState = self.get_parameter_value(dist_name, "Administrative state", "administrativeState")
        availabilityStatus = self.get_parameter_value(dist_name, "Availability status", "availabilityStatus")
        operationalState = self.get_parameter_value(dist_name, "Operational state", "operationalState")
        proceduralStatus = self.get_parameter_value(dist_name, "Procedural status", "proceduralStatus")

        operational = False

        if (administrativeState == 'Unlocked'
                and availabilityStatus == 'Online'
                and operationalState == 'Enabled'
                and proceduralStatus == 'configured'):

            operational = True
        elif (administrativeState == 'Unlocked'
                and availabilityStatus == '-'
                and operationalState == 'enabled'
                and proceduralStatus == 'configured'):

            operational = True
        else:
            logger.info("\n Unit [{}] is NOT operational:".format(dist_name), also_console=True)
            logger.info("  - administrativeState = {}".format(administrativeState), also_console=True)
            logger.info("  - availabilityStatus  = {}".format(availabilityStatus), also_console=True)
            logger.info("  - operationalState    = {}".format(operationalState), also_console=True)
            logger.info("  - proceduralStatus    = {}".format(proceduralStatus), also_console=True)

        return operational

    # ------------------------------------------------------------------
    # METHOD is_smod_operational
    # ------------------------------------------------------------------

    def is_smod_operational(self, unit_index=0):
        logger.info("kw_selenium_classical::is_smod_operational()", also_console=True)

        smod_info = self.sel_coam.get_hw_info(hw_name="ASIL")
        if smod_info is None:
            return False

        product_name = smod_info["Product name"]
        logger.info("- product_name = {}".format(product_name), also_console=True)

        operational = False

        administrativeState = smod_info["Status"]["Administrative state"]
        availabilityStatus = smod_info["Status"]["Availability status"]
        operationalState = smod_info["Status"]["Operational state"]
        proceduralStatus = smod_info["Status"]["Procedural status"]

        if (administrativeState == 'Unlocked'
                and availabilityStatus == 'Online'
                and operationalState == 'Enabled'
                and proceduralStatus == 'configured'):

            operational = True
        elif (administrativeState == 'Unlocked'
                and availabilityStatus == '-'
                and operationalState == 'enabled'
                and proceduralStatus == 'configured'):

            operational = True
        else:
            logger.info("\n SMOD {} is NOT operational:".format(unit_index), also_console=True)
            logger.info("  - administrativeState = {}".format(administrativeState), also_console=True)
            logger.info("  - availabilityStatus  = {}".format(availabilityStatus), also_console=True)
            logger.info("  - operationalState    = {}".format(operationalState), also_console=True)
            logger.info("  - proceduralStatus    = {}".format(proceduralStatus), also_console=True)

        return operational

    # ------------------------------------------------------------------
    # METHOD is_bbmod_operational
    # ------------------------------------------------------------------

    def is_bbmod_operational(self):
        logger.info("kw_selenium_classical::is_bbmod_operational()", also_console=True)

        bbmod_info = self.sel_coam.get_hw_info(hw_name="ABIO")
        if bbmod_info is None:
            return False

        product_name = bbmod_info["Product name"]
        logger.info("- product_name = {}".format(product_name), also_console=True)

        operational = False

        administrativeState = bbmod_info["Status"]["Administrative state"]
        availabilityStatus = bbmod_info["Status"]["Availability status"]
        operationalState = bbmod_info["Status"]["Operational state"]
        proceduralStatus = bbmod_info["Status"]["Procedural status"]

        if (administrativeState == 'Unlocked'
                and availabilityStatus == 'Online'
                and operationalState == 'Enabled'
                and proceduralStatus == 'configured'):

            operational = True
        elif (administrativeState == 'Unlocked'
                and availabilityStatus == '-'
                and operationalState == 'enabled'
                and proceduralStatus == 'configured'):

            operational = True
        else:
            logger.info("\n BBMOD {} is NOT operational:".format(unit_index), also_console=True)
            logger.info("  - administrativeState = {}".format(administrativeState), also_console=True)
            logger.info("  - availabilityStatus  = {}".format(availabilityStatus), also_console=True)
            logger.info("  - operationalState    = {}".format(operationalState), also_console=True)
            logger.info("  - proceduralStatus    = {}".format(proceduralStatus), also_console=True)

        return operational

    # ------------------------------------------------------------------
    # METHOD is_ru_operational
    # ------------------------------------------------------------------

    def is_ru_operational(self, unit_index=0):
        logger.info("kw_selenium_classical::is_ru_operational()", also_console=True)
        logger.info("- INPUT : unit_index = {}".format(unit_index), also_console=True)

        ru_info = self.sel_coam.get_ru_info()
        if ru_info is None:
            return False

        product_name = ru_info["Product name"]
        logger.info("- product_name = {}".format(product_name), also_console=True)

        operational = False

        administrativeState = ru_info["Status"]["Administrative state"]
        availabilityStatus = ru_info["Status"]["Availability status"]
        operationalState = ru_info["Status"]["Operational state"]
        proceduralStatus = ru_info["Status"]["Procedural status"]

        if (administrativeState == 'Unlocked'
                and availabilityStatus == 'Online'
                and operationalState == 'Enabled'
                and proceduralStatus == 'configured'):

            operational = True
        elif (administrativeState == 'Unlocked'
                and availabilityStatus == '-'
                and operationalState == 'enabled'
                and proceduralStatus == 'configured'):

            operational = True
        else:
            logger.info("\n RU {} is NOT operational:".format(unit_index), also_console=True)
            logger.info("  - administrativeState = {}".format(administrativeState), also_console=True)
            logger.info("  - availabilityStatus  = {}".format(availabilityStatus), also_console=True)
            logger.info("  - operationalState    = {}".format(operationalState), also_console=True)
            logger.info("  - proceduralStatus    = {}".format(proceduralStatus), also_console=True)

        return operational

    # ------------------------------------------------------------------
    # METHOD is_gnss_operational
    # ------------------------------------------------------------------

    def is_gnss_operational(self, unit_index=0):
        logger.info("kw_selenium_classical::is_gnss_operational()", also_console=True)

        gnss_info = self.sel_coam.get_gnss_info()
        if gnss_info is None:
            return False

        product_name = gnss_info["Product name"]
        logger.info("- product_name = {}".format(product_name), also_console=True)

        operational = False

        administrativeState = gnss_info["Status"]["Administrative state"]
        availabilityStatus = gnss_info["Status"]["Availability status"]
        operationalState = gnss_info["Status"]["Operational state"]

        if (administrativeState == 'Unlocked'
                and availabilityStatus == 'Online'
                and operationalState == 'Enabled'):

            operational = True
        elif (administrativeState == 'Unlocked'
                and availabilityStatus == '-'
                and operationalState == 'enabled'):

            operational = True
        else:
            logger.info("\n GNSS {} is NOT operational:".format(unit_index), also_console=True)
            logger.info("  - administrativeState = {}".format(administrativeState), also_console=True)
            logger.info("  - availabilityStatus  = {}".format(availabilityStatus), also_console=True)
            logger.info("  - operationalState    = {}".format(operationalState), also_console=True)

        return operational

    # ------------------------------------------------------------------
    # METHOD is_cell_on_air
    # ------------------------------------------------------------------

    def is_cell_on_air(self, cell_index=1):
        logger.info("kw_selenium_classical::is_cell_on_air()", also_console=True)
        logger.info("- INPUT : cell_index = {}".format(cell_index))

        cell_info = self.sel_coam.get_cell_info(cell_index)
        if cell_info is None:
            return False

        cell_name = cell_info["Cell name"]
        logger.info("- cell_name = {}".format(cell_name), also_console=True)

        on_air = False

        administrativeState = cell_info["Status"]["Administrative state"]
        availabilityStatus = cell_info["Status"]["Availability status"]
        operationalState = cell_info["Status"]["Operational state"]
        proceduralStatus = cell_info["Status"]["Procedural status"]

        if (administrativeState == 'Unlocked'
                and availabilityStatus == 'Online'
                and operationalState == 'Enabled'
                and proceduralStatus == 'configured'):

            on_air = True
        elif (administrativeState == 'Unlocked'
                and availabilityStatus == '-'
                and operationalState == 'enabled'
                and proceduralStatus == 'configured'):

            on_air = True
        else:
            logger.info("\n CELL {} is NOT on air:".format(cell_index), also_console=True)
            logger.info("  - administrativeState = {}".format(administrativeState), also_console=True)
            logger.info("  - availabilityStatus  = {}".format(availabilityStatus), also_console=True)
            logger.info("  - operationalState    = {}".format(operationalState), also_console=True)
            logger.info("  - proceduralStatus    = {}".format(proceduralStatus), also_console=True)

        return on_air


# End of CLASS kw_selenium_classical.


# ----------------------------end-of-file-------------------------------
