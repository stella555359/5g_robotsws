*** Settings ***

Library  taf.selenium.sbts  WITH NAME  selenium_coam
Library           OperatingSystem
Library           Collections
Library           String
Library           BuiltIn
Library           taf.transport.ssh    WITH NAME    csn
Library           random
Library           taf.config.scf    WITH NAME    scf
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/scf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/admin_sbts.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/android_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
Resource    ${BASIC_PATH_5G}/OAM_KPI_61a_SiSo_Auto_BTS_site_reset.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Auto_BTS_site_reset.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/Common/Manual_SiSo_CM_Recommissioning.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/siso_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/LTE/Manual_SiSo_SM_LTE_RAT_reset.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/outsides/AP_resources/AP_resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/UEs/nokia_fastmile.robot

Documentation
...    author: Chen Xu
...    contact: xu.2.chen@nokia-sbell.com
...    Group: HGZ_SG5

*** Variables ***
${MRBTS_ID}    ${tl.gnbs[0].instance_id}
${NRBTS_ID}    ${tl.gnbs[0].global_bts_id}
${GNB_PATH}    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
${dist_name}    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/BBADM-1
${ue_type}    nokia_fastmile
${PATH_Storage}    /home/ute/CB009471
${ENB_PATH}  MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].global_bts_id}
${UL_TP}                       5
${UL_TP_THRESHOLD}              5
${DL_TP}                       5
${DL_TP_THRESHOLD}              5
&{fault_6450}       faultId=${6450}
&{fault_4527}       faultId=${4527}
&{fault_6327}       faultId=${6327}
&{fault_61652}       faultId=${61652}
&{fault_61524}       faultId=${61524}
&{fault_4654}       faultId=${4654}
&{fault_4655}       faultId=${4655}
&{fault_7319}       faultId=${7319}
&{fault_7300}       faultId=${7300}
@{ALLOWED_FAULT}    &{fault_61652}    &{fault_61524}  &{fault_4654}    &{fault_4655}  &{fault_7319}  &{fault_7300}  &{fault_6450}

${unit_name}    MRBTS-${MRBTS_ID}/EQM_R-1/APEQM_R-1/CABINET_R-1
@{bbpool_array}    ${dist_name}/BBPOOL-11  ${dist_name}/BBPOOL-12

@{cell_SA_list_1}  61  62  63  64  65  66  67  68  59  510  511  512  69  610  611  612
@{cell_SA_list_2}  49  410  411  412  51  52  53  54  55  56  57  58  25  26
@{cell_SA_list_3}  9  27  28
@{cell_SA_list_4}  41  42  43  44  45  46  47  48
@{cell_SA_list_5}  19  32  33  34  35
@{cell_SA_list_6}  24  30  31
@{cell_SA_list_7}  20  21  22  23  29
@{cell_SA_list_8}  1  2  3  4  5  6  36
@{cell_SA_list_9}  13  14  15  16  17  18
@{cell_SA_list_10}  7  8  10  11  12


${MAX_LOOP}   1
&{dict_flags}  0x10041=5

*** Keywords ***

Test Case Setup
    [Arguments]     ${case_name}
    ${TS_CASE_LOG_PATH}    catenate     SEPARATOR=/    ${PATH_Storage}    ${case_name}
    Set Test Variable    ${TS_CASE_LOG_PATH}
    Run keyword And Ignore Error  Remove Directory  ${TS_CASE_LOG_PATH}  recursive=True
    Run Keyword And Continue On Failure  create directory  ${PATH_Storage}
    Run Keyword And Continue On Failure  create directory  ${PATH_Storage}/${case_name}
    robot_common_operations.Common Case Setup
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    ${onair_status}    Run keyword and Return Status    COAM Check GNB cell on air
    ${exist_fault}    coam_gnb_classical.COAM Get active alarms
    Set test variable    ${exist_fault}
    #Run keyword If    ${onair_status}==${False}    Perform BTS Site Reset
    #COAM Wait for gnb ready and cell setup    timeout=20 min
    Set Suite Variable  ${CASE_LOG_PATH}  ${TS_CASE_LOG_PATH}


Test Case Teardown
    [Arguments]    ${protocol}=udp  ${direction}=both
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    Run keyword And Ignore Error    Run Keyword If Test Failed    COAM Save snapshot via rest api  timeout=900
    Run Keyword And Continue On Failure  Unexpect Alarm Should Not Exist  allowed_faults=${exist_fault}  file_path=${TS_CASE_LOG_PATH}
    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master
    run keyword and ignore error    COAM Teardown gnb connections
    Run Keyword If Test Passed  Run keyword And Ignore Error  Remove Directory  ${TS_CASE_LOG_PATH}  recursive=True
    robot_common_operations.Common Case Teardown

Suite Case Setup
    Run Keyword And Ignore Error    coam.teardown
    log to console    Common Suite Setup
    #CI_interface.Common Suite Setup   ##load scf   
    robot_common_operations.Common Suite Setup  
    log to console  Get Active SW Version
    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    set suite variable      ${Active_SW_version}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    set suite variable      ${stream}
    ${count_bbmods}  Get BBMOD Num
    set suite variable  ${count_bbmods}
    ${gNb_CuType}   Get gNB CU type
    set suite variable      ${gNb_CuType}
    #Set cell barred flag for all special cell  cell_type=NR  barred_value=barred


Suite Case Teardown
    robot_common_operations.Common Suite Teardown
    log to console    Suite Case Teardown
    #CI_interface.Common Suite Setup    ##load SCF

Receiver 5G19-A Attach and Start traffic
    ${scf_file}  CB009471_W_keyword.Get real SCF From BTS
    Set Test Variable  ${scf_file}

    power_ue.Prepare UE      ue_index=${0}    ue_type=${ue_type}
    FOR  ${cell_id}  IN  @{cell_SA_list_1}
        Connect to gnb coam via ssl
        Run Keyword And Continue On Failure  5G Receiver Attach cell  cell_id=${cell_id}  ue_index=${0}
    END
    power_ue.Prepare UE      ue_index=${1}    ue_type=${ue_type}
    FOR  ${cell_id}  IN  @{cell_SA_list_2}
        Connect to gnb coam via ssl
        Run Keyword And Continue On Failure  5G Receiver Attach cell  cell_id=${cell_id}  ue_index=${1}
    END
    power_ue.Prepare UE      ue_index=${2}    ue_type=${ue_type}
    FOR  ${cell_id}  IN  @{cell_SA_list_3}
        Connect to gnb coam via ssl
        Run Keyword And Continue On Failure  5G Receiver Attach cell  cell_id=${cell_id}  ue_index=${2}
    END
    power_ue.Prepare UE      ue_index=${3}    ue_type=${ue_type}
    FOR  ${cell_id}  IN  @{cell_SA_list_4}
        Connect to gnb coam via ssl
        Run Keyword And Continue On Failure  5G Receiver Attach cell  cell_id=${cell_id}  ue_index=${3}
    END
    power_ue.Prepare UE      ue_index=${4}    ue_type=${ue_type}
    FOR  ${cell_id}  IN  @{cell_SA_list_5}
        Connect to gnb coam via ssl
        Run Keyword And Continue On Failure  5G Receiver Attach cell  cell_id=${cell_id}  ue_index=${4}
    END
    power_ue.Prepare UE      ue_index=${5}    ue_type=${ue_type}
    FOR  ${cell_id}  IN  @{cell_SA_list_6}
        Connect to gnb coam via ssl
        Run Keyword And Continue On Failure  5G Receiver Attach cell  cell_id=${cell_id}  ue_index=${5}
    END
    power_ue.Prepare UE      ue_index=${6}    ue_type=${ue_type}
    FOR  ${cell_id}  IN  @{cell_SA_list_7}
        Connect to gnb coam via ssl
        Run Keyword And Continue On Failure  5G Receiver Attach cell  cell_id=${cell_id}  ue_index=${6}
    END
    power_ue.Prepare UE      ue_index=${7}    ue_type=${ue_type}
    FOR  ${cell_id}  IN  @{cell_SA_list_8}
        Connect to gnb coam via ssl
        Run Keyword And Continue On Failure  5G Receiver Attach cell  cell_id=${cell_id}  ue_index=${7}
    END
    power_ue.Prepare UE      ue_index=${8}    ue_type=${ue_type}
    FOR  ${cell_id}  IN  @{cell_SA_list_9}
        Connect to gnb coam via ssl
        Run Keyword And Continue On Failure  5G Receiver Attach cell  cell_id=${cell_id}  ue_index=${8}
    END
    power_ue.Prepare UE      ue_index=${9}    ue_type=${ue_type}
    FOR  ${cell_id}  IN  @{cell_SA_list_10}
        Connect to gnb coam via ssl
        Run Keyword And Continue On Failure  5G Receiver Attach cell  cell_id=${cell_id}  ue_index=${9}
    END


5G Receiver Attach cell
    [Arguments]  ${cell_id}=0  ${ue_index}=${0}
    ${pci}    scf.get_value_from_scf    dist_name=${GNB_PATH}/NRCELL-${cell_id}    p_name=physCellId
    ${arfcnSsbPbch}    scf.get_value_from_scf    dist_name=${GNB_PATH}/NRCELL-${cell_id}    p_name=arfcnSsbPbch
    #${BandNR}    scf.get_value_from_scf    dist_name=${GNB_PATH}/NRCELL-${cell_id}    p_name=freqBandIndicatorNR
    nokia_fastmile.Modify UE Capatibility  ue_index=${ue_index}  pci=${pci}    arfcn=${arfcnSsbPbch}
    Wait Until Keyword Succeeds    2x    5s  UE Attach and Start traffic  physCellId=${pci}  ue_index=${ue_index}    cell_id=${cell_id}

Get real SCF From BTS
    [Arguments]  ${sub_scf_dir}=tmp_scf  ${config_type}=configurationAndRuntimeObjects
    Log To Console  Get SCF From BTS
    ${local_dir}    Set Variable     ${TS_CASE_LOG_PATH}/${sub_scf_dir}
    Create Directory    ${local_dir}
    ${current_time}    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S%f
    ${scf_file_path}     Set Variable    ${local_dir}/scf_${current_time}.xml
    coam.get_current_scf_file    local_dir_path=${local_dir}    file_name=scf_${current_time}.xml
    ...    timeout=240    connection=GNB_OAM    export_type=${config_type}
    scf.load_scf    file_path=${scf_file_path}
    [Return]   ${scf_file_path}


Get 5G Receiver IP
    [Arguments]    ${ue_index}=${0}
    ${ue_info}    ute_ue.get_ue_info  ue_alias=UE_${ue_index}
    ${ue_ipaddr}    get from dictionary    ${ue_info}    ip
    Set test variable    ${ue_ipaddr}
    [Return]   ${ue_ipaddr}

Ping UE and Verify
    [Arguments]     ${ipaddr}
    ...    ${hostname}=${tl.appserver.iperf_details.ssh_connection_details.addr}
    ...    ${username}=${tl.appserver.iperf_details.ssh_connection_details.username}
    ...    ${password}=${tl.appserver.iperf_details.ssh_connection_details.password}
    ...    ${alias}=APPserver
    Wait Until Keyword Succeeds    1 min    10 sec    csn.Connect to
    ...    hostname=${hostname}    username=${username}    password=${password}    alias=${alias}
    ${pingcommand}=    Set variable    ping -c 10 ${ipaddr} | grep loss
    ${output_from_appserver}  csn.Execute  command=${pingcommand}  connection=APPserver
    ${pinglost}=    Get Regexp Matches      ${output_from_appserver}   [0123456789.]{1,7}%
    should be equal as strings      ${pinglost[0]}    0%
    [Teardown]  csn.Disconnect  connection=APPserver


UE Attach and Start traffic
    [Arguments]     ${4G_check_needed}=False    ${duration}=300    ${attach_mode}=5G_SA
    ...    ${physCellId}=${physical_0}    ${ue_index}=${0}    ${iperf_port}=default
    ...    ${actCarrierAggregation}=${False}  ${cell_id}=${attach_cell_id}

    log to console  UE Attach and Start traffic
    ${5Grach_ed}     power_ue.UE Attach     ue_type=${ue_type}    ue_index=${ue_index}  pci=${physCellId}

    Get 5G Receiver IP    ue_index=${ue_index}
    Ping UE and Verify    ipaddr=${ue_ipaddr}

    [Teardown]    Run Keywords  Run Keyword And Ignore Error  Receiver Dettach and Stop Traffic    ue_index=${ue_index}
	...    AND  Run Keyword And Ignore Error  COAM Teardown gnb connections

Receiver Dettach and Stop Traffic
    [Arguments]    ${protocol}=udp    ${ue_index}=${0}
    Log To Console    \n UE Dettach and Stop traffic
    power_ue.UE Detach     ue_type=${ue_type}    ue_index=${ue_index}
    #power_ue.Stop traffic    direction=ul    ue_index=${ue_index}    ue_type=${ue_type}
    #power_ue.Stop traffic    direction=dl    ue_index=${ue_index}    ue_type=${ue_type}


Get BBMOD Num
    ${hw_info}    coam.get_detected_hw_info    connection=GNB_OAM    timeout=${600}
    @{list_bbmods}    Set variable    ${hw_info['basebandModules']}
    ${count_bbmods}    Get length    ${list_bbmods}
    Should be true    ${count_bbmods}>=${3}    msg=Check BBMOD status failed as total BBMOD number is less than 1
    [Return]   ${count_bbmods}


9471_Manual_SiSo_SM_NR_RAT_reset
    [Arguments]      ${range_time}=${1}
    Log To Console  Manual_SiSo_SM_NR_RAT_reset
    Connect to gnb coam via ssl
    FOR	   ${i}    IN RANGE    ${range_time}
        Wait until keyword succeeds    5min    60s    Check all NR cells should be onair
        coam.rat_reset       rat_type=NR     timeout=900    connection=GNB_OAM    reset_type=Hard
        Log To Console  Hard NR RAT Reset Round_${i} Done, wait cell onair
        Sleep    120s
        Wait until keyword succeeds    20min    90s    Check all NR cells should be onair
        Wait Until Keyword Succeeds    10min    60s    COAM Check X2 link status from GNB
        Run Keyword And Continue On Failure  Unexpect Alarm Should Not Exist  allowed_faults=${exist_fault}    timeout=60
        Sleep    60s
    END
    FOR	   ${i}    IN RANGE    ${range_time}
        Wait until keyword succeeds    5min    60s    Check all NR cells should be onair
        coam.rat_reset       rat_type=NR     timeout=900    connection=GNB_OAM    reset_type=Soft
        Log To Console  Soft NR RAT Reset Round_${i} Done, wait cell onair
        Sleep    120s
        Wait until keyword succeeds    20min    90s    Check all NR cells should be onair
        Wait Until Keyword Succeeds    10min    60s    COAM Check X2 link status from GNB
        Run Keyword And Continue On Failure  Unexpect Alarm Should Not Exist  allowed_faults=${exist_fault}    timeout=60
        Sleep    60s
    END
    Receiver 5G19-A Attach and Start traffic


9471_Manual_SiSo_SM_BTS_Site_Reset
    [Arguments]      ${range_time}=${1}
    Connect to gnb coam via ssl
    FOR	   ${i}    IN RANGE    ${range_time}
        #Selenium Logout And Close Browser
        #Perform BTS Site Reset
        Log To Console  BTS_Reset_Round_${i}
        coam.reset_site       timeout=900    connection=GNB_OAM    wait_for_reconnection=True
        sleep    120s
        Connect to gnb coam via ssl
        Wait Until Keyword Succeeds    20min    90s    Check all NR cells should be onair
        Wait Until Keyword Succeeds    10min    60s    COAM Check X2 link status from GNB
        Run Keyword And Continue On Failure  Unexpect Alarm Should Not Exist  allowed_faults=${exist_fault}    timeout=60
        csn.reset_cache
        Sleep    90s
    END
    Receiver 5G19-A Attach and Start traffic


9471_General_SiSo_Cell_block_and_unblock
    [Arguments]      ${range_time}=${5}
    Connect to gnb coam via ssl
    Wait until keyword succeeds    5min    60s    Check all NR cells should be onair
    FOR	   ${i}    IN RANGE    ${range_time}
        coam.block_all_cells  rat=NR  timeout=360  connection=GNB_OAM
        Sleep    30s
        coam.unblock_all_cells  rat=NR  timeout=360  connection=GNB_OAM
        Wait Until Keyword Succeeds    20min    90s    Check all NR cells should be onair
        Wait Until Keyword Succeeds    10min    60s    COAM Check X2 link status from GNB
        Run Keyword And Continue On Failure  Unexpect Alarm Should Not Exist  allowed_faults=${exist_fault}    timeout=60
    END
    Receiver 5G19-A Attach and Start traffic
    [Teardown]  run keyword and ignore error    COAM Teardown gnb connections



Check all NR cells should be onair
    [Arguments]    ${connection}=GNB_OAM    ${timeout}=900
    Log to console    Check all NR cells should be onair
    ${nr_cells_info}   coam.get_cells_info  cell_type=nr    timeout=${timeout}    connection=${connection}
    FOR    ${cell}    IN    @{nr_cells_info}
        Should Be Equal As Strings    ${cell['status']['operationalState'].lower()}   enabled
        Should Be Equal As Strings    ${cell['status']['administrativeState'].lower()}     unlocked
        Should Be Equal As Strings    ${cell['status']['blockingState'].lower()}   unblocked
    END
