*** Settings ***
Documentation     author: Dong Tingting
...               contact: tingting.dong@nokia-sbell.com
...               squad group: MMW_02
Suite Setup       SISO Coam Suite Setup
Suite Teardown    SISO Coam Suite Teardown
Force Tags
...    PY36
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC002479/Resources/5GC002479_Resouce.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
# Library     taf.transport.ssh          WITH NAME    csn
# Resource          Resources/5GC002577_keywords.robot
# Variables         Resources/variables.py

*** Variables ***
@{GNB_PS_CELL_INDEX_LIST}    1
# ${if_commissioning}   False
${ru_ip_addr}    ${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.addr}
${scf_1sector}    SCF_SBTS00.xml
${ASIK_LMP_IP_URL}    https://${bts_host}/
${bts_host}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${UPDATE_FILE_PATH}     /home/ute/Download_gNB_Package
${factory_version}    0x7898F2F0
${ru_index}    1

*** Keywords ***
FDSW_upgrade
    Upload file to RU and Install SW
    ${status}    run keyword and return status    Wait Until Keyword Succeeds    15min    30s    Check 23 alarm
    Software Update

Upload file to RU and Install SW
#    Connect to gnb coam via ssl    connection=ASIK Master
    Connect to Common Unit Master
    Wait until keyword succeeds    10 min    20 sec    Connect to RU With Allocated IP
    csn.upload File    remote_path=/tmp/    local_path=/home/ute/Downloads/SRM-rfsw-image-install-aeqb_${factory_version}.tar
    ...    connection=RU    timeout=60s
    sleep    20s
    Install SW on RU
    Wait Until Keyword Succeeds    35min    60s    inquire SW on RU
    Activate SW on RU

Install SW on RU
#    [Arguments]    ${ru_alias}=RU
    ${output_cmd_ruSW}    csn.execute
    ...    command=ls -hl /tmp/SRM-rfsw-image-install-aeqb_${factory_version}.tar
    ...    connection=RU    timeout=60s
    log to console    \n output_cmd_ruSW:${output_cmd_ruSW}
    ${output_cmd_chown}    csn.execute
    ...    command=sudo chown rfsw:rfsw /tmp/SRM-rfsw-image-install-aeqb_${factory_version}.tar
    ...    connection=RU    timeout=60s
    log to console    \n output_cmd_chown:${output_cmd_chown}
    ${output_cmd_ruSW}    csn.execute
    ...    command=ls -hl /tmp/SRM-rfsw-image-install-aeqb_${factory_version}.tar
    ...    connection=RU    timeout=60s
    log to console    \n output_cmd_ruSW:${output_cmd_ruSW}
    should contain    ${output_cmd_ruSW}    ${factory_version}
    csn.send command
    ...    command=sudo SWmanShellCommand -s /tmp/SRM-rfsw-image-install-aeqb_${factory_version}.tar ${factory_version} ${factory_version} '' &
    ...    connection=RU
    sleep    180s
    csn.send command    command=\n    connection=RU
#    ${output_cmd_ruSW}    csn.execute
#    ...    command=sudo SWmanShellCommand -s /tmp/SRM-rfsw-image-install-aeqb_${factory_version}.tar ${factory_version} ${factory_version} '' &
#    ...    connection=RU    timeout=60s
#    log to console    \n output_cmd_ruSW:${output_cmd_ruSW}
    sleep    180s
    csn.send command    command=\n    connection=RU
#    run keyword and ignore error    csn.await execution end    timeout=120s    connection=RU

inquire SW on RU
    csn.reset_cache
#    Connect to gnb coam via ssl    connection=ASIK Master
    Connect to Common Unit Master
    Wait until keyword succeeds    10 min    20 sec    Connect to RU With Allocated IP
    ${output_cmd_ruSW}    csn.execute    command=sudo SWmanShellCommand -i    connection=RU    timeout=60s
    log to console    ${output_cmd_ruSW}
    ${pattern}   Set Variable    version:(.*)(0x.*)(\r)
    ${ruSW_fromModule_temp}    Get Regexp Matches     ${output_cmd_ruSW}    ${pattern}    2
    log to console    ${ruSW_fromModule_temp}
    should contain    ${ruSW_fromModule_temp}    ${factory_version}

Activate SW on RU
    run keyword and ignore error    Perform RU Power reset
    sleep    120s
    csn.reset_cache
#    Connect to gnb coam via ssl    connection=ASIK Master
    Connect to Common Unit Master
    Wait until keyword succeeds    10 min    20 sec    Connect to RU With Allocated IP
#    ${file_name1}    Get RU SW version    command=cat /mnt/runtime/swman/slot_0 |grep ' "value0": "'|awk '{print $2}'|cut -d '"' -f 2
#    ${file_version1}    Get RU SW version    command=cat /mnt/runtime/swman/slot_0 |grep value1|awk '{print $2}'|cut -d '"' -f 2
#    ${build_name1}    Get RU SW version    command=cat /mnt/runtime/swman/slot_0 |grep value2|awk '{print $2}'|cut -d '"' -f 2
#    ${build_version1}    Get RU SW version    command=cat /mnt/runtime/swman/slot_0 |grep value3|awk '{print $2}'|cut -d '"' -f 2
#    ${file_name2}    Get RU SW version    command=cat /mnt/runtime/swman/slot_1 |grep ' "value0": "'|awk '{print $2}'|cut -d '"' -f 2
#    ${file_version2}    Get RU SW version    command=cat /mnt/runtime/swman/slot_1 |grep value1|awk '{print $2}'|cut -d '"' -f 2
#    ${build_name2}    Get RU SW version    command=cat /mnt/runtime/swman/slot_1 |grep value2|awk '{print $2}'|cut -d '"' -f 2
#    ${build_version2}    Get RU SW version    command=cat /mnt/runtime/swman/slot_1 |grep value3|awk '{print $2}'|cut -d '"' -f 2
#    ${activeBuildName}    Get RU SW version    command=sudo SWmanShellCommand -i |grep activeBuildName:|awk '{print $2}'
#    log to console    build_name1 is:${build_name1}
#    log to console    build_name2 is:${build_name2}
#    log to console    activeBuildName is:${activeBuildName}
#    ${buildName}    set variable if    '${build_name1}'=='${activeBuildName}'    ${build_name2}    ${build_name1}
#    ${buildVersion}    set variable if    '${build_name1}'=='${activeBuildName}'    ${build_version2}    ${build_version1}
#    ${fileName}    set variable if    '${build_name1}'=='${activeBuildName}'    ${file_name2}    ${file_name1}
#    ${fileVersion}    set variable if    '${build_name1}'=='${activeBuildName}'    ${file_version2}    ${file_version1}
#    should not be empty    ${buildName}
#    should not be equal as strings    ${buildName}    100
#    log to console    buildName is:${buildName}
    ${activeBuildName}    set Variable    RF.SRM6.trunk.20220909.020
    ${fileName}    set Variable    SRM-rfsw-image-install-aeqb_${factory_version}.tar
    ${fileVersion}    set Variable    ${factory_version}
    csn.Send Command    command=sudo SWmanShellCommand -a ${activeBuildName} ${activeBuildName} ${fileName} ${fileVersion}
    ...    connection=RU
    csn.await execution end    timeout=120s    connection=RU
    log to console    sudo SWmanShellCommand -a ${activeBuildName} ${activeBuildName} ${fileName} ${fileVersion}
#    csn.execute    pssreboot hw    connection=RU
#    csn.await execution end    timeout=120s    connection=RU
    csn.disconnect  connection=RU
    run keyword and ignore error    Perform RU Power reset
    sleep    60s

Get RU SW version
    [Arguments]    ${command}    ${ru_alias}=RU
    csn.Send Command    command=${command}    connection=${ru_alias}
    ${GET_SW}  csn.Read Output    connection=${ru_alias}
    ${GET_SW}  strip_string    ${GET_SW}
    log to console    ${GET_SW}
    [Return]    ${GET_SW}

Software Update
    csn.reset_cache
    Connect to gnb coam via ssl    connection=ASIK Master
#    Connect to Common Unit Master
    ${TargetBuildVersionTmp}    Get Active SW Version    connection=ASIK Master
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${TargetBuildVersion}    Run keyword If     '${split_version}[2]'=='9999'
    ...    Replace String Using Regexp    string=${Active_SW_version}    pattern=SBTS[^_]+    replace_with=SBTS00
    ...    ELSE    Set variable    ${Active_SW_version}
    Log To Console    \n TargetBuildVersion: ${TargetBuildVersion}
#    ${TargetBuildVersion}    Set variable    ${target_version}
    Log to console    \n TargetBuildVersion: ${TargetBuildVersion}
    ${Target_package_path}    SoftwareUpdate.Download_gNB_Package    build_version=${TargetBuildVersion}
    log to console    package prepared
    Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
    log to console    Download SW build with activate
    COAM_WebEM.Login       url=${ASIK_LMP_IP_URL}
    log to console   start to  load software
    ${load_result}    selenium_coam.load_software_package_from_local_drive    ${Target_package_path}
    log to console    ${load_result}
    log to console   start to software update with active
    selenium_coam.software_update     is_activate=${True}
    log to console   finish KW selenium_coam.software_update
    ${finish}    wait until keyword succeeds    60min    10s    check SW download progress finished
    log to console    waitAllCellsOnair
    wait until keyword succeeds    30min    10s    COAM_Admin.CheckAllCellsOnair
    run    command=rm -r ${UPDATE_FILE_PATH}/*

Check 23 alarm
    [Arguments]  ${connection}=GNB_OAM
    log to console  \n Check fault 23 or 7111 on WebUI
    ${alarm_list}    create list    23    7111
    ${status}    set variable    ${False}
    FOR    ${faultId}    IN    @{alarm_list}
        ${status}    run keyword and return status    Expect Fault Should Present    faultId=${faultId}    connection=${connection}
        log    ${status}
        exit for loop if    ${status}
    END
    should be true    ${status}


Collect_one_RFSW_logs_from_RU_into_BTS_Snapshot
    [Arguments]    ${is_get_snapshot_via_selenium}=${False}    ${ru_index}=1
    sleep    600s
    Connect to Common Unit Master
    #${ru_index_list}  Get All RU Index
    Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    ${version}=    Set Variable If
    ...     '${stream}'=='SBTS24R3'        SBTS24R3
    ...     '${stream}'=='SBTS25R1'        SBTS25R1
    ...     '${stream}'=='SBTS25R3'        SBTS25R3
    ...     '${stream}'=='SBTS25R2'        SBTS25R2
    ...     SBTS00
    ${prefix_name}    Set Variable If   '${version}'=='SBTS24R3' or '${version}'=='SBTS25R1'    BTS    BTS${mrbtsID}
    Verify RFSW Log Include In Snapshot  ru_index=${ru_index}  ru_alias=RU_${ru_index}  snapshot_path=${SAVE LOG DIRECTORY}
    ...    is_get_snapshot_via_selenium=${is_get_snapshot_via_selenium}    prefix_name=${prefix_name}
    Check startup runtime and soap file in ru log    ru_log=${rfsw_log_path_on_testPC}    ru_index=${ru_index}
    csn.Disconnect  connection=RU_${ru_index}
    [Teardown]  csn.Disconnect  connection=ASIK Master

*** Test Cases ***
[1][1.0] General_SiSo_Auto_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Tags]    CRT_TRUNK    CIT_TRUNK
    [Setup]    SISO Coam Test Setup
    Collect_one_RFSW_logs_from_RU_into_BTS_Snapshot
    [Teardown]    SISO Coam Test Teardown

[1][2.0] General_SiSo_Hot_swap_to_RU_with_factory_SW
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    FDSW_upgrade
    [Teardown]    SISO Coam Test Teardown