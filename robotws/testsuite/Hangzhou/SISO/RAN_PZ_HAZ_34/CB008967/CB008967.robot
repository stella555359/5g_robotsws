*** Settings ***
Documentation      author: Caoli Hu
...                 contact: caoli.hu@nokia-sbell.com
...                This robot file is for CB008967

Suite Setup       Setup Suite
Suite Teardown    Teardown Suite
Force Tags         PY36
Resource           CB008967_Resource.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Test Cases ***
[1] CB008967_SR_E_SBTS_SFP_SM_AVG_TEMPERATURE
     [Documentation]
     [Tags]     CRT_TRUNK
     [Setup]   Setup case
     [Teardown]   Run Keywords    robot_common_operations.Common Case Teardown    AND   Teardown case
     TC.CB008967_SR_E_SBTS_SFP_SM_AVG_TEMPERATURE



[1] CB008967_SR_I_AEHC_SBTS_RMOD_MAX_FANSPEED_activation_deactivation
     [Documentation]
     [Tags]     CRT_TRUNK
     [Setup]   Setup case
     [Teardown]   Run Keywords    robot_common_operations.Common Case Teardown    AND   Teardown case
     TC.CB008967_SR_I_AEHC_SBTS_RMOD_MAX_FANSPEED_activation_deactivation



[1]CB008967-SR-B_8_fault 4792_ EFaultId_CabinetLowTempViolationAl-deactivation_Dualcore
     [Documentation]
     [Tags]     CRT_TRUNK
     [Setup]   Setup case
     [Teardown]   Run Keywords    robot_common_operations.Common Case Teardown    AND   Teardown case
     TC.CB008967-SR-B_8_fault 4792_ EFaultId_CabinetLowTempViolationAl-deactivation_Dualcore


[1]CB008967-SR-F_1_Exploratory_Testing
     [Documentation]
     [Tags]     CRT_TRUNK
     [Setup]   Setup case
     [Teardown]   Run Keywords    robot_common_operations.Common Case Teardown    AND   Teardown case
     TC.CB008967-SR-F_1_Exploratory_Testing