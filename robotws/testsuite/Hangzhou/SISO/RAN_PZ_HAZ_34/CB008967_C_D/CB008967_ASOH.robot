*** Settings ***
Documentation      author: Guorong Song
...                contact: guorong.song@nokia-sbell.com
...                This robot file is for CB008967

Suite Setup       Setup Suite With SCF
Suite Teardown    Teardown Suite D
Force Tags         PY36
Resource           CB008967_D_Resource.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Test Cases ***
[1]CB008967-SR-D_6_ASOH_SBTS_CAB_AVG_FANSPEED_activation_deactivation_WEBEM_NMS
     [Documentation]
     [Tags]     CRT_TRUNK
     [Setup]   Run Keywords    robot_common_operations.Common Case Setup
     ...    allowed_faults_ids=61675,1933,4681,7311,7306    AND    Setup case after common setup
     [Teardown]   Run Keywords    robot_common_operations.Common Case Teardown    AND   Teardown case D
     CB008967_SR_D_6_ASOH_SBTS_CAB_AVG_FANSPEED


[1]CB008967-SR-C_32_ASOH_SBTS_SMOD_TEMP_RANGE3_SAMPLES_activation_deactivation
     [Documentation]
     [Tags]     CRT_TRUNK
     [Setup]   Run Keywords    robot_common_operations.Common Case Setup
     ...    allowed_faults_ids=61675,1933,4681,7311,7306    AND    Setup case after common setup
     [Teardown]   Run Keywords    robot_common_operations.Common Case Teardown    AND   Teardown case D
     CB008967_SR_C_32_ASOH_SBTS_SMOD_TEMP_RANGE3


CB008967-SR_test
     [Documentation]
     [Tags]     CRT_TRUNK
     [Setup]
     [Teardown]
     CB008967_SR_C_test