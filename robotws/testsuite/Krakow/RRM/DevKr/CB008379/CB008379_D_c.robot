*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         CB008379: GBR Services for SA
...
...      == TEST SET NAME ==
...         CB008379
...
...      == TESTING SPLIT==
...            CB008379-D_c
...
...      == AUTHORS ==
...       - Dawid Krawczuk <dawid.krawczuk@nokia.com>
...       - Cezary Dudek <cezary.dudek@nokia.com>
...       - Marek Kieltyka <marek.kieltyka@nokia.com>
...       - Karolina Sroczyk <karolina.sroczyk@nokia.com>
...       - Gabriela Stasiuk <gabriela.stasiuk@nokia.com>
...       - Grzegorz Szymik <grzegorz.szymik@nokia.com>
...       - Michal Szymakowski <michal.szymakowski@nokia.com>
...       - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...
...      == MAINTAINER ==
...       - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      == REFERENCES ==
...         CB008379 CFAM
...
...      == HISTORY ==
...         [07.02.2022] - Create Test Suite

Resource    ./resources/CB008379-common_keywords.robot

Force Tags    CONFIGURED    RAN_5G    RAN_5G_FDD    SBTS00    SBTS23R4    SKIPRUN
    ...    CLOUD_5G_I_KL_AP_KL_SANSA_FS_CPRI_CMWV_FDD

Suite Setup
...     Run Setup

*** Variables ***
${LUA_CFG}=                 ${CURDIR}/config/SA_TDD_2c_1gNBSim.lua
${yaml_enable_interho}=     ${CURDIR}/../resources/yaml_config/inter_gnb_ho.yaml
${yaml_enable_ngho}=        ${CURDIR}/../resources/yaml_config/NG_handover.yaml

*** Test Cases ***
CB008379-D-c_2 Successful inter-gNB intra-freq NG-HO handover with indirect forwarding with GBR bearer
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     The purpose of test is to perform successful intra-frequency inter-gNB NG handover with indirect forwarding and traffic verification
    ...     for GBR bearers with 5QI: 2,3,4,71,72,76,128,212,254
    ...
    ...  == Precondition: ==
    ...  - gNB2 up and running with one SA cell OnAir
    ...  - simulated gNB3 is up and running with one cell
    ...  - NRBTS-1.NRADJGNB-0 is configured for adjacent gNB3
    ...  - NRBTS-1.NRADJNRCELL-1 is configured for adjacent gNB3 Cell1
    ...  - Neighbour gNB3 has Ng connection to the AMF that the UE1 is connected to
    ...  - gNB2 Cell1 has NRCELL-1.NRREL object, which indicates relation to gNB2 neighbor cell
    ...  - NRCELL-1.NRREL.handoverAllowedSA = 'XnHoNotAllowed'
    ...  - NRCELL-1.actNonVoNRGBRService = 'enabled'
    ...  - NRCELL-1.a3MeasEnabled = 'rsrpAndRsrq'
    ...  - NRCELL-1.a5MeasEnabled = 'rsrpAndRsrq'
    ...  - NRCELL-1.actCDrx = 'disabled'
    ...  - NRBTS-1.actIntraFreqHoSA = 'true'
    ...  - NRBTS-1.actIntraNrNgHo = 'sourceAndTarget'
    ...  - RLC mode = RLC AM
    ...  - PDCP SN size = 18 bit
    ...  - NG HO is supported between real and simulated gNB
    ...
    ...  == TESTING TOOLS ==
    ...  - AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...  - NRCELL-1 simulated on AEQA radio module - NR_BAND: n78
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE:  5G_RAN_CP_12360506; 5G_CP_MM_2997
    ...
    ...  == REQUIRED LOGS ==
    ...    UU, NGAP, NRRRC, PCAP
    ...
    ...  == CONTACTS ==
    ...     - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  == REFERENCES ==
    ...  - Related CFAM US:
    ...     - USCB008379-D1#B4: Successful Intra-frequency Inter-gNB handover with GBR bearers
    ...			- 5GC000705-A#B3 Successful Inter-gNB NG based Handover based on A3/A5 measurements with
    ...           indirect DL data forwarding - 5G_RAN_USR_RRM_1452
	...
    ...  == HISTORY ==
    ...     [07.02.2022]  - Created TC

    [Tags]  DC2

    Prepare test environment DC2

    Run Keyword And Continue On Failure
    ...     Repeat Successful intra-frequency inter-gnb handover from simulated gNB3 to gNB2 with 5QI2 for UE1
    Run Keyword And Continue On Failure
    ...     Repeat Successful intra-frequency inter-gnb handover from simulated gNB3 to gNB2 with 5QI3 for UE2
    Run Keyword And Continue On Failure
    ...     Repeat Successful intra-frequency inter-gnb handover from simulated gNB3 to gNB2 with 5QI4 for UE3
    Run Keyword And Continue On Failure
    ...     Repeat Successful intra-frequency inter-gnb handover from simulated gNB3 to gNB2 with 5QI71 for UE4
    Run Keyword And Continue On Failure
    ...     Repeat Successful intra-frequency inter-gnb handover from simulated gNB3 to gNB2 with 5QI72 for UE5
    Run Keyword And Continue On Failure
    ...     Repeat Successful intra-frequency inter-gnb handover from simulated gNB3 to gNB2 with 5QI76 for UE6
    Run Keyword And Continue On Failure
    ...     Repeat Successful intra-frequency inter-gnb handover from simulated gNB3 to gNB2 with 5QI128 for UE7
    Run Keyword And Continue On Failure
    ...     Repeat Successful intra-frequency inter-gnb handover from simulated gNB3 to gNB2 with 5QI212 for UE8
    Run Keyword And Continue On Failure
    ...     Repeat Successful intra-frequency inter-gnb handover from simulated gNB3 to gNB2 with 5QI254 for UE9

*** Keywords ***
Prepare test environment DC1
    Configure       ${yaml_enable_interho}

Prepare test environment DC2
    Execute egate command   cmd=gnb_param id=3 sa_ho=ng_based

Prepare test environment DC3
    Configure       ${yaml_enable_ngho}

Repeat Successful inter-frequency inter-gnb handover from simulated gNB${gnb_src} to gNB${gnb_tgt} with 5QI${5qi_gbr} for UE${ue_id:\d+}
    Attach UE${ue_id} with one PDU session and traffic to simulated gNB${gnb_src} with 1 nonGBR and 1 GBR 5QI${5qi_gbr} QoS flow
    UE${ue_id} triggers Inter-gNB Handover from simulated gNB3 to real gNB2 by sending A5 measurement
    Stop and verify 5MBps UL and DL traffic on UE${ue_id} PDU1 QFI2
    Stop and verify 5MBps UL and DL traffic on UE${ue_id} PDU1 QFI1
    Detach and kill UE${ue_id}

Repeat Successful intra-frequency inter-gnb handover from simulated gNB${gnb_src} to gNB${gnb_tgt} with 5QI${5qi_gbr} for UE${ue_id:\d+}
    Set data forwarding to True for UE${ue_id}
    Attach UE${ue_id} with one PDU session and traffic to simulated gNB${gnb_src} with 1 nonGBR and 1 GBR 5QI${5qi_gbr} QoS flow
    UE${ue_id} triggers successful NG HO from simulated_gNB to real_gNB without indirect data forwarding
    Stop and verify 5MBps UL and DL traffic on UE${ue_id} PDU1 QFI2
    Stop and verify 5MBps UL and DL traffic on UE${ue_id} PDU1 QFI1
    Detach and kill UE${ue_id}

Attach UE${ue_id:\d+} with one PDU session and traffic to simulated gNB${gnb_id} with 1 nonGBR and 1 GBR 5QI${5qi_id:\d+} QoS flow
    Execute egate command   cmd=ue_change_location id=${ue_id} enb=2 cell=1
    Set up inter gNB Handover for UE${ue_id}
    start_observing_measurements      UE_${ue_id}       technology=5G
    Attach UE${ue_id} to gNB2 cell1 with ICS without PDU session
    Add to UE${ue_id} initial PDU session without ICS including 1 nonGBR and 1 GBR 5QI${5qi_id} QoS flow
    Run 5MBps UL and DL traffic on UE${ue_id} PDU1 QFI1 and wait 0 seconds
    Run 5MBps UL and DL traffic on UE${ue_id} PDU1 QFI2 and wait 5 seconds

    Execute egate command   cmd=meas_cfg_ue_disp id=${ue_id}
    UE${ue_id} triggers Inter-gNB Handover from real gNB2 to simulated gNB3 by sending A5 measurement
    Sleep  10

Set forwarding to indirect for UE${ue_id:\d+}
    Execute egate command   cmd=gnb_param id=${ue_id} ng_forwarding_tunnel_type=drb ran_status_transfer=enable
    Execute egate command   cmd=amf_param id=${ue_id} intra5g_data_forwarding=on

UE${ue_id:\d+} triggers successful NG HO from simulated_gNB to real_gNB without indirect data forwarding
    EXPECT FLOW: AMF1 NGAP handoverRequest, handoverRequestAckonwledge
    EXPECT FLOW: AMF1 NGAP DLRanStatusTransfer
    EXPECT FLOW: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW: AMF1 NGAP UEContextReleaseCommand
    EXPECT FLOW: AMF1 NGAP UEContextReleaseComplete

    UE${ue_id} triggers Inter-gNB Handover from simulated gNB3 to real gNB2 by sending A5 measurement

    PASS FLOW: AMF1 NGAP handoverRequest
    PASS FLOW: AMF1 NGAP handoverRequestAckonwledge
    PASS FLOW: AMF1 NGAP DLRanStatusTransfer
    PASS FLOW: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW: AMF1 NGAP UEContextReleaseCommand
    PASS FLOW: AMF1 NGAP UEContextReleaseComplete


