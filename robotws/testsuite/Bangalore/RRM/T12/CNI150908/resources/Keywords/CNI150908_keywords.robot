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
...                 :author   : vijaylakshmi
...                 :contact  : vijaylakshmi.vijaylakshmi@nokia.com
...                 :Feature Related all common Keywords.


*** Variables ***
${TOPOLOGY}                CLOUD_5G_O_E_AP_LOOO
${DELTACONFIGDIR}          ${CURDIR}/../../config/scf
${AP_CONFIG_BASIC}         ${CURDIR}/../../config/wts
${5GC}                     RN_release_due_to_5gc_generated_reason
${NGRAN}                   RN_release_due_to_ngran_generated_reason
${CN}                      RN_release_due_to_cn_detected_mobility
${HW_FAIL}                 MISC_hardware_failure
${PDU_ID1}                 1
${PDU_SESSION_ADD}         Added QosFlow with QFI:(\\d+)\\s+fiveQI:(\\d+)
${PDU_SESSION_DEL} 	       Removed FiveQi
${TIMEOUT}                 200
${DL_PATTERN}             Started Downlink
${UL_PATTERN}             Started Uplink
${PDU_RELEASE}            Successfully released PDU Session
${UE_CTX_RELEASE}         UE CONTEXT RELEASE COMPLETE
${UE_LOST}                RN_radio_connection_with_ue_lost


*** Keywords ***
Prepare For CNI150908 RJIO
    [Documentation]    Preparing For CNI150908 with NIDD parameters update and Basic bring up OnAir
    ...     Also updating oncifg id and starting syslogs collection For RJIO TL.
    ${hhmm}     Get Current Time As HHMM
    ${Log_Path}    Create Log Directory     CNI150908RJIO${hhmm}
    Link SCOUT SCF To Configuration ID For Reporting
    Set Test Variable    ${Log_Path}
    Update BSR Package For RJIO
    GNB Delta Commission        ${DELTACONFIGDIR}/Delta_CNI150908_RJIO.json     timeout=500
    Sleep       30s
    Wait Coam Site To Be Ready
    Start UTE WTS     CNI150908_setup.cfg
    NG Link Should Be UP
    Sleep   90s

Get Current Time As HHMM
    [Documentation]     This keyword is used to create variable base on timein hour and min in HHMM format
    ${time}     Get Time    result_format=%H%M
    ${hh}       Get Substring       ${time}   11  13
    ${mm}       Get Substring       ${time}   14  16
    ${hhmm}     Set Variable        ${hh}${mm}
    [Return]    ${hhmm}

Common Tear Down For CNI150908 RJIO
    [Documentation]    Common Tear Down For CNI150908 RJIO where reverting back all changes and collecting Logs.
    slog.Stop Syslog
    Snapshot Collection     ${Log_Path}     Snapshot_RJIO.zip
    Copy Files      ${WTS_WORKING_DIR}/egate_console.log      ${LOG_PATH}
    Run     zip -r ${OUTPUTDIR}/CNI150908_RJIO.zip ${LOG_PATH}
    GNB Delta Commission       ${DELTACONFIGDIR}/Delta_Reverse_CNI150908_RJIO.json
    RAT Block Unblock

DL Traffic Should Be Successful CNI150908
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
    ELSE
        wtsrunner.Trf Data Start     ue=${UE_ID}     pdu=${PDU_ID1}     qfi=${QFI}
        ...         mbps=${dl_rate}       dir=dl     protocol=udp
        ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=${DL_PATTERN}    timeout=30
        ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
        Log to Console    ${output}
    END


UL Traffic Should Be Successful CNI150908
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
    ELSE
        wtsrunner.Trf Data Start     ue=${UE_ID}     pdu=${PDU_ID1}     qfi=${QFI}
        ...         mbps=${ul_rate}      dir=ul     protocol=udp
        ${output}   wtsrunner.Read Wtsemu Output Until Re    expected=${UL_PATTERN}    timeout=30
        ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
        Log to Console    ${output}
    END

Modify PDU Session For UE To Add
    [Arguments]    ${ue}     ${QFI}=2    ${PDU}=1    ${pattern}=${PDU_SESSION_ADD}
    UE PDU Session Modify    ue=${ue}     pdu=${PDU}      qosflows_to_add=${QFI}      by=amf
    wtsrunner.Read Wtsemu Output Until Re     ${pattern}      ${TIMEOUT}

Modify PDU Session For UE To Delete
    [Arguments]    ${ue}     ${QFI}=2    ${PDU}=1    ${pattern}=${PDU_SESSION_DEL}
    UE PDU Session Modify    ue=${ue}     pdu=${PDU}      qosflows_to_del=${QFI}      by=amf
    wtsrunner.Read Wtsemu Output Until Re     ${pattern}      ${TIMEOUT}

Release PDU Session For UE
    [Arguments]    ${ue}     ${PDU}=1    ${pattern}=${PDU_RELEASE}
    UE PDU Session Release      ue=${ue}    pdu=${PDU}
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
    [Arguments]         ${ue}=1    ${cause}=${NGRAN}     ${PDU}=1
    AMF UE PDU Release Param     id=1    ue=${ue}    action=override_ie
    ...      cause=${cause}
    Sleep    3s
    Release PDU Session For UE     ${ue}    ${PDU}

All UE NG Context Release For CNI150908 NGAP
	[Documentation]     All UE NG Context Release For CNI150908 with cause RN_release_due_to_radio_connection_with_ue_lost
	Context Release For UE NG      1        cause=${UE_LOST}
	Context Release For UE NG      2        cause=${UE_LOST}
	Context Release For UE NG      3        cause=${UE_LOST}
	Context Release For UE NG      4       cause=${UE_LOST}
	Context Release For UE NG      5       cause=${UE_LOST}
	Context Release For UE NG      6       cause=${UE_LOST}
	Context Release For UE NG      7        cause=${UE_LOST}
	Context Release For UE NG      8        cause=${UE_LOST}
	Context Release For UE NG      9        cause=${UE_LOST}
	Context Release For UE NG      10       cause=${UE_LOST}
	Context Release For UE NG      11       cause=${UE_LOST}
	Context Release For UE NG      12       cause=${UE_LOST}

CNI PM Counters
    [Documentation]     Verification of NGAP PM Counters specific to the Testcase Scenario
	[Arguments]         ${PM_File}=${pm_counter_file}      ${CELLID}=${CELL1}
	Verify Last Counters In File
    ...     M55125C09005     6      NG_FLOW_REL_GNB_UE_LOST
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
    Verify Last Counters In File
    ...     M55125C09505	2      NG_FLOW_REL_GNB_UE_LOST_5QI1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
	Verify Last Counters In File
    ...     M55125C13055     2      NG_UE_CTXT_REL_GNB_UE_LOST
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}
    ...     file_path=${PM_File}
    Verify If Latest Pm Counter Has Exact Value     counter_id=M55163C00506     value=2
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELLID}      filepath=${PM_File}
    ...     pmqap=PLMN-PLMN/NRPMQAP-1

CNI Related RLF Testmode Command
    [Arguments]     ${profId}=1     ${dlHarq}=5000       ${csi_rep}=5000
    wtsrunner.RLF Testmode NR    profile_id=${profId}    num_stop_dlharq_tx=${dlHarq}        num_stop_csi_report=${csi_rep}
    Sleep   10s
CNI Related UE Testmode Command
    [Arguments]     ${id}=1     ${tm}=rlf    ${act}=activate    ${profId}=1
    wtsrunner.UE Testmode Set NR     id=${id}    testmode=${tm}      action=${act}       profile_id=${profId}
    Sleep   10s
