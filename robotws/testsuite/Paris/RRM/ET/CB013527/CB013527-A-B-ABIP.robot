*** Settings ***

Documentation     [SUITE PURPOSE]   feature CB013527 Instantaneous Throughput Pooling ecpri72e
...               Prerequisite      : CB09514 (parity ecpri72e) & CB012605 (layer prb pooling ecpri72e)
...               Scope             : cell setup & call setup & PRB and Tput pooling
...
...               Test Case Scenario author   : ying.yw.wu@nokia.com
...               Creation Date               : 19-03-2025
...               Modified Date               : 19-03-2025
...               Last Modified by            : ying.yw.wu@nokia.com
...               Version   Date      Author                             Notes
...               0.1       FB2506    ying.yw.wu@nokia.com             Creation

Resource          ./resources/robot/CB013527-Common-Keywords.robot
Resource          ./resources/robot/CB013527-A-B-Keywords.robot

Suite Setup       Suite Setup from scratch    keepAllUeDataInCfgFile=${True}    listBackupFiles=${FD_ALL}


*** Variables ***
# Custom Config ABIP Tdlte 3ms
${ABIP_Tdlte_3ms_SCF}       ${CURDIR}/config/customCFG/ABIP/ABIP_Tdlte_3ms_6_Cells_8DL4UL_In_1_L1_Pool.xml
${ABIP_6_Cells_IPHY}        ${CURDIR}/config/customCFG/ABIP/6_Cells_72e_iphy.xml
${6_UE_CFG}                 ${CURDIR}/config/customCFG/ABIP/basic_setup_6_cells.cfg


# Custom Config ABIP Tdlte 3ms Canada
${ABIP_Tdlte_3ms_Canada_SCF}       ${CURDIR}/config/customCFG/ABIP/ABIP_Tdlte_3ms_Canada_6_Cells_8DL4UL_In_1_L1_Pool.xml
${6_UE_CFG_Canada}                 ${CURDIR}/config/customCFG/ABIP/Canada_basic_setup.cfg


# Custom Config ABIP Semi static 1/4
${ABIP_Semi_Static_1_4_SCF}        ${CURDIR}/config/customCFG/ABIP/ABIP_SemiStatic_1_4_6_Cells_8DL4UL_In_1_L1_Pool.xml

# Custom BSR file
${ABIP_MuMimoBSR}                  ${CURDIR}/config/customCFG/ABIP/BSR_AVQL_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00002.zip

#Custom Config ABIP TdLte3ms mumimo
${ABIP_Tdlte_3ms_mumimo_SCF}    ${CURDIR}/config/customCFG/ABIP/ABIP_Tdlte_3ms_6_Cells_8DL4UL_mumimo.xml
${basic_cf_MuMimo}              ${CURDIR}/config/customCFG/ABIP/basic_setup_mumimo_cell1.cfg
${ABIP_6_Cells_mumimo_IPHY}     ${CURDIR}/config/customCFG/ABIP/6_Cells_72e_mumimo_iphy.xml

#Custom Config ABIP TdLte3ms mumimo
${ABIP_Tdlte_3ms_mumimo-RAT_SCF}    ${CURDIR}/config/customCFG/ABIP/ABIP_Tdlte_3ms_6_Cells_8DL4UL_mumimo-RAT.xml
${basic_cfg_MuMimo-RAT}              ${CURDIR}/config/customCFG/ABIP/basic_setup_mumimo_cell1-rat.cfg



# SA 6 UEs, 1 UE per cell, dl 175mbps, ul 75mbps
&{SA_Cell1_DlTput175M_UlTput75M}         callType=SA     targetCell=1     dltput=350     ultput=175      pos_profile=1
&{SA_Cell2_DlTput175M_UlTput75M}         callType=SA     targetCell=2     dltput=175     ultput=75      pos_profile=1
&{SA_Cell3_DlTput175M_UlTput75M}         callType=SA     targetCell=3     dltput=175     ultput=75      pos_profile=1
&{SA_Cell4_DlTput175M_UlTput75M}         callType=SA     targetCell=4     dltput=175     ultput=75      pos_profile=1
&{SA_Cell5_DlTput175M_UlTput75M}         callType=SA     targetCell=5     dltput=175     ultput=75      pos_profile=1
&{SA_Cell6_DlTput175M_UlTput75M}         callType=SA     targetCell=6     dltput=175     ultput=75      pos_profile=1


@{UE_Def_DL_UL_List_01}     ${SA_Cell1_DlTput175M_UlTput75M}
...                         ${SA_Cell2_DlTput175M_UlTput75M}
...                         ${SA_Cell3_DlTput175M_UlTput75M}
...                         ${SA_Cell4_DlTput175M_UlTput75M}
...                         ${SA_Cell5_DlTput175M_UlTput75M}
...                         ${SA_Cell6_DlTput175M_UlTput75M}

# SA Add Ue for MiMimo
&{SA_Cell1_DlTput350M_UlTput75M}         callType=SA     targetCell=1     dltput=350     ultput=175      pos_profile=1
&{SA_Cell1-2_DlTput350M_UlTput75M}         callType=SA     targetCell=1     dltput=350     ultput=175      pos_profile=2

@{UE_Def_DL_UL_List_02}     ${SA_Cell1_DlTput350M_UlTput75M}
...                         ${SA_Cell2_DlTput175M_UlTput75M}
...                         ${SA_Cell3_DlTput175M_UlTput75M}
...                         ${SA_Cell4_DlTput175M_UlTput75M}
...                         ${SA_Cell5_DlTput175M_UlTput75M}
...                         ${SA_Cell6_DlTput175M_UlTput75M}
...                         &{SA_Cell1-2_DlTput350M_UlTput75M}


${GBRdlthroughput}             10     #GBR DL Throughput : 10 Mb/s

&{CB013527_ASOH_BSR_Dic}        BSR_file_name=BSR_AVQL_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00002.zip
...                             BSR_folder=CB013527
# ---------------------------------------------------------------------------------------------------------------
*** Test Cases ***

[1]CB013527-A-B-ABIP-Tdlte-3ms-DL-UL-Throughput-Pooling
    [Documentation]     CB013527 Basic DL+UL Throughput Allocation
    ...                 Conditions:
    ...                     6 TDD Cells on half ABIP, without mumimo cells
    ...                     Layer PRB Pooling Features activated +
    ...                     CB013527 Tput Pooling Activated
    ...                     ABIP Half Mode 6 TDD cells mapping info in 1 L1pool
    ...                     bbmodBoardConfigType=NRFDD_NRTDD
    ...                     +----------+----------+----------+-----------+-----------+-----------+
    ...                     | NRCELL-1 | NRCELL-3 | NRCELL-5 | NRCELL-2  |NRCELL-4   |NRCELL-6   |
    ...                     +----------+----------+----------------------+-----------+-----------+
    ...                     |     L1 SubPoolId=1             |           L1 SubPoolId=0          |
    ...                     +---------------------+----------------------------------------------+
    ...                     |                   L1 PoolId=9                                      |
    ...                     +---------------------+----------------------------------------------+
    ...                 Actions:
    ...                     1) cell setup with CB012605 & CB013527 activated, 6 TDD cells in one L1pool on half ABIP:
    ...                     2) Call setup with Low DL+UL traffic
    ...                         NRCELL-1 (50) : 1 SA UE, UE id 1, DL 175mbps + UL 75mbps;
    ...                         NRCELL-2 (51) : 1 SA UE, UE id 2, DL 175mbps + UL 75mbps;
    ...                         NRCELL-3 (52) : 1 SA UE, UE id 3, DL 175mbps + UL 75mbps;
    ...                         NRCELL-4 (53) : 1 SA UE, UE id 4, DL 175mbps + UL 75mbps;
    ...                         NRCELL-4 (54) : 1 SA UE, UE id 4, DL 175mbps + UL 75mbps;
    ...                         NRCELL-4 (55) : 1 SA UE, UE id 4, DL 175mbps + UL 75mbps;
    ...                     3) Collect TTI traces & gnb snapshot
    ...                 Checks:
    ...                     In TTI traces, at each SFN, for both DL & UL :
    ...                     - the allocated tput on each cell should be >= a predefined min tput value;
    ...                     - the allocated tput sum of all cells should be <= a predefine max tput limit
    Dated Log New Line     ===> To setup  with custom config files
    CB013527 Setup With Custom Config   SCF=${ABIP_Tdlte_3ms_SCF}
    ...                                 CFG=${6_UE_CFG}
    ...                                 rdParam=@{Rad_Param_CB013527}
    ...                                 IPHY=${ABIP_6_Cells_IPHY}
    ...                                 vendorParam=@{Custom_Vendor_For_Airphone}
    TC CB013527-DL-UL-Traffic           UEdefListparam=${UE_Def_DL_UL_List_01}
    #[Teardown]

[1]CB013527-A-B-ABIP-Tdlte-3ms-DL-UL-Throughput-Pooling-Deactivate
    [Documentation]     CB013527 Basic DL+UL Throughput Allocation
    ...                 Conditions:
    ...                     6 TDD Cells on half ABIP, without mumimo cells
    ...                     Layer PRB Pooling Features activated +
    ...                     CB013527 Tput Pooling DeActivated
    ...                     ABIP Half Mode 6 TDD cells mapping info in 1 L1pool
    ...                     bbmodBoardConfigType=NRFDD_NRTDD
    ...                     +----------+----------+----------+-----------+-----------+-----------+
    ...                     | NRCELL-1 | NRCELL-3 | NRCELL-5 | NRCELL-2  |NRCELL-4   |NRCELL-6   |
    ...                     +----------+----------+----------------------+-----------+-----------+
    ...                     |     L1 SubPoolId=1             |           L1 SubPoolId=0          |
    ...                     +---------------------+----------------------------------------------+
    ...                     |                   L1 PoolId=9                                      |
    ...                     +---------------------+----------------------------------------------+
    ...                 Actions:
    ...                     1) cell setup with CB012605 & CB013527 activated, 6 TDD cells in one L1pool on half ABIP:
    ...                     2) Call setup with Low DL+UL traffic
    ...                         NRCELL-1 (50) : 1 SA UE, UE id 1, DL 175mbps + UL 75mbps;
    ...                         NRCELL-2 (51) : 1 SA UE, UE id 2, DL 175mbps + UL 75mbps;
    ...                         NRCELL-3 (52) : 1 SA UE, UE id 3, DL 175mbps + UL 75mbps;
    ...                         NRCELL-4 (53) : 1 SA UE, UE id 4, DL 175mbps + UL 75mbps;
    ...                         NRCELL-4 (54) : 1 SA UE, UE id 4, DL 175mbps + UL 75mbps;
    ...                         NRCELL-4 (55) : 1 SA UE, UE id 4, DL 175mbps + UL 75mbps;
    ...                     3) Collect TTI traces & gnb snapshot
    ...                 Checks:
    ...                     Tput allocation not applied, only layer PRB pooling (CB012605) works
    Dated Log New Line     ===> To setup  with custom config files
    CB013527 Setup With Custom Config   SCF=${ABIP_Tdlte_3ms_SCF}
    ...                                 CFG=${6_UE_CFG}
    ...                                 rdParam=@{Rad_Param_CB013527_Deact}
    ...                                 IPHY=${ABIP_6_Cells_IPHY}
    ...                                 vendorParam=@{Custom_Vendor_For_Airphone}
    TC CB013527-DL-UL-Traffic           UEdefListparam=${UE_Def_DL_UL_List_01}
    #[Teardown]



[1]CB013527-A-B-ABIP-Tdlte-3ms-Canada-DL-UL-Throughput-Pooling
    [Documentation]     CB013527 Basic DL+UL Throughput Allocation
    ...                 Conditions:
    ...                     6 TDD Cells on half ABIP, without mumimo cells
    ...                     Layer PRB Pooling Features activated +
    ...                     CB013527 Tput Pooling Activated
    ...                     ABIP Half Mode 6 TDD cells mapping info in 1 L1pool
    ...                     bbmodBoardConfigType=NRFDD_NRTDD
    ...                     +----------+----------+----------+-----------+-----------+-----------+
    ...                     | NRCELL-1 | NRCELL-3 | NRCELL-5 | NRCELL-2  |NRCELL-4   |NRCELL-6   |
    ...                     +----------+----------+----------------------+-----------+-----------+
    ...                     |     L1 SubPoolId=1             |           L1 SubPoolId=0          |
    ...                     +---------------------+----------------------------------------------+
    ...                     |                   L1 PoolId=9                                      |
    ...                     +---------------------+----------------------------------------------+
    ...                 Actions:
    ...                     1) cell setup with CB012605 & CB013527 activated, 6 TDD cells in one L1pool on half ABIP:
    ...                     2) Call setup with Low DL+UL traffic
    ...                         NRCELL-1 (50) : 1 SA UE, UE id 1, DL 175mbps + UL 75mbps;
    ...                         NRCELL-2 (51) : 1 SA UE, UE id 2, DL 175mbps + UL 75mbps;
    ...                         NRCELL-3 (52) : 1 SA UE, UE id 3, DL 175mbps + UL 75mbps;
    ...                         NRCELL-4 (53) : 1 SA UE, UE id 4, DL 175mbps + UL 75mbps;
    ...                         NRCELL-4 (54) : 1 SA UE, UE id 4, DL 175mbps + UL 75mbps;
    ...                         NRCELL-4 (55) : 1 SA UE, UE id 4, DL 175mbps + UL 75mbps;
    ...                     3) Collect TTI traces & gnb snapshot
    ...                 Checks:
    ...                     In TTI traces, at each SFN, for both DL & UL :
    ...                     - the allocated tput on each cell should be >= a predefined min tput value;
    ...                     - the allocated tput sum of all cells should be <= a predefine max tput limit
    Dated Log New Line     ===> To setup  with custom config files
    CB013527 Setup With Custom Config   SCF=${ABIP_Tdlte_3ms_Canada_SCF}
    ...                                 CFG=${6_UE_CFG_Canada}
    ...                                 rdParam=@{Rad_Param_CB013527}
    ...                                 IPHY=${ABIP_6_Cells_IPHY}
    ...                                 vendorParam=@{Custom_Vendor_For_Airphone}
    TC CB013527-DL-UL-Traffic           UEdefListparam=${UE_Def_DL_UL_List_01}
    #[Teardown]

[1]CB013527-A-B-ABIP-Semi-Static-1-4-DL-UL-Throughput-Pooling
    [Documentation]     CB013527 Basic DL+UL Throughput Allocation
    ...                 Conditions:
    ...                     6 TDD Cells on half ABIP, without mumimo cells
    ...                     Layer PRB Pooling Features activated +
    ...                     CB013527 Tput Pooling Activated
    ...                     ABIP Half Mode 6 TDD cells mapping info in 1 L1pool
    ...                     bbmodBoardConfigType=NRFDD_NRTDD
    ...                     +----------+----------+----------+-----------+-----------+-----------+
    ...                     | NRCELL-1 | NRCELL-3 | NRCELL-5 | NRCELL-2  |NRCELL-4   |NRCELL-6   |
    ...                     +----------+----------+----------------------+-----------+-----------+
    ...                     |     L1 SubPoolId=1             |           L1 SubPoolId=0          |
    ...                     +---------------------+----------------------------------------------+
    ...                     |                   L1 PoolId=9                                      |
    ...                     +---------------------+----------------------------------------------+
    ...                 Actions:
    ...                     1) cell setup with CB012605 & CB013527 activated, 6 TDD cells in one L1pool on half ABIP:
    ...                     2) Call setup with Low DL+UL traffic
    ...                         NRCELL-1 (50) : 1 SA UE, UE id 1, DL 175mbps + UL 75mbps;
    ...                         NRCELL-2 (51) : 1 SA UE, UE id 2, DL 175mbps + UL 75mbps;
    ...                         NRCELL-3 (52) : 1 SA UE, UE id 3, DL 175mbps + UL 75mbps;
    ...                         NRCELL-4 (53) : 1 SA UE, UE id 4, DL 175mbps + UL 75mbps;
    ...                         NRCELL-4 (54) : 1 SA UE, UE id 4, DL 175mbps + UL 75mbps;
    ...                         NRCELL-4 (55) : 1 SA UE, UE id 4, DL 175mbps + UL 75mbps;
    ...                     3) Collect TTI traces & gnb snapshot
    ...                 Checks:
    ...                     In TTI traces, at each SFN, for both DL & UL :
    ...                     - the allocated tput on each cell should be >= a predefined min tput value;
    ...                     - the allocated tput sum of all cells should be <= a predefine max tput limit
    Dated Log New Line     ===> To setup  with custom config files
    CB013527 Setup With Custom Config   SCF=${ABIP_Semi_Static_1_4_SCF}
    ...                                 CFG=${6_UE_CFG}
    ...                                 rdParam=@{Rad_Param_CB013527}
    ...                                 IPHY=${ABIP_6_Cells_IPHY}
    ...                                 vendorParam=@{Custom_Vendor_For_Airphone}
    TC CB013527-DL-UL-Traffic           UEdefListparam=${UE_Def_DL_UL_List_01}
    #[Teardown]

[1]CB013527-A-B-ABIP-B#3-Airphone-ABIP-Tdlte-3ms-6-Cells-DL-Tput-Limit-hit-With-Mumimo
    [Documentation]     CB013527 Tdlte-3ms-6-Cells-DL-Tput-Limit-hit-With-Mumimo
    ...                 Conditions:
    ...                     6 TDD cells 8DL 4UL Layers 16RX 7-2e on Half ABIP, Mixed cell bandwidth (MHz)
    ...                     Cell 1 :  configured with mumimo enabled + actDl256Qam=true, All other cells : actDl256Qam=false
    ...                     Layer PRB Pooling Features activated +
    ...                     CB013527 Tput Pooling Activated
    ...                     ABIP Half Mode 6 TDD cells mapping info in 1 L1pool
    ...                     bbmodBoardConfigType=NRFDD_NRTDD
    ...                     +----------+----------+----------+-----------+-----------+-----------+
    ...                     | NRCELL-1 | NRCELL-3 | NRCELL-5 | NRCELL-2  |NRCELL-4   |NRCELL-6   |
    ...                     +----------+----------+----------------------+-----------+-----------+
    ...                     |     L1 SubPoolId=1             |           L1 SubPoolId=0          |
    ...                     +---------------------+----------------------------------------------+
    ...                     |                   L1 PoolId=9                                      |
    ...                     +---------------------+----------------------------------------------+
    ...                 Actions:
    ...                     1) cell setup with CB012605 & CB013527 activated, 6 TDD cells in one L1pool on half ABIP:
    ...                     2) Call setup with Low DL+UL traffic
    ...                         NRCELL-1 (50) : UE 1,7 on cell 1 : GBR 10mpbs + nonGBR 350mbps;
    ...                         NRCELL-2 (51) : UE 2 on cell 2 : GBR 10mpbs + nonGBR 175mbps;
    ...                         NRCELL-3 (52) : UE 3 on cell 3 : GBR 10mpbs + nonGBR 175mbps;
    ...                         NRCELL-4 (53) : UE 4 on cell 4 : GBR 10mpbs + nonGBR 175mbps;
    ...                         NRCELL-5 (54) : UE 5 on cell 5 : GBR 10mpbs + nonGBR 175mbps;
    ...                         NRCELL-6 (55) : UE 6 on cell 6 : GBR 10mpbs + nonGBR 175mbps;
    ...                     3) Complete the traffic load with dummy pdsch to trigger the tput limit hit  (tbc)
    ...                     4) Collect TTI traces & gnb snapshot
    ...                     5) Collect syslog/snapshot
    ...                     6) Collect PMs
    ...                 Checks:
    ...                     In TTI traces, at each SFN, for both DL & UL :
    ...                     - the allocated tput on each cell should be >= a predefined min tput value;
    ...                     - the allocated tput sum of all cells should be <= a predefine max tput limit
    Dated Log New Line     ===> Load BSR file
    #OAM Software Update    sw_package=${ABIP_MuMimoBSR}
    CB013527 Load CB013527 BSR file     ${CB013527_ASOH_BSR_Dic}       #iso 13199 file
    Dated Log New Line     ===> To setup  with custom config files

    CB013527 Setup With Custom Config   SCF=${ABIP_Tdlte_3ms_mumimo_SCF}
    ...                                 CFG=${basic_cf_MuMimo}
    ...                                 rdParam=@{Rad_Param_CB013527}
    ...                                 IPHY=${ABIP_6_Cells_mumimo_IPHY}
    ...                                 vendorParam=@{Custom_Vendor_For_Airphone-TputLimit}
    # Restart TL

    TC CB013527-DL-UL-Traffic-GBR           UEdefListparam=${UE_Def_DL_UL_List_02}
    #[Teardown]




[1]CB013527-C#1-Airphone-ABIP-Tdlte-3ms-6-Cells-DL-RAT1-RAT0-IWK-CB008927
    [Documentation]     CB013527 Tdlte-3ms-6-Cells-DL-Tput-Limit-hit-With-Mumimo
    ...                 Conditions:
    ...                     6 TDD cells 8DL 4UL Layers 16RX 7-2e on Half ABIP, Mixed cell bandwidth (MHz)
    ...                     Cell 50 : DL/UL Mumimo enabled
    ...                     Cell 50 : actRat1Alloc = true
    ...                     Cell 51 : actRat1Alloc = true, actDlDynSwitchAlloc=true
    ...                     Layer PRB Pooling Features activated +
    ...                     CB013527 Tput Pooling Activated
    ...                     ABIP Half Mode 6 TDD cells mapping info in 1 L1pool
    ...                     bbmodBoardConfigType=NRFDD_NRTDD
    ...                     +----------+----------+----------+-----------+-----------+-----------+
    ...                     | NRCELL-1 | NRCELL-3 | NRCELL-5 | NRCELL-2  |NRCELL-4   |NRCELL-6   |
    ...                     +----------+----------+----------------------+-----------+-----------+
    ...                     |     L1 SubPoolId=1             |           L1 SubPoolId=0          |
    ...                     +---------------------+----------------------------------------------+
    ...                     |                   L1 PoolId=9                                      |
    ...                     +---------------------+----------------------------------------------+
    ...                 Actions:
    ...                     1) cell setup with CB012605 & CB013527 activated, 6 TDD cells in one L1pool on half ABIP:
    ...                     2) Call setup with Low DL+UL traffic
    ...                         NRCELL-1 (50) : UE 1,7 on cell 1 : nonGBR 350mbps;
    ...                         NRCELL-2 (51) : UE 2 on cell 2 : nonGBR 175mbps;
    ...                         NRCELL-3 (52) : UE 3 on cell 3 : nonGBR 175mbps;
    ...                         NRCELL-4 (53) : UE 4 on cell 4 : nonGBR 175mbps;
    ...                         NRCELL-5 (54) : UE 5 on cell 5 : nonGBR 175mbps;
    ...                         NRCELL-6 (55) : UE 6 on cell 6 : nonGBR 175mbps;
    ...                     3) Complete the traffic load with dummy pdsch to trigger the tput limit hit  (tbc)
    ...                     4) Collect TTI traces & gnb snapshot
    ...                     5) Collect syslog/snapshot
    ...                     6) Collect PMs
    ...                 Checks:


    Dated Log New Line     ===> Load BSR file
    #OAM Software Update    sw_package=${ABIP_MuMimoBSR}
    CB013527 Load CB013527 BSR file     ${CB013527_ASOH_BSR_Dic}       #iso 13199 file
    Dated Log New Line     ===> To setup  with custom config files

    CB013527 Setup With Custom Config   SCF=${ABIP_Tdlte_3ms_mumimo-RAT_SCF}
    ...                                 CFG=${basic_cfg_MuMimo-RAT}
    ...                                 rdParam=@{Rad_Param_CB013527}
    ...                                 IPHY=${ABIP_6_Cells_mumimo_IPHY}
    ...                                 vendorParam=@{Custom_Vendor_For_Airphone}
    # Restart TL

    TC CB013527-DL-UL-Traffic-RAT           UEdefListparam=${UE_Def_DL_UL_List_02}
    #[Teardown]