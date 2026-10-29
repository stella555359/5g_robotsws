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
...               0.3       FB2603    philippe.daroux@nokia.com              Adding steps to check Counter and TTI status when:
...                                                                          Fallback is off
...                                                                          Fallback is on and 2 cells 2 Cores
...                                                                          Fallback is on and 1 cells 2 Cores

Resource          ./CB013932-Common-Keywords.robot
Resource          ../../../resources/common/TtiTrace/ttitrace.robot
Resource          ../../../../../resources/SWENG/robot/Setup.robot
Resource          ../../../resources/DSS/robot/aashell.robot
Resource          ../../../resources/robot/KeyWordMarket.robot
# Resource          ../../../resources/SWENG/robot/Oam.robot
Resource          ../../../../../resources/SWENG/robot/RdCounters.robot
Resource          ../../../../../resources/SWENG/robot/TtiConvertInterface.robot
Library           ../python/CB013932_checkTTItrace.py
Library           OperatingSystem
Library           taf.sbts.oam.coam.admin        WITH NAME        coam



*** Variables ***

${blockResult}      Blocked

# BSR custom beamset package for AEQE Beamset_6
${BSR_git_path}         gitlabe1.ext.net.nokia.com/nps_vrf_8_and_9/bsr.git

#allowFallbackFromSRSToSSBBeam default value
${fallbackvalue}        False

#  Nb of Unlocked cells
${CellsUnLocked}          6

# Variables for TTI check
# RAT1 check in TTI traces
&{Dict_IWK_8927_RAT1_Check}          eventType=dlFdSchedData
...                                  columnName=rat0Bitmap

#CB013932 DL RD Counters
&{TC_C1_Expected_DL_BLOCK_UE_RD_Counters}         BLOCKED_PDSCH_UE_COUNT=0
&{TC_C1_Expected_DL_SHAVING_PRB_RD_Counters}      REDUCED_PDSCH_SUBCELL_PRB_COUNT=0


*** Keywords ***



TC CB013932-DL-UL-Traffic
    [Documentation]          CB013932 DL UL Traffic
    [Arguments]              ${TC_Param}
    Init Sequence            ${TC_Param}
    set Suite Variable       ${TC_Param}
    Step                     Restart TL
    ${returned_syslog}       CB013932 Cell Setup With Syslogs
    Critical Step            CB013932 UE Calls Steps With SCE Files           ${TC_Param.Step_1_Sce}
    Traced Sleep             duration=3s                                      msg=UE Call Step1 ...
    Critical Step            CB013932 UE Calls Steps With SCE Files           ${TC_Param.Step_2_Sce}
    Traced Sleep             duration=3s                                      msg=UE Call Step2 ...
    Critical Step            CB013932 UE Calls Steps With SCE Files           ${TC_Param.Step_3_Sce}
    Traced Sleep             duration=3s                                      msg=UE Call Step3 ...
    Critical Step            CB013932 UE Calls Steps With SCE Files           ${TC_Param.Step_4_Sce}
    Traced Sleep             duration=3s                                      msg=UE Call Step4 ...
    Step                     CB013932 start TTI Capture                       suffix=DL_UL
    Traced Sleep             duration=2s                                      msg=start DL UL traffic TTI capture...
    Step                     CB013932 stop TTI Capture                        suffix=DL_UL_Traffic
    Traced Sleep             duration=60s                                     msg=stop TTI waiting for 60seconds
    Step                     CB013932 TTI Post Processing                     TTIpcap=${TTIpcap}
    Traced Sleep             duration=360s                                    msg=waiting for collecting PM counters file
    Step                     CB013932 Collect PM Counters File
    Step                     Check Expected Maximum number of Scheduled Ues UL on Cell        CELL_ID=${TC_Param.First_Cell_Idx}
    Step                     Check Multiple K2 Mode Counter on Cell                           CELL_ID=${TC_Param.First_Cell_Idx}
   # Step                     CB013932 Check BLER KPIs                         BLER_KPI_Constraints_File=${TC_Param.Bler_KPI_File}
    Critical Step            Set allowFallbackFromSRSToSSBBeam
    Traced Sleep             duration=360s                                    msg=collecting PM counters file after fallback changing
    Dated Log New Line       ====> parameter allowFallbackFromSRSToSSBBeam changed to true on Cell1
    Step                     CB013932 Collect PM Counters File
    Step                     Check Expected Maximum number of Scheduled Ues UL on Cell        CELL_ID=${TC_Param.First_Cell_Idx}
    Step                     CB013932 start TTI Capture                       suffix=DL_UL
    Traced Sleep             duration=2s                                      msg=start DL UL traffic TTI capture...
    Step                     CB013932 stop TTI Capture                        suffix=DL_UL_Traffic
    Traced Sleep             duration=60s                                     msg=stop TTI waiting for 60seconds
    Step                     CB013932 TTI Post Processing                     TTIpcap=${TTIpcap}
    Step                     Locking Cell
    Dated Log New Line       ====> Cell locked
    Traced Sleep             duration=360s                                    msg=collecting PM counters file after locking cell 4
    Step                     CB013932 Collect PM Counters File
    Step                     Check Expected Maximum number of Scheduled Ues UL on Cell        CELL_ID=${TC_Param.First_Cell_Idx}
    Step                     CB013932 start TTI Capture                       suffix=DL_UL
    Traced Sleep             duration=2s                                      msg=start DL UL traffic TTI capture...
    Step                     CB013932 stop TTI Capture                        suffix=DL_UL_Traffic
    Traced Sleep             duration=60s                                     msg=stop TTI waiting for 60seconds
    Step                     CB013932 TTI Post Processing                     TTIpcap=${TTIpcap}
    Critical Step            Set allowFallbackFromSRSToSSBBeam    false
    Traced Sleep             duration=360s                                    msg=collecting PM counters file after fallback changing
    Dated Log New Line       ====> parameter allowFallbackFromSRSToSSBBeam changed to false on Cell1
    Step                     CB013932 Collect PM Counters File
    Step                     Check Expected Maximum number of Scheduled Ues UL on Cell        CELL_ID=${TC_Param.First_Cell_Idx}
    Step                     Oam.OAM Get Snapshot
    [Teardown]               CB013932 End Of TC


CB013932 Load BSR file
    [Documentation]         Load BSR file to enable the use of Spatial Managed UE position
    [Arguments]             ${BSR_Dic}

    Dated Log New Line     ===> Download BSR file ${BSR_Dic.BSR_file_name}
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


CB013932 UE Calls Steps With SCE Files
    [Arguments]            ${SCE_File_Name}
    ${SCE_FILES_Dir}=    Set Variable       ${LOG_PATH}/SCE_FILES
    ${exist_dir}=    Run Keyword And Return status    Directory Should Exist      ${SCE_FILES_Dir}
    Run Keyword If    ${exist_dir}        Copy Files    ${SCE_File_Name}    ${SCE_FILES_Dir}
    Run Keyword If    not ${exist_dir}    Run Keywords
    ...    Log    ${SCE_FILES_Dir} doesn't exist, create it
    ...    AND    Create Directory     ${SCE_FILES_Dir}
    ...    AND    Copy Files    ${SCE_File_Name}    ${SCE_FILES_Dir}
    kwmkt_run_script_once        ${SCE_File_Name}

CB013932 Set Mumimo UEs position
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


CB013932 Collect PM Counters File
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


CB013932 Check BLER KPIs
    [Arguments]            ${BLER_KPI_Constraints_File}

    Dated Log New Line     ====> Check BLER KPIs in the last PM file : ${LATEST_PM_FILE}
    # ${PM_lastFile}         Counters.Collect PM files from BTS    ${LOG_PATH}/PM_FILES
    Dated Log New Line     ====> Last PM File : ${LATEST_PM_FILE}
    KPI Evaluate                    pmFile=${LATEST_PM_FILE}
    ...                             constraintsFile=${BLER_KPI_Constraints_File}
    ...                             failOnError=${True}

Check Expected Maximum number of Scheduled Ues UL on Cell
    [Documentation]        M55308C18002
    ...                    M55308C18002   Maximum number of Scheduled (FDM and MU-MIMO) UEs on PUSCH per slot on CELL
    ...                    Check that on Cell x, during the PM reporting periods, the max nb of scheduled UE can reach to
    ...                    the expected value, default is 16;
    ...                    with CB013932 and allowFallbackFromSRSToSSBBeam set to true:
    ...                    with 2 cells 2 cores, the value is 23; With 1 cell 2 cores, the value is 24
    [Arguments]            ${CELL_ID}=1
    ...                    ${Expected_Max_UE_1}=16     ${Expected_Max_UE_2}=23      ${Expected_Max_UE_3}=24
    Dated Log New Line          ====================================================================================
    Dated Log New Line                PM Counter M55308C18002 analysis in ${log_path_pm}
    Dated Log New Line                Check on Cell : ${CELL_ID}
   # Dated Log New Line                Expected Max Nb of UE Scheduled On Cell ${CELL_ID} is : 0 - ${Expected_Max_UE}
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
    ${expected_val_1}       Set Variable      ${Expected_Max_UE_1}
    ${expected_val_2}       Set Variable      ${Expected_Max_UE_2}
    ${expected_val_3}       Set Variable      ${Expected_Max_UE_3}
    ${comparison}           Set Variable      '=='

    IF    "${fallbackvalue}" == "False"
        ${expected_val}=    Set Variable    ${Expected_Max_UE_1}
        Dated Log New Line    Expected value (fallback=False): ${expected_val}
   # ELSE IF    "${CellsUnLocked}" == "2" or "${CellsUnLocked}" == "3" or "${CellsUnLocked}" == "5"
    ELSE IF    "${CellsUnLocked}" in ["2", "3", "5"]
        ${expected_val}=    Set Variable    ${Expected_Max_UE_3}
        Dated Log New Line    Expected value (fallback=True, CellsUnLocked=${CellsUnLocked}): ${expected_val}
    ELSE
        ${expected_val}=    Set Variable    ${Expected_Max_UE_2}
        Dated Log New Line    Expected value (fallback=True, CellsUnLocked=${CellsUnLocked}): ${expected_val}
    END

    ${foundOrNot}=    Counters.Check At Least One Value Is In Criteria From Pm Files For Object With ID
    ...    ${log_path_pm}    ${expected_val}    ${comparison}    &{expected_dict}

    Should Be True    '${foundOrNot}'=='True'
    ...    msg=Counter M55308C18002 did not reach expected value ${expected_val} on Cell ${CELL_ID}


Check Multiple K2 Mode Counter on Cell
    [Documentation]        M55365C27011
    ...                    When multiple K2 mode is triggered, the counter value should not be 0
    [Arguments]            ${CELL_ID}=1
    Dated Log New Line          ====================================================================================
    Dated Log New Line                PM Counter M55365C27011 analysis in ${log_path_pm}
    Dated Log New Line          ====================================================================================

    FOR        ${idx}        IN RANGE        1        7
        ${retrieved_counter_value}=     Counters.Retrieve Latest Single Counter Value From Pm File with CellID
    ...                                 pm_path=${LATEST_PM_FILE}
    ...                                 counter_name=M55365C27011
    ...                                 CellID=${idx}
        Dated Log New Line        In the latest PM file, Cell ${idx} M55365C27011 is : ${retrieved_counter_value}
    END

    Dated Log New Line          Check on requested Cell ${CELL_ID} ...
    Dated Log New Line          Expected Number of Radio Frames Scheduled with Multiple K2 mode should be <= 30000
    ${requested_cell_counter_value}=      Counters.Retrieve Latest Single Counter Value From Pm File with CellID
    ...                                   pm_path=${LATEST_PM_FILE}
    ...                                   counter_name=M55365C27011
    ...                                   CellID=${CELL_ID}
    Should Be True              ${requested_cell_counter_value}>0 and ${requested_cell_counter_value}<=30000


CB013932 TTI Post Processing
    [Arguments]            ${TTIpcap}
    Dated Log New Line     ====> TTI Conversion ====
    ${TTIjson}    Convert TTI trace from pcap to others    input_file_path=${TTIpcap}
    ${TTIcsv}    decode_tti_traces_json_using_TtitraceReaderEvtDec    jsonPathName=${TTIjson}    num_of_events=50000
    Check Multiple K2 Values in TTI Json    ${TTIjson}
    Check Slot Processing Duration Budget 750ms in TTI    ${TTIjson}

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

Set allowFallbackFromSRSToSSBBeam
    [Arguments]    ${value}=true
    &{modify_param1}    Create Dictionary
    ...    parameter=allowFallbackFromSRSToSSBBeam
    ...    dist_name=MRBTS-1/NRBTS-1/NRCELL-1
   # ...    dist_name=${dist_name}
   # ...    value=true
    ...     value=${value}
    @{modify_param}    Create List    ${modify_param1}
    Oam.OAM Set Params                ${modify_param}
    Dated Log New Line              ====> allowFallbackFromSRSToSSBBeam flag is : ${modify_param}
    ${new_fallback_value}=          Get From Dictionary    ${modify_param1}    value
    Set Suite Variable              ${fallbackvalue}    ${new_fallback_value}  # Update the suite variable
    Dated Log New Line              ====> The value of allowFallbackFromSRSToSSBBeam is: ${fallbackvalue}



Locking Cell
  #  [Documentation]    Lock appropriate cell based on number of cells configuration
  #  ${cellsNr}=    Get Number of Cells

 #   IF    "${cellsNr}" == "4"
 #       ${cell_to_lock}=    Set Variable    3
 #   ELSE IF    "${cellsNr}" == "6"
 #       ${cell_to_lock}=    Set Variable    4
 #   ELSE
 #       Log    No cell locking required
 #       RETURN
 #   END
 #   Oam.OAM Cell Lock    cell_id=${cell_to_lock}
 #   Traced Sleep    duration=120s    msg=wait for new cell status
 #   ${NbOfLockedCells}    ${NbOfUnlockedCells}=    Oam.OAM Number of Blocked Unblocked Cells
 #   Dated Log    After lock - Locked: ${NbOfLockedCells}, Unlocked: ${NbOfUnlockedCells}
 #   Set Suite Variable    ${CellsUnLocked}    ${NbOfUnlockedCells}
 #   Dated Log New Line    ===> Number of Cell unlocked: ${CellsUnLocked}



    [Documentation]    Lock appropriate cell based on number of cells configuration
    ${cellsNr}=    Get Number of Cells

    IF    "${cellsNr}" == "4"
        @{cells_to_lock}=    Create List    2    3
    ELSE IF    "${cellsNr}" == "6"
        @{cells_to_lock}=    Create List    4
    ELSE
        Log    No cell locking required
        RETURN
    END
    
    # Lock each cell in the list
    FOR    ${cell_id}    IN    @{cells_to_lock}
        Oam.OAM Cell Lock    cell_id=${cell_id}
    END
    
    Traced Sleep    duration=120s    msg=wait for new cell status
    ${NbOfLockedCells}    ${NbOfUnlockedCells}=    Oam.OAM Number of Blocked Unblocked Cells
    Dated Log    After lock - Locked: ${NbOfLockedCells}, Unlocked: ${NbOfUnlockedCells}
    Set Suite Variable    ${CellsUnLocked}    ${NbOfUnlockedCells}
    Dated Log New Line    ===> Number of Cell unlocked: ${CellsUnLocked}