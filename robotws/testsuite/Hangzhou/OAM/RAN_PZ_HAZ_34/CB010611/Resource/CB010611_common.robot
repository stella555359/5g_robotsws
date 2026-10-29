*** Settings ***
Documentation     author: ruiyu.han
...               contact: ruiyu,han@nokia-sbell.com
...               squad group: SG_07
...               feature : CB010611

Library           OperatingSystem
Library           Collections
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Variables         testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB010611/Resource/resource.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/rrm_common.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_log.robot


*** Keywords ***
Case Setup for CB010611
    robot_common_operations.Common Case Setup
    Wait Until Keyword Succeeds    5min    20s      COAM WEBUI Login
    COAM Login
    CI_interface.Common Suite Setup
    wait until keyword succeeds    15min    1min   COAM Check all cells should be onair    connection=COAM

Case Teardown for CB010611
    Check Extra Reset From Blackbox
#    run keyword if test failed    run keyword and ignore error    Save Snapshot logs On COAM    IP_WEBUI=${WEBUI_ADDR}
#    run keyword if test failed    run keyword and ignore error    Screenshot for case fail
    Run Keyword If   $KEYWORD_STATUS=='FAIL'   run keyword and ignore error    Save Snapshot logs On COAM    IP_WEBUI=${WEBUI_ADDR}
    Run Keyword If   $KEYWORD_STATUS=='FAIL'   run keyword and ignore error    Screenshot for case fail
    run keyword and ignore error    COAM WEBUI Logout
    Run Keyword and Ignore Error   COAM Logout
    run keyword and ignore error    Stop and download Wireshark at gNB    nglogname=axis_0
    run keyword and ignore error    Stop and download Wireshark at gNB    nglogname=axis_1
    run keyword and ignore error    Stop and download Wireshark at gNB    nglogname=axis_2
    CI_interface.Common Case Teardown


Set L3 CALL param CB010611
    [Arguments]    ${runame}    ${framestruct}
    set test variable    ${ue_index}    ${L3CALL_Set['${runame}']['${framestruct}']['ue_index']}
    set test variable    ${L3CALL_cell_index}    ${L3CALL_Set['${runame}']['${framestruct}']['L3CALL_cell_index']}
    set test variable   ${dl_tp_ratio}    ${L3CALL_Set['${runame}']['${framestruct}']['dl_tp_ratio']}
    set test variable   ${ul_tp_ratio}    ${L3CALL_Set['${runame}']['${framestruct}']['ul_tp_ratio']}
    set test variable   ${peak_tp_dl}    ${L3CALL_Set['${runame}']['${framestruct}']['peak_tp_dl']}
    set test variable   ${peak_tp_ul}    ${L3CALL_Set['${runame}']['${framestruct}']['peak_tp_ul']}
    set test variable   ${duration}    ${L3CALL_Set['${runame}']['${framestruct}']['duration']}

PEAK L3 CALL Process CB010611
    ${dl_expect}    evaluate    ${peak_tp_dl}*${dl_tp_ratio}
    ${ul_expect}    evaluate    ${peak_tp_ul}*${ul_tp_ratio}
    ${Send_Tput_DL}   set variable   ${peak_tp_dl}
    ${Send_Tput_UL}   set variable   ${peak_tp_ul}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${ini_port}    Get Variable Value    ${tl.ues[${ue_index}].iperf_details.port}
    ...    ${tl.ues[${ue_index}].data_transfer[0].app_server.ports[0]}
    ${iperf_port}   Set Variable If   '${ue_type}'=='nokia_fastmile' or '${ue_type}'=='askey'    58092
    ...   ${ini_port}>${50000}   ${ini_port}
    ...   '${tl.gnbs[0].global_bts_id}'=='None'   58092
    ...   len("${tl.gnbs[0].global_bts_id}")==${2}   580${tl.gnbs[0].global_bts_id}   58${tl.gnbs[0].global_bts_id}
    CB010611 Get NR L3CALL Cell info
    Block Unblock NR cell Except L3CALL   5G_operation=locked
    wait until keyword succeeds   3x    20s  Call Setup and check tput  port=${iperf_port}   method=PEAK
    ...   tput=${Send_Tput_DL}   tput_expect=${dl_expect}
    ...   peak_ul=${Send_Tput_UL}   ul_expect=${ul_expect}
    ...   duration=${duration}
    ...   ue_lock=${True}    band=${nrband}    arfcn=${nrarfcn}    pci=${nrpci}
    [Teardown]   Block Unblock NR cell Except L3CALL   5G_operation=unlocked


CB010611 SISO_OAM_KPI_61a_SiSo_Auto_BTS_site_reset_with_L3Call
    [Arguments]    ${reset_flag}    ${runame}=AZHL    ${reset_times}=2
    LOG    ${runame}
    Return From Keyword If   ${reset_flag.count('FALSE')} >0
    Log To Console   BTS Site Reset Start ...
    FOR   ${index}    IN RANGE    ${reset_times}
       COAM WEBUI Whether Close Start Up View Window
       selenium_coam.reset_site
       Sleep   5m
       Wait Until Keyword Succeeds   20m   1m   COAM Check all cells should be onair  connection=COAM
       Log To Console   BTS Site Reset Number: ${index + 1}
    END
    Log To Console   BTS Site Reset Finish...
#    Start Capture Wireshark at gNB    nglogname=axis_1
#    Wait Until Keyword Succeeds   3x   10s   PEAK L3 CALL Process CB010611
#    Wait Until Keyword Succeeds   3x   10s   Stop and download Wireshark at gNB    nglogname=axis_1


CB010611 Get NR L3CALL Cell info
    ${nrpci}    ${nrarfcn}    Get physCellId and ARFCN by Cellid    gloablecellid=${L3CALL_cell_index}    Technology=NR
    ${nrband}    Get Cell Band by Cellid    gloablecellid=${L3CALL_cell_index}    Technology=NR
    Set Suite Variable    ${nrpci}
    Set Suite Variable    ${nrarfcn}
    Set Suite Variable    ${nrband}


Block Unblock NR cell Except L3CALL
    [Arguments]   ${5G_operation}=Unlocked
    ${nr_cells}    coam.Get cells info    connection=COAM
    @{nrcells_info}   Create List
    FOR    ${index}    IN    @{nr_cells}
        Run Keyword If    '${index['globalCellId']}'!='${L3CALL_cell_index}'    Append To List    ${nrcells_info}  ${index['globalCellId']}
    END
    FOR   ${index}    IN   @{nrcells_info}
        run keyword if  '${5G_operation.lower()}'=='locked'
        ...   wait Until Keyword Succeeds   3x   10s    ADMIN Block NR cell and check status   cell_index=${index}
        ...   ELSE   wait Until Keyword Succeeds   3x   10s    ADMIN UnBlock NR cell and check status    cell_index=${index}
    END
