*** Settings ***
Documentation
...                 author: David Jollivet
...                 contact: david.jollivet@nokia.com
...                 CB006627: SyncE Assisted Holdover


*** Keywords ***
CB006627 Setup
    Log To Console    CB006627 setup
    # BTS is OnAir
    Run Keyword And Continue on failure    COAM Get Bts status enabled    ${bts_addr}

Test Setup
    Log To Console    Test setup
    # BTS is OnAir
    Run Keyword And Continue on failure    COAM Get Bts status enabled    ${bts_addr}

    # Start the logs
    # Start All Logs

Test Teardown
    Log To Console    Test teardown
    # Save the logs and get Snapshot
    # Get All Logs

    # BTS is OnAir
    Run Keyword And Continue on failure    COAM Get Bts status enabled    ${bts_addr}

    # If test stops early, restore PTP (done for nothing if test passed)
    Run Keyword And Continue on failure    Trigger recovery of ptp synchro    ${tl.tl_ptp['4G']}
    Run Keyword And Continue on failure    Trigger change of synce SSM    ${tl.tl_synce['4G']}    prc

# TC 01

Period Estimation With Warm Reset
    # Online parameter changes
    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${enb_addr}
    ...    ${enb_mrbts}/MNL-1/MNLENT-1/FEATCADM-1
    ...    actIntelligentSynceAssHoTime
    ...    true
    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${enb_addr}
    ...    ${enb_mrbts}/MNL-1/MNLENT-1/SYNC-1
    ...    synceAssistedHoldoverMode
    ...    IntelligentHoldover
    Run Keyword And Ignore Error    COAM Parameter Online delete    ${enb_addr}    ${enb_mrbts}/MNL-1/MNLENT-1/SYNC-1
    ...    manualSynceAssistedHoPeriod
    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${enb_addr}
    ...    ${enb_mrbts}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/SYNCE-1
    ...    synceNtwReAgtForceMajor
    ...    false

    # BTS is OnAir : Above changes are Online
    Run Keyword And Continue on failure    COAM Get Bts status enabled    ${enb_addr}

    # Counter pathes change after 24R1
    ${branch}=    COAM Get SW Branch    ${bts_addr}
    ${synce_counter_path}=    Set Variable If    "${branch}" == "SBTS24R1"
    ...    BTS/${enb_mrbts}/SYNC-1/CLOCK-1/SYNCE-1    ${enb_mrbts}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/SYNCE-1

    # Wait for HO estimation to be > 0
    Wait until Keyword Succeeds    120 min    15 min    COAM Check PM counter Superior or equal
    ...    ${enb_addr}    BTS    ${synce_counter_path}/${HO_period_Cpt_name}    ${HO_period_Cpt_num}    1

    # Get HO estimation value and synceNetworkRearrangements value
    ${assisted_ho_duration}=    COAM Get PM counter
    ...    ${enb_addr}
    ...    BTS
    ...    ${synce_counter_path}/${HO_period_Cpt_name}
    ...    ${HO_period_Cpt_num}
    ${net_rearrangements_before}=    COAM Get PM counter
    ...    ${enb_addr}
    ...    BTS
    ...    ${synce_counter_path}/SyncE_ReArrgt
    ...    M40109C0

    # Reset Site
    COAM gNB Reset Site    ${enb_addr}
    Wait Until Keyword Succeeds    15 min    1 min    COAM Get Bts status enabled    ${enb_addr}

    # Wait 15 min for counters availability and check value of Assisted HO is not decremented
    Wait until Keyword Succeeds
    ...    20 min
    ...    5 min
    ...    COAM Check PM counter Superior or equal
    ...    ${enb_addr}
    ...    BTS
    ...    ${synce_counter_path}/${HO_period_Cpt_name}
    ...    ${HO_period_Cpt_num}
    ...    ${assisted_ho_duration}

    # Reset site is not a major rearrangement
    ${net_rearrangements_after}=    COAM Get PM counter
    ...    ${enb_addr}
    ...    BTS
    ...    ${synce_counter_path}/SyncE_ReArrgt
    ...    M40109C0
    Should Be Equal    ${net_rearrangements_before}    ${net_rearrangements_after}

# TC 11

Assisted HO After Sync Loss
    # Online parameter changes
    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${enb_addr}
    ...    ${enb_mrbts}/MNL-1/MNLENT-1/FEATCADM-1
    ...    actIntelligentSynceAssHoTime
    ...    true
    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${enb_addr}
    ...    ${enb_mrbts}/MNL-1/MNLENT-1/SYNC-1
    ...    synceAssistedHoldoverMode
    ...    IntelligentHoldover
    Run Keyword And Ignore Error    COAM Parameter Online delete    ${enb_addr}    ${enb_mrbts}/MNL-1/MNLENT-1/SYNC-1
    ...    manualSynceAssistedHoPeriod
    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${enb_addr}
    ...    ${enb_mrbts}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/SYNCE-1
    ...    synceNtwReAgtForceMajor
    ...    false

    # BTS is OnAir : Above changes are Online
    Run Keyword And Continue on failure    COAM Get Bts status enabled    ${enb_addr}

    # Counter pathes change after 24R1
    ${branch}=    COAM Get SW Branch    ${bts_addr}
    ${synce_counter_path}=    Set Variable If    "${branch}" == "SBTS24R1"
    ...    BTS/${enb_mrbts}/SYNC-1/CLOCK-1/SYNCE-1    ${enb_mrbts}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/SYNCE-1

    # Check PTP and SyncE are Usable
    ${res}=    COAM Get TOPP Status    ${enb_addr}
    Should Be Equal    ${res}    Usable
    ${res}=    COAM Get SYNCE Status    ${enb_addr}
    Should Be Equal    ${res}    Usable

    # Wait for HO estimation to be > 0
    Wait until Keyword Succeeds    120 min    15 min    COAM Check PM counter Superior or equal
    ...    ${enb_addr}    BTS    ${synce_counter_path}/${HO_period_Cpt_name}    ${HO_period_Cpt_num}    1

    # Wait for Assisted HO period > Adaptive HO period
    Wait until Keyword Succeeds    180 min    5 min    COAM Check Fault not Displayed in webEM    ${enb_addr}    4712
    Wait until Keyword Succeeds    180 min    5 min    COAM Check Fault not Displayed in webEM    ${enb_addr}    4710

    # PTP is lost
    Run Keyword And Continue on failure    Trigger lost of ptp synchro    ${tl.tl_ptp['4G']}

    # Wait for TOP reference missing alarm
    Wait until Keyword Succeeds    10 min    1 min    COAM Check Fault Displayed in webEM    ${enb_addr}    4298

    # Check PTP and SyncE
    ${res}=    COAM Get TOPP Status    ${enb_addr}
    Should Be Equal    ${res}    Unusable
    ${res}=    COAM Get SYNCE Status    ${enb_addr}
    Should Be Equal    ${res}    Usable

    # We should be in Assisted HO
    ${mode}=    COAM Get Tuning Mode    ${enb_addr}
    Should Be Equal    ${mode}    Intelligent assisted holdover

    # PTP is restored
    Run Keyword And Continue on failure    Trigger recovery of ptp synchro    ${tl.tl_ptp['4G']}

    # Wait for TOP reference missing alarm to disappear
    Wait until Keyword Succeeds    10 min    1 min    COAM Check Fault not Displayed in webEM    ${enb_addr}    4298

# TC 50

Manual Assisted HO After Minor Impairment
    # Online parameter changes
    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${enb_addr}
    ...    ${enb_mrbts}/MNL-1/MNLENT-1/FEATCADM-1
    ...    actIntelligentSynceAssHoTime
    ...    true
    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${enb_addr}
    ...    ${enb_mrbts}/MNL-1/MNLENT-1/SYNC-1
    ...    synceAssistedHoldoverMode
    ...    ManualHoldoverWithTransitionToAdaptive
    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${enb_addr}
    ...    ${enb_mrbts}/MNL-1/MNLENT-1/SYNC-1
    ...    manualSynceAssistedHoPeriod
    ...    600
    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${enb_addr}
    ...    ${enb_mrbts}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/SYNCE-1
    ...    synceNtwReAgtForceMajor
    ...    false

    # BTS is OnAir after parameter changes : no reset
    Run Keyword And Continue on failure    COAM Get Bts status enabled    ${enb_addr}

    # Counter pathes change after 24R1
    ${branch}=    COAM Get SW Branch    ${bts_addr}
    ${synce_counter_path}=    Set Variable If    "${branch}" == "SBTS24R1"
    ...    BTS/${enb_mrbts}/SYNC-1/CLOCK-1/SYNCE-1    ${enb_mrbts}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/SYNCE-1

    # Wait for Assisted HO period > Adaptive HO period
    Wait until Keyword Succeeds    60 min    5 min    COAM Check Fault not Displayed in webEM    ${enb_addr}    4712
    Wait until Keyword Succeeds    60 min    5 min    COAM Check Fault not Displayed in webEM    ${enb_addr}    4710

    # PTP is lost
    Run Keyword And Continue on failure    Trigger lost of ptp synchro    ${tl.tl_ptp['4G']}

    # Wait for TOP reference missing alarm
    Wait until Keyword Succeeds    10 min    1 min    COAM Check Fault Displayed in webEM    ${enb_addr}    4298

    # Check PTP and SyncE
    ${res}=    COAM Get TOPP Status    ${enb_addr}
    Should Be Equal    ${res}    Unusable
    ${res}=    COAM Get SYNCE Status    ${enb_addr}
    Should Be Equal    ${res}    Usable

    ${mode}=    COAM Get Tuning Mode    ${enb_addr}
    Should Be Equal    ${mode}    Manual assisted holdover to adaptive with transition

    ${net_rearrangements_before}=    COAM Get PM counter
    ...    ${enb_addr}
    ...    BTS
    ...    ${synce_counter_path}/SyncE_ReArrgt
    ...    M40109C0

    # Reset Site
    COAM gNB Reset Site    ${enb_addr}

    # TDD is not OnAir
    Sleep    15 minutes
    IF    '${HO_period_Cpt_name}' == 'SyncE_FDD_HO'
        COAM Get Bts status enabled    ${enb_addr}
    END

    # Frequency Mode after Reset Site
    ${syncMode}=    COAM Get Synchronization Mode    ${enb_addr}
    Should Be Equal    ${syncMode}    FreqSync

    # Check PTP and SyncE
    ${res}=    COAM Get TOPP Status    ${enb_addr}
    Should Be Equal    ${res}    Unusable
    ${res}=    COAM Get SYNCE Status    ${enb_addr}
    Should Be Equal    ${res}    Usable

    # Wait 15 min for counters availability and check that rearrangement is not incremented by reset site
    # Check : Sleep    15 minutes
    ${net_rearrangements_after}=    Wait until Keyword Succeeds    20 min    5 min
    ...    COAM Get PM counter    ${enb_addr}    BTS    ${synce_counter_path}/SyncE_ReArrgt    M40109C0
    Should Be Equal    ${net_rearrangements_before}    ${net_rearrangements_after}

    # PTP is restored
    Run Keyword And Continue on failure    Trigger recovery of ptp synchro    ${tl.tl_ptp['4G']}

    # Reset Site to recover phase synchronisation
    COAM gNB Reset Site    ${enb_addr}

    # BTS is OnAir after PTP restoration and Site Reset
    Wait Until Keyword Succeeds    15 min    1 min    COAM Get 5g status enabled    ${bts_addr}

# TC 13

SyncE Assisted HO Expiration Short Duration
    # Online parameter changes
    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${enb_addr}
    ...    ${enb_mrbts}/MNL-1/MNLENT-1/FEATCADM-1
    ...    actIntelligentSynceAssHoTime
    ...    true
    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${enb_addr}
    ...    ${enb_mrbts}/MNL-1/MNLENT-1/SYNC-1
    ...    synceAssistedHoldoverMode
    ...    IntelligentHoldover
    Run Keyword And Ignore Error    COAM Parameter Online delete    ${enb_addr}    ${enb_mrbts}/MNL-1/MNLENT-1/SYNC-1
    ...    manualSynceAssistedHoPeriod

    # BTS is OnAir after parameter changes : no reset
    Run Keyword And Continue on failure    COAM Get Bts status enabled    ${enb_addr}

    # Counter pathes change after 24R1
    ${branch}=    COAM Get SW Branch    ${bts_addr}
    ${synce_counter_path}=    Set Variable If    "${branch}" == "SBTS24R1"
    ...    BTS/${enb_mrbts}/SYNC-1/CLOCK-1/SYNCE-1    ${enb_mrbts}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/SYNCE-1

    # Check PTP and SyncE are Usable
    ${res}=    COAM Get TOPP Status    ${enb_addr}
    Should Be Equal    ${res}    Usable
    ${res}=    COAM Get SYNCE Status    ${enb_addr}
    Should Be Equal    ${res}    Usable

    # Wait for Assisted HO period > Adaptive HO period
    Wait until Keyword Succeeds    60 min    5 min    COAM Check Fault not Displayed in webEM    ${enb_addr}    4712
    Wait until Keyword Succeeds    60 min    5 min    COAM Check Fault not Displayed in webEM    ${enb_addr}    4710

    # Wait for HO estimation to be > 0
    Wait until Keyword Succeeds    120 min    15 min    COAM Check PM counter Superior or equal
    ...    ${enb_addr}    BTS    ${synce_counter_path}/${HO_period_Cpt_name}    ${HO_period_Cpt_num}    1

    # Get HO estimation value and synceNetworkRearrangements value
    ${assisted_ho_duration}=    COAM Get PM counter
    ...    ${enb_addr}
    ...    BTS
    ...    BTS/${enb_mrbts}/SYNC-1/CLOCK-1/SYNCE-1/${HO_period_Cpt_name}
    ...    ${HO_period_Cpt_num}
    ${net_rearrangements_before}=    COAM Get PM counter
    ...    ${enb_addr}
    ...    BTS
    ...    ${synce_counter_path}/SyncE_ReArrgt
    ...    M40109C0

    # PTP is lost
    Run Keyword And Continue on failure    Trigger lost of ptp synchro    ${tl.tl_ptp['4G']}

    # Wait for TOP reference missing alarm
    Wait until Keyword Succeeds    10 min    1 min    COAM Check Fault Displayed in webEM    ${enb_addr}    4298

    # Check PTP and SyncE
    ${res}=    COAM Get TOPP Status    ${enb_addr}
    Should Be Equal    ${res}    Unusable
    ${res}=    COAM Get SYNCE Status    ${enb_addr}
    Should Be Equal    ${res}    Usable

    # We should be in Assisted HO
    ${mode}=    COAM Get Tuning Mode    ${enb_addr}
    Should Be Equal    ${mode}    Intelligent assisted holdover

    # Wait for end of assisted HO time
    Sleep    ${assisted_ho_duration} hours

    # 5G is down
    Wait until Keyword Succeeds    1 hour    5 min    COAM Get 5g status disabled    ${bts_addr}
    COAM Check Fault Displayed in webEM    ${enb_addr}    4452

    # PTP is restored
    Run Keyword And Continue on failure    Trigger recovery of ptp synchro    ${tl.tl_ptp['4G']}

    # BTS is OnAir after PTP restoration and Site Reset
    Wait Until Keyword Succeeds    15 min    1 min    COAM Get 5g status enabled    ${bts_addr}

# TC 21

Intelligent Assisted HO After Minor Impairment
    # Online parameter changes
    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${enb_addr}
    ...    ${enb_mrbts}/MNL-1/MNLENT-1/FEATCADM-1
    ...    actIntelligentSynceAssHoTime
    ...    true
    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${enb_addr}
    ...    ${enb_mrbts}/MNL-1/MNLENT-1/SYNC-1
    ...    synceAssistedHoldoverMode
    ...    IntelligentHoldover
    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${enb_addr}
    ...    ${enb_mrbts}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/SYNCE-1
    ...    synceNtwReAgtForceMajor
    ...    false

    # BTS is OnAir after parameter changes : no reset
    Run Keyword And Continue on failure    COAM Get Bts status enabled    ${enb_addr}

    # Counter pathes change after 24R1
    ${branch}=    COAM Get SW Branch    ${bts_addr}
    ${synce_counter_path}=    Set Variable If    "${branch}" == "SBTS24R1"
    ...    BTS/${enb_mrbts}/SYNC-1/CLOCK-1/SYNCE-1    ${enb_mrbts}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/SYNCE-1

    # Wait for Assisted HO period > Adaptive HO period
    Wait until Keyword Succeeds    60 min    5 min    COAM Check Fault not Displayed in webEM    ${enb_addr}    4712
    Wait until Keyword Succeeds    60 min    5 min    COAM Check Fault not Displayed in webEM    ${enb_addr}    4710

    # PTP is lost
    Run Keyword And Continue on failure    Trigger lost of ptp synchro    ${tl.tl_ptp['4G']}

    # Wait for TOP reference missing alarm
    Wait until Keyword Succeeds    10 min    1 min    COAM Check Fault Displayed in webEM    ${enb_addr}    4298

    # Check PTP and SyncE
    ${res}=    COAM Get TOPP Status    ${enb_addr}
    Should Be Equal    ${res}    Unusable
    ${res}=    COAM Get SYNCE Status    ${enb_addr}
    Should Be Equal    ${res}    Usable

    ${mode}=    COAM Get Tuning Mode    ${enb_addr}
    Should Be Equal    ${mode}    Intelligent assisted holdover

    ${net_rearrangements_before}=    COAM Get PM counter
    ...    ${enb_addr}
    ...    BTS
    ...    ${synce_counter_path}/SyncE_ReArrgt
    ...    M40109C0

    # Reset Site
    COAM gNB Reset Site    ${enb_addr}
    Wait Until Keyword Succeeds    15 min    1 min    COAM Get Bts status enabled    ${enb_addr}

    # Frequency Mode after Reset Site
    ${syncMode}=    COAM Get Synchronization Mode    ${enb_addr}
    Should Be Equal    ${syncMode}    FreqSync

    # Check PTP and SyncE
    ${res}=    COAM Get TOPP Status    ${enb_addr}
    Should Be Equal    ${res}    Unusable
    ${res}=    COAM Get SYNCE Status    ${enb_addr}
    Should Be Equal    ${res}    Usable

    # Wait 15 min for counters availability and check that rearrangement is not incremented by reset site
    # Check : Sleep    15 minutes
    ${net_rearrangements_after}=    Wait until Keyword Succeeds    20 min    5 min
    ...    COAM Get PM counter    ${enb_addr}    BTS    ${synce_counter_path}/SyncE_ReArrgt    M40109C0
    Should Be Equal    ${net_rearrangements_before}    ${net_rearrangements_after}

    # PTP is restored
    Run Keyword And Continue on failure    Trigger recovery of ptp synchro    ${tl.tl_ptp['4G']}

    # Reset Site to recover phase synchronisation
    COAM gNB Reset Site    ${enb_addr}

    # BTS is OnAir after PTP restoration and Site Reset
    Wait Until Keyword Succeeds    15 min    1 min    COAM Get 5g status enabled    ${bts_addr}

# TC 40

Manual Assisted HO After Sync Loss
    # Online parameter changes
    &{myDict}=    Create Dictionary
    ...    localPriority=128
    ...    maximumNetworkTimingError=0
    ...    phaseErrorComp=0
    ...    topMasterId=1
    ${myList}=    create list    ${myDict}
    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${enb_addr}
    ...    ${enb_mrbts}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1
    ...    topMasterList
    ...    ${myList}
    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${enb_addr}
    ...    ${enb_mrbts}/MNL-1/MNLENT-1/FEATCADM-1
    ...    actIntelligentSynceAssHoTime
    ...    true
    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${enb_addr}
    ...    ${enb_mrbts}/MNL-1/MNLENT-1/SYNC-1
    ...    synceAssistedHoldoverMode
    ...    ManualHoldoverWithTransitionToAdaptive
    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${enb_addr}
    ...    ${enb_mrbts}/MNL-1/MNLENT-1/SYNC-1
    ...    manualSynceAssistedHoPeriod
    ...    600
    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${enb_addr}
    ...    ${enb_mrbts}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/SYNCE-1
    ...    synceNtwReAgtForceMajor
    ...    false

    # BTS is OnAir after parameter changes : no reset
    Run Keyword And Continue on failure    COAM Get Bts status enabled    ${enb_addr}

    # Counter pathes change after 24R1
    ${branch}=    COAM Get SW Branch    ${bts_addr}
    ${synce_counter_path}=    Set Variable If    "${branch}" == "SBTS24R1"
    ...    BTS/${enb_mrbts}/SYNC-1/CLOCK-1/SYNCE-1    ${enb_mrbts}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/SYNCE-1

    # Check PTP and SyncE are Usable
    ${res}=    COAM Get TOPP Status    ${enb_addr}
    Should Be Equal    ${res}    Usable
    ${res}=    COAM Get SYNCE Status    ${enb_addr}
    Should Be Equal    ${res}    Usable

    # Wait for Assisted HO period > Adaptive HO period
    Wait until Keyword Succeeds    60 min    5 min    COAM Check Fault not Displayed in webEM    ${enb_addr}    4712
    Wait until Keyword Succeeds    60 min    5 min    COAM Check Fault not Displayed in webEM    ${enb_addr}    4710

    # PTP is lost
    Run Keyword And Continue on failure    Trigger lost of ptp synchro    ${tl.tl_ptp['4G']}

    # Wait for TOP reference missing alarm
    Wait until Keyword Succeeds    10 min    1 min    COAM Check Fault Displayed in webEM    ${enb_addr}    4298

    # Check PTP and SyncE
    ${res}=    COAM Get TOPP Status    ${enb_addr}
    Should Be Equal    ${res}    Unusable
    ${res}=    COAM Get SYNCE Status    ${enb_addr}
    Should Be Equal    ${res}    Usable

    # We should be in Assisted HO
    ${mode}=    COAM Get Tuning Mode    ${enb_addr}
    Should Be Equal    ${mode}    Manual assisted holdover to adaptive with transition

    # Wait for TOP reference missing alarm to appear
    Wait until Keyword Succeeds    10 min    1 min    COAM Check Fault Displayed in webEM    ${enb_addr}    4298

    # PTP is restored
    Run Keyword And Continue on failure    Trigger recovery of ptp synchro    ${tl.tl_ptp['4G']}

    # Wait for TOP reference missing alarm to disappear
    Wait until Keyword Succeeds    10 min    1 min    COAM Check Fault not Displayed in webEM    ${enb_addr}    4298

# TC 60

Manual Assisted HO To Adaptive HO
    # Online parameter changes
    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${enb_addr}
    ...    ${enb_mrbts}/MNL-1/MNLENT-1/FEATCADM-1
    ...    actIntelligentSynceAssHoTime
    ...    true
    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${enb_addr}
    ...    ${enb_mrbts}/MNL-1/MNLENT-1/SYNC-1
    ...    synceAssistedHoldoverMode
    ...    ManualHoldoverWithTransitionToAdaptive
    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${enb_addr}
    ...    ${enb_mrbts}/MNL-1/MNLENT-1/SYNC-1
    ...    manualSynceAssistedHoPeriod
    ...    600
    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${enb_addr}
    ...    ${enb_mrbts}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/SYNCE-1
    ...    ssmAcceptanceLevel
    ...    ssmPRCorPRS

    # BTS is OnAir after parameter changes : no reset
    Run Keyword And Continue on failure    COAM Get Bts status enabled    ${enb_addr}

    # Counter pathes change after 24R1
    ${branch}=    COAM Get SW Branch    ${bts_addr}
    ${synce_counter_path}=    Set Variable If    "${branch}" == "SBTS24R1"
    ...    BTS/${enb_mrbts}/SYNC-1/CLOCK-1/SYNCE-1    ${enb_mrbts}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/SYNCE-1

    # PTP is lost
    Run Keyword And Continue on failure    Trigger lost of ptp synchro    ${tl.tl_ptp['4G']}

    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${enb_addr}
    ...    ${enb_mrbts}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/SYNCE-1
    ...    synceNtwReAgtForceMajor
    ...    true

    # Wait for TOP reference missing alarm
    Wait until Keyword Succeeds    10 min    1 min    COAM Check Fault Displayed in webEM    ${enb_addr}    4298

    # Check PTP and SyncE
    ${res}=    COAM Get TOPP Status    ${enb_addr}
    Should Be Equal    ${res}    Unusable
    ${res}=    COAM Get SYNCE Status    ${enb_addr}
    Should Be Equal    ${res}    Usable

    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${enb_addr}
    ...    ${enb_mrbts}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/SYNCE-1
    ...    synceNtwReAgtForceMajor
    ...    true

    ${net_rearrangements_before}=    COAM Get PM counter
    ...    ${enb_addr}
    ...    BTS
    ...    ${synce_counter_path}/SyncE_ReArrgt
    ...    M40109C0

    # Change SSM to unaccepted value
    Trigger change of synce SSM    ${tl.tl_synce['4G']}    ssu_b

    # Check PTP and SyncE
    ${res}=    COAM Get TOPP Status    ${enb_addr}
    Should Be Equal    ${res}    Unusable
    ${res}=    COAM Get SYNCE Status    ${enb_addr}
    Should Be Equal    ${res}    Unusable

    ${mode}=    COAM Get Tuning Mode    ${enb_addr}
    Should Be Equal    ${mode}    Adaptive holdover

    # Wait 15 min and check that rearrangement is incremented due to bad SSM quality and then transition to adpative
    Sleep    15 minutes
    ${net_rearrangements_after}=    Wait until Keyword Succeeds    20 min    5 min
    ...    COAM Get sum PM counter    ${enb_addr}    BTS    ${synce_counter_path}/SyncE_ReArrgt    M40109C0    2
    ${res}=    Evaluate    ${net_rearrangements_after}-${net_rearrangements_before}
    Should Exp Be True    1 <= ${res} <= 2

    # Change SSM to accepted value
    Trigger change of synce SSM    ${tl.tl_synce['4G']}    prc

    # PTP is restored
    Run Keyword And Continue on failure    Trigger recovery of ptp synchro    ${tl.tl_ptp['4G']}

    # BTS is OnAir after PTP restoration and Site Reset
    Wait Until Keyword Succeeds    15 min    1 min    COAM Get 5g status enabled    ${bts_addr}

Test Debug
    COAM Get Parameter Value
    ...    ${enb_addr}
    ...    ${enb_mrbts}/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/MNL_CONF_M-1/MNLENT_CONF-M-1/SYNC_CONF-M-1/SYNC_R-1
    ...    localTimeError
