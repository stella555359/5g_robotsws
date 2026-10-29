*** Settings ***
Documentation     author: Dong Tingting
...               contact: tingting.dong@nokia-sbell.com
...               squad group: MMW_02
#Library    taf.sbts.oam.coam.admin   WITH NAME   admin_cli
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
#Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot


*** Variables ***
${UE_TYPE}                  ${tl.ues[0].capabilities[-1]}
#${WEBUI_IP}                 ${tl.gnbs[0].cu.oam_http_connection_details.addr}
#${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
#${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}


*** Keywords ***
Do_L3call_with_data_transfer_tp_check_from_gnb
    [Documentation]
    ...    The purpose of this test is to verify L3 call.
    [Arguments]  ${ul_tp}=150M  ${dl_tp}=1700M  ${protocol}=udp  ${traffic_duration}=900
    ...    ${ul_tp_target}=60  ${dl_tp_target}=1000  ${check_duration}=5m
#    Call_Common_Setup
    step2: Prepare UE
    Step3: UE Attach
    Step4: Start traffic    ul_throughput=${ul_tp}    dl_throughput=${dl_tp}    protocol=${protocol}    duration=${traffic_duration}
    sleep    60s
    Step5: Check throughput    ultp=${ul_tp_target}    dltp=${dl_tp_target}    duration=${check_duration}
    [Teardown]    Run Keyword And Ignore Error    Call_Common_Teardown

#Call_Common_Setup
#    Run keyword and continue on failure    Wait Until Keyword Succeeds    15min    20s    step1: Check all cells status
#
#step1: Check all cells status
#    log to console      step1: Check all cells status
#    COAM Check GNB_DU cell on air

#Conect to DU COAM
#    [Arguments]    ${connection}=COAM
#    admin_cli.connect to   bts_host=${WEBUI_IP}
#                  ...      username=${WEBUI_USERNAME}
#                  ...      password=${WEBUI_PASSWORD}
#                  ...      name=${connection}
#
#COAM Check GNB_DU cell on air
#    [Documentation]  Author:
#    ...              Description: Check if GNB is in cell on air status
#    [Arguments]    ${connection}=COAM
#    Conect to DU COAM
#    COAM Check All Cells Onair
#    [Teardown]   admin_cli.teardown    connection=${connection}

step2: Prepare UE
    log to console      step2: Prepare UE
    power_ue.Prepare UE    ue_index=${0}    ue_type=${UE_TYPE}

Step3: UE Attach
    log to console      Step3: UE Attach
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    log_type=Aasyslog
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=False
    #Preparation and execution for Commercial UE Attach    ue_index=${0}
    #Log    click Airplane mode switch to disable its function so that make UE attach

Step4: Start traffic
    [Arguments]   ${ul_throughput}=50M    ${dl_throughput}=300M    ${protocol}=udp    ${duration}=1200
    log to console      Step4: Start traffic
    power_ue.Start traffic    ue_index=${0}    direction=ul    throughput=${ul_throughput}    duration=${duration}    ue_type=${UE_TYPE}
    ...    iperf_type=via_command
    ...    protocol=${protocol}
    sleep    1s
    power_ue.Start traffic    ue_index=${0}    direction=dl    throughput=${dl_throughput}    duration=${duration}    ue_type=${UE_TYPE}
    ...    protocol=${protocol}    buffer_size=1400B    process_num=${3}    seg_size=1350    window=16M
    sleep    2s

Get NR Cell Identity
    [Documentation]
    [Arguments]    ${connection}=GNB_OAM    ${gnb_index}=0
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity    connection_alias=${connection}
    ${cell_id_list}    Get Dictionary Keys    ${cell_mapping}
    ${nrCellIdentity_list}    Create List
    FOR    ${item}    IN     @{cell_id_list}
        ${nrCellIdentity}    Evaluate    int(${cell_mapping[${item}]['nrCellIdentity']})
        Append To List    ${nrCellIdentity_list}    ${nrCellIdentity}
    END
    [Return]    ${nrCellIdentity_list}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Step5: Check throughput
    [Arguments]    ${ultp}=35    ${dltp}=150    ${duration}=5m
    log to console      Step5: Check throughput
    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${duration}    filter=L2Lo
    ${list_of_cell_ids}    Get NR Cell Identity
    power_ue.Check Bi Tput    ue_type=${UE_TYPE}    log=${log}    cells=${list_of_cell_ids}
      ...    ultarget_throughput=${ultp}    dltarget_throughput=${dltp}    actCarrierAggregation=${True}

Step6: Stop traffic
    log to console      Step6: Stop traffic
    power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=${UE_TYPE}    iperf_type=via_command
    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${UE_TYPE}

Step7: UE Detach
    log to console      Step7: UE Detach
    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}

Call_Common_Teardown
    [Arguments]    ${connection}=COAM
    Log To Console    \n *** Call_Common teardown
    Run Keyword And Ignore Error    Step6: Stop traffic
    Run Keyword And Ignore Error    Step7: UE Detach
#    Run Keyword And Ignore Error    admin_cli.teardown    connection=${connection}
    Run Keyword And Ignore Error    Teardown the Aasyslog save progress
