*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_BLLL_AP_LOO    VARIANT_PRIVATE_SANSA_FS_ECPRI_CMWV_FDD_2CELLS

Documentation    :copyright: Nokia

Resource    taf/rfrl/common_resources/robot/libraries_instances.robot
Resource    ../keywords/tshark_verifying.robot
Variables   testsuite/Wroclaw/RRM/resources/airphone/tshark_filters/ngap.py
Variables   testsuite/Wroclaw/RRM/resources/airphone/tshark_filters/f1ap.py
Resource    feature_keywords.robot

Suite Setup       Prepare Test Environement And Reach Onair
    ...				iphy_xml=${TS_CONFIG_DIR}/ap/iphy_APoABIO.xml
    ...				scfc=full_scfc_3CC_RLF_APoABIO.xml
    ...             egate_cfg=${TS_CONFIG_DIR}/fs_sa_call_fdd_cmwv_3CC_n2_n5_n66.cfg
    ...             cell_number=3
    ...             disablel1bypass=False

Test Setup        Start Default Logging    output_dirpath=${OUTPUT_DIR}

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${TS_CONFIG_DIR}=       ${CURDIR}/config/5GC001167-A3/5GC001167_A3_j_UE_RRC_reestablishment_after_RLF_with_the_same_throughput_3CC_interband
${F1AP_SCELL_TO_BE_SETUP_MOD_LIST}=    f1ap.SCell_ToBeSetupMod_List == 1
${F1AP_SCELL_TO_ADD_MOD_LIST}=         (((nr-rrc.physCellId == 52)) ) && (nr-rrc.pdsch_HARQ_ACK_Codebook == 1)
${UE_CONTEXT_RELEASE_RLF}=    ((f1ap.procedureCode == 6))  && (f1ap.criticality == 1)
${RRC_SETUP_REQUEST}=    ((nr-rrc.c1 == 0)) && (f1ap.id == 128)

*** Test Cases ***
5GC001167_A3_j_UE_RRC_reestablishment_after_RLF_with_the_same_throughput_3CC_interband
    Attach_UE1_With_PDU_Session_Setup
    Verify ICS On NGAP
    Verify Successful Reconfiguration    packet_filter=${F1AP_RECONFIGURE_TO_3CC_SCELLS_B_C}
    Trigger Radio Link Failure
    Verify Successfull Registration To Cell Via RRC Setup Request
    [Teardown]    Run Keywords      Release Pdu Session    ue_id=1    pdu_id=1
        ...            AND          Deregister Ue    ue_id=1


*** Keywords ***
Attach_UE1_With_PDU_Session_Setup
    Set Internal Traffic Type To UEs    ue_id=1
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1    nwslice=1

Trigger Radio Link Failure
    [Arguments]    ${ue_id}=1    ${gnb_id}=2   ${cause}=otherFailure    ${cell_id}=1
    Execute Egate Command     cmd=ue_rrc_reestablish id=${ue_id}  gnb=${gnb_id} cell=${cell_id} cause=${cause}
    Verify Tcpdump Log      packet_filter=${UE_CONTEXT_RELEASE_RLF}

Verify Successfull Registration To Cell Via RRC Setup Request
    Verify Tcpdump Log      packet_filter=${RRC_SETUP_REQUEST}
