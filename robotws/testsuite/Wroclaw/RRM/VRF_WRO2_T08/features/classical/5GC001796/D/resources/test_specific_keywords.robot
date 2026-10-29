*** Settings ***
Library    taf.ue
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/5GC001796/D/resources/test_specific_keywords.py
Library    ta_attenuator

Resource   testsuite/Wroclaw/RRM/resources/logs.robot
Resource   testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource   testsuite/Wroclaw/RRM/resources/swconfig_operations.robot
Resource   testsuite/Wroclaw/RRM/resources/tti_verification/tti_streaming/tti_streaming.robot
Resource   testsuite/Wroclaw/RRM/resources/cell_utility/cell_utility.robot
Resource   taf/rfrl/common_resources/common_step/interface.robot

Documentation  Set of keywords for feature 5GC001796-D execution


*** Variables ***
${ABSTRACT_LIB_CONFIG}     /home/ute/testline_configuration/7_16_UTE5GCLOUDT196/ue_conf.yaml
${start_atten}              ${10}
${stop_atten}               ${0}
${atten_step}               ${2}
${atten_interval}           1s
${ATTACH_CELL}              GNB_1_CELL_50


*** Keywords ***
5GC001796_DB_TC83_UL_LA_SingleTx_UE_Not_Impacted_By_Fallback_SINR_BW-5MHz_NSA
    Set TESTNAME without spaces
    Setup preconditions for ini mcs
    Start tcpdump on LTE
    Initialise Attenuator
    Set attenuation   ${ATTACH_CELL}   ${start_atten}db
    taf.ue.Require UE   UE_1   capabilities=REAL_UE
    Start TTI Traces in Streaming mode
    Sleep  1s   Wait for tti to start capturing packets
    taf.ue.Attach UE    UE_1
    Sleep  2s   Wait for attach
    taf.ue.Start Data Transfer
    ...     dt_name=DT_UL
    ...     ue_alias=UE_1
    ...     direction=UL
    ...     duration=60s
    ...     throughput=200Mbits/sec
    ...     protocol=udp
    ...     packet_size=1200
    FOR  ${atten}  IN RANGE   ${stop_atten}   ${start_atten}   ${atten_step}
        ${real_atten}=   Evaluate   ${start_atten}-${atten}
        Set Attenuation   ${ATTACH_CELL}   ${real_atten}db
        Sleep   ${atten_interval}
    END
    Stop TTI Traces in Streaming mode    output_file=${test_name}_tti
    taf.ue.Await Data Transfer Finish   DT_UL
    taf.ue.Verify Average Throughput
    ...     dt_name=DT_UL
    ...     tput_min=6MBits/sec
    Check that sinr is averaged based on pusch    ${LOG_PATH}/${test_name}_tti.dlAndUl.csv
    [Teardown]   Run Keywords
    ...          taf.ue.Stop Data Transfer   DT_UL                   AND
    ...          taf.ue.Detach UE    UE_1                            AND
    ...          Teardown TTI Traces in Streaming mode    output_file=${test_name}_tti_teardown    AND
    ...          Stop tcpdump on LTE and get logs             AND
    ...          Teardown attenuator


5GC001796_DB_TC79_UL_LA_Check_NIDD_impact_on_Fallback_SINR_BW-5MHz_NSA
    Set TESTNAME without spaces
    #Prepare and upload swconfig      0x590072=1
    Change actEnhancedLinkAdaptation Parameter    true
    Change UlLaIniMcs    18
    Require UE   UE_1   capabilities=REAL_UE
    Start TTI Traces in Streaming mode
    Sleep  1
    taf.ue.Attach UE    UE_1
    Sleep  2s   Wait for attach
    taf.ue.Start Data Transfer
    ...     dt_name=DT_UL
    ...     ue_alias=UE_1
    ...     direction=UL
    ...     duration=16s
    ...     throughput=200Mbits/sec
    ...     protocol=udp
    ...     packet_size=1200
    Sleep   12s
    Stop TTI Traces in Streaming mode    output_file=${test_name}_tti_true
    taf.ue.Await Data Transfer Finish      DT_UL
    taf.ue.Verify Average Throughput
    ...     dt_name=DT_UL
    ...     tput_min=6MBits/sec
    Check if used mcs is higher than init      ${LOG_PATH}/${test_name}_tti_true.dlAndUl.csv
    taf.ue.Detach UE    UE_1

    Change actEnhancedLinkAdaptation Parameter    false
    Start TTI Traces in Streaming mode
    Sleep   1s
    taf.ue.Attach UE    UE_1
    Sleep  2s   Wait for attach
    taf.ue.Start Data Transfer
    ...     dt_name=DT_UL
    ...     ue_alias=UE_1
    ...     direction=UL
    ...     duration=30s
    ...     throughput=200Mbits/sec
    ...     protocol=udp
    ...     packet_size=1200
    Sleep    12s
    Stop TTI Traces in Streaming mode    output_file=${test_name}_tti_false
    taf.ue.Await Data Transfer Finish   DT_UL
    taf.ue.Verify Average Throughput
    ...     dt_name=DT_UL
    ...     tput_min=6MBits/sec
    Check if used mcs is correct if feature off      ${LOG_PATH}/${test_name}_tti_false.dlAndUl.csv
    [Teardown]   Run Keywords
    ...          taf.ue.Stop Data Transfer   DT_UL                   AND
    ...          Teardown TTI Traces in Streaming mode    output_file=${test_name}_tti_teardown   AND
    ...          taf.ue.Detach UE    UE_1


Initialise attenuator
    Load Attenuation Config    ${ABSTRACT_LIB_CONFIG}
    @{cell_list}=   Create list   GNB_1_CELL_50   GNB_1_CELL_51   GNB_1_CELL_52
    Set global variable   @{gnb_cells}   @{cell_list}
    Require Attenuator Setup Of    ${gnb_cells}
    Set Attenuation For All Cells    90db
    Set Attenuation    ${ATTACH_CELL}   0db
    Sleep  1s  Give time to adapt to new attenuations


Teardown attenuator
    Set attenuation for all cells    0db
    Release attenuator cell    ${gnb_cells}


Test Teardown
    Run Keyword If Test Failed   Stop TTI Traces in Streaming mode   output_file=${test_name}_tti_teardown
    Run Keyword And Ignore Error    interface.Common Step Trigger
