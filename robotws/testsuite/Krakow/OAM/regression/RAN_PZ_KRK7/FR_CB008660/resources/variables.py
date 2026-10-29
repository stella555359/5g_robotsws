"""
Variables related to feature CB008660.
"""
# General
ASIR_WEBEM_ADDRESS = "192.168.255.129"
ASIR_WEBEM_PORT = 3601

# Associated with TC A03
CHANNEL_1_DIST_NAME = "ASI-1/BTS-1/CELL-1/CHANNELGROUP-1/CHANNEL-1"
ASIR_PRRH_MODULE_ANTENNA_LINE_PROFILE_PARAMETER = "antAntlPrDN"
ASIR_PRRH_MODULE_ANTENNA_LINE_PROFILE_VALUE = "ANTMODPR-1/ANTRFSMPR-1/ANTANTLPR-1"
ASIR_PRRH_MODULE_ANTENNA_LINE_PROFILE_INCORRECT_VALUE = "ANTRFSMPR-1/ANTANTLPR-1"

allowed_alarms = [
    "Service account root access is enabled",
    "SSH enabled",
    "Ethernet port security is disabled",
    "LMP access via port 443",
    "R&D Service Port enabled",
    "Diagnostic Files collected",
    "Sanity Check Error",
    "Radio Diagnostic Files collected",
    "Diagnostic Check Error"
]
