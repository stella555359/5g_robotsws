*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO

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

*** Variables ***
${LOGGING_POLICY}=    FULL_POLICY
${IPHY}=              ${CURDIR}/config/CB008717_JC/iphy_n78A_n257A_BOO_AP_LOO.xml
${SCFC}=              scf_JC_B1a_n78A_n257A_BOO_LOO.xml
${EGATE}=             ${CURDIR}/config/CB008717_JC/BOO_LOO_JC_B1a_n78_n257.cfg

*** Test Cases ***
CB008717_JC_B1a_Activation_Of_Inter_Freq_A4_Measurement_For_NRDC_PSCell_Addition_After_ICS
    Prepare Flow Check For JC_B1a    scenario=JC_B1a    ue_id=UE_1
    Attach UE And Establish PDU Session    ue_id=1    cell_id=1    enb_id=2
    Verify Flow Context For JC_B1a    scenario=JC_B1a
    [Teardown]    Deregister Ue    ue_id=1

*** Keywords ***
Prepare Flow Check For JC_B1a
    [Arguments]    ${scenario}    ${ue_id}
    Expect message flow
    ...    gNB:F1AP_UEContextModificationRequest (measObjectEutra is not present)
    ...    gNB:F1AP_UEContextModificationResponse
    ...    ${ue_id}:NR-RRC_RRCReconfiguration (radioBearerConfig is not present) as RRCReconfiguration
    ...    ${ue_id}:NR-RRC_RRCReconfigurationComplete
    ...    gNB:F1AP_UEContextModificationRequest
    ...    gNB:F1AP_UEContextModificationResponse
    ...    gNB:F1AP_DLRRCMessageTransfer
    ...    gNB:F1AP_ULRRCMessageTransfer
    ...    alias=NR_DC_FlOW_${scenario}
    ...    overall_timeout=15

Verify Message Flow
    [Arguments]    ${scenario}
    Verify That Message Fulfills Query
    ...        (reportConfigToAddModList contains (
    ...            reportAmount eq 'r4'))
    ...        and
    ...        (reportConfigToAddModList contains (
    ...            reportInterval eq 'ms1024'))
    ...        and
    ...        (reportConfigToAddModList contains (
    ...            hysteresis eq 0))
    ...        and
    ...        (measIdToAddModList contains (
    ...            measId eq 1))
    ...        and
    ...        (measObjectToAddModList contains (
    ...            ssbFrequency eq 2071387))
    ...    flow_alias=NR_DC_FlOW_${scenario}
    ...    message_alias=RRCReconfiguration

Verify Flow Context For JC_B1a
    [Arguments]    ${scenario}
    Check If Flow occurred as expected    scenario=${scenario}
    Verify Message Flow    scenario=${scenario}
    Verify That Message Fulfills Query
    ...        (measGapConfig is not present)
    ...    flow_alias=NR_DC_FlOW_${scenario}
    ...    message_alias=RRCReconfiguration

