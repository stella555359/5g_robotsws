*** Settings ***
Documentation     author: annie.hu
...               Group: HGZ_SG5
...               contact: annie.hu@nokia-sbell.com

Library                     String
Library                     OperatingSystem
Resource                    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/coam_resource.robot

*** Variables ***
${testpc_host}    ${host_addr}
${testpc_user}    ${host_username}
${testpc_pswd}    ${host_password}
${search_text}   	Operational state
#ssh gNB
${asik_addr}        ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${asik_username}    ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${asik_password}    ${tl.gnbs[0].cu.oam_ssh_connection_details.password}

${SW_build_path}    /home/ute/Downloads
${target_version}    
#${package_link}    https://artifactory-hz1.ext.net.nokia.com/artifactory/mnp5g-central-public-remote/System_Release
#${package_link}     https://artifactory-espoo1.int.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release
${package_link}     https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local/SBTS00_packages/
#${SBTS00_package_link}     https://artifactory-hz1.int.net.nokia.com/artifactory/mnpsbts-central-local/SBTS00_packages/
${SBTS00_package_link}     https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local/SBTS00_packages/
${SBTS21B_package_link}     https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local/SBTS21B_packages/
${SBTS22R1_package_link}     https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local/SBTS22R1_packages/
${SBTS22R2_package_link}     https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local/SBTS22R2_packages/
${SBTS22R3_package_link}     https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local/SBTS22R3_packages/
${SBTS22R4_package_link}     https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local/SBTS22R4_packages/
${SBTS23R1_package_link}     https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local/SBTS23R1_packages/
${package_version_1525-CA}      ${target_version}

*** Keywords ***
SWM supports provision SW build package via WebUI
    Set Test Variable    ${test_result}    ${False}
    Login WebUI
    Check current sw version 1
    Upgrade site with active
    Check SW version after upgrade
    Check sw update report
    Check site status
    Set Test Variable    ${test_result}    ${True}
    [Teardown]     run keyword if  not ${test_result}     cOAM Common Suite Teardown


Classical gNB Software Rollback successfully via WebUI
    Set Test Variable    ${test_result}    ${False}
    Login WebUI
    Check current sw version 2
    Perform rollback
    Confirm rollback success
    ENV recovery
    Check site status
    Set Test Variable    ${test_result}    ${True}
    [Teardown]     run keyword if  not ${test_result}     cOAM Common Suite Teardown



Get The Version link For Download
    [Documentation]     get the dwonload package link like planned/active/passive version
    [Arguments]    ${version_type}
    ${version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    ${result}    string.split string    string=${version}[${version_type}]    separator=_
    ${result1}    convert to integer    ${result}[-1]
    ${result2}    convert to integer    ${result}[-2]
    ${result3}    convert to integer    ${result}[-3]
    ${result4}     convert to string    ${result}[-5]
    set suite variable    ${result4}
    ${SW_vesion}    set variable      ${result3}.${result2}.${result1}
    ${target_version}=   Run Keyword If   "${result4}"=="SBTS21B"   
    ...     string.Replace String    ${version}[${version_type}]    21B    00
    ...     ELSE    Set Variable     ${SW_vesion}
    ${package_full_link}=   Run Keyword If    "${result4}"=="SBTS21B"
    ...   Set Variable    ${SBTS00_package_link}/${target_version}/${target_version}_release_BTSSM_downloadable_A54.zip   
    ...   ELSE     Set Variable     ${package_link}/${SW_vesion}/AirScale-${SW_vesion}.zip
    [Return]      ${version}    ${package_full_link}

Get link For Download from external value
    [Arguments]    ${version_type}
    ${version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
#    @{result}    string.split string    string=&{version}[${version_type}]    separator=_
    @{result}    string.split string    string=${package_version_1525-CA}    separator=_
    ${result5}     convert to string    ${result}[-5]
    ${if_SBTS21B}     convert to string    ${result}[-3]
    set suite variable    ${result5}
    set suite variable    ${if_SBTS21B}
    ${package_full_link}=   Run Keyword If   "${result5}"=="SBTS22R2" or "${result5}"=="SBTS22R3" and "${if_SBTS21B}"=="9999"
    ...   Set Variable     ${SBTS00_package_link}/${package_version_1525-CA}/${package_version_1525-CA}_release_BTSSM_downloadable_A54.zip  
    ...   ELSE IF    "${result5}"=="SBTS22R2" and "${if_SBTS21B}"=="0000"
    ...   Set Variable     ${SBTS22R2_package_link}/${package_version_1525-CA}/${package_version_1525-CA}_release_BTSSM_downloadable_A54.zip
    ...   ELSE IF    "${result5}"=="SBTS22R1" and "${if_SBTS21B}"=="0000"
    ...   Set Variable     ${SBTS22R1_package_link}/${package_version_1525-CA}/${package_version_1525-CA}_release_BTSSM_downloadable_A54.zip
    ...   ELSE IF    "${result5}"=="SBTS22R3" and "${if_SBTS21B}"=="0000"
    ...   Set Variable     ${SBTS22R3_package_link}/${package_version_1525-CA}/${package_version_1525-CA}_release_BTSSM_downloadable_A54.zip
    ...   ELSE IF    "${result5}"=="SBTS22R4" and "${if_SBTS21B}"=="0000"
    ...   Set Variable     ${SBTS22R4_package_link}/${package_version_1525-CA}/${package_version_1525-CA}_release_BTSSM_downloadable_A54.zip
    ...   ELSE IF    "${result5}"=="SBTS23R1" and "${if_SBTS21B}"=="0000"
    ...   Set Variable     ${SBTS23R1_package_link}/${package_version_1525-CA}/${package_version_1525-CA}_release_BTSSM_downloadable_A54.zip
    ...   ELSE    Set Variable     ${package_link}/${package_version_1525-CA}/AirScale-${package_version_1525-CA}.zip
    [Return]      ${package_full_link}

Download SW Build to VM
    [Arguments]    ${package_full_link}
    OperatingSystem.Empty Directory    ${SW_build_path}
    ${current_version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
#    @{result}    string.split string    string=&{current_version}[Active]    separator=_
    @{result}    string.split string    string=${package_version_1525-CA}    separator=_
    ${package_stream}     convert to string    ${result}[-5]
    set suite variable     ${package_stream}
    Run Keyword If
    ...    "${package_stream}"=="SBTS23R1" or "${package_stream}"=="SBTS22R1" or "${package_stream}"=="SBTS22R2" or "${package_stream}"=="SBTS22R3"
    ...             Run And Return Rc And Output    wget --no-proxy ${package_full_link}.sha256 -P ${SW_build_path}
    ...    ELSE     Run And Return Rc And Output    wget --no-proxy ${package_full_link}.md5 -P ${SW_build_path}
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

check the download completed
    [Arguments]    ${upgrade_package_path}    ${md5_value}
    ${sum}=        Set Variable     sha256sum ${upgrade_package_path}
    ${res}    ${output}    Run And Return Rc And Output    ${sum}
    ${res}    string.split string    ${output}
    should be equal    ${md5_value}    ${res}[0]

check sw version with external package value
    [Documentation]    this KW is to check the SW version when the download version is from the external value
    [Arguments]     ${check_version}
    WEBUI Login
    ${version}    wait until keyword succeeds    2min   15s    selenium_coam.check_current_software_version
    ${result}    string.split string    string=${version}[${check_version}]    separator=_
    ${version_now}     convert to string    ${result}[-5]
    ${SW_check}    convert to integer      ${result}[-1]
    ${if_SBTS00}     convert to string    ${result}[-3]

#    @{result}    string.split string     string=${package_version_1525-CA}    separator=.
    ${current_version}=   Run Keyword If   "${version_now}"=="SBTS22R2" and "${if_SBTS00}"=="9999"
    ...    string.Replace String    ${version}[${check_version}]    22R2    00
    ...    ELSE IF     "${version_now}"=="SBTS22R4" and "${if_SBTS00}"=="9999"
    ...    string.Replace String    ${version}[${check_version}]    22R4    00
    ...    ELSE IF    "${version_now}"=="SBTS22R3" or "${version_now}"=="SBTS23R1" or "${version_now}"=="SBTS22R4" and "${if_SBTS00}"=="0000"
    ...    Set Variable    ${version['${check_version}']}
    Run Keyword If   "${version_now}"=="SBTS22R2" or "${version_now}"=="SBTS22R3" or "${version_now}"=="SBTS23R1"
    ...    should be equal    "${current_version}"    "${package_version_1525-CA}"
    ...    ELSE    should be equal    "${SW_check}"    "${result}[-1]"

    [Return]    ${version}

check sw version without external package value
    [Documentation]    cp_b4 and after should be Planned/Active/Passive
    [Arguments]      ${version_b4}    ${cp_b4}    ${cp_after}
    ${version}    wait until keyword succeeds    1min    10s    selenium_coam.check_current_software_version
    should be equal      ${version_b4}[${cp_b4}]    ${version}[${cp_after}]

Download package to site
    [Documentation]    the input value should be False or Ture
    [Arguments]    ${if_active}    ${upgrade_package_path}
    wait until keyword succeeds    2min    10s    WEBUI Login
    ${result}    selenium_coam.load_software_package_from_local_drive    ${upgrade_package_path}
    should be equal      ${result}    software package load success
    selenium_coam.software_update     is_activate=${if_active}
    sleep    15s

check SW download progress finished
    ${result}    selenium_coam.check_software_update_progress
    should be equal    ${result}[status]    Download completed
    should be equal    ${result}[percentage]    100%

check reset progress when same as active version
    [Documentation]    this KW is to check the reset status when the upgrade package is same as active version
    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    ${result}    selenium_coam.check_software_update_progress
    should be equal    ${result}[status]     Activation completed
    #should be equal    &{result}[percentage]     100% completed

check site reset actually finished
    [Documentation]    this KW is to check the reset status when site will reset actually
    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    ${result}    selenium_coam.check_software_update_progress
    should be empty    ${result}[status]
    should be equal    ${result}[percentage]     0% completed

check board and cell status
    Check ABIL is UP
    Check ASIK is UP
    Check Cell is UP

check the update report
    Wait Until Keyword Succeeds    2min    10s    WEBUI Login
    #run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    #Run Keyword and Ignore Error    selenium_coam.refresh_page
    sleep    3s
    #${is_startup_window_exist}=    Run Keyword And Ignore Error    selenium_coam.start_up_view_window_exists
    #Run Keyword If   '${is_startup_window_exist[-1]}'=='True'    Run Keyword And Ignore Error    
    #...    selenium_coam.close_start_up_view_window
    #sleep    10s
    ${sw_update_report}    selenium_coam.save_sw_update_report
    OperatingSystem.File Should Exist     ${sw_update_report}
    OperatingSystem.Copy File    ${sw_update_report}     ${SW_build_path}
    ${file_path}    ${file_name}    OperatingSystem.split path    ${sw_update_report}
    ${sw_update_report_content}    OperatingSystem.get file    ${SW_build_path}/${file_name}
    csn.Connect to    ${host_addr}    ${host_username}    ${host_password}    alias=TESTPC
    csn.send command    command=cat ${SW_build_path}/${file_name} |grep -n "Started Software Build Download" |tail -1 |cut -d ":" -f1
    ...    connection=TESTPC
    ${output}    csn.read output    connection=TESTPC
    ${line_number}    convert to integer   ${output}
    csn.send command    command=tail -n \+${line_number} ${SW_build_path}/${file_name}    connection=TESTPC
    ${output}    csn.read output    connection=TESTPC
    should not contain any    ${output}    error    failed
    csn.disconnect    connection=TESTPC

rollback site
    selenium_coam.software_rollback
    selenium_coam.disable_screen_lock
    wait until keyword succeeds    18min    10s    check site reset actually finished
    Run Keyword And Ignore Error    wait until keyword succeeds    2min    15s     WEBUI Logout
	sleep   300s
    #Run Keyword And Ignore Error    run process    taskkill /f /im firefoxdriver.exe    shell=True
    #Run Keyword And Ignore Error    run process    ps -ef|grep firefox | awk '{print $2}' |xargs kill -9    shell=True
    Run Keyword And Ignore Error    wait until keyword succeeds    2min    10s    WEBUI Login
    Run Keyword And Ignore Error    wait until keyword succeeds    15min    20s    check board and cell status
    #selenium_coam.enable_screen_lock

case_setup
     wait until keyword succeeds    2min    15s     WEBUI Login
     ${version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
     ${active_version_b4}    set variable      ${version}[Active]
     set suite variable    ${active_version_b4}
     Run Keyword And Ignore Error    wait until keyword succeeds    2min    10s    WEBUI Logout

case_teardown
    run keyword and ignore error    WEBUI Logout
    wait until keyword succeeds    2min    15s     WEBUI Login
    ${version_current}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    ${current_active_version}     set variable      ${version_current}[Active]
    run keyword if      '${active_version_b4}' != '${current_active_version}'    rollback site
    Run Keyword And Ignore Error    wait until keyword succeeds    2min    15s     WEBUI Logout
    #Run Keyword And Ignore Error    run process    taskkill /f /im firefoxdriver.exe    shell=True
    #Run Keyword And Ignore Error    run process    ps -ef|grep firefox | awk '{print $2}' |xargs kill -9    shell=True

Check if Airscal Upgrade Successfully
    ${If_SBTS00}    Run Keyword and Ignore Error    should contain    ${package_version_1525-CA}    SBTS00
    #${If_SBTS22R1}    Run Keyword and Ignore Error    should contain    ${package_version_1525-CA}    SBTS22R1
    run keyword if     '${If_SBTS00[0]}' == 'PASS'       Check Common Load Version
    #...    ELSE IF   '${If_SBTS22R1[0]}' == 'PASS'        Check 22R1 Version
    ...    ELSE      Check Normal Gnb Version
    csn.reset_cache

Check Common Load Version
    csn.reset_cache
    csn.Connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=asik
    csn.send_command    command=ls /ffs/run/TargetBD*\.xml    connection=asik
    ${result}     csn.read_output    connection=asik
    ${str}=	    Remove String	    ${package_version_1525-CA}    SBTS00
    should contain    ${result}    ${str}
    csn.reset_cache

Check 22R1 Version
    csn.reset_cache
    csn.Connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=asik
    csn.send_command    command=ls /ffs/run/TargetBD*\.xml    connection=asik
    ${result}     csn.read_output    connection=asik
    should contain    ${result}    ${package_version_1525-CA}
    csn.reset_cache

Check Normal Gnb Version
    csn.reset_cache
    csn.Connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=asik
    csn.send_command    command=ls /ffs/run/TargetBD*\.xml    connection=asik
    ${result}     csn.read_output    connection=asik
    @{version}    string.split string    string=${package_version_1525-CA}   separator=.
    #Should Match Regexp	       ${result}	    \\d*${version[0]}_\\d*${version[1]}_\\d*${version[2]}
    should contain    ${result}    ${package_version_1525-CA}
    csn.reset_cache


Login WebUI
    log to console    Login WebUI
    Wait Until Keyword Succeeds    2min    10s    WEBUI Login    ${TRUE}

Check current sw version 1
    log to console   check current sw version 1
    ${pre_active_version_1}    wait until keyword succeeds    1min    10s    check SW version    Active
    set suite variable    ${pre_active_version_1}
    sleep    5s

Check current sw version 2
    log to console    check current sw version 2
    ${output}    ${version}    wait until keyword succeeds    1min    10s    check SW version    Active
    ${pre_active_version_2}    set variable    ${output}
    set suite variable    ${pre_active_version_2}
    ${pre_passive_version_2}    set variable    ${version}[Passive]
    set suite variable    ${pre_passive_version_2}
    sleep    5s

Upgrade site with active
    log to console    upgrade site with active
    csn.Connect to    hostname=${testpc_host}    username=${testpc_user}    password=${testpc_pswd}    alias=TESTPC
    ${package_full_link}    Get link For Download from external value      version_type=Active
    ${upgrade_package_path}    Download SW Build to VM     package_full_link=${package_full_link}
    set suite variable    ${upgrade_package_path}
    csn.disconnect    connection=TESTPC
    wait until keyword succeeds     5 min   10 sec
    ...     coam.connect to       bts_host=${asik_addr}     name=coam_admin
    coam.update_software    sw_package=${upgrade_package_path}    timeout=7200    connection=coam_admin
    #sleep    5s
    #run keyword and ignore error     selenium_coam.disable_screen_lock
    #sleep    2s
    #Download package to site    if_active=${True}    upgrade_package_path=${upgrade_package_path}

Perform rollback
    log to console    execute rollback
    run keyword and ignore error     selenium_coam.disable_screen_lock
    wait until keyword succeeds    1min    10s    selenium_coam.software_rollback
    sleep    5min

Check SW version after upgrade
    log to console    check SW version after upgrade
    wait until keyword succeeds     40min    2min    Check if Airscal Upgrade Successfully
#    check if SW upgrade success

Confirm rollback success
    log to console    confirm rollback success
    ${test_result}    Run Keyword And Return Status    wait until keyword succeeds    15min    1min    check if rollback success
    sleep    5s

Check sw update report
    log to console    check sw update report
    wait until keyword succeeds    10min    1min    check the update report

ENV recovery
    log to console    ENV recovery
    run keyword if    "${test_result}"=="FAIL"    Perform rollback

Check site status
    log to console    check site status
    wait until keyword succeeds    40min    2min    check board and cell status
    run keyword and ignore error     selenium_coam.enable_screen_lock

Logout webui
    log to console    logout webui
    run keyword and ignore error    WEBUI Logout    virtual_disable=${TRUE}

Check if SW upgrade success
    ${update_result}    ${version}    run keyword and ignore error    check sw version with external package value    check_version=Active
    set suite variable    ${update_result}
    ${result_2}    should match regexp    ${version}[Planned]    ${EMPTY}

Check if rollback success
    ${output}    ${version}    wait until keyword succeeds    1min    10s    check SW version    Active
    should match regexp    ${output}    ${pre_passive_version_2}
    sleep    5s
    should match regexp    ${version}[Passive]    ${pre_active_version_2}
    sleep    5s
    should match regexp    ${version}[Planned]    ${EMPTY}
    sleep    5s
