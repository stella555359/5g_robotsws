# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Adrianna Pienkowska, Beata Kapusta
:maintainer:  Adrianna Pienkowska, Beata Kapusta
:contact: adrianna.pienkowska@nokia.com, beata.kapusta@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
"""
import six
import time
import json
import urllib3
from functools import wraps
from contextlib import contextmanager
from abc import ABCMeta, abstractmethod

from robot.libraries.BuiltIn import BuiltIn
from taf.gnb.oam.coam.cu.exception import AuthenticationFailed
from taf.internal.gnb.oam.coam.cu.client.asm.v1.exceptions import ApiException as cuException
from taf.internal.gnb.oam.coam.vdu.client.asm.v1.exceptions import ApiException as duException

from testsuite.Paris.RRM.ET.resources_KRK.python.utilities import logger_console

AICCommonException = (cuException, duException)
ConnectionError = (OSError, urllib3.exceptions.NewConnectionError, urllib3.exceptions.ProtocolError,
                   urllib3.exceptions.MaxRetryError, AuthenticationFailed, UnboundLocalError)


def _plan_exist_error(api_error):
    """
    Raises error if plan exists

    :param api_error: api error
    :return: True, if plan already exists, False otherwise
    """
    if "Plan name already exists" in str(api_error):
        return True
    if "reach to the maximum plan number 1" in str(api_error):
        return True
    return False


def _mo_doesnt_exist_error(api_error):
    """
    Raises error if MO doesn't exists

    :param api_error: api error
    :return: True, if plan already exists, False otherwise
    """
    if "Invalid change parameters: empty mo uuid" in str(api_error):
        return True


def read_delta_json_file(file_path):
    """
    Read delta json file

    :param file_path: path to the file
    :return: data from json file
    """
    with open(file_path) as f:
        return json.load(f)


def sleep(msg, period):
    """
    Sleeps for period due to some action

    :param msg: message of action
    :param period: period of time
    :return: nothing
    """
    logger_console('Will sleep for {}s due to *{}*'.format(period, msg))
    time.sleep(period)


@six.add_metaclass(ABCMeta)
class AIC:
    """
    All in Cloud class
    """

    @abstractmethod
    def __init__(self, interface):
        self.port = 443
        self.secure = True
        self.interface = interface

    @property
    def _connection_args(self):
        _connection_args = self.__dict__.copy()
        _connection_args.pop('interface')
        return _connection_args

    @_connection_args.setter
    def _connection_args(self, interface):
        self.interface = interface

    @contextmanager
    def admin_session(self):
        while True:
            try:
                self.interface.connect_to(**self._connection_args)
                break
            except ConnectionError:
                sleep('Wait for connection to {}'.format(self.__str__()), 60)
        try:
            yield self.interface
        finally:
            self.interface.disconnect()

    def handle_admin(self, func):
        @wraps(func)
        def wrapper(**kwargs):
            while True:
                try:
                    connection_args = self._connection_args
                    with self.interface(**connection_args) as connection:
                        result = func(connection=connection, **kwargs)
                        break
                except ConnectionError as error:
                    sleep('Wait for connection', 60)
            return result
        return wrapper

    @abstractmethod
    def reboot_unit(self):
        pass

    @abstractmethod
    def _parse_delta_distname(self, distname_data):
        """
        Parse delta distname

        :param distname_data: (str) distname data
        """
        pass

    @abstractmethod
    def _add_mo_object(self, dist_info, add_fun):
        """
        Adds MO object

        :param dist_info: the mo distName that contains the parameter like MRBTS-3218/NRBTS-1/NRCELL-1
        :param add_fun: add_fun
        """
        pass

    def generate_delta_plan(self, generate_fun, delete_fun, info_list_fun):
        """
        Generates delta plan

        :param generate_fun: generate fun
        :param delete_fun: delete_fun
        :param info_list_fun: info list fun
        :return: output of generate fun()
        """
        try:
            out = generate_fun(plan_name='delta_plan')
        except AICCommonException as api_error:
            if _plan_exist_error(str(api_error)):
                self._delete_all_existing_delta_plans(delete_fun, info_list_fun)
                out = generate_fun(plan_name='delta_plan')
            else:
                raise api_error
        time.sleep(10)
        return out

    def upload_params(self, delta_path, update_fun, add_fun, check_fun):
        """
        Updates parameter

        :param delta_path: (str) path to delta file
        :param update_fun: update_fun
        :param add_fun: add_fun
        :param check_fun: check_fun
        :return: nothing
        """
        delta_file = read_delta_json_file(delta_path)
        for distname in delta_file:
            dist_info = self._parse_delta_distname(distname)
            if distname['operation'] == 'add':
                self._add_mo_object(dist_info, add_fun)
            update = update_fun(plan_id='dp_00000000', **dist_info)
            time.sleep(1)
            update = check_fun(plan_id='dp_00000000', action_id=update['action_id'])
            if update['status'] == 'ongoing':
                time.sleep(5)
                update = check_fun(plan_id='dp_00000000', action_id=update['action_id'])
            assert update['status'] == 'success', "FAILED TO UPDATE {}: {}\n{}".format(
                distname['distName'], distname['parameters'], update)

    @staticmethod
    def _delete_all_existing_delta_plans(delete_fun, info_list_fun):
        """
        Delete all existing delta plans

        :param delete_fun: delete fun
        :param info_list_fun: info list fun
        :return: nothing
        """
        all_plan_list = info_list_fun()
        for plan in all_plan_list:
            delete_fun(plan['plan_id'])
