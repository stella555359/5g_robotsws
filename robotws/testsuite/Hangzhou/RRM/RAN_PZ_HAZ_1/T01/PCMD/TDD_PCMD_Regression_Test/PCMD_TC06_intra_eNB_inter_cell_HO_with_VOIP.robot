*** Settings ***
Documentation
...   author: zhang hancong
...   contact: hancong。zhang@nokia-sbell.com
...   this is a robot case about LTE3333.

Suite Setup       Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM
Test Setup        Common Test Setup For RRM
Test Teardown     Common Test Teardown For RRM

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
${first_cell2_id}      1231874
${first_cell3_id}      1231875
${gummei}          /460:02:2714:01

${expected_throughput}=   20Mbits/sec
${record_type}=  1      #1:normal record 2: failure record


@{check_list_86}     PRIMARY    86    NONNULL      0    1       -2147483648     2147483647
@{check_list_87}     PRIMARY    87    NONNULL      0    1       -2147483648     2147483647
@{check_list_88}     PRIMARY    88    CPLANE       0    2       1       5		 #upper and lower limit are mandatory
@{check_list_89}     PRIMARY    89    CPLANE       0    202     101     510
@{check_list_90}     PRIMARY    90    CPLANE       0    2
@{check_list_91}     PRIMARY    91    NONNULL      40   8472    0       4294967295       #mac ps
@{check_list_92}     PRIMARY    92    NONNULL      40   8472    0       10000            #mac ps
@{check_list_93}     PRIMARY    93    NONNULL      0    1       0       10000            #mac ps
@{check_list_94}     PRIMARY    94    NONNULL      0    1       0       65535            #mac ps
@{check_list_95}     PRIMARY    95    NONNULL      0    1       0       65535            #mac ps
@{check_list_96}     PRIMARY    96    NONNULL      40   1801    0       4294967295       #mac ps
@{check_list_97}     PRIMARY    97    NONNULL      40   14677   0       4294967295       #mac ps
@{check_list_98}     PRIMARY    98    NONNULL      40   14677   0       4294967295       #mac ps
@{check_list_99}     PRIMARY    99    CPLANE       20   0       0       1500             #mac ps
#@{check_list_100}    PRIMARY    100    NONNULL     20   14     0       1500             #mac ps, relate the tm3 or tm4
# mac ps, belong with the platform,the value of them will be set to  if TA=0 in your platform, my platform ta = 16
@{check_list_112}    PRIMARY    112   NONNULL      0    0       0       65535
# mac ps, belong with the platform,the value of them will be set to if TA=0 in your platform, my platform ta = 16
@{check_list_113}    PRIMARY    113   NONNULL      0    16      0       65535
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
# mac ps,CAActivation Duration 2DLCAActivation Duration 2DL
@{check_list_266}    PRIMARY    266   NONNULL      80   15000		0				86400000
# mac ps,CAActivation Duration 3DLCAActivation Duration 3DL
@{check_list_267}    PRIMARY    267   NONNULL      80   15000   0				86400000

#@{check_list_21}     PRIMARY     21    NONNULL     0    1      #temp
#@{check_list_41}     PRIMARY     41    NONNULL     0    2      #temp
@{check_list_101}    PRIMARY    101    NONNULL     0    2		-2147483648		2147483647
@{check_list_102}    PRIMARY    102    CPLANE      0    0
@{check_list_116}    PRIMARY    116    CPLANE      0    1		1		2           #hardcode to 1 by NPC
@{check_list_119}    PRIMARY    119    CPLANE      1    1		1		2           #hardcode to 1 by NPC
@{check_list_122}    PRIMARY    122    CPLANE      0    1		1               #hardcode to 1 by NPC
@{check_list_127}    PRIMARY    127    NONNULL     0    3		0		3
@{check_list_131}    PRIMARY    131    NONNULL     0    2
@{check_list_132}    PRIMARY    132    NONNULL     0    1
@{check_list_133}    PRIMARY    133    CPLANE      0    3
@{check_list_135}    PRIMARY    135    CPLANE      0    4		2		8
@{check_list_137}    PRIMARY    137    CPLANE      0    1		1		14
@{check_list_140}    PRIMARY    140    NONNULL     80   15000		-2147483648		2147483647
@{check_list_141}    PRIMARY    141    CPLANE      0    1		1		3
@{check_list_152}    PRIMARY    152    CPLANE      0    7		1		6
@{check_list_155}    PRIMARY    155    NONNULL     0    4		-2147483648		2147483647
#@{check_list_156}    PRIMARY    156    NONNULL     0    4		-2147483648		2147483647
@{check_list_157}    PRIMARY    157    CPLANE       0    4		1		4
@{check_list_163}    PRIMARY    163    NONNULL      0    67328		65536		16777215        #L3DC related version
@{check_list_164}    PRIMARY    164    NONNULL      0    0		-2147483648		2147483647
@{check_list_166}    PRIMARY    166    NONNULL      0    0		0		15
@{check_list_173}    PRIMARY    173    CPLANE       0    2                      #numberof secondary record  ???
#@{check_list_189}    PRIMARY    189    CPLANE       0    1		0		2147483647
@{check_list_206}    PRIMARY    206    NONNULL      80   15000		0		10000
@{check_list_212}    PRIMARY    212    NONNULL      20   6350		1		256                #band related
@{check_list_217}    PRIMARY    217    CPLANE       0    1		1
@{check_list_219}    PRIMARY    219    CPLANE       0    1		1		3
@{check_list_220}    PRIMARY    220    CPLANE       0    1		1		3
@{check_list_221}    PRIMARY    221    CPLANE       0    1		1		3
@{check_list_223}    PRIMARY    223    CPLANE       0    3349		0		65535    #1295      #UE related
@{check_list_224}    PRIMARY    224    NONNULL      0    1028
@{check_list_235}    PRIMARY    235    NONNULL      0    476200		0		2147483647
@{check_list_236}    PRIMARY    236    NONNULL      0    2		0		16777215
@{check_list_237}    PRIMARY    237    NONNULL      0    1		-2147483648		2147483647
@{check_list_238}    PRIMARY    238    CPLANE       0    1		1		8
@{check_list_239}    PRIMARY    239    CPLANE       0    1		1		8
@{check_list_241}    PRIMARY    241    CPLANE       0    0		0		1
@{check_list_242}    PRIMARY    242    CPLANE       0    0		0		1
@{check_list_243}    PRIMARY    243    NONNULL      20   6350		-2147483648		2147483647
@{check_list_244}    PRIMARY    244    NONNULL      20   6350		-2147483648		2147483647
@{check_list_245}    PRIMARY    245    NONNULL      0    16		-2147483648		2147483647
#@{check_list_246}    PRIMARY    246    NONNULL      0    0		0		86400000
@{check_list_247}    PRIMARY    247    CPLANE       0    2		1		8
@{check_list_248}    PRIMARY    248    CPLANE       0    4		2		4
@{check_list_249}    PRIMARY    249    CPLANE       0    4		1		4
@{check_list_250}    PRIMARY    250    CPLANE       0    4		2		4
@{check_list_251}    PRIMARY    251    NONNULL      0    900
@{check_list_251_2}     PRIMARY    251    NONNULL     0    900           # cell1(429) band12
@{check_list_252}     PRIMARY    252    NONNULL     0     386139393  #4294901762
@{check_list_252_2}     PRIMARY    252    NONNULL     0    151127297
@{check_list_259}     PRIMARY    259    NONNULL     0    14248		1		65523
@{check_list_282}      PRIMARY    282    CPLANE     0     33554431  #16715535       #first HO cell1(429) to cell 2(441)
@{check_list_282_2}     PRIMARY    282    CPLANE     0     33492991  #16715535     #Second HO cell2(441) to cell 1(429)


@{check_list_6}      SECONDARY    6     CPLANE      0     5     1       9                #default bear info   #check 5
@{check_list_8}      SECONDARY    8     CPLANE      0     5     1       15               #default bear info  # check 6
@{check_list_15}     SECONDARY    15    NONNULL     0     1     0       4294967295
@{check_list_16}     SECONDARY    16    NONNULL     0     1     0       4294967295
@{check_list_17}     SECONDARY    17    NONNULL     0     1     0       4294967295
@{check_list_18}     SECONDARY    18    NONNULL     0     1     0       4294967295
@{check_list_19}     SECONDARY    19    NONNULL     0     1     0       4294967295
@{check_list_20}     SECONDARY    20    NONNULL     0     1     0       4294967295
@{check_list_22}     SECONDARY    22    NONNULL     0     1     0       4294967295
@{check_list_23}     SECONDARY    23    NONNULL     0     1     0       4294967295
@{check_list_34}     SECONDARY    34    NONNULL     0     0     0       4294967295           #mac ps
@{check_list_35}     SECONDARY    35    NONNULL     0     1     0       4294967295           #mac ps

@{check_list_QCI_1}      TERTIARY    1    QCI_NONNULL     1     1
@{check_list_Teritary_4}       TERTIARY    4    QCI_NONNULL     1     7
@{check_list_Teritary_12}     TERTIARY    12    QCI_NONNULL     1     1
@{check_list_Teritary_13}     TERTIARY    13    QCI_NONNULL     1     1
@{check_list_Teritary_14}     TERTIARY    14    QCI_NONNULL     1     1
@{check_list_Teritary_15}     TERTIARY    15    QCI_NONNULL     1     1
@{check_list_Teritary_16}     TERTIARY    16    QCI_NONNULL     1     1
@{check_list_Teritary_17}     TERTIARY    17    QCI_NONNULL     1     1
@{check_list_Teritary_20}     TERTIARY    20    QCI_NONNULL     1     1
@{check_list_Teritary_31}     TERTIARY    31    QCI_NONNULL     1    1

@{meas_report_2}      CELLMRPT    2     CPLANE      0     85    #462               #first HO cell1(429) to cell 2(441)
@{meas_report_2_2}      CELLMRPT    2     CPLANE      0     87    #462             #Second HO cell2(441) to cell 1(429)
@{meas_report_3}      CELLMRPT    3     NONNULL     0     0
@{meas_report_4}      CELLMRPT    4     NONNULL     0     0
@{meas_report_5}      CELLMRPT    5     NONNULL     0     0

@{sum_list_1}       ${check_list_86}    ${check_list_87}    ${check_list_88}    ${check_list_89}    ${check_list_90}
...    ${check_list_91}    ${check_list_92}     ${check_list_93}     ${check_list_94}      ${check_list_95}
...    ${check_list_96}    ${check_list_97}     ${check_list_98}     ${check_list_101}   ${check_list_102}
...    ${check_list_112}        ${check_list_114}    ${check_list_115}     ${check_list_116}
...    ${check_list_117}   ${check_list_118}    ${check_list_119}   ${check_list_120}
...    ${check_list_121}   ${check_list_122}    ${check_list_123}    ${check_list_124}     ${check_list_125}
...    ${check_list_126}   ${check_list_127}    ${check_list_131}   ${check_list_132}    ${check_list_133}
...    ${check_list_137}
...    ${check_list_141}    ${check_list_142}    ${check_list_143}    ${check_list_144}    ${check_list_152}
...    ${check_list_154}    ${check_list_155}   ${check_list_157}    ${check_list_163}    ${check_list_164}
...    ${check_list_166}
...    ${check_list_173}    ${check_list_196}    ${check_list_197}    ${check_list_208}    ${check_list_209}
...    ${check_list_210}
...    ${check_list_211}    ${check_list_212}    ${check_list_215}    ${check_list_216}    ${check_list_217}
...    ${check_list_218}    ${check_list_219}
...    ${check_list_220}    ${check_list_223}    ${check_list_235}    ${check_list_236}     #${check_list_238}
...    ${check_list_241}    ${check_list_242}    ${check_list_247}    ${check_list_248}
...    ${check_list_251}    ${check_list_252}    ${check_list_259}    ${check_list_282}
...    ${check_list_6}      ${check_list_8}      ${check_list_15}     ${check_list_16}     ${check_list_17}
...    ${check_list_18}    ${check_list_19}   ${check_list_20}    ${check_list_22}    ${check_list_23}
...    ${check_list_34}
...    ${meas_report_2}    ${meas_report_3}    ${meas_report_4}    ${meas_report_5}


@{sum_mac_ps_list_1}    ${check_list_88}    ${check_list_89}    ${check_list_90}
...    ${check_list_91}     ${check_list_92}     ${check_list_93}     ${check_list_94}      ${check_list_95}
...    ${check_list_96}     ${check_list_97}     ${check_list_98}
...    ${check_list_112}    ${check_list_113}    ${check_list_114}    ${check_list_115}     ${check_list_117}
...    ${check_list_118}    ${check_list_120}
...    ${check_list_121}    ${check_list_123}    ${check_list_124}    ${check_list_125}     ${check_list_126}
...    ${check_list_142}    ${check_list_143}    ${check_list_144}    ${check_list_154}
...    ${check_list_196}    ${check_list_197}    ${check_list_208}    ${check_list_209}     ${check_list_210}
...    ${check_list_211}    ${check_list_215}    ${check_list_216}    ${check_list_218}     ${check_list_258}
...    ${check_list_6}      ${check_list_8}     #${check_list_34}    ${check_list_35}

@{sum_list_2}     ${check_list_86}    ${check_list_87}    ${check_list_88}    ${check_list_89}    ${check_list_90}
...    ${check_list_91}    ${check_list_92}     ${check_list_93}     ${check_list_94}      ${check_list_95}
...    ${check_list_96}    ${check_list_97}     ${check_list_98}
...    ${check_list_101}   ${check_list_102}
...    ${check_list_112}   ${check_list_113}    ${check_list_114}    ${check_list_115}     ${check_list_116}
...    ${check_list_117}   ${check_list_118}    ${check_list_119}   ${check_list_120}
...    ${check_list_121}   ${check_list_122}    ${check_list_123}    ${check_list_124}     ${check_list_125}
...    ${check_list_126}   ${check_list_127}    ${check_list_131}   ${check_list_132}    ${check_list_133}
...    ${check_list_137}
...    ${check_list_141}    ${check_list_142}    ${check_list_143}    ${check_list_144}    ${check_list_152}
...    ${check_list_154}    ${check_list_155}    ${check_list_157}    ${check_list_163}    ${check_list_164}
...    ${check_list_166}
...    ${check_list_173}    ${check_list_196}    ${check_list_197}    ${check_list_208}    ${check_list_209}
...    ${check_list_210}
...    ${check_list_211}    ${check_list_212}    ${check_list_215}    ${check_list_216}    ${check_list_217}
...    ${check_list_218}    ${check_list_219}
...    ${check_list_220}    ${check_list_223}    ${check_list_235}    ${check_list_236}
...    ${check_list_241}    ${check_list_242}    ${check_list_247}    ${check_list_248}
...    ${check_list_251_2}    ${check_list_252_2}    ${check_list_259}    ${check_list_282_2}
...    ${check_list_6}      ${check_list_8}      ${check_list_15}     ${check_list_16}     ${check_list_17}
...    ${check_list_18}    ${check_list_19}   ${check_list_20}    ${check_list_22}    ${check_list_23}
...    ${meas_report_2_2}    ${meas_report_3}    ${meas_report_4}    ${meas_report_5}

@{sum_list_3}    ${check_list_221}    ${check_list_224}    ${check_list_237}    ${check_list_239}
...             ${check_list_249}    ${check_list_250}
&{check_filter_1}       88=2    89=202    90=2
&{check_filter_2}    88=1    89=101    90=58
*** Test Cases ***
Test case senario
#    Save created delta to file and perform recommissioning
	log        start Enable_Cell2_Disalbe_Cell3
    Start attenuator Enable_Cell2_Disalbe_Cell3
#    Reserve UE for tests
#    Attach Ue For Test
#    Ue Show Basic Info    UE_1
#    ${cell_id_1}    ue get cellid    UE_1
    Prepare UE0
    log        start get wirheshark logs    console=yes
    Start tcpdump by command
    Attach UE0
    ${ue_ip}    Get the UE Ip address
    # 4600* is UE imsi  5 is the QCI bearer 10.85* is the appserver 135.252.251.5
    make ue bearer     460003031393392     ${ue_ip}    1    10.70.14.251    1
    Start DL TPUT for UE0
    sleep    10s
	log        start Enable_Cell3_Disalbe_Cell2
    Start attenuator Enable_Cell3_Disalbe_Cell2
    sleep    10s
#    Await Data Transfer Finish      DT_1      # blocks your thread, error when duration=forver, without timeout arg
#    Ue Show Basic Info    UE_1
#    ${cell_id_2}    ue get cellid    UE_1
    Start DL TPUT for UE0
    sleep    10s
#    Ue Show Basic Info    UE_1
#    ${cell_id_3}    ue get cellid    UE_1
#    Await Data Transfer Finish      DT_1      # blocks your thread, error when duration=forver, without timeout arg
    Detach UE0
    log        stop get wirheshark logs     console=yes
    Stop tcpdump by command
    sleep  30s
    ${time_system}       get sys time
    Log to console    check PCMD
    Save Pcmd Log from MNI    ${gummei}    ${TEST_LOG_DIRECTORY}
    ...                       t_detach=${time_system}    cell_id=${first_cell2_id}
    ...                       record_type=${record_type}    &{check_filter_1}
    sleep  5s
    ${check_result}=    Check Pcmd Record from MNI    ${TEST_LOG_DIRECTORY}    input_pcmd_array=${sum_list_1}
    log        ${check_result}
    should be true    ${check_result}
#   should not be equal as numbers    ${cell_id_2}      ${cell_id_3
    Log to console    check PCMD
    Save Pcmd Log from MNI    ${gummei}    ${TEST_LOG_DIRECTORY}
    ...                       t_detach=${time_system}    cell_id=${first_cell3_id}
    ...                       record_type=${record_type}    &{check_filter_2}
    sleep  5s
    ${check_result}=    Check Pcmd Record from MNI    ${TEST_LOG_DIRECTORY}    input_pcmd_array=${sum_list_2}
    log        ${check_result}
    should be true    ${check_result}



*** Keywords ***
Start attenuator Enable_Cell2_Disalbe_Cell3
        Log to console    Adjust PA Signal
    ${attenuation_channels}     Get Attenuation port    RU_id=0    gnb_id=0
    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=HBTE    gnb_id=0
    &{channels_to_modify}    create dictionary
    ...    ${attenuation_channels[0]}=63    ${attenuation_channels[1]}=63
    ...    ${attenuation_channels[2]}=0    ${attenuation_channels[3]}=0
    ...    ${attenuation_channels[8]}=63    ${attenuation_channels[9]}=63
    ...    ${attenuation_channels[14]}=40    ${attenuation_channels[15]}=40
    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    gnb_id=0
    sleep    10s
    Log to console    attenuation change complete
Start attenuator Enable_Cell3_Disalbe_Cell2
        Log to console    Adjust PA Signal
    ${attenuation_channels}     Get Attenuation port    RU_id=0    gnb_id=0
    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=HBTE    gnb_id=0
    &{channels_to_modify}    create dictionary
    ...    ${attenuation_channels[0]}=63    ${attenuation_channels[1]}=63
    ...    ${attenuation_channels[2]}=40    ${attenuation_channels[3]}=40
    ...    ${attenuation_channels[8]}=63    ${attenuation_channels[9]}=63
    ...    ${attenuation_channels[14]}=0    ${attenuation_channels[15]}=0
    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    gnb_id=0
    sleep    10s
    Log to console    attenuation change complete
Start tcpdump by command
    Log to console    start tcpdumplog
    ${tcpdump_log_name}    Start tcpdump in SBTS by command    connection=First_ASIB
	set test variable    ${tcpdump_log_name}
Stop tcpdump by command
	Stop tcpdump in SBTS by command
	${capture_file_path}    Download wireshark log to testvm    tcpdump_log_name=${tcpdump_log_name}
	set test variable    ${capture_file_path}
Prepare UE0
    ${ue0_type}    ue.translate_power_ue_type_from_testline    ue_index=${0}
	set test variable    ${ue0_type}
    Prepare UE    ${ue0_type}    ue_index=${0}
Attach UE0
    UE Attach    ${ue0_type}    ue_index=${0}
Start DL TPUT for UE0
    Start traffic    ue_type=${ue0_type}    ue_index=${0}    direction=dl    dt_index=${0}
	...              throughput=110M    duration=600
Detach UE0
    UE Detach    ${ue0_type}    ue_index=${0}
Save created delta to file and perform recommissioning
    Setup Admin    bts_host=192.168.255.129    bts_port=443    use_ssl=True    alias=SCFC
    Create delta  bts_name_update
    Append parameter update to delta  MRBTS-1982/LNBTS-5036   actIfHo    enabled   delta_id=bts_name_update
    Append parameter update to delta  MRBTS-1982/LNBTS-5036/LNCEL-1
    ...                               a2TimeToTriggerActInterFreqMeas   40ms  delta_id=bts_name_update
    Append parameter update to delta  MRBTS-1982/LNBTS-5036/LNCEL-3
    ...                               a2TimeToTriggerActInterFreqMeas   40ms  delta_id=bts_name_update

Test Teardown

    Report  ${qc_case_name}  ${qc_case_name}   ${qc_test_set_name}   ${case_path}

