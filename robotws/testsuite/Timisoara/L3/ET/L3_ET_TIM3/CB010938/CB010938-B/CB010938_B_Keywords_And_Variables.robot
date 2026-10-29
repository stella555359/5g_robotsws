*** Settings ***

Documentation    :copyright: Nokia

Resource     ../../resources/5G_SW_WRO_Keywords.robot
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_enb
Library      ta5g_ue_measurements
Library      ta5g_pm_counters
Library      ta5g_cell_operations
Library      ta5g_delta
Library      ta_pcmd
Library      ute_reporting_portal

*** Variables ***
${custom-scf-TC11-B_PMO}    ${CURDIR}/../../resources/custom-config/CB010938_B_2_CELLS_SANSA_TDD/gNB_scf_ASIL_ABIO_TDD_N78.xml
${custom-iphy-TC11-C_PMO}   ${CURDIR}/../../resources/custom-config/CB010938_B_2_CELLS_SANSA_TDD/AP_iphy_AEQE_AEQE_ASIL_ABIO_TDD_N78.xml
${iphy-init}                ${CURDIR}/config/iphy_init.xml

${VM_ETH_IFACES}=    sudo ip address add 10.0.1.131/24 dev eth3;
...    sudo ip address add 10.0.1.132/24 dev eth3;
...    sudo ip address add 10.0.1.133/24 dev eth3;
...    sudo ip address add 10.0.1.134/24 dev eth3;
...    sudo ip address add 10.0.1.135/24 dev eth3;
...    sudo ip address add 10.0.1.136/24 dev eth3;
...    sudo ip address add 10.0.1.137/24 dev eth3;
...    sudo ip address add 10.0.1.121/24 dev eth3;
...    sudo ip address add 10.0.1.3/24 dev eth3;
...    sudo ip address add 10.0.1.4/24 dev eth3;
...    sudo ip address add 10.0.1.102/24 dev eth3;
...    sudo ip address add 10.0.1.101/24 dev eth3;

${VM_ETH_IFACES_2}=    sudo ip addr add 10.0.2.1/24 dev eth4;
...  sudo ip addr add 10.0.1.122/24 dev eth3;
...  sudo ip addr add 10.0.1.123/24 dev eth3;
...  sudo ip addr add 10.0.1.124/24 dev eth3;
...  sudo ip addr add 10.0.1.125/24 dev eth3;
...  sudo ip addr add 10.0.1.126/24 dev eth3;
...  sudo ip addr add 10.0.1.127/24 dev eth3;
...  sudo ip addr add 10.0.1.128/24 dev eth3;
...  sudo ip addr add 10.0.1.129/24 dev eth3;
...  sudo ip addr add 10.0.1.130/24 dev eth3;
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
...  sudo ip addr add 10.0.1.103/24 dev eth3;
...  sudo ip addr add 10.0.1.104/24 dev eth3;
...  sudo ip addr add 10.0.1.105/24 dev eth3;
...  sudo ip addr add 10.0.1.106/24 dev eth3;
...  sudo ip addr add 10.0.1.107/24 dev eth3;
...  sudo ip addr add 10.0.1.108/24 dev eth3;
...  sudo ip addr add 10.0.1.109/24 dev eth3;
...  sudo ip addr add 10.0.1.112/24 dev eth3;
...  sudo ip addr add 10.0.1.113/24 dev eth3

${custom-scf-TC17}    ${CURDIR}/config/SCF_CB010938_B_TC17.xml

${infra_info_TC17}    (ngap.NGAP_PDU && (nr-rrc.c1 && (nr-rrc.ue_CapabilityRAT_Container && (nr-rrc.appliedFreqBandListFilter &&
...    (nr-rrc.FreqBandInformation == 0 && (nr-rrc.bandEUTRA == 200 &&
...    nr-rrc.ca_BandwidthClassDL_EUTRA == 5 && nr-rrc.ca_BandwidthClassUL_EUTRA == 5))))))

${chipset_info_TC17}    nr-rrc.ueCapabilityInformation_element && nr-rrc.ue_CapabilityRAT_ContainerList &&
...    nr-rrc.UE_CapabilityRAT_Container_element && nr-rrc.ue_CapabilityRAT_Container && (nr-rrc.UE_NR_Capability_element &&
...    (nr-rrc.mac_Parameters_element && (nr-rrc.mac_ParametersCommon_element && nr-rrc.mAC_ParametersCommon.dummy == 0))
...    && (nr-rrc.rf_Parameters_element && (nr-rrc.supportedBandListNR && (nr-rrc.BandNR_element && nr-rrc.bandNR == 78
...    && nr-rrc.mIMO_ParametersPerBand.dummy4_element && (nr-rrc.burstLength == 1 && nr-rrc.maxSimultaneousResourceSetsPerCC == 5
...    && nr-rrc.maxConfiguredResourceSetsPerCC == 37)))))

${custom-scf-TC15}    ${CURDIR}/config/SCF_CB010938_B_TC15.xml

${HandoverRequiredFilter}=   ngap.HandoverRequired_element && nr-rrc.mAC_ParametersCommon.dummy == 0 && nr-rrc.burstLength == 1
...    && nr-rrc.maxSimultaneousResourceSetsPerCC == 5 && nr-rrc.maxConfiguredResourceSetsPerCC == 37
...    && nr-rrc.maxConfiguredResourceSetsAllCC == 12 && nr-rrc.bandEUTRA == 200 && nr-rrc.bandEUTRA == 201
...    && nr-rrc.bandEUTRA == 202 && nr-rrc.ca_BandwidthClassDL_EUTRA == 0 && nr-rrc.ca_BandwidthClassUL_EUTRA == 3
...    && nr-rrc.ca_BandwidthClassUL_EUTRA == 4

${HO_request_chipset_infra_info_TC11}    xnap.HandoverRequest_element && nr-rrc.HandoverPreparationInformation_element &&
...    nr-rrc.ue_CapabilityRAT_List && (nr-rrc.UE_NR_Capability_element && (nr-rrc.mac_Parameters_element && (nr-rrc.mac_ParametersCommon_element
...    && nr-rrc.mAC_ParametersCommon.dummy == 0)) && (nr-rrc.rf_Parameters_element && (nr-rrc.appliedFreqBandListFilter &&
...    ((nr-rrc.FreqBandInformation == 0 && nr-rrc.bandInformationEUTRA_element && (nr-rrc.bandEUTRA == 200 && nr-rrc.ca_BandwidthClassDL_EUTRA == 5
...    && nr-rrc.ca_BandwidthClassUL_EUTRA == 5)) && (nr-rrc.FreqBandInformation == 0 && nr-rrc.bandInformationEUTRA_element &&
...    (nr-rrc.bandEUTRA == 201 && nr-rrc.ca_BandwidthClassDL_EUTRA == 0 && nr-rrc.ca_BandwidthClassUL_EUTRA == 5)) &&
...    (nr-rrc.FreqBandInformation == 0 && nr-rrc.bandInformationEUTRA_element && (nr-rrc.bandEUTRA == 202 && nr-rrc.ca_BandwidthClassDL_EUTRA == 0
...    && nr-rrc.ca_BandwidthClassUL_EUTRA == 5))))))

${UECapabilityEnquiry_Infra_Info_TC11}    (nr-rrc.ueCapabilityEnquiry_element && (nr-rrc.ue_CapabilityRAT_RequestList &&
...    (nr-rrc.UE_CapabilityRAT_Request_element && (nr-rrc.capabilityRequestFilter && (nr-rrc.UE_CapabilityRequestFilterNR_element &&
...    (nr-rrc.frequencyBandListFilter && (nr-rrc.FreqBandInformation == 0 && (nr-rrc.bandEUTRA == 200 && nr-rrc.ca_BandwidthClassDL_EUTRA == 0
...    && nr-rrc.ca_BandwidthClassUL_EUTRA == 3) && (nr-rrc.bandEUTRA == 201 && nr-rrc.ca_BandwidthClassDL_EUTRA == 0
...    && nr-rrc.ca_BandwidthClassUL_EUTRA == 4) && (nr-rrc.bandEUTRA == 202 && nr-rrc.ca_BandwidthClassDL_EUTRA == 0
...    && nr-rrc.ca_BandwidthClassUL_EUTRA == 4))))))))

${UECapabilityInformation_Chipset_Info_TC11}    nr-rrc.ueCapabilityInformation_element && nr-rrc.ue_CapabilityRAT_ContainerList &&
...    nr-rrc.UE_CapabilityRAT_Container_element && nr-rrc.ue_CapabilityRAT_Container && (nr-rrc.UE_NR_Capability_element &&
...    (nr-rrc.mac_Parameters_element && (nr-rrc.mac_ParametersCommon_element && nr-rrc.mAC_ParametersCommon.dummy == 0)))

${UERadioCapabilityInfoIndication_Chipset_Infra_Info_TC11}    ngap.UERadioCapabilityInfoIndication_element && (nr-rrc.UE_NR_Capability_element
...    && (nr-rrc.mac_Parameters_element && (nr-rrc.mac_ParametersCommon_element && nr-rrc.mAC_ParametersCommon.dummy == 0)) &&
...    (nr-rrc.rf_Parameters_element && (nr-rrc.appliedFreqBandListFilter && ((nr-rrc.FreqBandInformation == 0 &&
...    nr-rrc.bandInformationEUTRA_element && (nr-rrc.bandEUTRA == 200 && nr-rrc.ca_BandwidthClassDL_EUTRA == 5
...    && nr-rrc.ca_BandwidthClassUL_EUTRA == 5)) && (nr-rrc.FreqBandInformation == 0 && nr-rrc.bandInformationEUTRA_element &&
...    (nr-rrc.bandEUTRA == 201 && nr-rrc.ca_BandwidthClassDL_EUTRA == 0 && nr-rrc.ca_BandwidthClassUL_EUTRA == 5)) &&
...    (nr-rrc.FreqBandInformation == 0 && nr-rrc.bandInformationEUTRA_element && (nr-rrc.bandEUTRA == 202 && nr-rrc.ca_BandwidthClassDL_EUTRA == 0
...    && nr-rrc.ca_BandwidthClassUL_EUTRA == 5))))))

*** Keywords ***
Perform SA call without traffic
    [Arguments]     ${ue_id}
    Execute Egate Command   cmd=set_pdu_param ue=${ue_id} pdu=${ue_id} trf_type=internal
    Attach Ue    ue_id=${ue_id}
    Establish Pdu Session    ue_id=${ue_id}    pdu_id=${ue_id}    gw_id=${ue_id}

Send A5 MR to trigger interGNB intraFreqHo with blind Scell Addition
    [Arguments]    ${ue_id}    ${target_pci}    ${meas_id}
    ${command}    Set Variable    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A5 srsrp_nr=10 phycell_id=${target_pci} nrsrp_nr=40

Attach UE And Establish PDU Session
    [Arguments]    ${ue_id}    ${pdu_id}    ${gw_id}
    Attach Ue    ue_id=${ue_id}    pass_regexp=Received REGISTRATION COMPLETE from UE with RAN UE NGAP ID \\d+ and AMF UE NGAP ID \\d+
    Establish PDU Session    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}

Perform InterRAT HO
    Prepare interRAT HO    ue_id=1
    Sleep    5
    Verify Measurement is configured    event=B2    ue_id=1
    Send Custom Ue Measurement Nr    id=1    meas_id=3    event=B2    phycell_id=11    nrsrp_nr=19    nrsrq_nr=17
        ...                              pass_regexp=IRAT Handover from NR to EUTRA completed
        ...                              timeout=10

Prepare interRAT HO
    [Arguments]    ${ue_id}
    Execute egate command    cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=A2

Verify Measurement is configured
    [Arguments]  ${event}  ${ue_id}
    Execute egate command    cmd=ue_meas_cfg_disp id=${ue_id}  pass_regexp=Event${event}

Setup wireshark
    [Arguments]       ${preferences}
    Run  chmod 777 /home/ute/.config/wireshark/preferences
    ${output1}  Run  cp -f ${preferences} /home/ute/.config/wireshark/preferences
    Should Not Contain  ${output1}  No such file or directory
