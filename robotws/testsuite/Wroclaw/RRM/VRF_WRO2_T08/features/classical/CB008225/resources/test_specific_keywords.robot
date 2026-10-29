*** Settings ***
Documentation
...    author:  Rafal Kaczmarski
...    contact: rafal.kaczmarski@nokia.com

Library     ta_attenuator
Library     taf.ue
Library     taf.sbts.oam.coam.admin   WITH NAME   taf_admin
Library     ./test_specific_keywords.py
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.log_collectors.elt_log_collector.EltLogCollector   WITH NAME   ELT
Library     OperatingSystem
Library     DateTime
Library     testsuite/Wroclaw/RRM/resources/webUI_operations.py
Library     testsuite/Wroclaw/RRM/resources/scout_report.py
Resource    testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    testsuite/Wroclaw/RRM/resources/pm_counters/pm_counters.robot

*** Variables ***
${LOG_PATH}         ${OUTPUT_DIR}
${gNB_IP}           ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}
${gNB_ID}           ${tl.gnbs[0].global_bts_id}
${VM_IP}            ${tl.test_pc.default_ssh_connection_details.addr}
@{RELEASES}         SBTS25R1    SBTS25R2    SBTS25R3
${B_B1_1}           e1ap.procedureCode == 8 and e1ap.ActivityNotificationLevel == 2 and e1ap.Inactivity_Timer == 30
${B_B1_2}           e1ap.procedureCode == 13 and e1ap.uE_Activity == 1
${B_B1_3}           nr-rrc.c1 == 2 and nr-rrc.MCC_MNC_Digit == 5 and nr-rrc.MCC_MNC_Digit == 4 and nr-rrc.MCC_MNC_Digit == 0
...                 and nr-rrc.MCC_MNC_Digit == 0 and nr-rrc.MCC_MNC_Digit == 1 and nr-rrc.RAN_AreaCode == 0 and nr-rrc.t380 == 0
${H_1}              f1ap.F1AP_PDU == 0 and nr-rrc.c1 == 2 and nr-rrc.criticalExtensions == 0 and nr-rrc.freqPriorityListNR == 3
...                 and nr-rrc.carrierFreq == 176500 and nr-rrc.cellReselectionPriority == 7 and nr-rrc.carrierFreq == 430000
...                 and nr-rrc.cellReselectionPriority == 6 and nr-rrc.RAN_AreaCode == 2


*** Keywords ***
Test Setup
    [Arguments]  ${COMMON}=${FALSE}  ${A_B2}=${FALSE}  ${H_B1}=${FALSE}  ${L}=${FALSE}    ${ELT}=${FALSE}
    Set Test Variable    ${A_B2}    ${A_B2}
    Set Test Variable    ${COMMON}    ${COMMON}
    Set Test Variable    ${H_B1}    ${H_B1}
    Set Test Variable    ${L}    ${L}
    Set Test Variable    ${ELT}    ${ELT}
    Collect SCF Before Test
    IF    ${A_B2}    Set Initial Parameters  none  false  false   2448  false  false
    IF    ${COMMON}    Set Initial Parameters  intra-gNB  false  false   2448  false  false
    IF    ${H_B1}    Set Initial Parameters  intra-gNB  true  true   2448  false  false
    IF    ${L}       Set Initial Parameters  intra-gNB  false  false   2448  true  true
    Prepare Ue
    IF    ${ELT}    ELT.Setup   ${True}    ${CONFIGURATION}
    IF    ${ELT}    ELT.Set Logging Filter   OTA


Teardown
    Make Snapshot In Case Of Error
    Add Scout Scf Id To Test Data
    IF    ${ELT}    ELT.Shutdown
    Run Keyword And Ignore Error    Detach Ue    UE_1
    Release Attenuator
    Run Keyword And Ignore Error    taf_admin.Teardown Admin    connection=admin_gnb
    Run Keyword And Ignore Error    taf_admin.Teardown All Aliases For Admin
    Run Keyword And Ignore Error    Stop And Collect Syslog    ${OUTPUT_DIR}/${TEST_NAME}/


Collect SCF Before Test
    taf_admin.Setup Admin    bts_host=${gNB_IP}     name=admin_gnb
    Log To Console    \nCollecting Backup SCF
    taf_admin.Get Current Scf File  ${LOG_PATH}/${test_name}/scf/  backup_scf.xml  timeout=60  connection=admin_gnb


Perform Commissioning Of Backup Scf
    Perform Scf Commissioning
    Wait For X2 Link Available    cells_up


Wait For X2 Link Available
    [Arguments]  ${admin_alias}
    taf_admin.Setup Admin    alias=${admin_alias}
    Wait Until Keyword Succeeds  900  10  testline_preparation.Verify X2 Link Is Available  ${admin_alias}
    taf_admin.Teardown Admin    connection=${admin_alias}


Set Initial Parameters
    [Arguments]  ${actRrcInactState}  ${rrcInactIMMSteeringEnabled}  ${actIdleMMSteering}  ${maxNumOfRrcConUEsPerDU}
    ...          ${actNrRrcSuccRateSlCellCuDetRec}  ${actAutNrRrcConStAtSlCellDetRec}
    Log To Console    \nSetting Up Initial Parameters
    taf_admin.Create_Delta    delta_id=delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}    actRrcInactState
    ...                                          ${actRrcInactState}    delta_id=delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}    rrcInactIMMSteeringEnabled
    ...                                         ${rrcInactIMMSteeringEnabled}    delta_id=delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}    actIdleMMSteering
    ...                                         ${actIdleMMSteering}    delta_id=delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRDU-1    maxNumOfRrcConUEsPerDU
    ...                                         ${maxNumOfRrcConUEsPerDU}    delta_id=delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/MNL-1/MNLENT-1/FEATCADM-1    actNrRrcSuccRateSlCellCuDetRec
    ...                                         ${actNrRrcSuccRateSlCellCuDetRec}    delta_id=delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/MNL-1/MNLENT-1/FEATCADM-1    actAutNrRrcConStAtSlCellDetRec
    ...                                         ${actAutNrRrcConStAtSlCellDetRec}    delta_id=delta
    IF   ${L} == ${TRUE}    Run Keywords
    ...    taf_admin.Append_Parameter_Delete_To_Delta
    ...    MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRCELL-2/NRPLMNSET_SA-1    ranAC    delta_id=delta    AND
    ...    taf_admin.Append_Parameter_Delete_To_Delta
    ...    MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRCELL-2/NRPLMNSET_SA-2    ranAC    delta_id=delta
    ...    ELSE    Run Keywords
    ...    taf_admin.Append_Parameter_Update_To_Delta
    ...    MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRCELL-2/NRPLMNSET_SA-1    ranAC    1    delta_id=delta  AND
    ...    taf_admin.Append_Parameter_Update_To_Delta
    ...    MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRCELL-2/NRPLMNSET_SA-2    ranAC    2    delta_id=delta
    ${delta}    taf_admin.Get_Delta    delta_id=delta
    taf_admin.Remove_All_Delta_Id
    taf_admin.Perform_Delta_Recommissioning    ${delta}    connection=admin_gnb
    Wait For X2 Link Available    cells_up


Activate CB008225
    ${params}=    cb008225_activation
    Log To Console    \nActivating CB008225...
    taf_admin.Setup Admin      bts_host=${gNB_IP}    name=activation
    taf_admin.Perform_Object_Recommissioning    dist_name=MRBTS-${gNB_ID}/NRBTS-${gNB_ID}
    ...                                         parameter=${params}
    ...                                         operation=update
    ...                                         connection=activation
    taf_admin.Teardown Admin    connection=activation


Set maxNumOfRrcConUEsPerDU
    [Arguments]   ${maxnumperdu}=0
    ${params}=    max_num_of_rrc_con_ues_per_du    ${maxnumperdu}
    Log To Console    \nChanging maxNumOfRrcConUEsPerDU parameter...
    taf_admin.Setup Admin      bts_host=${gNB_IP}    name=activation
    taf_admin.Perform_Object_Recommissioning    dist_name=MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRDU-1
    ...                                         parameter=${params}
    ...                                         operation=update
    ...                                         connection=activation
    taf_admin.Teardown Admin    connection=activation


Set maxNumOfRrcSA
    [Arguments]   ${maxNumOfRrcSA}=0
    ${params}=    max_num_of_rrc_sa    ${maxNumOfRrcSA}
    Log To Console    \nChanging maxNumOfRrcSA parameter...
    taf_admin.Setup Admin      bts_host=${gNB_IP}    name=activation
    taf_admin.Perform_Object_Recommissioning    dist_name=MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRCELL-1
    ...                                         parameter=${params}
    ...                                         operation=update
    ...                                         connection=activation
    taf_admin.Teardown Admin    connection=activation


Change PLMNs
    [Arguments]    ${PLMN_1}    ${PLMN_2}
    Log To Console    \nSetting given PLMN
    taf_admin.Setup Admin      bts_host=${gNB_IP}    name=plmns
    ${SW_RELEASE}=    taf_admin.Get Sw Release Name    connection=plmns
    Log To Console   ${SW_RELEASE}
    Log To Console   ${RELEASES}
    IF  "${SW_RELEASE}" in ${RELEASES}
        taf_admin.Create_Delta    delta_id=plmn
        taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}    mcc    ${PLMN_1}    delta_id=plmn
        taf_admin.append_complex_item_to_delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRCELL-2/NRREL-4
        ...     gnbPlmn
        ...     mcc=${PLMN_1}
        ...     mnc=1
        ...     mncLength=2
        ...     delta_id=plmn
        taf_admin.append_complex_item_to_delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRCELL-4/NRREL-2
        ...     gnbPlmn
        ...     mcc=${PLMN_1}
        ...     mnc=1
        ...     mncLength=2
        ...     delta_id=plmn
        taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRPLMN-1    mcc    ${PLMN_1}    delta_id=plmn
        taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRPLMN-2    mcc    ${PLMN_2}    delta_id=plmn
        ${delta}    taf_admin.Get_Delta    delta_id=plmn
        taf_admin.Remove_All_Delta_Id
        taf_admin.Perform_Delta_Recommissioning    ${delta}    connection=plmns
        taf_admin.Teardown Admin    connection=plmns
        Wait For X2 Link Available    cells_up
    END


Set Initial Attenuation
    ${cell_list}=   Create list   GNB_1_CELL_1    GNB_1_CELL_2  GNB_2_CELL_1   GNB_2_CELL_2    GNB_2_CELL_3
    ...    GNB_1_CELL_4
    Set global variable   ${gnb_cells}   ${cell_list}
    Load Attenuation Config    ${ABSTRACT_LIB_CONFIG}
    Require Attenuator Setup Of    ${gnb_cells}
    Set Attenuation    ${CELL_1_ALIAS}    90dB
    Set Attenuation    ${CELL_2_ALIAS}    90dB
    Set Attenuation    ${CELL_3_ALIAS}    90dB
    Set Attenuation    ${CELL_4_ALIAS}    90dB
    Set Attenuation    ${CELL_6_ALIAS}    90dB
    Sleep  2s


Release Attenuator
    Set Attenuation For All Cells  90dB
    Release attenuator cell    ${gnb_cells}


Prepare Ue
    Set Initial Attenuation
    Require Ue    UE_1    capabilities=REAL_ANDROID_UE
    Detach Ue     UE_1


Stop Tcpdump On CU
    Stop Tcpdump On CU And Download Logs    filename=${test_name}_SCTP.pcap
    Move File   ${LOG_PATH}/${test_name}_SCTP.pcap   ${LOG_PATH}/${test_name}/${test_name}_SCTP.pcap
    Set Test Variable   ${pcap_path}   ${LOG_PATH}/${test_name}/${test_name}_SCTP.pcap


Perform Intra-gNB HO Until RRCReject
    Log To Console    Intra-gNB HO...
    Set Attenuation    GNB_1_CELL_1    0db
    Set Attenuation    GNB_1_CELL_2    20db
    FOR    ${i}  IN RANGE  0  90  2
        Set Attenuation  GNB_1_CELL_1  ${i}db
        ${fire_counter}=    Count Fires For Rrcreject    syslog_path=/tmp/btslog2/SYSLOG_1.LOG
        Log To Console   ${fire_counter}${fire_counter} > 5
        IF    ${fire_counter} > 5    BREAK
        Sleep    1s
    END
    Log To Console    HO procedure done...


Perform HO
    [Arguments]    ${source_cell}    ${target_cell}    ${att_source}    ${att_target}
    Log To Console    Starting HO from ${source_cell} to ${target_cell}
    Set Attenuation    ${source_cell}    ${att_source}db
    Set Attenuation    ${target_cell}    ${att_target}db
    FOR    ${i}  IN RANGE  0  30  2
        Set Attenuation  ${source_cell}  ${i}db
        Sleep    1s
    END
    Set Attenuation    ${source_cell}    90db
    Log To Console    HO procedure done...


Perform Interfreq Reselection
    [Arguments]    ${source_cell}    ${target_cell}    ${att_source}    ${att_target}
    Log To Console    Starting HO from ${source_cell} to ${target_cell}
    Set Attenuation    ${source_cell}    ${att_source}db
    Set Attenuation    ${target_cell}    ${att_target}db
    FOR    ${i}  IN RANGE  0  70  1
        Set Attenuation  ${source_cell}  ${i}db
        Sleep    1s
    END
    Set Attenuation    ${source_cell}    90db
    Log To Console    HO procedure done...


Perform Inter-Rat HO
    [Arguments]    ${source_cell}    ${target_cell}    ${att_source}    ${att_target}
    Log To Console    Starting Inter-RAT HO
    Set Attenuation    ${source_cell}    ${att_source}db
    Set Attenuation    ${target_cell}    ${att_target}db
    FOR    ${i}  IN RANGE  0  90  2
        Set Attenuation  ${source_cell}  ${i}db
        Sleep    1s
    END
    Log To Console    HO procedure done...


Verify PCAP Packets
    [Arguments]    ${testcase_name}    @{PCAP_MSG}
    Log To Console    \nChecking PCAP messages...
    Check PCAP Packets   ${LOG_PATH}/${test_name}/tcpdump/    ${testcase_name}    @{PCAP_MSG}
    Log To Console    \nChecking done. All packets appeared.


Check Counters
    [Arguments]    @{counters}    ${cell_id}=1    ${expected_value}=1    ${increment}=0
    Collect Counters
    ${updated_counter_values}    Get Last Counter Values    @{counters}
    Cleanup All Downloaded Counter Files
    ${results}=  Check If Counters Increased  ${updated_counter_values}  cell_id=${cell_id}  expected_value=${expected_value}  increment=${increment}


Check For Sleeping Cell Alarm
    taf_admin.Setup Admin      bts_host=${gNB_IP}    name=alarm
    Wait Until Keyword Succeeds    20x    30s    taf_admin.Assert Alarm Active  faultId=4548  connection=alarm
    taf_admin.Teardown Admin    connection=alarm


Start IP Capturing
    taf_admin.Setup Admin      bts_host=${gNB_IP}    name=ipcap
    taf_admin.start_ip_capture_file    measurement_point=NE_Terminated    uplane_capturing=true    connection=ipcap


Download And Generate PCAP
    taf_admin.stop_ip_capture_file    connection=ipcap
    taf_admin.generate_ip_capture_file    connection=ipcap
    taf_admin.download_ip_capture_file    target_file_name=${LOG_PATH}/${test_name}/8225.pcap    connection=ipcap
    taf_admin.Teardown Admin    connection=ipcap


Start TCP Dump on Both GNBs
    [Arguments]    ${step}
    Create TCPDump Collector    B_B1_EDA_${step}
    Create TCPDump Collector From Remote    B_B1_EDA_remote_${step}
    Start Collecting TCP Dump
    Start Collecting TCP Dump Remote


Convert Pcaps to Pdml
    Convert Pdml    ${LOG_PATH}/${TEST_NAME}/tcpdump/B_B1_EDA_Step_1
    Convert Pdml    ${LOG_PATH}/${TEST_NAME}/tcpdump/B_B1_EDA_Step_2
    Convert Pdml    ${LOG_PATH}/${TEST_NAME}/tcpdump/B_B1_EDA_Step_3
    Convert Pdml    ${LOG_PATH}/${TEST_NAME}/tcpdump_remote/B_B1_EDA_remote_Step_1
    Convert Pdml    ${LOG_PATH}/${TEST_NAME}/tcpdump_remote/B_B1_EDA_remote_Step_2
    Convert Pdml    ${LOG_PATH}/${TEST_NAME}/tcpdump_remote/B_B1_EDA_remote_Step_3


Check Pdmls
    Verify Callflow For Step 1    ${LOG_PATH}/${TEST_NAME}/tcpdump/B_B1_EDA_Step_1.pdml
    Verify Callflow For Step 1 Remote    ${LOG_PATH}/${TEST_NAME}/tcpdump_remote/B_B1_EDA_remote_Step_1.pdml
    Verify Callflow For Step 2    ${LOG_PATH}/${TEST_NAME}/tcpdump/B_B1_EDA_Step_2.pdml
    Verify Callflow For Step 2 Remote    ${LOG_PATH}/${TEST_NAME}/tcpdump_remote/B_B1_EDA_remote_Step_2.pdml
    Verify Callflow For Step 3    ${LOG_PATH}/${TEST_NAME}/tcpdump/B_B1_EDA_Step_3.pdml


Get SW Release And Trigger EDA Scenario
    taf_admin.Setup Admin      bts_host=${gNB_IP}    name=swrelease
    ${SW_RELEASE}=    taf_admin.Get Sw Release Name    connection=swrelease
    log to console   ${SW_RELEASE}
    taf_admin.Teardown Admin    connection=swrelease
    IF  "${SW_RELEASE}" not in ${RELEASES}
        Log To console    OK
        Start TCP Dump on Both GNBs    Step_1
        Perform HO    GNB_1_CELL_1    GNB_1_CELL_2    0    10
        Sleep    5s
        Log To Console    Starting Data Transfer...
        Start Data Transfer    dt_name=DT_1    ue_alias=UE_1    direction=dl    duration=40s    protocol=udp
        ...                    throughput=600Mbits/sec    packet_size=1400
        Sleep    10s
        Perform HO    GNB_1_CELL_2    GNB_2_CELL_1    0    0
        Await Data Transfer Finish    DT_1
        Sleep    40s
        Stop And Collect Tcp Dump    ${OUTPUT_DIR}/${TEST_NAME}/
        Stop And Collect Tcp Dump Remote    ${OUTPUT_DIR}/${TEST_NAME}/
        Start TCP Dump on Both GNBs    Step_2
        Perform HO    GNB_2_CELL_1    GNB_2_CELL_3    0    10
        Sleep    5s
        Log To Console    Starting Data Transfer...
        Start Data Transfer    dt_name=DT_2    ue_alias=UE_1    direction=ul    duration=40s    protocol=udp
        ...                    throughput=600Mbits/sec    packet_size=1400
        Sleep    10s
        Perform HO    GNB_2_CELL_3    GNB_1_CELL_1    0    0
        Await Data Transfer Finish    DT_2
        Sleep    40s
        Stop And Collect Tcp Dump    ${OUTPUT_DIR}/${TEST_NAME}/
        Stop And Collect Tcp Dump Remote    ${OUTPUT_DIR}/${TEST_NAME}/
        Start TCP Dump on Both GNBs    Step_3
        Perform Interfreq Reselection    GNB_1_CELL_1    GNB_1_CELL_4    0    0
        Sleep    5s
        Log To Console    Starting Data Transfer...
        Start Data Transfer    dt_name=DT_3    ue_alias=UE_1    direction=ul    duration=70s    protocol=udp
        ...                    throughput=600Mbits/sec    packet_size=1400
        Sleep    10s
        Perform Inter-Rat HO    GNB_1_CELL_4    GNB_2_CELL_1    0    0
        Await Data Transfer Finish    DT_3
        Stop And Collect Tcp Dump    ${OUTPUT_DIR}/${TEST_NAME}/
        Stop And Collect Tcp Dump Remote    ${OUTPUT_DIR}/${TEST_NAME}/
        Stop And Collect Syslog    ${OUTPUT_DIR}/${TEST_NAME}/
        Convert Pcaps to Pdml
        Check Pdmls
    END


A_B2_Feature_activation_RAN_non_Sharing
    Log To Console    \nStarting Test...
    Create Syslog Collector    BtsLog.tgz
    Create TCPDump Collector    A_B2
    Start Syslog
    Start Collecting TCP Dump
    ELT.Start Log Collecting
    Set Attenuation    ${CELL_1_ALIAS}    0dB
    Attach Ue    UE_1
    Sleep    45s
    Activate CB008225
    Sleep    10s
    ELT.Stop Log Collecting
    Stop And Collect Tcp Dump    ${OUTPUT_DIR}/${TEST_NAME}/
    Stop And Collect Syslog    ${OUTPUT_DIR}/${TEST_NAME}/
    ${elt_log}=  ELT.Download Log   ${LOG_PATH}/${TEST_NAME}/elt_log.json
    Check actRrcInactState Activation    ${LOG_PATH}/${TEST_NAME}/elt_log.json


B_B1_RRCRelease_with_SC_after_ICS
    Log To Console    \nStarting Test...
    Create Syslog Collector    BtsLog.tgz
    Create TCPDump Collector    B_B1
    Start Syslog
    Start Collecting TCP Dump
    Set Attenuation    ${CELL_1_ALIAS}    0dB
    Attach Ue    UE_1
    Sleep    40s
    Stop And Collect Tcp Dump    ${OUTPUT_DIR}/${TEST_NAME}/
    Verify PCAP Packets    B_B1    ${B_B1_1}    ${B_B1_2}    ${B_B1_3}
    Get SW Release And Trigger EDA Scenario


C_B1_B3_Successful_RAN_Paging_in_RRC_Inactive_State_DL_User_Plane_Data_from_UPF
    Log To Console    \nStarting Test...
    Create Syslog Collector    BtsLog.tgz
    Create TCPDump Collector    C_B1
    Start Syslog
    Start Collecting TCP Dump
    Set Attenuation    ${CELL_1_ALIAS}    10dB
    Attach Ue    UE_1
    Sleep    45s
    Start Data Transfer    dt_name=DT_1    ue_alias=UE_1    direction=dl    duration=10s    protocol=udp
    ...                    throughput=600Mbits/sec    packet_size=1400
    Await Data Transfer Finish    DT_1
    ELT.Start Log Collecting
    Sleep    45s
    Stop And Collect Tcp Dump    ${OUTPUT_DIR}/${TEST_NAME}/
    Stop And Collect Syslog    ${OUTPUT_DIR}/${TEST_NAME}/
    ELT.Stop Log Collecting
    ${elt_log}=  ELT.Download Log   ${LOG_PATH}/${TEST_NAME}/elt_log.json
    Convert Pdml    ${LOG_PATH}/${TEST_NAME}/tcpdump/C_B1
    Verify Callflow For C_B1    ${LOG_PATH}/${TEST_NAME}/tcpdump/C_B1.pdml


D_B1_RRC_Inactive_to_RRC_Connected_State_UL_User_Data
    Log To Console    \nStarting Test...
    Set Attenuation    ${CELL_1_ALIAS}    10dB
    Create Syslog Collector    BtsLog.tgz
    Create TCPDump Collector    D_B1
    Start Syslog
    Start Collecting TCP Dump
    Attach Ue    UE_1
    Sleep    45s
    Start Data Transfer    dt_name=DT_1    ue_alias=UE_1    direction=ul    duration=10s    protocol=udp
    ...                    throughput=200Mbits/sec    packet_size=1400
    Await Data Transfer Finish    DT_1
    ELT.Start Log Collecting
    Sleep    45s
    Stop And Collect Tcp Dump    ${OUTPUT_DIR}/${TEST_NAME}/
    Stop And Collect Syslog    ${OUTPUT_DIR}/${TEST_NAME}/
    ELT.Stop Log Collecting
    ${elt_log}=  ELT.Download Log   ${LOG_PATH}/${TEST_NAME}/elt_log.json
    Convert Pdml    ${LOG_PATH}/${TEST_NAME}/tcpdump/D_B1
    Verify Callflow For D_B1    ${LOG_PATH}/${TEST_NAME}/tcpdump/D_B1.pdml


H_B1_PMO29_RRCRelease_with_CA_aware_cellReselectionPriorities_via_drbRrcInactInactivityTimerSA
    Log To Console    \nStarting Test...
    @{counters}=       Create List                    M55124C00006
    Wait Until Keyword Succeeds  6x  60s              Check Counters  @{counters}  cell_id=2  expected_value=0
    Create Syslog Collector    BtsLog.tgz
    Create TCPDump Collector    H_B1
    Start Syslog
    Start Collecting TCP Dump
    ELT.Start Log Collecting
    Set Attenuation    ${CELL_2_ALIAS}    0dB
    Attach Ue    UE_1
    Sleep    45s
    ELT.Stop Log Collecting
    ${elt_log}=  ELT.Download Log   ${LOG_PATH}/${test_name}/elt_log.json
    Stop And Collect Tcp Dump    ${OUTPUT_DIR}/${TEST_NAME}/
    Stop And Collect Syslog    ${OUTPUT_DIR}/${TEST_NAME}/
    Verify PCAP Packets    H_B1    ${H_1}
    Wait Until Keyword Succeeds  6x  60s              Check Counters  @{counters}  cell_id=2


L_PMO6_Sleeping_Cell_Detection_by_RRCResumeRequestReject
    Log To Console    \nStarting Test...
    @{counters}=       Create List                    M55124C01011    M55166C00507    M55166C00510
    Wait Until Keyword Succeeds  6x  60s              Check Counters  @{counters}  cell_id=2  expected_value=0
    Create Syslog Collector    BtsLog.tgz
    Create TCPDump Collector    L_PMO6
    Start Syslog
    Start Collecting TCP Dump
    Set Attenuation    ${CELL_1_ALIAS}    0dB
    Attach Ue    UE_1
    Sleep    45s
    Set maxNumOfRrcConUEsPerDU    maxnumperdu=0
    Perform Intra-gNB HO Until RRCReject
    Check For Sleeping Cell Alarm
    Wait Until Keyword Succeeds  6x  60s              Check Counters  @{counters}  cell_id=2  increment=1
    Stop And Collect Tcp Dump    ${OUTPUT_DIR}/${TEST_NAME}/
    Stop And Collect Syslog    ${OUTPUT_DIR}/${TEST_NAME}/
    Verify Sleeping Cell By Rrcresumerequestreject Pcap


E_B3_PMO23_Successful_transition_of_suspended_UE_in_RRC_INACTIVE_state_to_RRC_CONNECTED_with_A1_meas_CA
    Log To Console    \nStarting Test...
    @{counters}=       Create List                    M55124C00007    M55124C00010
    Wait Until Keyword Succeeds  6x  60s              Check Counters  @{counters}  cell_id=2  expected_value=0
    Create Syslog Collector    BtsLog.tgz
    Create TCPDump Collector    E_B3
    Start Syslog
    Start Collecting TCP Dump
    Set Attenuation    ${CELL_2_ALIAS}    0dB
    Attach Ue    UE_1
    Sleep    45s
    Log To Console    \nStarting Data Transfer...
    Start Data Transfer    dt_name=DT_1    ue_alias=UE_1    direction=ul    duration=10s    protocol=udp
    ...                    throughput=200Mbits/sec    packet_size=1400
    Await Data Transfer Finish    DT_1
    Log To Console    \nData Transfer Stopped
    Stop And Collect Tcp Dump    ${OUTPUT_DIR}/${TEST_NAME}/
    Stop And Collect Syslog    ${OUTPUT_DIR}/${TEST_NAME}/
    Wait Until Keyword Succeeds  6x  60s              Check Counters  @{counters}  cell_id=2
    Convert Pdml    ${LOG_PATH}/${test_name}/tcpdump/E_B3
    Verify Callflow For E_B3    ${LOG_PATH}/${test_name}/tcpdump/E_B3.pdml


I_B5_Fallback_to_RRCSetup_by_resumeCause=emergency_using_numOfRadioResReservForEmergency_resources
    Log To Console    \nStarting Test...
    Create Syslog Collector    BtsLog.tgz
    Create TCPDump Collector    I_B5
    Start Syslog
    Start Collecting TCP Dump
    Set Attenuation    ${CELL_1_ALIAS}    0dB
    Attach Ue    UE_1
    Sleep    45s
    Set maxNumOfRrcSA
    Start Voice Call    VC    UE_1    911    5s
    Await Voice Call Finish    VC
    Stop And Collect Tcp Dump    ${OUTPUT_DIR}/${TEST_NAME}/
    Stop And Collect Syslog    ${OUTPUT_DIR}/${TEST_NAME}/
    Set maxNumOfRrcSA    275
    Convert Pdml    ${LOG_PATH}/${test_name}/tcpdump/I_B5
    Verify Callflow For I_B5    ${LOG_PATH}/${test_name}/tcpdump/I_B5.pdml


J_B05_PCMD_and_Cell_trace_records_during_RNA_update_in_same_gNB
    Log To Console    \nStarting Test...
    Create Syslog Collector    BtsLog.tgz
    Create TCPDump Collector    J_B5
    Start Syslog
    Start Collecting TCP Dump
    Start IP Capturing
    Set Attenuation    ${CELL_2_ALIAS}    0dB
    Attach Ue    UE_1
    Sleep    340s
    Download And Generate PCAP
    Stop And Collect Tcp Dump    ${OUTPUT_DIR}/${TEST_NAME}/
    Stop And Collect Syslog    ${OUTPUT_DIR}/${TEST_NAME}/
    Convert Pdml    ${LOG_PATH}/${test_name}/8225.pcap
    Verify PDML    ${LOG_PATH}/${test_name}/8225.pdml
    Verify J_B05 PCAP
