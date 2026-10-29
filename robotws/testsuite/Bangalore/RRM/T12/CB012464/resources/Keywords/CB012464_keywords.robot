*** Settings ***
Library         BuiltIn
Library         Collections
Library         DateTime
Library         OperatingSystem
Library         String
Library         taf.collectors.l1l2bip
Library         taf.sbts.oam.coam.admin         WITH NAME    admin
Library         taf.sw.syslog       WITH NAME   slog
Library         ta5g_pm_counters
Library         taf.ul.alarms_watchdog
Resource        ${CURDIR}/../../../resources/Keywords/generic_kw.robot
Resource        ${CURDIR}/../../../resources/Keywords/gnb_Keywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/tsharkPcapVerifyKeywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/ute_wts_runner.robot
Resource        ${CURDIR}/../../../resources/Keywords/ap_Keywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/common_keywords.robot
Resource        ${CURDIR}/../../../resources/Variables/common_variables.robot
Resource        ${CURDIR}/../Variables/CB012464_variable.robot

Documentation       :copyright: Nokia
...                 :author   : Vikash Kumar
...                 :contact  : vikash.20.kumar@nokia.com
...                 :Feature Related all common Keywords.


*** Variables ***
${TOPOLOGY}                CLOUD_5G_I_LOO_AP_LOOO
${DELTACONFIGDIR}          ${CURDIR}/../../config/scf
${APCONFIGDIR}             ${CURDIR}/../../config/ap_iphy
${VLAN_ID}                 ${tl.gnbs[0].cu.x2c.vlan_id}
${MRBTS_DISTNAME}          MRBTS-1
${VLANIF_DISTNAME}         ${MRBTS_DISTNAME}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1
${AP_CONFIG_BASIC}         ${CURDIR}/../../config/wts
${PDU_ID1}                 1
${PDU_SESS_MODIFY}         Added QosFlow with QFI
${TIMEOUT1}                200
${CELL1}                   1
${CELL7}                   7
@{NRPMQAP_IDS}             1    5    6    7    8    9    12    20    22
${UL_BLER}                 200,200,200,200,200,200,200,200
${FILTER}     3gpp.subcellid == 16 && UlData_UePuschReceiveRespPs_t.dtx == 0 && UlData_UePuschReceiveRespPs_t.fakeUe != True
${FIELD_SIN}               UlData_puschAntMeas_t.sinrOfAnt
${FIELD_NOISE}             UlData_puschAntMeas_t.linNoiseOfAnt
${DELTA}                   500


*** Keywords ***
Prepare For CB012464
    [Documentation]    Preparing For CB012464 with NIDD parameters update and Basic bring up OnAir
    ...     Also updating oncifg id and starting syslogs collection.
    ${hhmm}     Get Current Time As HHMM
    ${Log_Path}    Create Log Directory     CB012464AE${hhmm}
    Link SCOUT SCF To Configuration ID For Reporting
    Set Test Variable    ${Log_Path}
    IF   '${STREAM_NR}' == 'SBTS25R3'
         GNB Delta Commission    ${DELTACONFIGDIR}/Delta_Initial_Config_25R3.json     timeout=500
    ELSE
         GNB Delta Commission    ${DELTACONFIGDIR}/Delta_Initial_Config.json     timeout=500
    END
    Sleep       60s
    GNB Delta Commission        ${DELTACONFIGDIR}/Delta_Feature_FlagEnable.json
    Wait Coam Site To Be Ready
    Start UTE WTS     CB012464_Inac_VoNR_slotagg.cfg
    Basic Bring Up

Prepare For CB012464D
    [Documentation]    Preparing For CB012464 with NIDD parameters update and Basic bring up OnAir
    ...     Also updating oncifg id and starting syslogs collection.
    ${hhmm}     Get Current Time As HHMM
    ${Log_Path}    Create Log Directory     CB012464D${hhmm}
    Link SCOUT SCF To Configuration ID For Reporting
    Set Test Variable    ${Log_Path}
    GNB Delta Commission        ${DELTACONFIGDIR}/Delta_CB012464_D.json     timeout=500
    Sleep       30s
    Wait Coam Site To Be Ready
    Start UTE WTS     CB012464_D.cfg
    Basic Bring Up

Prepare For CB012464 RJIO
    [Documentation]    Preparing For CB012464 with NIDD parameters update and Basic bring up OnAir
    ...     Also updating oncifg id and starting syslogs collection For RJIO TL.
    ${hhmm}     Get Current Time As HHMM
    ${Log_Path}    Create Log Directory     CB012464RJIO${hhmm}
    Link SCOUT SCF To Configuration ID For Reporting
    Set Test Variable    ${Log_Path}
    Update BSR Package For RJIO
    GNB Delta Commission        ${DELTACONFIGDIR}/Delta_CB012464_RJIO.json     timeout=500
    Wait Coam Site To Be Ready
    Start UTE WTS     basic_setup_LOOO.cfg
    NG Link Should Be UP
    Sleep   60s

Get Current Time As HHMM
    [Documentation]     This keyword is used to create variable base on timein hour and min in HHMM format
    ${time}     Get Time    result_format=%H%M
    ${hh}       Get Substring       ${time}   11  13
    ${mm}       Get Substring       ${time}   14  16
    ${hhmm}     Set Variable        ${hh}${mm}
    [Return]    ${hhmm}

Common Tear Down For CB012464
    [Documentation]    Common Tear Down For CB012464 where reverting back all changes and collecting Logs.
    slog.Stop Syslog
    Snapshot Collection     ${Log_Path}     Snapshot_AE.zip
    Collect Logs For The Test                   ${Log_Path}
    Copy Files      ${WTS_WORKING_DIR}/egate_console.log      ${LOG_PATH}
    Run     zip -r ${OUTPUTDIR}/CB012464_TC1.zip ${LOG_PATH}
    GNB Delta Commission       ${DELTACONFIGDIR}/Delta_Config_Reverse.json      timeout=500
    Sleep   10s
    RAT Block Unblock

Common Tear Down For CB012464D
    [Documentation]    Common Tear Down For CB012464D where reverting back all changes and collecting Logs.
    slog.Stop Syslog
    Snapshot Collection     ${Log_Path}     Snapshot_D.zip
    Collect Logs For The Test            ${Log_Path}
    Copy Files      ${WTS_WORKING_DIR}/egate_console.log      ${LOG_PATH}
    Run     zip -r ${OUTPUTDIR}/CB012464_TCD.zip ${LOG_PATH}
    GNB Delta Commission       ${DELTACONFIGDIR}/Delta_CB012464_Reverse_D.json
    Sleep   10s
    RAT Block Unblock

Common Tear Down For CB012464 RJIO
    [Documentation]    Common Tear Down For CB012464 RJIO where reverting back all changes and collecting Logs.
    slog.Stop Syslog
    Snapshot Collection     ${Log_Path}     Snapshot_RJIO.zip
    Collect Logs For The Test            ${Log_Path}
    Copy Files      ${WTS_WORKING_DIR}/egate_console.log      ${LOG_PATH}
    Run     zip -r ${OUTPUTDIR}/CB012464_RJIO.zip ${LOG_PATH}
    GNB Delta Commission       ${DELTACONFIGDIR}/Delta_Reverse_CB012464_RJIO.json
    Sleep   10s
    GNB reboot
    sleep    300s

Sum PM Counter Values Under PMQAP
    [Documentation]    Takes a list of PM counters as an argument, retrieves values,
    ...    ensures they are integers, appends them, and returns the sum.
    ...    ${file} path of the PM file from where counters value to be extracted
    ...    ${cell} Cell Id for which Counter Value is to be taken
    ...    @{pm_counters} list of PM counters which are under NRCELL-${cell} not pmqap
    [Arguments]    ${file}     ${QPID}    ${cell}=${CELL1}    @{pm_counters}
    ${total}    Set Variable    0
    FOR    ${counter}    IN    @{pm_counters}
        ${value}    Get PM Counter Value    ${counter}
        ...         localmoid=MRBTS-1/NRBTS-1/NRCELL-${cell}
        ...         filepath=${file}
        ...         pmqap=${QPID}
        IF    '${QPID}' == '12'
            ${value}    Convert To Integer    ${value}[-1]
        ELSE IF     '${QPID}' == '20'
            ${value}    Convert To Integer    ${value}[-1]
        ELSE IF     '${QPID}' == '21'
            ${value}    Convert To Integer    ${value}[-1]
        ELSE IF    '${QPID}' == '22'
            ${value}    Convert To Integer    ${value}[-1]
        ELSE
            ${value}    Convert To Integer    ${value}[0]
        END

        ${total}    Evaluate   int(${total})+int(${value})
    END
    [Return]    ${total}

Sum PM Counter Values
    [Documentation]    Takes a list of PM counters as an argument, retrieves values,
    ...    ensures they are integers, appends them, and returns the sum.
    ...    ${file} path of the PM file from where counters value to be extracted
    ...    ${cell} Cell Id for which Counter Value is to be taken
    ...    @{pm_counters} list of PM counters which are under NRCELL-${cell} not pmqap
    [Arguments]    ${file}    ${cell}=${CELL1}    @{pm_counters}
    ${total}    Set Variable    0
    FOR    ${counter}    IN    @{pm_counters}
        ${value}    Get PM Counter Value    ${counter}
        ...         localmoid=MRBTS-1/NRBTS-1/NRCELL-${cell}
        ...         filepath=${file}
        ${value}    Convert To Integer    ${value}[0]
        ${total}    Evaluate   int(${total})+int(${value})
    END
    [Return]    ${total}

Verify PM Counter Values
    [Documentation]    This Keyword verify the velue for Counter corresponding parameter
    ...     ${pm_counter_file}  PM File path should be given from which counters value will be checked
    ...     ${cell}     Cell Id for the counter in which Cell to be checked
    ...     ${QPID}     pmqap id for which Counter needs to check
    ...     ${counter_expected_dict}    Dictionary of Counter and corresponding Values to Validate
    [Arguments]    ${pm_counter_file}    ${cell}    ${QPID}    ${counter_expected_dict}
    ${Counter_Keys}     Get Dictionary Keys    ${counter_expected_dict}
    FOR    ${CNT}    IN    @{Counter_Keys}
        ${ExpVal}    Set Variable    ${counter_expected_dict}[${CNT}]
        ${RcvVal}    Get Pm Counter Value
        ...     counter=${CNT}
        ...     localmoid=MRBTS-1/NRBTS-1/NRCELL-${cell}
        ...     filepath=${pm_counter_file}
        ...     pmqap=${QPID}
        Log To Console      cell ${cell} and pmqap ${QPID}
        IF    '${QPID}' == '12'
            ${int_ExpVal}         Evaluate     int(${ExpVal})*6
            Should Be Equal    ${int_ExpVal}    ${RcvVal}[-1]
        ELSE IF     '${QPID}' == '20'
            ${int_ExpVal}         Evaluate     int(${ExpVal})*6
            Should Be Equal    ${int_ExpVal}    ${RcvVal}[-1]
        ELSE IF     '${QPID}' == '21'
            Should Be Equal     int(0)    int(${RcvVal}[-1])
        ELSE IF    '${QPID}' == '22'
            ${int_ExpVal}         Evaluate     int(${ExpVal})*6
            Should Be Equal    ${int_ExpVal}    ${RcvVal}[-1]
        ELSE
            Should Be Equal   int(${ExpVal})   int(${RcvVal}[0])
        END
    END

Verifying The PM Counter For CB012464 CP Rank1
    [Documentation]    Verifying The PM Counter For CB012464 CP Rank1 MCS PM counter
    ...     cell    is for Cell id of which PM Counter we are comparing.
    [Arguments]            ${cell}=${CELL1}
    ${R1_CP64}        Sum PM Counter Values    ${pm_counter_file}       ${cell}    @{PUSCH_CP_RANK1_64_MCS}
    ${R1_CP256}       Sum PM Counter Values    ${pm_counter_file}       ${cell}    @{PUSCH_CP_RANK1_256_MCS}
    ${ExpRank1_CP}      Evaluate        int(${R1_CP64})+int(${R1_CP256})
    &{RANK1_CP_EXPECTED_VALUE}      Create Dictionary
    ...     ${CP_RNK1}      ${ExpRank1_CP}
    FOR    ${QPID}    IN     @{NRPMQAP_IDS}
        Verify PM Counter Values    ${pm_counter_file}
        ...     ${cell}     ${QPID}     ${RANK1_CP_EXPECTED_VALUE}
    END

Verifying The PM Counter For CB012464 CP Rank2
    [Documentation]    Verifying The PM Counter For CB012464 CP Rank2 MCS PM counter
    ...     cell    is for Cell id of which PM Counter we are comparing.
    [Arguments]            ${cell}=${CELL1}
    ${R2_CP64}        Sum PM Counter Values    ${pm_counter_file}       ${cell}    @{PUSCH_CP_RANK2_64_MCS}
    ${R2_CP256}       Sum PM Counter Values    ${pm_counter_file}       ${cell}    @{PUSCH_CP_RANK2_256_MCS}
    ${ExpRank2_CP}      Evaluate        int(${R2_CP64})+int(${R2_CP256})
    &{RANK2_CP_EXPECTED_VALUE}      Create Dictionary
    ...    ${CP_RNK2}        ${ExpRank2_CP}
    FOR    ${QPID}    IN     @{NRPMQAP_IDS}
        Verify PM Counter Values    ${pm_counter_file}
        ...     ${cell}     ${QPID}     ${RANK2_CP_EXPECTED_VALUE}
    END

Verifying The PM Counter For CB012464 CP256 MCS
    [Documentation]    Verifying The PM Counter For CB012464 CP Rank1 MCS PM counter
    ...     cell    is for Cell id of which PM Counter we are comparing.
    [Arguments]            ${cell}=${CELL1}
    ${R1_CP256}       Sum PM Counter Values    ${pm_counter_file}       ${cell}    @{PUSCH_CP_RANK1_256_MCS}
    ${R2_CP256}       Sum PM Counter Values    ${pm_counter_file}       ${cell}    @{PUSCH_CP_RANK2_256_MCS}
    ${Exp_CP256}      Evaluate        int(${R1_CP256})+int(${R2_CP256})
    FOR    ${QPID}    IN     @{NRPMQAP_IDS}
        ${RcvVal}       Sum PM Counter Values Under PMQAP   ${pm_counter_file}
        ...      ${QPID}    ${cell}     @{PUSCH_CP_BIN_256_PMQ}
        IF    '${QPID}' == '12'
            ${int_ExpVal}         Evaluate     int(${Exp_CP256})*6
            Should Be Equal    ${int_ExpVal}        ${RcvVal}
        ELSE IF     '${QPID}' == '20'
            ${int_ExpVal}         Evaluate     int(${Exp_CP256})*6
            Should Be Equal    ${int_ExpVal}        ${RcvVal}
        ELSE IF     '${QPID}' == '21'
            Should Be Equal    int(0)       int(${RcvVal})
        ELSE IF    '${QPID}' == '22'
            ${int_ExpVal}         Evaluate     int(${Exp_CP256})*6
            Should Be Equal    ${int_ExpVal}        ${RcvVal}
        ELSE
            Should Be Equal     ${Exp_CP256}        ${RcvVal}
        END
    END

Verifying The PM Counter For CB012464 CP64 MCS
    [Documentation]    Verifying The PM Counter For CB012464 CP Rank1 MCS PM counter
    ...     cell    is for Cell id of which PM Counter we are comparing.
    [Arguments]            ${cell}=${CELL1}
    ${R1_CP64}       Sum PM Counter Values    ${pm_counter_file}       ${cell}    @{PUSCH_CP_RANK1_64_MCS}
    ${R2_CP64}       Sum PM Counter Values    ${pm_counter_file}       ${cell}    @{PUSCH_CP_RANK2_64_MCS}
    ${Exp_CP64}      Evaluate        int(${R1_CP64})+int(${R2_CP64})
    FOR    ${QPID}    IN     @{NRPMQAP_IDS}
        ${RcvVal}       Sum PM Counter Values Under PMQAP   ${pm_counter_file}
        ...     ${QPID}     ${cell}    @{PUSCH_CP_BIN_64_PMQ}
        IF    '${QPID}' == '12'
            ${int_ExpVal}         Evaluate     int(${Exp_CP64})*6
            Should Be Equal    ${int_ExpVal}        ${RcvVal}
        ELSE IF     '${QPID}' == '20'
            ${int_ExpVal}         Evaluate     int(${Exp_CP64})*6
            Should Be Equal    ${int_ExpVal}        ${RcvVal}
        ELSE IF     '${QPID}' == '21'
            Should Be Equal     int(0)       int(${RcvVal})
        ELSE IF    '${QPID}' == '22'
            ${int_ExpVal}         Evaluate     int(${Exp_CP64})*6
            Should Be Equal    ${int_ExpVal}        ${RcvVal}
        ELSE
            Should Be Equal     ${Exp_CP64}        ${RcvVal}
        END
    END

Verifying The PM Counter For CB012464 DFT Rank1 MCS
    [Documentation]    Verifying The PM Counter For CB012464 DFT Rank1 MCS PM counter
    ...     cell    is for Cell id of which PM Counter we are comparing.
    [Arguments]            ${cell}=${CELL1}
    ${R1_DFT64}     Sum PM Counter Values    ${pm_counter_file}       ${cell}     @{PUSCH_DFT_RANK1_PMI}
    &{RANK1_DFT_EXPECTED_VALUE}      Create Dictionary
    ...     ${DFT_RNK1}      ${R1_DFT64}
    FOR    ${QPID}    IN     @{NRPMQAP_IDS}
        Verify PM Counter Values    ${pm_counter_file}
        ...     ${cell}     ${QPID}     ${RANK1_DFT_EXPECTED_VALUE}
        ${RcvVal}       Sum PM Counter Values Under PMQAP   ${pm_counter_file}
        ...     ${QPID}     ${cell}     @{PUSCH_DFT_BIN_64_PMQ}
        IF   '${QPID}' == '12'
            ${int_ExpVal}         Evaluate     int(${R1_DFT64})*6
            Should Be Equal    ${int_ExpVal}        ${RcvVal}
        ELSE IF     '${QPID}' == '20'
            ${int_ExpVal}         Evaluate     int(${R1_DFT64})*6
            Should Be Equal    ${int_ExpVal}        ${RcvVal}
        ELSE IF     '${QPID}' == '21'
            Should Be Equal     int(0)       int(${RcvVal})
        ELSE IF    '${QPID}' == '22'
            ${int_ExpVal}         Evaluate     int(${R1_DFT64})*6
            Should Be Equal    ${int_ExpVal}        ${RcvVal}
        ELSE
            Should Be Equal     ${R1_DFT64}        ${RcvVal}
        END
    END

Verifying The PM Counter For CB012464 BLER
    [Documentation]    Verifying The PM Counter For CB012464 BLER PM Counters
    ...     cell    is for Cell id of which PM Counter we are comparing.
    [Arguments]             ${cell}=${CELL1}
    ${UNSUCC_CP64}     Sum PM Counter Values    ${pm_counter_file}       ${cell}         @{PUSCH_CP_UNSUCC_64TBL_MCS}
    ${UNSUCC_CP256}    Sum PM Counter Values    ${pm_counter_file}       ${cell}         @{PUSCH_CP_UNSUCC_256TBL_MCS}
    ${UNSUCC_DFT64}    Sum PM Counter Values    ${pm_counter_file}       ${cell}         @{PUSCH_DFT_UNSUCC_64TBL_MCS}
    ${UNSUCC}    Evaluate    int(${UNSUCC_CP64})+int(${UNSUCC_CP256})+int(${UNSUCC_DFT64})
    ${SUCC_CP64}       Sum PM Counter Values    ${pm_counter_file}       ${cell}         @{PUSCH_CP_SUCC_ANY_64TBL_MCS}
    ${SUCC_CP256}      Sum PM Counter Values    ${pm_counter_file}       ${cell}         @{PUSCH_CP_SUCC_ANY_256TBL_MCS}
    ${SUCC_DFT64}      Sum PM Counter Values    ${pm_counter_file}       ${cell}         @{PUSCH_DFT_SUCC_ANY_64TBL_MCS}
    ${SUCC}    Evaluate    int(${SUCC_CP64})+int(${SUCC_CP256})+int(${SUCC_DFT64})
    &{BLER_CNT_EXPECTED_VALUE}    Create Dictionary
    ...    ${BLER_UNSUC}    ${UNSUCC}
    ...    ${BLER_SUC}      ${SUCC}
    FOR    ${QPID}    IN     @{NRPMQAP_IDS}
        Verify PM Counter Values    ${pm_counter_file}
        ...     ${cell}     ${QPID}     ${BLER_CNT_EXPECTED_VALUE}
    END

Verifying The PM Counter For CB012464 TA
    [Documentation]    Verifying The PM Counter For CB012464 BLER PM Counters
    ...     cell    is for Cell id of which PM Counter we are comparing.
    [Arguments]     ${cell}=${CELL1}
    ${near_list}    Get Slice From List    ${TA_LEG_CNTR}    0      ${NEAR_THRESH_TA}
    ${mid_list}     Get Slice From List    ${TA_LEG_CNTR}    ${NEAR_THRESH_TA}    ${FAR_THRESH_TA}
    ${far_list}     Get Slice From List    ${TA_LEG_CNTR}    ${FAR_THRESH_TA}

    ${NearThrsh}     Sum PM Counter Values    ${pm_counter_file}       ${cell}
    ...              @{near_list}
    ${MidThrsh}      Sum PM Counter Values    ${pm_counter_file}       ${cell}
    ...              @{mid_list}
    ${FarThrsh}      Sum PM Counter Values    ${pm_counter_file}       ${cell}
    ...              @{far_list}
    &{TA_CNT_EXPECTED_VALUE}    Create Dictionary
    ...     ${NEAR_CNT}    ${NearThrsh}
    ...     ${MID_CNT}     ${MidThrsh}
    ...     ${FAR_CNT}     ${FarThrsh}
    FOR    ${QPID}    IN     @{NRPMQAP_IDS}
        Verify PM Counter Values    ${pm_counter_file}
        ...     ${cell}     ${QPID}     ${TA_CNT_EXPECTED_VALUE}
    END

DL Traffic Should Be Successful CB012464
    [Documentation]    This Keywords helps to start Only DL Data
    ...     ${dl_rate} :    Gives the Quantity of data
    ...     ${UEID}    :    UE Id for which Data to be transferred
    ...     ${QFI}     :    QOS Flow We want for data
    ...     ${bps}     :    dl_rate in mbps/kbps required.
    [Arguments]    ${dl_rate}=30    ${UE_ID}=${UE_ID}       ${QFI}=1    ${bps}=mbps
    Log to Console    \nRunning DL Traffic
    wtsrunner.Trf Data Start     ue=${UE_ID}    pdu=1   qfi=${QFI}    dir=dl    ${bps}=${dl_rate}
    ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=UDP DL TRF: .*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    ${output}

UL Traffic Should Be Successful CB012464
    [Documentation]    This Keyword helps to start Only UL Data.
    ...     ${ul_rate} :    Gives the Quantity of data
    ...     ${UEID}    :    UE Id for which Data to be transferred
    ...     ${QFI}     :    QOS Flow We want for data
    ...     ${bps}     :    ul_rate in mbps/kbps required.
    [Arguments]    ${ul_rate}=30    ${UE_ID}=${UE_ID}       ${QFI}=1    ${bps}=mbps
    Log to Console    \nRunning UL Traffic
    wtsrunner.Trf Data Start     ue=${UE_ID}    pdu=1   qfi=${QFI}    dir=ul    ${bps}=${ul_rate}
    ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=UDP UL TRF: .*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    ${output}

Register Multiple UEs And Start UL AND DL Traffic
    [Documentation]    This keyword registers multiple UEs and starts traffic on each UE.
    [Arguments]    ${Start_UEID}=1    ${Stop_UEID}=9    ${dl}=10    ${ul}=10
    FOR    ${ueid}    IN RANGE    ${Start_UEID}    ${Stop_UEID}
        Log    Registering UE ${ueid} and initializing traffic
        wtsrunner.AMF UE ICS Param    id=1    ue=${ueid}    core_network_assistance_info=on
        ...    ue_identity_index_value=1    ue_specific_drx=256
        ...    periodic_registration_update_timer=1:10min    plmn_id=310:260    tac_id=200
        ...    trace_ref_id=1   trace_rec_session_ref_id=1
        Sleep   1s
        UE Register Should Be Successful For SA    ${ueid}
        Log    Starting Downlink and Uplink Traffic for UE ${ueid}
        DL Traffic Should Be Successful CB012464    ${dl}    ${ueid}
        UL Traffic Should Be Successful CB012464    ${ul}    ${ueid}
        Log To Console      Starting Dl and Ul Traffic for UE ${ueid} for diff QoS
        Add QOS Flows And Start Data With All QOS ID    ${ueid}
    END

De-Register Multiple UEs
    [Documentation]    This Keyword helps to De-Register given range of UEs.
    ...     ${Start_UEID}   :   Starting Range of UEId to DeRegister
    ...     ${Stop_UEID}    :   1 More than Last UE To be Deregistered.
    [Arguments]     ${Start_UEID}=1     ${Stop_UEID}=9
    FOR     ${ueid}  IN RANGE   ${Start_UEID}   ${Stop_UEID}
        UE Deregister Should Be Successful For SA       ${ueid}
        Log   De-Registered UE ${ueid}
    END

Add QOS Flows And Start Data With All QOS ID
    [Documentation]    This Keyword helps to Add QOS Flows For Given UEID And Start Data in range of QoS ids.
    [Arguments]     ${UEID}=1   ${StartQFID}=2    ${StopQFID}=7      ${dl}=10    ${ul}=10
    FOR     ${qfi}  IN RANGE   ${StartQFID}   ${StopQFID}
        Modify PDU session for UE to add    ${UEID}     ${PDU_ID1}      ${qfi}
        IF  ${qfi} == 5 or ${qfi} == 6
            DL Traffic Should Be Successful CB012464    ${dl}    ${UEID}    ${qfi}    kbps
            UL Traffic Should Be Successful CB012464    ${ul}    ${UEID}    ${qfi}    kbps
        ELSE
            DL Traffic Should Be Successful CB012464    ${dl}    ${UEID}    ${qfi}    mbps
            UL Traffic Should Be Successful CB012464    ${ul}    ${UEID}    ${qfi}    mbps
        END
    END

Modify PDU Session For UE To add
    [Arguments]    ${ue_id}=1    ${Pdu_ID}=1   ${QFI}=1     ${pattern}=${PDU_SESS_MODIFY}
    wtsrunner.UE PDU Session Modify    ue=${ue_id}    pdu=${Pdu_ID}    qosflows_to_add=${QFI}   by=amf
    sleep    10s
    wtsrunner.Read WTSemu Output Until     ${pattern}       ${TIMEOUT1}
    sleep    5s

Add Pathloss For Range of UEs
    [Documentation]    This keyword to add pathloss for multiple UEs in given range.
    [Arguments]    ${Start_UEID}=1    ${Stop_UEID}=9    ${pathLoss}=100
    FOR    ${ueid}    IN RANGE    ${Start_UEID}    ${Stop_UEID}
        Add Pathloss With UL SINR Testmode And Activate With UE Testmode    ${ueid}
        ...     1       ${pathLoss}
    END

Add UL Cell Noise Testmode
    [Documentation]     This Keyword is used to Add UL Cell Noise Testmode to NR Activate or Deactivate.
    [Arguments]   ${ProfId}=2   ${PUSCH_Noise}=-610   ${gnbId}=2   ${cellId}=11   ${testmode}=ul_cell_noise  ${action}=activate
    UL Cell Noise Testmode NR   profile_id=${ProfId}    noise_pusch=${PUSCH_Noise}
    Sleep   2s
    Set NR Cell Testmode    gnbId=${gnbId}  cellId=${cellId}    testmode=${testmode}    profId=${ProfId}    action=${action}    wait_for=5s
    Sleep   2s

Add TA And BLER Testmode For Range of UEs
    [Documentation]    This keyword to activate TA and BLER for multiple UEs in given range.
    [Arguments]    ${Start_UEID}=1    ${Stop_UEID}=9
    FOR    ${ueid}    IN RANGE    ${Start_UEID}    ${Stop_UEID}
        Add UE Time Advance Testmode And Activate        ${ueid}
        Add UE BLER Testmode And Activate                ${ueid}
    END

Add UE Time Advance Testmode And Activate
    [Documentation]    This Keyword helps to create Time Advance (TA) and then Activate
    ...                the specific requested UE with same profile.testmode and action are hardcoded as
    ...                This is the specific requirement from the Keyword. Hence to be used for Same purpose only.
    ...                ${UEID}  :   UE for which pathloss has to be activated.
    ...                ${ProfId}:   Profile Ids that will be used for Activating
    [Arguments]     ${UEID}=1   ${ProfId}=2
    wtsrunner.UE TA NR        profile_id=${ProfId}      nb_reps_ta_sim=100
    ...    ue_speed=10        ue_p_delay_max=1500       ue_p_delay_min=100
    ...    ue_p_delay_initial=300
    wtsrunner.UE Testmode Set NR    id=${UEID}    testmode=ta
    ...    profile_id=${ProfId}     action=activate

Add UE BLER Testmode And Activate
    [Documentation]    This Keyword helps to create BLER Testmode and then Activate
    ...                the specific requested UE with same profile.testmode and action are hardcoded as
    ...                This is the specific requirement from the Keyword. Hence to be used for Same purpose only.
    ...                ${UEID}  :   UE for which pathloss has to be activated.
    ...                ${ProfId}:   Profile Ids that will be used for Activating or Deactivating
    [Arguments]     ${UEID}=1       ${ProfId}=3
    wtsrunner.BLER TESTMODE NR      profile_id=${ProfId}      ul_bler=${UL_BLER}
    wtsrunner.UE Testmode Set NR    id=${UEID}    testmode=bler
    ...    profile_id=${ProfId}     action=activate

Deactivate UE BLER And Time Advanced Testmodes
    [Documentation]    This Keyword helps to deactivate BLER And Time Advanced Testmode
    [Arguments]     ${UEID}=1
    wtsrunner.UE Testmode Set NR    id=${UEID}    testmode=bler
    ...    profile_id=3     action=deactivate
    Sleep   2s
    wtsrunner.UE Testmode Set NR    id=${UEID}    testmode=ta
    ...    profile_id=2     action=deactivate

Deactivate TA And BLER Testmode For Range Of UEs
    [Documentation]    This keyword to activate TA and BLER for multiple UEs in given range.
    [Arguments]    ${Start_UEID}=1    ${Stop_UEID}=9
    FOR    ${ueid}    IN RANGE    ${Start_UEID}    ${Stop_UEID}
        Deactivate UE BLER And Time Advanced Testmodes      ${ueid}
    END

Add Pathloss With UL SINR Testmode And Activate With UE Testmode
    [Documentation]    This Keyword helps to create pathloss for UL SINR Testmode and then Activate
    ...                the specific requested UE with same profile.testmode and action are hardcoded as
    ...                This is the specific requirement from the Keyword. Hence to be used for Same purpose only.
    ...                ${UEID}  :   UE for which pathloss has to be activated.
    ...                ${ProfId}:   Profile Ids that will be used for Activating or Deactivating
    ...                ${pathLoss}: Default is 100, We can vary the pathloss as per our requirement
    [Arguments]     ${UEID}=1   ${ProfId}=1     ${pathLoss}=100
    UL SINR Testmode NR     profile_id=${ProfId}    pathloss=${pathLoss}    pcmax=30
    Sleep   2s
    UE Testmode Set NR      id=${UEID}     testmode=ul_sinr     action=activate    profile_id=${ProfId}
    Sleep   10s

Verifying The PM Counter For CB012464
    [Documentation]    This keyword Will Check the PMCounter for all the Scenario of CB012464
    ...     For Given Cell it will check BLER , TA , CP Rank1 , CP Rank2 and DFT RANK1 also MCS
    [Arguments]        ${Cell_ID}=${CELL1}
    Verifying The PM Counter For CB012464 TA                    ${Cell_ID}
    Log To console      Counters for Time Advanced Completed

Verifying The PM Counter For CB012464 CP64QAM
    [Documentation]    This keyword Will Check the PMCounter for all the Scenario of CB012464
    ...     For Given Cell it will check BLER , TA , CP Rank1 , CP Rank2 , MCS, CP64QAM
    ...     Currently it is Configured to be used for Cell2 and Cell8 only
    [Arguments]        ${Cell_ID}=${CELL1}
    Verifying The PM Counter For CB012464 TA                    ${Cell_ID}
    Verifying The PM Counter For CB012464 CP Rank2              ${Cell_ID}
    Verifying The PM Counter For CB012464 CP Rank1              ${Cell_ID}

Verifying The PM Counter For CB012464 CP256QAM
    [Documentation]    This keyword Will Check the PMCounter for all the Scenario of CB012464
    ...     For Given Cell it will check BLER , TA , CP Rank1 , CP Rank2 , MCS, CP256QAM
    ...     Currently it is Configured to be used for Cell1 and Cell10 only
    [Arguments]        ${Cell_ID}=${CELL1}
    Verifying The PM Counter For CB012464 TA                    ${Cell_ID}
    Verifying The PM Counter For CB012464 CP Rank2              ${Cell_ID}
    Verifying The PM Counter For CB012464 CP Rank1              ${Cell_ID}

Verifying The PM Counter For CB012464 DFT64QAM
    [Documentation]    This keyword Will Check the PMCounter for all the Scenario of CB012464
    ...     For Given Cell it will check BLER , TA , DFT Rank1, MCS, CP64QAM , CP256QAM
    ...     Currently it is Configured to be used for Cell3 and Cell7 only
    [Arguments]        ${Cell_ID}=${CELL1}
    Verifying The PM Counter For CB012464 TA                    ${Cell_ID}

Start Interface Mirroring With NR Phy Cellids
    [Documentation]     This keyword is to Start Interface Mirroring With NR Phy Cellids
    [Arguments]      ${name}=l1l2bip    ${PhyCell}=61    ${MirrFilt}=SpecificL1L2Messages     ${MsgId}=0xE24B
    create_interface_mirroring_l1l2bip_collector
    ...  name=${name}
    ...  webservice=${WEBSERVICES}
    ...  nr_phy_cell_ids=${PhyCell}
    ...  mirroring_filter=${MirrFilt}
    ...  specific_message_ids=${MsgId}
    taf.collectors.l1l2bip.setup_collectors    names=${name}
    taf.collectors.l1l2bip.start_collectors    names=${name}
    taf.collectors.l1l2bip.set_suite_alias     alias=${name}

Stop Interface Mirroring With NR Phy Cellids
    [Documentation]     This keyword is to Stop Interface Mirroring With NR Phy Cellids
    [Arguments]      ${name}=l1l2bip    ${TarPath}=${Log_Path}
    core.stop_collectors    names=l1l2bip
    core.collect_collectors    names=l1l2bip    target_dir=${TarPath}
    core.teardown_collectors    names=l1l2bip
    Convert Bip To CSV And Extract Expected Value   BipFile=${TarPath}/${name}/*pcap
    ...     filter=${FILTER}    field=${FIELD_SIN}      CSV_File=CB012464_SIN.csv
    Convert Bip To CSV And Extract Expected Value   BipFile=${TarPath}/${name}/*pcap
    ...     filter=${FILTER}    field=${FIELD_NOISE}    CSV_File=CB012464_NOISE.csv

Verifying The PM Counter For CB012464E SIN
    [Documentation]    This keyword Will Check the PMCounter for all the Scenario of CB012464_E SIN CNT
    [Arguments]     ${PM_File}=${pm_counter_file}        ${cell}=11     &{SIN}
    Verify Last Counters In File
    ...     M55387C00001     ${SIN}[M55387C00001]     AVG_UE_SINR_PUSCH_STR_0
    ...     M55387C00002     ${SIN}[M55387C00002]     AVG_UE_SINR_PUSCH_STR_1
    ...     M55387C00003     ${SIN}[M55387C00003]     AVG_UE_SINR_PUSCH_STR_2
    ...     M55387C00004     ${SIN}[M55387C00004]     AVG_UE_SINR_PUSCH_STR_3
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${cell}
    ...     file_path=${PM_File}

Verifying The PM Counter For CB012464E SIN RJIO
    [Documentation]    This keyword Will Check the PMCounter for all the Scenario of CB012464_E SIN CNT
    [Arguments]     ${PM_File}=${pm_counter_file}        ${cell}=5     &{SIN}
    Verify Last Counters In File
    ...     M55387C00001     ${SIN}[M55387C00001]     AVG_UE_SINR_PUSCH_STR_0
    ...     M55387C00002     ${SIN}[M55387C00002]     AVG_UE_SINR_PUSCH_STR_1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${cell}
    ...     file_path=${PM_File}

Verifying The PM Counter For CB012464E RIP
    [Documentation]    This keyword Will Check the PMCounter for all the Scenario of CB012464_E RIP CNT
    [Arguments]     ${PM_File}=${pm_counter_file}        ${cell}=11      &{RIP}
    Verify Last Counters In File
    ...     M55387C00005     ${RIP}[M55387C00005]     AVG_UE_RIP_PUSCH_STR_0
    ...     M55387C00006     ${RIP}[M55387C00006]     AVG_UE_RIP_PUSCH_STR_1
    ...     M55387C00007     ${RIP}[M55387C00007]     AVG_UE_RIP_PUSCH_STR_2
    ...     M55387C00008     ${RIP}[M55387C00008]     AVG_UE_RIP_PUSCH_STR_3
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${cell}
    ...     file_path=${PM_File}

Verifying The PM Counter For CB012464E RIP RJIO
    [Documentation]    This keyword Will Check the PMCounter for all the Scenario of CB012464_E RIP CNT
    [Arguments]     ${PM_File}=${pm_counter_file}        ${cell}=5      &{RIP}
    Verify Last Counters In File
    ...     M55387C00005     ${RIP}[M55387C00005]     AVG_UE_RIP_PUSCH_STR_0
    ...     M55387C00006     ${RIP}[M55387C00006]     AVG_UE_RIP_PUSCH_STR_1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${cell}
    ...     file_path=${PM_File}

Verifying The PM Counters For CB012464D
    [Documentation]    This keyword Will Check the PMCounter for all the SSBs Under ExpectedCells of CB012464D
    ...     these Counters will peg either 1 or 0, and will peg only for one interval so all the commands are
    ...     triggered withing single interval to check all the expected counters pegged with value 1.
    ...     ${PM_File} is File where the value is captured and ${val} is the expected value.
    [Arguments]     ${PM_File}=${pm_counter_file}       ${val}=1
    Log To Console      For cell ${CELL1} and SSB0
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39809     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL1}       filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-0
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39829     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL1}       filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-0
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39849     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL1}       filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-0
    Log To Console      For cell ${CELL1} and SSB1
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39806     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL1}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-1
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39829     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL1}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-1
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39849     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL1}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-1
    Log To Console      For cell ${CELL1} and SSB2
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39807     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL1}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-2
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39827     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL1}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-2
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39847     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL1}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-2
    Log To Console      For cell ${CELL1} and SSB3
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39808     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL1}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-3
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39829     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL1}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-3
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39848     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL1}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-3
    Log To Console      For cell ${CELL2} and SSB4
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39811     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL2}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-4
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39831     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL2}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-4
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39851     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL2}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-4
    Log To Console      For cell ${CELL3} and SSB2
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39814     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL3}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-2
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39834     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL3}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-2
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39855     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL3}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-2
    Log To Console      For cell ${CELL3} and SSB5
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39811     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL3}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-5
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39833     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL3}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-5
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39852     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL3}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-5
    Log To Console      For cell ${CELL4} and SSB3
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39812     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL4}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-3
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39832     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL4}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-3
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39852     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL4}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-3
    Log To Console      For cell ${CELL7} and SSB0
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39809     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL7}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-0
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39810     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL7}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-0
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39829     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL7}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-0
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39830     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL7}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-0
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39849     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL7}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-0
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39850     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL7}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-0
    Log To Console      For cell ${CELL8} and SSB0
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39811     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL8}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-0
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39812     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL8}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-0
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39834     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL8}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-0
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39836     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL8}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-0
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39853     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL8}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-0
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39861     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL8}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-0
    Log To Console      For cell ${CELL10} and SSB0
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39822     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL10}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-0
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39841     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL10}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-0
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39862     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL10}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-0
	Log To Console      For cell ${CELL11} and SSB0
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39824     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL11}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-0
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39845     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL11}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-0
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39865     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL11}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-0

Convert Bip To CSV And Extract Expected Value
    [Documentation]     This keyword Will Conver Bip To CSV And Extract Expected Value For CB012464E
    ...     ${BipFile}      Biplog Collected Files.
    ...     ${filter}       Filter to be used to get required messages.
    ...     ${field}        Values Required for the Given Field.
    ...     ${CSV_File}     Export or save output Values in csv file.
    [Arguments]     ${BipFile}      ${filter}    ${field}       ${CSV_File}=CB012464_E.csv
    ${rc}    ${tshark_output}    Run And Return Rc And Output
    ...    tshark -Y "${filter}" -r ${BipFile} -T fields -e ${field} -E occurrence=a -E header=y -E separator=, > ${Log_Path}/${CSV_File}
    Log    TShark executed with return code: ${rc}
    Log To Console      ${CSV_File} is Created.

Remove Trailing Slashes
    [Documentation]     This keyword will remove last chars from each cell if it ends with given string
    [Arguments]    ${input_string}
    ${result}       Split String    ${input_string}     \\
    ${res}    Convert To Number    ${result}[0]
    [Return]    ${res}

Calculate SINR Avg Value From BIP Log
    [Documentation]    This Keyword Calculates the average SINR values from a given CSV file.
    ...                - Replaces -255 with 0
    ...                - Skips header row
    ...                - Rounds the averages to nearest integer
    [Arguments]     ${CSV_File}=CB012464_SIN.csv
    ${lines}        Get File    ${Log_Path}/${CSV_File}
    @{rows}         Split To Lines      ${lines}
    # Skip first row
    Remove From List    ${rows}    0
    # Prepare column containers
    @{first_data_row}    Split String    ${rows[0]}    separator=,
    ${num_columns}       Get Length    ${first_data_row}
    @{columns}           Create List
    FOR    ${i}    IN RANGE    ${num_columns}
        @{col}     Create List
        Append To List    ${columns}    ${col}
    END
    # Process each data row
    FOR    ${row}    IN    @{rows}[0:500]
        @{cells}    Split String    ${row}    separator=,
        FOR    ${i}    IN RANGE    ${num_columns}
            ${value}    Remove Trailing Slashes     ${cells}[${i}]
            IF    ${value} != -255
                ${col}     Get From List    ${columns}    ${i}
                Append To List    ${col}    ${value}
                Set List Value    ${columns}    ${i}    ${col}
            ELSE
                ${col}     Get From List    ${columns}    ${i}
                ${value}   Convert To Number    0
                Append To List    ${col}        ${value}
                Set List Value    ${columns}    ${i}    ${col}
            END
        END
    END
    # Calculate averages
    @{averages}    Create List
    FOR    ${col}    IN    @{columns}
        ${sum}    Evaluate    sum(${col})
        ${count}  Get Length    ${col}
        ${avg}    Evaluate    int(${sum} / ${count})
        ${avg_s}    Convert To String    ${avg}
        Append To List    ${averages}    ${avg_s}
    END
    Log To Console     Column Averages (SINR): ${averages}
    &{SIN_AVG_EXP}     Create Dictionary
    ${cnt}    Get Length    ${averages}
    FOR    ${index}    IN RANGE    ${cnt}
        ${key}     Get From List    ${SIN_PM_CNT}    ${index}
        ${value}   Get From List    ${averages}      ${index}
        Set To Dictionary    ${SIN_AVG_EXP}    ${key}=${value}
    END
    Log    ${SIN_AVG_EXP}
    RETURN      ${SIN_AVG_EXP}

Calculate RIP Avg Value From BIP Log
    [Documentation]     This Keyword to Calculate Avg value of RIP Values form given csv file.
    [Arguments]     ${CSV_File}=CB012464_NOISE.csv
    ${lines}        Get File    ${Log_Path}/${CSV_File}
    @{rows}         Split To Lines      ${lines}
    # Skip first row
    Remove From List    ${rows}    0
    # Prepare column containers
    @{first_data_row}    Split String    ${rows[0]}    separator=,
    ${num_columns}       Get Length    ${first_data_row}
    @{columns}           Create List
    FOR    ${i}    IN RANGE    ${num_columns}
        @{col}     Create List
        Append To List    ${columns}    ${col}
    END
    # Process each data row
    FOR    ${row}    IN    @{rows}[0:500]
        @{cells}    Split String    ${row}    separator=,
        FOR    ${i}    IN RANGE    ${num_columns}
            ${value}     Remove Trailing Slashes     ${cells}[${i}]
            IF    ${value} != 10
                ${dBm}     Convert Attowatts To DBM    ${value}
                ${col}     Get From List    ${columns}    ${i}
                Append To List    ${col}    ${dBm}
                Set List Value    ${columns}    ${i}    ${col}
            ELSE
                ${col}     Get From List    ${columns}    ${i}
                ${value}   Convert To Number    0
                Append To List    ${col}        ${value}
                Set List Value    ${columns}    ${i}    ${col}
            END
        END
    END
    # Calculate averages
    @{averages}    Create List
    FOR    ${col}    IN    @{columns}
        ${sum}    Evaluate    sum(${col})
        ${count}  Get Length    ${col}
        ${avg}    Evaluate    int(${sum} / ${count})
        ${avg_s}    Convert To String    ${avg}
        Append To List    ${averages}    ${avg_s}
    END
    Log To Console     Column Averages (RIP): ${averages}
    &{RIP_AVG_EXP}     Create Dictionary
    ${cnt}    Get Length    ${averages}
    FOR    ${index}    IN RANGE    ${cnt}
        ${key}     Get From List    ${RIP_PM_CNT}    ${index}
        ${value}   Get From List    ${averages}      ${index}
        Set To Dictionary    ${RIP_AVG_EXP}    ${key}=${value}
    END
    Log    ${RIP_AVG_EXP}
    RETURN      ${RIP_AVG_EXP}

Convert Attowatts To DBM
    [Documentation]     This Keyword is Used to Convert Attowatts to dBm
    [Arguments]    ${attowatts}
    ${attowatts}    Convert To Number    ${attowatts}
    IF    ${attowatts} != 0
        ${milliwatts}    Evaluate    ${attowatts} / 1e18
        TRY
            ${dbm}    Evaluate    10 * math.log10(${milliwatts}) + 30     modules=math
        EXCEPT
            Log To Console    ERROR converting to dBm
            Log To Console    attowatts: ${attowatts}
            Log To Console    milliwatts: ${milliwatts}
            ${dbm}    Set Variable    0
        END
    ELSE
        ${dbm}    Set Variable    0
    END
    ${res_dbm}    Convert To Integer    ${dbm}
    RETURN    ${res_dbm}

Verify Benchmark Counters For CB012464
    [Documentation]     This Keyword is Used to Check the Counter Values is in expected range of benchark
    [Arguments]    ${PM_File}=${pm_counter_file}
    ${TDDBlerUNS2}   Get Pm Counter Value
    ...     counter=${BLER_UNSUC}
    ...     localmoid=MRBTS-1/NRBTS-1/NRCELL-${CELL2}
    ...     filepath=${PM_File}
    ...     pmqap=1
    Log To Console      ${TDDBlerUNS2}[0] received value for Cell2-pmqap-1 UnSuc BLER M55386C00028
    Value Should Be Within Range    ${TDDBlerUNS2}[0]     ${Bench_BLER_CNT_TDD}[M55386C00028]
    ${TDDBlerSUC2}   Get Pm Counter Value
    ...     counter=${BLER_SUC}
    ...     localmoid=MRBTS-1/NRBTS-1/NRCELL-${CELL2}
    ...     filepath=${PM_File}
    ...     pmqap=1
    Log To Console      ${TDDBlerSUC2}[0] received value for Cell2-pmqap-1 Succ BLER M55386C00029
    Value Should Be Within Range    ${TDDBlerSUC2}[0]     ${Bench_BLER_CNT_TDD}[M55386C00029]

    ${FDDBlerUNS8}   Get Pm Counter Value
    ...     counter=${BLER_UNSUC}
    ...     localmoid=MRBTS-1/NRBTS-1/NRCELL-${CELL8}
    ...     filepath=${PM_File}
    ...     pmqap=1
    Log To Console      ${FDDBlerUNS8}[0] received value for Cell8-pmqap-1 UnSuc BLER M55386C00028
    Value Should Be Within Range    ${FDDBlerUNS8}[0]     ${Bench_BLER_CNT_FDD}[M55386C00028]
    ${FDDBlerSUC8}   Get Pm Counter Value
    ...     counter=${BLER_SUC}
    ...     localmoid=MRBTS-1/NRBTS-1/NRCELL-${CELL8}
    ...     filepath=${PM_File}
    ...     pmqap=1
    Log To Console      ${FDDBlerSUC8}[0] received value for Cell8-pmqap-1 Succ BLER M55386C00029
    Value Should Be Within Range    ${FDDBlerSUC8}[0]     ${Bench_BLER_CNT_FDD}[M55386C00029]
    ${TDD_MCSBIN0_1}   Get Pm Counter Value
    ...     counter=M55386C00043
    ...     localmoid=MRBTS-1/NRBTS-1/NRCELL-${CELL1}
    ...     filepath=${PM_File}
    ...     pmqap=1
     Log To Console      ${TDD_MCSBIN0_1}[0] received value for Cell1-pmqap-1 MCS BIN0 M55386C00043
    Value Should Be Within Range    ${TDD_MCSBIN0_1}[0]     ${Bench_MCS_CNT_TDD}[M55386C00043]
    ${TDD_MCSBIN3_1}   Get Pm Counter Value
    ...     counter=M55386C00046
    ...     localmoid=MRBTS-1/NRBTS-1/NRCELL-${CELL1}
    ...     filepath=${PM_File}
    ...     pmqap=1
    Log To Console      ${TDD_MCSBIN3_1}[0] received value for Cell1-pmqap-1 MCS BIN3 M55386C00046
    Value Should Be Within Range    ${TDD_MCSBIN3_1}[0]     ${Bench_MCS_CNT_TDD}[M55386C00046]
    ${FDD_MCSBIN0_7}   Get Pm Counter Value
    ...     counter=M55386C00043
    ...     localmoid=MRBTS-1/NRBTS-1/NRCELL-${CELL7}
    ...     filepath=${PM_File}
    ...     pmqap=1
    Log To Console      ${FDD_MCSBIN0_7}[0] received value for Cell7-pmqap-1 MCS BIN0 M55386C00043
    Value Should Be Within Range    ${FDD_MCSBIN0_7}[0]     ${Bench_MCS_CNT_FDD}[M55386C00043]
    ${FDD_MCSBIN3_7}   Get Pm Counter Value
    ...     counter=M55386C00046
    ...     localmoid=MRBTS-1/NRBTS-1/NRCELL-${CELL7}
    ...     filepath=${PM_File}
    ...     pmqap=1
    Log To Console      ${FDD_MCSBIN3_7}[0] received value for Cell7-pmqap-1 MCS BIN3 M55386C00043
    Value Should Be Within Range    ${FDD_MCSBIN3_7}[0]     ${Bench_MCS_CNT_FDD}[M55386C00046]

Value Should Be Within Range
    [Documentation]     This Keyword is used to check if observed value is in range of expeted value.
    ...     range of expected +/- delta.
    ...     observed -> Received Value
    ...     expected -> Expected Benchmark value
    ...     delta    -> Expected deviation from Benchmark value
    [Arguments]    ${observed}    ${expected}    ${delta}=${DELTA}
    ${lower}      Evaluate    ${expected} - ${delta}
    ${upper}      Evaluate    ${expected} + ${delta}
    Should Be True    ${lower} <= ${observed} <= ${upper}

Verifying The PM Counters For CB012464 RJIO
    [Documentation]    This keyword Will Check the PMCounter for all the SSBs Under ExpectedCells of CB012464 RJIO
    ...     these Counters will peg either 1 or 0, and will peg only for one interval so all the commands are
    ...     triggered withing single interval to check all the expected counters pegged with value 1.
    ...     ${PM_File} is File where the value is captured and ${val} is the expected value.
    [Arguments]     ${PM_File}=${pm_counter_file}       ${val}=1
    Log To Console      For cell ${CELL3} and SSB5
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39806     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL3}       filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-5
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39829     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL3}       filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-5
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39848     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL3}       filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-5
    Log To Console      For cell ${CELL4} and SSB0
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39810     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL4}       filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-0
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39828     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL4}       filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-0
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39847     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL4}       filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-0
    Log To Console      For cell ${CELL5} and SSB0
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39812     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL5}       filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-0
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39836     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL5}       filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-0
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39861     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL5}       filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-0
    Log To Console      For cell ${CELL6} and SSB0
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39821    value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL6}       filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-0
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39823    value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL6}       filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-0
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39824     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL6}       filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-0
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39841    value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL6}       filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-0
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39842     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL6}       filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-0
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39845     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL6}       filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-0
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39854     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL6}       filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-0
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39864    value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL6}       filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-0
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55202C39865     value=${val}
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL6}       filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/SSBPM-0

Get GNB Alarms
    [Documentation]     This keyword is to check current alarms on gnB and return list of alarms.
    admin.Setup Admin
    ${alarms}      admin.Get Alarms
    [Return]       ${alarms}
    [Teardown]     admin.Teardown Admin

Get Alarm By Details
    [Documentation]    Getting Alarm details of GNB List of Fault Ids Active at GNB
    @{alarms}   Get GNB Alarms
    @{Alarm_Fault_Id}       Create List
    FOR  ${alarm}  IN  @{alarms}
        ${current_alarm_info}              Get From Dictionary  ${alarm}                      alarmInformation
        ${current_additional_info}         Get From Dictionary  ${current_alarm_info}         alarmAdditionalInfo
        ${current_additional_fault_id}     Get From Dictionary  ${current_additional_info}    additionalFaultID
        ${current_alarm_detail}            Get From Dictionary  ${current_alarm_info}         alarmDetail
        ${current_fault_description}       Get From Dictionary  ${current_alarm_info}         faultDescription
        Append To List      ${Alarm_Fault_Id}       ${current_additional_fault_id}
    END
    [Return]    ${Alarm_Fault_Id}