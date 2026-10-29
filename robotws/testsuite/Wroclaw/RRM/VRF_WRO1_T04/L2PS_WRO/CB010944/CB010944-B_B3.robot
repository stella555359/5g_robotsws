*** Settings ***
Documentation
...    copyright: Nokia

Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    SBTS00    SBTS23R1    RAN_5G    RAN_5G_FDD

Resource    testsuite/Wroclaw/RRM/resources/logs.robot
Resource    ../resources/configuration_id.robot
Resource    ../resources/5G_SW_WRO_Keywords.robot
Resource    CB010944_keywords.robot
Library     ../resources/Python/webem_alarms.py
Library     ../resources/Python/traffic_management.py
Library     ute_admin_infomodel
Library     taf.transport.ssh  WITH NAME  ssh
Library     CB010944_keywords.py
Library     taf.collectors.l1l2bip    WITH NAME    l1l2bip
Library     taf.collectors.l2stream3     WITH NAME  tcl
Library     taf.converters.eventdecoder  WITH NAME  tce
Library     taf.collectors.core    WITH NAME    core

Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/AEQE_iphy.xml
    ...                        swconfig_flags_list=@{L2PS_BIP_SIZE}
    ...        AND             Start Default Logging
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=full_CB010944_1208_SRS_50MHz.xml
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/basic_setup_8249-C_SA_SRS.cfg
    ...        AND             Active beam

Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
@{L2PS_BIP_SIZE}=                 0x3F007C = 50
${ADMIN_INFOMODEL_ALIAS}=         infomodel_1
${ADMIN_INFOMODEL_LOG_DIR}=       ${OUTPUT_DIR}
${ADMIN_INFOMODEL_FILENAME}=      infomodel.ims2


*** Test Cases ***
CB010944_B_B3_Load_generation_IWK_with_CB008247_SRS_based_DL_BF
    Verify Target Beam Candidates
    Check Selected Beam Candidates    NRBEAM_EMF-1
    Set Internal Traffic Type To UE
    Set SRS Beam Config
    Attach SA UE And Verify msg2TPC     ue_id=1      msg2TPC_value=3
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Attach SA UE And Verify msg2TPC     ue_id=4      msg2TPC_value=3
    Establish Pdu Session    ue_id=4    pdu_id=4    gw_id=1
    Airphone override to rank2
    Start and Verify Tput
    Collect TTI Traces And Check DL MU-MIMO And DL SRS-based BF   duration=6   directory_name=CB010944-B B3  ini_path=tti_dl_features_enabled.ini
    Start Gathering BIP Logs And Wait 5s
    Stop gnbMirroring And Gather L1L2 Bip Logs
    Verify Max PRB for TargetLoad
    Deactive Emf Test Mode
    Verify Target Beam Candidates Not Exist
    [Teardown]    Run Keywords    Stop All Data Transfers And Detach UE SA
    ...    AND    Send Configuration ID To Scout

*** Keywords ***
Start and Verify Tput
    Start Double Data Traffic In DL And Single In UL   ue_id=1    pdu=1   tput_dl=150   tput_ul=50
    Start Double Data Traffic In DL And Single In UL   ue_id=4    pdu=4   tput_dl=150   tput_ul=10
    Verify Tput For UE    ue_id=1   dir=ul    expected_tput=25
    Verify Tput For UE    ue_id=1   dir=dl    expected_tput=280
    Verify Tput For UE    ue_id=4   dir=ul    expected_tput=9
    Verify Tput For UE    ue_id=4   dir=dl    expected_tput=280

Verify Max PRB for TargetLoad
    Convert pcap file to pdml
    verify_PRB_for_patternId    pdml_path=${OUTPUT_DIR}/BIP_log_1.pdml    patternId=1309
    ...    num_prb=120    bip_mesg=nr_l1dl_l2ps_dldata_pdschsendreql1sw_t

Verify Target Beam Candidates
    Start Infomodel Logging
    FOR    ${ID}    IN RANGE    ${1}    ${6}
    ${object_exists}=       Check infomodel object        dist_name=/MRBTS-1//NRCELL_A-1/NRBEAM_EMF_A-${ID}    alias=${ADMIN_INFOMODEL_ALIAS}
    Should Be True         ${object_exists}               msg= NRBEAM_EMF_A-${ID} found in InfoModel.
    END
    Stop Infomodel Logging      address=192.168.255.129

Check Selected Beam Candidates
    [Arguments]      ${expected_value}
    Start Infomodel Logging
    Query Infomodel And Expect Parameter Value
    ...    dist_name=/MRBTS-1/RAT-1//NRCELL_A-1
    ...    parameter=emfBeamDNList[0]
    ...    value=${expected_value}
    Stop Infomodel Logging      address=192.168.255.129

Verify Target Beam Candidates Not Exist
    Start Infomodel Logging
    FOR    ${ID}    IN RANGE    ${1}    ${6}
    ${object_exists}=       Check infomodel object        dist_name=/MRBTS-1//NRCELL_A-1/NRBEAM_EMF_A-${ID}    alias=${ADMIN_INFOMODEL_ALIAS}
    Should Be True         ${object_exists}==${False}               msg= NRBEAM_EMF_A-${ID} not found in InfoModel.
    END
    Stop Infomodel Logging      address=192.168.255.129

Convert pcap file to pdml
    [Documentation]     Using luashark converting BIP log from pcap to pdml.
    [Arguments]   ${input_file}=${OUTPUT_DIR}/BIP_L1L2_1.pcap
    Log to console    Converting pcap to pdml
        ${tshark_cmd} =   Catenate    tshark
    ...    -r ${input_file}
    ...    -Y "(nr_l1dl_l2ps_dldata_pdschsendreql1sw_t) && (DlData_PdschGrantL1sw.patternId_item) && (DlData_PdschGrantL1sw.numOfPrb)"
    ...    -T pdml > ${OUTPUT_DIR}/BIP_log_1.pdml
    Run    ${tshark_cmd}
    Log to console    Pcap->Pdml conversion done...
#    Remove File    ${dir_path}/BIP_L1L2_1.pcap
    Sleep    5s

Convert pcap file to pdml for srs
    [Documentation]     Using luashark converting BIP log from pcap to pdml.
    [Arguments]   ${input_file}=${OUTPUT_DIR}/BIP_L1L2_1.pcap
    Log to console    Converting pcap to pdml
        ${tshark_cmd} =   Catenate    tshark
    ...    -r ${input_file}
    ...    -Y uldata_srsreceivereq
    ...    -T pdml > ${OUTPUT_DIR}/BIP_log_1.pdml
    Run    ${tshark_cmd}
    Log to console    Pcap->Pdml conversion done...
#    Remove File    ${dir_path}/BIP_L1L2_1.pcap
    Sleep    5s

Stop Infomodel Logging
    [Arguments]    ${address}
    ...            ${filename}=${ADMIN_INFOMODEL_FILENAME}
    ...            ${log_dir}=${ADMIN_INFOMODEL_LOG_DIR}
    ...            ${alias}=${ADMIN_INFOMODEL_ALIAS}

    ute_admin_infomodel.Save Infomodel Log    filename=${log_dir}/${filename}_${address}  alias=${alias}
    ute_admin_infomodel.Disconnect Infomodel  alias=${alias}
    ute_admin_infomodel.Teardown Infomodel    alias=${alias}

Query Infomodel And Expect Parameter Value
    [Arguments]    ${dist_name}
    ...            ${parameter}
    ...            ${value}
    ...            ${timeout}=60
    ${out_query_result}=   ute_admin_infomodel.Query Infomodel    query=${dist_name} is [${parameter}=${value}]
    ...    timeout=${timeout}  alias=${ADMIN_INFOMODEL_ALIAS}

Start Infomodel Logging
    ute_admin_infomodel.Setup infomodel    address=192.168.255.129    port=443    alias=${ADMIN_INFOMODEL_ALIAS}
    ute_admin_infomodel.Connect infomodel    alias=${ADMIN_INFOMODEL_ALIAS}

Print thuput
    Execute Egate Command And Wait For Data
    ...    cmd=ue_stats_nr id=1 type=pdsch scell=0-4
    Execute Egate Command And Wait For Data
    ...    cmd=ue_stats_nr id=4 type=pdsch scell=0-4
    Execute Egate Command And Wait For Data
    ...    cmd=ue_stats_nr id=1 type=pusch scell=0-4
    Execute Egate Command And Wait For Data
    ...    cmd=ue_stats_nr id=4 type=pusch scell=0-4

Active beam
    Find Scfc and Send Delta Commissioning    scfc_filename=emfbeam_2.json

Deactive Emf Test Mode
    Find Scfc and Send Delta Commissioning    scfc_filename=deactive_emf_2.json

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
     ...  timeout=500
     ...  remove_zip_file=False
     core.setup_collectors    names=tcpdump
     core.start_collectors    names=tcpdump
     core.Set Suite Alias     ${target_file_name}
     Sleep    5

Stop gnbMirroring And Gather L1L2 Bip Logs
     [Arguments]
     ...     ${alias}=L1L2_BIP_Logs
     ...     ${dir_path}=${OUTPUT_DIR}
     ...     ${delay}=0
     Sleep  ${delay}
     Create directory  path=${dir_path}/${alias}
     Create directory  path=/tmp/${alias}
     core.stop_collectors    names=tcpdump
     core.collect_collectors    names=tcpdump    target_dir=${OUTPUT_DIR}
     core.teardown_collectors    names=tcpdump
     ${rc}=    Run And Return Rc  mergecap -a ${dir_path}/tcpdump/*mirroring_L2L1*.pcap* -w /tmp/${alias}/tcpdump.pcap
     Run keyword if    ${rc}!=0    Fail    PCAP merging failed, check if alias does not contain spaces
     OperatingSystem.Copy File    /tmp/${alias}/tcpdump.pcap    ${dir_path}/BIP_L1L2_1.pcap
     Remove Directory    ${OUTPUT_DIR}/tcpdump
     ...                 recursive=True
     Sleep    10s





