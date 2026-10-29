*** Settings ***
Force Tags      CRT    RAN_5G    RAN_5G_FDD    SBTS00    STATE_CONFIGURED
...             CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_FDD_ORAN    RF50

Documentation
...            author:       Marcin Duplaga, marcin.duplaga@nokia.com
...            maintainer:   I_EXT_MN_RAN_VRF_WRO2_7_T03@internal.nsn.com

Resource    ./../../../sim_resources/Krk_regression/ran_L3_SW2_resources/KRK3_resources/krk3_common/main_cls.robot
Resource    resources/5GC001756-common_keywords.robot
Resource    testsuite/Wroclaw/RRM/resources/airphone/5G_SW_WRO_Keywords.robot
Library     ta5g_ue_mobility
Library     ta5g_enb
Library     ta5g_setups_and_teardowns
Library     ta5g_delta
Library     DateTime
Library     ./resources/test_setup_resources.py    WITH NAME    test_setup
Library     testsuite/Wroclaw/RRM/resources/airphone/scripts/dcap_version_checker.py
Library     testsuite/Wroclaw/RRM/resources/airphone/scout_reporting/ScoutMonitor.py

Suite Setup       Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...      AND      Create Suite Scope Variables
...      AND      Start Vm Ethernet Interfaces
...      AND      Add bearers to WTS Config    wts_delta=${DELTA_WTS_BEARERS}    wts_out=${WTS_FILE}
...                                            wts_in=${INPUT_CONFIG_FILE}
...      AND      Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...      AND      Find Scfc and Send Delta Commissioning    scfc_filename=delta_pcmd_nsa_bearer_DCAP.json
...      AND      Check Version Of Dcap And Install If Needed
...      AND      ta5g_egate.Reach Onair    lua_cfg=${WTS_FILE}    check_edaemon_port=True
...      AND      Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    Stop Vm Ethernet Interfaces
...      AND      Roll Delta Back
...               initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
...               delta_scf_filename=${CURDIR}/config/default/delta_pcmd_nsa_bearer_DCAP.json
...      AND      Stop Default Processes And Gather Logs And Compress Logs

Test Setup        Test Case Setup    logs=${LOGS_WITH_DCAP}    log_dir=5GC001756-B_B102_2
Test Teardown     Run Keywords    Restart Scout Monitoring On Test Line If Needed
...      AND      Add Scout External Execution ID To Reporting Portal
...      AND      Test Case Teardown

*** Variables ***
@{DCAP_GNB}             condor5gSyslog
@{DCAP_BTS}             ipCapture
&{DCAP_OPTIONS}         gnb_custom_profile=${DCAP_GNB}    bts_custom_profile=${DCAP_BTS}    start=yes
&{LOGS_WITH_DCAP}       dcap=${DCAP_OPTIONS}    tcpdump_gnb=yes
${WTS_FILE}             ${OUTPUT DIR}/Logs/wts_ho_with_additional_bearers.cfg
${DELTA_WTS_BEARERS}    ${CURDIR}/resources/wts_configs/wts_delta_additional_bearers.cfg
${INPUT_CONFIG_FILE}      ${CURDIR}/resources/wts_configs/basic_setup.cfg
@{tshark_options}    -o    ntrstr.defragment:TRUE    -o    ntrstr.port:49148

*** Test Cases ***
[1]5GC001756-B_B102_2_Timing Advance Trace Record in NSA mode - Contention Based Random Acces
    Start NSA L3 Call    ue_id=11
    Add bearers
    NSA Establish DC bearers
    Start Traffic On Additional Bearers
    Verify NSA UE Traffic Using Bearer Stats    ue_id=11     wait=10s
    Stop NSA L3 Call    ue_id=11
    Sleep    5s    Reason=Wait for PCMD logs update
    ${multiBearer_timestamp}    DateTime.Get Current Date
    Activate TA Testmode
    Start NSA L3 Call    ue_id=11
    Sleep    5s    Reason=Wait for PCMD logs update
    ${intraCellHO_timestamp}    DateTime.Get Current Date
    NSA Intracell HO UE    ue_id=11
    Verify NSA UE Traffic Using Bearer Stats    ue_id=11     wait=10s
    Stop NSA L3 Call    ue_id=11
    ${dcap_files}    Stop and Collect DCAP Trace    log_dir=${TEST_log_dir}/DCAP/
    Set Test Variable    ${dcap_files}
    ${RbRLCMeas_PCMD_records}    Get PCMD Records from PCAP     pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=(nsetapx.DlRadioBearerRlcMeasData_element || nsetapx.UlRadioBearerRlcMeasData_element) && frame.time <= "${multiBearer_timestamp}"
    ...    save_to_file=${TEST_log_dir}/PCMD/rbRLCMeas_PCMD_records.json
    ${all_PCMD_records}    Get PCMD Records from PCAP     pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=nsetapx    save_to_file=${TEST_log_dir}/PCMD/all_PCMD_records.json
    ${initial_TA_PCMD_records}    Get PCMD Records from PCAP     pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=nsetapx.timingAdvanceRecord && nsetapx.initial    save_to_file=${TEST_log_dir}/PCMD/initial_TA_PCMD_records.json
    @{PCMD_Seq_timingAdvanceRecord}       Prepare timingAdvanceRecord Verification List
    @{PCMD_Seq_rbRLCMeasDataRecords}      Prepare RbRLCMeasDataRecords Verification List
    Verify PCMD Records Sequence in Collection    ${initial_TA_PCMD_records}    ${PCMD_Seq_timingAdvanceRecord}
    Verify PCMD Records Sequence in Collection    ${RbRLCMeas_PCMD_records}     ${PCMD_Seq_rbRLCMeasDataRecords}
    Verify Message Count in PCAP    pcap_filepath=${dcap_files}[ipCapture][0]
    ...    filter=nsetapx.DuVendorExtensionRecordDataType == bearerRecord && frame.time >= "${intraCellHO_timestamp}"
    ...    count=0    options=${tshark_options}

*** Keywords ***
Activate TA Testmode
    [Arguments]    ${ue_id}=11
    Log to Console      Activating TA Testmode
    ${cmd}    Set Variable
    ...    ue_ta_nr profile_id\=1 nb_reps_ta_sim\=100 ue_speed\=4 ue_p_delay_max\=500 ue_p_delay_min\=100 ue_p_delay_initial\=350
    ute_wtssim.execute_egate_command    cmd=${cmd}
    ${cmd}    Set Variable
    ...    ue_testmode_set_nr id\=${ue_id} scell\=0 testmode\=ta profile_id\=1 action\=activate
    ute_wtssim.execute_egate_command    cmd=${cmd}

NSA Intracell HO UE
    [Arguments]    ${ue_id}=11
    Perform Intracell Handover And Wait For Confirmation    ue_id=${ue_id}    timeout=10s

Add bearers
    [Arguments]    ${ue_id}=11
    ute_wtssim.execute_egate_command    cmd=bearer_add ue\=${ue_id} id\=1 filter\=1 precedence\=1    pass_regexp=Bearer.*created
    ute_wtssim.execute_egate_command    cmd=bearer_add ue\=${ue_id} id\=3 filter\=3 precedence\=3    pass_regexp=Bearer.*created
    ute_wtssim.execute_egate_command    cmd=bearer_add ue\=${ue_id} id\=5 filter\=5 precedence\=5    pass_regexp=Bearer.*created

NSA Establish DC bearers
    [Arguments]    ${ue_id}=11
    ute_wtssim.execute_egate_command
    ...    cmd=enb_ue_dc_modify ue=${ue_id} bearer_to_add=1 by=enb cause=RN_CauseRadioNetwork_unspecified type=split_scg
    ...    pass_regexp=Successfully reconfigured dual connectivity
    sleep    0.1s    reason=Wait for DC bearer to be established
    ute_wtssim.execute_egate_command
    ...    cmd=enb_ue_dc_modify ue=${ue_id} bearer_to_add=3 by=enb cause=RN_CauseRadioNetwork_unspecified type=split_scg
    ...    pass_regexp=Successfully reconfigured dual connectivity
    sleep    0.1s    reason=Wait for DC bearer to be established
    ute_wtssim.execute_egate_command
    ...    cmd=enb_ue_dc_modify ue=${ue_id} bearer_to_add=5 by=enb cause=RN_CauseRadioNetwork_unspecified type=split_scg
    ...    pass_regexp=Successfully reconfigured dual connectivity

Start Traffic On Additional Bearers
    [Arguments]    ${ue_id}=11
    Start Internal NSA Bidirectional Traffic    ue_id=${ue_id}    drb_id=1    dl_tput=10mbps    ul_tput=10mbps
    Start Internal NSA Bidirectional Traffic    ue_id=${ue_id}    drb_id=3    dl_tput=10mbps    ul_tput=10mbps
    Start Internal NSA Bidirectional Traffic    ue_id=${ue_id}    drb_id=5    dl_tput=10mbps    ul_tput=10mbps

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

Prepare timingAdvanceRecord Verification List
    [Arguments]    ${syslog_filepath}=${dcap_files}[syslog]
    ${allInitialTAvalues}    Get all initialTa Value from GNB Syslog    syslog_filepath=${syslog_filepath}
    ${timingAdvanceRecord1}      Create dictionary
    ...      record_name=timingAdvanceRecord
    ...      initial=${allInitialTAvalues}[0]
    ${timingAdvanceRecord2}      Create dictionary
    ...      record_name=timingAdvanceRecord
    ...      initial=${allInitialTAvalues}[1]
    ${timingAdvanceRecord3}      Create dictionary
    ...      record_name=timingAdvanceRecord
    ...      initial=${allInitialTAvalues}[2]
    ${PCMD_Seq}    Create List    ${timingAdvanceRecord1}    ${timingAdvanceRecord2}    ${timingAdvanceRecord3}
    [Return]    ${PCMD_Seq}

Prepare RbRLCMeasDataRecords Verification List
    ${PCMD_Seq}    Create List
    ${bearerRecords_amount}    Get Amount Of RbRLCMeasDataRecords From JSON File
    ...    json_file=${TEST_log_dir}/PCMD/rbRLCMeas_PCMD_records.json
    ${amount_of_middle_records}    Evaluate    ${bearerRecords_amount} - 2
    ${dlRbRlcMeasRecord_first}      Create dictionary
    ...    record_name=dlRbRlcMeasRecord
    ...    Item 0.*endMarker=0    Item 0.*drb_Id=4    Item 0.*dataCollectionDuration=[0-9]+
    ...    Item 0.*timeOfUePduTx=[0-9]+    Item 0.*sumOfRlcPduTxBytes=[0-9]+
    ${ulRbRlcMeasRecord_first}      Create dictionary
    ...    record_name=ulRbRlcMeasRecord
    ...    Item 0.*endMarker=0    Item 0.*drb_Id=4    Item 0.*dataCollectionDuration=[0-9]+
    ...    Item 0.*timeOfUePduRx=[0-9]+    Item 0.*sumOfRlcPduRxBytes=[0-9]+
    Append To List    ${PCMD_Seq}    ${dlRbRlcMeasRecord_first}    ${ulRbRlcMeasRecord_first}
    FOR    ${RbRlcMeasRecord_middle}    IN RANGE    1    ${amount_of_middle_records}+1
        ${dlRbRlcMeasRecord_middle}      Create dictionary
        ...    record_name=dlRbRlcMeasRecord
        ...    Item 0.*endMarker=0    Item 0.*drb_Id=4    Item 0.*dataCollectionDuration=[0-9]+
        ...    Item 0.*timeOfUePduTx=[0-9]+    Item 0.*sumOfRlcPduTxBytes=[0-9]+
        ...    Item 1.*endMarker=0    Item 1.*drb_Id=7    Item 1.*dataCollectionDuration=[0-9]+
        ...    Item 1.*timeOfUePduTx=[0-9]+    Item 1.*sumOfRlcPduTxBytes=[0-9]+
        ...    Item 2.*endMarker=0    Item 2.*drb_Id=3    Item 2.*dataCollectionDuration=[0-9]+
        ...    Item 2.*timeOfUePduTx=[0-9]+    Item 2.*sumOfRlcPduTxBytes=[0-9]+
        ...    Item 3.*endMarker=0    Item 3.*drb_Id=5    Item 3.*dataCollectionDuration=[0-9]+
        ...    Item 3.*timeOfUePduTx=[0-9]+    Item 3.*sumOfRlcPduTxBytes=[0-9]+
        ${ulRbRlcMeasRecord_middle}      Create dictionary
        ...    record_name=ulRbRlcMeasRecord
        ...    Item 0.*endMarker=0    Item 0.*drb_Id=4    Item 0.*dataCollectionDuration=[0-9]+
        ...    Item 0.*timeOfUePduRx=[0-9]+    Item 0.*sumOfRlcPduRxBytes=[0-9]+
        ...    Item 1.*endMarker=0    Item 1.*drb_Id=7    Item 1.*dataCollectionDuration=[0-9]+
        ...    Item 1.*timeOfUePduRx=[0-9]+    Item 1.*sumOfRlcPduRxBytes=[0-9]+
        ...    Item 2.*endMarker=0    Item 2.*drb_Id=3    Item 2.*dataCollectionDuration=[0-9]+
        ...    Item 2.*timeOfUePduRx=[0-9]+    Item 2.*sumOfRlcPduRxBytes=[0-9]+
        ...    Item 3.*endMarker=0    Item 3.*drb_Id=5    Item 3.*dataCollectionDuration=[0-9]+
        ...    Item 3.*timeOfUePduRx=[0-9]+    Item 3.*sumOfRlcPduRxBytes=[0-9]+
        Append To List    ${PCMD_Seq}    ${dlRbRlcMeasRecord_middle}    ${ulRbRlcMeasRecord_middle}
    END
    ${dlRbRlcMeasRecord_last}      Create dictionary
    ...    record_name=dlRbRlcMeasRecord
    ...    Item 0.*endMarker=1    Item 0.*drb_Id=4    Item 0.*dataCollectionDuration=[0-9]+
    ...    Item 0.*timeOfUePduTx=[0-9]+    Item 0.*sumOfRlcPduTxBytes=[0-9]+
    ...    Item 1.*endMarker=1    Item 1.*drb_Id=7    Item 1.*dataCollectionDuration=[0-9]+
    ...    Item 1.*timeOfUePduTx=[0-9]+    Item 1.*sumOfRlcPduTxBytes=[0-9]+
    ...    Item 2.*endMarker=1    Item 2.*drb_Id=3    Item 2.*dataCollectionDuration=[0-9]+
    ...    Item 2.*timeOfUePduTx=[0-9]+    Item 2.*sumOfRlcPduTxBytes=[0-9]+
    ...    Item 3.*endMarker=1    Item 3.*drb_Id=5    Item 3.*dataCollectionDuration=[0-9]+
    ...    Item 3.*timeOfUePduTx=[0-9]+    Item 3.*sumOfRlcPduTxBytes=[0-9]+
    ${ulRbRlcMeasRecord_last}      Create dictionary
    ...    record_name=ulRbRlcMeasRecord
    ...    Item 0.*endMarker=1    Item 0.*drb_Id=4    Item 0.*dataCollectionDuration=[0-9]+
    ...    Item 0.*timeOfUePduRx=[0-9]+    Item 0.*sumOfRlcPduRxBytes=[0-9]+
    ...    Item 1.*endMarker=1    Item 1.*drb_Id=7    Item 1.*dataCollectionDuration=[0-9]+
    ...    Item 1.*timeOfUePduRx=[0-9]+    Item 1.*sumOfRlcPduRxBytes=[0-9]+
    ...    Item 2.*endMarker=1    Item 2.*drb_Id=3    Item 2.*dataCollectionDuration=[0-9]+
    ...    Item 2.*timeOfUePduRx=[0-9]+    Item 2.*sumOfRlcPduRxBytes=[0-9]+
    ...    Item 3.*endMarker=1    Item 3.*drb_Id=5    Item 3.*dataCollectionDuration=[0-9]+
    ...    Item 3.*timeOfUePduRx=[0-9]+    Item 3.*sumOfRlcPduRxBytes=[0-9]+
    Append To List    ${PCMD_Seq}    ${dlRbRlcMeasRecord_last}    ${ulRbRlcMeasRecord_last}
    [Return]    ${PCMD_Seq}

Get Amount Of RbRLCMeasDataRecords From JSON File
    [Arguments]    ${json_file}
    ${result}    Run Process And Expect Success    grep  ulRbRlcMeasRecord  ${json_file}
    ${ulRbRlcMeasRecord_amount}    Get Line Count    ${result.stdout}
    ${result}    Run Process And Expect Success    grep  dlRbRlcMeasRecord  ${json_file}
    ${dlRbRlcMeasRecord_amount}    Get Line Count    ${result.stdout}
    Should Be Equal    ${ulRbRlcMeasRecord_amount}    ${dlRbRlcMeasRecord_amount}
    [Return]    ${ulRbRlcMeasRecord_amount}

Get all initialTa Value from GNB Syslog
    [Arguments]    ${syslog_filepath}=${dcap_files}[syslog]
    ${all_initialTa}    Create List
    ${initialTA_from_syslog}    Create List
    FOR    ${syslog}    IN    @{syslog_filepath}
        ${cmd}    Set Variable
        ...    grep -o 'initialTa[\:=][0-9]*' '${syslog}' | cut -d ":" -f2 | cut -d "=" -f2
        ${rc}    ${output}    Run And Return Rc And Output    ${cmd}
        @{splitted_output}    Split String    ${output}    \n
        ${initialTA_from_syslog}    Combine Lists    ${initialTA_from_syslog}    ${splitted_output}
    END
    FOR    ${initialTA}    IN    @{initialTA_from_syslog}
      ${NTA}    Evaluate    ${initialTA} * 16
      ${NTA_string}    Convert to string     ${NTA}
      Append To list    ${all_initialTa}    ${NTA_string}
    END
    [Return]    ${all_initialTa}
