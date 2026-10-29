*** Settings ***
Documentation    :copyright: Nokia

Library      ute_fsmaccess
Library      ta5g_iphy
Library      ta5g_testline_management
Library      taf.collectors.l1l2bip
Library      taf.collectors.core    WITH NAME    core
Library      ./resources/utility.py
Resource     ../../../resources/airphone/5G_SW_WRO_Keywords.robot

*** Variables ***
${NSETAPX_REPORT}=      nsetapx.report_element
${CSI_IM_RES}=          nr-rrc.csi_IM_ResourceToAddModList
${DlData_ABIO}=         nr_l1dl_l2ps_dldata_csirssendreql1sw_t
${DlData_ABIL}=         nr_l1dl_l2ps_dldata_csirssendreqloner_t
${StartSymbol_ABIO}=    DlData_CsiRsResourceL1sw_t.startSymbol
${StartSymbol_ABIL}=    DlData_CsiRsResourceLoner_t.startSymbol
${CSI_IM_BIP}=          DlData_CsiRsResourceL1sw_t.csiTransmitPower
${CSI_IM_BIP_ABIL}=     DlData_CsiRsResourceLoner_t.csiTransmitPower
${PCI_BIP}=             DlData_CsiRsResourceL1sw_t.csiRsScramblingSequenceInt
${PCI_BIP_ABIL}=        DlData_CsiRsResourceLoner_t.csiRsScramblingSequenceInt

*** Keywords ***
Start Vm Ethernet Interfaces
    Start Vm Ethernet Interface    if_name=eth3:simgnb3_xn    ip_with_mask=10.0.1.122/24
    Start Vm Ethernet Interface    if_name=eth3:simgnb3_ng    ip_with_mask=10.0.1.123/24
    Start Vm Ethernet Interface    if_name=eth3:simgnb4_xn    ip_with_mask=10.0.1.124/24
    Start Vm Ethernet Interface    if_name=eth3:simgnb4_ng    ip_with_mask=10.0.1.125/24

Start TCE trace
    [Arguments]    ${log_filename}=trace_TCE.pcap    ${alias}=tce_trace_pcap
    Start tshark
    ...    log_filename=${log_filename}
    ...    eth_interface=eth3
    ...    capture_filter=tcp
    ...    log_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...    alias=${alias}

Verify TCE Messages
    [Arguments]    ${packet_filter}    ${number_of_messages}=1    ${pcap_file_path}=${None}    ${timeout}=16    ${relation_symbol}= ==
    ...            ${alias}=tce_trace_pcap   ${continue_on_failure}=${True}
    IF    ${{$pcap_file_path is not None}}
        ${pcap_file_path}=    Catenate      SEPARATOR=/    ${OUTPUT_DIR}/${TEST_NAME}    ${pcap_file_path}
    END
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
    ...    pass_criteria=${relation_symbol}${number_of_messages}
    ...    pcap_file_path=${pcap_file_path}
    ...    timeout=${timeout}
    ...    continue_on_failure=${continue_on_failure}

Copy Wireshark preferences
    Copy File    ${CURDIR}/config/wireshark_preferences    /home/ute/.config/wireshark/preferences

Start L1L2 BIP collection
    [Arguments]    ${pci}
    ${webservice}=  Create Dictionary
                    ...  host=192.168.255.129
                    ...  user=Nemuadmin
                    ...  password=nemuuser
                    ...  port=443
    Create Interface Mirroring l1l2bip collector
    ...    name=l1l2bip_pci${pci}    webservice=${webservice}
    ...    nr_phy_cell_ids={pci}
    ...    mirroring_filter=SpecificL1L2Messages    specific_message_ids=0xE110,0xE122,0xE133
    core.Setup Collectors    names=l1l2bip_pci${pci}
    core.Start Collectors    names=l1l2bip_pci${pci}
    core.Set test alias    l1l2bip_pci${pci}

Stop L1L2 BIP collection
    [Arguments]    ${name}
    core.Stop Collectors    names=${name}
    core.Collect Collectors    names=${name}
    core.Teardown Collectors    names=${name}

Prepare config for ABIO
    @{MPLANE_CELLS}=    Create list    5    6    9    12
    Copy Wireshark preferences
    Update and put iphy xml    input_filepath=${CURDIR}/config/iphy_abio_boundary_pci.xml
    Trigger site reset
    Check radios availability
    Find Scfc And Send Delta Commissioning    scfc_filename=delta_enable_cni133099_with_boundary_pci_abio.json
    Reach OnAir    lua_cfg=${CURDIR}/config/abio_boundary_pci.cfg    check_edaemon_port=${True}    mplane_cells=@{MPLANE_CELLS}
    Setup X2 Link    initiator_device=1    complementary_device=2

Prepare config for ABIL
    Start Vm Ethernet Interfaces
    Copy Wireshark preferences
    Update and put iphy xml    input_filepath=${CURDIR}/config/iphy_abil_boundary_pci.xml
    Trigger site reset
    Check radios availability
    Find Scfc And Send Delta Commissioning    scfc_filename=delta_enable_cni133099_with_boundary_pci_abil.json
    Reach OnAir    lua_cfg=${CURDIR}/config/abil_boundary_pci.cfg    check_edaemon_port=${True}

Verify CSI-IM subcarrier in RRC Setup
    [Arguments]    ${subcarrier}    ${pci}
    Verify TCE Messages
    ...    packet_filter=${NSETAPX_REPORT} && ${RRC_SETUP} && ${CSI_IM_RES} == 1 && nr-rrc.subcarrierLocation_p1 == s${subcarrier}
    ...    pcap_file_path=tce_ue_pci_${pci}.pcap
    ...    alias=tce_ue_pci_${pci}

Verify CSI-IM symbol in RRC Setup
    [Arguments]    ${symbol}    ${pci}
    Verify TCE Messages
    ...    packet_filter=${NSETAPX_REPORT} && ${RRC_SETUP} && ${CSI_IM_RES} == 1 && nr-rrc.symbolLocation_p1 == ${symbol}
    ...    pcap_file_path=tce_ue_pci_${pci}.pcap
    ...    alias=tce_ue_pci_${pci}

Verify timeRestrictionForInterferenceMeasurements in RRC Reconfiguration is set to notConfigured
    [Arguments]    ${pci}
    Verify TCE Messages
    ...    packet_filter=${NSETAPX_REPORT} && ${RRC_RECONFIGURATION} && nr-rrc.timeRestrictionForInterferenceMeasurements == notConfigured
    ...    pcap_file_path=tce_ue_pci_${pci}.pcap
    ...    alias=tce_ue_pci_${pci}

Verify CSI-IM slot in BIP
    [Arguments]    ${slot}    ${symbol}    ${pci}    ${BM}=ABIO
    IF    "${BM}" == "ABIL"
        ${bip_filter}=    Set Variable
        ...    ${DlData_ABIL} && 3gpp.slot == ${slot} && ${StartSymbol_ABIL} == ${symbol} && ${PCI_BIP_ABIL} == ${pci} && ${CSI_IM_BIP_ABIL} == -743
    ELSE
        ${bip_filter}=    Set Variable
        ...    ${DlData_ABIO} && 3gpp.slot == ${slot} && ${StartSymbol_ABIO} == ${symbol} && ${PCI_BIP} == ${pci} && ${CSI_IM_BIP} == -743
    END
    ${pcap_dir}=    Set Variable    ${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/l1l2bip_pci${pci}
    ${pcap_file}=    Get BIP Pcap File    ${pcap_dir}
    ${pcap_path}=    Catenate    SEPARATOR=/    ${pcap_dir}    ${pcap_file}
    ${result}=    Verify Csi Im Slot In BIP    ${pcap_path}    ${bip_filter}
    Should be True    ${result}
