*** Settings ***
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Library           ./CB007841_common.py
Resource          ../../CB007308-5G-AB/Resources/CB007308-5G-AB_FID4657_keywords.robot
Resource          ../../CB007308-5G-AB/Resources/CB007308-5G-AB_common_keywords.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Variables ***
${host}    ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${user}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${password}   ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
&{fault_61652}             faultId=${61652}
&{fault_61524}             faultId=${61524}
&{fault_61649}             faultId=${61649}
&{fault_9000}             faultId=${9000}
&{fault_4592}              faultId=${4592}
&{fault_4527}              faultId=${4527}
&{fault_1932}              faultId=${1932}
&{fault_4334}              faultId=${4334}
&{fault_61074}              faultId=${61074}
&{fault_61618}                faultId=${61618}
&{fault_4687}              faultId=${4687}
&{fault_4654}              faultId=${4654}
&{fault_4655}              faultId=${4655}
&{fault_8150}                faultId=${8150}
&{fault_4681}              faultId=${4681}
&{fault_16}              faultId=${16}
@{ALLOWED_FAULT_1}       &{fault_61652}    &{fault_61524}    &{fault_61649}    &{fault_9000}    &{fault_4592}
...                      &{fault_4527}     &{fault_1932}     &{fault_4334}     &{fault_61074}    &{fault_61618}
...                      &{fault_4687}     &{fault_4654}     &{fault_4655}     &{fault_8150}     &{fault_4681}      &{fault_16}

*** Keywords ***
Rest Login DU
    [Arguments]    ${ip_address}=${DU_IP}    ${username}=${WEBEM_USERNAME}
    ...    ${password}=${WEBEM_PASSWORD}    ${alias}=default
    [Documentation]   Rest Login DU
    Connect to gnb coam via ssl    bts_host=${ip_address}    username=${username}    password=${password}    connection=${alias}
    ${connection}     set variable    ${alias}
    [Return]    ${connection}

Delete sfp in sfpwhitelist
    CB007308-5G-AB_FID4657_keywords_AEQE.Set SFPWhiteList File Name
    CB007308-5G-AB_FID4657_keywords_AEQE.Create dir
    CB007308-5G-AB_FID4657_keywords_AEQE.Download whitelist file
    CB007308-5G-AB_FID4657_keywords_AEQE.Delete parameter in sfpwhitelist    sfp_model=AOSD
    CB007308-5G-AB_FID4657_keywords_AEQE.Delete parameter in sfpwhitelist    sfp_model=FOTB
    CB007308-5G-AB_FID4657_keywords_AEQE.Upload whitelist file
    ...    upload_whitelist_path=${SFPwhitelist_PATH}${SFPwhitelist_NAME}

Check no unexpected alarm in WebEM
    Wait Until Keyword Succeeds    1 min    5 sec  Connect to gnb coam via ssl
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT_1}
    Run Keyword And Continue On Failure    Unexpect History Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT_1}
    [Teardown]   run keyword and ignore error    COAM Teardown gnb connections

#Extract logs from snapshot
#    [Documentation]   Auther:lijian.xia@nokia-sbell.com
#    [Arguments]    ${snapshot_file}    ${filter_para}='{print $3}'|cut -d "<" -f 2|cut -d ">" -f 1|cut -d "." -f 1|cut -d "T" -f 2
#    ...    ${Ready}="Initializing, to: Ready"    ${Cooled}="Cooled transceiver detected"
#    ...    ${file}=snapshot_file_list.txt    ${f_length}=-E -w "[^[:space:]]{36}"
#    ${timestamp}    Get Current Date    result_format=%Y-%m-%d%H:%M:%S
#    ${zipout}    Set Variable    zipout_${timestamp}
#    Extract Zip File    ${snapshot_file}    ${TS_CASE_LOG_PATH}/${zipout}
#    ${searchName}    Run    command=cd ${TS_CASE_LOG_PATH}/${zipout};find . -name ${file} |xargs grep "_startup" |grep "_RMOD" |grep ${f_length}
#    ${searchName}   split string   ${searchName}    \n
#    log to console     ${searchName}
#    FOR     ${item}    IN     @{searchName}
#        ${item}    Remove String    ${item}     ${SPACE}
#        ${result_zip}    searchFile      filename=${TS_CASE_LOG_PATH}/${zipout}/snapshot_file_list.txt      searchName=${item}
#        Extract Zip File      ${TS_CASE_LOG_PATH}/${zipout}/${result_zip.split(":")[0]}       ${TS_CASE_LOG_PATH}/${zipout}
#        Extract Zip File      ${TS_CASE_LOG_PATH}/${zipout}/${item}       ${TS_CASE_LOG_PATH}/${zipout}
#        Run    command=cd ${TS_CASE_LOG_PATH}/${zipout};unxz startup_DEFAULT.log.xz
#        ${Initializing_time}    Run    command=cat ${TS_CASE_LOG_PATH}/${zipout}/startup_DEFAULT.log |grep ${Ready}|tail -1 |awk ${filter_para}
#        ${Detecting_time}    Run    command=cat ${TS_CASE_LOG_PATH}/${zipout}/startup_DEFAULT.log |grep ${Cooled} |tail -1 |awk ${filter_para}
#        ${Initializing_time}    DateTime.Convert Time    ${Initializing_time}
#        ${Detecting_time}      DateTime.Convert Time      ${Detecting_time}
#        ${return_deviation}      Evaluate    ${Initializing_time}-${Detecting_time}
#        ${status1}    run keyword and return status    should be true    ${return_deviation}<90.0
#        ${status2}    run keyword and return status    should be equal   ${return_deviation}    ${90.0}
#        should be true    ${status1} or ${status2}
#   END

Extract logs from snapshot
    [Documentation]   Auther:lijian.xia@nokia-sbell.com
    [Arguments]    ${snapshot_file}
    ${timestamp}    Get Current Date    result_format=%Y-%m-%d%H:%M:%S
    ${zipout}    Set Variable    zipout_${timestamp}
    Extract Zip File    ${snapshot_file}    ${TS_CASE_LOG_PATH}/${zipout}
    ${time_list_startup}    Get AEQE startup time deviation     zipout=${zipout}
    ${time_list_runtime}    Get AEQE runtime time deviation     zipout=${zipout}
    ${Initializing_exist_startup}    run keyword and return status    should not be empty   ${time_list_startup}[0]
    ${Detecting_exist_startup}    run keyword and return status    should not be empty   ${time_list_startup}[1]
    ${Initializing_exist_runtime}    run keyword and return status    should not be empty   ${time_list_runtime}[0]
    ${Detecting_exist_runtime}    run keyword and return status    should not be empty   ${time_list_runtime}[1]
    ${Initializing_time_final}     run keyword if     ${Initializing_exist_startup}    DateTime.Convert Time    ${time_list_startup}[0]
    ...    ELSE     DateTime.Convert Time    ${time_list_runtime}[0]
    ${Detecting_time_final}     run keyword if     ${Detecting_exist_startup}    DateTime.Convert Time    ${time_list_startup}[1]
    ...    ELSE     DateTime.Convert Time    ${time_list_runtime}[1]
    ${return_deviation}      Evaluate    ${Initializing_time_final}-${Detecting_time_final}
    ${status1}    run keyword and return status    should be true    ${return_deviation}<90.0
    ${status2}    run keyword and return status    should be equal   ${return_deviation}    ${90.0}
    ${status}    run keyword and return status    should be true    ${status1} or ${status2}

Get AEQE startup time deviation
    [Arguments]    ${zipout}    ${file}=snapshot_file_list.txt    ${f_length}=-E -w "[^[:space:]]{36}"
    ...    ${Ready}="Initializing, to: Ready"    ${Cooled}="Cooled sfp detected"
    ...    ${filter_para}='{print $3}'|cut -d "<" -f 2|cut -d ">" -f 1|cut -d "." -f 1|cut -d "T" -f 2
    ${searchName}    Run    command=cd ${TS_CASE_LOG_PATH}/${zipout};find . -name ${file} |xargs grep "L_1_startup" |grep "_RMOD" |grep ${f_length}
    log to console     ${searchName}
    ${searchName}    Remove String    ${searchName}     ${SPACE}
    ${result_zip}    searchFile      filename=${TS_CASE_LOG_PATH}/${zipout}/snapshot_file_list.txt      searchName=${searchName}
    Extract Zip File      ${TS_CASE_LOG_PATH}/${zipout}/${result_zip.split(":")[0]}       ${TS_CASE_LOG_PATH}/${zipout}
    Extract Zip File      ${TS_CASE_LOG_PATH}/${zipout}/${searchName}       ${TS_CASE_LOG_PATH}/${zipout}
    Run    command=cd ${TS_CASE_LOG_PATH}/${zipout};unxz startup_DEFAULT.log.xz
    ${Initializing_time}    Run    command=cat ${TS_CASE_LOG_PATH}/${zipout}/startup_DEFAULT.log |grep ${Ready}|tail -1 |awk ${filter_para}
    ${Detecting_time}    Run    command=cat ${TS_CASE_LOG_PATH}/${zipout}/startup_DEFAULT.log |grep ${Cooled} |tail -1 |awk ${filter_para}
    [Return]   ${Initializing_time}  ${Detecting_time}

Get AEQE runtime time deviation
    [Arguments]    ${zipout}    ${file}=snapshot_file_list.txt    ${f_length}=-E -w "[^[:space:]]{36}"
    ...    ${Ready}="Initializing, to: Ready"    ${Cooled}="Cooled sfp detected"
    ...    ${filter_para}='{print $3}'|cut -d "<" -f 2|cut -d ">" -f 1|cut -d "." -f 1|cut -d "T" -f 2
    ${searchName}    Run    command=cd ${TS_CASE_LOG_PATH}/${zipout};find . -name ${file} |xargs grep "L_1_runtime" |grep "_RMOD" |grep ${f_length}
    log to console     ${searchName}
    ${searchName}    Remove String    ${searchName}     ${SPACE}
    ${result_zip}    searchFile      filename=${TS_CASE_LOG_PATH}/${zipout}/snapshot_file_list.txt      searchName=${searchName}
    Extract Zip File      ${TS_CASE_LOG_PATH}/${zipout}/${result_zip.split(":")[0]}       ${TS_CASE_LOG_PATH}/${zipout}
    Extract Zip File      ${TS_CASE_LOG_PATH}/${zipout}/${searchName}       ${TS_CASE_LOG_PATH}/${zipout}
    Run    command=cd ${TS_CASE_LOG_PATH}/${zipout};unxz runtime_DEFAULT.log.xz
    ${Initializing_time}    Run    command=cat ${TS_CASE_LOG_PATH}/${zipout}/runtime_DEFAULT.log |grep ${Ready}|tail -1 |awk ${filter_para}
    ${Detecting_time}    Run    command=cat ${TS_CASE_LOG_PATH}/${zipout}/runtime_DEFAULT.log |grep ${Cooled} |tail -1 |awk ${filter_para}
    [Return]  ${Initializing_time}  ${Detecting_time}

Collect snapshot coam
    [Arguments]    ${snapshot_path}=${OUTPUT DIR}
    CB007308-5G-AB_common_keywords_AEQE.Connect to DU
    ${date}    Get current date    result_format=%Y%m%d_%H%M%S
    coam.Collect snapshot
    ...        target_file_name=${snapshot_path}/snapshot_${date}.zip
    ...        coverage=Full
    ...        force=True
    ...        timeout=720
    ...        connection=cOAM_admin
    CB007308-5G-AB_common_keywords_AEQE.Disconnect from DU
    [Return]    ${snapshot_path}/snapshot_${date}.zip

Case Teardown
    sleep    15s
    CB007308-5G-AB_FID4657_keywords_AEQE.Upload whitelist file
    ...    upload_whitelist_path=${SFPwhitelist_PATH}SFPwhitelist.xml
    CB007308-5G-AB_FID4657_keywords_AEQE.Reset DU
    run keyword and continue on failure    CB007308-5G-AB_FID4657_keywords_AEQE.check none fault 4657
    sleep    3s
    ssh.Connect to    hostname=${test_pc_host}    username=${test_pc_username}
    ...   password=${test_pc_password}    alias=test_pc
    ssh.send command    command=rm -rf ${SFPwhitelist_PATH}${SFPwhitelist_NAME}
    ...    connection=test_pc    timeout=15 s
    ssh.send command    command=rm -rf ${SFPwhitelist_PATH}log
    ...    connection=test_pc    timeout=15 s
    CI_interface.Common Case Teardown
    robot_common_operations.Common case Teardown
    [Teardown]    ssh.Disconnect    connection=test_pc


### TL7422  ###
Check fault 4657 and check SFP status
    [Arguments]    ${SN}    ${RF}    ${R_SN}
    check 7422 fault 4657      SN=${SN}   RF=${RF}    R_SN=${R_SN}
    ${i}    Get TL7422 BBMOD distname       SN=${SN}
    ${ii}    Get TL7422 RF1 distname     i=${i}     RF=${RF}
    ${j}    Get TL7422 EIF1 distname
    ${k}    COAM get ru index      R_SN=${R_SN}
    ${EIF1_SFP_status}    ${RF1_SFP_status}    ${RMOD_SFP_status}    Get 7422 Availability status for SFP    i=${i}    ii=${ii}    j=${j}    k=${k}
    CB007308-5G-AB_FID4657_keywords_AEQE.Check SFP availability status
    ...    EIF1_SFP_status=${EIF1_SFP_status}    RF1_SFP_status=${RF1_SFP_status}
    ...    RMOD_SFP_status=${RMOD_SFP_status}    expected_status=Degraded

check 7422 fault 4657
    [Arguments]     ${RF}    ${SN}    ${R_SN}
    ${j}    Get TL7422 BBMOD distname       SN=${SN}
    ${i}    Get TL7422 RF Runtime number     j=${j}    RF=${RF}
    ${h}    CB007308-5G-AB_common_keywords_AEQE.Get EIF1 Runtime number
    ${k}    COAM get ru index      R_SN=${R_SN}
    CB007308-5G-AB_FID4657_keywords_AEQE.Connect to DU
    ${hw_path_list}    ${alarm_list}    ${fault_id_list}    Get Alarm Info
    list should contain value    ${hw_path_list}    /SMOD_R-1/eif1/SFP_R-${h}
    run keyword if    '${R_SN}'=='${R_AWEUA}'     list should contain value    ${hw_path_list}    /SMOD_R-1/BBMOD_R-${j}(Left_Bottom)/rf1/SFP_R-1
    ...   ELSE      list should contain value    ${hw_path_list}    /SMOD_R-1/BBMOD_R-${j}(Left_Top)/rf7/SFP_R-7
    run keyword if    '${R_SN}'=='${R_AWEUA}'
    ...   list should contain value    ${hw_path_list}    /SMOD_R-1/BBMOD_R-${j}(Left_Bottom)/rf2/RMOD_R-1/opt_if0/SFP_R-1
    ...   ELSE     list should contain value    ${hw_path_list}    /SMOD_R-1/BBMOD_R-${j}(Left_Top)/rf7/RMOD_R-3/opt_if1/SFP_R-1
    FOR    ${item}    IN    @{alarm_list}
        should be equal    '${item}'    '${7100}'
    END
    [Teardown]    CB007308-5G-AB_FID4657_keywords_AEQE.Disconnect from DU

COAM get ru index
    [Documentation]  Author: shenrao
    ...              Description: Get RU detail info by ru index
    ...              ${ru_index} Should be start from 1, should match the value with RMOD-*
    [Arguments]    ${R_SN}    ${ru_index}=1    ${connection}=GNB_OAM
    Rest Login DU    alias=${connection}
    &{hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    ${count_RUs}    Get length    ${list_RUs}
    ${all_ru_list}      Create List
    Run Keyword And Ignore Error    Should be true    ${count_RUs}>=1    msg=No RU found
    FOR    ${RMOD}    IN    @{list_RUs}
        run keyword if    '${RMOD['serialNumber']}'=='${R_SN}'
        ...  Append To List    ${all_ru_list}    ${RMOD['ports'][0]['id']['internal'].split('RMOD_L-')[1].split("/")[0]}
    END
    [Teardown]   Run Keyword And Ignore Error   Logout DU via admin    alias=${connection}
    [Return]  ${all_ru_list[0]}

Get TL7422 RF Runtime number
     [Arguments]    ${j}    ${RF}
    ${connection}    CB007308-5G-AB_common_keywords_AEQE.Connect to DU    alias=gnb
    FOR     ${i}    IN RANGE    ${1}    ${16}
        ${SFP_status}    run keyword and return status    coam.get_parameters
       ...   dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-${j}/SFP_R-${i}
       ...       connection=${connection}
       ${SFP_status}    run keyword if      ${SFP_status}
       ...   coam.get_parameters
       ...   dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-${j}/SFP_R-${i}
       ...       connection=${connection}      ELSE      Continue For Loop
        ${label}    get from dictionary    ${SFP_status}     physicalPort
        ${if_RF1}     run keyword and return status    should be equal     ${label}   ${RF}
        Exit For Loop If    '${if_RF1}'=='${True}'
    END
    [Return]    ${i}
    [Teardown]    CB007308-5G-AB_common_keywords_AEQE.Disconnect from DU    alias=${connection}

Check none fault 4657 and check SFP status
    [Arguments]    ${SN}    ${RF}    ${R_SN}
    run keyword and continue on failure    CB007308-5G-AB_FID4657_keywords_AEQE.check none fault 4657
    ${i}    Get TL7422 BBMOD distname       SN=${SN}
    ${ii}    Get TL7422 RF1 distname     i=${i}    RF=${RF}
    ${j}    Get TL7422 EIF1 distname
    ${k}    COAM get ru index      R_SN=${R_SN}
    ${EIF1_SFP_status}    ${RF1_SFP_status}    ${RMOD_SFP_status}    Get 7422 Availability status for SFP    i=${i}    ii=${ii}    j=${j}    k=${k}
    CB007308-5G-AB_FID4657_keywords_AEQE.Check SFP availability status
    ...    EIF1_SFP_status=${EIF1_SFP_status}    RF1_SFP_status=${RF1_SFP_status}
    ...    RMOD_SFP_status=${RMOD_SFP_status}    expected_status=Online

check SFP status once more
    [Arguments]    ${SN}    ${RF}    ${expected_status}    ${R_SN}
    ${i}    Get TL7422 BBMOD distname       SN=${SN}
    ${ii}    Get TL7422 RF1 distname     i=${i}    RF=${RF}
    ${j}    Get TL7422 EIF1 distname
    ${k}    COAM get ru index      R_SN=${R_SN}
    ${EIF1_SFP_status}    ${RF1_SFP_status}    ${RMOD_SFP_status}    Get 7422 Availability status for SFP    i=${i}    ii=${ii}    j=${j}    k=${k}
    CB007308-5G-AB_FID4657_keywords_AEQE.Check SFP availability status
    ...    EIF1_SFP_status=${EIF1_SFP_status}    RF1_SFP_status=${RF1_SFP_status}
    ...    RMOD_SFP_status=${RMOD_SFP_status}    expected_status=${expected_status}

Get TL7422 EIF1 distname
    ${connection}    CB007308-5G-AB_common_keywords_AEQE.Connect to DU
    FOR     ${j}    IN RANGE    ${1}    ${17}
        ${Connector_status}    run keyword and return status
        ...   coam.get_parameters    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/SMOD_L-1/CONNECTOR_L-${j}
        ...              connection=${connection}
        ${Connector_status}    run keyword if    ${Connector_status}
        ...   coam.get_parameters    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/SMOD_L-1/CONNECTOR_L-${j}
        ...              connection=${connection}     ELSE     Continue For Loop
        ${label}    get from dictionary    ${Connector_status}     connectorLabel
        ${if_EIF1}     run keyword and return status    should be equal     ${label}   EIF1
        Exit For Loop If    '${if_EIF1}'=='${True}'
    END
    [Return]    ${j}
    [Teardown]    CB007308-5G-AB_common_keywords_AEQE.Disconnect from DU

Get TL7422 RF1 distname
    [Arguments]     ${i}    ${RF}
    ${connection}    CB007308-5G-AB_common_keywords_AEQE.Connect to DU
    FOR     ${ii}    IN RANGE    ${1}    ${17}
        ${Connector_status}    run keyword and return status
        ...   coam.get_parameters    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/BBMOD_L-${i}/CONNECTOR_L-${ii}
        ...              connection=${connection}
        ${Connector_status}    run keyword if    ${Connector_status}
        ...   coam.get_parameters    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/BBMOD_L-${i}/CONNECTOR_L-${ii}
        ...              connection=${connection}     ELSE    Continue For Loop
        ${label}    get from dictionary    ${Connector_status}     connectorLabel
        ${if_RF1}     run keyword and return status    should be equal     ${label}    ${RF}
        Exit For Loop If    '${if_RF1}'=='${True}'
    END
    [Return]    ${ii}
    [Teardown]    CB007308-5G-AB_common_keywords_AEQE.Disconnect from DU

Get TL7422 BBMOD distname
     [Arguments]    ${SN}
     ${conn}   CB007308-5G-AB_common_keywords_AEQE.Connect to DU
     FOR     ${i}    IN RANGE    ${1}    ${20}
        ${Connector_status}    run keyword and return status
        ...    coam.get_parameters    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/BBMOD_L-${i}
        ...              connection=${conn}
        ${label}   run keyword if    ${Connector_status}
        ...    coam.get_parameters    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/BBMOD_L-${i}
        ...              connection=${conn}       ELSE    Continue For Loop
        ${label}     run keyword if    ${Connector_status}    get from dictionary    ${label}     serialNumber
        ${if_BBMOD}   run keyword if    ${Connector_status}    run keyword and return status    should be equal     ${label}    ${SN}
        Exit For Loop If    '${if_BBMOD}'=='${True}'
    END
    [Return]    ${i}
    [Teardown]     CB007308-5G-AB_common_keywords_AEQE.Disconnect from DU

Get 7422 Availability status for SFP
    [Arguments]    ${i}    ${ii}   ${j}    ${k}
    ${connection}    CB007308-5G-AB_common_keywords_AEQE.Connect to DU
    ${RF1_status}    coam.get_parameters    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/BBMOD_L-${i}/CONNECTOR_L-${ii}/SFP_L-1
    ...                 pattern=availabilityStatus    connection=${connection}
    ${EIF1_status}    coam.get_parameters    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/SMOD_L-1/CONNECTOR_L-${j}/SFP_L-1
    ...                 pattern=availabilityStatus    connection=${connection}
    ${RMOD_status}    coam.get_parameters    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/RMOD_L-${k}/CONNECTOR_L-1/SFP_L-1
    ...                 pattern=availabilityStatus    connection=${connection}
    ${EIF1_status_dic}        get from dictionary    ${EIF1_status}    stateInfo
    ${EIF1_SFP_status}        get from dictionary    ${EIF1_status_dic}    availabilityStatus
    ${RF1_SFP_status_dic}     get from dictionary    ${RF1_status}    stateInfo
    ${RF1_SFP_status}         get from dictionary    ${RF1_SFP_status_dic}     availabilityStatus
    ${RMOD_SFP_status_dic}    get from dictionary    ${RMOD_status}    stateInfo
    ${RMOD_SFP_status}        get from dictionary    ${RMOD_SFP_status_dic}    availabilityStatus
    [Return]    ${EIF1_SFP_status}    ${RF1_SFP_status}    ${RMOD_SFP_status}
    [Teardown]     CB007308-5G-AB_common_keywords_AEQE.Disconnect from DU    alias=${connection}

BTS 7422 detects cold SFP+/SFP28 startup and compare the temperature
   [Arguments]     ${SN}    ${RF}    ${R_SN}     ${index}
    CB007308-5G-AB_common_keywords_AEQE.Connect to DU
    CB007308-5G-AB_common_keywords_AEQE.ADMIN Wait Until BTS OnAir
    Compare 7422 the temperature for FH and BH SFP    SN=${SN}    RF=${RF}    R_SN=${R_SN}     index=${index}
    [Teardown]    CB007308-5G-AB_common_keywords_AEQE.Disconnect from DU

Compare 7422 the temperature for FH and BH SFP
    [Arguments]   ${SN}    ${RF}    ${R_SN}      ${index}
    ${j}    Get TL7422 BBMOD distname       SN=${SN}
    ${ii}    Get TL7422 RF Runtime number     j=${j}    RF=${RF}
    ${i}    CB007308-5G-AB_common_keywords_AEQE.Get EIF1 Runtime number
    ${k}    COAM get ru index      R_SN=${R_SN}
    CB007308-5G-AB_common_keywords_AEQE.Connect to DU
    ${TEMHIGH_RF1}    ${TEMHIGH_EIF1}    ${TEMHIGH_RMOD_opt1}    Check 7422 SFP temperature
    ...    parameter=temperatureHighAlarmThreshold    i=${i}    ii=${ii}    j=${j}    index=${index}
    ${TEMLOW_RF1}    ${TEMLOW_EIF1}    ${TEMLOW_RMOD_opt1}    Check 7422 SFP temperature
    ...    parameter=temperatureLowAlarmThreshold    i=${i}    ii=${ii}    j=${j}    index=${index}
    ${temperature_value_RF1}    CB007308-5G-AB_common_keywords_AEQE.Check RF1 SFP Module temperature
    ${temperature_value_EIF1}    CB007308-5G-AB_common_keywords_AEQE.Check EIF1 SFP Module temperature
    ${RMOD_SFP_TEMP_value}    Get 7422 temperature for RMOD SFP    k=${k}
    Should Be True    ${TEMLOW_RF1}<=${temperature_value_RF1}<=${TEMHIGH_RF1}
    ...               ${TEMLOW_EIF1}<=${temperature_value_EIF1}<=${TEMHIGH_EIF1}
    Should Be True    ${TEMLOW_RMOD_opt1}<=${RMOD_SFP_TEMP_value}<=${TEMHIGH_RMOD_opt1}

Get 7422 temperature for RMOD SFP
    [Arguments]   ${k}
    ${connection}    CB007308-5G-AB_common_keywords_AEQE.Connect to DU    alias=gnb
    ${RMOD_SFP_TEMP}    coam.get_parameters    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/RMOD_L-${k}/CONNECTOR_L-1/SFP_L-1/SFP_PARAMS_L-1
    ...                 pattern=modTemp    connection=${connection}
    ${RMOD_SFP_TEMP_value}    get from dictionary    ${RMOD_SFP_TEMP}    modTemp
    [Return]    ${RMOD_SFP_TEMP_value}
    [Teardown]    CB007308-5G-AB_common_keywords_AEQE.Disconnect from DU    alias=${connection}

Check 7422 SFP temperature
    [Arguments]    ${parameter}    ${i}    ${ii}    ${j}   ${index}
    ${TEM1}   Get SCF single Value from current xml file
    ...   parameter=${parameter}   list_name=${None}
    ...   dist_name=MRBTS-${MRBTS_ID}/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-${j}/SFP_R-${ii}   p_index=${0}
    ...   alias=cOAM_admin    config_type=configurationAndRuntimeObjects
    ${TEM2}   Get SCF single Value from current xml file
    ...   parameter=${parameter}   list_name=${None}   dist_name=MRBTS-${MRBTS_ID}/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1/SFP_R-${i}   p_index=${0}
    ...   alias=cOAM_admin    config_type=configurationAndRuntimeObjects
    ${TEM3}   Get SCF single Value from current xml file
    ...   parameter=${parameter}   list_name=${None}   dist_name=MRBTS-${MRBTS_ID}/EQM_R-1/APEQM_R-1/RMOD_R-${index}/SFP_R-1   p_index=${0}
    ...   alias=cOAM_admin    config_type=configurationAndRuntimeObjects
    [Return]    ${TEM1}    ${TEM2}    ${TEM3}

## common keyword  ###
SSH To BTS And Collect sfp monitor log
    [Arguments]   ${hostname}=${host}    ${username}=${user}      ${password}=${password}     ${alias}=gnb
    ${connection}    csn.Connect to    hostname=${host}   username=${user}   password=${password}    alias=${alias}
    csn.send_command    command=/opt/trs/bin/trs-eth-d monitor >/tmp/sfp_file.txt    connection=${connection}
    sleep    5s
    csn.send_command     command=ps -ef |grep "/opt/trs/bin/trs-eth-d monitor" | awk '{print $2}' |xargs kill -9  connection=${connection}
    csn.download_file   remote_path=/tmp/sfp_file.txt     local_path=${OUTPUT_DIR}/sfp_file.txt
    ...   connection=${connection}
    ${PowerL_file}    Set Variable        ${OUTPUT_DIR}/sfp_file.txt
    [Teardown]    csn.Disconnect     connection=${connection}
    [Return]    ${PowerL_file}


Collect dump_file And check power class
    [Arguments]  ${log_command}=bsh 0:1     ${bget}=bget 0:1
    ...  ${hostname}=${host}    ${username}=${user}      ${password}=${password}     ${alias}=gnb
    csn.Connect to    hostname=${host}   username=${user}   password=${password}    alias=${alias}
    csn.send_command    command=${log_command} sfp_tester mem_dump /tmp/dump_file.txt      connection=${alias}
    sleep    5s
    csn.send_command    command=${bget} /tmp/dump_file.txt /tmp/
    ...   connection=${alias}
    sleep   5s
    csn.download_file   remote_path=/tmp/dump_file.txt     local_path=${OUTPUT_DIR}/dump_file.txt
    ...   connection=${alias}
    ${dump_file}    Set Variable        ${OUTPUT_DIR}/dump_file.txt
    [Teardown]    csn.Disconnect     connection=${alias}
    [Return]    ${dump_file}
