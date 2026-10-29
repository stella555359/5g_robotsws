*** Settings ***
Library    taf.ue
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/5GC001796/B/resources/test_specific_keywords.py  WITH NAME  specific
Library    ta_attenuator
Library    taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter   WITH NAME      GnbCounter

Resource   testsuite/Wroclaw/RRM/resources/logs.robot
Resource   testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource   testsuite/Wroclaw/RRM/resources/tti_verification/tti_streaming/tti_streaming.robot
Resource   testsuite/Wroclaw/RRM/resources/pm_counters/pm_counters.robot
Resource   testsuite/Wroclaw/RRM/resources/cell_utility/cell_utility.robot
Resource   taf/rfrl/common_resources/common_step/interface.robot

Documentation  Set of keywords for feature 5GC001796-B execution


*** Variables ***
${ABSTRACT_LIB_CONFIG}      7_16_UTE5GCLOUDT196/ue_conf.yaml
${pm_interval}              15
${next_pm_period_delay}     60
${counters_start_atten}     8db
${counters_stop_atten}      40db
${counters_atten_step}      4db
${counters_atten_interval}  0.5s
${start_atten}              0db
${stop_atten}               90db
${atten_step}               4db
${atten_interval}           1s
${ATTACH_CELL}              GNB_1_CELL_50


*** Keywords ***
5GC001796_BB_TC114_M55304C06000-27_Initial_and_retransmission_volume_on_PDSCH_with_256QAM_MCS_table_using_MCS_0-27
    @{tc114_counter_names}=   Create List   M55304C06000   M55304C06001   M55304C06002   M55304C06003   M55304C06004   M55304C06005   M55304C06006
    ...                                     M55304C06007   M55304C06008   M55304C06009   M55304C06010   M55304C06011   M55304C06012   M55304C06013
    ...                                     M55304C06014   M55304C06015   M55304C06016   M55304C06017   M55304C06018   M55304C06019   M55304C06020
    ...                                     M55304C06021   M55304C06022   M55304C06023   M55304C06024   M55304C06025   M55304C06026   M55304C06027
    ${tc114_counter_values}=    Get last counter values   @{tc114_counter_names}
    ${tb_dict}=   Extract tb size sum for each used mcs   ${LOG_PATH}/${TESTNAME}_tti.dlAndUl.csv   dl
#    Check gathered dict relations match pm counters relations  ${tb_dict}   ${tc114_counter_values}   ${cell_id}
    Check gathered mcs match pm counters  ${tb_dict}   ${tc114_counter_values}   ${cell_id}


5GC001796_BB_TC113_M55304C05000-27_Initial_transmission_volume_on_PDSCH_with_256QAM_MCS_table_using_MCS_0-27
    @{tc113_counter_names}=   Create List   M55304C05000   M55304C05001   M55304C05002   M55304C05003   M55304C05004   M55304C05005   M55304C05006
    ...                                     M55304C05007   M55304C05008   M55304C05009   M55304C05010   M55304C05011   M55304C05012   M55304C05013
    ...                                     M55304C05014   M55304C05015   M55304C05016   M55304C05017   M55304C05018   M55304C05019   M55304C05020
    ...                                     M55304C05021   M55304C05022   M55304C05023   M55304C05024   M55304C05025   M55304C05026   M55304C05027
    ${tc113_counter_values}=    Get last counter values   @{tc113_counter_names}
    ${tb_dict}=   Extract tb size sum for each used mcs in initial transmissions  ${LOG_PATH}/${TESTNAME}_tti.dlAndUl.csv    dl
#    Check gathered dict relations match pm counters relations  ${tb_dict}   ${tc113_counter_values}   ${cell_id}
    Check gathered mcs match pm counters  ${tb_dict}   ${tc113_counter_values}   ${cell_id}


5GC001796_BB_TC112_M55303C06001-25_Received_UE_related_SINR_in_Rank_2_for_PUSCH_Level_01-25
    @{tc112_counter_names}=   Create List   M55303C06001   M55303C06002   M55303C06003   M55303C06004   M55303C06005   M55303C06006   M55303C06007
    ...                                     M55303C06008   M55303C06009   M55303C06010   M55303C06011   M55303C06012   M55303C06013   M55303C06014
    ...                                     M55303C06015   M55303C06016   M55303C06017   M55303C06018   M55303C06019   M55303C06020   M55303C06021
    ...                                     M55303C06022   M55303C06023   M55303C06024   M55303C06025
    ${tc112_counter_values}=    Get last counter values   @{tc112_counter_names}
    ${sinr_dict}=   Extract pusch sinr levels table for given rank   ${LOG_PATH}/${TESTNAME}_tti.dlAndUl.csv   2
    Check gathered mcs match pm counters  ${sinr_dict}   ${tc112_counter_values}   ${cell_id}


5GC001796_BB_TC111_M55303C05001-25_Received_UE_related_SINR_in_Rank_1_for_PUSCH_Level_01-25
    @{tc111_counter_names}=   Create List   M55303C05001   M55303C05002   M55303C05003   M55303C05004   M55303C05005   M55303C05006   M55303C05007
    ...                                     M55303C05008   M55303C05009   M55303C05010   M55303C05011   M55303C05012   M55303C05013   M55303C05014
    ...                                     M55303C05015   M55303C05016   M55303C05017   M55303C05018   M55303C05019   M55303C05020   M55303C05021
    ...                                     M55303C05022   M55303C05023   M55303C05024   M55303C05025
    ${tc111_counter_values}=    Get last counter values   @{tc111_counter_names}
    ${sinr_dict}=   Extract pusch sinr levels table for given rank   ${LOG_PATH}/${TESTNAME}_tti.dlAndUl.csv    1
    Check gathered mcs match pm counters  ${sinr_dict}   ${tc111_counter_values}   ${cell_id}


5GC001796_BB_TC110_M55301C20020-35_Wideband_CQI_Histogram_when_UE_reports_related_to_256QAM_table-CQI_Level_0-15
    @{tc110_counter_names}=   Create List   M55301C20020   M55301C20021   M55301C20022   M55301C20023   M55301C20024   M55301C20025   M55301C20026
    ...                                     M55301C20027   M55301C20028   M55301C20029   M55301C20030   M55301C20031   M55301C20032   M55301C20033
    ...                                     M55301C20034   M55301C20035
    ${tc110_counter_values}=    Get last counter values   @{tc110_counter_names}
    ${cqi_dict}=   Extract CQI report table  ${LOG_PATH}/${TESTNAME}_tti.dlAndUl.csv
    Check gathered cqi match pm counters  ${cqi_dict}   ${tc110_counter_values}   ${cell_id}


5GC001796_BB_TC109_M55301C19020-35_Wideband_CQI_Histogram_when_UE_reports_related_to_64QAM_table-CQI_Level_0-15
    @{tc109_counter_names}=   Create List   M55301C19020   M55301C19021   M55301C19022   M55301C19023   M55301C19024   M55301C19025   M55301C19026
    ...                                     M55301C19027   M55301C19028   M55301C19029   M55301C19030   M55301C19031   M55301C19032   M55301C19033
    ...                                     M55301C19034   M55301C19035
    ${tc109_counter_values}=    Get last counter values   @{tc109_counter_names}
    ${cqi_dict}=   Extract CQI report table  ${LOG_PATH}/${TESTNAME}_tti.dlAndUl.csv
    Check gathered cqi match pm counters  ${cqi_dict}   ${tc109_counter_values}   ${cell_id}


5GC001796_BB_TC108_M55300C07000-27_Unsuccessful_PDSCH_transmissions_by_last_HARQ_reTx_with_256QAM_MCS_table_using_MCS_0-27
    @{tc108_counter_names}=   Create List   M55300C07000   M55300C07001   M55300C07002   M55300C07003   M55300C07004   M55300C07005   M55300C07006
    ...                                     M55300C07007   M55300C07008   M55300C07009   M55300C07010   M55300C07011   M55300C07012   M55300C07013
    ...                                     M55300C07014   M55300C07015   M55300C07016   M55300C07017   M55300C07018   M55300C07019   M55300C07020
    ...                                     M55300C07021   M55300C07022   M55300C07023   M55300C07024   M55300C07025   M55300C07026   M55300C07027
    ${tc108_counter_values}=    Get last counter values   @{tc108_counter_names}
    ${tc108_mcs_dict}=   Extract used dl mcs table in last unsuccessful retransmissions  ${LOG_PATH}/${TESTNAME}_tti.dlAndUl.csv   dl
    Check gathered mcs match pm counters  ${tc108_mcs_dict}   ${tc108_counter_values}   ${cell_id}


5GC001796_BB_TC107_M55300C06000-27_Successful_PDSCH_transmissions_by_any_transmission_with_256QAM_MCS_table_using_MCS_0-27
    @{tc107_counter_names}=   Create List   M55300C06000   M55300C06001   M55300C06002   M55300C06003   M55300C06004   M55300C06005   M55300C06006
    ...                                     M55300C06007   M55300C06008   M55300C06009   M55300C06010   M55300C06011   M55300C06012   M55300C06013
    ...                                     M55300C06014   M55300C06015   M55300C06016   M55300C06017   M55300C06018   M55300C06019   M55300C06020
    ...                                     M55300C06021   M55300C06022   M55300C06023   M55300C06024   M55300C06025   M55300C06026   M55300C06027
    ${tc107_counter_values}=    Get last counter values   @{tc107_counter_names}
    ${tc107_mcs_dict}=   Extract used mcs table in successful transmissions  ${LOG_PATH}/${TESTNAME}_tti.dlAndUl.csv    dl
    Check gathered mcs match pm counters  ${tc107_mcs_dict}   ${tc107_counter_values}   ${cell_id}


5GC001796_BB_TC106_M55300C05000-27_Successful_PDSCH_transmissions_by_initial_transmission_with_256QAM_MCS_table_using_MCS_0-27
    @{tc106_counter_names}=   Create List   M55300C05000   M55300C05001   M55300C05002   M55300C05003   M55300C05004   M55300C05005   M55300C05006
    ...                                     M55300C05007   M55300C05008   M55300C05009   M55300C05010   M55300C05011   M55300C05012   M55300C05013
    ...                                     M55300C05014   M55300C05015   M55300C05016   M55300C05017   M55300C05018   M55300C05019   M55300C05020
    ...                                     M55300C05021   M55300C05022   M55300C05023   M55300C05024   M55300C05025   M55300C05026   M55300C05027
    ${tc106_counter_values}=    Get last counter values   @{tc106_counter_names}
    ${tc106_mcs_dict}=   Extract used mcs table in successful initial transmissions   ${LOG_PATH}/${TESTNAME}_tti.dlAndUl.csv    dl
    Check gathered mcs match pm counters  ${tc106_mcs_dict}   ${tc106_counter_values}   ${cell_id}


5GC001796_BB_TC105_M55300C04000-27_PDSCH_initial_transmissions_with_256QAM_MCS_table_using_MCS_0-27
    @{tc105_counter_names}=   Create List   M55300C04000   M55300C04001   M55300C04002   M55300C04003   M55300C04004   M55300C04005   M55300C04006
    ...                                     M55300C04007   M55300C04008   M55300C04009   M55300C04010   M55300C04011   M55300C04012   M55300C04013
    ...                                     M55300C04014   M55300C04015   M55300C04016   M55300C04017   M55300C04018   M55300C04019   M55300C04020
    ...                                     M55300C04021   M55300C04022   M55300C04023   M55300C04024   M55300C04025   M55300C04026   M55300C04027
    ${tc105_counter_values}=    Get last counter values   @{tc105_counter_names}
    ${tc105_mcs_dict}=   Extract used mcs table in initial transmissions   ${LOG_PATH}/${TESTNAME}_tti.dlAndUl.csv    dl
    Check gathered mcs match pm counters  ${tc105_mcs_dict}   ${tc105_counter_values}   ${cell_id}


5GC001796_BB_TC73_UL_LA_iniDeltaSinr_Calculation_Updated_Case_different_MCS0_or_MaxMCS_BW-5MHz_NSA
    Start tcpdump on LTE
    Execute call and get whole TTI traces   UE_1  UL  ${start_atten}  ${stop_atten}  ${atten_step}  ${atten_interval}
    specific.Check that laIniDelta is updated correctly    ${LOG_PATH}/${TESTNAME}_tti.dlAndUl.csv
    [Teardown]  Stop tcpdump on LTE and get logs


5GC001796_BB_TC65_DL_LA_Check_NIDD_impact_on_Update_of_iniDeltaCqi_BW-5MHz_NSA
    Start tcpdump on LTE
    Execute call and get whole TTI traces   UE_1  DL  ${start_atten}  ${stop_atten}  ${atten_step}  ${atten_interval}
    specific.Check that laIniDelta is updated correctly    ${LOG_PATH}/${TESTNAME}_tti.dlAndUl.csv
    [Teardown]  Stop tcpdump on LTE and get logs


Initialise attenuator
    Load Attenuation Config    ${ABSTRACT_LIB_CONFIG}
    @{cell_list}=   Create list   GNB_1_CELL_50   GNB_1_CELL_51   GNB_1_CELL_52
    Set global variable   @{gnb_cells}   @{cell_list}
    Require Attenuator Setup Of    ${gnb_cells}
    Set Attenuation For All Cells    90db
    Set Attenuation    ${ATTACH_CELL}   0db
    Sleep  1s  Give time to adapt to new attenuations


Counters 64qam Trigger
    Set suite variable    ${TEST NAME}    5GC001796_B_64qam_ttitrace_pm_counters
    Set suite variable    ${TESTNAME}     5GC001796_B_64qam_ttitrace_pm_counters
    Set suite variable    ${test_name}    5GC001796_B_64qam_ttitrace_pm_counters
    ${pm_interval}=   Convert To Integer   ${pm_interval}
    ${next_pm_period_delay}=    Convert To Integer   ${next_pm_period_delay}
    Setup default olla parameters 64qam
    taf.ue.Require UE   UE_1   capabilities=REAL_UE
    Require Cell    alias=CELL_1    lnbts_id=${tl.enbs[0].global_bts_id}      lcr_id=1
    Set Ue Location    UE_1    CELL_1
    Initialise attenuator
    GnbCounter.Wait for next pm period     interval=${pm_interval}
    Start tcpdump on LTE   filename=${TESTNAME}_lte.pcap
    Execute call and get whole TTI traces   UE_1  UL  ${counters_start_atten}  ${counters_stop_atten}
    ...   ${counters_atten_step}  ${counters_atten_interval}
    Stop tcpdump on LTE and get logs   filename=${TESTNAME}_lte.pcap
    ${id}=   Get global id of attached cell   ${LOG_PATH}/${TESTNAME}_lte.pcap
    Set Suite Variable   ${cell_id}   ${id}
    GnbCounter.Wait for next pm period     interval=${pm_interval}   delay=${next_pm_period_delay}
    Collect counters
    [Teardown]   Stop tcpdump on LTE and get logs   filename=${TESTNAME}_lte.pcap


Counters 256qam Trigger
    Set suite variable    ${TEST NAME}    5GC001796_B_256qam_ttitrace_pm_counters
    Set suite variable    ${TESTNAME}    5GC001796_B_256qam_ttitrace_pm_counters
    ${pm_interval}=   Convert To Integer   15
    ${next_pm_period_delay}=    Convert To Integer   60
    Setup default olla parameters
    taf.ue.Require UE   UE_1   capabilities=REAL_UE
    Require Cell    alias=CELL_1    lnbts_id=${tl.enbs[0].global_bts_id}      lcr_id=1
    Set Ue Location    UE_1    CELL_1
    Initialise attenuator
    GnbCounter.Wait for next pm period     interval=${pm_interval}
    Start tcpdump on LTE   filename=${TESTNAME}_lte.pcap
    Execute call and get whole TTI traces   UE_1  DL  ${counters_start_atten}  ${counters_stop_atten}
    ...   ${counters_atten_step}  ${counters_atten_interval}
    Stop tcpdump on LTE and get logs   filename=${TESTNAME}_lte.pcap
    ${id}=   Get global id of attached cell   ${LOG_PATH}/${TESTNAME}_lte.pcap
    Set Suite Variable   ${cell_id}   ${id}
    GnbCounter.Wait for next pm period     interval=${pm_interval}   delay=${next_pm_period_delay}
    Collect counters
    [Teardown]   Stop tcpdump on LTE and get logs   filename=${TESTNAME}_lte.pcap

Counters Suite Teardown
    Cleanup all downloaded counter files
    Stop tcpdump on LTE and get logs   filename=${TESTNAME}_lte.pcap
    Teardown TTI Traces in Streaming mode    output_file=${test_name}_tti_teardown
    Run Keyword And Ignore Error    Teardown attenuator
    taf.ue.Detach UE    UE_1

Execute call and get whole TTI traces
    [Arguments]  ${ue_alias}   ${direction}   ${start_att}  ${stop_att}   ${step_att}   ${interval_att}
    Start TTI Traces in Streaming mode
    taf.ue.Attach UE    ${ue_alias}
    taf.ue.Start Data Transfer
    ...     dt_name=DT_${direction}
    ...     ue_alias=${ue_alias}
    ...     direction=${direction}
    ...     duration=60s
    ...     throughput=500Mbits/sec
    ...     protocol=udp
    ...     packet_size=1200
    Sleep  1s   Iperf warm up
    Execute single cell fading scenario   ${ATTACH_CELL}  ${step_att}  ${interval_att}  ${start_att}  ${stop_att}
    [Teardown]  Run Keywords
    ...   Stop TTI Traces in Streaming mode   output_file=${test_name}_tti  AND
    ...   taf.ue.Stop Data Transfer   DT_${direction}                       AND
    ...   taf.ue.Detach UE   ${ue_alias}                                    AND
    ...   Set Attenuation    ${ATTACH_CELL}   0db


Execute all cells fading scenario
    [Arguments]  ${start_att}  ${stop_att}   ${step_att}   ${interval_att}
    FOR   ${cell}  IN  @{gnb_cells_robot}
        Execute single cell fading scenario   ${cell}  ${step_att}  ${interval_att}  ${start_att}  ${stop_att}
    END


Test Teardown
    Run Keyword And Ignore Error    interface.Common Step Trigger


Teardown Attenuator
    Set attenuation for all cells    0db
    Release attenuator cell    ${gnb_cells}
