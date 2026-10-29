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
###-----------------------------------container recovery--------------------------------------
vDU_Container_Recovery_oamconfig_oamconfig
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamconfigoamconfigcontainer']['retry_times']}
    ...    func=KW.LoopFor_oamconfig_oamconfig_container

vDU_Container_Recovery_oamfm_oamfm
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamfmContainer']['retry_times']}
    ...    func=KW.LoopFor_oamfm_oamfm_container

vDU_Container_Recovery_oamkpianalyzer_oamkpianalyzer
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamkpianalyzerContainer']['retry_times']}
    ...    func=KW.LoopFor_oamkpianalyzer_oamkpianalyzer_container

vDU_Container_Recovery_oamswm_oamswm
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamswmContainer']['retry_times']}
    ...    func=KW.LoopFor_oamswm_oamswm_container

vDU_Container_Recovery_oamcm_oamcm
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamcmContainer']['retry_times']}
    ...    func=KW.LoopFor_oamcm_oamcm_container

vDU_Container_Recovery_oamasm_oamasm
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamasmContainer']['retry_times']}
    ...    func=KW.LoopFor_oamasm_oamasm_container

vDU_Container_Recovery_oamasm_oamembe
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamembeContainer']['retry_times']}
    ...    func=KW.LoopFor_oamasm_oamembe_container

vDU_Container_Recovery_oampm_oampm
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoampmContainer']['retry_times']}
    ...    func=KW.LoopFor_oampm_oampm_container

vDU_Container_Recovery_oampm_oamdispatcher
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamdispatcherContainer']['retry_times']}
    ...    func=KW.LoopFor_oampm_oamdispatcher_container

vDU_Container_Recovery_oampm_PMDataServer
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUPMDataServerContainer']['retry_times']}
    ...    func=KW.LoopFor_oampm_PMDataServer_container

vDU_Container_Recovery_oamconfig_nwmgmt
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUnwmgmtContainer']['retry_times']}
    ...    func=KW.LoopFor_oamconfig_nwmgmt_container

vDU_Container_Recovery_oamfh_sftpserver
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUsftpserverContainer']['retry_times']}
    ...    func=KW.LoopFor_oamfh_sftpserver_container

vDU_Container_Recovery_oamfh_nftmgmt
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUnftmgmtContainer']['retry_times']}
    ...    func=KW.LoopFor_oamfh_nftmgmt_container

vDU_Container_Recovery_oamfh_nwmgmt
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUnwmgmtContainer']['retry_times']}
    ...    func=KW.LoopFor_oamfh_nwmgmt_container

vDU_Container_Recovery_oamfh_dhcp
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUDHCPContainer']['retry_times']}
    ...    func=KW.LoopFor_oamfh_dhcp_container

vDU_Container_Recovery_oamext_tracecontroller
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUTracecontrollerContainer']['retry_times']}
    ...    func=KW.LoopFor_oamext_tracecontroller_container

vDU_Container_Recovery_oamext_nwmgmt
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUnwmgmtContainer']['retry_times']}
    ...    func=KW.LoopFor_oamext_nwmgmt_container

vDU_Container_Recovery_oamext_ne3sadapt
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUne3sadaptContainer']['retry_times']}
    ...    func=KW.LoopFor_oamext_ne3sadapt_container

vDU_Container_Recovery_oamext_nftmgmt
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUnftmgmtContainer']['retry_times']}
    ...    func=KW.LoopFor_oamext_nftmgmt_container

vDU_Container_Recovery_oamext_httpd
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUhttpdContainer']['retry_times']}
    ...    func=KW.LoopFor_oamext_httpd_container

vDU_Container_Recovery_oamext_logforwarder
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUlogforwarderContainer']['retry_times']}
    ...    func=KW.LoopFor_oamext_logforwarder_container

vDU_Container_Recovery_oamext_ipsecmgmt
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUipsecmgmtContainer']['retry_times']}
    ...    func=KW.LoopFor_oamext_ipsecmgmt_container

vDU_Container_Recovery_oamext_cnumserver
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUcnumserverContainer']['retry_times']}
    ...    func=KW.LoopFor_oamext_cnumserver_container

vDU_Container_Recovery_oamext_oamlssclient
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamlssclientContainer']['retry_times']}
    ...    func=KW.LoopFor_oamext_oamlssclient_container

vDU_Container_Recovery_oamext_testportserver
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUtestportserverContainer']['retry_times']}
    ...    func=KW.LoopFor_oamext_testportserver_container

vDU_Container_Recovery_oamext_oamdispatcher
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamdispatcherContainer']['retry_times']}
    ...    func=KW.LoopFor_oamext_oamdispatcher_container

vDU_Container_Recovery_oamext_ipcapturemgmt
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUipcapturemgmtContainer']['retry_times']}
    ...    func=KW.LoopFor_oamext_ipcapturemgmt_container

vDU_Container_Recovery_oamext_certman
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUcertmanContainer']['retry_times']}
    ...    func=KW.LoopFor_oamext_certman_container

vDU_Container_Recovery_cprt_nftmgmt
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUnftmgmtContainer']['retry_times']}
    ...    func=KW.LoopFor_cprt_nftmgmt_container

vDU_Container_Recovery_cprt_nwmgmt
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUnwmgmtContainer']['retry_times']}
    ...    func=KW.LoopFor_cprt_nwmgmt_container

vDU_Container_Recovery_cprt_haagent
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUhaagentContainer']['retry_times']}
    ...    func=KW.LoopFor_cprt_haagent_container

vDU_Container_Recovery_cprt_ipcapturemgmt
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUipcapturemgmtContainer']['retry_times']}
    ...    func=KW.LoopFor_cprt_ipcapturemgmt_container

vDU_Container_Recovery_l2rt_l2rt
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUl2rtContainer']['retry_times']}
    ...    func=KW.LoopFor_l2rt_l2rt_container

vDU_Container_Recovery_l2rt_nwmgmt
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUnwmgmtContainer']['retry_times']}
    ...    func=KW.LoopFor_l2rt_nwmgmt_container

vDU_Container_Recovery_l2nrt_nwmgmt
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUnwmgmtContainer']['retry_times']}
    ...    func=KW.LoopFor_l2nrt_nwmgmt_container

 vDU_Container_Recovery_l2nrt_l2hi
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUl2hiContainer']['retry_times']}
    ...    func=KW.LoopFor_l2nrt_l2hi_container

vDU_Container_Recovery_l2nrt_ipsecmgmt
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUipsecmgmtContainer']['retry_times']}
    ...    func=KW.LoopFor_l2nrt_ipsecmgmt_container

vDU_Container_Recovery_l2nrt_nftmgmt
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUnftmgmtContainer']['retry_times']}
    ...    func=KW.LoopFor_l2nrt_nftmgmt_container

vDU_Container_Recovery_ahm_l1commproxy
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUl1commproxyContainer']['retry_times']}
    ...    func=KW.LoopFor_ahm_l1commproxy_container

*** Keywords ***
Suite setup
    KW.SuiteSetup

Teardown Suite
    wait until keyword succeeds    20min    1min    KW.vDUGetSnapshot
    KW.SuiteTeardown

####----------------------KW FOR container resiliency-------------------------------
KW.LoopFor_oamconfig_oamconfig_container
   [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_container_recovery     pod_name=oamconfig   container_name=oamconfig

KW.LoopFor_oamfm_oamfm_container
   [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_container_recovery     pod_name=oamfm   container_name=oamfm

KW.LoopFor_oamkpianalyzer_oamkpianalyzer_container
   [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_container_recovery     pod_name=oamkpianalyzer   container_name=oamkpianalyzer

KW.LoopFor_oamswm_oamswm_container
   [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_container_recovery     pod_name=oamswm   container_name=oamswm

KW.LoopFor_oamcm_oamcm_container
   [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_container_recovery     pod_name=oamcm   container_name=oamcm

KW.LoopFor_oamasm_oamasm_container
   [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_container_recovery     pod_name=oamasm   container_name=oamasm

KW.LoopFor_oamasm_oamembe_container
   [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_container_recovery     pod_name=oamasm   container_name=oamembe

KW.LoopFor_oampm_oampm_container
   [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_container_recovery     pod_name=oampm   container_name=oampm

KW.LoopFor_oampm_oamdispatcher_container
   [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_container_recovery     pod_name=oampm   container_name=oamdispatcher

KW.LoopFor_oampm_PMDataServer_container
   [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_container_recovery     pod_name=oampm   container_name=pmdataserver

KW.LoopFor_oamconfig_nwmgmt_container
   [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_container_recovery     pod_name=oamconfig   container_name=nwmgmt

KW.LoopFor_oamfh_sftpserver_container
   [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_container_recovery     pod_name=oamfh   container_name=sftpserver

KW.LoopFor_oamfh_nftmgmt_container
   [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_container_recovery     pod_name=oamfh  container_name=nftmgmt

KW.LoopFor_oamfh_nwmgmt_container
   [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_container_recovery     pod_name=oamfh   container_name=nwmgmt

KW.LoopFor_oamfh_dhcp_container
   [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_container_recovery     pod_name=oamfh   container_name=dhcp

KW.LoopFor_oamext_tracecontroller_container
   [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_container_recovery     pod_name=oamext   container_name=tracecontroller

KW.LoopFor_oamext_nwmgmt_container
   [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_container_recovery     pod_name=oamext   container_name=nwmgmt

KW.LoopFor_oamext_ne3sadapt_container
   [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_container_recovery     pod_name=oamext   container_name=ne3sadapt

KW.LoopFor_oamext_nftmgmt_container
   [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_container_recovery     pod_name=oamext   container_name=nftmgmt

KW.LoopFor_oamext_httpd_container
   [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_container_recovery     pod_name=oamext   container_name=httpd

KW.LoopFor_oamext_logforwarder_container
   [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_container_recovery     pod_name=oamext   container_name=logforwarder

KW.LoopFor_oamext_ipsecmgmt_container
   [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_container_recovery     pod_name=oamext   container_name=ipsecmgmt

KW.LoopFor_oamext_cnumserver_container
   [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_container_recovery     pod_name=oamext   container_name=cnumserver

KW.LoopFor_oamext_oamlssclient_container
   [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_container_recovery     pod_name=oamext   container_name=oamlssclient

KW.LoopFor_oamext_testportserver_container
   [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_container_recovery     pod_name=oamext   container_name=testportserver

KW.LoopFor_oamext_oamdispatcher_container
   [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_container_recovery     pod_name=oamext   container_name=oamdispatcher

KW.LoopFor_oamext_ipcapturemgmt_container
   [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_container_recovery     pod_name=oamext   container_name=ipcapturemgmt

KW.LoopFor_oamext_certman_container
   [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_container_recovery     pod_name=oamext   container_name=certman

KW.LoopFor_cprt_nftmgmt_container
   [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_container_recovery     pod_name=cprt   container_name=nftmgmt

KW.LoopFor_cprt_nwmgmt_container
   [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_container_recovery     pod_name=cprt   container_name=nwmgmt

KW.LoopFor_cprt_haagent_container
   [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_container_recovery     pod_name=cprt   container_name=haagent

KW.LoopFor_cprt_ipcapturemgmt_container
   [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_container_recovery     pod_name=cprt   container_name=ipcapturemgmt

KW.LoopFor_l2rt_l2rt_container
   [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_container_recovery     pod_name=l2rt   container_name=l2rt

KW.LoopFor_l2rt_nwmgmt_container
   [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_container_recovery     pod_name=l2rt-a   container_name=nwmgmt

KW.LoopFor_l2nrt_nwmgmt_container
   [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_container_recovery     pod_name=l2nrt   container_name=nwmgmt

KW.LoopFor_l2nrt_l2hi_container
   [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_container_recovery     pod_name=l2nrt   container_name=l2hi

KW.LoopFor_l2nrt_ipsecmgmt_container
   [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_container_recovery     pod_name=l2nrt   container_name=ipsecmgmt

KW.LoopFor_l2nrt_nftmgmt_container
   [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_container_recovery     pod_name=l2nrt   container_name=nftmgmt

KW.LoopFor_ahm_l1commproxy_container
   [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_vDU_container_recovery     pod_name=ahm-a   container_name=l1commproxy