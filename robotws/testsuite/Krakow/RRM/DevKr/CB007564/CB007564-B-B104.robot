*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         CB007564: NR Additional PM Counters
...         This feature provides new Performance Measurement counters that are used for Network
...         Performance measurement and creation of new or improvement of existing KPIs. The Feature
...         introduces PM counters related to Stand Alone Architecture: Accessibility counters,
...         Retainability counters and Non Stand Alone Architectre: RACH counters
...
...      == TEST SET NAME ==
...         CB007564 - NR Additional PM Counters
...
...      == TESTING SPLIT ==
...         CB007564-A Accessibility counters
...         CB007564-A-A101 Development enabler
...         CB007564-A-A102 PDU Session Resource Setup
...         CB007564-A-A103 PDU Session Resource Modify
...         CB007564-A-A104 Initial Context Setup Failure
...         CB007564-A-A105 Initial Context Setup Response
...         CB007564-A-A106 Handover Scenarios
...         CB007564-A-A107 RRC Re-estabishment
...         CB007564-B Retainability counters
...         CB007564-B-B101 Release of UE/PDU Session/QoS Flow in all procedures
...         CB007564-B-B102 NG Reset
...         CB007564-B-B103 AMF initiated release
...         CB007564-B-B104 Handover Scenarios
...         CB007564-C RACH counters
...
...      == CONTACTS ==
...       - Mateusz Matusik <mateusz.matusik@nokia.com>
...       - Maciej Madej <maciej.madej@nokia.com>
...
...      == MAINTAINER ==
...       - Maciej Madej <maciej.madej@nokia.com>
...
...      == REFERENCES ==
...         CB007564 CFAM
...
...      == HISTORY ==
...         [20.10.2021] - Create Test Suite
...         [10.02.2023] - Switching TL type to CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD

Resource    ./resources/CB007564_HO_keywords.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_FDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD

Suite Setup  Run Setup alternative

*** Variables ***
${LUA_CFG}=                     ${CURDIR}/config/egate_2c_1lte_cell_on_gnb.lua
@{yaml_paths_to_configure}=     ${disable_ciphering_yaml_path}   ${CURDIR}/config/yaml_config/7564B104.yaml

*** Test Cases ***
CB007564-B-B104_Counters_for_inter_gNB_handovers
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...    Purpose of this test is to verify correct behaviour of CB007564 counters in cases related to QoS Flow release
    ...    due to inter gNB handovers and inter-RAT handovers
    ...
    ...  == Precondition: ==
    ...    - gNB2 classical - real hardware - ASIL + ABIO
    ...    - NRCELL simulated on AHLOA radio module - NR_BAND: n71
    ...    - AMF1 simulated
    ...    - UE - Airphone simulator
    ...
    ...    - gNB2 up and running with two SA cells OnAir
	...    - simulated gNB3 is up and running with one SA NRCell-31 OnAir
	...    - MRBTS/NRBTS/NRCELL/a2MeasEnabledSA is set to 'rsrp'
    ...    - MRBTS/NRBTS/NRCELL/a3MeasEnabled is set to 'rsrp'
    ...    - NRBTS/actIntraFreqHoSA is set to 'true'
	...    - NRBTS/actInterRatHoSA is set to 'true'
	...    - MRBTS/NRBTS/raTypeList is set to 'nr' and 'eutra'
	...    - MRBTS/NRBTS/NRADJGNB is configured for adjacent gNB3
    ...    - MRBTS/NRBTS/NRADJNRCELL is configured for adjacent gNB3 NRCell-31
	...    - MRBTS/NRBTS/NRADJECELL is configured for adjacent eNB1 Cell-11
	...    - MRBTS/NRBTS/NRCELL/NRREL object, which indicates relation to neighbor NR cell
	...    - MRBTS/NRBTS/NRCELL/NRRELLTE object, which indicates relation to neighbor LTE cell
	...    - MRBTS/NRBTS/NRHOIR is configured
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...    - gNB classicBTS in SA mode
    ...    - HARDWARE ID:  gNB(ASIL + ABIO) with simulated two AHLOA radio modules - NR_BAND: n71
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_PM_400
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, NGAP, XNAP pcap
    ...
    ...  == CONTACTS ==
    ...    - Maciej Madej (Nokia - PL/Krakow) <maciej.madej@nokia.com>
    ...    - Mateusz Matusik (Nokia - PL/Krakow) <mateusz.matusik@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB007564-B#US9 QosFlow Release due to HO
    ...
    ...  == HISTORY ==
    ...     [19.11.2021] - TC Create

    [Setup]  Prepare test environment B104-TC2

    Attach UE1 and setup initial PDU Session with one QoS Flow
    Verify that UE1 was attached to gNB2
    Trigger inter-gNB handover to gNB3 NRCELL-31 for UE1
    Verify that UE1 inter gNB handover was successfull

    Collect PM counters file
    Verify that M55125C09015 NG_FLOW_REL_IANR_SUC_HO counter is equal 1 in NRCELL-1 cell in gNB2
    Verify that M55125C09016 NG_FLOW_REL_IRAT_SUC_HO counter is equal 0 in NRCELL-1 cell in gNB2
    Verify that M55125C08503 NG_FLOW_REL counter is equal 0 in NRCELL-1 cell in gNB2
    Verify that M55125C08504 NG_FLOW_REL_NORMAL counter is equal 0 in NRCELL-1 cell in gNB2

    Trigger partial inter-gNB handover to gNB2 NRCELL-1 for UE1
    Verify that UE1 partial handover was successfull

    Collect PM counters file
    Verify that M55125C09015 NG_FLOW_REL_IANR_SUC_HO counter is equal 0 in NRCELL-1 cell in gNB2
    Verify that M55125C09016 NG_FLOW_REL_IRAT_SUC_HO counter is equal 0 in NRCELL-1 cell in gNB2
    Verify that M55125C08503 NG_FLOW_REL counter is equal 0 in NRCELL-1 cell in gNB2
    Verify that M55125C08504 NG_FLOW_REL_NORMAL counter is equal 0 in NRCELL-1 cell in gNB2
    Verify that M55125C09013 NG_FLOW_STP_ATT_INC_HO counter is equal 3 in NRCELL-1 cell in gNB2
    Verify that M55125C09014 NG_FLOW_STP_SUC_INC_HO counter is equal 1 in NRCELL-1 cell in gNB2

    Add secondary QoS flow to UE1 initial PDU Session
    Trigger inter-RAT handover to eNB1 CELL_11 for UE1
    Verify that UE1 interRAT handover was successfull

    Collect PM counters file
    Verify that M55125C09015 NG_FLOW_REL_IANR_SUC_HO counter is equal 0 in NRCELL-1 cell in gNB2
    Verify that M55125C09016 NG_FLOW_REL_IRAT_SUC_HO counter is equal 2 in NRCELL-1 cell in gNB2
    Verify that M55125C08503 NG_FLOW_REL counter is equal 2 in NRCELL-1 cell in gNB2
    Verify that M55125C08504 NG_FLOW_REL_NORMAL counter is equal 2 in NRCELL-1 cell in gNB2

    [Teardown]  Cleanup after test B104-TC2

*** Keywords ***
Prepare test environment B104-TC2
    Collect PM counters file
    Set up HO for UE1
    Execute egate command  cmd=gnb_param id=1 measEvent=A3

Cleanup after test B104-TC2
    Execute egate command  cmd=kill_ue id=1-5
    Execute egate command  cmd=ue_change_location id=1 enb=2 cell=1

Trigger partial inter-gNB handover to gNB2 NRCELL-1 for UE${ue_id:\d}
    Add secondary pdu session to UE${ue_id} with one Qos Flow with s-nssai not supported in gNB2
    Sleep  3
    Expect Message Flow
    ...     gNB2:XNAP_HandoverRequest as HO_Req
    ...     gNB2:XNAP_HandoverRequestAcknowledge as HO_Req_Ack
    ...     gNB2:XNAP_SNStatusTransfer
    ...     alias=UE${ue_id}_partial_Handover   overall_timeout=20

#    Expect Message Flow
#    ...     UE_${ue_id}:NR-RRC_MeasurementReport
#    ...     alias=UE_${ue_id}_RRCMeasurementReport
#    ...     overall_timeout=30
    Execute egate command  cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 srsrp_nr=19 srsrq_nr=10 phycell_id=50 nrsrp_nr=85 nrsrq_nr=31
#    Flow occurred as expected  alias=UE_1_RRCMeasurementReport

    Execute egate command
    ...    cmd=ue_pdu_session_release ue=${ue_id} pdu=2 by=amf
    ...    pass_regexp=Successfully released PDU Session with ID 2

    Execute egate command  cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 srsrp_nr=19 srsrq_nr=10 phycell_id=50 nrsrp_nr=85 nrsrq_nr=31

Verify that UE${ue_id} partial handover was successfull
    Flow occurred as expected  alias=UE${ue_id}_partial_Handover

Add secondary PDU Session to UE${ue_id:\d+} with one QoS Flow with s-nssai not supported in gNB2
    Sleep  5s
    Execute egate command   cmd=ue_pdu_session_setup ue=${ue_id} pdu=2 gw=2 nwslice=2


