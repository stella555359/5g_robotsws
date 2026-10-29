*** Settings ***
Documentation    Specific Test Cases for subfeature CB013392-A
Library    Collections
Library    ./../../libraries/CB013392_tools.py          WITH NAME  CB013392
Resource   ./../../../../resources/Common/coam_ulm.robot
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]



*** Keywords ***

A_B1_TC01_Blind_SCell_Addition
    ${ue_id}=    Get Not Attached UEs
    CB013392.Initialize Egate
    #--- Register UE    -------------------------------------------------------------------------------------------------------------[150 characters]
    CB013392.Register UE Collect RRC  ${ue_id}  pdu=1  gw=1

    #--- Start Traffic UE1 ----------------------------------------------------------------------------------------------------------[150 characters]
    # temporarily commented out due to TTI/PMC log issue; not needed for feature verification
    # Sleep  1s
    # Start Traffic In UL    ue_id=${ue_id}    qfi_id=1    trf_id=2    mbps=100    seconds=3
    # Start Traffic In DL    ue_id=${ue_id}    qfi_id=1    trf_id=4    mbps=175    seconds=3
    # Start Traffic In DL    ue_id=${ue_id}    qfi_id=1    trf_id=5    mbps=175    seconds=3
    # Start Traffic In DL    ue_id=${ue_id}    qfi_id=1    trf_id=6    mbps=175    seconds=3
    # Start Traffic In DL    ue_id=${ue_id}    qfi_id=1    trf_id=7    mbps=175    seconds=3
    # Sleep  1s
    # ${output}   wts_ue.Send Egate Command And Verify Output   cmd=ue_nr_stats id=${ue_id} type=pdsch,pusch scell=0,1
    # Log    ${output}    console=yes

    Sleep  3s

    #--- Deregister UEs -------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue.UE Deregister    ue_id=${ue_id}


A_B1_TC02_Blind_SCell_Addition_incoming_HO
    ${ue_id}=    Get Not Attached UEs
    CB013392.Initialize Egate
    #--- Register UE    -------------------------------------------------------------------------------------------------------------[150 characters]
    CB013392.Register UE Collect RRC  ${ue_id}
    CB013392.Trigger Ho  ${ue_id}

    #--- Start Traffic UE1 ----------------------------------------------------------------------------------------------------------[150 characters]
    Sleep  1s
    Start Traffic In UL    ue_id=${ue_id}    qfi_id=1    trf_id=2    mbps=100    seconds=3
    Start Traffic In DL    ue_id=${ue_id}    qfi_id=1    trf_id=4    mbps=175    seconds=3
    Start Traffic In DL    ue_id=${ue_id}    qfi_id=1    trf_id=5    mbps=175    seconds=3
    Start Traffic In DL    ue_id=${ue_id}    qfi_id=1    trf_id=6    mbps=175    seconds=3
    Start Traffic In DL    ue_id=${ue_id}    qfi_id=1    trf_id=7    mbps=175    seconds=3
    Sleep  1s
    ${output}   wts_ue.Send Egate Command And Verify Output   cmd=ue_nr_stats id=${ue_id} type=pdsch,pusch scell=0,1
    Log    ${output}    console=yes

    Sleep  3s

    #--- Deregister UEs -------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue.UE Deregister    ue_id=${ue_id}


A_B2_TC01_IntragNB_A1_UL_SCell_addition_power_class
    ${ue_id}=    Get Not Attached UEs
    CB013392.Initialize Egate
    #--- Register UE    -------------------------------------------------------------------------------------------------------------[150 characters]
    CB013392.Register UE Collect RRC  ${ue_id}  pdu=1  gw=1

    # Trigger A1 event to add scell
    CB013392.Trigger A1 Fdd Scell Addition  ${ue_id}

    Sleep  1s

    #--- Start Traffic UE1 ----------------------------------------------------------------------------------------------------------[150 characters]
    Start Traffic In UL    ue_id=${ue_id}    qfi_id=1    trf_id=2    mbps=100    seconds=3
    Start Traffic In DL    ue_id=${ue_id}    qfi_id=1    trf_id=4    mbps=175    seconds=3
    Start Traffic In DL    ue_id=${ue_id}    qfi_id=1    trf_id=5    mbps=175    seconds=3
    Start Traffic In DL    ue_id=${ue_id}    qfi_id=1    trf_id=6    mbps=175    seconds=3
    Start Traffic In DL    ue_id=${ue_id}    qfi_id=1    trf_id=7    mbps=175    seconds=3
    Sleep  1s
    ${output}   wts_ue.Send Egate Command And Verify Output   cmd=ue_nr_stats id=${ue_id} type=pdsch,pusch scell=0,1
    Log    ${output}    console=yes

    Sleep  3s

    #--- Deregister UEs -------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue.UE Deregister    ue_id=${ue_id}


A_B3_TC01_IntragNB_A1_UL_SCell_change_power_class
    [Arguments]  ${seconds}=3
    ${ue_id}=    Get Not Attached UEs
    CB013392.Initialize Egate
    #--- Register UE    -------------------------------------------------------------------------------------------------------------[150 characters]
    CB013392.Register UE Collect RRC  ${ue_id}  pdu=1  gw=1

    # Trigger A1 event to add TDD scell
    CB013392.Trigger A1 Tdd Scell Addition  ${ue_id}    meas_id=5    threshold=100

    # Trigger A1 event to add FDD scell
    CB013392.Trigger A1 Fdd Scell Addition  ${ue_id}    meas_id=7    threshold=120

    #--- Start Traffic UE1 ----------------------------------------------------------------------------------------------------------[150 characters]
    Sleep  1s
    Start Traffic In UL    ue_id=${ue_id}    qfi_id=1    trf_id=2    mbps=50     seconds=${seconds}
    Start Traffic In DL    ue_id=${ue_id}    qfi_id=1    trf_id=4    mbps=175    seconds=${seconds}
    Start Traffic In DL    ue_id=${ue_id}    qfi_id=1    trf_id=5    mbps=175    seconds=${seconds}
    Start Traffic In DL    ue_id=${ue_id}    qfi_id=1    trf_id=6    mbps=175    seconds=${seconds}
    Start Traffic In DL    ue_id=${ue_id}    qfi_id=1    trf_id=7    mbps=175    seconds=${seconds}
    Start Traffic In DL    ue_id=${ue_id}    qfi_id=1    trf_id=8    mbps=150    seconds=${seconds}
    Sleep  1s
    ${output}   wts_ue.Send Egate Command And Verify Output   cmd=ue_nr_stats id=${ue_id} type=pdsch,pusch scell=0,1
    Log    ${output}    console=yes

    Sleep  3s

    #--- Deregister UEs -------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue.UE Deregister    ue_id=${ue_id}


A_B5_TC01_IntragNB_A2_UL_SCell_release_power_class
    ${ue_id}=    Get Not Attached UEs
    CB013392.Initialize Egate
    #--- Register UE    -------------------------------------------------------------------------------------------------------------[150 characters]
    CB013392.Register UE Collect RRC  ${ue_id}  pdu=1  gw=1

    # Trigger A1 event to add scell
    CB013392.Trigger A1 Fdd Scell Addition  ${ue_id}

    #  Trigger A2 event to release scell
    CB013392.Trigger A2 Scell Release  ${ue_id}    scell_idx=1

    Sleep  1s

    #--- Start Traffic UE1 ----------------------------------------------------------------------------------------------------------[150 characters]
    # temporarily commented out due to TTI/PMC log issue; not needed for feature verification
    # Start Traffic In UL    ue_id=${ue_id}    qfi_id=1    trf_id=2    mbps=50     seconds=3
    # Start Traffic In DL    ue_id=${ue_id}    qfi_id=1    trf_id=4    mbps=150    seconds=3
    # Start Traffic In DL    ue_id=${ue_id}    qfi_id=1    trf_id=5    mbps=150    seconds=3
    # Sleep  1s
    # ${output}   wts_ue.Send Egate Command And Verify Output   cmd=ue_nr_stats id=${ue_id} type=pdsch,pusch scell=0,1
    # Log    ${output}    console=yes

    # Sleep  3s

    #--- Deregister UEs -------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue.UE Deregister    ue_id=${ue_id}


A_B6_TC01_power_limitation_with_pMaxNROwnCell_without_CA
    ${ue_id}=    Get Not Attached UEs
    CB013392.Initialize Egate
    #--- Register UE    -------------------------------------------------------------------------------------------------------------[150 characters]
    CB013392.Register UE Collect RRC  ue_id=${ue_id}  pdu=1  gw=1

    Sleep  1s

    #--- Start Traffic UE1 ----------------------------------------------------------------------------------------------------------[150 characters]
    Start Traffic In UL    ue_id=${ue_id}    qfi_id=1    trf_id=2    mbps=50     seconds=3    pdu=1
    Start Traffic In DL    ue_id=${ue_id}    qfi_id=1    trf_id=4    mbps=150    seconds=3    pdu=1
    Start Traffic In DL    ue_id=${ue_id}    qfi_id=1    trf_id=5    mbps=150    seconds=3    pdu=1
    Sleep  1s
    ${output}   wts_ue.Send Egate Command And Verify Output   cmd=ue_nr_stats id=${ue_id}
    Log    ${output}    console=yes

    Sleep  3s

    #--- Deregister UEs -------------------------------------------------------------------------------------------------------------[150 characters]
    wts_ue.UE Deregister    ue_id=${ue_id}


Get Not Attached UEs
    ${non_attached_ues_dict}=  Get Attach List    scenario_name=${scenario_name}    ue_type=sa    with_auto_attach=${FALSE}
    ${non_attached_ues_list}=  Collections.Get Dictionary Keys  ${non_attached_ues_dict}

    RETURN    ${non_attached_ues_list}[0]


Start Traffic In DL
    [Arguments]  ${ue_id}  ${qfi_id}  ${trf_id}  ${mbps}  ${seconds}  ${pdu}=2
    &{kwargs}=    Create Dictionary    mbps=${mbps}    pdu=${pdu}    qfi=${qfi_id}    seconds=${seconds}
    wts_ue.Start Data Traffic In Egate    ue_id=${ue_id}
    ...                                     direction=dl
    ...                                     protocol=udp
    ...                                     ack_mode=off
    ...                                     trf_id=${trf_id}
    ...                                     cl_trf_stats=on
    ...                                     &{kwargs}


Start Traffic In UL
    [Arguments]  ${ue_id}  ${qfi_id}  ${trf_id}  ${mbps}  ${seconds}  ${pdu}=2
    &{kwargs}=    Create Dictionary    mbps=${mbps}    pdu=${pdu}    qfi=${qfi_id}    seconds=${seconds}
    wts_ue.Start Data Traffic In Egate    ue_id=${ue_id}
    ...                                     direction=ul
    ...                                     protocol=udp
    ...                                     ack_mode=off
    ...                                     trf_id=${trf_id}
    ...                                     cl_trf_stats=on
    ...                                     &{kwargs}
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]