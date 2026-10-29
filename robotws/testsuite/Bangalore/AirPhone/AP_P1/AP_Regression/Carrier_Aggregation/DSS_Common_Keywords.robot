*** Settings ***
Documentation    This resource file contains common keywords to DSS feature

Resource        CA_Common_Keywords.robot
Resource        ../../Resources/robot/DSS_wts.robot

*** Variables ***
@{eth3_VM_DSS_LOKI_interfaces}       10.0.1.111
@{noofcells}                         1    2
@{target_cell}                       1    2
${reservedfixed_norsubframes}        0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000
${dl_norsubframes}                   1011111001-1111111111-1011111001-1111111111-1011111001-1111111111-1011111001-1111111111
@{logical_cell_list}                 1    2    3    4
${assigned_dl_minimum_share_to_nr}   30
${assigned_dl_maximum_share_to_nr}   100
${min_lte_nr_dss_ratio}              30
${ul_allocated_prb_list}             0,3|6,35|49,3
${antenna_ports_num}                 2
${super_all_status}                  off
${prb_allocat}                       SEPARATOR=    0:0,52+1:0,52+2:0,52+3:0,52+4:0,52+5:0,52+6:0,52+7:0,52+8:0,52+9:0,52+10:0,52+11:0,52+12:0,52+13:0,
...    52+14:0,52+15:0,52+16:0,52+17:0,52+18:0,52+19:0,52+20:0,52+21:0,52+22:0,52+23:0,52+24:0,52+25:0,52+26:0,52+27:0,52+28:0,52+29:0,52+30:0,
...    52+31:0,52+32:0,52+33:0,52+34:0,52+35:0,52+36:0,52+37:0,52+38:0,52+39:0,52+40:0,52+41:0,52+42:0,52+43:0,52+44:0,52+45:0,52+46:0,52+47:0,
...    52+48:0,52+49:0,52+50:0,52+51:0,52+52:0,52+53:0,52+54:0,52+55:0,52+56:0,52+57:0,52+58:0,52+59:0,52+60:0,52+61:0,52+62:0,52+63:0,52+64:0,
...    52+65:0,52+66:0,52+67:0,52+68:0,52+69:0,52+70:0,52+71:0,52+72:0,52+73:0,52+74:0,52+75:0,52+76:0,52+77:0,52+78:0,52+79:0,52

*** Keywords ***
Test setup for DSS
    [Arguments]    ${noofcells}    ${WTS_FILE}    ${EDAEMON_PORT}    ${feature}=DSS    ${scf_update}=False    ${ip_del}=False    ${prb}=True
    ...    ${superfast}=False    ${prb_list}=False    &{kwargs}
    Basic Test Setup    feature=${feature}    scf_update=${scf_update}    &{kwargs}
    Run Keyword If    "${ip_del}" == "True"    Configure LOKI interfaces for 5GC002640
    Start and configure WTS    wts_cfg_path=/opt/wts/latest/${WTS_FILE}    edaemon_port=${EDAEMON_PORT}
    ${fault_dict_before_test}=    Run keyword And Continue On Failure    Get Alarms
    Set Test Variable    ${fault_dict_before_test}
    Establish X2 link    enb_id=1    gnb_id=2
    Establish XP link
    Enabling DSS Feature Flag    enb_id=1    feature_flag=on    message_sets=DMS3
    Set LTE NR DSS configuration    noofcells=${noofcells}    antenna_ports_num=${antenna_ports_num}
    Set CELL DSS Feature   ${noofcells}    superfast=${superfast}    prb=${prb}
    Setup DSS3 Link    ${noofcells}    ${target_cell}
    Reset UL and DL Reservation for DSS3    ${noofcells}
    DL resource cell reservation    ${noofcells}    ${target_cell}
    UL resource cell reservation    ${noofcells}    ${target_cell}
    Run Keyword If    "${prb_list}" == "True"    Cell Allocation DSS3 PRB LIST    ${noofcells}    ${target_cell}    prb=${prb}
    ...    ELSE    Cell Allocation DSS3    ${noofcells}    ${target_cell}    prb=${prb}
    Wait Until Keyword Succeeds    5 min    15sec
    ...    Check for cell setup complete msg    ${logical_cell_list}
    Enable rrc traces in WTS
    Start AP TTI Traces    AP
    Start gNB TTI Traces
    Start WTS tcpdump for UDP traffic

Test setup for DSS Phase2
    [Arguments]    ${noofcells}    ${target_cell}    ${logical_cell_list}    ${assigned_dl_minimum_share_to_nr}
    ...    ${assigned_dl_maximum_share_to_nr}    ${dl_norsubframes}    ${ul_allocated_prb_list}    ${feature}=DSS    ${scf_update}=False
    ...    ${prb}=False    ${lte_nr_dss_mode}=DL_CRS_TDM_UL_FDM    &{kwargs}
    Log    ${assigned_dl_minimum_share_to_nr}
    Log    ${assigned_dl_maximum_share_to_nr}
    Log    ${ul_allocated_prb_list}
    Basic Test Setup    feature=${feature}    scf_update=${scf_update}    &{kwargs}
    Start and configure WTS    wts_cfg_path=/opt/wts/latest/${WTS_FILE}    edaemon_port=${EDAEMON_PORT}
    ${fault_dict_before_test}=    Run keyword And Continue On Failure    Get Alarms
    Set Test Variable    ${fault_dict_before_test}
    Establish X2 link    enb_id=1    gnb_id=2
    Establish XP link
    Enabling DSS Feature Flag    enb_id=1    feature_flag=on    message_sets=V1,DMS2
    Set LTE NR DSS configuration    noofcells=${noofcells}    lte_nr_dss_mode=${lte_nr_dss_mode}
    Setup DSS3 Link    noofcells=${noofcells}    target_cell=${target_cell}    Phase_3=False
    Cell Allocation DSS Phase 2    noofcells=${noofcells}    target_cell=${target_cell}    prb=${prb}    dl_norsubframes=${dl_norsubframes}
    ...    ul_allocated_prb_list=${ul_allocated_prb_list}
    Wait Until Keyword Succeeds    5 min    15sec
    ...    Check for cell setup complete msg    ${logical_cell_list}
    Enable rrc traces in WTS
    Start AP TTI Traces    AP
    Start gNB TTI Traces
    Start WTS tcpdump for UDP traffic

Configure LOKI interfaces for 5GC002640
    FOR    ${ip}    IN    @{eth3_VM_DSS_LOKI_interfaces}
         Run and return rc and output     sudo ip addr del ${ip}/24 dev eth3
    END

Set CELL DSS Feature
    [Arguments]    ${noofcells}    ${enb_id}=1    ${superfast}=False    ${prb}=True    ${super_all_status}=${super_all_status}
    FOR    ${id}    IN    @{noofcells}
        Enable Cell DSS Feature    ${id}    ${enb_id}    nr_dl_peak_rate_increase=on
        Run Keyword If    "${superfast}" == "True" and "${id}" == "1"   Enable Cell DSS Feature    ${id}    ${enb_id}    superfast_allocation=on
        ...    ELSE    Enable Cell DSS Feature    ${id}    ${enb_id}    superfast_allocation=${super_all_status}
        Run Keyword If    "${prb}" == "False"    Update DSS cell parameter    ${enb_id}    id=${id}    dl_resource_sharing_algo=dl_buffer_level_based
        ...    ELSE    Update DSS cell parameter    ${enb_id}    id=${id}    dl_resource_sharing_algo=dl_prb_load_based
    END

Set LTE NR DSS configuration
    [Arguments]    ${noofcells}    ${enb_id}=1    ${lte_nr_dss_mode}=DSS_PHASE_3    &{kwargs}
    FOR    ${id}    IN    @{noofcells}
        Log To Console    Set LTE NR DSS Mode for Cell-${id}...
        Update cell parameter    ${enb_id}    id=${id}    lte_nr_dss_mode=${lte_nr_dss_mode}    &{kwargs}
    END

Setup DSS3 Link
    [Arguments]    ${noofcells}    ${target_cell}    ${enb}=1    ${assigned_dl_minimum_share_to_nr}=${assigned_dl_minimum_share_to_nr}
    ...    ${Phase_3}=True
    Run Keyword If    "${Phase_3}" == "True"    Update Common Ressource Manager parameters    ${enb}    ul_qos_load_meas_timer=200
    ...    dl_qos_load_meas_timer=200
    FOR    ${id}    ${cell}    IN ZIP    ${noofcells}    ${target_cell}
        Configure dss partnership    enb_id=${enb}    cell_id=${id}    dss_peer=2:${cell}
        Set CRM cell resource reservation for DL and UL    enb_id=${enb}    cell_id=${id}    tgt_cell=${cell}    tgt_enb=2
        ...    assigned_dl_minimum_share_to_nr=${assigned_dl_minimum_share_to_nr}
        ...    assigned_dl_maximum_share_to_nr=${assigned_dl_maximum_share_to_nr}    assigned_dl_minimum_share_to_lte=15
        ...    assigned_dl_maximum_share_to_lte=70    assigned_ul_minimum_share_to_nr=20    assigned_ul_maximum_share_to_nr=70
        sleep    5s
    END
	FOR    ${id}    ${cell}    IN ZIP    ${noofcells}    ${target_cell}
        Establish a DSS partnership between two cells    enb_id=${enb}    cell_id=${id}    tgt_cell=${cell}    tgt_enb=2    timeout=180
    END

Reset UL and DL Reservation for DSS3
    [Arguments]    ${noofcells}    ${enb}=1
    FOR    ${id}    IN    @{noofcells}
        Reset Reservation for DSS3    ${id}    ${enb}    dir=dl
        Reset Reservation for DSS3    ${id}    ${enb}    dir=ul
    END

DL resource cell reservation
    [Arguments]    ${noofcells}    ${target_cell}    ${dir}=DL    ${enb}=1    ${min_lte_nr_dss_ratio}=${min_lte_nr_dss_ratio}
    FOR    ${id}    IN    @{noofcells}
        Configure cells for DSS DL Cell Subframe Resource Coordination    ${id}    ${enb}
        ...    prb_area_reservation_list=0,0,0-10-none+0,0,5-10-none+0,0,9-10-none
        Configure cells for DSS DL Cell Subframe Resource Coordination    ${id}    ${enb}
        ...    reserved_fixed_normal_subframes=${reservedfixed_norsubframes}
        Configure cells for DSS DL Cell Subframe Resource Coordination    ${id}    ${enb}    min_lte_nr_dss_ratio=${min_lte_nr_dss_ratio}
        ...    max_lte_nr_dss_ratio=100
    END
    FOR    ${id}    ${cell}    IN ZIP    ${noofcells}    ${target_cell}
        Request a cell resource coordination to CRM    ${enb}    ${id}    tgt_cell=${cell}    tgt_enb=2    dir=${dir}
    END

UL resource cell reservation
    [Arguments]    ${noofcells}    ${target_cell}    ${dir}=UL    ${enb}=1
    FOR    ${id}    ${cell}    IN ZIP    ${noofcells}    ${target_cell}
        Configure cells for DSS UL Cell Subframe Resource Coordination    ${id}    ${enb}    minimum_prb_share=30    maximum_prb_share=70
        Request a cell resource coordination to CRM    ${enb}    ${id}    tgt_cell=${cell}    tgt_enb=2    dir=${dir}
        ...    pass_regexp=EN DSS UL Cell Subcarrier Resource Coordination*
        Displays per Cell CRM related status    ${enb}    cell=${id}
    END

Request a cell DSS resource allocation for DL
    [Arguments]    ${id}    ${tgt_cell}    ${pass_regexp}=Cell ${id}: Received DSS DL Resource Area Allocation Response*
    ...    ${dl_allocated_normal_subframes}=${dl_norsubframes}    ${enb}=1    ${tgt_enb}=2
    ...    ${timeout}=180    ${allocation_start_time}=immediate    &{kwargs}
    Request a cell DSS resource allocation to the CRM    enb_id=${enb}    cell_id=${id}    tgt_cell=${tgt_cell}    tgt_enb=${tgt_enb}
    ...    dir=DL    timeout=${timeout}   pass_regexp=${pass_regexp}    allocation_start_time=${allocation_start_time}
    ...    dl_allocated_normal_subframes=${dl_allocated_normal_subframes}    &{kwargs}

Request a cell DSS resource allocation for UL
    [Arguments]    ${id}    ${tgt_cell}    ${pass_regexp}=Cell ${id}: Received EN DSS UL Subcarrier Resource Allocation Response*
    ...    ${ul_allocated_prb_list}=${ul_allocated_prb_list}   ${enb}=1    ${tgt_enb}=2
    ...    ${timeout}=180    ${allocation_start_time}=immediate    &{kwargs}
    Request a cell DSS resource allocation to the CRM    enb_id=${enb}    cell_id=${id}    tgt_cell=${tgt_cell}    tgt_enb=${tgt_enb}
    ...    dir=UL    timeout=${timeout}   pass_regexp=${pass_regexp}    allocation_start_time=${allocation_start_time}
    ...    ul_allocated_prb_list=${ul_allocated_prb_list}    &{kwargs}

Cell Allocation DSS Phase 2
    [Arguments]    ${noofcells}    ${target_cell}    ${dl_norsubframes}=${dl_norsubframes}
    ...    ${ul_allocated_prb_list}=${ul_allocated_prb_list}    ${prb_allocat}=${prb_allocat}    ${prb}=True
    Log    ${dl_norsubframes}
    Log    ${ul_allocated_prb_list}
    FOR    ${id}    ${cell}    IN ZIP    ${noofcells}    ${target_cell}
        Run Keyword If    "${prb}" == "False"
        ...    Request a cell DSS resource allocation for DL    id=${id}    tgt_cell=${cell}
        ...    pass_regexp=Cell ${id}: Received DSS DL Subframe Resource Allocation Response*
        ...    ELSE
        ...    Request a cell DSS resource allocation for DL    id=${id}    tgt_cell=${cell}
        ...    pass_regexp=Cell ${id}: Received DSS DL Subframe Resource Allocation Response*
        ...    dl_prb_area_allocation_list=${prb_allocat}
        Request a cell DSS resource allocation for UL    id=${id}    tgt_cell=${cell}
    END

Cell Allocation DSS3
    [Arguments]    ${noofcells}    ${target_cell}    ${dl_norsubframes}=${dl_norsubframes}
    ...    ${ul_allocated_prb_list}=${ul_allocated_prb_list}    ${prb_allocat}=${prb_allocat}    ${prb}=True
    Log    ${dl_norsubframes}
    Log    ${ul_allocated_prb_list}
    FOR    ${id}    ${cell}    IN ZIP    ${noofcells}    ${target_cell}
        Run Keyword If    "${prb}" == "False"
        ...    Request a cell DSS resource allocation for DL    id=${id}    tgt_cell=${cell}
        ...    ELSE
        ...    Request a cell DSS resource allocation for DL    id=${id}    tgt_cell=${cell}
        ...    dl_prb_area_allocation_list=${prb_allocat}
        Request a cell DSS resource allocation for UL    id=${id}    tgt_cell=${cell}
    END

Cell Allocation DSS3 PRB LIST
    [Arguments]    ${noofcells}    ${target_cell}    ${enb}=1    ${ul_allocated_prb_list}=${ul_allocated_prb_list}    ${prb_allocat}=${prb_allocat}
    ...    ${prb}=True
    FOR    ${id}    ${cell}    ${prb}    ${ul_prb}    IN ZIP    ${noofcells}    ${target_cell}    ${prb_allocat}    ${ul_allocated_prb_list}
        Run Keyword If    "${prb}" == "False"    Request a cell DSS resource allocation to the CRM    ${enb}    ${id}    tgt_cell=${cell}   tgt_enb=2
        ...    dir=DL    timeout=180    pass_regexp=Cell ${id}: Received DSS DL Resource Area Allocation Response*
        ...    allocation_start_time=immediate    dl_allocated_normal_subframes=${dl_norsubframes}
        ...    ELSE    Request a cell DSS resource allocation to the CRM    ${enb}    ${id}    tgt_cell=${cell}   tgt_enb=2    dir=DL    timeout=180
        ...    pass_regexp=Cell ${id}: Received DSS DL Resource Area Allocation Response*
        ...    allocation_start_time=immediate    dl_allocated_normal_subframes=${dl_norsubframes}    dl_prb_area_allocation_list=${prb}
        Request a cell DSS resource allocation to the CRM    ${enb}    ${id}    tgt_cell=${cell}   tgt_enb=2    dir=UL    timeout=180
        ...    pass_regexp=Cell ${id}: Received EN DSS UL Subcarrier Resource Allocation Response*
        ...    allocation_start_time=immediate    ul_allocated_prb_list=${ul_prb}
    END

Trigger Intrafreq Based SA Forward handover
    [Arguments]    ${ue_id}    ${carrier_frequency}=127010    ${primary_cell}=1    ${sim_gnb_id}=2    ${sim_cell}=3    ${phycell_id}=52
    log to console    SA forward handover from Real gNB2 cell${primary_cell} to simulator gNB${sim_gnb_id} cell${sim_cell} ...
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=rrcReconfigurationComplete
    ...    carrier_frequency=${carrier_frequency}    srsrp_nr=10    srsrq_nr=5     ssinr_nr=10
    ...    phycell_id=${phycell_id}    nrsrp_nr=60    nrsrq_nr=40    nsinr_nr=50
    Log To Console    Validating SA forward handover...
    Validate success prints from command output    ${output}
    ...    pass_regex=*UE${ue_id}: Intra-eNB handover from EXT_ENB-2.${primary_cell} to EXT_ENB-${sim_gnb_id}.${sim_cell} performed*
    sleep    5s   reason=To stabilise traffic

Trigger Intrafreq Based SA Reverse handover
    [Arguments]    ${ue_id}    ${carrier_frequency}=127010    ${sim_gnb_id}=2    ${sim_cell}=3    ${phycell_id}=50    ${primary_cell}=1
    log to console    SA reverse handover from simulator gNB${sim_gnb_id} cell${sim_cell} to real gNB2 cell${primary_cell}
    Execute Egate Command    cmd=ue_enb_param id=${ue_id} ue_history_list=1
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=rrcReconfigurationComplete
    ...    carrier_frequency=${carrier_frequency}    srsrp_nr=11    srsrq_nr=11    phycell_id=${phycell_id}    nrsrp_nr=50    nrsrq_nr=30
    Log To Console    Validating SA reverse handover...
    Validate success prints from command output    ${output}
    ...    pass_regex=*UE${ue_id}: Intra-eNB handover from EXT_ENB-${sim_gnb_id}.${sim_cell} to EXT_ENB-2.${primary_cell} performed*
    sleep    10s   reason=To stabilise traffic txput

Trigger Intrafreq Based NSA Forward handover
    [Arguments]    ${ue_id}    ${carrier_frequency}=127010    ${primary_cell}=1    ${sim_gnb_id}=2    ${sim_cell}=3    ${phycell_id}=52
    log to console    NSA forward handover from Real gNB2 cell${primary_cell} to simulator gNB${sim_gnb_id} cell${sim_cell} ...
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=rrcConnectionReconfigurationComplete
    ...    carrier_frequency=${carrier_frequency}    srsrp_nr=10    srsrq_nr=5     ssinr_nr=10
    ...    phycell_id=${phycell_id}    nrsrp_nr=60    nrsrq_nr=40    nsinr_nr=50
    Log To Console    Validating NSA forward handover...
    Validate success prints from command output    ${output}
    ...    pass_regex=*UE${ue_id}: Sending SgNB Modification Confirm*
    sleep    10s   reason=To stabilise traffic

Trigger Intrafreq Based NSA Reverse handover
    [Arguments]    ${ue_id}    ${carrier_frequency}=127010    ${sim_gnb_id}=2    ${sim_cell}=3    ${phycell_id}=50    ${primary_cell}=1
    log to console    NSA reverse handover from simulator gNB${sim_gnb_id} cell${sim_cell} to real gNB2 cell${primary_cell}
    Execute Egate Command    cmd=ue_enb_param id=${ue_id} ue_history_list=1
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=rrcConnectionReconfigurationComplete
    ...    carrier_frequency=${carrier_frequency}    srsrp_nr=11    srsrq_nr=11    phycell_id=${phycell_id}    nrsrp_nr=50    nrsrq_nr=30
    Log To Console    Validating NSA reverse handover...
    Validate success prints from command output    ${output}
    ...    pass_regex=*UE${ue_id}: Sending SgNB Modification Confirm*
    sleep    10s   reason=To stabilise traffic txput

Trigger Interfreq XN Based SA Forward handover for 4CC
    [Arguments]    ${ue_id}    ${scell_index}    ${A2_carrier_freq}    ${A3_carrier_freq}    ${primary_cell}=1
    ...    ${sim_gnb_id}=2    ${sim_cell}=3    ${phycell_id}=52    ${srsrp_nr}=11    ${srsrq_nr}=11    ${nrsrp_nr}=30
    ...    ${nrsrq_nr}=30
    Log    ${scell_index}
    log to console    SA forward handover from Real gNB2 cell${primary_cell} to simulator gNB${sim_gnb_id} cell${sim_cell} ...
    Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport    carrier_frequency=${A2_carrier_freq}
    ...    srsrp_nr=30    srsrq_nr=30
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=Intra-eNB handover
    ...    carrier_frequency=${A3_carrier_freq}    srsrp_nr=${srsrp_nr}    srsrq_nr=${srsrq_nr}
    ...    phycell_id=${phycell_id}    nrsrp_nr=${nrsrp_nr}    nrsrq_nr=${nrsrq_nr}
    Log To Console    Validating SA forward handover...
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: CTRL_RACH_COMPLETE Received*
    Validate success prints from command output    ${output}
    ...    pass_regex=*UE${ue_id}: Intra-eNB handover from EXT_ENB-2.${primary_cell} to EXT_ENB-${sim_gnb_id}.${sim_cell} performed*
    sleep    10s   reason=To stabilise traffic txput

Trigger Interfreq XN Based SA Reverse handover for 4CC
        [Arguments]    ${ue_id}    ${scell_index}    ${A3_carrier_freq}    ${A2_carrier_freq}    ${primary_cell}=1
    ...    ${sim_gnb_id}=2    ${sim_cell}=3    ${phycell_id}=50    ${srsrp_nr}=10    ${srsrq_nr}=11    ${nrsrp_nr}=30
    ...    ${nrsrq_nr}=30
    Log    ${scell_index}
    log to console    SA reverse handover from simulator gNB${sim_gnb_id} cell${sim_cell} to real gNB2 cell${primary_cell}
    Trigger A2 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport    carrier_frequency=${A2_carrier_freq}
    ...    srsrp_nr=30    srsrq_nr=30
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=Intra-eNB handover
    ...    carrier_frequency=${A3_carrier_freq}    srsrp_nr=${srsrp_nr}    srsrq_nr=${srsrq_nr}    phycell_id=${phycell_id}
    ...    nrsrp_nr=${nrsrp_nr}    nrsrq_nr=${nrsrq_nr}
    Log To Console    Validating SA reverse handover...
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: CTRL_RACH_COMPLETE Received*
    Validate success prints from command output    ${output}
    ...    pass_regex=*UE${ue_id}: Intra-eNB handover from EXT_ENB-${sim_gnb_id}.${sim_cell} to EXT_ENB-2.${primary_cell} performed*
    sleep    10s   reason=To stabilise traffic txput