*** Settings ***
Documentation
...   author: Rafal Kaczmarski
...   contact: rafal.kaczmarski@nokia.com

Library     ta_attenuator
Library     ute_ue
Library     taf.sbts.oam.coam.admin   WITH NAME   taf_admin
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/CB010751/resources/test_specific_keywords.py
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.common_keywords.file_utils
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.log_collectors.elt_log_collector.EltLogCollector   WITH NAME   ELT
Library     OperatingSystem
Library     DateTime
Library     SSHLibrary
Library     taf.ul.alarms_watchdog    WITH NAME   WATCHDOG
Library     testsuite/Wroclaw/RRM/resources/scout_report.py
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    testsuite/Wroclaw/RRM/resources/pm_counters/pm_counters.robot
Resource    taf/rfrl/bts/robot/gnb.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/testline_preparation/testline_preparation.robot
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/allowed_alarms.py

*** Variables ***
${LOG_PATH}         ${OUTPUT_DIR}
${GNB_IP}           ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}
${at_command_apn}   AT+EAPNSET="5gsawro",2,"type=default;protocol=IP;roaming_protocol=IP;authtype=0;carrier_enabled=1; \
...                 max_conns=0;max_conns_time=0;wait_time=0;bearer_bitmask=4294836223;inactive_timer=0"
@{at_commands}      AT+EGCMD=6,6,"VGMM_CLEAR_GUTI"  AT+ERAT=19  AT+EAPNLOCK=1  AT+EAPNSET="5gsawro",1,"",""
...                 ${at_command_apn}
...                 AT+EAPNLOCK=0
...                 AT+EIAAPN="5gsawro"  AT+ESBP=5,"SBP_REJECT_QUERY_CONNECTED_STATE_CID",0  AT+CEMODE=0  AT+EFUN=1
...                 AT+EAPNACT=1,"5gsawro","default",0   AT+CGPADDR=1

*** Keywords ***
CB010751_AB1_TC01_Suspend_after_NRBTS_drbRrcInactInactivityRedCapTimerSA_expiration
    Log To Console    \nStarting test...
    @{counters}=       Create List                    M55124C00006    M55166C00013    M55138C00062
    Wait Until Keyword Succeeds  20x  10s              Check Counters  @{counters}  expected_value=0
    Create Syslog Collector    BtsLog.tgz
    Create TCPDump Collector    AB_1
    Start Syslog
    Start TCP Dump
    ELT.Start Log Collecting
    Attach RedCap UE    ${CELL_1_ALIAS}
    Sleep    40s
    Stop And Collect Tcp Dump    ${OUTPUT_DIR}/${TEST_NAME}/
    Stop And Collect Syslog    ${OUTPUT_DIR}/${TEST_NAME}/
    ELT.Stop Log Collecting
    ${elt_log}=  ELT.Download Log   ${LOG_PATH}/${TEST_NAME}/elt_log.json
    Validate Inactive State    ${LOG_PATH}/${TEST_NAME}/elt_log.json    0
    Convert Pdml    ${OUTPUT_DIR}/${TEST_NAME}/tcpdump/AB_1
    Verify Callflow For AB1    ${OUTPUT_DIR}/${TEST_NAME}/tcpdump/AB_1.pdml
    Wait Until Keyword Succeeds  20x  10s              Check Counters  @{counters}


CB010751_PMO_A2_TC02_Counter_update_due_to_successful_Resume
    Log To Console    \nStarting test...
    @{counters_1}=    Create List    M55124C00007    M55124C00010    M55306C06002    M55138C00063    M55138C00064    M55138C00065    M55156C00052
    @{counters_2}=    Create List    M55124C00007    M55124C00010    M55306C06002    M55138C00063    M55138C00064
    @{counters_3}=    Create List    M55138C00009    M55138C00065
    @{counters_4}=    Create List    M55156C00052
    Wait Until Keyword Succeeds  20x  10s              Check Counters  @{counters_1}  expected_value=0
    Create Syslog Collector    BtsLog.tgz
    Create TCPDump Collector    PMO_A2
    Start Syslog
    Start TCP Dump
    ELT.Start Log Collecting
    Attach RedCap UE    ${CELL_1_ALIAS}
    Sleep    40s
    Start Ul Data Transfer
    ELT.Stop Log Collecting
    ${elt_log}=  ELT.Download Log   ${LOG_PATH}/${TEST_NAME}/elt_log_ul.json
    ELT.Start Log Collecting
    Sleep    40s
    Start Dl Data Transfer
    Stop And Collect Tcp Dump    ${OUTPUT_DIR}/${TEST_NAME}/
    Stop And Collect Syslog    ${OUTPUT_DIR}/${TEST_NAME}/
    ELT.Stop Log Collecting
    ${elt_log}=  ELT.Download Log    ${LOG_PATH}/${TEST_NAME}/elt_log_dl.json
    Validate RRCResumeRequest1    ${LOG_PATH}/${TEST_NAME}/elt_log_ul.json    4
    Validate RRCResumeRequest1    ${LOG_PATH}/${TEST_NAME}/elt_log_dl.json    2
    Validate Inactive State    ${LOG_PATH}/${TEST_NAME}/elt_log_ul.json    0
    Validate Inactive State    ${LOG_PATH}/${TEST_NAME}/elt_log_dl.json    0
    Convert Pdml    ${OUTPUT_DIR}/${TEST_NAME}/tcpdump/PMO_A2
    Verify Callflow For PMO A2    ${OUTPUT_DIR}/${TEST_NAME}/tcpdump/PMO_A2.pdml
    Wait Until Keyword Succeeds    20x    10s    Check Counters    @{counters_2}    expected_value=2
    Wait Until Keyword Succeeds    20x    10s    Check Counters    @{counters_3}    morethanzero=morethanzero
    Wait Until Keyword Succeeds    20x    10s    Check Counters    @{counters_4}


CB010751_AEC1_TC03_Release_to_RRC_Idle_due_to_lack_of_ranac
    Log To Console    \nStarting test...
    Create Syslog Collector    BtsLog.tgz
    Create TCPDump Collector    AEC1
    Start Syslog
    Start TCP Dump
    ELT.Start Log Collecting
    Attach RedCap UE    ${CELL_3_ALIAS}
    Sleep    40s
    Stop And Collect Tcp Dump    ${OUTPUT_DIR}/${TEST_NAME}/
    Stop And Collect Syslog    ${OUTPUT_DIR}/${TEST_NAME}/
    ELT.Stop Log Collecting
    ${elt_log}=  ELT.Download Log   ${LOG_PATH}/${TEST_NAME}/elt_log.json
    Convert Pdml    ${OUTPUT_DIR}/${TEST_NAME}/tcpdump/AEC1
    Verify Callflow For AEC1    ${OUTPUT_DIR}/${TEST_NAME}/tcpdump/AEC1.pdml
    Validate Idle State    ${LOG_PATH}/${TEST_NAME}/elt_log.json


CB010751_AEC2_TC04_RRCReject_by_maxNumOfRrcSARedCap_AC_failure_with_CB008225_DE1
    Log To Console    \nStarting test...
    Create Syslog Collector    BtsLog.tgz
    Create TCPDump Collector    AEC2
    Start Syslog
    Start TCP Dump
    ELT.Start Log Collecting
    Attach RedCap UE    ${CELL_1_ALIAS}
    Sleep    40s
    Set maxNumOfRrcSARedCap    0
    Start Ul Data Transfer
    Stop And Collect Tcp Dump    ${OUTPUT_DIR}/${TEST_NAME}/
    Stop And Collect Syslog    ${OUTPUT_DIR}/${TEST_NAME}/
    ELT.Stop Log Collecting
    ${elt_log}=  ELT.Download Log   ${LOG_PATH}/${TEST_NAME}/elt_log_ul.json
    Validate Inactive State    ${LOG_PATH}/${TEST_NAME}/elt_log_ul.json    0
    Convert Pdml    ${OUTPUT_DIR}/${TEST_NAME}/tcpdump/AEC2
    Verify Callflow For AEC2    ${OUTPUT_DIR}/${TEST_NAME}/tcpdump/AEC2.pdml
    Validate RRCResumeRequest1 UL With Reject    ${LOG_PATH}/${TEST_NAME}/elt_log_ul.json    4


CB010751_PMO_A3_TC05_Counter_update_due_to_fallback_after_intra-gNB_reselection_to_cell_without_ranAC
    Log To Console    \nStarting test...
    @{counters_1}=    Create List    M55166C00012    M55124C00008    M55124C00013    M55124C00014    M55138C00070    M55138C00069    M55138C00068
    ...                              M55166C00502    M55166C00011    M55124C01001
    @{counters_2}=    Create List    M55124C00008    M55124C00013    M55124C00014    M55138C00070    M55138C00069    M55138C00068
    @{counters_3}=    Create List    M55166C00012    M55166C00502    M55166C00011    M55124C01001
    Wait Until Keyword Succeeds    20x    10s    Check Counters    @{counters_1}    cell_id=222    expected_value=0
    Create Syslog Collector    BtsLog.tgz
    Create TCPDump Collector    PMO_A3
    Start Syslog
    Start TCP Dump
    ELT.Start Log Collecting
    Attach RedCap UE    ${CELL_1_ALIAS}
    Sleep    40s
    Trigger Intra-gNB HO
    Stop And Collect Tcp Dump    ${OUTPUT_DIR}/${TEST_NAME}/
    Stop And Collect Syslog    ${OUTPUT_DIR}/${TEST_NAME}/
    ELT.Stop Log Collecting
    ${elt_log}=  ELT.Download Log   ${LOG_PATH}/${TEST_NAME}/elt_log_ul.json
    Validate Inactive State    ${LOG_PATH}/${TEST_NAME}/elt_log_ul.json    0
    Convert Pdml    ${OUTPUT_DIR}/${TEST_NAME}/tcpdump/PMO_A3
    Verify Callflow For Pmo A3    ${OUTPUT_DIR}/${TEST_NAME}/tcpdump/PMO_A3.pdml
    Wait Until Keyword Succeeds    20x    10s    Check Counters    @{counters_2}    cell_id=222    expected_value=1
    Wait Until Keyword Succeeds    20x    10s    Check Counters    @{counters_3}    cell_id=222    expected_value=0


CB010751_BIWK2_TC06_Suspend_with_NRDRB_and_SNSSAI_timers_configured
    Log To Console    \nStarting test...
    Create Syslog Collector    BtsLog.tgz
    Create TCPDump Collector    BIWK2
    Start Syslog
    Start TCP Dump
    ELT.Start Log Collecting
    Attach RedCap UE    ${CELL_1_ALIAS}
    Sleep    20s
    Stop And Collect Tcp Dump    ${OUTPUT_DIR}/${TEST_NAME}/
    Stop And Collect Syslog    ${OUTPUT_DIR}/${TEST_NAME}/
    ELT.Stop Log Collecting
    ${elt_log}=  ELT.Download Log   ${LOG_PATH}/${TEST_NAME}/elt_log.json
    Validate Inactive State    ${LOG_PATH}/${TEST_NAME}/elt_log.json    0
    Convert Pdml    ${OUTPUT_DIR}/${TEST_NAME}/tcpdump/BIWK2
    Verify Callflow For AB1    ${OUTPUT_DIR}/${TEST_NAME}/tcpdump/BIWK2.pdml


CB010751_AB3_TC08_Resume_by_DL_user_plane_data_after_intra-gNB_reselection_to_NRCELL_with_different_RANAC
    Log To Console    \nStarting test...
    Create Syslog Collector    BtsLog.tgz
    Create TCPDump Collector    AB3
    Start Syslog
    Start TCP Dump
    ELT.Start Log Collecting
    Attach RedCap UE    ${CELL_1_ALIAS}
    Sleep    40s
    Trigger Intra-gNB HO
    ELT.Stop Log Collecting
    ${elt_log}=  ELT.Download Log   ${LOG_PATH}/${TEST_NAME}/elt_log_ho.json
    ELT.Start Log Collecting
    Sleep    40s
    Start Dl Data Transfer
    ELT.Stop Log Collecting
    ${elt_log}=  ELT.Download Log   ${LOG_PATH}/${TEST_NAME}/elt_log_dl.json
    Stop And Collect Tcp Dump    ${OUTPUT_DIR}/${TEST_NAME}/
    Stop And Collect Syslog    ${OUTPUT_DIR}/${TEST_NAME}/
    Convert Pdml    ${OUTPUT_DIR}/${TEST_NAME}/tcpdump/AB3
    Validate Inactive State For AB3    ${LOG_PATH}/${TEST_NAME}/elt_log_ho.json    0    1
    Validate RRCResumeRequest1    ${LOG_PATH}/${TEST_NAME}/elt_log_ho.json    8
    Validate RRCResumeRequest1    ${LOG_PATH}/${TEST_NAME}/elt_log_dl.json    2
    Validate RRCResume    ${LOG_PATH}/${TEST_NAME}/elt_log_dl.json
    Verify Callflow For AB3    ${OUTPUT_DIR}/${TEST_NAME}/tcpdump/AB3.pdml


CB010751_BIWK4_TC07_RNA_update_with_non_CA_aware_mobility_steering
    Log To Console    \nStarting test...
    Create Syslog Collector    BtsLog.tgz
    Create TCPDump Collector    BIWK4
    Start Syslog
    Start TCP Dump
    ELT.Start Log Collecting
    Attach RedCap UE    ${CELL_1_ALIAS}
    Sleep    340s
    Stop And Collect Tcp Dump    ${OUTPUT_DIR}/${TEST_NAME}/
    Stop And Collect Syslog    ${OUTPUT_DIR}/${TEST_NAME}/
    ELT.Stop Log Collecting
    ${elt_log}=  ELT.Download Log   ${LOG_PATH}/${TEST_NAME}/elt_log.json
    Validate RRCResumeRequest1    ${LOG_PATH}/${TEST_NAME}/elt_log.json    8
    Convert Pdml    ${OUTPUT_DIR}/${TEST_NAME}/tcpdump/BIWK4
    Verify Callflow For BIWK4    ${OUTPUT_DIR}/${TEST_NAME}/tcpdump/BIWK4.pdml


CB011041_A_B2_Alt2_RAN_Paging_due_to_DL_cplane_msg_for_RedCap_UE
    Log To Console    \nStarting test...
    @{counters_cell_1}=    Create List    M55117C00004    M55197C00001    M55197C00002    M55117C04501
    @{counters_cell_221}=    Create List    M55331C00004    M55166C00506    M55124C00007    M55124C00010    M55166C00508
    @{counters_morethanzero}=    Create List    M55197C00003
    Wait Until Keyword Succeeds    20x    10s    Check Counters For CB11041_AB2    counters_1=@{counters_cell_1}    counters_2=@{counters_cell_221}
    ...                            counters_3=@{counters_morethanzero}    cell_id_1=1    cell_id_2=221    expected_value=0
    Create Syslog Collector    BtsLog.tgz
    Create TCPDump Collector    CB011041_AB2
    Start Syslog
    Start TCP Dump
    ELT.Start Log Collecting
    Attach RedCap UE    ${CELL_1_ALIAS}
    Sleep    485s
    ELT.Stop Log Collecting
    ${elt_log}=  ELT.Download Log   ${LOG_PATH}/${TEST_NAME}/elt_log.json
    Stop And Collect Tcp Dump    ${OUTPUT_DIR}/${TEST_NAME}/
    Stop And Collect Syslog    ${OUTPUT_DIR}/${TEST_NAME}/
    Convert Pdml    ${OUTPUT_DIR}/${TEST_NAME}/tcpdump/CB011041_AB2
    Validate Inactive State    ${LOG_PATH}/${TEST_NAME}/elt_log.json    0
    Validate RRCResumeRequest1    ${LOG_PATH}/${TEST_NAME}/elt_log.json    2
    Verify Callflow For CB011041_AB2    ${OUTPUT_DIR}/${TEST_NAME}/tcpdump/CB011041_AB2.pdml
    Confirm CB011041_AB2    ${OUTPUT_DIR}/${TEST_NAME}/btslog/SYSLOG_1.LOG
    Wait Until Keyword Succeeds    20x    10s    Check Counters For CB11041_AB2    counters_1=@{counters_cell_1}    counters_2=@{counters_cell_221}
    ...                            counters_3=@{counters_morethanzero}    cell_id_1=1    cell_id_2=221    expected_value=1
    Detach RedCap UE


CB011041_B_EC1_Failed_RAN_Paging_due_to_DL_data_with_Paging_Repetition_Strategy
    Log To Console    \nStarting test...
    Create Syslog Collector    BtsLog.tgz
    Create TCPDump Collector    CB011041_BEC1
    Start Syslog
    Start TCP Dump
    ELT.Start Log Collecting
    Attach RedCap UE    ${CELL_1_ALIAS}
    Sleep    40s
    Set Attenuation    ${CELL_1_ALIAS}    90dB
    Start Dl Data Transfer
    ELT.Stop Log Collecting
    ${elt_log}=  ELT.Download Log   ${LOG_PATH}/${TEST_NAME}/elt_log.json
    Stop And Collect Tcp Dump    ${OUTPUT_DIR}/${TEST_NAME}/
    Stop And Collect Syslog    ${OUTPUT_DIR}/${TEST_NAME}/
    Convert Pdml    ${OUTPUT_DIR}/${TEST_NAME}/tcpdump/CB011041_BEC1
    Validate Inactive State    ${LOG_PATH}/${TEST_NAME}/elt_log.json    0
    Verify Callflow For BEC1    ${OUTPUT_DIR}/${TEST_NAME}/tcpdump/CB011041_BEC1.pdml
    Confirm CB011041 BEC1    ${OUTPUT_DIR}/${TEST_NAME}/btslog/SYSLOG_1.LOG


CB011041_PMO_B3_Counter_update_for_Intra-GNB_Fallback_to_RRCSetup_by_RNAU_with_RRCResumeRequest
    Log To Console    \nStarting test...
    @{counters_1}=    Create List    M55125C00504
    @{counters_2}=    Create List    M55124C00008    M55124C00013    M55124C00014
    Wait Until Keyword Succeeds    20x    10s    Check Counters For CB11041_PMO_B3    counters_1=@{counters_1}    counters_2=@{counters_2}
    ...                            cell_id_1=221    cell_id_2=222    expected_value=0
    Create Syslog Collector    BtsLog.tgz
    Create TCPDump Collector    PMO_B3
    Start Syslog
    Start TCP Dump
    ELT.Start Log Collecting
    Attach RedCap UE    ${CELL_1_ALIAS}
    Sleep    40s
    Trigger Intra-gNB HO
    Stop And Collect Tcp Dump    ${OUTPUT_DIR}/${TEST_NAME}/
    Stop And Collect Syslog    ${OUTPUT_DIR}/${TEST_NAME}/
    ELT.Stop Log Collecting
    ${elt_log}=  ELT.Download Log   ${LOG_PATH}/${TEST_NAME}/elt_log.json
    Validate Inactive State    ${LOG_PATH}/${TEST_NAME}/elt_log.json    0
    Convert Pdml    ${OUTPUT_DIR}/${TEST_NAME}/tcpdump/PMO_B3
    Verify Callflow For PMO_B3    ${OUTPUT_DIR}/${TEST_NAME}/tcpdump/PMO_B3.pdml
    Wait Until Keyword Succeeds    20x    10s    Check Counters For CB11041_PMO_B3    counters_1=@{counters_1}    counters_2=@{counters_2}
    ...                            cell_id_1=221    cell_id_2=222    expected_value=0


Test Setup
    [Arguments]    ${set_maxNumOfRrcSARedCap}=${FALSE}    ${BIWK2}=${FALSE}    ${AB3}=${FALSE}    ${BIWK4}=${FALSE}
    ...            ${CB011041_AB2}=${FALSE}    ${CB011041_BEC1}=${FALSE}
    Set Test Variable    ${set_maxNumOfRrcSARedCap}    ${set_maxNumOfRrcSARedCap}
    Set Test Variable    ${BIWK2}    ${BIWK2}
    Set Test Variable    ${BIWK4}    ${BIWK4}
    Set Test Variable    ${AB3}    ${AB3}
    Set Test Variable    ${CB011041_AB2}    ${CB011041_AB2}
    Set Test Variable    ${CB011041_BEC1}    ${CB011041_BEC1}
    IF    ${BIWK2}    Set BIWK2 Parameters Setup
    IF    ${BIWK4}    Set IdleMMSteering    true    true
    IF    ${AB3}    Set Ranac    update    1
    IF    ${CB011041_AB2}   Set CB11041 Initial Parameters    pagingStratForRrcInact    10min
    IF    ${CB011041_BEC1}   Set CB11041 Initial Parameters    pagingStratForRrcInact    10min    5    20    ${True}
    WATCHDOG.Watch Alarms    allowed_alarms=${allowed_alarms}
    Verify Bts Is Operational
    ELT.Setup    configuration=${CONFIGURATION}
    ELT.Set Logging Filter   OTA
    ELT.Set Logging Filter   SYS    ${CODES}
    Collect SCF Before Test
    Set Initial Attenuation
    Detach RedCap UE


Teardown
    Detach RedCap UE
    WATCHDOG.Check Detected Alarms
    WATCHDOG.Stop Watching Alarms
    Run Keyword If Test Failed    Killall Tcpdump After Test
    Run Keyword If Test Failed    Stop And Collect Syslog    ${OUTPUT_DIR}/${TEST_NAME}/
    Run Keyword If Test Failed    Collect BTS Snapshot
    Add Scout Scf Id To Test Data
    IF    ${set_maxNumOfRrcSARedCap}    set_maxNumOfRrcSARedCap    50
    IF    ${BIWK2}    Set BIWK2 Parameters Teardown
    IF    ${BIWK4}    Set IdleMMSteering    false    false
    IF    ${AB3}      Set Ranac    delete    get_empty_list
    Run Keyword And Ignore Error    taf_admin.Teardown All Aliases For Admin
    Release Attenuator
    ELT.Shutdown
    IF    ${CB011041_BEC1}    Reboot Redcap UE


Set CB11041 Initial Parameters
    [Arguments]    ${actPagingEnh}    ${t380}    ${pagingRepMaxNum}=${None}    ${ranPagingRepGuardTimer}=${None}    ${bec1}=${False}
    Set actPagingEnh    ${actPagingEnh}    ${t380}    ${pagingRepMaxNum}    ${ranPagingRepGuardTimer}    ${bec1}
    Wait For X2 Link Available


Wait For X2 Link Available
    [Arguments]    ${admin_alias}=source
    Wait Until Keyword Succeeds  30  10  taf_admin.Setup Admin    bts_host=${gNB_IP}    alias=${admin_alias}
    Wait Until Keyword Succeeds  900  10  testline_preparation.Verify X2 Link Is Available  ${admin_alias}
    taf_admin.Teardown Admin    connection=${admin_alias}


Killall Tcpdump After Test
    SSHLibrary.Open Connection    host=${GNB_IP}    alias=target_pcap
    SSHLibrary.Login    toor4nsn    oZPS0POrRieRtu
    SSHLibrary.Start Command    killall tcpdump
    Sleep    10s
    ${response}    Read Command Output
    Log To Console    ${response} on ${GNB_IP}


Verify Bts Is Operational
    Log To Console  \nBTS Verification Ongoing...
    Verify Gnb Is OnAir
    WATCHDOG.Check Detected Alarms


Set Initial Attenuation
    ${cell_list}=    Create list    GNB_1_CELL_221    GNB_1_CELL_222    GNB_1_CELL_223    GNB_2_CELL_501    GNB_2_CELL_502
    Set global variable   ${gnb_cells}   ${cell_list}
    Load Attenuation Config    ${ABSTRACT_LIB_CONFIG}
    Require Attenuator Setup Of    ${gnb_cells}
    Set Attenuation    ${CELL_1_ALIAS}    90dB
    Set Attenuation    ${CELL_2_ALIAS}    90dB
    Set Attenuation    ${CELL_3_ALIAS}    90dB
    Set Attenuation    ${CELL_4_ALIAS}    90dB
    Set Attenuation    ${CELL_5_ALIAS}    90dB
    Sleep  2s


Release Attenuator
    Set Attenuation For All Cells  90dB
    Release attenuator cell    ${gnb_cells}


Attach RedCap UE
    [Arguments]    ${cell}
    [Timeout]    60s
    Set Attenuation    ${cell}    0dB
    Sleep    2s
    ELT.Send AT Command   AT+EFUN=0
    ELT.Send Pcommand
    FOR    ${command}    IN    @{at_commands}
       ELT.Send AT Command   ${command}
       Log To console   ${command}
    END
    ${ip}=    ELT.Set IP    serial_number=m60_caymus_c0934
    Set Test Variable    ${ip}    ${ip}
    Log to Console    ${ip}
    Log To Console    \nUE attached!


Detach RedCap UE
    ELT.Send AT Command   AT+EFUN=0


Trigger Intra-gNB HO
    Log To Console    Starting IntraGNB HO...
    Set Attenuation    ${CELL_2_ALIAS}    10db
    FOR    ${i}  IN RANGE  0  90  2
        Set Attenuation  ${CELL_1_ALIAS}  ${i}db
        Sleep  1s
    END
    Log To Console    HO procedure done...


Check Counters
    [Arguments]  @{counters}  ${cell_id}=221  ${expected_value}=1  ${morethanzero}=${None}
    Collect Counters
    ${updated_counter_values}    Get Last Counter Values    @{counters}
    Cleanup All Downloaded Counter Files
    ${results}=  Check If Counters Increased  ${updated_counter_values}  cell_id=${cell_id}  expected_value=${expected_value}
    ...                                       morethanzero=${morethanzero}


Check Counters For CB11041_AB2
    [Arguments]  ${counters_1}    ${counters_2}    ${counters_3}    ${cell_id_1}    ${cell_id_2}    ${expected_value}   ${morethanzero}=${None}
    Collect Counters
    ${updated_counter_values_1}    Get Last Counter Values    @{counters_1}
    ${updated_counter_values_2}    Get Last Counter Values    @{counters_2}
    ${updated_counter_values_3}    Get Last Counter Values    @{counters_3}
    Cleanup All Downloaded Counter Files
    ${results_1}=  Check If Counters Increased  ${updated_counter_values_1}  cell_id=${cell_id_1}  expected_value=${expected_value}
    ...                                       morethanzero=${morethanzero}
    ${results_2}=  Check If Counters Increased  ${updated_counter_values_2}  cell_id=${cell_id_2}  expected_value=${expected_value}
    ...                                       morethanzero=${morethanzero}
    ${results_3}=  Check If Counters Increased  ${updated_counter_values_3}  cell_id=${cell_id_1}  expected_value=${expected_value}
    ...                                       morethanzero=morethanzero


Check Counters For CB11041_PMO_B3
    [Arguments]  ${counters_1}    ${counters_2}    ${cell_id_1}    ${cell_id_2}    ${expected_value}   ${morethanzero}=${None}
    Collect Counters
    ${updated_counter_values_1}    Get Last Counter Values    @{counters_1}
    ${updated_counter_values_2}    Get Last Counter Values    @{counters_2}
    Cleanup All Downloaded Counter Files
    ${results_1}=  Check If Counters Increased  ${updated_counter_values_1}  cell_id=${cell_id_1}  expected_value=${expected_value}
    ...                                       morethanzero=${morethanzero}
    ${results_2}=  Check If Counters Increased  ${updated_counter_values_2}  cell_id=${cell_id_2}  expected_value=${expected_value}
    ...                                       morethanzero=${morethanzero}
