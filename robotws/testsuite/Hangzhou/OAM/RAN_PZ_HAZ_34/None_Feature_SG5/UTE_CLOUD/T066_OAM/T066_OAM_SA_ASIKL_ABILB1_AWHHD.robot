*** Settings ***
Suite Setup       SISO Coam Suite Setup
Suite Teardown    SISO Coam Suite Teardown
Test Setup
Test Teardown
Test Timeout      120 minutes

Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource     ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC000470/Resource/5GC000470-E-5GC001082_common_KW.robot
Resource     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001178-A/Resource/5GC001178-A-5GC001082_common_KW.robot
Resource     ../Resource/T066_KW.robot

Documentation
...    author: hu annie
...    contact: annie.hu@nokia-sbell.com
...    squad group: SG_05
...    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AWHHD in TRUNK program

Force Tags    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY39    master_classicalbts_all

*** Variables ***
${package_target_version}    SBTS00_ENB_9999_231214_000008

*** Test Cases ***
### part-1: 5GC000470_N_5GC001541 - 7 TCs ###
### part-2: 5GC000470-E-5GC001082-A - 4 TCs ###
### part-3: 5GC001178-A-5GC001082-A - 1 TCs ###
#[1][1.0] 5GC001178_A_5GC001082_01_12_Classical gNB Software Management Operation Cancellation via WebUI
#    [Tags]   CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AWHHD   CRT_UTE
#    [Setup]   Run Keywords    cOAM Common Suite Setup    Case setup
#    [Teardown]   Run Keywords     Case teardown    Delete downloaded package    cOAM Common Suite Teardown
#    Step1: Login WebUI
#    Step2: Upgrade site without active
#    Step3: Cancel during software update progress
#    Step4: Logout webui

*** Keywords ***
