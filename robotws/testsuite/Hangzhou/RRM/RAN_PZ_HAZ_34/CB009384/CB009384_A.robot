*** Settings ***
Force Tags    PY36
Documentation     author: yifan.hu
...                 contact: yifan.hu@nokia-sbell.com
...                 squad group: SG_03
...                 feature : CB009384-A

Resource    ./Resources/CB009384_common_keywords.robot
Variables    ./Resources/CB009384_variables.py


Suite Setup    Run Keywords    Common Suite Setup for COAM
...            AND    Get gnb release info
...            AND    get_release_check_result
...            AND    Common Case TestLine Setup    is_commission=True    is_commission_for_second_gnb=True    scf_path=${scf_path}
...            golden_scf_name=${gnb1_scf_${release_info}}    golden_scf_name_gnb2=${gnb2_scf_${release_info}}

Suite Teardown    Run Keywords
...               Run Keyword And Ignore Error    Common Suite Teardown for COAM   AND
...               Run Keyword And Ignore Error    COAM Teardown gnb connections


*** Variables ***
${gnb_path}    /tmp
${scf_path}    /opt/workspace/CRT/Master/SCF_file/
${epc_log_path}    /opt/workspace/CRT/Master/Case_Logs/
${gnb1_scf_SBTS26R1_ENB_9999}    golden_TDD.xml
${gnb2_scf_SBTS26R1_ENB_9999}    golden_FDD.xml
${gnb1_scf_SBTS25R3_ENB_0000}    golden_TDD.xml
${gnb2_scf_SBTS25R3_ENB_0000}    golden_FDD.xml
${logname_18bit}    A_18bit.pcap
${logname_12bit}    A_12bit.pcap
${logname_gnb2_attach}    gnb2_attach.pcap
${logname_RRE}    gnb2_RRE_to_gnb1.pcap
${logname_16drbs}    A_16drbs.pcap
${logname_vonr}    vonr_setup.pcap
${interface1}    any
${expected_tput_ul}    76
${expected_tput_dl}   190
${expected_tput_ul_grant}    40
${expected_tput_dl_grant}   55
${length_id_18bit}    1
${length_id_12bit}    0
@{6drbs}    5   6   7   8   9   128
@{2drbs}    8   9
${12b_xpath1}    nr-rrc.nonCriticalExtension_element/nr-rrc.masterCellGroup/nr-rrc.CellGroupConfig_element/
${12b_xpath2}    nr-rrc.rlc_BearerToAddModList/_[1]/nr-rrc.RLC_BearerConfig_element/nr-rrc.rlc_Config/nr-rrc.am_element/
${12bit_ul_xpath}    nr-rrc.ul_AM_RLC_element/nr-rrc.sn_FieldLength
${12bit_dl_xpath}    nr-rrc.dl_AM_RLC_element/nr-rrc.sn_FieldLength
${UE_type_sansumg}    ${tl.ues[3].capabilities[0]}
${IE}    ngap/ngap.NGAP_PDU/ngap.initiatingMessage_element/ngap.value_element/ngap.InitialUEMessage_element/
${TMSI_IE}    ngap.protocolIEs/_[5]/ngap.ProtocolIE_Field_element/ngap.value_element/ngap.FiveG_S_TMSI_element
${redcap_IE}    ngap.protocolIEs/_[6]/ngap.ProtocolIE_Field_element/ngap.value_element/ngap.RedCapIndication

*** Test Cases ***
[1]CB009384-A_B2_RedCap_UE_identification_during_call_setup_and_data_transfer_18_bit_length
    [Documentation]
    ...    This case checks RedCap UE 18 bit identification during call setup and data transfer
    [Tags]    classical    CRT_TRUNK    CRT_23R3
    [Setup]    robot_common_operations.Common Case Setup    allowed_faults_ids=7311
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_MO_GNB1_A_18bit}
    Prepare with PM counter time to caculate
    Run keyword If    '${gnb_instance0}'== '${gnb_id}[1]'    Adjust gNB_RU Attenuation    gnb1_cell3_value=${40}
    ...    ELSE    Adjust gNB_RU Attenuation    gnb1_cell3_value=${25}    gnb1_cell3_value1=${8}
    MTK prepare UE    ue_type=${ue_type}    ue_index=${2}
    Start capture gNB log on master    filename=${logname_18bit}    gNB_index=${0}
    MTK UE Attach    ue_type=${ue_type}    ue_index=${2}
    Stop and download the Logs    filename=${logname_18bit}   gNB_index=${0}
    Check wireshark log for SN length    logname=${logname_18bit}    length_id=${length_id_18bit}
    Start DLUL traffic and check throughput    cellid=3    ue_index=${2}    ul_throughput=NULL    tput_ul=NULL
    Stop UE DLUL traffic    ue_index=${2}    ul_port=NULL
    Wait until keyword succeeds    5 min    20s    Check counter for 18bit
    ###check CGType2
    Run Keyword And Ignore Error    Start DLUL traffic and check throughput   logname=${logname_18bit}
    ...    cellid=3    ue_index=${2}    dl_throughput=NULL    tput_dl=NULL
    Stop UE DLUL traffic    ue_index=${2}    dl_port=NULL    ue_type=Huawei
    Wait until keyword succeeds    10 min    20s    Check counter for CGType2
    [Teardown]    run keywords
    ...    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${2}    AND
    ...    Run Keyword And Ignore Error    Case Teardown

[1]CB009384-A_B2_RedCap_UE_identification_during_call_setup_and_data_transfer_12_bit_length_check_counter
   [Documentation]
    ...    This case checks RedCap UE 12 bit identification during call setup and data transfer
    [Tags]    classical    CRT_TRUNK    CRT_23R3
    [Setup]    robot_common_operations.Common Case Setup    allowed_faults_ids=7311
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    ${release_info}    Get sagnb release
    ###check SN 12bit
    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_MO_GNB1_A_12bit}
    Modify Parameters for Cases   gnb_index=${1}    Modify_Para_Online=${PARAMETERS_TO_MO_GNB2_RRE}
    Adjust gNB_RU Attenuation    gnb2_cell2_value=${40}
    MTK prepare UE    ue_type=${ue_type}    ue_index=${2}
    Start capture gNB log on master    filename=${logname_gnb2_attach}    gNB_index=${1}
    MTK UE Attach    ue_type=${ue_type}    ue_index=${2}
    Start capture gNB log on master    filename=${logname_RRE}    gNB_index=${0}
    Adjust gNB_RU Attenuation    gnb1_cell3_value=${40}     gnb2_cell2_value=${40}
    sleep    2s
    Run keyword If    '${gnb_instance0}'== '${gnb_id}[1]'    Adjust gNB_RU Attenuation    gnb1_cell3_value=${0}
    ...    ELSE    Adjust gNB_RU Attenuation    gnb1_cell3_value=${25}    gnb1_cell3_value1=${8}
    sleep    10s
    Stop and download the Logs    filename=${logname_RRE}   gNB_index=${0}
    Stop and download the Logs    filename=${logname_gnb2_attach}   gNB_index=${1}
    Check RRE IE    logname=${logname_RRE}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${2}
    Run keyword If    '${gnb_instance0}'== '${gnb_id}[1]'    Adjust gNB_RU Attenuation    gnb1_cell3_value=${40}
    ...    ELSE    Adjust gNB_RU Attenuation    gnb1_cell3_value=${25}    gnb1_cell3_value1=${8}
    Prepare with PM counter time to caculate
    Sleep    60s
    Start capture gNB log on master    filename=${logname_12bit}    gNB_index=${0}
    MTK UE Attach    ue_type=${ue_type}    ue_index=${2}
    Stop and download the Logs    filename=${logname_12bit}   gNB_index=${0}
    Check wireshark log for SN length    logname=${logname_12bit}    length_id=${length_id_12bit}
    Wait until keyword succeeds    10 min    20s    Check counter for 12bit
    Start DLUL traffic and check throughput    cellid=3    ue_index=${2}    ul_throughput=NULL    tput_ul=NULL
    Stop UE DLUL traffic    ue_index=${2}    ul_port=NULL
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${2}
    Wait until keyword succeeds    10 min    20s    Check counter for redcap release
    ###nomal UE attach and check Tput
    Run keyword If    '${gnb_instance0}'== '${gnb_id}[0]'     sansumg attach and start traffic
    ###check Proactive UL grant
    Run keyword If    '${gnb_instance0}'== '${gnb_id}[1]'    Adjust gNB_RU Attenuation    gnb1_cell3_value=${40}
    ...    ELSE    Adjust gNB_RU Attenuation    gnb1_cell3_value=${25}    gnb1_cell3_value1=${8}
    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_MO_GNB1_grant}
    MTK UE Attach    ue_type=${ue_type}    ue_index=${2}
    Start DLUL traffic and check throughput    cellid=3    ue_index=${2}    dl_length=100B
    ...    ul_throughput=NULL    tput_ul=NULL
    ...    tput_dl=${expected_tput_dl_grant}
    Stop UE DLUL traffic    ue_index=${2}    ul_port=NULL
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${2}
    ###check maxNumOfRrcSARedCap
    Prepare with PM counter time to caculate
    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_MO_GNB1_maxNumOfRrcSARedCap}
    Run Keyword And Ignore Error    MTK UE Attach    ue_type=${ue_type}    ue_index=${2}
    Wait until keyword succeeds    10 min    20s    Check counter for redcap attach fail
    [Teardown]    run keywords
    ...    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${2}    AND
    ...    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_MO_GNB1_recover}    AND
    ...    Run Keyword And Ignore Error    Case Teardown

#[1]CB009384-A_B2_RedCap_UE_identification_during_call_setup_and_data_transfer_max_16_DRBs
#    [Documentation]
#    ...    This case checks RedCap UE setup 16 drbs.(up to 8drbs due to M60 UE limitation)
#    [Tags]    classical    CRT_TRUNK    CRT_23R3
#    [Setup]    robot_common_operations.Common Case Setup
#    ${release_info}    Get sagnb release
#    Common Case TestLine Setup   ModifySCF_Beforecommission=True
#    ...    golden_scf_name=${scf_path}${tl_scf_${release_info}}    ParamterToModify=${PARAMETERS_TO_MO_GNB1_A_7225}
#    ...    ListToAdd=${LIST_TO_ADD_GNB1_A_7225_${release_info}}    ParameterToDelete=${PARAMETERS_TO_DELETE_GNB1_A_BWP}
#    Prepare with PM counter time to caculate
#    Adjust gNB_RU Attenuation    gnb1_cell3_value=${40}
#    MTK prepare UE    ue_type=${ue_type}    ue_index=${2}
#    Start capture gNB log on master    filename=${logname_16drbs}    gNB_index=${0}
#    MTK UE Attach    ue_type=${ue_type}    ue_index=${2}
#    MTK UE Act Additional PDN    ue_index=${2}    pdn=mdrb1.nokia.com
#    Stop and download the Logs    filename=${logname_16drbs}   gNB_index=${0}
#    Check wireshark log for multi-drbs    logname=${logname_16drbs}
#    ...    multi_apn=mdrb1.nokia.com    drb_length=${6}    multi_drbs=@{6drbs}
#    Start DLUL traffic and check throughput    cellid=3    ue_index=${2}    ul_throughput=NULL    tput_ul=NULL
#    Stop UE DLUL traffic    ue_index=${2}    ul_port=NULL
#    Wait until keyword succeeds    5 min    20s    Check counter for 7552
#    [Teardown]    run keywords
#    ...    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${2}    AND
##    ...    Run Keyword And Ignore Error    recover for 20M    AND
#    ...    Run Keyword And Ignore Error    Case Teardown
#
#[1]CB009384-A_IWK3_Feature_interworking_for_RedCap_UE_with_7552_and_30M_band_2DMRS
#    [Documentation]
#    ...    This case checks redcap UE IWK with 7552 and 30M band 2DMRS
#    [Tags]    classical    CRT_TRUNK    CRT_23R3
#    [Setup]    robot_common_operations.Common Case Setup
#    Common Case TestLine Setup    ModifySCF_Beforecommission=True    scf_path=${scf_path}
#    ...    golden_scf_name=${tl_scf_filename_gnb1}
#    ...    ParamterToModify=${PARAMETERS_TO_MO_GNB1_A_7225}    ListToAdd=${LIST_TO_ADD_GNB1_A_7225}
#    ...    ListParamterToModify=${LIST_TO_MO_GNB1_A_30M}
#    Prepare with PM counter time to caculate
#    Adjust gNB_RU Attenuation    gnb1_cell3_value=${30}
#    MTK prepare UE    ue_type=${ue_type}    ue_index=${2}
#    MTK UE Attach    ue_type=${ue_type}    ue_index=${2}
#    Start DLUL traffic and check throughput    cellid=3    ue_index=${2}    ul_throughput=NULL    tput_ul=NULL
#    Stop UE DLUL traffic    ue_index=${2}    ul_port=NULL
#    Wait until keyword succeeds    5 min    20s    Check the PM counter should be value
#    ...    gnb_index=${0}    counter_id=${counter_id_7552}
#    ...    dic_path=${counter_dic_path_7552}    value=${counter_value_7552}
#    [Teardown]    run keywords
#    ...    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${2}    AND
#    ...    recover for 20M    AND
#    ...    Run Keyword And Ignore Error    Case Teardown


*** Keywords ***
recover for 20M
    Modify Parameters for Cases   gnb_index=${0}    Delete_Para_Online=${PARAMETERS_TO_DEL_GNB1_A_20M}
    ...    Add_Para_Online=${PARAMETERS_TO_ADD_GNB1_A_20M_trunk}
    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_MO_GNB1_A_20M}

Check counter for redcap attach fail
    Run Keyword If    '${check_result}' != 'True'    Check the PM counter should be equal
    ...    gnb_index=${0}    counter_id=${counter_id_attach_fail}
    ...    dic_path=${counter_dic_path_attach_fail}
    ...    ELSE    Check the PM counter should be equal
    ...    gnb_index=${0}    counter_id=${counter_id_attach_fail}
    ...    dic_path=${counter_dic_path_attach_fail_trunk}

Check counter for redcap release
    Run Keyword If    '${check_result}' != 'True'    Check the PM counter should be value
    ...    gnb_index=${0}    counter_id=${counter_id_12bit_release}
    ...    dic_path=${counter_dic_path_12bit_release}    value=${counter_value_12bit_release}
    ...    ELSE    Check the PM counter should be value
    ...    gnb_index=${0}    counter_id=${counter_id_12bit_release}
    ...    dic_path=${counter_dic_path_12bit_release_trunk}    value=${counter_value_12bit_release}

Check counter for 12bit
   Run Keyword If    '${check_result}' != 'True'    Check counter for 12bit for branch
   ...    ELSE    Check counter for 12bit for trunk

Check counter for 12bit for trunk
    Check the PM counter should be value
    ...    gnb_index=${0}    counter_id=${counter_id_12bit_1}
    ...    dic_path=${counter_dic_path_12bit_1_trunk}    value=${counter_value_12bit_1}
    Check the PM counter should be value
    ...    gnb_index=${0}    counter_id=${counter_id_12bit_0}
    ...    dic_path=${counter_dic_path_12bit_0_trunk}    value=${counter_value_12bit_0}
    Check the PM counter should be greater than value
    ...    gnb_index=${0}    counter_id=${counter_id_12bit_sum}
    ...    dic_path=${counter_dic_path_12bit_sum_trunk}    value=${100}

Check counter for 12bit for branch
    Check the PM counter should be value
    ...    gnb_index=${0}    counter_id=${counter_id_12bit_1}
    ...    dic_path=${counter_dic_path_12bit_1}    value=${counter_value_12bit_1}
    Check the PM counter should be value
    ...    gnb_index=${0}    counter_id=${counter_id_12bit_0}
    ...    dic_path=${counter_dic_path_12bit_0}    value=${counter_value_12bit_0}
    Check the PM counter should be greater than value
    ...    gnb_index=${0}    counter_id=${counter_id_12bit_sum}
    ...    dic_path=${counter_dic_path_12bit_sum}    value=${100}

Check counter for 18bit
    Run Keyword If    '${check_result}' != 'True'    Check the PM counter should be greater than value
    ...    gnb_index=${0}    counter_id=${counter_id_18bit}
    ...    dic_path=${counter_dic_path_18bit}    value=${400}
    ...    ELSE    Check the PM counter should be greater than value
    ...    gnb_index=${0}    counter_id=${counter_id_18bit}
    ...    dic_path=${counter_dic_path_18bit_trunk}    value=${400}

Check counter for CGType2
    Run Keyword If    '${check_result}' != 'True'    Check the PM counter should be greater than value
    ...    gnb_index=${0}    counter_id=${counter_id_CGType2}
    ...    dic_path=${counter_dic_path_CGType2}        value=${0}
    ...    ELSE    Check the PM counter should be greater than value
    ...    gnb_index=${0}    counter_id=${counter_id_CGType2}
    ...    dic_path=${counter_dic_path_CGType2_trunk}        value=${0}

Check counter for 7552
    Run keyword if    '${release_info}' == '${branch}[2]'    Check the PM counter should be value
    ...    gnb_index=${0}    counter_id=${counter_id_7552}
    ...    dic_path=${counter_dic_path_7552_trunk}    value=${counter_value_7552}
    ...    ELSE    Check the PM counter should be value
    ...    gnb_index=${0}    counter_id=${counter_id_7552}
    ...    dic_path=${counter_dic_path_7552}    value=${counter_value_7552}

Check wireshark log for SN length
    [Arguments]    ${logname}    ${length_id}
    Check PDCP SN length    logname=${logname}    length_id=${length_id}
    Check RLC AM SN length    logname=${logname}    length_id=${length_id}


Check PDCP SN length
    [Arguments]    ${logname}    ${length_id}
    ...    ${message_filter1}=f1ap.procedureCode == 12
    ...    ${message_filter2}=f1ap.procedureCode == 12
    ...    ${xpath}=.//nr-rrc.pdcp_SN_SizeDL
    Log    PDCP SN length check
    ${pdcp_ul_sn_length}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath}
    should be equal    ${pdcp_ul_sn_length[0]}    ${length_id}
    ${pdcp_dl_sn_length}=    Check wireshark log    logname=${logname}    message_filter=${message_filter2}    xpath=${xpath}
    should be equal    ${pdcp_dl_sn_length[0]}    ${length_id}

Check RLC AM SN length
    [Arguments]    ${logname}    ${length_id}
    ...    ${message_filter}=f1ap.procedureCode == 12
    ...    ${xpath1}=.//${12b_xpath1}${12b_xpath2}${12bit_ul_xpath}
    ...    ${xpath2}=.//${12b_xpath1}${12b_xpath2}${12bit_dl_xpath}
    Log    RLC AM SN length check
    ${rlc_am_ul_sn_length}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath1}
    should be equal    ${rlc_am_ul_sn_length[0]}    ${length_id}
    ${rlc_am_dl_sn_length}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath2}
    should be equal    ${rlc_am_dl_sn_length[0]}    ${length_id}

sansumg attach and start traffic
    Adjust gNB_RU Attenuation    gnb1_cell3_value=${0}
    attach with normal UE
    Start UE DLUL traffic    ue_type=${UE_type_sansumg}    ue_index=${3}
    Sleep    10s
    Check DLUL tput     cellid=3    gnb_index=${0}    ue_index=${3}    duration=300s
    Stop UE DLUL traffic    ue_type=${UE_type_sansumg}   ue_index=${3}
    [Teardown]    power_ue.UE Detach    ue_type=${UE_type_sansumg}   ue_index=${3}

Check RRE IE
    [Arguments]    ${logname}
    ...    ${message_filter}=ngap.id
    ...    ${xpath1}=.//${IE}${TMSI_IE}
    ...    ${xpath2}=.//${IE}${redcap_IE}
    Log    PDCP SN length check
    ${TMSI_IE}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath1}
    ...    attribute_name=showname
    should be equal    ${TMSI_IE}[0]    FiveG-S-TMSI
    ${redcap_IE}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath2}
    ...    attribute_name=showname
    should be equal    ${redcap_IE}[0]    RedCapIndication: redcap (0)
