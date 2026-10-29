*** Settings ***
Resource    common_lib_variable.robot
Resource    common_admin.robot
Resource    common_NSA_ue_command.robot
Resource    common_SA_ue_command.robot
Resource    common_multi_UE_resource.robot
Resource    common_log_capture.robot
Resource    common_file_operation.robot
Resource    common_deal_config_file.robot
Resource    check_pcap_file.robot
Resource    common_log_analyzer.robot
Resource    common_multi_cases.robot
Resource    common_CA.robot
Resource    common_auto_analyze_error.robot

Documentation
...
...             TESTING SPLIT:    Refer CB008278 Test Plan

*** Keywords ***
Clean Up Env
    Run Keyword And Ignore Error    CORE.Teardown Collectors    names=l2stream
    Run Keyword And Ignore Error    CORE.Teardown Collectors    names=btslog
    Run Keyword And Ignore Error    CORE.Teardown Collectors    names=testVM_Tcpdump
    Run Keyword And Ignore Error    CORE.Teardown Collectors    names=oamTShark
    Run Keyword And Ignore Error    CORE.Teardown Collectors    names=gnb_pm_counters
    Run Keyword And Ignore Error    CORE.Teardown Collectors    names=gnb_coam_snapShot
    Run Keyword And Ignore Error    COAM.Teardown Admin
    Run Keyword And Ignore Error    SHERPA.Teardown    sherpa

Suite Setup Update GNB
    [Arguments]    ${swconfig_param}=${empty}    ${scf_file}=${empty}    ${iphy_file}=${empty}    ${swconfig_param_AP}=${empty}    ${log}=${True}
    ...    ${force_reboot}=${False}    ${skip_reboot}=${False}    ${vendor_change_list}=${empty}
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
    ...    Example7: for vendor file
    ...    | &{xml_params_dict1} | Create Dictionary | maxNumLayerPrbDlL1Sp=200 | maxNumLayerPrbUlL1Sp=100 |
    ...    | ...| maxNumStreamPrbDlL1Sp=300 | maxNumStreamPrbUlL1Sp=200 |
    ...    | &{vendor_change_dict1} | Create Dictionary | list_name=bbL1SpPrbCapacity |
    ...    | ... |    | ref_value=ABIO\\d+FDD48 | params_dict=${xml_params_dict1} |
    ...    | &{xml_params_dict2} | Create Dictionary | guaranteedResourceRatioPerCell=10 |
    ...    | &{vendor_change_dict2} | Create Dictionary | list_name=${EMPTY} |
    ...    |  ref_value=${EMPTY}  |  params_dict=${xml_params_dict2} | ${vendor_change_dict2} |
    ...    | @{vendor_change_list} | Create List | ${vendor_change_dict1} | ${vendor_change_dict2} |
    ...    | Suite Setup Update GNB | vendor_change_list=${VENDOR_CHANGE_LIST} |
    Import Testline Variables
    Run Keyword If    "${BASELINE}"!=""    Install Ttitrace And Mcshark    ${BASELINE}
    Check GNB EIF Ping OK
    Check AP EIF Ping OK
    Sync Timezone For GNB AP And WTS
    Print Current Time    Start Robot File Time
    Clean Up Env
    Create Suite Directory
    Run Keyword And Ignore Error    Get Qc File
    Get All Testline Information And Set Suite Variable
    Modify UTE Memory Size
    Run Keyword If    '${iphy_file}'!='${empty}'    Get RRU Type From Local IPHY XML    ${iphy_file}
    Print Testline Info Ahead Of Report
    Setup Connections
    Set CP Debug Log
    Run Keyword If    "${log}"=="${True}"    common_log_capture.Start Logs    ${LOG_NAME_SUITE_SETUP}    ${SUITE_LOG_DIRECTORY}
#    Get Default NRBTS DistName
    Add RD Parameters To GNB Swconfig File    0x1002A=1    #open catching emil fuction
    ${scf_file_type}    Get File Type    ${scf_file}
    Run Keyword If    '${iphy_file}'!='${empty}'    Modify IPHY File And Send to Airphone    ${iphy_file}
    Run Keyword If    '${swconfig_param}'!='${empty}'    Add RD Parameters To GNB Swconfig File    ${swconfig_param}
    Run Keyword If    '${swconfig_param_AP}'!='${empty}'    Add RD Parameters To Airphone Swconfig File    ${swconfig_param_AP}
    ${vendor_change_list_is_empty}    ${ret}    Run Keyword And Ignore Error     Should Be Empty    ${vendor_change_list}
    Run Keyword If    '${scf_file_type}'=='xml' and '${vendor_change_list_is_empty}'=='PASS'
    ...      Full Commission With SCF File    ${scf_file}
    Run Keyword If    '${vendor_change_list_is_empty}'=='FAIL'
    ...      Modify Vendor File And Do Full Commission    ${vendor_change_list}    ${scf_file}
    Run Keyword If    '${scf_file_type}'=='json'    Delta Commission With SCF File    ${scf_file}
    Run Keyword And Return If    '${skip_reboot}'=='${True}'    Log    testline is forced to skip reboot ...    WARN
    ${file_empty_state}=    Catenate    '${scf_file}'!='${empty}' or '${swconfig_param}'!='${empty}' or '${swconfig_param_AP}'!='${empty}'
     ...    or '${iphy_file}'!='${empty}'
    ${file_state}=    Evaluate    ${file_empty_state}
    Run Keyword If    '${file_state}'=='${True}' or '${force_reboot}'=='${True}'
    ...    Reboot TL And Check Configured

Import Testline Variables
    ${ret}    ${host_name}=    OperatingSystem.Run And Return Rc And Output    hostname|sed 's/-/_/g'
    ${testline_config_path}=    Set Variable    /home/ute/testline_configuration/${host_name}/
    ${ret}=    Run Keyword And Return Status    File Should Exist    ${testline_config_path}/__init__.py
    ${testline_config_path}=    Set Variable If    "${ret}"=="${True}"    ${testline_config_path}
    ...    /home/ute/testline_init_results/configs/${host_name}/
    Log    Testline init file is ${testline_config_path}      console=${True}
    Import Variables    ${testline_config_path}
    Set Suite Variable    ${AP_PDU_IP}    ${tl.ues[0].l1.common_units[0].pdu_port.pdu.addr}
    Set Suite Variable    ${AP_PDU_PORT}    ${tl.ues[0].l1.common_units[0].pdu_port.port_no}
    Set Suite Variable    ${GNB_PDU_IP}    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
    Set Suite Variable    ${GNB_PDU_PORT}    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
    Set Suite Variable    ${AP_PDU}    ${tl.ues[0].l1.common_units[0].pdu_port.pdu}
    Set Suite Variable    ${GNB_PDU}    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu}
    Set Suite Variable    ${TLPC_IP}    ${tl.test_pc.default_ssh_connection_details.addr}
    Set Suite Variable    ${TLPC_SSH_UE}    ${tl.test_pc.default_ssh_connection_details.username}
    Set Suite Variable    ${TLPC_SSH_PWD}    ${tl.test_pc.default_ssh_connection_details.password}
    Set Suite Variable    ${VLAN_ID}    ${tl.gnbs[0].cu.x2c.vlan_id}

Install Ttitrace And MCshark
    [Arguments]    ${package}=${BASELINE}
    Run    sh ${CURDIR}/tools/local_testline/update_ttitrace.sh ${package}
    Download MCShark To UTE    ${package}

Check Testline Reboot Automatically
    ${res}    Run Keyword And Return Status    Verify Coam Site Is Ready
    [Return]    ${res}

Get All Testline Information And Set Suite Variable
    [Arguments]    ${scf_tag}=before_suite
    Backup Scf    ${OUTPUT_DIR}    ${scf_tag}
    Get Default NRBTS DistName
    Get GNB Type From SCFC
    Get L1Bypass Type
    Run Keyword And Ignore Error    Get Testline Type
    Run Keyword If    '${SW_BRANCH}'=='${EMPTY}'    Get Software Version
    Get Airphone Software Version
    Get WTS Version
    Get Control Board Type
    Get Base Band Boards Type
    Get AP Control Board Type
    Get AP Base Band Boards Type
    Get RRU Type
    Get Host IP
    Get Host Name
    Get Cell Numbers
    Get Mplane IP Of GNB

Print Testline Info Ahead Of Report
    Set Suite Metadata    GNB FCT Type    ${FCT_BOARD_TYPE}
    Set Suite Metadata    GNB ASPs Type    ${ASP_BOARDS_TYPE}
    Set Suite Metadata    AP FCT Type    ${AP_FCT_BOARD_TYPE}
    Set Suite Metadata    AP ASPs Type    ${AP_ASP_BOARDS_TYPE}
    Set Suite Metadata    RRU Type    ${RRU_TYPE}
    Set Suite Metadata    RRU Type List    ${RRU_TYPE_LIST}
    Set Suite Metadata    WTS Version    ${WTS_VERSION}
    Set Suite Metadata    Software Version Total    ${SW_VERSION_TOTAL}
    Set Suite Metadata    Software Version    ${SW_VERSION}

Modify UTE Memory Size
    [Documentation]    This keyword is to start AirPhone load 4.0.10852, The Sack Timeout In The WTS VM And AP ASIK Must Be
    ...    configured before cell setup.This Aims To Prevent Delayed Messaging Between AirPhone
    ...    and WTS (e.g. CTRL_ADD_UE_NR for attach procedure).
    Log To Console    Modify UTE Memory Size...
    OperatingSystem.Run    sudo sysctl -w net.core.wmem_max=20971520
    OperatingSystem.Run    sudo sysctl -w net.core.wmem_default=20971520
    OperatingSystem.Run    sudo sysctl -w net.core.rmem_max=20971520
    OperatingSystem.Run    sudo sysctl -w net.core.rmem_default=20971520

Suite Setup Copy WTS Config Files From QT
    [Documentation]    This keyword is to copy the configuration files of WTS from QT by testline type.
    ...    | QT config files | /home/ute/Auto5G/testsuite/QTPH1/AirPhone/resources. |
    ...    | git path | https://wrgitlab.int.net.nokia.com/5G/robotws5g/tree/master/testsuite/QTPH1/AirPhone/resources |
    ...
    ...    | for SA testline | l1_mode is L1Bypass | file is like l1b_tdd_sa_cmwv/0.800/AirPhoneConfig_l1bypass_tdd_sa_cmwv.xml |
    ...    | for NSA testline | l1_mode is FullStack | file is like  fs_fdd_nsa_cmwv/9.1800/AirPhoneConfig_fullstack_fdd_nsa_cmwv.xml |
    ${ret}=    Run Keyword And Return Status    Copy WTS Common Config Files
    Run Keyword If    "${ret}"=="False"    Set Suite Variable    ${WTS_CFG}    basic_setup.cfg
    Log    cfg file=${WTS_CFG}
    #Add the part to modify the UE capability to updated ones, since cfg file in QT is out of date sometime
    Run Keyword If    '${GNBCUTYPE}'=='SA' and '${CELLTECHNOLOGY}'=='TDD' and '${FR}'=='cmwv'
    ...    Modify UE Capabilities In CFG    ${WTS_DIR}/${WTS_CFG}    ${UE_NR_CAPABILITIES_PATT}    ${UE_NR_CAPABILITIES_VAL}

Modify Testconfig Yaml File For L1bypass
    [Arguments]    ${config_yaml}
    OperatingSystem.Run    sed -i 's@component_carrier: 2@component_carrier: 1@' ${config_yaml}
    OperatingSystem.Run    sed -i 's@component_carrier: 6@component_carrier: 1@' ${config_yaml}
    OperatingSystem.Run    sed -i 's@RU_type: \\[AEQE, AEHC, AHFIB, AHLOA\\]@RU_type: AEQE@' ${config_yaml}
    OperatingSystem.Run    sed -i 's@RU_type: \\[AHLOA, AEHC\\]@RU_type: AEHC@' ${config_yaml}

Modify Testconfig Yaml File For Fullstack
    [Arguments]    ${config_yaml}
    OperatingSystem.Run    sed -i 's@component_carrier: 2@component_carrier: 1@' ${config_yaml}
    OperatingSystem.Run    sed -i 's@RU_type: \\[AHLOA, AEHC\\]@RU_type: AEHC@' ${config_yaml}

Copy WTS Common Config Files
    ${AP_BUILD}    OperatingSystem.Run    ls -l /opt/wts/ | grep latest
#    ${AP_build_number}    String.Fetch From Right    ${AP_BUILD}    /opt/wts/
    Set Suite Variable    ${AP_configs}      ${CURDIR}/AP_configs_repo
    OperatingSystem.Run    rm -rf ${AP_configs}
    ${ret}=    OperatingSystem.Run And Return Rc    git clone "https://gerrit.ext.net.nokia.com/gerrit/MN/5G/TEST/testconfigs" ${AP_configs}
    Run Keyword If    "${ret}"!="0"    Fail    Environment issue:git clone testconfigs from gerrit failed.
#    OperatingSystem.Run    cd ${AP_configs}; git checkout tags/${AP_build_number}
    ${config_yaml}=    Set Variable    ${AP_configs}/${SW_VERSION}/${GNBCUTYPE}/${L1_TYPE}/config.yaml
    OperatingSystem.File Should Exist    ${config_yaml}
    run keyword if    "${L1_TYPE}"=="FS"    Modify Testconfig Yaml File For Fullstack    ${config_yaml}
    ...    ELSE    Modify Testconfig Yaml File For L1bypass    ${config_yaml}
    Run    cp ${config_yaml} ${OUTPUT_DIR}
    OperatingSystem.Get File    ${config_yaml}
    ${dic}=    YAMLPARSER.Parse Yaml    ${config_yaml}    ${CELLTECHNOLOGY}    ${RF_TYPE}
    ...    ${FR}    ${RRU_TYPE}    ${FCT_BOARD_TYPE}    ${ASP_BOARDS_TYPE}    ${AP_FCT_BOARD_TYPE}    ${AP_ASP_BOARDS_TYPE}
    ...    1
    Log    ${dic}
    Run Keyword If    "${dic}"=="None"    Fail    TA scripts issue:can't get cfg file info from testconfig for current testline type.
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
#    OperatingSystem.Remove File    ${WTS_DIR}/AirPhoneConfig*.xml
#    OperatingSystem.Remove File    ${WTS_DIR}/basic*.cfg
    ${ret}=    OperatingSystem.Run And Return Rc    cp ${ap_xml_file} ${WTS_DIR}/${WTS_AP_XML}
    ${ret}=    OperatingSystem.Run And Return Rc    cp ${wts_cfg_file} ${WTS_DIR}/${WTS_CFG}
    OperatingSystem.Run    sed -i 's/file=.*\.xml/file=${WTS_AP_XML}/' ${WTS_DIR}/${WTS_CFG}
    Set Suite Variable    ${WTS_CFG}
    Set Suite Variable    ${WTS_AP_XML}

Get Testline Type
    [Documentation]    This keyword is used to get testline type, CLOUD_5G_KL_AP_NSA_FS_CMWV_TDD etc.
    ${file_content}=    OperatingSystem.Get File    ${RESERVATION_FILE_PATH}
    &{testline_dict}=    json.Loads    ${file_content}
    ${testline_type}=    Collections.Get From Dictionary    ${testline_dict}    topology
    ${enb_build_version}=    Collections.Get From Dictionary    ${testline_dict}    enb_build
    Log    Testline type: ${testline_type}     console=${True}
    Set Suite Metadata    Testline type    ${testline_type}
    [Return]    ${testline_type}

Get L1Bypass Type
    [Documentation]    Get TL is configured as L1Bypass mode or FS mode
    ...    Examples:
    ...    | ${L1_type}= | Get L1Bypass Type |
    ${output}=    Run    (sleep 2s; echo "tag -a";sleep 2s)|sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.129 telnet localhost 15007
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
    ${ret}=    Run Keyword And Return Status    Should Contain    ${radio_protocol}[0]    eCPRI
    ${rf}=    Set Variable If    '${ret}'=='${True}'    eCPRI    CPRI
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
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    5s    1s    OperatingSystem.File Should Exist    ${WTS_DIR}/${WTS_AP_XML}

Suite Setup Start WTS And Check OnAir Without Workaround
    [Arguments]    ${log}=yes    ${enb_id}=1    ${gnb_id}=2
    [Documentation]    This keyword is to modify vlan, start WTS, wait for onAir
    Modify UTE SCTP Timeout
    Modify AP SCTP Timeout
    Configure UTE ETH3
    Start UTE WTS
    Run Keyword If    '${GNBCUTYPE}'=='SANSA'    UE SIB Decoding Should Be Successful
    Run Keyword If    '${GNBCUTYPE}'=='SA'    UE SIB Decoding
    Run Keyword If    '${GNBCUTYPE}'=='NSA' or '${GNBCUTYPE}'=='SANSA'    Setup X2 Connection    ${enb_id}    ${gnb_id}
    #Get NR Cell Number
    Run Keyword If    '${GNBCUTYPE}'=='SANSA' or '${GNBCUTYPE}'=='SA'    Check All Cells Received SIB2
    Verify Cell Setup
    [Teardown]    Run Keyword If    "${log}"=="yes"    common_log_capture.Stop Logs    ${LOG_NAME_SUITE_SETUP}    ${SUITE_LOG_DIRECTORY}

Suite Setup Start WTS And Check OnAir
    [Arguments]        ${log}=yes    ${enb_id}=1    ${gnb_id}=2
    ${status}    Run Keyword And Return Status
    ...    Suite Setup Start WTS And Check OnAir Without Workaround    ${log}    ${enb_id}    ${gnb_id}
    Run Keyword If    '${status}'=='False'    Workaround For Check SIB2 Fail    ${log}    ${enb_id}    ${gnb_id}

Workaround For Check SIB2 Fail
    [Arguments]    ${log}=yes    ${enb_id}=1    ${gnb_id}=2
    Reboot TL And Check Configured
    Run Keyword And Ignore Error    Clean Edaemon And Egate
    Suite Setup Start WTS And Check OnAir Without Workaround    ${log}    ${enb_id}    ${gnb_id}

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
    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is OnAir
    Run Keyword If    '${delta_jason}' != '${none}'    Backup Scf    ${TEST_LOG_DIRECTORY}    after_case
    Run Keyword If    "${log}"=="yes"    common_log_capture.Start Logs    ${LOG_NAME_LIST}

Common Test Setup And Check Configured
    [Arguments]    ${delta_jason}=${none}    ${wait_time}=300sec    ${log}=yes
    Create Test Directory
    Run Keyword If    '${delta_jason}' != '${none}'    Backup Scf    ${TEST_LOG_DIRECTORY}    before_case
    Run Keyword If    '${delta_jason}' != '${none}'    Delta Commission With SCF File    ${delta_jason}
    Wait Until Keyword Succeeds    ${wait_time}    15sec    Verify BTS Is Configured
    Run Keyword If    '${delta_jason}' != '${none}'    Backup Scf    ${TEST_LOG_DIRECTORY}    after_case
    Run Keyword If    "${log}"=="yes"    common_log_capture.Start Logs    ${LOG_NAME_LIST}

Common Test Teardown
    [Arguments]    ${detach_ue_id}=${EMPTY}
    [Documentation]    This keyword is to detach UE, and stop logs for case
    ${status}    ${output}    Run Keyword And Ignore Error    Variable Should Exist    ${ue_id}
    ${detach_ue_id}    Set Variable If    '${status}'=='PASS' and '${detach_ue_id}'=='${EMPTY}'    ${ue_id}    ${detach_ue_id}
    Log    ${detach_ue_id}
    Run Keyword And Ignore Error    common_log_capture.Stop Logs    ${LOG_NAME_LIST}
    Run Keyword And Ignore Error    NSA LTE Detach    ${detach_ue_id}
    Run Keyword And Ignore Error    SA 5G Detach    ${detach_ue_id}
    #Run Keyword If    '${mode}'!='debug'    Run Keyword If Test Failed    Collect UTE SosReport    ${TEST_LOG_DIRECTORY}
    Run Keyword And Ignore Error    Save Egate Log    ${TEST_LOG_DIRECTORY}
    Run    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.200.1:/tmp/APL3.log ${TEST_LOG_DIRECTORY}
    Run    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.129:/ram/node_CPRT00/tmp/startup_cp_rt.log* ${TEST_LOG_DIRECTORY}
    Run Keyword And Ignore Error    Filter ERR WRN Message From Syslog By Log Path    ${TEST_LOG_DIRECTORY}
    ...    ${CURDIR}/filter_msg.txt    ${TEST_LOG_DIRECTORY}/case_fatal_log.txt
    Auto_Analyze_Error    ${TEST_LOG_DIRECTORY}/case_fatal_log.txt

Common Suite Teardown
    [Arguments]    ${mode}=${EMPTY}    ${collect_config_file}=${FALSE}
    [Documentation]    This keyword is to collect the logs.
    Run Keyword And Ignore Error    Get Alarms
    Run keyword If    '${FLAG_CATCH_SUITE_LOG}'=='${True}'    common_log_capture.Stop Logs    ${LOG_NAME_SUITE_SETUP}    ${SUITE_LOG_DIRECTORY}
    Run Keyword And Ignore Error    Show Relation Errors If Exist
    Run Keyword If    '${collect_config_file}'=='${TRUE}' and '${SUITE STATUS}'=='PASS'
    ...    Get Config Files And Put To Local Log Server
    Run Keyword If    '${mode}'!='debug'    Run Keyword And Ignore Error    Stop Logs    ${LOG_NAME_SUITE_TEARDOWN}    ${SUITE_LOG_DIRECTORY}
    Run Keyword If    '${mode}'!='debug'    Run Keyword And Ignore Error    Run Keyword If Any Tests Failed
    ...    Collect UTE SosReport    ${SUITE_LOG_DIRECTORY}
    common_log_capture.Teardown All Connections
    ute_wtssim.Teardown All Aliases For Wts
    Run Keyword And Ignore Error    Stop Edaemon Egate
    Run Keyword And Ignore Error    Filter ERR WRN Message From Syslog By Log Path    ${SUITE_LOG_DIRECTORY}
    ...    ${CURDIR}/filter_msg.txt    ${SUITE_LOG_DIRECTORY}/suite_fatal_log.txt
    Auto_Analyze_Error    ${SUITE_LOG_DIRECTORY}/suite_fatal_log.txt

Get Qc File
    ${path}    ${file}=    OperatingSystem.Split Path    ${SUITE_SOURCE}
    ${ret}    ${output}    OperatingSystem.Run And Return Rc And Output    ls -1 ${path}/*.qc
    ${list_1}=    String.Split To Lines    ${output}
    ${qc_file}=    Set Variable    @{list_1}[0]
    ${content}=    Get File    ${qc_file}
    Log    ${content}

Save Egate Log
    [Arguments]    ${log_path}=${SUITE_LOG_DIRECTORY}
    [Documentation]    This keyword is to copy egate console log from /opt/iphy/latest/egate_console.log to ${log_path}
    ...    after execute 'sim_log_set flush'
    ute_wtssim.Execute Egate Command    sim_log_set flush
    OperatingSystem.Copy Files    /opt/iphy/latest/egate_console.log*    ${log_path}

Create Suite Directory
    [Documentation]    This keyword is to create a directory for storing suite level logs.
    ...
    ...    ${SUITE_LOG_DIRECTORY} is a suite variable.
    ...    before refine: Test_Suite_Folder_1605087516120
    ...    after refine: Test_Suite_Folder_20201112151625116
    Log To Console    Create Suite Directory...
    Log    ${SUITE_NAME}
    ${time_string}    DateTime.Get Current Date    result_format=timestamp
    ${time_string}    String.Replace String Using Regexp    ${time_string}    (-|:|\\.|\\s)    ${EMPTY}
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

Wait GNB And AP SSH Connect OK
        Wait Until Keyword Succeeds    120s    5s    Check GNB And AP SSH Connect OK

Check GNB And AP SSH Connect OK
    Check GNB SSH Connect OK
    Check AP SSH Connect OK

Reboot TL And Check Configured
    [Documentation]    This keyword is to soft reboot testline and check the status is configured.
    ...            It with try ${MAX_REBOOT_TIME} times to make sure the testline can be reboot successfully.
    Log To Console    Make sure BTS site is ready by rebooting at most ${MAX_REBOOT_TIME} times...
    Run Keyword And Ignore Error    Remove hwf File To Save Reboot Time
    #Run Keyword And Ignore Error    Wait GNB And AP SSH Connect OK
    Set Suite Variable    ${reboot_sucess_flag}    ${False}
    FOR    ${index}    IN RANGE    1    ${MAX_REBOOT_TIME}+1
        Log To Console    ===============Reboot Time: ${index}==============
        Run Keyword If    "${ROOT_TYPE}"=="soft_reboot" and "${index}"=="1"    Reboot Testline Via SSH
        ...    ELSE    Hard Reboot Testline
        ${res}    Run Keyword And Return Status    Verify Coam Site Is Ready
        ${reboot_sucess_flag}=    Set Variable If    '${res}'=='True'    ${True}
        Exit For Loop If    '${res}'=='True'
    END
    Should Be True    "${reboot_sucess_flag}"=="${True}"    WRN:Reboot ${MAX_REBOOT_TIME} times,RRU still can't go to green state.

Reboot TL And Check Configured If Needed
    ${auto_reboot_stats}=    Run Keyword And Return Status    Check Testline Reboot Automatically
    Run Keyword If    '${auto_reboot_stats}'=='${False}'
    ...    Reboot TL And Check Configured

Remove hwf File To Save Reboot Time
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output
    ...    sshpass -p ${GNB.password} ssh ${GNB.username}@${GNB.ip} rm /ffs/run/config/hwf.bin.gz
    Should Be True    "${rc}"=="0"

Start UTE WTS
    [Documentation]    This keyword is to kill Running WTS Binaries If Any, Configure ETH3, Retrieve Files And Configure WTS
    Log To Console    Starting WTS...
    Run Keyword And Ignore Error    Stop Edaemon Egate
    Run Keyword And Ignore Error    Adapt Cfg File Nrafcn Value With Scf    ${WTS_DIR}/${WTS_CFG}
    Run Keyword And Ignore Error    Get IpAddr From Scf And Cfg
    ute_wtssim.Setup Edaemon    edaemon_port=22222    tool_dir=${WTS_DIR}    alias=edaemon
    ute_wtssim.Start Edaemon Process    alias=edaemon
    ute_wtssim.Setup Egate    egate_port=20000    tool_dir=${WTS_DIR}     save_egate=${True}
    ute_wtssim.Start Egate Process
    Run Keyword If    '${GNBCUTYPE}'=='SA'    ute_wtssim.Execute Egate Command    cfg file\=${WTS_DIR}/${WTS_CFG}
    ...    pass_regexp=SCTP proxy link   timeout=5min
    ...  ELSE IF    '${GNBCUTYPE}'=='NSA' or '${GNBCUTYPE}'=='SANSA'    ute_wtssim.Execute Egate Command    cfg file\=${WTS_DIR}/${WTS_CFG}
    ...    pass_regexp=(SimMode is ready now|UEC-1 is active)      timeout=5min
    ...    ELSE    Log To Console    WARN: No cfg file is imported in egate console!!!
#    Run Keyword If    '${GNBCUTYPE}'=='NSA' or '${GNBCUTYPE}'=='SANSA'    Wait Until Keyword Succeeds    120sec    15sec
#    ...    ute_wtssim.Execute Egate Command    state_sim_disp    pass_regexp=The state is ACTIVE

Change WTS VM Timezone to UTC
    OperatingSystem.Run    sudo timedatectl set-timezone UTC

Stop Edaemon Egate
    Run Keyword And Ignore Error    Clean Edaemon And Egate
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
    OperatingSystem.Run    sudo ip addr add 10.0.1.121/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.137/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.124/32 dev eth3    #gnb3
    OperatingSystem.Run    sudo ip addr add 10.0.1.125/32 dev eth1    #gnb4
    OperatingSystem.Run    sudo ip addr add 10.0.1.122/32 dev eth3    #gnb3
    OperatingSystem.Run    sudo ip addr add 10.0.1.123/32 dev eth1    #gnb4
    OperatingSystem.Run    sudo ip addr add 10.0.1.12/24 dev eth3    #MO_X2

Open GNB Syslog Button For Workaround
    OperatingSystem.Run    ${SSH_CMD} sed -i s'/0x10041=1/0x10041=5/' /ffs/run/swconfig.txt

Get Software Version
    ${coam_connection}    coam.Connect To    bts_host=${GNB_ASIK.ip}
    ${software_info_1}=    coam.Get Sw Version    connection=${coam_connection}
    Set Suite Variable    ${SOFTWARE_INFO}    ${software_info_1}
    Log    Software Version: ${SOFTWARE_INFO}    console=${True}    #5G21B_GNB_0000_000800_004084_0oeo9    5G21A_GNB_0011_000800_000601
    @{words}=    String.Split String    ${SOFTWARE_INFO}    _
    ${ENB_BUILD}=    Set Variable    ${words[0][0:4]}
    ${IS_SOFTWARE_KNIFE}=    Set Variable If    "${words[-1][0:3]}"=="000"    ${False}    ${True}
    #${ENB_BUILD}=    String.Get Substring    ${SOFTWARE_INFO}    0    4
    Set Suite Variable    ${ENB_BUILD}
    Set Suite Variable    ${IS_SOFTWARE_KNIFE}
    Get Software Version Total
    [Teardown]    coam.Teardown    ${coam_connection}

Get Software Version Total
    [Documentation]    This keyword is to get gNB software version including below 3 suite variables.
    ...
    ...    | Suite variable | Example | Description |
    ...    | ${SW_VERSION} | SBTS00 | get the QT config files with the related version |
    ...    | ${SW_VERSION_TOTAL} | SBTS21B_ENB_9999_210324_000019 | total sw version |
    ...    | ${SW_BRANCH} | SBTS21B | the folder to stort config files for case |
    ...
    @{sw_list}    String.Split String    ${SOFTWARE_INFO}    _
    ${status}    Run Keyword And Return Status    Should Be True    ${sw_list[2]}==9999 or ${sw_list[2]}==9990
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
    Set Suite Variable    ${AP_version}
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
    #COAM.Setup Admin    bts_host=${GNB_ASIK.ip}
    COAM.Setup Admin
    ${cells_info}=    COAM.Get Cell List
    ${dist_name}=    Set Variable    ${cells_info['cells']['nr'][0]['id']['configuration']}
    Log    ${dist_name}
    ${mrbts}    ${nrbts}    ${nrcell}    String.Split String    ${dist_name}    /
    Set Suite Variable    ${NRBTS_DISTNAME}    ${mrbts}/${nrbts}
    Set Suite Variable    ${MRBTS_DISTNAME}    ${mrbts}
    Log To Console    NRBTS_DISTNAME: ${NRBTS_DISTNAME}
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown

Verify BTS Procedural State
    [Arguments]    ${alias}=cOAM    ${proceduralstates}=Configured    ${timeout}=30
    [Documentation]    Verify BTS Procedural State And Blocking State
    ...    alias:    AdminConnection Object Or If Used, String Name Alias
    ...    timeout: Time to wait for positive procedure result
    ...    proceduralStates: (string or list) BTS procedural States, opetions=Configured or OnAir or Commissioned
    ${cells_info}=    COAM.Get Cell List    alias=${alias}
    ${bts_status}=    COAM.Get Bts Statuses    timeout=${timeout}    connection=${alias}
    List Should Contain Value    ${proceduralstates}    ${bts_status['proceduralState']}
    Should Be Equal    ${bts_status['blockingState']}    Unblocked    ignore_case=true
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown

Get Host IP
    [Documentation]    This keyword is to get testline control host intranet IP.
    ...    Examples:
    ...    | ${host_ip} | Get Host IP |
    ${command}    Set Variable    sudo ifconfig eth0|awk -F "[ :]+" 'NR==2 {print $3}'
    ${rc}    ${output}=    OperatingSystem.Run and Return RC and Output    ${command}
    Log    Host IP:${output}    console=${True}
    Set Suite Metadata    Host IP    ${output}
    Set Suite Variable    ${HOST_IP}    ${output}
	[Return]    ${output}

Get PhysCellId Of GNB
    [Documentation]    This keyword to get radio protocol type from current scfc file
    ${coam_connection}    COAM.Connect To    bts_host=${GNB_ASIK.ip}
    ${cells_info}=    COAM.get_cell_list    connection=${coam_connection}
    ${cell_num}=    Get Length    ${cells_info['cells']['nr']}
    ${pci}=    Create List
    FOR    ${cell_id}    IN RANGE    ${cell_num}
        Append To List    ${pci}    ${cells_info['cells']['nr'][${cell_id}]['physicalCellId']}
    END
    Set Suite Variable    ${NR_PHY_CELL_IDS}
    [Return]    ${pci}
    [Teardown]    COAM.Teardown    ${coam_connection}

Get Mplane IP Of GNB
    [Documentation]    localIpAddr
    ${ip}=    OperatingSystem.Run    ${SSH_CMD} ip addr|grep "inet "|grep -oE "10.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}"|sed -n "1p"
    Set Suite Variable    ${MPLANE_IP}    ${ip}
    [Return]    ${MPLANE_IP}

Sync Timezone For GNB AP And WTS
    OperatingSystem.Run    sudo timedatectl set-timezone UTC
    Sleep    5s    wait for timezone is changed.
    ${get_time_cmd}=    Set Variable    echo $(date "+%Y-%m-%d %H:%M:%S").$((`date "+%N"`/1000000))
    ${vm_date}=    Run    ${get_time_cmd}
    ${gnb_date}=    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.129 ${get_time_cmd} 2>/dev/null
    ${ap_date}=    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.200.1 ${get_time_cmd} 2>/dev/null
    Log    vm_time:${vm_date},gnb_time:${gnb_date},ap_time:${gnb_date}    console=True
    #OperatingSystem.Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.129 timedatectl set-timezone "Asia/Shanghai"
    #OperatingSystem.Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.200.1 timedatectl set-timezone "Asia/Shanghai"

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
    COAM.Setup Admin
    ${cells_info}=    COAM.Get Cell List
    ${dist_name}=    Set Variable    ${cells_info['cells']['nr'][0]['id']['configuration']}
    Log    ${dist_name}
    ${mrbts}    ${nrbts}    ${nrcell}    String.Split String    ${dist_name}    /
    ${bts_id}    Fetch From Right    ${mrbts}    -
    [Return]    ${bts_id}
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown

Check Config File Absolute Path Or Relative Path
    [Arguments]    ${config_file}
    [Documentation]    This keyword is used to check scf or delta file absolute path or relative path
    ...    This keyword is very complicated. If you want to modify it,you should run UT.
    ...    UT address:
    ...    Examples:
    ...    Check Config File Absolute Path Or Relative Path    ${CURDIR}/scf.xml
    ...    Check Config File Absolute Path Or Relative Path    ${CURDIR}/delta.json
    ...    Check Config File Absolute Path Or Relative Path    scf.xml
    ...    Check Config File Absolute Path Or Relative Path    delta.json
    Should Not Start With    ${config_file}    .    msg=ERROR: use \$\{CURDIR\} instead of . for config file
    ${ret}=    run keyword and return status    File Should Exist    ${config_file}
    ${ret2}=    run keyword and return status    File Should Exist    ${SCF_PATH}/${config_file}
    ${ret3}=    run keyword and return status    File Should Exist    ${SCF_DIR}/${config_file}
    ${config_pull_path1}=    set variable if    "${ret}"=="${True}"    ${config_file}
    ...    "${ret2}"=="${True}"    ${SCF_PATH}/${config_file}
    ...    "${ret3}"=="${True}"    ${SCF_DIR}/${config_file}
    ${config_pull_path2}=    Run Keyword If    "${config_pull_path1}"=="None"    Join Config File Path    ${config_file}
    ${config_pull_path}=    set variable if    "${config_pull_path1}"!="None"    ${config_pull_path1}
    ...    "${config_pull_path2}"!="None"    ${config_pull_path2}
    File Should Exist    ${config_pull_path}
    [Return]    ${config_pull_path}

Join Config File Path
    [Arguments]    ${config_file}
    ${suite_path}    ${suite_file}=    OperatingSystem.Split Path    ${SUITE SOURCE}
    ${scf_path_define_in_robot}=    Get Variable Value    ${SCF_PATH}    ${suite_path}/config
    ${join_config_path}=    OperatingSystem.Join Path    ${scf_path_define_in_robot}    ${SW_BRANCH}    SCF    ${config_file}
    ${new_branch_status}    ${ret}    Run Keyword And Ignore Error    File Should Exist    ${join_config_path}
    Run Keyword If    '${new_branch_status}'=='FAIL'    Copy SCF Files From Lastest Old SW_BRANCH    ${scf_path_define_in_robot}
    File Should Exist    ${join_config_path}
    [Return]    ${join_config_path}

Copy SCF Files From Lastest Old SW_BRANCH
    [Arguments]    ${scf_path_define_in_robot}
    ${new_branch_config_path}=    OperatingSystem.Join Path    ${scf_path_define_in_robot}    ${SW_BRANCH}
    # OperatingSystem.Create Directory    ${new_branch_config_path}
    ${folder_list}    OperatingSystem.List Directories In Directory    ${scf_path_define_in_robot}
    ${folder_list_str}    Evaluate    ','.join(${folder_list})
    ${scf_folder_list}    Get Regexp Matches    ${folder_list_str}    ,?(?P<SCF_folder>SBTS[0-9R]*)    SCF_folder
    ${rc}    ${output}=    Run And Return Rc And Output
    ...    cp -rf ${scf_path_define_in_robot}/${scf_folder_list[-1]} ${new_branch_config_path}

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
    ${delta_full_path}=    Check Config File Absolute Path Or Relative Path    ${delta_json}
    ${scf_file_type}    Get File Type    ${delta_full_path}
    Should Be True    '${scf_file_type}'=='json'    msg=This File is not a json file.
    Log To Console    Config file is ${delta_full_path}
    Run Keyword If    '${NRBTS_DISTNAME}'=='${EMPTY}'    Get Default NRBTS DistName
    COAM.Setup Admin
    Modify File Parameter    ${delta_full_path}    MRBTS-[0-9]+/NRBTS-[0-9]+    ${NRBTS_DISTNAME}
    COAM.Perform Delta Recommissioning
    ...    delta_file=${delta_full_path}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=300
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown

Full Commission With SCF File
    [Arguments]    ${scf_file}    ${auto_update}=True
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
    Log To Console    Perform full commissioning，please use the scf with full configuration saved.
    Get Software Version
    ${scf_pull_path}=    Check Config File Absolute Path Or Relative Path    ${scf_file}
    Log To Console    Config file is ${scf_pull_path}
    ${NRBTS_DISTNAME}    Set Variable If    '${NRBTS_DISTNAME}'==''    MRBTS-1/NRBTS-1    ${NRBTS_DISTNAME}
    ${MRBTS_DISTNAME}    Set Variable If    '${MRBTS_DISTNAME}'==''    MRBTS-1    ${MRBTS_DISTNAME}
    Modify File Parameter    ${scf_pull_path}    MRBTS-[0-9]+/NRBTS-[0-9]+    ${NRBTS_DISTNAME}
    Modify File Parameter    ${scf_pull_path}    MRBTS-[0-9]+    ${MRBTS_DISTNAME}
    Modify VlanId In SCF File    ${scf_pull_path}
    ${auto_update}=    Set Variable If    "${IS_SOFTWARE_KNIFE}"=="${True}" or "${SKIP_ADMIN_CLI}"=="${True}"     ${False}    ${False}
    ${sw}=    Set Variable If    "${BASELINE}"!=""    ${BASELINE}    ${SW_VERSION_TOTAL}
    ${new_scf_path}    Run Keyword If    "${ENB_BUILD}"=="SBTS" and "${auto_update}"=="True"   Migration SCF To New Release    ${scf_pull_path}
    ...    ${sw}
    ${new_scf_path}=    Set Variable If    "${new_scf_path}"=="${None}"    ${scf_pull_path}    ${new_scf_path}
    File Should Exist    ${new_scf_path}
    ${bts_id}    Get Regexp Matches    MRBTS-1/NRBTS-1    MRBTS-(?P<bts_id>\\d+)\\/    bts_id
    COAM.Setup Admin
    COAM.Perform Commissioning
    ...    bts_id=${bts_id[0]}
    ...    scf_file=${new_scf_path}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=300
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown

Connect To AP ASIK
    [Documentation]    This keyword is to connect to Airphone ASIK
    SSH.Connect To    ${AP_ASIK.ip}    ${AP_ASIK.username}    ${AP_ASIK.password}
    ...    alias=${AP_ASIK.connection}

Connect To GNB FCT
    Connect To GNB ASIK

Connect To GNB ASIK
    [Documentation]    This keyword is to connect to Airphone ASIK
    SSH.Connect To    ${GNB_ASIK.ip}    ${GNB_ASIK.username}    ${GNB_ASIK.password}
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
    Wait Until Keyword SucceedS    2 min    10 s    SSH.Connect To    ${${conn_type}.ip}    ${${conn_type}.username}
    ...    ${${conn_type}.password}    alias=${${conn_type}.connection}
    : FOR    ${params}    IN    @{id_value_lst}
    \    @{param_value}    Split String    ${params}    =
    \    ${feature_flag_org}    SSH.Execute    command=cat /ffs/run/swconfig.txt |grep @{param_value}[0]    connection=${${conn_type}.connection}
    \    ${feature_flag}    Fetch From Left    ${feature_flag_org}    marker=\r\n
    \    ${len}    Get Length    ${feature_flag}
    \    Set Suite Variable    ${len}
    \    ${cmd_0}    Set Variable    command=cp /ffs/run/swconfig.txt /ffs/run/swconfig_bak.txt
    \    ${cmd_1}    Set Variable    sed -i '$a ${params}' /ffs/run/swconfig.txt
    \    ${cmd_3}    Set Variable    sed -ie 's/${feature_flag}/${params}/g' /ffs/run/swconfig.txt
    \    ${cmd A}    Catenate    SEPARATOR=;    ${cmd_0}    ${cmd 1}    ${cmd 2}
    \    ${cmd B}    Catenate    SEPARATOR=;    ${cmd_0}    ${cmd 3}    ${cmd 2}
    \    Run Keyword If    ${len} == ${0}    SSH.Execute    command=${cmd_a}    connection=${${conn_type}.connection}
    \    Run Keyword Unless    ${len} == ${0}    SSH.Execute    command=${cmd_b}    connection=${${conn_type}.connection}

Reboot Testline Via SSH
    [Documentation]    This keyword is to reboot gNB and Airphone with reboot command
    Log To Console    Reboot testline via ssh...
    Wait Until Keyword Succeeds    120s    5s    Check AP Ping OK
    Wait Until Keyword Succeeds    120s    5s    Check GNB Ping OK
    Wait Until Keyword Succeeds    60s    5s    Check AP SSH Connect OK
    Wait Until Keyword Succeeds    60s    5s    Check GNB SSH Connect OK
    ${ret}    ${output}=    OperatingSystem.Run And Return Rc And Output
    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} 'reboot'
    Run Keyword If    "${ret}"!="0"    Fail    WRN:Soft reboot AP failed!
    Wait Until Keyword Succeeds    120s    5s    Check AP Ping NOK
    ${ret}    ${output}=    OperatingSystem.Run And Return Rc And Output
    ...    sshpass -p ${GNB_ASIK.password} ssh ${GNB_ASIK.username}@${GNB_ASIK.ip} 'reboot'
    Run Keyword If    "${ret}"!="0"    Fail    WRN:Soft reboot Gnb failed!
    Wait Until Keyword Succeeds    120s    5s    Check GNB Ping NOK
    Wait Until Keyword Succeeds    120s    5s    Check AP Ping OK
    Wait Until Keyword Succeeds    120s    5s    Check GNB Ping OK

Setup X2 Connection
    [Arguments]    ${enb_id}=1    ${gnb_id}=2
    [Documentation]    This keyword is to setup X2 connection and check x2 is ok
    Log To Console    setup X2 connection...
    ${pattern}    Set Variable    ENB-${enb_id}: X2AP Link with GNB-${gnb_id} .* is up
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    enb_x2_link_up enb\=${enb_id} target\=${gnb_id}
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
    #[Arguments]    ${check_cell_count}=${NR_NON_SIMULATED_CELL_NUM}
    [Documentation]    This keyword is to wait for cell setup successfully.It checks print in aiphone APL3.log
    ...
    ...           The max waiting time is set by ${MAX_WAITTIME_CELL_SETUP},the default value is 3 minutes
    Log To Console    verify cell setup...
    Get NR Cell Number
    Wait Until Keyword Succeeds    ${MAX_WAITTIME_CELL_SETUP}    15s    Check UTE ASIK AP Cell Setup    ${NR_NON_SIMULATED_CELL_NUM}
    Log    cell_setup_is_ok

Check UTE ASIK AP Cell Setup
    [Documentation]    This keyword is to check "Cell Setup Completed" in Airphone ASIK
    [Arguments]    ${check_cell_count}=1
    Log To Console    check ute ASIK AP cell setup...
    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.200.1:/tmp/APL3.log ${OUTPUT_DIR}
    ${cell_complete_print}=    Set Variable    Cell Setup completed
    ${output}=    OperatingSystem.Run    grep -i "${cell_complete_print}" ${OUTPUT_DIR}/APL3.log
    ${cell_complete_num}=    Get Count    ${output}    ${cell_complete_print}
    Should Be True    ${cell_complete_num}>=${check_cell_count}

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
    ${MRBTS_DISTNAME}    Set Variable If    '${MRBTS_DISTNAME}'==''    MRBTS-1    ${MRBTS_DISTNAME}
    ${vlanif_distname}    Set Variable    ${MRBTS_DISTNAME}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1
    ${vlan_id}    Convert To String    ${VLAN_ID}
    ${vlan_id_scf}    Get Single Value From Scf File    file_path=${scf_path}    dist_name=${vlanif_distname}    para_name=vlanId
    Log To Console    VlanId in Testline: ${vlan_id}
    Log To Console    VlanId in Origin SCF file: ${vlan_id_scf}
    Set Single Value From Scf File    file_path=${scf_path}
    ...    dist_name=${vlanif_distname}    para_name=vlanId    para_value=${vlan_id}

Migration SCF To New Release
    [Arguments]    ${scf_path}    ${sw}=${SW_VERSION_TOTAL}
    [Documentation]    This keyword is to use ADMIN CLI to migration SCF for new version.Only support SBTS package.
    ...    This keyword doesn't support 0.400 package.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${scf_path} | Yes | the path name for SCF file which need to migrate.
    ...           The SCF file should be saved with FULL CONFIGURATION as need to know swVerion for the SCF file. |
    ...
    ...    Examples:
    ...    | Migration SCF To New Release | /home/ute/Auto5G/testsuite/RRM/ECE/CUDU_L2/Full_Configuration_scf.xml |
    Log To Console    Migration SCF To New Release...
    OperatingSystem.File Should Exist    ${scf_path}
    ${download_file}    Download Zip From WFT    sw=${sw}    store_path=/tmp/
    ${new_scf_path}=    Unzip And Do Migration SCF    ${download_file}    ${scf_path}
    [Return]    ${new_scf_path}

Download Zip From WFT
    [Arguments]    ${sw}=${SW_VERSION_TOTAL}    ${store_path}=/tmp/
    [Documentation]    This keyword is to download zip file from release note.
    ...    used in keyword 'Migration SCF To New Release'
    ...    Return ${download_status}, if download success, it's True. if not, it's False.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${sw} | Yes | the sw release, such as 0.800.1487 |
    ...    | ${store_path} | Yes | the path need to store from download,such as ${output_dir} |
    ...
    ...    Examples:
    ...    | Download Zip From WFT | 0.800.1487 | 5G_0.800.1487_ADMIN_CLI.zip | ${output_dir} |
    Log To Console    Download ADMIN CLI file...
    ${release_url_SBTS}    Set Variable
    ...    ${PACKAGE_FTP_URL_WFT_SBTS}/${SW_VERSION}/${sw}/${sw}_ADMIN_CLI.zip
    OperatingSystem.Run    wget ${release_url_SBTS} -P ${store_path}
    ${ret}=    run keyword and return status    OperatingSystem.Should Exist    ${store_path}/${sw}_ADMIN_CLI.zip
    ${rc}    ${output}=    run and return rc and output    traceroute https://artifactory-espoo2.int.net.nokia.com
    run keyword if    "${ret}"=="${False}" and "${rc}"!="0"    Fail    WRN:can't connect to WFT,firewall not open.
    run keyword if    "${ret}"=="${False}" and "${rc}"=="0"    Fail    WRN:There is no ${sw}_ADMIN_CLI.zip on WFT.
    [Return]    ${store_path}/${sw}_ADMIN_CLI.zip

Unzip And Do Migration SCF
    [Arguments]    ${zip_file}    ${input_scf_path}
    [Documentation]    This keyword is to unzip and do migration.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${zip_file} | Yes | the name of the zip file storeed |
    ...    | ${input_scf_path} | Yes | the path of the inputed scf file  |
    ...    Examples: see the detail in keyword 'Migration SCF To New Release'
    ...
    Log To Console    Unzip ADMIN CLI file and do migration...
    ${folder}    ${file_name}=    OperatingSystem.Split Path    ${zip_file}
    OperatingSystem.Run    rm -rf ${folder}/admin_cli/; unzip ${zip_file} -d ${folder}/admin_cli/
    OperatingSystem.Should Exist    ${folder}/admin_cli/migrateScf.sh
    OperatingSystem.Run    cd ${folder}/admin_cli/;sh ${folder}/admin_cli/migrateScf.sh --input-file ${input_scf_path} --output-file output_file.xml
    OperatingSystem.Should Exist    ${folder}/admin_cli/output_file.xml
    [Return]    ${folder}/admin_cli/output_file.xml

Get Control Board Type
    [Documentation]    this keyword is used to get control board Type, ASIK, ASIB, ASIL etc.
    ute_fsmaccess.Setup Enb Fsm Access
    ${cmd}=    Set Variable    cat /proc/device-tree/module-identity/unit-id
    ${board_type}=    ute_fsmaccess.Execute Command On Enb    ${cmd}
    ${board_type}=    String.Replace String Using Regexp    ${board_type}    \x00    ${EMPTY}
    Set Suite Variable    ${FCT_BOARD_TYPE}    ${board_type}
    Log    GNB Control Board Type: ${FCT_BOARD_TYPE}     console=${True}
    [Teardown]    ute_fsmaccess.Teardown Enb Fsm Access
    [Return]    ${board_type}

Get Base Band Boards Type
    [Documentation]    this keyword is used to get base band board Type, ABIL，ABIO，ABIN etc.
    ${frame_id_list}=    Create List    1    2    3
    ${ASP_BOARDS_TYPE}    Create List
    FOR    ${frame_id}    IN    @{frame_id_list}
        ${ret}=    Run Keyword And Return Status    Get Base Band Board Type    ${frame_id}
        Run Keyword If    "${ret}"=="${TRUE}"    Collections.Append To List    ${ASP_BOARDS_TYPE}    ${ASP_BOARD_TYPE}
    END
    Log    GNB Base Band Boards Type: ${ASP_BOARDS_TYPE}     console=${True}
    Set Suite Variable    ${ASP_BOARDS_TYPE}
    [Return]    ${ASP_BOARDS_TYPE}

Get Base Band Board Type
    [Arguments]    ${frame_id}=1
    [Documentation]    this keyword is used to get base band board Type, ABIL，ABIO，ABIN etc.
    ute_fsmaccess.Setup Enb Fsm Access
    ${cmd}=    Set Variable    bsh ${frame_id}:0 cat /proc/device-tree/module-identity/unit-id
    ${board_type}=    ute_fsmaccess.Execute Command On Enb    ${cmd}
    ${board_type}=    String.Replace String Using Regexp    ${board_type}    \x00    ${EMPTY}
    Set Suite Variable    ${ASP_BOARD_TYPE}    ${board_type}
    [Teardown]    ute_fsmaccess.Teardown Enb Fsm Access
    [Return]    ${board_type}

Get AP Control Board Type
    [Documentation]    this keyword is used to get control board Type, ASIK, ASIB, ASIL etc.
    ute_fsmaccess.Setup Wts Fsm Access
    ${cmd}=    Set Variable    cat /proc/device-tree/module-identity/unit-id
    ${board_type}=    ute_fsmaccess.Execute Command On Wts    ${cmd}
    ${board_type}=    String.Replace String Using Regexp    ${board_type}    \x00    ${EMPTY}
    Set Suite Variable    ${AP_FCT_BOARD_TYPE}    ${board_type}
    [Teardown]    ute_fsmaccess.Teardown Wts Fsm Access
    [Return]    ${board_type}

Get AP Base Band Boards Type
    [Documentation]    this keyword is used to get base band board Type, ABIL，ABIO，ABIN etc.
    ${frame_id_list}=    Create List    1    2    3
    ${AP_ASP_BOARDS_TYPE}    Create List
    FOR    ${frame_id}    IN    @{frame_id_list}
        ${ret}=    Run Keyword And Return Status    Get AP Base Band Board Type    ${frame_id}
        Run Keyword If    "${ret}"=="${TRUE}"    Collections.Append To List    ${AP_ASP_BOARDS_TYPE}    ${AP_ASP_BOARD_TYPE}
    END
    Log    AP Base Band Boards Type: ${AP_ASP_BOARDS_TYPE}     console=${True}
    Set Suite Variable    ${AP_ASP_BOARDS_TYPE}
    [Return]    ${AP_ASP_BOARDS_TYPE}

Get AP Base Band Board Type
    [Arguments]    ${frame_id}=1
    [Documentation]    this keyword is used to get base band board Type, ABIL，ABIO，ABIN etc.
    ute_fsmaccess.Setup Wts Fsm Access
    ${cmd}=    Set Variable    bsh ${frame_id}:0 cat /proc/device-tree/module-identity/unit-id
    ${board_type}=    ute_fsmaccess.Execute Command On Wts    ${cmd}
    ${board_type}=    String.Replace String Using Regexp    ${board_type}    \x00    ${EMPTY}
    Set Suite Variable    ${AP_ASP_BOARD_TYPE}    ${board_type}
    [Teardown]    ute_fsmaccess.Teardown Wts Fsm Access
    [Return]    ${board_type}

Get RRU Type
    [Documentation]    this keyword is used to get RRU Type, AEQA,AAHF etc.
    ute_fsmaccess.Setup Wts Fsm Access
    ${cmd}=    Set Variable    cat /ffs/run/simmode/iphy.xml|grep -Eo "<cardName>.*</cardName>"|grep -Eo "[[:upper:]]{4,5}"
    ${RRU_type_1}=    ute_fsmaccess.Execute Command On Wts    ${cmd}
    ${RRU_type_list}=    String.Split To Lines    ${RRU_type_1}
    Set Suite Variable    @{RRU_TYPE}    ${RRU_type_list}[0]
    Set Suite Variable    ${RRU_TYPE_LIST}    ${RRU_type_list}
    Log    RRU Type List: ${RRU_type_list}     console=${True}
    Log    RRU Type: ${RRU_TYPE}     console=${True}
    [Teardown]    ute_fsmaccess.Teardown Wts Fsm Access
    [Return]    ${RRU_type_1}

Get Host Name
    ${ret}    ${host_name}=    OperatingSystem.Run And Return Rc And Output    hostname|sed 's/-/_/g'
    Log    Host Name: ${host_name}     console=${True}
    Log    Testline init file is /home/ute/testline_configuration/${host_name}/      console=${True}
    Set Suite Metadata    Host Name    ${host_name}
    [Return]    ${host_name}

Get Cell Numbers
    ${nr_phy_cell_ids}=    Get PhysCellId Of GNB
    ${cell_number}=    Get Length    ${nr_phy_cell_ids}
    Set Suite Variable    ${COMPONENT_CARRIER}    ${cell_number}
    Log    Cells Number: ${COMPONENT_CARRIER}     console=${True}
    [Return]    ${cell_number}

Hard Reboot Testline
    Log To Console    Start to hard reboot testline...
    Print Current Time    Hard Reboot Time
    Log To Console    Start to power off AP and GNB...
    ${AP_PDU}=    Get Variable Value    ${AP_PDU}    ${EMPTY}
    Run Keyword If    "${AP_PDU}"=="${EMPTY}"    Import Testline Variables
    Power Off AP
    Wait Until Keyword Succeeds    120s    5s    Check AP Ping NOK
    Power Off GNB
    Wait Until Keyword Succeeds    120s    5s    Check GNB Ping NOK
    Log To Console    Start to power on AP and GNB...
    PDU.Power On    port=${AP_PDU_PORT}    pdu_device=pdu_alias_ap
    PDU.Power On    port=${GNB_PDU_PORT}    pdu_device=pdu_alias_gnb
    ${ret}=    Run Keyword And Return Status    Wait Until Keyword Succeeds    150s    5s    Check GNB And AP Ping OK
    Run Keyword If    "${ret}"=="${False}"    PDU.Power On    port=${AP_PDU_PORT}    pdu_device=pdu_alias_ap
    Run Keyword If    "${ret}"=="${False}"    PDU.Power On    port=${GNB_PDU_PORT}    pdu_device=pdu_alias_gnb
    Wait Until Keyword Succeeds    150s    5s    Check GNB And AP Ping OK
    Wait Until Keyword Succeeds    60s    5s    Check GNB SSH Connect OK
    Wait Until Keyword Succeeds    60s    5s    Check AP SSH Connect OK

Power Off GNB
    PDU.Setup Pdu    ${GNB_PDU}    alias=pdu_alias_gnb
    PDU.Power Off    port=${GNB_PDU_PORT}    pdu_device=pdu_alias_gnb
    #Wait Until Keyword Succeeds    120s    3s    Check PDU Status    pdu_alias_gnb    off    ${GNB_PDU_PORT}

Power Off AP
    PDU.Setup Pdu    ${AP_PDU}    alias=pdu_alias_ap
    PDU.Power Off    port=${AP_PDU_PORT}    pdu_device=pdu_alias_ap
    #Wait Until Keyword Succeeds    120s    3s    Check PDU Status    pdu_alias_ap    off    ${AP_PDU_PORT}

Hard Reboot GNB
    Power Off GNB
    PDU.Power On    port=${GNB_PDU_PORT}    pdu_device=pdu_alias_gnb
    #Wait Until Keyword Succeeds    120s    3s    Check PDU Status    pdu_alias_gnb    on    ${GNB_PDU_PORT}

Hard Reboot Airphone
    Power Off AP
    PDU.Power On    port=${AP_PDU_PORT}    pdu_device=pdu_alias_ap
    #Wait Until Keyword Succeeds    120s    3s    Check PDU Status    pdu_alias_ap    on    ${AP_PDU_PORT}

Check PDU Status
    [Arguments]    ${alias}    ${target_status}    ${PDU_PORT}
    ${status}=    PDU.Get Port Status    port=${PDU_PORT}    pdu_device=${alias}
    Should Be True    "${status}"=="${target_status}"

Check GNB Ping OK
    ${ret}    ${output}=    Run And Return Rc And Output    ping -c 3 192.168.255.129
    ${console_log}=    Set Variable If    "${ret}"=="0"    VM ping GNB OK!    VM ping GNB NOK!
    Log To Console    ${console_log}
    ${status}=    Set Variable If    "${ret}"=="1"    ${False}    ${True}
    Should Be True    "${ret}"=="0"    WRN:VM ping GNB NOK!
    [Return]    ${status}

Check AP Ping OK
    ${ret}    ${output}=    Run And Return Rc And Output    ping -c 3 192.168.200.1
    ${console_log}=    Set Variable If    "${ret}"=="0"    VM ping AP OK!    VM ping AP NOK!
    Log To Console    ${console_log}
    ${status}=    Set Variable If    "${ret}"=="1"    ${False}    ${True}
    Should Be True    "${ret}"=="0"    WRN:VM ping AP NOK!
    [Return]    ${status}

Check GNB And AP Ping OK
    ${ret_1}    ${output}=    Run And Return Rc And Output    ping -c 3 192.168.255.129
    ${ret_2}    ${output}=    Run And Return Rc And Output    ping -c 3 192.168.200.1
    ${console_log}=    Set Variable If    "${ret_1}"=="0"    VM ping GNB OK!    VM ping GNB NOK!
    Log To Console    ${console_log}
    ${console_log}=    Set Variable If    "${ret_2}"=="0"    VM ping AP OK!    VM ping AP NOK!
    Log To Console    ${console_log}
    ${status}=    Set Variable If    "${ret_1}"=="1"or "${ret_2}"=="1"    ${False}    ${True}
    Should Be True    "${ret_1}"=="0" and "${ret_2}"=="0"    WRN:VM ping GNB and AP NOK!
    [Return]    ${status}

Check GNB Ping NOK
    ${ret}    ${output}=    Run And Return Rc And Output    ping -c 3 192.168.255.129
    ${console_log}=    Set Variable If    "${ret}"=="0"    VM ping GNB OK!    VM ping GNB NOK!
    Log To Console    ${console_log}
    ${status}=    Set Variable If    "${ret}"=="1"    ${True}    ${False}
    Should Be True    "${ret}"=="1"    WRN:VM ping GNB OK!
    [Return]    ${status}

Check AP Ping NOK
    ${ret}    ${output}=    Run And Return Rc And Output    ping -c 3 192.168.200.1
    ${console_log}=    Set Variable If    "${ret}"=="0"    VM ping GNB OK!    VM ping GNB NOK!
    Log To Console    ${console_log}
    ${status}=    Set Variable If    "${ret}"=="1"    ${True}    ${False}
    Should Be True    "${ret}"=="1"    WRN:VM ping AP OK!
    [Return]    ${status}

Check GNB SSH Connect OK
    ${ret}    ${output}=    Run And Return Rc And Output    timeout 5s sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.129 pwd
    ${console_log}=    Set Variable If    "${ret}"=="0"    SSH connect GNB OK!    SSH connect GNB NOK!
    Log To Console    ${console_log}
    ${status}=    Set Variable If    "${ret}"=="1"    ${False}    ${True}
    Should Be True    "${ret}"=="0"    WRN:VM ssh GNB failed!
    [Return]    ${status}

Check AP SSH Connect OK
    ${ret}    ${output}=    Run And Return Rc And Output    timeout 5s sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.200.1 pwd
    ${console_log}=    Set Variable If    "${ret}"=="0"    SSH connect AP OK!    SSH connect AP NOK!
    Log To Console    ${console_log}
    ${status}=    Set Variable If    "${ret}"=="1"    ${False}    ${True}
    Should Be True    "${ret}"=="0"    WRN:VM ssh AP failed!
    [Return]    ${status}

Check AP EIF Ping OK
    ${ret}    ${output}=    Run And Return Rc And Output    ping -c 3 10.0.2.80 -i 0.5
    ${status}=    Set Variable If    "${ret}"=="1"    ${False}    ${True}
    Should Be True    "${ret}"=="0"    WRN:VM ping AP EIF failed!
    ${ret}    ${output}=    Run And Return Rc And Output    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.200.1 "ping -c 3 10.0.2.1"
    ${status}=    Set Variable If    "${ret}"=="1"    ${False}    ${True}
    Should Be True    "${ret}"=="0"    WRN:AP EIF ping VW failed!
    [Return]    ${status}

Check GNB EIF Ping OK
    ${ret}    ${output}=    Run And Return Rc And Output    ping -c 3 10.0.1.2 -i 0.5
    ${status}=    Set Variable If    "${ret}"=="1"    ${False}    ${True}
    Should Be True    "${ret}"=="0"    WRN:VM ping GNB EIF failed!
    ${ret}    ${output}=    Run And Return Rc And Output    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.129 "ping -c 3 10.0.1.1"
    ${status}=    Set Variable If    "${ret}"=="1"    ${False}    ${True}
    Should Be True    "${ret}"=="0"    WRN:GNB EIF ping VM failed!
    [Return]    ${status}

Copy Config File To Airphone QT Folder
    ${cmd}=    Set Variable    cp -r ${CURDIR}/config/l1b_tdd_nsa_ASIL_ABIO_cmwv ${WTS_CONFIG_PATH}
    OperatingSystem.Run And Return Rc And Output    ${cmd}

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
    ...    sshpass -p oZPS0POrRieRtu scp ${path} 'toor4nsn@192.168.200.1:/ffs/run/swconfig.txt;crasign /ffs/run/swconfig.txt'
    Should Be Equal As Integers    ${rc}    0

Get Swconfig File From GNB
    [Arguments]    ${save_dir}
    OperatingSystem.Run
    ...    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.129:/ffs/run/swconfig.txt ${save_dir}/swconfig_gnb.txt
    OperatingSystem.Should Exist    ${save_dir}/swconfig_gnb.txt
    ${path}    Set Variable    ${save_dir}/swconfig_gnb.txt
    [Return]    ${path}

Send Swconfig File To GNB
    [Arguments]    ${path}
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p oZPS0POrRieRtu scp ${path} 'toor4nsn@192.168.255.129:/ffs/run/swconfig.txt;crasign /ffs/run/swconfig.txt'
    Should Be Equal As Integers    ${rc}    1

Print Current Time
    [Arguments]    ${log}=...
    ${date}=    DateTime.Get Current Date
    BuiltIn.log to console    ${date}:${log}

Modify IPHY File Version By Airphone Automatically And Send To Airphone
    [Arguments]    ${iphy_path}
    ${content}=    OperatingSystem.Get File    path=${iphy_path}
    ${new_content}=      String.Replace String Using Regexp    ${content}    <buildversion>.*<\/buildversion>    <buildversion>0.00<\/buildversion>
    OperatingSystem.Create File    ${iphy_path}    ${new_content}
    Send IPHY XML To Airphone    ${iphy_path}

Modify IPHY File And Send to Airphone
    [Arguments]    ${iphy_path}
    ${RRU_type_list}    Get RRU Type From Local IPHY XML    ${iphy_path}
    FOR    ${RRU_type}    IN    @{RRU_type_list}
        ${RRU_Version}    Get RRU Version From TargetBD File    ${RRU_type}    ${OUTPUT_DIR}
        Modify RRU Version Of IPHY XML    ${iphy_path}    ${RRU_type[0]}    ${RRU_Version}
    END
    Send IPHY XML To Airphone    ${iphy_path}

Get RRU Type From Local IPHY XML
    [Arguments]    ${iphy_path}
    ${ret}    tak_xml.Evaluate Xml Xpath    ${iphy_path}   count(//RE)
    ${num}    Evaluate      int(${ret})+1
    ${RRU_type_list}    Create List
    ${RRU_type_ecpri_list}    Create List
    FOR     ${index}    IN RANGE     1      ${num}
        ${rru_type}    tak_xml.Evaluate Xml Xpath    ${iphy_path}   string(//RE[${index}]/identity/cardName)
        ${ecpri_tag}    tak_xml.Evaluate Xml Xpath    ${iphy_path}   string(//RE[${index}]/ecpri)
        ${type_list}    Create List    ${rru_type}    ${ecpri_tag}
        Append To List    ${RRU_type_list}    ${rru_type}
        Append To List    ${RRU_type_ecpri_list}    ${type_list}
    END
    Set Suite Variable    ${RRU_type_list}
    Set Suite Variable    ${RRU_TYPE}    ${RRU_type_list[0]}
    [Return]    @{RRU_type_ecpri_list}

Get RRU Version From TargetBD File
    [Arguments]    ${RRU_type}    ${save_dir}
    ${RRU_type}=    Set Variable If    "${RRU_type[0]}"=="AAHF"    AAHF_C1
    ...    "${RRU_type[0]}"=="AEUB"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AEHC"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AEUD"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AWEUA"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AWHHF"    AWHHF_N1
    ...    "${RRU_type[1]}"=="true"    ${RRU_type[0]}_E1
    ...    ${RRU_type[0]}
    OperatingSystem.Run
    ...    sshpass -p ${GNB_ASIK.password} scp ${GNB_ASIK.username}@${GNB_ASIK.ip}:/ffs/run/TargetBD*.xml ${save_dir}/TargetBD.xml
    OperatingSystem.Should Exist    ${save_dir}/TargetBD.xml
    ${content}=    OperatingSystem.Get File    path=${save_dir}/TargetBD.xml
    ${check_point_regexp}    Set Variable    resourceBuildKey="LTX_${RRU_type}".*resourceSWVersion="(?P<RRU_Version>.*)"
    @{RRU_Version}    String.Get Regexp Matches    ${content}    ${check_point_regexp}    RRU_Version
    [Return]    ${RRU_Version}[0]

Modify RRU Version Of IPHY XML
    [Arguments]    ${iphy_path}    ${RRU_type}    ${RRU_Version}
    ${content}    OperatingSystem.Get File    path=${iphy_path}
    ${bldVersion}=    String.Get Regexp Matches    ${content}
    ...    <cardName>${RRU_type}<\/cardName>[\\s\\S]*?<bldVersion>(?P<bldVersion>.*)<\/bldVersion>
    ...    bldVersion
    Log Many    ${bldVersion[0]}    ${RRU_Version}
    ${new_content}    String.Replace String    ${content}    ${bldVersion[0]}    ${RRU_Version}
    Log    ${new_content}
    OperatingSystem.Create File    path=${iphy_path}    content=${new_content}

Modify GSCN Of IPHY XML
    [Arguments]    ${iphy_path}    ${phy_cell_id}    ${gscn_id}
    ${content}    OperatingSystem.Get File    path=${iphy_path}
    ${phycell_and_gscn_node_list}=    String.Get Regexp Matches    ${content}
    ...    <phy_cell_id>${phy_cell_id}<\/phy_cell_id>[\\s\\S]*?<GSCN>.*<\/GSCN>
    ${phycell_and_gscn_node}=    Set Variable    ${phycell_and_gscn_node_list}[0]
    ${new_phycell_and_gscn_node}=    String.replace_string_using_regexp    ${phycell_and_gscn_node}    <GSCN>.*<\/GSCN>    <GSCN>${gscn_id}<\/GSCN>
    ${new_content}    String.Replace String    ${content}    ${phycell_and_gscn_node}    ${new_phycell_and_gscn_node}
    OperatingSystem.Create File    path=${iphy_path}    content=${new_content}

Modify GSCN On Airphone
    [Arguments]    ${phy_cell_id}    ${gscn_id}
    Get IPHY XML File    ${OUTPUT_DIR}
    Modify GSCN Of IPHY XML    ${OUTPUT_DIR}/iphy.xml    ${phy_cell_id}    ${gscn_id}
    Send IPHY XML To Airphone    ${OUTPUT_DIR}/iphy.xml

Get Cell Number From Cfg
    [Arguments]    ${cfg_path}=${WTS_DIR}/${WTS_CFG}
    [Documentation]    This keyword is to get cell num from cfg file with count the number of 'set_cell id='
    ...
    ${content}    OperatingSystem.Get File    path=${cfg_path}
    ${regexp}    Set Variable    ^set_cell id=.*?gnb=
    ${match_list}     Get Lines Matching Regexp    ${content}    ${regexp}    partial_match=true
    Log    ${match_list}
    ${cell_num}    Get Count    ${match_list}    set_cell id=
    [Return]    ${cell_num}

Get NR Cell Number
    ${cell_num_cfg}=    Get Cell Number From Cfg
    ${cell_num_gnb}=    Get Cell Numbers
    ${cell_num}=    Set Variable If    ${cell_num_cfg}<${cell_num_gnb}    ${cell_num_cfg}    ${cell_num_gnb}
    Set Suite Variable    ${NR_NON_SIMULATED_CELL_NUM}    ${cell_num}

Check All Cells Received SIB2
    Get NR Cell Number
    ${egate_file}    Set Variable    /opt/iphy/latest/egate_console.log
    Wait Until Keyword Succeeds    240s    5s    Check Egate Log With Message    ${egate_file}
    ...    SystemInformationBlockType2-NR updated    ${NR_NON_SIMULATED_CELL_NUM}


Check Cell Status And Reboot If Need
    ${all_cell_status}    Get All Cell Status From COAM
    ${status}    Run Keyword And Return Status    List Should Contain Value    ${all_cell_status}    initializing
    Run Keyword If    ${status}     Reboot TL And Check Configured

Read L1 RD Param Value
    [Arguments]    ${board_num}    ${board_node}    ${domain}    ${key}
    [Documentation]    This keyword is to read the value of L1 RD parameter.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${board_num} | Yes | the num of the gNB ASP board, such as 1, 2 |
    ...    | ${board_node} | Yes | 1 for slave, 0 for master |
    ...    | ${domain} | yes | the domain of the L1 RD parameter key, such as NrDlPhy |
    ...    | ${key} | Yes | the name of L1 RD parameter, such as rdAdvancedTimingWindow |
    ...
    ...    This keyword will return the value of the key. and suggest use it after Write L1 RD Param Value
    ...
    ...    Examples:
    ...    | Write L1 RD Param Value | 1 | 1 | NrDlPhy | rdAdvancedTimingWindow | 1|
    ...    | ${value} | Read L1 RD Param Value | 1 | 1 | NrDlPhy | rdAdvancedTimingWindow |
    ${read_cmd}    Catenate    SEPARATOR=${SPACE}    sshpass -p ${GNB.password} ssh ${GNB.username}@${GNB.ip}
    ...    bsh ${board_num}:${board_node} confmgmtbrowser read ${domain} ${key}
    ${ret}    ${output}    OperatingSystem.Run And Return Rc And Output    ${read_cmd}
    ${value}    Get Regexp Matches    ${output}    VALUE:\\s(?P<param_value>\\d+)    param_value
    [Return]    ${value}[0]

Write L1 RD Param Value
    [Arguments]    ${board_num}    ${board_node}    ${domain}    ${key}    ${value}
    [Documentation]    This keyword is to write the value of L1 RD parameter.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${board_num} | Yes | the num of the gNB ASP board, such as 1, 2 |
    ...    | ${board_node} | Yes | 1 for slave, 0 for master |
    ...    | ${domain} | yes | the domain of the L1 RD parameter key, such as NrDlPhy |
    ...    | ${key} | Yes | the name of L1 RD parameter, such as rdAdvancedTimingWindow |
    ...    | ${value} | Yes | the value of L1 RD parameter, such as 1 |
    ...
    ...    This keyword will return the value of the key. and suggest use it after Write L1 RD Param Value
    ...
    ...    Examples:
    ...    | Write L1 RD Param Value | 1 | 1 | NrDlPhy | rdAdvancedTimingWindow | 1|
    ...    | ${value} | Read L1 RD Param Value | 1 | 1 | NrDlPhy | rdAdvancedTimingWindow |
    ${write_cmd}    Catenate    SEPARATOR=${SPACE}    sshpass -p ${GNB.password} ssh ${GNB.username}@${GNB.ip}
    ...    bsh ${board_num}:${board_node} confmgmtbrowser write ${domain} ${key} ${value}
    ${ret}    ${output}    OperatingSystem.Run And Return Rc And Output    ${write_cmd}

Check L1 RD Param Value Changed
    [Arguments]    ${board_num}    ${board_node}    ${domain}    ${key}
    [Documentation]    This keyword is to check the L1 RD parameter was changed
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${board_num} | Yes | the num of the gNB ASP board, such as 1, 2 |
    ...    | ${board_node} | Yes | 1 for slave, 0 for master |
    ...    | ${domain} | yes | the domain of the L1 RD parameter key, such as NrDlPhy |
    ...    | ${key} | Yes | the name of L1 RD parameter, such as rdAdvancedTimingWindow |
    ...
    ...    This keyword will return the value of the key. and suggest use it after Write L1 RD Param Value
    ...
    ...    Examples:
    ...    | Check L1 RD Param Value Changed | 1 | 1 | NrDlPhy | rdAdvancedTimingWindow |
    ${change_cmd}    Catenate    SEPARATOR=${SPACE}    sshpass -p ${GNB.password} ssh ${GNB.username}@${GNB.ip}
    ...    bsh ${board_num}:${board_node} journalctl -b | grep processRadParametersChange
    ${ret}    ${output}    OperatingSystem.Run And Return Rc And Output    ${change_cmd}
    Should Contain    ${output}    ${key}
