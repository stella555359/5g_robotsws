# -*- coding: utf-8 -*-
import os
import re
import json
import types
import sys
import time
import ConfigParser
from ute_common_store import Store
from cStringIO import StringIO
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from ProxyWrap import ProxyWrap


class ProxyInterface(object):
    def __init__(self):
        self.store = Store()

    def start_proxy_instance(self, config_name="", **kwargs):
        currentPath = os.getcwd()
        proxy_path = currentPath + "/testsuite/WMP/OAM/LTE3663/SASSim"
        if config_name == "":
            config_name = proxy_path + "/HttpProxy.conf"
        serverInstance = ProxyWrap(config_name, proxy_path)
        self.store.add(serverInstance, alias=kwargs.get('alias'))
        self.store.get(alias=kwargs.get('alias')).start_service()
        os.chdir(currentPath)

    def kill_proxy_instance(self, **kwargs):
        self.store.get(alias=kwargs.get('alias')).kill_service()
        self.store.remove(alias=kwargs.get('alias'))
