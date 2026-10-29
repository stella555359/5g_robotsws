from taf.rfrl.utilities.robot.general import get_builtin_value

DCAP_CONNECTION = {"host": "localhost", "port": "9443", "user": None, "passwd": None}
DCAP_PROFILE = {'gnb_custom_profile':  ['L2Ps_Component'],
                'bts_custom_profile':  ['scf'],
                'bip_mirroring_time':  0,
                'wait_for_activation': True}
ATTENUATOR_CONFIG = get_builtin_value("tl.attenuator")
CELLS_PORTS = {"NRCELL-210": [17, 18],
               "NRCELL-211": [21, 22],
               "NRCELL-212": [13, 14],
               "NRCELL-213": [15, 16]}
BTS_DISTNAME = "MRBTS-50821/NRBTS-50821"
CELLS = ["NRCELL-210", "NRCELL-211", "NRCELL-212", "NRCELL-213"]
UE = get_builtin_value("tl.ues[0]")

SMOOTHING_EFFECT = [
    {"parameterName": "eirpControl", "operation": "update", "value":
        [{"smoothingEffect": "<set_value>"}]}
]
TEST_VERIFICATION_RESULTS: dict
TEST_LOG_DIR: str
TEST_NAME: str
