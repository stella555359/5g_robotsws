from functools import wraps
from datetime import datetime
from taf.nms.netact.interface import netact
from taf.rfrl.utilities.robot.general import get_builtin_value
import re


def connect_disconnect_netact(netact_function):
    @wraps(netact_function)
    def wrapper(self, *args, **kwargs):
        self.netact.add_node('cmwas', self.cmwas_node_ip, self.cmwas_username,
                             self.cmwas_passwd)
        netact_url = "https://{}/authentication/Login".format(self.netact.detect_web_url())
        self.netact.add_web_url(netact_url, self.cmwas_username, self.cmwas_passwd)
        try:
            result = netact_function(self, *args, **kwargs)
            return result
        finally:
            self.netact.delete_node('cmwas')
            self.netact.clean_all()
    return wrapper


class NetactScripts(object):
    def __init__(self):
        self.netact = netact()
        tl = get_builtin_value(param_name="tl")
        self.cmwas_node_ip = tl.nms.netact[0].https_main_info.addr
        self.cmwas_passwd = tl.nms.netact[0].https_main_info.password
        self.cmwas_username = tl.nms.netact[0].https_main_info.username

    @connect_disconnect_netact
    def get_netact_counters(self, technology, measurement, netact_counters, filter_by,
                            mo_names, object_aggregation, time_aggregation, time_filter, look_back_period):
        """
            Perform on-the-fly report and return PM counters statistics.

            :param string technology: Technology name, e.g., ``LNBTS-NSN LTE Base Transceiver Station``
            :param string measurement: Measurement name, e.g., ``LTE Cell Availability``
            :param string|list(string) netact_counters: Counter identifier(s), e.g.,
                ``CHNG_TO_CELL_AVAIL`` or ``['CHNG_TO_CELL_AVAIL', 'CHNG_TO_CELL_PLAN_UNAVAIL']``.
                Accepts also ``ALL`` what means all counters of the set ``measurement``.
            :param string filter_by: Item from `Filter by` list at `Object selection` stage
                of `Add To New Board` wizard, e.g., ``MRBTS``.
            :param string|list(string) mo_names: Managed object name(s), e.g., ``PLMN-PLMN/MRBTS-1``
                or ``['PLMN-PLMN/MRBTS-1', 'PLMN-PLMN/MRBTS-2']``.
                Item from `Available objects` list at `Object selection` stage of `Add To New Board` wizard.
            :param string object_aggregation: Object aggregation name, e.g., ``PLMN/MRBTS``.
                Item from `Object` list at `Aggregation` stage of `Add To New Board` wizard.
            :param string time_aggregation: Time aggregation name, e.g., ``RAW``.
                Item from `Time` list at `Aggregation` stage of `Add To New Board` wizard.
            :param string time_filter: Corresponds to `Time selection` stage of `Add To New Board` wizard.
                Allowed value: ``relative``, ``absolute``, ``realtime``, ``today``, ``currentMonth``
                or ``previousMonth``.
            :param int look_back_period: Mandatory for ``realtime`` time filter (in minutes).

                Example output::

                    [
                        {
                            'CHNG_TO_CELL_AVAIL': 1.0,
                            'CHNG_TO_CELL_PLAN_UNAVAIL': 1.0,
                            'dn': 'PLMN-PLMN/MRBTS-1/LNBTS-1/LNCEL-1',
                            'lnbts_name': '1',
                            'lncel_gid': '100011',
                            'lncel_name': '1',
                            'mrbts_name': '1',
                            'period_start_time': '2022-02-22 09:00:00.0'
                        },
                        {
                            'CHNG_TO_CELL_AVAIL': 0.0,
                            'CHNG_TO_CELL_PLAN_UNAVAIL': 1.0,
                            'dn': 'PLMN-PLMN/MRBTS-1/LNBTS-1/LNCEL-2',
                            'lnbts_name': '1',
                            'lncel_gid': '100012',
                            'lncel_name': '2',
                            'mrbts_name': '1',
                            'period_start_time': '2022-02-22 09:00:00.0'
                        },
                        {
                            'CHNG_TO_CELL_AVAIL': 1.0,
                            'CHNG_TO_CELL_PLAN_UNAVAIL': 2.0,
                            'dn': 'PLMN-PLMN/MRBTS-1/LNBTS-1/LNCEL-3',
                            'lnbts_name': '1',
                            'lncel_gid': '100013',
                            'lncel_name': '3',
                            'mrbts_name': '1',
                            'period_start_time': '2022-02-22 09:00:00.0'
                        }
                    ]

            :return: PM counters statistics.
            :rtype: list(dict)
        """
        netact_counters = self.netact.get_pm_counters(technology=technology,
                                                      measurement=measurement,
                                                      counters=netact_counters,
                                                      filter_by=filter_by,
                                                      mo_names=mo_names,
                                                      object_aggregation=object_aggregation,
                                                      time_aggregation=time_aggregation,
                                                      time_filter=time_filter,
                                                      look_back_period=look_back_period)
        return netact_counters
