*** Settings ***
Library    ute_wtssim
Library		OperatingSystem
LIbrary		BuiltIn
Library     Collections
Library     String
Library          ../python/check_cell_throughput.py    WITH NAME    Cell_TPT

Documentation  Wts sim Keywords

*** Variables ***
${Ng_link_pattern}    NG link is Up
${Address_distribution_pattern}    Address Distribution is complete
${Cell_setup_complete_pattern}    Cell Setup completed
${UE_reg_complete_pattern}    REGISTRATION COMPLETE
${UE_Reestablishment_pattern}    NR RRC Reestablishment sucessfully completed
${PDU_session_resource_setup_response}      Established PDU session
${UE_deregister_pattern}    UE Context Release Complete
${Initial_context_setup_pattern}    Initial Context Setup Successful
${DL_traffic_start_pattern}		Started Downlink Internal traffic
${traffic_stop_pattern}		Traffic was stopped
${Pdu_session_mod_patten}      Pdu Session Resource Modify Response Message with RAN UE NGAP ID 0 handled successfully
${Pdu_session_qos_patten}      QoS Routing Table
${Pdu_session_qos_del_patten}      Removed FiveQi:Qfi mapping fiveQi
${pdu_addition_pattern}        Pdu Session Resource Setup Response Message
${pdu_del_pattern}      Received Pdu Session Resource Release Response Message
${EGATE_PORT}    20000
${EDAEMON_PORT}    22222
${EGATE_COMMAND_TIMEOUT}    10s
${mib_radiated_pattern}		schedulingInfoSIB
${sib_radiated_pattern}		systemInformationBlockType
${X2_link_pattern}    ENB-1: X2AP Link with GNB-2 .* is up
${LTE_attach_pattern}    UE IS ACTIVE
${UE_attach_pattern}    reported successful RA
${UE_5GDetach_pattern}    Bearer-type change from SCG-split to MCG
${UE_detach_pattern}    detached
${UE_reattach_pattern}    UE IS ACTIVE
${UE_RLF_pattern}     radioNetwork: rl-failure-rlc
${Trf_type}    internal
${GUI_Snapshot}    False
${Timeout_SA}    40
${Timeout_NSA}    300
${Total_Timeout}    5 min
${Retry_Timeout}    15 sec
${UE_Reattach_sleep}    20 sec
${Target_gNB}    2
${Target_Cells}    1
${Bearer_ID}     2
${Default_Cell_No}       1
${Default_Reestablishment_Cause}    reconfigurationFailure


*** Keywords ***
Configure eth3 IP
	${ip_list}		Create List		10.0.1.131	10.0.1.132	10.0.1.133	10.0.1.134	10.0.1.135	10.0.1.136	10.0.1.99	10.0.2.99
	...		10.0.1.121	10.0.1.137   10.0.1.3   10.0.1.4   10.0.1.5   10.0.1.6   10.0.1.7
	FOR		${i}	IN	@{ip_list}
    OperatingSystem.Run    sudo ip addr add ${i}/24 dev eth3
	END

Load CFG and verify cell status
    [Arguments]             ${wts_cfg_file}		${start_cell}	${end_cell}		${enb_id}=2
	Configure eth3 IP
#	Start CPRT capture
	Start wts application and load CFG		${wts_cfg_file}
    Wait Until Keyword Succeeds     600s    5s	Verify_sib_mib_for_Cell		${start_cell}	${end_cell}		${enb_id}
#    Stop CPRT capture common     log_dir=${LOG_PATH}
    Sleep   20s

Start wts application and load CFG
	[Arguments]             ${wts_cfg_file}
    Log To Console    Starting WTS...
    Run Keyword And Ignore Error     wts_sim_keywords.Clean edaemon and egate
    Wait Until Keyword Succeeds    5s    1s    OperatingSystem.File Should Exist    ${wts_cfg_file}
    ute_wtssim.Setup Edaemon    edaemon_port=${EDAEMON_PORT}    tool_dir=${WTS_DIR}    alias=edaemon
    ute_wtssim.Start Edaemon Process    alias=edaemon
    ute_wtssim.Setup Egate    egate_port=${EGATE_PORT}    tool_dir=${WTS_DIR}
    ute_wtssim.Start Egate Process
    ${verify_pattern}       SET VARIABLE    (SimMode is ready now|The state is ACTIVE|eNB 2 cell 1\: SystemInformationBlockType1\-NR updated)
    ute_wtssim.Execute Egate Command And Wait For Data    cfg file\=${wts_cfg_file}    pass_regexp=${verify_pattern}    timeout=180s
    Sleep   20s

Verify_sib_mib_for_Cell
	[Arguments]		${start_cell}	${end_cell}		${enb_id}=2
	FOR     ${i}    IN RANGE    ${start_cell}   ${end_cell}+1
	${mib_disp_cmd}		SET VARIABLE	enb_cell_ib_disp cell=${i} enb=${enb_id} type=mib
	${sib_disp_cmd}		SET VARIABLE	enb_cell_ib_disp cell=${i} enb=${enb_id} type=sib1
	${sib_mib_disp_cmd}		SET VARIABLE	enb_cell_ib_disp cell=${i} enb=${enb_id}
    #ute_wtssim.Execute Egate Command And Wait For Data ${mib_disp_cmd} pass_regexp=${mib_radiated_pattern}		timeout=${EGATE_COMMAND_TIMEOUT}
    ute_wtssim.Execute Egate Command And Wait For Data      ${sib_disp_cmd}     pass_regexp=${sib_radiated_pattern}
    ...     timeout=${EGATE_COMMAND_TIMEOUT}
    ute_wtssim.Execute Egate Command And Wait For Data		${sib_mib_disp_cmd}			fail_regexp=no
    ...     timeout=${EGATE_COMMAND_TIMEOUT}
	END

UE Register should be Successful
    [Arguments]    ${ue_id}     ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}      ${gw_id}=${gw_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file
    ${set_pdu_param_cmd}    SET VARIABLE    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    ${ue_reg_cmd}   SET VARIABLE        ue_register id=${ue_id}
    ${pdu_setup_cmd}    SET VARIABLE    ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=${nw_id} gw=${gw_id}
    ute_wtssim.Execute Egate Command    ${set_pdu_param_cmd}    timeout=${EGATE_COMMAND_TIMEOUT}
    ute_wtssim.Execute Egate Command And Wait For Data  ${ue_reg_cmd}   pass_regexp=${UE_reg_complete_pattern}
    ...     timeout=${EGATE_COMMAND_TIMEOUT}
    ute_wtssim.Execute Egate Command And Wait For Data  ${pdu_setup_cmd}
	...		pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})        timeout=${EGATE_COMMAND_TIMEOUT}

UE Reestablishment should be successful
    [Arguments]    ${ue_id}          ${Cell_No}=${Default_Cell_No}      ${Cause}=${Default_Reestablishment_Cause}
    BuiltIn.Log   ${Cause}
    ${UE_Reestablishment_Sim_Cmd}    SET VARIABLE    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${Cell_No} cause=${Default_Reestablishment_Cause}
    ute_wtssim.Execute Egate Command And Wait For Data    ${UE_Reestablishment_Sim_Cmd}    pass_regexp=${UE_Reestablishment_pattern}
    ...    timeout=${EGATE_COMMAND_TIMEOUT}

MultiUE Reestablishment should be successful
    [Arguments]    ${start_ue_id}   ${end_ue_id}   ${Cell_No}=${Default_Cell_No}    ${Cause}=${Default_Reestablishment_Cause}
    BuiltIn.Log   ${Cause}
    FOR   ${ue_idx}    IN RANGE    ${start_ue_id}   ${end_ue_id}+1
    ${UE_Reestablishment_Sim_Cmd}    SET VARIABLE    ue_rrc_reestablish id=${ue_idx} gnb=2 cell=${Cell_No} cause=${Default_Reestablishment_Cause}
    ute_wtssim.Execute Egate Command And Wait For Data    ${UE_Reestablishment_Sim_Cmd}    pass_regexp=${UE_Reestablishment_pattern}
    ...    timeout=${EGATE_COMMAND_TIMEOUT}
    END

UE Register should be Successful And Fetch RNTI with RAT1
    [Arguments]    ${ue_id}     ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}      ${gw_id}=${gw_ID}
    ${ue_reg_cmd}	SET VARIABLE	ue_register id=${ue_id}
	${set_pdu_param_cmd}	SET VARIABLE	set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    ${pdu_setup_cmd}	SET VARIABLE	ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=${nw_id} gw=${gw_id}
	ute_wtssim.Execute Egate Command    ${set_pdu_param_cmd}    timeout=10s
    ${output}		ute_wtssim.Execute Egate Command And Wait For Data  ${ue_reg_cmd}   pass_regexp=${UE_reg_complete_pattern}
    ...     timeout=${EGATE_COMMAND_TIMEOUT}
    ${output1}   ute_wtssim.Execute Egate Command And Wait For Data  ${pdu_setup_cmd}
	...		pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})        timeout=${EGATE_COMMAND_TIMEOUT}
	BuiltIn.log   ${output1}
	BuiltIn.Should Match Regexp   ${output1}  spCellConfigDedicated(.|\r|\n)*?pdsch-Config setup(.|\r|\n)*?resourceAllocation resourceAllocationType1
	Create File     ${OUTPUT_DIR}/regst.txt     ${output}
    ${crnti_value}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk -F 'crnti:' '{print $2}'|cut -d ' ' -f 2
	BuiltIn.Log     ${crnti_value}
	Log to Console             ue_register_is_ok with ${crnti_value}
	[Return]      ${crnti_value}

MultiUE Register should be Successful And Fetch RNTI with RAT1
    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA varianti
    ${crnti_list}       Create List
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
	${ue_reg_cmd}	SET VARIABLE	ue_register id=${ue_idx}
	${output}		ute_wtssim.Execute Egate Command And Wait For Data  ${ue_reg_cmd}   pass_regexp=${UE_reg_complete_pattern}
    ...      timeout=${EGATE_COMMAND_TIMEOUT}
	Create File     ${OUTPUT_DIR}/regst.txt     ${output}
	${crnti_value}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk -F 'crnti:' '{print $2}'|cut -d ' ' -f 2
	BuiltIn.Log     ${crnti_value}
	Log to Console             ue${ue_idx}_register_is_ok with ${crnti_value}
	Append To List  ${crnti_list}   ${crnti_value}
	${set_pdu_param_cmd}	SET VARIABLE	set_pdu_param ue=${ue_idx} pdu=${pdu_id} trf_type=internal
    ${pdu_setup_cmd}	SET VARIABLE	ue_pdu_session_setup pdu=${pdu_id} ue=${ue_idx} nwslice=${nw_id} gw=${ue_idx}
	ute_wtssim.Execute Egate Command    ${set_pdu_param_cmd}    timeout=${EGATE_COMMAND_TIMEOUT}
	${output1}  ute_wtssim.Execute Egate Command And Wait For Data  ${pdu_setup_cmd}
	...		pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})        timeout=${EGATE_COMMAND_TIMEOUT}
	BuiltIn.log   ${output1}
	BuiltIn.Should Match Regexp   ${output1}  spCellConfigDedicated(.|\r|\n)*?pdsch-Config setup(.|\r|\n)*?resourceAllocation resourceAllocationType1
    BuiltIn.Log        ue=${ue_idx} with crnti=${crnti_value} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    END
    Log to Console             multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                CRntilist:${crnti_list}
    [Return]      ${crnti_list}

UE Register should be Successful And Fetch RNTI
    [Arguments]    ${ue_id}     ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}      ${gw_id}=${gw_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA variant
    ${ue_reg_cmd}	SET VARIABLE	ue_register id=${ue_id}
	${set_pdu_param_cmd}	SET VARIABLE	set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    ${pdu_setup_cmd}	SET VARIABLE	ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=${nw_id} gw=${gw_id}
	ute_wtssim.Execute Egate Command    ${set_pdu_param_cmd}    timeout=${EGATE_COMMAND_TIMEOUT}
    ${output}		ute_wtssim.Execute Egate Command And Wait For Data  ${ue_reg_cmd}   pass_regexp=${UE_reg_complete_pattern}
    ...     timeout=${EGATE_COMMAND_TIMEOUT}
    ute_wtssim.Execute Egate Command And Wait For Data  ${pdu_setup_cmd}
	...		pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})        timeout=${EGATE_COMMAND_TIMEOUT}
	Create File     ${OUTPUT_DIR}/regst.txt     ${output}
    ${crnti_value}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk -F 'crnti:' '{print $2}'|cut -d ' ' -f 2
	BuiltIn.Log     ${crnti_value}
	Log to Console             ue_register_is_ok with ${crnti_value}
	[Return]      ${crnti_value}

Trigger data
	[Arguments]    ${ue_id}     ${dir}		${pdu_id}     ${trf_id}		${qfi}  ${Traffic_unit}		${traffic_rate}
    [Documentation]    This keyword starts the downlink data
    Log to Console    \nRunning Traffic
	${data_cmd}	SET VARIABLE	trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} dir=${dir} ${Traffic_unit}=${traffic_rate} trf_id=${trf_id}
    ute_wtssim.Execute Egate Command And Wait For Data		${data_cmd}		timeout=${EGATE_COMMAND_TIMEOUT}

Trigger VONR data
	[Arguments]    ${ue_id}     ${dir}		${pdu_id}     ${trf_id}		${qfi}		${Traffic_unit}		${traffic_rate}		${rtp_codec}
    [Documentation]    This keyword starts the vonr data
    Log to Console    \nRunning Traffic
	${data_cmd}	SET VARIABLE	trf_data_start ue=${ue_id} pdu=${pdu_id} dir=${dir} qfi=${qfi} ${Traffic_unit}=${traffic_rate}
	... trf_id=${trf_id} rtp_codec=${rtp_codec}
    ute_wtssim.Execute Egate Command And Wait For Data		${data_cmd}		timeout=${EGATE_COMMAND_TIMEOUT}

Stop data
	[Arguments]        ${ue_id}    ${pdu_id}    ${dir}    ${trf_id}     ${qfi}
    [Documentation]    This keyword starts the uplink data
    Log to Console    Stopping data
	${stop_data_cmd}	SET VARIABLE	trf_data_stop ue=${ue_id} pdu=${pdu_id} qfi=${qfi} dir=${dir} trf_id=${trf_id}
    ute_wtssim.Execute Egate Command And Wait For Data		${stop_data_cmd}	timeout=${EGATE_COMMAND_TIMEOUT}
	...		pass_regexp=${traffic_stop_pattern}

UE PDU Addition should be Successful
    [Arguments]    ${ue_id}     ${pdu_id}     ${nw_id}    ${gw_id}
    ${pdu_param_set}	SET VARIABLE	set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    ${pdu_setup}	SET VARIABLE	ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=${nw_id} gw=${gw_id}
	ute_wtssim.Execute Egate Command    ${pdu_param_set}    timeout=${EGATE_COMMAND_TIMEOUT}
	ute_wtssim.Execute Egate Command And Wait For Data  ${pdu_setup}	pass_regexp=${pdu_addition_pattern}		timeout=${EGATE_COMMAND_TIMEOUT}

UE PDU Modfication should be Successful
     [Arguments]     ${ue_id}      ${pdu_id}=${Pdu_session_ID}      ${qosflows_to_add}=${Q_O_ADD}
     ${pdu_modify}	SET VARIABLE	ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qosflows_to_add} by=amf
     ute_wtssim.Execute Egate Command    ${pdu_modify}		pass_regexp=${Pdu_session_qos_patten}     timeout=${EGATE_COMMAND_TIMEOUT}

UE PDU Modification should be Successful for QFI delete
     [Arguments]     ${ue_id}      ${pdu_id}=${Pdu_session_ID}      ${qosflows_to_del}=${Q_O_DEL}
     ${pdu_modify}	SET VARIABLE	ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_del=${qosflows_to_del} by=amf
     ute_wtssim.Execute Egate Command    ${pdu_modify}		pass_regexp=${Pdu_session_qos_del_patten}     timeout=${EGATE_COMMAND_TIMEOUT}

UE PDU Session release
	 [Arguments]    ${ue_id}     ${pdu_id}=${Pdu_session_ID}
	 [Documentation]    This keyword checks the message for the completion of PDU session release in the output file
	 ${pdu_session_cmd}		SET VARIABLE    ue_pdu_session_release ue=${ue_id} pdu=${pdu_id}
	 ute_wtssim.Execute Egate Command And Wait For Data   	${pdu_session_cmd}		pass_regexp=${pdu_del_pattern}
	 ...	timeout=${EGATE_COMMAND_TIMEOUT}

UE Deregister should be Successful
    [Arguments]    ${ue_id}
    [Documentation]    This keyword checks the message for the completion of UE deregistration in the output file
    ${deregister_cmd}    SET VARIABLE    ue_deregister id=${ue_id} ue_deregister_type=switch_off by=ue
    ute_wtssim.Execute Egate Command And Wait For Data   ${deregister_cmd}    pass_regexp=${UE_deregister_pattern}
    ... 	timeout=${EGATE_COMMAND_TIMEOUT}

UE Deregister should be Successful And Fetch RNTI
    [Arguments]    ${ue_id}
    [Documentation]    This keyword checks the message for the UE Deregistration in the output file for the SA variant
    ${deregister_cmd}    SET VARIABLE    ue_deregister id=${ue_id} ue_deregister_type=switch_off
    ${output}	ute_wtssim.Execute Egate Command And Wait For Data   ${deregister_cmd}    pass_regexp=${UE_deregister_pattern}
    ... 	timeout=${EGATE_COMMAND_TIMEOUT}
	Create File     ${OUTPUT_DIR}/regst.txt     ${output}
    ${crnti_value}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk -F 'crnti:' '{print $2}'|cut -d ' ' -f 2
    BuiltIn.Log                ue_deregister_is_ok with ${crnti_value}
	[Return]      ${crnti_value}

Clean edaemon and egate
    OperatingSystem.Run    sudo rm -rf ${WTS_DIR}/*.log.*
    ute_wtssim.Teardown Edaemon    alias=edaemon
    ute_wtssim.Teardown Egate

NSA X2AP Link Should be UP
	[Arguments]    ${eNB_ID}		${eNB_target}
    [Documentation]    This keyword is used to Create a X2 connection with gNB
    ...                And checks if the X2AP link with the gNB is UP in the output file.
    ${x2_link_up_cmd}    SET VARIABLE    enb_x2_link_up enb=${eNB_ID} target=${eNB_target}
    ute_wtssim.Execute Egate Command And Wait For Data   ${x2_link_up_cmd}		pass_regexp=${X2_link_pattern}    timeout=${Timeout_NSA}
    BuiltIn.Log    x2_is_ok

NSA LTE Attach should be Successful
    [Arguments]    ${NSA_UE_ID}
    [Documentation]    This keyword is used at create the LTE Attach and checks the completion message in output file.
    ${ue_attach_cmd}	SET VARIABLE	ue_attach id=${NSA_UE_ID}
    ute_wtssim.Execute Egate Command And Wait For Data   ${ue_attach_cmd}	pass_regexp=${LTE_attach_pattern}    timeout=${Timeout_NSA}
    BuiltIn.Log    lte_attach_is_ok

NSA UE Attach should be Successful
    [Arguments]    ${NSA_UE_ID}    ${Target_Cells}
    [Documentation]    This keyword is used to Attach the UE with gNB and check the completion message in output file.
    ${en_dc_start_cmd}=  catenate  SEPARATOR=${SPACE}
     ...  enb_ue_dc_start target_gnb=${Target_gNB} target_cells=${Target_Cells} ue=${NSA_UE_ID}
     ...  bearer=${Bearer_ID} type=split_scg
    ute_wtssim.Execute Egate Command And Wait For Data   ${en_dc_start_cmd}		pass_regexp=${UE_attach_pattern}    timeout=${Timeout_NSA}

NSA UE Attach should be Successful CFRA
    [Arguments]    ${NSA_UE_ID}    ${Target_Cells}
    [Documentation]    This keyword is used to Attach the UE with gNB and check the completion message in output file.
    ${en_dc_start_cmd}=  catenate  SEPARATOR=${SPACE}
     ...  enb_ue_dc_start target_gnb=${Target_gNB} target_cells=${Target_Cells} ue=${NSA_UE_ID}
     ...  bearer=${Bearer_ID} type=split_scg
    ${output1}    ute_wtssim.Execute Egate Command And Wait For Data   ${en_dc_start_cmd}		pass_regexp=${UE_attach_pattern}    timeout=${Timeout_NSA}
    BuiltIn.Should Match Regexp   ${output1}    cfra(.|\r|\n)*?ra-PreambleIndex 60

NSA UE Attach should be Successful for RAT1
    [Arguments]    ${NSA_UE_ID}    ${Target_Cells}
    [Documentation]    This keyword is used to Attach the UE with gNB and check the completion message in output file.
    ${en_dc_start_cmd}=  catenate  SEPARATOR=${SPACE}
     ...  enb_ue_dc_start target_gnb=${Target_gNB} target_cells=${Target_Cells} ue=${NSA_UE_ID}
     ...  bearer=${Bearer_ID} type=split_scg
    ${output1}  ute_wtssim.Execute Egate Command And Wait For Data   ${en_dc_start_cmd}  pass_regexp=${UE_attach_pattern}  timeout=${Timeout_NSA}
	BuiltIn.log   ${output1}
	BuiltIn.Should Match Regexp   ${output1}  pdsch-Config setup(.|\r|\n)*?resourceAllocation resourceAllocationType1


NSA Multi UE Attach should be Successful
    [Arguments]    ${Start_NSA_UE}    ${END_NSA_UE}     ${Target_Cells}
    FOR  ${UE}  IN RANGE    ${Start_NSA_UE}    ${END_NSA_UE}+1
       NSA LTE Attach should be Successful    ${UE}
       NSA UE Attach should be Successful    ${UE}    ${Target_Cells}
    END

NSA Multi UE Attach should be Successful for RAT1
    [Arguments]    ${Start_NSA_UE}    ${END_NSA_UE}     ${Target_Cells}
    FOR  ${UE}  IN RANGE    ${Start_NSA_UE}    ${END_NSA_UE}+1
       NSA LTE Attach should be Successful    ${UE}
       NSA UE Attach should be Successful for RAT1    ${UE}    ${Target_Cells}
    END

NSA UE Detach should be Successful
    [Arguments]    ${UE_ID}=${UE_ID}
    [Documentation]    This keyword is used to Detach the UE with gNB and checks the completion message in output file.
    ${ue_detach_cmd}	SET VARIABLE	ue_detach id=${UE_ID}
    ute_wtssim.Execute Egate Command And Wait For Data   ${ue_detach_cmd}		pass_regexp=${UE_detach_pattern}    timeout=${Timeout_NSA}
    BuiltIn.Log    detach_is_ok

NSA Multi UE Detach should be Successful
    [Arguments]    ${start_ue_id}    ${end_ue_id}
    [Documentation]    This keyword is used to Detach the UE with gNB and checks the completion message in output file.
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    ${ue_detach_cmd}	SET VARIABLE	ue_detach id=${ue_idx}
    ute_wtssim.Execute Egate Command And Wait For Data   ${ue_detach_cmd}		pass_regexp=${UE_detach_pattern}    timeout=${Timeout_NSA}
    BuiltIn.Log    detach_is_ok
    END

Trigger DL Traffic for NSA
    [Arguments]    ${ue_id}        ${Traffic_rate}     ${dl_rate}       ${id}=${Bearer_ID}    ${trf_id}=${TRF_ID}
    [Documentation]    This keyword starts the DL Traffic for the SA variant
    Log to Console    \nRunning DL Traffic for ${dl_rate} ${Traffic_rate}...
    ${trf_start_cmd}	SET VARIABLE	trf_data_start ue=${ue_id} id=${id} dir=dl trf_id=${trf_id} ${Traffic_rate}=${dl_rate}
	ute_wtssim.Execute Egate Command And Wait For Data   ${trf_start_cmd}	pass_regexp=UDP.*	timeout=${EGATE_COMMAND_TIMEOUT}
    BuiltIn.Log    DL_traffic_data_is_started_successfully

Trigger UL Traffic for NSA
    [Arguments]    ${ue_id}        ${Traffic_rate}     ${ul_rate}       ${id}=${Bearer_ID}    ${trf_id}=${TRF_ID}
    [Documentation]    This keyword starts the UL Traffic for the SA variant
    Log to Console    \nRunning UL Traffic for ${ul_rate} ${Traffic_rate}...
    ${trf_start_cmd}	SET VARIABLE	trf_data_start ue=${ue_id} id=${id} dir=ul trf_id=${trf_id} ${Traffic_rate}=${ul_rate}
	ute_wtssim.Execute Egate Command And Wait For Data   ${trf_start_cmd}	pass_regexp=UDP.*	timeout=${EGATE_COMMAND_TIMEOUT}
    BuiltIn.Log    UL_traffic_data_is_started_successfully

MultiUE Trigger DL Traffic for NSA
    [Arguments]    ${start_ue_id}  ${end_ue_id}   ${Traffic_rate}     ${dl_rate}       ${id}=${Bearer_ID}    ${trf_id}=${TRF_ID}
    [Documentation]    This keyword starts the DL Traffic for the NSA variant
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Log to Console    \nRunning DL Traffic for ${dl_rate} ${Traffic_rate}...
    ${data_cmd}	SET VARIABLE	trf_data_start ue=${ue_idx} id=${id} dir=dl trf_id=${trf_id} ${Traffic_rate}=${dl_rate}
    ute_wtssim.Execute Egate Command And Wait For Data   ${data_cmd}	pass_regexp=UDP.*	timeout=${EGATE_COMMAND_TIMEOUT}
    BuiltIn.Log    DL_traffic_data_is_started_successfully
	END

MultiUE Trigger UL Traffic for NSA
    [Arguments]    ${start_ue_id}  ${end_ue_id}   ${Traffic_rate}     ${ul_rate}       ${id}=${Bearer_ID}    ${trf_id}=${TRF_ID}
    [Documentation]    This keyword starts the UL Traffic for the NSA variant
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Log to Console    \nRunning UL Traffic for ${ul_rate} ${Traffic_rate}...
    ${data_cmd}	SET VARIABLE	trf_data_start ue=${ue_idx} id=${id} dir=ul trf_id=${trf_id} ${Traffic_rate}=${ul_rate}
	ute_wtssim.Execute Egate Command And Wait For Data   ${data_cmd}	pass_regexp=UDP.*	timeout=${EGATE_COMMAND_TIMEOUT}
    BuiltIn.Log    UL_traffic_data_is_started_successfully
	END

MultiUE Trigger DL Bursty Traffic for NSA
    [Arguments]    ${start_ue_id}  ${end_ue_id}   ${Traffic_rate}   ${dl_rate}   ${id}=${Bearer_ID}   ${trf_id}=${TRF_ID}  ${burst}=30   ${period}=40

    [Documentation]    This keyword starts the DL Traffic for the NSA variant
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Log to Console    \nRunning DL Traffic for ${dl_rate} ${Traffic_rate}...
    ${data_cmd} 	catenate  SEPARATOR=${SPACE}
    ...    trf_data_start ue=${ue_idx} id=${id} dir=dl trf_id=${trf_id} ${Traffic_rate}=${dl_rate}
    ...    burst=${burst} period_ms=${period}
    ute_wtssim.Execute Egate Command And Wait For Data   ${data_cmd}	pass_regexp=UDP.*	timeout=${EGATE_COMMAND_TIMEOUT}
    BuiltIn.Log    DL_traffic_data_is_started_successfully
	END

MultiUE Trigger UL Bursty Traffic for NSA
    [Arguments]    ${start_ue_id}  ${end_ue_id}   ${Traffic_rate}   ${ul_rate}   ${id}=${Bearer_ID}   ${trf_id}=${TRF_ID}   ${burst}=30  ${period}=40

    [Documentation]    This keyword starts the UL Traffic for the NSA variant
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Log to Console    \nRunning UL Traffic for ${ul_rate} ${Traffic_rate}...
    ${data_cmd} 	catenate  SEPARATOR=${SPACE}
    ...    trf_data_start ue=${ue_idx} id=${id} dir=ul trf_id=${trf_id} ${Traffic_rate}=${ul_rate}
    ...    burst=${burst} period_ms=${period}
	ute_wtssim.Execute Egate Command And Wait For Data   ${data_cmd}	pass_regexp=UDP.*	timeout=${EGATE_COMMAND_TIMEOUT}
    BuiltIn.Log    UL_traffic_data_is_started_successfully
	END

Qosflow_modify Priority
    [Arguments]    ${qos_flow}   ${priority}
	${qosflow_modify}	SET VARIABLE	qosflow_modify qos_flow=${qos_flow} priority=${priority}
	ute_wtssim.Execute Egate Command   ${qosflow_modify}	timeout=10s

UE Emergency PDU Addition should be Successful
    [Arguments]    ${ue_id}     ${pdu_id}     ${nw_id}    ${gw_id}
    ${pdu_param_cmd}	SET VARIABLE	set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    ${pdu_setup_cmd}	SET VARIABLE	ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=${nw_id} gw=${gw_id}
    ...    request_type=initial-emergency-request
    ute_wtssim.Execute Egate Command And Wait For Data   ${pdu_param_cmd}	timeout=${EGATE_COMMAND_TIMEOUT}
	ute_wtssim.Execute Egate Command And Wait For Data   ${pdu_setup_cmd}	pass_regexp=${pdu_addition_pattern}    ${Timeout_SA}

MultiUE Register should be Successful
    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA varianti
    ${crnti_list}       Create List
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
	${ue_reg_cmd}	SET VARIABLE	ue_register id=${ue_idx}
	${output}		ute_wtssim.Execute Egate Command And Wait For Data  ${ue_reg_cmd}   pass_regexp=${UE_reg_complete_pattern}
    ...      timeout=${EGATE_COMMAND_TIMEOUT}
	Create File     ${OUTPUT_DIR}/regst.txt     ${output}
	${crnti_value}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk -F 'crnti:' '{print $2}'|cut -d ' ' -f 2
	BuiltIn.Log     ${crnti_value}
	Log to Console             ue${ue_idx}_register_is_ok with ${crnti_value}
	Append To List  ${crnti_list}   ${crnti_value}
	${set_pdu_param_cmd}	SET VARIABLE	set_pdu_param ue=${ue_idx} pdu=${pdu_id} trf_type=internal
    ${pdu_setup_cmd}	SET VARIABLE	ue_pdu_session_setup pdu=${pdu_id} ue=${ue_idx} nwslice=${nw_id} gw=${ue_idx}
	ute_wtssim.Execute Egate Command    ${set_pdu_param_cmd}    timeout=${EGATE_COMMAND_TIMEOUT}
	 ute_wtssim.Execute Egate Command And Wait For Data  ${pdu_setup_cmd}
	...		pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})        timeout=${EGATE_COMMAND_TIMEOUT}
    BuiltIn.Log        ue=${ue_idx} with crnti=${crnti_value} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    END
    Log to Console             multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                CRntilist:${crnti_list}
    [Return]      ${crnti_list}

MultiUE Register with RAR timer Expiry
    [Arguments]    ${start_ue_id}   ${end_ue_id}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA varianti
    ${crnti_list}       Create List
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
	${ue_reg_cmd}	SET VARIABLE	ue_register id=${ue_idx}
	${output}		ute_wtssim.Execute Egate Command And Wait For Data  ${ue_reg_cmd}   pass_regexp=RAR Timer has expired
    ...      timeout=${EGATE_COMMAND_TIMEOUT}
    END
    [Return]      ${crnti_list}

MultiUE Deregister should be Successful
    [Arguments]    ${start_ue_id}   ${end_ue_id}
    [Documentation]    This keyword checks the message for the UE Deregistration in the output file for the SA variant
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
	${deregister_cmd}    SET VARIABLE    ue_deregister id=${ue_idx} ue_deregister_type=switch_off by=ue
	ute_wtssim.Execute Egate Command And Wait For Data   ${deregister_cmd}    pass_regexp=${UE_deregister_pattern}
    ... 	timeout=${EGATE_COMMAND_TIMEOUT}
    END
    BuiltIn.Log                multi_ue_deregister_is_ok

Trigger DL Traffic for SA
    [Arguments]    ${ue_id}     ${Traffic_rate}     ${dl_rate}      ${pdu_id}=${Pdu_session_ID}     ${trf_id}=${TRF_ID}     ${qfi_id}=${QFI_ID}
    [Documentation]    This keyword starts the DL Traffic for the SA variant
    Log to Console    \nRunning DL Traffic for ${dl_rate} ${Traffic_rate}...
    ${trf_strt_cmd}	SET VARIABLE
    ...     trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl trf_id=${trf_id} ${Traffic_rate}=${dl_rate}
    ${output}		ute_wtssim.Execute Egate Command And Wait For Data   ${trf_strt_cmd}		pass_regexp=Started Downlink Internal traffic*
    ...    timeout=${Timeout_NSA}
    ${output}         Get Lines Matching Regexp    ${output}    UDP DL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
    BuiltIn.Log    DL_traffic_data_is_started_successfully

Trigger DL Data Traffic for SA
    [Arguments]    ${ue_id}     ${Traffic_rate}     ${dl_rate}       ${pdu_id}=${Pdu_session_ID}     ${trf_id}=${TRF_ID}
    [Documentation]    This keyword starts the max 175 DL data Traffic for the SA variant
    Log to Console    \nRunning DL Traffic for ${dl_rate} ${Traffic_rate}...
    ${trf_strt_cmd}	SET VARIABLE	trf_data_start ue=${ue_id} pdu=${pdu_id} dir=dl ${Traffic_rate}=${dl_rate} trf_id=${trf_id}
	${output}		ute_wtssim.Execute Egate Command And Wait For Data   ${trf_strt_cmd}		pass_regexp=Started Downlink Internal traffic*
    ...    timeout=${Timeout_NSA}
    ${output}         Get Lines Matching Regexp    ${output}    UDP DL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
    BuiltIn.Log    DL_traffic_data_is_started_successfully

Trigger UL Traffic for SA
    [Arguments]    ${ue_id}        ${Traffic_rate}     ${ul_rate}       ${pdu_id}=${Pdu_session_ID}     ${trf_id}=${TRF_ID}
    ...      ${qfi_id}=${QFI_ID}
    [Documentation]    This keyword starts the UL Traffic for the SA variant
    Log to Console    \nRunning UL Traffic for ${ul_rate} ${Traffic_rate}...
    ${trf_strt_cmd}	SET VARIABLE
    ...     trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul trf_id=${trf_id} ${Traffic_rate}=${ul_rate}
	${output}		ute_wtssim.Execute Egate Command And Wait For Data   ${trf_strt_cmd}		pass_regexp=Started Uplink Internal traffic*
    ...    timeout=${Timeout_NSA}
    ${output}         Get Lines Matching Regexp    ${output}    UDP UL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
    BuiltIn.Log    UL_traffic_data_is_started_successfully


MultiUE Trigger UL Bursty Data Traffic for SA
    [Arguments]     ${start_ue_id}	${end_ue_id}  ${Traffic_rate}     ${ul_rate}    ${pdu_id}=${Pdu_session_ID}     ${trf_id}=${TRF_ID}
    ...   ${qfi_id}=${QFI_ID}    ${burst}=30     ${period}=40
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
    Log to Console    \nRunning UL Traffic for ${ul_rate} ${Traffic_rate}...
    ${trf_strt_cmd}    catenate  SEPARATOR=${SPACE}
    ...    trf_data_start ue=${ue_idx} pdu=${pdu_id} qfi=${qfi_id} dir=ul ${Traffic_rate}=${ul_rate} trf_id=${trf_id}
    ...    burst=${burst} period_ms=${period}
    ${output}		ute_wtssim.Execute Egate Command And Wait For Data   ${trf_strt_cmd}		pass_regexp=Started Uplink Internal traffic*
    ...    timeout=${Timeout_NSA}
    ${output}         Get Lines Matching Regexp    ${output}    UDP UL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
    BuiltIn.Log    UL_traffic_data_is_started_successfully
    END

MultiUE Trigger DL Bursty Data Traffic for SA
    [Arguments]   ${start_ue_id}  ${end_ue_id}   ${Traffic_rate}     ${dl_rate}    ${pdu_id}=${Pdu_session_ID}     ${trf_id}=${TRF_ID}
    ...   ${qfi_id}=${QFI_ID}    ${burst}=30   ${period}=40
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
    Log to Console    \nRunning DL Traffic for ${dl_rate} ${Traffic_rate}...
    ${trf_strt_cmd}    catenate  SEPARATOR=${SPACE}
    ...   trf_data_start ue=${ue_idx} pdu=${pdu_id} qfi=${qfi_id} dir=dl ${Traffic_rate}=${dl_rate}    trf_id=${trf_id}
    ...   burst=${burst} period_ms=${period}
    ${output}		ute_wtssim.Execute Egate Command And Wait For Data   ${trf_strt_cmd}		pass_regexp=Started Downlink Internal traffic*
    ...    timeout=${Timeout_NSA}
    ${output}         Get Lines Matching Regexp    ${output}    UDP DL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
    BuiltIn.Log    DL_traffic_data_is_started_successfully
    END

Trigger UL Non Bursty Data Traffic for SA
    [Arguments]    ${ue_id}        ${Traffic_rate}     ${ul_rate}       ${pdu_id}=${Pdu_session_ID}     ${trf_id}=${TRF_ID}
    ...   ${burst}=30    ${qfi_id}=${QFI_ID}
    Log to Console    \nRunning UL Traffic for ${ul_rate} ${Traffic_rate} ${burst}...
    ${trf_strt_cmd}	SET VARIABLE	trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul ${Traffic_rate}=${ul_rate} trf_id=${trf_id}
    ${output}		ute_wtssim.Execute Egate Command And Wait For Data   ${trf_strt_cmd}		pass_regexp=Started Uplink Internal traffic*
    ...     timeout=${Timeout_NSA}
    ${output}         Get Lines Matching Regexp    ${output}    UDP UL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
    BuiltIn.Log    UL_traffic_data_is_started_successfully

Trigger DL Non Bursty Data Traffic for SA
    [Arguments]    ${ue_id}        ${Traffic_rate}     ${dl_rate}       ${pdu_id}=${Pdu_session_ID}     ${trf_id}=${TRF_ID}
    ...   ${qfi_id}=${QFI_ID}
    Log to Console    \nRunning DL Traffic for ${dl_rate} ${Traffic_rate}...
    ${trf_strt_cmd}	SET VARIABLE	trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl ${Traffic_rate}=${dl_rate} trf_id=${trf_id}
    ${output}		ute_wtssim.Execute Egate Command And Wait For Data   ${trf_strt_cmd}		pass_regexp=Started Downlink Internal traffic*
    ...    timeout=${Timeout_NSA}
    ${output}         Get Lines Matching Regexp    ${output}    UDP DL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
    BuiltIn.Log    DL_traffic_data_is_started_successfully

Trigger UL Data Traffic for SA
    [Arguments]    ${ue_id}        ${Traffic_rate}     ${ul_rate}       ${pdu_id}=${Pdu_session_ID}     ${trf_id}=${TRF_ID}
    [Documentation]    This keyword starts the max 175 UL data Traffic for the SA variant
    Log to Console    \nRunning UL Traffic for ${ul_rate} ${Traffic_rate}...
    ${trf_strt_cmd}	SET VARIABLE	trf_data_start ue=${ue_id} pdu=${pdu_id} dir=ul ${Traffic_rate}=${ul_rate} trf_id=${trf_id}
    ${output}		ute_wtssim.Execute Egate Command And Wait For Data   ${trf_strt_cmd}		pass_regexp=Started Uplink Internal traffic*
    ...    timeout=${Timeout_NSA}
    ${output}         Get Lines Matching Regexp    ${output}    UDP UL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
    BuiltIn.Log    UL_traffic_data_is_started_successfully

Trigger DL Data Traffic for SA with Sec
    [Arguments]    ${ue_id}     ${Trf_rate}     ${dl_rate}       ${pdu_id}=${Pdu_session_ID}     ${trf_id}=${TRF_ID}    ${sec}=${SECOND}
    ...    ${qfi}=${QFI}
    [Documentation]    This keyword starts the max 175 DL data Traffic for the SA variant for specific time
    Log to Console    \nRunning DL Traffic for ${dl_rate} ${Trf_rate}...
    ${trf_strt_cmd}	 SET VARIABLE  trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} dir=dl ${Trf_rate}=${dl_rate} trf_id=${trf_id} seconds=${sec}
	${output}	ute_wtssim.Execute Egate Command And Wait For Data   ${trf_strt_cmd}		pass_regexp=Started Downlink Internal traffic*
    ...    timeout=${Timeout_NSA}
    ${output}         Get Lines Matching Regexp    ${output}    UDP DL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
    BuiltIn.Log    DL_traffic_data_is_started_successfully

Trigger UL Data Traffic for SA with Sec
    [Arguments]    ${ue_id}      ${Trf_rate}     ${ul_rate}       ${pdu_id}=${Pdu_session_ID}     ${trf_id}=${TRF_ID}    ${sec}=${SECOND}
    ...    ${qfi}=${QFI}
    [Documentation]    This keyword starts the max 175 UL data Traffic for the SA variant for specific time
    Log to Console    \nRunning UL Traffic for ${ul_rate} ${Trf_rate}...
    ${trf_strt_cmd}	 SET VARIABLE  trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} dir=ul ${Trf_rate}=${ul_rate} trf_id=${trf_id} seconds=${sec}
    ${output}	ute_wtssim.Execute Egate Command And Wait For Data   ${trf_strt_cmd}		pass_regexp=Started Uplink Internal traffic*
    ...    timeout=${Timeout_NSA}
    ${output}         Get Lines Matching Regexp    ${output}    UDP UL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
    BuiltIn.Log    UL_traffic_data_is_started_successfully

Check Average Rate
    [Arguments]    ${bearer_stat}    ${dir}    ${mbps}
    ${output}         Get Regexp Matches    ${bearer_stat}    Average data rate +(\\d+)    1
    ${result}         Evaluate    (${mbps} * 1000000 * 1.1) > int(${output[0]}) > (${mbps} * 1000000 * 0.9)
    Run Keyword if    ${result}    Log to Console    ${dir} Average data rate: ${output[0]}
    ...               ELSE    BuiltIn.Log     ${dir} Average data rate: ${output[0]}    level=ERROR
    Run Keyword and Continue on Failure
    ...               Should Be True    ${result}    msg=${dir} Average data rate failed!

Check DL Data Loss
    [Arguments]    ${bearer_stat_all}    ${bearer_stat_scg}
    ${bytes_sent}       Get Regexp Matches    ${bearer_stat_all}    Bytes sent +(\\d+)    1
    ${bytes_rec}        Get Regexp Matches    ${bearer_stat_scg}    Bytes received +(\\d+)    1
    ${bytes_sent_int}   Convert To Integer  ${bytes_sent[0]}
    ${data_loss}        Set Variable    0.01
    ${bytes_sent_min}   Evaluate    ${bytes_sent_int}*(1 - ${data_loss})
    ${bytes_sent_int}   Evaluate   ${bytes_sent_int} + 1000
    ${bytes_rec_int}    Convert To Integer   ${bytes_rec[0]}
#   BuiltIn.Log                 "Below is WA for ASIL Traffic issue seen in some TLs..."
#   ${data_loss}        Set Variable if    "${gnb_sm_hardware}"=="ASIL"    0.02    0.01

    Run Keyword if    ${bytes_sent_min} <= ${bytes_rec_int} <= ${bytes_sent_int}
    ...               Log to Console    DL Bytes received complete (${bytes_rec[0]})
    ...               ELSE
    ...               BuiltIn.Log     DL Data Loss! Bytes Received (${bytes_rec[0]}) not matching given threshold! Sent (${bytes_sent[0]})
    ...               level=ERROR
    Run Keyword and Continue on Failure
    ...               Should Be True    ${bytes_sent_min} <= ${bytes_rec_int} <= ${bytes_sent_int}    msg=${EMPTY}

Check DL Data Loss for high data
    [Arguments]    ${bearer_stat_all}    ${bearer_stat_scg}
    ${bytes_sent}       Get Regexp Matches    ${bearer_stat_all}    Bytes sent +(\\d+)    1
    ${bytes_rec}        Get Regexp Matches    ${bearer_stat_scg}    Bytes received +(\\d+)    1
    ${bytes_sent_int}   Convert To Integer  ${bytes_sent[0]}
    ${bytes_sent_int}=   Evaluate   ${bytes_sent_int} + 3000
    ${bytes_rec_int}    Convert To Integer   ${bytes_rec[0]}
#   BuiltIn.Log                 "Below is WA for ASIL Traffic issue seen in some TLs..."
#   ${data_loss}        Set Variable if    "${gnb_sm_hardware}"=="ASIL"    0.02    0.01
    ${data_loss}        Set Variable    0.06
    ${bytes_sent_min}   Evaluate    ${bytes_sent_int}*(1 - ${data_loss})

    Run Keyword if    ${bytes_sent_min} <= ${bytes_rec_int} <= ${bytes_sent_int}
    ...               Log to Console    DL Bytes received complete (${bytes_rec[0]})
    ...               ELSE
    ...               BuiltIn.Log     DL Data Loss! Bytes Received (${bytes_rec[0]}) not matching given threshold! Sent (${bytes_sent[0]})
    ...               level=ERROR
    Run Keyword and Continue on Failure
    ...               Should Be True    ${bytes_sent_min} <= ${bytes_rec_int} <= ${bytes_sent_int}    msg=${EMPTY}


Check UL Data Loss
    [Arguments]    ${bearer_stat_all}    ${bearer_stat_scg}
    ${bytes_sent}       Get Regexp Matches    ${bearer_stat_scg}    Bytes sent +(\\d+)    1
    ${bytes_rec}        Get Regexp Matches    ${bearer_stat_all}    Bytes received +(\\d+)    1
    ${bytes_sent_int}   Convert To Integer  ${bytes_sent[0]}
    ${data_loss}        Set Variable    0.01
    ${bytes_sent_min}   Evaluate    ${bytes_sent_int}*(1 - ${data_loss})
    ${bytes_sent_int}   Evaluate   ${bytes_sent_int} + 1000
    ${bytes_rec_int}    Convert To Integer   ${bytes_rec[0]}
#   BuiltIn.Log                  "Below is WA for ASIL Traffic issue seen in some TLs..."
#   ${data_loss}        Set Variable if    "${gnb_sm_hardware}"=="ASIL"    0.02    0.01

    Run Keyword if    ${bytes_sent_min} <= ${bytes_rec_int} <= ${bytes_sent_int}
    ...               Log to Console    UL Bytes sent complete (${bytes_sent[0]})
    ...               ELSE
    ...               BuiltIn.Log     UL Data Loss! Bytes Sent (${bytes_sent[0]}) not matching given threshold! Received (${bytes_rec[0]})
    ...               level=ERROR
    Run Keyword and Continue on Failure
    ...               Should Be True    ${bytes_sent_min} <= ${bytes_rec_int} <= ${bytes_sent_int}    msg=${EMPTY}

Validate DL Traffic For SA
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. DL Bytes Received must be equal to ALL Bytes Sent
    [Arguments]    ${ue_id}     ${dl_rate}     ${pdu_id}=${Pdu_session_ID}      ${qfi_id}=${QFI_ID}
    ${bearer_stats_cmd}	SET VARIABLE	bearer_stats ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl
    ${bearer_stat_dl}		ute_wtssim.Execute Egate Command And Wait For Data   ${bearer_stats_cmd}	pass_regexp=Average packet interval
    ...                     timeout=30
    wts_sim_keywords.Check Average Rate      ${bearer_stat_dl}    DL    ${dl_rate}
    Run keyword and Ignore Error    wts_sim_keywords.Check DL Data Loss      ${bearer_stat_dl}    ${bearer_stat_dl}

Validate DL Traffic For MultiUE SA
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. DL Bytes Received must be equal to ALL Bytes Sent
    [Arguments]    ${start_ue_id}    ${end_ue_id}  ${dl_rate}     ${pdu_id}=${Pdu_session_ID}      ${qfi_id}=${QFI_ID}
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    ${bearer_stats_cmd}	SET VARIABLE	bearer_stats ue=${ue_idx} pdu=${pdu_id} qfi=${qfi_id} dir=dl
    ${bearer_stat_dl}		ute_wtssim.Execute Egate Command And Wait For Data   ${bearer_stats_cmd}	pass_regexp=Average packet interval
    ...                     timeout=30
    wts_sim_keywords.Check Average Rate      ${bearer_stat_dl}    DL    ${dl_rate}
    Run keyword and Ignore Error    wts_sim_keywords.Check DL Data Loss      ${bearer_stat_dl}    ${bearer_stat_dl}
	END

Validate DL Traffic For SA for high data
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. DL Bytes Received must be equal to ALL Bytes Sent
    [Arguments]    ${ue_id}     ${dl_rate}     ${pdu_id}=${Pdu_session_ID}      ${qfi_id}=${QFI_ID}
    ${bearer_stats_cmd}	SET VARIABLE	bearer_stats ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl
    ${bearer_stat_dl}		ute_wtssim.Execute Egate Command And Wait For Data   ${bearer_stats_cmd}	pass_regexp=Average packet interval
    ...                     timeout=30
    wts_sim_keywords.Check Average Rate      ${bearer_stat_dl}    DL    ${dl_rate}
    Run keyword and Ignore Error    wts_sim_keywords.Check DL Data Loss for high data      ${bearer_stat_dl}    ${bearer_stat_dl}

Validate UL Traffic For SA
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. UL Bytes Sent must be equal to ALL Bytes Received
    [Arguments]    ${ue_id}     ${ul_rate}     ${pdu_id}=${Pdu_session_ID}      ${qfi_id}=${QFI_ID}
    ${bearer_stats_cmd}	SET VARIABLE	bearer_stats ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul
    ${bearer_stat_ul}		ute_wtssim.Execute Egate Command And Wait For Data   ${bearer_stats_cmd}	pass_regexp=Average packet interval
    ...                     timeout=30
    wts_sim_keywords.Check Average Rate      ${bearer_stat_ul}    UL    ${ul_rate}
    Run keyword and Ignore Error    wts_sim_keywords.Check UL Data Loss      ${bearer_stat_ul}    ${bearer_stat_ul}

Validate UL Traffic For MultiUE SA
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. UL Bytes Sent must be equal to ALL Bytes Received
    [Arguments]   ${start_ue_id}    ${end_ue_id}    ${ul_rate}     ${pdu_id}=${Pdu_session_ID}      ${qfi_id}=${QFI_ID}
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    ${bearer_stats_cmd}	SET VARIABLE	bearer_stats ue=${ue_idx} pdu=${pdu_id} qfi=${qfi_id} dir=ul
    ${bearer_stat_ul}		ute_wtssim.Execute Egate Command And Wait For Data   ${bearer_stats_cmd}	pass_regexp=Average packet interval
    ...                     timeout=30
    wts_sim_keywords.Check Average Rate      ${bearer_stat_ul}    UL    ${ul_rate}
    Run keyword and Ignore Error    wts_sim_keywords.Check UL Data Loss      ${bearer_stat_ul}    ${bearer_stat_ul}
	END

Traffic for SA should be Successful
    [Arguments]    ${traffic_dl_rate}=${Traffic_dl_rate}    ${traffic_ul_rate}=${Traffic_ul_rate_SA}
    [Documentation]    This keyword starts and Validates the Traffic for the SA variant
    Start and Validate Traffic For SA    dl_rate=${traffic_dl_rate}    ul_rate=${traffic_ul_rate}
    BuiltIn.Log    traffic_is_ok

Start and Validate Traffic For SA
    [Arguments]    ${dl_rate}=5    ${ul_rate}=3    ${duration}=30sec
    ${duration}       Get Variable Value    ${TRF_DURATION}    ${duration}
    Log to Console    \nRunning DL + UL Traffic for ${duration}...
    ${trf_start}	SET VARIABLE	trf_data_start ue=${ue_id} pdu=1 qfi=${qfi_id} dir=dl mbps=${dl_rate} period_ms=40
    ${output}		ute_wtssim.Execute Egate Command And Wait For Data   ${trf_start}    pass_regexp=UDP DL TRF: .*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    ${output}
    ${trf_start}	SET VARIABLE	trf_data_start ue=${ue_id} pdu=1 qfi=${qfi_id} dir=ul mbps=${ul_rate} period_ms=40
    ${output}		ute_wtssim.Execute Egate Command And Wait For Data   ${trf_start}    pass_regexp=UDP UL TRF: .*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    ${output}
    Sleep             ${duration}
    ${trf_status}     Run Keyword And Ignore Error    Validate Traffic For SA    ${dl_rate}    ${ul_rate}
    Should Be True    '${trf_status[0]}' == 'PASS'    msg=Traffic failed, see error above!
    Log to Console    Stopping DL + UL Traffic...
    ${trf_stop}	SET VARIABLE	trf_data_stop     ue=${ue_id}
    ${output}		ute_wtssim.Execute Egate Command And Wait For Data   ${trf_stop}	pass_regexp=Traffic was stopped   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    Traffic was stopped   partial_match=${TRUE}
    Log to Console    ${output}

Validate Traffic For SA
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. DL Bytes Received must be equal to ALL Bytes Sent
    ...                3. UL Bytes Sent must be equal to ALL Bytes Received
    [Arguments]    ${dl_rate}    ${ul_rate}
    ${bearer_stats}	SET VARIABLE	bearer_stats ue=${ue_id} pdu=1 qfi=1 dir=dl
    ${bearer_stat_dl}      ute_wtssim.Execute Egate Command And Wait For Data   ${bearer_stats}	pass_regexp=Average packet interval
    ...                     timeout=30
    wts_sim_keywords.Check Average Rate      ${bearer_stat_dl}    DL    ${dl_rate}
    Run keyword and Ignore Error    Check DL Data Loss      ${bearer_stat_dl}    ${bearer_stat_dl}

    ${bearer_stats}	SET VARIABLE	bearer_stats ue=${ue_id} pdu=1 qfi=1 dir=ul
    ${bearer_stat_ul}     ute_wtssim.Execute Egate Command And Wait For Data   ${bearer_stats}    pass_regexp=Average packet interval
    ...                     timeout=30
    wts_sim_keywords.Check Average Rate      ${bearer_stat_ul}    UL    ${ul_rate}
    Run keyword and Ignore Error    wts_sim_keywords.Check UL Data Loss      ${bearer_stat_ul}    ${bearer_stat_ul}

MultiUE Trigger DL Traffic for SA
    [Arguments]     ${start_ue_id}    ${end_ue_id}    ${Traffic_rate}    ${dl_rate}    ${pdu_id}=${Pdu_session_ID}
    ...     ${trf_id}=${TRF_ID}    ${qfi_id}=${QFI_ID}
    [Documentation]    This keyword starts the DL Traffic for the SA variant
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Log to Console    \nRunning DL Traffic for ${dl_rate} ${Traffic_rate}...
    ${data_cmd}	SET VARIABLE	trf_data_start ue=${ue_idx} pdu=${pdu_id} qfi=${qfi_id} dir=dl ${Traffic_rate}=${dl_rate} trf_id=${trf_id}
    ${output}		ute_wtssim.Execute Egate Command And Wait For Data   ${data_cmd}    pass_regexp=Started Downlink Internal traffic*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP DL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
	END
    BuiltIn.Log    DL_traffic_data_is_started_successfully

MultiUE Trigger UL Traffic for SA
    [Arguments]    ${start_ue_id}    ${end_ue_id}    ${Traffic_rate}    ${ul_rate}    ${pdu_id}=${Pdu_session_ID}
    ...     ${trf_id}=${TRF_ID}    ${qfi_id}=${QFI_ID}
    [Documentation]    This keyword starts the DL Traffic for the SA variant
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Log to Console    \nRunning UL Traffic for ${ul_rate} ${Traffic_rate}...
    ${trf_strt_cmd}	SET VARIABLE	trf_data_start ue=${ue_idx} pdu=${pdu_id} qfi=${qfi_id} dir=ul trf_id=${trf_id} ${Traffic_rate}=${ul_rate}
    ${output}		ute_wtssim.Execute Egate Command And Wait For Data   ${trf_strt_cmd}    pass_regexp=Started Uplink Internal traffic*
    ...    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP UL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
	END

Stop Data Traffic for SA
    [Arguments]    ${ue_id}
    [Documentation]    This keyword stops the Data Traffic for the SA variant
    Log to Console    \nStopping Data Traffic...
    ${trf_stop_cmd}	SET VARIABLE	trf_data_stop ue=${ue_id}
    ${output}		ute_wtssim.Execute Egate Command And Wait For Data   ${trf_stop_cmd}    pass_regexp==Traffic was stopped   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    Traffic was stopped   partial_match=${TRUE}
    Log to Console    ${output}

Stop Data Traffic for NSA
    [Arguments]    ${ue_id}
    [Documentation]    This keyword stops the Data Traffic for the SA variant
    Log to Console    \nStopping Data Traffic...
    ${trf_stop_cmd}	SET VARIABLE	trf_data_stop     ue=${ue_id}
    $${output}		ute_wtssim.Execute Egate Command And Wait For Data   ${trf_stop_cmd}    pass_regexp=Traffic was stopped   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    Traffic was stopped   partial_match=${TRUE}
    Log to Console    ${output}

TRF Data Stop for SA
    [Arguments]    ${ue_id}    ${pdu_id}    ${dir}    ${trf_id}
    [Documentation]    This keyword stops the Data Traffic for the SA variant
    Log to Console    \nStopping Data Traffic...
    ${trf_stop_cmd}	SET VARIABLE	trf_data_stop ue=${ue_id} pdu=${pdu_id} dir=${dir} trf_id=${trf_id}
    ${output}		ute_wtssim.Execute Egate Command And Wait For Data   ${trf_stop_cmd}    pass_regexp=Traffic was stopped   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    Traffic was stopped   partial_match=${TRUE}
    Log to Console    ${output}

TRF Data Stop for NSA
    [Arguments]    ${ue_id}    ${Bearer_ID}    ${dir}    ${trf_id}
    [Documentation]    This keyword stops the Data Traffic for the SA variant
    Log to Console    \nStopping Data Traffic...
    ${trf_stop_cmd}	SET VARIABLE	trf_data_stop ue=${ue_id} id=${Bearer_ID} dir=${dir} trf_id=${trf_id}
    ${output}		ute_wtssim.Execute Egate Command And Wait For Data   ${trf_stop_cmd}    pass_regexp=Traffic was stopped   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    Traffic was stopped   partial_match=${TRUE}
    Log to Console    ${output}

DL TRF Data Stop for SA
    [Arguments]    ${ue_id}    ${pdu_id}    ${dir}    ${trf_id}
    [Documentation]    This keyword stops the DL Data Traffic for the SA variant
    Log to Console    \nStopping Data Traffic...
    ${trf_stop_cmd}	SET VARIABLE	trf_data_stop ue=${ue_id} pdu=${pdu_id} dir=${dir} trf_id=${trf_id}
    ${output}		ute_wtssim.Execute Egate Command And Wait For Data   ${trf_stop_cmd}    pass_regexp=Stopped Downlink Internal traffic
    ...   timeout=10
    Log to Console    ${output}

MultiUE PDU Addition should be Successful
    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${pdu_id}     ${nw_id}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    ${gyw}=    Evaluate    int(${end_ue_id}) + int(${ue_idx})
    ${pdu_param_set}	SET VARIABLE	set_pdu_param ue=${ue_idx} pdu=${pdu_id} trf_type=internal
    ${pdu_setup}	SET VARIABLE	ue_pdu_session_setup pdu=${pdu_id} ue=${ue_idx} nwslice=${nw_id} gw=${gyw}
	ute_wtssim.Execute Egate Command    ${pdu_param_set}    timeout=${EGATE_COMMAND_TIMEOUT}
    ute_wtssim.Execute Egate Command And Wait For Data 		${pdu_setup}	pass_regexp=${pdu_addition_pattern}    timeout=${Timeout_SA}
    BuiltIn.Log          ue=${ue_idx} pdu=${pdu_id} added with pdu_gateway id=${gyw} successfully
	Log to Console       ue=${ue_idx} pdu=${pdu_id} added with pdu_gateway id=${gyw} successfully
	END

MultiUE PDU Modfication should be Successful
    [Arguments]     ${start_ue_id}    ${end_ue_id}     ${pdu_id}=${Pdu_session_ID}      ${qosflows_to_add}=${Q_O_ADD}
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    ${pdu_modify}	SET VARIABLE	ue_pdu_session_modify ue=${ue_idx} pdu=${pdu_id} qosflows_to_add=${qosflows_to_add} by=amf
    ${output}	ute_wtssim.Execute Egate Command And Wait For Data   ${pdu_modify}		pass_regexp=${Pdu_session_qos_patten}
    ...     timeout=${Timeout_SA}
    BuiltIn.Log               ue=${ue_idx} qosflow=${qosflows_to_add} added
	Log to Console            ue=${ue_idx} qosflow=${qosflows_to_add} added
    END
    BuiltIn.Log       All_ue_added_an_extra_qosflow_successfully
	Log to Console    All_ue_added_an_extra_qosflow_successfully

Stop MultiUE Data Traffic for SA
    [Arguments]    ${start_ue_id}   ${end_ue_id}
    [Documentation]    This keyword stops the Data Traffic for the SA variant
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Log to Console    \nStopping Data Traffic...
    ${trf_stop_cmd}		SET VARIABLE	trf_data_stop ue=${ue_idx}
	${output}	ute_wtssim.Execute Egate Command And Wait For Data   ${trf_stop_cmd}	pass_regexp=Traffic was stopped		timeout=${Timeout_SA}
    ${output}         Get Lines Matching Regexp    ${output}    Traffic was stopped   partial_match=${TRUE}
    Log to Console    ${output}
	END

Stop MultiUE Data Traffic for SA DL UL SP
    [Arguments]    ${start_ue_id}   ${end_ue_id}   ${pdu}   ${qfi}   ${trfid}
    [Documentation]    This keyword stops the Data Traffic for the SA variant
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Log to Console    \nStopping Data Traffic...
    ${trf_stop_cmd}		SET VARIABLE	trf_data_stop ue=${ue_idx} pdu=${pdu} qfi=${qfi} trf_id=${trfid}
    ${output}	ute_wtssim.Execute Egate Command And Wait For Data    ${trf_stop_cmd}   pass_regexp=Traffic was stopped   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    Traffic was stopped   partial_match=${TRUE}
    Log to Console    ${output}
	END

Trigger MultiUE VoNR DL Traffic for SA
    [Arguments]    ${start_ue_id}    ${end_ue_id}     ${pdu_id}=${Pdu_session_ID}     ${trf_id}=${TRF_ID}
	...     ${qfi_id}=${QFI_ID}   ${rtp_codec}=${RTP_COD}
    [Documentation]    This keyword starts the VoNR DL Traffic for the SA variant having some rtp codec
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Log to Console    \nRunning VoNR DL Traffic for ue=${ue_idx} with ${rtp_codec}...
    ${trf_start_cmd}		SET VARIABLE	trf_data_start ue=${ue_idx} pdu=${pdu_id} qfi=${qfi_id} dir=dl trf_id=${trf_id} rtp_codec=${rtp_codec}
    ${output}	ute_wtssim.Execute Egate Command And Wait For Data   ${trf_start_cmd}  pass_regexp=Started Downlink Internal traffic Receiver*
    ...     timeout=10
    Log to Console    ue=${ue_idx} ${output} VoNR_DL_traffic_data_is_started_successfully
    BuiltIn.Log       ue=${ue_idx} VoNR_DL_traffic_data_is_started_successfully
	END
	BuiltIn.Log       All_ue_started_DL_VoNR_traff_succesfully
	Log to Console    All_ue_started_DL_VoNR_traff_succesfully

Trigger MultiUE VoNR UL Traffic for SA
    [Arguments]    ${start_ue_id}    ${end_ue_id}     ${pdu_id}=${Pdu_session_ID}     ${trf_id}=${TRF_ID}
	...     ${qfi_id}=${QFI_ID}   ${rtp_codec}=${RTP_COD}
    [Documentation]    This keyword starts the VoNR UL Traffic for the SA variant having some rtp codec
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Log to Console    \nRunning VoNR UL Traffic for ue=${ue_idx} with ${rtp_codec}...
    ${trf_start_cmd}		SET VARIABLE	trf_data_start ue=${ue_idx} pdu=${pdu_id} qfi=${qfi_id} dir=ul trf_id=${trf_id} rtp_codec=${rtp_codec}
    ${output}	ute_wtssim.Execute Egate Command And Wait For Data   ${trf_start_cmd}  pass_regexp=Started Uplink Internal traffic*
    ...     timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP UL TRF:    partial_match=${TRUE}
    Log to Console    ue=${ue_idx} ${output} VoNR_UL_traffic_data_is_started_successfully
    BuiltIn.Log       ue=${ue_idx} VoNR_UL_traffic_data_is_started_successfully
	END
	BuiltIn.Log       All_ue_started_UL_VoNR_traff_succesfully
	Log to Console    All_ue_started_UL_VoNR_traff_succesfully

Validate DL Traffic For NSA
    [Documentation]    NSA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. DL Bytes Received must be equal to ALL Bytes Sent
    [Arguments]    ${ue_id}     ${dl_rate}     ${id}=${Bearer_ID}
    ${bearer_stats}	   SET VARIABLE	bearer_stats ue=${ue_id} id=${id} dir=dl
    ${bearer_stat_dl}      ute_wtssim.Execute Egate Command And Wait For Data   ${bearer_stats}	pass_regexp=Average packet interval
    ...                     timeout=30
    wts_sim_keywords.Check Average Rate      ${bearer_stat_dl}    DL    ${dl_rate}
    Run keyword and Ignore Error    wts_sim_keywords.Check DL Data Loss      ${bearer_stat_dl}    ${bearer_stat_dl}

Validate DL Traffic For MultiUE NSA
    [Documentation]    NSA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. DL Bytes Received must be equal to ALL Bytes Sent
    [Arguments]    ${start_ue_id}    ${end_ue_id}   ${dl_rate}     ${id}=${Bearer_ID}
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    ${bearer_stats}	   SET VARIABLE	bearer_stats ue=${ue_idx} id=${id} dir=dl
    ${bearer_stat_dl}      ute_wtssim.Execute Egate Command And Wait For Data   ${bearer_stats}	pass_regexp=Average packet interval
    ...                     timeout=30
    wts_sim_keywords.Check Average Rate      ${bearer_stat_dl}    DL    ${dl_rate}
    Run keyword and Ignore Error    wts_sim_keywords.Check DL Data Loss      ${bearer_stat_dl}    ${bearer_stat_dl}
	END

Validate DL Traffic For NSA for high data
    [Documentation]    NSA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. DL Bytes Received must be equal to ALL Bytes Sent
    [Arguments]    ${ue_id}     ${dl_rate}     ${id}=${Bearer_ID}
    ${bearer_stats}	SET VARIABLE	bearer_stats ue=${ue_id} id=${id}
    ${bearer_stat_dl}      ute_wtssim.Execute Egate Command And Wait For Data   ${bearer_stats}	pass_regexp=Average packet interval
    ...                     timeout=30
    wts_sim_keywords.Check Average Rate      ${bearer_stat_dl}    DL    ${dl_rate}
    Run keyword and Ignore Error    Check DL Data Loss for high data      ${bearer_stat_dl}    ${bearer_stat_dl}

Validate UL Traffic For NSA
    [Documentation]    NSA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. UL Bytes Sent must be equal to ALL Bytes Received
    [Arguments]    ${ue_id}     ${ul_rate}     ${id}=${Bearer_ID}
    ${bearer_stats}	SET VARIABLE	bearer_stats ue=${ue_id} id=${id} dir=ul
    ${bearer_stat_ul}      ute_wtssim.Execute Egate Command And Wait For Data   ${bearer_stats}	pass_regexp=Average packet interval
    ...                     timeout=30
    wts_sim_keywords.Check Average Rate      ${bearer_stat_ul}    UL    ${ul_rate}
    Run keyword and Ignore Error    wts_sim_keywords.Check UL Data Loss      ${bearer_stat_ul}    ${bearer_stat_ul}

Validate UL Traffic For MultiUE NSA
    [Documentation]    NSA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. UL Bytes Sent must be equal to ALL Bytes Received
    [Arguments]    ${start_ue_id}    ${end_ue_id}    ${ul_rate}     ${id}=${Bearer_ID}
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    ${bearer_stats}	SET VARIABLE	bearer_stats ue=${ue_idx} id=${id} dir=ul
    ${bearer_stat_ul}      ute_wtssim.Execute Egate Command And Wait For Data   ${bearer_stats} 	pass_regexp=Average packet interval
    ...                     timeout=30
     wts_sim_keywords.Check Average Rate      ${bearer_stat_ul}    UL    ${ul_rate}
    Run keyword and Ignore Error    wts_sim_keywords.Check UL Data Loss      ${bearer_stat_ul}    ${bearer_stat_ul}
	END

Check MultiUE Disp
    [Arguments]    ${startue_id}    ${endue_id}
    FOR    ${ue_idx}    IN RANGE   ${startue_id}    ${endue_id}+1
    ${ue_state}	 SET VARIABLE	ue_disp id=${ue_idx}
    ${state}    ute_wtssim.Execute Egate Command And Wait For Data   ${ue_state}	pass_regexp=PDN    timeout=30
    BuiltIn.Should Match Regexp   ${state}    state.*ACTIVE
    END

Multiue DL TRF Data Stop for SA
    [Arguments]     ${start_ue_id}   ${end_ue_id}   ${pdu_id}=1     ${trf_id}=1
    [Documentation]    This keyword stops the Data Traffic for the SA variant
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Log to Console    \nStopping Data Traffic...
    ${trf_stop_cmd}	SET VARIABLE	trf_data_stop ue=${ue_idx} pdu=${pdu_id} dir=dl trf_id=${trf_id}
    ${output}		ute_wtssim.Execute Egate Command And Wait For Data   ${trf_stop_cmd}    pass_regexp=Traffic was stopped   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    Traffic was stopped   partial_match=${TRUE}
    Log to Console    ${output}
    END

Multiue UL TRF Data Stop for SA
    [Arguments]     ${start_ue_id}   ${end_ue_id}   ${pdu_id}=1    ${trf_id}=1
    [Documentation]    This keyword stops the Data Traffic for the SA variant
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    Log to Console    \nStopping Data Traffic...
    ${trf_stop_cmd}	SET VARIABLE	trf_data_stop ue=${ue_idx} pdu=${pdu_id} dir=ul trf_id=${trf_id}
    ${output}		ute_wtssim.Execute Egate Command And Wait For Data   ${trf_stop_cmd}    pass_regexp=Stopping Uplink Internal   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    Stopping Uplink Internal   partial_match=${TRUE}
    Log to Console    ${output}
    END

Intiate Bler for Ues and activate
    [Arguments]    ${startue}    ${endue}
    ${profile}	   SET VARIABLE    bler_testmode_nr profile_id=1 dl_bler=60,60,60,60,60,60,60,60
    ute_wtssim.execute_egate_command    ${profile}
    FOR     ${ue_idx}   IN RANGE    ${startue}    ${endue}+1
    ${activate}	   SET VARIABLE    ue_testmode_set_nr id=${ue_idx} testmode=bler profile_id=1 action=activate
    ute_wtssim.execute_egate_command    ${activate}
    END


Get PDSCH UE Stats for Given CC
    [Arguments]    ${ue_id}=1    ${scell_idx}=0
    Log to Console    PDSCH UE stats for given CC
    # wtsemu.script    file=${run_script_log_set}    entry=sim_log_set_flush()
    ${cmd}	   SET VARIABLE    ue_stats_nr id=${ue_id} type=pdsch scell=${scell_idx}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}  pass_regexp=Average   timeout=10
    [Return]      ${output}

Get AVG DL DATA TRAFFIC For Given CC
    [Arguments]    ${ue_id}=1    ${scell_idx}=0     ${unit}=Mbps
    ${pdsch_ue_stats}    wts_sim_keywords.Get PDSCH UE Stats for Given CC    ${ue_id}    ${scell_idx}
	${avg_tput}   avg_dl_data.get_avg_dl_data_traffic    ${pdsch_ue_stats}    ${unit}
	Log to Console    ${avg_tput}
    [Return]      ${avg_tput}

Get PUSCH UE Stats for Given CC
    [Arguments]    ${ue_id}=1    ${scell_idx}=0
    Log to Console    PUSCH UE stats for given CC
    # wtsemu.script    file=${run_script_log_set}    entry=sim_log_set_flush()
    ${cmd}	   SET VARIABLE    ue_stats_nr id=${ue_id} type=pusch scell=${scell_idx}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}  pass_regexp=Average   timeout=10
    [Return]      ${output}

Get AVG UL DATA TRAFFIC For Given CC
    [Arguments]    ${ue_id}=1    ${scell_idx}=0     ${unit}=Mbps
    ${pdsch_ue_stats}    wts_sim_keywords.Get PUSCH UE Stats for Given CC    ${ue_id}    ${scell_idx}
	${avg_tput}   avg_dl_data.get_avg_dl_data_traffic    ${pdsch_ue_stats}    ${unit}
	Log to Console    ${avg_tput}
    [Return]      ${avg_tput}

Get Max DL Cell throughput
    [Documentation]    Cell throughput DL
    [Arguments]    ${enb_id}=2     ${cell_id}=1     ${uec_id}=1
    ${cell_stats_cmd}	SET VARIABLE   cell_stats_nr enb=${enb_id} id=${cell_id} uec=${uec_id} type=throughput
    ${cell_stats}      ute_wtssim.Execute Egate Command And Wait For Data   ${cell_stats_cmd}	pass_regexp=DL Max Data Rate
    ...                     timeout=30
    ${max_dl_cell_tput_kbps}      Cell_TPT.get_max_dl_cell_tput    cell_stats_nr=${cell_stats}
    ${max_dl_cell_tput_mbps}   Evaluate   ${max_dl_cell_tput_kbps}/1000
    Log to Console          Max DL cell throughput for Cell ${cell_id} = ${max_dl_cell_tput_mbps} mbps
    [Return]   ${max_dl_cell_tput_mbps}

Get Max UL Cell throughput
    [Documentation]    Cell throughput UL
    [Arguments]    ${enb_id}=2     ${cell_id}=1     ${uec_id}=1
    ${cell_stats_cmd}	SET VARIABLE   cell_stats_nr enb=${enb_id} id=${cell_id} uec=${uec_id} type=throughput
    ${cell_stats}      ute_wtssim.Execute Egate Command And Wait For Data   ${cell_stats_cmd}	pass_regexp=UL Max Data Rate
    ...                     timeout=30
    ${max_ul_cell_tput_kbps}      Cell_TPT.get_max_ul_cell_tput    cell_stats_nr=${cell_stats}
    ${max_ul_cell_tput_mbps}   Evaluate   ${max_ul_cell_tput_kbps}/1000
    Log to Console          Max UL cell throughput for Cell ${cell_id} = ${max_ul_cell_tput_mbps} mbps
    [Return]   ${max_ul_cell_tput_mbps}

Change Default 5QI Bearer
    [Arguments]    ${qosflow}    ${5QI}   ${fiveqi_type}=non-gbr    ${default}=off
    ${changedrb}	SET VARIABLE  qosflow_modify qos_flow=${qosflow} 5qi=${5QI} fiveqi_type=${fiveqi_type} default=${default}
    ute_wtssim.Execute Egate Command   ${changedrb} 	timeout=10s

Get Configured Measurements of UE${ue_id}
    BuiltIn.Log    Get configured Measurements...    console=${True}
    ${ue_meas_cmd}	SET VARIABLE   ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    ${output}   ute_wtssim.Execute Egate Command And Wait For Data     ${ue_meas_cmd}
    ...     pass_regexp=UE${ue_id} NR MEASUREMENT IDENTITIES:    timeout=10s
    ${output}         Get Lines Matching Regexp    ${output}    UE${ue_id} NR MEASUREMENT IDENTITIES:   partial_match=${TRUE}
    Log to Console    ${output}

Trigger A3 RsrpAndRsrq Measurement for intragnb HO
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}=50
     ${HO_cmd}	SET VARIABLE
     ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=1 srsrq_nr=1 phycell_id=${phycell_id} nrsrp_nr=30 nrsrq_nr=20
    ${output}   ute_wtssim.Execute Egate Command And Wait For Data    ${HO_cmd}
    ...     pass_regexp=rrcReconfigurationComplete    timeout=10s
    ${output}         Get Lines Matching Regexp    ${output}    rrcReconfigurationComplete   partial_match=${TRUE}
    Log to Console    ${output}

Trigger handover 5G to LTE cell
    [Documentation]    trigger handover to LTE
    [Arguments]     ${ue_id}=1    ${A2_meas_id}=1   ${B2_meas_id}=3
    ${HO_cmd}	catenate    SEPARATOR=${SPACE}
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${A2_meas_id} event=A2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0 phycell_id=50 nrsrp_nr=30
    ...    nrsrq_nr=30 rs_type=ssb index=0 nrs_result=30:30:0
    ${output}   ute_wtssim.Execute Egate Command And Wait For Data    ${HO_cmd}
    ...     pass_regexp=rrcReconfigurationComplete    timeout=10s
    ${HO_LTE_cmd}	catenate    SEPARATOR=${SPACE}
    ...   ue_measurement_send_nr id=${ue_id} meas_id=${B2_meas_id} event=B2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0 phycell_id=11
    ...   nrsrp_nr=30 nrsrq_nr=30 rs_type=ssb index=0 nrs_result=30:30:0
    ${output1}   ute_wtssim.Execute Egate Command And Wait For Data    ${HO_LTE_cmd}
    ...    pass_regexp=Successful handover from EXT_ENB-2.1 to ENB-4.1     timeout=15s

Trigger handover to LTE to 5G
    [Documentation]      trigger handover to 5G
    [Arguments]     ${ue_id}=1    ${target_cell}=1
    ${HO_5G_cmd}	SET VARIABLE    gnb_trigger_inter_rat_handover_to_5g ue=${ue_id} target_gnb=2 target_cell=${target_cell} plmn=311:489
    ${output}   ute_wtssim.Execute Egate Command And Wait For Data    ${HO_5G_cmd}
    ...     pass_regexp=rrcReconfigurationComplete    timeout=10s


MultiUE Register should be Successful with Fetch Bearer ID
    [Arguments]    ${start_ue_id}   ${end_ue_id}    ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}   ${sa_ue_nr_cap}=None  #${ue_cap_p}=${-1}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA varianti
    ${crnti_list}           Create List
    ${ue_to_bearer_list}    Create Dictionary
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
    ${cmd1}	    Set Variable	ue_register id=${ue_idx}
	${cmd2}	    Set Variable	ue_register id=${ue_idx} ue_nr_capabilities=${sa_ue_nr_cap}
	${ue_reg_cmd}   Set Variable if     '${sa_ue_nr_cap}'=='None'    ${cmd1}    ${cmd2}
	${output}		ute_wtssim.Execute Egate Command And Wait For Data  ${ue_reg_cmd}   pass_regexp=${UE_reg_complete_pattern}
    ...      timeout=${EGATE_COMMAND_TIMEOUT}
	Create File     ${OUTPUT_DIR}/regst.txt     ${output}
	${crnti_value}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk -F 'crnti:' '{print $2}'|cut -d ' ' -f 2
	BuiltIn.Log     ${crnti_value}
	Log to Console             ue${ue_idx}_register_is_ok with ${crnti_value}
	Append To List  ${crnti_list}   ${crnti_value}
	${set_pdu_param_cmd}	SET VARIABLE	set_pdu_param ue=${ue_idx} pdu=${pdu_id} trf_type=internal
    ${pdu_setup_cmd}	SET VARIABLE	ue_pdu_session_setup pdu=${pdu_id} ue=${ue_idx} nwslice=${nw_id} gw=${ue_idx}
	ute_wtssim.Execute Egate Command    ${set_pdu_param_cmd}    timeout=${EGATE_COMMAND_TIMEOUT}
	${output1}      ute_wtssim.Execute Egate Command And Wait For Data  ${pdu_setup_cmd}
	...		pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})      timeout=${EGATE_COMMAND_TIMEOUT}
	${bearer_list}       Create List
	${dummy_list}        Create List
    Create File	    ${OUTPUT_DIR}/bearer.txt	    ${output1}
    ${bearer_id}    Run     cat ${OUTPUT_DIR}/bearer.txt |grep -i "servedRadioBearer drb-Identity" |awk '{print $4}'|sed 's/,//g'
    ${qfi_id}       Run     cat ${OUTPUT_DIR}/bearer.txt |grep -i "AMF-1: Setup QosFlow with QFI:"|awk '{print $9}'|sed 's/,//g'
    ${qfi_id}       Replace String    ${qfi_id}    :    -
    log to console     qfi-${qfi_id}
    Append To List	    ${dummy_list}    ${qfi_id}  ${bearer_id}
    Append To List	    ${bearer_list}    ${dummy_list}
    Set To Dictionary	${ue_to_bearer_list} 	${ue_idx}	    ${bearer_list}
    BuiltIn.Log        ue=${ue_idx} with crnti=${crnti_value} is regtd ,pdu=${pdu_id} created and its crnti is appended in list ${crnti_list}
    END
    Log to Console             multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                multi_ue_register_is_ok with ${crnti_list}
    BuiltIn.Log                CRntilist:${crnti_list}
    [Return]      ${crnti_list}     ${ue_to_bearer_list}

Trigger VoNR DL Traffic for SA
    [Arguments]    ${ue_id}    ${pdu_id}=${Pdu_session_ID}     ${trf_id}=${TRF_ID}
	...     ${qfi_id}=${QFI_ID}   ${rtp_codec}=${RTP_COD}
    [Documentation]    This keyword starts the VoNR DL Traffic for the SA variant having some rtp codec
    Log to Console    \nRunning VoNR DL Traffic for ue=${ue_id} with ${rtp_codec}...
    ${trf_start_cmd}		SET VARIABLE	trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl trf_id=${trf_id} rtp_codec=${rtp_codec}
    ${output}	ute_wtssim.Execute Egate Command And Wait For Data   ${trf_start_cmd}  pass_regexp=Started Downlink Internal traffic Receiver*
    ...     timeout=10
    Log to Console    ue=${ue_id} ${output} VoNR_DL_traffic_data_is_started_successfully
    BuiltIn.Log       ue=${ue_id} VoNR_DL_traffic_data_is_started_successfully
	BuiltIn.Log       All_ue_started_DL_VoNR_traff_succesfully
	Log to Console    All_ue_started_DL_VoNR_traff_succesfully

Trigger VoNR UL Traffic for SA
    [Arguments]    ${ue_id}    ${pdu_id}=${Pdu_session_ID}     ${trf_id}=${TRF_ID}
	...     ${qfi_id}=${QFI_ID}   ${rtp_codec}=${RTP_COD}
    [Documentation]    This keyword starts the VoNR UL Traffic for the SA variant having some rtp codec
    Log to Console    \nRunning VoNR UL Traffic for ue=${ue_id} with ${rtp_codec}...
    ${trf_start_cmd}		SET VARIABLE	trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul trf_id=${trf_id} rtp_codec=${rtp_codec}
    ${output}	ute_wtssim.Execute Egate Command And Wait For Data   ${trf_start_cmd}  pass_regexp=Started Uplink Internal traffic*
    ...     timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP UL TRF:    partial_match=${TRUE}
    Log to Console    ue=${ue_id} ${output} VoNR_UL_traffic_data_is_started_successfully
    BuiltIn.Log       ue=${ue_id} VoNR_UL_traffic_data_is_started_successfully
	BuiltIn.Log       All_ue_started_UL_VoNR_traff_succesfully
	Log to Console    All_ue_started_UL_VoNR_traff_succesfully