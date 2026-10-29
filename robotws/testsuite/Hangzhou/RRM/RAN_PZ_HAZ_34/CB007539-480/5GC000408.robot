*** Settings ***
Documentation    author：Shanshan Zhang
...              contact: shanshan.zhang@nokia-sbell.com
...              squad group: mmw_SG_04

Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

Suite Setup       robot_common_operations.Common Suite Setup
Suite Teardown    robot_common_operations.Common Suite Teardown

*** Variables ***
${gNB_ip}                 ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${gNB_username}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${MR_BTS_NAME}            ${tl.gnbs[0].instance_id}
${NR_BTS_NAME}            ${tl.gnbs[0].global_bts_id}
#${4G_IP}                  ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
#${4G_MR_BTS}              ${tl.enbs[0].global_bts_id}
#${4G_NR_BTS}              ${tl.enbs[0].instance_id}
${Cycle_time}             ${5}
@{5G_RU_id_list_749}        ${3}
@{4G_RU_id_list_749}        ${1}
${5G_BTS_ID_749}            7502
${4G_BTS_ID_749}            10725
@{RU_lock_status}           Locked    enabled    Idle    configured
@{empty_list}

*** Test Cases ***
[1][1.0] 5GC000480-K_M55114C00008_PM_Counter
    [Tags]      CRT_22R4    CRT_TRUNK
    [Setup]    Case480 Setup
    Modify miNrRacCu parameter     btsip=${gNB_ip}
    Wait until cluster is on cell on air status    is_all_cells_checking_needed=${True}     is_x2_check_from_enb_needed=${False}
    Prepara UE for case   ue_index=${0}
    Prepara UE for case   ue_index=${1}
    Wait for counter to be gathered after guard peroid    Time_M=${0}    if_current_time=${True}

    ${UE1_attach}    attach power ue due to index    ue_index=${0}
    ${UE1_attach_time}    ${UE1_attach_time_M}    Get UE attach time of duration    5Grach_time=${UE1_attach}
    Wait for counter to be gathered after guard peroid    Time_M=${UE1_attach_time_M}    if_current_time=${False}
    ${UE1_attach1_counter1}    Get PM counter recently value    counter_id=M55114C00010
    ${UE1_attach1_counter2}    Get PM counter recently value    counter_id=M55114C00008
    ${counter2_diff1}    Evaluate    abs(${UE1_attach_time}-${UE1_attach1_counter2})
    run keyword and continue on failure     should be true    ${UE1_attach1_counter1}==1
    run keyword and continue on failure     should be true    ${counter2_diff1}<=2

    ${UE2_attach}    attach power ue due to index    ue_index=${1}
    ${UE2_attach_time}    ${UE2_attach_time_M}    Get UE attach time of duration    5Grach_time=${UE2_attach}
    Wait for counter to be gathered after guard peroid    Time_M=${UE2_attach_time_M}    if_current_time=${False}
    ${UE2_attach1_counter1}    Get PM counter recently value    counter_id=M55114C00010
    ${UE2_attach1_counter2}    Get PM counter recently value    counter_id=M55114C00008
    ${counter2_diff2}    Evaluate    abs(300+${UE2_attach_time}-${UE2_attach1_counter2})
    run keyword and continue on failure     should be true    ${UE2_attach1_counter1}==2
    run keyword and continue on failure     should be true    ${counter2_diff2}<=2

    Teardown the Aasyslog save progress    gnb_index=${0}    du_index=${0}
    Aasyslog precondition    gnb_index=${0}    du_index=${0}
    Start the Aasyslog save progress    gnb_index=${0}    du_index=${0}    filter=L2   log_name=detach1.txt
    sleep    30s
    power_ue.UE Detach    ue_index=${0}    ue_type=samsung
    sleep    30s
    Teardown the Aasyslog save progress    gnb_index=${0}    du_index=${0}
    ${UE1_detach}    Get 5GRACH release times on gnb side    filename=detach1.txt
    ${UE1_detach_time}    ${UE1_detach_time_M}    run keyword and continue on failure    Get UE attach time of duration
    ...    5Grach_time=${UE1_detach}
    ${UE1_attach_time1}    Evaluate    ${Cycle_time}*60-${UE1_detach_time}
    Wait for counter to be gathered after guard peroid    Time_M=${UE1_detach_time_M}    if_current_time=${False}
    ${UE1_detach1_counter1}    Get PM counter recently value    counter_id=M55114C00010
    ${UE1_detach1_counter2}    Get PM counter recently value    counter_id=M55114C00008
    ${counter2_diff3}    Evaluate    abs(${UE1_attach_time1}+300-${UE1_detach1_counter2})
    run keyword and continue on failure    run keyword if    ${UE1_attach_time1} > ${0}    should be true    ${UE1_detach1_counter1}==2
    ...    ELSE    should be true    ${UE1_detach1_counter1}==1
    run keyword and continue on failure     should be true    ${counter2_diff3}<=2

    Teardown the Aasyslog save progress    gnb_index=${0}    du_index=${0}
    Aasyslog precondition    gnb_index=${0}    du_index=${0}
    Start the Aasyslog save progress    gnb_index=${0}    du_index=${0}    filter=L2   log_name=detach2.txt
    sleep    30s
    power_ue.UE Detach    ue_index=${1}    ue_type=samsung
    sleep    30s
    Teardown the Aasyslog save progress    gnb_index=${0}    du_index=${0}
    ${UE2_detach}    Get 5GRACH release times on gnb side    filename=detach2.txt
    ${UE2_detach_time}    ${UE2_detach_time_M}    run keyword and continue on failure    Get UE attach time of duration
    ...    5Grach_time=${UE2_detach}
    ${UE2_attach_time1}    Evaluate    ${Cycle_time}*60-${UE2_detach_time}
    Wait for counter to be gathered after guard peroid    Time_M=${UE2_detach_time_M}    if_current_time=${False}
    ${UE2_detach1_counter1}    Get PM counter recently value    counter_id=M55114C00010
    ${UE2_detach1_counter2}    Get PM counter recently value    counter_id=M55114C00008
    ${counter2_diff4}    Evaluate    abs(${UE2_attach_time1}-${UE2_detach1_counter2})
    run keyword and continue on failure    run keyword if    ${UE2_attach_time1} > ${0}    should be true    ${UE2_detach1_counter1}==1
    ...    ELSE    should be true    ${UE2_detach1_counter1}==0
    run keyword and continue on failure     should be true    ${counter2_diff4}<=2

    Wait for counter to be gathered after guard peroid    Time_M=${0}    if_current_time=${True}
    ${UE2_detach2_counter1}    Get PM counter recently value    counter_id=M55114C00010
    ${UE2_detach2_counter2}    Get PM counter recently value    counter_id=M55114C00008
    run keyword and continue on failure    should be true    ${UE2_detach2_counter1}==0
    run keyword and continue on failure    should be true    ${UE2_detach2_counter2}==0
    [Teardown]  case teardown


*** Keywords ***
#change 4G configuration
#    [Arguments]      ${value}=${8}
#    Connect to gnb coam via ssl    bts_host=${4G_IP}    username=${gNB_username}    password=${gNB_password}    connection=4G_admin
#    coam.Perform Parameter Recommissioning
#    ...    dist_name=MRBTS-${4G_MR_BTS}/LNBTS-${4G_NR_BTS}/LNCEL-1
#    ...    parameter=defaultLnRelGnbCellId
#    ...    value=${value}
#    ...    operation=update
#    ...    connection=4G_admin
#    ...    should_activate=${True}
#    COAM Teardown gnb connections     connection=4G_admin

Modify miNrRacCu parameter
    [Arguments]    ${btsip}=${gNB_ip}    ${connection}=GNB_OAM
    log to console    Modify parameter
    Connect to gnb coam via ssl     bts_host=${btsip}      connection=${connection}
    coam.Perform Parameter Recommissioning    dist_name=MRBTS-${MR_BTS_NAME}/NRBTS-${NR_BTS_NAME}/NRPMRNL-1
    ...    parameter=miNrRacCu     value=5min
    ...    operation=update    skip_parameter_relation_errors=${False}    should_activate=${True}    connection=${connection}
    coam.Perform Parameter Recommissioning    dist_name=MRBTS-${MR_BTS_NAME}/NRBTS-${NR_BTS_NAME}/NRCELL-1
    ...    parameter=ccLoadThreshold     value=100
    ...    operation=update    skip_parameter_relation_errors=${False}    should_activate=${True}    connection=${connection}
    log to console  change parameter successful
    [Teardown]    COAM Teardown gnb connections    connection=${connection}

Get PM counter value sum
    [Arguments]    ${counter_id}    ${btsip}=${gNB_ip}    ${BTS}=BTS    ${CELLS}=CELLS
    ...    ${NRCELL}=NRCELL-5    ${counter_object}=RACCU    ${connection}=GNB_OAM    ${timeout}=600s
    sleep  1min
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    connection=${connection}
    ${counter_values}    coam.get pm counters    counter_ids=${counter_id}    connection=${connection}   timeout=${timeout}
    ${result}    Get Dictionary Values   ${counter_values['${BTS}']['${CELLS}']['${NRCELL}']['${counter_object}']['${counter_id}']}
    ${length}      Get Length       ${result}
    ${counter_value_sum}       Set Variable          0
    FOR   ${i}    IN RANGE    ${0}    ${length}     1
        ${counter_value_sum}     Evaluate    ${counter_value_sum}+${result}[${i}]
    END
    [Return]    ${counter_value_sum}
    [Teardown]      COAM Teardown gnb connections   connection=${connection}

Check Release Larged Than Given
    [Arguments]    ${release}=24R1    ${gnb_index}=${0}    ${connection}=GNB_OAM
    ${Y_given_string}=    Get SubString    ${release}    0    2
    ${R_given_string}=    Get SubString    ${release}    3    4
    ${Y_given}    Evaluate    int(${Y_given_string})
    ${R_given}    Evaluate    int(${R_given_string})
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${software}    coam.get_software_info    connection=${connection}
    ${activate_version}    Set Variable    ${software}[Active SW version]
    ${Y_active_string}=    Get SubString    ${activate_version}    4    6
    ${R_active_string}=    Get SubString    ${activate_version}    7    8
    ${Y_active}    Evaluate    int(${Y_active_string})
    ${R_active}    Evaluate    int(${R_active_string})
    ${Is_large}    Set variable if    ${Y_active}>${Y_given}    ${True}
    ...    ${Y_active}==${Y_given} and ${R_active}>${R_given}    ${True}    ${False}
    [Return]    ${Is_large}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections  connection=${connection}


Get PM counter recently value
    [Arguments]    ${counter_id}    ${btsip}=${gNB_ip}    ${BTS}=BTS    ${CELLS}=CELLS
    ...    ${NRCELL}=NRCELL-1    ${counter_object}=RACCU    ${connection}=GNB_OAM    ${timeout}=600s
    sleep  1min
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    connection=${connection}
    ${counter_values}    coam.get pm counters    counter_ids=${counter_id}    connection=${connection}   timeout=${timeout}
    ${MR_BTS}    set variable    MRBTS-${tl.gnbs[${0}].instance_id}
    ${NR_BTS}    set variable    NRBTS-${tl.gnbs[${0}].global_bts_id}
    ${is_large_24R1_release}    Check Release Larged Than Given    release=24R1    gnb_index=${0}
    ${result}    run keyword if    ${is_large_24R1_release}
    ...    Get Dictionary Values   ${counter_values['${BTS}']['${MR_BTS}']['${NR_BTS}']['${NRCELL}']['${counter_object}']['${counter_id}']}
    ...    ELSE    Get Dictionary Values   ${counter_values['${BTS}']['${CELLS}']['${NRCELL}']['${counter_object}']['${counter_id}']}
    ${length}      Get Length       ${result}
    ${recently_value}    Set Variable If    ${length}!=0    ${result}[-1]    ${0}
    [Return]    ${recently_value}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections   connection=${connection}

attach power ue due to index
    [Arguments]    ${ue_index}   ${gnb_index}=${0}
    log to console       Prepare UE
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=samsung
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    attach_mode=5G_NSA   ue_type=samsung
    power_ue.Verify attach    ue_type=samsung    ue_index=${ue_index}   5Grach_ed=${5Grach_ed_0}    4G_check=False
    ${5Grach_ing}    ${5Grach_time_ing}    Get 5Grach attach time    hwcheck_index=${5Grach_ed_0[2]}     log_type=${5Grach_ed_0[3]}
    [Return]   ${5Grach_time_ing}

Prepara UE for case
    [Arguments]   ${ue_index}
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=samsung
    power_ue.UE Detach    ue_index=${ue_index}    ue_type=samsung

PM Wait To Nearest Measurement Period
   Log    PM Wait To Nearest Measurement Period    console=yes
   [Arguments]  ${interval}
   Wait Until Keyword Succeeds                     16 min
   ...                                            1 min
   ...                                             Wait For Right Period    interval=${interval}

Wait For Right Period
   [Arguments]  ${interval}
   ${list1}=           Create List         00  15  30  45
   ${list2}=           Create List         00  05  10  15  20  25  30  35  40  45  50  55
   ${list}=            Set Variable IF     '${interval}' == '5'    ${list2}    ${list1}
   ${actualTime}=     DateTime.Get Current Date    result_format=%M
   ...                                    time_zone=UTC
   ...                                    increment=8 hours
   ${actualHour}=     DateTime.Get Current Date    result_format=%H
   ...                                    time_zone=UTC
    ...                                    increment=8 hours
   ${date}=     DateTime.Get Current Date    result_format=%Y-%m-%d
   ...                                    time_zone=UTC
   ...                                    increment=8 hours
   ${date_nodash}=    DateTime.Get Current Date    result_format=%Y%m%d
   ...                                    time_zone=UTC
   ${actualEpoch}=    DateTime.Convert Date	       ${date} ${actualHour}:${actualTime}:00.000	epoch
   List Should Contain Value	           ${list}  ${actualTime}
   Log                                    ${actualTime}
   ${string_epoch}=   Convert To String   ${actualEpoch}
   ${nopoint_epoch}=   fetch from left   ${string_epoch}   .
   ${integer_epoch}=   convert to integer  ${nopoint_epoch}
   ${epoch_minus_interval}=   Evaluate   ${integer_epoch}-15*60
   ${epoch_minus_interval_string}=   Convert To String   ${epoch_minus_interval}
   set test variable    ${epoch_minus_interval_string}

Wait for counter to be gathered after guard peroid
   [Arguments]  ${Time_M}    ${if_current_time}=${False}    ${interval}=5
   ${list1}=    Create List         00  15  30  45
   ${list2}=    Create List         00  05  10  15  20  25  30  35  40  45  50  55
   ${list}=    Set Variable IF     '${interval}' == '5'    ${list2}    ${list1}
   ${actualTime}=     DateTime.Get Current Date    result_format=%M
   ...                                    time_zone=UTC
   ${actualTime_M}    Set Variable IF    ${if_current_time}    ${actualTime}    ${Time_M}
   ${time_check}    run keyword and return status   List Should Contain Value    ${list}    '${actualTime_M}'
   run keyword if    ${time_check}   Sleep   ${interval} minutes
   PM Wait To Nearest Measurement Period    interval=${interval}

case teardown
#    run keyword and ignore error    Prepara UE for case   ue_index=${1}
#    run keyword and ignore error    Prepara UE for case   ue_index=${2}
    run keyword and ignore error    COAM Teardown gnb connections
    CI_interface.Common Case Teardown
    robot_common_operations.Common Case Teardown

Get 5Grach attach time
    [Arguments]  ${gnb_index}=${0}    ${hwcheck_index}=${1}    ${log_type}=Aasyslog   ${log_loca}=l2lo
    ${5Grach_ing}    ${5Grach_time_ing}    Get 5GRACH success times on gnb side    gnb_index=${gnb_index}
    ...                                                                            hwcheck_index=${hwcheck_index}
    ...                                                                            log_type=${log_type}
    ...                                                                            log_loca=${log_loca}
    [Return]  ${5Grach_ing}    ${5Grach_time_ing}

Get UE attach time of duration
    [Arguments]  ${5Grach_time}    ${interval}=5
    ${list1}=    Create List         0  15  30  45
    ${list2}=    Create List         0  5  10  15  20  25  30  35  40  45  50  55
    ${list}=     Set Variable IF     '${interval}' == '5'    ${list2}    ${list1}
    ${5Grach_time_list}    split string     ${5Grach_time}[0]    .
    ${attach_time}    set variable    ${5Grach_time_list}[0]
    ${attach_time_list}     split string     ${attach_time}    :
    ${attach_time_M}     Evaluate    int('${attach_time_list}[1]')
    ${end_time_M}    set variable    ${0}
    ${list_length}    get length    ${list}
    ${list_length_for_range}     Evaluate    ${list_length}-1
    FOR   ${i}    IN RANGE   ${list_length_for_range}
        ${end_time_M}    Run keyword if   ${list}[${i}]<=${attach_time_M}<${list}[${i+1}]
        ...    set variable    ${list}[${i}]
        ...    ELSE IF   ${attach_time_M}>=${list}[${list_length_for_range}]     set variable    ${list}[${list_length_for_range}]
        Exit for loop if   '${end_time_M}'!='None'
    END
    log to console        ${end_time_M}
    ${attach_time_S}     Evaluate    int('${attach_time_list}[2]')
    ${duration_time}     Evaluate      ${interval}*60-((${attach_time_M}-${end_time_M})*60+${attach_time_S})
    log to console        ${duration_time}
    [Return]    ${duration_time}    ${attach_time_M}

Get 5GRACH release times on gnb side
    [Documentation]  This keyword help to check the 5G RACH status in gnb side
    ...  :param gnb_index is index for which gnb prepare to attach
    ...  :param du_index is index for which du prepare to attach
    ...  :param hwcheck_index is index for which HW try to check 5grach status, ex: 0->ASIK 1>ABIL1 2->ABIL2 3->ABIL3
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}    ${hwcheck_index}=${1}    ${log_type}=Aasyslog
    ...    ${log_loca}=l2lo    ${filename}=detach.txt
    ${host}   Get Mplane IP from gNB   gnb_index=${gnb_index}   du_index=${du_index}
    wait until keyword succeeds    1 min    10 sec    csn.Connect to
    ...    hostname=${host}
    ...    username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    alias=ASIK
    ${Aal2lo_cmd}=    catenate    cat /tmp/${filename} | grep -a "cause:RELEASE" | grep -av grep
    ${output} =    csn.execute    command=${Aal2lo_cmd}    connection=ASIK
    run keyword and ignore error    csn.disconnect    connection=ASIK
    @{list}    split string    ${output}    \n
    Remove Values From List    ${list}   ${empty}
    ${len}    Get Length    ${list}
    ${last_line}    Run keyword if    ${len}>0    Get From List    ${list}    0
    ${rach_time}    Run keyword if    ${len}>0    Get Regexp Matches    ${last_line}    \\d{2}\\:\\d{2}\\:\\d{2}\\.[\\d|\\w]*
    [Return]   ${rach_time}

Set default SCF
    [Arguments]    ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    separator=_
    ${if_common_load}     run keyword and return status    should contain    ${version_list[2]}    9999
    ${version_scf}    set variable if    ${if_common_load}    SBTS00    ${version_list[0]}
    Set Suite Variable    ${CURDIR_path}    ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}
    ${default_scf_path}    set variable    ${CURDIR_path}/SCF_${version_scf}.xml
    set suite variable    ${default_scf_path}
    log to console   ${default_scf_path}
    [Teardown]     Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Setup Commission SCF
    [Arguments]   ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM
    Set default SCF    bts_host=${bts_host}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    COAM Commission with scf file    scf_file_path=${default_scf_path}    connection=${connection}    timeout=1000
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Check GNB on air
    [Timeout]    20 min
    [Arguments]  ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    Wait Until Keyword Succeeds    20min    20s    COAM Check GNB cell on air    connection=${connection}
    Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=${connection}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Case480 Setup
    [Arguments]
    robot_common_operations.Common case Setup
    Setup Commission SCF
    sleep    7min
    Check GNB on air
    Determine whether to lock based on RU status    lock_ru_list=${5G_RU_id_list_749}    bts_host=10.71.215.244    BTS_ID=${5G_BTS_ID_749}
    Determine whether to lock based on RU status    lock_ru_list=${4G_RU_id_list_749}    bts_host=10.71.215.243    BTS_ID=${4G_BTS_ID_749}

Determine whether to lock based on RU status
    [Arguments]    ${lock_ru_list}    ${bts_host}    ${BTS_ID}    ${ru_expect_status}=${RU_lock_status}
    ${lock_ru_status}    Create Dictionary
    @{tmp_ru_list}    create list
    FOR    ${ru_id}    IN    @{lock_ru_list}
        APPEND TO LIST    ${tmp_ru_list}    ${ru_id}
        Set To Dictionary    ${lock_ru_status}    RMOD-${ru_id}    ${ru_expect_status}
    END
    ${status_list}    Check All RU or Cell Status    expect_item_status_dict=${lock_ru_status}    if_ru=${True}    bts_host=${bts_host}
    ${length}    Get length    ${lock_ru_list}
    FOR    ${item}   IN RANGE    ${length}
        Run Keyword If    ${status_list}[${item}] == ${True}    Remove Values From List     ${lock_ru_list}    ${tmp_ru_list}[${item}]
        log to console    ${tmp_ru_list}
    END
    Lock or Unlock RU And Check Status    lock_RU_id_list=${lock_ru_list}     lock_flag=${True}    bts_host=${bts_host}    BTS_ID=${BTS_ID}

Check All RU or Cell Status
    [Documentation]  expect_item_status_dict eg:
    ...              1) ${cell_status_dict}    Create Dictionary     NRCELL-1=${Cell_unblock_status}    NRCELL-2=${Cell_block_status}
    ...              2) ${ru_status_dict}    Create Dictionary     RMOD-1=${RU_unlock_status}    RMOD-2=${RU_lock_status}
    [Arguments]  ${expect_item_status_dict}    ${if_ru}=${True}   ${bts_host}=${gnb_ip}
    Log To Console    Check All RU or Cell Status
    ${item_status_dic}    Get All RU or Cell Status    if_ru=${if_ru}    bts_host=${bts_host}    connection=GNB_OAM
    @{item_id_list}    get dictionary keys    ${expect_item_status_dict}
    @{status_list}    create list
    FOR  ${item_id}  IN  @{item_id_list}
        ${expect_status_list}     get from dictionary    ${expect_item_status_dict}    ${item_id}
        ${item_status}    set variable    ${item_status_dic['${item_id}']}
        ${status}    run keyword and return status
        ...    Run Keyword If    ${if_ru}    Check Single RU Status    item_status=${item_status}    expect_status_list=${expect_status_list}
        ...    ELSE    Check Single Cell Status    item_status=${item_status}    expect_status_list=${expect_status_list}
        append to list    ${status_list}    ${status}
    END
    [Return]  ${status_list}

Check Single RU Status
    [Arguments]  ${item_status}    ${expect_status_list}
    ${admin_status}    get from dictionary    ${item_status}    administrativeState
    Run Keyword And Continue On Failure    should be equal as strings   ${admin_status}    ${expect_status_list[${0}]}
    ${operate_status}    get from dictionary    ${item_status}    operationalState
    Run Keyword And Continue On Failure    should be equal as strings    ${operate_status}    ${expect_status_list[${1}]}
    ${usage_status}    get from dictionary    ${item_status}    usageState
    Run Keyword And Continue On Failure    should be equal as strings    ${usage_status}    ${expect_status_list[${2}]}
    ${procedure_status}    get from dictionary    ${item_status}    proceduralStatus
    Run Keyword And Continue On Failure    should be equal as strings    ${procedure_status}    ${expect_status_list[${3}]}

Check Single Cell Status
    [Arguments]  ${item_status}    ${expect_status_list}
    Check Single RU Status    item_status=${item_status}    expect_status_list=${expect_status_list}
    ${block_status}    get from dictionary    ${item_status}    blockingState
    Run Keyword And Continue On Failure    should be equal as strings   ${block_status}    ${expect_status_list[${-1}]}

Get All RU or Cell Status
    [Arguments]  ${if_ru}=${True}    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
    Log to console    Get All RU or Cell Status
    ${item_status_dic}    Create Dictionary
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${ru_info_list}    coam.get_frm    connection=${connection}
    ${cell_info_list}     coam.Get_Cells_Info   cell_type=nr    connection=${connection}
    ${item_info_list}    set variable if    ${if_ru}    ${ru_info_list}    ${cell_info_list}
    ${count_item}    Get Length    ${item_info_list}
    FOR  ${item}  IN RANGE   ${count_item}
        ${item_id_info}  Split String  ${item_info_list[${item}]['id']['configuration']}  separator=/
        ${item_id}    set variable    ${item_id_info[-1]}
        ${item_status}    set variable    ${item_info_list[${item}]['status']}
        set to dictionary    ${item_status_dic}    ${item_id}=${item_status}
    END
    [Return]  ${item_status_dic}
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Lock or Unlock RU And Check Status
    [Arguments]  ${BTS_ID}   ${lock_RU_id_list}=${empty_list}     ${unlock_RU_id_list}=${empty_list}    ${lock_flag}=${True}   ${bts_host}=${gnb_ip}
    ${operate_ru_id_list}    Set Variable If    ${lock_flag}    ${lock_RU_id_list}    ${unlock_RU_id_list}
    Lock or UnLock Multiple RU    RMOD_id_list=${operate_ru_id_list}    lock_flag=${lock_flag}    bts_host=${bts_host}    BTS_ID=${BTS_ID}
    ${expect_item_status_dict}    create dictionary
    FOR  ${item}  IN    @{lock_RU_id_list}
        Set to dictionary    ${expect_item_status_dict}    RMOD-${item}=${RU_lock_status}
    END
    FOR  ${item1}  IN   @{unlock_RU_id_list}
        Set to dictionary    ${expect_item_status_dict}    RMOD-${item1}=${RU_unlock_status}
    END
    Check All RU or Cell Status    expect_item_status_dict=${expect_item_status_dict}    if_ru=${True}    bts_host=${bts_host}

Lock or UnLock Multiple RU
    [Arguments]    ${RMOD_id_list}   ${BTS_ID}    ${lock_flag}=${True}    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM    ${timeout}=60
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    FOR  ${RMOD_id}  IN  @{RMOD_id_list}
        ${dist_name}    Set Variable    MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${RMOD_id}
        Run keyword if    ${lock_flag}==${True}    Log To Console    Lock RMOD-${RMOD_id}
        ...    ELSE    Log To Console    UnLock RMOD-${RMOD_id}
        Run keyword if    ${lock_flag}==${True}    coam.lock    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
        ...    ELSE    coam.unlock    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
        sleep    8s
    END
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
