*** Settings ***
Documentation
...  author: Pawel Zabawczuk
...  contact: pawel.k.zabawczuk@nokia.com

Resource        ./CB007893_keywords.robot

*** Keywords ***
[1]CB007893-5G-G_004_Measurement_Gap_interaction_with_configuration_of_the_A1_measurement_based_SCell_additon_during_SgNB_modification
    [Documentation]   This scenario is to verify that gNB can successfully handle SCell addition with P(S)Cell-A1 measurement
    ...               for SCell addition with maintained DRX.
    # Change A1 Measurment Configuration    rsrp   101
    Check Signal Strength For 4G Cells Used In Test

    Log To Console   \n\n ATTACH UE TO LTE, START AND VERIFY TRAFFIC
    Clear Attenuation For Cell 4G Pci 51
    Attach Ue     UE_1
    Verify 4G Attach
    ${start_time}   Get Time   epoch
    Perform Data Transfer   tput=900
    ${time_point_1}   Get Time   epoch
    Check If Traffic Is Still Running
    Check Average Tput   start_time=${start_time}  stop_time=${time_point_1}

    Log To Console   \n\n PERFORM NSA ATTACH AND VERIFY TRAFFIC
    Start Tracing On SMOD
    Clear Attenuation For Cell 5G Pci 101
    BuiltIn.Sleep   30s   Time needed to perform NSA attach
    Verify 5G NSA Attach
    ${time_point_2}   Get Time   epoch
    Check If Traffic Is Still Running
    Check Average Tput   start_time=${start_time}  stop_time=${time_point_2}

    Log To Console   \n\n PERFORM CA, GENERATE A1 MEASUREMENT REPORTS AND VERIFY TRAFFIC
    Clear Attenuation For Cell 5G Pci 105
    Set Attenuation For 4G Cell Pci 51 Below Threshold Tha2 For RSRP
    Set Attenuation For 4G Cell Pci 12 Witn RSRP Lower Than Cell Pci 51
    ${time_point_3}   Get Time   epoch
    Verify 5G NSA Attach
    Check If Traffic Is Still Running
    Check Average Tput   start_time=${start_time}  stop_time=${time_point_3}
    ${log path}   Stop Tracing And Download Logs From SMOD
    Await Data Transfer Finish   DT_DL

    Verify A1   ${log path}
    Verify Measurment Report   ${log path}
    Verify Carier Aggregation   pcap_file=${log path}  num_of_cells=1  phys_cells_id=105

    [Teardown]  Run Keywords
    ...    Detach Ue   ue_alias=UE_1     AND
    ...    Stop Tracing On SMOD
