*** Settings ***
Documentation
...   Author: yuyan.xu@nokia-sbell.com
...   Description: This robot cases is for NFTA vDU
...   RAN_ST_CB006092-B_003_CM_Validate Delta Configuration Plan from SMO with shorten DISTNAMEs
Variables       ../TestCases/My_NetAct.py
Resource        ../../Resources/Cloud/AIC_Common_Resource.robot


*** Keywords ***
VRAN_SyVe_CM_CB006092-B_003_Validate_Delta_Configuration_Plan_From_SMO_With_Shorten_DISTNAMEs
    [Documentation]
    ...    Author: yuyan.xu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    11.07.2025, yuyan.xu@nokia-sbell.com
    Step 1: Validate And Provision Delta Plan On NetConf In vDU
    Step 2: Validate Full Plan On NetConf In vDU
    Step 3: Provision Full Plan On NetConf In vDU
    Step 4: Check Site Reset Action And Check CCN Message On vDU



Step ${index}: Validate And Provision Delta Plan On NetConf In vDU
    Log To Console    Step ${index}: Validate And Provision Delta Plan On NetConf In vDU
    @{para_list}    Create List    vesRegistrationEndpointDN
    @{value_list}    Create List    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1/VESENDPOINT-1
    @{mo_list}    Create List    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}
    ${time}    Get Time    epoch
    ${fileName_init}    Set Variable    onap_vDU_${time}.xml
    ${fileName_updated}    Set Variable    onap_vDU_${time}_updated.xml
    ${onap_path}    Transfer SCF DN To Xpath Of ONAP Get Result    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1
    ${cmd_getConfig}    Set Variable
    ...    get-config --source running --filter-xpath ${onap_path}/attributes/vesRegistrationEndpointDN --out=/tmp/${fileName_init}
    ${cmd_validate}    Set Variable
    ...    edit-config --target running --config=/tmp/${fileName_updated} --test test-only --error rollback --rpc-timeout 160s
    ${cmd_editConfig}    Set Variable
    ...    edit-config --target running --config=/tmp/${fileName_updated} --test test-then-set --error rollback --rpc-timeout 160s
    Execute NetConf Command On ONAP Simulator    MRBTS-${vDU_id}    ${host_ip}    ${user}    ${pwd}    ${cmd_getConfig}
    Get File From Simulator To Local    ${host_ip}    ${user}    ${pwd}
    ...    /tmp/${fileName_init}    ${TEST_LOG_DIRECTORY}/${fileName_init}
    ${tmp_value}    Set Variable    VESENDPOINT=1
    ${tmp_dic}    Create Dictionary    vesRegistrationEndpointDN=${tmp_value}
    ${param_dic}    Create Dictionary    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1=${tmp_dic}
    Generate Delta Plan For NetConf    ${param_dic}    ${TEST_LOG_DIRECTORY}/${fileName_init}    ${TEST_LOG_DIRECTORY}/${fileName_updated}
    Put File From Local To Simulator    ${host_ip}    ${user}    ${pwd}
    ...    /tmp/${fileName_updated}    ${TEST_LOG_DIRECTORY}/${fileName_updated}
    ${output}    Execute NetConf Command On ONAP Simulator    MRBTS-${vDU_id}    ${host_ip}    ${user}    ${pwd}    ${cmd_validate}
    Log    ${output}
    ##Should Contain    ${output}    \r\nOK\r\n
    Start VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
	${output}    Execute NetConf Command On ONAP Simulator    MRBTS-${vDU_id}    ${host_ip}    ${user}    ${pwd}    ${cmd_editConfig}
    Log    ${output}
    ##Should Contain    ${output}    \r\nOK\r\n
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
    ${tmp_value}    Set Variable    SubNetwork=${vDU_id},VESENDPOINT=1
    ${tmp_dic}    Create Dictionary    vesRegistrationEndpointDN=${tmp_value}
    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN    ${VES_CCN_msgs}    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1
    ...    vDu    ${vesSourceName}    ${dnPrefix}    ${du_ip}    replace    ${tmp_dic}
    Log    ${target_VES_CCN_msg}
    ##should be true    "${target_VES_CCN_msg.__len__()}">="${1}"


Step ${index}: Validate Full Plan On NetConf In vDU
    Log To Console    Step ${index}: Validate Full Plan On NetConf In vDU
    @{para_list}    Create List    vesRegistrationEndpointDN
    @{value_list}    Create List    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1/VESENDPOINT-1
    @{mo_list}    Create List    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}

    ${time}    Get Time    epoch
    ${fileName_init}    Set Variable    onap_vDU_${time}.xml
    ${fileName_updated}    Set Variable    onap_vDU_${time}_updated.xml
    ${cmd_getConfig}    Set Variable
    ...    get-config --source running --out=/tmp/${fileName_init}
    ${cmd_validate}    Set Variable
    ...    validate --src-config=/tmp/${fileName_updated} --rpc-timeout 300

    ${cmd_copyConfig}    Set Variable
    ...    copy-config --target running --src-config=/tmp/${fileName_updated} --rpc-timeout 300s
    Set Test Variable    ${cmd_copyConfig}
    Execute NetConf Command On ONAP Simulator    MRBTS-${vDU_id}    ${host_ip}    ${user}    ${pwd}    ${cmd_getConfig}
    Get File From Simulator To Local    ${host_ip}    ${user}    ${pwd}
    ...    /tmp/${fileName_init}    ${TEST_LOG_DIRECTORY}/${fileName_init}
	Generate Full Plan For NetConf    ${TEST_LOG_DIRECTORY}/${fileName_init}    ${TEST_LOG_DIRECTORY}/${fileName_updated}
	Put File From Local To Simulator    ${host_ip}    ${user}    ${pwd}
    ...    /tmp/${fileName_updated}    ${TEST_LOG_DIRECTORY}/${fileName_updated}
	${output}    Execute NetConf Command On ONAP Simulator    MRBTS-${vDU_id}    ${host_ip}    ${user}    ${pwd}    ${cmd_validate}
    Log    ${output}
	##Should Contain    ${output}    \r\nOK\r\n

Generate Full Plan For NetConf
    [Arguments]    ${source_file}    ${target_file}
	Log To Console    Generate Full Plan For NetConf
    ${file_content}    OperatingSystem.Get File    ${source_file}
    ${file_content}    Remove String    ${file_content}    <data xmlns="urn:ietf:params:xml:ns:netconf:base:1.0">
    ${file_content}    Remove String    ${file_content}    </data>
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${file_content}
    ${onap_path}    Transfer SCF DN To Xpath Of ONAP Get Result    ${TNL_delete_list[0]}
    #Remove runtime TNL
    FOR    ${TNL}    IN    @{TNL_delete_list}
        ${onap_path}    Transfer SCF DN To Xpath Of ONAP Get Result    ${TNL}
        L_XML.Remove Elements    source=${scf_xml}    xpath=//${onap_path}    remove_tail=True
    END
    ${onap_path}    Transfer SCF DN To Xpath Of ONAP Get Result    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1
    L_XML.Set Element Text    ${scf_xml}    VESENDPOINT=1    \r\n    //${onap_path}/attributes/vesRegistrationEndpointDN
    L_XML.Save Xml    ${scf_xml}    ${target_file}
    ${file_content}    OperatingSystem.Get File    ${target_file}
    ${file_content}    Replace String    ${file_content}    \&\#13;    ${EMPTY}
    ${parsed_xml}    XML.Parse XML    ${file_content}
    XML.Set Element Attribute    ${parsed_xml}    xmlns:nc    urn:ietf:params:xml:ns:netconf:base:1.0    .
    XML.Save Xml    ${parsed_xml}    ${target_file}
    Sleep    10s    time for file creation


Step ${index}: Provision Full Plan On NetConf In vDU
    Log To Console    Step ${index}: Provision Full Plan On NetConf In vDU
    Start VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
	${output}    Execute NetConf Command On ONAP Simulator    MRBTS-${vDU_id}    ${host_ip}    ${user}    ${pwd}    ${cmd_copyConfig}
    Log    ${output}
	##Should Contain    ${output}    \r\nOK\r\n
    Sleep    10s


Step ${index}: Check Site Reset Action And Check CCN Message On vDU
    Log To Console    Step ${index}: Check Site Reset Action And Check CCN Message On vDU
     ${reset_status}    Set Variable
    FOR    ${index}    IN RANGE    0    20
        ${reset_status}    Run Keyword And Return Status    Check IP Is Pingable    ${vDU_oamssh_ip}    expect_pingable=${False}
        Exit For Loop If    ${reset_status}
        Sleep    10s
    END
    Should Be True    ${reset_status}
    Wait Until Keyword Succeeds    10min    30s    vDU Login By Rest
    Wait Until Keyword Succeeds    20min    60s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    Sleep    30s
    ${VES_CCN_msgs}    Stop VES Log Listen On ONAP Simulator    ${host_ip}    ${user}    ${pwd}
    ${tmp_value}    Set Variable    SubNetwork=${vDU_id},VESENDPOINT=1
    ${param_dic}    Create Dictionary    vesRegistrationEndpointDN=${tmp_value}
    ${target_VES_CCN_msg}    Filter VES NotifyMOIChanges CCN    ${VES_CCN_msgs}    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1
    ...    vDu    ${vesSourceName}    ${dnPrefix}    ${du_ip}    add    ${param_dic}
    Log    ${target_VES_CCN_msg}
    ##should be true    "${target_VES_CCN_msg.__len__()}">="${1}"

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
    #Get Runtime TNL object
    ${time}    Get Time    epoch
    ${BTS_Scf_With_Runtime}    vdu.get_current_plan_file    local_dir_path=${TEST_LOG_DIRECTORY}    filename=current_scf_${time}.xml
    ...    include_runtime_data=True    include_auto_config_data=${False}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_content}    L_XML.Parse xml    ${BTS_Scf_With_Runtime}
    #check the parameter - TNLSVC.TNL.templateUsage.
    #If 'TRUE', then the TNL instance (and its subtree) is a template TNL.
    #If 'FALSE' or if the parameter is not configured, then the TNL instance (and its subtree) is runtime TNL configuration.
    #If it runtime TNL, need delete in full plan which will provision
    ${tnl_objects}   L_XML.Get Elements
    ...    ${scf_content}    .//managedObject[@class="com.nokia.srbts.tnl:TNL"]
    ${TNL_delete_list}    Create List
    FOR    ${element}    IN    @{tnl_objects}
        ${templateUsage}    L_XML.Get Element Text    ${element}    .//p[@name="templateUsage"]
        Continue For Loop If    "${templateUsage}"=="TRUE"
        ${dn}    L_XML.Get Element Attribute    ${element}    distName
        Append To List    ${TNL_delete_list}    ${dn}
    END
    Set Test Variable    ${TNL_delete_list}
    Log To Console    ${TNL_delete_list}


Case Postcondition
    Log To Console    Case Postcondition
    Common Test Teardown For AIC
    Teardown NetAct