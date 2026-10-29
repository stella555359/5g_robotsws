"""
Collector of tcpdump. Implements common log collector API.

:copyright: Nokia
:author: adam.kropiwnicki@nokia.com
:maintainer: adam.kropiwnicki@nokia.com
"""

from pathlib import Path
from shutil import copy, rmtree

from taf.collectors.tcpdump import tcpdump

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.connections import \
    ConnectionManager
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.testline_conf import \
    TestlineConfiguration

from .log_collector import LogCollector

_tcpdump = tcpdump()
_cm = ConnectionManager()
_tl = TestlineConfiguration()


class TcpdumpLogCollector(LogCollector):
    def __init__(self, alias="tcpdump"):
        super(TcpdumpLogCollector, self).__init__(alias=alias)
        self._start_cmd = "tcpdump -i {} {} -w {}"
        self._stop_cmd = "kill -2 $(ps -ef | grep [t]cpdump | grep '{}' | awk '{}')"
        self._interface = "any"
        self._filter = "sctp"
        self._remote_filepath = "/tmp/tcpdump.pcap"
        self._log_postfix = "_tcpdump"
        self._log_extension = ".pcap"
        self._options = "-i any sctp port \\(36412 or 36422 or 38412 or 38422 or 38462 or 38472\\) -c 250000"
        self._executor = None

    def setup(self):
        _tcpdump.create_tcpdump_collector(name=self.alias, options=self._options, executor=self.executor)
        _tcpdump.setup_collectors(names=self.alias)

    def start_log_collecting(self):
        _tcpdump.start_collectors(names=self.alias)
        _tcpdump.set_suite_alias(self.alias)

    def stop_log_collecting(self):
        _tcpdump.stop_collectors(names=self.alias)

    def download_log(self, filepath):
        _tcpdump.collect_collectors(names=self.alias, target_dir="/tmp")
        filepath = self._prepare_log_name(filepath)
        target_dir = Path("/tmp") / self.alias
        copy(target_dir / f"{self.alias}.pcap", filepath)
        rmtree(target_dir)
        return filepath

    def shutdown(self):
        _tcpdump.teardown_collectors(names=self.alias)


class X2APLogCollector(TcpdumpLogCollector):
    def __init__(self):
        super(X2APLogCollector, self).__init__()
        self.executor = unify_connection_details(_tl.get_gnb_ssh_connection_details())
        self._remote_filepath = "/tmp/tcpdump_nsa.pcap"
        self._log_postfix = "_tcpdump_nsa.pcap"
        self.alias = "tcpdump_nsa"


class NGAPLogCollector(TcpdumpLogCollector):
    def __init__(self):
        super(NGAPLogCollector, self).__init__()
        self.executor = unify_connection_details(_tl.get_gnb_ssh_connection_details())
        self._remote_filepath = "/tmp/tcpdump_sa"
        self._log_postfix = "_tcpdump_sa"
        self.alias = "tcpdump_sa"


def unify_connection_details(details):
    return {"host": details["hostname"], "user": details["username"], "password": details["password"]}
