*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...
...      == INTRODUCTION ==
...      This sub-feature introduces mobility and non-basic measurements scenarios with inter-gNB NR-DC enabled:
...      - for incoming HO
...      - for ICS
...      - for retry timer related handling
...      - for IWK with RRC-Inactive
...
...      == TEST SET NAME ==
...      CB008490-M: Incoming mobility and non-basic measurement scenarios/legacy interactions
...
...      == TESTING SPLIT ==
...      For incoming HO:
...      CB008490-SR-M-B101 A2 MeasReport queued during PSCell Addition and during TakeBack
...      CB008490-SR-M-B102 Intra gNB HO with MFBI - mobillity measurements activated on UE when DU changed band to alternative
...
...      For ICS:
...      CB008490-SR-M-B1101 UE Cap Enquiry during not optimized ICS to cell with disabled NRDC
...      CB008490-SR-M-B1201 ICS optimized with non eligible PDU gNB blocks A3 A5 A2 for FWA
...      CB008490-SR-M-B1201 ICS optimized with A2 redirection support gNB blocks A2 A3 A5
...      CB008490-SR-M-B1202 ICS not optimized with MFBI gNB configures A3 A5 A2 and A4 for NRDC is not activated
...      CB008490-SR-M-B1202 ICS not optimized with MRL gNB configures A3 A5 A2 and A4 for NRDC is not activated
...      CB008490-SR-M-B1301 Blocking mobility measurements and allowing A2 for redirection during PDU Session Setup
...      CB008490-SR-M-B1302 Allowing mobility and A2 measurements for redirection during PDU Session Setup with MFBI when DU changes band to
...      alernative
...
...      For retry timer related handling:
...      CB008490-SR-M-B1701 A4retryTimer restart when no NRDC eligible PDU on UE
...      CB008490-SR-M-B1702 A4retryTimer restart blocked when CB008490 disabled
...      CB008490-SR-M-B1702 A4retryTimer restart blocked when proper NRADJNRCELL not found
...      CB008490-SR-M-B1801 A4 for NRDC after TakeBack activated after A4RetryTimer expiry
...
...      == TESTING SCOPE ==
...      CB008490-SR-M-B1202 ICS not optimized with MFBI gNB configures A3 A5 A2 and A4 for NRDC is not activated
...      CB008490-SR-M-B1302 Allowing mobility and A2 measurements for redirection during PDU Session Setup with MFBI when DU changes band to
...      alernative
...      CB008490-SR-M-B102 Intra gNB HO with MFBI - mobillity measurements activated on UE when DU changed band to alternative
...
...      == CONTACTS ==
...         - Malgorzata Konior     <malgorzata.konior@nokia.com>
...         - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
...
...      == MAINTAINER ==
...         - Malgorzata Konior     <malgorzata.konior@nokia.com>
...         - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
...
...      == REFERENCES ==
...         CB008490 CFAM - https://gates.nsn-net.net/view/000271e7#o=1260
...
...      == HISTORY ==
...      M-B12-3:
...      [29.04.2024] - Create Test Suite
...      [10.05.2024] - Final shape of M-B12-3 Test Case
...      [10.05.2024] - Review M-B12-3 closed (https://collab.ext.net.nokia.com/ui#review:id=906087)
...      M-B13-ALT1:
...      [22.05.2024] - Create Test Suite
...      [24.05.2024] - Final shape of M-B13-ALT1 Test Case
...      [04.06.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=911923)
...      M-B102:
...      [15.04.2024] - Create Test Suite
...      [23.05.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=909618)
...
...      [05.06.2024] - Merge M-B12-3, M-B13-ALT1 and M-B102 into one TC

Resource    ../resources/CB008490-common_keywords.robot
Resource    ../resources/CB008490_setup_and_teardowns.robot
Resource    ../resources/CB008490-flows_with_sim_gNB.robot

Force Tags    CONFIGURED    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_LO_AP_LO
...    VARIANT_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup    Run setup    f1ap_gNBs=MN    sim_gNB=SN

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/M/egate_3c_n78_n78_n257_TDD_SA_simSN.lua
${SCF_gnb2_MN}=           Krakow/CB008490/M/sfc_3cells_n78_n78_n257_simSN_with_MFBI.xml
${AP_XML}=                Krakow/CB008490/M/iphy_3cells_n78_n78_n257_simSN.xml

${yaml_A2_redirection}=   ${CURDIR}/config/yaml/A2_redirection.yaml
${A2_redirect_ssb_freq}=  633312

*** Test Cases ***
CB008490-SR-M-B12-B13-B102 Interactions with MFBI
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario describes the behavior when MFBI is enabled on the MN-gNB side and:
    ...   - the gNB shall block A4 measurements and does not start A4 retryTimer for a FWA UE after successful attach
    ...     (not optimized Initial Context Setup) on a cell where NR-DC feature is enabled and there is NR-DC eligible
    ...     PDU Session established for the UE. Additionally, the scenario checks that the gNB does NOT determine to block
    ...     A2/A3/A5 measurements for FWA UE.
    ...   - the gNB shall block NR-DC A4 measurements activation on UE when the returned NrBand of the PCell from DU is
    ...     changed from the native band to an alternative band during first PDU Session Setup, and the gNB configures
    ...     A2/A3/A5 measurements for mobility purpose and A2 measurements for redirection on UE.
    ...   - the gNB shall block NR-DC A4 measurements activation on UE during intra-gNB inter-cell HO when the returned
    ...     NrBand of the PCell from DU is changed from the native band to an alternative band.
    ...     gNB-CU-CP blocks A3/A5/A2 for mobility purpose on UE via F1AP:UE Context Modification Request
    ...     on target cell. But the received NrBand of the PCell is overwritten via F1AP:UE Context Modification Response
    ...     by DU to an alternative one, So gNB-CU-CP doesn't block A3/A5/A2 for mobility purpose on UE via RRCReconfiguration
    ...     message. Upon handover completion gNB-CU-CP doesn't configure any NR-DC A4 measurement to UE. And gNB-CU-CP
    ...     doesn't start A4 Retry Timer.
    ...
    ...  == PRECONDITION ==
    ...  - MN and SN gNB are configured as in CFAM CB008490-M Common Preconditions #1 5G_RAN_USR_RRM_23189 and #2 5G_RAN_USR_RRM_23190
    ...    with addition to:
    ...      MN:
    ...         - MN-NRBTS-2/NRCELL-1 SA cell simulated on AEQE radio module (PCI-50)
    ...              - NR_BAND: n78 – native band
    ...              - NR_BAND: n77 – alternative band
    ...              - NR-DC enabled (actNrDualConnectivity is set to inter-gNB_FR1-FR2)
    ...          - MN-NRBTS-2/NRCELL-2 simulated on AEQE radio module (PCI-51)
    ...              - NR_BAND: n78 – native band
    ...              - NR-DC disabled (actNrDualConnectivity is set to disabled)
    ...
    ...        SN:
    ...           - SN-NRBTS-3/NRCELL-3 simulated on EGATE - NR_BAND: n257 (PCI-52)
    ...           - NRCELL-3 is active in pure NR-DC-SN mode of operation
    ...
    ...    - MN-NRBTS-2/actMultiFrequencyBandIndicatorNRSupport is set to true
    ...    - MN-NRBTS-2/actMfbiNrCaSupportFr1 =  false (CB007219)
    ...    - MN-NRBTS-2/NRCONNECTMODE_PROFILE-0/multiFreqBandIndicatorNR is set to n77
    ...    - MN-NRBTS-2/NRCELL-1/nrConnectModeProfileDN pointing to NRCONNECTMODE_PROFILE-0
    ...    - MN-NRBTS-2/actRedirect is set to true
    ...    - MN-NRBTS-2/NRCELL-1/NRREDRT-1 is configured
    ...
    ...    - UE4 supports n77 and n257, but not n78. NR-DC band combination n77-n257 is supported by UE4
    ...    - UE5 and UE6 support n77, n78 and n257 bands and n77-n257, n78-n257 NR-DC band combinations, but n77_n257
    ...        has more mimo layers (four layers) than n78_n258 (two layers) in DL+UL direction for the PCell band.
    ...
    ...  == POSTCONDITION ==
    ...  - UE4, UE5 and UE6 are in RRC-CONNECTED state on NRCELL-1 without A4 NR-DC measurements and with A2/A3/A5 for
    ...     mobility and A2 for redirection measurements configured
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...    - HARDWARE ID:  real gNB2 (ASIL + ABIO) with simulated 1x AEQE in SA mode as MN
    ...  - sim gNB3 in NR-DC-SN mode as SN
    ...  - UEs configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_23189,5G_RAN_USR_RRM_23190,5G_RAN_USR_RRM_23179,5G_RAN_USR_RRM_24312,
    ...                             5G_RAN_USR_RRM_24313, 5G_RAN_USR_RRM_23178
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC, NGAP, F1AP, E1AP, XNAP
    ...
    ...  == CONTACTS ==
    ...     - Malgorzata Konior     <malgorzata.konior@nokia.com>
    ...     - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  - CB008490-M#B12 Not activate inter-frequency A4 measurement for NR-DC PSCell Addition but start A4 Retry Timer for FWA UE after ICS
    ...    (Initial Context Setup) - ALT1: In the Preconditions, MFBI is enabled on the MN gNB side (NRBTS.actMultiFrequencyBandIndicatorNRSupport
    ...    is set to 'true'). And UE connects to target PCell with an alternative band.
    ...  - US CB008490-M#B13 Not activate A3/A5/A2 on FWA UE during the first PDU Session Resource Setup Request – ALT1: Block NR-DC A4 measurements
    ...    activation on UE when the returned NrBand of the PCell from DU is changed from the native band to an alternative band and don't block
    ...    A3/A5/A2
    ...  - US CB008490-M#B1 Activate inter-frequency A4 measurements for NR-DC PSCell Addition after intra-gNB intra-DU
    ...    Handover for NR-DC setup (excluding intra-DU intra-Cell handover) - ALT4.1
    ...
    ...  == HISTORY ==
    ...      M-B12-3:
    ...      [29.04.2024] - Create Test Suite
    ...      [10.05.2024] - Final shape of M-B12-3 Test Case
    ...      [10.05.2024] - Review M-B12-3 closed (https://collab.ext.net.nokia.com/ui#review:id=906087)
    ...      M-B13-ALT1:
    ...      [22.05.2024] - Create Test Suite
    ...      [24.05.2024] - Final shape of M-B13-ALT1 Test Case
    ...      [04.06.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=911923)
    ...      M-B102:
    ...      [15.04.2024] - Create Test Suite
    ...      [23.05.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=909618)
    ...
    ...      [05.06.2024] - Marge M-B12-3, M-B13-ALT1 and M-B102 into one TC

    [Setup]  Prepare test environment CB008490-M-B12-B13-B102

    # CB008490-SR-M-B1202 ICS not optimized with MFBI gNB configures A3 A5 A2 and A4 for NRDC is not activated
    Attach UE4 without ICS to MN gNB2 NRCELL-1

    Set expected messages flows to check UECapabilityEnquiry request for UE4
    Set expected messages flows for PDU session setup with A2/A3/A5 measurements and no A4 measurement configuration for UE4
    Add to UE4 initial PDU session with ICS and indexToRFSP equal 1
    Verify that expected message flows for UECapabilityEnquiry request occured for UE4
    Verify expected messages flows for PDU session setup with A2/A3/A5 measurements and no A4 measurement configuration for UE4

    Verify in UECapabilityEnquiry that includeNR-DC IE is set for UE4
    Verify in UECapabilityEnquiry that message includes request for bands:n77,n78,n257 for UE4

    Verify that A2,A3,A5 measurements are configured for UE4 in RRCReconfiguration message
    Verify that A4 measurements are not configured for UE4 in RRCReconfiguration message

    Expect that A4 measurements are not configured after retryTimer eq 10 expiry for UE4
    Verify that A4 measurements are not configured after retryTimer eq 10 expiry for UE4

#    # CB008490-SR-M-B1302 Allowing mobility and A2 measurements for redirection during PDU Session Setup with MFBI
#    #                     when DU changes band to alternative
#    Set indexToRFSP to 1 for UE5
#    Set expected messages flows to check that A2,A3,A4,A5 measurements are not installed after ICS with no PDU session setup UE5
#    Attach UE5 to gNB2 cell1 with ICS without PDU session
#    Verify expected messages flows to check that A2,A3,A4,A5 measurements are not installed after ICS with no PDU session setup UE5
#    Verify in UECapabilityEnquiry that includeNR-DC IE is set for UE5
#    Verify in UECapabilityEnquiry that message includes request for bands:n77,n78,n257 for UE5
#
#    Set expected messages flows for PDU session setup after ICS with A2/A3/A5 and no A4 measurement configuration for UE5
#    Add to UE5 initial PDU session after ICS
#    Verify expected messages flows for PDU session setup after ICS with A2/A3/A5 and no A4 measurement configuration for UE5
#
#    Verify that UEContextSetupRequest contains A2,A3,A5 measurements
#    Verify that UEContextSetupRequest contains 4 measurements in total
#    Verify that A2,A3,A5 measurements are configured for UE5 in RRCReconfiguration message
#    # mobility purposes and A2 for redirection, by checking total amount of measurements
#    Verify that in total 4 measurements are configured for UE5 in RRCReconfiguration message
#    Verify that A4 measurements are not configured for UE5 in RRCReconfiguration message
#
#    Expect that A4 measurements are not configured after retryTimer eq 10 expiry for UE5
#    Verify that A4 measurements are not configured after retryTimer eq 10 expiry for UE5
#
#    # CB008490-SR-M-B102 Intra gNB HO with MFBI - mobillity measurements activated on UE when DU changed band to alternative
#    Attach UE6 without ICS to MN gNB2 NRCELL-2
#    Set expected messages flows for PDU session setup with A2/A3/A5 measurements and no A4 measurement configuration for UE6
#    Add to UE6 initial PDU session with ICS and indexToRFSP equal 1
#    Verify expected messages flows for PDU session setup with A2/A3/A5 measurements and no A4 measurement configuration for UE6
#
#    Expect that A4 measurements are not configured after HO for UE6
#    Trigger intra-gNB inter-cell HO to NRCELL-1 for UE6
#    Verify that A4 measurements are not configured after HO for UE6
#    Verify that A2,A3,A5 measurements are not deactivated for UE6 in RRCReconfiguration message

    [Teardown]  Basic cleanup sim SN
