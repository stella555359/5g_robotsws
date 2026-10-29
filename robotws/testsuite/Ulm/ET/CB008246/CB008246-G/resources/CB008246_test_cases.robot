*** Settings ***
Documentation    Specific Test Cases for subfeature CB008246-G of "LA for HR DRBs"
Resource   ../../../../resources/Common/coam_ulm.robot
Resource   ../../../../resources/Common/connect.robot

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]



*** Variables ***


${Cqi}                   7
${Rank}                  3
${Mcs}                   16
${bler_profile_id}       30
${bler_profile_id_2}     32
${csio_profile_id}       31
${target_bler}           100,95,90,50,30,10,5,1,0,0,0,0,0,0,0
${dtx_profile_id}        35



*** Keywords ***

TC01_HrDrbPdsch_SA_multiDRB_nonGBR_MultiUE
    ${non_attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=sa    with_auto_attach=${FALSE}
    ${non_attached_ues_list}=  get dictionary keys  ${non_attached_ues_dict}
    ${ue_id}=    set variable    ${non_attached_ues_list}[0]
    ${ue_id_2}=    set variable    ${non_attached_ues_list}[1]
    #--- Register UE1 ---------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    wts_ue . UE Register    ue_id=${ue_id}
    wts_ue . Send Egate Command and verify output   cmd=smf_param additional_qosflows_to_activate=7,8 id=1
    wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1
    sleep  3s
    #--- Start Traffic UE1 ----------------------------------------------------------------------------------------------------------[150 characters]
    Start Traffic in DL    ue_id=${ue_id}    qfi_id=1    trf_id=2    mbps=10
    Start Traffic in DL    ue_id=${ue_id}    qfi_id=2    trf_id=3    mbps=10
    Start Traffic in DL    ue_id=${ue_id}    qfi_id=3    trf_id=4    mbps=10
    sleep  3s
    #--- Register UE2 ---------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${ue_id_2} pdu=1 trf_type=internal
    wts_ue . UE Register    ue_id=${ue_id_2}
    wts_ue . Send Egate Command and verify output   cmd=smf_param additional_qosflows_to_activate=7,8 id=1
    wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id_2} nwslice=1 gw=1
    sleep  3s
    #--- Start Traffic UE2 ----------------------------------------------------------------------------------------------------------[150 characters]
    Start Traffic in DL    ue_id=${ue_id_2}    qfi_id=1    trf_id=2    mbps=10
    Start Traffic in DL    ue_id=${ue_id_2}    qfi_id=2    trf_id=3    mbps=10
    Start Traffic in DL    ue_id=${ue_id_2}    qfi_id=3    trf_id=4    mbps=10
    sleep  3s
    #--- Stop Traffic UE1 &nd Release PDU bearer  -----------------------------------------------------------------------------------[150 characters]
    Stop traffic and release PDU bearer    ue_id=${ue_id}    trf_id=2    qosflows=1
    sleep  3s
    #--- Deregister UEs -------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . UE Deregister    ue_id=${ue_id}
    wts_ue . UE Deregister    ue_id=${ue_id_2}


TC02_HrDrbPdsch_SA_multiDRB_nonGBR_FDD
    ${non_attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=sa    with_auto_attach=${FALSE}
    ${non_attached_ues_list}=  get dictionary keys  ${non_attached_ues_dict}
    ${ue_id}=    set variable    ${non_attached_ues_list}[0]
    #--- Register UE1 ---------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    wts_ue . UE Register    ue_id=${ue_id}
    wts_ue . Send Egate Command and verify output   cmd=smf_param additional_qosflows_to_activate=7,8 id=1
    wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1
    sleep  3s
    #--- Start Traffic UE1 ----------------------------------------------------------------------------------------------------------[150 characters]
    Start Traffic in DL    ue_id=${ue_id}    qfi_id=1    trf_id=2    mbps=10
    Start Traffic in DL    ue_id=${ue_id}    qfi_id=2    trf_id=3    mbps=10
    Start Traffic in DL    ue_id=${ue_id}    qfi_id=3    trf_id=4    mbps=10
    sleep  3s
    #--- Stop Traffic UE1 &nd Release PDU bearer  -----------------------------------------------------------------------------------[150 characters]
    Stop traffic and release PDU bearer    ue_id=${ue_id}    trf_id=2    qosflows=1
    sleep  3s
    #--- Deregister UEs -------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . UE Deregister    ue_id=${ue_id}


TC03_HrDrbPdsch_SA_multiDRB_nonGBR_OnlineModify_multiUE
    ${non_attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=sa    with_auto_attach=${FALSE}
    ${non_attached_ues_list}=  get dictionary keys  ${non_attached_ues_dict}
    ${ue_id}=    set variable    ${non_attached_ues_list}[0]
    ${ue_id_2}=    set variable    ${non_attached_ues_list}[1]
    connect.Setup OAM HTTP Session
    #--- Register UE1 ---------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    wts_ue . UE Register    ue_id=${ue_id}
    wts_ue . Send Egate Command and verify output   cmd=smf_param additional_qosflows_to_activate=7,8 id=1
    wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1
    sleep  1s
    #--- Start Traffic UE1 ----------------------------------------------------------------------------------------------------------[150 characters]
    Start Traffic in DL    ue_id=${ue_id}    qfi_id=1    trf_id=2    mbps=1
    Start Traffic in DL    ue_id=${ue_id}    qfi_id=2    trf_id=3    mbps=1
    Start Traffic in DL    ue_id=${ue_id}    qfi_id=3    trf_id=4    mbps=1
    sleep  1s
    ${distName_NRCELL}=   Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    coam_ulm.Update SCF parameter   value=10    parameter=dllaMcsMax64qamLowSERANK4HR     dist_name=${distName_NRCELL[0]}
    ...                            list_name=pdschHrLaConfig
    #--- Register UE2 ---------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${ue_id_2} pdu=1 trf_type=internal
    wts_ue . UE Register    ue_id=${ue_id_2}
    wts_ue . Send Egate Command and verify output   cmd=smf_param additional_qosflows_to_activate=7,8 id=1
    wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id_2} nwslice=1 gw=1
    sleep  1s
    #--- Start Traffic UE2 ----------------------------------------------------------------------------------------------------------[150 characters]
    Start Traffic in DL    ue_id=${ue_id_2}    qfi_id=1    trf_id=2    mbps=1
    Start Traffic in DL    ue_id=${ue_id_2}    qfi_id=2    trf_id=3    mbps=1
    Start Traffic in DL    ue_id=${ue_id_2}    qfi_id=3    trf_id=4    mbps=1
    sleep  1s
    ${distName_NRCELL}=   Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    coam_ulm.Update SCF parameter   value=20    parameter=dllaMcsMax64qamLowSERANK4HR     dist_name=${distName_NRCELL[0]}
    ...                            list_name=pdschHrLaConfig
    #--- Deregister UEs -------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . UE Deregister    ue_id=${ue_id}
    wts_ue . UE Deregister    ue_id=${ue_id_2}


TC04_HrDrbPdsch_SA_multiDRB_nonGBR_Conditional_OLLA_Instance1
    ${non_attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=sa    with_auto_attach=${FALSE}
    ${non_attached_ues_list}=  get dictionary keys  ${non_attached_ues_dict}
    ${ue_id}=      set variable    ${non_attached_ues_list}[0]
    ${ue_id_2}=    set variable    ${non_attached_ues_list}[1]
    ${ue_id_3}=    set variable    ${non_attached_ues_list}[4]
    ${ue_id_4}=    set variable    ${non_attached_ues_list}[5]
    ${Mcs}=    set variable    27
    #--- Set CQI to 5 for all UEs ---------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Update UE Channel State Information  profile_id=${csio_profile_id}  cqi=${Cqi}  cqi_mode=fixed  ri=${Rank}  ri_mode=fixed
    sleep  0.5s
    wts_ue . Associate UEs to testmode    ue_id=${ue_id},${ue_id_2},${ue_id_3},${ue_id_4}
    ...                                   profile_id=${csio_profile_id}    action=activate    testmode=csi_override
    sleep  0.5s
    wts_ue . Configure NR BLER testmode  profile_id=${bler_profile_id}    target_mcs=${Mcs}  target_bler=${target_bler}  mcs_table=qam64LowSE
    wts_ue . Configure NR BLER testmode  profile_id=${bler_profile_id_2}  target_mcs=${Mcs}  target_bler=${target_bler}  mcs_table=qam64
    sleep  0.5s
    wts_ue . Associate UEs to testmode    ue_id=${ue_id},${ue_id_2}      profile_id=${bler_profile_id}      action=activate    testmode=bler
    wts_ue . Associate UEs to testmode    ue_id=${ue_id_3},${ue_id_4}    profile_id=${bler_profile_id_2}    action=activate    testmode=bler
    sleep  0.5s
    wts_ue . Send Egate Command and verify output   cmd=forced_dtx_testmode_nr profile_id=${dtx_profile_id} force_dtx_pucch=50:1000
    wts_ue . Send Egate Command and verify output
    ...      cmd=ue_testmode_set_nr id=${ue_id},${ue_id_3} testmode=forced_dtx profile_id=${dtx_profile_id} action=activate
    sleep  0.5s
    #--- Register UEs ---------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    wts_ue . UE Register    ue_id=${ue_id}
    wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${ue_id_2} pdu=1 trf_type=internal
    wts_ue . UE Register    ue_id=${ue_id_2}
    wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${ue_id_3} pdu=1 trf_type=internal
    wts_ue . UE Register    ue_id=${ue_id_3}
    wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${ue_id_4} pdu=1 trf_type=internal
    wts_ue . UE Register    ue_id=${ue_id_4}
    sleep  1s
    #--- Setup PDU with dedicated QCI6 , nonGBR QCI7, GBR QCI2-----------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=smf_param additional_qosflows_to_activate=7,4 id=1
    wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1
    wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id_2} nwslice=1 gw=1
    wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id_3} nwslice=1 gw=1
    wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id_4} nwslice=1 gw=1
    sleep  1s
    #--- Start Traffic UEs ----------------------------------------------------------------------------------------------------------[150 characters]
    Start Traffic in DL    ue_id=${ue_id}      qfi_id=1    trf_id=2    mbps=15
    Start Traffic in DL    ue_id=${ue_id_2}    qfi_id=1    trf_id=2    mbps=15
    Start Traffic in DL    ue_id=${ue_id_3}    qfi_id=1    trf_id=2    mbps=15
    Start Traffic in DL    ue_id=${ue_id_4}    qfi_id=1    trf_id=2    mbps=15
    Start Traffic in DL    ue_id=${ue_id}      qfi_id=2    trf_id=3    mbps=10
    Start Traffic in DL    ue_id=${ue_id_2}    qfi_id=2    trf_id=3    mbps=10
    Start Traffic in DL    ue_id=${ue_id_3}    qfi_id=2    trf_id=3    mbps=10
    Start Traffic in DL    ue_id=${ue_id_4}    qfi_id=2    trf_id=3    mbps=10
    Start Traffic in DL    ue_id=${ue_id}      qfi_id=3    trf_id=4    mbps=1
    Start Traffic in DL    ue_id=${ue_id_2}    qfi_id=3    trf_id=4    mbps=1
    Start Traffic in DL    ue_id=${ue_id_3}    qfi_id=3    trf_id=4    mbps=1
    Start Traffic in DL    ue_id=${ue_id_4}    qfi_id=3    trf_id=4    mbps=1
    sleep  1s
    #--- changing CQI and Rank for UE1 ----------------------------------------------------------------------------------------------[150 characters]
    FOR    ${Cqi}    IN RANGE    2    16    1
        ${Rank}=    set variable if    ${Cqi} < 7    1
        ...                            ${Cqi} < 8    2
        ...                                          3
        Send Egate Command and verify output    cmd=csi_override_testmode_nr profile_id=${csio_profile_id} cqi=${Cqi} ri=${Rank} ri_mode=fixed
        Send Egate Command and verify output    cmd=csi_override_testmode_nr profile_id=${csio_profile_id}
        ...                                     pass_regexp=csi_override_testmode_nr Parameters
        sleep    0.7s
    END
    ${Rank}=   set variable   3
    ${Cqi}=    set variable   14
    Send Egate Command and verify output    cmd=csi_override_testmode_nr profile_id=${csio_profile_id} cqi=${Cqi} ri=${Rank} ri_mode=fixed
    Send Egate Command and verify output    cmd=csi_override_testmode_nr profile_id=${csio_profile_id}
    ...                                     pass_regexp=csi_override_testmode_nr Parameters
    sleep   3s
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Stop traffic and release PDU bearer    ue_id=${ue_id}      trf_id=5,2,3,4    qosflows=1
    Stop traffic and release PDU bearer    ue_id=${ue_id_2}    trf_id=5,2,3,4    qosflows=1
    Stop traffic and release PDU bearer    ue_id=${ue_id_3}    trf_id=5,2,3,4    qosflows=1
    Stop traffic and release PDU bearer    ue_id=${ue_id_4}    trf_id=5,2,3,4    qosflows=1
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . UE Deregister    ue_id=${ue_id}
    wts_ue . UE Deregister    ue_id=${ue_id_2}
    wts_ue . UE Deregister    ue_id=${ue_id_3}
    wts_ue . UE Deregister    ue_id=${ue_id_4}
    wts_ue . Associate UEs to testmode    ue_id=${ue_id},${ue_id_2},${ue_id_3},${ue_id_4}
    ...                                   profile_id=${csio_profile_id}    action=deactivate    testmode=csi_override
    wts_ue . Associate UEs to testmode    ue_id=${ue_id},${ue_id_2}      profile_id=${bler_profile_id}      action=deactivate    testmode=bler
    wts_ue . Associate UEs to testmode    ue_id=${ue_id_3},${ue_id_4}    profile_id=${bler_profile_id_2}    action=deactivate    testmode=bler


TC04_HrDrbPdsch_SA_multiDRB_nonGBR_Conditional_OLLA_Instance2
    ${non_attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=sa    with_auto_attach=${FALSE}
    ${non_attached_ues_list}=  get dictionary keys  ${non_attached_ues_dict}
    ${ue_id}=    set variable    ${non_attached_ues_list}[0]
    ${ue_id_1}=    set variable    ${non_attached_ues_list}[1]
    ${ue_id_2}=    set variable    ${non_attached_ues_list}[4]
    ${ue_id_3}=    set variable    ${non_attached_ues_list}[5]
    ${Mcs}=    set variable    16
    #--- Set CQI to 5 for all UEs ---------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Update UE Channel State Information  profile_id=${csio_profile_id}  cqi=${Cqi}  cqi_mode=fixed  ri=${Rank}  ri_mode=fixed
    sleep  0.5s
    wts_ue . Associate UEs to testmode    ue_id=${ue_id},${ue_id_1},${ue_id_2},${ue_id_3}
	...                                   profile_id=${csio_profile_id}    action=activate    testmode=csi_override
    sleep  0.5s
    wts_ue . Configure NR BLER testmode  profile_id=${bler_profile_id}  target_mcs=${Mcs}  target_bler=${target_bler}  mcs_table=qam64LowSE
    wts_ue . Configure NR BLER testmode  profile_id=${bler_profile_id_2}  target_mcs=${Mcs}  target_bler=${target_bler}  mcs_table=qam64
    sleep  0.5s
    wts_ue . Associate UEs to testmode    ue_id=${ue_id},${ue_id_1}    profile_id=${bler_profile_id}    action=activate    testmode=bler
    wts_ue . Associate UEs to testmode    ue_id=${ue_id_2},${ue_id_3}    profile_id=${bler_profile_id_2}    action=activate    testmode=bler
    sleep  0.5s
    wts_ue . Send Egate Command and verify output   cmd=forced_dtx_testmode_nr profile_id=${dtx_profile_id} force_dtx_pucch=50:1000
    wts_ue . Send Egate Command and verify output
    ...      cmd=ue_testmode_set_nr id=${ue_id},${ue_id_2} testmode=forced_dtx profile_id=${dtx_profile_id} action=activate
    sleep  0.5s
    #--- Register UEs ---------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    wts_ue . UE Register    ue_id=${ue_id}
    wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${ue_id_1} pdu=1 trf_type=internal
    wts_ue . UE Register    ue_id=${ue_id_1}
    wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${ue_id_2} pdu=1 trf_type=internal
    wts_ue . UE Register    ue_id=${ue_id_2}
    wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${ue_id_3} pdu=1 trf_type=internal
    wts_ue . UE Register    ue_id=${ue_id_3}
    sleep  1s
    #--- Setup PDU with dedicated QCI6 , nonGBR QCI7, GBR QCI2-----------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=smf_param additional_qosflows_to_activate=7,4 id=1
    wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1
    wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id_1} nwslice=1 gw=1
    wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id_2} nwslice=1 gw=1
    wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id_3} nwslice=1 gw=1
    sleep  1s
    #--- Start Traffic UEs ----------------------------------------------------------------------------------------------------------[150 characters]
    Start Traffic in DL    ue_id=${ue_id}      qfi_id=1    trf_id=2    mbps=15
    Start Traffic in DL    ue_id=${ue_id_1}    qfi_id=1    trf_id=2    mbps=15
    Start Traffic in DL    ue_id=${ue_id_2}    qfi_id=1    trf_id=2    mbps=15
    Start Traffic in DL    ue_id=${ue_id_3}    qfi_id=1    trf_id=2    mbps=15
    Start Traffic in DL    ue_id=${ue_id}      qfi_id=2    trf_id=3    mbps=10
    Start Traffic in DL    ue_id=${ue_id_1}    qfi_id=2    trf_id=3    mbps=10
    Start Traffic in DL    ue_id=${ue_id_2}    qfi_id=2    trf_id=3    mbps=10
    Start Traffic in DL    ue_id=${ue_id_3}    qfi_id=2    trf_id=3    mbps=10
    Start Traffic in DL    ue_id=${ue_id}      qfi_id=3    trf_id=4    mbps=1
    Start Traffic in DL    ue_id=${ue_id_1}    qfi_id=3    trf_id=4    mbps=1
    Start Traffic in DL    ue_id=${ue_id_2}    qfi_id=3    trf_id=4    mbps=1
    Start Traffic in DL    ue_id=${ue_id_3}    qfi_id=3    trf_id=4    mbps=1
    sleep  1s
    #--- changing CQI and Rank for UE1 ----------------------------------------------------------------------------------------------[150 characters]
    FOR    ${Cqi}    IN RANGE    2    9    1
        ${Rank}=    set variable if    ${Cqi} < 7    1
        ...                            ${Cqi} < 8    2
        ...                                          3
        Send Egate Command and verify output    cmd=csi_override_testmode_nr profile_id=${csio_profile_id} cqi=${Cqi} ri=${Rank} ri_mode=fixed
        Send Egate Command and verify output    cmd=csi_override_testmode_nr profile_id=${csio_profile_id}
        ...                                     pass_regexp=csi_override_testmode_nr Parameters
        sleep    0.7s
    END
    ${Rank}=   set variable   3
    ${Cqi}=    set variable   8
    ${command1}=    set variable   csi_override_testmode_nr profile_id=${csio_profile_id} cqi_mode=oscillating
    ${command1}=    set variable   cqi_min=7 cqi_max=10 cqi_step=1 cqi_period=3 ri=${Rank} ri_mode=fixed
    Send Egate Command and verify output    cmd=${command1} ${command2}
    Send Egate Command and verify output    cmd=csi_override_testmode_nr profile_id=${csio_profile_id}
    ...                                     pass_regexp=csi_override_testmode_nr Parameters
    sleep   2s
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Stop traffic and release PDU bearer    ue_id=${ue_id}      trf_id=5,2,3,4    qosflows=1
    Stop traffic and release PDU bearer    ue_id=${ue_id_1}    trf_id=5,2,3,4    qosflows=1
    Stop traffic and release PDU bearer    ue_id=${ue_id_2}    trf_id=5,2,3,4    qosflows=1
    Stop traffic and release PDU bearer    ue_id=${ue_id_3}    trf_id=5,2,3,4    qosflows=1
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . UE Deregister    ue_id=${ue_id}
    wts_ue . UE Deregister    ue_id=${ue_id_1}
    wts_ue . UE Deregister    ue_id=${ue_id_2}
    wts_ue . UE Deregister    ue_id=${ue_id_3}
    wts_ue . Associate UEs to testmode    ue_id=${ue_id},${ue_id_1},${ue_id_2},${ue_id_3}
	...                                   profile_id=${csio_profile_id}    action=deactivate    testmode=csi_override
    wts_ue . Associate UEs to testmode    ue_id=${ue_id},${ue_id_1}      profile_id=${bler_profile_id}      action=deactivate    testmode=bler
    wts_ue . Associate UEs to testmode    ue_id=${ue_id_2},${ue_id_3}    profile_id=${bler_profile_id_2}    action=deactivate    testmode=bler


TC04_HrDrbPdsch_SA_multiDRB_nonGBR_Conditional_OLLA_Instance3
    ${non_attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=sa    with_auto_attach=${FALSE}
    ${non_attached_ues_list}=  get dictionary keys  ${non_attached_ues_dict}
    ${ue_id}=      set variable    ${non_attached_ues_list}[0]
    ${ue_id_1}=    set variable    ${non_attached_ues_list}[1]
    ${ue_id_2}=    set variable    ${non_attached_ues_list}[4]
    ${ue_id_3}=    set variable    ${non_attached_ues_list}[5]
    ${Mcs}=    set variable    25
    #--- Set CQI to 5 for all UEs ---------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Update UE Channel State Information  profile_id=${csio_profile_id}  cqi=${Cqi}  cqi_mode=fixed  ri=${Rank}  ri_mode=fixed
    sleep  0.5s
    wts_ue . Associate UEs to testmode    ue_id=${ue_id},${ue_id_1},${ue_id_2},${ue_id_3}
	...                                   profile_id=${csio_profile_id}    action=activate    testmode=csi_override
    sleep  0.5s
    wts_ue . Configure NR BLER testmode  profile_id=${bler_profile_id}  target_mcs=${Mcs}  target_bler=${target_bler}  mcs_table=qam64LowSE
    wts_ue . Configure NR BLER testmode  profile_id=${bler_profile_id_2}  target_mcs=${Mcs}  target_bler=${target_bler}  mcs_table=qam64
    sleep  0.5s
    wts_ue . Associate UEs to testmode    ue_id=${ue_id},${ue_id_1}    profile_id=${bler_profile_id}    action=activate    testmode=bler
    wts_ue . Associate UEs to testmode    ue_id=${ue_id_2},${ue_id_3}    profile_id=${bler_profile_id_2}    action=activate    testmode=bler
    sleep  0.5s
    wts_ue . Send Egate Command and verify output   cmd=forced_dtx_testmode_nr profile_id=${dtx_profile_id} force_dtx_pucch=90:1000
    wts_ue . Send Egate Command and verify output
    ...      cmd=ue_testmode_set_nr id=${ue_id},${ue_id_1},${ue_id_2},${ue_id_3} testmode=forced_dtx profile_id=${dtx_profile_id} action=activate
    sleep  0.5s
    #--- Register UEs ---------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    wts_ue . UE Register    ue_id=${ue_id}
    wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${ue_id_1} pdu=1 trf_type=internal
    wts_ue . UE Register    ue_id=${ue_id_1}
    wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${ue_id_2} pdu=1 trf_type=internal
    wts_ue . UE Register    ue_id=${ue_id_2}
    wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${ue_id_3} pdu=1 trf_type=internal
    wts_ue . UE Register    ue_id=${ue_id_3}
    sleep  1s
    #--- Setup PDU with dedicated QCI6 , nonGBR QCI7, GBR QCI2-----------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=smf_param additional_qosflows_to_activate=7,4 id=1
    wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1
    wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id_1} nwslice=1 gw=1
    wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id_2} nwslice=1 gw=1
    wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id_3} nwslice=1 gw=1
    sleep  1s
    #--- Start Traffic UEs ----------------------------------------------------------------------------------------------------------[150 characters]
    Start Traffic in DL    ue_id=${ue_id}      qfi_id=1    trf_id=2    mbps=15
    Start Traffic in DL    ue_id=${ue_id_1}    qfi_id=1    trf_id=2    mbps=15
    Start Traffic in DL    ue_id=${ue_id_2}    qfi_id=1    trf_id=2    mbps=15
    Start Traffic in DL    ue_id=${ue_id_3}    qfi_id=1    trf_id=2    mbps=15
    Start Traffic in DL    ue_id=${ue_id}      qfi_id=2    trf_id=3    mbps=10
    Start Traffic in DL    ue_id=${ue_id_1}    qfi_id=2    trf_id=3    mbps=10
    Start Traffic in DL    ue_id=${ue_id_2}    qfi_id=2    trf_id=3    mbps=10
    Start Traffic in DL    ue_id=${ue_id_3}    qfi_id=2    trf_id=3    mbps=10
    Start Traffic in DL    ue_id=${ue_id}      qfi_id=3    trf_id=4    mbps=1
    Start Traffic in DL    ue_id=${ue_id_1}    qfi_id=3    trf_id=4    mbps=1
    Start Traffic in DL    ue_id=${ue_id_2}    qfi_id=3    trf_id=4    mbps=1
    Start Traffic in DL    ue_id=${ue_id_3}    qfi_id=3    trf_id=4    mbps=1
    sleep  1s
    #--- changing CQI and Rank for UE1 ----------------------------------------------------------------------------------------------[150 characters]
    FOR    ${Cqi}    IN RANGE    2    14    1
        ${Rank}=    set variable if    ${Cqi} < 7    1
        ...                            ${Cqi} < 8    2
        ...                                          3
        Send Egate Command and verify output    cmd=csi_override_testmode_nr profile_id=${csio_profile_id} cqi=${Cqi} ri=${Rank} ri_mode=fixed
        Send Egate Command and verify output    cmd=csi_override_testmode_nr profile_id=${csio_profile_id}
        ...                                     pass_regexp=csi_override_testmode_nr Parameters
        sleep    0.7s
    END
    ${Rank}=   set variable   3
    ${Cqi}=    set variable   13
    Send Egate Command and verify output    cmd=csi_override_testmode_nr profile_id=${csio_profile_id} cqi=${Cqi} ri=${Rank} ri_mode=fixed
    Send Egate Command and verify output    cmd=csi_override_testmode_nr profile_id=${csio_profile_id}
    ...                                     pass_regexp=csi_override_testmode_nr Parameters
    sleep   3s
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Stop traffic and release PDU bearer    ue_id=${ue_id}      trf_id=5,2,3,4    qosflows=1
    Stop traffic and release PDU bearer    ue_id=${ue_id_1}    trf_id=5,2,3,4    qosflows=1
    Stop traffic and release PDU bearer    ue_id=${ue_id_2}    trf_id=5,2,3,4    qosflows=1
    Stop traffic and release PDU bearer    ue_id=${ue_id_3}    trf_id=5,2,3,4    qosflows=1
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . UE Deregister    ue_id=${ue_id}
    wts_ue . UE Deregister    ue_id=${ue_id_1}
    wts_ue . UE Deregister    ue_id=${ue_id_2}
    wts_ue . UE Deregister    ue_id=${ue_id_3}
    wts_ue . Associate UEs to testmode    ue_id=${ue_id},${ue_id_1},${ue_id_2},${ue_id_3}
	...                                   profile_id=${csio_profile_id}    action=deactivate    testmode=csi_override
    wts_ue . Associate UEs to testmode    ue_id=${ue_id},${ue_id_1}      profile_id=${bler_profile_id}      action=deactivate    testmode=bler
    wts_ue . Associate UEs to testmode    ue_id=${ue_id_2},${ue_id_3}    profile_id=${bler_profile_id_2}    action=deactivate    testmode=bler


TC04_HrDrbPdsch_SA_multiDRB_nonGBR_Conditional_OLLA_Instance4
    ${non_attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=sa    with_auto_attach=${FALSE}
    ${non_attached_ues_list}=  get dictionary keys  ${non_attached_ues_dict}
    ${ue_id}=      set variable    ${non_attached_ues_list}[0]
    ${ue_id_2}=    set variable    ${non_attached_ues_list}[4]
    #--- Set CQI to 5 for all UEs ---------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Update UE Channel State Information  profile_id=${csio_profile_id}  cqi=${Cqi}  cqi_mode=fixed  ri=${Rank}  ri_mode=fixed
    wts_ue . Associate UEs to testmode    ue_id=${ue_id}      profile_id=${csio_profile_id}    action=activate    testmode=csi_override
    wts_ue . Associate UEs to testmode    ue_id=${ue_id_2}    profile_id=${csio_profile_id}    action=activate    testmode=csi_override
    wts_ue . Configure NR BLER testmode  profile_id=${bler_profile_id}    target_mcs=${Mcs}  target_bler=${target_bler}  mcs_table=qam64LowSE
    wts_ue . Configure NR BLER testmode  profile_id=${bler_profile_id_2}  target_mcs=${Mcs}  target_bler=${target_bler}  mcs_table=qam64
    sleep  3s
    #--- Register UE1 ---------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    wts_ue . UE Register    ue_id=${ue_id}
    wts_ue . Send Egate Command and verify output   cmd=smf_param additional_qosflows_to_activate=7,8 id=1
    wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1
    sleep  3s
    #--- Start Traffic UE1 ----------------------------------------------------------------------------------------------------------[150 characters]
    Start Traffic in DL    ue_id=${ue_id}    qfi_id=1    trf_id=2    mbps=10
    Start Traffic in DL    ue_id=${ue_id}    qfi_id=2    trf_id=3    mbps=10
    Start Traffic in DL    ue_id=${ue_id}    qfi_id=3    trf_id=4    mbps=10
    wts_ue . Associate UEs to testmode    ue_id=${ue_id}    profile_id=${bler_profile_id}    action=activate    testmode=bler
    sleep  3s
    #--- changing CQI and Rank for UE1 ----------------------------------------------------------------------------------------------[150 characters]
    FOR    ${Cqi}    IN RANGE    2    16    1
        ${Rank}=    set variable if    ${Cqi} < 4    0
        ...                            ${Cqi} < 6    1
        ...                            ${Cqi} < 8    2
        ...                                          3
        Send Egate Command and verify output    cmd=csi_override_testmode_nr profile_id=${csio_profile_id} cqi=${Cqi} ri=${Rank} ri_mode=fixed
        Send Egate Command and verify output    cmd=csi_override_testmode_nr profile_id=${csio_profile_id}
        ...                                     pass_regexp=csi_override_testmode_nr Parameters
        sleep    0.7s
    END
    #--- Register UE2 ---------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${ue_id_2} pdu=1 trf_type=internal
    wts_ue . UE Register    ue_id=${ue_id_2}
    wts_ue . Send Egate Command and verify output   cmd=smf_param additional_qosflows_to_activate=7,8 id=1
    wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id_2} nwslice=1 gw=1
    sleep  3s
    #--- Start Traffic UE2 ----------------------------------------------------------------------------------------------------------[150 characters]
    Start Traffic in DL    ue_id=${ue_id_2}    qfi_id=1    trf_id=2    mbps=10
    Start Traffic in DL    ue_id=${ue_id_2}    qfi_id=2    trf_id=3    mbps=10
    Start Traffic in DL    ue_id=${ue_id_2}    qfi_id=3    trf_id=4    mbps=10
    wts_ue . Associate UEs to testmode    ue_id=${ue_id_2}    profile_id=${bler_profile_id_2}    action=activate    testmode=bler
    sleep  3s
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Stop traffic and release PDU bearer    ue_id=${ue_id}    trf_id=2    qosflows=1
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . UE Deregister    ue_id=${ue_id}
    wts_ue . UE Deregister    ue_id=${ue_id_2}
    wts_ue . Associate UEs to testmode    ue_id=${ue_id}      profile_id=${csio_profile_id}      action=deactivate    testmode=csi_override
    wts_ue . Associate UEs to testmode    ue_id=${ue_id_2}    profile_id=${csio_profile_id}      action=deactivate    testmode=csi_override
    wts_ue . Associate UEs to testmode    ue_id=${ue_id}      profile_id=${bler_profile_id}      action=deactivate    testmode=bler
    wts_ue . Associate UEs to testmode    ue_id=${ue_id_2}    profile_id=${bler_profile_id_2}    action=deactivate    testmode=bler


TC07_HrDrbPdsch_SA_multiDRB_noLowSeUe_nonGBR_FDD
    ${non_attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=sa    with_auto_attach=${FALSE}
    ${non_attached_ues_list}=  get dictionary keys  ${non_attached_ues_dict}
    ${ue_id}=    set variable    ${non_attached_ues_list}[4]
    #--- Register UE1 ---------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    wts_ue . UE Register    ue_id=${ue_id}
    wts_ue . Send Egate Command and verify output   cmd=smf_param additional_qosflows_to_activate=7,8 id=1
    wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1
    sleep  3s
    #--- Start Traffic UE1 ----------------------------------------------------------------------------------------------------------[150 characters]
    Start Traffic in DL    ue_id=${ue_id}    qfi_id=1    trf_id=2    mbps=20    seconds=2
    Start Traffic in DL    ue_id=${ue_id}    qfi_id=2    trf_id=3    mbps=20    seconds=2
    Start Traffic in DL    ue_id=${ue_id}    qfi_id=3    trf_id=4    mbps=20    seconds=2
    sleep  3s
    #--- Stop Traffic UE1 &nd Release PDU bearer  -----------------------------------------------------------------------------------[150 characters]
    Stop traffic and release PDU bearer    ue_id=${ue_id}    trf_id=2    qosflows=1
    Start Traffic in DL    ue_id=${ue_id}    qfi_id=2    trf_id=3    mbps=20    seconds=2
    Start Traffic in DL    ue_id=${ue_id}    qfi_id=3    trf_id=4    mbps=20    seconds=2
    sleep  3s
    #--- Deregister UEs -------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . UE Deregister    ue_id=${ue_id}


TC08_HrDrbPdsch_SA_multiDRB_noLowSeUe_nonGBR_OnlineModify_NRCELL_multiUE
    ${non_attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=sa    with_auto_attach=${FALSE}
    ${non_attached_ues_list}=  get dictionary keys  ${non_attached_ues_dict}
    ${ue_id}=      set variable    ${non_attached_ues_list}[4]
    ${ue_id_2}=    set variable    ${non_attached_ues_list}[5]
    connect.Setup OAM HTTP Session
    #--- Register UE1 ---------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    wts_ue . UE Register    ue_id=${ue_id}
    wts_ue . Send Egate Command and verify output   cmd=smf_param additional_qosflows_to_activate=7,8 id=1
    wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1
    sleep  3s
    #--- Start Traffic UE1 ----------------------------------------------------------------------------------------------------------[150 characters]
    Start Traffic in DL    ue_id=${ue_id}    qfi_id=1    trf_id=2    mbps=20
    Start Traffic in DL    ue_id=${ue_id}    qfi_id=2    trf_id=3    mbps=20
    Start Traffic in DL    ue_id=${ue_id}    qfi_id=3    trf_id=4    mbps=20
    pmcounters.Wait until the next Measurement Period starts
    ${distName_NRCELL}=   Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    coam_ulm.Update SCF parameter   value=10    parameter=dllaMcsMax64qamRANK4HR     dist_name=${distName_NRCELL[0]}    list_name=pdschHrLaConfig
    #--- Register UE2 ---------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${ue_id_2} pdu=1 trf_type=internal
    wts_ue . UE Register    ue_id=${ue_id_2}
    wts_ue . Send Egate Command and verify output   cmd=smf_param additional_qosflows_to_activate=7,8 id=1
    wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id_2} nwslice=1 gw=1
    sleep  3s
    #--- Start Traffic UE2 ----------------------------------------------------------------------------------------------------------[150 characters]
    Start Traffic in DL    ue_id=${ue_id_2}    qfi_id=1    trf_id=2    mbps=20
    Start Traffic in DL    ue_id=${ue_id_2}    qfi_id=2    trf_id=3    mbps=20
    Start Traffic in DL    ue_id=${ue_id_2}    qfi_id=3    trf_id=4    mbps=20
    pmcounters.Wait until the next Measurement Period starts
    pmcounters.Wait until the next Measurement Period starts
    pmcounters.Wait until the next Measurement Period starts
    ${distName_NRCELL}=   Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    coam_ulm.Update SCF parameter   value=25    parameter=dllaMcsMax64qamRANK4HR     dist_name=${distName_NRCELL[0]}    list_name=pdschHrLaConfig
    pmcounters.Wait until the next Measurement Period starts
    #--- Deregister UEs -------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . UE Deregister    ue_id=${ue_id}
    wts_ue . UE Deregister    ue_id=${ue_id_2}


TC09_HrDrbPdsch_SA_multiDRB_noLowSeUe_nonGBR_OnlineModify_NRBTS_multiUE
    ${non_attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=sa    with_auto_attach=${FALSE}
    ${non_attached_ues_list}=  get dictionary keys  ${non_attached_ues_dict}
    ${ue_id}=      set variable    ${non_attached_ues_list}[4]
    ${ue_id_2}=    set variable    ${non_attached_ues_list}[5]
    #${target_bler_TC09}=    set variable    20,20,20,20,20,20,20,20,20,20,20,20,20,20,20
    wts_ue . Configure NR BLER testmode  profile_id=${bler_profile_id}    target_mcs=6  target_bler=${target_bler}  mcs_table=qam64
    connect.Setup OAM HTTP Session
    #--- Register UE1 ---------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    wts_ue . UE Register    ue_id=${ue_id}
    wts_ue . Send Egate Command and verify output   cmd=smf_param additional_qosflows_to_activate=7,8 id=1
    wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1
    sleep  3s
    #--- Start Traffic UE1 ----------------------------------------------------------------------------------------------------------[150 characters]
    Start Traffic in DL    ue_id=${ue_id}    qfi_id=1    trf_id=2    mbps=7
    Start Traffic in DL    ue_id=${ue_id}    qfi_id=2    trf_id=3    mbps=7
    Start Traffic in DL    ue_id=${ue_id}    qfi_id=3    trf_id=4    mbps=7
    sleep  3s
    ${distName_NRBTS}=   Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    sort list    ${distName_NRBTS}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    coam_ulm.Update SCF parameter   value=25    parameter=dlHRBlerOutageMcsThresh64qam     dist_name=${distName_NRBTS[0]}/NRPDSCHHRLA-1
    coam_ulm.Update SCF parameter   value=18    parameter=dlHRBlerRecoverMcsThresh64qam    dist_name=${distName_NRBTS[0]}/NRPDSCHHRLA-1
    #--- Register UE2 ---------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${ue_id_2} pdu=1 trf_type=internal
    wts_ue . UE Register    ue_id=${ue_id_2}
    wts_ue . Send Egate Command and verify output   cmd=smf_param additional_qosflows_to_activate=7,8 id=1
    wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id_2} nwslice=1 gw=1
    sleep  3s
    #--- Start Traffic UE2 ----------------------------------------------------------------------------------------------------------[150 characters]
    Start Traffic in DL    ue_id=${ue_id_2}    qfi_id=1    trf_id=2    mbps=7
    Start Traffic in DL    ue_id=${ue_id_2}    qfi_id=2    trf_id=3    mbps=7
    Start Traffic in DL    ue_id=${ue_id_2}    qfi_id=3    trf_id=4    mbps=7
    sleep  1s
    wts_ue . Associate UEs to testmode    ue_id=${ue_id},${ue_id_2}      profile_id=${bler_profile_id}     action=activate      testmode=bler
    sleep  4s
    wts_ue . Associate UEs to testmode    ue_id=${ue_id},${ue_id_2}      profile_id=${bler_profile_id}     action=deactivate    testmode=bler
    sleep  4s
    #--- Deregister UEs -------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . UE Deregister    ue_id=${ue_id}
    wts_ue . UE Deregister    ue_id=${ue_id_2}


TC10_HrDrbPdsch_SA_multiDRB_noLowSeUe_nonGBR_IWK_NACKflood_DLFB_BRDRB_PMC
    ${distName_NRBTS}=   Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    connect.Setup OAM HTTP Session
    coam_ulm . Update SCF parameter    value=25    parameter=dlHRBlerOutageMcsThresh64qam     dist_name=${distName_NRBTS[0]}/NRPDSCHHRLA-1
    coam_ulm . Update SCF parameter    value=27    parameter=dlHRBlerRecoverMcsThresh64qam    dist_name=${distName_NRBTS[0]}/NRPDSCHHRLA-1
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${non_attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=sa    with_auto_attach=${FALSE}
    ${non_attached_ues_list}=  get dictionary keys  ${non_attached_ues_dict}
    ${ue_id}=    set variable    ${non_attached_ues_list}[4]
    ${nack_flood}=    set variable    100,100,100,100,100,100,100,100,100,100,100,100,100,100,100
    wts_ue . Configure NR BLER testmode  profile_id=${bler_profile_id}    target_mcs=${Mcs}  target_bler=${nack_flood}  mcs_table=qam64
    #--- Register UEs ---------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    wts_ue . UE Register    ue_id=${ue_id}
    wts_ue . Send Egate Command and verify output   cmd=smf_param additional_qosflows_to_activate=7,8 id=1
    wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1
    sleep  1s
    #--- Start Traffic --------------------------------------------------------------------------------------------------------------[150 characters]
    Start Traffic in DL    ue_id=${ue_id}      qfi_id=1    trf_id=2    mbps=7
    Start Traffic in DL    ue_id=${ue_id}      qfi_id=2    trf_id=3    mbps=7
    Start Traffic in DL    ue_id=${ue_id}      qfi_id=3    trf_id=4    mbps=7
    sleep  1s
    wts_ue . Associate UEs to testmode    ue_id=${ue_id}      profile_id=${bler_profile_id}     action=activate      testmode=bler
    sleep  4s
    wts_ue . Associate UEs to testmode    ue_id=${ue_id}      profile_id=${bler_profile_id}     action=deactivate    testmode=bler
    sleep  4s
    #--- Stop Traffic and Release PDU bearer ----------------------------------------------------------------------------------------[150 characters]
    Stop traffic and release PDU bearer    ue_id=${ue_id}      trf_id=2    qosflows=1
    sleep  1s
    wts_ue . Associate UEs to testmode    ue_id=${ue_id}      profile_id=${bler_profile_id}     action=activate      testmode=bler
    sleep  4s
    wts_ue . Associate UEs to testmode    ue_id=${ue_id}      profile_id=${bler_profile_id}     action=deactivate    testmode=bler
    sleep  4s
    #--- Deregister UEs -------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . UE Deregister    ue_id=${ue_id}


TC11_HrDrbPdsch_SA_multiDRB_noLowSeUe_nonGBR_HRDRB_PMC
    ${non_attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=sa    with_auto_attach=${FALSE}
    ${non_attached_ues_list}=  get dictionary keys  ${non_attached_ues_dict}
    ${ue_id}=      set variable    ${non_attached_ues_list}[4]
    ${ue_id_2}=    set variable    ${non_attached_ues_list}[5]
    connect.Setup OAM HTTP Session
    #--- Register UE1 ---------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    wts_ue . UE Register    ue_id=${ue_id}
    wts_ue . Send Egate Command and verify output   cmd=smf_param additional_qosflows_to_activate=7,8 id=1
    wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1
    sleep  1s
    #--- Start Traffic UE1 ----------------------------------------------------------------------------------------------------------[150 characters]
    Start Traffic in DL    ue_id=${ue_id}    qfi_id=1    trf_id=2    mbps=2
    Start Traffic in DL    ue_id=${ue_id}    qfi_id=2    trf_id=3    mbps=2
    Start Traffic in DL    ue_id=${ue_id}    qfi_id=3    trf_id=4    mbps=2
    sleep  1s
    ${distName_NRBTS}=   Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    sort list    ${distName_NRBTS}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    coam_ulm.Update SCF parameter   value=25    parameter=dlHRBlerOutageMcsThresh64qam     dist_name=${distName_NRBTS[0]}/NRPDSCHHRLA-2
    coam_ulm.Update SCF parameter   value=27    parameter=dlHRBlerRecoverMcsThresh64qam    dist_name=${distName_NRBTS[0]}/NRPDSCHHRLA-2
    #--- Register UE2 ---------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${ue_id_2} pdu=1 trf_type=internal
    wts_ue . UE Register    ue_id=${ue_id_2}
    wts_ue . Send Egate Command and verify output   cmd=smf_param additional_qosflows_to_activate=7,8 id=1
    wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id_2} nwslice=1 gw=1
    sleep  1s
    #--- Start Traffic UE2 ----------------------------------------------------------------------------------------------------------[150 characters]
    Start Traffic in DL    ue_id=${ue_id_2}    qfi_id=1    trf_id=2    mbps=2
    Start Traffic in DL    ue_id=${ue_id_2}    qfi_id=2    trf_id=3    mbps=2
    Start Traffic in DL    ue_id=${ue_id_2}    qfi_id=3    trf_id=4    mbps=2
    sleep  3s
    #--- Stop Traffic UE1 &nd Release PDU bearer  -----------------------------------------------------------------------------------[150 characters]
    Stop traffic and release PDU bearer    ue_id=${ue_id}    trf_id=2    qosflows=1
    Stop traffic and release PDU bearer    ue_id=${ue_id_2}    trf_id=2    qosflows=1
    sleep  5s
    #--- Deregister UEs -------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . UE Deregister    ue_id=${ue_id}
    wts_ue . UE Deregister    ue_id=${ue_id_2}


TC12_HrDrbPdsch_SA_multiDRB_GBR_FDD
    ${non_attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=sa    with_auto_attach=${FALSE}
    ${non_attached_ues_list}=  get dictionary keys  ${non_attached_ues_dict}
    ${ue_id}=    set variable    ${non_attached_ues_list}[0]
    #--- Register UE1 ---------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    wts_ue . UE Register    ue_id=${ue_id}
    wts_ue . Send Egate Command and verify output   cmd=smf_param additional_qosflows_to_activate=7,5 id=1
    wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1
    sleep  3s
    #--- Start Traffic UE1 ----------------------------------------------------------------------------------------------------------[150 characters]
    Start Traffic in DL    ue_id=${ue_id}    qfi_id=1    trf_id=2    mbps=10
    Start Traffic in DL    ue_id=${ue_id}    qfi_id=2    trf_id=3    mbps=10
    Start Traffic in DL    ue_id=${ue_id}    qfi_id=3    trf_id=4    mbps=10
    sleep  3s
    #--- Stop Traffic UE1 &nd Release PDU bearer  -----------------------------------------------------------------------------------[150 characters]
    Stop traffic and release PDU bearer    ue_id=${ue_id}    trf_id=3    qosflows=7
    sleep  3s
    #--- Deregister UEs -------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . UE Deregister    ue_id=${ue_id}


TC13_HrDrbPdsch_SA_multiDRB_GBR_PDCCH_AL_Dynamic_multiUE
    ${non_attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=sa    with_auto_attach=${FALSE}
    ${non_attached_ues_list}=  get dictionary keys  ${non_attached_ues_dict}
    ${ue_id}=      set variable    ${non_attached_ues_list}[0]
    ${ue_id_2}=    set variable    ${non_attached_ues_list}[1]
    #--- Register UE1 ---------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    wts_ue . UE Register    ue_id=${ue_id}
    wts_ue . Send Egate Command and verify output   cmd=smf_param additional_qosflows_to_activate=7,5 id=1
    wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1
    sleep  3s
    #--- Start Traffic UE1 ----------------------------------------------------------------------------------------------------------[150 characters]
    Start Traffic in DL    ue_id=${ue_id}    qfi_id=1    trf_id=2    mbps=10
    Start Traffic in DL    ue_id=${ue_id}    qfi_id=2    trf_id=3    mbps=10
    Start Traffic in DL    ue_id=${ue_id}    qfi_id=3    trf_id=4    mbps=10
    sleep  3s
    #--- Register UE2 ---------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${ue_id_2} pdu=1 trf_type=internal
    wts_ue . UE Register    ue_id=${ue_id_2}
    wts_ue . Send Egate Command and verify output   cmd=smf_param additional_qosflows_to_activate=7,5 id=1
    wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id_2} nwslice=1 gw=1
    sleep  3s
    #--- Start Traffic UE2 ----------------------------------------------------------------------------------------------------------[150 characters]
    Start Traffic in DL    ue_id=${ue_id_2}    qfi_id=1    trf_id=2    mbps=10
    Start Traffic in DL    ue_id=${ue_id_2}    qfi_id=2    trf_id=3    mbps=10
    Start Traffic in DL    ue_id=${ue_id_2}    qfi_id=3    trf_id=4    mbps=10
    sleep  3s
    #--- Stop Traffic UE1/UE2 &nd Release PDU bearer  -------------------------------------------------------------------------------[150 characters]
    Stop traffic and release PDU bearer    ue_id=${ue_id}    trf_id=3    qosflows=7
    sleep  3s
    Stop traffic and release PDU bearer    ue_id=${ue_id_2}    trf_id=3    qosflows=7
    sleep  3s
    #--- Deregister UEs -------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . UE Deregister    ue_id=${ue_id}
    wts_ue . UE Deregister    ue_id=${ue_id_2}


TC14_HrDrbPdsch_SA_multiDRB_DiffGBR_mixedUEtype
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
    #--- Register UE1 ---------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    wts_ue . UE Register    ue_id=${ue_id}
    wts_ue . Send Egate Command and verify output   cmd=smf_param additional_qosflows_to_activate=7,6 id=1
    wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1
    sleep  3s
    #--- Register UE2 ---------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${ue_id_2} pdu=1 trf_type=internal
    wts_ue . UE Register    ue_id=${ue_id_2}
    wts_ue . Send Egate Command and verify output   cmd=smf_param additional_qosflows_to_activate=7,6 id=1
    wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id_2} nwslice=1 gw=1
    sleep  3s
    #--- Register UE3 ---------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${ue_id_3} pdu=1 trf_type=internal
    wts_ue . UE Register    ue_id=${ue_id_3}
    wts_ue . Send Egate Command and verify output   cmd=smf_param additional_qosflows_to_activate=7,6 id=1
    wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id_3} nwslice=1 gw=1
    sleep  3s
    #--- Register UE4 ---------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${ue_id_4} pdu=1 trf_type=internal
    wts_ue . UE Register    ue_id=${ue_id_4}
    wts_ue . Send Egate Command and verify output   cmd=smf_param additional_qosflows_to_activate=7,6 id=1
    wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id_4} nwslice=1 gw=1
    sleep  3s
    #--- Register UE5 ---------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${ue_id_5} pdu=1 trf_type=internal
    wts_ue . UE Register    ue_id=${ue_id_5}
    wts_ue . Send Egate Command and verify output   cmd=smf_param additional_qosflows_to_activate=7,6 id=1
    wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id_5} nwslice=1 gw=1
    sleep  3s
    #--- Register UE6 ---------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${ue_id_6} pdu=1 trf_type=internal
    wts_ue . UE Register    ue_id=${ue_id_6}
    wts_ue . Send Egate Command and verify output   cmd=smf_param additional_qosflows_to_activate=7,6 id=1
    wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id_6} nwslice=1 gw=1
    sleep  3s
    #--- Register UE7 ---------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${ue_id_7} pdu=1 trf_type=internal
    wts_ue . UE Register    ue_id=${ue_id_7}
    wts_ue . Send Egate Command and verify output   cmd=smf_param additional_qosflows_to_activate=7,6 id=1
    wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id_7} nwslice=1 gw=1
    sleep  3s
    #--- Register UE8 ---------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${ue_id_8} pdu=1 trf_type=internal
    wts_ue . UE Register    ue_id=${ue_id_8}
    wts_ue . Send Egate Command and verify output   cmd=smf_param additional_qosflows_to_activate=7,6 id=1
    wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id_8} nwslice=1 gw=1
    sleep  3s
    #--- Start Traffic for LowSE UEs ------------------------------------------------------------------------------------------------[150 characters]
    Start Traffic in DL    ue_id=${ue_id},${ue_id_2},${ue_id_3},${ue_id_4}    qfi_id=1    trf_id=2    mbps=20
    Start Traffic in DL    ue_id=${ue_id},${ue_id_2},${ue_id_3},${ue_id_4}    qfi_id=2    trf_id=3    mbps=20
    Start Traffic in DL    ue_id=${ue_id},${ue_id_2},${ue_id_3},${ue_id_4}    qfi_id=3    trf_id=4    mbps=20
    #--- Start Traffic for noLowse UEs ----------------------------------------------------------------------------------------------[150 characters]
    Start Traffic in DL    ue_id=${ue_id_5},${ue_id_6},${ue_id_7},${ue_id_8}    qfi_id=1    trf_id=2    mbps=20
    Start Traffic in DL    ue_id=${ue_id_5},${ue_id_6},${ue_id_7},${ue_id_8}    qfi_id=2    trf_id=3    mbps=20
    Start Traffic in DL    ue_id=${ue_id_5},${ue_id_6},${ue_id_7},${ue_id_8}    qfi_id=3    trf_id=4    mbps=20
    sleep  3s
    #--- Stop Traffic UE1/UE2 &nd Release PDU bearer  -------------------------------------------------------------------------------[150 characters]
    Stop traffic and release PDU bearer    ue_id=${ue_id}    trf_id=3    qosflows=7
    sleep  3s
    #--- Deregister UEs -------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . UE Deregister    ue_id=${ue_id}
    wts_ue . UE Deregister    ue_id=${ue_id_2}
    wts_ue . UE Deregister    ue_id=${ue_id_3}
    wts_ue . UE Deregister    ue_id=${ue_id_4}
    wts_ue . UE Deregister    ue_id=${ue_id_5}
    wts_ue . UE Deregister    ue_id=${ue_id_6}
    wts_ue . UE Deregister    ue_id=${ue_id_7}
    wts_ue . UE Deregister    ue_id=${ue_id_8}


TC15_HrDrbPdsch_SA_multiDRB_GBR_noLowSeUe
    ${non_attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=sa    with_auto_attach=${FALSE}
    ${non_attached_ues_list}=  get dictionary keys  ${non_attached_ues_dict}
    ${ue_id}=    set variable    ${non_attached_ues_list}[4]
    #--- Register UE1 ---------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . Send Egate Command and verify output   cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    wts_ue . UE Register    ue_id=${ue_id}
    wts_ue . Send Egate Command and verify output   cmd=smf_param additional_qosflows_to_activate=7,5 id=1
    wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1
    sleep  1s
    #--- Start Traffic UE1 ----------------------------------------------------------------------------------------------------------[150 characters]
    Start Traffic in DL    ue_id=${ue_id}    qfi_id=1    trf_id=2    mbps=10
    Start Traffic in DL    ue_id=${ue_id}    qfi_id=2    trf_id=3    mbps=10
    Start Traffic in DL    ue_id=${ue_id}    qfi_id=3    trf_id=4    mbps=10
    sleep  2s
    #--- Stop Traffic UE1 &nd Release PDU bearer  -----------------------------------------------------------------------------------[150 characters]
    Stop traffic and release PDU bearer    ue_id=${ue_id}    trf_id=3    qosflows=7
    sleep  4s
    #--- Deregister UEs -------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue . UE Deregister    ue_id=${ue_id}


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


Stop traffic and release PDU bearer
    [Arguments]  ${ue_id}   ${trf_id}    ${qosflows}
    wts_ue . Stop data traffic in egate    ue_id=${ue_id}    direction=dl    trf_id=${trf_id}
    sleep   1s
    wts_ue . Send Egate Command and verify output   cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=${qosflows} by=amf


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
