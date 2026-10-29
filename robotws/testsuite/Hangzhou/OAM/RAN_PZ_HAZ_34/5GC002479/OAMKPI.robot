*** Settings ***
Suite Setup       Run Keywords    robot_common_operations.Common Suite Setup    AND    Suite setup
Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown    AND    Teardown Suite
Force Tags
...    PY36
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC002479/Resources/OAMKPI_Resource.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
#Variables         ../5GC002479/Resources/5GC002479_Test.py

*** Test Cases ***
[1]Cell_Block_Unblock_KPI17a
    [Documentation]     KPI17a
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    TestCase.Stop
    @{kpiList}    create list    KPI17a
    TC.Cell_Block_Unblock    kpiList=${kpiList}
    ...                      times=${CASE_INPUT_5GC002479['5GC002479_HA_KPI17a']['block_times']}

#[1]Cell_Block_Unblock_KPI17b
#    [Documentation]     KPI17b
#    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start
#    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    TestCase.Stop
#    @{kpiList}    create list    KPI17b
#    TC.Cell_Block_Unblock    kpiList=${kpiList}
#    ...                      times=${CASE_INPUT_5GC002479['5GC002479_HA_KPI17b']['unblock_times']}

[1]RF_Reset_KPI51a
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    TestCase.Stop
    @{kpiList}    create list    KPI51a
    TC.RF_Reset    kpiList=${kpiList}
    ...            times=${CASE_INPUT_5GC002479['5GC002479_HA_KPI51a']['RF_reset_times']}

[1]Site_Reset_KPI1a
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    TestCase.Stop
    @{kpiList}    create list    KPI1a
    TC.Site_Reset    kpiList=${kpiList}
    ...              times=${CASE_INPUT_5GC002479['5GC002479_HA_KPI1a']['WebUI_reset_times']}

[1]BaseBand_Reset_KPI5
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    TestCase.Stop
    @{kpiList}    create list    KPI5
    TC.BaseBand_Reset    kpiList=${kpiList}
    ...                  times=${CASE_INPUT_5GC002479['5GC002479_HA_KPI5']['reset_times']}

[1]Cell_Lock_Unlock_KPI16a
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    TestCase.Stop
    @{kpiList}    create list    KPI16a
    TC.Cell_Lock_Unlock    kpiList=${kpiList}
    ...                    times=${CASE_INPUT_5GC002479['5GC002479_HA_KPI16a']['lock_times']}
#kpi2a, no matching package, case ignore
kpi2b
    #[Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start
    #[Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    TestCase.Stop
    @{kpiList}    create list    KPI2b
    TC.SW_Upgrade    kpiList=${kpiList}
    ...              OriginalStream=${CASE_INPUT_5GC002479['5GC002479_HA_KPI2b']['OriginalStream']}
    ...              OriginalStreamSCF=${CASE_INPUT_5GC002479['5GC002479_HA_KPI2b']['OriginalStreamSCF']}
    ...              TargetStreamSCF=${CASE_INPUT_5GC002479['5GC002479_HA_KPI2b']['TargetStreamSCF']}
    ...              conditions=${condition_PS_diff}
    ...              times=${CASE_INPUT_5GC002479['5GC002479_HA_KPI2b']['retrytimes']}
#[1]SW_Upgrade_KPI2c
kpi2c
    #[Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start
    #[Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    TestCase.Stop
    @{kpiList}    create list    KPI2c
    TC.SW_Upgrade    kpiList=${kpiList}
    ...              OriginalStream=${TargetBTSStream}
    ...              TargetStreamSCF=${CASE_INPUT_5GC002479['5GC002479_HA_KPI2c']['TargetStreamSCF']}
    ...              conditions=${condition_PS_same}
    ...              times=${CASE_INPUT_5GC002479['5GC002479_HA_KPI2c']['retrytimes']}

kpi2d
    #[Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start
    #[Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    TestCase.Stop
    @{kpiList}    create list    KPI2d
    TC.SW_Upgrade    kpiList=${kpiList}
    ...              OriginalStream=${TargetBTSStream}
    ...              TargetStreamSCF=${CASE_INPUT_5GC002479['5GC002479_HA_KPI2d']['TargetStreamSCF']}
    ...              conditions=${condition_PS_diff}
    ...              times=${CASE_INPUT_5GC002479['5GC002479_HA_KPI2d']['retrytimes']}

KPI12
    #[Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start
    #[Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    TestCase.Stop
    @{kpiList}    create list    KPI12
    TC.DeltaCommission
    ...    kpiList=${kpiList}
    ...    times=${CASE_INPUT_5GC002479['5GC002479_HA_KPI12']['retrytimes']}
    ...    type=WithSiteReset

#TEST2
#    #DeltaCommissionWithRATReset
#    @{kpiList}    create list    KPI12
#    TC.DeltaCommission
#    ...    kpiList=${kpiList}
#    ...    times=${CASE_INPUT_5GC002479['5GC002479_HA_KPI10']['retrytimes']}
#    ...    KPIMax=${CASE_INPUT_5GC002479['5GC002479_HA_KPI10']['KPI10_MAX']}
#    ...    type=WithRATReset

*** Keywords ***
Suite setup
    kw.suite setup for 2479    #AdaptConfigurationPath=${True}

Teardown Suite
    kw.teardown suite
