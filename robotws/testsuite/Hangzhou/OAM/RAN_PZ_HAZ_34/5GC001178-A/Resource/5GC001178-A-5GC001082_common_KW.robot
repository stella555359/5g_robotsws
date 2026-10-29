*** Settings ***
Documentation
...    author: Jeffrey.Shi ;Jackie Ji; Annie.hu
...    contact: jeffrey.shi@nokia-sbell.com; jackie.ji@nokia-sbell.com ; annie.hu@nokia-sbell.com
...    squad group: SG_05
...    Feature 5GC0001178-A-5GC001082 in 5G19B program


Library       taf.ul.selenium.netact    WITH NAME    netact
Library       taf.ul.swing.core    WITH NAME    swing
Library       taf.transport.ssh    WITH NAME    csn
Library       ../../libraries/get_bts_info.py    WITH NAME     lib

Resource      ../../common/coam_resource.robot
#Resource      ../../common/NetAct_swing.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Variables ***
${target_version}    none
${SW_build_path}     /home/ute/Downloads
${package_link}      https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build/
${SBTS_package_link}         https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build/SBTS00/
${SBTS21B_package_link}      https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build/SBTS21B/
${SBTS22R3_package_link}     https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build/SBTS22R3/
${SBTS22R4_package_link}     https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build/SBTS22R4/
${SBTS23R1_package_link}     https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build/SBTS23R1/
${SBTS23R2_package_link}     https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build/SBTS23R2/
${SBTS23R3_package_link}     https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build/SBTS23R3/

${package_target_version}    ${target_version}
${MO_Type_xpath}         //*[@id="ccMOTypecomboboxField"]
${View_xpath}            //*[@id="TreeViewcomboboxField"]
${Parent_xpath}          //input[@id="mot:::c"]
${MO_DN_xpath}           //table[@class='table table-bordered table-header']//input[@class='filter-input']
#${Radio_Select_box}      //tr[@class='table-row-odd']/td[@class='columnSelectNS']/input[@class='selection']
${Radio_Select_box}       //*[@id="swmTable_networkView_body"]/div/table/tbody/tr/td[1]/input
${Upload_xpath}          //*[@id="belowTableActions:uploadButton"]
${Upload_status_xpath}   //*[@id="swmTable_networkView_body"]//td[@class='columnLastSoftwareTaskNS']//img[contains(@src, 'webuif/icons')]
#${Upload_status_xpath}    //*[@id="swmTable_networkView_body"]/div/table/tbody/tr/td/div/span/a/img
${Active_Info_xpath}     //table[@class='table table-bordered table-body']//td[@class='columnActiveSwIdNS']
${Passive_Info_xpath}    //table[@class='table table-bordered table-body']//td[@class='columnPassiveSwIdNS']
${Planned_Info_xpath}    //table[@class='table table-bordered table-body']//td[@class='columnPlannedSwIdNS']
${New_task_xpath}        //span[contains(@id, 'opActionButtons')]/input[contains(@value, 'New Task')]
${Rollback_xpath}         //*[@id="include:createWizardForm:opTree:0:5::opNodeName"]
${Download_xpath}         //*[@id="include:createWizardForm:opTree:0:1::opNodeName"]
${Provision_xpath}        //*[@id="include:createWizardForm:opTree:0:4::opNodeName"]
${Activation_xpath}       //*[@id="include:createWizardForm:opTree:0:3::opNodeName"]
${Rollback_finish_xpath}    //input[@id='include:createWizardForm:btnFinish' and @value='Finish']
${Rollback_continue}       //input[@id='confirmationForActiveOperationModalForm:confirmationForActiveOperationModalmsgBtnScriptAndActionOk']
${Action_status_xpath}     //*[@id="swmTable_networkView_body"]//td[@class='columnLastSoftwareTaskNS']//img[contains(@src, 'webuif/icons')]
#${Action_status_xpath}     //*[@id="swmTable_networkView_body"]/div/table/tbody/tr/td/div/span/a/img

${login_Task Details_xpath_scroll}    //*[@id="swmTable_networkView_body"]/div/table/tbody/tr/td[11]
${login_Task_Details_xpath_click}    //div[contains(text(), 'Download')]
#${login_Task Details_xpath}    //*[@id="swmTable_networkView_body"]/div/table/tbody/tr/td[10]/a/div/div[2]
#${Cancel_download_xpath}    //div[@id='frmTaskDetails:pgpAction']//input[@value='Cancel']
${Cancel_download_xpath}     //*[@id="frmTaskDetails:btnCancel"]
${Cancel_status_xpath}    //*[@id="frmTaskDetails:TaskStatus"]

#${New_url}      https://na19lbwas.qin1.srnhz.nsn-rdnet.net
#${user_name}    omc
#${pwd}    Nokia126_
#${NetAct_dmgr}     ${tl.nms}
#${New_url}      https://shanxilbwas.sui6.srnhz.nsn-rdnet.net
${New_url}      https://gansulbwas.gansu.srnhz.nsn-rdnet.net
${usr}      omc
${passwd}    Nokia126_

${wget_link}        https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build/SBTS00/
${SBTS00_package_link}     https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build/SBTS00/
${SW_Archive_MO_Type_xpath}    //*[@id="embTreeFrm:cccomboboxField"]
${app_download_path}        /home/ute/tmp
${package_download_path}    /home/ute/Downloads/

*** Keywords ***
Get The Version link For Download
    [Documentation]     get the dwonload package link like planned/active/passive version
    [Arguments]    ${version_type}
    ${version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    ${result}    string.split string    string=${version}[${version_type}]    separator=_
    ${result1}    convert to integer    ${result}[-1]
    ${result2}    convert to integer    ${result}[-2]
    ${result3}    convert to integer    ${result}[-3]
    ${result4}     convert to string    ${result}[-5]
    ${SW_vesion}    set variable      ${result3}.${result2}.${result1}

    ${target_version}=   Run Keyword If   "${result3}"=="9999"
    ...   string.Replace String    ${version}[${version_type}]    ${result4}    SBTS00
    ...   ELSE    Set Variable     ${version}[${version_type}]
    ${package_full_link}=
    ...   Run Keyword If    "${result3}"=="9999"
    ...   Set Variable    ${SBTS_package_link}/${target_version}/${target_version}_release_BTSSM_downloadable_A54.zip
    ...   ELSE  Set Variable  ${package_link}/${result4}/${target_version}/${target_version}_release_BTSSM_downloadable_A54.zip
    [Return]      ${version}    ${package_full_link}

Get link For Download from external value
    [Arguments]    ${version_type}
#    ${version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
#    @{result}    string.split string    string=&{version}[${version_type}]    separator=_
#    ${result5}     convert to string    @{result}[-5]
#    ${if_SBTS21B}     convert to string    @{result}[-3]
#    set suite variable    ${result5}
#    set suite variable    ${if_SBTS21B}
#    ${package_full_link}=   Run Keyword If   "${result5}"=="SBTS23R1" and "${if_SBTS21B}"=="9999"
#    ...   Set Variable     ${SBTS_package_link}/${package_target_version}/${package_target_version}_release_BTSSM_downloadable_A54.zip
#    ...   ELSE IF    "${result5}"=="SBTS23R2" and "${if_SBTS21B}"=="9999"
#    ...   Set Variable     ${SBTS_package_link}/${package_target_version}/${package_target_version}_release_BTSSM_downloadable_A54.zip
#    ...   ELSE IF    "${result5}"=="SBTS23R1" and "${if_SBTS21B}"=="0000"
#    ...   Set Variable     ${SBTS23R1_package_link}/${package_target_version}/${package_target_version}_release_BTSSM_downloadable_A54.zip
#    ...   ELSE IF    "${result5}"=="SBTS22R4" and "${if_SBTS21B}"=="0000"
#    ...   Set Variable     ${SBTS22R4_package_link}/${package_target_version}/${package_target_version}_release_BTSSM_downloadable_A54.zip
#    ...   ELSE IF    "${result5}"=="SBTS22R3" and "${if_SBTS21B}"=="0000"
#    ...   Set Variable     ${SBTS22R3_package_link}/${package_target_version}/${package_target_version}_release_BTSSM_downloadable_A54.zip
#    ...   ELSE IF    "${result5}"=="SBTS21B" and "${if_SBTS21B}"=="0000"
#    ...   Set Variable     ${SBTS21B_package_link}/${package_target_version}/${package_target_version}_release_BTSSM_downloadable_A54.zip
#    ...   ELSE    Set Variable     ${package_link}/${package_target_version}/AirScale-${package_target_version}.zip

    ${version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    ${result_version_type}    string.split string    string=${version}[${version_type}]    separator=_

    @{result}    string.split string    string=${package_target_version}    separator=_
    ${result4}    convert to string    ${result}[-5]   #SBTS00, SBTS23R1
    ${if_SBTS21B}     convert to string    ${result}[-3]   #9999, 0000

    ${package_target_version}=   Run Keyword If   "${if_SBTS21B}"=="9999"
    ...   string.Replace String    ${package_target_version}    ${result4}    SBTS00
    #${result4}    set variable if   "${if_SBTS21B}"=="9999"   SBTS00    ${result4}
    set suite variable    ${result4}
    set suite variable    ${if_SBTS21B}

    ${zipBuildName}    set variable    ${package_target_version}_release_BTSSM_downloadable_A54.zip
    ${package_full_link}=
    ...   Run Keyword If    "${if_SBTS21B}"=="9999"
    ...   Set Variable    ${SBTS_package_link}/${package_target_version}/${zipBuildName}
    ...   ELSE  Set Variable  ${package_link}/${result4}/${package_target_version}/${zipBuildName}
    [Return]      ${package_full_link}

Download SW Build to VM
    [Arguments]    ${package_full_link}
    OperatingSystem.Create Directory    ${SW_build_path}
    OperatingSystem.Empty Directory    ${SW_build_path}
    WEBUI Login
    ${current_version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    ${result}    string.split string    string=${current_version}[Active]    separator=_
    ${package_stream}     convert to string    ${result}[-5]
    set suite variable     ${package_stream}
    Run And Return Rc And Output    wget --no-proxy ${package_full_link}.sha256 -P ${SW_build_path}
    ${output}    OperatingSystem.List Directory    ${SW_build_path}    absolute=${TRUE}
    ${md5_file}     set variable    ${output}[0]
    ${md5_value}      OperatingSystem.get file    ${md5_file}
    OperatingSystem.Empty Directory    ${SW_build_path}
    Run And Return Rc And Output    wget --no-proxy ${package_full_link} -P ${SW_build_path}
    ${output}    OperatingSystem.List Directory    ${SW_build_path}    absolute=${TRUE}
    ${upgrade_package_path}     set variable    ${output}[0]
    sleep    5min
    wait until keyword succeeds    10min    10s    check the download completed    ${upgrade_package_path}     ${md5_value}
    [Return]      ${upgrade_package_path}

Check the download completed
    [Arguments]    ${upgrade_package_path}    ${md5_value}
    ${sum}=     Set Variable     sha256sum ${upgrade_package_path}
    ${res}    ${output}    Run And Return Rc And Output    ${sum}
    ${res}    string.split string    ${output}
    should be equal    ${md5_value}    ${res}[0]

Check SW version with external package value
    [Documentation]    this KW is to check the SW version when the download version is from the external value
    [Arguments]     ${check_version}
    ${version}    wait until keyword succeeds    2min   15s    selenium_coam.check_current_software_version
    ${result}    string.split string    string=${version}[${check_version}]    separator=_
    ${SW_check}    convert to integer      ${result}[-1]
    @{result}    string.split string     string=${package_target_version}    separator=.
    should be equal    "${SW_check}"    "${result}[-1]"
    [Return]    ${version}

Check sw version without external package value
    [Documentation]    cp_b4 and after should be Planned/Active/Passive
    [Arguments]      ${version_b4}    ${cp_b4}    ${cp_after}
    ${version}    wait until keyword succeeds    1min    10s    selenium_coam.check_current_software_version
    should be equal      ${version_b4}[${cp_b4}]    ${version}[${cp_after}]

Download package to site
    [Documentation]    the input value should be False or Ture
    [Arguments]    ${if_active}    ${upgrade_package_path}
    log to console  Download package to site
    ${result}    selenium_coam.load_software_package_from_local_drive     file_path=${upgrade_package_path}
    should be equal      ${result}    software package load success
    selenium_coam.software_update     is_activate=${if_active}

Check SW download progress finished
    ${result}    selenium_coam.check_software_update_progress
    should be equal    ${result}[status]    Download completed
    should be equal    ${result}[percentage]    100%

Check reset progress when same as active version
    [Documentation]    this KW is to check the reset status when the upgrade package is same as active version
    ${result}    selenium_coam.check_software_update_progress
    should be equal    ${result}[status]     Activation completed
    #should be equal    ${result}[percentage]     100% completed

Check site reset actually finished
    [Documentation]    this KW is to check the reset status when site will reset actually
    ${result}    selenium_coam.check_software_update_progress
    should be empty    ${result}[status]
    should be equal    ${result}[percentage]     0% completed
    #should be empty    ${result}[percentage]

Check board and cell status
    Check ABIL is UP
    Check ASIK is UP
    Check Cell is UP

Check the update report
    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    ${sw_update_report}    selenium_coam.save_sw_update_report
    OperatingSystem.File Should Exist     ${sw_update_report}
    OperatingSystem.Copy File    ${sw_update_report}     ${SW_build_path}
    ${file_path}    ${file_name}    OperatingSystem.split path    ${sw_update_report}
    ${sw_update_report_content}    OperatingSystem.get file    ${SW_build_path}/${file_name}
    csn.Connect to     hostname=${host_addr}     username=${host_username}     password=${host_password}    alias=TESTPC
    csn.send command    command=cat ${SW_build_path}/${file_name} |grep -n "Finished Software Build Download" |tail -1 |cut -d ":" -f1
    ...    connection=TESTPC
    ${output}    csn.read output    connection=TESTPC
    ${line_number}    convert to integer   ${output}
    csn.send command    command=tail -n \+${line_number} ${SW_build_path}/${file_name}    connection=TESTPC
    ${output}    csn.read output    connection=TESTPC
    should not contain any    ${output}    error    failed
    csn.disconnect    connection=TESTPC

Rollback site
     selenium_coam.software_rollback
     selenium_coam.disable_screen_lock
     wait until keyword succeeds    18min    10s    Check site reset actually finished
#     Run Keyword And Ignore Error    wait until keyword succeeds    2min    15s     WEBUI Logout
     sleep   300s
     Run Keyword And Ignore Error    wait until keyword succeeds    2min    10s    WEBUI Login
     Run Keyword And Ignore Error    wait until keyword succeeds    15min    20s    check board and cell status
     #selenium_coam.enable_screen_lock


Backup_SCF_file_on_WebEM
    log to console    Backup_SCF_file_on_WebEM
    ${flag_result}   ${scf_file}    Run Keyword And Ignore Error    selenium_coam.backup_bts_site_configuration    download_timeout=600
    sleep    5s
    ${scf_file_path}    OperatingSystem.Copy File    ${scf_file}    ${SAVE LOG DIRECTORY}
    set suite variable     ${scf_file_path}

Case setup
    cOAM Common Test Setup
    WEBUI Login
    Obtain_BTS_Name_ID
    #Get MRBTS Id online
    Get_SMOD_type
    ${version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    ${active_version_b4}    set variable      ${version}[Active]
    ${passive_version_b4}    set variable      ${version}[Passive]
    set suite variable    ${active_version_b4}
    set suite variable    ${passive_version_b4}
    # ${version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    @{result}    string.split string     ${active_version_b4}     separator=_
    ${main_build}     convert to string    ${result}[-5]
    ${stream}     convert to string    ${result}[-3]
    set suite variable    ${main_build}
    set suite variable    ${stream}
    Run Keyword And Ignore Error     WEBUI Logout
     #check RU STATUS

Env Recovery
    Run Keyword And Ignore Error   WEBUI Logout
    wait until keyword succeeds    2min    15s     WEBUI Login
    ${version_current}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    ${current_active_version}     set variable      ${version_current}[Active]
    run keyword if      '${active_version_b4}' != '${current_active_version}'    Rollback site
    Run Keyword And Ignore Error    wait until keyword succeeds    2min    15s     WEBUI Logout

Case teardown
    robot_common_operations.Common Case Teardown
    log to console   Start to Env Recovery
    Run Keyword And Ignore Error   WEBUI Logout
    #${CIT_build}    get CIT build
    #set suite variable        ${CIT_build}
    OperatingSystem.Empty Directory    ${SW_build_path}
    #WEBUI Login
    #@{version}     check SW version    Active
    #${converted_active_version}     SW Version convert     @{version}[0]
    #run keyword if   "${CIT_build}"=="${converted_active_version}"    log     "Active version is CIT build version"
    #...    ELSE    run keywords
    #...    Upgrade back to CIT build
    #...    WEBUI Logout

Check upgrade back execution success
    log to console    check upgrade back execution success
    wait until keyword succeeds     10min      10s      WEBUI Login
    &{SW_version}    Get SW version
    ${version_from_gNB}    SW Version convert    ${SW_version}[Active]
    should be equal   ${version_from_gNB}     ${CIT_build}
    run keyword and ignore error     WEBUI Logout


Delete downloaded package
    [Arguments]    ${version_type}=Active
    log to console    Delete downloaded package
    csn.Connect to     hostname=${host_addr}      username=${host_username}      password=${host_password}    alias=TESTPC
    run keyword and ignore error    csn.execute     command=rm -rf ${SW_build_path}/.*    connection=TESTPC
    csn.disconnect    connection=TESTPC


Obtain_BTS_Name_ID
    Backup_SCF_file_on_WebEM
    ${mrbtsId}     lib.Get_MRBTSID_cOAM     scf_path=${scf_file_path}
    ${nrbtsId}     lib.Get_NRBTSID_cOAM     scf_path=${scf_file_path}
    set suite variable     ${mrbtsId}
    set suite variable     ${nrbtsId}

    ${BTS_Name}    Wait Until Keyword Succeeds    2min    10s
    ...    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsId}    filter_param=BTS name
    set suite variable     ${BTS_Name}
    ${MRBTS_ID}=    Set Variable    MRBTS-${mrbtsId}
    set suite variable    ${MRBTS_ID}

Get MRBTS Id online
    log to console    Get MRBTS Id online
    Wait Until Keyword Succeeds   3min   10s   WEBUI Login
    ${mrbtsId}    Wait Until Keyword Succeeds    2min    10s    selenium_coam.get_parameter_value
    ...    dist_name=MRBTS-${mrbtsId}    filter_param=Multi Radio BTS Instance Id
    ${MRBTS_ID}=    Set Variable    MRBTS-${mrbtsId}
    set suite variable    ${MRBTS_ID}
    sleep    2s

Get SW version
    &{SW version}    selenium_coam.check_current_software_version
    [Return]  ${SW version}

Get BTS ID
    [Documentation]   Get BTS ID
    ${bts_id}     selenium_coam.get_bts_id
    [Return]  ${bts id}

Get_SMOD_type
    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    ${output}    selenium_coam.get_hw_parameters    hw_type=SMOD    index=1
    ${output_tmp}    set variable    ${output}[Runtime parameters]
    set suite variable    ${P_name_smod}    ${output_tmp}[Product name]
    [Return]      ${P_name_smod}


Login Netact
    [Documentation]   Login NetAct
    ...    Author: jeffrey.shi@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | url | no | NetAct web link|
    ...   | user_name | no | NetAct user name |
    ...   | pwd | no | NetAct password |
    Netact.enable_virtual_display
    run keyword and ignore error    Netact.logout
    run keyword and ignore error  Remove File    ${app_download_path}/*.jnlp
    run keyword and ignore error    netact.Set Download Dir      ${app_download_path}
    #Netact.login      url=${Netact_url_qin}     username=${Netact_user_name}     password=${Netact_pwd_qin}
    Netact.login      url=${New_url}     username=${usr}     password=${passwd}

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
    wait until keyword succeeds    2min    5s    netact.write_value_and_enter      ${MO_Type_xpath}      ${MO_Type_value}
    sleep    10s
    wait until keyword succeeds    2min    5s    netact.write_value_and_enter      ${View_xpath}      ${View_value}
    sleep    10s
    wait until keyword succeeds    2min    5s    netact.select_checkbox      ${Parent_xpath}
    sleep    10s
    wait until keyword succeeds    2min    5s    netact.write_value_and_enter     ${MO_DN_xpath}     ${BTS_ID}
    sleep    10s
    wait until keyword succeeds    2min    5s    netact.select_checkbox     ${Radio_Select_box}
    sleep    10s

Get Active SW ID via NetAct
    [Documentation]   get Active SW version from NetAct
    ...    Author: jeffrey.shi@nokia-sbell.com
    ${Active_version}    netact.get_elem_text      ${Active_Info_xpath}
    [Return]  ${Active_version}

Get Passive SW ID via NetAct
    [Documentation]   get passive SW version from NetAct
    ...    Author: jeffrey.shi@nokia-sbell.com
    ${Passive_version}    netact.get_elem_text      ${Passive_Info_xpath}
    [Return]  ${Passive_version}

Upload SW build to NetAct
    [Arguments]   ${SW_version}
    ${package_full_link}    Get The Version link For Download_netact      SW_build_Version=${SW_version}
    Download SW Build to VM      package_full_link=${package_full_link}
    Login Netact
    Open Software Manager
    Start upload SW build Java APP
    ${SW_version_name}=
    ...   Run Keyword If   "${P_name_smod}"=="ASIB AirScale Common"
    ...   set variable       ${SW_Version}
    ...   ELSE IF   "${P_name_smod}"=="ASIK AirScale Common" and "${main_build}"!="5G19B"
    ...   set variable       ${SW_Version}
    ...   ELSE     Set Variable     ${SW_Version}
    #...   Run Keyword If    "${main_build}"!="5G19B"
    #...   Set Variable    AirScale-${SW_Version}
    #...   ELSE     Set Variable     AirScale-${SW_Version}
    Upload SW build via Java APP      file_path=${package_download_path}/${SW_version_name}_release_BTSSM_downloadable_A54.zip
    Close Java Application
    logout netact

Start upload SW build Java APP
    [Documentation]   Open upload SW build Java APP
    ...    Author: jeffrey.shi@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | SW_build_Version | Yes | Sw build version|
    wait until keyword succeeds    3times    10s    netact.switch_to_software_archive
    sleep   30s
    Wait Until Keyword Succeeds    30 sec    5 sec   netact.write_value_and_enter
    ...     ${SW_Archive_MO_Type_xpath}      MRBTS
    Wait Until Keyword Succeeds    30 sec    5 sec    netact.Click Button
    ...     //a[@id='embTreeFrm:cmdLinkImport']//span[contains(text(), 'Add software package')]
    sleep   30s
    log to console    Open upload SW build Java APP
    swing.Setup    javaws_path=/usr/bin/javaws
    swing.Start Application    alias=SW build    jnlp_file=${app_download_path}/webstart.jnlp
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
    ${output}    Strip String     string=${output}
    @{port_info_list}    Split String     string=${output}     separator=${SPACE}
    ${list_length}   Get Length   ${port_info_list}
    ${port_info_str} =    Set Variable If
    ...    '${list_length}'=='0'    ${SPACE}
    ...    '${list_length}'!='0'    ${port_info_list[-1]}
    @{pid_list}    Split String     string=${port_info_str}    separator=/
    ${pid}    Set Variable    ${pid_list[0]}
    # ${output}    Run    kill -15 ${pid}
    ${output}    Run    kill -9 ${pid}

Get The Version link For Download_netact
    [Documentation]     get the dwonload package link like planned/active/passive version
    [Arguments]    ${SW_build_Version}
    ${sw_package_name}=
    ...   Run Keyword If   "${P_name_smod}"=="ASIB AirScale Common"
    ...   set variable       ${SW_build_Version}_release_BTSSM_downloadable_A54.zip
    ...   ELSE IF   "${P_name_smod}"=="ASIK AirScale Common" and "${main_build}"!="5G19B"
    ...   set variable       ${SW_build_Version}_release_BTSSM_downloadable_A54.zip
    ...   ELSE     Set Variable     ${SW_build_Version}_release_BTSSM_downloadable_A54.zip

    #${sw_package_name}    set variable    ${SW_build_Version}_release_BTSSM_downloadable_A54.zip
    #${package_full_link}    set variable    ${wget_link}/${SW_build_Version}_release_BTSSM_downloadable_A54.zip
    ${package_full_link}    set variable    ${wget_link}${SW_build_Version}/${SW_build_Version}_release_BTSSM_downloadable_A54.zip
    [Return]      ${package_full_link}

Select New Task and rollback option done
    [Documentation]    In Network Status package click New Task - Rollback - Finish
    netact.click_button     ${New_task_xpath}
    sleep    5s
    netact.click_button     ${Rollback_xpath}
    sleep    5s
    netact.click_button     ${Rollback_finish_xpath}
    sleep    5s
    netact.click_button     ${Rollback_continue}
    sleep    5min

Upload Target gNB
    [Documentation]   upload target gNB SW version to NetAct
    ...    Author: jeffrey.shi@nokia-sbell.com
    netact.wait_for_enable        ${Upload_xpath}
    sleep    10s
    netact.Click Button    ${Upload_xpath}
    sleep    2min
    run keyword and ignore error    netact.scroll_element_to_view      ${Upload_status_xpath}
    sleep    10s
    ${Update status}    netact.get_element_attribute    ${Upload_status_xpath}    src
    sleep    15s
    ${task}   netact.get_elem_text    //td[@class='columnLastSoftwareTaskNS']//img/following-sibling::span
    should be equal   ${task}    Upload
    [Return]  ${Update status}

Check Rollback excetion success
    ${Rollback_status}    netact.get_element_attribute    ${Action_status_xpath}    src
    ${task}   netact.get_elem_text    //td[@class='columnLastSoftwareTaskNS']//img/following-sibling::span
    should contain    ${Rollback_status}    s_ok_NSN
    should be equal   ${task}    Rollback

Check Download exceution success via NetAct
    ${Download_status}    netact.get_element_attribute    ${Action_status_xpath}    src
    ${task}   netact.get_elem_text    //td[@class='columnLastSoftwareTaskNS']//img/following-sibling::span
    should contain    ${Download_status}    s_ok_NSN
    should be true   "${task}"=="Download" or "${task}"=="SW Change Event"

Check Provision exceution success
    ${Download_status}    netact.get_element_attribute    ${Action_status_xpath}     attr_name=src
    should contain    ${Download_status}    s_ok_NSN

Select SW package and finish download
    [Arguments]    ${sw_version}
    WEBUI Login
    ${version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    ${result}    string.split string    string=${version}[Active]    separator=_
    ${result3}     convert to string    ${result}[-3]
    ${result4}     convert to string    ${result}[-5]
    ${Sw_build_version}=
    ...   Run Keyword If   "${result3}"=="0000"
    ...   set variable       ${sw_version}
    ...   ELSE IF      "${result3}"=="9999"
    ...   string.Replace String     ${sw_version}    SBTS00    ${result4}
    ...   ELSE     Set Variable     ${sw_version}
    ${Selected_SW_xpath}=
    ...   Set Variable
    ...   //div[contains(text(), '${Sw_build_version}')]/parent::td/preceding-sibling::td[1]//input[@type='radio']

    sleep    5s
    netact.click_button     ${New_task_xpath}
    sleep    5s
    netact.click_button     ${Download_xpath}
    sleep    5s
    ${select_button}    run keyword and ignore error    netact.click_button     ${Selected_SW_xpath}
    Run Keyword If   "${select_button[0]}"=="FAIL"    netact.click_button
    ...     //div[contains(text(), '${sw_version}')]/parent::td/preceding-sibling::td[1]//input[@type='radio']
    sleep    5s
    netact.click_button     ${Rollback_finish_xpath}
    sleep    5s

Select SW package and finish provision
    [Arguments]    ${sw_version}
    ${Selected_SW_xpath}=
    ...   Run Keyword If   "${P_name_smod}"=="ASIB AirScale Common"      Set Variable
    ...   //div[contains(text(), 'AirScale-${sw_version}')]/parent::td/preceding-sibling::td[1]//input[@type='radio']
    ...   ELSE IF   "${P_name_smod}"=="ASIK AirScale Common" and "${main_build}"!="5G19B"   Set Variable
    ...   //div[contains(text(), 'AirScale-${sw_version}')]/parent::td/preceding-sibling::td[1]//input[@type='radio']
    ...   ELSE     Set Variable
    ...   //div[contains(text(), 'AirScale-${sw_version}')]/parent::td/preceding-sibling::td[1]//input[@type='radio']

    #${Selected_SW_xpath}    set variable
    #...    //div[contains(text(), 'AirScale-${sw_version}')]/parent::td/preceding-sibling::td[1]//input[@type='radio']
    sleep    5s
    netact.click_button     ${New_task_xpath}
    sleep    10s
    netact.click_button     ${Provision_xpath}
    sleep    10s
    netact.click_button     ${Selected_SW_xpath}
    sleep    10s
    netact.click_button     ${Rollback_finish_xpath}
    sleep    10s
    netact.click_button    //*[@id="confirmationForActiveOperationModalForm:confirmationForActiveOperationModalmsgBtnScriptAndActionOk"]
    sleep    10min

Activation SW build via NetAct
    [Arguments]    ${sw_version}
    #${Selected_SW_xpath}    set variable
    #...    //div[contains(text(), 'AirScale-${sw_version}')]/parent::td/preceding-sibling::td[1]//input[@type='radio']
    WEBUI Login
    ${version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    ${result}    string.split string    string=${version}[Active]    separator=_
    ${result3}     convert to string    ${result}[-3]
    ${result4}     convert to string    ${result}[-5]
    ${Sw_build_version}=
    ...   Run Keyword If   "${result3}"=="0000"
    ...   set variable       ${sw_version}
    ...   ELSE IF      "${result3}"=="9999"
    ...   string.Replace String     ${sw_version}    SBTS00    ${result4}
    ...   ELSE     Set Variable     ${sw_version}
    ${Selected_SW_xpath}=    Set Variable
    ...   //div[contains(text(), '${Sw_build_version}')]/parent::td/preceding-sibling::td[1]//input[@type='radio']
    sleep    5s
    netact.click_button     ${New_task_xpath}
    sleep    10s
    netact.click_button      ${Activation_xpath}
    sleep    5s
    ${select_button}    run keyword and ignore error    netact.click_button     ${Selected_SW_xpath}
    Run Keyword If   "${select_button[0]}"=="FAIL"    netact.click_button
    ...     //div[contains(text(), '${sw_version}')]/parent::td/preceding-sibling::td[1]//input[@type='radio']
    sleep    5s
    netact.click_button     ${Rollback_finish_xpath}
    sleep    5s
    netact.click_button    //*[@id="confirmationForActiveOperationModalForm:confirmationForActiveOperationModalmsgBtnScriptAndActionOk"]
    sleep    10min

Check Activatation execution success
    ${Activation_status}    netact.get_element_attribute    ${Action_status_xpath}    src
    should contain    ${Activation_status}    s_ok_NSN

Get SW build version in NetAct
    [Documentation]     get all SW build versions which already uploaded in NetAct
    ...    Author: jeffrey.shi@nokia-sbell.com
    [Arguments]    ${NetAct_dmgr}=${NetAct_dmgr}    ${usr}=${usr}    ${passwd}=${passwd}    ${swm_arch}=/var/opt/nokia/oss/global/swm/swm_arch
    csn.connect to     hostname=${NetAct_dmgr}     username=${usr}     password=${passwd}    alias=NetActMgr
    csn.send command    command=ls ${swm_arch}    connection=NetActMgr
    ${SW_build_version_NetAct}    csn.read output    connection=NetActMgr
    csn.disconnect    connection=NetActMgr
    [Return]   ${SW_build_version_NetAct}

Check SW build exist in NetAct or not
    [Documentation]     check whether SW build already uploaded in NetAct or not, return True if same build exist!
    ...    Author: jeffrey.shi@nokia-sbell.com
    [Arguments]    ${sw_version}    ${NetAct_dmgr}=${NetAct_dmgr}     ${usr}=${usr}    ${passwd}=${passwd}     ${flag}=None
    ${Sw_build_version}=
    ...   Run Keyword If   "${stream}"=="0000"
    ...   set variable       ${sw_version}
    ...   ELSE IF      "${stream}"=="9999"
    ...   string.Replace String     ${sw_version}    SBTS00    ${main_build}
    ...   ELSE     Set Variable     ${sw_version}
    #${Sw_build_version}   set variable    AirScale-${sw_version}
    ${SW_build_version_NetAct}     Get SW build version in NetAct      NetAct_dmgr=${NetAct_dmgr}      usr=${usr}      passwd=${passwd}
    @{SW_build_version_NetAct}     split string     string=${SW_build_version_NetAct}
    FOR    ${temp}    IN    @{SW_build_version_NetAct}
        ${flag}    set variable if    "${temp}"=="${Sw_build_version}"    True
        run keyword if    ${flag}==True    Exit for loop
    END
    [Return]    ${flag}

Cancel SW download via NetAct
    netact.scroll_element_to_view     ${login_Task Details_xpath_scroll}
    sleep    3s
    wait until keyword succeeds    10s    2s    netact.click_button      ${login_Task_Details_xpath_click}
    sleep    3s
    wait until keyword succeeds    20s    2s    netact.click_button      ${Cancel_download_xpath}
    #sleep    3s
    #wait until keyword succeeds    10s    2s    netact.click_button     //tbody//input[contains(@value,'OK')]
    sleep    5s
    wait until keyword succeeds    10s    2s    netact.click_button     //*[@id="frmTaskDetails:cancelTaskConfirmationPanelmsgBtnOk"]
    sleep    3s

Check download cancellation success via NetAct
    Run Keyword and Ignore Error    selenium_coam.refresh_page
    ${Cancel_status}         netact.get_elem_text     ${Cancel_status_xpath}
    sleep    3s
    #should be equal         ${Cancel_status}          Canceled
    Should Contain Any     ${Cancel_status}     Canceled    Successful
    sleep    3s
    netact.switch_to_network_status
    sleep    3s

SW Version convert
    [Documentation]    Convert SW build version(for example: 5G19_FSMK_0000_018351_000316) get from WEBUI to x.xx.xxx (for example : 0.1835.307)
    [Arguments]    ${Webui_version}
    @{temp}    string.split string     string=${Webui_version}     separator=_
    ${T1}    convert to integer    ${temp}[-3]
    ${T2}    convert to integer    ${temp}[-2]
    ${T3}    convert to integer    ${temp}[-1]
    ${T5}    set variable    ${temp}[-5]
    ${CI_target}=
    ...   Run Keyword If      "${T1}" == "9999"
    ...   string.Replace String     ${Webui_version}   SBTS22R3    SBTS00
    ...   ELSE IF     "${T1}" == "0000"
    ...   set variable      ${Webui_version}
    [Return]    ${CI_target}
