*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == INTRODUCTION ==
...      This feature introduces gNB support for planned AMF removal (maintenance, SW upgrades).
...      AMF may release (using NGAP UE TNLA BINDING RELEASE REQUEST) or rebind the NGAP UE-TNLA binding on per UE basis.
...
...      == TEST SET NAME ==
...      CB006999-B	UE TNLA BINDING RELEASE REQUEST handling
...      == TESTING SPLIT ==
...      CB006999-A AMF STATUS INDICATION Handling
...      CB006999-B	UE TNLA BINDING RELEASE REQUEST handling
...      == AUTHORS ==
...      - Cezary Dudek <cezary.dudek@nokia.com>
...      - Marek Kieltyka <marek.kieltyka@nokia.com>
...      - Konrad Krzyzak <konrad.krzyzak@nokia.com>
...      - Karolina Sroczyk <karolina.sroczyk@nokia.com>
...      - Agnieszka Wlodarczyk <agnieszka.wlodarczyk@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...      == REFERENCES ==
...      - CB006999 CFAM
...      https://nokia.sharepoint.com/:f:/r/sites/ASCOP/AS%20Documents/FS1TAs-CFAMs/CB/CB006800%20-%20CB006999/CFAM/
...      CB006999%20gNB%20support%20for%20AMF%20Status%20Indication/CP2/CP2_Approved?csf=1&web=1
...      - L3 Testplan
...      https://nokia-my.sharepoint.com/:x:/r/personal/agnieszka_wlodarczyk_nokia_com/_layouts/15/
...      guestaccess.aspx?e=GxcEku&share=ESPUb8cGM2dMsgKohhtKI5gBg7y0YwPVpncWZIE9fxBKmg
...      == HISTORY ==
...         [15.12.2021] - Created TC
...         [22.04.2022] - Migrate to APoABIO

Resource    ./resources/CB006999.robot
Resource    ./resources/CB006999-B_setups_teardowns.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup  Run Keywords
...  Setup emss    node_id=1
...  AND  Create all devices aliases
...  AND  Configure CB006999 basic params via yaml
...  AND  Configure    ${inter_gNB_handover}
#...  AND  Setup egate  egate_port=20000  alias=default
...  AND  ute_admin.Setup admin    bts_host=192.168.255.1    bts_port=443    use_ssl=True
...  AND  Setup NG HO on gNB
...  AND  Reach OnAir with retries    lua_cfg=${lua_cfg_file}

*** Variables ***
${lua_cfg_file}=   ${CURDIR}/config/egate_SA_2c_1gNBSim_2amf_APoABIO.lua

*** Test Cases ***

CB006999-B-I003-2-TBR_interact_with_NGHO_and_is_send_during_NGHO_SRC
    [Tags]    BI003-2
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  This test scenario shows that NG-based HO procedure is aborted due to TNGRELOCprep expiry, regardless of AMF
    ...  sending NGAP: TNLA BINDING RELEASE REQUEST during HO procedure. UE stays at source gNB in case of
    ...  NGAP: HANDOVER CANCEL, gNB performs AMF reselection for this UE and backup AMF is selected.
    ...  == Precondition ==
    ...  Both real gNB - gNB2 and simulated gNB - gNB3 are up and running
    ...  NRBTS.actNgcFlexSaMode=true (5GC000740)
    ...  NRBTS.actAmfPlannedRemoval=true
    ...  NRBTS.tNgRelocPrep = 2 [s] default value
    ...  NG HO is supported between real and simulated gNB
    ...  - NRBTS.NRCELL.NRREL.handoverAllowedSA=onlyNG
    ...  - NRBTS.actIntraNrNgHo=sourceAndTarget
    ...  Established all NG connections (3 links up for real gNB and 3 links for simulated gNB)
    ...  3 AMFs up and running
    ...  AMF1 is configured with 2 GUAMIs (GUAMI1, GUAMI2)
    ...  AMF2 is configured with 1 GUAMI (GUAMI3)
    ...  AMF-1.GUAMI1 has backup AMF set to AMF2
    ...  AMF-1.GUAMI2 has backup AMF set to AMF2
    ...  GUAMIs of AMF2 have no backup AMF
    ...  GUAMI1, GUAMI2, GUAMI3 have status set to AVAILABLE
    ...  == Flow ==
    ...  1.	Attach UE1 to AMF1:GUAMI1.
    ...  2.	Verify that UE1 is attached to AMF1:GUAMI1.
    ...  3.	Connect PDU Session with one QoS Flow (non-GBR) for UE1.
    ...  4.	Trigger failure NG HO from real gNB to sim gNB for UE1 while AMF1 sends concurrent TBR:
    ...  - Source gNB sends NGAP: HANDOVER REQUIRED to AMF1
    ...  - AMF1 sends NGAP: UE TNLA BINDING RELEASE REQUEST to source gNB for UE1
    ...  - Timer TNGRELOCprep expiry and simulated gNB doesn't send NGAP: HANDOVER REQUEST ACKNOWLEDGE
    ...  5.	Verify that real gNB sends NGAP: HANDOVER CANCEL to AMF1.
    ...  6.	Verify that AMF1 sends NGAP: HANDOVER CANCEL ACKNOWLEDGE.
    ...  7.	Trigger UE1 to send NR-RRC: UL INFORMATION TRANSFER with PDU Session Modification Request.
    ...  8.	Verify that UE1 stays on source gNB, gNB performs successful AMF reselection for UE1 and backup AMF2 is selected.
    ...  9. Verify that PM counters are incremented:
    ...  - M55155C00004 - AMF_RESELECTION_GNB_ATT  = 1
    ...  - M55155C00005 - AMF_RESELECTION_GNB_FAIL = 0
    ...  - M55155C00006 - AMF_RESELECTION_GNB_SUCC = 1
    ...  - M55155C00007 - AMF_RESELECTION_5GC_RCV  = 0
    ...  - M55155C00008 - AMF_RESELECTION_5GC_REF  = 0
    ...  10. Teardown:
    ...  - Detach UE1
    ...  == Postcondition ==
    ...  - All NGAP links real gNB-AMF and simulated gNB-AMF are in active state
    ...  - UE1 is detached
    ...  == TESTING TOOLS ==
    ...  AirPhone, EPCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ASIL + ABIO)
    ...  == REQUIREMENTS COVERAGE ==
    ...  CB006999-B#US29
    ...  == REQUIRED LOGS ==
    ...  NGAP
    ...  NR-RRC
    ...  == AUTHOR ==
    ...  - Grzegorz Szymik <grzegorz.szymik@nokia.com>
    ...  == REFERENCES ==
    ...  CB006999-2781

    [Setup]  Prepare test environment BI003-2

    Attach UE1 to AMF1:GUAMI:1 without starting traffic

    Trigger failure NG HO with no response from real to sim gNB for UE1 while AMF1 sent concurrent UETNLABindingReleaseRequest

    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1
    Expect that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF2 is selected
    Trigger UE1 to send PDU Session Modification for PDU1
    Verify that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF2 is selected
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1

    Wait until PM counters file is ready and saved
    Verify PM counters for gNB initiated AMF reselection are incremented successfully: attempts:1, fails:0, successes:1
    Verify PM counters for 5GC initiated AMF reselection are incremented successfully: received:0, refused:0

    [Teardown]  Teardown test environment BI003-2


CB006999-B-I003-1-TBR_interacting_with_NGHO_SRC_NGHO_continue_with_old_AMF
    [Tags]    BI003-1
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  This test scenario shows that sending NGAP: UE TNLA BINDING RELEASE REQUEST during ongoing NG-based HO
    ...  results in HO continuation with old AMF - NGAP: UE TNLA BINDING RELEASE REQUEST is processed after HO services
    ...  == Precondition ==
    ...  - Both real gNB2 and simulated NB3 are up and running
    ...  - NRBTS.actNgcFlexSaMode=true (5GC000740)
    ...  - NRBTS.amfPlannedRemovalTimer = 0
    ...  - NRBTS.actAmfPlannedRemoval=true
    ...  - NG HO is supported between real and simulated gNB
    ...  -- NRBTS.NRCELL.NRREL.handoverAllowedSA=onlyNG
    ...  -- NRBTS.actIntraNrNgHo=sourceAndTarget
    ...  - Established all NG connections (3 links up for real gNB and 3 links for simulated gNB)
    ...  - AMF-1 is configured with 2 GUAMIs (GUAMI1, GUAMI2)
    ...  - AMF-2 is configured with 1 GUAMI (GUAMI3)
    ...  - AMF-1 have backup AMF set to AMF-2 and AMF-2
    ...  - AMF-2 have no backup AMFs
    ...  == Flow ==
    ...  1.	Attach UE1 to AMF-1 (GUAMI1) to real gNB2
    ...  2.	Connect PDU Session with one QoS Flow (non-GBR)
    ...  3.	Trigger failure NG HO from real gNB to sim gNB for UE1 while AMF1 sent concurrent UETNLABindingReleaseRequest
    ...  4.	Run DL and UL 20MBps traffic on PDU 1
    ...  5.	Expect that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF2 is selected
    ...  6.	Trigger UE1 to send PDU Session Modification for PDU1
    ...  7.	Verify that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF2 is selected
    ...  8.	Trigger successful NG HO from real_gNB to simulated_gNB for UE1 with backup AMF2
    ...  9.	Verify that UE1 completed NG HO successfully with backup AMF2
    ...  == Postcondition ==
    ...  - Traffic on UE1 is not impacted during AMFs reselection
    ...  - All NGAP links gNB-AMF are in active state
    ...  == TESTING TOOLS ==
    ...  AirPhone, EPCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ASIL + ABIO)
    ...  == REQUIREMENTS COVERAGE ==
    ...  5G_RAN_USR_RRM_6838
    ...  == REQUIRED LOGS ==
    ...  NGAP
    ...  == AUTHOR ==
    ...  Marek Kieltyka <marek.kieltyka@nokia.com>
    ...  == REFERENCES ==
    ...  CB006999-2781

    [Setup]  Prepare test environment BI003-1
    Attach UE1 to AMF1:GUAMI:1 without starting traffic
    Trigger failure NG HO from real to sim gNB for UE1 while AMF1 sent concurrent UETNLABindingReleaseRequest
    Run 20MBps UL and DL traffic on UE1 PDU1 QFI1 and wait 5 seconds

    Expect that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF2 is selected
    Trigger UE1 to send PDU Session Modification for PDU1
    Verify that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF2 is selected

    Trigger successful NG HO from real_gNB to simulated_gNB for UE1 with backup AMF2
#    TODO: Flooding logs after HO:  ERR: GNB-3: UE1: Failed to send UL data for EBI-5.

    Stop and verify 20MBps UL and DL traffic on UE1 PDU1 QFI1
    Wait until PM counters file is ready and saved
    Verify PM counters for gNB initiated AMF reselection are incremented successfully: attempts:1, fails:0, successes:1
    [Teardown]  Teardown test environment BI003-1
