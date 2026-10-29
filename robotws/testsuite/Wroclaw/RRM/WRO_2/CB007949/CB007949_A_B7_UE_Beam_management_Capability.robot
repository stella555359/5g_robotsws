*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    SBTS22R4    SBTS23R1
    ...    CLOUD_5G_I_BOO_AP_LOO

Documentation   :copyright: Nokia
...             :authors: Marta Klukas
...             :contact: marta.klukas@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource    ../keywords/tshark_verifying.robot
Resource     ../keywords/L3_Call.robot
Resource     CB007949_keywords.robot
Resource     ../keywords/logging.robot
Library      ta5g_testline_management
Library      ta5g_cell_operations
Library      ta5g_enb
Library      ta5g_delta

Variables    ../resources/custom_policy.py

Suite Setup    Run Keywords    Enable C-Plane Debug Logs    with_reboot=${false}
...    AND         Wait For Environment To Stabilize

Test Setup      With Retry Context    1
...                Update And Put Iphy Xml         input_filepath=${iphy_xml}
...    AND         With Gnb Configuration          commissioning=${scfc}
...    AND         Enable Tshark Verification
...    AND         With Simulator Configuration    config=${cfg}

Suite Teardown     Run Keywords    Stop Default Logging

*** Variables ***
${LOGGING_POLICY}=          BASIC_POLICY
${cfg}=                     ${CURDIR}/config/egate_custom_config.cfg
${iphy_xml}=                ${CURDIR}/config/iphy_3FDD_3TDD_bw_100_50_60.xml
${scfc}=                    scfc_7949_A_B7.xml
${ue_id}=                   2
${gw_id}=                   2
${pcell_id}=                3
${gnb_id}=                  2

*** Test Cases ***
CB007949_A_B7a_Blind_SCell_Addition_For_TDD_PCell_With_3CC_DL_CA_With_Beamforming_Enabled_And_Beam_Refinement_Is_Applied_For_The_UE_In_PCell_Only
    Trigger And Verify Blind SCell Addition
    Verify Correct PUCCH Configuration For SCells
    Verify RRC Reconfiguration
    Verify Full Configuration
    Verify If Ue Is Attached To PCell

*** Keywords ***
Trigger And Verify Blind SCell Addition
    Attach UE And Establish PDU Session    ue_id=${ue_id}    cell_id=${pcell_id}    enb_id=${gnb_id}    gw_id=${gw_id}
    Verify SCells Addition

Verify SCells Addition
    Clear Egate Buffer From Logs
    Verify Egate Content    expected_pattern=SCellIndex 1 activated successfully at airphone
    Verify Egate Content    expected_pattern=SCellIndex 2 activated successfully at airphone
    Verify Successful 3CC TTT On F1AP Messages
