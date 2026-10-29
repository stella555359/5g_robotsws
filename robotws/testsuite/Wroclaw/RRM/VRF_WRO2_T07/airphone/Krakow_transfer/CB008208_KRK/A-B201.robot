*** Settings ***
Force Tags      CRT    RAN_5G    RAN_5G_TDD    SBTS00    RF50
...             CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    STATE_CONFIGURED

Documentation
...            author:       Michal Sagan, michal.sagan@nokia.com
...            maintainer:   I_EXT_MN_RAN_VRF_WRO2_7_T03@internal.nsn.com

Resource    ../../../../sim_resources/Krk_regression/ran_L3_SW2_resources/KRK3_resources/krk3_common/main_cls.robot
Resource    ../../../../resources/airphone/5G_SW_WRO_Keywords.robot
Resource    resources/common.robot
Library     ta5g_ue_mobility
Library     ta5g_enb
Library     ta5g_setups_and_teardowns
Library     ta5g_delta
Library     ../../../../resources/airphone/scout_reporting/ScoutMonitor.py

Suite Setup       Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...      AND      Create Suite Scope Variables
...      AND      common.Start Vm Ethernet Interfaces
...      AND      Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...      AND      Find Scfc and Send Delta Commissioning    scfc_filename=CB008208.json
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
${WTS_FILE}           /opt/wts/latest/basic_setup.cfg
@{DCAP_GNB}           condor5gSyslog
@{DCAP_BTS}           ipCapture
&{DCAP_OPTIONS}       gnb_custom_profile=${DCAP_GNB}    bts_custom_profile=${DCAP_BTS}    start=yes
&{LOGS_WITH_DCAP}     dcap=${DCAP_OPTIONS}    tcpdump_gnb=yes
@{tshark_options}     -o    ntrstr.defragment:TRUE    -o    ntrstr.port:49148

*** Test Cases ***
# Test transferred from Krakow, will be rewritten
[1]CB008208-5G-A_1_B201_DU_UE_Context_Setup_reporting_during_Intra-DU_PSCell_change_for_NSA_without_SRB3
    Start NSA L3 Call    ue_id=101
    Verify NSA UE Traffic Using Bearer Stats    ue_id=101     wait=10s
    Perform Intra-GNB X2 NSA Handover To Target PCI    ue_id=101    target_pci=51    event=A3
    Verify NSA UE Traffic Using Bearer Stats    ue_id=101     wait=10s
    Stop NSA L3 Call    ue_id=101
    ${dcap_files}    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    Set Test Variable    ${dcap_files}
    ${all_PCMD_records}    Get PCMD Records from PCAP     pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=nsetapx    save_to_file=${TEST_log_dir}/PCMD/all_PCMD_records.json
    @{UeCtxSetupTraceRecords}     Prepare UeCtxSetupTraceRecords Verification List
    @{DuBearerTraceRecords}       Prepare DuBearerTraceRecords Verification List
    Verify PCMD Records Sequence in Collection    ${all_PCMD_records}    ${UeCtxSetupTraceRecords}
    Verify PCMD Records Sequence in Collection    ${all_PCMD_records}    ${DuBearerTraceRecords}

*** Keywords ***
Prepare UeCtxSetupTraceRecords Verification List
    ${ueCtxSetupReqRcvTime}     Get Message Timestamp From Pcap     filter=f1ap.UEContextSetupRequest_element    which_message=0
    ${ueCtxSetupCmplSndTime}    Get Message Timestamp From Pcap     filter=f1ap.UEContextSetupResponse_element   which_message=0
    ${cu_ue_f1ap_id}    Get Message Field Values from PCAP
    ...    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    field_name=f1ap.GNB_CU_UE_F1AP_ID
    ...    filter=f1ap.UEContextSetupRequest_element
    ${du_ue_f1ap_id}    Get Message Field Values from PCAP
    ...    pcap_filepath=${TEST_tcpdump_gnb_path}
    ...    field_name=f1ap.GNB_DU_UE_F1AP_ID
    ...    filter=f1ap.UEContextSetupResponse_element
    ${UeCtxSetupTraceRecord_attach}      Create dictionary
    ...    record_name=ueCtxSetupRecord
    ...    result=0
    ...    gnb_cu_ue_f1ap_Id=${cu_ue_f1ap_id}[0]      gnb_du_ue_f1ap_Id=${du_ue_f1ap_id}[0]
    ...    ueCtxSetupReqRcvTime.*seconds=${ueCtxSetupReqRcvTime}      ueCtxSetupReqRcvTime.*useconds=[0-9]+
    ...    ueCtxSetupCmplSndTime.*seconds=${ueCtxSetupCmplSndTime}    ueCtxSetupCmplSndTime.*useconds=[0-9]+
    ...    ssbSubcarrierSpacing=1    dlCarrierBandwidthTdd=28    absoluteFrequencySsb=636576
    ${UeCtxSetupTraceRecord_ho}      Create dictionary
    ...    record_name=ueCtxSetupRecord
    ...    result=0
    ...    gnb_cu_ue_f1ap_Id=${cu_ue_f1ap_id}[0]      gnb_du_ue_f1ap_Id=${du_ue_f1ap_id}[0]
    ...    ssbSubcarrierSpacing=1    dlCarrierBandwidthTdd=28    absoluteFrequencySsb=636576
    ${PCMD_Seq}    Create List    ${UeCtxSetupTraceRecord_attach}    ${UeCtxSetupTraceRecord_ho}
    [Return]    ${PCMD_Seq}

Prepare DuBearerTraceRecords Verification List
    ${DuBearerTraceRecords_attach}      Create dictionary
    ...    record_name=bearerRecord
    ...    trigger=1    setupBearers=1    drb_Id=4
    ...    qci=9    priorityLevel=15
    ...    preemptionCapability=0    preemptionVulnerability=0
    ${DuBearerTraceRecords_ho}      Create dictionary
    ...    record_name=bearerRecord
    ...    trigger=3    setupBearers=1    drb_Id=4
    ...    qci=9    priorityLevel=15
    ...    preemptionCapability=0    preemptionVulnerability=0
    ${PCMD_Seq}    Create List    ${DuBearerTraceRecords_attach}    ${DuBearerTraceRecords_ho}
    [Return]    ${PCMD_Seq}

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

Change UE NSA Capabilities In WTS File
    Create Directory       ${WTS_DIR}
    wtscfg.Load Wts Cfg    /opt/wts/latest/basic_setup.cfg
    wtscfg.Modify   ue_param id=11    dual_conn=eutra_nr ue_eutra_nr_capabilities=${UE11_CAPS}
    wtscfg.Save Wts Cfg    ${WTS_FILE}
