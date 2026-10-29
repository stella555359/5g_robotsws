*** Settings ***
Force Tags      CLOUD_5G_I_MP_AP_LO

Resource         CB013233_Resource.robot

Suite Setup         Run keywords     Log to console      "Suite Setup started"
...                 AND     Suite setup from scratch
...                 AND     Configure UTE ETH3 IPs
...                 AND     Start Log   btslog
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND     sleep   2s

Suite Teardown      Run keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Log   btslog    snapshot    sosreport

Documentation
...
...             author:           Manasa
...             maintainer:       manasa.shankarappa@nokia.com
...
...             INTRODUCTION:     The user scenario targets the DRX configuration for SA UE during ICS.
...                               F1AP: UEContextSetupRequest message to gNB-DU to setup DRB, includes DRXCycle IE.
...                               First RRCReconfiguration to UE includes DRX configuration. After NGAP:InitialContextSetupResponse
...                               to AMF gNB does not send dedicated RRCReconfiguration to configure DRX to UE.
...
...
...
...             TEST SET NAME:    CB013233
...             TESTING SPLIT:    Refer CB013233 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB013233 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_26392



*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_A_B101.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${rad_params}       0x890091=1

${sa_ue_id1}      ${1}
${sa_ue_id2}      ${2}
${sa_ue_id3}      ${3}
${sa_ue_id4}      ${4}
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${TRF_ID}     1
${QFI_ID}     1
${QFI_ID1}     2
${QFI_ID2}     3
${QFI_ID3}     6

${TEST_NAME}     TC36
${CELL_ID}    1

${delta_file_name}=             Enable_DRX_GBR.json
${drb_inactivity_timer}=    60
${srb_inactivity_timer}=    60
${delta}=   30

*** Test Cases ***
CB013233-A#B101_Early_DRX_setup_MultiUE_SA_mode_during_ICS_with_PDU_TDD_different_DRX_profile
    [Tags]     QC_xxxx
    set suite variable     ${TEST_NAME}
    set test variable      ${LOG_PATH}
    Perform SCF Delta Commissioning with ${delta_file_name}
    X2AP Link Should be UP
    Wait until the next Measurement Period starts
    log to console   "SA UE attach "
#Step 1. Attach Multiple SA UE's with GBR and NON GBR Bearer
    CPRT Monitoring Start ASOH
    ${crnti_list}=    MultiUE Register should be Successful with DRX    ${sa_ue_id1}     ${sa_ue_id4}
    sleep     2s
    CPRT Monitoring Stop Collect ASOH    ${LOG_PATH}
#Step2: Check for early DRX in ICS ie, uecontextsetup request
    MoveFile    ${LOG_PATH}/SYSCOM_NODECPRT_GNB.pcap    ${LOG_PATH}/SYSCOM_NODECPRT_GNB_early_drx.pcap
    Verify DRXcycle in F1AP_UEContextSetupRequest for all UE   ${LOG_PATH}/SYSCOM_NODECPRT_GNB_early_drx.pcap   ${crnti_list}
    CPRT Monitoring Start ASOH
#Step3: Add 5QI-5 and 5Qi-1 VONR Bearer.
    Add new Bearer for Multiple SA UE    ${sa_ue_id1}    ${sa_ue_id4}    ${Pdu_session_ID}    ${QFI_ID1}
    Add new Bearer for Multiple SA UE    ${sa_ue_id1}    ${sa_ue_id4}    ${Pdu_session_ID}    ${QFI_ID2}
    CPRT Monitoring Stop Collect ASOH     ${LOG_PATH}
    MoveFile    ${LOG_PATH}/SYSCOM_NODECPRT_GNB.pcap    ${LOG_PATH}/SYSCOM_NODECPRT_GNB_VONR_drx.pcap
#Step4: VONR DRX profile is higher priority. Hence DRX gets released and setup with new values.
    Verify DRXcycle in F1AP_UEContextModificationRequest for all UE    ${LOG_PATH}/SYSCOM_NODECPRT_GNB_VONR_drx.pcap   ${crnti_list}
    CPRT Monitoring Start ASOH
#Step5: Add new GBR Bearer with DRX priority lower than VONR DRX
    Add new Bearer for Multiple SA UE    ${sa_ue_id1}    ${sa_ue_id4}    ${Pdu_session_ID}    ${QFI_ID3}
    CPRT Monitoring Stop Collect ASOH     ${LOG_PATH}
    MoveFile    ${LOG_PATH}/SYSCOM_NODECPRT_GNB.pcap    ${LOG_PATH}/SYSCOM_NODECPRT_GNB_5QI_2_drx.pcap
#Step6: Start bursty traffic only for UE-1 to hit DRX Sleep duration with 20Kbps
    MultiUE Trigger Bursty DL Traffic for SA    ${sa_ue_id1}    ${sa_ue_id1}   Traffic_rate=kbps   dl_rate=20    period_ms=1000ms
    ...   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID}
    MultiUE Trigger bursty UL Traffic for SA    ${sa_ue_id1}    ${sa_ue_id1}   Traffic_rate=kbps   ul_rate=20    period_ms=1000ms
    ...   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID}
    sleep   60s
    Run Keyword and continue on Failure       Validate DL Traffic For MultiUE for SA     ${sa_ue_id1}    ${sa_ue_id1}   dl_rate=0.02
    ...    pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID}
    Run Keyword and continue on Failure       Validate UL Traffic For MultiUE for SA     ${sa_ue_id1}    ${sa_ue_id1}   ul_rate=0.02
    ...    pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID}
    Wait until the current Measurement Period stops
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File Classical   output_dirpath=${OUTPUT DIR}/pmcounter1
#Step7: Check DRX Active and Sleep counters
    Verify Any Counters In File
    ...  M55308C11001  >1000   SLOTS_UE_DRX_ACTIVE
    ...  M55308C11002  >1000   SLOTS_UE_DRX_SLEEP
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
    ...  file_path=${pm_counter_file}
#Step8: Trigger bursty traffic for other UE's
    MultiUE Trigger Bursty DL Traffic for SA    ${sa_ue_id2}    ${sa_ue_id4}   Traffic_rate=kbps   dl_rate=20    period_ms=1000ms
    ...   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID}
    MultiUE Trigger bursty UL Traffic for SA    ${sa_ue_id2}    ${sa_ue_id4}   Traffic_rate=kbps   ul_rate=20    period_ms=1000ms
    ...   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID}
    sleep   60s
#Step9: Validate UL and DL data traffic for all UE's.
    Run Keyword and continue on Failure       Validate DL Traffic For MultiUE for SA     ${sa_ue_id1}    ${sa_ue_id4}   dl_rate=0.02
    ...    pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID}
    Run Keyword and continue on Failure       Validate UL Traffic For MultiUE for SA     ${sa_ue_id1}    ${sa_ue_id4}   ul_rate=0.02
    ...    pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID}
    Link SCOUT SCF to Configuration ID for Reporting
#Step10: Testcase Teardown Deregister UE
    [Teardown]   MultiUE Deregister should be Successful    ${sa_ue_id1}     ${sa_ue_id4}

*** Keywords ***
Prepare TL with rad_params without RMOD detection
    Log To Console    Configure ENV with rad params
    add gnb configuration    rad_params=${rad_params}
    configure environment     rmod_detection=False
    Log To Console    After Configure ENV

MultiUE Trigger Bursty DL Traffic for SA
    [Arguments]     ${start_ue_id}    ${end_ue_id}    ${Traffic_rate}    ${dl_rate}    ${period_ms}   ${pdu_id}=${Pdu_session_ID}
    ...     ${trf_id}=${TRF_ID}    ${qfi_id}=${QFI_ID}
    [Documentation]    This keyword starts the DL Traffic for the SA variant
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Log to Console    \nRunning DL Traffic for ${dl_rate} ${Traffic_rate}...
    wtsrunner.trf_data_start     ue=${ue_idx}    pdu=${pdu_id}   qfi=${qfi_id}    dir=dl    trf_id=${trf_id}
    ...    period_ms=${period_ms}    ${Traffic_rate}=${dl_rate}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Downlink Internal traffic*    timeout=10
#    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    ${output}         Get Lines Matching Regexp    ${output}    UDP DL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
    END
    BuiltIn.Log    DL_traffic_data_is_started_successfully


MultiUE Trigger Bursty UL Traffic for SA
    [Arguments]    ${start_ue_id}    ${end_ue_id}    ${Traffic_rate}    ${ul_rate}   ${period_ms}    ${pdu_id}=${Pdu_session_ID}
    ...     ${trf_id}=${TRF_ID}    ${qfi_id}=${QFI_ID}
    [Documentation]    This keyword starts the DL Traffic for the SA variant
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Log to Console    \nRunning UL Traffic for ${ul_rate} ${Traffic_rate}...
    wtsrunner.trf_data_start     ue=${ue_idx}    pdu=${pdu_id}   qfi=${qfi_id}    dir=ul    trf_id=${trf_id}
    ...    period_ms=${period_ms}    ${Traffic_rate}=${ul_rate}

    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Uplink Internal traffic*    timeout=10
#    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    ${output}         Get Lines Matching Regexp    ${output}    UDP UL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
    END
    BuiltIn.Log    UL_traffic_data_is_started_successfully


Verify DRXcycle in F1AP_UEContextSetupRequest for all UE
    [Arguments]   ${cprt_pcap}   ${crnti_list}
    FOR  ${rnti}  IN   @{crnti_list}
         Verify DRXcycle in F1AP_UEContextSetupRequest   ${cprt_pcap}   ${rnti}
    END

Verify DRXcycle in F1AP_UEContextModificationRequest for all UE
    [Arguments]   ${cprt_pcap}   ${crnti_list}
    FOR  ${rnti}  IN   @{crnti_list}
        Verify DRXcycle in F1AP_UEContextModificationRequest    ${cprt_pcap}    ${rnti}  longDRXCycleLength: ms40 (3)
    END

Verify DRXrelease in F1AP_UEContextModificationRequest for all UE
    [Arguments]   ${cprt_pcap}   ${crnti_list}
    FOR  ${rnti}  IN   @{crnti_list}
        Verify DRXrelease in F1AP_UEContextModificationRequest   ${cprt_pcap}   ${rnti}
    END

Add new Bearer for Multiple SA UE
     [Arguments]    ${first_ue_id}    ${last_ue_id}    ${pdu_id}      ${qos_id}
     FOR   ${ue_id}    IN RANGE    ${first_ue_id}     ${last_ue_id}+${1}
        UE PDU Modfication should be Successful   ${ue_id}      pdu_id=${pdu_id}      qosflows_to_add=${qos_id}
        sleep   5s
     END

MultiUE Register should be Successful with DRX
    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA varianti
    ${crnti_list}       Create List
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    wtsrunner.ue_register   id=${ue_idx}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Create File     ${OUTPUT_DIR}/regst.txt     ${output}
#    ${crnti_string}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk '{print $9}'
    ${crnti_string}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk -F 'crnti:' '{print $2}'|cut -d ' ' -f 2
    Append To List  ${crnti_list}   ${crnti_string}
    BuiltIn.Log     ${crnti_string}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
    wtsrunner.set_pdu_param     ue=${ue_idx}    pdu=${pdu_id}    trf_type=internal
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_idx}    nwslice=${nw_id}    gw=${ue_idx}
    ${output}   Read WTS Output Until Pattern Matches    ${Initial_context_setup_pattern}    ${Timeout_SA}
    ${output1}         Get Lines Matching Regexp    ${output}    drx-onDurationTimer    partial_match=${TRUE}
    Run Keyword and continue on Failure    should contain   ${output1}   ms10
    ${output1}         Get Lines Matching Regexp    ${output}    drx-InactivityTimer    partial_match=${TRUE}
    Run Keyword and continue on Failure    should contain   ${output1}   ms80
    ${output1}         Get Lines Matching Regexp    ${output}    drx-RetransmissionTimerDL    partial_match=${TRUE}
    Run Keyword and continue on Failure    should contain   ${output1}   sl16
    ${output1}         Get Lines Matching Regexp    ${output}    drx-RetransmissionTimerUL    partial_match=${TRUE}
    Run Keyword and continue on Failure    should contain   ${output1}   sl16
    ${output1}         Get Lines Matching Regexp    ${output}    drx-LongCycleStartOffset     partial_match=${TRUE}
    Run Keyword and continue on Failure    should contain   ${output1}   ms40
    Log to Console     ue=${ue_idx} with crnti=${crnti_string} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    BuiltIn.Log        ue=${ue_idx} with crnti=${crnti_string} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    END
    Log to Console             multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                CRntilist:${crnti_list}
    [Return]      ${crnti_list}
