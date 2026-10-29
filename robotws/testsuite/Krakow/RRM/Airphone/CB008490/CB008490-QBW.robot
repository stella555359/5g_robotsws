*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...
...      == INTRODUCTION ==
...      This subfeature introduces multiple BWPs support on PCell while UE is configured with NR-DC.
...
...      == TEST SET NAME ==
...      CB008490-QBW Other interactions (BWP)
...
...      == TESTING SPLIT ==
...      CB008490-SR-QBW-IWK1 NR-DC PSCell addition with multiple BWP configuration - UE supporting full cell bandwidth of PCell
...      CB008490-SR-QBW-IWK2 NR-DC PSCell addition with multiple BWP configuration - UE not supporting full cell bandwidth of PCell
...      CB008490-SR-QBW-IWK3 Bearer takeback with multiple BWP configuration - UE not supporting full cell bandwidth of PCell
...      CB008490-SR-QBW-IWK4 NR-DC PSCell addition with power saving BWP configuration of PCell
...      CB008490-SR-QBW-EC1 NR-DC PSCell addition with multiple BWP configuration - PSCell Pre-selection fails
...
...      == TESTING SCOPE ==
...      CB008490-SR-QBW-IWK2 NR-DC PSCell addition with multiple BWP configuration - UE not supporting full cell bandwidth of PCell
...      CB008490-SR-QBW-IWK3 Bearer takeback with multiple BWP configuration - UE not supporting full cell bandwidth of PCell
...      CB008490-SR-QBW-EC1 NR-DC PSCell addition with multiple BWP configuration - PSCell Pre-selection fails
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
...         CB008490 CFAM - https://gates.nsn-net.net/view/000271e7#o=7258
...
...      == HISTORY ==
...      [02.08.2024] - Create Test Suite
...      [08.08.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=916494)
...
Resource    resources/CB008490-common_keywords.robot
Resource    resources/CB008490_setup_and_teardowns.robot
Resource    resources/CB008490-flows_with_sim_gNB.robot

Force Tags    CONFIGURED    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_LO_AP_LO
...    VARIANT_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup    Run setup    f1ap_gNBs=MN    sim_gNB=SN

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_3c_n78_n78_n257_TDD_SA_simSN_BWP.lua
${SCF_gnb2_MN}=           Krakow/CB008490/M/scf_n78_3bwp_40_70_100_GMC.xml
${AP_XML}=                Krakow/CB008490/M/iphy_3cells_n78_n78_n257_simSN_QBW.xml

&{NRCELL_1_BWP}=    ID=1    SMALL_BW=40    SECOND_BW=70    LARGE_BW=100
@{NRCELL_BWP}=      &{NRCELL_1_BWP}

*** Test Cases ***
CB008490-SR-QBW
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  Purpose of this test case is to verify gNB behaviour when PCell is configured with multiple dedicated BWPs and
    ...  UE does not support full PCell bandwidth. Test coveres following cases:
    ...  - NR-DC setup after ICS and takeback after PDU session release for UE8 supporting PSCell small BWP in NR-DC
    ...   band combination
    ...  - NR-DC setup after intra-gNB HO and takeback after RRC:SCGFailureInformation for UE9 supporting PSCell second
    ...   BWP in NR-DC band combination
    ...  - NR-DC setup after inter-gNB XN HO for UE10 supporting PSCell small BWP in NR-DC band combination
    ...  - NR-DC setup after intra-gNB reestablishment to serving cell for UE11 supporting PSCell second BWP in NR-DC
    ...   band combination
    ...  - PSCell pre-selection failure for UE12 supporting band smaller than small dedicated BWP in NR-DC band combination
    ...
    ...  == PRECONDITION ==
    ...  - MN and SN gNB are configured as in CFAM CB008490-M Common Preconditions #1 5G_RAN_USR_RRM_23189 and #2 5G_RAN_USR_RRM_23190
    ...    with addition to:
    ...    - MN-NRBTS-2/NRCELL-1 simulated on AEQE radio module - NR_BAND: n78 (PCI-50) - NR-DC enabled
    ...        large BWP3:    100MHz, BWP_PROFILE-57
    ...        second BWP2:   70MHz, BWP_PROFILE-54
    ...        small BWP1:    40MHz, BWP_PROFILE-51
    ...        initial BWP:   40Mhz, BWP_PROFILE-5
    ...    - MN-NRBTS-2/NRCELL-2 simulated on AEQE radio module - NR_BAND: n78 (PCI-51) - NR-DC disabled
    ...    - SN-NRBTS-3/NRCELL-3 simulated on EGATE - NR_BAND: n257 (PCI-52) - NR-DC-SN mode of operation
    ...    - NRBTS/actMultipleDedicatedBWPs = true (CB007552 feature flag)
    ...
    ...    UE8 supports 40MHz for n78 in DC-n78_n257 band combination
    ...    UE9 supports 70MHz for n78 in DC-n78_n257 band combination
    ...    UE10 supports 40MHz for n78 in DC-n78_n257 band combination
    ...    UE11 supports 70MHz for n78 in DC-n78_n257 band combination
    ...    UE12 supports 20MHz for n78 in DC-n78_n257 band combination
    ...
    ...  == POSTCONDITION ==
    ...   - UE8 is in RRC-CONNECTED state with NRCELL-1 small BWP
    ...   - UE9 is in RRC-CONNECTED state with NRCELL-1 second BWP
    ...   - UE10 has NR-DC configured with PSCell small BWP
    ...   - UE11 has NR-DC configured with PSCell second BWP
    ...   - UE12 is in RRC-CONNECTED state with NRCELL-1 without A4 measurements configured
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...    - HARDWARE ID:  real gNB2 (ASIL + ABIO) with simulated 1x AEQE (band n78) in SA mode as MN
    ...  - sim gNB3 in NR-DC-SN mode as SN
    ...  - sim gNB4 in SA mode for inter-gNB HO
    ...  - UEs configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_25676; 5G_RAN_USR_RRM_26376
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC, NGAP, F1AP, E1AP, XNAP
    ...
    ...  == CONTACTS ==
    ...     - Malgorzata Konior     <malgorzata.konior@nokia.com>
    ...     - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
    ...     - Maciej Madej          <maciej.madej@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...  CB008490-QBW#B2: NR-DC PSCell addition with multiple BWP configuration - UE not supporting full cell bandwidth of PCell
    ...  CB008490-QBW#B4: NR-DC PSCell addition in Handover case with multiple BWP configuration - UE is not supporting full cell bandwidth of PCell
    ...
    ...  == HISTORY ==
    ...  [02.08.2024] - Create Test Suite
    ...  [08.08.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=916494)

    [Setup]  Prepare test environment CB008490-QBW

    # ================================ ICS ========================================================

    Attach UE8 without ICS to MN gNB2 NRCELL-1
    Set expected messages flows for PDU session and A4 measurement configuration for UE8 and AMF1
    Add to UE8 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE8 and AMF1
    Verify that UE8 is configured with small BWP profile after ICS to NRCELL-1
    Add to UE8 second PDU session after ICS

    Set expected messages flows for SNodeAddition for UE8, MN real gNB2 and SN sim gNB3
    UE8 sends A4 measurement with id=1 for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for UE8, MN real gNB2 and SN sim gNB3
    Verify that UE8 is configured with PCell NRCELL-1 small BWP profile after NR-DC setup

    Set expected messages for NR-DC takeback after PDU session release for UE8, MN gNB2
    Release first PDU session for UE8
    Verify expected messages for NR-DC takeback after PDU session release for UE8, MN gNB2
    Verify that UE8 is configured with PCell NRCELL-1 small BWP profile after NR-DC takeback

    # ================================ intra-gNB HO ========================================================

#    Attach UE9 without ICS to MN gNB2 NRCELL-2
#    Set expected messages flows for PDU session setup with A2/A3/A5 measurements and no A4 measurement configuration for UE9
#    Add to UE9 initial PDU session with ICS and indexToRFSP equal 1
#    Verify expected messages flows for PDU session setup with A2/A3/A5 measurements and no A4 measurement configuration for UE9
#    Verify that A2,A3,A5 measurements are configured for UE9 in RRCReconfiguration message
#
#    Set expected messages flows to check A4 activation without DRX after HO for UE9
#    Trigger intra-gNB inter-cell HO to NRCELL-1 with ssb freq 638496 for UE9
#    Verify expected messages flows to check A4 activation without DRX after HO for UE9
#    Verify that A4 measurements are configured for UE9 in 2 out of 2 RRCReconfiguration message
#    Verify that UE9 is configured with second BWP profile after HO to NRCELL-1
#
#    Set expected messages flows for SNodeAddition for UE9, MN real gNB2 and SN sim gNB3
#    UE9 sends A4 measurement with id=4 for NR-DC PSCell addition
#    Verify expected messages flows for SNodeAddition for UE9, MN real gNB2 and SN sim gNB3
#    Verify that UE9 is configured with PCell NRCELL-1 second BWP profile after NR-DC setup
#
#    Set expected messages for NR-DC takeback after RRC:SCGFailureInformation from UE9, MN gNB2
#    UE9 sends RRC:SCGFailureInformation to MN gNB2
#    Verify expected messages for NR-DC takeback after RRC:SCGFailureInformation from UE9, MN gNB2
#    Verify that UE9 is configured with PCell NRCELL-1 second BWP profile after NR-DC takeback

    # ================================ inter-gNB HO ========================================================

    Attach UE10 to sim gNB4 cell1 with PDU session and indexToRFSP equal 1
    Set expected messages flows to check A4 activation without DRX after HO for UE10
    Trigger UE10 XN HO to gNB2 with ssb freq 638496 NRCELL-1
    Verify expected messages flows to check A4 activation without DRX after HO for UE10
    Verify that A4 measurements are configured for UE10 in 2 out of 2 RRCReconfiguration message
    Verify that UE10 is configured with small BWP profile after inter-gNB HO to NRCELL-1

    Set expected messages flows for SNodeAddition for UE10, MN real gNB2 and SN sim gNB3
    UE10 sends A4 measurement with id=7 for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for UE10, MN real gNB2 and SN sim gNB3
    Verify that UE10 is configured with PCell NRCELL-1 small BWP profile after NR-DC setup

    # ================================ reestablishment ========================================================

    Attach UE11 without ICS to MN gNB2 NRCELL-1
    Set expected messages flows for PDU session and A4 measurement configuration for UE11 and AMF1
    Add to UE11 initial PDU session with ICS and indexToRFSP equal 1
    Verify expected messages flows for PDU session and A4 measurement configuration for UE11 and AMF1
    Verify that UE11 is configured with second BWP profile after ICS to NRCELL-1

    Set expected messages flows to check A4 activation without DRX after reestablishment for UE11
    Trigger reestablishment for UE11 to gNB2 NRCELL-1
    Verify expected messages flows to check A4 activation without DRX after reestablishment for UE11
    Verify that A4 measurements are configured for UE11 in 2 out of 2 RRCReconfiguration message
    Verify that UE11 is configured with second BWP profile after reestablishment to NRCELL-1

    Set expected messages flows for SNodeAddition for UE11, MN real gNB2 and SN sim gNB3
    UE11 sends A4 measurement with id=3 for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for UE11, MN real gNB2 and SN sim gNB3
    Verify that UE11 is configured with PCell NRCELL-1 second BWP profile after NR-DC setup

    # ================================ PSCell pre-selection failure ========================================================

    Attach UE12 without ICS to MN gNB2 NRCELL-1
    Expect that A4 measurements are not configured after PDU session setup for UE12
    Add to UE12 initial PDU session with ICS and indexToRFSP equal 1
    Verify that UE12 is configured with small BWP profile after ICS to NRCELL-1
    Verify that A4 measurements are not configured after PDU session setup for UE12
    Verify that A4 measurements are not configured for UE12 in RRCReconfiguration message

    [Teardown]  QBW cleanup
