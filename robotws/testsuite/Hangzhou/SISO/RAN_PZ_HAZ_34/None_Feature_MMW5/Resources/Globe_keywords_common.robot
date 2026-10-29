*** Settings ***
Documentation    Auther:xiaofei.zhao@nokia-sbell.com

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Common_setup_and_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_calculation_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/logs.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot

*** Variables ***
${BASIC_SCF}    globe_basic.xml

${SW_build_path}    /home/ute/Downloads
${target_version}
${package_link}     https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build/
${package_version_globe}      ${target_version}

*** Keywords ***
GlobeCommon_Suite_Setup
    [Documentation]    Author: jack.zeng@nokia-sbell.com
    [Arguments]    ${is_commission}=${False}
    ${stream_version}    gnb_classical_hangzhou.Get program version based on stream version
    Set Suite Variable    ${stream_version}
    # get how many UEs
    #${ue_length}    Get Length    ${tl.ues}
    Set Suite Variable    ${ue_length}     1
    # get tl_prefix, such as T813/T073
    Set Suite Variable    ${tl_prefix}    ${testline_name.split('_')[-1][-4:]}
    # get how many ENBs
    ${enb_length}    Get Length    ${tl.enbs}
    Set Suite Variable    ${enb_length}
    Common_setup_and_teardown.Common Suite Setup    scf_name=${tl_prefix}_${BASIC_SCF}    is_commission=${is_commission}
    Verify Gnb Ready And All Cell On Air
    Log to console    ${\n}----Verify all cells of enbs are on air----
    FOR    ${enb_id}    IN RANGE    ${enb_length}
        Wait until keyword succeeds    2 min    20 sec    Globe_keywords_common.Verify Enb All Cell On Air    enb_index=${enb_id}
    END
    sleep    5s

Globe Common Case Teardown
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]     ${is_save_snapshot}=True    ${is_save_snapshot_for_second_gnb}=False
    ...             ${connection}=GNB_OAM0    ${connection_for_second_gnb}=GNB_OAM1
    ...             ${timeout}=900    ${alais}=ASIK Master0    ${alais_for_second_gnb}=ASIK Master1
    Run Keyword If    ${is_save_snapshot}    run keywords
    ...    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${0}    AND
    ...    Connect to Common Unit Master    alias=${alais}    gnb_index=${0}    AND
    ...    Run Keyword And Ignore Error    csn.execute    command=killall tcpdump    connection=${alais}    AND
    ...    Run Keyword And Ignore Error    Run Keyword If Test Failed    COAM Save snapshot via rest api    connection=${connection}
    ...                                                                                                     timeout=${timeout}
    Run Keyword If    ${is_save_snapshot_for_second_gnb}    run keywords
    ...    Connect to gnb coam via ssl    connection=${connection_for_second_gnb}    gnb_index=${1}    AND
    ...    Connect to Common Unit Master    alias=${alais_for_second_gnb}    gnb_index=${1}    AND
    ...    Run Keyword And Ignore Error    csn.execute    command=killall tcpdump    connection=${alais_for_second_gnb}    AND
    ...    Run Keyword And Ignore Error    Run Keyword If Test Failed    COAM Save snapshot via rest api
    ...                                                                  connection=${connection_for_second_gnb}
    ...                                                                  timeout=${timeout}
    Run Keyword And Ignore Error    run    command=ps -ef | grep firefox |awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore Error    run    command=ps -ef | grep admin_api |awk '{print $2}' | xargs kill -9
    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}    AND
    ...    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection_for_second_gnb}    AND
    ...    Run Keyword And Ignore Error   csn.disconnect    connection=${alais}    AND
    ...    Run Keyword And Ignore Error   csn.disconnect    connection=${alais_for_second_gnb}    AND
    ...    csn.Reset Cache

Globe_Check_gNB_Startup_log
    [Documentation]   tingting.1.liu@nokia-sbell.com
    [Arguments]  ${connection}=GNB_OAM
    log    ${connection}
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

Globe_Check_btslog_After_Reset
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
	   ...   gunzip -c ${log_path} |grep -i '4330 Radio memory consumption exceeds critical threshold'
	${common_list}    create list   ${bts_gz_command1}  ${bts_gz_command2}  ${bts_gz_command3}  ${bts_gz_command4}
	...                             ${bts_gz_command5}  ${bts_gz_command6}  ${bts_gz_command7}  ${bts_gz_command8}
	${status_list}    create list
	FOR   ${common}   IN   @{common_list}
	    ${offline_output}   RUN    ${common}
	    ${status}    run keyword and return status    should be empty    ${offline_output}    Syslog Crash verification failed
	    Append To List    ${status_list}    ${status}
	END
	list should not contain value    ${status_list}    ${False}

Globe Modify Swconfig File
    [Documentation]   tingting.1.liu@nokia-sbell.com
    [Arguments]    ${para_update}    ${local_path}=${OUTPUT DIR}
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

Verify Gnb Ready And All Cell On Air
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                Check ALL cells on air include: "lte", "wcdma", "gsm", "nr".
    [Arguments]    ${timeout}=30min    ${connection}=GNB_OAM
    Wait Gnb Ready And Cell On Air    timeout=${timeout}    connection=${connection}
    Wait until keyword succeeds    10 min    20 sec    Globe_keywords_common.Verify Gnb Type Cells Should Be Onair
    ...    cell_type=lte    connection=${connection}
    Wait until keyword succeeds    10 min    20 sec    Globe_keywords_common.Verify Gnb Type Cells Should Be Onair
    ...    cell_type=wcdma    connection=${connection}
    Wait until keyword succeeds    10 min    20 sec    Globe_keywords_common.Verify Gnb Type Cells Should Be Onair
    ...    cell_type=gsm    connection=${connection}

Verify Gnb Type Cells Should Be Onair
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                :param str cell_type: Cell type of given RAT: "lte", "wcdma", "gsm", "nr" (5G). Default: "nr".
    [Arguments]    ${cell_type}=lte    ${connection}=GNB_OAM    ${gnb_id}=${0}    ${timeout}=30
    Log to console    ${\n}----Verify all ${cell_type} cells are on air----
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_id}
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    &{cell_list_info}    Create Dictionary
    FOR    ${item}    IN    @{cell_info}
        Set To Dictionary    ${cell_list_info}    ${item['id']['configuration']}=${item['status']}
    END
    ${cell_list}    Get Dictionary Keys    ${cell_list_info}
    FOR  ${cell}  IN   @{cell_list}
         Should contain    ${cell_list_info['${cell}']['operationalState']}    Enabled    ignore_case=True
         ${status_keys}    Collections.get dictionary keys    ${cell_list_info['${cell}']}
         ${availability_status}    run keyword and return status    should contain
         ...    ${status_keys}    availabilityStatus    ignore_case=True
         run keyword if    ${availability_status}    Should contain
         ...    ${cell_list_info['${cell}']['availabilityStatus']}    Online
    END
    [Return]    ${cell_list}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Verify Enb All Cell On Air
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${enb_index}=${0}    ${connection}=enblte_${enb_index}    ${timeout}=30
    Connect to eNB via ssl    enb_index=${enb_index}    connection=${connection}
	${output}    enblte.get_bts_info    connection=${connection}
    @{rat_type_list}    Create List
    ${ratState_list}    Get Dictionary Keys    ${output['ratState']}
    FOR    ${item}    IN    @{ratState_list}
        ${value}    Get From Dictionary    ${output['ratState']}    ${item}
        Run Keyword If    '${value}' != 'NO_CELLS'    Append To List    ${rat_type_list}    ${item}
    END
    FOR    ${rat_type}    IN    @{rat_type_list}
        Globe_keywords_common.Verify Enb Type Cells Should Be Onair    cell_type=${rat_type}    connection=${connection}    timeout=${timeout}
    END
	[Teardown]    Run Keyword And Ignore Error    Enblte close down    connection=${connection}

Verify Enb Type Cells Should Be Onair
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                :param str cell_type: Cell type of given RAT: "lte", "wcdma", "gsm".
    [Arguments]    ${cell_type}    ${connection}    ${timeout}=30
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    &{cell_list_info}    Create Dictionary
    FOR    ${item}    IN    @{cell_info}
        Set To Dictionary    ${cell_list_info}    ${item['id']['configuration']}=${item['status']}
    END
    ${cell_list}    Get Dictionary Keys    ${cell_list_info}
    FOR    ${cell}    IN    @{cell_list}
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_list_info['${cell}']['administrativeState']}
    ...     unlocked    ignore_case=True
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_list_info['${cell}']['operationalState']}
    ...     enabled    ignore_case=True
    END


SWM supports provision SW build package via WebUI
    Set Test Variable    ${test_result}    ${False}
    step1:Login WebUI
    step2:check current sw version 1
    step3:upgrade site with active
    Sleep    5min
    ${Active_SW_version}    Wait Until Keyword Succeeds    2min    10s    Get Current SITE SoftWare Version
    Set Test Variable    ${Active_SW_version}
    step4:check SW version after upgrade
    step5:check sw update report
    step6:check site status
    step7:logout webui
    Set Test Variable    ${test_result}    ${True}
    [Teardown]     run keyword if  not ${test_result}     CI_interface.Common Case Teardown


Classical gNB Software Rollback successfully via WebUI
    Set Test Variable    ${test_result}    ${False}
    ${Active_SW_version}    Get Current SITE SoftWare Version
    Set Test Variable    ${Active_SW_version}
    step1:Login WebUI
    step2:check current sw version 2
    step3:execute rollback
    run keyword and ignore error    WEBUI Logout    virtual_disable=${TRUE}
    Sleep    5min
    ${Active_SW_version}    Wait Until Keyword Succeeds    2min    10s    Get Current SITE SoftWare Version
    Set Test Variable    ${Active_SW_version}
    Wait Until Keyword Succeeds    2min    10s    Selenium Login And Disable Screen Lock
    step4:confirm rollback success
    step5:ENV recovery
    step6:check site status
    step7:logout webui
    Set Test Variable    ${test_result}    ${True}
    [Teardown]     run keyword if  not ${test_result}     CI_interface.Common Case Teardown

step1:Login WebUI
    log to console    step1:Login WebUI
    Wait Until Keyword Succeeds    2min    10s    Selenium Login And Disable Screen Lock

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
    csn.Connect to    hostname=${testpc_host}    username=${testpc_user}    password=${testpc_pswd}    alias=TESTPC
    set suite variable    ${upgrade_package_path}    ${SW_build_path}/${target_version}_release_BTSSM_downloadable_A54.zip
    ${status}    run keyword and return status   OperatingSystem.File Should Exist    ${upgrade_package_path}
    run keyword if  not ${status}     Fetch SW Package
    csn.disconnect    connection=TESTPC
    wait until keyword succeeds     5 min   10 sec
    ...     coam.connect to       bts_host=${smod_addr}     name=coam_admin
    coam.update_software    sw_package=${upgrade_package_path}    timeout=7200    connection=coam_admin
    #sleep    5s
    #run keyword and ignore error     selenium_coam.disable_screen_lock
    #sleep    2s
    #Download package to site    if_active=${True}    upgrade_package_path=${upgrade_package_path}

Fetch SW Package
    log to console    SW package does not exist in ute server, start to fetch
    ${package_full_link}    Get link For Download from external value
    ${upgrade_package_path}    Download SW Build to VM     package_full_link=${package_full_link}

step3:execute rollback
    log to console    step3:execute rollback
    run keyword and ignore error     selenium_coam.disable_screen_lock
    wait until keyword succeeds    1min    10s    selenium_coam.software_rollback
    sleep    10min

step4:check SW version after upgrade
    log to console    step4:check SW version after upgrade
    wait until keyword succeeds     40min    2min    Check if Airscal Upgrade Successfully
    check if SW upgrade success

step4:confirm rollback success
    log to console    step4:confirm rollback success
    wait until keyword succeeds    15min    1min    check if rollback success
    sleep    5s

step5:check sw update report
    log to console    step5:check sw update report
    wait until keyword succeeds    10min    1min    check the update report

step5:ENV recovery
    log to console    step5:ENV recovery
    run keyword if    "${update_result}"=="FAIL"    step3:execute rollback

step6:check site status
    log to console    step6:check site status
#    wait until keyword succeeds    40min    2min    check board and cell status
    Verify Gnb Ready And All Cell On Air
    Wait Until Keyword Succeeds    1 min    5 sec  Connect to gnb coam via ssl
    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT}
    run keyword and ignore error     selenium_coam.enable_screen_lock
    COAM Teardown gnb connections

step7:logout webui
    log to console    step7:logout webui
    run keyword and ignore error    WEBUI Logout    virtual_disable=${TRUE}

check if SW upgrade success
    ${update_result}    ${version}    run keyword and ignore error    check sw version with external package value    check_version=Active
    set suite variable    ${update_result}
    ${result_2}    should match regexp    ${version}\[Planned]    ${EMPTY}

check if rollback success
    ${output}    ${version}    wait until keyword succeeds    1min    10s    check SW version    Active
    should match regexp    ${output}    ${pre_passive_version_2}
    sleep    5s
    should match regexp    ${version}[Passive]    ${pre_active_version_2}
    sleep    5s
    should match regexp    ${version}[Planned]    ${EMPTY}
    sleep    5s


#Get link For Download from external value from current SW version
#    [Arguments]    ${version_type}
#    ${version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
#    @{result}    string.split string    string=&{version}[${version_type}]    separator=_
#    ${result5}     convert to string    @{result}[-5]
#    ${if_SBTS21B}     convert to string    @{result}[-3]
#    set suite variable    ${result5}
#    set suite variable    ${if_SBTS21B}
#    ${package_full_link}=   Run Keyword If   "${result5}"=="SBTS23R1" and "${if_SBTS21B}"=="9999"
#    ...   Set Variable     ${SBTS00_package_link}/${package_version_globe}/${package_version_globe}_release_BTSSM_downloadable_A54.zip
#    ...   ELSE IF    "${result5}"=="SBTS22R4" and "${if_SBTS21B}"=="9999"
#    ...   Set Variable     ${SBTS00_package_link}/${package_version_globe}/${package_version_globe}_release_BTSSM_downloadable_A54.zip
#    ...   ELSE IF    "${result5}"=="SBTS21B" and "${if_SBTS21B}"=="0000"
#    ...   Set Variable     ${SBTS21B_package_link}/${package_version_globe}/${package_version_globe}_release_BTSSM_downloadable_A54.zip
#    ...   ELSE IF    "${result5}"=="SBTS22R1" and "${if_SBTS21B}"=="0000"
#    ...   Set Variable     ${SBTS22R1_package_link}/${package_version_globe}/${package_version_globe}_release_BTSSM_downloadable_A54.zip
#    ...   ELSE IF    "${result5}"=="SBTS22R2" and "${if_SBTS21B}"=="0000"
#    ...   Set Variable     ${SBTS22R2_package_link}/${package_version_globe}/${package_version_globe}_release_BTSSM_downloadable_A54.zip
#    ...   ELSE IF    "${result5}"=="SBTS22R3" and "${if_SBTS21B}"=="0000"
#    ...   Set Variable     ${SBTS22R3_package_link}/${package_version_globe}/${package_version_globe}_release_BTSSM_downloadable_A54.zip
#    ...   ELSE    Set Variable     ${package_link}/${package_version_globe}/AirScale-${package_version_globe}.zip
#   [Return]      ${package_full_link}

Get link For Download from external value
    @{result}    string.split string    string=${target_version}    separator=_
    ${result5}     convert to string    ${result}[-5]
    set suite variable    ${result5}
    ${package_full_link}    Set Variable    ${package_link}${result5}/${target_version}/${target_version}_release_BTSSM_downloadable_A54.zip
    [Return]      ${package_full_link}

Download SW Build to VM
    [Arguments]    ${package_full_link}
    ...    ${artifactory_token}="Authorization: Bearer cmVmdGtuOjAxOjE3OTI5MjExOTA6ME1uaG1sTzdKYTduOVpVNnM1TVpJcDNueVND"
    OperatingSystem.Empty Directory    ${SW_build_path}
#    ${current_version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
#    @{result}    string.split string    string=&{current_version}[Active]    separator=_
#    ${package_stream}     convert to string    @{result}[-5]
#    set suite variable     ${package_stream}
#    Run Keyword If
#    ...    "${package_stream}"=="SBTS22R4" or "${package_stream}"=="SBTS22R1" or "${package_stream}"=="SBTS22R2" or "${package_stream}"=="SBTS22R3"
#    ...             Run And Return Rc And Output    wget --no-proxy ${package_full_link}.sha256 -P ${SW_build_path}
#    ...    ELSE     Run And Return Rc And Output    wget --no-proxy ${package_full_link}.md5 -P ${SW_build_path}
    Run And Return Rc And Output    wget --no-proxy --header=${artifactory_token} ${package_full_link}.sha256 -P ${SW_build_path}
    ${output}    OperatingSystem.List Directory    ${SW_build_path}    absolute=${TRUE}
    ${md5_file}     set variable    ${output}[0]
    ${md5_value}      OperatingSystem.get file    ${md5_file}
    OperatingSystem.Empty Directory    ${SW_build_path}
    Run And Return Rc And Output    wget --no-proxy --header=${artifactory_token} ${package_full_link} -P ${SW_build_path}
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

#check sw version with external package value
#    [Documentation]    this KW is to check the SW version when the download version is from the external value
#    [Arguments]     ${check_version}
#    WEBUI Login
#    ${version}    wait until keyword succeeds    2min   15s    selenium_coam.check_current_software_version
#    @{result}    string.split string    string=&{version}[${check_version}]    separator=_
#    ${version_now}     convert to string    @{result}[-5]
#    ${SW_check}    convert to integer      @{result}[-1]
#    ${if_SBTS00}     convert to string    @{result}[-3]
#    @{result}    string.split string     string=${package_version_globe}    separator=.
#    ${current_version}=   Run Keyword If   "${version_now}"=="SBTS23R1" and "${if_SBTS00}"=="9999"
#    ...    string.Replace String    &{version}[${check_version}]    23R1    00
#    ...    ELSE IF    "${version_now}"=="SBTS22R1" or "${version_now}"=="SBTS22R4" and "${if_SBTS00}"=="0000"
#    ...    Set Variable    ${version['${check_version}']}
#    Run Keyword If   "${version_now}"=="SBTS22R1" or "${version_now}"=="SBTS22R4" or "${version_now}"=="SBTS23R1"
#    ...    should be equal    "${current_version}"    "${package_version_globe}"
#    ...    ELSE    should be equal    "${SW_check}"    "@{result}[-1]"
#    [Return]    ${version}

check sw version with external package value
    [Documentation]    this KW is to check the SW version when the download version is from the external value
    [Arguments]     ${check_version}
    Selenium Login And Disable Screen Lock
    ${version}    wait until keyword succeeds    2min   15s    selenium_coam.check_current_software_version
    ${result}    string.split string    string=${version}[${check_version}]    separator=_
    ${version_now}     convert to string    ${result}[-5]
    ${SW_check}    convert to integer      ${result}[-1]
    ${if_SBTS00}     convert to string    ${result}[-3]
    ${current_version}=   Run Keyword If   "${if_SBTS00}"=="9999"
    ...    string.Replace String    ${version}[${check_version}]    ${version_now}    SBTS00
    ...    ELSE IF    "${if_SBTS00}"=="0000"
    ...    Set Variable    ${version['${check_version}']}
    should be equal    "${current_version}"    "${package_version_globe}"
    [Return]    ${version}

check board and cell status
    Check ABIL is UP
    Check ASIK is UP
    #Check Cell is UP //problem with selenium_coam . Get Cell Info  replaced with "Verify Gnb Ready And All Cell On Air" in step6

check the update report
    Wait Until Keyword Succeeds    2min    10s    Selenium Login And Disable Screen Lock    download_dir=${TS_CASE_LOG_PATH}/Selenium_Download
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
    csn.send command    command=cat ${SW_build_path}/${file_name} |grep -n "Finished Software Build Download" |tail -1 |cut -d ":" -f1
    ...    connection=TESTPC
    ${output}    csn.read output    connection=TESTPC
    ${line_number}    convert to integer   ${output}
    csn.send command    command=tail -n \+${line_number} ${SW_build_path}/${file_name}    connection=TESTPC
    ${output}    csn.read output    connection=TESTPC
    should not contain any    ${output}    error    failed
    csn.disconnect    connection=TESTPC

Check if Airscal Upgrade Successfully
    ${If_SBTS00}    Run Keyword and Ignore Error    should contain    ${package_version_globe}    SBTS00
#    ${If_SBTS21B}    Run Keyword and Ignore Error    should contain    ${package_version_globe}    SBTS21B
    run keyword if     '${If_SBTS00[0]}' == 'PASS'       Check Trunk Load Version
    ...    ELSE      Check Branch Load Version
    csn.reset_cache

Check Trunk Load Version
    csn.reset_cache
    csn.Connect to    hostname=${smod_addr}    username=${asik_username}    password=${asik_password}    alias=asik
    csn.send_command    command=ls /ffs/run/TargetBD*\.xml    connection=asik
    ${result}     csn.read_output    connection=asik
    ${str}=	    Remove String	    ${package_version_globe}    SBTS00
    should contain    ${result}    ${str}
    csn.reset_cache

Check Branch Load Version
    csn.reset_cache
    csn.Connect to    hostname=${smod_addr}    username=${asik_username}    password=${asik_password}    alias=asik
    csn.send_command    command=ls /ffs/run/TargetBD*\.xml    connection=asik
    ${result}     csn.read_output    connection=asik
    should contain    ${result}    ${package_version_globe}
    csn.reset_cache

Get_Current_Active_SW_Version
    [Arguments]  ${download_dir}=${OUTPUT DIR}    ${gnb_index}=${0}
    ...        ${url}=https://${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    COAM Navigate to login page via webUI    download_dir=${download_dir}   gnb_index=${gnb_index}   url=${url}
    ...   username=${username}   password=${password}
    ${gnb_version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    ${result}    string.split string    string=${gnb_version}[Active]    separator=_
    ${release_info}     convert to string    ${result}[-5]
    ${build_num}    convert to integer      ${result}[-1]
    ${IsTrunk}     convert to string    ${result}[-3]
    ${current_version}=   Run Keyword If   "${IsTrunk}"=="9999"
    ...    string.Replace String    ${gnb_version}[Active]    ${release_info}    SBTS00
    ...    ELSE IF    "${IsTrunk}"=="0000"
    ...    Set Variable    ${gnb_version['Active']}
    [Teardown]    Run keyword and ignore error    selenium_coam.logout
    [Return]    ${current_version}
