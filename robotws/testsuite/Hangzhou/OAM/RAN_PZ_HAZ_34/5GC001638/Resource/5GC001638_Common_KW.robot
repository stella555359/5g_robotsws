*** Settings ***
Documentation    Global Resource file used for All Feature 5GC001638-VA cases
Library    OperatingSystem
Library    taf.ul.selenium.netact    WITH NAME    netact
Library    taf.ul.swing.core    WITH NAME    swing
Library    RemoteSwingLibrary    WITH NAME    RSL
Library    String
Library    taf.transport.ssh    WITH NAME    csn
Library    ${CURDIR}/../../libraries/get_bts_info.py    WITH NAME     getBTSInfo
Resource   ${CURDIR}/../../common/coam_resource.robot
Resource   ${CURDIR}/../../common/NetAct_swing.robot

*** Variables ***
${MO_Type_xpath}         //*[@id="ccMOTypecomboboxField"]
${View_xpath}            //*[@id="TreeViewcomboboxField"]
${Parent_xpath}          //input[@id="mot:::c"]
${MO_DN_xpath}           //table[@class='table table-bordered table-header']//input[@class='filter-input']
${MO_name_xpath}           //*[@id="swmTable_networkView_header"]/table/thead/tr[2]/th[4]/div/input
${Radio_Select_box}       //*[@id="swmTable_networkView_header"]/table/thead/tr[2]/th[1]/span/div[1]/input
${Upload_xpath}          //*[@id="belowTableActions:uploadButton"]
${Upload_status_xpath}   //*[@id="swmTable_networkView_body"]//td[@class='columnLastSoftwareTaskNS']//img[contains(@src, 'webuif/icons')]
#${Upload_status_xpath}    //*[@id="swmTable_networkView_body"]/div/table/tbody/tr/td[8]/div/span/a/img
${Active_Info_xpath}     //table[@class='table table-bordered table-body']//td[@class='columnActiveSwIdNS']
${Passive_Info_xpath}    //table[@class='table table-bordered table-body']//td[@class='columnPassiveSwIdNS']
${Planned_Info_xpath}    //table[@class='table table-bordered table-body']//td[@class='columnPlannedSwIdNS']
${New_task_xpath}        //span[contains(@id, 'opActionButtons')]/input[contains(@value, 'New Task')]
${Rollback_xpath}         //*[@id="include:createWizardForm:opTree:0:4::opNodeName"]
${Download_xpath}         //*[@id="include:createWizardForm:opTree:0:1::opNodeName"]
${Provision_xpath}        //*[@id="include:createWizardForm:opTree:0:3::opNodeName"]
${Activation_xpath}       //*[@id="include:createWizardForm:opTree:0:2::opNodeName"]
${Rollback_finish_xpath}    //input[@id='include:createWizardForm:btnFinish' and @value='Finish']
${Rollback_continue}       //input[@id='confirmationForActiveOperationModalForm:confirmationForActiveOperationModalmsgBtnScriptAndActionOk']
${Action_status_xpath}     //*[@id="swmTable_networkView_body"]//td[@class='columnLastSoftwareTaskNS']//img[contains(@src, 'webuif/icons')]
#${Action_status_xpath}     //*[@id="swmTable_networkView_body"]/div/table/tbody/tr/td[8]/div/span/a/img

${login_Task Details_xpath_scroll}    //*[@id="swmTable_networkView_body"]/div/table/tbody/tr/td[11]
${login_Task_Details_xpath_click}    //div[contains(text(), 'Download')]
${login_Task Details_xpath}    //*[@id="swmTable_networkView_body"]/div/table/tbody/tr/td[10]/a/div/div[2]
#${Cancel_dowmload_xpath}    //div[@id='frmTaskDetails:pgpAction']//input[@value='Cancel']
${Cancel_dowmload_xpath}     //*[@id="frmTaskDetails:btnCancel"]
${Cancel_status_xpath}    //*[@id="frmTaskDetails:TaskStatus"]

#${New_url}      https://na19lbwas.qin1.srnhz.nsn-rdnet.net
#${user_name}    omc
#${pwd}    Nokia123!
${New_url}      https://kungfulbwas.kungfu.srnhz.nsn-rdnet.net
${user_name}    omc
${pwd}    Nokia126_
${NetAct_dmgr}     ${tl.nms}
${usr}    root
${passwd}    arthur

${wget_link}        https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release
${SW_Archive_MO_Type_xpath}    //*[@id="embTreeFrm:cccomboboxField"]
${app_download_path}        /root/Downloads
${package_download_path}    /home/nokia/Downloads/
*** Keywords ***
Get SW version
    &{SW version}    selenium_coam.check_current_software_version
    [Return]  ${SW version}

Get BTS ID
    [Documentation]   Get BTS ID
    ${bts id}    selenium_coam.get_parameter_value    MRBTS-19264    Multi Radio BTS Instance Id
    [Return]  ${bts id}

Login Netact
    [Documentation]   Login NetAct
    ...    Author: jeffrey.shi@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | url | no | NetAct web link|
    ...   | user_name | no | NetAct user name |
    ...   | pwd | no | NetAct password |
    Netact.enable_virtual_display
    run keyword and ignore error    Netact.logout
    run keyword and ignore error  Remove File    /root/Downloads/*.jnlp
    run keyword and ignore error    netact.Set Download Dir    ${app_download_path}
    Netact.login    ${New_url}    ${user_name}    ${pwd}

Logout NetAct
    run keyword and ignore error    Netact.logout
    Netact.disable_virtual_display

Open Software Manager
    [Documentation]   Open NetAct software manager
    ...    Author: jeffrey.shi@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...    None
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    netact.open_configuration_software_manager
    sleep    5s

Select Target gNB
    [Documentation]   Select tagaet gNB in software management/Network status
    ...    Author: jeffrey.shi@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | MO_DN_xpath | no | MO type in Network Status|
    ...   | View_xpath | no | View in Network Status |
    ...   | BTS_ID | yes | gNB BTS ID |
    ...    Example
    ...   | Select Target gNB | ${BTS_ID} |
    [Arguments]  ${BTS_ID}   ${MO_Type_value}=MRBTS   ${View_value}=Parent
    wait until keyword succeeds    2min    5s    netact.write_value_and_enter    ${MO_Type_xpath}    ${MO_Type_value}
    sleep    10s
    wait until keyword succeeds    2min    5s    netact.write_value_and_enter    ${View_xpath}    ${View_value}
    sleep    10s
    wait until keyword succeeds    2min    5s    netact.select_checkbox    ${Parent_xpath}
    sleep    10s
    wait until keyword succeeds    2min    5s    netact.write_value_and_enter    ${MO_name_xpath}    ${BTS_ID}
    sleep    10s
    wait until keyword succeeds    2min    5s    netact.select_checkbox          ${Radio_Select_box}
    netact.Click Button    //*[@id="swmTable_networkView_refreshTable"]/div/a/div/span
    #wait until keyword succeeds    2min    5s    netact.write_value_and_enter    ${MO_DN_xpath}      ${BTS_ID}
    #sleep    10s

Get Active SW ID via NetAct
    [Documentation]   get Active SW version from NetAct
    ...    Author: jeffrey.shi@nokia-sbell.com
    ${Active_version}    netact.get_elem_text    ${Active_Info_xpath}
    [Return]  ${Active_version}

Get Passive SW ID via NetAct
    [Documentation]   get passive SW version from NetAct
    ...    Author: jeffrey.shi@nokia-sbell.com
    ${Passive_version}    netact.get_elem_text    ${Passive_Info_xpath}
    [Return]  ${Passive_version}

Upload SW build to NetAct
    [Arguments]   ${SW_version}
    ${package_full_link}    Get The Version link For Download    ${SW_version}
    Download SW Build to VM    ${package_full_link}
    Login Netact
    Open Software Manager
    Start upload SW build Java APP
    Upload SW build via Java APP    ${package_download_path}/AirScale-${SW_version}.zip
    Close Java Application
    logout netact

Start upload SW build Java APP
    [Documentation]   Open upload SW build Java APP
    ...    Author: jeffrey.shi@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | SW_build_Version | Yes | Sw build version|
    wait until keyword succeeds    3times    10s    netact.switch_to_software_archive
    sleep   30s
    netact.write_value_and_enter    ${SW_Archive_MO_Type_xpath}    MRBTS
    sleep   10s
    netact.Click Button     //a[@id='embTreeFrm:cmdLinkImport']//span[contains(text(), 'Add software package')]
    sleep   30s
    log to console    Open upload SW build Java APP
    swing.Setup    javaws_path=/usr/bin/javaws
    swing.Start Application    alias=SW build    jnlp_file=/root/Downloads/webstart.jnlp
    ...    close_security_dialogs=${True}    remote_port=${34218}    timeout=${500}
    swing.Application Started      SW build     remote_port=${34218}
    swing.Switch to Application    SW build
    Sleep    30s

Upload SW build via Java APP
    [Documentation]   Upload SW build to NetAct via Java APP
    ...    Author: jeffrey.shi@nokia-sbell.com
    [Arguments]   ${file_path}
     Wait Until Keyword Succeeds    30 sec    5 sec    SWING.Select Main Window
     sleep    5s
     run keyword and ignore error    swing.Select From Combobox   0   MRBTS
     ${output}=    SWING.List Components In Context
     sleep    5s
     swing.Push Button   Add Local Files...
     swing.Select Dialog   Open Local Files
     swing.Insert into Text Field   0   ${file_path}
     swing.Push Button   Open
     sleep    5s
     ${windows}   swing.List Windows
     swing.Select Window   ${windows[0]}
     Wait Until Keyword Succeeds    1min    20s    swing.Button Should Be Enabled    Import All
     Wait Until Keyword Succeeds    3times    10s    swing.Push Button    Import All
     Sleep   10min
     FOR   ${index}    IN RANGE    30
         ${curr_action}   swing.Get label Content   16
         Run Keyword If   '${curr_action.lower()}'=='stop'   Sleep   1min
         ...   ELSE   Exit For Loop
    END
     ${curr_status}   swing.Get label Content   15
     ${load_success}   Set Variable   Software package imported successfully
     Should Be Equal   ${curr_status}   ${load_success}

Close Java Application
    [Documentation]   close NetAct Java APP
    ...    Author: jeffrey.shi@nokia-sbell.com
    [Arguments]   ${remote_port}=${34218}
    ${output}    Run    netstat -tunlp|grep ${remote_port}
    ${output}    Strip String    ${output}
    @{port_info_list}    Split String    ${output}    ${SPACE}
    ${list_length}   Get Length   ${port_info_list}
    ${port_info_str} =    Set Variable If
    ...    '${list_length}'=='0'    ${SPACE}
    ...    '${list_length}'!='0'    ${port_info_list[-1]}
    @{pid_list}    Split String    ${port_info_str}    /
    ${pid}    Set Variable    ${pid_list[0]}
    # ${output}    Run    kill -15 ${pid}
    ${output}    Run    kill -9 ${pid}

Get The Version link For Download
    [Documentation]     get the dwonload package link like planned/active/passive version
    [Arguments]    ${SW_build_Version}
    ${sw_package_name}    set variable    AirScale-${SW_build_Version}.zip
    ${package_full_link}    set variable    ${wget_link}/${SW_build_Version}/${sw_package_name}
    [Return]      ${package_full_link}

Download SW Build to VM
    [Arguments]    ${package_full_link}    ${SW_build_path}=/home/nokia/Downloads/
    OperatingSystem.Empty Directory    ${SW_build_path}
    Run And Return Rc And Output    wget --no-proxy ${package_full_link}.md5 -P ${SW_build_path}
    ${output}    OperatingSystem.List Directory    ${SW_build_path}    absolute=${TRUE}
    ${md5_file}     set variable    ${output}[0]
    ${md5_value}      OperatingSystem.get file    ${md5_file}
    OperatingSystem.Empty Directory    ${SW_build_path}
    Run And Return Rc And Output    wget --no-proxy ${package_full_link} -P ${SW_build_path}
    ${output}    OperatingSystem.List Directory    ${SW_build_path}    absolute=${TRUE}
    ${upgrade_package_path}     set variable    ${output}[0]
    wait until keyword succeeds    15min    10s    check the download completed    ${upgrade_package_path}     ${md5_value}
    [Return]      ${upgrade_package_path}

check the download completed
    [Arguments]    ${upgrade_package_path}    ${md5_value}
    ${res}    ${output}    Run And Return Rc And Output    md5sum ${upgrade_package_path}
    ${res}    string.split string    ${output}
    should be equal    ${md5_value}    ${res}[0]

Select New Task and rollback option done
    [Documentation]    In Network Status package click New Task - Rollback - Finish
    netact.click_button    ${New_task_xpath}
    sleep    5s
    netact.click_button    ${Rollback_xpath}
    sleep    5s
    netact.click_button    ${Rollback_finish_xpath}
    sleep    5s
    netact.click_button    ${Rollback_continue}
    sleep    5s

Upload Target gNB
    [Documentation]   upload target gNB SW version to NetAct
    ...    Author: jeffrey.shi@nokia-sbell.com
    netact.wait_for_enable       ${Upload_xpath}
    sleep    10s
    netact.Click Button    ${Upload_xpath}
    sleep    2min
    run keyword and ignore error    netact.scroll_element_to_view    ${Upload_status_xpath}
    sleep    10s
    ${Update status}    netact.get_element_attribute    ${Upload_status_xpath}    src
    sleep    15s
    ${task}   netact.get_elem_text    //td[@class='columnLastSoftwareTaskNS']//img/following-sibling::span
    should be equal   ${task}    Upload
    [Return]  ${Update status}

Check Rollback excetion success
    ${Rollback_status}    netact.get_element_attribute    ${Action_status_xpath}    src
    ${task}   netact.get_elem_text    //td[@class='columnLastSoftwareTaskNS']//img/following-sibling::span
    should contain    ${Rollback_status}    ok_NSN
    should be equal   ${task}    Rollback

Check Download exceution success via NetAct
    ${Download_status}    netact.get_element_attribute    ${Action_status_xpath}    src
    ${task}   netact.get_elem_text    //td[@class='columnLastSoftwareTaskNS']//img/following-sibling::span
    should contain    ${Download_status}    ok_NSN
    should be true   "${task}"=="Download" or "${task}"=="SW Change Event"

Check Provision exceution success
    ${Download_status}    netact.get_element_attribute    ${Action_status_xpath}    src
    should contain    ${Download_status}    ok_NSN

Select SW package and finish download
    [Arguments]    ${sw_version}
    ${Selected_SW_xpath}    set variable
    ...    //div[contains(text(), 'AirScale-${sw_version}')]/parent::td/preceding-sibling::td[1]//input[@type='radio']
    sleep    5s
    netact.click_button    ${New_task_xpath}
    sleep    5s
    netact.click_button    ${Download_xpath}
    sleep    5s
    netact.click_button    ${Selected_SW_xpath}
    sleep    5s
    netact.click_button    ${Rollback_finish_xpath}
    sleep    2s

Select SW package and finish provision
    [Arguments]    ${sw_version}
    ${Selected_SW_xpath}    set variable
    ...    //div[contains(text(), 'AirScale-${sw_version}')]/parent::td/preceding-sibling::td[1]//input[@type='radio']
    sleep    5s
    netact.click_button    ${New_task_xpath}
    sleep    5s
    netact.click_button    ${Provision_xpath}
    sleep    5s
    netact.click_button    ${Selected_SW_xpath}
    sleep    5s
    netact.click_button    ${Rollback_finish_xpath}
    sleep    5s
    netact.click_button    //*[@id="confirmationForActiveOperationModalForm:confirmationForActiveOperationModalmsgBtnScriptAndActionOk"]
    sleep    10min

Activation SW build via NetAct
    [Arguments]    ${sw_version}
    ${Selected_SW_xpath}    set variable
    ...    //div[contains(text(), 'AirScale-${sw_version}')]/parent::td/preceding-sibling::td[1]//input[@type='radio']
    sleep    5s
    netact.click_button    ${New_task_xpath}
    sleep    5s
    netact.click_button     ${Activation_xpath}
    sleep    5s
    netact.click_button    ${Selected_SW_xpath}
    sleep    5s
    netact.click_button    ${Rollback_finish_xpath}
    sleep    5s
    netact.click_button    //*[@id="confirmationForActiveOperationModalForm:confirmationForActiveOperationModalmsgBtnScriptAndActionOk"]
    sleep    10min

Check Activatation execution success
    ${Activation_status}    netact.get_element_attribute    ${Action_status_xpath}    src
    should contain    ${Activation_status}    ok_NSN

Get SW build version in NetAct
    [Documentation]     get all SW build versions which already uploaded in NetAct
    ...    Author: jeffrey.shi@nokia-sbell.com
    [Arguments]    ${NetAct_dmgr}=10.107.178.203    ${usr}=${user_name}    ${passwd}=${pwd}    ${swm_arch}=/var/opt/nokia/oss/global/swm/swm_arch
    csn.connect to    ${NetAct_dmgr}    ${usr}    ${passwd}    alias=NetActMgr
    csn.send command    command=ls ${swm_arch}    connection=NetActMgr
    ${SW_build_version_NetAct}    csn.read output    connection=NetActMgr
    csn.disconnect    connection=NetActMgr
    [Return]   ${SW_build_version_NetAct}

Check SW build exist in NetAct or not
    [Documentation]     check whether SW build already uploaded in NetAct or not, return True if same build exist!
    ...    Author: jeffrey.shi@nokia-sbell.com
    [Arguments]    ${sw_version}    ${NetAct_dmgr}=10.107.178.203   ${usr}=${user_name}    ${passwd}=${pwd}     ${flag}=None
    ${Sw_build_version}   set variable    AirScale-${sw_version}
    ${SW_build_version_NetAct}     Get SW build version in NetAct    ${NetAct_dmgr}    ${usr}    ${passwd}
    @{SW_build_version_NetAct}     split string    ${SW_build_version_NetAct}
    FOR    ${temp}    IN    @{SW_build_version_NetAct}
        ${flag}    set variable if    "${temp}"=="${Sw_build_version}"    True
        run keyword if    ${flag}==True    Exit for loop
    END
    [Return]    ${flag}

Cancel SW download via NetAct
    netact.scroll_element_to_view     ${login_Task Details_xpath_scroll}
    sleep    2s
    wait until keyword succeeds    10s    2s    netact.click_button     ${login_Task_Details_xpath_click}
    sleep    3s
    wait until keyword succeeds    30s    2s    netact.click_button     ${Cancel_dowmload_xpath}
    #sleep    3s
    #wait until keyword succeeds    10s    2s    netact.click_button     //tbody//input[contains(@value,'OK')]
    sleep    2s
    wait until keyword succeeds    10s    2s    netact.click_button     //*[@id="frmTaskDetails:cancelTaskConfirmationPanelmsgBtnOk"]
    sleep    3s

Check download cancellation success via NetAct
      ${Cancel_status}         netact.get_elem_text    ${Cancel_status_xpath}
      sleep    10s
      should be equal         ${Cancel_status}          Canceled
      sleep    3s
      netact.switch_to_network_status
      sleep    3s

SW Version convert
    [Documentation]    Convert SW build version(for example: 5G19_FSMK_0000_018351_000316) get from WEBUI to x.xx.xxx (for example : 0.1835.307)
    [Arguments]    ${Webui_version}
    @{temp}    string.split string    ${Webui_version}     _
    ${T1}    convert to integer    ${temp}[-3]
    ${T2}    convert to integer    ${temp}[-2]
    ${T3}    convert to integer    ${temp}[-1]
    ${CI_target}  set variable  ${T1}.${T2}.${T3}
    [Return]    ${CI_target}

Get BTS ID from Testline
    [Documentation]   Get gNB MRBTS_ID
    [Arguments]    ${scf_path}
    ${BTSID_temp}    getBTSInfo.Get_MRBTS_ID     ${scf_path}
    @{BTSID_tmp}    string.split string    ${BTSID_temp}    "
    ${BTSID}    set variable     ${BTSID_tmp}[0]
    [Return]    ${BTSID}

Common Teardown
    run keyword and ignore error    WEBUI Logout
    run keyword and ignore error    Logout netact
