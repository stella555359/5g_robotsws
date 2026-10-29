*** Settings ***
Documentation
...    copyright: Nokia
...    maintainer: Wojciech Szczesniak (wojciech.szczesniak@nokia.com)
...    testline: CLOUD_5G_I_MP_AP_LO
...    variant: SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC

Force Tags    CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    SBTS00    SBTS23R1    RAN_5G    RAN_5G_FDD

Resource     ../resources/5G_SW_WRO_Keywords.robot
Library      ../resources/Python/webem_alarms.py
Resource     ../CB008249/CB008249_keywords.robot
Library    OperatingSystem
Library    taf.transport.ssh  WITH NAME  ssh
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library      CB008249_keywords.py
Library      ta5g_tshark
Library    taf.collectors.l1l2bip    WITH NAME    l1l2bip
Library    taf.collectors.core    WITH NAME    core
Resource     testsuite/Wroclaw/RRM/resources/logs.robot
Resource     ../resources/configuration_id.robot

Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/iphy_AEQE_8249_C.xml
    ...        AND             Start Default Logging
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=full_cb008247_C_1208_SRS.xml
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/basic_setup_8249-C_SA_SRS.cfg

*** Variables ***
${input_file1_1208}=             ${OUTPUT_DIR}/BIP_L1L2_1.pcap
${input_file2_1208}=             ${OUTPUT_DIR}/BIP_L1L2_2.pcap
${input_file3_1208}=             ${OUTPUT_DIR}/BIP_L1L2_3.pcap

${filter_1208}=                  uldata_srsreceivereq

${dir_path1_1208}=               ${OUTPUT_DIR}/BIP_log_1.pdml
${dir_path2_1208}=               ${OUTPUT_DIR}/BIP_log_2.pdml
${dir_path3_1208}=               ${OUTPUT_DIR}/BIP_log_3.pdml

${bip_file1_1208}=               BIP_L1L2_1.pcap
${bip_file2_1208}=               BIP_L1L2_2.pcap
${bip_file3_1208}=               BIP_L1L2_3.pcap
${alias}=                        L1L2_BIP_Logs
${dir_path}=                     ${OUTPUT_DIR}
${delay}=                        0

${SMOD}    ASIB
${GNB_IP}    192.168.255.129
${NOKIA_USERNAME}    toor4nsn
${NOKIA_PASS}    oZPS0POrRieRtu
${NOISE_POWER_FOR_RI}=     SEPARATOR=
...                        -63,-65,-67,-69,-71,-73,-75,-79,-81,-83,-85,-87,-89,-93,-95,-98,-101,-104,
...                        -105,-99,-95,-90,-85,-80,-75,-71,-67,-64,-60,-55,-50,-47

${RRC_POWER_RAMPING_STEP}=   ${SIB1} && nr-rrc.powerRampingStep == 1
${RRC_POWER_RAMPING_STEP_AFTER_RI}=  ${SIB1} && nr-rrc.powerRampingStep == 2

*** Test Cases ***
CB008249-C_C1_Remote_interference_mitigation_actions_eCPRI_5GC001208_GP2_SA
    Set Internal Traffic Type To UE
    Set SRS Beam Config
    Attach SA UE And Verify msg2TPC     ue_id=1      msg2TPC_value=3
    Verify PowerRampingStep Configuration       filter=${RRC_POWER_RAMPING_STEP}
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Attach SA UE And Verify msg2TPC     ue_id=4      msg2TPC_value=3
    Establish Pdu Session    ue_id=4    pdu_id=4    gw_id=1
    Airphone override to rank2
    Start Double Data Traffic In DL And Single In UL   ue_id=1    pdu=1   tput_dl=150   tput_ul=50
    Start Double Data Traffic In DL And Single In UL   ue_id=4    pdu=4   tput_dl=150   tput_ul=10
    Verify Tput For UE    ue_id=1   dir=ul    expected_tput=30
    Verify Tput For UE    ue_id=1   dir=dl    expected_tput=280
    Verify Tput For UE    ue_id=4   dir=ul    expected_tput=9
    Verify Tput For UE    ue_id=4   dir=dl    expected_tput=280
    Collect TTI Traces And Check DL MU-MIMO And DL SRS-based BF   duration=6   directory_name=CB008249_1    ini_path=tti_dl_features_enabled.ini
    Start Gathering BIP Logs And Wait 5s
    Stop gnbMirroring And Gather L1L2 Bip Logs    ${alias}    ${dir_path}    ${delay}    ${bip_file1_1208}
    Convert pcap file to pdml    ${input_file1_1208}    ${filter_1208}    ${dir_path1_1208}
    Check If UL SRS-based BF Is Enabled     file=BIP_log_1.pdml
    Sleep    10s
    Verify If Admin Fault Is Down     fault_id=7525
    Generate RI
    Wait For Fault To Be Up     fault_id=7525   timeout=800
    Collect TTI Traces And Check DL MU-MIMO And DL SRS-based BF   duration=6   directory_name=CB008249_2    ini_path=tti_dl_features_disabled.ini
    Start Gathering BIP Logs And Wait 5s
    Stop gnbMirroring And Gather L1L2 Bip Logs    ${alias}    ${dir_path}    ${delay}    ${bip_file2_1208}
    Convert pcap file to pdml    ${input_file2_1208}    ${filter_1208}    ${dir_path2_1208}
    Check If UL SRS-based BF Is Disabled     file=BIP_log_2.pdml
    Attach SA UE And Verify msg2TPC     ue_id=2      msg2TPC_value=5
    Verify PowerRampingStep Configuration       filter=${RRC_POWER_RAMPING_STEP_AFTER_RI}
    Cancel RI
    Wait For Fault To Be Down     fault_id=7525   timeout=600
    Collect TTI Traces And Check DL MU-MIMO And DL SRS-based BF   duration=6   directory_name=CB008249_3    ini_path=tti_dl_features_enabled.ini
    Start Gathering BIP Logs And Wait 5s
    Stop gnbMirroring And Gather L1L2 Bip Logs    ${alias}    ${dir_path}    ${delay}    ${bip_file3_1208}
    Convert pcap file to pdml    ${input_file3_1208}    ${filter_1208}    ${dir_path3_1208}
    Check If UL SRS-based BF Is Enabled     file=BIP_log_3.pdml
    Attach SA UE And Verify msg2TPC     ue_id=3      msg2TPC_value=3
    Verify PowerRampingStep Configuration       filter=${RRC_POWER_RAMPING_STEP}
    [Teardown]    Run Keywords    Stop All Data Transfers And Detach UE SA
    ...    AND    Send Configuration ID To Scout

*** Keywords ***
Set SRS Beam Config
    Execute Egate Command   cmd=ue_srs_beam_pos_nr profile_id=1 init_pos=0 srsMode=fixed
    Execute Egate Command   cmd=ue_testmode_set_nr id=1 testmode=ue_srs_beam_pos action=activate profile_id=1
    Execute Egate Command   cmd=ue_srs_beam_pos_nr profile_id=2 init_pos=2 srsMode=fixed
    Execute Egate Command   cmd=ue_testmode_set_nr id=4 testmode=ue_srs_beam_pos action=activate profile_id=2

Verify PowerRampingStep Configuration
    [Arguments]   ${filter}
    Verify Uu Messages    packet_filter=${filter}

Attach SA UE And Verify msg2TPC
    [Arguments]   ${ue_id}      ${msg2TPC_value}
    Execute Egate Command    cmd=ue_register id=${ue_id}
    ...    pass_regexp=msg2TPC: ${msg2TPC_value}

Set Internal Traffic Type To UE
    Execute Egate Command   cmd=set_pdu_param ue=1 pdu=1 trf_type=internal
    Execute Egate Command   cmd=set_pdu_param ue=2 pdu=2 trf_type=internal
    Execute Egate Command   cmd=set_pdu_param ue=3 pdu=3 trf_type=internal
    Execute Egate Command   cmd=set_pdu_param ue=4 pdu=4 trf_type=internal

Start Double Data Traffic In DL And Single In UL
    [Arguments]   ${ue_id}    ${pdu}    ${tput_ul}    ${tput_dl}
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} dir=dl mbps=${tput_dl} trf_id=1
    ...    pass_regexp=UE${ue_id}: Started Downlink Internal traffic Receiver on Ue:${ue_id} Pdu:${pdu} Qfi:1 TrfId:1
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} dir=dl mbps=${tput_dl} trf_id=2
    ...    pass_regexp=UE${ue_id}: Started Downlink Internal traffic Receiver on Ue:${ue_id} Pdu:${pdu} Qfi:1 TrfId:2
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} dir=ul mbps=${tput_ul}
    ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue:${ue_id} UpfId:1 Pdu:${pdu} Qfi:1 TrfId:1
    Sleep    60s

Generate RI
    Execute Egate Command
    ...    cmd=remote_interference_testmode_nr profile_id=12 start_symbol_position=0 num_of_symbols=32 noise_power_values=${NOISE_POWER_FOR_RI}
    Sleep   5s
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr testmode=remote_interference gnb=2 cell_id=1 profile_id=12 action=activate

Cancel RI
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr testmode=remote_interference gnb=2 cell_id=1 profile_id=12 action=deactivate

Verify Tput For UE
    [Arguments]   ${ue_id}    ${dir}    ${expected_tput}
    ${avg_tput}=    Get Avg Data Traffic For Given Cc    ue_id=${ue_id}   cc=0   direction=${dir}    unit=Mbps
    Should Be True    ${avg_tput} > ${expected_tput}


Stop All Data Transfers And Detach UE SA
    Execute Egate Command    cmd=trf_data_stop ue=1 pdu=1
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=1 ue_deregister_type=switch_off
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=2 ue_deregister_type=switch_off
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=3 ue_deregister_type=switch_off
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=4 ue_deregister_type=switch_off

Verify Uu Messages
    [Documentation]  Verification of messages captured on UU interface (between GnB and UE, WTS eth4).
    ...              By default keyword validates exact one occurrence of message.
    [Arguments]     ${packet_filter}    ${alias}=${DEFAULT_UU_TSHARK_ALIAS}
    Sleep   5s
    Verify Tshark For At Least Given Number Of Messages
    ...    alias=${alias}   packet_filter=${packet_filter}    number_of_messages=1

Airphone override to rank2
    Execute Egate Command    cmd=csi_override_testmode_nr profile_id=1 cqi=15 ri=1
    Execute Egate Command    cmd=ue_testmode_set_nr id=1 testmode=csi_override action=activate profile_id=1
    Execute Egate Command    cmd=ue_testmode_set_nr id=4 testmode=csi_override action=activate profile_id=1

Capture BIP Logs
    [Arguments]   ${file}=BIP_L1L2.pcap     ${pdml}=${OUTPUT_DIR}/BIP_log.pdml
    Start gnbMirroring L2L1
    Sleep   5s
    Stop gnbMirroring And Gather L1L2 Bip Logs      filename=${file}
    Convert pcap file to pdml       input_file=${OUTPUT_DIR}/${file}     output_pdml=${pdml}

Check If UL SRS-based BF Is Enabled
    [Arguments]   ${file}=BIP_L1L2.pcap
    verify_if_SRS_is_enabled    pdml_path=${OUTPUT_DIR}/${file}

Check If UL SRS-based BF Is Disabled
    [Arguments]   ${file}=BIP_L1L2.pcap
    verify_if_SRS_is_disabled    pdml_path=${OUTPUT_DIR}/${file}

Start Gathering BIP Logs And Wait 5s
    [Arguments]    ${target_file_name}=tcpdump
     ${webservice}=  Create Dictionary
     ...  host=192.168.255.129
     ...  user=Nemuadmin
     ...  password=nemuuser
     ...  port=443

     create_interface_mirroring_l1l2bip_collector
     ...  name=tcpdump
     ...  webservice=${webservice}
     ...  target_file_name=tcpdump
     ...  timeout=1300
     ...  remove_zip_file=False
     core.setup_collectors    names=tcpdump
     core.start_collectors    names=tcpdump
     core.Set Suite Alias     ${target_file_name}
     Sleep    5

Stop gnbMirroring And Gather L1L2 Bip Logs
     [Arguments]
     ...     ${alias}
     ...     ${dir_path}
     ...     ${delay}
     ...     ${bip_file}
     Sleep  ${delay}
     Create directory  path=${dir_path}/${alias}
     Create directory  path=/tmp/${alias}
     core.stop_collectors    names=tcpdump
     core.collect_collectors    names=tcpdump    target_dir=${OUTPUT_DIR}
     core.teardown_collectors    names=tcpdump
     ${rc}=    Run And Return Rc  mergecap -a ${dir_path}/tcpdump/*mirroring_L2L1*.pcap* -w /tmp/${alias}/tcpdump.pcap
     Run keyword if    ${rc}!=0    Fail    PCAP merging failed, check if alias does not contain spaces
     Copy File    /tmp/${alias}/tcpdump.pcap    ${dir_path}/${bip_file}
     Remove Directory    ${OUTPUT_DIR}/tcpdump
     ...                 recursive=True
     Sleep    10s
