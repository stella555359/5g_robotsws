import re
from time import sleep

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.log_verification.pcap_reader import \
    load_pcap
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.nls import (
    change_nls_parameters, download_nrppa_log,
    setup_nls_page_and_open_nrppa_parameter_page,
    teardown_nls_connection_and_restore_initial_values, trigger_lcs)
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.perf_cap.cell_edge.resources.cell_edge import (
    CellEdge, logger)


class CB013507(CellEdge):
    """
    This class provides extendent Cell Edge testcase scenario which triggers E-CID measurements after each attach and
    collects position data
    """

    LMF_CONNECTION_DETAILS = {"hostname": "10.27.227.254", "username": "root", "password": "nls72NSN"}
    LMF_FILE_PATH = "/root/13507_Wro8/gjill-{}.xml"

    def __init__(self):
        super().__init__()
        self.ecid_fails = 0
        self.ecid_runs = 0
        self.last_nrppa_idx = 0
        self.coordinates_csv = "coordinates.csv"

    def test_setup(self, testname: str | None = None) -> None:
        super().test_setup(testname)
        setup_nls_page_and_open_nrppa_parameter_page()
        self.schedule_test_teardown_function("teardown_nls", self.teardown_nls, [])
        change_nls_parameters("TimingAdvanceNR,SS_RSRP,SS_RSRQ", "OnDemand")
        self._create_coordinates_csv()

    @CellEdge.teardown_wrapper()
    def teardown_nls(self) -> None:
        teardown_nls_connection_and_restore_initial_values()

    def do_post_attach_test_steps(self):
        """
        Trigger E-CID measurement after attach
        """

        trigger_lcs(self.LMF_CONNECTION_DETAILS, f"{self.LMF_FILE_PATH}{self.cfg.imsi}")
        sleep(5)
        super().do_post_attach_test_steps()

    def gather_logs(self, run_nr: str) -> list[str]:
        """
        Adds translog download after all other Cell Edge logs are gathered
        """

        files = super().gather_logs(run_nr)
        nrppa_log = f"{self.current_subdir}/{self._get_formatted_log_prefix()}_nrppa.log"
        download_nrppa_log(self.LMF_CONNECTION_DETAILS, nrppa_log)
        files["nrppa"] = nrppa_log
        return files

    def analyze_logs(self, logs: list[str]) -> None:
        """
        Analyze gathered nls translog and tcpdump logs and write data row to position datafile
        """

        super().analyze_logs(logs)
        log_name = "TCPDUMP_5G" if "TCPDUMP_5G" in logs else "TCPDUMP_LTE"
        flags = check_tcpdump_for_lcs_trigger(logs[log_name])
        x, y = self.analyze_nls_nrppa_log(logs["nrppa"])
        self._append_coordinates(logs["run_nr"], x, y)
        self.ecid_runs += 1
        if not all(flags) or not (x and y):
            self.ecid_fails += 1
            logger.info(
                f"tcpdump analysis for e-cid failed:\nDL E-CID Request = {flags[0]}\n"
                f"UL E-CID Response with successfulOutcome_element = {flags[1]}\n"
                f"Coordinates = {x}, {y}",
                also_to_console=True,
            )
        logger.info(
            f"Successful E-CIDs = {self.ecid_runs - self.ecid_fails}/{self.ecid_runs}. Coordinates = {x}, {y}",
            also_to_console=True,
        )

    def analyze_nls_nrppa_log(self, nrppa_log: str) -> tuple[str, str]:
        """
        Check nrppa.log from NLS for latest entry with provided IMSI and extract posional data
        """
        start_nrppa_regex = fr'^.*com\.nokia\.nls\.nrppa\.service\.NRPPaHandler - get init.*sessionId:([0-9A-F]+),' \
                            fr'.*UEName\(supi:imsi-{self.cfg.imsi},.*cellid:([0-9A-F]+)\),.*$'
        x, y = "0", "0"
        nrppa_start_line_idx = None
        cell_id = None
        with open(nrppa_log) as f:
            lines = f.readlines()
        initial_start_point = self.last_nrppa_idx if self.last_nrppa_idx < len(lines) else 0
        logger.info(f"Processing nrppa.log lines {initial_start_point} to {len(lines)}", also_to_console=True)
        for idx, line in enumerate(lines[initial_start_point:]):
            matched = re.match(start_nrppa_regex, line)
            if matched:
                nrppa_start_line_idx = self.last_nrppa_idx + idx
                cell_id = matched.group(2)
        if nrppa_start_line_idx is None:
            raise ValueError(f"Could not find valid NRPPA init message for IMSI {self.cfg.imsi}")
        if cell_id is None:
            raise ValueError(f"Could not find cell id nrppa.log")
        ecid_regex = fr'^.*com\.nokia\.nls\.nrppa\.util\.ECIDMeasurementConverter - ECID request to UPM:Request' \
                     fr'.*cellId:{cell_id}\),.*$'
        position_regex = fr'^.*com\.nokia\.nls\.nrppa\.service\.UpmAdapter - get positioning result.*LocationInfo' \
                         fr'\(latitude:(\d+\.\d+), longitude:(\d+\.\d+).*{cell_id}.*$'
        self.last_nrppa_idx = nrppa_start_line_idx
        relevant_lines = lines[nrppa_start_line_idx:]
        ecid_match = False
        for line in relevant_lines:
            if re.match(ecid_regex, line):
                ecid_match = True
            elif ecid_match:
                if pos_match := re.match(position_regex, line):
                    x, y = pos_match.groups()
        return x, y

    def _create_coordinates_csv(self) -> None:
        self.coordinates_csv = f"{self._log_prefix_path}_coordinates.csv"
        with open(self.coordinates_csv, "w") as output_file:
            output_file.write(",".join(["run_nr", "X", "Y"]))
            output_file.write("\n")

    def _append_coordinates(self, run_nr: str, x: str, y: str) -> None:
        with open(self.coordinates_csv, "a") as output_file:
            output_file.write(",".join([str(run_nr), x, y]))


def check_tcpdump_for_lcs_trigger(tcpdump: str) -> tuple[bool, bool]:
    """
    Check tcpdump for core E-CID messages and return flags indicating if Request and Response were found in log
    """

    filter_msg = [
        "ngap.DownlinkUEAssociatedNRPPaTransport_element",
        "ngap.UplinkUEAssociatedNRPPaTransport_element",
        "nrppa.successfulOutcome_element",
    ]
    messages = load_pcap(tcpdump, tshark_fields=filter_msg, output_json_file="/tmp/tcpdump_lcs.json")
    downlink_ecid = False
    uplink_ecid = False
    for msg in messages:
        msg = msg["_source"]["layers"]
        if "ngap.DownlinkUEAssociatedNRPPaTransport_element" in msg:
            downlink_ecid = True
        if "ngap.UplinkUEAssociatedNRPPaTransport_element" in msg:
            if "nrppa.successfulOutcome_element" in msg:
                uplink_ecid = True
    return uplink_ecid, downlink_ecid
