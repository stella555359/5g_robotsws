*** Settings ***
Documentation  Test suite variables
...  Maintainer: slawomir.jastrzebski@nokia.com

*** Variables ***
#IP ADDRESSES
${ENB_IP_ADDR}=         192.168.255.129
${ENB_SSH_USER}=        toor4nsn
${ENB_SSH_PASSWD}=      oZPS0POrRieRtu
${ENB_SSH_PORT}=        22
${ENB_SSH_IP_USER}=     toor4nsn@192.168.255.129

# CONFIG FILE PATHS
${SWCONFIG_FILE_PATH}=  /home/ute/MN/UTE/robotws/testsuite/Wroclaw/SISO/SRAN/resources/swconfig

# SWCONFIG FLAGS
@{SWCONFIG_FLAGS}=      0x360000=3 #enables FDSW/SWIM debug logs
...                     0x5801cb=0 #disable fake UE reading

# OTHER VARIABLES
${RAT_IMPACT}=          NONE

#TIMEOUTS
${DELTA_RECOMMISSIONING_TIMEOUT}=    300


# ALLOWED ALARMS
#@{ALLOWED_ALARMS_ONAIR}=
#...                  BTS booted at
#...                  Sanity Check Error

@{ALLOWED_ALARMS_ONAIR_FAULT_ID}=
...                        faultId=61652, severity=Minor
...                        faultId=61524, severity=Minor
...                        faultId=61649, severity=Minor
...                        faultId=4592, severity=Warning
...                        faultId=4655, severity=Minor
...                        faultId=4654, severity=Minor
...                        faultId=4681, severity=Minor

@{ALLOWED_ALARMS_BLOCK_UNBLOCK_FAULT_ID}=
...                        faultId=61652, severity=Minor
...                        faultId=61524, severity=Minor
...                        faultId=61649, severity=Minor
...                        faultId=4592, severity=Warning
...                        faultId=4655, severity=Minor
...                        faultId=4654, severity=Minor
...                        faultId=4681, severity=Minor
...                        faultId=49, severity=Critical

@{ALLOWED_ALARMS_FAULT_ID}=
...                        faultId=61652, severity=Minor
...                        faultId=61524, severity=Minor
...                        faultId=61649, severity=Minor
...                        faultId=4592, severity=Warning
...                        faultId=4655, severity=Minor
...                        faultId=4654, severity=Minor
...                        faultId=4681, severity=Minor
...                        faultId=4681, severity=Minor
...                        faultId=6202, severity=Critical
...                        faultId=3080
...                        faultId=26
...                        faultId=4793
...                        faultId=61058
...                        faultId=61006
...                        faultId=6150
...                        faultId=6308

# @{ALLOWED_ALARMS_ONAIR}=
# 61652    R&D Service Port enabled
# 61524    SSH enabled
# 61649    LMP access via port 443
# 4592     BTS Reset Cause
# 4655    Service account root access is enabled
# 4654    Ethernet port security is disabled
# 4681    Sanity Check Error

#@{ALLOWED_ALARMS_BLOCK_UNBLOCK}=
# 49      Cell blocked

#@{ALLOWED_ALARMS}=
# 6202    Transport layer connection failure in S1 interface
# 3080    BTS reference clock missing
# 26      BTS time not corrected
# 4793    ToP master service unusable
#         Synchronisation lost
# 61058   Synchronization lost
# 61006   BTS booted at
# 6150	  GTP-U Path Failure
#         Service Port Enabled
# 6308    S1 interface setup failure

# 2403     Configuration mismatch between BSC and BTS
