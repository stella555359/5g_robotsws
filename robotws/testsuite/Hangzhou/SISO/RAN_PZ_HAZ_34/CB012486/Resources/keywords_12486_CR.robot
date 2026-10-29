*** Settings ***
Documentation     author: Yang Liqin
...               contact: liqin.yang@nokia-sbell.com
...               squad group: MMW_SG_05
Library  taf.selenium.sbts  WITH NAME  selenium_coam
Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/Cloud/Cloud_General_SiSo_vDU_Reset.robot
Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/android_ue.robot
*** Variables ***
${ue_index}  ${0}
@{pci_list}  166  167  168 
@{arfcnSsbPbch_list}  634944  653280  631680
${cell_num}  3   
${duration}  60
${call_duration}  1200
@{identity_list}  189169665  189169666  189169667
${avg_expect_rate}  0.7
${min_expect_rate}  0.3
${dl_tp}  100
${ul_tp}  5
${loop_times}  3
*** Keywords ***
Cloud_Manual_SiSo_SM_BTS_Site_Reset
  Cloud Reset vDU and Check Cell On Air   need_check_on_air=${True}
  Cloud UE L3 CAll

Cloud UE L3 CAll
  ${ue_type}  ue.Translate Power Ue Type From Testline  ue_index=${ue_index}
  set suite variable  ${ue_type}
  power_ue.Prepare UE      ue_index=${ue_index}    ue_type=${ue_type}
  FOR  ${id}  IN RANGE  ${cell_num}
    nokia_fastmile.Modify UE Capatibility  ue_index=${ue_index}  pci=${pci_list}[${id}]    arfcn=${arfcnSsbPbch_list}[${id}]
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  ${loop_times}x  30sec  Receiver 5G19-A make call  cell_id=${id}    
  END

Receiver 5G19-A make call
    [Arguments]  ${cell_id}=0
    log to console  Receiver 5G19-A make call with cell_${cell_id}
    power_ue.UE Attach     ue_type=${ue_type}    ue_index=${ue_index}  log_type=Cloud
    power_ue.Start traffic  ue_type=${ue_type}  direction=dl  throughput=150M  duration=${call_duration}
    ...    ue_index=${ue_index}    iperf_type=via_command
    power_ue.Start traffic  ue_type=${ue_type}  direction=ul  throughput=20M  duration=${call_duration}
    ...    ue_index=${ue_index}    iperf_type=via_app
    sleep  60
    ${tput_log}  Cloud_Throughput.Cloud Collect Tput from VDU  duration=${duration}
    ${cells}  Create List  ${identity_list}[${cell_id}]
    ${all_dl_details}  Run Keyword And Continue On Failure  steam_aasyslog.check_aasyslog_throughput  direction=dl  log_path=${tput_log}
    ...  local_output_dir=${SAVE LOG DIRECTORY}  cells=${cells}  theoretical_throughput=${dl_tp}  average_tolerance=${avg_expect_rate}
    ...  minimum_tolerance=${min_expect_rate}
    ${all_ul_details}  Run Keyword And Continue On Failure  steam_aasyslog.check_aasyslog_throughput  direction=ul  log_path=${tput_log}
    ...  local_output_dir=${SAVE LOG DIRECTORY}  cells=${cells}  theoretical_throughput=${ul_tp}  average_tolerance=${avg_expect_rate}
    ...  minimum_tolerance=${min_expect_rate}
    ${dl_detail}  cloud_throughput.Get DL Details  all_dl_details=${all_dl_details}  identity_id=${identity_list}[${cell_id}]
    ${ul_detail}  Get UL dtails  all_ul_details=${all_ul_details}  identity=${identity_list}[${cell_id}]
    Log To Console  cell_${cell_id} dl_detail:${dl_detail} ul_detail:${ul_detail}
    [Teardown]  Dettach UE and Stop traffic    ue_index=${ue_index}  ue_type=${ue_type}

Get UL dtails
    [Arguments]  ${all_ul_details}    ${identity}
     FOR  ${ul_detail}  IN  @{all_ul_details}
         return from keyword if    '${identity}'=='${ul_detail['cellid']}'    ${ul_detail}
     END

Test Setup
    log to console    *****Cloud Test Setup*****
    ${TS_CASE_LOG_PATH}    generic_utils.generate_log_path_with_log_type
    Set Test Variable    ${SAVE LOG DIRECTORY}    ${TS_CASE_LOG_PATH}
    log to console  case log path:${TS_CASE_LOG_PATH}

