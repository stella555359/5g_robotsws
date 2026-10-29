*** Settings ***
Documentation
...   author: winnie.he
...   contact: winnie.he@nokia-sbell.com
...   this is a robot case for UTE regression
Resource          ../Resources/common_resource.robot
# Resource          ../Resources/ute_case_common_resource.robot
Library           ute_ue
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown    TL Suite Teardown
Test Setup        _Create Test Directory
Test Teardown     TL Test Teardown
Force Tags
# ...                     CRT
...                     RAN_5G
...                     CLOUD_5G_CLASSICAL_ANDRIOD_CA_ASIBL_ABIAB3_FRPA_FRHF_AHEGB_FRHF-ASIBL_ABIL_AEQE
...                     SBTS23R1
...                     SBTS22R4
...                     SBTS00
...                     STATE_SKIP_AGENT
...                     CA_RAN_PZ_HAZ_1
...                     RAN_PZ_HAZ1_SG07_ST_RRM
...                     TA_LEVEL_22
Test Timeout            75h
*** Variables ***
&{Init_Enviroment}      IP=10.56.198.140
...                     USERNAME=root
...                     PASSWORD=uteadmin
...                     Reinstall_Script_Path=${/}root${/}scripts
...                     VM_Required_File=~/MN/UTE/robotws/requirements.cfg
${testline_configuration_path}    ~${/}testline_configuration
#storge case file info and path case file : { case path : path, case list: case list}
&{Upgrade_Case_Info}    Case_Path=${CURDIR}${/}..${/}GNB_EAR_Case${/}upgrade.robot
...                     Case_Tag=Upgrade
&{LTE4549_Case_Info}    Case_Path=${CURDIR}${/}..${/}LTE4549${/}LTE4549.robot
&{CB007910_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB007910${/}CB007910.robot
&{CB006067_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB006067${/}CB006067.robot
&{CB007320_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB007320${/}CB007320.robot
&{CB006465_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB006465${/}CB006465.robot
&{LTE5003_Case_Info}    Case_Path=${CURDIR}${/}..${/}LTE5003${/}LTE5003.robot
&{CB007163_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB007163${/}CB007163.robot
&{CB009189_Case1_Info}    Case_Path=${CURDIR}${/}..${/}CB009189${/}CB009189.robot
...                       Case_Tag=CB009189_A
&{CB009189_Case2_Info}    Case_Path=${CURDIR}${/}..${/}CB009189${/}CB009189.robot
...                       Case_Tag=CB009189_A
&{CB009189_Case_Info}   Case_Path=${CURDIR}${/}..${/}CB009189${/}CB009189.robot
&{Feature_File_INFO}
...    Upgrade=&{Upgrade_Case_Info}
...    LTE4549=&{LTE4549_Case_Info}
...    CB006465=&{CB006465_Case_Info}
...    CB007910=&{CB007910_Case_Info}
...    CB006067=&{CB006067_Case_Info}
...    CB007320=&{CB007320_Case_Info}
...    LTE5003=&{LTE5003_Case_Info}
...    CB007163=&{CB007163_Case_Info}
...    CB009189_1=&{CB009189_Case1_Info}
...    CB009189_2=&{CB009189_Case2_Info}
...    CB009189=&{CB009189_Case_Info}
${APC_Index}    -1
*** Test Cases ***
Init Enviroment
    ReInstall Vm
Upgrade
    Compare Release And Choose Suitable Upgrade
    Run Feature Case
LTE4549-A_FDD_Scell addition is triggered as one step for UE in EN-DC mode
    ReInstall Vm
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Upgrade
    Run Feature Case    LTE4549
    # Log    LTE4549
IWK_ESP_CB006465_SR_UL_256QAM_is_configured_and_deconfigured_for_EN_DC_capable_UE_Channel_Quality_Monitoring_is_enabled
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Upgrade
    Run Feature Case    CB006465
    # Log    CB006465
CB007910-SR_A_07_01 parallel interaction with EN-DC HO
    # FOR    ${i}    IN RANGE    ${10}
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Upgrade
    Run Feature Case    CB007910
    # Log    CB007910
    # END
IWK_ESP_CB006067_A_002_Proper_maxMeasFreqsSCG_value_are_provided_in_SgNB_Addition_Request
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Upgrade
    Run Feature Case    CB006067
    # Log    CB006067
IWK_ESP_CB7320_Keeping_UL_256QAM_mode_and_CQM_after_ENDC_entry
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Upgrade
    Run Feature Case    CB007320
    # Log    CB007320
LTE5003-A_FDD_Coverage and buffer based EN-DC setup before LTE CA configuration
    Compare Release And Choose Suitable Upgrade
    Run Feature Case    Upgrade
    Run Feature Case    LTE5003
    # Log    LTE5003
CB007163_03_MR-DC capabilities shall be considered when steering UE to preferred layer when CB006607 is enabled
    ${expect_release}    Get Release    sw=${EXPECT_SW_VERSION}
    Run Keyword If    '${expect_release}'>'SBTS22R3' or '${expect_release}'=='SBTS00'
    ...    Run Keywords
    ...    Compare Release And Choose Suitable Upgrade    AND
    ...    Run Feature Case    Upgrade    AND
    ...    Run Feature Case    CB007163
    # Log    CB007163
CB007163_07_eA5 measurement activation and deactivation interaction with SgNB addition and release
    ${expect_release}    Get Release    sw=${EXPECT_SW_VERSION}
    Run Keyword If    '${expect_release}'>'SBTS22R3' or '${expect_release}'=='SBTS00'
    ...    Run Keywords
    ...    Compare Release And Choose Suitable Upgrade    AND
    ...    Run Feature Case    Upgrade    AND
    ...    Run Feature Case    CB007163
    # Log    CB007163
CB007163_12_EN-DC Handover to preferred layer after incoming handover from inter-eNB cell with EN-DC without MR-DC capability retrieval needed
    ${expect_release}    Get Release    sw=${EXPECT_SW_VERSION}
    Run Keyword If    '${expect_release}'>'SBTS22R3' or '${expect_release}'=='SBTS00'
    ...    Run Keywords
    ...    Compare Release And Choose Suitable Upgrade    AND
    ...    Run Feature Case    Upgrade    AND
    ...    Run Feature Case    CB007163
    # Log    CB007163
CB007163_09_EN-DC Handover to preferred layer after incoming handover from intra-eNB cell with EN-DC without CB006607 enabled
    ${expect_release}    Get Release    sw=${EXPECT_SW_VERSION}
    Run Keyword If    '${expect_release}'>'SBTS22R3' or '${expect_release}'=='SBTS00'
    ...    Run Keywords
    ...    Compare Release And Choose Suitable Upgrade    AND
    ...    Run Feature Case    Upgrade    AND
    ...    Run Feature Case    CB007163
    # Log    CB007163
CB009189-A_01_NSA_TDD_Successful admission control for specific SR period configured DRB addition for non-VoNR UEs initial access
    ${expect_release}    Get Release    sw=${EXPECT_SW_VERSION}
    Run Keyword If    '${expect_release}'>'SBTS22R4' or '${expect_release}'=='SBTS00'
    ...    Run Keywords
    ...    Compare Release And Choose Suitable Upgrade    AND
    ...    Run Feature Case    Upgrade    AND
    ...    Run Feature Case    CB009189_1
    # Log    CB009189_1
CB009189-A_02_SA_TDD_Successful admission control for specific SR period configured DRB addition for non-VoNR UEs additional DRBs SR change
    ${expect_release}    Get Release    sw=${EXPECT_SW_VERSION}
    Run Keyword If    '${expect_release}'>'SBTS22R4' or '${expect_release}'=='SBTS00'
    ...    Run Keywords
    ...    Compare Release And Choose Suitable Upgrade    AND
    ...    Run Feature Case    Upgrade    AND
    ...    Run Feature Case    CB009189_2
    # Log    CB009189_2
CB009189-D_17_Successful setup of 5QI-80 non GBR QoS flow with Initial Context Setup Request
    ${expect_release}    Get Release    sw=${EXPECT_SW_VERSION}
    Run Keyword If    '${expect_release}'>'SBTS22R4' or '${expect_release}'=='SBTS00'
    ...    Run Keywords
    ...    Compare Release And Choose Suitable Upgrade    AND
    ...    Run Feature Case    Upgrade    AND
    ...    Run Feature Case    CB009189
    # Log    CB009189

*** Keywords ***
Run Feature Case
    [Arguments]    ${test_name}=${TEST NAME}
    Log to Console    Start to Run robot file ${test_name}
    ${Cases_INFO}    Get Case File Info    case_name=${test_name}
    Connect To VM
    Run One Case    ${Cases_INFO}    ${test_name}
    [Teardown]    Disconnect VM

Run One Case
    [Arguments]    ${cases_info}    ${feature_name}
    ${case_path}    Set Variable    ${cases_info}[Case_Path]
    ${tag_status}    ${value}    Run Keyword And Ignore Error    Dictionary Should Contain Key
    ...    ${cases_info}    Case_Tag
    ${execute_command}    Run Keyword If    '${tag_status}'=='PASS'
    ...    Catenate     robot -L TRACE -b debug.log
    ...    -V ${testline_configuration_path}${/}${TESTLINE_NAME}${/}
    ...    -d ${TEST_LOG_DIRECTORY}
    ...    -l ${feature_name}.html
    ...    -i ${cases_info}[Case_Tag]
    ...    ${case_path}
    ...    ELSE
    ...    Catenate     robot -L TRACE -b debug.log
    ...    -V ${testline_configuration_path}${/}${TESTLINE_NAME}${/}
    ...    -d ${TEST_LOG_DIRECTORY}
    ...    -l ${feature_name}.html
    ...    -t "${TEST NAME}"
    ...    ${case_path}
    ${ret}    OperatingSystem.Run    command=source /opt/ute/agent_env/bin/activate;${execute_command}
    ${matches}    Get Regexp Matches    ${ret}    \\d+ failed
    Should Not Be Empty    ${matches}
    ${failed_num}    Split String    ${matches}[0]    ${SPACE}
    Should Be Equal    ${failed_num}[0]    0

Get Case File Info
    [Arguments]    ${case_name}=${TEST NAME}
    ${Cases_INFO}    Set Variable    ${Feature_File_INFO}[${case_name}]
    [Return]    ${Cases_INFO}

Send All Report Portal Result
    Connect To VM
    ${feature_names}    Get Dictionary Keys    ${Feature_File_INFO}
    FOR    ${feature_name}    IN    @{feature_names}
        Log To Console    Start send report portal of ${feature_name}
        ${ret}    Send One Report Portal Result    robotfile_path=${Feature_File_INFO}[${feature_name}][Case_Path]
        ...    feature_log_path=${SUITE_LOG_DIRECTORY}    feature_name=${feature_name}
    END

Send One Report Portal Result
    [Arguments]    ${robotfile_path}    ${feature_log_path}    ${feature_name}
    ${ret}    csn.execute    command=cd ${feature_log_path};ls    connection=VM
    ${feature_dirs}    Split String    ${ret}
    ${feature_dir}    Get Matches    ${feature_dirs}    regexp=${feature_name}_\\d+
    ${exist_feature_dir}    Run Keyword And Return Status    Should Not Be Empty     ${feature_dir}
    Return From Keyword If    ${exist_feature_dir}==${False}    ${False}
    Log to Console    Output xml path is ${feature_dir}[0]${/}output.xml
    ${output_xml_exist}    Run Keyword And Return Status    File Should Exist
    ...    ${feature_log_path}${/}${feature_dir}[0]${/}output.xml
    Return From Keyword If    ${output_xml_exist}==${False}    ${False}
    ${sw}    Convert Trunk Sw Version To SBTS00    ${ACTIVE_SW_VERSION}
    ${command}    Catenate    ute_reporting_portal send -ie
    ...    -ro ${feature_log_path}${/}${feature_dir}[0]${/}output.xml
    ...    -tl ${TESTLINE_NAME}
    ...    --info "${TL_Type}"
    ...    -v --file_path "${robotfile_path}"
    ...    --sw_version "${sw}"
    ...    -l "${TL_Type}"
    ...    -ca RAN_PZ_HAZ_1
    ${ret}    OperatingSystem.Run     command=${command}    connection=VM
    Should Contain    ${ret}    Report was successfully sent to Reporting Portal
    ${ret_hash}    Get Regexp Matches    ${ret}
    ...    pattern=https://rep-portal.wroclaw.nsn-rdnet.net/reports/test-runs/\\?file_hash=[0-9a-zA-Z]+
    Log To Console    return url is ${ret_hash}[0]

Restart PA By APC
    pdu.setup_pdu    model=${tl.pdus[${APC_Index}].vendor}    host=${tl.pdus[${APC_Index}].addr}
    ...    alias=apc
    pdu.power_off    port=${tl.pdus[${APC_Index}].pdu_ports[1].port_no}    pdu_device=apc
    pdu.power_on     port=${tl.pdus[${APC_Index}].pdu_ports[1].port_no}    pdu_device=apc
    sleep    1min    reason=wait for pa restart


