from taf.ul.ettf.scheduler.robot_policy_trigger import Suite, Test
from taf.ul.ettf.scheduler.robot_policy_scheduler import Policy
from taf.ul.ettf.logging.policies import _EMIL_KEYWORDS, _TSHARK_KEYWORDS, _SYSLOG_KEYWORDS, _CONFIGS_KEYWORDS, \
    _SNAPSHOT_KEYWORDS_ON_FAILURE, SOS_REPORT, NO_LOGS
from taf.ul.ettf.logging.interface import logging as logging_lib

logging = logging_lib()

FULL_POLICY_WITH_EMIL = Policy(
    {
        Test: _SYSLOG_KEYWORDS + _TSHARK_KEYWORDS,
        Suite: _CONFIGS_KEYWORDS + _EMIL_KEYWORDS + _SNAPSHOT_KEYWORDS_ON_FAILURE
    }
)

TSHARK_LOGS = Policy(
    {
        Test: _TSHARK_KEYWORDS,
        Suite: [],
    }
)

SNAPSHOT_AND_CONFIGS_POLICY = Policy(
    {
        Test: _CONFIGS_KEYWORDS + _SNAPSHOT_KEYWORDS_ON_FAILURE + SOS_REPORT,
        Suite: []
    }
)
