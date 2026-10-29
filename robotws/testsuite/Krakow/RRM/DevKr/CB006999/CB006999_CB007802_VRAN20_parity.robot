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
...      CB006999-B UE TNLA BINDING RELEASE REQUEST handling
...      == AUTHORS ==
...      - Marek Kieltyka <marek.kieltyka@nokia.com>
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
...         [23.03.2022] - Created parity suite for VRAN2.0
...         [13.02.2023] - Switch to VRAN4.0 RANNIC
...         [23.11.2023] - Switch to VRAN4.0 Rinline2 Thor

Resource    ./resources/CB006999.robot
Resource    ./resources/CB006999-A_setups_teardowns.robot
Resource    ./resources/CB006999-B_setups_teardowns.robot

Library    ./resources/CB006999_VRAN_verifiers.py

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    vDUCNF00    DISABLE_GENERATION
    ...    CLOUD_5GC_dRNIC_1vDU_P_AP_LO_SWFH
    ...    VARIANT_SANSA_FS_ECPRI_CMWV_TDD
    ...    PY39

Suite Setup  VRAN setup
Suite Teardown  Run keywords
...             vcu_emss_teardown    AND
...             vdu_emss_teardown

#TODO: make ta_emss working in VRAN auto

*** Variables ***
${LUA_CFG}=                       ${CURDIR}/config/VRAN/FS_SA_TDD_2c_3AMF.lua
${vran_basic_config_json_path}=   ${CURDIR}/config/VRAN/basic_enabler_3AMFs.json
${vran_basic_config_yaml_path}=   ${CURDIR}/config/yaml_config/VRAN_basic_enabler_3AMFs.yaml


*** Test Cases ***
CB006999-A-B203-2-Successful_AMF_selection_after_ASI_received_without_timer_and_without_backup_AMF
    [Tags]    AB203-2    GQC_PLAN:FEATURE:CB008608
    [Documentation]
    ...  DESCRIPTION:
    ...  == Info ==
    ...  == Precondition ==
    ...  - vCU
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
    ...  1. Attach UE1 to AMF1:GUAMI:1 without starting traffic
    ...  2. Connect UE-1 PDU session 1 with QoS flow
    ...  3. Wait until UE1 is going IDLE (UE got NR-RRC: RRCRelease from gNB)
    ...  4. Send NGAP: AMF STATUS INDICATION from AMF1 with GUAMI1 and GUAMI2
    ...  5. Send NGAP: AMF STATUS INDICATION from AMF2 with GUAMI3
    ...  6. Verify alarm 7115 (fault ID 7325) is raised for SERVEDAMF-1
    ...  7. Verify alarm 7115 (fault ID 7325) is raised for SERVEDAMF-2
    ...  8. Restore default gNB radio bearer inactivity timers (NRBTS.drbInactivityTimerSA=600, NRBTS.srbInactivityTimerSA=600)
    ...  9. Trigger UE1 IDLE mode exit
    ...  10. Verify that gNB performed selection to AMF3 for UE-1
    ...  == Postcondition ==
    ...  - UE-1 attached to AMF-1 and then attached to AMF-3 as it's last available AMF
    ...  - PM counters are incremented correctly:
    ...  - M55155C00001 (AMF_SELECTION_ATT) = 2
    ...  - M55155C00002 (AMF_SELECTION_FAIL) = 0
    ...  - M55155C00003 (AMF_SELECTION_SUCC) = 2
    ...  == TESTING TOOLS ==
    ...  AirPhone, EPCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB VRAN4.0 BTS in SA mode
    ...  - HARDWARE ID: gNB(vCU OE22 + vDU RANNIC) with simulated AEQP radio module - NR_BAND: n78
    ...  == REQUIREMENTS COVERAGE ==
    ...  5G_RAN_USR_RRM_6826
    ...  == REQUIRED LOGS ==
    ...  NGAP, NR-RRC
    ...  == AUTHOR ==
    ...  Marek Kieltyka <marek.kieltyka@nokia.com>
    ...  == REFERENCES ==
    ...  CFAM_CB006999
    ...  == HISTORY ==
    ...  [28.03.2022] - VRAN2.0 passed CB008608 - SW build: vCUCNF22R3_0.250.4039;vDUCNF22R3_0.300.4901
    ...  [20.06.2022] - add to QC Trunk - SW build: vCUCNF22R4_0.250.5497;vDUCNF22R4_0.300.6345
    ...  [06.02.2023] - VRAN4.0 passed CB009881 - SW build: vCUCNF23R2_0.250.10129;vDUCNF23R2_0.300.10815

    [Setup]  Prepare VRAN test environment AB203-2

    Attach UE1 to AMF1:GUAMI:1 without starting traffic
    Wait until UE1 is going IDLE

    Send ASI from AMF1 with two GUAMI:1 backupAMF:None timerApproach:off GUAMI:2 backupAMF:None timerApproach:off
    Send ASI from AMF2 with one GUAMI:1 backupAMF:None timerApproach:off

    VRAN Verify SERVEDAMF-1:GUAMI-1: backupAmfName=AMF2, guamiStatus=unavailable
    VRAN Verify SERVEDAMF-1:GUAMI-2: backupAmfName=AMF3, guamiStatus=unavailable
    VRAN Verify SERVEDAMF-2:GUAMI-1: backupAmfName=None, guamiStatus=unavailable
    Sleep  2
    VRAN Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF1
    VRAN Verify that alarm with NG AMF Status Indication fault and fault ID=7325 is raised for AMF2

    Expect that gNB performs selection to AMF3 for UE-1
    Trigger UE1 IDLE mode exit
    Verify that gNB performed selection to AMF3 for UE-1

    Wait until CU PM counters file is ready and saved
    Verify VRAN PM counters for AMF selection are incremented successfully: attempts:2, fails:0, successes:2

    [Teardown]  Teardown VRAN test environment AB203-2

*** Keywords ***
PCMD setup
    # ip argument must be the same as NRBTS.CTRLTS.TCE.tceIpAddress
    Configure PCMD    technology=5G    asn1per_decoding=${True}    ip=192.168.100.126     tshark_interface=eth5
    Sleep  2
    Start collecting PCMD reports
    Sleep  2

PCMD down
    Stop collecting PCMD reports
    Sleep  2
    Deconfigure PCMD
    Sleep  2

VRAN_SPECIFIC Cleanup Backup AMF Name from SERVEDAMF-${amf_id:\d+}
    Execute egate command   cmd=amf_ng_setup_param id=${amf_id} include_backup_amf_name=off
    TEMPORARY BYPASS: Reset NG link between AMF${amf_id} and gNB
    Verify that NG link to AMF-${amf_id} recovered

    VRAN Verify SERVEDAMF-1:GUAMI-1: backupAmfName=None, guamiStatus=available
    VRAN Verify SERVEDAMF-1:GUAMI-2: backupAmfName=None, guamiStatus=available

VRAN_SPECIFIC Wait until amfPlannedRemovalTimer expiration
    ${timer_duration}    vcu.Search parameters of current plan  parameter_name=amfPlannedRemovalTimer
    Sleep  ${timer_duration['items'][0]['parameter']['simple_parameter']['value']}

VRAN_SPECIFIC Restore AMF1 GUAMIs and backupAMFNames
    Execute Egate Command  cmd=amf_ng_setup_param id=1 include_backup_amf_name=on
    Restore AMF1 GUAMIs
    Sleep  1
    Execute egate command  cmd=send_hex source=amf:1 target=gnb:2 hex=${ACU_rest}
    Sleep  1

    VRAN Verify SERVEDAMF-1:GUAMI-1: backupAmfName=AMF2, guamiStatus=available
    VRAN Verify SERVEDAMF-1:GUAMI-2: backupAmfName=AMF3, guamiStatus=available

VRAN_SPECIFIC Trigger UE${ue_id} to send PDU Session Modification for PDU${pdu_id}
    Execute egate command    cmd=ue_pdu_session_modify pdu=${pdu_id} qosflows_to_del=2 ue=${ue_id}

VRAN setup
    Run keyword and ignore error
    ...     vcu.Connect to  host=${vCU_admin}  port=443  username=Nemuadmin  password=Nokia@123  secure=True
    Run keyword and ignore error
    ...     vdu.Connect to  host=${vDU_admin}  port=443  username=Nemuadmin  password=Nokia@123  secure=True
    setup_vcu_emss
    setup_vdu_emss
    vcu_configure       ${vran_basic_config_yaml_path}
#    Send CU delta commissioning   input_filepath=${vran_basic_config_json_path}
    ${run_update}    get variable value      ${configure}    True     # do not ever change that line!
    Run Keyword if  "${run_update}" == "True"
    ...         Reach OnAir in VRAN with retries   lua_cfg=${LUA_CFG}
    Run Keyword if  "${run_update}" != "True"
    ...         Setup egate  egate_port=20000  alias=default
    Create CB006999 VRAN devices aliases

