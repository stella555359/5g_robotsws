*** Settings ***
Documentation
...                 author: David Jollivet
...                 contact: david.jollivet@nokia.com
...                 CNI81875: SyncE Assisted Holdover


*** Keywords ***
CNI81875 Setup
    # BTS is OnAir
    Run Keyword And Continue on failure    COAM Get 5g status enabled    ${bts_addr}

Test Setup
    # BTS is OnAir
    Run Keyword And Continue on failure    COAM Get 5g status enabled    ${bts_addr}

    # Start the logs
    # Start All Logs

Test Teardown
    # Save the logs and get Snapshot
    # Get All Logs

    # BTS is OnAir
    Run Keyword And Continue on failure    COAM Get 5g status enabled    ${bts_addr}

    # If test stops early, restore PTP (done for nothing if test passed)
    Run Keyword And Continue on failure    Trigger recovery of ptp synchro    ${switchdict_ptp['4G']}

PTP shutdown and GNB Sync Holdover
    [Arguments]    ${SyncEExpectedOutageTime}

    # timers for enabled period and disabled
    ${MinTimer}=    Subtract Time From Time    ${SyncEExpectedOutageTime}    ${Margin}
    ${DiffTimer}=    Add Time to Time    ${Margin}    ${Margin}

    # BTS is OnAir when test starts
    Run Keyword And Continue on failure    COAM Get 5g status enabled    ${bts_addr}

    # PTP port is shutdown on 7705/PTS switch
    Run Keyword And Continue on failure    Trigger lost of ptp synchro    ${switchdict_ptp['4G']}

    # BTS should be OnAir during at least SyncEExpectedOutageTime - Margin
    Execute Keyword Multiple Times    ${MinTimer}    5 min    COAM Get 5g status enabled    ${bts_addr}

    # BTS should not be OffAir after SyncEExpected Outage + Margin
    Wait Until Keyword Succeeds    ${DiffTimer}    5 min    COAM Get 5g status disabled    ${bts_addr}

    # PTP port is set up again and BTS should be OnAir after few minutes
    Run Keyword And Continue on failure    Trigger recovery of ptp synchro    ${switchdict_ptp['4G']}
    Wait Until Keyword Succeeds    10 min    1 min    COAM Get 5g status enabled    ${bts_addr}
