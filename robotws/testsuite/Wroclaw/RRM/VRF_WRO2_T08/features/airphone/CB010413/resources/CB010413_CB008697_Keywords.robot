*** Settings ***

Documentation    :copyright: Nokia

Resource    ../../../../../resources/airphone/5G_SW_WRO_Keywords.robot
Resource    CB010413_CB008697_Variables.robot
Library     CB010413_CB008697_Keywords.py
Library     ta5g_pm_counters
Library     ta5g_iphy
Library     ta5g_enb
Library     ta5g_testline_management
Library     ta5g_ue_measurements
Library     ta5g_throughput
Library     ta5g_cell_operations
Library     taf.gnb.oam.coam.cu
Library     CB010413.py

*** Keywords ***
Start Additional Vm Ethernet Interfaces
    Start Vm Ethernet Interface    if_name=eth3:GNB3_NG    ip_with_mask=10.0.11.100/24
    Start Vm Ethernet Interface    if_name=eth3:GNB3_XN    ip_with_mask=10.0.12.100/24
    Start Vm Ethernet Interface    if_name=eth3:GNB3_S1U_X2    ip_with_mask=10.0.1.11/24
    Start Vm Ethernet Interface    if_name=eth3:GNB3_PROXY   ip_with_mask=10.0.2.90/24

Stop Additional Vm Ethernet Interfaces
    Stop Vm Ethernet Interface    if_name=eth3:GNB3_NG    ip_with_mask=10.0.11.100/24
    Stop Vm Ethernet Interface    if_name=eth3:GNB3_XN    ip_with_mask=10.0.12.100/24
    Stop Vm Ethernet Interface    if_name=eth3:GNB3_S1U_X2    ip_with_mask=10.0.1.11/24
    Stop Vm Ethernet Interface    if_name=eth3:GNB3_PROXY   ip_with_mask=10.0.2.90/24

Reset Testline And Wait For Rmods And Collect Logs
    Start Default Logging    output_dirpath=${OUTPUT_DIR}/reset_testline
    Trigger Site Reset
    Check Radios Availability
    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/reset_testline

Check Activation Of Overheating Assistance Information
    Verify Tcpdump Log    packet_filter=${UE_CAPABILITIES_OH}
    Verify Tcpdump Log    packet_filter=${RRC_RECONFIGURATION_OH}

Check Activation Of Overheating Assistance Information For Second UE
    Verify Tcpdump Log    packet_filter=${RRC_RECONFIGURATION_OH_UE2}

Add XN Interface Addresses
    Add XN Interface Address    10.0.1.101    24    eth3
    Add XN Interface Address    10.0.1.102    24    eth3

Enable XN Link
    Perform Parameter Commissioning Aic    dist_name=MRBTS-1/NRBTS-1/NRADJGNB-1    parameter=administrativeState    value=Unlocked

Disable XN Link
    Perform Parameter Commissioning Aic    dist_name=MRBTS-1/NRBTS-1/NRADJGNB-1     parameter=administrativeState    value=Locked

Set Internal Traffic Type To Ue With Multiple Pdu Sessions
    [Arguments]    ${ue_id}
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=2 trf_type=internal
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=3 trf_type=internal
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=4 trf_type=internal

Set Internal Traffic Type To Ue With One Pdu Session
    [Arguments]    ${ue_id}    ${pdu}=1
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal

Send A2 Event Related To SCell Release
    [Arguments]    ${ue_id}=20    ${meas_id}=6    ${scell}=1
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} scell=${scell} scell_rsrp=10 scell_rsrq=12 event=A2
    ...    pass_regexp=message c1 : rrcReconfigurationComplete

Send A2 Event For A5 Configuration
    [Arguments]    ${ue_id}    ${meas_id}    ${srsrp_nr}=1    ${srsrq_nr}=1
    ...            ${pass_regexp}=message c1 : rrcReconfigurationComplete

    Send Custom Ue Measurement Nr    pass_regexp=${pass_regexp}
    ...                              id=${ue_id}    event=A2    meas_id=${meas_id}
    ...                              srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}

Send A5 Event To Trigger Ho
    [Arguments]      ${ue_id}=1    ${meas_id}=1    ${srsrq_nr}=1    ${srsrp_nr}=1    ${ssinr_nr}=1    ${phycell_id}=50
    ...              ${nrsrq_nr}=1    ${nrsrp_nr}=1    ${nsinr_nr}=1
    ...              ${pass_regexp}=message c1 : rrcReconfigurationComplete

    Send Custom Ue Measurement Nr    pass_regexp=${pass_regexp}
    ...                              id=${ue_id}    event=A5    meas_id=${meas_id}
    ...                              srsrq_nr=${srsrq_nr}    srsrp_nr=${srsrp_nr}    ssinr_nr=${ssinr_nr}
    ...                              phycell_id=${phycell_id}    nrsrq_nr=${nrsrq_nr}    nrsrp_nr=${nrsrp_nr}    nsinr_nr=${nsinr_nr}

Start Big Dl Data Transfer And Check If Only One SCell Is Activated
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=20 dir=dl mbps=175 pdu=1; trf_data_start ue=20 dir=dl mbps=175 pdu=2; trf_data_start ue=20 dir=dl mbps=175 pdu=3
    ...    pass_regexp=SCellIndex 2 activated successfully at airphone.
    ...    fail_regexp=SCellIndex 1 activated successfully at airphone.

Start Dl Data Transfer And Check If SCell Is Activated
    [Arguments]    ${ue_id}    ${pdu}
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} dir=dl mbps=175 pdu=${pdu}
    ...    pass_regexp=SCellIndex 1 activated successfully at airphone.
    ...    timeout=10

Send Overheating Assistance And Check If SCell Is Deactivated
    [Arguments]    ${ue_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_assistance_send_nr ue_id=${ue_id} forOverheating=yes reducedCCsDL=0
    ...    pass_regexp=SCellIndex 1 deactivated successfully at airphone.
    ...    timeout=10

Trigger Rrc Reestablishment
    [Arguments]    ${ue_id}    ${gnb}=2    ${cell}=1
    Execute Egate Command And Wait For Data
    ...    cmd=ue_rrc_reestablish id=${ue_id} gnb=${gnb} cell=${cell}
    ...    pass_regexp=Initial Context Setup Successful
    ...    timeout=10

Modify Logging Levels For Traffic
    Execute Egate Command    cmd=log_sim_debug level=6 uec=1
    Execute Egate Command    cmd=log_sim_debug level=6 upf=1

Postpone RRC Reconfiguration Response
    [Arguments]    ${ue_id}=10    ${time}=2s
    UE NR RRC Reconf Param    ue_id=${ue_id}  if_contains=any    action=none    delay=${time}

Send A1 event for S-Cell Addition
    [Arguments]    ${ue_id}=1    ${meas_id}=2    ${srsrp}=127    ${srsrq}=127    ${ssinr}=127
    ...            ${pass_regexp}=message c1 : rrcReconfigurationComplete
    Send Custom Ue Measurement Nr    pass_regexp=${pass_regexp}    timeout=60
    ...                              id=${ue_id}    meas_id=${meas_id}    event=A1
    ...                              srsrq_nr=${srsrq}    srsrp_nr=${srsrp}    ssinr_nr=${ssinr}
    Sleep    1s    reason=Waiting for AP to finalize internal S-Cell addition

Perform A1 PCell Switch And Verify If Handover Is Successful
    [Arguments]    ${ue_id}=10    ${meas_id}=2
    Send Custom Ue Measurement Nr    id=${ue_id} meas_id=${meas_id} event=A1 scell=1 scell_rsrp=127 scell_sinr=127 scell_rsrq=127
    ...                              pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.5 performed

Send Empty Ue Assistance Nr
    [Arguments]    ${ue_id}=1
    Execute Egate Command     cmd=ue_assistance_send_nr ue_id=${ue_id} forOverheating=yes

Check Counters Related To CellLoad Based Deactivation
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Run Keyword And Continue On Failure    Verify Any Counters In File
    ...    M55118C07504    >0    NUM_REQ_1_SCELL_ALLOW_OVH
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${pm_counter_file}

Send A2 Event Related To SCell Release And Send OH Assistance In Quick Succession
    [Arguments]    ${ue_id}=10
    Send Custom Ue Measurement Nr   id=${ue_id}    meas_id=6    scell=2    scell_rsrp=1 scell_rsrq=1    event=A2
    Sleep    1.5s    reason=Waiting for RRC Reconfiguration Reception
    Execute Egate Command And Wait For Data
    ...    cmd=ue_assistance_send_nr ue_id=20 forOverheating=yes reducedCCsDL=0
    ...    pass_regexp=SCellIndex 1 deactivated successfully at airphone.*SCellIndex 2 deactivated successfully at airphone.
    ...    timeout=10

Verify M55118C07501 And M55118C07503 Counters For Overheating Reports
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55118C07501    1    NUM_UE_OVH_REPORTS
    ...    M55118C07503    1    NUM_REQ_1_SCELL_ALLOW_OVH
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2
    ...    file_path=${pm_counter_file}

Release S-Cell And Send Overheating Assistance In Quick Succession
    [Arguments]    ${ue_id}=10
    Execute Egate Command   cmd=ue_measurement_send_nr event=A2 meas_id=6 id=${ue_id} scell=1 scell_rsrp=1 scell_rsrq=1
    Sleep   1s    reason=Waiting for RRC Reconfiguration Reception
    Execute Egate Command   cmd=ue_assistance_send_nr ue_id=${ue_id} forOverheating=yes reducedCCsDL=0

Verify Counter For Overheating Reports
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55118C07501    0    NUM_UE_OVH_REPORTS
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counter_file}
