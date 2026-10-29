from taf.ul.ettf.scheduler.robot_policy_trigger import Test
from taf.ul.ettf.scheduler.robot_policy_scheduler import Policy
from taf.ul.ettf.logging.interface import Logging

BASIC_POLICY = Policy(
    {
        Test: [Logging().with_capturing_gnb_syslog,
               Logging().with_capturing_simulators_syslog,
               Logging().with_gnb_snapshot_collection,
               Logging().with_sos_report_collection_on_failure]
    }
)
