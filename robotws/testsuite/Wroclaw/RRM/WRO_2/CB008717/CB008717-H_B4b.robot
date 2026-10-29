*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO

Documentation    :copyright: Nokia
...              :authors: Dariusz Maciocha
...              :contact: dariusz.maciocha@nokia.com

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
Library     testsuite/Wroclaw/RRM/resources/scout_report.py

Suite Setup    Run Keywords
...                 Backup And Modify Swconfig File    parameters_list=@{8717_SWCONFIG_FLAGS}
...    AND          Configure Test Environment
                       ...    iphy=${IPHY}
                       ...    scfc=${SCFC}
                       ...    egate=${EGATE}
...    AND     Create gNB And UEs Aliases
Test Setup        Workaround For Ue Attach
Test Teardown    Add Scout Scf Id To Test Data

*** Variables ***
${LOGGING_POLICY}=    FULL_POLICY
${IPHY}=              ${CURDIR}/config/CB008717_H/iphy_n66_n257_5CC.xml
${SCFC}=              h_b4b_scf_5cells_with_drx.xml
${EGATE}=             ${CURDIR}/config/CB008717_H/8717_n66_n257_5CC.cfg
${A4_SUPERVISION_TIMER}=    6
${A4_RETRY_TIMER}=    10

*** Test Cases ***
CB008717_H_B4b_Alt1_Reactivate_NR-DC_A4_Measurements_When_A4_Retry_Timer_Expires_With_DRX_And_Without_Measurement_Gaps
    Prepare Flow Check For Alt1
    Attach UE And Establish PDU Session    ue_id=1    cell_id=1    enb_id=2
    Wait For A4 Supervision Timer And A4 Retry Timer Expiration
    Check If Flow occurred as expected    scenario=HB4b_Alt1
    Verify If A4 Supervision Timer Expired After Correct Time    scenario=HB4b_Alt1
    Verify If A4 Retry Timer Expired After Correct Time    scenario=HB4b_Alt1
    Verify Message Flow

CB008717_H_B4b_Alt2_Re-activate_NR-DC_inter-freq_A4_measurements_when_A4_Retry_Timer_expires_with_DRX
    Prepare Flow Check For Alt2
    Attach UE And Establish PDU Session    ue_id=2    cell_id=1    enb_id=2
    Wait For A4 Supervision Timer And A4 Retry Timer Expiration
    Check If Flow occurred as expected    scenario=HB4b_Alt2
    Verify if A4 Supervision Timer Expired After Correct Time    scenario=HB4b_Alt2
    Verify if A4 Retry Timer Expired After Correct Time    scenario=HB4b_Alt2

*** Keywords ***
Prepare Flow Check For Alt1
    Expect message flow
        ...    UE_1:NR-RRC_RRCReconfiguration (measGapConfig is not present and length(measIdToAddModList) eq 2) as A4
        ...    UE_1:NR-RRC_RRCReconfigurationComplete as A4_Supervision_Timer_Start
        ...    UE_1:NR-RRC_RRCReconfiguration (drx-Config is present)
        ...    UE_1:NR-RRC_RRCReconfigurationComplete
        ...    UE_1:NR-RRC_RRCReconfiguration (length(measIdToRemoveList) eq 2) as A4_Supervis_Stop
        ...    UE_1:NR-RRC_RRCReconfigurationComplete as A4_Retry_Timer_Start
        ...    UE_1:NR-RRC_RRCReconfiguration (length(measIdToAddModList) eq 2) as A4_Retry_Timer_Stop
        ...    UE_1:NR-RRC_RRCReconfigurationComplete
        ...    alias=NR_DC_FlOW_HB4b_Alt1
        ...    overall_timeout=30

Prepare Flow Check For Alt2
    Expect message flow
        ...    UE_2:NR-RRC_RRCReconfiguration (radioBearerConfig is not present and gapUE is present)
        ...    UE_2:NR-RRC_RRCReconfigurationComplete as A4_Supervision_Timer_Start
        ...    UE_2:NR-RRC_RRCReconfiguration (length(measIdToRemoveList) eq 2 and gapUE is present) as A4_Supervis_Stop
        ...    UE_2:NR-RRC_RRCReconfigurationComplete as A4_Retry_Timer_Start
        ...    gNB:F1AP_UEContextModificationRequest (DRXCycle is present)
        ...    gNB:F1AP_UEContextModificationResponse (drx-Config is present)
        ...    UE_2:NR-RRC_RRCReconfiguration (drx-Config is present)
        ...    UE_2:NR-RRC_RRCReconfigurationComplete
        ...    gNB:F1AP_UEContextModificationRequest (CUtoDURRCInformation is present)
        ...    gNB:F1AP_UEContextModificationResponse (measGapConfig is present)
        ...    gNB:F1AP_UEContextModificationRequest (DRXConfigurationIndicator is present)
        ...    gNB:F1AP_UEContextModificationResponse (drx-Config is present)
        ...    gNB:F1AP_DLRRCMessageTransfer
        ...    UE_2:NR-RRC_RRCReconfiguration (length(measIdToAddModList) eq 2) as A4_Retry_Timer_Stop
        ...    UE_2:NR-RRC_RRCReconfigurationComplete
        ...    alias=NR_DC_FlOW_HB4b_Alt2
        ...    overall_timeout=120

Wait For A4 Supervision Timer And A4 Retry Timer Expiration
    Sleep    ${A4_SUPERVISION_TIMER}
    Sleep    ${A4_RETRY_TIMER}

Verify If A4 Supervision Timer Expired After Correct Time
    [Arguments]    ${scenario}
    Verify delay between messages
        ...    reference_flow_alias=NR_DC_FlOW_${scenario}
        ...    reference_message_alias=A4_Supervision_Timer_Start
        ...    flow_alias=NR_DC_FlOW_${scenario}
        ...    message_alias=A4_Supervis_Stop
        ...    expected_diff_time=${A4_SUPERVISION_TIMER}
        ...    tolerance=1

Verify If A4 Retry Timer Expired After Correct Time
    [Arguments]    ${scenario}
    Verify delay between messages
        ...    reference_flow_alias=NR_DC_FlOW_${scenario}
        ...    reference_message_alias=A4_Retry_Timer_Start
        ...    flow_alias=NR_DC_FlOW_${scenario}
        ...    message_alias=A4_Retry_Timer_Stop
        ...    expected_diff_time=${A4_RETRY_TIMER}
        ...    tolerance=1

Verify Message Flow
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
        ...        ssbFrequency contains (
        ...            2072539, 2074267)
        ...    flow_alias=NR_DC_FlOW_HB4b_Alt1
        ...    message_alias=A4

Workaround For Ue Attach
    Run Keyword And Ignore Error    Attach UE And Establish PDU Session    ue_id=3    cell_id=1    enb_id=2
