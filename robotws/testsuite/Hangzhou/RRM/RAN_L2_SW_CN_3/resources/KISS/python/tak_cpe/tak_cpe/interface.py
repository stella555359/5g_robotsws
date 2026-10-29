# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Chen Jin Emily
:contact: jin_emily.chen@nokia.com
:maintainer: I_EXT_MBB_GLOBAL_LTE_TDD_CITA_KISS_GMS
:contact: I_EXT_MBB_GLOBAL_LTE_TDD_CITA_KISS@internal.nsn.com
"""
from ute_common_store import Store
from .ue import Ue


class tak_cpe(object):
    '''
    support cpe type: spark cpe

    '''

    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self):
        self.store = Store()

    def cpe_setup(self, ue_info, alias='ue', **kwargs):
        ''' setup ue
        | Support UE types and ue_info format:
        |    1, spark,  {'type': 'SPARK_CPE', 'address':'10.68.152.99'}
        |
        :param ue_info: dictionary item is 'type' and 'address' for ue infomation
        :param alias: default as 'ue'
        :param frequency: specific the frequency.
        :param band: specific the band.
        '''
        self.ue_info = ue_info
        ue_obj = Ue(ue_info, **kwargs)
        self.store.add(ue_obj, alias)

    def cpe_teardown(self, alias='ue'):
        ''' remove alias
        :param alias: default as 'ue'
        '''

        self.store.remove(alias=alias)

    def cpe_attach(self, alias='ue', **kwargs):
        """send AT command to perform ue attach step.

        :param alias: default as 'ue'
        @param remote_host: remote host ip, default is '127.0.0.1', only support for gct cpe
        @param remote_user: remote host username, default is 'ute', only support for gct cpe

        :return:  attach infomation returned by ue if succeed.
        """
        return self.store.get(alias).attach(**kwargs)

    def cpe_detach(self, alias='ue', **kwargs):
        """send AT command to perform ue detach step.
        :param alias: default as 'ue'
        @param remote_host: remote host ip, default is '127.0.0.1', only support for gct cpe
        @param remote_user: remote host username, default is 'ute', only support for gct cpe
        :return: detach infomation returned by ue if succeed.
        """
        return self.store.get(alias).detach(**kwargs)

    def cpe_get_attach_ip(self, alias='ue', **kwargs):
        """send AT command to get ue attached ip address.
        :param alias: default as 'ue'
        @param remote_host: remote host ip, default is '127.0.0.1', only support for gct cpe
        @param remote_user: remote host username, default is 'ute', only support for gct cpe
        :return: ip address that ue acquired
        """
        return self.store.get(alias).get_ip(**kwargs)

    def cpe_get_status(self, alias='ue', **kwargs):
        """send AT command to get ue attached or detached status.
        | status_type:
        |   1, attach, default value
        |   2, rsrp, get rsrp value, not supported now.
        |   3, rsrq, get rsrq value, not supported now.
        :param alias: default as 'ue'
        @param remote_host: remote host ip, default is '127.0.0.1', only support for gct cpe
        @param remote_user: remote host username, default is 'ute', only support for gct cpe
        :return: Attached or Detached if get status succeed.
        """
        return self.store.get(alias).get_status(**kwargs)

    def cpe_get_btscell_id(self, alias='ue', **kwargs):
        """get ue acquired bts cellid infomation.
        :param alias: default as 'ue'
        @param remote_host: remote host ip, default is '127.0.0.1', only support for gct cpe
        @param remote_user: remote host username, default is 'ute', only support for gct cpe
        :return: bts cell id info.
        """
        return self.store.get(alias).get_btscell_id(**kwargs)

    def cpe_software_reboot(self, alias='ue', **kwargs):
        """send AT command to reboot ue.
        :param alias: default as 'ue'
        @param remote_host: remote host ip, default is '127.0.0.1', only support for gct cpe
        @param remote_user: remote host username, default is 'ute', only support for gct cpe
        :return: True, if run succeed.
        """
        return self.store.get(alias).reboot(**kwargs)

    def cpe_execute_at_command(self, at_cmd, alias='ue', **kwargs):
        """send AT command to ue.

        :param at_cmd: the command need to execute, such as "AT+GETCFG="BAND" or "SendAT"
        :param alias: default as 'ue'
        :param index: such as 'index=1' to specify ue
        :param para: such as 'para={"SuccStr": "", "Command": 'AT+GTRNDIS=0'}' should be a dictionary.
        :return: AT cmd return infomation, if run succeed.
        """
        return self.store.get(alias).execute_at_command(at_cmd, **kwargs)

    def cpe_start_log(self, alias='ue', **kwargs):
        """send AT command to start log
        """
        return self.store.get(alias).start_log(**kwargs)

    def cpe_stop_log(self, alias='ue', **kwargs):
        """send AT command to stop log and export log as csv and xml.
        """
        return self.store.get(alias).stop_log(**kwargs)

    def cpe_collect_log(self, alias='ue', **kwargs):
        """send AT command to stop log and export log as csv and xml.
        @param log_save_folder: log save folder, default as '/tmp'
        @param ue_index: which one need to collect log, default as 'all'
        @param log_type: need log type, 'csv', 'xml', 'txt', 'all', default as 'csv'
        :return: log name list.
        """
        return self.store.get(alias).collect_log(**kwargs)
