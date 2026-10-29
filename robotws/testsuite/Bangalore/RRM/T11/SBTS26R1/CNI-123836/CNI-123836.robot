*** Settings ***
Documentation    :copyright: Nokia
Force Tags   CRT    CLOUD_R4LAPO_CUS    SBTS00
Library         ta_uexgate
Library         taf.ul.ue.sim.env_setup
Library		    taf.sbts.oam.coam.admin
Library         ta_messaging
Library         taf.sw.wtssim
Library         taf.sw.syslog
Library         taf.collectors.tshark    WITH NAME    tshark
Library         taf.collectors.core    WITH NAME    core
Resource        ../../../../resources/robot/configuration_id.robot
Library         Collections

Suite Setup    Configure Env

*** Variables ***
${ue_eutra_capabilities}    56000000C000001000804510021200055C041900

*** Test Cases ***
[1]CNI-123836_TC3_WB_CATm_NB_Iot_Ues_Coexist_perform_UL_DL_traffic
    Set Catm UE capabilities
    run keyword and continue on failure    Link SCOUT SCF to Configuration ID for Reporting

    Attach legacy UEs and start traffic
    Attach Catm UEs and start traffic
    Attach NB-IoT UEs and start traffic
    Start syslog_RROM_CellTearDownReq
#    Start wireshark
    Start observing for rrcconnection message
    Reset RMOD to trigger RROM_CellTearDownReq
    Verify if All the UEs have been Released
#    Verify if UEs are released via tshark
    Verify if RROM_CellTearDownReq is seen in syslog_RROM_CellTearDownReq
    Check for S1AP partial reset in syslog_RROM_CellTearDownReq
    Attaching UEs after RMod reset is done
    [Teardown]    Custom Teardown

*** Keywords ***
Set Catm UE capabilities
    Log to console  Set Catm UEs capabilities
    Run UEx command  ue_param  id=31   ue_eutra_capabilities=${ue_eutra_capabilities}
    Run UEx command  ue_param  id=131  ue_eutra_capabilities=${ue_eutra_capabilities}
    Run UEx command  ue_param  id=32   ue_eutra_capabilities=${ue_eutra_capabilities}
    Run UEx command  ue_param  id=132  ue_eutra_capabilities=${ue_eutra_capabilities}

Attach UE${ue_id} to CELL${cell_id:\d+}
    Log To Console   ${\n}Attach UE${ue_id} to CELL${cell_id}
    Run UEx command  ue_attach  id=${ue_id}  cell=${cell_id}

Start ${protocol} traffic containing ${ul_tput} ${ul_unit} UL and ${dl_tput} ${dl_unit} DL on UE${ue_id}
    Log to console  Start ${protocol} traffic containing ${ul_tput} ${ul_unit} UL on UE${ue_id}
    Run UEx command  trf_data_start  ue=${ue_id}  dir=ul  protocol=${protocol}  ${ul_unit}=${ul_tput}   stats=true  duration=900    size=3000
    Sleep   1
    Log to console  Start ${protocol} traffic containing ${dl_tput} ${dl_unit} DL on UE${ue_id}
    Run UEx command  trf_data_start  ue=${ue_id}  dir=dl  protocol=${protocol}  ${dl_unit}=${dl_tput}   stats=true  duration=900    size=3000

Attach legacy UEs and start traffic
    Attach UE1 to CELL1
	sleep			1s
	Start udp traffic containing 15 Mbps UL and 30 Mbps DL on UE1

    Attach UE101 to CELL2
	sleep			1s
	start udp traffic containing 40 Mbps UL and 60 Mbps DL on UE101

Attach Catm UEs and start traffic
    Attach UE31 to CELL1
	sleep			1s
	Start udp traffic containing 100 kbps UL and 100 kbps DL on UE31

    Attach UE131 to CELL2
	sleep			1s
	Start udp traffic containing 100 kbps UL and 100 kbps DL on UE131

Attach NB-IoT UEs and start traffic
    Attach UE51 to CELL11
	sleep			1s
	Start udp traffic containing 10 kbps UL and 10 kbps DL on UE51

    Attach UE151 to CELL21
	sleep			1s
	Start udp traffic containing 10 kbps UL and 10 kbps DL on UE151

Attaching UEs after RMod reset is done
    Attach UE2 to CELL1
	sleep			1s
	Start udp traffic containing 15 Mbps UL and 30 Mbps DL on UE2

    Attach UE102 to CELL2
	sleep			1s
	start udp traffic containing 40 Mbps UL and 60 Mbps DL on UE102

	Attach UE32 to CELL1
	sleep			1s
	Start udp traffic containing 100 kbps UL and 100 kbps DL on UE32

    Attach UE132 to CELL2
	sleep			1s
	Start udp traffic containing 100 kbps UL and 100 kbps DL on UE132

	Attach UE52 to CELL11
	sleep			1s
	Start udp traffic containing 10 kbps UL and 10 kbps DL on UE52

    Attach UE152 to CELL21
	sleep			1s
	Start udp traffic containing 10 kbps UL and 10 kbps DL on UE152

Reset RMOD to trigger RROM_CellTearDownReq
    Log To Console   Resetting RMOD
    taf.sbts.oam.coam.admin.Setup Admin
    Run keyword and continue on failure    taf.sbts.oam.coam.admin.reset unit    dist_name=MRBTS-1/EQM-1/APEQM-1/RMOD-1
    Run keyword and continue on failure    taf.sbts.oam.coam.admin.reset unit    dist_name=MRBTS-1/EQM-1/APEQM-1/RMOD-2
    taf.sbts.oam.coam.admin.Teardown admin


Start observing for rrcconnection message
    sleep    10s
    Log To Console  Start observing for rrcconnectionreconfiguration adn rrcconnectionsetup complete messages
    Expect Message Flow
    ...                 UE_1:RRC_RRCConnectionReconfigurationComplete
    ...                 UE_31:RRC_RRCConnectionReconfigurationComplete
    ...                 UE_51:RRC_RRCConnectionSetupComplete-NB
    ...                 UE_101:RRC_RRCConnectionReconfigurationComplete
    ...                 UE_131:RRC_RRCConnectionReconfigurationComplete
    ...                 UE_151:RRC_RRCConnectionSetupComplete-NB
    ...                 MME_1:S1AP_Reset (initiatingMessage contains (value contains (Reset contains (Cause contains (misc eq "om-intervention")))))
    ...                 MME_1:S1AP_ResetAcknowledge (successfulOutcome contains ( value contains (ResetAcknowledge is present)))
    ...                 MME_1:S1AP_Reset (initiatingMessage contains (value contains (Reset contains (Cause contains (misc eq "om-intervention")))))
    ...                 MME_1:S1AP_ResetAcknowledge (successfulOutcome contains ( value contains (ResetAcknowledge is present)))
    ...                 MME_1:S1AP_Reset (initiatingMessage contains (value contains (Reset contains (Cause contains (misc eq "om-intervention")))))
    ...                 MME_1:S1AP_ResetAcknowledge (successfulOutcome contains ( value contains (ResetAcknowledge is present)))
    ...                 MME_1:S1AP_Reset (initiatingMessage contains (value contains (Reset contains (Cause contains (misc eq "om-intervention")))))
    ...                 MME_1:S1AP_ResetAcknowledge (successfulOutcome contains ( value contains (ResetAcknowledge is present)))
    ...                 alias=UE_Release    overall_timeout=300

Verify if All the UEs have been Released
    Log To Console  Verify if All the UEs have been Released
    sleep    30s
    Flow occurred as expected   alias=UE_Release

#Start wireshark
#    start_tshark   log_filename=CNI123836_S1_partial_reset.pcap    eth_interface=eth3   capture_filter=less 1000   alias=Partial_reset
#
#Stop wireshark
#    stop_tshark    alias=Partial_reset
#
#Verify if UEs are released via tshark
#    Log To Console  Verify if UEs are released via tshark
#    Verify_tshark_for_at_least_given_number_of_messages    packet_filter=s1ap.Reset [Misc-cause=om-intervention]
#    ...    number_of_messages=4    alias=Partial_reset
#    Stop wireshark


Start syslog_${id}
	[Documentation]	Start Syslog keyword
    Start syslog  log_dir=/tmp    log_name=${id}    alias=${id}  ip=192.168.255.126    ports=51000   add_line_number=True

Verify if RROM_CellTearDownReq is seen in syslog_${id}
    ${regexp1}=    Set Variable    .*Sending RROM_CellTearDownResp with result: status=0; cause=0; specificCause=0; for lcrId=1.*
    Run Keyword And Continue On Failure     Message should exist in syslog file   regexp=${regexp1}     alias=${id}
    ${regexp2}=    Set Variable    .*Sending RROM_CellTearDownResp with result: status=0; cause=0; specificCause=0; for lcrId=2.*
    Run Keyword And Continue On Failure     Message should exist in syslog file   regexp=${regexp2}     alias=${id}

Check for S1AP partial reset in syslog_${id}

    ${regexp1}=    Set Variable    .*Starting S1 Partial reset, transactionId: .*
    ${count_1}=    Run Keyword And Continue On Failure     count_syslog_messages   regexp=${regexp1}     alias=${id}
    Should be true    ${count_1}==4
    ${regexp2}=    Set Variable    .*Finished: 0x4750, fsm: S1ApFsm, state: PERFORMING_PARTIAL_RESET.*
    ${count_2}=    Run Keyword And Continue On Failure     count_syslog_messages   regexp=${regexp2}     alias=${id}
    Should be true    ${count_2}==4

Custom Teardown
    Run UEx command    ue_detach    all
    Collect Syslog Results    destination=${OUTPUT_DIR}${/}RROM_CellTearDownReq.log    unzip=True    alias=RROM_CellTearDownReq

Create Alias
    Create UE Alias     UE_1           ue_id=1      id_type=cus
    Create UE Alias     UE_31          ue_id=31     id_type=cus
    Create UE Alias     UE_51          ue_id=51     id_type=cus
    Create UE Alias     UE_101         ue_id=101    id_type=cus
    Create UE Alias     UE_131         ue_id=131    id_type=cus
    Create UE Alias     UE_151         ue_id=151    id_type=cus
    Create MME Alias    alias=MME_1    mme_id=1     id_type=wts

Configure Env
    Add Simulator   sim_type=cus    config=${CURDIR}/config/CNI123836_TC3_coco.yaml
    Add Enb Configuration           scfc=${CURDIR}/config/CNI123836_TC3_scf.xml
    Configure_environment
    setup egate  20000

    Create Alias

