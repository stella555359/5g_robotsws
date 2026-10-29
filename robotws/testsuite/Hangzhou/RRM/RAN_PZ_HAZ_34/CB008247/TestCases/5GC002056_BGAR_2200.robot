*** Settings ***
Documentation      Author: jia-rebecca.liu@nokia-sbell.com
...                squad group: SG_03
...                feature : CB010602


Suite Setup       Run Keyword     Common Suite Setup for COAM 8247    ModifySCF_Beforecommission=False
...                                                                   Is_Swconfig=False

Suite Teardown          Run Keyword    Common Suite Teardown for COAM

Resource         ../Resources/CB008247_case_steps_SG3.robot



*** Variables ***
${10602_wireshark_01}              10602_wireshark_01
${B4003_wireshark_01}              B4003_wireshark_01
${B4003_wireshark_02}              B4003_wireshark_02
${C007_wireshark_01}               C007_wireshark_01
${dlexpect_tp_3741199999}               1100
${dl_tput_multiue_3741199999}           1100M
@{throughput_C007_3741199999}           860     500     100
${Gnb_cell_dist_3741199999}             MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-37401
${allow_fault_list}                     6327

*** Test Cases ***
[1]5GC002056_BGAR_2200_C_007_PM_counter_impact_after_2200_activated
    [Documentation]
    ...    this test case is to verify interworking online modify eirp with 2200 enable.
    [Tags]      C007
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=6327
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Case Step for C_007
    [Teardown]    Run Keywords
    ...    robot_common_operations.Common Case Teardown    AND
    ...    Case TearDown C007

*** Keywords ***
####                          2200_c_007                               ####
Case Step for C_007
    [Arguments]
#    ...            ${Test_PC_IP}=${tl.test_pc.default_ssh_connection_details.addr}
#    ...            ${Test_PC_username}=${tl.test_pc.default_ssh_connection_details.username}
#    ...            ${Test_PC_password}=${tl.test_pc.default_ssh_connection_details.password}
    Common Case TestLine Setup    ModifySCF_Beforecommission=True
    ...                           golden_scf_name=MRBTS-${MRBTS_ID}_${release_info}.xml
    ...                           ParameterToDelete=${ParameterToDelete_C007_${MRBTS_ID}}
    ...                           ListToAdd=${ListToAdd_C007_${MRBTS_ID}}
    ...                           ParamterToModify=${ParamterToModify_C007_${MRBTS_ID}}
    Check after online_modify_parameter GNB cell not restart     PARA_Modify_online=${PARA_Modify_online_C007_${MRBTS_ID}}
    sleep    180s
#    put btslog_ini file to ute
#    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
#    Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
#    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
#    ...      Test_PC_password=${Test_PC_password}
#    ...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
#    ...      btslog_launcher_path=/opt/btslog/btslog
    Prepare MultiUE with client
    MCS SETUP AND SET ATT C007
    ${cpif_log_C007_01}=     attach UE and capture wiresharklog with new way    wiresharklog=${C007_wireshark_01}
    BuiltIn.Set Test Variable    ${cpif_log_C007_01}
    Analysis 2200_C007 log    file_path=${cpif_log_C007_01}
    Start MUE dltraffic with appserver    ue_addr=${upd_info}[Param][IP]     dl_port=${DL_PORT}    dl_throughput=${dl_tput_multiue_${MRBTS_ID}}
    Wait Until Keyword Succeeds   1m   10s    Check one UE traffic with pioneer client    tput_target=${throughput_C007_${MRBTS_ID}}[0]
    sleep    60s
    Wait Until Keyword Succeeds   6m   10s    Check throughput reduce    Expect_Control_Tput=${throughput_C007_${MRBTS_ID}}[1]
    ...                                                                  Expect_compare_Tput=${throughput_C007_${MRBTS_ID}}[2]
    stop traffic and detach MultiUE0
    Modify EIRP Segments Configuration Online    dist_id=${Gnb_cell_dist_${MRBTS_ID}}
    sleep    180s
    MultiUE one Attach with client    UE_mode=${SA_attach_mode}
    Start MUE dltraffic with appserver    ue_addr=${upd_info}[Param][IP]     dl_port=${DL_PORT}    dl_throughput=${dl_tput_multiue_${MRBTS_ID}}
    Wait Until Keyword Succeeds   1m   10s   Check one UE traffic with pioneer client    tput_target=${throughput_C007_${MRBTS_ID}}[0]
    sleep    50s
    Wait Until Keyword Succeeds   6m   10s    Check throughput reduce    Expect_Control_Tput=${throughput_C007_${MRBTS_ID}}[1]
    ...                                                                  Expect_compare_Tput=${throughput_C007_${MRBTS_ID}}[2]
    Check the PM counter shuould not be 0    counter_id=${counter_id_C007_1_${MRBTS_ID}}    dic_path=${counter_dic_path_C007_${MRBTS_ID}}
    ...                                      counter_lenth=7
    Check the PM counter shuould be 0    counter_id=${counter_id_C007_0_${MRBTS_ID}}    dic_path=${counter_dic_path_C007_${MRBTS_ID}}
    ...                                  out_of_beamid=6
    stop traffic and detach MultiUE0
    [Teardown]    Run keywords
    ...    Run Keyword And Ignore Error    stop traffic and MCS teardown with new way    mcs_type=${mcs_type}
    ...    AND    Common Case TestLine Setup    is_commission=True
    ...                                         golden_scf_name=MRBTS-${MRBTS_ID}_${release_info}.xml

MCS SETUP AND SET ATT C007
    [Arguments]
    ${mcs_type}=    mcs_common.Get MCS Type
    set suite variable      ${mcs_type}
    Run keyword if    '${mcs_type}'=='haojin'    HAOJIN MCS SETUP AND SET ATT for ONE UE    mcs_type=${mcs_type}
    ...    att_value_1=${25}     att_value_2=${25}
    ...    P1_out=${13}    P2_out=${14}    vertical_1=${96}    horizontal_1=${5}
    ...    P3_out=${15}    P4_out=${16}    vertical_2=${96}    horizontal_2=${15}
    Run keyword if    '${mcs_type}'=='hbte'      HBTE MCS SETUP Phases AND SET ATT    mcs_type=${mcs_type}
    ...    vertical_distance=${2.0}   horizontal_distance=${0.5}
    ...    att_value1=${30}    att_value2=${30}    vertical_angle=${96}
    ...    first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${5}
    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${15}

Check throughput reduce
    [Arguments]    ${Expect_Control_Tput}    ${Expect_compare_Tput}
    ${dlul_tp_l2l0}      Check one UE traffic with pioneer client    tput_target=${Expect_compare_Tput}
    should be true    ${Expect_Control_Tput} > ${dlul_tp_l2l0}

stop traffic and detach MultiUE0
    [Arguments]    ${ue}=${uegroup}[0]
    Stop traffic with appserver    iperf_port=${DL_PORT}
    sleep    1s
    Detach dingli_UE0 with poweroff    ue=${ue}

Analysis 2200_C007 log
    [Arguments]    ${file_path}
    ${nrofPorts}=    Get CSIRS_nrofPorts from CPIF    file_path=${file_path}
#    should contain    ${nrofPorts}    p8     # enable actTddCsiImRm impact csirs num
    should contain x times    ${nrofPorts}    p8    4
    ${cdm_Type}=     Get CSIRS_cdm_Type from CPIF     file_path=${file_path}
    should contain    ${cdm_Type}    2
    ${n1-n2}=        Get CSIRS_n1_n2 from CPIF        file_path=${file_path}
    should contain    ${n1-n2}       1

Modify EIRP Segments Configuration Online
   [Arguments]     ${dist_id}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}
    ...                    username=${WEBUI_NAME}
    ...                    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.disable_message_box
    Wait Until Keyword Succeeds    5min   5s
    ...    selenium_coam.set_parameter_value    dist_name=${dist_id}
    ...    filter_param=Number of cell segment edges in azimuth
    ...    new_value=2
    Wait Until Keyword Succeeds    5min   5s
    ...    selenium_coam.set_parameter_value    dist_name=${dist_id}
    ...    filter_param=Cell segment edge azimuth 1
    ...    new_value=20
    Run Keyword And Ignore Error    selenium_coam.delete_parameter    dist_name=${dist_id}
    ...    filter_param=Cell segment edge azimuth 2
    Run Keyword And Ignore Error    selenium_coam.remove_element    dist_name=${dist_id}
    ...    filter_param=List of EIRP control power reduction factor per cell segment
    ...    node_index=0
    Run Keyword And Ignore Error    selenium_coam.remove_element    dist_name=${dist_id}
    ...    filter_param=List of EIRP control power reduction factor per cell segment
    ...    node_index=1
    Run Keyword And Ignore Error    selenium_coam.remove_element    dist_name=${dist_id}
    ...    filter_param=List of EIRP control power reduction factor per cell segment
    ...    node_index=2
    Wait Until Keyword Succeeds    5min   5s
    ...    selenium_coam.set_parameter_value    dist_name=${dist_id}
    ...    filter_param=Cell segment edge elevation 0
    ...    new_value=33
    Wait Until Keyword Succeeds    5min   5s
    ...    selenium_coam.set_parameter_value    dist_name=${dist_id}
    ...    filter_param=Cell segment edge elevation 1
    ...    new_value=30
    sleep    3s
    selenium_coam.validate_plan
    sleep    3s
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    5s
    [Teardown]    selenium_coam.logout

Check the PM counter shuould not be 0
    [Arguments]    ${counter_id}    ${dic_path}    ${counter_lenth}
    Connect to gnb coam via ssl
    FOR    ${index}    IN RANGE    ${counter_lenth}
        ${counter_value} =    get_coam_pmcounter.get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM
         ...    dic_path=${dic_path[0]}    timeout=600
        Should be true    ${counter_value[0]} > ${0}
    END
    [Teardown]    COAM Teardown gnb connections

Check the PM counter shuould be 0
    [Arguments]    ${counter_id}    ${dic_path}    ${out_of_beamid}
    Connect to gnb coam via ssl
    FOR    ${index}    IN RANGE    ${out_of_beamid}    64
        ${index_tmp}=    set variable if    ${index}<10    ${0}${index}    ${index}
        ${counter_value} =    get_coam_pmcounter.get_pm_counter_values    counter_id=${counter_id[0]}${index_tmp}    connection=GNB_OAM
         ...    dic_path=${dic_path[0]}    timeout=600
        Should be equal    ${counter_value[0]}    ${0}
    END
    [Teardown]    COAM Teardown gnb connections

Case TearDown C007
    [Arguments]     ${gnb_list}=${gnb_list}    ${log_path}=${epc_log_path}
    Run Keyword And Ignore Error     Common Case TestLine Setup    ModifySCF_Beforecommission=True
    ...                              golden_scf_name=MRBTS-${MRBTS_ID}_${release_info}.xml
    ...                              ParameterToDelete=${ParameterToDelete_Recovery_C007_${MRBTS_ID}}
    ...                              ListToAdd=${ListToAdd_Recovery_C007_${MRBTS_ID}}
    ...                              ParamterToModify=${ParamterToModify_Recovery_C007_${MRBTS_ID}}
    Run Keyword And Ignore Error     stop traffic and detach UE
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure
    ...    COAM Save all gnb snapshot via api    gnb_list=${gnb_list}    log_path=${log_path}
#    Run Keyword And Ignore error    Stop BTSlogs Collection And Download Logs To Log Server
#    run keyword and continue on failure     Check ERR Or WRN From Syslog    sys_logs_path=${UTE_syslogs_path}
    Run keyword and ignore error    Tear down the all connections
    Run keyword and ignore error    CI_interface.Common Case Teardown
