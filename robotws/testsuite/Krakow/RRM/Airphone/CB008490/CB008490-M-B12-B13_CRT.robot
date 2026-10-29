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
...      CB008490-SR-M-B1302 Blocking mobility measurements and allowing A2 for redirection during PDU Session Setup
...
...      For retry timer related handling:
...      CB008490-SR-M-B1701 A4retryTimer restart when no NRDC eligible PDU on UE
...      CB008490-SR-M-B1702 A4retryTimer restart blocked when CB008490 disabled
...      CB008490-SR-M-B1702 A4retryTimer restart blocked when proper NRADJNRCELL not found
...      CB008490-SR-M-B1801 A4 for NRDC after TakeBack activated after A4RetryTimer expiry
...
...      == TESTING SCOPE ==
...      CB008490-SR-M-B1201 ICS optimized with non eligible PDU gNB blocks A3 A5 A2 for FWA
...      CB008490-SR-M-B1201 ICS optimized with A2 redirection support gNB blocks A2 A3 A5
...      CB008490-SR-M-B1202 ICS not optimized with MRL gNB configures A3 A5 A2 and A4 for NRDC is not activated
...      CB008490-SR-M-B1301 Blocking mobility measurements and allowing A2 for redirection during PDU Session Setup
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
...      M-B12-1
...      [10.04.2024] - Create Test Suite
...      [10.04.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=906087)
...      M-B12-2
...      [25.04.2024] - Create Test Suite
...      [26.04.2024] - Final shape of M-B12-2 Test Case
...      [26.04.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=906087)
...      M-B12-4
...      [13.05.2024] - Create Test Suite
...      [15.05.2024] - Final shape of M-B12-4 Test Case
...      [15.05.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=906087)
...      M-B13-1
...      [19.04.2024] - Create Test Suite
...      [24.04.2024] - Final shape of M-B13 Test Case
...      [24.04.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=906087)
...
...      [05.06.2024] - Merge M-B12-1, M-B12-2, M-B12-4 and M-B13-1 into one TC
...
Resource    resources/CB008490-common_keywords.robot
Resource    resources/CB008490_setup_and_teardowns.robot
Resource    resources/CB008490-flows_with_sim_gNB.robot

Force Tags    CONFIGURED    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_LO_AP_LO
...    VARIANT_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup    Run setup    f1ap_gNBs=MN    sim_gNB=SN

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/M/egate_3c_n78_n78_n257_TDD_SA_simSN.lua
${SCF_gnb2_MN}=           Krakow/CB008490/M/sfc_3cells_n78_n78_n257_simSN_GMC.xml
${AP_XML}=                Krakow/CB008490/M/iphy_3cells_n78_n78_n257_simSN.xml

${yaml_A2_redirection}=   ${CURDIR}/config/yaml/A2_redirection.yaml
${A2_redirect_ssb_freq}=  640032
${a4retrytimer_toleration}=    2
&{USER_5QI_TO_EGATE_QOS_FLOW_ID}=  6=1  5=2  1=3  7=4  8=5  9=6  170=7

*** Test Cases ***
CB008490-SR-M-B12-B13 NR-DC, mobility and redirection measurements handling during ICS and PDU session setup
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  This user scenario describes the behavior when:
    ...  - the gNB shall block A4 measurements and start A4 retryTimer for a FWA UE after successful attach
    ...    (optimized Initial Context Setup) on a cell where NR-DC feature is enabled and there is no NR-DC eligible
    ...    PDU Session established for the UE. Additionally, the scenario checks that the gNB determines to block A2/A3/A5
    ...    mobility measurements for FWA UE and does not block A2 for redirection measurements due to actRedirect flag enabled.
    ...   - the gNB shall block A4 measurements and start A4 retryTimer for a FWA UE after successful first PDU Session Resource Setup
    ...    (after non-optimized Initial Context Setup without PDU Session) on a cell where NR-DC feature is enabled
    ...    and there is no NR-DC eligible PDU Session established for the UE. Additionally, the scenario checks that
    ...    the gNB determines to block A2/A3/A5 moblity measurements for FWA UE and does not block A2 for redirection
    ...    measurements due to actRedirect flag enabled.
    ...   - Mobility Restriction List is provided in NGAP: Initial Context Setup for UE. The gNB shall block A4 measurements
    ...    and does not start A4 retryTimer for a FWA UE after successful attach (optimized Initial Context Setup) on a cell
    ...    where NR-DC feature is enabled and there is NR-DC eligible PDU Session established for the UE. Additionally,
    ...    the scenario checks that the gNB does NOT determine to block A2/A3/A5 measurements for FWA UE.
    ...
    ...  == PRECONDITION ==
    ...  - MN and SN gNB are configured as in CFAM CB008490-M Common Preconditions #1 5G_RAN_USR_RRM_23189 and #2 5G_RAN_USR_RRM_23190
    ...    with addition to:
    ...    - MN-NRBTS-2/NRCELL-1 simulated on AEQE radio module - NR_BAND: n78 (PCI-50)
    ...    - MN-NRBTS-2/NRCELL-2 simulated on AEQE radio module - NR_BAND: n78 (PCI-51)
    ...    - SN-NRBTS-3/NRCELL-3 simulated on EGATE - NR_BAND: n257 (PCI-52)
    ...    - Two FR1 cells (MN-NRBTS-2/NRCELL-1 and MN-NRBTS-2/NRCELL-2) are active in pure SA mode of operation:
    ...      - MN-NRBTS-2/NRCELL-1 has NR-DC enabled actNrDualConnectivity is set to inter-gNB_FR1-FR2
    ...      - MN-NRBTS-2/NRCELL-2 does not have NR-DC enabled actNrDualConnectivity is set to disabled
    ...    - One FR2 cell (SN-NRBTS-3/NRCELL-3) is active in pure NR-DC-SN mode of operation
    ...    - MN-NRBTS-2/actRedirect is set to true
    ...    - MN-NRBTS-2/NRCELL-1/NRREDRT-1 is configured
    ...    - MN-NRBTS-2/NRCELL-1/a2MeasRedirectEnabled is set to
    ...
    ...  == POSTCONDITION ==
    ...  - UE1 and UE2 are in RRC-CONNECTED state on NRCELL-1 (MN-gNB) with inter-gNB NR-DC setup with NRCELL-3 (SN-gNB)
    ...  - UE3 is in RRC-CONNECTED state on NRCELL-1 without A4 NR-DC measurements configured
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...    - HARDWARE ID:  real gNB2 (ASIL + ABIO) with simulated 1x AEQE (band n78) in SA mode as MN
    ...  - sim gNB3 in NR-DC-SN mode as SN
    ...  - UEs configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_23189,5G_RAN_USR_RRM_23190,5G_RAN_USR_RRM_23179,5G_RAN_USR_RRM_24312
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
    ...  CB008490-SR-M-B1201 ICS optimized with non eligible PDU gNB blocks A3 A5 A2 for FWA
    ...  CB008490-M#B12 Not activate inter-frequency A4 measurement for NR-DC PSCell Addition but start A4 Retry Timer for FWA UE after ICS
    ...    (Initial Context Setup) - ALT3: NRBTS.actRedirect (5GC000708) is set to true, A2 for redirection measurements won't be blocked to UE
    ...    during ICS.
    ...  CB008490-M#B12 Not activate inter-frequency A4 measurement for NR-DC PSCell Addition but start A4 Retry Timer for FWA UE after ICS
    ...    (Initial Context Setup) - ALT2: In the preconditions, Mobility Restriction List is provided in NGAP: Initial Context Setup Request message
    ...    and for the UE selected PLMN(5G_CP_ARC_ALG_887), NR RAT is restricted as the secondary RAT (a bit for 'nR' is set to "1"
    ...    in MobilityRestrictionList->rATRestrictions->ExtendedRATRestrictionInformation->secondaryRATRestriction).
    ...  CB008490-M#B13 Not activate A3/A5/A2 on FWA UE during the first PDU Session Resource Setup Request
    ...
    ...  == HISTORY ==
    ...      M-B12-1
    ...      [10.04.2024] - Create Test Suite
    ...      [10.04.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=906087)
    ...      M-B12-2
    ...      [25.04.2024] - Create Test Suite
    ...      [26.04.2024] - Final shape of M-B12-2 Test Case
    ...      [26.04.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=906087)
    ...      M-B12-4
    ...      [13.05.2024] - Create Test Suite
    ...      [15.05.2024] - Final shape of M-B12-4 Test Case
    ...      [15.05.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=906087)
    ...      M-B13-1
    ...      [19.04.2024] - Create Test Suite
    ...      [24.04.2024] - Final shape of M-B13 Test Case
    ...      [24.04.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=906087)
    ...
    ...      [05.06.2024] - Merge M-B12-1, M-B12-2, M-B12-4 and M-B13-1 into one TC

    [Setup]  Prepare test environment CB008490-M-B12-B13

    # CB008490-SR-M-B1201 ICS optimized with non eligible PDU gNB blocks A3 A5 A2 for FWA
    # CB008490-SR-M-B1201 ICS optimized with A2 redirection support gNB blocks A2 A3 A5
    Prepare NrDc UE1 candidate with 1 PDU sessions with 1 non-GBR and 1 signalling QoS Flow on NRCELL-1

    Set expected messages flows to check UECapabilityEnquiry request did not occure for UE1
    Set expected messages flows to check non NR-DC eligible PDU Session established for the UE1
    Set expected messages flows to check that A4 measurements are not installed after ICS with no NR-DC eligible PDU session setup for UE1

    Trigger UE1 idle mode exit

    Verify that expected message flows for UECapabilityEnquiry request did not occure for UE1
    Verify expected messages flows to check non NR-DC eligible PDU Session established for the UE1
    Verify expected messages flows to check that A4 measurements are not installed after ICS with no NR-DC eligible PDU session setup for UE1

    Verify that initial PDU session for UE1 contains 2 qos flows
    Verify that A2 for redirection is configured for UE1 in RRCReconfiguration message
    Verify that A3,A5 measurements are not configured for UE1 in RRCReconfiguration message
    Verify that A4 measurements are not configured for UE1 in RRCReconfiguration message
    Get occurence time of RRCReconfiguration after ICS for UE1

    Expect that A4 measurements are not configured after retryTimer eq 10 expiry for UE1
    Verify that A4 measurements are not configured after retryTimer eq 10 expiry for UE1

    Expect that A4 measurements are configured after adding eligible PDU session for UE1
    Reset QoS Flow settings on SMF
    Add to UE1 second PDU session after ICS
    Verify that A4 measurements are configured after adding eligible PDU session for UE1
    Verify that A4 measurements are configured in 4 out of 4 UEContextModificationRequest message
    Verify that A4 measurements are not configured for UE1 in 1 out of 2 RRCReconfiguration message
    Verify that A4 measurements are configured for UE1 in 2 out of 2 RRCReconfiguration message

    Get occurence time of RRCReconfiguration with A4 measurements installation for UE1 and verify if difference is equal 20s

    Set expected messages flows for SNodeAddition for UE1, MN real gNB2 and SN sim gNB3
    UE1 sends A4 measurement with id=3 for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for UE1, MN real gNB2 and SN sim gNB3

    # CB008490-SR-M-B1301 Blocking mobility measurements and allowing A2 for redirection during PDU Session Setup
    Set indexToRFSP to 1 for UE2
    Set expected messages flows to check that A2,A3,A4,A5 measurements are not installed after ICS with no PDU session setup UE2
    Attach UE2 to gNB2 cell1 with ICS without PDU session
    Verify expected messages flows to check that A2,A3,A4,A5 measurements are not installed after ICS with no PDU session setup UE2
    Verify in UECapabilityEnquiry that includeNR-DC IE is set for UE2
    Verify in UECapabilityEnquiry that message includes request for band:n78 and band:n257 for UE2

    Get occurence time of NGAP InitialContextSetup for AMF1

    Expect that A4 measurements are not configured after retryTimer eq 10 expiry for UE2
    Verify that A4 measurements are not configured after retryTimer eq 10 expiry for UE2

    Expect that A4 measurements are configured after adding first eligible PDU session for UE2
    Add to UE2 initial PDU session after ICS
    Verify that A4 measurements are configured after adding first eligible PDU session for UE2
    Verify that A2 measurements are configured for UE2 in 1 out of 2 RRCReconfiguration message
    Verify that A2 for redirection is configured for UE2 in 1 out of 2 RRCReconfiguration message
    Verify that A3,A5 measurements are not configured for UE2 in 1 out of 2 RRCReconfiguration message
    Verify that A4 measurements are configured in 3 out of 4 UEContextModificationRequest message
    Verify that A4 measurements are configured for UE2 in 2 out of 2 RRCReconfiguration message

    Get occurence time of RRCReconfiguration with A4 measurements installation for UE2 and verify if difference is equal 20s

    Set expected messages flows for SNodeAddition for UE2, MN real gNB2 and SN sim gNB3
    UE2 sends A4 measurement with id=3 for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for UE2, MN real gNB2 and SN sim gNB3

    # CB008490-SR-M-B1202 ICS not optimized with MRL gNB configures A3 A5 A2 and A4 for NRDC is not activated
    Set MRL with NR restricted as secondary RAT
    Attach UE3 without ICS to MN gNB2 NRCELL-1

    Set expected messages flows to check UECapabilityEnquiry request for UE3
    Set expected messages flows for PDU session setup with A2/A3/A5 measurements and no A4 measurement configuration for UE3
    Add to UE3 initial PDU session with ICS and indexToRFSP equal 1
    Verify that expected message flows for UECapabilityEnquiry request occured for UE3
    Verify expected messages flows for PDU session setup with A2/A3/A5 measurements and no A4 measurement configuration for UE3

    Verify in UECapabilityEnquiry that includeNR-DC IE is set for UE3
    Verify in UECapabilityEnquiry that message includes request for band:n78 and band:n257 for UE3

    Verify that A2,A3,A5 measurements are configured for UE3 in RRCReconfiguration message
    Verify that A4 measurements are not configured for UE3 in RRCReconfiguration message

    Expect that A4 measurements are not configured after retryTimer eq 10 expiry for UE3
    Verify that A4 measurements are not configured after retryTimer eq 10 expiry for UE3

    [Teardown]  Basic cleanup sim SN
