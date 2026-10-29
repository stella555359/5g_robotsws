# *** Settings ***
# Documentation
# ...  author: Chen Yin 4
# ...  contact: yin.4.chen@nokia-sbell.com
# 
# Resource   ./Resource/Common.robot
# 
# Force Tags   SG_07   CA_5G_OAM   CRT    PY36
# 
# Suite Setup    Common Setup
# Suite Teardown    Common Teardown
# Test Setup   Run Keywords
# ...   robot_common_operations.Common Case Setup   AND
# ...   Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
# 
# *** Variables ***
# @{ALL_TEST_STATUS}
# 
# *** Test Cases ***
# CB007777_SR_I_General_SiSo_Power_Meter_counter_update_for_energy_consumption_on_AEQN
#     ${all_counters}   Get Power Meter Releated Counters
#     ${all_timestamp}   Get ALL Timestamp   all_counters=${all_counters}
#     Set Suite Variable   ${ALL_COUNTERS}
#     Set Suite Variable   ${ALL_TIMESTAMP}
#     Check Power Meter Releated Counters   ALL_COUNTERS=${ALL_COUNTERS}   ALL_TIMESTAMP=${ALL_TIMESTAMP}
#     # Check Time Interval   time_interval=${900}   ALL_COUNTERS=${ALL_COUNTERS}   ALL_TIMESTAMP=${ALL_TIMESTAMP}
# 
# CB007777_SR_I_WebUI_Real_time_Measurements_display_Voltage_and_Power_information
#     ${all_measurements}   Get Power Meter Releated Measurements
#     Set Suite Variable   ${ALL_MEASUREMENTS}
#     :FOR   ${distname}   IN   @{ALL_MEASUREMENTS.keys()}
#         # Log To Console   ${ALL_MEASUREMENTS['${distname}']['power']}
#         # Log To Console   ${ALL_MEASUREMENTS['${distname}']['voltage']}
#         Should Not Be Equal As Numbers   ${ALL_MEASUREMENTS['${distname}']['power']}   0
#         Should Not Be Equal As Numbers   ${ALL_MEASUREMENTS['${distname}']['voltage']}   0
#     END
# 
# CB007777_SR_I_Energy_Consumption_Counter_Update_When_different_Measurement_Interval
#     ${delta_file}   Catenate   SEPARATOR=
#     ...   [{
#     ...       "distName":"${MRBTS}/MNL-1/MNLENT-1/PMMNL-1",
#     ...       "operation":"update",
#     ...       "parameters":[{
#     ...           "parameterName":"mtBtsEnergyMonitoring",
#     ...           "value":"30min",
#     ...           "operation":"update"
#     ...       }]
#     ...   },{
#     ...       "distName":"${MRBTS}/MNL-1/MNLENT-1/PMMNL-1",
#     ...       "operation":"update",
#     ...       "parameters":[{
#     ...           "parameterName":"mtSBTSRfmEnergyMonitoring",
#     ...           "value":"30min",
#     ...           "operation":"update"
#     ...       }]
#     ...   },{
#     ...       "distName":"${MRBTS}/MNL-1/MNLENT-1/PMMNL-1",
#     ...       "operation":"update",
#     ...       "parameters":[{
#     ...           "parameterName":"mtSBTSSmEnergyMonitoring",
#     ...           "value":"30min",
#     ...           "operation":"update"
#     ...       }]
#     ...   }]
#     COAM Perform Delta Recommission   delta_file=${delta_file}
#     Sleep   16m
#     ${all_counters}   Get Power Meter Releated Counters
#     ${all_timestamp}   Get ALL Timestamp   all_counters=${all_counters}
#     Set Suite Variable   ${ALL_COUNTERS}
#     Set Suite Variable   ${ALL_TIMESTAMP}
#     Check Power Meter Releated Counters   ALL_COUNTERS=${ALL_COUNTERS}   ALL_TIMESTAMP=${ALL_TIMESTAMP}
#     # Check Time Interval   time_interval=${1800}   ALL_COUNTERS=${ALL_COUNTERS}   ALL_TIMESTAMP=${ALL_TIMESTAMP}
#     [Teardown]   Initialize Power Meter Releated Parameters
# 
# CB007777_SR_I_Energy_Consumption_Counter_Feature_Deactivate_via_WebUI
#     COAM Update Parameter   dist_name=${MRBTS}/MNL-1/MNLENT-1/FEATCADM-1   parameter=actPowerMeter   value=false
#     Sleep   16m
#     ${last_timestamp}   Get Latest Timestamp
#     Sleep   16m
#     ${new_timestamp}   Get Latest Timestamp
#     Should Be Equal As Numbers   ${new_timestamp}   ${last_timestamp}
#     [Teardown]   Initialize Power Meter Releated Parameters
# 
# CB007777_SR_I_AEQN_Embedded_Power_Meter_for_Energy_Efficiency
#     List Should Not Contain Value   ${ALL_TEST_STATUS}   FAIL
