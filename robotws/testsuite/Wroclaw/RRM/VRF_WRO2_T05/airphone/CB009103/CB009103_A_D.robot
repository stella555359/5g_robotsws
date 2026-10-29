*** Settings ***
Force Tags    CLOUD_5G_I_[MP][MP]_AP_[LOOO]    PY311
...           NoResUsage

Documentation   :copyright: Nokia
...             :authors: Dominik Borkowski, Katarzyna Wisniewska
...             :contact: dominik.borkowski@nokia.com, katarzyna.wisniewska@nokia.com
...             :topology: CLOUD_5G_I_[MP][MP]_AP_[LOOO]
...             :variant: VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_GMC

Resource     CB009103_Keywords_And_Variables.robot

Suite Setup        Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs    remote_host=${REMOTE_HOST_1_IP}
...                AND             Get Iphy Xml File    output_filepath=${OUTPUT_DIR}/iphy.xml
...                AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/SN_initial_commissioning.xml    remote_host=${REMOTE_HOST_1_IP}
...                AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/MN_initial_commissioning.xml
...                AND             Update And Put Iphy Xml         input_filepath=${IPHY}
...                AND             Find Scfc And Send Delta Commissioning
...                                scfc_filename=${EXTERNAL_GNB_DELTA_A_B1}    remote_host=${REMOTE_HOST_1_IP}
...                AND             Find Scfc And Send Delta Commissioning
...                                scfc_filename=${PRIME_GNB_DELTA_A_B1}
...                AND             Trigger Site Reset    remote_host=${REMOTE_HOST_1_IP}
...                AND             Reach Onair    lua_cfg=${EGATE_CFG}    remote_hosts=${REMOTE_HOSTS}
...                AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown     Run Keywords    Update And Put Iphy Xml         input_filepath=${OUTPUT_DIR}/iphy.xml
...                AND             Send Full Commissioning
...                                input_filepath=${OUTPUT_DIR}/SN_initial_commissioning.xml   remote_host=${REMOTE_HOST_1_IP}
...                AND             Send Full Commissioning    input_filepath=${OUTPUT_DIR}/MN_initial_commissioning.xml
...                AND             Wait For Testline Icmp Echo Replies And Ssh Services
...                AND             Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${PRIME_GNB_DELTA_A_B1}=       Prime_gNB_delta_A_B1.json
${EXTERNAL_GNB_DELTA_A_B1}=    External_gNB_delta_A_B1.json
${EGATE_CFG}=                  ${CURDIR}/config/egate_config_CB009103_A_B1.cfg
${IPHY}=                       ${CURDIR}/config/iphy_CB009103_A_B1.xml

*** Test Cases ***
CB009103-A_PMO_B1_Counter_update_for_new_intra-SCell_addition_for_a_UE_which_is_already_configured_with_ext-SCells
    [Documentation]
    ...    PCell = pci 50
    ...    internal sCell = pci 52
    ...    external sCells = pci 55, 56
    ...    The test case checks counters for new intra_SCell addition
    ...    For UE which is already configured with two ext_SCells
    ...    miNrCaCu=5min
    ...    miNrNGCC=5min
    ...    miNrCaDuCp=5min
    ...    actBufferBasedSCellAddition=oneShot_stepWise_Dl_Fr1
    ...    sCellActivationMethod=blind
    ...    Req: 5G_PM_2488, 5G_RAN_USR_RRM_28790

    [Setup]    Run Keywords    Start Default Logging And Mark New Test    remote_host=${REMOTE_HOST_1_IP}    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        test_name=${TEST_NAME}
    ...        AND             Lock Cells On Both gNBs

    Attach Ue    ue_id=1
    Establish PDU Session With Traffic    ue_id=1    pdu_id=1    gw_id=1
    Start Traffic To Trigger SCells Addition    ue_id=1    pdu_id=1
    Verify Messages
    Verify PM Counters On Prime GNB And External GNB Sides

    [Teardown]    Run Keywords    Deregister Ue Without Confirmation   ue_id=1
    ...           AND             Unlock Cells On Both gNBs
    ...           AND             Add Scout Scf Id To Test Data
    ...           AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

CB009103_D_EC2_Intra_GNB_DU_RRC_Connection_Reestablishment_Failure_Handling_For_UE_With_Both_Intra_SCell_And_Ext_SCell
    [Documentation]
    ...    PCell = pci 50
    ...    internal sCell = pci 52
    ...    external sCells = pci 55, 56
    ...    The test case checks if gNB is properly handling UE state after timeout for  RRC Reconfiguration during
    ...    RRC Reestablishment procedure. New PCell (pci 51) is located in the same prime-gNB.
    ...    miNrCaCu=5min
    ...    miNrNGCC=5min
    ...    miNrCaDuCp=5min
    ...    actBufferBasedSCellAddition=oneShot_stepWise_Dl_Fr1
    ...    sCellActivationMethod=blind
    ...    Req: 5G_RAN_USR_RRM_29131
    ...    Test case required TOOLS_PROFILE_5G_TTI_NOKIA tag to decode NokiaXn private messages.

    [Setup]    Run Keywords    Start Default Logging And Mark New Test    remote_host=${REMOTE_HOST_1_IP}    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        test_name=${TEST_NAME}
    ...        AND             Lock Cells On Both gNBs

    Attach Ue    ue_id=2
    Establish PDU Session With Traffic    ue_id=2    pdu_id=2    gw_id=2
    Start Traffic To Trigger SCells Addition    ue_id=2    pdu_id=2
    Unlock Single Cell    cell_id=2
    Configure UE To Drop RRC Reconfiguration    ue_id=2
    Initiate UE RRC Reestablishment    ue_id=2    cell=2    pass_regexp=Expired reestablishing state timer
    Verify Tcpdump Log    packet_filter=${RRC_REESTABLISHMENT_REQUEST}
    Verify Ngap Messages    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMMAND}
    Verify Ngap Messages    packet_filter=${NGAP_UE_CONTEXT_RELEASE_REQUEST}
    Verify Ngap Messages    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMPLETE}
    Verify Tcpdump Log    packet_filter=${XNAP_PRIVATE_MESSAGE_IgNBCAReleaseRequest}
    Verify Tcpdump Log    packet_filter=${XNAP_PRIVATE_MESSAGE_IgNBCAReleaseRequest_Acknowledge}

    [Teardown]    Run Keywords    Deregister Ue Without Confirmation   ue_id=2
    ...           AND             Unlock Cells On Both gNBs
    ...           AND             Add Scout Scf Id To Test Data
    ...           AND             Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

