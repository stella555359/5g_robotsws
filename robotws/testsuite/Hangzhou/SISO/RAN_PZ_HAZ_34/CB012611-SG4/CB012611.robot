*** Settings ***
Suite Setup          CB012611-ute_cloud Suite Setup
Suite Teardown       CB012611-G Suite Teardown
Test Timeout         400 min

Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB012611-SG4/Resource/CB012611_common_keyword.robot



Documentation
...    Author: zhichao shu
...    Contact: zhichao.shu@nokia-sbell.com
...    squad group:Mmw_SG04
...    Feature Owner: Shu Zhichao
...    Feature CB012611

Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED
*** Variables ***
@{ru_serial_list}    EB2245R1272

*** Test Cases ***
[1]CB012611-SR-B-01_1supercell_6subcells_Single_loki_permanent_failure_at_runtime
    [Setup]    CB012611-G Case Setup
    1supercell_6subcells_Single_loki_permanent_failure_at_runtime
    [Teardown]    CB012611-G Case Teardown

[1]CB012611-SR-B-02_3supercell_2subcells_Single_loki_permanent_failure_at_runtime
    [Setup]    CB012611-G Case Setup
    3supercell_2subcells_Single_loki_permanent_failure_at_runtime
    [Teardown]    CB012611-G Case Teardown

[1]CB012611-SR-B-03_1supercell_6subcells_Single_loki_failed_BTS_startup_with_ABIO
    [Setup]    CB012611-G Case Setup
    1supercell_6subcells_Single_loki_failed_BTS_startup_with_ABIO
    [Teardown]    CB012611-G Case Teardown

[1]CB012611-SR-B-04_2supercell_3subcells_Single_loki_failed_BTS_startup_with_ABIO
    [Setup]    CB012611-G Case Setup
    2supercell_3subcells_Single_loki_failed_BTS_startup_with_ABIO
    [Teardown]    CB012611-G Case Teardown

[1]CB012611-SR-B-07_2supercell_3subcells_Reset_of_ABIO_with_single_failed_Loki
    [Setup]    CB012611-G Case Setup
    2supercell_3subcells_Reset_of_ABIO_with_single_failed_Loki
    [Teardown]    CB012611-G Case Teardown