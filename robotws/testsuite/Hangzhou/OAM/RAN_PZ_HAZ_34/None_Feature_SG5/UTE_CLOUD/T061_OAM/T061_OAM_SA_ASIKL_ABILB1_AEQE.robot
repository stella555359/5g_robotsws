*** Settings ***
Suite Setup       SISO Coam Suite Setup
Suite Teardown    SISO Coam Suite Teardown
Test Setup
Test Teardown
Test Timeout      90 minutes

Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource     ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001178-A/Resource/5GC001178-AE-5GC001639-RA_common_KW.robot
Resource     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
Resource     ../Resource/T061_KW.robot

Documentation
...    author: hu annie
...    contact: annie.hu@nokia-sbell.com
...    squad group: SG_05
...    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQE in TRUNK program

Force Tags    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY39    master_classicalbts_all

*** Variables ***

*** Test Cases ***
### part-1: 5GC001178-A - 3 TCs ###
### 2023-02-07 below 3TCs optimized from Trunk so case Tag 'CRT_UTE' removed
[1][1.0] 5GC001178_A_5GC000372_03_Session Idle Timeout
    [Tags]    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQE
    [Timeout]    20min
    [Setup]    SISO Coam Test Setup
    [Teardown]    SISO Coam Test Teardown
    Step1: Login WebUI
    Wait idle time
    Logout WebUI

[1][1.0] 5GC001178-5GC001639-RA_05_snapshot_contains_SW_and_HW_configuration
    [Tags]    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQE
    [Setup]    SISO Coam Test Setup
    [Teardown]    SISO Coam Test Teardown
    step1:Login WebUI
    step2:collect snapshot
    step3:check configuration files collected
    step4:logout webui
    remove the unzip directory

[1][1.0] 5GC001178-5GC001639-RA_07_snapshot_collect_summary_file
    [Tags]    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQE
    [Setup]    SISO Coam Test Setup
    [Teardown]    SISO Coam Test Teardown
    step1:Login WebUI
    step2:collect All log snapshot
    step3:check summary file collected
    step4:logout webui
    remove the unzip directory

*** Keywords ***
