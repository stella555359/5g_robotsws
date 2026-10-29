*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation    :copyright: Nokia

Resource    testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource    ../keywords/logging.robot
Resource    taf/rfrl/common_resources/robot/libraries_instances.robot
Resource    ../keywords/tshark_verifying.robot
Resource    ../5GC001167/feature_keywords.robot

Library     taf.ul.ettf.logging
Library     taf.ul.ettf.retry_context
Library     taf.ul.ettf.setups

Variables    ../resources/custom_policy.py

Suite Setup    Run Keywords    Enable C-Plane Debug Logs      with_reboot=${false}
...    AND         With Swconfig Flags        flags=@{SWCONFIG_FLAGS_LIST}

Test Setup    With Retry Context    2
...                Trigger Site Reset
...    AND         Check Radios Availability
...    AND         Update And Put Iphy Xml         input_filepath=${iphy_xml}
...    AND         With Gnb Configuration          commissioning=${scfc}
...    AND         With Simulator Configuration    config=${CURDIR}/config/basic_n71_n66_n41_l1by.cfg

*** Variables ***
${LOGGING_POLICY}=          BASIC_POLICY
${iphy_xml}=                ${CURDIR}/config/iphy_2640_AA.B4g.xml
${scfc}=                    scfc_AA_B4g.xml
${F1AP_SCELL_TO_BE_SETUP_MOD_LIST}=    f1ap.SCell_ToBeSetupMod_List == 2
${F1AP_SCELL_TO_ADD_MOD_LIST}=    nr-rrc.sCellToAddModList == 2 && nr-rrc.physCellId == 51 && nr-rrc.physCellId == 52
${F1AP_RRC_RECONFIGURATION}=    f1ap.DLRRCMessageTransfer_element
@{SWCONFIG_FLAGS_LIST}=       ${rdMergedMeasGapSetupAndDrxRelease}

*** Test Cases ***
5GC002640_AA_B4g_Online_Parameter_Change_in_FDD_FDD_TDD_Configuration
    Attach UE With PDU Session Setup    ue_id=1    pdu_id=1    gw_id=1
    Activate Feature 5GC002640 And Verify Ue Is Not Reconfigured
    Deregister Ue    ue_id=1
    Attach UE With PDU Session Setup And Verify 3CC CA Configured    ue_id=1    pdu_id=1    gw_id=1
    Deactivate Feature 5GC002640 And Verify Ue Is Not Reconfigured
    Deregister Ue    ue_id=1
    Attach UE With PDU Session Setup And Verify 3CC CA Not Configured    ue_id=1

*** Keywords ***
Activate Feature 5GC002640
    Find Scfc and Send Delta Commissioning    scfc_filename=delta_feature_activation.json

Deactivate Feature 5GC002640
    Find Scfc and Send Delta Commissioning    scfc_filename=delta_feature_deactivation.json

Activate Feature 5GC002640 And Verify Ue Is Not Reconfigured
    Start Tcpdump On Remote Interface
    ...    alias=feature_activation    log_filename_prefix=feature_activation    log_dirpath=${OUTPUT_DIR}/tshark
    Activate Feature 5GC002640
    Verify Tshark For No Messages
    ...    alias=feature_activation
    ...    packet_filter=${F1AP_RRC_RECONFIGURATION}
    ...    pcap_file_path=${OUTPUT_DIR}/tshark/feature_activation.pcap

Deactivate Feature 5GC002640 And Verify Ue Is Not Reconfigured
    Start Tcpdump On Remote Interface
    ...    alias=feature_deactivation    log_filename_prefix=feature_deactivation    log_dirpath=${OUTPUT_DIR}/tshark
    Deactivate Feature 5GC002640
    Verify Tshark For No Messages
    ...    alias=feature_deactivation
    ...    packet_filter=${F1AP_RRC_RECONFIGURATION}
    ...    pcap_file_path=${OUTPUT_DIR}/tshark/feature_deactivation.pcap

Attach UE With PDU Session Setup And Verify 3CC CA Not Configured
    [Arguments]     ${ue_id}    ${pdu_id}=1    ${gw_id}=1
    Start Tcpdump On Remote Interface
    ...    alias=attach_3CC_disabled    log_filename_prefix=attach_3CC_disabled    log_dirpath=${OUTPUT_DIR}/tshark
    Attach UE With PDU Session Setup          ue_id=${ue_id}    pdu_id=${pdu_id}         gw_id=${gw_id}
    Verify Tshark For No Messages
    ...    alias=attach_3CC_disabled
    ...    packet_filter=${F1AP_SCELL_TO_BE_SETUP_MOD_LIST}
    ...    pcap_file_path=${OUTPUT_DIR}/tshark/attach_3CC_disabled.pcap

Attach UE With PDU Session Setup
    [Arguments]     ${ue_id}    ${pdu_id}    ${gw_id}
    Set Internal Traffic Type To UEs    ue_id=${ue_id}
    Attach Ue                           ue_id=${ue_id}
    Establish Pdu Session               ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}    nwslice=1

Verify Successful 3CC SCell Addition
    Verify Tcpdump Log      packet_filter=${F1AP_SCELL_TO_BE_SETUP_MOD_LIST}
    Verify Tcpdump Log      packet_filter=${F1AP_SCELL_TO_ADD_MOD_LIST}    number_of_messages=3

Attach UE With PDU Session Setup And Verify 3CC CA Configured
    [Arguments]     ${ue_id}    ${pdu_id}=1    ${gw_id}=1
    Start Tcpdump On Remote Interface
    ...    alias=attach_3CC_enabled    log_filename_prefix=attach_3CC_enabled    log_dirpath=${OUTPUT_DIR}/tshark
    Attach UE With PDU Session Setup          ue_id=${ue_id}    pdu_id=${pdu_id}         gw_id=${gw_id}
    Verify Tshark
    ...    alias=attach_3CC_enabled
    ...    packet_filter=${F1AP_SCELL_TO_ADD_MOD_LIST}
    ...    pass_criteria= ==3
    ...    pcap_file_path=${OUTPUT_DIR}/tshark/attach_3CC_enabled.pcap
    Verify Tshark For Single Message
    ...    alias=attach_3CC_enabled
    ...    packet_filter=${F1AP_SCELL_TO_BE_SETUP_MOD_LIST}
    ...    pcap_file_path=${OUTPUT_DIR}/tshark/attach_3CC_enabled.pcap

