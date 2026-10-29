*** Settings ***
Resource          ../../CUDU_L2/common_setup_teardown.robot
Resource          ../../CUDU_L2/common_CA_DSS.robot


*** Keywords ***
CA UE Attach And Start DL UL Traffic
    [Arguments]    ${ue_id}    ${scell_physical_ids}    ${cc_num}    ${dl_data}    ${ul_data}
    SA 5G CA Attach    ${ue_id}
    Start SA UE Big DL Traffic Internal    ${ue_id}    ${dl_data}
    Start SA UE Big UL Traffic Internal    ${ue_id}    ${ul_data}
    Sleep    10s    reason=wait for traffic statble
    Check SA All Scell PhysicalID With UE ID    ${ue_id}    ${scell_physical_ids}    ${cc_num}

CA UE Attach And Start DL UL Traffic With A1
    [Arguments]    ${ue_id}    ${scell_physical_ids}    ${cc_num}    ${dl_data}    
                   ...    ${ul_data}    ${srsrp_nr}    ${srsrq_nr}    ${phycell_id}
    SA 5G CA Attach    ${ue_id}
    Start SA UE Big DL Traffic Internal    ${ue_id}    ${dl_data}
    Start SA UE Big UL Traffic Internal    ${ue_id}    ${ul_data}
    Trigger A1 Scell Addition With RSRQ    ${ue_id}    ${srsrp_nr}    ${srsrq_nr}    ${phycell_id}
    Sleep    10s    reason=wait for traffic statble
    Check SA All Scell PhysicalID With UE ID    ${ue_id}    ${scell_physical_ids}    ${cc_num}

Multi CA UE Attach And Start DL UL Traffic With A1
    [Arguments]    ${ca_ue_list}     ${scell_physicalid_list}    ${cc_num}    ${dl_data}    
                   ...    ${ul_data}    ${srsrp_nr}    ${srsrq_nr}    ${pcell_id_list}        
    FOR    ${ue_id}    ${phycell_id}    ${scell_physical_ids}    IN ZIP    ${ca_ue_list}    ${pcell_id_list}    ${scell_physicalid_list}
       CA UE Attach And Start DL UL Traffic With A1    ${ue_id}    ${scell_physical_ids}    
                   ...    ${cc_num}    ${dl_data}    ${ul_data}    ${srsrp_nr}    ${srsrq_nr}    ${phycell_id}
    END

Check Band Combination Selection Changed
    [Arguments]    ${pcap_file}    ${str1}    ${str2}
    BuiltIn.Log To Console    Check Band Combination Selection Changed
    cap.Read Cap    cap_file=${pcap_file}    display_filter=f1ap
    ${value1} =    cap.get_element_value    element_expression=f1ap.SelectedBandCombinationIndex    element_idx=${0}    
    ...    default_value=True    condition_expression=f1ap.SelectedBandCombinationIndex == ${str1}
    Should Contain    ${value1}    ${str1}
    ${value2} =    cap.get_element_value    element_expression=f1ap.SelectedFeatureSetEntryIndex    element_idx=${0}    
    ...    default_value=True    condition_expression=f1ap.SelectedFeatureSetEntryIndex == ${str2}
    Should Contain    ${value2}    ${str2}

Add Bad RLQ to Release Scell
    [Arguments]    ${ue_id}    ${cell}
    ute_wtssim.Execute Egate Command    cmd=bler_testmode_nr profile_id=2 target_mcs=0 num_dl_pkts=10000
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=ue_testmode_set_nr id\=${ue_id} scell=${cell} testmode=bler action=activate profile_id=2
    ...    pass_regexp=rrcReconfigurationComplete    timeout=3minutes
    Should Contain    ${output}    SCellIndex ${cell} deactivated successfully at airphone

Deactive Bad RLQ to Release Scell
    [Arguments]    ${ue_id}    ${cell}
    ute_wtssim.Execute Egate Command    cmd=ue_testmode_set_nr id\=${ue_id} scell=${cell} testmode=bler action=deactivate profile_id=2

Delete Bad RLQ
    ute_wtssim.Execute Egate Command    cmd=bler_testmode_nr delete=true profile_id=2

Trigger A1 Scell Addition With RSRQ
    [Arguments]    ${ue_id}    ${srsrp_nr}=70    ${srsrq_nr}=30    ${phycell_id}=50    ${meas_id}=${EMPTY}
    [Documentation]    This keyword is to trigger A1 scell added.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | the id of ue |
    ...    | srsrp_nr | Yes | the value of srsrp_nr |
    ...    | srsrq_nr | Yes | the value of srsrq_nr |
    ...    | phycell_id | Yes | phycell id of the cell |
    ...
    ...    Examples:
    ...    | Trigger A1 Scell Addition | 1 | 70 | 30 | 50 |
    ...
    ${meas_id_from_egate}    _Get Measurement Id From Egate Log    A1    ${ue_id}
    ${measida1}    Set Variable If    '${meas_id}'=='${EMPTY}'    ${meas_id_from_egate}    ${meas_id}
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${measida1} event=A1 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr} phycell_id=${phycell_id}
    ...    pass_regexp=rrc(Connection)?ReconfigurationComplete

Trigger A1 Scell Addition With RSRQ without complete
    [Arguments]    ${ue_id}    ${srsrp_nr}=70    ${srsrq_nr}=30    ${phycell_id}=50    ${meas_id}=${EMPTY}
    ${meas_id_from_egate}    _Get Measurement Id From Egate Log    A1    ${ue_id}
    ${measida1}    Set Variable If    '${meas_id}'=='${EMPTY}'    ${meas_id_from_egate}    ${meas_id}
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${measida1} event=A1 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr} phycell_id=${phycell_id}

Check UE DL Special CA cell TP On Target For Single UE
    [Arguments]    ${ue_id}    ${exp_dl_tput_list}
    Check CA UE Pcell Scell Cell TPut On Target    ue_id=${ue_id}    dir=dl    cell_type=pcell    scell_index=0    target_tp=${exp_dl_tput_list[0]}
    Check CA UE Pcell Scell Cell TPut On Target    ue_id=${ue_id}    dir=dl    cell_type=scell    scell_index=1    target_tp=${exp_dl_tput_list[1]}
    Check CA UE Pcell Scell Cell TPut On Target    ue_id=${ue_id}    dir=dl    cell_type=scell    scell_index=3    target_tp=${exp_dl_tput_list[2]}
    Check CA UE Pcell Scell Cell TPut On Target    ue_id=${ue_id}    dir=dl    cell_type=scell    scell_index=4    target_tp=${exp_dl_tput_list[3]}

Configure 2CELL DSS
    [Arguments]    ${ENB_CELL_1}    ${ENB_CELL_2}    ${ANTP_NUM}    ${mindl_dss_ratio}    ${maxdl_dss_ratio}    
                   ...    ${minul_dss_ratio}    ${maxul_dss_ratio}    ${DL_PRB_LIST}    ${UL_PRB_LIST}    ${NORMAL_SUBFRAME}
    Setup X2 Connection    2    1
    Setup XP LINK    2    1
    ute_wtssim.Execute Egate Command    cmd=enb_disp id=2 type=xp_info
    Enable DSS DMS3 Feature On    2
    Set LTE NR DSS Mode PHASE3    2    ${ENB_CELL_1}    ${ANTP_NUM}
    Set LTE NR DSS Mode PHASE3    2    ${ENB_CELL_2}    ${ANTP_NUM}
    Setup DSS Link PHASE3    2    1    ${ENB_CELL_1}
    Setup DSS Link PHASE3    2    1    ${ENB_CELL_2}
    Set DL RESOURCE Cell Reservation    ${mindl_dss_ratio}    ${maxdl_dss_ratio}    2    ${ENB_CELL_1}
    Set DL RESOURCE Cell Reservation    ${mindl_dss_ratio}    ${maxdl_dss_ratio}    2    ${ENB_CELL_2}
    Cell Resource Coordination PHASE3    2    1    ${ENB_CELL_1}    DL
    Cell Resource Coordination PHASE3    2    1    ${ENB_CELL_2}    DL
    UL Resource Cell Reservation    ${minul_dss_ratio}    ${maxul_dss_ratio}    2    1    ${ENB_CELL_1}
    UL Resource Cell Reservation    ${minul_dss_ratio}    ${maxul_dss_ratio}    2    1    ${ENB_CELL_2}
    Cell Allocation    ${NORMAL_SUBFRAME}    ${UL_PRB_LIST}    2    1    ${ENB_CELL_1}    ${DL_PRB_LIST}
    Cell Allocation    ${NORMAL_SUBFRAME}    ${UL_PRB_LIST}    2    1    ${ENB_CELL_2}    ${DL_PRB_LIST}
    common_setup_teardown.UE SIB Decoding Should Be Successful
    Sleep    10s    reason=waiting for SIB for all cells

Adjust Sinr Target Pathloss
    [Arguments]    ${ue_id}=1    ${sinr_target_pathloss}=150
    ute_wtssim.Execute Egate Command
    ...    cmd=ul_sinr_testmode_nr profile_id=1 pathloss=${sinr_target_pathloss}
    ${command}    Set Variable    ue_testmode_set_nr id\=${ue_id} testmode=ul_sinr action=activate profile_id=1
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}
    ...    pass_regexp=rrc-TransactionIdentifier \\d+,\\s+\\S+ rrcReconfigurationComplete
    ...    timeout=3minutes

Deactive Pathloss
    [Arguments]    ${ue_id}=1    ${profile_id}=1
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_testmode_set_nr id\=${ue_id} testmode=ul_sinr action=deactivate profile_id=${profile_id}
    ...    cmd=ul_sinr_testmode_nr profile_id=${profile_id} delete=on

CA UE Attach Multi RAB with A1
    [Arguments]    ${ue_id}    ${scell_physical_ids}    ${cc_num}    ${dl_data_1}    
                   ...    ${ul_data_1}    ${dl_data_2}    ${ul_data_2} 
    ...    ${srsrp_nr}    ${srsrq_nr}    ${phycell_id}
    SA 5G CA Attach    ${ue_id}
    ute_wtssim.Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=2 trf_type=internal
    ute_wtssim.Execute Egate Command    cmd=ue_pdu_session_setup pdu=2 ue=${ue_id} nwslice=1 gw=2
    sleep    1s    reason=wait RAB setup
    ute_wtssim.Execute Egate Command    cmd=ue_pdu_session_modify ue=${ue_id} pdu=2 qosflows_to_add=2 by=amf
    sleep    1s    reason=wait RAB setup
    ute_wtssim.Execute Egate Command    cmd=ue_pdu_session_modify ue=${ue_id} pdu=2 qosflows_to_add=3 by=amf
    sleep    1s    reason=wait RAB setup
    Trigger A1 Scell Addition With RSRQ    ${ue_id}    ${srsrp_nr}    ${srsrq_nr}    ${phycell_id}
    sleep    1s    reason=wait Scell addition
    Start SA Internal Traffic    ${ue_id}    ${dl_data_2}    dl    2    1    3 
    Start SA Internal Traffic    ${ue_id}    ${ul_data_2}    ul    2    1    3
    Sleep    5s    reason=wait for traffic statble
    Start SA UE Big DL Traffic Internal    ${ue_id}    ${dl_data_1}
    Start SA UE Big UL Traffic Internal    ${ue_id}    ${ul_data_1}
    Sleep    5s    reason=wait for traffic statble
    Check SA All Scell PhysicalID With UE ID    ${ue_id}    ${scell_physical_ids}    ${cc_num}
    Sleep    5s    reason=wait for traffic statble

CA UE Attach Multi RAB with A1 without complete
    [Arguments]    ${ue_id}    ${scell_physical_ids}    ${cc_num}    
                   ...    ${dl_data_1}    ${ul_data_1}    ${dl_data_2}    ${ul_data_2} 
    ...    ${srsrp_nr}    ${srsrq_nr}    ${phycell_id}
    SA 5G CA Attach    ${ue_id}
    ute_wtssim.Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=2 trf_type=internal
    ute_wtssim.Execute Egate Command    cmd=ue_pdu_session_setup pdu=2 ue=${ue_id} nwslice=1 gw=2
    sleep    1s    reason=wait RAB setup
    ute_wtssim.Execute Egate Command    cmd=ue_pdu_session_modify ue=${ue_id} pdu=2 qosflows_to_add=2 by=amf
    sleep    1s    reason=wait RAB setup
    ute_wtssim.Execute Egate Command    cmd=ue_pdu_session_modify ue=${ue_id} pdu=2 qosflows_to_add=3 by=amf
    sleep    1s    reason=wait RAB setup
    Trigger A1 Scell Addition With RSRQ without complete    ${ue_id}    ${srsrp_nr}    ${srsrq_nr}    ${phycell_id}
    sleep    1s    reason=wait Scell addition
    Start SA Internal Traffic    ${ue_id}    ${dl_data_2}    dl    2    1    3 
    Start SA Internal Traffic    ${ue_id}    ${ul_data_2}    ul    2    1    3 
    Sleep    5s    reason=wait for traffic statble
    Start SA UE Big DL Traffic Internal    ${ue_id}    ${dl_data_1}
    Start SA UE Big UL Traffic Internal    ${ue_id}    ${ul_data_1}
    Sleep    60s    reason=wait for traffic statble
    Check SA All Scell PhysicalID With UE ID    ${ue_id}    ${scell_physical_ids}    ${cc_num}
    Sleep    5s    reason=wait for traffic statble

Check DRX Profile
    [Arguments]   ${drx-onDurationTimer}=ms10    ${drx-InactivityTimer}=ms10    ${drx-LongCycleStartOffset}=ms40
    [Documentation]    This keyword is to check the latest one DRX profile parameter from egate_console.log
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${ret1}=    OperatingSystem.Run    grep -A 10 "drx-Config setup" /opt/iphy/latest/egate_console.log|tail -11
    Should Contain    ${ret1}=    drx-Config setup
    Should Contain    ${ret1}=    drx-onDurationTimer milliSeconds : ${drx-onDurationTimer}
    Should Contain    ${ret1}=    drx-InactivityTimer ${drx-InactivityTimer}
    Should Contain    ${ret1}=    drx-LongCycleStartOffset ${drx-LongCycleStartOffset}
    
Verfiy Scells Are Activation
    [Arguments]    ${scell_nums}
    Log To Console    \nverify Scell Info...
    FOR    ${id}    IN RANGE    1    ${scell_nums}
    ${scell_activation}    Set Variable    SCellIndex ${id} activated successfully at airphone.
    ${check_rst}    Run    cat /opt/iphy/latest/egate_console.log|grep -A 300 
                   ...    'SCellIndex ${id} deactivated successfully at airphone'|grep -i "${scell_activation}"|wc -l
    Should Be True    ${check_rst}==1
    END
    
Stop SA Internal Traffic
    [Arguments]    ${ue_id}    ${dir_id}=dl    ${pdu_id}=1
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue\=${ue_id} pdu\=${pdu_id} dir=${dir_id}
    
Check Whether UE In CA Mode
    [Arguments]    ${ue_id}=1    ${ca_num}=1
    ${output}=    ute_wtssim.Execute Egate Command And Wait For Data     cmd=ue_stats_nr id\=${UE_ID} type=pdsch scell=0-31    pass_regexp=EGATE
    Log    ${output}
    Should Contain X Times    ${output}    CellIndex-    ${ca_num}   msg=UE is not in ${ca_num} CC mode
    
Multi RAB setup
    [Arguments]    ${ue_id}    ${pdu}    ${qosflows}    ${dl_data}    ${ul_data}
    ute_wtssim.Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu\=${pdu} trf_type=internal
    ute_wtssim.Execute Egate Command    cmd=ue_pdu_session_setup pdu\=${pdu} ue=${ue_id} nwslice=1 gw\=${pdu}
    Sleep    1s    reason=wait RAB setup
    ute_wtssim.Execute Egate Command    cmd=ue_pdu_session_modify ue=${ue_id} pdu\=${pdu} qosflows_to_add\=${qosflows} by=amf
    Sleep    1s    reason=wait RAB setup
    Start SA Internal Traffic    ${ue_id}    ${dl_data}    dl    ${pdu}    1    2 
    Start SA Internal Traffic    ${ue_id}    ${ul_data}    ul    ${pdu}    1    2 
    Sleep    2s    reason=wait for traffic statble
    
Check CG Config
    [Arguments]   ${pos}=pos1
    [Documentation]    This keyword is to check the latest one DRX profile parameter from egate_console.log
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${ret1}=    OperatingSystem.Run    grep -A 10 "configuredGrantConfig setup" /opt/iphy/latest/egate_console.log|tail -11
    Should Contain    ${ret1}=    dmrs-AdditionalPosition ${pos}
    
CA UE Attach Multi RAB without VoNR with A1
    [Arguments]    ${ue_id}    ${scell_physical_ids}    ${cc_num}    ${dl_data_1}    
                   ...    ${ul_data_1}    ${dl_data_2}    ${ul_data_2} 
    ...    ${srsrp_nr}    ${srsrq_nr}    ${phycell_id}    ${pdu}    ${qosflows}
    SA 5G CA Attach    ${ue_id}
    ute_wtssim.Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu\=${pdu} trf_type=internal
    ute_wtssim.Execute Egate Command    cmd=ue_pdu_session_setup pdu\=${pdu} ue=${ue_id} nwslice=1 gw\=${pdu}
    sleep    1s    reason=wait RAB setup
    ute_wtssim.Execute Egate Command    cmd=ue_pdu_session_modify ue=${ue_id} pdu\=${pdu} qosflows_to_add\=${qosflows} by=amf
    sleep    1s    reason=wait RAB setup
    Trigger A1 Scell Addition With RSRQ    ${ue_id}    ${srsrp_nr}    ${srsrq_nr}    ${phycell_id}
    sleep    1s    reason=wait Scell addition
    Start SA Internal Traffic    ${ue_id}    ${dl_data_2}    dl    ${pdu}    1    2 
    Start SA Internal Traffic    ${ue_id}    ${ul_data_2}    ul    ${pdu}    1    2    
    Sleep    5s    reason=wait for traffic statble
    Start SA UE Big DL Traffic Internal    ${ue_id}    ${dl_data_1}
    Start SA UE Big UL Traffic Internal    ${ue_id}    ${ul_data_1}
    Sleep    20s    reason=wait for traffic statble
    Check SA All Scell PhysicalID With UE ID    ${ue_id}    ${scell_physical_ids}    ${cc_num}
    Sleep    5s    reason=wait for traffic statble
    
Start SA Internal Traffic
    [Arguments]    ${ue}    ${mbps}    ${trf_type}=dl    
                   ...    ${pdu_id}=1    ${trf_id}=1    ${qfi_id}=1
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue} pdu\=${pdu_id} qfi\=${qfi_id} dir=${trf_type} mbps\=${mbps} trf_id\=${trf_id} seconds=6000
     
Update Egate log
    ute_wtssim.Execute Egate Command    cmd=set_log flush
    
Verfiy Scells Are Deactivation
    [Arguments]    ${scell_list}=${dlonly_scell_index}
    Log To Console    \nverify Scell Deactivation Info...
    ute_wtssim.Execute Egate Command    sim_log_set flush
    FOR    ${id}    IN    @{scell_list}
    ${scell_deactivation}    Set Variable    SCellIndex ${id} deactivated successfully.
    ${check_rst}    Run    cat /opt/iphy/latest/egate_console.log|grep -i "${scell_deactivation}"|wc -l
    Should Be True    ${check_rst}>=1
    END