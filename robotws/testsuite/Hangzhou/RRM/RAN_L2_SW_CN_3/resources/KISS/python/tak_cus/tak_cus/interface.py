# -*- coding: utf-8 -*-
"""
:created on: 01-12-2023

:copyright: Nokia
:author: Lily Xu
:contact: lily.l.xu@nokia-sbell.com
"""

import logging
from ute_common_store import Store
from ute_common_store.exception import AliasError
from .cus import Cus
from .cus_files import CusFiles


class tak_cus(CusFiles):

    ROBOT_LISTENER_API_VERSION = 2
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self):
        self._log = logging.getLogger(__name__)
        self.store = Store()
        self.ROBOT_LIBRARY_LISTENER = self
        self.cus_obj = Cus()
        CusFiles.__init__(self)

    def cus_execute_cus_command(self, cmd, prompt="CUS>", prompt_is_regexp=False):
        """ Execute cus command

        :param cmd: command
        :return: command execution output
        """

        return self.cus_obj.execute_cus_command(cmd, prompt, prompt_is_regexp)

    def cus_execute_uex_command(self, cmd):
        """ Execute uexgate command

        :param cmd: command
        :return: command execution output
        """

        return self.cus_obj.execute_uex_command(cmd)

    def cus_attach(self, ue_id_list, cell_id_list=1, interval=0.5, timeout=20, retry=0, ue_eutra_capabilities=None,
                   enb_id_list=None, selected_plmn=None):
        """ Cus Attach, support multi UEs

        :param ue_id_list: ue_group id for example:"1,3...5,7,9...11"
        :param cell_id_list: Number of comma contains in cell_id_list should be equal to contains in ue_id_list,
        default is 1.
        :param interval: UE attach interval, default is 0.5 second
        :param timeout: timeout, default is 20 seconds
        :param retry: not used now
        :param ue_eutra_capabilities: ue_eutra_capabilities
        :param enb_id_list: Number of comma contains in enb_id_list should be equal to contains in ue_id_list,
        default is None.
        :param selected_plmn: Use specified PLMN ID instead of PLMN ID from IMSI
        :return: no return value
        """

        self.cus_obj.attach(ue_id_list, cell_id_list, float(interval), timeout, retry, ue_eutra_capabilities,
                            enb_id_list, selected_plmn)

    def cus_detach(self, ue_id_list, interval=0.5):
        """ Cus Detach, support multi UEs

        :param ue_id_list: ue_group id for example:"1,3...5,7,9...11"
        :param interval: UE detach interval, default is 0.5 second
        :return: no return value
        """

        self.cus_obj.detach(ue_id_list, float(interval))

    def cus_all_detach(self, interval=0.5):
        """ Detach all active and idle cus

        :param interval: UE detach interval, default is 0.5 second
        :return: no return value
        """

        self.cus_obj.detach_all(float(interval))

    def cus_start_ul_udp_data_traffic(self, ue_id_list, through_put, **kwargs):
        """ Start uplink udp data traffic.

        :param ue_id_list: ue group id, for example 1,3,4,5 or 1,3...5,8...9,11
        :param through_put: throughput value, Desired data transfer throughput, '10 Mbits/sec'
                            or '500Bytes/sec' or '500'(=500Kbits/sec) or '30M'(=30Mbits/sec) or '30K(=30Kbits/sec)
        |
        - units of through_put:
                    - bits/sec        range:56-175000000
                    - Kbits/sec       range:1-175000
                    - Mbits/sec       range:1-175
                    - Bytes/sec
                    - KBytes/sec
                    - MBytes/sec
            Note: conversion rate is equal to 1000.
        :param kwargs: variable parameter, support such as trf_id=1 bearer=5
        """

        self.cus_obj.start_data_traffic(ue_id_list, through_put, 'ul', 'udp', **kwargs)

    def cus_get_ul_throughput_ave(self, ue_id, type, unit='kbps'):
        """ Get ul average throughput

        :param ue_id: UE ID
        :param type: Statistics type, such as: ul_mac, ul_rlc, ul_pdcp
        :param unit: Unit in which throughput statistics will be returned, such as: bps, kbps, Mbps, Gbps, default kbps
        :return: rtype is float with .2f, value is throughput, unit is the same with unit parameter, default is kbps.
        """

        return self.cus_obj.get_throughput_ave(ue_id, type, unit)

    def cus_stop_ul_udp_data_traffic(self, ue_id_list, **kwargs):
        """ Stop udp data traffic. data traffic type is UL.

        :param ue_id_list: ue group id, for example 1,3,4,5 or 1,3...5,8...9,11
        :param kwargs: variable parameter, support such as trf_id=1 bearer=5
        """

        self.cus_obj.stop_data_traffic(ue_id_list, 'ul', **kwargs)

    def cus_start_dl_udp_data_traffic(self, ue_id_list, through_put, **kwargs):
        """ Start downlink udp data traffic.

        :param ue_id_list: ue group id, for example 1,3,4,5 or 1,3...5,8...9,11
        :param through_put: throughput value, Desired data transfer throughput, '10 Mbits/sec'
                            or '500Bytes/sec' or '500'(=500Kbits/sec) or '30M'(=30Mbits/sec) or '30K(=30Kbits/sec)
        |
        - units of through_put:
                    - bits/sec        range:56-175000000
                    - Kbits/sec       range:1-175000
                    - Mbits/sec       range:1-175
                    - Bytes/sec
                    - KBytes/sec
                    - MBytes/sec
            Note: conversion rate is equal to 1000.
        :param kwargs: variable parameter, support such as trf_id=1 bearer=5
        """

        self.cus_obj.start_data_traffic(ue_id_list, through_put, 'dl', 'udp', **kwargs)

    def cus_get_dl_throughput_ave(self, ue_id, type, unit='kbps'):
        """ Get dl average throughput

        :param ue_id: UE ID
        :param type: Statistics type, such as: dl_mac, dl_rlc, dl_pdcp
        :param unit: Unit in which throughput statistics will be returned, such as: bps, kbps, Mbps, Gbps, default kbps
        :return: rtype is float with .2f, value is throughput, unit is the same with unit parameter, default is kbps.
        """

        return self.cus_obj.get_throughput_ave(ue_id, type, unit)

    def cus_stop_dl_udp_data_traffic(self, ue_id_list, **kwargs):
        """ Stop udp data traffic. data traffic type is DL.

        :param ue_id_list: ue group id, for example 1,3,4,5 or 1,3...5,8...9,11
        :param kwargs: variable parameter, support such as trf_id=1 bearer=5
        """

        self.cus_obj.stop_data_traffic(ue_id_list, 'dl', **kwargs)

    def cus_get_throughput_on_specific_scell(self, ue_id, type, scell_id=0, tput_type='avg'):
        """ Get cus throughput on specific scell(ue level).

        :param ue_id: UE ID
        :param type: the type, such as:dl_mac
        :param scell_id: the identification of cell. Default is 0. 0:PCell 1:Scell-1 2:Scell-2
        :param tput_type: the type of throughput. Default is 'avg'. Support : avg, max, min, cur
        :return: rtype is float with .2f, return value is throughput, unit is Kbps
        """

        return self.cus_obj.get_throughput_on_specific_scell(ue_id, type, scell_id, tput_type)

    def cus_create_bearer(self, ue_id_list, qci_id_list, **kwargs):
        """ Activates bearers for UE, the same with bearer_add uexgate command

        :param ue_id_list: ue group id, for example 1,3,4,5 or 1,3...5,8...9,11
        :param qci_id_list: QoS Class Identifier, 1..9 | 128..254
        :param kwargs: variable parameters, support such as: mbr_ul=2048 mbr_dl=2048 gbr_ul=2048 gbr_dl=2048
        :return: no return value
        """

        self.cus_obj.create_bearer(ue_id_list, qci_id_list, **kwargs)

    def cus_get_througput_for_each_bearer(self, ue_id, direction, bearer_id=None, tput_type="avg"):
        """ Get average throughput for each bearer

        :param ue_id: UE id
        :param direction: direction, dl or ul
        :param bearer_id: bearer id, default is None
        :param tput_type: support avg, cur, max or min, default is avg
        :return: if no bearer id is specified, return throughput for all bearers; if it is specified, return throughput
        for specified bearer. unit is mbps.
        """
        return self.cus_obj.get_througput_for_each_bearer(ue_id, direction, bearer_id, tput_type)

    def cus_verify_that_average_throughput_for_each_bearer_is_on_target(self, ue_id, direction, throughput_target):
        """ Verify average throughput for specified bearer reach target*0.9

        :param ue_id: UE id
        :param direction: direction, dl or ul
        :param throughput_target: throughput target
        :return: it will raise AssertionError if not reach 0.9*target
        """
        self.cus_obj.verify_that_average_throughput_for_each_bearer_is_on_target(ue_id, direction, throughput_target)

    def cus_get_ul_throughput(self, ue_id, stat_type, tput_type='avg', unit='kbps'):
        """ Get ul throughput

        :param ue_id: UE ID
        :param stat_type: Statistics type, such as: ul_mac, ul_rlc, ul_pdcp
        :param tput_type: throughput type, such as: avg, cur, max, min
        :param unit: Unit in which throughput statistics will be returned, such as: bps, kbps, Mbps, Gbps, default kbps
        :return: rtype is float with .2f, value is throughput, unit is the same with unit parameter, default is kbps.
        """

        return self.cus_obj.get_throughput(ue_id, stat_type, tput_type, unit)

    def cus_get_dl_throughput(self, ue_id, stat_type, tput_type='avg', unit='kbps'):
        """ Get dl throughput

        :param ue_id: UE ID
        :param stat_type: Statistics type, such as: dl_mac, dl_rlc, dl_pdcp
        :param tput_type: throughput type, such as: avg, cur, max, min
        :param unit: Unit in which throughput statistics will be returned, such as: bps, kbps, Mbps, Gbps, default kbps
        :return: rtype is float with .2f, value is throughput, unit is the same with unit parameter, default is kbps.
        """

        return self.cus_obj.get_throughput(ue_id, stat_type, tput_type, unit)

    def cus_get_cell_throughput(self, cell_id, stat_type, tput_type='avg', unit='Mbps'):
        """

        :param cell_id: Cell ID
        :param stat_type: Statistics type, such as: ul_mac, ul_rlc, ul_pdcp, dl_mac, dl_rlc, dl_pdcp
        :param tput_type: throughput type, such as: avg, cur, max, min
        :param unit: Unit in which throughput statistics will be returned, such as: bps, kbps, Mbps, Gbps, default Mbps
        :return: rtype is float with .2f, value is throughput, unit is the same with unit parameter, default is Mbps
        """
        return self.cus_obj.get_cell_throughput(cell_id, stat_type, tput_type, unit)
