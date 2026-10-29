from taf.ul.ettf.scheduler.robot_policy_trigger import Suite, Test
from taf.ul.ettf.scheduler.robot_policy_scheduler import Policy
from taf.ul.ettf.logging.policies import _EMIL_KEYWORDS, _TSHARK_KEYWORDS, _SYSLOG_KEYWORDS, _CONFIGS_KEYWORDS,\
    _SNAPSHOT_KEYWORDS_ON_FAILURE
from taf.ul.ettf.logging.interface import logging as logging_lib

logging = logging_lib()

FULL_POLICY_WO_SOS_REPORT = Policy(
    {
        Test: _SYSLOG_KEYWORDS + _TSHARK_KEYWORDS,
        Suite: _CONFIGS_KEYWORDS + _SNAPSHOT_KEYWORDS_ON_FAILURE
    }
)
