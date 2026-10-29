*** Settings ***
Documentation
...   Author: yuyan.xu@nokia-sbell.com
...   Description: This robot cases is for NFTA vDU
...   RAN_ST_CB006092-B_004_CM_Validate Delta Configuration Plan from SMO with validation scope setting
Variables       ../TestCases/My_NetAct.py
Resource        ../../Resources/Cloud/AIC_Common_Resource.robot


*** Keywords ***
VRAN_SyVe_CM_CB006092-B_004_Validate_Delta_Configuration_Plan_From_SMO_With_Validation_Scope_Setting
    [Documentation]
    ...    Author: yuyan.xu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    11.07.2025, yuyan.xu@nokia-sbell.com
    Step 1: Validate Delta Plan With Delta Check Success On NetConf In vDU
    Step 2: Validate Delta Plan With Delta Check Failed On NetConf In vDU

Step ${index}: Validate Delta Plan With Delta Check Success On NetConf In vDU
    Log To Console    Step ${index}: Validate Delta Plan With Delta Check Success On NetConf In vDU
    ${time}    Get Time    epoch
    ${fileName_init}    Set Variable    onap_vDU_${time}.xml
    ${fileName_updated}    Set Variable    onap_vDU_${time}_updated.xml
    ${MNL_onap_path}    Transfer SCF DN To Xpath Of ONAP Get Result    MRBTS-${vDU_id}/MNL-1
    ${MPLANEONAP_onap_path}    Transfer SCF DN To Xpath Of ONAP Get Result    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1
    ${filter_str}    Set Variable   ${MNL_onap_path}/attributes/validationScope|${MPLANEONAP_onap_path}/attributes/activateSendingFmEvents
    ${cmd_getConfig}    Set Variable
    ...    get-config --source running --filter-xpath ${filter_str} --out=/tmp/${fileName_init}
    ${cmd_validate}    Set Variable
    ...    edit-config --target running --config=/tmp/${fileName_updated} --test test-only --error rollback --rpc-timeout 160s
    ${output}    Execute NetConf Command On ONAP Simulator    MRBTS-${vDU_id}    ${host_ip}    ${user}    ${pwd}    ${cmd_getConfig}
    Log    ${output}
    Get File From Simulator To Local    ${host_ip}    ${user}    ${pwd}
    ...    /tmp/${fileName_init}    ${TEST_LOG_DIRECTORY}/${fileName_init}
    ${param_dic1}    Create Dictionary    validationScope=Delta Check
    ${tmp_dic}    Create Dictionary    activateSendingFmEvents=false
    ${param_dic2}    Create Dictionary    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1=${tmp_dic}
    Generate Delta Plan For NetConf    ${param_dic2}    ${TEST_LOG_DIRECTORY}/${fileName_init}    ${TEST_LOG_DIRECTORY}/${fileName_updated}
    Generate Delta Plan For NetConf Case    ${TEST_LOG_DIRECTORY}/${fileName_updated}    ${TEST_LOG_DIRECTORY}/${fileName_updated}
    Put File From Local To Simulator    ${host_ip}    ${user}    ${pwd}
    ...    /tmp/${fileName_updated}    ${TEST_LOG_DIRECTORY}/${fileName_updated}
    Start VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
	${output}    Execute NetConf Command On ONAP Simulator    MRBTS-${vDU_id}    ${host_ip}    ${user}    ${pwd}    ${cmd_validate}
    Log    ${output}
    ##Should Contain    ${output}    \r\nOK\r\n
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
    Log    ${VES_CCN_msgs}

Generate Delta Plan For NetConf Case
    [Arguments]    ${source_file}    ${target_file}
	Log To Console    Generate Delta Plan For NetConf Case
    ${file_content}    OperatingSystem.Get File    ${source_file}
    ${file_content}    Remove String    ${file_content}    <data xmlns="urn:ietf:params:xml:ns:netconf:base:1.0">
    ${file_content}    Remove String    ${file_content}    </data>
    ${scf_xml}    L_XML.Parse xml    ${file_content}
    Run Keyword And Ignore Error    L_XML.Remove Elements    source=${scf_xml}    xpath=//validationScope    remove_tail=True
    L_XML.Add Element    ${scf_xml}    <attributes/>    xpath=//MNL
    L_XML.Add Element    ${scf_xml}    <validationScope>Delta Check</validationScope>    xpath=//MNL/attributes
    L_XML.Save Xml    ${scf_xml}    ${target_file}
    ${file_content}    OperatingSystem.Get File    ${target_file}
    ${file_content}    Replace String    ${file_content}    \&\#13;    ${EMPTY}
    ${parsed_xml}    XML.Parse XML    ${file_content}
    XML.Set Element Attribute    ${parsed_xml}    xmlns:nc    urn:ietf:params:xml:ns:netconf:base:1.0    .
    XML.Save Xml    ${parsed_xml}    ${target_file}
    Sleep    10s    time for file creation

Step ${index}: Validate Delta Plan With Delta Check Failed On NetConf In vDU
    Log To Console    Step ${index}: Validate Delta Plan With Delta Check Failed On NetConf In vDU
    ${time}    Get Time    epoch
    ${fileName_init}    Set Variable    onap_vDU_${time}.xml
    ${fileName_updated}    Set Variable    onap_vDU_${time}_updated.xml
    ${MNL_onap_path}    Transfer SCF DN To Xpath Of ONAP Get Result    MRBTS-${vDU_id}/MNL-1
    ${MPLANEONAP_onap_path}    Transfer SCF DN To Xpath Of ONAP Get Result    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1
    ${filter_str}    Set Variable   ${MNL_onap_path}/attributes/validationScope|${MPLANEONAP_onap_path}/attributes/activateOranO1NetconfService
    ${cmd_getConfig}    Set Variable
    ...    get-config --source running --filter-xpath ${filter_str} --out=/tmp/${fileName_init}
    ${cmd_validate}    Set Variable
    ...    edit-config --target running --config=/tmp/${fileName_updated} --test test-only --error rollback --rpc-timeout 160s
    ${output}    Execute NetConf Command On ONAP Simulator    MRBTS-${vDU_id}    ${host_ip}    ${user}    ${pwd}    ${cmd_getConfig}
    Log    ${output}
    Get File From Simulator To Local    ${host_ip}    ${user}    ${pwd}
    ...    /tmp/${fileName_init}    ${TEST_LOG_DIRECTORY}/${fileName_init}
    ${param_dic1}    Create Dictionary    validationScope=Delta Check
    ${tmp_dic}    Create Dictionary    activateOranO1NetconfService=false
    ${param_dic2}    Create Dictionary    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1=${tmp_dic}
    Generate Delta Plan For NetConf Case    ${TEST_LOG_DIRECTORY}/${fileName_init}    ${TEST_LOG_DIRECTORY}/${fileName_updated}
    Generate Delta Plan For NetConf    ${param_dic2}    ${TEST_LOG_DIRECTORY}/${fileName_updated}    ${TEST_LOG_DIRECTORY}/${fileName_updated}
    Put File From Local To Simulator    ${host_ip}    ${user}    ${pwd}
    ...    /tmp/${fileName_updated}    ${TEST_LOG_DIRECTORY}/${fileName_updated}
    Start VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
	${output}    Execute NetConf Command On ONAP Simulator    MRBTS-${vDU_id}    ${host_ip}    ${user}    ${pwd}    ${cmd_validate}
    Log    ${output}
    ##Should Not Contain    ${output}    \r\nOK\r\n
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
    Log    ${VES_CCN_msgs}


Case Precondition
    [Arguments]    ${ReIntegrate_vCU}=False    ${ReIntegrate_vDU}=False
    Log To Console    Case Precondition
    Log    ${ReIntegrate_vCU}
    Common Test Setup For AIC
    Setup NetAct    ${NETACT}
    #ReIntegrate NE
    Run Keyword If    ${ReIntegrate_vDU}    Wait Until Keyword Succeeds    2x    15s
    ...    Integrate NE To NetAct    ${du_ip}    PLMN-PLMN/MRBTS-${vDU_id}    ${du_release}    ${du_mr}
    #need develop kw
    #Run Keyword If    ${Integrate_Need}    Integrate SBTS To ONAP Simulator    ${MRBTS_ID}    ${ONAP['host_ip']}
    Set Test Variable    ${host_ip}    ${ONAP["host_ip"]}
    Set Test Variable    ${user}    ${ONAP["user"]}
    Set Test Variable    ${pwd}    ${ONAP["pwd"]}
    vDU Login By Rest
    ${vesSourceName}    Get Parameter Value From vDU     MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1    vesSourceName
    Set Test Variable    ${vesSourceName}
    ${dnPrefix}    Get Parameter Value From vDU     MRBTS-${vDU_id}    dnPrefix
    Set Test Variable    ${dnPrefix}



Case Postcondition
    Log To Console    Case Postcondition
    Common Test Teardown For AIC
    Teardown NetAct