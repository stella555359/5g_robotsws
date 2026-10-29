#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
:copyright: Nokia
:author: Abdrrahmane NEZROUK (Paris Saclay)
:contact: abderrahmane.nezrouk@nokia.com
:maintainer: Abderrahmane Nezrouk (Paris Saclay)
Helpful library to replace /ffs/run/config/FRIps.txt file
"""

from functools import wraps
from taf.sbts.oam.coam.admin import admin
from taf.internal.sbts.admin.exceptions import AdminApiConnectionClosedException, AdminApiProcedureFailureException
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from pprint import pprint


def admin_connect(web_fun):
    @wraps(web_fun)
    def wrapper(self, *args, **kwargs):
        self.try_to_connect()
        try:
            result = web_fun(self, *args, **kwargs)
            return result
        finally:
            self.admin.teardown()

    return wrapper


class admin_manager:
    def __init__(self):
        self.admin = admin()
        self.bts_host = "192.168.255.129"

    def set_bts_host(self, bts_host="192.168.255.129"):
        self.bts_host = bts_host

    def try_to_connect(self, awaiting_time=300, repeat_time=5):
        num_try = 0
        while num_try < repeat_time:
            try:
                self.admin.connect_to(bts_host=self.bts_host)
                break
            except (AdminApiConnectionClosedException, AdminApiProcedureFailureException) as ex:
                num_try += 1
                if "cannot establish socket connection" in str(ex).lower():
                    logger.warn(str(ex))
                    BuiltIn().sleep(awaiting_time)
                else:
                    raise AdminApiConnectionClosedException(str(ex))
        else:
            raise AdminApiConnectionClosedException(
                "Cannot establish connection, connexion refused")

    @admin_connect
    def _get_managed_object_conf(self, class_name, timeout=10):
        """ Get RMODs configuration """
        managed_object = self.admin.get_managed_objects(class_name=class_name, timeout=timeout)
        return managed_object

    def get_rmod_conf(self, timeout=10, rmod_id=None):
        """ Get RMODs configuration """
        rmod_list = []
        rmods = self._get_managed_object_conf(class_name="RMOD_L", timeout=timeout)
        for ru in rmods:
            rmod_list.append({
                'distName': ru["distName"],
                'ipAddress': ru['parameters'].get('ipAddress', None),
                'serialNumber': ru['parameters'].get('serialNumber', None),
                'productCode': ru['parameters'].get('productCode', None),
                'productName': ru['parameters'].get('productName', None),
                'stateInfo': ru['parameters'].get('stateInfo', None)
            })
        if rmod_id:
            for ru in rmod_list:
                if ru['distName'].endswith(f"RMOD_L-{rmod_id}"):
                    return ru
            else:
                return None
        return rmod_list

    def get_bbmod_conf(self, timeout=10):
        """ Get BBMODs configuration """
        bbmods = self._get_managed_object_conf(class_name="BBMOD_L", timeout=timeout)
        return bbmods

    def get_alarm_conf(self, timeout=10):
        """ Get ALARMs configuration """
        alarms = self._get_managed_object_conf(class_name="ALARM_L", timeout=timeout)
        return alarms

    def get_nrcell_conf(self, timeout=10):
        """ Get NRCELLs configuration """
        nrcells = self._get_managed_object_conf(class_name="NRCELL_L", timeout=timeout)
        return nrcells
