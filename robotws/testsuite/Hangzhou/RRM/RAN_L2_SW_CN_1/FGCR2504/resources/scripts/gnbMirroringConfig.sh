#!/bin/bash
###############################################################################
# !!!!!!!!!!!!!!! OPTIONS !!!!!!!!!!!!!!!

# General options
MIRRORING_MODE='local' # remote/local/manual, remote mirrors to EIF2, local dumps data to gNB, manual enables mirroring but ABIL Master/Slave Xeon but does not capture data or disable mirroring

# Mirrored interfaces, the less interfaces are configured for mirroring, the better are chances to not to drop packets
SYSCOM_MIRRORING='false' # true/false, mirrors syscom traffic between control and baseband boards for ABILs that are mirrored
MIRROR_ABIL_1='true' # true/false
MIRROR_ABIL_2='false' # true/false
MIRROR_ABIL_3='false' # true/false
CARRIER_AGGREGATION='false' # true/false, for GC2/GD2 L2-RT instances
BACKHAUL_MIRRORING='false' # S1/X2, only in ASIK
F1U_MIRRORING='false' # traffic between L2-HI - L2-LO, only in ASIK

# Standalone mode options
FILTERING='off' # off/on, on filters out control messages sent in every TTI 
USE_GULP='false' # true/false, use gulp engine for capturing instead of tcpdump, provides better performance, works with ASIK+ABIL
CAPTURING_TIME_SECONDS=5 # in seconds/special value 'infinite' keeps capture rolling
NUMBER_OF_FILES=2 # number of files created, tcpdump -W
FILE_SIZE_MBYTES=50 # size of file create, tcpdump -C

###############################################################################
