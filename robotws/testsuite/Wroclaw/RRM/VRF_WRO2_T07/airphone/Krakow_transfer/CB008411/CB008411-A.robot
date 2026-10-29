*** Settings ***
Force Tags      CRT    RAN_5G    RAN_5G_TDD    SBTS00    STATE_CONFIGURED    RF50
...             CLOUD_5G_I_LO_AP_LO      VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Documentation
...             author:        Nelsandro Sampaio, nelsandro.sampaio@nokia.com
...             maintainer:    I_EXT_MN_RAN_VRF_WRO2_7_T03@internal.nsn.com

Resource        ./CB008411_common.robot
Resource        ./CB008911_common.robot
Resource        ../../../../resources/airphone/5G_SW_WRO_Keywords.robot
Library         ../../../../resources/airphone/scripts/dcap_version_checker.py
Library         ta5g_ue_mobility
Library         ta5g_enb
Library         ta5g_setups_and_teardowns
Library         ta5g_delta
Library         ta5g_egate
Library         ../../../../resources/airphone/scripts/SwconfigFlagsChecker.py
Library         ../../../../resources/airphone/scout_reporting/ScoutMonitor.py

Suite Setup       Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...      AND      Create Suite Scope Variables
...      AND      Start Vm Ethernet Interfaces
...      AND      Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...      AND      Find Scfc and Send Delta Commissioning
...               scfc_filename=Delta_CU_subscriber_true_pcmd_true_pcmd_reporting_true.json
...      AND      Check Version Of Dcap And Install If Needed
...      AND      SwconfigFlagsChecker.Modify Flags In Swconfig    ${RND_FLAGS}
...      AND      Reach Onair    lua_cfg=${WTS_FILE}    check_edaemon_port=True
...      AND      Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Testline Teardown

Test Setup        Test Case Setup    logs=${LOGS_WITH_DCAP}    radio_res=yes
Test Teardown     Run Keywords    Restart Scout Monitoring On Test Line If Needed
...      AND      Add Scout External Execution ID To Reporting Portal
...      AND      Test Case Teardown    check_radio_res=yes    oam_logs=yes    sosreport=yes

*** Variables ***
@{IP_ADDR_SIM_GNB}          eth3:10.0.1.3/24    eth3:10.44.76.28/24
${WTS_FILE}                 ${CURDIR}/config/wts_LO.cfg
@{DCAP_GNB}                 condor5gSyslog
@{DCAP_BTS}                 ipCapture
&{DCAP_OPTIONS}             gnb_custom_profile=${DCAP_GNB}    bts_custom_profile=${DCAP_BTS}    start=yes
&{LOGS_WITH_DCAP}           dcap=${DCAP_OPTIONS}    tcpdump_gnb=yes
@{RND_FLAGS}          0x1003F=1   # AaSysLogInputLevel
...                   0x10040=1   # AaSysLogOutputLevel
...                   0x10041=1   # ERadCcs_AaSysLogOutputMode
...                   0x590072=1  # CP-RT DEBUG level logs
...                   0x66001b=1  # CP-NRT DEBUG level logs
...                   0x890003=0  # CP-UE TRACE level logs
...                   0x890004=1  # CP-CELL DEBUG level logs

*** Test Cases ***
# Test transferred from Krakow, will be rewritten
[1]CB008411-SR-A_B102_9_Buffered_PCMD_records_sent_from_cu-cp_in_sba_session_initiated_by_ngap_ics
    [Documentation]
    ...     This user scenario validates the PCMD records in subscriber trace equipment trace content sent by gNB-CU-CP
    ...     in subscriber trace sessions triggered by NGAP: Initial Context Setup Request
    Enable Trace Activation IE For 6 UEs In Which 3 Of Them Are Without Vse And Start Traffic
    Verify For 6 UEs That 80mbps DL And 5mbps UL Traffic Is Running And Stable For 60 Period
    Stop Traffic And Deregister 6 UEs
    ${dcap_files}    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    ${records_sba_mba}       Get PCMD Records from PCAP
    ...    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    save_to_file=${TEST_log_dir}/PCMD/PCMD_records_traceMessage.json
    ...    pattern=nsetapx.*TraceMessage_tree
    ${SBA_TRACE_ACT_FILE}    Filter PCMD Records in Collection
    ...    collected_records=${records_sba_mba}
    ...    traceActivationType=1
    ${SBA_PCMD_FILE_UE1}    Filter PCMD Records For UE    trace_id=1    records=${SBA_TRACE_ACT_FILE}    ue_id=1
    ${SBA_PCMD_FILE_UE2}    Filter PCMD Records For UE    trace_id=2    records=${SBA_TRACE_ACT_FILE}    ue_id=2
    ${SBA_PCMD_FILE_UE3}    Filter PCMD Records For UE    trace_id=3    records=${SBA_TRACE_ACT_FILE}    ue_id=3
    ${SBA_PCMD_FILE_UE4}    Filter PCMD Records For UE    trace_id=4    records=${SBA_TRACE_ACT_FILE}    ue_id=4
    ${SBA_PCMD_FILE_UE5}    Filter PCMD Records For UE    trace_id=5    records=${SBA_TRACE_ACT_FILE}    ue_id=5
    ${SBA_PCMD_FILE_UE6}    Filter PCMD Records For UE    trace_id=6    records=${SBA_TRACE_ACT_FILE}    ue_id=6
    Verify All CU-CP SBA PCMD Records Triggered By Initial Context Setup Request For UE    ue_id=1
    ...     records=${SBA_PCMD_FILE_UE1}     which_message=0
    Verify All CU-CP SBA PCMD Records Triggered By Initial Context Setup Request For UE    ue_id=2
    ...     records=${SBA_PCMD_FILE_UE2}     which_message=1
    Verify All CU-CP SBA PCMD Records Triggered By Initial Context Setup Request For UE    ue_id=3
    ...     records=${SBA_PCMD_FILE_UE3}     which_message=2
    Should Be Empty     ${SBA_PCMD_FILE_UE4}    msg=SBA_PCMD file is not empty for UE4
    Should Be Empty     ${SBA_PCMD_FILE_UE5}    msg=SBA_PCMD file is not empty for UE5
    Should Be Empty     ${SBA_PCMD_FILE_UE6}    msg=SBA_PCMD file is not empty for UE6