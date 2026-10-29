*** Settings ***

Documentation     [SUITE PURPOSE]   feature CB013932 ABIP
...               Prerequisite      : CB09514 (parity ecpri72e) & CB012605 (layer prb pooling ecpri72e)
...               Scope             : cell setup & call setup & PRB and Tput pooling
...
...               Test Case Scenario author   : ying.yw.wu@nokia.com
...               Creation Date               : 19-11-2025
...               Modified Date               : 24-11-2025
...               Last Modified by            : ying.yw.wu@nokia.com
...               Version   Date      Author                             Notes
...               0.1       FB2524    ying.yw.wu@nokia.com                   Creation
...               0.2       FB2525    ying.yw.wu@nokia.com                   TTI processing K2 & Timing Check
...               0.3       FB2603    philippe.daroux@nokia.com              Adding steps to check Counter and TTI status when:
...                                                                          Fallback is off
...                                                                          Fallback is on and 2 cells 2 Cores
...                                                                          Fallback is on and 1 cells 2 Cores

Resource          ./resources/robot/CB013932-Common-Keywords.robot
Resource          ./resources/robot/CB013932-A-Keywords.robot
Resource          ../../../resources/SWENG/robot/Setup.robot

Suite Setup       Suite Setup from scratch    keepAllUeDataInCfgFile=${True}    listBackupFiles=${FD_ALL}


*** Variables ***

#Custom Config ABIP ecpri72e TdLte3ms mumimo
${72E_Half_ABIP_Tdlte_3ms_SCF}    ${CURDIR}/config/customCFG/ABIP/CB013305_Half_ABIP_72E_16DL8UL_8RX_Beamset_6_Dyn_AL.xml
# ${72E_Half_ABIP_Tdlte_3ms_SCF}    ${CURDIR}/config/customCFG/ABIP/CB013305_Half_ABIP_72E_16DL8UL_8RX_Beamset_6.xml
${6_Cells_64_UEs}                 ${CURDIR}/config/customCFG/ABIP/basic_wts_step2_64_UEs.cfg
${72E_6_Cells_mumimo_IPHY}        ${CURDIR}/config/customCFG/ABIP/6_Cells_72e_mumimo_iphy.xml

#Custom Config ABIP ecpri72a Tdlte3ms mumimo
${72A_Half_ABIP_Tdlte_3ms_SCF}    ${CURDIR}/config/customCFG/ABIP/CB013305_Half_ABIP_72A_8DL8UL_4RX_Beamset_6_Dyn_AL_Selection.xml
# ${72A_Half_ABIP_Tdlte_3ms_SCF}    ${CURDIR}/config/customCFG/ABIP/CB013305_Half_ABIP_72A_8DL8UL_4RX_Beamset_6.xml
${6_Cells_64_UEs_Diff_Capa}       ${CURDIR}/config/customCFG/ABIP/basic_wts_step2_64_UEs_UE_Capa_Refine_SRS.cfg
${72A_6_Cells_mumimo_IPHY}        ${CURDIR}/config/customCFG/ABIP/6_Cells_72a_mumimo_iphy.xml


&{TC_72E_Params}                  Step_1_Sce=${CURDIR}/resources/egateCmds/UE_1_To_64_Attach.sce
...                               Step_2_Sce=${CURDIR}/resources/egateCmds/UE_1_To_30_Testmode_72e_Sinr.sce
...                               Step_3_Sce=${CURDIR}/resources/egateCmds/UE_1_To_30_Testmode_72e_Ul_Beam_Pos.sce
...                               Step_4_Sce=${CURDIR}/resources/egateCmds/UE_Traffic_UL_64_UEs_5mbps.sce
...                               First_Cell_Idx=1
...                               Second_Cell_Idx=4
...                               Bler_KPI_File=${CURDIR}/config/CounterKPI/CB013932_BLER_KPI.csv

&{TC_72A_Params}                  Step_1_Sce=${CURDIR}/resources/egateCmds/UE_1_To_64_Attach.sce
...                               Step_2_Sce=${CURDIR}/resources/egateCmds/UE_1_To_4_Testmode_72A_Refine_Beams.sce
...                               Step_3_Sce=${CURDIR}/resources/egateCmds/UE_5_To_20_Testmode_72A_SRS_Beams.sce
...                               Step_4_Sce=${CURDIR}/resources/egateCmds/UE_Traffic_UL_64_UEs_5mbps.sce
...                               First_Cell_Idx=1
...                               Second_Cell_Idx=4
...                               Bler_KPI_File=${CURDIR}/config/CounterKPI/CB013932_BLER_KPI_cell1.csv

${6_Cells_BLER_KPI}               ${CURDIR}/config/CounterKPI/CB013932_BLER_KPI.csv

# BSR package
&{CB013932_AVQL_6_SSB_8RX_SR_Dic}        BSR_file_name=BSR_AVQL_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00002.zip
...                                      BSR_folder=CB013932

&{CB013932_AEQE_6_SSB_8RX_SR_Dic}        BSR_file_name=BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip
...                                      BSR_folder=CB008830

# ---------------------------------------------------------------------------------------------------------------
*** Test Cases ***

[1]CB013932-Prep-72E-Half-ABIP-Tdlte-3ms-DL-UL
    [Documentation]     CB013932 Basic DL+UL
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
	...						3) Call setup with 12 UE in cell1, 1 UE per cell in other cells
	...                     3) Collect TTI traces & gnb snapshot
    ...                 Checks:
    ...                     To be completed
    Dated Log New Line     ===> To setup  with custom config files
    CB013932 Load BSR file              ${CB013932_AVQL_6_SSB_8RX_SR_Dic}
    CB013932 Setup With Custom Config 72E       SCF=${72E_Half_ABIP_Tdlte_3ms_SCF}
    ...                                         CFG=${6_Cells_64_UEs}
    ...                                         IPHY=${72E_6_Cells_mumimo_IPHY}
    ...                                         rdParam=@{Rad_Param_CB013932_72e}
    ...                                         vendorParam=@{Custom_Vendor_For_Airphone}
    TC CB013932-DL-UL-Traffic           TC_Param=${TC_72E_Params}
    #[Teardown]

[1]CB013932-Prep-72A-Half-ABIP-Tdlte-3ms-DL-UL
    [Documentation]     CB013932 Basic DL+UL
    ...                 Conditions:
    ...                     6 TDD Cells on half ABIP, 1 mumimo cells
    ...                     PRB Pooling Features activated (CB008940+CB010513)+
    ...                     CB013199 Tput Pooling Activated + CB013305 Activated
	...						CB013932 is Activated
    ...                     ABIP Half Mode 6 TDD cells mapping info in 1 L1pool
    ...                     bbmodBoardConfigType=NRFDD_NRTDD
    ...                     +----------+----------+----------+-----------+-----------+-----------+
    ...                     | NRCELL-1 | NRCELL-3 | NRCELL-5 | NRCELL-2  |NRCELL-4   |NRCELL-6   |
    ...                     +----------+----------+----------------------+-----------+-----------+
    ...                     |     L1 SubPoolId=1             |           L1 SubPoolId=0          |
    ...                     +---------------------+----------------------------------------------+
    ...                     |                   L1 PoolId=9                                      |
    ...                     +---------------------+----------------------------------------------+
    ...                     Cell1 and Cell 4 are in same L2_subpool meaning if both cells are activated we are in:
    ...                                                                         2 Cells 2 cores
    ...                                                                     if cell1 is the only activated we are in:
    ...                                                                         1 cell 2 cores
    ...                 Actions:
    ...                     1) cell setup with CB012605, CB013527, CB013305 and CB013932 activated,
    ...                        6 TDD cells in one L1pool on half ABIP. allowFallbackFromSRSToSSBBeam is not activated on Cell1
    ...                        All cells are activated(2 Cells/2 Cores)
	...						2) Call setup with 64 UE in cell1
    ...                     3) Collect counter M55308C18002
	...                     4) Collect TTI traces & gnb snapshot
    ... 					5) allowFallbackFromSRSToSSBBeam chaned ONLINE to TRUE on Cell1
    ...                     6) Collect counter M55308C18002
	...                     7) Collect TTI traces & gnb snapshot
    ... 					8) Lock cell4
    ...                     9) Collect counter M55308C18002
	...                     10) Collect TTI traces & gnb snapshot
    ... 					11) allowFallbackFromSRSToSSBBeam chaned ONLINE to FALSE on Cell1
    ...                     12) Collect counter M55308C18002
	...                     13) Collect TTI traces & gnb snapshot
    ...                 Checks:
    ...                     1) All cells are up and running, Snapshot shows Cell1 and 4 in same L2 subpool
	...						2) Call established on 64 Ues
    ...                     3) The max nb of scheduled UE(M55308C18002) can reach the expected value, default is 16
	...                     4) TTI traces & multiple K2 mode is triggered, the counter M55365C27011 should not be 0
    ... 					5) allowFallbackFromSRSToSSBBeam correctly chenged to TRUE on Cell1
    ...                     6) The max nb of scheduled UE(M55308C18002) can reach the expected value, is 23
	...                     7) TTI traces & multiple K2 mode is triggered, the counter M55365C27011 should not be 0
    ... 					8) Cell4 is correctly blocked as seen in Snapshot
    ...                     9) The max nb of scheduled UE(M55308C18002) can reach the expected value, is 24
	...                     10) TTI traces & multiple K2 mode is triggered, the counter M55365C27011 should not be 0
    ...                     11) Collect counter M55308C18002
	...                     12) Collect TTI traces & gnb snapshot
    ... 					13) allowFallbackFromSRSToSSBBeam correctly chenged to FALSE on Cell1
    ...                     14) The max nb of scheduled UE(M55308C18002) can reach the expected value, is 16
	...                     15) TTI traces & multiple K2 mode is triggered, the counter M55365C27011 should not be 0
    Dated Log New Line     ===> To setup  with custom config files
    CB013932 Load BSR file              ${CB013932_AEQE_6_SSB_8RX_SR_Dic}
    CB013932 Set RAD Parameters on Airphone
    CB013932 Setup With Custom Config 72A       SCF=${72A_Half_ABIP_Tdlte_3ms_SCF}
    ...                                         CFG=${6_Cells_64_UEs_Diff_Capa}
    ...                                         IPHY=${72A_6_Cells_mumimo_IPHY}
    ...                                         rdParam=@{Rad_Param_CB013932_72a}
    TC CB013932-DL-UL-Traffic           TC_Param=${TC_72A_Params}
   # [Teardown]

