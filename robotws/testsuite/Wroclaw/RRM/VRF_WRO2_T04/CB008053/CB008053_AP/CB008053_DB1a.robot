*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
...           CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation    :copyright: Nokia
...              :authors: Lukasz Klimowicz
...              :contact: lukasz.klimowicz@nokia.com

Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB008053/CB008053_AP/CB008053_Keywords_And_Variables.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/iphy/wireshark_plugin.robot


*** Test Cases ***
CB008053-D_B1a_Simultaneous_Rx_Tx_Inter_Band_CA_transmission_handling_-_TDD_PCell
    [Setup]    Run Keywords    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_CB008053.xml
    ...        AND    Upload Fixed Iphy Plug
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
