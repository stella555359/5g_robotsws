*** Settings ***

Documentation
...   author: T02
...   contact: T02

*** Variables***

###ca case####
${NRcell1_counters_path1}=           BTS']['MRBTS-911']['NRBTS-911']['NRCELL-1']['NCADU
${LTE_pcell_counters_path}=      BTS']['MRBTS-911']['LNBTS-912']['LNCEL-9117']['MCC-404']['MNC-99']['LTE_UE_Quantity
@{3CC_Countervalues}=    M55316C03002
@{2CC_Countervalues}=    M55316C03001    M55316C09000    M55118C05507    M55118C05508
@{LTE5270_7CC_counters}=    M8051C190
###this is a comment saying below are the counters to validate 2CC in DL
####  M55118C05508  Sum of CA UEs in the current cell configured as an SCell with 1 configured SCell in DL   NRCELL-2
####  M55118C05507  Sum of CA UEs in the current cell configured as PCell with 1 configured SCell in DL      NRCELL-7
####  M55316C03001   P(S)Cell UEs with 1 activated SCell in DL                                               NRCELL-7
####  M55316C03002   P(S)Cell UEs with 2 activated SCell in DL                                               NRCELL-7
####  M55316C09000   Number of successful SCell activations                                                  NRCELL-2

####Maximum number of UEs with six configured SCells (M8051C188)
####Maximum number of UEs with six activated SCells (M8051C190)
####Average number of UEs with six activated Scells (M8051C178)
${ncac}=              M55118C07004
${rsacu}=             M55138C02501
${rsadu}=             M55139C01501

${TEST_LOG_DIRECTORY}                     /home/ute/Dcap
@{ports_fjt}=                   ${5}    ${6}    ${7}    ${8}
@{ports_ahpmda}=                ${9}    ${10}    ${11}    ${12}
@{ports_azqp}=                  ${13}    ${14}    ${15}    ${16}
@{cavalues0}=   90dB    90dB   90dB    90dB
@{cavalues1}=   0dB    0dB   0dB    0dB
@{cavalues2}=   30dB    30dB   30dB    30dB
@{cavalues3}=   20dB    20dB   20dB    20dB
@{cavalues4}=   0dB    0dB   0dB    0dB
@{cavalues5}=   0dB    0dB   0dB    0dB
@{at_channel_ahpmda}=    ${9}    ${10}    ${11}    ${12}
@{at_channel_azqp}=      ${13}    ${14}    ${15}    ${16}

##UE##
@{UE_alias}=                 UE1
@{capabilities}=             Legacy_1
@{UE_alias3}=                 UE3
@{capabilities3}=             Legacy_3
@{throughput_dl}             250
@{direction_dl}=             dl
@{deviation_dl}=             90
@{throughput_ul}             90
@{udpcalltype}=              UDP
@{tcpcalltype}=              TCP
@{direction_ul}=             ul
@{deviation_ul}=             80
@{Acceptable_Peak_tp_DL} =   80
@{Acceptable_Peak_tp_UL} =   20
${interval}=                 30s
${rep_values}
@{dt_name}=                 iperf_dl_test
@{UE_alias2}=               UE_2
@{capabilities2}=           Legacy_2
@{duration}=                120s

##Attenuation##
${attenuator_host}=          10.45.153.204
${attenuator_port}=          ${3001}
@{ports}=                    ${5}    ${6}    ${7}    ${8}
@{at_channel_AHHB}=          ${1}    ${2}    ${3}    ${4}
@{ports_AHHB}=               ${1}    ${2}    ${3}    ${4}
@{valueslistofports}         ${values}     ${values1}      ${values2}     ${values3}     ${values4}      ${values30}
...                          ${values32}     ${values35}      ${values37}     ${values40}     ${values8}      ${values9}
...                          ${values10}     ${values0}
@{valueslistofports_6620}    ${valuesA}     ${values}     ${values1}      ${values2}     ${values3}     ${values4}      ${values30}
...                          ${values4}      ${values40}     ${values8}     ${values0}
@{valueslistofports_907}     ${values20}    ${values30}      ${values35}      ${values40}     ${values43}     ${values46}      ${values47}
@{at_channel}=               ${5}    ${6}    ${7}    ${8}
@{values0}=     0dB    0dB   0dB    0dB
@{values}=      5dB    5dB   5dB    5dB
@{valuesA}=     20dB    20dB   20dB    20dB
@{valuesmax}=   90dB     90dB    90dB    90dB
@{values1}=     10dB    10dB   10dB    10dB
@{values2}=     15dB    15dB   15dB    15dB
@{values3}=     23dB    23dB   23dB    23dB
@{values4}=     25dB    25dB   25dB    25dB
@{values32}=    32dB    32dB   32dB    32dB
@{values37}=    37dB    37dB   37dB    37dB
@{values8}=     42dB    42dB   42dB    42dB
@{values9}=     45dB    45dB   45dB    45dB
@{values20}=    20dB    20dB   20dB    20dB
@{values30}=    30dB    30dB   30dB    30dB
@{values35}=    35dB    35dB   35dB    35dB
@{values40}=    40dB    40dB   40dB    40dB
@{values43}=    43dB    43dB   43dB    43dB
@{values46}=    46dB    46dB   46dB    46dB
@{values47}=    47dB    47dB   47dB    47dB
@{values10}=    50dB    50dB   50dB    50dB

#####DCAP Server Details################
${username}         utfuser
${password}         utfadmin!
${BTS_MPLANE}=      10.53.188.246
${bts_username}		Nemuadmin
${bts_password}		Nokia@123
${DCAP_host}        10.41.209.118
${port}              443
${dcap_password}=   utfadmin!
${dcapuser}=        utfuser
${voice_call_TC}=           VoLTE_Server_Call
&{BTS_INFO}                 host=${BTS_M_plane_ip}	port=443
@{enb_custom_filters}       condor4gTti    cp_4g    controlPlane4g
@{bts_custom_filter}        immediateSnapshot    scf
@{collection_timing}        Immediate       TraceEnd
${Default_DCAP_duration}    30
${dcap_log_timeout}         600
${emil_profile}             ${emil_path}//profiles//5G
${at_vendor}                TOPYOUNG
${at_model}                 TAS_16T16_0_2G6_90_1S_DEJS
@{data_transfer_protocol}   UDP
${Proxy_path}               C:\Users\inbabtslabuser\Desktop\Tools\Ultracaller\ultracaller3_proxy29_win
${TEST NAME}=               Tput_Counters
${WebEM IP}         https://192.168.255.129:443
${ADMIN_ALIAS}=     admin_1
${BTS_ADDRESS}      192.168.255.129
${USE_SSL}          True
${Rmod3}=           MRBTS-911/EQM-1/APEQM-1/RMOD-3
${Cell1_dist}=      MRBTS-911/LNBTS-912/LNCEL-9117
${CONFIGURATION}=    10_2_SG1ORAN911-912
${class_name}=       LNCEL
${timeout}=          300
${expected_state}=   regex"Enabled|enabled"
${sw_info}
${testline}=    10_2_SG1ORAN911-912
${NrcellId}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-911/NRCELL_R-2
${TestModel}=   TM1_1
@{BeamPatternId} =	0    0
${polarization}=    P_plus45_or_0
${powerBackoff}=    0
${ruMode}=          NR_Only
${PhyCellId}=       201
${pmax}=            38
${nrarfcnDl}=       366000
${nrarfcnUl}=	    347000
${MIMOrank}=        1
${codebook2antports}=      0
${i11Codebook4antports}=   0
${i2codebook4antports}=    0
${i13codebook4antports}=   0
@{Required_bts_status} =   Test    OnAir
${log_dir}=                /tmp/btslog2
${name}=                   btslog
${new_timeout}=            2000s
${cell_timeout}=           120s
${dist_name_cell2}=        /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-911/NRCELL_R-2
${user}=                   toor4nsn
#${BTS_ssh_password}=       oZPS0POrRieRtu
${BTS_ssh_password}=       nemuuser
${target_file_name}=       coredump1.log
${max_num_carr}=                    2
${min_power_per_pa_antenna}=        37.5
${max_power_per_pa_antenna}=        49.5
${max_power_per_antenna}=           45.6
${min_power_per_antenna}=           23.1
${max-gain1}=                       43.01
${max-gain2}=                       44.8
${max-gain3}=                       46.02
${min_supported_frequency_dl1}=       2110000000
${min_supported_frequency_ul1}=       1920000000
${min_supported_frequency_dl2}=       1805000000
${min_supported_frequency_ul2}=       1710000000
${min_supported_frequency_dl3}=       2170000000
${min_supported_frequency_ul3}=       1980000000
${min_supported_frequency_dl4}=       1880000000
${min_supported_frequency_ul4}=       1785000000
${min_carrier_bandwidth_dl1}=         10000000
${min_carrier_bandwidth_ul1}=         10000000
${min_carrier_bandwidth_dl2}=         10000000
${min_carrier_bandwidth_ul2}=         10000000
${min_carrier_bandwidth_dl3}=         20000000
${min_carrier_bandwidth_ul3}=         20000000
${min_carrier_bandwidth_dl4}=         20000000
${min_carrier_bandwidth_ul4}=         20000000
${GNB_ID}=                            911
${managed_object}=                    PLMN-PLMN/MRBTS-${GNB_ID}
${var}=                               3
${mo_id}=                             PLMN-PLMN/MRBTS-911/NRBTS-911/NRCELL-1
${NRBTS_distname}                     MRBTS-911/NRBTS-911
${DELTA_FILE}                         ${CURDIR}/resources/config/mobility_scf.xml
@{cells}                              1   2   6   7
${fm_cm_itsmwas_hostIp}=   	10.43.48.16
${nwi3_hostIp}=            	10.43.48.16
${clsservices_hostIp}=     	10.43.48.21
${clsdb_hostIp}=           	10.43.48.22
${NETACT_NAME}=            	srnclab1042
${WEB_URL}=                	https://${NETACT_NAME}lbwas.srnblr.nsn-rdnet.net/authentication/Login
${netactUSERNAME}=              test2
${netactPASSWORD}=              Qwer_1234
${node_Username_fmwas}=	        omc
${node_password_fmwas}=         Medsql!_1893
${PLAN_DESCRIPTION}=            T02NetactCasePlan

##New VAriables##
${rootseqindex_value}               62
${param_rootseqindex}               rootSeqIndex
${value_enabled}                    Enabled
${value_true}=                      true
${value_false}=                     false
${distname_lncelfdd}      MRBTS-911/LNBTS-912/LNCEL-9117/LNCEL_FDD-0
${paramter_catm}          actCatM
${param_autolock}         enableAutoLock
${param_grflshdn}         enableGrflShdn
${param_ttibundling}      actTtiBundling
${scf_lte907}             BTS911_FJTOnly_LTE9117.xml
${BTS911_max_config_scf}      BTS911_scf_max_config_LTE_NR.xml
${scf_b1}                 b1.xml
${scf_b1b3}               b1_b3.xml
${scf_OFEGSA}            scf_MRBTS-911_only_OFEGSA_NR.xml
${scf_catm}               9462_catM_ptc_reconditions.xml
${scf_file_3cc}           3cc_ca_case_nr.xml
${scf_lte830}             LTE830.xml
${param_modscheme}        actModulationSchemeDl
${param_modschemeUL}      actModulationSchemeUL
${value_qam}              256QAM
${param_actUlLnkAdp}      actUlLnkAdp
${param_actUlLnkAdp_value}      fUlLa
${param_mcs}                    actUlsOptimizePrbMcs
${RMOD1_distname}               MRBTS-911/EQM-1/APEQM-1/RMOD-1
${RMOD4_distname}               MRBTS-911/EQM-1/APEQM-1/RMOD-4
${RMOD5_distname}               MRBTS-911/EQM-1/APEQM-1/RMOD-5
${RMOD6_distname}               MRBTS-911/EQM-1/APEQM-1/RMOD-6
${shutcell_plan}                plan_shutcell_t02
${shutcellBackup}               bkp_plan_shutcell_t02
${unlockcell_plan}              plan_unlockcell_t02
${unlockBackup}                 bkp_plan_unlockcell_t02
${celladministrativeState1}    1
${celladministrativeState2}    2
${shut_window}                 60
${shutstep}                    10
${value_actGrflShdn}           actGrflShdn
${value_shutdownWindow}        shutdownWindow
${value_shutdownStepAmount}    shutdownStepAmount

##FaultVariables##
${fault_id1}=     7312
${fault_id2}=     4655
${fault_id3}=     61524
${fault_id4}=     4654
${fault_id5}=     61652
${fault_id6}=     61649
${fault_id7}=     4340
${alarm_id1}=      7115
${alarm_id2}=      7220
${alarm_id3}=      7220
${alarm_id4}=      7220
${alarm_id5}=      7220
${alarm_id6}=      7220
${alarm_id7}=      7115
${fault_name1}=    NgGnbInitFullReset
${fault_name2}=    Service account root access is enabled
${fault_name3}=    SSH enabled
${fault_name4}=    Ethernet port security is disabled
${fault_name5}=    R&D Service Port enabled
${fault_name6}=    LMP access via port 443

##Variables##
${ip_pdu}=                          10.45.153.163
${ip_pdu1}=                         10.58.242.70
${asim}=                            5
${ru}=                              8
${time}                    		30
${connection}              		default
${BTS_path}                 		/home/ute/results
@{antlList}
@{radios}                   		${3}
@{cellsnum}
${BBmod}                            MRBTS-911/EQM-1/APEQM-1/CABINET-1/BBMOD-2
${Rmod}                             MRBTS-911/EQM-1/APEQM-1/RMOD-3
@{miOranEpeStats_CounterList}=	    M40021C0    M40021C1     M40021C2     M40021C3     M40021C4     M40021C5
${miOranEpeStats_name}=     	    miOranEpeStats
${windowStatsValue}=       	        5min
${windowStatsValue_disable}=        disabled
${NetconfFileName}=                 RMOD_L-1_NetconfRpcMessageTrace.log
${distname_pmmnl}=            	    MRBTS-911/MNL-1/MNLENT-1/PMMNL-1
${distname_nrpmrnl}=          	    MRBTS-911/NRBTS-911/NRPMRNL-1
@{EPE_capabilities}=                POWER
${miOranEpeStats_Counter}=          BTS']['MRBTS-911']['EQM-1']['APEQM-1']['RMOD-3']['OEPE
@{active}=                          true    false
${operation_value}=                 update
${commonSCFpath}=                   /home/ute/robotws/testsuite/Bangalore/ORAN/SG02/CRT2Suite/Fileconfiguration
${CONFIG_PATH}=   ./testsuite/Bangalore/ORAN/SG02/CB008796/configurations/ta_ue_config.yaml
${SCF_PATH}=      ./testsuite/Bangalore/ORAN/SG02/CB008796/configurations/ANT_remap_LTE.json
${scf_path2}=     ./testsuite/Bangalore/ORAN/SG02/CB008796/configurations/ANT_remap_modifying_LTE.json
${UE_PC_IP}                 10.45.150.187
${BTS_M_plane_ip}           10.58.239.6
${Windows_user}             inbabtslabuser
${Windows_pass}             BT5l@bus3rl0g1n
${emil_path}                C://Emil
${uepc_Log_path}            C://Users//inbabtslabuser//Documents//Automation_logs
${UE_file}					ta_ue_config.yaml
${i}                        ${0}
${secure}                   True
${rd_version}               dcapv3
${filter_message_file}    /home/ute/robotws/testsuite/Bangalore/ORAN/SG02/CRT2Suite/Fileconfiguration/
${Parameter_name_a}    rootSeqIndex
${Value_a}             62      # Provide value between 60 to 100
${New_Element_MO_b}    MRBTS-911/MNL-1/MNLENT-1/SYNC-1/TIME-1
${Parameter_name_b}    timeZone
${Value_b1}            (GMT-10) HST
${Value_b2}            (GMT+5.5) Asia/Kolkata
${New_Element_MO_c}    MRBTS-911/LNBTS-912/LNCEL-9117
${Parameter_name_c}    administrativeState
${Value_c}             shutting down
${New_Element_MO_d}    MRBTS-911/LNBTS-912/LNCEL-9117
${Parameter_name_d}    administrativeState
${Value_d}             unlocked
${New_Element_MO_dis}    MRBTS-911/LNBTS-912
${Parameter_name_dis}    enableGrflShdn
${Value_dis}           Disabled
${voice_call_TC1}=     BTS942_Voice_Call
@{cell_alias}=         241153
${LNCEL_ID}=           9117
${DIST_NAME}=          PLMN-PLMN/MRBTS-911
${grflcellshtn}        RromGracefulCellShutdown

#####ALARMS#####
@{ALLOWED_ALARMS}    4654    61524    61652    61649    4655    4079
&{4644}     fault_id=4644
...         alarm_id=7220
...         alarm_severity=Minor
...         fault_name="Ethernet port security is disabled"
...         notifier=[LTE_NR_7CC_Bangalore] MRBTS-911/EQM_R-4/APEQM_R-1/CABINET_R-1/SMOD_R-1
&{1922}     fault_id=1922
...         alarm_id=7240
...         alarm_severity=Minor
...         alarm_resource=[1] MRBTS-911/EQM-1/APEQM-1/RMOD-3
...         fault_name="EFaultId_FrTemperatureTooLow"
&{1924_allowed}     fault_id=1924
...         alarm_id=7115
...         alarm_severity=Minor
...         notifier=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
...         fault_name="EFaultId_FrConfigurationFileCorrupted"
&{4720}     fault_id=4720
...         alarm_id=7115
...         alarm_severity=Warning
...         alarm_resource=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
...         fault_name="EFaultId_HwValidationContentMismatchWithOruCapabilitiesAl"
&{4692}     fault_id=4692
...         alarm_id=7116
...         alarm_severity=Critical
...         notifier=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
...         fault_name="EFaultId_NoExternalSynchronizationSourceAl"
&{1841}     fault_id=1841
...         alarm_id=7116
...         alarm_severity=Critical
...         alarm_resource=[1] MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1
...         fault_name="EFaultId_UnitFaultyAl"
&{7305_allowed}     fault_id=7305
...         alarm_id=7107
...         alarm_severity=Critical
...         fault_name="NG SCTP setup fail"
...         notifier=
&{7107_allowed}     fault_id=7107
...         alarm_id=7114
...         alarm_severity=regex"Critical|Minor|Major"
...         fault_name="Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability"
...         notifier=
&{7523_allowed}     fault_id=7523
...         alarm_id=7115
...         alarm_severity=Critical
...         fault_name="Cell Activation timeout at gNB-DU"
...         notifier=
&{7304_allowed}     fault_id=7304
...         alarm_id=7107
...         alarm_severity=Critical
...         fault_name="NG SCTP endpoint broken"
...         notifier=
&{7308_allowed}     fault_id=7308
...         alarm_id=7107
...         alarm_severity=Major
...         fault_name="Transport layer connection failure in X2 interface"

## #CATM ###
${UE_CATM}=                        CatM
${UE_CATM2}=                       catm2
${UE_CAPABILITIES_CATM}=           CATM
${UE_CAPABILITIES_CATM2}=          catm2
${CATM_UE_CAPABILITIES}=           catm2
${CALL_DL_BANDWIDTH_CATM}=         60Kbits/sec
${CALL_DL1_BANDWIDTH_CATM}=        8Kbits/sec
${CALL_DL3_BANDWIDTH_CATM}=        12Kbits/sec
${CALL_DL_BANDWIDTH_CATMM}=        76Kbits/sec
${CALL_UL_BANDWIDTH_CATM}=           80Kbits/sec
${CALL_UL1_BANDWIDTH_CATM}=          20Kbits/sec
${CALL_UL2_BANDWIDTH_CATM}=          8Kbits/sec
${CATM_UE_ALIAS1}=                   Quectel_UE_1
${CATM_CALL_UL_BW_KBPS}=             70Kbits/sec
${CATM_CALL_DL_BW_KBPS}=             70Kbits/sec
${CATM_CALL_ULDL_BW_KBPS}=           70Kbits/sec
${CATM_CALL_DL_BW_KBPS_MHARQ}=       100Kbits/sec
${CATM_CALL_DL_BW_KBPS_MHARQ_WITH_LA}=      100Kbits/sec
${OUT_EARFCN}=                       0
${CALL_UL_BANDWIDTH}=                110Kbits/sec
${CALL_DL_BANDWIDTH}=                100Kbits/sec
${CATM_MAX_BW_DEVIATION_PERCENT}=    30%
${CALL_DURATION_S}=                  60s
${CALL_DURATION_S1}=                 240s
${CATM_IDLE_TIME_S}=                 120s
@{TAG}                               Enable5099   actDRX
@{TAG1}                              disaable5099   disablelongCDRX
${direction}=                        ALL
${port_id}=                          15002
${at_cmd_reset}=                     at+cfun=1,1
######CB010992Variable######
@{CellState} =   energySaving    notEnergySaving
@{ORUState} =   AWAKE    SLEEP
${SCFpath_10992}=    /home/ute/robotws/testsuite/Bangalore/ORAN/SG02/CRT2Suite/CB010992_Script/CB010992SCF.xml
${input_File}=    /home/ute/robotws/testsuite/Bangalore/ORAN/SG02/CRT2Suite/CB010992_Script/SCFs/CB010992SCF.xml
${output_File}=    /home/ute/robotws/testsuite/Bangalore/ORAN/SG02/CRT2Suite/Fileconfiguration/CB010992/modified_CB010992SCF.xml
${savedSCF_path}=    /home/ute/robotws/testsuite/Bangalore/ORAN/SG02/CRT2Suite/Fileconfiguration/CB010992
${filename}=    modified_CB010992SCF.xml
${cellSoduration}=    25
${OFEGSACELLLTE1}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/LNBTS_R-912/LNCEL_R-9117
${OFEGSACELLLTE2}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/LNBTS_R-912/LNCEL_R-9118
${OFEGSACELLNR1}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-911/NRCELL_R-1
${OFEGSACELLNR2}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-911/NRCELL_R-2
${OFEGSACELLNR5}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-911/NRCELL_R-5
${AHHBCELL1}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/LNBTS_R-912/LNCEL_R-9111
${AHHBCELL2}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/LNBTS_R-912/LNCEL_R-9112
${AZRBCELL1}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/LNBTS_R-912/LNCEL_R-9113
${AZRBCELL2}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/LNBTS_R-912/LNCEL_R-9114
${AZRBCELL3}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/LNBTS_R-912/LNCEL_R-9115
${AZRBCELL4}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/LNBTS_R-912/LNCEL_R-9116
${AHPMDANRCELL}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-911/NRCELL_R-6
${AHPMDANRCELL2}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-911/NRCELL_R-9
${AZQPNRCELL}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-911/NRCELL_R-7
${AZQPNRCELL2}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-911/NRCELL_R-8
${AWHQNNRCELL}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-911/NRCELL_R-0
${RMODOFEGSA}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/RMOD_R-3
@{emil_values}=    SCell    PCI
###CB010358 variables###
${DSS_SCF_FILE}        /home/ute/robotws/testsuite/Bangalore/ORAN/SG02/CRT2Suite/Fileconfiguration/master_scf_MRBTS-911_LTE_NR_7CC_with_DSS.xml
${master_scf_file}     /home/ute/robotws/testsuite/Bangalore/ORAN/SG02/CRT2Suite/Fileconfiguration/master_scf_MRBTS-911_LTE_NR_7CC_with_DSS.xml
${scf_config2}       /home/ute/robotws/testsuite/Bangalore/ORAN/SG02/CRT2Suite/Fileconfiguration/scf_config2_MRBTS-911_LTE_NR.xml
