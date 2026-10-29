# *** Settings ***
# Force Tags    PY36
# Documentation
# ...    Author:linjiangjing
# ...    Contact:jiangjing.lin@nokia-sbell.com
# ...    Group: HGZ_SG8
# ...    Feature: CB008795
# 
# Suite Setup         run keywords    Setup Suite For Cloud    AND    Initial Parameter Values For 8795
# Test Setup          Setup Test For Cloud
# Test Teardown       Teardown Test For Cloud
# Suite Teardown      Teardown Suite For Cloud
# Resource          Resource/CB008795_common_keyword.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# 
# *** Variables ***
# ${scf_path_cu}    ${commissionings_path}/HGZ/${testline_name}/gnbs_0/cu
# ${scf_path_du}    ${commissionings_path}/HGZ/${testline_name}/gnbs_0/dus_0
# 
# *** Test Cases ***
# [1]CB008795-CR-B_3_Cloud_RMOD_MAX_TEMPERATURE_counter_activation
#     activate and deactivate rmod max temperature counter
# 
# [1]CB008795-CR-B_6_Cloud_SFP_RM_AVG_TEMPERATURE_counter_activation
#     activate and deactivate sfp rm avg temperature counter
# 
# [1]CB008795-CR-A_1_Cloud startup SFP power level 1-2 compatibility validation on RMOD
#     sfp power compatibility validation on rmod
# 
# [1]CB008795-CR-A_9_The Cloud shall support NIDD parameter sfpOperatorMode enable and disable SFP28 compliance validation on RMOD
#     sfpOperatorMode enable and SFP28 compliance disable
# 
# 
# 
# 
# 
# 
# 
