*** Settings ***
Documentation    Specific Test Cases for subfeature CB008246-K#3 of "LA for HR DRBs"
Library     Collections
Library     ../../../L2/libraries/template_functions.py              WITH NAME   template

Resource    ../../../../resources/Common/coam_ulm.robot
Resource    ../../../../resources/Common/wts_ue.robot

# -----------------------------------------------------------------------------------------------------------------------------------[150 characters]



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

TC03_HR_IWK_CA_UL_SA_2CC_FDDTDD_HRDRB_after_SCell_Addition
    ${non_attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=sa    with_auto_attach=${FALSE}
    ${non_attached_ues_list}=  Get Dictionary Keys  ${non_attached_ues_dict}
    ${ue_id}=    Set Variable    ${non_attached_ues_list}[0]
    # -- Adding cell noise and pathloss ---------------------------------------------------------------------------------------------[150 characters]
    Changing Cell Noise Level For All Cells    noise=${default_noise}    cell_id=11
    Changing UE Pathloss Level For All UEs     non_attached_ues_list=${non_attached_ues_list}    pathloss_value=${default_pathloss}
    # -- Register UE1 ---------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command And Verify Output   cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    wts_ue . UE Register    ue_id=${ue_id}
    wts_ue . Send Egate Command And Verify Output   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1
    Sleep  1s
    # -- Start Traffic UE1 &nd PDU bearer modification ------------------------------------------------------------------------------[150 characters]
    Start Traffic In UL    ue_id=${ue_id}    qfi_id=1    trf_id=2    mbps=10
    Sleep  1s
    wts_ue . Send Egate Command And Verify Output   cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=8 by=amf
    Sleep  1s
    Start Traffic In UL    ue_id=${ue_id}    qfi_id=2    trf_id=3    mbps=10
    Sleep  1s
    wts_ue . Send Egate Command And Verify Output   cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=7 by=amf
    Sleep  1s
    Start Traffic In UL    ue_id=${ue_id}    qfi_id=3    trf_id=4    mbps=10
    Sleep  1s
# -- Changing cell Noise level --------------------------------------------------------------------------------------------------[150 characters]
    ${noise}=    Set Variable    -760
    FOR    ${noise}    IN RANGE    -760    -652    4
        wts_ue . Send Egate Command And Verify Output
        ...      cmd=ul_cell_noise_testmode_nr profile_id=2 noise_pucch=${noise} noise_prach=${noise} noise_pusch=${noise} noise_srs=${noise}
        wts_ue . Send Egate Command And Verify Output
        ...      cmd=ul_cell_noise_testmode_nr profile_id=2
        Sleep    0.3s
    END
    Sleep  3s
    FOR    ${noise}    IN RANGE    -652   -760    -4
        wts_ue . Send Egate Command And Verify Output
        ...      cmd=ul_cell_noise_testmode_nr profile_id=2 noise_pucch=${noise} noise_prach=${noise} noise_pusch=${noise} noise_srs=${noise}
        wts_ue . Send Egate Command And Verify Output
        ...      cmd=ul_cell_noise_testmode_nr profile_id=2
        Sleep    0.3s
    END
    Sleep  0.3s
    # -- Stop Traffic UE1 &nd Release PDU bearer  -----------------------------------------------------------------------------------[150 characters]
    Stop Traffic On UL And Release PDU Bearer    ue_id=${ue_id}    trf_id=4    qosflows=8
    Sleep  1s
    Stop Traffic On UL And Release PDU Bearer    ue_id=${ue_id}    trf_id=3    qosflows=7
    Sleep  1s
    # -- Deregister UEs -------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . UE Deregister    ue_id=${ue_id}
    Sleep  1s


TC04_HR_IWK_CA_UL_SA_2CC_FDDTDD_SCell_Addition_after_HRDRB
    ${non_attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=sa    with_auto_attach=${FALSE}
    ${non_attached_ues_list}=  Get Dictionary Keys  ${non_attached_ues_dict}
    ${ue_id}=    Set Variable    ${non_attached_ues_list}[0]
    # -- Adding cell noise and pathloss ---------------------------------------------------------------------------------------------[150 characters]
    Changing Cell Noise Level For All Cells    noise=${default_noise}    cell_id=all
    Changing UE Pathloss Level For All UEs     non_attached_ues_list=${non_attached_ues_list}    pathloss_value=${default_pathloss}
    # -- Register UE1 ---------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command And Verify Output   cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    wts_ue . UE Register    ue_id=${ue_id}
    wts_ue . Send Egate Command And Verify Output   cmd=smf_param additional_qosflows_to_activate=8 id=1
    wts_ue . Send Egate Command And Verify Output   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1
    Sleep  1s
    # -- Start Traffic UE1 &nd PDU bearer modification ------------------------------------------------------------------------------[150 characters]
    Start Traffic In UL    ue_id=${ue_id}    qfi_id=1    trf_id=2    mbps=20
    Sleep  1s
    Start Traffic In UL    ue_id=${ue_id}    qfi_id=2    trf_id=3    mbps=20
    Sleep  3s
    # -- Stop Traffic UE1 &nd Release PDU bearer  -----------------------------------------------------------------------------------[150 characters]
    Stop Traffic On UL And Release PDU Bearer    ue_id=${ue_id}    trf_id=3    qosflows=8
    Sleep  1s
    Stop Traffic On UL And Release PDU Bearer    ue_id=${ue_id}    trf_id=2    qosflows=1
    Sleep  1s
    # -- Deregister UEs -------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . UE Deregister    ue_id=${ue_id}
    Sleep  1s


TC07_TC09_HR_IWK_CA_UL_SA_2CC_FDDTDD_HRDRB_ACSI_DFT-s-OFDM
    ${non_attached_ues_dict}=  template.Get Attach List    scenario_name=${scenario_name}    ue_type=sa    with_auto_attach=${FALSE}
    ${non_attached_ues_list}=  Collections.Get Dictionary Keys  ${non_attached_ues_dict}
    ${ue_id}=    Set Variable    ${non_attached_ues_list}[0]
    # -- Adding cell noise and pathloss ---------------------------------------------------------------------------------------------[150 characters]
    Changing Cell Noise Level For All Cells    noise=${default_noise}    cell_id=11
    Changing UE Pathloss Level For All UEs     non_attached_ues_list=${non_attached_ues_list}    pathloss_value=${default_pathloss}
    # -- Register UE1 ---------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue.Set Traffic Type    ue_id=${ue_id}   pdu_id=1   trf_type=internal
    wts_ue.UE Register    ue_id=${ue_id}
    wts_ue.UE PDU Session Setup    ue_id=${ue_id}   pdu=1   nwslice=1   gw=1  pass_regexp=SCellIndex 1 activated successfully at airphone
    # -- Start Traffic UE1 &nd PDU bearer modification ------------------------------------------------------------------------------[150 characters]
    Start Traffic In UL    ue_id=${ue_id}    qfi_id=1    trf_id=2    mbps=50
    Sleep  0.1s
    wts_ue.Send Egate Command And Verify Output   cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=8 by=amf
    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID .* handled successfully
    Start Traffic In UL    ue_id=${ue_id}    qfi_id=2    trf_id=3    mbps=50
    Sleep  0.1s
    wts_ue.Send Egate Command And Verify Output   cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=7 by=amf
    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID .* handled successfully
    Start Traffic In UL    ue_id=${ue_id}    qfi_id=3    trf_id=4    mbps=50
    Sleep  0.1s
    # -- Changing cell Noise level --------------------------------------------------------------------------------------------------[150 characters]
    FOR    ${noise}    IN RANGE    -800    -500    20
        wts_ue.Send Egate Command And Verify Output
        ...      cmd=ul_cell_noise_testmode_nr profile_id=2 noise_pucch=${noise} noise_prach=${noise} noise_pusch=${noise} noise_srs=${noise}
        wts_ue.Send Egate Command And Verify Output
        ...      cmd=ul_cell_noise_testmode_nr profile_id=2
        Sleep    0.3s
    END
    Sleep  4s
    FOR    ${noise}    IN RANGE    -500   -800    -20
        wts_ue.Send Egate Command And Verify Output
        ...      cmd=ul_cell_noise_testmode_nr profile_id=2 noise_pucch=${noise} noise_prach=${noise} noise_pusch=${noise} noise_srs=${noise}
        wts_ue.Send Egate Command And Verify Output
        ...      cmd=ul_cell_noise_testmode_nr profile_id=2
        Sleep    0.3s
    END
    Sleep  1s
    # -- Stop Traffic UE1 &nd Release PDU bearer  -----------------------------------------------------------------------------------[150 characters]
    Stop Traffic On UL And Release PDU Bearer    ue_id=${ue_id}    trf_id=4    qosflows=7
    Sleep  0.1s
    Stop Traffic On UL And Release PDU Bearer    ue_id=${ue_id}    trf_id=3    qosflows=8
    Sleep  0.1s
    # -- Deregister UEs -------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue.UE Deregister    ue_id=${ue_id}


# -- Helper Keywords ----------------------------------------------------------------------------------------------------------------[150 characters]


Register MUE
    [Arguments]  ${non_attached_ues_list}
    FOR  ${id}  IN  @{non_attached_ues_list}
        wts_ue . Send Egate Command And Verify Output   cmd=set_pdu_param ue=${id} pdu=1 trf_type=internal
        UE Register    ue_id=${id}
        wts_ue . Send Egate Command And Verify Output   cmd=smf_param additional_qosflows_to_activate=7,8 id=1
        wts_ue . Send Egate Command And Verify Output   cmd=ue_pdu_session_setup pdu=1 ue=${id} nwslice=1 gw=1
    END


Deregister MUE
    [Arguments]  ${non_attached_ues_list}
    FOR  ${id}  IN  @{non_attached_ues_list}
        UE Deregister     ue_id=${id}
    END


Start Traffic In DL
    [Arguments]  ${ue_id}  ${qfi_id}  ${trf_id}  ${mbps}
    &{kwargs}=    Create Dictionary    mbps=${mbps}    pdu=1    qfi=${qfi_id}
    wts_ue . Start Data Traffic In Egate    ue_id=${ue_id}
    ...                                     direction=dl
    ...                                     protocol=udp
    ...                                     ack_mode=off
    ...                                     trf_id=${trf_id}
    ...                                     cl_trf_stats=on
    ...                                     &{kwargs}


Start Traffic In UL
    [Arguments]  ${ue_id}  ${qfi_id}  ${trf_id}  ${mbps}
    &{kwargs}=    Create Dictionary    mbps=${mbps}    pdu=1    qfi=${qfi_id}
    wts_ue . Start Data Traffic In Egate    ue_id=${ue_id}
    ...                                     direction=ul
    ...                                     protocol=udp
    ...                                     ack_mode=off
    ...                                     trf_id=${trf_id}
    ...                                     cl_trf_stats=on
    ...                                     &{kwargs}


Stop Traffic On UL And Release PDU Bearer
    [Arguments]  ${ue_id}   ${trf_id}    ${qosflows}
    wts_ue . Stop Data Traffic In Egate    ue_id=${ue_id}    direction=ul    trf_id=${trf_id}
    Sleep   1s
    wts_ue . Send Egate Command And Verify Output   cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=${qosflows} by=amf


Changing Cell Noise Level For All Cells
    [Arguments]  ${noise}   ${cell_id}
    wts_ue . Send Egate Command And Verify Output
    ...      cmd=ul_cell_noise_testmode_nr profile_id=2 noise_pucch=${noise} noise_prach=${noise} noise_pusch=${noise} noise_srs=${noise}
    wts_ue . Send Egate Command And Verify Output
    ...      cmd=ul_cell_noise_testmode_nr profile_id=2
    wts_ue . Send Egate Command And Verify Output
    ...      cmd=cell_testmode_set_nr cell_id=${cell_id} gnb=2 testmode=ul_cell_noise profile_id=2 action=activate


Changing UE Pathloss Level For All UEs
    [Arguments]  ${non_attached_ues_list}   ${pathloss_value}
    wts_ue . Send Egate Command And Verify Output
    ...      cmd=ul_sinr_testmode_nr profile_id=3 pathloss=${pathloss_value}
    wts_ue . Send Egate Command And Verify Output
    ...      cmd=ul_sinr_testmode_nr profile_id=3
    FOR  ${id}  IN  @{non_attached_ues_list}
        wts_ue . Send Egate Command And Verify Output
        ...      cmd=ue_testmode_set_nr id=${id} scell=0 testmode=ul_sinr profile_id=3 action=activate
    END

Simulate Pathloss
    [Arguments]    ${pathloss_start_dB}=75    ${pathloss_end_dB}=129    ${pathloss_step_dB}=1
    FOR    ${pathloss}    IN RANGE    ${pathloss_start_dB}    ${pathloss_end_dB}    ${pathloss_step_dB}
        wts_ue.Configure NR UL SINR testmode    profile_id=2    pathloss=${pathloss}
    END
# -----------------------------------------------------------------------------------------------------------------------------------[150 characters]
