*** Settings ***

Library  taf.selenium.sbts  WITH NAME  selenium_coam
Library           OperatingSystem
Library           Collections
Library           String
Library           BuiltIn
Library           taf.transport.ssh    WITH NAME    csn
# Library            random
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/scf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/android_ue.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/admin_sbts.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
# Resource    ${BASIC_PATH_5G}/OAM_KPI_61a_SiSo_Auto_BTS_site_reset.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_Auto_BTS_site_reset.robot
Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/Common/Manual_SiSo_CM_Recommissioning.robot
Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/siso_common_keywords.robot
# Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/LTE/Manual_SiSo_SM_LTE_RAT_reset.robot


Documentation
...    author: Liqin Yang
...    contact: liqin.yang@nokia-sbell.com
...    Group: HGZ_SG5

*** Variables ***
${MRBTS_ID}                           ${tl.gnbs[0].instance_id}
${NRBTS_ID}    ${tl.gnbs[0].global_bts_id}
${GNB_PATH}    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
${dist_name}    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1
${ue_type_0}  xiaomi
${ue_type_1}  samsung
${ue_type_2}  nokia_fastmile
${ue_type_3}  nokia_fastmile
${PATH_Storage}    /home/ute/CB009471
${ENB_PATH}  MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].global_bts_id}
${UL_TP}                       50M
${UL_TP_THRESHOLD}              1
${DL_TP}                       300M
${DL_TP_THRESHOLD}              1
&{fault_6450}       faultId=${6450}
&{fault_4527}       faultId=${4527}
&{fault_6327}       faultId=${6327}
&{fault_61652}       faultId=${61652}
&{fault_61524}       faultId=${61524}
&{fault_4654}       faultId=${4654}
&{fault_4655}       faultId=${4655}
&{fault_7319}       faultId=${7319}
&{fault_7300}       faultId=${7300}
&{fault_4590}       faultId=${4590}
@{ALLOWED_FAULT}    &{fault_61652}    &{fault_61524}  &{fault_4654}    &{fault_4655}  &{fault_7319}  &{fault_7300}  &{fault_6450}
@{ALLOWED_FAULT1}    &{fault_4590}


# @{1930_n3_SA_cell}  21  22  23  33  14  15  16  17  18  19  110  111  112  113  114  115  36  116
@{1930_n3_SA_cell}  21  23  14  15  16  17  18  19  110  111  112  113  114  115  36
@{1930_n78_SA_cell}  11
@{1930_NSA_cell}  24  25  26  27  28  29

# @{1930_LTE_cell}  34  35  36  37  38  39
@{1930_LTE_cell}  34  35  37

@{1931_n3_SA_cell}  52  13  21  22  14
@{1931_n78_SA_cell}  11  12  24  25  26  31  32  33  51  61
@{1931_LTE_cell_S22}  41  42
@{1931_LTE_cell}  23
# @{1931_other_cell}  51  52  53  54  55  56  57  58

&{1931_NSA}  23=11
&{1930_NSA}  24=11  25=12  26=34  27=35  28=31  29=32
${MAX_LOOP}   1
# &{dict_flags}  0x10041=5
*** Keywords ***

Test Case Setup
    [Arguments]     ${case_name}
    ${TS_CASE_LOG_PATH}    catenate     SEPARATOR=/    ${PATH_Storage}    ${case_name}
    Set Test Variable    ${TS_CASE_LOG_PATH}
    Run keyword And Ignore Error  Remove Directory  ${TS_CASE_LOG_PATH}  recursive=True
    Run Keyword And Continue On Failure  create directory  ${PATH_Storage}
    Run Keyword And Continue On Failure  create directory  ${PATH_Storage}/${case_name}
    robot_common_operations.Common Case Setup
    Run Keyword And Ignore Error  COAM Teardown gnb connections
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    ${onair_status}    Run keyword and Return Status    COAM Check GNB cell on air
    ${exist_fault}    coam_gnb_classical.COAM Get active alarms
    Set test variable    ${exist_fault}
    #Run keyword If    ${onair_status}==${False}    Perform BTS Site Reset
    COAM Wait for gnb ready and cell setup    timeout=20 min
    Set Suite Variable  ${CASE_LOG_PATH}  ${TS_CASE_LOG_PATH}


Test Case Teardown

    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    Wait For Expect Fault To Disappear  faultId=4592    timeout=60
    Run Keyword And Continue On Failure  Unexpect Alarm Should Not Exist  allowed_faults=${exist_fault}  file_path=${TS_CASE_LOG_PATH}
    Run keyword And Ignore Error    Run Keyword If Test Failed    COAM Save snapshot via rest api  timeout=900
    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master
    run keyword and ignore error    COAM Teardown gnb connections
    Run Keyword If Test Passed  Run keyword And Ignore Error  Remove Directory  ${TS_CASE_LOG_PATH}  recursive=True
    robot_common_operations.Common Case Teardown

Suite Case Setup
    Run Keyword And Ignore Error    COAM Teardown gnb connections
    Run Keyword If  '${cpe}'=='False'  android_ue.Kill ADB application
    robot_common_operations.Common Suite Setup
    log to console    Common Suite Setup
    CI_interface.Common Suite Setup
    log to console  Get Active SW Version
    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    set suite variable      ${Active_SW_version}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    set suite variable      ${stream}
    ${count_bbmods}  Get BBMOD Num
    set suite variable  ${count_bbmods}
    Run Keyword If  ${cpe}  Run keywords  UE Prepare  ue_index=${2}
    ...  AND  UE Prepare  ue_index=${3}
    # ...  ELSE  Run keywords  UE Prepare  ue_index=${0}
    # ...  AND  UE Prepare  ue_index=${1}
    ${cell_n3_NR_list}  Set Variable If  ${count_bbmods}<${4}  ${1930_n3_SA_cell}  ${1931_n3_SA_cell}
    ${cell_n78_NR_list}  Set Variable If  ${count_bbmods}<${4}  ${1930_n78_SA_cell}  ${1931_n78_SA_cell}
    ${cell_LTE_list}  Set Variable If  ${count_bbmods}<${4}  ${1930_LTE_cell}  ${1931_LTE_cell}
    ${cell_NSA_list}  Set Variable If  ${count_bbmods}<${4}  ${1930_NSA_cell}  ${1931_LTE_cell_S22}
    Set Suite Variable  ${cell_n3_NR_list}
    Set Suite Variable  ${cell_n78_NR_list}
    Set Suite Variable  ${cell_LTE_list}
    Set Suite Variable  ${cell_NSA_list}
    ${cell_NR_list}  Combine Lists  ${cell_n3_NR_list}  ${cell_n78_NR_list}
    set suite variable  ${cell_NR_list}
    ${gNb_CuType}   Get gNB CU type
    set suite variable      ${gNb_CuType}
    ${scf_file}  scf.Get real SCF From BTS
    Set Suite Variable  ${scf_file}
    ${ue0}  Set Variable If  ${cpe}  ${2}  ${0}
    Set Suite Variable  ${ue0}
    ${ue1}  Set Variable If  ${cpe}  ${3}  ${1}
    Set Suite Variable  ${ue1}
    # Set cell barred flag for all special cell  cell_type=LTE  barred_value=barred
    # Set cell barred flag for all special cell  cell_type=NR  barred_value=barred
    # Set cell barred flag for all special cell  cell_type=NSA  barred_value=barred
#     Run Keyword If  ${count_bbmods}>${4}  Set cell barred flag for all special cell
#    ...  cell_type=NR  barred_value=barred  cell_list=${1931_other_cell}


Suite Case Teardown
    Check Alarm and stop robot testing when unexpected alarm raised
    robot_common_operations.Common Suite Teardown
    log to console    Suite Case Teardown
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    Run keyword if    '${SUITE STATUS}' == 'FAIL'    Run keyword and continue on failure
    ...    COAM Save snapshot via rest api  timeout=900    log_path=${PATH_Storage}
    run keyword and ignore error    COAM Teardown gnb connections


Set cell barred flag for all special cell
    [Arguments]  ${cell_type}=LTE  ${barred_value}=barred  ${parameter}=cellBarred  ${cell_list}=${cell_${cell_type}_list}
    Log To Console  Set ${parameter} to ${barred_value} for all ${cell_type} cell
    FOR    ${i}    IN    @{cell_list}
      Run Keyword If  '${cell_type}'!='NR'  scf.Activate Parameter Value
      ...    dist_name=${ENB_PATH}/LNCEL-${i}/SIB-0    p_name=${parameter}  new_value=${barred_value}
      ...  ELSE  scf.Activate Parameter Value
      ...  dist_name=${GNB_PATH}/NRCELL-${i}    p_name=${parameter}  new_value=${barred_value}
    END

Get BBMOD Num
    ${hw_info}    coam.get_detected_hw_info    connection=GNB_OAM
    @{list_bbmods}    Set variable    ${hw_info['basebandModules']}
    ${count_bbmods}    Get length    ${list_bbmods}
    Should be true    ${count_bbmods}>=${1}    msg=Check BBMOD status failed as total BBMOD number is less than 1
    [Return]   ${count_bbmods}

Make calls for all bbmods
    Run keyword If  '${cpe}'=='False'  UE Prepare  ue_index=${ue0}
    Run keyword If  ${cpe}  ute_ue.set_access_technology  UE_${ue0}  technology=NR5GSA  preferred=NR5GSA
    Make L3call for cells  cells_list=${cell_n3_NR_list}   attach_mode=SA  ue_index=${ue0}
    Run keyword If  ${cpe}  ute_ue.set_access_technology  UE_${ue0}  technology=LTE  preferred=LTE
    Make L3call for cells  cells_list=${cell_LTE_list}   attach_mode=LTE  ue_index=${ue0}
    Run keyword If  '${cpe}'=='False'  UE Prepare  ue_index=${ue1}
    Run keyword If  ${cpe}  ute_ue.set_access_technology  UE_${ue1}  technology=NR5GSA  preferred=NR5GSA
    Make L3call for cells  cells_list=${cell_n78_NR_list}   attach_mode=SA  ue_index=${ue1}
    Run Keyword If  ${count_bbmods}<${4}  Make L3call for cells  cells_list=${cell_NSA_list}   attach_mode=NSA  ue_index=${ue1}
    ...  ELSE  Make L3call for cells  cells_list=${cell_NSA_list}   attach_mode=LTE  ue_index=${ue1}

Make one call and detach
    [Arguments]  ${attach_mode}=SA  ${cell_id}=0  ${ue_index}=${0}
    Log To Console    Make one call and detach
    Run Keyword If    '${attach_mode}'=='SA'  Run Keywords  scf.Activate Parameter Value  dist_name=${GNB_PATH}/NRCELL-${cell_id}
    ...  p_name=cellBarred  new_value=notBarred
    ...  AND  Make one SA or NSA call and detach  cell_id=${cell_id}  ue_index=${ue_index}
    ...  ELSE IF  '${attach_mode}'=='NSA'  Run Keywords  scf.Activate Parameter Value  dist_name=${ENB_PATH}/LNCEL-${cell_id}/SIB-0
    ...  p_name=cellBarred  new_value=notBarred
    ...  AND  Make one SA or NSA call and detach  cell_id=${${MRBTS_ID}_NSA}[${cell_id}]  attach_mode=NSA  ue_index=${ue_index}
    ...  ELSE  Run Keywords  scf.Activate Parameter Value  dist_name=${ENB_PATH}/LNCEL-${cell_id}/SIB-0  p_name=cellBarred
    ...  new_value=notBarred
    ...  AND  Wait Until Keyword Succeeds    3x    10s
    ...  UE Attach 4G And Check Throughput Normal with wait  cell_id=${cell_id}
    ...  ue_index=${ue_index}
    [Teardown]  Run Keyword If  '${cpe}'=='${False}'  Make one call and detach teardown  attach_mode=${attach_mode}  cell_id=${cell_id}


Make one call and detach via 5G receiver
    [Arguments]  ${attach_mode}=SA  ${cell_id}=0  ${ue_index}=${0}
    Run Keyword If    '${attach_mode}'=='SA'  Make one SA call via 5G receiver  id=${cell_id}  ue_index=${ue_index}
    ...  ELSE  Make one LTE call via 5G receiver  id=${cell_id}  ue_index=${ue_index}

Make one SA call via 5G receiver
  [Arguments]  ${id}=0  ${ue_index}=${0}
#   ${pci}  Get Parameter Value from SCF  parameter=physCellId  dist_name=${GNB_PATH}/NRCELL-${id}  scf_file_path=${scf_file}
  Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
  ${arfcnSsbPbch}  Get Parameter Value from SCF  parameter=arfcnSsbPbch  dist_name=${GNB_PATH}/NRCELL-${id}  scf_file_path=${scf_file}
  nokia_fastmile.Modify UE Capatibility  ue_index=${ue_index}  pci=${id}    arfcn=${arfcnSsbPbch}
  Make one SA or NSA call and detach  cell_id=${id}  ue_index=${ue_index}

Make one LTE call via 5G receiver
  [Arguments]  ${id}=0  ${ue_index}=${0}
  Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
  ${cellTechnology}  Set Variable If  '${ue_index}'=='2'  FDD  TDD
  ${parameter}  Set Variable If  '${ue_index}'=='2'  earfcnDL  earfcn
  ${arfcnSsbPbch}  Get Parameter Value from SCF  parameter=${parameter}  dist_name=${ENB_PATH}/LNCEL-${id}/LNCEL_${cellTechnology}-0
  ...  scf_file_path=${scf_file}
  nokia_fastmile.Modify UE Capatibility  ue_index=${ue_index}  pci=${id}    arfcn=${arfcnSsbPbch}  mobile_network_system=LTE
#   Wait Until Keyword Succeeds    3x    10s
    UE Attach 4G And Check Throughput Normal with wait  cell_id=${id}
    ...  ue_index=${ue_index}

Make one call and detach teardown
  [Arguments]  ${attach_mode}=SA  ${cell_id}=0
  Log To Console    Make one call and detach teardown
  Run Keyword If    '${attach_mode}'=='SA'  scf.Activate Parameter Value  dist_name=${GNB_PATH}/NRCELL-${cell_id}  p_name=cellBarred
  ...  new_value=barred
  ...  ELSE  scf.Activate Parameter Value  dist_name=${ENB_PATH}/LNCEL-${cell_id}/SIB-0    p_name=cellBarred  new_value=barred

9471_Manual_SiSo_SM_BTS_Site_Reset
    [Arguments]      ${range_time}=${1}
    AlarmWatchdog.add_allow_alarms    fault_id=4592
    FOR	   ${i}    IN RANGE    ${range_time}
        Selenium Logout And Close Browser
        Perform BTS Site Reset
        sleep    60s
        Wait Until Keyword Succeeds  3x  20s  Connect to gnb coam via ssl
        Wait Until Keyword Succeeds  20min  30s  Check all cells info should be onair
        Wait Until Keyword Succeeds    10min    20 sec    COAM Check X2 link status from GNB
        csn.reset_cache
        Make calls for all bbmods
    END
    AlarmWatchdog.remove_allow_alarms    fault_id=4592
    [Teardown]    Selenium Logout And Close Browser

9471_OAM_KPI_61a_SiSo_Auto_BTS_site_reset
    [Arguments]    ${reset_times}=1
#    Selenium Login And Disable Screen Lock  version=${stream}
    Set Test Variable    ${fail_count}  0
    FOR    ${count}    IN RANGE    ${reset_times}
        ${status}    Run Keyword And Return Status  9471_Manual_SiSo_SM_BTS_Site_Reset  range_time=${1}
        ${fail_count}    Set Variable If    '${status}'=='False'    ${fail_count}+1    ${fail_count}
    END
    ${fail_rate}    Evaluate    float(${fail_count})/float(${reset_times})
    Should Be True    ${fail_rate}<=0.1
#    Selenium Logout And Close Browser



9471_General_SiSo_Cell_block_and_unblock
    [Arguments]  ${technology}=NR
   Connect to gnb coam via ssl
    Get X2 link shutdown waiting time
    # ${cell_type}    Convert To Lowercase    ${technology}
    ${tmp}  Set Variable If  '${technology}'=='NR'  SA  LTE
    Wait Until Keyword Succeeds  10min  30s  Check all cells info should be onair
#    Wait until keyword succeeds    5 min    20 sec   verify all cells should be onair  cell_type=${cell_type}
    Selenium Login And Disable Screen Lock  version=${stream}
    # ${cell_num}    get length  ${cell_${technology}_list}
    Run keyword If  '${cpe}'=='False'  UE Prepare  ue_index=${0}
    ...  ELSE  ute_ue.set_access_technology  UE_${ue0}  technology=NR5GSA  preferred=NR5GSA
    Block and UnBlock Cells and Make L3call  block_list=${cell_n3_NR_list}
    ...  technology=${technology}  attach_mode=${tmp}  ue_index=${ue0}
    Run keyword If  '${cpe}'=='False'  UE Prepare  ue_index=${1}
    ...  ELSE  ute_ue.set_access_technology  UE_${ue1}  technology=NR5GSA  preferred=NR5GSA
    Block and UnBlock Cells and Make L3call    block_list=${cell_n78_NR_list}
    ...  technology=${technology}  attach_mode=${tmp}  ue_index=${ue1}
    [Teardown]    Selenium Logout And Close Browser


9471_Manual_SiSo_SM_LTE Cell_block_unblock
  [Arguments]  ${technology}=LTE
   Connect to gnb coam via ssl
    Get X2 link shutdown waiting time
    # ${cell_type}    Convert To Lowercase    ${technology}
    Wait Until Keyword Succeeds  10min  30s  Check all cells info should be onair
#    Wait until keyword succeeds    5 min    20 sec   verify all cells should be onair  cell_type=${cell_type}
    Selenium Login And Disable Screen Lock  version=${stream}
    Run keyword If  '${cpe}'=='False'  UE Prepare  ue_index=${0}
    ...  ELSE  ute_ue.set_access_technology  UE_${ue0}  technology=LTE  preferred=LTE
    Block and UnBlock Cells and Make L3call    block_list=${cell_LTE_list}
    ...  technology=${technology}  attach_mode=LTE  ue_index=${ue0}
    Run keyword If  '${cpe}'=='False'  UE Prepare  ue_index=${1}
    ...  ELSE  ute_ue.set_access_technology  UE_${ue1}  technology=LTE  preferred=LTE
    Run Keyword If  ${count_bbmods}<${4}  Block and UnBlock Cells and Make L3call    block_list=${cell_NSA_list}
    ...  technology=LTE  attach_mode=NSA  ue_index=${ue1}
    Run Keyword If  ${count_bbmods}>=${4}  Block and UnBlock Cells and Make L3call    block_list=${cell_NSA_list}
    ...  technology=${technology}  attach_mode=LTE  ue_index=${ue1}
    [Teardown]    Selenium Logout And Close Browser


Block and UnBlock Cells and Make L3call
    [Arguments]  ${block_list}   ${technology}=NR  ${attach_mode}=SA  ${ue_index}=${0}
    ${block_num}    get length  ${block_list}
    FOR  ${block_id}  IN  @{block_list}
        ${check_alarm}  set variable if  ${block_num}==1  ${True}  ${False}
        ${check_cell}  create list  ${block_id}
        Run Keyword And Continue On Failure  Block cells and check status   block_list=${check_cell}   check_alarm=${check_alarm}
        ...  gnb_type='${gNb_CuType}'  technology=${technology}
        Run Keyword And Continue On Failure  UnBlock Cells and check status   block_list=${check_cell}   check_alarm=${check_alarm}
        ...  gnb_type='${gNb_CuType}'  technology=${technology}  timeout=120
        Run Keyword If  ${cpe}  Run Keyword And Continue On Failure  Make one call and detach via 5G receiver  attach_mode=${attach_mode}
        ...  cell_id=${block_id}  ue_index=${ue_index}
        ...  ELSE  Run Keyword And Continue On Failure  Make one call and detach  attach_mode=${attach_mode}
        ...  cell_id=${block_id}  ue_index=${ue_index}
    END

Make L3call for cells
    [Arguments]  ${cells_list}   ${attach_mode}=SA  ${ue_index}=${0}
    FOR  ${cell_id}  IN  @{cells_list}
        Run Keyword If  ${cpe}  Run Keyword And Continue On Failure  Make one call and detach via 5G receiver  attach_mode=${attach_mode}
        ...  cell_id=${cell_id}  ue_index=${ue_index}
        ...  ELSE  Run Keyword And Continue On Failure  Make one call and detach  attach_mode=${attach_mode}  cell_id=${cell_id}
        ...  ue_index=${ue_index}
    END

9471_Manual_SiSo_SM_NR_RAT_reset
    [Arguments]  ${call_keyword}=Make calls for all bbmods
    Log To Console  Manual_SiSo_SM_NR_RAT_reset
#    Connect to gnb coam via ssl
    Wait until keyword succeeds    5min    30s    Check all cells info should be onair
    coam.rat_reset       rat_type=NR     timeout=300    connection=GNB_OAM
    Sleep    120s
    Wait until keyword succeeds    20min    30s    Check all cells info should be onair
    Wait Until Keyword Succeeds    10min    20 sec    COAM Check X2 link status from GNB
    Run Keyword  ${call_keyword}

9471_Manual_SiSo_STARTUP_BTS_Power_Reset
    [Arguments]  ${times}=1  ${call_keyword}=Make calls for all bbmods
    Log To Console  Manual_SiSo_STARTUP_BTS_Power_Reset
    FOR	 ${i}    IN RANGE    ${times}
        Perform Site Power Off
        sleep    180s
        Perform Site Power On
        sleep    180s
        Connect to gnb coam via ssl
        Wait until keyword succeeds    20 min    20 sec   Check all cells info should be onair
        Wait Until Keyword Succeeds    10min    20 sec    COAM Check X2 link status from GNB
        csn.reset_cache
        Run Keyword  ${call_keyword}
    END
    ${exist_fault}  Combine Lists  ${exist_fault}  ${ALLOWED_FAULT1}
    Set test variable  ${exist_fault}

Make one SA or NSA call and detach
    [Arguments]  ${cell_id}  ${attach_mode}=SA  ${ul_tp}=100M  ${dl_tp}=300M  ${ue_index}=${0}
    Log To Console    UE${ue_index} make one ${attach_mode} call and detach for nrcell-${cell_id}
    Connect to gnb coam via ssl
    # Wait Until Keyword Succeeds    3x    10s
    UE Attach And Check Throughput With Detach bk
    ...    ul_tp=${ul_tp}    ul_tp_threshold=${UL_TP_THRESHOLD}    attach_mode=${attach_mode}
    ...    dl_tp=${dl_tp}    dl_tp_threshold=${DL_TP_THRESHOLD}
    ...    global_cell_id=${cell_id}  ue_index=${ue_index}
    [Teardown]  run keyword and ignore error    COAM Teardown gnb connections

UE Attach And Check Throughput With Detach bk
    [Documentation]  global_cell_id(Global cell ID): 1
    ...    ul_tp: 50M    ul_tp_threshold: 15
    ...    dl_tp: 300M    dl_tp_threshold: 220
    ...    [Return]    ul_tp: 20    dl_tp; 200
    [Arguments]    ${global_cell_id}    ${ul_tp}   ${ul_tp_threshold}
    ...    ${dl_tp}    ${dl_tp_threshold}    ${attach_mode}=SA    ${iperf_type}=via_command
    ...    ${ul_duration}=1200    ${dl_duration}=1200    ${ue_index}=${0}  ${ue_type}=${ue_type_${ue_index}}
    Log To Console  ${attach_mode} UE${ue_index} Attach And Check Throughput With Detach for nrcell-${global_cell_id}
    ${nr_cell_identity}    Get NR Cell Identity Via Index "${global_cell_id}"
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}  timeout=${900}  power_reset=${True}
    Sleep    10s
    Run keyword If  '${cpe}'=='False'  Reboot UE If no UE IP  ue_index=${ue_index}
    ${iperf_type}  set variable if  '${ue_type}'=='huawei' or '${ue_type}'=='nokia_fastmile'  via_app  via_command
    Run Keyword If  '${attach_mode}'=='SA' and '${ue_index}'=='0' and '${cpe}'=='False'  Get nrCellIdentity for SA UE  nrCId=${nr_cell_identity}
    ...  ue_index=${ue_index}
    Run Keyword If    '${attach_mode}'=='NSA'  power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=True
    ...  ue_index=${ue_index}
    ...    ELSE    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False
    ...  ue_index=${ue_index}
    Run Keyword If    '${iperf_type}'=='via_command'    UE Start UL Traffic    throughput=${ul_tp}    ul_time=${ul_duration}
    ...    ul_port=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}  ue_index=${ue_index}
    ...    ELSE    power_ue.Start traffic   ue_type=${ue_type}   direction=ul   throughput=${ul_tp}    duration=${ul_duration}
    ...    ue_index=${ue_index}  iperf_type=${iperf_type}
    Run Keyword If  ${cpe}  power_ue.Start traffic  ue_type=${ue_type}  direction=dl  throughput=150M  duration=${duration}
    ...    ue_index=${ue_index}    iperf_type=via_command
    ...  ELSE  UE Start DL Traffic    throughput=${dl_tp}    dl_time=${dl_duration}    dl_port=${tl.ues[${ue_index}].iperf_details.port}
    ...    ue_index=${ue_index}
    Sleep    30s
    ${cell_list}  Create List  ${nr_cell_identity}
    ${log}    Run Keyword If  ${cpe}  power_ue.Collect Tput  check_source=Aasyslog  ue_type=${ue_type}    duration=2m  upload_duration=${True}
    ...  ELSE  power_ue.Collect Tput    ue_type=${ue_type}    duration=2m    filter=L2Lo  ue_index=${ue_index}
    ${all_tp}    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log}    cells=${cell_list}
    ...    ultarget_throughput=${ul_tp_threshold}    dltarget_throughput=${dl_tp_threshold}    actCarrierAggregation=${False}
    ...    min_percent=0
    # Run Keyword And Continue On Failure  power_ue.Check throughput    ue_index=${ue_index}    direction=ul    ue_type=${ue_type}
    # ...    throughput=${ul_tp_threshold}    cellid=${nr_cell_identity}
    # Run Keyword And Continue On Failure  power_ue.Check throughput   ue_index=${ue_index}    direction=dl    ue_type=${ue_type}
    # ...    throughput=${dl_tp_threshold}    cellid=${nr_cell_identity}
    [Teardown]    Run Keyword And Ignore Error   Dettach UE and Stop traffic  ue_index=${ue_index}

UE Attach 4G And Check Throughput Normal with wait
    [Arguments]    ${cell_id}    ${ue_index}=${0}

    ...    ${wait_time}=1min  ${ue_type}=${ue_type_${ue_index}}
    Log To Console  UE${ue_index} Attach 4G And Check Throughput Normal with wait for lncell-${cell_id}
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}  timeout=${900}
    Run Keyword If  '${ue_index}'=='0'  Run Keyword And Ignore Error  Get nrCellIdentity for SA UE  ${ue_index}=${ue_index}
    Run Keyword If  '${cpe}'=='False'  Wait Until Keyword Succeeds    ${wait_time}    10s    Verify 4G Attach by ADB Command    ${ue_index}
    ${ip_addr_ue}  Run Keyword If  '${cpe}'=='False'  traffic.Get UE IP Address  ue_index=${ue_index}
    ...  ELSE  Get UE IP Successfully  ue_index=${ue_index}
    ${pingres}=                        Do DL ping      ${ip_addr_ue}   numberofping=120    intervalofpings=1
    ${linelostping}=                   Get lines containing String     ${pingres}          packet loss
    Verify no ping lost                pingreport=${linelostping}
    ${linertt}=                        Get lines containing String     ${pingres}          min/avg/max/mdev
    ${refrtt}=                         Get average rtt                 pingreport=${linertt}
    [Teardown]  power_ue.UE Detach     ue_type=${ue_type}    ue_index=${ue_index}

Do DL ping
    [Arguments]     ${toipaddr}
    ...             ${intervalofpings}=5
    ...             ${numberofping}=25
    ${timeouttoused}=               Evaluate        ${numberofping} * ${intervalofpings} + 15
    Log                             \ntimeout : ${timeouttoused}
    ${commandtolaunch}=    Set variable
    ...        ping -c ${numberofping} -i ${intervalofpings} ${toipaddr} | grep -E 'loss|rtt'
    Log                             \nCommand to launch : ${commandtolaunch}
    Wait Until Keyword Succeeds  1 min  10 sec  traffic_via_iperf.Connect to APPserver
    ${output_from_remote}  csn.Execute  command=${commandtolaunch}  connection=APPserver
    ...    timeout=${timeouttoused} s
    Log                             \n${output_from_remote}
    [return]                        ${output_from_remote}
    [Teardown]  csn.Disconnect  connection=APPserver

Verify no ping lost
    [arguments]         ${pingreport}
    ${pinglost}=        Get Regexp Matches      ${pingreport}   [0123456789.]{1,7}%
    should be equal as strings      ${pinglost[0]}    0%

Get average rtt
    [Arguments]         ${pingreport}
    log                 \String to scan : ${pingreport}
    ${averagertt}       Get Regexp Matches      ${pingreport}   [0123456789]{1,4}\.[0123456789]{1,3}
    log                 \n${averagertt}         #formatter=repr
    [return]            ${averagertt[1]}

9471_Manual_SiSo_CM_Recommissioning

    scf.Activate Parameter Value  dist_name=${sync_dist_name}  p_name=${sync_abbr}  new_value=false
    Selenium Logout And Close Browser
    Selenium Login And Disable Screen Lock    version=${stream}
    wait until keyword succeeds    300      5  Connect to gnb coam via ssl
    Manual_SiSo_CM_Recommissioning  timeout=600
    [Teardown]  Run Keywords  run keyword and ignore error  Selenium Coam Logout And Close Browser
    ...  AND  scf.Activate Parameter Value  dist_name=${sync_dist_name}  p_name=${sync_abbr}
    ...     new_value=true
