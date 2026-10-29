*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO

Documentation   :copyright: Nokia
...             :authors: Joanna Kogut-Malarczyk
...             :contact: joanna.kogut-malarczyk@nokia.com

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
${LOGGING_POLICY}=    SYSLOG_POLICY
${IPHY}=              ${CURDIR}/config/CB008717_JC/iphy_n78A_n257A_BOO_AP_LOO.xml
${SCFC}=              scf_JC_B12a_n78A_n257A_BOO_LOO.xml
${EGATE}=             ${CURDIR}/config/CB008717_JC/BOO_AP_LOO_n78_N257_JCB12a.cfg

*** Test Cases ***
CB008717_JC_B12a_Handling_Of_UE_Inactivity_Timer_Expiry_When_UE_Is_In_NR-DC_Mode
    Prepare Flow Check For JC_B12a And Configure RLF Testmode NR   scenario=JC_B12a    ue_id=UE_1
    Attach UE And Establish PDU Session    ue_id=1    cell_id=1    enb_id=2
    Send a4 measurement
    Verify Flow Context For JC_B12a    scenario=JC_B12a
    Verify Messages For JC_B12a Scenario
    [Teardown]    Deregister Ue    ue_id=1

*** Keywords ***

Send a4 measurement
    Execute Egate Command    cmd=ue_measurement_send_nr id=1 meas_id=1 phycell_id=52 nrsrp_nr=60 event=A4

Prepare Flow Check For JC_B12a And Configure RLF Testmode NR
    [Arguments]    ${scenario}    ${ue_id}
    Expect message flow
    ...    gNB:E1AP_BearerContextInactivityNotification
    ...    gNB:NGAP_UEContextReleaseRequest
    ...    gNB:NGAP_UEContextReleaseCommand
    ...    gNB:E1AP_BearerContextReleaseCommand
    ...    gNB:F1AP_UEContextReleaseCommand
    ...    gNB:E1AP_BearerContextReleaseComplete
    ...    gNB:F1AP_UEContextReleaseComplete
    ...    gNB:NGAP_UEContextReleaseComplete
    ...    alias=NR_DC_FlOW_${scenario}
    ...    overall_timeout=60
    Execute Egate Command     cmd=rlf_testmode_nr profile_id=6 num_stop_csi_report=1000 num_stop_dlharq_tx=2000

Verify Flow Context For JC_B12a
    [Arguments]    ${scenario}
    Check If Flow occurred as expected    scenario=${scenario}

Verify Messages For JC_B12a Scenario
    Verify Tcpdump Log      ${E1AP_BEARER_CONTEXT_INACTIVITY_NOTIFICATION}
    Verify Tcpdump Log      ${NGAP_UE_CONTEXT_RELEASE_REQUEST_FOR_JC_B12a}


