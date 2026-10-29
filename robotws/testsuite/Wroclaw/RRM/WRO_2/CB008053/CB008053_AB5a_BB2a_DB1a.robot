*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
...           CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation    :copyright: Nokia
...              :authors: Izabela Prosniak, Aleksandra Vesely, Blanka Gozdek, Lukasz Klimowicz, Sebastian Sliwakowski
...              :contact: izabela.prosniak@nokia.com, aleksandra.vesely@nokia.com, blanka.gozdek@nokia.com,
...                        lukasz.klimowicz@nokia.com, sebastian.sliwakowski@nokia.com

Resource     testsuite/Wroclaw/RRM/WRO_2/CB008053/CB008053_Keywords_And_Variables.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot


*** Test Cases ***
CB008053-A_B5a_Successful_A2_Measurement_PCell_triggered_PCell_change_to_FDD_SCell

    [Setup]    Run Keywords    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_CB008053.xml
    ...            AND             With Gnb Configuration    commissioning=${scfc_1}
    ...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
    ...            AND             Start Default Logging
    ...            AND             With Simulator Configuration    config=${BASIC_SETUP}

    Add Scout Data Info To Testcase

    Attach UE And Verify Establishing PDU Session   ue_id=${UE_ID}    cell_id=${PCELL_ID}
    ...    gnb_id=${GNB_ID}    pdu_id=${PDU_PCELL_1}    gw_id=${GW_ID}
    Verify A1 Measurement Configuration    ue_id=${UE_ID}
    Trigger A1 Based SCell Addition With 4CC TFTT    ue_id=${UE_ID}    gNB_id=${GNB_ID}
    Verify 4CC TFTT SCell Addition Message Contents    ue_id=${UE_ID}
    Trigger PCell Change    ue_id=${UE_ID}    gNB_id=${GNB_ID}    A2_cmd=${A2_cmd}
    Verify Successful PCell Change And SCells Release    ue_id=${UE_ID}
    Trigger A1 Measurement To Verify CA Successful    ue_id=${UE_ID}    gNB_id=${GNB_ID}
    Verify Successful CA    ue_id=${UE_ID}
    Verify 4CC CA Counters    scell_1=${PCELL_ID}    scell_2=${SCELL_ID_1}    scell_3=${SCELL_ID_2}    pcell=${PCELL_ID_2}
    Release UE    ue_id=${UE_ID}    pdu_id=${PDU_PCELL_1}

    [Teardown]    Run Keywords    Stop Default Logging

CB008053-B_B2a_Interaction_with_SCell_Change

    [Setup]    Run Keywords    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_CB008053.xml
    ...            AND             With Gnb Configuration    commissioning=${scfc_2}
    ...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
    ...            AND             Start Default Logging
    ...            AND             With Simulator Configuration    config=${BASIC_SETUP}

    Add Scout Data Info To Testcase

    Attach UE And Verify Establishing PDU Session    ue_id=${UE_FDD_PCELL_1}    cell_id=${FDD_PCELL_ID}
    ...    gnb_id=${GNB_ID}    pdu_id=${PDU_FDD_PCELL_1}    gw_id=${UE_FDD_PCELL_1}
    Verify Measurements Are Configured At UE    ue_id=${UE_FDD_PCELL_1}    event_type=${A1_FOR_SCELL_ADDITION}
    ...    event_params=${A1_RSRP_50}    frequencies=${FREQUENCIES_A1}
    Trigger A1 Based SCell Addition With 3CC FFF    ue_id=${UE_FDD_PCELL_1}    gNB_id=${GNB_ID}
    Verify 3CC FFF A1 Based SCell Addition Message Contents    ue_id=${UE_FDD_PCELL_1}
    Trigger SCell Change to 4CC FTTT At UE    ue_id=${UE_FDD_PCELL_1}    gNB_id=${GNB_ID}
    Verify 4CC FTTT A1 Based SCell Change Message Contents    ue_id=${UE_FDD_PCELL_1}
    Verify 4CC CA Counters For FDD_PCELL    ${FDD_PCELL_ID}
    Release UE    ue_id=${UE_FDD_PCELL_1}    pdu_id=${PDU_FDD_PCELL_1}

    [Teardown]    Run Keywords    Stop Default Logging

CB008053-D_B1a_Simultaneous_Rx_Tx_Inter_Band_CA_transmission_handling_-_TDD_PCell
    [Setup]    Run Keywords    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_CB008053.xml
    ...        AND    With Gnb Configuration    commissioning=${scfc_3}
    ...        AND    Wait For Testline Icmp Echo Replies And Ssh Services
    ...        AND    Start Default Logging
    ...        AND    With Simulator Configuration    config=${BASIC_SETUP}
    ...        AND    Create gNB Alias
    ...        AND    Wait For Next Full Pm Interval

    Add Scout Data Info To Testcase
    Configure UE1 UE2 UE3 capabilities    ue_capability_file=${UE_CAPABILITY_FILE}

    #####    UE1
    Attach Ue And Verify Establishing PDU Session With A1 Measurement Verification    ue_id=${UE_TDD_PCELL_1}
    ...    cell_id=${TDD_PCELL_ID}    gnb_id=${GNB_ID}    pdu_id=${PDU_TDD_PCELL_1}    gw_id=${UE_TDD_PCELL_1}
    Trigger A1 Based CA    ue_id=${UE_TDD_PCELL_1}    gnb_id=${GNB_ID}    meas_id=${Trigger_CA_Meas_ID}
    Verify 4CC TTTF A1 Based SCell Addition For Ue1    ue_id=${UE_TDD_PCELL_1}
    Verify Traffic Is Scheduled On All Cells    ue_id=${UE_TDD_PCELL_1}    pdu_id=${PDU_TDD_PCELL_1}    num_of_scells=3
    Release UE    ue_id=${UE_TDD_PCELL_1}    pdu_id=${PDU_TDD_PCELL_1}

    #####    UE2
    Attach Ue And Verify Establishing PDU Session With A1 Measurement Verification    ue_id=${UE_TDD_PCELL_2}
    ...    cell_id=${TDD_PCELL_ID}    gnb_id=${GNB_ID}    pdu_id=${PDU_TDD_PCELL_1}    gw_id=${UE_TDD_PCELL_2}
    Trigger A1 Based CA    ue_id=${UE_TDD_PCELL_2}    gnb_id=${GNB_ID}    meas_id=${Trigger_CA_Meas_ID}
    Verify 4CC TTFF A1 Based SCell Addition For Ue2    ue_id=${UE_TDD_PCELL_2}
    Verify Traffic Is Scheduled On All Cells    ue_id=${UE_TDD_PCELL_2}    pdu_id=${PDU_TDD_PCELL_1}    num_of_scells=3
    Release UE    ue_id=${UE_TDD_PCELL_2}    pdu_id=${PDU_TDD_PCELL_1}

    #####    UE3
    Attach Ue And Verify Establishing PDU Session With A1 Measurement Verification    ue_id=${UE_TDD_PCELL_3}
    ...    cell_id=${TDD_PCELL_ID}    gnb_id=${GNB_ID}    pdu_id=${PDU_TDD_PCELL_1}    gw_id=${UE_TDD_PCELL_3}
    Trigger A1 Based CA    ue_id=${UE_TDD_PCELL_3}    gnb_id=${GNB_ID}    meas_id=${Trigger_CA_Meas_ID}
    Verify 2CC TT A1 Based SCell Addition For Ue3    ue_id=${UE_TDD_PCELL_3}
    Verify Traffic Is Scheduled On All Cells    ue_id=${UE_TDD_PCELL_3}    pdu_id=${PDU_TDD_PCELL_1}    num_of_scells=1
    Release UE    ue_id=${UE_TDD_PCELL_3}    pdu_id=${PDU_TDD_PCELL_1}

    Verify 4CC And 2CC CA Counters    pcell_id=${TDD_PCELL_ID}    scell_id_ue3=5

    [Teardown]    Run Keywords    Stop Default Logging
