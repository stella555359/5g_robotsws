*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...
...      == INTRODUCTION ==
...      This feature extends the inter-gNB NR-DC (CB008490) with limited mobility support.
...      The NR-DC allowed UEs can be configured with mobility related measurements when entering the cell. The UEs are also
...      configured with NR-DC FR2 A4 if not conflicting with other measurements.
...      If mobility is needed, before the NR-DC is set-up, it's performed in a regular way.
...      NR-DC measurements can not co-exist with inter-frequency and inter-RAT measurements for coverage-based mobility.
...      In case both measurement types are needed, NR-DC measurements are not activated or released.
...      When NR-DC is configured, no mobility is possible until SCG is released.
...      When A3/A5 intra frequency report is received, the gNB triggers SN takeback. Handover is again possible after SCG is
...      released.
...      In case of A2 report for inter-frequency/inter-RAT mobility activation. The gNB triggers SN takeback and configures
...      the inter-frequency/inter-RAT measurements as needed.
...      NR-DC can be added again, if HO doesn't happen, or FR1 inter-freq/inter-RAT measurements are released, after
...      another round of A4 FR2 measurements.
...      The feature also allows to disable the check for RFSP and configure NR-DC for all capable devices.
...      The feature allows to prevent NR-DC for UEs having another PDU session with 5QI1 and 5GI2 bearers.
...      PM counters are updated so that it's possible to measure the number of NR-DC take-backs due to measurement reception.
...      The feature is activated automatically if NR-DC is activated in the cell. With this feature, NR-DC can be additionally
...      enabled/disabled per UE profile.
...
...      == TEST SET NAME ==
...      CB012328-EA Interaction with other features (part 1)
...
...      == TESTING SPLIT ==
...      CB012328-EA-IWK0101 Selective blocking of possibility of NR-DC setup for some UE types (interaction with
...      CB014533 and CB010938)
...      CB012328-EA-IWK0102 Selective blocking - ICS for UE#1 and UE#2 does not contain any PDU Session (which is
...      setup as part of the following PDU Session Setup procedure)
...      CB012328-EA-IWK0103 Selective blocking - missing or insufficient NR-DC UE radio capability
...      CB012328-EA-IWK0104 Selective blocking - RRC Reestablishment to the same cell
...
...      == CONTACTS ==
...         - Maciej Madej          <maciej.madej@nokia.com>
...
...      == MAINTAINER ==
...         - Maciej Madej          <maciej.madej@nokia.com>
...
...      == REFERENCES ==
...         13254863: USCB012328-EA#IWK01: Selective blocking of possibility of NR-DC setup for some UE
...         types (interaction with CB014553 and CB010938)
...
...      == HISTORY ==
...      [16.12.2025] - Create Test Suite
...      [xx.xx.xxxx] - Review closed ()
...
Resource    resources/CB012328-common_keywords.robot
Resource    resources/CB012328_setup_and_teardowns.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_LO_AP_LO/CLOUD_5G_I_MP_AP_LO
...    VARIANT_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup    Run setup    f1ap_gNBs=MN    sim_gNB=SN

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_3c_n78_n78_n257_TDD_SA_simSN.lua
${SCF_gnb2_MN}=           Krakow/CB012328/sfc_3cells_n78_n78_n257_simSN_GMC.xml
${AP_XML}=                Krakow/CB012328/iphy_3cells_n78_n78_n257_simSN.xml

${act_chipsetID_list}=      ${CURDIR}/config/yaml/act_chipsetID_list.yaml
${disable_chipsetID}=       ${CURDIR}/config/yaml/disable_chipsetID.yaml
${act_RRC_inactive}=        ${CURDIR}/config/yaml/act_RRC_inactive.yaml
${default_profile}=         ${CURDIR}/config/yaml/default_profile.yaml
${ue_1_capabilities}=       SEPARATOR=
...                         040D60881A9E7A05000574F7E03560803C5200016080080C048830004C1C2E006241A000502013018062280C0299C05AA3626EB04610D04083A422002
...                         8B65515090E7D033EC09F18E7CC31E50B0381C3C05C0077C007001DF0007080006CA0000A00000283E236B04610D04083C4220024B65515050E7D033
...                         E31CF9863CA16070387813F8000000FE000000541F107582308682041E21100125B2A8A82873E819F18E7CC31E50B0381C3C09FD8000007F60000007
...                         04000182A81681EF1C610E00151E7E2888008FDB30552003C78010E208308A8147EFE40DC6E30E40000301D02D01C0DE38C21C002A3CFC5110011FB6
...                         60AA40078F0021C4106115028FDFC81B8FC71C80000602A05A01BC718438005479F8A220023F6CC154800F1E00438820C22A051FBF90371B8C390000
...                         0C0008C3C4D000E800000000400C04D82003A80003C030A24ED8E7C301C050007A11C001F001400180E0A00E06012803800301010880082160210008
...                         00193C0100400000492800004B0079415BA40041000009652504000065949401D28AAAED40002020040080802004356140004062A38424A5008829A8
...                         50BD00803388800010800
${ue_1_insufficient}=       SEPARATOR=
...                         040D60881A9E7A05000574F7E03560803C5200016080080C048830004C1C2E006241A000502013018062280C0299C05AA3626EB04610D04083A422002
...                         8B65515090E7D033EC09F18E7CC31E50B0381C3C05C0077C007001DF0007080006CA0000A00000283E236B04610D04083C4220024B65515050E7D033E
...                         31CF9863CA16070387813F8000000FE000000541F107582308682041E21100125B2A8A82873E819F18E7CC31E50B0381C3C09FD8000007F6000000704
...                         000182A81681EF1C610E00151E7E2888008FDB30552003C78010E208308A8147EFE40DC6E30E40000301D02D01C0DE38C21C002A3CFC5110011FB660A
...                         A40078F0021C4106115028FDFC81B8FC71C80000602A05A01BC718438005479F8A220023F6CC154800F1E00438820C22A051FBF90371B8C3900000C00
...                         08C3C4D000E800000000400C04D82003A80003C030A24ED8E7C301C050007A11C001F001400180E0A00E0601280380030101088008216021000800193
...                         C0100400000492800004B0079415BA40041000009652504000065949401D28AAAED40002020040080802004356140004062A38424A5008829A850BD00
...                         803308800010800
${ue_17_capabilities}=      SEPARATOR=
...                         040D70881ABE7A0500057C8F7E03560803C5200016080080C048830004C1C2E006241A000502013018062280C0299C05AA3626EB04612D04083A48000
...                         1100145B2A8A84873E819F604F8C73E618F28581C0E1E02E003BE003800EF8003840003650000500000141F11B582308682041E21100125B2A8A82873
...                         E819F18E7CC31E50B0381C3C09FC0000007F0000002A0F883AC1184341020F10880092D954541439F40CF8C73E618F28581C0E1E04FEC000003FB0000
...                         003820000C1540B40F78E3087000A8F3F14440047ED982A9001E3C0087104184540A3F7F206E3718720000180E81680E06F1C610E00151E7E2888008F
...                         DB30552003C78010E208308A8147EFE40DC7E38E40000301502D00DE38C21C002A3CFC5110011FB660AA40078F0021C4106115028FDFC81B8DC61C800
...                         006000461E2680074000000002006026C1001D40001E01851276C73E180E028003D08E000F800A000C070500703009401C001808084400410B0108004
...                         000C9E00802000002494000025803CA0ADD20020800004B29282000032CA4A00E9455576A00010100200404010021AB0A000203151C21252804414D42
...                         85E804019C440000840
${ue_17_insufficient}=      SEPARATOR=
...                         040D70881ABE7A0500057C8F7E03560803C5200016080080C048830004C1C2E006241A000502013018062280C0299C05AA3626EB04612D04083A48000
...                         1100145B2A8A84873E819F604F8C73E618F28581C0E1E02E003BE003800EF8003840003650000500000141F11B582308682041E21100125B2A8A82873
...                         E819F18E7CC31E50B0381C3C09FC0000007F0000002A0F883AC1184341020F10880092D954541439F40CF8C73E618F28581C0E1E04FEC000003FB0000
...                         003820000C1540B40F78E3087000A8F3F14440047ED982A9001E3C0087104184540A3F7F206E3718720000180E81680E06F1C610E00151E7E2888008F
...                         DB30552003C78010E208308A8147EFE40DC7E38E40000301502D00DE38C21C002A3CFC5110011FB660AA40078F0021C4106115028FDFC81B8DC61C800
...                         006000461E2680074000000002006026C1001D40001E01851276C73E180E028003D08E000F800A000C070500703009401C001808084400410B0108004
...                         000C9E00802000002494000025803CA0ADD20020800004B29282000032CA4A00E9455576A00010100200404010021AB0A000203151C21252804414D42
...                         85E8040198440000840
${ue_17_wo_chipset_id}=     SEPARATOR=
...                         040D60881A9E7A0500057C8F7E03560803C5200016080080C048830004C1C2E006241A000502013018062280C0299C05AA3626EB04610D04083A42200
...                         28B65515090E7D033EC09F18E7CC31E50B0381C3C05C0077C007001DF0007080006CA0000A00000283E236B04610D04083C4220024B65515050E7D033
...                         E31CF9863CA16070387813F8000000FE000000541F107582308682041E21100125B2A8A82873E819F18E7CC31E50B0381C3C09FD8000007F600000070
...                         4000182A81681EF1C610E00151E7E2888008FDB30552003C78010E208308A8147EFE40DC6E30E40000301D02D01C0DE38C21C002A3CFC5110011FB660
...                         AA40078F0021C4106115028FDFC81B8FC71C80000602A05A01BC718438005479F8A220023F6CC154800F1E00438820C22A051FBF90371B8C3900000C0
...                         008C3C4D000E800000000400C04D82003A80003C030A24ED8E7C301C050007A11C001F001400180E0A00E060128038003010108800821602100080019
...                         3C0100400000492800004B0079415BA40041000009652504000065949401D28AAAED40002020040080802004356140004062A38424A5008829A850BD0
...                         080330880001080
${ue_19_insufficient}=      SEPARATOR=
...                         040D70881ABE7A0500057C8F7E03560803C5200016080080C048830004C1C2E006241A000502013018062280C0299C05AA3626EB04612D0
...                         4083A420011100145B2A8A84873E819F604F8C73E618F28581C0E1E02E003BE003800EF8003840003650000500000141F11B582308682041E21100125
...                         B2A8A82873E819F18E7CC31E50B0381C3C09FC0000007F0000002A0F883AC1184341020F10880092D954541439F40CF8C73E618F28581C0E1E04FEC00
...                         0003FB0000003820000C1540B40F78E3087000A8F3F14440047ED982A9001E3C0087104184540A3F7F206E3718720000180E81680E06F1C610E00151E
...                         7E2888008FDB30552003C78010E208308A8147EFE40DC7E38E40000301502D00DE38C21C002A3CFC5110011FB660AA40078F0021C4106115028FDFC81
...                         B8DC61C800006000461E2680074000000002006026C1001D40001E01851276C73E180E028003D08E000F800A000C070500703009401C0018080844004
...                         10B0108004000C9E00802000002494000025803CA0ADD20020800004B29282000032CA4A00E9455576A00010100200404010021AB0A000203151C2125
...                         2804414D4285E8040198440000840


*** Test Cases ***
CB012328-EA CRT
    [Documentation]
    ...  == DESCRIPTION ==
    ...  Merged testcases:
    ...  CB012328-EA-IWK0101 Selective blocking of possibility of NR-DC setup for some UE types (interaction with CB014533 and CB010938)
    ...  CB012328-EA-IWK0102 Selective blocking - ICS for UE#1 and UE#2 does not contain any PDU Session
    ...  CB012328-EA-IWK0103 Selective blocking - missing or insufficient NR-DC UE radio capability
    ...  CB012328-EA-IWK0104 Selective blocking - RRC Reestablishment to the same cell
    ...
    ...  See the description of corresponding test cases
    ...
    ...  == PRECONDITION ==
    ...  See preconditions of corresponding test cases
    ...
    ...  == TEST STEPS ==
    ...  See corresponding test cases
    ...
    ...  == POSTCONDITION ==
    ...  See corresponding test cases
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
    ...  REQUIREMENTS IN SCOPE: 13254864, 13254869, 13254863, 13254874, 13254866, 13254870, 13254871, 13254872, 13254873, 13254865
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP,XNAP
    ...
    ...  == CONTACTS ==
    ...     - Maciej Madej          <maciej.madej@nokia.com>
    ...
    ...  == MAINTAINER ==
    ...     - Maciej Madej          <maciej.madej@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  13254863: USCB012328-EA#IWK01: Selective blocking of possibility of NR-DC setup for some UE types
    ...  (interaction with CB014553 and CB010938)
    ...  == HISTORY ==
    ...  [25.03.2026] - Create Test Case

    [Setup]  Prepare test environment CB012328-EA

# CB012328-EA-IWK0101 Selective blocking of possibility of NR-DC setup for some UE types (interaction with CB014533 and CB010938)
    Log To Console    Start CB012328-EA-IWK0101

    Attach UE17 without ICS to MN gNB2 NRCELL-1
    Expect second RRC Reconfiguration message for UE17 with timeout=5s
    Add to UE17 initial PDU session with ICS
    Verify second RRC Reconfiguration message did not occur for UE17 with timeout=5s
    Verify that only A3, A5, A2 meauserments were configured for UE17 in RRCReconfiguration message

    Attach UE19 without ICS to MN gNB2 NRCELL-1
    Add to UE19 initial PDU session
    Verify that a4 measurement was activated in second RRCReconfiguration message for UE19
    Set expected messages flows for SNodeAddition for MN gNB2
    UE19 sends A4 measurement for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for MN gNB2
    Trigger UE19 to send deregister request
    Trigger UE17 to send deregister request

    # ALT1
    Attach UE17 to sim gNB4 cell1 with PDU session and indexToRFSP equal 1
    Trigger UE17 XN HO to gNB2 NRCELL-1 without A4 installation

    Attach UE19 to sim gNB4 cell1 with PDU session and indexToRFSP equal 1
    Trigger UE19 XN HO to gNB2 NRCELL-1
    Set expected messages flows for SNodeAddition for MN gNB2
    UE19 sends A4 measurement with id=10 for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for MN gNB2
    Trigger UE19 to send deregister request
    Trigger UE17 to send deregister request

    # ALT3
    Attach UE17 without ICS to MN gNB2 NRCELL-1
    Add to UE17 initial PDU session with ICS
    Verify that only A3, A5, A2 meauserments were configured for UE17 in RRCReconfiguration message
    Expect second RRC Reconfiguration message for UE17 with timeout=12s
    Trigger reestablishment for UE17 to gNB2 NRCELL-2
    Verify second RRC Reconfiguration message did not occur for UE17 with timeout=12s
    Verify no measurements reconfiguration for UE17

    Attach UE19 to gNB2 cell1 with ICS and PDU session setup after ICS
    Trigger reestablishment for UE19 to gNB2 NRCELL-2
    Verify A4 meauserment activation for UE19 with timeout=12s
    Set expected messages flows for SNodeAddition for MN gNB2
    UE19 sends A4 measurement for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for MN gNB2
    Trigger UE19 to send deregister request
    Trigger UE17 to send deregister request

    # ALT4
    Attach UE17 without ICS to MN gNB2 NRCELL-1
    Add to UE17 initial PDU session with ICS
    Trigger UE17 to send UAI with RRC preferred state of inactive
    Expect second RRC Reconfiguration message for UE17 with timeout=12s
    Trigger UE17 to enter ACTIVE state without A4 configuration
    Verify second RRC Reconfiguration message did not occur for UE17 with timeout=12s
    Verify that only A3, A5, A2 meauserments were configured for UE17 in RRCReconfiguration message

    Attach UE19 without ICS to MN gNB2 NRCELL-1
    Add to UE19 initial PDU session
    Trigger UE19 to send UAI with RRC preferred state of inactive
    Trigger UE19 to enter ACTIVE state with A4 configuration
    Set expected messages flows for SNodeAddition for MN gNB2
    UE19 sends A4 measurement for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for MN gNB2
    Trigger UE19 to send deregister request
    Trigger UE17 to send deregister request

    # ALT9
    Reconfigure NRDC_UEPROFILE to not contain UE chipsetID

    Attach UE17 without ICS to MN gNB2 NRCELL-1
    Add to UE17 initial PDU session
    Trigger UE17 to send UAI with RRC preferred state of inactive
    Trigger UE17 to enter ACTIVE state with A4 configuration
    Set expected messages flows for SNodeAddition for MN gNB2
    UE17 sends A4 measurement for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for MN gNB2

    Attach UE19 without ICS to MN gNB2 NRCELL-1
    Add to UE19 initial PDU session
    Trigger UE19 to send UAI with RRC preferred state of inactive
    Trigger UE19 to enter ACTIVE state with A4 configuration
    Set expected messages flows for SNodeAddition for MN gNB2
    UE19 sends A4 measurement for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for MN gNB2
    Trigger UE19 to send deregister request
    Trigger UE17 to send deregister request
    Set NRDC_UEPROFILE.nrUeProfileDNList to NRUEPROFILE-1

# CB012328-EA-IWK0102 Selective blocking - ICS for UE#1 and UE#2 does not contain any PDU Session
    Log To Console    Start CB012328-EA-IWK0102

    #ALT5
    Attach UE17 to gNB2 cell1 with ICS without PDU session
    Expect second RRC Reconfiguration message for UE17 with timeout=4s
    Add to UE17 initial PDU session after ICS
    Verify second RRC Reconfiguration message did not occur for UE17 with timeout=4s
    Verify that only A3, A5, A2 meauserments were configured for UE17 in RRCReconfiguration message
    Verify that A4 was NOT configured for UE17 after a4RetryTimer

    Attach UE19 to gNB2 cell1 with ICS without PDU session
    Expect second RRC Reconfiguration message for UE19 with timeout=4s
    Add to UE19 initial PDU session after ICS
    Verify second RRC Reconfiguration message did not occur for UE19 with timeout=4s
    Verify that only A3, A5, A2 meauserments were configured for UE19 in RRCReconfiguration message
    Verify A4 meauserment activation for UE19 with timeout=7s
    Set expected messages flows for SNodeAddition for MN gNB2
    UE19 sends A4 measurement for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for MN gNB2
    Trigger UE19 to send deregister request
    Trigger UE17 to send deregister request

# CB012328-EA-IWK0104 Selective blocking - RRC Reestablishment to the same cell
    Log To Console    Start CB012328-EA-IWK0104

    # ALT2
    Attach UE17 without ICS to MN gNB2 NRCELL-1
    Add to UE17 initial PDU session with ICS
    Verify that only A3, A5, A2 meauserments were configured for UE17 in RRCReconfiguration message
    Expect second RRC Reconfiguration message for UE17 with timeout=12s
    Trigger reestablishment for UE17 to gNB2 NRCELL-1
    Verify second RRC Reconfiguration message did not occur for UE17 with timeout=12s
    Verify no measurements reconfiguration for UE17

    Attach UE19 to gNB2 cell1 with ICS and PDU session setup after ICS
    Trigger reestablishment for UE19 to gNB2 NRCELL-1
    Verify A4 meauserment activation for UE19 with timeout=12s
    Set expected messages flows for SNodeAddition for MN gNB2
    UE19 sends A4 measurement for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for MN gNB2
    Trigger UE19 to send deregister request
    Trigger UE17 to send deregister request

# CB012328-EA-IWK0103 Selective blocking - missing or insufficient NR-DC UE radio capability
    Log To Console    Start CB012328-EA-IWK0103

    #ALT6
    Include UE Capabilities In ICS Request  ue_id=17  ue_capabilities=${ue_17_insufficient}
    Attach UE17 without ICS to MN gNB2 NRCELL-1
    Set expected messages flows for additional UECapabilityEnquiry request for UE17
    Add to UE17 initial PDU session with ICS
    Verify that only A3, A5, A2 meauserments were configured for UE17 in RRCReconfiguration message
    Fail expected messages flows for additional UECapabilityEnquiry request for UE17

    Include UE Capabilities In ICS Request  ue_id=19  ue_capabilities=${ue_19_insufficient}
    Attach UE19 without ICS to MN gNB2 NRCELL-1
    Set expected messages flows for additional UECapabilityEnquiry request for UE19
    Add to UE19 initial PDU session
    Verify expected messages flows for additional UECapabilityEnquiry request for UE19
    Verify that a4 measurement was activated in second RRCReconfiguration message for UE19
    Set expected messages flows for SNodeAddition for MN gNB2
    UE19 sends A4 measurement for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for MN gNB2
    Trigger UE19 to send deregister request
    Trigger UE17 to send deregister request

    #ALT7
    Include UE Capabilities In ICS Request  ue_id=17  ue_capabilities=${ue_17_wo_chipset_id}
    Attach UE17 without ICS to MN gNB2 NRCELL-1
    Set expected messages flows for additional UECapabilityEnquiry request for UE17
    Expect second RRC Reconfiguration message for UE17 with timeout=3s
    Add to UE17 initial PDU session with ICS
    Verify that only A3, A5, A2 meauserments were configured for UE17 in RRCReconfiguration message
    Verify expected messages flows for additional UECapabilityEnquiry request for UE17
    Verify second RRC Reconfiguration message did not occur for UE17 with timeout=3s

    Include UE Capabilities In ICS Request  ue_id=19  ue_capabilities=${ue_19_insufficient}
    Attach UE19 without ICS to MN gNB2 NRCELL-1
    Set expected messages flows for additional UECapabilityEnquiry request for UE19
    Add to UE19 initial PDU session
    Verify expected messages flows for additional UECapabilityEnquiry request for UE19
    Verify that a4 measurement was activated in second RRCReconfiguration message for UE19
    Set expected messages flows for SNodeAddition for MN gNB2
    UE19 sends A4 measurement for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for MN gNB2
    Trigger UE19 to send deregister request
    Trigger UE17 to send deregister request

    #ALT8
    Configure    ${default_profile}

    Attach UE18 without ICS to MN gNB2 NRCELL-1
    Set expected messages flows for additional UECapabilityEnquiry request for UE18
    Expect second RRC Reconfiguration message for UE18 with timeout=3s
    Add to UE18 initial PDU session with ICS
    Verify that only A3, A5, A2 meauserments were configured for UE18 in RRCReconfiguration message
    Verify expected messages flows for additional UECapabilityEnquiry request for UE18
    Verify second RRC Reconfiguration message did not occur for UE18 with timeout=3s

    Include UE Capabilities In ICS Request  ue_id=19  ue_capabilities=${ue_19_insufficient}
    Attach UE19 without ICS to MN gNB2 NRCELL-1
    Set expected messages flows for additional UECapabilityEnquiry request for UE19
    Add to UE19 initial PDU session
    Verify expected messages flows for additional UECapabilityEnquiry request for UE19
    Verify that a4 measurement was activated in second RRCReconfiguration message for UE19
    Set expected messages flows for SNodeAddition for MN gNB2
    UE19 sends A4 measurement for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for MN gNB2
    Trigger UE19 to send deregister request
    Trigger UE18 to send deregister request

    [Teardown]  CB012328-SR-EA-IWK0103 cleanup

CB012328-EA-IWK0101 Selective blocking of possibility of NR-DC setup for some UE types (interaction with CB014533 and CB010938)
    [Tags]    EA1
    [Documentation]
    ...  == DESCRIPTION ==
    ...  Scenario covers interaction with CB014553 ('User Equipment Profile selection') and CB010938 ('Chipset and
    ...  RAN Identification exchange') in version with selective blocking of the NR-DC, i.e. by default NR-DC is
    ...  allowed for the UE, unless it matches NRDC_UEPROFILE (NRDC_UEPROFILE.nrDcAllowed is set to false).
    ...  Scenario covers UEs entry to cell by Handover, reestablishment, resume from Inactive and not blocking NRDC when
    ...  chipsetID is missing in NRDC_UEPROFILE.nrUeProfileDN list
    ...
    ...  == PRECONDITION ==
    ...  - 12750563: CB012328 Common preconditions
    ...  UE supports bandFR1#1 and bandFR2#1, as well as NR-DC band combination (bandFR1#1-bandFR2#1,
    ...  e.g. DC_n77A-n257M), that can accommodate saCell#1 and nrDcCell#1.
    ...  NRBTS-1.actChipsetAndRanInfoExchange = true
    ...  NRBTS-1.actNrUEProfile = true
    ...  NRBTS-1.NRUEPROFILE-1.chipsetIdList is configured
    ...  NRBTS-1.NRUEPROFILE-1.imeisvList is configured
    ...  NRBTS-1.actFunNrUeBased = 'NR-DC activation
    ...  NRDC_UEPROFILE-1.nrDcAllowed = false
    ...  UE1 is matching with configured NRUEPROFILE
    ...  UE1 is NOT matching with configured NRUEPROFILE
    ...
    ...  == TEST STEPS ==
    ...  UE1 performs ICS with pdu session setup
    ...  UE2 performs ICS with pdu session setup
    ...  UE2 sends A4 measurement and NRDC is established for this UE
    ...
    ...  == POSTCONDITION ==
    ...  UE1 is matching configured NRUEPROFILE and NRDC is not allowed for this UE
    ...  UE2 is configured with NRDC
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
    ...  REQUIREMENTS IN SCOPE: 13254864, 13254869, 13254863, 13254874, 13254866
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP,XNAP
    ...
    ...  == CONTACTS ==
    ...     - Maciej Madej          <maciej.madej@nokia.com>
    ...
    ...  == MAINTAINER ==
    ...     - Maciej Madej          <maciej.madej@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  13254863: USCB012328-EA#IWK01: Selective blocking of possibility of NR-DC setup for some UE types
    ...  (interaction with CB014553 and CB010938)
    ...
    ...  == HISTORY ==
    ...  [28.11.2024] - Create Test Suite
    ...  [27.11.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=922710)

    [Setup]  Prepare test environment CB012328-EA

    Attach UE17 without ICS to MN gNB2 NRCELL-1
    Expect second RRC Reconfiguration message for UE17 with timeout=5s
    Add to UE17 initial PDU session with ICS
    Verify second RRC Reconfiguration message did not occur for UE17 with timeout=5s
    Verify that only A3, A5, A2 meauserments were configured for UE17 in RRCReconfiguration message

    Attach UE19 without ICS to MN gNB2 NRCELL-1
    Add to UE19 initial PDU session
    Verify that a4 measurement was activated in second RRCReconfiguration message for UE19
    Set expected messages flows for SNodeAddition for MN gNB2
    UE19 sends A4 measurement with id=4 for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for MN gNB2
    Trigger UE19 to send deregister request
    Trigger UE17 to send deregister request

    # ALT1
    Attach UE17 to sim gNB4 cell1 with PDU session and indexToRFSP equal 1
    Trigger UE17 XN HO to gNB2 NRCELL-1 without A4 installation

    Attach UE19 to sim gNB4 cell1 with PDU session and indexToRFSP equal 1
    Trigger UE19 XN HO to gNB2 NRCELL-1
    Set expected messages flows for SNodeAddition for MN gNB2
    UE19 sends A4 measurement with id=10 for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for MN gNB2
    Trigger UE19 to send deregister request
    Trigger UE17 to send deregister request

    # ALT3
    Attach UE17 without ICS to MN gNB2 NRCELL-1
    Add to UE17 initial PDU session with ICS
    Verify that only A3, A5, A2 meauserments were configured for UE17 in RRCReconfiguration message
    Expect second RRC Reconfiguration message for UE17 with timeout=12s
    Trigger reestablishment for UE17 to gNB2 NRCELL-2
    Verify second RRC Reconfiguration message did not occur for UE17 with timeout=12s
    Verify no measurements reconfiguration for UE17

    Attach UE19 to gNB2 cell1 with ICS and PDU session setup after ICS
    Trigger reestablishment for UE19 to gNB2 NRCELL-2
    Verify A4 meauserment activation for UE19 with timeout=12s
    Set expected messages flows for SNodeAddition for MN gNB2
    UE19 sends A4 measurement with id=5 for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for MN gNB2
    Trigger UE19 to send deregister request
    Trigger UE17 to send deregister request

    # ALT4
    Attach UE17 without ICS to MN gNB2 NRCELL-1
    Add to UE17 initial PDU session with ICS
    Trigger UE17 to send UAI with RRC preferred state of inactive
    Expect second RRC Reconfiguration message for UE17 with timeout=12s
    Trigger UE17 to enter ACTIVE state without A4 configuration
    Verify second RRC Reconfiguration message did not occur for UE17 with timeout=12s
    Verify that only A3, A5, A2 meauserments were configured for UE17 in RRCReconfiguration message

    Attach UE19 without ICS to MN gNB2 NRCELL-1
    Add to UE19 initial PDU session
    Trigger UE19 to send UAI with RRC preferred state of inactive
    Trigger UE19 to enter ACTIVE state with A4 configuration
    Set expected messages flows for SNodeAddition for MN gNB2
    UE19 sends A4 measurement with id=4 for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for MN gNB2
    Trigger UE19 to send deregister request
    Trigger UE17 to send deregister request

    # ALT9
    Reconfigure NRDC_UEPROFILE to not contain UE chipsetID

    Attach UE17 without ICS to MN gNB2 NRCELL-1
    Add to UE17 initial PDU session
    Trigger UE17 to send UAI with RRC preferred state of inactive
    Trigger UE17 to enter ACTIVE state with A4 configuration
    Set expected messages flows for SNodeAddition for MN gNB2
    UE17 sends A4 measurement with id=4 for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for MN gNB2

    Attach UE19 without ICS to MN gNB2 NRCELL-1
    Add to UE19 initial PDU session
    Trigger UE19 to send UAI with RRC preferred state of inactive
    Trigger UE19 to enter ACTIVE state with A4 configuration
    Set expected messages flows for SNodeAddition for MN gNB2
    UE19 sends A4 measurement with id=4 for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for MN gNB2
    Trigger UE19 to send deregister request
    Trigger UE17 to send deregister request

    [Teardown]  CB012328-SR-A cleanup

CB012328-EA-IWK0102 Selective blocking - ICS for UE#1 and UE#2 does not contain any PDU Session
#(which is setup as part of the following PDU Session Setup procedure)
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  Scenario covers interaction with CB014553 ('User Equipment Profile selection') and CB010938 ('Chipset and
    ...  RAN Identification exchange') in version with selective blocking of the NR-DC, i.e. by default NR-DC is
    ...  allowed for the UE, unless it matches NRDC_UEPROFILE (NRDC_UEPROFILE.nrDcAllowed is set to false).
    ...  Scenario covers ALT5. PDU session is setup after ICS.
    ...
    ...  == PRECONDITION ==
    ...  - 12750563: CB012328 Common preconditions
    ...  UE supports bandFR1#1 and bandFR2#1, as well as NR-DC band combination (bandFR1#1-bandFR2#1,
    ...  e.g. DC_n77A-n257M), that can accommodate saCell#1 and nrDcCell#1.
    ...  NRBTS-1.actChipsetAndRanInfoExchange = true
    ...  NRBTS-1.actNrUEProfile = true
    ...  NRBTS-1.NRUEPROFILE-1.chipsetIdList is configured
    ...  NRBTS-1.NRUEPROFILE-1.imeisvList is configured
    ...  NRBTS-1.actFunNrUeBased = 'NR-DC activation
    ...  NRDC_UEPROFILE-1.nrDcAllowed = false
    ...  UE1 is matching with configured NRUEPROFILE
    ...  UE1 is NOT matching with configured NRUEPROFILE
    ...
    ...  == TEST STEPS ==
    ...  UE1 performs ICS without pdu session setup
    ...  UE2 performs ICS without pdu session setup
    ...  PDU session is added to both UEs after ICS complete
    ...  UE2 sends A4 measurement and NRDC is established for this UE
    ...
    ...  == POSTCONDITION ==
    ...  UE1 is matching configured NRUEPROFILE and NRDC is not allowed for this UE
    ...  UE2 is configured with NRDC
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
    ...  REQUIREMENTS IN SCOPE: 13254870
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP,XNAP
    ...
    ...  == CONTACTS ==
    ...     - Maciej Madej          <maciej.madej@nokia.com>
    ...
    ...  == MAINTAINER ==
    ...     - Maciej Madej          <maciej.madej@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  13254863: USCB012328-EA#IWK01: Selective blocking of possibility of NR-DC setup for some UE types
    ...  (interaction with CB014553 and CB010938)
    ...
    ...  == HISTORY ==
    ...  [28.11.2024] - Create Test Suite
    ...  [27.11.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=922710)

    [Setup]  Prepare test environment CB012328-EA

    #ALT5
    Attach UE17 to gNB2 cell1 with ICS without PDU session
    Expect second RRC Reconfiguration message for UE17 with timeout=4s
    Add to UE17 initial PDU session after ICS
    Verify second RRC Reconfiguration message did not occur for UE17 with timeout=4s
    Verify that only A3, A5, A2 meauserments were configured for UE17 in RRCReconfiguration message
    Verify that A4 was NOT configured for UE17 after a4RetryTimer

    Attach UE19 to gNB2 cell1 with ICS without PDU session
    Expect second RRC Reconfiguration message for UE19 with timeout=4s
    Add to UE19 initial PDU session after ICS
    Verify second RRC Reconfiguration message did not occur for UE19 with timeout=4s
    Verify that only A3, A5, A2 meauserments were configured for UE19 in RRCReconfiguration message
    Verify A4 meauserment activation for UE19 with timeout=7s
    Set expected messages flows for SNodeAddition for MN gNB2
    UE19 sends A4 measurement with id=5 for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for MN gNB2
    Trigger UE19 to send deregister request
    Trigger UE17 to send deregister request

    [Teardown]  CB012328-SR-A cleanup

CB012328-EA-IWK0103 Selective blocking - missing or insufficient NR-DC UE radio capability
    [Tags]
    [Documentation]
    ...  == DESCRIPTION ==
    ...  Scenario covers interaction with CB014553 ('User Equipment Profile selection') and CB010938 ('Chipset and
    ...  RAN Identification exchange') in version with selective blocking of the NR-DC, i.e. by default NR-DC is
    ...  allowed for the UE, unless it matches NRDC_UEPROFILE (NRDC_UEPROFILE.nrDcAllowed is set to false).
    ...  Scenario covers ALT6-8. Missing / insufficient NR-DC UE radio capability, Missing / insufficient NR-DC UE
    ...  radio capability and missing chipset ID, NR-DC blocking due to default UE profile selection
    ...
    ...  == PRECONDITION ==
    ...  - 12750563: CB012328 Common preconditions
    ...  UE supports bandFR1#1 and bandFR2#1, as well as NR-DC band combination (bandFR1#1-bandFR2#1,
    ...  e.g. DC_n77A-n257M), that can accommodate saCell#1 and nrDcCell#1.
    ...  NRBTS-1.actChipsetAndRanInfoExchange = true
    ...  NRBTS-1.actNrUEProfile = true
    ...  NRBTS-1.NRUEPROFILE-1.chipsetIdList is configured
    ...  NRBTS-1.NRUEPROFILE-1.imeisvList is configured
    ...  NRBTS-1.actFunNrUeBased = 'NR-DC activation
    ...  NRDC_UEPROFILE-1.nrDcAllowed = false
    ...  UE1 is matching with configured NRUEPROFILE
    ...  UE1 is NOT matching with configured NRUEPROFILE
    ...  UE1 and UE2 have insufficient NR-DC UE radio capabilities
    ...
    ...  == TEST STEPS ==
    ...  UE1 performs ICS with pdu session setup
    ...  UE2 performs ICS with pdu session setup
    ...  UE2 sends A4 measurement and NRDC is established for this UE
    ...
    ...  == POSTCONDITION ==
    ...  UE1 is matching configured NRUEPROFILE and NRDC is not allowed for this UE
    ...  UE2 is configured with NRDC
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
    ...  REQUIREMENTS IN SCOPE: 13254871, 13254872, 13254873
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP,XNAP
    ...
    ...  == CONTACTS ==
    ...     - Maciej Madej          <maciej.madej@nokia.com>
    ...
    ...  == MAINTAINER ==
    ...     - Maciej Madej          <maciej.madej@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  13254863: USCB012328-EA#IWK01: Selective blocking of possibility of NR-DC setup for some UE types
    ...  (interaction with CB014553 and CB010938)
    ...
    ...  == HISTORY ==
    ...  [28.11.2024] - Create Test Suite
    ...  [27.11.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=922710)

    [Setup]  Prepare test environment CB012328-EA

    #ALT6
    Include UE Capabilities In ICS Request  ue_id=17  ue_capabilities=${ue_17_insufficient}
    Attach UE17 without ICS to MN gNB2 NRCELL-1
    Set expected messages flows for additional UECapabilityEnquiry request for UE17
    Add to UE17 initial PDU session with ICS
    Verify that only A3, A5, A2 meauserments were configured for UE17 in RRCReconfiguration message
    Fail expected messages flows for additional UECapabilityEnquiry request for UE17

    Include UE Capabilities In ICS Request  ue_id=19  ue_capabilities=${ue_19_insufficient}
    Attach UE19 without ICS to MN gNB2 NRCELL-1
    Set expected messages flows for additional UECapabilityEnquiry request for UE19
    Add to UE19 initial PDU session
    Verify expected messages flows for additional UECapabilityEnquiry request for UE19
    Verify that a4 measurement was activated in second RRCReconfiguration message for UE19
    Set expected messages flows for SNodeAddition for MN gNB2
    UE19 sends A4 measurement with id=4 for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for MN gNB2
    Trigger UE19 to send deregister request
    Trigger UE17 to send deregister request

    #ALT7
    Include UE Capabilities In ICS Request  ue_id=17  ue_capabilities=${ue_17_wo_chipset_id}
    Attach UE17 without ICS to MN gNB2 NRCELL-1
    Set expected messages flows for additional UECapabilityEnquiry request for UE17
    Expect second RRC Reconfiguration message for UE17 with timeout=3s
    Add to UE17 initial PDU session with ICS
    Verify that only A3, A5, A2 meauserments were configured for UE17 in RRCReconfiguration message
    Verify expected messages flows for additional UECapabilityEnquiry request for UE17
    Verify second RRC Reconfiguration message did not occur for UE17 with timeout=3s

    Include UE Capabilities In ICS Request  ue_id=19  ue_capabilities=${ue_19_insufficient}
    Attach UE19 without ICS to MN gNB2 NRCELL-1
    Set expected messages flows for additional UECapabilityEnquiry request for UE19
    Add to UE19 initial PDU session
    Verify expected messages flows for additional UECapabilityEnquiry request for UE19
    Verify that a4 measurement was activated in second RRCReconfiguration message for UE19
    Set expected messages flows for SNodeAddition for MN gNB2
    UE19 sends A4 measurement with id=4 for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for MN gNB2
    Trigger UE19 to send deregister request
    Trigger UE17 to send deregister request

    #ALT8
    Configure    ${default_profile}

    Attach UE18 without ICS to MN gNB2 NRCELL-1
    Set expected messages flows for additional UECapabilityEnquiry request for UE18
    Expect second RRC Reconfiguration message for UE18 with timeout=3s
    Add to UE18 initial PDU session with ICS
    Verify that only A3, A5, A2 meauserments were configured for UE18 in RRCReconfiguration message
    Verify expected messages flows for additional UECapabilityEnquiry request for UE18
    Verify second RRC Reconfiguration message did not occur for UE18 with timeout=3s

    Include UE Capabilities In ICS Request  ue_id=19  ue_capabilities=${ue_19_insufficient}
    Attach UE19 without ICS to MN gNB2 NRCELL-1
    Set expected messages flows for additional UECapabilityEnquiry request for UE19
    Add to UE19 initial PDU session
    Verify expected messages flows for additional UECapabilityEnquiry request for UE19
    Verify that a4 measurement was activated in second RRCReconfiguration message for UE19
    Set expected messages flows for SNodeAddition for MN gNB2
    UE19 sends A4 measurement with id=4 for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for MN gNB2
    Trigger UE19 to send deregister request
    Trigger UE18 to send deregister request

    [Teardown]  CB012328-SR-EA-IWK0103 cleanup

CB012328-EA-IWK0104 Selective blocking - RRC Reestablishment to the same cell
    [Tags]    EA4
    [Documentation]
    ...  == DESCRIPTION ==
    ...  Scenario covers interaction with CB014553 ('User Equipment Profile selection') and CB010938 ('Chipset and
    ...  RAN Identification exchange') in version with selective blocking of the NR-DC, i.e. by default NR-DC is
    ...  allowed for the UE, unless it matches NRDC_UEPROFILE (NRDC_UEPROFILE.nrDcAllowed is set to false).
    ...  Scenario covers ALT2 UE#1 and UE#2 reestablish to the same cell
    ...
    ...  == PRECONDITION ==
    ...  - 12750563: CB012328 Common preconditions
    ...  UE supports bandFR1#1 and bandFR2#1, as well as NR-DC band combination (bandFR1#1-bandFR2#1,
    ...  e.g. DC_n77A-n257M), that can accommodate saCell#1 and nrDcCell#1.
    ...  NRBTS-1.actChipsetAndRanInfoExchange = true
    ...  NRBTS-1.actNrUEProfile = true
    ...  NRBTS-1.NRUEPROFILE-1.chipsetIdList is configured
    ...  NRBTS-1.NRUEPROFILE-1.imeisvList is configured
    ...  NRBTS-1.actFunNrUeBased = 'NR-DC activation
    ...  NRDC_UEPROFILE-1.nrDcAllowed = false
    ...  UE1 is matching with configured NRUEPROFILE
    ...  UE1 is NOT matching with configured NRUEPROFILE
    ...
    ...  == TEST STEPS ==
    ...  UE1 performs ICS without pdu session setup
    ...  UE2 performs ICS without pdu session setup
    ...  PDU session is added to both UEs after ICS complete
    ...  UE2 sends A4 measurement and NRDC is established for this UE
    ...
    ...  == POSTCONDITION ==
    ...  UE1 is matching configured NRUEPROFILE and NRDC is not allowed for this UE
    ...  UE2 is configured with NRDC
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
    ...  REQUIREMENTS IN SCOPE: 13254865
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC,NGAP,F1AP,E1AP,XNAP
    ...
    ...  == CONTACTS ==
    ...     - Maciej Madej          <maciej.madej@nokia.com>
    ...
    ...  == MAINTAINER ==
    ...     - Maciej Madej          <maciej.madej@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  13254863: USCB012328-EA#IWK01: Selective blocking of possibility of NR-DC setup for some UE types
    ...  (interaction with CB014553 and CB010938)
    ...
    ...  == HISTORY ==
    ...  [28.11.2024] - Create Test Suite
    ...  [27.11.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=922710)

    [Setup]  Prepare test environment CB012328-EA

    # ALT2
    Attach UE17 without ICS to MN gNB2 NRCELL-1
    Add to UE17 initial PDU session with ICS
    Verify that only A3, A5, A2 meauserments were configured for UE17 in RRCReconfiguration message
    Expect second RRC Reconfiguration message for UE17 with timeout=12s
    Trigger reestablishment for UE17 to gNB2 NRCELL-1
    Verify second RRC Reconfiguration message did not occur for UE17 with timeout=12s
    Verify no measurements reconfiguration for UE17

    Attach UE19 to gNB2 cell1 with ICS and PDU session setup after ICS
    Trigger reestablishment for UE19 to gNB2 NRCELL-1
    Verify A4 meauserment activation for UE19 with timeout=12s
    Set expected messages flows for SNodeAddition for MN gNB2
    UE19 sends A4 measurement with id=5 for NR-DC PSCell addition
    Verify expected messages flows for SNodeAddition for MN gNB2
    Trigger UE19 to send deregister request
    Trigger UE17 to send deregister request


    [Teardown]  CB012328-SR-A cleanup


*** Keywords ***
Run keywords and expect at least one passed
    [Arguments]    @{keywords}
    ${passed}=    Set Variable    ${False}
    FOR    ${kw}    IN    @{keywords}
        ${status}    ${result}=    Run Keyword And Ignore Error    ${kw}
        IF    '${status}' == 'PASS'
            ${passed}=    Set Variable    ${True}
            BREAK
        END
    END
    Run Keyword If    not ${passed}    Fail    None of the keywords passed

UE${ue_id} sends A4 measurement for NR-DC PSCell addition
    Run keywords and expect at least one passed
    ...    UE${ue_id} sends A4 measurement with id=4 for NR-DC PSCell addition
    ...    UE${ue_id} sends A4 measurement with id=5 for NR-DC PSCell addition
