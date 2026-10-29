"""
Collector of tti trace. Implements common log collector API.

:copyright: Nokia
:author: adam.kropiwnicki@nokia.com
:maintainer: adam.kropiwnicki@nokia.com
"""

import re
import subprocess
from pathlib import Path
from shutil import copy, rmtree

from taf.collectors.l2stream3 import l2stream3
from taf.collectors.tcpdump import tcpdump
from taf.config.testline import ClassicalBts, TestPc

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.connections import \
    ConnectionManager
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.testline_conf import \
    TestlineConfiguration

from .log_collector import LogCollector

_tcpdump = tcpdump()
_tti_collector = l2stream3()
_cm = ConnectionManager()
_tl = TestlineConfiguration()


class TTILogCollector(LogCollector):
    """
    TTI collector based on taf.collectors.l2stream3; Output file is in .pcap format.
    """

    def __init__(self, test_pc: TestPc = None, gnb: ClassicalBts = None, alias: str = "tti") -> None:
        """
        :param taf.config.testline.testpc.TestPc test_pc: PC on which to collect TTI trace. When not specified,
                                                          attepmt to discover tl.test_pc object from init file.
        :param taf.config.testline.gnb.ClassicalBts gnb: GNB object from which TTI trace will be collected.
                                                         When not specified, attempt to discover tl.gnbs[0] from
                                                         init file.
        :param str alias: Collector alias
        :param taf.config.testline
        """
        super(TTILogCollector, self).__init__(alias=alias)
        self._testpc_ssh_config = None
        self._test_pc = test_pc
        self._gnb = gnb
        self._remote_filepath = "/tmp/tcpdump.pcap"
        self._log_postfix = "_tcpdump"
        self._log_extension = ".pcap"
        self._options = "-i {} port 5678"

        self._cell_dns = None
        self._executor = None
        self._tcpdump_alias = f"tcpump_{self.alias}"
        self._tti_alias = f"tti_{self.alias}"

    def setup(self) -> None:
        """
        Sets up required internal taf.collectors
        """
        self._test_pc = self._test_pc or _tl.tl_init.test_pc
        self._gnb = self._gnb or _tl.tl_init.gnbs[0]
        self._testpc_ssh_config = {
            "host": self._test_pc.default_ssh_connection_details.addr,
            "user": self._test_pc.default_ssh_connection_details.username,
            "password": self._test_pc.default_ssh_connection_details.password,
        }

        interface_name = self._identify_interface_with_ip(self._testpc_ssh_config["host"])
        options = self._options.format(interface_name)

        _tcpdump.create_tcpdump_collector(name=self._tcpdump_alias, options=options, executor=self._testpc_ssh_config)

        executor = {
            "host": self._gnb.dus[0].airscale.common_units[0].lmp_connection.addr,
            "user": self._gnb.cu.oam_http_connection_details.username,
            "password": self._gnb.cu.oam_http_connection_details.password,
            "port": 443,
        }
        l2_stream_config_1 = {"nr_cell_dns": self._cell_dns}
        l2_stream_configuration = [l2_stream_config_1]
        _tti_collector.create_sbts_l2stream_collector(
            name=self._tti_alias,
            webservice=executor,
            destination_ip_addr=self._testpc_ssh_config["host"],
            collector=self._tcpdump_alias,
            l2_stream_configuration=l2_stream_configuration,
        )
        _tti_collector.setup_collectors(names=self._tti_alias)

    def set_logging_filter(self, filtering: str | list[str]) -> None:
        """
        Set filtering to only include traces from specified cells
        :param [str / list] filtering: Distname/distnames of cells
        """
        if isinstance(filtering, list):
            self._cell_dns = filtering
        else:
            self._cell_dns = [filtering]

    def start_log_collecting(self) -> None:
        _tti_collector.start_collectors(names=self._tti_alias)
        _tti_collector.set_suite_alias(self._tti_alias)

    def stop_log_collecting(self) -> None:
        _tti_collector.stop_collectors(names=self._tti_alias)

    def download_log(self, filepath: str) -> str:
        """
        Download collected log into the specified filepath
        :param str filepath: Filepath for the output log file. Cannot be a directory. If
                             path provided does not end with .pcap file extension, it is appended at the end.
        :returns str: Path to downloaded file.
        """
        _tti_collector.collect_collectors(names=self._tti_alias, target_dir="/tmp")
        filepath = self._prepare_log_name(filepath)
        log_dir = Path("/tmp") / self._tti_alias
        copy(log_dir / self._tcpdump_alias / f"{self._tcpdump_alias}.pcap", filepath)
        rmtree(log_dir)
        return filepath

    def shutdown(self) -> None:
        _tti_collector.teardown_collectors(names=self._tti_alias)

    def _identify_interface_with_ip(self, ip):
        output = str(subprocess.run(["ip", "-o", "-4", "addr", "show"], capture_output=True).stdout, encoding="utf-8")
        ip = ip.replace(".", "\\.")
        interface_name = re.search(rf"^\d+:\s(\S+).*{ip}.*$", output, re.M)
        if interface_name is None:
            raise ValueError(f"could not find interface name for TTI streaming; ip output: {output}")
        return interface_name.group(1)
