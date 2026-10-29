*** Settings ***
Resource    ./../Resources/CB008140_common_keywords_multiUE.robot
Variables    ./Resources/CB008140_G_variables_2gnb.py

Documentation
...   author: qingqing.zhang
...   contact: qingqing.zhang@nokia-sbell.com
...   squad group: SG_03
...   Feature CB008140-GC

Suite Setup    Run Keywords
...               robot_common_operations.Common Suite Setup
...               AND    Common Suite Setup for COAM
...               AND    get_release_check_result
...               AND    Common Case TestLine Setup with gnb1 and gnb2
...               AND    Adjust gNB_RU Attenuation for 2gnb

Suite Teardown    Run Keywords
...               robot_common_operations.Common Suite Teardown    AND
...               Common Case TestLine Setup recover    AND
...               Run Keyword And Ignore Error    Common Suite Teardown for COAM   AND
...               Run Keyword And Ignore Error    COAM Teardown gnb connections
...               AND    Adjust gNB_RU Attenuation for 2gnb

*** Variables ***
${tl_scf_gnb0}    SCF_GNB1_
${tl_scf_gnb1}    SCF_GNB2_
${filename_002_attach_gnb0}    log_name_GC_002_gNB1_attach.pcap
${filename_002_attach_gnb1}    log_name_GC_002_gNB2_attach.pcap
${filename1_002_gnb0}    log1_name_GC_002_gNB1.pcap
${filename1_002_gnb1}    log1_name_GC_002_gNB2.pcap
${filename_005_attach_gnb0}    log1_name_GC_005_gNB1_attach.pcap
${filename_005_attach_gnb1}    log1_name_GC_005_gNB2_attach.pcap
${filename1_005_gnb0}    log1_name_GC_005_gNB1.pcap
${filename1_005_gnb1}    log1_name_GC_005_gNB2.pcap
${filename2_005_gnb0}    log2_name_GC_005_gNB1.pcap
${filename2_005_gnb1}    log2_name_GC_005_gNB2.pcap
${filename_008_attach_gnb0}    log1_name_GC_008_gNB1_attach.pcap
${filename_008_attach_gnb1}    log1_name_GC_008_gNB2_attach.pcap
${filename1_008_gnb0}    log1_name_GC_008_gNB1.pcap
${filename1_008_gnb1}    log1_name_GC_008_gNB2.pcap
${filename2_008_gnb0}    log2_name_GC_008_gNB1.pcap
${filename2_008_gnb1}    log2_name_GC_008_gNB2.pcap
${PMfile_gnb1}    8140_GC_002_counter_gnb1.xml
${PMfile_gnb2}    8140_GC_002_counter_gnb2.xml
@{scell_index_list_cell2}    ${2}
@{scell_index_list_cell31}    ${31}
@{scell_index_list_cell1}    ${1}
@{scell_index_list_cell11}    ${11}
@{extgnb_index_gnb1}    ${0}
@{extgnb_index_gnb2}    ${1}
@{gnb_ips}    ${bts_host0}    ${bts_host1}
@{gnb_list}    ${0}    ${1}
${epc_log_path}    /opt/workspace/CRT/Master/Case_Logs/

@{counter_gnb1_M55118C05507}    ${1}
@{cell_id_002_gnb1}    ${0}    ${0}

@{expected_value_002_gnb1}    ${1}    ${1}
@{expected_value_002_gnb2}    ${1}    ${1}    ${1}    ${1}

${expected_tput_dl_F}    390
${expected_tput_dl_T}    1400
${expected_tput_dl_T_40M}    540
${Send_Tput_DL_F_F}    800M
${Send_Tput_DL_F_T}    1800M
${Send_Tput_DL_T_T_spark}    2000
${Send_Tput_DL_T_T}    500M
${normal_release}    10
${expected_xml_value_GC002_gnb1}    1
@{cell_id_GC002_gnb1}    ${0}
@{cell_id_GC005_gnb1}    ${1}
@{counter_gnb1_GG002_value}    ${1}
@{branch}    SBTS24R1_ENB_0000    SBTS24R2_ENB_9999
*** Test Cases ***
[1]CB008140-5G-GC_002_Intra_gNB-DU_RRC_connection_reestablishment_with_valid_UE_context_in_IgNB_CA_mode
    [Documentation]  This user scenario describes the successful connection re-establishment of a UE context in IgNB-CA
    ...               mode, when the new PCell is located in the same prime-gNB-DU of the old PCell.
    [Tags]     classical    CRT_TRUNK
    [Timeout]    2 hour
    [Setup]    robot_common_operations.Common Case Setup
    MultiUE.Prepare UE
    Modify Parameters for Cases   gnb_index=${1}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB4_GC002}
    Adjust gNB_RU Attenuation for 2gnb    gnb2_cell3_value=${0}
    Attach and check CA setup    filename=filename_002_attach_gnb    logname=${filename_002_attach_gnb1}
    ...    pcell_index=${31}    scell_index_list=${scell_index_list_cell1}    UEContextModificationResponse_nums=${2}
    ...    Primegnb_index=${1}    extgnb_index_list=${extgnb_index_gnb1}    gnb_list=${gnb_list}
    Prepare with PM counter time to caculate    period=start
    MultiUE.Start DL Traffic    throughput_for_DL=${Send_Tput_DL_T_T}    duration=1200    process_num=${5}
    ###trigger RRE
    Start capture multi gNB log    filename=filename1_002_gnb    gnb_list=${gnb_list}
    Adjust gNB_RU Attenuation for 2gnb    gnb2_cell2_value=${0}    gnb2_cell3_value=${0}
    Adjust gNB_RU Attenuation for 2gnb    gnb2_cell2_value=${0}
    Sleep    5s
    Stop capture multi gNB log    filename=filename1_002_gnb    gnb_list=${gnb_list}
    Comment    check the wireshark log
    Check wireshark log for GC002   logname=${filename1_002_gnb1}    logname1=${filename1_002_gnb0}
    Comment    check the counter
    Wait until keyword succeeds    5min    20s    Check counter for GC002
    Adjust gNB_RU Attenuation for 2gnb    gnb1_cell1_value=${0}    gnb2_cell2_value=${0}
    Sleep    10s
    Check 2CC DLUL tput     tput_dl_pcell=${expected_tput_dl_F}    tput_dl_scell=${expected_tput_dl_F}
    ...    scellid=1    pcellid=2    gnb_prime=${1}    gnb_external=${0}
    MultiUE.Stop DL Traffic    ue_type=${ue_type}
    MultiUE.Detach
    Hanging resource test    gnb_ips=@{gnb_ips}    gnb_list=${gnb_list}
    [Teardown]    run keywords
    ...    MultiUE.Detach    AND
    ...    Run Keyword And Ignore Error    Common Case Teardown for COAM    gnb_list=${gnb_list}

[1]CB008140-5G-GC_005_Inter-gNB_Handover_over_Xn_of_a_UE_connection_in_IgNB_CA_mode
    [Documentation]  This user scenario describes the inter-gNB handover over Xn of a UE context in IgNB-CA mode.
    [Tags]     classical    CRT_TRUNK
    [Timeout]    2 hour
    [Setup]    robot_common_operations.Common Case Setup
    MultiUE.Prepare UE
    ##HO preparation
    Case prepare for GC005
    Adjust gNB_RU Attenuation for 2gnb    gnb1_cell2_value=${0}
    Attach and check CA setup    filename=filename_005_attach_gnb    logname=${filename_005_attach_gnb0}
         ...    pcell_index=${2}    scell_index_list=${scell_index_list_cell31}    UEContextModificationResponse_nums=${2}
         ...    Primegnb_index=${0}    extgnb_index_list=${extgnb_index_gnb2}    gnb_list=${gnb_list}
    ###trigger inter HO with A3 and A1 addition
    MultiUE.Start DL Traffic    throughput_for_DL=${Send_Tput_DL_T_T}    duration=1200    process_num=${5}
    Prepare with PM counter time to caculate    period=start
    Start capture multi gNB log    filename=filename1_005_gnb    gnb_list=${gnb_list}
    Sleep    2s
    Adjust gNB_RU Attenuation for 2gnb    gnb1_cell2_value=${10}    gnb2_cell2_value=${20}
    Sleep    2s
    Adjust gNB_RU Attenuation for 2gnb    gnb1_cell2_value=${10}    gnb2_cell2_value=${10}
    Sleep    2s
    Adjust gNB_RU Attenuation for 2gnb    gnb1_cell2_value=${15}    gnb2_cell2_value=${10}
    Sleep    2s
    Adjust gNB_RU Attenuation for 2gnb    gnb1_cell2_value=${25}    gnb2_cell2_value=${10}
    Sleep    2s
    Adjust gNB_RU Attenuation for 2gnb    gnb2_cell2_value=${10}
    Sleep    3s
    Stop capture multi gNB log    filename=filename1_005_gnb    gnb_list=${gnb_list}
    Adjust gNB_RU Attenuation for 2gnb    gnb1_cell1_value=${0}    gnb2_cell2_value=${0}
    sleep    10s
    Check 2CC DLUL tput     tput_dl_pcell=${expected_tput_dl_F}    tput_dl_scell=${expected_tput_dl_F}
         ...    scellid=1    pcellid=2    gnb_prime=${1}    gnb_external=${0}
    Comment    check the wireshark log
    Check wireshark log for GC005_01   logname=${filename1_005_gnb0}    logname1=${filename1_005_gnb1}
    Comment    check the counter
    Wait until keyword succeeds    5min    20s   Check counter for GC005
    ####trigger inter HO with A5 but no A1 addition
    Start capture multi gNB log    filename=filename2_005_gnb    gnb_list=${gnb_list}
    Adjust gNB_RU Attenuation for 2gnb    gnb2_cell2_value=${25}
    Adjust gNB_RU Attenuation for 2gnb    gnb1_cell2_value=${15}    gnb2_cell2_value=${25}
    ###trigger  A1 addition
    Adjust gNB_RU Attenuation for 2gnb    gnb1_cell2_value=${0}    gnb2_cell3_value=${0}
    Stop capture multi gNB log    filename=filename2_005_gnb    gnb_list=${gnb_list}
    Check 2CC DLUL tput     tput_dl_pcell=${expected_tput_dl_F}    tput_dl_scell=${expected_tput_dl_T}
    ...    tput_ul_pcell=NULL    scellid=31    pcellid=2    gnb_prime=${0}    gnb_external=${1}
    Comment    check the wireshark log
    Check wireshark log for GC005_02   logname=${filename2_005_gnb0}    logname1=${filename2_005_gnb1}
    MultiUE.Stop DL Traffic    ue_type=${ue_type}
    MultiUE.Detach
    Hanging resource test    gnb_ips=@{gnb_ips}    gnb_list=${gnb_list}
    [Teardown]    run keywords
    ...    MultiUE.Detach    AND
    ...    Run Keyword And Ignore Error    Common Case Teardown for COAM    gnb_list=${gnb_list}

[1]CB008140-5G-GC_008_Successful_IgNB-CA_Scell_Addition_after_incoming_HO_measurement_below
    [Documentation]  This user scenario describes the successful connection re-establishment of a UE context in IgNB-CA
    ...               mode, when the new PCell is located in the same prime-gNB-DU of the old PCell.
    [Tags]     classical    CRT_TRUNK
    [Timeout]    2 hour
   [Setup]    robot_common_operations.Common Case Setup
    Case prepare for GC008
    MultiUE.Prepare UE
    Run keyword if    '${gnb_instance0}' == '${gnb_id}[2]'
    ...    Adjust gNB_RU Attenuation for 2gnb    gnb1_cell1_value=${10}
    ...    ELSE    Adjust gNB_RU Attenuation for 2gnb    gnb1_cell1_value=${0}
    Attach and check CA setup    filename=filename_005_attach_gnb    logname=${filename_005_attach_gnb0}
         ...    pcell_index=${11}    scell_index_list=${scell_index_list_cell1}    UEContextModificationResponse_nums=${2}
         ...    Primegnb_index=${0}    extgnb_index_list=${extgnb_index_gnb2}    gnb_list=${gnb_list}
    MultiUE.Start DL Traffic    throughput_for_DL=${Send_Tput_DL_T_T}    duration=1200    process_num=${5}
    ###trigger intra HO###
    Prepare with PM counter time to caculate    period=start
    Start capture multi gNB log    filename=filename1_008_gnb    gnb_list=${gnb_list}
    Adjust gNB_RU Attenuation for 2gnb    gnb1_cell1_value=${20}    gnb1_cell2_value=${20}
    Adjust gNB_RU Attenuation for 2gnb    gnb1_cell1_value=${25}    gnb1_cell2_value=${20}
    Adjust gNB_RU Attenuation for 2gnb    gnb1_cell1_value=${30}    gnb1_cell2_value=${20}
    Adjust gNB_RU Attenuation for 2gnb    gnb1_cell1_value=${35}    gnb1_cell2_value=${20}
    ###trigger A1 addition###
    Adjust gNB_RU Attenuation for 2gnb    gnb2_cell3_value=${0}    gnb1_cell2_value=${0}
    Stop capture multi gNB log    filename=filename1_008_gnb    gnb_list=${gnb_list}
    Check 2CC DLUL tput     tput_dl_pcell=${expected_tput_dl_F}    tput_dl_scell=${expected_tput_dl_T}
     ...    tput_ul_pcell=NULL    scellid=31    pcellid=2    gnb_prime=${0}    gnb_external=${1}
    Check wireshark log for GC008_01    logname=${filename1_008_gnb0}    logname1=${filename1_008_gnb1}
    Comment    check the counter
    Wait until keyword succeeds    5min    20s    Check counter for GC008
    Start capture multi gNB log    filename=filename2_008_gnb    gnb_list=${gnb_list}
    Adjust gNB_RU Attenuation for 2gnb    gnb1_cell1_value=${30}    gnb1_cell2_value=${20}
    Adjust gNB_RU Attenuation for 2gnb    gnb1_cell1_value=${20}    gnb1_cell2_value=${20}
    Adjust gNB_RU Attenuation for 2gnb    gnb1_cell1_value=${20}    gnb1_cell2_value=${25}
    Adjust gNB_RU Attenuation for 2gnb    gnb1_cell1_value=${0}    gnb2_cell1_value=${0}
    Stop capture multi gNB log    filename=filename2_008_gnb    gnb_list=${gnb_list}
    Check 2CC DLUL tput     tput_dl_pcell=${expected_tput_dl_F}    tput_dl_scell=${expected_tput_dl_F}
    ...    scellid=1    pcellid=11    gnb_prime=${0}    gnb_external=${1}
    Check wireshark log for GC008_02    logname=${filename2_008_gnb0}    logname1=${filename2_008_gnb1}
    MultiUE.Detach
    Hanging resource test    gnb_ips=@{gnb_ips}    gnb_list=${gnb_list}
    [Teardown]    run keywords
    ...    MultiUE.Detach    AND
    ...    Run Keyword And Ignore Error    Common Case Teardown for COAM    gnb_list=${gnb_list}

*** Keywords ***
Common Case TestLine Setup with gnb1 and gnb2
    ${release_info}    Get sagnb release
    @{scf_list}    Create List
    ${scf_gnb0}    Only Modify SCF before Perform Commission    gnb_index=${0}
    ...    golden_scf_name=${tl_scf_gnb0}${release_info}.xml    MOsToAdd=${MOS_ADD_GNB1_GC}
    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB1_GC}    ListToAdd=${LIST_TO_ADD_GNB1_GC}
    ${scf_gnb1}    Only Modify SCF before Perform Commission    gnb_index=${1}
    ...    golden_scf_name=${tl_scf_gnb1}${release_info}.xml    MOsToAdd=${MOS_ADD_GNB2_GC}
    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB2_GC}    ListToAdd=${LIST_TO_ADD_GNB2_GC}
    Append to List    ${scf_list}    ${scf_gnb0}    ${scf_gnb1}
    Log to console    Start to modify scf files and commission, please wait...
    Multi-gNB commission    index_list=${gnb_list}    scf_list=${scf_list}
    Check the MultiBTS cells status on air    gnb_list=${gnb_list}
#    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_MODIFY_GNB1_GC_LOCK}
    Run keyword if    '${gnb_instance0}' == '${gnb_id}[2]'
    ...    Run keywords    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-372    parameter=administrativeState     value=locked
    ...    AND    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-375    parameter=administrativeState     value=locked
    ...    AND    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-376    parameter=administrativeState     value=locked
    ...    ELSE    Run keywords    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-362    parameter=administrativeState     value=locked
    ...    AND    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-365    parameter=administrativeState     value=locked

Common Case TestLine Setup recover
    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_MODIFY_GNB1_recover_GC}
    Run keyword if    '${gnb_instance0}' == '${gnb_id}[2]'
    ...    Run keywords    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-372    parameter=administrativeState     value=unlocked
    ...    AND    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-375    parameter=administrativeState     value=unlocked
    ...    AND    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-376    parameter=administrativeState     value=unlocked
    ...    ELSE    Run keywords    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-362    parameter=administrativeState     value=unlocked
    ...    AND    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-365    parameter=administrativeState     value=unlocked

Attach and check CA setup
    [Arguments]    ${filename}    ${logname}    ${scell_index_list}    ${extgnb_index_list}
    ...    ${pcell_index}    ${Primegnb_index}   ${gnb_list}    ${UEContextModificationResponse_nums}=${3}
    Start capture multi gNB log    filename=${filename}    gnb_list=${gnb_list}
    MultiUE.Attach
    Stop capture multi gNB log    filename=${filename}    gnb_list=${gnb_list}
    ###check CA setup succuss
    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${logname}
    ...    pcell_index=${pcell_index}    scell_index_list=${scell_index_list}
    ...    Primegnb_index=${Primegnb_index}    extgnb_index_list=${extgnb_index_list}
    ...    UEContextModificationResponse_nums=${UEContextModificationResponse_nums}
    [Teardown]    Run Keyword And Ignore Error     Stop capture multi gNB log    filename=${filename}    gnb_list=${gnb_list}

Case prepare for GC005
    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_GC005}
    Modify Parameters for Cases   gnb_index=${1}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB2_GC005}
    ...    Add_Para_Online=${PARAMETERS_TO_ONLINE_ADD_GNB2_GC005}

Case prepare for GC008
    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_GC008}

Check xml counter for GC002
    [Arguments]    ${counter_index}=${cell_id_GC002_gnb1}
    Check the PM counter xml report    PMfile_name=${PMfile_gnb2}
    ...    PM_counter=${counter_xml_GC002_gNB1}    value=${expected_xml_value_GC002_gnb1}
    ...    counter_index=${counter_index}   gnb_index=${0}

Check counter for GC002
    Run Keyword If    '${check_result}' != 'True'    Check the PM counter should be value
    ...    gnb_index=${1}    counter_id=${counter_id_GG002_gNB1}
    ...    dic_path=${counter_dic_path_GG002_gNB1}    value=@{counter_gnb1_GG002_value}
    ...    ELSE    Check the PM counter should be value
    ...    gnb_index=${1}    counter_id=${counter_id_GG002_gNB1}
    ...    dic_path=${counter_dic_path_GG002_gNB1_trunk}    value=@{counter_gnb1_GG002_value}

Check counter for GC005
    Run Keyword If    '${check_result}' != 'True'    Check the PM counter should be value
    ...    gnb_index=${0}    counter_id=${counter_id_GG002_gNB1}
    ...    dic_path=${counter_dic_path_GG005_gNB1}    value=@{counter_gnb1_GG002_value}
    ...    ELSE    Check the PM counter should be value
    ...    gnb_index=${0}    counter_id=${counter_id_GG002_gNB1}
    ...    dic_path=${counter_dic_path_GG005_gNB1_trunk}    value=@{counter_gnb1_GG002_value}

Check counter for GC008
    Run Keyword If    '${check_result}' != 'True'    Check the PM counter should be value
    ...    gnb_index=${0}    counter_id=${counter_id_GG002_gNB1}
    ...    dic_path=${counter_dic_path_GC008_gNB1}    value=@{counter_gnb1_GG002_value}
    ...    ELSE    Check the PM counter should be value
    ...    gnb_index=${0}    counter_id=${counter_id_GG002_gNB1}
    ...    dic_path=${counter_dic_path_GC008_gNB1_trunk}    value=@{counter_gnb1_GG002_value}

Check wireshark log for GC002
    [Arguments]    ${logname}    ${logname1}
    ####check RRE
    Check RRC Reestablishment to a cell   logname=${logname}    source_cell_index=${31}    target_cell_index=${2}
    ...    source_gnb_index=${1}    target_gnb_index=${1}
    Check UEContextModifucationRequest message    logname=${logname}
    ###check source secll release
    Check pscell and scell release wireshark log    logname=${logname}    logname1=${logname1}
    ###check target Pcell and scell CA setup based on A1
    Check Measurement message on PrimegNB    logname=${logname}    cell_index=${2}    gnb_index=${1}    event_id=3
    ...    meas_lengths=${1}

Check wireshark log for GC005_01
    [Arguments]    ${logname}    ${logname1}
    Check intergNB HO process on source gNB    logname=${logname}    ip_source=${xnap_gnb1}   ip_target=${xnap_gnb2}
    Check intergNB HO process on target gNB    logname=${logname1}   ip_source=${xnap_gnb1}
    ...    npap_ip_target=${bts_host1}
    ###check target CA setup successful based on A1
    Check wireshark log for Measurement EventA1 after HO    logname=${logname1}    cell_index=${2}    gnb_index=${1}
    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${logname1}
    ...    pcell_index=${2}    scell_index_list=${scell_index_list_cell1}
    ...    Primegnb_index=${1}    extgnb_index_list=${extgnb_index_gnb1}
    ...    UEContextModificationResponse_nums=${1}
    ###check source CA release
    Check pscell and scell release wireshark log    logname=${logname}    logname1=${logname1}

Check wireshark log for GC005_02
    [Arguments]    ${logname}    ${logname1}
    Check intergNB HO process on source gNB    logname=${logname1}    ip_source=${xnap_gnb2}    ip_target=${xnap_gnb1}
    Check intergNB HO process on target gNB    logname=${logname}    ip_source=${xnap_gnb2}
    ...    npap_ip_target=${bts_host0}
    ###check target CA setup successful based on A1
    Check wireshark log for Measurement EventA1 after HO    logname=${logname}    cell_index=${2}    gnb_index=${0}
    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${logname}
    ...    pcell_index=${2}    scell_index_list=${scell_index_list_cell31}
    ...    Primegnb_index=${0}    extgnb_index_list=${extgnb_index_gnb2}
    ...    UEContextModificationResponse_nums=${1}
    ###check source CA release
    Check pscell and scell release wireshark log    logname=${logname1}   logname1=${logname}

Check wireshark log for GC008_01
    [Arguments]    ${logname}    ${logname1}
    Check intra-F intra-gNB HO procedure    logname=${logname}    target_cell=${2}    target_gnb=${0}
    Check wireshark log for Measurement EventA1 after HO    logname=${logname}    cell_index=${2}    gnb_index=${0}
    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${logname}
    ...    message_filter=nokiaf1ap.F1AP_PDU == 1 and nokiaf1ap.procedureCode == 7 and nr-rrc.sCellToAddModList==
    ...    pcell_index=${2}    scell_index_list=${scell_index_list_cell31}
    ...    Primegnb_index=${0}    extgnb_index_list=${extgnb_index_gnb2}
    ...    UEContextModificationResponse_nums=${1}
    Check pscell and scell release wireshark log    logname=${logname}    logname1=${logname1}

Check wireshark log for GC008_02
    [Arguments]    ${logname}    ${logname1}
    Check intra-F intra-gNB HO procedure    logname=${logname}    target_cell=${11}    target_gnb=${0}
    Check wireshark log for Measurement EventA1 after HO    logname=${logname}    cell_index=${2}    gnb_index=${0}
    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${logname}
    ...    message_filter=nokiaf1ap.F1AP_PDU == 1 and nokiaf1ap.procedureCode == 7 and nr-rrc.sCellToAddModList==
    ...    pcell_index=${11}    scell_index_list=${scell_index_list_cell1}
    ...    Primegnb_index=${0}    extgnb_index_list=${extgnb_index_gnb2}
    ...    UEContextModificationResponse_nums=${1}
    Check pscell and scell release wireshark log    logname=${logname}    logname1=${logname1}


Enable two Gnbs cells a1MeasSCellAddEnabled
    Common Case TestLine Setup
    ...    ModifySCF_Aftercommission=True    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_GC}
    ...    Add_Para_Online=${PARAMETERS_TO_ONLINE_ADD_GNB1_GC}
    ...    ModifySCF_Aftercommission_for_GNB2=True    Add_Para_Online_GNB2=${PARAMETERS_TO_ONLINE_ADD_GNB2_GC}
