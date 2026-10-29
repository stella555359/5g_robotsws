*** Settings ***
Suite Setup          run keywords    CB013664 CBRS Suite Setup    AND    Get btsName
Suite Teardown       CB013664 CBRS Suite Teardown
Test Setup           CB013664 CBRS Test Setup
Test Teardown        CB013664 CBRS Test Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    resources/CB013664_common_keywords.robot

Documentation
...    Author:linjiangjing
...    contact:jiangjing.lin@nokia-sbell.com
...    squad group:SG_08
...    Feature CB013664

Force Tags    SBTS00
...   PY36

*** Test Cases ***
[1]CB013664_E_04_N_type_redundancy_configuration_fiber_broken_SWO
    CB013664_E_04_N_type_redundancy_configuration_fiber_broken_SWO

[1]CB013664_A_03_N_type_configuration_RU_failure_test_CBRS
    CB013664_configuration_RU_failure_test_CBRS    configuration=A

[1]CB013664_C_03_H_type_configuration_RU_failure_test_CBRS
    CB013664_configuration_RU_failure_test_CBRS    configuration=C
