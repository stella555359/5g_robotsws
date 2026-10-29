*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         CB008985: NR FR1 TDD super cell
...         This feature supports NR FR1 TDD super cell RRM part. The super cell is a logical cell created by several sub-cells.
...         The same Physical Cell ID (PCI) is assigned to each sub-cell of the super cell. Each sub-cell of the super cell operates
...         on the same carrier frequency without resource multiplexing. Benefits for customers are: reduced handover ratio, improved
...         call service quality (i.e. call drop rate)
...
...      == TEST SET NAME ==
...         CB008985 - NR FR1 TDD super cell
...
...      == TESTING SPLIT ==
...         CB008985-A Basic function and performance of supercell
...         CB008985-B High speed supercell support
...         CB008985-C Interworking with other key features
...
...      == CONTACTS ==
...       - Marek Kieltyka <marek.kieltyka@nokia.com>
...       - Mateusz Matusik <mateusz.matusik@nokia.com>
...
...      == MAINTAINER ==
...       - Marek Kieltyka <marek.kieltyka@nokia.com>
...       - Mateusz Matusik <mateusz.matusik@nokia.com>
...
...      == REFERENCES ==
...         CB008985 CFAM
...
...      == HISTORY ==
...         [26.09.2022] - Create Test Suite
...         [01.12.2022] - keep default value rdTRSSlotAligned=0 (https://pronto.ext.net.nokia.com/pronto/problemReport.html?prid=PR678442)

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4    SKIPRUN
    ...    CLOUD_5G_I_LO_AP_LOOO_SANSA_FS_ECPRI_CMWV_TDD
    ...    CONFIGS_Krakow/CB008985/SCF_2_supercells_2x3_subcells_3_AZQP_3_AZQU_CA_setup.yaml

Suite Setup    Run Setup    reset_tl=${False}

Resource    ./resources/CB008985_keywords.robot

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/SANSA_TDD_2c_n77_n78_1eNBsim_1gNBsim.lua

*** Test Cases ***
CB008985-A-B901_Robustness_inter_freq_intra_gNB_CA_with_supercell
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  Purpose of this test is to verify interaction between supercell feature and inter-freq intra-gNB CA
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO + ABIO + ABIO
    ...  - AMF1 simulated
    ...  - UE1 - Airphone simulator
    ...  - UE1 is capable of FR1-TDD FR1 CA with up to 2CCs
    ...  - UE1 support 2CC n77-n78 band combination
    ...  - gNB2 up
    ...  - NRCELL-1.freqBandIndicatorNR=78
    ...  - NRCELL-2.freqBandIndicatorNR=77
    ...  - NRCELL-1 and NRCELL-2 supercell configuration:
    ...  - NRCELL.actSupercell=true
    ...  - NRCELL.actCsirsMultiplexing=true
    ...  - NRCELL.actBeamforming=false
    ...  - NRCELL.pucchModeSelect=longPucch
    ...  - NRCELL.numOfSuperSubcells=3 (3xCHANNELGROUP configured)
    ...  - NRCELL-1.dlMimoMode='2x2 Closed Loop Spatial Multiplexing'
    ...  - NRCELL-2.dlMimoMode='4x4 or 4x2 Closed Loop Spatial Multiplexing'
    ...  - NRCELL-1.nrCellType=2DL2UL
    ...  - NRCELL-2.nrCellType=4DL4UL
    ...  CA settings
    ...  - NRBTS.actCarrierAggregation=true
    ...  - NRBTS.actMeasBasedSCellAddition=true
    ...  - NRDU.actInterGnbCa=disabled
    ...  - NRBTS.caConfigurationSupport=2CCDL_2CCUL
    ...  - NRBTS.maxNumScellsDl=2
    ...  - NRBTS.maxNumScellsUl=2
    ...  - NRBTS.sCellActivationMethod=blind
    ...  - NRBTS.actBcsCheck=enabled_FR1
    ...  - NRBTS.rejectSuppBcs=none
    ...  - NRBTS.NRDU.carrierAggregationSupportList=ca_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Nsa
    ...  - NRBTS.NRDU.flexibleCAMode=MixedCAMode
    ...  - NRBTS.actFdmScheduling=true
    ...  - NRCELL.allowUnsuppBcOrBcs=accept unknown BCSs
    ...  - NRCELL-1.NRREL.sCellAdditionMethod=covBasedA1  (relation to NRCELL-2)
    ...  DRX settings
    ...  - NRCELL.actCDrx is set to true
    ...  - drxProfile1 is configured in NRCELL:
    ...  - NRCELL.drxProfile1.drxOnDurationTimer eq 10ms
    ...  - NRCELL.drxProfile1.drxInactivityTimer eq 20ms
    ...  - NRCELL.drxProfile1.drxLongCycle eq 40ms
    ...  - UE1 supports longDRX mac-Parameters.MAC-ParametersXDD-Diff.longDRX-Cycle set to supported
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with 3 simulated AZQU and 3 simulated AZQP radio modules
    ...       3xAZQP for NRCELL-1
    ...       3xAZQU for NRCELL-2
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_16872
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, NGAP pcap
    ...
    ...  == CONTACTS ==
    ...  - Marek Kieltyka (Nokia - PL/Krakow) <marek.kieltyka@nokia.com>
    ...  - Mateusz Matusik (Nokia - PL/Krakow) <mateusz.matusik@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008985-A Predicted Robustness
    ...
    ...  == HISTORY ==
    ...     [26.09.2022] - TC Create

    [Tags]  B901

    Attach UE1 to gNB2 NRCELL-1 subcell_1

    Trigger A1 measurement for UE1 with result greater than TDD threshold
    Verify that covBasedA1 SCell addition NRCELL-2 is successful for UE1
    Verify that UE1 configured A2 measurement during SCell Addition
    Verify that CSI-SSB resources are properly allocated for UE1 after A1 measurement by PCell and SCell with 3 beams

    Run 100Mbps DL traffic-1 on UE1 PDU1 QFI1 and wait 1 seconds
    Run 100Mbps DL traffic-2 on UE1 PDU1 QFI1 and wait 1 seconds
    Run 100Mbps DL traffic-3 on UE1 PDU1 QFI1 and wait 1 seconds
    Run 100Mbps DL traffic-4 on UE1 PDU1 QFI1 and wait 1 seconds

    Sleep  20   reason=Wait for increasing average traffic rate on PCELL and SCELL...

    Trigger subcell switch for UE1 from NRCELL-2 subcell_1 to subcell_3
    Trigger subcell switch for UE1 from NRCELL-1 subcell_1 to subcell_2

    Verify that traffic on PCELL for UE1 is greater than 180MBps
    Verify that traffic on SCELL for UE1 is greater than 180MBps

    Trigger A2 measurement for UE1 with result lower than SCell Release threshold for SCELL-1
    Verify that UE1 released NRCELL-2 SCell
    Verify that traffic on PCELL for UE1 is greater than 180MBps

    Trigger subcell switch for UE1 from NRCELL-1 subcell_2 to subcell_3
    Verify that traffic on PCELL for UE1 is greater than 180MBps
    Stop 400Mbps DL traffic on UE1 PDU1 QFI1

    [Teardown]  Detach and kill UE1
