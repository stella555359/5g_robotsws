*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_TDD    SBTS00

Documentation
...    authors: Arkadiusz Sobejko, Daniel Grzebelec
...    contacts: arkadiusz.sobejko@nokia.com, daniel.grzebelec@nokia.com

Resource      resources/CNI-140975_resources.robot
Library       ta_uexgate
Library       resources/ScenarioExecutor.py
Library       resources/UExGateStats.py
Library       taf.ul.alarms_watchdog    WITH NAME    alarms_watchdog

Suite Setup    Run keywords    Prepare AP_CUS suite environment Setup
...            AND    Create aliases

Suite Teardown    Clean suite environment

*** Variables ***
${egate_config}=    ${CURDIR}/config/config_9a/config_9a_basic_setup.cfg
${cus_ini}=         ${CURDIR}/config/config_9a/cus_config9a.ini
${SCF}=             ${CURDIR}/config/config_9a/SCFC_2FDD_RU_N_type_12_LTE_cells_3_FDD_RU_3_LTE_cells_3FDD_CPRI_4DL4UL_RU_6_NR_cells.xml
${AP_XML}=          ${CURDIR}/config/config_9a/iphy_3_RU_FDD_6cells.xml

*** Test Cases ***
Manual SiSo SM cell Block Unblock
    [Setup]    Run keywords    Allowed alarms in onair
    ...    AND    alarms_watchdog.Watch alarms

    alarms_watchdog.Allow alarm    alarm_id=7102    fault_id=49      fault_name=Cell blocked
    alarms_watchdog.Allow alarm    alarm_id=7107    fault_id=6327    fault_name=Setup of X2 connectivity to gNB failed
    alarms_watchdog.Allow alarm    alarm_id=7107    fault_id=7300    fault_name=No X2 link available

    Start scenario  scenario_cfg_2
    Sleep    60s    reason=wait for CUS scenario completed
    NR L3 call    ue_number=18    ue_per_cell=3    cell_number=6

    Check That Data Is Being Transmitted On 15 Cells
    Stop scenario

    CNI-140975_resources.Block all cells    cell_type=NR
    CNI-140975_resources.Block all cells    cell_type=LTE

    alarms_watchdog.Check detected alarms

    CNI-140975_resources.Unblock all cells    cell_type=NR
    CNI-140975_resources.Unblock all cells    cell_type=LTE

    Wait for enb discovery    timeout=300
    Wait for enb on air    timeout=600

    Start scenario  scenario_cfg_9a
    Sleep    60s    reason=wait for CUS scenario completed
    NR L3 call    ue_number=18    ue_per_cell=3    cell_number=6

    Check That Data Is Being Transmitted On 15 Cells

    alarms_watchdog.Disallow alarm    alarm_id=7102    fault_id=49      fault_name=Cell blocked
    alarms_watchdog.Disallow alarm    alarm_id=7107    fault_id=6327    fault_name=Setup of X2 connectivity to gNB failed
    alarms_watchdog.Disallow alarm    alarm_id=7107    fault_id=7300    fault_name=No X2 link available
    Run keyword and continue on failure    alarms_watchdog.Check detected alarms

    [Teardown]    Run Keywords    Stop scenario
    ...    AND    alarms_watchdog.Stop watching alarms

Manual SiSo SM BTS site reset
    [Setup]    Run keywords    Allowed alarms in onair
    ...    AND    alarms_watchdog.Watch alarms

    alarms_watchdog.Allow alarm    alarm_id=7107    fault_id=6327    fault_name=Setup of X2 connectivity to gNB failed
    alarms_watchdog.Allow alarm    alarm_id=7115    fault_id=4592    fault_name=BTS Reset Cause

    CNI-140975_resources.Site Reset
    alarms_watchdog.Check detected alarms
    Start scenario  scenario_cfg_9a
    Sleep    60s    reason=wait for CUS scenario completed
    NR L3 call    ue_number=18    ue_per_cell=3    cell_number=6

    Check That Data Is Being Transmitted On 15 Cells

    alarms_watchdog.Disallow alarm    alarm_id=7107    fault_id=6327    fault_name=Setup of X2 connectivity to gNB failed
    alarms_watchdog.Disallow alarm    alarm_id=7115    fault_id=4592    fault_name=BTS Reset Cause

    alarms_watchdog.Check detected alarms

    [Teardown]    Run Keywords    Stop scenario
    ...    AND    alarms_watchdog.Stop watching alarms

Soft RAT reset
    [Setup]    Run keywords    Allowed alarms in onair
    ...    AND    alarms_watchdog.Watch alarms

    CNI-140975_resources.Rat reset    rat_type=NR    graceful_cell_shutdown=True    reset_type=Soft
    alarms_watchdog.Check detected alarms

    Start scenario  scenario_cfg_9a
    Sleep    60s    reason=wait for CUS scenario completed
    NR L3 call    ue_number=18    ue_per_cell=3    cell_number=6

    Check That Data Is Being Transmitted On 15 Cells

    CNI-140975_resources.Rat reset    rat_type=LTE    graceful_cell_shutdown=True    reset_type=Soft

    alarms_watchdog.Check detected alarms

    [Teardown]    Run Keywords    Stop scenario
    ...    AND    alarms_watchdog.Stop watching alarms

Hard RAT reset
    [Setup]    Run keywords    Allowed alarms in onair
    ...    AND    alarms_watchdog.Watch alarms

    CNI-140975_resources.Rat reset    rat_type=NR    graceful_cell_shutdown=True    reset_type=Hard
    alarms_watchdog.Check detected alarms

    Start scenario  scenario_cfg_9a
    Sleep    60s    reason=wait for CUS scenario completed
    NR L3 call    ue_number=18    ue_per_cell=3    cell_number=6

    Check That Data Is Being Transmitted On 15 Cells

    CNI-140975_resources.Rat reset    rat_type=LTE    graceful_cell_shutdown=True    reset_type=Hard

    alarms_watchdog.Check detected alarms

    [Teardown]    Run Keywords    Stop scenario
    ...    AND    alarms_watchdog.Stop watching alarms


Manual_SiSo_CM_recommissioning
    [Setup]    Run keywords    Allowed alarms in onair
    ...    AND    alarms_watchdog.Watch alarms

    log to console    Step - 1 parameter change require Site reset
    alarms_watchdog.Allow alarm    alarm_id=7107    fault_id=6327    fault_name=Setup of X2 connectivity to gNB failed
    alarms_watchdog.Allow alarm    alarm_id=7115    fault_id=4592    fault_name=BTS Reset Cause
    Configure  {'MOC': 'CLOCK', 'ID': '1-1-1-1', 'holdOverModeUsed': 'false'}
    Wait for enb on air    timeout=600
    alarms_watchdog.Check detected alarms

    Configure    {'MOC': 'CLOCK', 'ID': '1-1-1-1', 'holdOverModeUsed': 'True'}
    Wait for enb on air    timeout=600
    alarms_watchdog.Check detected alarms

    Start scenario  scenario_cfg_9a
    Sleep    60s    reason=wait for CUS scenario completed
    NR L3 call    ue_number=18    ue_per_cell=3    cell_number=6

    Check That Data Is Being Transmitted On 15 Cells

    alarms_watchdog.Disallow alarm    alarm_id=7107    fault_id=6327    fault_name=Setup of X2 connectivity to gNB failed
    alarms_watchdog.Disallow alarm    alarm_id=7115    fault_id=4592    fault_name=BTS Reset Cause
    alarms_watchdog.Check detected alarms
    Stop scenario


    log to console    Step - 2 parameter change require NR RAT reset
    Configure  {'MOC': 'NRCEL', 'ID': '1', 'enDcSyncStatus': 'none'}
    Wait for enb on air    timeout=600
    alarms_watchdog.Check detected alarms

    Configure  {'MOC': 'NRCEL', 'ID': '1', 'enDcSyncStatus': 'synchronous'}
    Wait for enb on air    timeout=600
    alarms_watchdog.Check detected alarms

    Start scenario  scenario_cfg_9a
    Sleep    60s    reason=wait for CUS scenario completed
    NR L3 call    ue_number=18    ue_per_cell=3    cell_number=6

    Check That Data Is Being Transmitted On 15 Cells

    alarms_watchdog.Check detected alarms
    Stop scenario


    log to console    Step - 3 parameter change require LTE RAT reset
    alarms_watchdog.Allow alarm    alarm_id=7114    fault_id=7107
    ...                            fault_name=Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability
    Configure  {'MOC': 'LNBTS', 'ID': '1', 'actExtN77Support': 'true'}
    Wait for enb on air    timeout=600
    alarms_watchdog.Check detected alarms

    Configure  {'MOC': 'LNBTS', 'ID': '1', 'actExtN77Support': 'false'}
    Wait for enb on air    timeout=600
    alarms_watchdog.Check detected alarms

    Start scenario  scenario_cfg_9a
    Sleep    60s    reason=wait for CUS scenario completed
    NR L3 call    ue_number=18    ue_per_cell=3    cell_number=6

    Check That Data Is Being Transmitted On 15 Cells
    alarms_watchdog.Disallow alarm    alarm_id=7114    fault_id=7107
    ...                            fault_name=Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability
    alarms_watchdog.Check detected alarms
    Stop scenario


    log to console    Step - 4 online parameter change

    Configure  [{'MOC': 'LNCELL', 'ID': '112', 'inactivityTimer': '660'},
    ...         {'MOC': 'NRBTS', 'ID': '1', 'nsaInactivityTimer': '6600'}]

    Wait for enb on air    timeout=600
    alarms_watchdog.Check detected alarms

    Configure  [{'MOC': 'LNCELL', 'ID': '112', 'inactivityTimer': '600'},
    ...         {'MOC': 'NRBTS', 'ID': '1', 'nsaInactivityTimer': '7200'}]
    Wait for enb on air    timeout=600
    alarms_watchdog.Check detected alarms

    Start scenario  scenario_cfg_9a
    Sleep    60s    reason=wait for CUS scenario completed
    NR L3 call    ue_number=18    ue_per_cell=3    cell_number=6

    Check That Data Is Being Transmitted On 15 Cells

    alarms_watchdog.Check detected alarms

    [Teardown]    Run Keywords    Stop scenario
    ...    AND    alarms_watchdog.Stop watching alarms
