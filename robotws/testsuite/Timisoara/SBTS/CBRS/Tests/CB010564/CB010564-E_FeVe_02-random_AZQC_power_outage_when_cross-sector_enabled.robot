*** Settings ***
Documentation
...    = Author =
...    karol.sadowski@nokia.com
...    = Maintainer =
...    karol.sadowski@nokia.com
...    = Reviewer =
...    aleksandra.chudzik@nokia.com
...    piotr.lukaszewicz@nokia.com
...    Review link:


*** Keywords ***
CB010564-E_FeVe_02-random_AZQC_power_outage_when_cross-sector_enabled
    [Documentation]    Requirement: SRAN_SFS_SISO.3871, SRAN_SFS_SISO.3905, OAM_REQ_CBRS_556
    ...                Purpose: This test case verifies CBSDs behaviour in cross-sector BTS configuration. It is
    ...                expected that if one of 3 RRHs operating in 4Tx4Rx would be faulty, two cells will degrade to
    ...                2Tx2Rx to hold 3 sectors - each RRH is connected to two sectors.
    ...
    ...                Test Steps:
    ...                Step 0: Prepare BTS cross-sector and SAS configuration
    ...                Step 1: Start SAS simulator and enable CBRS on BTS
    ...                Step 2: Power off random RMOD on PDU
    ...                Step 3: Check presence of FID:10 and FID:4003
    ...                Step 4: Check if all sectors are operational in onAir


    ${bts_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${alias}   Set Variable    RAT_1ST
    &{expected_alarm_1}   Create Dictionary    fault_id=1815    fault_name=Not able to synchronize baseband bus    severity=Major
    &{expected_alarm_2}   Create Dictionary    fault_id=10    fault_name=No connection to unit    severity=Major
    &{expected_alarm_3}   Create Dictionary    fault_id=4003    fault_name=Transmission path failure    severity=Minor
    &{expected_alarm_4}   Create Dictionary    fault_id=4589    fault_name=Unit power reset    severity=Warning
    ${expected_alarms_list}   Create List    ${expected_alarm_1}    ${expected_alarm_2}    ${expected_alarm_3}    ${expected_alarm_4}
    ${expected_alarms_objects}   Create Watchdog Alarm List    ${expected_alarms_list}
    ${num_of_cells}   Get Number of Cells    enb_id=${bts_id}

    Log To Console    ${\n}Step 0: Setting preconditions...
    Disable CBRS Feature On eNB
    Kill All SAS Processes
    Enable CBRS Feature On eNB

    Log To Console    ${\n}Step 1: Starting SAS simulator...
    ${sas_pid}    ${sas_logs_dir}   Start SAS Process
    Wait Until Keyword Succeeds    6x    10s    Required CBSD Status Should Be Reached
    ...    expected_status=Registered    enb_id=${bts_id}
    Start Watchdog Alarm Detection    expected_alarms=${expected_alarms_objects}

    Wait For All Cells To Be OnAir    wait_time=10min

    Log To Console    ${\n}Step 2: Power off random rmod
    ${nodes}   Get Dictionary With Testline PDU Details
    ${radio_list}   Get Random radio Object    alias=${alias}
    ${radio_sn}   Set Variable     ${radio_list[0]['serialNumber']}
    ${pdu_model}   Set Variable    ${nodes['${radio_sn}']['pdu_model']}
    ${pdu_ip}   Set Variable    ${nodes['${radio_sn}']['pdu_ip']}
    ${pdu_port}   Set Variable    ${nodes['${radio_sn}']['pdu_port']}
    IF  ${node_count}==${1}
        ${pdu_version}  Set Variable  ${nodes['${radio_sn}']['pdu_version']}
    ELSE
        ${pdu_version}  Set Variable  ${testlines.${testline_id}.pdu_1.pdu_version}
    END

    taf.hw.pdu.Setup Pdu    host=${pdu_ip}    model=${pdu_model}    version=${pdu_version}
    taf.hw.pdu.Power On    ${pdu_port}

    Log To Console    ${\n}Step 3: Check if mandatory alarms raised on eNB

#Alarm not mentioned in TC description
#    Log To Console    Looking for active alarm:${\n}${expected_alarm_1}
#    Wait For Watchdog Alarm Activation    fault_id=${expected_alarm_1}[fault_id]    fault_name=${expected_alarm_1}[fault_name]
#    ...                                   severity=${expected_alarm_1}[severity]    timeout=30
#    Wait For Watchdog Alarm Deactivation    fault_id=${expected_alarm_1}[fault_id]    fault_name=${expected_alarm_1}[fault_name]
#    ...                                     severity=${expected_alarm_1}[severity]    timeout=240
    Remove Fault From Watchdog Ignored List    fault_id=${expected_alarm_1}[fault_id]    fault_name=${expected_alarm_1}[fault_name]
    ...                                        severity=${expected_alarm_1}[severity]

    Log To Console    Looking for active alarm:${\n}${expected_alarm_2}
    Wait For Watchdog Alarm Activation    fault_id=${expected_alarm_2}[fault_id]    fault_name=${expected_alarm_2}[fault_name]
    ...                                   severity=${expected_alarm_2}[severity]    timeout=30

    Log To Console    Looking for active alarm:${\n}${expected_alarm_3}
    Wait For Watchdog Alarm Activation    fault_id=${expected_alarm_3}[fault_id]    fault_name=${expected_alarm_3}[fault_name]
    ...                                   severity=${expected_alarm_3}[severity]    timeout=30

    Wait For All Cells To Be OnAir    wait_time=3min

    Log To Console    ${\n}Step 4: (Optional) Recover from 1 faulty rmod.
    taf.hw.pdu.Power Off    ${pdu_port}

    Wait For Watchdog Alarm Deactivation    fault_id=${expected_alarm_2}[fault_id]    fault_name=${expected_alarm_2}[fault_name]
    ...                                     severity=${expected_alarm_2}[severity]    timeout=240
    Wait For Watchdog Alarm Deactivation    fault_id=${expected_alarm_3}[fault_id]    fault_name=${expected_alarm_3}[fault_name]
    ...                                     severity=${expected_alarm_3}[severity]    timeout=60

    Remove Fault From Watchdog Ignored List    fault_id=${expected_alarm_2}[fault_id]    fault_name=${expected_alarm_2}[fault_name]
    ...                                        severity=${expected_alarm_2}[severity]
    Remove Fault From Watchdog Ignored List    fault_id=${expected_alarm_3}[fault_id]    fault_name=${expected_alarm_3}[fault_name]
    ...                                        severity=${expected_alarm_3}[severity]

    Wait For All Cells To Be OnAir    wait_time=3min

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           Disable CBRS Feature On eNB    AND
    ...                           Kill All SAS Processes    AND
    ...                           Check If Cells Are Disabled    enb_id=${bts_id}
