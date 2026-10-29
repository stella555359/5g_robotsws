*** Settings ***
Resource    ./Resources/CB008227_common_keywords.robot
Variables    ./Resources/CB008227_Variables.py


Documentation
...   author: xiaodan.li
...   contact: xiaodan.li@nokia-sbell.com
...   squad group: SG_03
...   Feature CB008227-E

Suite Setup    Run Keywords
...    Common Suite Setup for COAM    AND
...    Adjust gNB_RU Attenuation    AND
...    Adjust gNB_RU Attenuation    tl=${gnb_instance}_UE2

Suite Teardown    Run Keywords
...               Common Suite Teardown for COAM   AND
...               Adjust gNB_RU Attenuation    AND
...               Adjust gNB_RU Attenuation    tl=${gnb_instance}_UE2

*** Variables ***
${golden_scf_name_E003_gnb2}    8227_E003_SCF_gnb2
${golden_scf_name_E007}    8227_E007_SCF
${golden_scf_name}    7326_784_SCF
${scf_path}    /opt/workspace/CRT/Master/SCF_file/
${epc_log_path}    /opt/workspace/CRT/Master/Case_Logs/
${ue_type}    ${tl.ues[0].capabilities[0]}
${ue1_type}    ${tl.ues[1].capabilities[0]}
${mdrb_apn_name}    ${tl.ues[0].pdn[2]}
${dxdata2_apn_name}    ${tl.ues[0].pdn[0]}
${dl_throughput}    600M
${dl_throughput_400M}    400M
${dl_port_5QI7}    ${53380}
${dl_port_5QI8}    ${55378}
${dl_port_5QI7_UE1}    ${53385}
@{dl_ports}    ${dl_port_5QI7}    ${dl_port_5QI8}
@{gnb_list_E}    ${0}    ${1}
${log_name_E_003}    8227_E003_NSA_CA_Attach.pcap
${log_name_E_003_1}    8227_E003_NSA_CA_Attach_1.pcap
${log_name_E_003_2}    8227_E003_NSA_CA_Attach_2.pcap
${log_name_E_003_3}    8227_E003_NSA_CA_Attach_3.pcap
${log_name_E_003_enb}    8227_E003_NSA_CA_Attach_enb.pcap
${log_name_E_003_1_enb}    8227_E003_NSA_CA_Attach_1_enb.pcap
${log_name_E_003_2_enb}    8227_E003_NSA_CA_Attach_2_enb.pcap
${log_name_E_003_3_enb}    8227_E003_NSA_CA_Attach_3_enb.pcap
${log_name_E_003_test_A2}    8227_E003_NSA_CA_Attach_test_A2.pcap
${log_name_E_003_test_A2_enb}    8227_E003_NSA_CA_Attach_test_A2_ENB.pcap

${file_name_E003}    8227_E003_CA_NBR_UE2
${file_name_E003_1}    8227_E003_CA_NBR_UE2_1
${file_name_E003_2}    8227_E003_CA_NBR_UE2_2
${file_name_E003_3}    8227_E003_CA_NBR_UE2_3
${file_name_E003_4}    8227_E003_CA_NBR_UE1
${file_name_E003_5}    8227_E003_CA_NBR_UE2_4
${file_name_E003_6}    8227_E003_CA_NBR_UE1_1
${file_name_E003_before_A2}    8227_E003_CA_NBR_UE1_before_A2
${file_name_E003_A2release}    8227_E003_CA_NBR_UE1_A2release
${log_name_E_007_1}    8227_E007_Inter_CA_Attach.pcap
${file_name_E007}    8227_E007_CA_Not_NBR_UE2
${file_name_E007_1}    8227_E007_CA_NBR_UE2_1
${file_name_E007_2}    8227_E007_CA_NBR_UE2_2
${file_name_E007_3}    8227_E007_CA_NBR_UE2_3
${log_name_E_007_test}    8227_E007_Inter_CA_in_total_test.pcap

@{dl_ports_UE1}    ${dl_port_5QI7_UE1}
@{ue1_index_list}    ${0}
@{ue2_index_list}    ${1}    ${1}
@{value_E003}     ${1}
@{allow_fault_list}    7311    7307

${att_port_1_gnb1_cell1_37611_UE2}                ${tl.attenuator[1].attenuator_ports[5].port_no}
${att_port_2_gnb1_cell1_37611_UE2}                ${tl.attenuator[1].attenuator_ports[6].port_no}
${att_port_3_gnb1_cell1_37611_UE2}                ${tl.attenuator[1].attenuator_ports[7].port_no}
${att_port_4_gnb1_cell1_37611_UE2}                ${tl.attenuator[1].attenuator_ports[8].port_no}
${att_port_1_gnb2_cell1_37611_UE2}                ${tl.attenuator[1].attenuator_ports[13].port_no}
${att_port_2_gnb2_cell1_37611_UE2}                ${tl.attenuator[1].attenuator_ports[14].port_no}
${att_port_3_gnb2_cell1_37611_UE2}                ${tl.attenuator[1].attenuator_ports[15].port_no}
${att_port_4_gnb2_cell1_37611_UE2}                ${tl.attenuator[1].attenuator_ports[16].port_no}

*** Test Cases ***
[1]CB008227_E_07_B3_Nominal_Bitrate_interworking_with_inter_gNB_DL_CA_with_NBR_congetion_control_pooling
    [Documentation]    This user scenario describes Nominal Bitrate interworking with DL CA.
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=7311,7107
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    ###case setup
    Common Case TestLine Setup for E007
    Online modify parmeters    gnb_index=${0}    parameters_to_update=${PARAMETERS_TO_ONLINE_MODIFY_GNB1}
    ...    skip_parameter_relation_errors=False
    put btslog_ini file to ute
    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
    Start capture syslog via btslog on ute
    ###prepare UE
    power_ue.Prepare UE    ue_type=${ue1_type}    ue_index=${1}
#    Andriod UE adb reboot    ue_index=${1}
    Adjust gNB_RU Attenuation    tl=${gnb_instance}_UE2    gnb1_cell1_value=${50}    gnb2_cell1_value=${33}
    Attach and collect log    filename=${log_name_E_007_1}    4G_check=False
    Start capture gNB log on master    filename=${log_name_E_007_test}    gNB_index=${0}
    Start DL Traffic    dl_ports=${dl_ports}    dl_throughput=${dl_throughput}    ue_index_list=${ue2_index_list}
    ...    cap_index=${1}    times=5400
    sleep    20s
    Comment   step1 check NBR DRB7 and NBR DRB8 traffic are the same
    ${Gap1}    Check inter CA NBR Congetion    file_name=${file_name_E007}
    ...    gnb1_cell1_origin_value=${50}    gnb1_cell1_target_value=${51}    gnb2_cell1_origin_value=${33}    gnb2_cell1_target_value=${34}
    ...    value_NBR_min=${490}    value_NBR_max=${550}    value_nNBR_min=${490}    value_nNBR_max=${550}
    ${Gap1}    Evaluate    abs(${Gap1})
    Should be true    ${0}<=${Gap1}<=${30}
    Stop capture syslog via btslog on ute
    Comment    step2 check triger the DRB7 NBR but not Congetion(the traffic difference between 5QI7 and 5QI9 Traffic is approximately 200M)
    ${Gap2}    Check inter CA NBR Congetion    file_name=${file_name_E007_1}
#    ...    gnb1_cell1_origin_value=${50}    gnb1_cell1_target_value=${72}    gnb2_cell1_origin_value=${33}    gnb2_cell1_target_value=${50}
    ...    gnb1_cell1_origin_value=${50}    gnb1_cell1_target_value=${72}    gnb2_cell1_origin_value=${33}    gnb2_cell1_target_value=${49}
    ...    value_NBR_min=${440}    value_NBR_max=${500}    value_nNBR_min=${250}    value_nNBR_max=${310}
    Should be true    ${100}<=${Gap2}<=${250}
    Comment    step3 check triger (Pcell DRB7 NBR Congetion+counter) and  (Scell not Congetion +counter=0)
    ...        (the traffic difference between 5QI7 and 5QI9 Traffic is approximately 100M)
    ${Gap3}    Check inter CA NBR Congetion    file_name=${file_name_E007_2}
    ...    gnb1_cell1_origin_value=${71}    gnb1_cell1_target_value=${78}    gnb2_cell1_origin_value=${48}    gnb2_cell1_target_value=${49}
#    ...    gnb1_cell1_origin_value=${67}    gnb1_cell1_target_value=${77}    gnb2_cell1_origin_value=${48}    gnb2_cell1_target_value=${49}
    ...    value_NBR_min=${350}    value_NBR_max=${450}    value_nNBR_min=${230}    value_nNBR_max=${300}
    Should be true    ${10}<=${Gap3}<=${150}
    should be true    ${gap2}>${gap3}
    Wait until keyword succeeds    20 min    3s    Check NBR Congetion Counter    value_1=${300}    value_Average=${1}
    ...    counter_id=${counter_id_D01_gNB1}    counter_dic_path=${counter_dic_path_D01_gNB1}    gnb_index=${0}
    Check NBR Congetion Counter    value_1=${0}    value_Average=${0}
    ...    counter_id=${counter_id_D01_gNB1}    counter_dic_path=${counter_dic_path_E007_gNB2}    gnb_index=${1}
    Comment    step4 check triger Pscell+Scell all DRB7 NBR are also Congetion
    ...        (the traffic difference between 5QI7 and 5QI9 Traffic is approximately equal)
    ${Gap4}    Check inter CA NBR Congetion    file_name=${file_name_E007_3}
    ...    gnb1_cell1_origin_value=${77}    gnb1_cell1_target_value=${80}    gnb2_cell1_origin_value=${48}    gnb2_cell1_target_value=${53}
#    ...    gnb1_cell1_origin_value=${77}    gnb1_cell1_target_value=${78}    gnb2_cell1_origin_value=${50}    gnb2_cell1_target_value=${54}
    ...    value_NBR_min=${250}    value_NBR_max=${300}    value_nNBR_min=${250}    value_nNBR_max=${300}
    ${Gap4}    Evaluate    abs(${Gap4})
    Should be true    ${0}<=${Gap4}<=${20}
    should be true    ${gap3}>${gap4}
    Check counter for E007    value_1=${300}    value_Average_1=${1}    value_2=${300}    value_Average_2=${1}
    Stop and download the Logs   filename=${log_name_E_007_test}    gNB_index=${0}
    Stop DL/UL traffic    dl_ports=${dl_ports}    ue_index_UL=${ue2_index_list}
    [Teardown]    run keywords
    ...    Run Keyword And Ignore Error    Stop and download the Logs   filename=${log_name_E_007_test}    gNB_index=${0}    AND
    ...    power_ue.UE Detach    ue_type=${ue1_type}    ue_index=${1}    AND
    ...    Stop DL/UL traffic    dl_ports=${dl_ports}    ue_index_UL=${ue2_index_list}    AND
    ...    Run Keyword And Ignore Error    Stop capture syslog via btslog on ute    AND
    ...    get and analysis syslog    AND
    ...    Common Case TestLine Setup for E007    golden_scf_name=${golden_scf_name}    AND
    ...    Case Teardown    gnb_list=${gnb_list_E}

#[1]CB008227_E_07_B3_Nominal_Bitrate_interworking_with_inter_gNB_DL_CA_with_NBR_congetion_control_pooling
#    [Documentation]    This user scenario describes Nominal Bitrate interworking with DL CA.
#    [Setup]    robot_common_operations.Common Case Setup
#    ###case setup
#    Common Case TestLine Setup for E007
#    ###prepare UE
#    power_ue.Prepare UE    ue_type=${ue1_type}    ue_index=${1}
#    Andriod UE adb reboot    ue_index=${1}
#    Adjust gNB_RU Attenuation    tl=${gnb_instance}_UE2    gnb1_cell1_value=${50}    gnb2_cell1_value=${40}
#    Attach and collect log    filename=${log_name_E_007_1}    4G_check=False
#    Start capture gNB log on master    filename=${log_name_E_007_test}    gNB_index=${0}
#    Start DL Traffic    dl_ports=${dl_ports}    dl_throughput=${dl_throughput}    ue_index_list=${ue2_index_list}
#    ...    cap_index=${1}    times=5400
#    sleep    60s
#    Comment   step1 check NBR DRB7 and NBR DRB8 traffic are the same
#    ${Gap1}    Wait until keyword succeeds    3X    5s    Check inter CA NBR Congetion    file_name=${file_name_E007}
#    ...    gnb1_cell1_value=${62}    gnb2_cell1_value=${40}
#    ...    value_NBR_min=${490}    value_NBR_max=${550}    value_nNBR_min=${490}    value_nNBR_max=${550}
#    ${Gap1}    Evaluate    abs(${Gap1})
#    Should be true    ${0}<=${Gap1}<=${5}
#    Comment    step2 check triger the DRB7 NBR but not Congetion
#    ${Gap2}    Wait until keyword succeeds    3X    5s    Check inter CA NBR Congetion    file_name=${file_name_E007_1}
#    ...    gnb1_cell1_value=${78}    gnb2_cell1_value=${55}
#    ...    value_NBR_min=${300}    value_NBR_max=${330}    value_nNBR_min=${200}    value_nNBR_max=${250}
#    Should be true    ${50}<=${Gap2}<=${150}
#    Comment    step3 check triger (Pcell DRB7 NBR Congetion+counter) and  (Scell not Congetion +counter=0)
#    ${Gap3}    Wait until keyword succeeds    3X    5s    Check inter CA NBR Congetion    file_name=${file_name_E007_2}
#    ...    gnb1_cell1_value=${86}    gnb2_cell1_value=${55}
#    ...    value_NBR_min=${210}    value_NBR_max=${260}    value_nNBR_min=${160}    value_nNBR_max=${210}
#    Should be true    ${10}<=${Gap3}<=${70}
#    should be true    ${gap2}>${gap3}
#    Wait until keyword succeeds    20 min    3s    Check NBR Congetion Counter    value_1=${300}    value_Average=${1}
#    ...    counter_id=${counter_id_D01_gNB1}    counter_dic_path=${counter_dic_path_D01_gNB1}    gnb_index=${0}
#    Check NBR Congetion Counter    value_1=${0}    value_Average=${0}
#    ...    counter_id=${counter_id_D01_gNB1}    counter_dic_path=${counter_dic_path_E007_gNB2}    gnb_index=${1}
#    Comment    step4 check triger Scell DRB7 NBR is also Congetion(Pcell DRB7 NBR Congetion+counter) and (Scell not Congetion +counter)
#    ${Gap4}    Wait until keyword succeeds    3X    5s    Check inter CA NBR Congetion    file_name=${file_name_E007_3}
#    ...    gnb1_cell1_value=${86}    gnb2_cell1_value=${62}
#    ...    value_NBR_min=${120}    value_NBR_max=${200}    value_nNBR_min=${120}    value_nNBR_max=${200}
#    ${Gap4}    Evaluate    abs(${Gap4})
#    Should be true    ${0}<=${Gap4}<=${10}
#    should be true    ${gap3}>${gap4}
#    Check counter for E007    value_1=${300}    value_Average_1=${1}    value_2=${300}    value_Average_2=${1}
#    Stop and download the Logs   filename=${log_name_E_007_test}    gNB_index=${0}
#    Stop DL/UL traffic    dl_ports=${dl_ports}    ue_index_UL=${ue2_index_list}
#    [Teardown]    run keywords
#    ...    Stop and download the Logs   filename=${log_name_E_007_test}    gNB_index=${0}    AND
#    ...    Stop DL/UL traffic    dl_ports=${dl_ports}    ue_index_UL=${ue2_index_list}    AND
#    ...    power_ue.UE Detach    ue_type=${ue1_type}    ue_index=${1}    AND
#    ...    Common Case TestLine Setup for E007    golden_scf_name=${golden_scf_name}    AND
#    ...    Case Teardown    gnb_list=${gnb_list_E}

#[1]CB008227_E_03_B3_Nominal_Bitrate_interworking_with_DL_CA_without_NBR_congetion_AC_success
#    [Documentation]    This user scenario describes Nominal Bitrate interworking with DL CA.
#    [Setup]    robot_common_operations.Common Case Setup
#    ###case setup
#    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
#    Common Case TestLine Setup for E003
#    ###prepare UE
#    power_ue.Prepare UE    ue_type=${ue1_type}    ue_index=${1}
#    Precondition for Sansumg UE    ue_type=${ue_type}    ui_version=S21UI3.1
#    Set APN point for sanmsung until succeed    apn_name=${mdrb_apn_name}
#    ######Check point 1 maxPrbsPerNbrUe NBR rate#######
#    ###NBR data rate average, maxPrbsPerNbrUe Pcell-30,scell-90
#    Online modify NIDD on gnb    gnb_index=${1}    Modify_Para_Online=${Modify_Online_Para_NSA_E003_gnb2}
#    ${index1}    ${Gap1}    Wait until keyword succeeds    3X    5s    Attach and Check CA NBR bearer tput
#    ...    wiresharklog=${log_name_E_003}    wiresharklog_enb=${log_name_E_003_enb}
#    ...    file_name=${file_name_E003}    ue_index_list=${ue2_index_list}
#    ...    gnb2_cell1_value=${58}    gnb2_cell2_value=${55}
#    ...    value_NBR_min=${350}    value_NBR_max=${390}    value_nNBR_min=${70}    value_nNBR_max=${100}
#    ###NBR data rate average, maxPrbsPerNbrUe Pcell-90,scell-30
#    Online modify NIDD on gnb    gnb_index=${1}    Modify_Para_Online=${Modify_Online_Para_NSA_E003_gnb2_1}
#    ${index2}    ${Gap2}    Wait until keyword succeeds    3X    5s    Attach and Check CA NBR bearer tput
#    ...    wiresharklog=${log_name_E_003_1}    wiresharklog_enb=${log_name_E_003_1_enb}
#    ...    file_name=${file_name_E003_1}    ue_index_list=${ue2_index_list}
#    ...    gnb2_cell1_value=${58}    gnb2_cell2_value=${index1}    gnb2_cell2_value_max=${${index1}+${1}}
#    ...    value_NBR_min=${350}    value_NBR_max=${390}    value_nNBR_min=${70}    value_nNBR_max=${100}
#    ###NBR data rate average, maxPrbsPerNbrUe Pcell-50,scell-50
#    Online modify NIDD on gnb    gnb_index=${1}    Modify_Para_Online=${Modify_Online_Para_NSA_E003_gnb2_2}
#    ${index3}    ${Gap3}    Wait until keyword succeeds    3X    5s    Attach and Check CA NBR bearer tput
#    ...    wiresharklog=${log_name_E_003_2}    wiresharklog_enb=${log_name_E_003_2_enb}
#    ...    file_name=${file_name_E003_2}    ue_index_list=${ue2_index_list}
#    ...    gnb2_cell1_value=${58}    gnb2_cell2_value=${index1}    gnb2_cell2_value_max=${${index1}+${1}}
#    ...    value_NBR_min=${330}    value_NBR_max=${355}    value_nNBR_min=${110}    value_nNBR_max=${130}
#    ${Gap1_average}    Evaluate    abs(${Gap1-${Gap2}})
#    ${Gap2_average}    Evaluate    abs(${Gap1-${Gap3}})
#    ${Gap3_average}    Evaluate    abs(${Gap2-${Gap3}})
#    Should be true    ${0}<=${Gap1_average}<=${30}
#    Should be true    ${30}<=${Gap1}-${Gap3}<=${70}
#    Should be true    ${30}<=${Gap2}-${Gap3}<=${70}
#
#    ######Check point 2 A2release NBR rate#######
#    ###check CA scell release and pcell NBR Maintain the original NBR gap
#    Run keyword If    '${release}'=='SBTS24R2_ENB_0'    Online modify NIDD on gnb
#    ...    gnb_index=${1}    Modify_Para_Online=${Modify_Online_Para_NSA_E003_gnb2_A2release_24R2}
#    ...    ELSE    Online modify NIDD on gnb
#    ...    gnb_index=${1}    Modify_Para_Online=${Modify_Online_Para_NSA_E003_gnb2_A2release}
#    Wait until keyword succeeds    3X    5s    Check Pcell NBR after Scell A2release
#
#    ######Check point 3 2UE NBR#######
#    ###UE2 start traffic 5QI7, not impact the UE1 bearer tput
#    Run keyword If    '${release}'=='SBTS24R2_ENB_0'
#    ...    Online modify NIDD on gnb    gnb_index=${1}    Modify_Para_Online=${Modify_Online_Para_NSA_E003_gnb2_3_24R2}
#    ...    ELSE    Online modify NIDD on gnb    gnb_index=${1}    Modify_Para_Online=${Modify_Online_Para_NSA_E003_gnb2_3}
#    Adjust gNB_RU Attenuation    tl=${gnb_instance}_UE2    gnb2_cell1_value=${54}    gnb2_cell2_value=${20}    enb_cell_value=${0}
#    ${UE_IP}    Wait until keyword succeeds    3X    5s    Attach and collect log
#    ...    filename=${log_name_E_003_3}    log_name=${log_name_E_003_3_enb}
#    ...    cell1_index=${2}    cell2_index=${3}    gnb_index1=${1}    gnb_index2=${1}
#    Start DL Traffic    dl_ports=${dl_ports}    dl_throughput=${dl_throughput_400M}    ue_index_list=${ue2_index_list}
#    ...    cap_index=${1}    UE_IP=${UE_IP}
#    Online modify NIDD on gnb    gnb_index=${1}    Modify_Para_Online=${Modify_Online_Para_NSA_E003_gnb2_4}
#    ###UE2 can not impact UE1
#    Adjust gNB_RU Attenuation    gnb2_cell1_value=${0}
#    Attach and check power UE    ue_type=${ue_type}    gnb_index=${1}
#    Prepare to caculate PM counter    period=start
#    Power UE Start DL traffic    dl_throughput=${dl_throughput_400M}    duration=1200    dl_port=${dl_port_5QI7_UE1}
#    ###adjuct UE1 PA to -90dB, check bearer
#    Wait until keyword succeeds    3X    5s    Check 3 bearer with 2 UE    file_name1=${file_name_E003_3}    file_name2=${file_name_E003_4}
#    Prepare to caculate PM counter    period=end
#    Check counter for E003
#    Wait until keyword succeeds    3X    5s    Check 3 bearer with 2 UE    file_name1=${file_name_E003_5}    file_name2=${file_name_E003_6}
#    [Teardown]    run keywords
#    ...    Stop DL/UL traffic    dl_ports=${dl_ports}    ue_index_UL=${ue2_index_list}    AND
#    ...    Stop DL/UL traffic    dl_ports=${dl_ports_UE1}    ue_index_UL=${ue1_index_list}    AND
#    ...    Online modify NIDD on gnb    gnb_index=${1}    Modify_Para_Online=${Modify_Online_Para_NSA_C13_gnb2_recover}    AND
#    ...    Modify the enblte parameter    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-1
#    ...    parameter=defaultLnRelGnbCellId    value=1    AND
#    ...    Set APN point for sanmsung until succeed    apn_name=${dxdata2_apn_name}    AND
#    ...    power_ue.UE Detach    ue_type=${ue1_type}    ue_index=${1}    AND
#    ...    Case Teardown


*** Keywords ***
Common Case TestLine Setup for E003
    ${release}=    Get sagnb release title
    set suite variable    ${release}
    Common Case TestLine Setup with singe BTS    is_commission=True    gnb_index=${1}    scf_path=${scf_path}
    ...    golden_scf_name=${golden_scf_name_E003_gnb2}_${release}.xml
    Wait until keyword succeeds    20 min    20s
        ...    Check the cells status on air    bts_host=${bts_host1}   connection=gnb0
    #### open enb attach NSA gnb2 cell1
    Modify the enblte parameter    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-1
    ...    parameter=defaultLnRelGnbCellId
    ...    value=2
    sleep    10s

Common Case TestLine Setup for E007
    [Arguments]    ${golden_scf_name}=${golden_scf_name_E007}
    ${release}=    Get sagnb release title
    set suite variable    ${release}
    @{scf_list}    Create List
    ...    ${scf_path}${golden_scf_name}_${release}.xml    ${scf_path}${golden_scf_name}_gnb2_${release}.xml
    Log to console    Start to modify scf files and commission, please wait...
    Multi-gNB commission    index_list=${gnb_list_E}    scf_list=${scf_list}
    Wait until keyword succeeds    20 min    20s
    ...    Check the cells status on air    bts_host=${bts_host0}   connection=gnb0
    Wait until keyword succeeds    20 min    20s
    ...    Check the cells status on air    bts_host=${bts_host1}   connection=gnb1


Attach and collect log
        [Arguments]    ${filename}=${filename}    ${log_name}=NULL    ${4G_check}=True
    ...    ${cell1_index}=${1}    ${cell2_index}=${2}    ${gnb_index1}=${0}    ${gnb_index2}=${1}
#    power_ue.UE Detach    ue_type=${ue1_type}    ue_index=${1}
    Start capture gNB log on master    filename=${filename}    gNB_index=${gnb_index1}
    Run keyword If    '${4G_check}'=='True'    Start to collect the log on eNB    log_name=${log_name}
    Attach and check power UE X65    ue_type=${ue1_type}    ue_index=${1}    4G_check=${4G_check}    gnb_index=${gnb_index1}
    Stop and download the Logs   filename=${filename}    gNB_index=${gnb_index1}
    Run keyword If    '${4G_check}'=='True'    Stop and download Logs on eNB    log_name=${log_name}
    Check wireshark log for CA attach OK    logname=${filename}
    ...    cell1_index=${cell1_index}    cell2_index=${cell2_index}    gnb_index1=${gnb_index1}    gnb_index2=${gnb_index2}
    ${UE_IP}    Run keyword If    '${4G_check}'=='True'    Check wireshark log for data IP    logname=${log_name}
    [Teardown]    Stop and download the Logs   filename=${filename}    gNB_index=${gnb_index1}
    [Return]    ${UE_IP}

Attach and check power UE X65
    [Arguments]    ${ue_type}    ${ue_index}=${0}    ${4G_check}=False    ${gnb_index}=${1}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    gnb_index=${gnb_index}
    Run keyword If    '${4G_check}'=='True'    Before test reset QCOM use adb command    ue_index=${ue_index}
    Run keyword If    '${4G_check}'=='True'    sleep    60s
    Run keyword If    '${4G_check}'=='True'    Check UE device status with adb recover    ue_index=${ue_index}
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    ue_index=${ue_index}    4G_check=${4G_check}
    ...    gnb_index=${gnb_index}

check CA NBR bearer Tput
    [Arguments]    ${file_name}    ${dl_ports}=${dl_ports}    ${ue_index_list}=${ue_index_list}
    ...    ${value_NBR_min}=${740}    ${value_NBR_max}=${760}    ${value_nNBR_min}=${150}    ${value_nNBR_max}=${170}
    Listened DL And Download Traffic    file_name=${file_name}    dl_ports=${dl_ports}    ue_index=${1}
    ...    ue_index_list=${ue_index_list}
    Check beare value should be true
    ...    file_name=${file_name}_${dl_port_5QI7}.txt    value_min=${value_NBR_min}    value_max=${value_NBR_max}
    Check beare value should be true
    ...    file_name=${file_name}_${dl_port_5QI8}.txt    value_min=${value_nNBR_min}    value_max=${value_nNBR_max}

Check 3 bearer with 2 UE
    [Arguments]    ${file_name1}    ${file_name2}
    Listened DL And Download Traffic    file_name=${file_name1}    dl_ports=${dl_ports}    ue_index=${1}
    ...    ue_index_list=${ue2_index_list}
    Listened DL And Download Traffic    file_name=${file_name2}    dl_ports=${dl_ports_UE1}    ue_index=${0}
    ...    ue_index_list=${ue1_index_list}
    Check beare value should be true
    ...    file_name=${file_name1}_${dl_port_5QI8}.txt    value_min=${140}    value_max=${350}
    Check beare value should be true
    ...    file_name=${file_name1}_${dl_port_5QI7}.txt    value_min=${320}    value_max=${470}
    Check beare value should be true
    ...    file_name=${file_name2}_${dl_port_5QI7_UE1}.txt    value_min=${100}    value_max=${125}

Attach and Check CA NBR bearer tput
    [Arguments]    ${wiresharklog}    ${wiresharklog_enb}    ${file_name}    ${gnb2_cell1_value}=${50}    ${gnb2_cell2_value}=${30}
    ...    ${value_NBR_min}=${740}    ${value_NBR_max}=${760}    ${value_nNBR_min}=${160}    ${value_nNBR_max}=${170}
    ...    ${ue_index_list}=${ue_index_list}    ${gnb2_cell2_value_max}=${${gnb2_cell2_value}+${3}}
    Adjust gNB_RU Attenuation    tl=${gnb_instance}_UE2
    ...    gnb2_cell1_value=${30}    gnb2_cell2_value=${30}    enb_cell_value=${0}
    ${UE_IP}    Attach and collect log    filename=${wiresharklog}
    ...    cell1_index=${2}    cell2_index=${3}    gnb_index1=${1}    gnb_index2=${1}
    ...    log_name=${wiresharklog_enb}
    Start DL Traffic    dl_ports=${dl_ports}    dl_throughput=${dl_throughput}    ue_index_list=${ue_index_list}
    ...    cap_index=${1}    UE_IP=${UE_IP}
    sleep    10s
    FOR    ${index}    IN RANGE    ${gnb2_cell2_value}    ${gnb2_cell2_value_max}
        Adjust gNB_RU Attenuation    tl=${gnb_instance}_UE2
        ...    gnb2_cell1_value=${gnb2_cell1_value}    gnb2_cell2_value=${index}    enb_cell_value=${0}
        ${status_1}    Run keyword and return status    check CA NBR bearer Tput
        ...    file_name=${file_name}    dl_ports=${dl_ports}    ue_index_list=${ue_index_list}
        ...    value_NBR_min=${value_NBR_min}    value_NBR_max=${value_NBR_max}
        ...    value_nNBR_min=${value_nNBR_min}    value_nNBR_max=${value_nNBR_max}
        Exit For Loop If    '${status_1}'=='True'
    END
    Should be equal    ${status_1}    ${True}
    ${Gap}    Run keyword If    '${status_1}'=='True'    Check beare value average    file_name=${file_name}
    [Teardown]    Run keywords
    ...    Stop All port traffic    ue_index=${ue_index_list}   direction=dl    port_list=${dl_ports}    AND
    ...    power_ue.UE Detach    ue_type=${ue1_type}    ue_index=${1}
    [Return]    ${index}    ${Gap}

Check inter CA NBR Congetion
    [Arguments]    ${file_name}
    ...    ${gnb1_cell1_origin_value}=${50}    ${gnb1_cell1_target_value}=${51}
    ...    ${gnb2_cell1_origin_value}=${33}    ${gnb2_cell1_target_value}=${34}
    ...    ${value_NBR_min}=${350}    ${value_NBR_max}=${360}    ${value_nNBR_min}=${235}    ${value_nNBR_max}=${250}
    Adjust HBTE Attenuation For gnb1_cell1    origin_value=${gnb1_cell1_origin_value}    target_value=${gnb1_cell1_target_value}
    Adjust HBTE Attenuation For gnb2_cell1    origin_value=${gnb2_cell1_origin_value}    target_value=${gnb2_cell1_target_value}
    Wait until keyword succeeds    4X    5s    check CA NBR bearer Tput
    ...    file_name=${file_name}    dl_ports=${dl_ports}    ue_index_list=${ue2_index_list}
    ...    value_NBR_min=${value_NBR_min}    value_NBR_max=${value_NBR_max}
    ...    value_nNBR_min=${value_nNBR_min}    value_nNBR_max=${value_nNBR_max}
    ${Gap}    Check beare value average    file_name=${file_name}
    [Return]    ${Gap}

Adjust HBTE Attenuation For gnb1_cell1
    [Arguments]    ${origin_value}=${50}    ${target_value}=${78}
    FOR  ${value}    IN RANGE    ${origin_value}    ${target_value}    ${1}
       Adjust gNB_RU Attenuation For gnb1_cell1    tl=${gnb_instance}_UE2    gnb1_cell1_value=${value}
    END

Adjust HBTE Attenuation For gnb2_cell1
    [Arguments]    ${origin_value}=${33}    ${target_value}=${52}
    FOR  ${value}    IN RANGE    ${origin_value}    ${target_value}    ${1}
       Adjust gNB_RU Attenuation For gnb2_cell1    tl=${gnb_instance}_UE2    gnb2_cell1_value=${value}
    END

Adjust gNB_RU Attenuation For gnb1_cell1
    [Arguments]     ${tl}=${gnb_instance}    ${gnb1_cell1_value}=${127}
    ####create cell list#####
    @{att_ports_gnb1_cell1}    Create List    ${att_port_1_gnb1_cell1_${tl}}    ${att_port_2_gnb1_cell1_${tl}}
    ...    ${att_port_3_gnb1_cell1_${tl}}    ${att_port_4_gnb1_cell1_${tl}}

    ###create value list####
    @{values_gnb1_cell1}    Create List    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}

    ###Adjust the HBTE attenuation value###
    Set the attenuation value of ports simultaneously   att_ports=${att_ports_gnb1_cell1}    values=${values_gnb1_cell1}
    ...    att_connection_port=${att_port_1_gnb1_cell1_${tl}}    att_ipaddr=${att_ipaddr_gnb1_cell1_${tl}}

Adjust gNB_RU Attenuation For gnb2_cell1
    [Arguments]     ${tl}=${gnb_instance}    ${gnb2_cell1_value}=${127}
    ####create cell list#####
    @{att_ports_gnb2_cell1}    Create List    ${att_port_1_gnb2_cell1_${tl}}    ${att_port_2_gnb2_cell1_${tl}}
    ...    ${att_port_3_gnb2_cell1_${tl}}    ${att_port_4_gnb2_cell1_${tl}}

    ###create value list####
    @{values_gnb2_cell1}    Create List    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}

    ###Adjust the HBTE attenuation value###
    Set the attenuation value of ports simultaneously    att_ports=${att_ports_gnb2_cell1}    values=${values_gnb2_cell1}
    ...    att_connection_port=${att_port_1_gnb2_cell1_${tl}}    att_ipaddr=${att_ipaddr_gnb2_cell1_${tl}}

#Check inter CA NBR Congetion
#    [Arguments]    ${file_name}    ${gnb1_cell1_value}=${69}    ${gnb2_cell1_value}=${54}
#    ...    ${value_NBR_min}=${350}    ${value_NBR_max}=${360}    ${value_nNBR_min}=${235}    ${value_nNBR_max}=${250}
#    Adjust gNB_RU Attenuation    tl=${gnb_instance}_UE2
#    ...    gnb1_cell1_value=${gnb1_cell1_value}    gnb2_cell1_value=${gnb2_cell1_value}
#    sleep    20s
#    check CA NBR bearer Tput
#    ...    file_name=${file_name}    dl_ports=${dl_ports}    ue_index_list=${ue2_index_list}
#    ...    value_NBR_min=${value_NBR_min}    value_NBR_max=${value_NBR_max}
#    ...    value_nNBR_min=${value_nNBR_min}    value_nNBR_max=${value_nNBR_max}
#    ${Gap}    Check beare value average    file_name=${file_name}
#    [Return]    ${Gap}

Start DL Traffic
    [Arguments]    ${dl_ports}     ${UE_IP}=NULL    ${dl_throughput}=${dl_throughput}    ${ue_index_list}=${ue_index_list}
    ...    ${cap_index}=${0}    ${times}=1200
    ${UE_IPS}    Create List
    FOR    ${index}    IN    @{ue_index_list}
        Run keyword If    '${UE_IP}'=='NULL'    Get Commercial UE IP    ue_index=${index}    cap_index=${cap_index}
        Append To List    ${UE_IPS}    ${UE_IP}
    END
    operate_all_bearer_of_tput_traffic_threading_via_appserver
    ...    ue_ips=${UE_IPS}    dl_ports=${dl_ports}    traffic=${dl_throughput}    times=${times}

Listened DL And Download Traffic
    [Arguments]    ${file_name}    ${dl_ports}    ${ue_index_list}=${ue_index_list}
    ...    ${timeout1}=${30}    ${ue_index}=${0}
    ${serial_numbers}    Create List
    FOR    ${index}    IN    @{ue_index_list}
        Append To List    ${serial_numbers}    ${tl.ues[${index}].serial_number}
    END
    operate_all_bearer_of_tput_listen_threading_via_cpc    filename=${file_name}
    ...    dl_ports=${dl_ports}    serial_numbers=${serial_numbers}    timeout1=${timeout1}    ue_index=${ue_index}
    sleep    30s
    FOR    ${index}    IN   @{dl_ports}
        Download DL Traffic File    file_name=${file_name}_${index}.txt    ue_index=${ue_index}
    END

Check beare value average
    [Arguments]    ${file_name}
    ${value1_list}    check beare value    file_name=${epc_log_path}${file_name}_${dl_port_5QI7}.txt
    ${value2_list}    check beare value    file_name=${epc_log_path}${file_name}_${dl_port_5QI8}.txt
    ${Gap}    Evaluate    ${value1_list[1]}-${value2_list[1]}
    ${Gap}    Convert To Integer    ${Gap}
    [Return]    ${Gap}

Check UE tput is not RLC
    [Arguments]    ${file_name}    ${dl_ports}    ${dl_throughput}=${dl_throughput}    ${ue_index_list}=${ue_index_list}
    ...    ${timeout1}=${30}    ${ue_index}=${0}
    ...    ${value_NBR_min}=${400}    ${value_NBR_max}=${500}    ${value_nNBR_min}=${100}    ${value_nNBR_max}=${120}
    Listened DL And Download Traffic    file_name=${file_name}    dl_ports=${dl_ports}    dl_throughput=${dl_throughput}
    ...    ue_index_list=${ue_index_list}    timeout1=${timeout1}    ue_index=${ue_index}
    Check beare value should be true
    ...    file_name=${file_name}_${dl_port_5QI7}.txt    value_min=${value_NBR_min}    value_max=${value_NBR_max}
    Check beare value should be true
    ...    file_name=${file_name}_${dl_port_5QI8}.txt    value_min=${value_nNBR_min}    value_max=${value_nNBR_max}

Check counter for E003
    [Arguments]    ${counter_id}=${counter_id_E03_gNB1}    ${dic_path}=${counter_dic_path_E03_gNB1}    ${value}=${value_E003}
    ...    ${gnb_index}=${0}
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    Sleep    40s
    ${counter_lenth}    Get Length    ${counter_id}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    FOR    ${index}    IN RANGE    ${counter_lenth}
        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM
         ...    dic_path=${dic_path[${index}]}
        Should Not contain    ${counter_value}    ${value[${index}]}
    END
    [Teardown]    COAM Teardown gnb connections

Check counter for E007
    [Arguments]    ${value_1}    ${value_Average_1}    ${value_2}    ${value_Average_2}
    Prepare to caculate PM counter    period=start
    comment    check the NBR_congestion counter
    Prepare to caculate PM counter    period=end
    Check NBR Congetion Counter    value_1=${value_1}    value_Average=${value_Average_1}
    ...    counter_id=${counter_id_D01_gNB1}    counter_dic_path=${counter_dic_path_D01_gNB1}    gnb_index=${0}
    Check NBR Congetion Counter    value_1=${value_2}    value_Average=${value_Average_2}
    ...    counter_id=${counter_id_D01_gNB1}    counter_dic_path=${counter_dic_path_E007_gNB2}    gnb_index=${1}

Check Pcell NBR after Scell A2release
    Adjust gNB_RU Attenuation    tl=${gnb_instance}_UE2    gnb2_cell1_value=${0}    gnb2_cell2_value=${20}    enb_cell_value=${0}
    ${UE_IP}    Attach and collect log    filename=${log_name_E_003_test_A2}    log_name=${log_name_E_003_test_A2_enb}
    ...    cell1_index=${2}    cell2_index=${3}    gnb_index1=${1}    gnb_index2=${1}
    Start DL Traffic    dl_ports=${dl_ports}    dl_throughput=${dl_throughput}    ue_index_list=${ue2_index_list}
    ...    cap_index=${1}    UE_IP=${UE_IP}
    Adjust gNB_RU Attenuation    tl=${gnb_instance}_UE2    gnb2_cell1_value=${55}    gnb2_cell2_value=${52}    enb_cell_value=${0}
    Wait until keyword succeeds    3X    5s    check CA NBR bearer Tput    file_name=${file_name_E003_before_A2}
    ...    ue_index_list=${ue2_index_list}
    ...    value_NBR_min=${250}    value_NBR_max=${300}    value_nNBR_min=${250}    value_nNBR_max=${300}
    Adjust gNB_RU Attenuation    tl=${gnb_instance}_UE2    gnb2_cell1_value=${55}    gnb2_cell2_value=${65}    enb_cell_value=${0}
    Wait until keyword succeeds    3X    5s    check CA NBR bearer Tput    file_name=${file_name_E003_A2release}
    ...    ue_index_list=${ue2_index_list}
    ...    value_NBR_min=${200}    value_NBR_max=${210}    value_nNBR_min=${60}    value_nNBR_max=${90}
    [Teardown]    Run keywords    Stop All port traffic    ue_index=${ue_index_list}   direction=dl    port_list=${dl_ports}
    ...    AND    power_ue.UE Detach    ue_type=${ue1_type}    ue_index=${1}

Check wireshark log for data IP
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
    Log To Console    UEContextModificationResponse has scell
    ${ipv4_filter}=     Catenate    s1ap.procedureCode == 9 and s1ap.S1AP_PDU == 0 and nas_eps.esm.pdn_ipv4
    ${ipv4_packets}=    cap.filter_packets_by_expression    filter_expression=${ipv4_filter}    pcap_parser=test6
    ${ipv4_list}=     cap.get_field_value_by_xpath    xpath=.//nas_eps.esm.pdn_ipv4    pcap_parser=test6
    Should Start With    ${ipv4_list[0]}    172.
    [Return]  ${ipv4_list[-1]}