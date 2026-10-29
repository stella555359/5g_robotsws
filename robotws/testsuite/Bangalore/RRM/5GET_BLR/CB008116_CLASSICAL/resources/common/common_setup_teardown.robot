*** Settings ***
Documentation       copyright:nokia
Resource    common_lib_variable.robot
Resource    common_admin.robot
Resource    common_ue_command.robot
Resource    common_log_capture.robot
Resource    common_file_operation.robot
Resource    common_deal_config_file.robot
Resource    check_pcap_file.robot
Resource    common_log_analyzer.robot
Resource    common_multi_cases.robot

*** Keywords ***
Clean Up Env
    Run Keyword And Ignore Error    CORE.Teardown Collectors    names=l2stream
    Run Keyword And Ignore Error    CORE.Teardown Collectors    names=btslog
    Run Keyword And Ignore Error    CORE.Teardown Collectors    names=testVM_Tcpdump
    Run Keyword And Ignore Error    CORE.Teardown Collectors    names=oamTShark
    Run Keyword And Ignore Error    CORE.Teardown Collectors    names=gnb_pm_counters
    Run Keyword And Ignore Error    CORE.Teardown Collectors    names=gnb_coam_snapShot
    Run Keyword And Ignore Error    coam.Teardown Admin
    Run Keyword And Ignore Error    SHERPA.Teardown    sherpa

Suite Setup Update GNB
    [Arguments]    ${swconfig_param}=${empty}    ${scf_file}=${empty}    ${iphy_file}=${empty}    ${swconfig_param_AP}=${empty}    ${log}=yes
    ...    ${force_reboot}=no
    [Documentation]    This keyword is to update the configuration of GNB and WTS both, and wait for configured.
    ...                It also capture the logs for cell setup.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${swconfig_param} | No | set RD parameter in swconfig file, e.g.0x580017=3;0x580019=1; |
    ...    | ${scf_file} | No | use scf.xml/delta.json to update gNB parameters |
    ...    |  |  | If ${scf_file} is endwith .xml, Full Commission With SCF File will be triggered. |
    ...    |  |  | If ${scf_file} is endwith .jsom, Delta Commission With SCF File will be triggered. |
    ...    |  |  | It usual exist in ${scf_path}/${SW_BRANCH}/SCF/${scf_file}. |
    ...    |  |  | ${scf_path} set in suite file, ${SW_BRANCH} is a suite variable, can be used directly. |
    ...    | ${iphy_file} | No | update iphy.xml. not support yet |
    ...
    ...    This keyword will reboot testline if need to update configuration.
    ...    The max times to reboot testline is set by ${MAX_REBOOT_TIME} to make sure the TL will onair.
    ...
    ...    Example1: no need to update anything
    ...    | Suite Setup | Run Keywords | Suite Setup Update GNB |
    ...    | ... | AND | Suite Setup Copy WTS Config Files From QT |
    ...    | ... | AND | Suite Setup Start WTS And Check OnAir |
    ...
    ...    Example2: no need to update WTS configuration
    ...    | Suite Setup | Run Keywords | Suite Setup Update GNB | scf_file=scf.xml | swconfig_param=0x580017=3;0x580019=1; |
    ...    | ... | AND | Suite Setup Copy WTS Config Files From QT |
    ...    | ... | AND | Suite Setup Start WTS And Check OnAir |
    ...
    ...    Example3: need update cfg file of WTS,${WTS_DIR}/${WTS_CFG} is a suite variable
    ...    | *** Variables *** | Set below variable if need to update WTS configuration file. | used in example3,5 |
    ...    | @{CFG_OLD_PARAMS} | plmn=[0-9]+:[0-9]+ |
    ...    | @{CFG_NEW_PARAMS} | plmn=302:610 |
    ...
    ...    | Suite Setup | Run Keywords | Suite Setup Update GNB | scf_file=delta.json | swconfig_param=0x580017=3;0x580019=1; |
    ...    | ... | AND | Suite Setup Copy WTS Config Files From QT |
    ...    | ... | AND | Modify Text File | ${WTS_DIR}/${WTS_CFG} | ${cfg_old_params} | ${cfg_new_params} |
    ...    | ... | AND | Suite Setup Start WTS And Check OnAir |
    ...
    ...    Example4: need update xml file of WTS,${WTS_DIR}/${WTS_AP_XML} is a suite variable
    ...    | *** Variables *** | Set below variable if need to update WTS configuration file. | used in example 4,5 |
    ...    | &{xml_params_dict} | prachStartSymbol=2 | prachPreambleFormat=8 | bestBeamRsrp=555 |
    ...
    ...    | Suite Setup | Run Keywords | Suite Setup Update GNB | scf_file=scf.xml | swconfig_param=0x580017=3;0x580019=1; |
    ...    | ... | AND | Suite Setup Copy WTS Config Files From QT |
    ...    | ... | AND | Modify XML File | ${WTS_DIR}/${WTS_AP_XML} | ${xml_params_dict} |
    ...    | ... | AND | Suite Setup Start WTS And Check OnAir |
    ...
    ...    Example5: need update config file of gNB and WTS
    ...    | Suite Setup | Run Keywords | Suite Setup Update GNB | scf_file=delta.json | swconfig_param=0x580017=3;0x580019=1; | |
    ...    | ... | AND | Suite Setup Copy WTS Config Files From QT |  |  |  |
    ...    | ... | AND | Modify Text File | ${WTS_DIR}/${WTS_CFG} | ${cfg_old_params} | ${cfg_new_params} |
    ...    | ... | AND | Modify XML File | ${WTS_DIR}/${WTS_AP_XML} | ${xml_params_dict} |
    ...    | ... | AND | Suite Setup Start WTS And Check OnAir |
    ...
    ...    Example6: need update config file of gNB and WTS from local
    ...    | *** Variables *** | Set below variable if need to update WTS configuration file. | used in example3,5 |
    ...    | ${LOCAL_WTS_DIR} | ${CURDIR}/config |
    ...    | ${WTS_CFG} | xxx.cfg |
    ...    | ${WTS_AP_XML} | xxx.xml |
    ...
    ...    | Suite Setup | Run Keywords | Suite Setup Update GNB | scf_file=delta.json | swconfig_param=0x580017=3;0x580019=1; |
    ...    | ... | AND | Suite Setup Copy WTS Config Files From Local | ${LOCAL_WTS_DIR} |
    ...    | ... | AND | Modify Text File | ${WTS_DIR}/${WTS_CFG} | ${cfg_old_params} | ${cfg_new_params} |
    ...    | ... | AND | Modify XML File | ${WTS_DIR}/${WTS_AP_XML} | ${xml_params_dict} |
    ...    | ... | AND | Suite Setup Start WTS And Check OnAir |
    ...
    Print Current Time    Start Robot File Time
    Clean Up Env
    Create Suite Directory
    Get All Testline Information And Set Suite Variable
    Print Testline Info Ahead Of Report
    Setup Connections
    Set CP Debug Log
    Run Keyword If    "${log}"=="yes"    common_log_capture.Start Logs    ${LOG_NAME_SUITE_SETUP}    ${SUITE_LOG_DIRECTORY}
    Get Default NRBTS DistName
    ${scf_file_type}    Get File Type    ${scf_file}
    Run Keyword If    '${iphy_file}'!='${empty}'    Modify IPHY File And Send to Airphone    ${iphy_file}
    Run Keyword If    '${swconfig_param}'!='${empty}'    Add RD Parameters To GNB Swconfig File    ${swconfig_param}
    Run Keyword If    '${swconfig_param_AP}'!='${empty}'    Add RD Parameters To Airphone Swconfig File    ${swconfig_param_AP}
    Run Keyword If    '${scf_file_type}'=='xml'    Full Commission With SCF File    ${scf_file}
    Run Keyword If    '${scf_file_type}'=='json'    Delta Commission With SCF File    ${scf_file}
    ${file_state}=    Evaluate    '${scf_file}'!='${empty}' or '${swconfig_param}'!='${empty}' or '${swconfig_param_AP}'!='${empty}'
    Run Keyword If    '${file_state}'=='${TRUE}' or '${force_reboot}'=='yes'
    ...    Reboot TL And Check Configured
Suite Setup Update GNB with full and delta commissioning
    [Arguments]    ${swconfig_param}=${empty}    ${scf_file}=${empty}    ${delta_file}=${empty}    ${iphy_file}=${empty}
    ...    ${swconfig_param_AP}=${empty}    ${log}=yes    ${force_reboot}=no

    Print Current Time    Start Robot File Time
    Clean Up Env
    Create Suite Directory
    Get All Testline Information And Set Suite Variable
    Print Testline Info Ahead Of Report
    Setup Connections
    Set CP Debug Log
    Run Keyword If    "${log}"=="yes"    common_log_capture.Start Logs    ${LOG_NAME_SUITE_SETUP}    ${SUITE_LOG_DIRECTORY}
    Get Default NRBTS DistName
    ${scf_file_type}    Get File Type    ${scf_file}
    Run Keyword If    '${iphy_file}'!='${empty}'    Modify IPHY File And Send to Airphone    ${iphy_file}
    Run Keyword If    '${swconfig_param}'!='${empty}'    Add RD Parameters To GNB Swconfig File    ${swconfig_param}
    Run Keyword If    '${swconfig_param_AP}'!='${empty}'    Add RD Parameters To Airphone Swconfig File    ${swconfig_param_AP}
    Full Commission With SCF File    ${scf_file}
    Delta Commission With SCF File    ${delta_file}
    ${file_state}=    Evaluate    '${scf_file}'!='${empty}' or '${swconfig_param}'!='${empty}' or '${swconfig_param_AP}'!='${empty}'
    Run Keyword If    '${file_state}'=='${TRUE}' or '${force_reboot}'=='yes'
    ...    Reboot TL And Check Configured
Get All Testline Information And Set Suite Variable
    Backup Scf    ${OUTPUT_DIR}    before_suite
    Get Default NRBTS DistName
    Get GNB Type From SCFC
    Get L1Bypass Type
    Run Keyword And Ignore Error    Get Testline Type
    Get Software Version
    Get Airphone Software Version
    Get WTS Version
    Get Control Board Type
    Run Keyword If    '${FCT_BOARD_TYPE}'!='ASOE'    Get Base Band Board Type
    Get RRU Type
    Get Testline Name

Print Testline Info Ahead Of Report
    Set Suite Metadata    Base Band Board Type    ${ASP_BOARD_TYPE}
    Set Suite Metadata    Control Board Type    ${FCT_BOARD_TYPE}
    Set Suite Metadata    RRU Type    ${RRU_TYPE}
    Set Suite Metadata    RRU Type List    ${RRU_TYPE_LIST}
    Set Suite Metadata    WTS Version    ${WTS_VERSION}
    Set Suite Metadata    Software Version Total    ${SW_VERSION_TOTAL}
    Set Suite Metadata    Software Version    ${SW_VERSION}

Suite Setup Copy WTS Config Files From QT
    [Documentation]    This keyword is to copy the configuration files of WTS from QT by testline type.
    ...    | QT config files | /home/ute/Auto5G/testsuite/QTPH1/AirPhone/resources. |
    ...    | git path | https://wrgitlab.int.net.nokia.com/5G/robotws5g/tree/master/testsuite/QTPH1/AirPhone/resources |
    ...
    ...    | for SA testline | l1_mode is L1Bypass | file is like l1b_tdd_sa_cmwv/0.800/AirPhoneConfig_l1bypass_tdd_sa_cmwv.xml |
    ...    | for NSA testline | l1_mode is FullStack | file is like  fs_fdd_nsa_cmwv/9.1800/AirPhoneConfig_fullstack_fdd_nsa_cmwv.xml |
    Copy WTS Common Config Files
    #Add the part to modify the UE capability to updated ones, since cfg file in QT is out of date sometime
    Run Keyword If    '${GNBCUTYPE}'=='SA' and '${CELLTECHNOLOGY}'=='TDD' and '${FR}'=='cmwv'
    ...    Modify UE Capabilities In CFG    ${WTS_DIR}/${WTS_CFG}    ${UE_NR_CAPABILITIES_PATT}    ${UE_NR_CAPABILITIES_VAL}

Copy WTS Common Config Files
    ${AP_BUILD}    OperatingSystem.Run    ls -l /opt/wts/ | grep latest
    ${AP_build_number}    String.Fetch From Right    ${AP_BUILD}    /opt/wts/
    Set Suite Variable    ${AP_configs}      ${WTS_CONFIG_PATH}/AP_configs_repo
    OperatingSystem.Run    rm -rf ${AP_configs}
    OperatingSystem.Run    git clone "https://gerrit.ext.net.nokia.com/gerrit/MN/5G/TEST/testconfigs" ${AP_configs}
    OperatingSystem.Run    cd ${AP_configs}; git checkout tags/${AP_build_number}
    ${config_yaml}=    Set Variable    ${AP_configs}/${SW_VERSION}/${GNBCUTYPE}/${L1_TYPE}/config.yaml
    ${dic}=    YAMLPARSER.Parse Yaml    ${config_yaml}    ${CELLTECHNOLOGY}    ${RF_TYPE}
    ...    ${FR}    ${RRU_TYPE}    ${FCT_BOARD_TYPE}    ${ASP_BOARD_TYPE}
    Log    ${dic}
    ${ap_xml_file}=    Collections.Get From Dictionary    ${dic}   WTS_ap
    ${wts_cfg_file}=    Collections.Get From Dictionary    ${dic}   WTS_config
    ${gnb_scf_file}=    Collections.Get From Dictionary    ${dic}   gNB_DU_scf
    ${gnb_swconfig_file}=    Collections.Get From Dictionary    ${dic}   gNB_swconfig
    ${ap_iphy_file}=    Collections.Get From Dictionary    ${dic}   AP_iphy_xml
    ${ap_swconfig_file}=    Collections.Get From Dictionary    ${dic}   AP_swconfig
    Set Suite Variable    ${ap_xml_file}    ${AP_configs}/${ap_xml_file}
    Set Suite Variable    ${wts_cfg_file}    ${AP_configs}/${wts_cfg_file}
    Set Suite Variable    ${gnb_scf_file}    ${AP_configs}/${gnb_scf_file}
    Set Suite Variable    ${gnb_swconfig_file}    ${AP_configs}/${gnb_swconfig_file}
    Set Suite Variable    ${ap_iphy_file}    ${AP_configs}/${ap_iphy_file}
    Set Suite Variable    ${ap_swconfig_file}    ${AP_configs}/${ap_swconfig_file}
    ${path}    ${WTS_AP_XML}=    OperatingSystem.Split Path    ${ap_xml_file}
    ${path}    ${WTS_CFG}=    OperatingSystem.Split Path    ${wts_cfg_file}
    OperatingSystem.Remove File    ${WTS_DIR}/AirPhoneConfig*.xml
    OperatingSystem.Remove File    ${WTS_DIR}/basic*.cfg
    ${ret}=    OperatingSystem.Run And Return Rc    cp ${ap_xml_file} ${WTS_DIR}/${WTS_AP_XML}
    ${ret}=    OperatingSystem.Run And Return Rc    cp ${wts_cfg_file} ${WTS_DIR}/${WTS_CFG}
    OperatingSystem.Run    sed -i 's/file=.*\.xml/file=${WTS_AP_XML}/' ${WTS_DIR}/${WTS_CFG}
    Set Suite Variable    ${WTS_CFG}
    Set Suite Variable    ${WTS_AP_XML}

Get Testline Type
    [Documentation]    This keyword is used to get testline type, CLOUD_5G_KL_AP_NSA_FS_CMWV_TDD etc.
    ${file_content}=    OperatingSystem.Get File    ${RESERVATION_FILE_PATH}
    &{testline_dict}=    json.Loads    ${file_content}
    ${testline_type}=    Collections.Get From Dictionary    ${testline_dict}    testline_type
    ${enb_build_version}=    Collections.Get From Dictionary    ${testline_dict}    enb_build
    Log    Testline type: ${testline_type}     console=${True}
    Set Suite Metadata    Testline type    ${testline_type}
    [Return]    ${testline_type}

Get L1Bypass Type
    [Documentation]    Get TL is configured as L1Bypass mode or FS mode
    ...    Examples:
    ...    | ${L1_type}= | Get L1Bypass Type |
    ${output}=    Run    (sleep 2s; echo "tag -a";sleep 2s)|sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 telnet localhost 15007
    ${result}=    Run Keyword And Return Status   should contain  ${output}   L1BypassMap
    Log    ${result}
    ${L1_TYPE}=    Set Variable IF     "${result}" == "True"    L1b    FS
    Set Suite Variable    ${L1_TYPE}    ${L1_TYPE}
    [Return]    ${L1_TYPE}

Get Radio Protocol Type
    [Arguments]    ${scfc_file}
    [Documentation]    This keyword to get radio protocol type from current scfc file
    ...    Examples:
    ...    | ${RF_TYPE}= | Get Radio Protocol Type| /tmp/SCF.xml |
    ${root}=    XML.Parse XML    ${scfc_file}
    Should Be Equal    ${root.tag}    raml
    ${radio_protocol}=    XML.Get Elements Texts    ${root}    xpath=.//p[@name="radioProtocolType"]
    ${rf}    Set Variable If    '${radio_protocol}[0]'=='eCPRI'    eCPRI    CPRI
    Set Suite Variable    ${RF_TYPE}    ${rf}
    [Return]    ${rf}

Suite Setup Copy WTS Config Files From Local
    [Arguments]    ${local_wts_dir}
    [Documentation]    This keyword is used to copy cfg and xml files from local path.
    ...    If this keyword is used, pls make sure you define below 3 parameters in your case.
    ...    ${LOCAL_WTS_DIR}    ${WTS_CFG}    ${WTS_AP_XML}
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${local_dir} | Yes | where cfg and xml files can be found |
    ...
    ...    Examples:
    ...    | *** Variables *** |
    ...    ${LOCAL_WTS_DIR}    ${CURDIR}/resources/wts
    ...    ${WTS_CFG}          basic_fullstack_nsa_call_tdd_cmwv.cfg
    ...    ${WTS_AP_XML}       AirPhoneConfig_fullstack_tdd_nsa_cmwv.xml
    ...
    ...    | Suite Setup Copy WTS Config Files From Local | local_dir=${LOCAL_WTS_DIR} |
    ...
    Get GNB Type From SCFC
    OperatingSystem.Run    cp ${local_wts_dir}/${WTS_CFG} ${WTS_DIR}
    OperatingSystem.Run    cp ${local_wts_dir}/${WTS_AP_XML} ${WTS_DIR}
    Wait Until Keyword Succeeds    5s    1s    OperatingSystem.File Should Exist    ${WTS_DIR}/${WTS_CFG}
    Wait Until Keyword Succeeds    5s    1s    OperatingSystem.File Should Exist    ${WTS_DIR}/${WTS_AP_XML}

Suite Setup Start WTS And Check OnAir
    [Arguments]        ${log}=yes
    [Documentation]    This keyword is to modify vlan, start WTS, wait for onAir
    Modify UTE SCTP Timeout
    Modify AP SCTP Timeout
    Configure UTE ETH3
    Start UTE WTS
#    Run Keyword If    '${GNBCUTYPE}'=='SANSA'    NG Link Should Be UP
#    Run Keyword If    '${GNBCUTYPE}'=='SANSA'    Address Distribution Should Be Successful
    Run Keyword If    '${GNBCUTYPE}'=='SANSA'    UE SIB Decoding Should Be Successful
    Run Keyword If    '${GNBCUTYPE}'=='SA'    UE SIB Decoding
    Run Keyword If    '${GNBCUTYPE}'=='NSA' or '${GNBCUTYPE}'=='SANSA'    Setup X2 Connection
    Verify Cell Setup
    [Teardown]    Run Keyword If    "${log}"=="yes"    common_log_capture.Stop Logs    ${LOG_NAME_SUITE_SETUP}    ${SUITE_LOG_DIRECTORY}

NG Link Should Be UP
    [Documentation]    This keyword is to wait for the message of SIB decoding.
    ...
    ...           Timeout is set by ${SIB_DECODE_TIMEOUT},the default value is 3 minutes
    ta5g_egate.Wait For Egate Console Output    expected_message=${Ng_link_pattern}    timeout=${SIB_DECODE_TIMEOUT}
    Log    sib_decoding_is_ok

Address Distribution Should Be Successful
    [Documentation]    This keyword is to wait for the message of SIB decoding.
    ...
    ...           Timeout is set by ${SIB_DECODE_TIMEOUT},the default value is 3 minutes
    ta5g_egate.Wait For Egate Console Output    expected_message=${Address_distribution_pattern}    timeout=${SIB_DECODE_TIMEOUT}
    Log    sib_decoding_is_ok

UE SIB Decoding Should Be Successful
    [Documentation]    This keyword is to wait for the message of SIB decoding.
    ...
    ...           Timeout is set by ${SIB_DECODE_TIMEOUT},the default value is 3 minutes
    ${ret}=    Run Keyword And Return Status    ta5g_egate.Wait For Egate Console Output    expected_message=${UE_SIB_decoding_pattern}
    ...    timeout=${SIB_DECODE_TIMEOUT}
    Run Keyword If    "${ret}"=="${False}"    Fail    msg=Cell not onair!!! No NR SIB received!!!
    Should Be True    ${ret}
    Log    sib_decoding_is_ok

Common Test Setup
    [Arguments]    ${delta_jason}=${none}    ${log}=yes
    [Documentation]    This keyword is to update parameters for this case.
    ...
    ...          1. Create test directory to store the logs for case
    ...
    ...          2. backup scf before update and after update parameters with jason file
    ...
    ...          3. start logs
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${delta_jason} | No | jason file,It usual exist in ${scf_path}/${SW_BRANCH}/SCF/${delta_json}. |
    ...    |  |  | ${SW_BRANCH} is get in keyword 'Suite Setup Update GNB', like 5G20A |
    ...
    ...    | *** Variables *** |
    ...    | ${SCF_PATH} | ${CURDIR}/config |
    ...
    ...    Examples1: no parameter need to update
    ...    | Common Test Setup |
    ...
    ...    Examples2: update parameter with jason file
    ...    | Common Test Setup | Delta_Conf_5GC002504_ET_01.json |
    Create Test Directory
    Run Keyword If    '${delta_jason}' != '${none}'    Backup Scf    ${TEST_LOG_DIRECTORY}    before_case
    Run Keyword If    '${delta_jason}' != '${none}'    Delta Commission With SCF File    ${delta_jason}
    Verify BTS Is OnAir
    Run Keyword If    '${delta_jason}' != '${none}'    Backup Scf    ${TEST_LOG_DIRECTORY}    after_case
    Run Keyword If    "${log}"=="yes"    common_log_capture.Start Logs    ${LOG_NAME_LIST}

Common Test Teardown
    [Arguments]    ${mode}=${EMPTY}    ${log}=yes
    [Documentation]    This keyword is to detach UE, and stop logs for case
    Run Keyword And Ignore Error    common_log_capture.Stop Logs    ${LOG_NAME_LIST}
    Run Keyword And Ignore Error    NSA LTE Detach    ${ue_id}
    Run Keyword And Ignore Error    SA 5G Detach    ${ue_id}
    Run Keyword If    '${mode}'!='debug'    Run Keyword If Test Failed    Collect UTE SosReport    ${TEST_LOG_DIRECTORY}
    Run Keyword And Ignore Error    Save Egate Log    ${TEST_LOG_DIRECTORY}
    Run Keyword And Ignore Error    Filter ERR WRN Message From Syslog By Log Path    ${TEST_LOG_DIRECTORY}    ${CURDIR}/filter_msg.txt
    ...    ${TEST_LOG_DIRECTORY}/case_fatal_log.txt
    Builtin.Log     ${log}

Common Suite Teardown
    [Arguments]    ${mode}=${EMPTY}    ${collect_config_file}=${FALSE}
    [Documentation]    This keyword is to collect the logs.
    Run keyword If    '${FLAG_CATCH_SUITE_LOG}'=='${True}'    common_log_capture.Stop Logs    ${LOG_NAME_SUITE_SETUP}    ${SUITE_LOG_DIRECTORY}
    Run Keyword And Ignore Error    Show Relation Errors If Exist
    Run Keyword If    '${collect_config_file}'=='${TRUE}' and '${SUITE STATUS}'=='PASS'
    ...    Get Config Files And Put To Local Log Server
    Run Keyword If    '${mode}'!='debug'    Run Keyword And Ignore Error    Stop Logs    ${LOG_NAME_SUITE_TEARDOWN}    ${SUITE_LOG_DIRECTORY}
    Run Keyword If    '${mode}'!='debug'    Run Keyword And Ignore Error    Run Keyword If Any Tests Failed
    ...    Collect UTE SosReport    ${SUITE_LOG_DIRECTORY}
    common_log_capture.Teardown All Connections
    ute_wtssim.Teardown All Aliases For Wts
    Run Keyword And Ignore Error    Filter ERR WRN Message From Syslog By Log Path    ${SUITE_LOG_DIRECTORY}    ${CURDIR}/filter_msg.txt
    ...    ${SUITE_LOG_DIRECTORY}/suite_fatal_log.txt

Save Egate Log
    [Arguments]    ${log_path}=${SUITE_LOG_DIRECTORY}
    ute_wtssim.Execute Egate Command    sim_log_set flush
    OperatingSystem.Run    cp /opt/wts/latest/egate_console.log ${log_path}

Create Suite Directory
    [Documentation]    This keyword is to create a directory for storing suite level logs.
    ...
    ...    ${SUITE_LOG_DIRECTORY} is a suite variable.
    ...    before refine: Test_Suite_Folder_1605087516120
    ...    after refine: Test_Suite_Folder_20201112151625116
    Log To Console    Create Suite Directory...
    Log    ${SUITE_NAME}
    ${time_string}    DateTime.Get Current Date    result_format=timestamp
    ${time_string}    String.Replace String Using Regexp    ${time_string}    (-|:)    ${EMPTY}
    ${time_string}    String.Replace String    ${time_string}    ${SPACE}    ${EMPTY}
    ${time_string}    String.Remove String    ${time_string}    .
    ${suite_name2}    String.Replace String    ${SUITE_NAME}    ${SPACE}    _
    Create Directory    ${OUTPUT_DIR}/log/${suite_name2}_${time_string}
    Set Suite Variable    ${SUITE_LOG_DIRECTORY}    ${OUTPUT_DIR}/log/${suite_name2}_${time_string}

Create Test Directory
    [Documentation]    This keyword is to create a directory for storing case level logs.
    ...
    ...        ${TEST_LOG_DIRECTORY} is a test variable.
    Log To Console    Create Case Directory...
    ${test_name2}    string.Replace String    ${TEST_NAME[:50]}    ${space}    _
    Create Directory    ${SUITE_LOG_DIRECTORY}/${test_name2}
    Set Test Variable    ${TEST_LOG_DIRECTORY}    ${SUITE_LOG_DIRECTORY}/${test_name2}

Stop Cell Setup Logs
    [Documentation]    This keyword is to collect logs for cell setup
    Log To Console    Stop Cell Setup logs...
    Backup Scf    ${SUITE_LOG_DIRECTORY}    after_suite
    Stop And Collect Syslog    log_dir=${SUITE_LOG_DIRECTORY}
    Collect GNB Snapshot Via Aashell    log_dir=${SUITE_LOG_DIRECTORY}
    Collect AP Snapshot Via Aashell    log_dir=${SUITE_LOG_DIRECTORY}

Reboot TL And Check Configured
    [Documentation]    This keyword is to soft reboot testline and check the status is configured.
    ...            It with try ${MAX_REBOOT_TIME} times to make sure the testline can be reboot successfully.
    Log To Console    Make sure BTS site is ready by rebooting at most ${MAX_REBOOT_TIME} times...
    FOR    ${index}    IN RANGE    1    ${MAX_REBOOT_TIME}+1
        Log To Console    ===============Reboot Time: ${index}==============
        # Reboot Testline Via SSH
        Hard Reboot Testline
        ${res}    Run Keyword And Return Status    Verify coam Site Is Ready
        Exit For Loop If    '${res}'=='True'
    END

Start UTE WTS
    [Documentation]    This keyword is to kill Running WTS Binaries If Any, Configure ETH3, Retrieve Files And Configure WTS
    Log To Console    Starting WTS...
    Run Keyword And Ignore Error    Stop Edaemon Egate
    Run Keyword And Ignore Error    Adapt Cfg File Nrafcn Value With Scf    ${WTS_DIR}/${WTS_CFG}
    Run Keyword And Ignore Error    Get IpAddr From Scf And Cfg
    ute_wtssim.Setup Edaemon    edaemon_port=22222    tool_dir=${WTS_DIR}    alias=edaemon
    ute_wtssim.Start Edaemon Process    alias=edaemon
    ute_wtssim.Setup Egate    egate_port=20000    tool_dir=${WTS_DIR}
    ute_wtssim.Start Egate Process
    Run Keyword If    '${GNBCUTYPE}'=='SA'    ute_wtssim.Execute Egate Command    cfg file\=${WTS_DIR}/${WTS_CFG}
    ...    pass_regexp=SCTP proxy link
    Run Keyword If    '${GNBCUTYPE}'=='NSA' or '${GNBCUTYPE}'=='SANSA'    ute_wtssim.Execute Egate Command    cfg file\=${WTS_DIR}/${WTS_CFG}
    ...    pass_regexp=(SimMode is ready now|UEC-1 is active)
#    Run Keyword If    '${GNBCUTYPE}'=='NSA' or '${GNBCUTYPE}'=='SANSA'    Wait Until Keyword Succeeds    120sec    15sec
#    ...    ute_wtssim.Execute Egate Command    state_sim_disp    pass_regexp=The state is ACTIVE

Change WTS VM Timezone to UTC
    OperatingSystem.Run    sudo timedatectl set-timezone UTC

Stop Edaemon Egate
    OperatingSystem.Run    sudo pkill edaemon
    OperatingSystem.Run    sudo pkill egate
    OperatingSystem.Run    sudo pkill 22222
    OperatingSystem.Run    sudo pkill 20000

Modify UTE SCTP Timeout
    [Documentation]    This keyword is to start AirPhone load 4.0.10852, The Sack Timeout In The WTS VM And AP ASIK Must Be
    ...    configured before cell setup.This Aims To Prevent Delayed Messaging Between AirPhone
    ...    and WTS (e.g. CTRL_ADD_UE_NR for attach procedure).
    Log To Console    Modify UTE SCTP Timeout...
    OperatingSystem.Run    sudo sysctl -w net.sctp.sack_timeout=20
    OperatingSystem.Run    sudo sysctl -w net.sctp.rto_min=200
    OperatingSystem.Run    sudo sysctl -w net.sctp.rto_initial=200
    OperatingSystem.Run    sudo sysctl -w net.sctp.rto_max=800

Modify AP SCTP Timeout
    [Documentation]    This keyword is to Modify AP SCTP Timeout in Airphon ASIK
    ...      To Prevent Delayed Messaging Between AirPhone and WTS (e.g. CTRL_ADD_UE_NR for attach procedure).
    Log To Console    Modify AP SCTP Timeout...
    ${command}    Catenate    sysctl -w net.sctp.sack_timeout=10 &&
    ...    sysctl -w net.sctp.rto_min=200 &&
    ...    sysctl -w net.sctp.rto_initial=200 &&
    ...    sysctl -w net.sctp.rto_max=800
    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.200.1 '${command}'

Configure UTE ETH3
    [Documentation]    This keyword is to configure VM interfaces.
    Log To Console    configure VM interfaces...
    OperatingSystem.Run    sudo ip addr add 10.0.1.131/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.132/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.133/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.134/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.135/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.136/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.99/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.2.99/24 dev eth4
    OperatingSystem.Run    sudo ip addr add 10.0.1.121/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.137/24 dev eth3

Open GNB Syslog Button For Workaround
    OperatingSystem.Run    ${SSH_CMD} sed -i s'/0x10041=1/0x10041=5/' /ffs/run/swconfig.txt

Get Software Version
    ${coam_connection}    coam.Connect To    bts_host=${GNB_ASIK.ip}
    ${software_info_1}=    coam.Get Sw Version    connection=${coam_connection}
    Set Suite Variable    ${SOFTWARE_INFO}    ${software_info_1}
    Log    Software Version: ${SOFTWARE_INFO}    console=${True}    #5G21B_GNB_0000_000800_004084_0oeo9    5G21A_GNB_0011_000800_000601
    ${ENB_BUILD}=    String.Get Substring    ${SOFTWARE_INFO}    0    4
    Set Suite Variable    ${ENB_BUILD}
    Run Keyword If    "${ENB_BUILD}"=="SBTS"    Get Software Version On Common Package
    ...    ELSE    Get Software Version On 5G Pacakge
    [Teardown]    coam.Teardown    ${coam_connection}

Get Software Version On 5G Pacakge
    [Documentation]    This keyword is to get gNB software version including below 3 suite variables.
    ...
    ...    | Suite variable | Example | Description |
    ...    | ${SW_VERSION} | 0.800 | get the QT config files with the related version |
    ...    | ${SW_VERSION_TOTAL} | 0.800.779 | total sw version |
    ...    | ${SW_BRANCH} | 5G20B | the folder to stort config files for case |
    ...
    @{sw_list}    String.Split String    ${SOFTWARE_INFO}    _
    ${status}    Run Keyword And Return Status    Should Be True    ${sw_list[2]}==0000
    ${version_0}    String.Get Regexp Matches    ${sw_list[2]}    [1-9]+[0-9]*    #return a list
    ${version_1}    String.Get Regexp Matches    ${sw_list[3]}    [1-9]+[0-9]*
    ${version_2}    String.Get Regexp Matches    ${sw_list[4]}    [1-9]+[0-9]*
    Run Keyword If    '${status}'=='True'    Set Suite Variable    ${SW_VERSION}    0.${version_1[0]}
    ...    ELSE    Set Suite Variable    ${SW_VERSION}    ${version_0[0]}.${version_1[0]}
    Run Keyword If    '${status}'=='True'    Set Suite Variable    ${SW_VERSION_TOTAL}    0.${version_1[0]}.${version_2[0]}
    ...    ELSE    Set Suite Variable    ${SW_VERSION_TOTAL}    ${version_0[0]}.${version_1[0]}.${version_2[0]}
    Set Suite Variable    ${SW_BRANCH}    ${sw_list[0]}
    Log    Software Version Total: ${SW_VERSION_TOTAL}    console=${True}

Get Software Version On Common Package
    [Documentation]    This keyword is to get gNB software version including below 3 suite variables.
    ...
    ...    | Suite variable | Example | Description |
    ...    | ${SW_VERSION} | SBTS00 | get the QT config files with the related version |
    ...    | ${SW_VERSION_TOTAL} | SBTS21B_ENB_9999_210324_000019 | total sw version |
    ...    | ${SW_BRANCH} | SBTS21B | the folder to stort config files for case |
    ...
    @{sw_list}    String.Split String    ${SOFTWARE_INFO}    _
    ${status}    Run Keyword And Return Status    Should Be True    ${sw_list[2]}==9999
    Run Keyword If    '${status}'=='True'    Set Suite Variable    ${SW_VERSION}    SBTS00
    ...    ELSE    Set Suite Variable    ${SW_VERSION}    ${sw_list[0]}
    Run Keyword If    '${status}'=='True'    Set Suite Variable    ${SW_VERSION_TOTAL}
    ...    SBTS00_${sw_list[1]}_${sw_list[2]}_${sw_list[3]}_${sw_list[4]}
    ...    ELSE    Set Suite Variable    ${SW_VERSION_TOTAL}    ${SOFTWARE_INFO}
    Set Suite Variable    ${SW_BRANCH}    ${sw_list[0]}
    Log    Software Version Total: ${SW_VERSION_TOTAL}    console=${True}

Get Airphone Software Version
    ute_fsmaccess.Setup Wts Fsm Access
    ${cmd}=    Set Variable    ls /ffs/run/TargetBD_*.xml
    ${targetbd_file}=    ute_fsmaccess.Execute Command On Wts    ${cmd}
    ${tmp1}=    String.Fetch From Right    ${targetbd_file}    TargetBD_
    ${AP_version}=    String.Fetch From Left    ${tmp1}    .xml
    Log    AP Software Version: ${AP_version}      console=${True}
    Set Suite Metadata    AP Version    ${AP_version}
    [Teardown]    ute_fsmaccess.Teardown Wts Fsm Access
    [Return]    ${AP_version}

Get WTS Version
    [Documentation]    This keyword is to get WTS version including below 1 suite variable.
    ...
    ...    | Suite variable | Example | Description |
    ...    | ${WTS_VERSION} | 4.0.13303 | WTS version |
    ...
    ${rc}    ${output}    OperatingSystem.Run And Return Rc And Output    ls -la /opt/iphy/latest
    @{split_list}    String.Split String    ${output}    /
    Set Suite Variable    ${WTS_VERSION}    ${split_list[-1]}
    Log    WTS Version: ${WTS_VERSION}     console=${True}

Get Default NRBTS DistName
    [Documentation]    This keyword is to get the NRBTS distname for current gNB. e.g.MRBTS-1/NRBTS-1
    coam.Setup Admin    bts_host=${GNB_ASIK.ip}
    ${cells_info}=    coam.Get Cell List
    ${dist_name}=    Set Variable    ${cells_info['cells']['nr'][0]['id']['configuration']}
    Log    ${dist_name}
    ${mrbts}    ${nrbts}    ${nrcell}    String.Split String    ${dist_name}    /
    Set Suite Variable    ${NRBTS_DISTNAME}    ${mrbts}/${nrbts}
    Set Suite Variable    ${MRBTS_DISTNAME}    ${mrbts}
    Log To Console    NRBTS_DISTNAME: ${NRBTS_DISTNAME}
    [Teardown]    Run Keyword And Ignore Error    coam.Teardown

Verify BTS Procedural State
    [Arguments]    ${alias}=coam    ${proceduralstates}=Configured    ${timeout}=30
    [Documentation]    Verify BTS Procedural State And Blocking State
    ...    alias:    AdminConnection Object Or If Used, String Name Alias
    ...    timeout: Time to wait for positive procedure result
    ...    proceduralStates: (string or list) BTS procedural States, opetions=Configured or OnAir or Commissioned
    ${cells_info}=    coam.Get Cell List    alias=${alias}
    ${bts_status}=    coam.Get Bts Statuses    timeout=${timeout}    connection=${alias}
    List Should Contain Value    ${proceduralstates}    ${bts_status['proceduralState']}
    Should Be Equal    ${bts_status['blockingState']}    Unblocked    ignore_case=true
    [Teardown]    Run Keyword And Ignore Error    coam.Teardown

Modify File Parameter
    [Arguments]    ${file_path}    ${old_value}    ${new_value}
    [Documentation]    This keyword is to replace string for file
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${file_path} | No | the file path which need to modify |
    ...    | ${old_value} | No | the value need to be replaced |
    ...    | ${new_value} | No | the new value |
    ...
    ...    Examples:
    ...    | ${delta_path} | OperatingSystem.Join Path | ${scf_path} | ${SW_BRANCH} | SCF | Delta_Conf_5GC002504.json |
    ...    | Modify File Parameter | ${delta_path} | MRBTS-[0-9]+/NRBTS-[0-9]+ | ${NRBTS_DISTNAME} |
    ${content}=    OperatingSystem.Get File    path=${file_path}
    ${content}=    String.Replace String Using Regexp    string=${content}    pattern=${old_value}    replace_with=${new_value}
    OperatingSystem.Create File    path=${file_path}    content=${content}

Get BTS Id
    [Documentation]    This keyword is to get BTS id in current env
    coam.Setup Admin
    ${cells_info}=    coam.Get Cell List
    ${dist_name}=    Set Variable    ${cells_info['cells']['nr'][0]['id']['configuration']}
    Log    ${dist_name}
    ${mrbts}    ${nrbts}    ${nrcell}    String.Split String    ${dist_name}    /
    ${bts_id}    Fetch From Right    ${mrbts}    -
    [Return]    ${bts_id}
    [Teardown]    Run Keyword And Ignore Error    coam.Teardown

Delta Commission With SCF File
    [Arguments]    ${delta_json}
    [Documentation]    This keyword is to update parameters with delta file
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | delta_json | Yes | delta file name.It usual exist in ${scf_path}/${SW_BRANCH}/SCF/${delta_json}. |
    ...    |  |  | ${SW_BRANCH} is get in keyword 'Suite Setup Update GNB', like 5G20A |
    ...
    ...    Examples:
    ...    | *** Variables *** |
    ...    | ${scf_path} | Set Variable | ${CURDIR}/config |
    ...    | Delta Commission With SCF File | Delta_Conf_5GC002504.json |    |
    ...    Example2:
    ...    | ${delta_json} | Set Variable | ${CURDIR}/delta.json |
    ...    | Delta Commission With SCF File | ${delta_json} |    |
    Log To Console    Perform delta commissioning...
    coam.Setup Admin
    #${delta_path}=    OperatingSystem.Join Path    ${scf_path}    ${SW_BRANCH}    SCF    ${delta_json}
    ${join_delta_path}=    OperatingSystem.Join Path    ${scf_path}    ${SW_BRANCH}    SCF    ${delta_json}
    ${is_join_path_file_exist}=    Run Keyword And Return Status    File Should Exist    ${join_delta_path}
    ${delta_path}    Set Variable If    ${is_join_path_file_exist}==True    ${join_delta_path}    ${delta_json}
    Modify File Parameter    ${delta_path}    MRBTS-[0-9]+/NRBTS-[0-9]+    ${NRBTS_DISTNAME}
    coam.Perform Delta Recommissioning
    ...    delta_file=${delta_path}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=300
    [Teardown]    Run Keyword And Ignore Error    coam.Teardown

Full Commission With SCF File
    [Arguments]    ${scf_file}
    [Documentation]    This keyword is to update parameters with delta file
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | scf_file | Yes | SCF file name.It usual exist in ${scf_path}/${SW_BRANCH}/SCF/${scf_file}. |
    ...    |  |  | ${SW_BRANCH} is get in keyword 'Suite Setup Update GNB', like 5G20A |
    ...
    ...    Examples:
    ...    | *** Variables *** |
    ...    | ${scf_path} | Set Variable | ${CURDIR}/config |
    ...    | Full Commission With SCF File | SCF_5GC002504.xml |    |
    ...    Example2:
    ...    | ${scf_file} | Set Variable | ${CURDIR}/scf.xml |
    ...    | Full Commission With SCF File | ${scf_file} |    |
    Log To Console    Perform full commissioning?please use the scf with full configuration saved.
    ${join_scf_path}=    OperatingSystem.Join Path    ${scf_path}    ${SW_BRANCH}    SCF    ${scf_file}
    ${is_join_path_file_exist}=    Run Keyword And Return Status    File Should Exist    ${join_scf_path}
    ${scf_path}    Set Variable If    ${is_join_path_file_exist}==True    ${join_scf_path}    ${scf_file}
    Modify File Parameter    ${scf_path}    MRBTS-[0-9]+/NRBTS-[0-9]+    ${NRBTS_DISTNAME}
    Modify VlanId In SCF File    ${scf_path}
    ${new_scf_path}    Migration SCF To New Release    ${scf_path}
    ${bts_id}    Get BTS Id
    coam.Setup Admin
    coam.Perform Commissioning
    ...    bts_id=${bts_id}
    ...    scf_file=${new_scf_path}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=300
    [Teardown]    Run Keyword And Ignore Error    coam.Teardown

Connect To AP ASIK
    [Documentation]    This keyword is to connect to Airphone ASIK
    ssh.Connect To    ${AP_ASIK.ip}    ${AP_ASIK.username}    ${AP_ASIK.password}
    ...    alias=${AP_ASIK.connection}

Connect To GNB FCT
    Connect To GNB ASIK

Connect To GNB ASIK
    [Documentation]    This keyword is to connect to Airphone ASIK
    ssh.Connect To    ${GNB_ASIK.ip}    ${GNB_ASIK.username}    ${GNB_ASIK.password}
    ...    alias=${GNB_ASIK.connection}

Add RD Param To Swconfig File
    [Arguments]    ${id_value}    ${conn_type}=GNB_ASIK
    [Documentation]    This keyword is to update RD parameters in swconfig file.
    ...
    ...    If the RD parameter exist. this keyword will be updated
    ...
    ...    If the RD parameter not exist. this keyword will be added.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${id_value} | Yes | RD parameter, split by ;. e.g.0x580017=3;0x580019=1; |
    ...    | ${connection_type} | No | GNB_ASIK/AP_ASIK, the default value is GNB_ASIK |
    ...
    ...    Examples:
    ...    | Add RD Param To Swconfig File | 0x580017=3;0x580019=1; |
    Log    [Add RD Param To Swconfig File]This keyword will be deprecated soon...    level=WARN
    Log To Console    Start to modify RD params...
    @{id_value_lst}    Split String    ${id_value}    ;
    ${cmd_2}    Set Variable    rm /ffs/run/swconfig.txt.p7;crasign /ffs/run/swconfig.txt
    Wait Until Keyword SucceedS    2 min    10 s    ssh.Connect To    ${${conn_type}.ip}    ${${conn_type}.username}
    ...    ${${conn_type}.password}    alias=${${conn_type}.connection}
    : FOR    ${params}    IN    @{id_value_lst}
    \    @{param_value}    Split String    ${params}    =
    \    ${feature_flag_org}    ssh.Execute    command=cat /ffs/run/swconfig.txt |grep @{param_value}[0]    connection=${${conn_type}.connection}
    \    ${feature_flag}    Fetch From Left    ${feature_flag_org}    marker=\r\n
    \    ${len}    Get Length    ${feature_flag}
    \    Set Suite Variable    ${len}
    \    ${cmd_0}    Set Variable    command=cp /ffs/run/swconfig.txt /ffs/run/swconfig_bak.txt
    \    ${cmd_1}    Set Variable    sed -i '$a ${params}' /ffs/run/swconfig.txt
    \    ${cmd_3}    Set Variable    sed -ie 's/${feature_flag}/${params}/g' /ffs/run/swconfig.txt
    \    ${cmd A}    Catenate    SEPARATOR=;    ${cmd_0}    ${cmd 1}    ${cmd 2}
    \    ${cmd B}    Catenate    SEPARATOR=;    ${cmd_0}    ${cmd 3}    ${cmd 2}
    \    Run Keyword If    ${len} == ${0}    ssh.Execute    command=${cmd_a}    connection=${${conn_type}.connection}
    \    Run Keyword Unless    ${len} == ${0}    ssh.Execute    command=${cmd_b}    connection=${${conn_type}.connection}

Reboot Testline Via SSH
    [Documentation]    This keyword is to reboot gNB and Airphone with reboot command
    Log To Console    Reboot testline via ssh...
    OperatingSystem.Run And Return Rc And Output
    ...    sshpass -p ${GNB_ASIK.password} ssh ${GNB_ASIK.username}@${GNB_ASIK.ip} 'reboot'
    Sleep    2s
    OperatingSystem.Run And Return Rc And Output
    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} 'reboot'

Setup X2 Connection
    [Documentation]    This keyword is to setup X2 connection and check x2 is ok
    Log To Console    setup X2 connection...
    ${pattern}    Set Variable    ENB-1: X2AP Link with GNB-2 .* is up
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    enb_x2_link_up enb\=1 target\=2
    ...    pass_regexp=${pattern}    timeout=5min
    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    Log To Console    \n${output}
    Log    x2_is_ok

UE SIB Decoding
    [Documentation]    This keyword is to wait for the message of SIB decoding.
    ...
    ...           Timeout is set by ${SIB_DECODE_TIMEOUT},the default value is 3 minutes
    ta5g_egate.Wait For Egate Console Output    expected_message=SystemInformationBlockType1    timeout=${SIB_DECODE_TIMEOUT}
    Log    sib_decoding_is_ok

Verify Cell Setup
    [Documentation]    This keyword is to wait for cell setup successfully.
    ...
    ...           The max waiting time is set by ${MAX_WAITTIME_CELL_SETUP},the default value is 3 minutes
    Log To Console    verify cell setup...
    Wait Until Keyword Succeeds    ${MAX_WAITTIME_CELL_SETUP}    15s    Check UTE ASIK AP Cell Setup
    Log    cell_setup_is_ok

Check UTE ASIK AP Cell Setup
    [Documentation]    This keyword is to check "Cell Setup Completed" in Airphone ASIK
    Log To Console    check ute ASIK AP cell setup...
    ${cmd}=    Set Variable    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.200.1 grep -i "Cell Setup Completed" /tmp/APL3.log 2>/dev/null
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    ${cmd}
    Should Contain    ${output}    Cell Setup Completed    ignore_case=True
    #Log To Console    ${output}

Get Single Value From Scf File
    [Arguments]    ${file_path}    ${dist_name}    ${para_name}    ${list_name}=${EMPTY}
    [Documentation]    This keyword is to get single parameter value from SCF file
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${file_path} | Yes | SCF file path |
    ...    | ${dist_name} | Yes | dist name for the parameter |
    ...    | ${para_name} | Yes | parameter name |
    ...    | ${list_name} | No | list name if the parameter in list, the default value is ${EMPTY} |
    ...
    ...    Examples:
    ...    | Get Single Value From Scf File | ${SUITE_LOG_DIRECTORY}/SCF_before_suite.xml | MRBTS-1/NRBTS-1 | gNbCuType |
    ...    | Get Single Value From Scf File | ${SUITE_LOG_DIRECTORY}/SCF_before_suite.xml | MRBTS-1/NRBTS-1 | actDddsReduction | qciTab5Nsa3x |
    ${root}=    XML.Parse XML    ${file_path}
    Should Be Equal    ${root.tag}    raml
    ${ele}=    Run Keyword If    '${list_name}' == '${empty}'
    ...    XML.Get Element    ${root}    .//managedObject[@distName='${dist_name}']//p[@name='${para_name}']
    ...    ELSE    XML.Get Element    ${root}    .//managedObject[@distName='${dist_name}']//list[@name='${list_name}']//p[@name='${para_name}']
    [Return]    ${ele.text}

Get GNB Type From SCFC
    [Arguments]    ${file_path}=${OUTPUT_DIR}/SCF_before_suite.xml
    [Documentation]    This keyword is to the value of GNB type from current SCF
    ...
    ...    | gNbCuType | NSA/SA/both |
    ...    | cellTechnology | TDD/FDD |
    ...    | freqBandIndicatorNR | mmwv/cmwv | freqBandIndicatorNR>=127 == FR2==mmmv |
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | file_path | No | SCF file path. the default value is ${SUITE_LOG_DIRECTORY}/SCF_before_suite.xml |
    ...
    ...    Examples:
    ...    | Get GNB Type From SCFC |  |  |
    ${GNBCUTYPE}=    Get Single Value From Scf File    ${file_path}    ${NRBTS_DISTNAME}    gNbCuType
    ${GNBCUTYPE}=    Set Variable If    "${GNBCUTYPE}"=="both" or "${GNBCUTYPE}"=="SA+NSA"    SANSA    ${GNBCUTYPE}
    ${CELLTECHNOLOGY}=    Get Single Value From Scf File    ${file_path}    ${NRBTS_DISTNAME}/NRCELL-1    cellTechnology
    ${band_value}=    Get Single Value From Scf File    ${file_path}    ${NRBTS_DISTNAME}/NRCELL-1    freqBandIndicatorNR
    ${fr_tag}    Evaluate    int(${band_value})>=int(127)
    ${FR}    Set Variable If    '${fr_tag}'=='True'    mmwv    cmwv
    ${rf}=    Get Radio Protocol Type    ${file_path}
    Set Suite Variable    ${GNBCUTYPE}
    Set Suite Variable    ${CELLTECHNOLOGY}
    Set Suite Variable    ${FR}
    Set Suite Variable    ${RF_TYPE}    ${rf}

Get File Type
    [Arguments]    ${file}
    [Documentation]    This keyword is to get the name extension of a file
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${file} | Yes | file name need to get the name extension |
    ...
    ...    Examples:
    ...    | Get File Type | delta.json |
    ...    | Get File Type | scf.xml |
    @{file_list}    String.Split String    ${file}    .
    [Return]    ${file_list[-1]}

Set Single Value From Scf File
    [Arguments]    ${file_path}    ${dist_name}    ${para_name}    ${para_value}    ${list_name}=${EMPTY}
    [Documentation]    This keyword is to get single parameter value from SCF file
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${file_path} | Yes | SCF file path |
    ...    | ${dist_name} | Yes | dist name for the parameter |
    ...    | ${para_name} | Yes | parameter name |
    ...    | ${list_name} | No | list name if the parameter in list, the default value is ${EMPTY} |
    ...
    ...    Examples:
    ...    | ${file_path} | Set Variable | ${suite_log_directory}/SCF_before_suite.xml |
    ...    | Set Single Value From Scf File | ${file_path} | MRBTS-1/NRBTS-1 | vlanId | 1901 |
    ...    | Set Single Value From Scf File | ${file_path} | MRBTS-1/NRBTS-1 | actDddsReduction | false | qciTab5Nsa3x |
    ${root}=    XML.Parse XML    ${file_path}
    Should Be Equal    ${root.tag}    raml
    Run Keyword If    '${list_name}' == '${empty}'
    ...    XML.Set Element Text    source=${root}    text=${para_value}    xpath=.//managedObject[@distName='${dist_name}']//p[@name='${para_name}']
    ...    ELSE    XML.Set Element Text    source=${root}    text=${para_value}
    ...    xpath=.//managedObject[@distName='${dist_name}']//list[@name='${list_name}']//p[@name='${para_name}']
    XML.Save Xml    ${root}    ${file_path}

Modify VlanId In SCF File
    [Arguments]    ${scf_path}
    [Documentation]    This keyword is to make sure VlanId in SCF file as the same as the testline.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |${scf_path} | Yes | the path for scf file, the modified file path is same as the origin one. |
    ...
    ...    Examples:
    ...    | Modify VlanId In SCF File | ${CURDIR}/SCF_after_suite.xml |
    ${vlanif_distname}    Set Variable    ${MRBTS_DISTNAME}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1
    ${vlan_id}    Convert To String    ${VLAN_ID}
    ${vlan_id_scf}    Get Single Value From Scf File    file_path=${scf_path}    dist_name=${vlanif_distname}    para_name=vlanId
    Log To Console    VlanId in Testline: ${vlan_id}
    Log To Console    VlanId in Origin SCF file: ${vlan_id_scf}
    Set Single Value From Scf File    file_path=${scf_path}
    ...    dist_name=${vlanif_distname}    para_name=vlanId    para_value=${vlan_id}

Migration SCF To New Release
    [Arguments]    ${scf_path}
    [Documentation]    This keyword is to use ADMIN CLI to migration SCF for new version.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${scf_path} | Yes | the path name for SCF file which need to migrate.
    ...           The SCF file should be saved with FULL CONFIGURATION as need to know swVerion for the SCF file. |
    ...
    ...    Examples:
    ...    | Migration SCF To New Release | /home/ute/Auto5G/testsuite/RRM/ECE/CUDU_L2/Full_Configuration_scf.xml |
    Log To Console    Migration SCF To New Release...
    ${branch}    Evaluate    '${SW_VERSION_TOTAL}'.startswith('0.800')
    ${sw_branch}   Set Variable If    '${branch}'=='True'    5G    ${SW_BRANCH}
    ${admin_cli_name}    Set Variable    ${sw_branch}_${SW_VERSION_TOTAL}_ADMIN_CLI.zip
    ${scf_list}    String.Split String    ${scf_path}    .x
    ${output_scf_path}    Set Variable    ${scf_list[0]}_new_version.xml
    ${download_status}    Download Zip From WFT    sw=${SW_VERSION_TOTAL}    file_name=${admin_cli_name}    store_path=${output_dir}
    ${version_new}    Judge SCF SW Version    ${scf_path}
    Run Keyword If    '${Version_new}'=='False'    Log To Console    SW version isn't older than that of the testline.
    Run Keyword If    '${download_status}'=='False'    Log To Console    ${admin_cli_name} doesn't exist in release.
    Run Keyword If    '${download_status}'=='True' and '${Version_new}'=='True'
    ...    Unzip And Do Migration SCF    ${output_dir}    ${admin_cli_name}    ${scf_path}    ${output_scf_path}
    ${new_scf_path}    Set Variable If    '${download_status}'=='True' and '${Version_new}'=='True'    ${output_scf_path}    ${scf_path}
    [Return]    ${new_scf_path}

Download Zip From WFT
    [Arguments]    ${sw}    ${file_name}    ${store_path}
    [Documentation]    This keyword is to download zip file from release note.
    ...    used in keyword 'Migration SCF To New Release'
    ...    Return ${download_status}, if download success, it's True. if not, it's False.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${sw} | Yes | the sw release, such as 0.800.1487 |
    ...    | ${file_name} | Yes | the file need to download, such as 5G_0.800.1487_ADMIN_CLI.zip |
    ...    | ${store_path} | Yes | the path need to store from download,such as ${output_dir} |
    ...
    ...    Examples:
    ...    | Download Zip From WFT | 0.800.1487 | 5G_0.800.1487_ADMIN_CLI.zip | ${output_dir} |
    Log To Console    Download ADMIN CLI file...
    ${release_url}    Set Variable
    ...    https://artifactory-espoo1.int.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release/${sw}
    ${path_list}    Create List    ${release_url}    ${file_name}
    ${rel_zip_path}    Evaluate    '/'.join(${path_list})
    ${download_status}    Run Keyword And Return Status    OperatingSystem.Should Exist    ${store_path}/${file_name}
    Run Keyword If    '${download_status}'=='False'    OperatingSystem.Run    wget ${rel_zip_path} -P ${store_path}
    ${download_status}    Run Keyword And Return Status    OperatingSystem.Should Exist    ${store_path}/${file_name}
    [Return]    ${download_status}

Unzip And Do Migration SCF
    [Arguments]    ${zip_path}    ${zip_file}    ${input_scf_path}    ${output_scf_path}
    [Documentation]    This keyword is to unzip and do migration.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${zip_path} | Yes | the path of the zip file storeed |
    ...    | ${zip_file} | Yes | the name of the zip file storeed |
    ...    | ${input_scf_path} | Yes | the path of the inputed scf file  |
    ...    | ${output_scf_path} | Yes | the path of the outputed scf file, the name can not be the same as input scf file |
    ...
    ...    Examples: see the detail in keyword 'Migration SCF To New Release'
    ...
    Log To Console    Unzip ADMIN CLI file and do migration...
    ${file_list}    String.Split String    ${zip_file}    .z
    ${zip_folder}    Set Variable    ${zip_path}/${file_list[0]}
    ${unzip_status}    Run Keyword And Return Status    OperatingSystem.Should Exist    ${zip_folder}
    Run Keyword If    '${unzip_status}'=='False'    OperatingSystem.Run    unzip ${zip_path}/${zip_file} -d ${zip_folder}
    OperatingSystem.Run    chmod +x ${zip_folder}/migrateScf.sh
    Process.Run Process    cp ./bundle.js ..    shell=True    cwd=${zip_folder}
    ${migration_cmd}    Set Variable    ./migrateScf.sh --input-file ${input_scf_path} --output-file ${output_scf_path}
    ${result}    Process.Start Process    ${migration_cmd}    shell=True    cwd=${zip_folder}
    ...    stdout=${TEMPDIR}/migrate_stdout.txt

Judge SCF SW Version
    [Arguments]    ${scf_file}
    [Documentation]    This keyword is to judge the SW version from SCF file which saved as full configuration.
    ...    return ${status}, if SCF SW version is lower than that in testline, ${status} is True, need to migrate.
    ...    if not, ${status} is False, no need to migrate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${scf_file} | Yes | SCF path with scf name. such as ${CURDIR}/Full_Configuration_scf.xml |
    ...
    ...    Examples:
    ...    | Judge SCF SW Version | ${CURDIR}/Full_Configuration_scf.xml |
    ${status}    ${sw_version_origin}    Run Keyword And Ignore Error
    ...    Get Single Value From Scf File    file_path=${scf_file}    dist_name=MRBTS-1/HW-1    para_name=swVersion
    ${ret}    Run Keyword If    '${status}'=='PASS'    Evaluate    '${sw_version_origin}'<'${SOFTWARE_INFO}'
    Log To Console    Origin SW Version in SCF file: ${sw_version_origin}
    Log To Console    SW Version in the testline: ${SOFTWARE_INFO}
    ${status}    Set Variable If    '${status}'=='PASS'    ${ret}    False
    [Return]    ${status}

Get Control Board Type
    [Documentation]    this keyword is used to get control board Type, ASIK, ASIB, ASIL etc.
    ute_fsmaccess.Setup Enb Fsm Access
    ${cmd}=    Set Variable    cat /proc/device-tree/module-identity/unit-id
    ${board_type}=    ute_fsmaccess.Execute Command On Enb    ${cmd}
    ${board_type}=    String.Replace String Using Regexp    ${board_type}    \x00    ${EMPTY}
    Set Suite Variable    ${FCT_BOARD_TYPE}    ${board_type}
    Log    Control Board Type: ${FCT_BOARD_TYPE}     console=${True}
    [Teardown]    ute_fsmaccess.Teardown Enb Fsm Access
    [Return]    ${board_type}

Get Base Band Board Type
    [Documentation]    this keyword is used to get base band board Type, ABIL?ABIO?ABIN etc.
    ute_fsmaccess.Setup Enb Fsm Access
    ${cmd}=    Set Variable    bsh 1:0 cat /proc/device-tree/module-identity/unit-id
    ${board_type}=    ute_fsmaccess.Execute Command On Enb    ${cmd}
    ${board_type}=    String.Replace String Using Regexp    ${board_type}    \x00    ${EMPTY}
    Set Suite Variable    ${ASP_BOARD_TYPE}    ${board_type}
    Log    Base Band Board Type: ${ASP_BOARD_TYPE}     console=${True}
    [Teardown]    ute_fsmaccess.Teardown Enb Fsm Access
    [Return]    ${board_type}

Get RRU Type
    [Documentation]    this keyword is used to get RRU Type, AEQA,AAHF etc.
    ute_fsmaccess.Setup Wts Fsm Access
    ${cmd}=    Set Variable    cat /ffs/run/simmode/iphy.xml|grep -Eo "<cardName>.*</cardName>"|grep -Eo "[[:upper:]]{4,5}"
    ${RRU_type_1}=    ute_fsmaccess.Execute Command On Wts    ${cmd}
    ${RRU_type_list}=    String.Split To Lines    ${RRU_type_1}
    Set Suite Variable    ${RRU_TYPE}    @{RRU_type_list}[0]
    Set Suite Variable    ${RRU_TYPE_LIST}    ${RRU_type_list}
    Log    RRU Type List: ${RRU_type_list}     console=${True}
    Log    RRU Type: ${RRU_TYPE}     console=${True}
    [Teardown]    ute_fsmaccess.Teardown Wts Fsm Access
    [Return]    ${RRU_type_1}

Get Testline Name
    ${ret}    ${testline_name}=    OperatingSystem.Run And Return Rc And Output    hostname|sed 's/-/_/g'
    Log    Testline Name: ${testline_name}     console=${True}
    Log    Testline init file is /home/ute/testline_configuration/${testline_name}/      console=${True}
    Set Suite Metadata    Testline Name    ${testline_name}

Hard Reboot Testline
    Log To Console    Start to hard reboot testline...
    Print Current Time    Hard Reboot Time
    Hard Reboot Airphone
    Hard Reboot GNB

Hard Reboot Airphone
    PDU.Setup Pdu    ${AP_PDU}    alias=pdu_alias
    PDU.Power Off    port=${AP_PDU_PORT}    pdu_device=pdu_alias
    PDU.Get Port Status    port=${AP_PDU_PORT}    pdu_device=pdu_alias
    Sleep    3s
    PDU.Power On    port=${AP_PDU_PORT}    pdu_device=pdu_alias
    PDU.Get Port Status    port=${AP_PDU_PORT}    pdu_device=pdu_alias

Hard Reboot GNB
    PDU.Setup Pdu    ${GNB_PDU}    alias=pdu_alias_2
    PDU.Power Off    port=${GNB_PDU_PORT}    pdu_device=pdu_alias_2
    PDU.Get Port Status    port=${GNB_PDU_PORT}    pdu_device=pdu_alias_2
    Sleep    3s
    PDU.Power On    port=${GNB_PDU_PORT}    pdu_device=pdu_alias_2
    PDU.Get Port Status    port=${GNB_PDU_PORT}    pdu_device=pdu_alias_2

Copy Config File To Airphone QT Folder
    ${cmd}=    Set Variable    cp -r ${CURDIR}/config/l1b_tdd_nsa_ASIL_ABIO_cmwv ${WTS_CONFIG_PATH}
    OperatingSystem.Run And Return Rc And Output    ${cmd}

Modify ASIB X2 IP For Workaround
    ${asib_cfg}=    Set Variable    ${WTS_CONFIG_PATH}/fs_tdd_nsa_ASIB_cmwv/0.800/basic_fullstack_nsa_call_tdd_cmwv.cfg
    OperatingSystem.Run    sed -i s'/ENB2_S1_ADDR="10.0.1.112"/ENB2_S1_ADDR="10.0.1.2"/' ${asib_cfg}
    OperatingSystem.Run    sed -i s'/ENB2_X2_ADDR="10.0.1.111"/ENB2_X2_ADDR="10.0.1.2"/' ${asib_cfg}

Add RD Parameters To Airphone Swconfig File
    [Arguments]    ${rd_parametrs}
    [Documentation]    This keyword is to add new RD parameters to swconfig.txt
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${rd_parametrs} | Yes | str joined by symbol ;, like 0x580019=1;0x580011=0;0x580012=0; |
    ...
    ...    Examples:
    ...    | Add RD Parameters To Airphone Swconfig File | 0x580019=1;0x580011=0;0x580012=0 |
    ...
    ${path}    Get Swconfig File From Airphone    ${OUTPUT_DIR}
    Modify Swconfig File Parameters    ${path}    ${rd_parametrs}
    Send Swconfig File To Airphone    ${path}

Add RD Parameters To GNB Swconfig File
    [Arguments]    ${rd_parametrs}
    [Documentation]    This keyword is to add new RD parameters to swconfig.txt
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${rd_parametrs} | Yes | str joined by symbol ;, like 0x580019=1;0x580011=0;0x580012=0; |
    ...
    ...    Examples:
    ...    | Add RD Parameters To GNB Swconfig File | 0x580019=1;0x580011=0;0x580012=0 |
    ...
    ${path}    Get Swconfig File From GNB    ${OUTPUT_DIR}
    Modify Swconfig File Parameters    ${path}    ${rd_parametrs}
    Send Swconfig File To GNB    ${path}

Get Swconfig File From Airphone
    [Arguments]    ${save_dir}
    OperatingSystem.Run
    ...    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.200.1:/ffs/run/swconfig.txt ${save_dir}/swconfig_ap.txt
    OperatingSystem.Should Exist    ${save_dir}/swconfig_ap.txt
    ${path}    Set Variable    ${save_dir}/swconfig_ap.txt
    [Return]    ${path}

Send Swconfig File To Airphone
    [Arguments]    ${path}
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p oZPS0POrRieRtu scp ${path} toor4nsn@192.168.200.1:/ffs/run/swconfig.txt
    Should Be Equal As Integers    ${rc}    0

Get Swconfig File From GNB
    [Arguments]    ${save_dir}
    OperatingSystem.Run
    ...    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.1:/ffs/run/swconfig.txt ${save_dir}/swconfig_gnb.txt
    OperatingSystem.Should Exist    ${save_dir}/swconfig_gnb.txt
    ${path}    Set Variable    ${save_dir}/swconfig_gnb.txt
    [Return]    ${path}

Send Swconfig File To GNB
    [Arguments]    ${path}
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p oZPS0POrRieRtu scp ${path} toor4nsn@192.168.255.1:/ffs/run/swconfig.txt
    Should Be Equal As Integers    ${rc}    0

Print Current Time
    [Arguments]    ${log}=...
    ${date}=    DateTime.Get Current Date
    BuiltIn.log to console    ${date}:${log}

Modify IPHY File And Send to Airphone
    [Arguments]    ${iphy_path}
    ${RRU_type_list}    Get RRU Type From Local IPHY XML    ${iphy_path}
    FOR    ${RRU_type}    IN    @{RRU_type_list}
        ${RRU_Version}    Get RRU Version From TargetBD File    ${RRU_type}    ${OUTPUT_DIR}
        Modify RRU Version Of IPHY XML    ${iphy_path}    ${RRU_type}    ${RRU_Version}
    END
    Send IPHY XML To Airphone    ${iphy_path}

Get RRU Type From Local IPHY XML
    [Arguments]    ${iphy_path}
    ${content}=    OperatingSystem.Get File    path=${iphy_path}
    ${check_point_regexp}    Set Variable    <cardName>(?P<RRU_type>[A-Z]+)<\\/cardName>
    @{RRU_type}    String.Get Regexp Matches    ${content}    ${check_point_regexp}    RRU_type
    [Return]    @{RRU_type}

Get RRU Version From TargetBD File
    [Arguments]    ${RRU_type}    ${save_dir}
    ${RRU_type}=    Set Variable If    "${RRU_type}"=="AAHF"    AAHF_C1    ${RRU_type}
    OperatingSystem.Run
    ...    sshpass -p ${GNB_ASIK.password} scp ${GNB_ASIK.username}@${GNB_ASIK.ip}:/ffs/run/TargetBD*.xml ${save_dir}/TargetBD.xml
    OperatingSystem.Should Exist    ${save_dir}/TargetBD.xml
    ${content}=    OperatingSystem.Get File    path=${save_dir}/TargetBD.xml
    ${check_point_regexp}    Set Variable    resourceBuildKey="LTX_${RRU_type}".*resourceSWVersion="(?P<RRU_Version>.*)"
    @{RRU_Version}    String.Get Regexp Matches    ${content}    ${check_point_regexp}    RRU_Version
    [Return]    @{RRU_Version}[0]

Modify RRU Version Of IPHY XML
    [Arguments]    ${iphy_path}    ${RRU_type}    ${RRU_Version}
    ${content}    OperatingSystem.Get File    path=${iphy_path}
    ${bldVersion}=    String.Get Regexp Matches    ${content}
    ...    <cardName>${RRU_type}<\/cardName>[\\s\\S]*?<bldVersion>(?P<bldVersion>.*)<\/bldVersion>
    ...    bldVersion
    ${new_content}    String.Replace String    ${content}    ${bldVersion}[0]    ${RRU_Version}
    OperatingSystem.Create File    path=${iphy_path}    content=${new_content}
