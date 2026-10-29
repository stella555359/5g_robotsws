*** Settings ***
Resource    ./../Resources/CB008140_common_keywords_multiUE.robot
Variables    ./Resources/CB008140_H_variables_2gnb.py

Documentation
...   author: xiaodan.li
...   contact: xiaodan.li@nokia-sbell.com
...   squad group: SG_03
...   Feature CB008140-HA/HE

Suite Setup    Run Keywords    Common Suite Setup for COAM    AND
...               Adjust gNB_RU Attenuation for 2gnb    AND
...               Get sagnb release    AND
...               get_release_check_result    AND
...               Common Case TestLine Setup for HA004

Suite Teardown    Run Keywords
...               Common Suite Teardown for COAM   gnb_list=${gnb_list_HA}    AND
...               Run Keyword And Ignore Error    COAM Teardown gnb connections



*** Variables ***
${golden_scf_name_gnb0}    SCF_GNB1
${golden_scf_name_gnb1}    SCF_GNB2
${filename_HA004_gnb0}    log_name_HA_004_gNB1.pcap
${filename_HA004_gnb1}    log_name_HA_004_gNB2.pcap
${filename_HA007_gnb0}    log_name_HA_007_gNB1.pcap
${filename_HA007_gnb1}    log_name_HA_007_gNB2.pcap
${filename1_HA007_gnb0}    log1_name_HA_007_gNB1.pcap
${filename1_HA007_gnb1}    log1_name_HA_007_gNB2.pcap
${filename_HA008_gnb0}    log_name_HA_008_gNB1.pcap
${filename_HA008_gnb1}    log_name_HA_008_gNB2.pcap
${epc_log_path}    /opt/workspace/CRT/Master/Case_Logs/
@{gnb_ips_HA}    ${bts_host0}    ${bts_host1}
@{scell_index_list_HA004}    ${3}
@{scell_index_list_HA008}    ${3}
@{extgnb_index_list_HA004}    ${1}
@{extgnb_index_list_HA008}    ${0}
@{filename_HA004}    filename_HA004_gnb    filename_HA007_gnb    filename1_HA007_gnb
@{filename_HA008}    filename_HA008_gnb
@{expected_value_HA004_gnb1}    ${1}    ${1}    ${1}
@{expected_value_HA004_gnb2}    ${1}    ${1}    ${1}    ${1}    ${1}
${Send_Tput_DL_F_T_spark_small}    1
${expected_tput_dl_T_100MHz}    1400
${expected_tput_dl_T_40MHz}    560
${Send_Tput_DL_T_T_spark}    500
${expected_tput_dl_T_spark}    1
${T-PDU-DUD}    nr_u.PDU.Type == 14 and nr_u.Version
${T-PDU-DDDS}    nr_u.PDU.Type == 15 and nr_u.Version
${IP_Traffic_filename}    IP_Traffic_capture_HE001.pcap.gz
${IP_Traffic_filename_unzip}    IP_Traffic_capture_HE001.pcap
@{gnb_list_HA}    ${0}    ${1}
${gnb2_cell3_value_tput_38611}    ${5}
${gnb2_cell3_value_tput_38711}    ${0}

*** Test Cases ***
[1]CB008140-5G-HA_004_Beam_configuration_compatibility_checked_in_ext-gNB-DU_during_IgCA_Scell_addition_procedure_TDD_TDD_actBeamforming_difference
    [Documentation]    This user scenario describes a failed inter-gNB CA SCell addition for a SA UE context having
    ...    one candidate SCell only in an ext-gNB, due to rejection in execution phase from target
    ...    ext-gNB-DU due to incompatible beam configuration between PCell and candidate ext-SCell.
    [Tags]     classical    CRT_TRUNK
    [Setup]    robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    MultiUE.Prepare UE
    Adjust gNB_RU Attenuation for 2gnb    gnb1_cell3_value=${0}
    Prepare to caculate PM counter    period=start
    Attach and detach with wiresharklog    filename=filename_HA004_gnb    gnb_list=${gnb_list_HA}
    Prepare to caculate PM counter    period=end
    Check counter for HA004
    Check wireshark log for HA004    logname=${filename_HA004_gnb0}
    ##add HA007 checkpoiint
    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${MODIFY_PARA_ONLINE_GNB1_HA007}
    Adjust gNB_RU Attenuation for 2gnb    gnb1_cell3_value=${0}    gnb2_cell3_value=${gnb2_cell3_value_tput_${gnb_instance0}}
    Start capture multi gNB log    filename=filename_HA007_gnb    gnb_list=${gnb_list_HA}
    MultiUE.Attach
    sleep    10s
    MultiUE.Start DL Traffic    throughput_for_DL=${Send_Tput_DL_T_T_spark}    duration=1200    process_num=${5}
    sleep    10s
    Stop capture multi gNB log    filename=filename_HA007_gnb    gnb_list=${gnb_list_HA}
    Connect And Start IP Traffic Capturing    gnb_index=${0}    measurement_point=Transport_Interface
    sleep    10s
    Stop IP Traffic Capturing and Download File    gnb_index=${0}    IP_Traffic_filename=${IP_Traffic_filename}
    sleep    50s
    Check 2CC DLUL tput
    ...    tput_dl_pcell=${expected_tput_dl_T_100MHz}    tput_dl_scell=${expected_tput_dl_T_40MHz}
    ...    scellid=3    pcellid=3    gnb_prime=${0}    gnb_external=${1}
    MultiUE.Stop DL Traffic
    MultiUE.Detach
    AlarmWatchdog.add_allow_alarms    fault_id=1868
    Modify Parameters for Cases    gnb_index=${0}    Modify_Para_Online=${MODIFY_PARA_ONLINE_GNB1_HA007_1}
    ...    Add_Mo_Online=${ADD_MO_ONLINE_GNB1_HA007_1}
    sleep    2min
    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${MODIFY_PARA_ONLINE_GNB1_HA007_2}
    AlarmWatchdog.remove_allow_alarms    fault_id=1868
    Attach and detach with wiresharklog    filename=filename1_HA007_gnb    gnb_list=${gnb_list_HA}
    comment    check the wireshark log
    Check wireshark log for HA007    logname=${filename_HA007_gnb0}
    Check wireshark log for HA004    logname=${filename1_HA007_gnb0}
    ${split_pacp}=    Split sniffing capture    IP_Traffic_filename_unzip=${IP_Traffic_filename_unzip}
    Check wireshark log for HE001    wireshark=${split_pacp}
    Hanging resource test    gnb_ips=@{gnb_ips_HA}    gnb_list=@{gnb_list_HA}
    [Teardown]    run keywords
    ...    Online modify NIDD on gnb    gnb_index=${1}    Modify_Para_Online=${MODIFY_PARA_ONLINE_GNB3_HA007_RECOVER}    AND
    ...    Run Keyword And Ignore Error    Stop IP Traffic Capturing    connection=gNB${0}    AND
    ...    Case Teardown    filename=${filename_HA004}    gnb_list=${gnb_list_HA}    AND
    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation

#[1]CB008140-5G-HA_008_IGCA_CNI-87162_Single_UE_CA_DL_data_split_with_blind_Scell_activation
#    [Documentation]    This user scenario describes successful DL data split on the Scell for a FDD-TDD CA case when the
#    ...    Scell is configured with blind Scell activation for a single UE with carrier aggregation enabled
#    ...    Add 8140-HE001 check point
#    [Tags]     classical    CRT_TRUNK
#    [Setup]    robot_common_operations.Common Case Setup
#    Common Case TestLine Setup for HA008
#    MultiUE.Prepare UE
#    Adjust gNB_RU Attenuation    gnb3_cell2_value=${0}    gnb1_cell3_value=${0}
#    Start capture multi gNB log    filename=filename_HA008_gnb    gnb_list=${gnb_list_HA}
#    MultiUE.Attach
#    sleep    5s
#    Stop capture multi gNB log    filename=filename_HA008_gnb    gnb_list=${gnb_list_HA}
#    MultiUE.Start DL Traffic    throughput_for_DL=${Send_Tput_DL_F_T_spark_small}    duration=1200
#    Check 2CC DLUL tput     tput_dl_scell=0    tput_dl_scell=${expected_tput_dl_T_spark}
#    ...    pcellid=2    scellid=3    gnb_prime=${2}    gnb_external=${0}
#    MultiUE.Stop DL Traffic
#    MultiUE.Detach
#    Check wireshark log for HA008    logname=${filename_HA008_gnb2}
#    Hanging resource test    gnb_ips=@{gnb_ips_HA}    gnb_list=@{gnb_list_HA}
#    [Teardown]    run keywords
#    ...    Case Teardown    filename=${filename_HA008}    gnb_list=${gnb_list_HA}    AND
#    ...    Run Keyword And Ignore Error    Adjust gNB_RU Attenuation

*** Keywords ***
Common Case TestLine Setup for HA004
    @{scf_list}    Create List
    ${scf_gnb1}    Only Modify SCF before Perform Commission    gnb_index=${0}
    ...    golden_scf_name=${golden_scf_name_gnb0}_${release_info}.xml    MOsToAdd=${MOS_ADD_GNB1_HA004}
    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB1_HA004}    ParameterToDelete=${PARAMETERS_TO_DELETE_GNB1_HA004}
    ...    ListParamterToModify=${LIST_TO_MODIFY_GNB1_HA004}    ListToAdd=${LIST_TO_ADD_GNB1_HA004}
    Append to List    ${scf_list}    ${scf_gnb1}
    ${scf_gnb2}    Only Modify SCF before Perform Commission    gnb_index=${1}
    ...    golden_scf_name=${golden_scf_name_gnb1}_${release_info}.xml
    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB2_HA004}    ListParamterToModify=${LIST_TO_MODIFY_GNB2_HA004}
    ...    ListToAdd=${LIST_TO_ADD_GNB2_HA004}
    Append to List    ${scf_list}    ${scf_gnb2}
    Log to console    Start to modify scf files and commission, please wait...
    Multi-gNB commission    index_list=${gnb_list_HA}    scf_list=${scf_list}
    Wait until keyword succeeds    20 min    20s
    ...    Check the cells status on air    bts_host=${bts_host0}    connection=gnb1
    Wait Until Keyword Succeeds    20 min    30 sec    Cell Should Be Lock or Unlock
    ...    gnb_index=${1}    cell_idx=${31}    cell_group_idx=${31}
    Online modify NIDD on gnb    gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_NEA}
    Modify Parameters for Cases    gnb_index=${1}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB2_NEA}
    sleep    20s

Common Case TestLine Setup for HA008
    @{scf_list}    Create List
    ${scf_gnb1}    Only Modify SCF before Perform Commission    gnb_index=${0}
    ...    golden_scf_name=${golden_scf_name_gnb0}
    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB1_HA008}    ParameterToDelete=${PARAMETERS_TO_DELETE_GNB1_HA004}
    ...    ListParamterToModify=${LIST_TO_MODIFY_GNB1_HA004}
    Append to List    ${scf_list}    ${scf_gnb1}
    ${scf_gnb3}    Only Modify SCF before Perform Commission    gnb_index=${2}
    ...    golden_scf_name=${golden_scf_name_gnb2}    MOsToAdd=${MOS_ADD_GNB3_HA008}
    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB3_HA008}    ListToAdd=${LIST_TO_ADD_GNB3_HA008}
    ...    ListParamterToModify=${LIST_TO_MODIFY_GNB3_HA008}
    Append to List    ${scf_list}    ${scf_gnb3}
    Log to console    Start to modify scf files and commission, please wait...
    Multi-gNB commission    index_list=${gnb_list_HA}    scf_list=${scf_list}
    Check the MultiBTS cells status on air    gnb_list=${gnb_list_HA}


ONline Modify Prameter HA
    [Arguments]    ${Modify_Para_Online}='NULL'    ${Delete_Mo_Online}='NULL'    ${gnb_index}=${0}    ${gnb_list}=${gnb_list}
    Common Case TestLine Setup with singe BTS    gnb_index=${gnb_index}    ModifySCF_Aftercommission=True
    ...    golden_scf_name=${golden_scf_name_gnb${gnb_index}}    Modify_Para_Online=${Modify_Para_Online}
    ...    Delete_Mo_Online=${Delete_Mo_Online}    timeout=30min
    sleep    10s
    Check the MultiBTS cells status on air    gnb_list=${gnb_list}


Attach and detach with wiresharklog
    [Arguments]    ${filename}    ${gnb_list}=${gnb_list}    ${throughput_for_DL}=${Send_Tput_DL_T_T_spark}
    Start capture multi gNB log    filename=${filename}    gnb_list=${gnb_list}
    MultiUE.Attach
    sleep    10s
    MultiUE.Start DL Traffic    throughput_for_DL=${throughput_for_DL}    duration=1200
    sleep    10s
    Stop capture multi gNB log    filename=${filename}    gnb_list=${gnb_list}
    MultiUE.Detach
    [Teardown]    MultiUE.Stop DL Traffic

Check counter for HA004
    sleep    40s
    RUN KEYWORD IF    '${check_result}' == 'True'    Check the PM counter should be value
    ...    gnb_index=${0}    counter_id=${counter_id_HA004_gNB1}    dic_path=${counter_dic_path_HA004_gNB1_Trunk}
    ...    value=${expected_value_HA004_gnb1}
    ...    ELSE    Check the PM counter should be value
    ...    gnb_index=${0}    counter_id=${counter_id_HA004_gNB1}    dic_path=${counter_dic_path_HA004_gNB1}
    ...    value=${expected_value_HA004_gnb1}
    RUN KEYWORD IF    '${check_result}' == 'True'    Check the PM counter should be value
    ...    gnb_index=${1}    counter_id=${counter_id_HA004_gNB2_Trunk}    dic_path=${counter_dic_path_HA004_gNB2_Trunk}
    ...    value=${expected_value_HA004_gnb2}
    ...    ELSE    Check the PM counter should be value
    ...    gnb_index=${1}    counter_id=${counter_id_HA004_gNB2}    dic_path=${counter_dic_path_HA004_gNB2}
    ...    value=${expected_value_HA004_gnb2}

Check wireshark log for HA004
    [Arguments]    ${logname}
    Check IgNBCAAdditionReqestReject message    logname=${logname}
    Check 2st IgNBCAUeContextModificationRequest has the cancel CA message on PrimegNB    logname=${logname}
    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${logname}
    ...    pcell_index=${3}    scell_index_list=${scell_index_list_HA004}
    ...    Primegnb_index=${0}    extgnb_index_list=${extgnb_index_list_HA004}    CA_OK=False

Check wireshark log for HA007
    [Arguments]    ${logname}
    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${logname}
    ...    pcell_index=${3}    scell_index_list=${scell_index_list_HA004}
    ...    Primegnb_index=${0}    extgnb_index_list=${extgnb_index_list_HA004}
    ...    UEContextModificationResponse_nums=${3}

Check wireshark log for HA008
    [Arguments]    ${logname}
    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${logname}
    ...    pcell_index=${2}    scell_index_list=${scell_index_list_HA008}
    ...    Primegnb_index=${2}    extgnb_index_list=${extgnb_index_list_HA008}
    ...    UEContextModificationResponse_nums=${2}

Check wireshark log for HE001
    [Arguments]    ${wireshark}
    @{wireshakr_list}    Split String    ${wireshark}    \n
    FOR    ${wireshark_var}    IN    @{wireshakr_list}
        ${status}    Run keyword and return status    Check T-PDU message
        ...    logname=${wireshark_var}    message_filter=${T-PDU-DUD}
        Exit for Loop If    '${status}'=='True'
    END
    FOR    ${wireshark_var}    IN    @{wireshakr_list}
        ${status}    Run keyword and return status    Check T-PDU message
        ...    logname=${wireshark_var}    message_filter=${T-PDU-DDDS}
        Exit for Loop If    '${status}'=='True'
    END



Check IgNBCAAdditionReqestReject message
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaxnap.procedureCode == 22 and nokiaxnap.IgNBCACause == 0
    ...    ${xpath}=.//nokiaxnap.privateCause
    Log    check IgNBCAAdditionReqestReject cause is incompatible-configuration(7)
    ${reject_cause}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should be equal    ${reject_cause[0]}    7

Check T-PDU message
    [Arguments]    ${logname}
    ...    ${message_filter}=nr_u.PDU.Type == 14 and nr_u.Version
    ...    ${xpath}=.//nr_u.Version
    Log    check T-PDU has the Frame format Version:1.0
    ${DUT_Version}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should be equal    ${DUT_Version[0]}    1

Start sniffing capture with ASIB
    [Arguments]    ${gnb_index}=${0}
    ${mac}=  Get gNB mac address    gnb_index=${gnb_index}
    wait until keyword succeeds    1min   10s    Connect gNB    gNB_index=${gnb_index}
    csn.execute    command=/opt/trs/bin/vtc vtc_traffic_capturing_start_test 1 1 1 0 0x${mac} scell    connection=gNB${gnb_index}
    [Teardown]    csn.disconnect    connection=gNB${gnb_index}

Stop and download sniffing capture with ASIB
    [Arguments]    ${gnb_index}=${0}
    wait until keyword succeeds    1min   10s    Connect gNB    gNB_index=${gnb_index}
    csn.execute    command=/opt/trs/bin/vtc vtc_traffic_capturing_stop_test    connection=gNB${gnb_index}
    sleep    2s
    csn.execute    command=/opt/trs/bin/vtc vtc_traffic_capture_gen_pcap_test dummy    connection=gNB${gnb_index}
    sleep    2s
    csn.execute    command=mv /lte1460/portMirroringTmp.pcap.gz /lte1460/portMirroringTmp.pcap    connection=gNB${gnb_index}
    csn.download_file   remote_path=/lte1460/portMirroringTmp.pcap  local_path=${epc_log_path}portMirroringTmp.pcap   connection=gNB${gnb_index}
    [Teardown]    csn.disconnect    connection=gNB${gnb_index}

Split sniffing capture
    [Arguments]    ${IP_Traffic_filename_unzip}=${IP_Traffic_filename_unzip}
    Run    command=cd ${epc_log_path}
    sleep    2s
    Run    command=rm -rf split_*
    sleep    2s
    Run    command=editcap -c 8192 ${IP_Traffic_filename_unzip} split.pcap
    sleep    5s
    ${output}=    Run    command=ls -l split* | awk '{print $9}'
    [Return]    ${output}

Delete the split capture
    Run    command=cd ${epc_log_path}
    Run    command=rm -rf split_*