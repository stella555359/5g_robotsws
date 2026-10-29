*** Settings ***
Suite Setup    Run keywords    CI_interface.Common Suite Setup    AND    PCMD Coam Suite Setup
Suite Teardown     Run keywords    robot_common_operations.Common Suite Teardown    AND    Suite Teardown with SCF
Test Setup    SISO Coam Test Setup
Test Teardown    Coam Test Teardown
Test Timeout    100 min

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ../common/RRH_common_keyword.robot
Resource    Resources/TL924_Robust_Common_Keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot

Documentation
...   author: y6lu
...   contact: lu.yu@nokia-sbell.com
...   squad group: MMW_SG3
...   Feature 5GC001358-D in 5G22R2 program

Force Tags    STATE_SW_UPLOADED    CRT_UTE    RAN_5G    RAN_5G_TDD    CLOUD_5G_CLASSICAL_ASKEY_ASIBR_ABIOB4_3xAZQG    SBTS00    SBTS22R2
...    PY36    SBTS22R3

Library             taf.config.scf        WITH NAME    scf
Library             taf.sbts.oam.coam.admin   WITH NAME   admin_cli



*** Variables ***
${testline_name}    7_5_UTE5G402T2065
${scf_file_path}    ${commissionings_path}HGZ/${testline_name}




*** Test Cases ***
[1]CB013388_A_01_Online_modification_actAdaptiveSr_from_True_to_False_with_non_VoNR_UE_TDD
    [Documentation]
    [Tags]
    [Setup]    Test Case setup
    Scf commission and wait on-air    scf_name=SCF_CB013388.xml
    Set parameter    key=actAdaptiveSr    value=${true}
    sleep    120s
    Set PA prepare
    L3 call setup for CB008124
    start power ue traffic ul and dl      ul_throughput=110M    dl_throughput=310M
    Check power ue Tput    ul_throughput=100    dl_throughput=300
    Set parameter    key=actAdaptiveSr    value=${false}
    Check power ue Tput    ul_throughput=100    dl_throughput=300
    stop multi power ue traffic ul and dl
    L3 call detach
    [Teardown]    Test Case teardown

[1]CB013388_A_09_Online_modification_actAdaptiveSr_from_False_to_True_TDD
    [Setup]    Test Case setup
    Scf commission and wait on-air    scf_name=SCF_CB013388.xml
    Set parameter    key=actAdaptiveSr    value=${false}
    sleep    120s
    Set PA prepare
    L3 call setup for CB008124
    start power ue traffic ul and dl      ul_throughput=110M    dl_throughput=310M
    Check power ue Tput    ul_throughput=100    dl_throughput=300
    Set parameter    key=actAdaptiveSr    value=${true}
    Check power ue Tput    ul_throughput=100    dl_throughput=300
    stop multi power ue traffic ul and dl
    L3 call detach
    [Teardown]    Test Case teardown


[1]CB013388_B_15_Online_modification_actServiceAwareConfig_TDD_SA
    [Setup]    Test Case setup
    Scf commission and wait on-air    scf_name=SCF_CB013388.xml
    Set parameter    key=actServiceAwareConfig    value=${false}
    sleep    120s
    Set PA prepare
    L3 call setup for CB008124
    start power ue traffic ul and dl      ul_throughput=110M    dl_throughput=310M
    Check power ue Tput    ul_throughput=100    dl_throughput=300
    Set parameter    key=actServiceAwareConfig    value=${true}
    Check power ue Tput    ul_throughput=100    dl_throughput=300
    stop multi power ue traffic ul and dl
    L3 call detach
    [Teardown]    Test Case teardown

[1]CB013388_B_20_Online_modification_actServiceAwareConfig_iwk_CB012810
    [Setup]    Test Case setup
    Scf commission and wait on-air    scf_name=SCF_CB013388.xml
    Set parameter    key=actServiceAwareConfig    value=${true}
    sleep    120s
    Set PA prepare
    L3 call setup for CB008124
    start power ue traffic ul and dl      ul_throughput=110M    dl_throughput=310M
    Check power ue Tput    ul_throughput=100    dl_throughput=300
    Set parameter    key=actServiceAwareConfig    value=${false}
    Check power ue Tput    ul_throughput=100    dl_throughput=300
    stop multi power ue traffic ul and dl
    L3 call detach
    [Teardown]    Test Case teardown
