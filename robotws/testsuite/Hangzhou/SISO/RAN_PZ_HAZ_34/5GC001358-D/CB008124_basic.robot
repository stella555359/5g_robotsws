*** Settings ***
Suite Setup    Run keywords    CI_interface.Common Suite Setup    AND    PCMD Coam Suite Setup    AND    SISO Coam Suite Setup
Suite Teardown     Run keywords    SISO Coam Suite Teardown    AND    Suite Teardown with SCF
Test Setup    SISO Coam Test Setup
Test Teardown    Coam Test Teardown
Test Timeout    100 min

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ../common/RRH_common_keyword.robot
Resource    Resources/5GC001358-D_keyword.robot

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
${testline_name}    7_5_UTE5G402T924
${scf_file_path}    ${commissionings_path}HGZ/${testline_name}




*** Test Cases ***
[1]CB008124-SR-E_01_IWK1_5GC000704_ULCG_config_setup_during_Intra-gNB_Intra-freq_HO_With_same_UE_CG_activation_status_With_same_UE_CG_profile
    [Documentation]
    [Tags]
    [Setup]
    [Teardown]    teardown for CB008124
    Scf commission and wait on-air    scf_name=SCF_CB008124.xml
    Set PA prepare
    Start Btslog Collect for CB008124
    L3 call setup for CB008124
    Start Traffic UL
    Stop btslog and check CG2 Activate
    Stop Traffic UL
    L3 call detach


