*** Settings ***
Resource     keywords_CB008490.robot
Variables    keywords_CB008490.py

Documentation
...    author: Mariusz Waczynski
...    maintainer: Marcin Kotula (marcin.kotula@nokia.com)
...    release: 25R3

*** Variables ***
${TRAFFIC_DURATION_SEC_L_B2}=   30s
${TRAFFIC_DURATION_BEFORE_PSCELL_SEC_L_B2}=   20s

*** Keywords ***
CB008490-L_B2_Handling_of_the_UE-Capability_pdcch-BlindDetection_in_the_SCG
    Change Ue Capa Blind Detection CA To 5
    Register Nrdc Ue With Default Pdu Session
    Start Udp Traffic 300Mbps In DL    traffic_duration=${TRAFFIC_DURATION_BEFORE_PSCELL_SEC_L_B2}
    Set expected message flow for A4 meas inter-gNB PSCell Addition For UE1 GNB3 during SN-initiated SNodeMod procedure
    Send A4 Measurement And Trigger Pscell Addition
    Verify expected message flow for A4 meas inter-gNB PSCell Addition For UE1 GNB3 during SN-initiated SNodeMod procedure
    Sleep    5s
    Start Traffic 450Mbps In DL    traffic_duration=${TRAFFIC_DURATION_SEC_L_B2}
    Ue Should Be Connected To 4CC
    Deregister First Ue

    Change Ue Capa Blind Detection CA To 9
    Register Nrdc Ue With Default Pdu Session
    Start Udp Traffic 300Mbps In DL    traffic_duration=${TRAFFIC_DURATION_BEFORE_PSCELL_SEC_L_B2}
    Set expected message flow for A4 meas inter-gNB PSCell Addition For UE1 GNB3 during SN-initiated SNodeMod procedure
    Send A4 Measurement And Trigger Pscell Addition
    Verify expected message flow for A4 meas inter-gNB PSCell Addition For UE1 GNB3 during SN-initiated SNodeMod procedure
    Sleep    5s
    Start Traffic 450Mbps In DL    traffic_duration=${TRAFFIC_DURATION_SEC_L_B2}
    Ue Should Be Connected To 8CC
    Deregister First Ue

    Change Ue Capa Blind Detection CA To 4
    Register Nrdc Ue With Default Pdu Session
    Start Udp Traffic 300Mbps In DL    traffic_duration=${TRAFFIC_DURATION_BEFORE_PSCELL_SEC_L_B2}
    Set expected message flow for A4 meas inter-gNB PSCell Addition For UE1 GNB3 during SN-initiated SNodeMod procedure
    Send A4 Measurement And Trigger Pscell Addition
    Verify expected message flow for A4 meas inter-gNB PSCell Addition For UE1 GNB3 during SN-initiated SNodeMod procedure
    Sleep    5s
    Start Traffic 450Mbps In DL    traffic_duration=${TRAFFIC_DURATION_SEC_L_B2}
    Ue Should Be Connected To 6CC
    Deregister First Ue

    Change Ue Capa Blind Detection CA To 5 And Nrdc
    Register Nrdc Ue With Default Pdu Session
    Start Udp Traffic 300Mbps In DL    traffic_duration=${TRAFFIC_DURATION_BEFORE_PSCELL_SEC_L_B2}
    Set expected message flow for A4 meas inter-gNB PSCell Addition For UE1 GNB3 during SN-initiated SNodeMod procedure
    Send A4 Measurement And Trigger Pscell Addition
    Verify expected message flow for A4 meas inter-gNB PSCell Addition For UE1 GNB3 during SN-initiated SNodeMod procedure
    Sleep    5s
    Start Traffic 450Mbps In DL    traffic_duration=${TRAFFIC_DURATION_SEC_L_B2}
    Ue Should Be Connected To 8CC
    Deregister First Ue

    Change Ue Capa Without Blind Detection CA And Only Nrdc Present
    Register Nrdc Ue With Default Pdu Session
    Start Udp Traffic 300Mbps In DL    traffic_duration=${TRAFFIC_DURATION_BEFORE_PSCELL_SEC_L_B2}
    Set expected message flow for A4 meas inter-gNB PSCell Addition For UE1 GNB3 during SN-initiated SNodeMod procedure
    Send A4 Measurement And Trigger Pscell Addition
    Verify expected message flow for A4 meas inter-gNB PSCell Addition For UE1 GNB3 during SN-initiated SNodeMod procedure
    Sleep    5s
    Start Traffic 450Mbps In DL    traffic_duration=${TRAFFIC_DURATION_SEC_L_B2}
    Ue Should Be Connected To 8CC
    Deregister First Ue

Verify Successful 8CC SCell Addition for UE${ue_id}
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 That sCellIndex Is Equal To ${sCellIndexes_8CC} In CG-Config For GNB2
    Verify In RRC RRCReconfiguration_1 Out Of 1 That List sCellToAddModList Has 7 Element/s For UE${ue_id}

Verify That Traffic Is Scheduled On All SCells In Group
    [Arguments]    ${ue_id}=1    ${cell_index_min}=0    ${cell_index_max}=3    ${cell_group}=MCG    ${type}=pdsch
    ${num_of_cells_on_MN_and_SN}=    Evaluate        int(${cell_index_max}) + int(1)
    ${num_of_cells_if_only_SN}=      Set variable    ${cell_index_max}
    ${num_of_cells}=                 Set variable if
    ...     '${cell_index_min}' == '0'    ${num_of_cells_on_MN_and_SN}    ${num_of_cells_if_only_SN}
    Execute Egate Command And Wait For Data
        ...          cmd=ue_stats_nr id=${ue_id} cell_group=${cell_group} type=${type} scell=${cell_index_min}-${cell_index_max}
        ...          pass_regexp=(CellIndex-[${cell_index_min}-${cell_index_max}][\\s][\\s][1-9].*\\n){${num_of_cells}}

Change Ue Capa Blind Detection CA To 5
    Execute Egate Command    cmd=ue_param id=1 ue_nr_capabilities=${UE_CAPA_PDCCH_BLIND_DETECTION_CA_5_WITHOUT_NRDC}

Change Ue Capa Blind Detection CA To 9
    Execute Egate Command    cmd=ue_param id=1 ue_nr_capabilities=${UE_CAPA_PDCCH_BLIND_DETECTION_CA_9_WITHOUT_NRDC}

Change Ue Capa Blind Detection CA To 4
    Execute Egate Command    cmd=ue_param id=1 ue_nr_capabilities=${UE_CAPA_PDCCH_BLIND_DETECTION_CA_4_WITH_NRDC}

Change Ue Capa Blind Detection CA To 5 And Nrdc
    Execute Egate Command    cmd=ue_param id=1 ue_nr_capabilities=${UE_CAPA_PDCCH_BLIND_DETECTION_CA_5_WITH_NRDC}

Change Ue Capa Without Blind Detection CA And Only Nrdc Present
    Execute Egate Command    cmd=ue_param id=1 ue_nr_capabilities=${UE_CAPA_WITHOUT_PDCCH_BLIND_DETECTION_CA_AND_NRDC}

Ue Should Be Connected To 4CC
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 cell_group=SCG type=pdsch scell=1-8
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 cell_group=MCG type=pdsch scell=1-8
    Verify That Traffic Is Scheduled On All SCells In Group    ue_id=1    cell_group=SCG    cell_index_min=1    cell_index_max=4

Ue Should Be Connected To 8CC
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 cell_group=SCG type=pdsch scell=1-8
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 cell_group=MCG type=pdsch scell=1-8
    Verify That Traffic Is Scheduled On All SCells In Group    ue_id=1    cell_group=SCG    cell_index_min=1    cell_index_max=8

Ue Should Be Connected To 6CC
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 cell_group=SCG type=pdsch scell=1-8
    Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 cell_group=MCG type=pdsch scell=1-8
    Verify That Traffic Is Scheduled On All SCells In Group    ue_id=1    cell_group=SCG    cell_index_min=1    cell_index_max=6

Deregister First Ue
    Execute Egate Command    cmd=trf_data_stop ue=1 pdu=1
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=1 ue_deregister_type=switch_off
    Sleep    10s
