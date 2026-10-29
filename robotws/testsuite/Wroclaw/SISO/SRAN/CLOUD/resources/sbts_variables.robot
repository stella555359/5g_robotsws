*** Settings ***
Documentation  SBTS test suite variables
...  Maintainer: slawomir.jastrzebski@nokia.com

*** Variables ***
# IP ADDRESSES
${ENB_IP_ADDR}=         192.168.255.129
${ENB_SSH_USER}=        toor4nsn@192.168.255.129

# DEFAULT CONNECTIONS
${ADMIN_CONNECTION_DEFAULT}=  default

# LOGS FILE PATH
${SUITE_LOGS_DIR_PATH}=    ${OUTPUT DIR}

# CONFIG FILE PATHS
${SWCONFIG_FILE_PATH}=  /home/ute/MN/UTE/robotws/testsuite/Wroclaw/SISO/SRAN/resources/swconfig

# SWCONFIG FLAGS
@{SWCONFIG_FLAGS}=      0x360000=3 #enables FDSW/SWIM debug logs

# OTHER VARIABLES
${RAT_IMPACT}=          NONE

# TIMEOUTS
${DELTA_RECOMMISSIONING_TIMEOUT}=    300

# ALLOWED ALARMS
@{ALLOWED_ALARMS_FAULT_ID}=
...                        faultId=61652, severity=Minor
...                        faultId=61524, severity=Minor
...                        faultId=61649, severity=Minor
...                        faultId=4655, severity=Minor
...                        faultId=4654, severity=Minor

@{ADDITIONAL_COMMON_ALLOWED_ALARMS}=

@{ALLOWED_HISTORICAL_ALARMS_FAULT_ID}=
...                        faultId=61652, severity=Minor
...                        faultId=61524, severity=Minor
...                        faultId=61649, severity=Minor
...                        faultId=4655, severity=Minor
...                        faultId=4654, severity=Minor

@{ADDITIONAL_COMMON_HISTORICAL_ALLOWED_ALARMS}=

# @{ALLOWED_ALARMS_FAULT_ID}=
# 61652    R&D Service Port enabled
# 61524    SSH enabled
# 61649    LMP access via port 443
# 4655    Service account root access is enabled
# 4654    Ethernet port security is disabled
