*** Settings ***
Documentation     [SUITE PURPOSE]  Keywords of CB013932-A-B
...               Prerequisite :
...               Scope :
...               Test Case Scenario author   : ying.yw.wu@nokia.com
...               Creation Date               : 19-03-2025
...               Modified Date               : 19-03-2025
...               Last Modified by            : ying.yw.wu@nokia.com
...               Version   Date      Author                                 Notes
...               0.1       FB2524    ying.yw.wu@nokia.com                   Creation with call setup and PM counters check
...               0.2       FB2525    ying.yw.wu@nokia.com                   TTI processing K2 & Timing Check

Resource          ./BEP-853223-Common-Keywords.robot
Resource          ../../../resources/common/TtiTrace/ttitrace.robot
Resource          ../../../../../resources/SWENG/robot/Setup.robot
Resource          ../../../resources/DSS/robot/aashell.robot
Resource          ../../../resources/robot/KeyWordMarket.robot
Resource          ../../../../../resources/SWENG/robot/RdCounters.robot
Resource          ../../../../../resources/SWENG/robot/Counters.robot
Resource          ../../../../../resources/SWENG/robot/TtiConvertInterface.robot
Resource          ../../../resources/common/TtiTrace/ttitrace.robot
Library           ../python/BEP-853223_checkTTItrace.py
Library           ../../../CB013199/resources/python/CB013199_checkTTItrace.py
Library           OperatingSystem
Library           taf.sbts.oam.coam.admin        WITH NAME        coam



*** Variables ***

# BSR custom beamset package for AEQE Beamset_6
${BSR_git_path}         gitlabe1.ext.net.nokia.com/nps_vrf_8_and_9/bsr.git

# Variables for TTI check
# The detailed calculation of the min data alloc per slot (minDataPerSlotAlloc):
# 	minDataPerSlotAlloc = numMinPrbPoolingAlloc(i)* nominalCellSpecEff(i)
# 	numMinPrbPoolingAlloc(i) is the minimum number of cell PRB allocated to the cell i by BBRM
# 	nominalCellSpecEff(i) is the norminal Cell spectral efficiency of cell i
# 	nominalCellSpecEff(i) = minActiveSubcellsPerCell * minLayerPerCell * rdSpectralEffForMinAlloc * numSubCarrierPerPrb * numSymbolsPerSlot

# 	Cell i :  256 qam, 16DL8UL, 50Mhz
# 		minActiveSubcellsPerCell=1
# 		minLayerPerCell=1
# 		rdSpectralEffForMinAlloc=4 (RAD param default value : 0x58098D=4)
# 		numSubCarrierPerPrb=12
# 		numSymbolsPerSlot=13 (13 symbols pusch per slot)
#
# 		nominalCellSpecEff = 1*4*12*13=624
# 	For DL : numMinPrbPoolingAlloc = 48 (hardcoded value in CPRT, CB012605)
# 		     minDataPerSlotAlloc = 48*624=29 952   (bits per slot)
#
# 	For UL : umMinPrbPoolingAlloc = 24(hardcoded value in CPRT, CB012605)
# 		     minDataPerSlotAlloc = 24*624=14 976   (bits per slot)

# vendor file settings (modifed in TC) of max tput limit for ABIP/half mode/TDD/cpriOrEcpri72e:
#   maxPdschTpSlotL1Pool=5032 (kbits/slot)
#   maxPuschTpSlotL1Pool=1250 (kbits/slot)

&{Dict_UL_Tput_TTI_Check}           eventType=ulAllocatedPooledResourcesData
...                                 columnName=allocCellThroughputUl
...                                 minDataAlloc=14976
...                                 maxThroughputL1Pool=1250000


#UL RD Counters
&{Expected_UL_BLOCK_UE_RD_Counters}         BLOCKED_PUSCH_UE_COUNT=0
&{Expected_UL_SHAVING_PRB_RD_Counters}      REDUCED_PUSCH_SUBCELL_PRB_COUNT=0


*** Keywords ***
TC BEP-853223-DL-UL-Traffic-IWK-CB013932
    [Documentation]          BEP-853223 DL UL Traffic
    [Arguments]              ${TC_Param}
    Init Sequence            ${TC_Param}
    ${syslog}                SYSLOG Start    host=${GNB_DU.sys[0].M}          name=Start_Up
    Step                     Restart TL
    ${syslog_start_up}       SYSLOG STOP                                      syslog=${syslog}
    ${returned_syslog}       BEP 853223 Cell Setup With Syslogs
    ${syslog}                SYSLOG Start    host=${GNB_DU.sys[0].M}          name=UE_Attach
    Critical Step            BEP 853223 UE Calls Steps With SCE Files           ${TC_Param.Step_1_Sce}
    Traced Sleep             duration=3s                                      msg=UE Call Step1 ...
    Critical Step            BEP 853223 UE Calls Steps With SCE Files           ${TC_Param.Step_2_Sce}
    Traced Sleep             duration=3s                                      msg=UE Call Step2 ...
    Critical Step            BEP 853223 UE Calls Steps With SCE Files           ${TC_Param.Step_3_Sce}
    Traced Sleep             duration=3s                                      msg=UE Call Step3 ...
    ${syslog_ue_attach}      SYSLOG STOP                                      syslog=${syslog}
    ${syslog}                SYSLOG Start    host=${GNB_DU.sys[0].M}          name=UE_Traffic_UL
    Critical Step            BEP 853223 UE Calls Steps With SCE Files           ${TC_Param.Step_4_Sce}
    Traced Sleep             duration=3s                                      msg=UE Call Step4 ...    
    Step                     BEP 853223 start TTI Capture                       suffix=UL
    Traced Sleep             duration=2s                                      msg=start UL traffic TTI capture...
    Step                     BEP 853223 stop TTI Capture                        suffix=UL_Traffic
    Traced Sleep             duration=60s                                     msg=stop TTI waiting for 60seconds
    ${syslog_ul_traffic}     SYSLOG STOP                                      syslog=${syslog}
    Step                     BEP 853223 TTI Post Processing Tput Alloc        TTIpcap=${TTIpcap}
    ...                                                                       Expected_Dict_UL_Tput=${TC_Param.Expected_UL_Alloc_Sum}
    Step                     BEP 853223 TTI Post Processing Multi K2          TTIpcap=${TTIpcap}
    ${syslog}                SYSLOG Start    host=${GNB_DU.sys[0].M}          name=UE_Traffic_UL_Long
    Traced Sleep             duration=360s                                    msg=waiting for collecting PM counters file
    ${syslog_long}           SYSLOG STOP                                      syslog=${syslog}
    Step                     BEP 853223 Collect PM Counters File
    Step                     Check Mu Paired UE PRB Counters In Multi Cells        ${TC_Param}[Cell_Index_List]
    Step                     BEP 853223 UL RD Counters Check In Multi Cells        ${TC_Param}[Cell_Index_List]
    Step                     Check Expected Maximum number of Scheduled Ues UL on Cell
    Step                     Check Multiple K2 Mode Counter on Cell
    Step                     BEP 853223 Check BLER KPIs                         BLER_KPI_Constraints_File=${TC_Param.Bler_KPI_File}
    Step                     Oam.OAM Get Snapshot
    [Teardown]               BEP 853223 End Of TC

TC BEP-853223-DL-UL-Traffic
    [Documentation]          BEP-853223 DL UL Traffic
    [Arguments]              ${TC_Param}
    Init Sequence            ${TC_Param}
    ${syslog}                SYSLOG Start    host=${GNB_DU.sys[0].M}          name=Start_Up
    Step                     Restart TL
    ${syslog_start_up}       SYSLOG STOP                                      syslog=${syslog}
    ${returned_syslog}       BEP 853223 Cell Setup With Syslogs
    ${syslog}                SYSLOG Start    host=${GNB_DU.sys[0].M}          name=UE_Attach
    Critical Step            BEP 853223 UE Calls Steps With SCE Files           ${TC_Param.Step_1_Sce}
    Traced Sleep             duration=3s                                      msg=UE Call Step1 ...
    Critical Step            BEP 853223 UE Calls Steps With SCE Files           ${TC_Param.Step_2_Sce}
    Traced Sleep             duration=3s                                      msg=UE Call Step2 ...
    Critical Step            BEP 853223 UE Calls Steps With SCE Files           ${TC_Param.Step_3_Sce}
    Traced Sleep             duration=3s                                      msg=UE Call Step3 ...
    ${syslog_ue_attach}      SYSLOG STOP                                      syslog=${syslog}
    ${syslog}                SYSLOG Start    host=${GNB_DU.sys[0].M}          name=UE_Traffic_UL
    Critical Step            BEP 853223 UE Calls Steps With SCE Files           ${TC_Param.Step_4_Sce}
    Traced Sleep             duration=3s                                      msg=UE Call Step4 ...    
    Step                     BEP 853223 start TTI Capture                       suffix=UL
    Traced Sleep             duration=2s                                      msg=start UL traffic TTI capture...
    Step                     BEP 853223 stop TTI Capture                        suffix=UL_Traffic
    Traced Sleep             duration=60s                                     msg=stop TTI waiting for 60seconds
    ${syslog_ul_traffic}     SYSLOG STOP                                      syslog=${syslog}
    Step                     BEP 853223 TTI Post Processing Tput Alloc        TTIpcap=${TTIpcap}
    ...                                                                       Expected_Dict_UL_Tput=${TC_Param.Expected_UL_Alloc_Sum}
    ${syslog}                SYSLOG Start    host=${GNB_DU.sys[0].M}          name=UE_Traffic_UL_Long
    Traced Sleep             duration=360s                                    msg=waiting for collecting PM counters file
    ${syslog_long}           SYSLOG STOP                                      syslog=${syslog}
    Step                     BEP 853223 Collect PM Counters File
    Step                     Check Mu Paired UE PRB Counters In Multi Cells        ${TC_Param}[Cell_Index_List]
    Step                     BEP 853223 UL RD Counters Check In Multi Cells        ${TC_Param}[Cell_Index_List]
    Step                     BEP 853223 Check BLER KPIs                       BLER_KPI_Constraints_File=${TC_Param.Bler_KPI_File}
    Step                     Oam.OAM Get Snapshot
    [Teardown]               BEP 853223 End Of TC

BEP 853223 Load BSR file
    [Documentation]         Load BSR file to enable the use of Spatial Managed UE position
    [Arguments]             ${BSR_Dic}

    Dated Log New Line     ===> Download BSR file ${BSR_Dic.BSR_file_name}
    # Dated Log New Line     ===> check F1 is ready before SW update with BSR package
    # F1 Wait Link Classical
    ${admin_conn}        coam.connect to
    ${bsr_exist}=        coam.get bsr files     connection=${admin_conn}
    ${bsr_check_res_len}=    Get Length    ${bsr_exist}[bsrFileInused]
    Dated Log New Line     ===> bsr file check : ${bsr_exist} <=====
    Dated Log New Line     ===> bsr file in use : ${bsr_exist}[bsrFileInused] <=====
    Run Keyword If    ${bsr_check_res_len} == 0
    ...               Download Package Using Git Update OAM
    ...                                 git_path=${BSR_git_path}
    ...                                 git_folder=${BSR_Dic.BSR_folder}
    ...                                 git_file_name=${BSR_Dic.BSR_file_name}
    ...                                 target_dir=${LOG_PATH}/BSR

BEP 853223 UE Calls Steps With SCE Files
    [Arguments]            ${SCE_File_Name}
    ${SCE_FILES_Dir}=    Set Variable       ${LOG_PATH}/SCE_FILES
    ${exist_dir}=    Run Keyword And Return status    Directory Should Exist      ${SCE_FILES_Dir}
    Run Keyword If    ${exist_dir}        Copy Files    ${SCE_File_Name}    ${SCE_FILES_Dir}
    Run Keyword If    not ${exist_dir}    Run Keywords
    ...    Log    ${SCE_FILES_Dir} doesn't exist, create it
    ...    AND    Create Directory     ${SCE_FILES_Dir}
    ...    AND    Copy Files    ${SCE_File_Name}    ${SCE_FILES_Dir}
    kwmkt_run_script_once        ${SCE_File_Name}

BEP 853223 Set Mumimo UEs position
    [Documentation]          In Mumimo testing, test mode 'ul_mimo_srs_beam_pos_nr' in egate is used to position the UE
    ...                      in a Pre-defined Quadrant/sub-Quadrant position relative to the RU geometry
    [Arguments]             ${UElist}

    # # Define UE position profiles
    # wtsemu.ul_mimo_srs_beam_pos_nr    profile_id=1    mode=fixed    init_quad_pos=0    init_sub_quad_pos=0
    # wtsemu.ul_mimo_srs_beam_pos_nr    profile_id=2    mode=fixed    init_quad_pos=1    init_sub_quad_pos=0
    # wtsemu.ul_mimo_srs_beam_pos_nr    profile_id=3    mode=fixed    init_quad_pos=2    init_sub_quad_pos=0
    # wtsemu.ul_mimo_srs_beam_pos_nr    profile_id=4    mode=fixed    init_quad_pos=3    init_sub_quad_pos=0
    #For 7.2e

    wtsemu.ul_sinr_testmode_nr     profile_id=1
    ...                             pusch_tx_power=-394
    ...                             pathloss=28

    Wtsemu.ul_ue_beam_pos_nr  profile_id=1
    ...                              num_beam_paths=2
    ...                              azimuth=-70,-70
    ...                              zenith=-40,-40
    ...                              power=-250,-250

    Wtsemu.ul_ue_beam_pos_nr  profile_id=2
    ...                              num_beam_paths=2
    ...                              azimuth=-53,-53
    ...                              zenith=-30,-30
    ...                              power=-250,-250


    FOR    ${UEitem}    IN     @{UElist}
        #wtsemu.ue_testmode_set_nr    id=${UEitem.ue}
        #...                          testmode=ul_mimo_srs_beam_pos
        #...                          action=activate
        #...                          profile_id=${UEitem.ue_srs_beam_pos_profile}

        wtsemu.ue_testmode_set_nr    id=${UEitem.ue}
        ...                          testmode=ul_sinr
        ...                          action=activate
        ...                          profile_id=1

        wtsemu.ue_testmode_set_nr    id=${UEitem.ue}
        ...                          testmode=ue_ul_beam_position
        ...                          action=activate
        ...                          profile_id=${UEitem.ue_srs_beam_pos_profile}

    END


BEP 853223 Collect PM Counters File
    [Documentation]                 KW to get counters and store in specific directory with day date
    ${date}                         Get Current Date
    ${date_in_dir_name}             Convert Date         ${date}     result_format=%d%m%Y_%H%M
    ${log_path_pm}                  Set Variable         ${LOG_PATH}/PM_${date_in_dir_name}
    Dated Log New Line              ====> The PM counters file collected from gnb will be stored under : ${log_path_pm}
    ${pm_latest}                    Counters.Collect PM files from BTS    ${log_path_pm}
    set Suite Variable              ${LATEST_PM_FILE}       ${pm_latest}
    set Suite Variable              ${log_path_pm}
    Dated Log New Line              ====> PATH of PM Files : ${log_path_pm}
    Dated Log New Line              ====> Latest pm counters file : ${LATEST_PM_FILE}


BEP 853223 Check BLER KPIs
    [Arguments]            ${BLER_KPI_Constraints_File}

    Dated Log New Line     ====> Check BLER KPIs in the last PM file : ${LATEST_PM_FILE}
    # ${PM_lastFile}         Counters.Collect PM files from BTS    ${LOG_PATH}/PM_FILES
    Dated Log New Line     ====> Last PM File : ${LATEST_PM_FILE}
    KPI Evaluate                    pmFile=${LATEST_PM_FILE}
    ...                             constraintsFile=${BLER_KPI_Constraints_File}
    ...                             failOnError=${True}

Check Expected Maximum number of Scheduled Ues UL on Cell
    [Documentation]        M55308C18002
    ...                    M55308C18002   Maximum number of Scheduled (FDM and MU-MIMO) UEs on PDSCH per slot on CELL
    ...                    Check that on Cell x, during the PM reporting periods, the max nb of scheduled UE can reach to
    ...                    the expected value, default is 16 (legacy);
    ...                    with CB013932, with 2 cells 2 cores, 2 cells' traffic, the value is 22;
    ...                    With 1 cell 2 cores, the value is 24
    [Arguments]            ${CELL_ID}=1
    ...                    ${Expected_Max_UE}=22
    Dated Log New Line          ====================================================================================
    Dated Log New Line                PM Counter M55308C18002 analysis in ${log_path_pm}
    Dated Log New Line                Check on Cell : ${CELL_ID}
    Dated Log New Line                Expected Max Nb of UE Scheduled On Cell ${CELL_ID} is : 0 - ${Expected_Max_UE}
    Dated Log New Line          ====================================================================================

    FOR        ${idx}        IN RANGE        1        7
        ${retrieved_counter_value}=     Counters.Retrieve Latest Single Counter Value From Pm File with CellID    pm_path=${LATEST_PM_FILE}
        ...                             counter_name=M55308C18002
        ...                             CellID=${idx}
        Dated Log New Line        In the latest PM file, Cell ${idx} M55308C18002 (max scheduled UE pusch) is : ${retrieved_counter_value}
    END

    Dated Log New Line          =====================================================================================
    Dated Log New Line             Check on cell ${CELL_ID} : at least once, M55308C18002 (max scheduled UE pusch) is as expected value
	...							   (max scheduled UE pusch)

    &{expected_dict}      Create Dictionary     counter=M55308C18002    obj=NRCELL      objId=${CELL_ID}
    ${expected_val}       Set Variable      ${Expected_Max_UE}
    ${comparison}         Set Variable      '=='
    ${foundOrNot}         Counters.Check At Least One Value Is In Criteria From Pm Files For Object With ID     ${log_path_pm}
    ...                   ${expected_val}      ${comparison}      &{expected_dict}
    Should Be True       '${foundOrNot}'=='True'

Check Mu Paired UE PRB Counters
    [Documentation]         M55308C35007-Number of PRBs for 2 UE pair Rx for MU MIMO in UL
    ...                     M55308C35008-Number of PRBs for 3 UE pair Rx for MU MIMO in UL
    ...                     M55308C35009-Number of PRBs for 4 UE pair Rx for MU MIMO in UL
    ...                     The above 3 PM counters of Cell 1 (mu mimo enabled) should be greater than 0
    [Arguments]                ${CELL_ID}=1
    Dated Log New Line          ====================================================================================
    Dated Log New Line              Get  PM Counter M55308C35007, M55308C35008, M55308C35009 values in ${log_path_pm}
    Dated Log New Line          ====================================================================================
    ${Counter_PRB_2_UE_Paired}        Counters.Retrieve Latest Single Counter Value From Pm File with CellID
    ...                               pm_path=${LATEST_PM_FILE}
    ...                               counter_name=M55308C35007
    ...                               CellID=${CELL_ID}
    Dated Log New Line          ==== In the lates PM file, PUSCH PRB with 2 UE Paired (M55308C35007) : ${Counter_PRB_2_UE_Paired}

    ${Counter_PRB_3_UE_Paired}        Counters.Retrieve Latest Single Counter Value From Pm File with CellID
    ...                               pm_path=${LATEST_PM_FILE}
    ...                               counter_name=M55308C35008
    ...                               CellID=${CELL_ID}
    Dated Log New Line          ==== In the lates PM file, PUSCH PRB with 3 UE Paired (M55308C35008) : ${Counter_PRB_3_UE_Paired}

    ${Counter_PRB_4_UE_Paired}        Counters.Retrieve Latest Single Counter Value From Pm File with CellID
    ...                               pm_path=${LATEST_PM_FILE}
    ...                               counter_name=M55308C35009
    ...                               CellID=${CELL_ID}
    Dated Log New Line          ==== In the lates PM file, PUSCH PRB with 4 UE Paired (M55308C35009) : ${Counter_PRB_4_UE_Paired}
    Should Be True              ${Counter_PRB_2_UE_Paired}>0 or ${Counter_PRB_3_UE_Paired}>0 or ${Counter_PRB_4_UE_Paired}>0

Check Mu Paired UE PRB Counters In Multi Cells
    [Documentation]         M55308C35007-Number of PRBs for 2 UE pair Rx for MU MIMO in UL
    ...                     M55308C35008-Number of PRBs for 3 UE pair Rx for MU MIMO in UL
    ...                     M55308C35009-Number of PRBs for 4 UE pair Rx for MU MIMO in UL
    ...                     The above 3 PM counters of Cell 1 (mu mimo enabled) should be greater than 0
    [Arguments]             ${CELL_ID_List}
    ${num_of_cell_to_check}=    Get Length    ${CELL_ID_List}

    Dated Log New Line          ====================================================================================
    Dated Log New Line              Get PM Counter M55308C35007, M55308C35008, M55308C35009 values of cells ${CELL_ID_List} in ${log_path_pm}
    Dated Log New Line          ====================================================================================

    FOR        ${idx}        IN       @{CELL_ID_List}
        ${Counter_PRB_2_UE_Paired}        Counters.Retrieve Latest Single Counter Value From Pm File with CellID
        ...                               pm_path=${LATEST_PM_FILE}
        ...                               counter_name=M55308C35007
        ...                               CellID=${idx}
        Dated Log New Line          ==== In the lates PM file, CELL ${idx} PUSCH PRB with 2 UE Paired (M55308C35007) : ${Counter_PRB_2_UE_Paired}

        ${Counter_PRB_3_UE_Paired}        Counters.Retrieve Latest Single Counter Value From Pm File with CellID
        ...                               pm_path=${LATEST_PM_FILE}
        ...                               counter_name=M55308C35008
        ...                               CellID=${idx}
        Dated Log New Line          ==== In the lates PM file, CELL ${idx} PUSCH PRB with 3 UE Paired (M55308C35008) : ${Counter_PRB_3_UE_Paired}

        ${Counter_PRB_4_UE_Paired}        Counters.Retrieve Latest Single Counter Value From Pm File with CellID
        ...                               pm_path=${LATEST_PM_FILE}
        ...                               counter_name=M55308C35009
        ...                               CellID=${idx}
        Dated Log New Line          ==== In the lates PM file, CELL ${idx} PUSCH PRB with 4 UE Paired (M55308C35009) : ${Counter_PRB_4_UE_Paired}
        Should Be True              ${Counter_PRB_2_UE_Paired}>0 or ${Counter_PRB_3_UE_Paired}>0 or ${Counter_PRB_4_UE_Paired}>0
    END


Check Multiple K2 Mode Counter on Cell
    [Documentation]        M55365C27011
    ...                    When multiple K2 mode is triggered, the counter value should not be 0
    [Arguments]            ${CELL_ID}=1
    Dated Log New Line          ====================================================================================
    Dated Log New Line                PM Counter M55365C27011 analysis in ${log_path_pm}
    Dated Log New Line          ====================================================================================

    FOR        ${idx}        IN RANGE        1        7
        ${retrieved_counter_value}=     Counters.Retrieve Latest Single Counter Value From Pm File with CellID    pm_path=${LATEST_PM_FILE}
        ...                             counter_name=M55365C27011
        ...                             CellID=${idx}
        Dated Log New Line        In the latest PM file, Cell ${idx} M55365C27011 is : ${retrieved_counter_value}
    END

    Dated Log New Line          Check on requested Cell ${CELL_ID} ...
    Dated Log New Line          Expected Number of Radio Frames Scheduled with Multiple K2 mode should be <= 30000
    ${requested_cell_counter_value}=      Counters.Retrieve Latest Single Counter Value From Pm File with CellID    pm_path=${LATEST_PM_FILE}
        ...                             counter_name=M55365C27011
        ...                             CellID=${CELL_ID}
    Should Be True              ${requested_cell_counter_value}>0 and ${requested_cell_counter_value}<=30000



BEP 853223 TTI Post Processing Multi K2
    [Arguments]            ${TTIpcap}
    Dated Log New Line     ====> TTI Conversion ====
    ${TTIjson}    Convert TTI trace from pcap to others    input_file_path=${TTIpcap}
    ${TTIcsv}    decode_tti_traces_json_using_TtitraceReaderEvtDec    jsonPathName=${TTIjson}    num_of_events=50000
    Check Multiple K2 Values in TTI Json    ${TTIjson}
    Check Slot Processing Duration Budget 750ms in TTI    ${TTIjson}

Alloc Tput Check In TTI
    [Documentation]                    Check the Tput Allocation of all cells in TTI traces
    [Arguments]                        ${Dict_Tput_TTI_Check}    ${path_to_json}
    Dated Log New Line         ====> Check Tput Allocation in tti json file : ${path_to_json}
    ${Tput_Alloc_Check_failure}        Check_allocCellThroughput
    ...                                     jsonPathName=${path_to_json}
    ...                                     eventTTI=${Dict_Tput_TTI_Check.eventType}
    ...                                     columnInEvent=${Dict_Tput_TTI_Check.columnName}
    ...                                     min_data_allocation=${Dict_Tput_TTI_Check.minDataAlloc}
    ...                                     maxTputLimit=${Dict_Tput_TTI_Check.maxThroughputL1Pool}
    Dated Log New Line         ===> Tput_Allocation_Check_failure status is: ${Tput_Alloc_Check_failure}
    should not be true      '${Tput_Alloc_Check_failure}' =='1'


BEP 853223 TTI Post Processing Tput
    [Arguments]            ${TTIpcap}
    Dated Log New Line     ====> TTI Conversion ====
    ${TTIjson}    Convert TTI trace from pcap to others    input_file_path=${TTIpcap}
    ${TTIcsv}     decode_tti_traces_json_using_TtitraceReaderEvtDec    jsonPathName=${TTIjson}    num_of_events=50000
    Dated Log New Line     ====> BEP 853223 UL tput allocation min cell & max tput L1pool check : ====
    Alloc Tput Check In TTI         ${Dict_UL_Tput_TTI_Check}        ${TTIjson}

BEP 853223 TTI Post Processing Tput Alloc
    [Arguments]            ${TTIpcap}     ${Expected_Dict_UL_Tput}
    Dated Log New Line     ====> TTI Conversion ====
    ${TTIjson}    Convert TTI trace from pcap to others    input_file_path=${TTIpcap}
    ${TTIcsv}     decode_tti_traces_json_using_TtitraceReaderEvtDec    jsonPathName=${TTIjson}    num_of_events=50000
    Dated Log New Line     ====> BEP 853223 UL tput allocation min cell & max tput L1pool check : ====
    Alloc Tput Check In TTI         ${Expected_Dict_UL_Tput}        ${TTIjson}


Check Multiple K2 Values in TTI Json
    [Documentation]        Check the Multiple K2 values (4,3,2) in TTI traces
    [Arguments]            ${tti_json}
    Dated Log New Line     ====> check multiple K2 values in TTI Json file ====
    ${check_failure}=    Check_Multiple_K2_Values
    ...                    jsonPathName=${tti_json}
    Dated Log New Line     ===> Multiple K2 check failure status : ${check_failure} ====
    should not be true        '${check_failure}' == '1'


Check Slot Processing Duration Budget 750ms in TTI
    [Arguments]    ${tti_json}
    Dated Log New Line     ====> check slot processing duration value in TTI ====
    ${check_failure}=    Check_Slot_Processing_Duration_Budget
    ...                    jsonPathName=${tti_json}
    ...                    expectedBudget=750
    Dated Log New Line         ===> Slot Processing Duration Budget 750ms check failure status : ${check_failure} ====
    should not be true        '${check_failure}' == '1'

BEP 853223 UL RD Counters Check
    Dated Log New Line     ====> Collect & Verify RD counters
    ${RD_Counters_Log_Path}      Set Variable         ${LOG_PATH}/RD_Counters_Files
    Dated Log New Line     ====> The RD counters file collected from gnb will be stored under : ${RD_Counters_Log_Path}
    ${RD_Counters_Files}=   Collect RD Counters
    ${NRCELL_ID_1}          Set Variable    1
    ${Check_Result_1}       Verify RD Counters With Criteria
    ...                     ${RD_Counters_Files}
    ...                     ${Expected_UL_BLOCK_UE_RD_Counters}
    ...                     ${NRCELL_ID_1}
    ...                     '>='
    ${Check_Result_2}       Verify RD Counters With Criteria
    ...                     ${RD_Counters_Files}
    ...                     ${Expected_UL_SHAVING_PRB_RD_Counters}
    ...                     ${NRCELL_ID_1}
    ...                     '>'

BEP 853223 UL RD Counters Check In Multi Cells
    [Arguments]             ${CELL_ID_List}
    ${num_of_cell_to_check}=    Get Length    ${CELL_ID_List}

    Dated Log New Line     ====> Collect & Verify RD counters
    ${RD_Counters_Log_Path}      Set Variable         ${LOG_PATH}/RD_Counters_Files
    Dated Log New Line     ====> The RD counters file collected from gnb will be stored under : ${RD_Counters_Log_Path}
    ${RD_Counters_Files}=   Collect RD Counters

    FOR    ${idx}    IN       @{CELL_ID_List}
        ${Check_Result_1}       Verify RD Counters With Criteria
        ...                     ${RD_Counters_Files}
        ...                     ${Expected_UL_BLOCK_UE_RD_Counters}
        ...                     ${idx}
        ...                     '>='
        ${Check_Result_2}       Verify RD Counters With Criteria
        ...                     ${RD_Counters_Files}
        ...                     ${Expected_UL_SHAVING_PRB_RD_Counters}
        ...                     ${idx}
        ...                     '>'
    END