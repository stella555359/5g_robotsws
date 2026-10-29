*** Settings ***
Documentation    Specific Test Cases for subfeature CB013392-B

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    taf.config.wts                                         WITH NAME  wts
Library    ./../../libraries/CB013392_tools.py                    WITH NAME  CB013392
Library    ./../libraries/CB013392_C_B10_commissioning.py         WITH NAME  c_b10_commissioning

Resource   ./../../../../resources/Common/coam_ulm.robot
Resource   ../../../../resources/Common/commissioning.robot
Resource   ../../../../resources/Common/ute_workarounds.robot



*** Keywords ***

C B2 TC01 Incoming HO
    ${ue_id}=    Get The First Attached UE
    CB013392.Initialize Egate
    # Send meas gap command (needed for inter freq HO in NSA; UE can check for cells with other freq)
    ${cmd}  Set Variable   ue_enb_param id=${ue_id} measurement_gap=gp0:0 mgta=ms0 gap_purpose=perUE gap_trigger=gnb_triggered
    wts_ue.Send Egate Command And Verify Output  cmd=${cmd}
    Sleep   1s
    # Trigger handover for UE
    CB013392.Trigger HO   ue_id=${ue_id}   a2_meas_id=3   a3_meas_id=6   scenario=NSA


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
C B4 TC01 ENB Initiated Intra ENB HO
    ${ue_id}=    Get The First Attached UE
    CB013392.Initialize Egate

    CB013392.Log UE Meas Disp    ${ue_id}   AFTER SgNB ADDITION

    # In nr-rrctoolgui tool select MeasResultList2NR
    # 0B1EA578010D80 -> ssbFrequency 502110, physCellId 54
    ${cmd}  Set Variable   ue_enb_endc_param id=${ue_id} candidate_cells_mn_hex_for_menb_ho=0B1EA578010D80
    wts_ue.Send Egate Command And Verify Output  cmd=${cmd}
    ${cmd}  Set Variable   ue_ho id=${ue_id} ho_mode=INTRA_LTE enb=1 cell=2
    wts_ue.Send Egate Command And Verify Output  cmd=${cmd}
    Sleep  1s

    ${path_to_mp}=  Set Variable  ${ts_log_dir}/meas_disp_after_HO.txt
    CB013392.Get UE Meas Disp   ${path_to_mp}   ${ue_id}   AFTER INTRA eNB+gNB HANDOVER


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
C B7 TC01 ENB Initiated Inter ENB HO
    ${ue_id}=    Get The First Attached UE
    CB013392.Initialize Egate

    CB013392.Log UE Meas Disp    ${ue_id}   AFTER SgNB ADDITION

    # In nr-rrctoolgui tool select MeasResultList2NR
    # 0B1EA578010D80 -> ssbFrequency 502110, physCellId 54
    ${cmd}  Set Variable   ue_enb_endc_param id=${ue_id} candidate_cells_mn_hex_for_menb_ho=0B1EA578010D80
    wts_ue.Send Egate Command And Verify Output  cmd=${cmd}
    ${cmd}  Set Variable   ue_ho id=${ue_id} ho_mode=INTRA_LTE enb=9 cell=9
    wts_ue.Send Egate Command And Verify Output  cmd=${cmd}
    Sleep  1s

    ${path_to_mp}=  Set Variable  ${ts_log_dir}/meas_disp_after_HO.txt
    CB013392.Get UE Meas Disp   ${path_to_mp}   ${ue_id}   AFTER INTER eNB + INTRA gNB HANDOVER


C B7 TC01 Enable Link To 2nd ENB
    ${cmd}  Set Variable   enb_x2_link_up enb=9 target=2
    wts_ue.Send Egate Command And Verify Output    cmd=${cmd}
    Sleep    5s


C B8 TC01 Activation After A1
    ${ue_id}=    Get The First Attached UE
    CB013392.Initialize Egate
    #--- After UE Attach ------------------------------------------------------------------------------------------------------------[150 characters]
    ${cmd}  Set Variable   ue_enb_param id=${ue_id} measurement_gap=gp0:0 mgta=ms0 gap_purpose=perUE gap_trigger=gnb_triggered
    wts_ue.Send Egate Command And Verify Output  cmd=${cmd}
    Sleep  1s
    ${path_to_mp}=  Set Variable  ${ts_log_dir}/meas_disp_after_attach.txt
    CB013392.Get UE Meas Disp   ${path_to_mp}   ${ue_id}   AFTER UE ATTACH
    Sleep  1s
    #--- Event A2 -------------------------------------------------------------------------------------------------------------------[150 characters]
    ${cmd}  Set Variable   ue_measurement_send_nr id=${ue_id} meas_id=3 event=A2 srsrp_nr=80 srsrq_nr=80 srs_result=0:11:11:0
    wts_ue.Send Egate Command And Verify Output  cmd=${cmd}
    Sleep  1s
    ${path_to_mp}=  Set Variable  ${ts_log_dir}/meas_disp_after_a2.txt
    CB013392.Get UE Meas Disp   ${path_to_mp}   ${ue_id}   AFTER A2
    Sleep  1s
    #--- Event A1 -------------------------------------------------------------------------------------------------------------------[150 characters]
    ${cmd}  Set Variable   ue_measurement_send_nr id=${ue_id} meas_id=5 event=A1 srsrp_nr=97 srsrq_nr=97
    wts_ue.Send Egate Command And Verify Output  cmd=${cmd}
    Sleep  1s
    ${path_to_mp}=  Set Variable  ${ts_log_dir}/meas_disp_after_a1.txt
    CB013392.Get UE Meas Disp   ${path_to_mp}   ${ue_id}   AFTER A1
    Sleep  1s


C B10 TC01 Wait For A4 Configuration
    ${ue_id}=    Get The First Attached UE
    CB013392.Initialize Egate
    # Send meas gap command (needed for inter freq HO in NSA; UE can check for cells with other freq)
    ${cmd}  Set Variable   ue_enb_param id=${ue_id} measurement_gap=gp0:0 mgta=ms0 gap_purpose=perUE gap_trigger=gnb_triggered
    wts_ue.Send Egate Command And Verify Output  cmd=${cmd}
    Sleep  6s    # wait for 5s timer and the automatic configuration afterwards
    ${path_to_mp}=  Set Variable  ${ts_log_dir}/meas_disp_with_A4.txt
    CB013392.Get UE Meas Disp   ${path_to_mp}   ${ue_id}   AFTER A4 CONFIG


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
C B10 TC02 Wait And Send A1
    ${ue_id}=    Get The First Attached UE
    CB013392.Initialize Egate
    # Send meas gap command (needed for inter freq HO in NSA; UE can check for cells with other freq)
    ${cmd}  Set Variable   ue_enb_param id=${ue_id} measurement_gap=gp0:0 mgta=ms0 gap_purpose=perUE gap_trigger=gnb_triggered
    wts_ue.Send Egate Command And Verify Output  cmd=${cmd}
    Sleep  6s    # wait A4 retry timer (5s). It should not be triggered and A4 not be configured
    CB013392.Log UE Meas Disp   ${ue_id}   AFTER A4 RETRY TIMER (NO A4 CONFIGURED)    # just for info, not used for verification

    Sleep  1s
    ${cmd}  Set Variable   ue_measurement_send_nr id=${ue_id} meas_id=5 event=A1
    wts_ue.Send Egate Command And Verify Output  cmd=${cmd}

    Sleep  1s
    ${path_to_mp}=  Set Variable  ${ts_log_dir}/meas_disp_with_A4.txt
    CB013392.Get UE Meas Disp   ${path_to_mp}   ${ue_id}   AFTER A4 CONFIG WITH A1


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Get The First Attached UE
    ${attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=nsa
    ${attached_ues_list}=  Get Dictionary Keys  ${attached_ues_dict}
    RETURN    ${attached_ues_list}[0]


Modify Basic_setup.cfg For PowerCoordination
    wts.Insert    ue_enb_endc_param id=101 p_max_nr=23 p_max_eutra=23    after    set_bearer


Remove Nwslices
    FOR  ${id}  IN RANGE   2  21  # numbers from 2 to 20
        wts.Delete    set_nwslice id=${id}
        wts.Modify    set_nwslice id=1   modification=ue=all
    END


Modify Basic_setup For ENB Mobility On TMO
    ${change}  Set Variable  earfcn=2000:20000 mapped_earfcn=4200:22200 tdd_cell=on mandatory_for_activation=off proxy=$DAEMON_IP:12221
    wts.Modify  set_cell id=1 bw=10MHz enb=1   modification=${change}

    ${cmd}    Catenate      set_cell id=2 bw=10MHz enb=1 eci=0x1234602 pci=4:0 tac=222 proxy=$DAEMON_IP:12222 earfcn=2000:20000
    ...                     mapped_earfcn=4200:22200 tdd_cell=on mandatory_for_activation=off
    wts.Insert  ${cmd}  after   set_cell id=1 bw=10MHz enb=1

    ${cmd}    Catenate      set_cell id=3 bw=10MHz enb=1 eci=0x1234603 pci=4:1 tac=222 proxy=$DAEMON_IP:12223 earfcn=2000:20000
    ...                     mapped_earfcn=4200:22200 tdd_cell=on mandatory_for_activation=off
    wts.Insert  ${cmd}  after   set_cell id=2 bw=10MHz enb=1

    wts.Insert    enb_cell_param enb=1 id=2 allow_endc=on    after   set_cell id=3 bw=10MHz enb=1

    wts.Insert    ue_enb_endc_param id=101 include_p_max=sgnb_addition_and_modification    after    ue_enb_endc_param id=101

    # additional simulated eNB for C_B7
    wts.Insert    set ENB9_X2_ADDR="10.0.1.139"    after    set GNB_X2_ADDR="10.0.1.2"
    wts.Insert    set ENB9_X2U_ADDR="10.0.1.140"   after    set ENB9_X2_ADDR="10.0.1.139"
    wts.Insert    set ENB9_S1_ADDR="10.0.1.141"    after    set ENB9_X2U_ADDR="10.0.1.140"

    ${cmd}    Catenate      set_enb id=9 plmn=310:260 s1=$ENB9_S1_ADDR enb_id_macro=0x12349 daemon=$DAEMON_IP:$DAEMON_PORT x2=$ENB9_X2_ADDR
    ...                     x2u=$ENB9_X2U_ADDR type=simulated x2_peers=1
    wts.Insert    ${cmd}  after   enb_endc_param id=1

    wts.Insert    enb_param id=9 drb_id_begin=3 endc_capable_qci=9  after   set_enb id=9

    ${cmd}    Catenate      set_cell id=9 bw=10MHz enb=9 eci=0x1234901 pci=9:2 tac=222 proxy=$DAEMON_IP:12229 earfcn=2000:20000
    ...                     mapped_earfcn=4200:22200 tdd_cell=on mandatory_for_activation=off
    wts.Insert    ${cmd}  after   enb_param id=9

    wts.Insert    enb_cell_param enb=9 id=9 allow_endc=on    after    set_cell id=9 bw=10MHz enb=9

    ${cmd}    Catenate      enb_endc_param id=9 control_flow_period=3gpp1 use_nr_ran_cont=on p_max_nr_tgt_menb=23 p_max_eutra_tgt_menb=23
    ...                     allowed_bc_list_mrdc=2:1
    wts.Insert    ${cmd}   after   enb_cell_param enb=9

    # add IP addresses
    Log To Console    \nadd IPs 10.0.1.139, 10.0.1.140 and 10.0.1.141

    ute_workarounds.Configure IP On VM    ip=10.0.1.139        interface=eth3
    ute_workarounds.Configure IP On VM    ip=10.0.1.140        interface=eth3
    ute_workarounds.Configure IP On VM    ip=10.0.1.141        interface=eth3


#-----------For iphy.xml Changes-----------------------------------------------------------------------------------------------------[150 characters]
Save IPHY File
    ${ap_alias}    connect.Connect to Airphone Common Unit
    ssh . Download File    /rom/simmode/new_iphy.xml    ${configuration_directory}/iphy_orig.xml    connection=${ap_alias}
