#!/bin/bash
###############################################################################
# !!!!!!!!!!!!!!! OPTIONS !!!!!!!!!!!!!!!

# General options
MIRRORING_MODE='local' # remote/local/manual/local_in_l2rt_core, remote mirrors to EIF2, local dumps data to gNB, manual enables mirroring but ABIL Master/Slave Xeon but does not capture data or disable mirroring

# Mirror BB boards
MIRROR_ABIL_1='true' # true/false
MIRROR_ABIL_2='false' # true/false
MIRROR_ABIL_3='false' # true/false

# Mirrored interfaces, the less interfaces are configured for mirroring, the better are chances to not to drop packets
L2_L1_BIP='true' # true/false
SYSCOM_MIRRORING='false' # true/false, mirrors syscom traffic between control and baseband boards for ABILs that are mirrored
CARRIER_AGGREGATION='false' # true/false, for GC2/GD2 L2-RT instances
BACKHAUL_MIRRORING='false' # S1/X2 in Classical deployment, F1-U in Cloud deployment, works only in ASIK
L2HI_L2LO_MIRRORING='false' # traffic between L2-HI - L2-LO, only in ASIK

# Local mode options
FILTERING='off' # off/on, on filters out control messages sent in every TTI
FILTER=''
USE_GULP='false' # true/false, use gulp engine for capturing instead of tcpdump, provides better performance, works with ASIK+ABIL
CAPTURING_TIME_SECONDS=0 # in seconds/special value 'infinite' or 0 keeps capture rolling
NUMBER_OF_FILES=1 # number of files created, tcpdump -W
FILE_SIZE_MBYTES=100 # size of file create, tcpdump -C


# Debug options
XTRACE='off' # true/false

###############################################################################

# FILTER message IDs
# By default, periodic control messages are filtered out
# https://gitlabe1.ext.net.nokia.com/high-five/3gpp-interfaces-5g-layer-1/-/wikis/5G-3GPP-Interface-Message-IDs
# Some common message IDs
# 5G19A
#   - PatternConfigReq 0x12b
#   - SlotTypeReq 0x122
#   - PrachReceiveReq 0x233
#   - CsiRsSendReq 0x12a
#   - SsBlocSendReq 0x127
#   - pdschPayloadTbSendReq 0x108
#   - puschReceiveRespLo 0x23a
#  Changes in 5G19B
#   - PrachReceiveReq 0x240
#   - CsiRsSendReq 0x131
#  Changes in 5G20A
#   - PatternConfigReq 0xe101
#




