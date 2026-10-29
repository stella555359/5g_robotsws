*** Settings ***
Documentation
...   Author: yuyan.xu@nokia-sbell.com
...   Description: This robot cases is for RAN_ST_CB006092-B_021_CM_Full commission from SMO in vCU
Variables       ../TestCases/My_NetAct.py
Resource        ../../Resources/Cloud/AIC_Common_Resource.robot

*** Keywords ***
VRAN_SyVe_CM_CB006092-B_021_Full_Commission_From_SMO_In_vCU
    [Documentation]
    ...    Author: yuyan.xu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    09.07.2025, yuyan.xu@nokia-sbell.com
    Step 1: Validate Full Plan On NetConf In vCU
    FOR    ${index}    IN RANGE    1    6
        Log To Console    Repeat Time:${index}
        Step 2: Provision Full Plan On NetConf In vCU
        Step 3: Check Site Reset Action On vCU
        Step 4: Check Alarms On vCU
    END

Step ${index}: Check Alarms On vCU
    Log To Console    Step ${index}: Check Alarms On vCU
    Login To vCU By Rest
    ${active_alarm}    cu.get_active_alarms    page_number=${1}    items_per_page=${1000}
    ${alarms}    Set Variable   ${active_alarm["alarms"]}
    ${faults_case}    Create List   6500    6501    6502
    ${faults_raised_active}    Create List
    FOR    ${alarm}    IN    @{alarms}
        ${contain}    Run Keyword And Return Status    List Should Contain Value   ${case_faults}    ${alarm["fault_id"]}
        Run Keyword If    ${contain}    Append To List    ${faults_raised_active}    ${alarm["fault_id"]}
    END
    ${historical_alarm}=    cu.get_historical_alarms    page_number=${1}    items_per_page=${1000}
    ${alarms}    Set Variable   ${historical_alarm["alarms"]}
    ${faults_raised_historical}    Create List
    FOR    ${alarm}    IN    @{alarms}
        ${contain}    Run Keyword And Return Status    List Should Contain Value   ${case_faults}    ${alarm["fault_id"]}
        Run Keyword If    ${contain}    Append To List    ${faults_raised_historical}    ${alarm["fault_id"]}
    END
    Log    ${faults_raised_active}
    Log    ${faults_raised_historical}
    Should Be Empty    ${faults_raised_active}
    Should Be Empty    ${faults_raised_historical}

Step ${index}: Validate Full Plan On NetConf In vCU
    Log To Console    Step ${index}: Validate Full Plan On NetConf In vCU
    ${time}    Get Time    epoch
    ${fileName_init}    Set Variable    onap_vCU_${time}.xml
    ${fileName_updated}    Set Variable    onap_vCU_${time}_updated.xml
    ${cmd_getConfig}    Set Variable
    ...    get-config --source running --out=/tmp/${fileName_init}
    ${cmd_validate}    Set Variable
    ...    validate --src-config=/tmp/${fileName_updated} --rpc-timeout 300

    ${cmd_copyConfig}    Set Variable
    ...    copy-config --target running --src-config=/tmp/${fileName_updated} --rpc-timeout 300s
    Set Test Variable    ${cmd_copyConfig}
    ${output}    Execute NetConf Command On ONAP Simulator    MRBTS-${vCU_id}    ${host_ip}    ${user}    ${pwd}    ${cmd_getConfig}
    Get File From Simulator To Local    ${host_ip}    ${user}    ${pwd}
    ...    /tmp/${fileName_init}    ${TEST_LOG_DIRECTORY}/${fileName_init}
	Generate Full Plan For NetConf    ${TEST_LOG_DIRECTORY}/${fileName_init}    ${TEST_LOG_DIRECTORY}/${fileName_updated}
	Put File From Local To Simulator    ${host_ip}    ${user}    ${pwd}
    ...    /tmp/${fileName_updated}    ${TEST_LOG_DIRECTORY}/${fileName_updated}
    ${start_time}    Get Time
	${output}    Execute NetConf Command On ONAP Simulator    MRBTS-${vCU_id}    ${host_ip}    ${user}    ${pwd}    ${cmd_validate}
	${end_time}    Get Time
    ${time}    Subtract Date From Date    ${end_time}    ${start_time}
    Should Be True    ${time}<660
    Log    ${output}
	Should Contain    ${output}    \r\nOK\r\n

Generate Full Plan For NetConf
    [Arguments]    ${source_file}    ${target_file}
	Log To Console    Generate Full Plan For NetConf
    ${file_content}    OperatingSystem.Get File    ${source_file}
    ${file_content}    Remove String    ${file_content}    <data xmlns="urn:ietf:params:xml:ns:netconf:base:1.0">
    ${file_content}    Remove String    ${file_content}    </data>
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${file_content}
    #Remove runtime TNL
    FOR    ${TNL}    IN    @{TNL_delete_list}
        ${onap_path}    Transfer SCF DN To Xpath Of ONAP Get Result    ${TNL}
        L_XML.Remove Elements    source=${scf_xml}    xpath=//${onap_path}    remove_tail=True
    END
    L_XML.Save Xml    ${scf_xml}    ${target_file}
    ${file_content}    OperatingSystem.Get File    ${target_file}
    ${file_content}    Replace String    ${file_content}    \&\#13;    ${EMPTY}
    ${parsed_xml}    XML.Parse XML    ${file_content}
    XML.Set Element Attribute    ${parsed_xml}    xmlns:nc    urn:ietf:params:xml:ns:netconf:base:1.0    .
    XML.Save Xml    ${parsed_xml}    ${target_file}
    Sleep    10s    time for file creation

Step ${index}: Provision Full Plan On NetConf In vCU
    Log To Console    Step ${index}: Provision Full Plan On NetConf In vCU
	${start_time}    Get Time
	${output}    Execute NetConf Command On ONAP Simulator    MRBTS-${vCU_id}    ${host_ip}    ${user}    ${pwd}    ${cmd_copyConfig}
	${end_time}    Get Time
    ${time}    Subtract Date From Date    ${end_time}    ${start_time}
    Should Be True    ${time}<660
    Log    ${output}
	Should Contain    ${output}    \r\nOK\r\n

Step ${index}: Check Site Reset Action On vCU
    Log To Console    Step ${index}: Check Site Reset Action On vCU
     ${reset_status}    Set Variable
    FOR    ${index}    IN RANGE    0    20
        ${reset_status}    Run Keyword And Return Status    Check IP Is Pingable    ${vCU_oamssh_ip}    expect_pingable=${False}
        Exit For Loop If    ${reset_status}
        Sleep    10s
    END
    Should Be True    ${reset_status}
    Wait Until Keyword Succeeds    10min    30s    Login To vCU By Rest
    Wait Until Keyword Succeeds    20min    60s    Check All Cells On Air In vCU    gnb_index=0
    Sleep    30s


Case Precondition
    [Arguments]    ${ReIntegrate_vCU}=False    ${ReIntegrate_vDU}=False
    Log To Console    Case Precondition
    Log    ${ReIntegrate_vDU}
    Common Test Setup For AIC
    Setup NetAct    ${NETACT}
    #ReIntegrate NE
    Run Keyword If    ${ReIntegrate_vCU}    Wait Until Keyword Succeeds    2x    15s
    ...    Integrate NE To NetAct    ${cu_ip}    PLMN-PLMN/MRBTS-${vCU_id}    ${du_release}    ${du_mr}
    #need develop kw
    #Run Keyword If    ${Integrate_Need}    Integrate SBTS To ONAP Simulator    ${MRBTS_ID}    ${ONAP['host_ip']}
    Set Test Variable    ${host_ip}    ${ONAP["host_ip"]}
    Set Test Variable    ${user}    ${ONAP["user"]}
    Set Test Variable    ${pwd}    ${ONAP["pwd"]}
    #Get Runtime TNL object
    Login To vCU By Rest
    ${time}    Get Time    epoch
    ${BTS_Scf_With_Runtime}    cu.get_current_plan_file    path=${TEST_LOG_DIRECTORY}/current_scf_${time}.xml    include_runtime_data=True
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