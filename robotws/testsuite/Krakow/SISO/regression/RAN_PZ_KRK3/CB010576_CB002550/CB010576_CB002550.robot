*** Settings ***

Documentation
...    Author: Agnieszka Basza, Aleksandra Faliszek, Karol Lapczyk, Patryk Wojcik
...    contact: agnieszka.basza@nokia.com, aleksandra.faliszek@nokia.com, karol.lapczyk@nokia.com, patryk.wojcik@nokia.com
...    squad group: MN RAN Pz KRK 3 SG
...    Feature CB010756 MN RAN in 24R1 program

Library           BuiltIn
Library           Collections
Library           DateTime
Library           OperatingSystem
Resource          testsuite/Krakow/resources/RAN_VRF_KRK3/SFP/sfp_common.robot
Library           ./resources/CB010576_resources.py
Resource          taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables         taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
Suite Teardown    Common Suite Teardown

Test Setup        Common Preconditions With Watching Alarms
Test Teardown     Common Postconditions With Watching Alarms


*** Test Cases ***
[1][1.0] CB010576-E_5GC002550-Initiate SFP Monitoring from webUI for ABIP(static data - Tx_parameters)
    Set SFPs HW for test
    ${SFPs_for_BBMOD}=     Get SFP links details for BBMOD
    sfp_common.Check if SFP static TX parameters have a valid values     ${SFPs_for_BBMOD}    ${SFPs_hw_BBMOD}

[1][1.0] CB010576-E_5GC002550-Initiate_SFP_Monitoring_from_WemEM_for_ABIP(static_data-SFP_parameters)
    Set SFPs HW for test
    ${SFPs_for_BBMOD}=     Get SFP links details for BBMOD
    sfp_common.Check if SFP static HW parameters have a valid values for BBMOD    ${SFPs_for_BBMOD}    ${SFPs_hw_BBMOD}

[1][1.0] CB010576-E_5GC002550-Dynamic_SFP_Parameters_saved_into_PM_counters_for_ABIP
    ${sfps_for_BBMOD}=     Get SFP dynamic parameters from PM counters for BBMOD
    sfp_common.Check if SFP dynamic parameters retrieved from PM counters have a valid values for BBMOD   ${sfps_for_BBMOD}
    sleep   15min
    ${sfps_for_BBMOD}=     Get SFP dynamic parameters from PM counters for BBMOD
    sfp_common.Check if SFP dynamic parameters retrieved from PM counters have a valid values for BBMOD     ${sfps_for_BBMOD}

[1][1.0] CB010576-C_General_SiSo_Link_Diagnostic_and_Monitoring
    ${links}  ${SMOD}  ${BBMOD}  ${RMOD}    Get information about sfp links
    Check if static data SFP QSFP have a valid value for ports for SMOD  ${links}     ${SMOD}
    ${physicalPort}    Check if QSFP or SFP  ${links}    ${BBMOD}
    Check if Tx parameters have a valid value for ports for BBMOD    ${links}    ${BBMOD}    ${physicalPort}
    Check if temperature parameters have a valid value for ports for SMOD   ${links}    ${SMOD}
    Check if static parameters have a valid value for ports    ${links}    ${RMOD}
