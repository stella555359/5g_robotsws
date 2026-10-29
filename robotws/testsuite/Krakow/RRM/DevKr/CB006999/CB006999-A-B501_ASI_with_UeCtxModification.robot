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
...      - Konrad Krzyzak <konrad.krzyzak@nokia.com>
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
...         [09.11.2021] - Created TC
...         [03.12.2021] - Review and KW implementation

Resource    ./resources/CB006999.robot
Resource    ./resources/CB006999-A_setups_teardowns.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup  Run Keywords
...  Setup emss    node_id=1
...  AND  Create all devices aliases
...  AND  Configure CB006999 basic params via yaml
#...  AND  Setup egate  egate_port=20000  alias=default
...  AND  ute_admin.Setup admin    bts_host=192.168.255.1    bts_port=443    use_ssl=True
...  AND  Reach OnAir with retries    lua_cfg=${lua_cfg_file}

*** Variables ***
${lua_cfg_file}=   ${CURDIR}/config/egate_SA_2c_1gNBSim_2amf_APoABIO.lua

*** Test Cases ***
CB006999-A-B501-1-ASI_with_reselection_to_newAMF_different_GUAMI_UeCtxModification_with_NewGUAMI_check
    [Tags]    AB501-1
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  This testcase shows the behavior of UEs when partial NGAP: AMF Status Indication (ASI)
    ...  with timer approach and with backup AMF is sent by AMF. gNB performs AMF reselection
    ...  for UE that used GUAMI for which NGAP:ASI was sent. UE that used GUAMI which wasn't modified
    ...  by NGAP:ASI - is not impacted, and its' traffic continues without issues.
    ...  == Precondition ==
	...  - gNB up and running
	...  - NRBTS.actNgcFlexSaMode=true (5GC000740)
	...  - NRBTS.actAmfPlannedRemoval=true
	...  - NRBTS.amfPlannedRemovalTimer=30
	...  - Established NG connections AMF-gNB
	...  - AMF-1 is configured with 2 GUAMIs (GUAMI1, GUAMI2) - SERVEDAMF-1
	...  - AMF-2 is configured with 2 GUAMIs (GUAMI3, GUAMI4) - SERVEDAMF-2
	...  - GUAMI1, GUAMI2, GUAMI3, GUAMI4 have no backup AMF set
	...  - 2 AMFs up and running
    ...  == Flow ==
    ...  1.	Attach UE1 to AMF1:GUAMI1
    ...  2.	Verify that UE1 is attached to AMF1:GUAMI1
    ...  3.	Attach UE2 to AMF1:GUAMI2
    ...  4.	Verify that UE2 is attached to AMF1:GUAMI2
    ...  5.	Connect PDU Session to UE1 and UE2
    ...  6.	Run UL and DL traffic only on UE2
    ...  7.	Trigger AMF1 to send partial ASI with unavailableGuamiList:
    ...      •	GUAMI[1]
    ...          o	timerApproachForGUAMIRemoval=apply-timer
    ...          o	backupAMFName is set to AMF2
    ...  8.	Verify that alarm 7115 with faultID=7325 is raised for AMF1
    ...  9.	Verify that SERVEDAMF-1 object is updated as follows:
    ...      •	GUAMI[1].guamiStatus = unavailable
    ...      •	GUAMI[1].backupAmfName = AMF2
    ...  10.	Trigger UE1 to send NR-RRC: UL Information Transfer with PDU Session Modification Request
    ...  11.	Verify that gNB sends NGAP: Uplink NAS Transport to AMF1
    ...  12.	Verify that gNB does not send NGAP: Uplink NAS Transport to AMF2
    ...  13.	Wait until amfPlannedRemovalTimer expires
    ...  14.	Trigger AMF2 to send ASI with unavailableGuamiList (to ensure that SERVEDAMF-2.GUAMI[2] will be reselected later):
    ...      •	GUAMI[1]
    ...          o	timerApproachForGUAMIRemoval is not present
    ...          o	backupAMFName is not set
    ...  15.	Verify that SERVEDAMF-2 object is updated as follows:
    ...      •	GUAMI[1].guamiStatus = unavailable
    ...  16.	Trigger UE1 to send NR-RRC: UL Information Transfer with PDU Session Modification Request
    ...  17.	Verify that gNB performs AMF reselection for UE1 and backup AMF2 is selected
    ...  18.	Trigger AMF2 to send NGAP:UE Context Modification Request for UE1 with newGUAMI set to SERVEDAMF-2.GUAMI[2]
    ...  19.	Verify that gNB sends NGAP:UE Context Modification Response to AMF2
    ...  20.	Trigger AMF2 to send ASI with unavailableGuamiList:
    ...      •	GUAMI[2]
    ...          o	timerApproachForGUAMIRemoval is not present
    ...          o	backupAMFName is not set
    ...  21.	Verify that alarm 7115 with faultID=7325 is raised for AMF2
    ...  22.	Verify that SERVEDAMF-2 object is updated as follows:
    ...      •	GUAMI[2].guamiStatus = unavailable
    ...  23.	Trigger UE1 to send NR-RRC: UL Information Transfer with PDU Session Modification Request
    ...  24.	Verify that gNB performs AMF reselection for UE1 to AMF-1:GUAMI2
    ...  25.	Verify that gNB does not send NGAP: Uplink NAS Transport to AMF2
    ...  26.	Verify that UE2 traffic is not impacted
    ...  27.	Verify that UE2 is still connected to AMF1
    ...  28.	Verify that PM counters are incremented:
    ...      •	M55155C00004 (AMF_RESELECTION_GNB_ATT) = 2
    ...      •	M55155C00005 (AMF_RESELECTION_GNB_FAIL) = 0
    ...      •	M55155C00006 (AMF_RESELECTION_GNB_SUCC) = 2
    ...  29.	Teardown:
    ...      •	Reset AMF1 GUAMIs to operable state after AMF Status Indication
    ...          o	SERVEDAMF-1.guAMI[1].guamiStatus = available
    ...          o	SERVEDAMF-1.guAMI[1].backupAMFName not set
    ...      •	Reset AMF2 GUAMIs to operable state after AMF Status Indication
    ...          o	SERVEDAMF-2.guAMI[1].guamiStatus = available
    ...      •	Wait until alarm with faultID=7325 is cleared
    ...
    ...  == Postcondition ==
    ...  - Alarm with faultID=7325 is cleared
    ...  - NGAP link gNB-AMF1 is active
    ...  - NGAP link gNB-AMF2 is active
    ...  - UE1 is in active state
    ...  == TESTING TOOLS ==
    ...  AirPhone, 5GCSim, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  CB006999-A-B501
    ...  == REQUIRED LOGS ==
    ...  NGAP
    ...  == AUTHOR ==
    ...  - Cezary Dudek <cezary.dudek@nokia.com>
    ...  - Konrad Krzyzak <konrad.krzyzak@nokia.com>
    ...  == REFERENCES ==
    ...  CB006999-2765

    [Setup]  Prepare test environment AB501-1

    Attach UE1 to AMF1:GUAMI:1 without starting traffic
    Attach UE2 to AMF1:GUAMI:2 and run traffic on PDU 2

    Send ASI from AMF1 with one GUAMI:1 backupAMF:2 timerApproach:on
    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF1
    Verify SERVEDAMF-1:GUAMI_index-1 is correctly updated: backupAmfName=AMF2, guamiStatus=unavailable

    Expect that gNB does not send NGAP: Uplink NAS Transport to AMF-2
    Expect that gNB sends NGAP: Uplink NAS Transport to AMF1
    Trigger UE1 to send PDU Session Modification for PDU1
    Verify that gNB does not send NGAP: Uplink NAS Transport to AMF-2
    Verify that gNB sends NGAP: Uplink NAS Transport to AMF1

    Wait until amfPlannedRemovalTimer expiration

    Lock AMF2:GUAMI1 with ASI from being used in AMF reselection
    Verify SERVEDAMF-2:GUAMI_index-1:guamiStatus is set to unavailable

    Expect that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF2 is selected
    Expect that UE Context Modification was sent from AMF2 with UE1 with aMFPointer equal to 4 in payload
    Trigger UE1 to send PDU Session Modification for PDU1
    Verify that UE Context Modification was sent from AMF2 with UE1 with aMFPointer equal to 4 in payload
    Verify that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF2 is selected

    Send ASI from AMF2 with one GUAMI:2 backupAMF:None timerApproach:off
    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF2
    Verify SERVEDAMF-2:GUAMI_index-2:guamiStatus is set to unavailable

    Verify if NewGUAMI applied in UE1 and gNB performs AMF reselection due to new UPLINK NAS message

    Stop and verify 20MBps UL and DL traffic on UE2 PDU2 QFI1

    Wait until PM counters file is ready and saved
    Verify PM counters for gNB initiated AMF reselection are incremented successfully: attempts:2, fails:0, successes:2

    [Teardown]  Teardown test environment AB501-1

CB006999-A-B501-2-ASI_with_reselection_to_oldAMF_different_GUAMI_UeCtxModification_with_NewGUAMI_check
    [Tags]    AB501-2
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  This testcase shows that when the last active AMF with two GUAMIs and NGAP:ASI sets one GUAMI
    ...  currently used by UE as UNAVAILABLE, then UE is reselected to other available GUAMI
    ...  from the same AMF.
    ...  This testcase also shows that UE traffic is not impacted before and after AMF reselection.
    ...  == Precondition ==
	...  - gNB up and running
	...  - NRBTS.actNgcFlexSaMode=true (5GC000740)
	...  - NRBTS.actAmfPlannedRemoval=true
	...  - NRBTS.amfPlannedRemovalTimer=0
	...  - AMF-1 is configured with 2 GUAMIs (GUAMI1, GUAMI2) - SERVEDAMF-1
	...  - AMF-2 is configured with 2 GUAMIs (GUAMI3, GUAMI4) - SERVEDAMF-2
	...  - GUAMI1, GUAMI2 have no backup AMF set
	...  - Established NG link AMF1-gNB
	...  - NG link towards AMF2 is locked
	...  - 2 AMFs up and running
    ...  == Flow ==
	...  1.	 Attach UE1 to AMF1:GUAMI1 and run traffic
	...  2.	 Send ASI from AMF1 with one GUAMI:1 backupAMF:2 timerApproach:on
	...  3.	 Trigger UE1 to send NR-RRC: UL Information Transfer with PDU Session Modification Request
	...  4.	 Verify that gNB sends NGAP: Uplink NAS Transport to AMF1
	...  5.	 Wait until amfPlannedRemovalTimer expires
	...  6.	 Trigger UE1 to send NR-RRC: UL Information Transfer with PDU Session Modification Request
	...  7.	 Verify that gNB performs AMF reselection for UE1 and AMF1 is selected
	...  8.	 Verify that gNB sends NGAP: Uplink NAS Transport to AMF1
	...  9.  Trigger AMF1 to send NGAP:UE Context Modification Request for UE1 with newGUAMI set to SERVEDAMF-1.GUAMI[2]
	...  10. Verify that gNB sends NGAP:UE Context Modification Response to AMF1
	...  11. Verify that gNB sends NGAP: Uplink NAS Transport to AMF1
    ...  == Postcondition ==
	...  - UE1 is in active state
	...  - Alarm with faultID=7325 is cleared
	...  - NGAP link gNB-AMF1 is active
    ...  == TESTING TOOLS ==
    ...  AirPhone, 5GCSim, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classical BTS in SA mode
    ...  - HARDWARE ID: gNB(ABIL + ASIK) with simulated AEQA radio module - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  CB006999-A-B501
    ...  == REQUIRED LOGS ==
    ...  NGAP
    ...  == AUTHOR ==
    ...  - Cezary Dudek <cezary.dudek@nokia.com>
    ...  == REFERENCES ==
    ...  CB006999-2765

    [Setup]  Prepare test environment AB501-2
    Attach UE1 to AMF1:GUAMI:1 and run traffic on PDU 1

    Send ASI from AMF1 with one GUAMI:1 and redirection to other GUAMI
    Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF1
    Verify SERVEDAMF-1:GUAMI_index-1:guamiStatus is set to unavailable

    Expect that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF1 is selected
    Expect that UE Context Modification was sent from AMF1 with UE1 with aMFPointer equal to 2 in payload
    Trigger UE1 to send PDU Session Modification for PDU1
    Verify that after PDU Session Modification Request from UE1 gNB performs AMF reselection and AMF1 is selected
    Verify that UE Context Modification was sent from AMF1 with UE1 with aMFPointer equal to 2 in payload

    Stop and verify 20MBps UL and DL traffic on UE1 PDU1 QFI1

    Wait until PM counters file is ready and saved
    Verify PM counters for gNB initiated AMF reselection are incremented successfully: attempts:1, fails:0, successes:1

    [Teardown]  Teardown test environment AB501-2

