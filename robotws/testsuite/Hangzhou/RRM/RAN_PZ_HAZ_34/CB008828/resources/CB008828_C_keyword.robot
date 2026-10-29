*** Settings ***
Library     taf.transport.ssh    WITH NAME    ssh
Library     taf.config.wts       WITH NAME    wts
Resource  ./CB008828_keyword.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py    WITH NAME
...    throughput_computation
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot

Documentation
...    author: Liqin Yang
...    contact: liqin.yang@nokia-sbell.com
...    Group: HGZ_SG5

*** Variables ***
${ue_0_type}  samsung
${ue_1_type}  samsung
${ue_type_0}  samsung
${ue_type_1}  samsung
${ue0_qci7_port}  45317
${ue1_qci7_port}  45916
${ue0_qci2_port}  45316
# ${ue0_noGBR_port}  45317
${NRRESOURCEGROUP-5}  NRCELL-4/NRRESOURCEGROUP-5
${NRRESOURCEGROUP-2}  NRCELL-4/NRRESOURCEGROUP-2
${NRRESOURCEGROUP-3}  NRCELL-4/NRRESOURCEGROUP-3
${NRRESOURCEGROUP-1}  NRCELL-4/NRRESOURCEGROUP-1
${NRRESOURCEGROUP-4}  NRCELL-4/NRRESOURCEGROUP-4
${NRRESOURCEGROUP-22}  NRCELL-4/NRRESOURCEGROUP-22
${NRRESOURCEGROUP-1_ca}  NRCELL-1/NRRESOURCEGROUP-1
${NRRESOURCEGROUP-2_ca}  NRCELL-1/NRRESOURCEGROUP-2
${NRRESOURCEGROUPS-1}  NRCELL-3/NRRESOURCEGROUP-1
${NRRESOURCEGROUPS-2}  NRCELL-3/NRRESOURCEGROUP-2
${NRRESOURCEGROUP-5_19}  NRCELL-2/NRRESOURCEGROUP-5
${NRRESOURCEGROUP-2_19}  NRCELL-2/NRRESOURCEGROUP-2
${NRRESOURCEGROUP-1_19}  NRCELL-2/NRRESOURCEGROUP-1
${CELL_ID}  NRCELL-4
${M55910}  NCUPNRG
${M55308}  NCELA
${M55351}  DBWP
${diff}  6
@{RG_ID}  5  2
@{RG_ID_15}  1  4
@{RG_ID_26}  1  2
@{NRRESOURCEGROUP}  ${NRRESOURCEGROUP-5}  ${NRRESOURCEGROUP-2}
@{NRRESOURCEGROUP_19}  ${NRRESOURCEGROUP-5_19}  ${NRRESOURCEGROUP-2_19}
@{NRRESOURCEGROUP_15}  ${NRRESOURCEGROUP-1}  ${NRRESOURCEGROUP-4}
@{NRRESOURCEGROUP_26}  ${NRRESOURCEGROUPS-1}  ${NRRESOURCEGROUPS-2}
@{NRRESOURCEGROUP_12}  ${NRRESOURCEGROUP-1}  ${NRRESOURCEGROUP-2}
@{NRRESOURCEGROUP_26_ca}  ${NRRESOURCEGROUP-1_ca}  ${NRRESOURCEGROUP-2_ca}
${cell_id_1}  4
${Pcell_id}  1
${Scell_id}  3
${cell_id_2}  2
@{NCUPNRG_counter}  M55910C00001  M55910C00002
@{NCELA_counter}  M55308C33000
@{DBWP_counter_1}  M55351C00001  M55351C00002
@{DBWP_counter_2}  M55351C01001  M55351C01002
${delta_delete_NRRESOURCEGROUP22}  ${CURDIR}/config/delta_files/delta_delete_NRRESOURCEGROUP22.json
${delta_add_NRRESOURCEGROUP22}  ${CURDIR}/config/delta_files/delta_add_NRRESOURCEGROUP22.json
${delta_delete_two_NRRESOURCEGROUP}  ${CURDIR}/config/delta_files/delta_delete_two_NRRESOURCEGROUP.json
${delta_add_two_NRRESOURCEGROUP}  ${CURDIR}/config/delta_files/delta_add_two_NRRESOURCEGROUP.json
${delta_delete_one_NRRESOURCEGROUP}  ${CURDIR}/config/delta_files/delta_delete_one_NRRESOURCEGROUP.json
${delta_add_one_NRRESOURCEGROUP}  ${CURDIR}/config/delta_files/delta_add_one_NRRESOURCEGROUP.json
${delta_add_one1_NRRESOURCEGROUP}  ${CURDIR}/config/delta_files/delta_add_one1_NRRESOURCEGROUP.json
${delta_modify_two_NRRESOURCEGROUP}  ${CURDIR}/config/delta_files/delta_modify_two_NRRESOURCEGROUP.json
${delta_enable_Micro_DTX}  ${CURDIR}/config/delta_files/delta_enable_Micro_DTX.json
${delta_disable_Micro_DTX}  ${CURDIR}/config/delta_files/delta_disable_Micro_DTX.json
${delta_NSA_CB008746_disabled}  ${CURDIR}/config/delta_files/delta_NSA_CB008746_disabled.json
${delta_CB008746_enabled}  ${CURDIR}/config/delta_files/delta_CB008746_enabled.json
${DL_Peak_TP}  ${274}
${UL_Peak_TP}  ${73}
${small_tp_value}  100k
${NPRMQAP-1}  NRCELL-13/NRPMQAP-1
${M55359}  NL1SL
@{NCELA_counter_4}  M55308C10013
@{NCELA_counter_4_r2}  M55308C10007
@{NL1SL_counter}  M55359C00000  M55359C00001
${NPRMQAP-7_C}  NRCELL-4/NRPMQAP-7
${NPRMQAP-8_C}  NRCELL-4/NRPMQAP-8
${ENB_PATH}  MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].global_bts_id}
${lnrel_dist}  ${ENB_PATH}/LNCEL-5
${lnrel_para1}    administrativeState
*** Keywords ***
Get allmaxQuota and allminQuota
  [Arguments]  ${index_list}=${RG_ID}  ${id}=1
  @{allmaxQuota}  Create List
  @{allminQuota}  Create List
  FOR  ${i}  IN  @{index_list}
      ${maxQuota}  Get Parameter Value via SCF  parameter=maxQuota  dist_name=${GNB_PATH}/NRRESOURCEGROUP_PROFILE-${id}/NRRESOURCEGROUP-${i}
      ...  scf_file_path=${scf_file_path}  list_name=schedulerParams
      ${minQuota}  Get Parameter Value via SCF  parameter=minQuota  dist_name=${GNB_PATH}/NRRESOURCEGROUP_PROFILE-${id}/NRRESOURCEGROUP-${i}
      ...  scf_file_path=${scf_file_path}  list_name=schedulerParams
      Append To List  ${allmaxQuota}  ${maxQuota}
      Append To List  ${allminQuota}  ${minQuota}
  END
  [Return]  ${allmaxQuota}  ${allminQuota}

Calculate all Quota
  [Arguments]  ${allmaxQuota}  ${allminQuota}
  ${molecule}  Set Variable  0
  ${denominator}  Set Variable  0
  @{target_quota_list}  Create List
  ${len}  Get Length  ${allmaxQuota}
  FOR  ${i}  IN RANGE  ${len}
      ${maxQuota}  Set Variable  ${allmaxQuota}[${i}]
      ${minQuota}  Set Variable  ${allminQuota}[${i}]
      ${molecule}  Evaluate  ${molecule}+${minQuota}
      ${denominator_tmp}  Evaluate  ${maxQuota}-${minQuota}
      ${denominator}  Evaluate  ${denominator}+${denominator_tmp}
  END
  FOR  ${i}  IN RANGE  ${len}
      ${maxQuota}  Set Variable  ${allmaxQuota}[${i}]
      ${minQuota}  Set Variable  ${allminQuota}[${i}]
      ${target_quota}  Evaluate  ${minQuota}+(${maxQuota}-${minQuota})*(100-${molecule})/${denominator}
      Append To List  ${target_quota_list}  ${target_quota}
  END
  [Return]  ${target_quota_list}

Get Theoretical Throughput
    [Arguments]     ${cellid}=1  ${attach_mode}=5G_SA  ${ue_dl_layer}=4
    ${ue_ul_layer}  Set Variable If  '${attach_mode}'=='5G_NSA'  1  2
    ${ue_dl_layer}   convert to integer    ${ue_dl_layer}
    ${ue_ul_layer}   convert to integer    ${ue_ul_layer}
    ${theoretical_dl}    ${theoretical_ul}    throughput_computation.get_theoretical_throughput
    ...    scf_path=${scf_file_path}    cell_id=${cellid}    ue_dl_layer=${ue_dl_layer}
    ...    ue_ul_layer=${ue_ul_layer}
    [Return]  ${theoretical_dl}    ${theoretical_ul}

Get expected TP
  [Arguments]  ${dl_throughput}  ${ul_throughput}  ${quota}
    ${ul_throughput_tmp}  Evaluate  ${ul_throughput}*${quota}*0.01
  ${ul_throughput}  convert to integer  ${ul_throughput_tmp}
  ${expected_ul}  Catenate  SEPARATOR=  ${ul_throughput}  M
      ${dl_throughput_tmp}  Evaluate  ${dl_throughput}*${quota}*0.01
  ${dl_throughput}  convert to integer  ${dl_throughput_tmp}
  ${expected_dl}  Catenate  SEPARATOR=  ${dl_throughput}  M
  [Return]  ${expected_dl}    ${expected_ul}

Check Quota value in counter
    [Arguments]  ${counter_groups}=${None}  ${counter}=${None}  ${meas}=${M55910}
    ...  ${counter_object}=${NPRMQAP-3}
    ${len}  Get Length  ${counter_object}
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    FOR  ${i}  IN RANGE  ${len}
      ${value}    Get latest counter value  counter_id=${counter}  check_time=${counter_groups}
        ...  counter_full_path=CELLS/${counter_object}[${i}]/${meas}
      Run Keyword And Continue On Failure  should be true  ${value}>=${0}
    END

Check PRB value in counter
    [Arguments]  ${target_quota}  ${counter_groups}=${None}  ${counter}=${None}  ${meas}=${M55910}
    ...  ${counter_object}=${NPRMQAP-3}  ${check_PRB}=${True}
    Log to console  Check PRB value in counter
    ${len}  Get Length  ${counter_object}
    @{PRB_list}  Create List
    @{PRB_ratio_list}  Create List
    ${PRB_sum}  Set Variable  0
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    FOR  ${i}  IN RANGE  ${len}
      ${value}    Get latest counter value  counter_id=${counter}  check_time=${counter_groups}
        ...  counter_full_path=CELLS/${counter_object}[${i}]/${meas}
      Append To List  ${PRB_list}  ${value}
      ${PRB_sum}  Evaluate  ${PRB_sum}+${value}
    END
    FOR  ${i}  IN RANGE  ${len}
      ${PRB_ratio_target}  convert to integer  ${target_quota}[${i}]
      ${big_value}  Evaluate  ${PRB_ratio_target}+${diff}
      ${small_value}  Evaluate  ${PRB_ratio_target}-${diff}
      ${PRB_ratio_tmp}  Evaluate  ${PRB_list}[${i}]/${PRB_sum}*100
      Append To List  ${PRB_ratio_list}  ${PRB_ratio_tmp}
      ${PRB_ratio}  convert to integer  ${PRB_ratio_tmp}
      Run keyword If  ${check_PRB}  Run Keyword And Continue On Failure  should be true
      ...  ${PRB_ratio}>=${small_value} and ${PRB_ratio}<=${big_value}
    END
    [Return]  ${PRB_ratio_list}

Stop and start traffic
    [Arguments]    ${ul_tp}=100M
    ...    ${dl_tp}=300M    ${iperf_type}=via_command
    ...    ${ul_duration}=12000    ${dl_duration}=12000    ${ue_index}=${0}  ${ue_type}=${ue_type_${ue_index}}
    ...  ${ul_port}=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    ...  ${dl_port}=${tl.ues[${ue_index}].iperf_details.port}  ${stop_traffic}=${True}
    Log To Console  UE${ue_index} Stop and start traffic
    ${iperf_type}  Set Variable If  '${ue_type}'=='huawei'  via_app  via_command
    Run Keyword If  ${stop_traffic}  Dettach UE and Stop traffic  ue_index=${ue_index}  Dettach=${False}
    ...  iperf_port=${ue${ue_index}_qci7_port}
    Run Keyword If    '${iperf_type}'=='via_command'    UE Start UL Traffic    throughput=${ul_tp}    ul_time=${ul_duration}
    ...    ul_port=${ul_port}  ue_index=${ue_index}
    ...    ELSE    power_ue.Start traffic   ue_type=${ue_type}   direction=ul   throughput=${ul_tp}    duration=${ul_duration}
    ...    ue_index=${ue_index}  iperf_port=${ul_port}
    UE Start DL Traffic    throughput=${dl_tp}    dl_time=${dl_duration}    dl_port=${dl_port}
    ...    ue_index=${ue_index}

DRB without configured resource group
  [Arguments]  ${nrcell_id}=${cell_id_1}  ${attach_mode}=5G_SA  ${index_list}=${RG_ID}  ${check_object}=${NRRESOURCEGROUP}  ${L3_call}=${True}
  ...  ${deattach}=${True}  ${abnormal_object}=${NRRESOURCEGROUP-3}  ${check_id}=${NRRESOURCEGROUP-2}  ${stop_traffic}=${False}  ${abnormal}=${True}
  ...  ${check_M55910}=${True}  ${small_tp}=${False}  ${GBR}=${None}
  ${scf_file_path}  Get SCF From BTS
  Set Test Variable  ${scf_file_path}
  ${allmaxQuota}  ${allminQuota}  Get allmaxQuota and allminQuota  index_list=${index_list}
  Set Test Variable  ${allmaxQuota}
  Set Test Variable  ${allminQuota}
  ${target_quota_list}  Calculate all Quota  allmaxQuota=${allmaxQuota}  allminQuota=${allminQuota}
  Set Test Variable  ${target_quota_list}
  ${target_quota1}  Set Variable  ${target_quota_list}[0]
  ${target_quota2}  Set Variable  ${target_quota_list}[1]
  # ${dl_throughput}  Set Variable  ${DL_Peak_TP}
  # ${ul_throughput}  Set Variable  ${UL_Peak_TP}
  ${dl_throughput}  ${ul_throughput}  Get Theoretical Throughput  cellid=${nrcell_id}  attach_mode=${attach_mode}
  ${expected_dl1}    ${expected_ul1}  Get expected TP  dl_throughput=${dl_throughput}  ul_throughput=${ul_throughput}
  ...  quota=${target_quota1}
  ${expected_dl2}    ${expected_ul2}  Get expected TP  dl_throughput=${dl_throughput}  ul_throughput=${ul_throughput}
  ...  quota=${target_quota2}
  ${UL_traffic}  Set Variable If  '${attach_mode}'=='5G_NSA'  ${False}  ${True}
  Run Keyword If  ${L3_call}  Attach real UE  ue_index=0  ul_port=${ue0_qci7_port}  dl_port=${ue0_qci7_port}  ul_tp=${expected_ul1}
    ...    dl_tp=${expected_dl1}  global_cell_id=${nrcell_id}  UL_traffic=${UL_traffic}
  Run Keyword If  '${GBR}'=='True'  Stop and start traffic  ue_index=0  ul_port=${ue0_qci2_port}
    ...  dl_port=${ue0_qci2_port}  ul_tp=20M  dl_tp=20M  stop_traffic=${False}
  Run Keyword If  '${GBR}'=='False'  Dettach UE and Stop traffic  ue_index=${0}  Dettach=${False}
  ...  iperf_port=${ue0_qci2_port}
  Run keyword If  ${small_tp} and ${L3_call}  Attach real UE  ue_index=1  ul_port=${ue1_qci7_port}  dl_port=${ue1_qci7_port}  ul_tp=${small_tp_value}
    ...    dl_tp=${small_tp_value}  global_cell_id=${nrcell_id}  UL_traffic=${False}
    ...  ELSE IF  ${L3_call}  Attach real UE  ue_index=1  ul_port=${ue1_qci7_port}  dl_port=${ue1_qci7_port}  ul_tp=${expected_ul2}
    ...    dl_tp=${expected_dl2}  global_cell_id=${nrcell_id}  UL_traffic=${UL_traffic}
  Run Keyword If  ${stop_traffic}  Stop and start traffic  ue_index=1  ul_port=${ue1_qci7_port}
    ...  dl_port=${ue1_qci7_port}  ul_tp=${expected_ul2}  dl_tp=${expected_dl2}
  ${counter_groups}  Run Keyword If  ${check_M55910}  Check M55910  check_object=${check_object}  nrcell_id=${nrcell_id}
  ...  deattach=${deattach}  abnormal_object=${abnormal_object}  check_id=${check_id}  abnormal=${abnormal}  UL_check=${UL_traffic}
  [Return]  ${counter_groups}


Check M55910
  [Arguments]  ${nrcell_id}=${cell_id_1}  ${check_object}=${NRRESOURCEGROUP}  ${UL_check}=${True}
  ...  ${deattach}=${True}  ${abnormal_object}=${NRRESOURCEGROUP-3}  ${check_id}=${NRRESOURCEGROUP-2}  ${abnormal}=${True}

#  Wait for one counter period
  ${counter_groups}  Get Check time  NPRMQAP-id=${check_id}  counter=M55910C00001  meas=${M55910}
  Check PRB value in counter  target_quota=${target_quota_list}  counter_groups=${counter_groups}  counter=M55910C00001
    ...  counter_object=${check_object}
  Run Keyword And Continue On Failure  Run keyword If  ${abnormal}  Check Counter normal or abnormal  counter=${NCUPNRG_counter}
  ...  flag=abnormal  counter_object=${abnormal_object}  meas=${M55910}  counter_groups=${counter_groups}
  ...  ELSE  Check No Counter value  counter=${NCUPNRG_counter}
  ...  counter_object=${abnormal_object}  meas=${M55910}  counter_groups=${counter_groups}
    Check Quota value in counter  counter_groups=${counter_groups}  counter=M55910C00002
    ...  counter_object=${check_object}
    Run Keyword And Continue On Failure  Verify attach and Check Throughput  5G_check=False  global_cell_id=${nrcell_id}
    ...  UL_check=${UL_check}
    [Teardown]  Run Keyword If  ${deattach}  Detach all UE
    [Return]  ${counter_groups}

DRB without configured resource group CB008828 enabled
  ${scf_file_path}  Get SCF From BTS
  Set Test Variable  ${scf_file_path}
  Modify parameter in objects  value=SNSSAI-2  parameter=resourceDN  dist_name=${GNB_PATH}/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1
    ...  list_name=nrResourceList  scf_file_path=${scf_file_path}
  Modify parameter in objects  value=SNSSAI-1991  parameter=resourceDN  dist_name=${GNB_PATH}/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2
    ...  list_name=nrResourceList  scf_file_path=${scf_file_path}
  DRB without configured resource group


Default resource group online modification
  ${scf_file_path}  Get SCF From BTS
  Set Test Variable  ${scf_file_path}
  ${exist_NRRESOURCEGROUP22}  Run Keyword And Return Status  Get Parameter Value via SCF  parameter=maxQuota
  ...  dist_name=${GNB_PATH}/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-22
  ...  list_name=schedulerParams  scf_file_path=${scf_file_path}
  Run Keyword If  ${exist_NRRESOURCEGROUP22}  scf.Activate or Deactivate feature    delta_file=${delta_delete_NRRESOURCEGROUP22}  timeout=600
  Connect to gnb coam via ssl
  DRB without configured resource group  deattach=${False}  index_list=${RG_ID_15}  check_object=@{NRRESOURCEGROUP_15}  check_id=${NRRESOURCEGROUP-4}
  Add One NRRESOURCEGROUP  addition_id=22
  scf.Activate or Deactivate feature    delta_file=${delta_add_NRRESOURCEGROUP22}  timeout=600
  ${index_list_1}  Create List  1  22
  ${check_object_1}  Create List  ${NRRESOURCEGROUP-1}  ${NRRESOURCEGROUP-22}
  Connect to gnb coam via ssl
  DRB without configured resource group  index_list=${index_list_1}  check_object=${check_object_1}  L3_call=${False}
  ...  abnormal_object=${NRRESOURCEGROUP-4}  check_id=${NRRESOURCEGROUP-22}  deattach=${False}
  DRB without configured resource group  index_list=${index_list_1}  check_object=${check_object_1}  L3_call=${False}
  ...  abnormal_object=${NRRESOURCEGROUP-4}  check_id=${NRRESOURCEGROUP-22}  stop_traffic=${True}
  [Teardown]  Run keywords  Modify parameter in objects  value=4  parameter=nrResourceGroupId  dist_name=${GNB_PATH}/NRRESOURCEGROUP_PROFILE-1
    ...  list_name=defaultRgSaList  scf_file_path=${scf_file_path}
    ...  AND  Detach all UE


Default resource group online modification CB008828 disabled
    scf.scf uploading and commissioning  Log_directory=${CURDIR}/config/scf_files  SCF_Filename=CB008828_disabled_scf.xml
    Connect to gnb coam via ssl
    ${scf_file_path}  Get SCF From BTS
    Set Test Variable  ${scf_file_path}
    Wait Until Keyword Succeeds  70x  10s  Cell Should Be Unlocked  cell_group_idx=${${cell_id_1}}  cell_idx=${${cell_id_1}}
    DRB without configured resource group  deattach=${False}  index_list=${RG_ID_15}  check_object=@{NRRESOURCEGROUP_15}
    ...  check_id=${NRRESOURCEGROUP-4}
    ${index_list_1}  Create List  1  5
    ${check_object_1}  Create List  ${NRRESOURCEGROUP-1}  ${NRRESOURCEGROUP-5}
    Modify parameter in objects  value=5  parameter=nrResourceGroupId  dist_name=${GNB_PATH}/NRRESOURCEGROUP_PROFILE-1
    ...  list_name=defaultRgSaList  scf_file_path=${scf_file_path}
    DRB without configured resource group  index_list=${index_list_1}  check_object=${check_object_1}  L3_call=${False}
     ...  abnormal_object=${NRRESOURCEGROUP-4}  check_id=${NRRESOURCEGROUP-5}  deattach=${False}
    DRB without configured resource group  index_list=${index_list_1}  check_object=${check_object_1}  L3_call=${False}
     ...  abnormal_object=${NRRESOURCEGROUP-4}  check_id=${NRRESOURCEGROUP-5}  stop_traffic=${True}
    [Teardown]  Run keywords  Detach all UE  AND  CI_interface.Common Suite Setup  AND  Wait For Expect Fault To Disappear  faultId=4592  timeout=120

Detach all UE
  Run Keyword And Ignore Error  Dettach UE and Stop traffic  ue_index=${0}
    ...  iperf_port=${ue0_qci7_port}  ue_type=${ue_type_0}
  Run Keyword And Ignore Error   Dettach UE and Stop traffic  ue_index=${1}  iperf_port=${ue1_qci7_port}  ue_type=${ue_type_1}

Wrong configuration of quotas for a resource group
  ${scf_file_path}  Get SCF From BTS
  Set Test Variable  ${scf_file_path}
  ${delta_add_two}  Collect Delta of Adding Two NRRESOURCEGROUPs
  Check Plan validation result  delta_add=${delta_add_two}
  Modify json file  json_file=${delta_delete_one_NRRESOURCEGROUP}  old_string=-ID  new_string=-24
  ${delta_add_one}  Collect Delta of Adding One NRRESOURCEGROUP  addition_id=24  maxQuota=40  minQuota=50
  Check Plan validation result  mo_id=24  delta_delete=${delta_delete_one_NRRESOURCEGROUP}  delta_add=${delta_add_one}
  ...  msg=minQuota
  [Teardown]  Run keywords  Modify json file  json_file=${delta_delete_one_NRRESOURCEGROUP}  old_string=-24  new_string=-ID
  ...  AND  Add One NRRESOURCEGROUP  addition_id=21
  ...  AND  Add One NRRESOURCEGROUP  addition_id=24
  ...  AND  Add One NRRESOURCEGROUP  addition_id=23

Check Plan validation result
  [Arguments]  ${mo_id}=21  ${delta_delete}=${delta_delete_two_NRRESOURCEGROUP}  ${delta_add}=${delta_add_two_NRRESOURCEGROUP}
  ...  ${msg}=The sum of NRRESOURCEGROUP.schedulerParams.minQuota
  ${exist_NRRESOURCEGROUP}  Run Keyword And Return Status  Get Parameter Value via SCF  parameter=maxQuota
  ...  dist_name=${GNB_PATH}/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-${mo_id}
  ...  list_name=schedulerParams  scf_file_path=${scf_file_path}
  Run Keyword If  ${exist_NRRESOURCEGROUP}  Run keywords  scf.Activate or Deactivate feature    delta_file=${delta_delete}  timeout=600
  ...  AND  Connect to gnb coam via ssl
  ${result}  coam_parameter.perform_scf_delta_commission  delta_file=${delta_add}  timeout=600
      ...  skip_parameter_relation_errors=true  should_activate=${false}  connection=GNB_OAM
  # ${status}  run keyword and return status  Should Contain Any  ${stream}  SBTS24R3
  ${feedback}  Convert To String
  ...  ${result['validationResult']['pdlValidationResult']['logs']['relationErrors'][0]['feedback']}
  # ...  ELSE  Convert To String  ${result['validationResult']['pdlValidationResult']['logs']['relationErrors'][0]['error']['feedback']}
  run keyword and continue on failure  Run keywords  Should Be Equal As Strings    ${result['validationResult']['pdlValidationResult']['status']}
  ...  FAIL
    ...        msg=Commissioned without error exists, pdl validation result is in OK status.    ignore_case=${True}
  ...  AND  Should Contain  ${feedback}  ${msg}  ignore_case=True

Existing resource group is removed CB008828 enabled
    ${scf_file_path}  Get SCF From BTS
    Set Test Variable  ${scf_file_path}
    Modify parameter in objects  value=4  parameter=nrResourceGroupId  dist_name=${GNB_PATH}/NRRESOURCEGROUP_PROFILE-1
    ...  list_name=defaultRgSaList  scf_file_path=${scf_file_path}
    Modify parameter in objects  value=SNSSAI-1991  parameter=resourceDN  dist_name=${GNB_PATH}/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2
    ...  list_name=nrResourceList  scf_file_path=${scf_file_path}
    Modify parameter in objects  value=SNSSAI-1  parameter=resourceDN  dist_name=${GNB_PATH}/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1
    ...  list_name=nrResourceList  scf_file_path=${scf_file_path}
    DRB without configured resource group  index_list=${RG_ID_26}  check_object=@{NRRESOURCEGROUP_12}  check_id=${NRRESOURCEGROUP-2}
    ...  deattach=${False}
    Modify common json file and activate  json_file=${delta_delete_one_NRRESOURCEGROUP}  old_string=-ID  new_string=-2
    Connect to gnb coam via ssl
    DRB without configured resource group  index_list=${RG_ID_15}  check_object=@{NRRESOURCEGROUP_15}  check_id=${NRRESOURCEGROUP-4}
    ...  abnormal_object=${NRRESOURCEGROUP-2}  L3_call=${False}  deattach=${False}  abnormal=${False}
    DRB without configured resource group  index_list=${RG_ID_15}  check_object=@{NRRESOURCEGROUP_15}  check_id=${NRRESOURCEGROUP-4}
    ...  abnormal_object=${NRRESOURCEGROUP-2}  L3_call=${False}  stop_traffic=${True}  abnormal=${False}
    [Teardown]  Run keywords  Detach all UE
    ...  AND  Add One NRRESOURCEGROUP  addition_id=2

Resource group online modification
    ${scf_file_path}  Get SCF From BTS
    Set Test Variable  ${scf_file_path}
    Modify parameter in objects  value=4  parameter=nrResourceGroupId  dist_name=${GNB_PATH}/NRRESOURCEGROUP_PROFILE-1
    ...  list_name=defaultRgSaList  scf_file_path=${scf_file_path}
    Modify parameter in objects  value=SNSSAI-1992  parameter=resourceDN  dist_name=${GNB_PATH}/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2
    ...  list_name=nrResourceList  scf_file_path=${scf_file_path}
    Modify parameter in objects  value=SNSSAI-1  parameter=resourceDN  dist_name=${GNB_PATH}/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1
    ...  list_name=nrResourceList  scf_file_path=${scf_file_path}
    Modify parameter in objects  value=SNSSAI-5  parameter=resourceDN  dist_name=${GNB_PATH}/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-5
    ...  list_name=nrResourceList  scf_file_path=${scf_file_path}
    DRB without configured resource group  deattach=${False}  index_list=${RG_ID_15}  check_object=@{NRRESOURCEGROUP_15}
    ...  check_id=${NRRESOURCEGROUP-4}
    Modify parameter in objects  value=SNSSAI-1991  parameter=resourceDN  dist_name=${GNB_PATH}/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2
    ...  list_name=nrResourceList  scf_file_path=${scf_file_path}
    DRB without configured resource group  L3_call=${False}  index_list=${RG_ID_15}  check_object=@{NRRESOURCEGROUP_15}
    ...  check_id=${NRRESOURCEGROUP-4}  abnormal_object=${NRRESOURCEGROUP-2}
    DRB without configured resource group  index_list=${RG_ID_26}  check_object=@{NRRESOURCEGROUP_12}  check_id=${NRRESOURCEGROUP-2}
    ...  deattach=${False}  abnormal_object=${NRRESOURCEGROUP-4}
    Modify parameter in objects  value=SNSSAI-1992  parameter=resourceDN  dist_name=${GNB_PATH}/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2
    ...  list_name=nrResourceList  scf_file_path=${scf_file_path}
    Modify parameter in objects  value=SNSSAI-1991  parameter=resourceDN  dist_name=${GNB_PATH}/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-5
    ...  list_name=nrResourceList  scf_file_path=${scf_file_path}
    DRB without configured resource group  index_list=${RG_ID_26}  check_object=@{NRRESOURCEGROUP_12}  check_id=${NRRESOURCEGROUP-2}
    ...  L3_call=${False}  abnormal_object=${NRRESOURCEGROUP-4}
    ${index_list_1}  Create List  1  5
    ${check_object_1}  Create List  ${NRRESOURCEGROUP-1}  ${NRRESOURCEGROUP-5}
    DRB without configured resource group  index_list=${index_list_1}  check_object=${check_object_1}
     ...  abnormal_object=${NRRESOURCEGROUP-2}  check_id=${NRRESOURCEGROUP-5}
    [Teardown]  Run keywords  Detach all UE
      ...  AND  coam_parameter.perform_single_parameter_update  value=SNSSAI-5  parameter=resourceDN  timeout=90
      ...  dist_name=${GNB_PATH}/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-5  list_name=nrResourceList  connection=GNB_OAM

DRB with configured resource group for multi cell
  [Arguments]  ${nrcell_id}=${Pcell_id}  ${attach_mode}=5G_SA  ${index_list}=${RG_ID_26}  ${check_object}=${NRRESOURCEGROUP_26}  ${L3_call}=${True}
  ...  ${deattach}=${True}  ${check_id}=${NRRESOURCEGROUPS-2}  ${nrcell_id_2}=${Scell_id}  ${check_object_ca}=${NRRESOURCEGROUP_26_ca}
  ${scf_file_path}  Get SCF From BTS
  Set Test Variable  ${scf_file_path}
  ${allmaxQuota}  ${allminQuota}  Get allmaxQuota and allminQuota  index_list=${index_list}
  ${target_quota_list}  Calculate all Quota  allmaxQuota=${allmaxQuota}  allminQuota=${allminQuota}
  ${target_quota1}  Set Variable  ${target_quota_list}[0]
  ${target_quota2}  Set Variable  ${target_quota_list}[1]
  ${dl_throughput1}  ${ul_throughput1}  Get Theoretical Throughput  cellid=${nrcell_id}  attach_mode=${attach_mode}
  ...  ue_dl_layer=2
  ${dl_throughput2}  ${ul_throughput2}  Get Theoretical Throughput  cellid=${nrcell_id_2}  attach_mode=${attach_mode}
  ${dl_throughput}  Evaluate  ${dl_throughput1}+${dl_throughput2}
  ${ul_throughput}  Evaluate  ${ul_throughput1}+${ul_throughput2}
  ${expected_dl1}    ${expected_ul1}  Get expected TP  dl_throughput=${dl_throughput}  ul_throughput=${ul_throughput}
  ...  quota=${target_quota1}
  ${expected_dl2}    ${expected_ul2}  Get expected TP  dl_throughput=${dl_throughput}  ul_throughput=${ul_throughput}
  ...  quota=${target_quota2}
  Run Keyword If  ${L3_call}  Attach real UE  ue_index=0  ul_port=${ue0_qci7_port}  dl_port=${ue0_qci7_port}  ul_tp=${expected_ul1}
    ...    dl_tp=${expected_dl1}  global_cell_id=${nrcell_id}    UL_traffic=${False}
  Run Keyword If  ${L3_call}  Attach real UE  ue_index=1  ul_port=${ue1_qci7_port}  dl_port=${ue1_qci7_port}  ul_tp=${expected_ul2}
    ...    dl_tp=${expected_dl2}  global_cell_id=${nrcell_id}    UL_traffic=${False}
  Wait for one counter period
  ${counter_groups}  Get Check time  NPRMQAP-id=${check_id}  counter=M55910C00001  meas=${M55910}
  Check PRB value in counter  target_quota=${target_quota_list}  counter_groups=${counter_groups}  counter=M55910C00001
    ...  counter_object=${check_object}
  Check Quota value in counter  counter_groups=${counter_groups}  counter=M55910C00002
  ...  counter_object=${check_object}
  Check PRB value in counter  target_quota=${target_quota_list}  counter_groups=${counter_groups}  counter=M55910C00001
  ...  counter_object=${check_object_ca}
  Check Quota value in counter  counter_groups=${counter_groups}  counter=M55910C00002
    ...  counter_object=${check_object_ca}
  Run Keyword And Ignore Error  Verify attach and Check Throughput  5G_check=False  global_cell_id=${nrcell_id}  UL_check=${False}
  [Teardown]  Run Keyword If  ${deattach}  Detach all UE

Intra gNB TDD FDD CA
  attenuator.setup_attenuator    attenuator=${tl.attenuator[1]}    alias=HBTE
  Modify attenuator value by port   modify_value=${0}  port=0    ru_id=1
  Modify attenuator value by port   modify_value=${127}  port=1    ru_id=1
  attenuator.setup_attenuator    attenuator=${tl.attenuator[0]}    alias=HBTE
  Modify attenuator value by port   modify_value=${0}  port=0    ru_id=0
  Modify attenuator value by port   modify_value=${127}  port=1    ru_id=0
  Modify common json file and activate  json_file=${delta_modify_two_NRRESOURCEGROUP}  old_string="20"  new_string="10"
  Connect to gnb coam via ssl
  ${scf_file_path}  Get SCF From BTS
  Set Test Variable  ${scf_file_path}
  Modify parameter in objects  value=barred  parameter=cellBarred  dist_name=${GNB_PATH}/NRCELL-${Scell_id}
    ...  scf_file_path=${scf_file_path}
  DRB with configured resource group for multi cell  deattach=${False}
  Modify common json file and activate  json_file=${delta_modify_two_NRRESOURCEGROUP}  old_string="10"  new_string="20"
  Connect to gnb coam via ssl
  DRB with configured resource group for multi cell  L3_call=${False}
  [Teardown]  Run Keywords  Detach all UE
  ...  AND  Recover PA value
  ...  AND  Modify common json file and activate  json_file=${delta_modify_two_NRRESOURCEGROUP}  old_string="20"  new_string="10"
  ...  AND  Connect to gnb coam via ssl
  ...  AND  coam_parameter.perform_single_parameter_update  value=notBarred  parameter=cellBarred  dist_name=${GNB_PATH}/NRCELL-${Scell_id}
    ...  connection=GNB_OAM  timeout=90

Interaction between Micro DTX scheduler with Slice Aware Scheduler
  scf.Activate or Deactivate feature    delta_file=${delta_enable_Micro_DTX}  timeout=600
  Connect to gnb coam via ssl
  ${scf_file_path}  Get SCF From BTS
  Set Test Variable  ${scf_file_path}
  DRB without configured resource group  deattach=${False}  check_M55910=${False}  small_tp=${True}
  Wait for one counter period
  ${check_time}  Get Check time  NPRMQAP-id=${CELL_ID}  counter=M55351C00002  meas=${M55351}
  Check Counter normal or abnormal  counter=${NCELA_counter}  flag=normal  counter_object=${CELL_ID}
    ...  counter_groups=${check_time}  meas=${M55308}
  Check Counter normal or abnormal  counter=${DBWP_counter_1}  flag=normal  counter_object=${CELL_ID}
    ...  counter_groups=${check_time}  meas=${M55351}
  Check Counter normal or abnormal  counter=${DBWP_counter_2}  flag=normal  counter_object=${CELL_ID}
    ...  counter_groups=${check_time}  meas=${M55351}
  Check Counter normal or abnormal  counter=${NCUPNRG_counter}
  ...  flag=normal  counter_object=${NRRESOURCEGROUP-1}  meas=${M55910}  counter_groups=${check_time}
  Check Counter normal or abnormal  counter=${NCUPNRG_counter}
  ...  flag=normal  counter_object=${NRRESOURCEGROUP-4}  meas=${M55910}  counter_groups=${check_time}
  ${check_time}  DRB without configured resource group  L3_call=${False}  stop_traffic=${True}  index_list=${RG_ID_15}
  ...  check_object=@{NRRESOURCEGROUP_15}  check_id=${NRRESOURCEGROUP-4}  abnormal_object=${NRRESOURCEGROUP-2}
  Check Counter normal or abnormal  counter=${DBWP_counter_1}  flag=abnormal  counter_object=${CELL_ID}
    ...  counter_groups=${check_time}  meas=${M55351}
  Check Counter normal or abnormal  counter=${DBWP_counter_2}  flag=normal  counter_object=${CELL_ID}
    ...  counter_groups=${check_time}  meas=${M55351}
  [Teardown]  Run Keywords  Detach all UE
    ...  AND  scf.Activate or Deactivate feature    delta_file=${delta_disable_Micro_DTX}  timeout=600

different quotas for each resource group
  wait until keyword succeeds  3x  5s  Switch APN  ui_version=one ui 4.0  new_APN=mdrb  ue_index=${0}
  ${scf_file_path}  Get SCF From BTS
  Set Test Variable  ${scf_file_path}
  Modify parameter in objects  value=SNSSAI-1  parameter=resourceDN  dist_name=${GNB_PATH}/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1
    ...  list_name=nrResourceList  scf_file_path=${scf_file_path}
  Modify parameter in objects  value=SNSSAI-1991  parameter=resourceDN  dist_name=${GNB_PATH}/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2
    ...  list_name=nrResourceList  scf_file_path=${scf_file_path}
  Modify parameter in objects  value=5min  parameter=miNrCellUtilization  dist_name=${GNB_PATH}/NRPMRNL-1  scf_file_path=${scf_file_path}
    Modify common json file and activate  json_file=${delta_modify_two_NRRESOURCEGROUP}  old_string="10"  new_string="20"
    Connect to gnb coam via ssl
    ${check_time}  DRB without configured resource group  index_list=${RG_ID_26}  check_object=@{NRRESOURCEGROUP_12}  check_id=${NRRESOURCEGROUP-2}
    ...  deattach=${False}  GBR=${True}
    Check Counter normal or abnormal  counter=${PTHPQ_counter}  flag=normal  counter_object=${NPRMQAP-7_C}
    ...  counter_groups=${check_time}  meas=${M55363}
    Check Counter normal or abnormal  counter=${PTHPQ_counter}  flag=normal  counter_object=${NPRMQAP-8_C}
    ...  counter_groups=${check_time}  meas=${M55363}
    ${check_time}  DRB without configured resource group  index_list=${RG_ID_26}  check_object=@{NRRESOURCEGROUP_12}  check_id=${NRRESOURCEGROUP-2}
    ...  deattach=${False}  L3_call=${False}  GBR=${False}
    Check Counter normal or abnormal  counter=${PTHPQ_counter}  flag=normal  counter_object=${NPRMQAP-7_C}
    ...  counter_groups=${check_time}  meas=${M55363}
    Check Counter normal or abnormal  counter=${PTHPQ_counter}  flag=normal  counter_object=${NPRMQAP-8_C}
    ...  counter_groups=${check_time}  meas=${M55363}
    Modify common json file and activate  json_file=${delta_modify_two_NRRESOURCEGROUP}  old_string="20"  new_string="10"
    Connect to gnb coam via ssl
    ${check_time}  DRB without configured resource group  index_list=${RG_ID_26}  check_object=@{NRRESOURCEGROUP_12}  check_id=${NRRESOURCEGROUP-2}
    ...  deattach=${False}  GBR=${True}  L3_call=${False}
    Check Counter normal or abnormal  counter=${PTHPQ_counter}  flag=normal  counter_object=${NPRMQAP-7_C}
    ...  counter_groups=${check_time}  meas=${M55363}
    Check Counter normal or abnormal  counter=${PTHPQ_counter}  flag=normal  counter_object=${NPRMQAP-8_C}
    ...  counter_groups=${check_time}  meas=${M55363}
    ${check_time}  DRB without configured resource group  index_list=${RG_ID_26}  check_object=@{NRRESOURCEGROUP_12}  check_id=${NRRESOURCEGROUP-2}
    ...  deattach=${False}  L3_call=${False}  GBR=${False}
    Check Counter normal or abnormal  counter=${PTHPQ_counter}  flag=normal  counter_object=${NPRMQAP-7_C}
    ...  counter_groups=${check_time}  meas=${M55363}
    Check Counter normal or abnormal  counter=${PTHPQ_counter}  flag=normal  counter_object=${NPRMQAP-8_C}
    ...  counter_groups=${check_time}  meas=${M55363}
  Check No Counter value  counter=${NL1SL_counter}
  ...  counter_object=${NPRMQAP-8_C}  counter_groups=${check_time}  meas=${M55359}
  ${contain_release}  Run Keyword And Return Status  Should Not Contain  ${stream}  24R2
  Run Keyword If  ${contain_release}  Check Counter normal or abnormal  counter=${NCELA_counter_4}  flag=normal  counter_object=${CELL_ID}
    ...  counter_groups=${check_time}  meas=${M55308}
  ...  ELSE  Check Counter normal or abnormal  counter=${NCELA_counter_4_r2}  flag=normal  counter_object=${CELL_ID}
    ...  counter_groups=${check_time}  meas=${M55308}
    [Teardown]  Run Keywords  Detach all UE
    ...  AND  wait until keyword succeeds  3x  5s  Switch APN  ui_version=one ui 4.0  new_APN=dxdata2  ue_index=${0}
    ...  AND  Modify common json file and activate  json_file=${delta_modify_two_NRRESOURCEGROUP}  old_string="20"  new_string="10"

Not_configured_RG_for_NSA_CB008746_disabled_CB008828_enabled
  attenuator.setup_attenuator    attenuator=${tl.attenuator[1]}    alias=HBTE
  Modify attenuator value by port   modify_value=${0}  port=1    ru_id=1
  Connect and Modify the parameter on enblte  dist_name=${lnrel_dist}  parameter=${lnrel_para1}   value=unlocked
  scf.Activate or Deactivate feature    delta_file=${delta_NSA_CB008746_disabled}  timeout=600
  AlarmWatchdog.add_allow_alarms    fault_id=7107
  Connect to gnb coam via ssl
  DRB without configured resource group  attach_mode=5G_NSA  check_object=${NRRESOURCEGROUP_19}  abnormal_object=${NRRESOURCEGROUP-1_19}
  ...  check_id=${NRRESOURCEGROUP-2_19}  nrcell_id=${cell_id_2}
  [Teardown]  Run Keywords  CI_interface.Common Suite Setup
  ...  AND  attenuator.setup_attenuator    attenuator=${tl.attenuator[1]}    alias=HBTE
  ...  AND  Modify attenuator value by port   modify_value=${127}  port=1    ru_id=1
  ...  AND    Wait Until Keyword Succeeds    3x    30 sec  Connect and Modify the parameter on enblte
  ...  dist_name=${lnrel_dist}  parameter=${lnrel_para1}   value=locked

Suite Case C Setup
  Suite Case Setup
  update swconfig
  CI_interface.Common Suite Setup
  Run Keyword And Ignore Error  Connect and Modify the parameter on enblte
  ...  dist_name=${lnrel_dist}  parameter=${lnrel_para1}   value=locked
  run keyword and ignore error  Recover PA value

Recover PA value
  attenuator.setup_attenuator    attenuator=${tl.attenuator[1]}    alias=HBTE
  Modify attenuator value by port   modify_value=${127}  port=0    ru_id=1
  Modify attenuator value by port   modify_value=${127}  port=1    ru_id=1
  attenuator.setup_attenuator    attenuator=${tl.attenuator[0]}    alias=HBTE
  Modify attenuator value by port   modify_value=${127}  port=0    ru_id=0
  Modify attenuator value by port   modify_value=${0}  port=1    ru_id=0

Add One NRRESOURCEGROUP
    [Arguments]  ${addition_id}=2    ${connection}=GNB_OAM     ${should_activate}=${True}
    ...          ${skip_parameter_relation_errors}=True
    Connect to gnb coam via ssl
    Log to console          Add One NRRESOURCEGROUP.
    ${delta}                Collect Delta of Adding One NRRESOURCEGROUP       addition_id=${addition_id}
    taf.sbts.oam.coam.admin.Perform Delta Recommissioning       connection=${connection}       delta_file=${delta}
    ...                     should_activate=${should_activate}
    ...                     skip_parameter_relation_errors=${skip_parameter_relation_errors}

Collect Delta of Adding Two NRRESOURCEGROUPs
    Log to console          Collect delta of Two NRRESOURCEGROUPs.
    Initialise delta store
    ${minQuota}  Set Variable  50
    ${nrresourcegroup_path}       Set variable
    ...    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP
    ${result}    run keyword and return status    should contain any    ${stream}    24R3    25R1    25R2
    FOR   ${id}   IN    21    23
        add managed object and parameter to delta  ${nrresourcegroup_path}-${id}  userLabel=add
        Add List Parameters To Delta  ${nrresourcegroup_path}-${id}        nrResourceList      resourceDN=SNSSAI-${id}
        Add List Parameters To Delta  ${nrresourcegroup_path}-${id}        schedulerParams     maxQuota=100
        ...     minQuota=${minQuota}
        ${minQuota}  Evaluate  ${minQuota}+10
        run keyword if  not ${result}    Add param to delta  ${nrresourcegroup_path}-${id}
        ...  allowRegularSrAboveMaxQuota    value=false
        run keyword if  not ${result}    Add List Parameters To Delta  ${nrresourcegroup_path}-${id}
        ...  srRacParams    maxQuota=100    minQuota=0
    END
    ${delta}                Collect delta store
    [Return]  ${delta}

Collect Delta of Adding One NRRESOURCEGROUP
    [Arguments]  ${addition_id}=2  ${maxQuota}=100  ${minQuota}=10
    Log to console          Collect Delta of Adding One NRRESOURCEGROUP.
    Initialise delta store
    ${nrresourcegroup_path}       Set variable
    ...    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-${addition_id}
    add managed object and parameter to delta  ${nrresourcegroup_path}  userLabel=add
    Add List Parameters To Delta  ${nrresourcegroup_path}        nrResourceList      resourceDN=SNSSAI-${addition_id}
    Add List Parameters To Delta  ${nrresourcegroup_path}        schedulerParams     maxQuota=${maxQuota}
    ...     minQuota=${minQuota}
    ${result}    run keyword and return status    should contain any    ${stream}    24R3    25R1    25R2
    run keyword if  not ${result}    Add param to delta  ${nrresourcegroup_path}  allowRegularSrAboveMaxQuota
    ...    value=false
    run keyword if  not ${result}    Add List Parameters To Delta  ${nrresourcegroup_path}  srRacParams    maxQuota=100
    ...    minQuota=0
    ${delta}                Collect delta store
    [Return]  ${delta}

