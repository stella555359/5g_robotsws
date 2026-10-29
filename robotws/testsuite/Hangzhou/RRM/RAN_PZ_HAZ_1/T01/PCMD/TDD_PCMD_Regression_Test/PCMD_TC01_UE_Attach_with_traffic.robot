*** Settings ***
Documentation
...   author: zhang hancong
...   contact: hancong。zhang@nokia-sbell.com
...   this is a robot case about LTE3333.

Suite Setup       Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM
Test Setup        Common Test Setup For RRM
#Test Teardown     Common Test Teardown For RRM
Test Teardown    Common Test Case Teardown with Scout    ${TESTLINE_NAME}
Force Tags        SBTS00   5G_RAN    CLOUD_5G_CLASSICAL_ANDROID_ASIBR_ABILB1_AHEGB_FRGQ_ENB    QCD_MN_RAN    QCP_RAN_ST


Resource    ../../../Resources/Classical/RRM_Common_Resource.robot
Resource          ../../Resources/RRM2_RRM_Resource.robot

*** Variables ***

#${case_path}      Root\\Test_Sets\\22R2\\Regression\\RAN_PZ_HAZ_1\\RAN_PZ_HAZ_1_SG02\\RRM\\CRT
${qc_test_set_name}       TDD PCMD Regression Test
${qc_case_name}     UE Attach with traffic
${DST_FOR_BTS}    MRBTS-${MRBTS_ID}/NRBTS-10065
${DST_FOR_FRM}    MRBTS-${MRBTS_ID}/NRBTS-10065/NRCELL-0
${DST_FOR_GROUP}    MRBTS-${MRBTS_ID}/NRBTS-10065/NRCELLGRP-0
${DST_FOR_PMCADM}    MRBTS-${MRBTS_ID}/MNL-1/PMCADM-1
${ue_index}           ${tl.ues[0]}
${first_cell_id}      1231874
${gnb_cell_id}        164904960
${gummei}          /262:03:2717:01
${TESTLINE_NAME}     10_5_UTESRAN201T4812

${expected_throughput}=   20Mbits/sec
${record_type}=  1      #1:normal record 2: failure record
@{check_list_86}     PRIMARY    86    NONNULL      0    1       -2147483648     2147483647
@{check_list_87}     PRIMARY    87    NONNULL      0    1       -2147483648     2147483647
@{check_list_88}     PRIMARY    88    CPLANE       0    1       1       5
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
#@{check_list_100}    PRIMARY    100    NONNULL     20   14     0       1500             #mac ps, relate the tm3 or tm4,
@{check_list_112}    PRIMARY    112   NONNULL      0    0       0       65535
#mac ps, belong with the platform,the value of them will be set to “0” if TA=0 in your platform, my platform ta = 16
@{check_list_113}    PRIMARY    113   NONNULL      0    16      0       65535
#mac ps, belong with the platform,the value of them will be set to “0” if TA=0 in your platform, my platform ta = 16
@{check_list_114}    PRIMARY    114   NONNULL      80   15000   0       4294967295       #mac ps
@{check_list_115}    PRIMARY    115   NONNULL      80   15000   0       4294967295       #mac ps
@{check_list_117}    PRIMARY    117   NONNULL      80   15000   0       18446744073709551615     #mac ps
@{check_list_118}    PRIMARY    118   NONNULL      80   15000   0       4294967295       #mac ps
@{check_list_120}    PRIMARY    120   NONNULL      80   15000   0       18446744073709551615     #mac ps
@{check_list_121}    PRIMARY    121   NONNULL      80   15000   0       4294967295               #mac ps
@{check_list_123}    PRIMARY    123   NONNULL      80   15000   0       18446744073709551615     #mac ps
@{check_list_124}    PRIMARY    124   NONNULL      80   15000   0       4294967295               #mac ps
@{check_list_125}    PRIMARY    125   NONNULL      20   4283809931    -2147483648    2147483647          #mac ps
@{check_list_126}    PRIMARY    126   NONNULL      10   639     0       4294967295       #mac ps
@{check_list_142}    PRIMARY    142   NONNULL      80   15000   0       4294967295               #mac ps
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

@{check_list_6}      SECONDARY    6     CPLANE      0     5     1       9                #default bear info   #ceheck 5
@{check_list_8}      SECONDARY    8     CPLANE      0     5     1       15               #default bear info  # check 6
@{check_list_15}     SECONDARY    15    NONNULL     0     1     0       4294967295
@{check_list_16}     SECONDARY    16    NONNULL     0     1     0       4294967295
@{check_list_17}     SECONDARY    17    NONNULL     0     1     0       4294967295
@{check_list_18}     SECONDARY    18    NONNULL     0     1     0       4294967295
@{check_list_19}     SECONDARY    19    NONNULL     0     1     0       4294967295
@{check_list_20}     SECONDARY    20    NONNULL     0     1     0       4294967295
@{check_list_22}     SECONDARY    22    NONNULL     0     1     0       4294967295        #0
@{check_list_23}     SECONDARY    23    NONNULL     0     1     0       4294967295


@{sum_list}    ${check_list_88}    ${check_list_89}    ${check_list_90}
...    ${check_list_91}     ${check_list_92}     ${check_list_93}     ${check_list_94}      ${check_list_95}
...    ${check_list_96}     ${check_list_97}     ${check_list_98}
...    ${check_list_112}    ${check_list_113}    ${check_list_114}    ${check_list_115}     ${check_list_117}
...    ${check_list_118}    ${check_list_120}
...    ${check_list_121}    ${check_list_123}    ${check_list_124}    ${check_list_125}     ${check_list_126}
...    ${check_list_142}    ${check_list_143}    ${check_list_144}    ${check_list_154}
...    ${check_list_196}    ${check_list_197}    ${check_list_208}    ${check_list_209}     ${check_list_210}
...    ${check_list_211}    ${check_list_215}    ${check_list_216}    ${check_list_218}     ${check_list_258}



&{check_filter}    88=1    89=101    90=58

*** Test Cases ***
[1][4.0] UE Attach with traffic
    [Tags]    QC_32429     QCD_MN_RAN      QCP_RAN_VRF
    Start attenuator
    sleep    2s
    #Reserve UE for tests
    #Attach Ue For Test
    #sleep    10s
    #Ue Show Basic Info    UE_1
    #${cell_id}    ue get cellid    UE_1

    #Start Data Transfer     DT_1    UE_1 dl duration=15s    throughput=20Mbits/sec    protocol=udp   packet_size=1024B
    #Await Data Transfer Finish      DT_1      # blocks your thread, error when duration=forver, without timeout arg
    #Ue Print Avg Throughput      DT_1
    #Ue Review Iperf Reports     DT_1
    #Detach
    Start tcpdump by command
	Attach UE0 And Start DL TPUT
	#${cell_id}    ue get cellid    UE_0
	Detach UE0
	Stop tcpdump by command
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
    ...    ${attenuation_channels[3]}=5     ${attenuation_channels[8]}=63    ${attenuation_channels[9]}=63
    ...    ${attenuation_channels[14]}=15    ${attenuation_channels[15]}=15
    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    gnb_id=0
    sleep    10s
    Log to console    attenuation change complete
Attach UE0 And Start DL TPUT
    Prepare UE0
    Attach UE0
#    sleep    10s
    Start DL TPUT for UE0
#    sleep    10s
Prepare UE0
    ${ue0_type}    ue.translate_power_ue_type_from_testline    ue_index=${0}
	set test variable    ${ue0_type}
    Prepare UE    ${ue0_type}    ue_index=${0}  reboot_ue=${True}
    sleep  10s
Attach UE0
    UE Attach    ${ue0_type}    ue_index=${0}
Start DL TPUT for UE0
    Start traffic    ue_type=${ue0_type}    ue_index=${0}    direction=dl    dt_index=${0}
	...              throughput=110M    duration=600
Detach
    ute_ue.Detach Ue  UE_1
Test Teardown
    Report  ${qc_case_name}  ${qc_case_name}   ${qc_test_set_name}   ${case_path}
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
