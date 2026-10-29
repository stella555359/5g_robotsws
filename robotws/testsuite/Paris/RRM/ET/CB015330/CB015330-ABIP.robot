*** Settings ***

Documentation     [SUITE PURPOSE]   feature CB015530 Instantaneous Throughput Pooling UL improvement
...               Prerequisite      : CB013199 (1st tput pooling feature) & CB015149 (full mode abip 8RX support)
...               Scope             : cell setup & call setup & PRB and Tput pooling
...
...               Test Case Scenario author   : ying.yw.wu@nokia.com
...               Creation Date               : 28-07-2025
...               Modified Date               : 28-07-2025
...               Last Modified by            : ying.yw.wu@nokia.com
...               Version   Date      Author                             Notes
...               0.1       FB2506    ying.yw.wu@nokia.com             Creation
...               0.2       FB2522    ying.yw.wu@nokia.com             TC010 Added in CRT Regression Test

Resource          ./resources/robot/CB015330-Common-Keywords.robot
Resource          ./resources/robot/CB015330-A-Keywords.robot

Suite Setup       Suite Setup from scratch    keepAllUeDataInCfgFile=${True}    listBackupFiles=${FD_ALL}


*** Variables ***
# Custom Config ABIP Tdlte 3ms
${ABIP_Fullmode_Multi_BWP_SCF}       ${CURDIR}/config/customCFG/ABIP/CB015149_ABIP_Fullmode_8DL8UL_8RX_Multi_BWP_100_80_60_SCF.xml
${6_Cells_IPHY}                      ${CURDIR}/config/customCFG/ABIP/6_Cells_iphy.xml
${Basic_Setup_CFG_With_Multi_BWP}                 ${CURDIR}/config/customCFG/ABIP/basic_setup_multi_bwp.cfg

# Custom Config Half ABIP tdlte 0ms
${ABIP_Half_Tdlte_0ms_SCF}       ${CURDIR}/config/customCFG/ABIP/CB015330-Half-ABIP-8DL8UL-4RX-Tdlte-0ms-SCF.xml
${Basic_Setup_CFG_6_Cells}       ${CURDIR}/config/customCFG/ABIP/basic_setup_6_Cells.cfg

# Custom Config Half ABIP Tdlte 3 ms 4RX/8RX mix
${ABIP_Half_Tdlte_3ms_Mix_SCF}       ${CURDIR}/config/customCFG/ABIP/CB015330-Half-ABIP-Tdlte-3ms-4RX-8RX-Mix-SCF.xml

# Custom config Full ABIP 4RX 8RX mix
${ABIP_Full_Tdlte_3ms_Mix_SCF}       ${CURDIR}/config/customCFG/ABIP/CB015330-Full-ABIP-Mix-4RX-8RX-Mix-SCF.xml

# Custom config Full ABIP 8RX
${ABIP_Full_Tdlte_3ms_8RX_SCF}       ${CURDIR}/config/customCFG/ABIP/CB015330-Full-ABIP-8RX-SCF.xml

# Custom Config Half ABIP tdlte 0ms 6 cells 8RX in 2 L1pools
${ABIP_Half_Tdlte_0ms_8RX_SCF}         ${CURDIR}/config/customCFG/ABIP/CB015330-Half-ABIP-8DL8UL-Bbmod-Auto-8Rx-Tdlte-0ms-SCF.xml

# BSR package
&{CB015330_AEQE_6_SSB_8RX_SR_Dic}        BSR_file_name=BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00002.zip
...                                      BSR_folder=BSR

# SA UEs List
&{UE_1_DL175_UL175}         callType=SA     targetCell=1     dltput=175     ultput=175      pos_profile=1
&{UE_2_DL175_UL175}         callType=SA     targetCell=2     dltput=175     ultput=175      pos_profile=1
&{UE_3_DL175_UL175}         callType=SA     targetCell=3     dltput=175     ultput=175      pos_profile=1
&{UE_4_DL175_UL175}         callType=SA     targetCell=4     dltput=175     ultput=175      pos_profile=1
&{UE_5_DL175_UL175}         callType=SA     targetCell=5     dltput=175     ultput=175      pos_profile=1
&{UE_6_DL175_UL175}         callType=SA     targetCell=6     dltput=175     ultput=175      pos_profile=1
&{UE_7_DL175_UL175}         callType=SA     targetCell=1     dltput=175     ultput=175      pos_profile=2
&{UE_8_DL175_UL175}         callType=SA     targetCell=1     dltput=175     ultput=175      pos_profile=2
&{UE_8_2_DL175_UL175}       callType=SA     targetCell=2     dltput=175     ultput=175      pos_profile=2
&{UE_9_1_DL175_UL175}       callType=SA     targetCell=1     dltput=175     ultput=175      pos_profile=2
&{UE_9_DL175_UL175}         callType=SA     targetCell=4     dltput=175     ultput=175      pos_profile=2
&{UE_10_DL175_UL175}        callType=SA     targetCell=6     dltput=175     ultput=175      pos_profile=2

&{UE_1_DL560_UL175}         callType=SA     targetCell=1     dltput=560     ultput=175      pos_profile=1
&{UE_2_DL560_UL175}         callType=SA     targetCell=1     dltput=560     ultput=175      pos_profile=2


@{TC_BWP_UE_List}           ${UE_1_DL175_UL175}
...                         ${UE_2_DL175_UL175}
...                         ${UE_3_DL175_UL175}
...                         ${UE_4_DL175_UL175}
...                         ${UE_5_DL175_UL175}
...                         ${UE_6_DL175_UL175}
...                         ${UE_7_DL175_UL175}
...                         ${UE_8_2_DL175_UL175}
...                         ${UE_9_DL175_UL175}
...                         ${UE_10_DL175_UL175}

@{TC_001_UE_List}           ${UE_1_DL175_UL175}
...                         ${UE_2_DL175_UL175}
...                         ${UE_7_DL175_UL175}
...                         ${UE_8_DL175_UL175}

@{TC_003_Precheck_4_UE_List}          ${UE_1_DL560_UL175}
...                                   ${UE_2_DL560_UL175}

@{TC_004_UE_List}           ${UE_1_DL175_UL175}
...                         ${UE_2_DL175_UL175}
...                         ${UE_3_DL175_UL175}
...                         ${UE_4_DL175_UL175}
...                         ${UE_5_DL175_UL175}
...                         ${UE_6_DL175_UL175}
...                         ${UE_7_DL175_UL175}

@{TC_010_UE_List}           ${UE_1_DL175_UL175}
...                         ${UE_2_DL175_UL175}
...                         ${UE_3_DL175_UL175}
...                         ${UE_4_DL175_UL175}
...                         ${UE_5_DL175_UL175}
...                         ${UE_6_DL175_UL175}
...                         ${UE_7_DL175_UL175}
...                         ${UE_8_DL175_UL175}
...                         ${UE_9_1_DL175_UL175}

@{TC_005_UE_List}           ${UE_1_DL175_UL175}
...                         ${UE_7_DL175_UL175}

@{TC_007_UE_List}           ${UE_1_DL175_UL175}
...                         ${UE_7_DL175_UL175}

${TC001_KPI}                ${CURDIR}/config/CounterKPI/CB015330_TC001_KPI.csv
${TC004_KPI}                ${CURDIR}/config/CounterKPI/CB015330_TC004_KPI.csv
${TC005_KPI}                ${CURDIR}/config/CounterKPI/CB015330_TC005_KPI.csv
${TC003_Precheck_KPI}       ${CURDIR}/config/CounterKPI/CB015330_TC003_Precheck_KPI.csv
${TC007_KPI}                ${CURDIR}/config/CounterKPI/CB015330_TC007_KPI.csv
${TC010_KPI}                ${CURDIR}/config/CounterKPI/CB015330_TC010_KPI.csv
${TC011_KPI}                ${CURDIR}/config/CounterKPI/CB015330_TC011_KPI.csv
# ---------------------------------------------------------------------------------------------------------------
*** Test Cases ***
[1]CB015330-TC001-HALF-ABIP-8DL8UL-4RX-Tdlte-0ms
    [Documentation]     CB015330-TC001-HALF-ABIP-8DL8UL-4RX-Tdlte-0ms
    ...                 Conditions:
    ...                     6 TDD cells 8DL8UL 4RX on Half ABIP
    ...                     Cell 1 :  DL+UL mumimo enabled
    ...                     Cell 2, 3, 4, 5, 6 :  mumimo disabled
    ...                     ABIP Half Mode 6 TDD cells mapping info in 1 L1pool
    ...                     bbmodBoardConfigType=NRFDD_NRTDD
    ...                     +----------+----------+----------+-----------+-----------+-----------+
    ...                     | NRCELL-1 | NRCELL-3 | NRCELL-5 | NRCELL-2  |NRCELL-4   |NRCELL-6   |
    ...                     +----------+----------+----------------------+-----------+-----------+
    ...                     |     L1 SP 3                    |  L1 SP  2                         |
    ...                     +---------------------+----------------------------------------------+
    ...                     |                   L1 PoolId=12                                      |
    ...                     +---------------------+----------------------------------------------+
    ...                 Actions:
    ...                     1) cell setup
    ...                     2) Call setup with Low DL+UL traffic
    ...                         NRCELL-1 (50) : UE 1,7 on cell 1 : 175mbps DL + 175mbps UL;
    ...                         NRCELL-2 (51) : UE 2 on cell 2 :   175mbps DL + 175mbps UL;
    ...                         NRCELL-3 (52) : UE 3 on cell 3 :   175mbps DL + 175mbps UL;
    ...                         NRCELL-4 (53) : UE 4 on cell 4 :   175mbps DL + 175mbps UL;
    ...                         NRCELL-5 (54) : UE 5 on cell 5 :   175mbps DL + 175mbps UL;
    ...                         NRCELL-6 (55) : UE 6 on cell 6 :   175mbps DL + 175mbps UL;
    ...                     4) Collect TTI traces & gnb snapshot
    ...                     5) Collect snapshot
    ...                     6) Collect PMs
    ...                 Checks:
    ...                     In TTI traces, at each SFN, for both DL & UL :
    ...                     - the allocated tput on each cell should be >= a predefined min tput value;
    ...                     - the allocated tput sum of all cells should be <= a predefine max tput limit
    Dated Log New Line     ===> Load BSR file
    CB015330 Load BSR file     ${CB015330_AEQE_6_SSB_8RX_SR_Dic}
    Dated Log New Line     ===> To setup  with custom config files

    CB015330 Setup With Custom Config   SCF=${ABIP_Half_Tdlte_0ms_SCF}
    ...                                 CFG=${Basic_Setup_CFG_6_Cells}
    ...                                 IPHY=${6_Cells_IPHY}
    ...                                 rdParam=@{Rad_Param_CB015330}

    TC CB015330-DL-UL       UEdefListparam=${TC_001_UE_List}
    ...                     Kpi_Csv_File=${TC001_KPI}
    # Restart TL

    #[Teardown]

[1]CB015330-TC001-HALF-ABIP-8DL8UL-4RX-Tdlte-0ms-OFF
    [Documentation]     CB015330-TC001-HALF-ABIP-8DL8UL-4RX-Tdlte-0ms
    ...                 Conditions:
    ...                     6 TDD cells 8DL8UL 8RX on Half ABIP
    ...                     Cell 1 :  DL+UL mumimo enabled
    ...                     Cell 2, 3, 4, 5, 6 :  mumimo disabled
    ...                     ABIP Half Mode 6 TDD cells mapping info in 1 L1pool
    ...                     bbmodBoardConfigType=NRFDD_NRTDD
    ...                     +----------+----------+----------+-----------+-----------+-----------+
    ...                     | NRCELL-1 | NRCELL-3 | NRCELL-5 | NRCELL-2  |NRCELL-4   |NRCELL-6   |
    ...                     +----------+----------+----------------------+-----------+-----------+
    ...                     |     L1 SP 3                    |  L1 SP  2                         |
    ...                     +---------------------+----------------------------------------------+
    ...                     |                   L1 PoolId=9                                      |
    ...                     +---------------------+----------------------------------------------+
    ...                 Actions:
    ...                     1) cell setup
    ...                     2) Call setup with Low DL+UL traffic
    ...                         NRCELL-1 (50) : UE 1,7 on cell 1 : 175mbps DL + 175mbps UL;
    ...                         NRCELL-2 (51) : UE 2 on cell 2 :   175mbps DL + 175mbps UL;
    ...                         NRCELL-3 (52) : UE 3 on cell 3 :   175mbps DL + 175mbps UL;
    ...                         NRCELL-4 (53) : UE 4 on cell 4 :   175mbps DL + 175mbps UL;
    ...                         NRCELL-5 (54) : UE 5 on cell 5 :   175mbps DL + 175mbps UL;
    ...                         NRCELL-6 (55) : UE 6 on cell 6 :   175mbps DL + 175mbps UL;
    ...                     4) Collect TTI traces & gnb snapshot
    ...                     5) Collect snapshot
    ...                     6) Collect PMs
    ...                 Checks:
    ...                     In TTI traces, at each SFN, for both DL & UL :
    ...                     - the allocated tput on each cell should be >= a predefined min tput value;
    ...                     - the allocated tput sum of all cells should be <= a predefine max tput limit
    Dated Log New Line     ===> Load BSR file
    CB015330 Load BSR file     ${CB015330_AEQE_6_SSB_8RX_SR_Dic}
    Dated Log New Line     ===> To setup  with custom config files

    CB015330 Setup With Custom Config   SCF=${ABIP_Half_Tdlte_0ms_SCF}
    ...                                 CFG=${Basic_Setup_CFG_6_Cells}
    ...                                 IPHY=${6_Cells_IPHY}
    ...                                 rdParam=@{Rad_Param_CB015330_OFF}

    TC CB015330-DL-UL       UEdefListparam=${TC_001_UE_List}
    ...                     Kpi_Csv_File=${TC001_KPI}
    # Restart TL

    #[Teardown]

[1]CB015330-TC003-HALF-ABIP-8DL8UL-4RX-8RX-Tdlte-3ms
    [Documentation]     CB015330-TC001-HALF-ABIP-8DL8UL-4RX-8RX-Tdlte-3ms
    ...                 Conditions:
    ...                     6 TDD cells 8DL8UL 4RX 8RX on Half ABIP
    ...                     Cell 1 :  DL+UL mumimo enabled, 8RX
    ...                     Cell 2, 3, 4, 5, 6 :  mumimo disabled, 4RX
    ...                     ABIP Half Mode 6 TDD cells mapping info in 1 L1pool
    ...                     bbmodBoardConfigType=NRFDD_NRTDD
    ...                     +----------+----------+----------+-----------+-----------+-----------+
    ...                     | NRCELL-1 | NRCELL-3 | NRCELL-5 | NRCELL-2  |NRCELL-4   |NRCELL-6   |
    ...                     +----------+----------+----------------------+-----------+-----------+
    ...                     |     L1 SP 3                    |  L1 SP  2                         |
    ...                     +---------------------+----------------------------------------------+
    ...                     |                   L1 PoolId=9                                      |
    ...                     +---------------------+----------------------------------------------+
    ...                 Actions:
    ...                     1) cell setup
    ...                     2) Call setup with Low DL+UL traffic
    ...                         NRCELL-1 (50) : UE 1,7 on cell 1 : 175mbps DL + 175mbps UL;
    ...                         NRCELL-2 (51) : UE 2 on cell 2 :   175mbps DL + 175mbps UL;
    ...                         NRCELL-3 (52) : UE 3 on cell 3 :   175mbps DL + 175mbps UL;
    ...                         NRCELL-4 (53) : UE 4 on cell 4 :   175mbps DL + 175mbps UL;
    ...                         NRCELL-5 (54) : UE 5 on cell 5 :   175mbps DL + 175mbps UL;
    ...                         NRCELL-6 (55) : UE 6 on cell 6 :   175mbps DL + 175mbps UL;
    ...                     4) Collect TTI traces & gnb snapshot
    ...                     5) Collect snapshot
    ...                     6) Collect PMs
    ...                 Checks:
    ...                     In TTI traces, at each SFN, for both DL & UL :
    ...                     - the allocated tput on each cell should be >= a predefined min tput value;
    ...                     - the allocated tput sum of all cells should be <= a predefine max tput limit
    Dated Log New Line     ===> Load BSR file
    CB015330 Load BSR file     ${CB015330_AEQE_6_SSB_8RX_SR_Dic}
    Dated Log New Line     ===> To setup  with custom config files

    CB015330 Setup With Custom Config   SCF=${ABIP_Half_Tdlte_3ms_Mix_SCF}
    ...                                 CFG=${Basic_Setup_CFG_6_Cells}
    ...                                 IPHY=${6_Cells_IPHY}
    ...                                 rdParam=@{Rad_Param_CB015330}

    TC CB015330-DL-UL       UEdefListparam=${TC_003_Precheck_4_UE_List}
    ...                     Kpi_Csv_File=${TC003_Precheck_KPI}
    # Restart TL

    #[Teardown]

[1]CB015330-TC003-HALF-ABIP-8DL8UL-4RX-8RX-Tdlte-3ms-OFF
    [Documentation]     CB015330-TC001-HALF-ABIP-8DL8UL-4RX-8RX-Tdlte-3ms
    ...                 Conditions:
    ...                     6 TDD cells 8DL8UL 4RX 8RX on Half ABIP
    ...                     Cell 1 :  DL+UL mumimo enabled, 8RX
    ...                     Cell 2, 3, 4, 5, 6 :  mumimo disabled, 4RX
    ...                     ABIP Half Mode 6 TDD cells mapping info in 1 L1pool
    ...                     bbmodBoardConfigType=NRFDD_NRTDD
    ...                     +----------+----------+----------+-----------+-----------+-----------+
    ...                     | NRCELL-1 | NRCELL-3 | NRCELL-5 | NRCELL-2  |NRCELL-4   |NRCELL-6   |
    ...                     +----------+----------+----------------------+-----------+-----------+
    ...                     |     L1 SP 3                    |  L1 SP  2                         |
    ...                     +---------------------+----------------------------------------------+
    ...                     |                   L1 PoolId=9                                      |
    ...                     +---------------------+----------------------------------------------+
    ...                 Actions:
    ...                     1) cell setup
    ...                     2) Call setup with Low DL+UL traffic
    ...                         NRCELL-1 (50) : UE 1,7 on cell 1 : 175mbps DL + 175mbps UL;
    ...                         NRCELL-2 (51) : UE 2 on cell 2 :   175mbps DL + 175mbps UL;
    ...                         NRCELL-3 (52) : UE 3 on cell 3 :   175mbps DL + 175mbps UL;
    ...                         NRCELL-4 (53) : UE 4 on cell 4 :   175mbps DL + 175mbps UL;
    ...                         NRCELL-5 (54) : UE 5 on cell 5 :   175mbps DL + 175mbps UL;
    ...                         NRCELL-6 (55) : UE 6 on cell 6 :   175mbps DL + 175mbps UL;
    ...                     4) Collect TTI traces & gnb snapshot
    ...                     5) Collect snapshot
    ...                     6) Collect PMs
    ...                 Checks:
    ...                     In TTI traces, at each SFN, for both DL & UL :
    ...                     - the allocated tput on each cell should be >= a predefined min tput value;
    ...                     - the allocated tput sum of all cells should be <= a predefine max tput limit
    Dated Log New Line     ===> Load BSR file
    CB015330 Load BSR file     ${CB015330_AEQE_6_SSB_8RX_SR_Dic}
    Dated Log New Line     ===> To setup  with custom config files

    CB015330 Setup With Custom Config   SCF=${ABIP_Half_Tdlte_3ms_Mix_SCF}
    ...                                 CFG=${Basic_Setup_CFG_6_Cells}
    ...                                 IPHY=${6_Cells_IPHY}
    ...                                 rdParam=@{Rad_Param_CB015330_OFF}

    TC CB015330-DL-UL       UEdefListparam=${TC_003_Precheck_4_UE_List}
    ...                     Kpi_Csv_File=${TC003_Precheck_KPI}
    # Restart TL

    #[Teardown]


[1]CB015330-TC004-FULL-ABIP-8DL8UL-4RX-8RX-Tdlte-3ms
    [Documentation]     CB015330-TC004-Full-ABIP-8DL8UL-4RX-8RX-Tdlte-3ms
    ...                 Conditions:
    ...                     6 TDD cells 8DL8UL 4RX 8RX on Half ABIP
    ...                     Cell 1 :  DL+UL mumimo enabled, 8RX
    ...                     Cell 2, 3, 4, 5, 6 :  mumimo disabled, 4RX
    ...                     ABIP Half Mode 6 TDD cells mapping info in 1 L1pool
    ...                     bbmodBoardConfigType=NRTDD_Fullmode
    ...                     +----------+----------+----------+-----------+-----------+-----------+
    ...                     | NRCELL-1 | NRCELL-3 | NRCELL-5 | NRCELL-2  |NRCELL-4   |NRCELL-6   |
    ...                     +----------+----------+----------------------+-----------+-----------+
    ...                     |     L1 SP 3                    |  L1 SP  2                         |
    ...                     +---------------------+----------------------------------------------+
    ...                     |                   L1 PoolId=9                                      |
    ...                     +---------------------+----------------------------------------------+
    ...                 Actions:
    ...                     1) cell setup
    ...                     2) Call setup with Low DL+UL traffic
    ...                         NRCELL-1 (50) : UE 1,7 on cell 1 : 175mbps DL + 175mbps UL;
    ...                         NRCELL-2 (51) : UE 2 on cell 2 :   175mbps DL + 175mbps UL;
    ...                         NRCELL-3 (52) : UE 3 on cell 3 :   175mbps DL + 175mbps UL;
    ...                         NRCELL-4 (53) : UE 4 on cell 4 :   175mbps DL + 175mbps UL;
    ...                         NRCELL-5 (54) : UE 5 on cell 5 :   175mbps DL + 175mbps UL;
    ...                         NRCELL-6 (55) : UE 6 on cell 6 :   175mbps DL + 175mbps UL;
    ...                     4) Collect TTI traces & gnb snapshot
    ...                     5) Collect snapshot
    ...                     6) Collect PMs
    ...                 Checks:
    ...                     In TTI traces, at each SFN, for both DL & UL :
    ...                     - the allocated tput on each cell should be >= a predefined min tput value;
    ...                     - the allocated tput sum of all cells should be <= a predefine max tput limit
    Dated Log New Line     ===> Load BSR file
    CB015330 Load BSR file     ${CB015330_AEQE_6_SSB_8RX_SR_Dic}
    Dated Log New Line     ===> To setup  with custom config files

    CB015330 Setup With Custom Config   SCF=${ABIP_Full_Tdlte_3ms_Mix_SCF}
    ...                                 CFG=${Basic_Setup_CFG_6_Cells}
    ...                                 IPHY=${6_Cells_IPHY}
    ...                                 rdParam=@{Rad_Param_CB015330}

    TC CB015330-DL-UL       UEdefListparam=${TC_004_UE_List}
    ...                     Kpi_Csv_File=${TC004_KPI}


[1]CB015330-TC004-FULL-ABIP-8DL8UL-4RX-8RX-Tdlte-3ms-OFF
    [Documentation]     CB015330-TC001-HALF-ABIP-8DL8UL-4RX-8RX-Tdlte-3ms
    ...                 Conditions:
    ...                     6 TDD cells 8DL8UL 4RX 8RX on Half ABIP
    ...                     Cell 1 :  DL+UL mumimo enabled, 8RX
    ...                     Cell 2, 3, 4, 5, 6 :  mumimo disabled, 4RX
    ...                     ABIP Half Mode 6 TDD cells mapping info in 1 L1pool
    ...                     bbmodBoardConfigType=NRTDD_Fullmode
    ...                     +----------+----------+----------+-----------+-----------+-----------+
    ...                     | NRCELL-1 | NRCELL-3 | NRCELL-5 | NRCELL-2  |NRCELL-4   |NRCELL-6   |
    ...                     +----------+----------+----------------------+-----------+-----------+
    ...                     |     L1 SP 3                    |  L1 SP  2                         |
    ...                     +---------------------+----------------------------------------------+
    ...                     |                   L1 PoolId=9                                      |
    ...                     +---------------------+----------------------------------------------+
    ...                 Actions:
    ...                     1) cell setup
    ...                     2) Call setup with Low DL+UL traffic
    ...                         NRCELL-1 (50) : UE 1,7 on cell 1 : 175mbps DL + 175mbps UL;
    ...                         NRCELL-2 (51) : UE 2 on cell 2 :   175mbps DL + 175mbps UL;
    ...                         NRCELL-3 (52) : UE 3 on cell 3 :   175mbps DL + 175mbps UL;
    ...                         NRCELL-4 (53) : UE 4 on cell 4 :   175mbps DL + 175mbps UL;
    ...                         NRCELL-5 (54) : UE 5 on cell 5 :   175mbps DL + 175mbps UL;
    ...                         NRCELL-6 (55) : UE 6 on cell 6 :   175mbps DL + 175mbps UL;
    ...                     4) Collect TTI traces & gnb snapshot
    ...                     5) Collect snapshot
    ...                     6) Collect PMs
    ...                 Checks:
    ...                     In TTI traces, at each SFN, for both DL & UL :
    ...                     - the allocated tput on each cell should be >= a predefined min tput value;
    ...                     - the allocated tput sum of all cells should be <= a predefine max tput limit
    Dated Log New Line     ===> Load BSR file
    CB015330 Load BSR file     ${CB015330_AEQE_6_SSB_8RX_SR_Dic}
    Dated Log New Line     ===> To setup  with custom config files

    CB015330 Setup With Custom Config   SCF=${ABIP_Full_Tdlte_3ms_Mix_SCF}
    ...                                 CFG=${Basic_Setup_CFG_6_Cells}
    ...                                 IPHY=${6_Cells_IPHY}
    ...                                 rdParam=@{Rad_Param_CB015330_OFF}

    TC CB015330-DL-UL       UEdefListparam=${TC_004_UE_List}
    ...                     Kpi_Csv_File=${TC004_KPI}


[1]CB015330-TC007-FULL-ABIP-8DL8UL-8RX-Tdlte-3ms
    [Documentation]     CB015330-TC004-Full-ABIP-8DL8UL-8RX-Tdlte-3ms
    ...                 Conditions:
    ...                     6 TDD cells 8DL8UL 8RX on Full ABIP
    ...                     Cell 1 :  DL+UL mumimo enabled, 8RX
    ...                     Cell 2, 3, 4, 5, 6 :  mumimo disabled, 8RX
    ...                     ABIP Half Mode 6 TDD cells mapping info in 1 L1pool
    ...                     bbmodBoardConfigType=NRTDD_Fullmode
    ...                     +----------+----------+----------+-----------+-----------+-----------+
    ...                     | NRCELL-1 | NRCELL-3 | NRCELL-5 | NRCELL-2  |NRCELL-4   |NRCELL-6   |
    ...                     +----------+----------+----------------------+-----------+-----------+
    ...                     |     L1 SP 3                    |  L1 SP  2                         |
    ...                     +---------------------+----------------------------------------------+
    ...                     |                   L1 PoolId=9                                      |
    ...                     +---------------------+----------------------------------------------+
    ...                 Actions:
    ...                     1) cell setup
    ...                     2) Call setup with Low DL+UL traffic
    ...                         NRCELL-1 (50) : UE 1,7 on cell 1 : 175mbps DL + 175mbps UL;
    ...                         NRCELL-2 (51) : UE 2 on cell 2 :   175mbps DL + 175mbps UL;
    ...                         NRCELL-3 (52) : UE 3 on cell 3 :   175mbps DL + 175mbps UL;
    ...                         NRCELL-4 (53) : UE 4 on cell 4 :   175mbps DL + 175mbps UL;
    ...                         NRCELL-5 (54) : UE 5 on cell 5 :   175mbps DL + 175mbps UL;
    ...                         NRCELL-6 (55) : UE 6 on cell 6 :   175mbps DL + 175mbps UL;
    ...                     4) Collect TTI traces & gnb snapshot
    ...                     5) Collect snapshot
    ...                     6) Collect PMs
    ...                 Checks:
    ...                     In TTI traces, at each SFN, for both DL & UL :
    ...                     - the allocated tput on each cell should be >= a predefined min tput value;
    ...                     - the allocated tput sum of all cells should be <= a predefine max tput limit
    Dated Log New Line     ===> Load BSR file
    CB015330 Load BSR file     ${CB015330_AEQE_6_SSB_8RX_SR_Dic}
    Dated Log New Line     ===> To setup  with custom config files

    CB015330 Setup With Custom Config   SCF=${ABIP_Full_Tdlte_3ms_8RX_SCF}
    ...                                 CFG=${Basic_Setup_CFG_6_Cells}
    ...                                 IPHY=${6_Cells_IPHY}
    ...                                 rdParam=@{Rad_Param_CB015330_TC008}

    TC CB015330-DL-UL       UEdefListparam=${TC_007_UE_List}
    ...                     Kpi_Csv_File=${TC007_KPI}


[1]CB015330-TC007-FULL-ABIP-8DL8UL-8RX-Tdlte-3ms-OFF
    [Documentation]     CB015330-TC004-Full-ABIP-8DL8UL-8RX-Tdlte-3ms
    ...                 Conditions:
    ...                     6 TDD cells 8DL8UL 8RX on Full ABIP
    ...                     Cell 1 :  DL+UL mumimo enabled, 8RX
    ...                     Cell 2, 3, 4, 5, 6 :  mumimo disabled, 8RX
    ...                     ABIP Half Mode 6 TDD cells mapping info in 1 L1pool
    ...                     bbmodBoardConfigType=NRTDD_Fullmode
    ...                     +----------+----------+----------+-----------+-----------+-----------+
    ...                     | NRCELL-1 | NRCELL-3 | NRCELL-5 | NRCELL-2  |NRCELL-4   |NRCELL-6   |
    ...                     +----------+----------+----------------------+-----------+-----------+
    ...                     |     L1 SP 3                    |  L1 SP  2                         |
    ...                     +---------------------+----------------------------------------------+
    ...                     |                   L1 PoolId=9                                      |
    ...                     +---------------------+----------------------------------------------+
    ...                 Actions:
    ...                     1) cell setup
    ...                     2) Call setup with Low DL+UL traffic
    ...                         NRCELL-1 (50) : UE 1,7 on cell 1 : 175mbps DL + 175mbps UL;
    ...                         NRCELL-2 (51) : UE 2 on cell 2 :   175mbps DL + 175mbps UL;
    ...                         NRCELL-3 (52) : UE 3 on cell 3 :   175mbps DL + 175mbps UL;
    ...                         NRCELL-4 (53) : UE 4 on cell 4 :   175mbps DL + 175mbps UL;
    ...                         NRCELL-5 (54) : UE 5 on cell 5 :   175mbps DL + 175mbps UL;
    ...                         NRCELL-6 (55) : UE 6 on cell 6 :   175mbps DL + 175mbps UL;
    ...                     4) Collect TTI traces & gnb snapshot
    ...                     5) Collect snapshot
    ...                     6) Collect PMs
    ...                 Checks:
    ...                     In TTI traces, at each SFN, for both DL & UL :
    ...                     - the allocated tput on each cell should be >= a predefined min tput value;
    ...                     - the allocated tput sum of all cells should be <= a predefine max tput limit
    Dated Log New Line     ===> Load BSR file
    CB015330 Load BSR file     ${CB015330_AEQE_6_SSB_8RX_SR_Dic}
    Dated Log New Line     ===> To setup  with custom config files

    CB015330 Setup With Custom Config   SCF=${ABIP_Full_Tdlte_3ms_8RX_SCF}
    ...                                 CFG=${Basic_Setup_CFG_6_Cells}
    ...                                 IPHY=${6_Cells_IPHY}
    ...                                 rdParam=@{Rad_Param_CB015330_OFF_TC008}

    TC CB015330-DL-UL       UEdefListparam=${TC_007_UE_List}
    ...                     Kpi_Csv_File=${TC007_KPI}

[1]CB015330-TC005-HALF-ABIP-8DL8UL-8RX-Tdlte-0ms
    [Documentation]     CB015330-TC001-HALF-ABIP-8DL8UL-4RX-Tdlte-0ms
    ...                 Conditions:
    ...                     6 TDD cells 8DL8UL 4RX on Half ABIP
    ...                     Cell 1 :  DL+UL mumimo enabled
    ...                     Cell 2, 3, 4, 5, 6 :  mumimo disabled
    ...                     ABIP Half Mode 6 TDD cells mapping info in 2 L1pools
    ...                     bbmodBoardConfigType=Auto
    ...                     +----------+----------+----------+-----------+-----------+-----------+
    ...                     | NRCELL-1 | NRCELL-3 | NRCELL-5 | NRCELL-2  |NRCELL-4   |NRCELL-6   |
    ...                     +----------+----------+----------------------+-----------+-----------+
    ...                     |     L1 SP 3         |  L1 SP  2| L1 SP1                | L1 SP 0   |
    ...                     +---------------------+----------------------------------------------+
    ...                     |                   L1 PoolId=9  |     L1 PoolId=12                  |
    ...                     +---------------------+----------------------------------------------+
    ...                 Actions:
    ...                     1) cell setup
    ...                     2) Call setup with Low DL+UL traffic
    ...                         NRCELL-1 (50) : UE 1,7 on cell 1 : 175mbps DL + 175mbps UL;
    ...                     4) Collect TTI traces & gnb snapshot
    ...                     5) Collect snapshot
    ...                     6) Collect PMs
    ...                 Checks:
    ...                     In TTI traces, at each SFN, for both DL & UL :
    ...                     - the allocated tput on each cell should be >= a predefined min tput value;
    ...                     - the allocated tput sum of all cells should be <= a predefine max tput limit
    Dated Log New Line     ===> Load BSR file
    CB015330 Load BSR file     ${CB015330_AEQE_6_SSB_8RX_SR_Dic}
    Dated Log New Line     ===> To setup  with custom config files

    CB015330 Setup With Custom Config   SCF=${ABIP_Half_Tdlte_0ms_8RX_SCF}
    ...                                 CFG=${Basic_Setup_CFG_6_Cells}
    ...                                 IPHY=${6_Cells_IPHY}
    ...                                 rdParam=@{Rad_Param_CB015330}

    TC CB015330-DL-UL       UEdefListparam=${TC_005_UE_List}
    ...                     Kpi_Csv_File=${TC005_KPI}

[1]CB015330-TC005-HALF-ABIP-8DL8UL-8RX-Tdlte-0ms-OFF
    [Documentation]     CB015330-TC001-HALF-ABIP-8DL8UL-4RX-Tdlte-0ms
    ...                 Conditions:
    ...                     6 TDD cells 8DL8UL 4RX on Half ABIP
    ...                     Cell 1 :  DL+UL mumimo enabled
    ...                     Cell 2, 3, 4, 5, 6 :  mumimo disabled
    ...                     ABIP Half Mode 6 TDD cells mapping info in 2 L1pools
    ...                     bbmodBoardConfigType=Auto
    ...                     +----------+----------+----------+-----------+-----------+-----------+
    ...                     | NRCELL-1 | NRCELL-5 | NRCELL-2 | NRCELL-3  |NRCELL-6   |NRCELL-4   |
    ...                     +----------+----------+----------------------+-----------+-----------+
    ...                     |     L1 SP 0         |  L1 SP  1| L1 SP2                | L1 SP 3   |
    ...                     +---------------------+----------------------------------------------+
    ...                     |                   L1 PoolId=9  |     L1 PoolId=12                  |
    ...                     +---------------------+----------------------------------------------+
    ...                 Actions:
    ...                     1) cell setup
    ...                     2) Call setup with Low DL+UL traffic
    ...                         NRCELL-1 (50) : UE 1,7 on cell 1 : 175mbps DL + 175mbps UL;
    ...                     4) Collect TTI traces & gnb snapshot
    ...                     5) Collect snapshot
    ...                     6) Collect PMs
    ...                 Checks:
    ...                     In TTI traces, at each SFN, for both DL & UL :
    ...                     - the allocated tput on each cell should be >= a predefined min tput value;
    ...                     - the allocated tput sum of all cells should be <= a predefine max tput limit
    Dated Log New Line     ===> Load BSR file
    CB015330 Load BSR file     ${CB015330_AEQE_6_SSB_8RX_SR_Dic}
    Dated Log New Line     ===> To setup  with custom config files

    CB015330 Setup With Custom Config   SCF=${ABIP_Half_Tdlte_0ms_8RX_SCF}
    ...                                 CFG=${Basic_Setup_CFG_6_Cells}
    ...                                 IPHY=${6_Cells_IPHY}
    ...                                 rdParam=@{Rad_Param_CB015330_OFF}

    TC CB015330-DL-UL       UEdefListparam=${TC_005_UE_List}
    ...                     Kpi_Csv_File=${TC005_KPI}



[1]CB015330-TC010-FULL-ABIP-8DL8UL-4RX-8RX-Tdlte-3ms
    [Documentation]     CB015330-TC004-Full-ABIP-8DL8UL-4RX-8RX-Tdlte-3ms
    ...                 Conditions:
    ...                     6 TDD cells 8DL8UL 4RX 8RX on Half ABIP
    ...                     Cell 1 :  DL+UL mumimo enabled, 8RX
    ...                     Cell 2, 3, 4, 5, 6 :  mumimo disabled, 4RX
    ...                     ABIP Half Mode 6 TDD cells mapping info in 1 L1pool
    ...                     bbmodBoardConfigType=NRTDD_Fullmode
    ...                     +----------+----------+----------+-----------+-----------+-----------+
    ...                     | NRCELL-1 | NRCELL-3 | NRCELL-5 | NRCELL-2  |NRCELL-4   |NRCELL-6   |
    ...                     +----------+----------+----------------------+-----------+-----------+
    ...                     |     L1 SP 3                    |  L1 SP  2                         |
    ...                     +---------------------+----------------------------------------------+
    ...                     |                   L1 PoolId=9                                      |
    ...                     +---------------------+----------------------------------------------+
    ...                 Actions:
    ...                     1) cell setup
    ...                     2) Call setup with Low DL+UL traffic
    ...                         NRCELL-1 (50) : UE 1,7,8 on cell 1 : 175mbps DL + 175mbps UL;
    ...                         NRCELL-2 (51) : UE 2 on cell 2 :   175mbps DL + 175mbps UL;
    ...                         NRCELL-3 (52) : UE 3 on cell 3 :   175mbps DL + 175mbps UL;
    ...                         NRCELL-4 (53) : UE 4 on cell 4 :   175mbps DL + 175mbps UL;
    ...                         NRCELL-5 (54) : UE 5 on cell 5 :   175mbps DL + 175mbps UL;
    ...                         NRCELL-6 (55) : UE 6 on cell 6 :   175mbps DL + 175mbps UL;
    ...                     4) Collect TTI traces & gnb snapshot
    ...                     5) Collect snapshot
    ...                     6) Collect PMs
    ...                 Checks:
    ...                     In TTI traces, at each SFN, for both DL & UL :
    ...                     - the allocated tput on each cell should be >= a predefined min tput value;
    ...                     - the allocated tput sum of all cells should be <= a predefine max tput limit
    Dated Log New Line     ===> Load BSR file
    CB015330 Load BSR file     ${CB015330_AEQE_6_SSB_8RX_SR_Dic}
    Dated Log New Line     ===> To setup  with custom config files

    CB015330 Setup With Custom Config   SCF=${ABIP_Full_Tdlte_3ms_Mix_SCF}
    ...                                 CFG=${Basic_Setup_CFG_6_Cells}
    ...                                 IPHY=${6_Cells_IPHY}
    ...                                 rdParam=@{Rad_Param_CB015330}

    TC CB015330-DL-UL-TC010       UEdefListparam=${TC_010_UE_List}
    ...                     Kpi_Csv_File=${TC010_KPI}


[1]CB015330-TC010-FULL-ABIP-8DL8UL-4RX-8RX-Tdlte-3ms-OFF
    [Documentation]     CB015330-TC004-Full-ABIP-8DL8UL-4RX-8RX-Tdlte-3ms
    ...                 Conditions:
    ...                     6 TDD cells 8DL8UL 4RX 8RX on Half ABIP
    ...                     Cell 1 :  DL+UL mumimo enabled, 8RX
    ...                     Cell 2, 3, 4, 5, 6 :  mumimo disabled, 4RX
    ...                     ABIP Half Mode 6 TDD cells mapping info in 1 L1pool
    ...                     bbmodBoardConfigType=NRTDD_Fullmode
    ...                     +----------+----------+----------+-----------+-----------+-----------+
    ...                     | NRCELL-1 | NRCELL-4 | NRCELL-2 | NRCELL-6  |NRCELL-3   |NRCELL-5   |
    ...                     +----------+----------+----------------------+-----------+-----------+
    ...                     |     L1 SP 2         |  L1 SP  0            |   L1 SP 3 | L1 SP 1   |
    ...                     +---------------------+----------------------------------------------+
    ...                     |                   L1 PoolId=9                                      |
    ...                     +---------------------+----------------------------------------------+
    ...                 Actions:
    ...                     1) cell setup
    ...                     2) Call setup with Low DL+UL traffic
    ...                         NRCELL-1 (50) : UE 1,7,8,9 on cell 1 : 175mbps DL + 175mbps UL;
    ...                         NRCELL-2 (51) : UE 2 on cell 2 :   175mbps DL + 175mbps UL;
    ...                         NRCELL-3 (52) : UE 3 on cell 3 :   175mbps DL + 175mbps UL;
    ...                         NRCELL-4 (53) : UE 4 on cell 4 :   175mbps DL + 175mbps UL;
    ...                         NRCELL-5 (54) : UE 5 on cell 5 :   175mbps DL + 175mbps UL;
    ...                         NRCELL-6 (55) : UE 6 on cell 6 :   175mbps DL + 175mbps UL;
    ...                     4) Collect TTI traces & gnb snapshot
    ...                     5) Collect snapshot
    ...                     6) Collect PMs
    ...                 Checks:
    ...                     In TTI traces, at each SFN, in event ulAllocatedPooledResourcesData :
    ...                     - the allocated tput on each cell should be >= a predefined min tput value;(CB013199)
    ...                     - the allocated tput sum of all cells should be <= a predefine max tput limit(CB013199)
    ...                     - If in the same sfn, the sum of the values of allocCellThroughputUl > maxThresholdTputAlloc,
    ...                       then expected value of the colomn "ulCellTpRedFactorInSch" of each cell in the sfn should be 0.75,
    ...                       otherwise the expected value of the "ulCellTpRedFactorInSch" should be 1;(CB015330)
    ...                     - check KPI NR_5089 and NR_5088 has non zero values
    ...                     - Check KPI DL/UL BLER (This test introduced pathloss test mode, there will be expected BLER)

    Dated Log New Line     ===> Load BSR file
    CB015330 Load BSR file     ${CB015330_AEQE_6_SSB_8RX_SR_Dic}
    Dated Log New Line     ===> To setup  with custom config files

    CB015330 Setup With Custom Config   SCF=${ABIP_Full_Tdlte_3ms_Mix_SCF}
    ...                                 CFG=${Basic_Setup_CFG_6_Cells}
    ...                                 IPHY=${6_Cells_IPHY}
    ...                                 rdParam=@{Rad_Param_CB015330_OFF}

    TC CB015330-DL-UL-TC010       UEdefListparam=${TC_010_UE_List}
    ...                     Kpi_Csv_File=${TC010_KPI}


[1]CB015330-TC011-ABIP-Fullmode-8RX-IWK-CB08954-With-Mumimo
    [Documentation]     CB015330-ABIP-Fullmode-8RX-IWK-CB08954-With-Mumimo
    ...                 Conditions:
    ...                     6 TDD cells 8DL8UL 8RX on Full ABIP
    ...                     Cell 1 :  DL+UL mumimo enabled
    ...                     Cell 2, 3, 4 : UL mumimo enabled
    ...                     ABIP Full Mode 6 TDD cells mapping info in 1 L1pool
    ...                     bbmodBoardConfigType=NRTDD_Fullmode
    ...                     +----------+----------+----------+-----------+-----------+-----------+
    ...                     | NRCELL-1 | NRCELL-4 | NRCELL-2 | NRCELL-6  |NRCELL-3   |NRCELL-5   |
    ...                     +----------+----------+----------------------+-----------+-----------+
    ...                     |     L1 SP 2         |   L1 SP 0            |  L1 SP 3  | L1 SP 1   |           |
    ...                     +---------------------+----------------------------------------------+
    ...                     |                   L1 PoolId=9                                      |
    ...                     +---------------------+----------------------------------------------+
    ...                 Actions:
    ...                     1) cell setup
    ...                     2) Call setup with Low DL+UL traffic
    ...                         NRCELL-1 (50) : UE 1,7 on cell 1 : 175mbps DL + 175mbps UL,
    ...                                         UE 1 supports large BWP 100Mhz, UE 7 supports only small BWP 60Mhz
    ...                         NRCELL-2 (51) : UE 2,8 on cell 2 : 175mbps DL + 175mbps UL;
    ...                         NRCELL-3 (52) : UE 3 on cell 3 :   175mbps DL + 175mbps UL;
    ...                         NRCELL-4 (53) : UE 4,9 on cell 4 : 175mbps DL + 175mbps UL;
    ...                         NRCELL-5 (54) : UE 5 on cell 5 :   175mbps DL + 175mbps UL;
    ...                         NRCELL-6 (55) : UE 6,10 on cell 6: 175mbps DL + 175mbps UL, UE 6 supports large BWP 100Mhz,
    ...                                         UE 10 supports only medium BWP 80Mhz
    ...                     4) Collect TTI traces & gnb snapshot
    ...                     5) Collect snapshot
    ...                     6) Collect PMs
    ...                 Checks:
    ...                     In TTI traces, at each SFN, for both DL & UL :
    ...                     - the allocated tput on each cell should be >= a predefined min tput value;
    ...                     - the allocated tput sum of all cells should be <= a predefine max tput limit
    Dated Log New Line     ===> Load BSR file
    CB015330 Load BSR file     ${CB015330_AEQE_6_SSB_8RX_SR_Dic}
    Dated Log New Line     ===> To setup  with custom config files

    CB015330 Setup With Custom Config   SCF=${ABIP_Fullmode_Multi_BWP_SCF}
    ...                                 CFG=${Basic_Setup_CFG_With_Multi_BWP}
    ...                                 IPHY=${6_Cells_IPHY}
    ...                                 rdParam=@{Rad_Param_CB015330}

    TC CB015330-A-Multi-BWP-DL-UL       UEdefListparam=${TC_BWP_UE_List}
    ...                     Kpi_Csv_File=${TC011_KPI}
    # Restart TL

    #[Teardown]


[1]CB015330-TC011-ABIP-Fullmode-8RX-IWK-CB08954-With-Mumimo-OFF
    [Documentation]     CB015330-ABIP-Fullmode-8RX-IWK-CB08954-With-Mumimo
    ...                 Conditions:
    ...                     6 TDD cells 8DL8UL 8RX on Full ABIP
    ...                     Cell 1 :  DL+UL mumimo enabled
    ...                     Cell 2, 3, 4 : UL mumimo enabled
    ...                     ABIP Full Mode 6 TDD cells mapping info in 1 L1pool
    ...                     bbmodBoardConfigType=NRTDD_Fullmode
    ...                     +----------+----------+----------+-----------+-----------+-----------+
    ...                     | NRCELL-1 | NRCELL-4 | NRCELL-2 | NRCELL-6  |NRCELL-3   |NRCELL-5   |
    ...                     +----------+----------+----------------------+-----------+-----------+
    ...                     |     L1 SP 2         |   L1 SP 0            |  L1 SP 3  | L1 SP 1   |           |
    ...                     +---------------------+----------------------------------------------+
    ...                     |                   L1 PoolId=9                                      |
    ...                     +---------------------+----------------------------------------------+
    ...                 Actions:
    ...                     1) cell setup
    ...                     2) Call setup with Low DL+UL traffic
    ...                         NRCELL-1 (50) : UE 1,7 on cell 1 : 175mbps DL + 175mbps UL,
    ...                                         UE 1 supports large BWP 100Mhz, UE 7 supports only small BWP 60Mhz
    ...                         NRCELL-2 (51) : UE 2,8 on cell 2 : 175mbps DL + 175mbps UL;
    ...                         NRCELL-3 (52) : UE 3 on cell 3 :   175mbps DL + 175mbps UL;
    ...                         NRCELL-4 (53) : UE 4,9 on cell 4 : 175mbps DL + 175mbps UL;
    ...                         NRCELL-5 (54) : UE 5 on cell 5 :   175mbps DL + 175mbps UL;
    ...                         NRCELL-6 (55) : UE 6,10 on cell 6: 175mbps DL + 175mbps UL, UE 6 supports large BWP 100Mhz,
    ...                                         UE 10 supports only medium BWP 80Mhz
    ...                     4) Collect TTI traces & gnb snapshot
    ...                     5) Collect snapshot
    ...                     6) Collect PMs
    ...                 Checks:
    ...                     In TTI traces, at each SFN, for both DL & UL :
    ...                     - the allocated tput on each cell should be >= a predefined min tput value;
    ...                     - the allocated tput sum of all cells should be <= a predefine max tput limit
    Dated Log New Line     ===> Load BSR file
    CB015330 Load BSR file     ${CB015330_AEQE_6_SSB_8RX_SR_Dic}
    Dated Log New Line     ===> To setup  with custom config files

    CB015330 Setup With Custom Config   SCF=${ABIP_Fullmode_Multi_BWP_SCF}
    ...                                 CFG=${Basic_Setup_CFG_With_Multi_BWP}
    ...                                 IPHY=${6_Cells_IPHY}
    ...                                 rdParam=@{Rad_Param_CB015330_OFF}

    TC CB015330-A-Multi-BWP-DL-UL       UEdefListparam=${TC_BWP_UE_List}
    ...                     Kpi_Csv_File=${TC011_KPI}
    # Restart TL

    #[Teardown]