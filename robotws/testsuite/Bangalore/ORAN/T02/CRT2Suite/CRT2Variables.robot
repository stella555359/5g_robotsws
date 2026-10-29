*** Settings ***

Documentation
...   author: T02
...   contact: T02

*** Variables***

&{[1]CB010992-D_CB010443_Verify EN-DC Cell Activation procedure that is triggered by eNB for NR cell.}    QC_ID_FL00=QC_101865
...    QC_ID_SBTS26R1=247046
&{[1]CB007814-F_Verification of site moving to TDS and then back to normal state.}    QC_ID_FL00=QC_31047
&{[1]CB009556_Cell level and Radio level measurements in RF Diagnostic Test via CLI commands after performing basic O&M operations multiple times}
...    QC_ID_FL00=QC_71955
&{[1]CB009556_ETP and RTWP in ALM via CLI commands after performing basic O&M operations multiple times.}    QC_ID_FL00=QC_71956
&{[1]CB007795-B_Verification of Cell setup procedure with O-RU}    QC_ID_FL00=QC_31122
&{[1]CNI-121537_ Verification of EPE counters for power and temperature after Radio Reset and Lock_Unlock}    QC_ID_FL00=QC_31053
...    QC_ID_SBTS26R1=247047
&{[1]CB008796_CB006620_Fast Uplink Link Adaptation improvement}    QC_ID_FL00=QC_31114
&{[1]CB008796_LTE30_LTE31_Link Adaptation_DL AMC for Data Channel}    QC_ID_FL00=QC_31115
&{[1]CB012780_To Monitor ORU reset along with SSH key exchange}    QC_ID_FL00=QC_174069
&{[1]Test case-2_CB010358_CB005738_CB007738_DSS_LTE-NR_SuperFast_allocation_verification_20MHz_SA}    QC_ID_FL00=QC_163331
...    QC_ID_SBTS25R3=247056
&{[1]CB008796_LTE5270_Verification of 4CC 16 MIMOlayers FDD DL CA with blind SCel addition}    QC_ID_FL00=QC_235373
...    QC_ID_SBTS25R3=247051
&{[1]CB007814_5GC002250_5GC001390 Verification of TCP Downlink Carrier Aggregation data Tput and Buffer Based SCell activationfor up to 2CC UEs}
...    QC_ID_FL00=QC_31111

#####SetupReadiness###

#BTSRelatedParameters
${bts_id}=                911
#${BTS_ADDRESS} =          192.168.255.129
#${btsusername}=           Nemuadmin
#${btspassword}=           nemuuser
${ssh_username}=          toor4nsn
${ssh_password}=          oZPS0POrRieRtu
#${connection}=            default
#${BTS_path}=              /home/ute/logs
#${port}=                  443
@{faultslist}=            61652    61649    4681    4655    4654    61524
${scout_TL_name}=    10_2_SG1ORAN911_912
#BuildRelatedParameters#
###Precondition to create a folder with base build name (eg. SBTS25R2 or SBTS24R3)###
###Precondition to keep base release SCF and RFM plugin in the path###
###If dedicated base build is available for downgrade variable is yes,
#...    else Mention it as "no" to download a new base build###

###Source Software ###
${sourcebasebuildavailable}=     yes
${fullsourcebasebuild}=          SBTS25R2_ENB_0000_000562_000000   #Build name if a dedicated base build is available#
${sourceRelease}=                SBTS00     #SourceRelease#
${sourceScfpath}=                /home/ute/${sourceRelease}/SCF.xml   #Path of base build SCF#
${rfmpluginpath}=                /home/ute/${sourceRelease}/RFMPlugin_O-RU_FJ_TA08029-B311-01_0003.zip    #RFM plugin for FJT#
${fdsw_version}=                 FDSW25A
###Example: FDWS25A is the FDWS for SBTS25R2 release builds,find it in sub-builds section of WFT link for base release build###

###Target Software ###
${targetRelease}=         SBTS00    #TargetRelease#
${SWpromTAG}=             REGRESSION     #TagtoDownloadBuildfromCoops(eg.REGRESSION/CDRT)#
${currentTrunk}=          SBTS26R2       #SetCurrentTrunk,example:"SBTS00"NowEquals"SBTS26R1"l
### Update below parameters for your Choice of Build to Download
### yes : Download the build by the choice of user
### no  : download latest released build from coops link ###
${DownloadSWBuildbyUserChoice}=        yes  ##If yes, provide Build in ${SWBuildID_UserChoice}##
${SWBuildID_UserChoice}=               SBTS00_ENB_9999_251215_000007

#O-RANRelatedParameters
&{FJsw_compatibility}=    SBTS24R3=02
...                       SBTS25R1=03
...                       SBTS25R2=04
...                       SBTS25R3=05
...                       SBTS26R1=06
...                       SBTS26R2=06

###ca case####
${NRcell6_counters_path1}=           BTS']['MRBTS-911']['NRBTS-911']['NRCELL-6']['NCADU
${LTE_pcell_counters_path}=      BTS']['MRBTS-911']['LNBTS-912']['LNCEL-9118']['MCC-001']['MNC-01']['LTE_UE_Quantity
${LTE_pcell_tput_counters_path}=      BTS']['MRBTS-911']['LNBTS-912']['LNCEL-9118']['MCC-001']['MNC-01']['LTE_Cell_Throughput
${LTE_pcell_LTE_Pwr_and_Qual_DL}=      BTS']['MRBTS-911']['LNBTS-912']['LNCEL-9118']['MCC-001']['MNC-01']['LTE_Pwr_and_Qual_DL
@{3CC_Countervalues}=    M55316C03002
@{2CC_Countervalues}=    M55316C03001    M55316C09000
#@{2CC_Countervalues}=    M55316C03001    M55316C09000    M55118C05507    M55118C05508
@{LTE5270_7CC_counters}=    M8051C190
@{LTE5270_4CC_counters}=    M8051C19    M8051C17
@{LTE5270_4CC_counters_tput}=    M8012C25
@{LTE5270_4CC_counters_UE}=        M8010C115
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
@{ports_ahpmdg}=                ${9}    ${10}
@{ports_azqp}=                  ${13}    ${14}    ${15}    ${16}
@{cavalues0}=   90dB    90dB   90dB    90dB
@{cavalues1}=   0dB    0dB   0dB    0dB
@{cavalues2}=   30dB    30dB   30dB    30dB
@{cavalues3}=   20dB    20dB   20dB    20dB
@{cavalues4}=   0dB    0dB   0dB    0dB
@{cavalues5}=   0dB    0dB   0dB    0dB
@{cavalues6}=   50dB    50dB   50dB    50dB
@{avalues0}=   90dB    90dB
@{avalues1}=   0dB    0dB
@{at_channel_ahpmda}=    ${9}    ${10}
@{at_channel_azqp}=      ${13}    ${14}    ${15}    ${16}

##UE##
@{UE_alias}=                 UE1
@{capabilities}=             Legacy_1
@{UE_alias3}=                 UE3
@{capabilities3}=             Legacy_3
@{throughput_dl}             250
@{direction_dl}=             dl
@{deviation_dl}=             90
@{throughput_ul}             70
@{udpcalltype}=              UDP
@{tcpcalltype}=              TCP
@{direction_ul}=             ul
@{deviation_ul}=             90
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
${bts_password}		nemuuser
${DCAP_host}        10.41.209.120
${port}              443
${dcap_password}=   utfadmin!
${dcapuser}=        utfuser
${voice_call_TC}=           VoLTE_Server_Call
&{BTS_INFO}                 host=${BTS_M_plane_ip}	port=443
@{enb_custom_filters}       condor4gTti    cp_4g    controlPlane4g
@{bts_custom_filter}        immediateSnapshot    scf
@{collection_timing}        Immediate       TraceEnd
${Default_DCAP_duration}    30
${dcap_log_timeout}         800
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
${NrcellId}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-911/NRCELL_R-1
${TestModel}=   TM1_1
@{BeamPatternId} =	0    0
${polarization}=    P_plus45_or_0
${powerBackoff}=    0
${ruMode}=          NR_Only
${PhyCellId}=       101
${pmax}=            40
${nrarfcnDl}=       426000
${nrarfcnUl}=	    388000
${MIMOrank}=        1
${codebook2antports}=      0
${i11Codebook4antports}=   0
${i2codebook4antports}=    0
${i13codebook4antports}=   0
@{Required_bts_status} =   Test    OnAir
${log_dir}=                /tmp/btslog2
#${name}=                   btslog
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
${netactUSERNAME}=              omc
${netactPASSWORD}=              Medsql!_1893
${node_Username_fmwas}=	        omc
${node_password_fmwas}=         Medsql!_1893
${PLAN_DESCRIPTION}=            T02NetactCasePlan
@{dhcpv6_messages}    Solicit    Advertise    Request    Confirm
@{DORA_messages}    DHCP Discover    DHCP Offer    DHCP Request    DHCP ACK
${RU_IP}=    172.22.8.2
@{messages}    DHCP ACK

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
${NMS_path}=    /home/ute/RU_SW
${user_RUSW}=    chenniga
${auth_key}=     cmVmdGtuOjAxOjE4MDg2MzM2NDk6YmJhcHlocnBlUGZzeFFvQ0VScDRtTFdMSXc1

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
${BTS_path}                 		/home/ute/logs
@{antlList}
@{radios}                   		${3}
@{cellsnum}
${BBmod}                            MRBTS-911/EQM-1/APEQM-1/CABINET-1/BBMOD-2
${Rmod}                             MRBTS-911/EQM-1/APEQM-1/RMOD-3
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
${commonSCFpath}=                  ./testsuite/Bangalore/ORAN/T02/CRT2Suite/Fileconfiguration
${CONFIG_PATH}=   ./testsuite/Bangalore/ORAN/T02/CB008796/configurations/ta_ue_config.yaml
${SCF_PATH}=      ./testsuite/Bangalore/ORAN/T02/CB008796/configurations/ANT_remap_LTE.json
${scf_path2}=     ./testsuite/Bangalore/ORAN/T02/CB008796/configurations/ANT_remap_modifying_LTE.json
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
${filter_message_file}    ./testsuite/Bangalore/ORAN/T02/CRT2Suite/Fileconfiguration/
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
${DN_ALD}=	MRBTS-911/EQM-1/APEQM-1/ALD-1
${DN_RSL}=	MRBTS-911/EQM-1/APEQM-1/RMOD-6/RSL-1
${dc_parameter}=    dc-enabled
${dc_parameter_name}    dcVoltageEnabled
${hard_reset}=    hard
${soft_reset}=    soft
${netconf_file}=    RMOD_L-1_NetconfRpcMessageTrace.log
${rpc}=    rpc
${rpc_get}=    get
${rpc_reply}=    rpc-reply
${external}=    external-io
${name}=    name
${port_rpc}=    port-in
${line}=    line-in
${ald_communication}=    ald-communication
${status}=    status
${value}=    ACCEPTED
${RMOD_AWHQN}=    MRBTS-911/EQM-1/APEQM-1/RMOD-6
${MRBTS_BBMOD}=    MRBTS-911/EQM-1/APEQM-1/CABINET-1/BBMOD-3
${config}=    edit-config
${distname_pmax}=    MRBTS-911/NRBTS-911/NRCELL-0
${parameter_pmax}=    pMax
${pmax_43dbm}=    430
${pmax_40dbm}=    400
${o-du-port-bitmask}=    o-du-port-bitmask
${band-sector-bitmask}=    band-sector-bitmask
${ccid-bitmask}=    ccid-bitmask
${ru-port-bitmask}=    ru-port-bitmask
${egen_IP}=    10.45.150.180
${egen_username}=    ute
${miOranRURxStatspath}=    BTS']['MRBTS-911']['EQM-1']['APEQM-1']['RMOD-6']['RURWS
@{miOranrxStats_CounterList}=    M55604C00001
@{miOranrurxtotal_CounterList}=    M55604C00006
${parameter_mirxws}=    miRxWindowStats
${parameter_mitrrxws}=    miTrRxWindowStats
${miOranTrRxStatspath}=    TRS']['MRBTS-911']['TNLSVC-1']['TNL-2']['ETHSVC-1']['ETHLK-1']['TRRWS
@{miOrantrrxStats_CounterList}=    M55605C00001
@{miOrantrrxtotal_CounterList}=    M55605C00006

#####ALARMS#####
@{ALLOWED_ALARMS}    4654    61524    61652    61649    4655    4079    49    4592    6134    6129
@{allowed_alarms_CB008815}    &{4655}  &{61649}  &{61524}  &{4654}  &{61652}  &{4079}  &{4141}
&{49}     fault_id=49
...         alarm_id=7102
...         alarm_severity=Critical
...         fault_name="Cell blocked"
...         notifier=[LTE_NR_7CC_Bangalore] MRBTS-911/LNBTS-912/LNCEL-9111
&{6134}     fault_id=6134
...         alarm_id=7115
...         alarm_severity=Minor
...         fault_name="EN DSS De-activated on partner side"
...         notifier=[LTE_NR_7CC_Bangalore][LTE_FDD_Band_1] MRBTS-911/LNBTS-912/LNCEL-9118
&{6129}     fault_id=6129
...         alarm_id=7115
...         alarm_severity=Minor
...         fault_name="No DSS Partner Cell"
...         notifier=[LTE_NR_7CC_Bangalore][LTE_FDD_Band_1] MRBTS-911/LNBTS-912/LNCEL-9118
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
&{61524}        fault_id=61524
...	       alarm_id=7220
...            alarm_severity=regex"Warning|Minor|Major"
...            fault_name="SSH enabled"
&{4654}        fault_id=4654
...	       alarm_id=7220
...            alarm_severity=regex"Warning|Minor|Major"
...            fault_name="Ethernet port security is disabled"
&{61652}        fault_id=61652
...	       alarm_id=7220
...            alarm_severity=regex"Warning|Minor|Major"
...            fault_name="R&D Service Port enabled"
&{4079}        fault_id=4079
...	       alarm_id=7115
...            alarm_severity=regex"Warning|Minor|Major"
...            fault_name="Cooling fan speed decreased"
&{4141}        fault_id=4141
...	       alarm_id=7113
...            alarm_severity=regex"Warning|Minor|Major"
...            fault_name="DC voltage administratively disabled"
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
&{4655}        fault_id=4655
...	       alarm_id=7220
...            alarm_severity=regex"Warning|Minor|Major"
...            fault_name="Service account root access is enabled"
&{61649}        fault_id=61649
...	       alarm_id=7220
...            alarm_severity=regex"Warning|Minor|Major"
...            fault_name="LMP access via port 443"
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
${maxNrDssRatio_70}      70
${maxNrDssRatio_50}      50
${maxNrDssRatio_90}      90
${lteNrDssDlRatio_70}    70
${lteNrDssDlRatio_50}    50
${lteNrDssDlRatio_90}    90
${maxLteDssSibRb_0}      0
${maxLteDssSibRb_10}     10

######CB010992Variable######
@{CellState} =   energySaving    notEnergySaving
@{ORUState} =   AWAKE    SLEEP
${SCFpath_10992}=    /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T02/CRT2Suite/CB010992_Script/CB010992SCF.xml
${input_File}=    /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T02/CRT2Suite/CB010992_Script/CB010992SCF.xml
${output_File}=    /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T02/CRT2Suite/Fileconfiguration/CB010992/modified_CB010992SCF.xml
${savedSCF_path}=    /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T02/CRT2Suite/Fileconfiguration/CB010992
${filename}=    modified_CB010992SCF.xml
${cellSoduration}=    25
${OFEGSACELLLTE9110}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/LNBTS_R-912/LNCEL_R-9110
${OFEGSACELLLTE9115}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/LNBTS_R-912/LNCEL_R-9115
${OFEGSACELLLTE9117}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/LNBTS_R-912/LNCEL_R-9117
${OFEGSACELLLTE9118}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/LNBTS_R-912/LNCEL_R-9118
${OFEGSACELLNR1}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-911/NRCELL_R-1
${OFEGSACELLNR2}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-911/NRCELL_R-2
${OFEGSACELLNR5}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-911/NRCELL_R-5
${AHHBCELL1}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/LNBTS_R-912/LNCEL_R-9111
${AHHBCELL2}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/LNBTS_R-912/LNCEL_R-9112
${AZRBCELL1}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/LNBTS_R-912/LNCEL_R-9113
${AZRBCELL2}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/LNBTS_R-912/LNCEL_R-9114
${AZRBCELL3}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/LNBTS_R-912/LNCEL_R-9115
${AZRBCELL4}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/LNBTS_R-912/LNCEL_R-9116
${AHPMDGNRCELL}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-911/NRCELL_R-6
${AHPMDGNRCELL2}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-911/NRCELL_R-9
${AHPMDGLCELL_2}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/LNBTS_R-912/LNCEL_R-2
${AHPMDGLCELL_10}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/LNBTS_R-912/LNCEL_R-10
${AZQPNRCELL}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-911/NRCELL_R-7
${AZQPNRCELL2}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-911/NRCELL_R-8
${AWHQNNRCELL}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-911/NRCELL_R-0
${RMODOFEGSA}=    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/RMOD_R-2
@{emil_values}=    SCell    PCI
###CB010358 variables###
${DSS_SCF_FILE}        /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T02/CRT2Suite/SCFs/master_scf_MRBTS-911_ofegsa_LTE_4_NR_1cells_26R1_DSS.xml
${master_scf_file}     /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T02/CRT2Suite/SCFs/master_scf_BTS911_trunk_26R2.xml
${master_scf_file_26R1}     /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T02/CRT2Suite/SCFs/
...    customer_config_align_without_GSM_master_scf_MRBTS_911_with_AWHQN_NR_LTE_4cc_trunk_26R1.xml
${scf_config2}      /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T02/CRT2Suite/SCFs/scf2_CB09556_OFEGSA_5NR_cells_MRBTS-911.xml
${master_scf_with_AWHQN}    /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T02/CRT2Suite/SCFs/master_scf_BTS911_trunk_26R2.xml
${master_scf_without_AWHQN}    /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T02/CRT2Suite//SCFs/scf_BTS911_wo_AWHQN_truk_26R2.xml
${mo_name}=                     PLMN-PLMN/MRBTS-911
${plan_name_enableFeature}=     counter_miTrRxWindowStats_5m
${plan_name_disableFeature}=    counter_miTrRxWindowStats_disabled
${description}=      SG02_AutomationCase_enable_disable_counters_under_miTrRxWindowStatsl
${mo_id_pmmnl}=     PLMN-PLMN/MRBTS-911/MNL-1/MNLENT-1/PMMNL-1
${Time_5m}=    5
${disabled}=    0
${transport_stats_group}=       Transport RX Window Statistics
${miOranTrx_stats_group}=    O-RAN Transceiver Statistics
@{counterlist_miTrRxWindowStats}=    TRANSPORT_RX_CORRUPT    TRANSPORT_RX_DUPL    TRANSPORT_RX_EARLY    TRANSPORT_RX_EARLY_C
...                                  TRANSPORT_RX_LATE    TRANSPORT_RX_SEQID_ERR_C    TRANSPORT_RX_ERR_DROP
...                                  TRANSPORT_RX_LATE_C    TRANSPORT_RX_ON_TIME    TRANSPORT_RX_ON_TIME_C     TRANSPORT_RX_SEQID_ERR
@{counterlist_miOranTrxStats}=    RX_PWR_FIRST    RX_PWR_LATEST    TX_PWR_FIRST    TX_PWR_LATEST    RX_PWR_MAX     TX_BIAS_CUR_FIRST
...                               TX_BIAS_CUR_LATEST    LASER_TEMP_FIRST    LASER_TEMP_LATEST    LASER_TEMP_MIN    TRANSCEIVER_VOLT_FIRST
@{counterlist_miOranEpeStats}=    O_RAN_RADIO_POWER_MAX    O_RAN_RADIO_POWER_MIN    O_RAN_RADIO_POWER_AVG    O_RAN_RADIO_TEMPERATURE_MAX
...    O_RAN_RADIO_TEMPERATURE_MIN    O_RAN_RADIO_TEMPERATURE_AVG    O_RAN_RADIO_VOLTAGE_MAX    O_RAN_RADIO_VOLTAGE_MIN
...    O_RAN_RADIO_VOLTAGE_AVG    O_RAN_RADIO_CURRENT_MAX   O_RAN_RADIO_CURRENT_MIN    O_RAN_RADIO_CURRENT_AVG
${miOranEpe_stats_group}=    O-RAN EPE Statistics
@{counterlist_miOranRuTxStats}=    RU_TX_TOTAL
${miOranRuTx_stats_group}=    O-RAN RU Tx Statistics
${miTrRxWindowStats_Counter}=      TRS']['MRBTS-911']['TNLSVC-1']['TNL-2']['ETHSVC-1']['ETHLK-1']['TRRWS
@{miTrRxWindowStats_CounterList}=         M55605C00001    M55605C00002    M55605C00003    M55605C00006    M55605C00007    M55605C00008
...                                     M55605C00009    M55605C00004
${miOranTrxStats_Counter}=    BTS']['MRBTS-911']['EQM-1']['APEQM-1']['RMOD-3']['SFP-1']['OTRST
@{mioranTrxStats_CounterList}=    M40027C1    M40027C10     M40027C11     M40027C12    M40027C13     M40027C14
...                               M40027C15     M40027C16     M40027C17     M40027C18     M40027C19
${miOranRuTxStats_Counter}=    BTS']['MRBTS-911']['EQM-1']['APEQM-1']['RMOD-3']['ORTX
@{miOranRuTxStats_CounterList}=     M40022C0
@{miOranEpeStats_CounterList}=	        M40021C0	M40021C1	M40021C2	M40021C3	M40021C4	M40021C5
...	                                M40021C7	M40021C8	M40021C9	M40021C10	M40021C11       M40021C6
${TECHNOLOGY_NRCOUNTER}=        NRBTS-Nokia AirScale BTS 5G
${NR_GRP_COUNTER}=    SBTS-Nokia Multi Radio Transceiver Station
${FILTER_BY}=                   MRBTS
${OBJECT_AGGREGATION}=          PLMN
${TIME_AGGREGATION}=            RAW
@{miOranTrTxStats_capabilities}=    TX_TOTAL
@{miTrRxWindowStats_capabilities}=    RX_CORRUPT    RX_DUPL    RX_EARLY    RX_EARLY_C    RX_ON_TIME_C     RX_SEQID_ERR
...                                  RX_LATE    RX_SEQID_ERR_C    RX_ERR_DROP    RX_LATE_C    RX_ON_TIME
@{miOranTrxStats_capabilities}=    TEMPERATURE    VOLTAGE    TX_POWER    RX_POWER    TX_BIAS_COUNT
${msgSubType_edit-config}           edit-config
${msgSubType_get}=                  get
@{miOranepeStats_capabilities}=    POWER    CURRENT    VOLTAGE    TEMPERATURE
@{miOranRuTxStats_capabilities}=    TX_TOTAL
@{miRxWindowStats_capabilities}=    RX_ON_TIME    RX_LATE    RX_EARLY    RX_DUPL     RX_TOTAL    RX_CORRUPT
${plan_name_enableFeature_1}=     miOranTrxStats_5m
${plan_name_disableFeature_1}=    counter_miOranTrxStats_disabled
@{counterlist_miRxWindowStats}=    RU_RX_ON_TIME    RU_RX_EARLY    RU_RX_LATE    RU_RX_CORRUPT    RU_RX_TOTAL    RU_RX_ON_TIME_C    RU_RX_EARLY_C
...                                RU_RX_LATE_C
${miRxWindow_stats_group}=    RU RX Window Statistics
@{counterlist_miOranTrTxStats}=    TRANSPORT_TX_TOTAL
${miOranTrTx_stats_group}=    O-RAN Transport Tx Statistics
${miRxWindowStats_Counter}=     BTS']['MRBTS-911']['EQM-1']['APEQM-1']['RMOD-3']['RURWS
@{miRxWindowStats_CounterList}=         M55604C00001    M55604C00002    M55604C00003    M55604C00006    M55604C00007    M55604C00008
...                                     M55604C00009    M55604C00004
${miOranTrTxStats_Counter}=    TRS']['MRBTS-911']['TNLSVC-1']['TNL-2']['ETHSVC-1']['ETHLK-1']['OTTX
@{miOranTrTxStats_CounterList}=     M40023C0

####CB012780 variables####
${VM_IP}                10.58.238.12
${VM_usn}               ute
${VM_pwd}               BT5l@bus3rl0g1n
@{key_msg1}             aes128-ctr    aes256-gcm@openssh.com    aes128-gcm@openssh.com    aes256-ctr    aes192-ctr
@{key_msg2}             ecdh-sha2-nistp256    ecdh-sha2-nistp384    ecdh-sha2-nistp521    ecdsa-sha2-nistp384    ecdsa-sha2-nistp256
@{key_msg3}             curve25519-sha256    diffie-hellman-group-exchange-sha256
${server_elliptic_message}    Server: Elliptic Curve Diffie-Hellman Key Exchange Init
${client_elliptic_message}    Client: Elliptic Curve Diffie-Hellman Key Exchange Reply
@{key_msg4}             hmac-sha2-256    hmac-sha2-512    hmac-sha2-256-etm@openssh.com    hmac-sha2-512-etm@openssh.com    ecdsa-sha2-nistp521
${server_message}       Server: Key Exchange Init
${client_message}       Client: Protocol (SSH-2.0-libssh_0.11.2), Key Exchange Init
${runtime_log_file}    runtime_DEFAULT.log
${info}    operational-info
${version}    supported-mplane-version
${filter_msg}    ssh
${pattern}=    retrieveMplaneVersion(): Received "12.0.0" using 12.0.0
${FJT_ippdu_ip}    10.58.242.70
${FJT_IPPDU_port}    8
${AWHQN_ippdu_ip}    10.58.242.70
${AWHQN_IPPDU_port}    4
@{sfp_list}=    interface-name    port-number    name    vendor-id    vendor-part    vendor-rev
...             present    serial-no    connector-type    identifier    SFF8472-compliance-code
# --- Windows Machine (Jump Host) Credentials ---
${WINDOWS_HOST}          10.45.150.187

# --- RU Target Credentials ---
${RU_TARGET_HOST}     192.168.1.131
${RU_TARGET_USER}     User1-vSFQEFw1        # Replace with your Linux username on 192.168.1.131
# ${RU_TARGET_PASS}   Q+*!LD0sem     # Only needed if NOT using passwordless SSH from Windows to Linux target, See notes below.
@{search_string}=    Create List    dlAllocationSequenceNumber
${FJT_RFM_plugin_path}    /home/ute/MN/UTE/robotws/RFMPlugin_O-RU_FJ_TA08029-B311-01_0003.zip
${AWHQN_RFM_plugin_path}    /home/ute/MN/UTE/robotws/RFMPlugin_O-RU_NK_475701A-103_0003.zip
${swconfig_path}        /home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/T02/CRT2Suite/Fileconfiguration/swconfig.txt
${RFM_plugin_link}    https://artifactory-blr1.int.net.nokia.com/artifactory/mn-fujitsu-data-local/
${FJT_RFM_plugin_build}    RFMPlugin_O-RU_FJ_TA08029-B311-01_0003.zip
${AWHQN_RFM_plugin_build}    RFMPlugin_O-RU_NK_475701A-103_0003.zip
${RFM_plugin_user}    ca_fujitsu_nok
${plugin_auth_key}    cmVmdGtuOjAxOjE4Mjg5NjU3Nzc6RmpzWWFpcXNkUXA0TjNOVGMyeHZ2b3h3QXVY
${timezone}    timeZone
${dist_timezone}    MRBTS-911/MNL-1
${timezone_value_asia}    (GMT+5.5) Asia/Kolkata
${timezone_value_utc}    (GMT+0) UTC
