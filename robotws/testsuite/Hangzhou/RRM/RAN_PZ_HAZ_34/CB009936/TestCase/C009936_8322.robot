*** Settings ***
Force Tags    PY36
Documentation     author: qingqing zhang
...                 contact: qingqing.zhang@nokia-sbell.com
...                 squad group: SG_03
...                 feature : CB008140-AB

Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008140/Resources/CB008140_common_keywords_multiUE.robot
Variables    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB009936/Resources/CB009936_variables.py

Suite Setup    Run Keywords
...            robot_common_operations.Common Suite Setup
...            AND    Common Suite Setup for COAM
...            AND    Common Case TestLine Setup for gnb1

Suite Teardown    Run Keywords
...               robot_common_operations.Common Suite Teardown    AND
...               Adjust gNB_RU Attenuation for 2gnb    AND
...               Run Keyword And Ignore Error    Common Suite Teardown for COAM   AND
...               Run Keyword And Ignore Error    COAM Teardown gnb connections


*** Variables ***
${gnb_path}    /tmp
${tl_scf_gnb}    SCF_GNB1_
${scf_path}    /opt/workspace/SCF/
${interface1}    any
${expected_tput_ul_100M}    80
${expected_tput_ul_20M}    17
${expected_tput_dl_100M}    1470
${expected_tput_dl_20M}    264
${dl_throughput}      400
${ul_throughput}     200M
${filename_gnb1_8322_attach_1}    CB009936_CB008322_D_28_attach1.pcap
${filename_gnb1_8322_attach_2}    CB009936_CB008322_D_28_attach2.pcap
@{allow_fault_list}    4098    62003    7311    7307
*** Test Cases ***
[1]CB009936_CB008322_D_28_Verify_singleUE_Comb4_UL_DL_BF_20M_32TRX_1208
    [Documentation]
    ...    This case is check throughput when enable comb4
    [Tags]    classical    CRT_TRUNK
    [Setup]    robot_common_operations.Common Case Setup    allowed_faults_ids=4098,62003,7311,7307
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
#    Online close 72a pooling
    MultiUE.Prepare UE
    Attach and check tput    filename=${filename_gnb1_8322_attach_1}
    ...    tput_dl_expect=${expected_tput_dl_100M}    tput_ul_expect=${expected_tput_ul_100M}
    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_8322_20M}
    Attach and check tput    filename=${filename_gnb1_8322_attach_2}
    ...    tput_dl_expect=${expected_tput_dl_20M}    tput_ul_expect=${expected_tput_ul_20M}
    Hanging resource test    gnb_ips=@{gnb_ips}    gnb_list=${gnb_list}
    [Teardown]    run keywords
    ...    MultiUE.Detach    AND
    ...    MultiUE.Stop DLUL traffic
    ...    AND    Run Keyword And Ignore Error    Common Case Teardown for COAM    gnb_list=${gnb_list}

*** Keywords ***
Common Case TestLine Setup for gnb1
    @{scf_list}    Create List
    ${release_info}    Get sagnb release
    Common Case TestLine Setup    ModifySCF_Beforecommission=True
    ...    golden_scf_name=${tl_scf_gnb}${release_info}.xml    ParameterToDelete=${PARAMS_TO_delete_GNB1_8322}
    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB1_8322}    ListParamterToModify=${LIST_TO_modify_GNB1_8322}
    ...    ListToAdd=${LIST_TO_ADD_GNB1_8322}
#    Act Ecpri_RRU Mode Switch    scf_path=${scf_gnb}

Attach and check tput
    [Arguments]    ${filename}    ${tput_dl_expect}=${expected_tput_dl_20M}    ${tput_ul_expect}=${expected_tput_ul_20M}
    Adjust gNB_RU Attenuation for 2gnb     gnb1_cell3_value=${0}
    UE attach and collect log    filename=${filename}
    MultiUE.Start UE DLUL traffic    dl_throughput=${dl_throughput}    process_num=${4}
    ...    ul_throughput=${ul_throughput}
    ${nrcellid}    COAM Get nrcellid with lcrid    lcrid=${3}    gnb_index=${0}
    ${cellid}    Create list    ${nrcellid}
    ${tput_log}    power_ue.Collect Tput    duration=30s    ignore_time=0s    gnb_index=${0}    ue_type=${tl.ues[0].capabilities[0]}
    power_ue.Check Tput    direction=DL    cells=${cellid}    log=${tput_log}
    ...    target_throughput=${tput_dl_expect}    ue_type=${tl.ues[0].capabilities[0]}
    power_ue.Check Tput    direction=UL    cells=${cellid}    log=${tput_log}
    ...    target_throughput=${tput_ul_expect}    ue_type=${tl.ues[0].capabilities[0]}
    MultiUE.Stop DLUL traffic
    MultiUE.Detach

UE attach and collect log
    [Arguments]    ${filename}    ${gNB_index}=${0}
    Start capture gNB log on master    filename=${filename}   gNB_index=${gNB_index}
    MultiUE.Attach
    sleep    5s
    Stop and download the Logs    filename=${filename}    gNB_index=${gNB_index}
    [Teardown]    Stop and download the Logs    filename=${filename}    gNB_index=${gNB_index}

Online close 72a pooling
    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_UPDATE_pooling_72a}
    Sleep    180s