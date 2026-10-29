# -*- coding: utf-8 -*-
import os
import re
import json
import types
import sys
import time
import configparser
from ute_common_store import Store
from io import StringIO
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from ProxyWrap import ProxyWrap


class ProxyInterface(object):
    def __init__(self):
        self.store = Store()

    def start_proxy_instance(self, config_name="", **kwargs):
        currentPath = os.getcwd()
        if not currentPath.endswith("robotws"):
            currentPath = currentPath + "/robotws"
        proxy_path = currentPath + "/testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CBRS/resources/SASSim_HZ"
        if config_name == "":
            config_name = proxy_path + "/HttpProxy.conf"
        serverInstance = ProxyWrap(config_name, proxy_path)
        self.store.add(serverInstance, alias=kwargs.get('alias'))
        self.store.get(alias=kwargs.get('alias')).start_proxy()
        os.chdir(currentPath)

    def kill_proxy_instance(self, **kwargs):
        self.store.get(alias=kwargs.get('alias')).kill_proxy()
        self.store.remove(alias=kwargs.get('alias'))

    def prepare_to_check_proxy_log(self, **kwargs):
        self.store.get(alias=kwargs.get('alias')).prepare_to_check_message()

    def find_message_from_proxy_log(self, messageTag, **kwargs):
        return self.store.get(alias=kwargs.get('alias')).find_message(messageTag)

    def count_message_from_proxy_log(self, messageTag, **kwargs):
        return self.store.get(alias=kwargs.get('alias')).count_message(messageTag)

    def end_to_check_proxy_log(self, **kwargs):
        self.store.get(alias=kwargs.get('alias')).end_to_check()
