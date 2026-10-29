*** Settings ***
Force Tags    CONFIGURED    CRT    RAN_5G    SBTS00    CLOUD_5G_I_[MP][MP]_AP_[LOOO]

Documentation   :copyright: Nokia
...             :authors: Edyta Rudnik
...             :contact: edyta.rudnik@nokia.com

Resource    ../resources/feature_keywords.robot
Resource    ../../resources/testing_env.robot
Resource    ../../keywords/traffic.robot
Resource    ../../keywords/keywords.robot

Library        taf.ul.ettf.setups
Library        ../resources/KeywordsCB008490.py
Library        ta5g_pm_counters
Library        ta5g_ue_measurements
Library        ../resources/multignb_variables.py
Library        ../resources/syslog_collector.py
Library        ../../../resources/scout_report.py
Variables      ../resources/custom_policy.py

Suite Setup        Run Keywords
...                Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
...    AND         Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}    remote_host=${REMOTE_HOST_1_IP}
...    AND         Enable C-Plane Debug Logs       with_reboot=${false}

*** Variables ***
${LOGGING_POLICY}=              REMOTE_HOST_POLICY
${SCFC_MN_KC}=                  scfc_MN_n78A_n257M_AEQE_8CC.xml
${SCFC_SN_KC}=                  scfc_SN_n78A_n257M_AWEUB_8CC.xml
${IPHY_KC}=                     ${CURDIR}/config/iphy_MN_AEQE_SN_AWEUB_8CC.xml
${cfg_KC}=                      ${CURDIR}/config/cfg_n78A_n257M_8CC_9UEs.cfg
${SCFC_MN_KE}=                  scfc_MN_n77A_n257M_AEQE_8CC.xml
${SCFC_SN_KE}=                  scfc_SN_n77A_n257M_AWEUB_8CC.xml
${IPHY_KE}=                     ${CURDIR}/config/iphy_MN_AHGD_AEQE_SN_AWEUB.xml
${cfg_KE}=                      ${CURDIR}/config/cfg_n77A_n257M_8CC.cfg
${ue1}=                         1
${ue2}=                         2
${ue3}=                         3
${amf_id}=                      1
${pdu_id}=                      1
@{sCellIndexes}=                2    3    4    5    6    7    8    9
@{sCellIndexes_8CC}=            2    3    4    5    6    7    8
@{sCellIndexesWithValue300}=    2    3    4    5
@{sCellIndexesWithValue0}=      6    7    8    9
@{FAULT_IDS_LIST}=              6450    4383

*** Test Cases ***
CB008490_SR_KC_B_102_L3_Counters_related_to_SNodeAddition_procedure_and_the_subsequent_NR-DC_legacy_counters_which_should_be_incremented
   [Setup]     Run Keywords
   ...                Prepare Test Setup For Two Real Gnbs And Enable Tshark Verification    KC
   ...    AND         Setup multigNB devices aliases
   Verify Legacy Pm Counters Were Not Incremented
   Establish And Verify Sucessfull A4 Meas Based Inter-gNB NR-DC With CA For 8UEs With Different Number Of SCells
   Trigger And Verify Unsucessfull A4 Meas Based Inter-gNB NR-DC For UE9
   Trigger PDU Session Release For UEs With Id 1-3
   Trigger Deregistration For UEs With Id 4-6
   Trigger Takeback Caused By RLF For UEs With Id 7-8
   Verify Legacy Pm Counters Values After Test
   Verify Legacy Pm Counters Were Reset After Site Reset
   [Teardown]     Run Keywords       Deregister UE    ue_id=all
               ...    AND         Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
               ...    AND         Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}    remote_host=${REMOTE_HOST_1_IP}
               ...    AND         Add Scout Scf Id To Test Data

CB008490_SR_KE_B1_Inter-gNB_NR-DC_bearer_takeback_while_FR2_CA_established_in_SCG
   [Setup]     Run Keywords
   ...                Prepare Test Setup For Two Real Gnbs And Enable Tshark Verification    KE
   ...    AND         Setup multigNB devices aliases
    Start Collecting Syslog From Gnbs
    Set Internal Traffic Type To UE    ue_id=${ue1}    pdu_id=${pdu_id}
    Set Internal Traffic Type To UE    ue_id=${ue2}    pdu_id=${pdu_id}
    Set Internal Traffic Type To UE    ue_id=${ue3}    pdu_id=${pdu_id}
    Set Scg UL Dist Percent
    Attach Ue    ue_id=${ue1}    enb=2    cell=1
    Establish Pdu Session    ue_id=${ue1}    gw_id=1
    Send Data Traffic    ue_id=${ue1}    inactive_timer=1
    Set expected message flow       ue_id=${ue1}    rrcReconf=1    rrcReconfCompl=1    sNnodeAddPrep=1
    Send Ue Measurement Nr    ue_id=${ue1}    meas_id=1    phycell_id=52    nrsrp_nr=60    event=A4
    Verify expected message flow       ue_id=${ue1}   rrcReconf=1    rrcReconfCompl=1    sNnodeAddPrep=1
    Verify Successful 8CC SCell Addition for UE${ue1}
    Attach Ue    ue_id=${ue2}    enb=2    cell=1
    Establish Pdu Session    ue_id=${ue2}    gw_id=2
    Send Data Traffic    ue_id=${ue2}    inactive_timer=1
    Set expected message flow       ue_id=${ue2}    rrcReconf=1    rrcReconfCompl=1    sNnodeAddPrep=1
    Send Ue Measurement Nr    ue_id=${ue2}    meas_id=1    phycell_id=52    nrsrp_nr=60    event=A4
    Verify expected message flow       ue_id=${ue2}   rrcReconf=1    rrcReconfCompl=1    sNnodeAddPrep=1
    Verify That UE${ue2} has no CA established
    Set Expected Message Flow For Takeback On SN Side
    Set Expected Message Flow For Takeback On MN Side
    Trigger RRC SCGFailureInformation By Random Access Problem
    Verify Expected Message Flow For Takeback On MN Side
    Verify Expected Message Flow For Takeback On SN Side
    Get And Verify Values Of logicalChannelIdentity
    Verify Successful Takeback For UE${ue1}
    Attach Ue    ue_id=${ue3}    enb=2    cell=1
    Establish Pdu Session    ue_id=${ue3}    gw_id=3
    Send Data Traffic    ue_id=${ue3}    inactive_timer=1
    Set expected message flow       ue_id=${ue3}    rrcReconf=1    rrcReconfCompl=1    sNnodeAddPrep=1
    Send Ue Measurement Nr    ue_id=${ue3}    meas_id=1    phycell_id=52    nrsrp_nr=60    event=A4
    Verify expected message flow       ue_id=${ue3}    rrcReconf=1    rrcReconfCompl=1    sNnodeAddPrep=1
    Verify Successful 8CC SCell Addition for UE${ue3}
    Verify Throughput For UE1
    Verify Throughput For UE2 With Cell Index Max In DL Is Eq 1
    Verify Throughput For UE3 With Cell Index Max In DL Is Eq 8
    [Teardown]     Run Keywords       Deregister UE    ue_id=all
                   ...    AND         Stop Collecting Syslog And Download Files
                   ...    AND         Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
                   ...    AND         Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}    remote_host=${REMOTE_HOST_1_IP}
                   ...    AND         Add Scout Scf Id To Test Data
*** Keywords ***
#CB008490_SR_KC_B_102_L3_Counters_related_to_SNodeAddition_procedure_and_the_subsequent_NR-DC_legacy_counters_which_should_be_incremented KWs
Verify Legacy Pm Counters Values After Test
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File    remote_host=${REMOTE_HOST_1_IP}
        Verify Any Counters In File
            ...   M55118C05505      1      RRC_RECONF_ADD1DLSCELL_ATT_SA
            ...   M55118C07004      1      RRC_RECONF_ADD2DLSCELL_ATT_SA
            ...   M55118C09503      1      RRC_RECONF_ADD3DLSCELL_ATT_SA
            ...   M55118C02015      1      RRC_RECONF_ADD4DLSCELL_ATT_SA
            ...   M55118C00001      2      RRC_RECONF_ADD5DLSCELL_ATT_SA
            ...   M55118C00002      1      RRC_RECONF_ADD6DLSCELL_ATT_SA
            ...   M55118C00003      1      RRC_RECONF_ADD7DLSCELL_ATT_SA
            ...   M55118C05506      1      RRC_RECONF_ADD1DLSCELL_SUCC_SA
            ...   M55118C07003      1      RRC_RECONF_ADD2DLSCELL_SUCC_SA
            ...   M55118C09502      1      RRC_RECONF_ADD3DLSCELL_SUCC_SA
            ...   M55118C02014      1      RRC_RECONF_ADD4DLSCELL_SUCC_SA
            ...   M55118C00004      1      RRC_RECONF_ADD5DLSCELL_SUCC_SA
            ...   M55118C00005      1      RRC_RECONF_ADD6DLSCELL_SUCC_SA
            ...   M55118C00006      1      RRC_RECONF_ADD7DLSCELL_SUCC_SA
            ...   M55138C01501      1      GNB_SCELL_1_ADMI_REQ_SA
            ...   M55138C01502      1      GNB_SCELL_1_ADMI_SUCC_SA
            ...   M55138C02501      1      GNB_SCELL_2_ADMI_REQ_SA
            ...   M55138C02502      1      GNB_SCELL_2_ADMI_SUCC_SA
            ...   M55138C03001      1      GNB_SCELL_3_ADMI_REQ_SA
            ...   M55138C03002      1      GNB_SCELL_3_ADMI_SUCC_SA
            ...   M55138C00048      1      GNB_SCELL_4_ADMI_REQ_SA
            ...   M55138C00049      1      GNB_SCELL_4_ADMI_SUCC_SA
            ...   M55138C03504      2      GNB_SCELL_5_ADMI_REQ_SA
            ...   M55138C03507      2      GNB_SCELL_5_ADMI_SUCC_SA
            ...   M55138C03505      1      GNB_SCELL_6_ADMI_REQ_SA
            ...   M55138C03508      1      GNB_SCELL_6_ADMI_SUCC_SA
            ...   M55138C03506      1      GNB_SCELL_7_ADMI_REQ_SA
            ...   M55138C03509      1      GNB_SCELL_7_ADMI_SUCC_SA
            ...   M55138C01503      0      GNB_SCELL_ADMI_UNSUCC_SA
            ...   M55139C01003      1      GNB_DU_SCELL_1_ADMI_REQ_SA
            ...   M55139C01004      1      GNB_DU_SCELL_1_ADMI_SUCC_SA
            ...   M55139C01501      1      GNB_DU_SCELL_2_ADMI_REQ_SA
            ...   M55139C01502      1      GNB_DU_SCELL_2_ADMI_SUCC_SA
            ...   M55139C03001      1      GNB_DU_SCELL_3_ADMI_REQ_SA
            ...   M55139C03002      1      GNB_DU_SCELL_3_ADMI_SUCC_SA
            ...   M55139C00023      1      GNB_DU_SCELL_4_ADMI_REQ_SA
            ...   M55139C00024      1      GNB_DU_SCELL_4_ADMI_SUCC_SA
            ...   M55139C03003      2      GNB_DU_SCELL_5_ADMI_REQ_SA
            ...   M55139C03006      2      GNB_DU_SCELL_5_ADMI_SUCC_SA
            ...   M55139C03004      1      GNB_DU_SCELL_6_ADMI_REQ_SA
            ...   M55139C03007      1      GNB_DU_SCELL_6_ADMI_SUCC_SA
            ...   M55139C03005      1      GNB_DU_SCELL_7_ADMI_REQ_SA
            ...   M55139C03008      1      GNB_DU_SCELL_7_ADMI_SUCC_SA
            ...    local_moid=PLMN-PLMN/MRBTS-3/NRBTS-3/NRCELL-2
            ...    file_path=${pm_counter_file}

    FOR    ${sCellIndex}    IN    @{sCellIndexesWithValue300}
    Verify Last Counters In File
            ...   M55316C01002      >200    	SAMPLES_UL_UE_AMOUNTS
            ...   M55316C01002      <301    	SAMPLES_UL_UE_AMOUNTS
            ...    local_moid=PLMN-PLMN/MRBTS-3/NRBTS-3/NRCELL-${sCellIndex}
            ...    file_path=${pm_counter_file}
    END

    FOR    ${sCellIndex}    IN    @{sCellIndexesWithValue0}
    Verify Any Counters In File
            ...   M55316C01002      0    	SAMPLES_UL_UE_AMOUNTS
            ...    local_moid=PLMN-PLMN/MRBTS-3/NRBTS-3/NRCELL-${sCellIndex}
            ...    file_path=${pm_counter_file}
    END

    FOR    ${sCellIndex}    IN    @{sCellIndexes}
    Verify Last Counters In File
            ...   M55316C01003      >200    SAMPLES_DL_UE_AMOUNTS
            ...   M55118C00054      >200    DEN_1_SEC_SAMPLE
            ...   M55118C01000      >200    SAMPLES_UE_AMOUNTS
            ...   M55316C01003      <301    SAMPLES_DL_UE_AMOUNTS
            ...   M55118C00054      <301    DEN_1_SEC_SAMPLE
            ...   M55118C01000      <301    SAMPLES_UE_AMOUNTS
            ...   local_moid=PLMN-PLMN/MRBTS-3/NRBTS-3/NRCELL-${sCellIndex}
            ...   file_path=${pm_counter_file}
    END

Verify Legacy Pm Counters Were Not Incremented
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File    remote_host=${REMOTE_HOST_1_IP}
    FOR    ${sCellIndex}     IN     @{sCellIndexes}
        Verify Any Counters In File
            ...   M55118C05505      0      RRC_RECONF_ADD1DLSCELL_ATT_SA
            ...   M55118C07004      0      RRC_RECONF_ADD2DLSCELL_ATT_SA
            ...   M55118C09503      0      RRC_RECONF_ADD3DLSCELL_ATT_SA
            ...   M55118C02015      0      RRC_RECONF_ADD4DLSCELL_ATT_SA
            ...   M55118C00001      0      RRC_RECONF_ADD5DLSCELL_ATT_SA
            ...   M55118C00002      0      RRC_RECONF_ADD6DLSCELL_ATT_SA
            ...   M55118C00003      0      RRC_RECONF_ADD7DLSCELL_ATT_SA
            ...   M55118C05506      0      RRC_RECONF_ADD1DLSCELL_SUCC_SA
            ...   M55118C07003      0      RRC_RECONF_ADD2DLSCELL_SUCC_SA
            ...   M55118C09502      0      RRC_RECONF_ADD3DLSCELL_SUCC_SA
            ...   M55118C02014      0      RRC_RECONF_ADD4DLSCELL_SUCC_SA
            ...   M55118C00004      0      RRC_RECONF_ADD5DLSCELL_SUCC_SA
            ...   M55118C00005      0      RRC_RECONF_ADD6DLSCELL_SUCC_SA
            ...   M55118C00006      0      RRC_RECONF_ADD7DLSCELL_SUCC_SA
            ...   M55138C01501      0      GNB_SCELL_1_ADMI_REQ_SA
            ...   M55138C01502      0      GNB_SCELL_1_ADMI_SUCC_SA
            ...   M55138C02501      0      GNB_SCELL_2_ADMI_REQ_SA
            ...   M55138C02502      0      GNB_SCELL_2_ADMI_SUCC_SA
            ...   M55138C03001      0      GNB_SCELL_3_ADMI_REQ_SA
            ...   M55138C03002      0      GNB_SCELL_3_ADMI_SUCC_SA
            ...   M55138C00048      0      GNB_SCELL_4_ADMI_REQ_SA
            ...   M55138C00049      0      GNB_SCELL_4_ADMI_SUCC_SA
            ...   M55138C03504      0      GNB_SCELL_5_ADMI_REQ_SA
            ...   M55138C03507      0      GNB_SCELL_5_ADMI_SUCC_SA
            ...   M55138C03505      0      GNB_SCELL_6_ADMI_REQ_SA
            ...   M55138C03508      0      GNB_SCELL_6_ADMI_SUCC_SA
            ...   M55138C03506      0      GNB_SCELL_7_ADMI_REQ_SA
            ...   M55138C03509      0      GNB_SCELL_7_ADMI_SUCC_SA
            ...   M55138C01503      0      GNB_SCELL_ADMI_UNSUCC_SA
            ...   M55139C01003      0      GNB_DU_SCELL_1_ADMI_REQ_SA
            ...   M55139C01004      0      GNB_DU_SCELL_1_ADMI_SUCC_SA
            ...   M55139C01501      0      GNB_DU_SCELL_2_ADMI_REQ_SA
            ...   M55139C01502      0      GNB_DU_SCELL_2_ADMI_SUCC_SA
            ...   M55139C03001      0      GNB_DU_SCELL_3_ADMI_REQ_SA
            ...   M55139C03002      0      GNB_DU_SCELL_3_ADMI_SUCC_SA
            ...   M55139C00023      0      GNB_DU_SCELL_4_ADMI_REQ_SA
            ...   M55139C00024      0      GNB_DU_SCELL_4_ADMI_SUCC_SA
            ...   M55139C03003      0      GNB_DU_SCELL_5_ADMI_REQ_SA
            ...   M55139C03006      0      GNB_DU_SCELL_5_ADMI_SUCC_SA
            ...   M55139C03004      0      GNB_DU_SCELL_6_ADMI_REQ_SA
            ...   M55139C03007      0      GNB_DU_SCELL_6_ADMI_SUCC_SA
            ...   M55139C03005      0      GNB_DU_SCELL_7_ADMI_REQ_SA
            ...   M55139C03008      0      GNB_DU_SCELL_7_ADMI_SUCC_SA
            ...    local_moid=PLMN-PLMN/MRBTS-3/NRBTS-3/NRCELL-${sCellIndex}
            ...    file_path=${pm_counter_file}
    END

Set Expected Message Flow For A4 Meas Based Unsuccessfull Inter-gNB PSCell Addition For UE${ue_id:\d+}
    Set expected message flow    ue_id=${ue_id}    gnb_id=2    rrcReconf=1    rrcReconfCompl=1    SNodeReleaseRequest=1    XNAPuECtxRelease=1
    ...    rrcRelease=1

Verify Expected Message Flow For A4 Meas Based Unsuccessfull Inter-gNB PSCell Addition For UE${ue_id:\d+}
    Verify expected message flow    ue_id=${ue_id}    gnb_id=2    rrcReconf=1    SNodeReleaseRequest=1    XNAPuECtxRelease=1
    ...    rrcRelease=1
    FAIL FLOW[timeout=30]: UE_9 NR-RRC 1*RRCReconfigurationComplete

Set Expected Message Flow For PDU Session Release For UE${ue_id}
    Set expected message flow    ue_id=${ue_id}    gnb_id=2   pduSessResRel=1    SNodeReleaseRequest=1    XNAPuECtxRelease=1    rrcReconf=1
    ...    rrcReconfCompl=1

Verify Expected Message Flow For PDU Session Release For UE${ue_id}
    Verify expected message flow    ue_id=${ue_id}    gnb_id=2   pduSessResRel=1    SNodeReleaseRequest=1    XNAPuECtxRelease=1    rrcReconf=1
    ...    rrcReconfCompl=1

Verify That UE${ue_id:\d+} Has ${num_of_scells:\d+} Number Of SCells Established
    Verify In RRC RRCReconfiguration_3 Out Of 3 That List sCellToAddModList Has ${num_of_scells} Element/s For UE${ue_id}

Set Expected Message Flow For Deregistration Of UE${ue_id:\d+}
    Set expected message flow    ue_id=${ue_id}    gnb_id=2    NGAPueCtxRelease=1    SNodeReleaseRequest=1    XNAPuECtxRelease=1    rrcRelease=1

Verify Expected Message Flow For Deregistration Of UE${ue_id:\d+}
    Verify expected message flow    ue_id=${ue_id}    gnb_id=2    NGAPueCtxRelease=1    SNodeReleaseRequest=1    XNAPuECtxRelease=1    rrcRelease=1

Set Expected Message Flow For NR-DC Bearer Takeback Triggered By RLF For UE${ue_id:\d+}
     Set expected message flow     ue_id=${ue_id}    SNodeReleaseRequest=1    xnUAddressInd=1    sNStatusTransfer=1     XNAPuECtxRelease=1
     ...    rrcReconf=1    rrcReconfCompl=1    pduSessResModInd=1

Verify Expected Message Flow For NR-DC Bearer Takeback Triggered By RLF For UE${ue_id:\d+}
     Verify expected message flow    ue_id=${ue_id}    SNodeReleaseRequest=1    xnUAddressInd=1    sNStatusTransfer=1     XNAPuECtxRelease=1
     ...    rrcReconf=1    rrcReconfCompl=1    pduSessResModInd=1

Establish And Verify Sucessfull A4 Meas Based Inter-gNB NR-DC With CA For 8UEs With Different Number Of SCells
    FOR    ${id}    IN RANGE    1    9
        Set Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On SN Side For UE${id} GNB3
        Set Expected Message Flow For ICS And A4 Meas Based Inter-gNB PSCell Addition On MN Side For UE${id} GNB2
        Attach Ue    ue_id=${id}
        Establish PDU Session    ue_id=${id}   pdu_id=1    gw_id=${id}
        Send Ue Measurement Nr    ue_id=${id}    meas_id=1    phycell_id=52    nrsrp_nr=60    event=A4
        Verify Expected Message Flow For ICS And A4 Meas Based Inter-gNB PSCell Addition On MN Side For UE${id} GNB2
        Verify Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On SN Side For UE${id} GNB3
    END
    Verify In RRC RRCReconfiguration_3 Out Of 3 That sCellToAddModList Is Not Present For UE1
    FOR    ${id}    IN RANGE    2    9
        Verify That UE${id} Has ${id-1} Number Of SCells Established
    END

Trigger And Verify Unsucessfull A4 Meas Based Inter-gNB NR-DC For UE${ue_id:\d+}
    Attach Ue    ue_id=${ue_id}
    Establish PDU Session    ue_id=${ue_id}   pdu_id=1    gw_id=9
    Waiting For PDU Session Establishment
    Set Expected Message Flow For A4 Meas Based Unsuccessfull Inter-gNB PSCell Addition For UE${ue_id}
    Delay RRC Reconfiguration Complete During NR-DC Setup For UE9
    Send Ue Measurement Nr    ue_id=${ue_id}    meas_id=1    phycell_id=52    nrsrp_nr=60    event=A4
    Verify Expected Message Flow For A4 Meas Based Unsuccessfull Inter-gNB PSCell Addition For UE${ue_id}

Trigger PDU Session Release For UEs With Id 1-3
    FOR    ${id}    IN RANGE    1    4
        Set Expected Message Flow For PDU Session Release For UE${id}
        Release Pdu Session    ue_id=${id}
        Verify Expected Message Flow For PDU Session Release For UE${id}
    END

Trigger Deregistration For UEs With Id 4-6
    FOR    ${id}    IN RANGE    4    7
        Set Expected Message Flow For Deregistration Of UE${id}
        Deregister UE    ue_id=${id}
        Verify Expected Message Flow For Deregistration Of UE${id}
        Verify In NGAP UEContextReleaseCommand_1 Out Of 1 Cause Is Set To "nas: normal-release" For AMF${amf_id}
    END

Trigger Takeback Caused By RLF For UEs With Id 7-8
    FOR    ${id}    IN RANGE    7    9
        Set Expected Message Flow For NR-DC Bearer Takeback Triggered By RLF For UE${id}
        Trigger RRC SCGFailureInformation By Random Access Problem    ue_id=${id}
        Verify Expected Message Flow For NR-DC Bearer Takeback Triggered By RLF For UE${id}
    END

Verify Legacy Pm Counters Were Reset After Site Reset
    Trigger Site Reset    remote_host=None
    Wait For Testline Icmp Echo Replies And Ssh Services
    Trigger Site Reset    remote_host=${REMOTE_HOST_1_IP}
    Wait For Testline Icmp Echo Replies And Ssh Services
    Wait 601s For Counters To Show
    Verify Legacy Pm Counters Were Not Incremented

#CB008490_SR_KE_B1_Inter-gNB_NR-DC_bearer_takeback_while_FR2_CA_established_in_SCG KWs
Verify Successful 8CC SCell Addition for UE${ue_id}
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 That sCellIndex Is Equal To ${sCellIndexes_8CC} In CG-Config For GNB2
    Verify In RRC RRCReconfiguration_1 Out Of 1 That List sCellToAddModList Has 7 Element/s For UE${ue_id}

Verify That UE${ue_id} has no CA established
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 That SCellToAddModList Is Not Present In CG-Config For GNB2
    Verify In RRC RRCReconfiguration_1 Out Of 1 That sCellToAddModList Is Not Present For UE${ue_id}

Get And Verify Values Of logicalChannelIdentity
    ${TB_logicalchannelidentity_rlc_BearerToAddModList}=    Get value of parameter from message
    ...    procedure=RRCReconfiguration     message=RRCReconfiguration    num_of_message=1
    ...    all=1    protocol=NR-RRC    device=UE_1    parameter=logicalChannelIdentity
    ${TB_logicalchannelidentity_rlc_BearerToReleaseList}=    Get value of parameter from message
    ...    procedure=RRCReconfiguration     message=RRCReconfiguration    num_of_message=1
    ...    all=1    protocol=NR-RRC    device=UE_1    parameter=rlc-BearerToReleaseList

    Should Not Be True    ${TB_logicalchannelidentity_rlc_BearerToAddModList}==${TB_logicalchannelidentity_rlc_BearerToReleaseList}

Verify Successful Takeback For UE${ue1}
    Verify In RRC RRCReconfiguration_1 Out Of 1 That radioBearerConfig Contains drb-Identity Set To 4 For UE${ue1}
    Verify In RRC RRCReconfiguration_1 Out Of 1 That pdcp-Config Is Present For UE${ue1}
    Verify In RRC RRCReconfiguration_1 Out Of 1 That masterCellGroup Contains cellGroupId Set To 0 For UE${ue1}
    Verify In RRC RRCReconfiguration_1 Out Of 1 That servedRadioBearer Contains drb-Identity Set To 4 For UE${ue1}
    Verify In RRC RRCReconfiguration_1 Out Of 1 That rlc-BearerToAddModList Contains rlc-Config And mac-LogicalChannelConfig For UE${ue1}
    Verify In RRC RRCReconfiguration_1 Out Of 1 That mrdc-SecondaryCellGroupConfig Has 'release' For UE${ue1}

Verify Throughput For UE1
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue1}    expected_throughput=10Mbps      cell_index_min=0    cell_index_max=0
                                     ...     direction=ul    cell_group=MCG    selection_type=Average    margin=10%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue1}    expected_throughput=100Mbps      cell_index_min=0    cell_index_max=0
                                     ...     direction=dl    cell_group=MCG    selection_type=Average    margin=10%

Verify Throughput For UE${ue_id:\d+} With Cell Index Max In DL Is Eq ${cell_index:\d+}
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=10Kbps
    ...       direction=dl    cell_group=MCG    selection_type=Average    margin=10%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=10Mbps
    ...       direction=ul    cell_group=MCG    selection_type=Average    margin=10%
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=10Mbps      cell_index_min=1    cell_index_max=1
    ...     direction=ul    cell_group=SCG    selection_type=Average    margin=70%
    Verify That Traffic Is Scheduled On All SCells In Group    ue_id=${ue_id}    cell_group=SCG    cell_index_min=1    cell_index_max=${cell_index}
