# *** Settings ***
# Suite Setup        SISO Coam Suite Setup
# Suite Teardown     SISO Coam Suite Teardown
# Test Setup
# Test Teardown
# Test Timeout      90 minutes
# 
# Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/5G_Setup_And_Teardown.robot
# Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource          ../common/coam_resource.robot
# Resource          Resource/5GC001178-A-5GC001082_common_KW.robot
# Documentation
# ...    author: hellen.liu
# ...    contact: hellen.liu@nokia-sbell.com
# ...    squad group: SG_05
# ...    Feature 5GC0001178-A-5GC001082 in 5G19B program
# 
# Force Tags   5G_SISO  RAN_5G   RAN_5G_TDD  master_classicalbts_all  STATE_SW_UPLOADED  CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AWHHD
# ...    PY36
# 
# *** Variables ***
# ${package_target_version}    SBTS00_ENB_9999_220920_000008
# 
# 
# *** Test Cases ***
# [1]5GC001178_A_5GC001082_01_12_Classical gNB Software Management Operation Cancellation via WebUI
#     [Documentation]    *****************
#     ...    Basic information
#     ...    *****************
#     ...    this case is to verify gNB Software Management Operation Cancellation via WebUI
#     ...    ******************
#     ...    History of changes
#     ...    ******************
#     ...    - 15.08.2019 https://jiradc.int.net.nokia.com/browse/WESTLAKE-1021 - Created
#     ...    *******************
#     ...    Test case flowchart
#     ...    *******************
#     [Tags]   CRT_TRUNK   SBTS00
#     [Setup]   Run Keywords    cOAM Common Suite Setup    Case setup
#     [Teardown]   Run Keywords     Case teardown    Delete downloaded package    cOAM Common Suite Teardown
#     Step1: Login WebUI
#     Step2: Upgrade site without active
#     Step3: Cancel during software update progress
#     Step4: Logout webui
# 
# *** Keywords ***
# Step1: Login WebUI
#     log to console    Step1:Login WebUI
#     Wait Until Keyword Succeeds    10min    10s    WEBUI Login
# 
# Step2: Upgrade site without active
#     log to console    Step2:Upgrade site without active
#     ${package_full_link}    Get link For Download from external value    version_type=Active
#     ${upgrade_package_abs_path}    Download SW Build to VM      package_full_link=${package_full_link}
#     set suite variable    ${upgrade_package_abs_path}
#     Download package to site       if_active=${FALSE}      upgrade_package_path=${upgrade_package_abs_path}
# 
# 
# Step3: Cancel during software update progress
#     log to console    Step3:Cancel during software update progress
#     #wait until keyword succeeds    15min    1min    Check if SW download start
#     sleep    2min
#     wait until keyword succeeds    5min    10s    selenium_coam.cancel_software_update
#     wait until keyword succeeds    3min    10s    Check the planned SW version
# 
# Step4: Logout webui
#     log to console    Step4:logout webui
#     Run Keyword And Ignore Error    WEBUI Logout
# 
# Check the planned SW version
#     ${version}    selenium_coam.check_current_software_version
#     ${result}    should match regexp    &{version}[Planned]     ${empty}
#     sleep    5s
# 
# Check if SW download start
#     ${result}    selenium_coam.check_software_update_progress
#     log    ${result}
#     should not be equal    &{result}[percentage]    0%
# 
