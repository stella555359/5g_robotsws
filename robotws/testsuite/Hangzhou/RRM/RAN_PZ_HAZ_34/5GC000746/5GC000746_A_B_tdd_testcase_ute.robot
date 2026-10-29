*** Settings ***
Library    OperatingSystem
Library    Collections
Library    BuiltIn
Library    String

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ald_operation.robot
Resource    Resources/5GC000746_common_keyword.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC001783/Resources/5GC001783_5GC002040_Keywords.robot
Variables    Resources/5GC000746_A_variables.py

Documentation
...   author: Chen Tong
...   contact: tong.chen@nokia-sbell.com
...   squad group: SG_02

Force Tags    5G_SISO         master_classicalbts_all    STATE_SW_UPLOADED    SBTS00    5G_RAN    5G_RAN_TDD
...    PY39
...           RAN_5G    RAN_5G_TDD    CIT    CLOUD_5G_CLASSICAL_ANDROID_ASIBL_ABILB1_AEQB_ENB

#Suite Setup     Run Keywords    SG2_Common_setup_teardown.Common Suite setup    if_commissioning=${True}
#...             AND    Upgrade geckodriver workround

Suite Setup     SG2_Common_setup_teardown.Common Suite setup    if_commissioning=${True}

*** Variables ***
#${tshark_path_for_746}    /usr/bin/tshark
#${luashark_path}    /opt/luashark/luashark.lua
#${command_template}
#...    {tshark_path} -o swe.call_mac_nr:TRUE -r {pcap_file} -X lua_script:${luashark_path} -Y ${expression_cmas_sib8} -T pdml
#${command_template_sib1}
#...    {tshark_path} -o swe.call_mac_nr:TRUE -r {pcap_file} -X lua_script:${luashark_path} -Y ${expression_cmas_sib1} -T pdml
#${command_template_bip_cell1}
#...    {tshark_path} -o swe.call_mac_nr:TRUE -r {pcap_file} -X lua_script:${luashark_path} -Y ${bip_expression_cmas_cell1} -T pdml
#${command_template_bip_cell2}
#...    {tshark_path} -o swe.call_mac_nr:TRUE  -r {pcap_file} -X lua_script:${luashark_path} -Y ${bip_expression_cmas_cell2} -T pdml

${scf_dir_746}    ${CURDIR}/../../../../../commissionings/HGZ/7_5_UTE5G402T243
#${sib8_sfn}    DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.sfn
#${sib8_slot}    DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.slot
#${filter_sib8_sfn}    DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.sfn
#${filter_sib8_slot}    DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.slot
#${dldata_subcellid}    DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.subcellId
${mcc_filter}    e212.5gstai.mcc
${mnc_filter}    e212.5gstai.mnc

@{amfs}    zheng_amf    shen_amf    han_amf    sui_amf    zhou_amf    liang_amf    tang_amf    feng_amf

&{fault_61524}    faultId=${61524}    source=-    #faultId:SSH_ENABLED  source:RU1
&{fault_61652}    faultId=${61652}    source=-    #faultId:R&D_SERVICE_PORT_ENABLED  source:RU1


*** Test Cases ***
[1]5GC000980_B_AEQB_001_ALD_HW_inventory_ALD_HW_properties_retrieval_and_visualization
    [Tags]    CIT_TRUNK    CIT_21B    CIT_21A
    [Timeout]    40 min
    [Setup]    Run Keywords    SG2_Common_setup_teardown.Common Case setup    AND    Commission for 5GC000980 and Wait Cell On Air
    ${ald_info}    Get ALD Information via webUI
    Run keyword and continue on failure    Should Not Be Empty    ${ald_info["Product code"]}    msg=There is no Product code for ALD
    Run keyword and continue on failure    Should Not Be Empty    ${ald_info["Serial number"]}    msg=There is no Serial number for ALD
    Run keyword and continue on failure    Should Not Be Empty    ${ald_info["HW version"]}    msg=There is no HW version for ALD
    Run keyword and continue on failure    Should Not Be Empty    ${ald_info["SW version"]}    msg=There is no SW version for ALD
    [Teardown]    Run Keyword And Ignore Error    SG2_Common_setup_teardown.Common Case teardown    is_need_to_recover=${True}

[1]5GC000980_C_AEQB_005_ALD_Configuration_Management_ALD_reset_operation
    [Tags]    CIT_TRUNK    CIT_21B    CIT_21A
    [Timeout]    50 min
    [Setup]    Run Keywords    SG2_Common_setup_teardown.Common Case setup    AND    Commission for 5GC000980 and Wait Cell On Air
    Run keyword and continue on failure    5GC001783_5GC002040_Keywords.ALD Should Be Ready
    Run keyword and continue on failure    5GC001783_5GC002040_Keywords.RAEU Should Be Ready
    Reset ALD via webUI    reset_type=hardware
    Wait Until Keyword Succeeds   3 min  5 sec    5GC001783_5GC002040_Keywords.ALD Should Be Ready
    Wait Until Keyword Succeeds   3 min  5 sec    5GC001783_5GC002040_Keywords.RAEU Should Be Ready
    [Teardown]    run keyword and ignore error    SG2_Common_setup_teardown.Common Case teardown    is_need_to_recover=${True}

[1][1.0] 5GC000746_A_001_Verify if Cell can be Onair when actCMAS is set to true
    [Tags]    CIT_TRUNK    CIT_20A    CIT_21A
    [Timeout]    1h
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
    Run Keyword And Ignore Error    coam.teardown_all_aliases_for_admin
    wait until keyword succeeds    1min    2sec    Connect to gnb coam via ssl
    Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT_LIST}
    COAM Wait for gnb ready and cell setup    gnb_type='SA'
    [Teardown]    5GC000746 Case Teardown

[1][1.0] 5GC000746_A_008_Verify WRITE-REPLACE WARNING REQUEST with MessageIdentifier is not identified CMAS
    [Tags]    CIT_TRUNK    CIT_20A    CIT_21A
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
    [Tags]    CIT_TRUNK    CIT_20A    CIT_21A
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
    [Tags]    CIT_TRUNK    CIT_20A    CIT_21A
    [Setup]    5GC000746 Case Setup
    ${ngap_log}    ${bip_log}    Trigger CMAS Notification and Capture Logs
    ...                                         amf=${current_amf}
    ...                                         warning_area_list_id=${warning_area_list}[warning_area_cgi_list_2cell]
    Check Write Replace Warning Response without Broadcaset Completed Area List    ngap_log=${ngap_log}    bip_log=${bip_log}
    [Teardown]    5GC000746 Case Teardown

[1][1.0] 5GC000746_A_015_Verify WRITE-REPLACE WARNING REQUEST with WarningAreaList.emergencyAreaIDList which is not configured in serving gNB
    [Tags]    CIT_TRUNK    CIT_20A    CIT_21A
    [Setup]    5GC000746 Case Setup
    ${ngap_log}    ${bip_log}    Trigger CMAS Notification and Capture Logs
    ...                                         amf=${current_amf}
    ...                                         warning_area_list_id=${warning_area_list}[unknown_warning_area_emergency_list]
    Check Write Replace Warning Response without Broadcaset Completed Area List    ngap_log=${ngap_log}    bip_log=${bip_log}
    [Teardown]    5GC000746 Case Teardown

[1][1.0] 5GC000746_A_026_Verify CMAS coded 4 pages broadcast in RRC_CONNECTED state
    [Tags]    CIT_TRUNK    CIT_20A    CIT_21A
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

[1][1.0] 5GC000746_A_030_Verify cell locked while CMAS broadcast ongoing
    [Tags]    CIT_TRUNK    CIT_20A    CIT_21A
    [Setup]    5GC000746 Case Setup
    ${ngap_log_cmas}    ${bip_log_cmas}    Trigger CMAS Notification and Capture Logs
    ...                                         amf=${current_amf}
    ...                                         warning_area_list_id=${warning_area_list}[warning_area_cgi_list_1cell]
    ...                                         number_of_broadcasts_requested=${0}
    Check Complete Procedure for CMAS broadcasting    ngap_log=${ngap_log_cmas}
    ...                                               bip_log=${bip_log_cmas}
    ...                                               number_of_broadcasts_requested=${0}
    ${ngap_name}    Start NGAP and Bip Logs Capture
    Run Keyword And Ignore Error    coam.teardown_all_aliases_for_admin
    wait until keyword succeeds    1min    2sec    Connect to gnb coam via ssl
    Perform cell lock via rest api
    Wait Until Keyword Succeeds   5 min  5 sec   Cell Should Be Locked
    ${ngap_log_lock}    ${bip_log_lock}    Stop NGAP and Bip Logs Capture and Download Logs    ngap_name=${ngap_name}
    Check PWS Failure Indication Message with PWSFailedCellIDList IE    ngap_log=${ngap_log_lock}
    Run Keyword And Ignore Error    coam.teardown_all_aliases_for_admin
    wait until keyword succeeds    1min    2sec    Connect to gnb coam via ssl
    Perform cell unlock via rest api
    COAM Wait for gnb ready and cell setup    gnb_type='SA'
    Connect to Common Unit Master
    Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT_LIST}
    Check CMAS Broadcasting is Interrupted
    [Teardown]    5GC000746 Case Teardown

[1][1.0] 5GC000746_A_031_Verify change emergencyAreaId while CMAS broadcast ongoing
    [Tags]    CIT_TRUNK    CIT_20A    CIT_21A
    [Setup]    5GC000746 Case Setup
    ${ngap_log}    ${bip_log}    Trigger CMAS Notification and Capture Logs
    ...                                         amf=${current_amf}
    ...                                         warning_area_list_id=${warning_area_list}[warning_area_emergency_list]
    ...                                         number_of_broadcasts_requested=${0}
    ${wmc}    ${wac}    Check Complete Procedure for CMAS broadcasting    ngap_log=${ngap_log}
    ...                                                                   bip_log=${bip_log}
    ...                                                                   number_of_broadcasts_requested=${0}
    COAM Update Emergency Area ID List via webUI    param_emergency_area_id_list=${PARAM_746_EMERGENCY_AREA_ID_LIST_2[0]}
    Run Keyword And Ignore Error    coam.teardown_all_aliases_for_admin
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
    Run Keyword And Ignore Error    coam.teardown_all_aliases_for_admin
    wait until keyword succeeds    1min    2sec    Connect to gnb coam via ssl
    Perform cell lock via rest api
    Wait Until Keyword Succeeds   5 min  5 sec   Cell Should Be Locked
    Perform cell unlock via rest api
    COAM Wait for gnb ready and cell setup    gnb_type='SA'
    Connect to Common Unit Master
    Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT_LIST}
    [Teardown]    5GC000746 Case Teardown

[1][1.0] 5GC000746_A_033_Verify counter NNGCC_WRWR_RES_SENT
    [Tags]    CIT_TRUNK    CIT_20A    CIT_21A
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
        Run Keyword And Ignore Error    coam.teardown_all_aliases_for_admin
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

[1][1.0] 5GC000746_A_039_Verify L1_L2 pool failure while CMAS broadcast ongoing
    [Tags]    CIT_TRUNK    CIT_20A    CIT_21A
    [Setup]    5GC000746 Case Setup
    ${ngap_log_cmas}    ${bip_log_cmas}    Trigger CMAS Notification and Capture Logs
    ...                                         amf=${current_amf}
    ...                                         warning_area_list_id=${warning_area_list}[warning_area_cgi_list_1cell]
    ...                                         number_of_broadcasts_requested=${0}
    Check Complete Procedure for CMAS broadcasting    ngap_log=${ngap_log_cmas}
    ...                                               bip_log=${bip_log_cmas}
    ...                                               number_of_broadcasts_requested=${0}
    ${ngap_name}    Start NGAP and Bip Logs Capture
    Run Keyword And Ignore Error    coam.teardown_all_aliases_for_admin
    wait until keyword succeeds    1min    2sec    Connect to gnb coam via ssl
    Lock BBMOD to cause L1_L2 pool Failure
    ${ngap_log_lock}    ${bip_log_lock}    Stop NGAP and Bip Logs Capture and Download Logs    ngap_name=${ngap_name}
    Check PWS Failure Indication Message with PWSFailedCellIDList IE    ngap_log=${ngap_log_lock}
    Run Keyword And Ignore Error    coam.teardown_all_aliases_for_admin
    wait until keyword succeeds    1min    2sec    Connect to gnb coam via ssl
    Unlock BBMOD to Recover ENV
    Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT_LIST}
    Check CMAS Broadcasting is Interrupted
    [Teardown]    5GC000746 Case Teardown

[1][1.0] 5GC000746_A_040_Verify multiple WRITE-REPLACE WARNING REQUEST concurrency
    [Tags]    CIT_TRUNK    CIT_20A    CIT_21A
    [Setup]    5GC000746 Case Setup
    ssh.Disconnect    connection=ASIK Master
    COAM commission scf and wait cell setup    scf_file_path=${scf_dir_746}/${ENB_BRANCH}_scf_SA_3amf.xml
    Connect to Common Unit Master
    Connect to Common Unit Slave
    COAM Update several parameters via webUI    parameters_to_update_via_webui=${PARAM_746_DISABLE_CMAS}
    ...                                         download_dir=${TS_CASE_LOG_PATH}
    ...                                         is_need_to_check_validation_errors=${False}
    FOR  ${item}    IN RANGE    2
        ${ngap_log}    ${bip_log}    Trigger CMAS Notification and Capture Logs
        ...                                    amf=${${amfs[${item}]}}
        ...                                    warning_area_list_id=${warning_area_list}[tai_warning_area_list]
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
    Run Keyword And Ignore Error    coam.teardown_all_aliases_for_admin
    wait until keyword succeeds    1min    2sec    Connect to gnb coam via ssl
    Perform cell lock via rest api
    Wait Until Keyword Succeeds   5 min  5 sec   Cell Should Be Locked
    ${ngap_log_lock}    ${bip_log_lock}    Stop NGAP and Bip Logs Capture and Download Logs    ngap_name=${ngap_name}
    Check PWS Failure Indication Message with PWSFailedCellIDList IE for Multi AMFs    ngap_log=${ngap_log_lock}
    Run Keyword And Ignore Error    coam.teardown_all_aliases_for_admin
    wait until keyword succeeds    1min    2sec    Connect to gnb coam via ssl
    Perform cell unlock via rest api
    COAM Wait for gnb ready and cell setup    gnb_type='SA'
    [Teardown]    5GC000746 Case Teardown to Recover Configuration

[1][1.0] 5GC000746_B_001_Verify PWS CANCEL REQUEST when actCMAS is set to false
    [Tags]    CIT_TRUNK    CIT_20A    CIT_21A
    [Timeout]    1h
    [Setup]    5GC000746 Case Setup
    COAM Update several parameters via webUI    parameters_to_update_via_webui=${PARAM_746_DISABLE_CMAS}
    ...                                         download_dir=${TS_CASE_LOG_PATH}
    ...                                         is_need_to_check_validation_errors=${False}
    ${ngap_log}    ${bip_log}    Trigger CMAS Notification and Capture Logs    amf=${current_amf}
    ...                                         warning_area_list_id=${warning_area_list}[warning_area_cgi_list_1cell]
    Check Error Ind Message with Message Not Compatiable With Receiver State Cause    ngap_log=${ngap_log}    bip_log=${bip_log}
    COAM Update several parameters via webUI    parameters_to_update_via_webui=${PARAM_746_ENABLE_CMAS}
    ...                                         download_dir=${TS_CASE_LOG_PATH}
    ...                                         is_need_to_check_validation_errors=${False}
    [Teardown]    5GC000746 Case Teardown

[1][1.0] 5GC000746_B_005_Vierfy PWS CANCEL REQUEST with WarningAreaList not belong to the serving gNB
    [Tags]    CIT_TRUNK    CIT_20A    CIT_21A
    [Setup]    5GC000746 Case Setup
    Trigger CMAS Notification and Capture Logs    amf=${current_amf}
    ...                                           warning_area_list_id=${warning_area_list}[warnig_area_list_none]
    ...                                           number_of_broadcasts_requested=${0}
    ${ngap_log}    ${bip_log}    Trigger CMAS PWS Cancel and Capture Logs    amf=${current_amf}
    ...                                              warning_area_list_id=${warning_area_list}[warnig_area_list_none]
    Check Complete Cancel Procedure in NGAP Log    ngap_log=${ngap_log}    amf=${current_amf}
    ...                                            warningarealist_type=None
    Check CMAS Broadcasting is Interrupted
    Trigger CMAS Notification and Capture Logs    amf=${current_amf}
    ...                                           warning_area_list_id=${warning_area_list}[warning_area_cgi_list_1cell]
    ...                                           number_of_broadcasts_requested=${0}
    ${ngap_log}    ${bip_log}    Trigger CMAS PWS Cancel and Capture Logs    amf=${current_amf}
    ...                                              warning_area_list_id=${warning_area_list}[warning_area_cgi_list_2cell]
    Check PWS Cancel Response without Broadcaset Cancelled Area List    ngap_log=${ngap_log}
    ${ngap_log}    ${bip_log}    Trigger CMAS PWS Cancel and Capture Logs    amf=${current_amf}
    ...                                              warning_area_list_id=${warning_area_list}[warning_area_cgi_list_1cell]
    Check Complete Cancel Procedure in NGAP Log    ngap_log=${ngap_log}    amf=${current_amf}
    ...                                            warningarealist_type=None
    Check CMAS Broadcasting is Interrupted
    [Teardown]    5GC000746 Case Teardown

[1][1.0] 5GC000746_B_006_Verify multiple PWS CANCEL REQUEST concurrency
    [Tags]    CIT_TRUNK    CIT_20A    CIT_21A
    [Setup]    5GC000746 Case Setup
    ssh.Disconnect    connection=ASIK Master
    COAM commission scf and wait cell setup    scf_file_path=${scf_dir_746}/${ENB_BRANCH}_scf_SA_3amf.xml
    Connect to Common Unit Master
    Connect to Common Unit Slave
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
        ${ngap_log}    ${bip_log}    Trigger CMAS PWS Cancel and Capture Logs    amf=${${amfs[${item}]}}
        ...                                              warning_area_list_id=${warning_area_list}[tai_warning_area_list]
        ...                                              serial_number=${item}
        Check Complete Cancel Procedure in NGAP Log    ngap_log=${ngap_log}
        ...                                            amf=${${amfs[${item}]}}
        ...                                            serial_number=${item}
        ...                                            warningarealist_type=tailist
        Check CMAS Broadcasting is Interrupted
    END
    [Teardown]    5GC000746 Case Teardown to Recover Configuration

[1][1.0] 5GC000746_B_008_Verify counter NNGCC_PWSCAN_RESP_SENT
    [Tags]    CIT_TRUNK    CIT_20A    CIT_21A
    [Setup]    5GC000746 Case Setup
    ssh.Disconnect    connection=ASIK Master
    Perform BTS Site Reset
    Sleep    5min
    COAM Wait for gnb ready and cell setup    gnb_type='SA'
    Connect to Common Unit Master
    Connect to Common Unit Slave
    FOR  ${item}  IN RANGE  51  56
        Trigger CMAS Notification and Capture Logs    amf=${current_amf}
        ...                                           warning_area_list_id=${warning_area_list}[warning_area_cgi_list_1cell]
        ...                                           serial_number=${item}
        ...                                           number_of_broadcasts_requested=${0}
    END
    FOR  ${item}  IN RANGE  51  56
        Trigger CMAS PWS Cancel and Capture Logs    amf=${current_amf}
        ...                                         warning_area_list_id=${warning_area_list}[warning_area_cgi_list_1cell]
        ...                                         serial_number=${item}
    END
    Sleep    6min
    ${cnt_list}    COAM Get BTS Counters via webUI    counter_id=${COUNTERS_746[3]}[counter_id]
    ${counter_sum}    Sum Value in Counter list    cnt_list=${cnt_list}
    Should Be Equal    ${counter_sum}    ${5}
    ${cnt_list}    COAM Get BTS Counters via webUI    counter_id=${COUNTERS_746[4]}[counter_id]
    ${counter_sum}    Sum Value in Counter list    cnt_list=${cnt_list}
    Should Be Equal    ${counter_sum}    ${5}
    [Teardown]    5GC000746 Case Teardown

*** Keywords ***
Upgrade geckodriver workround
    Run    sudo sshpass -p "iW_K#8.ute%A10h0m0ra" scp ute@10.57.157.218:/home/ute/Downloads/geckodriver-v0.28.0-linux64.tar.gz /opt
    Sleep    2s
    Run    sudo sshpass -p "iW_K#8.ute%A10h0m0ra" scp ute@10.57.157.218:/home/ute/Downloads/firefox-91.9.1esr.tar.bz2 /opt
    Sleep    2s
    Run    sudo tar xf /opt/geckodriver-v0.28.0-linux64.tar.gz -C /opt
    Sleep    2s
    Run    sudo tar xf /opt/firefox-91.9.1esr.tar.bz2 -C /opt
    Sleep    2s
    Run    sudo mv /opt/geckodriver /opt/ute/geckodriver/
    Sleep    2s
    Run    sudo rm -rf /usr/bin/firefox
    Sleep    2s
    Run    sudo ln -s /opt/firefox/firefox /usr/bin/firefox
