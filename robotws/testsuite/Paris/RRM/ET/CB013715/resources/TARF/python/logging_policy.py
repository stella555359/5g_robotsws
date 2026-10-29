from taf.ul.ettf.scheduler.robot_policy_trigger import Suite, Test
from taf.ul.ettf.scheduler.robot_policy_scheduler import Policy
from taf.ul.ettf.logging.policies import _EMIL_KEYWORDS, _TSHARK_KEYWORDS, _SYSLOG_KEYWORDS, _CONFIGS_KEYWORDS, \
    _SNAPSHOT_KEYWORDS_ON_FAILURE
from taf.ul.ettf.logging.interface import logging as logging_lib

logging = logging_lib()

# see /home/ute/.pyenv/versions/3.9.14/lib/python3.9/site-packages/taf/ul/ettf/logging/policies.py

NO_LOGS_POLICY = Policy(
    {
        Test: [],
        Suite: []
    }
)

FULL_POLICY_WO_SOS_REPORT = Policy(
    {
        Test: _SYSLOG_KEYWORDS + _TSHARK_KEYWORDS,
        Suite: _CONFIGS_KEYWORDS + _SNAPSHOT_KEYWORDS_ON_FAILURE
    }
)

NO_TRAFFIC_LOGS_POLICY_FULL = Policy(
    {
        Test: _SYSLOG_KEYWORDS + [logging.with_capturing_f1ap_messages,
                                  logging.with_capturing_ue_specific_messages,
                                  logging.with_traffic_messages_from_wts,
                                  logging.with_capturing_adminapi_infomodel_messages],
        Suite: _CONFIGS_KEYWORDS
    }
)

LOGS_POLICY = Policy(
    {
        Test: _CONFIGS_KEYWORDS + [logging.with_gnb_snapshot_collection],
        Suite: _CONFIGS_KEYWORDS
    }
)


NO_TRAFFIC_LOGS_POLICY = Policy(
    {
        Test: _CONFIGS_KEYWORDS + [logging.with_capturing_f1ap_messages,
                                   logging.with_capturing_adminapi_infomodel_messages,
                                   logging.with_gnb_snapshot_collection],
        Suite: _CONFIGS_KEYWORDS
    }
)

NO_TRAFFIC_NO_SNAPSHOT_NO_INFOMODEL_LOGS_POLICY = Policy(
    {
        Test: _CONFIGS_KEYWORDS + [logging.with_capturing_f1ap_messages],
        Suite: _CONFIGS_KEYWORDS
    }
)

NO_TRAFFIC_NO_SNAPSHOT_LOGS_POLICY = Policy(
    {
        Test: _CONFIGS_KEYWORDS + [logging.with_capturing_f1ap_messages,
                                   logging.with_capturing_adminapi_infomodel_messages],
        Suite: _CONFIGS_KEYWORDS
    }
)

LOGS_POLICY_FULL = Policy(
    {
        Test: _CONFIGS_KEYWORDS + [logging.with_capturing_f1ap_messages,
                                   logging.with_emil_logs_collection,
                                   logging.with_gnb_snapshot_collection_on_failure,
                                   logging.with_simulator_snapshot_collection_on_failure,
                                   logging.with_sos_report_collection_on_failure],
        Suite: _CONFIGS_KEYWORDS
    }
)

LOGS_POLICY_CRT = Policy(
    {
        Test: _CONFIGS_KEYWORDS + [logging.with_capturing_f1ap_messages,
                                   logging.with_gnb_snapshot_collection_on_failure,
                                   logging.with_simulator_snapshot_collection_on_failure,
                                   logging.with_sos_report_collection_on_failure],
        Suite: _CONFIGS_KEYWORDS
    }
)


def start_logging():
    logging = logging_lib()
    logging.with_capturing_f1ap_messages


if __name__ == "__main__":
    LOGGING_POLICY = NO_TRAFFIC_LOGS_POLICY
    obj = logging_lib()
    help(obj)
