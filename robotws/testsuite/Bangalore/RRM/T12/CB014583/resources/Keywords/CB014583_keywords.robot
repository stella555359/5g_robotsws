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
Resource        ${CURDIR}/../../../resources/Keywords/generic_kw.robot
Resource        ${CURDIR}/../../../resources/Keywords/gnb_Keywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/tsharkPcapVerifyKeywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/ute_wts_runner.robot
Resource        ${CURDIR}/../../../resources/Keywords/ap_Keywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/common_keywords.robot
Resource        ${CURDIR}/../../../resources/Variables/common_variables.robot

Documentation       :copyright: Nokia
...                 :author   : Vikash Kumar
...                 :contact  : vikash.20.kumar@nokia.com
...                 :Feature Related all common Keywords.


*** Variables ***
${DELTACONFIGDIR}          ${CURDIR}/../../config/scf
${AP_CONFIG_BASIC}         ${CURDIR}/../../config/wts
${5GC}                     RN_release_due_to_5gc_generated_reason
${NGRAN}                   RN_release_due_to_ngran_generated_reason
${CN}                      RN_release_due_to_cn_detected_mobility
${UE_LOST}                 RN_radio_connection_with_ue_lost
${HW_FAIL}                 MISC_hardware_failure
${PDU_ID1}                 1
${PDU_SESSION_ADD}         Added QosFlow with QFI:(\\d+)\\s+fiveQI:(\\d+)
${PDU_SESSION_DEL} 	       Removed FiveQi
${TIMEOUT}                 150
${DL_PATTERN}              Started Downlink
${UL_PATTERN}              Started Uplink
${PDU_RELEASE}             Successfully released PDU Session
${UE_CTX_RELEASE}          UE CONTEXT RELEASE COMPLETE
${ATTACHE_UES}             ${AP_CONFIG_BASIC}/Attach_UE.lua
${UL_PAT_24}               UE24: UDP UL TRF
${UL_PAT_38}               UE38: UDP UL TRF
${5QI_ULDL_TRAFFIC}        ${AP_CONFIG_BASIC}/Traffic_Diff_5qi_CB014583.lua
${VLAN_ID}                 ${tl.gnbs[0].cu.x2c.vlan_id}
${MRBTS_DISTNAME}          MRBTS-1
${vlanif_distname}         ${MRBTS_DISTNAME}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1


*** Keywords ***
Prepare For CB014583 RJIO
    [Documentation]    Preparing For CB014583 with NIDD parameters update and Basic bring up OnAir
    ...     Also updating oncifg id and starting syslogs collection For RJIO TL.
    ${hhmm}     Get Current Time As HHMM
    ${Log_Path}    Create Log Directory     CB014583RJIO${hhmm}
    Link SCOUT SCF To Configuration ID For Reporting
    Set Test Variable    ${Log_Path}
    RUN KEYWORD AND IGNORE ERROR    Update BSR Package For RJIO
    GNB Delta Commission        ${DELTACONFIGDIR}/Delta_CB014583_RJIO.json     timeout=500
    Sleep       30s
    Wait Coam Site To Be Ready
    Start UTE WTS     CB014583_setup.cfg
    NG Link Should Be UP
    Sleep   90s

Prepare For CB014583 TMO
    [Documentation]    Preparing For CB014583 with NIDD parameters update and Basic bring up OnAir
    ...     Also updating oncifg id and starting syslogs collection For TMO TL.
    ${hhmm}     Get Current Time As HHMM
    ${Log_Path}    Create Log Directory     CB014583TMO${hhmm}
    Link SCOUT SCF To Configuration ID For Reporting
    Set Test Variable           ${Log_Path}
    GNB Delta Commission        ${DELTACONFIGDIR}/Delta_CB014583_TMO.json     timeout=500
    Sleep       30s
    Wait Coam Site To Be Ready
    Start UTE WTS     CB014583_TMO_Setup.cfg
    Basic Bring Up
    Sleep   20s

Get Current Time As HHMM
    [Documentation]     This keyword is used to create variable base on timein hour and min in HHMM format
    ${time}     Get Time    result_format=%H%M
    ${hh}       Get Substring       ${time}   11  13
    ${mm}       Get Substring       ${time}   14  16
    ${hhmm}     Set Variable        ${hh}${mm}
    [Return]    ${hhmm}

Common Tear Down For CB014583 RJIO
    [Documentation]    Common Tear Down For CB014583 RJIO where reverting back all changes and collecting Logs.
    slog.Stop Syslog
    ${hhmm}     Get Current Time As HHMM
    Snapshot Collection     ${Log_Path}     Snapshot_${hhmm}_RJIO.zip
    Copy Files      ${WTS_WORKING_DIR}/egate_console.log      ${LOG_PATH}
    Run     zip -r ${OUTPUTDIR}/CB014583_RJIO${hhmm}.zip ${LOG_PATH}
    GNB Delta Commission       ${DELTACONFIGDIR}/Delta_Reverse_CB014583_RJIO.json
    RAT Block Unblock

Common Tear Down For CB014583 TMO
    [Documentation]    Common Tear Down For CB014583 RJIO where reverting back all changes and collecting Logs.
    slog.Stop Syslog
    ${hhmm}     Get Current Time As HHMM
    Snapshot Collection     ${Log_Path}     Snapshot_${hhmm}_TMO.zip
    Copy Files      ${WTS_WORKING_DIR}/egate_console.log      ${LOG_PATH}
    Run     zip -r ${OUTPUTDIR}/CB014583_TMO${hhmm}.zip ${LOG_PATH}
    GNB Delta Commission       ${DELTACONFIGDIR}/Delta_Reverse_CB014583_TMO.json
    RAT Block Unblock

Pass Lua File For Attach
    [Documentation]       This KW shall allow for passing lua file at egate console prompt 24 UEs
    [Arguments]           ${lua_file}=${ATTACHE_UES}        ${PAT}=${UL_PAT_24}
    wtsrunner.Script      file=${lua_file}
    Sleep   30s
    Read WTS Output For Pattern And Print Matching Lines       ${PAT}        600
    wtsrunner.UE Disp
    Sleep   15s
    wtsrunner.Script_stop

Pass Lua File For 5QI
    [Documentation]       This KW shall allow for passing lua file at egate console prompt 24 UEs Traffic 5QIs
    [Arguments]           ${lua_file}=${5QI_ULDL_TRAFFIC}
    wtsrunner.Script      file=${lua_file}
    Sleep   900s
    wtsrunner.UE Disp
    wtsrunner.Script_stop

DL Traffic Should Be Successful CB014583
    [Documentation]    This Keywords helps to start Only DL Data
    ...     ${dl_rate} :    Gives the Quantity of data
    ...     ${UEID}    :    UE Id for which Data to be transferred
    ...     ${QFI}     :    QOS Flow We want for data
	...		${tm}	   :    Time in seconds
	...		${fiveQI}  :    5Qi type we are parsing
    [Arguments]    ${dl_rate}=30    ${UE_ID}=${UE_ID}       ${QFI}=1    ${tm}=3600		${fiveQI}=9
    Log to Console    \nRunning DL Traffic
    IF  ${fiveQI}==5
        wtsrunner.Trf Data Start     ue=${UE_ID}     pdu=${PDU_ID1}     qfi=${QFI}
        ...         kbps=500       dir=dl     protocol=tcp    seconds=${tm}
        ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=${DL_PATTERN}    timeout=30
        ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
        Log to Console    ${output}
    ELSE IF   ${fiveQI}==1
         wtsrunner.Trf Data Start     ue=${UE_ID}    pdu=${PDU_ID1}     qfi=${QFI}
        ...               dir=dl      seconds=${tm}      rtp_codec=g711m
        ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=${DL_PATTERN}    timeout=30
        ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
        Log to Console    ${output}
        wtsrunner.Trf Data Start     ue=${UE_ID}     pdu=${PDU_ID1}     qfi=${QFI}
        ...         mbps=1       dir=dl     protocol=udp
        ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=${DL_PATTERN}    timeout=30
        ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
        Log to Console    ${output}
    ELSE
        wtsrunner.Trf Data Start     ue=${UE_ID}     pdu=${PDU_ID1}     qfi=${QFI}
        ...         mbps=${dl_rate}       dir=dl     protocol=udp
        ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=${DL_PATTERN}    timeout=30
        ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
        Log to Console    ${output}
    END

UL Traffic Should Be Successful CB014583
    [Documentation]    This Keyword helps to start Only UL Data.
    ...     ${ul_rate} :    Gives the Quantity of data
    ...     ${UEID}    :    UE Id for which Data to be transferred
    ...     ${QFI}     :    QOS Flow We want for data
    ...     ${tm}      :    Time in seconds
    ...     ${fiveQI}  :    5Qi type we are parsing
    [Arguments]    ${ul_rate}=30    ${UE_ID}=${UE_ID}       ${QFI}=1    ${tm}=3600      ${fiveQI}=9
    Log to Console    \nRunning UL Traffic
    IF  ${fiveQI}==5
        wtsrunner.Trf Data Start     ue=${UE_ID}     pdu=${PDU_ID1}     qfi=${QFI}
        ...         kbps=500       dir=ul     protocol=tcp    seconds=${tm}
        ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=${UL_PATTERN}   timeout=30
        ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
        Log to Console    ${output}
    ELSE IF   ${fiveQI}==1
         wtsrunner.Trf Data Start     ue=${UE_ID}    pdu=${PDU_ID1}     qfi=${QFI}
        ...               dir=ul      seconds=${tm}      rtp_codec=g711m
        ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=${UL_PATTERN}    timeout=30
        ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
        Log to Console    ${output}
        wtsrunner.Trf Data Start     ue=${UE_ID}     pdu=${PDU_ID1}     qfi=${QFI}
        ...         mbps=${ul_rate}      dir=ul     protocol=udp
        ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=${UL_PATTERN}    timeout=30
        ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
        Log to Console    ${output}
    ELSE
        wtsrunner.Trf Data Start     ue=${UE_ID}     pdu=${PDU_ID1}     qfi=${QFI}
        ...         mbps=${ul_rate}      dir=ul     protocol=udp
        ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=${UL_PATTERN}    timeout=30
        ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
        Log to Console    ${output}
    END

Modify PDU Session For UE To Add
    [Arguments]    ${ue}     ${QFI}=2     ${PDU}=1        ${pattern}=${PDU_SESSION_ADD}
    UE PDU Session Modify    ue=${ue}     pdu=${PDU}      qosflows_to_add=${QFI}      by=amf
    wtsrunner.Read Wtsemu Output Until Re     ${pattern}      ${TIMEOUT}

Modify PDU Session For UE To Delete
    [Arguments]    ${ue}     ${QFI}=2     ${PDU}=1        ${pattern}=${PDU_SESSION_DEL}
    UE PDU Session Modify    ue=${ue}     pdu=${PDU}      qosflows_to_del=${QFI}      by=amf
    wtsrunner.Read Wtsemu Output Until Re     ${pattern}      ${TIMEOUT}

Release PDU Session For UE
    [Arguments]    ${ue}     ${PDU}=1    ${pattern}=${PDU_RELEASE}
    UE PDU Session Release      ue=${ue}    pdu=${PDU}        by=amf
    wtsrunner.Read Wtsemu Output Until Re     ${pattern}      ${TIMEOUT}

Context Release For UE NG
    [Documentation]     Release the UE NG Context with provided Cause
    [Arguments]     ${ue}       ${cause}=${5GC}    ${by}=amf    ${pattern}=${UE_CTX_RELEASE}
    UE NG CTX Release       id=${ue}    cause=${cause}      by=${by}
    wtsrunner.Read Wtsemu Output Until Re     ${pattern}      ${TIMEOUT}

AMF Sends PDU MODIFY REQUEST
    [Documentation]     Release the QoS Flows using NgAP:PDUSessionResourceModifyRequest:
    ...    with list of QoS Flows to be removed with given cause
    [Arguments]         ${ue}=1     ${QFI}=2         ${cause}=${NGRAN}      ${PDU}=1
    AMF UE PDU Modify Param     id=1    ue=${ue}     action=override_ie
    ...      qos_flow_to_del_cause=${cause}
    Sleep    3s
    Modify PDU Session For UE To Delete     ${ue}      ${QFI}      ${PDU}

AMF Sends PDU Release REQUEST
    [Documentation]     Release the QoS Flows using NgAP:PDUSessionResourceModifyRequest:
    ...    with list of QoS Flows to be removed with given cause
    [Arguments]         ${ue}=1          ${cause}=${NGRAN}      ${PDU}=1
    AMF UE PDU Release Param     id=1    ue=${ue}    cause=${cause}
    Sleep    3s
    Release PDU Session For UE     ${ue}    ${PDU}

All PDU Modify For CB014583 5GC
    [Documentation]     All PDU Modify For CB014583 with cause RN_release_due_to_5gc_generated_reason
    AMF Sends PDU MODIFY REQUEST      1        3       cause=${5GC}
    AMF Sends PDU MODIFY REQUEST      1        2       cause=${5GC}
    AMF Sends PDU MODIFY REQUEST      4        3       cause=${5GC}
    AMF Sends PDU MODIFY REQUEST      4        2       cause=${5GC}
    AMF Sends PDU MODIFY REQUEST      7        5       cause=${5GC}
    AMF Sends PDU MODIFY REQUEST      7        4       cause=${5GC}
    Run Keyword And Ignore Error    AMF Sends PDU MODIFY REQUEST      10       4       cause=${5GC}
    Run Keyword And Ignore Error    AMF Sends PDU MODIFY REQUEST      10       5       cause=${5GC}
    AMF Sends PDU MODIFY REQUEST      13       1       cause=${5GC}
    AMF Sends PDU MODIFY REQUEST      13       2       cause=${5GC}
    AMF Sends PDU MODIFY REQUEST      16       2       cause=${5GC}
    AMF Sends PDU MODIFY REQUEST      16       1       cause=${5GC}

All PDU Modify For CB014583 NGRAN
    [Documentation]     All PDU Modify For CB014583 with cause RN_release_due_to_ngran_generated_reason
    AMF Sends PDU MODIFY REQUEST      2        3       cause=${NGRAN}
    AMF Sends PDU MODIFY REQUEST      2        2       cause=${NGRAN}
    AMF Sends PDU MODIFY REQUEST      5        3       cause=${NGRAN}
    AMF Sends PDU MODIFY REQUEST      5        2       cause=${NGRAN}
    AMF Sends PDU MODIFY REQUEST      8        5       cause=${NGRAN}
    AMF Sends PDU MODIFY REQUEST      8        4       cause=${NGRAN}
    Run Keyword And Ignore Error    AMF Sends PDU MODIFY REQUEST      11       4       cause=${NGRAN}
    Run Keyword And Ignore Error    AMF Sends PDU MODIFY REQUEST      11       5       cause=${NGRAN}
    AMF Sends PDU MODIFY REQUEST      14       1       cause=${NGRAN}
    AMF Sends PDU MODIFY REQUEST      14       2       cause=${NGRAN}
    AMF Sends PDU MODIFY REQUEST      17       2       cause=${NGRAN}
    AMF Sends PDU MODIFY REQUEST      17       1       cause=${NGRAN}

All PDU Modify For CB014583 UE LOST
    [Documentation]     All PDU Modify For CB014583 with cause RN_radio_connection_with_ue_lost
    AMF Sends PDU MODIFY REQUEST      19        3       cause=${UE_LOST}
    AMF Sends PDU MODIFY REQUEST      22        3       cause=${UE_LOST}

All PDU Modify For CB014583 CN
    [Documentation]     All PDU Modify For CB014583 with cause RN_release_due_to_cn_detected_mobility
    AMF Sends PDU MODIFY REQUEST      3        3       cause=${CN}
    AMF Sends PDU MODIFY REQUEST      3        2       cause=${CN}
    AMF Sends PDU MODIFY REQUEST      6        3       cause=${CN}
    AMF Sends PDU MODIFY REQUEST      6        2       cause=${CN}
    AMF Sends PDU MODIFY REQUEST      9        5       cause=${CN}
    AMF Sends PDU MODIFY REQUEST      9        4       cause=${CN}
    Run Keyword And Ignore Error    AMF Sends PDU MODIFY REQUEST      12       4       cause=${CN}
    Run Keyword And Ignore Error    AMF Sends PDU MODIFY REQUEST      12       5       cause=${CN}
    AMF Sends PDU MODIFY REQUEST      15       1       cause=${CN}
    AMF Sends PDU MODIFY REQUEST      15       2       cause=${CN}
    AMF Sends PDU MODIFY REQUEST      18       2       cause=${CN}
    AMF Sends PDU MODIFY REQUEST      18       1       cause=${CN}

All PDU Modify For CB014583 5GC TMO
    [Documentation]     All PDU Modify For CB014583 with cause RN_release_due_to_5gc_generated_reason
    AMF Sends PDU MODIFY REQUEST      1        6       cause=${5GC}		# 5qi1
	AMF Sends PDU MODIFY REQUEST      1        4       cause=${5GC}		# 5qi9
    AMF Sends PDU MODIFY REQUEST      5        4       cause=${5GC}		# 5qi1
    AMF Sends PDU MODIFY REQUEST      5        6       cause=${5GC}		# 5qi9
    AMF Sends PDU MODIFY REQUEST      21       7       cause=${5GC}		# 5qi3
    AMF Sends PDU MODIFY REQUEST      21       1       cause=${5GC}		# 5qi6
    AMF Sends PDU MODIFY REQUEST      25       1       cause=${5GC}		# 5qi6
    AMF Sends PDU MODIFY REQUEST      25       7       cause=${5GC}		# 5qi3
    AMF Sends PDU MODIFY REQUEST      31       5       cause=${5GC}		# 5qi5
    AMF Sends PDU MODIFY REQUEST      31       3       cause=${5GC}		# 5qi8
    AMF Sends PDU MODIFY REQUEST      35       3       cause=${5GC}		# 5qi8
    AMF Sends PDU MODIFY REQUEST      35       5       cause=${5GC}		# 5qi5
	AMF Sends PDU MODIFY REQUEST      41       1       cause=${5GC}		# 5qi6
    AMF Sends PDU MODIFY REQUEST      41       2       cause=${5GC}		# 5qi7
    AMF Sends PDU MODIFY REQUEST      45       2       cause=${5GC}		# 5qi7
    AMF Sends PDU MODIFY REQUEST      45       1       cause=${5GC}		# 5qi6

All PDU Modify For CB014583 NGRAN TMO
    [Documentation]     All PDU Modify For CB014583 with cause RN_release_due_to_ngran_generated_reason
    AMF Sends PDU MODIFY REQUEST      2        6       cause=${NGRAN}		# 5qi1
	AMF Sends PDU MODIFY REQUEST      2        4       cause=${NGRAN}		# 5qi9
    AMF Sends PDU MODIFY REQUEST      6        4       cause=${NGRAN}		# 5qi1
    AMF Sends PDU MODIFY REQUEST      6        6       cause=${NGRAN}		# 5qi9
    AMF Sends PDU MODIFY REQUEST      22       7       cause=${NGRAN}		# 5qi3
    AMF Sends PDU MODIFY REQUEST      22       1       cause=${NGRAN}		# 5qi6
    AMF Sends PDU MODIFY REQUEST      26       1       cause=${NGRAN}		# 5qi6
    AMF Sends PDU MODIFY REQUEST      26       7       cause=${NGRAN}		# 5qi3
    AMF Sends PDU MODIFY REQUEST      32       5       cause=${NGRAN}		# 5qi5
    AMF Sends PDU MODIFY REQUEST      32       3       cause=${NGRAN}		# 5qi8
    AMF Sends PDU MODIFY REQUEST      36       3       cause=${NGRAN}		# 5qi8
    AMF Sends PDU MODIFY REQUEST      36       5       cause=${NGRAN}		# 5qi5
	AMF Sends PDU MODIFY REQUEST      42       1       cause=${NGRAN}		# 5qi6
    AMF Sends PDU MODIFY REQUEST      42       2       cause=${NGRAN}		# 5qi7
    AMF Sends PDU MODIFY REQUEST      46       2       cause=${NGRAN}		# 5qi7
    AMF Sends PDU MODIFY REQUEST      46       1       cause=${NGRAN}		# 5qi6

All PDU Modify For CB014583 UE LOST TMO
    [Documentation]     All PDU Modify For CB014583 with cause RN_radio_connection_with_ue_lost
    AMF Sends PDU MODIFY REQUEST      4        6       cause=${UE_LOST}
    AMF Sends PDU MODIFY REQUEST      8        6       cause=${UE_LOST}

All PDU Modify For CB014583 CN TMO
    [Documentation]     All PDU Modify For CB014583 with cause RN_release_due_to_cn_detected_mobility
    AMF Sends PDU MODIFY REQUEST      3        6       cause=${CN}		# 5qi1
	AMF Sends PDU MODIFY REQUEST      3        4       cause=${CN}		# 5qi9
    AMF Sends PDU MODIFY REQUEST      7        4       cause=${CN}		# 5qi1
    AMF Sends PDU MODIFY REQUEST      7        6       cause=${CN}		# 5qi9
    AMF Sends PDU MODIFY REQUEST      23       7       cause=${CN}		# 5qi3
    AMF Sends PDU MODIFY REQUEST      23       1       cause=${CN}		# 5qi6
    AMF Sends PDU MODIFY REQUEST      27       1       cause=${CN}		# 5qi6
    AMF Sends PDU MODIFY REQUEST      27       7       cause=${CN}		# 5qi3
    AMF Sends PDU MODIFY REQUEST      33       5       cause=${CN}		# 5qi5
    AMF Sends PDU MODIFY REQUEST      33       3       cause=${CN}		# 5qi8
    AMF Sends PDU MODIFY REQUEST      37       3       cause=${CN}		# 5qi8
    AMF Sends PDU MODIFY REQUEST      37       5       cause=${CN}		# 5qi5
	AMF Sends PDU MODIFY REQUEST      43       1       cause=${CN}		# 5qi6
    AMF Sends PDU MODIFY REQUEST      43       2       cause=${CN}		# 5qi7
    AMF Sends PDU MODIFY REQUEST      47       2       cause=${CN}		# 5qi7
    AMF Sends PDU MODIFY REQUEST      47       1       cause=${CN}		# 5qi6

All PDU Release For CB014583 5GC
    [Documentation]     All PDU Release For CB014583 with cause RN_release_due_to_5gc_generated_reason
    AMF Sends PDU Release REQUEST      1               cause=${5GC}
    AMF Sends PDU Release REQUEST      4               cause=${5GC}
    AMF Sends PDU Release REQUEST      7               cause=${5GC}
    AMF Sends PDU Release REQUEST      10              cause=${5GC}
    AMF Sends PDU Release REQUEST      13              cause=${5GC}
    AMF Sends PDU Release REQUEST      16              cause=${5GC}

All PDU Release For CB014583 5GC TMO
    [Documentation]     All PDU Release For CB014583 with cause RN_release_due_to_5gc_generated_reason
    AMF Sends PDU Release REQUEST      1               cause=${5GC}
    AMF Sends PDU Release REQUEST      2               cause=${5GC}
    AMF Sends PDU Release REQUEST      3               cause=${5GC}
    AMF Sends PDU Release REQUEST      5               cause=${5GC}
    AMF Sends PDU Release REQUEST      6               cause=${5GC}
    AMF Sends PDU Release REQUEST      7               cause=${5GC}

All PDU Release For CB014583 NGRAN
    [Documentation]     All PDU Release For CB014583 with cause RN_release_due_to_ngran_generated_reason
    AMF Sends PDU Release REQUEST      2               cause=${NGRAN}
    AMF Sends PDU Release REQUEST      5               cause=${NGRAN}
    AMF Sends PDU Release REQUEST      8               cause=${NGRAN}
    AMF Sends PDU Release REQUEST      11              cause=${NGRAN}
    AMF Sends PDU Release REQUEST      14              cause=${NGRAN}
    AMF Sends PDU Release REQUEST      17              cause=${NGRAN}

All PDU Release For CB014583 NGRAN TMO
    [Documentation]     All PDU Release For CB014583 with cause RN_release_due_to_ngran_generated_reason
    AMF Sends PDU Release REQUEST      21              cause=${NGRAN}
    AMF Sends PDU Release REQUEST      22              cause=${NGRAN}
    AMF Sends PDU Release REQUEST      23              cause=${NGRAN}
    AMF Sends PDU Release REQUEST      25              cause=${NGRAN}
    AMF Sends PDU Release REQUEST      26              cause=${NGRAN}
    AMF Sends PDU Release REQUEST      27              cause=${NGRAN}

All PDU Release For CB014583 CN
    [Documentation]     All PDU Release For CB014583 with cause RN_release_due_to_cn_detected_mobility
    AMF Sends PDU Release REQUEST      3               cause=${CN}
    AMF Sends PDU Release REQUEST      6               cause=${CN}
    AMF Sends PDU Release REQUEST      9               cause=${CN}
    AMF Sends PDU Release REQUEST      12              cause=${CN}
    AMF Sends PDU Release REQUEST      15              cause=${CN}
    AMF Sends PDU Release REQUEST      18              cause=${CN}

All PDU Release For CB014583 CN TMO
    [Documentation]     All PDU Release For CB014583 with cause RN_release_due_to_cn_detected_mobility
    AMF Sends PDU Release REQUEST      31              cause=${CN}
    AMF Sends PDU Release REQUEST      32              cause=${CN}
    AMF Sends PDU Release REQUEST      33              cause=${CN}
    AMF Sends PDU Release REQUEST      35              cause=${CN}
    AMF Sends PDU Release REQUEST      36              cause=${CN}
    AMF Sends PDU Release REQUEST      37              cause=${CN}

All PDU Release For CB014583 UE Lost
    [Documentation]     All PDU Release For CB014583 with cause RN_radio_connection_with_ue_lost
    AMF Sends PDU Release REQUEST      21              cause=${UE_LOST}
    AMF Sends PDU Release REQUEST      24              cause=${UE_LOST}

All PDU Release For CB014583 UE Lost TMO
    [Documentation]     All PDU Release For CB014583 with cause RN_radio_connection_with_ue_lost
    AMF Sends PDU Release REQUEST      4              cause=${UE_LOST}
    AMF Sends PDU Release REQUEST      8              cause=${UE_LOST}

All UE NG Context Release For CB014583 5GC
    [Documentation]     All PDU Modify For CB014583 with cause RN_release_due_to_5gc_generated_reason
    Context Release For UE NG      1        cause=${5GC}
	Context Release For UE NG      4        cause=${5GC}
	Context Release For UE NG      7        cause=${5GC}
	Context Release For UE NG      10       cause=${5GC}
	Context Release For UE NG      13       cause=${5GC}
	Context Release For UE NG      16       cause=${5GC}

All UE NG Context Release For CB014583 5GC For TMO
    [Documentation]     All PDU Modify For CB014583 with cause RN_release_due_to_5gc_generated_reason
    Context Release For UE NG      1        cause=${5GC}
    Context Release For UE NG      2        cause=${5GC}
    Context Release For UE NG      3        cause=${5GC}
    Context Release For UE NG      5        cause=${5GC}
    Context Release For UE NG      6        cause=${5GC}
    Context Release For UE NG      7        cause=${5GC}

All UE NG Context Release For CB014583 NGRAN
    [Documentation]     All UE NG Context Release For CB014583 with cause RN_release_due_to_ngran_generated_reason
	Context Release For UE NG      2        cause=${NGRAN}
	Context Release For UE NG      5        cause=${NGRAN}
	Context Release For UE NG      8        cause=${NGRAN}
	Context Release For UE NG      11       cause=${NGRAN}
	Context Release For UE NG      14       cause=${NGRAN}
	Context Release For UE NG      17       cause=${NGRAN}

All UE NG Context Release For CB014583 NGRAN For TMO
    [Documentation]     All UE NG Context Release For CB014583 with cause RN_release_due_to_ngran_generated_reason
    Context Release For UE NG      21        cause=${NGRAN}
    Context Release For UE NG      22        cause=${NGRAN}
    Context Release For UE NG      23       cause=${NGRAN}
    Context Release For UE NG      25       cause=${NGRAN}
    Context Release For UE NG      26       cause=${NGRAN}
    Context Release For UE NG      27       cause=${NGRAN}

All UE NG Context Release For CB014583 CN
    [Documentation]     All UE NG Context Release For CB014583 with cause RN_release_due_to_cn_detected_mobility
	Context Release For UE NG      3        cause=${CN}
	Context Release For UE NG      6        cause=${CN}
	Context Release For UE NG      9        cause=${CN}
	Context Release For UE NG      12       cause=${CN}
	Context Release For UE NG      15       cause=${CN}
	Context Release For UE NG      18       cause=${CN}

All UE NG Context Release For CB014583 CN For TMO
    [Documentation]     All UE NG Context Release For CB014583 with cause RN_release_due_to_cn_detected_mobility
    Context Release For UE NG      31        cause=${CN}
    Context Release For UE NG      32        cause=${CN}
    Context Release For UE NG      33        cause=${CN}
    Context Release For UE NG      35        cause=${CN}
    Context Release For UE NG      36        cause=${CN}
    Context Release For UE NG      37        cause=${CN}

All UE NG Context Release For CB014583 UE Lost
    [Documentation]     All UE NG Context Release For CB014583 with cause RN_radio_connection_with_ue_lost
    Context Release For UE NG      21        cause=${UE_LOST}
    Context Release For UE NG      24        cause=${UE_LOST}

All UE NG Context Release For CB014583 UE Lost For TMO
    [Documentation]     All UE NG Context Release For CB014583 with cause RN_radio_connection_with_ue_lost
    Context Release For UE NG      44        cause=${UE_LOST}
    Context Release For UE NG      48        cause=${UE_LOST}

5GC PM Counters
    [Documentation]     Verification of 5GC PM Counters Specific to Test Case
    [Arguments]     ${PM_File}=${pm_counter_file}		${CELLID}=${CELL1}
    Verify Last Counters In File
    ...     M55125C09534     6      NG_FLOW_REL_AMF_5GCGENRSN
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
	Verify Last Counters In File
    ...     M55125C09535     1      NG_FLOW_REL_AMF_5GCGENRSN_5QI1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
	Verify Last Counters In File
    ...     M55125C09545     1      NG_FLOW_REL_AMF_5GGENISSN_5QI1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00522     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-1
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00522     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-9
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00522     value=2
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-13

NGRAN PM Counters
    [Documentation]     Verification of the NGRAN PM Counters specific to test cases.
    [Arguments]         ${PM_File}=${pm_counter_file}		${CELLID}=${CELL2}
    Verify Last Counters In File
    ...     M55125C09536     6      NG_FLOW_REL_AMF_NGGENRSN
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
	Verify Last Counters In File
    ...     M55125C09539     6      NG_FLOW_REL_AMF_NGGENISSN_5QI1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
	Verify Last Counters In File
    ...     M55125C09537     1      NG_FLOW_REL_AMF_NGGENRSN_5QI1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
	Verify Last Counters In File
    ...     M55125C09538     1      NG_FLOW_REL_AMF_NGGENISSN_5QI1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00523     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-1
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00523     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-2
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00523     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-9
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00524     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-1
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00524     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-2
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00524     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-9

CN PM Counters
    [Documentation]     Verification of CN PM Counters specific to the Testcase Scenario
	[Arguments]         ${PM_File}=${pm_counter_file}		${CELLID}=${CELL3}
	Verify Last Counters In File
    ...     M55125C09540     6      NG_FLOW_REL_AMF_CNDETMOB
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
	Verify Last Counters In File
    ...     M55125C09541     1      NG_FLOW_REL_AMF_CNDETMOB_5QI1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
	Verify Last Counters In File
    ...     M55125C09542     6      NG_FLOW_REL_AMF_CNDETMOBISSN
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
	Verify Last Counters In File
    ...     M55125C09543     1      NG_FLOW_REL_AMF_CNDTMBISN_5QI1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
	Verify Last Counters In File
    ...     M55125C08504     6      NG_FLOW_REL_NORMAL
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
	Verify Last Counters In File
    ...     M55125C09514     1      NG_FLOW_REL_NORMAL_5QI1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
	Verify Last Counters In File
    ...     M55125C09025     6      NG_FLOW_REL_NORMAL_INSESSION
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00013     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-1
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00013     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-2
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00013     value=2
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-5
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00013     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-6
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00013     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-9
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00004     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-1
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00004     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-2
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00004     value=2
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-5
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00004     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-6
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00004     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-9
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00527     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-1
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00527     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-2
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00527     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-9
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00527     value=2
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-13
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00526     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-1
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00526     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-2
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00526     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-9
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00526     value=2
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-13

Special Counters For CB014583
    [Documentation]     Verification of few other Counters.
	[Arguments]     ${PM_File}=${pm_counter_file}
	Verify Last Counters In File
    ...     M55125C09544     2      NG_FLOW_REL_ABNORMAL_INSN_5QI1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL1}
    ...     file_path=${PM_File}
    Verify Last Counters In File
    ...     M55125C09544     1      NG_FLOW_REL_ABNORMAL_INSN_5QI1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL2}
    ...     file_path=${PM_File}
    Verify Last Counters In File
    ...     M55125C09544     0      NG_FLOW_REL_ABNORMAL_INSN_5QI1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL3}
    ...     file_path=${PM_File}
	Verify Last Counters In File
    ...     M55125C09544     2      NG_FLOW_REL_ABNORMAL_INSN_5QI1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL4}
    ...     file_path=${PM_File}
    Verify Last Counters In File
    ...     M55125C09544     1      NG_FLOW_REL_ABNORMAL_INSN_5QI1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL5}
    ...     file_path=${PM_File}
    Verify Last Counters In File
    ...     M55125C09544     0      NG_FLOW_REL_ABNORMAL_INSN_5QI1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL6}
    ...     file_path=${PM_File}
    Verify Last Counters In File
    ...     M55125C00069     1      NG_FLOW_REL_AMF_5GGENISSN_5QI1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL1}
    ...     file_path=${PM_File}
    Verify Last Counters In File
    ...     M55125C00069     1      NG_FLOW_REL_AMF_5GGENISSN_5QI1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL4}
    ...     file_path=${PM_File}

5GC PM Counters Release
    [Documentation]     Verification of 5GC PM Counters Specific to Test Case
    [Arguments]     ${PM_File}=${pm_counter_file}		${CELLID}=${CELL1}
    Verify Last Counters In File
    ...     M55125C09534     12      NG_FLOW_REL_AMF_5GCGENRSN
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
	Verify Last Counters In File
    ...     M55125C09535     2      NG_FLOW_REL_AMF_5GCGENRSN_5QI1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
	Verify Last Counters In File
    ...     M55125C09545     2      NG_FLOW_REL_AMF_5GGENISSN_5QI1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00522     value=2
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-1
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00522     value=3
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-2
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00522     value=3
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-5
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00522     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-6
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00522     value=3
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-9
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00522     value=3
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-13

NGRAN PM Counters Release
    [Documentation]     Verification of the NGRAN PM Counters specific to test cases.
    [Arguments]         ${PM_File}=${pm_counter_file}		${CELLID}=${CELL2}
    Verify Last Counters In File
    ...     M55125C09536     12      NG_FLOW_REL_AMF_NGGENRSN
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
	Verify Last Counters In File
    ...     M55125C09537     2      NG_FLOW_REL_AMF_NGGENRSN_5QI1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
	Verify Last Counters In File
    ...     M55125C09538     2      NG_FLOW_REL_AMF_NGGENISSN_5QI1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
	Verify Last Counters In File
    ...     M55125C09539     12      NG_FLOW_REL_AMF_NGGENISSN
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00523     value=2
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-1
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00523     value=3
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-2
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00523     value=3
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-9
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00524     value=2
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-1
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00524     value=3
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-2
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00524     value=3
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-9

CN PM Counters Release
    [Documentation]     Verification of CN PM Counters specific to the Testcase Scenario
    [Arguments]         ${PM_File}=${pm_counter_file}		${CELLID}=${CELL3}
    Verify Last Counters In File
    ...     M55125C09540     12      NG_FLOW_REL_AMF_CNDETMOB
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
	Verify Last Counters In File
    ...     M55125C09541     2      NG_FLOW_REL_AMF_CNDETMOB_5QI1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
	Verify Last Counters In File
    ...     M55125C09542     12      NG_FLOW_REL_AMF_CNDETMOBISSN
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
	Verify Last Counters In File
    ...     M55125C09543     2      NG_FLOW_REL_AMF_CNDTMBISN_5QI1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00527     value=2
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-1
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00527     value=3
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-2
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00527     value=3
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-5
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00527     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-6
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00527     value=3
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-9
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00527     value=3
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-13
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00526     value=2
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-1
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00526     value=3
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-2
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00526     value=3
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-5
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00526     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-6
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00526     value=3
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-9
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00526     value=3
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-13
    Verify Last Counters In File
    ...     M55125C08504     12      NG_FLOW_REL_NORMAL
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
	Verify Last Counters In File
    ...     M55125C09514     2      NG_FLOW_REL_NORMAL_5QI1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
	Verify Last Counters In File
    ...     M55125C09025     12      NG_FLOW_REL_NORMAL_INSESSION
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00013     value=2
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-1
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00013     value=3
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-2
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00013     value=3
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-5
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00013     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-6
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00013     value=3
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-9
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00004     value=2
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-1
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00004     value=3
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-2
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00004     value=3
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-5
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00004     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-6
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00004     value=3
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-9

Special Counters For CB014583 Release
    [Documentation]     Verification of few other Counters.
    [Arguments]     ${PM_File}=${pm_counter_file}
    Verify Last Counters In File
    ...     M55125C09544     2      NG_FLOW_REL_ABNORMAL_INSN_5QI1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL1}
    ...     file_path=${PM_File}
    Verify Last Counters In File
    ...     M55125C09544     2      NG_FLOW_REL_ABNORMAL_INSN_5QI1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL2}
    ...     file_path=${PM_File}
    Verify Last Counters In File
    ...     M55125C09544     1      NG_FLOW_REL_ABNORMAL_INSN_5QI1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL3}
    ...     file_path=${PM_File}
	Verify Last Counters In File
    ...     M55125C09544     2      NG_FLOW_REL_ABNORMAL_INSN_5QI1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL4}
    ...     file_path=${PM_File}
    Verify Last Counters In File
    ...     M55125C09544     2      NG_FLOW_REL_ABNORMAL_INSN_5QI1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL5}
    ...     file_path=${PM_File}
    Verify Last Counters In File
    ...     M55125C00069     1      NG_FLOW_REL_AMF_5GGENISSN_5QI1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL3}
    ...     file_path=${PM_File}
    Verify Last Counters In File
    ...     M55125C00069     1      NG_FLOW_REL_AMF_5GGENISSN_5QI1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL6}
    ...     file_path=${PM_File}

5GC PM Counters UE Release TMO
	[Documentation]     Verification of 5GC PM Counters Specific to Test Case
	[Arguments]     ${PM_File}=${pm_counter_file}       ${CELLID}=${CELL1}
	Verify Last Counters In File
	...     M55125C09534     4      NG_FLOW_REL_AMF_5GCGENRSN
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
	...     file_path=${PM_File}
	Verify Last Counters In File
	...     M55125C09535     1      NG_FLOW_REL_AMF_5GCGENRSN_5QI1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
	...     file_path=${PM_File}
	Verify Last Counters In File
	...     M55125C09545     1      NG_FLOW_REL_AMF_5GGENISSN_5QI1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
	...     file_path=${PM_File}
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00522     value=1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-6
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00522     value=1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-9
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00522     value=1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-5
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00522     value=1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-1

NGRAN PM Counters UE Release TMO
	[Documentation]     Verification of the NGRAN PM Counters specific to test cases.
	[Arguments]         ${PM_File}=${pm_counter_file}       ${CELLID}=${CELL2}
	Verify Last Counters In File
	...     M55125C09536     4      NG_FLOW_REL_AMF_NGGENRSN
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
	...     file_path=${PM_File}
	Verify Last Counters In File
	...     M55125C09539     4      NG_FLOW_REL_AMF_NGGENISSN_5QI1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
	...     file_path=${PM_File}
	Verify Last Counters In File
	...     M55125C09537     1      NG_FLOW_REL_AMF_NGGENRSN_5QI1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
	...     file_path=${PM_File}
	Verify Last Counters In File
	...     M55125C09538     1      NG_FLOW_REL_AMF_NGGENISSN_5QI1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
	...     file_path=${PM_File}
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00523     value=1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-6
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00523     value=1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-5
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00523     value=1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-1
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00523     value=1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-3
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00524     value=1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-6
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00524     value=1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-5
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00524     value=1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-1
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00524     value=1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-3

CN PM Counters UE Release TMO
	[Documentation]     Verification of CN PM Counters specific to the Testcase Scenario
	[Arguments]         ${PM_File}=${pm_counter_file}       ${CELLID}=${CELL3}
	Verify Last Counters In File
	...     M55125C09540     4      NG_FLOW_REL_AMF_CNDETMOB
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
	...     file_path=${PM_File}
	Verify Last Counters In File
	...     M55125C09541     1      NG_FLOW_REL_AMF_CNDETMOB_5QI1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
	...     file_path=${PM_File}
	Verify Last Counters In File
	...     M55125C09542     4      NG_FLOW_REL_AMF_CNDETMOBISSN
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
	...     file_path=${PM_File}
	Verify Last Counters In File
	...     M55125C09543     1      NG_FLOW_REL_AMF_CNDTMBISN_5QI1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
	...     file_path=${PM_File}
	Verify Last Counters In File
	...     M55125C08504     4      NG_FLOW_REL_NORMAL
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
	...     file_path=${PM_File}
	Verify Last Counters In File
	...     M55125C09514     1      NG_FLOW_REL_NORMAL_5QI1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
	...     file_path=${PM_File}
	Verify Last Counters In File
	...     M55125C09025     4      NG_FLOW_REL_NORMAL_INSESSION
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
	...     file_path=${PM_File}
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00013     value=1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-1
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00013     value=1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-5
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00013     value=1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-6
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00013     value=1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-8
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00004     value=1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-1
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00004     value=1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-5
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00004     value=1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-6
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00004     value=1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-8
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00527     value=1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-1
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00527     value=1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-5
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00527     value=1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-6
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00527     value=1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-8
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00526     value=1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-1
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00526     value=1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-5
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00526     value=1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-6
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00526     value=1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-8

Special Counters For CB014583 Release For TMO
	[Documentation]     Verification of few other Counters.
	[Arguments]     ${PM_File}=${pm_counter_file}
	Verify Last Counters In File
	...     M55125C09544     2      NG_FLOW_REL_ABNORMAL_INSN_5QI1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL1}
	...     file_path=${PM_File}
	Verify Last Counters In File
	...     M55125C09544     2      NG_FLOW_REL_ABNORMAL_INSN_5QI1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL2}
	...     file_path=${PM_File}
	Verify Last Counters In File
	...     M55125C09544     2      NG_FLOW_REL_ABNORMAL_INSN_5QI1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL3}
	...     file_path=${PM_File}
	Verify Last Counters In File
	...     M55125C09544     1      NG_FLOW_REL_ABNORMAL_INSN_5QI1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL4}
	...     file_path=${PM_File}
	Verify Last Counters In File
	...     M55125C09544     2      NG_FLOW_REL_ABNORMAL_INSN_5QI1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL7}
	...     file_path=${PM_File}
	Verify Last Counters In File
	...     M55125C09544     2      NG_FLOW_REL_ABNORMAL_INSN_5QI1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL8}
	...     file_path=${PM_File}
	Verify Last Counters In File
	...     M55125C09544     2      NG_FLOW_REL_ABNORMAL_INSN_5QI1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL10}
	...     file_path=${PM_File}
	Verify Last Counters In File
	...     M55125C09544     1      NG_FLOW_REL_ABNORMAL_INSN_5QI1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL11}
	...     file_path=${PM_File}
	Verify Last Counters In File
	...     M55125C00069     1      NG_FLOW_REL_AMF_5GGENISSN_5QI1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL4}
	...     file_path=${PM_File}
	Verify Last Counters In File
	...     M55125C00069     1      NG_FLOW_REL_AMF_5GGENISSN_5QI1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL11}
	...     file_path=${PM_File}

5GC PM Counters TMO
    [Documentation]     Verification of 5GC PM Counters Specific to Test Case
	[Arguments]     ${PM_File}=${pm_counter_file}       ${CELLID}=${CELL1}
	Verify Last Counters In File
	...     M55125C09534     8      NG_FLOW_REL_AMF_5GCGENRSN
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
	...     file_path=${PM_File}
	Verify Last Counters In File
	...     M55125C09535     1      NG_FLOW_REL_AMF_5GCGENRSN_5QI1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
	...     file_path=${PM_File}
	Verify Last Counters In File
	...     M55125C09545     1      NG_FLOW_REL_AMF_5GGENISSN_5QI1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
	...     file_path=${PM_File}
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00522     value=1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-1
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00522     value=1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-3
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00522     value=1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-5
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00522     value=2
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-6
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00522     value=1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-7
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00522     value=1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-8
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00522     value=1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-9

NGRAN PM Counters TMO
	[Documentation]     Verification of the NGRAN PM Counters specific to test cases.
	[Arguments]         ${PM_File}=${pm_counter_file}       ${CELLID}=${CELL2}
	Verify Last Counters In File
	...     M55125C09536     8      NG_FLOW_REL_AMF_NGGENRSN
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
	...     file_path=${PM_File}
	Verify Last Counters In File
	...     M55125C09539     8      NG_FLOW_REL_AMF_NGGENISSN_5QI1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
	...     file_path=${PM_File}
	Verify Last Counters In File
	...     M55125C09537     1      NG_FLOW_REL_AMF_NGGENRSN_5QI1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
	...     file_path=${PM_File}
	Verify Last Counters In File
	...     M55125C09538     1      NG_FLOW_REL_AMF_NGGENISSN_5QI1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
	...     file_path=${PM_File}
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00523     value=1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-1
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00523     value=1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-3
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00523     value=1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-5
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00523     value=2
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-6
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00523     value=1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-7
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00523     value=1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-8
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00523     value=1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-9
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00524     value=1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-1
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00524     value=1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-3
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00524     value=1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-5
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00524     value=2
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-6
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00524     value=1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-7
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00524     value=1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-8
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00524     value=1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
	...     pmqap=PLMN-PLMN/NRPMQAP-9

CN PM Counters TMO
    [Documentation]     Verification of CN PM Counters specific to the Testcase Scenario
    [Arguments]         ${PM_File}=${pm_counter_file}       ${CELLID}=${CELL3}
    Verify Last Counters In File
    ...     M55125C09540     8      NG_FLOW_REL_AMF_CNDETMOB
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
    Verify Last Counters In File
    ...     M55125C09541     1      NG_FLOW_REL_AMF_CNDETMOB_5QI1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
    Verify Last Counters In File
    ...     M55125C09542     8      NG_FLOW_REL_AMF_CNDETMOBISSN
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
    Verify Last Counters In File
    ...     M55125C09543     1      NG_FLOW_REL_AMF_CNDTMBISN_5QI1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
    Verify Last Counters In File
    ...     M55125C08504     8      NG_FLOW_REL_NORMAL
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
    Verify Last Counters In File
    ...     M55125C09514     1      NG_FLOW_REL_NORMAL_5QI1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
    Verify Last Counters In File
    ...     M55125C09025     8      NG_FLOW_REL_NORMAL_INSESSION
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00013     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-1
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00013     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-3
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00013     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-5
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00013     value=2
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-6
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00013     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-7
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00013     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-8
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00013     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-9
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00004     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-1
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00004     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-3
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00004     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-5
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00004     value=2
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-6
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00004     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-7
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00004     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-8
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00004     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-9
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00527     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-1
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00527     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-3
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00527     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-5
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00527     value=2
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-6
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00527     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-7
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00527     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-8
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00527     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-9
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00526     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-1
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00526     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-3
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00526     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-5
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00526     value=2
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-6
	Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00526     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-7
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00526     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-8
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00526     value=1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-9

Special Counters For CB014583 TMO
	[Documentation]     Verification of few other Counters.
	[Arguments]     ${PM_File}=${pm_counter_file}
	Verify Last Counters In File
	...     M55125C09544     1      NG_FLOW_REL_ABNORMAL_INSN_5QI1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL1}
	...     file_path=${PM_File}
	Verify Last Counters In File
	...     M55125C09544     1      NG_FLOW_REL_ABNORMAL_INSN_5QI1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL2}
	...     file_path=${PM_File}
	Verify Last Counters In File
	...     M55125C09544     0      NG_FLOW_REL_ABNORMAL_INSN_5QI1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL3}
	...     file_path=${PM_File}
	Verify Last Counters In File
	...     M55125C09544     1      NG_FLOW_REL_ABNORMAL_INSN_5QI1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL4}
	...     file_path=${PM_File}
	Verify Last Counters In File
	...     M55125C09544     1      NG_FLOW_REL_ABNORMAL_INSN_5QI1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL7}
	...     file_path=${PM_File}
	Verify Last Counters In File
	...     M55125C09544     1      NG_FLOW_REL_ABNORMAL_INSN_5QI1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL8}
	...     file_path=${PM_File}
	Verify Last Counters In File
	...     M55125C09544     0      NG_FLOW_REL_ABNORMAL_INSN_5QI1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL10}
	...     file_path=${PM_File}
	Verify Last Counters In File
	...     M55125C09544     1      NG_FLOW_REL_ABNORMAL_INSN_5QI1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL11}
	...     file_path=${PM_File}
	Verify Last Counters In File
	...     M55125C00069     1      NG_FLOW_REL_AMF_5GGENISSN_5QI1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL11}
	...     file_path=${PM_File}
	Verify Last Counters In File
	...     M55125C00069     1      NG_FLOW_REL_AMF_5GGENISSN_5QI1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL4}
	...     file_path=${PM_File}

Validate Counter For Normal Release
    [Documentation]     Verification of 5GC PM Counters Specific to Test Case
    [Arguments]     ${PM_File}=${pm_counter_file}		${CELLID}=${CELL1}
    Verify Last Counters In File
    ...     M55125C09534     0      NG_FLOW_REL_AMF_5GCGENRSN
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
    Verify Last Counters In File
	...     M55125C09544     0      NG_FLOW_REL_ABNORMAL_INSN_5QI1
	...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
	...     file_path=${PM_File}
	Verify Last Counters In File
    ...     M55125C09535     0      NG_FLOW_REL_AMF_5GCGENRSN_5QI1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
	Verify Last Counters In File
    ...     M55125C09545     0      NG_FLOW_REL_AMF_5GGENISSN_5QI1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
    Verify Last Counters In File
    ...     M55163C00522     0      NG_FLOW_REL_AMF_5GCGENRSN_PMQP
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
    Verify Last Counters In File
    ...     M55125C09536     0      NG_FLOW_REL_AMF_NGGENRSN
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
    Verify Last Counters In File
    ...     M55125C09537     0      NG_FLOW_REL_AMF_NGGENRSN_5QI1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
    Verify Last Counters In File
    ...     M55163C00523     0      NG_FLOW_REL_AMF_NGGENRSN_PMQP
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
    Verify Last Counters In File
    ...     M55125C09538     0      NG_FLOW_REL_AMF_NGGENISSN_5QI1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
    Verify Last Counters In File
    ...     M55163C00524     0      NG_FLOW_REL_AMF_NGGENISSN_PMQP
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
    Verify Last Counters In File
    ...     M55125C09540     0      NG_FLOW_REL_AMF_CNDETMOB
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
    Verify Last Counters In File
    ...     M55125C09539     0      NG_FLOW_REL_AMF_NGGENISSN
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
    Verify Last Counters In File
    ...     M55163C00526     0      NG_FLOW_REL_AMF_CNDETMOB_PMQAP
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
    Verify Last Counters In File
    ...     M55125C09541     0      NG_FLOW_REL_AMF_CNDETMOB_5QI1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
    Verify Last Counters In File
    ...     M55125C09542     0      NG_FLOW_REL_AMF_CNDETMOBISSN
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
    Verify Last Counters In File
    ...     M55163C00527     0      NG_FLOW_REL_AMF_CNDETISSN_PMQP
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
    Verify Last Counters In File
    ...     M55125C09543     0      NG_FLOW_REL_AMF_CNDTMBISN_5QI1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
