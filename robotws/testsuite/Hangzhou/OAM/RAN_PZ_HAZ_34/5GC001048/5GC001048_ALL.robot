# *** Settings ***
# Documentation
# ...  author: Chen Yin 4
# ...  contact: yin.4.chen@nokia-sbell.com   lei.nie@nokia-sbell.com
# 
# Resource   ./Resource/Common.robot
# 
# Force Tags   SG_07   CA_5G_OAM    CRT_UTE   master_classicalbts_all   5G_RAN
# ...    PY36
# ...   5G_RAN_TDD   CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQN_NETACT   STATE_SW_UPLOADED
# ...   AUTHOR_yin.4.chen@nokia-sbell.com   RAN_5G    RAN_5G_TDD   SBTS00
# 
# Test Timeout   1h
# 
# Suite Setup   Wait Until Keyword Succeeds   3x   30s   COAM commissioning if not onair
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]5GC001048_001_Upgrade_to_Target_build_and_check_default_value
#     [Tags]   AUTHOR_yin.4.chen@nokia-sbell.com
#     [Setup]   Case Setup 001
#     [Teardown]   Case Teardown 001
#     Upgrade_to_Target_build_and_check_default_value
# 
# [1]5GC001048_002_Feature_flag_is_enable_password_change_to_default
#     [Tags]   AUTHOR_yin.4.chen@nokia-sbell.com
#     [Setup]   Case Setup 002
#     [Teardown]   Case Teardown 002
#     Feature_flag_is_enable_password_change_to_default
# 
# [1]5GC001048_003_Feature_flag_is_enable_alarm_is_raised_update_alarm_by_password_change_to_default
#     [Tags]   AUTHOR_yin.4.chen@nokia-sbell.com
#     [Setup]   Case Setup 003
#     [Teardown]   Case Teardown 003
#     Feature_flag_is_enable_alarm_is_raised_update_alarm_by_password_change_to_default
# 
# [1]5GC001048_004_Feature_flag_is_enable_alarm_is_raised_update_alarm_by_password_change_to_non_default
#     [Tags]   AUTHOR_yin.4.chen@nokia-sbell.com
#     [Setup]   Case Setup 004
#     [Teardown]   Case Teardown 004
#     Feature_flag_is_enable_alarm_is_raised_update_alarm_by_password_change_to_non_default
# 
# [1]5GC001048_005_Feature_flag_is_enable_alarm_is_raised_Clear_alarm_by_password_change_to_non_default
#     [Tags]   AUTHOR_yin.4.chen@nokia-sbell.com
#     [Setup]   Case Setup 005
#     [Teardown]   Case Teardown 005
#     Feature_flag_is_enable_alarm_is_raised_Clear_alarm_by_password_change_to_non_default
# 
# [1]5GC001048_006_Feature_flag_is_enable_alarm_is_raised_Clear_alarm_by_disable_feature_flag
#     [Tags]   AUTHOR_yin.4.chen@nokia-sbell.com
#     [Setup]   Case Setup 006
#     [Teardown]   Case Teardown 006
#     Feature_flag_is_enable_alarm_is_raised_Clear_alarm_by_disable_feature_flag
# 
# [1]5GC001048_007_Feature_flag_is_disable_with_default_password_enable_flag
#     [Tags]   AUTHOR_yin.4.chen@nokia-sbell.com
#     [Setup]   Case Setup 007
#     [Teardown]   Case Teardown 007
#     Feature_flag_is_disable_with_default_password_enable_flag
# 
# [1]5GC001048_008_Feature_flag_is_enable_ssh_is_enable_change_Local_Nokia_Service_account_password_to_default
#     [Tags]   AUTHOR_yin.4.chen@nokia-sbell.com
#     [Setup]   Case Setup 008
#     [Teardown]   Case Teardown 008
#     Feature_flag_is_enable_ssh_is_enable_change_Local_Nokia_Service_account_password_to_default
# 
# [1]FGCR_2355_003_Beamforming_Grid_Selection_Modification_via_WEBEM_Requires_Object_Locking
#     [Tags]   AUTHOR_yin.4.chen@nokia-sbell.com
#     [Setup]   Case Setup 2355
#     [Teardown]   Case Teardown 2355
#     Beamforming_Grid_Selection_Modification_via_WEBEM_Requires_Object_Locking
