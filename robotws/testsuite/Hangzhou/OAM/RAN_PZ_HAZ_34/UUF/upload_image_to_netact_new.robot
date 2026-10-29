*** Settings ***
Force Tags    PY36
Documentation    Only for upload image to netact
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/NetAct_swing.robot
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/NetAct_selenium.robot
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_env.robot
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/common.robot
Library   OperatingSystem
Library   Collections
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/NetAct_ssh.robot
#Variables   ../libraries/nms_vars.py
Suite Setup   Run Keyword and Ignore Error   Close All Java Application Forced
Suite Teardown   Run Keyword and Ignore Error   Close All Java Application Forced

*** Variables ***
@{upload_ssh_allow}   10.107.178.214   10.106.161.25   10.108.243.22   10.108.248.82    10.110.144.154    10.68.84.15    10.107.183.26
${version}   10.1800.492
${DEBUG}   false
${netact_nodeip}   10.106.161.25
${NetAct_info}   ${netact_global_configuration}[${netact_nodeip}]
${NetAct_page}   ${NetAct_info['url']}
${NetAct_UI_user}   ${NetAct_info['http_username']}
${NetAct_UI_password}   ${NetAct_info['http_password']}
${NetAct_ssh_user}   ${NetAct_info['ssh_username']}
${NetAct_ssh_password}   ${NetAct_info['ssh_password']}
#${download_dir}   /home/nokia/Downloads
${download_dir}   /home/ute
${commonBuild_trunk}   SBTS24R1
*** Test Cases ***
Upload Image to NetAct
    run keyword if  not ${${DEBUG}}   selenium_netact.enable_virtual_display
#    Open Netact Start Page   url=${NetAct_page}   username=${NetAct_UI_user}   password=${NetAct_UI_password}   showall=${false}
#    selenium_netact.open_configuration_software_manager
#    ${package_exists}   Check package exists   ${version}
    ${package_exists}   run keyword and return status   Check Package Exists on NetAct Backend   ${version}
    pass execution if  ${package_exists}   SW package found in Netact, skip the upload actions.
#    Run Keyword and Return Status   selenium_netact.logout
    ${package_release}   Catch build release  ${version}
    ${if_commonbuild}   run keyword and return status  should contain   ${package_release}   SBTS
    ${version_suffix}    run keyword if  not ${if_commonbuild}   Fetch From Right    ${version}    .
    ${check_version}   run keyword if  "${package_release}"=="5G20A"   set variable  1130
    ...   ELSE IF   "${package_release}"=="trunk"   set variable  2002
    ...   ELSE   set variable  0
    ${knife_status}   run keyword and return status  should not contain  ${version_suffix}  -
    ${package_name}   run keyword if   ${knife_status}   set variable if  ${${version_suffix}}<${${check_version}}
    ...   AirScale-${version}_ASIK_ABIL.zip   AirScale-${version}.zip
    ...   ELSE IF   ${if_commonbuild}   set variable   ${version}_release_BTSSM_downloadable_A54.zip
    ...   ELSE   set variable   AirScale-${version}.zip
    Check taget SW package exist in taf server   version=${version}
    ${package_path}   Set Variable If   ${if_commonbuild}   ${download_dir}/${version}.zip   ${download_dir}/AirScale-${version}.zip
    Upload Image to NetAct   file_path=${package_path}   version=${version}
    wait until keyword succeeds   1h   5min   Check package exists   ${version}
    [Teardown]   Run Keywords   Run Keyword and Return Status   selenium_netact.logout
    ...   AND   run keyword if  not ${${DEBUG}}   selenium_netact.disable_virtual_display
    ...   AND   run keyword and ignore error  run keyword if   ${if_commonbuild}   Run   rm -rf ${download_dir}/${version}.zip
    ...   ELSE   Run   rm -rf ${download_dir}/${package_name}

*** Keywords ***
Copy Package from MNT to UTE
    [Arguments]  ${package_name}   ${package_path}
    Log to console   SW package AirScale-${version}.zip exists in path /mnt/5g_build/System_Release/${version}
    ${download_exists}   Run Keyword and Return Status   OperatingSystem.File Should Exist   ${download_dir}/AirScale-${version}.zip
    Log to console   CP Package
    Run Keyword If   ${download_exists}   log to console   Package Exist in ${download_dir}
    ...   ELSE   run   cp ${package_path} ${download_dir}/AirScale-${version}.zip
    Set Suite Variable   ${package_path}   ${download_dir}/AirScale-${version}.zip

Download Request Package
    ${download_exists}   Run Keyword and Return Status   OperatingSystem.File Should Exist   ${download_dir}/AirScale-${version}.zip
    Run Keyword If   ${download_exists}   Set Suite Variable   ${package_path}   ${download_dir}/AirScale-${version}.zip
    ...   ELSE   Download Classical Package   ${version}

Check package exists
    [Arguments]   ${version}
    log to console   Check package exists
    Open Netact Start Page   url=${NetAct_page}   username=${NetAct_UI_user}   password=${NetAct_UI_password}   showall=${false}
    selenium_netact.open_configuration_software_manager
    selenium_netact.switch_to_page   Software Manager
    selenium_netact.wait_for_enable   elem_xpath=//span[text()='Software Archive']
    Wait Until Keyword Succeeds   3 times   10s   Run Keywords   selenium_netact.Click Button   //span[text()='Software Archive']
    ...   AND   selenium_netact.wait_for_enable   elem_xpath=//input[@id='embTreeFrm:cccomboboxField']    timeout=600
    Sleep   3s
    selenium_netact.write_value_and_enter   //input[@id='embTreeFrm:cccomboboxField']   MRBTS
    Wait Until Keyword Succeeds   3 times   10s   selenium_netact.wait_for_visibility
    ...   elem_xpath=//*[@id='embTreeFrm:swTree:#REGULAR__PACKAGES#::remoteRepositoryTreeNode:mainRow']
    Sleep   3s
    ${package_list}   _Get package list
    ${is_common}   run keyword and return status   should contain   ${version}   SBTS
    ${package_version}   set variable if   ${is_common}   ${version}   AirScale-${version}
#    ${package_exists}   Run Keyword and Return Status  List Should Contain Value   ${package_list}   ${package_version}
    List Should Contain Value   ${package_list}   ${package_version}
#    [Return]   ${package_exists}
    [Teardown]   Run Keyword and Return Status   selenium_netact.logout

_Get package list
    ${table_id}   Set Variable   embTreeFrm:swTree:#REGULAR__PACKAGES#::remoteRepositoryTreeNode:childs
    ${package_list}   Create List
    ${package_count}   selenium_netact.execute_script
    ...   script_cmd=return document.getElementById('${table_id}').querySelectorAll('table').length
    FOR   ${i}    IN RANGE    ${package_count}
       ${child}   _Get Child Node Name   table_id=${table_id}   node_num=${i+1}
       ${select_status}   ${package_name}   run keyword and ignore error   selenium_netact.get_elem_text
       ...  elem_xpath=//div[@id='${table_id}']/table[${i+1}]/tbody/tr/td[3]/${child}
       ${is_common}   Run Keyword and Return Status   should contain   ${package_name}   SBTS
       ${is_package}   Run Keyword and Return Status   should not contain   ${package_name}   _
       ${common_package_list}   run keyword if   ${is_common} and ${is_package}   _Get Common Package List   ${package_name}
       ...    ELSE IF    ${is_common} and '${is_package}'=='${False}'    create list    ${package_name.strip()}
       EXIT FOR LOOP IF  '${select_status}'=='FAIL'
       ${package_tmp}    run keyword if  not ${is_common}   Create List   ${package_name.strip()}
       ${package_list}   run keyword if   ${is_common}   Combine Lists  ${package_list}   ${common_package_list}
       ...   ELSE   Combine Lists   ${package_list}   ${package_tmp}
    END
    [Return]   ${package_list}

_Get Common Package List
    [Arguments]  ${release}
    ${common_package_list}   Create List
    ${table_id_common}   Set Variable   embTreeFrm:swTree:#REGULAR__PACKAGES#:${release}::remoteRepositoryTreeNode:childs
    ${package_count}   selenium_netact.execute_script
    ...   script_cmd=return document.getElementById('${table_id_common}').querySelectorAll('table').length
    Wait Until Keyword Succeeds  5 times   2s   selenium_netact.move_to_element
    ...   elem_xpath=//*[@id="embTreeFrm:swTree:#REGULAR__PACKAGES#:${release}::remoteRepositoryTreeNode:handle:img:collapsed"]
    Wait Until Keyword Succeeds  5 times   2s   selenium_netact.click_button
    ...   button_xpath=//*[@id="embTreeFrm:swTree:#REGULAR__PACKAGES#:${release}::remoteRepositoryTreeNode:handle:img:collapsed"]
    sleep   10s
#    Run Keyword And Ignore Error   selenium_netact.wait_for_visibility    xpath=//div[@id='${table_id_common}']/table[1]/tbody/tr/td[3]
    FOR   ${i}    IN RANGE    ${package_count}
       ${child}   _Get Child Node Name   table_id=${table_id_common}   node_num=${i+1}
       ${select_status}   ${package_name}   run keyword and ignore error   selenium_netact.get_elem_text
       ...  elem_xpath=//div[@id='${table_id_common}']/table[${i+1}]/tbody/tr/td[3]/${child}
       EXIT FOR LOOP IF  '${select_status}'=='FAIL'
       Append To List   ${common_package_list}   ${package_name.strip()}
    END
    Wait Until Keyword Succeeds  5 times   2s   selenium_netact.move_to_element
    ...   elem_xpath=//*[@id="embTreeFrm:swTree:#REGULAR__PACKAGES#:${release}::remoteRepositoryTreeNode:handle:img:expanded"]
    Wait Until Keyword Succeeds  5 times   2s   selenium_netact.click_button
    ...   button_xpath=//*[@id="embTreeFrm:swTree:#REGULAR__PACKAGES#:${release}::remoteRepositoryTreeNode:handle:img:expanded"]
    sleep   1s
    [Return]   ${common_package_list}



_Get Child Node Name
    [Arguments]   ${table_id}   ${node_num}
    ${first_node}   Set Variable   //div[@id='${table_id}']/table[${node_num}]/tbody/tr/td[3]/
    ${span_match}   Run Keyword and Return Status   selenium_netact.get_elem_text   elem_xpath=${first_node}span
    ${node_name}   Run Keyword If   ${span_match}   Set Variable   span   ELSE   Set Variable   label
    [Return]   ${node_name}

Upload Image to NetAct
    [Arguments]   ${file_path}   ${version}
    ${is_common}   run keyword and return status   should contain   ${version}   SBTS
    ${version_name}   set variable if   ${is_common}   ${version}   AirScale-${version}
    Log to console   Start upload package ${version_name}
    Run Keyword If   '${netact_nodeip}' in ${upload_ssh_allow}   Upload Package to NetAct Server by Console
    ...   file_path=${file_path}   version=${version_name}
    ...   ELSE    Upload NetAct image   file_path=${file_path}

Upload Package to NetAct Server by Console
    [Arguments]   ${file_path}   ${version}
    log to console   Start Upload Package to NetAct Server by Console
    ${output}   Run   ssh-keygen -f "/home/ute/.ssh/known_hosts" -R "${netact_nodeip}"
    ${command_part}   set variable  sshpass -p ${NetAct_ssh_password} scp /home/ute/${version}.zip
    ${upload_command}   set variable  ${command_part} ${NetAct_ssh_user}@${netact_nodeip}:/d/oss/global/swmanager/swm_temp/${version}.zip
    Run    ${upload_command}
    log to console   Upload to Server Done and Start to Import ${version}.zip
    csn.connect_to    hostname=${netact_nodeip}   username=${NetAct_ssh_user}   password=${NetAct_ssh_password}    alias=netact
    csn.Execute    command=cd /d/oss/global/swmanager/swm_temp/;chmod 777 ${version}.zip   timeout=600   connection=netact
    ${Return_Status}   csn.Execute    command=cd /d/oss/global/swmanager/swm_temp/;swmCLI.sh import --file ${version}.zip --mo-type MRBTS
    ...   timeout=1200   connection=netact
#    should be equal   ${Return_Status}   ${version}\r\n
    wait until keyword succeeds   10min   30s   Check Package on NetAct Backend Quickly   ${version}   netact
    ${if_commonbuild}   run keyword and return status  should contain   ${version}   SBTS
    run keyword if   ${if_commonbuild}   sleep   5min
    wait until keyword succeeds   10min   30s   Check Package on NetAct Backend Quickly   ${version}   netact
    log to console   Import ${version}.zip Done
#    [Teardown]   run keyword and ignore error   csn.disconnect    connection=netact
    [Teardown]   run keywords
    ...   run keyword and ignore error   run keyword if  not ${if_commonbuild}   csn.Execute
    ...   command=rm -rf /d/oss/global/swmanager/swm_temp/${version}.zip   timeout=600   connection=netact
    ...   AND    run keyword and ignore error   csn.disconnect    connection=netact

Check Package on NetAct Backend Quickly
    [Arguments]  ${version}   ${alias}=netact
    ${is_commontrunk}   run keyword and return status   should contain   ${version}   SBTS00
    ${commontrunk_version}   run keyword if   ${is_commontrunk}   Split String    ${version}    _    1
    ${version_name}   set variable if   ${is_commontrunk}   ${commonBuild_trunk}_${commontrunk_version}[1]   ${version}
    ${output}   csn.Execute    command=cd /var/opt/nokia/oss/global/swm/swm_arch;ls -al | grep ${version_name}   timeout=60   connection=${alias}
    should contain   ${output}   ${version_name}

Check Package Exists on NetAct Backend
    [Arguments]  ${version}
    log to console   Check Package Exists on NetAct Backend
#    ${package_release}   Catch build release  ${version}
#    ${if_commonbuild}   run keyword and return status  should contain   ${package_release}   SBTS
    ${is_commontrunk}   run keyword and return status   should contain   ${version}   SBTS00
    ${commontrunk_version}   run keyword if   ${is_commontrunk}   Split String    ${version}    _    1
    ${version_name}   set variable if   ${is_commontrunk}   ${commonBuild_trunk}_${commontrunk_version}[1]   ${version}
    csn.connect_to    hostname=${netact_nodeip}   username=${NetAct_ssh_user}   password=${NetAct_ssh_password}    alias=netact_node
    run keyword and ignore error   csn.Execute    command=rm -rf /d/oss/global/swmanager/swm_temp/SBTS*   timeout=600   connection=netact_node
    ${output}   csn.Execute    command=cd /var/opt/nokia/oss/global/swm/swm_arch;ls -al | grep ${version_name}   timeout=60   connection=netact_node
    should contain   ${output}   ${version_name}
    [Teardown]  run keyword and ignore error   csn.disconnect    connection=netact_node
