*** Settings ***
Documentation   :copyright: Nokia
...             :author   : Anandapriya Mani
...             :contact  : anandapriya.mani@nokia.com
...             The aim of the feature is to verify scheduling is stopped for
...             old UE context with cause GHOSTUERELEASE

Resource     ${CURDIR}/resources/Keywords/CNI127390_KW.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Suite teardown for 127390

*** Variables ***
${UE_ID}      1
${UE_ID_51}     52
${rad_parameter}        0x58057A=4;0x58057F=0x1800;0x5809B8=1
${BTSLOG}      btslog

*** Test Cases ***
[1][1.0] CNI127390_A_4_Verify scheduling is stopped for old(Ghost) UE context at U-plane in TDD SA configuration
    [Documentation]     The purpose of this test case is to verify scheduling is stopped for
    ...                 old UE context with cause GHOSTUERELEASE
    [Tags]    QC_107547   QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Prepare Test Case For CNI127390_A
    Log To Console    Starting TestCase...
    start Btslogs from Local machine      ${BTSLOG}
    Log to console  Registering UE
    Run Keyword And Ignore Error    Make SA Call    ${UE_ID}    ${GW_ID}
    Sleep    10s
    wtsrunner.ue_ng_ctx_release    by=amf    id=1    cause=NAS_normal_release
    Sleep    10s
    Log to console  create testmode profile for msg4 dtx and activate
    wtsrunner.cont_res_testmode_nr    profile_id=1     msg4_dtx=20
    wtsrunner.ue_testmode_set_nr    id=1    action=activate    testmode=contention_resolution    profile_id=1
    Sleep    10s
    wtsrunner.ue_im_exit    id=1
    Sleep    10s
    Stops Btslogs from Local machine    ${BTSLOG}
    Empty Directory    ${LOG_PATH}
    Copy Directory    /tmp/btslog2    ${LOG_PATH}
    Empty Directory    /tmp/btslog2
    Validate GHOSTUERELEASE in Syslog
    [Teardown]      RAT block unblock

[1][1.0] CNI127390_B_C_1_Verify RRC Processing Delay is applied for all SRB AUGs during UE attach procedure for FDD SA call
    [Documentation]     The purpose of this test case is to verify rrc processing delay
    [Tags]    QC_107546   QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Prepare Test Case For CNI127390_B
    Log To Console    Starting TestCase...
    Start Btslogs from Local machine      ${BTSLOG}
    Sleep    10s
    Log to console  Registering UE
    FOR    ${i}    IN RANGE    51    ${UE_ID_51}
        Run Keyword And Ignore Error    Make SA Call    ${i}    1
    END
    Sleep    10s
    Stops Btslogs from Local machine    ${BTSLOG}
    Empty Directory    ${LOG_PATH}
    Copy Directory    /tmp/btslog2    ${LOG_PATH}
    Empty Directory    /tmp/btslog2
    Validate rrcDelay in Syslog
    Validate rrccontainertype in logs
    [Teardown]      RAT block unblock
