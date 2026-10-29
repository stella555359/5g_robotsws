# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           #SISO Coam Test Setup
# Test Teardown        #SISO Coam Test Teardown
# Test Timeout         2h
# 
# Resource    Resource/CB010766_Common_KW.robot
# 
# Documentation
# ...    Author: Zhang Xuewen
# ...    Contact: xuewen.zhang@nokia-sbell.com
# ...    squad group:SG_05
# ...    Feature 'CB010766 RU Deep Sleep mode for mMIMO products' in SBTS24R1 program
# 
# Force Tags    RAN_5G_TDD    RAN_5G    SBTS00    STATE_SW_UPLOADED
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]CB010766-SR-A_01 Configure time window for RU deep sleep (AQQL)
#     [Tags]     CRT_TRUNK
#     [Setup]    SISO Coam Test Setup
#     Configure time window for RU deep sleep
#     [Teardown]    SISO Coam Test Teardown
# 
# [1]CB010766-SR-A_07 Activate RU Deep Sleep Mode when the time window starts (AQQL)
#     [Tags]     CRT_TRUNK
#     [Setup]    SISO Coam Test Setup
#     Activate RU Deep Sleep Mode when the time window starts
#     [Teardown]    SISO Coam Test Teardown
# 
# [1]CB010766-SR-A_08 Awake RU from deep sleep when the time window ends (AQQL)
#     [Tags]     CRT_TRUNK
#     [Setup]    SISO Coam Test Setup
#     Awake RU from deep sleep when the time window ends
#     [Teardown]    SISO Coam Test Teardown
# 
# [1]CB010766-SR-A_06 Change RU deep sleep mode when time window is re-configured (AQQL)
#     [Tags]     CRT_TRUNK
#     [Setup]    SISO Coam Test Setup
#     Change RU deep sleep mode when time window is re-configured
#     [Teardown]    SISO Coam Test Teardown
# 
# *** Keywords ***
