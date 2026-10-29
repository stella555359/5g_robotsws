*** Settings ***
Suite Setup       Suite setup
Suite Teardown    Teardown Suite
Force Tags
...    PY36
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC002479/Resources/OAMKPI_Cloud_Resource.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
#Variables         ../5GC002479/Resources/5GC002479_Test.py
Documentation
...    Author:
...    Contact:
...    squad
...    Feature
*** Test Cases ***
vCUCPNBResiliency
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vCU_Resiliency['vCUCPNBResiliency']['retry_times']}
    ...    func=KW.LoopForvCUCPNBResiliency

vCUCPNRTResiliency
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vCU_Resiliency['vCUCPNRTResiliency']['retry_times']}
    ...    func=KW.LoopForvCUCPNRTResiliency

vCUNRTSResiliency
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vCU_Resiliency['vCUNRTSResiliency']['retry_times']}
    ...    func=KW.LoopForvCUNRTSResiliency

vCUCPIFResiliency
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vCU_Resiliency['vCUCPIFResiliency']['retry_times']}
    ...    func=KW.LoopForvCUCPIFResiliency

vCUCPCLResiliency
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vCU_Resiliency['vCUCPCLResiliency']['retry_times']}
    ...    func=KW.LoopForvCUCPCLResiliency

vCUCPUEResiliency
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_vCU_Resiliency['vCUCPUEResiliency']['retry_times']}
    ...    func=KW.LoopForvCUCPUEResiliency
*** Keywords ***
Suite setup
    KW.SuiteSetup

Teardown Suite
    Run Keyword and Ignore Error   wait until keyword succeeds    10min    1min    KW.vCUCollectLog
    Run Keyword and Ignore Error   wait until keyword succeeds    15min    1min    KW.vDUGetSnapshot
    KW.SuiteTeardown
