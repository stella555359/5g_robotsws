*** Settings ***
Documentation     Perf Variables file

*** Variables ***
${simmode_timeout}    600
${pdu_session_pattern}    Established PDU session ID
${sa_nsa_detach_pattern}    detached
${mue_detach_pattern}    === Bearer-type change from SCG-split to MCG is successful ===
${gnb_pdcp}    PDCP at GNB
${pdu_session_release}    Released PDU session
${Trf_validation_string}    All UE Traffic is started
${lte_attach_mue}    === UE IS ACTIVE
@{sa_ueids_multicell}    101    253
@{nsa_ueids_multicell}    1    51
@{sa_fdd_ueids_multicell}    609    761    913    1065
@{nsa_fdd_ueids_multicell}    1    153    305    457
@{sa_fdd_iwf_ueids_multicell}    161    313    465    617    769    921    1073    1225
@{nsa_fdd_iwf_ueids_multicell}    1    21    41    61    81    101    121    141
${perf_sa_sue_dl_rate}    1600
${perf_ul_rate}    200
${perf_nsa_sue_dl_rate}    1200
${abil_sue_dl_rate}    200
${abil_sue_ul_rate}    140
${abil_mue_rate}    10
${pdu}    1
${qfi}    1
${dl_mbps_1}    175
${dl_mbps_2}    60
${ul_mbps}    120
${evaluator}    1000000
${per_ue_dl}    30
${per_mue_dl}    60
${perf_mue_dl_rate}    60
${perf_mue_ul_rate}    10
${dl_data_rate_mmwv}    550
${ul_data_rate_mmwv}    110
${ul_datarate_mmwv_mue}    5.5
${dl_datarate_mmwv_mue}    27.5
${kbps_ul}    5500
${kbps_dl}    27500
${SA_DL_TPUT_COUNTER}    M55326C00501
${SA_UL_TPUT_COUNTER}    M55326C00502
${NSA_DL_TPUT_COUNTER}    M55319C02009
${NSA_UL_TPUT_COUNTER}    M55319C06009
${SA_DL_CELL_RLC_COUNTER}    M55310C01006
${SA_UL_CELL_RLC_COUNTER}    M55310C03006
${NSA_DL_CELL_RLC_COUNTER}    M55310C01009
${NSA_UL_CELL_RLC_COUNTER}    M55310C03009
${NSA_DL_gNB_COUNTER}    M55326C00001
${NSA_UL_gNB_COUNTER}    M55326C00002
${L2RT_container_ID}    5732
${L2RT_container}    0x5732
${perf_trf_duration}    11
${dl_limit}    0.95
${dl_mue_limit}    0.83
${ul_limit}    0.95
${sa_mue_dl_limit}    0.875
${mue_dl_limit}    0.90
${mue_ul_limit}    0.90
${SA_CELL1_FIRST_DEFAULT}    101
${SA_CELL1_END_DEFAULT}    252
${NSA_CELL1_FIRST_DEFAULT}    1
${NSA_CELL1_END_DEFAULT}    10
${SA_CELL2_FIRST_DEFAULT}    253
${SA_CELL2_END_DEFAULT}    404
${NSA_CELL2_FIRST_DEFAULT}    51
${NSA_CELL2_END_DEFAULT}    60
${NO_OF_CELL_LO}    2
${NO_OF_CELLS_FDDPerf}    4
${NO_OF_CELLS_FDDIWF}    8
${NO_OF_CELL_LOOO}    6
${SANSA_MUE_20_CELLUE}    10
${active_ues_total}    0
@{amf_list}    1    2
${Timeout_Fdd_Perf}    200
${fdd_per_cell_dl}    106.5
${fdd_iwf_per_cell_dl}    101.5
${fdd_per_cell_ul}    52.5
${trf_id_fddperf}    16000
${trf_id_perf}    1350
${NSA_CELL}    NSA_CELL
${SA_CELL}    SA_CELL
${target_cells_IWF_FR1}    2
${TRF_PERF_BIP_LOGS}    False
${SIB_TIMEOUT}    600
${AP_Snapshot}    False
${DC_ACTIVE_REGEXP}    DC state\\s+active
${IWF_FAIL}    IWF process is not active
${FR2_8CC_cell_index}    8:16
${FR2_4CC_cell_index}    8:11
${FR2_single_cell_index}    8:8
${FR2_cell_index_8CC}    8:15

${cell_index_id}    1
${stats_id}    11
${stats_id_Cell1}    1-20
${stats_id_Cell_8CC}    1-10
${stats_id_Cell2}    21-40
${stats_type}    pusch,pdsch
${stats_scell}    8-15
@{nsa_iwf_fr1_ueids}    2001    2002
@{target_ids_nsa}    1    3

@{TRFID}    1    2    3
@{data_rate}    143    143    144
${NO_OF_CELLS_IWF}    8

${CAP_CFG_FILE}    capability.cfg

@{SimMode}     CRASH OCCURED    SimMode is ready now
${mib_pattern_iwf}    MasterInformationBlock

${FR2FirstUE}    1
${FR2EndUE}    40

${IWF_ENABLED}    False
@{IWF_Strings}    UPF-1: Starting in IWF mode    SGW-1: Starting in IWF mode
...    PGW-1: Starting in IWF mode    MME-1: Starting in IWF mode    UEC-1: Starting in IWF mode
...    ENB-1: Starting in IWF mode

${FR2_4CCDl}    2200
${FR2_8CCDl}    4300
${FR2_Ul}    0
${FR2_UE}    11

#Variables for MUMIMO Beamforming
${noise_srs}    -1053
${sinr_target_srs}    100
${testmode}    ul_sinr
${action}    activate
${profile_id}    7
${mu_id1}    1-144
${mu_id2}    144-288
${MIMO_id1}    1-36
${MIMO_id2}    37-72
${MIMO_id3}    72-108
${MIMO_id4}    108-144
${MUMIMO_id1}    145-180
${MUMIMO_id2}    181-216
${MUMIMO_id3}    217-252
${MUMIMO_id4}    253-288
@{Prof_id}    1    2    3    4
@{init_pos}    0    1    2    3

${FDD_IWF_multicell}    0
${gnb_pmcounter_dir}    /home/ute/fdd_pmcounters
${gnb2_pmcounter_dir}    /home/ute/fdd_pmcounters2

#P1_Perf lua generator script
${lua_generator_script}    ${CURDIR}/../scripts/luaGenerator_APoABIO.py
${lua_generator_mmwv_script}    ${CURDIR}/../scripts/luaGenerator_mmwv_APoABIO.py
${perf_wts_stats_script}    ${CURDIR}/../scripts/wts_interface_stats.sh
${lua_generator_fdd_abil}    ${CURDIR}/../scripts/luaGenerator_Fdd_APoABIL.py
${Fdd_Perf_Lua}    ${CURDIR}/../scripts/PERF_LUA/fdd_perf.lua
${20UEDL_lua}    ${CURDIR}/../scripts/20UEDL.lua
${144UEDL_lua}    ${CURDIR}/../scripts/144UEDL.lua
${PET_AMF}    5
${ng_link_up_pattern}        NG link is up
${sib_script_pattern}    SIB Check Script Completed
${cell_setup_pattern}    Cell Setup completed

@{IWF_TAGS}    SA_MUE    NSA_MUE    SA304UE    SA_NSA_PAR_TC2    NSA_4_UE    NSA_1_UE_2CC
...    SA_4_UE    SA_1_UE_2CC    SA_1_UE_3CC    SA_20_UE_2CC
...    FR2_8CC    FR2_4CC    FR2_NSA_MUE    FR2_NSA_SUE    SANSA_72_UE    SA500UE
@{FR1_IWF_TAGS}    SA_MUE    NSA_MUE    SA304UE    SA_NSA_PAR_TC2    NSA_4_UE    NSA_1_UE_2CC
...    SA_4_UE    SA_1_UE_2CC    SA_1_UE_3CC    SA_20_UE_2CC    SANSA_72_UE    SA500UE
@{FR2_IWF_TAGS}    FR2_8CC    FR2_4CC    FR2_NSA_MUE    FR2_NSA_SUE    FR2_NSA_MUE_2CELL
@{NSA_TAGS}    NSA_MUE    NSA_4_UE    NSA_1_UE_2CC    SA_NSA_PAR_TC2    SANSA_72_UE
...    FR2_8CC    FR2_4CC    FR2_NSA_MUE    FR2_NSA_SUE    FR2_NSA_MUE_2CELL    SA_608UE
@{SA_TAGS}    SA_MUE    SA_NSA_PAR_TC2    SA_4_UE    SA_1_UE_2CC    SA_1_UE_3CC    SA304UE
...    SA_20_UE_2CC    SANSA_72_UE    SA500UE    144UEDL
@{DL_TAGS}    40UEDL    40UEDL3CC    SA20    NSA_4_UE    SA_4_UE    SA_1_UE_2CC    SA_1_UE_3CC
...    SA_20_UE_2CC    144UEDL   SANSA_72_UE    432UEDL    432UEDL_BF    1208FF_GBR
...    CB008701_4UES    CB008701_72UES
@{UL_TAGS}    432UEUL    1UEUL    72UEUL    1070FF_GBR
...    CB008406FF_432UES    CB008360_2UES
@{FR1_2CC_TAGS}    SA_MUE    NSA_MUE    SA304UE    SA_NSA_PAR_TC2    NSA_4_UE    NSA_1_UE_2CC
...    SA_4_UE    SA_1_UE_2CC    SA_20_UE_2CC    SANSA_72_UE    SA500UE

@{DSS_CA_TAGS}    DSS_CA_IWF    SA_SUE_6CC_IWF    SA_CA_20UE    SA_CA_80UE    NSA_10UEs   SA_NSA_SUE_2CELL    TC1_106SA_DL

@{PET_TAF_TAGS}    144UEDL    3000UEDLUL
@{ue_id_list}    1    1051


${IWF_CONFIG}    ${CURDIR}/../scripts/iwf_launch.py

${dist}    MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1
${vland_pname}   vlanId
${testline_results_path_perf}    /home/ute/testline_update_results/configs
${run_script_log_set}    ${CURDIR}${/}../../../QT/resources/scripts/run_script_log_set.lua
${sib_decoding_pattern_pet}    SystemInformationBlockType5
${pet_tput_file}    ${EXECDIR}/tput_test.properties
${pet_trf_duration}    60
${traffic_validation}    All UE Traffic is started
${proxy_estblishment}    Established connection with proxy to eNB 2 cell
${TAG_NAME}    Non_RRC
${scell_index_ca}    SCellIndex 1 activated successfully at airphone
${start_amf}    1
${end_amf}    5
${mnc_mcc}    311:490
${mnc_mcc_plmn}    311:489
${max_ues}    3000
${amf_register_mue}    AMF registeration completed
${ue_register_complete}    Completed Loop for UEs
${mue_deregister_complete}    Complete Deregister
${fdd_dl_dataRate}    426
${fdd_iwf_dl_dataRate}    406
${fdd_ul_dataRate}    210
${OVERALL_DL_CC}    3200
${TAF_REPO}    https://artifactory-espoo1.ext.net.nokia.com/artifactory/api/pypi/ta-lib-5g-virtual/simple
${config_reader}    ${CURDIR}/../scripts/config_update.py
${DEREGISTER_RATE}    5

${gNB_Mirroring_script}    /opt/wts/latest/sosReport_ASIL/gnbMirroringConfig.sh

#PET SE Variables and Tags
#for PET_SE_TAGS please append to the below list at the end & do not change the order
@{PET_SE_TAGS}    48UEDLUL_BF    40UEDL3CC    432UEDL_BF
...    1070FF_BF_VoNR    406Scell    9000_BF    1208FF_GBR    1070FF_GBR    1070FF_MIXEDGBR
...    1070FF_VoNR_CDRx_Disabled    CB008406FF_432UES    CB008701_4UES    CB008701_72UES    CB008360_2UES
@{1208FF_TAGS_CA}    40UEDL3CC
@{1208FF_TAGS}    432UEDL_BF    Perf_Mue
@{1116FF_TAGS}    505Scell
@{1070FF_TAGS_VoNR}    1070FF_BF_VoNR
@{8406FF_TAGS}    1UEUL    72UEUL
@{1070FF_BF_TAGS}    9000_BF    48UEDLUL_BF
@{PET_SE_PARALLEL_VALIDATION}    3000UEDLUL
@{WTSSIM_TAGS}    9000_BF    432UEDL_BF    1070FF_BF_VoNR    505Scell
...    SA500UE    1208FF_GBR    1070FF_GBR    1070FF_MIXEDGBR
...    1070FF_VoNR_CDRx_Disabled    CB008406FF_432UES    CB008701_4UES    CB008701_72UES    CB008360_2UES
@{RESET_TAGS}    72UE2CELL    DSS4UL_VoNR
...    CB008701_72UES    3S_8CC_DL_12UE    MUE_6S_4CC
...    1S_8CC_MUE_UL    TDD_3CC_Scell    TCP_3S_8CC_UL_MP    TCP_1S_8CC_DL_MP    DL_3S_8CC_MP
...    UL_3S_8CC_MP    DL_MUE_3S_8CC_MP    UL_MUE_3S_8CC_MP
@{GBR_TAGS}    1208FF_GBR    1070FF_GBR    1070FF_MIXEDGBR
...    1070FF_VoNR_CDRx_Disabled    CB008406FF_432UES    CB008701_4UES    CB008701_72UES    CB008360_2UES
${SIB_TDD}    1,6
${SIB_TDD_TIMEOUT}    30
${SGNB_ADMISSION_REQ_Counter}    M55138C00001
${SGNB_ADMISSION_RES_Counter}    M55138C00002
${counter_wait_time}    360s
${nonRRC_UE_Count_threshold}    1
${RRC_UE_Count_threshold}    0.005

${NO_OF_CELL_LO_TDD}    1
${BSR_TEST}    0
${OVERALL_UL_TPUT_CB008406FF_432UES}    2640
${OVERALL_DL_TPUT_CB008701_4UES}    4800
${OVERALL_DL_TPUT_CB008701_72UES}    4800
${OVERALL_UL_TPUT_1070FF_VoNR_CDRx_Disabled}    128
${OVERALL_DL_TPUT_1070FF_VoNR_CDRx_Disabled}    128
${GBR_VoNR_CDRx_Disabled}    1656

${wts_cfg_load_command}    cfg_sim file=/opt/wts/latest/sansa.lua entry=run_configuration()
${VoNR_peak_COUNTER}    M55140C00501
${expected_VoNR_peak}    828
${testmode_nr_profile}    4
${testmode_profile1}    1,207,1,5
${testmode_profile2}    208,415,2,5
${testmode_profile3}    416,623,3,5
${testmode_profile4}    624,828,4,5

${FR1_COMMANDS_LUA}    ${CURDIR}/../scripts/PET_SE_IWF/commands.lua
${FR1_CAPABILITIES_CFG_FILE}    ${CURDIR}/../scripts/PET_SE_IWF/capability.cfg
${FR1_MULTI_UE_SCRIPT}    ${CURDIR}/../scripts/PET_SE_IWF/multi_ue_sa_script_new.lua

${432UE_SE_WaitTime}    3
${VoNR_WaitTime}    3
${sib_pattern_pet_se}    SIB Found
${pet_se_validation_string}    script completed
${InitialRegistration}    INITIAL_REGISTRATION
${SE_sib}    1,6
${sys_log_directory}    /home/ute/udpsyslog/
${skip_ues}    50

${TLTYPE}    yes
${CALLTYPE}    sa
${WTS_Summary}    ${CURDIR}/../scripts/WTS_Summary
${wts_sim_edaemon_port}    22222
${wts_sim_egate_port}    20000

${em_trace_stream}    tools/emtraces/EmTraceHistoryBufferStreamReceiver64
${em_trace_stream_port}    15003
${em_trace_type}    syscom-testport

${nsa_fr2_first_cell1}    11
${nsa_fr2_end_cell1}    30
${rrc_ue_timeout}    1800
${default_timeout}    600
${iwf_cells}    3
${loo_iwf_cells}    5
${IWF_LOO_CELLS_6}    6
${EM_TRACES}    True
${EM_PERF_STATS}    True
${SYSLOG}    True
${WTS_PCAP}    False
${AP_TOP}    False
${L2L3_BIPLOG}    False
${simmode_check}    SimMode is ready now
${TOP_INTERFACE_STATS}    True

${targetbd_file}    ${EXECDIR}/custom_configs
${remote_paths}    /ffs/run/
${remote_path}    /ffs/run/simmode
${local_path}    /home/ute/Perf_config
${ute_perf_ca_path}    /home/ute/.ute-ca/executions/1/configs/testline_configuration
${testline_config_perf_path}    /home/ute/testline_configuration
${custom_perf_path}    ${EXECDIR}/custom_configs
@{mue_tcs}    10PARUE    5PARUE    SANSA_72_UE
&{GNB_BTS1}     Ip=192.168.255.1    Username=Nemuadmin    Password=nemuuser    Port=443
${IWF_TDD_FR1}    False
${rrc_limit}    0.995

&{AP_bsh_ip}    0:0=192.168.253.80    0:1=192.168.253.81    0:2=192.168.253.82    1:0=192.168.253.84
...    1:1=192.168.253.85    1:2=192.168.253.86    2:0=192.168.253.88    2:1=192.168.253.89
...    2:2=192.168.253.90    3:0=192.168.253.92    3:1=192.168.253.93    3:2=192.168.253.94

&{gNB_bsh_ip}    0:0=192.168.253.32    0:1=192.168.253.33    0:2=192.168.253.34    1:0=192.168.253.36
...    1:1=192.168.253.37    1:2=192.168.253.38    2:0=192.168.253.40    2:1=192.168.253.41
...    2:2=192.168.253.42    3:0=192.168.253.44    3:1=192.168.253.45    3:2=192.168.253.46

${TARGET_IP_BASE}    192.168.253
${USER_NAME}    toor4nsn
${USER_PASSWORD}    oZPS0POrRieRtu
${ssh_fix_cmd}    ssh -o StrictHostKeyChecking=no -o ProxyJump
${ap_base_ip}    192.168.200
${path_perf}    /opt/CCS_RT/em_perf_monitor
${stat_log}    /ffs/run/logs/stats.log

#Different name for scenario
&{SA_24UE_DL}    FIRST_UE=1    END_UE=24    PDU_ID=1    QFI_ID=1    TRF_ID=1
   ...    UL_RATE=0    DL_RATE=150000    TRF_DIR=dl    DELAY_BTW_PDU_TRAFFIC=0.6
   ...    TRF_TYPE=internal    PACKET_SIZE=1350    LUA_FILE=pet_lua_functions.lua
   ...    LUA_METHOD=attach_start_traffic_multiue    OVERALL_DL=600    RMOD=AEQE

&{SA_24UE_UL}    FIRST_UE=1    END_UE=24    PDU_ID=1    QFI_ID=1    TRF_ID=1
   ...    UL_RATE=80000    DL_RATE=0    TRF_DIR=ul    DELAY_BTW_PDU_TRAFFIC=0.6
   ...    TRF_TYPE=internal    PACKET_SIZE=1350    LUA_FILE=pet_lua_functions.lua
   ...    LUA_METHOD=attach_start_traffic_multiue    OVERALL_UL=320    RMOD=AEQE

&{SA_24UE_BOTH}    FIRST_UE=1    END_UE=24    PDU_ID=1    QFI_ID=1    TRF_ID=1
   ...    UL_RATE=54000    DL_RATE=150000    TRF_DIR=both    DELAY_BTW_PDU_TRAFFIC=0.6
   ...    TRF_TYPE=internal    PACKET_SIZE=1350    LUA_FILE=pet_lua_functions.lua
   ...    LUA_METHOD=attach_start_traffic_multiue    OVERALL_DL=600    OVERALL_UL=216
   ...    RMOD=AEQE

&{SA_40UE_DL}    FIRST_UE=1    END_UE=40    PDU_ID=1    QFI_ID=1    TRF_ID=1
   ...    UL_RATE=0    DL_RATE=80000    TRF_DIR=dl    DELAY_BTW_PDU_TRAFFIC=2
   ...    TRF_TYPE=internal    PACKET_SIZE=1350    LUA_FILE=pet_lua_functions.lua
   ...    LUA_METHOD=attach_start_traffic_multiue    OVERALL_DL=80    RMOD=AEQE

&{SA_72UE_UL}    FIRST_UE=1    END_UE=72    PDU_ID=1    QFI_ID=1    TRF_ID=1
   ...    UL_RATE=6100    DL_RATE=0    TRF_DIR=ul    DELAY_BTW_PDU_TRAFFIC=0.6
   ...    TRF_TYPE=internal    PACKET_SIZE=1350    LUA_FILE=pet_lua_functions.lua
   ...    LUA_METHOD=attach_start_traffic_multiue    OVERALL_UL=6100    RMOD=AWHQW

&{SA_304UE_BOTH}    FIRST_UE=101    END_UE=404    PDU_ID=1    QFI_ID=1    TRF_ID=1
   ...    UL_RATE=500    DL_RATE=500    TRF_DIR=both    DELAY_BTW_PDU_TRAFFIC=0.7
   ...    TRF_TYPE=internal    PACKET_SIZE=1350
   ...    LUA_FILE=pet_lua_functions.lua
   ...    LUA_METHOD=attach_start_traffic_multiue    OVERALL_DL=76    OVERALL_UL=76

&{SA_40UE_CA_DL}    FIRST_UE=1    END_UE=40    PDU_ID=1    QFI_ID=1    TRF_ID=1
   ...    UL_RATE=0    DL_RATE=120000    TRF_DIR=dl    DELAY_BTW_PDU_TRAFFIC=2
   ...    TRF_TYPE=internal    PACKET_SIZE=1350    LUA_FILE=pet_lua_functions.lua
   ...    LUA_METHOD=attach_start_traffic_multiue    OVERALL_DL=120    RMOD=AEQE
   ...    Cell_Count=1,6    SIB_Timeout=30    NO_OF_CELLS=6    UEC_COUNT=6
   ...    entry=PET_1208FF_nonBF_40UE_DL_3CC   timeout=180
   ...    SCRIPT_COMPLETE=PET_1208FF_nonBF_40UE_DL_3CC script completed

&{SA_20UE_DL}    FIRST_UE=1    END_UE=20    PDU_ID=1    QFI_ID=1    TRF_ID=1
   ...    UL_RATE=0    DL_RATE=120000    TRF_DIR=dl    DELAY_BTW_PDU_TRAFFIC=2
   ...    TRF_TYPE=internal    PACKET_SIZE=1350    LUA_FILE=pet_lua_functions.lua
   ...    LUA_METHOD=attach_start_traffic_multiue    OVERALL_DL=120    RMOD=AEQE

&{FR2_8CC}    OVERALL_DL=3200    OVERALL_UL=0
&{FR2_4CC}    OVERALL_DL=2200    OVERALL_UL=0

&{SA_4UE_MIMO}    FIRST_UE=1    END_UE=4    PDU_ID=1    QFI_ID=1    TRF_ID=1
   ...    UL_RATE=0    DL_RATE=800000    TRF_DIR=dl    DELAY_BTW_PDU_TRAFFIC=0.6
   ...    TRF_TYPE=internal    PACKET_SIZE=1350    LUA_FILE=pet_lua_functions.lua
   ...    LUA_METHOD=attach_start_traffic_multiue    OVERALL_DL=800    RMOD=AEQE

&{NSA_4UE_MIMO}    FIRST_UE=1    END_UE=4    PDU_ID=1    QFI_ID=1    TRF_ID=1
   ...    UL_RATE=0    DL_RATE=800000    TRF_DIR=dl    DELAY_BTW_PDU_TRAFFIC=0.6
   ...    TRF_TYPE=internal    PACKET_SIZE=1350    LUA_FILE=pet_lua_functions.lua
   ...    LUA_METHOD=attach_start_traffic_multiue    OVERALL_DL=800    RMOD=AEQE

&{FR2_NSA_MUE_1CELL_ULDL}    FIRST_UE=1    END_UE=10    BEARER_ID=2    TARGET_GNB=2
   ...    TARGET_GNB_CELL=1    UL_RATE=110000    DL_RATE=550000
   ...    UL_PACKET_SIZE=1350    UL_PACKET_SIZE=1350
   ...    LUA_FILE=pet_lua_functions.lua    tag=NSA_10UE
   ...    LUA_METHOD=attach_with_complete_call_without_timer_with_tag    OVERALL_DL=550    OVERALL_UL=110

&{FR2_NSA_MUE_2CELL_ULDL}    FIRST_UE=11    END_UE=20    BEARER_ID=2    TARGET_GNB=2
   ...    TARGET_GNB_CELL=2    UL_RATE=110000    DL_RATE=550000
   ...    UL_PACKET_SIZE=1350    UL_PACKET_SIZE=1350
   ...    LUA_FILE=pet_lua_functions.lua    tag=NSA_10UE
   ...    LUA_METHOD=attach_with_complete_call_without_timer_with_tag    OVERALL_DL=550    OVERALL_UL=110

&{FR2_NSA_MUE_3CELL_ULDL}    FIRST_UE=21    END_UE=30    BEARER_ID=2    TARGET_GNB=2
   ...    TARGET_GNB_CELL=3    UL_RATE=110000    DL_RATE=550000
   ...    UL_PACKET_SIZE=1350    UL_PACKET_SIZE=1350
   ...    LUA_FILE=pet_lua_functions.lua    tag=NSA_10UE
   ...    LUA_METHOD=attach_with_complete_call_without_timer_with_tag    OVERALL_DL=550    OVERALL_UL=110

&{FR2_NSA_MUE_4CELL_ULDL}    FIRST_UE=31    END_UE=40    BEARER_ID=2    TARGET_GNB=2
   ...    TARGET_GNB_CELL=4    UL_RATE=110000    DL_RATE=550000
   ...    UL_PACKET_SIZE=1350    UL_PACKET_SIZE=1350
   ...    LUA_FILE=pet_lua_functions.lua    tag=NSA_10UE
   ...    LUA_METHOD=attach_with_complete_call_without_timer_with_tag    OVERALL_DL=550    OVERALL_UL=110

&{SA20_2CC}    FIRST_UE=1    END_UE=20    PDU_ID=1    QFI_ID=1    TRF_ID=1
   ...    UL_RATE=0    DL_RATE=160000    TRF_DIR=dl    DELAY_BTW_PDU_TRAFFIC=0.6
   ...    TRF_TYPE=internal    PACKET_SIZE=1350    LUA_FILE=pet_lua_functions.lua
   ...    LUA_METHOD=attach_start_traffic_multiue    OVERALL_DL=3200    RMOD=AEQE

&{SA_72UE_CELL}    FIRST_UE=1    END_UE=72
   ...    OVERALL_DL=800    OVERALL_UL=100    TIME_IN_SECONDS=2000    CELL1_UES=72    ID=7,9
   ...    SE_duration=80    SE_wait=100s

&{NSA_72UE_CELL1}    FIRST_UE=2001    END_UE=2072    BEARER_ID=2    TARGET_GNB=2
   ...    TARGET_GNB_CELL=1    UL_RATE=100000    DL_RATE=800000
   ...    UL_PACKET_SIZE=1350    DL_PACKET_SIZE=1350
   ...    LUA_FILE=pet_lua_functions.lua
   ...    LUA_METHOD=attach_with_complete_call_without_timer    OVERALL_CELL_DL=800    OVERALL_CELL_UL=100

&{NSA_72UE_CELL2}    FIRST_UE=2073    END_UE=2144    BEARER_ID=2    TARGET_GNB=2
   ...    TARGET_GNB_CELL=3    UL_RATE=100000    DL_RATE=800000
   ...    UL_PACKET_SIZE=1350    DL_PACKET_SIZE=1350
   ...    LUA_FILE=pet_lua_functions.lua
   ...    LUA_METHOD=attach_with_complete_call_without_timer    OVERALL_CELL_DL=800    OVERALL_CELL_UL=100

&{SA_500_UE_2CELL}    FIRST_UE=1    END_UE=1000
   ...    OVERALL_DL=0.074    OVERALL_UL=0.074    TIME_IN_SECONDS=1600    CELL1_UES=500    ID=1,3
   ...    SE_duration=560    SE_wait=180s    NO_OF_CELLS=3    CELL_COUNT=1,3

&{SA_2cell_MUE}    FIRST_UE=1    END_UE=1000
   ...    OVERALL_DL=1600    OVERALL_UL=200    TIME_IN_SECONDS=920    CELL1_UES=1    ID=4,6
   ...    SE_duration=5    SE_wait=10s

&{SA_20_UE_2CC}    FIRST_UE=1    END_UE=1000
   ...    OVERALL_DL=3200    OVERALL_UL=0    TIME_IN_SECONDS=900    CELL1_UES=20    ID=10

&{SA_144UE_DL}    FIRST_UE=1    END_UE=288    PDU_ID=1    QFI_ID=1    TRF_ID=1
   ...    RATE=kbps    UL_RATE=0    DL_RATE=22200    TRF_DIR=dl    DELAY_BTW_PDU_TRAFFIC=0.7
   ...    TRF_TYPE=internal    PACKET_SIZE=1350
   ...    RETRY=yes    SRB_INACTIVITY_TIMER=60
   ...    LUA_FILE=pet_lua_functions.lua
   ...    LUA_METHOD=attach_start_traffic_multiue_retry    OVERALL_DL=3196    RMOD=AEQE

&{SA_432UE_UL}    FIRST_UE=1    END_UE=432    NUM_CELLS=6    PDU_ID=1    QFI_ID=1
   ...    TRF_ID=1    RATE=kbps    UL_RATE=3000    DL_RATE=0    TRF_DIR=ul
   ...    DELAY_BTW_UE_ATTACH=0.7    TRF_TYPE=internal    PACKET_SIZE=1350
   ...    RETRY_IDLE_OFF_UE=yes    srbInactivityTimerSA=60
   ...    LUA_METHOD=register_multiue_with_pdu_check_traffic_parallel_retry
   ...    LUA_FILE=pet_lua_functions.lua    OVERALL_UL=1296    RMOD=AEQE
   ...    entry=PET_1208FF_nonBF_432UE_UL    timeout=600
   ...    Cell_Count=1,6    SIB_Timeout=30    NO_OF_CELLS=6    UEC_COUNT=6
   ...    SCRIPT_COMPLETE=PET_1208FF_nonBF_432UE_UL script completed

&{FDD_UE_IDS}    FIRST_NSA_CELL1=1    END_NSA_CELL1=152    FIRST_SA_CELL1=609    END_SA_CELL1=760
    ...    FIRST_SA_CELL2=761    END_SA_CELL2=912    FIRST_NSA_CELL2=153    END_NSA_CELL2=304
    ...    FIRST_SA_CELL3=913    END_SA_CELL3=1064    FIRST_NSA_CELL3=305   END_NSA_CELL3=456
    ...    FIRST_SA_CELL4=1065    END_SA_CELL4=1216    FIRST_NSA_CELL4=457    END_NSA_CELL4=608

&{FDD_IWF_UE_IDS}    FIRST_NSA_CELL1=1    END_NSA_CELL1=20    FIRST_SA_CELL1=161    END_SA_CELL1=312
    ...    FIRST_SA_CELL2=313    END_SA_CELL2=464    FIRST_NSA_CELL2=21    END_NSA_CELL2=40
    ...    FIRST_SA_CELL3=465    END_SA_CELL3=616    FIRST_NSA_CELL3=41   END_NSA_CELL3=60
    ...    FIRST_SA_CELL4=617    END_SA_CELL4=768    FIRST_NSA_CELL4=61    END_NSA_CELL4=80
    ...    FIRST_SA_CELL5=769    END_SA_CELL5=920    FIRST_NSA_CELL5=81    END_NSA_CELL5=100
    ...    FIRST_SA_CELL6=921    END_SA_CELL6=1072    FIRST_NSA_CELL6=101    END_NSA_CELL6=120
    ...    FIRST_SA_CELL7=1073    END_SA_CELL7=1224    FIRST_NSA_CELL7=121    END_NSA_CELL7=140
    ...    FIRST_SA_CELL8=1225    END_SA_CELL8=1376    FIRST_NSA_CELL8=141    END_NSA_CELL8=160

&{NSA_10_UE}    entry=TC2_10NSA_8CC_DL_UL    MAX_ACTIVE_UES=10    EXPECTED_UE_COUNT=10
    ...    SCRIPT_COMPLETE=TC2_10NSA_8CC_DL_UL script completed    DIR=BOTH
    ...    Cell_IDs=1,2,3,4,5,6,7,8    Cell_IDs_NSA=1,2,3,4,5,6,7,8    ng_link_count=1    CA_NCA_MODE=CA
    ...    OVERALL_DL=4300    DL_LIMIT=0.90    OVERALL_UL=560    UL_LIMIT=0.90    COUNTER_CHECK=NSA
    ...    NSA_DL_TPUT_COUNTER=M55326C00001   NSA_UL_TPUT_COUNTER=M55326C00002
    ...    NSA_DL_CELL_RLC_COUNTER=M55310C01009   NSA_UL_CELL_RLC_COUNTER=M55310C03009
    ...    WTS_TC_CMD=script file\=test_sequence.lua entry\=TC2_10NSA_8CC_DL_UL

&{FR2_IWF_NSA_MUE_106UE_ULDL}    FIRST_UE=1    END_UE=106    BEARER_ID=2    TARGET_GNB=2
   ...    TARGET_GNB_CELL=1    UL_RATE=212    DL_RATE=212
   ...    UL_PACKET_SIZE=1350    UL_PACKET_SIZE=1350
   ...    LUA_FILE=pet_lua_functions.lua    tag=NSA_106_UE
   ...    LUA_METHOD=attach_with_complete_call_without_timer_with_tag

&{CLOUD_5G_I_LO_AP_LOO-IWF_PRIVATE_NSA_FS_ECPRI_MMWV_TDD_AP_PERFORMANCE}    SUITE_WTS_CFG=basic.lua
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_fdd_nsa_eCpri_mmwv_LO_AP_LOO
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_fdd_nsa_eCpri_mmwv_LO_AP_LOO
   ...    gnb_sm_hardware=ASIL    gnb_cp_hardware=[ABIO]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO, ABIO]
   ...    duplexing=TDD    skip_l2testmode=True    NO_OF_CELLS=8    ng_link_count=1
   ...    RF_type=eCPRI    wavelength=mmwv    deployment=NSA    Sim_Config_Format=True
   ...    l1=FS    RU_type=AEQE    COMPONENT_CARRIER=8    SKIP_WTS_CONFIG_DOWNLOAD=True
   ...    ute_ca_label=CLOUD_5G_I_LO_AP_LOO-IWF    ute_ca_variant=PRIVATE_NSA_FS_ECPRI_MMWV_TDD_AP_PERFORMANCE
   ...    ute_ca_variant_dss=PRIVATE_NSA_FS_ECPRI_MMWV_TDD_NONBF_AP_PERFORMANCE
   ...    WTS_COMMANDS_LUA=${CURDIR}/../scripts/TDD_FR2_IWF/sim_config.lua
   ...    WTS_TEST_SCRIPT=${CURDIR}/../scripts/TDD_FR2_IWF/test_sequence.lua
   ...    WTS_CAPS_CFG_FILE=${CURDIR}/../scripts/TDD_FR2_IWF/capability.cfg
   ...    MULTI_LUA_SCRIPT=${CURDIR}/../scripts/TDD_FR2_NIWF/multi_ue_sa_script_new.lua

&{SA_1_UE_3CC}    OVERALL_DL=4800    OVERALL_UL=0    TIME_IN_SECONDS=920    CELL1_UES=1    ID=13
   ...    SE_duration=5    SE_wait=180s    LUA_METHOD=attach_ueto_testmode_profile    parameters=1,1,1,1

@{SKIP_LUA_UPDATE}    SA500UE    1208FF_GBR    1070FF_GBR    1070FF_MIXEDGBR
...    1070FF_VoNR_CDRx_Disabled    CB008406FF_432UES    CB008701_4UES    CB008701_72UES    CB008360_2UES

&{DSS_FDD_40UE}    FIRST_UE=1    END_UE=160
   ...    RATE=1    ID=1-4    SE_DURATION=60    MAX_ACTIVE_UES=40    SCRIPT_COMPLETE_TIME=60
   ...    Cell_Count=1,4    SIB_Timeout=30    ng_link_count=1
   ...    timeout=180    iwf_cells=4
   ...    OVERALL_DL=1144    OVERALL_UL=296
   ...    NO_OF_CELLS=4    EXPECTED_UE_COUNT=160

&{DSS_FDD_152}    FIRST_UE=1    END_UE=608
   ...    RATE=1    ID=5-8    SE_DURATION=200    MAX_ACTIVE_UES=152    SCRIPT_COMPLETE_TIME=60
   ...    Cell_Count=1,4    SIB_Timeout=30
   ...    timeout=180    NO_OF_CELLS=4    EXPECTED_UE_COUNT=608

&{FR2_IWF_NSA_SUE}    cell_index_id=1    FR2_cell_index=8:8    FR2_UE=11
   ...    DL_data_rate=550    UL_data_rate=110    stats_id=11    stats_type=pusch,pdsch
   ...    stats_scell=8-15    EXPECTED_UE_COUNT=1

&{FR2_IWF_NSA_SUE_4CC}    cell_index_id=1    FR2_cell_index=8:11    FR2_UE=11
    ...    stats_id=11    stats_type=pusch,pdsch    stats_scell=8-15    DL_data_rate=2200
    ...    EXPECTED_UE_COUNT=1

&{NSA_8CC_SUE}    entry=TC1_1NSA_8CC_DL_UL    MAX_ACTIVE_UES=1    EXPECTED_UE_COUNT=1
    ...    SCRIPT_COMPLETE=TC1_1NSA_8CC_DL_UL script completed    DIR=BOTH
    ...    Cell_IDs=1,2,3,4,5,6,7,8    Cell_IDs_NSA=1,2,3,4,5,6,7,8    ng_link_count=1    CA_NCA_MODE=CA
    ...    OVERALL_DL=4300    DL_LIMIT=0.95    OVERALL_UL=560    UL_LIMIT=0.95    COUNTER_CHECK=NSA
    ...    NSA_DL_TPUT_COUNTER=M55326C00001   NSA_UL_TPUT_COUNTER=M55326C00002
    ...    NSA_DL_CELL_RLC_COUNTER=M55310C01009   NSA_UL_CELL_RLC_COUNTER=M55310C03009
    ...    WTS_TC_CMD=script file\=test_sequence.lua entry\=TC1_1NSA_8CC_DL_UL

&{NSA_10UEs}    entry=TC3_NSA_nonCA_4CELL_DL_UL    MAX_ACTIVE_UES=40    EXPECTED_UE_COUNT=40
    ...    SCRIPT_COMPLETE=TC3_NSA_nonCA_4CELL_DL_UL script completed    DIR=BOTH
    ...    Cell_IDs=1,2,3,4    Cell_IDs_NSA=1,2,3,4    ng_link_count=1    CA_NCA_MODE=NCA
    ...    OVERALL_DL=2200    DL_LIMIT=0.90    OVERALL_UL=440    UL_LIMIT=0.90    COUNTER_CHECK=NSA
    ...    NSA_DL_TPUT_COUNTER=M55326C00001   NSA_UL_TPUT_COUNTER=M55326C00002
    ...    NSA_DL_CELL_RLC_COUNTER=M55310C01009   NSA_UL_CELL_RLC_COUNTER=M55310C03009
    ...    WTS_TC_CMD=script file\=test_sequence.lua entry\=TC3_NSA_nonCA_4CELL_DL_UL

&{TC1_106SA_DL}    entry=TC1_106SA_DL    MAX_ACTIVE_UES=106    EXPECTED_UE_COUNT=106
    ...    SCRIPT_COMPLETE=TC1_106SA_DL script completed    DIR=DL
    ...    Cell_IDs=1,2,3,4,5,6,7,8    Cell_IDs_SA=1,2,3,4,5,6,7,8    ng_link_count=6    CA_NCA_MODE=NCA
    ...    OVERALL_DL=1060    DL_LIMIT=0.90    OVERALL_UL=0    UL_LIMIT=0    COUNTER_CHECK=SA
    ...    SA_DL_TPUT_COUNTER=M55326C00501    SA_DL_CELL_RLC_COUNTER=M55310C01006
    ...    IWF_ENABLED=False    deployment=SA    NO_OF_CELLS=8    NO_OF_SIBS=6
    ...    ute_ca_variant_dss=PRIVATE_SA_FS_ECPRI_MMWV_TDD_AP_PERF
    ...    MULTI_LUA_SCRIPT=${CURDIR}/../scripts/TDD_FR2_NIWF/multi_ue_sa_script_new.lua
    ...    WTS_COMMANDS_LUA=${CURDIR}/../scripts/TDD_FR2_NIWF/sim_config.lua
    ...    WTS_TEST_SCRIPT=${CURDIR}/../scripts/TDD_FR2_NIWF/test_sequence.lua
    ...    WTS_CAPS_CFG_FILE=${CURDIR}/../scripts/TDD_FR2_NIWF/capability.cfg
    ...    WTS_TC_CMD=script file\=test_sequence.lua entry\=TC1_106SA_DL

#variables for PET SE FDD
${PET_FDD}    False
${PET_TDD}    False
${NO_OF_CELL_LOOO_FDD}    12

${IWF_TDD_FR2}    False
${IWF_FDD_DSS}    False
${IWF_FDD_NON_DSS_CA}    False
${IWF_FDD_NON_DSS}    False
${IWF_FDD_CA_DSS}    False

&{CLOUD_5G_I_LO_AP_LOO-IWF_PRIVATE_SANSA_FS_CPRI_CMWV_FDD_2S_4CC_DSS_AP_PERF}    SUITE_WTS_CFG=basic.lua
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_fdd_sansa_eCpri_cmwv_LO_AP_LOO
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_fdd_sansa_eCpri_cmwv_LO_AP_LOO
   ...    gnb_sm_hardware=ASIL    gnb_cp_hardware=[ABIO]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO, ABIO]
   ...    duplexing=FDD    IWF_FDD_DSS=True
   ...    RF_type=CPRI    wavelength=cmwv    deployment=SANSA
   ...    l1=FS    RU_type=AHLOA    COMPONENT_CARRIER=4    SKIP_WTS_CONFIG_DOWNLOAD=True
   ...    ute_ca_label=CLOUD_5G_I_LO_AP_LOO-IWF    ute_ca_variant=PRIVATE_SANSA_FS_CPRI_CMWV_FDD_2S_4CC_DSS_AP_PERF
   ...    ute_ca_variant_dss=PRIVATE_SANSA_FS_CPRI_CMWV_FDD_2S_4CC_CA_DSS_AP_PERF

&{CLOUD_5G_I_LO_AP_LOO-IWF_PRIVATE_SANSA_FS_CPRI_CMWV_FDD_2S_4CC_AP_PERF}    SUITE_WTS_CFG=basic.lua
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_fdd_sansa_cpri_cmwv_LO_AP_LOO_2S_4CC
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_fdd_sansa_cpri_cmwv_LO_AP_LOO_2S_4CC
   ...    gnb_sm_hardware=ASIL    gnb_cp_hardware=[ABIO]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO, ABIO]    duplexing=FDD
   ...    RF_type=CPRI    wavelength=cmwv    deployment=SANSA    IWF_FDD_NON_DSS=True
   ...    l1=FS    RU_type=AHLOA    COMPONENT_CARRIER=8    SKIP_WTS_CONFIG_DOWNLOAD=True    FDD_IWF_multicell=1
   ...    Sim_Config_Format=True    ng_link_count=1    skip_l2testmode=True    NO_OF_CELLS=8
   ...    ute_ca_label=CLOUD_5G_I_LO_AP_LOO-IWF    ute_ca_variant=PRIVATE_SANSA_FS_CPRI_CMWV_FDD_2S_4CC_AP_PERF
   ...    ute_ca_variant_dss=PRIVATE_SANSA_FS_CPRI_CMWV_1S_4CC_FDD_CA_AP_PERF
   ...    ute_ca_variant_ca_dss=PRIVATE_SANSA_FS_CPRI_CMWV_FDD_MIX_BAND_DL_UL_CA_AP_PERF
   ...    WTS_COMMANDS_LUA=${CURDIR}/../scripts/FDD_nDSS_IWF/sim_config.lua
   ...    WTS_TEST_SCRIPT=${CURDIR}/../scripts/FDD_nDSS_IWF/test_sequence.lua
   ...    WTS_CAPS_CFG_FILE=${CURDIR}/../scripts/PET_SE_IWF/capability.cfg

@{PET_FDD_TAGS}    DSS4UL_VoNR
...    72UE2CELL
@{PET_FDD_12CELLS_TAGS}    DSS4UL_VoNR    72UE_2Cells
@{NON_COMMISSIONING_TAGS}    DSS4UL_VoNR

&{BF_ENABLE_PROFILE1}    profile_id=1    ueBeamIndexInitial=0,1,2,3,4,5    ssbeam_bestbeam=0    ssbeam_rsrp_best=-44
    ...    ssbeam_rsrp_avg=-50

&{BF_ENABLE_PROFILE2}    profile_id=2    ueBeamIndexInitial=1,0,2,3,4,5    ssbeam_bestbeam=1    ssbeam_rsrp_best=-45
    ...    ssbeam_rsrp_avg=-120

&{BF_ENABLE_PROFILE3}    profile_id=3    ueBeamIndexInitial=2,0,1,3,4,5    ssbeam_bestbeam=2    ssbeam_rsrp_best=-50
    ...    ssbeam_rsrp_avg=-125

&{BF_ENABLE_PROFILE4}    profile_id=4    ueBeamIndexInitial=3,0,1,2,4,5    ssbeam_bestbeam=3    ssbeam_rsrp_best=-55
    ...    ssbeam_rsrp_avg=-120

&{BF_ENABLE_PROFILE5}    profile_id=5    ueBeamIndexInitial=4,0,1,2,3,5    ssbeam_bestbeam=4    ssbeam_rsrp_best=-60
    ...    ssbeam_rsrp_avg=-139

&{BF_ENABLE_PROFILE6}    profile_id=6    ueBeamIndexInitial=5,0,1,2,3,4    ssbeam_bestbeam=5    ssbeam_rsrp_best=-65
    ...    ssbeam_rsrp_avg=-70

&{505_Scell}    entry=PET_1116_0msFF_BF_505UEs_scell_addition    timeout=300
    ...    Cell_Count=1,6    SIB_Timeout=30    NO_OF_CELLS=6    UEC_COUNT=6
    ...    SCRIPT_COMPLETE=PET_1116_0msFF_BF_505UEs_scell_addition script completed
    ...    END_UE=505    EXPECTED_SCELL=505

&{CLOUD_5G_I_LO_AP_LOO-IWF_PRIVATE_SANSA_FS_ECPRI_CMWV_TDD_AP_PERFORMANCE}    SUITE_WTS_CFG=basic.lua
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_tdd_sansa_eCpri_cmwv_LO_AP_LOO_P1Perf_IWF
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_tdd_sansa_eCpri_cmwv_LO_AP_LOO_P1Perf_IWF
   ...    gnb_sm_hardware=ASIL    gnb_cp_hardware=[ABIO]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO, ABIO]
   ...    duplexing=TDD    NO_OF_CELLS=3    ng_link_count=1    Sim_Config_Format=True
   ...    RF_type=eCPRI    wavelength=cmwv    deployment=SANSA    skip_l2testmode=True
   ...    l1=FS    RU_type=AEQE    COMPONENT_CARRIER=3    SKIP_WTS_CONFIG_DOWNLOAD=True
   ...    ute_ca_label=CLOUD_5G_I_LO_AP_LOO-IWF    ute_ca_variant=PRIVATE_SANSA_FS_ECPRI_CMWV_TDD_AP_PERFORMANCE
   ...    BSR_TEST=1    BSR_PKG=BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00002
   ...    BSR_PKG_PATH=tools/BSR_Package
   ...    WTS_COMMANDS_LUA=${CURDIR}/../scripts/Perf_TDD_FR1/sim_config.lua
   ...    WTS_TEST_SCRIPT=${CURDIR}/../scripts/Perf_TDD_FR1/test_sequence.lua
   ...    WTS_CAPS_CFG_FILE=${CURDIR}/../scripts/Perf_TDD_FR1/capability.cfg

&{SA_NSA_SUE_2CELL}    entry=TC5_1SA_1SA_PEAK_DL_UL    MAX_ACTIVE_UES=2    EXPECTED_UE_COUNT=2
    ...    OVERALL_DL=3200    OVERALL_UL=400    DL_LIMIT=0.90    UL_LIMIT=0.90    SCRIPT_COMPLETE_TIME=10
    ...    OVERALL_DL_SA=1600    OVERALL_DL_NSA=1600    OVERALL_UL_SA=200    OVERALL_UL_NSA=200
    ...    DIR=BOTH    Cell_IDs=1,3    Cell_IDs_SA=1    Cell_IDs_NSA=3    COUNTER_CHECK=SANSA    CA_NCA_MODE=NCA
    ...    SCRIPT_COMPLETE=TC5_1SA_1SA_PEAK_DL_UL script completed    NO_OF_CELLS=3    BSR_TEST=0
    ...    ute_ca_variant_dss=PRIVATE_SANSA_FS_ECPRI_CMWV_TDD_AP_PERFORMANCE
    ...    WTS_TC_CMD=script file\=test_sequence.lua entry\=TC5_1SA_1SA_PEAK_DL_UL

&{SA_2000_UE_3CELL}    entry=TC4_1000SA_1000NSA_RRC    MAX_ACTIVE_UES=2000    EXPECTED_UE_COUNT=2000
    ...    SCRIPT_COMPLETE=TC4_1000SA_1000NSA_RRC script completed    SCRIPT_COMPLETE_TIME=25
    ...    WTS_TC_CMD=script file\=test_sequence.lua entry\=TC4_1000SA_1000NSA_RRC

&{SA_3CC}    entry=TC1_SUE_3CC_DL    MAX_ACTIVE_UES=1    EXPECTED_UE_COUNT=1
    ...    SCRIPT_COMPLETE=TC1_SUE_3CC_DL script completed
    ...    OVERALL_DL=4800    OVERALL_UL=0    DL_LIMIT=0.95    UL_LIMIT=0
    ...    DIR=DL    Cell_IDs=1,2,3    Cell_IDs_SA=1,2,3    COUNTER_CHECK=SA
    ...    CA_NCA_MODE=CA
    ...    WTS_TC_CMD=script file\=test_sequence.lua entry\=TC1_SUE_3CC_DL

&{SA_20_UE_3CC}    entry=TC2_40SA_3CC_DL_UL    MAX_ACTIVE_UES=40    EXPECTED_UE_COUNT=40
    ...    SCRIPT_COMPLETE=TC2_40SA_3CC_DL_UL script completed
    ...    OVERALL_DL=4800    OVERALL_UL=200    DL_LIMIT=0.90   UL_LIMIT=0.90
    ...    DIR=BOTH    Cell_IDs=1,2,3    Cell_IDs_SA=1,2,3    COUNTER_CHECK=SA    CA_NCA_MODE=CA
    ...    WTS_TC_CMD=script file\=test_sequence.lua entry\=TC2_40SA_3CC_DL_UL

&{SA_40_UE_MIMO}    entry=TC3_40SA_MUMIMO_DL_UL    MAX_ACTIVE_UES=40    EXPECTED_UE_COUNT=40
    ...    OVERALL_DL=3200    OVERALL_UL=200    DL_LIMIT=0.90    UL_LIMIT=0.90
    ...    EXPECTED_UE_COUNT=40    DIR=BOTH    Cell_IDs=2    Cell_IDs_SA=2    COUNTER_CHECK=SA    CA_NCA_MODE=CA
    ...    SCRIPT_COMPLETE=TC3_40SA_MUMIMO_DL_UL script completed
    ...    WTS_TC_CMD=script file\=test_sequence.lua entry\=TC3_40SA_MUMIMO_DL_UL

&{20UE_CA_SA}    entry=TC3_SA_4CC_DL    MAX_ACTIVE_UES=20    EXPECTED_UE_COUNT=20
    ...    SCRIPT_COMPLETE=TC3_SA_4CC_DL script completed    DIR=DL    NO_OF_CELLS=7
    ...    Cell_IDs=1,2,3,4,5,6,7    Cell_IDs_SA=1,2,3,4,5,6,7    CA_NCA_MODE=CA
    ...    OVERALL_DL_SA=1624    DL_LIMIT=0.90    OVERALL_UL=0    UL_LIMIT=0    COUNTER_CHECK=SA
    ...    SA_DL_TPUT_COUNTER=M55326C00501    SA_DL_CELL_RLC_COUNTER=M55310C01006
    ...    WTS_TC_CMD=script file\=test_sequence.lua entry\=TC3_SA_4CC_DL
    ...    WTS_COMMANDS_LUA=${CURDIR}/../scripts/FDD_nDSS_IWF_TC3/sim_config.lua
    ...    WTS_TEST_SCRIPT=${CURDIR}/../scripts/FDD_nDSS_IWF_TC3/test_sequence.lua
    ...    WTS_CAPS_CFG_FILE=${CURDIR}/../scripts/PET_SE_IWF/capability.cfg

&{SA_2F_20UE}    ng_link_count=1    iwf_cells=5    NO_OF_CELLS=5    Cell_Count=1,5
    ...    ID=8    SE_DURATION=60    MAX_ACTIVE_UES=20
    ...    stats_id=81-100    stats_type=pdsch,pusch    stats_scell=0-9    SCRIPT_COMPLETE_TIME=100
    ...    OVERALL_DL=3450    OVERALL_UL=0    DL_LIMIT=0.90    UL_LIMIT=0.90    EXPECTED_UE_COUNT=20

&{SA_3F_20UE}    ng_link_count=1    iwf_cells=5    NO_OF_CELLS=5    Cell_Count=1,5
    ...    ID=5    SE_DURATION=60    MAX_ACTIVE_UES=20
    ...    stats_id=161-180    stats_type=pdsch,pusch    stats_scell=0-9    SCRIPT_COMPLETE_TIME=100
    ...    OVERALL_DL=832    OVERALL_UL=0    DL_LIMIT=0.90    UL_LIMIT=0.90    EXPECTED_UE_COUNT=20

&{SA_1216UE_NON_DSS}    entry=FDD_SA_152UE_8CELL_RRCCONNECTED    timeout=200
    ...    SCRIPT_COMPLETE=TDD_FR1_SA_1216UE_Register script completed
    ...    Cell_Count=1,8    SIB_Timeout=60    NO_OF_CELLS=8
    ...    END_UE=1216    EXPECTED_UE_COUNT=1216

&{SA_SUE_NON_DSS}    entry=TC1_8SA_8CELL_DL_UL    MAX_ACTIVE_UES=8    EXPECTED_UE_COUNT=8
    ...    SCRIPT_COMPLETE=TC1_8SA_8CELL_DL_UL script completed    DIR=BOTH
    ...    Cell_IDs=1,2,3,4,5,6,7,8    Cell_IDs_SA=1,2,3,4,5,6,7,8    CA_NCA_MODE=NCA
    ...    OVERALL_DL=3248    DL_LIMIT=0.95    OVERALL_UL=1680    UL_LIMIT=0.95    COUNTER_CHECK=SA
    ...    SA_DL_TPUT_COUNTER=M55326C00501    SA_UL_TPUT_COUNTER=M55326C00502
    ...    SA_DL_CELL_RLC_COUNTER=M55310C01006    SA_UL_CELL_RLC_COUNTER=M55310C03006
    ...    WTS_TC_CMD=script file\=test_sequence.lua entry\=TC1_8SA_8CELL_DL_UL

&{SA_CA_80UE_NON_DSS}    entry=TC4_SA_MixBand_nonCA_DL    MAX_ACTIVE_UES=80    EXPECTED_UE_COUNT=80
    ...    SCRIPT_COMPLETE=TC4_SA_MixBand_nonCA_DL script completed    DIR=BOTH    NO_OF_CELLS=4
    ...    Cell_IDs=1,2,3,4    Cell_IDs_SA=1,2,3,4    CA_NCA_MODE=NCA
    ...    OVERALL_DL_SA=1940    DL_LIMIT=0.90    OVERALL_UL=930    UL_LIMIT=0.90    COUNTER_CHECK=SA
    ...    SA_DL_TPUT_COUNTER=M55326C00501    SA_UL_TPUT_COUNTER=M55326C00502
    ...    SA_DL_CELL_RLC_COUNTER=M55310C01006    SA_UL_CELL_RLC_COUNTER=M55310C03006
    ...    WTS_TC_CMD=script file\=test_sequence.lua entry\=TC4_SA_MixBand_nonCA_DL
    ...    WTS_COMMANDS_LUA=${CURDIR}/../scripts/FDD_nDSS_IWF_TC4/sim_config.lua
    ...    WTS_TEST_SCRIPT=${CURDIR}/../scripts/FDD_nDSS_IWF_TC4/test_sequence.lua
    ...    WTS_CAPS_CFG_FILE=${CURDIR}/../scripts/PET_SE_IWF/capability.cfg

&{SA_20UE_NON_DSS}    entry=FDD_SA_20UE_8CELL_DL_UL    timeout=200
    ...    SCRIPT_COMPLETE=TDD_FR1_SA_160UE_Register script completed
    ...    Cell_Count=1,8    SIB_Timeout=60    NO_OF_CELLS=8
    ...    OVERALL_DL=406    OVERALL_UL=210    DL_LIMIT=0.90    UL_LIMIT=0.90
    ...    EXPECTED_UE_COUNT=160

&{SANSA_10UE_NON_DSS}    entry=TC2_10SA_10NSA_8CELL_DL_UL    MAX_ACTIVE_UES=160    EXPECTED_UE_COUNT=160
    ...    SCRIPT_COMPLETE=TC2_10SA_10NSA_8CELL_DL_UL script completed    DIR=BOTH    COUNTER_CHECK=SANSA
    ...    Cell_IDs=1,2,3,4,5,6,7,8    Cell_IDs_SA=1,2,3,4    Cell_IDs_NSA=5,6,7,8    CA_NCA_MODE=NCA
    ...    OVERALL_DL_NSA=1624    OVERALL_DL_SA=1350    DL_LIMIT=0.90    OVERALL_UL=840    UL_LIMIT=0.90
    ...    SA_DL_TPUT_COUNTER=M55326C00501    SA_UL_TPUT_COUNTER=M55326C00502
    ...    SA_DL_CELL_RLC_COUNTER=M55310C01006    SA_UL_CELL_RLC_COUNTER=M55310C03006
    ...    NSA_DL_TPUT_COUNTER=M55326C00001   NSA_UL_TPUT_COUNTER=M55326C00002
    ...    NSA_DL_CELL_RLC_COUNTER=M55310C01009   NSA_UL_CELL_RLC_COUNTER=M55310C03009
    ...    WTS_TC_CMD=script file\=test_sequence.lua entry\=TC2_10SA_10NSA_8CELL_DL_UL

&{SA_40_5CC}    RATE=2    ID=28    SE_DURATION=80    MAX_ACTIVE_UES=40    SCRIPT_COMPLETE_TIME=80
    ...    OVERALL_DL=5000    OVERALL_UL=248    DL_LIMIT=0.90    UL_LIMIT=0.90
    ...    Cell_Count=1,5    EXPECTED_UE_COUNT=40
    ...    Cell_IDs=1,2,3,4,5    Cell_IDs_SA=1,2,3,4,5    COUNTER_CHECK=SA    DIR=BOTH
    ...    SCRIPT_COMPLETE=SA_40_UE_5CC

&{SA_SUE_5CC}    RATE=1    ID=13    SE_DURATION=10    MAX_ACTIVE_UES=1    SCRIPT_COMPLETE_TIME=10
    ...    OVERALL_DL=4500    OVERALL_UL=250    DL_LIMIT=0.95    UL_LIMIT=0.95
    ...    Cell_Count=1,5    EXPECTED_UE_COUNT=1

&{SA_SUE_6CC}    RATE=1    ID=17   SE_DURATION=10    MAX_ACTIVE_UES=1    SCRIPT_COMPLETE_TIME=10
    ...    OVERALL_DL=4300    OVERALL_UL=399    DL_LIMIT=0.95    UL_LIMIT=0.95
    ...    Cell_Count=1,6    EXPECTED_UE_COUNT=1    BSR_TEST=0

&{SA_UE_6CC}    RATE=1    ID=67   SE_DURATION=10    MAX_ACTIVE_UES=1    SCRIPT_COMPLETE_TIME=10
    ...    OVERALL_DL=4300    OVERALL_UL=295    DL_LIMIT=0.95    UL_LIMIT=0.95
    ...    Cell_Count=1,6    EXPECTED_UE_COUNT=1

&{CLOUD_5G_I_LOO_AP_LOOO-IWF_PRIVATE_SANSA_FS_CMWV_CPRI_FDD_ECPRI_5CC_TDD_AP_PERF}    SUITE_WTS_CFG=basic.lua
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_tdd_fdd_sansa_eCpri_cpri_cmwv_LOO_AP_LOOO_P1Perf_IWF
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_tdd_fdd_sansa_eCpri_cpri_cmwv_LOO_AP_LOOO_P1Perf_IWF
   ...    gnb_sm_hardware=ASIL    gnb_cp_hardware=[ABIO, ABIO]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO, ABIO, ABIO]
   ...    duplexing=TDD+FDD
   ...    RF_type=CPRI+eCPRI    wavelength=cmwv    deployment=SANSA
   ...    l1=FS    RU_type=[AEQE, AHFII]    COMPONENT_CARRIER=5    SKIP_WTS_CONFIG_DOWNLOAD=True
   ...    ute_ca_label=CLOUD_5G_I_LOO_AP_LOOO-IWF    ute_ca_variant=PRIVATE_SANSA_FS_CMWV_CPRI_FDD_ECPRI_5CC_TDD_AP_PERF
   ...    ute_ca_variant_dss=PRIVATE_SANSA_FS_CMWV_CPRI_FDD_ECPRI_6CC_TDD_AP_PERF
   ...    BSR_TEST=1    BSR_PKG=BSR_AVQQA_6_H3H3_ALN60_ARP60_P00_COV3840_00444_00001
   ...    BSR_PKG_PATH=tools/BSR_Package

##########L3Call_ECPRI72E_IWF_Variables_Section
${CA_NCA_MODE}    NON_CA
${IWF_TDD_ECPRI72E}    False
${ute_ca_variant_tc4}    False
${skip_l2testmode}    False
${gnb_id}    2
${ue_nr_stats_lower_limit}   0.90
${ue_nr_stats_upper_limit}   1.05
${UE_Count_Threshold}    1
${WTS_CFG_LOAD_CMD}    cfg file=/opt/wts/latest/sim_config.lua entry=run_configuration(sansa,84000)
${WTS_X2_LINK_CMD}    script file\=/opt/wts/latest/test_sequence.lua entry\=x2_link()
${WTS_COMMANDS_LUA}    ${CURDIR}/../scripts/Perf_TDD_ECPRI72E/sim_config.lua
${WTS_CAPS_CFG_FILE}    ${CURDIR}/../scripts/Perf_TDD_ECPRI72E/capability.cfg
${WTS_TEST_SCRIPT}    ${CURDIR}/../scripts/Perf_TDD_ECPRI72E/test_sequence.lua
${Sim_Config_Format}    False
${SCRIPT_COMPLETE_TIME}    10
${UEPROXY_CMD}    script file\=/opt/wts/latest/test_sequence.lua entry\=ue_proxy_loglevel()

&{CLOUD_5G_I_MP_AP_LO-IWF_PRIVATE_SANSA_ECPRI72E_CMWV_TDD_AP_PERF}    SUITE_WTS_CFG=basic.lua
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_tdd_sansa_ecpri72e_cmwv_MP_AP_LO_P1Perf_IWF
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_tdd_sansa_ecpri72e_cmwv_MP_AP_LO_P1Perf_IWF
   ...    gnb_sm_hardware=ASIM    gnb_cp_hardware=[ABIP]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO]
   ...    duplexing=TDD    skip_l2testmode=True
   ...    RF_type=eCPRI    wavelength=cmwv    deployment=SANSA
   ...    l1=FS    RU_type=AVQL    COMPONENT_CARRIER=1    SKIP_WTS_CONFIG_DOWNLOAD=True
   ...    IWF_TDD_ECPRI72E=True   NO_OF_CELLS=2    ng_link_count=1
   ...    ute_ca_label=CLOUD_5G_I_MP_AP_LO-IWF    ute_ca_variant=PRIVATE_SANSA_ECPRI72E_CMWV_TDD_AP_PERF
   ...    ute_ca_variant_tc4=PRIVATE_SANSA_ECPRI72E_CMWV_TDD_50MHz_AP_PERF

&{SUE_SANSA_ECPRI72E}    entry=TC1_SA_NSA_DL_UL    MAX_ACTIVE_UES=2    EXPECTED_UE_COUNT=2
    ...    SCRIPT_COMPLETE=TC1_SA_NSA_DL_UL script completed    DIR=BOTH
    ...    Cell_IDs=1,2    Cell_IDs_SA=1    Cell_IDs_NSA=2    NO_OF_CELLS=2    ng_link_count=1
    ...    OVERALL_DL=1600    OVERALL_UL=220    DL_LIMIT=0.95    UL_LIMIT=0.95
    ...    COUNTER_CHECK=SANSA
    ...    SA_DL_TPUT_COUNTER=M55326C00501    SA_UL_TPUT_COUNTER=M55326C00502
    ...    NSA_DL_TPUT_COUNTER=M55326C00001   NSA_UL_TPUT_COUNTER=M55326C00002
    ...    SA_DL_CELL_RLC_COUNTER=M55310C01006    SA_UL_CELL_RLC_COUNTER=M55310C03006
    ...    NSA_DL_CELL_RLC_COUNTER=M55310C01009   NSA_UL_CELL_RLC_COUNTER=M55310C03009
    ...    WTS_TC_CMD=script file\=test_sequence.lua entry\=TC1_SA_NSA_DL_UL

&{40UE_SA_ECPRI72E}    entry=TC2_SA_MUMIMO_DL_UL    timeout=200    MAX_ACTIVE_UES=40    EXPECTED_UE_COUNT=40
    ...    SCRIPT_COMPLETE=TC2_SA_MUMIMO_DL_UL script completed    DIR=BOTH
    ...    Cell_IDs=1    Cell_IDs_SA=1    SIB_Timeout=60    NO_OF_CELLS=2    ng_link_count=1
    ...    OVERALL_DL=3200    OVERALL_UL=220    DL_LIMIT=0.90    UL_LIMIT=0.90
    ...    COUNTER_CHECK=SA    SA_UE_ID_RANGE=2,41
    ...    SA_DL_TPUT_COUNTER=M55326C00501    SA_UL_TPUT_COUNTER=M55326C00502
    ...    NSA_DL_TPUT_COUNTER=M55326C00001   NSA_UL_TPUT_COUNTER=M55326C00002
    ...    SA_DL_CELL_RLC_COUNTER=M55310C01006    SA_UL_CELL_RLC_COUNTER=M55310C03006
    ...    NSA_DL_CELL_RLC_COUNTER=M55310C01009   NSA_UL_CELL_RLC_COUNTER=M55310C03009
    ...    WTS_TC_CMD=script file\=test_sequence.lua entry\=TC2_SA_MUMIMO_DL_UL

&{2000UE_SANSA_ECPRI72E}    entry=TC3_SANSA_500UEs_DL_UL    timeout=200    MAX_ACTIVE_UES=2000    EXPECTED_UE_COUNT=2000
    ...    SCRIPT_COMPLETE=TC3_SANSA_500UEs_DL_UL script completed
    ...    Cell_IDs=1,2    SIB_Timeout=60    NO_OF_CELLS=2    ng_link_count=1
    ...    WTS_TC_CMD=script file\=test_sequence.lua entry\=TC3_SANSA_500UEs_DL_UL

&{SUE_PER_CELL_SANSA_ECPRI72E}    entry=TC4_SANSA_SUE_DL_50MHz    MAX_ACTIVE_UES=4    EXPECTED_UE_COUNT=4
    ...    SCRIPT_COMPLETE=TC4_SANSA_SUE_DL_50MHz script completed    DIR=DL
    ...    Cell_IDs=1,2,3,4    Cell_IDs_SA=1,2    Cell_IDs_NSA=3,4    NO_OF_CELLS=4
    ...    ng_link_count=1
    ...    OVERALL_DL=1600    DL_LIMIT=0.95    OVERALL_UL=0    UL_LIMIT=0    COUNTER_CHECK=SANSA
    ...    WTS_TC_CMD=script file\=test_sequence.lua entry\=TC4_SANSA_SUE_DL_50MHz
    ...    WTS_COMMANDS_LUA=${CURDIR}/../scripts/Perf_TDD_ECPRI72E_50MHz/sim_config.lua
    ...    ute_ca_variant_tc4=PRIVATE_SANSA_ECPRI72E_CMWV_TDD_50MHz_AP_PERF
    ...    WTS_TEST_SCRIPT=${CURDIR}/../scripts/Perf_TDD_ECPRI72E_50MHz/test_sequence.lua
    ...    WTS_CAPS_CFG_FILE=${CURDIR}/../scripts/Perf_TDD_ECPRI72E_50MHz/capability.cfg
############L3Call_ECPRI72E_IWF_Variables_Section_End

##########L3Call_ECPRI72E_IWF_Stream2_Variables_Section
&{CLOUD_5G_I_MPP_AP_LOO-IWF_PRIVATE_SA_ECPRI72E_CMWV_TDD_100MHz_AP_PERF}    SUITE_WTS_CFG=basic.lua
   ...    SUITE_CFG_DIR_tmp=${CURDIR}/resources/fs_tdd_sa_ecpri72e_cmwv_MPP_AP_LOO_P1Perf_IWF
   ...    DURATION=${duration}    EXCLUDE_LOGS=0    apConfiguration=fs_tdd_sa_ecpri72e_cmwv_MPP_AP_LOO_P1Perf_IWF
   ...    gnb_sm_hardware=ASIM    gnb_cp_hardware=[ABIP, ABIP]    ap_sm_hardware=ASIL    ap_cp_hardware=[ABIO, ABIO]
   ...    duplexing=TDD    skip_l2testmode=True
   ...    RF_type=eCPRI    wavelength=cmwv    deployment=SA
   ...    l1=FS    RU_type=AVQL    COMPONENT_CARRIER=1    SKIP_WTS_CONFIG_DOWNLOAD=True
   ...    IWF_TDD_ECPRI72E=True   NO_OF_CELLS=6    ng_link_count=1    Sim_Config_Format=True
   ...    ute_ca_label=CLOUD_5G_I_MPP_AP_LOO-IWF    ute_ca_variant=PRIVATE_SA_ECPRI72E_CMWV_TDD_100MHz_AP_PERF
   ...    WTS_COMMANDS_LUA=${CURDIR}/../scripts/Perf_TDD_ECPRI72E_Stream2/sim_config.lua
   ...    WTS_TEST_SCRIPT=${CURDIR}/../scripts/Perf_TDD_ECPRI72E_Stream2/test_sequence.lua
   ...    WTS_CAPS_CFG_FILE=${CURDIR}/../scripts/Perf_TDD_ECPRI72E_Stream2/capability.cfg

&{SUE_SA_ECPRI72E_DL}    entry=S2TC1_SA_SUE_DL_6Gbps    MAX_ACTIVE_UES=1    EXPECTED_UE_COUNT=1
    ...    SCRIPT_COMPLETE=S2TC1_SA_SUE_DL_6Gbps script completed    DIR=DL
    ...    Cell_IDs=1,2,3,4,5,6    Cell_IDs_SA=1,2,3,4,5,6    NO_OF_CELLS=6    ng_link_count=1    CA_NCA_MODE=CA
    ...    OVERALL_DL=6000    DL_LIMIT=0.95    OVERALL_UL=0    UL_LIMIT=0    COUNTER_CHECK=SA
    ...    SA_DL_TPUT_COUNTER=M55326C00501    SA_DL_CELL_RLC_COUNTER=M55310C01006,M55310C01007
    ...    WTS_TC_CMD=script file\=test_sequence.lua entry\=S2TC1_SA_SUE_DL_6Gbps

&{SUE_SA_ECPRI72E_UL}    entry=S2TC2_SA_SUE_UL_220Mbps    MAX_ACTIVE_UES=1    EXPECTED_UE_COUNT=1
    ...    SCRIPT_COMPLETE=S2TC2_SA_SUE_UL_220Mbps script completed    DIR=UL
    ...    Cell_IDs=3,4    Cell_IDs_SA=3,4    NO_OF_CELLS=6    ng_link_count=1   CA_NCA_MODE=CA
    ...    OVERALL_DL=0    DL_LIMIT=0    OVERALL_UL=220    UL_LIMIT=0.95    COUNTER_CHECK=SA
    ...    SA_UL_TPUT_COUNTER=M55326C00502    SA_UL_CELL_RLC_COUNTER=M55310C03006
    ...    WTS_TC_CMD=script file\=test_sequence.lua entry\=S2TC2_SA_SUE_UL_220Mbps

&{S2TC3_SA_MUE_UL_440Mbps}    entry=S2TC3_SA_MUE_UL_440Mbps    MAX_ACTIVE_UES=40    EXPECTED_UE_COUNT=40
    ...    SCRIPT_COMPLETE=S2TC3_SA_MUE_UL_440Mbps script completed    DIR=UL
    ...    Cell_IDs=3,4    Cell_IDs_SA=3,4    NO_OF_CELLS=6    ng_link_count=1   CA_NCA_MODE=CA
    ...    OVERALL_DL=0    DL_LIMIT=0    OVERALL_UL=440    UL_LIMIT=0.90    COUNTER_CHECK=SA
    ...    SA_UL_TPUT_COUNTER=M55326C00502    SA_UL_CELL_RLC_COUNTER=M55310C03006
    ...    WTS_TC_CMD=script file\=test_sequence.lua entry\=S2TC3_SA_MUE_UL_440Mbps

&{S2TC4_SA_MUE_DL_6300M}    entry=S2TC4_SA_MUE_DL_6300Mbps    MAX_ACTIVE_UES=40    EXPECTED_UE_COUNT=40
    ...    SCRIPT_COMPLETE=S2TC4_SA_MUE_DL_6300Mbps script completed    DIR=DL
    ...    Cell_IDs=1,2,3,4,5,6    Cell_IDs_SA=1,2,3,4,5,6    NO_OF_CELLS=6    ng_link_count=1   CA_NCA_MODE=CA
    ...    OVERALL_DL=6300    DL_LIMIT=0.90    OVERALL_UL=0    UL_LIMIT=0    COUNTER_CHECK=SA
    ...    SA_DL_TPUT_COUNTER=M55326C00501    SA_DL_CELL_RLC_COUNTER=M55310C01006,M55310C01007
    ...    WTS_TC_CMD=script file\=test_sequence.lua entry\=S2TC4_SA_MUE_DL_6300Mbps
############L3Call_ECPRI72E_IWF_Stream2_Variables_Section_End
