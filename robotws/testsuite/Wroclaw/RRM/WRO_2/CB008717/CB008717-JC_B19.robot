*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO

Documentation   :copyright: Nokia
...             :authors: Tomasz Dabrowski
...             :contact: tomasz.dabrowski@nokia.com

Resource    testsuite/Wroclaw/RRM/resources/airphone/scout_reporting/reporting_portal.robot
Resource    taf/rfrl/common_resources/robot/libraries_instances.robot
Resource    ../keywords/logging.robot
Resource    ../keywords/L3_Call.robot
Resource    feature_keywords.robot
Resource    testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Library     taf.ul.ettf.setups
Library     taf.ul.ettf.logging
Library     taf.ul.ettf.retry_context
Library     ta_messaging
Library     ta5g_iphy

Suite Setup    Run Keywords
...                 Backup And Modify Swconfig File    parameters_list=@{8717_SWCONFIG_FLAGS}
...    AND          Configure Test Environment
               ...    iphy=${IPHY}
               ...    scfc=${SCFC}
               ...    egate=${EGATE}
               ...    AND     Create gNB And UEs Aliases

Test Teardown     Add Scout External Execution ID To Reporting Portal


*** Variables ***
${LOGGING_POLICY}=    SYSLOG_POLICY
${IPHY}=              ${CURDIR}/config/CB008717_JC/iphy_n78A_n257A_BOO_AP_LOO.xml
${SCFC}=              scfc_JC_B19_n78A_n257A_BOO_LOO.xml
${EGATE}=             ${CURDIR}/config/CB008717_JC/BOO_AP_LOO_n78_n257_JC_B19.cfg

*** Test Cases ***
CB008717_JC_B19a_RRC_Connection_Release_When_Idle_Mode_Mobility_Steering_Is_Enabled_And_UE_Is_Not_In_NR-DC_Mode
    Expect NGAP Message Flow For JC_B19 Scenario
    Expect F1AP Message Flow For JC_B19 Scenario
    Expect RRC Message Flow For JC_B19 Scenario
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1    nwslice=1
    Deregister Ue By AMF
    Flow occurred as expected    alias=NR_DC_FlOW_JC_B19_NGAP
    Flow occurred as expected    alias=NR_DC_FlOW_JC_B19_F1AP
    Flow occurred as expected    alias=NR_DC_FlOW_JC_B19_RRC
    Verify In F1AP Messages That A4 NR-DC Measurements Are Configured and Cell Reselection Priorities Set On RRCRelease

*** Keywords ***
Expect NGAP Message Flow For JC_B19 Scenario
    Expect message flow
    ...    gNB:NGAP_InitialContextSetupRequest
    ...    gNB:NGAP_InitialContextSetupResponse
    ...    alias=NR_DC_FlOW_JC_B19_NGAP
    ...    overall_timeout=600


Expect F1AP Message Flow For JC_B19 Scenario
    Expect message flow
    ...    gNB:F1AP_UEContextSetupRequest (CUtoDURRCInformation is present) as UEContextSetupRequest
    ...    gNB:F1AP_UEContextSetupResponse
    ...    gNB:F1AP_UEContextModificationRequest (CUtoDURRCInformation is present) as UEContextModificationRequest
    ...    gNB:F1AP_UEContextModificationResponse
    ...    gNB:F1AP_DLRRCMessageTransfer
    ...    gNB:F1AP_ULRRCMessageTransfer
    ...    gNB:F1AP_UEContextReleaseCommand
    ...    gNB:F1AP_UEContextReleaseComplete
    ...    alias=NR_DC_FlOW_JC_B19_F1AP
    ...    overall_timeout=600

Expect RRC Message Flow For JC_B19 Scenario
    Expect message flow
    ...    UE_1:NR-RRC_RRCRelease
    ...    alias=NR_DC_FlOW_JC_B19_RRC
    ...    overall_timeout=600

Verify In F1AP Messages That A4 NR-DC Measurements Are Configured and Cell Reselection Priorities Set On RRCRelease
    Verify Tcpdump Log      ${F1AP_UE_CONTEXT_MODIFICATION_REQUEST_FOR_JC_B19}
    Verify Tcpdump Log      ${F1AP_DLRRC_MESSAGE_TRANSFER_RRC_RECONFIGURATION_FOR_JC_B19}
    Verify Tcpdump Log      ${F1AP_UE_CONTEXT_RELEASE_COMMAND_FOR_JC_B19}


Deregister Ue By AMF
    Execute Egate Command    cmd=ue_deregister id=1 by=amf ue_deregister_type=normal
