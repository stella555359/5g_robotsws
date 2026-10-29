*** Settings ***
Suite Setup       Suite setup
Suite Teardown    Teardown Suite
Force Tags
...    PY36
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC002479/Resources/OAMKPI_Cloud_Resource.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Documentation
...    Author:
...    Contact:
...    squad
...    Feature
*** Test Cases ***
 ###-----------------------------------pod recovery--------------------------------------
vDU_Pod_oamconfigResiliency
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUNRTSResiliency']['retry_times']}
    ...    func=KW.LoopForvDUNRTSResiliency
#vDUcprtResiliency
#    [Setup]     Run Keyword     log to console     CaseStart
#    [Teardown]  Run Keyword     log to console     CaseStop
#    @{kpiList}    create list    KPI1a
#    TC.BaseLoopOperation
#    ...    kpiList=${kpiList}
#    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamkpianalyzerResiliency']['retry_times']}
#    ...    func=KW.LoopForvDUcprtResiliency
vDU_Pod_l2nrtResiliency
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUl2nrtResiliency']['retry_times']}
    ...    func=KW.LoopForvDUl2nrtResiliency
vDU_Pod_ahmResiliency
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUahmResiliency']['retry_times']}
    ...    func=KW.LoopForvDUahmResiliency
#vDU_Pod_l2rtResiliency
#    [Setup]     Run Keyword     log to console     CaseStart
#    [Teardown]  Run Keyword     log to console     CaseStop
#    @{kpiList}    create list    KPI1a
#    TC.BaseLoopOperation
#    ...    kpiList=${kpiList}
#    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamkpianalyzerResiliency']['retry_times']}
#    ...    func=KW.LoopForvDUl2rtResiliency
vDU_Pod_oamasmResiliency
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamasmResiliency']['retry_times']}
    ...    func=KW.LoopForvDUoamasmResiliency
#vDU_Pod_oambbResiliency
#    [Setup]     Run Keyword     log to console     CaseStart
#    [Teardown]  Run Keyword     log to console     CaseStop
#    @{kpiList}    create list    KPI1a
#    TC.BaseLoopOperation
#    ...    kpiList=${kpiList}
#    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamkpianalyzerResiliency']['retry_times']}
#    ...    func=KW.LoopForvDUoambbResiliency
#vDU_Pod_oamcalcResiliency
#    [Setup]     Run Keyword     log to console     CaseStart
#    [Teardown]  Run Keyword     log to console     CaseStop
#    @{kpiList}    create list    KPI1a
#    TC.BaseLoopOperation
#    ...    kpiList=${kpiList}
#    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamkpianalyzerResiliency']['retry_times']}
#    ...    func=KW.LoopForvDUoamcalcResiliency
vDU_Pod_oamcmResiliency
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamcmResiliency']['retry_times']}
    ...    func=KW.LoopForvDUoamcmResiliency
#vDU_Pod_oamextResiliency
#    [Setup]     Run Keyword     log to console     CaseStart
#    [Teardown]  Run Keyword     log to console     CaseStop
#    @{kpiList}    create list    KPI1a
#    TC.BaseLoopOperation
#    ...    kpiList=${kpiList}
#    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamkpianalyzerResiliency']['retry_times']}
#    ...    func=KW.LoopForvDUoamextResiliency
#vDU_Pod_oamfhResiliency
#    [Setup]     Run Keyword     log to console     CaseStart
#    [Teardown]  Run Keyword     log to console     CaseStop
#    @{kpiList}    create list    KPI1a
#    TC.BaseLoopOperation
#    ...    kpiList=${kpiList}
#    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamkpianalyzerResiliency']['retry_times']}
#    ...    func=KW.LoopForvDUoamfhResiliency
vDU_Pod_oamfmResiliency
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamfmResiliency']['retry_times']}
    ...    func=KW.LoopForvDUoamfmResiliency
vDU_Pod_oamkpianalyzerResiliency
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamkpianalyzerResiliency']['retry_times']}
    ...    func=KW.LoopForvDUoamkpianalyzerResiliency
vDU_Pod_oampmResiliency
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoampmResiliency']['retry_times']}
    ...    func=KW.LoopForvDUoampmResiliency
vDU_Pod_oamswmResiliency
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamswmResiliency']['retry_times']}
    ...    func=KW.LoopForvDUoamswmResiliency
#vDU_Pod_rcpsdlResiliency
#    [Setup]     Run Keyword     log to console     CaseStart
#    [Teardown]  Run Keyword     log to console     CaseStop
#    @{kpiList}    create list    KPI1a
#    TC.BaseLoopOperation
#    ...    kpiList=${kpiList}
#    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamkpianalyzerResiliency']['retry_times']}
#    ...    func=KW.LoopForvDUrcpsdlResiliency
vDU_Pod_remotestorageResiliency
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUremotestorageResiliency']['retry_times']}
    ...    func=KW.LoopForvDUremotestorageResiliency
vDU_Pod_securestorageResiliency
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUsecurestorageResiliency']['retry_times']}
    ...    func=KW.LoopForvDUsecurestorageResiliency
#vDU_Pod_trsconfigResiliency
#    [Setup]     Run Keyword     log to console     CaseStart
#    [Teardown]  Run Keyword     log to console     CaseStop
#    @{kpiList}    create list    KPI1a
#    TC.BaseLoopOperation
#    ...    kpiList=${kpiList}
#    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamkpianalyzerResiliency']['retry_times']}
#    ...    func=KW.LoopForvDUtrsconfigResiliency
*** Keywords ***
Suite setup
    KW.SuiteSetup

Teardown Suite
    Run Keyword and Ignore Error   wait until keyword succeeds    15min    1min    KW.vDUGetSnapshot
    KW.SuiteTeardown

#-------------------------vDU resiliency  pod recovery -----------------------------------
KW.LoopForvDUNRTSResiliency
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0   ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_pod_restart     pod_name=oamconfig

KW.LoopForvDUcprtResiliency
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0   ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_pod_restart      pod_name=cprt

KW.LoopForvDUl2nrtResiliency
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0   ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_pod_restart     pod_name=l2nrt

KW.LoopForvDUahmResiliency
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0   ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_pod_restart     pod_name=ahm

KW.LoopForvDUl2rtResiliency
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0   ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_pod_restart     pod_name=l2rt

KW.LoopForvDUoamasmResiliency
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0   ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_pod_restart     pod_name=oamasm

KW.LoopForvDUoambbResiliency
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0   ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_pod_restart     pod_name=oambb

KW.LoopForvDUoamcalcResiliency
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0   ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_pod_restart     pod_name=oamcalc

KW.LoopForvDUoamcmResiliency
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0   ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_pod_restart      pod_name=oamcm

KW.LoopForvDUoamextResiliency
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0   ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_pod_restart     pod_name=oamext

KW.LoopForvDUoamfhResiliency
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0   ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_pod_restart     pod_name=oamfh

KW.LoopForvDUoamfmResiliency
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0   ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_pod_restart     pod_name=oamfm

KW.LoopForvDUoamkpianalyzerResiliency
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0   ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_pod_restart     pod_name=oamkpianalyzer

KW.LoopForvDUoampmResiliency
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0   ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_pod_restart     pod_name=oampm

KW.LoopForvDUoamswmResiliency
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0   ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_pod_restart      pod_name=oamswm

KW.LoopForvDUrcpsdlResiliency
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0   ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_pod_restart     pod_name=rcpsdl

KW.LoopForvDUremotestorageResiliency
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0   ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_pod_restart     pod_name=remotestorage

KW.LoopForvDUsecurestorageResiliency
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0   ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_pod_restart     pod_name=securestorage

KW.LoopForvDUtrsconfigResiliency
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0   ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_pod_restart     pod_name=trsconfig


