*** Settings ***
Documentation    Specific Test Cases for subfeature "CB008409-B: PowerBoostVoNR_and_SRB_transmissions"
Resource   ./../../../../../resources/Common/coam_ulm.robot

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]



*** Variables ***


${Cqi}                   6
${Rank}                  1
${Mcs}                   17
${csio_profile_id}       31
${target_bler}           100,90,80,60,40,20,15,13,10,8,5,0.5,0,0,0
${retx_target_bler1}     95,95,95,95,95,95,95,95,95,95,95,95,95,95,95
${retx_target_bler2}     90,90,90,90,90,90,90,90,90,90,90,90,90,90,90
${retx_target_bler3}     85,85,85,85,85,85,85,85,85,85,85,85,85,85,85
${dtx_profile_id}        35

*** Keywords ***

TC_B3_IWK_Enhanced_MU-MIMO
    ${non_attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=sa    with_auto_attach=${FALSE}
    ${non_attached_ues_list}=  get dictionary keys  ${non_attached_ues_dict}
    ${ue_id}=      set variable    ${non_attached_ues_list}[0]
    ${ue_id_2}=    set variable    ${non_attached_ues_list}[1]
    ${ue_id_3}=    set variable    ${non_attached_ues_list}[2]
    ${ue_id_4}=    set variable    ${non_attached_ues_list}[3]
    ${Mcs}=    set variable    16
    #--- Set CQI vlaues for all UEs -------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Update UE Channel State Information  profile_id=${csio_profile_id}  cqi=${Cqi}  cqi_mode=oscillating
    ...     cqi_min=6  cqi_max=8  cqi_step=1  cqi_period=3  ri=${Rank}  ri_mode=fixed
    #--- Set CSI_override on all UEs ------------------------------------------------------------------------------------------------[150 characters]
    FOR   ${id}    IN RANGE    ${ue_id}    ${ue_id_4}+1    1
        wts_ue . Associate UEs to testmode
        ...      ue_id=${id}    profile_id=${csio_profile_id}    action=activate    testmode=csi_override
    END
    #------ New adv_bler testmode----------------------------------------------------------------------------------------------------[150 characters]
    ${cmd}    Catenate     adv_bler_testmode_nr profile_id=1 target_bler_profile_id=1
    ...    target_bler=${target_bler} retx_target_bler1=${retx_target_bler1}  retx_target_bler2=${retx_target_bler2}
    ...    target_mcs=8 rank=1 mcs_table=qam64 p_target_bler_profile_id=1
    ...    target_mcs=7 rank=2 mcs_table=qam64 p_target_bler_profile_id=1
    ...    target_mcs=7 rank=3 mcs_table=qam64 p_target_bler_profile_id=1
    ...    target_mcs=7 rank=4 mcs_table=qam64 p_target_bler_profile_id=1
    ...    target_mcs=4 rank=1 mcs_table=qam256 p_target_bler_profile_id=1
    ...    target_mcs=4 rank=2 mcs_table=qam256 p_target_bler_profile_id=1
    ...    target_mcs=4 rank=3 mcs_table=qam256 p_target_bler_profile_id=1
    ...    target_mcs=4 rank=4 mcs_table=qam256 p_target_bler_profile_id=1
    wts_ue . Send Egate Command and verify output     cmd=${cmd}
    #-- to print config in log
    wts_ue . Send Egate Command and verify output   cmd=adv_bler_testmode_nr profile_id=1

    #--- Register UEs ---------------------------------------------------------------------------------------------------------------[150 characters]
    FOR   ${id}    IN RANGE    ${ue_id}    ${ue_id_4}+1    1
        wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${id} pdu=1 trf_type=internal
        wts_ue . UE Register    ue_id=${id}
    END
    #--- Setup PDU with dedicated 5qi6 , GBR 5qi1, GBR 5qi5--------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=smf_param additional_qosflows_to_activate=2,3 id=1
    FOR   ${id}    IN RANGE    ${ue_id}    ${ue_id_4}+1    1
        wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${id} nwslice=1 gw=1
    END
    #---Associate Advance BLER profile to UE2 and UE4--------------------------------------------------------------------------------[150 characters]
    wts_ue . Associate UEs to testmode    ue_id=${ue_id_2},${ue_id_4}
    ...                                   profile_id=1    action=activate    testmode=adv_bler
    #--- Start Traffic on UEs -------------------------------------------------------------------------------------------------------[150 characters]
    Start Traffic in DL    ue_id=${ue_id}      qfi_id=1    trf_id=2    mbps=100
    Start Traffic in DL    ue_id=${ue_id_2}    qfi_id=1    trf_id=2    mbps=50
    Start Traffic in DL    ue_id=${ue_id_3}    qfi_id=1    trf_id=2    mbps=100
    Start Traffic in DL    ue_id=${ue_id_4}    qfi_id=1    trf_id=2    mbps=50

    Start Traffic in DL    ue_id=${ue_id_2}    qfi_id=3    trf_id=4    mbps=1
    Start Traffic in DL    ue_id=${ue_id_4}    qfi_id=3    trf_id=4    mbps=1
    Start Traffic in UL    ue_id=${ue_id_2}    qfi_id=3    trf_id=4    mbps=1
    Start Traffic in UL    ue_id=${ue_id_4}    qfi_id=3    trf_id=4    mbps=1
    sleep  5s
    wts_ue . Associate UEs to testmode    ue_id=${ue_id_2},${ue_id_4}
    ...                                   profile_id=1    action=deactivate    testmode=adv_bler
    #---Stop Traffic on all UEs -----------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=trf_data_stop ue=${ue_id}-${ue_id_4} dir=bi trf_id=2,3,4 pdu=1
    #---Deregister all UEs ----------------------------------------------------------------------------------------------------------[150 characters]
    FOR   ${id}    IN RANGE    ${ue_id}    ${ue_id_4}+1    1
        wts_ue . Associate UEs to testmode
        ...      ue_id=${id}    profile_id=${csio_profile_id}    action=deactivate    testmode=csi_override
        wts_ue . UE Deregister    ue_id=${id}
    END

TC_B5_IWK_PRB_pooling
    ${non_attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=sa    with_auto_attach=${FALSE}
    ${non_attached_ues_list}=  get dictionary keys  ${non_attached_ues_dict}
    ${ue_id}=      set variable    ${non_attached_ues_list}[0]
    ${ue_id_2}=    set variable    ${non_attached_ues_list}[1]
    ${ue_id_3}=    set variable    ${non_attached_ues_list}[2]
    ${ue_id_4}=    set variable    ${non_attached_ues_list}[3]
    ${ue_id_5}=    set variable    ${non_attached_ues_list}[4]
    ${ue_id_6}=    set variable    ${non_attached_ues_list}[5]
    ${ue_id_7}=    set variable    ${non_attached_ues_list}[6]
    ${Mcs}=    set variable    16
    #--- Set CQI to 5 for all UEs ---------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Update UE Channel State Information  profile_id=${csio_profile_id}  cqi=${Cqi}  cqi_mode=oscillating
    ...     cqi_min=6  cqi_max=8  cqi_step=1  cqi_period=3  ri=1  ri_mode=fixed
    #--- Set CSI_override on all UEs ------------------------------------------------------------------------------------------------[150 characters]
    FOR   ${id}    IN RANGE    ${ue_id}    ${ue_id_7}+1    1
        wts_ue . Associate UEs to testmode
        ...      ue_id=${id}    profile_id=${csio_profile_id}    action=activate    testmode=csi_override
    END
    #------ New adv_bler testmode----------------------------------------------------------------------------------------------------[150 characters]
    ${cmd}    Catenate     adv_bler_testmode_nr profile_id=1 target_bler_profile_id=1
    ...    target_bler=${target_bler} retx_target_bler1=${retx_target_bler1}  retx_target_bler2=${retx_target_bler2}
    ...    target_mcs=8 rank=1 mcs_table=qam64 p_target_bler_profile_id=1
    ...    target_mcs=7 rank=2 mcs_table=qam64 p_target_bler_profile_id=1
    ...    target_mcs=7 rank=3 mcs_table=qam64 p_target_bler_profile_id=1
    ...    target_mcs=7 rank=4 mcs_table=qam64 p_target_bler_profile_id=1
    wts_ue . Send Egate Command and verify output     cmd=${cmd}
    #-------- To print config in log-------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=adv_bler_testmode_nr profile_id=1
    #--- Register UEs ---------------------------------------------------------------------------------------------------------------[150 characters]
    FOR   ${id}    IN RANGE    ${ue_id}    ${ue_id_7}+1    1
        wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${id} pdu=1 trf_type=internal
        wts_ue . UE Register    ue_id=${id}
    END
    #--- Setup PDU with dedicated 5qi6 , GBR 5qi1, GBR 5qi5--------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=smf_param additional_qosflows_to_activate=2,3 id=1
    FOR   ${id}    IN RANGE    ${ue_id}    ${ue_id_7}+1    1
        wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${id} nwslice=1 gw=1
    END
    #---Associate Advance BLER profile to UE5 to  UE7--------------------------------------------------------------------------------[150 characters]
    wts_ue . Associate UEs to testmode    ue_id=${ue_id_5},${ue_id_6},${ue_id_7}
    ...                                   profile_id=1    action=activate    testmode=adv_bler
    #--- Start nonGBR Traffic UEs ---------------------------------------------------------------------------------------------------[150 characters]
    FOR   ${id}    IN RANGE    ${ue_id}    ${ue_id_4}+1    1
        Start Traffic in DL    ue_id=${id}           qfi_id=1    trf_id=2    mbps=100
    END
    #--- Start VoNR Traffic UEs -----------------------------------------------------------------------------------------------------[150 characters]
    FOR   ${id}   IN   ${ue_id_5}  ${ue_id_6}   ${ue_id_7}
        Start Traffic in DL    ue_id=${id}     qfi_id=1    trf_id=2    mbps=4
        Start Traffic in DL    ue_id=${id}     qfi_id=3    trf_id=4    mbps=1
        Start Traffic in UL    ue_id=${id}     qfi_id=3    trf_id=4    mbps=1
    END
    sleep  4s
    #---Stop Traffic on all UEs -----------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=trf_data_stop ue=${ue_id}-${ue_id_7} dir=bi trf_id=2,3,4 pdu=1
    wts_ue . Associate UEs to testmode    ue_id=${ue_id_5},${ue_id_6},${ue_id_7}
    ...                                   profile_id=1    action=deactivate    testmode=adv_bler
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR   ${id}    IN RANGE    ${ue_id}    ${ue_id_7}+1    1
        wts_ue . Associate UEs to testmode    ue_id=${id}
        ...        profile_id=${csio_profile_id}    action=deactivate    testmode=csi_override
        wts_ue . UE Deregister    ue_id=${id}
    END

TC_B17_IWK_PRB_blanking
    ${non_attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=sa    with_auto_attach=${FALSE}
    ${non_attached_ues_list}=  get dictionary keys  ${non_attached_ues_dict}
    ${ue_id}=      set variable    ${non_attached_ues_list}[0]
    ${ue_id_2}=    set variable    ${non_attached_ues_list}[1]
    ${ue_id_3}=    set variable    ${non_attached_ues_list}[2]
    ${ue_id_4}=    set variable    ${non_attached_ues_list}[3]
    ${Mcs}=    set variable    16
    #--- Set CQI to 5 for all UEs ---------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Update UE Channel State Information  profile_id=${csio_profile_id}  cqi=${Cqi}  cqi_mode=oscillating
    ...     cqi_min=6  cqi_max=8  cqi_step=1  cqi_period=3  ri=${Rank}  ri_mode=fixed
    wts_ue . Associate UEs to testmode    ue_id=${ue_id},${ue_id_2},${ue_id_3},${ue_id_4}
    ...                                   profile_id=${csio_profile_id}    action=activate    testmode=csi_override
    #------ New adv_bler testmode----------------------------------------------------------------------------------------------------[150 characters]

    ${cmd}    Catenate     adv_bler_testmode_nr profile_id=1 target_bler_profile_id=1
    ...    target_bler=${target_bler} retx_target_bler1=${retx_target_bler1}  retx_target_bler2=${retx_target_bler2}
    ...    target_mcs=8 rank=1 mcs_table=qam64 p_target_bler_profile_id=1
    ...    target_mcs=7 rank=2 mcs_table=qam64 p_target_bler_profile_id=1
    ...    target_mcs=7 rank=3 mcs_table=qam64 p_target_bler_profile_id=1
    ...    target_mcs=7 rank=4 mcs_table=qam64 p_target_bler_profile_id=1
    wts_ue . Send Egate Command and verify output     cmd=${cmd}
    #-------- To print config in log-------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=adv_bler_testmode_nr profile_id=1
    #--- Register UEs ---------------------------------------------------------------------------------------------------------------[150 characters]
    FOR   ${id}   IN   ${ue_id}  ${ue_id_2}  ${ue_id_3}  ${ue_id_4}
        wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${id} pdu=1 trf_type=internal
        wts_ue . UE Register    ue_id=${id}
    END
    #-------- Setup PDU with dedicated 5qi6 , GBR 5qi1, GBR 5qi5---------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=smf_param additional_qosflows_to_activate=2,3 id=1
    FOR   ${id}   IN   ${ue_id}  ${ue_id_2}  ${ue_id_3}  ${ue_id_4}
        wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${id} nwslice=1 gw=1
    END
    #--- Start Traffic UEs ----------------------------------------------------------------------------------------------------------[150 characters]
    FOR   ${id}   IN   ${ue_id}  ${ue_id_2}  ${ue_id_3}  ${ue_id_4}
        Start Traffic in DL    ue_id=${id}      qfi_id=1    trf_id=2    mbps=1
        Start Traffic in DL    ue_id=${id}      qfi_id=3    trf_id=4    mbps=1
        Start Traffic in UL    ue_id=${id}      qfi_id=3    trf_id=4    mbps=1
    END
    #---Associate Advance BLER profile to UE4----------------------------------------------------------------------------------------[150 characters]
    wts_ue . Associate UEs to testmode    ue_id=${ue_id},${ue_id_2},${ue_id_3},${ue_id_4}
    ...                                   profile_id=1    action=activate    testmode=adv_bler
    sleep  5s
    #---Stop Traffic on all UEs -----------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=trf_data_stop ue=${ue_id}-${ue_id_4} dir=bi trf_id=2,3,4 pdu=1
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR   ${id}   IN   ${ue_id}  ${ue_id_2}  ${ue_id_3}  ${ue_id_4}
        wts_ue . Associate UEs to testmode     ue_id=${id}
        ...                                profile_id=1    action=deactivate    testmode=adv_bler
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR   ${id}   IN   ${ue_id}  ${ue_id_2}  ${ue_id_3}  ${ue_id_4}
        wts_ue . UE Deregister    ue_id=${id}
        wts_ue . Associate UEs to testmode    ue_id=${id}
        ...        profile_id=${csio_profile_id}    action=deactivate    testmode=csi_override
    END

TC_Dc2_FDD_IWK_with_DL_RAT1_and_RAT_DynSwitch_and_PRB_Pooling
    ${non_attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=sa    with_auto_attach=${FALSE}
    ${non_attached_ues_list}=  get dictionary keys  ${non_attached_ues_dict}
    ${ue_id_count}=  Get Length  ${non_attached_ues_list}
    ${ue_id_1}=    set variable    ${non_attached_ues_list}[0]
    ${ue_id_2}=    set variable    ${non_attached_ues_list}[1]
    ${ue_id_3}=    set variable    ${non_attached_ues_list}[2]
    ${ue_id_4}=    set variable    ${non_attached_ues_list}[3]
    ${ue_id_5}=    set variable    ${non_attached_ues_list}[4]
    ${ue_id_6}=    set variable    ${non_attached_ues_list}[5]
    ${ue_id_7}=    set variable    ${non_attached_ues_list}[6]
    ${ue_id_8}=    set variable    ${non_attached_ues_list}[7]
    ${ue_id_9}=    set variable    ${non_attached_ues_list}[8]
    ${ue_id_10}=    set variable    ${non_attached_ues_list}[9]
    ${ue_id_11}=    set variable    ${non_attached_ues_list}[10]
    ${ue_id_12}=    set variable    ${non_attached_ues_list}[11]
    ${ue_id_13}=    set variable    ${non_attached_ues_list}[12]
    ${ue_id_14}=    set variable    ${non_attached_ues_list}[13]
    ${Mcs}=    set variable    16
    #--- Set CQI to 5 for all UEs ---------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Update UE Channel State Information  profile_id=${csio_profile_id}  cqi=${Cqi}  cqi_mode=oscillating
    ...     cqi_min=6  cqi_max=8  cqi_step=1  cqi_period=3  ri=1  ri_mode=fixed
    #--- Set CSI_override on all UEs ------------------------------------------------------------------------------------------------[150 characters]
    FOR   ${id}    IN RANGE    ${ue_id_1}    ${ue_id_14}+1    1
        wts_ue . Associate UEs to testmode
        ...      ue_id=${id}    profile_id=${csio_profile_id}    action=activate    testmode=csi_override
    END
    #------ New adv_bler testmode----------------------------------------------------------------------------------------------------[150 characters]
    ${cmd}    Catenate     adv_bler_testmode_nr profile_id=1 target_bler_profile_id=1
    ...    target_bler=${target_bler} retx_target_bler1=${retx_target_bler1}  retx_target_bler2=${retx_target_bler2}
    ...    target_mcs=8 rank=1 mcs_table=qam64 p_target_bler_profile_id=1
    ...    target_mcs=7 rank=2 mcs_table=qam64 p_target_bler_profile_id=1
    ...    target_mcs=7 rank=3 mcs_table=qam64 p_target_bler_profile_id=1
    ...    target_mcs=7 rank=4 mcs_table=qam64 p_target_bler_profile_id=1
    wts_ue . Send Egate Command and verify output     cmd=${cmd}
    #-------- To print config in log-------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=adv_bler_testmode_nr profile_id=1
    #--- Register UEs ---------------------------------------------------------------------------------------------------------------[150 characters]
    FOR   ${id}    IN RANGE    ${ue_id_1}    ${ue_id_14}+1    1
        wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${id} pdu=1 trf_type=internal
        wts_ue . UE Register    ue_id=${id}
    END
    #--- Setup PDU with dedicated 5qi6 , GBR 5qi1, GBR 5qi5--------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=smf_param additional_qosflows_to_activate=2,3 id=1
    FOR   ${id}    IN RANGE    ${ue_id_1}    ${ue_id_14}+1    1
        wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${id} nwslice=1 gw=1
    END
    #---Associate Advance BLER profile to UE5 to  UE14-------------------------------------------------------------------------------[150 characters]
    FOR   ${id}    IN RANGE    ${ue_id_5}    ${ue_id_9}+1    1
            wts_ue . Associate UEs to testmode    ue_id=${id}
    ...        profile_id=1    action=activate    testmode=adv_bler
    END
    #--- Start nonGBR Traffic UEs ---------------------------------------------------------------------------------------------------[150 characters]
    FOR   ${id}    IN RANGE    ${ue_id_1}    ${ue_id_4}+1    1
        Start Traffic in DL    ue_id=${id}     qfi_id=1    trf_id=2    mbps=120
    END
    #--- Start VoNR Traffic UEs -----------------------------------------------------------------------------------------------------[150 characters]
    FOR   ${id}    IN RANGE    ${ue_id_5}    ${ue_id_14}+1    1
        Start Traffic in DL    ue_id=${id}     qfi_id=1    trf_id=2    mbps=4
        Start Traffic in DL    ue_id=${id}     qfi_id=3    trf_id=4    mbps=1
        Start Traffic in UL    ue_id=${id}     qfi_id=3    trf_id=4    mbps=1
    END
    sleep  4s
    #---Stop Traffic on all UEs -----------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=trf_data_stop ue=${ue_id_1}-${ue_id_14} dir=bi trf_id=2,3,4 pdu=1
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR   ${id}    IN RANGE    ${ue_id_1}    ${ue_id_14}+1    1
        wts_ue . Associate UEs to testmode
        ...      ue_id=${id}    profile_id=${csio_profile_id}    action=deactivate    testmode=csi_override
        wts_ue . UE Deregister    ue_id=${id}
    END


TC_Dc3_TDD_IWK_with_DL_RAT1_and_PRB_Pooling
    ${non_attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=sa    with_auto_attach=${FALSE}
    ${non_attached_ues_list}=  get dictionary keys  ${non_attached_ues_dict}
    ${ue_id}=      set variable    ${non_attached_ues_list}[0]
    ${ue_id_2}=    set variable    ${non_attached_ues_list}[1]
    ${ue_id_3}=    set variable    ${non_attached_ues_list}[2]
    ${ue_id_4}=    set variable    ${non_attached_ues_list}[3]
    ${ue_id_5}=    set variable    ${non_attached_ues_list}[4]
    ${ue_id_6}=    set variable    ${non_attached_ues_list}[5]
    ${ue_id_7}=    set variable    ${non_attached_ues_list}[6]
    ${ue_id_8}=    set variable    ${non_attached_ues_list}[7]
    ${ue_id_9}=    set variable    ${non_attached_ues_list}[8]
    ${Mcs}=    set variable    16
    #--- Set CQI to 5 for all UEs ---------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Update UE Channel State Information  profile_id=${csio_profile_id}  cqi=${Cqi}  cqi_mode=oscillating
    ...     cqi_min=6  cqi_max=8  cqi_step=1  cqi_period=3  ri=1  ri_mode=fixed
    #--- Set CSI_override on all UEs ------------------------------------------------------------------------------------------------[150 characters]
    FOR   ${id}    IN RANGE    ${ue_id}    ${ue_id_9}+1    1
        wts_ue . Associate UEs to testmode
        ...      ue_id=${id}    profile_id=${csio_profile_id}    action=activate    testmode=csi_override
    END
    #------ New adv_bler testmode----------------------------------------------------------------------------------------------------[150 characters]
    ${cmd}    Catenate     adv_bler_testmode_nr profile_id=1 target_bler_profile_id=1
    ...    target_bler=${target_bler} retx_target_bler1=${retx_target_bler1}  retx_target_bler2=${retx_target_bler2}
    ...    target_mcs=8 rank=1 mcs_table=qam64 p_target_bler_profile_id=1
    ...    target_mcs=7 rank=2 mcs_table=qam64 p_target_bler_profile_id=1
    ...    target_mcs=7 rank=3 mcs_table=qam64 p_target_bler_profile_id=1
    ...    target_mcs=7 rank=4 mcs_table=qam64 p_target_bler_profile_id=1
    wts_ue . Send Egate Command and verify output     cmd=${cmd}
    #-------- To print config in log-------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=adv_bler_testmode_nr profile_id=1
    #--- Register UEs ---------------------------------------------------------------------------------------------------------------[150 characters]
    FOR   ${id}    IN RANGE    ${ue_id}    ${ue_id_9}+1    1
        wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${id} pdu=1 trf_type=internal
        wts_ue . UE Register    ue_id=${id}
    END
    #--- Setup PDU with dedicated 5qi6 , GBR 5qi1, GBR 5qi5--------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=smf_param additional_qosflows_to_activate=2,3 id=1
    FOR   ${id}    IN RANGE    ${ue_id}    ${ue_id_9}+1    1
        wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${id} nwslice=1 gw=1
    END
    FOR   ${id}    IN RANGE    ${ue_id}    ${ue_id_5}+1    1
            wts_ue . Associate UEs to testmode    ue_id=${id}
    ...        profile_id=1    action=activate    testmode=adv_bler
    END
    #--- Start nonGBR Traffic UEs ---------------------------------------------------------------------------------------------------[150 characters]
    FOR   ${id}    IN RANGE    ${ue_id_6}    ${ue_id_9}+1    1
        Start Traffic in DL    ue_id=${id}     qfi_id=1    trf_id=2    mbps=15
    END
    #--- Start VoNR Traffic UEs -----------------------------------------------------------------------------------------------------[150 characters]
    FOR   ${id}    IN RANGE    ${ue_id}    ${ue_id_5}+1    1
        Start Traffic in DL    ue_id=${id}     qfi_id=1    trf_id=2    mbps=1
        Start Traffic in DL    ue_id=${id}     qfi_id=3    trf_id=4    mbps=1
        Start Traffic in UL    ue_id=${id}     qfi_id=3    trf_id=4    mbps=1
    END
    sleep  4s
    #---Stop Traffic on all UEs -----------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=trf_data_stop ue=${ue_id}-${ue_id_9} dir=bi trf_id=2,3,4 pdu=1
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR   ${id}    IN RANGE    ${ue_id}    ${ue_id_9}+1    1
        wts_ue . Associate UEs to testmode
        ...      ue_id=${id}    profile_id=${csio_profile_id}    action=activate    testmode=csi_override
        wts_ue . UE Deregister    ue_id=${id}
    END



#--- Helper Keywords ----------------------------------------------------------------------------------------------------------------[150 characters]

Register MUE
    [Arguments]  ${non_attached_ues_list}
    FOR  ${id}  IN  @{non_attached_ues_list}
        wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${id} pdu=1 trf_type=internal
        UE Register    ue_id=${id}
        wts_ue . Send Egate Command and verify output   cmd=smf_param additional_qosflows_to_activate=2,3 id=1
        wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${id} nwslice=1 gw=1
    END


Deregister MUE
    [Arguments]  ${non_attached_ues_list}
    FOR  ${id}  IN  @{non_attached_ues_list}
        UE Deregister     ue_id=${id}
    END


Start Traffic in DL
    [Arguments]  ${ue_id}  ${qfi_id}  ${trf_id}  ${mbps}  ${seconds}=${EMPTY}
    &{kwargs}=    create dictionary    mbps=${mbps}    pdu=1    qfi=${qfi_id}
    IF    '${seconds}' != '${EMPTY}'   Set To Dictionary    ${kwargs}    seconds    ${seconds}
    wts_ue . Start data traffic in egate    ue_id=${ue_id}
    ...                                     direction=dl
    ...                                     protocol=udp
    ...                                     ack_mode=off
    ...                                     trf_id=${trf_id}
    ...                                     cl_trf_stats=on
    ...                                     &{kwargs}


Start Traffic in UL
    [Arguments]  ${ue_id}  ${qfi_id}  ${trf_id}  ${mbps}  ${seconds}=${EMPTY}
    &{kwargs}=    create dictionary    mbps=${mbps}    pdu=1    qfi=${qfi_id}
    IF    '${seconds}' != '${EMPTY}'   Set To Dictionary    ${kwargs}    seconds    ${seconds}
    wts_ue . Start data traffic in egate    ue_id=${ue_id}
    ...                                     direction=ul
    ...                                     protocol=udp
    ...                                     ack_mode=off
    ...                                     trf_id=${trf_id}
    ...                                     cl_trf_stats=on
    ...                                     &{kwargs}


Stop traffic and release PDU bearer
    [Arguments]  ${ue_id}   ${trf_id}    ${qosflows}
    wts_ue . Stop data traffic in egate    ue_id=${ue_id}    direction=bi    trf_id=${trf_id}
    sleep   1s
    wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=${qosflows} by=amf


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

