*** Settings ***
Documentation
    ...    Author: ruiyu.han@nokia-sbell.com
    ...    to define SG07 COMMON SISO Case
    ...    feature : CB009499-CB009542

Library         OperatingSystem
Library         Collections
Library         taf.hw.rf_attenuator    WITH NAME    att
Variables     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB008278/Resource/resource.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/common.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009499/Resource/9499_CPE_resource.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009499/Resource/9499_samsung_resource.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009499/Resource/COAM_Operation.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009499/Resource/9499_askey_resource.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001821/Resource/coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/siso_common.robot


*** Variables ***
${cpc_ip}   ${tl.ues[${ue_index}].ssh_connection_details.addr}
${cpc_usrname}   ${tl.ues[${ue_index}].ssh_connection_details.username}
${cpc_passwd}   ${tl.ues[${ue_index}].ssh_connection_details.password}
${ue_2_required}   ${false}
${ue_3_required}   ${false}
${ue_4_required}   ${false}
${BTS_ID}    ${tl.gnbs[0].global_bts_id}
@{sas_faults_list}    6823   6824   6825   6826   6827   6828   6829   6830   6831   6832   6833


*** Keywords ***
ASOF Suite Setup Steps
    Log to console   ASOF Suite Setup
    robot_common_operations.Common Suite Setup
    AlarmWatchdog.add_allow_alarms    fault_id=${sas_faults_list}
    COAM LOGIN
    run keyword if    ${CBRS_chbw_change_Needed} and ${CBRS_PC_restart_needed}    Restart CBRS Service at Control PC

ASOF Suite Teardown Steps
    Log to console   ASOF Suite Teardown
    robot_common_operations.Common Suite Teardown
    run keyword and ignore error    COAM LOGOUT

ASOF Case Setup
    [Documentation]   Setup WEBUI login and start btslog collection
    robot_common_operations.Common Case Setup
    COAM WEBUI Login   display=${${DEBUG}}
    COAM WEBUI Whether Close Start Up View Window
    COAM Login
    ${is_cells_onair}   Run Keyword and Return Status   COAM Check all cells should be onair
    Log to Console   Check all cells should be onair result is ${is_cells_onair}
    run keyword if   ${scf_imported_need}==${true} or ${is_cells_onair}==${false}    ASOF Import Scf   feature=${configid}
    ${NR_ue_type}    translate_power_ue_type_from_testline    ue_index=${NR_L3call_UE}
    set Suite Variable   ${NR_ue_type}
    Run Keyword and Ignore Error    Set Sanity Check to False
    Run Keyword and Ignore Error   Start BTS Log Collection

ASOF Case Teardown
    [Documentation]   Stop btslog collection, and logout WEBUI connection
    Check Extra Reset From Blackbox
    COAM WEBUI Whether Close Start Up View Window
    run keyword and ignore error   Run Keyword If   '${TEST_STATUS}' == 'FAIL'    Siso Common Save Logs
    run keyword if    ${CBRS_chbw_change_Needed} and ${CBRS_PC_restart_needed}    Check CBRS If Cell Not Onair
    run keyword if    ${CBRS_chbw_change_Needed} and ${CBRS_PC_restart_needed}    Download CBRS Log
    run keyword and ignore error    COAM WEBUI Logout   display=${${DEBUG}}
    Run Keyword and Ignore Error   COAM Logout

Case Setup: ASOF_CRT
    robot_common_operations.Common Case Setup

Case Teardown: ASOF_CRT
    robot_common_operations.Common Case Teardown
    run keyword and ignore error   Run Keyword If Test Failed    Siso Common Save Logs
    CI_interface.Common Case Teardown

Case Setup: ASOF_Collect_RFSW_logs_into_BTS_Snapshot
    ASOF Case Setup
    Connect to gnb coam via ssl
    Connect to Common Unit Master
    Connect to RU With Allocated IP

Case Teardown: ASOF_Collect_RFSW_logs_into_BTS_Snapshot
    Run Keyword And Ignore Error   COAM Teardown GNB Connections
    Run Keyword And Ignore Error   csn.Disconnect   connection=RU
    Run Keyword And Ignore Error   csn.Disconnect   connection=ASIK Master
    ASOF Case Teardown

Case Setup: ASOF_E2E_system_setup_with_data_transfer
    ASOF Case Setup

Case Teardown: ASOF_E2E_system_setup_with_data_transfer
    Run Keyword And Ignore Error   ASOF Case Teardown

Case Setup: ASOF_CM_Recommissioning
    ASOF Case Setup
    COAM Backup SCF

Case Teardown: ASOF_CM_Recommissioning
    robot_common_operations.Common Case Teardown
    Run Keyword And Ignore Error   COAM Logout
    Wait Until Keyword Succeeds   20m   1m   COAM Login   bts_host=192.168.255.129
    ${status}   run keyword and return status   COAM SCF Commission
    run keyword if   ${status}==${false}   set suite variable   ${scf_imported_need}  ${true}
    Wait Until Keyword Succeeds   10m   1m     COAM Check all cells should be onair
    ASOF Case Teardown

Case Setup Steps: ASOF_Cell_lock_and_unlock
    ASOF Case Setup

Case Teardown Steps: ASOF_Cell_lock_and_unlock
#    run keyword if test failed   Run keyword if   ${NR_L3call_need}==${true}   Block Cell for L3call   5G_call=${true}
#    run keyword if test failed   Run keyword if   ${LTE_L3call_need}==${true}   Block Cell for L3call   4G_call=${true}
    Unblock All Cells
    Run Keyword And Ignore Error   ASOF Case Teardown


Case Setup: ASOF_BTS_Site_Reset
    ASOF Case Setup

Case Teardown: ASOF_BTS_Site_Reset
    Run Keyword And Ignore Error   COAM Logout
    Run Keyword And Ignore Error   Wait Until Keyword Succeeds   10m   1m   COAM Login
    Run Keyword And Ignore Error   Wait Until Keyword Succeeds   15m   1m   COAM Check all cells should be onair
    ASOF Case Teardown

Case Setup: ASOF_BTS_Site_Reset_without_HWF_without_L3call
    ASOF Case Setup

Case Teardown: ASOF_BTS_Site_Reset_without_HWF_without_L3call
    Run Keyword And Ignore Error   COAM Logout
    Run Keyword And Ignore Error   Wait Until Keyword Succeeds   10m   1m   COAM Login
    Run Keyword And Ignore Error   Wait Until Keyword Succeeds   15m   1m   COAM Check all cells should be onair
    ASOF Case Teardown

Test_Case_ASOF_Collect_RFSW_logs_into_BTS_Snapshot
    ${status}   Run Keyword And Return Status   Verify RFSW Log Include In Snapshot
    Run Keyword If   not ${status}   Log To Console   [Warning] Should Check RFSW Logs IN Snapshot.

Import SCF and Wait onair
    [Arguments]   ${ip_addr}   ${SCF_FILE}
    coam.Import SCF On COAM   IP_WEBUI=${ip_addr}  SCF_FILE=${SCF_FILE}
    Wait Until Keyword Succeeds   10m   30s   Try Connect gNB    gnb_addr=${ip_addr}
    Wait until keyword succeeds  10min   1min   COAM Login   alias=scf
    log to console   wait onair after import scf
    Wait Until Keyword Succeeds   20min   1min   COAM Check all cells should be onair
    [Teardown]    Run Keyword and Ignore Error   COAM Logout   connection=scf

Return scf name by release
   ${gnb_release}   Get gnb release    host=${LMP_ADDR}
   ${value}    run keyword if   '${gnb_release}'!='trunk'    fetch from right    ${gnb_release}    SBTS
   ${scfname}    set variable if   '${gnb_release}'=='trunk'   TRUNK     ${value}
   [Return]     ${scfname}

ASOF Import Scf
    [Arguments]    ${feature}=9542_E1
    ${scfname}   Return scf name by release
    log to console   start to import 9499_9542 scf
    Import SCF and Wait onair   ip_addr=${asik_addr}
    ...   SCF_FILE=${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/SCF_${scfname}_${feature}.xml
    set suite variable   ${scf_imported_need}   ${false}

Set peak number
    [Arguments]    ${before_number}   ${ratio}
    ${after_number}=   Evaluate   ${before_number}*${ratio}
    [Return]    ${after_number}

Set Send number
    [Arguments]    ${before_number}
    ${after_number}=   Evaluate   ${before_number}*1.2
    [Return]    ${after_number}

Set Suite variable for L3 Call
    [Arguments]   ${CM_Call}=${false}
    ${5Gsend_tp_DL}=   Run Keyword If   ${CM_Call}==${false}   Set Send number   before_number=${NRtput_expect_DL}
    ...   ELSE   Set Send number   before_number=${NR_L3call_Peak_Tput_DL_CM_Recom}
    ${5Gsend_tp_UL}=   Run Keyword If   ${CM_Call}==${false}   Set Send number   before_number=${NRtput_expect_uL}
    ...   ELSE   Set Send number   before_number=${NR_L3call_Peak_Tput_UL_CM_Recom}
    ${4Gsend_tp_DL}=   Run Keyword If   ${CM_Call}==${false}   Set Send number   before_number=${LTEtput_expect_DL}
    ...   ELSE   Set Send number   before_number=${LTE_L3call_Peak_Tput_DL_CM_Recom}
    ${4Gsend_tp_UL}=   Run Keyword If   ${CM_Call}==${false}   Set Send number   before_number=${LTEtput_expect_uL}
    ...   ELSE   Set Send number   before_number=${LTE_L3call_Peak_Tput_UL_CM_Recom}
    Set Suite Variable  ${5Gsend_tp_DL}
    Set Suite Variable  ${5Gsend_tp_UL}
    Set Suite Variable  ${4Gsend_tp_DL}
    Set Suite Variable  ${4Gsend_tp_UL}
    ${5Gtput_expect_DL}   Run Keyword If   ${L3call_peak}==${true} and ${CM_Call}==${false}
    ...   Set peak number   before_number=${NRtput_expect_DL}   ratio=${NR_Peak_Tput_DL_coeff}
    ...   ELSE IF   ${L3call_peak}==${true} and ${CM_Call}==${true}
    ...   Set peak number   before_number=${NR_L3call_Peak_Tput_DL_CM_Recom}   ratio=${NR_Peak_Tput_DL_coeff_CM_Recom}
    ...   ELSE IF   ${L3call_peak}==${false} and ${CM_Call}==${true}
    ...   Set peak number   before_number=${NR_L3call_Peak_Tput_DL_CM_Recom}   ratio=${NR_Nor_Tput_DL_coeff}
    ...   ELSE   Set peak number   before_number=${NRtput_expect_DL}   ratio=${NR_Nor_Tput_DL_coeff}
    Set Suite Variable  ${5Gtput_expect_DL}
    ${5Gtput_expect_uL}   Run Keyword If   ${L3call_peak}==${true} and ${CM_Call}==${false}
    ...   Set peak number   before_number=${NRtput_expect_uL}   ratio=${NR_Peak_Tput_UL_coeff}
    ...   ELSE IF   ${L3call_peak}==${true} and ${CM_Call}==${true}
    ...   Set peak number   before_number=${NR_L3call_Peak_Tput_UL_CM_Recom}   ratio=${NR_Peak_Tput_UL_coeff_CM_Recom}
    ...   ELSE IF   ${L3call_peak}==${false} and ${CM_Call}==${true}
    ...   Set peak number   before_number=${NR_L3call_Peak_Tput_UL_CM_Recom}   ratio=${NR_Nor_Tput_UL_coeff}
    ...   ELSE   Set peak number   before_number=${NRtput_expect_uL}   ratio=${NR_Nor_Tput_UL_coeff}
    Set Suite Variable  ${5Gtput_expect_uL}
    ${4Gtput_expect_DL}   Run Keyword If   ${L3call_peak}==${true} and ${CM_Call}==${false}
    ...   Set peak number   before_number=${LTEtput_expect_DL}   ratio=${LTE_Peak_Tput_DL_coeff}
    ...   ELSE IF   ${L3call_peak}==${true} and ${CM_Call}==${true}
    ...   Set peak number   before_number=${LTE_L3call_Peak_Tput_DL_CM_Recom}   ratio=${LTE_Peak_Tput_DL_coeff_CM_Recom}
    ...   ELSE IF   ${L3call_peak}==${false} and ${CM_Call}==${true}
    ...   Set peak number   before_number=${LTE_L3call_Peak_Tput_DL_CM_Recom}   ratio=${LTE_Nor_Tput_DL_coeff}
    ...   ELSE   Set peak number   before_number=${LTEtput_expect_DL}   ratio=${LTE_Nor_Tput_DL_coeff}
    Set Suite Variable  ${4Gtput_expect_DL}
    ${4Gtput_expect_uL}   Run Keyword If   ${L3call_peak}==${true} and ${CM_Call}==${false}
    ...   Set peak number   before_number=${LTEtput_expect_uL}   ratio=${LTE_Peak_Tput_UL_coeff}
    ...   ELSE IF   ${L3call_peak}==${true} and ${CM_Call}==${true}
    ...   Set peak number   before_number=${LTE_L3call_Peak_Tput_UL_CM_Recom}   ratio=${LTE_Peak_Tput_UL_coeff_CM_Recom}
    ...   ELSE IF   ${L3call_peak}==${false} and ${CM_Call}==${true}
    ...   Set peak number   before_number=${LTE_L3call_Peak_Tput_UL_CM_Recom}   ratio=${LTE_Nor_Tput_UL_coeff}
    ...   ELSE   Set peak number   before_number=${LTEtput_expect_uL}   ratio=${LTE_Nor_Tput_UL_coeff}
    Set Suite Variable  ${4Gtput_expect_uL}

Start NRcall
    [Arguments]   ${bip_enable}=${false}    ${traffic_stop}=${true}    ${duration}=90   ${direction}=BOTH   ${ue_lock}=${False}
    ...   ${5G_DL_tput_deviation}=0.98     ${5G_UL_tput_deviation}=0.98   ${5G_operation}=Locked   ${4G_operation}=locked
    run keyword and ignore error   COAM WEBUI Whether Close Start Up View Window
    Block Cell for L3call  5G_call=${true}   5G_operation=${5G_operation}   4G_operation=${4G_operation}
#    Run Keyword And Continue On Failure   COAM WEBUI Check Cell Status   cell_index=${nrcall_cell_index}
#    wait until keyword succeeds    5min    1min   COAM WEBUI Check Cell Status   cell_index=${nrcall_cell_index}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${NR_L3call_UE}
    ${ini_port}    Get Variable Value    ${tl.ues[${NR_L3call_UE}].iperf_details.port}
    ...    ${tl.ues[${NR_L3call_UE}].data_transfer[0].app_server.ports[0]}
    ${iperf_port}   Set Variable If
    ...   '${ue_type}'=='nokia_fastmile'    58092
    ...   ${ini_port}>${50000}   ${ini_port}
    ...   '${tl.gnbs[0].global_bts_id}'=='None'   58092
    ...   len("${tl.gnbs[0].global_bts_id}")==${2}   580${tl.gnbs[0].global_bts_id}   58${tl.gnbs[0].global_bts_id}
    Set Test variable    ${iperf_port}
    Run Keyword If   '${ue_type}'!='askey'
    ...   Call Setup and check tput   port=${iperf_port}   tput_expect=${5Gtput_expect_DL}    tput=${5Gsend_tp_DL}
    ...   bip_request=${bip_enable}    traffic_stop=${traffic_stop}    duration=${duration}   ue_index=${NR_L3call_UE}
    ...   Technology=NR   ue_lock=${ue_lock}   band=${nrband}   arfcn=${nrarfcn}   pci=${nrpci}
    ...   method=PEAK   peak_ul=${5Gsend_tp_UL}    ul_expect=${5Gtput_expect_UL}
    ...   dl_deviation=${5G_DL_tput_deviation}    ul_deviation=${5G_UL_tput_deviation}
    ...   min_percent=${5G_min_percent}   apn_address=dxdata2   power_reset=True
    Run Keyword If   '${ue_type}'=='askey'   Askey NRcall   traffic_stop=${traffic_stop}   duration=${duration}
    ...    iperf_port=${iperf_port}    direction=${direction}

Test_Case_ASOF_Data_Transfer_Conducted
    [Arguments]   ${bip_enable}=${false}    ${traffic_stop}=${true}   ${duration}=${L3CALL_duration}   ${direction}=BOTH
    ...   ${CM_Call}=${false}   ${5G_call_celllock}=${true}   ${4G_call_celllock}=${true}
    ...   ${CM_peak}=${true}   ${Lock_peak}=${true}   ${Reset_peak}=${true}
    Log to console   ASOF_Data_Transfer_Conducted start
    Set Suite variable for L3 Call   CM_Call=${CM_Call}
    ${5Gtput_expect_DL}   Run Keyword If
    ...   ${CM_Call}==${true} and (${CM_peak}==${false} or ${Lock_peak}==${false} or ${Reset_peak}==${false})
    ...   Set peak number   before_number=${NR_L3call_Peak_Tput_DL_CM_Recom}   ratio=${NR_Nor_Tput_DL_coeff}
    ...   ELSE IF   ${CM_Call}==${false} and (${CM_peak}==${false} or ${Lock_peak}==${false} or ${Reset_peak}==${false})
    ...   Set peak number   before_number=${NRtput_expect_DL}   ratio=${NR_Nor_Tput_DL_coeff}
    ...   ELSE   set variable   ${5Gtput_expect_DL}
    ${5Gtput_expect_uL}   Run Keyword If
    ...   ${CM_Call}==${true} and (${CM_peak}==${false} or ${Lock_peak}==${false} or ${Reset_peak}==${false})
    ...   Set peak number   before_number=${NR_L3call_Peak_Tput_UL_CM_Recom}   ratio=${NR_Nor_Tput_UL_coeff}
    ...   ELSE IF   ${CM_Call}==${false} and (${CM_peak}==${false} or ${Lock_peak}==${false} or ${Reset_peak}==${false})
    ...   Set peak number   before_number=${NRtput_expect_uL}   ratio=${NR_Nor_Tput_UL_coeff}
    ...   ELSE   set variable   ${5Gtput_expect_uL}
    ${4Gtput_expect_DL}   Run Keyword If
    ...   ${CM_Call}==${true} and (${CM_peak}==${false} or ${Lock_peak}==${false} or ${Reset_peak}==${false})
    ...   Set peak number   before_number=${LTE_L3call_Peak_Tput_DL_CM_Recom}   ratio=${LTE_Nor_Tput_DL_coeff}
    ...   ELSE IF   ${CM_Call}==${false} and (${CM_peak}==${false} or ${Lock_peak}==${false} or ${Reset_peak}==${false})
    ...   Set peak number   before_number=${LTEtput_expect_DL}   ratio=${LTE_Nor_Tput_DL_coeff}
    ...   ELSE   set variable   ${4Gtput_expect_DL}
    ${4Gtput_expect_uL}   Run Keyword If
    ...   ${CM_Call}==${true} and (${CM_peak}==${false} or ${Lock_peak}==${false} or ${Reset_peak}==${false})
    ...   Set peak number   before_number=${LTE_L3call_Peak_Tput_UL_CM_Recom}   ratio=${LTE_Nor_Tput_UL_coeff}
    ...   ELSE IF   ${CM_Call}==${false} and (${CM_peak}==${false} or ${Lock_peak}==${false} or ${Reset_peak}==${false})
    ...   Set peak number   before_number=${LTEtput_expect_uL}   ratio=${LTE_Nor_Tput_UL_coeff}
    ...   ELSE   set variable   ${4Gtput_expect_uL}
    Get NR and LTE L3CALL Cell info
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${NR_L3call_UE}
    ${ue_lock}    set variable if   '${ue_type}'=='nokia_fastmile'   ${True}   ${False}
    Run Keyword If   ${NR_L3call_need}==${true} and ${5G_call_celllock}==${true}
    ...   Start NRcall   bip_enable=${bip_enable}   traffic_stop=${traffic_stop}   duration=${duration}   direction=${direction}
    ...    ue_lock=${ue_lock}
    Run Keyword If   ${LTE_L3call_need}==${true} and ${4G_call_celllock}==${true}
    ...   Start LTEcall   bip_enable=${bip_enable}   traffic_stop=${traffic_stop}   duration=${duration}   direction=${direction}
    ...    ue_lock=${ue_lock}
    Log to console   ASOF_Data_Transfer_Conducted finish

    [Teardown]   NRcall Teardown   traffic_stop=${traffic_stop}

Restart spark pc
    [Arguments]   ${ue_index}
    csn.Connect to    hostname=${cpc_ip}
    ...    username=${cpc_usrname}
    ...    password=${cpc_passwd}    alias=cpc_${ue_index}
    csn.send_command
    ...    command=shutdown /r /f /t 0
    ...    connection=cpc_${ue_index}
    csn.disconnect      connection=cpc_${ue_index}
    sleep    120s

NRcall Teardown
    [Arguments]   ${traffic_stop}=${true}
    Log To Console   'traffic_stop=${traffic_stop}'
#    run keyword if   ${traffic_stop}    Run Keyword and Ignore Error   power_ue.UE Detach
#    ...   ue_type=${ue_${NR_L3call_UE}_type}   ue_index=${NR_L3call_UE}
#    run keyword and ignore error   Unlock band and PCI from CPE   ue_index=${NR_L3call_UE}   band=${nrband}
    Run Keyword and Ignore Error   Block Cell for L3call   5G_call=${true}   5G_operation=Unlocked   4G_operation=unlocked
    wait until keyword succeeds    10min    1min       COAM Check all cells should be onair

Start LTEcall
    [Arguments]   ${bip_enable}=${false}    ${traffic_stop}=${true}    ${duration}=90   ${direction}=BOTH   ${ue_lock}=${False}
    Log To Console   Start LTEcall for direction:${direction}!
    wait until keyword succeeds    10min    1min    COAM Login   alias=LTEcall
    run keyword and ignore error   COAM WEBUI Whether Close Start Up View Window
    Block Cell for L3call  4G_call=${true}   5G_operation=Locked   4G_operation=locked
    ${is_cells_onair}   Run Keyword and Return Status   COAM Check all cells should be onair   connection=LTEcall
    Log to Console   Check all cells should be onair result is ${is_cells_onair} after lock cell for LTEcall
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${LTE_L3call_UE}
    ${ini_port}    Get Variable Value    ${tl.ues[${LTE_L3call_UE}].iperf_details.port}
    ...    ${tl.ues[${LTE_L3call_UE}].data_transfer[0].app_server.ports[0]}
    ${iperf_port}   Set Variable If
    ...   '${ue_type}'=='askey' or '${ue_type}'=='nokia_fastmile'    58092
    ...   ${ini_port}>${50000}   ${ini_port}
    ...   '${tl.gnbs[0].global_bts_id}'=='None'   58092
    ...   len("${tl.gnbs[0].global_bts_id}")==${2}   580${tl.gnbs[0].global_bts_id}   58${tl.gnbs[0].global_bts_id}
#    Run Keyword If   '${ue_type}'!='samsung_lte'
#    ...   Call Setup and check tput   port=${iperf_port}   tput_expect=${4Gtput_expect_DL}    tput=${4Gsend_tp_DL}
#    ...   bip_request=${bip_enable}    traffic_stop=${traffic_stop}    duration=${duration}   ue_index=${LTE_L3call_UE}
#    ...   Technology=LTE   ue_lock=${ue_lock}   band=${lteband}   arfcn=${ltearfcn}   pci=${ltepci}
#    ...   method=PEAK   peak_ul=${4Gsend_tp_UL}    ul_expect=${4Gtput_expect_UL}
#    ...   dl_deviation=${4G_DL_tput_deviation}    ul_deviation=${4G_UL_tput_deviation}
#    Run Keyword If   '${ue_type}'=='samsung_lte'   Samsung_Lte_Call   traffic_stop=${traffic_stop}   duration=${duration}
    Call Setup and check tput   port=${iperf_port}   tput_expect=${4Gtput_expect_DL}    tput=${4Gsend_tp_DL}
    ...   bip_request=${bip_enable}    traffic_stop=${traffic_stop}    duration=${duration}   ue_index=${LTE_L3call_UE}
    ...   Technology=LTE   ue_lock=${ue_lock}   band=${lteband}   arfcn=${ltearfcn}   pci=${ltepci}
    ...   method=PEAK   peak_ul=${4Gsend_tp_UL}    ul_expect=${4Gtput_expect_UL}
    ...   dl_deviation=${4G_DL_tput_deviation}    ul_deviation=${4G_UL_tput_deviation}
    ...   min_percent=${4G_min_percent}
    [Teardown]  LTEcall Teardown   traffic_stop=${traffic_stop}   ue_type=${ue_type}

Samsung_Lte_Call
    [Arguments]   ${traffic_stop}=${true}   ${duration}=90
    power_ue.Prepare UE    ue_type=samsung_lte   ue_index=${LTE_L3call_UE}
    Run Keyword And Ignore Error   power_ue.UE Detach   ue_type=samsung_lte   ue_index=${LTE_L3call_UE}
    ${lte_pci}   selenium_coam.get_parameter_value   dist_name=MRBTS-${BTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-${ltecall_cell_index}
    ...   filter_param=Physical layer cell identity
    power_ue.UE Attach   ue_type=samsung_lte   ue_index=${LTE_L3call_UE}   pci=${lte_pci}
    power_ue.Start traffic   ue_type=samsung_lte   direction=dl   throughput=${4Gsend_tp_DL}   duration=${duration}   ue_index=${LTE_L3call_UE}
    power_ue.Start traffic   ue_type=samsung_lte   direction=ul   throughput=${4Gsend_tp_UL}   duration=${duration}   ue_index=${LTE_L3call_UE}
    power_ue.Collect Tput    ue_type=samsung_lte   ue_index=${LTE_L3call_UE}   duration=${duration}   ignore_time=30  check_source=Iperf
    power_ue.Check Tput    ue_type=samsung_lte    ue_index=${LTE_L3call_UE}
    ...    direction=dl    target_throughput=${4Gtput_expect_DL}   target_avg_percent=${4G_DL_tput_deviation}
    power_ue.Check Tput    ue_type=samsung_lte    ue_index=${LTE_L3call_UE}
    ...    direction=ul    target_throughput=${4Gtput_expect_uL}   target_avg_percent=${4G_UL_tput_deviation}
    [Teardown]   Samsung_Lte_Call_Teardown   traffic_stop=${traffic_stop}

Samsung_Lte_Call_Teardown
    [Arguments]   ${traffic_stop}=${true}
    run keyword and ignore error   run keyword if   ${traffic_stop}   power_ue.UE Detach   ue_type=samsung_lte   ue_index=${LTE_L3call_UE}
    run keyword and ignore error   run keyword if   ${traffic_stop}
    ...   power_ue.Stop traffic   ue_type=samsung_lte   direction=dl   ue_index=${LTE_L3call_UE}
    run keyword and ignore error   run keyword if   ${traffic_stop}
    ...   power_ue.Stop traffic   ue_type=samsung_lte   direction=ul   ue_index=${LTE_L3call_UE}


LTEcall Teardown
    [Arguments]   ${ue_type}   ${traffic_stop}=${true}
#    run keyword and ignore error   Unlock band and PCI from CPE   ue_index=${NR_L3call_UE}   band=${nrband}
    run keyword if   ${traffic_stop} and ('${ue_type}'!='samsung_lte')   Run Keyword and Ignore Error   power_ue.UE Detach
    ...   ue_type=${ue_${LTE_L3call_UE}_type}   ue_index=${LTE_L3call_UE}
    Run Keyword and Ignore Error   Block Cell for L3call   4G_call=${true}   5G_operation=Unlocked   4G_operation=unlocked
    wait until keyword succeeds    10min    1min      COAM Check all cells should be onair

Test_Case_ASOF_CM_Recommissioning
    [Arguments]   ${bip_enable}=${false}    ${traffic_stop}=${true}    ${duration}=90   ${direction}=BOTH
    Log To Console   CM Recommissioning Start ...
    COAM WEBUI Whether Close Start Up View Window
    Run keyword if   ${NR_chBw_change_Needed}==${true}    Chbw CM Change   type=NR
    Run keyword if   ${NR_prach_change_Needed}==${true}   Prach_CM_Change   type=NR
    Run keyword if   ${LTE_chBw_change_Needed}==${true}   Chbw CM Change   type=LTE
    Run keyword if   ${LTE_prach_change_Needed}==${true}   Prach_CM_Change   type=LTE
    Log to console   Modify CM recommission finished and start to activate!
    selenium_coam.validate_plan
    sleep  5s
    selenium_coam.activate_plan   activate_plan_despite_errors=True   timeout=240
    Wait until keyword succeeds  10min   1min   COAM Check all cells should be onair
    COAM Backup SCF    file_name=scf_after_recommission.xml
    Log To Console   CM Recommissioning Finish ...
    Run keyword if   ${CM_L3call_needed}==${true}   Test_Case_ASOF_Data_Transfer_Conducted   CM_Call=${true}   CM_peak=${CM_L3call_peak_needed}
    ...   bip_enable=${bip_enable}   traffic_stop=${traffic_stop}   duration=${duration}   direction=${direction}

Test_Case_ASOF_CM_Recommissioning_9499_G1
    [Arguments]   ${bip_enable}=${false}    ${traffic_stop}=${true}    ${duration}=90   ${direction}=BOTH
    Log To Console   CM Recommissioning Start ...
    COAM WEBUI Whether Close Start Up View Window
    Run keyword if   ${NR_chBw_change_Needed}==${true}   Chbw CM Change G1  type=NR
    Run keyword if   ${NR_prach_change_Needed}==${true}   Prach_CM_Change   type=NR
    Run keyword if   ${LTE_chBw_change_Needed}==${true}   Chbw CM Change   type=LTE
    Run keyword if   ${LTE_prach_change_Needed}==${true}   Prach_CM_Change   type=LTE
    Log to console   Modify CM recommission finished and start to activate!
    selenium_coam.validate_plan
    sleep  5s
    selenium_coam.activate_plan   activate_plan_despite_errors=True   timeout=240
    Wait until keyword succeeds  10min   1min   COAM Check all cells should be onair
    COAM Backup SCF    file_name=scf_after_recommission.xml
    Log To Console   CM Recommissioning Finish ...
    Run keyword if   ${CM_L3call_needed}==${true}   Test_Case_ASOF_Data_Transfer_Conducted   CM_Call=${true}   CM_peak=${CM_L3call_peak_needed}
    ...   bip_enable=${bip_enable}   traffic_stop=${traffic_stop}   duration=${duration}   direction=${direction}

Chbw CM Change
    [Arguments]   ${type}=NR
    Run keyword if   '${type}'=='NR'   wait until keyword succeeds   3x   15s    selenium_coam.set_parameter_value
    ...  dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-${nrcall_cell_index}   filter_param=Channel bandwidth   new_value=${NR_target_chBw}MHz
    Run keyword if   '${type}'=='NR'   wait until keyword succeeds   3x   15s    selenium_coam.set_parameter_value
    ...   dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-${nrcall_cell_index}   filter_param=Requested minimum number of PUSCH PRBs
    ...   new_value=${NR_target_reqMinNumPuschPrb}
    Run keyword if   '${type}'=='NR'   wait until keyword succeeds   3x   15s    selenium_coam.set_parameter_value
    ...   dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-${nrcall_cell_index}   filter_param=Bandwidth Part Profile distinguished name
    ...   new_value=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/BWP_PROFILE-${NR_target_cellBwpList_1}   node_index=${0}
    Run keyword if   '${type}'=='NR'   wait until keyword succeeds   3x   15s    selenium_coam.set_parameter_value
    ...   dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-${nrcall_cell_index}   filter_param=Bandwidth Part Profile distinguished name
    ...   new_value=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/BWP_PROFILE-${NR_target_cellBwpList_2}   node_index=${1}
    Run keyword if   '${type}'=='LTE'   wait until keyword succeeds   3x   15s   selenium_coam.set_parameter_value   new_value=${LTE_target_chBw} MHz
    ...   filter_param=Channel bandwidth TDD   dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${ltecall_cell_index}/LNCEL_TDD-0
    Run keyword if   '${type}'=='LTE'   wait until keyword succeeds   3x   15s   selenium_coam.set_parameter_value
    ...   dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${ltecall_cell_index}   filter_param=Activate down sampling   new_value=false
    Run keyword if   ${CBRS_chbw_change_Needed} and '${type}'=='NR'   wait until keyword succeeds   3x   15s   selenium_coam.set_parameter_value
    ...   dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-${nrcall_cell_index}/NRCBSDCELL-0
    ...   filter_param=Bandwidth Part Profile distinguished name 1   new_value=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/BWP_PROFILE-${NR_target_cellBwpList_1}
    Run keyword if   ${CBRS_chbw_change_Needed} and '${type}'=='NR'   wait until keyword succeeds   3x   15s   selenium_coam.set_parameter_value
    ...   dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-${nrcall_cell_index}/NRCBSDCELL-0
    ...   filter_param=Bandwidth Part Profile distinguished name 2   new_value=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/BWP_PROFILE-${NR_target_cellBwpList_2}
    Run keyword if   ${CBRS_chbw_change_Needed} and '${type}'=='NR'   wait until keyword succeeds   3x   15s
    ...   selenium_coam.set_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-${nrcall_cell_index}/NRCBSDCELL-0
    ...   filter_param=Channel bandwidth   new_value=${NR_target_chBw}MHz
    Run keyword if   ${CBRS_chbw_change_Needed} and '${type}'=='NR'   wait until keyword succeeds   3x   15s
    ...   selenium_coam.set_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-${nrcall_cell_index}/NRCBSDCELL-0
    ...   filter_param=Requested minimum number of PUSCH PRBs   new_value=${NR_target_reqMinNumPuschPrb}
    Run keyword if   ${CBRS_chbw_change_Needed} and '${type}'=='NR'   wait until keyword succeeds   3x   15s
    ...   selenium_coam.set_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-${nrcall_cell_index}/NRCBSDCELL-0
    ...   filter_param=Desired channel bandwidth   new_value=${NR_target_chBw}MHz
    Run keyword if   ${CBRS_chbw_change_Needed} and '${type}'=='LTE'   wait until keyword succeeds   3x   15s
    ...   selenium_coam.set_parameter_value   dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${ltecall_cell_index}/CBSDCEL-0
    ...   filter_param=Desired Channel Band Width   new_value=${LTE_target_chBw}MHz


Chbw CM Change G1
    [Arguments]   ${type}=NR
    Run keyword if   '${type}'=='NR'   selenium_coam.set_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-${nrcall_cell_index}
    ...   filter_param=Channel bandwidth   new_value=${NR_target_chBw}MHz
    Run keyword if   '${type}'=='NR'   selenium_coam.set_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-${nrcall_cell_index}
    ...   filter_param=Requested minimum number of PUSCH PRBs   new_value=${NR_target_reqMinNumPuschPrb}
    Run keyword if   '${type}'=='NR'   selenium_coam.set_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-${nrcall_cell_index}
    ...   filter_param=PRACH Frequency start   new_value=${NR_target_msg1FrequencyStart}
    Run keyword if   '${type}'=='NR'   selenium_coam.set_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-${nrcall_cell_index}
    ...   filter_param=PUCCH size in PRB for long PUCCH   new_value=${NR_target_pucchSize}
    Run keyword if   '${type}'=='NR'   selenium_coam.set_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-${nrcall_cell_index}
    ...   filter_param=Bandwidth Part Profile distinguished name   new_value=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/BWP_PROFILE-${NR_target_cellBwpList_1}
    ...   node_index=${0}
    Run keyword if   '${type}'=='NR'   selenium_coam.set_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-${nrcall_cell_index}
    ...   filter_param=Bandwidth Part Profile distinguished name   new_value=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/BWP_PROFILE-${NR_target_cellBwpList_2}
    ...   node_index=${1}
    Run keyword if   '${type}'=='LTE'   selenium_coam.set_parameter_value   new_value=${LTE_target_chBw} MHz
    ...   filter_param=Channel bandwidth TDD   dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${ltecall_cell_index}/LNCEL_TDD-0
    Run keyword if   '${type}'=='LTE'   selenium_coam.set_parameter_value   dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${ltecall_cell_index}
    ...   filter_param=Activate down sampling   new_value=false
    Run keyword if   ${CBRS_chbw_change_Needed} and '${type}'=='NR'
    ...   selenium_coam.set_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-${nrcall_cell_index}/NRCBSDCELL-0
    ...   filter_param=Bandwidth Part Profile distinguished name 1   new_value=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/BWP_PROFILE-${NR_target_cellBwpList_1}
    Run keyword if   ${CBRS_chbw_change_Needed} and '${type}'=='NR'
    ...   selenium_coam.set_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-${nrcall_cell_index}/NRCBSDCELL-0
    ...   filter_param=Bandwidth Part Profile distinguished name 2   new_value=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/BWP_PROFILE-${NR_target_cellBwpList_2}
    Run keyword if   ${CBRS_chbw_change_Needed} and '${type}'=='NR'
    ...   selenium_coam.set_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-${nrcall_cell_index}/NRCBSDCELL-0
    ...   filter_param=Channel bandwidth   new_value=${NR_target_chBw}MHz
    Run keyword if   ${CBRS_chbw_change_Needed} and '${type}'=='NR'
    ...   selenium_coam.set_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-${nrcall_cell_index}/NRCBSDCELL-0
    ...   filter_param=Requested minimum number of PUSCH PRBs   new_value=${NR_target_reqMinNumPuschPrb}
    Run keyword if   ${CBRS_chbw_change_Needed} and '${type}'=='NR'
    ...   selenium_coam.set_parameter_value   dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-${nrcall_cell_index}/NRCBSDCELL-0
    ...   filter_param=Desired channel bandwidth   new_value=${NR_target_chBw}MHz
    Run keyword if   ${CBRS_chbw_change_Needed} and '${type}'=='LTE'
    ...   selenium_coam.set_parameter_value   dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${ltecall_cell_index}/CBSDCEL-0
    ...   filter_param=Desired Channel Band Width   new_value=${LTE_target_chBw}MHz


Prach_CM_Change
    [Arguments]   ${type}=NR
    Run Keyword If   '${type}'=='NR'   wait until keyword succeeds   3x   15s   selenium_coam.set_parameter_value
    ...   new_value=${NR_target_prachConfig}   filter_param=PRACH configuration index
    ...   dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-${nrcall_cell_index}
    ...   ELSE   wait until keyword succeeds   3x   15s   selenium_coam.set_parameter_value   new_value=${LTE_target_prachConfIndex}
    ...   filter_param=PRACH configuration index   dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${ltecall_cell_index}/LNCEL_TDD-0


Test_Case_ASOF_Cell_lock_and_unlock
    Log to console   Test_Case_ASOF_Cell_lock_and_unlock
    Block Unblock All cell
    Run keyword if   ${Lockcell_L3call_needed}==${true} and ${NR_ue_type.count('askey')}>0
    ...   Check L3call Status after Cell Lock Unlock
    Run keyword if   ${Lockcell_L3call_needed}==${true} and ${NR_ue_type.count('fastmile')}>0
    ...   CPE Check L3call Status after Cell Lock Unlock
    Run keyword if   ${Lockcell_L3call_needed}==${true} and ${NR_ue_type.count('askey')}<=0 and ${NR_ue_type.count('fastmile')}<=0
    ...   Samsung Check L3call Status after Cell Lock Unlock
    [Teardown]   Run Keyword And Ignore Error   Unblock All Cells

Check L3call Status after Cell Lock Unlock
    [Arguments]   ${bip_enable}=${false}    ${traffic_stop}=${false}    ${duration}=3000   ${direction}=BOTH
    # Start NR DL traffic #
    @{lock_case_NRcells}   Create List
    @{lock_case_LTEcells}   Create List
    Run keyword if   ${NR_L3call_need}==${true} and ('${direction}'=='BOTH' or '${direction}'=='DL')   Test_Case_ASOF_Data_Transfer_Conducted
    ...   bip_enable=${bip_enable}   traffic_stop=${traffic_stop}   direction=DL   duration=${duration}   4G_call_celllock=${false}
    ...   Lock_peak=${Lockcell_L3call_peak_needed}
    ${NRCellId}   Get Attached Cell Indentity
    Append To List    ${lock_case_NRcells}   ${NRCellId}
    # Check NR DL tput not impact by unlock cell#
    Run keyword if   ${NR_L3call_need}==${true} and ('${direction}'=='BOTH' or '${direction}'=='DL')   Check Tput l3call
    ...   ue_type=${NR_ue_type}  ue_index=${NR_L3call_UE}   direction=DL   cells=${lock_case_NRcells}   expect=${5Gtput_expect_DL}
    # Lock NR NoL3CALL Cells ALL Onetime #
    Run keyword if   ${NR_L3call_need}==${true}   Block Cell for L3call   5G_call=${true}  5G_operation=Locked   4G_operation=locked
    # Check NR DL tput not impact by lock cell #
    Run keyword if   ${NR_L3call_need}==${true} and ('${direction}'=='BOTH' or '${direction}'=='DL')   Check Tput l3call
    ...   ue_type=${NR_ue_type}  ue_index=${NR_L3call_UE}   direction=DL   cells=${lock_case_NRcells}   expect=${5Gtput_expect_DL}
    Run keyword if   ${NR_L3call_need}==${true}   Askey stop DL traffic     iperf_port=${iperf_port}
    Run keyword if   ${NR_L3call_need}==${true}   run keyword and ignore error
    ...    Block Cell for L3call   5G_call=${true}  5G_operation=Unlocked   4G_operation=unlocked
    Run keyword if   ${NR_L3call_need}==${true}   Wait until keyword succeeds  10min   1min   COAM Check all cells should be onair
    # Start NR UL traffic #
    Run keyword if   ${NR_L3call_need}==${true} and ('${direction}'=='BOTH' or '${direction}'=='UL')   Test_Case_ASOF_Data_Transfer_Conducted
    ...   bip_enable=${bip_enable}   traffic_stop=${traffic_stop}   direction=UL   duration=${duration}   4G_call_celllock=${false}
    ...   Lock_peak=${Lockcell_L3call_peak_needed}
    # Check NR UL tput not impact by unlock cell#
    Run keyword if   ${NR_L3call_need}==${true} and ('${direction}'=='BOTH' or '${direction}'=='UL')   Check Tput l3call
    ...   ue_type=${NR_ue_type}   ue_index=${NR_L3call_UE}   direction=UL   cells=${lock_case_NRcells}   expect=${5Gtput_expect_uL}
    Run keyword if   ${NR_L3call_need}==${true}   Block Cell for L3call   5G_call=${true}  5G_operation=Locked   4G_operation=locked
    # Check NR UL tput not impact by lock cell #
    Run keyword if   ${NR_L3call_need}==${true} and ('${direction}'=='BOTH' or '${direction}'=='UL')   Check Tput l3call
    ...   ue_type=${NR_ue_type}   ue_index=${NR_L3call_UE}   direction=UL   cells=${lock_case_NRcells}   expect=${5Gtput_expect_uL}
    Run keyword if   ${NR_L3call_need}==${true}   Stop traffic via iperf command on UE   ue_index=${NR_L3call_UE}   port=${iperf_port}
    Run keyword if   ${NR_L3call_need}==${true}   Block Cell for L3call   5G_call=${true}  5G_operation=Unlocked   4G_operation=unlocked
    Run keyword if   ${NR_L3call_need}==${true}   Wait until keyword succeeds  10min   1min   COAM Check all cells should be onair
    # Start LTE DL/UL traffic #
#    Run keyword if   ${LTE_L3call_need}==${true}   Test_Case_ASOF_Data_Transfer_Conducted   Lock_peak=${Lockcell_L3call_peak_needed}
#    ...   bip_enable=${bip_enable}   traffic_stop=${traffic_stop}   duration=90   5G_call_celllock=${false}
#    # Check LTE DL tput not impact by unlock cell #
#    Run keyword if   ${LTE_L3call_need}==${true} and ('${direction}'=='BOTH' or '${direction}'=='DL')   power_ue.Check Tput    ue_type=samsung_lte
#    ...    direction=dl    target_throughput=${4Gtput_expect_DL}   ue_index=${LTE_L3call_UE}   target_avg_percent=${4G_DL_tput_deviation}
#    # Check LTE UL tput not impact by unlock cell #
#    Run keyword if   ${LTE_L3call_need}==${true} and ('${direction}'=='BOTH' or '${direction}'=='UL')   power_ue.Check Tput    ue_type=samsung_lte
#    ...    direction=ul    target_throughput=${4Gtput_expect_uL}   ue_index=${LTE_L3call_UE}   target_avg_percent=${4G_UL_tput_deviation}
#    # Lock LTE NoL3CALL Cells ALL Onetime #
#    Run keyword if   ${LTE_L3call_need}==${true}   Block Cell for L3call   4G_call=${true}  5G_operation=Locked   4G_operation=locked
#    # Check LTE DL tput not impact by lock cell #
#    Run keyword if   ${LTE_L3call_need}==${true} and ('${direction}'=='BOTH' or '${direction}'=='DL')   power_ue.Check Tput    ue_type=samsung_lte
#    ...    direction=dl    target_throughput=${4Gtput_expect_DL}   ue_index=${LTE_L3call_UE}   target_avg_percent=${4G_DL_tput_deviation}
#    # Check LTE UL tput not impact by lock cell #
#    Run keyword if   ${LTE_L3call_need}==${true} and ('${direction}'=='BOTH' or '${direction}'=='UL')   power_ue.Check Tput    ue_type=samsung_lte
#    ...    direction=ul    target_throughput=${4Gtput_expect_uL}   ue_index=${LTE_L3call_UE}   target_avg_percent=${4G_UL_tput_deviation}
#    Run keyword if   ${LTE_L3call_need}==${true}   power_ue.Stop traffic   ue_type=samsung_lte   direction=dl   ue_index=${LTE_L3call_UE}
#    Run keyword if   ${LTE_L3call_need}==${true}   power_ue.Stop traffic   ue_type=samsung_lte   direction=ul   ue_index=${LTE_L3call_UE}
#    Run keyword if   ${LTE_L3call_need}==${true}   Block Cell for L3call   4G_call=${true}  5G_operation=Unlocked   4G_operation=unlocked
#    Run keyword if   ${LTE_L3call_need}==${true}   Wait until keyword succeeds  10min   1min   COAM Check all cells should be onair
    [Teardown]   Run Keyword And Ignore Error   Run Keywords
    ...   Askey stop DL traffic     iperf_port=${iperf_port}   AND
    ...   Stop traffic via iperf command on UE   ue_index=${NR_L3call_UE}   port=${iperf_port}   AND
    ...   Askey Detach    AND
    ...   Unblock All Cells


Test_Case_ASOF_BTS_Site_Reset
    [Arguments]   ${bip_enable}=${false}    ${traffic_stop}=${true}    ${duration}=90   ${direction}=BOTH
    Log To Console   BTS Site Reset Start ...
    FOR   ${index}    IN RANGE    ${Reset_times_needed}
       COAM WEBUI Whether Close Start Up View Window
       Site Reset
       Log To Console   BTS Site Reset Number: ${index + 1}
       ${number}=   Evaluate   ${index+1}%5
       Run keyword if   ${Reset_L3call_needed}==${true} and '${number}'=='0'   Test_Case_ASOF_Data_Transfer_Conducted
       ...   bip_enable=${bip_enable}   traffic_stop=${traffic_stop}   direction=${direction}   duration=${duration}
       ...   Reset_peak=${Reset_L3call_peak_needed}
    END
    Log To Console   BTS Site Reset Finish...


Remove HWF reset flag
    [Arguments]    ${hostname}=${asik_addr}
    ${flag1}   set variable   0x190030=0
    ${flag2}   set variable   0x4F0214=0
    log to console    check and remove HWF reset flag
    Wait Until Keyword Succeeds    15 min    1 min
    ...   csn.Connect to   hostname=${hostname}   username=${asik_username}   password=${asik_password}    alias=gnb
    ${swc_output1}   csn.execute    command=cat /ffs/run/swconfig.txt |grep 0x190030   connection=gnb
    ${swc_output2}   csn.execute    command=cat /ffs/run/swconfig.txt |grep 0x4F0214   connection=gnb
    ${flag1_status}  run keyword and return status   should contain any    ${swc_output1.split('\r\n')[0]}   ${flag1}
    ${flag2_status}  run keyword and return status   should contain any    ${swc_output2.split('\r\n')[0]}   ${flag2}
    run keyword if   ${flag1_status}    run keywords
    ...    csn.execute    command=sed -i 's/0x190030=0//g' /ffs/run/swconfig.txt   connection=gnb
    ...    AND   csn.execute    command=sed -i 's/#HWF reset flag for releases before 15 December 2021//g' /ffs/run/swconfig.txt
    ...    connection=gnb
    run keyword if   ${flag2_status}    run keywords
    ...    csn.execute    command=sed -i 's/0x4F0214=0//g' /ffs/run/swconfig.txt   connection=gnb
    ...    AND   csn.execute    command=sed -i 's/#HWF reset flag for releases after 15 December 2021//g' /ffs/run/swconfig.txt
    ...    connection=gnb
    run keyword if    ${flag1_status} or ${flag2_status}    run keywords
    ...    csn.execute    command=sed -i '/^[ ]*$/d' /ffs/run/swconfig.txt    connection=gnb
    ...    AND   csn.execute    command=crasign /ffs/run/swconfig.txt   connection=gnb
    ...    AND   Set Suite Variable    ${need_site_reset}    ${true}
    run keyword if   ${need_site_reset}    Site Reset
    [Teardown]    run keyword and ignore error    csn.Disconnect   connection=gnb


Add HWF reset flag
    [Arguments]    ${hostname}=${asik_addr}
    ${flag1}   set variable   0x190030=0
    ${flag2}   set variable   0x4F0214=0
    log to console    check and add HWF reset flag
    Wait Until Keyword Succeeds    15 min    1 min
    ...   csn.Connect to   hostname=${hostname}   username=${asik_username}   password=${asik_password}    alias=gnb
    ${swc_output1}   csn.execute    command=cat /ffs/run/swconfig.txt |grep 0x190030   connection=gnb
    ${swc_output2}   csn.execute    command=cat /ffs/run/swconfig.txt |grep 0x4F0214   connection=gnb
    ${flag1_status}  run keyword and return status   should contain any    ${swc_output1.split('\r\n')[0]}   ${flag1}
    ${flag2_status}  run keyword and return status   should contain any    ${swc_output2.split('\r\n')[0]}   ${flag2}
    run keyword if  not ${flag1_status}    csn.execute
    ...    command=echo "0x190030=0 #HWF reset flag for releases before 15 December 2021" >> /ffs/run/swconfig.txt
    ...    connection=gnb
    run keyword if  not ${flag2_status}    csn.execute
    ...    command=echo "0x4F0214=0 #HWF reset flag for releases after 15 December 2021" >> /ffs/run/swconfig.txt
    ...    connection=gnb
    run keyword if    '${flag1_status}'=='${False}' or '${flag2_status}'=='${False}'    run keywords
    ...    csn.execute    command=crasign /ffs/run/swconfig.txt   connection=gnb
    ...    AND   Set Suite Variable    ${need_site_reset}    ${true}
    run keyword if   ${need_site_reset}    Site Reset
    [Teardown]    run keyword and ignore error    csn.Disconnect   connection=gnb


Site Reset
#    COAM WEBUI Whether Close Start Up View Window
    COAM Reset Site
    Sleep   5m
    Wait Until Keyword Succeeds   20m   1m   COAM Check all cells should be onair


Test_Case_ASOF_BTS_Site_Reset_without_HWF_without_L3call
    Set Suite Variable    ${need_site_reset}    ${false}
    Add HWF reset flag
    Log To Console   BTS Site Reset without_HWF Start ...
    FOR   ${index}    IN RANGE    ${Reset_times_without_HWF_needed}
       Site Reset
       Log To Console   BTS Site Reset without_HWF Number: ${index + 1}
    END
    Log To Console   BTS Site Reset without_HWF Finish...
    [Teardown]   Remove HWF reset flag

Restart CBRS Service at Control PC
    Log to console   Restart CBRS Service
    ${scfname}   Return scf name by release
    coam.Import SCF On COAM    IP_WEBUI=${asik_addr}
    ...   SCF_FILE=${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/SCF_${scfname}_${configid}.xml
    set suite variable   ${scf_imported_need}   ${false}
    Stop Control PC Windows Process   ip_index=${CBRS_PC_index}
    Stop Control PC Cygwin Process    ip_index=${CBRS_PC_index}
    Remove CBRS Log
    Builtin.sleep  3min
    Start CBRS Service   ip_index=${CBRS_PC_index}
    Builtin.sleep  3min
    Wait Until Keyword Succeeds   15m   30s   COAM Check all cells should be onair

Start CBRS Service
    [Arguments]    ${ip_index}
    Wait Until Keyword Succeeds  2m   10s   Connect to control pc enhanced   ue_index=${ip_index}
    ${output}    csn.send command   command=cd ${CBRS_File_location};python SAS_Sim.py > log.txt &   connection=cpc_${ip_index}
    BuiltIn.sleep   5s
    ${output1}    csn.execute   command=ps -ef | grep python   connection=cpc_${ip_index}
    should not be empty    ${output1}
#    BuiltIn.sleep   2s
#    ${output2}    csn.execute   command=netstat -an | grep -iE "10.57.130.45:4433"   connection=cpc_${ip_index}
#    Should Contain Any   ${output2}   ESTABLISHED  LISTENING
    [Teardown]   Run Keyword And Ignore Error    csn.disconnect   connection=cpc_${ip_index}

Check CBRS If Cell Not Onair
    Wait Until Keyword Succeeds  2m   10s   Connect to control pc enhanced   ue_index=${CBRS_PC_index}
    ${output}    csn.execute    command=ps -ef | grep python   connection=cpc_${CBRS_PC_index}
    sleep    5s
    ${passed}    run keyword and return status    should not be empty    ${output}
    log to console    CBRS existing:${passed} .
    Log to console   Restart CBRS Service
    Stop Control PC Windows Process   ip_index=${CBRS_PC_index}
    Stop Control PC Cygwin Process    ip_index=${CBRS_PC_index}
    Builtin.sleep   3min
    Start CBRS Service   ip_index=${CBRS_PC_index}
    Builtin.sleep   3min
    Wait Until Keyword Succeeds   15m   30s   COAM Check all cells should be onair

Remove CBRS Log
    Connect to control pc enhanced   ue_index=${CBRS_PC_index}
    csn.execute    command=cd ${CBRS_File_location};rm -f SAS_Sim.log   connection=cpc_${CBRS_PC_index}
    [Teardown]   Run Keyword And Ignore Error   csn.disconnect   connection=cpc_${CBRS_PC_index}

Download CBRS Log
    Connect to control pc enhanced   ue_index=${CBRS_PC_index}
    wait until keyword succeeds     5min    1min
    ...    csn.download_file   ${CBRS_File_location}SAS_Sim.log
    ...    ${OUTPUT_DIR}SAS_Sim.log   connection=cpc_${CBRS_PC_index}
    [Teardown]   csn.disconnect   connection=cpc_${CBRS_PC_index}

ASOF_Collect_RFSW_logs_into_BTS_Snapshot
   [Timeout]  2h
   Case Setup: ASOF_Collect_RFSW_logs_into_BTS_Snapshot
   Test_Case_ASOF_Collect_RFSW_logs_into_BTS_Snapshot
   [Teardown]  Case Teardown: ASOF_Collect_RFSW_logs_into_BTS_Snapshot

ASOF_E2E_system_setup_with_data_transfer
   [Timeout]  2h
   Case Setup: ASOF_E2E_system_setup_with_data_transfer
   Test_Case_ASOF_Data_Transfer_Conducted
   [Teardown]  Case Teardown: ASOF_E2E_system_setup_with_data_transfer

ASOF_CM_Recommissioning
   [Timeout]  2h
   Case Setup: ASOF_CM_Recommissioning
   Test_Case_ASOF_CM_Recommissioning
   [Teardown]  Case Teardown: ASOF_CM_Recommissioning

ASOF_CM_Recommissioning_9499_G1
   [Timeout]  2h
   Case Setup: ASOF_CM_Recommissioning
   Test_Case_ASOF_CM_Recommissioning_9499_G1
   [Teardown]  Case Teardown: ASOF_CM_Recommissioning

ASOF_Cell_lock_and_unlock
   [Timeout]  3h
   Case Setup Steps: ASOF_Cell_lock_and_unlock
   Test_Case_ASOF_Cell_lock_and_unlock
   [Teardown]  Case Teardown Steps: ASOF_Cell_lock_and_unlock

ASOF_BTS_Site_Reset
   [Timeout]  5h
   Case Setup: ASOF_BTS_Site_Reset
   Test_Case_ASOF_BTS_Site_Reset
   [Teardown]  Case Teardown: ASOF_BTS_Site_Reset

ASOF_BTS_Site_Reset_without_HWF_without_L3call
   [Timeout]  15h
   Case Setup: ASOF_BTS_Site_Reset_without_HWF_without_L3call
   Test_Case_ASOF_BTS_Site_Reset_without_HWF_without_L3call
   [Teardown]  Case Teardown: ASOF_BTS_Site_Reset_without_HWF_without_L3call