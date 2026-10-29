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

*** Test Cases ***
CB008717_H_B3a_De_Configure_NR_DC_Inter_Freq_A4_Measurements_When_A4_Supervision_Timer_Expires_No_DRX
    Prepare Flow Check
    Attach UE And Establish PDU Session    ue_id=1    cell_id=1    enb_id=2
    Wait For A4 Supervision Timer Expiration
    Check If Flow occurred as expected    scenario=HB3a

*** Keywords ***
Prepare Flow Check
    Expect message flow
        ...    UE_1:NR-RRC_RRCReconfiguration (radioBearerConfig is not present)
        ...    UE_1:NR-RRC_RRCReconfigurationComplete
        ...    UE_1:NR-RRC_RRCReconfiguration (measIdToRemoveList contains (1) and length(measIdToRemoveList) eq 1)
        ...    UE_1:NR-RRC_RRCReconfigurationComplete
        ...    alias=NR_DC_FlOW_HB3a
        ...    overall_timeout=20

Wait For A4 Supervision Timer Expiration
    Sleep    9s
