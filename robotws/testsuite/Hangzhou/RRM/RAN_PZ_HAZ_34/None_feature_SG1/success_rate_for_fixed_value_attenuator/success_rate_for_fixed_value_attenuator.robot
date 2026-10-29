# *** Settings ***
# Documentation    author:Tiffany Liu
# ...               contact: tiffany.liu@nokia-sbell.com
# ...               squad group: SG_01
# ...               feature :
# Suite Setup       TestSuite.Init
# Suite Teardown    TestSuite.Destroy
# Force Tags
# ...    PY36
# Resource          ../../../../OAM/RAN_PZ_HAZ_34/None_Feature_SG1/OAM_Interface.robot
# Resource          ../../5GC002479/Resources/5GC002479_Resouce.robot
# #Resource          ../../None_feature_SG1/success_rate_for_fixed_value_attenuator/Resources/success_rate_for_fixed_value_attenuator_Resouce.robot
# Resource          ../success_rate_for_fixed_value_attenuator/Resources/success_rate_for_fixed_value_attenuator_Resouce.robot
# 
# *** Test Cases ***
# success_rate_for_fixed_value_attenuator
#     [Documentation]
#     [Tags]     CIT_TRUNK     CIT_21A       CIT_21B
#     [Setup]    Setup case for two CELL L3 call
#     [Teardown]  Teardown case for two CELL L3 call
#     TC.success_rate_for_fixed_value_attenuator
# 
# 
# *** Keywords ***
# TestSuite.Init
#     TestSuite.CommonSuiteStart_for_success_rate
# 
# 
# TestSuite.Destroy
#     TestSuite.CommonSuiteStop
# 
