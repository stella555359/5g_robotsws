*** Settings ***
Documentation     author: Chen Helen
...               contact: helen.1.chen@nokia-sbell.com
...               squad group: MMW_02
Suite Setup       SISO Coam Suite Setup
Suite Teardown    SISO Coam Suite Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource          ./resources/CB007113_common_keywords.robot

*** Variables ***
${if_commissioning}    False

*** Test Cases ***
[1][1.0]CB007113-SR-C_38_NR_FR1_TDD_Inter_L1_subpool_UL_PRB_Pooling_example_2_100MHz
    [Setup]    Case_Setup
    ${SCF_CB008940-Q}    Replace String    ${Golden_SCF_Path}    .xml    _CB008940-Q.xml
    Commissioning SCF And Check On Air    scf_path=${SCF_CB008940-Q}
    Multi_UEs_Attach_And_UL_Traffic_For_7113
    [Teardown]    Case_Teardown

[1][1.0]CB007113-J_2_Interworking_with_CB008662_Adaptive_re-transmission_with_NDM-SRS
    [Setup]    Case_Setup
    Should Be Equal As Strings    ${PREV TEST STATUS}    PASS
    [Teardown]    Case_Teardown

