*** Settings ***
Documentation     Author: Chen Yin
...               Email: yin.1.chen@nokia-sbell.com
...               Squad group: SG_02

Library           String
Library           taf.rfrl.common_resources.python.SWConfig    WITH NAME    SWconfig
Library           taf.hw.rf_attenuator    WITH NAME    attenuator
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/frame_structure_and_throughput.py
Library           testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CMCC_E2E/Resources/E2E_CMCC_get_cell_info.py
Variables         testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CMCC_E2E/Resources/E2E_CMCC_UE_infor.py
Resource          testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/common/RRH_common_keyword.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/Huawei_sigspark_L3_call.robot
Resource          testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC002029-A/Resources/5GC002029_A_common_keywords.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Variables ***
${SW_build_path}    /home/ute/UUF_SW
${SBTS00_package_link}     https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local/SBTS00_packages
${SBTS22R1_package_link}     https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local/SBTS22R1_packages
${SBTS22R2_package_link}     https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local/SBTS22R2_packages
${SBTS22R3_package_link}     https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local/SBTS22R3_packages
${SBTS22R4_package_link}     https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local/SBTS22R4_packages
${SBTS23R1_package_link}     https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local/SBTS23R1_packages
${SBTS23R2_package_link}     https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local/SBTS23R2_packages
${SBTS23R1_FSM3_package_link}     https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local/SBTS23R1_FSM3_packages/
${Package_link}       https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build/

${testpc_host}    ${tl.test_pc.default_ssh_connection_details.addr}
${testpc_user}    ${tl.test_pc.default_ssh_connection_details.username}
${testpc_pswd}    ${tl.test_pc.default_ssh_connection_details.password}

@{swconfig_modify}      0x190030=0    0x4F0214=0
${btslog_path}    /opt/btslog/btslog
${btslog_launcher_path}    /opt/btslog/btslog_launcher
${btslog_folder}    /tmp/btslog2

${UL_SLP_TP}    10
${DL_SLP_TP}    10

${tl_recover_scf_path}     ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/gnbs_0/sbts

*** Keywords ***
Common CMCC Test Case Setup
    ${SCOUT_TL_NAME}    Set Variable If    '${testline_name}' == '7_5_UTE5G402T978'    7_5_UTE5G402T777_5G2
    ...                                    '${testline_name}' == '7_5_UTE5G402T777'    7_5_UTE5G402T777_5G1
    ...                                    '${testline_name}' == '7_5_UTE5G402T779'    7_5_UTE5G402T779
    ...                                    '${testline_name}' == '7_5_UTE5G402T785'    7_5_UTE5G402T785_5G
    ...                                    '${testline_name}' == '7_5_UTE4G402T10967'    7_5_UTE5G402T777_4G
    ...                                    '${testline_name}' == '7_5_UTE4G402T9672'    7_5_UTE5G402T785_4G
    ...                                    '${testline_name}' == '7_5_UTE5G402T965'    7_5_UTE5G402T965
    ...                                    '${testline_name}' == '7_5_UTE5G402T967'    7_5_UTE5G402T967
    ...                                     ${testline_name}
    Set Test Variable    ${SCOUT_TL_NAME}
    ${SCOUT_HOSTNAME}    Set Variable If    '${testline_name}' == '7_5_UTE5G402T978'    7_5_UTE5G402T777_5G2
    ...                                    '${testline_name}' == '7_5_UTE5G402T777'    7_5_UTE5G402T777_5G1
    ...                                    '${testline_name}' == '7_5_UTE5G402T779'    7_5_UTE5G402T779
    ...                                    '${testline_name}' == '7_5_UTE5G402T785'    7_5_UTE5G402T785_5G
    ...                                    '${testline_name}' == '7_5_UTE4G402T10967'    7_5_UTE5G402T777_4G
    ...                                    '${testline_name}' == '7_5_UTE4G402T9672'    7_5_UTE5G402T785_4G
    ...                                    '${testline_name}' == '7_5_UTE5G402T965'    7_5_UTE5G402T965
    ...                                    '${testline_name}' == '7_5_UTE5G402T967'    7_5_UTE5G402T967
    ...                                     ${testline_name}
    Set Test Variable    ${SCOUT_HOSTNAME}
    @{customers}    Create List
    Set Test Variable    ${customers}
    Run Keyword If    '${testline_name}' == '7_5_UTE5G402T967' or '${testline_name}' == '7_5_UTE5G402T965'
    ...                Append To List    ${customers}    TMO US
    ...                ELSE IF    '${testline_name}' == '7_5_UTE5G402T37710' or '${testline_name}' == '7_5_UTE5G402T37672'
    ...                Append To List    ${customers}    Generic
    ...                ELSE            Append To List    ${customers}    CMCC
    robot_common_operations.Common Case Setup    fail_with_alarms=${False}    allowed_faults_ids=7312,7313,7307,7311,4589
    ${ue_reboot_dict}    create dictionary
    set test variable    ${ue_reboot_dict}

Common CMCC Test Case Teardown
    Run keyword And Ignore Error    robot_common_operations.Common Case Teardown
    Run keyword If       '${testline_name}' == '7_5_UTE4G402T9672' or '${testline_name}' == '7_5_UTE4G402T10967'
    ...      log to console      ${testline_name}
    ...      ELSE      Run keyword And Ignore Error    CI_interface.Common Case Teardown

Common E2E Test Case Setup
    ${SCOUT_TL_NAME}    Set Variable If    '${testline_name}' == '7_5_UTE5G402T978'    7_5_UTE5G402T777_5G2
    ...                                    '${testline_name}' == '7_5_UTE5G402T777'    7_5_UTE5G402T777_5G1
    ...                                    '${testline_name}' == '7_5_UTE5G402T779'    7_5_UTE5G402T779
    ...                                    '${testline_name}' == '7_5_UTE5G402T785'    7_5_UTE5G402T785_5G
    ...                                    '${testline_name}' == '7_5_UTE4G402T10967'    7_5_UTE5G402T777_4G
    ...                                    '${testline_name}' == '7_5_UTE4G402T9672'    7_5_UTE5G402T785_4G
    ...                                    '${testline_name}' == '7_5_UTE5G402T965'    7_5_UTE5G402T965
    ...                                    '${testline_name}' == '7_5_UTE5G402T967'    7_5_UTE5G402T967
    ...                                     ${testline_name}
    Set Test Variable    ${SCOUT_TL_NAME}
    @{customers}    Create List
    Set Test Variable    ${customers}
    Run Keyword If    '${testline_name}' == '7_5_UTE5G402T967' or '${testline_name}' == '7_5_UTE5G402T965'
    ...                Append To List    ${customers}    TMO US
    ...                ELSE            Append To List    ${customers}    CMCC
    Test Case Setup
    ${ue_reboot_dict}    create dictionary
    set test variable    ${ue_reboot_dict}

update parameter in SCF
    [Arguments]    ${update_value}    ${connection}=GNB_OAM
    ${cell_num}    RRH_common_keyword.COAM Get GNB CELL Number    connection=${connection}
    @{cell_list}    Create List
    @{modify_param}    Create List
    ${allowed_faults}    Create List    @{ALLOWED_FAULT_ID}    ${fault_7319}    ${fault_7300}
    FOR    ${cell_index}    IN RANGE    1    ${cell_num}+${1}
        Append To List    ${cell_list}    ${cell_index}
    END
    FOR    ${cell_idx}    IN    @{cell_list}
        &{update_param}    Create Dictionary    dist_name=NRBTS-${nr_bts_id}/NRCELL-${cell_idx}
        ...    parameter=actIncreasedFdmUsersPerSlot    value=${update_value}
        Append To List    ${modify_param}     ${update_param}
    END
    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param}    timeout=600

Recover ENV
    ${scf_base_path}    String.Replace String    ${CURDIR}    ${cur_relative_dir}/Resources    commissionings
    Commissioning with Template Commission      scf_file=${scf_base_path}/HGZ/7_5_UTE5G402T967/RF_Sharing.xml
    Test Case Teardown for CMCC

CMCC testline commission scf
    [Arguments]    ${scf}
    Connect to gnb coam via ssl
    COAM commission scf and wait cell setup    scf_file_path=${scf}
    COAM Teardown gnb connections

Test Case Setup without HWF
    [Arguments]     ${swconfig_modify_list}
    robot_common_operations.Common Case Setup
    COAM Create log directory
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    ${onair_status}    Run keyword and Return Status    COAM Check GNB cell on air
    Run keyword If    ${onair_status}==${False}    Perform BTS Site Reset and Verify all cells be on air
    COAM Wait for gnb ready and cell setup    timeout=20 min
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${allowed_faults}
    ${date}    Evaluate    datetime.datetime.now().strftime('%Y-%m-%d-%H%M%S')    datetime

    Set test variable    ${date}
    Connect to Common Unit Master
    SWconfig.download_swConfig_file_from_asik_to_test_pc      localFilePath=${OUTPUT_DIR}/swconfig.txt      asik_alias=ASIK Master
    SWconfig.modify_swConfig_file      parametersList=${swconfig_modify_list}      filePath=${OUTPUT_DIR}/swconfig.txt
    SWconfig.upload_swConfig_file_to_asik_and_crasign      localFilePath=${OUTPUT_DIR}/swconfig.txt      asik_alias=ASIK Master
    [Teardown]    Run keyword and ignore error    Run keywords    csn.disconnect    connection=ASIK Master    AND
    ...    COAM Teardown gnb connections

Perform BTS Site Reset and Verify all cells be on air
    Perform BTS Site Reset
    Sleep    3min
    COAM Wait for gnb ready and cell setup    timeout=20min
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair    connection=GNB_OAM

Test Case Teardown for CMCC
    [Arguments]    ${need_Btslog}=${True}
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    Run keyword And Ignore Error    Run Keyword If Test Failed    COAM Save snapshot via rest api
    Run keyword If    ${need_Btslog}==${True}    Stop BTS log
    Run keyword And Ignore Error    Run Keyword If Test Failed    Capture RU log from ctrl PC
    Run keyword And Ignore Error    Run Keyword If Test Failed    Perform BTS Site Reset and Verify all cells be on air
    Run keyword And Ignore Error    CI_interface.Common Case Teardown
    Run Keyword And Ignore Error    csn.disconnect    connection=ABIL Loner
    Run Keyword And Ignore Error    csn.disconnect    connection=RU
    Run Keyword And Ignore Error    csn.disconnect    connection=ABIL Master
    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master
    run keyword and ignore error    COAM Teardown gnb connections

Test Case Teardown with UE for CMCC
    Run keyword And Ignore Error    power_ue.UE Detach     ue_type=${ue_type}
    Test Case Teardown for CMCC

check the download completed
    [Arguments]    ${upgrade_package_path}    ${md5_value}
    ${sum}=        Set Variable     sha256sum ${upgrade_package_path}
    ${res}    ${output}    Run And Return Rc And Output    ${sum}
    ${res}    string.split string    ${output}
    should be equal    ${md5_value}    ${res}[0]

Download SW Build to VM
    [Arguments]    ${package_full_link}
    csn.Connect to    hostname=${testpc_host}    username=${testpc_user}    password=${testpc_pswd}    alias=TESTPC
    OperatingSystem.Empty Directory    ${SW_build_path}
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
    csn.disconnect    connection=TESTPC
    [Return]      ${upgrade_package_path}

Get package link and Download to VM
    COAM Navigate to login page via webUI
    ${current_version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    COAM selenium logout
    Set Test Variable    ${current_version}    ${current_version['Active']}
    @{stream_list}=    Split String    ${target_version}    _    3
    ${stream}    string.fetch from left    ${target_version}    marker=_
    ${package_name}    Set Variable If    '${customers}'=='CMCC'    ${target_version}_release_BTSSM_downloadable_CMCC_A50.zip
    ...                                    ${target_version}_release_BTSSM_downloadable_A54.zip
    ${stream_folder}     Set Variable If    '${stream_list}[2]'=='9990'     'SBTSCD00'
    ...                                     '${stream_list}[2]'=='9200'     'SBTS_FEINT'
    ...                                     '${stream_list}[2]'=='9000'     'SBTS_PSINT'
    ...                                     '${stream_list}[2]'=='9001'     'SBTS_PSINT2'
    ...                                     '${stream_list}[2]'=='9999'     ${stream}
    ...                                     '${stream_list}[2]'=='0000'     ${stream}
    ${package_full_link}    Set Variable      ${Package_link}/${stream_folder}/${target_version}/${package_name}
    ${package_path}    Download SW Build to VM    package_full_link=${package_full_link}
    [Return]      ${package_path}

Check if Airscal Upgrade Successfully
    csn.Connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=asik
    csn.send_command    command=ls /ffs/run/TargetBD*\.xml    connection=asik
    ${result}     csn.read_output    connection=asik
    ${str}=	    Remove String	    ${target_version}    SBTS00
    should contain    ${result}    ${str}
    csn.disconnect    connection=asik

Compare Trunk Version
    [Arguments]    ${version}    ${target_version}
    ${version}    Replace String    ${version}    SBTS23R1    SBTS00
    Should be Equal as Strings    ${target_version}    ${version}

Upgrade Site and Check gnb Status
    [Arguments]    ${package_path}
    coam.update_software    sw_package=${package_path}    timeout=7200    connection=GNB_OAM
    Log to Console    1:update
    wait until keyword succeeds     40min    2min    Check if Airscal Upgrade Successfully
    Log to Console    2:Airscal upgrade successfully
    Capture BTS log
    COAM Wait for gnb ready and cell setup
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair    connection=GNB_OAM
    Wait until keyword succeeds    3min    20 sec    Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT_ID}
    Log to Console    3:cell on air
    COAM Navigate to login page via webUI
    ${version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    COAM selenium logout
    ${stream}    string.fetch from left    ${target_version}    marker=_
    Run Keyword If    "${stream}"=="SBTS00"    Compare Trunk Version    version=${version['Active']}   target_version=${target_version}
    ...       ELSE    Should be Equal as Strings    ${target_version}    ${version['Active']}
    [Teardown]    Stop BTS log

Rollback Site and Check gnb Status
    COAM Navigate to login page via webUI
    wait until keyword succeeds    1min    10s    selenium_coam.software_rollback
    COAM selenium logout
    sleep    8min
    Capture BTS log
    COAM Wait for gnb ready and cell setup
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair    connection=GNB_OAM
    Wait until keyword succeeds    3min    20 sec    Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT_ID}
    COAM Navigate to login page via webUI
    ${version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    COAM selenium logout
    Should be Equal as Strings    ${current_version}    ${version['Active']}
    [Teardown]    Stop BTS log

Clear SW Build
    csn.Connect to    hostname=${testpc_host}    username=${testpc_user}    password=${testpc_pswd}    alias=TESTPC
    OperatingSystem.Empty Directory    ${SW_build_path}
    csn.disconnect    connection=TESTPC
    Common CMCC Test Case Teardown


Connect RU from Ctrl PC
    [Arguments]    ${ru_index}    ${pc_ip}   ${pc_username}    ${pc_password}    ${ru_ip}    ${ru_username}    ${ru_password}=${None}
    ssh.connect to    hostname=${pc_ip}    username=${pc_username}    password=${pc_password}    alias=PC_${ru_index}
    ssh.connect to    hostname=${ru_ip}    username=${ru_username}    password=${ru_password}    proxy=PC_${ru_index}    alias=PC_RU_${ru_index}

Enable SSH to RU from Ctrl PC
    [Arguments]    ${ru_index}    ${pc_ip}   ${pc_username}    ${pc_password}    ${ru_ip}    ${ru_username}    ${ru_password}
    ${com}            Set variable    ${tl.gnbs[0].dus[0].rus[${ru_index}].default_ssh_connection_details.port}
    ${com}            Set variable    ttyS${com}
#    Set Test variable    ${ru_password}    ${tl.gnbs[0].dus[0].rus[${ru_index}].default_ssh_connection_details.password}
    ${ru_info}        Create Dictionary    username=${ru_username}    password=${ru_password}
    ${ru_info}        Create List    ${ru_info}
#    run keyword and ignore error    Run   ps -ef|grep ${enable_ssh_script}|grep -v grep| awk '{print $2}' |xargs kill -9
    run keyword and ignore error    enable_ssh_to_ru    ${pc_ip}    ${pc_username}    ${pc_password}    ${com}   ${ru_ip}   ${ru_info}

Capture RU log from ctrl PC
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    ${ru_num}    RRH_common_keyword.COAM Get GNB RU Number    connection=GNB_OAM
    FOR    ${ru_index}    IN RANGE    ${ru_num}
        ${radio_type}    Set variable    ${tl.gnbs[0].dus[0].rus[${ru_index}].radio_type}
        ${pc_ip}    Set variable    ${tl.gnbs[0].dus[0].rus[${ru_index}].lmp_connection.addr}
        ${pc_username}    Set variable    ${tl.gnbs[0].dus[0].rus[${ru_index}].lmp_connection.username}
        ${pc_password}    Set variable    ${tl.gnbs[0].dus[0].rus[${ru_index}].lmp_connection.password}
        ${ru_ip}    Set variable    192.168.100.1
        ${ru_username}    Set variable    ${tl.gnbs[0].dus[0].rus[${ru_index}].default_ssh_connection_details.username}
        ${ru_password}    Set variable    ${tl.gnbs[0].dus[0].rus[${ru_index}].default_ssh_connection_details.password}
        Run keyword If    '${radio_type}' == 'RadioTypes.AZHM' or '${radio_type}' == 'RadioTypes.AEHB'
        ...               Enable SSH to RU from Ctrl PC    ru_index=${ru_index}
        ...                                                pc_ip=${pc_ip}
        ...                                                pc_username=${pc_username}
        ...                                                pc_password=${pc_password}
        ...                                                ru_ip=${ru_ip}
        ...                                                ru_username=${ru_username}
        ...                                                ru_password=${ru_password}
        Connect RU from Ctrl PC    ru_index=${ru_index}
        ...                        pc_ip=${pc_ip}
        ...                        pc_username=${pc_username}
        ...                        pc_password=${pc_password}
        ...                        ru_ip=${ru_ip}
        ...                        ru_username=${ru_username}
        ...                        ru_password=${ru_password}
        ${ru_file_path}    Capture RFSW Log On RU    connection=PC_RU_${ru_index}
        Download RU File To TestPC    ru_file_path=${ru_file_path}    connection=PC_RU_${ru_index}
    END


Upgrade Site and Check eNB Status
    [Arguments]    ${package_path}
    Selenium Login And Disable Screen Lock    download_dir=${CASE_LOG_PATH}    url=https://${sbts_addr}
    ...    username=${http_username}    password=${http_password}
    coam.update_software    sw_package=${package_path}    timeout=7200    connection=GNB_OAM
    Selenium Logout and kill process
    sleep       2min
    Log to Console    1:update
    wait until keyword succeeds     10min    2min    Check if FSIH Upgrade Successfully      target_version=${target_version}
    Log to Console    2:FSIH upgrade successfully
    sleep    5min
    Capture BTS log
    Log to console      3:start to check cell infor
    csn.Connect to    hostname=${sbts_addr}    username=${ssh_username}    password=${ssh_password}    alias=GNB_OAM
    RUn keyword and ignore error      Wait until keyword succeeds    10 min    20 sec
    ...      verify all cells should be onair    cell_type=${cell_type}    connection=GNB_OAM
    Wait until keyword succeeds    3min    20 sec    Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT_ID}
    Log to Console    3:cell on air
    csn.disconnect    connection=GNB_OAM
    Selenium Login And Disable Screen Lock    download_dir=${CASE_LOG_PATH}    url=https://${sbts_addr}
    ...    username=${http_username}    password=${http_password}
    ${version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    Selenium Logout and kill process
    ${stream}    string.fetch from left    ${target_version}    marker=_
    Run Keyword If    "${stream}"=="SBTS00"    Compare Trunk Version    version=${version['Active']}   target_version=${target_version}
    ...       ELSE    Should be Equal as Strings    ${target_version}    ${version['Active']}
    [Teardown]    Stop BTS log

Rollback Site and Check eNB Status
    [arguments]    ${current_version}
    Selenium Login And Disable Screen Lock    download_dir=${CASE_LOG_PATH}    url=https://${sbts_addr}
    ...    username=${http_username}    password=${http_password}
    wait until keyword succeeds    1min    10s    selenium_coam.software_rollback
    Selenium Logout and kill process
    sleep    3min
    Log to Console    1:rollback software
    wait until keyword succeeds     40min    2min    Check if FSIH Upgrade Successfully      target_version=${current_version['Active']}
    Log to Console    2:FSIH upgrade successfully
    sleep    8min
    Capture BTS log
    csn.Connect to    hostname=${sbts_addr}    username=${ssh_username}    password=${ssh_password}    alias=GNB_OAM
    RUn keyword and ignore error      Wait until keyword succeeds    10 min    20 sec
    ...      verify all cells should be onair    cell_type=${cell_type}    connection=GNB_OAM
    Wait until keyword succeeds    3min    20 sec    Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT_ID}
    Log to Console    3:cell on air
    csn.disconnect    connection=GNB_OAM
    Selenium Logout and kill process
    Selenium Login And Disable Screen Lock    download_dir=${CASE_LOG_PATH}    url=https://${sbts_addr}
    ...    username=${http_username}    password=${http_password}
    ${version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    Selenium Logout and kill process
    Should be Equal as Strings    ${current_version['Active']}    ${version['Active']}
    [Teardown]    Stop BTS log

Test Case Teardown for CMCC eNB
    [Arguments]    ${need_Btslog}=${True}    ${btslog_name}=btslog_${date}
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl    connection=lmp_OAM
    ...      bts_host=192.168.255.129    username=${http_username}      password=${http_password}
    Run keyword And Ignore Error    Run Keyword If Test Failed    COAM Save snapshot via rest api
    ...                             connection=lmp_OAM    log_path=${CASE_LOG_PATH}
    Run keyword If    ${need_Btslog}==${True}    Stop BTS log    btslog_name=${btslog_name}
    Run Keyword And Ignore Error    csn.disconnect    connection=RU
    Run Keyword And Ignore Error    csn.disconnect    connection=GNB_OAM
    run keyword and ignore error    COAM Teardown gnb connections
    run keyword and ignore error    COAM Teardown gnb connections    connection=lmp_OAM

Get eNB package link and Download to VM
    Selenium Login And Disable Screen Lock    download_dir=${TS_CASE_LOG_PATH}    url=https://${sbts_addr}
    ...    username=${http_username}    password=${http_password}
    ${current_version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    COAM selenium logout
    Set Test Variable    ${current_version}    ${current_version['Active']}
    ${stream}    string.fetch from left    ${target_version}    marker=_
	${FSM3_flag}    Run keyword and return status    should contain    ${target_version}    FSM3
    ${package_name}    Set Variable    ${target_version}_release_BTSSM_downloadable_CMCC_A50.zip
    ${stream_folder}    Run Keyword If   ${FSM3_flag}==True      Set Variable    ${stream}_FSM3
    ...    ELSE    Set Variable      ${stream}
    @{stream_list}=    Split String    ${target_version}    _    3
    ${package_stream_folder}     Set Variable If    '${stream_list}[2]'=='9990'     'SBTSCD00'
    ...                                     '${stream_list}[2]'=='9200'     'SBTS_FEINT'
    ...                                     '${stream_list}[2]'=='9000'     'SBTS_PSINT'
    ...                                     '${stream_list}[2]'=='9001'     'SBTS_PSINT2'
    ...                                     '${stream_list}[2]'=='9999'     ${stream_folder}
    ...                                     '${stream_list}[2]'=='0000'     ${stream_folder}
    ${package_full_link}    Set Variable      ${Package_link}/${package_stream_folder}/${target_version}/${package_name}
    ${package_path}    Download SW Build to VM    package_full_link=${package_full_link}
    [Return]      ${package_path}

Check if FSIH Upgrade Successfully
    [arguments]    ${target_version}
    csn.Connect to    hostname=${sbts_addr}    username=${ssh_username}    password=${ssh_password}    alias=GNB_OAM
    csn.send_command    command=ls /ffs/run/TargetBD*\.xml    connection=GNB_OAM
    ${result}     csn.read_output    connection=GNB_OAM
    ${stream}    string.fetch from left    ${target_version}    marker=_
    ${str}=	    Remove String	    ${target_version}    ${stream}
    should contain    ${result}    ${str}
    csn.disconnect    connection=GNB_OAM

Kill firefox process
    ssh.Connect to    ${tl.test_pc.default_ssh_connection_details.addr}
    ...               ${tl.test_pc.default_ssh_connection_details.username}
    ...               ${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=ute
    csn.send_command    command=ps -ef | grep firefox | awk '{print $2}' | xargs kill -9    connection=ute
    sleep   2s
    csn.disconnect      connection=ute

Selenium Logout and kill process
    Selenium Logout And Close Browser
    Kill firefox process

Check current eNB version
    Selenium Login And Disable Screen Lock    download_dir=${CASE_LOG_PATH}    url=https://${sbts_addr}
    ...    username=${http_username}    password=${http_password}
    ${current_version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    Selenium Logout and kill process
    [return]    ${current_version}

COAM Get BTS Counters via webUI
    [Arguments]    ${counter_id}    ${full_path}    ${dist_name}
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${counters}    selenium_coam.get_bts_counters_info    counter_id=${counter_id}    full_path=${full_path}
    ...                                                   dist_name=${dist_name}    timeout_for_loading_available_counters=60
    COAM selenium logout
    ${counters}    Get Dictionary Values    ${counters}
    [Return]    ${counters}

UE Attach to LTE Cell and Start Traffic
    [Arguments]     ${data_transfer_dl}     ${data_transfer_ul}     ${Expected_Throughput_DL}
    ...             ${Expected_Throughput_UL}    ${ue_index}=${0}
    ...             ${apn_address}=wap1nokiacom
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${ue_index_list}    Create List    ${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    Connect to Common Unit Master  alias=ASIK MASTER
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    Connect to Common Unit Master  alias=ASIK MASTER
    connect to gnb coam via ssl    connection=GNB_OAM
#    ${cell_id}    wait until keyword succeeds   1min    5s    get_ue_attached_cell_id_from_log    log_path=/tmp/5Grach.txt
#    ...    alias=ASIK MASTER    connection=GNB_OAM
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${data_transfer_dl}
    ...                       duration=${DURATION}    ue_index=${ue_index}    apn_address=${apn_address}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${data_transfer_ul}
    ...                       duration=${DURATION}    ue_index=${ue_index}    apn_address=${apn_address}
    Sleep    31min
    ${cnt_list_ul}    COAM Get BTS Counters via webUI    counter_id=${COUNTERS_LTE_TP[0]}[counter_id]
    ...                                                  full_path=${COUNTERS_LTE_TP[0]}[full_path]
    ...                                                  dist_name=${COUNTERS_LTE_TP[0]}[dist_name]
    ${cnt_list_dl}    COAM Get BTS Counters via webUI    counter_id=${COUNTERS_LTE_TP[1]}[counter_id]
    ...                                                  full_path=${COUNTERS_LTE_TP[1]}[full_path]
    ...                                                  dist_name=${COUNTERS_LTE_TP[1]}[dist_name]
    ${Expected_TP_UL}    Evaluate    ${Expected_Throughput_UL}*1024
    ${Expected_TP_DL}    Evaluate    ${Expected_Throughput_DL}*1024
    run keyword and continue on failure    Should Be True    ${cnt_list_ul[-1]} > ${Expected_TP_UL}
    run keyword and continue on failure    Should Be True    ${cnt_list_dl[-1]} > ${Expected_TP_DL}
    [Teardown]    Ue Stop DL UL Traffic and Detach    ue_index_list=${ue_index_list}

Get SCF Path
    ${stream}    Set Variable If    ${AF_PATH.count('SBTS22R2')}>${0}    SBTS22R2
    ...                             ${AF_PATH.count('SBTS22R3')}>${0}    SBTS22R3
    ...                             ${AF_PATH.count('SBTS22R4')}>${0}    SBTS22R4
    ...                             ${AF_PATH.count('SBTS00')}>${0}    SBTS00
    Set test variable    ${original_scf_path}    ${scf_dir}/SCF_${stream}.xml
    Set test variable    ${concurrent_scf_path}    ${scf_dir}/SCF_${stream}_CONCURRENT_MODE.xml

Update PA value
    [Arguments]    ${attenuator}      ${value}      ${ru_num}      ${port_num}=4    ${vender}=HBTE
    attenuator.setup_attenuator    attenuator=${attenuator}    alias=${vender}
    FOR      ${n}      IN RANGE      ${port_num}
          attenuator.set_attenuation
          ...      port=${tl.gnbs[0].dus[0].rus[${ru_num}].attenuation_ports[${n}]}
          ...      value=${value}
          ...      attenuator_device=${vender}
    END

UE Attach and Check traffic for Sleeping Cells
    [Arguments]    ${cell_used_in_test}=${None}    ${ignore_flag}=${True}    ${data_transfer_dl}=${DL_THROUGHPUT}
    ...            ${data_transfer_ul}=${UL_THROUGHPUT}    ${Expected_Throughput_DL}=${DL_SLP_TP}    ${ip_filter}=172.
    ...            ${Expected_Throughput_UL}=${UL_SLP_TP}    ${apn_address}=${apn1}    ${time}=3m   ${cap_index}=${2}
    ${cells_map_info}    get_cells_map_info_for_attach    dependent_cells=${cell_used_in_test}
    Return From Keyword If    ${cells_map_info} is None
    ${cells_id}    Get Dictionary Keys    ${cells_map_info}
    FOR    ${cell_id}    IN    @{cells_id}
        ${cell_info}    Set Variable    ${cells_map_info[${cell_id}]}
        ${nrCellIdentity}    Set Variable    ${cell_info['nrCellIdentity']}
        ${rmod_id}    Set Variable    ${cell_info['rmod_id']}
        ${attenuator_info}    Set Variable    ${PA_INFO}[${rmod_id}]
        ${UE_id}    Set Variable    ${cell_info['ue_id']}
        run keyword if  not '${attenuator_info}' == 'default'
        ...    Update PA value       attenuator=${attenuator_info}      value=${0}      ru_num=${rmod_id}-1
        run keyword and continue on failure    UE Attach and Check traffic for Sleeping Cell
        ...        nrCellIdentity=${nrCellIdentity}    data_transfer_dl=${data_transfer_dl}    data_transfer_ul=${data_transfer_ul}
        ...        Expected_Throughput_DL=${Expected_Throughput_DL}    Expected_Throughput_UL=${Expected_Throughput_UL}
        ...        ue_index=${UE_id}    apn_address=${apn_address}    time=${time}    cap_index=${cap_index}    ip_filter=${ip_filter}
        run keyword if  not '${attenuator_info}' == 'default'
        ...    Update PA value       attenuator=${attenuator_info}      value=${127}      ru_num=${rmod_id}-1
        Return From Keyword If    ${cell_used_in_test} is None and ${ignore_flag}
    END

UE Attach and Check traffic for Sleeping Cell
    [Arguments]    ${nrCellIdentity}    ${data_transfer_dl}=${DL_THROUGHPUT}    ${data_transfer_ul}=${UL_THROUGHPUT}
    ...            ${Expected_Throughput_DL}=${DL_SLP_TP}    ${Expected_Throughput_UL}=${UL_SLP_TP}    ${ue_index}=${0}
    ...            ${apn_address}=${apn1}    ${time}=3m   ${cap_index}=${0}    ${ip_filter}=${None}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${ui_version}    Set Variable If    '${ue_type}' =='xiaomi'    ${tl.ues[${ue_index}].capabilities[${1}]}    default
    ${ue_index_list}    Create List    ${ue_index}
    ADB Reboot UE      ue_index=${ue_index}
    Sleep       20s
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    ui_version=${ui_version}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    cap_index=${cap_index}
    Connect to Common Unit Master  alias=ASIK MASTER
    connect to gnb coam via ssl    connection=GNB_OAM
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${data_transfer_dl}    duration=${DURATION}
    ...                       ue_index=${ue_index}    apn_address=${apn_address}    cap_index=${cap_index}    ip_filter=${ip_filter}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${data_transfer_ul}
    ...                       duration=${DURATION}    ue_index=${ue_index}    apn_address=${apn_address}
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}     duration=${time}
    ${cell_id}    Create List    ${nrCellIdentity}
    run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    direction=DL    cells=${cell_id}
    ...                                    log=${tput_log}    target_throughput=${Expected_Throughput_DL}
    run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    direction=UL    cells=${cell_id}
    ...                                    log=${tput_log}    target_throughput=${Expected_Throughput_UL}
    [Teardown]    Ue Stop DL UL Traffic and Detach    ue_index_list=${ue_index_list}


Check RMOD runtime log by radios
    [Arguments]    ${connection}=GNB_OAM      ${alias}=ASIK Master
    Run Keyword And Ignore Error      COAM Teardown gnb connections    connection=${connection}
    Run Keyword And Ignore Error      csn.disconnect      connection=${alias}
    Connect to gnb coam via ssl
    &{hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    ${count_RUs}    Get length    ${list_RUs}
    FOR      ${i}      IN RANGE      ${count_RUs}
        ${ru_idx}      Evaluate      ${i}+1
        &{ru_info}    COAM get ru detial info by ru index     ru_index=${ru_idx}   connection=${connection}
        ${productName}      Set Variable    ${ru_info['productName']}
        Run keyword IF      "${productName}"=="AEHC"      Check RMOD runtime      ru_index=${ru_idx}
    END
    [Teardown]      Run keywords      Run Keyword And Ignore Error      csn.disconnect      connection=${alias}
    ...      AND      COAM Teardown gnb connections    connection=${connection}

Check RMOD runtime
    [Arguments]    ${ru_index}      ${download_dir}=${TS_CASE_LOG_PATH}
    ...      ${timeout}=300      ${alias}=ASIK Master
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_alias=RU_${ru_index}    ru_index=${ru_index}
    ${rfsw_log_path_on_ru}   Capture RFSW Log On RU    connection=RU_${ru_index}    timeout=${timeout}
    Sleep   10 sec
    ${rfsw_log_path_on_testPC}    Download RU File To TestPC    ru_file_path=${rfsw_log_path_on_ru}
    ...                                                         connection=RU_${ru_index}
    ...                                                         download_dir=${download_dir}
    Set Task Variable      ${rfsw_log_path_on_testPC}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${snapshot_unzip_file_path}    Join Path    ${TS_CASE_LOG_PATH}    RFSW_${timestamp}
    Run   rm -rf ${snapshot_unzip_file_path}
    extract zip file    ${rfsw_log_path_on_testPC}    ${snapshot_unzip_file_path}
    ${RFSW_runtime_file_path}    Join Path    ${snapshot_unzip_file_path}    1011_runtime
    Run   rm -rf ${RFSW_runtime_file_path}
    extract zip file    ${snapshot_unzip_file_path}/1011_runtime.zip    ${RFSW_runtime_file_path}
    ${output}      run     xzcat ${RFSW_runtime_file_path}/runtime_DEFAULT.log.xz|grep 'Invalid prach config'
    should be empty      ${output}
    [Teardown]      Run Keyword And Ignore Error      csn.disconnect      connection=${alias}
