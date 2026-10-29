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


class MantarayScripts(object):
    def __init__(self):
        self.netact = netact()
        tl = get_builtin_value(param_name="tl")
        self.cmwas_node_ip = tl.nms.netact[0].ssh_connections_info.addr
        self.cmwas_passwd = tl.nms.netact[0].ssh_connections_info.password
        self.cmwas_username = tl.nms.netact[0].ssh_connections_info.username

    @connect_disconnect_netact
    def get_netact_counters(self, technology, measurement, netact_counters, filter_by,
                            mo_names, object_aggregation, time_aggregation, time_filter, look_back_period):
        """
            Perform on-the-fly report and return PM counters statistics.
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
