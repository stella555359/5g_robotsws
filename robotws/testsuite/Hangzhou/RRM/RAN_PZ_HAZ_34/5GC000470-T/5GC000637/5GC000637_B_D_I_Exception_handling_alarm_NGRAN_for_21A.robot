# # #*** Settings ***
# # #Force Tags    PY36
# # #Documentation     author: cris cai
# # #...                 contact: cris.cai@nokia-sbell.com
# # #...                 squad group: SG_03
# # #...                 feature : 5GC000637-B-D-I
# # ##Force Tags                 CIT_21A
# # #Resource    ../../5GC000637/Resources/Common_intergration_keywords.robot
# # #Resource    ../../5GC000637/Resources/5GC000637_feature_keywords.robot
# # #Variables    Resources/Test_Parameters.py
# # #
# # #Suite Setup    run keywords     Run Keyword And Ignore Error    Common Suite Setup for COAM    AND
# # #...     Setup Environment for case    mcc=${mcc}    mnc=${mnc}    length=@{length}[1]
# # ##...    set and check value of parameter administrativeState on MO SNSSAI    value=Locked    new_value=Locked    AND
# # ##...    set and check value of parameter administrativeState on MO SNSSAI    value=Locked    new_value=Locked
# # ##...    connect_IP=${WEBUI_COAM_PEER}    AND
# # #
# # #Suite Teardown    Run Keyword And Ignore Error    Delete all NRADJGNB object
# # #
# # #*** Variables ***
# # #@{xnlogname}    637_B_01.pcap    637_B_02.pcap    637_B_04.pcap
# # #${XN_Failure}    xnap.XnAP_PDU == 2 and xnap.procedureCode == 17
# # #${tl_scf_dir_path}    /opt/workspace/CIT/Master/Scf_files/
# # #${FaultId}    7311
# # #${AlarmId}    7107
# # #@{NGlogname}             637_I.pcap
# # #@{cellid}                1    2
# # #@{gnb_filter}    xnap.served_Cells_ToDelete_NR == 1    xnap.served_Cells_ToAdd_NR == 1
# # #...    xnap.served_Cells_ToModify_NR == 1
# # #${counter_value}         0
# # #${counter_value_peer}    0
# # #
# # #*** Test Cases ***
# # #[1]5GC000637_B_001_Xn_Setup_Request_received_from_neighboring_gNB_crossing_case
# # #    [Documentation]    This case is used to verifyied that gNB receives Xn Setup Request from peer gNB (crossing case).
# # #    [Tags]    5GC000637-B    SA    classical
# # #    [Setup]
# # #    Modify the administrative state for both gNB    admin_state=@{admin_state}[0]
# # #    wait until keyword succeeds    10 min    10 sec    Check XNLINK status for both gNB on webUI    xn_status=available
# # #    Modify the administrative state for Local gNB    local_distname=${distname_id_1}    admin_state=Locked
# # #    Modify the administrative state for Peer gNB    peer_distname=${distname_id_2}    admin_state=Locked
# # #    Start To Capture Logs    xnlogname=@{xnlogname}[0]    interface=br1
# # #    Modify the administrative state for Local gNB    local_distname=${distname_id_1}    admin_state=Unlocked
# # #    sleep    35s
# # #    Stop and Save Logs    xnlogname=@{xnlogname}[0]
# # #    sleep    2s
# # #    check IE wireshark log for xn setup failure message
# # #    ...    logname=@{xnlogname}[0]    message_filter=${XN_Failure}
# # #    sleep    5s
# # #    Start To Capture Logs    xnlogname=@{xnlogname}[1]    interface=br1
# # #    Modify the administrative state for Peer gNB    peer_distname=${distname_id_2}    admin_state=Unlocked
# # #    sleep    35s
# # #    Stop and Save Logs    xnlogname=@{xnlogname}[1]
# # #    sleep    2s
# # #    ${plmn}    Plmn exchange to code mode    mcc=${mcc}    mnc=0${mnc}
# # #    ${tac_exp}    convert to hex    ${tac}    lowercase=true
# # #    check IE wireshark log for xn setup request message    xnlogname=@{xnlogname}[1]    plmn=${plmn}    tac_exp=000${tac_exp}
# # #    check IE wireshark log for xn setup response message
# # #    ...    xnlogname=@{xnlogname}[1]    plmn=${plmn}    tac_exp=000${tac_exp}    band_log=004c
# # #    [Teardown]    Recover for case 001
# # #
# # #[1]5GC000637_B_004_Xn_Setup_rejected_by_gNB_initiating_nodeType_is_not_a_gNB
# # #    [Documentation]    This case is used to verifyied that Xn Setup rejected by gNB, gNB send XN setup failure
# # #    ...    withinitiating_nodeType_is_not_a_gNB only for 19B modification
# # #    [Tags]    5GC000637-B    SA    classical
# # #    [Setup]
# # #    Run Keyword And Ignore Error    Modify the administrative state for both gNB    admin_state=@{admin_state}[0]
# # #    Check XNLINK status for both gNB on webUI    xn_status=available
# # #    Modify new parameter value for gNB    url=${WEBUI_COAM_LOCAL}    dist_name=${distname_id_1}/NRADJGNB-1
# # #    ...    filter_name=gNodeB Id    new_value=${11111}
# # #    sleep    10s
# # #    Modify the administrative state for Peer gNB    peer_distname=${distname_id_2}    admin_state=Locked
# # #    Start To Capture Logs    xnlogname=@{xnlogname}[2]    interface=br1
# # #    Modify the administrative state for Peer gNB    peer_distname=${distname_id_2}    admin_state=Unlocked
# # #    sleep    100s
# # #    Stop and Save Logs    xnlogname=@{xnlogname}[2]
# # #    Check webui alarm    dist_name_alarm=${distname_id_1}/NRADJGNB-1    dist_name_mrbts=MRBTS-${tl.gnbs[0].instance_id}
# # #    ...    alarm_id=7107    coam_url=${WEBUI_COAM_LOCAL}
# # #    [Teardown]    Run Keyword And Ignore Error    Recover for case 004
# # #
# # #[1]5GC000637_D_002_Xn(gNB)_alarm_handling_in_case_of_Xn_Setup_error
# # #    [Documentation]    Creation of Xn link object in "Locked" state and check Xnlink status should be unavailable
# # #    [Tags]    5GC000637-D    SA    classical
# # #    [Timeout]    40 minutes
# # #    [Setup]
# # #    Run Keyword And Ignore Error    Modify new parameter value for gNB    url=${WEBUI_COAM_LOCAL}
# # #    ...    dist_name=${distname_id_1}/NRADJGNB-1    filter_name=gNodeB Id    new_value=${1035}
# # #    Run Keyword And Ignore Error    Modify new parameter value for gNB    url=${WEBUI_COAM_LOCAL}
# # #    ...    dist_name=${distname_id_1}/NRADJGNB-1    filter_name=Xn link reference    new_value=1
# # #    [Teardown]    Disconnect all connections
# # #
# # #[1]5GC000637_D_003_Xn_alarm_clearing
# # #    [Documentation]    Online modify administrative state and can be active instead of reboot BTS
# # #    [Tags]    5GC000637-D    SA    classical
# # #    [Timeout]    30 minutes
# # #    [Setup]
# # #    Check XNLINK status available for both gNB on webUI
# # #    [Teardown]    Disconnect all connections
# # #
# # #[1]5GC000637_I_003_Xn_NGRAN_Node_configuration_update_successful_cell_modify
# # #    [Documentation]    This case is used to verifyied that NG-RAN Node Configuration Update procedure triggered by
# # #    ...    addition of a new cell modifyed
# # #    [Tags]    5GC000637-X    SA    classical
# # #    [Timeout]    40 minutes
# # #    [Setup]
# # #    Start To Capture Logs    xnlogname=@{NGlogname}[0]    interface=br1
# # #    #Modify Cell info for local gNB
# # #    sleep    2s
# # #    lock Cell info for gNB    WEBUI_COAM=${WEBUI_COAM_LOCAL}    cell_id=@{cellid}[0]
# # #    sleep    30s
# # #    unlock Cell info for gNB    WEBUI_COAM=${WEBUI_COAM_LOCAL}    cell_id=@{cellid}[0]
# # #    sleep    2s
# # #    Stop and Save Logs    xnlogname=@{NGlogname}[0]
# # #    sleep    2s
# # #    #check IE wireshark log for NGRAN node configuration update    log_name=@{NGlogname}[0]    filter=@{gnb_filter}[2]
# # #    check IE wireshark log for NGRAN node configuration update    log_name=@{NGlogname}[0]    filter=@{gnb_filter}[0]
# # #    check IE wireshark log for NGRAN node configuration update    log_name=@{NGlogname}[0]    filter=@{gnb_filter}[1]
# # #    check IE wireshark log for NGRAN node configuration update ack    log_name=@{NGlogname}[0]
# # #    Check XNLINK status for both gNB on webUI    xn_status=available
# # #    sleep    4mins
# # #    Check counters
# # #    [Teardown]    Disconnect all connections
# # #
# # #*** Keywords ***
# # #Check counters
# # #    Login coam webui    WEBUI_COAM=${WEBUI_COAM_LOCAL}
# # #    ${btsname}=    selenium_coam.get_parameter_value    dist_name=MRBTS-${tl.gnbs[0].instance_id}
# # #    ...    filter_param=BTS name
# # #    ...    abbr=btsName
# # #    ${M55126C00029}=    Get bts counter
# # #    ...    counter_id=M55126C00029    full_path=[${btsname}] BTS/NRBTS-${tl.gnbs[0].instance_id}/NXNCB/XN_NGRAN_CONF_UPDATE_SENT
# # #    Login coam webui    WEBUI_COAM=${WEBUI_COAM_PEER}
# # #    ${btsname_1}=    selenium_coam.get_parameter_value    dist_name=MRBTS-${tl.gnbs[1].instance_id}
# # #    ...    filter_param=BTS name
# # #    ...    abbr=btsName
# # #    ${M55126C00033_peer}=    Get bts counter
# # #    ...    counter_id=M55126C00033    full_path=[${btsname_1}] BTS/NRBTS-${tl.gnbs[1].instance_id}/NXNCB/XN_NGRAN_CONF_UPDATE_ACK_SENT
# # #    :For    ${i}    IN    @{M55126C00029}
# # #    \    ${counter_value}=   evaluate     ${counter_value}+${i}
# # #    should be true    ${counter_value}==2
# # #    :For    ${i}    IN    @{M55126C00033_peer}
# # #    \    ${counter_value_peer}=   evaluate     ${counter_value_peer}+${i}
# # #    should be true    ${counter_value_peer}==2
# # #
# # #check IE wireshark log for NGRAN node configuration update
# # #    [Arguments]     ${filter}    ${log_name}
# # #    cap.read_cap      cap_file=${epc_log_path}${log_name}    display_filter=xnap
# # #    ${Message_Type} =    Catenate    ${filter}
# # #    cap.Check Expression    condition_expression=${Message_Type}
# # #    #${NR_Cell_Identity} =    cap.get_element_value    element_expression=xnap.NR-Cell-Identity
# # #    #...    condition_expression=${filter}    element_idx=${0}
# # #    #should be equal    ${NR_Cell_Identity[0]}    0010480010
# # #
# # #check IE wireshark log for NGRAN node configuration update ack
# # #    [Arguments]     ${log_name}
# # #    cap.read_cap      cap_file=${epc_log_path}${log_name}    display_filter=xnap
# # #    ${Message_Type} =    Catenate    xnap.RespondingNodeTypeConfigUpdateAck == 1
# # #    cap.Check Expression    condition_expression=${Message_Type}
# # #
# # #check IE wireshark log for xn setup failure message
# # #    [Arguments]     ${logname}    ${message_filter}
# # #    ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${logname}
# # #    ${Message_Type} =    Catenate    ${message_filter}
# # ##    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${Message_Type}
# # #    filter_packets_by_expression    filter_expression=${Message_Type}
# # ##    ${XnSetupFailure}=    filter_packets_by_expression    pdml_list=${all_packets}    filter_expression=${Message_Type}
# # #    ${XnSetupFailure}=    filter_packets_by_expression    filter_expression=${Message_Type}
# # #    ${Cause}=    get_field_value_by_xpath
# # ##    ...    pdml_list=${XnSetupFailure}    xpath=.//xnap.ProtocolIE_Field_element//xnap.id
# # #    ...    xpath=.//xnap.ProtocolIE_Field_element//xnap.id
# # #    should be equal    ${Cause[0]}   7
# # #    ${criticality}=    get_field_value_by_xpath
# # ##    ...    pdml_list=${XnSetupFailure}    xpath=.//xnap.ProtocolIE_Field_element/xnap.criticality
# # #    ...    xpath=.//xnap.ProtocolIE_Field_element/xnap.criticality
# # #    should be equal    ${criticality[0]}    1
# # ##    ${misc} =    get_field_value_by_xpath    pdml_list=${XnSetupFailure}    xpath=.//xnap.misc
# # #    ${misc} =    get_field_value_by_xpath    xpath=.//xnap.misc
# # #    should be equal    ${misc[0]}    2
# # #
# # #Recover for case 001
# # #    Run Keyword And Ignore Error
# # #    ...    Modify the administrative state for Peer gNB    peer_distname=${distname_id_2}    admin_state=Unlocked
# # #    Run Keyword And Ignore Error
# # #    ...    Modify the administrative state for Local gNB    local_distname=${distname_id_1}    admin_state=Unlocked
# # #    sleep    10s
# # #    Disconnect all connections
# # #
# # #Set test variables
# # #    ${release_info} =    Get gnb release
# # #    set suite variable    ${interface}    ${para_store['${release_info}']['interface']}
# # #    set suite variable    ${tac_exp}    ${para_store['${release_info}']['tac']}
# # #    set suite variable    ${plmn}    ${para_store['${release_info}']['plmn']}
# # #    set suite variable    ${mcc}    ${para_store['${release_info}']['mcc']}
# # #    set suite variable    ${mnc}    ${para_store['${release_info}']['mnc']}
# # #
# # #Check webui alarm
# # #    [Arguments]    ${dist_name_alarm}    ${dist_name_mrbts}    ${alarm_id}    ${coam_url}
# # #    selenium_coam.enable_virtual_display
# # #    wait until keyword succeeds    2min   20s    selenium_coam.login    url=${coam_url}
# # #    ...    username=${WEBUI_NAME}    password=${WEBUI_PWD}
# # #    ${btsname}=    selenium_coam.get_parameter_value    dist_name=${dist_name_mrbts}
# # #    ...    filter_param=BTS name
# # #    ...    abbr=btsName
# # #    @{result_0}    selenium_coam.get_active_alarm_info    alarm_filter=[${btsname}] ${dist_name_alarm}
# # #    &{fault_dic_0}   set variable    @{result_0}[0]
# # #    ${alarm_id_0}    set variable    &{fault_dic_0}[Alarm ID]
# # #    should be equal     ${alarm_id_0}     ${alarm_id}
# # #
# # #Recover for case 004
# # #    Run Keyword And Ignore Error    Modify new parameter value for gNB    url=${WEBUI_COAM_LOCAL}
# # #    ...    dist_name=${distname_id_1}/NRADJGNB-1    filter_name=gNodeB Id    new_value=${tl.gnbs[1].instance_id}
# # #    Run Keyword And Ignore Error    Modify new parameter value for gNB    url=${WEBUI_COAM_LOCAL}
# # #    ...    dist_name=${distname_id_1}/NRADJGNB-1    filter_name=Xn link reference    new_value=1
# # #    Disconnect all connections
