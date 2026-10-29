*** Settings ***
Force Tags    CONFIGURED   CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_BOO_AP_LOO

Documentation    :copyright: Nokia
...             :authors: I_MN_RAN_RD_VRF_WRO2_6
...             :contact: I_MN_RAN_RD_VRF_WRO2_6

Resource    ../../../resources/airphone/5G_SW_WRO_Keywords.robot
Resource    ../resources/feature_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T06/resources/keywords.robot
Resource    testsuite/Wroclaw/RRM/resources/airphone/wro_2/keywords/traffic.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T06/resources/Error_finder.robot
Library     ta5g_file_system
Library     ../resources/KeywordsCB008490.py
Library     testsuite/Wroclaw/RRM/resources/scout_report.py

Suite Setup        Run Keywords
...                Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
...    AND         Enable C-Plane Debug Logs       with_reboot=${false}
...    AND         Start Vm Ethernet Interfaces For Simulated gNB2

Suite Teardown    Compress Test Logs

*** Variables ***
${SCFC_EA}=                 scfc_MN_n78A_AEQE_3Slices_VONR.xml
${IPHY_EA}=                 ${CURDIR}/config/iphy_MN_AEQE.xml
${cfg_EA}=                  ${CURDIR}/config/cfg_realMN_n78A_simSN_n257A_3Slices_VONR.cfg
${SCFC_FB}=                 scfc_AWEUB_n257A_realSN.xml
${IPHY_FB}=                 ${CURDIR}/config/iphy_AWEUB_realSN.xml
${cfg_FB}=                  ${CURDIR}/config/cfg_n257A_realSN.cfg
${SCFC_KC}=                 scfc_8490_KC_B101_8CC_realSN.xml
${IPHY_KC}=                 ${CURDIR}/config/iphy_8490_K_B_8CC_realSN.xml
${cfg_KC}=                  ${CURDIR}/config/cfg_8490-K_B_8CC_realSN.cfg
${SCFC_QNN}=                scf_MN_n78A_AEQE.xml
${IPHY_QNN}=                ${CURDIR}/config/iphy_MN_AEQE.xml
${cfg_QNN}=                 ${CURDIR}/config/cfg_realMN_n78A_simSN_n257B.cfg
${delta_unlock_QNN}=        delta_unlock.json
${delta_lock_QNN}=          delta_lock.json
@{FAULT_IDS_LIST}=          6450    4383
${ue1}=                     1
${ue2}=                     2
${amf_id}=                  1
${pdu_id}=                  1
${moid_pscell}=             PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-1
@{sCellIndexes_8CC}=        2    3    4    5    6    7    8
@{num_of_FR2_cells}=        1    2    3    4    5    6    7    8
@{COUNTERS_NOT_TO_INCREMENT_BEFORE_TEST_AND_AFTER_RESET}=    M55116C00057    M55116C00058    M55156C00030    M55138C00040
@{COUNTERS_NOT_TO_INCREMENT_IN_SN_GNB_CELLS}=    M55118C05507    M55118C07001    M55118C09501     M55118C02016    M55118C00013    M55118C00014
...    M55118C05508    M55118C07002    M55118C11009    M55118C07510    M55118C00018    M55118C00019    M55118C04012     M55118C04013
...    M55118C05012    M55118C05013

*** Test Cases ***
CB008490_EA_EC102_Concurrency_handling_of_PDU_and_UE_Release
    [Documentation]    :copyright: Nokia
    ...                :authors: Magdalena Mlynarska
    ...                :contact: magdalena.mlynarska@nokia.com

    [Setup]   Run Keywords    Start Vm Ethernet Interfaces For Simulated gNB2
    ...    AND         Prepare Test Setup For One Real Gnb And Enable Tshark Verification    EA
    ...    AND         Setup devices aliases for realMN simSN
    ...    AND         Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...    AND         Reach Onair    lua_cfg=${cfg_EA}
    ...    AND         Enforce Protocol    nr-rrc

    Attach Ue    ue_id=${ue1}    enb=2    cell=1
    Set Scg UL Dist Percent
    Establish Pdu Session With Traffic    ue_id=${ue1}    pdu_id=1    nwslice=1    gw_id=1      throughput=30Kbps
    Establish Pdu Session With Traffic    ue_id=${ue1}    pdu_id=2    nwslice=2    gw_id=2      throughput=30Kbps
    Set Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On MN Side For UE1 GNB2
    Send Ue Measurement Nr    ue_id=${ue1}    meas_id=1    phycell_id=52    nrsrp_nr=60    event=A4
    Wait 5s For NR-DC Setup
    Verify Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On MN Side For UE1 GNB2
    Get Values From APIDs In SNnodeAddPrep
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue1}    expected_throughput=0.01
                                       ...       direction=dl    cell_group=MCG    selection_type=average    margin=10%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue1}    expected_throughput=0.01      cell_index_min=0    cell_index_max=0
                                       ...     direction=ul    cell_group=MCG    selection_type=average    margin=10%
    Set Expected Message Flow For PDU Session Release And Ue Release On MN Side For UE1 GNB2
    Wait 3s For Prodedure Establish
    Perform Command To Delay Snode Release Request
    Release Pdu Session Without Confirmation    ue_id=${ue1}    pdu_id=1
    Perform Command To Release Ue By AMF
    Verify Expected Message Flow For PDU Session Release And Ue Release On MN Side For UE1 GNB2
    Verify NGAP EA US
    Verify XNAP EA US
    Verify F1AP EA US
    Verify E1AP EA US
    [Teardown]    Run Keywords
    ...                Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
    ...    AND         Find Errors
    ...    AND         Add Scout Scf Id To Test Data
    ...    AND         Teardown Egate And Collect Logs    logs_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...    AND         Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...    AND         Collect Selected Debug Files
    ...                output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...                omit_collectors=sos_report

CB008490_FB_EC102_Lack_of_XnAP_SNodeReleaseConfirm_message
    [Documentation]    Since FB2422 This Test Case covers additionally FC_B202 and FC_B203 User Scenario with counters.
    ...                :copyright: Nokia
    ...                :authors: Magdalena Mlynarska
    ...                :contact: magdalena.mlynarska@nokia.com

    [Setup]            Run Keywords    Start Vm Ethernet Interfaces For Simulated gNB
    ...    AND         Prepare Test Setup For One Real Gnb And Enable Tshark Verification    FB
    ...    AND         Setup devices aliases
    ...    AND         Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...    AND         Reach Onair    lua_cfg=${cfg_FB}
    ...    AND         Enforce Protocol    nr-rrc

    Verify If Counters Were Not Incremented    counter_id_list=@{COUNTERS_NOT_TO_INCREMENT_BEFORE_TEST_AND_AFTER_RESET}    local_moid=${moid_pscell}
    Wait For Next Full Pm Interval
    Attach Ue    ue_id=${ue1}
    Perform Command To Configure Behavior Of AMF During RAN Initiated PDU Session Modification Procedure
    Wait 2s For Environment To Establish
    Prepare Sim gNB
    Wait 2s For Environment To Establish
    Perform Commnad To Configure SMF Parameters
    Establish PDU Session    ue_id=${ue1}    pdu_id=1    nwslice=2    gw_id=1    check_timestamps=${False}
    Perform Commnad To Configure SMF Parameters    qos_id=3
    Establish PDU Session    ue_id=${ue1}    pdu_id=2    nwslice=1   gw_id=2    check_timestamps=${False}
    Wait 2s For Environment To Establish
    Perform Command To Trigger Snode Release Confirm Param
    Set Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On SN Side For UE1 GNB2
    UE Sends A4 Measurement For Inter-gNB NR-DC With Simulated MN GNB    tar_pdu_id=2
    Wait 2s For NRDC To Establish
    Verify Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On SN Side For UE1 GNB2
    Get Values From APIDs In SNnodeAddPrep
    Set Expected Message Flow For SNode Release Interruption Caused By Lack Of SNodeReleaseConfirm Message For UE1 GNB2
    Set Expected Lack Of SNodeReleaseConfirm
    Trigger UPF Sim to send GTP-U Error Indication to gNB
    Verify Expected Lack Of SNodeReleaseConfirm
    Verify Expected Message Flow For SNode Release Interruption Caused By Lack Of SNodeReleaseConfirm Message For UE1 GNB2
    Verify XnAP FB US
    Verify F1AP FB US
    Verify E1AP FB US
    Verify If Counters Were Incremented After Test
    [Teardown]    Run Keywords    Deregister UE    ue_id=all
    ...    AND         Find Errors
    ...    AND         Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
    ...    AND         Add Scout Scf Id To Test Data
    ...    AND         Teardown Egate And Collect Logs    logs_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...    AND         Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...    AND         Collect Selected Debug Files
    ...                output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...                omit_collectors=sos_report

CB008490_SR_KC_B101_Counters_for_number_UEs_with_CA_8CC
    [Documentation]    :copyright: Nokia
    ...                :authors: Edyta Rudnik
    ...                :contact: edyta.rudnik@nokia.com

    [Setup]    Run Keywords    Start Vm Ethernet Interfaces For Simulated gNB
    ...    AND         Prepare Test Setup For One Real Gnb And Enable Tshark Verification    KC
    ...    AND         Setup devices aliases
    ...    AND         Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...    AND         Reach Onair    lua_cfg=${cfg_KC}
    ...    AND         Enforce Protocol    nr-rrc

    Attach Ue    ue_id=${ue1}
    Prepare Sim gNB
    Establish PDU Session    ue_id=${ue1}    pdu_id=1    gw_id=1    check_timestamps=${False}
    Set Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On SN Side For UE1 GNB2
    UE Sends A4 Measurement For Inter-gNB NR-DC With Simulated MN GNB
    Wait 2s For NRDC To Establish
    Verify Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On SN Side For UE1 GNB2
    Verify Successfull 8CC CA in FR2
    Attach Ue    ue_id=${ue2}    enb=3    cell=9
    Establish PDU Session    ue_id=${ue2}    pdu_id=1    gw_id=2    check_timestamps=${False}
    Set Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On SN Side For UE2 GNB2
    UE Sends A4 Measurement For Inter-gNB NR-DC With Simulated MN GNB    ue_id=2    phycell_id=52
    Verify Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On SN Side For UE2 GNB2
    Verify Successfull 8CC CA in FR2
    Wait For Next Full Pm Interval
    ${pm_counter_file_after_test}=    Get Next Unpacked Full Pm Counters File
    Set Suite Variable    ${pm_counter_file_after_test}
    Verify PM Counters In PSCell After Successfull NR-DC With 8CC in FR2
    Verify PM Counters In SCells After Successfull NR-DC With 8CC in FR2
    Verify PM Counters Are Not Incremented In Any SN GNB Cells After Successfull NR-DC With 8CC in FR2
    [Teardown]    Run Keywords
    ...                Deregister UE    ue_id=all
    ...    AND         Find Errors
    ...    AND         Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
    ...    AND         Add Scout Scf Id To Test Data
    ...    AND         Teardown Egate And Collect Logs    logs_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...    AND         Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...    AND         Collect Selected Debug Files
    ...                output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...                omit_collectors=sos_report

*** Keywords ***
#CB008490_EA_EC102_Concurrency_handling_of_PDU_and_UE_Release_(wait_abort_&_process) KWs
Start Vm Ethernet Interfaces For Simulated gNB2
    Start Vm Ethernet Interface    if_name=eth3:GNB2_NG_ADDR    ip_with_mask=10.0.1.6/24
    Start Vm Ethernet Interface    if_name=eth3:GNB2_XN_ADDR    ip_with_mask=10.0.1.7/24

Set Expected Message Flow For PDU Session Release And Ue Release On MN Side For UE1 GNB2
    Set expected message flow     gnb_id=2      pduSessResRel=1        SNodeReleaseRequest=1       XNAPuECtxRelease=1
        ...       NGAPueCtxRelease=1     F1APuECtxRelease=1    bearerCtxRelease=1     rrcRelease=1

Verify Expected Message Flow For PDU Session Release And Ue Release On MN Side For UE1 GNB2
     Verify expected message flow    gnb_id=2      pduSessResRel=1        SNodeReleaseRequest=1       XNAPuECtxRelease=1
        ...       NGAPueCtxRelease=1     F1APuECtxRelease=1    bearerCtxRelease=1     rrcRelease=1

Verify E1AP EA US
    Verify In E1AP BearerContextReleaseCommand_1 Out Of 1 Cause Is Set To "radioNetwork: normal-release" For GNB2

Verify F1AP EA US
   Verify In F1AP UEContextReleaseCommand_1 Out Of 1 Cause Is Set To "radioNetwork: normal-release" For GNB2
   Verify In F1AP UEContextReleaseCommand_1 Out Of 1 That RRCContainer Is Present For GNB2

Verify XNAP EA US
    Verify In XNAP SNodeReleaseRequest_1 Out Of 1 That Cause Has radioNetwork Set To 'normal-release' For GNB2
    Verify In XNAP SNodeReleaseRequest_1 Out Of 1 That pduSessionId Is Set To 1 For GNB2
    Check Values From APIDs In SNodeReleaseRequest

Verify NGAP EA US
    Verify In NGAP PDUSessionResourceReleaseCommand_1 Out Of 1 cause Is Set To "nas: normal-release" For AMF1
    Verify In NGAP UEContextReleaseCommand_1 Out Of 1 Cause Is Set To "nas: normal-release" For AMF1

#CB008490_FB_EC102_Lack_of_XnAP_SNodeReleaseConfirm_message KWs
Set Expected Message Flow For SNode Release Interruption Caused By Lack Of SNodeReleaseConfirm Message For UE1 GNB2
     Set expected message flow    gnb_id=2     bearerCtxRelease=1     uECtxMod=1    bearerCtxModReq=1
     ...     XNAPuECtxRelease=1     F1APuECtxRelease=1

Verify Expected Message Flow For SNode Release Interruption Caused By Lack Of SNodeReleaseConfirm Message For UE1 GNB2
     Verify expected message flow   gnb_id=2    bearerCtxRelease=1    uECtxMod=1    bearerCtxModReq=1
     ...     XNAPuECtxRelease=1    F1APuECtxRelease=1

Set Expected Lack Of SNodeReleaseConfirm
    EXPECT FLOW[timeout=10]: gNB2 XNAP 1*sNGRANnodeinitiatedSNGRANnodeRelease

Verify Expected Lack Of SNodeReleaseConfirm
    Run Keyword And Expect Error    MessageObserverTimeout*    PASS FLOW[timeout=10]: gNB2 XNAP 1*sNGRANnodeinitiatedSNGRANnodeRelease

Verify XnAP FB US
    Check Values From APIDs In SNodeReleaseRequired
    Verify In XNAP SNodeReleaseRequired_1 Out Of 1 That Cause Has transport Set To 'transport-resource-unavailable' For GNB2

Verify F1AP FB US
     Verify In F1AP UEContextModificationRequest_1 Out Of 1 That TransmissionActionIndicator Is Set To 'stop' For gNB2
     Verify In F1AP UEContextReleaseCommand_1 Out Of 1 That Cause Contains transport Set To 'transport-resource-unavailable' For GNB2

Verify E1AP FB US
    Verify In E1AP BearerContextModificationRequired_1 Out Of 1 That Cause Has transport Set To 'transport-resource-unavailable' For GNB2
    Verify In E1AP BearerContextReleaseCommand_1 Out Of 1 That Cause Has transport Set To 'transport-resource-unavailable' For GNB2

Verify If Counters Were Incremented After Test
    ${pm_counter_file_after_test}=     Get Next Unpacked Full Pm Counters File    remote_host=None
    Set Suite Variable    ${pm_counter_file_after_test}
    Verify If M55156C00030 Counter Has Value 1
    Verify If M55116C00057 Counter Has Value 2
    Verify If M55116C00058 Counter Has Value 2
    Verify If M55138C00040 Counter Is In Range Of Given Values


Verify If ${counter_id:\S+} Counter Has Value ${x:\d+}
    Run Keyword If    ('${counter_id}' == 'M55156C00030') or ('${counter_id}' == 'M55116C00057') or ('${counter_id}' == 'M55116C00058')
    ...     Verify If Latest Pm Counter Has Exact Value
            ...    counter_id=${counter_id}
            ...    value=${x}
            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-1
            ...    filepath=${pm_counter_file_after_test}

Verify If M55138C00040 Counter Is In Range Of Given Values
        Verify If Any Pm Counter Is In Range Of Given Values
        ...    counter_id=M55138C00040
        ...    value_lower=1
        ...    value_higher=4
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-1
        ...    filepath=${pm_counter_file_after_test}

#CB008490_SR_KC_B101_Counters_for_number_UEs_with_CA_8CC KWs
Verify Successfull 8CC CA in FR2
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 That sCellIndex Is Equal To ${sCellIndexes_8CC} In CG-Config For GNB2

Verify PM Counters In PSCell After Successfull NR-DC With 8CC in FR2
        Verify If Latest Pm Counter Has Exact Value
        ...    counter_id=M55156C00029
        ...    value=2
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-1
        ...    filepath=${pm_counter_file_after_test}

        Verify If Any Pm Counter Is In Range Of Given Values
        ...    counter_id=M55118C00015
        ...    value_lower=500
        ...    value_higher=601
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-1
        ...    filepath=${pm_counter_file_after_test}

Verify PM Counters In SCells After Successfull NR-DC With 8CC In FR2
    FOR    ${scell_index}    IN    @{sCellIndexes_8CC}
        Verify If Any Pm Counter Is In Range Of Given Values
           ...    counter_id=M55118C00020
           ...    value_lower=500
           ...    value_higher=601
           ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-${scell_index}
           ...    filepath=${pm_counter_file_after_test}
    END

Verify PM Counters Are Not Incremented In Any SN GNB Cells After Successfull NR-DC With 8CC in FR2
    FOR    ${scell_index}    IN    @{num_of_FR2_cells}
        Verify If Latest Pm Counters In Counter Id List Have Exact Value
           ...    counter_id_list=@{COUNTERS_NOT_TO_INCREMENT_IN_SN_GNB_CELLS}
           ...    value=0
           ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-${scell_index}
           ...    filepath=${pm_counter_file_after_test}
    END
