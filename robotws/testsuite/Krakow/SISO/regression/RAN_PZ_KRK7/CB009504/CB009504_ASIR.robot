*** Settings ***
Documentation
...    author: Dominik Wieczorek
...    contact: Dominik Wieczorek (dominik.wieczorek@nokia.com)

Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Resource     testsuite/Krakow/resources/RAN_PZ_KRK7/Quectel_L3_Call/keywords.robot
Library      taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations  WITH NAME  gnbasir
Library      taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME    gnbcell
Library      ./resources/keywords.py    WITH NAME    keywords
Library      testsuite/Krakow/resources/RAN_PZ_KRK7/tools/keywords.py    WITH NAME    T07_keywords

Suite Setup      Run Keywords    Prepare gNB Neighbour
...                       AND    Common Suite Setup With OnAir Test Line Preparation
...                                                                   should_5G_neighbour_be_changed=${False}
...                                                                   swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...                                                                   upload_swconfig_to_neighbour=${False}
...                                                                   enable_sleeping_cell_detection=${False}
...                                                                   list_of_additional_allowed_alarms=${PREPARATION_ALARMS}
Suite Teardown    Common Suite Teardown
Test Setup       Custom Preconditions With Watching Alarms
Test Teardown    Custom Postconditions With Watching Alarms

*** Variables ***
@{PREPARATION_ALARMS}       No connection to unit
...                         Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability
...                         Failure detected on assigned antennas

@{CUSTOM_ALLOWED_ALARMS}    Failure in connection between BTS and 3rd party tool
...                         Failure in internal BTS connection or connection to 3rd party tool
...                         User Account has Default Password
...                         TX out of order
...                         RF module gain adjusting failure
...                         RX out of order
...                         Transmission path failure
...                         Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability
...                         Failure detected on assigned antennas
...                         Cell problem due to unavailability of associated links

${FID1907}                  TX out of order
${FID1908}                  RF module gain adjusting failure
${FID1911}                  RX out of order
${FID1907_RESET}            1907 autonomous reset as recovery action
${FID1908_RESET}            1908 autonomous reset as recovery action
${FID1911_RESET}            1911 autonomous reset as recovery action
${FID4479}                  Failure detected on assigned antennas
${FID4480}                  ANTMOD not detected

${UE_CAPABILITIES}                   QUECTEL_UE
${UE_DEFAULT_ALIAS_NAME}             UE
${DEFAULT_DATA_TRANSFER_DURATION}    60s
${DEFAULT_SEGMENT_SIZE}              1320
${DEFAULT_PROTOCOL}                  tcp
${DEFAULT_TPUT_UL}                   70Mbits/sec
${DEFAULT_DEVIATION_UL}              40%
${DEFAULT_TPUT_DL}                   1500Mbits/sec
${DEFAULT_DEVIATION_DL}              40%
${UE_TYPE}                           quectel

*** Test Cases ***
CB009504_E01_23_Triggering_fault_ASIR_Cell_Setup_with_Failed_Tx_Rx_in_Degraded_State_pRRH.
    [Tags]    tc23
    Perform setup operations
    Trigger FID on pRRH    fid=1907    ant=0x03    prrh_id=0    rmod_sn=NH195100111
    Trigger FID on pRRH    fid=1908    ant=0x04    prrh_id=0    rmod_sn=NH195100111
    Trigger FID on pRRH    fid=1911    ant=0x01    prrh_id=0    rmod_sn=NH195100111
    Check if no immediate recovery    fault_id=1907    impacted_cell=39
    Check if no immediate recovery    fault_id=1908    impacted_cell=39
    Check if no immediate recovery    fault_id=1911    impacted_cell=39
    L3 CALL    tput_dl=750Mbits/sec    tput_ul=35Mbits/sec

    Trigger FID on pRRH    fid=1907    ant=0x00    prrh_id=0    rmod_sn=NH195100111
    Trigger FID on pRRH    fid=1908    ant=0x00    prrh_id=0    rmod_sn=NH195100111
    Trigger FID on pRRH    fid=1911    ant=0x00    prrh_id=0    rmod_sn=NH195100111
    Wait Until Keyword Succeeds    2min    10s    gnbcell.Verify Cell Statuses    cell_id=39
    ...                                                                           operational_state=enabled
    ...                                                                           availability_status=online

    Perform setup operations on enb
    Trigger FID on pRRH    fid=1907    ant=0x01    prrh_id=0    rmod_sn=NH200200323    bts_id=1
    Trigger FID on pRRH    fid=1911    ant=0x01    prrh_id=0    rmod_sn=NH200200323    bts_id=1
    Check if no immediate recovery on enb    fault_id=1907    impacted_cell=11
    Check if no immediate recovery on enb    fault_id=1911    impacted_cell=11
    L3 CALL LTE    tput_dl=70Mbits/sec    tput_ul=45Mbits/sec
    Trigger FID on pRRH    fid=1907    ant=0x00    prrh_id=0    rmod_sn=NH200200323    bts_id=1
    Trigger FID on pRRH    fid=1911    ant=0x00    prrh_id=0    rmod_sn=NH200200323    bts_id=1

CB009504_E02_25_Triggering_fault_on_ASIR_to_verify_autonomous_pRRH_Recovery_Reset_due_to_Tx_Rx_Failure_successful_recovery.
    [Tags]    tc25
    Perform setup operations
    Perform FID operations with successfull recovery    fault_id=1911    ant=0xFF    prrh_id=0    rmod_sn=NH195100111
    ...                                                 impacted_cell=39    tput_dl=1500Mbits/sec    tput_ul=70Mbits/sec

    Perform setup operations on enb
    Perform FID operations with successfull recovery on enb    fault_id=1907    ant=0xFF    prrh_id=0
    ...                                                        rmod_sn=NH200200323    tput_dl=140Mbits/sec
    ...                                                        tput_ul=45Mbits/sec

CB009504_E03_26_Triggering_fault_on_ASIR_Scheduled_pRRH_Recovery_Reset_fail_recovery.
    [Tags]    tc26
    Perform setup operations
    Perform FID operations with MW    fault_id=1907    ant=0x02    prrh_id=0    rmod_sn=NH195100111    impacted_cell=39
    ...                               tput_dl=1125Mbits/sec    tput_ul=70Mbits/sec

    Perform setup operations on enb
    Perform FID operations with MW on enb    fault_id=1911    ant=0x01    prrh_id=0    rmod_sn=NH200200323
    ...                                      impacted_cell=11    tput_dl=70Mbits/sec    tput_ul=45Mbits/sec


*** Keywords ***
Perform setup operations
    keywords.Set Act Force Unit Auto Reset    expected_value=false
    keywords.Delete Maintenance Window
    keywords.Reset Site
    Sleep    30sec    Wait for 'keywords.Reset Site' completed
    Wait Until Keyword Succeeds    15min    10s    keywords.verify_all_bbmods_online_status
    Add SSH Key    filename=id_rsa    path=testsuite/Krakow/SISO/regression/RAN_PZ_KRK7/CB009504/resources/ASIR
    Wait Until Keyword Succeeds    10min    10s    gnbcell.Verify Cell Statuses    cell_id=39
    ...                                                                            operational_state=enabled
    ...                                                                            availability_status=online

Perform setup operations on enb
    Wait Until Keyword Succeeds    5min    10s    keywords.Set Act Force Unit Auto Reset    bts_id=1
    ...                                                                                     expected_value=false
    keywords.Delete Maintenance Window    bts_id=1
    keywords.Reset Site    bts_id=1
    Sleep    30sec    Wait for 'keywords.Reset Site' completed
    Wait Until Keyword Succeeds    15min    10s    keywords.verify_all_bbmods_online_status    bts_id=1
    Add SSH Key    filename=id_rsa
    ...            path=testsuite/Krakow/SISO/regression/RAN_PZ_KRK7/CB009504/resources/ASIR
    ...            bts_id=1
    Wait Until Keyword Succeeds    10min    10s    gnbcell.Verify All Cells Statuses    bts_id=1
    ...                                                                                 operational_state=enabled
    ...                                                                                 availability_status=online

Perform FID operations with successfull recovery
    [Arguments]    ${fault_id}    ${ant}    ${prrh_id}    ${rmod_sn}    ${impacted_cell}
    ...            ${tput_dl}=${DEFAULT_TPUT_DL}    ${tput_ul}=${DEFAULT_TPUT_UL}
    IF    ${fault_id} == 1907
          Set Test Variable    ${fault_name_reset}    ${FID1907_RESET}
          Log To Console    ${fault_name_reset}
    ELSE IF    ${fault_id} == 1908
          Set Test Variable    ${fault_name_reset}    ${FID1908_RESET}
          Log To Console    ${fault_name_reset}
    ELSE IF    ${fault_id} == 1911
          Set Test Variable    ${fault_name_reset}    ${FID1911_RESET}
          Log To Console    ${fault_name_reset}
    ELSE
        Fail    Unexpected fault_id: ${fault_id}
    END
    Sleep    4min    Wait for runtime
    Trigger FID on pRRH    fid=${fault_id}    ant=${ant}    prrh_id=${prrh_id}    rmod_sn=${rmod_sn}
    Check if immediate recovery succeed    fault_id=${fault_id}
    ...                                    impacted_cell=${impacted_cell}
    ...                                    fault_name_reset=${fault_name_reset}
    L3 CALL    tput_dl=${tput_dl}    tput_ul=${tput_ul}
    gnbcell.Verify Cell Statuses    cell_id=${impacted_cell}    operational_state=enabled    availability_status=online

Perform FID operations with successfull recovery on enb
    [Arguments]    ${fault_id}    ${ant}    ${prrh_id}    ${rmod_sn}
    ...            ${tput_dl}=${DEFAULT_TPUT_DL}    ${tput_ul}=${DEFAULT_TPUT_UL}
    IF    ${fault_id} == 1907
          Set Test Variable    ${fault_name_reset}    ${FID1907_RESET}
          Log To Console    ${fault_name_reset}
    ELSE IF    ${fault_id} == 1908
          Set Test Variable    ${fault_name_reset}    ${FID1908_RESET}
          Log To Console    ${fault_name_reset}
    ELSE IF    ${fault_id} == 1911
          Set Test Variable    ${fault_name_reset}    ${FID1911_RESET}
          Log To Console    ${fault_name_reset}
    ELSE
        Fail    Unexpected fault_id: ${fault_id}
    END
    Sleep    4min    Wait for runtime
    Trigger FID on pRRH    fid=${fault_id}    ant=${ant}    prrh_id=${prrh_id}    rmod_sn=${rmod_sn}    bts_id=1
    Check if immediate recovery succeed on enb    fault_id=${fault_id}
    ...                                           fault_name_reset=${fault_name_reset}
    L3 CALL LTE   tput_dl=${tput_dl}    tput_ul=${tput_ul}
    gnbcell.Verify All Cells Statuses    bts_id=1    operational_state=enabled    availability_status=online

Perform FID operations with MW
    [Arguments]    ${fault_id}    ${ant}    ${prrh_id}    ${rmod_sn}    ${impacted_cell}
    ...            ${tput_dl}=${DEFAULT_TPUT_DL}    ${tput_ul}=${DEFAULT_TPUT_UL}

    IF    ${fault_id} == 1907
          Set Test Variable    ${fault_name_reset}    ${FID1907_RESET}
          Log To Console    ${fault_name_reset}
    ELSE IF    ${fault_id} == 1908
          Set Test Variable    ${fault_name_reset}    ${FID1908_RESET}
          Log To Console    ${fault_name_reset}
    ELSE IF    ${fault_id} == 1911
          Set Test Variable    ${fault_name_reset}    ${FID1911_RESET}
          Log To Console    ${fault_name_reset}
    ELSE
        Fail    Unexpected fault_id: ${fault_id}
    END

    keywords.Setup Maintenance Window    graceful_cell_shutdown=yes if supported
    Sleep    4min    Wait for runtime
    Trigger FID on pRRH    fid=${fault_id}    ant=${ant}    prrh_id=${prrh_id}    rmod_sn=${rmod_sn}
    Check if no immediate recovery    fault_id=${fault_id}    impacted_cell=${impacted_cell}
    Check if recovery succeed    impacted_cell=${impacted_cell}
    keywords.Verify ASIR Maintenance Window Result    quantity=1
    Trigger FID on pRRH    fid=${fault_id}    ant=${ant}    prrh_id=${prrh_id}    rmod_sn=${rmod_sn}
    Check if no immediate recovery    fault_id=${fault_id}    impacted_cell=${impacted_cell}
    L3 CALL    tput_dl=${tput_dl}    tput_ul=${tput_ul}
    Trigger FID on pRRH    fid=${fault_id}    ant=0x00    prrh_id=${prrh_id}    rmod_sn=${rmod_sn}
    Wait Until Keyword Succeeds    10min    10s    gnbcell.Verify Cell Statuses    cell_id=${impacted_cell}
    ...                                                                            operational_state=enabled
    ...                                                                            availability_status=online

Perform FID operations with MW on enb
    [Arguments]    ${fault_id}    ${ant}    ${prrh_id}    ${rmod_sn}    ${impacted_cell}
    ...            ${tput_dl}=${DEFAULT_TPUT_DL}    ${tput_ul}=${DEFAULT_TPUT_UL}

    IF    ${fault_id} == 1907
          Set Test Variable    ${fault_name_reset}    ${FID1907_RESET}
          Log To Console    ${fault_name_reset}
    ELSE IF    ${fault_id} == 1908
          Set Test Variable    ${fault_name_reset}    ${FID1908_RESET}
          Log To Console    ${fault_name_reset}
    ELSE IF    ${fault_id} == 1911
          Set Test Variable    ${fault_name_reset}    ${FID1911_RESET}
          Log To Console    ${fault_name_reset}
    ELSE
        Fail    Unexpected fault_id: ${fault_id}
    END

    keywords.Setup Maintenance Window    bts_id=1    graceful_cell_shutdown=yes if supported
    Sleep    4min    Wait for runtime
    Trigger FID on pRRH    fid=${fault_id}    ant=${ant}    prrh_id=${prrh_id}    rmod_sn=${rmod_sn}    bts_id=1
    Check if no immediate recovery on enb    fault_id=${fault_id}    impacted_cell=${impacted_cell}
    Check if recovery succeed on enb
    keywords.Verify ASIR Maintenance Window Result    quantity=1    bts_id=1
    Trigger FID on pRRH    fid=${fault_id}    ant=${ant}    prrh_id=${prrh_id}    rmod_sn=${rmod_sn}    bts_id=1
    Check if no immediate recovery on enb    fault_id=${fault_id}    impacted_cell=${impacted_cell}
    L3 CALL LTE    tput_dl=${tput_dl}    tput_ul=${tput_ul}
    Trigger FID on pRRH    fid=${fault_id}    ant=0x00    prrh_id=${prrh_id}    rmod_sn=${rmod_sn}    bts_id=1
    Wait Until Keyword Succeeds    10min    10s    gnbcell.Verify All Cells Statuses    bts_id=1
    ...                                                                                 operational_state=enabled
    ...                                                                                 availability_status=online

Check if recovery succeed
    [Arguments]    ${impacted_cell}
    Wait Until Keyword Succeeds    10min    5s    keywords.Verify GNB ASIR Alarm is Active
    ...                                                         fault_name=${FID4480}
    Wait Until Keyword Succeeds    10min    5s    gnbcell.Verify Cell Statuses    cell_id=${impacted_cell}
    ...                                                                           operational_state=disabled
    ...                                                                           availability_status=failed
    Wait Until Keyword Succeeds    10min    10s    gnbcell.Verify Cell Statuses    cell_id=${impacted_cell}
    ...                                                                            operational_state=enabled
    ...                                                                            availability_status=online

Check if recovery succeed on enb
    [Arguments]
    Wait Until Keyword Succeeds    10min    5s    keywords.Verify GNB ASIR Alarm is Active
    ...                                                         bts_id=1
    ...                                                         fault_name=${FID4480}
    Wait Until Keyword Succeeds    10min    5s    gnbcell.Verify All Cells Statuses    bts_id=1
    ...                                                                                operational_state=disabled
    ...                                                                                availability_status=failed
    Wait Until Keyword Succeeds    10min    10s    gnbcell.Verify All Cells Statuses    bts_id=1
    ...                                                                                 operational_state=enabled
    ...                                                                                 availability_status=online

Check if immediate recovery succeed
    [Arguments]    ${fault_id}    ${impacted_cell}    ${fault_name_reset}
    Wait Until Keyword Succeeds    2min    5s    gnb_asir.Verify Alarm is Active    fault_id=${fault_id}
    Wait Until Keyword Succeeds    2min    5s    Verify Alarm is Active on GNB    fault_name=${FID4479}
    Wait Until Keyword Succeeds    2min    5s    keywords.Verify GNB ASIR Alarm is Active
    ...                                                                   fault_name=${fault_name_reset}
    Wait Until Keyword Succeeds    2min    5s    keywords.Verify GNB ASIR Alarm is Active
    ...                                                                   fault_name=${FID4480}
    Wait Until Keyword Succeeds    2min    5s    gnbcell.Verify Cell Statuses    cell_id=${impacted_cell}
    ...                                                                          operational_state=disabled
    ...                                                                          availability_status=failed
    Wait Until Keyword Succeeds    5min    10s    gnbcell.Verify Cell Statuses    cell_id=${impacted_cell}
    ...                                                                           operational_state=enabled
    ...                                                                           availability_status=online

Check if immediate recovery succeed on enb
    [Arguments]    ${fault_id}    ${fault_name_reset}
    Wait Until Keyword Succeeds    2min    5s    gnbasir.Verify Alarm is Active    bts_id=1
    ...                                                                            fault_id=${fault_id}
    Wait Until Keyword Succeeds    2min    5s    Verify Alarm is Active on GNB    gnb_id=1
    ...                                                                           fault_name=${FID4479}
    Wait Until Keyword Succeeds    2min    5s    keywords.Verify GNB ASIR Alarm is Active
    ...                                                                   bts_id=1
    ...                                                                   fault_name=${fault_name_reset}
    Wait Until Keyword Succeeds    2min    5s    keywords.Verify GNB ASIR Alarm is Active
    ...                                                                   bts_id=1
    ...                                                                   fault_name=${FID4480}
    Wait Until Keyword Succeeds    2min    5s    gnbcell.Verify All Cells Statuses    bts_id=1
    ...                                                                               operational_state=disabled
    ...                                                                               availability_status=failed
    Wait Until Keyword Succeeds    5min    10s    gnbcell.Verify All Cells Statuses    bts_id=1
    ...                                                                                operational_state=enabled
    ...                                                                                availability_status=online

Check if no immediate recovery
    [Arguments]    ${fault_id}    ${impacted_cell}
    Wait Until Keyword Succeeds    10min    10s    gnb_asir.Verify Alarm is Active    fault_id=${fault_id}
    Wait Until Keyword Succeeds    2min    10s    Verify Alarm is Active on GNB    fault_name=${FID4479}
    Wait Until Keyword Succeeds    2min    10s    gnbcell.Verify Cell Statuses    cell_id=${impacted_cell}
    ...                                                                           operational_state=enabled
    ...                                                                           availability_status=degraded
    Repeat Keyword    2min    Run Keywords    keywords.Verify GNB ASIR Alarm is not Active   fault_name=${FID1907_RESET}
    ...                                AND    keywords.Verify GNB ASIR Alarm is not Active   fault_name=${FID1908_RESET}
    ...                                AND    keywords.Verify GNB ASIR Alarm is not Active   fault_name=${FID1911_RESET}
    ...                                AND    Sleep    10s    Wait for next iteration
    gnbcell.Verify Cell Statuses    cell_id=${impacted_cell}
    ...                             operational_state=enabled
    ...                             availability_status=degraded

Check if no immediate recovery on enb
    [Arguments]    ${fault_id}    ${impacted_cell}
    Wait Until Keyword Succeeds    10min    10s    gnbasir.Verify Alarm is Active    bts_id=1
    ...                                                                              fault_id=${fault_id}
    Wait Until Keyword Succeeds    2min    10s    Verify Alarm is Active on GNB    gnb_id=1
    ...                                                                            fault_name=${FID4479}
    Wait Until Keyword Succeeds    2min    10s    gnbcell.Verify Cell Statuses    bts_id=1
    ...                                                                           cell_id=${impacted_cell}
    ...                                                                           operational_state=enabled
    ...                                                                           availability_status=degraded
    Repeat Keyword    2min    Run Keywords    keywords.Verify GNB ASIR Alarm is not Active   bts_id=1
    ...                                                                                      fault_name=${FID1907_RESET}
    ...                                AND    keywords.Verify GNB ASIR Alarm is not Active   bts_id=1
    ...                                                                                      fault_name=${FID1908_RESET}
    ...                                AND    keywords.Verify GNB ASIR Alarm is not Active   bts_id=1
    ...                                                                                      fault_name=${FID1911_RESET}
    ...                                AND    Sleep    10s    Wait for next iteration
    gnbcell.Verify Cell Statuses    bts_id=1
    ...                             cell_id=${impacted_cell}
    ...                             operational_state=enabled
    ...                             availability_status=degraded

Prepare UE PC Connection
    ute_ue.Require UE    ${UE_DEFAULT_ALIAS_NAME}    capabilities=QUECTEL_UE
    Sleep    5sec    Wait for complete ute_ue.Require UE

L3 CALL
    [Arguments]    ${tput_dl}=${DEFAULT_TPUT_DL}    ${tput_ul}=${DEFAULT_TPUT_UL}
    Run Keyword And Ignore Error    Prepare UE PC Connection
    Change Network Mode    ${UE_DEFAULT_ALIAS_NAME}    LTE:NR5G    ue_type=${UE_TYPE}
    Sleep    5sec    Wait for Change Network Mode complete
    Set Active Bands    ${UE_DEFAULT_ALIAS_NAME}    LTE    2:66
    Sleep    5sec    Wait for Set Active Bands complete
    Set Active Bands    ${UE_DEFAULT_ALIAS_NAME}    NR5G_NSA    41
    Sleep    5sec    Wait for Set Active Bands complete
    Run Keyword And Ignore Error    ute_ue.Detach UE    ${UE_DEFAULT_ALIAS_NAME}
    Sleep    5sec    Wait for Detach UE complete
    Attach UE
    Sleep    5sec    Wait for Attach UE complete
    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    Sleep    5sec    Wait for Get UE Info complete
    ute_ue.Start Data Transfer    dt_name=DT_UL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=ul
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${tput_ul}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=12
    ute_ue.Await Data Transfer Finish    dt_name=DT_UL
    Verify Average Throughput With Deviation    dt_name=DT_UL
    ...                                         tput=${tput_ul}
    ...                                         deviation=${DEFAULT_DEVIATION_UL}

    ute_ue.Start Data Transfer    dt_name=DT_DL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=dl
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${tput_dl}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=100
    ute_ue.Await Data Transfer Finish    dt_name=DT_DL
    Verify Average Throughput With Deviation    dt_name=DT_DL
    ...                                         tput=${tput_dl}
    ...                                         deviation=${DEFAULT_DEVIATION_DL}


    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    ute_ue.Detach UE    ${UE_DEFAULT_ALIAS_NAME}
    ute_ue.Stop Using Ue    ${UE_DEFAULT_ALIAS_NAME}

L3 CALL LTE
    [Arguments]    ${tput_dl}=${DEFAULT_TPUT_DL}    ${tput_ul}=${DEFAULT_TPUT_UL}
    Run Keyword And Ignore Error    Prepare UE PC Connection
    Change Network Mode    ${UE_DEFAULT_ALIAS_NAME}    LTE    ue_type=${UE_TYPE}
    Sleep    5sec    Wait for Change Network Mode complete
    Set Active Bands    ${UE_DEFAULT_ALIAS_NAME}    LTE    2
    Sleep    5sec    Wait for Set Active Bands complete
    Run Keyword And Ignore Error    ute_ue.Detach UE    ${UE_DEFAULT_ALIAS_NAME}
    Sleep    5sec    Wait for Detach UE complete
    Attach UE
    Sleep    5sec    Wait for Attach UE complete
    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    Sleep    5sec    Wait for Get UE Info complete
    ute_ue.Start Data Transfer    dt_name=DT_UL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=ul
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${tput_ul}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=4
    ute_ue.Await Data Transfer Finish    dt_name=DT_UL
    Verify Average Throughput With Deviation    dt_name=DT_UL
    ...                                         tput=${tput_ul}
    ...                                         deviation=${DEFAULT_DEVIATION_UL}

    ute_ue.Start Data Transfer    dt_name=DT_DL
    ...                           ue_alias=${UE_DEFAULT_ALIAS_NAME}
    ...                           direction=dl
    ...                           duration=${DEFAULT_DATA_TRANSFER_DURATION}
    ...                           max_segment_size=${DEFAULT_SEGMENT_SIZE}
    ...                           throughput=${tput_dl}
    ...                           protocol=${DEFAULT_PROTOCOL}
    ...                           parallel_streams=8
    ute_ue.Await Data Transfer Finish    dt_name=DT_DL
    Verify Average Throughput With Deviation    dt_name=DT_DL
    ...                                         tput=${tput_dl}
    ...                                         deviation=${DEFAULT_DEVIATION_DL}


    ${UE_INFO}=    ute_ue.Get UE Info    ${UE_DEFAULT_ALIAS_NAME}    ALL
    ute_ue.Detach UE    ${UE_DEFAULT_ALIAS_NAME}
    ute_ue.Stop Using Ue    ${UE_DEFAULT_ALIAS_NAME}

Attach UE
    Log to Console    Attaching UE
    ${status}    Run Keyword And Return Status    ute_ue.Attach UE    ${UE_DEFAULT_ALIAS_NAME}
    IF    not ${status}
        Log to Console    UE attach failed, trying to recover UE by rebooting it
        ute_ue.Reboot Ue    ${UE_DEFAULT_ALIAS_NAME}      timeout=${170}
        Sleep    10s    Wait for UE Reboot
        Run Keyword And Ignore Error    ute_ue.Stop Using UE    ${UE_DEFAULT_ALIAS_NAME}
        Sleep    5sec    # wait for complete `ute_ue.Require UE`
        Run Keyword And Ignore Error    ute_ue.Require UE    ${UE_DEFAULT_ALIAS_NAME}    capabilities=QUECTEL_UE
        Sleep    5sec    # wait for complete `ute_ue.Require UE`
        Log to Console    Attaching UE Again
        ${status}    Run Keyword And Return Status    ute_ue.Attach UE    ${UE_DEFAULT_ALIAS_NAME}
    END
    Run Keyword If    not ${status}    Fail    UE attach failed even after recovery

Custom Preconditions With Watching Alarms
    Common Preconditions With Watching Alarms
    gnbalarm.Start watching alarms     bts_id=1    allowed_alarms=${allowed_alarms}
    gnbalarm.Watch Active Alarms and Collect Logs on Unexpected    bts_id=1


Custom Postconditions With Watching Alarms
    gnbasir.Reset Antenna    ant_id=1
    Sleep    30sec    Wait for Reset Antenna complete
    gnbasir.Reset Antenna    bts_id=1    ant_id=1
    Sleep    30sec    Wait for Reset Antenna complete
    Wait Until Keyword Succeeds    10min    10s    gnbcell.Verify All Cells Statuses    operational_state=enabled
    ...                                                                                 availability_status=online
    Wait Until Keyword Succeeds    10min    10s    gnbcell.Verify All Cells Statuses    bts_id=1
    ...                                                                                 operational_state=enabled
    ...                                                                                 availability_status=online
    Common Postconditions       collect_syslog=${True}

    [Teardown]    Run Keywords    gnb_alarm.Stop watching alarms
    ...                    AND    gnbalarm.Stop watching alarms    bts_id=1
    ...                    AND    Remove Custom Allowed Alarms If Defined
