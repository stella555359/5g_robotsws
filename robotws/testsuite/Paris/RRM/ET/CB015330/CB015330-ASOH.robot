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
...               0.2       FB2519    ying.yw.wu@nokia.com             Complete TC008 steps and KPI kws
...               0.3       FB2520    ying.yw.wu@nokia.com             adapt TC002 with 8Rx config
...               0.4       FB2522    ying.yw.wu@nokia.com             Add TC002 in CRT Non Reg

Resource          ./resources/robot/CB015330-Common-Keywords.robot
Resource          ./resources/robot/CB015330-A-Keywords.robot

Suite Setup       Suite Setup from scratch    keepAllUeDataInCfgFile=${True}    listBackupFiles=${FD_ALL}


*** Variables ***
# Custom Config semi static 1/4
${ASOH_Half_Semi_Static}       ${CURDIR}/config/customCFG/ASOH/CB015330-Half-ASOH-4-Cells-8DL8UL-4RX.xml
${ASOH_4_Cells_TDD_IPHY}       ${CURDIR}/config/customCFG/ASOH/ASOH-4-TDD-iphy.xml
${Basic_Setup_CFG_4_Cells}     ${CURDIR}/config/customCFG/ASOH/basic_setup_4_cells.cfg
${ASOH_Half_Mix_4RX_8RX}       ${CURDIR}/config/customCFG/ASOH/CB015330-Half-ASOH-Mix-4RX-8RX.xml

# Custom Config semi static 3/7
${ASOH_Half_Semi_Static_3_7}       ${CURDIR}/config/customCFG/ASOH/CB015330-Half-ASOH-4-Cells-8DL8UL-8RX-SemiStatic-3-7.xml
${ASOH_Half_Semi_Static_3_7_4RX}       ${CURDIR}/config/customCFG/ASOH/CB015330-Half-ASOH-4-Cells-8DL8UL-4RX-SemiStatic-3-7.xml

# BSR package
&{CB015330_AQQL_6_SSB_4RX_SR_Dic}        BSR_file_name=BSR_AQQL_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip
...                                      BSR_folder=CB013199

&{CB015330_AQQL_6_SSB_8RX_SR_Dic}        BSR_file_name=BSR_AQQL_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00002.zip
...                                      BSR_folder=BSR

# SA UEs List
&{UE_1_DL140_UL280}         callType=SA     targetCell=1     dltput=140     ultput=280      pos_profile=1
&{UE_2_DL140_UL280}         callType=SA     targetCell=1     dltput=140     ultput=280      pos_profile=2
&{UE_1_DL560_UL280}         callType=SA     targetCell=1     dltput=560     ultput=280      pos_profile=1
&{UE_2_DL560_UL280}         callType=SA     targetCell=1     dltput=560     ultput=280      pos_profile=2
&{UE_3_DL140_UL140}         callType=SA     targetCell=1     dltput=140     ultput=140      pos_profile=3
&{UE_4_DL140_UL140}         callType=SA     targetCell=1     dltput=140     ultput=140      pos_profile=4

&{UE_1_DL140_UL320}         callType=SA     targetCell=1     dltput=140     ultput=320      pos_profile=1
&{UE_2_DL140_UL140}         callType=SA     targetCell=2     dltput=140     ultput=140      pos_profile=1
&{UE_3_DL140_UL280}         callType=SA     targetCell=3     dltput=140     ultput=280      pos_profile=1
&{UE_4_DL140_UL280}         callType=SA     targetCell=4     dltput=140     ultput=280      pos_profile=1
&{UE_5_DL140_UL320}         callType=SA     targetCell=1     dltput=140     ultput=320      pos_profile=2
&{UE_6_DL140_UL140}         callType=SA     targetCell=2     dltput=140     ultput=140      pos_profile=2
&{UE_7_DL140_UL280}         callType=SA     targetCell=3     dltput=140     ultput=280      pos_profile=2
&{UE_8_DL140_UL280}         callType=SA     targetCell=4     dltput=140     ultput=280      pos_profile=2

@{TC_008_UE_List}           ${UE_1_DL560_UL280}
...                         ${UE_2_DL560_UL280}

@{TC_009_UE_List}           ${UE_1_DL140_UL280}
...                         ${UE_2_DL140_UL280}
...                         ${UE_3_DL140_UL140}
...                         ${UE_4_DL140_UL140}

@{TC_002_UE_List}           ${UE_1_DL140_UL320}
...                         ${UE_2_DL140_UL140}
...                         ${UE_3_DL140_UL280}
...                         ${UE_4_DL140_UL280}
...                         ${UE_5_DL140_UL320}
...                         ${UE_6_DL140_UL140}
...                         ${UE_7_DL140_UL280}
...                         ${UE_8_DL140_UL280}

${TC002_KPI}                ${CURDIR}/config/CounterKPI/CB015330_TC002_KPI.csv
${TC008_KPI}                ${CURDIR}/config/CounterKPI/CB015330_TC008_KPI.csv
${TC009_KPI}                ${CURDIR}/config/CounterKPI/CB015330_TC008_KPI.csv
# ---------------------------------------------------------------------------------------------------------------
*** Test Cases ***

[1]CB015330-TC-002-ASOH-Halfmode-8RX-With-Mumimo-SemiStatic-3-7
    [Documentation]     CB015330-ASOH-Halfmode-4RX-With-Mumimo-SemiStatic-3-7
    ...                 Conditions:
    ...                     4 TDD cells 8DL8UL 8RX on half ASOH
    ...                     Cell 1 :  DL+UL mumimo enabled
    ...                     Cell 2, 3, 4 : UL mumimo disabled
    ...                     ASOH Half Mode 4 TDD cells mapping info in 1 L1pool
    ...                     bbmodBoardConfigType=Auto
    ...                     +----------+----------+----------+-----------+
    ...                     | NRCELL-1 | NRCELL-3 | NRCELL-2 | NRCELL-4  |
    ...                     +----------+----------+----------------------+
    ...                     | L1 SP 1  | L1 SP 0  | L1 SP 3  | L1 SP 2   |
    ...                     +---------------------+-----------------------
    ...                     |  L1 PoolId=9        |  L1 PoolId=12        |
    ...                     +---------------------+-----------------------
    ...                 Actions:
    ...                     1) cell setup
    ...                     2) Call setup with  DL+UL traffic
    ...                         NRCELL-1 (50) : UE 1,5 on cell 1 : 140mbps DL + 320mbps UL;
    ...                         NRCELL-2 (51) : UE 2,6 on cell 2 : 140mbps DL + 280mbps UL;
    ...                         NRCELL-3 (52) : UE 3,7 on cell 3 : 140mbps DL + 280mbps UL;
    ...                         NRCELL-4 (53) : UE 4,8 on cell 4 : 140mbps DL + 280mbps UL;
    ...                     4) Collect TTI traces & gnb snapshot
    ...                     5) Collect snapshot
    ...                     6) Collect & check PMs & KPI
    ...                 Checks:
    ...                     In TTI traces, at each SFN, ulAllocatedPooledResourcesData event :
    ...                     - the allocated tput on each cell should be >= a predefined min tput value;
    ...                     - the allocated tput sum of all cells should be <= a predefine max tput limit
    ...                     - In each L1 pool, in the same sfn, if the sum of the values of allocCellThroughputUl > maxThresholdTputAlloc,
    ...                       then expected value of the colomn "ulCellTpRedFactorInSch" of each cell in the sfn should be 0.75,
    ...                       else the expected value of the "ulCellTpRedFactorInSch" should be 1
    ...                     - check the KPI NR_5088 and NR_5089 has non zero values
    ...                     - check the KPI DL/UL BLER (less than 1%)

    Dated Log New Line     ===> Load BSR file
    CB015330 Load BSR file     ${CB015330_AQQL_6_SSB_8RX_SR_Dic}
    Dated Log New Line     ===> To setup  with custom config files

    CB015330 Setup With Custom Config   SCF=${ASOH_Half_Semi_Static_3_7}
    ...                                 CFG=${Basic_Setup_CFG_4_Cells}
    ...                                 IPHY=${ASOH_4_Cells_TDD_IPHY}
    ...                                 rdParam=@{Rad_Param_CB015330}

    TC CB015330-DL-UL-TC002       UEdefListparam=${TC_002_UE_List}
    ...                     Kpi_Csv_File=${TC002_KPI}
    # Restart TL
    #[Teardown]

[1]CB015330-TC-002-ASOH-Halfmode-8RX-With-Mumimo-SemiStatic-3-7-OFF
    [Documentation]     CB015330-ASOH-Halfmode-4RX-With-Mumimo-SemiStatic-3-7
    ...                 Conditions:
    ...                     4 TDD cells 8DL8UL 8RX on half ASOH
    ...                     Cell 1 :  DL+UL mumimo enabled
    ...                     Cell 2, 3, 4 : UL mumimo disabled
    ...                     ASOH Half Mode 4 TDD cells mapping info in 1 L1pool
    ...                     bbmodBoardConfigType=NRFDD_NRTDD
    ...                     +----------+----------+----------+-----------+
    ...                     | NRCELL-1 | NRCELL-3 | NRCELL-2 | NRCELL-4  |
    ...                     +----------+----------+----------------------+
    ...                     |     L1 SP 3         |   L1 SP 2            |
    ...                     +---------------------+-----------------------
    ...                     |                   L1 PoolId=9              |
    ...                     +---------------------+-----------------------
    ...                 Actions:
    ...                     1) cell setup
    ...                     2) Call setup with  DL+UL traffic
    ...                         NRCELL-1 (50) : UE 1,5 on cell 1 : 140mbps DL + 320mbps UL;
    ...                         NRCELL-2 (51) : UE 2 on cell 2 : 140mbps DL + 280mbps UL;
    ...                         NRCELL-3 (52) : UE 3 on cell 3 : 140mbps DL + 280mbps UL;
    ...                         NRCELL-4 (53) : UE 4 on cell 4 : 140mbps DL + 280mbps UL;
    ...                     4) Collect TTI traces & gnb snapshot
    ...                     5) Collect snapshot
    ...                     6) Collect & check PMs & KPI
    ...                 Checks:
    ...                     In TTI traces, at each SFN, for both DL & UL :
    ...                     - the allocated tput on each cell should be >= a predefined min tput value;
    ...                     - the allocated tput sum of all cells should be <= a predefine max tput limit
    Dated Log New Line     ===> Load BSR file
    CB015330 Load BSR file     ${CB015330_AQQL_6_SSB_8RX_SR_Dic}
    Dated Log New Line     ===> To setup  with custom config files

    CB015330 Setup With Custom Config   SCF=${ASOH_Half_Semi_Static_3_7}
    ...                                 CFG=${Basic_Setup_CFG_4_Cells}
    ...                                 IPHY=${ASOH_4_Cells_TDD_IPHY}
    ...                                 rdParam=@{Rad_Param_CB015330_OFF}

    TC CB015330-DL-UL       UEdefListparam=${TC_002_UE_List}
    ...                     Kpi_Csv_File=${TC002_KPI}
    # Restart TL
    #[Teardown]

[1]CB015330-TC-008-ASOH-Halfmode-4RX-With-Mumimo
    [Documentation]     CB015330-ASOH-Halfmode-4RX-With-Mumimo
    ...                 Conditions:
    ...                     4 TDD cells 8DL8UL 8RX on Full ABIP
    ...                     Cell 1 :  DL+UL mumimo enabled
    ...                     Cell 2, 3, 4 : UL mumimo disabled
    ...                     ASOH Half Mode 4 TDD cells mapping info in 1 L1pool
    ...                     bbmodBoardConfigType=NRFDD_NRTDD
    ...                     +----------+----------+----------+-----------+
    ...                     | NRCELL-1 | NRCELL-3 | NRCELL-2 | NRCELL-4  |
    ...                     +----------+----------+----------------------+
    ...                     |     L1 SP 3         |   L1 SP 2            |
    ...                     +---------------------+-----------------------
    ...                     |                   L1 PoolId=9              |
    ...                     +---------------------+-----------------------
    ...                 Actions:
    ...                     1) cell setup
    ...                     2) Call setup with  DL+UL traffic
    ...                         NRCELL-1 (50) : UE 1,5 on cell 1 : 175mbps DL + 280mbps UL;
    ...                         NRCELL-2 (51) : UE 2,6 on cell 2 : 100mbps UL;
    ...                         NRCELL-3 (52) : UE 3,7 on cell 3 : 100mbps UL;
    ...                         NRCELL-4 (53) : UE 4,8 on cell 4 : 100mbps UL;
    ...                     4) Collect TTI traces & gnb snapshot
    ...                     5) Collect snapshot
    ...                     6) Collect PMs & KPI
    ...                 Checks:
    ...                     In TTI traces, at each SFN, for both DL & UL :
    ...                     - the allocated tput on each cell should be >= a predefined min tput value;
    ...                     - the allocated tput sum of all cells should be <= a predefine max tput limit
    Dated Log New Line     ===> Load BSR file
    CB015330 Load BSR file     ${CB015330_AQQL_6_SSB_4RX_SR_Dic}
    Dated Log New Line     ===> To setup  with custom config files

    CB015330 Setup With Custom Config   SCF=${ASOH_Half_Semi_Static}
    ...                                 CFG=${Basic_Setup_CFG_4_Cells}
    ...                                 IPHY=${ASOH_4_Cells_TDD_IPHY}
    ...                                 rdParam=@{Rad_Param_CB015330_TC008}

    TC CB015330-DL-UL       UEdefListparam=${TC_008_UE_List}
    ...                     Kpi_Csv_File=${TC008_KPI}
    # Restart TL

    #[Teardown]

[1]CB015330-TC-008-ASOH-Halfmode-4RX-With-Mumimo-Deactivation
    [Documentation]     CB015330-ASOH-Halfmode-4RX-With-Mumimo
    ...                 Conditions:
    ...                     4 TDD cells 8DL8UL 8RX on Full ABIP
    ...                     Cell 1 :  DL+UL mumimo enabled
    ...                     Cell 2, 3, 4 : UL mumimo disabled
    ...                     ASOH Half Mode 4 TDD cells mapping info in 1 L1pool
    ...                     bbmodBoardConfigType=NRFDD_NRTDD
    ...                     +----------+----------+----------+-----------+
    ...                     | NRCELL-1 | NRCELL-3 | NRCELL-2 | NRCELL-4  |
    ...                     +----------+----------+----------------------+
    ...                     |     L1 SP 3         |   L1 SP 2            |
    ...                     +---------------------+-----------------------
    ...                     |                   L1 PoolId=9              |
    ...                     +---------------------+-----------------------
    ...                 Actions:
    ...                     1) cell setup
    ...                     2) Call setup with  DL+UL traffic
    ...                         NRCELL-1 (50) : UE 1,5 on cell 1 : 175mbps DL + 280mbps UL;
    ...                         NRCELL-2 (51) : UE 2,6 on cell 2 : 100mbps UL;
    ...                         NRCELL-3 (52) : UE 3,7 on cell 3 : 100mbps UL;
    ...                         NRCELL-4 (53) : UE 4,8 on cell 4 : 100mbps UL;
    ...                     4) Collect TTI traces & gnb snapshot
    ...                     5) Collect snapshot
    ...                     6) Collect PMs & KPI
    ...                 Checks:
    ...                     In TTI traces, at each SFN, for both DL & UL :
    ...                     - the allocated tput on each cell should be >= a predefined min tput value;
    ...                     - the allocated tput sum of all cells should be <= a predefine max tput limit
    Dated Log New Line     ===> Load BSR file
    CB015330 Load BSR file     ${CB015330_AQQL_6_SSB_4RX_SR_Dic}
    Dated Log New Line     ===> To setup  with custom config files

    CB015330 Setup With Custom Config   SCF=${ASOH_Half_Semi_Static}
    ...                                 CFG=${Basic_Setup_CFG_4_Cells}
    ...                                 IPHY=${ASOH_4_Cells_TDD_IPHY}
    ...                                 rdParam=@{Rad_Param_CB015330_OFF_TC008}

    TC CB015330-DL-UL       UEdefListparam=${TC_008_UE_List}
    ...                     Kpi_Csv_File=${TC008_KPI}
    # Restart TL

    #[Teardown]


[1]CB015330-TC-009-ASOH-Halfmode-4RX-8RX-MIX
    [Documentation]     CB015330-ASOH-Halfmode-4RX-With-Mumimo
    ...                 Conditions:
    ...                     4 TDD cells 8DL8UL 8RX on Full ABIP
    ...                     Cell 1 :  DL+UL mumimo enabled, 8RX
    ...                     Cell 2, 3, 4 : UL mumimo disabled, 4RX
    ...                     ASOH Half Mode 4 TDD cells mapping info in 1 L1pool
    ...                     bbmodBoardConfigType=NRFDD_NRTDD
    ...                     +----------+----------+----------+-----------+
    ...                     | NRCELL-1 | NRCELL-3 | NRCELL-2 | NRCELL-4  |
    ...                     +----------+----------+----------------------+
    ...                     |     L1 SP 3         |   L1 SP 2            |
    ...                     +---------------------+-----------------------
    ...                     |                   L1 PoolId=9              |
    ...                     +---------------------+-----------------------
    ...                 Actions:
    ...                     1) cell setup
    ...                     2) Call setup with  DL+UL traffic
    ...                         NRCELL-1 (50) : UE 1,5 on cell 1 : 175mbps DL + 280mbps UL;
    ...                         NRCELL-2 (51) : UE 2,6 on cell 2 : 100mbps UL;
    ...                         NRCELL-3 (52) : UE 3,7 on cell 3 : 100mbps UL;
    ...                         NRCELL-4 (53) : UE 4,8 on cell 4 : 100mbps UL;
    ...                     4) Collect TTI traces & gnb snapshot
    ...                     5) Collect snapshot
    ...                     6) Collect PMs & KPI
    ...                 Checks:
    ...                     In TTI traces, at each SFN, for both DL & UL :
    ...                     - the allocated tput on each cell should be >= a predefined min tput value;
    ...                     - the allocated tput sum of all cells should be <= a predefine max tput limit
    Dated Log New Line     ===> Load BSR file
    CB015330 Load BSR file     ${CB015330_AQQL_6_SSB_8RX_SR_Dic}
    Dated Log New Line     ===> To setup  with custom config files

    CB015330 Setup With Custom Config   SCF=${ASOH_Half_Mix_4RX_8RX}
    ...                                 CFG=${Basic_Setup_CFG_4_Cells}
    ...                                 IPHY=${ASOH_4_Cells_TDD_IPHY}
    ...                                 rdParam=@{Rad_Param_CB015330}

    TC CB015330-DL-UL-TC009       UEdefListparam=${TC_009_UE_List}
    ...                     Kpi_Csv_File=${TC009_KPI}




[1]CB015330-TC-009-ASOH-Halfmode-4RX-8RX-MIX-OFF
    [Documentation]     CB015330-ASOH-Halfmode-4RX-With-Mumimo
    ...                 Conditions:
    ...                     4 TDD cells 8DL8UL 8RX on Full ABIP
    ...                     Cell 1 :  DL+UL mumimo enabled, 8RX
    ...                     Cell 2, 3, 4 : UL mumimo disabled, 4RX
    ...                     ASOH Half Mode 4 TDD cells mapping info in 1 L1pool
    ...                     bbmodBoardConfigType=NRFDD_NRTDD
    ...                     +----------+----------+----------+-----------+
    ...                     | NRCELL-1 | NRCELL-3 | NRCELL-2 | NRCELL-4  |
    ...                     +----------+----------+----------------------+
    ...                     |     L1 SP 3         |   L1 SP 2            |
    ...                     +---------------------+-----------------------
    ...                     |                   L1 PoolId=9              |
    ...                     +---------------------+-----------------------
    ...                 Actions:
    ...                     1) cell setup
    ...                     2) Call setup with  DL+UL traffic
    ...                         NRCELL-1 (50) : UE 1,5 on cell 1 : 175mbps DL + 280mbps UL;
    ...                         NRCELL-2 (51) : UE 2,6 on cell 2 : 100mbps UL;
    ...                         NRCELL-3 (52) : UE 3,7 on cell 3 : 100mbps UL;
    ...                         NRCELL-4 (53) : UE 4,8 on cell 4 : 100mbps UL;
    ...                     4) Collect TTI traces & gnb snapshot
    ...                     5) Collect snapshot
    ...                     6) Collect PMs & KPI
    ...                 Checks:
    ...                     In TTI traces, at each SFN, for both DL & UL :
    ...                     - the allocated tput on each cell should be >= a predefined min tput value;
    ...                     - the allocated tput sum of all cells should be <= a predefine max tput limit
    Dated Log New Line     ===> Load BSR file
    CB015330 Load BSR file     ${CB015330_AQQL_6_SSB_8RX_SR_Dic}
    Dated Log New Line     ===> To setup  with custom config files

    CB015330 Setup With Custom Config   SCF=${ASOH_Half_Mix_4RX_8RX}
    ...                                 CFG=${Basic_Setup_CFG_4_Cells}
    ...                                 IPHY=${ASOH_4_Cells_TDD_IPHY}
    ...                                 rdParam=@{Rad_Param_CB015330_OFF}

    TC CB015330-DL-UL-TC009       UEdefListparam=${TC_009_UE_List}
    ...                     Kpi_Csv_File=${TC009_KPI}
