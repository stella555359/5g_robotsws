*** Settings ***

Documentation     [SUITE PURPOSE]   feature CB013527 Instantaneous Throughput Pooling ecpri72e
...               Prerequisite      : CB09514 (parity ecpri72e) & CB012605 (layer prb pooling ecpri72e)
...               Scope             : cell setup & call setup & PRB and Tput pooling
...
...               Test Case Scenario author   : ying.yw.wu@nokia.com
...               Creation Date               : 03-04-2025
...               Modified Date               : 03-04-2025
...               Last Modified by            : ying.yw.wu@nokia.com
...               Version   Date      Author                             Notes
...               0.1       FB2507    ying.yw.wu@nokia.com             Creation

Resource          ./resources/robot/CB013527-Common-Keywords.robot
Resource          ./resources/robot/CB013527-A-B-Keywords.robot

Suite Setup       Suite Setup from scratch    keepAllUeDataInCfgFile=${True}    listBackupFiles=${FD_ALL}


*** Variables ***
# Custom Config ABIP Tdlte 3ms
${ASOH_SemiStatic_1_4_SCF}       ${CURDIR}/config/customCFG/ASOH/ASOH_SemiStatic_1_4_NRTDD_8_Cells_8DL2UL_In_2_L1_Pools.xml
${ASOH_8_Cells_IPHY}        ${CURDIR}/config/customCFG/ASOH/4_RUs_8_Cells_72e_iphy.xml
${8_UE_CFG}                 ${CURDIR}/config/customCFG/ASOH/basic_setup_8_cells.cfg


# SA 8 UEs, 1 UE per cell, dl 175mbps, ul 75mbps
&{SA_Cell1_DlTput175M_UlTput175M}        callType=SA     targetCell=1     dltput=175     ultput=175     pos_profile=1
&{SA_Cell2_DlTput175M_UlTput75M}         callType=SA     targetCell=2     dltput=175     ultput=75      pos_profile=1
&{SA_Cell3_DlTput175M_UlTput75M}         callType=SA     targetCell=3     dltput=175     ultput=75      pos_profile=1
&{SA_Cell4_DlTput175M_UlTput75M}         callType=SA     targetCell=4     dltput=175     ultput=75      pos_profile=1
&{SA_Cell5_DlTput175M_UlTput15M}         callType=SA     targetCell=5     dltput=175     ultput=15      pos_profile=1
&{SA_Cell6_DlTput175M_UlTput75M}         callType=SA     targetCell=6     dltput=175     ultput=75      pos_profile=1
&{SA_Cell7_DlTput175M_UlTput15M}         callType=SA     targetCell=7     dltput=175     ultput=15      pos_profile=1
&{SA_Cell8_DlTput175M_UlTput75M}         callType=SA     targetCell=8     dltput=175     ultput=75      pos_profile=1

@{TC_A04_UE_Def_DL_UL_List}     ${SA_Cell1_DlTput175M_UlTput175M}
...                             ${SA_Cell2_DlTput175M_UlTput75M}
...                             ${SA_Cell3_DlTput175M_UlTput75M}
...                             ${SA_Cell4_DlTput175M_UlTput75M}
...                             ${SA_Cell5_DlTput175M_UlTput15M}
...                             ${SA_Cell6_DlTput175M_UlTput75M}
...                             ${SA_Cell7_DlTput175M_UlTput15M}
...                             ${SA_Cell8_DlTput175M_UlTput75M}
# ---------------------------------------------------------------------------------------------------------------
*** Test Cases ***

[1]CB013527-A-B-ASOH-SemiStatic-1-4-DL-UL-Throughput-Pooling
    [Documentation]     CB013527 Basic DL+UL Throughput Allocation
    ...                 Conditions:
    ...                     8 TDD Cells on half ASOH, without mumimo cells
    ...                     Layer PRB Pooling Features activated +
    ...                     CB013527 Tput Pooling Activated
    ...                     ASOH Half Mode 8 TDD cells mapping info in 2 L1pools
    ...                     bbmodBoardConfigType=NRFDD_NRTDD
    ...                     +----------+----------+----------+-----------+-----------+-----------+-----------+-----------+
    ...                     | NRCELL-1 | NRCELL-5 | NRCELL-3 | NRCELL-7  |NRCELL-2   |NRCELL-6   |NRCELL-4   |NRCELL-8   |
    ...                     +----------+----------+----------------------+-----------+-----------+-----------+-----------+
    ...                     |     L1 SubPoolId=3  |     L1 SubPoolId=2   |      L1 SubPoolId=0   |       L1 SubPoolId=1  |
    ...                     +---------------------+----------------------------------------------+-----------------------+
    ...                     |                   L1 PoolId=9              |                  L1 PoolId=12                 |
    ...                     +---------------------+----------------------------------------------------------------------+
    ...                 Actions:
    ...                     1) cell setup with CB012605 & CB013527 activated, 8 TDD cells in two L1pools on half ASOH:
    ...                     2) Call setup with Low DL+UL traffic
    ...                         NRCELL-1 (50) : 1 SA UE, UE id 1, DL 175mbps + UL 175mbps;
    ...                         NRCELL-2 (51) : 1 SA UE, UE id 2, DL 175mbps + UL 75mbps;
    ...                         NRCELL-3 (52) : 1 SA UE, UE id 3, DL 175mbps + UL 75mbps;
    ...                         NRCELL-4 (53) : 1 SA UE, UE id 4, DL 175mbps + UL 75mbps;
    ...                         NRCELL-5 (54) : 1 SA UE, UE id 4, DL 175mbps + UL 15mbps;
    ...                         NRCELL-6 (55) : 1 SA UE, UE id 4, DL 175mbps + UL 75mbps;
    ...                         NRCELL-7 (56) : 1 SA UE, UE id 4, DL 175mbps + UL 15mbps;
    ...                         NRCELL-8 (57) : 1 SA UE, UE id 4, DL 175mbps + UL 75mbps;
    ...                     3) Collect TTI traces & gnb snapshot
    ...                 Checks (to do):
    ...                     In TTI traces, at each SFN, for both DL & UL :
    ...                     - the allocated tput on each cell should be >= a predefined min tput value;
    ...                     - the allocated tput sum of all cells should be <= a predefine max tput limit
    Dated Log New Line     ===> To setup  with custom config files
    CB013527 Setup With Custom Config   SCF=${ASOH_SemiStatic_1_4_SCF}
    ...                                 CFG=${8_UE_CFG}
    ...                                 rdParam=@{Rad_Param_CB013527}
    ...                                 IPHY=${ASOH_8_Cells_IPHY}
    ...                                 vendorParam=@{Custom_Vendor_For_Airphone}
    # TC CB013527-DL-UL-Traffic           UEdefListparam=${TC_A04_UE_Def_DL_UL_List}
    TC CB013527-ASOH-DL-UL-Traffic      UEdefListparam=${TC_A04_UE_Def_DL_UL_List}
    #[Teardown]

[1]CB013527-A-B-ASOH-SemiStatic-1-4-DL-UL-Throughput-Pooling-Deactivate
    [Documentation]     CB013527 Basic DL+UL Throughput Allocation
    ...                 Conditions:
    ...                     6 TDD Cells on half ABIP, without mumimo cells
    ...                     Layer PRB Pooling Features activated +
    ...                     CB013527 Tput Pooling DeActivated
    ...                 Same Config & Actions as previous TC with CB013527 activated
    ...                 Checks:
    ...                     Tput allocation not applied, only layer PRB pooling (CB012605) works
    Dated Log New Line     ===> To setup  with custom config files
    CB013527 Setup With Custom Config   SCF=${ASOH_SemiStatic_1_4_SCF}
    ...                                 CFG=${8_UE_CFG}
    ...                                 rdParam=@{Rad_Param_CB013527_Deact}
    ...                                 IPHY=${ASOH_8_Cells_IPHY}
    ...                                 vendorParam=@{Custom_Vendor_For_Airphone}
    TC CB013527-DL-UL-Traffic           UEdefListparam=${UE_Def_DL_UL_List_01}
    #[Teardown]
