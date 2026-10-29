*** Settings ***
Documentation    :copyright: Nokia
...             :authors: I_MN_RAN_RD_VRF_WRO2_6
...             :contact: I_MN_RAN_RD_VRF_WRO2_6

Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO

Resource    testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource    ../keywords/tshark_verifying.robot
Resource    feature_keywords.robot
Variables   feature_variables.py
Library     KeywordsCB008717.py
Resource    taf/rfrl/common_resources/robot/libraries_instances.robot
Resource    ../keywords/logging.robot
Resource    ../keywords/L3_Call.robot
Library     taf.ul.ettf.setups
Library     taf.ul.ettf.logging
Library     taf.ul.ettf.retry_context
Library     ta_messaging
Library     ta5g_iphy


Suite Setup    Run Keywords
...    Backup And Modify Swconfig File    parameters_list=@{swconfig_8717_rdFlag}
...    AND     Reach Configured State With Second Radio Locked

Test Teardown     Stop Default Logging
Suite Teardown    Stop Default Processes And Gather Logs


*** Variables ***
${LOGGING_POLICY}=      FULL_POLICY
${iphy_xml}=            ${CURDIR}/config/CB008717_G/iphy_2xAEQE_1xAWEUB.xml
${egate_cfg}=           ${CURDIR}/config/CB008717_G/WTS_n78_n257_4cells.cfg
${scfc}=                scf_3cells_n78_1cell_n257_2AEQE_1AWEUB.xml
${delta}=               Unlocked_FR1_SA_Cell_2.json


*** Test Cases ***
CB008717_G_B8.1a_Successful_NR-DC-SN_Cell_Setup_With_Enabled_RAN_Sharing
    Configure Wts Without Onair Check    lua_cfg=${egate_cfg}
    Waiting For FR1 SA Cell Configuring
    Unlock FR2 Radio    2
    Wait For Cell To Be Enabled    cell_id=4
    Unlock FR1 SA Cell
    Verify If Proper Cells Are In Service State
    Check If Flow occurred as expected    scenario=G_B81a
    Verify E1AP F1AP and NGAP Messages For G_B81a Scenario

*** Keywords ***
Prepare Flow Check For G_B81a Scenario
    feature_keywords.Create GNB alias
    Expect F1AP and NGAP Message Flow For G_B81a Scenario

Expect F1AP and NGAP Message Flow For G_B81a Scenario
    Expect message flow
    ...    gNB:F1AP_F1SetupRequest as F1SetupRequestWithSaCell
    ...    gNB:F1AP_F1SetupResponse as F1SetupResponse
    ...    gNB:NGAP_NGSetupRequest as NGSetupRequest
    ...    gNB:NGAP_NGSetupResponse as NGSetupResponse
    ...    gNB:F1AP_GNBCUConfigurationUpdate as CUConfUpdForSaCellActList
    ...    gNB:F1AP_GNBCUConfigurationUpdateAcknowledge as CUConfUpdAckForSaCellActList
    ...    gNB:F1AP_GNBDUConfigurationUpdate as DUConfUpdForSaCellModList
    ...    gNB:F1AP_GNBDUConfigurationUpdateAcknowledge as DUConfUpdAckForSaCellModList
    ...    gNB:F1AP_GNBDUConfigurationUpdate as DUConfUpdForNrdcsnCellServedList
    ...    gNB:F1AP_GNBDUConfigurationUpdateAcknowledge as DUConfUpdAckForNrdcsnCellServedList
    ...    gNB:F1AP_GNBCUConfigurationUpdate as CUConfUpdForNrdcsnCellActivation
    ...    gNB:F1AP_GNBCUConfigurationUpdateAcknowledge as CUConfUpdAckForNrdcsnCellActivation
    ...    gNB:F1AP_GNBDUConfigurationUpdate as DUConfUpdForNrdcsnCellStatList
    ...    gNB:F1AP_GNBDUConfigurationUpdateAcknowledge as DUConfUpdAckForNrdcsnCellStatList
    ...    gNB:F1AP_GNBDUConfigurationUpdate as DUConfUpdAckForSaCellServedAddList
    ...    gNB:F1AP_GNBDUConfigurationUpdateAcknowledge as DUConfUpdAckForSaCellServedAddList
    ...    gNB:NGAP_RANConfigurationUpdate as RANConfigurationUpdateWithSuppTAList
    ...    gNB:NGAP_RANConfigurationUpdateAcknowledge as RANConfigurationUpdateAcknowledge
    ...    gNB:F1AP_GNBCUConfigurationUpdate as CUConfUpdForSaCellActList
    ...    gNB:F1AP_GNBCUConfigurationUpdateAcknowledge as CUConfUpdAckForSaCellActList
    ...    gNB:F1AP_GNBDUConfigurationUpdate as DUConfUpdForSaCellModList
    ...    gNB:F1AP_GNBDUConfigurationUpdateAcknowledge as DUConfUpdAckForSaCellModList
    ...    alias=NR_DC_FlOW_G_B81a
    ...    overall_timeout=1200

Verify E1AP F1AP and NGAP Messages For G_B81a Scenario
    Verify Tcpdump Log      ${E1AP_SETUP_REQUEST_G_B81}
    Verify Tcpdump Log      ${F1AP_F1SETUP_REQUEST_WITH_SA_CELL_G_B81}
    Verify Tcpdump Log      ${F1AP_GNB_DU_CONFIGURATION_UPDATE_WITH_NRDC_CELL_TO_ADD_WITH_PLMN3_AND_PLMN4_G_B81a}
    Verify Ngap Messages    ${NGAP_SETUP_REQUEST_G_B81}
    Verify Tcpdump Log      ${F1AP_GNB_CU_CONFIGURATION_UPDATE_FOR_NRDC_CELL_ACTIVATION_WITH_PLMN3_AND_PLMN4}
    Verify Ngap Messages    ${NGAP_NGRAN_CONFIGURATION_UPDATE_FOR_SA_CELL_WITH_TAC3_ONLY_PLMN3}


