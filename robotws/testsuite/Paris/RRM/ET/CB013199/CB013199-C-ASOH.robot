*** Settings ***

Documentation     [SUITE PURPOSE]   feature CB013199 Instantaneous Throughput Pooling
...               Prerequisite      : gNB configured with 6 Cells
...               Scope             : cell setup & call setup
...
...               Test Case Scenario author   : ying.yw.wu@nokia.com
...               Creation Date               : 19-09-2024
...               Modified Date               : 19-09-2024
...               Last Modified by            : ying.yw.wu@nokia.com
...               Version   Date      Author                             Notes
...               0.1       FB2419    ying.yw.wu@nokia.com             Creation

# Resource          ../CB008940/resources/robot/CB008940-I-J-Keywords.robot
Resource          ./resources/robot/CB013199-Common-Keywords.robot
Resource          ./resources/robot/CB013199-B-Keywords.robot
Resource          ./resources/robot/CB013199-C-Keywords.robot


Suite Setup       CB013199-Common-Keywords.Suite Setup CB013199
...               yaml_file_path=${CURDIR}/../../../../../custom-config/POOLING/CB013199/CB013199-C/custom_config_13199_IWK_10503_ASOH.yaml




*** Variables ***
&{TC_Params}            nbCell=4

# ---------------------------------------------------------------------------------------------------------------
*** Test Cases ***


[1]CB013199-Auto-UL-Tput-Allocation-Tput-Limit-ASOH-4-Cells-SA-NSA
    [Documentation]     CB013199 IWK with CB010503 (semi static 4/6 higher UL traffic)
    ...                 Conditions:     CB010503 (semi static 4/6 higher UL traffic) 4 SSB Beams +
    ...                                 PRB Pooling Features activated +
    ...                                 CB013199 Tput Pooling Activated
    ...                                 AQOH Half Mode 4 TDD cells mapping info in 1 L1pool
    ...                                 bbmodBoardConfigType=NRFDD_NRTDD
    ...                                 +----------+----------+----------+-----------+
    ...                                 | NRCELL-1 | NRCELL-3 | NRCELL-2 | NRCELL-4  |
    ...                                 +----------+----------+----------------------+
    ...                                 |     L1 SubPoolId=3  | L1 SubPoolId=2       |
    ...                                 +---------------------+----------------------+
    ...                                 |                L1 PoolId=12                |
    ...                                 +---------------------+----------------------+
    ...                 Actions:
    ...                     1) cell setup with 4 TDD cells in one L1pool on half ASOH, Cell 1 (50) is configured with MUMIMO enabled
    ...                     2) Call setup with high UL traffic to trigger the UL Tput Limit hit
    ...                         NRCELL-1 (50) : 2 SA UEs, UE id 1 & 2, each 420mbps UL, UE 1 & 2 will be paired;
    ...                         NRCELL-2 (51) : 1 NSA UE, UE id 3, 280mbps UL
    ...                         NRCELL-3 (52) : 1 NSA UE, UE id 4, 280mbps UL
    ...                         NRCELL-4 (53) : 1 NSA UE, UE id 5, 280mbps UL
    ...                     3) Collect TTI traces & RD counters file
    ...                 Checks:
    ...                     Check in RD counters files, the counters BLOCKED_PUSCH_UE_COUNT & REDUCED_PUSCH_SUBCELL_PRB_COUNT
    ...                     of Cell 1 are supposed to be pegged in case that UL tput limit hits;
    TC CB013199-C-ASOH-SemiStatic-4-6-UL-Traffic                 ${TC_ASOH_SemiStatic_4_6_UE_List}