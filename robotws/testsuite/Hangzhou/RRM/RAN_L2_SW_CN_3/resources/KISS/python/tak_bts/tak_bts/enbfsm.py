# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Yonna Yao
:contact: yonna.yao@nokia.com
:maintainer: I_MN_RAN_L2_SW_3_CN_SG9_TA_GMS
:contact: i_mn_ran_l2_sw_3_cn_sg9_ta@internal.nsn.com
"""


from ute_fsmaccess import ute_fsmaccess
import logging
import re


class Enbfsm(object):

    def __init__(self):
        self._log = logging.getLogger(__name__)
        self._log.setLevel(logging.DEBUG)

    def get_bbu_type(self, fsm_ip='192.168.255.1', remote_host="127.0.0.1", timeout=20, **kwargs):
        """Get eNB bbu type.

        :param string fsm_ip:           Ip address of Enb Fsm.
        :param string remote_host:      Ip address or domain name of remote host.
        :param float timeout:           SSH timeout, unit is sec.

        :return:         bbu type.
        :rtype:          string
         """
        self.enbfsm = ute_fsmaccess()
        self.enbfsm.setup_enb_fsm_access(host=fsm_ip, prompt=' >', fallback_prompt='#', timeout=timeout,
                                         remote_host=remote_host, alias='bbu')
        cmd = "cat /proc/device-tree/module-identity/unit-id"
        rrutype = self.enbfsm.execute_command_on_enb(cmd, False, alias='bbu')
        self.enbfsm.teardown_enb_fsm_access(alias='bbu')
        return re.compile('\x00').sub("", rrutype)
