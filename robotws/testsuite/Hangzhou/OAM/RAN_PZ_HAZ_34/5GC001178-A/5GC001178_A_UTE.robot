# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup
# Test Teardown
# Test Timeout      120min
# 
# Resource    ../common/coam_resource.robot
# Resource    Resource/5GC001178-AE-5GC001639-RA_common_KW.robot
# Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/5G_Setup_And_Teardown.robot
# Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# 
# Documentation
# ...    author: jackie.ji
# ...    contact: jackie.ji@nokia-sbell.com
# ...    squad group: SG_05
# ...    Feature 5GC001178-A-5GC000372 in 5G19B program
# 
# Force Tags     RAN_5G   RAN_5G_TDD   master_classicalbts_all   STATE_SW_UPLOADED   CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQE 
# ...    PY36
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]5GC001178_A_5GC000372_03_Session Idle Timeout
#     [Tags]      SBTS00   CRT_TRUNK   CRT_21A   CRT_21B   CRT_22R1
#     [Timeout]    20min
#     [Setup]    SISO Coam Test Setup
#     [Teardown]    SISO Coam Test Teardown
#     Step1: Login WebUI
#     Wait idle time
#     Logout WebUI
# 
# [1]5GC001178-5GC001639-RA_05_snapshot_contains_SW_and_HW_configuration
#     [Tags]      SBTS00   CRT_TRUNK   CRT_21A   CRT_21B   CRT_22R1
#     [Setup]    SISO Coam Test Setup
#     [Teardown]    SISO Coam Test Teardown 
#     step1:Login WebUI
#     step2:collect snapshot
#     step3:check configuration files collected
#     step4:logout webui
#     remove the unzip directory
# 
# [1]5GC001178-5GC001639-RA_07_snapshot_collect_summary_file
#     [Tags]      SBTS00   CRT_TRUNK   CRT_21A   CRT_21B   CRT_22R1
#     [Setup]    SISO Coam Test Setup
#     [Teardown]    SISO Coam Test Teardown 
#     step1:Login WebUI
#     step2:collect All log snapshot
#     step3:check summary file collected
#     step4:logout webui
#     remove the unzip directory
# 
# *** Keywords ***
# Step2: Check NG link status
#     log to console    Step2: Check NG link status
#     Check AMF status
# 
# Logout WebUI
#     log to console    Logout WebUI
#     Run Keyword And Ignore Error    selenium_coam.set_lock_screen_time    lock_time=${15}
#     run keyword and ignore error    WEBUI Logout
# 
# Wait idle time
#     log to console    sleep to wait
#     Run Keyword and Ignore Error    selenium_coam.refresh_page
#     Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
#     #run keyword and ignore error      selenium_coam.enable_screen_lock
#     ${lock_screen_time}=    selenium_coam.get_lock_screen_time
#     run keyword if    "${lock_screen_time}" != "${2}"     selenium_coam.set_lock_screen_time    lock_time=${2}
#     sleep    130s
#     selenium_coam.login_after_screen_lock    passwd=${WEBUI_PASSWORD}
# 
# Acquire login fail info
#     sleep    10s
#     @{fail_info}    run keyword and ignore error    selenium_coam.login     url=${WEBUI_URL}
#     ...   username=${WEBUI_USER}     password=${WEBUI_PASSWORD}
#     should be equal    @{fail_info}[0]    FAIL
# 
# Check AMF status
#     &{amf_status}    selenium_coam.get_amf_info
#     should be equal    &{amf_status}[NG link status]    Active
# 
# step1:Login WebUI
#     log to console    step1:Login WebUI
#     wait until keyword succeeds      3min    10s     WEBUI Login
# 
# step2:collect snapshot
#     log to console    step2:collect snapshot
#     save snapshot    coverage=Most important log files    save_location=Local
#     wait until keyword succeeds      10min    30s   check snapshot collected in local driver and copy it
# 
# step3:check configuration files collected
#     log to console    step3:check configuration files collected
#     check the expected file collected    pattern=*.ims2
# 
# step4:logout webui
#     log to console    step4:logout webui
#         run keyword and ignore error     WEBUI Logout
# 
# step2:collect All log snapshot
#     log to console    step2:collect All log snapshot
#     save snapshot    coverage=All log files    save_location=Local
#     wait until keyword succeeds    20 min    30 sec    check snapshot collected in local driver and copy it
# 
# step3:check summary file collected
#     log to console    step3:check summary file collected
#     check the expected file collected    pattern=*metadata.txt
