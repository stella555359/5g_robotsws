*** Settings ***
Documentation
...    author: Kamil Bielecki
...    contact: kamil.bielecki@nokia.com
...    description: Test Cases for CB012207 parity HO for FR2 SA

Resource          ./resources/keywords.robot


Suite Setup    Suite Setup
Suite Teardown    Suite Teardown


*** Test Cases ***
CB012207-C-B1_CB008806_Successful_Intra-freq_Inter-gNB_NG_handover_based_on_A3_A5_measurements_with_indirect_DL_data_forwarding
    [Setup]    Test Setup NG HO
    Lock gNB Cell    gnb_id=0    cell_id=260
    Sleep    10
    Wait For Next PM measurements
    Attach UE With PDU Session Setup to Cell 1 of gNB 2
    Check If UE Is Attached To Cell 1 Of gNB 2
    Unlock gNB Cell    gnb_id=0    cell_id=260
    Run Downlink and Uplink TCP Data Transmission for 300 seconds
    Perform UE HO to cell 1 of gNB 1
    Check If UE performed NG HO To Cell 1 Of gNB 1
    Stop Downlink and Uplink TCP Data Transmission
    Verify Downlink and Uplink TCP Data Transmission
    Detach UE
    Wait For Next PM measurements
    Check PM counters for CB008806
    [Teardown]    Test Teardown HO with source shutdown


CB012207-C-B2_CB008127_Successful_Intra-freq_Inter-gNB_handover_Xn_based_on_A3_A5_measurements
    [Setup]    Test Setup Xn HO
    Lock gNB Cell    gnb_id=0    cell_id=260
    Sleep    10
    Wait For Next PM measurements
    Attach UE With PDU Session Setup to Cell 1 of gNB 2
    Check If UE Is Attached To Cell 1 Of gNB 2
    Unlock gNB Cell    gnb_id=0    cell_id=260
    Run Downlink and Uplink TCP Data Transmission for 300 seconds
    Perform UE HO to cell 1 of gNB 1
    Check If UE performed XN HO To Cell 1 Of gNB 1
    Stop Downlink and Uplink TCP Data Transmission
    Verify Downlink and Uplink TCP Data Transmission
    Detach UE
    Wait For Next PM measurements
    Check PM counters for CB008127
    [Teardown]    Test Teardown HO with source shutdown


CB012207-C-B2_CB008699_Successful_Intra-freq_inter-gNB_Xn_handover_when_Source_DRB_to_QoS_flow_mapping_is_not_supported_at_target_gNB
    [Setup]    Test Setup Xn HO
    Activate Full RRC Reconfiguration on both gNBs
    Lock gNB Cell    gnb_id=0    cell_id=260
    Sleep    10
    Wait For Next PM measurements
    Attach UE With PDU Session Setup to Cell 1 of gNB 2
    Check If UE Is Attached To Cell 1 Of gNB 2
    Unlock gNB Cell    gnb_id=0    cell_id=260
    Run Downlink and Uplink TCP Data Transmission for 300 seconds
    Perform UE HO to cell 1 of gNB 1
    Check If UE performed XN HO To Cell 1 Of gNB 1
    Stop Downlink and Uplink TCP Data Transmission
    Verify Downlink and Uplink TCP Data Transmission
    Detach UE
    Deactivate Full RRC Reconfiguration on both gNBs
    Wait For Next PM measurements
    Check PM counters for CB008699
    [Teardown]    Test Teardown HO with source shutdown


CB012207-C-B7_CB009842_Successful_E-CID_Measurement_Reporting_for_NR-TADV_Measurement_Quantity
    [Setup]    Test Setup NG HO
    Lock gNB Cell    gnb_id=1    cell_id=270
    Sleep    10
    Attach UE With PDU Session Setup to Cell 1 of gNB 1
    Check If UE Is Attached To Cell 1 Of gNB 1
    Unlock gNB Cell    gnb_id=1    cell_id=270
    Trigger E-CID initialization request
    Verify E-CID request received and measurements correct
    Detach UE
    [Teardown]    Test Teardown HO with source shutdown
