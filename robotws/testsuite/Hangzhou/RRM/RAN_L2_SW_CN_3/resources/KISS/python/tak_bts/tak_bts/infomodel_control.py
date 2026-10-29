# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Lily Xu
:contact: lily.l.xu@nokia.com
:maintainer: I_EXT_MBB_GLOBAL_LTE_TDD_CITA_KISS_GMS
:contact: I_EXT_MBB_GLOBAL_LTE_TDD_CITA_KISS@internal.nsn.com
"""


from ute_admin_infomodel import ute_admin_infomodel
from ute_common_store import Store
from ute_common_converter.to_number import to_int
import logging
import importlib
import time
import six
from tak_config import *
from robot.libraries.BuiltIn import BuiltIn


class InfomodelControl(object):

    def __init__(self):
        self._log = logging.getLogger(__name__)
        self._log.setLevel(logging.DEBUG)
        self.store = Store()
        self.ute_admin_infomodel = ute_admin_infomodel()
        self.robot_builtin_keywords = BuiltIn()
        self.im_dist_group = importlib.import_module('tak_bts.tak_bts.resources.IM_NODE')

    def _setup(self, alias, timeout=30, remote_host=None, port=3600):
        """Setup infomodel and connect infomodel"""
        start_time = time.time()
        while time.time() - start_time < timeout:
            try:
                self.ute_admin_infomodel.setup_infomodel(remote_host=remote_host, port=port, alias=alias)
                self.ute_admin_infomodel.connect_infomodel(alias=alias)
                new_time_out = int(timeout - (time.time() - start_time))
                self._log.debug('new_time_out after connect infomodel %s' % new_time_out)
                return new_time_out
            except Exception:
                self.ute_admin_infomodel.teardown_infomodel(alias=alias)
                time.sleep(2)
        if time.time() - start_time >= timeout:
            raise Exception("Can't connect infomodel within a given time")

    def _teardown(self, alias):
        """Disconnect infomodel and teardown infomodel"""
        self.ute_admin_infomodel.disconnect_infomodel(alias=alias)
        self.ute_admin_infomodel.teardown_infomodel(alias=alias)

    def bts_should_be_onair(self, timeout=600, remote_host=None, port=3600, alias='bts'):
        """Check bts until onair with infomodel.

        :param int timeout: Onair max duration when check in infomodel
        :param string remote_host: remote host ip address
        :param int port: AdminAPI port
        :param string alias: Name of execution context
        :return: True
        :raises: Default bts dist name can't be found or InfoModelQueryTimeoutException

        :note: The infomodel node used in this keyword is defined in IM_NODE.py.
               There is a default IM_NODE.py in the package , and can also use
               customized file with the same parameters name, details refer to example.

        """
        timeout = int(timeout)
        bts_dist_name = self._get_defined_value('IM_BTS_ONAIR')
        try:
            new_time_out = self._setup(timeout=timeout, alias=alias, remote_host=remote_host, port=port)
            self._check_bts_onair_with_given_dist(bts_dist_name=bts_dist_name, timeout=new_time_out, alias=alias)
            return True
        except Exception as e:
            self.ute_admin_infomodel.save_infomodel_log(filename='{}/BtsOnair.ims2'.format(kiss_debug_log_directory()),
                                                        alias=alias)
            raise Exception(e)
        finally:
            self._teardown(alias=alias)

    def cell_should_be_onair(self, timeout=600, remote_host=None, port=3600, alias='cell'):
        """Check cell until onair with infomodel

        :param int timeout: Onair max duration when check in infomodel
        :param string remote_host: remote host ip address
        :param int port: AdminAPI port
        :param string alias: Name of execution context
        :return: True
        :raises: Default cell dist name can't be found or InfoModelQueryTimeoutException

        :note: The infomodel node used in this keyword is defined in IM_NODE.py.
               There is a default IM_NODE.py in the package , and can also use
               customized file with the same parameters name, details refer to example.
        """
        timeout = int(timeout)
        cell_dist_name = self._get_defined_value('IM_CELL_ONAIR')
        try:
            new_time_out = self._setup(timeout=timeout, alias=alias, remote_host=remote_host, port=port)
            self._check_cell_onair_with_given_dist(cell_dist_name=cell_dist_name, timeout=new_time_out, alias=alias)
            return True
        except Exception as e:
            self.ute_admin_infomodel.save_infomodel_log(filename='{}/BtsOnair.ims2'.format(kiss_debug_log_directory()),
                                                        alias=alias)
            raise Exception(e)
        finally:
            self._teardown(alias=alias)

    def _check_bts_onair_with_given_dist(self, bts_dist_name, timeout, alias):
        if isinstance(bts_dist_name, six.string_types):
            query = 'every %s' % bts_dist_name
            self._log.debug(query)
            return self.ute_admin_infomodel.query_infomodel(query=query, timeout=timeout, alias=alias)
        elif isinstance(bts_dist_name, list):
            return self._query_infomodel_within_timeout(bts_dist_name, timeout, alias)
        else:
            raise Exception('The value type of IM_BTS_ONAIR should be string or list.')

    def _check_cell_onair_with_given_dist(self, cell_dist_name, timeout, alias):
        if isinstance(cell_dist_name, six.string_types):
            query = 'every %s' % cell_dist_name
            self._log.debug(query)
            return self.ute_admin_infomodel.query_infomodel(query=query, timeout=timeout, alias=alias)
        elif isinstance(cell_dist_name, list):
            return self._query_infomodel_within_timeout(cell_dist_name, timeout, alias)
        else:
            raise Exception('The value type of IM_CELL_ONAIR should be string or list.')

    def _query_infomodel_within_timeout(self, dist_name, timeout, alias):
        total_check_time = timeout
        while total_check_time > 0:
            for item in dist_name:
                query = 'every %s' % item
                self._log.debug(query)
                try:
                    return self.ute_admin_infomodel.query_infomodel(query=query, timeout=3, alias=alias)
                except Exception as e:
                    self._log.debug(e)
                total_check_time -= 3
        raise Exception('[Warning] Timeout. Do not check in onair status.')

    def enb_get_physical_cell_id(self, cell_index, timeout=20, remote_host=None, port=3600, alias='phycell', **kwargs):
        """Get physical cellid in enb.

        :param cell_index: Cell index: Start from 1
        :param int timeout: Onair max duration when check in infomodel
        :param string remote_host: remote host ip address
        :param int port: AdminAPI port
        :param string alias: Name of execution context

        :return: enb phycell id

        :note: The infomodel node used in this keyword is defined in IM_NODE.py.
               There is a default IM_NODE.py in the package , and can also use
               customized file with the same parameters name, details refer to example.
        """
        timeout = int(timeout)
        try:
            new_timeout = self._setup(timeout=timeout, alias=alias, remote_host=remote_host, port=port)
            dist_name = self._get_lncell_dist_name(cell_index=cell_index, timeout=new_timeout, alias=alias)
            obj = self._get_infomodel_object(dist_name=dist_name, timeout=new_timeout, alias=alias)
            return to_int(obj.phyCellId)
        finally:
            self._teardown(alias=alias)

    def enb_get_cell_number(self, timeout=20, remote_host=None, port=3600, alias='cellnum', **kwargs):
        """Get total cell number in enb.

        :param int timeout: Onair max duration when check in infomodel
        :param string remote_host: remote host ip address
        :param int port: AdminAPI port
        :param string alias: Name of execution context
        :return: cell number

        :note: The infomodel node used in this keyword is defined in IM_NODE.py.
               There is a default IM_NODE.py in the package , and can also use
               customized file with the same parameters name, details refer to example.
        """
        dist_name = self._get_defined_value('IM_PHY_CELL_ID')
        timeout = int(timeout)
        try:
            new_timeout = self._setup(timeout=timeout, alias=alias, remote_host=remote_host, port=port)
            number = to_int(self._cell_number_get_count(dist_name=dist_name, timeout=new_timeout, alias=alias))
            if number == 0:
                self.ute_admin_infomodel.save_infomodel_log('{}/GetPhyCellNumber.ims2'
                                                            .format(kiss_debug_log_directory()), alias=alias)
                raise Exception("Cell Number is 0.")
            return number
        finally:
            self._teardown(alias=alias)

    def _get_infomodel_object(self, dist_name, timeout, alias):
        """get infomodel object by dist name
        """
        self._log.debug(dist_name)
        try:
            object = self.ute_admin_infomodel.get_infomodel_object(dist_name=dist_name, timeout=timeout, alias=alias)
            return object
        except Exception as e:
            self._log.info(e)
            self.ute_admin_infomodel.save_infomodel_log('{}/GetPhyCellId.ims2'.format(kiss_debug_log_directory()),
                                                        alias=alias)
            raise Exception('Get fail! Check {} whether exist.'.format(dist_name))

    def _cell_number_get_count(self, dist_name, timeout, alias):
        """get the count as the given dist name
        """
        if isinstance(dist_name, six.string_types):
            query = "get count {}* is [phyCellId != '']".format(dist_name)
            self._log.debug(query)
            return self.ute_admin_infomodel.query_infomodel(query=query, timeout=timeout, alias=alias)
        elif isinstance(dist_name, list):
            return self._get_dist_count_number_within_timeout(dist_name, timeout, alias)
        else:
            raise Exception('The value type of IM_PHY_CELL_ID should be string or list.')

    def _get_dist_count_number_within_timeout(self, dist_name, timeout, alias):
        total_check_time = timeout
        while total_check_time > 0:
            for item in dist_name:
                query = "get count {}* is [phyCellId != '']".format(item)
                self._log.debug('query command:{}'.format(query))
                number = self.ute_admin_infomodel.query_infomodel(query=query, timeout=3, alias=alias)
                self._log.debug('query result:{}'.format(number))
                if number != 0:
                    return number
                total_check_time -= 3
        self._log.info('[Warn] Timeout, do not get the cell number.')
        return 0

    def _get_defined_value(self, key):
        """Get the value of the key
        """
        value = self.robot_builtin_keywords.get_variable_value("${%s}" % key)
        if value is None:
            self._log.debug('IM node get from tak_bts defined values.')
            return eval('self.im_dist_group.%s' % key)
        else:
            self._log.debug('IM node get from user-defined values.')
            return value

    def _get_lncell_dist_name(self, cell_index, timeout, alias):
        """Get lncell dist_name, such as:/MRBTS-1/RAT-1/LTS-*/LNBTS_L-*/LNCEL_L-1
            or /MRBTS-1/RAT-1/LTS-*/LNBTS_L-*/LNCEL_L-11"""
        dist = self._get_defined_value('IM_PHY_CELL_ID')
        if isinstance(dist, six.string_types):
            query = "get list {}*".format(dist)
            dist_name_list = self.ute_admin_infomodel.query_infomodel(query=query, timeout=timeout, alias=alias)
        elif isinstance(dist, list):
            dist_name_list = self._get_list_within_timeout(dist, timeout, alias)
        else:
            raise Exception("The value type of IM_PHY_CELL_ID should be string or list")

        for dist_name_dict in dist_name_list:
            dist_name = dist_name_dict['dist_name']
            if to_int(dist_name[-1]) == to_int(cell_index):
                return dist_name

    def _get_list_within_timeout(self, dist, timeout, alias):
        total_check_time = timeout
        while total_check_time > 0:
            for item in dist:
                query = "get list {}*".format(item)
                try:
                    dist_name_list = self.ute_admin_infomodel.query_infomodel(query=query, timeout=2, alias=alias)
                    return dist_name_list
                except Exception as e:
                    self._log.debug(e)
                total_check_time -= 2
        raise Exception('[Warn] Timeout, query finish.')

    def get_rru_ip(self, timeout=60, remote_host=None, port=3600, alias='bts'):
        """Get RRU IP list by /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/RMOD_L-*
           sorted by RMOD-*'s number, such as RMOD_1 is first ip,then next

        :param int timeout: Onair max duration when check in infomodel
        :param string remote_host: remote host ip address
        :param int port: AdminAPI port
        :param string alias: Name of execution context
           """

        timeout = int(timeout)

        try:
            new_time_out = self._setup(timeout=timeout, alias=alias, remote_host=remote_host, port=port)
            ret = self.ute_admin_infomodel.query_infomodel(query="get list /MRBTS-1/RAT-1/BTS_L-*/EQM_L-1/RMOD_L-*",
                                                           alias=alias)
            rru_dic = {}
            for k in ret:
                if k['ipAddress'] != '0.0.0.0':
                    rru_dic[int(k['dist_name'].split('-')[-1])] = k['ipAddress']
                    self._log.debug("distname is '%s', IP address is '%s'" % (k['dist_name'], k['ipAddress']))
            sorted(rru_dic.keys())
            self._log.debug('sorted rru dictionary is: %s' % rru_dic)
            return [rru_dic[r] for r in rru_dic.keys()]
        except Exception as e:
            self.ute_admin_infomodel.save_infomodel_log(filename='{}/BtsOnair.ims2'.format(kiss_debug_log_directory()),
                                                        alias=alias)
            raise Exception(e)
        finally:
            self._teardown(alias=alias)
