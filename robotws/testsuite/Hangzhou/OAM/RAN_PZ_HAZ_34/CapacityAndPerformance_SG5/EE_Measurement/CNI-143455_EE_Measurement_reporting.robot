*** Settings ***
Suite Setup       SISO Coam Suite Setup
Suite Teardown    SISO Coam Suite Teardown
Test Setup        SISO Coam Test Setup
Test Teardown     SISO Coam Test Teardown

Documentation
...   author: Jeffrey Shi
...   contact: jeffrey.Shi@nokia-sbell.com

Resource    taf/rfrl/procedures/SISO/test_models/etsi/resources/Test_Model.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot

*** Test Cases ***
[1]EE_Measurement_reporting
    gnbbbu.connect
    Run Energy Efficiency Measurement Procedure
    ...    connection=REST_GNB0_DU0
#    ...    cells=NRCELL-1
#    ...    rus=RMOD-1
#    ...    test_model_duration=900
#    ...    load_levels=load_70
    Run Keyword and Ignore Error    taf.sw.reporting_portal.Set Reference Configuration Id    CNF_EE_9b