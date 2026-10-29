*** Settings ***

Library  taf.selenium.sbts  WITH NAME  selenium_coam
Library           OperatingSystem
Library           Collections
Library           String
Library           BuiltIn
Library           taf.transport.ssh    WITH NAME    csn
Library            random
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/scf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/android_ue.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/admin_sbts.robot
Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/siso_common_keywords.robot
Resource  testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008158/Resources/CB008158_common_keywords.robot
Resource  testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008828/resources/common_keywords.robot
Library    taf.hw.rf_attenuator    WITH NAME    attenuator


Documentation
...    author: Liqin Yang
...    contact: liqin.yang@nokia-sbell.com
...    Group: HGZ_SG5

*** Variables ***
${MRBTS_ID}                           ${tl.gnbs[0].instance_id}
${NRBTS_ID}    ${tl.gnbs[0].global_bts_id}
${GNB_PATH}    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
${dist_name}    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1

${MRBTS_ID_1}                           ${tl.gnbs[1].instance_id}
${NRBTS_ID_1}    ${tl.gnbs[1].global_bts_id}
${GNB_PATH_1}    MRBTS-${MRBTS_ID_1}/NRBTS-${NRBTS_ID_1}
${ue_type_0}  samsung
${ue_type_1}  samsung
${PATH_Storage}    /home/ute/CB008828
${ENB_PATH}  MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].global_bts_id}
${UL_TP}                       50M
${UL_TP_THRESHOLD}              1
${DL_TP}                       300M
${DL_TP_THRESHOLD}              1
@{ACCSQ_counter}    M55161C00003  M55161C00001    M55161C00002
@{ACCSQ_counter_CU}    M55161C00008  M55161C00009
@{PDCPQ_counter}    M55352C02001    M55352C02003  M55352C02005  M55352C02006
@{ACDSQ_counter}    M55193C00001  M55193C00002
@{ACDSQ_counter_HO}    M55193C00003  M55193C00004
@{ACCSQ_counter_HO}    M55161C00010  M55161C00011
@{SMEXP_counter}  M55185C00009  M55185C00010  M55185C00011
@{SMEXP_counter_intre}  M55185C00004  M55185C00006  M55185C00008
@{SMENP_counter_intre}  M55186C00004  M55186C00005  M55186C00006
@{SMENP_counter_intra}  M55186C00007  M55186C00008  M55186C00009
@{SMEXP_counter_no}  M55185C00005
@{SMENP_counter_no}  M55186C00010
@{M55149_counter}  M55149C00008  M55149C00009  M55149C00010  M55149C02004  M55149C00021  M55149C00022  M55149C01001
...  M55149C01002  M55149C01003  M55149C01004
@{M55149_counter_intre}  M55149C00570  M55149C00571  M55149C00010  M55149C02004  M55149C00021  M55149C00022
@{M55149_counter_NG_intre}  M55149C03004  M55149C03005  M55149C03006  M55149C00010  M55149C00021  M55149C00022
@{M55149_counter_NG_intra}  M55149C03004  M55149C03005  M55149C03006  M55149C00010  M55149C00021  M55149C00022
@{SMAGP_counter_inter}  M55184C00011  M55184C00012
@{SMAGP_counter_inter_no}  M55184C00009  M55184C00010
@{PTHPQ_counter}  M55363C00001  M55363C00003
@{M55149_counter_intra_intre}  M55149C00550  M55149C00551  M55149C00002  M55149C00003  M55149C00020
...  M55149C00022  M55149C02002  M55149C00560  M55149C00561  M55149C00006  M55149C00007
@{SMAGP_counter_intra}  M55184C00015  M55184C00016
@{SMAGP_counter_intra_no}  M55184C00013  M55184C00014
@{M55149_counter_intra_intra}  M55149C00004  M55149C00005  M55149C00002  M55149C00003  M55149C00020  M55149C02002
@{M55149_activation}  M55149C00022
@{M55328_counter}  M55328C00001  M55328C00002  M55328C00003  M55328C00004  M55328C00005  M55328C00006  M55328C00007
@{M55159_counter}  M55159C00001  M55159C00005
${NPRMQAP-1}  NRCELL-13/NRPMQAP-1
${NPRMQAP-2}  NRCELL-13/NRPMQAP-2
${NPRMQAP-3}  NRCELL-13/NRPMQAP-3
${NPRMQAP-4}  NRCELL-13/NRPMQAP-4
# ${NPRMQAP-5}  NRCELL-1/NRPMQAP-5
${NPRMQAP-6}  NRCELL-13/NRPMQAP-6
${NPRMQAP-7}  NRCELL-13/NRPMQAP-7
${NPRMQAP-1_cell_14}  NRCELL-14/NRPMQAP-1
${NPRMQAP-1_cell_3}  NRCELL-3/NRPMQAP-1
${slice-1}  MCC-262/MNC-03/SST-1/SD-13714341
${slice-21}  MCC-460/MNC-02/SST-1/SD-13714341
${M55161}  ACCSQ
${M55352}  PDCPQ
${M55193}  ACDSQ
${M55185}  SMEXP
${M55149}  NSL
${M55186}  SMENP
${M55184}  SMAGP
${M55363}  PTHPQ
${M55159}  PDLTQ
${M55328}  NPSL
${delta_add_NRPMAP}               ${CURDIR}/config/delta_files/delta_add_NRPMAP.json
${delta_delete_NRPMAP}               ${CURDIR}/config/delta_files/delta_delete_NRPMAP.json
${delta_NG_HO_inter_source}               ${CURDIR}/config/delta_files/delta_NG_HO_inter_source.json
${delta_NG_HO_intra_source}               ${CURDIR}/config/delta_files/delta_NG_HO_intra_source.json
${delta_XN_HO_inter_source}               ${CURDIR}/config/delta_files/delta_XN_HO_inter_source.json
${delta_XN_HO_intra_source}               ${CURDIR}/config/delta_files/delta_XN_HO_intra_source.json
${delta_NG_HO_target}               ${CURDIR}/config/delta_files/delta_NG_HO_target.json
${delta_XN_HO_target}               ${CURDIR}/config/delta_files/delta_XN_HO_target.json
${delta_modify_intra_target}  ${CURDIR}/config/delta_files/delta_modify_intra_target.json
${delta_recover_intra_target}  ${CURDIR}/config/delta_files/delta_recover_intra_target.json
${delta_add_Xn_link}  ${CURDIR}/config/delta_files/delta_add_Xn_link.json
${delta_activate_8828}  ${CURDIR}/config/delta_files/delta_activate_8828.json
${mdrb_port}  45352
@{1921_intra_target}  6375  510000
@{1923_intra_target}  1  633334
@{1921_inter_target}  6411  513000
@{1923_inter_target}  1  636600
${1921_ui_version}  one ui 3.1
${1923_ui_version}  one ui 4.0
@{scf_value_list}  gscnOrSsPbchArfcn_value  nrarfcn_value
${ue1_ul_port}  45441
${ue1_dl_port}  45444
${cpe}  ${False}
${last_num}  10
${last_directory}  3
*** Keywords ***

Test Case Setup
    [Arguments]     ${case_name}
    ${TS_CASE_LOG_PATH}    catenate     SEPARATOR=/    ${PATH_Storage}    ${case_name}
    Set Test Variable    ${TS_CASE_LOG_PATH}
    # Run keyword And Ignore Error  Remove Directory  ${TS_CASE_LOG_PATH}  recursive=True
    Run Keyword And Continue On Failure  create directory  ${PATH_Storage}
    Run Keyword And Continue On Failure  create directory  ${PATH_Storage}/${case_name}
    robot_common_operations.Common Case Setup
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    ${exist_fault}    coam_gnb_classical.COAM Get active alarms
    Set test variable    ${exist_fault}
    Set Suite Variable  ${CASE_LOG_PATH}  ${TS_CASE_LOG_PATH}
    Remove files except for last  target_directory=${TS_CASE_LOG_PATH}
    Enable Syslog Info Level Prints

Remove files except for last
   [Arguments]  ${target_directory}=${TS_CASE_LOG_PATH}
    @{files}=   OperatingSystem.List Files in Directory   ${target_directory}   *   absolute
    ${num}  Get length  ${files}
    Run keyword If  ${num}>${last_num}  Remove Files    @{files[:-${last_num}]}
    @{files_a}=   OperatingSystem.List Files in Directory   ${target_directory}   *   absolute
    @{folders}=   OperatingSystem.List Directories In Directory   ${target_directory}   *   absolute
    ${num_tmp}  Get length  ${folders}
  Run keyword If  ${num_tmp}>${last_directory}  Remove directory except for last  target_directory=${target_directory}
  ...  num_tmp=${num_tmp}  folders=${folders}

Remove directory except for last
  [Arguments]  ${num_tmp}  ${folders}  ${target_directory}=${TS_CASE_LOG_PATH}
  ${num}  Evaluate  ${num_tmp}-${last_directory}
    FOR    ${i}    IN RANGE    ${num}
        ${dir_path}    Join Path    ${PATH_Storage}    ${folders}[${i}]
        Remove Directory  ${dir_path}  recursive=True
    END
    @{folders_a}=   OperatingSystem.List Directories In Directory   ${target_directory}   *   absolute

Test Case Teardown
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${exist_fault}    file_path=${TS_CASE_LOG_PATH}
    Run keyword And Ignore Error    Run Keyword If Test Failed    COAM Save snapshot via rest api  timeout=900
    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master
    run keyword and ignore error    COAM Teardown gnb connections
    # Run Keyword If Test Passed  Run keyword And Ignore Error  Remove Directory  ${TS_CASE_LOG_PATH}  recursive=True
    ${gnb_numbers}    get length    ${tl.gnbs}
    Run Keyword If Test Failed  Run keyword If  ${gnb_numbers}>${1}  Run keywords  Wait Until Keyword Succeeds    1 min    3 sec
    ...  Connect to gnb coam via ssl  gnb_index=1  connection=GNB_OAM_1
    ...  AND  Run keyword and continue on failure
    ...    COAM Save snapshot via rest api  timeout=900    log_path=${PATH_Storage}  connection=GNB_OAM_1
    ...  AND  run keyword and ignore error    COAM Teardown gnb connections  connection=GNB_OAM_1
    Run Keyword And Ignore Error  taf.sbts.oam.coam.admin.Teardown All Aliases For Admin
    robot_common_operations.Common Case Teardown
	CI_interface.Common Case Teardown

Suite Case Setup
    Run Keyword And Ignore Error    coam.teardown
    robot_common_operations.Common Suite Setup
    log to console  Get Active SW Version
    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    set suite variable      ${Active_SW_version}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    set suite variable      ${stream}

Suite Case Teardown
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    Run keyword if    '${SUITE STATUS}' == 'FAIL'    Run keyword and continue on failure
    ...    COAM Save snapshot via rest api  timeout=900    log_path=${PATH_Storage}
    run keyword and ignore error    COAM Teardown gnb connections
    ${gnb_numbers}    get length    ${tl.gnbs}
    Run keyword If  '${SUITE STATUS}' == 'FAIL' and ${gnb_numbers}>${1}  Run keywords  Wait Until Keyword Succeeds    1 min    3 sec
    ...  Connect to gnb coam via ssl  gnb_index=1  connection=GNB_OAM_1
    ...  AND  Run keyword and continue on failure
    ...    COAM Save snapshot via rest api  timeout=900    log_path=${PATH_Storage}  connection=GNB_OAM_1
    ...  AND  run keyword and ignore error    COAM Teardown gnb connections  connection=GNB_OAM_1
    Check Alarm and stop robot testing when unexpected alarm raised
    robot_common_operations.Common Suite Teardown
    log to console    Suite Case Teardown

Suite Case D Teardown
  Suite Case Teardown
  Run Keyword And Ignore Error  Modify attenuator value by port   modify_value=${127}  port=0    ru_id=0

Get Check time
    [Arguments]  ${NPRMQAP-id}=NRCELL-13/NRPMQAP-1  ${counter}=M55193C00001  ${meas}=${M55193}
    Wait for one counter period
    Sleep  2min  reason=wait for Measurement
    Log To Console  Get Check time
    ${counter_group} =    Split String    ${NPRMQAP-id}    /
    ${len}  Get Length  ${counter_group}
    ${Counter1} =    Wait Until Keyword Succeeds  3x  10s  coam.get_counters_info    connection=GNB_OAM    timeout=600
    ...  dist_name=BTS/${GNB_PATH}/${NPRMQAP-id}/${meas}/${counter}
    &{dic_name}  Set Variable  ${Counter1['BTS']['MRBTS-${MRBTS_ID}']['NRBTS-${NRBTS_ID}']['${counter_group[0]}']}
    FOR  ${i}  IN RANGE  1  ${len}
      &{dic_name}  Set Variable  ${dic_name['${counter_group[${i}]}']}
    END
    ${Counter10}=  Set Variable  ${dic_name['${meas}']['${counter}']}
    ${Counter11}=  Get Dictionary Keys  ${Counter10}
    ${Counter_Time}  Set Variable  ${Counter11[-1]}
    ${latest_value}  Get From Dictionary    ${Counter10}    ${Counter_Time}
    ${Counter_Time}  Run Keyword If  ${latest_value}>=${1}  set variable  ${Counter_Time}
    ...  ELSE  Set Variable    ${Counter11[-2]}
    [return]    ${Counter_Time}

Get latest counter value
    [Arguments]    ${counter_id}    ${counter_full_path}  ${check_time}  ${gnb}=${GNB_PATH}  ${connection}=GNB_OAM
    Log to console    Gathering value of counter: "${counter_id}" for ${counter_full_path}
    ${counter_group} =    Split String    ${counter_full_path}    /
    ${counter_groups_length} =    Get Length    ${counter_group}
    ${name}  Set Variable  ${counter_group}[1]
    FOR  ${i}  IN RANGE  2  ${counter_groups_length}
      ${name}  Set Variable  ${name}/${counter_group}[${i}]
    END
    ${C1} =    Wait Until Keyword Succeeds  3x  10s  coam.get_counters_info    connection=${connection}    timeout=600
    ...  dist_name=BTS/${gnb}/${name}/${counter_id}
    ${dic_name}  Set Variable  ${C1['BTS']['MRBTS-${MRBTS_ID}']['NRBTS-${NRBTS_ID}']['${counter_group}[1]']}
    FOR  ${i}  IN RANGE  2  ${counter_groups_length}
      ${dic_name}  Set Variable  ${dic_name['${counter_group}[${i}]']}
    END
    ${Counter10}=  Set Variable  ${dic_name['${counter_id}']}
    ${latest_value}  Get From Dictionary    ${Counter10}    ${check_time}
    ${status1}  Run Keyword And Return Status  Should Be True  ${latest_value}==${0}
    ${status2}  Run Keyword And Return Status  Should Contain  ${counter_id}  M55352
    ${Counter11}  Get Dictionary Keys  ${Counter10}
    ${latest_value}  Run Keyword If  ${status1} and ${status2}  Get From Dictionary  ${Counter10}  ${Counter11[-1]}
    ...  ELSE  Set Variable  ${latest_value}
    [return]    ${latest_value}

Check Measurement M55161 M55352 M55193 for NRPMQAP
    [Arguments]  ${flag1}=normal  ${flag2}=normal  ${ue_index}=${0}  ${NPRMQAP-id}=${NPRMQAP-3}
    Attach real UE  ue_index=${ue_index}
    ${counter_groups}  Get Check time  NPRMQAP-id=${NPRMQAP-id}
    Check Counter normal or abnormal  counter=${ACCSQ_counter}  flag=${flag1}  counter_object=${NPRMQAP-3}  meas=${M55161}
    ...  counter_groups=${counter_groups}
    Check Counter normal or abnormal  counter=${ACCSQ_counter}  flag=${flag2}  counter_object=${NPRMQAP-4}  meas=${M55161}
    ...  counter_groups=${counter_groups}
    Check Counter normal or abnormal  counter=${ACDSQ_counter}  flag=${flag1}  counter_object=${NPRMQAP-3}
    ...  counter_groups=${counter_groups}
    Run Keyword If  '${flag2}'=='normal'  Check Counter normal or abnormal  counter=${ACDSQ_counter}  flag=${flag2}
    ...  counter_object=${NPRMQAP-4}
    ...  counter_groups=${counter_groups}
    Check Counter normal or abnormal  counter=${PDCPQ_counter}  flag=${flag1}  counter_object=${NPRMQAP-3}  meas=${M55352}
    ...  counter_groups=${counter_groups}
    Check Counter normal or abnormal  counter=${PDCPQ_counter}  flag=${flag2}  counter_object=${NPRMQAP-4}  meas=${M55352}
    ...  counter_groups=${counter_groups}
    [Teardown]  Run keyword and ignore error  Dettach UE and Stop traffic  ue_index=${ue_index}


Check Counter normal or abnormal
    [Arguments]  ${counter_groups}=${None}  ${counter}=${None}  ${flag}=normal  ${meas}=${M55193}
    ...  ${counter_object}=${NPRMQAP-3}
    ${len}  Get Length  ${counter}
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    FOR  ${i}  IN RANGE  ${len}
        ${status}  Run keyword If  '${flag}'!='normal' and '${meas}'=='${M55193}'  run keyword and return status
        ...  Get latest counter value  counter_id=${counter}[${i}]  check_time=${counter_groups}
        ...  counter_full_path=CELLS/${counter_object}/${meas}
        Run keyword If  '${status}'=='False'    Exit For Loop
        ${value}    Get latest counter value  counter_id=${counter}[${i}]  check_time=${counter_groups}
        ...  counter_full_path=CELLS/${counter_object}/${meas}
        Run Keyword And Continue On Failure  Run keyword if  '${flag}'=='normal'  should be true    ${value}>${0}
        ...  ELSE IF  '${counter}[${i}]'=='M55161C00002'  should be true    ${value}>=${300}
        ...  ELSE  should be true    ${value}==${0}
    END

Modify SNSSAI in NRPMQAP objects
    [Arguments]  ${value}=${GNB_PATH}/SNSSAI-1991  ${parameter}=snssaiDN  ${id}=4  ${list_name}=snssaiList    ${connection}=GNB_OAM
    ...  ${dist_name}=${GNB_PATH}/NRPMRNL-1/NRPMQAP-${id}
    Log To Console  Modify ${dist_name}
    coam_parameter.perform_single_parameter_update  value=${value}  parameter=${parameter}  list_name=${list_name}
    ...  dist_name=${dist_name}  connection=${connection}  timeout=90

Modify parameter in objects
    [Arguments]  ${scf_file_path}  ${value}=${GNB_PATH}/SNSSAI-1991  ${parameter}=snssaiDN  ${list_name}=${None}    ${connection}=GNB_OAM
    ...  ${dist_name}=${GNB_PATH}/NRPMRNL-1/NRPMQAP-${id}
    Log To Console  Modify ${dist_name}
    ${pre_value}  Get Parameter Value via SCF  parameter=${parameter}  dist_name=${dist_name}  scf_file_path=${scf_file_path}  list_name=${list_name}
    Run keyword IF  '${pre_value}'!='${value}'  coam_parameter.perform_single_parameter_update  value=${value}  parameter=${parameter}
    ...  list_name=${list_name}  timeout=90
    ...  dist_name=${dist_name}  connection=${connection}
    [Return]   ${pre_value}

Get SCF From BTS
    [Arguments]  ${connection}=GNB_OAM
    ...          ${sub_scf_dir}=tmp_scf
    ...          ${config_type}=configurationAndRuntimeObjects
    Log To Console  Get SCF From BTS
    ${local_dir}    Set Variable     ${TS_CASE_LOG_PATH}/${sub_scf_dir}
    Create Directory    ${local_dir}
    ${current_time}    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S%f
    ${scf_file_path}     Set Variable    ${local_dir}/scf_${current_time}.xml
    coam.collect_scf    target_file_name=${scf_file_path}    export_type=${config_type}
    ...    timeout=30    connection=${connection}
    [Return]   ${scf_file_path}

Get Parameter Value via SCF
    [Arguments]  ${parameter}    ${dist_name}  ${scf_file_path}  ${p_index}=${0}    ${list_name}=${None}    ${connection}=GNB_OAM
    ...          ${config_type}=configurationAndRuntimeObjects
    Log To Console  Get ${parameter} Value of ${dist_name} from SCF
    ${value}     coam_parameter.get_single_value_from_scf_file    local_dir_path=${scf_file_path}   p_index=${p_index}
    ...       parameter=${parameter}   list_name=${list_name}   dist_name=${dist_name}
    ...       connection=${connection}    config_type=${config_type}
    # run keyword and ignore error    run    rm -rf ${local_dir}
    [Return]   ${value}

Modify attenuator value by port
    [arguments]    ${modify_value}    ${port}    ${ru_id}=0    ${vender}=HBTE
    #attenuator.setup_attenuator    attenuator=${tl.attenuator}    alias=${vender}
    Log To Console  Modify attenuator value for RU_${ru_id}
    ${value}  Get value from Attenuator  port=${port}      ru_id=${ru_id}
    ${status}  Run Keyword And Return Status  Should not Be Equal   ${modify_value}  ${value}
    Run Keyword If  ${status}    attenuator.set_attenuation
    ...      port=${tl.gnbs[0].dus[0].rus[${ru_id}].attenuation_ports[${port}]}
    ...      value=${modify_value}
    ...      attenuator_device=${vender}
    ${value1}  Get value from Attenuator  port=${port}      ru_id=${ru_id}
    Run Keyword If  ${status}    Should Be Equal   ${modify_value}  ${value1}

Get value from Attenuator
    [arguments]    ${port}      ${ru_id}=0    ${vender}=HBTE
    ${value}    attenuator.read_attenuation
    ...      port=${tl.gnbs[0].dus[0].rus[${ru_id}].attenuation_ports[${port}]}    attenuator_device=${vender}
    [Return]      ${value}

Add SNSSAI in NRPMQAP objects
    ${scf_file_path}  Get SCF From BTS
    ${NRPMQAP2_slice_b}  Modify parameter in objects  value=SNSSAI-1992  parameter=snssaiDN  dist_name=${GNB_PATH}/NRPMRNL-1/NRPMQAP-4
    ...  list_name=snssaiList
    ...  scf_file_path=${scf_file_path}
    ${NRPMQAP1_slice_b}  Modify parameter in objects  value=SNSSAI-1991  parameter=snssaiDN  dist_name=${GNB_PATH}/NRPMRNL-1/NRPMQAP-3
    ...  list_name=snssaiList  scf_file_path=${scf_file_path}
    Wait for one counter period
    Check Measurement M55161 M55352 M55193 for NRPMQAP  flag1=normal  flag2=abnormal
    Modify SNSSAI in NRPMQAP objects
    Check Measurement M55161 M55352 M55193 for NRPMQAP  flag1=normal  flag2=normal

Remove SNSSAI in NRPMQAP objects
    Log To Console  Remove SNSSAI in NRPMQAP objects
    Sleep  5min  reason=wait for next counter
    Modify SNSSAI in NRPMQAP objects  id=3  value=${GNB_PATH}/SNSSAI-4
    Wait for one counter period
    Check Measurement M55161 M55352 M55193 for NRPMQAP  flag1=abnormal  flag2=normal  NPRMQAP-id=${NPRMQAP-4}

Move SNSSAI in NRPMQAP objects
    Log To Console  Move SNSSAI in NRPMQAP objects
    Sleep  5min  reason=wait for next counter
    Modify SNSSAI in NRPMQAP objects  id=4  value=${GNB_PATH}/SNSSAI-1992
    Modify SNSSAI in NRPMQAP objects  id=3  value=${GNB_PATH}/SNSSAI-5
    Wait for one counter period
    Check Measurement M55161 M55352 M55193 for NRPMQAP  flag1=abnormal  flag2=normal  ue_index=${1}  NPRMQAP-id=${NPRMQAP-4}

SA Admission Control initial access
    ${scf_file_path}  Get SCF From BTS
    Modify parameter in objects  value=SNSSAI-1992  parameter=snssaiDN  dist_name=${GNB_PATH}/NRPMRNL-1/NRPMQAP-4  list_name=snssaiList
    ...  scf_file_path=${scf_file_path}
    Modify parameter in objects  value=SNSSAI-1991  parameter=snssaiDN  dist_name=${GNB_PATH}/NRPMRNL-1/NRPMQAP-2  list_name=snssaiList
    ...  scf_file_path=${scf_file_path}
    Attach real UE  ue_index=${1}  dl_port=${ue1_dl_port}  ul_port=${ue1_ul_port}
    ${counter_groups}  Get Check time  NPRMQAP-id=${NPRMQAP-4}
    ${5Grach_ed}  Attach real UE
    ${counter_groups_real}  Get Check time  NPRMQAP-id=${NPRMQAP-2}
    Check Measurement M55161 M55193 for NRPMQAP  counter_groups=${counter_groups}  flag=normal  counter_object=${NPRMQAP-4}
    Run Keyword And Continue On Failure  Verify attach and Check Throughput  5Grach_ed=${5Grach_ed}
    Check Measurement M55161 M55193 for NRPMQAP  counter_groups=${counter_groups_real}  flag=normal  counter_object=${NPRMQAP-2}
    [Teardown]  Run keywords  Run Keyword And Ignore Error  Dettach UE and Stop traffic  ue_index=${1}
    ...  AND  Run Keyword And Ignore Error   Dettach UE and Stop traffic  ue_index=${0}

Check Measurement M55161 M55193 for NRPMQAP
    [arguments]  ${counter_groups}  ${flag}=normal  ${counter_object}=${NPRMQAP-4}  ${counter}=${ACCSQ_counter}
    Check Counter normal or abnormal  counter=${counter}  flag=${flag}  counter_object=${counter_object}
    ...  meas=${M55161}  counter_groups=${counter_groups}
    Check Counter normal or abnormal  counter=${ACDSQ_counter}  flag=${flag}  counter_object=${counter_object}
        ...  counter_groups=${counter_groups}


Attach real UE
    [Documentation]  global_cell_id(Global cell ID): 1
    ...    ul_tp: 50M    ul_tp_threshold: 15
    ...    dl_tp: 300M    dl_tp_threshold: 220
    ...    [Return]    ul_tp: 20    dl_tp; 200
    [Arguments]    ${global_cell_id}=13    ${ul_tp}=100M
    ...    ${dl_tp}=300M    ${attach_mode}=SA    ${iperf_type}=via_command
    ...    ${ul_duration}=12000    ${dl_duration}=12000    ${ue_index}=${0}  ${ue_type}=${ue_type_${ue_index}}
    ...  ${ul_port}=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    ...  ${dl_port}=${tl.ues[${ue_index}].iperf_details.port}
    ...  ${UL_traffic}=${True}
    Log To Console  ${attach_mode} UE${ue_index} Attach nrcell-${global_cell_id}
    # Connect to gnb coam via ssl
#    Run Keyword If  '${ue_index}'=='1'  Set Test Variable  ${ul_port}  ${ue1_ul_port}
#    Run Keyword If  '${ue_index}'=='1'  Set Test Variable  ${dl_port}  ${ue1_dl_port}
    ${iperf_type}  Set Variable If  '${ue_type}'=='huawei'  via_app  via_command
    Run Keyword And Ignore Error  android_ue.UE Prepare  ue_index=${ue_index}  ue_type=${ue_type}  iperf_port=${ul_port}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    timeout=1m
    Sleep    10s

    Run Keyword If  ${UL_traffic} and '${iperf_type}'=='via_command'  UE Start UL Traffic  throughput=${ul_tp}  ul_time=${ul_duration}
    ...    ul_port=${ul_port}  ue_index=${ue_index}
    ...  ELSE IF  ${UL_traffic}  power_ue.Start traffic   ue_type=${ue_type}   direction=ul   throughput=${ul_tp}    duration=${ul_duration}
    ...    ue_index=${ue_index}  iperf_port=${ul_port}
    UE Start DL Traffic    throughput=${dl_tp}    dl_time=${dl_duration}    dl_port=${dl_port}
    ...    ue_index=${ue_index}
    [Return]   ${5Grach_ed}

Verify attach and Check Throughput
    [Arguments]    ${5Grach_ed}=${None}  ${global_cell_id}=13    ${ul_tp_threshold}=${UL_TP_THRESHOLD}  ${UL_check}=${True}
    ...    ${dl_tp_threshold}=${DL_TP_THRESHOLD}  ${ue_index}=${0}  ${ue_type}=${ue_type_${ue_index}}  ${5G_check}=True

    Log To Console  Verify attach and Check Throughput
    Run Keyword If  '${5G_check}'=='True'  power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}  4G_check=False
    ...  ue_index=${ue_index}
    ${nr_cell_identity}    Get NR Cell Identity Via Index "${global_cell_id}"
    Run Keyword If  '${UL_check}'=='True'  Run Keyword And Continue On Failure  power_ue.Check throughput    ue_index=${ue_index}    direction=ul
    ...    ue_type=${ue_type}    throughput=${ul_tp_threshold}    cellid=${nr_cell_identity}
    Run Keyword And Continue On Failure  power_ue.Check throughput   ue_index=${ue_index}    direction=dl    ue_type=${ue_type}
    ...    throughput=${dl_tp_threshold}    cellid=${nr_cell_identity}

Online modification of slice configuration add NRPMQAP
    ${scf_file_path}  Get SCF From BTS
    Modify parameter in objects  value=SNSSAI-1992  parameter=snssaiDN  dist_name=${GNB_PATH}/NRPMRNL-1/NRPMQAP-3  list_name=snssaiList
    ...  scf_file_path=${scf_file_path}
    ${exist_NRPMQAP6}  Run Keyword And Return Status  Get Parameter Value via SCF  parameter=snssaiDN  dist_name=${GNB_PATH}/NRPMRNL-1/NRPMQAP-6
    ...  list_name=snssaiList  scf_file_path=${scf_file_path}
    Set Test Variable  ${exist_NRPMQAP6}
    Run Keyword If  ${exist_NRPMQAP6}  Run keywords  scf.Modify json file and activate  json_file=${delta_delete_NRPMAP}
    ...  AND  Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    Attach real UE  ue_index=${1}  dl_port=${ue1_dl_port}  ul_port=${ue1_ul_port}
    ${counter_groups}  Get Check time  NPRMQAP-id=${NPRMQAP-3}
    Check Measurement M55161 M55193 for NRPMQAP  counter_groups=${counter_groups}  flag=normal  counter_object=${NPRMQAP-3}
    scf.Modify json file and activate  json_file=${delta_add_NRPMAP}
    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
    Wait for one counter period
    ${5Grach_ed}  Attach real UE
    ${counter_groups_real}  Get Check time  NPRMQAP-id=${NPRMQAP-6}
    Check Measurement M55161 M55193 for NRPMQAP  counter_groups=${counter_groups_real}  flag=normal  counter_object=${NPRMQAP-6}
    Check Measurement M55161 M55193 for NRPMQAP  counter_groups=${counter_groups_real}  flag=abnormal  counter_object=${NPRMQAP-7}
    Run Keyword And Continue On Failure  Verify attach and Check Throughput  5Grach_ed=${5Grach_ed}
    Check Counter normal or abnormal  counter=${ACCSQ_counter}  flag=normal  counter_object=${NPRMQAP-3}  meas=${M55161}
    ...  counter_groups=${counter_groups_real}
    [Teardown]  Run keywords  Run Keyword And Ignore Error  Dettach UE and Stop traffic  ue_index=${1}
    ...  AND  Run Keyword And Ignore Error   Dettach UE and Stop traffic  ue_index=${0}


Check No Counter value
    [Arguments]  ${counter_groups}=${None}  ${counter_object}=${NPRMQAP-3}  ${counter}=${None}  ${meas}=${M55193}
    ...  ${connection}=GNB_OAM    ${gnb_index}=0  ${gnb}=${GNB_PATH}
	${len}  Get Length  ${counter}
    Log To Console  Check No Counter value
    run keyword and ignore error    COAM Teardown gnb connections  connection=${connection}
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl  connection=${connection}  gnb_index=${gnb_index}
    FOR  ${i}  IN RANGE  ${len}
        ${status}  run keyword and return status
        ...  Get latest counter value  counter_id=${counter}[${i}]  check_time=${counter_groups}  gnb=${gnb}
        ...  counter_full_path=CELLS/${counter_object}/${meas}  connection=${connection}
        Should Be True  '${status}'=='False'
    END


Online modification of slice configuration delete NRPMQAP
    Log To Console  delete NRPMQAP
    Attach real UE  ue_index=${1}  dl_port=${ue1_dl_port}  ul_port=${ue1_ul_port}
    Run Keyword If  '${exist_NRPMQAP6}'!='True'  Modify json file and activate  json_file=${delta_delete_NRPMAP}
    Connect to gnb coam via ssl
	Wait for one counter period
    ${5Grach_ed}  Attach real UE
    ${counter_groups_real}  Get Check time  NPRMQAP-id=${NPRMQAP-3}
    Check Counter normal or abnormal  counter=${ACCSQ_counter}  flag=normal  counter_object=${NPRMQAP-3}  meas=${M55161}
    ...  counter_groups=${counter_groups_real}
    Run Keyword And Continue On Failure  Verify attach and Check Throughput  5Grach_ed=${5Grach_ed}
    Check No Counter value  counter_groups=${counter_groups_real}  counter_object=${NPRMQAP-6}  counter=${ACDSQ_counter}
    ...  meas=${M55193}
    Check No Counter value  counter_groups=${counter_groups_real}  counter_object=${NPRMQAP-7}  counter=${ACDSQ_counter}
    ...  meas=${M55193}
    Check No Counter value  counter_groups=${counter_groups_real}  counter_object=${NPRMQAP-6}  counter=${ACCSQ_counter}
    ...  meas=${M55161}
    Check No Counter value  counter_groups=${counter_groups_real}  counter_object=${NPRMQAP-7}  counter=${ACCSQ_counter}
    ...  meas=${M55161}
    [Teardown]  Run keywords  Run Keyword And Ignore Error  Dettach UE and Stop traffic  ue_index=${1}
    ...  AND  Run Keyword And Ignore Error   Dettach UE and Stop traffic  ue_index=${0}


Trigger IntraFreq IntergNBHO and check Measurement
    # attenuator.setup_attenuator    attenuator=${tl.attenuator}    alias=HBTE
    Modify attenuator value by port   modify_value=${0}  port=0    ru_id=1
    Modify attenuator value by port   modify_value=${127}  port=1    ru_id=1
    Modify attenuator value by port   modify_value=${127}  port=0    ru_id=0
    Modify attenuator value by port   modify_value=${127}  port=1    ru_id=0
    Attach real UE
    Run Keyword And Ignore Error  Verify attach by adb  physCellId=${cell_1}    ue_index=${0}  attach_mode=5G_SA
    Modify attenuator value by port   modify_value=${0}  port=0    ru_id=0
    sleep    10s
    Modify attenuator value by port   modify_value=${20}  port=0    ru_id=1
    sleep    10s
    ${counter_groups}  Get Check time  NPRMQAP-id=${NPRMQAP-1}  counter=M55193C00003
    Check Counter normal or abnormal  counter=${ACDSQ_counter_HO}  flag=normal  counter_object=${NPRMQAP-1}
    ...  counter_groups=${counter_groups}
    Run Keyword And Continue On Failure  Verify attach and Check Throughput  5G_check=False
    Run Keyword And Ignore Error  Verify SA UE handover by adb    target_physCellId=${cell_2}  source_physCellId=${cell_1}
    [Teardown]  Run Keywords  Run Keyword And Ignore Error   Dettach UE and Stop traffic  ue_index=${0}
    ...  AND  Run Keyword And Ignore Error  Modify attenuator value by port   modify_value=${127}  port=0    ru_id=1

Trigger IntraFreq IntergNBHO and check M55161 and M55193
    # attenuator.setup_attenuator    attenuator=${tl.attenuator}    alias=HBTE
    Modify attenuator value by port   modify_value=${0}  port=0    ru_id=1
    Modify attenuator value by port   modify_value=${127}  port=1    ru_id=1
    Modify attenuator value by port   modify_value=${127}  port=0    ru_id=0
    Modify attenuator value by port   modify_value=${127}  port=1    ru_id=0
    Attach real UE
    Run Keyword And Ignore Error  Verify attach by adb  physCellId=${cell_1}    ue_index=${0}  attach_mode=5G_SA
    Modify attenuator value by port   modify_value=${0}  port=0    ru_id=0
    sleep    10s
    Modify attenuator value by port   modify_value=${20}  port=0    ru_id=1
    sleep    10s
    ${counter_groups}  Get Check time  NPRMQAP-id=${NPRMQAP-1}  counter=M55193C00003
    Check Counter normal or abnormal  counter=${ACDSQ_counter_HO}  flag=normal  counter_object=${NPRMQAP-1}
    ...  counter_groups=${counter_groups}
    Check Counter normal or abnormal  counter=${ACCSQ_counter_HO}  flag=normal  counter_object=${NPRMQAP-1}
    ...  counter_groups=${counter_groups}  meas=${M55161}
    Run Keyword And Continue On Failure  Verify attach and Check Throughput  5G_check=False
    Run Keyword And Ignore Error  Verify SA UE handover by adb    target_physCellId=${cell_2}  source_physCellId=${cell_1}
    [Teardown]  Run Keywords  Run Keyword And Ignore Error   Dettach UE and Stop traffic  ue_index=${0}
    ...  AND  Run Keyword And Ignore Error  Modify attenuator value by port   modify_value=${127}  port=0    ru_id=1

SA Admission Control initial access in CU
    ${scf_file_path}  Get SCF From BTS
    Modify parameter in objects  value=SNSSAI-1992  parameter=snssaiDN  dist_name=${GNB_PATH}/NRPMRNL-1/NRPMQAP-4  list_name=snssaiList
    ...  scf_file_path=${scf_file_path}
    Modify parameter in objects  value=SNSSAI-1991  parameter=snssaiDN  dist_name=${GNB_PATH}/NRPMRNL-1/NRPMQAP-2  list_name=snssaiList
    ...  scf_file_path=${scf_file_path}
	Wait for one counter period
    Attach real UE  ue_index=${1}  dl_port=${ue1_dl_port}  ul_port=${ue1_ul_port}
    ${counter_groups}  Get Check time  NPRMQAP-id=${NPRMQAP-4}
    ${5Grach_ed}  Attach real UE
    ${counter_groups_real}  Get Check time  NPRMQAP-id=${NPRMQAP-2}
    Check Measurement M55161 M55193 for NRPMQAP  counter_groups=${counter_groups}  flag=normal  counter_object=${NPRMQAP-4}
    ...  counter=${ACCSQ_counter_CU}
    Run Keyword And Continue On Failure  Verify attach and Check Throughput  5Grach_ed=${5Grach_ed}
    Check Measurement M55161 M55193 for NRPMQAP  counter_groups=${counter_groups_real}  flag=normal  counter_object=${NPRMQAP-2}
    ...  counter=${ACCSQ_counter_CU}
    [Teardown]  Run keywords  Run Keyword And Ignore Error  Dettach UE and Stop traffic  ue_index=${1}
    ...  AND  Run Keyword And Ignore Error   Dettach UE and Stop traffic  ue_index=${0}

Intra-frequency_successful_handover
    [Arguments]    ${check_counter}=M55185C00009  ${meas}=${M55185}  ${normal_counter}=${SMEXP_counter}
    ...  ${abnormal_counter}=${SMEXP_counter_no}  ${no_update_counter}=${M55149_counter}
    ...  ${no_update_meas}=${M55149}  ${GBR}=${True}  ${inter_gnb}=${True}
    # attenuator.setup_attenuator    attenuator=${tl.attenuator}    alias=HBTE
    Modify attenuator value by port   modify_value=${0}  port=0    ru_id=0
    Modify attenuator value by port   modify_value=${127}  port=1    ru_id=0
    Modify attenuator value by port   modify_value=${127}  port=0    ru_id=1
    Modify attenuator value by port   modify_value=${127}  port=1    ru_id=1
    ${ui_version}  Set Variable If  '${MRBTS_ID}'=='1921'  ${1921_ui_version}  ${1923_ui_version}
    Run keyword IF  ${GBR}  Switch APN  ui_version=${ui_version}  new_APN=mdrb
    ${5Grach_ed}  Run keyword IF  ${GBR}  Attach real UE  ul_port=${mdrb_port}  dl_port=${mdrb_port}
    ...  ELSE  Attach real UE
    Run Keyword And Ignore Error  Verify attach by adb  physCellId=${cell_2}    ue_index=${0}  attach_mode=5G_SA
    Run Keyword And Continue On Failure  Verify attach and Check Throughput  5Grach_ed=${5Grach_ed}
    Run Keyword If  ${inter_gnb}  Modify attenuator value by port   modify_value=${0}  port=0    ru_id=1
    ...  ELSE   Modify attenuator value by port   modify_value=${0}  port=1    ru_id=0
    sleep    10s
    Modify attenuator value by port   modify_value=${20}  port=0    ru_id=0
    sleep    10s
    ${counter_groups}  Get Check time  NPRMQAP-id=${NPRMQAP-1}  counter=${check_counter}  meas=${meas}
    Check Counter normal or abnormal  counter=${normal_counter}  flag=normal  counter_object=${NPRMQAP-1}
    ...  counter_groups=${counter_groups}  meas=${meas}
    Check Counter normal or abnormal  counter=${abnormal_counter}  flag=abnormal  counter_object=${NPRMQAP-1}
    ...  counter_groups=${counter_groups}  meas=${meas}
    Check No Counter value  counter=${no_update_counter}  counter_object=${NPRMQAP-1}
    ...  counter_groups=${counter_groups}  meas=${no_update_meas}
    Run Keyword If  ${inter_gnb}  Run keywords  Run Keyword And Ignore Error  Verify SA UE handover by adb  target_physCellId=${cell_1}
    ...  source_physCellId=${cell_2}
    ...  AND  Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl  gnb_index=1  connection=GNB_OAM_1
    ...  AND  Check No Counter value  counter=${no_update_counter}  counter_object=${NPRMQAP-1_cell_3}
    ...  counter_groups=${counter_groups}  meas=${no_update_meas}  gnb=${GNB_PATH_1}  connection=GNB_OAM_1  gnb_index=1
    ...  ELSE  Run keywords  Run Keyword And Ignore Error  Verify SA UE handover by adb    target_physCellId=${cell_3}  source_physCellId=${cell_2}
    ...  AND  Check No Counter value  counter=${no_update_counter}  counter_object=${NPRMQAP-1_cell_14}
    ...  counter_groups=${counter_groups}  meas=${no_update_meas}
    [Teardown]  Run Keywords  Run Keyword And Ignore Error   Dettach UE and Stop traffic  ue_index=${0}
    ...  AND  Run Keyword If  ${inter_gnb}  Run Keyword And Ignore Error  Modify attenuator value by port   modify_value=${127}  port=0    ru_id=1
    ...  ELSE  Modify attenuator value by port   modify_value=${127}  port=1    ru_id=0
    ...  AND  Run Keyword And Ignore Error  Modify attenuator value by port   modify_value=${0}  port=0    ru_id=0
    ...  AND  Run keyword IF  ${GBR}  Switch APN  ui_version=${ui_version}  new_APN=dxdata2
    ...  AND  Run Keyword If  ${inter_gnb}  Run Keyword And Ignore Error  COAM Teardown gnb connections  connection=GNB_OAM_1
    [Return]  ${counter_groups}

Inter-frequency_successful_handover
    [Arguments]    ${check_counter}=M55185C00004  ${meas}=${M55185}  ${normal_counter}=${SMEXP_counter_intre}
    ...  ${abnormal_counter}=${SMEXP_counter_no}  ${no_update_counter}=${M55149_counter_intre}
    ...  ${no_update_meas}=${M55149}  ${inter_gnb}=${True}
    # attenuator.setup_attenuator    attenuator=${tl.attenuator}    alias=HBTE
    Modify attenuator value by port   modify_value=${127}  port=0    ru_id=0
    Modify attenuator value by port   modify_value=${0}  port=1    ru_id=0
    Modify attenuator value by port   modify_value=${127}  port=0    ru_id=1
    Modify attenuator value by port   modify_value=${127}  port=1    ru_id=1
    ${5Grach_ed}  Attach real UE
    Run Keyword And Ignore Error  Verify attach by adb  physCellId=${cell_3}    ue_index=${0}  attach_mode=5G_SA
    Run Keyword And Continue On Failure  Verify attach and Check Throughput  5Grach_ed=${5Grach_ed}  global_cell_id=14
    # Wait For Next Raw Pm Interval
    Run Keyword If  ${inter_gnb}  Modify attenuator value by port   modify_value=${0}  port=0    ru_id=1
    ...  ELSE   Modify attenuator value by port   modify_value=${0}  port=0    ru_id=0
    sleep    10s
    Modify attenuator value by port   modify_value=${30}  port=1    ru_id=0
    sleep    10s
    ${counter_groups}  Get Check time  NPRMQAP-id=${NPRMQAP-1_cell_14}  counter=${check_counter}  meas=${meas}
    Check Counter normal or abnormal  counter=${normal_counter}  flag=normal  counter_object=${NPRMQAP-1_cell_14}
    ...  counter_groups=${counter_groups}  meas=${meas}
    Check Counter normal or abnormal  counter=${abnormal_counter}  flag=abnormal  counter_object=${NPRMQAP-1_cell_14}
    ...  counter_groups=${counter_groups}  meas=${meas}
    Check No Counter value  counter=${no_update_counter}  counter_object=${NPRMQAP-1_cell_14}
    ...  counter_groups=${counter_groups}  meas=${no_update_meas}
    Run Keyword If  ${inter_gnb}  Run keywords  Run Keyword And Ignore Error  Verify SA UE handover by adb  target_physCellId=${cell_1}
    ...  source_physCellId=${cell_3}
    ...  AND  Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl  gnb_index=1  connection=GNB_OAM_1
    ...  AND  Check No Counter value  counter=${no_update_counter}  counter_object=${NPRMQAP-1_cell_3}
    ...  counter_groups=${counter_groups}  meas=${no_update_meas}  connection=GNB_OAM_1  gnb_index=1  gnb=${GNB_PATH_1}
    ...  ELSE  Run keywords  Run Keyword And Ignore Error  Verify SA UE handover by adb    target_physCellId=${cell_2}  source_physCellId=${cell_3}
    ...  AND  Check No Counter value  counter=${no_update_counter}  counter_object=${NPRMQAP-1}
    ...  counter_groups=${counter_groups}  meas=${no_update_meas}
    [Teardown]  Run Keywords  Run Keyword And Ignore Error   Dettach UE and Stop traffic  ue_index=${0}
    ...  AND  Run Keyword And Ignore Error  Modify attenuator value by port   modify_value=${127}  port=0    ru_id=1
    ...  AND  Run Keyword And Ignore Error  Modify attenuator value by port   modify_value=${0}  port=0    ru_id=0
    ...  AND  Run Keyword And Ignore Error  Modify attenuator value by port   modify_value=${127}  port=1    ru_id=0
    ...  AND  Run Keyword If  ${inter_gnb}  Run Keyword And Ignore Error  COAM Teardown gnb connections  connection=GNB_OAM_1
    [Return]  ${counter_groups}

NG-based_Inter-frequency_successful_handover
    scf.Modify json file and activate  json_file=${delta_NG_HO_inter_source}
    scf.Modify json file and activate  json_file=${delta_NG_HO_target}  connection=GNB_OAM_1  gnb_index=1
    ...  string_1=${MRBTS_ID_1}  string_2=${NRBTS_ID_1}
    Connect to gnb coam via ssl
    Inter-frequency_successful_handover  check_counter=M55186C00004  meas=${M55186}  normal_counter=${SMENP_counter_intre}
    ...  abnormal_counter=${SMENP_counter_no}  no_update_counter=${M55149_counter_NG_intre}
    ...  no_update_meas=${M55149}
    [Teardown]  Run Keywords  scf.Modify json file and activate  json_file=${delta_XN_HO_inter_source}
    ...  AND  scf.Modify json file and activate  json_file=${delta_XN_HO_target}  connection=GNB_OAM_1  gnb_index=1
    ...  string_1=${MRBTS_ID_1}  string_2=${NRBTS_ID_1}

NG-based_Intra-frequency_successful_handover
    scf.Modify json file and activate  json_file=${delta_NG_HO_intra_source}
    scf.Modify json file and activate  json_file=${delta_NG_HO_target}  connection=GNB_OAM_1  gnb_index=1
    ...  string_1=${MRBTS_ID_1}  string_2=${NRBTS_ID_1}
    Connect to gnb coam via ssl
    Intra-frequency_successful_handover  check_counter=M55186C00007  meas=${M55186}  normal_counter=${SMENP_counter_intra}
    ...  abnormal_counter=${SMENP_counter_no}  no_update_counter=${M55149_counter_NG_intra}
    ...  no_update_meas=${M55149}  GBR=${False}
    [Teardown]  Run Keywords  scf.Modify json file and activate    json_file=${delta_XN_HO_intra_source}
    ...  AND  scf.Modify json file and activate  json_file=${delta_XN_HO_target}  connection=GNB_OAM_1  gnb_index=1
    ...  string_1=${MRBTS_ID_1}  string_2=${NRBTS_ID_1}

Intra-gNB_Inter-frequency_successful_handover
    ${check_time}  Inter-frequency_successful_handover  check_counter=M55184C00011  meas=${M55184}  normal_counter=${SMAGP_counter_inter}
    ...  abnormal_counter=${SMAGP_counter_inter_no}  no_update_counter=${M55149_counter_intra_intre}
    ...  no_update_meas=${M55149}  inter_gnb=${False}
    Check Counter normal or abnormal  counter=${PTHPQ_counter}  flag=normal  counter_object=${NPRMQAP-1_cell_14}
    ...  counter_groups=${check_time}  meas=${M55363}
    Check Counter normal or abnormal  counter=${PTHPQ_counter}  flag=normal  counter_object=${NPRMQAP-1}
    ...  counter_groups=${check_time}  meas=${M55363}

Intra-gNB_Intra-frequency_successful_handover
    ${value_list}  Set Variable If  '${MRBTS_ID}'=='1921'  ${1921_intra_target}  ${1923_intra_target}
    ${recover_value_list}  Set Variable If  '${MRBTS_ID}'=='1921'  ${1921_inter_target}  ${1923_inter_target}
    Modify common json file and activate for different ENV  json_file=${delta_modify_intra_target}  old_string=${scf_value_list}
    ...  new_string=${value_list}
    Connect to gnb coam via ssl
    Wait Until Keyword Succeeds  70x  10s  Cell Should Be Unlocked  cell_group_idx=${13}  cell_idx=${13}
    Wait Until Keyword Succeeds  10x  10s  Cell Should Be Unlocked  cell_group_idx=${14}  cell_idx=${14}
    ${check_time}  Intra-frequency_successful_handover  check_counter=M55184C00015  meas=${M55184}  normal_counter=${SMAGP_counter_intra}
    ...  abnormal_counter=${SMAGP_counter_intra_no}  no_update_counter=${M55149_counter_intra_intra}
    ...  no_update_meas=${M55149}  inter_gnb=${False}  GBR=${False}
    Check Counter normal or abnormal  counter=${PTHPQ_counter}  flag=normal  counter_object=${NPRMQAP-1_cell_14}
    ...  counter_groups=${check_time}  meas=${M55363}
    Check Counter normal or abnormal  counter=${PTHPQ_counter}  flag=normal  counter_object=${NPRMQAP-1}
    ...  counter_groups=${check_time}  meas=${M55363}
    [Teardown]  Run keywords  Modify common json file and activate for different ENV  json_file=${delta_recover_intra_target}
    ...  old_string=${scf_value_list}  new_string=${recover_value_list}
    ...  AND  Connect to gnb coam via ssl
    ...  AND  Wait Until Keyword Succeeds  70x  10s  Cell Should Be Unlocked  cell_group_idx=${13}  cell_idx=${13}
    ...  AND  Wait Until Keyword Succeeds  10x  10s  Cell Should Be Unlocked  cell_group_idx=${14}  cell_idx=${14}

Suite Case D Setup
    Suite Case19 Setup
    CI_interface.Common Suite Setup  gnb_index=1
    Connect to gnb coam via ssl  gnb_index=1  connection=GNB_OAM_1
    Get nr cell id mapping  connection=GNB_OAM_1  gnb_index=1
    ${cell_1}  Get physical Cell Id Via Index  index=3
    set suite variable  ${cell_1}

Suite Case19 Setup
  CI_interface.Common Suite Setup
  Suite Case Setup
  attenuator.setup_attenuator    attenuator=${tl.attenuator}    alias=HBTE
  Run Keyword And Ignore Error  Modify attenuator value by port   modify_value=${127}  port=1    ru_id=1
  Run Keyword And Ignore Error  Modify attenuator value by port   modify_value=${127}  port=0    ru_id=1
  Run Keyword And Ignore Error  Modify attenuator value by port   modify_value=${0}  port=0    ru_id=0
  Run Keyword And Ignore Error  Modify attenuator value by port   modify_value=${127}  port=1    ru_id=0
    Connect to gnb coam via ssl
    Get nr cell id mapping
    ${cell_2}  Get physical Cell Id Via Index  index=13
    ${cell_3}  Get physical Cell Id Via Index  index=14
    set suite variable  ${cell_2}
    set suite variable  ${cell_3}

Check M55149 M55328 M55352 M55159 counters
  [Arguments]  ${check_time}  ${flag1}=normal  ${flag2}=normal  ${NPRMQAP-id}=${NPRMQAP-1}  ${slice-id}=${slice-1}  ${flag3}=normal
  Run Keyword If  '${flag1}'=='no'  Check No Counter value  counter_groups=${check_time}
  ...  counter_object=${slice-id}  counter=${M55149_activation}  meas=${M55149}
  ...  ELSE  Check Counter normal or abnormal  counter=${M55149_activation}  flag=${flag1}  counter_object=${slice-id}
  ...  counter_groups=${check_time}  meas=${M55149}
  Run Keyword If  '${flag3}'=='no'  Check No Counter value  counter_groups=${check_time}
  ...  counter_object=${slice-id}  counter=${M55328_counter}  meas=${M55328}
  ...  ELSE  Check Counter normal or abnormal  counter=${M55328_counter}  flag=${flag3}  counter_object=${slice-id}
  ...  counter_groups=${check_time}  meas=${M55328}
  Check Counter normal or abnormal  counter=${PDCPQ_counter}  flag=${flag2}  counter_object=${NPRMQAP-id}
  ...  counter_groups=${check_time}  meas=${M55352}
  Check Counter normal or abnormal  counter=${M55159_counter}  flag=${flag2}  counter_object=${NPRMQAP-id}
  ...  counter_groups=${check_time}  meas=${M55159}

Online activation of CB008828 with PM counters
  scf.scf uploading and commissioning  Log_directory=${CURDIR}/config/scf_files  SCF_Filename=Disabled_CB008828_scf.xml
  Connect to gnb coam via ssl
  ${5Grach_ed}  Attach real UE
  Run Keyword And Continue On Failure  Verify attach and Check Throughput  5Grach_ed=${5Grach_ed}
  ${check_time}  Get Check time  NPRMQAP-id=${slice-1}  counter=M55149C00022  meas=${M55149}
  Check M55149 M55328 M55352 M55159 counters  check_time=${check_time}
  Activate 8828
#  scf.Modify json file and activate  json_file=${delta_activate_8828}
  Wait For Next Raw Pm Interval
  Connect to gnb coam via ssl
  Attach real UE  ue_index=${1}  dl_port=${ue1_dl_port}  ul_port=${ue1_ul_port}
  ${check_time_1}  Get Check time  NPRMQAP-id=${NPRMQAP-6}  counter=M55352C02003  meas=${M55352}
  ${status}  run keyword and return status  Should Contain Any  ${stream}  SBTS25R1
  ${flag3}  Set Variable If  ${status}  normal  no
  Log  flag3=${flag3}
  Check M55149 M55328 M55352 M55159 counters  check_time=${check_time_1}  flag1=no  flag3=no
  Check M55149 M55328 M55352 M55159 counters  check_time=${check_time_1}  flag1=no  flag3=${flag3}  NPRMQAP-id=${NPRMQAP-6}  slice-id=${slice-21}
  [Teardown]  Run Keywords  Dettach UE and Stop traffic  ue_index=${1}  iperf_port=${ue1_dl_port}
  ...  AND  Run Keyword And Ignore Error   Dettach UE and Stop traffic  ue_index=${0}
#   ...  AND  CI_interface.Common Suite Setup

Activate 8828
    [Arguments]  ${connection}=GNB_OAM     ${should_activate}=${True}     ${skip_parameter_relation_errors}=True
    Log to console          Activate 8828.
    Initialise delta store
    ${nrbts_path}       Set variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ${nrpmqap_path}     Set variable    ${nrbts_path}/NRPMRNL-1/NRPMQAP-6
    ${snssai_path}      Set variable    ${nrbts_path}/SNSSAI-21
    ${trackingarea_path}       Set variable    ${nrbts_path}/TRACKINGAREA-20200
    Add List Parameters To Delta  ${trackingarea_path}    snssaiList      snssaiDN=${nrbts_path}/SNSSAI-1
    ...    snssaiDNLast=${nrbts_path}/SNSSAI-21
    add managed object and parameter to delta  ${nrpmqap_path}  actCplaneCounters=true
    Add List Parameters To Delta  ${nrpmqap_path}    snssaiList      snssaiDN=SNSSAI-21
    Add Parameters To Delta  ${nrpmqap_path}    actUPlaneGroup1Counters=true    actUPlaneGroup2Counters=true
    ...    cfgProfType=SA    rlcAmSduDlDelayThresh=2000    cfg5qiRange=7    thpHistDownlinkMaxRange=1000000
    ...    thpHistDownlinkMinRange=100    thpHistScale=linear    thpHistUplinkMaxRange=100000
    ...    thpHistUplinkMinRange=100    cfgUECategoryFR1=All UEs    cfgUECategoryFR2=All UEs
    ${result}    run keyword and return status    should contain any    ${stream}    25R1    25R2
    run keyword if  not ${result}    Add List Parameters To Delta  ${nrpmqap_path}    cfgLatencyCounters
    ...    actPerDelayCounters=false    ranDelayHistDlMaxRange=51    ranDelayHistDlMinRange=1
    ...    ranDelayHistUlMaxRange=51    ranDelayHistUlMinRange=1
    add managed object and parameter to delta  ${snssai_path}  administrativeState=Unlocked
    Add Parameters To Delta  ${snssai_path}    sd=13714341    sst=1
    ${nrPlmnDNList}  create list  NRPLMN-2
    Add param to delta  ${snssai_path}    nrPlmnDNList      value=${nrPlmnDNList}
    Add param to delta  ${nrbts_path}    actSliceNumExt       value=true
    ${delta}                Collect delta store
    coam.Perform Delta Recommissioning       connection=${connection}       delta_file=${delta}
    ...                     should_activate=${should_activate}
    ...                     skip_parameter_relation_errors=${skip_parameter_relation_errors}

