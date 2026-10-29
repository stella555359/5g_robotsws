#!/bin/bash
###############################################################################
# !!!!!!!!!!!!!!! OPTIONS !!!!!!!!!!!!!!!

# General options
MIRRORING_MODE='local' # remote/local/manual/local_in_l2rt_core, remote mirrors to EIF2, local dumps data to gNB, manual enables mirroring but ABIL Master/Slave Xeon but does not capture data or disable mirroring

# Mirror BB boards
BB_SLOT_1='true' # true/false
BB_SLOT_2='false' # true/false
BB_SLOT_3='false' # true/false
BB_SLOT_5='false' # true/false
BB_SLOT_6='false' # true/false
BB_SLOT_7='false' # true/false

# Mirrored interfaces, the less interfaces are configured for mirroring, the better are chances to not to drop packets
L2_L1_BIP='true' # true/false/l2l1/l1l2, ASIK/ASIB/ASIL+ABIL, ASIB/ASIL+ABIO, ASOD: BIP traffic between L2-L1
SYSCOM_MIRRORING='false' # true/false, ASIK/ASIB/ASIL+ABIL: syscom traffic between control and baseband boards
BACKHAUL_MIRRORING='true' # true/false, ASIK: S1/X2 in Classical deployment, F1-U in Cloud deployment
L2HI_MIRRORING='false' # true/false, ASIK/ASIB/ASIL+ABIL: traffic to/from L2-HI, ASIB+ABIO: L2HI_TRSP (contains also l2ps_peer interface in CA configs)
L2RT_MIRRORING='false' # true/false, ASIK/ASIB/ASIL+ABIL: traffic to/from L2-RT, ASIB+ABIO: L2HI_L2RT
CPRT_MIRRORING='false' # true/false, ASIK/ASIB/ASIL+ABIL: traffic to/from CP-RT

# Local mode options
FILTERING='off' # on/off, on enables capture filter, set filter in FILTER argument, default filters examples are exclusive filters for event IDs, for syntax see https://www.tcpdump.org/manpages/tcpdump.1.html
FILTER='ether[0x18:2]!=0xe101 and ether[0x18:2]!=0x131 and ether[0x18:2]!=0xe206 and ether[0x18:2]!=0xe105 and ether[0x18:2]!=0xe111 and ether[0x18:2]!=0xe229' # ASIK+ABIL, ASIL+ABIO
#FILTER='ether[0x1c:2]!=0xe101 and ether[0x1c:2]!=0x131 and ether[0x1c:2]!=0xe206 and ether[0x1c:2]!=0xe105 and ether[0x1c:2]!=0xe111 and ether[0x1c:2]!=0xe229' # ASIB+ABIO
USE_GULP='false' # true/false, use gulp engine for capturing instead of tcpdump, provides better performance, works at least with ASIK+ABIL
CAPTURING_TIME_SECONDS=3000 # in seconds/special value 'infinite' or 0 keeps capture rolling
NUMBER_OF_FILES=1 # number of files created, tcpdump -W
FILE_SIZE_MBYTES=500 # size of file create, tcpdump -C
SNAPLEN='262144' # Snarf snaplen bytes of data from each packet rather than the default of 262144 bytes.

# Triggering options
WAIT_FOR_JOURNAL_EVENT="off" # off/<string>, polling L1 journal to stop capturing when <string> is logged to journal
BB_NODE_FOR_TRIGGER="1:2"

# Debug options
XTRACE='off' # on/off
SKIP_SW_BUILD_CHECK="false"



