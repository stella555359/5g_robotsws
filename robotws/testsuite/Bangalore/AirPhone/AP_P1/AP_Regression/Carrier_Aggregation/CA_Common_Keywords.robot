*** Settings ***
Documentation    This resource file contains common keywords to CA feature

Library         OperatingSystem
Library         String
Library         ../../Resources/Python/measurement_id.py    WITH NAME    measurement_id
Library         taf.config.wts    WITH NAME    wts_conf
Library         ../../Resources/Python/DeltaStore.py    WITH NAME    delta_store
Library         ../../Resources/Python/AdminHelper.py    WITH NAME    admin_helper

Resource        ../../Resources/robot/gnb.robot
Resource        ../../Resources/robot/ute_setup.robot
Resource        ../../Resources/robot/wts.robot
Resource        ../../Resources/robot/log.robot
Resource        ../../Resources/Variables/Common_Variables.robot
Resource        ../../Resources/robot/suite_common_keywords.robot
Resource        ../../Resources/robot/ue_operations.robot


*** Variables ***
&{mimode_params}              dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
&{InterRAT_params}            actInterRatHoFromEutraToSA=true    actInterRatHoSA=true    actInterRatHoSADlDataForward=true
&{ANR_InterRAT_params}        actSaUeBasedAnrEutra=true    actInterRatHoSA=true    maxNumNrAnrMoiAllowed=20000
@{SA_Scell_Index}                0    1
@{NSA_Scell_Index}               8    9
@{4CC_scell_index}               1     2    3
${4CC_scell_index_1}             0,1,2,3
${4CC_scell_index_2}             1,2,3
@{scell_index}                   9
@{4CC_NSA_cell_Index}           8    9    10    11
@{4CC_NSA_Scell_Index}         9    10    11
${closed_loop}                 False

*** Keywords ***
Suite Setup
    [Arguments]     ${feature_folder}     ${topology}=CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
    Suite Common Keywords    feature_folder=${feature_folder}
    Copy and Trigger Mirroring Script    topology=${topology}
    ute_setup.Modify UTE SCTP Timeout    ${AP_IP}    ${AP_Username}    ${NOKIA_PASS}    AP_Update_Flag=False

Suite Teardown
    Common Suite Teardown Keywords

Test Setup
    [Arguments]    ${handover}=False    ${4CC}=False    ${cell_deployment}=${EMPTY}    ${Gnb_Commissioning}=True
    ...    ${4CC_DL_2CC_UL}=False    &{kwargs}
    Common Test setup    ${handover}    ${4CC}    ${cell_deployment}    ${Gnb_Commissioning}    ${4CC_DL_2CC_UL}
    ...     &{kwargs}
    Ensure NG Link is Up
    Wait Until Keyword Succeeds    5 min    15sec
    ...    Ensure Address Distribution Is Successful
    Wait Until Keyword Succeeds    5 min    15sec
    ...    Ensure UE SIB Decoding Is Successful
    run keyword if    '${cell_deployment}' != 'SA'    Establish X2 link    enb_id=1    gnb_id=2
    Wait Until Keyword Succeeds    5 min    15sec
    ...    Check if cell setup completed
    Run Keyword And Ignore Error    Check pcap files in gNB
    Enable rrc traces in WTS
    Start AP TTI Traces    AP
    Start gNB TTI Traces
    Start WTS tcpdump for UDP traffic

Test Setup for cell deployment NSA
    [Arguments]    ${handover}=False    &{kwargs}
    Log    ${handover}
    Common Test setup    cell_deployment=NSA    &{kwargs}
    Establish X2 link    enb_id=1    gnb_id=2
    Wait Until Keyword Succeeds    5 min    15sec
    ...    Ensure Address Distribution Is Successful
    Wait Until Keyword Succeeds    5 min    15sec
    ...    Ensure UE SIB Decoding Is Successful    cells=${No_of_cells_Sib_decoding_cell_dep_NSA}
    Wait Until Keyword Succeeds    5 min    15sec
    ...    Check if cell setup completed
    Run Keyword And Ignore Error    Check pcap files in gNB
    Enable rrc traces in WTS
    Start AP TTI Traces    AP
    Start gNB TTI Traces
    Start WTS tcpdump for UDP traffic

Common Test setup
    [Arguments]    ${handover}=False    ${4CC}=False    ${cell_deployment}=${EMPTY}    ${Gnb_Commissioning}=True
    ...     ${4CC_DL_2CC_UL}=False    ${custom_config}=False    ${custom_config_folder}=${EMPTY}    &{kwargs}
    Create Test Case Folder
    ${testlog_path}    log_store.get test log folder
    Set Suite Variable    ${testlog_path}
    set test variable    ${cell_deployment}
    Set variables for TC    &{kwargs}
    Run Keyword If    'AP_LO' in '${TOPOLOGY}'    Set variables for APoABIO    &{kwargs}
    Run Keyword If    'AP_LO' in '${TOPOLOGY}'    Configure LOKI interfaces
    ...   ELSE    Configure VM interfaces for handover
    Copy custom config files
    Run keyword If    '${cell_deployment}' == 'SANSA' or '${cell_deployment}' == 'SA'
    ...    Update Gnb for different cell deployment    ${cell_deployment}    &{kwargs}
    ...    ELSE IF    '${cell_deployment}' == 'NSA'    Update Gnb for cell deployment NSA    &{kwargs}
    Run Keyword If    '${4CC}' == 'True' and '${Gnb_Commissioning}' == 'True'    Update Gnb for 4CC    &{kwargs}
    Run Keyword If     ${4CC_DL_2CC_UL}    Update Gnb for 4CC_DL_2CC_UL    &{kwargs}
    Run Keyword If    "${custom_config}" == "True"    Bring Up TL with Custom Configuration    custom_config_folder=${custom_config_folder}
    ...    update_required=True    output_dir=${OUTPUT_DIR}
    IF    'bsr_file_name' in ${kwargs}
        Get and Update BSR Package    bsr_file_name=${bsr_file_name}    bsr_path=${bsr_path}
    END
    Run Keyword If    not ${custom_config}    Reboot GNB irrespective of state
    Wait for gNB To Be Ready
    Run Keyword And Ignore Error    Get disk space and tmp content
    Start pcap collection in gNB and WTS    options=-i any -s0 -z gzip
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True' and '${handover}' == 'False' and 'AP_LO' not in '${TOPOLOGY}'
    ...    Run Keyword And Ignore Error    Start L1L2biplogs    PCAP_PREFIX=TC${TC_index}_Setup
    Collect logs for debug
    Start and configure WTS    wts_cfg_path=/opt/wts/latest/${WTS_FILE}
    ${fault_dict_before_test}=    Run keyword And Continue On Failure    Get Alarms
    Set Test Variable    ${fault_dict_before_test}

Test Teardown
    [Arguments]    ${sa_nonca_ue_list}=${EMPTY}    ${sa_ue_list}=${EMPTY}    ${nsa_ue_list}=${EMPTY}    ${handover}=False
    ...    ${4CC}=False
    Run Keyword If    '${BIP_CAPTURE_NEEDED}' == 'True' and '${handover}' == 'False'
    ...    Run Keyword And Ignore Error    Stop L1L2bipLogs
    Run Keyword If    '${TEST_STATUS}' == 'FAIL'
    ...    Test Env Cleanup On Failure    ${sa_nonca_ue_list}    ${sa_ue_list}   ${nsa_ue_list}    ${4CC}
    Common Test Teardown
    Increment TC Index

Test Env Cleanup On Failure
    [Arguments]    ${sa_nonca_ue_list}    ${sa_ue_list}    ${nsa_ue_list}=${EMPTY}    ${4CC}=False
    Log    ${4CC}
    Log To Console    On Failure: Sleeping for 5min before collecting PM Counters..
    Sleep    300s
    Run Keyword and Ignore Error    Collect Gnb PM Counters    target_dir=${testlog_path}    name=gnb_pm_counters
    Run Keyword If    "${sa_nonca_ue_list}" != "${EMPTY}"    Run Keyword and Ignore Error    Stop Traffic and Detach SA UEs    ${sa_nonca_ue_list}
    Run Keyword and Ignore Error
    ...    Stop Traffic and Detach SA UEs    ${sa_ue_list}
    Run Keyword If    "${nsa_ue_list}" != "${EMPTY}"    Run Keyword and Ignore Error    Stop Traffic and Detach NSA UEs    ${nsa_ue_list}

Cell Specific Throughput Validation
    [Arguments]    ${ue_id}    ${scell}    ${type}=pdsch
    Capture UE Stats    ue_id=${ue_id}    type=${type}    scell=primary,secondary
    ${pcell_output}    Capture UE Stats    ue_id=${ue_id}    scell=${scell}    type=${type}
    sleep    2s
    ${tput_average}    Get Regexp Matches    ${pcell_output}    ${SPACE}*(\\d+\.\\d+)${SPACE}*Mbps${SPACE}*    1
    ${tput_average}    Evaluate    ${tput_average}[-1]
    Log To Console    Cell ${scell} Tput : ${tput_average}
    [Return]    ${tput_average}

Total CA UE Throughput Verification
    [Arguments]    ${cell_total}    ${bearer_stats_tput}    ${expected_tput}
    ${result_cell}    Evaluate    int(${expected_tput} * 1.2) >= int(${cell_total}) >= int(${expected_tput} * 0.9)
    ${result_stats}    Evaluate    int((${expected_tput}* 1000000) * 1.2) >= int(${bearer_stats_tput}[0]) >= int((${expected_tput}* 1000000) * 0.9)
    Run Keyword If    not (${result_cell} and ${result_stats})    FAIL
    ...    msg = Total TPut is not as expected. cell: ${result_cell} and stats :${result_stats}

Validate Scell Regsitration
    [Documentation]    check_for_scell_registreation after ue register
    Log To Console    Validating Scell Registration...
    Run and return rc    grep -i "sCellToAddModList" /opt/wts/latest/egate_console.log

Validate Scell Addition
    [Documentation]    Check For Scell Addition After Ue Register
    [Arguments]    ${scell_index}
    Log To Console    Validating Scell Addition...
    Run and return rc    grep "sCellIndex ${scell_index}" /opt/wts/latest/egate_console.log

Validate Scell Release
    [Documentation]    Check For Scell Release After Stopping the Traffic
    [Arguments]    ${scell_index}
    Log    ${scell_index}
    Log To Console    Validating Scell Release...
    Run and return rc    grep "sCellToReleaseList" /opt/wts/latest/egate_console.log

Test Setup for handover scenario
    [Arguments]    ${Handover_Feature}=${EMPTY}    ${simulator_gnb_list}=${Sim_Gnb_list_HO}    ${NGBased_HO}=False
    ...     ${interrat_ho}=False    ${ANR_IR}=False    ${4CC}=False    &{kwargs}
    Common Test setup for handover    Handover_Feature=${Handover_Feature}    4CC=${4CC}    interrat_ho=${interrat_ho}
    ...     ANR_IR=${ANR_IR}    NGBased_HO=${NGBased_HO}    &{kwargs}
    Wait Until Keyword Succeeds    5 min    15sec
    ...    Ensure UE SIB Decoding Is Successful
    run Keyword if    "${Handover_Feature}" != "5GC002329"
    ...    Establish X2 link for simulator Gnb    enb_id=1    simulator_gnb_list=${simulator_gnb_list}
    Ensure cell setup completed    AP_IP=${AP_IP}
    Run Keyword And Ignore Error    Check pcap files in gNB
    Enable rrc traces in WTS
    Start AP TTI Traces    AP
    Start gNB TTI Traces
    Start WTS tcpdump for UDP traffic

Test Setup for 4CC_DL_2CC_UL handover scenario
    [Arguments]    ${Handover_Feature}=${EMPTY}    ${simulator_gnb_list}=${Sim_Gnb_list_HO}    ${NGBased_HO}=False
    ...     ${interrat_ho}=False    ${ANR_IR}=False    ${4CC}=False    ${wts_changes}=False    &{kwargs}
    Common Test setup for handover    Handover_Feature=${Handover_Feature}    4CC=${4CC}    interrat_ho=${interrat_ho}
    ...     ANR_IR=${ANR_IR}    NGBased_HO=${NGBased_HO}    wts_changes=${wts_changes}    &{kwargs}
    ${list_of_cells}    Get From Dictionary    ${kwargs}    logical_cell_list
    Wait Until Keyword Succeeds    5 min    15sec
    ...    Ensure UE SIB Decoding Is Successful for cell list    list_of_cells=${list_of_cells}
    Wait Until Keyword Succeeds    5 min    15sec
    ...    Check if cell setup completed for cell list    AP_IP=${AP_IP}    list_of_cells=${list_of_cells}
    Establish X2 link for simulator Gnb    enb_id=1    simulator_gnb_list=${simulator_gnb_list}
    Run Keyword And Ignore Error    Check pcap files in gNB
    Enable rrc traces in WTS
    Start AP TTI Traces    AP
    Start gNB TTI Traces
    Start WTS tcpdump for UDP traffic

Common Test setup for handover
    [Arguments]    ${Handover_Feature}=${EMPTY}    ${NGBased_HO}=False    ${interrat_ho}=False
    ...     ${ANR_IR}=False    ${4CC}=False    ${wts_changes}=False    &{kwargs}
    Log    ${4CC}
    Create Test Case Folder
    ${testlog_path}    log_store.get test log folder
    Set Suite Variable    ${testlog_path}
    Set variables for TC    &{kwargs}
    run keyword if    ${interrat_ho}    Configure Inter RAT handover interfaces
    ...    ELSE     Configure VM interfaces for handover
    Run Keyword If    'AP_LO' in '${TOPOLOGY}'    Configure LOKI interfaces
    Copy custom config files
    run Keyword if    ${closed_loop}    Update Gnb with closed loop dl mimomode for ${Handover_Feature}
    run Keyword if    ${NGBased_HO}    Update WTS config file for ${Handover_Feature}
    run Keyword if    ${NGBased_HO}    Update Gnb with NGBasedHO configuration for ${Handover_Feature}
    run Keyword if    '${interrat_ho}' == 'True' or '${wts_changes}' == 'True'
    ...    Update WTS config file for InterRAT handover ${Handover_Feature}
    run Keyword if    ${interrat_ho}   Update Gnb with InterRAT configuration for ${Handover_Feature}
    run Keyword if    ${ANR_IR}        Update WTS config file for ANR InterRAT handover ${Handover_Feature}
    run Keyword if    ${ANR_IR}        Update Gnb with ANR InterRAT configuration for ${Handover_Feature}
    Reboot gNB irrespective of state
    Wait for gNB To Be Ready
    Run Keyword And Ignore Error    Get disk space and tmp content
    Start pcap collection in gNB and WTS    options=-i any -s0 -z gzip
    Collect logs for debug
    Start and configure WTS    wts_cfg_path=/opt/wts/latest/${WTS_FILE}
    ${fault_dict_before_test}=    Run keyword And Continue On Failure    Get Alarms
    Set Test Variable    ${fault_dict_before_test}
    Ensure NG Link is Up
    Wait Until Keyword Succeeds    5 min    15sec
    ...    Ensure Address Distribution Is Successful

Check if NRADJCELL and NRRELE object is created after Forward HO
    [Arguments]    ${feature_id}=${EMPTY}
    sleep    60s    reason=waiting for gNB to create the profiles
    ${scf_path}    Download SCF file    local_dir_path=${testlog_path}    file_name=SCF_After_HO.xml
    scf_helper.check_if_object_is_present_in_scf    scf_path=${scf_path}   distname=${NRBTS_DISTNAME}/NRADJECELL-5000
    Run Keyword if    '${feature_id}' == '5GC002329'
    ...    scf_helper.check_if_object_is_present_in_scf    scf_path=${scf_path}   distname=${NRBTS_DISTNAME}/NRCELL-1/NRRELE-256
    ...    ELSE    scf_helper.check_if_object_is_present_in_scf    scf_path=${scf_path}   distname=${NRBTS_DISTNAME}/NRCELL-2/NRRELE-256

Delete anr profile if present
    [Arguments]    ${feature_id}=${EMPTY}
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/NRADJECELL-5000
    Run Keyword if    '${feature_id}' == '5GC002329'
    ...    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/NRCELL-1/NRRELE-256
    ...    ELSE    delta_store.delete_managed_object_from_delta    dist_name=${NRBTS_DISTNAME}/NRCELL-2/NRRELE-256
    ${delta_store}    Collect Delta Store
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}
    Wait for gNB To Be Ready

Perform SA UE Register and start traffic for Blind ScellAddition and Blind ScellActivation
    [Arguments]    ${sa_ue_list}    ${uplink_tput}=${ul_tput}    ${scell_index_list}=${4CC_scell_index}    ${4CC}=False
    ...    ${dl_tput_list}=${dl_tput_list}
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Ensure UE Register Is Successful    ue_id=${ue_id}
        Ensure Set PDU Param Is Successful    ue_id=${ue_id}    pdu_id=3    trf_type=internal
        run keyword if   ${4CC}    Ensure UE PDU Session Setup Is Successful    ue_id=${ue_id}    pdu_id=3    gw_id=1    nwslice=1
        ...    ELSE    Ensure UE PDU Session Setup Is Successful    ue_id=${ue_id}    pdu_id=3    gw_id=${ue_id}
        ...    pass_regexp=SCellIndex 1 activated successfully    nwslice=1
        run keyword if   ${4CC}    Verify scell addition for each scell index    ${scell_index_list}
        run keyword if   ${4CC}    Wait Until Keyword Succeeds    1 min    30sec
        ...   Verify scell activation for each scell index    ${ue_id}    ${scell_index_list}
        Log To Console    Going To Start Traffic for SA UE: ${ue_id}
        Start Traffic    ue_id=${ue_id}    dir=ul    pdu=3    mbps=${uplink_tput}
        Start Traffic without Validation of Scell Activation    ue_id=${ue_id}    mode=SA    dl_tput_list=${dl_tput_list}
    END

Perform SA UE Register for Blind ScellAddition and Blind ScellActivation
    [Arguments]    ${sa_ue_list}    ${scell_index_list}=${4CC_scell_index}    ${pdu_id}=3
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Ensure UE Register Is Successful    ue_id=${ue_id}
        Ensure Set PDU Param Is Successful    ue_id=${ue_id}    pdu_id=${pdu_id}    trf_type=internal
        Ensure UE PDU Session Setup Is Successful    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${ue_id}    nwslice=1
        Verify scell addition for each scell index    ${scell_index_list}
        Verify scell activation for each scell index    ${ue_id}    ${scell_index_list}
    END

Start parallel traffic for all SA UEs
    [Arguments]    ${ue_list}    ${dl_tput}=${dl_tput_list}    ${ul_tput}=${ul_tput}
    Start traffic for all SA UEs UL data   ${ue_list}    ${ul_tput}
    Start traffic for all SA UEs DL data   ${ue_list}    ${dl_tput}
    sleep   10s    reason=for traffic to be stable

Start parallel UL and DL traffic with multiple trf_id for all SA UEs
    [Arguments]    ${ue_list}    ${dl_tput}=${dl_tput_list}    ${ul_tput}=${ul_tput_list}
    Start traffic for all SA UEs UL data with multiple trf_id   ${ue_list}    ${ul_tput}
    Start traffic for all SA UEs DL data   ${ue_list}    ${dl_tput}
    sleep   10s    reason=for traffic to be stable

Start traffic for all SA UEs UL data with multiple trf_id
    [Arguments]    ${ue_list}    ${ul_tput}=${ul_tput_list}
    FOR    ${ue_id}    IN    @{ue_list}
        Log To Console    Going To Start UL Traffic for SA UE: ${ue_id}
        Start UL SA Traffic for multi UE scenario    ${ue_id}    ${ul_tput}
    END

Start traffic for all SA UEs UL data
    [Arguments]    ${ue_list}    ${ul_tput}=${ul_tput}    ${pdu}=3
    FOR    ${ue_id}    IN    @{ue_list}
        Log To Console    Going To Start UL Traffic for SA UE: ${ue_id}
        Start Traffic    ue_id=${ue_id}    dir=ul    pdu=${pdu}    mbps=${ul_tput}
    END

Start traffic for all SA UEs DL data
    [Arguments]    ${ue_list}    ${dl_tput}=${dl_tput_list}
    FOR    ${ue_id}    IN    @{ue_list}
        Log To Console    Going To Start DL Traffic for SA UE: ${ue_id}
        Start DL SA Traffic for multi UE scenario    ${ue_id}    ${dl_tput}
    END

Start Traffic without Validation of Scell Activation
    [Arguments]    ${ue_id}    ${mode}    ${dl_tput_list}=${dl_tput_list}    ${bearer_id}=${EMPTY}
    FOR    ${index}    ${dl_tput}    IN ENUMERATE    @{dl_tput_list}
        ${trf_id}=    Evaluate    ${index} + 1
        run keyword if    $mode == 'SA'    Start Traffic    ue_id=${ue_id}    dir=dl    pdu=3    trf_id=${trf_id}    mbps=${dl_tput}
        ...    ELSE    Start Traffic    ue_id=${ue_id}    dir=dl    id=${bearer_id}    trf_id=${trf_id}    mbps=${dl_tput}
    END

Perform NSA UE Attach and start traffic for Blind ScellAddition and Blind ScellActivation
    [Arguments]    ${nsa_ue_list}    ${scell_index}=${scell_index}    ${target_cells}=2    ${uplink_tput}=${ul_tput}
    FOR    ${ue_id}    IN    @{nsa_ue_list}
        UE Attach    ue_id=${ue_id}    profile_id=${profile_id}
        SGNB Addition For Bearer    ue_id=${ue_id}    target_gnb=${target_gnb}    target_cells=${target_cells}
        ...    bearer=${bearer_id}    pass_regexp=SCellIndex ${scell_index} activated successfully
        Verify scell activation for each scell index    ${ue_id}    ${scell_index}
        Log To Console    Going To Start Traffic for NSA UE: ${ue_id}
        Start Traffic    ue_id=${ue_id}    dir=ul    id=${bearer_id}    mbps=${uplink_tput}
        Start Traffic without Validation of Scell Activation    ue_id=${ue_id}     mode=NSA
        ...    dl_tput_list=${dl_tput_list}    bearer_id=${bearer_id}
    END

Validate Pcell Throughput from UE stats and bearer stats for Non CA Capable UEs
    [Arguments]    ${expected_ul_tput}    ${expected_dl_tput}    ${UE_List}
    FOR    ${ue_id}    IN    @{UE_List}
        Log To Console    Going To Check Throughput for Non CA Capable SA UE: ${ue_id}
        ${pcell_tput}    Cell Specific Throughput Validation    ue_id=${ue_id}    scell=0    type=pdsch
        ${ul_tput}    Get Average Throughput from Bearer Stats For SA    ue_id=${ue_id}    dir=ul    pdu_id=3
        ${dl_tput}    Get Average Throughput from Bearer Stats For SA    ue_id=${ue_id}    dir=dl    pdu_id=3
        Total CA UE Throughput Verification from cell stats   ${pcell_tput}    ${expected_dl_tput}
        Run Keyword and Ignore Error    Average Throughput Should Be as Expected    ${ul_tput}
        ...    ${expected_ul_tput}
    END

Validate downlink cell throughput from UE stats and bearer stats for SA UEs
    [Arguments]    ${expected_ul_tput}    ${expected_dl_tput}    ${UE_List}    ${Scell_Id}
    ${expected_dl_value}    Evaluate    isinstance(${expected_dl_tput}, list) == True
    ${expected_total_dl_tput}    Run Keyword If    ${expected_dl_value}    Evaluate
    ...    sum([int(str(x).encode('ascii')) for x in @{expected_dl_tput}])    ELSE    Set Variable    ${expected_dl_tput}
    FOR    ${ue_id}    IN    @{UE_List}
        Log To Console    Going To Check Throughput for SA UE: ${ue_id}
        ${total_tput}    Get Throughput from all cells    ${ue_id}     ${Scell_Id}
        ${ul_tput}    Get Average Throughput from Bearer Stats For SA    ue_id=${ue_id}    dir=ul    pdu_id=3
        ${dl_tput}    Get Average Throughput from Bearer Stats For SA    ue_id=${ue_id}    dir=dl    pdu_id=3
        Total CA UE Throughput Verification   ${total_tput}    ${dl_tput}    ${expected_total_dl_tput}
        Run Keyword and Ignore Error    Average Throughput Should Be as Expected    ${ul_tput}
        ...    ${expected_ul_tput}
    END

Validate throughput from UE stats for all CA UEs
    [Arguments]    ${ue_list}    ${expected_dl_tput}    ${expected_ul_tput}    ${dl_scell}    ${ul_scell}
    ${expected_dl_value}    Evaluate    isinstance(${expected_dl_tput}, list) == True
    ${expected_total_dl_tput}    Run Keyword If    ${expected_dl_value}    Evaluate
    ...    sum([int(str(x).encode('ascii')) for x in @{expected_dl_tput}])    ELSE    Set Variable    ${expected_dl_tput}
    ${expected_ul_value}    Evaluate    isinstance(${expected_ul_tput}, list) == True
    ${expected_total_ul_tput}    Run Keyword If    ${expected_ul_value}    Evaluate
    ...    sum([int(str(x).encode('ascii')) for x in @{expected_ul_tput}])    ELSE    Set Variable    ${expected_ul_tput}
    FOR    ${ue_id}    IN    @{ue_list}
        Log To Console    Going To Check UE stats for  UE: ${ue_id}
        ${dl_tput}    Get Throughput from all cells    ${ue_id}    scell=${dl_scell}    type=pdsch
        ${ul_tput}    Get Throughput from all cells    ${ue_id}    scell=${ul_scell}    type=pusch
        Average UE stats throughput Should Be as Expected    ${dl_tput}    ${expected_total_dl_tput}
        Average UE stats throughput Should Be as Expected    ${ul_tput}    ${expected_total_ul_tput}
    END

Validate throughput from UE stats for all CA UEs for L4S
    [Arguments]    ${expected_dl_tput}    ${expected_ue1_tput}    ${expected_ue2_tput}
    ${expected_dl_value}    Evaluate    isinstance(${expected_dl_tput}, list) == True
    ${expected_total_dl_tput}    Run Keyword If    ${expected_dl_value}    Evaluate
    ...    sum([int(str(x).encode('ascii')) for x in @{expected_dl_tput}])    ELSE    Set Variable    ${expected_dl_tput}
	${expected_ue1_value}    Evaluate    isinstance(${expected_ue1_tput}, list) == True
    ${expected_total_ue1_tput}    Run Keyword If    ${expected_ue1_value}    Evaluate
    ...    sum([int(str(x).encode('ascii')) for x in @{expected_ue1_tput}])    ELSE    Set Variable    ${expected_ue1_tput}
	${expected_ue2_value}    Evaluate    isinstance(${expected_ue2_tput}, list) == True
    ${expected_total_ue2_tput}    Run Keyword If    ${expected_ue2_value}    Evaluate
    ...    sum([int(str(x).encode('ascii')) for x in @{expected_ue2_tput}])    ELSE    Set Variable    ${expected_ue2_tput}
	${ue_stats_output}=    Capture UE Stats for L4S    1,2    scell=0-4    type=pdsch
    Validate UE Stats Average    ${ue_stats_output}    ${expected_total_dl_tput}    ${expected_total_ue1_tput}    ${expected_total_ue2_tput}

Validate UE Stats Average
    [Arguments]    ${ue_stats_output}    ${expected_total_dl_tput}    ${expected_total_ue1_tput}    ${expected_total_ue2_tput}
    ${lines}=    Split String    ${ue_stats_output}    \n
    ${avg_list}=    Create List
    ${current_ue}=    Set Variable    None

    FOR    ${line}    IN    @{lines}
        ${is_ue1}=    Run Keyword And Return Status    Should Contain    ${line}    UE-1:
        ${is_ue2}=    Run Keyword And Return Status    Should Contain    ${line}    UE-2:
        IF    ${is_ue1}
            ${current_ue}=    Set Variable    UE-1
        ELSE IF    ${is_ue2}
            ${current_ue}=    Set Variable    UE-2
        END
        ${is_total}=    Run Keyword And Return Status    Should Start With    ${line}    1 cell
        IF    ${is_total}
            ${parts}=    Split String    ${line}
            ${avg_str}=    Get From List    ${parts}    -2
            ${unit}=      Get From List    ${parts}    -1
            ${avg_float}=    Convert To Number    ${avg_str}
            IF    '${unit}' == 'Kbps'
                ${avg_float}=    Evaluate    ${avg_float} / 1000
            ELSE IF    '${unit}' == 'Gbps'
                ${avg_float}=    Evaluate    ${avg_float} * 1000
            END

            IF    '${current_ue}' == 'UE-1'
                ${expected}=    Set Variable    ${expected_total_ue1_tput}
            ELSE IF    '${current_ue}' == 'UE-2'
                ${expected}=    Set Variable    ${expected_total_ue2_tput}
            END

            Run Keyword And Continue On Failure    Should Be True
            ...    ${avg_float} >= (${expected} - 20)
            ...    Average throughput ${avg_float} Mbps is less than ${expected} Mbps (allowed tolerance: 10 Mbps)!

            Append To List    ${avg_list}    ${avg_float}
        END
    END

    ${total_avg}=    Evaluate    sum(${avg_list})
    Log To Console    \n>>> Combined Average Throughput: ${total_avg} Mbps
    Should Be True    ${total_avg} >= (${expected_total_dl_tput}-20)
	...    Combined average throughput ${total_avg} Mbps is less than ${expected_total_dl_tput} Mbps!



Perform Stop Traffic and Detach SA UEs for Blind ScellAddition
    [Arguments]    ${sa_ue_list}
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Log To Console    Going To Stop Traffic for SA UE: ${ue_id}
        Stop UE Traffic    ue_id=${ue_id}    pdu=3    dir=ul
        Stop UE Traffic    ue_id=${ue_id}    pdu=3    dir=dl
        Ensure UE PDU Session Release Is Successful    ue_id=${ue_id}    pdu_id=3
        Ensure UE Deregister Is Successful    ue_id=${ue_id}    ue_deregister_type=switch_off    by=ue
    END

Perform Stop Traffic and Detach NSA UEs for Blind ScellAddition
    [Arguments]    ${nsa_ue_list}    ${bearer_id}=2
    FOR    ${ue_id}    IN    @{nsa_ue_list}
        Log To Console    Going To Stop Traffic for NSA UE: ${ue_id}
        Stop UE Traffic    ue_id=${ue_id}
        Release ENDC Bearer    ue_id=${ue_id}    bearer=${bearer_id}    cause=MISC_CauseMisc_unspecified
        UE Detach    ue_id=${ue_id}
    END

Perform SA UE Register for Blind ScellAddition and Bufferbased ScellActivation with CSI Override
    [Arguments]    ${sa_ue_list}    ${scell_index_list}=${4CC_scell_index}    ${4CC}=False    ${csi_scell_index}=${4CC_scell_index_1}
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Ensure UE Register Is Successful    ue_id=${ue_id}
        Ensure Set PDU Param Is Successful    ue_id=${ue_id}    pdu_id=3    trf_type=internal
        ${output}    Ensure UE PDU Session Setup Is Successful    ue_id=${ue_id}    pdu_id=3    gw_id=${ue_id}
        ...     pass_regexp=sCellIndex ${SA_Scell_Index}[1]    nwslice=1
        run keyword if   ${4CC}     Verify scell addition for each scell index    ${scell_index_list}
        run keyword if   ${4CC}
        ...     Associate UE to testmode    id=${ue_id}    testmode=csi_override     profile_id=2    action=activate    scell=${csi_scell_index}
        ...    ELSE    Associate UE to testmode    id=${ue_id}    testmode=csi_override     profile_id=2    action=activate    scell=0,1
    END

Perform NSA UE Attach for Blind ScellAddition and Bufferbased ScellActivation with CSI Override
    [Arguments]    ${nsa_ue_list}
    FOR    ${ue_id}    IN    @{nsa_ue_list}
        UE Attach    ue_id=${ue_id}    profile_id=${profile_id}
        ${output}    SGNB Addition For Bearer    ue_id=${ue_id}    target_gnb=${target_gnb}    target_cells=${target_cells}
        ...    bearer=${bearer_id}    pass_regexp=sCellIndex ${NSA_Scell_Index}[1]
        Associate UE to testmode    id=${ue_id}    testmode=csi_override     profile_id=2    action=activate    scell=8,9
    END

Stop traffic for UEs
    [Arguments]    ${non_ca_sa_ue_list}=${EMPTY}    ${ca_sa_ue_list}=${EMPTY}    ${nsa_ue_list}=${EMPTY}
    Run Keyword If    "${non_ca_sa_ue_list}" != "${EMPTY}"    Stop traffic for SA UEs    ${non_ca_sa_ue_list}
    Run Keyword If    "${ca_sa_ue_list}" != "${EMPTY}"    Stop traffic for SA UEs    ${ca_sa_ue_list}
    Run Keyword If    "${nsa_ue_list}" != "${EMPTY}"    Stop traffic for NSA UEs    ${nsa_ue_list}

Stop traffic for NSA UEs
    [Arguments]    ${nsa_ue_list}
    FOR    ${ue_id}    IN    @{nsa_ue_list}
        Log To Console    Going To Stop Traffic for NSA UE: ${ue_id}
        Stop UE Traffic    ue_id=${ue_id}
    END

Stop traffic for SA UEs
    [Arguments]    ${sa_ue_list}
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Log To Console    Going To Stop Traffic for SA UE: ${ue_id}
        Stop UE Traffic    ue_id=${ue_id}    pdu=3    dir=ul
        Stop UE Traffic    ue_id=${ue_id}    pdu=3    dir=dl
    END

Verify scell deactivated for all UEs
    sleep     10s    reason=Waiting for all Scells to be deactivated
    Execute Egate Command    cmd=sim_log_set flush    timeout=2s
    sleep    5s    reason=Waiting for egate console to be flushed
    FOR    ${ue_id}    IN    @{Multi_CA_SA_UE_List}
        ${sa_scell_ue_id}    Evaluate    ${ue_id}-1
        Run keyword And Continue On Failure
        ...    Egate console log verification    UeId:${sa_scell_ue_id},SubcellId:[0-1].* SCellIndex 1 deactivated successfully
    END
    FOR    ${ue_id}    IN    @{Multi_CA_NSA_UE_List}
        ${nsa_scell_ue_id}    Evaluate    ${ue_id}-1
        Run keyword And Continue On Failure
        ...    Egate console log verification    UeId:${nsa_scell_ue_id},SubcellId:[0-1].* SCellIndex 9 deactivated successfully
    END

Detach SA UEs for Blind ScellAddition
    [Arguments]    ${sa_ue_list}    ${pdu}=3
    Detach SA UEs    ${sa_ue_list}    ${pdu}

Detach NSA UEs for Blind ScellAddition
    [Arguments]    ${nsa_ue_list}    ${bearer_id}=2
    Detach NSA UEs    ${nsa_ue_list}    ${bearer_id}

Revert Gnb Configuration for LOKI cell deployment sansa
    Download SCF file    local_dir_path=${testlog_path}    file_name=SCF_used_during_TC.xml
    return from keyword if    '${Gnb_Revert}' == 'False'
    ${revert_delta}     Get Revert Delta Param for Cell Deployment SANSA
    Recommission GNB With Delta    ${revert_delta}
    Wait for gNB To Be Ready

Revert Gnb Configuration for LOKI cell deployment
    Download SCF file    local_dir_path=${testlog_path}    file_name=SCF_used_during_TC.xml
    return from keyword if    '${Gnb_Revert}' == 'False'
    ${revert_delta}     Run Keyword if    '${cell_deployment}' == 'SA'    Get Revert Delta Param for Cell Deployment SA
    ...    ${NRCELL_distname_list}
    ...    ELSE    Get Revert Delta Param for Cell Deployment NSA    ${NRCELL_distname_list}
    Recommission GNB With Delta    ${revert_delta}
    Wait for gNB To Be Ready

Perform SA UE Register and start traffic for Measurement based ScellAddition and Blind ScellActivation
    [Arguments]    ${sa_ue_list}    ${carrier_frequency}    ${uplink_tput}=${ul_tput}
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Ensure UE Register Is Successful    ue_id=${ue_id}
        Ensure Set PDU Param Is Successful    ue_id=${ue_id}    pdu_id=3    trf_type=internal
        Ensure UE PDU Session Setup Is Successful    ue_id=${ue_id}    pdu_id=3    gw_id=${ue_id}    nwslice=1
        Trigger A1 Event measurement    ue_id=${ue_id}    pass_regexp=SCellIndex 1 activated successfully
        ...    carrier_frequency=${carrier_frequency}    phycell_id=50    srsrp_nr=40
        Log To Console    Going To Start Traffic for SA UE: ${ue_id}
        Start Traffic    ue_id=${ue_id}    dir=ul    pdu=3    mbps=${uplink_tput}
        Start Traffic without Validation of Scell Activation    ue_id=${ue_id}    mode=SA    dl_tput_list=${dl_tput_list}
    END

Perform SA UE Register for Measurement based ScellAddition and Blind ScellActivation
    [Arguments]    ${sa_ue_list}    ${carrier_frequency}    ${phycell_id}=50    ${srsrp_nr}=40
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Ensure UE Register Is Successful    ue_id=${ue_id}
        Ensure Set PDU Param Is Successful    ue_id=${ue_id}    pdu_id=3    trf_type=internal
        Ensure UE PDU Session Setup Is Successful    ue_id=${ue_id}    pdu_id=3    gw_id=${ue_id}    nwslice=1
        Trigger A1 Event measurement    ue_id=${ue_id}    pass_regexp=SCellIndex 1 activated successfully
        ...    carrier_frequency=${carrier_frequency}    phycell_id=${phycell_id}    srsrp_nr=${srsrp_nr}
    END

Perform NSA UE Attach and start traffic for Measurement based ScellAddition and Blind ScellActivation
    [Arguments]    ${nsa_ue_list}    ${carrier_frequency}
    FOR    ${ue_id}    IN    @{nsa_ue_list}
        UE Attach    ue_id=${ue_id}    profile_id=${profile_id}
        SGNB Addition For Bearer    ue_id=${ue_id}    target_gnb=${target_gnb}    target_cells=${target_cells}
        ...    bearer=${bearer_id}
        Trigger A1 Event measurement    ue_id=${ue_id}    pass_regexp=SCellIndex 9 activated successfully
        ...    carrier_frequency=${carrier_frequency}    phycell_id=50    srsrp_nr=40
        Log To Console    Going To Start Traffic for SA UE: ${ue_id}
        Start Traffic    ue_id=${ue_id}    dir=ul    id=${bearer_id}    mbps=${ul_tput}
        Start Traffic without Validation of Scell Activation    ue_id=${ue_id}     mode=NSA
        ...    dl_tput_list=${dl_tput_list}    bearer_id=${bearer_id}
    END

Detach SA UEs for Measurement Based ScellAddition
    [Arguments]    ${sa_ue_list}    ${carrier_frequency}    ${4CC}=False    ${scell_rsrp}=30    ${phycell_id}=51
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Log To Console    Going To release SA UE: ${ue_id}
        Run Keyword If    '${4CC}' == 'True'    Trigger Scell Release by A2 Event    ${ue_id}    ${carrier_frequency}
        ...    ELSE
        ...    Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport    carrier_frequency=${carrier_frequency}
        ...    scell=${SA_Scell_Index}[1]    scell_rsrp=${scell_rsrp}    phycell_id=${phycell_id}
        Validate Scell Release    scell_index=${SA_Scell_Index}[1]
        Ensure UE PDU Session Release Is Successful    ue_id=${ue_id}    pdu_id=3
        Ensure UE Deregister Is Successful    ue_id=${ue_id}    ue_deregister_type=switch_off    by=ue
    END

Detach NSA UEs for Measurement Based ScellAddition
    [Arguments]    ${nsa_ue_list}    ${carrier_frequency}
    FOR    ${ue_id}    IN    @{nsa_ue_list}
        Log To Console    Going To release SA UE: ${ue_id}
        Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=rrcConnectionReconfigurationComplete
        ...    carrier_frequency=${carrier_frequency}    scell=${NSA_Scell_Index}[1]    scell_rsrp=30    phycell_id=51
        Validate Scell Release    scell_index=${NSA_Scell_Index}[1]
        Release ENDC Bearer    ue_id=${ue_id}    bearer=${bearer_id}    cause=MISC_CauseMisc_unspecified
        UE Detach    ue_id=${ue_id}
    END

Perform SA UE Register for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override
    [Arguments]    ${sa_ue_list}    ${carrier_frequency}    ${scell}=0,1    ${4CC}=False
    ...    ${scell_index_list}=${4CC_scell_index}    ${srsrp_nr}=100    ${srsrp_nr_2cc}=40
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Ensure UE Register Is Successful    ue_id=${ue_id}
        Ensure Set PDU Param Is Successful    ue_id=${ue_id}    pdu_id=3    trf_type=internal
        Ensure UE PDU Session Setup Is Successful    ue_id=${ue_id}    pdu_id=3    gw_id=${ue_id}    nwslice=1
        Run Keyword If    "${4CC}" == "True"    Trigger A1 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport
        ...    carrier_frequency=${carrier_frequency}    srsrp_nr=${srsrp_nr}
        ...    ELSE
        ...    Trigger A1 Event measurement    ue_id=${ue_id}    pass_regexp=sCellIndex ${SA_Scell_Index}[1]
        ...    carrier_frequency=${carrier_frequency}    srsrp_nr=${srsrp_nr_2cc}
        Run Keyword If    "${4CC}" == "True"    Verify scell addition for each scell index    ${scell_index_list}
        Associate UE to testmode    id=${ue_id}    testmode=csi_override     profile_id=2    action=activate    scell=${scell}
    END

Perform NSA UE Attach for Measurement based ScellAddition and Bufferbased ScellActivation with CSI Override
    [Arguments]    ${nsa_ue_list}    ${carrier_frequency}    ${InterHO}=False
    FOR    ${ue_id}    IN    @{nsa_ue_list}
        UE Attach    ue_id=${ue_id}    profile_id=${profile_id}
        Run Keyword If    "${InterHO}" == "True"    Update UE parameters for eNB    id=${ue_id}    drx_config=off
        ...    measurement_gap=gp0:20    gap_trigger=enb_and_gnb_triggered    mgta=ms0    gap_purpose=perUE
        ${output}    SGNB Addition For Bearer    ue_id=${ue_id}    target_gnb=${target_gnb}    target_cells=${target_cells}
        ...    bearer=${bearer_id}
        Run Keyword If    "${InterHO}" == "True"    Validate meas gap config prints for inter cases    ${output}
        Trigger A1 Event measurement    ue_id=${ue_id}    pass_regexp=sCellIndex ${NSA_Scell_Index}[1]
        ...    carrier_frequency=${carrier_frequency}    phycell_id=50    srsrp_nr=40
        Associate UE to testmode    id=${ue_id}    testmode=csi_override     profile_id=2    action=activate    scell=8,9
    END

Validate meas gap config prints for inter cases
    [Arguments]    ${output}
    Log To Console    Validating measurement gap configuration prints...
    Validate success prints from command output    ${output}    pass_regex=*measGapConfig setup :*
    Validate success prints from command output    ${output}    pass_regex=*gapOffset gp0 : 20*

Perform Stop Traffic and Detach SA UEs for MeasurementBased ScellAddition and Bufferbased ScellActivation
    [Arguments]    ${sa_ue_list}    ${carrier_frequency}
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Log To Console    Going To Stop Traffic for SA UE: ${ue_id}
        Stop UE Traffic    ue_id=${ue_id}    pdu=3    dir=ul
        Stop UE Traffic    ue_id=${ue_id}    pdu=3    dir=dl
        sleep     10s    reason=Waiting for Scell to be deactivated
        Execute Egate Command    cmd=sim_log_set flush    timeout=2s
        ${sa_scell_ue_id}    Evaluate    ${ue_id}-1
        Egate console log verification    UeId:${sa_scell_ue_id},SubcellId:[0-1].* SCellIndex 1 deactivated successfully
    END
    Detach SA UEs for Measurement Based ScellAddition    sa_ue_list=${sa_ue_list}    carrier_frequency=${carrier_frequency}

Perform Stop Traffic and Detach NSA UEs for MeasurementBased ScellAddition and Bufferbased ScellActivation
    [Arguments]    ${nsa_ue_list}    ${carrier_frequency}
    FOR    ${ue_id}    IN    @{nsa_ue_list}
        Log To Console    Going To Stop Traffic for NSA UE: ${ue_id}
        Stop UE Traffic    ue_id=${ue_id}
        sleep     10s    reason=Waiting for Scell to be deactivated
        Execute Egate Command    cmd=sim_log_set flush    timeout=2s
        ${nsa_scell_ue_id}    Evaluate    ${ue_id}-1
        Egate console log verification    UeId:${nsa_scell_ue_id},SubcellId:[0-1].* SCellIndex 9 deactivated successfully
    END
    Detach NSA UEs for Measurement Based ScellAddition    nsa_ue_list=${nsa_ue_list}    carrier_frequency=${carrier_frequency}

Update Gnb for different cell deployment
    [Arguments]    ${cell_deployment}=${EMPTY}    &{kwargs}
    ${original_scf_path}    Download SCF file    local_dir_path=${testlog_path}    file_name=SCF_original.xml
    set test variable    ${original_scf_path}
    Get cell distnames for scell activation and deactivation
    Run Keyword if    '${cell_deployment}' == 'SANSA'    Get original params from gnB for Cell Deployment SANSA
    ...    ELSE IF    '${cell_deployment}' == 'SA'    Get original params from gnB for Cell Deployment SA
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    Create delta for Gnb configuration changes    &{kwargs}
    ${delta_store}    Collect Delta Store
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}
    Set Test Variable    ${Gnb_Revert}    True
    Wait Until Keyword Succeeds     2min     30sec     Check if gNB is reachable    ${GNB_IP}

Update Gnb for cell deployment NSA
    [Arguments]    &{kwargs}
    ${original_scf_path}    Download SCF file    local_dir_path=${testlog_path}    file_name=SCF_original.xml
    set test variable    ${original_scf_path}
    Get cell distnames for scell activation and deactivation
    Get original params from gnB for Cell Deployment NSA
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    Create delta for Gnb configuration changes    &{kwargs}
    ${delta_store}    Collect Delta Store
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}
    Set Test Variable    ${Gnb_Revert}    True
    Wait Until Keyword Succeeds     2min     30sec     Check if gNB is reachable    ${GNB_IP}

Trigger A1 event and validate scell addition
    [Arguments]    ${ue_id}    ${carrier_frequency}
    ${output}    Trigger A1 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport
    ...    carrier_frequency=${carrier_frequency}    phycell_id=50    srsrp_nr=40
    Validate success prints from command output    ${output}    pass_regex=*sCellIndex ${SA_Scell_Index}[1]*

Create delta for Gnb configuration changes
    [Arguments]    &{kwargs}
    ${items}=    Get Dictionary items    ${kwargs}    sort_keys=False
    &{nrcell_parameters}    create dictionary
    FOR    ${key}    ${value}    IN    @{items}
        run keyword if   $key == 'sCellAdditionMethod'    Set scell params     ${NRREL_distname_list}     &{value}
        ...    ELSE IF   $key == 'sCellDeactivationTimerGNB' or $key == 'cellDepType'   set to dictionary   ${nrcell_parameters}    &{value}
        ...    ELSE IF   $key == 'sCellActivationMethod'    Set scell params     ${NRBTS_distname_list}     &{value}
        ...    ELSE    log to console    not a gnb scf parameter
    END
    set scell params   ${NRCELL_distname_list}     &{nrcell_parameters}
    Run Keyword if    '${cell_deployment}' == 'NSA'
    ...    Delete object from gNB    ${NRCELL_distname_list}    managed_object=NRPLMNSET_SA-1
    Run Keyword if    '${cell_deployment}' == 'SA'
    ...    Delete object from gNB    ${NRCELL_distname_list}    managed_object=NRPLMNSET_NSA-1

Set scell params
    [Arguments]    ${distname_list}    &{value}
    FOR   ${dist_name}   IN   @{distname_list}
        delta_store.update managed object and parameter to delta    dist_name=${dist_name}    &{value}
    END

Delete object from gNB
    [Arguments]    ${distname_list}    ${managed_object}=NRPLMNSET_NSA-1
    FOR   ${dist_name}   IN   @{distname_list}
        delta_store.delete_managed_object_from_delta    dist_name=${dist_name}/${managed_object}
    END

Get cell distnames for scell activation and deactivation
    ${NRBTS_DISTNAME}    admin_helper.get_distname_for_nrbts
    set test variable    ${NRBTS_DISTNAME}
    ${NRCELL2_DISTNAME}    admin_helper.get_distname_for_nrcell_using_logical_id    logical_cell_id=2
    set test variable    ${NRCELL2_DISTNAME}
    ${NRCELL1_DISTNAME}    admin_helper.get_distname_for_nrcell_using_logical_id    logical_cell_id=1
    set test variable    ${NRCELL1_DISTNAME}
    set test variable    ${NRREL1_DISTNAME}    ${NRCELL1_DISTNAME}/NRREL-1
    set test variable    ${NRREL2_DISTNAME}    ${NRCELL2_DISTNAME}/NRREL-1
    @{NRREL_distname_list}     create list        ${NRREL1_DISTNAME}    ${NRREL2_DISTNAME}
    @{NRBTS_distname_list}     create list        ${NRBTS_DISTNAME}
    @{NRCELL_distname_list}    create list        ${NRCELL1_DISTNAME}      ${NRCELL2_DISTNAME}
    set test variable    ${NRREL_distname_list}
    set test variable    ${NRBTS_distname_list}
    set test variable    ${NRCELL_distname_list}

Get original params from gnB for Cell Deployment SANSA
    ${sCellAdditionMethod_original}    scf_helper.get_feature_paramters_from_scf    ${original_scf_path}     ${TC3_sCellAdditionMethod}
    ...    ${NRREL1_DISTNAME}
    ${sCellActivationMethod_original}    scf_helper.get_feature_paramters_from_scf    ${original_scf_path}     ${TC3_sCellActivationMethod}
    ...    ${NRBTS_DISTNAME}
    ${sCellDeactivationTimerGNB_original}    scf_helper.get_feature_paramters_from_scf    ${original_scf_path}
    ...    ${TC3_sCellDeactivationTimerGNB}     ${NRCELL2_DISTNAME}
    set test variable    ${sCellAdditionMethod_original}
    set test variable    ${sCellActivationMethod_original}
    set test variable    ${sCellDeactivationTimerGNB_original}

Get original params from gnB for Cell Deployment SA
    ${sCellAdditionMethod_original}    scf_helper.get_feature_paramters_from_scf    ${original_scf_path}
    ...     ${TC15_16_sCellAdditionMethod}    ${NRREL1_DISTNAME}
    ${sCellActivationMethod_original}    scf_helper.get_feature_paramters_from_scf    ${original_scf_path}
    ...     ${TC15_16_sCellActivationMethod}    ${NRBTS_DISTNAME}
    ${sCellDeactivationTimerGNB_original}    scf_helper.get_feature_paramters_from_scf    ${original_scf_path}
    ...    ${TC18_sCellDeactivationTimerGNB}     ${NRCELL2_DISTNAME}
    ${cellDepType_original}    scf_helper.get_feature_paramters_from_scf    ${original_scf_path}
    ...    ${TC15_to_TC18_cellDepType}     ${NRCELL2_DISTNAME}
    set test variable    ${sCellAdditionMethod_original}
    set test variable    ${sCellActivationMethod_original}
    set test variable    ${sCellDeactivationTimerGNB_original}
    set test variable    ${cellDepType_original}

Get original params from gnB for Cell Deployment NSA
    ${sCellAdditionMethod_original}    scf_helper.get_feature_paramters_from_scf    ${original_scf_path}     ${TC3_sCellAdditionMethod}
    ...    ${NRREL1_DISTNAME}
    ${sCellActivationMethod_original}    scf_helper.get_feature_paramters_from_scf    ${original_scf_path}     ${TC3_sCellActivationMethod}
    ...    ${NRBTS_DISTNAME}
    ${sCellDeactivationTimerGNB_original}    scf_helper.get_feature_paramters_from_scf    ${original_scf_path}
    ...    ${TC3_sCellDeactivationTimerGNB}     ${NRCELL2_DISTNAME}
    ${cellDepType_original}    scf_helper.get_feature_paramters_from_scf    ${original_scf_path}
    ...    ${TC19_cellDepType}     ${NRCELL2_DISTNAME}
    set test variable    ${sCellAdditionMethod_original}
    set test variable    ${sCellActivationMethod_original}
    set test variable    ${sCellDeactivationTimerGNB_original}
    set test variable    ${cellDepType_original}

Get Revert Delta Param for Cell Deployment SANSA
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    Set scell params    ${NRREL_distname_list}    &{sCellAdditionMethod_original}
    Set scell params    ${NRBTS_distname_list}    &{sCellActivationMethod_original}
    Set scell params    ${NRCELL_distname_list}    &{sCellDeactivationTimerGNB_original}
    ${delta_store}    Collect Delta Store
    [Return]    ${delta_store}

Get Revert Delta Param for Cell Deployment SA
    [Arguments]    ${distname_list}
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    &{nrcell_original_parameters}    create dictionary
    Set scell params    ${NRREL_distname_list}    &{sCellAdditionMethod_original}
    Set scell params    ${NRBTS_distname_list}    &{sCellActivationMethod_original}
    set to dictionary   ${nrcell_original_parameters}    &{sCellDeactivationTimerGNB_original}    &{cellDepType_original}
    set scell params    ${NRCELL_distname_list}    &{nrcell_original_parameters}
    @{plmn_listvalue}    Create List    ${NRBTS_DISTNAME}/NRPLMN-1
    FOR   ${dist_name}   IN   @{distname_list}
        delta_store.add_managed_object_and_parameter_to_delta    dist_name=${dist_name}/NRPLMNSET_NSA-1
        ...    configuredEpsTac=7151    cellReservedForOperatorUse=notReserved
        delta_store.add_legacy_list_parameters_to_delta    ${dist_name}/NRPLMNSET_NSA-1    nrPlmnDNList    @{plmn_listvalue}
    END
    ${delta_store}    Collect Delta Store
    log to console    ${delta_store}
    [Return]    ${delta_store}

Get Revert Delta Param for Cell Deployment NSA
    [Arguments]    ${distname_list}
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    &{nrcell_original_parameters}    create dictionary
    Set scell params    ${NRREL_distname_list}    &{sCellAdditionMethod_original}
    Set scell params    ${NRBTS_distname_list}    &{sCellActivationMethod_original}
    set to dictionary   ${nrcell_original_parameters}    &{sCellDeactivationTimerGNB_original}    &{cellDepType_original}
    set scell params   ${NRCELL_distname_list}     &{nrcell_original_parameters}
    @{plmn_listvalue}    Create List    ${NRBTS_DISTNAME}/NRPLMN-1
    FOR   ${dist_name}   IN   @{distname_list}
        delta_store.add_managed_object_and_parameter_to_delta    dist_name=${dist_name}/NRPLMNSET_SA-1
        ...    trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200    cellReservedForOperatorUse=notReserved
        ...    cellReservedForOperatorUseUacAutoMax=notReserved
        delta_store.add_legacy_list_parameters_to_delta    ${dist_name}/NRPLMNSET_SA-1    nrPlmnDNList    @{plmn_listvalue}
    END
    ${delta_store}    Collect Delta Store
    [Return]    ${delta_store}

Activate testmode and verify scell deactivation
    [Arguments]    ${ue_list}    ${scell}=${4CC_scell_index_2}    ${profile_id}=5    ${scell_list}=${4CC_scell_index}
    Update CSI parameters    profile_id=${profile_id}
    FOR    ${ue_id}    IN    @{ue_list}
        Associate UE to testmode    id=${ue_id}    testmode=csi_override
    ...    profile_id=${profile_id}    pass_regex=SCellIndex \\d+ deactivated successfully    action=activate    scell=${scell}
    END
    Execute Egate Command    cmd=sim_log_set flush    timeout=2s
    Verify scell deactivated for SA UEs    sa_ue_list=${ue_list}    scell_list=${scell_list}

Stop Traffic and Detach SA UEs for MeasurementBased ScellAddition and Buffer+RLQ ScellActivation
    [Arguments]    ${sa_ue_list}    ${carrier_frequency}    ${4CC}=False
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Log To Console    Going To Stop Traffic for SA UE: ${ue_id}
        Stop UE Traffic    ue_id=${ue_id}    pdu=3    dir=ul
        Stop UE Traffic    ue_id=${ue_id}    pdu=3    dir=dl
        Log To Console    Going To release SA UE: ${ue_id}
        Run Keyword If    '${4CC}' == 'True'    Trigger Scell Release by A2 Event    ${ue_id}    ${carrier_frequency}
        ...    ELSE
        ...    Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport    carrier_frequency=${carrier_frequency}
        ...    scell=${SA_Scell_Index}[1]    scell_rsrp=30    phycell_id=51
        Validate Scell Release    scell_index=${SA_Scell_Index}[1]
        Ensure UE PDU Session Release Is Successful    ue_id=${ue_id}    pdu_id=3
        Ensure UE Deregister Is Successful    ue_id=${ue_id}    ue_deregister_type=switch_off    by=ue
    END

Stop Traffic and Detach CA SA UEs
    [Arguments]    ${sa_ue_list}    ${cf1}=426030    ${cf2}=156750
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Log To Console    Going To Stop Traffic for SA UE: ${ue_id}
        Stop UE Traffic    ue_id=${ue_id}    pdu=3    dir=ul
        Stop UE Traffic    ue_id=${ue_id}    pdu=3    dir=dl
        Log To Console    Going To Check Scell Dectivation For SA UE: ${ue_id}
        ${meas_id}    Get Measurement Id    ue_id=${ue_id}    event=EventA2    carrier_frequency=${cf1}
        Send Ue Measurements    ue_id=${ue_id}    meas_id=${meas_id}    pass_regexp=measurementReport    event=A2
        ...    scell=1    scell_rsrp=30    phycell_id=51
        ${meas_id}    Get Measurement Id    ue_id=${ue_id}    event=EventA2    carrier_frequency=${cf2}
        Send Ue Measurements    ue_id=${ue_id}    meas_id=${meas_id}    pass_regexp=measurementReport    event=A2
        ...    scell=2    scell_rsrp=30    phycell_id=52
        Validate Scell Release    scell_index=${SA_Scell_Index}[1]
        Validate Scell Release    scell_index=${SA_Scell_Index}[2]
        Ensure UE PDU Session Release Is Successful    ue_id=${ue_id}    pdu_id=3
        Ensure UE Deregister Is Successful    ue_id=${ue_id}    ue_deregister_type=switch_off    by=ue
    END

Trigger Scell Release by A2 Event
    [Arguments]    ${ue_id}    ${A2_carrier_frequency}
    ${items}     Get Dictionary Items   ${A2_carrier_frequency}
    FOR    ${key}    ${value}    IN    @{items}
        run keyword if   $key == 'scell1'    Trigger A2 event and validate Scell release in egate console
        ...    ue_id=${ue_id}    A2_carrier_frequency=${value}    scell_index=${4CC_scell_index}[0]
        ...    ELSE IF   $key == 'scell2'    Trigger A2 event and validate Scell release in egate console
        ...    ue_id=${ue_id}    A2_carrier_frequency=${value}    scell_index=${4CC_scell_index}[1]
        ...    ELSE IF   $key == 'scell3'    Trigger A2 event and validate Scell release in egate console
        ...    ue_id=${ue_id}    A2_carrier_frequency=${value}    scell_index=${4CC_scell_index}[2]
    END

Trigger A2 event and validate Scell release in egate console
    [Arguments]    ${ue_id}    ${A2_carrier_frequency}    ${scell_index}
    Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=rrcReconfigurationComplete
    ...    carrier_frequency=${A2_carrier_frequency}    scell=${scell_index}   scell_rsrp=30
    Validate Scell Release    scell_index=${scell_index}

Stop Traffic and Detach NSA UEs for MeasurementBased ScellAddition and Buffer+RLQ ScellActivation
    [Arguments]    ${nsa_ue_list}    ${carrier_frequency}    ${trigger_meas_gap_off}=False
    FOR    ${ue_id}    IN    @{nsa_ue_list}
        Log To Console    Going To Stop Traffic for NSA UE: ${ue_id}
        Stop UE Traffic    ue_id=${ue_id}
        Log To Console    Going To release SA UE: ${ue_id}
        Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=rrcConnectionReconfigurationComplete
        ...    carrier_frequency=${carrier_frequency}    scell=${NSA_Scell_Index}[1]    scell_rsrp=30    phycell_id=51
        Validate Scell Release    scell_index=${NSA_Scell_Index}[1]
        Run Keyword If    "${trigger_meas_gap_off}" == "True"    Update UE parameters for eNB    id=${ue_id}    drx_config=off
        ...    measurement_gap=off    gap_trigger=enb_and_gnb_triggered    mgta=ms0    gap_purpose=perUE
        Release ENDC Bearer    ue_id=${ue_id}    bearer=${bearer_id}    cause=MISC_CauseMisc_unspecified
        UE Detach    ue_id=${ue_id}
    END

#4CC
Update Gnb for 4CC
    [Arguments]    ${Ts_8533}=False    &{kwargs}
    ${original_scf_path}    Download SCF file    local_dir_path=${testlog_path}    file_name=SCF_original.xml
    set test variable    ${original_scf_path}
    Run Keyword If    '${Ts_8533}' == 'True'    Get cell distnames for scell activation and deactivation for 4CC    primary_cell=1
    ...    ELSE    Get cell distnames for scell activation and deactivation for 4CC
    Get original params from gnB for Cell Deployment_SANSA for 4CC
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    Create delta for Gnb configuration changes for 4CC    &{kwargs}
    ${delta_store}    Collect Delta Store
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}
    Set Test Variable    ${Gnb_Revert}    True
    Wait Until Keyword Succeeds     2min     30sec     Check if gNB is reachable    ${GNB_IP}

Get cell distnames for scell activation and deactivation for 4CC
    [Arguments]    ${primary_cell}=2
    ${NRBTS_DISTNAME}    admin_helper.get_distname_for_nrbts
    set test variable    ${NRBTS_DISTNAME}
    ${NRCELL2_DISTNAME}    admin_helper.get_distname_for_nrcell_using_logical_id    logical_cell_id=2
    set test variable    ${NRCELL2_DISTNAME}
    ${NRCELL1_DISTNAME}    admin_helper.get_distname_for_nrcell_using_logical_id    logical_cell_id=1
    set test variable    ${NRCELL1_DISTNAME}
    ${NRCELL3_DISTNAME}    admin_helper.get_distname_for_nrcell_using_logical_id    logical_cell_id=3
    set test variable    ${NRCELL3_DISTNAME}
    ${NRCELL4_DISTNAME}    admin_helper.get_distname_for_nrcell_using_logical_id    logical_cell_id=4
    set test variable    ${NRCELL4_DISTNAME}
    set test variable    ${NRREL1_DISTNAME}    ${NRCELL${primary_cell}_DISTNAME}/NRREL-1
    set test variable    ${NRREL2_DISTNAME}    ${NRCELL${primary_cell}_DISTNAME}/NRREL-2
    set test variable    ${NRREL3_DISTNAME}    ${NRCELL${primary_cell}_DISTNAME}/NRREL-3
    @{NRREL_distname_list}     create list    ${NRREL1_DISTNAME}    ${NRREL2_DISTNAME}    ${NRREL3_DISTNAME}
    @{NRBTS_distname_list}     create list    ${NRBTS_DISTNAME}
    @{NRCELL_distname_list}    create list    ${NRCELL1_DISTNAME}    ${NRCELL2_DISTNAME}    ${NRCELL3_DISTNAME}    ${NRCELL4_DISTNAME}
    set test variable    ${NRREL_distname_list}
    set test variable    ${NRBTS_distname_list}
    set test variable    ${NRCELL_distname_list}

Get original params from gnB for Cell Deployment_SANSA for 4CC
    FOR    ${key}    IN    @{NRREL_distname_list}
        ${sCellAdditionMethod_original}    scf_helper.get_feature_paramters_from_scf    ${original_scf_path}
        ...     ${TC3_sCellAdditionMethod}    ${key}
    END
    ${sCellActivationMethod_original}    scf_helper.get_feature_paramters_from_scf    ${original_scf_path}
    ...     ${TC3_sCellActivationMethod}    ${NRBTS_DISTNAME}
    FOR    ${key}    IN    @{NRCELL_distname_list}
        ${sCellDeactivationTimerGNB_original}    scf_helper.get_feature_paramters_from_scf    ${original_scf_path}
        ...    ${TC3_sCellDeactivationTimerGNB}    ${key}
    END
    set test variable    ${sCellAdditionMethod_original}
    set test variable    ${sCellActivationMethod_original}
    set test variable    ${sCellDeactivationTimerGNB_original}

Create delta for Gnb configuration changes for 4CC
    [Arguments]    &{kwargs}
    ${items}=    Get Dictionary items    ${kwargs}    sort_keys=False
    &{nrcell_parameters}    create dictionary
    FOR    ${key}    ${value}    IN    @{items}
        run keyword if   $key == 'sCellAdditionMethod'    Set scell params     ${NRREL_distname_list}     &{value}
        ...    ELSE IF   $key == 'sCellDeactivationTimerGNB' or $key == 'cellDepType'   set to dictionary   ${nrcell_parameters}    &{value}
        ...    ELSE IF   $key == 'sCellActivationMethod'    Set scell params     ${NRBTS_distname_list}     &{value}
        ...    ELSE    log to console    not a gnb scf parameter
    END
    set scell params    ${NRCELL_distname_list}    &{nrcell_parameters}

Revert Gnb Configuration for 4CC
    Download SCF file    local_dir_path=${testlog_path}    file_name=SCF_used_during_TC.xml
    return from keyword if    '${Gnb_Revert}' == 'False'
    ${revert_delta}     Get Revert Delta Param for 4CC
    Recommission GNB With Delta    ${revert_delta}
    Wait for gNB To Be Ready

Get Revert Delta Param for 4CC
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    Set scell params    ${NRREL_distname_list}    &{sCellAdditionMethod_original}
    Set scell params    ${NRBTS_distname_list}    &{sCellActivationMethod_original}
    Set scell params    ${NRCELL_distname_list}    &{sCellDeactivationTimerGNB_original}
    ${delta_store}    Collect Delta Store
    [Return]    ${delta_store}

Verify scell activation for each scell index
    [Arguments]    ${ue_id}    ${scell_list}
    ${sa_scell_ue_id}    Evaluate    ${ue_id}-1
    Execute Egate Command    cmd=sim_log_set flush    timeout=2s
    FOR    ${cell}    IN    @{scell_list}
        Wait Until Keyword Succeeds     30sec     10sec     Egate console log verification for multiple scell index
        ...    pattern1=UeId\\:${sa_scell_ue_id}\\,SubcellId    pattern2=SCellIndex ${cell} activated successfully
    END

Verify scell addition for each scell index
    [Arguments]    ${scell_list}=${4CC_scell_index}
    Execute Egate Command    cmd=sim_log_set flush    timeout=2s
    FOR    ${cell}    IN    @{scell_list}
        Validate Scell Addition    scell_index=${cell}
    END

Verify scell activated for SA UEs
    [Arguments]    ${sa_ue_list}=${Multi_CA_SA_UE_List}    ${scell_index_list}=${3CC_scell_index}
    Execute Egate Command    cmd=sim_log_set flush    timeout=2s
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Verify scell activation for each scell index    ${ue_id}    ${scell_index_list}
    END

Verify scell deactivated for SA UEs
    [Arguments]    ${sa_ue_list}    ${scell_list}=${4CC_scell_index}
    sleep     15s    reason=Waiting for all Scells to be deactivated
    Execute Egate Command    cmd=sim_log_set flush    timeout=2s
    sleep    5s    reason=Waiting for egate console to be flushed
    FOR    ${ue_id}    IN    @{sa_ue_list}
        ${sa_scell_ue_id}    Evaluate    ${ue_id}-1
        Verify scell deactivation for each scell index    ${sa_scell_ue_id}    scell_list=${scell_list}
    END

Verify scell deactivation for each scell index
    [Arguments]    ${sa_scell_ue_id}    ${scell_list}=${4CC_scell_index}
    FOR    ${cell}    IN    @{scell_list}
        Egate console log verification for multiple scell index
        ...    pattern1=UeId\\:${sa_scell_ue_id}\\,SubcellId    pattern2=SCellIndex ${cell} deactivated successfully
    END

Egate console log verification for multiple scell index
    [Arguments]    ${pattern1}    ${pattern2}
    Execute Egate Command    cmd=sim_log_set flush    timeout=2s
    ${rc}    ${output}=    Run and Return RC and Output    grep -i "${pattern1}" ${egate_console_log} | grep "${pattern2}"
    Should be Equal as Integers     ${rc}    0    msg=${pattern1}...${pattern2} not found in egate_console.log
    run keyword if    ${rc} == 0    log to console    ${output}

Start DL SA Traffic for multi UE scenario
    [Arguments]    ${ue_id}    ${dl_tput_list}    ${pdu}=3
    FOR    ${index}    ${dl_tput}    IN ENUMERATE    @{dl_tput_list}
        ${trf_id}=    Evaluate    ${index} + 1
        Start Traffic    ue_id=${ue_id}    dir=dl    pdu=${pdu}   trf_id=${trf_id}    mbps=${dl_tput}
    END

Start UL SA Traffic for multi UE scenario
    [Arguments]    ${ue_id}    ${ul_tput_list}    ${pdu}=3
    FOR    ${index}    ${ul_tput}    IN ENUMERATE    @{ul_tput_list}
        ${trf_id}=    Evaluate    ${index} + 1
        Start Traffic    ue_id=${ue_id}    dir=ul    pdu=${pdu}   trf_id=${trf_id}    mbps=${ul_tput}
    END

Total CA UE Throughput Verification from cell stats
    [Arguments]    ${cell_total}    ${expected_tput}
    ${result_cell}    Evaluate    int(${expected_tput} * 1.2) >= int(${cell_total}) >= int(${expected_tput} * 0.9)
    Run Keyword If    not ${result_cell}    FAIL
    ...    msg = Total TPut is not as expected. cell: ${result_cell}

##  4CC_DL + 2CC_UL keywords
Update Gnb for 4CC_DL_2CC_UL
    [Arguments]    &{kwargs}
    ${logical_cell_list}    Get From Dictionary    ${kwargs}    logical_cell_list
    ${nrrel_list}    Get From Dictionary    ${kwargs}    nrrel_list
    ${original_scf_path}    Download SCF file    local_dir_path=${testlog_path}    file_name=SCF_original.xml
    set test variable    ${original_scf_path}
    Get cell distnames for scell activation and deactivation for 4CC_DL_2CC_UL    ${logical_cell_list}    ${nrrel_list}    ${Primary_cell}
    Get original params from gnB for Cell Deployment_SANSA for 4CC_DL_2CC_UL    &{kwargs}
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    Create delta for Gnb configuration changes for 4CC_DL_2CC_UL    &{kwargs}
    ${delta_store}    Collect Delta Store
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}
    Set Test Variable    ${Gnb_Revert}    True
    Wait Until Keyword Succeeds     2min     30sec     Check if gNB is reachable    ${GNB_IP}

Get cell distnames for scell activation and deactivation for 4CC_DL_2CC_UL
    [Arguments]    ${logical_cell_list}    ${nrrel_list}    ${Primary_cell}=3
    ${NRBTS_DISTNAME}    admin_helper.get_distname_for_nrbts
    @{NRBTS_distname_list}     create list    ${NRBTS_DISTNAME}
    @{NRCELL_distname_list}    create list
    @{NRREL_distname_list}     create list
    set test variable    ${NRBTS_DISTNAME}
    FOR    ${logical_cell_id}    IN    @{logical_cell_list}
        ${NRCELL_DISTNAME}    admin_helper.get_distname_for_nrcell_using_logical_id    logical_cell_id=${logical_cell_id}
        run keyword if    ${logical_cell_id} == ${Primary_cell}     Set test variable     ${NRCELL3_DISTNAME}    ${NRCELL_DISTNAME}
        Append To List    ${NRCELL_distname_list}    ${NRCELL_DISTNAME}
    END
    FOR    ${nrrel_id}    IN    @{nrrel_list}
        ${nrrel_distname}    Set Variable    NRREL${nrrel_id}_DISTNAME
        set test variable    ${${nrrel_distname}}    ${NRCELL3_DISTNAME}/NRREL-${nrrel_id}
        Append To List    ${NRREL_distname_list}    ${NRCELL3_DISTNAME}/NRREL-${nrrel_id}
    END
    set test variable    ${NRREL_distname_list}
    set test variable    ${NRBTS_distname_list}
    set test variable    ${NRCELL_distname_list}

Get original params from gnB for Cell Deployment_SANSA for 4CC_DL_2CC_UL
    [Arguments]    &{kwargs}
    FOR    ${key}    IN    @{NRREL_distname_list}
        ${sCellAdditionMethod}    Get From Dictionary    ${kwargs}    sCellAdditionMethod
        ${sCellAdditionMethod_original}    scf_helper.get_feature_paramters_from_scf    ${original_scf_path}
        ...     ${sCellAdditionMethod}    ${key}
    END
    ${sCellActivationMethod}    Get From Dictionary    ${kwargs}    sCellActivationMethod
    ${sCellActivationMethod_original}    scf_helper.get_feature_paramters_from_scf    ${original_scf_path}
    ...     ${sCellActivationMethod}    ${NRBTS_DISTNAME}
    ${sCellDeactivationTimerGNB}    Evaluate    (${kwargs}.get('sCellDeactivationTimerGNB','None'))
    ${sCellDeactivationTimerGNB_original}    Run Keyword If    ${sCellDeactivationTimerGNB} != None
    ...    scf_helper.get_feature_paramters_from_scf    ${original_scf_path}
    ...    ${sCellDeactivationTimerGNB}    ${NRCELL3_DISTNAME}
    set test variable    ${sCellDeactivationTimerGNB}
    set test variable    ${sCellAdditionMethod_original}
    set test variable    ${sCellActivationMethod_original}
    set test variable    ${sCellDeactivationTimerGNB_original}

Create delta for Gnb configuration changes for 4CC_DL_2CC_UL
    [Arguments]    &{kwargs}
    ${items}=    Get Dictionary items    ${kwargs}    sort_keys=False
    FOR    ${key}    ${value}    IN    @{items}
        run keyword if   $key == 'sCellAdditionMethod'    Set scell params     ${NRREL_distname_list}     &{value}
        ...    ELSE IF   $key == 'sCellDeactivationTimerGNB'   Set scell params     ${NRCELL_distname_list}    &{value}
        ...    ELSE IF   $key == 'sCellActivationMethod'    Set scell params     ${NRBTS_distname_list}     &{value}
        ...    ELSE    log to console    not a gnb scf parameter
    END

Revert Gnb Configuration for 4CC_DL_2CC_UL
    Download SCF file    local_dir_path=${testlog_path}    file_name=SCF_used_during_TC.xml
    return from keyword if    '${Gnb_Revert}' == 'False'
    ${revert_delta}     Get Revert Delta Param for 4CC_DL_2CC_UL
    Recommission GNB With Delta    ${revert_delta}
    Wait for gNB To Be Ready

Get Revert Delta Param for 4CC_DL_2CC_UL
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    Set scell params    ${NRREL_distname_list}    &{sCellAdditionMethod_original}
    Set scell params    ${NRBTS_distname_list}    &{sCellActivationMethod_original}
    Run Keyword If    ${sCellDeactivationTimerGNB} != None
    ...    Set scell params    ${NRCELL_distname_list}    &{sCellDeactivationTimerGNB_original}
    ${delta_store}    Collect Delta Store
    [Return]    ${delta_store}

Test Setup for 4CC_DL_2CC_UL
    [Arguments]    ${4CC_DL_2CC_UL}=False    &{kwargs}
    Common Test setup    4CC_DL_2CC_UL=${4CC_DL_2CC_UL}    &{kwargs}
    ${list_of_cells}    Get From Dictionary    ${kwargs}    logical_cell_list
    Establish X2 link    enb_id=1    gnb_id=2
    Wait Until Keyword Succeeds    5 min    15sec
    ...    Ensure Address Distribution Is Successful
    Wait Until Keyword Succeeds    5 min    15sec
    ...    Ensure UE SIB Decoding Is Successful for cell list    list_of_cells=${list_of_cells}
    Wait Until Keyword Succeeds    5 min    15sec
    ...    Check if cell setup completed for cell list    AP_IP=${AP_IP}    list_of_cells=${list_of_cells}
    Enable rrc traces in WTS
    Start AP TTI Traces    AP
    Start gNB TTI Traces
    Start WTS tcpdump for UDP traffic

Ensure UE SIB Decoding Is Successful for cell list
    [Arguments]    ${list_of_cells}=${EMPTY}
    Execute Egate Command    cmd=sim_log_set flush    timeout=1s
    FOR    ${cell_id}    IN    @{list_of_cells}
        ${sib_decoding_string}=    Catenate    cell ${cell_id}:     SystemInformationBlockType1
        ${rc}    ${output}    Run And Return Rc And Output    grep -i "${sib_decoding_string}" /opt/wts/latest/egate_console.log
        Should be Equal as Integers     ${rc}    0    msg=UE SIB Decoding Verification has Failed for cell:${cell_id}.
    END

Check if cell setup completed for cell list
    [Arguments]   ${AP_IP}    ${list_of_cells}=${EMPTY}
    FOR    ${cell_id}    IN    @{list_of_cells}
        ${cell_setup_string}=    Catenate    Cell Setup completed     for \\[CELL_ID:${cell_id}\\]
        ${rc}=    Run and return rc
        ...       sshpass -p ${NOKIA_PASS} ssh toor4nsn@${AP_IP} 'grep -i "${cell_setup_string}" /tmp/startup_l3.log'
        Should be Equal as Integers     ${rc}    0    msg=Cell Setup Failed for cell:${cell_id}.
    END

#8CC

Common Test Setup With Custom Configuration
    [Arguments]    &{kwargs}
    Create Test Case Folder
    ${testlog_path}    log_store.get test log folder
    Set Suite Variable    ${testlog_path}
    Bring Up TL with Custom Configuration    custom_config_folder=${custom_config_folder}    update_required=True    output_dir=${OUTPUT_DIR}
    Configure LOKI Interfaces
    Wait for gNB To Be Ready
    Run Keyword And Ignore Error    Get disk space and tmp content
    Start pcap collection in gNB and WTS    options=-i any -s0 -z gzip
    Collect logs for debug
    Start and configure WTS    wts_cfg_path=/opt/wts/latest/${WTS_FILE}    edaemon_port=${edaemon_port}
    ${fault_dict_before_test}=    Run keyword And Continue On Failure    Get Alarms
    Set Test Variable    ${fault_dict_before_test}

Validate uplink and downlink cell throughput from UE stats and bearer stats for NSA UEs
    [Arguments]    ${expected_dl_tput}    ${expected_ul_tput}    ${UE_List}    ${UL_Scell_Id}    ${DL_Scell_Id}
    ${expected_dl_value}    Evaluate    isinstance(${expected_dl_tput}, list) == True
    ${expected_total_dl_tput}    Run Keyword If    ${expected_dl_value}    Evaluate
    ...    sum([int(str(x).encode('ascii')) for x in @{expected_dl_tput}])    ELSE    Set Variable    ${expected_dl_tput}
    FOR    ${ue_id}    IN    @{UE_List}
        Log To Console    Going To Check Throughput for NSA UE: ${ue_id}
        sleep    10s
        ${cell_stats_total_tput_UL}    ${bearer_stats_UL_tput}    Get throughput from ue stats and bearer stats for NSA
        ...     ${ue_id}    ${UL_Scell_Id}    dir=ul
        ${cell_stats_total_tput_DL}    ${bearer_stats_DL_tput}    Get throughput from ue stats and bearer stats for NSA
        ...     ${ue_id}    ${DL_Scell_Id}    dir=dl
        Total CA UE Throughput Verification from cell stats    ${cell_stats_total_tput_DL}    ${expected_total_dl_tput}
        Total CA UE Throughput Verification from cell stats    ${cell_stats_total_tput_UL}    ${expected_ul_tput}
    END

Get throughput from ue stats and bearer stats
    [Documentation]    Get throughput from ue stats and bearer stats for SA UEs
    [Arguments]    ${ue_id}     ${scell_index_list}    ${dir}
    ${type}     set variable if    '${dir}'=='dl'    pdsch    pusch
    ${cell_stats_total_tput}    Get Throughput from all cells    ${ue_id}     ${scell_index_list}    type=${type}
    ${bearer_stats_total_tput}    Get Average Throughput from Bearer Stats For SA    ue_id=${ue_id}    dir=${dir}    pdu_id=3
    [Return]    ${cell_stats_total_tput}    ${bearer_stats_total_tput}

Get throughput from ue stats and bearer stats for NSA
    [Arguments]    ${ue_id}     ${scell_index_list}    ${dir}
    ${type}     set variable if    '${dir}'=='dl'    pdsch    pusch
    ${cell_stats_total_tput}    Get Throughput from all cells    ${ue_id}    ${scell_index_list}    type=${type}
    ${bearer_stats_dl_tput}    Get Average Throughput from Bearer Stats For NSA    ue_id=${ue_id}    dir=${dir}
    [Return]    ${cell_stats_total_tput}    ${bearer_stats_dl_tput}

Validate Pcell Throughput For NSA Non CA Capable UEs
    [Arguments]    ${expected_ul_tput}    ${expected_dl_tput}    ${UE_List}
    FOR    ${ue_id}    IN    @{UE_List}
        Log To Console    Going To Check Throughput for NSA Non CA Capable SA UE: ${ue_id}
        ${pcell_tput}    Cell Specific Throughput Validation    ue_id=${ue_id}    scell=8
        ${ul_tput}    Get Average Throughput from Bearer Stats For NSA    ue_id=${ue_id}    dir=ul
        ${dl_tput}    Get Average Throughput from Bearer Stats For NSA    ue_id=${ue_id}    dir=dl
        Total CA UE Throughput Verification   ${pcell_tput}    ${dl_tput}    ${expected_dl_tput}
        Run Keyword and Ignore Error    Average Throughput Should Be as Expected    ${ul_tput}
        ...    ${expected_ul_tput}
    END

Perform NSA UE Attach and start traffic for Blind ScellAddition and Buffer RLQ ScellActivation
    [Arguments]    ${nsa_ue_list}    ${scell_index}=${scell_index}    ${target_cells}=2    ${uplink_tput}=${ul_tput}
    FOR    ${ue_id}    IN    @{nsa_ue_list}
        UE Attach    ue_id=${ue_id}    profile_id=${profile_id}
        SGNB Addition For Bearer    ue_id=${ue_id}    target_gnb=${target_gnb}    target_cells=${target_cells}
        ...    bearer=${bearer_id}
        Verify scell addition for each scell index    ${scell_index}
        Log To Console    Going To Start Traffic for NSA UE: ${ue_id}
        Start Traffic    ue_id=${ue_id}    dir=ul    id=${bearer_id}    mbps=${uplink_tput}
        Start Traffic without Validation of Scell Activation    ue_id=${ue_id}     mode=NSA
        ...    dl_tput_list=${dl_tput_list}    bearer_id=${bearer_id}
        sleep    5s    reason=waiting for traffic to be stable
        Verify scell activation for each scell index    ${ue_id}    ${scell_index}
    END

Perform SA UE Attach and start traffic for Blind ScellAddition and Buffer RLQ ScellActivation
    [Arguments]    ${sa_ue_list}    ${scell_index}=${scell_index}    ${uplink_tput}=${ul_tput}
    FOR    ${ue_id}    IN    @{sa_ue_list}
        Ensure UE Register Is Successful    ue_id=${ue_id}
        Ensure Set PDU Param Is Successful    ue_id=${ue_id}    pdu_id=3    trf_type=internal
        Ensure UE PDU Session Setup Is Successful    ue_id=${ue_id}    pdu_id=3    gw_id=${ue_id}    nwslice=1
        Verify scell addition for each scell index    ${scell_index}
        Log To Console    Going To Start Traffic for NSA UE: ${ue_id}
        Start Traffic    ue_id=${ue_id}    dir=ul    pdu=3    mbps=${uplink_tput}
        Start Traffic without Validation of Scell Activation    ue_id=${ue_id}     mode=SA
        ...    dl_tput_list=${dl_tput_list}
        sleep    5s    reason=waiting for traffic to be stable
        Verify scell activation for each scell index    ${ue_id}    ${scell_index}
    END
