*** Settings ***
Force Tags      CRT    RAN_5G    RAN_5G_TDD    SBTS00    STATE_CONFIGURED
...             CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    RF50

Documentation
...            author:       Bartosz Szlezak, bartosz.szlezak@nokia.com
...            maintainer:   I_EXT_MN_RAN_VRF_WRO2_7_T03@internal.nsn.com

Resource    .././../../../sim_resources/Krk_regression/ran_L3_SW2_resources/KRK3_resources/krk3_common/main_cls.robot
Resource    ../../../../resources/airphone/5G_SW_WRO_Keywords.robot
Resource    resources/common.robot
Library     ta5g_ue_mobility
Library     ta5g_enb
Library     ta5g_setups_and_teardowns
Library     ta5g_delta
Library     ../../../../resources/airphone/scripts/dcap_version_checker.py
Library     ../../../../resources/airphone/scout_reporting/ScoutMonitor.py

Suite Setup       Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...      AND      Create Suite Scope Variables
...      AND      common.Start Vm Ethernet Interfaces
...      AND      Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...      AND      Find Scfc and Send Delta Commissioning    scfc_filename=CB008208.json
...      AND      Check Version Of Dcap And Install If Needed
...      AND      Reach Onair    lua_cfg=${WTS_FILE}    check_edaemon_port=True
...      AND      Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    common.Stop Vm Ethernet Interfaces
...      AND      Roll Delta Back
...               initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
...               delta_scf_filename=${CURDIR}/config/default/CB008208.json
...      AND      Stop Default Processes And Gather Logs And Compress Logs

Test Setup        Test Case Setup    logs=${LOGS_WITH_DCAP}
Test Teardown     Run Keywords    Restart Scout Monitoring On Test Line If Needed
...      AND      Add Scout External Execution ID To Reporting Portal
...      AND      Test Case Teardown

*** Variables ***
${COMMON_KRK_RESOURCES_PATH}    ${CURDIR}/../resources/krk3_common
${DELTA_HO}           ${CURDIR}/resources/delta_nsa_intercell_ho.json
${DELTA_PCMD}         ${CURDIR}/resources/delta_pcmd_DCAP.json
@{DELTAS}             ${DELTA_HO}    ${DELTA_PCMD}
&{SUITE_CONFIG}       delta=${DELTAS}
@{DCAP_GNB}           condor5gSyslog
@{DCAP_BTS}           ipCapture
&{DCAP_OPTIONS}       gnb_custom_profile=${DCAP_GNB}    bts_custom_profile=${DCAP_BTS}    start=yes
&{LOGS_WITH_DCAP}     dcap=${DCAP_OPTIONS}    tcpdump_gnb=yes
${WTS_FILE}           ${CURDIR}/config/wts_additional_bearers.cfg
${DELTA_WTS_BEARERS}  ${CURDIR}/resources/wts_configs/wts_delta_additional_bearers.cfg
@{tshark_options}     -o    ntrstr.defragment:TRUE    -o    ntrstr.port:49148

*** Test Cases ***
# Test transferred from Krakow, will be rewritten
[1]CB008208-5G-A_9_B206_DU_UE_context_modification_reporting_during_new_E-RAB_setup
    Start NSA L3 Call    ue_id=101
    Add Bearer in LTE    drb_id=3
    Send X2AP SgNBModificationAdd    drb_id=3
    Start Internal NSA Bidirectional Traffic    ue_id=101    drb_id=3
    Verify NSA UE Traffic Using Bearer Stats    ue_id=101    wait=10s
    Send X2AP SgNBModificationRelease   drb_id=3
    Sleep    5s    reason=Wait for PCMD logs update
    ${dcap_files}    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    Set Test Variable    ${dcap_files}
    ${all_PCMD_records}    Get PCMD Records from PCAP     pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=nsetapx    save_to_file=${TEST_log_dir}/PCMD/all_PCMD_records.json
    Prepare And Verify UeCtxModificationTraceRecord in Collection    ${all_PCMD_records}
    Prepare And Verify DuBearerTraceRecords in Collection    ${all_PCMD_records}
    Stop NSA L3 Call    ue_id=101

*** Keywords ***
Add bearers to WTS Config
    [Arguments]    ${wts_delta}    ${wts_out}    ${wts_in}=/opt/wts/latest/basic_setup.cfg
    File Should Exist    ${wts_in}
    File Should Exist    ${wts_delta}
    ${delta_content}    OperatingSystem.Get File    ${wts_delta}
    @{lines}    Split To Lines    ${delta_content}
    wtscfg.load_wts_cfg    ${wts_in}
    ${previous_line}    Set Variable    set_bearer id=2
    FOR    ${line}    IN    @{lines}
      wtscfg.insert    ${line}    after    ${previous_line}
      ${previous_line}    Set Variable    ${line}
    END
    Create File    ${wts_out}    ${Empty}
    wtscfg.save_wts_cfg    ${wts_out}

Add Bearer in LTE
    [Arguments]    ${ue_id}=101    ${drb_id}=3
    Log to console    Add Bearer in LTE
    ${cmd}    Set Variable    bearer_add ue=${ue_id} id=${drb_id} filter=${drb_id} precedence=${drb_id}
    ute_wtssim.execute_egate_command    cmd=${cmd}    pass_regexp=Bearer.*created
    Log to console    Add Bearer in LTE - successful

Send X2AP SgNBModificationAdd
    [Arguments]    ${ue_id}=101    ${drb_id}=2
    Log to console    Send X2AP SgNBModificationAdd
    ${cmd}    Set Variable    enb_ue_dc_modify ue=${ue_id} bearer_to_add=${drb_id} by=enb cause=RN_CauseRadioNetwork_unspecified
    ute_wtssim.execute_egate_command    cmd=${cmd}    pass_regexp=Successfully reconfigured dual connectivity
    Log to console    Send X2AP SgNBModificationAdd - successful

Send X2AP SgNBModificationRelease
    [Arguments]    ${ue_id}=101    ${drb_id}=3
    Log to console    Send X2AP SgNBModificationRelease
    ${cmd}    Set Variable    enb_ue_dc_modify ue=${ue_id} bearer_to_release=${drb_id} by=enb cause=RN_CauseRadioNetwork_unspecified
    ute_wtssim.execute_egate_command    cmd=${cmd}    pass_regexp=UE${ue_id}: Successfully reconfigured dual connectivity
    Log to console    Send X2AP SgNBModificationRelease - successful

Prepare And Verify UeCtxModificationTraceRecord in Collection
    [Arguments]    ${collected_records}
    ${ueCtxModificationReqRcvTime}     Get Message Timestamp From Pcap     filter=f1ap.UEContextModificationRequest_element    which_message=1
    ${ueCtxModificationRespSndTime}    Get Message Timestamp From Pcap     filter=f1ap.UEContextModificationResponse_element   which_message=1
    Verify PCMD Record in Collection    ${collected_records}    ueCtxModificationRecord    no
    ...    result=0    ueCtxModificationReason=2
    ...    ueCtxModificationReqRcvTime.*seconds=${ueCtxModificationReqRcvTime}      ueCtxModificationReqRcvTime.*useconds=[0-9]+
    ...    ueCtxModificationRespSndTime.*seconds=${ueCtxModificationRespSndTime}    ueCtxModificationRespSndTime.*useconds=[0-9]+

Prepare And Verify DuBearerTraceRecords in Collection
    [Arguments]    ${collected_records}
    ${DuBearerTraceRecords_attach}      Create dictionary
    ...    record_name=bearerRecord
    ...    trigger=1    setupBearers=1    drb_Id=4
    ...    qci=9    priorityLevel=15    preemptionCapability=0    preemptionVulnerability=0
    ${DuBearerTraceRecords_new_E_RAB_setup}      Create dictionary
    ...    record_name=bearerRecord
    ...    trigger=2    setupBearers=1    drb_Id=5
    ...    qci=6    priorityLevel=15    preemptionCapability=0    preemptionVulnerability=0
    ${DuBearerTraceRecords_list}    Create List    ${DuBearerTraceRecords_attach}    ${DuBearerTraceRecords_new_E_RAB_setup}
    Verify PCMD Records Sequence in Collection     ${collected_records}    ${DuBearerTraceRecords_list}

Get Message Timestamp From Pcap
    [Arguments]    ${filter}=f1ap.UEContextSetupRequest_element    ${pcap_filepath}=${TEST_tcpdump_gnb_path}
    ...    ${which_message}=-1
    @{messages_timestamp}    Get Message Field Values from PCAP
    ...    pcap_filepath=${pcap_filepath}
    ...    field_name=frame.time_epoch
    ...    filter=${filter}
    ...    options=${tshark_options}
    ${date}    Convert To String    ${messages_timestamp}[${which_message}]
    ${splitted_date}    Split String    ${date}    separator=.
    Log to console    ${splitted_date}
    [Return]    ${splitted_date}[0]
