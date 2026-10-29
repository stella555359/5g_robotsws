*** Settings ***

Documentation    :copyright: Nokia

Resource     ../../resources/5G_SW_WRO_Keywords.robot
#Resource     keywords_pcap.robot
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_enb
Library      ta5g_ue_measurements
Library      ta5g_pm_counters
Library      ta5g_cell_operations
Library      ta5g_delta
Library      ta_pcmd
Library     OperatingSystem
Library     Process
Library     String
Library     ta5g_iperf_traffic
Library     ta5g_commissioning
Library     DateTime
Library     Telnet
Library     ute_wtssim
Library     ta5g_throughput
Library     ta5g_ue_mobility
Library     ta5g_egate
Library     ta5g_tshark
Library     ta5g_setups_and_teardowns
Library     SSHLibrary
Library     ta_a2a
Library     ta_messaging
Library     ute_admin_infomodel
Library     ute_reporting_portal

*** Variables ***
${custom-scf-TC02}    ${CURDIR}/config/SCF_CB010938_C_TC02.xml
${custom-iphy-TC02}   ${CURDIR}/config/new_iphy_TC02.xml
${TRF_DURATION}=        60
${ueCapabilityEnquiryFilter}=   nr-rrc.ueCapabilityEnquiry_element && nr-rrc.bandEUTRA == 200 && nr-rrc.bandEUTRA == 201 && nr-rrc.bandEUTRA == 202
...    && nr-rrc.ca_BandwidthClassDL_EUTRA == 0 && nr-rrc.ca_BandwidthClassUL_EUTRA == 3 && nr-rrc.ca_BandwidthClassUL_EUTRA == 4
${ueCapabilityInformationFilter}=   nr-rrc.ueCapabilityInformation_element && nr-rrc.mAC_ParametersCommon.dummy == 0
...    && nr-rrc.burstLength == 1 && nr-rrc.maxSimultaneousResourceSetsPerCC == 5 && nr-rrc.maxConfiguredResourceSetsPerCC == 64
...    && nr-rrc.maxConfiguredResourceSetsAllCC == 128

${custom-scf-TC03-C_B1}    ${CURDIR}/../../resources/custom-config/CB010938_C_2_CELLS_SANSA_TDD/gNB_scf_ASIM_ABIP_TDD_N78_N79_PCMD.xml
${custom-iphy-TC03-C_B1}   ${CURDIR}/../../resources/custom-config/CB010938_C_2_CELLS_SANSA_TDD/AP_iphy_AEQE_AZTA_ASIM_ABIP_TDD_N78_N79.xml
${iphy-init}               ${CURDIR}/config/iphy_init.xml

${custom-scf-gnb1-TC04-C_B2}    ${CURDIR}/../../resources/custom-config/CB010938_C_B2_TC04/SCF_TC04_C_B2_gnb1.xml
${custom-scf-gnb2-TC04-C_B2}    ${CURDIR}/../../resources/custom-config/CB010938_C_B2_TC04/SCF_TC04_C_B2_gnb2.xml
${custom-iphy-TC04-C_B2}   ${CURDIR}/../../resources/custom-config/CB010938_C_B2_TC04/AP_iphy_TC04_C_B2.xml
${iphy-init-TC04-C_B2}     ${CURDIR}/config/iphy_init_TC04_C_B2.xml
${scf-gnb1-init-TC04-C_B2}     ${CURDIR}/config/scf_init_gnb1.xml
${scf-gnb2-init-TC04-C_B2}     ${CURDIR}/config/scf_init_gnb2.xml

${TCE}    10.0.1.11
${GNB_X2_IP}    10.0.1.2

${PCMD_extended_chipset}    (nsetapx.ueInfoRecord && (nsetapx.chipsetInfo_element && (nsetapx.vendor_element &&
...    (nsetapx.part1 == 1 && nsetapx.part2 == 5)) && (nsetapx.version == 1 && (nsetapx.extended_element &&
...    (nsetapx.part1 == 2 && nsetapx.part2 == 7 && nsetapx.part3 == 23 && nsetapx.part4 == 1)))))

${UECapabilityEnquiry_Infra_Info}    (nr-rrc.ueCapabilityEnquiry_element && (nr-rrc.ue_CapabilityRAT_RequestList &&
...    (nr-rrc.UE_CapabilityRAT_Request_element && (nr-rrc.capabilityRequestFilter && (nr-rrc.UE_CapabilityRequestFilterNR_element &&
...    (nr-rrc.frequencyBandListFilter && (nr-rrc.FreqBandInformation == 0 && (nr-rrc.bandEUTRA == 200 && nr-rrc.ca_BandwidthClassDL_EUTRA == 0
...    && nr-rrc.ca_BandwidthClassUL_EUTRA == 3) && (nr-rrc.bandEUTRA == 201 && nr-rrc.ca_BandwidthClassDL_EUTRA == 0
...    && nr-rrc.ca_BandwidthClassUL_EUTRA == 4) && (nr-rrc.bandEUTRA == 202 && nr-rrc.ca_BandwidthClassDL_EUTRA == 0
...    && nr-rrc.ca_BandwidthClassUL_EUTRA == 4))))))))

${UECapabilityInformation_Extended_Chipset_Info}    nr-rrc.ueCapabilityInformation_element && nr-rrc.ue_CapabilityRAT_ContainerList &&
...    nr-rrc.UE_CapabilityRAT_Container_element && nr-rrc.ue_CapabilityRAT_Container && (nr-rrc.UE_NR_Capability_element &&
...    (nr-rrc.mac_Parameters_element && (nr-rrc.mac_ParametersCommon_element && nr-rrc.mAC_ParametersCommon.dummy == 0))
...    && (nr-rrc.rf_Parameters_element && (nr-rrc.supportedBandListNR && (nr-rrc.BandNR_element && nr-rrc.bandNR == 78
...    && nr-rrc.mIMO_ParametersPerBand.dummy4_element && (nr-rrc.burstLength == 1 && nr-rrc.maxSimultaneousResourceSetsPerCC == 5
...    && nr-rrc.maxConfiguredResourceSetsPerCC == 64 && nr-rrc.maxConfiguredResourceSetsAllCC == 128)) && (nr-rrc.BandNR_element
...    && nr-rrc.bandNR == 79 && nr-rrc.mIMO_ParametersPerBand.dummy4_element && (nr-rrc.burstLength == 2
...    && nr-rrc.maxSimultaneousResourceSetsPerCC == 7 && nr-rrc.maxConfiguredResourceSetsPerCC == 23
...    && nr-rrc.maxConfiguredResourceSetsAllCC == 1)))))

${UERadioCapabilityInfoIndication_Extended_Chipset_Info}    ngap.UERadioCapabilityInfoIndication_element && (nr-rrc.UE_NR_Capability_element
...    && (nr-rrc.mac_Parameters_element && (nr-rrc.mac_ParametersCommon_element && nr-rrc.mAC_ParametersCommon.dummy == 0))
...    && (nr-rrc.rf_Parameters_element && (nr-rrc.supportedBandListNR && (nr-rrc.BandNR_element && nr-rrc.bandNR == 78
...    && nr-rrc.mIMO_ParametersPerBand.dummy4_element && (nr-rrc.burstLength == 1 && nr-rrc.maxSimultaneousResourceSetsPerCC == 5
...    && nr-rrc.maxConfiguredResourceSetsPerCC == 64 && nr-rrc.maxConfiguredResourceSetsAllCC == 128)) && (nr-rrc.BandNR_element
...    && nr-rrc.bandNR == 79 && nr-rrc.mIMO_ParametersPerBand.dummy4_element && (nr-rrc.burstLength == 2
...    && nr-rrc.maxSimultaneousResourceSetsPerCC == 7 && nr-rrc.maxConfiguredResourceSetsPerCC == 23
...    && nr-rrc.maxConfiguredResourceSetsAllCC == 1)))))

${HO_request_chipset_infra_info_TC04}    xnap.HandoverRequest_element && nr-rrc.HandoverPreparationInformation_element &&
...    nr-rrc.ue_CapabilityRAT_List && (nr-rrc.UE_NR_Capability_element && (nr-rrc.mac_Parameters_element && (nr-rrc.mac_ParametersCommon_element
...    && nr-rrc.mAC_ParametersCommon.dummy == 0)) && (nr-rrc.rf_Parameters_element && (nr-rrc.supportedBandListNR && (nr-rrc.bandNR == 78 &&
...    nr-rrc.mIMO_ParametersPerBand.dummy4_element && (nr-rrc.burstLength == 1 && nr-rrc.maxSimultaneousResourceSetsPerCC == 5 &&
...    nr-rrc.maxConfiguredResourceSetsPerCC == 64 && nr-rrc.maxConfiguredResourceSetsAllCC == 128)) && (nr-rrc.bandNR == 41 &&
...    nr-rrc.mIMO_ParametersPerBand.dummy4_element && (nr-rrc.burstLength == 2 && nr-rrc.maxSimultaneousResourceSetsPerCC == 7 &&
...    nr-rrc.maxConfiguredResourceSetsPerCC == 23 && nr-rrc.maxConfiguredResourceSetsAllCC == 1))) && (nr-rrc.appliedFreqBandListFilter &&
...    ((nr-rrc.FreqBandInformation == 0 && nr-rrc.bandInformationEUTRA_element && (nr-rrc.bandEUTRA == 200 && nr-rrc.ca_BandwidthClassDL_EUTRA == 0
...    && nr-rrc.ca_BandwidthClassUL_EUTRA == 3)) && (nr-rrc.FreqBandInformation == 0 && nr-rrc.bandInformationEUTRA_element &&
...    (nr-rrc.bandEUTRA == 201 && nr-rrc.ca_BandwidthClassDL_EUTRA == 0 && nr-rrc.ca_BandwidthClassUL_EUTRA == 4)) &&
...    (nr-rrc.FreqBandInformation == 0 && nr-rrc.bandInformationEUTRA_element && (nr-rrc.bandEUTRA == 202 && nr-rrc.ca_BandwidthClassDL_EUTRA == 0
...    && nr-rrc.ca_BandwidthClassUL_EUTRA == 4))))))

${UECapabilityEnquiry_Infra_Info_TC04}    nr-rrc.ueCapabilityEnquiry_element

${UECapabilityInformation_Chipset_Info_TC04}    nr-rrc.ueCapabilityInformation_element

${UERadioCapabilityInfoIndication_Chipset_Infra_Info_TC04}    ngap.UERadioCapabilityInfoIndication_element

*** Keywords ***

Perform SA call
    [Arguments]     ${ue_id}
    Execute Egate Command   cmd=set_pdu_param ue=${ue_id} pdu=${ue_id} trf_type=internal
    Attach Ue    ue_id=${ue_id}
    Establish Pdu Session    ue_id=${ue_id}    pdu_id=${ue_id}    gw_id=${ue_id}
    Start Data Traffic
    ...     ues=${ue_id}
    ...     pdu=${ue_id}
    ...     direction=both
    ...     throughput=5mbps
    ...     traffic_period=${TRF_DURATION}

Start PCMD
    Log to console  Start PCMD..
    Start Tshark  log_filename=${TEST_NAME}_pcmd.pcap  eth_interface=eth3:TCE  capture_filter=host 10.0.1.11
    ...    log_dirpath=${OUTPUT_DIR}/tshark  alias=PCMD

Stop PCMD
    Log to console  Stop PCMD..
    # Sleep 10s to get all pcmd records captured..
    Sleep  10s
    Stop Tshark  alias=PCMD
    ${VAR1}=  Set variable  tshark -o ntrstr.defragment:TRUE -d tcp.port==15000-15100,ntrstr -d tcp.port==49151,ntrstr -r
    ${VAR2}=  Set variable  ${OUTPUT_DIR}/tshark/${TEST_NAME}_pcmd.pcap -V > ${OUTPUT_DIR}/tshark/${TEST_NAME}_pcmd_nsetapx_preferences.pcap
    Log  Tshark decoding cmd: ${VAR1} ${VAR2}
    Run  ${VAR1} ${VAR2}

Start TCE
    #${TestlineIpAddr}    Run    sudo ifconfig eth0 | grep -w inet | awk '{ print $2}'
    #Set Suite variable    ${TestlineIpAddr}

    SSHLibrary.open connection    ${TCE}    timeout=30 seconds
    SSHLibrary.Login With Public Key    ute    /home/ute/.ssh/id_rsa
    Start Ncat Listening
    Sleep  5s
    ${status}    Run Keyword And Return Status    Check Connection between GNB and L3DC

Start Ncat Listening
    SSHLibrary.Write    nc -lvnp 49151 &> /home/ute/logs/tce_49151.txt&

Stop TCE in UTE
    ${nc_id}    run    ps -ef | grep "nc -lvnp 49151" | grep -v grep | awk '{print $2}'
    run    kill -9 ${nc_id.strip()}
    ${output}    run    ps -ef | grep "nc -lvnp 49151" | grep -v grep | awk '{print $2}'
    Should be true    "${output.strip()}"==""

Check Connection between GNB and L3DC
    wait until keyword succeeds    120s    2s    trace_connection_should_be_existed

trace_connection_should_be_existed
    ${output}    Run    cat /home/ute/logs/tce_49151.txt |grep -a ${GNB_X2_IP}
    Should contain    ${output}    Connection from ${GNB_X2_IP}
    Sleep  5s

Setup wireshark
    [Arguments]       ${preferences}
    Run  chmod 777 /home/ute/.config/wireshark/preferences
    ${output1}  Run  cp -f ${preferences} /home/ute/.config/wireshark/preferences
    Should Not Contain  ${output1}  No such file or directory

Attach UE And Start Traffic For B6a
    [Arguments]    ${UE_ID}
    SA 5G Attach    ue_id=${UE_ID}
    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
    SA 5G PDU Session Setup    ue_id=${UE_ID}
    #step1
    Run Keyword And Continue On Failure    Start DL Traffic    1    4
    Run Keyword And Continue On Failure    Start UL Traffic    1    1
    Sleep    10s    wait traffic average
    Traffic Display

Send A3 MR to trigger interGNB intraFreqHo with blind Scell Addition
    [Arguments]    ${ue_id}=1    ${target_pci}=58
    ${command}    Set Variable    ue_measurement_send_nr id=${ue_id} meas_id=2 event=A3 srsrp_nr=10 phycell_id=${target_pci} nrsrp_nr=40
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    pass_regexp=Inter-eNB handover from EXT_ENB-2.4 to EXT_ENB-3.9 performed    timeout=3min

Suite Setup Start WTS For B6a
    Modify UTE SCTP Timeout
    Modify AP SCTP Timeout
    Configure UTE ETH3
    Start UTE WTS    ${WTS_CFG_B6a}
    UE SIB Decoding Should Be Successful
#    Check All Cells Received SIB2

Modify Swconfig File Parameters for 2gnb
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@10.0.1.3 'echo "0x4B000F=1">>/ffs/run/swconfig.txt'
	Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@10.0.1.3 'crasign /ffs/run/swconfig.txt'

Traffic Display
    Run Keyword And Ignore Error    ute_wtssim.Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 type=pdsch scell=0-4
    ...    pass_regexp=CellIndex-0    timeout=60s
    sleep    5s    #for traffic
    Run Keyword And Ignore Error    ute_wtssim.Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 type=pusch scell=0-4
    ...    pass_regexp=CellIndex-0    timeout=60s
