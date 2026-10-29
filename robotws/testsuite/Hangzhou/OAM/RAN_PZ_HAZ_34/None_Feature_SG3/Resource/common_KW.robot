*** Settings ***
Documentation     author: jack.zeng
...               Group: HGZ_SG3
...               contact: jack.zeng@nokia-sbell.com

Library                     String
Library                     OperatingSystem
Resource                    ${CURDIR}/../../common/coam_resource.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Resources.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource    SG3_TMO_common_keywords.robot
Resource    UUF_Sleep_cell_check.robot
Resource    Common_setup_and_teardown.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_calculation_common_keywords.robot
Library     taf.rfrl.common_resources.python.SWConfig
Resource          ../../common/coam_resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.sbts.oam.coam.admin   WITH NAME   coam
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/upgrade_rollback_keywords.robot
Library       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/upgrade_rollback_keywords.py

*** Variables ***
${SW_build_path}    /home/ute/Downloads
${target_version}
#${package_link}    https://artifactory-hz1.ext.net.nokia.com/artifactory/mnp5g-central-public-remote/System_Release
#${package_link}     https://artifactory-espoo1.int.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release
${package_link}     https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build/
#${SBTS00_package_link}     https://artifactory-hz1.int.net.nokia.com/artifactory/mnpsbts-central-local/SBTS00_packages/
${SBTS00_package_link}     https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local/SBTS00_packages/
${SBTS21B_package_link}     https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local/SBTS21B_packages/
${SBTS22R1_package_link}     https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local/SBTS22R1_packages/
${SBTS22R2_package_link}     https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local/SBTS22R2_packages/
${SBTS22R3_package_link}     https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local/SBTS22R3_packages/
${package_version_1525-CA}      ${target_version}
${testpc_host}    ${host_addr}
${testpc_user}    ${host_username}
${testpc_pswd}    ${host_password}
${search_text}   	Operational state
#ssh gNB
${asik_addr}        ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${asik_username}    ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${asik_password}    ${tl.gnbs[0].cu.oam_ssh_connection_details.password}

*** Keywords ***
SWM supports provision SW build package via WebUI
    Set Test Variable    ${test_result}    ${False}
    step1:Login WebUI
    step2:check current sw version 1
    step3:upgrade site with active
    step4:check SW version after upgrade
    #step5:check sw update report
    step6:check site status
#    UUF_Sleep_cell_check.Adjust gNB_RU Attenuation for L3_call
#    UUF_Sleep_cell_check.Start_L3_call_and_check_Tput
    Set Test Variable    ${test_result}    ${True}
#    [Teardown]     run keyword if  not ${test_result}     Common Suite Teardown for UUF
    [Teardown]    Run Keyword If    '${KEYWORD STATUS}' == 'FAIL'    Run keyword and continue on failure
    ...    COAM Save all gnb snapshot via api    gnb_list=${gnb_list}    log_path=${epc_log_path}


Classical gNB Software Rollback successfully via WebUI
    Set Test Variable    ${test_result}    ${False}
    step1:Login WebUI
    step2:check current sw version 2
    step3:execute rollback
    #step4:confirm rollback success
    step5:ENV recovery
    step6:check site status
    Set Test Variable    ${test_result}    ${True}
#    [Teardown]     run keyword if  not ${test_result}     Common Suite Teardown for UUF
    [Teardown]    Run Keyword If    '${KEYWORD STATUS}' == 'FAIL'    Run keyword and continue on failure
    ...    COAM Save all gnb snapshot via api    gnb_list=${gnb_list}    log_path=${epc_log_path}

Common Suite Teardown for UUF
   Set Test Variable    ${SUITE STATUS}    FAIL
   run keyword and ignore error    Common Suite Teardown for COAM
#   SG3_TMO_common_keywords.Connect and save snapshot for enb    enb_index=${0}
#   SG3_TMO_common_keywords.Connect and save snapshot for enb    enb_index=${1}
   #Connect and save snapshot for enb    enb_index=${1}

step1:Login WebUI
    log to console    step1:Login WebUI
    Wait Until Keyword Succeeds    2min    10s    WEBUI Login    ${TRUE}

step2:check current sw version 1
    log to console   step2:check current sw version 1
    ${pre_active_version_1}    wait until keyword succeeds    1min    10s    check SW version    Active
    set suite variable    ${pre_active_version_1}
    sleep    5s

step2:check current sw version 2
    log to console    step2:check current sw version 2
    ${output}    ${version}    wait until keyword succeeds    1min    10s    check SW version    Active
    ${pre_active_version_2}    set variable    ${output}
    set suite variable    ${pre_active_version_2}
    ${pre_passive_version_2}    set variable    ${version}[Passive]
    set suite variable    ${pre_passive_version_2}
    sleep    5s


step3:upgrade site with active
    log to console    step3:upgrade site with active
    set suite variable    ${upgrade_package_path}    ${SW_build_path}/${target_version}_release_BTSSM_downloadable_A54.zip
    csn.Connect to    hostname=${testpc_host}    username=${testpc_user}    password=${testpc_pswd}    alias=TESTPC
    ${status}    run keyword and return status   OperatingSystem.File Should Exist    ${upgrade_package_path}
    run keyword if  not ${status}     download_upgrade_package
    csn.disconnect    connection=TESTPC
    wait until keyword succeeds     5 min   10 sec
    ...     coam.connect to       bts_host=${asik_addr}     name=coam_admin
    coam.update_software    sw_package=${upgrade_package_path}    timeout=7200    connection=coam_admin
    #sleep    5s
    #run keyword and ignore error     selenium_coam.disable_screen_lock
    #sleep    2s
    #Download package to site    if_active=${True}    upgrade_package_path=${upgrade_package_path}

download_upgrade_package
    [Arguments]    ${download_path}=/home/ute/Downloads/
    log to console    SW package does not exist in ute server
#    ${package_full_link}    Get link For Download from external value
#    ${upgrade_package_path}    Download SW Build to VM     package_full_link=${package_full_link}
    download_release_build
    ...    release_url=${package_link}
    ...    release_name=${target_version}
    ...    download_path=${download_path}

step3:execute rollback
    [Arguments]    ${node_type}=gnb    ${index}=${0}    ${connection}=${node_type}_${index}
    upgrade_rollback_keywords.login    node_type=${node_type}    connection=${connection}    gnb_index=${index}    enb_index=${index}
    Log to console    1.check current version
    upgrade_rollback_keywords.Get current version to check    connection=${connection}
    Log to console    2.rollback
    sleep    30s
    upgrade_rollback_keywords.rollback_build    connection=${connection}
    sleep    1min
    Log to console    3. check version after rollback
    wait until keyword succeeds     40min    2min    upgrade_rollback_keywords.Check if rollback Successfully
    ...    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    upgrade_rollback_keywords.tearDown for logout    connection=${connection}

step4:check SW version after upgrade
    log to console    step4:check SW version after upgrade
    wait until keyword succeeds     40min    2min    Check if Airscal Upgrade Successfully
    ##[Teardown]    check if SW upgrade success

step4:confirm rollback success
    log to console    step4:confirm rollback success
    wait until keyword succeeds    15min    1min    check if rollback success
    sleep    5s

step5:check sw update report
    log to console    step5:check sw update report
    wait until keyword succeeds    10min    1min    check the update report

step5:ENV recovery
    log to console    step5:ENV recovery
    ##run keyword if    "${update_result}"=="FAIL"    step3:execute rollback

step6:check site status
    log to console    step6:check site status
    wait until keyword succeeds    30min    2min    check board and cell status
    wait until keyword succeeds    10min    2min    Verify TMO Gnb Ready And All Cell On Air
    run keyword and ignore error     selenium_coam.enable_screen_lock

step7:logout webui
    log to console    step7:logout webui
    run keyword and ignore error    WEBUI Logout    virtual_disable=${TRUE}

check if SW upgrade success
    ${update_result}    ${version}    run keyword and ignore error    check sw version with external package value    check_version=Active
    set suite variable    ${update_result}
    ${result_2}    should match regexp    ${version}[Planned]    ${EMPTY}

check if rollback success
    ${output}    ${version}    wait until keyword succeeds    1min    10s    check SW version    Active
    should match regexp    ${output}    ${pre_passive_version_2}
    sleep    5s
    should match regexp    ${version}[Passive]    ${pre_active_version_2}
    sleep    5s
    should match regexp    ${version}[Planned]    ${EMPTY}
    sleep    5s

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

Get link For Download from external value from current SW version
    [Arguments]    ${version_type}
    ${version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    ${result}    string.split string    string=${version}[${version_type}]    separator=_
    ${result5}     convert to string    ${result}[-5]
    ${if_SBTS21B}     convert to string    ${result}[-3]
    set suite variable    ${result5}
    set suite variable    ${if_SBTS21B}
    ${package_full_link}=   Run Keyword If   "${result5}"=="SBTS22R4" and "${if_SBTS21B}"=="9999"
    ...   Set Variable     ${SBTS00_package_link}/${package_version_1525-CA}/${package_version_1525-CA}_release_BTSSM_downloadable_A54.zip
    ...   ELSE IF    "${result5}"=="SBTS21B" and "${if_SBTS21B}"=="0000"
    ...   Set Variable     ${SBTS21B_package_link}/${package_version_1525-CA}/${package_version_1525-CA}_release_BTSSM_downloadable_A54.zip
    ...   ELSE IF    "${result5}"=="SBTS22R1" and "${if_SBTS21B}"=="0000"
    ...   Set Variable     ${SBTS22R1_package_link}/${package_version_1525-CA}/${package_version_1525-CA}_release_BTSSM_downloadable_A54.zip
    ...   ELSE IF    "${result5}"=="SBTS22R2" and "${if_SBTS21B}"=="0000"
    ...   Set Variable     ${SBTS22R2_package_link}/${package_version_1525-CA}/${package_version_1525-CA}_release_BTSSM_downloadable_A54.zip
    ...   ELSE IF    "${result5}"=="SBTS22R3" and "${if_SBTS21B}"=="0000"
    ...   Set Variable     ${SBTS22R3_package_link}/${package_version_1525-CA}/${package_version_1525-CA}_release_BTSSM_downloadable_A54.zip
    ...   ELSE    Set Variable     ${package_link}/${package_version_1525-CA}/AirScale-${package_version_1525-CA}.zip
    [Return]      ${package_full_link}

Get link For Download from external value
    @{result}    string.split string    string=${target_version}    separator=_
    ${result5}     convert to string    ${result}[-5]
    ${if_SBTS21B}     convert to string    ${result}[-3]
    set suite variable    ${result5}
    set suite variable    ${if_SBTS21B}
    ${package_full_link}    Set Variable    ${package_link}${result5}/${target_version}/${target_version}_release_BTSSM_downloadable_A54.zip
    [Return]      ${package_full_link}

Download SW Build to VM
    [Arguments]    ${package_full_link}
    OperatingSystem.Empty Directory    ${SW_build_path}
#    ${current_version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
#    @{result}    string.split string    string=&{current_version}[Active]    separator=_
#    ${package_stream}     convert to string    @{result}[-5]
#    set suite variable     ${package_stream}
#    Run Keyword If
#    ...    "${package_stream}"=="SBTS21B" or "${package_stream}"=="SBTS22R1" or "${package_stream}"=="SBTS22R2" or "${package_stream}"=="SBTS22R3"
#    ...             Run And Return Rc And Output    wget --no-proxy ${package_full_link}.sha256 -P ${SW_build_path}
#    ...    ELSE     Run And Return Rc And Output    wget --no-proxy ${package_full_link}.md5 -P ${SW_build_path}
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
    @{results}    string.split string     string=${package_version_1525-CA}    separator=.
    ${current_version}=   Run Keyword If   "${version_now}"=="SBTS22R3" and "${if_SBTS00}"=="9999"
    ...    string.Replace String    ${version}[${check_version}]    22R3    00
    ...    ELSE IF     "${version_now}"=="SBTS22R4" and "${if_SBTS00}"=="9999"
    ...    string.Replace String    ${version}[${check_version}]    22R4    00
    ...    ELSE IF    "${version_now}"=="SBTS21B" or "${version_now}"=="SBTS22R1"
    ...    or "${version_now}"=="SBTS22R2"  or "${version_now}"=="SBTS22R3" and "${if_SBTS00}"=="0000"
    ...    Set Variable    ${version['${check_version}']}
    Run Keyword If   "${version_now}"=="SBTS22R2" or "${version_now}"=="SBTS22R3" or "${version_now}"=="SBTS22R4"
    ...    or "${version_now}"=="SBTS22R1"
    ...    should be equal    "${current_version}"    "${package_version_1525-CA}"
    ...    ELSE    should be equal    "${SW_check}"    "${results}[-1]"
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
    #Check Cell is UP

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
    run keyword if     '${If_SBTS00[0]}' == 'PASS'       Check Common Load Version
    ...    ELSE      Check 21B Version
    csn.reset_cache

Check Common Load Version
    csn.reset_cache
    csn.Connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=asik
    csn.send_command    command=ls /ffs/run/TargetBD*\.xml    connection=asik
    ${result}     csn.read_output    connection=asik
    ${str}=	    Remove String	    ${package_version_1525-CA}    SBTS00
    should contain    ${result}    ${str}
    csn.reset_cache

Check 21B Version
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
    @{version}    string.split string    string=${package_version_1525-CA}   separator=-
    Should Match Regexp	       ${result}	    \\d*${version[0]}_\\d*${version[1]}_\\d*${version[2]}
    csn.reset_cache

test_case_setup
    [Documentation]    Author: tingting.1.liu@nokia-sbell.com
    [Arguments]    ${allowed_faults_ids}=NULL
    robot_common_operations.Common Case Setup    allowed_faults_ids=${allowed_faults_ids}
    Common_setup_and_teardown.Common Case Setup
    Wait Until Keyword Succeeds    5 min    5 sec    connection_alias_store.Connect to Common Unit Master
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    ${LTE_CELL_LIST}    Verify Gnb Type Cells Should Be Onair    cell_type=lte
    Set Test Variable    ${LTE_CELL_LIST}
    COAM Create log directory
    COAM Wait For Gnb Ready And Cell Setup    timeout=15 min
#    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=@{ALLOWED_FAULT}
    run keyword and ignore error    COAM Teardown gnb connections


Modify UUF Swconfig File
    [Documentation]   tingting.1.liu@nokia-sbell.com
    [Arguments]    ${para_update}    ${local_path}=${TS_LOG_PATH_BASE}
    Run    rm ${local_path}/swconfig*
    csn.Connect to     hostname=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...                username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...                password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...                alias=ASIK Master
    csn.send command    command=cp /ffs/run/swconfig.txt /ffs/run/swconfig.txt.bak   connection=ASIK Master
    swconf.Download swConfig file from asik to test pc    localFilePath=${local_path}/swconfig.txt
    ...                                                   asik_alias=ASIK Master
    ...                                                   remoteFilePath=/ffs/run/swconfig.txt
    FOR   ${swconfig}   IN   @{para_update}
        ${config_id}    should match regexp     ${swconfig}    .*?(?==)
        Run   sed -i -e '/${config_id}.*=.*/'d ${local_path}/swconfig.txt
    END
    swconf.Modify swConfig file    parametersList=${para_update}    filePath=${local_path}/swconfig.txt
    swconf.Upload swConfig file to asik and crasign    localFilePath=${local_path}/swconfig.txt
    ...                                                asik_alias=ASIK Master
    run keyword and ignore error  csn.disconnect    connection=ASIK Master

Check_UUF_gNB_Startup_log
    [Documentation]   tingting.1.liu@nokia-sbell.com
    csn.Connect to     hostname=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...                username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...                password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...                alias=ASIK Master
    ${startup_command} =    set variable    cat /tmp/startup_BTSOM.log |grep -i 'startService loading from hwf is disabled'
    ${startup_xz_command} =  set variable
    ...       xzcat /ffs/run/logs/fct-0a_aasyslog/startup_BTSOM.log.xz |grep -i 'startService loading from hwf is disabled'
    ${startup_log} =    Check Startup Defualt Log On ASIK
    ...    startup_cmd=${startup_command}    startup_xz_cmd=${startup_xz_command}    info=startService loading from hwf is disabled
    run keyword and ignore error  csn.disconnect    connection=ASIK Master

Check_btslog_After_Reset
    [Documentation]   tingting.1.liu@nokia-sbell.com
    [Arguments]   ${log_path}
    ${bts_gz_command1} =  set variable
        ...   gunzip -c ${log_path} |grep -i 'CELL NOTIFICATION 4329 Radio memory consumption exceeds abnormal threshold'
	${bts_gz_command2} =  set variable   gunzip -c ${log_path} |grep -i 'FaultId: 4329'
	${bts_gz_command3} =  set variable   gunzip -c ${log_path} |grep -i 'FaultId: 4330'
	${bts_gz_command4} =  set variable   gunzip -c ${log_path} |grep -i 'Detector 4329'
	${bts_gz_command5} =  set variable   gunzip -c ${log_path} |grep -i 'Detector 4330'
	${bts_gz_command6} =  set variable   gunzip -c ${log_path} |grep -i 'active 4329'
	${bts_gz_command7} =  set variable   gunzip -c ${log_path} |grep -i 'active 4330'
	${bts_gz_command8} =  set variable
	   ...   gunzip -c ${log_path} |grep -i '4230 Radio memory consumption exceeds critical threshold'
	${common_list}    create list   ${bts_gz_command1}  ${bts_gz_command2}  ${bts_gz_command3}  ${bts_gz_command4}
	...                             ${bts_gz_command5}  ${bts_gz_command6}  ${bts_gz_command7}  ${bts_gz_command8}
	${status_list}    create list
	FOR   ${common}   IN   @{common_list}
	    ${offline_output}   RUN    ${common}
	    ${status}    run keyword and return status    should be empty    ${offline_output}    Syslog Crash verification failed
	    Append To List    ${status_list}    ${status}
	END
	list should not contain value    ${status_list}    ${False}

LTE_Cell_Lock_Unlock_On_Gnb
    [Documentation]   tingting.1.liu@nokia-sbell.com
    ...       ${cell_status}:value can be "locked"  or "unlocked"
    [Arguments]    ${cell_status}   ${timeout}=${300}   ${connection}=GNB_OAM   ${enb_index}=${0}
    ...            ${enb_connection}==enblte_${enb_index}   ${gnb_id}=0   ${cell_type}=lte
    Log To Console   perform cell ${cell_status}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_id}
    Run Keyword If  '${enb_length}'!='${0}'   Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${cell_info_lte_on_gnb}   Run Keyword If  '${enb_length}'=='${0}'    coam.get_cells_info   cell_type=${cell_type}
                                                            ...   connection=${connection}     timeout=${timeout}
    ${cell_info_lte_on_enb}   Run Keyword If  '${enb_length}'!='${0}'    coam.get_cells_info   cell_type=${cell_type}
                                                            ...   connection=${enb_connection}  timeout=${timeout}
    ${cell_info_lte}   Set Variable If  '${enb_length}'=='${0}'   ${cell_info_lte_on_gnb}    ${cell_info_lte_on_enb}
    &{cell_list_info}    Create Dictionary
    FOR    ${item}    IN    @{cell_info_lte}
        Set To Dictionary    ${cell_list_info}    ${item['id']['configuration']}=${item['status']}
    END
    ${cell_list}    Get Dictionary Keys    ${cell_list_info}
    @{params_for_update}    Create List
    FOR   ${cell_dist_name}    IN     @{cell_list}
         ${param}    Create Dictionary    dist_name=${cell_dist_name}    parameter=administrativeState    value=${cell_status}
         Append To List    ${params_for_update}    ${param}
    END
    Run Keyword If     '${enb_length}'=='${0}'    COAM Update several parameters via rest api
                     ...    parameters_to_update_via_api=${params_for_update}    timeout=${timeout}   connection=${connection}
    Run Keyword If     '${enb_length}'!='${0}'    COAM Update several parameters via rest api
                     ...    parameters_to_update_via_api=${params_for_update}    timeout=${timeout}   connection=${enb_connection}
    Run Keyword If    '${cell_status}'=='locked' and '${enb_length}'=='${0}'    Wait Until Keyword Succeeds    120 sec    3 sec
          ...     Verify LTE Cell status Should Be locked    timeout=${timeout}   connection=${connection}  cell_type=${cell_type}
    Run Keyword If    '${cell_status}'=='unlocked' and '${enb_length}'=='${0}'  Wait Until Keyword Succeeds    120 sec    3 sec
          ...     Verify LTE Cell status Should Be Unlocked   timeout=${timeout}  connection=${connection}  cell_type=${cell_type}
    Run Keyword If    '${cell_status}'=='locked' and '${enb_length}'!='${0}'    Wait Until Keyword Succeeds    120 sec    3 sec
          ...     Verify LTE Cell status Should Be locked    timeout=${timeout}   connection=${enb_connection}  cell_type=${cell_type}
    Run Keyword If    '${cell_status}'=='unlocked' and '${enb_length}'!='${0}'  Wait Until Keyword Succeeds    120 sec    3 sec
          ...     Verify LTE Cell status Should Be Unlocked   timeout=${timeout}  connection=${enb_connection}  cell_type=${cell_type}
    [Teardown]    run keywords   Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}  AND
    ...      Run Keyword If  '${enb_length}'!='${0}'   Run Keyword And Ignore Error    Enblte close down    connection=${enb_connection}

Verify LTE Cell status Should Be Unlocked
    [Documentation]   tingting.1.liu@nokia-sbell.com
    [Arguments]     ${timeout}=10   ${connection}=GNB_OAM   ${enb_index}=${0}   ${enb_connection}==enblte_${enb_index}   #${gnb_id}=0
    ...             ${cell_type}=lte
#    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl   connection=${connection}   gnb_index=${gnb_id}
#    Run Keyword If  '${enb_length}'!='${0}'   Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${cell_info_lte_on_gnb}   Run Keyword If  '${enb_length}'=='${0}'    coam.get_cells_info   cell_type=${cell_type}   timeout=${timeout}
                                                            ...   connection=${connection}
    ${cell_info_lte_on_enb}   Run Keyword If  '${enb_length}'!='${0}'    coam.get_cells_info   cell_type=${cell_type}   timeout=${timeout}
                                                            ...   connection=${enb_connection}
    ${cell_info_lte}   Set Variable If  '${enb_length}'=='${0}'   ${cell_info_lte_on_gnb}    ${cell_info_lte_on_enb}
    &{cell_list_info}    Create Dictionary
    FOR    ${item}    IN    @{cell_info_lte}
        Set To Dictionary    ${cell_list_info}    ${item['id']['configuration']}=${item['status']}
    END
    ${cell_list}    Get Dictionary Keys    ${cell_list_info}
    ${sw_version}     coam.get_sw_version    connection=${connection}
    ${result}    run keyword and return status    should contain any
    ...    ${sw_version}
    ...    12.400    14.400    22R1    22R2    21B
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
    FOR  ${cell}  IN   @{cell_list}
        Run Keyword And Continue On Failure    Should Be Equal As Strings
                                    ...   ${cell_list_info['${cell}']['administrativeState']}    Unlocked
        Run Keyword And Continue On Failure    Should Be Equal As Strings
                                    ...   ${cell_list_info['${cell}']['availabilityStatus']}    Online
        Run Keyword And Continue On Failure    Should Be Equal As Strings
                                    ...   ${cell_list_info['${cell}']['operationalState']}    ${enabled}
    END
#    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}
#      Run Keyword If  '${enb_length}'!='${0}'   Run Keyword And Ignore Error    Enblte close down    connection=${enb_connection}

Verify LTE Cell status Should Be locked
    [Documentation]   tingting.1.liu@nokia-sbell.com
    [Arguments]     ${timeout}=10   ${connection}=GNB_OAM    ${enb_index}=${0}  ${enb_connection}==enblte_${enb_index}
    ...             ${cell_type}=lte
#    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_id}
#    Run Keyword If  '${enb_length}'!='${0}'   Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${cell_info_lte_on_gnb}   Run Keyword If  '${enb_length}'=='${0}'   coam.get_cells_info    cell_type=${cell_type}
                                                               ...   connection=${connection}   timeout=${timeout}
    ${cell_info_lte_on_enb}   Run Keyword If  '${enb_length}'!='${0}'   coam.get_cells_info   cell_type=${cell_type}
                                                               ...   connection=${enb_connection}  timeout=${timeout}
    ${cell_info_lte}   Set Variable If  '${enb_length}'=='${0}'   ${cell_info_lte_on_gnb}    ${cell_info_lte_on_enb}
    &{cell_list_info}    Create Dictionary
    FOR    ${item}    IN    @{cell_info_lte}
        Set To Dictionary    ${cell_list_info}    ${item['id']['configuration']}=${item['status']}
    END
    ${cell_list}    Get Dictionary Keys    ${cell_list_info}
    ${sw_version}     coam.get_sw_version    connection=${connection}
    ${result}    run keyword and return status    should contain any
    ...    ${sw_version}
    ...    12.400    14.400    22R1    22R2    21B
    ${disabled}    Set Variable If    ${result}    Disabled    disabled
    ${offline}    Set Variable If    ${result}    Offline    off line
    ${locked}    Set Variable If    ${result}    Locked    Locked
    FOR  ${cell}  IN   @{cell_list}
        Run Keyword And Continue On Failure    Should Be Equal As Strings
                                    ...   ${cell_list_info['${cell}']['administrativeState']}    ${locked}
        Run Keyword And Continue On Failure    Should Be Equal As Strings
                                    ...   ${cell_list_info['${cell}']['availabilityStatus']}    ${offline}
        Run Keyword And Continue On Failure    Should Be Equal As Strings
                                    ...   ${cell_list_info['${cell}']['operationalState']}    ${disabled}
    END
#    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}
#       Run Keyword If  '${enb_length}'!='${0}'   Run Keyword And Ignore Error    Enblte close down    connection=${enb_connection}
