*** Settings ***

Documentation     [SUITE PURPOSE]   feature BEP PR853223
...               Prerequisite      : CB09514 (parity ecpri72e) & CB012605 (layer prb pooling ecpri72e)
...               Scope             : cell setup & call setup & PRB and Tput pooling
...
...               Test Case Scenario author   : ying.yw.wu@nokia.com
...               Creation Date               : 14-01-2026
...               Modified Date               : 14-01-2026
...               Last Modified by            : ying.yw.wu@nokia.com
...               Version   Date      Author                             Notes
...               0.1       FB2524    ying.yw.wu@nokia.com             Creation

Resource          ./resources/robot/BEP-853223-Common-Keywords.robot
Resource          ./resources/robot/BEP-853223-A-Keywords.robot
Resource          ../../../resources/SWENG/robot/Setup.robot

Suite Setup       Suite Setup from scratch    keepAllUeDataInCfgFile=${True}    listBackupFiles=${FD_ALL}


*** Variables ***

#Custom Config ABIP ecpri72e TdLte3ms mumimo
${72E_Half_ABIP_Tdlte_3ms_SCF}    ${CURDIR}/config/customCFG/ABIP/CB013305_Half_ABIP_72E_16DL8UL_50Mhz_8RX_Beamset_6_Dyn_AL.xml
${6_Cells_64_UEs}                 ${CURDIR}/config/customCFG/ABIP/basic_wts_step2_64_UEs.cfg
${72E_6_Cells_mumimo_IPHY}        ${CURDIR}/config/customCFG/ABIP/6_Cells_72e_mumimo_iphy.xml

#Custom Config ABIP ecpri72e TdLte0ms mumimo 16DL8UL 50Mhz
${72E_Half_ABIP_Tdlte_0ms_SCF}    ${CURDIR}/config/customCFG/ABIP/CB013305_Half_ABIP_72E_Tdlte_0ms_16DL8UL_50Mhz_8RX_Beamset_6_Dyn_AL.xml
${6_Cells_64_UEs_Mix_Rank}                 ${CURDIR}/config/customCFG/ABIP/basic_wts_step2_64_UEs_Mix_Rank.cfg

#Custom Config Half ABIP ecpri72e TdLte 0ms mumimo 16DL4UL 100Mhz
${72E_Half_ABIP_16DL4UL_Tdlte_0ms_SCF}    ${CURDIR}/config/customCFG/ABIP/BEP-TC6-IWK-CB013932-72E-Half-ABIP-16DL4UL-Tdlte-0ms.xml


#Custom Config ABIP ecpri72a TdLte3ms mumimo
${72A_Half_ABIP_Tdlte_3ms_SCF}    ${CURDIR}/config/customCFG/ABIP/BEP-TC3-72A-Half-ABIP-8DL8UL-Tdlte-3ms.xml
${72A_6_Cells_mumimo_IPHY}        ${CURDIR}/config/customCFG/ABIP/6_Cells_72a_mumimo_iphy.xml

#Custom config Full ABIP ecpri72a Tdlte3ms 3 cells mumimo
${72A_Full_ABIP_Tdlte_3ms_SCF}    ${CURDIR}/config/customCFG/ABIP/BEP-TC4-72A-Full-ABIP-8DL8UL-Tdlte-3ms.xml
${6_Cells_64_UEs_Mix_Rank_TC4}                 ${CURDIR}/config/customCFG/ABIP/basic_wts_step2_64_UEs_Mix_Rank_TC4.cfg

#Custom config Half ABIP ecpri72a Tdlte3ms 1 cell mumimo CB013932 Activated
${CB013932_72A_Half_ABIP_Tdlte_3ms_SCF}    ${CURDIR}/config/customCFG/ABIP/BEP-TC5-IWK-CB013932-72A-Half-ABIP-8DL8UL-Tdlte-3ms.xml
${6_Cells_64_UEs_With_Refine_Capa}         ${CURDIR}/config/customCFG/ABIP/basic_wts_step2_64_UEs_UE_Capa_Refine_SRS.cfg

@{TC1_Cell_Idx_To_Check} =    1

@{TC2_Cell_Idx_To_Check} =    1    2

@{TC4_Cell_Idx_To_Check} =    1    2    4

&{TC1_TC2_Expected_UL_Tput_Alloc}           eventType=ulAllocatedPooledResourcesData
...                                         columnName=allocCellThroughputUl
...                                         minDataAlloc=14976
...                                         maxThroughputL1Pool=1250000

&{TC3_Expected_UL_Tput_Alloc}           eventType=ulAllocatedPooledResourcesData
...                                     columnName=allocCellThroughputUl
...                                     minDataAlloc=14976
...                                     maxThroughputL1Pool=2534000

&{TC4_Expected_UL_Tput_Alloc}           eventType=ulAllocatedPooledResourcesData
...                                     columnName=allocCellThroughputUl
...                                     minDataAlloc=14976
...                                     maxThroughputL1Pool=3784000
#
&{TC_72E_Less_UE_Higher_Load_Params}                  Step_1_Sce=${CURDIR}/resources/egateCmds/UE_Attach_Less.sce
...                                                   Step_2_Sce=${CURDIR}/resources/egateCmds/UE_1_To_4_Testmode_72e_Sinr.sce
...                                                   Step_3_Sce=${CURDIR}/resources/egateCmds/UE_1_To_4_Testmode_72e_Ul_Beam_Pos.sce
...                                                   Step_4_Sce=${CURDIR}/resources/egateCmds/UE_Traffic_UL_Less_UE_Higher_Tput.sce
# ...                                                   First_Cell_Idx=1
# ...                                                   Second_Cell_Idx=4
...                                                   Cell_Index_List=${TC1_Cell_Idx_To_Check}
...                                                   Bler_KPI_File=${CURDIR}/config/CounterKPI/6_Cells_BLER_KPI.csv
...                                                   Expected_UL_Alloc_Sum=${TC1_TC2_Expected_UL_Tput_Alloc}

&{TC2_72E_Params}                                     Step_1_Sce=${CURDIR}/resources/egateCmds/UE_Attach_More.sce
...                                                   Step_2_Sce=${CURDIR}/resources/egateCmds/UE_1_To_4_31_To_34_Testmode_72e_Sinr.sce
...                                                   Step_3_Sce=${CURDIR}/resources/egateCmds/UE_1_To_4_31_To_34_Testmode_72e_Ul_Beam_Pos.sce
...                                                   Step_4_Sce=${CURDIR}/resources/egateCmds/UE_Traffic_UL_More_UE_Higher_Tput.sce
# ...                                                   First_Cell_Idx=1
# ...                                                   Second_Cell_Idx=4
...                                                   Cell_Index_List=${TC2_Cell_Idx_To_Check}
...                                                   Bler_KPI_File=${CURDIR}/config/CounterKPI/6_Cells_BLER_KPI.csv
...                                                   Expected_UL_Alloc_Sum=${TC1_TC2_Expected_UL_Tput_Alloc}

&{TC3_72A_Params}                                     Step_1_Sce=${CURDIR}/resources/egateCmds/UE_Attach_Less.sce
...                                                   Step_2_Sce=${CURDIR}/resources/egateCmds/UE_1_To_4_Testmode_72A_SRS_Beams_Profiles.sce
...                                                   Step_3_Sce=${CURDIR}/resources/egateCmds/UE_1_To_4_Testmode_72A_Beam_Profile_Act.sce
...                                                   Step_4_Sce=${CURDIR}/resources/egateCmds/UE_Traffic_UL_Less_UE_Higher_Tput.sce
# ...                                                   First_Cell_Idx=1
# ...                                                   Second_Cell_Idx=4
...                                                   Cell_Index_List=${TC1_Cell_Idx_To_Check}
...                                                   Bler_KPI_File=${CURDIR}/config/CounterKPI/6_Cells_BLER_KPI.csv
...                                                   Expected_UL_Alloc_Sum=${TC3_Expected_UL_Tput_Alloc}

&{TC4_72A_Params}                                     Step_1_Sce=${CURDIR}/resources/egateCmds/UE_Attach_TC4.sce
...                                                   Step_2_Sce=${CURDIR}/resources/egateCmds/UE_Testmode_72A_SRS_Beams_Profiles.sce
...                                                   Step_3_Sce=${CURDIR}/resources/egateCmds/UE_TC4_Testmode_72A_Beam_Profile_Act.sce
...                                                   Step_4_Sce=${CURDIR}/resources/egateCmds/UE_Traffic_UL_TC4.sce
# ...                                                   First_Cell_Idx=1
# ...                                                   Second_Cell_Idx=4
...                                                   Cell_Index_List=${TC4_Cell_Idx_To_Check}
...                                                   Bler_KPI_File=${CURDIR}/config/CounterKPI/6_Cells_BLER_KPI.csv
...                                                   Expected_UL_Alloc_Sum=${TC4_Expected_UL_Tput_Alloc}

&{TC4_BEP_OFF_72A_Params}                             Step_1_Sce=${CURDIR}/resources/egateCmds/UE_Attach_TC4.sce
...                                                   Step_2_Sce=${CURDIR}/resources/egateCmds/UE_Testmode_72A_SRS_Beams_Profiles.sce
...                                                   Step_3_Sce=${CURDIR}/resources/egateCmds/UE_TC4_Testmode_72A_Beam_Profile_Act.sce
...                                                   Step_4_Sce=${CURDIR}/resources/egateCmds/UE_Traffic_UL_TC4.sce
# ...                                                   First_Cell_Idx=1
# ...                                                   Second_Cell_Idx=4
...                                                   Cell_Index_List=${TC4_Cell_Idx_To_Check}
...                                                   Bler_KPI_File=${CURDIR}/config/CounterKPI/6_Cells_BLER_KPI.csv
...                                                   Expected_UL_Alloc_Sum=${TC4_Expected_UL_Tput_Alloc}



&{TC5_72A_Params}                                     Step_1_Sce=${CURDIR}/resources/egateCmds/UE_1_To_64_Attach.sce
...                                                   Step_2_Sce=${CURDIR}/resources/egateCmds/UE_1_To_4_Testmode_72A_Refine_Beams.sce
...                                                   Step_3_Sce=${CURDIR}/resources/egateCmds/UE_5_To_20_Testmode_72A_SRS_Beams.sce
...                                                   Step_4_Sce=${CURDIR}/resources/egateCmds/UE_Traffic_UL_TC5.sce
# ...                                                   First_Cell_Idx=1
# ...                                                   Second_Cell_Idx=4
...                                                   Cell_Index_List=${TC1_Cell_Idx_To_Check}
...                                                   Bler_KPI_File=${CURDIR}/config/CounterKPI/6_Cells_BLER_KPI.csv
...                                                   Expected_UL_Alloc_Sum=${TC3_Expected_UL_Tput_Alloc}

&{TC6_72E_Params}                                     Step_1_Sce=${CURDIR}/resources/egateCmds/UE_Attach_TC6.sce
...                                                   Step_2_Sce=${CURDIR}/resources/egateCmds/UE_1_To_4_31_To_34_Testmode_72e_Sinr.sce
...                                                   Step_3_Sce=${CURDIR}/resources/egateCmds/UE_1_To_4_31_To_34_Testmode_72e_Ul_Beam_Pos.sce
...                                                   Step_4_Sce=${CURDIR}/resources/egateCmds/UE_Traffic_UL_TC6.sce
# ...                                                   First_Cell_Idx=1
# ...                                                   Second_Cell_Idx=4
...                                                   Cell_Index_List=${TC2_Cell_Idx_To_Check}
...                                                   Bler_KPI_File=${CURDIR}/config/CounterKPI/6_Cells_BLER_KPI.csv
...                                                   Expected_UL_Alloc_Sum=${TC3_Expected_UL_Tput_Alloc}

${6_Cells_BLER_KPI}               ${CURDIR}/config/CounterKPI/6_Cells_BLER_KPI.csv

# BSR package
&{AVQL_6_SSB_8RX_SR_Dic}        BSR_file_name=BSR_AVQL_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00002.zip
...                                      BSR_folder=CB013932

&{AEQE_6_SSB_8RX_SR_Dic}        BSR_file_name=BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip
...                                      BSR_folder=CB008830

# ---------------------------------------------------------------------------------------------------------------
*** Test Cases ***

[1]BEP-TC1-72E-Half-ABIP-16DL8UL-50Mhz-Tdlte-3ms-DL-UL
    [Documentation]     BEP 853223 Basic DL+UL
    ...                 Conditions:
    ...                     6 TDD Cells on half ABIP, 1 mumimo cells
    ...                     Layer PRB Pooling Features activated +
    ...                     CB013527 Tput Pooling Activated +
	...						CB013305 Activated
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
    ...                     1) cell setup with CB012605 & CB013527 & CB013305 activated, 6 TDD cells in one L1pool on half ABIP:
    ...                     2) Call setup
	...						3) Call setup with n UE in cell1, 1 UE per cell in other cells
	...                     3) Collect TTI traces & gnb snapshot
    ...                 Checks:
    ...                     To be completed
    Dated Log New Line     ===> To setup  with custom config files
    BEP 853223 Load BSR file              ${AVQL_6_SSB_8RX_SR_Dic}
    BEP 853223 Setup With Custom Config 72E       SCF=${72E_Half_ABIP_Tdlte_3ms_SCF}
    ...                                         CFG=${6_Cells_64_UEs}
    ...                                         IPHY=${72E_6_Cells_mumimo_IPHY}
    ...                                         rdParam=@{Rad_Param_72e}
    ...                                         vendorParam=@{Custom_Vendor_For_Airphone-TputLimit-UL}
    TC BEP-853223-DL-UL-Traffic           TC_Param=${TC_72E_Less_UE_Higher_Load_Params}
    #[Teardown]


[1]BEP-TC2-72E-Half-ABIP-16DL8UL-50Mhz-Tdlte-0ms-DL-UL
    [Documentation]     BEP 853223 Basic DL+UL
    ...                 Conditions:
    ...                     6 TDD Cells on half ABIP, 2 mumimo cells
    ...                        Cell 1 : ul max mumimo layer = 4
    ...                        Cell 2 : ul max mumimo layer = 8
    ...                     Layer PRB Pooling Features activated +
    ...                     CB013527 Tput Pooling Activated +
	...						CB013305 Activated
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
    ...                     1) cell setup with CB012605 & CB013527 & CB013305 activated, 6 TDD cells in one L1pool on half ABIP:
    ...                     2) Call setup
	...						3) Call setup with n UE in cell1, 1 UE per cell in other cells
	...                     3) Collect TTI traces & gnb snapshot
    ...                 Checks:
    ...                     To be completed
    Dated Log New Line     ===> To setup  with custom config files
    BEP 853223 Load BSR file              ${AVQL_6_SSB_8RX_SR_Dic}
    BEP 853223 Setup With Custom Config 72E       SCF=${72E_Half_ABIP_Tdlte_0ms_SCF}
    ...                                         CFG=${6_Cells_64_UEs_Mix_Rank}
    ...                                         IPHY=${72E_6_Cells_mumimo_IPHY}
    ...                                         rdParam=@{Rad_Param_72e}
    ...                                         vendorParam=@{Custom_Vendor_For_Airphone-TputLimit-UL}
    TC BEP-853223-DL-UL-Traffic           TC_Param=${TC2_72E_Params}
    #[Teardown]

[1]BEP-TC3-72A-Half-ABIP-8DL8UL-Tdlte-3ms
    [Documentation]     BEP 853223 Basic DL+UL
    ...                 Conditions:
    ...                     6 TDD Cells on half ABIP, 1 mumimo cells
    ...                     Stream PRB Pooling Features activated +
    ...                     CB013199 Tput Pooling Activated +
	...						CB013305 Activated
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
    ...                     1) cell setup with CB013199 & CB013305 activated & BEP 853223, 6 TDD cells in one L1pool on half ABIP:
    ...                     2) Call setup
	...						3) Call setup with 6 UEs in cell1, 4 UEs in cell2, 1-2 UEs per cell in other cells
	...                     4) Collect TTI traces & gnb snapshot
    ...                 Checks:
    ...                     1) in TTI trace, the tput allocation on all cells
    ...                     2) in PM counters files, cell 1 mu paired prb on 2, 3, 4 UEs;
    ...                     3) in RD counters files, cell 1 REDUCED_PUSCH_SUBCELL_PRB_COUNT and BLOCKED_PUSCH_UE_COUNT
    ...                        should be pegged
    Dated Log New Line     ===> To setup  with custom config files
    BEP 853223 Load BSR file              ${AEQE_6_SSB_8RX_SR_Dic}
    BEP 853223 Setup With Custom Config 72A       SCF=${72A_Half_ABIP_Tdlte_3ms_SCF}
    ...                                         CFG=${6_Cells_64_UEs}
    ...                                         IPHY=${72A_6_Cells_mumimo_IPHY}
    ...                                         rdParam=@{Rad_Param_72a}
    TC BEP-853223-DL-UL-Traffic           TC_Param=${TC3_72A_Params}
    #[Teardown]



[1]BEP-TC4-72A-Full-ABIP-8DL8UL-Tdlte-3ms
    [Documentation]     BEP 853223 Basic DL+UL
    ...                 Conditions:
    ...                     6 TDD Cells on Full ABIP, 3 mumimo cells (cell 1, 2, 4)
    ...                     Stream PRB Pooling Features activated +
    ...                     CB013199 Tput Pooling Activated +
	...						CB013305 Activated
    ...                     ABIP Half Mode 6 TDD cells mapping info in 1 L1pool, 4 L1subpools
    ...                     bbmodBoardConfigType=NRFDD_NRTDD
    ...                     +----------+----------+----------+-----------+-----------+-----------+
    ...                     | NRCELL-1 | NRCELL-3 | NRCELL-5 | NRCELL-2  |NRCELL-4   |NRCELL-6   |
    ...                     +----------+----------+----------------------+-----------+-----------+
    ...                     |     L1 SubPoolId=1             |           L1 SubPoolId=0          |
    ...                     +---------------------+----------------------------------------------+
    ...                     |                   L1 PoolId=9                                      |
    ...                     +---------------------+----------------------------------------------+
    ...                 Actions:
    ...                     1) cell setup with CB013199 & CB013305 & BEP 853223 activated, 6 TDD cells in one L1pool on half ABIP:
    ...                     2) Call setup
	...						3) Call setup with 4 UE rank 1 in cell1, 4 UE rank 2 in cell 2, 4 UE rank 2 in cell 4
    ...                        1-2 UE per cell in other cells, full traffic
	...                     4) Collect TTI traces & gnb snapshot
    ...                 Checks:
    ...                     1) in TTI trace, the tput allocation on all cells
    ...                     2) in PM counters files, cell 1 mu paired prb on 2, 3, 4 UEs; Cell 2 & 4 mu paired prb on 2 UEs
    ...                     3) in RD counters files, cell 1,2,4 REDUCED_PUSCH_SUBCELL_PRB_COUNT and BLOCKED_PUSCH_UE_COUNT
    ...                        should be pegged
    Dated Log New Line     ===> To setup  with custom config files
    BEP 853223 Load BSR file              ${AEQE_6_SSB_8RX_SR_Dic}
    BEP 853223 Setup With Custom Config 72A       SCF=${72A_Full_ABIP_Tdlte_3ms_SCF}
    ...                                         CFG=${6_Cells_64_UEs_Mix_Rank_TC4}
    ...                                         IPHY=${72A_6_Cells_mumimo_IPHY}
    ...                                         rdParam=@{Rad_Param_72a}
    TC BEP-853223-DL-UL-Traffic           TC_Param=${TC4_72A_Params}
    #[Teardown]



[1]BEP-TC5-72A-Half-ABIP-8DL8UL-Tdlte-3ms
    [Documentation]     BEP 853223 Basic DL+UL
    ...                 Conditions:
    ...                     6 TDD Cells on half ABIP, 1 mumimo cells
    ...                     Stream PRB Pooling Features activated +
    ...                     CB013199 Tput Pooling Activated +
	...						CB013932 Activated + allowFallbackFromSRSToSSBBeam true on cell 1
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
    ...                     1) cell setup with CB013199 & CB013932 & BEP 853223 activated, 6 TDD cells
    ...                        in one L1pool on half ABIP:
    ...                     2) Call setup
	...						3) Call setup with 30 UE in cell1 (4 UE with Refine Beam, 16 UEs with SRS beam),
    ...                        1-2 UEs per cell in other cells, full traffic
	...                     4) Collect TTI traces & gnb snapshot & Counters files
    ...                 Checks:
    ...                     1) in TTI trace, the tput allocation on all cells
    ...                     2) in TTI trace, cell 1 multi k2 mode with 750ms
    ...                     3) in PM counters files, cell 1 multi k2 counter pegged (>0, <30000)
    ...                     4) in PM counters files, cell 1 mu paired prb on 2 UEs
    ...                     5) in PM counters files, cell 1 max sheduled ue per slot should be at least once 22
    ...                     6) in RD counters files, cell 1 REDUCED_PUSCH_SUBCELL_PRB_COUNT and BLOCKED_PUSCH_UE_COUNT
    ...                        should be pegged
    Dated Log New Line     ===> To setup  with custom config files
    BEP 853223 Load BSR file              ${AEQE_6_SSB_8RX_SR_Dic}
    BEP 853223 Setup With Custom Config 72A       SCF=${CB013932_72A_Half_ABIP_Tdlte_3ms_SCF}
    ...                                           CFG=${6_Cells_64_UEs_With_Refine_Capa}
    ...                                           IPHY=${72A_6_Cells_mumimo_IPHY}
    ...                                           rdParam=@{Rad_Param_72a}
    TC BEP-853223-DL-UL-Traffic-IWK-CB013932           TC_Param=${TC5_72A_Params}
    #[Teardown]


[1]BEP-TC6-72E-Half-ABIP-16DL4UL-100Mhz-Tdlte-0ms-DL-UL
    [Documentation]     BEP 853223 Basic DL+UL
    ...                 Conditions:
    ...                     6 TDD Cells on half ABIP, 2 mumimo cells
    ...                        Cell 1 : ul max mumimo layer = 4
    ...                        Cell 2 : ul max mumimo layer = 4
    ...                     Layer PRB Pooling Features activated +
    ...                     CB013527 Tput Pooling Activated +
	...						CB013932 Activated
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
    ...                     1) cell setup with CB012605 & CB013527 & CB013932 activated, 6 TDD cells in one L1pool on half ABIP:
    ...                     2) Call setup
	...						3) Call setup with n UE in cell1 (4 of them RANK1 UE), 4 UEs in cell2,
    ...                        1 UE per cell in other cells
	...                     4) Collect TTI traces & gnb snapshot
    ...                 Checks:
    ...                     1) in TTI trace, the tput allocation on all cells
    ...                     2) in TTI trace, cell 1 multi k2 mode with 750ms
    ...                     3) in PM counters files, cell 1 multi k2 counter pegged (>0, <30000)
    ...                     4) in PM counters files, cell 1 mu paired prb on 2 or 3 or 4 UEs
    ...                     5) in PM counters files, cell 1 max sheduled ue per slot should be at least once 22
    ...                     6) in RD counters files, cell 1, 2 REDUCED_PUSCH_SUBCELL_PRB_COUNT and BLOCKED_PUSCH_UE_COUNT
    ...                        should be pegged
    Dated Log New Line     ===> To setup  with custom config files
    BEP 853223 Load BSR file              ${AVQL_6_SSB_8RX_SR_Dic}
    CB013932 IWK Set RAD Parameters on Airphone     rad_0x70735_val=1    rad_0x70737_val=0x640000
    BEP 853223 Setup With Custom Config 72E       SCF=${72E_Half_ABIP_16DL4UL_Tdlte_0ms_SCF}
    ...                                         CFG=${6_Cells_64_UEs_Mix_Rank}
    ...                                         IPHY=${72E_6_Cells_mumimo_IPHY}
    ...                                         rdParam=@{Rad_Param_72e}
    ...                                         vendorParam=@{Custom_Vendor_For_Airphone}
    TC BEP-853223-DL-UL-Traffic-IWK-CB013932           TC_Param=${TC6_72E_Params}
    #[Teardown]


[1]BEP-OFF-TC4-72A-Full-ABIP-8DL8UL-Tdlte-3ms
    [Documentation]     BEP 853223 Basic DL+UL
    ...                 Conditions:
    ...                     6 TDD Cells on Full ABIP, 3 mumimo cells (cell 1, 2, 4)
    ...                     Stream PRB Pooling Features activated +
    ...                     CB013199 Tput Pooling Activated +
	...						CB013305 Activated
    ...                     ABIP Half Mode 6 TDD cells mapping info in 1 L1pool, 4 L1subpools
    ...                     bbmodBoardConfigType=NRFDD_NRTDD
    ...                     +----------+----------+----------+-----------+-----------+-----------+
    ...                     | NRCELL-1 | NRCELL-3 | NRCELL-5 | NRCELL-2  |NRCELL-4   |NRCELL-6   |
    ...                     +----------+----------+----------------------+-----------+-----------+
    ...                     |     L1 SubPoolId=1             |           L1 SubPoolId=0          |
    ...                     +---------------------+----------------------------------------------+
    ...                     |                   L1 PoolId=9                                      |
    ...                     +---------------------+----------------------------------------------+
    ...                 Actions:
    ...                     1) cell setup with CB013199 & CB013305 & BEP 853223 activated, 6 TDD cells in one L1pool on half ABIP:
    ...                     2) Call setup
	...						3) Call setup with 4 UE rank 1 in cell1, 4 UE rank 2 in cell 2, 4 UE rank 2 in cell 4
    ...                        1-2 UE per cell in other cells, full traffic
	...                     4) Collect TTI traces & gnb snapshot
    ...                 Checks:
    ...                     1) in TTI trace, the tput allocation on all cells
    ...                     2) in PM counters files, cell 1 mu paired prb on 2, 3, 4 UEs; Cell 2 & 4 mu paired prb on 2 UEs
    ...                     3) in RD counters files, cell 1,2,4 REDUCED_PUSCH_SUBCELL_PRB_COUNT and BLOCKED_PUSCH_UE_COUNT
    ...                        should be pegged
    Dated Log New Line     ===> To setup  with custom config files
    BEP 853223 Load BSR file              ${AEQE_6_SSB_8RX_SR_Dic}
    BEP 853223 Setup With Custom Config 72A       SCF=${72A_Full_ABIP_Tdlte_3ms_SCF}
    ...                                         CFG=${6_Cells_64_UEs_Mix_Rank_TC4}
    ...                                         IPHY=${72A_6_Cells_mumimo_IPHY}
    ...                                         rdParam=@{Rad_Param_72a_Off}
    TC BEP-853223-DL-UL-Traffic           TC_Param=${TC4_BEP_OFF_72A_Params}
    #[Teardown]