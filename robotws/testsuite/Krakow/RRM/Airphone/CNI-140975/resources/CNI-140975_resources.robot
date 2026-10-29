*** Settings ***
Documentation
...        Maintainers:
...           Arkadiusz Sobejko, arkadiusz.sobejko@nokia.com
...        Authors:
...           Arkadiusz Sobejko, arkadiusz.sobejko@nokia.com
...        Description:  Common keywords for CNI-140975

Library     OperatingSystem
Library     Telnet
Library     ute_fsmaccess
Library     ute_tshark
Library     ta5g_tshark
Library     ta5g_iphy
Library     ta_emss
Library     ta5g_pm_counters
Library     taf.ul.ue.sim.env_setup
Library     ../../resources/former_l2_sw1/python/traffic_handling.py
Library     ../../resources/former_l2_sw1/python/ue_handling.py
Library     CNI-140975_resources.py

Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    ../../resources/former_l2_sw1/robot/common_keywords.robot
Resource    ../../resources/former_l2_sw1/robot/collectors.robot
Resource    ../../resources/former_l2_sw1/robot/ssh.robot


*** Variables ***
${ue_db}=          ${CURDIR}/../config/UEDB.db

*** Keywords ***
Prepare AP_CUS suite environment Setup
    Log To Console    Setup started
    Logcollector start
    Configure VM interfaces
    Configure interface for MME
    ${CONFIGURE_ENV}    get variable value    ${configure}    "false"
    Run keyword if  ${CONFIGURE_ENV}=="True"
    ...    Configure suite environment

    Setup egate  egate_port=20000  alias=default
    Setup emss in test

Configure suite environment
    Add gnb configuration    host_id=1    scfc=${SCF}
    Add simulator    sim_type=airphone    config=${AP_XML}
    Add simulator    sim_type=cus    config=${cus_ini},${ue_db}
    Add 5gc  config=${egate_config}  edaemon_ports=10000
    Configure environment    rmod_detection_timeout=600s    validate_gnb=True

Configure interface for MME
    OperatingSystem.Run    sudo ip addr add 10.0.1.3/24 dev eth3

Check radios availability and reach on air
    [Arguments]    ${egate_config}
    CNI-140975_resources.Check radios availability
    Sleep    10s    reason=wait radio and cell setup
    Execute egate Command    sim_reset
    Sleep    2s    reason=wait for reset command execution
    Execute egate Command    sim_cfg file\=${egate_config}
    Sleep    15s    reason=wait for setup egate configuration
    Wait for enb on air    timeout=600


Allowed alarms in onair
    alarms_watchdog.Allow alarm    alarm_id=7220    fault_id=61524    fault_name=SSH enabled
    alarms_watchdog.Allow alarm    alarm_id=7220    fault_id=61649    fault_name=LMP access via port 443
    alarms_watchdog.Allow alarm    alarm_id=7220    fault_id=61652    fault_name=R&D Service Port enabled
    alarms_watchdog.Allow alarm    alarm_id=7220    fault_id=4654     fault_name=Ethernet port security is disabled
    alarms_watchdog.Allow alarm    alarm_id=7220    fault_id=4655     fault_name=Service account root access is enabled


Check That Data Is Being Transmitted On ${num_of_cells} Cells
    FOR    ${cell_id}    IN RANGE    111    ${num_of_cells}+111
        Run keyword and continue on failure    wait till cell reaches tput  cell=${cell_id}   expected_tput=5    dir=dl    timeout=30
        Run keyword and continue on failure    wait till cell reaches tput  cell=${cell_id}   expected_tput=5    dir=ul    timeout=30
    END


Block unblock NR cells
    [Arguments]    ${num_of_cells}
    FOR    ${cell_id}    IN RANGE    1    ${num_of_cells}+1
        CNI-140975_resources.Block cell    cell_id=${cell_id}    cell_type=NR
        CNI-140975_resources.Unblock cell    cell_id=${cell_id}    cell_type=NR
    END


NR L3 call
    [Arguments]    ${ue_number}    ${ue_per_cell}    ${cell_number}
    ${ue_id}=    Set Variable    1
    Set suite variable    ${ue_id}
    FOR    ${cell_id}    IN RANGE    1    ${cell_number}+1
        FOR    ${i}    IN RANGE    ${ue_per_cell}
            Set pdu param for internal traffic    UE_ID=${ue_id}    PDU_ID=1
            Register UE    UE_ID=${ue_id}    CELL_ID=${cell_id}
            Establish PDU session    UE_ID=${ue_id}    PDU_ID=1
            Start SA traffic  ue=${ue_id}  pdu=1    dir=dl  traffic_rate=20Mbps
            Start SA traffic  ue=${ue_id}  pdu=1    dir=ul  traffic_rate=10Mbps
            ${ue_id}=    Set Variable    ${${ue_id} + 1}
        END
    END

    FOR    ${ue}    IN RANGE    1    ${ue_number}+1
        Run keyword and continue on failure    Verify SA traffic  ue=${ue}    pdu=1    dir=DL    expected_traffic=20Mbps
        Run keyword and continue on failure    Verify SA traffic  ue=${ue}    pdu=1    dir=UL    expected_traffic=10Mbps
    END
    [Teardown]    Deregister multi ues    first_ue_id=1    last_ue_id=${ue_number}


Manual SiSo SM cell Block Unblock
    [Arguments]    ${LTE_L3_call}    ${NR_L3_call}
    ...            ${5G_ue_number}    ${5G_ue_per_cell}    ${5G_cell_number}
    ...            ${LTE_cell_number}    ${LTE_scenario}

    [Documentation]    Keyword is for preparing cells block and unblock
    ...                Keyword detect NR and LTE cells and prepare operations
    ...                If LTE L3 call set to True - need prepare additional CUS scenario similar as /scn directory
    ...                If NR L3 call set to True - need add information how many cells,
    ...                ues and ues_per cells also this should be configured in wts config
    Allowed alarms in onair
    alarms_watchdog.Watch alarms

    alarms_watchdog.Allow alarm    alarm_id=7102    fault_id=49      fault_name=Cell blocked
    alarms_watchdog.Allow alarm    alarm_id=7107    fault_id=6327    fault_name=Setup of X2 connectivity to gNB failed
    alarms_watchdog.Allow alarm    alarm_id=7107    fault_id=7300    fault_name=No X2 link available

    Run keyword if   ${NR_L3_call}   NR L3 call    ue_number=${5G_ue_number}    ue_per_cell=${5G_ue_per_cell}    cell_number=${5G_cell_number}

    Run keyword if   ${LTE_L3_call}    Run keywords
    ...    start_scenario  ${LTE_scenario}
    ...    AND    Sleep    60s    reason=wait for CUS scenario completed
    ...    AND    Check That Data Is Being Transmitted On ${LTE_cell_number} Cells
    ...    AND    stop_scenario

    CNI-140975_resources.Block all cells    cell_type=NR
    CNI-140975_resources.Block all cells    cell_type=LTE

    alarms_watchdog.Check detected alarms

    CNI-140975_resources.Unblock all cells    cell_type=NR
    CNI-140975_resources.Unblock all cells    cell_type=LTE

    # WA until CNI-134056 not delivered, need unblock NR cell one by one
    Block unblock NR cells    num_of_cells=${5G_cell_number}

    Wait for enb discovery    timeout=300
    Wait for enb on air    timeout=600
    Run keyword if   ${NR_L3_call}   NR L3 call    ue_number=${5G_ue_number}    ue_per_cell=${5G_ue_per_cell}    cell_number=${5G_cell_number}

    Run keyword if   ${LTE_L3_call}    Run keywords
    ...    start_scenario  ${LTE_scenario}
    ...    AND    Sleep    60s    reason=wait for CUS scenario completed
    ...    AND    Check That Data Is Being Transmitted On ${LTE_cell_number} Cells
    ...    AND    stop_scenario

    alarms_watchdog.Disallow alarm    alarm_id=7102    fault_id=49      fault_name=Cell blocked
    alarms_watchdog.Disallow alarm    alarm_id=7107    fault_id=6327    fault_name=Setup of X2 connectivity to gNB failed
    alarms_watchdog.Disallow alarm    alarm_id=7107    fault_id=7300    fault_name=No X2 link available
    alarms_watchdog.Check detected alarms

    [Teardown]    alarms_watchdog.Stop watching alarms


Manual SiSo SM BTS site reset
    [Arguments]    ${LTE_L3_call}    ${NR_L3_call}
    ...            ${5G_ue_number}    ${5G_ue_per_cell}    ${5G_cell_number}
    ...            ${LTE_cell_number}    ${LTE_scenario}

    [Documentation]    Keyword is for preparing BTS site reset
    ...                If LTE L3 call set to True - need prepare additional CUS scenario similar as /scn directory
    ...                If NR L3 call set to True - need add information how many cells,
    ...                ues and ues_per cells also this should be configured in wts config
    Allowed alarms in onair
    alarms_watchdog.Watch alarms

    alarms_watchdog.Allow alarm    alarm_id=7107    fault_id=6327    fault_name=Setup of X2 connectivity to gNB failed
    alarms_watchdog.Allow alarm    alarm_id=7115    fault_id=4592    fault_name=BTS Reset Cause
    alarms_watchdog.Allow alarm    alarm_id=7107    fault_id=7304    fault_name=NG SCTP endpoint broken
    alarms_watchdog.Allow alarm    alarm_id=7114    fault_id=7107
    ...                            fault_name=Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability
    alarms_watchdog.Allow alarm    alarm_id=7107    fault_id=7305    fault_name=NG SCTP setup fail
    alarms_watchdog.Allow alarm    alarm_id=7107    fault_id=6202    fault_name=Transport layer connection failure in S1 interface

    CNI-140975_resources.Site Reset
    Check radios availability and reach on air    cfg_file=${egate_config}
    alarms_watchdog.Check detected alarms

    Run keyword if   ${NR_L3_call}   NR L3 call    ue_number=${5G_ue_number}    ue_per_cell=${5G_ue_per_cell}    cell_number=${5G_cell_number}

    Run keyword if   ${LTE_L3_call}    Run keywords
    ...    start_scenario  ${LTE_scenario}
    ...    AND    Sleep    60s    reason=wait for CUS scenario completed
    ...    AND    Check That Data Is Being Transmitted On ${LTE_cell_number} Cells
    ...    AND    stop_scenario

    alarms_watchdog.Disallow alarm    alarm_id=7107    fault_id=6202    fault_name=Transport layer connection failure in S1 interface
    alarms_watchdog.Disallow alarm    alarm_id=7107    fault_id=7305    fault_name=NG SCTP setup fail
    alarms_watchdog.Disallow alarm    alarm_id=7114    fault_id=7107
    ...                               fault_name=Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability
    alarms_watchdog.Disallow alarm    alarm_id=7107    fault_id=7304    fault_name=NG SCTP endpoint broken
    alarms_watchdog.Disallow alarm    alarm_id=7107    fault_id=6327    fault_name=Setup of X2 connectivity to gNB failed
    alarms_watchdog.Disallow alarm    alarm_id=7115    fault_id=4592    fault_name=BTS Reset Cause

    alarms_watchdog.Check detected alarms

    [Teardown]    alarms_watchdog.Stop watching alarms

Soft RAT reset
    [Arguments]    ${rat_type}    ${LTE_L3_call}    ${NR_L3_call}
    ...            ${5G_ue_number}    ${5G_ue_per_cell}    ${5G_cell_number}
    ...            ${LTE_cell_number}    ${LTE_scenario}

    [Documentation]    Keyword is for preparing Soft RAT reset
    ...                Need add rat_type eg. NR, LTE, WCDMA or GSM
    ...                If LTE L3 call set to True - need prepare additional CUS scenario similar as /scn directory
    ...                If NR L3 call set to True - need add information how many cells,
    ...                ues and ues_per cells also this should be configured in wts config
    Allowed alarms in onair
    alarms_watchdog.Watch alarms
    alarms_watchdog.Allow alarm    alarm_id=7114    fault_id=7107
    ...    fault_name=Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability

    CNI-140975_resources.Rat reset    rat_type=${rat_type}    graceful_cell_shutdown=True    reset_type=Soft

    alarms_watchdog.Check detected alarms

    alarms_watchdog.Disallow alarm    alarm_id=7114    fault_id=7107
    ...    fault_name=Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability

    Run keyword if   ${NR_L3_call}   NR L3 call    ue_number=${5G_ue_number}    ue_per_cell=${5G_ue_per_cell}    cell_number=${5G_cell_number}

    Run keyword if   ${LTE_L3_call}    Run keywords
    ...    start_scenario  ${LTE_scenario}
    ...    AND    Sleep    60s    reason=wait for CUS scenario completed
    ...    AND    Check That Data Is Being Transmitted On ${LTE_cell_number} Cells
    ...    AND    stop_scenario

    alarms_watchdog.Check detected alarms

    [Teardown]    alarms_watchdog.Stop watching alarms

Hard RAT reset
    [Arguments]    ${rat_type}    ${LTE_L3_call}    ${NR_L3_call}
    ...            ${5G_ue_number}    ${5G_ue_per_cell}    ${5G_cell_number}
    ...            ${LTE_cell_number}    ${LTE_scenario}

    [Documentation]    Keyword is for preparing Hard RAT reset
    ...                If LTE L3 call set to True - need prepare additional CUS scenario similar as /scn directory
    ...                If NR L3 call set to True - need add information how many cells,
    ...                ues and ues_per cells also this should be configured in wts config
    Allowed alarms in onair
    alarms_watchdog.Watch alarms

    CNI-140975_resources.Rat reset    rat_type=${rat_type}    graceful_cell_shutdown=True    reset_type=Hard
    alarms_watchdog.Check detected alarms

    Run keyword if   ${NR_L3_call}   NR L3 call    ue_number=${5G_ue_number}    ue_per_cell=${5G_ue_per_cell}    cell_number=${5G_cell_number}

    Run keyword if   ${LTE_L3_call}    Run keywords
    ...    start_scenario  ${LTE_scenario}
    ...    AND    Sleep    60s    reason=wait for CUS scenario completed
    ...    AND    Check That Data Is Being Transmitted On ${LTE_cell_number} Cells
    ...    AND    stop_scenario

    alarms_watchdog.Check detected alarms

    [Teardown]     alarms_watchdog.Stop watching alarms


General SiSo RAT Block Unblock
    [Arguments]    ${LTE_L3_call}    ${NR_L3_call}
    ...            ${5G_ue_number}    ${5G_ue_per_cell}    ${5G_cell_number}
    ...            ${LTE_cell_number}    ${LTE_scenario}

    [Documentation]    Keyword is for preparing rat block and unblock
    ...                If LTE L3 call set to True - need prepare additional CUS scenario similar as /scn directory
    ...                If NR L3 call set to True - need add information how many cells,
    ...                ues and ues_per cells also this should be configured in wts config
    Allowed alarms in onair
    alarms_watchdog.Watch alarms

    alarms_watchdog.Allow alarm    alarm_id=7102    fault_id=4614    fault_name=RAT blocked

    Run keyword if   ${NR_L3_call}   NR L3 call    ue_number=${5G_ue_number}    ue_per_cell=${5G_ue_per_cell}    cell_number=${5G_cell_number}

    Run keyword if   ${LTE_L3_call}    Run keywords
    ...    start_scenario  ${LTE_scenario}
    ...    AND    Sleep    60s    reason=wait for CUS scenario completed
    ...    AND    Check That Data Is Being Transmitted On ${LTE_cell_number} Cells
    ...    AND    stop_scenario

    CNI-140975_resources.Block rat    rat_type=NR
    CNI-140975_resources.Block rat    rat_type=LTE

    alarms_watchdog.Check detected alarms

    CNI-140975_resources.Unblock rat    rat_type=NR
    CNI-140975_resources.Unblock rat    rat_type=LTE

    alarms_watchdog.Check detected alarms

    alarms_watchdog.Allow alarm    alarm_id=7102    fault_id=49      fault_name=Cell blocked

    # WA until CNI-134056 not delivered, need unblock NR cell one by one
    Block unblock NR cells    num_of_cells=${5G_cell_number}

    Wait for enb discovery    timeout=300
    Wait for enb on air    timeout=600
    alarms_watchdog.Check detected alarms
    Run keyword if   ${NR_L3_call}   NR L3 call    ue_number=${5G_ue_number}    ue_per_cell=${5G_ue_per_cell}    cell_number=${5G_cell_number}

    Run keyword if   ${LTE_L3_call}    Run keywords
    ...    start_scenario  ${LTE_scenario}
    ...    AND    Sleep    60s    reason=wait for CUS scenario completed
    ...    AND    Check That Data Is Being Transmitted On ${LTE_cell_number} Cells
    ...    AND    stop_scenario

    alarms_watchdog.Disallow alarm    alarm_id=7102    fault_id=4614    fault_name=RAT blocked
    alarms_watchdog.Disallow alarm    alarm_id=7102    fault_id=49      fault_name=Cell blocked
    alarms_watchdog.Check detected alarms

    [Teardown]    alarms_watchdog.Stop watching alarms

Manual SiSo SM BTS Block Site
    [Arguments]    ${LTE_L3_call}    ${NR_L3_call}
    ...            ${5G_ue_number}    ${5G_ue_per_cell}    ${5G_cell_number}
    ...            ${LTE_cell_number}    ${LTE_scenario}

    [Documentation]    Keyword is for preparing BTS block and unblock
    ...                If LTE L3 call set to True - need prepare additional CUS scenario similar as /scn directory
    ...                If NR L3 call set to True - need add information how many cells,
    ...                ues and ues_per cells also this should be configured in wts config
    Allowed alarms in onair
    alarms_watchdog.Watch alarms

    alarms_watchdog.Allow alarm    alarm_id=7102    fault_id=50    fault_name=BTS blocked

    Run keyword if   ${NR_L3_call}   NR L3 call    ue_number=${5G_ue_number}    ue_per_cell=${5G_ue_per_cell}    cell_number=${5G_cell_number}

    Run keyword if   ${LTE_L3_call}    Run keywords
    ...    start_scenario  ${LTE_scenario}
    ...    AND    Sleep    60s    reason=wait for CUS scenario completed
    ...    AND    Check That Data Is Being Transmitted On ${LTE_cell_number} Cells
    ...    AND    stop_scenario

    CNI-140975_resources.Block bts

    alarms_watchdog.Check detected alarms
    alarms_watchdog.Allow alarm    alarm_id=7115    fault_id=4592    fault_name=BTS Reset Cause
    CNI-140975_resources.Unblock bts
    Wait for enb discovery    timeout=300
    Wait for enb on air    timeout=600

    alarms_watchdog.Disallow alarm    alarm_id=7102    fault_id=50    fault_name=BTS blocked
    alarms_watchdog.Check detected alarms

    alarms_watchdog.Allow alarm    alarm_id=7102    fault_id=49      fault_name=Cell blocked

    # WA until CNI-134056 not delivered, need unblock NR cell one by one
    Block unblock NR cells    num_of_cells=${5G_cell_number}

    Wait for enb discovery    timeout=300
    Wait for enb on air    timeout=600
    alarms_watchdog.Check detected alarms
    Run keyword if   ${NR_L3_call}   NR L3 call    ue_number=${5G_ue_number}    ue_per_cell=${5G_ue_per_cell}    cell_number=${5G_cell_number}

    Run keyword if   ${LTE_L3_call}    Run keywords
    ...    start_scenario  ${LTE_scenario}
    ...    AND    Sleep    60s    reason=wait for CUS scenario completed
    ...    AND    Check That Data Is Being Transmitted On ${LTE_cell_number} Cells
    ...    AND    stop_scenario

    alarms_watchdog.Disallow alarm    alarm_id=7115    fault_id=4592    fault_name=BTS Reset Cause
    alarms_watchdog.Disallow alarm    alarm_id=7102    fault_id=49      fault_name=Cell blocked

    alarms_watchdog.Check detected alarms

    [Teardown]    alarms_watchdog.Stop watching alarms

General SiSo Auto Cell lock and unlock with L3call
    [Arguments]    ${LTE_L3_call}    ${NR_L3_call}
    ...            ${5G_ue_number}    ${5G_ue_per_cell}    ${5G_cell_number}
    ...            ${LTE_cell_number}    ${LTE_scenario}

    [Documentation]    Keyword is for preparing cells lock and unlock
    ...                Keyword detect NR and LTE cells and prepare operations
    ...                If LTE L3 call set to True - need prepare additional CUS scenario similar as /scn directory
    ...                If NR L3 call set to True - need add information how many cells,
    ...                ues and ues_per cells also this should be configured in wts config
    Allowed alarms in onair
    alarms_watchdog.Watch alarms


    Run keyword if   ${NR_L3_call}   NR L3 call    ue_number=${5G_ue_number}    ue_per_cell=${5G_ue_per_cell}    cell_number=${5G_cell_number}

    Run keyword if   ${LTE_L3_call}    Run keywords
    ...    start_scenario  ${LTE_scenario}
    ...    AND    Sleep    60s    reason=wait for CUS scenario completed
    ...    AND    Check That Data Is Being Transmitted On ${LTE_cell_number} Cells
    ...    AND    stop_scenario

    CNI-140975_resources.Lock all cells    cell_type=NR
    CNI-140975_resources.Lock all cells    cell_type=LTE

    alarms_watchdog.Check detected alarms

    CNI-140975_resources.Unlock all cells    cell_type=NR
    CNI-140975_resources.Unlock all cells    cell_type=LTE

    alarms_watchdog.Allow alarm    alarm_id=7102    fault_id=49      fault_name=Cell blocked

    # WA until CNI-134056 not delivered, need unblock NR cell one by one
    Block unblock NR cells    num_of_cells=${5G_cell_number}

    Wait for enb discovery    timeout=300
    Wait for enb on air    timeout=600
    alarms_watchdog.Check detected alarms
    Run keyword if   ${NR_L3_call}   NR L3 call    ue_number=${5G_ue_number}    ue_per_cell=${5G_ue_per_cell}    cell_number=${5G_cell_number}

    Run keyword if   ${LTE_L3_call}    Run keywords
    ...    start_scenario  ${LTE_scenario}
    ...    AND    Sleep    60s    reason=wait for CUS scenario completed
    ...    AND    Check That Data Is Being Transmitted On ${LTE_cell_number} Cells
    ...    AND    stop_scenario

    alarms_watchdog.Disallow alarm    alarm_id=7102    fault_id=49      fault_name=Cell blocked
    alarms_watchdog.Check detected alarms

    [Teardown]    alarms_watchdog.Stop watching alarms
