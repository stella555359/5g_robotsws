*** Settings ***
Documentation     Install NE to NetAct
Library     OperatingSystem
Library    String
Library           XML    True
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/common.robot
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/NetAct_selenium.robot
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/NetAct_swing.robot
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/NetAct_ssh.robot
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GI000114/CaseResource/Integrating_NE_to_NetAct.robot

*** Variables ***
${IP}   ${oam_addr}
${NEIW_NE_Type}   MRBTS
${Adminstration_folder}   //*[@id="calypso-container"]/div[2]/div/a[1]/img
${NEIW_position}   //span[text()='NE Integration Wizard']
${result_xpath}   //*[@id="mainForm:main_table:result"]
${total_xpath}   //*[@id="mainForm:main_table:total_number_ne"]
${main_table_xpath}   //*[@id="mainForm:main_table"]
${file_name}   old_commission.xml
${origin_version}

*** Keywords ***
Integrating NE to NetAct Case Setup
    Set Suite Variable   ${NetAct_info}   ${netact_global_configuration}[${netact_nodeip}]
    Set Suite Variable   ${lab_name}   ${NetAct_info['name']}
    Set Suite Variable   ${MRC_name}   ${LAB_INFO['${lab_name}']['MRC']}
    Set Suite Variable   ${MR_name}   ${LAB_INFO['${lab_name}']['MR']}
    Set Suite Variable   ${MR_NEIW}   MRC-${MRC_name}/MR-${MR_name}
    run keyword and ignore error  selenium_sbts.enable_virtual_display
    IPV6 no proxy setting   ip_addr=${IP}
    UUF Set Global Lab Information    lab_name=${lab_name}
    ${build_version}   set variable  ${origin_version.split(',')[0]}
    ${NE_TYPE}   Get OAM Type From gNB   version=${build_version}
    ${NE_release}   Catch build release   ${build_version}
    ${common_build}   run keyword and return status   should contain   ${NE_release}   SBTS
    ${release}   set variable if   ${common_build}   ${NE_release}   ${NE_release}CLA
    set suite variable  ${release}
    set suite variable  ${NE_TYPE}
    run keyword if  '${NE_TYPE}'=='COAM'   UUF COAM Get Info of WebUI for Integration   file_name=${file_name}
    ...   ELSE   UUF Get Info of WebUI for Integration

Integrating NE to NetAct Case Teardown
    run keyword and ignore error  selenium_sbts.disable_virtual_display

UUF Integrating NE to NetAct
    run keyword and ignore error  UUF Renew Registrations on NE3SWS Network Element
    Open Netact Start Page   url=${START_PAGE}    username=${START_PAGE_USER}    password=${START_PAGE_PASSWORD}    showall=${false}
    Integrate NE via NEIW   DN=${DN}   Adminstration_folder=${Adminstration_folder}   NEIW_position=${NEIW_position}
    ...   NE_Type=${NEIW_NE_Type}   release=${release}   MR=${MR_NEIW}   IP=${IP}
    ...   NE3SWS_IPversion=${NE3SWS_IPversion}   NE3SWS_mode=${NE3SWS_mode}
    sleep   10s
    Run Keyword And Ignore Error    selenium_netact.Logout
    UUF CM Upload in Backend ENV

UUF CM Upload in Backend ENV
    ${upload_command}=   set variable  racclimx.sh -v -op Upload -DN ${DN}
    ${expect_output}=   run keyword if  '${NE_TYPE}'=='COAM'   set variable   The operation was successfully completed.:Upload is Successful
    ...   ELSE   set variable   Operation upload completed successfully
    Connect to NetAct WasNode and execute command   wasNode_IP=${HOST_IP['${WAS_DMGR_HOSTS[0]}']}   omc_uername=${SERVICE_USER}
    ...   omc_passowrd=${SERVICE_PASSWORD}  command=${upload_command}   expect_output=${expect_output}

UUF Renew Registrations on NE3SWS Network Element
    ${renew_Registration_command}=   set variable  racclimx.sh -op NE3S_RenewRegistration -DN ${DN} -v
    Connect to NetAct WasNode and execute command      wasNode_IP=${HOST_IP['${WAS_DMGR_HOSTS[0]}']}
    ...   omc_uername=${SERVICE_USER}   omc_passowrd=${SERVICE_PASSWORD}   command=${renew_Registration_command}

Confirm Double Names
    selenium_netact.Click Button    xpath=//*[@id="confirmCreateCredentialOkButton"]
    FOR    ${i}    IN RANGE    2
        ${status}=   Run Keyword And Return Status   selenium_netact.wait_for_visibility    xpath=//*[@id="createCredentialConfirmationDialogCDiv"]
        Exit For Loop If    '${status}'=='False'
    END
    Run Keyword And Ignore Error    Wait For Loading To Disappear

Set Credentials
    [Arguments]    ${user_name}    ${password}
    run keyword and ignore error  selenium_netact.wait_for_visibility   elem_xpath//*[@id="createPage:attributeLoop:0:AttributeField_Visible"]
    wait until keyword succeeds   16s   5s  selenium_netact.write_value
    ...   input_xpath=//*[@id="createPage:attributeLoop:0:AttributeField_Visible"]   value=${user_name}
    run keyword and ignore error  selenium_netact.wait_for_visibility   elem_xpath//*[@id="createPage:attributeLoop:1:AttributeField_Hidden"]
    wait until keyword succeeds   16s   5s  selenium_netact.write_value
    ...   input_xpath=//*[@id="createPage:attributeLoop:1:AttributeField_Hidden"]   value=${password}
    run keyword and ignore error  selenium_netact.wait_for_visibility   elem_xpath//*[@id="createPage:attributeLoop:1:AttributeField_HiddenRepeat"]
    wait until keyword succeeds   16s   5s  selenium_netact.write_value
    ...   input_xpath=//*[@id="createPage:attributeLoop:1:AttributeField_HiddenRepeat"]   value=${password}

Set Service Type
    [Arguments]    ${service_type}    ${profile}=Default
    Select Value From List in NEVC    index=//*[@id="createPage:ServiceTypeSelect_Create"]    value=${service_type}   list_element_nbr=50
    Sleep    10s
    run keyword if  '${profile}'!='Default'   Select Value From List in NEVC    index=//*[@id="createPage:ProfileSelect_Create"]    value=${profile}

Select Value From List in NEVC
    [Arguments]    ${index}    ${value}   ${list_element_nbr}=10
    FOR   ${i}    IN RANGE    ${list_element_nbr}
        Wait Until Keyword Succeeds   31s   10s   selenium_netact.click_button   ${index}
        Run Keyword And Return Status   Wait Until Keyword Succeeds   31s   10s   selenium_netact.click_button
        ...   button_xpath=${index}/option[${i+1}]
        ${value_act}=   selenium_netact.get_elem_text   elem_xpath=${index}/option[${i+1}]
        ${status}   Run Keyword And Return Status   Should Be Equal   ${value}   ${value_act}
        Exit For Loop If   ${status}
    END
    run keyword if  not ${status}   Fail

Create MRC
    [Arguments]  ${MRC_name}
    Wait Until Keyword Succeeds   31s   10s   swing.Select From Main Menu And Wait    Window|Reload Workspace
    Wait Until Keyword Succeeds   31s   10s   swing.Select From Main Menu And Wait    Tools|Managed Objects|Object Explorer
    sleep  2s
    Wait Until Keyword Succeeds   31s   10s   swing.Select From Main Menu And Wait    File|New|Object...
    sleep  2s
    swing.Select Dialog    New Object
    sleep  2s
    Wait Until Keyword Succeeds   31s   10s   swing.Push Button   Next >
    Wait Until Keyword Succeeds  5s   1s   swing.Click On Component   Instance
    Run Keyword And Ignore Error	Wait Until Keyword Succeeds   5s   1s   swing.Text Field Should Be Enabled   Instance
    Wait Until Keyword Succeeds   5s   1s   swing.Insert Into Text Field   Instance   ${MRC_name}
    ${enabled}=   Run Keyword And Return Status   Wait Until Keyword Succeeds   31s   10s   swing.Button Should Be Enabled   Finish
    Wait Until Keyword Succeeds   31s   10s   swing.Push Button   Finish

Create MR
    [Arguments]  ${MRC_name}   ${MR_name}
    Wait Until Keyword Succeeds   31s   10s   swing.Select From Main Menu And Wait    Window|Reload Workspace
    Wait Until Keyword Succeeds   31s   10s   swing.Select From Main Menu And Wait    Tools|Managed Objects|Object Explorer
    sleep  2s
    Wait Until Keyword Succeeds   31s   10s   swing.Select Tree Node   Objects   MRC-${MRC_name}
    sleep   2s
    Wait Until Keyword Succeeds   31s   10s   swing.Select From Main Menu And Wait    File|New|Object...
    sleep  2s
    swing.Select Dialog    New Object
    ${enabled}=   Run Keyword And Return Status   Wait Until Keyword Succeeds   30s   10s   swing.Button Should Be Enabled   Next >
    ${button_status}=   run keyword if  not ${enabled}   set variable  Button Next > disable
    sleep  2s
    Wait Until Keyword Succeeds   30s   10s   swing.Push Button   Next >
    sleep   2s
    Wait Until Keyword Succeeds  5s   1s   swing.Click On Component   Instance
    sleep   2s
    Run Keyword And Ignore Error	Wait Until Keyword Succeeds   5s   1s   swing.Text Field Should Be Enabled   Instance
    sleep   2s
    Wait Until Keyword Succeeds   5s   1s   swing.Insert Into Text Field   Instance   ${MR_name}
    sleep   2s
    ${enabled}=   Run Keyword And Return Status   Wait Until Keyword Succeeds   31s   10s   swing.Button Should Be Enabled   Finish
    sleep   2s
    Wait Until Keyword Succeeds   31s   10s   swing.Push Button   Finish
    sleep   2s

UUF Check Integration status FP
    [Arguments]   ${DN}
    #filter
    Input Text on NEIW or NEAC    TextField_xpath=//*[@id="mainForm:main_table:rootMOFilterInput"]   Text=${DN}
    ${total_text}=   Wait Until Keyword Succeeds   3 times   5s   selenium_netact.get_elem_text
    ...   elem_xpath=//*[@id="mainForm:main_table:total_number_ne"]
    ${total_text_reg}=   should match regexp  ${total_text}   \\d+
    ${total_nbr}=   BuiltIn.Convert To Integer   ${total_text_reg}
    FOR   ${i}    IN RANGE    ${total_nbr}
        ${status}   ${val}   Run Keyword And Ignore Error   selenium_netact.get_elem_text   elem_xpath=//*[@id="mainForm:main_table:${i}:rootMO"]
        Continue For Loop If   '${status}'=='FAIL'
        ${index}   Set Variable If   '${val}'=='${DN}'   ${i}    #correct number of row.
        Exit For Loop If   '${val}'=='${DN}'
    END
    #wait until status not Ongoing
    Sleep   20s
    Check Integration Status   table_index=${index}
    ${Verification_Status}   run keyword and return status
    ...   selenium_netact.wait_for_visibility   elem_xpath=//*[@id="mainForm:main_table:${index}:verificationStatus"]
    run keyword if  ${Verification_Status}   Check Verification Status   table_index=${index}
    #show details
    Run Keyword And Ignore Error  Wait Until Keyword Succeeds   3 times   5s   selenium_netact.click_button
    ...   button_xpath=//*[@id="mainForm:main_table:${index}:integrationStatus"]
    Run Keyword And Ignore Error  selenium_netact.wait_for_enable   elem_xpath=//*[@id="ShowFullLogLink"]
    #show full log
    Run Keyword And Ignore Error  Wait Until Keyword Succeeds   3 times   5s   selenium_netact.click_button
    ...   button_xpath=//*[@id="ShowFullLogLink"]
    Run Keyword And Ignore Error  selenium_netact.wait_for_visibility   elem_xpath=//*[@id="show_log_form:log_display_body"]
    ${output}    Run Keyword And Ignore Error  Wait Until Keyword Succeeds   3 times   5s   selenium_netact.get_elem_text
    ...   elem_xpath=//*[@id="show_log_form:log_display_body"]

Check Integration Status
    [Arguments]  ${table_index}
    run keyword and ignore error  wait until keyword succeeds  3 times   10s   selenium_netact.click_button
    ...   button_xpath=//span[@class='buttonIcon spanIconforfocus refreshIcon']
    selenium_netact.wait_for_visibility   elem_xpath=//*[@id="mainForm:main_table:${table_index}:integrationStatus"]
    ${status_int}   Wait Until Keyword Succeeds   5 times   5s   selenium_netact.get_elem_text
    ...   elem_xpath=//*[@id="mainForm:main_table:${table_index}:integrationStatus"]
    should be equal  ${status_int}   Completed

Check Verification Status
    [Arguments]  ${table_index}
    run keyword and ignore error  wait until keyword succeeds  3 times   10s   selenium_netact.click_button
    ...   button_xpath=//span[@class='buttonIcon spanIconforfocus refreshIcon']
    selenium_netact.wait_for_visibility   elem_xpath=//*[@id="mainForm:main_table:${table_index}:verificationStatus"]
    ${status_int}   Wait Until Keyword Succeeds   5 times   5s   selenium_netact.get_elem_text
    ...   elem_xpath=//*[@id="mainForm:main_table:${table_index}:verificationStatus"]
    Should Be Equal   ${status_int}   Completed

UUF Delete Configuration
    [Arguments]   ${DN}
    #select
    ${status}    Select One Row With DN   DN=${DN}
    run keyword if  not ${status}   Return From Keyword   False
    #delete
    sleep   5s
    run keyword and ignore error  selenium_netact.wait_for_enable    elem_xpath=//*[@id="deleteNEButton"]
    Wait Until Keyword Succeeds   3 times   5s   selenium_netact.click_button    button_xpath=//*[@id="deleteNEButton"]
    run keyword and ignore error  selenium_netact.wait_for_enable   elem_xpath=//*[@id="mainForm:deleteConfirmButton"]
    ${status}=   Run Keyword And Return Status   Wait Until Keyword Succeeds   3 times   5s   selenium_netact.click_button
    ...    button_xpath=//*[@id="mainForm:deleteConfirmButton"]
    Input Text on NEIW or NEAC    TextField_xpath=//*[@id="mainForm:main_table:rootMOFilterInput"]   Text=${DN}
    FOR    ${i}    IN RANGE    5
        ${num_text}   Wait Until Keyword Succeeds   3 times   5s   selenium_netact.get_elem_text   elem_xpath=//*[@id="mainForm:main_table:result"]
        ${num_text_reg}=   should match regexp  ${num_text}   \\d+
        ${num_nbr}=   BuiltIn.Convert To Integer   ${num_text_reg}
        ${status}    Run Keyword And Return Status    Should Be True    ${num_nbr}==0
        Exit For Loop If    ${status}
    END
    [Return]    ${status}

UUF Set Global Lab Information
    [Arguments]  ${lab_name}=CLAB737
    Set Suite Variable    ${LAB_INFO}    ${LAB_INFO['${lab_name}']}
    ${lab_info_keys} =    Get Dictionary Keys    ${LAB_INFO}
    FOR    ${key_name}   IN    @{lab_info_keys}
       Set Suite Variable   ${${key_name}}   ${LAB_INFO['${key_name}']}
    END

    UUF LogIn NetAct VM And Get Config File FP
    ${Cluster_XML} =   Parse XML    ${OUTPUT_DIR}/ClusterConfig.xml
    ${START_PAGE}   ${HOST_IP}   UUF Get Start Page And HOST From ClusterConfig FP   ${Cluster_XML}
    Set Suite Variable    ${HOST_IP}
    Set Suite Variable    ${START_PAGE}

    ${smanager_XML} =   Parse XML    ${OUTPUT_DIR}/smanagerConf.xml
    UUF Get Node Service From smanagerConf And Set As Global Vars    XML=${smanager_XML}

UUF LogIn NetAct VM And Get Config File FP
    ${alias}   csn.Connect To   hostname=${VM_IP}   username=${SERVICE_USER}   password=${SERVICE_PASSWORD}   alias=NETACT_VM   timeout=10
#    Switch to root From omc
    csn.Download File   remote_path=/etc/ClusterConfig.xml   local_path=${OUTPUT_DIR}/ClusterConfig.xml   connection=${alias}
    csn.Download File   remote_path=/var/opt/cpf/ha/smanagerConf.xml   local_path=${OUTPUT_DIR}/smanagerConf.xml   connection=${alias}
    [Teardown]   run keyword and ignore error  csn.Disconnect   connection=${alias}

UUF Get Start Page And HOST From ClusterConfig FP
    [Arguments]    ${XML}
    ${START_PAGE} =   XML.Get Element Attribute   ${XML}   name=URL   xpath=Services/Provider/Service[@Name='HTTPS']
    &{HOST_IP}   Create Dictionary
    ${hosts_eles} =   XML.Get Elements   ${XML}   xpath=Hosts/Host
    FOR   ${host_ele}   IN   @{hosts_eles}
        Log    ${host_ele}
       ${host_name_text} =   XML.Get Element Attribute   ${host_ele}   name=Hostname   xpath=.
       ${host_ip_text} =   XML.Get Element Attribute   ${host_ele}   name=IP   xpath=.
       Set To Dictionary   ${HOST_IP}   ${host_name_text}=${host_ip_text}
    END
    [Return]   ${START_PAGE}   ${HOST_IP}

UUF COAM Get Info of WebUI for Integration
    [Arguments]   ${file_name}=old_commission.xml
    ${connection}   wait until keyword succeeds  5min   1min   coam.connect_to   bts_host=${WEBUI_ADDR}   name=COAM
    COAM Backup SCF   local_dir=${OUTPUT_DIR}   file_name=${file_name}   connection=COAM
    ${XML}   xml.parse xml   ${OUTPUT_DIR}/${file_name}
    ${distname}   xml.get element attribute   ${XML}   distName    xpath=cmData/managedObject[@class="com.nokia.srbts:MRBTS"]
    ${btsid}   should match regexp   ${distname}   \\d+
    set suite variable  ${MO_NAME}   MRBTS-${bts_id}
    ${oam_tls_status}   xml.get element text   ${XML}   xpath=cmData/managedObject[@class="com.nokia.srbts.mnl:MPLANENW"]/p[@name="oamTls"]
    run keyword if    '${oam_tls_status}'=='off' and '${release}' <= 'SBTS22R2'    Set Suite Variable    ${NE3SWS_mode}    no TLS
    ...    ELSE IF    '${oam_tls_status}'=='off' and '${release}' > 'SBTS22R2'    Set Suite Variable    ${NE3SWS_mode}    Non_TLS
    ...    ELSE    Set Suite Variable    ${NE3SWS_mode}    TLS
    ${status_ip}=    run keyword and return status    should contain    ${oam_addr}    :
    run keyword if    ${status_ip}    Set Suite Variable    ${NE3SWS_IPversion}    IPv6
    ...    ELSE    Set Suite Variable    ${NE3SWS_IPversion}    IPv4
    Set Suite Variable    ${DN}    PLMN-PLMN/${MO_NAME}
    [Teardown]   run keyword and ignore error  coam.teardown   connection=${connection}

UUF Get Info of WebUI for Integration
    wait until keyword succeeds  5mins   10s   selenium_coam.login
    ...   url=https://${WEBUI_ADDR}/login.html    username=${WEBUI_USER}    password=${WEBUI_PASSWORD}
#    ${bts_id}=    selenium_coam.get_text_parameter_value    dist_name=mrbtsid    abbr=mrbtsId
    set suite variable  ${MO_NAME}   MRBTS-${bts_id}
#    ${oam_tls_status}=    selenium_coam.get_list_parameter_value    dist_name=TLS usage    abbr=oamTls
    run keyword if    '${oam_tls_status}'=='off' and '${release}' <= 'SBTS22R2'    Set Suite Variable    ${NE3SWS_mode}    no TLS
    ...    ELSE IF    '${oam_tls_status}'=='off' and '${release}' > 'SBTS22R2'    Set Suite Variable    ${NE3SWS_mode}    Non_TLS
    ...    ELSE    Set Suite Variable    ${NE3SWS_mode}    TLS
    ${status_ip}=    run keyword and return status    should contain    ${oam_addr}    :
    run keyword if    ${status_ip}    Set Suite Variable    ${NE3SWS_IPversion}    IPv6
    ...    ELSE    Set Suite Variable    ${NE3SWS_IPversion}    IPv4
    Set Suite Variable    ${DN}    PLMN-PLMN/${MO_NAME}
    [Teardown]  Run Keyword And Ignore Error    selenium_coam.Logout

UUF Get Node Service From smanagerConf And Set As Global Vars
    [Arguments]    ${XML}
    ${list_param_keys} =    Get Dictionary Keys    ${NODE_SERVICE_LIST}
    FOR    ${item}   IN    @{list_param_keys}
       ${item_eles} =   XML.Get Elements   ${XML}   xpath=Site/Cluster/SubCluster/NativeService[@Name="${NODE_SERVICE_LIST['${item}']}"]
       _UUF_Get_Node_Service_From_Elements   item=${item}   elements=${item_eles}
    END

    ${list_param_rep_keys} =    Get Dictionary Keys    ${NODE_SERVICE_LIST_REP}
    FOR    ${item_rep}   IN    @{list_param_rep_keys}
       ${item_rep_eles} =   XML.Get Elements   ${XML}
       ...   xpath=Site/Cluster/SubCluster/NativeService[contains(@Name, "${NODE_SERVICE_LIST_REP['${item_rep}']}")]
       _UUF_Get_Node_Service_From_Elements   item=${item_rep}   elements=${item_rep_eles}
    END

_UUF_Get_Node_Service_From_Elements
    [Arguments]   ${item}   ${elements}
    @{item_node_list}    Create List
    FOR   ${element}   IN   @{elements}
       ${item_node} =   XML.Get Element Attribute   ${element}   name=Node   xpath=.
       Append To List   ${item_node_list}   ${item_node}
       ${item_node_list}=   Remove Duplicates   ${item_node_list}
    END
    Set Suite Variable   ${${item}}   ${item_node_list}
    [Return]   ${${item}}

De Integrating NE to NetAct qin and gansu
    Open Netact Start Page   url=https://na20lbwas.qin1.srnhz.nsn-rdnet.net
    ...    username=omc    password=Nokia123!    showall=${false}
    De Integrate NE via NEIW   DN=${DN}   Adminstration_folder=${Adminstration_folder}   NEIW_position=${NEIW_position}
    sleep   10s
    Run Keyword And Ignore Error    selenium_netact.Logout
    Open Netact Start Page   url=https://gansulbwas.gansu.srnhz.nsn-rdnet.net
    ...    username=omc    password=Nokia126_    showall=${false}
    De Integrate NE via NEIW   DN=${DN}   Adminstration_folder=${Adminstration_folder}   NEIW_position=${NEIW_position}
    sleep   10s
    Run Keyword And Ignore Error    selenium_netact.Logout

De Integrate NE via NEIW
    [Arguments]  ${DN}   ${Adminstration_folder}   ${NEIW_position}  
    log to console    De Integrate NE via NEIW
    wait until keyword succeeds  5 times   5s   selenium_netact.switch_to_page   page_name=Start Page
    selenium_netact.open_sub_page    category_xpath=${Adminstration_folder}    page_xpath=${NEIW_position}    page_name=NE Integration Wizard
    sleep   10s
    ${status}=   Check if NE or MR in Table   TextField_xpath=//input[@id='mainForm:main_table:rootMOFilterInput']
    ...   Text=${DN}   main_table_xpath=${main_table_xpath}   total_xpath=${total_xpath}   result_xpath=${result_xpath}
    Run Keyword If  '${status}'=='True'   UUF Delete Configuration   DN=${DN}
    sleep   10s
    [Teardown]  run keyword and ignore error  selenium_netact.close_page   page_name=NE Integration Wizard
