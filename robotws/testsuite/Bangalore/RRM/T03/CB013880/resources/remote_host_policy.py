from taf.ul.ettf.scheduler.robot_policy_trigger import Suite, Test
from taf.ul.ettf.scheduler.robot_policy_scheduler import Policy
from taf.ul.ettf.logging.interface import Logging

import multignb_variables

remote_host_ip = multignb_variables.get_remote_host_ip()

REMOTE_HOST_POLICY = Policy(
    {
        Suite: [Logging().with_capturing_simulators_syslog],
        Test: [Logging().with_gnb_snapshot_collection,
               lambda: Logging().with_gnb_snapshot_collection(remote_host=remote_host_ip),
               Logging().with_sos_report_collection_on_failure]
    }
)
