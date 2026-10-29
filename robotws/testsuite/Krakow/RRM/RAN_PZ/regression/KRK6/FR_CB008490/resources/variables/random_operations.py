from taf.rfrl.bts.alarms.classical_alarms_definition import CLASSICAL_FAULT_7513, CLASSICAL_FAULT_6134
from taf.rfrl.utilities.robot.general import import_resource_to_robot_framework_namespace, get_builtin_value
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK6.FR_CB008490.resources.common import Misc


TOTAL_TIMEOUT = 3600
EMAIL_NOTIFICATION_WHEN_FAIL = Misc.to_bool(get_builtin_value("EMAIL_NOTIFICATION_WHEN_FAIL"), True)
OPERATIONS = ["rat_reset", "site_reset", "bts_power_on", "reset_bbmod", "reset_rmod", "power_reset_rmod",
              "bts_power_reset_via_api", "cell_block_unblock", "cell_lock_unlock"]
CALCULATE_KPI = Misc.to_bool(get_builtin_value("CALCULATE_KPI"), False)
COLLECT_RU_LOGS = Misc.to_bool(get_builtin_value("COLLECT_RU_LOGS"), False)
COLLECT_PASSED_SNAPSHOT = Misc.to_bool(get_builtin_value("COLLECT_PASSED_SNAPSHOT"), True)
DELAY_FOR_CHECKING_ALLOWED_ALARMS = 60
TEMP_ALLOWED_ALARMS = [CLASSICAL_FAULT_7513, CLASSICAL_FAULT_6134]
OPERATION_KWARGS = {
    operation_name: {
        'temp_allowed_alarms': TEMP_ALLOWED_ALARMS,
        'delay_for_checking_allowed_alarms': DELAY_FOR_CHECKING_ALLOWED_ALARMS,
        'calculate_kpi': CALCULATE_KPI,
        'collect_ru_logs': COLLECT_RU_LOGS,
        'collect_passed_snapshot': COLLECT_PASSED_SNAPSHOT
    }
    for operation_name in OPERATIONS
}

RANDOM_SEED = None
CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION = CLASSICAL_FAULT_6134['fault_id']

L3_CALL = Misc.to_bool(get_builtin_value("L3_CALL"), False)
if L3_CALL:
    import_resource_to_robot_framework_namespace("taf/rfrl/ue/robot/REAL_UE.robot")

L3_CALL_KEYWORDS = \
    {"ss_kw.use_ru_cell_as_pcell": {"ru_name": "AZQO"},
     "Prepare Ue for L3 Call": {"capabilities": "REAL_UE", "alias": "UE"},
     "Verify L3 Call Data Transfer DL&UL":
         {"duration": "60s", "tput_dl": "2000 Mbits/sec", "tput_ul": "250 Mbits/sec", "deviation": "20%",
          "parallel_streams_dl": "2", "parallel_streams_ul": "2", "size_packet_dl": "1350B", "size_packet_ul": "1350B",
          "buffer_server_dl": "4M",
          "alias": "UE"},
     "Stop Using Ue": ["UE"]}
