*** Settings ***
Documentation     author: Wang Ming
...               contact: ming.5.wang@nokia-sbell.com
...               squad group: SG_02
Suite Setup    robot_common_operations.Common Suite Setup
Suite Teardown    robot_common_operations.Common Suite Teardown
Force Tags        5G_RRM
...    PY36
Library           OperatingSystem
Library           Collections
Library           BuiltIn
Library           String
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/gnb_classical_hangzhou.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/bip_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource          ../5GC001655/Resources/1347_common_keyword.robot
Resource          ../5GC001655/Resources/5GC001116_MTK_common_keyword.robot
Resource          ../5GC000534_EB/Resources/MCS.robot
Resource          ../5GC002538/Resources/2538_keyword.robot
Resource          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001655/Resources/common_keyword_RRM_SG2.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/btslog.robot


*** Variables ***
${tl_path}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}

${scf_path}    /home/ute/Downloads/SCF

${_scf_1086_b_5}     ${scf_path}/1086_b_5.xml
${_scf_1086_b_3}     ${scf_path}/1086_b_3.xml
${_scf_1086_b_4}     ${scf_path}/1086_b_4.xml
${_scf_1086_c_1}     ${scf_path}/1086_c_1.xml
${_scf_1086_c_8}     ${scf_path}/1086_c_8.xml
${_scf_1086_d_2}     ${scf_path}/1086_d_2.xml
${_scf_1086_e_3}     ${scf_path}/1086_e_3.xml
${_scf_1086_g_2}     ${scf_path}/1086_g_2.xml
${_scf_1086_g_5}     ${scf_path}/1086_g_5.xml
${tmp_swconfig_dir}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/swconfig.txt
${ul_srs}      \"uldata_srsreceivereq\"
${srs_command_template}     {tshark_path} -r {pcap_file}
...      -Y ${ul_srs} -T pdml
${srs_bm}      UlData_srsReceiveReqSubcell_t.srsBmEnable
${sumimo}      UlData_srsReceiveReqSubcell_t.srsSuMimoEnable
${luashark_path_22R1}      /home/ute/Downloads/Lua/generated_luashark_SBTS22R1/luashark.lua
${luashark_path_22R2}    /home/ute/Downloads/Lua/generated_luashark_SBTS22R2/luashark.lua
${luashark_path_22R3}    /home/ute/Downloads/Lua/generated_luashark_SBTS22R3/luashark.lua
${luashark_path_22R4}    /home/ute/Downloads/Lua/generated_luashark_SBTS22R4/luashark.lua
${luashark_path_trunk}    /home/ute/Downloads/Lua/generated_luashark_TRUNK/luashark.lua
${tshark_path}    /usr/bin/tshark
@{beamset_horizontal}    -26    -26    0    0    26    26    0    0    -26    -26    0    0    26    26    0    0
@{beamset_vertical}    96    96    96    96    96    96    96    96    96    96    96    96    96    96    102    102
${pa_value}    25
@{pa_port}    1    2    3    4    5    6    7    8    9    10    11    12    13    14    15    16    17    18
...    19    20    21    22    23    24    25    27    28    29    30    31    32

@{check_print}    ERR/

*** Test Cases ***
[1]5GC001086-B_01_Single_UE_access_network_with_SU-MIMO_support_nrofSRS-Ports_port2_connected
    [Tags]    5GC001086    CIT_TRUNK
    [Setup]    Case Setup
    Reload Case SCF and Commission    scf_file=${scf_path}/${version}/1086_01.xml
    COAM Wait for gnb ready and cell setup    gnb_type='NSA'
#    Set Test Variable    ${num}    ${1}
#    Multi UE Attach And Send UL Traffic    num=${num}
    UE Attach And Send UL Traffic
    ${xz_file}    Download File From ASIK To TestPC    log_prefix=startup_cp_rt    path=/ffs/run/logs/CPRT00_aasyslog
    Set Test Variable    ${unxz_command}    unxz ${xz_file}[0]
    Run    ${unxz_command}
    Run Keyword And Ignore Error    Check CPRT Log Result    gain_value=-138    pSRSact=true    occasiondelay=86   runum_row=8
    ...    runum_col=4    num_row=NUMBEROFCOLTRX_8    num_col=NUMBEROFROWTRX_4
    Check SRS Enable From Bip File
    [Teardown]    Case Teardown

[1]5GC001086-B_05_Single_UE_access_network_with_SU-MIMO_support_nrofSRS-Ports_port2_connected
    [Tags]    5GC001086    CIT_22R2
    [Setup]    Case Setup
    Reload Case SCF and Commission    scf_file=${_scf_1086_b_5}
    COAM Wait for gnb ready and cell setup    gnb_type='NSA'
    Set Test Variable    ${num}    ${1}
    Multi UE Attach And Send UL Traffic    num=${num}
    ${fbb_type}    COAM Get FBB Type
    Capture BIP Log and Download By Web
    ${xz_file}    Download File From ASIK To TestPC    log_prefix=startup_cp_rt    path=/ffs/run/logs/CPRT00_aasyslog
    Set Test Variable    ${unxz_command}    unxz ${xz_file}[0]
    Run    ${unxz_command}
    Run Keyword And Ignore Error    Check CPRT Log Result    gain_value=-138    pSRSact=true    occasiondelay=26
    ...  runum_row=8     runum_col=4    num_row=NUMBEROFCOLTRX_8    num_col=NUMBEROFROWTRX_4
    Check SRS Enable From Bip File
    [Teardown]    Case Teardown

[1]5GC001086-B_03_Single_UE_access_network_with_SU-MIMO_with_different_frame_structure_OTA
    [Tags]    5GC001086    CIT_22R2
    [Setup]    Case Setup
    Reload Case SCF and Commission    scf_file=${_scf_1086_b_3}
    COAM Wait for gnb ready and cell setup    gnb_type='NSA'
    Set Test Variable    ${num}    ${1}
    Multi UE Attach And Send UL Traffic    num=${num}
    ${fbb_type}    COAM Get FBB Type
    Capture BIP Log and Download By Web
    ${xz_file}    Download File From ASIK To TestPC    log_prefix=startup_cp_rt    path=/ffs/run/logs/CPRT00_aasyslog
    Set Test Variable    ${unxz_command}    unxz ${xz_file}[0]
    Run    ${unxz_command}
    Run Keyword And Ignore Error    Check CPRT Log Result    gain_value=-138    pSRSact=true    occasiondelay=86
    ...  runum_row=8    runum_col=4    num_row=NUMBEROFCOLTRX_8    num_col=NUMBEROFROWTRX_4
    Check SRS Enable From Bip File
    [Teardown]    Case Teardown

[1]5GC001086-B_04_Single_UE_access_network_with_SU-MIMO_with_different_frame_structure
    [Tags]    5GC001086    CIT_22R2
    [Setup]    Case Setup
    Reload Case SCF and Commission    scf_file=${_scf_1086_b_4}
    COAM Wait for gnb ready and cell setup    gnb_type='NSA'
    ${xz_file}    Download File From ASIK To TestPC    log_prefix=startup_cp_rt    path=/ffs/run/logs/CPRT00_aasyslog
    Set Test Variable    ${unxz_command}    unxz ${xz_file}[0]
    Run    ${unxz_command}
    Run Keyword And Ignore Error    Check CPRT Log Result    gain_value=-138    pSRSact=true    occasiondelay=98   runum_row=8
    ...    runum_col=2    num_row=NUMBEROFCOLTRX_8    num_col=NUMBEROFROWTRX_2
    [Teardown]    Case Teardown

[1]5GC001086-C_01_Verify_OAM_NIDD_Modification_mMimoAntArrayMode_with_different_frame_stucture
    [Tags]    5GC001086    CIT_22R2
    [Setup]    Case Setup
    Reload Case SCF and Commission    scf_file=${_scf_1086_c_1}
    COAM Wait for gnb ready and cell setup    gnb_type='NSA'
    Set Test Variable    ${num}    ${1}
    Multi UE Attach And Send UL Traffic    num=${num}
    ${fbb_type}    COAM Get FBB Type
    Capture BIP Log and Download By Web
    ${xz_file}    Download File From ASIK To TestPC    log_prefix=startup_cp_rt    path=/ffs/run/logs/CPRT00_aasyslog
    Set Test Variable    ${unxz_command}    unxz ${xz_file}[0]
    Run    ${unxz_command}
    Run Keyword And Ignore Error    Check CPRT Log Result    gain_value=-138    pSRSact=true    occasiondelay=86   runum_row=8
    ...    runum_col=2    num_row=NUMBEROFCOLTRX_8    num_col=NUMBEROFROWTRX_2
    Check SRS Enable From Bip File
    [Teardown]    Case Teardown

[1]5GC001086-C_08_Single_UE_access_network_UL_DL_Traffic_with_Celltype_4D4U
    [Tags]    5GC001086    CIT_22R2
    [Setup]    Case Setup
    Reload Case SCF and Commission    scf_file=${_scf_1086_c_8}
    COAM Wait for gnb ready and cell setup    gnb_type='NSA'
    Set Test Variable    ${num}    ${1}
    Multi UE Attach And Send UL Traffic    num=${num}
    ${fbb_type}    COAM Get FBB Type
    Capture BIP Log and Download By Web
    ${xz_file}    Download File From ASIK To TestPC    log_prefix=startup_cp_rt    path=/ffs/run/logs/CPRT00_aasyslog
    Set Test Variable    ${unxz_command}    unxz ${xz_file}[0]
    Run    ${unxz_command}
    Run Keyword And Ignore Error    Check CPRT Log Result    gain_value=-138    pSRSact=true    occasiondelay=98   runum_row=8
    ...    runum_col=2    num_row=NUMBEROFCOLTRX_8    num_col=NUMBEROFROWTRX_2
    Check SRS Enable From Bip File
    [Teardown]    Case Teardown

[1]5GC001086-D_02_Cell_Setup_with_2cell_per_loki_with_1RFU_full_split_mode_1CC+1CC
    [Tags]    5GC001086    CIT_22R2
    [Setup]    Case Setup
    Reload Case SCF and Commission    scf_file=${_scf_1086_d_2}
    COAM Wait for gnb ready and cell setup    gnb_type='NSA'
    Set Test Variable    ${num}    ${1}
    Multi UE Attach And Send UL Traffic    num=${num}
    ${fbb_type}    COAM Get FBB Type
    Capture BIP Log and Download By Web
    ${xz_file}    Download File From ASIK To TestPC    log_prefix=startup_cp_rt    path=/ffs/run/logs/CPRT00_aasyslog
    Set Test Variable    ${unxz_command}    unxz ${xz_file}[0]
    Run    ${unxz_command}
    Run Keyword And Ignore Error    Check CPRT Log Result    gain_value=-138    pSRSact=true    occasiondelay=86   runum_row=8
    ...    runum_col=2    num_row=NUMBEROFCOLTRX_8    num_col=NUMBEROFROWTRX_2
    Check SRS Enable From Bip File
    [Teardown]    Case Teardown

[1]5GC001086-E_03_Multiple_UE_UL_DL_Traffic_with_3cell_per_loki_bandwidth_30M
    [Tags]    5GC001086    CIT_22R2
    [Setup]    Case Setup
    Reload Case SCF and Commission    scf_file=${_scf_1086_e_3}
    COAM Wait for gnb ready and cell setup    gnb_type='NSA'
    Set Test Variable    ${num}    ${1}
    Multi UE Attach And Send UL Traffic    num=${num}
    ${fbb_type}    COAM Get FBB Type
    Capture BIP Log and Download By Web
    ${xz_file}    Download File From ASIK To TestPC    log_prefix=startup_cp_rt    path=/ffs/run/logs/CPRT00_aasyslog
    Set Test Variable    ${unxz_command}    unxz ${xz_file}[0]
    Run    ${unxz_command}
    Run Keyword And Ignore Error    Check CPRT Log Result    gain_value=-138    pSRSact=true    occasiondelay=98   runum_row=8
    ...    runum_col=4    num_row=NUMBEROFCOLTRX_8    num_col=NUMBEROFROWTRX_4
    Check SRS Enable From Bip File
    [Teardown]    Case Teardown

[1]5GC001086-G_02_Single_UE_with_2D_DFT_Beam_Set_with_RF_sharing
    [Tags]    5GC001086    CIT_22R2
    [Setup]    Case Setup
    Reload Case SCF and Commission    scf_file=${_scf_1086_g_2}
    COAM Wait for gnb ready and cell setup    gnb_type='NSA'
    Set Test Variable    ${num}    ${1}
    Start Capture Pcap File On Lokki
    Multi UE Attach And Send UL Traffic    num=${num}
    Stop Capture Pcap File
    ${rrc_log}    Download File From ASIK To TestPC    log_prefix=Attachlog    path=/tmp/node_CPIF00/tmp/
    Load BIP Log with Lua Script    pcap_file=${rrc_log}[0]
    Filter Packets By Expression    filter_expression=!f1ap.initiatingMessage_element
    ${gnb_assign}    Get value from Bip Log    field_name=nr-rrc.nrofSRS_Ports
    ${ue_cap}    Get value from Bip Log    field_name=nr-rrc.maxNumberSRS_Ports_PerResource
    ${status}    Run Keyword and Return Status    Should Contain    ${ue_cap}    1
    Run Keyword If    ${status}==True    Remove values from list    ${gnb_assign}    1
    ...    ELSE    Remove values from list    ${gnb_assign}    0
    Should Be Empty    ${gnb_assign}
    ${fbb_type}    COAM Get FBB Type
    Capture BIP Log and Download By Web
    ${xz_file}    Download File From ASIK To TestPC    log_prefix=startup_cp_rt    path=/ffs/run/logs/CPRT00_aasyslog
    Set Test Variable    ${unxz_command}    unxz ${xz_file}[0]
    Run    ${unxz_command}
    Run Keyword And Ignore Error    Check CPRT Log Result    gain_value=-138    pSRSact=true    occasiondelay=98   runum_row=8
    ...    runum_col=4    num_row=NUMBEROFCOLTRX_8    num_col=NUMBEROFROWTRX_4
    Check SRS Enable From Bip File
    [Teardown]    Case Teardown

[1]5GC001086-G_05_Multiple_UE_with_L1_capacity_enhancement_Different_SRS_subband_RF_sharing
    [Tags]    5GC001086    CIT_22R2
    [Setup]    Case Setup
    Reload Case SCF and Commission    scf_file=${_scf_1086_g_5}
    COAM Wait for gnb ready and cell setup    gnb_type='NSA'
    Set Test Variable    ${num}    ${1}
    Multi UE Attach And Send UL Traffic    num=${num}
    ${fbb_type}    COAM Get FBB Type
    Capture BIP Log and Download By Web
    ${xz_file}    Download File From ASIK To TestPC    log_prefix=startup_cp_rt    path=/ffs/run/logs/CPRT00_aasyslog
    Set Test Variable    ${unxz_command}    unxz ${xz_file}[0]
    Run    ${unxz_command}
    Run Keyword And Ignore Error    Check CPRT Log Result    gain_value=-138    pSRSact=true    occasiondelay=26   runum_row=8
    ...    runum_col=4    num_row=NUMBEROFCOLTRX_8    num_col=NUMBEROFROWTRX_4
    Check SRS Enable From Bip File
    [Teardown]    Case Teardown

[1]5GC001086-W_02_Average_5G_UL_L1_Tput_with_SRS_BF_UDP_TCP
    [Tags]    5GC001086    CIT_22R2
    [Setup]    Case Setup
    Reload Case SCF and Commission    scf_file=${_scf_1086_g_2}
    COAM Wait for gnb ready and cell setup    gnb_type='NSA'
    ${nrcelst}    Get NRcellid list
    ${initial_att_values}    gnb_classical_hangzhou.Get Initial Attenuation Values For RU
    ${channels}    gnb_classical_hangzhou.Get Attenuation Channels For RU
    Set Test Variable    ${num}    ${1}
    Multi UE Attach And Send UL Traffic    num=${num}
    sleep    10s
    ${tput_log}    Capturing Aasyslog And Modify Attenuation In The Duration    channels=${channels}
    ${low_tput_result}    Run Keyword And Continue On Failure    power_ue.Check Tput    ue_type=huawei
    ...    direction=UL    log=${tput_log}    cells=${nrcelst}    target_throughput=0
    Check SRS Enable From Bip File
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    Restore Attenuation Channels    ${initial_att_values}    ${channels}
    ...    AND    Case Teardown

*** Keywords ***
Case Setup
    COAM Create log directory
    Connect to gnb coam via ssl
    ${result}    String.split string    string=${target_version}    separator=_
    Run keyword if    'SBTS00' in ${result}    set test variable    ${luashark_path}    ${luashark_path_trunk}
    ...    ELSE IF    'SBTS22R1' in ${result}    set test variable    ${luashark_path}    ${luashark_path_22R1}
    ...    ELSE IF    'SBTS22R2' in ${result}    set test variable    ${luashark_path}    ${luashark_path_22R2}
    ...    ELSE IF    'SBTS22R3' in ${result}    set test variable    ${luashark_path}    ${luashark_path_22R3}
    ...    ELSE IF    'SBTS22R4' in ${result}    set test variable    ${luashark_path}    ${luashark_path_22R4}
    Run Keyword And Ignore Error    get_spark_license_for_team    host=${tl.ues[0].ssh_connection_details.addr}
    ...    user=${tl.ues[0].licensekeeper.username}    password=${tl.ues[0].licensekeeper.password}
    ${build}    Coam Get Active SW Version
    ${result}    String.split string    string=${build}    separator=_
    robot_common_operations.Common Case Setup
    check pdl after sw update    download_dir=${TS_CASE_LOG_PATH}
    Set Test Variable     ${version}     ${result}[0]

Case Teardown
    Comment    Run Keyword And Ignore Error    Recover swconfig file
#    Run Keyword And Ignore Error    Multi UE Stop UL traffic    num=${num}
#    release_spark_license_for_team    host=${tl.ues[0].ssh_connection_details.addr}
    robot_common_operations.Common Case Teardown
    Run Keyword And Continue On Failure    Check for unexpected alarms
    Run Keyword And Continue On Failure    Save Coam Snapshot
    Run Keyword If    '${version}' == 'SBTS26R1'    Reload Case SCF and Commission    scf_file=${scf_path}/${version}/SCF_trunk_788_golden.xml
    Run Keyword And Ignore Error    COAM Teardown gnb connections
    Run keyword and ignore error    CI_interface.Common Case Teardown

MCS Set Beam
    [Arguments]    ${begin_output_port}    ${end_output_port}    ${vertical_angle}    ${horizontal_angle}
    MCS Setup    ip=${tl.mcses.ip_addr}    vendor=hbte
    FOR    ${num}    IN RANGE    ${${begin_output_port}}    ${${end_output_port}}+1
        ${index}    evaluate    ${num}-1
        MCS Set Phases According to Angles    vertical_angle=${${vertical_angle}[${index}]}
        ...    horizontal_angle=${${horizontal_angle}[${index}]}    vertical_distance=${2.1}
        ...    horizontal_distance=${0.5}    output_group_id=${num}
    END
    MCS Teardown


UE Attach For Dingli
    [Arguments]    ${ue_index}=${0}    ${attach_mode}=5G_SA
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    get_spark_license=${false}    power_reset=False
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    attach_mode=${attach_mode}    power_reset=False
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False
    [Teardown]

UE Send DL Traffic
    [Arguments]    ${ue_index}=${0}    ${send_traffic}=1500M/sec    ${send_duration}=3600   ${ue_mode}=NSA
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl
    ...    throughput=${send_traffic}    duration=${send_duration}    ue_mode=${ue_mode}

UE Send UL Traffic
    [Arguments]    ${ue_index}=${0}    ${send_traffic}=50M/sec    ${send_duration}=3600   ${ue_mode}=NSA
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul
    ...    throughput=${send_traffic}    duration=${send_duration}    ue_mode=${ue_mode}

UE Check DL Traffic
    [Arguments]    ${ue_index}=${0}    ${direction}=dl
    ${output}    spark.check_throughput_on_ue    ue_alias=UE_${ue_index}
    ${tput}    run keyword if    '${direction}'=='ul'    Evaluate    ${output[0]} / 1024 / 1024
    ...               ELSE IF    '${direction}'=='dl'    Evaluate    ${output[1]} / 1024 / 1024
    [return]    ${tput}

UE Check UL Traffic
    [Arguments]    ${ue_index}=${0}    ${direction}=ul
    ${output}    spark.check_throughput_on_ue    ue_alias=UE_${ue_index}
    ${tput}    run keyword if    '${direction}'=='ul'    Evaluate    ${output[0]} / 1024 / 1024
    ...               ELSE IF    '${direction}'=='dl'    Evaluate    ${output[1]} / 1024 / 1024
    [return]    ${tput}

Dingli Stop traffic
    [Arguments]    ${ue_index}=${0}    ${direction}=dl    ${ue_mode}=SA    ${apn_address}=ims
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=${direction}    ue_mode=${ue_mode}
    ...    ue_index=${ue_index}    apn_address=${apn_address}

Dingli Stop Ul traffic
    [Arguments]    ${ue_index}=${0}    ${direction}=ul    ${ue_mode}=SA    ${apn_address}=ims
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=${direction}    ue_mode=${ue_mode}
    ...    ue_index=${ue_index}    apn_address=${apn_address}

Multi UE Attach And Send Traffic
    [Arguments]    ${send_traffic}=400M/sec    ${send_duration}=3600    ${num}=1
    FOR    ${ue_no}    IN RANGE    ${num}
        UE Attach For Dingli    ue_index=${ue_no}
        sleep    2s
        Run Keyword And Continue On Failure    UE Send DL Traffic    ue_index=${ue_no}
        ...    send_traffic=${send_traffic}    send_duration=${send_duration}
    END

Multi UE Check DL Tput
    [Arguments]    ${num}=1    ${check_tput}=50
    FOR    ${ue_no}    IN RANGE    ${num}
        ${tput}    UE Check DL Traffic    ue_index=${ue_no}
        Run Keyword And Continue On Failure    Should Be True    ${tput}>${check_tput}
    END

Multi UE Attach And Send UL Traffic
    [Arguments]    ${send_traffic}=260M/sec    ${send_duration}=3600    ${num}=1
    FOR    ${ue_no}    IN RANGE    ${num}
        UE Attach For Dingli    ue_index=${ue_no}
        sleep    2s
        Run Keyword And Continue On Failure    UE Send UL Traffic    ue_index=${ue_no}
        ...    send_traffic=${send_traffic}    send_duration=${send_duration}
        sleep    120s
    END

UE Attach And Send UL Traffic
    [Arguments]    ${ul_tp}=200M    ${dl_tp}=1500M    ${duration}=2000    ${pci}=815
    ...    ${i}=0
    ${cells}    Get NRcellid list
    ${cell1}    Create list    ${cells}[${i}]
#    ${cell1}    Create list    12910592
    log to console    \n***Prepare UE_0***
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${1}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}
    Run keyword and ignore error    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${1}     log_type=Iperf    pci=${pci}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}    duration=${duration}    ue_index=${1}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}    duration=${duration}    ue_index=${1}
    ...                       process_num=5
    ${fbb_type}    COAM Get FBB Type
    Capture BIP Log and Download By Web
    Run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${1}
    Run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${1}

Multi UE Check UL Tput
    [Arguments]    ${num}=1    ${check_tput}=1
    FOR    ${ue_no}    IN RANGE    ${num}
        ${tput}    UE Check UL Traffic    ue_index=${ue_no}
        Run Keyword And Continue On Failure    Should Be True    ${tput}>${check_tput}
    END

Multi UE Stop traffic
    [Arguments]    ${num}=1
    FOR    ${ue_no}    IN RANGE    ${num}
        Dingli Stop traffic    ue_index=${ue_no}
    END

Multi UE Stop UL traffic
    [Arguments]    ${num}=1
    FOR    ${ue_no}    IN RANGE    ${num}
        Dingli Stop Ul traffic    ue_index=${ue_no}
        UE Detach For Dingli    ue_index=${ue_no}
    END

UE Detach For Dingli
    [Arguments]    ${ue_index}=${0}
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}    power_reset=False

Reload Case SCF and Commission
    [Arguments]    ${scf_file}
    Connect to gnb coam via ssl
    Run Keyword And Ignore Error    COAM Commission with scf file    scf_file_path=${scf_file}
    COAM Wait for gnb ready and cell setup    timeout=15 min    gnb_type='SA'

Download File From ASIK To TestPC
    [Arguments]   ${log_prefix}    ${path}    ${log_path}=${TS_CASE_LOG_PATH}    ${connection}=ASIK Master
    Connect to Common Unit Master
    @{list_log_names}    ssh_common_commands.get_file_names_under_directory    directory=${path}    connection=${connection}
    ...    file_indicator=${log_prefix}*
    should not be empty  ${list_log_names}    msg=No file found with log prefix ${log_prefix} under asik tmp folde
    @{list_log_path_local}    Create list
    FOR  ${log_name}  IN  @{list_log_names}
        Wait Until Keyword Succeeds   2 min  5 sec   csn.Download file
        ...   remote_path=${path}/${log_name}
        ...   local_path=${log_path}/${log_name}
        ...   connection=${connection}
        Append to list    ${list_log_path_local}    ${log_path}/${log_name}
    END
    [Return]    ${list_log_path_local}

Check item from crpt file
    [Arguments]    ${file_path}=${TS_CASE_LOG_PATH}/startup_cp_rt.log    ${check_value}=-138    ${check_item}="gainCorrection":(\S\d*)
    ${output}    get_value_from_log_file    file_path=${file_path}    check_item=${check_item}
    Should Contain    ${output}    ${check_value}

Get Ul SRS pdml From Bip
    [Arguments]    ${pcap_file}=${bip_log_path}    ${output}=${TS_CASE_LOG_PATH}/srs.pdml
    Set Test Variable    ${ul_command}    ${tshark_path} -r ${pcap_file} -X lua_script:${luashark_path} -Y ${ul_srs} -T pdml > ${output}
    Run    ${ul_command}

Check SRS Enable From Bip File
    [Arguments]    ${pcap_file}=${bip_log_path}    ${remove_false_value}=False    ${remove_true_value}=True
    Load BIP Log with Template Command    pcap_file=${pcap_file}    command_template=${srs_command_template}
    ${sumimo_result}    Get value from Bip Log    field_name=${sumimo}
    ${srsbm_result}    Get value from Bip Log    field_name=${srs_bm}
    should not be empty    ${srsbm_result}
    Remove values from list    ${sumimo_result}    ${remove_false_value}
    Remove values from list    ${srsbm_result}    ${remove_true_value}
    Should Be Empty    ${srsbm_result}

Restore Attenuation Channels
    [Arguments]    ${initial_att_values}    ${channels}
    ${modify_channel}    create dictionary
    ${len}    get length    ${channels}
    FOR    ${index}    IN RANGE    ${len}
        ${new_index}    evaluate    ${channels}[${index}]-1
        Set To Dictionary    ${modify_channel}    ${pa_port}[${new_index}]=${initial_att_values}[${index}]
    END
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=${modify_channel}

Start Capture Pcap File On Lokki
    [Arguments]     ${mirror_port}=any    ${filename}=Attachlog.pcap    ${asik_alias}=ASIK Master
    Connect to Common Unit Master
    Enable mirror port on Loki    mirror_port=${mirror_port}
    ${connection}    csn.get_connection_by_alias    alias=${asik_alias}
    ${channel}    Call Method    ${connection}    invoke_shell
    Call Method    ${channel}    send    lxc-attach -n 0x1514\n
    Sleep    1 sec
    Call Method    ${channel}    send    tcpdump -i any -p sctp -w /tmp/${filename}\n

Stop Capture Pcap File
    Connect to Common Unit Master
    csn.send command    command=killall tcpdump    connection=ASIK Master
    [Teardown]

Get RRC pdml From Bip
    [Arguments]    ${pcap_file}    ${output}=${TS_CASE_LOG_PATH}/rrc.pdml
    Set Test Variable    ${rrc_command}    ${tshark_path} -r ${pcap_file} -T pdml > ${output}
    Run    ${rrc_command}

Set PA Value For Attenuation Channels
    [Arguments]    ${channels}    ${pa_value}
    ${modify_channel}    create dictionary
    ${len}    get length    ${channels}
    FOR    ${index}    IN RANGE    ${len}
        ${new_index}    evaluate    ${channels}[${index}]-1
        Set To Dictionary    ${modify_channel}    ${pa_port}[${new_index}]=${pa_value}
    END
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=${modify_channel}

Capturing Aasyslog And Modify Attenuation In The Duration
    [Documentation]    Keep capturing Aasyslog for given duration.
    [Arguments]    ${channels}    ${gnb_index}=0    ${du_index}=0    ${type}=MCU   ${duration}=600s
    ...            ${Teardown_after_finished}=${True}    ${log_ip}=127.0.0.1    ${gnb_path}=/tmp/
    ...            ${log_name}=Aasys_CCS_MCU.txt    ${aa_sys_mode}=2    ${aa_sys_addr}=0x7F000001
    ...            ${aa_sys_udp_port}=0xC738    ${filter}=${EMPTY}    ${host}=${EMPTY}
    ...            ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ${host}   Run Keyword If   '${host}'==''   Get Host IP from gNB   gnb_index=${gnb_index}   du_index=${du_index}
    ...    ELSE   Set Variable   ${host}
    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    ...                                    host=${host}    username=${username}    password=${password}
    Aasyslog precondition    gnb_index=${gnb_index}    du_index=${du_index}    type=${type}
    ...                      aa_sys_mode=${aa_sys_mode}    aa_sys_addr=${aa_sys_addr}    aa_sys_udp_port=${aa_sys_udp_port}
    ...                      host=${host}    username=${username}    password=${password}
    Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    filter=${filter}
    ...                                 gnb_path=${gnb_path}    log_name=${log_name}
    ...                                 host=${host}    username=${username}    password=${password}
    ...                                 log_ip=${log_ip}    timeout=${duration}
    ${begin_value}    gnb_classical_hangzhou.Get Initial Attenuation Values For RU
    FOR    ${index}    IN RANGE    43
        ${step_pa_value}    Evaluate    ${index}+${begin_value}[0]
        Set PA Value For Attenuation Channels    channels=${channels}    pa_value=${step_pa_value}
        sleep    1s
    END
    Start Bip Log with Suitable Means
    FOR    ${index}    IN RANGE    43    53
        ${step_pa_value}    Evaluate    ${index}+${begin_value}[0]
        Set PA Value For Attenuation Channels    channels=${channels}    pa_value=${step_pa_value}
        sleep    1s
    END
    ${bip_file}    Stop Bip Log with Suitable Means
    set test variable    ${bip_log_path}    ${bip_file}[0]
    ${current_time}    DateTime.Get Current Date
    ${local_path}    set variable    ${OUTPUT_DIR}/${current_time}_${log_name}
    Download Aasyslog File From GNB    log_path=${gnb_path}${log_name}    local_path=${local_path}
    ...                                gnb_index=${gnb_index}    du_index=${du_index}
    ...                                host=${host}    username=${username}    password=${password}
    [Return]    ${local_path}
    [Teardown]    run keyword if    '${Teardown_after_finished}'=='${True}'
    ...           Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    ...                                                  host=${host}    username=${username}    password=${password}

Check CPRT Log Result
    [Arguments]    ${file_path}=${TS_CASE_LOG_PATH}/startup_cp_rt.log    ${gain_value}=-138    ${pSRSact}=true
    ...    ${occasiondelay}=98    ${runum_row}=8    ${runum_col}=2    ${num_row}=NUMBEROFCOLTRX_8    ${num_col}=NUMBEROFROWTRX_2
    ${output1}    get_value_from_log_file    file_path=${file_path}    check_item="gainCorrection":(\\S\\d*)
    ${output2}    get_value_from_log_file    file_path=${file_path}    check_item="pSRSact":(\\w{4,10})
    ${output3}    get_value_from_log_file    file_path=${file_path}    check_item="occasionDelay":(\\d{1,10})
    ${output4}    get_value_from_log_file    file_path=${file_path}    check_item="ruNumOfTrxInRow":(\\d)
    ${output5}    get_value_from_log_file    file_path=${file_path}    check_item="ruNumOfTrxInColumn":(\\d)
    ${output6}    get_value_from_log_file    file_path=${file_path}    check_item="numberOfColTRX":"(\\w{8,20})
    ${output7}    get_value_from_log_file    file_path=${file_path}    check_item="numberOfRowTRX":"(\\w{8,20})
    Should Contain    ${output1}    ${gain_value}
    Should Contain    ${output2}    ${pSRSact}
    Should Contain    ${output3}    ${occasiondelay}
    Should Contain    ${output4}    ${runum_row}
    Should Contain    ${output5}    ${runum_col}
    Should Contain    ${output6}    ${num_row}
    Should Contain    ${output7}    ${num_col}
