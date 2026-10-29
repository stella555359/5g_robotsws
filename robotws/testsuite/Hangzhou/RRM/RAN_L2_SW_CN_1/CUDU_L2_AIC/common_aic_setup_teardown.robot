*** Settings ***
Resource    common_aic_lib_variable.robot
Resource    common_vcu_oam.robot
Resource    common_vdu_oam.robot
Resource    common_aic_file_operation.robot
Resource    common_aic_log_capture.robot
Resource    common_aic_log_analyzer.robot
Resource    common_aic_egate.robot

*** Keywords ***
Common Suite Setup
    Import Testline Variables
    Create Suite Directory
    Run Keyword And Ignore Error    Get Qc File
    Get All Aic Testline Inform And Set Suite Variable

Update Aic GNB
    [Arguments]    ${IPHY_FILE}=${EMPTY}    ${VCU_SCFC_PATH}=${EMPTY}    ${VDU_SCFC_PATH}=${EMPTY}
	Run Keyword If    '${iphy_file}'!='${EMPTY}'    Update Iphy Xml And Reboot AP    ${iphy_file}
    Run Keyword If    '${VCU_SCFC_PATH}'!='${EMPTY}'    VCU Full Commssion    ${VCU_SCFC_PATH}
    Run Keyword If    '${VDU_SCFC_PATH}'!='${EMPTY}'    VDU Full Commssion    ${VDU_SCFC_PATH}
    Wait Until Keyword Succeeds    10min    30s    VCU Verify F1 Setup

Copy WTS Config Files From Local
    [Arguments]    ${local_wts_dir}
    [Documentation]    This keyword is used to copy cfg and xml files from local path.
    ...    If this keyword is used, pls make sure you define below 3 parameters in your case.
    ...    ${LOCAL_WTS_DIR}    ${WTS_CFG}
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${local_dir} | Yes | where cfg and xml files can be found |
    ...
    ...    Examples:
    ...    | *** Variables *** |
    ...    ${LOCAL_WTS_DIR}    ${CURDIR}/resources/wts
    ...    ${WTS_CFG}          basic_fullstack_nsa_call_tdd_cmwv.cfg
    ...
    ...    | Suite Setup Copy WTS Config Files From Local | local_dir=${LOCAL_WTS_DIR} |
    ...
    OperatingSystem.Run    cp ${local_wts_dir}/${WTS_CFG} ${WTS_DIR}
    Wait Until Keyword Succeeds    5s    1s    OperatingSystem.File Should Exist    ${WTS_DIR}/${WTS_CFG}

Start WTS And Check OnAir
    Modify UTE SCTP Timeout
    Modify AP SCTP Timeout
    Configure UTE ETH3
    ${vcu_scf_file}    VCU Get Current Plan File    ${output_dir}    vcu_scf.xml
    Get GNbCuType From SCFC    ${vcu_scf_file}
    Start Edaemon Egate And Load Cfg
    Run Keyword If    '${GNBCUTYPE}'=='NSA' or '${GNBCUTYPE}'=='SA+NSA'    Setup X2 Connection    ${enb_id}    ${gnb_id}
    Run Keyword If    '${GNBCUTYPE}'=='SA+NSA' or '${GNBCUTYPE}'=='SA'    Check All Cells Received SIB2

Common Test Teardown
    [Arguments]    ${mode}=${EMPTY}
    Run Keyword If    '${mode}'!='debug'    Run Keyword If Test Failed    Collect UTE SosReport    ${TEST_LOG_DIRECTORY}
    Run Keyword If    '${mode}'!='debug'    Run Keyword If Test Failed    VCU Collect Snapshot    ${TEST_LOG_DIRECTORY}
    Run Keyword If    '${mode}'!='debug'    Run Keyword If Test Failed    VDU Collect Snapshot    ${TEST_LOG_DIRECTORY}
    Run Keyword And Ignore Error    Save Egate Log    ${TEST_LOG_DIRECTORY}
    Run Keyword And Ignore Error    ute_wtssim.Teardown Edaemon
    Run Keyword And Ignore Error    ute_wtssim.Teardown Egate
    Run Keyword And Ignore Error    ute_wtssim.Teardown All Aliases For Wts

Common Suite Teardown
    [Arguments]    ${mode}=${EMPTY}
    Run Keyword And Ignore Error    Save Egate Log    ${SUITE_LOG_DIRECTORY}
    Run Keyword And Ignore Error    ute_wtssim.Teardown Edaemon
    Run Keyword And Ignore Error    ute_wtssim.Teardown Egate
    Run Keyword And Ignore Error    ute_wtssim.Teardown All Aliases For Wts
    ute_wtssim.Teardown All Aliases For Wts

Get All Aic Testline Inform And Set Suite Variable
    Get TL Namespace
    Get VCU SW Version
    Get VDU SW Version
    # VCU Get Software Version
    VDU Get Software Version
    Get AP SW Version

Update Iphy Xml And Reboot AP
    [Arguments]    ${iphy_path}
    ${rru_type_list}    Get RRU Type From IPHY XML    ${iphy_path}
    ${targetBD_path}    Get VDU TargetBD File    ${SUITE_LOG_DIRECTORY}
    FOR    ${rru_type}    IN    @{rru_type_list}
        Run Keyword If    '${rru_type}' in ${FDD_RRU_LIST}    Modify RRU Version Of IPHY XML For FDD
        ...    ${rru_type}    ${iphy_path}     ${targetBD_path}
        Run Keyword If    '${rru_type}' in ${TDD_RRU_LIST}    Modify RRU Version Of IPHY XML For TDD
        ...    ${rru_type}    ${iphy_path}     ${targetBD_path}
    END
    Log To Console    --> update iphy.xml done, start reboot AP
    Send IPHY XML To Airphone And Reboot    ${iphy_path}
    Log To Console    --> Waiting For Iphy Reachable
    Sleep    15min    reason=Waiting For Iphy Reachable

Get VDU TargetBD File
    [Arguments]    ${save_dir}
    ${ssh_cmd}    Catenate    SEPARATOR=${SPACE}    sshpass -p ${VDU_K8S_INFO.password} ssh -i ~/.ssh/id_rsa
    ...    ${VDU_K8S_INFO.username}@${VDU_K8S_INFO.ip}
    ${cmd}    Catenate    SEPARATOR=${SPACE}    kubectl exec -it ute-${namespace}-oamfh-0 -c ctr-${namespace}-oamfh
    ...     -n ${namespace} -- ls /ffs/run/RFSW | grep TargetBD
    ${targetbd_filename}=    OperatingSystem.Run    ${ssh_cmd} ${cmd}
    Set Suite Variable    ${targetbd_filename}
    ${cp_cmd}    Catenate    SEPARATOR=${EMPTY}    kubectl cp -c ctr-${namespace}-oamfh ${namespace}/ute-${namespace}-oamfh-0
    ...    :ffs/run/RFSW/${targetbd_filename} /tmp/${targetbd_filename}
    OperatingSystem.Run    ${ssh_cmd} ${cp_cmd}
    ${cp_cmd_2}    Catenate    SEPARATOR=${SPACE}    sshpass -p ${VDU_K8S_INFO.password} scp -i /home/ute/.ssh/id_rsa
    ...    core@${VDU_K8S_INFO.ip}:/tmp/${targetbd_filename} ${save_dir}
    OperatingSystem.Run    ${cp_cmd_2}
    OperatingSystem.Should Exist    ${save_dir}/${targetbd_filename}
    ${targetBD_path}    Set Variable    ${save_dir}/${targetbd_filename}
    [Return]    ${targetBD_path}

Get TL Namespace
    ${cmd_ouput}=    Run    hostname
    ${namespace}=    Convert To Lowercase    string=${cmd_ouput}
    Set Suite Variable    ${namespace}
    Log    TL Namespace: ${namespace}    console=${true}

Get VCU SW Version
    ssh.Connect To    hostname=${VCU_K8S_INFO.ip}    username=${VCU_K8S_INFO.username}
    ...    password=${VCU_K8S_INFO.password}    alias=sshcu
    ${vcu_sw_version_cmd}    _Get SW Version From Cmd    ${NAMESPACE}    aic-vcu-cnf    sshcu
    ${namespace_from_tlconfig}    Set Variable    ${tl.cloud_hostings[0].namespace}
    ${vcu_sw_version_ini}    _Get SW Version From Cmd    ${namespace_from_tlconfig}    aic-vcu-cnf    sshcu
    ${vcu_sw_version}     Set Variable If    '${vcu_sw_version_cmd}'==''    ${vcu_sw_version_ini}    ${vcu_sw_version_cmd}
    Set Suite Variable    ${vcu_sw_version}
    Log    VCU SW Version: ${vcu_sw_version}    console=${true}
    [teardown]    SSH.Disconnect    connection=sshcu

Get VDU SW Version
    ssh.Connect To    hostname=${VDU_K8S_INFO.ip}    username=${VDU_K8S_INFO.username}
    ...    password=${VDU_K8S_INFO.password}    alias=sshdu
    #namespace from hostname command
    ${vdu_sw_version_cmd}    _Get SW Version From Cmd    ${NAMESPACE}    aic-vdu    sshdu
    #namespace from ini file in testline_configuration
    ${namespace_from_tlconfig}    Set Variable    ${tl.cloud_hostings[1].namespace}
    ${vdu_sw_version_ini}    _Get SW Version From Cmd    ${namespace_from_tlconfig}    aic-vdu    sshdu
    ${vdu_sw_version}     Set Variable If    '${vdu_sw_version_cmd}'==''    ${vdu_sw_version_ini}    ${vdu_sw_version_cmd}
    Set Suite Variable    ${VDU_SW_VERSION}
    @{version_list}    Split String    ${VDU_SW_VERSION}    .
    ${BRANCH}    Set Variable If    '${version_list[0]}'=='0'    Trunk    Branch
    Set Suite Variable    ${BRANCH}
    Log    Branch: ${BRANCH}    console=${true}
    Log    VDU SW Version: ${VDU_SW_VERSION}    console=${true}
    [teardown]    SSH.Disconnect    connection=sshdu

_Get SW Version From Cmd
    [Arguments]    ${namespace_value}    ${cnf_tag}    ${connection_alias}
    ${output}    ssh.Execute    command=helm list -n ${namespace_value} -a | grep -v 'NAMESPACE'    connection=${connection_alias}
    ${version_list}    Get Regexp Matches    ${output}    ${cnf_tag}-(?P<version>\\d+.\\d+.\\d+)    version
    ${match_num}    Get Length    ${version_list}
    ${sw_version}    Set Variable If    ${match_num}!=0    ${version_list[0]}    ${EMPTY}
    [Return]    ${sw_version}

Get AP SW Version
    ute_fsmaccess.setup_wts_fsm_access
    get_wts_sw_version
    [teardown]    ute_fsmaccess.teardown_wts_fsm_access


Get RRU Type From IPHY XML
    [Arguments]    ${iphy_path}
    ${content}=    OperatingSystem.Get File    path=${iphy_path}
    ${regexp}    Set Variable    <RE>[\\s\\S]*?<cardName>(?P<RRU_type>\\w+)<\\/cardName>[\\s\\S]*?>\\n\\s+(?=<\\/RE>)
    @{rru_type}    String.Get Regexp Matches    ${content}    ${regexp}    RRU_type
    ${length}=    Get Length    ${rru_type}
    Set Suite Variable    ${length}
    [Return]    @{rru_type}


Modify RRU Version Of IPHY XML For TDD
    [Arguments]    ${rru_type}    ${iphy_path}    ${targetBD_path}
    # Get swFileKey and resourceSWVersion from TargetBD
    ${targetdb_xml}    XML.Parse XML   ${targetBD_path}
    ${rru_elem}    XML.Get Element    ${targetdb_xml}    .//hwResource[contains(@resourceBuildKey,'${rru_type}')]
    Log Element    source=${targetdb_xml}    xpath=.//hwResource[contains(@resourceBuildKey,'${rru_type}')]
    ${swFileKey}=   XML.Get Element Text    ${rru_elem}    swFileKey
    ${resourceSWVersion}=   XML.Get Element    ${rru_elem}    attribute::resourceSWVersion
    Set Suite Variable    ${swFileKey}
    Set Suite Variable    ${resourceSWVersion}
    # Modify Iphy.xml
    ${iphy_xml}    XML.Parse XML    ${iphy_path}
    ${RE_num}    Get Element Count    source=${iphy_xml}    xpath=//RE
    ${RE_num}    Evaluate    ${RE_num}+1
    FOR    ${rru_index}    IN RANGE    1    ${RE_num}
        ${rru_num}    Get Element Count    source=${iphy_xml}    xpath=//RE[${rru_index}]/identity[cardName="${rru_type}"]
        Run keyword If    ${rru_num}==1    Modify Single RRU Version Of IPHY XML For TDD    ${rru_index}    ${rru_type}    ${iphy_xml}
    END
    XML.Save Xml    ${iphy_xml}    ${iphy_path}

Modify Single RRU Version Of IPHY XML For TDD
    [Arguments]    ${rru_index}    ${rru_type}    ${iphy_xml}
    ${bldVersion_xpath}    Set Variable    //RE[${rru_index}]/identity[cardName="${rru_type}"]/bldVersion
    ${buildversion_xpath}    Set Variable    //RE[${rru_index}]/identity[cardName="${rru_type}"]/buildversion
    XML.Set Element Text    source=${iphy_xml}    text=${resourceSWVersion}    xpath=${bldVersion_xpath}
    XML.Set Element Text    source=${iphy_xml}    text=${resourceSWVersion}    xpath=${buildversion_xpath}
    ${vlan_id}    Set Variable    ${tl.ues[0].preferred_vlan_id}
    # ${preferredVlanId_xpath}    Set Variable    //RE[${rru_index}]/identity[cardName="${rru_type}"]/parent::*//preferredVlanId
    # XML.Set Element Text    source=${iphy_xml}    text=${vlan_id}    xpath=${preferredVlanId_xpath}
    ${RE_elem}    XML.Get Element    ${iphy_xml}    //RE[${rru_index}]/identity[cardName="${rru_type}"]/parent::*
    Log Element    source=${iphy_xml}    xpath=//RE[${rru_index}]/identity[cardName="${rru_type}"]/parent::*
    ${xpath}    Set Variable    //RE[${rru_index}]/identity[cardName="${rru_type}"]/parent::*//usageStatus
    ${usageStatus_num}    Get Element Count    source=${RE_elem}    xpath=${xpath}
    ${usageStatus_num}    Evaluate    ${usageStatus_num}+1
    FOR   ${num}    IN RANGE    1    ${usageStatus_num}
        ${xpath}    Set Variable    //RE[${rru_index}]/identity[cardName="${rru_type}"]/parent::*//file[${num}]/usageStatus
        ${name_xpath}    Set Variable    //RE[${rru_index}]/identity[cardName="${rru_type}"]/parent::*//file[${num}]/name
        ${version_xpath}    Set Variable    //RE[${rru_index}]/identity[cardName="${rru_type}"]/parent::*//file[${num}]/version
        ${usageStatus}    XML.Get Element Text    ${iphy_xml}    ${xpath}
        Run Keyword If    '${usageStatus}'=='passive'    XML.Set Element Text    source=${iphy_xml}    text=active
        ...    xpath=${xpath}
        Run Keyword If    '${usageStatus}'=='passive'    XML.Set Element Text    source=${iphy_xml}    text=${swFileKey}
        ...    xpath=${name_xpath}
        Run Keyword If    '${usageStatus}'=='passive'    XML.Set Element Text    source=${iphy_xml}    text=${resourceSWVersion}
        ...    xpath=${version_xpath}
        Run Keyword If    '${usageStatus}'=='active'    XML.Set Element Text    source=${iphy_xml}    text=passive
        ...    xpath=${xpath}
    END

Modify RRU Version Of IPHY XML For FDD
    [Arguments]    ${rru_type}    ${iphy_path}    ${targetBD_path}
    # Get swFileKey and resourceSWVersion from TargetBD
    ${targetdb_xml}    XML.Parse XML   ${targetBD_path}
    ${rru_elem}    XML.Get Element    ${targetdb_xml}    .//hwResource[contains(@resourceBuildKey,'${rru_type}')]
    Log Element    source=${targetdb_xml}    xpath=.//hwResource[contains(@resourceBuildKey,'${rru_type}')]
    ${swFileKey}=   XML.Get Element Text    ${rru_elem}    swFileKey
        @{swFileKey_split}    Split String    ${swFileKey}    _
    ${name}    Catenate    SEPARATOR=_    ${swFileKey_split[2]}    ${swFileKey_split[3]}
    @{split}    Split String    ${swFileKey_split[3]}    .
    ${version}    Set Variable    ${split[0]}
    ${resourceSWVersion}=   XML.Get Element    ${rru_elem}    attribute::resourceSWVersion
    Set Suite Variable    ${name}
    Set Suite Variable    ${version}
    Set Suite Variable    ${resourceSWVersion}
    # Modify Iphy.xml
    ${iphy_xml}    XML.Parse XML    ${iphy_path}
    ${RE_num}    Get Element Count    source=${iphy_xml}    xpath=//RE
    ${RE_num}    Evaluate    ${RE_num}+1
    FOR    ${rru_index}    IN RANGE    1    ${RE_num}
        ${rru_num}    Get Element Count    source=${iphy_xml}    xpath=//RE[${rru_index}]/identity[cardName="${rru_type}"]
        Run keyword If    ${rru_num}==1    Modify Single RRU Version Of IPHY XML For FDD    ${rru_index}    ${rru_type}    ${iphy_xml}
    END
    XML.Save Xml    ${iphy_xml}    ${iphy_path}

Modify Single RRU Version Of IPHY XML For FDD
    [Arguments]    ${rru_index}    ${rru_type}    ${iphy_xml}
    ${bldVersion_xpath}    Set Variable    //RE[${rru_index}]/identity[cardName="${rru_type}"]/bldVersion
    ${buildversion_xpath}    Set Variable    //RE[${rru_index}]/identity[cardName="${rru_type}"]/buildversion
    XML.Set Element Text    source=${iphy_xml}    text=${resourceSWVersion}    xpath=${bldVersion_xpath}
    ${RE_elem}    XML.Get Element    ${iphy_xml}    //RE[${rru_index}]/identity[cardName="${rru_type}"]/parent::*
    Log Element    source=${iphy_xml}    xpath=//RE[${rru_index}]/identity[cardName="${rru_type}"]/parent::*
    ${xpath}    Set Variable    //RE[${rru_index}]/identity[cardName="${rru_type}"]/parent::*//usageStatus
    ${usageStatus_num}    Get Element Count    source=${RE_elem}    xpath=${xpath}
    ${usageStatus_num}    Evaluate    ${usageStatus_num}+1
    FOR   ${num}    IN RANGE    1    ${usageStatus_num}
        ${xpath}    Set Variable    //RE[${rru_index}]/identity[cardName="${rru_type}"]/parent::*//file[${num}]/usageStatus
        ${name_xpath}    Set Variable    //RE[${rru_index}]/identity[cardName="${rru_type}"]/parent::*//file[${num}]/name
        ${version_xpath}    Set Variable    //RE[${rru_index}]/identity[cardName="${rru_type}"]/parent::*//file[${num}]/version
        ${usageStatus}    XML.Get Element Text    ${iphy_xml}    ${xpath}
        Run Keyword If    '${usageStatus}'=='passive'    XML.Set Element Text    source=${iphy_xml}    text=active
        ...    xpath=${xpath}
        Run Keyword If    '${usageStatus}'=='passive'    XML.Set Element Text    source=${iphy_xml}    text=${name}
        ...    xpath=${name_xpath}
        Run Keyword If    '${usageStatus}'=='passive'    XML.Set Element Text    source=${iphy_xml}    text=${version}
        ...    xpath=${version_xpath}
        Run Keyword If    '${usageStatus}'=='active'    XML.Set Element Text    source=${iphy_xml}    text=passive
        ...    xpath=${xpath}
    END

Get IPHY XML From AirPhone
    [Arguments]    ${save_dir}=${TEST_LOG_DIRECTORY}
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.200.129:/ffs/run/simmode/iphy.xml ${save_dir}/iphy.xml
    Should Be Equal As Integers    ${rc}    0
    File Should Exist    ${save_dir}/iphy.xml
    [Return]    ${save_dir}/iphy.xml


Send IPHY XML To Airphone And Reboot
    [Arguments]    ${iphy_path}
    [Documentation]    This keyword is to send target iphy.xml to Airphone /ffs/run/simmode/
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${iphy_path} | Yes | iphy.xml located, eg:/home/ute/iphy.xml |
    ...
    ...    Examples:
    ...    | Send IPHY XML To Airphone | /home/ute/iphy.xml |
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p oZPS0POrRieRtu scp ${iphy_path} toor4nsn@192.168.200.129:/ffs/run/simmode/iphy_modify.xml
    Should Be Equal As Integers    ${rc}    0
    ${soft_link}=    Set Variable    ln -fs /ffs/run/simmode/iphy_modify.xml /ffs/run/simmode/iphy.xml
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.200.129 ${soft_link}
    Should Be Equal As Integers    ${rc}    0
    Process.Start Process
    ...    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.200.129 reboot    shell=True
    Log To Console    --> Reboot AP Start

Reboot Airphone
    Process.Start Process
    ...    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.200.129 reboot    shell=True
    Log To Console    --> Reboot AP Start

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

Get Qc File
    ${path}    ${file}=    OperatingSystem.Split Path    ${SUITE_SOURCE}
    ${ret}    ${output}    OperatingSystem.Run And Return Rc And Output    ls -1 ${path}/*.qc
    ${list_1}=    String.Split To Lines    ${output}
    ${qc_file}=    Set Variable    @{list_1}[0]
    ${content}=    Get File    ${qc_file}
    Log    ${content}

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
    OperatingSystem.Run    sudo ip addr add 10.0.1.137/24 dev eth3

Import Testline Variables
    ${ret}    ${host_name}=    OperatingSystem.Run And Return Rc And Output    hostname|sed 's/-/_/g'
    ${testline_config_path}=    Set Variable    /home/ute/testline_configuration/${host_name}/
    ${ret}=    Run Keyword And Return Status    File Should Exist    ${testline_config_path}/__init__.py
    ${testline_config_path}=    Set Variable If    "${ret}"=="${True}"    ${testline_config_path}
    ...    /home/ute/testline_init_results/configs/${host_name}/
    Log    Testline init file is ${testline_config_path}      console=${True}
    Import Variables    ${testline_config_path}
    ${VCU_INFO_DICT}    Create Dictionary    host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...    port=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.port}
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ${VCU_K8S_INFO_DICT}    Create Dictionary    ip=${tl.cloud_hostings[0].master_node.ssh_connection_details.addr}
    ...    username=${tl.cloud_hostings[0].master_node.ssh_connection_details.username}
    ...    password=${tl.cloud_hostings[0].master_node.ssh_connection_details.password}
    ${VDU_K8S_INFO_DICT}    Create Dictionary    ip=${tl.cloud_hostings[1].master_node.ssh_connection_details.addr}
    ...    username=${tl.cloud_hostings[1].master_node.ssh_connection_details.username}
    ...    password=${tl.cloud_hostings[1].master_node.ssh_connection_details.password}
    Set Suite Variable    ${VCU_INFO}    ${VCU_INFO_DICT}
    Set Suite Variable    ${VCU_K8S_INFO}    ${VCU_K8S_INFO_DICT}
    Set Suite Variable    ${VDU_K8S_INFO}    ${VDU_K8S_INFO_DICT}
    Set Suite Variable    ${VLAN_ID_LIST}    ${tl.gnbs[0].dus[0].fhuc_vlans}