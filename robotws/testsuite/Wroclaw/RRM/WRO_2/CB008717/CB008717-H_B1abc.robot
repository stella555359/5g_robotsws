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
...                Backup And Modify Swconfig File    parameters_list=@{8717_SWCONFIG_FLAGS}
...    AND         Configure Test Environment
                       ...    iphy=${IPHY}
                       ...    scfc=${SCFC}
                       ...    egate=${EGATE}
...    AND     Create gNB And UEs Aliases
Test Teardown    Add Scout Scf Id To Test Data

*** Variables ***
${LOGGING_POLICY}=    FULL_POLICY
${IPHY}=              ${CURDIR}/config/CB008717_H/iphy_2c_FR1_n41_FR2_n257.xml
${SCFC}=              SCFC_CB008717_H_B1a.xml
${EGATE}=             ${CURDIR}/config/CB008717_H/2c_FR1_n66_FR2_n257_HB1.cfg

*** Test Cases ***
CB008717-H-B1a_Configuration_of_A4_measurement_for_NR_DC
    Prepare Flow Check    scenario=HB1a    ue_id=UE_1
    Attach UE And Establish PDU Session    ue_id=1    cell_id=1    enb_id=2
    Verify Flow Context For Hb1a    scenario=HB1a
    [Teardown]    Deregister Ue    ue_id=1

CB008717-H-B1b_Configuration_of_A4_measurement_for_NR_DC_With_Measurement_Gaps
    Prepare Flow Check    scenario=HB1b    ue_id=UE_2
    Attach UE And Establish PDU Session    ue_id=2    cell_id=1    enb_id=2
    Verify Flow Context For Hb1b    scenario=HB1b
    [Teardown]    Deregister Ue    ue_id=2

CB008717_H_B1c_Unsuccessful_Configuration_Of_A4 Measurement_For_NR_DC_Due_To_No_Response_To_RRC_Reconfiguration
    Prepare Flow Check For Failure Scenario
    Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=2 if_contains=meas_gap_setup action=drop
    Attach UE And Establish PDU Session    ue_id=2    cell_id=1    enb_id=2
    Verify Flow Context For Hb1c

*** Keywords ***
Prepare Flow Check
    [Arguments]    ${scenario}    ${ue_id}
    Expect message flow
    ...    ${ue_id}:NR-RRC_RRCReconfiguration (radioBearerConfig is not present) as RRCReconfiguration
    ...    ${ue_id}:NR-RRC_RRCReconfigurationComplete
    ...    gNB:F1AP_UEContextModificationRequest (CUtoDURRCInformation is present)
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

Verify Flow Context For Hb1a
    [Arguments]    ${scenario}
    Check If Flow occurred as expected    scenario=${scenario}
    Verify Message Flow    scenario=${scenario}
    Verify That Message Fulfills Query
    ...        (measGapConfig is not present)
    ...    flow_alias=NR_DC_FlOW_${scenario}
    ...    message_alias=RRCReconfiguration

Verify Flow Context For Hb1b
    [Arguments]    ${scenario}
    Check If Flow occurred as expected    scenario=${scenario}
    Verify Message Flow    scenario=${scenario}
    Verify That Message Fulfills Query
    ...        (measGapConfig is present)
    ...    flow_alias=NR_DC_FlOW_${scenario}
    ...    message_alias=RRCReconfiguration

Prepare Flow Check For Failure Scenario
    Expect message flow
    ...    UE_2:NR-RRC_RRCReconfiguration (radioBearerConfig is not present)
    ...    UE_2:NR-RRC_RRCRelease
    ...    alias=NR_DC_FlOW_HB1c
    ...    overall_timeout=10
    Expect Message Will Not Occur
    ...    UE_2:NR-RRC_RRCReconfigurationComplete (rrc-TransactionIdentifier eq 3)
    ...    alias=NO_MESSAGE_Hb1c
    ...    overall_timeout=10

Verify Flow Context For Hb1c
    Check If Flow occurred as expected    scenario=HB1c
    Flow Not Occurred For Message    alias=NO_MESSAGE_Hb1c
