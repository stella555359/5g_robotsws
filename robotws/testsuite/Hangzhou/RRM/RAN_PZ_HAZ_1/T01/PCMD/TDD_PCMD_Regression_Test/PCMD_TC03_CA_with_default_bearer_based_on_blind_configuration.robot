*** Settings ***
Documentation
...   author: zhang hancong
...   contact: hancong。zhang@nokia-sbell.com
...   this is a robot case about LTE3333.

Suite Setup       Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM
Test Setup        Common Test Setup For RRM
Test Teardown     Common Test Teardown For RRM
Force Tags        SBTS00   5G_RAN    CLOUD_5G_CLASSICAL_ANDROID_ASIBR_ABILB1_AHEGB_FRGQ_ENB   QCD_MN_RAN    QCP_RAN_ST

Resource    ../../../Resources/Classical/RRM_Common_Resource.robot
Resource          ../../Resources/RRM2_RRM_Resource.robot

*** Variables ***

${case_path}      Root\\Test_Sets\\22R2\\Regression\\RAN_PZ_HAZ_1\\RAN_PZ_HAZ_1_SG02\\RRM\\CRT
${qc_test_set_name}       TDD PCMD Regression Test
${qc_case_name}     UE Attach with traffic
${DST_FOR_BTS}    MRBTS-${MRBTS_ID}/NRBTS-10065
${DST_FOR_FRM}    MRBTS-${MRBTS_ID}/NRBTS-10065/NRCELL-0
${DST_FOR_GROUP}    MRBTS-${MRBTS_ID}/NRBTS-10065/NRCELLGRP-0
${DST_FOR_PMCADM}    MRBTS-${MRBTS_ID}/MNL-1/PMCADM-1
${ue_index}           ${tl.ues[0]}
${first_cell_id}      1231875
${gummei}          /460:02:2714:01

${expected_throughput}=   20Mbits/sec
${enb}=   ENB4812
${record_type}=  1      #1:normal record 2: failure record

@{check_list_86}     PRIMARY    86    NONNULL      0    1       -2147483648     2147483647
@{check_list_87}     PRIMARY    87    NONNULL      0    1       -2147483648     2147483647
@{check_list_88}     PRIMARY    88    CPLANE       0    1       1       5		 #upper and lower limit are mandatory
@{check_list_89}     PRIMARY    89    CPLANE       0    101     101     510
@{check_list_90}     PRIMARY    90    CPLANE       0    58
@{check_list_91}     PRIMARY    91    NONNULL      40   8472    0       4294967295       #mac ps
@{check_list_92}     PRIMARY    92    NONNULL      40   8472    0       10000            #mac ps
@{check_list_93}     PRIMARY    93    NONNULL      0    1       0       10000            #mac ps
@{check_list_94}     PRIMARY    94    NONNULL      0    1       0       65535            #mac ps
@{check_list_95}     PRIMARY    95    NONNULL      0    1       0       65535            #mac ps
@{check_list_96}     PRIMARY    96    NONNULL      40   1801    0       4294967295       #mac ps
@{check_list_97}     PRIMARY    97    NONNULL      40   14677   0       4294967295       #mac ps
@{check_list_98}     PRIMARY    98    NONNULL      40   14677   0       4294967295       #mac ps
@{check_list_99}     PRIMARY    99    CPLANE       20   0       0       1500             #mac ps
@{check_list_112}    PRIMARY    112   NONNULL      0    0       0       65535
#mac ps, belong with the platform,the value of them will be set to  if TA=0 in your platform, my platform ta = 16
@{check_list_113}    PRIMARY    113   NONNULL      0    16      0       65535
#mac ps, belong with the platform,the value of them will be set to  if TA=0 in your platform, my platform ta = 16
@{check_list_114}    PRIMARY    114   NONNULL      80   15000   0       4294967295       #mac ps
@{check_list_115}    PRIMARY    115   NONNULL      80   15000   0       4294967295       #mac ps
@{check_list_117}    PRIMARY    117   NONNULL      80   15000   0       18446744073709551615     #mac ps
@{check_list_118}    PRIMARY    118   NONNULL      80   15000   0       4294967295       #mac ps
@{check_list_120}    PRIMARY    120   NONNULL      80   15000   0       18446744073709551615     #mac ps
@{check_list_121}    PRIMARY    121   NONNULL      80   15000   0       4294967295               #mac ps
@{check_list_123}    PRIMARY    123   NONNULL      80   15000   0       18446744073709551615     #mac ps
@{check_list_124}    PRIMARY    124   NONNULL      80   15000   0       4294967295               #mac ps
@{check_list_125}    PRIMARY    125   NONNULL      20   4283809931    -2147483648    2147483647  #mac ps
@{check_list_126}    PRIMARY    126   NONNULL      10   639     0       4294967295       #mac ps
@{check_list_142}    PRIMARY    142   NONNULL      80   15000   0       4294967295       #mac ps
@{check_list_143}    PRIMARY    143   NONNULL      80   15000   0       10000            #mac ps
@{check_list_144}    PRIMARY    144   NONNULL      80   15000   0       10000            #mac ps
@{check_list_154}    PRIMARY    154   NONNULL      80   15000   -2147483648     2147483647       #mac ps
@{check_list_196}    PRIMARY    196   NONNULL      80   15000   0       65535            #mac ps
@{check_list_197}    PRIMARY    197   NONNULL      80   15000   0       65535            #mac ps
@{check_list_208}    PRIMARY    208   NONNULL      20   1802    0       4294967295       #mac ps
@{check_list_209}    PRIMARY    209   NONNULL      20   385492  0       4294967295       #mac ps
@{check_list_210}    PRIMARY    210   NONNULL      20   6350    0       4294967295       #mac ps
@{check_list_211}    PRIMARY    211   NONNULL      0    16      0       65535            #mac ps
@{check_list_215}    PRIMARY    215   NONNULL      20   6350    0       4294967295       #mac ps
@{check_list_216}    PRIMARY    216   NONNULL      0    16      0       18446744073709551615     #mac ps
@{check_list_218}    PRIMARY    218   NONNULL      0    16      0       4294967295       #mac ps
@{check_list_258}    PRIMARY    258   NONNULL      20   6350    0       4294967295       #mac ps
@{check_list_266}    PRIMARY    266   NONNULL      80   15000	0		86400000
#mac ps,CAActivation Duration 2DLCAActivation Duration 2DL
@{check_list_267}    PRIMARY    267   NONNULL      80   15000   0		86400000
#mac ps,CAActivation Duration 3DLCAActivation Duration 3DL
@{CA_report_1}       CARPT      1     NONNULL       0       1       0		255               #mac ps
@{CA_report_2}       CARPT      2     NONNULL       0       1       0		255               #mac ps
@{CA_report_3}       CARPT      3     NONNULL       0       1       0		255               #mac ps
@{CA_report_4}       CARPT      4     NONNULL       0       1		0		86400000          #mac ps
@{CA_report_5}       CARPT      5     NONNULL       0       1       0		65535             #mac ps
@{CA_report_6}       CARPT      6     NONNULL       0       1       0		65535             #mac ps
@{CA_report_7}       CARPT      7     NONNULL       0       1       0		65535             #mac ps
@{CA_report_8}       CARPT      8     NONNULL       0       1		0		86400000          #mac ps
@{CA_report_9}       CARPT      9     NONNULL       0       0       0       4294967295        #mac ps
@{CA_report_10}      CARPT      10    NONNULL       0       1       0       4294967295        #mac ps
@{CA_report_11}      CARPT      11    NONNULL       0       462     0       4294967295        #mac ps
@{CA_report_12}      CARPT      12    CPLANE        0       1500    0       1500              #mac ps
@{CA_report_13}      CARPT      13    CPLANE        0       1		0	    1500              #mac ps       #null
@{CA_report_14}      CARPT      14    NONNULL       0       0       0       4294967295        #mac ps
@{CA_report_15}      CARPT      15    NONNULL       0       1		0		10000             #mac ps
@{CA_report_16}      CARPT      16    NONNULL       0       1		0		10000             #mac ps
@{CA_report_17}      CARPT      17    NONNULL       0       1       0		65535             #mac ps
@{CA_report_18}      CARPT      18    NONNULL       0       1       0		65535             #mac ps
@{CA_report_19}      CARPT      19    NONNULL       0       0       0       4294967295        #mac ps
@{CA_report_21}      CARPT      21    NONNULL       0       462		0		1500              #mac ps
@{CA_report_22}      CARPT      22    NONNULL       0       1       0       4294967295        #mac ps
@{CA_report_23}      CARPT      23    NONNULL       0       1       0       4294967295        #mac ps
@{CA_report_25}      CARPT      25    NONNULL       0       1       0       4294967295        #mac ps
@{CA_report_26}      CARPT      26    NONNULL       0       1       0       4294967295        #mac ps
@{CA_report_27}      CARPT      27    NONNULL       0       1       0       4294967295        #mac ps
@{CA_report_28}      CARPT      28    NONNULL       0       1       0		86400000          #mac ps   voip
@{CA_report_29}      CARPT      29    NONNULL       0       1       0       4294967295        #mac ps
@{CA_report_30}      CARPT      30    NONNULL       0       1       0       4294967295        #mac ps

@{sum_list}    ${check_list_88}    ${check_list_89}    ${check_list_90}
...    ${check_list_91}     ${check_list_92}     ${check_list_93}     ${check_list_94}      ${check_list_95}
...    ${check_list_96}     ${check_list_97}     ${check_list_98}    #${check_list_99}
...    ${check_list_112}    ${check_list_113}    ${check_list_114}    ${check_list_115}     ${check_list_117}
...    ${check_list_118}    ${check_list_120}
...    ${check_list_121}    ${check_list_123}    ${check_list_124}    ${check_list_125}     ${check_list_126}
...    ${check_list_142}    ${check_list_143}    ${check_list_144}    ${check_list_154}
...    ${check_list_196}    ${check_list_197}    ${check_list_208}    ${check_list_209}     ${check_list_210}
...    ${check_list_211}    ${check_list_215}    ${check_list_216}    ${check_list_218}     ${check_list_258}
#...    #${check_list_266}
...    ${CA_report_2}      ${CA_report_3}      ${CA_report_4}
       #${CA_report_5}    ${CA_report_6}     ${CA_report_7}      ${CA_report_9}     ${CA_report_10}
...    ${CA_report_8}     ${CA_report_22}     ${CA_report_23}   ${CA_report_25}    ${CA_report_26}    ${CA_report_27}
...    ${CA_report_28}    ${CA_report_29}     ${CA_report_30}
#...    #${CA_report_22}     ${CA_report_23}     ${CA_report_25}    ${CA_report_26}    ${CA_report_27}   ${CA_report_28}
#...    #${CA_report_29}

#18 UE simID related the UE   12627 is enb402 Sansamg S7 simcardID
&{check_filter}    88=1    89=101    90=58       #18=460022000003287

*** Test Cases ***
[1][4.0] CA with default bearer based on blind configuration
    [Tags]    QC_101134    QCD_MN_RAN      QCP_RAN_ST
    Start attenuator
    Prepare UE0
    Start tcpdump by command
    Attach UE0
    Start DL TPUT for UE0
    sleep  30s
    Detach UE0
#    Ue Show Basic Info    UE_1
#    ${cell_id}    ue get cellid    UE_1
#    Start Data Transfer     DT_1    UE_1    dl      duration=15s    throughput=100Mbits/sec    protocol=udp
#    sleep    5s
#    Start attenuator    Enable_CA_Enable_MIMO_PA.txt    GROUP1   JFW_TCPIP
#    Await Data Transfer Finish      DT_1      # blocks your thread, error when duration=forver, without timeout arg
#    Ue Print Avg Throughput      DT_1
#    Ue Review Iperf Reports      DT_1
    Stop tcpdump by command
    sleep  30s
    ${time_system}    get_sys_time
    Log to console    check PCMD
    sleep  30s
    Save Pcmd Log from MNI    ${gummei}    ${TEST_LOG_DIRECTORY}    t_detach=${time_system}    cell_id=${first_cell_id}
    ...                       record_type=${record_type}    &{check_filter}
    sleep  5s
    ${check_result}=    Check Pcmd Record from MNI    ${TEST_LOG_DIRECTORY}    input_pcmd_array=${sum_list}
    log        ${check_result}
    should be true    ${check_result}
*** Keywords ***
Start attenuator
        Log to console    Adjust PA Signal
    ${attenuation_channels}     Get Attenuation port    RU_id=0    gnb_id=0
    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=HBTE    gnb_id=0
    &{channels_to_modify}    create dictionary
    ...    ${attenuation_channels[0]}=63    ${attenuation_channels[1]}=63    ${attenuation_channels[2]}=5
    ...    ${attenuation_channels[3]}=5
    ...    ${attenuation_channels[8]}=63    ${attenuation_channels[9]}=63   ${attenuation_channels[14]}=15
    ...    ${attenuation_channels[15]}=15
    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    gnb_id=0
    sleep    10s
    Log to console    attenuation change complete
Prepare UE0
    ${ue0_type}    ue.translate_power_ue_type_from_testline    ue_index=${0}
	set test variable    ${ue0_type}
    Prepare UE    ${ue0_type}    ue_index=${0}  reboot_ue=${True}
    sleep  10s
Attach UE0
    UE Attach    ${ue0_type}    ue_index=${0}
Start DL TPUT for UE0
    Start traffic    ue_type=${ue0_type}    ue_index=${0}    direction=dl    dt_index=${0}
	...              throughput=200M    duration=600
Detach UE0
    UE Detach    ${ue0_type}    ue_index=${0}
Start tcpdump by command
    Log to console    start tcpdumplog
    ${tcpdump_log_name}    Start tcpdump in SBTS by command    connection=First_ASIB
	set test variable    ${tcpdump_log_name}
Stop tcpdump by command
	Stop tcpdump in SBTS by command
	${capture_file_path}    Download wireshark log to testvm    tcpdump_log_name=${tcpdump_log_name}
	set test variable    ${capture_file_path}


Test Teardown

    Report  ${qc_case_name}  ${qc_case_name}   ${qc_test_set_name}   ${case_path}
