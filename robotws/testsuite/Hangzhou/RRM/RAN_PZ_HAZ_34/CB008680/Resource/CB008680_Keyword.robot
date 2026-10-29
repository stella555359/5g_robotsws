# @Time    : 2022/10
# @Author  : xudong.1.li
# @Email   : xudong.1.li@nokia-sbell.com
# @File    : CB008680_5G_common_keywords.robot
# @Software: PyCharm
*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/gnb_classical_hangzhou.robot
Library     taf.selenium.sbts    WITH NAME    selenium_sbts



*** Keywords ***
UE Attach And Check Throughput With Detach bk
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    global_cell_id(Global cell ID): 1
    ...    ul_tp: 50M    ul_tp_threshold: 15
    ...    dl_tp: 300M    dl_tp_threshold: 220
    ...    [Return]    ul_tp: 20    dl_tp; 200
    [Arguments]    ${global_cell_id}    ${ul_tp}   ${ul_tp_threshold}
    ...    ${dl_tp}    ${dl_tp_threshold}    ${attach_mode}=SA    ${iperf_type}=via_command
    ...    ${ul_duration}=200    ${dl_duration}=200    ${ue_index}=${0}
    Connect to gnb coam via ssl
    ${nr_cell_identity}    Get NR Cell Identity Via Index "${global_cell_id}"
    ${ue_type}    translate power ue type from testline    ${ue_index}
    #power_ue.Prepare UE    ue_type=${ue_type}
    Run Keyword And Ignore Error   _Detach Qualcomm Mobile    ue_index=${ue_index}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=0
    Reboot UE If no UE IP
    Wait Until Keyword Succeeds  3x  150s  Run Keyword If    '${attach_mode}'=='NSA'    power_ue.Verify attach    ue_type=${ue_type}
    ...    5Grach_ed=${5Grach_ed}    4G_check=True
    ...    ELSE    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False

    Run Keyword If  '${attach_mode}'=='SA'  Get nrCellIdentity for SA UE  nrCId=${nr_cell_identity}    
    Run Keyword If    '${iperf_type}'=='via_command'    UE Start UL Traffic    throughput=${ul_tp}    ul_time=${ul_duration}
    ...    ul_port=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    ...    ELSE    power_ue.Start traffic   ue_type=${ue_type}   direction=ul   throughput=${ul_tp}    duration=${ul_duration}
    UE Start DL Traffic    throughput=${dl_tp}    dl_time=${dl_duration}    dl_port=${tl.ues[${ue_index}].iperf_details.port}
    Sleep    30s
    power_ue.Check throughput    ue_index=${ue_index}    direction=ul    ue_type=${ue_type}    throughput=${ul_tp_threshold}
    ...    cellid=${nr_cell_identity}
    power_ue.Check throughput   ue_index=${ue_index}    direction=dl    ue_type=${ue_type}    throughput=${dl_tp_threshold}
    ...    cellid=${nr_cell_identity}
    Connect To BTS Csn Via Lmp
    ${ul_tp}    Calculate UL Throughoutput Re    alias=ASIK Master    sample=10    start_offset=3
    ...    sleep_time=5    cellid=${nr_cell_identity}    log_type=Aasyslog
    ${dl_tp}    Calculate DL Throughoutput Re    alias=ASIK Master    sample=10    start_offset=3
    ...    sleep_time=5    cellid=${nr_cell_identity}    log_type=Aasyslog
    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master
    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master
    #...    AND    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}   ue_index=${ue_index}
    ...    AND    Run Keyword And Ignore Error   _Detach Qualcomm Mobile    ue_index=${ue_index}
    [Return]    ${ul_tp}    ${dl_tp}

CB008680 Common Configuration Setting
    [Documentation]    Author: xudong.1.li@nokia-sbell.com
    [Arguments]
    ...    ${frameStructureType_value}     ${guardPeriodLength_value}    ${tdLteUlDlConfig_value}
    ...    ${ulDlDataSlotRatio_value}    ${timingAdvanceOffset_value}    ${dist}
    ...    ${frameStructureType}=Frame Structure Type    ${frameStructureType_abbr}=frameStructureType
    ...    ${guardPeriodLength}=Guard Period length      ${guardPeriodLength_abbr}=guardPeriodLength
    ...    ${tdLteUlDlConfig}=TDLTE UL-DL configuration        ${tdLteUlDlConfig_abbr}=tdLteUlDlConfig
    ...    ${ulDlDataSlotRatio}=UL to DL logical data slot ratio      ${ulDlDataSlotRatio_abbr}=ulDlDataSlotRatio
    ...    ${timingAdvanceOffset}=Timing Advance Offset    ${timingAdvanceOffset_abbr}=timingAdvanceOffset
    Selenium Login Sbts
    selenium_sbts.set_parameter_value
    ...    dist_name=${dist}    filter_param=${frameStructureType}
    ...    abbr=${frameStructureType_abbr}   new_value=${frameStructureType_value}
    selenium_sbts.set_parameter_value
    ...    dist_name=${dist}    filter_param=${guardPeriodLength}
    ...    abbr=${guardPeriodLength_abbr}   new_value=${guardPeriodLength_value}
    selenium_sbts.set_parameter_value
    ...    dist_name=${dist}    filter_param=${tdLteUlDlConfig}
    ...    abbr=${tdLteUlDlConfig_abbr}   new_value=${tdLteUlDlConfig_value}
    selenium_sbts.set_parameter_value
    ...    dist_name=${dist}    filter_param=${ulDlDataSlotRatio}
    ...    abbr=${ulDlDataSlotRatio_abbr}   new_value=${ulDlDataSlotRatio_value}
    selenium_sbts.set_parameter_value
    ...    dist_name=${dist}    filter_param=${timingAdvanceOffset}
    ...    abbr=${timingAdvanceOffset_abbr}   new_value=${timingAdvanceOffset_value}

Selenium_sbts Valifate And Activate Plan
    selenium_sbts.validate_plan
    sleep   1min
    selenium_sbts.activate_plan    activate_plan_despite_errors=True    timeout=300

Set Active SW Version
    Connect to gnb coam via ssl
    ${Active_SW_version}    coam.get_sw_version    connection=GNB_OAM
    Set Suite Variable    ${Active_SW_version}

Selenium Login Sbts
    [Documentation]    Author: xudong.1.li@nokia-sbell.com
    [Arguments]    ${username}=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...   ${SW_version}=${Active_SW_version}    ${download_dir}=${TS_CASE_LOG_PATH}/selenium_logs    ${timeout}=${60}
    ...    ${host}=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ${stream}    get stream from version    ${SW_version}
    ${version}=    Set Variable If
    ...     '${stream}'=='SBTS22R2'        SBTS22R2
    ...     '${stream}'=='SBTS22R3'        SBTS22R3
    ...     '${stream}'=='SBTS22R4'        SBTS22R4
    ...     SBTS23R1
    selenium_sbts.enable_virtual_display
    selenium_sbts.login    url=https://${host}
    ...                    username=${username}
    ...                    password=${password}
    ...                    download_dir=${download_dir}
    ...                    timeout=${timeout}
    ...                    version=${version}
    selenium_sbts.disable_message_box
    selenium_sbts.disable_screen_lock

Selenium Logout Sbts
    [Arguments]
    Run Keyword And Ignore Error    selenium_sbts.close_start_up_view_window    timeout=600
    Run Keyword And Ignore Error    selenium_sbts.logout
    Run Keyword And Ignore Error    selenium_sbts.disable_virtual_display
    Run Keyword And Ignore Error    selenium_sbts.close_browser

Lock Unlock lte Cell
    [Documentation]    Author: xudong.1.li@nokia-sbell.com
    [Arguments]  ${dist_name}    ${if_lock}=locked
    Connect to gnb coam via ssl    bts_host=${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
    ...    connection=ENB_OAM
    Modify Parameter On BTS With Activate
    ...    dist_name=${dist_name}    parameter=administrativeState    value=${if_lock}
    ...    connection=ENB_OAM
    [Teardown]  Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=ENB_OAM

Reset UE First
    [Documentation]    Author: xudong.1.li@nokia-sbell.com
    [Arguments]     ${ue_index}=${0}     ${hostname}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...     ${serial_number}=${tl.ues[${ue_index}].serial_number}
    log to console  \nReset UE\n
    Connect to control pc via cygwin     hostname=${hostname}     ue_index=${ue_index}
    csn.send_command     command=adb -s ${serial_number} reboot     connection=cygwin
    sleep     90s
    csn.disconnect     connection=cygwin

_Detach Qualcomm Mobile
    [Arguments]    ${ue_index}=${0}
    UE Dettach and Stop traffic  ue_index=${ue_index}
    
Case Teardown
    [Arguments]     ${json_file}
    Run keyword And Ignore Error  UE Dettach and Stop traffic
    robot_common_operations.Common Case Teardown
    Run Keyword And Ignore Error  Unbarred nr cell  cell_idx=${1} 
    Run Keyword And Ignore Error  Unbarred nr cell  cell_idx=${2}
    Connect to gnb coam via ssl 
    Modify Parameter On BTS With Activate    dist_name=${NR_AMF_Dist}    parameter=administrativeState
    ...    value=Unlocked    connection=GNB_OAM
    Run Keyword And Ignore Error    COAM Teardown gnb connections
    Run Keyword If  ${release}  Delete New PARAMS from json  ${json_file}
#    Run Keyword If  ${release}  Run Keyword And Ignore Error  OperatingSystem.Run  sed -i '/"comb": "comb2",/d' ${json_file}
#    Run Keyword If  ${release}  Run Keyword And Ignore Error  OperatingSystem.Run
#    ...  sed -i '/"srsPowerThresholdForUlBm": "-1320",/d' ${json_file}
    scf.Modify json file after testing  json_file=${json_file}
    Lock Unlock lte Cell    dist_name=${lte_cell2_dist}    if_lock=unlocked

