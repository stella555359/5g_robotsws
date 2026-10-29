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

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    SBTS00    SBTS22R3    SBTS22R4    SBTS23R1
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
    ...    PY36
    ...    DISABLE_GENERATION

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
CB006999-A-B203-1-Successful_AMF_reselection_after_ASI_received_without_timer_and_without_backup_AMF
    [Tags]    AB203-1    SKIPRUN
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  This test scenario describes the gNB behavior when AMF reselection is performed after receiving
    ...  AMF Status Indication without timerApproachForGUAMIRemoval set and without backup AMF set.
    ...  Reselection is performed to initial backup AMF on first NGAP uplink message from UE after
    ...  NGAP:ASI without timer approach and without backup AMF and GUAMIs.
    ...  == Precondition ==
    ...  - Real gNB up and running
    ...  - NRBTS.actNgcFlexSaMode=true (5GC000740)
    ...  - NRBTS.amfPlannedRemovalTimer = 0
    ...  - NRBTS.actAmfPlannedRemoval=true
    ...  - Established NG connections AMF-gNB
    ...  - AMF-1 is configured with 2 GUAMIs (GUAMI1, GUAMI2)
    ...  - AMF-2 is configured with 1 GUAMIs (GUAMI3)
    ...  - AMF-3 is configured with 1 GUAMIs (GUAMI4)
    ...  - 3 AMFs up and running
    ...  - GUAMIs of AMF-1, AMF-2 and AMF-3 have no backup AMF
    ...  - SERVEDAMF-2.relativeAMFCapacity = 100
    ...  == Flow ==
    ...  1.	Attach UE1 to gNB using AMF1 and GUAMI1.
    ...  2.	Connect PDU Session with one QoS Flow (non-GBR).
    ...  3.	Run UL and DL traffic on UE1.
    ...  4.	Send ASI from AMF-1:[(GUAMI[1, 2]: without TA, backup AMF set to None)]
    ...  5.	Trigger UE1 to send NR-RRC: UL INFORMATION TRANSFER with PDU Session Modification Request.
    ...  6.	Verify that gNB performs reselection and sends NGAP: UPLINK NAS TRANSPORT to backup AMF-2.
    ...  == Postcondition ==
    ...  - Alarm 7115 is raised
    ...  - UE1 is sending messages to AMF-2
    ...  == TESTING TOOLS ==
    ...  AirPhone, 5GCSim, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ASIL + ABIO)
    ...  == REQUIREMENTS COVERAGE ==
    ...  CB006999-A-B203
    ...  == REQUIRED LOGS ==
    ...  NGAP
    ...  == AUTHOR ==
    ...  - Karolina Sroczyk <karolina.sroczyk@nokia.com>
    ...  == REFERENCES ==
    ...  CB006999-2756

    [Setup]  Prepare test environment AB203-1
    Attach UE1 to AMF1:GUAMI:1 and run traffic on PDU 1

    Send ASI from AMF1 with two GUAMI:1 backupAMF:None timerApproach:off GUAMI:2 backupAMF:None timerApproach:off

    Verify SERVEDAMF-1:GUAMI_index-1 is correctly updated: backupAmfName=None, guamiStatus=unavailable
    Verify SERVEDAMF-1:GUAMI_index-2 is correctly updated: backupAmfName=None, guamiStatus=unavailable
    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF1

    Expect that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1
    Expect that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF2 is selected
    Trigger UE1 to send PDU Session Modification for PDU1
    Verify that gNB does not send NGAP: UPLINK NAS TRANSPORT to AMF-1
    Verify that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF2 is selected

    Verify that NG link to AMF-1 is established

    Wait until PM counters file is ready and saved
    Verify PM counters for gNB initiated AMF reselection are incremented successfully: attempts:1, fails:0, successes:1

    Stop and verify 20MBps UL and DL traffic on UE1 PDU1 QFI1

    [Teardown]  Teardown test environment AB203-1

CB006999-A-B203-2-Successful_AMF_selection_after_ASI_received_without_timer_and_without_backup_AMF
    [Tags]    AB203-2    GQC_PLAN:FEATURE:CB006999
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  == Precondition ==
    ...  NRBTS.actNgcFlexSaMode=true (5GC000740)
    ...  NRBTS.actAmfPlannedRemoval=true
    ...  NRBTS.amfPlannedRemovalTimer=0
    ...  Established NG connections AMF-gNB
    ...  AMF-1 has 2 GUAMIs (GUAMI1, GUAMI2)
    ...  AMF-2 has 1 GUAMI (GUAMI3)
    ...  AMF-3 has 1 GUAMI (GUAMI4)
    ...  3 AMFs up and running
    ...  GUAMI1 backup is AMF-2, GUAMI2 backup is AMF-3, GUAMI3, GUAMI4 have no backup AMF
    ...  NRBTS.drbInactivityTimerSA=10
    ...  NRBTS.srbInactivityTimerSA=10
    ...  == Flow ==
    ...  1. Attach UE10 to AMF1:GUAMI:1 without starting traffic
    ...  2. Connect UE-10 PDU session 1 with QoS flow
    ...  3. Wait until UE10 is going IDLE (UE got NR-RRC: RRCRelease from gNB)
    ...  4. Send NGAP: AMF STATUS INDICATION from AMF1 with GUAMI1 and GUAMI2
    ...  5. Send NGAP: AMF STATUS INDICATION from AMF2 with GUAMI3
    ...  6. Verify alarm 7115 (fault ID 7325) is raised for SERVEDAMF-1
    ...  7. Verify alarm 7115 (fault ID 7325) is raised for SERVEDAMF-2
    ...  8. Restore default gNB radio bearer inactivity timers (NRBTS.drbInactivityTimerSA=600, NRBTS.srbInactivityTimerSA=600)
    ...  9. Trigger UE10 IDLE mode exit
    ...  10. Verify that gNB performed selection to AMF3 for UE-10
    ...  == Postcondition ==
    ...  - UE-10 attached to AMF-1 and then attached to AMF-3 as it's last available AMF
    ...  - PM counters are incremented correctly:
    ...  - M55155C00001 (AMF_SELECTION_ATT) = 2
    ...  - M55155C00002 (AMF_SELECTION_FAIL) = 0
    ...  - M55155C00003 (AMF_SELECTION_SUCC) = 2
    ...  == TESTING TOOLS ==
    ...  AirPhone, EPCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ASIL + ABIO)
    ...  == REQUIREMENTS COVERAGE ==
    ...  5G_RAN_USR_RRM_6826
    ...  == REQUIRED LOGS ==
    ...  NGAP, NR-RRC
    ...  == AUTHOR ==
    ...  Marek Kieltyka <marek.kieltyka@nokia.com>
    ...  == REFERENCES ==
    ...  CFAM_CB006999

    [Setup]  Prepare test environment AB203-2
    Attach UE10 to AMF1:GUAMI:1 without starting traffic
    Wait until UE10 is going IDLE

    Send ASI from AMF1 with two GUAMI:1 backupAMF:None timerApproach:off GUAMI:2 backupAMF:None timerApproach:off
    Send ASI from AMF2 with one GUAMI:1 backupAMF:None timerApproach:off
    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF1
    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF2

    Verify SERVEDAMF-1:GUAMI_index-1 is correctly updated: backupAmfName=None, guamiStatus=unavailable
    Verify SERVEDAMF-1:GUAMI_index-2 is correctly updated: backupAmfName=None, guamiStatus=unavailable
    Verify SERVEDAMF-2:GUAMI_index-1 is correctly updated: backupAmfName=None, guamiStatus=unavailable

    Restore default gNB radio bearer inactivity timers
    Expect that gNB performs selection to AMF3 for UE-10
    Trigger UE10 IDLE mode exit
    Verify that gNB performed selection to AMF3 for UE-10

    Wait until PM counters file is ready and saved
    Verify PM counters for AMF selection are incremented successfully: attempts:2, fails:0, successes:2
    [Teardown]  Teardown test environment AB203-2
