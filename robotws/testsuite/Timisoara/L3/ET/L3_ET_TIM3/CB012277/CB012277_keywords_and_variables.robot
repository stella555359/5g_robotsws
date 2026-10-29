*** Settings ***

Resource   ../resources/5G_SW_WRO_Keywords.robot

*** Variables ***

${TRF_DURATION}=        600
${UE_ID_A_B4}=    12
${UE_ID_A_B1}=    31-33
#${UE_ID_A_B3_4}=    13
#${UE_ID}=    11
${EXPECTED_NRREL_OBJECTID}=    256

${NRREL_OBJECT_CREATION_TIME} =    120
${NRREL_ID} =    256
${CELL_1} =    50
${CELL_2} =    51
${CELL_3} =    150
${NRRRC_MCC} =    nr-rrc.MCC_MNC_Digit == 3 && nr-rrc.MCC_MNC_Digit == 1 && nr-rrc.MCC_MNC_Digit == 1
${NRRRC_MNC} =    nr-rrc.MCC_MNC_Digit == 4 && nr-rrc.MCC_MNC_Digit == 8 && nr-rrc.MCC_MNC_Digit == 9
${NRCGI_REPORT_SUPPORTED_IN_ENDC_MODE} =    nr-rrc.nr_CGI_Reporting_ENDC == 0

${CGI_INFO}=    ${X2AP_SGNB_CHANGE_REQUIRED} && nr-rrc.physCellId == 384 && nr-rrc.cgi_Info_element
...  && nr-rrc.PLMN_Identity_element && nr-rrc.cellIdentity && nr-rrc.cellReservedForOperatorUse

${CGI_INFO_PCI_150}=    ${X2AP_SGNB_CHANGE_REQUIRED} && nr-rrc.physCellId == 150 && nr-rrc.cgi_Info_element
...  && nr-rrc.PLMN_Identity_element && nr-rrc.cellIdentity && nr-rrc.cellReservedForOperatorUse

${VM_ETH_IFACES}=    sudo ip addr add 10.0.2.1/24 dev eth4;
...  sudo ip addr add 10.0.1.121/24 dev eth3;
...  sudo ip addr add 10.0.1.122/24 dev eth3;
...  sudo ip addr add 10.0.1.123/24 dev eth3;
...  sudo ip addr add 10.0.1.124/24 dev eth3;
...  sudo ip addr add 10.0.1.125/24 dev eth3;
...  sudo ip addr add 10.0.1.126/24 dev eth3;
...  sudo ip addr add 10.0.1.127/24 dev eth3;
...  sudo ip addr add 10.0.1.128/24 dev eth3;
...  sudo ip addr add 10.0.1.129/24 dev eth3;
...  sudo ip addr add 10.0.1.130/24 dev eth3;
...  sudo ip addr add 10.0.1.131/24 dev eth3;
...  sudo ip addr add 10.0.1.132/24 dev eth3;
...  sudo ip addr add 10.0.1.133/24 dev eth3;
...  sudo ip addr add 10.0.1.134/24 dev eth3;
...  sudo ip addr add 10.0.1.135/24 dev eth3;
...  sudo ip addr add 10.0.1.136/24 dev eth3;
...  sudo ip addr add 10.0.1.137/24 dev eth3;
...  sudo ip addr add 10.0.1.138/24 dev eth3;
...  sudo ip addr add 10.0.1.139/24 dev eth3;
...  sudo ip addr add 10.0.1.140/24 dev eth3;
...  sudo ip addr add 10.0.1.141/24 dev eth3;
...  sudo ip addr add 10.0.1.142/24 dev eth3;
...  sudo ip addr add 10.0.1.143/24 dev eth3;
...  sudo ip addr add 10.0.1.144/24 dev eth3;
...  sudo ip addr add 10.0.1.145/24 dev eth3;
...  sudo ip addr add 10.0.1.146/24 dev eth3;
...  sudo ip addr add 10.0.1.147/24 dev eth3;
...  sudo ip addr add 10.0.1.148/24 dev eth3;
...  sudo ip addr add 10.0.1.149/24 dev eth3;
...  sudo ip addr add 10.0.1.150/24 dev eth3;
...  sudo ip addr add 10.0.1.151/24 dev eth3;
...  sudo ip addr add 10.0.1.152/24 dev eth3;
...  sudo ip addr add 10.0.1.153/24 dev eth3;
...  sudo ip addr add 10.0.1.154/24 dev eth3;
...  sudo ip addr add 10.0.1.155/24 dev eth3;
...  sudo ip addr add 10.0.1.161/24 dev eth3;
...  sudo ip addr add 10.0.1.162/24 dev eth3;
...  sudo ip addr add 10.0.1.163/24 dev eth3;
...  sudo ip addr add 10.0.2.90/24 dev eth4;
...  sudo ip addr add 10.0.2.91/24 dev eth4;
...  sudo ip addr add 10.0.2.92/24 dev eth4;
...  sudo ip addr add 10.0.2.93/24 dev eth4;
...  sudo ip addr add 10.0.2.94/24 dev eth4;
...  sudo ip addr add 10.0.2.95/24 dev eth4;
...  sudo ip addr add 10.0.2.96/24 dev eth4;
...  sudo ip addr add 10.0.2.97/24 dev eth4;
...  sudo ip addr add 10.0.2.98/24 dev eth4;
...  sudo ip addr add 10.0.2.99/24 dev eth4;
...  sudo ip addr add 10.0.2.100/24 dev eth4;
...  sudo ip addr add 10.0.1.9/24 dev eth3;
...  sudo ip addr add 10.0.1.10/24 dev eth3;
...  sudo ip addr add 10.0.1.11/24 dev eth3;
...  sudo ip addr add 10.0.1.12/24 dev eth3;
...  sudo ip addr add 10.0.1.13/24 dev eth3;
...  sudo ip addr add 10.0.1.14/24 dev eth3;
...  sudo ip addr add 10.0.1.15/24 dev eth3;
...  sudo ip addr add 10.0.1.100/24 dev eth3;
...  sudo ip addr add 10.0.1.101/24 dev eth3;
...  sudo ip addr add 10.0.1.102/24 dev eth3;
...  sudo ip addr add 10.0.1.103/24 dev eth3;
...  sudo ip addr add 10.0.1.104/24 dev eth3;
...  sudo ip addr add 10.0.1.105/24 dev eth3;
...  sudo ip addr add 10.0.1.106/24 dev eth3;
...  sudo ip addr add 10.0.1.107/24 dev eth3;
...  sudo ip addr add 10.0.1.108/24 dev eth3;
...  sudo ip addr add 10.0.1.109/24 dev eth3;
...  sudo ip addr add 10.0.1.3/24 dev eth3;
...  sudo ip addr add 10.0.1.4/24 dev eth3;
...  sudo ip addr add 10.0.1.112/24 dev eth3

*** Keywords ***

Setup X2 Link for gNB4
    Execute Egate Command    cmd=enb_x2_link_up enb=1 target=4    pass_regexp=X2AP Link with GNB-4 .* is up

UE Trigger InterGnb InterFreq Ho
    [Arguments]    ${ue_id}=92
    UE Attach and Initial ENDC to Target Cell    ue_id=${ue_id}    target_gnb=2    target_cell=1    pci=50
    Send Throughput     ue_id=${ue_id}
    UE InterGnb Ho to Simulate gNB4 cell4    ue_id=${ue_id}

UE Attach and Initial ENDC to Target Cell
    [Arguments]    ${ue_id}=91    ${target_gnb}=2    ${target_cell}=1    ${pci}=50
    Execute Egate Command    cmd=ue_attach id=${ue_id}    pass_regexp=UE IS ACTIVE
    ${dc_success}    Set Variable    UE${ue_id}: Successfully reconfigured dual connectivity
    Execute Egate Command
    ...    cmd=ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb} target_cells=${target_cell} bearer=2 type=split_scg
    ...    pass_regexp=${dc_success}

Send Throughput
    [Arguments]    ${ue_id}=91
    Execute Egate Command    cmd=data_trf_start ue=${ue_id} id=2 dir=dl mbps=5    pass_regexp=UE ${ue_id}: UDP DL
    Execute Egate Command    cmd=data_trf_start ue=${ue_id} id=2 dir=ul mbps=5    pass_regexp=UE ${ue_id}: UDP UL

Trigger A2 Event
    [Arguments]    ${ue_id}    ${ssbFrequncy}    ${pass_regexp}
    Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=A2 srsrp_nr=7 srsrq_nr=7
    ...    pass_regexp=${pass_regexp}

Trigger A5 Event
    [Arguments]    ${ue_id}    ${pci}    ${ssbFrequncy}    ${pass_regexp}
    Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=3 event=A5 srsrp_nr=11 srsrq_nr=11 phycell_id=${pci} nrsrp_nr=60 nrsrq_nr=60
    ...    pass_regexp=${pass_regexp}

UE InterGnb Ho to Simulate gNB4 cell4
    [Arguments]    ${ue_id}=92
    ${a2_interGnb_ho}    Set Variable    SgNBModificationConfirm
    Trigger A2 Event    ue_id=${ue_id}    ssbFrequncy=636576    pass_regexp=${a2_interGnb_ho}
    ${a5_interGnb_ho}    Set Variable    Bearer-type change from MCG to SCG-split is successful
    Trigger A5 Event     ue_id=${ue_id}    pci=384    ssbFrequncy=2071387    pass_regexp=${a5_interGnb_ho}

Verify Successful Inter Gnb Pscell Change
    Verify Ngap Messages    packet_filter=${X2AP_SGNB_CHANGE_REQUIRED}
    Verify Ngap Messages    packet_filter=${X2AP_SGNB_CHANGE_CONFIRM}
    Verify Ngap Messages    packet_filter=${SN_STATUS_TRANSFER} && ip.src == 10.0.1.2
    Verify Ngap Messages    packet_filter=${X2AP_SGNB_ADDITION_REQUEST}
    Verify Loopback Messages    packet_filter=${X2AP_SGNB_ADDITION_REQUEST_ACKNOWLEDGE} && nr-rrc.physCellId == 150
    Verify Loopback Messages    packet_filter=${X2AP_SGNB_RECONFIGURATION_COMPLETE}
    Verify Loopback Messages    packet_filter=${SN_STATUS_TRANSFER}
    Verify Ngap Messages    packet_filter=${X2AP_UE_CONTEXT_RELEASE}
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMMAND}
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMPLETE}


Verify Created NRADJNRCELL And NRREL Objects
    Wait For Object To Exist    object_name=NRADJNRCELL_A-12288    moc=NRADJNRCELL_A    timeout=${NRREL_OBJECT_CREATION_TIME}
    Wait For Object To Exist    object_name=NRCELL_A-1/NRREL_A-${NRREL_ID}    moc=NRREL_A    timeout=${NRREL_OBJECT_CREATION_TIME}
    &{NRADJNRCELL}=    Get Managed Object    object_name=NRADJNRCELL_A-12288    moc=NRADJNRCELL_A
    &{NRREL}=    Get Managed Object    object_name=NRCELL_A-1/NRREL_A-${NRREL_ID}    moc=NRREL_A
    Verify Created NRREL Object    NRREL=&{NRREL}    mcc=${NRADJNRCELL.gnbPlmn.mcc}    mnc=${NRADJNRCELL.gnbPlmn.mnc}
    ...                            mncLength=${NRADJNRCELL.gnbPlmn.mncLength}    gNbId=3    gNbIdLength=${NRADJNRCELL.gNbIdLength}
    ...                            lcrId=${NRADJNRCELL.lcrId}
    Verify Created NRADJNRCELL Object    NRADJNRCELL=&{NRADJNRCELL}    mcc=311    mnc=489    mncLength=3    physCellId=150    cellDepType=SA+NSA
    ...                                  nrarfcn=636666    ssbFrequency=636576    gNbId=3    gNbIdLength=22    lcrId=1

Start Vm Ethernet Interfaces
    Start Vm Ethernet Interface    if_name=eth3:gNB2_XN    ip_with_mask=10.0.1.101/24
    Start Vm Ethernet Interface    if_name=eth3:gNB2_NG    ip_with_mask=10.0.1.102/24
    Start Vm Ethernet Interface    if_name=eth3:S1U_1296    ip_with_mask=10.0.1.21/24
    Start Vm Ethernet Interface    if_name=eth3:S11_1296    ip_with_mask=10.0.1.22/24
    Start Vm Ethernet Interface    if_name=eth3:gNB2_X2    ip_with_mask=10.0.1.3/24

Stop Vm Ethernet Interfaces
    Stop Vm Ethernet Interface    if_name=eth3:gNB2_XN    ip_with_mask=10.0.1.101/24
    Stop Vm Ethernet Interface    if_name=eth3:gNB2_NG    ip_with_mask=10.0.1.102/24
    Stop Vm Ethernet Interface    if_name=eth3:S1U_1296    ip_with_mask=10.0.1.21/24
    Stop Vm Ethernet Interface    if_name=eth3:S11_1296    ip_with_mask=10.0.1.22/24
    Stop Vm Ethernet Interface    if_name=eth3:gNB2_X2    ip_with_mask=10.0.1.3/24

Attach UE To Enb And Gnb
    [Arguments]    ${ue_id}    ${target_cell}=1
    Attach Ue To Enb    ue_id=${ue_id}    optional_parameters=profile=1
    Start Gnb Addition Procedure    ue=${ue_id}    target_gnb=2    target_cells=${target_cell}    bearer=2    dc_type=split_scg
    ...                             pass_regexp=Proxy \\(eNB 2 cell ${target_cell}\\) reported successful RA
    Sleep    10    reason=Waiting For SN Status Transfer

Verify UE Supports NRCGI Report
    Verify Ngap Messages       packet_filter=${X2AP_SGNB_ADDITION_REQUEST} && ${NRCGI_REPORT_SUPPORTED_IN_ENDC_MODE}

X2 Link for simulated gNB
    Execute Egate Command    cmd=enb_x2_link_up enb=1 target=3

Perform Data Traffic for 10 Minutes
    Start Data Traffic
    ...     ues=${UE_ID_A_B1}
    ...     bearer_id=2
    ...     direction=both
    ...     throughput=10mbps
    ...     traffic_period=${TRF_DURATION}

Verify Existing NRREL
    Wait For Object To Exist    object_name=NRCELL_A-1/NRREL_A-${EXPECTED_NRREL_OBJECTID}    moc=NRREL_A    timeout=${NRREL_OBJECT_CREATION_TIME}

Verify Not Existing NRREL
    Wait For Object To Not Exist    object_name=NRCELL_A-1/NRREL_A-${EXPECTED_NRREL_OBJECTID}    moc=NRREL_A    timeout=${NRREL_OBJECT_CREATION_TIME}

Perform Multiple NSA UEs call
    [Arguments]    ${ue_id}  ${target_cell}  ${target_gnb}
    Attach Ue To Enb    ue_id=${ue_id}
    Start Gnb Addition Procedure
    ...    ue=${ue_id}
    ...    target_cells=${target_cell}
    ...    target_gnb=${target_gnb}
    ...    bearer=2
    ...    dc_type=split_scg

Perform NSA call for UEs ID31-33
    FOR    ${index}    IN RANGE    31    34
        Perform Multiple NSA UEs call    ue_id=${index}  target_cell=1   target_gnb=2
    END

Perform A3 event HO for UEs ID31-33
    FOR    ${index}    IN RANGE    31    34
        Send Custom Ue Measurement Nr    id=${index}    meas_id=1    event=A3    srsrp_nr=11    phycell_id=381    nrsrp_nr=30
    ...                              pass_regexp=Bearer-type change from MCG to SCG-split is successful
    ...                              timeout=10
    END

Perform Detach for UEs ID31-33
    FOR    ${index}    IN RANGE    31    34
        Detach Ue    ue_id=${index}
    END

