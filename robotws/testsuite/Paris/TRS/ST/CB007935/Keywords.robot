*** Settings ***
Documentation
...                 author: David Jollivet
...                 contact: david.jollivet@nokia.com
...                 CB007935: Deep Sleep Mode Support for RF6.1 TDD RRH

Resource            CommonKeywords.robot


*** Keywords ***
CB007935 Setup
    Log To Console    CB007935 setup
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

    # PTP is restored
    Run Keyword And Continue on failure    Trigger recovery of ptp synchro    ${tl.tl_ptp['AVQL']}

# CB007935_A_TC_01 SyncE_assisted_HO_period_estimation_with_warm_reset on RU Yoda

check Warm Reset on Yoda
    # SCF is loaded on BTS
    ${status}=    COAM SCF Load    ${bts_addr}    ${scf_file_7935}
    Log To Console    ${status}

    # BTS is OnAir
    Wait Until Keyword Succeeds    30 min    1 min    Check All Cells Enabled    ${enb_addr}    ${bts_addr}

    # Get RMOD value of AVQL (like RMOD-1)
    ${RMODX}=    Get RMOD VAL    ${bts_addr}    AVQL

    # Wait for HO estimation to be > 0
    Wait until Keyword Succeeds    120 min    15 min    COAM Check PM counter Superior or equal
    ...    ${bts_addr}    BTS    ${gnb_mrbts}/EQM-1/APEQM-1/${RMODX}/RU_SyncE_HO_Period    M40122C0    1
    ${assisted_ho_duration}=    COAM Get PM counter
    ...    ${bts_addr}
    ...    BTS
    ...    ${gnb_mrbts}/EQM-1/APEQM-1/${RMODX}/RU_SyncE_HO_Period
    ...    M40122C0
    ${net_rearrangements_before}=    COAM Get PM counter
    ...    ${bts_addr}
    ...    BTS
    ...    ${gnb_mrbts}/EQM-1/APEQM-1/${RMODX}/RU_SyncE_Netw_ReArrgt
    ...    M40121C0

    # Reset Site
    COAM gNB Reset Site    ${bts_addr}
    Wait Until Keyword Succeeds    15 min    1 min    COAM Get Bts status enabled    ${bts_addr}

    # Wait 15 min for counters availability and check value of Assisted HO is not decremented
    Wait until Keyword Succeeds
    ...    20 min
    ...    5 min
    ...    COAM Check PM counter Superior or equal
    ...    ${bts_addr}
    ...    BTS
    ...    ${gnb_mrbts}/EQM-1/APEQM-1/${RMODX}/RU_SyncE_HO_Period
    ...    M40122C0
    ...    ${assisted_ho_duration}

    # Reset site is not a major rearrangement
    ${net_rearrangements_after}=    COAM Get PM counter
    ...    ${bts_addr}
    ...    BTS
    ...    ${gnb_mrbts}/EQM-1/APEQM-1/${RMODX}/RU_SyncE_Netw_ReArrgt
    ...    M40121C0
    Should Be Equal    ${net_rearrangements_before}    ${net_rearrangements_after}

# CB007935_A_TC_03 SyncE_modify_acceptance_level_SSM_QL on RU Yoda

change SSM acceptance Level on Yoda
    # SCF is loaded on BTS
    # ${status}=    COAM SCF Load    ${bts_addr}    ${scf_file_7935}
    # Log To Console    ${status}

    # BTS is OnAir
    Wait Until Keyword Succeeds    30 min    1 min    Check All Cells Enabled    ${enb_addr}    ${bts_addr}

    # Get RMOD value of AVQL (like RMOD-1)
    ${RMODX}=    Get RMOD VAL    ${bts_addr}    AVQL

    ${ssm_list}=    Create List
    ${tmp}=    Create Dictionary    ssm=ssmSSUorST2    accepted=True
    Append to List    ${ssm_list}    ${tmp}
    ${tmp}=    Create Dictionary    ssm=ssmePRTC    accepted=False
    Append to List    ${ssm_list}    ${tmp}
    ${tmp}=    Create Dictionary    ssm=ssmPRTCorePRTC    accepted=False
    Append to List    ${ssm_list}    ${tmp}
    ${tmp}=    Create Dictionary    ssm=ssmePRCorePRTC    accepted=False
    Append to List    ${ssm_list}    ${tmp}
    ${tmp}=    Create Dictionary    ssm=ssmePRCorPRTCorePRTC    accepted=False
    Append to List    ${ssm_list}    ${tmp}
    ${tmp}=    Create Dictionary    ssm=ssmPRCorPRS    accepted=True
    Append to List    ${ssm_list}    ${tmp}

    FOR    ${ssmAL}    IN    @{ssm_list}
        Run Keyword And Continue on failure
        ...    COAM Parameter Online update
        ...    ${bts_addr}
        ...    ${gnb_mrbts}/MNL-1/MNLENT-1/${sync}/CLOCK-1/SYNCE-1
        ...    ssmAcceptanceLevel
        ...    ${ssmAL["ssm"]}

        IF    ${ssmAL["accepted"]} == True
            Wait until Keyword Succeeds
            ...    10 min
            ...    1 min
            ...    COAM Check Fault Not Displayed in webEM
            ...    ${bts_addr}
            ...    4781
            Check synceStatus is OK    ${bts_addr}
            ${mtie}=    Get RU MTIE line number
            ...    ${bts_addr}
            ...    toor4nsn
            ...    oZPS0POrRieRtu
            ...    ${AVQL_user}
            ...    ${AVQL_pass}
            ...    AVQL
            Should Be True    ${mtie}>0
        ELSE
            Wait until Keyword Succeeds
            ...    10 min
            ...    1 min
            ...    COAM Check Fault Displayed in webEM
            ...    ${bts_addr}
            ...    4781
            Check synceStatus is NOK    ${bts_addr}
            ${mtie}=    Get RU MTIE line number
            ...    ${bts_addr}
            ...    toor4nsn
            ...    oZPS0POrRieRtu
            ...    ${AVQL_user}
            ...    ${AVQL_pass}
            ...    AVQL
            Should Be True    ${mtie}==0
        END
    END

# CB007935_B_TC_02 SyncE_assisted_HO_period expiration on RU Yoda

HO expiration on RU Yoda
    # SCF is loaded on BTS
    # ${status}=    COAM SCF Load    ${bts_addr}    ${scf_file_7935}
    # Log To Console    ${status}

    # BTS is OnAir
    Wait Until Keyword Succeeds    30 min    1 min    Check All Cells Enabled    ${enb_addr}    ${bts_addr}

    # Get RMOD value of AVQL (like RMOD-1)
    ${RMODX}=    Get RMOD VAL    ${bts_addr}    AVQL

    # Wait for HO estimation to be > 0
    Wait until Keyword Succeeds    120 min    15 min    COAM Check PM counter Superior or equal
    ...    ${bts_addr}    BTS    ${gnb_mrbts}/EQM-1/APEQM-1/${RMODX}/RU_SyncE_HO_Period    M40122C0    1
    ${assisted_ho_duration}=    COAM Get PM counter
    ...    ${bts_addr}
    ...    BTS
    ...    ${gnb_mrbts}/EQM-1/APEQM-1/${RMODX}/RU_SyncE_HO_Period
    ...    M40122C0
    ${rearrangements_before}=    COAM Get PM counter
    ...    ${bts_addr}
    ...    BTS
    ...    ${gnb_mrbts}/EQM-1/APEQM-1/${RMODX}/RU_SyncE_Netw_ReArrgt
    ...    M40121C0

    # PTP is lost
    Run Keyword And Continue on failure    Trigger lost of ptp synchro    ${tl.tl_ptp['AVQL']}

    # Wait for TOP reference alarm
    Wait until Keyword Succeeds    10 min    1 min    COAM Check Fault Displayed in webEM    ${bts_addr}    4298

    ${HO_min}=    Evaluate    ${assisted_ho_duration} * 3600 - 1800

    Sleep    ${HO_min}
    COAM Check Fault Not Displayed in webEM    ${bts_addr}    16

    Sleep    3600

    COAM Check Fault Displayed in webEM    ${bts_addr}    16

    # PTP is restored
    Run Keyword And Continue on failure    Trigger recovery of ptp synchro    ${tl.tl_ptp['AVQL']}

    # Wait for TOP reference missing alarm
    Wait until Keyword Succeeds    10 min    1 min    COAM Check Fault Not Displayed in webEM    ${bts_addr}    4298

# CB007935_C_TC_02_SyncE_manual_assisted_HO_until_expiration _on_RU_Yoda

manual HO expiration on RU Yoda
    # SCF is loaded on BTS
    # ${status}=    COAM SCF Load    ${bts_addr}    ${scf_file_7935}
    # Log To Console    ${status}

    # BTS is OnAir
    Wait Until Keyword Succeeds    30 min    1 min    Check All Cells Enabled    ${enb_addr}    ${bts_addr}

    # Get RMOD value of AVQL (like RMOD-1)
    ${RMODX}=    Get RMOD VAL    ${bts_addr}    AVQL

    # Parameter changes to manual HO
    ${param1}=    Create List    ${gnb_mrbts}/MNL-1/MNLENT-1/${sync}    synceAssistedHoldoverMode    ManualHoldover
    ${param2}=    Create List    ${gnb_mrbts}/MNL-1/MNLENT-1/${sync}    manualSynceAssistedHoPeriod    1
    ${params}=    Create List    ${param1}    ${param2}
    COAM Delta Commissioning    ${bts_addr}    ${params}

    # BTS is OnAir
    Wait Until Keyword Succeeds    30 min    1 min    Check All Cells Enabled    ${enb_addr}    ${bts_addr}

    # PTP is lost
    Run Keyword And Continue on failure    Trigger lost of ptp synchro    ${tl.tl_ptp['AVQL']}

    # Current Time
    ${start_currentTime}=    Get Time

    # Time to end checks
    ${endTimeMax}=    Add Time To Date    ${start_currentTime}    ${estimated_sec_max}
    ${maxTime}=    Convert Date    ${endTimeMax}    epoch

    # Earliest Time to have alarm
    ${endTimeMin}=    Add Time To Date    ${start_currentTime}    ${estimated_sec_min}
    ${minTime}=    Convert Date    ${endTimeMin}    epoch

    # Wait for TOP reference missing alarm
    Wait until Keyword Succeeds    10 min    1 min    COAM Check Fault Displayed in webEM    ${bts_addr}    4298

    # While...
    FOR    ${index}    IN RANGE    9999
        ${currentTime}=    Get Time
        ${epochDate}=    Convert Date    ${currentTime}    epoch
        IF    ${epochDate} > ${minTime}    BREAK

        COAM Check Fault Not Displayed in webEM    ${bts_addr}    16

        Sleep    120s
    END

    # While...
    FOR    ${index}    IN RANGE    9999
        ${status}    ${result}=    Run Keyword And Ignore Error
        ...    COAM Check Fault Displayed in webEM
        ...    ${bts_addr}
        ...    16
        ${currentTime}=    Get Time
        ${epochDate}=    Convert Date    ${currentTime}    epoch

        # no alarm yet
        IF    "${status}" == "FAIL"
            # exit if time is over
            IF    ${epochDate} > ${maxTime}    BREAK    ELSE    Sleep    60s

            # exit if alarm
        ELSE
            BREAK
        END
    END

    # test fails is no alarm (for loop exit condition)
    Should Be True    ${epochDate} > ${minTime}

    # PTP is restored
    Run Keyword And Continue on failure    Trigger recovery of ptp synchro    ${tl.tl_ptp['AVQL']}

    # Wait for TOP reference missing alarm
    Wait until Keyword Succeeds    10 min    1 min    COAM Check Fault Not Displayed in webEM    ${bts_addr}    4298

# CB007935_B_TC_33 SyncE Assisted HO and Deep Sleep mode_I

Assisted HO and Deep Sleep Mode
    # Get RMOD value of AVQL (like RMOD-1)
    ${RMODX}=    Get RMOD VAL    ${bts_addr}    AVQL

    # RU is not yet in DEEPSLEEP mode
    ${AVQL_powerState}=    Get AVQL PowerState    ${bts_addr}
    Should Be Equal    ${AVQL_powerState}    AWAKE

    # Wait for HO estimation to be > 0
    Wait until Keyword Succeeds    120 min    15 min    COAM Check PM counter Superior or equal
    ...    ${bts_addr}    BTS    ${gnb_mrbts}/EQM-1/APEQM-1/${RMODX}/RU_SyncE_HO_Period    M40122C0    1
    ${assisted_ho_duration}=    COAM Get PM counter
    ...    ${bts_addr}
    ...    BTS
    ...    ${gnb_mrbts}/EQM-1/APEQM-1/${RMODX}/RU_SyncE_HO_Period
    ...    M40122C0
    ${net_rearrangements_before}=    COAM Get PM counter
    ...    ${bts_addr}
    ...    BTS
    ...    ${gnb_mrbts}/EQM-1/APEQM-1/${RMODX}/RU_SyncE_Netw_ReArrgt
    ...    M40121C0

    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${bts_addr}
    ...    ${gnb_mrbts}/EQM-1/APEQM-1/${RMODX}
    ...    energySavingMode
    ...    DEEPSLEEP
    Sleep    10s

    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${bts_addr}
    ...    ${gnb_mrbts}/EQM-1/APEQM-1/${RMODX}
    ...    administrativeState
    ...    Locked
    Sleep    360s

    # RU is now in DEEPSLEEP mode
    ${AVQL_powerState}=    Get AVQL PowerState    ${bts_addr}
    Should Be Equal    ${AVQL_powerState}    SLEEP

    Sleep    1800s

    ${assisted_ho_duration}=    COAM Get PM counter
    ...    ${bts_addr}
    ...    BTS
    ...    ${gnb_mrbts}/EQM-1/APEQM-1/${RMODX}/RU_SyncE_HO_Period
    ...    M40122C0
    Should Be Equal    ${assisted_ho_duration}    0
    ${net_rearrangements}=    COAM Get PM counter
    ...    ${bts_addr}
    ...    BTS
    ...    ${gnb_mrbts}/EQM-1/APEQM-1/${RMODX}/RU_SyncE_Netw_ReArrgt
    ...    M40121C0
    Should Be Equal    ${net_rearrangements}    ${net_rearrangements_before}

    # RU is unlocked again
    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${bts_addr}
    ...    ${gnb_mrbts}/EQM-1/APEQM-1/${RMODX}
    ...    administrativeState
    ...    Unlocked

    # RU restarts
    Sleep    300s

    # RU is no more in DEEPSLEEP mode
    ${AVQL_powerState}=    Get AVQL PowerState    ${bts_addr}
    Should Be Equal As Integers    ${AVQL_powerState}    AWAKE

    # Wait for HO estimation to be > 0
    Wait until Keyword Succeeds    120 min    15 min    COAM Check PM counter Superior or equal
    ...    ${bts_addr}    BTS    ${gnb_mrbts}/EQM-1/APEQM-1/${RMODX}/RU_SyncE_HO_Period    M40122C0    1

    # Restore initial configuration
    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${bts_addr}
    ...    ${gnb_mrbts}/EQM-1/APEQM-1/${RMODX}
    ...    energySavingMode
    ...    NORMAL
