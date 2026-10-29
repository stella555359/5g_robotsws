*** Settings ***
Documentation    Specific Test Cases for subfeature CB013392-B

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    Collections
Library    ../../../L2/libraries/template_functions.py          WITH NAME  template
Library    ../../libraries/CB013392_tools.py                    WITH NAME  CB013392

Resource   ./../../../../resources/Common/coam_ulm.robot


*** Variables ***
${LOOP_COUNT}          9


*** Keywords ***

B B1 TC01 Test Steps
    Get Not Attached UEs
    CB013392 . register_multiple_ue_with_amf    ${NON_ATTACHED_UES_LIST}
    CB013392 . get_ue_meas_disp_kpi    ${NON_ATTACHED_UES_LIST}
    FOR   ${ue_id}  IN   @{NON_ATTACHED_UES_LIST}
        CB013392.Trigger HO  ${ue_id}   a3_meas_id=7  phycell_id=54  from_cell=7  to_cell=4
    END
    Trigger Traffic
    Deregister UEs And Change Location


B B1 TC01 Blind SCell Addition Incoming HO
    CB013392 . initialize_egate
    FOR    ${loop_ctr}    IN RANGE    1    ${LOOP_COUNT}    1
        Log to console  Loop Count: ${loop_ctr}
        B B1 TC01 Test Steps
        Sleep  10s
    END


Trigger Traffic
    #--- Start Traffic UE1 ----------------------------------------------------------------------------------------------------------[150 characters]
    FOR   ${ue_id}  IN   @{NON_ATTACHED_UES_LIST}
        Start Traffic In UL    ue_id=${ue_id}    qfi_id=1    trf_id=2    mbps=2    seconds=500
        Start Traffic In DL    ue_id=${ue_id}    qfi_id=1    trf_id=4    mbps=10    seconds=500
        ${output}   wts_ue . Send Egate Command And Verify Output   cmd=ue_nr_stats id=${ue_id} type=pdsch,pusch scell=0,1
        Log    ${output}    console=yes
    END
    Sleep  500s


Deregister UEs And Change Location
    FOR   ${ue_id}  IN   @{NON_ATTACHED_UES_LIST}
        wts_ue . UE Deregister    ue_id=${ue_id}
        ${output}   wts_ue . Send Egate Command and verify output   cmd=ue_change_location id=${ue_id} cell=7
        Log    ${output}    console=yes
    END


B_B2_TC01_IntragNB_A1_SCell_addition_DL_CA
    ${ue_id}=    Get The First Not Attached UE
    CB013392.Initialize Egate
    #--- Register UE    -------------------------------------------------------------------------------------------------------------[150 characters]
    CB013392.Register UE Collect RRC  ${ue_id}
    # Trigger A1 event to add scell
    CB013392.Trigger A1 Fdd Scell Addition  ${ue_id}
    Sleep  1s
    #--- Start Traffic UE1 ----------------------------------------------------------------------------------------------------------[150 characters]
    Start Traffic In UL    ue_id=${ue_id}    qfi_id=1    trf_id=2    mbps=50     seconds=3
    Start Traffic In DL    ue_id=${ue_id}    qfi_id=1    trf_id=4    mbps=175    seconds=3
    Start Traffic In DL    ue_id=${ue_id}    qfi_id=1    trf_id=5    mbps=175    seconds=3
    ${output}   wts_ue.Send Egate Command And Verify Output   cmd=ue_nr_stats id=${ue_id} type=pdsch,pusch scell=0,1
    Log    ${output}    console=yes
    Sleep  3s
    #--- Deregister UEs -------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue.UE Deregister    ue_id=${ue_id}


B_B3_TC01_IntragNB_A1_DL_SCell_change_to_DL_SCell_CA
    ${ue_id}=    Get The First Not Attached UE
    CB013392.Initialize Egate
    #--- Register UE    -------------------------------------------------------------------------------------------------------------[150 characters]
    CB013392.Register UE Collect RRC  ${ue_id}  pdu=1  gw=1
    Sleep  1s
    # Trigger A1 event to add FDD scell
    CB013392.Trigger A1 Fdd Scell Addition  ${ue_id}
    Sleep  1s
    # Trigger A1 event to add TDD scell
    CB013392.Trigger A1 Tdd Scell Addition  ${ue_id}    meas_id=7
    Sleep  1s
    #--- Start Traffic UE1 ----------------------------------------------------------------------------------------------------------[150 characters]
    # Start Traffic In UL    ue_id=${ue_id}    qfi_id=1    trf_id=2    mbps=50    seconds=3
    # Start Traffic In DL    ue_id=${ue_id}    qfi_id=1    trf_id=4    mbps=175    seconds=3
    # Start Traffic In DL    ue_id=${ue_id}    qfi_id=1    trf_id=5    mbps=175    seconds=3
    # ${output}   wts_ue.Send Egate Command And Verify Output   cmd=ue_nr_stats id=${ue_id} type=pdsch,pusch scell=0,1
    # Log    ${output}    console=yes
    # Sleep  3s
    #--- Deregister UEs -------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue.UE Deregister    ue_id=${ue_id}


B_B5_TC01_IntergNB_A1_SCell_addition_DL_CA
    ${ue_id}=    Get The First Not Attached UE
    CB013392.Initialize Egate
    #--- Register UE    -------------------------------------------------------------------------------------------------------------[150 characters]
    CB013392.Register UE Collect RRC  ${ue_id}
    #--- Start Traffic UE1 ----------------------------------------------------------------------------------------------------------[150 characters]
    Sleep  1s
    Start Traffic In UL    ue_id=${ue_id}    qfi_id=1    trf_id=2    mbps=50    seconds=3
    Start Traffic In DL    ue_id=${ue_id}    qfi_id=1    trf_id=4    mbps=175    seconds=3
    Start Traffic In DL    ue_id=${ue_id}    qfi_id=1    trf_id=5    mbps=175    seconds=3
    Start Traffic In DL    ue_id=${ue_id}    qfi_id=1    trf_id=6    mbps=175    seconds=3
    Start Traffic In DL    ue_id=${ue_id}    qfi_id=1    trf_id=7    mbps=175    seconds=3
    Sleep  3s
    #--- Deregister UEs -------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue.UE Deregister    ue_id=${ue_id}


B_B6_TC01_IntergNB_A2_SCell_release_DL_CA
    ${ue_id}=    Get The First Not Attached UE
    CB013392.Initialize Egate
    #--- Register UE    -------------------------------------------------------------------------------------------------------------[150 characters]
    CB013392.Register UE Collect RRC  ${ue_id}
    #--- Start Traffic UE1 ----------------------------------------------------------------------------------------------------------[150 characters]
    Sleep  1s
    Start Traffic In UL    ue_id=${ue_id}    qfi_id=1    trf_id=2    mbps=50    seconds=3
    Start Traffic In DL    ue_id=${ue_id}    qfi_id=1    trf_id=4    mbps=175    seconds=3
    Start Traffic In DL    ue_id=${ue_id}    qfi_id=1    trf_id=5    mbps=175    seconds=3
    Start Traffic In DL    ue_id=${ue_id}    qfi_id=1    trf_id=6    mbps=175    seconds=3
    Start Traffic In DL    ue_id=${ue_id}    qfi_id=1    trf_id=7    mbps=175    seconds=3
    Sleep  3s
    #--- Deregister UEs -------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue.UE Deregister    ue_id=${ue_id}


B_B7_TC01_IntragNB_A2_SCell_release_DL_CA
    ${ue_id}=    Get The First Not Attached UE
    CB013392.Initialize Egate
    #--- Register UE    -------------------------------------------------------------------------------------------------------------[150 characters]
    CB013392.Register UE Collect RRC  ${ue_id}
    # Trigger A1 event to add scell
    CB013392.Trigger A1 Fdd Scell Addition  ${ue_id}
    #  Trigger A2 event to release scell
    CB013392.Trigger A2 Scell Release  ${ue_id}
    Sleep  1s
    #--- Start Traffic UE1 ----------------------------------------------------------------------------------------------------------[150 characters]
    Start Traffic In UL    ue_id=${ue_id}    qfi_id=1    trf_id=2    mbps=50    seconds=3
    Start Traffic In DL    ue_id=${ue_id}    qfi_id=1    trf_id=4    mbps=150    seconds=3
    Start Traffic In DL    ue_id=${ue_id}    qfi_id=1    trf_id=5    mbps=150    seconds=3
    Sleep  1s
    ${output}   wts_ue.Send Egate Command And Verify Output   cmd=ue_nr_stats id=${ue_id} type=pdsch,pusch scell=0,1
    Log    ${output}    console=yes
    Sleep  3s
    #--- Deregister UEs -------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue.UE Deregister    ue_id=${ue_id}


B_B8_TC01_IntragNB_A1_partial_SCell_release_3CC_DL_CA
    ${ue_id}=    Get the first Not Attached UE
    CB013392.Initialize Egate
    #--- Register UE    -------------------------------------------------------------------------------------------------------------[150 characters]
    CB013392.Register UE Collect RRC  ${ue_id}  pdu=1  gw=1
    Sleep  1s
    # Trigger A1 event to add FDD & TDD scell
    CB013392.Trigger A1 Tdd Scell Addition  ${ue_id}  meas_id=4
    Sleep  1s
    #  Trigger A2 event to release one scell
    CB013392.Trigger A2 Scell Release  ${ue_id}
    #--- Start Traffic UE1 ----------------------------------------------------------------------------------------------------------[150 characters]
    Start Traffic In UL    ue_id=${ue_id}    qfi_id=1    trf_id=2    mbps=50    seconds=3
    Start Traffic In DL    ue_id=${ue_id}    qfi_id=1    trf_id=4    mbps=175    seconds=3
    Start Traffic In DL    ue_id=${ue_id}    qfi_id=1    trf_id=5    mbps=175    seconds=3
    ${output}   wts_ue.Send Egate Command And Verify Output   cmd=ue_nr_stats id=${ue_id} type=pdsch,pusch scell=0,1
    Log    ${output}    console=yes
    Sleep  3s
    #--- Deregister UEs -------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue.UE Deregister    ue_id=${ue_id}


B_B9_TC01_IntragNB_A1_ULDL_SCell_change_to_DL_SCell_CA
    ${ue_id}=    Get The First Not Attached UE
    CB013392.Initialize Egate
    #--- Register UE    -------------------------------------------------------------------------------------------------------------[150 characters]
    CB013392.Register UE Collect RRC  ${ue_id}  pdu=1  gw=1
    Sleep  1s
    # Trigger A1 event to add FDD scell
    CB013392.Trigger A1 Fdd Scell Addition  ${ue_id}
    Sleep  1s
    # Trigger A1 event to add TDD scell
    CB013392.Trigger A1 Tdd Scell Addition  ${ue_id}    meas_id=7
    Sleep  1s
    # following lines will be uncommented, when TTI trace and PMCs are working with TMO TL
    #--- Start Traffic UE1 ----------------------------------------------------------------------------------------------------------[150 characters]
    # Start Traffic In UL    ue_id=${ue_id}    qfi_id=1    trf_id=2    mbps=50    seconds=3
    # Start Traffic In DL    ue_id=${ue_id}    qfi_id=1    trf_id=4    mbps=175    seconds=3
    # Start Traffic In DL    ue_id=${ue_id}    qfi_id=1    trf_id=5    mbps=175    seconds=3
    # ${output}   wts_ue.Send Egate Command And Verify Output   cmd=ue_nr_stats id=${ue_id} type=pdsch,pusch scell=0,1
    # Log    ${output}    console=yes
    # Sleep  3s
    #--- Deregister UEs -------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue.UE Deregister    ue_id=${ue_id}


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Get The First Not Attached UE
    ${non_attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=sa    with_auto_attach=${FALSE}
    ${non_attached_ues_list}=  Collections.Get Dictionary Keys   ${non_attached_ues_dict}
    RETURN    ${non_attached_ues_list}[0]


Get Not Attached UEs
    ${non_attached_ues_dict}=  template.Get Attach List    scenario_name=${scenario_name}    ue_type=sa    with_auto_attach=${FALSE}
    @{non_attached_ues_list}=   Collections.Get Dictionary Keys  ${non_attached_ues_dict}
    Set Suite Variable    @{NON_ATTACHED_UES_LIST}


Start Traffic In DL
    [Arguments]  ${ue_id}  ${qfi_id}  ${trf_id}  ${mbps}  ${seconds}
    &{kwargs}=    Create Dictionary    mbps=${mbps}    pdu=2    qfi=${qfi_id}    seconds=${seconds}
    wts_ue.Start Data Traffic In Egate    ue_id=${ue_id}
    ...                                     direction=dl
    ...                                     protocol=udp
    ...                                     ack_mode=off
    ...                                     trf_id=${trf_id}
    ...                                     cl_trf_stats=on
    ...                                     &{kwargs}


Start Traffic In UL
    [Arguments]  ${ue_id}  ${qfi_id}  ${trf_id}  ${mbps}  ${seconds}
    &{kwargs}=    Create Dictionary    mbps=${mbps}    pdu=2    qfi=${qfi_id}    seconds=${seconds}
    wts_ue.Start Data Traffic In Egate    ue_id=${ue_id}
    ...                                     direction=ul
    ...                                     protocol=udp
    ...                                     ack_mode=off
    ...                                     trf_id=${trf_id}
    ...                                     cl_trf_stats=on
    ...                                     &{kwargs}

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
