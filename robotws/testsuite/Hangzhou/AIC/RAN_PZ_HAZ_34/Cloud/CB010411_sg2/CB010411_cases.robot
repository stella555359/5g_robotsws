*** Settings ***
Documentation
...   author: lu.1.yu@nokia-sbell.com
...   contact: lu.1.yu@nokia-sbell.com

Test Setup    Case Setup
Test Teardown    Case Teardown


Force Tags
...    PY310
...    CLOUD_5G_AIC                               #TL_TYPE
...    STATE_ON_AIR                               #gNB_STATE
...    5G_RAN                                     #CA
...    master_allincloud_int                      #vDU_Branch_name
...    RAN_RD_VRF_HAZ4                            #Orginazation
...    TA_LEVEL_22_FULL_AUTOMATED_CIT_CRT         #Detailed Automation Level

Test Timeout    2h

Library           DateTime
Library           json
Library           taf.config.scf                        WITH NAME    scf
Library           taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu
Library           taf.hw.fhgw.cli                       WITH NAME    issh
Library           taf.transport.ssh                     WITH NAME    tafssh
Library           testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.gnb_alarm.AlarmWatchdog    WITH NAME    AlarmWatchdog
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_state.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_vdu.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_cu.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/common_trans.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_bts.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot


*** Variables ***
${UL_THROUGHPUT}    200M
${DL_THROUGHPUT}    1500M
${UL_EXPECT}    10
${DL_EXPECT}    50

${scf_path}       /home/ute/Downloads/SCF


*** Test Cases ***
[1]CB008247-5G-B#B1_004_Check_UE_attach_to_5Gcell_success_with_SA_mode_when_UE_specific_CSIRS=0
#    CU Full Commission    path_of_commission_file=${scf_path}/CU_SCF_0.250.xml
#    vDU Full Commission SCF     scf_file=${scf_path}/vDU_SCF_0.300.xml
    CU Commission SCF
	vDU Commission SCF
    wait until keyword succeeds     40min    30s     vDU Verify All Cells Status Should Be Onair
    UE trafic and check tuput    throughput_ul=${UL_THROUGHPUT}
    ...                           throughput_dl=${DL_THROUGHPUT}
    ...                           target_throughput_ul=${UL_EXPECT}
    ...                           target_throughput_dl=${DL_EXPECT}

[1][1.0] CB012269_C_7_Interworking with CB008662 Adaptive re-transmission
    sleep    2s

*** Keywords ***
Case Setup
    ${START_TIME}    Get time    exclude_millis=yes
    Set Suite Variable    ${START_TIME}
    ${SUITE_LOG_DIRECTORY}    Get A Directory
    Set Suite Variable    ${SUITE_LOG_DIRECTORY}
    ${status}    run keyword and return status    vDU Verify All Cells Status Should Be Onair
    VDU Rest Login
    ${scf_path}    Get A Directory    scf
    ${scf_file_with_fullpath}   vdu.Get_Current_Plan_File    local_dir_path=${scf_path}  filename=scf.xml  include_runtime_data=${False}
    set test variable    ${scf_file_with_fullpath}
    scf.Load_Scf    file_path=${scf_file_with_fullpath}
    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${scf_file_with_fullpath}
    set test variable    ${mrbts_id}
	run keyword if    not ${status}    run keywords    vdu.Reset VDU    AND
	...    wait until keyword succeeds     25min    30s     vDU Verify All Cells Status Should Be Onair
    Run Keyword And Ignore Error    Fix OCP Syslog Format
    [Teardown]  run keyword and ignore error    vDU Rest Logout

Case Teardown
    [Documentation]    Case Teardown
    vDU Verify All Cells Status Should Be Onair

UE trafic and check tuput
    [Arguments]  ${throughput_ul}    ${throughput_dl}    ${target_throughput_ul}    ${target_throughput_dl}
    log to console    \n***Prepare UE_1***
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
    Wait Until Keyword Succeeds    2min    5s     power_ue.Prepare UE     ue_type=${ue_type}    ue_index=${0}
    ${5Grach_ed}     power_ue.UE Attach     ue_type=${ue_type}    log_type=Iperf    power_reset=True    ue_index=${0}
    power_ue.Start traffic     ue_type=${ue_type}     direction=ul     throughput=${throughput_ul}     duration=2000    process_num=5
    power_ue.Start traffic     ue_type=${ue_type}     direction=dl     throughput=${throughput_dl}     duration=2000
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=5m    check_source=Iperf
    run keyword and continue on failure     power_ue.Check Tput     ue_type=${ue_type}
    ...                     direction=ul     cells=13090817    log=${tput_log}
    ...                     target_throughput=${target_throughput_ul}    check_source=Iperf
    run keyword and continue on failure     power_ue.Check Tput     ue_type=${ue_type}
    ...                     direction=dl     cells=13090817    log=${tput_log}
    ...                     target_throughput=${target_throughput_dl}    check_source=Iperf
    power_ue.Stop traffic     ue_type=${ue_type}     direction=dl
    power_ue.Stop traffic     ue_type=${ue_type}     direction=ul

CU Commission SCF
    [Arguments]   ${gnb_index}=${0}
    ...            ${wait_for_completion}=False
    cu.connect_to     host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...    port=443
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...    secure=${True}
    cu.perform_commissioning     scf_file=${scf_path}/CU_SCF_0.250.xml        timeout=1200
    ...                          wait_for_completion=${wait_for_completion}
	sleep    1min

vDU Commission SCF
    [Arguments]   ${gnb_index}=${0}     ${vdu_index}=${0}
    ...            ${wait_for_completion}=False
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}    alias=${conn_alias}
    vdu.perform_commissioning    scf_file=${scf_path}/vDU_SCF_0.300.xml    vdu_connection=${conn_alias}    timeout=1200
    ...                          wait_for_completion=${wait_for_completion}
	sleep    1min
