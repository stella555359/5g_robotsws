*** Settings ***
Documentation     This file contains a collection of KWs used for CB012631
Library         BuiltIn
Library         Collections
Library         DateTime
Library         OperatingSystem
Library         String
Library         taf.sbts.oam.coam.admin         WITH NAME    admin
Library         ta5g_pm_counters
Library         taf.sw.syslog       WITH NAME   slog
Resource        ${CURDIR}/../../../resources/Keywords/generic_kw.robot
Resource        ${CURDIR}/../../../resources/Keywords/HO_KW.robot
Resource        ${CURDIR}/../../../resources/Keywords/TTI.robot
Resource        ${CURDIR}/../../../resources/Keywords/gnb_Keywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/tsharkPcapVerifyKeywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/ute_wts_runner.robot
Resource        ${CURDIR}/../../../resources/Keywords/ap_Keywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/common_keywords.robot
Resource        ${CURDIR}/../../../resources/Variables/common_variables.robot


*** Variables ***
${TOPOLOGY}     		CLOUD_5G_I_LOO_AP_LOOO
${DELTACONFIGDIR}       ${CURDIR}/../../config/gnb_scf
${APCONFIGDIR}          ${CURDIR}/../../config/ap_iphy
${AP_CONFIG_BASIC}      ${CURDIR}/../../config/wts
${VLAN_ID}        ${tl.gnbs[0].cu.x2c.vlan_id}
${MRBTS_DISTNAME}         MRBTS-1
${vlanif_distname}         ${MRBTS_DISTNAME}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1
${time}                 60
${S21}                  searchSpaceId 21
${S22}                  searchSpaceId 22
${S23}                  searchSpaceId 23
${S24}                  searchSpaceId 24
${S25}                  searchSpaceId 25
${S26}                  searchSpaceId 26
${S27}                  searchSpaceId 27
${S28}                  searchSpaceId 28
${S31}                  searchSpaceId 31
${S32}                  searchSpaceId 32
${S33}                  searchSpaceId 33
${S34}                  searchSpaceId 34
${S35}                  searchSpaceId 35
${S36}                  searchSpaceId 36
${S37}                  searchSpaceId 37
${S38}                  searchSpaceId 38
${S39}                  searchSpaceId 39
${monitorsl1}                           monitoringSlotPeriodicityAndOffset sl1 : NULL
${monitorsl4_0}                         monitoringSlotPeriodicityAndOffset sl4 : 0
${monitorsl4_1}                         monitoringSlotPeriodicityAndOffset sl4 : 1
${monitorsl4_2}                         monitoringSlotPeriodicityAndOffset sl4 : 2
${monitorsl10_9}                        monitoringSlotPeriodicityAndOffset sl10 : 9
${monitorsl10_2}                        monitoringSlotPeriodicityAndOffset sl10 : 2
${monitorsl10_3}                        monitoringSlotPeriodicityAndOffset sl10 : 3
${monitorsl10_8}                        monitoringSlotPeriodicityAndOffset sl10 : 8
${monitorsl10_7}                        monitoringSlotPeriodicityAndOffset sl10 : 7

${searchSpacesToAddModListExt_v1700}    searchSpacesToAddModListExt-v1700
${searchSpacesToAddModList}             searchSpacesToAddModList
${sw_param}            0x590072=1;0x580582=655360;0x58057A=4


*** Keywords ***
Prepare Test for CB012631 C 6
    [Documentation]    The KW will enable to bringup the test environment.
    ${LOG_PATH}      Create Log Directory    CB012631
    Link SCOUT SCF To Configuration ID For Reporting
    Set Test Variable    ${LOG_PATH}
    GNB Delta Commission        ${DELTACONFIGDIR}/Delta_12631.json
    Sleep   60s
    Add RD Parameters To GNB Swconfig File      ${sw_param}
    GNB Graceful Reset
    Sleep   320s
    Wait Coam Site To Be Ready
    Backup Scf     ${log_path}     TTI
    Start UTE WTS      CB012631_basic_setup.cfg
    Basic Bring Up

Prepare Test for CB012631 C 5
    [Documentation]    The KW will enable to bringup the test environment.
    ${LOG_PATH}      Create Log Directory    CB012631_C_5
    Link SCOUT SCF To Configuration ID For Reporting
    Set Test Variable    ${LOG_PATH}
    GNB Delta Commission        ${DELTACONFIGDIR}/Delta_12631_C_5.json
    Sleep   60s
    Add RD Parameters To GNB Swconfig File      ${sw_param}
    GNB Graceful Reset
    Sleep   320s
    Wait Coam Site To Be Ready
    Backup Scf     ${log_path}     TTI
    Start UTE WTS      CB012631_basic_setup.cfg
    Basic Bring Up

Prepare Test For CB012631 CVR
    [Documentation]    The KW will enable to bringup the test environment.
    ${LOG_PATH}      Create Log Directory    CB012631_CVR
    Link SCOUT SCF To Configuration ID For Reporting
    Set Test Variable    ${LOG_PATH}
    Update And Put Iphy Xml    ${APCONFIGDIR}/CB012631_CVR_iphy.xml
    Add RD Parameters To GNB Swconfig File      ${sw_param}
    GNB Graceful Reset
    Sleep   320s
    Wait Coam Site To Be Ready
    Full Commission With SCF File For UTE      ${DeltaConfigDir}/CB012631_CVR_SCF.xml
    Sleep   90s
    Wait Coam Site To Be Ready
    Backup Scf     ${log_path}     TTI
    Start UTE WTS      CB012631_basic_setup_CVR.cfg
    Basic Bring Up

Tear Down For CB012631
    [Documentation]    Tear Down For Case
    run keyword and ignore error    UE Deregister Should Be Successful For SA     ${UE_51}
    run keyword and ignore error    UE Deregister Should Be Successful For SA     ${UE_52}
    Copy Files    ${WTS_WORKING_DIR}/egate_console.log    ${LOG_PATH}
    slog.Stop Syslog
    Snapshot Collection      ${Log_path}
    Run     zip -r ${OUTPUTDIR}/CB012631.zip ${LOG_PATH}
    GNB Delta Commission        ${DELTACONFIGDIR}/Delta_12631_rev.json
    GNB Graceful Reset
    Sleep   320s
    Wait Coam Site To Be Ready

Tear Down For CB012631 C 5
    slog.Stop Syslog
    UE Deregister Should Be Successful For SA     ${UE_1}
    UE Deregister Should Be Successful For SA     ${UE_2}
    UE Deregister Should Be Successful For SA     ${UE_6}
    Copy Files    ${WTS_WORKING_DIR}/egate_console.log    ${LOG_PATH}
    Snapshot Collection      ${Log_path}
    Run     zip -r ${OUTPUTDIR}/CB012631_C_5.zip ${LOG_PATH}
    GNB Delta Commission        ${DELTACONFIGDIR}/Delta_12631_C_5_rev.json
    GNB Graceful Reset
    Sleep   320s
    Wait Coam Site To Be Ready

Tear Down For CB012631 CVR
    slog.Stop Syslog
    Copy Files    ${WTS_WORKING_DIR}/egate_console.log    ${LOG_PATH}
    Snapshot Collection      ${Log_path}
    Run     zip -r ${OUTPUTDIR}/CB012631_CVR.zip ${LOG_PATH}
    Rat Block Unblock


UE Register And Verify Searchspace Config
    [Documentation]    This keyword checks the message for the completion of UE registration and calls verify egate log
    [Arguments]        ${UE_ID}=${UE_ID}   ${monitor}=${monitor}  ${gw_ID}=${gw_ID}	    ${upf}=1    ${nwslice_ID}=1
    wtsrunner.UE Register   id=${UE_ID}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Print Matching Lines From Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message For UE Register And Reregister   ${output}
    wtsrunner.Set Pdu Param   ue=${UE_ID}    pdu=${Pdu_session_ID}    trf_type=${Trf_type}    upf=${upf}
    wtsrunner.UE Pdu Session Setup    pdu=${Pdu_session_ID}    ue=${UE_ID}   nwslice=${nwslice_ID}   gw=${gw_ID}
    Log To Console    \nFor ${UE_ID} validate egate log...
    Verify SearchSpaces Configuration In EgateLog For FDD    ${monitor}
    ${PDU_session_setup_output}         Read Wts Output For Pattern And Print Matching Lines
    ...                       ${Initial_context_setup_pattern}       ${Timeout_SA}
    [Return]                  ${PDU_session_setup_output}

UE Register And Verify Searchspace Config For TDD
    [Documentation]    This keyword checks the message for the completion of UE registration and calls verify egate log
    [Arguments]        ${UE_ID}=${UE_ID}     ${gw_ID}=${gw_ID}	    ${upf}=1    ${nwslice_ID}=1
    wtsrunner.UE Register   id=${UE_ID}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Print Matching Lines From Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message For UE Register And Reregister   ${output}
    wtsrunner.Set Pdu Param   ue=${UE_ID}    pdu=${Pdu_session_ID}    trf_type=${Trf_type}    upf=${upf}
    wtsrunner.UE Pdu Session Setup    pdu=${Pdu_session_ID}    ue=${UE_ID}   nwslice=${nwslice_ID}   gw=${gw_ID}
    Log To Console    \nFor ${UE_ID} validate egate log...
    Run Keyword If    '${UE_ID}'=='${UE_1}'    Verify SearchSpaces Configuration In EgateLog UE1
    ...    ELSE IF    '${UE_ID}'=='${UE_2}'    Verify SearchSpaces Configuration In EgateLog UE2
    ...    ELSE IF    '${UE_ID}'=='${UE_6}'    Verify SearchSpaces Configuration In EgateLog UE6
    ${PDU_session_setup_output}         Read Wts Output For Pattern And Print Matching Lines
    ...                       ${Initial_context_setup_pattern}       ${Timeout_SA}
    [Return]                  ${PDU_session_setup_output}

Verify SearchSpaces Configuration In EgateLog For FDD
    [Arguments]     ${monitor}
    [Documentation]    This is to verify patterns in eagte log.
    Read WTS Output For Pattern And Print Matching Lines    ${searchSpacesToAddModList}    ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${S7}      ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${monitorsl1}    ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${S8}      ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${monitorsl1}    ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${S10}      ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${monitorsl1}  ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${S39}     ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${monitor}    ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${S38}    ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${monitor}    ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${S37}    ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${monitor}    ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${searchSpacesToAddModListExt_v1700}     ${time}

Verify SearchSpaces Configuration In EgateLog UE1
    [Documentation]    This is to verify patterns in eagte log.
    Read WTS Output For Pattern And Print Matching Lines    ${searchSpacesToAddModList}    ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${S7}      ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${monitorsl1}    ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${S8}      ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${monitorsl1}    ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${S39}     ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${monitorsl10_9}   ${time}
#    Read WTS Output For Pattern And Print Matching Lines    ${S38}    ${time}
#    Read WTS Output For Pattern And Print Matching Lines    ${monitorsl10_2}    ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${S37}    ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${monitorsl10_2}    ${time}
#    Read WTS Output For Pattern And Print Matching Lines    ${S36}    ${time}
#    Read WTS Output For Pattern And Print Matching Lines    ${monitorsl10_9}    ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${searchSpacesToAddModListExt_v1700}     ${time}

Verify SearchSpaces Configuration In EgateLog UE2
    [Documentation]    This is to verify patterns in eagte log.
    Read WTS Output For Pattern And Print Matching Lines    ${searchSpacesToAddModList}    ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${S7}      ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${monitorsl1}    ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${S8}      ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${monitorsl1}    ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${S39}     ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${monitorsl10_3}    ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${S38}    ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${monitorsl10_8}    ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${S37}    ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${monitorsl10_8}    ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${S36}      ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${monitorsl10_3}  ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${searchSpacesToAddModListExt_v1700}     ${time}

Verify SearchSpaces Configuration In EgateLog UE6
    [Documentation]    This is to verify patterns in eagte log.
    Read WTS Output For Pattern And Print Matching Lines    ${searchSpacesToAddModList}    ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${S7}      ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${monitorsl1}    ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${S8}      ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${monitorsl1}    ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${S39}     ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${monitorsl10_2}    ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${S38}    ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${monitorsl10_7}    ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${S37}    ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${monitorsl10_7}    ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${S36}      ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${monitorsl10_2}  ${time}
    Read WTS Output For Pattern And Print Matching Lines    ${searchSpacesToAddModListExt_v1700}     ${time}


Run And Validate Traffic
    [Documentation]    This is to send traffic in kbps or mbps.
    [Arguments]     ${UE_ID}=${UE_ID}    ${unit}=${unit}    ${dl_rate}=5    ${ul_rate}=3
    Log to Console    \nRunning DL + UL Traffic
    wtsrunner.Trf Data Start     ue=${UE_ID}    pdu=1   qfi=1    dir=dl    ${unit}=${dl_rate}
    ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=UDP DL TRF: .*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    ${output}
    wtsrunner.Trf Data Start     ue=${UE_ID}   pdu=1   qfi=1    dir=ul    ${unit}=${ul_rate}
    ${output}    wtsrunner.Read Wtsemu Output Until Re    expected=UDP UL TRF: .*    timeout=10
    Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}

Validate Zero At Required Indexes
    [Documentation]   Validate that at least one of the two PM counter lists
    ...    contains a non-zero value at index positions 1 and 2.
    ...    Fail only if both values are zero at the same index.
    [Arguments]    ${list_a}    ${list_b}

    FOR    ${idx}    IN    1    2
        ${a}=    Convert To Integer    ${list_a}[${idx}]
        ${b}=    Convert To Integer    ${list_b}[${idx}]
        Run Keyword If    ${a} == 0 and ${b} == 0
        ...    Fail    Index ${idx} validation failed: both values are zero
        ...    ELSE
        ...    Log    Index ${idx} validation passed.
    END

Validate Equal At Required Indexes
    [Arguments]    ${list_a}    ${list_b}
    FOR    ${idx}    IN    1    2
        Should Be Equal As Integers    ${list_a}[${idx}]    ${list_b}[${idx}]
        ...    msg=Index ${idx} mismatch: ${list_a}[${idx}] != ${list_b}[${idx}]
    END
