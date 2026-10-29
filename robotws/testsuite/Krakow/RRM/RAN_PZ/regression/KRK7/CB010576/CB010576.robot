*** Settings ***
Documentation
...   Test suite for regression testing for feature CB010576
...   author: Wioleta Swies
...   contact: wioleta.swies@nokia.com


Resource    ./resources/keywords.robot

Suite Setup      Common Suite Setup With OnAir Test Line Preparation    should_LTE_neighbour_be_changed=${False}
...                                                                     should_5G_neighbour_be_changed=${False}
...                                                                     increase_time_for_checking_bbmod=600
...                                                                     increase_timeout_for_update_sw=1800
...                                                                     increase_time_for_checking_radios=2100
...                                                                     increase_time_for_checking_cells=1400
...                                                                     swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt

Suite Teardown    Common Suite Teardown

Test Setup       Run Keywords    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    No X2 link available    AND
...                              Common Preconditions With Watching Alarms

Test Teardown    Common Postconditions With Watching Alarms


*** Test Cases ***
[1]CB010576-D_001_5GC000918_Call_Setup_UL_DL_traffic_with_BasicBeamSet
    #5gkrk2/rmnet_data0
    Load and Activate SCF and Wait for OnAir    918_D_SCF.xml
    ue.Require Ue    ${alias}    capabilities=${capabilities}
    ue.Detach Ue     ${alias}
    bipcollector.Start Bip Trace Log Capturing    mirroring_script_params=${mirroring_script_params}
    ue.Attach Ue     ${alias}
    Sleep     10s
    ue.Detach Ue     ${alias}
    bipcollector.Stop Bip Trace Log Capturing
    bipcollector.Download Bip Logs    download_dir=${OUTPUT_DIR}/test_918
    ${full_pcap_file}   Find Pcap File    ${OUTPUT_DIR}/test_918
    convert_to_csv_and_analysis    pcap_file=${full_pcap_file}
    Run Keyword And Ignore Error     ue.Stop Using Ue    ${alias}
    Verify L3 Call Traffic DL Only    anp=5gkrk2

[1]CB010576-D_012_5GC001878_Generating_artificial_load_on_SSB_beams_SU_MIMO_DefinedSubsetofSSBBeams_mmWaves
    Run Keywords    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    No X2 link available
    ...                                                              No X2 link available for a specific LTEENB
    ...             AND    Common Preconditions With Watching Alarms
    Load and Activate SCF and Wait for OnAir    1878_D_SCF.xml
    ${pcap_path}    Catch Tcpdump During BBomd Reset
    Check L2ps Cellsetupreq Parameters    ${pcap_path}    ${LOG_PATH}/${TEST_NAME}.pdml
    Check L2ps Cellgroupreconfigreq Parameters    ${pcap_path}    ${LOG_PATH}/${TEST_NAME}.pdml

[1]CB010576-D_007_5GC001732_1CC_CSI_Report_Multiplexig_Max_DL_Tput_coderate_0.25
    Load and Activate SCF and Wait for OnAir    1732_C_SCF.xml
    bipcollector.Start Bip Trace Log Capturing    mirroring_script_params=${mirroring_script_params}
    Verify L3 Call Traffic DL Only    duration=100s    anp=5gkrk2
    bipcollector.Stop Bip Trace Log Capturing
    bipcollector.download_bip_logs    download_dir=${OUTPUT_DIR}/test_1732
    ${pcap_path}   Find Pcap File    ${OUTPUT_DIR}/test_1732
    Verify NumOfBitsOfUciInformation Parameter    ${pcap_path}    ${LOG_PATH}/${TEST_NAME}.pdml

[1]CB010576-D_015_CB008158-D_DL_scheduling_delay_with_Ue_DRX_On_and_inactive_for_PMQAP_FR2_TDD_NSA
    # '5qi78-krk/rmnet_data0'
    Load and Activate SCF and Wait for OnAir    8158_D_SCF.xml
    Wait For Next Pm Counter Period    interval=5min    delay=10
    Verify L3 Call Traffic DL Only    anp=5qi78-krk
    Wait For Next Pm Counter Period    interval=5min    delay=30
    Sleep    20s
    Check_DRX_related_counters_when_actCDrx_is_false
    Change ActCDrx Status    status=true
    Wait For Next Pm Counter Period    interval=5min    delay=1
    Verify L3 Call Traffic DL Only    anp=5qi78-krk    change_apn=${False}
    Wait For Next Pm Counter Period    interval=5min    delay=10
    Sleep    20s
    Check_DRX_related_counters_when_actCDrx_is_true
