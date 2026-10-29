*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...
...      == INTRODUCTION ==
...      This subfeature brings the support for:
...      - the mechanism to block NR-DC A4 measurements (to be reused later by other A4 types) for a short period of time
...        in case there is no measurement report received in a certain number of consecutive supervision/retry cycles
...      - the interactions between NR-DC A4 measurements and other A4 measurements
...      - the interaction between NR-DC A4 and B1 measurement for redirect to LTE
...
...      == TEST SET NAME ==
...      CB008490-MA Other mobility/measurements interactions
...
...      == TESTING SPLIT ==
...      CB008490-MA#B1: Blocking periodical NR-DC A4 activation for a configurable period if UE stays in area without
...      NR-DC PSCell coverage
...      CB008490-MA#IWK1 Interaction with CB007517
...      CB008490-MA#IWK2 Interaction with CB009205
...      CB008490-MA#IWK3 Interaction with CB006733
...      CB008490-MA#IWK4 Interaction with CB012118 (Voice fallback to LTE - Measurement-based redirection
...
...      == TESTING SCOPE ==
...      CB008490-MA#B1: Blocking periodical NR-DC A4 activation for a configurable period if UE stays in area without
...      NR-DC PSCell coverage
...      CB008490-MA#IWK1 Interaction with CB007517
...      CB008490-MA#IWK2 Interaction with CB009205
...
...      == CONTACTS ==
...         - Malgorzata Konior     <malgorzata.konior@nokia.com>
...         - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
...         - Maciej Madej          <maciej.madej@nokia.com>
...
...      == MAINTAINER ==
...         - Malgorzata Konior     <malgorzata.konior@nokia.com>
...         - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
...         - Maciej Madej          <maciej.madej@nokia.com>
...
...      == REFERENCES ==
...         CB008490 CFAM - https://gates.nsn-net.net/view/000271e7#o=1038
...
...      == HISTORY ==
...      [28.11.2024] - Create Test Suite
...      [27.11.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=922710)
...
Resource    resources/CB008490-common_keywords.robot
Resource    resources/CB008490_setup_and_teardowns.robot
Resource    resources/CB008490-flows_with_sim_gNB.robot
Resource    resources/CB008490_pm_counters.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_LO_AP_LO/CLOUD_5G_I_MP_AP_LO
...    VARIANT_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup    Run setup    f1ap_gNBs=MN    sim_gNB=SN

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/M/egate_3c_n78_n78_n257_TDD_SA_simSN.lua
${SCF_gnb2_MN}=           Krakow/CB008490/scfc-MA-IWK7517_GMC.xml
${AP_XML}=                Krakow/CB008490/M/iphy_3cells_n78_n78_n257_simSN.xml

${yaml_A2_redirection}=   ${CURDIR}/config/yaml/A2_redirection.yaml
${A2_redirect_ssb_freq}=  633312

*** Test Cases ***
CB008490-SR-MA-IWK1 Interaction with CB007517
    [Tags]  IWK7517
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This scenario verifies that when both CB008490 and CB007517 are enabled in a given cell UEs eligible for
    ...  NR-DC would get configured exclusively (regarding A4s) with NR-DC A4s and UEs not eligible for NR-DC would be
    ...  considered for CB007517 A4s activation
    ...
    ...  == PRECONDITION ==
    ...  - 5G_RAN_USR_RRM_25696 - CB008490-MA common definition
    ...  - CB007517-C preconditions
    ...    UE is considered as NR-DC allowed UE or NR-DC disallowed UE per 5G_CP_ARC_ALG_11202
    ...  - NRBTS.NRCELL.a4PeriodicMeasControlSA/a4RetryTimer = 10 (seconds)
    ...  - NRBTS.NRCELL.a4PeriodicMeasControlSA/a4MeasMaxNumber = 2
    ...  - NRBTS.NRCELL.a4PeriodicMeasControlSA/a4MeasActBlockTimer = 35 (seconds)
    ...  - NRBTS.actHigherPrioFreqHo = SA
    ...
    ...  == POSTCONDITION ==
    ...  Inter-frequency A4 NR-DC measurements are activated successfully at the UE2 and A4 supervision timer is running at PCell.
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB simulated BTS sim_SN
    ...  - gNB classical BTS in SA mode as MN - gNB_MN
    ...  - gNB module MN (ASIL + ABIO + ABIO / ASIM + ABIP + ABIP)
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_25614
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP,XNAP
    ...
    ...  == CONTACTS ==
    ...     - Malgorzata Konior     <malgorzata.konior@nokia.com>
    ...     - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
    ...     - Maciej Madej          <maciej.madej@nokia.com>
    ...
    ...  == MAINTAINER ==
    ...     - Malgorzata Konior     <malgorzata.konior@nokia.com>
    ...     - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
    ...     - Maciej Madej          <maciej.madej@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US: CB008490-MA#IWK2 Interaction with CB009205
    ...
    ...  == HISTORY ==
    ...  [28.11.2024] - Create Test Suite
    ...  [27.11.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=922710)

    [Setup]  Prepare test environment CB008490-MA-B101_1

    Attach UE2 without ICS to MN gNB2 NRCELL-2

    Set expected messages flows to check UECapabilityEnquiry request for UE2
    Set expected messages flows for PDU session setup with A2/A3/A5 measurements and no A4 measurement configuration for UE2
    Add to UE2 initial PDU session with ICS and indexToRFSP equal 2
    Verify that expected message flows for UECapabilityEnquiry request occured for UE2
    Verify expected messages flows for PDU session setup with A2/A3/A5 measurements and no A4 measurement configuration for UE2

    Trigger intra-gNB inter-cell HO to NRCELL-1 for UE2
    #A4 retrey timer running ~10a
    EXPECT FLOW[timeout=12]: UE_2 NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=12]: UE_2 NR-RRC RRCReconfigurationComplete
    PASS FLOW[timeout=12]: UE_2 NR-RRC RRCReconfiguration
    PASS FLOW[timeout=12]: UE_2 NR-RRC RRCReconfigurationComplete

    Verify CB007517 A4 measurement setup after HO for UE2

    #Wait until a4Fr2SupervisionTimer expires ~10s, numA4SupCyclesWoMeasRpt = 1
    Verify A4 meauserment deactivation for UE2 with timeout=12s
    #wait until a4RetryTimer expires ~10s
    Verify A4 meauserment activation for UE2 with timeout=12s
    #Wait until a4Fr2SupervisionTimer expires ~10s, numA4SupCyclesWoMeasRpt = 2
    Verify A4 meauserment deactivation for UE2 with timeout=12s
    Verify that A4 measurerment is not activated for UE2 during blockTimer running period with timeout=35s
    #wait until a4RetryTimer expires ~10s, numA4SupCyclesWoMeasRpt = 1
    Verify A4 meauserment activation for UE2 with timeout=12s

    Trigger UE2 to send deregister request

    Attach UE2 without ICS to MN gNB2 NRCELL-1
    Add to UE2 initial PDU session with ICS and indexToRFSP equal 2

    #A4 retrey timer running ~10a
    EXPECT FLOW[timeout=12]: UE_2 NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=12]: UE_2 NR-RRC RRCReconfigurationComplete
    PASS FLOW[timeout=12]: UE_2 NR-RRC RRCReconfiguration
    PASS FLOW[timeout=12]: UE_2 NR-RRC RRCReconfigurationComplete

    Verify CB007517 A4 measurement setup after HO for UE2

    Set expected messages flows for Reestablishment for UE2
    Trigger UE2 reestablishment
    Verify expected messages flows for Reestablishment for UE2

    #wait until a4RetryTimer expires ~10s
    Verify A4 meauserment activation for UE2 with timeout=12s

    Trigger UE2 to send deregister request

    Attach UE1 without ICS to MN gNB2 NRCELL-1
    Add to UE1 initial PDU session with ICS and indexToRFSP equal 1

    #Wait until a4Fr2SupervisionTimer expires ~10s, numA4SupCyclesWoMeasRpt = 1
    Verify A4 meauserment deactivation for UE1 with timeout=12s
    #wait until a4RetryTimer expires ~10s
    Verify A4 meauserment activation for UE1 with timeout=12s
    #Wait until a4Fr2SupervisionTimer expires ~10s, numA4SupCyclesWoMeasRpt = 2
    Verify A4 meauserment deactivation for UE1 with timeout=12s

    Verify that A4 measurerment is not activated for UE1 during blockTimer running period with timeout=35s

    [Teardown]  CB008490-MA-B101 cleanup


*** Keywords ***
Trigger UE${ue_id} reestablishment
    Trigger UE${ue_id} reestablishment via RRC Setup

Trigger intra-gNB inter-cell HO to NRCELL-${cell_id:\d+} for UE${ue_id:\d+}
    ${pci} =    Evaluate    ${49} + ${cell_id}

    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC MeasurementReport
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    Execute egate command
    ...    cmd=ue_ho_nr ue_id=${ue_id} tgt_phycell_id=${pci} meas_type=A3 tgt_cell_ssb_frequency=640032
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC MeasurementReport
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Verify A4 measurement release for UE${ue_id:\d+}
    ${flow_alias}=     Get flow name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     measIdToRemoveList is present
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias}

Verify A4 measurement setup for UE${ue_id:\d+}
    ${flow_alias}=     Get flow name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     measIdToAddModList is present
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias}
