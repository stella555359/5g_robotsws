# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# 
# Test Setup           SISO Coam Test Setup
# Test Teardown        Run keywords   
# ...    Recover Env   AND
# ...    SISO Coam Test Teardown
# 
# Test Timeout         150 min
# 
# Resource    Resource/CB005750_common_KW.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# #Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
# Library        ../../../OAM/RAN_PZ_HAZ_34/libraries/get_bts_info.py   WITH NAME    lib
# 
# Documentation
# ...    Author: Annie Hu
# ...    contact:Annie.hu@nokia-sbell.com
# ...    squad group:SG_05
# ...    Feature CB005750-5G-EBAS in 5G21A program
# 
# Force Tags             5G_RAN_TDD
# ...    PY36
# 
# *** Variables ***
# ${alarm_filter}     4383
# ${BLACKBOX_ALARMS_PATH}            /ffs/run/config/lifedata/blackbox_alarms
# ${alarm_filter}     4019
# ${Alarm_ID_CP}      7101
# ${Alarm_name_CP}    BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
# ${Fault_ID_CP}       4019
# ${Fault_name_CP}    Baseband card autonomous reset as recovery action
# 
# *** Test Cases ***
# [1]CB005750-5G-EBAS_001_5G_Autonomous_recovery_reset_counter_BBMOD_SMOD
#     [Tags]    master_classicalbts_all   CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4
#     General_OAM_Autonomous_recovery_reset_counter_BBMOD_SMOD
# 
# [1]CB005750-5G-EBAS_003_5G_Autonomous_recovery_reset_counter_SMOD
#     [Tags]    master_classicalbts_all    CRT_TRUNK
#     General_OAM_Autonomous_recovery_reset_counter_SMOD
# 
# 
# *** Keywords ***
