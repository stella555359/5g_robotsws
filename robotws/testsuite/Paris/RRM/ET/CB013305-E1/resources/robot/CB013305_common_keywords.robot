*** Settings ***
Documentation     [SUITE PURPOSE]  Common KW for CB013305 automated tests
...               Test Case Scenario author   : Abderrahmane.nezrouk@nokia.com
...               Test Case Scenario contact  : yann.ah.herve@nokia.com
...               Creation Date               : 07-July-2025
...
...               TL Topology: CLOUD_5G_O_E_AP_LOOO
...               TL Variant: PRIVATE_SANSA_FS_ECPRI_CMWV_TDD_4CC_8DL8UL_4xAEQE

Library           OperatingSystem
Library           String
Library           BuiltIn
Library           ute_wtssim                    WITH NAME    wts
Library           taf.config.wts                WITH NAME    wts_cfg
Library           taf.sbts.oam.coam.admin       WITH NAME    coam


Resource          taf/rfrl/common_resources/robot/preconditions.robot
Resource          ../../../../../resources/SWENG/robot/Counters.robot
Resource          ../../../../../resources/SWENG/robot/SetConfig.robot
Resource          ../../../../../resources/SWENG/robot/Syslogs.robot
Resource          ../../../../../resources/SWENG/robot/Capture.robot
Resource          ../../../../../resources/SWENG/robot/Oam.robot
Resource          ../../../../../resources/SWENG/robot/Hardening.robot
Resource          ../../../resources/common/TtiTrace/ttitrace.robot
Resource          ../../../../../resources/SWENG/robot/GenericTest.robot
Resource          ../../../../../resources/SWENG/robot/Scf.robot
Resource          ../../../../../resources/SWENG/robot/Traffic.robot
Resource          ../../../resources/vrf_nps2/robot/common_utilities_resources.robot


Library            ../../../../../resources/SWENG/python/CoamParameter.py      WITH NAME     coam_parameter
Library            ../../../../../resources/SWENG/python/pytest/GetFiles.py
Library            taf.sbts.oam.coam.admin           WITH NAME   sbts_coam

Library           ../../../resources/vrf_nps2/python/syslog_operations.py
Library           ../../../resources/vrf_nps2/python/pm_utilities.py
Library           ../../../resources/vrf_nps2/python/utilities.py
Library           ../python/syslog_analysis.py

*** Variables ***
@{cell_mapping_patterns}            cprt::cm::CellMappingReq:    "dlSubcellList":
@{cell_mapping_columns}             nrCellIdentity    dlSubcellId    l2PoolId    l2SubpoolId    l1PoolId    l1SubpoolId
${gnb_alias}                        gnb_under_test
${bsr_file}                         BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00002.zip
@{SA_UE_ID_List_Step_1}             1    2    3   4    5    6
@{SA_UE_ID_List_Step_2}             7    8    9   10   11   12
@{SA_UE_ID_List_Step_3}             13   14   15  16
@{SA_UE_ID_List_Step_4}             17   18   19  20
@{pi_list}                          M55308C28003	# Accumulated number of UEs scheduled in UL per slot per BWP1
...                                 M55308C28007	# Accumulated number of UEs scheduled in UL per slot per BWP2
...                                 M55308C28011	# Accumulated number of UEs scheduled in UL per slot per Power Saving BWP
...                                 M55308C28004	# Maximum number of UEs scheduled in UL per slot per BWP1
...                                 M55308C28008	# Maximum number of UEs scheduled in UL per slot per BWP2
...                                 M55308C28012	# Maximum number of UEs scheduled in UL per slot per Power Saving BWP
...                                 M55365C27011	# Number of radio frames scheduled with multiple K2 modes
...                                 M55365C27012	# Number of radio frames
...                                 M55125C02501	# Number of INITIAL CONTEXT SETUP REQUEST messages received
...                                 M55112C03001	# Number of radio bearer attempted to add
...                                 M55117C01009	# Number of UE Context Release Command received
${m_period}                         5
${CHECK_SYSLOG}                     ${True}

*** Keywords ***
Get Snaphot Sos Report
    Dated log                       Get Snapshot
  # Get Sos Report
    Get Snapshot

Apply Delta Commissioning File
    [Documentation]               Dedicated KW to apply a delta commissioning file.
    ...                           It performs delta commissioning and waits until gNB is up again
    ...                           (in case of RAT reset is needed for example)
    [Arguments]                   ${conn_alias}    ${delta_file}

    # Open connection towards cOAM
    sbts_coam.connect_to          name=${conn_alias}

    # Apply delta scf
    coam_parameter.perform_scf_delta_commission
    ...                           delta_file=${delta_file}
    ...                           connection=${conn_alias}
    ...                           timeout=300
    ...                           skip_parameter_relation_errors=True

    OAM wait available

    sbts_coam.teardown            connection=${conn_alias}

CB0013305 Feature Activation
    [Documentation]               Dedicated KW to activate the CB013305 feature.
    ...                           It performs delta commissioning and waits until gNB is up again
    ...                           (in case of RAT reset is needed for example)

    ${delta_file}=  Set Variable  ${CURDIR}/../config/${ENB_BRANCH}/CB013305_activation.json
    # Apply delta scf
    Apply Delta Commissioning File    ${gnb_alias}    ${delta_file}

CB0013305 Feature Deactivation
    [Documentation]               Dedicated KW to activate the CB013305 feature.
    ...                           It performs delta commissioning and waits until gNB is up again
    ...                           (in case of RAT reset is needed for example)

    ${delta_file}=  Set Variable  ${CURDIR}/../config/${ENB_BRANCH}/CB013305_deactivation.json
    # Apply delta scf
    Apply Delta Commissioning File    ${gnb_alias}    ${delta_file}

ADMIN Update Software
    [Arguments]    ${sw_package}
    ...            ${should_activate}
    ...            ${timeout}=1800
    ...            ${alias}=coam_gnb
    sbts_coam.update_software
    ...    sw_package=${sw_package}
    ...    should_activate=${should_activate}
    ...    timeout=${timeout}
    ...    connection=${alias}

ADMIN Update Software With Activation
    [Arguments]    ${sw_package}
    ...            ${timeout}=1800
    ...            ${alias}=coam_gnb
    ADMIN Update Software
    ...    sw_package=${sw_package}
    ...    should_activate=${True}
    ...    timeout=${timeout}
    ...    alias=${alias}

Download BSR File Using Git and Update BTS SW
     [Arguments]      ${bsr_file}   ${target_dir}
     ${exist}=      Run Keyword And Return Status    File Should Exist    ${target_dir}/${bsr_file}
     ${target}=     Run Keyword If    not ${exist}     GetFiles.download_package_using_git
     ...    gitlabe1.ext.net.nokia.com/nps_vrf_8_and_9/bsr.git
     ...    BSR
     ...    ${bsr_file}
     ...    NpsVrfToken
     ...    glpat-4yNB_jaBXxz_BsyeAsgL
     ...    target_dir=${target_dir}
     log to console   Update Software With Activation: ${target}

     sbts_coam.connect_to          name=coam_gnb

     ADMIN Update Software With Activation
     ...           sw_package=${target_dir}/${bsr_file}
     ...           alias=coam_gnb

Verify PoolInfo
    [Arguments]    ${syslog_file_path}    ${patterns_lis}    ${expected_colums}    ${expected_poolNum}=1
    [Documentation]    Verifies the pool info
    Log    Verifying pool info
    ${output_file}=    files_operations.extract_poolid_data_to_csv    ${syslog_file_path}    grep_patterns=${patterns_lis}
    ${pool_info}=      files_operations.get_unique_counts    ${output_file}    ${expected_colums}
    Log    pool info : ${pool_info}
    Should Be Equal As Integers    ${pool_info}[poolId]    ${expected_poolNum}

Check All dlSubcellId In Same l2Subpool
    [Arguments]    ${dict_list}
    ${first_l2subpool}=    Set Variable    ${dict_list[0]['l2SubpoolId']}
    FOR    ${item}    IN    @{dict_list}
        ${l2subpool}=    Get From Dictionary    ${item}    l2SubpoolId
        Run Keyword Unless    '${l2subpool}' == '${first_l2subpool}'    Fail    Not all dlSubcellId are in the same l2Subpool
    END
    [Return]    True

Check GNB And Cells Status OnAir
    [Documentation]                 Check GNB And Cells Status
    ...                             proceduralState should be in OnAir
    ...                             *Argument details:*
    ...                              - oam : Oam identity (ex: ${TGNB_DU[0].oam} or ${TGNB_CU[0].oam}).
    [Arguments]                     ${oam}=${TGNB_DU[0].oam}
    # check GNB status
    ${cmd}                          Set Variable    get_bts_statuses
    ${gnb_status}                   SBTS OAM Run Command    oam=${oam}    cmd=${cmd}
    Dated Log                       =======> Current GNB status = ${gnb_status}
    Should Contain Any              ${gnb_status['operationalState']}    Enabled   Disabled
    ...                             ignore_case=true
    Should Be Equal                 ${gnb_status['proceduralState']}     OnAir
    ...                             ignore_case=true
    ...                             msg=GNB is not in Test Mode, current status is ${gnb_status}
    Should Be Equal                 ${gnb_status['blockingState']}       Unblocked
    ...                             ignore_case=true
    # check cells status
    ${cmd}                          Set Variable    get_cells_info
    ${cells_info}                   SBTS OAM Run Command    oam=${oam}    cmd=${cmd}
    Dated log                       =======> Current cell(s) info = ${cells_info}
    FOR    ${cell}    IN    @{cells_info}
        Should Contain Any    ${cell['status']['proceduralStatus']}    not initialized   configured   OnAir
        ...                   ignore_case=true
        Should be equal       ${cell['status']['administrativeState']}    Unlocked
        ...                   ignore_case=true
    END


Restart OAM and Wait till Available
    OAM Reset SIte         ${GNB_DU.oam}
    OAM Wait Available     ${GNB_DU.oam}     400
    OAM Wait Site Available    ${GNB_DU.oam}
    Reset Egate and Reload Configuration
    Wait Until Keyword Succeeds    10min    30s       Check GNB And Cells Status OnAir    ${GNB_DU.oam}

CB013305_Register_and_Attach_All_UEs
    [Arguments]            ${SA_UE_List}    ${SA_UeId_List}
    # Dated Log New Line       ---> Attaching all needed UEs
    FOR        ${ue_id}      IN        @{SA_UeId_List}
        &{current_UE}=                  Copy dictionary     ${BASIC_UE_SA}
        Set To Dictionary               ${current_UE}       ue          ${ue_id}
        Set To Dictionary               ${current_UE}       pdu         1
        Append To List                  ${SA_UE_List}       ${current_UE}
        CallSetup.UE Register                     ue=${current_UE.ue}
        Launch PDU Session              ue=${current_UE.ue}    pdu=${current_UE.pdu}    gw=${current_UE.ue}
    END
    Dated Log                ---> All needed UEs are now attached

CB013305_Detach_all_UEs
    [Arguments]            ${SA_UE_List}
    FOR        ${current_ue}            IN         @{SA_UE_List}
        UE Deregister                   id=${current_ue.ue}
    END

TTI Trace Collection
    ${TTIdir}               Get TTI Trace Path                      dir_suffix=CB013305-Step1
    Dated Log New Line      Start TTI traces capture
    Start TTI Traces in Streaming mode    src_ip=10.0.1.2
    Traced Sleep            2 seconds    msg=TTI capture
    ${TTIpcap}              Stop TTI Traces in Streaming mode       tti_trace_path=${TTIdir}
    ...                                                             tti_trace_filename=CB013305
    Dated Log New Line      Convert TTItrace to json and csv
    ${TTIjson}              Convert TTItrace from pcap to others    input_file_path=${TTIpcap}
    ${TTIcsv}               ttitrace_tools.decode_tti_traces_json_using_TtitraceReaderEvtDec    jsonPathName=${TTIjson}
    ...                           num_of_events=10000
    set Suite Variable     ${TTIjson}

Increase Traffic Load Scenario And Check K2 Mode Status
    [Arguments]     ${SA_UE_ID_List}   ${syslog_file_name}
    [Documentation]  Increase the traffic load UL/DL, an collect the syslog and check the k2 mode status
    ...              Arguments:
    ...              -  SA_UE_List: the list of the mobile
    ...              -  syslog_file_name: Syslog file name
    ${SA_UE_List}=        Create List
    CB013305_Register_and_Attach_All_UEs    ${SA_UE_List}    ${SA_UE_ID_List}
    # Start traces capture during
    ${syslog}=                                  SYSLOG Start    host=${GNB_DU.sys[0].M}    name=${syslog_file_name}
    Traffic.Traffic UEs UL DL                   ueSettingList=${SA_UE_List}
    ...                                 duration=10s        shouldBeStop=False      shouldBeCheck=False    protocol=udp
    ...                                 dlThroughput=1          ulThroughput=40
    BuiltIn.Sleep   5s
    ${syslog_path}                    SYSLOG Stop    syslog=${syslog}
    Dated Log                                   syslog_path:  ${syslog_path}
    ${multik2_state_info}=     syslog_analysis.multiK2_state_machine         ${syslog_path}
    Dated Log                                   MultiK2 State Machine:  ${multik2_state_info}
    ${dynamic_switch_info}=    syslog_analysis.dynamic_switch_reqSender      ${syslog_path}
     Dated Log                                   Dynamic Switch ReqSender:  ${dynamic_switch_info}
    [Return]   ${SA_UE_List}

Decrease Traffic Load Scenario And Check K2 Mode Status
    [Arguments]     ${SA_UE_List}   ${syslog_file_name}
    [Documentation]  Decrease the traffic load UL/DL, collect the syslog and check the k2 mode status
    ...              Arguments:
    ...              -  SA_UE_List: the list of the mobile
    ...              -  syslog_file_name: Syslog file name
    Traffic.Traffic Stop UEs                    ueSettingList=${SA_UE_List}      dir=dl
    Traffic.Traffic Stop UEs                    ueSettingList=${SA_UE_List}      dir=ul
    CB013305_Detach_all_UEs    ${SA_UE_List}
    # Start traces capture during
    ${syslog}=                                  SYSLOG Start    host=${GNB_DU.sys[0].M}    name=${syslog_file_name}
    BuiltIn.Sleep   5s
    ${syslog_path}                    SYSLOG Stop    syslog=${syslog}
    Dated Log                                   syslog_path:  ${syslog_path}

Reset Egate and Reload Configuration
    [Documentation]                 Reset egate and reload configuration
    ...                             /
    ...                             | ... time_to_wait=1s
    ...
    ...                            *Argument details:*
    ...                            - *time_to_wait*: (optional)(default value=1s) sleep duration to be sure egate_console.log file is well updated
    [Arguments]                     ${cfg_file_path}=/opt/iphy/latest/basic_wts_step2.cfg   ${time_to_wait}=1s
    ute_wtssim.setup_egate          egate_port=${tl.core.egate_port}
    ...                             host_ip=${tl.core.default_ssh_connection_details.addr}
    ...                             tool_dir=${tl.core.dir_path}
    ...                             ssh_user=ute
    ...                             ssh_pass=ute
    ...                             alias=egate
    ute_wtssim.execute_egate_command
    ...                             cmd=reset
    ...                             timeout=5s
    ...                             alias=egate
    sleep                           ${time_to_wait}
    ${cmd}=                         Catenate    cfg file=${cfg_file_path}
    ute_wtssim.execute_egate_command
    ...                             cmd=${cmd}
    ...                             timeout=5s
    ...                             alias=egate
    sleep                           ${time_to_wait}
    ute_wtssim.teardown_egate       alias=egate
    sleep                           ${time_to_wait}

CB013305-E1_05_Switch_k2_mode
    [Documentation]    Test dynamic switching between K2={2} and K2={2,3,4} with multiple BWPs
    ...                and high UL PDCCH load in PS-BWP

    Set suite variable    ${tl.core.dir_path}    /opt/iphy/latest
    # Setup Config Initializations
    Init Sequence   "CB013305_E1_05_Switch_k2_mode"
    Dated Log New Line                                  ---> Configuring gNB and establishing initial calls

    ## To do
    Critical Step    Download BSR File Using Git and Update BTS SW
    ...    ${bsr_file}    /home/ute/BSR

    # Step 1: Initial Configuration and Call Establishment
    Critical Step    CB0013305 Feature Activation
    Dated Log New Line                                  ---> WTS setup SA
    Critical Step    WTS Setup                           shouldUseLua=${False}
    Dated Log New Line                                  ---> Restart TL
    # Start traces capture during cell setup
    ${syslog}=                                  SYSLOG Start    host=${GNB_DU.sys[0].M}    name=Cells_setup
    Critical Step   Restart OAM and Wait till Available    # Restart TL
    ${syslog_path_cell_setup}                    SYSLOG Stop    syslog=${syslog}
    Dated Log                                   syslog_path_cell_setup:  ${syslog_path_cell_setup}    # THQ pour sanity

    # Step 1: Check Cells Mapping Info
    ${cell_mapping_infos}    syslog_operations.syslog_data_extraction    ${syslog_path_cell_setup}    ${cell_mapping_patterns}
    ...                                ${cell_mapping_columns}
    Dated Log                                   cell_mapping_infos:  ${cell_mapping_infos}

    ${l2SubpoolId_grouped_cells}    syslog_operations.group_by_keys    l2SubpoolId    ${cell_mapping_infos}
    Dated Log                                   l2SubpoolId_grouped_cells:  ${cell_mapping_infos}

    Critical Step    Check All dlSubcellId In Same l2Subpool    ${l2SubpoolId_grouped_cells[0]}
    Critical Step    Check All dlSubcellId In Same l2Subpool    ${l2SubpoolId_grouped_cells[1]}

    ${intervals}=        Create List
    Counters.Wait PM availability

    # Step 1: Run Traffic Test Seanrio #1
    ${SA_UE_List_Step_1}    Increase Traffic Load Scenario And Check K2 Mode Status
    ...    ${SA_UE_ID_List_Step_1}    traffic_sa_Step_1
    Counters.Wait PM availability
    ${timestamp_step1}=    utilities.get_current_utc_time
    Append To List         ${intervals}    ${timestamp_step1}

    # Step 2: Run Traffic Test Seanrio #2
    ${SA_UE_List_Step_2}    Increase Traffic Load Scenario And Check K2 Mode Status
    ...    ${SA_UE_ID_List_Step_2}    traffic_sa_Step_2
    Counters.Wait PM availability
    ${timestamp_step2}=    utilities.get_current_utc_time
    Append To List         ${intervals}    ${timestamp_step2}

    # Step 3: Run Traffic Test Seanrio #3
    ${SA_UE_List_Step_3}    Increase Traffic Load Scenario And Check K2 Mode Status
    ...    ${SA_UE_ID_List_Step_3}    traffic_sa_Step_3
    Counters.Wait PM availability
    ${timestamp_step3}=    utilities.get_current_utc_time
    Append To List         ${intervals}    ${timestamp_step3}

    # Step 4: Run Traffic Test Seanrio #4
    ${SA_UE_List_Step_4}    Increase Traffic Load Scenario And Check K2 Mode Status
    ...    ${SA_UE_ID_List_Step_4}    traffic_sa_Step_4
    Counters.Wait PM availability
    ${timestamp_step4}=    utilities.get_current_utc_time
    Append To List         ${intervals}    ${timestamp_step4}

    # Step 5: Stop Traffic for Step 4
    Decrease Traffic Load Scenario And Check K2 Mode Status
    ...    ${SA_UE_List_Step_4}
    ...    Stop_traffic_sa_Step_4

    # Step 6: Stop Traffic for Step 3
    Decrease Traffic Load Scenario And Check K2 Mode Status
    ...    ${SA_UE_List_Step_3}
    ...    Stop_traffic_sa_Step_3

    # Step 7: Stop Traffic for Step 2
    Decrease Traffic Load Scenario And Check K2 Mode Status
    ...    ${SA_UE_List_Step_2}
    ...    Stop_traffic_sa_Step_2

    # Stoping remaing ue traffic and detaching
    Traffic.Traffic Stop UEs                    ueSettingList=${SA_UE_List_Step_1}      dir=dl
    Traffic.Traffic Stop UEs                    ueSettingList=${SA_UE_List_Step_1}      dir=ul
    CB013305_Detach_all_UEs    ${SA_UE_List_Step_1}
    Counters.Wait PM availability

    # Collection of PM file from the BTS
    ${pm_path}                    Counters.Collect PM files from BTS    ${LOG_PATH}/PM
    ${pi_dir}=                    Set Variable                          ${LOG_PATH}/PM/pm_files

    # Analysis:
    ${json_file}=    Save Pi Data To JSON File    ${pi_list}    ${pi_dir}    mos_list=${None}
    ...    pi_file_pattern=PM.*    m_period=${m_period}     intervals=${None}    before=${False}
    ...    out_dir=${None}    filename_prefix=counters

    # Validate counter for NRCELL-1
    Validate Counters Values From Json File
        ...    8 <= M55308C28004 + M55308C28008 <= 10
        ...    580000 <= M55308C28003 + M55308C28007 <= 864000
        ...    29900 <= M55365C27011 <= 30100
        ...    29900 <= M55365C27012 <= 30100
        ...    pm_json_file=${json_file}
        ...    mo=MRBTS-1/NRBTS-1/NRCELL-1
        ...    timestamp=${intervals[-1]}
        ...    before=${True}
        ...    m_period=${m_period}

    # Validate counter for NRCELL-3
    Validate Counters Values From Json File
        ...    8 <= M55308C28004 + M55308C28008 <= 10
        ...    580000 <= M55308C28003 + M55308C28007 <= 864000
        ...    29900 <= M55365C27011 <= 30100
        ...    29900 <= M55365C27012 <= 30100
        ...    pm_json_file=${json_file}
        ...    mo=MRBTS-1/NRBTS-1/NRCELL-3
        ...    timestamp=${intervals[-1]}
        ...    before=${True}
        ...    m_period=${m_period}

    # Validate counter for NRCELL-2
    Validate Counters Values From Json File
        ...    0 <= M55308C28004 + M55308C28008 <= 0
        ...    0 <= M55308C28003 + M55308C28007 <= 0
        ...    0 <= M55365C27011 <= 0
        ...   29900 <= M55365C27012 <= 30100
        ...    pm_json_file=${json_file}
        ...    mo=MRBTS-1/NRBTS-1/NRCELL-2
        ...    timestamp=${intervals[-1]}
        ...    before=${True}
        ...    m_period=${m_period}

    # Validate counter for NRCELL-4
    Validate Counters Values From Json File
        ...    0 <= M55308C28004 + M55308C28008 <= 0
        ...    0 <= M55308C28003 + M55308C28007 <= 0
        ...    0 <= M55365C27011 <= 0
        ...    29900 <= M55365C27012 <= 30100
        ...    pm_json_file=${json_file}
        ...    mo=MRBTS-1/NRBTS-1/NRCELL-4
        ...    timestamp=${intervals[-1]}
        ...    before=${True}
        ...    m_period=${m_period}
