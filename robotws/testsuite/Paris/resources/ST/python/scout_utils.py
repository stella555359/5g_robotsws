#!/bin/python -B
# -*- coding: utf-8 -*-
"""
:copyright: Nokia
:author: Abdrrahmane NEZROUK (Paris Saclay)
:contact: abderrahmane.nezrouk@nokia.com
:maintainer: Abderrahmane Nezrouk (MN RAN Pz NPS SG2)
"""
__maintainer__ = "Abderrahmane NEZROUK"
__team__ = "MN 5G&SC Pz 5G I&V x NPS x SG"
__email__ = "Abderrahmane.nezrouk@nokia.com"

import os
from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger as robot_logger
from taf.sw.scout.interface import scout
from taf.rfrl.bts.devices.du.du_operations import EnbDuOperations as enbbbu
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations as gnbbbu
from taf.internal.aliasing.exceptions import AliasLookupError
from taf.rfrl.bts.connections import device_aliases

builtin = BuiltIn()
instance = None
ROBOT_LIBRARY_SCOPE = 'TEST SUITE'


def _get_connection_alias(bts_type="GNB", bts_id=0, du_id=0):
    global instance
    is_new_connection = False
    if bts_type == "GNB" or bts_type == "4G5G":
        instance = gnbbbu()
    elif bts_type == "ENB":
        instance = enbbbu()
    else:
        raise AssertionError(f"Wrong bts_type '{bts_type}'! allowed: ENB|GNB|4G5G")
    conn_alias = device_aliases.rest_bts_du.format(f"{bts_type}", bts_id, du_id)
    try:
        conn_instance = instance.admin.store.get(conn_alias)
    except AliasLookupError:
        robot_logger.debug(f"[{conn_alias}] not connected")
        instance.connect(bts_id=bts_id, du_id=du_id)
        is_new_connection = True
    return conn_alias, is_new_connection


def _set_scount_name(bts_scout_name, bts_type):
    if (bts_type == "GNB" and "_5G" in bts_scout_name) or \
            (bts_type == "ENB" and "_4G" in bts_scout_name) or \
            (bts_type == "4G5G" and "_4G5G" in bts_scout_name):
        return bts_scout_name
    if bts_type == "GNB":
        bts_scout_name = f"{bts_scout_name}_5G"
    elif bts_type == "ENB":
        bts_scout_name = f"{bts_scout_name}_4G"
    elif bts_type == "4G5G":
        bts_scout_name = f"{bts_scout_name}_4G5G"
    return bts_scout_name


def _return_bts_scout_name(bts_scout_name, bts_type="GNB", bts_id=0, du_id=0, timeout=60):
    global instance
    Err = ""
    conn_alias, is_new_connection = _get_connection_alias(bts_type=bts_type, bts_id=bts_id, du_id=du_id)
    Scout = scout()
    try:
        Scout.setup_scout(scout_testline_name=bts_scout_name, alias=conn_alias)
        bts_status = Scout.get_scout_testline_status(alias=conn_alias)
        robot_logger.debug(f"[{__name__}]: bts_status of {bts_scout_name} ==> {bts_status}")
        if bts_status in ["unknown"]:
            Scout.teardown_scout_api(alias=conn_alias)
            robot_logger.debug(f"scout tesline name {bts_scout_name} not found")
            bts_scout_name = _set_scount_name(bts_scout_name, bts_type)
            if bts_scout_name:
                Scout.setup_scout(scout_testline_name=bts_scout_name, alias=conn_alias)
                bts_status = Scout.get_scout_testline_status(alias=conn_alias)
                robot_logger.debug(f"[{__name__}]: bts_status of {bts_scout_name} ==> {bts_status}")
                if bts_status in ["unknown"]:
                    Err = f"scout tesline name {bts_scout_name} not found"
                    robot_logger.debug(f"[{__name__}]: faliled : {Err}")
            else:
                Err = f"wrong scout tesline name !"
    except Exception as ex:
        Err = ex
    Scout.teardown_scout_api(alias=conn_alias)
    del Scout
    if is_new_connection:
        instance.admin.teardown(conn_alias)
        robot_logger.debug(f"[{__name__}]: instance.admin.teardown")
    if Err:
        robot_logger.debug(f"[{__name__}]: failed with {Err}")
    return bts_scout_name


def get_bts_scout_name(bts_scout_name="", bts_type="GNB"):
    if not bts_scout_name:
        bts_scout_name = builtin.get_variable_value("${bts_scout_name}", "")
        if bts_scout_name:
            robot_logger.debug(f"[{__name__}]: bts_scout_name from bts_scout_name variable: [{bts_scout_name}]")
            return bts_scout_name
    if not bts_scout_name:
        configuration_variable = builtin.get_variable_value("${CONFIGURATION}", "")
        if configuration_variable:
            bts_scout_name = configuration_variable.split(".")[1]
            robot_logger.debug(f"[{__name__}]: bts_scout_name from CONFIGURATION variable: [{bts_scout_name}]")
    if not bts_scout_name:
        import socket
        hostname = socket.gethostname()
        del socket
        robot_logger.debug(f"[{__name__}]: hostname : [{hostname}]")
        bts_scout_name = hostname.replace("-", "_")
    bts_scout_name = _set_scount_name(bts_scout_name, bts_type)
    return bts_scout_name


def set_scout_config_id_tc(bts_scout_name, bts_type="GNB", bts_id=0, du_id=0, timeout=60):
    global instance
    use_scout_internal_id = not bool(os.environ.get("CM_EXECUTION_ID"))
    robot_logger.debug(f"[{__name__}]: use_scout_internal_id: {use_scout_internal_id}")
    if bts_scout_name:
        conn_alias, is_new_connection = _get_connection_alias(bts_type=bts_type, bts_id=bts_id, du_id=du_id)
        Scout = scout()
        Err = ""
        external_scf_id = ""
        try:
            Scout.setup_scout(scout_testline_name=bts_scout_name, alias=conn_alias)
            external_scf_id = Scout.request_scf(
                use_scout_internal_id=use_scout_internal_id,
                timeout=timeout, alias=conn_alias
            )
            robot_logger.debug(f"[{__name__}]: external_scf_id: {external_scf_id}")
            Scout.teardown_scout_api(alias=conn_alias)
            del Scout
        except Exception as ex:
            Err = ex

        if is_new_connection:
            instance.admin.teardown(conn_alias)
            robot_logger.debug(f"[{__name__}]: instance.admin.teardown")
        if Err:
            raise AssertionError(f"[{__name__}]: failed an exception occurred :[{Err}]")

        if use_scout_internal_id:
            BuiltIn().set_tags(f"ute:id:{external_scf_id}")
