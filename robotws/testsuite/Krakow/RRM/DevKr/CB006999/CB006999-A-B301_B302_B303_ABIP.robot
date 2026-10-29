*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == INTRODUCTION ==
...      This feature introduces gNB support for planned AMF removal (maintenance, SW upgrades).
...      Upon receipt of the AMF STATUS INDICATION message over NG interface,
...      the gNB considers GUAMI(s), will be unavailable and performs AMF reselection as follows:
...      - gNB marks this source AMF as unavailable and does not consider this AMF for selection for subsequent N2 transactions
...      - if the source AMF included the Timer Approach indicator, the gNB starts a timer to control the release of NGAP UE-TNLA-binding
...      == TEST SET NAME ==
...      CB006999-A AMF STATUS INDICATION Handling
...      == TESTING SPLIT ==
...      CB006999-A AMF STATUS INDICATION Handling
...      CB006999-B	UE TNLA BINDING RELEASE REQUEST handling
...      == AUTHORS ==
...      - Cezary Dudek <cezary.dudek@nokia.com>
...      - Marek Kieltyka <marek.kieltyka@nokia.com>
...      - Konrad Krzyzak <konrad.krzyzak@nokia.com>
...      - Karolina Sroczyk <karolina.sroczyk@nokia.com>
...      - Gabriela Stasiuk <gabriela.stasiuk@nokia.com>
...      - Grzegorz Szymik <grzegorz.szymik@nokia.com>
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
...         [02.09.2021] - Created TC

Resource    ./resources/CB006999.robot
Resource    ./resources/CB006999-A_setups_teardowns.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup  Run Keywords
...  Setup emss    node_id=1
...  AND  Create all devices aliases
...  AND  Configure CB006999 basic params via yaml
#...  AND  Setup egate  egate_port=20000  alias=default
...  AND  ute_admin.Setup admin    bts_host=192.168.255.1    bts_port=443    use_ssl=True
...  AND  Reach OnAir with retries    lua_cfg=${lua_cfg_file}

*** Variables ***
${lua_cfg_file}=   ${CURDIR}/config/egate_SA_2c_3amf_APoABIO.lua

*** Test Cases ***
CB006999-A-B301-1-Reselection_after_ASI_received_with_partial_timer_approach_and_with_changed_backupAMF
    [Tags]    AB301-1
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  This test scenario describes the gNB behavior when AMF reselection is performed after receiving AMF Status
    ...  Indication with partial timerApproachForGUAMIRemoval set and with changed backup AMF.
    ...  Traffic on UE is not impacted during successful AMF reselection. Backup AMF is used after reselection.
    ...  == Precondition ==
    ...  Real gNB up and running
    ...  NRBTS.actNgcFlexSaMode=true (5GC000740)
    ...  NRBTS.actAmfPlannedRemoval=true
    ...  NRBTS.amfPlannedRemovalTimer > 0
    ...  Established NG connections AMF-gNB
    ...  AMF1 is configured with 2 GUAMIs (GUAMI1, GUAMI2)
    ...  AMF2 is configured with GUAMI (GUAMI3)
    ...  AMF3 is configured with GUAMI (GUAMI4)
    ...  3 AMFs up and running
    ...  GUAMIs of AMF-1 have backup AMF set to AMF-2 and AMF-3
    ...  GUAMIs of AMF-2 and AMF-3 have no backup AMF
    ...  == Flow ==
    ...  1.	Attach UE1 to AMF1:GUAMI1.
    ...  2.	Attach UE2 to AMF1:GUAMI2.
    ...  3.	Verify that UE1 is attached to AMF1:GUAMI1.
    ...  4.	Verify that UE2 is attached to AMF1:GUAMI2..
    ...  5.	Connect PDU Session with one QoS Flow (non-GBR) for UE1.
    ...  6.	Connect PDU Session with one QoS Flow (non-GBR) for UE2.
    ...  7.	Run UL and DL traffic on UE1.
    ...  8.	Run UL and DL traffic on UE2.
    ...  9. Send NGAP: AMF STATUS INDICATION from AMF1 with unavailableGuamiList:
    ...  - GUAMI1
    ...   - timerApproachForGUAMIRemoval = apply timer
    ...   - backupAMFName is set to AMF3
    ...  - GUAMI2:
    ...   - timerApproachForGUAMIRemoval is not present
    ...   - backupAMFName is set to AMF2
    ...  10. Verify that after NGAP:ASI reception all relevant AMF-1 objects are correctly updated:
    ...  - SERVEDAMF-1.guAMI[1].guamiStatus is set to UNAVAILABLE
    ...  - SERVEDAMF-1.guAMI[2].guamiStatus is set to UNAVAILABLE
    ...  - SERVEDAMF-1.guAMI[1].backupAMF is set to AMF3
    ...  - SERVEDAMF-1.guAMI[2].backupAMF is set to AMF2
    ...  11. Check if alarm 7115 with faultID=7325 is active.
    ...  12. During timer running, trigger UE1 to send NR-RRC: UL INFORMATION TRANSFER with PDU Session Modification Request.
    ...  13. Verify that for the duration of amfPlannedRemovalTimer UE1 sends messages to AMF1.
    ...  14. During timer running, trigger UE2 to send NR-RRC: UL INFORMATION TRANSFER with PDU Session Modification Request.
    ...  15. Verify that while amfPlannedRemovalTimer is running gNB performs successful AMF reselection for UE2 and backup AMF2 is selected.
    ...  16. Verify that gNB stops sending NGAP messages to AMF-1 related with UE2.
    ...  17. Wait until amfPlannedRemovalTimer expiration.
    ...  18. Trigger UE1 to send NR-RRC: UL INFORMATION TRANSFER with PDU Session Modification Request.
    ...  19. Verify that gNB performs successful AMF reselection for UE1 after second NGAP UL message and backup AMF3 is selected.
    ...  20. Verify that gNB stops sending NGAP messages to AMF-1 related with UE1.
    ...  21. Verify that UE1 traffic is not impacted during the whole procedure.
    ...  22. Verify that UE2 traffic is not impacted during the whole procedure.
    ...  23. Verify that PM counters are incremented:
    ...  - M55155C00004 - AMF_RESELECTION_GNB_ATT = 2
    ...  - M55155C00005 - AMF_RESELECTION_GNB_FAIL = 0
    ...  - M55155C00006 - AMF_RESELECTION_GNB_SUCC = 2
    ...  24. Teardown:
    ...  - Detach UE1
    ...  - Detach UE2
    ...  - SERVEDAMF-1.guAMI[1].guamiStatus = available
    ...  - SERVEDAMF-1.guAMI[2].guamiStatus = available
    ...  == Postcondition ==
    ...  - Alarm with faultID=7325 is cleared
    ...  - NGAP link gNB-AMF1 active
    ...  - NGAP link gNB-AMF2 active
    ...  - NGAP link gNB-AMF3 active
    ...  - UE1 is detached
    ...  - UE2 is detached
    ...  == TESTING TOOLS ==
    ...  AirPhone, EPCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ABIO + ASIL) with 2 simulated AEQE radio modules - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  CB006999-A#US10
    ...  == REQUIRED LOGS ==
    ...  NGAP
    ...  == AUTHOR ==
    ...  - Grzegorz Szymik <grzegorz.szymik@nokia.com>
    ...  == REFERENCES ==
    ...  CB006999-2757

    [Setup]  Prepare test environment AB301-1

    Attach UE1 to AMF1:GUAMI:1 and run traffic on PDU 1
    Attach UE2 to AMF1:GUAMI:2 and run traffic on PDU 2

    Send ASI from AMF1 with two GUAMI:1 backupAMF:3 timerApproach:on GUAMI:2 backupAMF:2 timerApproach:off

    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF1
    Verify SERVEDAMF-1:GUAMI_index-1 is correctly updated: backupAmfName=AMF3, guamiStatus=unavailable
    Verify SERVEDAMF-1:GUAMI_index-2 is correctly updated: backupAmfName=AMF2, guamiStatus=unavailable

    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-3
    Expect that after PDU Session Modification Request from UE1 gNB does not perform AMF reselection and AMF1 is selected
    Trigger UE1 to send PDU Session Modification for PDU1
    Verify that after PDU Session Modification Request from UE1 gNB does not perform AMF reselection and AMF1 is selected
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-3

    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1
    Expect that after PDU Session Modification Request from UE2 gNB performs AMF reselection and AMF2 is selected
    Trigger UE2 to send PDU Session Modification for PDU2
    Verify that after PDU Session Modification Request from UE2 gNB performs AMF reselection and AMF2 is selected
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1

    Wait until amfPlannedRemovalTimer expiration

    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1
    Expect that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF3 is selected
    Trigger UE1 to send PDU Session Modification for PDU1
    Verify that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF3 is selected
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1

    Verify that NG link to AMF-1 is established
    Verify that NG link to AMF-2 is established
    Verify that NG link to AMF-3 is established

    Stop and verify 20MBps UL and DL traffic on UE1 PDU1 QFI1
    Stop and verify 20MBps UL and DL traffic on UE2 PDU2 QFI1

    Wait until PM counters file is ready and saved
    Verify PM counters for gNB initiated AMF reselection are incremented successfully: attempts:2, fails:0, successes:2

    [Teardown]  Teardown test environment AB301-1
