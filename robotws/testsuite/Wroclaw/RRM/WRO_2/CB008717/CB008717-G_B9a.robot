*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO

Resource    ../keywords/tshark_verifying.robot
Resource    taf/rfrl/common_resources/robot/libraries_instances.robot
Resource    feature_keywords.robot
Resource    ../keywords/logging.robot
Resource    ../keywords/L3_Call.robot
Resource    testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Variables   feature_variables.py
Variables   ../resources/custom_policy.py
Library     ute_wtssim
Library     KeywordsCB008717.py
Library     taf.ul.ettf.setups
Library     taf.ul.ettf.logging
Library     taf.ul.ettf.retry_context
Library     ta_messaging
Library     ta5g_iphy
Library     ta5g_testline_management


Suite Setup    Run Keywords
...                Backup And Modify Swconfig File    parameters_list=@{swconfig_8717_rdFlag}
...    AND         Reach Configured State With FR2 Locked

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs


*** Variables ***
${LOGGING_POLICY}=      BASIC_POLICY
${iphy_xml}=            ${CURDIR}/config/CB008717_G/iphy_n78_n257_8CC_G9a.xml
${egate_cfg}=           ${CURDIR}/config/CB008717_G/cfg_n78_n257_8CC_G9a.cfg
${scfc}=                scfc_n78_n257_8CC_BOO_LOO_G9.xml
${delta}=               Unlocked_FR2.json


*** Test Cases ***
CB008717_G_B9a_NR-DC-SN_Cells_Setup_And_Activation_Triggered_By_SA+NSA_Cell
    Start Default Simulated SANSA Interfaces
    Configure Wts Without Onair Check    lua_cfg=${egate_cfg}
    Unlock FR2 Radio    2
    Establish X2 Link
    Unblocking Ng Interface
    Verify F1AP gNBDuConfigurationUpdate For FR2 8 Cells
    Verify If Cells To Be Activated List Contains 8 FR2 Cells And PCell
    Verify If 9 Cells Are In Service State
    Verify Mibs and Sib after Reached Onair
    Check If Flow occurred as expected    scenario=G_B9
    Verify F1AP Messages For G_B9 Scenario

*** Keywords ***
Establish X2 Link
    [Arguments]    ${enb}=1    ${gnb}=2
    Execute Egate Command And Wait For Data
    ...     cmd=enb_x2_link_up enb=${enb} target=${gnb}
    ...     timeout=60
    ...     pass_regexp=X2AP Link with GNB-2

Unblocking Ng Interface
    Execute Egate Command And Wait For Data
    ...     cmd=amf_ng_setup_param id=1 gnb=2 request_ignore=off
    ...     timeout=310
    ...     pass_regexp=NG Link to gNB=2 is now Active

Reach Configured State With FR2 Locked
    Prepare G_B9 Test Configuration
    Start Default Logging    output_dirpath=${OUTPUT_DIR}
    Prepare Flow Check For G_B9 Scenario
    Wait Until Keyword Succeeds    3x    1s    Check Radios Availability

Prepare G_B9 Test Configuration
    Update And Put Iphy Xml    input_filepath=${iphy_xml}
    Enable C-Plane Debug Logs    with_reboot=${FALSE}
    Find Scfc And Fix And Send Full Commissioning    scfc_filename=${scfc}
    Wait For Testline Icmp Echo Replies And Ssh Services

Prepare Flow Check For G_B9 Scenario
    feature_keywords.Create GNB alias
    Expect F1AP, NGAP and X2AP Message Flow For G_B9 Scenario

Expect F1AP, NGAP and X2AP Message Flow For G_B9 Scenario
    Expect message flow
    ...    gNB:F1AP_F1SetupRequest as F1SetupRequestWithSaCell
    ...    gNB:F1AP_F1SetupResponse as F1SetupResponse
    ...    gNB:F1AP_GNBDUConfigurationUpdate as DUConfUpdForNrdcsnCellServedList
    ...    gNB:F1AP_GNBDUConfigurationUpdateAcknowledge as DUConfUpdAckForNrdcsnCellServedList
    ...    gNB:F1AP_GNBDUConfigurationUpdate as DUConfUpdForNrdcsnCellServedList
    ...    gNB:F1AP_GNBDUConfigurationUpdateAcknowledge as DUConfUpdAckForNrdcsnCellServedList
    ...    gNB:F1AP_GNBDUConfigurationUpdate as DUConfUpdForNrdcsnCellServedList
    ...    gNB:F1AP_GNBDUConfigurationUpdateAcknowledge as DUConfUpdAckForNrdcsnCellServedList
    ...    gNB:F1AP_GNBDUConfigurationUpdate as DUConfUpdForNrdcsnCellServedList
    ...    gNB:F1AP_GNBDUConfigurationUpdateAcknowledge as DUConfUpdAckForNrdcsnCellServedList
    ...    gNB:F1AP_GNBDUConfigurationUpdate as DDUConfUpdForNrdcsnCellServedList
    ...    gNB:F1AP_GNBDUConfigurationUpdateAcknowledge as DUConfUpdAckForNrdcsnCellServedList
    ...    gNB:F1AP_GNBDUConfigurationUpdate as DUConfUpdForNrdcsnCellServedList
    ...    gNB:F1AP_GNBDUConfigurationUpdateAcknowledge as DUConfUpdAckForNrdcsnCellServedList
    ...    gNB:F1AP_GNBDUConfigurationUpdate as DUConfUpdForNrdcsnCellServedList
    ...    gNB:F1AP_GNBDUConfigurationUpdateAcknowledge as DUConfUpdAckForNrdcsnCellServedList
    ...    gNB:F1AP_GNBDUConfigurationUpdate as DUConfUpdForNrdcsnCellServedList
    ...    gNB:F1AP_GNBDUConfigurationUpdateAcknowledge as DUConfUpdAckForNrdcsnCellServedList
    ...    gNB:X2AP_ENDCX2SetupRequest as X2SetupRequest
    ...    gNB:X2AP_ENDCX2SetupResponse as X2SetupResponse
    ...    gNB:F1AP_GNBCUConfigurationUpdate as CUConfUpdForNSAPCellActList
    ...    gNB:F1AP_GNBCUConfigurationUpdateAcknowledge as CUConfUpdAckForNSAPCellActList
    ...    gNB:F1AP_GNBDUConfigurationUpdate as DUConfUpdForNSACellStatList
    ...    gNB:F1AP_GNBDUConfigurationUpdateAcknowledge as DUConfUpdAckForNSACellStatList
    ...    gNB:NGAP_NGSetupRequest as NGSetupRequest
    ...    gNB:NGAP_NGSetupResponse as NGSetupResponse
    ...    gNB:F1AP_GNBCUConfigurationUpdate as CUConfUpdForSaCellActList
    ...    gNB:F1AP_GNBCUConfigurationUpdateAcknowledge as CUConfUpdAckForSaCellActList
    ...    gNB:F1AP_GNBDUConfigurationUpdate as CUConfUpdForSaCellModList
    ...    gNB:F1AP_GNBCUConfigurationUpdate as CUConfUpdForNrdcsnCellActList
    ...    gNB:F1AP_GNBCUConfigurationUpdateAcknowledge as CUConfUpdAckForNrdcsnCellActList
    ...    gNB:F1AP_GNBDUConfigurationUpdateAcknowledge as DUConfUpdAckForSaCellModList
    ...    gNB:F1AP_GNBDUConfigurationUpdate as DUConfUpdForSaCellActList
    ...    alias=NR_DC_FlOW_G_B9
    ...    overall_timeout=1200

Verify F1AP Messages For G_B9 Scenario
    Verify Tcpdump Log      ${F1AP_F1SETUP_REQUEST_WITH_PCELL}
    Verify Tcpdump Log      ${F1AP_F1SETUP_RESPONSE}
    Verify Tcpdump Log      ${F1AP_GNB_CU_CONFIGURATION_UPDATE_FOR_NSA_PART_CELL_ACTIVATION}
    Verify Tcpdump Log      ${F1AP_GNB_CU_CONFIGURATION_UPDATE_FOR_SA_CELL_ACTIVATION}



