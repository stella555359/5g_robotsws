*** Settings ***
Documentation
...               author: Steven Liu
...               contact: steven.liu@nokia-sbell.com
...               squad group: MMW_SG_04
Library           ute_admin
Library           taf.sbts.oam.coam.admin    WITH NAME    coam
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Commercial_mobile_phone_adb_common_keywords.robot
#Resource          ../../../../../resources/sites/Ulm/Common/connect.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/aasyslog.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Throughput_checking_from_GNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot
Resource          ../../../../RRM/RAN_PZ_HAZ_34/5GC001937_OTA/resources/5GC001937_keywords.robot

*** Variables ***
${MRBTS_ID}            ${tl.gnbs[0].instance_id}
${DU_IP}               ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${WEBEM_USERNAME}      ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBEM_PASSWORD}      ${tl.gnbs[0].cu.oam_http_connection_details.password}
${scf_path}           ${CURDIR}/../../../../commissionings/HGZ/7_5_UTE5G402T700/



*** Keywords ***
Input default SCF
    [Timeout]  20 min
    [Arguments]    ${scf_800}     ${scf_999}    ${timeout}=10 min
    ${conn}    Connect to DU
    ${version}    coam.get_sw_version     connection=${conn}
    ${version_list}    split string    ${version}    _
    ${if_common_load}     run keyword and return status    should contain    ${version_list[0]}    SBTS22R2
    ${scf1}    set variable if    ${if_common_load}    ${scf_path}${scf_800}
    ...    ${scf_path}${scf_800}${scf_999}
    set suite variable    ${scf1}
    BuiltIn.Log    \n Input default SCF \n    console=yes
    run keyword and ignore error    COAM Commission with scf file    scf_file_path=${scf1}    connection=${conn}
    BuiltIn.Log    \n wait until gnb cell on air \n    console=yes
    wait until keyword succeeds    ${timeout}    30sec   Cloud DU connect to gnb coam via ssl    connection=${conn}
    wait until keyword succeeds    ${timeout}    30sec   COAM Check GNB cell on air    connection=${conn}
    [Teardown]    Disconnect from DU

Connect to DU
    [Arguments]    ${alias}=cOAM_admin
    ${conn}=    coam.connect_to
    ...    bts_host=${DU_IP}
    ...    username=${WEBEM_USERNAME}
    ...    password=${WEBEM_PASSWORD}
    ...    name=${alias}
    [Return]    ${conn}

Disconnect from DU
    [Arguments]    ${alias}=cOAM_admin
    coam.teardown     connection=${alias}

honor attach
    [Arguments]  ${ue_index}=${0}    ${ue_type}=huawei
    Log To Console    honor attach
    power_ue.Prepare UE    ue_type=${ue_type}
    ${5Grach_ed0}    power_ue.UE Attach    ue_type=${ue_type}
    Log To Console    Verify attach
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed0}    4G_check=False

UE check throughput
    [Arguments]    ${tp_direction}    ${exp_ul}=50    ${exp_dl}=220
    log to console    Check throughput
    ${all_tp}    Get ul and dl peak and ave throughput and return result
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'    Run keyword and continue on failure
    ...      should be true    ${all_tp[0]}>${exp_dl}
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    Run keyword and continue on failure
    ...     should be true    ${all_tp[3]}>${exp_ul}

UE start traffic
    [Documentation]    used for UE start traffic, ul/dl/both.
    [Arguments]    ${ue_index}=${0}    ${protocol}=udp    ${tp_direction}=both    ${duration}=600    ${iperf_type}=via_command
    ...    ${ul_throughput}=100M    ${dl_throughput}=2048M    ${time}=20s    ${ue_type}=huawei
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Start traffic    ue_index=${ue_index}
    ...    direction=ul    throughput=${ul_throughput}    duration=${duration}    ue_type=${ue_type}    iperf_type=${iperf_type}
    ...    protocol=${protocol}
    sleep    1s
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'   power_ue.Start traffic    ue_index=${ue_index}
    ...     direction=dl    throughput=${dl_throughput}    duration=${duration}    ue_type=${ue_type}    protocol=${protocol}
    sleep    ${time}
