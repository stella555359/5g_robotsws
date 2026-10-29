# # #*** Settings ***
# # #Force Tags    PY36
# # #Documentation
# # #...    author: kk
# # #...    contact:kk.wang@nokia-sbell.com
# # #...    squad group: SG_03
# # #...    feature : 5GC002200
# # #
# # #
# # #Suite Setup    Run Keywords
# # #...    Run Keywords    Common Suite Setup for COAM
# # #...     AND    run keyword if    '${release_info}' == 'SBTS22R1_ENB_0000'    ASKEY UE parameter setup
# # #
# # #Suite Teardown      Run Keywords
# # #...     Run Keyword And Ignore Error    Common Suite Teardown for COAM     AND
# # #...     Run Keyword And Ignore Error                        Tests Recover
# # #
# # #Resource       Resources/5GC002200_coam_common_keywords.robot
# # #Variables      Resources/variables.py
# # #
# # #*** Variables ***
# # #${TL365_scf_B020}           TL365_GNB_2200_Enable_B020.xml
# # #${TL370_scf_B020}           TL370_GNB_2200_Enable_B020.xml
# # #${eNB_scf_file}                    TL370_ENB_SCF.xml
# # #${swconfig}                 /opt/workspace/SCF/2200/swconfig/swconfig.txt
# # #${ASKEY_DL_PORT}             ${ue_param['data_transfer']['iperf_options']['qci'][5]}
# # #${Send_Tput_DL}         1500M
# # #${dlexpect}                   100
# # #${Expect_dl_enable_circle}    100
# # #${csv_file_B020}             2200_B020_result.csv
# # #${ue_num}    1
# # #${Expect_dl_B20}        1200
# # #
# # ###TRUNK test on TL365##
# # ###21A test on TL370##
# # #
# # #*** Test Cases ***
# # #[1]5GC002200_B_020_Performance_testing_with_64TRX_RU_when_feature_enable_with_4_resources_NSA
# # #    [Documentation]
# # #    ...    this case is to test performance with 64TRX(4*8*2) RU when 2200 feature enabled with 4CSIRS setting in NSA mode.
# # #    [Tags]      classical    CRT_TRUNK    CRT_21A    CRT_22R1    CRT_22R2
# # #    [Setup]
# # #    Set nrcellid suit varaible    cellid=${1}
# # #    run keyword if    '${release_info}' == 'SBTS22R1_ENB_0000'    test peak on 22R1
# # #    ...    ELSE    test performance on trunk
# # #    run keyword if    '${release_info}' == 'SBTS22R3_ENB_0000'
# # #    ...    Caculate average tput     csv_path=${epc_log_path}/${csv_file_B020}
# # #    [Teardown]    Run Keyword And Ignore Error     Tests Recover
# # #
# # #*** Keywords ***
# # #Tests Recover
# # ##    Connect and Modify the parameter on enblte    dist_name=${TL362_enb_dist}    parameter=${defaultgnbcell}    value=0
# # #    gNB connections    asik_addr=${asik_addr}    asik_username=${asik_username}    asik_password=${asik_password}
# # #    csn.send command    command=killall tcpdump     connection=gnb
# # #    run keyword if    '${release_info}' == 'SBTS22R3_ENB_9999'    Multi UE Detach And Stop Traffic
# # #    ...     ELSE    Askey UE stop dl traffic on appserver and detach
# # #    run keyword if    '${release_info}' == 'SBTS22R3_ENB_9999'     MCS teardown     mcs_alias=HJ
# # #    ...     ELSE    MCS teardown    mcs_alias=FC
# # #    clear cli process
# # #    disconect all connections
# # ##    Run keyword and continue on failure    CI_interface.Common Case Teardown
# # #
# # #test performance on trunk
# # #    Prepare testline to cell onair for NSA    localFilePath=${swconfig}    tl_scf_filename=${TL365_scf_B020}
# # #    ...    enbx2_dist=${enbx2_dist_TL365}
# # #    HAOJIN MCS Prepare    ip=${haojin_ip_365}
# # #    Set HAOJIN horizontal and vertical Phases by output_port    begin_output_port=${13}    end_output_port=${14}    input_group_id=${0}
# # #    ...    vertical_angle=${96}    horizontal_angle=${13}    vertical_distance=${2.1}    horizontal_distance=${0.5}    mcs_alias=HJ
# # #    sleep    5s
# # #    Set HAOJIN horizontal and vertical Phases by output_port    begin_output_port=${15}    end_output_port=${16}    input_group_id=${0}
# # #    ...    vertical_angle=${96}    horizontal_angle=${27}    vertical_distance=${2.1}    horizontal_distance=${0.5}    mcs_alias=HJ
# # #    sleep    5s
# # #    Set HAOJIN Port13 to Port16 ATT    att_value=${0}
# # #    Multi-UEs attach and Data Transfer    ue_num=${ue_num}    attach_mode=${NSA_attach_mode}   ue_mode=${NSA_UE_MODE}
# # #    ...    nettpye=${NSA_nettype}    apn_address=${NSA_apn_addr}
# # #    HAOJIN TEST with different ATTs    att_goodpoint=0    att_medialpoint=30    att_poorpoint=55    begin_θ_v=96    end_θ_v=97
# # #    ...    begin_θ_h=-60    end_θ_h=55    B1_port=13    B4_port=16    B2_port=14    B3_port=15    vertical_distance=${2.1}
# # #    ...        horizontal_distance=${0.5}    csv_path=${epc_log_path}/${csv_file_B020}
# # #    MCS teardown    mcs_alias=HJ
# # #
# # #test peak on 22R1
# # #    Commission SCF to eNB    eNB_asik_addr=${ENB_ADDRESS}    connection=eNB    scf_file=${eNB_scf_file}
# # #    Prepare testline to cell onair for NSA    localFilePath=${swconfig}    tl_scf_filename=${TL370_scf_B020}
# # #    ...    enbx2_dist=${enbx2_dist_TL370}
# # #    HBTE PA ON 22R1   ${PA_port_list}    ${PA_values4}
# # #    Power UE Precondition
# # #    Power UE Attach and Verify attach for askey     4g_check=True
# # #    Start DL date transfer on appserver     traffic=${dl_throughput}
# # #    DL Tput check with nrcellid    cellid=${${nrcellid}}    dlexpect_tp=${Expect_dl_B20}    duration=5
