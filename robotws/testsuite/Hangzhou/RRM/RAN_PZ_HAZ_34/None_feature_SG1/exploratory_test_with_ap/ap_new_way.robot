*** Settings ***
Force Tags    PY36
Documentation
...    Author:
...    Contact:
...    squad
...    Feature

Suite Setup         Setup Suite    ${CFGFILE_PATH}/Trunk_4AEQE_23R2_IWK_ulmimo_16UE_oldbwp.xml
#Suite Teardown     Teardown Suite
Resource          ./Resource/wts_airphone_resources.robot

#  *** Variables ***
# this configuration of WTS configuration file's name already move to gnb_configuration
# ${WTS_CFG}              AAA_WTS1.cfg
# ${WTS_CFG1}              AAA_WTS2.cfg

*** Test Cases ***
RTM_testing
    [Documentation]
    [Tags]    CIT_TRUNK  CRT_TRUNK  CRT_22R2
    [Teardown]  Teardown Case    mode=${JID_MODE}
    Set Suite Variable    ${JID_MODE}    0
    Set Suite Variable    ${JID_REPORTTAG}    RTM
    Setup Case for ap  wts_cfg=${WTS_CFG1}    mode=${JID_MODE}
    Generate kpi report until success    mode=${JID_MODE}
    #Generate kpi report    report_name=VRF4_SG1_Degraded_KPIs_with_ap_part2

FixMode_testing
    [Documentation]
    [Tags]    CIT_TRUNK  CRT_TRUNK  CRT_22R2
    [Teardown]  Teardown Case   mode=${JID_MODE}
    Set Suite Variable    ${JID_MODE}    1
    Set Suite Variable    ${JID_REPORTTAG}    FixMode
    Setup Case for ap  wts_cfg=${WTS_CFG1}   mode=${JID_MODE}
    Generate kpi report until success    mode=${JID_MODE}

RTMLoopTesting
    [Documentation]
    [Tags]    CIT_TRUNK  CRT_TRUNK  CRT_22R2
    FOR    ${job}    IN    @{Jobs}
        Set Suite Variable    ${JID_LUA}     ${job["lua"]}
        Set Suite Variable    ${JID_SCF}     ${job["scf"]}
        Set Suite Variable    ${JID_IPHY}    ${job["iphy"]}
        Set Suite Variable    ${JID_MODE}    ${job["JID"]}
        Set Suite Variable    ${JID_DURATION}    ${job["TestingDuration"]}
        Set Suite Variable    ${JID_REPORTTAG}    ${job["reportTag"]}
        Set Suite Variable    ${JID_TEMPLETEID}    ${job["TempleteID"]}
        Set Suite Variable    ${JID_REPORTPREFIX}    ${job["ReportPrefix"]}

        Setup Case for ap     wts_cfg=${JID_LUA}   mode=${JID_MODE}
        Generate kpi report until success    mode=${JID_MODE}
        Teardown Case   mode=${JID_MODE}
    END
    [Teardown]  Teardown Case   mode=1