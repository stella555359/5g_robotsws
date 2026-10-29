# # #*** Settings ***
# # #Force Tags    PY36
# # #Documentation
# # #...    author: kk
# # #...    contact:kk.wang@nokia-sbell.com
# # #...    squad group: SG_03
# # #...    feature : 5GC002200
# # #
# # #Suite Setup    Run Keywords
# # #...    Run Keyword And Ignore Error    Common Suite Setup for COAM    AND
# # #...                            ASKEY UE parameter setup
# # #
# # #Suite Teardown      Run Keywords
# # #...     Run Keyword And Ignore Error    Common Suite Teardown for COAM     AND
# # #...     Run Keyword And Ignore Error                        Tests Recover
# # #
# # #Resource       Resources/5GC002200_coam_common_keywords.robot
# # #Variables      Resources/variables.py
# # #
# # #*** Variables ***
# # #${TL362_scf_B022}           TL362_GNB_2200_Enable_B022.xml
# # #${swconfig}                 /opt/workspace/SCF/2200/swconfig/swconfig.txt
# # #${topyoung_ip_362}           ${tl.attenuator[0].ip_addr}
# # #${model}                     ${tl.attenuator[0].model}
# # #${ASKEY_DL_PORT}             ${ue_param['data_transfer']['iperf_options']['qci'][5]}
# # #${Send_Tput_DL}         1500M
# # #${csv_file_B022}                 2200_B022_result_TL362.csv
# # #${dlexpect}                      200
# # #
# # ###21B test on TL362##
# # #
# # #*** Test Cases ***
# # #[1]5GC002200_B_022_Performance_testing_with_32TRX_RU_when_feature_enable_with_2_resources_NSA
# # #    [Documentation]
# # #    ...    this case is to test performance with 32TRX(2*8*2) RU when 2200 feature enabled with N1N2 default 1 NSA mode.
# # #    [Tags]      classical    CRT_20B    CRT_21B    CRT_22R1    CRT_22R2
# # #    [Setup]
# # #    Prepare testline to cell onair for NSA    localFilePath=${swconfig}    tl_scf_filename=${TL362_scf_B022}
# # #    ...    enbx2_dist=${enbx2_dist_TL365}
# # #    Connect and Modify the parameter on enblte    dist_name=${TL362_enb_dist}    parameter=${defaultgnbcell}    value=1
# # #    Modify the COAM parameter with admin API    parameters=${LOCK_GNB1_CELL1}
# # #    Set nrcellid suit varaible    cellid=${2}
# # #    MCS Prepare and set frequency    ip=${topyoung_ip_362}
# # #    Set TOPYOUNG ATT TO LOCK AZQO
# # #    Set TOPYOUNG horizontal and vertical Phases by output_port    begin_output_port=${1}    end_output_port=${2}    begin_input_port=${1}
# # #    ...    end_input_port=${16}    vertical_angle=${-6}    horizontal_angle=${-6}    mcs_alias=TPY
# # #    Set TOPYOUNG horizontal and vertical Phases by output_port    begin_output_port=${3}    end_output_port=${4}    begin_input_port=${1}
# # #    ...    end_input_port=${16}    vertical_angle=${-6}    horizontal_angle=${6}    mcs_alias=TPY
# # #    Power UE Precondition
# # #    Power UE Attach And Verify Attach For Askey    4g_check=True
# # #    Start DL date transfer on appserver    DL_port=${ASKEY_DL_PORT}    traffic=${Send_Tput_DL}
# # #    TEST with different ATTs    att_goodpoint=25    att_medialpoint=40    att_poorpoint=55    begin_θ_v=-6    end_θ_v=-2
# # #    ...    begin_θ_h=-60    end_θ_h=55    B1_port=1    B4_port=2    B2_port=3    B3_port=4    begin_input_port=1
# # #    ...    end_input_port=16    csv_path=${epc_log_path}/${csv_file_B022}
# # #    Caculate average tput     csv_path=${epc_log_path}/${csv_file_B022}
# # #    MCS teardown    mcs_alias=TPY
# # #    [Teardown]    Run Keyword And Ignore Error     Tests Recover
# # #
# # #
# # #
# # #*** Keywords ***
# # #Tests Recover
# # #    Modify the COAM parameter with admin API    parameters=${UNLOCK_GNB1_CELL1}
# # #    Run Keyword And Ignore Error    Askey UE stop dl traffic on appserver and detach
# # #    MCS teardown    mcs_alias=TPY
# # #    clear cli process
# # #    disconect all connections
# # ##    Run keyword and continue on failure    CI_interface.Common Case Teardown
# # #
