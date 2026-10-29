*** Settings ***
Documentation
...   author: Zheng Tracy
...   contact: tracy.zheng@nokia-sbell.com
...   this is a robot case about SR002956, to check whether 4G and 5G PCMD record are reported and correlated in MNI.

Resource          ../../Resources/Classical/RRM_Common_Resource.robot
Resource          ../../T01/Resources/RRM2_RRM_Resource.robot
Force Tags        RAN_PZ_HAZ_1    RAN_PZ_HAZ1_SG02_ST_RRM    TA_LEVEL_21
...               RAN_5G    CLOUD_5G_CLASSICAL_ANDROID_ASIBR_ABILB1_AHEGB_FRGQ_ENB    STAT_SKIP_AGENT       SBTS00
Suite Setup       Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM
Test Setup        Common Test Setup For RRM
#Test Teardown     Common Test Teardown For RRM
Test Teardown    Common Test Case Teardown with Scout    ${TESTLINE_NAME}


*** Variables ***
${TESTLINE_NAME}     10_5_UTESRAN201T4812
${DST_FOR_BTS}    MRBTS-${MRBTS_ID}/NRBTS-10065
${DST_FOR_FRM}    MRBTS-${MRBTS_ID}/NRBTS-10065/NRCELL-0
${DST_FOR_GROUP}    MRBTS-${MRBTS_ID}/NRBTS-10065/NRCELLGRP-0
${DST_FOR_PMCADM}    MRBTS-${MRBTS_ID}/MNL-1/PMCADM-1
${ue_index}           ${tl.ues[0]}
${first_cell_id}      1231873
${gnb_cell_id}        164904960
${gummei}          /460:02:2714:01
${scf_file_path}     /home/ute/MN/UTE/robotws/commissionings/RRM/SRAN_5G/10_5_UTESRAN201T4812/10_5_UTESRAN201T4812_SR002956.xml
${record_type}=  1      #1:normal record 2: failure record
@{check_list_86}     PRIMARY    86    NONNULL    0    1
@{check_list_87}     PRIMARY    87    NONNULL    0    1
@{check_list_88}     PRIMARY    88    CPLANE     0    1
@{check_list_89}     PRIMARY    89    CPLANE     0    101
@{check_list_90}     PRIMARY    90    CPLANE     0    58
@{check_list_91}     PRIMARY    91    NONNULL     40   8472
@{check_list_92}     PRIMARY    92    NONNULL     40   8472
@{check_list_93}     PRIMARY    93    NONNULL    0    1
@{check_list_94}     PRIMARY    94    NONNULL    0    1
@{check_list_95}     PRIMARY    95    NONNULL    0    1
@{check_list_96}     PRIMARY    96    NONNULL     40   1801
@{check_list_97}     PRIMARY    97    NONNULL     40   14677
@{check_list_98}     PRIMARY    98    NONNULL     40   14677
@{check_list_99}     PRIMARY    99     NONNULL       20    11
#@{check_list_100}    PRIMARY    100    NONNULL     20   14
@{check_list_112}    PRIMARY    112    NONNULL     0     0
@{check_list_113}    PRIMARY    113   NONNULL      0    0
@{check_list_114}    PRIMARY    114   NONNULL      80   15000
@{check_list_115}    PRIMARY    115   NONNULL      80   15000
@{check_list_116}    PRIMARY    116   CPLANE      0     1
@{check_list_117}    PRIMARY    117   NONNULL      80   15000
@{check_list_118}    PRIMARY    118   NONNULL      80   15000
@{check_list_119}    PRIMARY    119   CPLANE      1     1
@{check_list_120}    PRIMARY    120   NONNULL      80   15000
@{check_list_121}    PRIMARY    121   NONNULL      80   15000
@{check_list_122}    PRIMARY    122   CPLANE      0      1
@{check_list_123}    PRIMARY    123   NONNULL      80   15000
@{check_list_124}    PRIMARY    124   NONNULL      80   15000
@{check_list_125}    PRIMARY    125   NONNULL      20   4283809931
@{check_list_126}    PRIMARY    126   NONNULL      10   639
@{check_list_131}    PRIMARY    131    NONNULL    0    1
@{check_list_135}    PRIMARY    135   NONNULL      0    5
@{check_list_140}    PRIMARY    140   NONNULL      80   15000
@{check_list_141}    PRIMARY    141   CPLANE      0     3
@{check_list_142}    PRIMARY    142   NONNULL      80   15000
@{check_list_143}    PRIMARY    143   NONNULL      80   15000
@{check_list_144}    PRIMARY    144  NONNULL      80   15000
@{check_list_152}    PRIMARY    152   CPLANE      0     8
@{check_list_154}    PRIMARY    154   NONNULL      80   15000
@{check_list_157}    PRIMARY    157   CPLANE      0     4
@{check_list_163}    PRIMARY    163   NONNULL      0    67328
@{check_list_166}    PRIMARY    166   CPLANE      0    0
@{check_list_173}    PRIMARY    173   CPLANE      0    1
@{check_list_196}    PRIMARY    196   NONNULL      80   15000
@{check_list_197}    PRIMARY    197   NONNULL      80   15000
@{check_list_208}    PRIMARY    208   NONNULL      20   1802
@{check_list_209}    PRIMARY    209   NONNULL      20   385492
@{check_list_210}    PRIMARY    210   NONNULL      20    6350
@{check_list_211}    PRIMARY   211    NONNULL      0     16
@{check_list_212}    PRIMARY    212   NONNULL      20    6350
@{check_list_214}    PRIMARY   214    NONNULL      0     16
@{check_list_215}    PRIMARY    215   NONNULL      20    6350
@{check_list_216}    PRIMARY   216    NONNULL      0     16
@{check_list_217}    PRIMARY    217   CPLANE      0    1
@{check_list_218}    PRIMARY   218    NONNULL      0     16
@{check_list_219}    PRIMARY    219   CPLANE      0     1
@{check_list_223}    PRIMARY   223    CPLANE      0     3348
#@{check_list_235}    PRIMARY   235    NONNULL     0    1
#@{check_list_236}    PRIMARY   236   NONNULL      0    1
@{check_list_241}    PRIMARY    241   CPLANE      0   0
@{check_list_242}    PRIMARY   242    CPLANE      0     0
@{check_list_243}    PRIMARY    243   NONNULL      20    6350
@{check_list_245}    PRIMARY   245    NONNULL      0     16
#@{check_list_258}    PRIMARY    258   NONNULL      20    6350
@{check_list_259}    PRIMARY   259   NONNULL      0    39897
@{check_list_6}     SECONDARY    6    NONNULL     0     8
@{check_list_8}     SECONDARY    8    CPLANE     0     5
@{check_list_15}     SECONDARY    15    NONNULL     0     1
@{check_list_16}     SECONDARY    16    NONNULL     0    1
@{check_list_17}     SECONDARY    17    NONNULL     0    1
@{check_list_18}     SECONDARY    18    NONNULL     0     1
@{check_list_19}     SECONDARY    19    NONNULL     0     1
@{check_list_20}     SECONDARY    20    NONNULL     0     1
@{check_list_22}     SECONDARY    22    NONNULL     0    1
@{check_list_23}     SECONDARY    23    NONNULL     0    1
@{check_list_24}     SGNBREQ      1     CPLANE     0    10065     #gNB ID
@{check_list_25}     SGNBREQ      2     NONNULL    0    5
@{check_list_26}     SGNBREQ      4     NONNULL    0    5
@{check_list_27}     SGNBREQ      5     NONNULL    0    5
@{check_list_28}     SGNBREQ      6     CPLANE     0    0
@{check_list_29}     SGNBREQ      11     NONNULL     0    1
@{check_list_30}     SGNBREQ      13     NONNULL     0    1
@{check_list_31}     SGNBREQ      14     CPLANE     0     0
#@{check_list_32}     SGNBREQ      17     NONNULL     0    5
#@{check_list_33}     SGNBREQ      19     NONNULL     0    5
#@{check_list_34}     SGNBREQ      20     NONNULL     0    5
#@{check_list_35}     SGNBREQ      21     CPLANE     0    0
@{check_list_36}     CU      5     CPLANE     0    164904960
@{check_list_37}     DU      5     CPLANE     0    164904960

@{sum_list}    ${check_list_86}    ${check_list_87}    ${check_list_88}    ${check_list_89}    ${check_list_90}
    ...    ${check_list_91}    ${check_list_92}     ${check_list_93}    ${check_list_94}      ${check_list_95}
    ...    ${check_list_96}    ${check_list_97}     ${check_list_98}    ${check_list_99}
    ...    ${check_list_112}   ${check_list_113}    ${check_list_114}    ${check_list_115}     ${check_list_116}
    ...    ${check_list_117}   ${check_list_118}    ${check_list_119}    ${check_list_120}
    ...    ${check_list_121}   ${check_list_122}    ${check_list_123}    ${check_list_124}     ${check_list_125}
    ...    ${check_list_126}   ${check_list_131}
    ...    ${check_list_141}    ${check_list_142}    ${check_list_143}    ${check_list_144}
    ...    ${check_list_152}    ${check_list_154}    ${check_list_157}    ${check_list_163}    ${check_list_166}
    ...    ${check_list_173}    ${check_list_196}    ${check_list_197}
    ...    ${check_list_208}    ${check_list_209}    ${check_list_210}
    ...    ${check_list_212}    ${check_list_215}    ${check_list_216}    ${check_list_217}
    ...    ${check_list_218}    ${check_list_219}
    ...    ${check_list_223}    ${check_list_241}    ${check_list_242}    ${check_list_259}
    ...    ${check_list_6}      ${check_list_8}      ${check_list_15}
    ...    ${check_list_16}     ${check_list_17}    ${check_list_18}
    ...    ${check_list_19}    ${check_list_20}    ${check_list_22}    ${check_list_23}     ${check_list_24}
    ...    ${check_list_25}    ${check_list_26}    ${check_list_27}    ${check_list_28}     ${check_list_29}
    ...    ${check_list_30}    ${check_list_31}    ${check_list_36}    ${check_list_37}


&{check_filter}     88=1    89=101    90=58

*** Test Cases ***
[1]RP002956-F_RP002956-G_LTE and 5G PCMD Function_Full Rack
    [Tags]    QC_101401    QCD_MN_RAN      QCP_RAN_ST
    Start attenuator
    Start tcpdump by command
	Attach UE0 And Start DL TPUT
	Detach UE0
	Stop tcpdump by command
    ${time_system}    get_sys_time
    Log to console    check PCMD
    Save Pcmd Log from MNI    ${gummei}    ${TEST_LOG_DIRECTORY}    t_detach=${time_system}    cell_id=${first_cell_id}
    ...                       record_type=${record_type}    &{check_filter}
    sleep  5s
    ${check_result}=    Check Pcmd Record from MNI    ${TEST_LOG_DIRECTORY}    input_pcmd_array=${sum_list}
    log        ${check_result}
    should be true    ${check_result}

[2]CB009834_TC01_CB009834 Automatic PCMD recovery after BB card failure and restart
    [Tags]    QC_551350    QCD_MN_RAN      QCP_RAN_ST
    COAM_Admin.Reset_BBMOD
    sleep    300s
    Start tcpdump by command
	Attach UE0 And Start DL TPUT
	Detach UE0
	Stop tcpdump by command
    ${time_system}    get_sys_time
    Log to console    check PCMD
    Save Pcmd Log from MNI    ${gummei}    ${TEST_LOG_DIRECTORY}    t_detach=${time_system}    cell_id=${first_cell_id}
    ...                       record_type=${record_type}    &{check_filter}
    sleep  5s
    ${check_result}=    Check Pcmd Record from MNI    ${TEST_LOG_DIRECTORY}    input_pcmd_array=${sum_list}
    log        ${check_result}
    should be true    ${check_result}

*** Keywords ***

make call with DL
    Log to console    make call
    Start traffic    ${ue_type}    direction=dl    throughput=1024M    duration=15
    sleep    10

##########    UE related    ##########
Start attenuator
        Log to console    Adjust PA Signal
    ${attenuation_channels}     Get Attenuation port    RU_id=0    gnb_id=0
    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=HBTE    gnb_id=0
    &{channels_to_modify}    create dictionary
    ...    ${attenuation_channels[0]}=10    ${attenuation_channels[1]}=10    ${attenuation_channels[2]}=63
    ...    ${attenuation_channels[3]}=63     ${attenuation_channels[8]}=10    ${attenuation_channels[9]}=10
    ...    ${attenuation_channels[14]}=63    ${attenuation_channels[15]}=63
    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    gnb_id=0
    sleep    10s
    Log to console    attenuation change complete
Prepare UE0
    ${ue0_type}    ue.translate_power_ue_type_from_testline    ue_index=${0}
	set test variable    ${ue0_type}
    Prepare UE    ${ue0_type}    ue_index=${0}
Prepare UE1
    ${ue1_type}    ue.translate_power_ue_type_from_testline    ue_index=${1}
	set test variable    ${ue1_type}
    Prepare UE    ${ue1_type}    ue_index=${1}
Attach UE0
    UE Attach    ${ue0_type}    ue_index=${0}
#	Sleep    60s
Attach UE1
    UE Attach    ${ue1_type}    ue_index=${1}
#	Sleep    60s
Start DL TPUT for UE0
    Start traffic    ue_type=${ue0_type}    ue_index=${0}    direction=dl    dt_index=${0}
	...              throughput=110M    duration=600
Start UL TPUT for UE0
    Start traffic    ue_type=${ue0_type}    ue_index=${0}    direction=ul    dt_index=${0}
	...              throughput=100M    duration=300
Start DL TPUT for UE1
    Start traffic    ue_type=${ue1_type}    ue_index=${1}    direction=dl    dt_index=${1}
	...              throughput=110M    duration=600
Start UL TPUT for UE1
    Start traffic    ue_type=${ue1_type}    ue_index=${1}    direction=ul    dt_index=${1}
	...              throughput=100M    duration=300
Stop DL THPUT And Detach UE0
    Stop DL THPUT for UE0
    Detach UE0
Stop Both DL AND UL THPUT And Detach UE0
    Stop DL THPUT for UE0
    Stop UL THPUT for UE0
    Detach UE0
Stop DL THPUT And Detach UE1
    Stop DL THPUT for UE1
    Detach UE1
Stop UL THPUT And Detach UE0
    Stop UL THPUT for UE0
    Detach UE0
Stop UL THPUT And Detach UE1
    Stop UL THPUT for UE1
    Detach UE1

Detach UE0
    UE Detach    ${ue0_type}    ue_index=${0}
Detach UE1
    UE Detach    ${ue1_type}    ue_index=${1}

Stop DL THPUT for UE0
    Stop traffic    ${ue0_type}    ue_index=${0}    direction=dl
Stop UL THPUT for UE0
    Stop traffic    ${ue0_type}    ue_index=${0}    direction=ul
Stop DL THPUT for UE1
    Stop traffic    ${ue1_type}    ue_index=${1}    direction=dl
Stop UL THPUT for UE1
    Stop traffic    ${ue1_type}    ue_index=${1}    direction=ul

Attach UE0 And Start Both DL And UL TPUT
    Prepare UE0
    Attach UE0
    sleep    60s
    Start DL TPUT for UE0
    Start UL TPUT for UE0
    sleep    10s

Attach UE0 And Start DL TPUT
    Prepare UE0
    Attach UE0
    sleep    60s
    Start DL TPUT for UE0
    sleep    10s

Attach UE0 And Start UL TPUT
    Prepare UE0
    Attach UE0
    sleep    60s
    Start UL TPUT for UE0
    sleep    10s

Attach UE1 And Start DL TPUT
    Prepare UE1
    Attach UE1
    sleep    60s
    Start DL TPUT for UE1
    sleep    10s

Attach UE1 And Start UL TPUT
    Prepare UE1
    Attach UE1
    sleep    60s
    Start UL TPUT for UE1
    sleep    10s

Start tcpdump by command
    Log to console    start tcpdumplog
    ${tcpdump_log_name}    Start tcpdump in SBTS by command    connection=First_ASIB
	set test variable    ${tcpdump_log_name}

Stop tcpdump by command
	Stop tcpdump in SBTS by command
	${capture_file_path}    Download wireshark log to testvm    tcpdump_log_name=${tcpdump_log_name}
	set test variable    ${capture_file_path}
