*** Settings ***
Force Tags    RAN_5G    SBTS00    NoResUsage    CRT
    ...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD


Documentation   :copyright: Nokia
...             :authors: Krystian Rechul-Narojek
...             :contact: krystian.rechul-narojek@nokia.com

Resource    ../keywords/tshark_verifying.robot
Resource    taf/rfrl/common_resources/robot/libraries_instances.robot
Resource    feature_keywords.robot
Resource    ../keywords/logging.robot
Resource    ../keywords/L3_Call.robot
Resource    testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Variables   feature_variables.py
Variables   ../resources/custom_policy.py
Library     KeywordsCB008717.py
Library     taf.ul.ettf.setups
Library     taf.ul.ettf.logging
Library     taf.ul.ettf.retry_context
Library     ta_messaging
Library     ta5g_iphy

Suite Setup    Run Keywords
...    Backup And Modify Swconfig File    parameters_list=@{swconfig_8717_rdFlag}
...    AND     Reach Configured State With Third Radio Locked


Test Teardown     Stop Default Logging
Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${LOGGING_POLICY}=    BASIC_POLICY
${iphy_xml}=            ${CURDIR}/config/CB008717_G/iphy_8717_G_B81b_2xAEQE_1x_AWEUB.xml
${egate_cfg}=           ${CURDIR}/config/CB008717_G/cfg_8717_G_B81b_n78_n257_3cells.cfg
${scfc}=                scfc_8717_G_B81b.xml
${delta}=               delta_8717_G_B81b.json

*** Test Cases ***
CB008717_G_B8.1b_ALT1_NR_DC_SN_cell_setup_and_activation_in_RAN_sharing_configuration
    Configure Wts Without Onair Check    lua_cfg=${egate_cfg}
    Waiting For Cell Configuring
    Unlock Radio    3
    Unlock FR1 SA Cell
    Wait For All Cells To Be Enabled
    Verify If Proper Cells Are In Service State
    Verify Mibs and Sib after Reached Onair
    Check If Flow occurred as expected    scenario=G_B81b
    Verify E1AP F1AP and NGAP Messages For G_B81b Scenario

*** Keywords ***
Reach Configured State With Third Radio Locked
    Prepare G_B81b Test Configuration
    Start Default Logging    output_dirpath=${OUTPUT_DIR}
    Prepare Flow Check For G_B81b Scenario
    Wait Until Keyword Succeeds    3x    1s    Check Radios Availability

Prepare G_B81b Test Configuration
    Update And Put Iphy Xml    input_filepath=${iphy_xml}
    Enable C-Plane Debug Logs    with_reboot=${FALSE}
    Find Scfc And Fix And Send Full Commissioning    scfc_filename=${scfc}
    Wait For Testline Icmp Echo Replies And Ssh Services

Prepare Flow Check For G_B81b Scenario
    feature_keywords.Create GNB alias
    Expect F1AP and NGAP Message Flow For G_B81b Scenario

Expect F1AP and NGAP Message Flow For G_B81b Scenario
    Expect message flow
    ...    gNB:F1AP_F1SetupRequest as F1SetupRequestWithSa1Cell
    ...    gNB:F1AP_F1SetupResponse as F1SetupResponse
    ...    gNB:NGAP_NGSetupRequest as NGSetupRequest
    ...    gNB:NGAP_NGSetupResponse as NGSetupResponse
    ...    gNB:F1AP_GNBCUConfigurationUpdate as CUConfUpdForSa1CellActivation
    ...    gNB:F1AP_GNBCUConfigurationUpdateAcknowledge as CUConfUpdAckForSa1CellActivation
    ...    gNB:F1AP_GNBDUConfigurationUpdate as DUConfUpdForSa1CellActivation
    ...    gNB:F1AP_GNBDUConfigurationUpdateAcknowledge as DUConfUpdAckForSa1CellActivation
    ...    gNB:F1AP_GNBDUConfigurationUpdate as DUConfUpdForNrdcsnCellAdd
    ...    gNB:F1AP_GNBDUConfigurationUpdateAcknowledge as DUConfUpdAckForNrdcsnCellAdd
    ...    gNB:F1AP_GNBCUConfigurationUpdate as CUConfUpdForNrdcsnCellActivation
    ...    gNB:F1AP_GNBCUConfigurationUpdateAcknowledge as CUConfUpdAckForNrdcsnCellActivation
    ...    gNB:F1AP_GNBDUConfigurationUpdate as DUConfUpdForNrdcsnCellActivation
    ...    gNB:F1AP_GNBDUConfigurationUpdateAcknowledge as DUConfUpdAckForNrdcsnCellActivation
    ...    gNB:F1AP_GNBDUConfigurationUpdate as DUConfUpdForSa2CellAdd
    ...    gNB:F1AP_GNBDUConfigurationUpdateAcknowledge as DUConfUpdAckForSa2CellAdd
    ...    gNB:NGAP_RANConfigurationUpdate as RANConfigurationUpdate
    ...    gNB:NGAP_RANConfigurationUpdateAcknowledge as RANConfigurationUpdateAcknowledge
    ...    gNB:F1AP_GNBCUConfigurationUpdate as CUConfUpdForSa2CellActivation
    ...    gNB:F1AP_GNBCUConfigurationUpdateAcknowledge as CUConfUpdAckForSa2CellActivation
    ...    gNB:F1AP_GNBDUConfigurationUpdate as DUConfUpdForSa2CellActivation
    ...    gNB:F1AP_GNBDUConfigurationUpdateAcknowledge as DUConfUpdAckForSa2CellActivation
    ...    alias=NR_DC_FlOW_G_B81b
    ...    overall_timeout=600

Verify E1AP F1AP and NGAP Messages For G_B81b Scenario
    Verify Tcpdump Log      ${E1AP_SETUP_REQUEST_G_B81}
    Verify Tcpdump Log      ${F1AP_F1SETUP_REQUEST_WITH_SA_CELL_G_B81}
    Verify Tcpdump Log      ${F1AP_GNB_DU_CONFIGURATION_UPDATE_WITH_NRDC_CELL_TO_ADD_WITH_PLMN3_AND_PLMN4_G_B81b}
    Verify Ngap Messages    ${NGAP_SETUP_REQUEST_G_B81}
    Verify Tcpdump Log      ${F1AP_GNB_CU_CONFIGURATION_UPDATE_FOR_NRDC_CELL_ACTIVATION_WITH_PLMN3_AND_PLMN4_G_B81b}
    Verify Ngap Messages    ${NGAP_NGRAN_CONFIGURATION_UPDATE_FOR_SA_CELL_WITH_TAC3_PLMN3_PLMN4}
    Verify Tcpdump Log      ${F1AP_GNB_CU_CONFIGURATION_UPDATE_FOR_2ND_SA_CELL_ACTIVATION_WITH_PLMN3_AND_PLMN4}
