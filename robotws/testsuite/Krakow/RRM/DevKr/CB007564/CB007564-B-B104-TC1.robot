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
...
...      == MAINTAINER ==
...       - Mateusz Matusik <mateusz.matusik@nokia.com>
...
...      == REFERENCES ==
...         CB007564 CFAM
...
...      == HISTORY ==
...         [20.10.2021] - Create Test Suite
...         [21.04.2022] - Enabled CB008700 for partial HO
...         [06.05.2022] - Aligned test with the changes introduced in 5G_L3_FLOW_59779 for PR644597
...         [18.01.2023] - Added M55125C09001, M55125C09007 counters verification for jira: 
...                        https://jiradc.ext.net.nokia.com/browse/MNRCA-58359

Resource    ./resources/CB007564_HO_keywords.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup  Run yaml setup

*** Variables ***
${LUA_CFG}=       ${CURDIR}/config/egate_2c_TDD_APoABIO.lua
&{phy_cell_id}=   1=50   2=51
${B104_yaml_file}=           ${CURDIR}/config/yaml_config/7564B104TC1.yaml
${partial_ho_yaml_file}=     ${CURDIR}/config/yaml_config/partial_ho_with_emergency_call.yaml
@{yaml_paths_to_configure}=     ${disable_ciphering_yaml_path}      ${SIB_config_yaml_path}
...                             ${intra_gNB_handover}               ${B104_yaml_file}
...                             ${partial_ho_yaml_file}

*** Test Cases ***
CB007564-B-B104_Counters_for_intra_gNB_handovers
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  Purpose of this test is to verify correct behaviour of CB007564 counters in cases related to QoS Flow release
    ...  due to intra gNB handovers
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - NRCELLs simulated on two AEQE radio modules - NR_BAND: n74
    ...  - AMF1 simulated
    ...  - UE - Airphone simulator
    ...
    ...  - gNB2 up and running with two SA cells OnAir
    ...  - MRBTS/NRBTS/NRCELL/a3MeasEnabled is set to 'rsrp' for both cells
    ...  - NRBTS/actIntraFreqHoSA is set to 'true'
    ...  - MRBTS/NRBTS/NRCELL.actARPBasedAC is set to 'handovers' for both cells
#    ...  - MRBTS/NRBTS/NRCELL.pduHoSliceRelease is set to 'true' for both cell [obsolete since 21.04.2022]
    ...  - MRBTS/NRBTS/NRCELL.actEmergencyCall is set to 'true' for both cells
    ...  - MRBTS/NRBTS/NRCELL.arpPrioEmergencyCall is set to '5' for both cells
    ...  - MRBTS/NRBTS/NRCELL.actVoNR is set to 'true' for both cells
    ...  - MRBTS/NRBTS/NRDRB_5QI objects are configured for 5QI-1 and 5QI-5
    ...  - Both cells have NRCELL/NRREL object, which indicates relation to neighbor cell
    ...  - MRBTS/NRBTS/NRCELL-1.trackingAreaDN support only one slice PDU session
    ...  - MRBTS/NRBTS/NRCELL-2.trackingAreaDN support all slices PDU sessions
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AEQE radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_PM_400
    ...
    ...  == REQUIRED LOGS ==
    ...    F1AP, NR-RRC, NGAP pcap
    ...
    ...  == CONTACTS ==
    ...  - Mateusz Matusik (Nokia - PL/Krakow) <mateusz.matusik@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB007564-B#US9 QosFlow Release due to HO
    ...
    ...  == HISTORY ==
    ...     [17.11.2021] - TC Create

    [Setup]  Prepare test environment B104-TC1
    [Tags]  B104-TC1  GQC_PLAN:FEATURE:CB007564-5G-B

    Attach UE1 to gNB2 NRCELL-1 and setup initial PDU Session with one QoS Flow
    Verify that UE1 was attached to gNB2 NRCELL-1
    Add secondary QoS flow to UE1 initial PDU Session

    Trigger intra-gNB Handover to NRCELL-2 for UE1
    Verify that UE1 handover was successful

    Collect PM counters file
    Verify that M55125C09013 NG_FLOW_STP_ATT_INC_HO counter is equal 0 in NRCELL-1 cell in gNB2
    Verify that M55125C09014 NG_FLOW_STP_SUC_INC_HO counter is equal 0 in NRCELL-1 cell in gNB2
    Verify that M55125C09015 NG_FLOW_REL_IANR_SUC_HO counter is equal 2 in NRCELL-1 cell in gNB2
    Verify that M55125C09016 NG_FLOW_REL_IRAT_SUC_HO counter is equal 0 in NRCELL-1 cell in gNB2

    Verify that M55125C09013 NG_FLOW_STP_ATT_INC_HO counter is equal 2 in NRCELL-2 cell in gNB2
    Verify that M55125C09014 NG_FLOW_STP_SUC_INC_HO counter is equal 2 in NRCELL-2 cell in gNB2
    Verify that M55125C09015 NG_FLOW_REL_IANR_SUC_HO counter is equal 0 in NRCELL-2 cell in gNB2
    Verify that M55125C09016 NG_FLOW_REL_IRAT_SUC_HO counter is equal 0 in NRCELL-2 cell in gNB2

    Verify that M55125C09001 NG_FLOW_REL_GNB_NG_RESET counter is equal 0 in NRCELL-1 cell in gNB2
    Verify that M55125C09007 NG_FLOW_REL_GNB_TRS counter is equal 0 in NRCELL-1 cell in gNB2
    Verify that M55125C09001 NG_FLOW_REL_GNB_NG_RESET counter is equal 0 in NRCELL-2 cell in gNB2
    Verify that M55125C09007 NG_FLOW_REL_GNB_TRS counter is equal 0 in NRCELL-2 cell in gNB2

    #Run Keyword And Continue On Failure     Verify that M55125C08503 NG_FLOW_REL counter is equal 0 in NRCELL-1 cell in gNB2
    #Run Keyword And Continue On Failure     Verify that M55125C08504 NG_FLOW_REL_NORMAL counter is equal 0 in NRCELL-1 cell in gNB2
    #Run Keyword And Continue On Failure     Verify that M55125C08503 NG_FLOW_REL counter is equal 0 in NRCELL-2 cell in gNB2
    #Run Keyword And Continue On Failure     Verify that M55125C08504 NG_FLOW_REL_NORMAL counter is equal 0 in NRCELL-2 cell in gNB2

    Prepare UE1 for partial HO
    Add secondary PDU Session to UE1 with one QoS Flow with s-nssai not supported in NRCELL-1
    Trigger partial intra-gNB Handover to NRCELL-1 for UE1
    Verify that UE1 partial handover was successful

    Remove emergency configuration from UE1

    Collect PM counters file
    Verify that M55125C09013 NG_FLOW_STP_ATT_INC_HO counter is equal 3 in NRCELL-1 cell in gNB2
    Verify that M55125C09014 NG_FLOW_STP_SUC_INC_HO counter is equal 2 in NRCELL-1 cell in gNB2
    Verify that M55125C09015 NG_FLOW_REL_IANR_SUC_HO counter is equal 0 in NRCELL-1 cell in gNB2
    Verify that M55125C09016 NG_FLOW_REL_IRAT_SUC_HO counter is equal 0 in NRCELL-1 cell in gNB2

    Verify that M55125C09013 NG_FLOW_STP_ATT_INC_HO counter is equal 0 in NRCELL-2 cell in gNB2
    Verify that M55125C09014 NG_FLOW_STP_SUC_INC_HO counter is equal 0 in NRCELL-2 cell in gNB2
    Verify that M55125C09015 NG_FLOW_REL_IANR_SUC_HO counter is equal 2 in NRCELL-2 cell in gNB2
    Verify that M55125C09016 NG_FLOW_REL_IRAT_SUC_HO counter is equal 0 in NRCELL-2 cell in gNB2

    Verify that M55125C09001 NG_FLOW_REL_GNB_NG_RESET counter is equal 0 in NRCELL-1 cell in gNB2
    Verify that M55125C09007 NG_FLOW_REL_GNB_TRS counter is equal 0 in NRCELL-1 cell in gNB2
    Verify that M55125C09001 NG_FLOW_REL_GNB_NG_RESET counter is equal 0 in NRCELL-2 cell in gNB2
    Verify that M55125C09007 NG_FLOW_REL_GNB_TRS counter is equal 0 in NRCELL-2 cell in gNB2

    #Run Keyword And Continue On Failure     Verify that M55125C08503 NG_FLOW_REL counter is equal 0 in NRCELL-1 cell in gNB2
    #Run Keyword And Continue On Failure     Verify that M55125C08504 NG_FLOW_REL_NORMAL counter is equal 0 in NRCELL-1 cell in gNB2
    #Run Keyword And Continue On Failure     Verify that M55125C08503 NG_FLOW_REL counter is equal 2 in NRCELL-2 cell in gNB2
    #Run Keyword And Continue On Failure     Verify that M55125C08504 NG_FLOW_REL_NORMAL counter is equal 2 in NRCELL-2 cell in gNB2

    Add secondary PDU Session to UE1 with one QoS Flow
    Trigger unsuccessful intra-gNB Handover to NRCELL-2 for UE1
    Verify that UE1 handover failed due to lack of response to RRC Reconfiguration
    Verify that UE1 context was released with cause: "radioNetwork: radio-connection-with-ue-lost"

    Collect PM counters file
    Verify that M55125C09013 NG_FLOW_STP_ATT_INC_HO counter is equal 0 in NRCELL-1 cell in gNB2
    Verify that M55125C09014 NG_FLOW_STP_SUC_INC_HO counter is equal 0 in NRCELL-1 cell in gNB2
    Verify that M55125C09015 NG_FLOW_REL_IANR_SUC_HO counter is equal 0 in NRCELL-1 cell in gNB2
    Verify that M55125C09016 NG_FLOW_REL_IRAT_SUC_HO counter is equal 0 in NRCELL-1 cell in gNB2

    Verify that M55125C09013 NG_FLOW_STP_ATT_INC_HO counter is equal 3 in NRCELL-2 cell in gNB2
    Verify that M55125C09014 NG_FLOW_STP_SUC_INC_HO counter is equal 0 in NRCELL-2 cell in gNB2
    Verify that M55125C09015 NG_FLOW_REL_IANR_SUC_HO counter is equal 0 in NRCELL-2 cell in gNB2
    Verify that M55125C09016 NG_FLOW_REL_IRAT_SUC_HO counter is equal 0 in NRCELL-2 cell in gNB2

    Verify that M55125C09005 NG_FLOW_REL_GNB_UE_LOST counter is equal 3 in NRCELL-1 cell in gNB2
    Verify that M55125C09005 NG_FLOW_REL_GNB_UE_LOST counter is equal 0 in NRCELL-2 cell in gNB2
    Verify that M55125C09001 NG_FLOW_REL_GNB_NG_RESET counter is equal 0 in NRCELL-1 cell in gNB2
    Verify that M55125C09007 NG_FLOW_REL_GNB_TRS counter is equal 0 in NRCELL-1 cell in gNB2
    Verify that M55125C09001 NG_FLOW_REL_GNB_NG_RESET counter is equal 0 in NRCELL-2 cell in gNB2
    Verify that M55125C09007 NG_FLOW_REL_GNB_TRS counter is equal 0 in NRCELL-2 cell in gNB2

    #Run Keyword And Continue On Failure     Verify that M55125C08503 NG_FLOW_REL counter is equal 3 in NRCELL-1 cell in gNB2
    #Run Keyword And Continue On Failure     Verify that M55125C08504 NG_FLOW_REL_NORMAL counter is equal 0 in NRCELL-1 cell in gNB2
    #Run Keyword And Continue On Failure     Verify that M55125C08503 NG_FLOW_REL counter is equal 0 in NRCELL-2 cell in gNB2
    #Run Keyword And Continue On Failure     Verify that M55125C08504 NG_FLOW_REL_NORMAL counter is equal 0 in NRCELL-2 cell in gNB2

    [Teardown]  Cleanup after test B104-TC1
