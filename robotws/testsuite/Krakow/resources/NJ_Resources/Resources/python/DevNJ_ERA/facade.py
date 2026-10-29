# -*- coding: utf-8 -*-
"""
:author: longmei.zhao
:contact: longmei.zhao@nokia.com
"""
from .ERA.SystemOperation import SystemOperation
from .ERA.SignalDistribution import SignalDistribution
from .ERA.SystemConfiguration import SystemConfiguration
from .ERA.EraLogin import EraLogin
from .ERA.TaskQueue import TaskQueue
from .ERA.CatchException import CatchException


class Era(object):
    def __init__(self, driver):
        self._driver = driver
        self._system_operation = SystemOperation(self._driver)
        self._signal_distribution = SignalDistribution(self._driver)
        self._system_configuration = SystemConfiguration(self._driver)
        self._task_queue = TaskQueue(self._driver)
        self._era_login = EraLogin(self._driver)
        self._catch_exception = CatchException(self._driver)

    @property
    def system_operation(self):
        return self._system_operation

    @property
    def signal_distribution(self):
        return self._signal_distribution

    @property
    def system_configuration(self):
        return self._system_configuration

    @property
    def task_queue(self):
        return self._task_queue

    @property
    def login(self):
        return self._era_login

    @property
    def catch_exception(self):
        return self._catch_exception
