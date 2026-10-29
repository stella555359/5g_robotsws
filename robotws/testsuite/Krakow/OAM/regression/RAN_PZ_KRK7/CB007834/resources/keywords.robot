*** Settings ***
Documentation
...   Generic keywords for testing UUF
...   author: Wioleta Swies
...   contact: wioleta.swies@nokia.com

Library      taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations  WITH NAME  GnbAsir
Library      taf.rfrl.bts.devices.asir.asir_operations.EnbAsirHubOperations  WITH NAME  EnbAsir
Library      taf.rfrl.bts.devices.asir.basic_logs.GnbAsirHubLog  WITH NAME  AsirLog
Library      taf.rfrl.procedures.resources.python.OAM_KPI.oam_kpi_runner
Library      taf.sbts.oam.coam.admin  WITH NAME  SbtsAdmin
Library      taf.sbts.oam.sc.rest  WITH NAME  Rest
Library      taf.ue

Library      ./sbts_keywords.py
Library      ./bts_data.py

Resource     taf/rfrl/bts/robot/enb.robot
Resource     taf/rfrl/bts/robot/gnb.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     taf/rfrl/ue/robot/REAL_UE.robot
Resource     taf/rfrl/uuf4all/uuf4all_test_cases.robot
#Resource     testsuite/Krakow/resources/RAN_PZ_KRK7/Quectel_L3_Call/keywords.robot

Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    ./targets.py


*** Variables ***
@{allowed_alarms_fault_ids}=    ${61648}    ${8150}    ${8000}    ${61646}

# -----------------------------UE-----------------------------
${capabilities}                         REAL_UE
${alias}                                UE
${bts_type}                             GNB
${COLLECT_LOGS_DURING_DATA_TRANSFER}    False
${ENABLE_RACH_OBSERVER}                 False
${deviation_ul}                         20%
${deviation_dl}                         20%
${duration}                             120s
${interval}                             1
${linux_congestion}                     None
${parallel_streams_dl}                  8
${parallel_streams_ul}                  1
${reboot_ue}                            True
${size_packet_dl}                       1380B
${size_packet_ul}                       1320B
${timeout_reboot_ue}                    100
${tput_dl}                              1200 Mbits/sec
${tput_ul}                              62 Mbits/sec
${qci}                                  None
${protocol}                             tcp
${buffer_client_dl}                     None
${buffer_server_dl}                     None
${buffer_client_ul}                     None
${buffer_server_ul}                     None

${dl_gnb_min_value}                     1080
${ul_gnb_min_value}                     49
${duration_of_tput}                     130

${dl_enb_min_value}                     95
${ul_enb_min_value}                     20

${UE_CAPABILITIES}                   QUECTEL_UE
${UE_DEFAULT_ALIAS_NAME}             UE
${DEFAULT_DATA_TRANSFER_DURATION}    120s
${DEFAULT_SEGMENT_SIZE}              1320
${DEFAULT_PROTOCOL}                  tcp
${DEFAULT_DEVIATION}                 20%
${DEFAULT_TPUT_UL}                   70Mbits/sec
${DEFAULT_TPUT_DL}                   1400Mbits/sec
${UE_TYPE}                           quectel

*** Keywords ***
Prepare UE PC Connection
    ue.Require Ue    ${UE_DEFAULT_ALIAS_NAME}    capabilities=QUECTEL_UE
    Sleep    5sec    wait for complete `ue.Require Ue`

Attach UE
    Log to Console    Attaching UE
    ${status}    Run Keyword And Return Status    ue.Attach UE    ${UE_DEFAULT_ALIAS_NAME}
    IF    not ${status}
        Log to Console    UE attach failed, trying to recover UE by rebooting it
        ue.Reboot Ue    ${UE_DEFAULT_ALIAS_NAME}      timeout=${170}
        Sleep    10s    Wait for UE Reboot
        Run Keyword And Ignore Error    ue.Stop Using UE    ${UE_DEFAULT_ALIAS_NAME}
        Sleep    5sec    # wait for complete `ute_ue.Require UE`
        Run Keyword And Ignore Error    ue.Require UE    ${UE_DEFAULT_ALIAS_NAME}    capabilities=QUECTEL_UE
        Sleep    5sec    # wait for complete `ute_ue.Require UE`
        Log to Console    Attaching UE Again
        ${status}    Run Keyword And Return Status    ue.Attach UE    ${UE_DEFAULT_ALIAS_NAME}
    END
    Run Keyword If    not ${status}    Fail    UE attach failed even after recovery

Verify L3 Call Quectel
    [Arguments]    ${ul_streams}=8    ${dl_streams}=40
    Prepare UE PC Connection
    ue.Change Network Mode    ${UE_DEFAULT_ALIAS_NAME}    LTE:NR5G    ue_type=${UE_TYPE}
    Sleep    10sec    wait for complete `ue.Change Network Mode`
    Wait For Time Window
    Attach UE
    Sleep    10sec    wait for complete `ue.Attach Ue`
    ue.Start Data Transfer    dt_name=DT_UL
    ...                       ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                       direction=ul
    ...                       duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                       max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                       throughput=${DEFAULT_TPUT_UL}
    ...                       protocol=${DEFAULT_PROTOCOL}
    ...                       parallel_streams=${ul_streams}



    ue.Await Data Transfer Finish    dt_name=DT_UL
    ue.Verify Average Throughput With Deviation   dt_name=DT_UL   tput=${DEFAULT_TPUT_UL}   deviation=${DEFAULT_DEVIATION}

    ue.Start Data Transfer    dt_name=DT_DL
    ...                       ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                       direction=dl
    ...                       duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                       max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                       throughput=${DEFAULT_TPUT_DL}
    ...                       protocol=${DEFAULT_PROTOCOL}
    ...                       parallel_streams=${dl_streams}

    ue.Await Data Transfer Finish    dt_name=DT_DL
    ue.Verify Average Throughput With Deviation   dt_name=DT_DL   tput=${DEFAULT_TPUT_DL}   deviation=${DEFAULT_DEVIATION}

    ue.Detach Ue    ${UE_DEFAULT_ALIAS_NAME}
    ue.Stop Using Ue    ${UE_DEFAULT_ALIAS_NAME}

Verify 5G Attach Quectel
    [Arguments]  ${cell_id}=None    ${delay}=30
    Set X2c Interface Signalling    5min
    ${before_counter}    Get Attach Counter    cell_id=${cell_id}
    Prepare UE PC Connection
    ue.Change Network Mode    ${UE_DEFAULT_ALIAS_NAME}    LTE:NR5G    ue_type=${UE_TYPE}
    Sleep    10sec    wait for complete `ue.Change Network Mode`
    Attach UE
    Sleep    10sec    wait for complete `ue.Attach UE`
    ue.Detach Ue    ${UE_DEFAULT_ALIAS_NAME}
    ue.Stop Using Ue    ${UE_DEFAULT_ALIAS_NAME}
    Wait For Next Pm Counter Period    interval=5min    delay=${delay}
    ${after_counter}    Get Attach Counter    cell_id=${cell_id}
    Should be True    ${after_counter} >= ${before_counter} + ${1}

Verify 5G Attach
    [Arguments]  ${cell_id}=None    ${reboot_ue}=${True}    ${delay}=30
    Set X2c Interface Signalling    5min
    ${before_counter}    Get Attach Counter    cell_id=${cell_id}
    Prepare Ue for L3 Call    capabilities=${capabilities}    reboot_ue=${reboot_ue}    timeout_reboot_ue=${timeout_reboot_ue}
    Perform Attach and Verify UE Properly Attached  alias=${alias}    bts_type=${bts_type}
    Wait For Next Pm Counter Period    interval=5min    delay=${delay}
    ${after_counter}    Get Attach Counter    cell_id=${cell_id}
    Should be True    ${after_counter} >= ${before_counter} + ${1}

Verify Throughput on 5G and 4G
    [Arguments]  ${dl_enb_min_value}=${dl_enb_min_value}
    ...     ${dl_gnb_min_value}=${dl_gnb_min_value}  ${ul_gnb_min_value}=${ul_gnb_min_value}
    Wait For Next Pm Counter Period    interval=15min    delay=30
    Verify Enb Dl Counter    min_value=${dl_enb_min_value}
    Verify Gnb Dl Counter    min_value=${dl_gnb_min_value}    divisor=${duration_of_tput}
    Verify Gnb Ul Counter    min_value=${ul_gnb_min_value}    divisor=${duration_of_tput}


Wait For Gnb Full Availability After Reset
    Wait Until Keyword Succeeds    900s    10s    Verify Cell Status    cell_status=Enabled
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    300    5s
    ...    Verify Alarm is Active on gNB    No X2 link available for a specific LTEENB    fault_id=7319
    Wait Until Keyword Succeeds    900s    10s
    ...    Verify Alarm is Not Active on gNB    No X2 link available for a specific LTEENB    fault_id=7319
    Wait Until Keyword Succeeds    900s    10s
    ...    Verify Alarm is Not Active on gNB    No X2 link available    fault_id=7300
    Wait Until Keyword Succeeds    60s    10s
    ...    Verify Alarm is Not Active on gNB    EN DSS De-activated on partner side    fault_id=6134

Change Asir Parameters Without Site Reset
    ${dist_name}=    Get Antennas Dist Name
    Log To Console    Changing User Label
    Change Parameter In Delta Plan And Activate    dn=${dist_name}   name=userLabel    value=testValue
    Wait Until Keyword Succeeds    20s    5s    GnbAsir.Verify Antmod Status    expected_statuses=${antmod_status}
    Wait Until Keyword Succeeds    20s    5s    GnbAsir.Verify Status Of Asir Cells    expected_asir_cell_status=operational

    Log To Console    Changing ASI_ID
    Change Parameter In Delta Plan And Activate    dn=${dist_name.split('/')[0]}    name=asiId    value=2
    Wait Until Keyword Succeeds    600s    10s    GnbAsir.Verify Antmod Status    expected_statuses=${antmod_status}
    Wait Until Keyword Succeeds    70s    5s    GnbAsir.Verify Status Of Asir Cells    expected_asir_cell_status=operational

Restore Default Values
    ${dist_name}=    Get Antennas Dist Name
    Log To Console    Restoring To Default Values
    Reverse Parameters To Default Values    dist_name=${dist_name}
    ...                                     param_name=userLabel
    ...                                     default_param_value=customer_add_prrh1
    Reverse Parameters To Default Values    dist_name=${dist_name.split('/')[0]}
    ...                                     param_name=asiId
    ...                                     default_param_value=1
    Wait Until Keyword Succeeds    600s    10s    GnbAsir.Verify Antmod Status    expected_statuses=${antmod_status}
    Wait Until Keyword Succeeds    70s    5s    GnbAsir.Verify Status Of Asir Cells    expected_asir_cell_status=operational

Reset Hub In Loop
    [Arguments]    ${iterations}    ${allowed_alarms}    ${bts_id}=0
    FOR    ${i}    IN RANGE    ${iterations}
        ${iteration}=    Evaluate    ${i} + 1
        Log To Console    iteration ${iteration}/${iterations}
        Wait Until Keyword Succeeds    5min    10s    GnbAsir.Reset Hub    bts_id=${bts_id}    hub_id=1
        Wait Until Keyword Succeeds    5min    10s    gnbcell.Verify All Cells Statuses    operational_state=enabled
        ...                                                                                availability_status=online
        GnbAsir.Verify Only Allowed Alarms Are Active    allowed_alarms=${allowed_alarms}
    END

Reset Hub In Loop on Enb
    [Arguments]    ${iterations}    ${allowed_alarms}
    FOR    ${i}    IN RANGE    ${iterations}
        ${iteration}=    Evaluate    ${i} + 1
        Log To Console    iteration ${iteration}/${iterations}
        Wait Until Keyword Succeeds    5min    10s    EnbAsir.Reset Hub    hub_id=1
        Wait Until Keyword Succeeds    5min    10s    enbcell.Verify All Cells Statuses    operational_state=enabled
        ...                                                                                availability_status=online
        EnbAsir.Verify Only Allowed Alarms Are Active    allowed_alarms=${allowed_alarms}
    END
