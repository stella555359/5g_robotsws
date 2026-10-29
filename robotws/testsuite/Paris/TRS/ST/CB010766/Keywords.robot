*** Settings ***
Documentation
...                 author: David Jollivet
...                 contact: david.jollivet@nokia.com
...                 CB010766: Deep Sleep Mode Support for RF6.1 TDD RRH

Resource            CommonKeywords.robot


*** Keywords ***
CB010766 Setup
    Log To Console    CB010766 setup
    # BTS is OnAir
    # Run Keyword And Continue on failure    COAM Get Bts status enabled    ${bts_addr}

Test Setup
    Log To Console    Test setup
    # BTS is OnAir
    # Run Keyword And Continue on failure    COAM Get Bts status enabled    ${bts_addr}

    # Start the logs
    # Start All Logs

Test Teardown
    Log To Console    Test teardown
    # Save the logs and get Snapshot
    # Get All Logs

    # BTS is OnAir
    # Run Keyword And Continue on failure    COAM Get Bts status enabled    ${bts_addr}

# 10766 TC_02

dedicated time window configuration for deep sleep mode
    # SCF is loaded on BTS
    ${status}=    COAM SCF Load    ${bts_addr}    ${scf_file_10766}
    Log To Console    ${status}

    # BTS is OnAir
    Wait Until Keyword Succeeds    30 min    1 min    Check All Cells Enabled    ${enb_addr}    ${bts_addr}

    # Get RMOD value of AZQJ (like RMOD-1)
    ${RMODX}=    Get RMOD VAL    ${bts_addr}    AZQJ

    # Counter pathes change after 24R1
    ${branch}=    COAM Get SW Branch    ${bts_addr}
    ${energy_counter_path}=    Set Variable If
    ...    "${branch}" == "SBTS24R1"
    ...    BTS/${gnb_mrbts}/${RMODX}/SBTS_RFM_Energy_Monitoring
    ...    ${gnb_mrbts}/EQM-1/APEQM-1/${RMODX}/SBTS_RFM_Energy_Monitoring

    # STEP 1

    ${param1}=    Create List    ${gnb_mrbts}/MNL-1/MNLENT-1/PMMNL-1    mtSBTSRfmEnergyMonitoring    15min
    ${param2}=    Create List    ${gnb_mrbts}/MNL-1/MNLENT-1/FEATCADM-1    actPowerMeter    true
    ${params}=    Create List    ${param1}    ${param2}
    COAM Delta Commissioning    ${bts_addr}    ${params}

    # We need to wait for a new full counter period
    Sleep    30 minutes

    ${RU_power_normal}=    COAM Get PM counter    ${bts_addr}    BTS    ${energy_counter_path}    M40003C2

    Log To Console    RU consumption in normal mode:
    Log To Console    ${RU_power_normal}

    # STEP 3

    ${AZQJ_powerState}=    Get AZQJ PowerState    ${bts_addr}
    # RU is not yet in SLEEP mode
    Should Not Be Equal    ${AZQJ_powerState}    SLEEP

    # Activate the deep sleep mode for RU
    ${param1}=    Create List    ${gnb_mrbts}/EQM-1/APEQM-1/${RMODX}    energySavingMode    DEEPSLEEP
    ${param2}=    Create List    ${gnb_mrbts}/MNL-1/MNLENT-1/FEATCADM-1    actRadioDeepSleepTimeSchedule    true
    ${param3}=    Create List    ${gnb_mrbts}/EQM-1/APEQM-1/${RMODX}    advanceTimeForRURestore    10
    ${day}=    Create Dictionary
    ...    dayOfWeek=Every day    startTime=00:00    windowDuration=1440
    ${days}=    Create List    ${day}
    ${param4}=    Create List    ${gnb_mrbts}/EQM-1/APEQM-1/${RMODX}    deepSleepTimeSchedule    ${days}
    ${params}=    Create List    ${param1}    ${param2}    ${param3}    ${param4}
    COAM Delta Commissioning    ${bts_addr}    ${params}

    # BTS is OnAir
    Wait Until Keyword Succeeds    30 min    1 min    Check All Cells Enabled    ${enb_addr}    ${bts_addr}

    # STEP 4
    COAM Block Cell    ${bts_addr}    ${gnb_mrbts}/${gnb_nrbts}/${NRCELL}
    COAM Block Cell    ${bts_addr}    ${enb_mrbts}/${enb_lnbts}/${LTECELL}

    # Wait grace period
    Sleep    6 minutes

    ${AZQJ_powerState}=    Get AZQJ PowerState    ${bts_addr}
    # RU is in SLEEP mode
    Should Be Equal    ${AZQJ_powerState}    SLEEP

    # eCPRI is still "configuration" and "synchronization"
    Check eCPRI Status    ${bts_addr}

    # TOPP is still locked
    # Check TOPP Status    ${bts_addr}

    # X2 is still available
    Check X2 Status    ${bts_addr}

    # Step 5

    # We need to wait for a new full counter period
    Sleep    30 minutes

    ${RU_power_sleep}=    COAM Get PM counter    ${bts_addr}    BTS    ${energy_counter_path}    M40003C2

    Log To Console    RU consumption in sleep mode:
    Log To Console    ${RU_power_sleep}

    ${RU_power_normal}=    Convert To Number    ${RU_power_normal}
    ${RU_power_sleep}=    Convert To Number    ${RU_power_sleep}

    ${energySaving_success}=    Evaluate    ${RU_power_sleep}/${RU_power_normal} < 0.75

    Should be True    ${energySaving_success}

    # Step +
    COAM Unblock Cell    ${bts_addr}    ${gnb_mrbts}/${gnb_nrbts}/${NRCELL}
    COAM Unblock Cell    ${bts_addr}    ${enb_mrbts}/${enb_lnbts}/${LTECELL}

    # RU restarts
    Sleep    10 minutes
    ${AZQJ_powerState}=    Get AZQJ PowerState    ${bts_addr}
    # RU is in AWAKE mode
    Should Be Equal    ${AZQJ_powerState}    AWAKE

Test Debug
    Check eCPRI Status    ${bts_addr}
