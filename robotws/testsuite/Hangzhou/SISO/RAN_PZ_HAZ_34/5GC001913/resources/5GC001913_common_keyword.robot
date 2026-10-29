*** Settings ***
Documentation    author：Hongyu Jiang
...              contact: hongyu.jiang@nokia-sbell.com
...              squad group: mmw_SG_04

Library           taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library           taf.pdu    WITH NAME    pdu
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_cu.robot

*** Keywords ***
Case Teardown
    [Arguments]  ${ue_num}    ${protocol}    ${if_ul}    ${if_dl}
    stop multi power ue traffic ul and dl    ue_num=${ue_num}    protocol=${protocol}    if_ul=${if_ul}    if_dl=${if_dl}
    Run Keyword And Ignore Error    Recover the test ENV
    CI_interface.Common Case Teardown

Recover the test ENV
    [Arguments]    ${ue_num}=${1}
    detach multi power ue    ue_num=${ue_num}
    COAM Teardown gnb connections

Input need scf for DL
    [Timeout]  20 min
    [Arguments]    ${timeout}=10 min
    ${conn}    Connect to DU
    BuiltIn.Log    \n Input need scf for DL \n    console=yes
    COAM Commission with scf file    scf_file_path=${1913_default_scf}    connection=${conn}
    BuiltIn.Log    \n wait until gnb cell on air \n    console=yes
    wait until keyword succeeds    ${timeout}    30sec   Cloud DU connect to gnb coam via ssl    connection=${conn}
    wait until keyword succeeds    ${timeout}    30sec   COAM Check GNB cell on air    connection=${conn}
    [Teardown]    Disconnect from DU

Connect to DU
    [Arguments]    ${alias}=cOAM_admin
    ${conn}=    admin_cli.connect_to   bts_host=${DU_IP}   username=${WEBUI_USER}    password=${WEBUI_PASSWORD}    name=${alias}
    [Return]    ${conn}

Disconnect from DU
    [Arguments]    ${alias}=cOAM_admin
    admin_cli.teardown     connection=${alias}

attach multi power ue
    [Arguments]    ${ue_num}
    log to console       Prepare UE
    FOR    ${item}    IN RANGE    ${ue_num}
         ${status}    run keyword and return status    power ue attach again    ${item}
         run keyword if  not ${status}    power ue attach again    ${item}
    END

power ue attach again
    [Arguments]    ${ue_index}
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=samsung
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=samsung    log_type=Aasyslog
    power_ue.Verify attach    ue_type=samsung   5Grach_ed=${5Grach_ed_0}    4G_check=False


start multi power ue traffic ul and dl
    [Arguments]    ${ue_num}    ${ul_throughput}=${None}    ${dl_throughput}=${None}    ${ul_duration}=6000    ${dl_duration}=6000    ${protocol}=udp
    ...    ${if_ul}=${True}    ${if_dl}=${True}
    log to console      Start traffic    console=yes
    FOR    ${item}    IN RANGE    ${ue_num}
          run keyword and continue on failure    run keyword if     ${if_ul}    power_ue.Start traffic    ue_index=${item}   duration=${ul_duration}
          ...    direction=ul    throughput=${ul_throughput}   iperf_type=via_command    protocol=${protocol}    iperf_port=${ue_power_port}
          ...    ue_type=samsung
          sleep    1s
          run keyword and continue on failure    run keyword if    ${if_dl}    power_ue.Start traffic    ue_index=${item}    direction=dl
          ...    throughput=${dl_throughput}    duration=${dl_duration}    ue_type=samsung    protocol=${protocol}    iperf_port=${ue_power_port}
          ...    ue_type=samsung
    END

Get peak and ave throughput and return result
    [Documentation]    Get ul and dl peak and ave throughput and return result.
    ...    :param aasys_start_flag: for short time captrue use default, for long time call use ${False}, EG:${true}/${False}
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${aasys_start_flag}=${true}    ${if_ul}=${False}    ${if_dl}=${False}
    ${cell_number}    Get cell numbers in gnb    gnb_index=${gnb_index}    du_index=${du_index}
    run keyword if    '${aasys_start_flag}'=='${true}'    AAsys log captrue    gnb_index=${gnb_index}    du_index=${du_index}
    ${cell_id}    Get nrcellid from aasys log    gnb_index=${gnb_index}    du_index=${du_index}
    ${dl_traffic_data}    ${ul_traffic_data}    Get traffic data from aasys log    gnb_index=${gnb_index}    du_index=${du_index}
    ${dl_traffic_data}    split_traffic_data_string    data=${dl_traffic_data}
    ${ul_traffic_data}    split_traffic_data_string    data=${ul_traffic_data}
    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    run keyword if    ${if_dl}    Calculate Throughput and retrun result in gnb
    ...    data=${dl_traffic_data}    cell_numbers=${cell_number}
    ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}    run keyword if    ${if_ul}    Calculate Throughput and retrun result in gnb
    ...    data=${ul_traffic_data}    cell_numbers=${cell_number}
    [Return]    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}

Check BTS Should Be Normal
    [Arguments]  ${timeout}=10 min    ${connection}=GNB_OAM
    wait until keyword succeeds    ${timeout}    30sec   Cloud DU connect to gnb coam via ssl    connection=${connection}
    wait until keyword succeeds    ${timeout}    30sec   COAM Check GNB cell on air    connection=${connection}
    [Teardown]  Disconnect from DU     alias=${connection}

Step1: Perform RU Power Off
    log to console    \n Step1: Perform RAU Power Off
    Perform RU Power Off    ru_index=1    model=${pb_model_ru}
    5GC001913_common_keyword.Du login page via webUI
    Check RU Disabled
    [Teardown]  run keyword and ignore error    selenium_coam.logout

Du login page via webUI
    [Documentation]  Author: Tian Chun
    ...              Description: If case failed, the snapshot from webUI will be stored in the folder
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${DU_IP}
    ...                    username=${WEBUI_USER}
    ...                    password=${WEBUI_PASSWORD}
    selenium_coam.disable_message_box

Check RU Disabled
    [Arguments]    ${ru_index}=${1}
    ${is_startup_window_exist}=    Run Keyword And Ignore Error    selenium_coam.start_up_view_window_exists
    Run Keyword If    '${is_startup_window_exist[0]}'=='PASS'    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${output_tmp}    selenium_coam.get_ru_info    ru_index=${ru_index}
    ${RU_info}    set variable    ${output_tmp}[Status]
    should match regexp    ${RU_info}[Operational state]    Disabled
    Check RU Alarm Info

Check RU Alarm Info
    Wait Until Keyword Succeeds    15min    10s    Check Alarm Info

Check Alarm Info
    @{alarms}    selenium_coam.get_active_alarm_info    timeout=${100}
    sleep    1s
    log     ${alarms}
    ${fault_id_list}    create list
    ${fault_name_list}    create list
    FOR    ${item}    IN    @{alarms}
        ${fault_id}    get from dictionary    ${item}    Fault ID
        ${fault_name}    get from dictionary    ${item}    Fault name
        append to list    ${fault_id_list}    ${fault_id}
        append to list    ${fault_name_list}    ${fault_name}
    END
    list should contain value     ${fault_id_list}    10
    list should contain value     ${fault_name_list}    No connection to unit


Step2: Check BTS not Reset Site
    [Arguments]  ${connection}=GNB_OAM
    log to console    \n Step2: Check BTS not Reset Site
    Check ASOD is UP
    ${led_ASOD}    run keyword and ignore error       Check Given ASOD Led State    asod=1
    run keyword and ignore error    selenium_coam.logout
    should be equal   ${led_ASOD[1]}   Online
    Check ASOD is OK    connection=${connection}
    [Teardown]  run keyword and ignore error    Disconnect from DU    alias=${connection}

Check ASOD is UP
    run keyword and ignore error    5GC001913_common_keyword.Du login page via webUI
    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear

Check Given ASOD Led State
    [Arguments]    ${asod}
    ${ASOD_state}       selenium_coam.get_led_status_of_an_unit     unit=SMOD-${asod}
    Log to console      ASOD state: ${ASOD_state}
    [Return]            ${ASOD_state}

Check ASOD is OK
    [Documentation]  Author: Ding Binmei
    ...              Description: Wait until GNB status ready.
    [Timeout]  30 min
    [Arguments]  ${timeout}=10 min    ${connection}=GNB_OAM    ${gnb_type}='NSA'
    Cloud DU connect to gnb coam via ssl    connection=${connection}
    COAM Check GNB ASOD status    connection=${connection}

COAM Check GNB ASOD status
    [Documentation]  Author: Ding Binmei
    ...              Description: Support to check multiple ASODs
    [Arguments]    ${connection}=GNB_OAM
    Log to console    Check GNB ASOD status
    ${hw_info}    admin_cli.get_detected_hw_info    connection=${connection}
    @{list_asods}    Set variable    ${hw_info['systemModules']}
    ${count_asods}    Get length    ${list_asods}
    Should be true    ${count_asods}>=${1}    msg=Check ASOD status failed as total ASOD number is less than 1
    FOR  ${asod}  IN  @{list_asods}
         Run keyword and continue on failure    Should be equal as strings    ${asod['status']['administrativeState']}    Unlocked
                                      ...    msg=Current ASOD administrativeState is not in Unlocked status    ignore_case=${True}
          Run keyword and continue on failure    Should be equal as strings    ${asod['status']['operationalState']}    Enabled
                                      ...    msg=Current ASOD operationalState is not in Enabled status    ignore_case=${True}
         Run keyword and continue on failure    Should be equal as strings    ${asod['status']['proceduralStatus']}    configured
                                      ...    msg=Current ASOD proceduralStatus is not in configured status    ignore_case=${True}
         Run keyword and continue on failure    Should be equal as strings    ${asod['status']['availabilityStatus']}    Online
                                      ...    msg=Current ASOD availabilityStatus is not in Online status    ignore_case=${True}
    END

Step3: Perform RU Power On
    [Arguments]  ${connection}=cOAM_admin
    log to console    \n Step3: Perform RU Power On
    Perform RU Power On    ru_index=1        model=${pb_model_ru}
    Connect to DU    alias=${connection}
    Wait Until BTS Should Be Normal    alias=${connection}
    [Teardown]  run keyword and ignore error    Disconnect from DU     alias=${connection}

Wait Until BTS Should Be Normal
    [Arguments]   ${retry}=600s    ${retry_interval}=30s    ${alias}=cOAM_admin
    [Documentation]   Wait Until CBTS Status Should Be Normal, if CBTS status is abnormal during retry time,
    Wait Until Keyword Succeeds   ${retry}     ${retry_interval}    Gnb Cell Should Be Onair

Gnb Cell Should Be Onair
    [Arguments]  ${alias}=cOAM_admin  ${cell_type }=nr
    [Documentation]  Gnb Cell Should Be Onair, check method is via REST
    ${status}      admin_cli.Get_Bts_Statuses   connection=${alias}
    ${operationalState}    Get From Dictionary    ${status}    operationalState
    Should Be Equal As Strings    ${operationalState}    Enabled    ignore_case=${True}
    ${blockingState}   Get From Dictionary    ${status}    blockingState
    Should Be Equal As Strings    ${blockingState}    Unblocked    ignore_case=${True}
    ${proceduralState}   Get From Dictionary    ${status}   proceduralState
    Should Be Equal As Strings    ${proceduralState}    OnAir    ignore_case=${True}
    ${cell_status}     admin_cli.Get_Cells_Info   connection=${alias}    cell_type=${cell_type}
    ${Status}    Get From Dictionary    ${cell_status[0]}    status
    ${tmp}   Get From Dictionary    ${status}    operationalState
    Should Be Equal As Strings    ${tmp}    Enabled    ignore_case=${True}
    ${tmp}   Get From Dictionary    ${status}   availabilityStatus
#    Should Be Equal As Strings    ${tmp}    Online    ignore_case=${True}
    ${tmp}   Get From Dictionary    ${status}  administrativeState
    Should Be Equal As Strings   ${tmp}    Unlocked    ignore_case=${True}
    ${tmp}   Get From Dictionary    ${status}  blockingState
    Should Be Equal As Strings    ${tmp}    Unblocked    ignore_case=${True}
    ${tmp}   Get From Dictionary    ${status}  usageState
    Should Be Equal As Strings    ${tmp}    Active    ignore_case=${True}

Step1:Login and check
    Log To Console     Check BTS Should Be Normal
    Connect to DU    alias=cOAM_admin
    Wait Until BTS Should Be Normal
    [Teardown]     run keyword and ignore error    Disconnect from DU     alias=${connection}

Step2:PB off
    PB execution       pb_ip=${tl.pdus[0].addr}  pb_port=${tl.pdus[0].port_numbers[0]}   action=off
    PB execution       pb_ip=${tl.pdus[1].addr}  pb_port=${tl.pdus[1].port_numbers[0]}   action=off
    Sleep              10s

Step3:PB on
    PB execution       pb_ip=${tl.pdus[0].addr}  pb_port=${tl.pdus[0].port_numbers[0]}   action=on
    PB execution       pb_ip=${tl.pdus[1].addr}  pb_port=${tl.pdus[1].port_numbers[0]}   action=on
    Log To Console     Check BTS Should Be Normal
    Wait Until Keyword Succeeds     250   10   Connect to DU
    Wait Until BTS Should Be Normal

PB execution
    [Arguments]        ${pb_ip}   ${pb_port}   ${action}
    pdu.setup_pdu      model=${pb_model_ru}   host=${pb_ip}   alias=BBU
    Run Keyword        pdu.power_${action}   port=${pb_port}   pdu_device=BBU
    Set Suite Variable   ${pb_status}   ${action}


stop multi power ue traffic ul and dl
    [Arguments]    ${ue_num}    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}
    log to console     Stop traffic    console=yes
    FOR    ${item}    IN RANGE    ${ue_num}
         run keyword if    ${if_ul}    power_ue.Stop traffic    direction=ul    ue_index=${item}    ue_type=samsung    iperf_type=via_command
         ...    protocol=${protocol}    iperf_port=${ue_power_port}
         run keyword if    ${if_dl}    power_ue.Stop traffic    direction=dl    ue_index=${item}    ue_type=samsung    protocol=${protocol}
         ...    iperf_port=${ue_power_port}
    END

detach multi power ue
    [Arguments]    ${ue_num}=${1}
    log to console      UE Detach    console=yes
    FOR    ${item}    IN RANGE    ${ue_num}
          power_ue.UE Detach    ue_index=${item}    ue_type=samsung
    END

################### UTE Cloud ######################
Commission_CU_DU
    [Documentation]
    ...                Description: do cu and du commission
    Cloud DU connect to gnb coam via ssl    bts_host=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    COAM Commission with scf file
    ...    scf_file_path=${CURDIR}/../../../../commissionings/HGZ/7_5_UTE5G401T721/SCF_10.1100_DU.xml
    ...    is_pdl_checking_needed=${False}    timeout=1200
    CU Full Commission
    ...    path_of_commission_file=${CURDIR}/../../../../commissionings/HGZ/7_5_UTE5G401T721/SCF_10.1100_CU.xml
    wait until keyword succeeds    25 min    10 sec    COAM Check GNB cell on air
    COAM Teardown gnb connections

Test Suite Setup
    Commission_CU_DU
