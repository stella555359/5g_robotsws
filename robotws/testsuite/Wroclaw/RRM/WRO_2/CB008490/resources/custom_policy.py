from taf.ul.ettf.scheduler.robot_policy_trigger import Suite, Test
from taf.ul.ettf.scheduler.robot_policy_scheduler import Policy
from taf.ul.ettf.logging.interface import Logging
import multignb_variables

remote_host_ip = multignb_variables.get_remote_host_ip()

SYSLOG_POLICY = Policy(
    {
        Suite: [Logging().with_capturing_gnb_syslog,
                Logging().with_capturing_simulators_syslog],
        Test: []
    }
)

BASIC_POLICY = Policy(
    {
        Suite: [Logging().with_gnb_snapshot_collection_on_failure,
                Logging().with_simulator_snapshot_collection_on_failure,
                Logging().with_capturing_gnb_syslog,
                Logging().with_capturing_simulators_syslog],
        Test: []
    }
)


BASIC_POLICY_WITH_EMIL = Policy(
    {
        Suite: [Logging().with_gnb_snapshot_collection_on_failure,
                Logging().with_simulator_snapshot_collection_on_failure,
                Logging().with_capturing_gnb_syslog,
                Logging().with_capturing_simulators_syslog,
                Logging().with_emil_logs_collection],
        Test: []
    }
)

MANUAL_TEST_POLICY = Policy(
    {
        Suite: [Logging().with_gnb_snapshot_collection,
                Logging().with_capturing_gnb_syslog,
                Logging().with_capturing_simulators_syslog],
        Test: []
    }
)

MANUAL_TEST_POLICY_WITH_EMIL = Policy(
    {
        Suite: [Logging().with_gnb_snapshot_collection,
                Logging().with_capturing_gnb_syslog,
                Logging().with_emil_logs_collection,
                Logging().with_capturing_simulators_syslog],
        Test: []
    }
)

REMOTE_HOST_POLICY = Policy(
    {
        Suite: [Logging().with_gnb_snapshot_collection_on_failure,
                lambda:  Logging().with_gnb_snapshot_collection_on_failure(remote_host=remote_host_ip),
                Logging().with_sos_report_collection_on_failure,
                Logging().with_simulator_snapshot_collection_on_failure,
                Logging().with_capturing_gnb_syslog,
                Logging().with_capturing_simulators_syslog],
        Test: []
    }
)
