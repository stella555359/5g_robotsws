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
...    AND     Create Ues Alias    alias=UE    id_type=wts_5g

*** Variables ***
${LOGGING_POLICY}=    FULL_POLICY
${IPHY}=              ${CURDIR}/config/CB008717_H/iphy_2c_FR1_n41_FR2_n257.xml
${SCFC}=              SCFC_CB008717_H_B1a.xml
${EGATE}=             ${CURDIR}/config/CB008717_H/2c_FR1_n66_FR2_n257_HB1_1UE.cfg
${A4_SUPERVISION_TIMER}=    7
${A4_RETRY_TIMER}=    10

*** Test Cases ***
CB008717_H_B4a_Re-activate_NR-DC_inter-freq_A4_measurement_when_A4_Retry_Timer_expires_for_one_FR2_cell
    Prepare Flow Check
    Attach UE And Establish PDU Session    ue_id=1    cell_id=1    enb_id=2
    Wait For A4 Supervision Timer Expiration
    Check If Flow occurred as expected    scenario=HB4a
    Verify test conditions

*** Keywords ***
Prepare Flow Check
    Expect message flow
        ...    UE_1:NR-RRC_RRCReconfiguration (radioBearerConfig is not present)
        ...    UE_1:NR-RRC_RRCReconfigurationComplete
        ...    UE_1:NR-RRC_RRCReconfiguration (measIdToRemoveList contains (1) and length(measIdToRemoveList) eq 1)
        ...    UE_1:NR-RRC_RRCReconfigurationComplete as A4_start
        ...    UE_1:NR-RRC_RRCReconfiguration (measIdToAddModList contains (1) and length(measIdToAddModList) eq 1) as A4_stop
        ...    UE_1:NR-RRC_RRCReconfigurationComplete
        ...    alias=NR_DC_FlOW_HB4a
        ...    overall_timeout=50

Wait For A4 Supervision Timer Expiration
    Sleep    ${A4_SUPERVISION_TIMER}

Wait For A4 Retry Timer Expiration
    Sleep    ${A4_RETRY_TIMER}

Verify test conditions
    Verify if A4 retry timer expired after correct time

Verify if A4 retry timer expired after correct time
    Verify delay between messages
        ...    reference_flow_alias=NR_DC_FlOW_HB4a
        ...    reference_message_alias=A4_start
        ...    flow_alias=NR_DC_FlOW_HB4a
        ...    message_alias=A4_stop
        ...    expected_diff_time=${A4_RETRY_TIMER}
        ...    tolerance=1.5
