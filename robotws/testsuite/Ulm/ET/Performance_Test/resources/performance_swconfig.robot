*** Settings ***
Documentation    Keywords for modifying the SWCONFIG flags for ap and gnb

Resource    ../../../resources/Common/gnb.robot
Resource    ../../../resources/Common/wts_ue.robot
Resource    performance_database.robot

Library     python/perf_keywords.py
Library     hasher


*** Variables ***
${QC_PATH}=             testsuite/Ulm/ET/Performance_Test/resources/qc/ASOE_performance.qc
${S_AP_SWCONFIG}
${S_GNB_SWCONFIG}


*** Keywords ***
Enable GNB SwConfig From File If Exists
    [Arguments]    ${config_dir}=${WORKSPACE}/gnb_swconfig_add.txt
    ${ret}    Run Keyword And Return Status    File Should Not Be Empty    ${config_dir}
    IF    not ${ret}   RETURN

    ${contents}    Get File    ${config_dir}    encoding=UTF-8    encoding_errors=strict
    @{SYSLOG_FLAGS}=    Split to lines    ${contents}
    IF    "${SYSLOG_FLAGS[0]}"=="${EMPTY}"   RETURN
    Update GNB Swconfig    ${SYSLOG_FLAGS}


Update GNB SwConfig From Params
    [Arguments]    ${tp}
    @{rad}    perf_keywords.Get Gnb Rad Params From Dictionary    ${tp}
    ${radlen}    Get Length    ${rad}
    IF    ${radlen} > 0
        Log to Console    Update GNB SwConfig From Params:
        Update GNB Swconfig    ${rad}
    END


Update AP SwConfig From Params
    [Arguments]    ${tp}
    @{rad}    perf_keywords.Get Ap Rad Params From Dictionary    ${tp}
    ${radlen}    Get Length    ${rad}
    IF    ${radlen} > 0
        Log to Console    Update AP SwConfig From Params:
        Update AP Swconfig    ${rad}
    END


Modify PM Interval in Gnb Swconfig
    [Arguments]    ${interval}=5
    Log to Console    - Modify PM Interval in Gnb Swconfig: ${interval}
    @{SYSLOG_FLAGS}     Create List    0x9D0000=${interval}    # PM Counter Interval reporting updates.
    Update GNB Swconfig    ${SYSLOG_FLAGS}

Enable GNB SwConfig Admin RD Mode Enable
    [Arguments]    ${value}=1
    Log to Console    - Enable GNB SwConfig Admin RD Mode Enable: ${value}
    @{SYSLOG_FLAGS}     Create List    0x450027=${value} # ADMIN RD mode enable, old flag: 0x45005a
    Update GNB Swconfig    ${SYSLOG_FLAGS}

Enable GNB SwConfig rdActAdaptiveSchedulerBudget
    Log to Console    - Enable GNB SwConfig rdActAdaptiveSchedulerBudget
    @{SYSLOG_FLAGS}     Create List    0x58081F=1 # rdActAdaptiveSchedulerBudget
    Update GNB Swconfig    ${SYSLOG_FLAGS}

Modify GNB SwConfig rdEnableUserDeleteInternalBundleMessage
    [Arguments]    ${value}
    Log to Console    - Modify GNB SwConfig rdEnableUserDeleteInternalBundleMessage: ${value}
    @{SYSLOG_FLAGS}     Create List    0x58094C=${value} # rdEnableUserDeleteInternalBundleMessage [0: disable; 1: enable]
    Update GNB Swconfig    ${SYSLOG_FLAGS}

Modify GNB SwConfig rdCsReductionFactorOlc
    [Documentation]    CNI-125967 wird aktiviert mit "rdCsReductionFactorOlc" (0x966)
    ...                rdCsReductionFactorOlc = 0: feature inaktiv
    ...                rdCsReductionFactorOlc = 1: feature konfiguriert durch NIDD (noch nicht vorhanden)
    ...                rdCsReductionFactorOlc in [10..100] feature konfiguriert mit csReductionFactorOlc = rdCsReductionFactorOlc / 100
    [Arguments]    ${value}
    Log to Console    - Modify GNB SwConfig rdCsReductionFactorOlc: ${value}
    @{SYSLOG_FLAGS}     Create List    0x580966=${value} # rdCsReductionFactorOlc
    Update GNB Swconfig    ${SYSLOG_FLAGS}

Modify AP SwConfig Fix For Peak Capacity
    [Documentation]    PR753371 fix for peak capacity (PET) & performance
    [Arguments]    ${value}=2
    Log to Console    - Modify AP SwConfig Fix For Peak Capacity: ${value}
    @{SYSLOG_FLAGS}     Create List    0x5C0009=${value} # PR753371 fix for peak capacity (PET) & performance
    Update AP Swconfig    ${SYSLOG_FLAGS}

Modify GNB SwConfig Syslog Output Severity
    [Documentation]    SYSLOG output severity prints (0=disable 1=debug 2=info 3=warning 4=error 5=vip 6=disable)
    [Arguments]    ${severity}=1
    Log to Console    - Modify GNB SwConfig Syslog Output Severity: ${severity}
    @{SYSLOG_FLAGS}     Create List    0x10040=${severity} # SYSLOG output severity
    ...                                0x1003F=${severity} # AaSysLogInputLevel
    ...                                0x10041=${severity} # ERadCcs_AaSysLogOutputMode
    ...                                0x590072=${severity} # CP-RT log level
    ...                                0x66001b=${severity} # CP-NRT log level
    ...                                0x890001=${severity} # CP-NB log level
    ...                                0x890002=${severity} # CP-SB log level
    ...                                0x890003=${severity} # CP-UE log level
    ...                                0x890004=${severity} # CP-CL log level
    ...                                0x890005=${severity} # CP-IF log level
    ...                                0x890006=${severity} # CP-SCTP log level
    Update GNB Swconfig    ${SYSLOG_FLAGS}

Modify Ap SwConfig Syslog Output Severity
    [Documentation]    SYSLOG output severity prints (0=disable 1=debug 2=info 3=warning 4=error 5=vip 6=disable)
    [Arguments]    ${severity}=1
    Log to Console    - Modify Ap SwConfig Syslog Output Severity: ${severity}
    @{SYSLOG_FLAGS}     Create List    0x10040=${severity} # SYSLOG output severity
    Update AP Swconfig    ${SYSLOG_FLAGS}

Update GNB Swconfig
    [Arguments]    ${SYSLOG_FLAGS}    ${gnb_id}=${0}
    Log to Console    ${SPACE} - Update GNB Swconfig: ${SYSLOG_FLAGS}
    gnb.Update SW Config file on System Module    gnb_id=${gnb_id}    param_list=${SYSLOG_FLAGS}
    ${ret}    Get gnb SwConfig
    Check If List In SwConfig    ${ret}    ${SYSLOG_FLAGS}

Update AP Swconfig
    [Arguments]    ${SYSLOG_FLAGS}    ${ue_id}=${0}    ${ue_comu_id}=${0}
    Log to Console    ${SPACE} - Update AP Swconfig: ${SYSLOG_FLAGS}
    wts_ue.Update SW Config file on AP System Module    ${SYSLOG_FLAGS}    ue_id=${ue_id}    ue_comu_id=${ue_comu_id}
    ${ret}    Get AP SwConfig
    Check If List In SwConfig    ${ret}    ${SYSLOG_FLAGS}

Get Swconfigs
    Run Keyword And Warn On Failure    Get gnb SwConfig
    Run Keyword And Warn On Failure    Get AP SwConfig

Get gnb SwConfig
    ${alias_common_unit}   connect.Connect To Node Common Unit
    ${ret}   ssh.execute    cat /ffs/run/swconfig.txt    connection=${alias_common_unit}
    Set Suite Variable    $S_GNB_SWCONFIG    ${ret}
    RETURN    ${ret}

Get AP SwConfig
    [Arguments]    ${ue_id}=${0}    ${ue_comu_id}=${0}
    ${alias_common_unit_ap}    connect.Connect To Airphone Common Unit    ue_id=${ue_id}    ue_comu_id=${ue_comu_id}
    ${ret}   ssh.execute    cat /ffs/run/swconfig.txt    connection=${alias_common_unit_ap}
    Set Suite Variable    $S_AP_SWCONFIG    ${ret}
    RETURN    ${ret}

Print SwConfigs
    Log to Console    \n====================\n AP SWCONFIG: \n====================\n${S_AP_SWCONFIG}\n\n====================\n
    Log to Console    \n====================\nGNB SWCONFIG: \n====================\n${S_GNB_SWCONFIG}\n\n====================\n

Check If List In SwConfig
    [Arguments]    ${swconfig}    ${flags}
    FOR    ${flag}    IN    @{flags}
        ${flag}    Remove Comment In Flag    ${flag}
        Should Contain    ${swconfig}    ${flag}    msg=swconfig does not contain ${flag}    ignore_case=${true}
    END

Remove Comment In Flag
    [Arguments]    ${flag}
    ${flag}    Evaluate    "${flag}".split(' #')[0].replace(' ','')
    RETURN    ${flag}
