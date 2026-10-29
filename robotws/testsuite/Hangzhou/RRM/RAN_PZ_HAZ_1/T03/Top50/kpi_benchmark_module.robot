*** Settings ***
Documentation
...   author: winnie.he
...   contact: winnie.he@nokia-sbell.com
...   this is a robot case for UTE regression
Resource          ../Resources/common_resource.robot
Resource          ../Resources/top50_resource.robot
Library           ../Resources/python/traffic_model_schedule.py
Library           traffic_model_schedule.TrafficModel    WITH NAME    traffic_model
Library           traffic_model_schedule.BenchmarkKpi    WITH NAME    BK
# Library           ute_ue
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown      Common MutliBTS Suite Teardown For RRM
Test Setup    Run keywords    Common MultiBTS Test Setup For RRM    other_method=Return From Keyword
...    AND    Case Setup
Test Teardown     Run keywords    Case Teardown    AND    Common MultiBTS Test Teardown For RRM

*** Variables ***
&{fault_4694}              faultId=${4694}
@{Ohter_Allow_Alarms}      &{fault_4694}
${BTS_NUMBER}               ${1}
${DEBUG_MODE}            ${TRUE}
${REMOTE_MODE}           ${False}
# will output variable
# ${Sequence1}                newsequence
# ${Sequence2}                newsequence
# ${SW1}                      SBTS00_ENB_9999_230722_000011
# ${SW2}                      SBTS00_ENB_9999_230724_000003
&{Init_Enviroment_6090}      IP=10.56.198.140
...                     USERNAME=root
...                     PASSWORD=uteadmin
...                     Reinstall_Script_Path=${/}root${/}scripts
...                     VM_Required_File=~/MN/UTE/robotws/requirements.cfg
&{Testline_KVM}         10_5_UTESRAN001T6090=${Init_Enviroment_6090}
&{Upgrade_Case_Info}      Case_Path=${CURDIR}${/}..${/}GNB_EAR_Case${/}upgrade.robot
...                       Case_Tag=Upgrade
&{Rollback_Case_Info}     Case_Path=${CURDIR}${/}..${/}GNB_EAR_Case${/}upgrade.robot
&{Feature_File_INFO}
...    Upgrade=&{Upgrade_Case_Info}
...    Rollback=&{Rollback_Case_Info}

*** Test Cases ***
Reinstall Init Enviroment
    ${config_testlines}    Get Dictionary Keys    dictionary=${Testline_KVM}
    Run Keyword If    '${TESTLINE_NAME}' in "@{config_testlines}"
    ...    Set Test Variable    ${Init_Enviroment}    ${Testline_KVM}[${TESTLINE_NAME}]
    Run Keyword If    '${TESTLINE_NAME}' in "@{config_testlines}"
    ...    ReInstall Vm    ${False}
    [Teardown]    Log To Console    Upgrade ute-ca successful

Init Enviroment
    Clean Btslog For Remote Vm
    Upgrade ute-ca
    [Teardown]    Log To Console    Upgrade ute-ca successful

Rollback For Local Before
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Rollback    Rollback For Local

Rollback For Remote GNBs Before
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Rollback    Rollback For Remote GNBs

Upgrade For Sw1
    [Setup]    Common MultiBTS Test Setup For RRM    other_method=Return From Keyword
    Log To Console    Upgrade For Sw1
    ${SW1}    Get Variable Value     ${SW1}     ${None}
    Run Keyword If     '${SW1}'=='${None}'
    ...    Set Suite Variable    ${SW1}   ${Expect_Sw_Version}
    ...    ELSE
    ...    Run Keywords    Update File Except Sw1
    ...    AND
    ...    Set Suite Variable    ${Expect_Sw_Version}    ${SW1}
    Run Feature Case    feature_name=Upgrade    test_name=Upgrade
    [Teardown]    TL Suite Teardown

Run Traffic Model Sequence For Sw1
    Log To Console    Run Traffic Model Sequence For Sw1
    KPI Operation    start_kpi_collection    product_type=gnb
    Run Keyword If    ${GNB_NUMBER} > ${1}
    ...    Append Other Site Of Testline For KPI
    Run Traffic Model Sequence1
    ${status}    ${ret}    Run Keyword And Ignore Error
    ...    Wait Traffic Model Sequence Finish    ${1}
    Sleep    5min
    ${zip_path1}    KPI Operation    finish_kpi_collection    product_type=gnb
    Set Suite Variable    ${zip_path1}    ${zip_path1}
    Should Be True    '${status}'=='PASS'

Upgrade For Sw2
    [Setup]    Common MultiBTS Test Setup For RRM    other_method=Return From Keyword
    Log To Console    Upgrade For Sw2
    Update File Except Sw2
    Run Feature Case    feature_name=Upgrade    test_name=Upgrade
    [Teardown]    TL Suite Teardown

Run Traffic Model Sequence For Sw2
    Log To Console    Run Traffic Model Sequence For Sw2
    KPI Operation    start_kpi_collection    product_type=gnb
    Run Keyword If    ${GNB_NUMBER} > ${1}
    ...    Append Other Site Of Testline For KPI
    Run Traffic Model Sequence2
    ${status}    ${ret}    Run Keyword And Ignore Error
    ...    Wait Traffic Model Sequence Finish    ${2}
    Sleep    5min
    ${zip_path2}    KPI Operation    finish_kpi_collection    product_type=gnb
    Set Suite Variable    ${zip_path2}    ${zip_path2}
    Should Be True    '${status}'=='PASS'

Generate Report
    ${SW1}    Get Variable Value     ${SW1}     ${None}
    ${SW1}    Run Keyword If     '${SW1}'=='${None}'
    ...    COAM_Admin.GetSBTSSWVersion    COAM_0
    ...    ELSE    Set Variable    ${SW1}
    ${SW2}    Get Variable Value     ${SW2}     ${None}
    ${bts_list}    ${template1}    ${template2}
    ...    ${SW1_fixed}    ${SW2_fixed}    ${starttime2}
    ...    ${endtime2}    Prepare For BenchMark Report
    ...   ${SW1}    ${SW2}
    ${email}    Get Email From Config
    Run Keyword If    '${zip_path1}'=='${None}' or '${zip_path2}'=='${None}'
    ...    Fail    No KPI report generated
    KPI Operation    benchmark_report_generate    pmfile_zip_path1=${zip_path1}    pmfile_zip_path2=${zip_path2}
    ...    template1=${template1}    template2=${template2}
    ...    owner=${email}

CNI-134290_Benchmark KPI and Counter test
    [Tags]    QC_111491    QCD_MN_RAN    QCP_RAN_VRF
    Log to Console    Send To Rep For BTS301 ${TESTLINE_NAME}
    Run Keyword And Ignore Error    _Get All Gnb Active Sw Version
    Run Keyword And Ignore Error    Set Suite Variable    ${ACTIVE_SW_VERSION}
    ...    ${BTS0_ACTIVE_SW_VERSION}
    [Teardown]    TL Test Teardown    append_qc_send=${True}

TC20_SFE_Benchmark_NR_SA_VoNR
    [Tags]    QC_32853    QCD_MN_RAN    QCP_RAN_VRF
    Log to Console    Send To Rep For BTS6090 ${TESTLINE_NAME}
    Run Keyword And Ignore Error    _Get All Gnb Active Sw Version
    Run Keyword And Ignore Error    Set Suite Variable    ${ACTIVE_SW_VERSION}
    ...    ${BTS0_ACTIVE_SW_VERSION}
    [Teardown]    TL Test Teardown    append_qc_send=${True}

Rollback For Local
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Rollback

Rollback For Remote GNBs
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Rollback

*** Keywords ***
Append Other Site Of Testline For KPI
    FOR    ${i}    IN RANGE    ${GNB_NUMBER}
        KPI Operation    operation=add_kpi_collection    product_type=gnb
        ...    append_product_type=gnb    append_bts_index=${i}
    END

Run Traffic Model Sequence${index}
    Log To Console    ${Sequence${index}}
    ${seq}    Get Variable Value    ${Sequence${index}}    ${None}
    Run Keyword If    '${Sequence1}'=='${None}'    Fail    Can't fine the traffic mode sequence name
    traffic_model.start_sequence    ${Sequence${index}}
    Set Test Variable    ${Sequence${index}}    ${Sequence${index}}

Check Traffic Model Sequence Finish
    [Arguments]    ${Sequence_index}=${1}
    ${respon}    traffic_model.get_sequence_status    sequence_name=${Sequence${Sequence_index}}
    Run Keyword If    '${respon}[status]'!='finish'    Fail    ${Sequence${Sequence_index}} Still No finish
    Run Keyword If    '${respon}[status]'=='error' or '${respon}[status]'=='pending'
    ...    Fail    msg=${Sequence${Sequence_index}} some error happen

Wait Traffic Model Sequence Finish
    [Arguments]    ${Sequence_index}=${1}    ${wait_time}=30 min    ${wait_x}=6
    FOR    ${i}    IN RANGE    ${wait_x}
        ${status}    ${ret}    Run Keyword And Ignore Error
        ...    Wait Until Keyword Succeeds     ${wait_time}    1 min
        ...    Check Traffic Model Sequence Finish    Sequence_index=${Sequence_index}
        ${respon}    traffic_model.get_sequence_status    sequence_name=${Sequence${Sequence_index}}
        Run Keyword If    '${respon}[status]'=='error' or '${respon}[status]'=='pending'
        ...    Fail    msg=${Sequence${Sequence_index}} some error happen
        Run Keyword If    '${i}'=='${0}'
        ...    Run Keyword And Ignore Error    Capture Default Log By Dcap
        Exit For Loop If    '${respon}[status]'=='finish'
    END
    Should Be True    '${status}'=='PASS'

Update File Except Sw${i}
    ${sw}    Get Variable Value    ${SW${i}}    ${None}
    Set Suite Variable    ${SW${i}}    ${sw}
    Return From Keyword If    '${SW${i}}'=='${None}'
    Replace String In One File    file_path=${UTE_RESERVATION_JSON}
    ...    pattern=${Expect_Sw_Version}    replace_with=${SW${i}}
    Replace String In One File    file_path=${UTE_RESERVATION_CONTEXT_JSON}
    ...    pattern=${Expect_Sw_Version}    replace_with=${SW${i}}

Case Setup
    Log to Console    start ${TEST NAME}

Case Teardown
    Run Keyword And Ignore Error    Collect Coam Snapshot For All GNB
    Log To Console    TL Test Teardown
    Run Keyword And Ignore Error    traffic_model.stop_sequence    ${Sequence1}
    Run Keyword And Ignore Error    traffic_model.stop_sequence    ${Sequence2}

Get Email From Config
    ${keylist}    Create List    ${TESTLINE_TYPE}    username
    ${has_email_key}    ${email}    Run Keyword And Ignore Error
    ...    Get Info From UTE Reservation File    ${keylist}    ${CURDIR}/username_config.json
    ${username}    Run Keyword If    '${has_email_key}'=="PASS"
    ...    Set Variable    ${email}
    ...    ELSE    Set Variable    tacase_auto@nokia-sbell.com
    [Return]    ${username}

Get API Key From Config
    ${keylist}    Create List    ${TESTLINE_TYPE}    api_keys
    ${has_api_key}    ${api_key}    Run Keyword And Ignore Error
    ...    Get Info From UTE Reservation File    ${keylist}    ${CURDIR}/username_config.json
    ${api_key}    Run Keyword If    '${has_api_key}'=="PASS"
    ...   Set Variable    ${api_key}
    ...   ELSE    Set Variable    ${None}
    [Return]    ${api_key}

Get Alpha Factor From Config
    ${keylist}    Create List    ${TESTLINE_TYPE}    alpha_factor
    ${has_alpha_key}    ${alpha_factor}    Run Keyword And Ignore Error
    ...    Get Info From UTE Reservation File    ${keylist}    ${CURDIR}/username_config.json
    ${alpha_factor}    Run Keyword If    '${has_alpha_key}'=="PASS"
    ...   Set Variable    ${alpha_factor}
    ...   ELSE    Set Variable    ${DEFAULT_ALPHA_FACTOR}
    [Return]    ${alpha_factor}

Capture Default Log By Dcap
    ${has_cellid_key}    ${cellid_list}    Run Keyword And Ignore Error
    ...    Get Info From UTE Reservation File    ${keylist}    ${CURDIR}/username_config.json
    Return From Keyword If    '${has_cellid_key}'=='FAIL'
    ${gnb_length}    Get Length    ${tl.gnbs}
    FOR    ${i}    IN RANGE   ${gnb_length}
        Start Capture Default Log By VM dcap    nrcell_list=${cellid_list}[${i}]
        ...    bts_index=${i}
        Sleep    1 min
        Stop Capture Default Log By VM dcap
        ...    bts_index=${i}
    END