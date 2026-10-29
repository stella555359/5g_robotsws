*** Settings ***
Documentation
...                 author: David Jollivet
...                 contact: david.jollivet@nokia.com
...                 CB006627: Flexible synchronization behavior management

Resource            CommonKeywords.robot


*** Keywords ***
CB006504 Setup
    Log To Console    CB006504 setup
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
    Run Keyword And Continue on failure    Trigger recovery of ptp synchro    ${tl.tl_ptp['5G']}
    Run Keyword And Continue on failure    Trigger recovery of ptp synchro    ${tl.tl_ptp['4G']}

# TC 01

NRTDD disabled and recovery
    # Parameter changes
    ${param1}=    Create List    ${gnb_mrbts}/MNL-1/MNLENT-1/FEATCADM-1    actTimeErrorManagement    true
    ${param2}=    Create List    ${gnb_mrbts}/MNL-1/MNLENT-1/SYNC-1/SYNCTEMPLATE-1    allowApplicationDisabling    true
    ${param3}=    Create List    ${gnb_mrbts}/MNL-1/MNLENT-1/SYNC-1/SYNCTEMPLATE-1    maxTimeToEnableApp    00-00:00:00
    &{myDict}=    Create Dictionary    allowedSyncSource=ALL    maxAbsoluteTimeError=${maxAbsoluteTimeError_for_NRTDD}
    ${myList}=    create list    ${myDict}
    ${param4}=    Create List
    ...    ${gnb_mrbts}/MNL-1/MNLENT-1/SYNC-1/SYNCTEMPLATE-1
    ...    appTimeErrorManagement
    ...    ${myList}
    ${param5}=    Create List
    ...    ${gnb_mrbts}/${gnb_nrbts}
    ...    nrTddSyncTemplateDN
    ...    ${gnb_mrbts}/MNL-1/MNLENT-1/SYNC-1/SYNCTEMPLATE-1
    ${param6}=    Create List    ${gnb_mrbts}/MNL-1/MNLENT-1/FMCADM-1    actForceAutoReset    true
    ${params}=    Create List    ${param1}    ${param2}    ${param3}    ${param4}    ${param5}    ${param6}
    COAM Delta Commissioning    ${bts_addr}    ${params}

    # BTS is OnAir after a reset
    Wait Until Keyword Succeeds    15 min    1 min    Check All Cells Enabled    ${enb_addr}    ${bts_addr}

    # PTP is lost
    Run Keyword And Continue on failure    Trigger lost of ptp synchro    ${tl.tl_ptp['4G']}

    # Wait for TOP reference missing alarm
    # Not done here : alarm is long to appear and 4731 could arrive faster
    # Wait until Keyword Succeeds    10 min    1 min    COAM Check Fault Displayed in webEM    ${bts_addr}    4298

    # Wait for alarm
    ${timeToDisableNRTDD}=    Check FaultId 4731    ${bts_addr}    ${maxAbsoluteTimeError_for_NRTDD}

    # 5G TDD cell is OffAir
    COAM Get 5g status disabled    ${bts_addr}

    # Wait for TOP reference missing alarm
    Wait until Keyword Succeeds    10 min    1 min    COAM Check Fault Displayed in webEM    ${bts_addr}    4298

    ${maxEstimatedLegacyTime}=    Evaluate
    ...    2 * ${timeToDisableNRTDD} * ${eCPRI_maxTimeError} / ${maxAbsoluteTimeError_for_NRTDD}

    # Wait for phase error to continue to increase and eCPRI to be disable
    # Value should be reached after about ${maxEstimatedLegacyTime}/2 - ${timeToDisableNRTDD
    # Here ${timeToDisableNRTDD} is a margin to reach targetted phase error
    Wait Phase Error Larger    ${bts_addr}    ${eCPRI_maxTimeError}    ${maxEstimatedLegacyTime}

    # PhaseErrorExceedsTheInterferenceLimitAl is not raised when the legacy hardcoded time error theshold is exceeded
    COAM Check Fault not Displayed in webEM    ${bts_addr}    4452

    # PTP is restored
    Run Keyword And Continue on failure    Trigger recovery of ptp synchro    ${tl.tl_ptp['4G']}

    # Wait for TOP reference missing alarm to disappear
    Wait until Keyword Succeeds    10 min    1 min    COAM Check Fault not Displayed in webEM    ${bts_addr}    4298

    ${phase_error}=    COAM Get Phase Error    ${bts_addr}
    Should Be True    ${phase_error} < ${maxAbsoluteTimeError_for_NRTDD}

    # 4731 is deleted
    COAM Check Fault not Displayed in webEM    ${bts_addr}    4731

    # 4001 is not raised
    COAM Check Fault not Displayed in webEM    ${bts_addr}    4001

    # 5G TDD cell is OnAir
    Wait Until Keyword Succeeds    2 min    30 sec    COAM Get 5g status enabled    ${bts_addr}

    # New set of parameters
    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${bts_addr}
    ...    ${gnb_mrbts}/MNL-1/MNLENT-1/SYNC-1/SYNCTEMPLATE-1
    ...    allowApplicationDisabling
    ...    false
    # BTS is OnAir after a reset
    Wait Until Keyword Succeeds    15 min    1 min    Check All Cells Enabled    ${enb_addr}    ${bts_addr}

    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${bts_addr}
    ...    ${gnb_mrbts}/MNL-1/MNLENT-1/SYNC-1/SYNCTEMPLATE-1
    ...    maxTimeToEnableApp
    ...    00-05:00:00
    # BTS is OnAir after a reset
    Wait Until Keyword Succeeds    15 min    1 min    Check All Cells Enabled    ${enb_addr}    ${bts_addr}

    # PTP is lost
    Run Keyword And Continue on failure    Trigger lost of ptp synchro    ${tl.tl_ptp['4G']}

    # Wait for TOP reference missing alarm
    # Not done here : alarm is long to appear and 4731 could arrive faster
    # Wait until Keyword Succeeds    10 min    1 min    COAM Check Fault Displayed in webEM    ${bts_addr}    4298

    # Wait for alarm
    ${timeToDisableNRTDD}=    Check FaultId 4731    ${bts_addr}    ${maxAbsoluteTimeError_for_NRTDD}

    # 5G TDD cell is OnAir
    COAM Get 5g status enabled    ${bts_addr}

    # Wait for TOP reference missing alarm
    Wait until Keyword Succeeds    10 min    1 min    COAM Check Fault Displayed in webEM    ${bts_addr}    4298

    ${maxEstimatedLegacyTime}=    Evaluate
    ...    2 * ${timeToDisableNRTDD} * ${eCPRI_maxTimeError} / ${maxAbsoluteTimeError_for_NRTDD}

    # Wait for phase error to continue to increase and eCPRI to be disable
    # Value should be reached after about ${maxEstimatedLegacyTime}/2 - ${timeToDisableNRTDD
    # Here ${timeToDisableNRTDD} is a margin to reach targetted phase error
    Wait Phase Error Larger    ${bts_addr}    ${eCPRI_maxTimeError}    ${maxEstimatedLegacyTime}

    # PhaseErrorExceedsTheInterferenceLimitAl is not raised when the legacy hardcoded time error theshold is exceeded
    COAM Check Fault not Displayed in webEM    ${bts_addr}    4452

    # RMOD can take some seconds to be down
    Sleep    1 min

    # 5G TDD cell is OffAir
    COAM Get 5g status disabled    ${bts_addr}

    # PTP is restored
    Run Keyword And Continue on failure    Trigger recovery of ptp synchro    ${tl.tl_ptp['4G']}

    # Wait for TOP reference missing alarm to disappear
    Wait until Keyword Succeeds    10 min    1 min    COAM Check Fault not Displayed in webEM    ${bts_addr}    4298

    ${phase_error}=    COAM Get Phase Error    ${bts_addr}
    Should Be True    ${phase_error} < ${maxAbsoluteTimeError_for_NRTDD}

    # 4731 is deleted
    COAM Check Fault not Displayed in webEM    ${bts_addr}    4731

    # 4001 is not raised
    COAM Check Fault not Displayed in webEM    ${bts_addr}    4001

    # 5G TDD cell is OnAir
    Wait Until Keyword Succeeds    2 min    30 sec    COAM Get 5g status enabled    ${bts_addr}

# TC 02

ENDC not disabled
    # Parameter changes
    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${enb_addr}
    ...    ${enb_mrbts}/MNL-1/MNLENT-1/FEATCADM-1
    ...    actTimeErrorManagement
    ...    true
    # BTS is OnAir after a reset
    Wait Until Keyword Succeeds    15 min    1 min    COAM Get Bts status enabled    ${enb_addr}

    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${enb_addr}
    ...    ${enb_mrbts}/MNL-1/MNLENT-1/SYNC-1/SYNCTEMPLATE-1
    ...    allowApplicationDisabling
    ...    false
    # BTS is OnAir after a reset
    Wait Until Keyword Succeeds    15 min    1 min    COAM Get Bts status enabled    ${enb_addr}

    &{myDict}=    Create Dictionary
    ...    allowedSyncSource=ALL
    ...    maxAbsoluteTimeError=${maxAbsoluteTimeError_for_ENDC_try}
    ${myList}=    create list    ${myDict}
    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${enb_addr}
    ...    ${enb_mrbts}/MNL-1/MNLENT-1/SYNC-1/SYNCTEMPLATE-1
    ...    appTimeErrorManagement
    ...    ${myList}
    # BTS is OnAir after a reset
    Wait Until Keyword Succeeds    15 min    1 min    COAM Get Bts status enabled    ${enb_addr}

    Run Keyword And Continue on failure    COAM Parameter Online update    ${enb_addr}    ${enb_mrbts}/${enb_lnbts}
    ...    lteNrDcSyncTemplateDN    ${enb_mrbts}/MNL-1/MNLENT-1/SYNC-1/SYNCTEMPLATE-1
    # BTS is OnAir after a reset
    Wait Until Keyword Succeeds    15 min    1 min    COAM Get Bts status enabled    ${enb_addr}

    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${enb_addr}
    ...    ${enb_mrbts}/MNL-1/MNLENT-1/FMCADM-1
    ...    actForceAutoReset
    ...    true
    # BTS is OnAir after a reset
    Wait Until Keyword Succeeds    15 min    1 min    COAM Get Bts status enabled    ${enb_addr}

    # Change maxAbsoluteTimeError to new value
    &{myDict}=    Create Dictionary    allowedSyncSource=ALL    maxAbsoluteTimeError=${maxAbsoluteTimeError_for_ENDC}
    ${myList}=    create list    ${myDict}
    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${enb_addr}
    ...    ${enb_mrbts}/MNL-1/MNLENT-1/SYNC-1/SYNCTEMPLATE-1
    ...    appTimeErrorManagement
    ...    ${myList}
    # BTS is OnAir after a reset
    Wait Until Keyword Succeeds    15 min    1 min    COAM Get Bts status enabled    ${enb_addr}

    # PTP is lost
    Run Keyword And Continue on failure    Trigger lost of ptp synchro    ${tl.tl_ptp['4G']}

    # Wait for alarm
    ${timeToDisableENDC}=    Check FaultId 4731    ${enb_addr}    ${maxAbsoluteTimeError_for_ENDC}

    # Service is not disabled...

    # Wait for TOP reference missing alarm
    Wait until Keyword Succeeds    10 min    1 min    COAM Check Fault Displayed in webEM    ${enb_addr}    4298

    ${maxEstimatedLegacyTime}=    Evaluate
    ...    2 * ${timeToDisableENDC} * ${FDD_maxTimeError} / ${maxAbsoluteTimeError_for_ENDC}

    # Wait for phase error to continue to increase and eCPRI to be disable
    # Value should be reached after about ${maxEstimatedLegacyTime}
    # Here ${timeToDisableNRTDD} is a margin to reach targetted phase error
    Wait Phase Error Larger    ${enb_addr}    ${FDD_maxTimeError}    ${maxEstimatedLegacyTime}

    # BTS is not more OnAir
    COAM Get Bts status disabled    ${enb_addr}

    # PTP is restored
    Run Keyword And Continue on failure    Trigger recovery of ptp synchro    ${tl.tl_ptp['4G']}

    # Wait for TOP reference missing alarm to disappear
    Wait until Keyword Succeeds    10 min    1 min    COAM Check Fault not Displayed in webEM    ${enb_addr}    4298

    ${phase_error}=    COAM Get Phase Error    ${enb_addr}
    Should Be True    ${phase_error} < ${maxAbsoluteTimeError_for_ENDC}

    # 4731 is deleted
    COAM Check Fault not Displayed in webEM    ${enb_addr}    4731

    # BTS is OnAir again
    Wait Until Keyword Succeeds    5 min    1 min    COAM Get Bts status enabled    ${enb_addr}

# TC 03

DSS disabled and recovery
    # Parameter changes
    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${enb_addr}
    ...    ${enb_mrbts}/MNL-1/MNLENT-1/FEATCADM-1
    ...    actTimeErrorManagement
    ...    true
    # BTS is OnAir after a reset
    Wait Until Keyword Succeeds    15 min    1 min    COAM Get Bts status enabled    ${enb_addr}

    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${enb_addr}
    ...    ${enb_mrbts}/MNL-1/MNLENT-1/SYNC-1/SYNCTEMPLATE-1
    ...    allowApplicationDisabling
    ...    true
    # BTS is OnAir after a reset
    Wait Until Keyword Succeeds    15 min    1 min    COAM Get Bts status enabled    ${enb_addr}

    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${bts_addr}
    ...    ${gnb_mrbts}/MNL-1/MNLENT-1/SYNC-1/SYNCTEMPLATE-1
    ...    allowApplicationDisabling
    ...    true
    # BTS is OnAir after a reset
    Wait Until Keyword Succeeds    15 min    1 min    COAM Get Bts status enabled    ${bts_addr}

    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${enb_addr}
    ...    ${enb_mrbts}/MNL-1/MNLENT-1/SYNC-1/SYNCTEMPLATE-1
    ...    maxTimeToEnableApp
    ...    00-00:00:00
    # BTS is OnAir after a reset
    Wait Until Keyword Succeeds    15 min    1 min    COAM Get Bts status enabled    ${enb_addr}

    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${bts_addr}
    ...    ${gnb_mrbts}/MNL-1/MNLENT-1/SYNC-1/SYNCTEMPLATE-1
    ...    maxTimeToEnableApp
    ...    00-00:00:00
    # BTS is OnAir after a reset
    Wait Until Keyword Succeeds    15 min    1 min    COAM Get Bts status enabled    ${bts_addr}

    &{myDict}=    Create Dictionary    allowedSyncSource=ALL    maxAbsoluteTimeError=${maxAbsoluteTimeError_for_DSS}
    ${myList}=    create list    ${myDict}
    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${enb_addr}
    ...    ${enb_mrbts}/MNL-1/MNLENT-1/SYNC-1/SYNCTEMPLATE-1
    ...    appTimeErrorManagement
    ...    ${myList}
    # BTS is OnAir after a reset
    Wait Until Keyword Succeeds    15 min    1 min    COAM Get Bts status enabled    ${enb_addr}

    &{myDict}=    Create Dictionary    allowedSyncSource=ALL    maxAbsoluteTimeError=${maxAbsoluteTimeError_for_DSS}
    ${myList}=    create list    ${myDict}
    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${bts_addr}
    ...    ${gnb_mrbts}/MNL-1/MNLENT-1/SYNC-1/SYNCTEMPLATE-1
    ...    appTimeErrorManagement
    ...    ${myList}
    # BTS is OnAir after a reset
    Wait Until Keyword Succeeds    15 min    1 min    COAM Get Bts status enabled    ${bts_addr}

    Run Keyword And Continue on failure    COAM Parameter Online update    ${enb_addr}    ${enb_mrbts}/${enb_lnbts}
    ...    lteNrDssSyncTemplateDN    ${enb_mrbts}/MNL-1/MNLENT-1/SYNC-1/SYNCTEMPLATE-1
    # BTS is OnAir after a reset
    Wait Until Keyword Succeeds    15 min    1 min    COAM Get Bts status enabled    ${enb_addr}

    Run Keyword And Continue on failure    COAM Parameter Online update    ${bts_addr}    ${gnb_mrbts}/${gnb_nrbts}
    ...    nrLteDssSyncTemplateDN    ${gnb_mrbts}/MNL-1/MNLENT-1/SYNC-1/SYNCTEMPLATE-1
    # BTS is OnAir after a reset
    Wait Until Keyword Succeeds    15 min    1 min    COAM Get Bts status enabled    ${bts_addr}

    # PTP is lost
    Run Keyword And Continue on failure    Trigger lost of ptp synchro    ${tl.tl_ptp['5G']}

    # Wait for alarm
    ${timeToDisableENDC}=    Check FaultId 4731    ${bts_addr}    ${maxAbsoluteTimeError_for_DSS}

    # Wait for TOP reference missing alarm
    Wait until Keyword Succeeds    10 min    1 min    COAM Check Fault Displayed in webEM    ${bts_addr}    4298

    # DSS deactivated alarm on ENB side
    COAM Check Fault Displayed in webEM    ${enb_addr}    6134

    # PTP is restored
    Run Keyword And Continue on failure    Trigger recovery of ptp synchro    ${tl.tl_ptp['5G']}

    # Wait for TOP reference missing alarm to disappear
    Wait until Keyword Succeeds    10 min    1 min    COAM Check Fault not Displayed in webEM    ${bts_addr}    4298

    ${phase_error}=    COAM Get Phase Error    ${bts_addr}
    Should Be True    ${phase_error} < ${maxAbsoluteTimeError_for_DSS}

    # 4731 is deleted
    COAM Check Fault not Displayed in webEM    ${bts_addr}    4731

    # DSS activated again on ENB side
    COAM Check Fault not Displayed in webEM    ${enb_addr}    6134

    # Parameter changes
    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${enb_addr}
    ...    ${enb_mrbts}/MNL-1/MNLENT-1/SYNC-1/SYNCTEMPLATE-1
    ...    allowApplicationDisabling
    ...    false
    # BTS is OnAir after a reset
    Wait Until Keyword Succeeds    15 min    1 min    COAM Get Bts status enabled    ${enb_addr}

    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${bts_addr}
    ...    ${gnb_mrbts}/MNL-1/MNLENT-1/SYNC-1/SYNCTEMPLATE-1
    ...    allowApplicationDisabling
    ...    false
    # BTS is OnAir after a reset
    Wait Until Keyword Succeeds    15 min    1 min    COAM Get Bts status enabled    ${bts_addr}

    # PTP is lost
    Run Keyword And Continue on failure    Trigger lost of ptp synchro    ${tl.tl_ptp['5G']}

    # Wait for alarm
    ${timeToDisableENDC}=    Check FaultId 4731    ${bts_addr}    ${maxAbsoluteTimeError_for_DSS}

    # Wait for TOP reference missing alarm
    Wait until Keyword Succeeds    10 min    1 min    COAM Check Fault Displayed in webEM    ${bts_addr}    4298

    # DSS is not deactivated on ENB side
    COAM Check Fault not Displayed in webEM    ${enb_addr}    6134

    # PTP is restored
    Run Keyword And Continue on failure    Trigger recovery of ptp synchro    ${tl.tl_ptp['5G']}

    # Wait for TOP reference missing alarm to disappear
    Wait until Keyword Succeeds    10 min    1 min    COAM Check Fault not Displayed in webEM    ${bts_addr}    4298

    ${phase_error}=    COAM Get Phase Error    ${bts_addr}
    Should Be True    ${phase_error} < ${maxAbsoluteTimeError_for_DSS}

    # 4731 is deleted
    COAM Check Fault not Displayed in webEM    ${bts_addr}    4731

# TC 14

DSS lock unlock
    # ENB Parameter changes
    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${enb_addr}
    ...    ${enb_mrbts}/MNL-1/MNLENT-1/FEATCADM-1
    ...    actTimeErrorManagement
    ...    true
    # BTS is OnAir after a reset
    Wait Until Keyword Succeeds    15 min    1 min    COAM Get Bts status enabled    ${enb_addr}

    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${enb_addr}
    ...    ${enb_mrbts}/MNL-1/MNLENT-1/SYNC-1/SYNCTEMPLATE-1
    ...    allowApplicationDisabling
    ...    true
    # BTS is OnAir after a reset
    Wait Until Keyword Succeeds    15 min    1 min    COAM Get Bts status enabled    ${enb_addr}

    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${enb_addr}
    ...    ${enb_mrbts}/MNL-1/MNLENT-1/SYNC-1/SYNCTEMPLATE-1
    ...    maxTimeToEnableApp
    ...    00-02:00:00
    # BTS is OnAir after a reset
    Wait Until Keyword Succeeds    15 min    1 min    COAM Get Bts status enabled    ${enb_addr}

    &{myDict}=    Create Dictionary    allowedSyncSource=ALL    maxAbsoluteTimeError=${maxAbsoluteTimeError_for_DSS}
    ${myList}=    create list    ${myDict}
    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${enb_addr}
    ...    ${enb_mrbts}/MNL-1/MNLENT-1/SYNC-1/SYNCTEMPLATE-1
    ...    appTimeErrorManagement
    ...    ${myList}
    # BTS is OnAir after a reset
    Wait Until Keyword Succeeds    15 min    1 min    COAM Get Bts status enabled    ${enb_addr}

    Run Keyword And Continue on failure    COAM Parameter Online update    ${enb_addr}    ${enb_mrbts}/${enb_lnbts}
    ...    lteNrDssSyncTemplateDN    ${enb_mrbts}/MNL-1/MNLENT-1/SYNC-1/SYNCTEMPLATE-1
    # BTS is OnAir after a reset
    Wait Until Keyword Succeeds    15 min    1 min    COAM Get Bts status enabled    ${enb_addr}

    # GNB Parameter changes
    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${bts_addr}
    ...    ${gnb_mrbts}/MNL-1/MNLENT-1/FEATCADM-1
    ...    actTimeErrorManagement
    ...    true
    # BTS is OnAir after a reset
    Wait Until Keyword Succeeds    15 min    1 min    COAM Get Bts status enabled    ${bts_addr}

    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${bts_addr}
    ...    ${gnb_mrbts}/MNL-1/MNLENT-1/SYNC-1/SYNCTEMPLATE-1
    ...    allowApplicationDisabling
    ...    true
    # BTS is OnAir after a reset
    Wait Until Keyword Succeeds    15 min    1 min    COAM Get Bts status enabled    ${bts_addr}

    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${bts_addr}
    ...    ${gnb_mrbts}/MNL-1/MNLENT-1/SYNC-1/SYNCTEMPLATE-1
    ...    maxTimeToEnableApp
    ...    00-02:00:00
    # BTS is OnAir after a reset
    Wait Until Keyword Succeeds    15 min    1 min    COAM Get Bts status enabled    ${bts_addr}

    &{myDict}=    Create Dictionary    allowedSyncSource=ALL    maxAbsoluteTimeError=${maxAbsoluteTimeError_for_DSS}
    ${myList}=    create list    ${myDict}
    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${bts_addr}
    ...    ${gnb_mrbts}/MNL-1/MNLENT-1/SYNC-1/SYNCTEMPLATE-1
    ...    appTimeErrorManagement
    ...    ${myList}
    # BTS is OnAir after a reset
    Wait Until Keyword Succeeds    15 min    1 min    COAM Get Bts status enabled    ${bts_addr}

    Run Keyword And Continue on failure    COAM Parameter Online update    ${bts_addr}    ${gnb_mrbts}/${gnb_nrbts}
    ...    nrLteDssSyncTemplateDN    ${gnb_mrbts}/MNL-1/MNLENT-1/SYNC-1/SYNCTEMPLATE-1
    # BTS is OnAir after a reset
    Wait Until Keyword Succeeds    15 min    1 min    COAM Get Bts status enabled    ${bts_addr}

    # PTP is lost on ENB
    Run Keyword And Continue on failure    Trigger lost of ptp synchro    ${tl.tl_ptp['4G']}

    # 5G DSS cell is blocked
    ${5G_DSS_Cell}=    Get 5G DSS Cell    ${bts_addr}
    COAM Block Cell    ${bts_addr}    ${5G_DSS_Cell}

    # Wait for DSS alarm on ENB : EN DSS De-activated on partner side
    Wait until Keyword Succeeds    5 min    1 min    COAM Check Fault Displayed in webEM    ${enb_addr}    6134

    # Wait for alarm
    ${timeToDisableENDC}=    Check FaultId 4731    ${enb_addr}    ${maxAbsoluteTimeError_for_DSS}

    # PTP is restored
    Run Keyword And Continue on failure    Trigger recovery of ptp synchro    ${tl.tl_ptp['4G']}

    # 4G DSS cell is blocked
    ${4G_DSS_Cell}=    Get 4G DSS Cell    ${enb_addr}
    COAM Block Cell    ${enb_addr}    ${4G_DSS_Cell}

    Wait until Keyword Succeeds
    ...    15 min
    ...    1 min
    ...    COAM Check Phase Error Lower Than
    ...    ${enb_addr}
    ...    ${maxAbsoluteTimeError_for_DSS}

    # 4731 is deleted
    COAM Check Fault not Displayed in webEM    ${enb_addr}    4731

    # 4G DSS cell is unblocked
    COAM Unblock Cell    ${enb_addr}    ${4G_DSS_Cell}

    # 5G DSS cell is unblocked
    COAM Unblock Cell    ${bts_addr}    ${5G_DSS_Cell}

    # Wait for DSS alarm to disappear on ENB
    Wait until Keyword Succeeds    5 min    1 min    COAM Check Fault Not Displayed in webEM    ${enb_addr}    6134

# TC 41

CA disabled by PCell HO
    # Parameter changes
    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${bts_addr}
    ...    ${gnb_mrbts}/MNL-1/MNLENT-1/FEATCADM-1
    ...    actTimeErrorManagement
    ...    true
    # BTS is OnAir after a reset
    Wait Until Keyword Succeeds    15 min    1 min    COAM Get Bts status enabled    ${enb_addr}

    &{myDict}=    Create Dictionary    allowedSyncSource=ALL    maxAbsoluteTimeError=${maxAbsoluteTimeError_for_CA}
    ${myList}=    create list    ${myDict}
    Run Keyword And Continue on failure
    ...    COAM Parameter Online update
    ...    ${bts_addr}
    ...    ${gnb_mrbts}/MNL-1/MNLENT-1/SYNC-1/SYNCTEMPLATE-1
    ...    appTimeErrorManagement
    ...    ${myList}
    # BTS is OnAir after a reset
    Wait Until Keyword Succeeds    15 min    1 min    COAM Get Bts status enabled    ${enb_addr}

    Run Keyword And Continue on failure    COAM Parameter Online update    ${bts_addr}    ${gnb_mrbts}/${gnb_lnbts}
    ...    interEnbCaSyncTemplateDN    ${gnb_mrbts}/MNL-1/MNLENT-1/SYNC-1/SYNCTEMPLATE-1
    # BTS is OnAir after a reset
    Wait Until Keyword Succeeds    15 min    1 min    COAM Get Bts status enabled    ${bts_addr}

    # PTP is lost
    Run Keyword And Continue on failure    Trigger lost of ptp synchro    ${tl.tl_ptp['5G']}

    # Check PTP
    ${res}=    COAM Get TOPP Status    ${bts_addr}
    Should Be Equal    ${res}    Unusable

    # Wait for TOP reference missing alarm
    Wait until Keyword Succeeds    10 min    1 min    COAM Check Fault Displayed in webEM    ${bts_addr}    4298

    # Wait for alarm
    Check FaultId 4731    ${bts_addr}    ${maxAbsoluteTimeError_for_CA}

    # PTP is restored
    Run Keyword And Continue on failure    Trigger recovery of ptp synchro    ${tl.tl_ptp['5G']}

    # Check FeaturesStatusInd in BTSlog
    Check Bts Log    ${5g_vm_addr}    ${5g_vm_username}    ${5g_vm_password}
    ...    ${endTimeMin}    ${endTimeMax}
    ...    ".*sending FeaturesSyncStatusInd.*interEnbCa=1.*"

    # Wait for TOP reference missing alarm to disappear
    Wait until Keyword Succeeds    10 min    1 min    COAM Check Fault not Displayed in webEM    ${bts_addr}    4298

    ${phase_error}=    COAM Get Phase Error    ${bts_addr}
    Should Be True    ${phase_error} < ${maxAbsoluteTimeError_for_CA}

    # 4731 is deleted
    COAM Check Fault not Displayed in webEM    ${bts_addr}    4731

Test Debug
    coam.connect_to    bts_host=${enb_addr}    name=coam_admin
    ${lncel_list}=    coam.get_managed_objects    LNCEL_R    timeout=10    connection=coam_admin

    # All cells are enabled
    FOR    ${lncel}    IN    @{lncel_list}
        Run keyword and continue on failure    Should Be Equal As Strings
        ...    ${lncel}[parameters][operationalState]    enabled
    END
