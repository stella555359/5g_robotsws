# *** Settings ***
# Documentation
# ...               author: Steven Liu
# ...               contact: steven.liu@nokia-sbell.com
# ...               squad group: MMW_SG_04
# 
# Force Tags        SBTS00    RAN_5G    RAN_5G_TDD    CRT_UTE    	CLOUD_5G_CLASSICAL_ANDROID_ASIBL_ABILB1_AWEUA_ENB    STATE_SW_UPLOADED
# ...    PY36
# Suite Setup       CI_interface.Common Suite Setup
# Suite Teardown
# Resource          ./resource/6942_common_keyword.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# 
# 
# 
# *** Test Cases ***
# 6942-E_common_case
#     [Tags]
#     Set SFPWhiteList File Name
#     Create dir
#     Download whitelist file
#     Delete parameter in sfpwhitelist    sfp_model=AOSD
#     Delete parameter in sfpwhitelist    sfp_model=FOTB
#     Upload whitelist file    upload_whitelist_path=${SFPwhitelist_PATH}${SFPwhitelist_NAME}
#     Reset DU
#     run keyword and continue on failure    check fault 4657
#     change sfpOperatorMode to true
#     sleep    2s
#     Reset DU
#     run keyword and continue on failure    check none fault 4657
#     [Teardown]    Case Teardown
# 
# [1]CB006942-5G-E_7_AEWUA_BTS startup SFP+ or SFP28 transceivers support for fronthaul and backhaul interface
#     [Tags]
#     [Setup]
#     Should Be Equal As Strings    ${PREV_TEST_STATUS}   PASS
#     [Teardown]    CI_interface.Common Case Teardown
# 
# [1]CB006942-5G-E_10_AWEUA_The BTS shall support NIDD parameter (EQM APEQM-SFPOperatorMode) to enable and disable SFP+ or
# ... SFP28 compliance validation
#     [Tags]
#     [Setup]
#     Should Be Equal As Strings    ${PREV_TEST_STATUS}   PASS
#     [Teardown]    CI_interface.Common Case Teardown
# 
# [1]CB006942-5G-C_7_ AEWUA _BTS startup Cooled SFP+ or SFP28 transceivers support for fronthaul and backhaul interface
#     [Tags]
#     Check BTS is in On Air
#     Check BTS startup
#     BTS detects cooled SFP+/SFP28
#     [Teardown]    CI_interface.Common Case Teardown
# 
# [1]CB006942-5G-D_7_AEWUA _BTS startup SFP+ or SFP28 transceivers cold start up support for fronthaul and backhaul interface
#     [Tags]
#     Check BTS is in On Air
#     Check BTS startup
#     BTS detects cooled2 SFP+/SFP28
#     [Teardown]    CI_interface.Common Case Teardown
# 
