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
#-------------------------vDU resiliency  process recovery -----------------------------------
vDU_Process_oamconfig_CPCONFIG_Resiliency
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamconfigCPCONFIGProcess']['retry_times']}
    ...    func=KW.LoopForvDU_oamconfig_CPCONFIG

vDU_Process_oamconfig_TRSCONFIG_Resiliency
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamconfigTRSCONFIGProcess']['retry_times']}
    ...    func=KW.LoopForvDU_oamconfig_TRSCONFIG

vDU_Porcess_oamconfig_NTS_Resiliency
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamconfigNTSProcess']['retry_times']}
    ...    func=KW.LoopFor_oamconfig_NTS

vDU_Process_oamconfig_TAS_Resiliency
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamcofigTASProcess']['retry_times']}
    ...    func=KW.LoopFor_oamconfig_TAS

vDU_Process_oamconfig_IMS_Resiliency
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamcofigImsProcess']['retry_times']}
    ...    func=KW.LoopFor_oamconfig_IMS

vDU_Process_oamconfig_IMSNAPSHOT_Resiliency
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamcofigIMSNAPSHOTProcess']['retry_times']}
    ...    func=KW.LoopFor_oamconfig_IMSNAPSHOT

vDU_Process_oamconfig_FaultServiceExe_Resiliency
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamcofigFaultServiceExeProcess']['retry_times']}
    ...    func=KW.LoopFor_oamconfig_FaultServiceExe

vDU_Process_oamconfig_MED_Resiliency
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamcofigMEDProcess']['retry_times']}
    ...    func=KW.LoopFor_oamconfig_MED

vDU_Process_oamfm_fm_Resiliency
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamfmfmProcess']['retry_times']}
    ...    func=KW.LoopFor_oamfm_fm

vDU_Process_oamkpianalyzer_KPIanalyzer_Resiliency
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamkpianalyzerProcess']['retry_times']}
    ...    func=KW.LoopFor_oamkpianalyzer_KPIanalyzer

vDU_Process_oamswm_KPIanalyzer_Resiliency
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamswmKPIanalyzerProcess']['retry_times']}
    ...    func=KW.LoopFor_oamswm_KPIanalyzer

vDU_Process_oamcm_cm_Resiliency
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamcmCMProcess']['retry_times']}
    ...    func=KW.LoopFor_oamcm_cm

vDU_Process_oamcm_cmservice_Resiliency
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamcmCMserviceProcess']['retry_times']}
    ...    func=KW.LoopFor_oamcm_cmservice

vDU_Process_oamasm_asm_Resiliency
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamasmASMProcess']['retry_times']}
    ...    func=KW.LoopFor_oamasm_asm

vDU_Process_oamasm_FaultServiceExe_Resiliency
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamasmFaultServicesExeProcess']['retry_times']}
    ...    func=KW.LoopFor_oamasm_FaultServiceExe

vDU_Process_oamasm_emservice_Resiliency
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamasmEmsrviceProcess']['retry_times']}
    ...    func=KW.LoopFor_oamasm_emservice

vDU_Process_oampm_pmstat_Resiliency
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoampmPMstatProcess']['retry_times']}
    ...    func=KW.LoopFor_oampm_pmstat

vDU_Process_oampm_PMDataServer_Resiliency
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoampmPMDataseverProcess']['retry_times']}
    ...    func=KW.LoopFor_oampm_PMDataServer

vDU_Process_oambb_IMSNAPSHOT_Resiliency
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoambbIMSNAPSHOTProcess']['retry_times']}
    ...    func=KW.LoopFor_oambb_IMSNAPSHOT

vDU_Process_oamfh_MED_Resiliency
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamfhMEDProcess']['retry_times']}
    ...    func=KW.LoopFor_oamfh_MED

vDU_Process_oamfh_IMSNAPSHOT_Resiliency
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamfhIMSNAPSHOTProcess']['retry_times']}
    ...    func=KW.LoopFor_oamfh_IMSNAPSHOT

vDU_Process_oamfh_NETCONF_Resiliency
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamfhNETCONFProcess']['retry_times']}
    ...    func=KW.LoopFor_oamfh_NETCONF

vDU_Process_oamext_OAMAgent_Resiliency
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamextoamagentProcess']['retry_times']}
    ...    func=KW.LoopFor_oamext_OAMAgent

vDU_Process_oamext_TCConfigurator_Resiliency
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamextTCConfiguratorProcess']['retry_times']}
    ...    func=KW.LoopFor_oamext_TCConfigurator

vDU_Process_oamext_TCMaster_Resiliency
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamextTCMasterProcess']['retry_times']}
    ...    func=KW.LoopFor_oamext_TCMaster

#vDU_oamext_ne3sadapt_Resiliency
#    [Setup]     Run Keyword     log to console     CaseStart
#    [Teardown]  Run Keyword     log to console     CaseStop
#    @{kpiList}    create list    KPI1a
#    TC.BaseLoopOperation
#    ...    kpiList=${kpiList}
#    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamextne3sadaptProcess']['retry_times']}
#    ...    func=KW.LoopFor_oamext_ne3sadapt

vDU_Process_oamext_cnumserver_Resiliency
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamextcnumserverProcess']['retry_times']}
    ...    func=KW.LoopFor_oamext_cnumserver

vDU_Process_oamcalc_imsnapshot_Resiliency
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vDU_Resiliency['vDUoamcalcimsnapshotProcess']['retry_times']}
    ...    func=KW.LoopFor_oamcalc_imsnapshot

*** Keywords ***
Suite setup
    KW.SuiteSetup

Teardown Suite
    wait until keyword succeeds    20min    1min    KW.vDUGetSnapshot
    KW.SuiteTeardown

####################################### KW for process resiliency  #######################################
KW.LoopForvDU_oamconfig_CPCONFIG
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_process_resiliency     pod_name=oamconfig    container_name=oamconfig    processpath=/opt/nokia/SS_OAM/CPCONFIG/CPCONFIG

KW.LoopForvDU_oamconfig_TRSCONFIG
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_process_resiliency     pod_name=oamconfig    container_name=oamconfig    processpath=/opt/nokia/SS_OAM/TRSCONFIG

KW.LoopFor_oamconfig_NTS
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_process_resiliency     pod_name=oamconfig    container_name=oamconfig    processpath=/opt/nokia/SS_OAM/NTS/NTS

KW.LoopFor_oamconfig_TAS
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_process_resiliency     pod_name=oamconfig    container_name=oamconfig    processpath=/opt/nokia/SS_OAM/TAS/TAS

KW.LoopFor_oamconfig_IMS
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_process_resiliency     pod_name=oamconfig    container_name=oamconfig    processpath=/opt/ims/ims

KW.LoopFor_oamconfig_IMSNAPSHOT
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_process_resiliency     pod_name=oamconfig    container_name=oamconfig    processpath=/opt/nokia/SS_OAM/IMSNAPSHOT/IMSNAPSHOT

KW.LoopFor_oamconfig_FaultServiceExe
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_process_resiliency     pod_name=oamconfig    container_name=oamconfig    processpath=/usr/bin/FaultServiceExe

KW.LoopFor_oamconfig_MED
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_process_resiliency     pod_name=oamconfig    container_name=oamconfig    processpath=/opt/nokia/SS_OAM/MED/MED

KW.LoopFor_oamfm_fm
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_process_resiliency      pod_name=oamfm    container_name=oamfm    processpath=/opt/nokia/SS_OAM/FM/fmvdu.json

KW.LoopFor_oamkpianalyzer_KPIanalyzer
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_process_resiliency     pod_name=oamkpianalyzer   container_name=oamkpianalyzer
    ...    processpath=/opt/nokia/SS_OAM/KPIanalyzer/KPIanalyzervdu

KW.LoopFor_oamswm_KPIanalyzer
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_process_resiliency      pod_name=oamswm   container_name=oamswm    processpath=/opt/nokia/SS_OAM/OAMSWM/oamswmvdu.json

KW.LoopFor_oamcm_cm
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_process_resiliency     pod_name=oamcm   container_name=oamcm    processpath=/opt/nokia/SS_OAM/OAMCM/oamcm.json

KW.LoopFor_oamcm_cmservice
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_process_resiliency     pod_name=oamcm   container_name=oamcm    processpath=/opt/nokia/SS_OAM/CMSERVICE/cmservice.json

KW.LoopFor_oamasm_asm
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU     vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_process_resiliency     pod_name=oamasm   container_name=oamasm    processpath=/opt/nokia/SS_OAM/ASM/asmvdu.json

KW.LoopFor_oamasm_FaultServiceExe
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_process_resiliency     pod_name=oamasm   container_name=oamasm    processpath=/usr/bin/FaultServiceExe

KW.LoopFor_oamasm_emservice
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_process_resiliency     pod_name=oamasm   container_name=oamembe    processpath=/opt/nokia/SS_OAM/EMSERVICE/emservicevdu.json

KW.LoopFor_oampm_pmstat
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_process_resiliency     pod_name=oampm   container_name=oampm    processpath=/opt/nokia/SS_OAM/PMStat/PMStatvdu.json

KW.LoopFor_oampm_PMDataServer
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_process_resiliency     pod_name=oampm   container_name=pmdataserver
    ...    processpath=/opt/nokia/SS_OAM/PMDataServer/PMDataServervdu.json

KW.LoopFor_oambb_IMSNAPSHOT
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_process_resiliency     pod_name=oambb   container_name=oambb    processpath=/opt/nokia/SS_OAM/IMSNAPSHOT/IMSNAPSHOT

KW.LoopFor_oamfh_MED
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_process_resiliency     pod_name=oamfh   container_name=oamfh   processpath=/opt/nokia/SS_OAM/MED/medfhvdu.json

KW.LoopFor_oamfh_IMSNAPSHOT
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_process_resiliency     pod_name=oamfh   container_name=oamfh   processpath=/opt/nokia/SS_OAM/IMSNAPSHOT/IMSNAPSHOT

KW.LoopFor_oamfh_NETCONF
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_process_resiliency     pod_name=oamfh   container_name=oamfh   processpath=/opt/nokia/SS_OAM/NETCONF/NETCONF

KW.LoopFor_oamext_OAMAgent
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_process_resiliency     pod_name=oamext   container_name=oamagent   processpath=/opt/nokia/SS_OAM/OAMAGENT/agent_oam.json

KW.LoopFor_oamext_TCConfigurator
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_process_resiliency     pod_name=oamext   container_name=tracecontroller   processpath=/usr/bin/TC-Configurator

KW.LoopFor_oamext_TCMaster
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_process_resiliency     pod_name=oamext   container_name=tracecontroller   processpath=/usr/bin/TC-Master-NR

#KW.LoopFor_oamext_ne3sadapt
#    [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
#    log to console    ${loop}
#    Wait Until Keyword Succeeds  10min   5s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
#    KW.Check_process_resiliency     pod_name=oamext   container_name=ne3sadapt   processpath=/opt/nokia/SS_OAM/NE3SADAPT/NE3SADAPT

KW.LoopFor_oamext_cnumserver
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_process_resiliency     pod_name=oamext   container_name=cnumserver   processpath=/usr/bin/cnumserver

KW.LoopFor_oamcalc_imsnapshot
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.Check_process_resiliency     pod_name=oamcalc   container_name=oamcalc   processpath=/opt/nokia/SS_OAM/IMSNAPSHOT/IMSNAPSHOT
