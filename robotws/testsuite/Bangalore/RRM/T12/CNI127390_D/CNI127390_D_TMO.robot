*** settings ***
Documentation   :copyright: Nokia
...             :author   : Anandapriya Mani
...             :contact  : anandapriya.mani@nokia.com
...             The aim of the feature is to Verify RRC Processing Delay for all SRB AUGs

Resource     ${CURDIR}/resources/Keywords/CNI127390_KW.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Suite teardown for 127390

*** Variables ***
${UE_ID}      11
${rad_parameter}        0x58057A=4;0x58057F=0x1800;0x5809B8=1
${BTSLOG}      btslog

*** Test Cases ***
[1][1.0] CNI127390_TMOUS_CVR_002_With_CNI_enabled_Verify_rrcreconfigdelay_SA_call_and_VoNR_call1
    [Documentation]     The purpose of this test case is to verify rrcdelay for rrcreconfiguration messages
    [Tags]    QC_220628   QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Prepare Test Case For CNI127390_B_TMO
    Log To Console    Starting TestCase...
    Start Btslogs from Local machine      ${BTSLOG}
    Sleep    10s
    Log to console  Registering UE
    FOR    ${i}    IN RANGE    1    ${UE_ID}
        Run Keyword And Ignore Error    Make SA Call    ${i}    1
    END
    Sleep    10s
    Stops Btslogs from Local machine    ${BTSLOG}
    Empty Directory    ${LOG_PATH}
    Copy Directory    /tmp/btslog2    ${LOG_PATH}
    Empty Directory    /tmp/btslog2
    Validate rrcDelay in Syslog
    [Teardown]      Run Keyword And Ignore Error      Common Test Case Tear Down LO AP LO
