*** Settings ***
Force Tags    CLOUD_R4MAQN_CUS    CRT   SBTS00

Documentation    :copyright       : Nokia
                 ...              :author       : Akanksha Raina
                 ...              :contact      : akanksha.raina@nokia.com
                 ...              :Description  : The scope of this document is to verify the RAC behaviour for NB IoT GB in NR cell.
                 ...                              NB IoT GB in NR cell inherit the RAC algotithms from NB IoT SA.

Library     OperatingSystem
Library     ta_uexgate
Library     Collections
Library     taf.ul.ue.sim.env_setup
Library     ta_messaging
Library		taf.sw.syslog
#Library     ute_wtssim
Library		taf.sbts.oam.coam.admin
Library     ta5g_tshark
#Library     ute_tshark
Library     ta_emss
Library     BuiltIn
Library     String
Library     SSHLibrary
#Library     ute_admin_infomodel
Resource     ../../../../resources/robot/configuration_id.robot


Suite Setup           Setup testline
Test Setup            Start Default Logging For CUS
Suite Teardown        Stop Default Logging For CUS And Compress Test Logs

*** Variables ***

${scfc}=        SCF_AHPMDD.xml
${lua}=        ${CURDIR}/config/epc.lua
${cus_ini}=    ${CURDIR}/config/cus_AHPMDD.ini



*** Test Cases ***
CB008925-SR-A-B2_FDD_15Mhz_ABIQ_CPRI_ET_RAC_Cell_level_for_NB_IOT_Ues_in_guardband NB-IoT_cell_hosted_by_NR_Cell
#    Start wireshark
    Attach NBIOT UE1..2 to CELL11
    Start udp traffic containing 10 kbps DL and 10 kbps UL on UE1..2
    Verify if desired 5kbps dl traffic 1 on UE1 reaches 90%
    Verify if desired 5kbps ul traffic 1 on UE1 reaches 90%
    Verify if desired 5kbps dl traffic 1 on UE2 reaches 90%
    Verify if desired 5kbps ul traffic 1 on UE2 reaches 90%
    Attach UE3 to Cell11 Expecting Connection Rejection With The Wait Time Equal To Extendedwaittime-R13 Ie
    Run keyword and continue on failure    Link SCOUT SCF to Configuration ID for Reporting
    Detach UEs
#    Stop wireshark
     [Teardown]     Run Keywords    syslog crash verification


*** Keywords ***

Setup testline
     Add Simulator   sim_type=cus    config=${cus_ini}
     Add Enb Configuration           scfc=${scfc}
     Add Epc                         config=${lua}
     Configure environment
     #setup egate   20000
     Create Alias

Create Alias
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create UE Alias    UE_3    ue_id=3    id_type=cus
    Create Enb Alias   ENB_1   enb_id=1   id_type=wts
#    Create Enb Alias    GNB_7    enb_id=7    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts

Start wireshark
    start_tshark   log_filename=CB008925.pcap    eth_interface=any   capture_filter=less 1000   alias=resource_check

Stop wireshark
    stop_tshark    alias=resource_check




Start Default Logging For CUS
	[Documentation]	Start Syslog keyword
	[Arguments]     ${output_dir}=${OUTPUT_DIR}
	taf.sw.syslog.Start Syslog	log_dir=${output_dir}/enb	log_name=default_syslog_enb	ip=192.168.255.126	alias=default_enb

Stop Default Logging For CUS And Compress Test Logs
	[Documentation]	Keyword to get active alarms and faults on SBTS and to stop Syslogs on SBTS
	taf.sbts.oam.coam.admin.connect_to
	get_active_alarms
	get_default_fault_list
	taf.sw.syslog.Stop Syslog	alias=default_enb

Attach NBIOT UE${ue_id} to CELL${cell_id:\d+}
    Log To Console   ${\n}Attach UE${ue_id} to CELL${cell_id}
    Run UEx command  ue_param  id=${ue_id}   type=nb    release=13    category=1         supported_bands=28
    Run UEx command  ue_attach  id=${ue_id}  cell=${cell_id}

Start ${protocol} traffic containing ${dl_tput} ${dl_unit} DL and ${ul_tput} ${ul_unit} UL on UE${ue_id}
    Log to console  Start ${protocol} traffic containing ${dl_tput} ${dl_unit} DL and ${ul_tput} ${ul_unit} UL on UE${ue_id}
    Run UEx command  trf_data_start  ue=${ue_id}  dir=dl_and_ul  protocol=${protocol}  ${dl_unit}_dl=${dl_tput}  ${ul_unit}_ul=${ul_tput} stats=true



Detach UEs
    Run UEx command    ue_detach all


Attach UE${ue_id} to Cell${cell_id} Expecting Connection Rejection With The Wait Time Equal To Extendedwaittime-R13 Ie
#    [Arguments]    ${ue_id}    ${cell}

    Expect message flow
       ...    UE_${ue_id}:RRC_RRCConnectionReject-NB
       ...    alias=NBIoTConenctionRejected    overall_timeout=300

    Run UEx command  ue_param  id=${ue_id}   type=nb    release=13    category=1         supported_bands=28
    Run Keyword And Ignore Error  ue_attach  id=${ue_id}  cell=${cell_id}
    Flow Occurred As Expected    alias=NBIoTConenctionRejected



Calculate kbps average tput for UE
    [Arguments]  ${trf_id}  ${ue_id}  ${dir}  ${exp_tput}
    ${trf_stats}=  Run UEx command  get_trf_data_stats  trf_id=${trf_id}  ue=${ue_id}  unit=kbps
    ${tputs_ue}=  Get From Dictionary  ${trf_stats}  ${dir}
    ${tput_avg}=  Get From Dictionary  ${tputs_ue}  avg
    ${tput_success_rate}=  Evaluate  ${tput_avg}/${exp_tput} * 100
    Log To Console  Achieved AVG UE${ue_id} ${dir} tput: ${tput_avg}kbps (${tput_success_rate}%) / Expected: ${exp_tput}kbps
    [Return]  ${tput_success_rate}

Verify if desired ${exp_tput}kbps ${dir:(ul|dl|UL|DL)} traffic ${trf_id} on UE${ue_id:\d+} reaches ${min_success_rate}%
    Log To Console  Verify if desired ${exp_tput}kbps ${dir} traffic ${trf_id} on UE${ue_id} reaches ${min_success_rate}%
    Sleep  10s
    ${tput_success_rate}=  Calculate kbps average tput for UE  trf_id=${trf_id}  ue_id=${ue_id}  dir=${dir}  exp_tput=${exp_tput}
    Should Be True  ${tput_success_rate} >= ${min_success_rate}

syslog crash verification

#K2 DSP crash
    ${1}=    taf.sw.syslog.count_syslog_messages      regexp=faultID: 6706      alias=default_enb
    ${2}=    taf.sw.syslog.count_syslog_messages      regexp=faultId: 6707      alias=default_enb
    ${3}=    taf.sw.syslog.count_syslog_messages      regexp=faultID: 6709      alias=default_enb

#K2 ARM Application crash
    ${4}=    taf.sw.syslog.count_syslog_messages      regexp=faultID: 6708      alias=default_enb
	${5}=    taf.sw.syslog.count_syslog_messages      regexp=faultId: 4019      alias=default_enb
	${6}=    taf.sw.syslog.count_syslog_messages      regexp=FR_FaultProcessor::triggerLogConnectionIfNeeded      alias=default_enb
#AXM ARM crash
	${7}=    taf.sw.syslog.count_syslog_messages      regexp=faultID: 6450      alias=default_enb
	${8}=    taf.sw.syslog.count_syslog_messages      regexp=FR_FaultProcessor::triggerLogConnectionIfNeeded      alias=default_enb
	${9}=    taf.sw.syslog.count_syslog_messages      regexp=BTSOM_COLLECT_DSP_CRASH_LOGS      alias=default_enb
    ${10}=    taf.sw.syslog.count_syslog_messages      regexp=EAaErrorFatality_Fatal      alias=default_enb

	Should be True     ${1} == 0
	Should be True     ${2} == 0
	Should be True     ${3} == 0
	Should be True     ${4} == 0
	Should be True     ${5} == 0
	Should be True     ${6} == 0
	Should be True     ${7} == 0
	Should be True     ${8} == 0
	Should be True     ${9} == 0
	Should be True     ${10} == 0
