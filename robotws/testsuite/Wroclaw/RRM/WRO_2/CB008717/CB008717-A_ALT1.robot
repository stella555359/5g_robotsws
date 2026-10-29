*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    SBTS22R4    SBTS23R1
    ...    CLOUD_5G_I_BOO_AP_LOO

Resource    ../keywords/tshark_verifying.robot
Resource    feature_keywords.robot
Variables   feature_variables.py
Library     KeywordsCB008717.py


Suite Setup    Run Keywords
...                Backup And Modify Swconfig File    parameters_list=@{swconfig_8717_rdFlag}
...    AND         Reach Configured State With First Radio Locked
...                          cell_number=2

Test Teardown     Stop Default Logging
Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${iphy_xml}=            ${CURDIR}/config/CB008717_A/iphy_2c_TDD_n41_FR2_n257.xml
${egate_cfg}=           ${CURDIR}/config/CB008717_A/2c_TDD_n41_FR2_n257.cfg
${scfc}=                TDD_n41_FR2_n257_ALT1.xml

*** Test Cases ***
CB008717_A_ALT1_NR_DC_SN_cell_setup_and_activation_where_gNB_DU_provides_as_first_NR_DC_SN_cell
    Configure Wts Without Onair Check    lua_cfg=${egate_cfg}
    Waiting For Cell Configuring
    Unlock Radio    1
    Wait For All Cells To Be Enabled
    Verify Mibs and Sib after Reached Onair
    Check If Flow occurred as expected    scenario=ALT1
    Verify F1AP and NGAP Messages For ALT1 Scenario

*** Keywords ***
Reach Configured State With First Radio Locked
    [Arguments]    ${cell_number}
    Prepare Test Configuration
    Start Default Logging    output_dirpath=${OUTPUT_DIR}
    Prepare Flow Check For ALT1 Scenario
    Wait Until Keyword Succeeds    3x    1s    Check Radios Availability

Prepare Flow Check For ALT1 Scenario
    feature_keywords.Create GNB alias
    Expect F1AP and NGAP Message Flow For ALT1 Scenario

Expect F1AP and NGAP Message Flow For ALT1 Scenario
    Expect message flow
    ...    gNB:F1AP_F1SetupRequest as F1SetupRequestWithNrdcsnCell
    ...    gNB:F1AP_F1SetupResponse as F1SetupResponse
    ...    gNB:F1AP_GNBDUConfigurationUpdate as DUConfUpdForSaCellAdd
    ...    gNB:F1AP_GNBDUConfigurationUpdateAcknowledge as DUConfUpdAckForSaCellAdd
    ...    gNB:NGAP_NGSetupRequest as NGSetupRequest
    ...    gNB:NGAP_NGSetupResponse as NGSetupResponse
    ...    gNB:F1AP_GNBCUConfigurationUpdate as CUConfUpdForSaCellActivation
    ...    gNB:F1AP_GNBCUConfigurationUpdateAcknowledge as CUConfUpdAckForSaCellActivation
    ...    gNB:F1AP_GNBDUConfigurationUpdate as DUConfUpdForSaCellActivation
    ...    gNB:F1AP_GNBDUConfigurationUpdateAcknowledge as DUConfUpdAckForSaCellActivation
    ...    gNB:F1AP_GNBCUConfigurationUpdate as CUConfUpdForNrdcsnCellActivation
    ...    gNB:F1AP_GNBCUConfigurationUpdateAcknowledge as CUConfUpdAckForNrdcsnCellActivation
    ...    gNB:F1AP_GNBDUConfigurationUpdate as DUConfUpdForNrdcsnCellActivation
    ...    gNB:F1AP_GNBDUConfigurationUpdateAcknowledge as DUConfUpdAckForNrdcsnCellActivation
    ...    alias=NR_DC_FlOW_ALT1
    ...    overall_timeout=1200

Verify F1AP and NGAP Messages For ALT1 Scenario
    Verify Tcpdump Log      ${F1AP_F1SETUP_REQUEST_WITH_NRDCSN_CELL}
    Verify Tcpdump Log      ${F1AP_F1SETUP_RESPONSE}
    Verify Tcpdump Log      ${F1AP_GNB_DU_CONFIGURATION_UPDATE_WITH_SA_CELL_TO_ADD}
    Verify Tcpdump Log      ${F1AP_GNB_DU_CONFIGURATION_UPDATE_ACKNOWLEDGE_WITH_SA_CELL_TO_ADD}
    Verify Ngap Messages    ${NGAP_SETUP_REQUEST}
    Verify Ngap Messages    ${NGAP_SETUP_RESPONSE}
    Verify Tcpdump Log      ${F1AP_GNB_CU_CONFIGURATION_UPDATE_FOR_SA_CELL_ACTIVATION_FOR_ALT1}
    Verify Tcpdump Log      ${F1AP_GNB_CU_CONFIGURATION_UPDATE_ACKNOWLEDGE_FOR_SA_CELL_ACTIVATION_FOR_ALT1}
    Verify Tcpdump Log      ${F1AP_GNB_DU_CONFIGURATION_UPDATE_FOR_SA_CELL_ACTIVATION_FOR_ALT1}
    Verify Tcpdump Log      ${F1AP_GNB_DU_CONFIGURATION_UPDATE_ACKNOWLEDGE_FOR_SA_CELL_ACTIVATION_FOR_ALT1}
    Verify Tcpdump Log      ${F1AP_GNB_CU_CONFIGURATION_UPDATE_FOR_NRDCSN_CELL_ACTIVATION_FOR_ALT1}
    Verify Tcpdump Log      ${F1AP_GNB_CU_CONFIGURATION_UPDATE_ACKNOWLEDGE_FOR_NRDCSN_CELL_ACTIVATION_FOR_ALT1}
    Verify Tcpdump Log      ${F1AP_GNB_DU_CONFIGURATION_UPDATE_FOR_NRDCSN_CELL_ACTIVATION_FOR_ALT1}
    Verify Tcpdump Log      ${F1AP_GNB_DU_CONFIGURATION_UPDATE_ACKNOWLEDGE_FOR_NRDCSN_CELL_ACTIVATION_FOR_ALT1}
