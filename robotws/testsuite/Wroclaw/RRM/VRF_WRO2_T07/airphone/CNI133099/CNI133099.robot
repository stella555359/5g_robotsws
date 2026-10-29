*** Settings ***

Documentation
...    :copyright: Nokia
...    :author: Sylwester Sowa
...    :maintainer: Sylwester Sowa, Krzysztof Wojnar, Marek Halama
...    :contact: sylwester.sowa@nokia.com, krzysztof.wojnar@nokia.com, marek.halama@nokia.com

Resource    CNI133099_keywords.robot

*** Test Cases ***
CNI_133099_PCI_Based_CSI-IM_rand_FDD_non_DSS_ABIO_pooling_enabled_boundary_PCI_values
    [Documentation]    The purpose of this test case is to verify CSI-IM configuration over DL data slots as to ensure
    ...    different time/frequency domain configuration of CSI-IM in different cells across intra gNB with ABIO
    ...    configuration with boundary PCI values.
    [Tags]     TC1    CLOUD_5G_I_LOO_AP_LOOO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65
    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...    AND                 Start netcat
    ...    AND                 Prepare config for ABIO
    [Teardown]    Run Keywords
    ...    Find Scfc And Send Delta Commissioning    scfc_filename=delta_clean_up_abio.json
    ...     AND                   Stop netcat
    ...     AND                   Add Scout External Execution ID To Reporting Portal
    ...     AND                   Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    check_errors_or_warnings=both
    Start TCE trace    log_filename=tce_ue_pci_0.pcap    alias=tce_ue_pci_0
    Start L1L2 BIP collection    pci=0
    Attach UE    ue_id=51    # UE in cell 7 PCI 0
    Sleep    1    reason=stability between commands
    Establish Pdu Session With Traffic    ue_id=51    pdu_id=1    gw_id=1    nwslice=1
    Stop L1L2 BIP collection    name=l1l2bip_pci0
    Verify CSI-IM subcarrier in RRC Setup    subcarrier=0    pci=0
    Verify CSI-IM symbol in RRC Setup    symbol=10    pci=0
    Verify timeRestrictionForInterferenceMeasurements in RRC Reconfiguration is set to notConfigured    pci=0
    Stop Tshark    alias=tce_ue_pci_0
    Verify CSI-IM slot in BIP    slot=8    symbol=10    pci=0
    Deregister UE    ue_id=51

    Start TCE trace    log_filename=tce_ue_pci_1007.pcap    alias=tce_ue_pci_1007
    Start L1L2 BIP collection    pci=1007
    Attach UE    ue_id=71    # UE in cell 8 PCI 1007
    Sleep    1    reason=stability between commands
    Establish Pdu Session With Traffic    ue_id=71    pdu_id=1    gw_id=1    nwslice=1
    Stop L1L2 BIP collection    name=l1l2bip_pci1007
    Verify CSI-IM subcarrier in RRC Setup    subcarrier=8    pci=1007
    Verify CSI-IM symbol in RRC Setup    symbol=4    pci=1007
    Verify timeRestrictionForInterferenceMeasurements in RRC Reconfiguration is set to notConfigured    pci=1007
    Stop Tshark    alias=tce_ue_pci_1007
    Verify CSI-IM slot in BIP    slot=8    symbol=4    pci=1007
    Deregister UE    ue_id=71

CNI_133099_PCI_Based_CSI-IM_rand_FDD_non_DSS_ABIL_boundary_PCI_values_sym_7_blocked
    [Documentation]    The purpose of this test case is to verify CSI-IM configuration over DL data slots as to ensure
    ...    different time/frequency domain configuration of CSI-IM in different cells across intra gNB with ABIL
    ...    configuration with boundary PCI values.
    [Tags]     TC2    CLOUD_5G_I_BLLL_AP_LOO    SANSA_FS_ECPRI_CMWV_FDD+TDD_GMC
    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...    AND                 Start netcat
    ...    AND                 Prepare config for ABIL
    [Teardown]    Run Keywords
    ...    Find Scfc And Send Delta Commissioning    scfc_filename=delta_clean_up_abil.json
    ...     AND                   Stop netcat
    ...     AND                   Add Scout External Execution ID To Reporting Portal
    ...     AND                   Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    check_errors_or_warnings=both
    Start TCE trace    log_filename=tce_ue_pci_0.pcap    alias=tce_ue_pci_0
    Start L1L2 BIP collection    pci=0
    Attach UE    ue_id=85    # UE in cell 11 PCI 0
    Sleep    1    reason=stability between commands
    Establish Pdu Session With Traffic    ue_id=85    pdu_id=1    gw_id=1    nwslice=1
    Stop L1L2 BIP collection    name=l1l2bip_pci0
    Verify CSI-IM subcarrier in RRC Setup    subcarrier=0    pci=0
    Verify CSI-IM symbol in RRC Setup    symbol=12    pci=0
    Verify timeRestrictionForInterferenceMeasurements in RRC Reconfiguration is set to notConfigured    pci=0
    Stop Tshark    alias=tce_ue_pci_0
    Verify CSI-IM slot in BIP    slot=0    symbol=12    pci=0    BM=ABIL
    Deregister UE    ue_id=85

    Start TCE trace    log_filename=tce_ue_pci_1007.pcap    alias=tce_ue_pci_1007
    Start L1L2 BIP collection    pci=1007
    Attach UE    ue_id=86    # UE in cell 12 PCI 1007
    Sleep    1    reason=stability between commands
    Establish Pdu Session With Traffic    ue_id=86    pdu_id=1    gw_id=1    nwslice=1
    Stop L1L2 BIP collection    name=l1l2bip_pci1007
    Verify CSI-IM subcarrier in RRC Setup    subcarrier=8    pci=1007
    Verify CSI-IM symbol in RRC Setup    symbol=8    pci=1007    # PCI mod 9 due to actBlockCsiImAllocSymSeven set to true
    Verify timeRestrictionForInterferenceMeasurements in RRC Reconfiguration is set to notConfigured    pci=1007
    Stop Tshark    alias=tce_ue_pci_1007
    Verify CSI-IM slot in BIP    slot=0    symbol=8    pci=1007    BM=ABIL
    Deregister UE    ue_id=86
