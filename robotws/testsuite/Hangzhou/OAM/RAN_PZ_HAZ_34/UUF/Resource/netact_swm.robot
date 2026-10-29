*** Settings ***
Documentation     author: Ruiyu Han
...               contact: ruiyu.han@nokia-sbell.com
...               Upgrade and Rollback UUF case.
Library    taf.ul.selenium.netact    WITH NAME    selenium_netact
Library    taf.gnb.oam.megazone_client    WITH NAME    megazone_client
Library           taf.transport.ssh    WITH NAME    csn
Library          ../../libraries/TestCaseRequirement.py
Library    String
Library    Collections
Library           DateTime
Resource           testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/NetAct_selenium.robot
Resource           testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/NetAct_swing.robot
Variables     mcs_request.py
Variables   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/global_vars.py
Resource      testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/webui_coam.robot
Resource      testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/common.robot
Resource      testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/gnb.robot
Library     OperatingSystem
Library   XML
Library     Process

*** Variables ***
${sm_page}    Software Manager
${gNBcheckbox_xpath}    //*[@id="swmTable_networkView_body"]/div/table/tbody/tr[1]/td[1]/input
${Upload_xpath}   //*[@id="belowTableActions:uploadButton"]
${Progress_xpath}    //*[@id="swmTable_networkView_body"]/div/table/tbody/tr/td[9]/div/span/a/span
${TaskStatus_xpath}    //*[@id="frmTaskDetails:TaskStatus"]
${prgTaskProgress_xpath}    //*[@id="frmTaskDetails:prgTaskProgress"]/div[2]
${activesw_xpath}    //*[@id="swmTable_networkView_body"]/div/table/tbody/tr/td[5]/span
${passivesw_xpath}   //*[@id="swmTable_networkView_body"]/div/table/tbody/tr/td[6]/span
${newtask_xpath}    //*[@id="belowTableActions:btnStartTask"]
${optinput_xpath}    //*[@id="include:createWizardForm:opTreeFilter"]
${provision_xpath}    //*[@id="include:createWizardForm:opTree:0:3::opNodeName"]
${provisionfinish_xpath}   //*[@id="include:createWizardForm:btnFinish"]
${continue_xpath}
...    //*[@id="confirmationForActiveOperationModalForm:confirmationForActiveOperationModalmsgBtnScriptAndActionOk"]
${networkoperationbtsname_xpath}  //*[@id="TView:moName"]
${topdisplay_xpath}  //*[@id="beautifulForm:j_id201"]
${topdisplay_xpath_chen}  //*[@id="beautifulForm:j_id__v_201"]
${networkoperationstatus_xpath}   //*[@id="TView:TTable:0:0:colTasksStatus"]
${filter_xpath}   //*[@id="swmTable_networkView_header"]/table/thead/tr[2]/th[3]/div/input
${motype_xpath}    //*[@id="ccMOTypecomboboxField"]
${configration_xpath}    //*[@id="calypso-container"]/div[2]/div/a[2]/div/span
${addswversion_xpath}    //*[@id="embTreeFrm:cmdLinkImport"]/div/span
${swmupload_xpath}    //*[@id="swmTable_networkView_body"]/div/table/tbody/tr
${errorpage_xpath}    //*[@id="frmTaskDetails:ErrorCode"]
${rootcause_xpath}    //*[@id="frmTaskDetails:ErrorInfo"]
${swmheader_xpath}    //*[@id="swmTable_networkView_header"]/table/thead/tr[1]
${swmbody_xpath}    //*[@id="swmTable_networkView_body"]/div/table/tbody/tr
&{swmupload_dict}
${failedstatus_xpath}    //*[@id="TView:TTable:0:0:taskFailedStatus_linkStyleGrp"]
${Timedoutstatus_xpath}    //*[@id="TView:TTable:0:0:taskTimeoutStatus_linkStyleGrp"]
${Administrater_xpath}    //*[@id="calypso-container"]/div[2]/div/a[1]
${integration_xpath}    //*[@id="calypso-container"]/div[2]/div/a[23]/div/span[2]
${moname_xpath}    //*[@id="mainForm:main_table:presentationNameFilterInput"]
${integrationbutton_xpath}     //*[@id="mainForm:integrate"]
${integrationcontinue_xpath}    //*[@id="mainForm:continueButton"]
${selectitems_xpath}    //*[@id="mainForm:main_table:selectRecordsPerPage:head"]/a/span[2]
${str1_cmd}    if (!document.querySelectorAll('[type="checkbox"]')[1].checked)
${str2_cmd}    {document.querySelectorAll('[type="checkbox"]')[1].click()}
${parent_xpath}    //*[@id="mot:::c"]
${Network_operation_xpath}   //*[@id="n-banner-collapse"]/div[2]/ul/li[2]/a
${MO_name_xpath_operation}   //*[@id="TView:moName"]
${MO_type}   //*[@id="TViewCombo:cccomboboxField"]
${task_type_xpath}   //*[@id="taskTypeFilterId_comboButton_id"]
${task_apply_button}   //*[@id="TView:taskTypeFilterId_apply_button"]
${task_download}   //*[@id="TView:taskTypeFilterId_multicheckbox_id:2"]
${MO_name_content_xpath}   //*[@id="TView:TTable:0:0:colTasksMO"]/span
${netact_active_sw_xpath}   //*[@id="swmTable_networkView_body"]/div/table//tr/td[5]
${netact_passive_sw_xpath}   //*[@id="swmTable_networkView_body"]/div/table//tr/td[7]
${netact_planned_sw_xpath}   //*[@id="swmTable_networkView_body"]/div/table//tr/td[6]
${task_start_time}   //*[@id="frmTaskDetails:StartDate"]
${task_end_time}    //*[@id="frmTaskDetails:pgpTimeContent"]/table/tbody/tr[3]/td[2]
${task_cancel_button}   //*[@id="frmTaskDetails:btnCancel"]
${task_progress}    //*[@id="frmTaskDetails:prgTaskProgress"]
${task_status}   //*[@id="frmTaskDetails:TaskStatus"]
${cancel_ok_button}   //*[@id="frmTaskDetails:cancelTaskConfirmationPanelmsgBtnOk"]

*** Keywords ***
NetAct SWM Upload
    [Documentation]  NetAct Upload opereration.
    log to console    NetAct SWM Upload
    Open Netact Start Page    url=${netact_url}   username=${netact_account}   password=${netact_pwd}   showall=${false}
    selenium_netact.wait_for_visibility    elem_xpath=${configration_xpath}
    Select gNB from Software Manager Operation    btsname=${input_btsname}
    netact_click_button    xpath=${Upload_xpath}
    ${if_chen}    run keyword and return status    should contain any    ${netact_url}    gansu   qin   sui   han    chen
    ${topdisplay}    run keyword if    ${if_chen}    set variable    ${topdisplay_xpath_chen}
    ...    ELSE    set variable    ${topdisplay_xpath}
    netact_click_button    xpath=${topdisplay}
    selenium_netact.wait_for_visibility    elem_xpath=${networkoperationstatus_xpath}
    ${status_content}    wait until keyword succeeds    10min    5s    check network operations status
    run keyword if    '${status_content}' == 'Failed' or '${status_content}' == 'Timed out'
    ...   Collect NetAct error information    status_conetent=${status_content}
    wait until keyword succeeds  2min   20s   selenium_netact.switch_to_network_status
    Sleep   15s
    ${swmupload_dict}    Add SWM Upload Info in Dict
    wait until keyword succeeds  30s   5s   selenium_netact.close_page    page_name=${sm_page}
#    Sleep    10s
    run keyword and ignore error  selenium_netact.logout
    should contain     ${status_content}    Success
    [Return]    ${swmupload_dict}
    [Teardown]    run keyword and ignore error    selenium_netact.logout

Trigger SW Rollback from NetAct
    [Documentation]  NetAct Rollback opereration.
    [Arguments]   ${input_btsname}=${input_btsname}
    ...   ${netact_url}=${netact_url}   ${netact_account}=${netact_account}   ${netact_pwd}=${netact_pwd}
    log to console    NetAct SWM Rollback
    Open Netact Start Page    url=${netact_url}   username=${netact_account}   password=${netact_pwd}   showall=${false}
    sleep    10s
    Select gNB from Software Manager Operation    btsname=${input_btsname}
    Select Operation in Newtask    operation=Rollback
    netact_click_button    xpath=${provisionfinish_xpath}  #click finish button
    sleep    5s
    ${status}    run keyword and return status   netact_click_button   xpath=${continue_xpath}
    run keyword if  not ${status}    wait until keyword succeeds    2min    30s    rollback WA    #click continue button
    selenium_netact.close_page    page_name=${sm_page}
    Sleep    5s
    [Teardown]    run keyword and ignore error    selenium_netact.logout

Select gNB from Software Manager Operation
    [Arguments]    ${btsname}
    selenium_netact.wait_for_visibility    elem_xpath=${configration_xpath}
    selenium_netact.open_configuration_software_manager
    netact_wait_and_write_value    xpath=${motype_xpath}    inputvalue=MRBTS
#    sleep    5s
    netact_select_checkbox    xpath=${parent_xpath}
    netact_wait_and_write_value    xpath=${filter_xpath}    inputvalue=${btsname}
    wait until keyword succeeds     5min    30s    Wait gNB checkbox visibal and click network status page
    sleep    10s
    selenium_netact.execute_script
    ...    script_cmd=document.getElementById("swmTable_networkView_horizontalScroll").style.setProperty("height", "1000px")
    netact_select_checkbox    xpath=${gNBcheckbox_xpath}

Wait gNB checkbox visibal and click network status page
#    run keyword and ignore error  Catch netact Screenshot by xpath    xpath=//body    dir=${OUTPUT_DIR}
    ${visibility_xpath}    run keyword and return status    selenium_netact.wait_for_visibility    elem_xpath=${gNBcheckbox_xpath}
    run keyword if    '${visibility_xpath}' == 'False'    selenium_netact.execute_script    script_cmd=location.reload();
#    sleep    2s
    selenium_netact.wait_for_visibility    elem_xpath=${gNBcheckbox_xpath}

Select Operation in Newtask
    [Arguments]    ${operation}
    netact_click_button    xpath=${newtask_xpath}
    netact_wait_and_write_value    xpath=${optinput_xpath}    inputvalue=${operation}

rollback WA
    selenium_netact.execute_script    script_cmd=location.reload();
    sleep   5s
    Select Operation in Newtask    operation=Rollback
    netact_click_button    xpath=${provisionfinish_xpath}  #click finish button
    sleep   5s
    netact_click_button    xpath=${continue_xpath}

Collect NetAct error information
    [Arguments]     ${status_conetent}
    run keyword if    '${status_conetent}'=='Failed'      netact_click_button    xpath=${failedstatus_xpath}
    ...   ELSE IF    '${status_conetent}'=='Timed out'    netact_click_button    xpath=${Timedoutstatus_xpath}
#    sleep   5s
    selenium_netact.get_elem_text    elem_xpath=${errorpage_xpath}
    selenium_netact.get_elem_text    elem_xpath=${rootcause_xpath}

Add SWM Upload Info in Dict
        ${status}    wait until keyword succeeds    5x    20s
    ...   run keywords    selenium_netact.switch_to_network_status
    ...   AND    sleep    5s
    ...   AND    selenium_netact.wait_for_visibility    elem_xpath=${swmheader_xpath}
#    ${status}    wait until keyword succeeds    5x    20s
#    ...   run keywords    run keyword and ignore error  Catch netact Screenshot by xpath    xpath=//body    dir=${OUTPUT_DIR}
#    ...   AND    selenium_netact.switch_to_network_status
#    ...   AND    sleep    5s
#    ...   AND    selenium_netact.wait_for_visibility    elem_xpath=${swmheader_xpath}
    ${SWMinfoLength}    selenium_netact.execute_script    script_cmd=return arguments[0].childElementCount;     elem_xpath=${swmheader_xpath}
    FOR    ${i}    IN RANGE    3   ${SWMinfoLength}
        ${swmheader_content} =  selenium_netact.get_elem_text    elem_xpath=${swmheader_xpath}/th[${i}]
        ${swmbody_content} =  selenium_netact.get_elem_text    elem_xpath=${swmbody_xpath}/td[${i}]
        Set To Dictionary    ${swmupload_dict}    ${swmheader_content}=${swmbody_content}
    END
    [Return]     ${swmupload_dict}

check network operations status
#    run keyword and ignore error  Catch netact Screenshot by xpath    xpath=//body    dir=${OUTPUT_DIR}
    selenium_netact.execute_script    script_cmd=location.reload();
    ${status_text}    selenium_netact.get_elem_text   elem_xpath=${networkoperationstatus_xpath}
    should contain any    ${status_text}   Success    Failed    Timed out
    [Return]     ${status_text}

Check taget SW package exist in netact server
    [Arguments]    ${version}
    log to console    Check taget SW package exist in netact server
    Open Netact Start Page    url=${netact_url}   username=${netact_account}   password=${netact_pwd}   showall=${false}
    Select gNB from Software Manager Operation    btsname=${input_btsname}
    Select Operation in Newtask    operation=Provision
    ${is_common}   run keyword and return status   should contain   ${version}   SBTS
    ${is_commontrunk}   run keyword and return status   should contain   ${version}   SBTS00
    ${commontrunk_version}   run keyword if   ${is_commontrunk}   Split String    ${version}    _    1
    ${version_name}   run keyword if   ${is_commontrunk}   set variable   ${commonBuild_trunk}_${commontrunk_version}[1]
    ...   ELSE   set variable if   ${is_common}   ${version}   AirScale-${version}
    ${status}    run keyword and return status  selenium_netact.wait_for_visibility
    ...     elem_xpath=//*[@title="Version ID: ${version_name}"]
    run keyword and ignore error   selenium_netact.logout
    run keyword if  '${status}' != 'True'    fail   msg=Target SW package doesn't exist in netact server!
    [Teardown]   run keyword and ignore error    selenium_netact.logout

Change Root User to Omc
    [Arguments]      ${alias}=NetActNode
    ${output}    csn.execute    command=echo $USER    connection=${alias}
    run keyword if   ${output.count('root')}>0
    ...    csn.execute    command=su omc    connection=${alias}

####basic netact operation package####
netact_click_button
    [Arguments]    ${xpath}
    sleep    10s
    ${status}    run keyword and return status    wait until keyword succeeds    3x    10s    selenium_netact.wait_for_enable    elem_xpath=${xpath}
#    wait until keyword succeeds     3x    10s    selenium_netact.wait_for_enable    elem_xpath=${xpath}
    run keyword if  not ${status}    run keywords    Catch netact Screenshot by xpath    xpath=//body    dir=${OUTPUT_DIR}
    ...    AND    FAIL    [ERROR] click button failed!
    wait until keyword succeeds     3x    30s    selenium_netact.click_button    button_xpath=${xpath}

netact_find_and_replace
    [Arguments]    ${xpath_ori}    ${attr_text}    ${replace_ori}    ${replace_dest}
    sleep   5s
    wait until keyword succeeds     3x    10s    selenium_netact.wait_for_visibility    elem_xpath=${xpath_ori}
    ${attr_content}    selenium_netact.execute_script    script_cmd=return arguments[0].parentNode.getAttribute('${attr_text}');
    ...     elem_xpath=${xpath_ori}
    ${attr_content}    run keyword if   '${attr_content}' == 'None'    selenium_netact.execute_script
    ...   script_cmd=return arguments[0].getAttribute('${attr_text}');   elem_xpath=${xpath_ori}
    ...   ELSE    set variable     ${attr_content}
    ${xpath_dest}    Replace String	  ${attr_content} 	${replace_ori}	 ${replace_dest}
    [Return]     ${xpath_dest}

netact_wait_and_write_value
    [Arguments]    ${xpath}    ${inputvalue}
    sleep   5s
    run keyword and ignore error  Catch netact Screenshot by xpath    xpath=//body    dir=${OUTPUT_DIR}
    run keyword and ignore error  wait until keyword succeeds     3x    30s    selenium_netact.wait_for_visibility    elem_xpath=${xpath}
    run keyword and ignore error  Catch netact Screenshot by xpath    xpath=//body    dir=${OUTPUT_DIR}
    wait until keyword succeeds     3x    30s    selenium_netact.write_value_and_enter    input_xpath=${xpath}    value=${inputvalue}

netact_select_checkbox
    [Arguments]    ${xpath}
#    Sleep   10s
    ${status}    run keyword and return status    wait until keyword succeeds
    ...     3x    10s    selenium_netact.wait_for_visibility    elem_xpath=${xpath}
#    run keyword and ignore error  Catch netact Screenshot by xpath    xpath=//body    dir=${OUTPUT_DIR}
#    run keyword unless  ${status}    run keywords    Catch netact Screenshot by xpath    xpath=//body    dir=${OUTPUT_DIR}
#    ...    AND    FAIL    [ERROR] the checkox xpath is not visibal!
    run keyword if  not ${status}    FAIL    [ERROR] the check xpath is not visibal!
    wait until keyword succeeds     30s    5s    selenium_netact.select_checkbox    checkbox_xpath=${xpath}

Catch netact Screenshot by xpath
    [Arguments]   ${xpath}    ${dir}=${OUTPUT_DIR}
    ${curr_data}    DateTime.Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S
    ${mz_lib} =    Get Library Instance    selenium_netact
    ${element} =    Call Method    ${mz_lib._driver}    find_element_by_xpath    ${xpath}
    Call Method    ${element}    screenshot    ${dir}/Screen_${curr_data}.png

Get Netact Release
    [Arguments]  ${host}=${netact_nodeip}   ${username}=${netact_nodeusername}   ${password}=${netact_nodepassword}
    csn.Connect To    hostname=${host}    username=${username}   password=${password}    alias=NetActNode
    Change Root User to Omc    alias=NetActNode
    ${netact_release}    csn.execute   command=cat /etc/netact-release    connection=NetActNode
    set suite variable     ${netact_release}
    [Teardown]   csn.Disconnect   connection=NetActNode

Check Operation Status in NetAct
    [Arguments]  ${operation}   ${input_btsname}=${input_btsname}   ${operation_totality}=${26}
    log to console  Check Operation Status in NetAct
    Open Netact Start Page  url=${netact_url}   username=${netact_account}   password=${netact_pwd}   showall=${false}
#    sleep   10s
    selenium_netact.wait_for_visibility    elem_xpath=${configration_xpath}
    selenium_netact.open_configuration_software_manager
    netact_click_button   xpath=${Network_operation_xpath}
    selenium_netact.wait_for_visibility    elem_xpath=${MO_type}
    netact_wait_and_write_value    xpath=${MO_type}    inputvalue=MRBTS
    netact_click_button   xpath=${task_type_xpath}
    FOR   ${i}    IN RANGE    ${operation_totality}
       ${type}   wait until keyword succeeds  5 times   5s   selenium_netact.get_elem_text
       ...   elem_xpath=//*[@id="TView:taskTypeFilterId_multicheckbox_id"]/tbody/tr[${i}+1]/td/label
       run keyword if  '${type}'=='${SPACE}${operation}'   run keywords  wait until keyword succeeds  5 times   5s   selenium_netact.select_checkbox
       ...   checkbox_xpath=//*[@id="TView:taskTypeFilterId_multicheckbox_id"]/tbody/tr[${i}+1]/td/label
       ...   AND   netact_click_button   xpath=${task_apply_button}
       exit for loop if  '${type}'=='${SPACE}${operation}'
    END
    netact_wait_and_write_value    xpath=${MO_name_xpath_operation}   inputvalue=${input_btsname}
#    sleep   5s
    selenium_netact.wait_for_visibility    elem_xpath=${networkoperationstatus_xpath}
    wait until keyword succeeds  5min   30s   WA for Filter MO   input_btsname=${input_btsname}
    FOR   ${i}    IN RANGE    ${60}
        ${operation_status}   wait until keyword succeeds  5 times   5s   selenium_netact.get_elem_text   elem_xpath=${networkoperationstatus_xpath}
        ${operation_type}   run keyword and return status   should not contain any    ${operation}   Download   Provision   Activation
        exit for loop if  ${operation_type}
        ${status}   run keyword and return status   should not contain    ${operation_status}   %
        ${if_empty}   run keyword and return status   should not be empty   ${operation_status}
        exit for loop if  ${status} and ${if_empty}
        sleep   120s
#        run keyword if   ${i}==${59}    Fail    msg=${operation} is ${operation_status}
    END
#    run keyword if   '${operation_type}'=='False' and '${status}'='False'    Fail    msg=upgrade or rollback failed, &{result}[status]
    [Return]  ${operation_status}
    [Teardown]    run keyword and ignore error    selenium_netact.logout

WA for Filter MO
    [Arguments]   ${input_btsname}=${input_btsname}
    ${MO_name_content}   wait until keyword succeeds  5 times   5s   selenium_netact.get_elem_text   elem_xpath=${MO_name_content_xpath}
    run keyword and ignore error  Catch netact Screenshot by xpath    xpath=//body    dir=${OUTPUT_DIR}
    should be equal  ${MO_name_content}   ${input_btsname}

Netact SWM Precheck or Postcheck
    [Documentation]  NetAct Precheck opereration.
    [Arguments]    ${taget_version}   ${operation}   ${input_btsname}=${input_btsname}
    ...   ${netact_url}=${netact_url}   ${netact_account}=${netact_account}   ${netact_pwd}=${netact_pwd}
    log to console    NetAct SWM Precheck or Postcheck
    ${is_common}   run keyword and return status   should contain   ${taget_version}   SBTS
    ${is_commontrunk}   run keyword and return status   should contain   ${taget_version}   SBTS00
    ${commontrunk_version}   run keyword if   ${is_commontrunk}   Split String    ${taget_version}    _    1
    ${version_name}   run keyword if   ${is_commontrunk}   set variable   ${commonBuild_trunk}_${commontrunk_version}[1]
    ...   ELSE   set variable if   ${is_common}   ${taget_version}   AirScale-${taget_version}
    selenium_netact.enable_virtual_display
    Open Netact Start Page    url=${netact_url}   username=${netact_account}   password=${netact_pwd}   showall=${false}
    sleep    10s
    Select gNB from Software Manager Operation    btsname=${input_btsname}
    Select Operation in Newtask    operation=${operation}
    ${provisionradio_xpath}    netact_find_and_replace    xpath_ori=//*[@title="Version ID: ${version_name}"]   attr_text=id
    ...   replace_ori=swpackName    replace_dest=radioSelectSWPackage_:0
    selenium_netact.select_radio    radio_xpath=//*[@id="${provisionradio_xpath}"]
    netact_click_button    xpath=${provisionfinish_xpath}  #click finish button
    ${if_chen}    run keyword and return status    should contain any    ${netact_url}    gansu   qin   sui   han    chen
    ${topdisplay}    run keyword if    ${if_chen}    set variable    ${topdisplay_xpath_chen}
    ...    ELSE    set variable    ${topdisplay_xpath}
    netact_click_button    xpath=${topdisplay}
    selenium_netact.wait_for_visibility    elem_xpath=${networkoperationstatus_xpath}
    ${status_content}    wait until keyword succeeds    5min    10s    check network operations status
    selenium_netact.close_page    page_name=${sm_page}
    Sleep    10s
    should contain     ${status_content}    Success
    [Teardown]    run keyword and ignore error    selenium_netact.logout

Trigger SW Operation from NetAct
    [Arguments]    ${operation}   ${taget_version}=None   ${input_btsname}=${input_btsname}
    ...   ${netact_url}=${netact_url}   ${netact_account}=${netact_account}   ${netact_pwd}=${netact_pwd}
    log to console    NetAct SWM ${Operation}
    ${is_common}   run keyword and return status   should contain   ${taget_version}   SBTS
    ${is_commontrunk}   run keyword and return status   should contain   ${taget_version}   SBTS00
    ${commontrunk_version}   run keyword if   ${is_commontrunk}   Split String    ${taget_version}    _    1
    ${version_name}   run keyword if   ${is_commontrunk}   set variable   ${commonBuild_trunk}_${commontrunk_version}[1]
    ...   ELSE   set variable if   ${is_common}   ${taget_version}   AirScale-${taget_version}
    Open Netact Start Page    url=${netact_url}   username=${netact_account}   password=${netact_pwd}   showall=${false}
    sleep    10s
    Select gNB from Software Manager Operation    btsname=${input_btsname}
    Select Operation in Newtask    operation=${operation}
    ${provisionradio_xpath}    netact_find_and_replace    xpath_ori=//*[@title="Version ID: ${version_name}"]   attr_text=id
    ...   replace_ori=swpackName    replace_dest=radioSelectSWPackage_:0
    selenium_netact.select_radio    radio_xpath=//*[@id="${provisionradio_xpath}"]
    netact_click_button    xpath=${provisionfinish_xpath}  #click finish button
    sleep    10s
    run keyword if   '${Operation}'=='Provision' or '${Operation}'=='Activation'   netact_click_button    xpath=${continue_xpath}
    selenium_netact.close_page    page_name=${sm_page}
    Sleep    10s
    [Teardown]    run keyword and ignore error    selenium_netact.logout

Get SWM Operation Status in NetAct
    [Arguments]   ${input_btsname}=${input_btsname}
    log to console  Check Operation Process in NetAct
    Open Netact Start Page  url=${netact_url}   username=${netact_account}   password=${netact_pwd}   showall=${false}
    selenium_netact.wait_for_visibility    elem_xpath=${configration_xpath}
    selenium_netact.open_configuration_software_manager
    netact_click_button   xpath=${Network_operation_xpath}
    selenium_netact.wait_for_visibility    elem_xpath=${MO_type}
    netact_wait_and_write_value    xpath=${MO_type}    inputvalue=MRBTS
    netact_click_button   xpath=${task_type_xpath}
    wait until keyword succeeds  5 times   5s   selenium_netact.select_checkbox
    ...   checkbox_xpath=//*[@id="TView:taskTypeFilterId_multicheckbox_id"]/tbody/tr[3]/td/label
    netact_click_button   xpath=${task_apply_button}
    netact_wait_and_write_value    xpath=${MO_name_xpath_operation}   inputvalue=${input_btsname}
    wait until keyword succeeds  5min   30s   WA for Filter MO
    selenium_netact.wait_for_visibility    elem_xpath=${networkoperationstatus_xpath}
    wait until keyword succeeds  5 times   5s   netact_click_button   xpath=${networkoperationstatus_xpath}
    sleep  5s
#Execute rubust operation when download progress over 20% or download duriation  over 5 mins
    FOR   ${i}    IN RANGE    ${50}
#        ${operation_status}   wait until keyword succeeds  5 times   5s   selenium_netact.get_elem_text   elem_xpath=${networkoperationstatus_xpath}
        ${operation_progress_status}   wait until keyword succeeds  5 times   5s   selenium_netact.get_elem_text   elem_xpath=${task_progress}
        ${status}   run keyword and return status   should not contain    ${operation_progress_status}   %
        exit for loop if     ${status}
        ${download_rate}   split string   ${operation_progress_status}   %
        exit for loop if    ${download_rate}[0] > 0
        ${operation_start_time}   wait until keyword succeeds  5 times   5s   selenium_netact.get_elem_text   elem_xpath=${task_start_time}
        ${current_time}    DateTime.Get Current Date
        ${download_progress}    Subtract Date From Date   ${current_time}   ${operation_start_time}
        ${coverted_duration}   convert to string   ${download_progress}
        ${duration}   Split String   ${coverted_duration}   .   1
        exit for loop if    ${duration}[0] > 360
        sleep  30s
    END
    should contain    ${operation_progress_status}   %
    [Return]  ${operation_progress_status}
    [Teardown]    run keyword and ignore error    selenium_netact.logout


Get gNB SW Version From Netact SWM
    log to console    Get gNB SW Version From Netact SWM
    ${upload_result}   NetAct SWM Upload
    ${netct_active}   set variable  ${upload_result}[Active SW ID]
    ${netact_passive}   set variable   ${upload_result}[Passive SW ID]
    ${netact_planned}   set variable   ${upload_result}[Planned SW ID]
    ${netact_active_sw_id}   Check gNB Version is Common Build   ${netct_active}
    ${netact_passive_sw_id}   Check gNB Version is Common Build   ${netact_passive}
    ${netact_planned_sw_id}   Check gNB Version is Common Build   ${netact_planned}
    run keyword and ignore error  selenium_netact.logout
    [Return]    ${netact_active_sw_id}   ${netact_passive_sw_id}   ${netact_planned_sw_id}
    [Teardown]    run keyword and ignore error    selenium_netact.logout

Get Netact SWM Operation Duration
    log to console  Check Operation Status in NetAct
    Open Netact Start Page  url=${netact_url}   username=${netact_account}   password=${netact_pwd}   showall=${false}
    selenium_netact.wait_for_visibility    elem_xpath=${configration_xpath}
    selenium_netact.open_configuration_software_manager
    selenium_netact.switch_to_network_operations
    sleep  10s
    selenium_netact.wait_for_visibility    elem_xpath=${MO_type}
    netact_wait_and_write_value    xpath=${MO_type}    inputvalue=MRBTS
    netact_click_button   xpath=${task_type_xpath}
    wait until keyword succeeds  5 times   5s   selenium_netact.select_checkbox
    ...   checkbox_xpath=//*[@id="TView:taskTypeFilterId_multicheckbox_id"]/tbody/tr[3]/td/label
    netact_click_button   xpath=${task_apply_button}
    netact_wait_and_write_value    xpath=${MO_name_xpath_operation}   inputvalue=${input_btsname}
    wait until keyword succeeds  2min   30s   WA for Filter MO
    wait until keyword succeeds  5 times   5s   netact_click_button   xpath=${networkoperationstatus_xpath}
    sleep  5s
    ${operation_start_time}   wait until keyword succeeds  5 times   5s   selenium_netact.get_elem_text   elem_xpath=${task_start_time}
    ${operation_end_time}   wait until keyword succeeds  5 times   5s   selenium_netact.get_elem_text   elem_xpath=${task_end_time}
    ${download_duration}    Subtract Date From Date   ${operation_end_time}   ${operation_start_time}
    ${coverted_duration}   convert to string   ${download_duration}
    [Return]  ${coverted_duration}
    [Teardown]    run keyword and ignore error    selenium_netact.logout

Check If SWM Operation Finished afer Interrupt
    [Arguments]  ${operation}=Timed out
    log to console  Check If SWM Operation Finished afer Interrupt
    Open Netact Start Page  url=${netact_url}   username=${netact_account}   password=${netact_pwd}   showall=${false}
    selenium_netact.wait_for_visibility    elem_xpath=${configration_xpath}
    selenium_netact.open_configuration_software_manager
    selenium_netact.switch_to_network_operations
    sleep  10s
    selenium_netact.wait_for_visibility    elem_xpath=${MO_type}
    netact_wait_and_write_value    xpath=${MO_type}    inputvalue=MRBTS
    netact_click_button   xpath=${task_type_xpath}
    wait until keyword succeeds  5 times   5s   selenium_netact.select_checkbox
    ...   checkbox_xpath=//*[@id="TView:taskTypeFilterId_multicheckbox_id"]/tbody/tr[3]/td/label
    netact_click_button   xpath=${task_apply_button}
    netact_wait_and_write_value    xpath=${MO_name_xpath_operation}   inputvalue=${input_btsname}
    wait until keyword succeeds  2min   30s   WA for Filter MO
    wait until keyword succeeds  5 times   5s   netact_click_button   xpath=${networkoperationstatus_xpath}
    sleep  5s
    FOR   ${i}    IN RANGE    ${20}
        ${operation_status}   wait until keyword succeeds  5 times   5s   selenium_netact.get_elem_text   elem_xpath=${task_status}
        ${status}   run keyword and return status   should contain    ${operation_status}   ${operation}
        ${if_success}   run keyword and return status   should contain    ${operation_status}   Success
        exit for loop if   ${if_success}
        exit for loop if   ${status}
        sleep  30s
    END
    should contain    ${operation_status}   ${operation}
    [Return]  ${operation_status}
    [Teardown]    run keyword and ignore error    selenium_netact.logout

Check gNB SW Version After Unexpected Interrupt
    ${netct_active}  ${netact_passive}  ${netact_planned}   Get gNB SW Version From Netact SWM
    ${webem_active}  ${webem_passive}   ${webem_planned}   WebEM Get SW version
    ${if_webem_passive_empty}   run keyword and return status   should be equal   ${webem_passive}   -
    ${webem_passive_asik}   set variable if   ${if_webem_passive_empty}   ${EMPTY}   ${webem_passive}
    should be equal   ${netct_active}   ${webem_active}
    should be equal   ${netact_passive}   ${webem_passive_asik}
    should be equal   ${webem_planned}   -
    should be empty   ${netact_planned}

Cancel Netact SW Download
    log to console  Cancel Netact SW download
    Open Netact Start Page  url=${netact_url}   username=${netact_account}   password=${netact_pwd}   showall=${false}
    selenium_netact.wait_for_visibility    elem_xpath=${configration_xpath}
    selenium_netact.open_configuration_software_manager
    selenium_netact.switch_to_network_operations
    sleep  10s
    selenium_netact.wait_for_visibility    elem_xpath=${MO_type}
    netact_wait_and_write_value    xpath=${MO_type}    inputvalue=MRBTS
    netact_click_button   xpath=${task_type_xpath}
    wait until keyword succeeds  5 times   5s   selenium_netact.select_checkbox
    ...   checkbox_xpath=//*[@id="TView:taskTypeFilterId_multicheckbox_id"]/tbody/tr[3]/td/label
    netact_click_button   xpath=${task_apply_button}
    netact_wait_and_write_value    xpath=${MO_name_xpath_operation}   inputvalue=${input_btsname}
    wait until keyword succeeds  2min   30s   WA for Filter MO
    wait until keyword succeeds  5 times   5s   netact_click_button   xpath=${networkoperationstatus_xpath}
    sleep  5s
    wait until keyword succeeds  5 times   5s   netact_click_button   xpath=${task_cancel_button}   #click cancel
    wait until keyword succeeds  5 times   5s   netact_click_button   xpath=${cancel_ok_button}   #confirm cancel
    run keyword and ignore error    selenium_netact.logout
    Check If SWM Operation Finished afer Interrupt   operation=Canceled

NetAct SW Provision
    [Arguments]   ${input_btsname}=${input_btsname}   ${upgrade_version}=${upgrade_version}
    wait until keyword succeeds   3 times   5min   Trigger SW Operation from NetAct   operation=Download   taget_version=${upgrade_version}
    ...   input_btsname=${input_btsname}
    NetAct Operation Should Be Success   action=Download   input_btsname=${input_btsname}
    wait until keyword succeeds   3 times   5min   Trigger SW Operation from NetAct   operation=Activation   taget_version=${upgrade_version}
    ...   input_btsname=${input_btsname}
    NetAct Operation Should Be Success   action=Activation   input_btsname=${input_btsname}

NetAct Operation Should Be Success
    [Arguments]   ${action}   ${input_btsname}=${input_btsname}
    FOR   ${index}   IN RANGE   ${60}
        ${operation_status}   Check Operation Status in NetAct   operation=${action}   input_btsname=${input_btsname}
        Exit For Loop If   ${operation_status.count("%")} == 0
    END
    should contain any    ${operation_status}   Successful    Timeout-Success
    [Return]   ${operation_status}

NetAct SW Rollback
    [Arguments]   ${input_btsname}=${input_btsname}
    Trigger SW Rollback from NetAct   input_btsname=${input_btsname}
    NetAct Operation Should Be Success   action=Rollback   input_btsname=${input_btsname}
