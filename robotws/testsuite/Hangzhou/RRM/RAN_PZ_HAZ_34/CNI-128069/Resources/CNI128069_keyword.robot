*** Settings ***

Library  taf.selenium.sbts  WITH NAME  selenium_coam
Library           OperatingSystem
Library           Collections
Library           String
Library           BuiltIn
Library           taf.transport.ssh    WITH NAME    csn
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/scf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/admin_sbts.robot
Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/siso_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/sparkue.robot
Variables   ./TLConfigration_128069.py
Resource  testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008828/resources/CB008828_C_keyword.robot

Documentation
...    author: Liqin Yang
...    contact: liqin.yang@nokia-sbell.com
...    Group: HGZ_SG5

*** Variables ***
${PATH_Storage}    /home/ute/CNI128069
${nrcell_id}  1
${RG_1}  NRCELL-1/NRRESOURCEGROUP-1
${RG_5}  NRCELL-1/NRRESOURCEGROUP-5
${RG_3}  NRCELL-1/NRRESOURCEGROUP-3
@{RG_ID_C1}  5  9  10  11  18  19  20  1
@{RG_ID_C4}  5  9  10  11  18  19  20  1
@{RG_ID_C3}  5  9  10  11  18  19  20
@{RG_ID_C6}  1  9  10  11  18  20
${ue_file}  ${CURDIR}/TLConfigration_128069.py
@{low_buffer_t1}  5
@{low_buffer_t2}  5  9
${UELI}  "UELI"
${delta_dif_scheduleweight_T1}  ${CURDIR}/delta_files/delta_dif_scheduleweight_t1.json
${delta_dif_scheduleweight_T2}  ${CURDIR}/delta_files/delta_dif_scheduleweight_t2.json
${delta_dif_scheduleweight_T3}  ${CURDIR}/delta_files/delta_dif_scheduleweight_t3.json
# ${delta_40Mhz}  ${CURDIR}/delta_files/delta_40Mhz.json
@{call_ue_C1}  0  1  2  3  4  5  6  7
@{call_ue_C3}  0  1  2  3  4  5  6
${diff_low}  6
${diff_ul}  3
${diff_low_ratio}  0.5
${ul_power_port_list}     ${tl.ues[0].iperf_details.ports[0:8]}
@{NCUPNRG_counter_1}  M55910C00003  M55910C00004
${GBR_port}  45430
@{mdrb_ue}  2  3  4
${process}  4
${low_throughput}  40
&{IP_RG}  227=5  229=9  230=10  231=11  233=18  234=19  235=20  237=1
*** Keywords ***
Forming RG list via RG ID list
  [Arguments]  ${index_list}=${RG_ID_C1}
  @{RG_list}  Create List
  FOR  ${i}  IN  @{index_list}
    ${RG}  Catenate  SEPARATOR=  NRCELL-1/NRRESOURCEGROUP-  ${i}
    Append To List  ${RG_list}  ${RG}
  END
  [Return]  ${RG_list}

Check UL PRB ratio for full buffer
  [Arguments]  ${actual_ratio_list}
    ${ue_counter}  Get Length  ${actual_ratio_list}
    FOR  ${i}  IN RANGE  ${ue_counter}
      ${big_value}  Evaluate  ${target_quota_list}[${i}]+${diff_ul}
      ${small_value_tmp}  Evaluate  ${target_quota_list}[${i}]-${diff_ul}
      ${small_value}  Set Variable If  ${small_value_tmp}>=${0}  ${small_value_tmp}  0
      ${PRB_ratio}  Set Variable  ${actual_ratio_list}[${i}]
      Run Keyword And Continue On Failure  should be true
      ...  ${PRB_ratio}>=${small_value} and ${PRB_ratio}<=${big_value}
    END

Check DL PRB ratio for full buffer
  [Arguments]  ${actual_ratio_list}
    ${ue_counter}  Get Length  ${actual_ratio_list}
    FOR  ${i}  IN RANGE  ${ue_counter}
      ${status}  Run Keyword And Return Status  Should Be True  ${target_quota_list}[${i}] > 10
      ${big_value}  Run Keyword If  ${status}  Evaluate  ${target_quota_list}[${i}]*(1+${diff_low}*0.01)
      ...  ELSE  Evaluate  ${target_quota_list}[${i}]+${diff_low_ratio}
      ${small_value}  Run Keyword If  ${status}  Evaluate  ${target_quota_list}[${i}]*(1-${diff_low}*0.01)
      ...  ELSE  Evaluate  ${target_quota_list}[${i}]-${diff_low_ratio}
      ${PRB_ratio}  Set Variable  ${actual_ratio_list}[${i}]
      Run Keyword And Continue On Failure  should be true
      ...  ${PRB_ratio}>=${small_value} and ${PRB_ratio}<=${big_value}
    END

Make call and check M55910
  [Arguments]  ${index_list}=${RG_ID_C1}
  ...  ${check_id}=${RG_1}  ${max_ue_num}=${8}  ${call_list}=${call_ue_C1}  ${mdrb_traffic}=${False}
  ${ue_config_tmp}  Change_ue_index_for_call  ue_config=${TLCommonConfig}  ue_ids=${call_list}
  ${ue_config}  Change_DL_TP  ue_config=${ue_config_tmp}  dl_list=${expected_dl_TP}  ue_list=${call_list}
  Prepare SparkUE And Attach    multiue_config_direction=${ue_config["MultiUECFG"]}  restart_ue=${True}  max_ue_num=${max_ue_num}
  ...  if_ul=${False}
  ${ue_ip_dict}  MultiUE Start UDP Traffic    if_ul=${False}    if_dl=${True}
  Run keyword If  ${mdrb_traffic}  MultiUE Start UDP DL Traffic  ue_index_list=${mdrb_ue}  ue_ip_dict=${ue_ip_dict}  throughput=30M
  ...  dl_port=${GBR_port}
  Run Keyword And Ignore Error  Check Each UE TP  ue_list=${ue_config['MultiUECFG']['ue_index_for_call']}  if_ul=${False}    if_dl=${True}
  ${check_time}  Get counter time  check_id=${check_id}
  [Teardown]  Run keywords  Run Keyword And Ignore Error  UE detach and stop traffic  ue_ip_dict=${ue_ip_dict}  mdrb_traffic=${mdrb_traffic}
  ...  AND  Check M55910 for traffic  counter_groups=${check_time}  index_list=${index_list}

Get maxQuota minQuota quota list
  [Arguments]  ${index_list}=${RG_ID_C1}  ${id}=1
  ${allmaxQuota}  ${allminQuota}  Get allmaxQuota and allminQuota  index_list=${index_list}  id=${id}
  Set Test Variable  ${allmaxQuota}
  Set Test Variable  ${allminQuota}
  Log To Console  Get target_quota_list for NRCELL-1/NRRESOURCEGROUP-${index_list}
  ${target_quota_list}  Calculate all Quota  allmaxQuota=${allmaxQuota}  allminQuota=${allminQuota}
  Set Test Variable  ${target_quota_list}

DL_SAS_same_scheduleweight_full_buffer_test
  [Arguments]  ${attach_mode}=5G_SA  ${index_list}=${RG_ID_C1}
  ...  ${check_id}=${RG_1}  ${max_ue_num}=${8}  ${call_list}=${call_ue_C1}
  ${scf_file_path}  Get SCF From BTS
  Set Test Variable  ${scf_file_path}
  Get maxQuota minQuota quota list  index_list=${index_list}
  ${dl_throughput_tmp}  ${ul_throughput}  Get Theoretical Throughput  cellid=${nrcell_id}  attach_mode=${attach_mode}
  ${dl_throughput_t}  Evaluate  ${dl_throughput_tmp}/${process}
  ${dl_throughput}  convert to integer  ${dl_throughput_t}
  @{expected_dl_TP}  Create List
  FOR  ${i}  IN RANGE  ${max_ue_num}
    Append To List  ${expected_dl_TP}  ${dl_throughput}
  END
  Set Test Variable  ${expected_dl_TP}
  ${target_dl_TP}  Get expected TP list  throughput=${dl_throughput_tmp}  quota_list=${target_quota_list}
  Make call and check M55910  index_list=${index_list}
  ...  check_id=${check_id}  max_ue_num=${max_ue_num}  call_list=${call_list}

Get expected TP list
  [Arguments]  ${throughput}  ${quota_list}
  @{TP_list}  Create List
  FOR  ${i}  IN  @{quota_list}
    ${throughput_tmp}  Evaluate  ${throughput}*${i}*0.01
    ${throughput_t}  convert to integer  ${throughput_tmp}
    Append To List  ${TP_list}  ${throughput_t}
  END
  [Return]  ${TP_list}

UE detach and stop traffic
    [Arguments]    ${ue_ip_dict}=None  ${mdrb_traffic}=${False}  ${if_ul}=${False}    ${if_dl}=${True}  ${if_listen}=${False}
    MultiUE Stop UDP Traffic    if_ul=${if_ul}    if_dl=${if_dl}
    Run keyword If  ${mdrb_traffic}  MultiUE Stop UDP DL Traffic  ue_index_list=${mdrb_ue}  ue_ip_dict=${ue_ip_dict}  dl_port=${GBR_port}
    Run Keyword If  ${if_dl} and ${if_listen}  Stop Iperf Listen On Spark  ue_index_list=${call_ue_C1}  ue_ip_dict=${ue_ip_dict}
    Run Keyword If  ${if_ul} and ${if_listen}  Stop Iperf Listen On Appserver  ue_index_list=${call_ue_C1}  ul_port_list=${ul_power_port_list}
    sparkue.MultiUE Detach

DL_SAS_different_scheduleweight_full_buffer_test
  scf.Activate or Deactivate feature    delta_file=${delta_dif_scheduleweight_T1}  timeout=600
  Log To Console  Test1
  Connect to gnb coam via ssl
  ${scf_file_path}  Get SCF From BTS
  Set Test Variable  ${scf_file_path}
  ${dl_throughput_tmp}  ${ul_throughput}  Get Theoretical Throughput  cellid=${nrcell_id}  attach_mode=5G_SA
  Get maxQuota minQuota quota list
  ${dl_throughput_t}  Evaluate  ${dl_throughput_tmp}/${process}
  ${dl_throughput}  convert to integer  ${dl_throughput_t}
  @{expected_dl_TP}  Create List
  FOR  ${i}  IN RANGE  8
    Append To List  ${expected_dl_TP}  ${dl_throughput}
  END
  Set Test Variable  ${expected_dl_TP}
  ${target_dl_TP}  Get expected TP list  throughput=${dl_throughput_tmp}  quota_list=${target_quota_list}
  Make call and check M55910
  scf.Activate or Deactivate feature    delta_file=${delta_dif_scheduleweight_T2}  timeout=600
  Log To Console  Test2
  Connect to gnb coam via ssl
  Make call and check M55910
  scf.Activate or Deactivate feature    delta_file=${delta_dif_scheduleweight_T3}  timeout=600
  Log To Console  Test3
  Connect to gnb coam via ssl
  Make call and check M55910

DL_SAS_same_scheduleweight_some_RGs_no_UE
  DL_SAS_same_scheduleweight_full_buffer_test  index_list=${RG_ID_C3}  max_ue_num=${7}  call_list=${call_ue_C3}
  ...  check_id=${RG_5}

Check PRB ratio
  [Arguments]  ${actual_ratio_list}  ${low_counter}=1
  ${factor}  Set Variable  1
  @{target_ratio_new}  Create List
    FOR  ${i}  IN RANGE  ${low_counter}
      ${factor_tmp}  Evaluate  ${factor}-${actual_ratio_list}[${i}]*0.01
      ${factor}  Set Variable  ${factor_tmp}
      Append To List  ${target_ratio_new}  ${actual_ratio_list}[${i}]
    END
    FOR  ${i}  IN RANGE  ${low_counter}  8
      ${m}  Evaluate  ${i}-${low_counter}
      ${PRB_ratio_target}  Evaluate  ${target_quota_list1}[${m}]*${factor}
      Append To List  ${target_ratio_new}  ${PRB_ratio_target}
      ${status}  Run Keyword And Return Status  Should Be True  ${PRB_ratio_target} > 10
      ${big_value}  Run Keyword If  ${status}  Evaluate  ${PRB_ratio_target}*(1+${diff_low}*0.01)
      ...  ELSE  Evaluate  ${PRB_ratio_target}+${diff_low_ratio}
      ${small_value}  Run Keyword If  ${status}  Evaluate  ${PRB_ratio_target}*(1-${diff_low}*0.01)
      ...  ELSE  Evaluate  ${PRB_ratio_target}-${diff_low_ratio}
      ${PRB_ratio}  Set Variable  ${actual_ratio_list}[${i}]
      Run Keyword And Continue On Failure  should be true
      ...  ${PRB_ratio}>=${small_value} and ${PRB_ratio}<=${big_value}
    END
    Log To Console  target_ratio_new:${target_ratio_new}

Make call with low buffer traffic and check M55910
  [Arguments]  ${attach_mode}=5G_SA
  ...  ${check_id}=${RG_1}  ${max_ue_num}=${8}  ${call_list}=${call_ue_C1}  ${low_counter}=1
  ${dl_throughput_tmp}  ${ul_throughput}  Get Theoretical Throughput  cellid=${nrcell_id}  attach_mode=${attach_mode}
  ${dl_throughput_t}  Evaluate  ${dl_throughput_tmp}/${process}
  ${dl_throughput}  convert to integer  ${dl_throughput_t}
  ${full_ue_num}  Evaluate  8-${low_counter}
  @{expected_dl}  Create List
  FOR  ${i}  IN RANGE  ${full_ue_num}
    Append To List  ${expected_dl}  ${dl_throughput}
  END
  ${low_throughput_t}  Evaluate  ${low_throughput}/${process}
  ${low_throughput_i}  convert to integer  ${low_throughput_t}
  @{expected_dl_tmp}  Create List
  FOR  ${i}  IN RANGE  ${low_counter}
    Append To List  ${expected_dl_tmp}  ${low_throughput_i}
  END
  ${expected_dl_TP}  Combine Lists  ${expected_dl_tmp}  ${expected_dl}
  ${dl_throughput}  Evaluate  ${dl_throughput_tmp}-40*${low_counter}
  ${target_dl}  Get expected TP list  throughput=${dl_throughput_tmp}  quota_list=${target_quota_list1}
  ${ue_config_tmp}  Change_ue_index_for_call  ue_config=${TLCommonConfig}  ue_ids=${call_list}
  ${ue_config}  Change_DL_TP  ue_config=${ue_config_tmp}  dl_list=${expected_dl_TP}  ue_list=${call_list}
  Prepare SparkUE And Attach    multiue_config_direction=${ue_config["MultiUECFG"]}  restart_ue=${True}  max_ue_num=${max_ue_num}
  ...  if_ul=${False}
  MultiUE Start UDP Traffic    if_ul=${False}    if_dl=${True}
  Run Keyword And Ignore Error  Check Each UE TP  ue_list=${ue_config['MultiUECFG']['ue_index_for_call']}  if_ul=${False}    if_dl=${True}
  ${check_time}  Get counter time  check_id=${check_id}
  [Teardown]  Run keywords  Run Keyword And Ignore Error  UE detach and stop traffic
  ...  AND  Check M55910 for traffic  counter_groups=${check_time}  full=${False}  low_counter=${low_counter}

DL_SAS_same_scheduleweight_low_buffer_test
  [Arguments]  ${cal_list}=${RG_ID_C4}  ${RG_list}=${RG_ID_C1}  ${low_buffer_list}=${low_buffer_t1}
  FOR  ${i}  IN  @{low_buffer_list}
    Remove Values From List  ${cal_list}  ${i}
  END
  Get maxQuota minQuota quota list  index_list=${cal_list}
  Set Test Variable  ${target_quota_list1}  ${target_quota_list}
  Get maxQuota minQuota quota list  index_list=${RG_list}
  ${low_counter}  Get Length  ${low_buffer_list}
  Make call with low buffer traffic and check M55910  low_counter=${low_counter}

DL_SAS_same_scheduleweight_some_RGs_low_buffer
  Log To Console  Test1:UE1 low buffer
  ${scf_file_path}  Get SCF From BTS
  Set Test Variable  ${scf_file_path}
  Run Keyword And Continue On Failure  DL_SAS_same_scheduleweight_low_buffer_test
  Log To Console  Test2:UE1 UE2 low buffer
  DL_SAS_same_scheduleweight_low_buffer_test  low_buffer_list=${low_buffer_t2}

UL_SAS_same_scheduleweight_full_buffer
  ${scf_file_path}  Get SCF From BTS
  Set Test Variable  ${scf_file_path}
  ${dl_throughput}  ${ul_throughput_tmp}  Get Theoretical Throughput  cellid=${nrcell_id}  attach_mode=5G_SA
  ${ul_throughput}  convert to integer  ${ul_throughput_tmp}
  Set Test Variable  ${ul_throughput}
  @{expected_ul_TP}  Create List
  FOR  ${i}  IN RANGE  8
    Append To List  ${expected_ul_TP}  ${ul_throughput}
  END
  ${ue_config_tmp}  Change_ue_index_for_call  ue_config=${TLCommonConfig}  ue_ids=${call_ue_C1}
  ${ue_config}  Change_UL_TP  ue_config=${ue_config_tmp}  ul_list=${expected_ul_TP}  ue_list=${call_ue_C1}
  Get maxQuota minQuota quota list  index_list=${RG_ID_C6}  id=2
  ${target_ul_TP}  Get expected TP list  throughput=${ul_throughput}  quota_list=${target_quota_list}
  Prepare SparkUE And Attach    multiue_config_direction=${ue_config["MultiUECFG"]}  restart_ue=${True}  max_ue_num=${8}
  ...  if_ul=${True}
  MultiUE Start UDP Traffic    if_ul=${True}    if_dl=${False}  ul_tp_list=${expected_ul_TP}  ul_port_list=${ul_power_port_list}
  Start Iperf Listen On Appserver  ue_index_list=${call_ue_C1}  ul_port_list=${ul_power_port_list}
  Run Keyword And Ignore Error  Check Each UE TP  ue_list=${ue_config['MultiUECFG']['ue_index_for_call']}  if_dl=${False}    if_ul=${True}
  ${check_time}  Get counter time  counter=M55910C00003
  [Teardown]  Run keywords  Run Keyword And Ignore Error  UE detach and stop traffic  if_ul=${True}    if_dl=${False}  if_listen=${True}
  ...  AND  Check M55910 for traffic  counter_groups=${check_time}  index_list=${RG_ID_C6}  counter1=M55910C00003  counter2=M55910C00004
  ...  if_dl=${False}
  ...  AND  Check counter M55370C00041 and NBR congestion  check_time=${check_time}

DL_and_UL_SAS_same_scheduleweight_full_buffer
  scf.scf uploading and commissioning  Log_directory=${CURDIR}/delta_files  SCF_Filename=UL_DL_40Mhz.xml
  # scf.Activate or Deactivate feature    delta_file=${delta_40Mhz}  timeout=600
  coam_gnb_classical.Connect to gnb coam via ssl
  ${scf_file_path}  Get SCF From BTS
  Set Test Variable  ${scf_file_path}
  ${dl_throughput_tmp}  ${ul_throughput_tmp}  Get Theoretical Throughput  cellid=${nrcell_id}  attach_mode=5G_SA
  ${ul_throughput}  convert to integer  ${ul_throughput_tmp}
  ${dl_throughput_t}  Evaluate  ${dl_throughput_tmp}/${process}
  ${dl_throughput}  convert to integer  ${dl_throughput_t}
  Set Test Variable  ${ul_throughput}
  Set Test Variable  ${dl_throughput_tmp}
  @{expected_ul_TP}  Create List
  @{expected_dl_TP}  Create List
  FOR  ${i}  IN RANGE  8
    Append To List  ${expected_ul_TP}  ${ul_throughput}
    Append To List  ${expected_dl_TP}  ${dl_throughput}
  END
  ${ue_config_1}  Change_ue_index_for_call  ue_config=${TLCommonConfig}  ue_ids=${call_ue_C1}
  ${ue_config_2}  Change_UL_TP  ue_config=${ue_config_1}  ul_list=${expected_ul_TP}  ue_list=${call_ue_C1}
  ${ue_config}  Change_DL_TP  ue_config=${ue_config_2}  dl_list=${expected_dl_TP}  ue_list=${call_ue_C1}
  Prepare SparkUE And Attach    multiue_config_direction=${ue_config["MultiUECFG"]}  restart_ue=${True}  max_ue_num=${8}
    ...  if_ul=${True}
  ${ue_ip_dict}  MultiUE Start UDP Traffic  if_ul=${True}  if_dl=${True}  ul_tp_list=${expected_ul_TP}  ul_port_list=${ul_power_port_list}
  Start Iperf Listen On Spark  ue_index_list=${call_ue_C1}  ue_ip_dict=${ue_ip_dict}
  Start Iperf Listen On Appserver  ue_index_list=${call_ue_C1}  ul_port_list=${ul_power_port_list}
  Run Keyword And Ignore Error  Check Each UE TP  ue_list=${ue_config['MultiUECFG']['ue_index_for_call']}  if_ul=${True}    if_dl=${True}
  ${check_time}  Get counter time
  [Teardown]  Run keywords  Run Keyword And Ignore Error  UE detach and stop traffic  if_ul=${True}    if_dl=${True}  if_listen=${True}
  ...  ue_ip_dict=${ue_ip_dict}
  ...  AND  Check M55910 for UL and DL traffic  check_time=${check_time}
  ...  AND  CI_interface.Common Suite Setup

Check M55910 for UL and DL traffic
  [Arguments]  ${check_time}
  Get maxQuota minQuota quota list  index_list=${RG_ID_C6}  id=2
  ${target_ul_TP}  Get expected TP list  throughput=${ul_throughput}  quota_list=${target_quota_list}
  Check M55910 for traffic  counter_groups=${check_time}  index_list=${RG_ID_C6}  counter1=M55910C00003  counter2=M55910C00004
  ...  if_dl=${False}
  Get maxQuota minQuota quota list
  ${target_ul_TP}  Get expected TP list  throughput=${dl_throughput_tmp}  quota_list=${target_quota_list}
  Check M55910 for traffic  counter_groups=${check_time}

Get counter time
  [Arguments]  ${check_id}=${RG_1}  ${counter}=M55910C00001
  Wait for one counter period
  ${check_time}  Get Check time  NPRMQAP-id=${check_id}  counter=${counter}  meas=${M55910}
  [return]  ${check_time}

Check M55910 for traffic
  [Arguments]  ${counter_groups}  ${index_list}=${RG_ID_C1}  ${counter1}=M55910C00001  ${counter2}=M55910C00002
  ...  ${full}=${True}  ${low_counter}=1  ${if_dl}=${True}
  Log To Console  RG target quota list:${target_quota_list}
  ${RG_C1}  Forming RG list via RG ID list  index_list=${index_list}
  ${PRB_ratio_list}  Check PRB value in counter  target_quota=${target_quota_list}  counter_groups=${counter_groups}  counter=${counter1}
    ...  counter_object=${RG_C1}  check_PRB=${False}
  Log To Console  RG actual quota list:${PRB_ratio_list}
  Check Quota value in counter  counter_groups=${counter_groups}  counter=${counter2}
    ...  counter_object=${RG_C1}
  Run keyword If  ${full} and ${if_dl}  Check DL PRB ratio for full buffer  actual_ratio_list=${PRB_ratio_list}
  ...  ELSE IF  ${if_dl}  Check PRB ratio  actual_ratio_list=${PRB_ratio_list}  low_counter=${low_counter}
  ...  ELSE  Check UL PRB ratio for full buffer  actual_ratio_list=${PRB_ratio_list}


DL_SAS_same_scheduleweight_some_RGs_run_mixed_GBR_nonGBR
  ${scf_file_path}  Get SCF From BTS
  Set Test Variable  ${scf_file_path}
  ${dl_throughput_tmp}  ${ul_throughput_tmp}  Get Theoretical Throughput  cellid=${nrcell_id}  attach_mode=5G_SA
  ${dl_throughput_t}  Evaluate  ${dl_throughput_tmp}/${process}
  ${dl_throughput}  convert to integer  ${dl_throughput_t}
  @{expected_dl_TP}  Create List
  FOR  ${i}  IN RANGE  8
    Append To List  ${expected_dl_TP}  ${dl_throughput}
  END
  Set Test Variable  ${expected_dl_TP}
  Get maxQuota minQuota quota list
  Make call and check M55910  mdrb_traffic=${True}

MultiUE Start UDP DL Traffic
  [Arguments]  ${ue_index_list}    ${ue_ip_dict}  ${throughput}
    ...    ${dl_port}      ${dl_time}=1800
    ...    ${hostname}=${tl.ues[0].iperf_details.ssh_connection_details.addr}
    ...    ${username}=${tl.ues[0].iperf_details.ssh_connection_details.username}
    ...    ${password}=${tl.ues[0].iperf_details.ssh_connection_details.password}
    ...    ${alias}=APPserver
    ...    ${parallel}=${1}
  Wait Until Keyword Succeeds    1 min    10 sec    csn.Connect to
    ...    hostname=${hostname}
    ...    username=${username}
    ...    password=${password}
    ...    alias=${alias}
  FOR  ${ue_index}  IN  @{ue_index_list}
      ${UE_ip}  get from dictionary    ${ue_ip_dict}     ${ue_index}
      ${command_str}  Catenate
      ...  iperf -c ${ue_ip} -u -t ${dl_time} -i 1 -p ${dl_port} -P ${parallel} -f m -b ${throughput} -l 1400B -T 64&
      csn.send command  command=${command_str}  connection=${alias}
        sleep   2s
        log to console    UE_${ue_index} start DL UDP Traffic
  END
  csn.Disconnect   connection=${alias}

MultiUE Stop UDP DL Traffic
  [Arguments]  ${ue_index_list}    ${ue_ip_dict}  ${dl_port}
    ...    ${hostname}=${tl.ues[0].iperf_details.ssh_connection_details.addr}
    ...    ${username}=${tl.ues[0].iperf_details.ssh_connection_details.username}
    ...    ${password}=${tl.ues[0].iperf_details.ssh_connection_details.password}
    ...    ${alias}=APPserver

    Wait Until Keyword Succeeds    1 min    10 sec    csn.Connect to
    ...    hostname=${hostname}
    ...    username=${username}
    ...    password=${password}
    ...    alias=${alias}
    FOR  ${ue_index}  IN  @{ue_index_list}
        ${UE_ip}  get from dictionary    ${ue_ip_dict}     ${ue_index}
        ${command_str}    Catenate
        ...      ps aux |grep iperf |grep ${UE_ip}|grep ${dl_port} |awk '{print $2}' | xargs kill -9
        csn.send command  command=${command_str}  connection=${alias}
        sleep   2s
        Log To Console  UE_${ue_index} stop DL UDP Traffic
    END
    csn.Disconnect   connection=${alias}

Check counter M55370C00041 and NBR congestion
  [Arguments]  ${check_time}
  ${value}  Get latest counter value  counter_id=M55370C00041  check_time=${check_time}  counter_full_path=CELLS/NRCELL-1/NULH
  ${sta}  Run Keyword And Return Status  Should Be True  ${value}==${600}
  Run Keyword If  ${sta}  Log to console  ***there is NBR congestion***
