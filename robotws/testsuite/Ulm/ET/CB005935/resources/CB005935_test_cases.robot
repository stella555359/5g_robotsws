*** Settings ***
Documentation    Specific Test Cases for CB005935 feature "Inter band FDD UL CA 2CCs"
Resource   ./../../../resources/Common/coam_ulm.robot

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]



*** Variables ***


${Cqi}                   7
${Rank}                  3
${Mcs}                   16
${Mcs_TC05}              1
${bler_profile_id}       30
${bler_profile_id_2}     32
${csio_profile_id}       31
${target_bler}           100,95,90,50,30,10,5,1,0,0,0,0,0,0,0
${default_noise}         -860
${default_pathloss}      75



*** Keywords ***

CB005935-BB-B2_Single_F+F_UL_2CCs_CA_UE_call_with_NACK_flood_triggered
    ${non_attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=sa    with_auto_attach=${FALSE}
    ${non_attached_ues_list}=  get dictionary keys  ${non_attached_ues_dict}
    ${ue_id}=    set variable    ${non_attached_ues_list}[0]
    #--- Adding cell noise and pathloss ---------------------------------------------------------------------------------------------[150 characters]
    Changing cell Noise level and activated    profile_id=2    noise=${default_noise}    cell_id=4
    Changing cell Noise level and activated    profile_id=4    noise=${default_noise}    cell_id=5
    Changing UE Pathloss level for all UEs     non_attached_ues_list=${non_attached_ues_list}    pathloss_value=${default_pathloss}
    #--- Register UE1 ---------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    wts_ue . UE Register    ue_id=${ue_id}
    wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1
    sleep  1s
    #--- Start Traffic --------------------------------------------------------------------------------------------------------------[150 characters]
    Start Traffic in UL    ue_id=${ue_id}    qfi_id=1    trf_id=2    mbps=80
    sleep  1s
    Start Traffic in DL    ue_id=${ue_id}    qfi_id=1    trf_id=2    mbps=5
    sleep  1s
    #--- Noise only on Scell---------------------------------------------------------------------------------------------------------[150 characters]
    ${noise}=    set variable    -100
    Changing cell Noise level    profile_id=4    noise=${noise}
    sleep  2s
    ${noise}=    set variable    -860
    Changing cell Noise level    profile_id=4    noise=${noise}
    sleep  1s
    #--- Noise only on Pcell---------------------------------------------------------------------------------------------------------[150 characters]
    ${noise}=    set variable    -100
    Changing cell Noise level    profile_id=2    noise=${noise}
    sleep  2s
    ${noise}=    set variable    -860
    Changing cell Noise level    profile_id=2    noise=${noise}
    sleep  1s
    #--- Noise on Both cells---------------------------------------------------------------------------------------------------------[150 characters]
    ${noise}=    set variable    -100
    Changing cell Noise level    profile_id=2    noise=${noise}
    Changing cell Noise level    profile_id=4    noise=${noise}
    sleep  1s
    ${noise}=    set variable    -860
    Changing cell Noise level    profile_id=2    noise=${noise}
    Changing cell Noise level    profile_id=4    noise=${noise}
    sleep  1s
    #--- Stop Traffic ---------------------------------------------------------------------------------------------------------------[150 characters]
    Stop traffic on UL    ue_id=${ue_id}    trf_id=2
    sleep  1s
    Stop traffic on DL    ue_id=${ue_id}    trf_id=2
    #--- Deregister UEs -------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . UE Deregister    ue_id=${ue_id}
    sleep  1s


CB005935_BB_B3_Interworking_with_uplink_closed_loop_power_control
    ${non_attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=sa    with_auto_attach=${FALSE}
    ${non_attached_ues_list}=  get dictionary keys  ${non_attached_ues_dict}
    ${ue_id}=    set variable    ${non_attached_ues_list}[0]
    #--- Adding cell noise and pathloss ---------------------------------------------------------------------------------------------[150 characters]
    Changing cell Noise level and activated    profile_id=2    noise=${default_noise}    cell_id=4
    Changing cell Noise level and activated    profile_id=4    noise=${default_noise}    cell_id=5
    Changing UE Pathloss level for all UEs     non_attached_ues_list=${non_attached_ues_list}    pathloss_value=${default_pathloss}
    #--- Register UE1 ---------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    wts_ue . UE Register    ue_id=${ue_id}
    wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1
    sleep  1s
    #--- Start Traffic --------------------------------------------------------------------------------------------------------------[150 characters]
    Start Traffic in UL    ue_id=${ue_id}    qfi_id=1    trf_id=2    mbps=50
    sleep  1s
    Start Traffic in DL    ue_id=${ue_id}    qfi_id=1    trf_id=2    mbps=5
    sleep  1s
    #--- Changing UE Noise level for Pcell ------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output
    ...      cmd=ul_cell_noise_testmode_nr profile_id=2 noise_pucch=-560 noise_prach=-560 noise_pusch=-560 noise_srs=-560
    wts_ue . Send Egate Command and verify output
    ...      cmd=ul_cell_noise_testmode_nr profile_id=2
    sleep  1s
    wts_ue . Send Egate Command and verify output
    ...      cmd=ul_cell_noise_testmode_nr profile_id=2 noise_pucch=-760 noise_prach=-760 noise_pusch=-760 noise_srs=-760
    wts_ue . Send Egate Command and verify output
    ...      cmd=ul_cell_noise_testmode_nr profile_id=2
    sleep  1s
    #--- Changing UE Noise level for Scell ------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output
    ...      cmd=ul_cell_noise_testmode_nr profile_id=4 noise_pucch=-560 noise_prach=-560 noise_pusch=-560 noise_srs=-560
    wts_ue . Send Egate Command and verify output
    ...      cmd=ul_cell_noise_testmode_nr profile_id=4
    sleep  1s
    wts_ue . Send Egate Command and verify output
    ...      cmd=ul_cell_noise_testmode_nr profile_id=4 noise_pucch=-760 noise_prach=-760 noise_pusch=-760 noise_srs=-760
    wts_ue . Send Egate Command and verify output
    ...      cmd=ul_cell_noise_testmode_nr profile_id=4
    sleep  1s
    #--- Stop Traffic ---------------------------------------------------------------------------------------------------------------[150 characters]
    Stop traffic on UL    ue_id=${ue_id}    trf_id=2
    sleep  1s
    Stop traffic on DL    ue_id=${ue_id}    trf_id=2
    #--- Deregister UEs -------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . UE Deregister    ue_id=${ue_id}
    sleep  1s


CB005935-ET-BB001_FF ULCA IWK with overheating UAI
    ${non_attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=sa    with_auto_attach=${FALSE}
    ${non_attached_ues_list}=  get dictionary keys  ${non_attached_ues_dict}
    ${ue_id}=    set variable    ${non_attached_ues_list}[0]
    #--- Adding cell noise and pathloss ---------------------------------------------------------------------------------------------[150 characters]
    Changing cell Noise level and activated    profile_id=2    noise=${default_noise}    cell_id=all
    Changing UE Pathloss level for all UEs     non_attached_ues_list=${non_attached_ues_list}    pathloss_value=${default_pathloss}
    #--- Register UE1 ---------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    wts_ue . UE Register    ue_id=${ue_id}
    wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1
    sleep  1s
    #--- Send A1 measurement report---------------------------------------------------------------------------------------------------[150 characters]
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=3 event=A1 rs_type=ssb srsrp_nr=70
    ${output}=    Send Egate Command and verify output   cmd=${cmd}
    sleep  1s
    #--- Start Traffic --------------------------------------------------------------------------------------------------------------[150 characters]
    Start Traffic in UL    ue_id=${ue_id}    qfi_id=1    trf_id=2    mbps=80
    sleep  1s
    Start Traffic in DL    ue_id=${ue_id}    qfi_id=1    trf_id=2    mbps=175
    sleep  1s
    #--- Triggering OverheatingAssistance  ------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=ue_assistance_send_nr ue_id=${ue_id} forOverheating=on reducedCCsDL=0 reducedCCsUL=2
    sleep  2s
    wts_ue . Send Egate Command and verify output   cmd=ue_assistance_send_nr ue_id=${ue_id} forOverheating=on reducedCCsDL=4 reducedCCsUL=0
    sleep  2s
    #--- RRE to original cell-2, then trigger A1 MR  --------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=ue_rrc_reestablish id=${ue_id} gnb=2 cell=2
    sleep  1s
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=6 event=A1 rs_type=ssb srsrp_nr=70
    ${output}=    Send Egate Command and verify output   cmd=${cmd}
    sleep  1s
    #--- Triggering OverheatingAssistance  ------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=ue_assistance_send_nr ue_id=${ue_id} forOverheating=on reducedCCsDL=1 reducedCCsUL=0
    sleep  2s
    wts_ue . Send Egate Command and verify output   cmd=ue_assistance_send_nr ue_id=${ue_id} forOverheating=on reducedCCsDL=3 reducedCCsUL=1
    sleep  2s
    #--- RRE from original cell-2 to new cell-4 -------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=ue_rrc_reestablish id=${ue_id} gnb=2 cell=4
    sleep  1s
    #--- Trigger interfreq HO from new cell-4 to original cell-2 --------------------------------------------------------------------[150 characters]
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=9 event=A2 rs_type=ssb srsrp_nr=20
    ${output}=    Send Egate Command and verify output   cmd=${cmd}
    sleep  1s
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=13 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=51
	...                   nrsrp_nr=100 nrsrq_nr=100 rs_type=ssb index=0 nrs_result=30:30:30
    ${output}=    Send Egate Command and verify output   cmd=${cmd}
    sleep  1s
    #--- Triggering OverheatingAssistance  ------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=ue_assistance_send_nr ue_id=${ue_id} forOverheating=on reducedCCsDL=3 reducedCCsUL=0
    sleep  2s
    wts_ue . Send Egate Command and verify output   cmd=ue_assistance_send_nr ue_id=${ue_id} forOverheating=on reducedCCsDL=4 reducedCCsUL=0
    sleep  2s
    #--- RRE from original cell-2 to new cell-4 -------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=ue_rrc_reestablish id=${ue_id} gnb=2 cell=4
    sleep  1s
    #--- 2nd RRE to new cell-4 ------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=ue_rrc_reestablish id=${ue_id} gnb=2 cell=4
    sleep  1s
    #--- RRE to original cell-2, then trigger A1 MR  --------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=ue_rrc_reestablish id=${ue_id} gnb=2 cell=2
    sleep  1s
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=24 event=A1 rs_type=ssb srsrp_nr=70
    ${output}=    Send Egate Command and verify output   cmd=${cmd}
    Log    ${output}
    sleep  1s
    #--- Triggering OverheatingAssistance  ------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=ue_assistance_send_nr ue_id=${ue_id} forOverheating=on reducedCCsDL=3 reducedCCsUL=2
    sleep  2s
    #--- Stop Traffic ---------------------------------------------------------------------------------------------------------------[150 characters]
    Stop traffic on UL    ue_id=${ue_id}    trf_id=2
    sleep  1s
    Stop traffic on DL    ue_id=${ue_id}    trf_id=2
    #--- Deregister UEs -------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . UE Deregister    ue_id=${ue_id}
    sleep  1s


CB005935_C001_FF_ULCA_IWK_with_9059
    ${non_attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=sa    with_auto_attach=${FALSE}
    ${non_attached_ues_list}=  get dictionary keys  ${non_attached_ues_dict}
    #--- Adding cell noise and pathloss ---------------------------------------------------------------------------------------------[150 characters]
    Changing cell Noise level and activated    profile_id=2    noise=${default_noise}    cell_id=all
    Changing UE Pathloss level for all UEs     non_attached_ues_list=${non_attached_ues_list}    pathloss_value=${default_pathloss}
    FOR  ${ue_id}  IN  @{non_attached_ues_list}
        wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
        wts_ue . UE Register    ue_id=${ue_id}
        wts_ue . Send Egate Command and verify output   cmd=smf_param additional_qosflows_to_activate=8 id=1
        wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1
        sleep  1s
        Start Traffic in UL    ue_id=${ue_id}    qfi_id=1    trf_id=2    mbps=30
        Start Traffic in DL    ue_id=${ue_id}    qfi_id=1    trf_id=2    mbps=30
        sleep  1s
        Start Traffic in UL    ue_id=${ue_id}    qfi_id=2    trf_id=3    mbps=30
        Start Traffic in DL    ue_id=${ue_id}    qfi_id=2    trf_id=3    mbps=30
        sleep  1s
        wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=4 by=amf
        sleep  1s
        Start Traffic in UL    ue_id=${ue_id}    qfi_id=3    trf_id=4    mbps=10
        Start Traffic in DL    ue_id=${ue_id}    qfi_id=3    trf_id=4    mbps=10
        sleep  1s
        Stop traffic and release PDU bearer    ue_id=${ue_id}    trf_id=4    qosflows=4
        sleep  1s
        Stop traffic on UL    ue_id=${ue_id}    trf_id=2
        Stop traffic on UL    ue_id=${ue_id}    trf_id=3
        sleep  1s
        Stop traffic on DL    ue_id=${ue_id}    trf_id=2
        Stop traffic on DL    ue_id=${ue_id}    trf_id=3
        sleep  1s
        wts_ue . UE Deregister    ue_id=${ue_id}
    END


CB005935-BD-B3_1_Interworking_with_CB008246_Link_Adaptation_for_HR_DRB_on_all_cells
    ${non_attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=sa    with_auto_attach=${FALSE}
    ${non_attached_ues_list}=  get dictionary keys  ${non_attached_ues_dict}
    ${ue_id}=    set variable    ${non_attached_ues_list}[0]
    #--- Adding cell noise and pathloss ---------------------------------------------------------------------------------------------[150 characters]
    Changing cell Noise level and activated    profile_id=2    noise=${default_noise}    cell_id=all
    Changing UE Pathloss level for all UEs     non_attached_ues_list=${non_attached_ues_list}    pathloss_value=${default_pathloss}
    #--- Register UE1 ---------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    wts_ue . UE Register    ue_id=${ue_id}
    wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1
    sleep  1s
    #--- Start Traffic --------------------------------------------------------------------------------------------------------------[150 characters]
    Start Traffic in UL    ue_id=${ue_id}    qfi_id=1    trf_id=2    mbps=80
    sleep  1s
    Start Traffic in DL    ue_id=${ue_id}    qfi_id=1    trf_id=2    mbps=175
    sleep  1s
    #--- Stop Traffic ---------------------------------------------------------------------------------------------------------------[150 characters]
    Stop traffic on UL    ue_id=${ue_id}    trf_id=2
    sleep  1s
    Stop traffic on DL    ue_id=${ue_id}    trf_id=2
    #--- Deregister UEs -------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . UE Deregister    ue_id=${ue_id}
    sleep  1s


CB005935-C-B4_1_Interworking_with_cache_optimized_L2_software_deployment_for_FR1-FDD
    ${non_attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=sa    with_auto_attach=${FALSE}
    ${non_attached_ues_list}=  get dictionary keys  ${non_attached_ues_dict}
    ${ue_id}=    set variable    ${non_attached_ues_list}[0]
    #--- Adding cell noise and pathloss ---------------------------------------------------------------------------------------------[150 characters]
    Changing cell Noise level and activated    profile_id=2    noise=${default_noise}    cell_id=4
    Changing cell Noise level and activated    profile_id=4    noise=${default_noise}    cell_id=5
    Changing UE Pathloss level for all UEs     non_attached_ues_list=${non_attached_ues_list}    pathloss_value=${default_pathloss}
    #--- RegisterUE1-8---------------------------------------------------------------------------------------------------------------[150 characters]
    #wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Register MUE    ue_id=${ue_id}
    #wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1
    sleep  1s
    #--- Start Traffic --------------------------------------------------------------------------------------------------------------[150 characters]
    Start Traffic in UL    ue_id=1   qfi_id=1    trf_id=2    mbps=10
    sleep  1s
    Start Traffic in DL    ue_id=1    qfi_id=1    trf_id=2    mbps=10
    sleep  1s
    #Start Traffic in UL    ue_id=${ue_id}    qfi_id=1    trf_id=2    mbps=10
    #sleep  1s
    #Start Traffic in DL    ue_id=${ue_id}    qfi_id=1    trf_id=2    mbps=10
    #sleep  1s
    #--- Changing UE Noise level for Pcell ------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output
    ...      cmd=ul_cell_noise_testmode_nr profile_id=2 noise_pucch=-560 noise_prach=-560 noise_pusch=-560 noise_srs=-560
    wts_ue . Send Egate Command and verify output
    ...      cmd=ul_cell_noise_testmode_nr profile_id=2
    sleep  1s
    wts_ue . Send Egate Command and verify output
    ...      cmd=ul_cell_noise_testmode_nr profile_id=2 noise_pucch=-760 noise_prach=-760 noise_pusch=-760 noise_srs=-760
    wts_ue . Send Egate Command and verify output
    ...      cmd=ul_cell_noise_testmode_nr profile_id=2
    sleep  1s
    #--- Changing UE Noise level for Scell ------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output
    ...      cmd=ul_cell_noise_testmode_nr profile_id=4 noise_pucch=-560 noise_prach=-560 noise_pusch=-560 noise_srs=-560
    wts_ue . Send Egate Command and verify output
    ...      cmd=ul_cell_noise_testmode_nr profile_id=4
    sleep  1s
    wts_ue . Send Egate Command and verify output
    ...      cmd=ul_cell_noise_testmode_nr profile_id=4 noise_pucch=-760 noise_prach=-760 noise_pusch=-760 noise_srs=-760
    wts_ue . Send Egate Command and verify output
    ...      cmd=ul_cell_noise_testmode_nr profile_id=4
    sleep  1s
    #--- Stop Traffic ---------------------------------------------------------------------------------------------------------------[150 characters]
    Stop traffic on UL    ue_id=1    trf_id=2
    sleep  1s
    Stop traffic on DL    ue_id=1    trf_id=2
    #Stop traffic on UL    ue_id=${ue_id}    trf_id=2
    #sleep  1s
    #Stop traffic on DL    ue_id=${ue_id}    trf_id=2
    #--- Deregister UEs -------------------------------------------------------------------------------------------------------------[150 characters]
    #wts_ue . UE Deregister    ue_id=${ue_id}
    #sleep  1s
    Deregister MUE    ue_id=${ue_id}
    sleep 1s


#--- Helper Keywords ----------------------------------------------------------------------------------------------------------------[150 characters]

Register MUE
    [Arguments]  ${non_attached_ues_list}
    FOR  ${id}  IN  @{non_attached_ues_list}
        wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${id} pdu=1 trf_type=internal
        UE Register    ue_id=${id}
        wts_ue . Send Egate Command and verify output   cmd=smf_param additional_qosflows_to_activate=7,8 id=1
        wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${id} nwslice=1 gw=1
    END


Deregister MUE
    [Arguments]  ${non_attached_ues_list}
    Log    Deregister MUE
    FOR  ${id}  IN  @{non_attached_ues_list}
        UE Deregister     ue_id=${id}
    END


Start Traffic in DL
    [Arguments]  ${ue_id}  ${qfi_id}  ${trf_id}  ${mbps}
    &{kwargs}=    create dictionary    mbps=${mbps}    pdu=1    qfi=${qfi_id}
    wts_ue . Start data traffic in egate    ue_id=${ue_id}
    ...                                     direction=dl
    ...                                     protocol=udp
    ...                                     ack_mode=off
    ...                                     trf_id=${trf_id}
    ...                                     cl_trf_stats=on
    ...                                     &{kwargs}


Start Traffic in UL
    [Arguments]  ${ue_id}  ${qfi_id}  ${trf_id}  ${mbps}
    &{kwargs}=    create dictionary    mbps=${mbps}    pdu=1    qfi=${qfi_id}
    wts_ue . Start data traffic in egate    ue_id=${ue_id}
    ...                                     direction=ul
    ...                                     protocol=udp
    ...                                     ack_mode=off
    ...                                     trf_id=${trf_id}
    ...                                     cl_trf_stats=on
    ...                                     &{kwargs}


Stop traffic on UL
    [Arguments]  ${ue_id}   ${trf_id}
    Log    Stop traffic on UL
    wts_ue . Stop data traffic in egate    ue_id=${ue_id}    direction=ul    trf_id=${trf_id}


Stop traffic on DL
    [Arguments]  ${ue_id}   ${trf_id}
    Log    Stop traffic on DL
    wts_ue . Stop data traffic in egate    ue_id=${ue_id}    direction=dl    trf_id=${trf_id}


Stop traffic on UL and release PDU bearer
    [Arguments]  ${ue_id}   ${trf_id}    ${qosflows}
    wts_ue . Stop data traffic in egate    ue_id=${ue_id}    direction=ul    trf_id=${trf_id}
    sleep   1s
    wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=${qosflows} by=amf


Changing cell Noise level and activated
    [Arguments]  ${profile_id}   ${noise}   ${cell_id}
    wts_ue . Send Egate Command and verify output
    ...      cmd=ul_cell_noise_testmode_nr profile_id=${profile_id} noise_pucch=${noise} noise_prach=${noise} noise_pusch=${noise} noise_srs=${noise}
    wts_ue . Send Egate Command and verify output
    ...      cmd=ul_cell_noise_testmode_nr profile_id=${profile_id}
    wts_ue . Send Egate Command and verify output
    ...      cmd=cell_testmode_set_nr cell_id=${cell_id} gnb=2 testmode=ul_cell_noise profile_id=${profile_id} action=activate


Changing cell Noise level
    [Arguments]  ${profile_id}   ${noise}
    wts_ue . Send Egate Command and verify output
    ...      cmd=ul_cell_noise_testmode_nr profile_id=${profile_id} noise_pucch=${noise} noise_prach=${noise} noise_pusch=${noise} noise_srs=${noise}
    wts_ue . Send Egate Command and verify output
    ...      cmd=ul_cell_noise_testmode_nr profile_id=${profile_id}


Changing UE Pathloss level for all UEs
    [Arguments]  ${non_attached_ues_list}   ${pathloss_value}
    wts_ue . Send Egate Command and verify output
    ...      cmd=ul_sinr_testmode_nr profile_id=3 pathloss=${pathloss_value}
    wts_ue . Send Egate Command and verify output
    ...      cmd=ul_sinr_testmode_nr profile_id=3
    FOR  ${id}  IN  @{non_attached_ues_list}
        wts_ue . Send Egate Command and verify output
        ...      cmd=ue_testmode_set_nr id=${id} scell=0 testmode=ul_sinr profile_id=3 action=activate
    END


Simulate Pathloss
    [Arguments]    ${pathloss_start_dB}=75    ${pathloss_end_dB}=129    ${pathloss_step_dB}=1
    Log    Simulate Pathloss
    FOR    ${pathloss}    IN RANGE    ${pathloss_start_dB}    ${pathloss_end_dB}    ${pathloss_step_dB}
        wts_ue.Configure NR UL SINR testmode    profile_id=2    pathloss=${pathloss}
    END


Stop traffic and release PDU bearer
    [Arguments]  ${ue_id}   ${trf_id}    ${qosflows}
    wts_ue . Stop data traffic in egate    ue_id=${ue_id}    direction=bi    trf_id=${trf_id}
    sleep   1s
    wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=${qosflows} by=amf

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
