*** Settings ***
Library    OperatingSystem
Library    Collections
Library    BuiltIn
Library    String
Resource    Resources/5GC000746_common_keyword.robot
Variables    Resources/5GC000746_A_variables.py

Documentation
...   author: Chen Tong
...   contact: tong.chen@nokia-sbell.com
...   squad group: SG_02

Force Tags    5G_RRM
...    PY36

Suite Setup     Suite preparation

*** Variables ***
@{amfs}    feng_amf    shen_amf    han_amf    sui_amf    zhou_amf    liang_amf    tang_amf    chu_amf

&{fault_61524}    faultId=${61524}    source=-    #faultId:SSH_ENABLED  source:RU1
&{fault_61652}    faultId=${61652}    source=-    #faultId:R&D_SERVICE_PORT_ENABLED  source:RU1


*** Test Cases ***
[1][1.0] 5GC000746_A_001_Verify if Cell can be Onair when actCMAS is set to true
    [Tags]    case1    CIT_TRUNK    CIT_22R3    CIT_22R2    CIT_22R4
    [Setup]    5GC000746 Case Setup
    ssh.Disconnect    connection=ASIK Master
    Commission Scf with actCMAS False
    Connect to Common Unit Master
    Connect to Common Unit Slave
    ${ngap_log}    ${bip_log}    Trigger CMAS Notification and Capture Logs
    ...                                         amf=${current_amf}
    ...                                         warning_area_list_id=${warning_area_list}[warning_area_cgi_list_1cell]
    Check Error Ind Message with Message Not Compatiable With Receiver State Cause    ngap_log=${ngap_log}    bip_log=${bip_log}
    COAM Update several parameters via webUI    parameters_to_update_via_webui=${PARAM_746_ENABLE_CMAS}
    ...                                         download_dir=${TS_CASE_LOG_PATH}
    ...                                         is_need_to_check_validation_errors=${False}
    wait until keyword succeeds    1min    2sec    Connect to gnb coam via ssl
    Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT_LIST}
    COAM Wait for gnb ready and cell setup    gnb_type='SA'
    [Teardown]    5GC000746 Case Teardown

[1][1.0] 5GC000746_A_008_Verify WRITE-REPLACE WARNING REQUEST with MessageIdentifier is not identified CMAS
    [Tags]    case8    CIT_TRUNK    CIT_22R3    CIT_22R2    CIT_22R4
    [Setup]    5GC000746 Case Setup
    COAM Update several parameters via webUI    parameters_to_update_via_webui=${PARAM_746_ENABLE_CMAS}
    ...                                         download_dir=${TS_CASE_LOG_PATH}
    ...                                         is_need_to_check_validation_errors=${False}
    ${ngap_log}    ${bip_log}    Trigger CMAS Notification and Capture Logs
    ...                                         amf=${current_amf}
    ...                                         warning_area_list_id=${warning_area_list}[warning_area_cgi_list_1cell]
    ...                                         repetition_period=${0}
    ...                                         number_of_broadcasts_requested=${2}
    Check Write Replace Warning Response without Broadcaset Completed Area List    ngap_log=${ngap_log}    bip_log=${bip_log}
    [Teardown]    5GC000746 Case Teardown

[1][1.0] 5GC000746_A_009_Verify WRITE-REPLACE WARNING REQUEST with WarningAreaList.nR-CGIListForWarning which is found in serving gNB
    [Tags]    case9    CIT_TRUNK    CIT_22R3    CIT_22R2    CIT_22R4
    [Setup]    5GC000746 Case Setup
    ${ngap_log}    ${bip_log}    Trigger CMAS Notification and Capture Logs
    ...                                         amf=${current_amf}
    ...                                         warning_area_list_id=${warning_area_list}[warning_area_cgi_list_1cell]
    ...                                         repetition_period=${0}
    ...                                         number_of_broadcasts_requested=${1}
    Check Complete Procedure for CMAS broadcasting    ngap_log=${ngap_log}
    ...                                               bip_log=${bip_log}
    ...                                               repetition_period=${0}
    ...                                               number_of_broadcasts_requested=${1}
    [Teardown]    5GC000746 Case Teardown

[1][1.0] 5GC000746_A_013_Verify WRITE-REPLACE WARNING REQUEST withWarningAreaList.nR-CGIListForWarning which is not found in serving gNB
    [Tags]    case13    CIT_TRUNK    CIT_22R3    CIT_22R2    CIT_22R4
    [Setup]    5GC000746 Case Setup
    ${ngap_log}    ${bip_log}    Trigger CMAS Notification and Capture Logs
    ...                                         amf=${current_amf}
    ...                                         warning_area_list_id=${warning_area_list}[warning_area_cgi_list_2cell]
    Check Write Replace Warning Response without Broadcaset Completed Area List    ngap_log=${ngap_log}    bip_log=${bip_log}
    [Teardown]    5GC000746 Case Teardown

[1][1.0] 5GC000746_A_015_Verify WRITE-REPLACE WARNING REQUEST with WarningAreaList.emergencyAreaIDList which is not configured in serving gNB
    [Tags]    case15    CIT_TRUNK    CIT_22R3    CIT_22R2    CIT_22R4
    [Setup]    5GC000746 Case Setup
    ${ngap_log}    ${bip_log}    Trigger CMAS Notification and Capture Logs
    ...                                         amf=${current_amf}
    ...                                         warning_area_list_id=${warning_area_list}[unknown_warning_area_emergency_list]
    Check Write Replace Warning Response without Broadcaset Completed Area List    ngap_log=${ngap_log}    bip_log=${bip_log}
    [Teardown]    5GC000746 Case Teardown

[1][1.0] 5GC000746_A_026_Verify CMAS coded 4 pages broadcast in RRC_CONNECTED state
    [Tags]    case26    CIT_TRUNK    CIT_22R3    CIT_22R2    CIT_22R4
    [Setup]    5GC000746 Case Setup
    COAM commission scf and wait cell setup    scf_file_path=${sa_rf64_scf_path}
    ${ue_type}    ue.translate_power_ue_type_from_testline
    Sleep    30s
    UE attach and Check Ciphering algorithm    ue_type=${ue_type}     cipheringAlgorithm=2
    COAM Update several parameters via webUI    parameters_to_update_via_webui=${PARAM_1936_HA_543}
    ...                                         download_dir=${TS_CASE_LOG_PATH}
    ...                                         is_need_to_check_validation_errors=${False}
    UE attach and Check Ciphering algorithm    ue_type=${ue_type}     cipheringAlgorithm=0
    Prepare for Check SIB    ue_type=${ue_type}
    Log to console    start to trigger CMAS
    ${ngap_log_1}    ${bip_log_1}    Trigger CMAS Notification and Capture Logs
    ...                                         amf=${current_amf}
    ...                                         warning_area_list_id=${warning_area_list}[warning_area_cgi_list_1cell]
    ...                                         cmas_file=${long_cmas}
    ...                                         message_identifier=4370
    ...                                         serial_number=31664
    ...                                         number_of_broadcasts_requested=${0}
    ${ngap_log_2}    ${bip_log_2}    Trigger CMAS Notification and Capture Logs
    ...                                         amf=${current_amf}
    ...                                         warning_area_list_id=${warning_area_list}[warning_area_cgi_list_1cell]
    ...                                         cmas_file=${short_cmas}
    ...                                         message_identifier=4370
    ...                                         serial_number=31680
    ...                                         number_of_broadcasts_requested=${0}
    spark.stop_log    ue_alias=UE_0    logname=${TS_CASE_LOG_PATH}/uelog_sigspark_RRC_CONNECTED_UE0.xml
    ${wmc1}    ${wac1}    Check Complete Procedure for CMAS broadcasting    ngap_log=${ngap_log_1}
    ...                                                                     bip_log=${bip_log_1}
    ...                                                                     serial_number=31664
    ...                                                                     message_identifier=4370
    ...                                                                     number_of_broadcasts_requested=${0}
    ${wmc2}    ${wac2}    Check Complete Procedure for CMAS broadcasting    ngap_log=${ngap_log_2}
    ...                                                                     bip_log=${bip_log_2}
    ...                                                                     serial_number=31680
    ...                                                                     message_identifier=4370
    ...                                                                     number_of_broadcasts_requested=${0}
    ...                                                                     no_wac=${True}
    Check UE Log for SIB8    ue_type=${ue_type}    bip_log=${bip_log_1}    wmc=${wmc1}    wac=${wac1}
    ...                      message_identifier=4370    serial_number=31664
    Check UE Log for SIB8    ue_type=${ue_type}    bip_log=${bip_log_2}    wmc=${wmc2}    wac=${wac2}
    ...                      message_identifier=4370    serial_number=31680
    Prepare for Check SIB    ue_type=${ue_type}
    Sleep    20s
    spark.stop_log    ue_alias=UE_0    logname=${TS_CASE_LOG_PATH}/uelog1_sigspark_RRC_CONNECTED_UE0.xml
    Check UE Log for SIB8    ue_type=${ue_type}    bip_log=${bip_log_1}
    ...                      wmc=${wmc1}    wac=${wac1}    logname=${TS_CASE_LOG_PATH}/uelog1_sigspark_RRC_CONNECTED_UE0.xml
    ...                      message_identifier=4370    serial_number=31664
    Check UE Log for SIB8    ue_type=${ue_type}    bip_log=${bip_log_2}
    ...                      wmc=${wmc2}    wac=${wac2}    logname=${TS_CASE_LOG_PATH}/uelog1_sigspark_RRC_CONNECTED_UE0.xml
    ...                      message_identifier=4370    serial_number=31680
    [Teardown]    5GC000746 Case Teardown

[1][1.0] 5GC000746_A_030_Verify cell locked while CMAS broadcast ongoing
    [Tags]    case30    CIT_TRUNK    CIT_22R3    CIT_22R2    CIT_22R4
    [Setup]    5GC000746 Case Setup
    ${ngap_log_cmas}    ${bip_log_cmas}    Trigger CMAS Notification and Capture Logs
    ...                                         amf=${current_amf}
    ...                                         warning_area_list_id=${warning_area_list}[warning_area_cgi_list_1cell]
    ...                                         number_of_broadcasts_requested=${0}
    Check Complete Procedure for CMAS broadcasting    ngap_log=${ngap_log_cmas}
    ...                                               bip_log=${bip_log_cmas}
    ...                                               number_of_broadcasts_requested=${0}
    ${ngap_name}    Start NGAP and Bip Logs Capture
    wait until keyword succeeds    1min    2sec    Connect to gnb coam via ssl
    Perform cell lock via rest api
    Wait Until Keyword Succeeds   5 min  5 sec   Cell Should Be Locked
    ${ngap_log_lock}    ${bip_log_lock}    Stop NGAP and Bip Logs Capture and Download Logs    ngap_name=${ngap_name}
    Check PWS Failure Indication Message with PWSFailedCellIDList IE    ngap_log=${ngap_log_lock}
    wait until keyword succeeds    1min    2sec    Connect to gnb coam via ssl
    Perform cell unlock via rest api
    COAM Wait for gnb ready and cell setup    gnb_type='SA'
    Connect to Common Unit Master
    Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT_LIST}
    Check CMAS Broadcasting is Interrupted
    [Teardown]    5GC000746 Case Teardown

[1][1.0] 5GC000746_A_031_Verify change emergencyAreaId while CMAS broadcast ongoing
    [Tags]    case31    CIT_TRUNK    CIT_22R3    CIT_22R2    CIT_22R4
    [Setup]    5GC000746 Case Setup
    ${ngap_log}    ${bip_log}    Trigger CMAS Notification and Capture Logs
    ...                                         amf=${current_amf}
    ...                                         warning_area_list_id=${warning_area_list}[warning_area_emergency_list]
    ...                                         number_of_broadcasts_requested=${0}
    ${wmc}    ${wac}    Check Complete Procedure for CMAS broadcasting    ngap_log=${ngap_log}
    ...                                                                   bip_log=${bip_log}
    ...                                                                   number_of_broadcasts_requested=${0}
    COAM Update Emergency Area ID List via webUI    param_emergency_area_id_list=${PARAM_746_EMERGENCY_AREA_ID_LIST_2[0]}
    wait until keyword succeeds    1min    2sec    Connect to gnb coam via ssl
    COAM Check GNB cell on air    connection=GNB_OAM
    COAM Update several parameters via webUI    parameters_to_update_via_webui=${PARAM_746_DISABLE_CMAS}
    ...                                         download_dir=${TS_CASE_LOG_PATH}
    ...                                         is_need_to_check_validation_errors=${False}
    #Bip Capture with gnbMirroring scripts with retry    syscom_mirroring=false
    Start Bip Log with Suitable Means    target_file_name=l1l2bip_log_emergency
    Sleep    10s
    #${bip_log}    Stop BIP capture on ASIK if needed and download BIP Logs to testPC    log_path=${OUTPUT_DIR}
    ${bip_log}    Stop Bip Log with Suitable Means    target_file_name=l1l2bip_log_emergency
    Check Complete Procedure in BIP Log    bip_log=${bip_log[0]}
    ...                                    wmc=${wmc}
    ...                                    wac=${wac}
    ...                                    number_of_broadcasts_requested=${0}
    COAM Update Emergency Area ID List via webUI    param_emergency_area_id_list=${PARAM_746_EMERGENCY_AREA_ID_LIST_1[0]}
    COAM Update several parameters via webUI    parameters_to_update_via_webui=${PARAM_746_ENABLE_CMAS}
    ...                                         download_dir=${TS_CASE_LOG_PATH}
    ...                                         is_need_to_check_validation_errors=${False}
    csn.Disconnect    connection=${cbctest_alias}
    Connect to Cbctest
    ${ngap_log}    ${bip_log}    Trigger CMAS Notification and Capture Logs
    ...                                         amf=${current_amf}
    ...                                         warning_area_list_id=${warning_area_list}[warning_area_cgi_list_1cell]
    ...                                         number_of_broadcasts_requested=${0}
    Check Complete Procedure for CMAS broadcasting    ngap_log=${ngap_log}
    ...                                               bip_log=${bip_log}
    ...                                               number_of_broadcasts_requested=${0}
    wait until keyword succeeds    1min    2sec    Connect to gnb coam via ssl
    Perform cell lock via rest api
    Wait Until Keyword Succeeds   5 min  5 sec   Cell Should Be Locked
    Perform cell unlock via rest api
    COAM Wait for gnb ready and cell setup    gnb_type='SA'
    Connect to Common Unit Master
    Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT_LIST}
    [Teardown]    5GC000746 Case Teardown

[1][1.0] 5GC000746_A_032_Verify counter NNGCC_WRWR_REQ_RECD
    [Tags]    case32
    [Setup]    5GC000746 Case Setup
    ssh.Disconnect    connection=ASIK Master
    Perform BTS Site Reset
    Sleep    5min
    COAM Wait for gnb ready and cell setup    gnb_type='SA'
    Connect to Common Unit Master
    Connect to Common Unit Slave
    FOR  ${item}  IN RANGE  5
        Trigger CMAS Notification and Capture Logs    amf=${current_amf}
        ...                                           warning_area_list_id=${warning_area_list}[warning_area_cgi_list_1cell]
        ...                                           serial_number=${item}
    END
    Sleep    6min
    ${cnt_list}    COAM Get BTS Counters via webUI    counter_id=${COUNTERS_746[0]}[counter_id]
    ${counter_sum}    Sum Value in Counter list    cnt_list=${cnt_list}
    Should Be Equal    ${counter_sum}    ${5}
    [Teardown]    5GC000746 Case Teardown

[1][1.0] 5GC000746_A_033_Verify counter NNGCC_WRWR_RES_SENT
    [Tags]    case33    CIT_TRUNK    CIT_22R3    CIT_22R2    CIT_22R4
    [Setup]    5GC000746 Case Setup
    Perform BTS Site Reset
    Sleep    5min
    COAM Wait for gnb ready and cell setup    gnb_type='SA'
    5GC000746 Case Reconnect
    FOR  ${item}  IN RANGE  5
        Trigger CMAS Notification and Capture Logs    amf=${current_amf}
        ...                                           warning_area_list_id=${warning_area_list}[warning_area_cgi_list_1cell]
        ...                                           serial_number=${item}
        ...                                           number_of_broadcasts_requested=${0}
        wait until keyword succeeds    1min    2sec    Connect to gnb coam via ssl
        Perform cell lock via rest api
        Wait Until Keyword Succeeds   5 min  5 sec   Cell Should Be Locked
        Perform cell unlock via rest api
        COAM Wait for gnb ready and cell setup    gnb_type='SA'
        5GC000746 Case Reconnect
        Wait Until Keyword Succeeds   5 min  5 sec   Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT_LIST}
    END
    Sleep    8min
    ${cnt_list}    COAM Get BTS Counters via webUI    counter_id=${COUNTERS_746[0]}[counter_id]
    ${counter_sum}    Sum Value in Counter list    cnt_list=${cnt_list}
    Should Be Equal    ${counter_sum}    ${5}
    ${cnt_list}    COAM Get BTS Counters via webUI    counter_id=${COUNTERS_746[1]}[counter_id]
    ${counter_sum}    Sum Value in Counter list    cnt_list=${cnt_list}
    Should Be Equal    ${counter_sum}    ${5}
    ${cnt_list}    COAM Get BTS Counters via webUI    counter_id=${COUNTERS_746[2]}[counter_id]
    ${counter_sum}    Sum Value in Counter list    cnt_list=${cnt_list}
    Should Be Equal    ${counter_sum}    ${5}
    [Teardown]    5GC000746 Case Teardown

[1][1.0] 5GC000746_A_035_Verify WRITE-REPLACE WARNING REQUEST when actCMAS is set to false
    [Tags]    case35
    [Setup]    5GC000746 Case Setup
    COAM Update several parameters via webUI    parameters_to_update_via_webui=${PARAM_746_DISABLE_CMAS}
    ...                                         download_dir=${TS_CASE_LOG_PATH}
    ...                                         is_need_to_check_validation_errors=${False}
    ${ngap_log}    ${bip_log}    Trigger CMAS Notification and Capture Logs
    ...                                         amf=${current_amf}
    ...                                         warning_area_list_id=${warning_area_list}[warning_area_cgi_list_1cell]
    Check Error Ind Message with Message Not Compatiable With Receiver State Cause    ngap_log=${ngap_log}    bip_log=${bip_log}
    COAM Update several parameters via webUI    parameters_to_update_via_webui=${PARAM_746_ENABLE_CMAS}
    ...                                         download_dir=${TS_CASE_LOG_PATH}
    ...                                         is_need_to_check_validation_errors=${False}
    [Teardown]    5GC000746 Case Teardown

[1][1.0] 5GC000746_A_039_Verify L1_L2 pool failure while CMAS broadcast ongoing
    [Tags]    case39    CIT_TRUNK    CIT_22R3    CIT_22R2    CIT_22R4
    [Setup]    5GC000746 Case Setup
    ${ngap_log_cmas}    ${bip_log_cmas}    Trigger CMAS Notification and Capture Logs
    ...                                         amf=${current_amf}
    ...                                         warning_area_list_id=${warning_area_list}[warning_area_cgi_list_1cell]
    ...                                         number_of_broadcasts_requested=${0}
    Check Complete Procedure for CMAS broadcasting    ngap_log=${ngap_log_cmas}
    ...                                               bip_log=${bip_log_cmas}
    ...                                               number_of_broadcasts_requested=${0}
    ${ngap_name}    Start NGAP and Bip Logs Capture
    wait until keyword succeeds    1min    2sec    Connect to gnb coam via ssl
    Lock BBMOD to cause L1_L2 pool Failure
    ${ngap_log_lock}    ${bip_log_lock}    Stop NGAP and Bip Logs Capture and Download Logs    ngap_name=${ngap_name}
    Check PWS Failure Indication Message with PWSFailedCellIDList IE    ngap_log=${ngap_log_lock}
    wait until keyword succeeds    1min    2sec    Connect to gnb coam via ssl
    Unlock BBMOD to Recover ENV
    Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT_LIST}
    Check CMAS Broadcasting is Interrupted
    [Teardown]    5GC000746 Case Teardown

[1][1.0] 5GC000746_A_040_Verify multiple WRITE-REPLACE WARNING REQUEST concurrency
    [Tags]    case40    CIT_TRUNK    CIT_22R3    CIT_22R2    CIT_22R4
    [Setup]    5GC000746 Case Setup
    ssh.Disconnect    connection=ASIK Master
    COAM commission scf and wait cell setup    scf_file_path=${3amf_scf_path}
    Connect to Common Unit Master
    Connect to Common Unit Slave
    COAM Update several parameters via webUI    parameters_to_update_via_webui=${PARAM_746_DISABLE_CMAS}
    ...                                         download_dir=${TS_CASE_LOG_PATH}
    ...                                         is_need_to_check_validation_errors=${False}
    FOR  ${item}    IN RANGE    2
        ${ngap_log}    ${bip_log}    Trigger CMAS Notification and Capture Logs
        ...                                         amf=${${amfs[${item}]}}
        ...                                         warning_area_list_id=${warning_area_list}[tai_warning_area_list]
        Check Error Ind Message with Message Not Compatiable With Receiver State Cause    ngap_log=${ngap_log}    bip_log=${bip_log}
    END
    COAM Update several parameters via webUI    parameters_to_update_via_webui=${PARAM_746_ENABLE_CMAS}
    ...                                         download_dir=${TS_CASE_LOG_PATH}
    ...                                         is_need_to_check_validation_errors=${False}
    FOR  ${item}    IN RANGE    2
        ${ngap_log}    ${bip_log}    Trigger CMAS Notification and Capture Logs
        ...                                         amf=${${amfs[${item}]}}
        ...                                         warning_area_list_id=${warning_area_list}[tai_warning_area_list]
        ...                                         serial_number=${item}
        ...                                         number_of_broadcasts_requested=${0}
        Check Complete Procedure for CMAS broadcasting    ngap_log=${ngap_log}
        ...                                               bip_log=${bip_log}
        ...                                               serial_number=${item}
        ...                                               number_of_broadcasts_requested=${0}
    END
    ${ngap_name}    Start NGAP and Bip Logs Capture
    wait until keyword succeeds    1min    2sec    Connect to gnb coam via ssl
    Perform cell lock via rest api
    Wait Until Keyword Succeeds   5 min  5 sec   Cell Should Be Locked
    ${ngap_log_lock}    ${bip_log_lock}    Stop NGAP and Bip Logs Capture and Download Logs    ngap_name=${ngap_name}
    Check PWS Failure Indication Message with PWSFailedCellIDList IE for Multi AMFs    ngap_log=${ngap_log_lock}
    wait until keyword succeeds    1min    2sec    Connect to gnb coam via ssl
    Perform cell unlock via rest api
    COAM Wait for gnb ready and cell setup    gnb_type='SA'
    [Teardown]    5GC000746 Case Teardown to Recover Configuration
