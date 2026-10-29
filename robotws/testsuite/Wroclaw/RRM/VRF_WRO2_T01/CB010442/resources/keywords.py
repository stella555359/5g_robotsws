from datetime import datetime, timedelta, time
from taf.sbts.oam.coam.admin import admin
import time
from robot.api import logger
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_api import AdminApi
from testsuite.Wroclaw.RRM.resources.log.matchers import PcapMessageMatcher as pm
from testsuite.Wroclaw.RRM.resources.log.helper import LogHelper
from testsuite.Wroclaw.RRM.resources.log.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T01.CB013553.resources.keywords import _verify_messages

CELL_PARAMETERS = {
    'CELL_n10': {'nRCellIdentity': '820330506', 'service-state': 'in-service'},
}
FILTER_F1ap = "f1ap"


def verify_GNBDUConfigurationUpdate_in_rrc_messages(pcap_file):
    cell_msgs = [
        pm('GNBDUConfigurationUpdate', name_line_pattern='empty')
        .containing('nRCellIdentity', '*{}*'.format(CELL_PARAMETERS['CELL_n10']['nRCellIdentity']))
        .containing('service-state', '*{}*'.format(CELL_PARAMETERS['CELL_n10']['service-state']))
    ]
    return _verify_messages(pcap_file, cell_msgs, shark_filter=FILTER_F1ap)


def verify_energy_saving_activation(cell_id: int, *cells_info: dict) -> None:
    for cell in cells_info:
        if cell["globalCellId"] == cell_id:
            # if cell["energySavingState"] != "EnergySaving":  # TODO bring back this line
            if cell["energySavingState"].lower() != "energysaving":
                raise Exception(f"Expected state for cell {cell['globalCellId']} is EnergySaving but cell was "
                                f"in {cell['energySavingState']} state")


def verify_energy_saving_deactivation(cell_id: int, *cells_info: dict) -> None:
    for cell in cells_info:
        if cell["globalCellId"] == cell_id:
            # if cell["energySavingState"].lower() != "notEnergySaving":
            if cell["energySavingState"] != "notEnergySaving":
                raise Exception(f"Expected state for cell {cell['globalCellId']} is EnergySaving but cell was "
                                f"in {cell['energySavingState']} state")


def verify_if_cell_mutted_state(cell_id: int, *cells_info: dict) -> None:
    for cell in cells_info:
        if cell["globalCellId"] == cell_id:
            # if cell["energySavingState"].lower() != "notEnergySaving":
            if cell["energySavingState"] != "reducedEnergySaving":
                raise Exception(f"Expected state for cell {cell['globalCellId']} is reducedEnergySaving but cell was "
                                f"in {cell['energySavingState']} state")


def verify_on_air_state(*cells_info: dict) -> None:
    for cell in cells_info:
        # TODO bring back this line
        # if cell["energySavingState"] != "NotEnergySaving" or cell["status"]["operationalState"] != "enabled":
        if cell["energySavingState"].lower() != "notenergysaving" or cell["status"]["operationalState"] != "enabled":
            raise Exception(f"Expected state for cell {cell['globalCellId']} is 'NotEnergySaving and enabled' but cell"
                            f"status was '{cell['energySavingState']} and {cell['status']['operationalState']}'")


def compare_pdml_with_counters(pdml: dict, counters: dict) -> bool:
    for counter, pdml_value in pdml.items():
        if str(pdml_value) != str(counters[counter]):
            raise Exception("Counter value differs from pdml value")

    counters_values = [counter_value for counter_value in counters.values()]
    counters_values = set(counters_values)
    if len(counters_values) != 1:
        raise Exception("Counters values are not equal")

    return True


def get_bts_time(remote_host):
    power_saving = PowerSavingTest()
    return power_saving.get_bts_time(remote_host)


def get_deep_sleep_remaining_time(remote_host):
    power_saving = PowerSavingTest()
    return power_saving.get_deep_sleep_remaining_time(remote_host)


def get_separate_hours_minutes_from_time(remote_host):
    power_saving = PowerSavingTest()
    return power_saving.get_separate_time(remote_host)


class PowerSavingTest(object):
    def _get_current_bts_time(self, remote_host):
        a = admin()
        a.setup_admin()
        try:
            ret = a.get_bts_time_zone(detailed_output=True)
        finally:
            a.teardown()

        return datetime.strptime(ret['time'],  '%I:%M:%S %p').strftime('%H:%M')

    def get_bts_time(self, remote_host):
        return self._get_current_bts_time(remote_host)

    def get_separate_time(self, remote_host, mins=5):
        """
        Get the current BTS time, add 5 minutes, and return the new time in the format
        in HH:MM.:return: MM formatted time string
        """
        time_str = self._get_current_bts_time(remote_host=remote_host)
        current_time = datetime.strptime(time_str, "%H:%M")
        new_time = current_time + timedelta(minutes=mins)
        formatted_time = new_time.strftime("%H:%M")
        formatted_time_hours = new_time.strftime("%H")
        formatted_time_minutes = new_time.strftime("%M")
        return current_time, new_time, formatted_time, formatted_time_hours, formatted_time_minutes

    def get_deep_sleep_remaining_time(self, remote_host):
        """
        Get the current BTS time, add 5 minutes, and return the new time in the format of day of the week time
        in HH:MM.:return: formatted time string
        """
        time_str = self._get_current_bts_time(remote_host=remote_host)
        current_time = datetime.strptime(time_str, "%H:%M")
        new_time = current_time + timedelta(minutes=5)
        formatted_time = new_time.strftime("%H:%M")
        return formatted_time


def verify_deep_sleep_activation(RU_type: str, RU_status, *RUs_info: dict) -> None:
    for Radiomodule in RUs_info:
        if Radiomodule["productName"] == RU_type:
            logger.info("expected productName: {}".format(Radiomodule["productName"]), also_console=False)
            logger.info("status for expected productName [dict]: {}".format(Radiomodule["status"]), also_console=False)
            RadiomoduleStatusDict = Radiomodule["status"]
            logger.info("currently still visible powerState for productName: {}"
                        .format(RadiomoduleStatusDict["powerState"]), also_console=False)
            logger.info("expected powerState: {}".format(RU_status))
            if RadiomoduleStatusDict["powerState"] != RU_status:
                raise Exception(f"Expected state for Radio Module {Radiomodule['productName']} is " + RU_status +
                                f"state but RU was " f"in {Radiomodule['powerState']} status")


def verify_deep_sleep_Deactivation_due_ES_finished(RU_type: str, RU_ProceduralStatus, *RUs_info: dict) -> None:
    for Radiomodule in RUs_info:
        if Radiomodule["productName"] == RU_type:
            logger.info("expected productName: {}".format(Radiomodule["productName"]), also_console=False)
            logger.info("status for expected productName [dict]: {}".format(Radiomodule["status"]), also_console=False)
            RadiomoduleStatusDict = Radiomodule["status"]
            logger.info("currently still visible proceduralStatus for productName: {}"
                        .format(RadiomoduleStatusDict["proceduralStatus"]), also_console=False)
            logger.info("expected proceduralStatus: {}".format(RU_ProceduralStatus))
            if RadiomoduleStatusDict["proceduralStatus"] != RU_ProceduralStatus:
                raise Exception(f"Expected state for Radio Module {Radiomodule['productName']} is "
                                + RU_ProceduralStatus + f"state but RU was " f"in "
                                                        f"{Radiomodule['proceduralStatus']} status")


def check_x2_link_status(eNB_id):
    with AdminApi() as web_api:
        x2_list = web_api.get_managed_objects(class_name="LTEENB_R", timeout=30)
        for i in range(len(x2_list)):
            if x2_list[i]["parameters"]["eNodeBId"] == int(eNB_id):
                return x2_list[i]["parameters"]["x2LinkStatus"]


def verify_x2_link_status_in_loop(eNB_id, expected_status, duration, sleep):
    start_time = time.time()
    while int(time.time()) - int(start_time) < int(duration):
        status = check_x2_link_status(eNB_id)
        assert status == expected_status, "x2 link is not in status: {}".format(
            expected_status
        )
        time.sleep(int(sleep))


def sync_to_reporting_interval(offset_s=40, interval_m=5):
    interval_s = int(interval_m) * 60
    now = datetime.now()
    time.sleep((interval_s + int(offset_s) - now.minute * 60 - now.second) % interval_s)


def verify_if_KPI_in_deviation(deviation, disabled_KPIs=None, value_to_report=None):
    deviation_as_float = parse_deviation(deviation)
    min_threshold = int(disabled_KPIs) - (int(disabled_KPIs) * deviation_as_float)
    max_threshold = int(disabled_KPIs) + (int(disabled_KPIs) * deviation_as_float)
    print('After deviation value: {} minimum expected KPI: {} , based first measurement for disabled: {} '
          .format(deviation, min_threshold, disabled_KPIs))
    assert int(min_threshold) < int(value_to_report), 'Average KPI for test: not in expected range! ' \
        'Current KPI: {} , with expected deviation MIN: {} '.format(value_to_report, min_threshold)


def parse_deviation(unparsed_deviation):
    number = unparsed_deviation.rstrip('%')
    deviation = float(number) / 100.0
    return deviation
