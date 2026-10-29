*** Settings ***
Documentation     [SUITE PURPOSE]  Keywords of CB015330
...               Prerequisite :
...               Scope :
...               Test Case Scenario author   : ying.yw.wu@nokia.com
...               Creation Date               : 29-07-2025
...               Modified Date               : 29-07-2025
...               Last Modified by            : ying.yw.wu@nokia.com
...               Version   Date      Author                                 Notes
...               0.1       FB2516    ying.yw.wu@nokia.com                   Creation
...               0.2       FB2519    ying.yw.wu@nokia.com                   Adding ASOH script and KPI check KWs
...               0.3       FB2522    ying.yw.wu@nokia.com                   Adding TTI check for ABIP TC010 fullboard
Resource          ./CB015330-Common-Keywords.robot
Resource          ../../../resources/common/TtiTrace/ttitrace.robot
Resource          ../../../resources/robot/KeyWordMarket.robot
Resource          ../../../../../resources/SWENG/robot/Setup.robot
Resource          ../../../resources/DSS/robot/aashell.robot
Resource          ../../../../../resources/SWENG/robot/RdCounters.robot
Library           ../../../CB013199/resources/python/CB013199_checkTTItrace.py



*** Variables ***
# BSR custom beamset package for AEQE Beamset_6
${BSR_git_path}         gitlabe1.ext.net.nokia.com/nps_vrf_8_and_9/bsr.git

# &{Dict_IWK_8927_RAT1_Check}          eventType=dlFdSchedData
# ...                                  columnName=rat0Bitmap

#CB015330 DL RD Counters
&{TC_C1_Expected_DL_BLOCK_UE_RD_Counters}         BLOCKED_PDSCH_UE_COUNT=0
&{TC_C1_Expected_DL_SHAVING_PRB_RD_Counters}      REDUCED_PDSCH_SUBCELL_PRB_COUNT=0


# The max pdsch tput limit = 5032000 (bits/slot) (corresponding to vendor file defaut setting half board)
# The max pusch tput limit = 1892000 (bits/slot) (corresponding to vendor file defaut setting half board)
# The max pdsch tput limit = 10064000 (bits/slot) (corresponding to vendor file defaut setting full board)
# The max pusch tput limit = 3784000 (bits/slot) (corresponding to vendor file defaut setting full board)

# vendor file default settings of max tput limit for ASOH or ABIP half mode/TDD/cpriOrEcpri72a:
#   maxPdschTpSlotL1Pool=5032 (kbits/slot)
#   maxPuschTpSlotL1Pool=1892 (kbits/slot)
#   ulCellTpRedFactor=75(percent)
#   maxUlPoolTpLimit=80(percent)
#   maxThresholdAlloc=1892000*0.8= 1513600


# vendor file default settings of max tput limit for  ABIP full mode/TDD/cpriOrEcpri72a:
#   maxPdschTpSlotL1Pool=10064 (kbits/slot)
#   maxPuschTpSlotL1Pool=3784 (kbits/slot)
#   ulCellTpRedFactor=75(percent)
#   maxUlPoolTpLimit=80(percent)
#   maxThresholdAlloc=1892000*0.8= 3027200

# Example values of min data alloc
# The min data alloc per slot DL = 29952 (bits/slot)
# The min data alloc per slot UL = 31200 (bits/slot)

# The detailed calculation of the min data alloc per slot (minDataPerSlotAlloc):
# 	minDataPerSlotAlloc = numMinPrbPoolingAlloc(i)* nominalCellSpecEff(i)
# 	numMinPrbPoolingAlloc(i) is the minimum number of cell PRB allocated to the cell i by BBRM
# 	nominalCellSpecEff(i) is the norminal Cell spectral efficiency of cell i
# 	nominalCellSpecEff(i) = minActiveSubcellsPerCell * minLayerPerCell * rdSpectralEffForMinAlloc * numSubCarrierPerPrb * numSymbolsPerSlot

# 	Cell i :  256 qam, 8DL8UL, 100Mhz
# 		minActiveSubcellsPerCell=1
# 		minLayerPerCell=1
# 		rdSpectralEffForMinAlloc=4 (RAD param default value : 0x58098D=4)
# 		numSubCarrierPerPrb=12
# 		numSymbolsPerSlot=13 (13 symbols pusch per slot)
#
# 		nominalCellSpecEff = 1*4*12*13=624
# 	For DL : numMinPrbPoolingAlloc = 48
# 		     minDataPerSlotAlloc = 48*624=29 952   (bits per slot)
#
# 	For UL : umMinPrbPoolingAlloc = 50
# 		     minDataPerSlotAlloc = 50*624=31 200   (bits per slot)


&{TC010_Dict_UL_TTI_Check}           eventType=ulAllocatedPooledResourcesData
...                                  columnName=allocCellThroughputUl
...                                  minDataAlloc=31200
...                                  maxThroughputL1Pool=3784000
...                                  maxThresholdTputAlloc=3027200

&{TC002_Dict_UL_TTI_Check}           eventType=ulAllocatedPooledResourcesData
...                                  columnName=allocCellThroughputUl
...                                  minDataAlloc=31200
...                                  maxThroughputL1Pool=3784000
...                                  maxThresholdTputAlloc=3027200

# vendor file default settings of max stream PRB capa per L1 subpool for ABIP
# l1PoolType=NR_L1Pool_Thor_TDD_FR1_eCPRI_7_2e
# For: UL
#  before CB013127:
#    maxNumLayerPrbL1Sp=1092, totalNumLayerPrb per L1 pool=2184
#
#  With CB013527:
#    maxNumLayerPrbL1Sp=2184, totalNumLayerPrb per L1 pool=4368
#
# For: DL
#  before CB013127:
#    maxNumLayerPrbL1Sp=2184, totalNumLayerPrb per L1 pool=4368
#
#  With CB013527:
#    maxNumLayerPrbL1Sp=4368, totalNumLayerPrb per L1 pool=8736

#todo : to adapt below for CB015330
&{Dict_UL_PRB_TTI_Check}            eventType=ulAllocatedPooledResourcesData
...                                 columnName=numAllocCellPrbUl
...                                 minPrbAlloc=54
...                                 maxCellPrbL1PoolLegacy=819
...                                 maxCellPrbL1PoolCB013199=1090

&{Dict_DL_PRB_TTI_Check}            eventType=dlAllocatedPooledResourcesData
...                                 columnName=numAllocCellPrbDl
...                                 minPrbAlloc=48
...                                 maxCellPrbL1PoolLegacy=1092
...                                 maxCellPrbL1PoolCB013199=1638
#end todo

@{PUSCH_Data_Slots_Counters}               M55308C00009      M55308C00011
@{MAC_PDU_CELL_PUSCH_Tput_Counters}        M55304C03000      M55304C03001      M55304C03002
...                                  M55304C03003      M55304C03004      M55304C03005
...                                  M55304C03006      M55304C03007      M55304C03008
...                                  M55304C03009      M55304C03010      M55304C03011
...                                  M55304C03012      M55304C03013      M55304C03014
...                                  M55304C03015      M55304C03016      M55304C03017
...                                  M55304C03018      M55304C03019      M55304C03020
...                                  M55304C03021      M55304C03022      M55304C03023
...                                  M55304C03024      M55304C03025      M55304C03026
...                                  M55304C03027      M55304C03028      M55304C07000
...                                  M55304C07001      M55304C07002      M55304C07003
...                                  M55304C07004      M55304C07005      M55304C07006
...                                  M55304C07007      M55304C07008      M55304C07009
...                                  M55304C07010      M55304C07011      M55304C07012
...                                  M55304C07013      M55304C07014      M55304C07015
...                                  M55304C07016      M55304C07017      M55304C07018
...                                  M55304C07019      M55304C07020      M55304C07021
...                                  M55304C07022      M55304C07023      M55304C07024
...                                  M55304C07025      M55304C07026      M55304C07027
...                                  M55304C09000      M55304C09001      M55304C09002
...                                  M55304C09003      M55304C09004      M55304C09005
...                                  M55304C09006      M55304C09007      M55304C09008
...                                  M55304C09009      M55304C09010      M55304C09011
...                                  M55304C09012      M55304C09013      M55304C09014
...                                  M55304C09015      M55304C09016      M55304C09017
...                                  M55304C09018      M55304C09019      M55304C09020
...                                  M55304C09021      M55304C09022      M55304C09023
...                                  M55304C09024      M55304C09025      M55304C09026
...                                  M55304C09027      M55367C05000      M55367C05001
...                                  M55367C05002      M55367C05003      M55367C05004
...                                  M55367C05005      M55367C05006      M55367C05007
...                                  M55367C05008      M55367C05009      M55367C05010
...                                  M55367C05011      M55367C05012      M55367C05013
...                                  M55367C05014      M55367C05015      M55367C05016
...                                  M55367C05017      M55367C05018      M55367C05019
...                                  M55367C05020      M55367C05021      M55367C05022
...                                  M55367C05023      M55367C05024      M55367C05025
...                                  M55367C05026      M55367C05027      M55367C05028
...                                  M55370C00011      M55370C00017

@{PDSCH_Data_Slots_Counters}         M55308C00008      M55308C00016      M55308C00018
@{MAC_PDU_CELL_PDSCH_Tput_Counters}        M55304C01000      M55304C01001      M55304C01002
...                                  M55304C01003      M55304C01004      M55304C01005
...                                  M55304C01006      M55304C01007      M55304C01008
...                                  M55304C01009      M55304C01010      M55304C01011
...                                  M55304C01012      M55304C01013      M55304C01014
...                                  M55304C01015      M55304C01016      M55304C01017
...                                  M55304C01018      M55304C01019      M55304C01020
...                                  M55304C01021      M55304C01022      M55304C01023
...                                  M55304C01024      M55304C01025      M55304C01026
...                                  M55304C01027      M55304C01028      M55304C05000
...                                  M55304C05001      M55304C05002      M55304C05003
...                                  M55304C05004      M55304C05005      M55304C05006
...                                  M55304C05007      M55304C05008      M55304C05009
...                                  M55304C05010      M55304C05011      M55304C05012
...                                  M55304C05013      M55304C05014      M55304C05015
...                                  M55304C05016      M55304C05017      M55304C05018
...                                  M55304C05019      M55304C05020      M55304C05021
...                                  M55304C05022      M55304C05023      M55304C05024
...                                  M55304C05025      M55304C05026      M55304C05027
...                                  M55366C05000      M55366C05001      M55366C05002
...                                  M55366C05003      M55366C05004      M55366C05005
...                                  M55366C05006      M55366C05007      M55366C05008
...                                  M55366C05009      M55366C05010      M55366C05011
...                                  M55366C05012      M55366C05013      M55366C05014
...                                  M55366C05015      M55366C05016      M55366C05017
...                                  M55366C05018      M55366C05019      M55366C05020
...                                  M55366C05021      M55366C05022      M55366C05023
...                                  M55366C05024      M55366C05025      M55366C05026
...                                  M55366C05027      M55366C05028


*** Keywords ***
CB015330 Load BSR file
    [Documentation]         Load BSR file to enable the use of Spatial Managed UE position
    [Arguments]             ${BSR_Dic}

    Dated Log New Line     ===> Download BSR file ${BSR_Dic.BSR_file_name}
    Download Package Using Git Update OAM
    ...                                 git_path=${BSR_git_path}
    ...                                 git_folder=${BSR_Dic.BSR_folder}
    ...                                 git_file_name=${BSR_Dic.BSR_file_name}
    ...                                 target_dir=${LOG_PATH}/BSR


TC CB015330-A-Multi-BWP-DL-UL
    [Documentation]
    [Arguments]              ${UEdefListparam}
    ...                      ${Kpi_Csv_File}
    Init Sequence            ${UEdefListparam}
    Step                     CB015330 Build Multi UE List From CFG            UEdefList=${UEdefListparam}
    Step                     Restart TL
    ${returned_syslog}       CB015330 Cell Setup With Syslogs
    Critical Step            CB015330 attach SA UEs                           UElist=${Multi_UE_list}
    Step                     CB015330 Set Mumimo UEs position                 UElist=${Multi_UE_list}
    Step                     CB015330 start traffic DL                        UElist=${Multi_UE_list}
    Traced Sleep             duration=5s                                      msg=DL traffic started ...
    Step                     CB015330 start traffic UL                        UElist=${Multi_UE_list}
    Traced Sleep             duration=5s                                      msg=UL traffic started ...
    Step                     CB015330 start TTI Capture                       suffix=DL_UL
    Traced Sleep             duration=3s                                      msg=start DL UL traffic TTI capture...
    Step                     CB015330 stop TTI Capture                        suffix=DL_UL_Traffic
    Traced Sleep             duration=60s                                     msg=stop TTI waiting for 60seconds
    Step                     CB015330 TTI Post Processing And Check           TTIpcap=${TTIpcap}
    Traced Sleep             duration=1320s                                    msg=waiting for collecting PM counters file
    Step                     CB015330 Check KPI                 KPI_Constraints_CSV_File=${Kpi_Csv_File}
	Step                     Oam.OAM Get Snapshot
    # Step                     GenericTest.Display Diagnosis
    [Teardown]               CB015330 End Of TC


TC CB015330-DL-UL
    [Documentation]
    [Arguments]              ${UEdefListparam}
    ...                      ${Kpi_Csv_File}
    Init Sequence            ${UEdefListparam}
    Step                     CB015330 define SA UEs            UEdefList=${UEdefListparam}
    Step                     Restart TL
    ${returned_syslog}       CB015330 Cell Setup With Syslogs
    Critical Step            CB015330 attach SA UEs                           UElist=${UEs_SA_list}
    Step                     CB015330 Set Mumimo UEs position                 UElist=${UEs_SA_list}
    Step                     CB015330 start traffic DL                        UElist=${UEs_SA_list}
    Traced Sleep             duration=5s                                      msg=DL traffic started ...
    Step                     CB015330 start traffic UL                        UElist=${UEs_SA_list}
    Traced Sleep             duration=5s                                      msg=UL traffic started ...
    Step                     CB015330 start TTI Capture                       suffix=DL_UL
    Traced Sleep             duration=3s                                      msg=start DL UL traffic TTI capture...
    Step                     CB015330 stop TTI Capture                        suffix=DL_UL_Traffic
    Traced Sleep             duration=60s                                     msg=stop TTI waiting for 60seconds
    Step                     CB015330 TTI Post Processing And Check           TTIpcap=${TTIpcap}
	Traced Sleep             duration=1320s                                    msg=waiting for collecting PM counters file
    Step                     CB015330 Check KPI                 KPI_Constraints_CSV_File=${Kpi_Csv_File}
    Step                     Oam.OAM Get Snapshot
    # Step                     GenericTest.Display Diagnosis
    [Teardown]               CB015330 End Of TC


TC CB015330-DL-UL-TC002
    [Documentation]
    [Arguments]              ${UEdefListparam}
    ...                      ${Kpi_Csv_File}
    Init Sequence            ${UEdefListparam}
    Step                     CB015330 define SA UEs            UEdefList=${UEdefListparam}
    Step                     Restart TL
    ${returned_syslog}       CB015330 Cell Setup With Syslogs
    Critical Step            CB015330 attach SA UEs                           UElist=${UEs_SA_list}
    Step                     CB015330 Set Mumimo UEs position                 UElist=${UEs_SA_list}
    Step                     CB015330 start traffic DL                        UElist=${UEs_SA_list}
    Traced Sleep             duration=5s                                      msg=DL traffic started ...
    Step                     CB015330 start traffic UL                        UElist=${UEs_SA_list}
    Traced Sleep             duration=5s                                      msg=UL traffic started ...
    Step                     CB015330 start TTI Capture                       suffix=DL_UL
    Traced Sleep             duration=3s                                      msg=start DL UL traffic TTI capture...
    Step                     CB015330 stop TTI Capture                        suffix=DL_UL_Traffic
    Traced Sleep             duration=60s                                     msg=stop TTI waiting for 60seconds
    Step                     CB015330 TC002 TTI Post Processing And Check           TTIpcap=${TTIpcap}
	Traced Sleep             duration=1320s                                    msg=waiting for collecting PM counters file
    Step                     CB015330 Check KPI                 KPI_Constraints_CSV_File=${Kpi_Csv_File}
    Step                     Oam.OAM Get Snapshot
    # Step                     GenericTest.Display Diagnosis
    [Teardown]               CB015330 End Of TC

TC CB015330-DL-UL-TC009
    [Documentation]
    [Arguments]              ${UEdefListparam}
    ...                      ${Kpi_Csv_File}
    Init Sequence            ${UEdefListparam}
    Step                     CB015330 define SA UEs            UEdefList=${UEdefListparam}
    Step                     Restart TL
    ${returned_syslog}       CB015330 Cell Setup With Syslogs
    Critical Step            CB015330 attach SA UEs                           UElist=${UEs_SA_list}
    Step                     CB015330 Set Mumimo UEs position                 UElist=${UEs_SA_list}
    Step                     CB015330 start traffic DL                        UElist=${UEs_SA_list}
    Traced Sleep             duration=5s                                      msg=DL traffic started ...
    Step                     CB015330 start traffic UL                        UElist=${UEs_SA_list}
    Traced Sleep             duration=30s                                      msg=UL traffic started ...
    Step                     CB015330 Set SINR Pathloss On UE                 UElist=${UEs_SA_list}
    Step                     CB015330 start TTI Capture                       suffix=DL_UL
    Traced Sleep             duration=3s                                      msg=start DL UL traffic TTI capture...
    Step                     CB015330 stop TTI Capture                        suffix=DL_UL_Traffic
    Traced Sleep             duration=60s                                     msg=stop TTI waiting for 60seconds
    Step                     CB015330 TTI Post Processing And Check           TTIpcap=${TTIpcap}
	Traced Sleep             duration=1320s                                    msg=waiting for collecting PM counters file
    Step                     CB015330 Check KPI                 KPI_Constraints_CSV_File=${Kpi_Csv_File}
    Step                     Oam.OAM Get Snapshot
    # Step                     GenericTest.Display Diagnosis
    [Teardown]               CB015330 End Of TC


TC CB015330-DL-UL-TC010
    [Documentation]
    [Arguments]              ${UEdefListparam}
    ...                      ${Kpi_Csv_File}
    Init Sequence            ${UEdefListparam}
    Step                     CB015330 define SA UEs            UEdefList=${UEdefListparam}
    Step                     Restart TL
    ${returned_syslog}       CB015330 Cell Setup With Syslogs
    Critical Step            kwmkt_run_script_once    ${CURDIR}/../egateCmds/TC010_With_Pathloss_Mumimo.sce
    Step                     CB015330 start TTI Capture                       suffix=DL_UL
    Traced Sleep             duration=3s                                      msg=start DL UL traffic TTI capture...
    Step                     CB015330 stop TTI Capture                        suffix=DL_UL_Traffic
    Traced Sleep             duration=60s                                     msg=stop TTI waiting for 60seconds
    Step                     CB015330 TC010 TTI Post Processing And Check           TTIpcap=${TTIpcap}
	Traced Sleep             duration=1320s                                    msg=waiting for collecting PM counters file
    Step                     CB015330 Check KPI                 KPI_Constraints_CSV_File=${Kpi_Csv_File}
    Step                     Oam.OAM Get Snapshot
    # Step                     GenericTest.Display Diagnosis
    [Teardown]               CB015330 End Of TC

CB015330 Check KPI
    [Arguments]            ${KPI_Constraints_CSV_File}

    Dated Log New Line     ====> collect and check TPUT & BLER KPIs
    ${PM_lastFile}         Counters.Collect PM files from BTS    ${LOG_PATH}/PM_FILES
    Dated Log New Line     ====> Last PM File : ${PM_lastFile}
    # verify KPI constraints
    KPI Evaluate                    pmFile=${PM_lastFile}
    ...                             constraintsFile=${KPI_Constraints_CSV_File}
    ...                             failOnError=${True}
    # display KPI values
    ${nbOfCells}    Get Length    ${TDD_Cell_list}
    FOR    ${cell_id_idx}    IN RANGE    1    ${nbOfCells}+1
        Dated Log new line        ==== check KPI (mac pusch cell tput) on cell ${cell_id_idx} : ====
        ${kpi_nr_5089_cell}     Get KPI Tput Value     ${cell_id_idx}
        ...                                            ${MAC_PDU_CELL_PUSCH_Tput_Counters}
        ...                                            ${PUSCH_Data_Slots_Counters}
        ...                                            ${LOG_PATH}/PM_FILES
        Dated Log new line        cell ${cell_id_idx} : kpi NR_5089 : ${kpi_nr_5089_cell}
        Dated Log new line        ==== check KPI NR_5088 (mac pdsch cell tput) on cell ${cell_id_idx} : ====
        ${kpi_nr_5088_cell}     Get KPI Tput Value     ${cell_id_idx}
        ...                                            ${MAC_PDU_CELL_PDSCH_Tput_Counters}
        ...                                            ${PDSCH_Data_Slots_Counters}
        ...                                            ${LOG_PATH}/PM_FILES
        Dated Log new line        cell ${cell_id_idx} : kpi NR_5088 : ${kpi_nr_5088_cell}
    END


CB015330 TTI Post Processing And Check
    [Arguments]            ${TTIpcap}
    Dated Log New Line     ===> convert TTI trace ${TTIpcap}
    ${TTIjson}             Convert TTI trace from pcap to others    input_file_path=${TTIpcap}
    ${TTIcsv}              decode_tti_traces_json_using_TtitraceReaderEvtDec    jsonPathName=${TTIjson}    num_of_events=45000

CB015330 TC002 TTI Post Processing And Check
    [Arguments]            ${TTIpcap}
    Dated Log New Line     ===> convert TTI trace ${TTIpcap}
    ${TTIjson}             Convert TTI trace from pcap to others    input_file_path=${TTIpcap}
    ${TTIcsv}              decode_tti_traces_json_using_TtitraceReaderEvtDec    jsonPathName=${TTIjson}    num_of_events=45000
    Dated Log New Line     ====> json spliting ... ====
	${file_1}		Set Variable	/tmp/pool_x.json
	${file_2}		Set Variable	/tmp/pool_y.json
	Split_Json_Of_2_L1Pools		jsonPathName=${TTIjson}    json_file_1=${file_1}	    json_file_2=${file_2}
	Dated Log New Line     ====> check ul reduction factor in ${file_1} and ${file_2} ... ====
    UL Reduction Factor Check in TTI        ${TC002_Dict_UL_TTI_Check}    ${file_1}
    UL Reduction Factor Check in TTI        ${TC002_Dict_UL_TTI_Check}    ${file_2}


CB015330 TC010 TTI Post Processing And Check
    [Arguments]            ${TTIpcap}
    Dated Log New Line     ===> convert TTI trace ${TTIpcap}
    ${TTIjson}             Convert TTI trace from pcap to others    input_file_path=${TTIpcap}
    ${TTIcsv}              decode_tti_traces_json_using_TtitraceReaderEvtDec    jsonPathName=${TTIjson}    num_of_events=45000
    UL Reduction Factor Check in TTI        ${TC010_Dict_UL_TTI_Check}    ${TTIjson}



UL Reduction Factor Check in TTI
	[Documentation]                    Check the UL Tput Allocation and UL Reduction Factor of all cells in TTI traces
    [Arguments]                        ${Dict_TTI_Check}    ${path_to_json}
    ${UL_RedFactor_Check_failure}      Check_UlCellTpRedFactor
    ...                                     jsonPathName=${path_to_json}
    ...                                     eventTTI=${Dict_TTI_Check.eventType}
    ...                                     columnInEvent=${Dict_TTI_Check.columnName}
    ...                                     min_data_allocation=${Dict_TTI_Check.minDataAlloc}
    ...                                     maxTputLimit=${Dict_TTI_Check.maxThroughputL1Pool}
	...										maxThresholdTputAlloc=${Dict_TTI_Check.maxThresholdTputAlloc}
    Dated Log New Line         ===> TTI Check_failure status is: ${UL_RedFactor_Check_failure}
    should not be true      '${UL_RedFactor_Check_failure}' =='1'

Get KPI Tput Value
    [Arguments]              ${cellID}     ${Data_Sum_Counters}     ${Data_Slots_Sum_Counters}    ${pm_path}
    Dated Log new line       === Check KPI  on cell ${cellID}

    # sum of mac pdu pusch cell tput
    ${sum_of_data_bytes}          Set Variable      0
    FOR    ${counter}    IN    @{Data_Sum_Counters}
        ${value}              Retrieve Counter Sum of Values From Pm Files For Object With Name
        ...                   ${pm_path}    NRCELL    ${counter}    object_id=${cellID}

        ${sum_of_data_bytes}      Evaluate        ${sum_of_data_bytes} + ${value}
    END
    ${sum_of_data_bits}           Evaluate        ${sum_of_data_bytes}*8
    Dated Log new line       - Total bytes : ${sum_of_data_bytes}
    Dated Log new line       - Total bits : ${sum_of_data_bits}

    # sum of pusch data slots
    ${sum_of_data_slots}       Set Variable      0
    FOR    ${counter}    IN    @{Data_Slots_Sum_Counters}
        ${value}              Retrieve Counter Sum of Values From Pm Files For Object With Name
        ...                   ${pm_path}    NRCELL    ${counter}    object_id=${cellID}

        ${sum_of_data_slots}     Evaluate        ${sum_of_data_slots} + ${value}
    END
    Dated Log new line       - total pusch slots : ${sum_of_data_slots}

    ${kpi_value}     Run Keyword If     ${sum_of_data_slots}!=0
    ...              Evaluate     ${sum_of_data_bits} / ${sum_of_data_slots}
    ...              ELSE
    ...              Set Variable    0
    Dated Log new line       - kpi on cell ${cellID} : ${kpi_value}
    RETURN                   ${kpi_value}
