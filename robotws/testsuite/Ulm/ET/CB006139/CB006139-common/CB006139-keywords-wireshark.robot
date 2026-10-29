*** Settings ***
Documentation   This is a keyword file for CB006139 part wireshark
...             Team: 'MN RAN RD VRF ULM 2'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Variables ***

${WIRESHARK_RUNNING}     false


${bufferMonitoring_activate_DL}   nokiaf1ap.BufferMonitoring == 0
${privatMsg_BufferCriterionNotif_BufferCriterion_downlink}  nokiaf1ap.NokiaBufferCriterion == 0

${UeContextModReq}                (nokiaf1ap.procedureCode == 7)
${bandCombinationIndex_1_3_4}     (nr-rrc.bandCombinationIndex == 1) && (nr-rrc.bandCombinationIndex == 3) && (nr-rrc.bandCombinationIndex == 4)
${bandCombinationIndex_1_3}       (nr-rrc.bandCombinationIndex == 1) && (nr-rrc.bandCombinationIndex == 3)

${UeContextModResp}               (nokiaf1ap.procedureCode == 7) && (nokiaf1ap.F1AP_PDU == 1)
${selectedBandCombinationIndex_0000}   (nokiaf1ap.SelectedBandCombinationIndex == 00:00)
${selectedBandCombinationIndex_0002}   (nokiaf1ap.SelectedBandCombinationIndex == 00:02)
${SCell-FailedtoSetupMod-List}    (nokiaf1ap.SCell_FailedtoSetupMod_List == 1)
${cause_plmn_not_served}          (nokiaf1ap.radioNetwork == 17)

# CB006139_AA_B7
${onshot_scell1}                  (nokiaf1ap.sCellIndex == 1) && (nokiaf1ap.nRCellIdentity == 00:00:04:00:20)
${onshot_scell2}                  (nokiaf1ap.sCellIndex == 2) && (nokiaf1ap.nRCellIdentity == 00:00:04:00:30)
${onshot_scell3}                  (nokiaf1ap.sCellIndex == 3) && (nokiaf1ap.nRCellIdentity == 00:00:04:00:40)
${onshot_scell4}                  (nokiaf1ap.sCellIndex == 4) && (nokiaf1ap.nRCellIdentity == 00:00:04:00:50)

${Scell3_rel_bad_rlq}              (nokiaf1ap.sCellIndex == 3) && (nokiaf1ap.sCellInactiveReason == 2)
${selectedbandCombinationIndex_4_5}  (nr-rrc.bandCombinationIndex == 4) && (nr-rrc.bandCombinationIndex == 5)
${UeContextModFailure}             (nokiaf1ap.F1AP_PDU == 2) && (nokiaf1ap.radioNetwork == 32)

${Scell2_rel_bad_rlq}              (nokiaf1ap.sCellIndex == 2) && (nokiaf1ap.sCellInactiveReason == 2)
${Scell2_rel_Pci55_activated}      (nokiaf1ap.F1AP_PDU == 1) && (nr-rrc.sCellIndex == 2) && (nr-rrc.physCellId == 55)
${bandCombinationIndex_4_5_6}      (nr-rrc.bandCombinationIndex == 4) && (nr-rrc.bandCombinationIndex == 5) && (nr-rrc.bandCombinationIndex == 6)
${selectedBandCombinationIndex_0005}  (nokiaf1ap.SelectedBandCombinationIndex == 00:05)


*** Keywords ***


Start Wireshark Trace
    [Documentation]    [PRIVATE]    start wireshark trace
    ...       :Autor: Sylvia Schneider
    tcpdump.Start TCPDump On TestPc
    ...  options=-i any sctp or icmp
    ...  collector=dump_testpc
    Sleep     1s
    Set Suite Variable      ${WIRESHARK_RUNNING}    true


Stop Wireshark Trace
    [Documentation]    [PRIVATE]    stop wireshark trace
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${wireshark_store}=${resultDir}/wireshark.pcap
    IF    '${WIRESHARK_RUNNING}'=='false'   RETURN
    Sleep     2s
    ${tcpdump_file}    tcpdump.Stop TCPDump On TestPc
    ...  collector=dump_testpc
    ...  target_dir=${resultDir}
    Sleep     2s
    Move File    ${tcpdump_file}    ${wireshark_store}
    Set Suite Variable      ${WIRESHARK_RUNNING}    false


Stop Wireshark Trace For Setup
    [Documentation]    [PRIVATE]    stop wireshark trace for setup
    ...       :Autor: Sylvia Schneider
    Stop Wireshark Trace            wireshark_store=${resultDir}/wireshark_startTL.pcap


Start TCE Trace eth3 sctp tcp
    [Documentation]    [PRIVATE]    start TCE trace eth3 sctp tcp
    ...       :Autor: Sylvia Schneider
    Log To Console    TCE trace started
    tshark.Start Tshark For Trace Session
    ...   interface=eth3
    ...   trace_port=${port_trace}
    ...   collector=tce_trace
    Sleep    1s   reason=wait for trace ready


Stop TCE Trace eth3 sctp tcp
    [Documentation]    [PRIVATE]    stop TCE trace eth3 sctp tcp
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${save_dir}
    Log To Console    TCE trace stopped
    Sleep    10s   reason=wait for all data collected
    tshark.Stop Tshark On Test PC
    ...   collector=tce_trace
    ...   target_dir=${save_dir}


Verify Wireshark CB006139 t1
    [Documentation]    [PRIVATE]    Verify Wireshark for AA_ET_TC02_B2_Buffer_based_step_wise_NR_FR1_SCell_addition_feature_deactivation
    ...       :Autor: Sylvia Schneider
    Log To Console    \nwireshark verification for CB006139_AA_ET_TC02_B2_Buffer_based_step_wise_NR_FR1_SCell_addition_feature_deactivation
    FOR   ${step}  ${action}                  ${path}                                 ${no_expected_msgs}   IN
    ...   1        activate_DL present        TCE_DL_buffer_monitoring_activated      1
    ...   2        activate_DL not present    TCE_DL_buffer_monitoring_deactivated    0
       Log To Console    verify step${step}: bufferMonitoring, ${action}
       ${TCE_dir}  Set Variable   ${resultDir}/${path}/tce_trace/tce_trace.pcap
       ${msg}     Run     tshark -r ${TCE_dir} -Y "${bufferMonitoring_activate_DL}" | wc -l
       Run Keyword And Continue On Failure   Should Be True    ${msg}==${no_expected_msgs}
       ...     Wrong number of "bufferMonitoring, ${action}" messages
    END


Verify Wireshark CB006139 t2
    [Documentation]    [PRIVATE]    Verify Wireshark for AA_ET_TC01_B1_ALT1_Buffer_based_step_wise_NR_FR1_SCell_addition_feature_activation
    ...       :Autor: Sylvia Schneider
    Log To Console    \nwireshark verification for CB006139_AA_ET_TC01_B1_ALT1_Buffer_based_step_wise_NR_FR1_SCell_addition_feature_activation
    ${TCE_dir}  Set Variable   ${resultDir}/TCE/tce_trace/tce_trace.pcap
    FOR   ${message}                          ${filter}       IN
    ...   bufferMonitoring, activate-dl       ${bufferMonitoring_activate_DL}
    ...   BufferCriterion_downlink            ${privatMsg_BufferCriterionNotif_BufferCriterion_downlink}
       Log To Console    verify 1 message present "${message}"
       ${msg}     Run     tshark -r ${TCE_dir} -Y "${filter}" | wc -l
       Run Keyword And Continue On Failure   Should Be True    ${msg}==1   Wrong number of "${message}" messages
   END


Verify Wireshark CB006139 t3
    [Documentation]    [PRIVATE]    Verify Wireshark for AA_ET_TC14_B12_Step_wise_SCell_Addition_with_FS_2CC_UL_chosen_over_FS_1CC_UL
    ...       :Autor: Sylvia Schneider
    Log To Console    \nwireshark verification for 1st measurement period
    ${TCE_dir}  Set Variable   ${resultDir}/TCE_part1/tce_trace/tce_trace.pcap
    FOR   ${message}                          ${filter}       IN
    ...   bufferMonitoring, activate-dl       ${bufferMonitoring_activate_DL}
    ...   BufferCriterion_downlink            ${privatMsg_BufferCriterionNotif_BufferCriterion_downlink}
       Log To Console    verify 2 messages present "${message}"
       ${msg}     Run     tshark -r ${TCE_dir} -Y "${filter}" | wc -l
       Run Keyword And Continue On Failure   Should Be True    ${msg}==2   Wrong number of "${message}" messages
    END

    Log To Console    verify 1 UEContextModificationRequest message present with
    Log To Console    -- bandCombinationIndex 1 and 3 and 4
    Log To Console    -- sCellIndex 1
    ${filter}  Set Variable  ${UeContextModReq} && ${bandCombinationIndex_1_3_4} && (nokiaf1ap.sCellIndex == 1)
    ${msg}     Run     tshark -r ${TCE_dir} -Y "${filter}" | wc -l
    Run Keyword And Continue On Failure   Should Be True    ${msg}==1   Wrong number of UEContextModificationRequest messages

    Log To Console    verify 1 UEContextModificationRequest message present with
    Log To Console    -- bandCombinationIndex 1 and 3
    Log To Console    -- sCellIndex 3
    ${filter}  Set Variable  ${UeContextModReq} && ${bandCombinationIndex_1_3} && (nokiaf1ap.sCellIndex == 3)
    ${msg}     Run     tshark -r ${TCE_dir} -Y "${filter}" | wc -l
    Run Keyword And Continue On Failure   Should Be True    ${msg}==1   Wrong number of UEContextModificationRequest messages

    Log To Console    verify 1 UEContextModificationResponse message present with
    Log To Console    -- SelectedBandCombinationIndex 0000
    Log To Console    -- SCell-FailedtoSetupMod-List
    Log To Console    -- cause plmn-not-served-by-the-gNB-CU
    ${filter}  Set Variable  ${UeContextModResp} && ${selectedBandCombinationIndex_0000} && ${SCell-FailedtoSetupMod-List} && ${cause_plmn_not_served}
    ${msg}     Run     tshark -r ${TCE_dir} -Y "${filter}" | wc -l
    Run Keyword And Continue On Failure   Should Be True    ${msg}==1   Wrong number of UEContextModificationResponse messages

    Log To Console    \nwireshark verification for 2nd measurement period
    ${TCE_dir}  Set Variable   ${resultDir}/TCE_part2/tce_trace/tce_trace.pcap

    FOR   ${message}                          ${filter}       IN
    ...   bufferMonitoring, activate-dl       ${bufferMonitoring_activate_DL}
    ...   BufferCriterion_downlink            ${privatMsg_BufferCriterionNotif_BufferCriterion_downlink}
       Log To Console    verify 1 message present "${message}"
       ${msg}     Run     tshark -r ${TCE_dir} -Y "${filter}" | wc -l
       Run Keyword And Continue On Failure   Should Be True    ${msg}==1   Wrong number of "${message}" messages
    END

    Log To Console    verify 1 UEContextModificationRequest message present with
    Log To Console    -- bandCombinationIndex 1 and 3
    ${msg}     Run     tshark -r ${TCE_dir} -Y "${UeContextModReq} && ${bandCombinationIndex_1_3}" | wc -l
    Run Keyword And Continue On Failure   Should Be True    ${msg}==1   Wrong number of UEContextModificationRequest messages

    Log To Console    verify 1 UEContextModificationResponse message present with
    Log To Console    -- SelectedBandCombinationIndex 0002
    ${filter}  Set Variable  ${UeContextModResp} && ${selectedBandCombinationIndex_0002}
    ${msg}     Run     tshark -r ${TCE_dir} -Y "${filter}" | wc -l
    Run Keyword And Continue On Failure   Should Be True    ${msg}==1   Wrong number of UEContextModificationResponse messages


Verify Wireshark CB006139 t6
    [Documentation]    [PRIVATE]    Verify Wireshark for AA_ET_TC06_B7_SCell_removed_from_SCell_Failed_to_Setup_List_after_SCell_Release
    ...       :Autor: Yasir Mehmood
    Log To Console    \nwireshark verification for buffer monitoring and buffer criterion after PDU session setup and increase traffic
    ${TCE_dir}  Set Variable   ${resultDir}/oneShot_SCell_addition/tce_trace/tce_trace.pcap
    FOR   ${message}                          ${filter}       IN
    ...   bufferMonitoring, activate-dl       ${bufferMonitoring_activate_DL}
    ...   BufferCriterion_downlink            ${privatMsg_BufferCriterionNotif_BufferCriterion_downlink}
       Log To Console    verify 2 messages present "${message}"
       ${msg}     Run     tshark -r ${TCE_dir} -Y "${filter}" | wc -l
       Run Keyword And Continue On Failure   Should Be True    ${msg}==2   Wrong number of "${message}" messages
    END

    Log To Console    verify 1 UEContextModificationRequest message present with
    Log To Console    -- sCellIndex 1,2,3,4 to be added
    ${filter}  Set Variable  ${UeContextModReq} && ${onshot_scell1} && ${onshot_scell2} && ${onshot_scell3} && ${onshot_scell4}
    ${msg}     Run     tshark -r ${TCE_dir} -Y "${filter}" | wc -l
    Run Keyword And Continue On Failure   Should Be True    ${msg}==1   Wrong number of UEContextModificationRequst messages

    Log To Console    \nwireshark verification for UeContextModFailure after release of scell3 and due to buffer criterion
    ${TCE_dir}  Set Variable   ${resultDir}/SCell3_Rel_and_UeContextModFail/tce_trace/tce_trace.pcap

    Log To Console    verify 1 UEContextModificationRequest message present with
    Log To Console    -- SCell-ToBeRemove-Item and one shot cell3 identity
    ${filter}  Set Variable  ${UeContextModReq} && (nokiaf1ap.id == 51) && (nokiaf1ap.nRCellIdentity == 00:00:04:00:40)
    ${msg}     Run     tshark -r ${TCE_dir} -Y "${filter}" | wc -l
    Run Keyword And Continue On Failure   Should Be True    ${msg}==1   Wrong number of UEContextModificationRequest messages
    Log To Console    verify 1 message (UEContextModificationRequest or SCellStatusNotification) contains
    Log To Console    -- sCellIndex 3 to be released due to bad RLQ
    ${filter}  Set Variable  ${Scell3_rel_bad_rlq}
    ${msg}     Run     tshark -r ${TCE_dir} -Y "${filter}" | wc -l
    Run Keyword And Continue On Failure   Should Be True    ${msg}==1   Wrong number of messages

    Log To Console    verify 1 UEContextModificationResponse message present with
    Log To Console    -- released sCellIndex 3
    Log To Console    -- resultant, SelectedBandCombinationIndex 0002
    ${filter}  Set Variable  ${UeContextModResp} && (nr-rrc.SCellIndex == 3) && ${selectedBandCombinationIndex_0002}
    ${msg}     Run     tshark -r ${TCE_dir} -Y "${filter}" | wc -l
    Run Keyword And Continue On Failure   Should Be True    ${msg}==1   Wrong number of UEContextModificationResponse messages

    Log To Console    verify 1 UEContextModificationrequest message present with
    Log To Console    -- proposed bandCombinationIndex 4 and 5
    Log To Console    -- sCellIndex 3 (PCI: 55) to addModList
    ${filter}  Set Variable  ${UeContextModReq} && ${selectedbandCombinationIndex_4_5} && (nokiaf1ap.sCellIndex == 3)
    ${msg}     Run     tshark -r ${TCE_dir} -Y "${filter}" | wc -l
    Run Keyword And Continue On Failure   Should Be True    ${msg}==1   Wrong number of UEContextModificationRequest messages

    Log To Console    verify 1 UEContextModificationFailure message present with
    Log To Console    --radioNetwork cause insufficient-ue-capabilities
    ${msg}     Run     tshark -r ${TCE_dir} -Y "${UeContextModFailure}" | wc -l
    Run Keyword And Continue On Failure   Should Be True    ${msg}==1   Wrong number of UEContextModificationFailure messages

    Log To Console    \nwireshark verification after release of scell2 and change of BC from BC2 to BC5
    ${TCE_dir}  Set Variable   ${resultDir}/SCell2_Rel_PC55_BC5_Select/tce_trace/tce_trace.pcap

    Log To Console    verify 1 UEContextModificationRequest message present with ScellStatusNotification
    Log To Console    -- sCellIndex 2 to be released due to bad RLQ
    ${filter}  Set Variable  (nokiaf1ap.procedureCode == 200) && ${Scell2_rel_bad_rlq}
    ${msg}     Run     tshark -r ${TCE_dir} -Y "${filter}" | wc -l
    Run Keyword And Continue On Failure   Should Be True    ${msg}==1   Wrong number of UEContextModificationRequest messages

    Log To Console    verify 1 UEContextModificationResponse message present with released sCellIndex 2
    Log To Console    -- SelectedBandCombinationIndex 0002
    ${filter}  Set Variable  ${UeContextModResp} && (nr-rrc.SCellIndex == 2) && ${selectedBandCombinationIndex_0002}
    ${msg}     Run     tshark -r ${TCE_dir} -Y "${filter}" | wc -l
    Run Keyword And Continue On Failure   Should Be True    ${msg}==1   Wrong number of UEContextModificationResponse messages

    Log To Console    verify 1 UEContextModificationReq after buffer criterion triggered
    Log To Console    -- scell to activate is pci: 55
    ${filter}  Set Variable  ${UeContextModReq} && ${bandCombinationIndex_4_5_6}
    ${msg}     Run     tshark -r ${TCE_dir} -Y "${filter}" | wc -l
    Run Keyword And Continue On Failure   Should Be True    ${msg}==1   Wrong number of UEContextModificationResponse messages

    Log To Console    verify 1 UEContextModificationResponse after buffer criterion triggered
    ${msg}     Run     tshark -r ${TCE_dir} -Y "${selectedBandCombinationIndex_0005}" | wc -l
    Run Keyword And Continue On Failure   Should Be True    ${msg}==1   Wrong number of UEContextModificationResponse messages


Verify Wireshark CB006139 DA_B3
    [Documentation]    [PRIVATE]    Verify Wireshark for DA_ET_TC03_B3_StepWise_SCell_Addition_with_CSI_RS_downgrade_in_existing_SCell
    ...       :Autor: Sylvia Schneider
    Log To Console    \nwireshark verification for 1st measurement period
    ${TCE_dir}  Set Variable   ${resultDir}/TCE/tce_trace/tce_trace.pcap
    FOR   ${message}                          ${filter}       IN
    ...   bufferMonitoring, activate-dl       ${bufferMonitoring_activate_DL}
    ...   BufferCriterion_downlink            ${privatMsg_BufferCriterionNotif_BufferCriterion_downlink}
       Log To Console    verify 1 message present "${message}"
       ${msg}     Run     tshark -r ${TCE_dir} -Y "${filter}" | wc -l
       Run Keyword And Continue On Failure   Should Be True    ${msg}==1   Wrong number of "${message}" messages
    END


Verify Wireshark CB006139 DA_B12
    [Documentation]    [PRIVATE]    Verify Wireshark for DA_ET_TC09_B12_StepWise_SCell_Addition_DL_UL_SCell_with_UL_Tx_Switching_Option_1
    ...       :Autor: Sylvia Schneider
    Log To Console    \nwireshark verification
    ${TCE_dir}  Set Variable   ${resultDir}/TCE/tce_trace/tce_trace.pcap
    FOR   ${message}                          ${filter}       IN
    ...   bufferMonitoring, activate-dl       ${bufferMonitoring_activate_DL}
    ...   BufferCriterion_downlink            ${privatMsg_BufferCriterionNotif_BufferCriterion_downlink}
       Log To Console    verify 1 message present "${message}"
       ${msg}     Run     tshark -r ${TCE_dir} -Y "${filter}" | wc -l
       Run Keyword And Continue On Failure   Should Be True    ${msg}==1   Wrong number of "${message}" messages
    END


Verify Wireshark CB006139 DA_B1
    [Documentation]    [PRIVATE]    Verify Wireshark for StepWise_SCell_Addition_accompanied_with_DL_maximum_MIMO_layer_change_in_existing_SCell
    ...       :Autor: Sylvia Schneider
    Log To Console    \nwireshark verification
    ${TCE_dir}  Set Variable   ${resultDir}/TCE/tce_trace/tce_trace.pcap
    FOR   ${message}                          ${filter}       IN
    ...   bufferMonitoring, activate-dl       ${bufferMonitoring_activate_DL}
    ...   BufferCriterion_downlink            ${privatMsg_BufferCriterionNotif_BufferCriterion_downlink}
       Log To Console    verify 4 message present "${message}"
       ${msg}     Run     tshark -r ${TCE_dir} -Y "${filter}" | wc -l
       Run Keyword And Continue On Failure   Should Be True    ${msg}==4   Wrong number of "${message}" messages
    END
