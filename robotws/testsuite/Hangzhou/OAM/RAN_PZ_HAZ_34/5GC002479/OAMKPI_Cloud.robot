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
#TEST
#    [Setup]     Run Keyword     TestCase.Start
#    [Teardown]  Run Keyword     TestCase.Stop
#    @{kpiList}    create list    KPI1a
#    TC.BaseLoopOperation
#    ...    kpiList=${kpiList}
#    ...    times=${1}
#    ...    func=KW.LoopForvCUResiliency
vCUReset
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_OAMKPI_CLOUD['vCUReset']['retry_times']}
    ...    func=KW.LoopForvCUReset

vDUReset
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_OAMKPI_CLOUD['vDUReset']['retry_times']}
    ...    func=KW.LoopForvDUReset

vDURUReset
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_OAMKPI_CLOUD['vDURUReset']['retry_times']}
    ...    func=KW.LoopForvDURUReset

vCUCellReset
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_OAMKPI_CLOUD['vCUCellReset']['retry_times']}
    ...    func=KW.LoopForvCUCellReset

vCUX2LockUnlock
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_OAMKPI_CLOUD['vCUX2LockUnlock']['retry_times']}
    ...    func=KW.LoopForvCUX2LockUnlock

vCUDULockUnlock
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_OAMKPI_CLOUD['vCUDULockUnlock']['retry_times']}
    ...    func=KW.LoopForvCUDULockUnlock

#vCUDeltaPlan
#    [Setup]     Run Keyword     log to console     CaseStart
#    [Teardown]  Run Keyword     log to console     CaseStop
#    @{kpiList}    create list    KPI1a
#    TC.BaseLoopOperation
#    ...    kpiList=${kpiList}
#    ...    times=${CASE_INPUT_OAMKPI_CLOUD['vDURUReset']['retry_times']}
#    ...    func=KW.LoopForvCUDeltaPlan
#----------------------------------------------------------------------------------
vDURULockUnlock
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_OAMKPI_CLOUD['vDURULockUnlock']['retry_times']}
    ...    func=KW.LoopForvDURULockUnlock

vDUCellLockUnlock
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_OAMKPI_CLOUD['vDUCellLockUnlock']['retry_times']}
    ...    func=KW.LoopForvDUCellLockUnlock

vDUCellBlockUnblock
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_OAMKPI_CLOUD['vDUCellBlockUnblock']['retry_times']}
    ...    func=KW.LoopForvDUCellBlockUnblock

vDURannicReset
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_OAMKPI_CLOUD['vDURannicReset']['retry_times']}
    ...    func=KW.LoopForvDURannicReset

vDUALDReset
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_OAMKPI_CLOUD['vDUALDReset']['retry_times']}
    ...    func=KW.LoopForvDUALDReset

vDUDeltaPlan
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_OAMKPI_CLOUD['vDUDeltaPlan']['retry_times']}
    ...    func=KW.LoopForvDUDeltaPlan

vDUFullPlan
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_OAMKPI_CLOUD['vDUFullPlan']['retry_times']}
    ...    func=KW.LoopForvDUFullPlan

vCUDeltaPlan
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_OAMKPI_CLOUD['vCUDeltaPlan']['retry_times']}
    ...    func=KW.LoopForvCUDeltaPlan

vCUFullPlan
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_OAMKPI_CLOUD['vCUFullPlan']['retry_times']}
    ...    func=KW.LoopForvCUFullPlan

vCUCellLockUnlock
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_OAMKPI_CLOUD['vCUCellLockUnlock']['retry_times']}
    ...    func=KW.LoopForvCUCellLockUnlock

vCUNGLockUnlock
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_OAMKPI_CLOUD['vCUNGLockUnlock']['retry_times']}
    ...    func=KW.LoopForvCUNGLockUnlock

vDUDeltaPlanWithBlocking
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_OAMKPI_CLOUD['vDUDeltaPlanWithBlocking']['retry_times']}
    ...    func=KW.LoopForvDUDeltaPlanWithBlocking

vDUDeltaPlanWithSiteReset
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_OAMKPI_CLOUD['vDUDeltaPlanWithSiteReset']['retry_times']}
    ...    func=KW.LoopForvDUDeltaPlanWithSiteReset


vDURUPowerReset
    [Setup]     Run Keyword     log to console     CaseStart
    [Teardown]  Run Keyword     log to console     CaseStop
    @{kpiList}    create list    KPI1a
    TC.BaseLoopOperation
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_OAMKPI_CLOUD['vDURUPowerReset']['retry_times']}
    ...    func=KW.LoopForPowerReset
#-------------------------vCU resiliency-----------------------------------
*** Keywords ***
Suite setup
    KW.SuiteSetup

Teardown Suite
    Run Keyword and Ignore Error   wait until keyword succeeds    10min    1min    KW.vCUCollectLog
    Run Keyword and Ignore Error   wait until keyword succeeds    15min    1min    KW.vDUGetSnapshot
    KW.SuiteTeardown
