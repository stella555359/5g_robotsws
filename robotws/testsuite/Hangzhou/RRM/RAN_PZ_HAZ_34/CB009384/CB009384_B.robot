*** Settings ***
Force Tags    PY36
Documentation     author: yifan.hu
...                 contact: yifan.hu@nokia-sbell.com
...                 squad group: SG_03
...                 feature : CB009384-B

Resource    ./Resources/CB009384_common_keywords.robot
Variables    ./Resources/CB009384_variables.py


Suite Setup    Run Keywords
...            Common Suite Setup for COAM
...            AND   Get gnb release info
...            AND    get_release_check_result
...            AND    Common Case TestLine Setup    is_commission=True    is_commission_for_second_gnb=True    scf_path=${scf_path}
...            golden_scf_name=${gnb1_scf_${release_info}}    golden_scf_name_gnb2=${gnb2_scf_${release_info}}

Suite Teardown    Run Keywords
...               Run Keyword And Ignore Error    Common Suite Teardown for COAM   AND
...               Run Keyword And Ignore Error    COAM Teardown gnb connections


*** Variables ***
${gnb_path}    /tmp
${scf_path}    /opt/workspace/CRT/Master/SCF_file/
${gnb1_scf_SBTS25R3_ENB_9999}    golden_TDD.xml
${gnb2_scf_SBTS25R3_ENB_9999}    golden_FDD.xml
${gnb1_scf_SBTS25R2_ENB_0000}    golden_TDD.xml
${gnb2_scf_SBTS25R2_ENB_0000}    golden_FDD.xml
${gnb1_scf_SBTS25R1_ENB_0000}    golden_TDD.xml
${gnb2_scf_SBTS25R1_ENB_0000}    golden_FDD.xml
${gnb1_scf_SBTS24R3_ENB_0000}    golden_TDD.xml
${gnb2_scf_SBTS24R3_ENB_0000}    golden_FDD.xml
${gnb1_scf_SBTS24R2_ENB_0000}    golden_TDD.xml
${gnb2_scf_SBTS24R2_ENB_0000}    golden_FDD.xml
${gnb1_scf_SBTS24R1_ENB_0000}    golden_TDD.xml
${gnb2_scf_SBTS24R1_ENB_0000}    golden_FDD.xml
${gnb1_scf_SBTS23R4_ENB_0000}    golden_TDD_23R4.xml
${gnb2_scf_SBTS23R4_ENB_0000}    golden_FDD_23R4.xml
${logname_A3_HO_gnb1}    B_a3HO_gnb1.pcap
${logname_A3_HO_gnb2}    B_a3HO_gnb2.pcap
${logname_A5_HO_gnb1}    B_a5HO_gnb1.pcap
${logname_A5_HO_gnb2}    B_a5HO_gnb2.pcap
${logname_NG_HO_gnb1}    B_NGHO_gnb1.pcap
${logname_NG_HO_gnb2}    B_NGHO_gnb2.pcap
${logname_PCDM_gnb1}     C_PCMD_gnb1.pcap
${logname_PCDM_gnb2}     C_PCMD_gnb2.pcap
${logname_vonr}    vonr_setup.pcap
${logname_16drbs}    A_16drbs.pcap
${interface1}    any
${expected_tput_ul}    76
${expected_tput_dl}   188
${expected_tput_dl_gnb2}   188
@{6drbs}    5   6   7   8   9   128
@{2drbs}    8   9



*** Test Cases ***
[1]CB009384_B_B1B2_RedCap_UE_HO_success_Intregnb_intrafreq_A3_shortSN
    [Documentation]
    ...    This case checks RedCap UE A3/A5 xn based HO with data transfer with different SNlength
    [Tags]    classical    CRT_TRUNK    CRT_23R3
    [Setup]    robot_common_operations.Common Case Setup
    Modify Parameters for 2gnbs    Modify_Para1=${PARAMETERS_TO_MO_GNB1_B_XN_HO_18bit}
    ...    Modify_Para2=${PARAMETERS_TO_MO_GNB2_B_XN_HO_12bit}
    Prepare with PM counter time to caculate
    MTK prepare UE    ue_type=${ue_type}    ue_index=${2}
    ##A3 based xn HO
    Run keyword If    '${gnb_instance0}'== '${gnb_id}[1]'    Adjust gNB_RU Attenuation    gnb1_cell3_value=${40}
    ...    ELSE    Adjust gNB_RU Attenuation    gnb1_cell3_value=${25}    gnb1_cell3_value1=${8}
    MTK UE Attach    ue_type=${ue_type}    ue_index=${2}
    Start DLUL traffic and check throughput    cellid=3    ue_index=${2}    ul_throughput=NULL    tput_ul=NULL
    Start capture gNB logs on 2gnbs    filename1=${logname_A3_HO_gnb1}    filename2=${logname_A3_HO_gnb2}
    Adjust gNB_RU Attenuation    gnb1_cell3_value=${40}    gnb2_cell2_value=${30}
    Sleep    1s
    Adjust gNB_RU Attenuation    gnb1_cell3_value=${50}    gnb2_cell2_value=${25}
    Stop and download the Logs on 2gnbs    filename1=${logname_A3_HO_gnb1}    filename2=${logname_A3_HO_gnb2}
    Check wireshark log for XN HO    filename1=${logname_A3_HO_gnb1}    filename2=${logname_A3_HO_gnb2}
    Check DLUL tput     tput_dl=${expected_tput_dl}    tput_ul=NULL    cellid=2    gnb_index=${1}    ue_index=${2}
    ##A5 based xn HO
    Start capture gNB logs on 2gnbs    filename1=${logname_A5_HO_gnb1}    filename2=${logname_A5_HO_gnb2}
    Adjust gNB_RU Attenuation    gnb1_cell3_value=${30}    gnb2_cell2_value=${50}
    Stop and download the Logs on 2gnbs    filename1=${logname_A5_HO_gnb1}    filename2=${logname_A5_HO_gnb2}
    Check wireshark log for XN HO    filename1=${logname_A5_HO_gnb2}    filename2=${logname_A5_HO_gnb1}
    ...    ip_source=${xnap_gnb2}    ip_target=${xnap_gnb1}
    Run keyword If    '${gnb_instance0}'== '${gnb_id}[1]'    Adjust gNB_RU Attenuation    gnb1_cell3_value=${40}
    ...    ELSE    Adjust gNB_RU Attenuation    gnb1_cell3_value=${25}    gnb1_cell3_value1=${8}
    Check DLUL tput     tput_dl=${expected_tput_dl}    tput_ul=NULL    cellid=3    gnb_index=${0}    ue_index=${2}
    Stop UE DLUL traffic    ue_index=${2}    ul_port=NULL
    Wait until keyword succeeds    5 min    20s    Check counter for XN HO    gnb_index=0
    Wait until keyword succeeds    5 min    20s    Check counter for XN HO    gnb_index=1
    [Teardown]    run keywords
    ...    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${2}    AND
    ...    Run Keyword And Ignore Error    Case Teardown


#[1]CB009384_B_B6_Successful_Inter_gNB_NG_based_Handover_based_on_A3_measurements_no_Xn_same_AMF_shortSN
#    [Documentation]
#    ...    This case checks RedCap UE A3 NG based HO with data transfer
#    [Tags]    classical    CRT_TRUNK    CRT_23R3
#    [Setup]    robot_common_operations.Common Case Setup
#    Modify Parameters for 2gnbs    Modify_Para1=${PARAMETERS_TO_MO_GNB1_B_NG_HO_12bit}
#    ...    Modify_Para2=${PARAMETERS_TO_MO_GNB1_B_NG_HO_12bit_gnb2}
#    MTK prepare UE    ue_type=${ue_type}    ue_index=${2}
#    Adjust gNB_RU Attenuation    gnb1_cell3_value=${40}
#    Start capture PCMD log on master    filename=${logname_PCDM_gnb1}
#    MTK UE Attach    ue_type=${ue_type}    ue_index=${2}
#    Stop and download the Logs    filename=${logname_PCDM_gnb1}   gNB_index=${0}
#    Start DLUL traffic and check throughput    cellid=3    ue_index=${2}    ul_throughput=NULL    tput_ul=NULL
#    Start capture gNB logs and PCMD on 2gnbs    filename1=${logname_NG_HO_gnb1}    filename2=${logname_NG_HO_gnb2}
#    Adjust gNB_RU Attenuation    gnb1_cell3_value=${40}    gnb2_cell2_value=${30}
#    Stop and download the Logs on 2gnbs    filename1=${logname_NG_HO_gnb1}    filename2=${logname_NG_HO_gnb2}
#    Check DLUL tput    tput_ul=NULL    cellid=2    gnb_index=${1}    ue_index=${2}
#    Stop UE DLUL traffic    ue_index=${2}    ul_port=NULL
#    Check wireshark log for NG HO    filename1=${logname_NG_HO_gnb1}    filename2=${logname_NG_HO_gnb2}
#    Check wireshark log for PCDM    filename1=${logname_PCDM_gnb1}    filename2=${logname_NG_HO_gnb2}
#    [Teardown]    run keywords
#    ...    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${2}    AND
#    ...    Modify Parameters for NGHO recover   Modify_Para1=${PARAMETERS_TO_MO_NGHO_recover}
#    ...    Modify_Para2=${PARAMETERS_TO_MO_NGHO_recover_gnb2}    AND
#    ...    Run Keyword And Ignore Error    Case Teardown
#
#
#[1]CB009384_B_IWK5_Feature_interworking_for_RedCap_UE_multi_drb
#    [Documentation]
#    ...    This case checks RedCap UE IWK with multi-drb , HO with VONR
#    [Tags]    classical    CRT_TRUNK    CRT_23R3
#    [Setup]    robot_common_operations.Common Case Setup
#    Modify Parameters for 2gnbs    Modify_Para1=${PARAMETERS_TO_MO_GNB1_A_18bit}
#    ...    Modify_Para2=${PARAMETERS_TO_MO_GNB1_A_18bit_gnb2}
#    Prepare with PM counter time to caculate
#    Adjust gNB_RU Attenuation    gnb1_cell3_value=${40}
#    MTK prepare UE    ue_type=${ue_type}    ue_index=${2}
#    Start capture gNB log on master    filename=${logname_16drbs}    gNB_index=${0}
#    MTK UE Attach    ue_type=${ue_type}    ue_index=${2}
#    MTK UE Act Additional PDN    ue_index=${2}    pdn=mdrb.nokia.com
#    Stop and download the Logs    filename=${logname_16drbs}   gNB_index=${0}
#    ${qos_flow}    Check wireshark log for multi-drbs    logname=${logname_16drbs}
#    ...    multi_apn=mdrb.nokia.com    drb_length=${2}    multi_drbs=@{2drbs}
#    Start DLUL traffic and check throughput    cellid=3    ue_index=${2}    ul_throughput=NULL    tput_ul=NULL
#    Start capture gNB logs on 2gnbs    filename1=${logname_A3_HO_gnb1}    filename2=${logname_A3_HO_gnb2}
#    ute_ue.Start Voice Call    vc_alias=VC_0    ue_alias=UE_2    to=+6688
#    Adjust gNB_RU Attenuation    gnb1_cell3_value=${40}    gnb2_cell2_value=${30}
#    Stop and download the Logs on 2gnbs    filename1=${logname_A3_HO_gnb1}    filename2=${logname_A3_HO_gnb2}
#    Check DLUL tput     tput_dl=${expected_tput_dl}    tput_ul=NULL    cellid=2    gnb_index=${1}    ue_index=${2}
#    Stop UE DLUL traffic    ue_index=${2}    ul_port=NULL
#    VoNR call hang up
#    ${vonr_qos_flow}    Check wireshark log for VONR setup    filename=${logname_A3_HO_gnb1}
#    Chech wireshark log for multi-drb XN HO    filename1=${logname_A3_HO_gnb1}    filename2=${logname_A3_HO_gnb2}
#    ...    drb_qos=${qos_flow}    vonr_qos=${vonr_qos_flow}
#    Check VONR NOT Release    filename=${logname_A3_HO_gnb1}
#    Wait until keyword succeeds    5 min    20s    Check counter for XN HO    gnb_index=0
#    [Teardown]    run keywords
#    ...    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${2}    AND
#    ...    Run Keyword And Ignore Error    VoNR call hang up    AND
#    ...    Run Keyword And Ignore Error    Case Teardown


*** Keywords ***
Modify Parameters for NGHO recover
    [Arguments]    ${Modify_Para1}    ${Modify_Para2}
    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${Modify_Para1}
    Modify Parameters for Cases   gnb_index=${1}    Modify_Para_Online=${Modify_Para2}

Check wireshark log for PCDM
    [Arguments]    ${filename1}    ${filename2}
    Check PCMD log on source gNB    logname=${filename1}
    Check PCMD log on source gNB    logname=${filename2}

Check wireshark log for NG HO
    [Arguments]    ${filename1}    ${filename2}
    Check intergNB NGHO process on source gNB    logname=${filename1}
    Check intergNB NGHO process on target gNB    logname=${filename2}

Check counter for XN HO
    [Arguments]    ${gnb_index}
    Run Keyword If    '${check_result}' != 'True'    Check the PM counter should be value
    ...    gnb_index=${gnb_index}    counter_id=${counter_id_XN_HO}
    ...    dic_path=${counter_dic_path_XN_HO_gnb${gnb_index}}    value=${counter_value_XN_HO}
    ...    ELSE    Check the PM counter should be value
    ...    gnb_index=${gnb_index}    counter_id=${counter_id_XN_HO}
    ...    dic_path=${counter_dic_path_XN_HO_gnb${gnb_index}_trunk}    value=${counter_value_XN_HO}

Check wireshark log for XN HO
    [Arguments]    ${filename1}    ${filename2}    ${ip_source}=${xnap_gnb1}    ${ip_target}=${xnap_gnb2}
    Check intergNB HO process on source gNB    logname=${filename1}
    ...    ip_source=${ip_source}    ip_target=${ip_target}
    Check intergNB HO process on target gNB    logname=${filename2}
    ...    ip_source=${ip_source}    ip_target=${ip_target}

Chech wireshark log for multi-drb XN HO
    [Arguments]    ${filename1}    ${filename2}    ${drb_qos}    ${vonr_qos}
    Check wireshark log for XN HO    filename1=${filename1}    filename2=${filename2}
    Check HO for qos flow HO    logname=${filename2}    drb_qos=${drb_qos}    vonr_qos=${vonr_qos}

Start capture gNB logs on 2gnbs
    [Arguments]    ${filename1}    ${filename2}
    Start capture gNB log on master    filename=${filename1}    gNB_index=${0}
    Start capture gNB log on master    filename=${filename2}    gNB_index=${1}

Start capture gNB logs and PCMD on 2gnbs
    [Arguments]    ${filename1}    ${filename2}
    Start capture gNB log on master    filename=${filename1}    gNB_index=${0}
    Start capture PCMD log on master    filename=${filename2}    gNB_index=${1}

Stop and download the Logs on 2gnbs
    [Arguments]    ${filename1}    ${filename2}
    Stop and download the Logs    filename=${filename1}   gNB_index=${0}
    Stop and download the Logs    filename=${filename2}   gNB_index=${1}

Modify Parameters for 2gnbs
    [Arguments]    ${Modify_Para1}    ${Modify_Para2}
    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${Modify_Para1}
    Modify Parameters for Cases   gnb_index=${1}    Modify_Para_Online=${Modify_Para2}

Start capture PCMD log on master
    [Arguments]    ${filename}    ${gNB_index}=${0}    ${interface}=any
    wait until keyword succeeds    1min   10s    Connect gNB    gNB_index=${gNB_index}
    sleep    3s
    csn.send command    command=tcpdump -i ${interface} -w ${gnb_path}${filename} -s 0   connection=gNB${gNB_index}
	sleep    3s
    [Teardown]    csn.disconnect    connection=gNB${gNB_index}