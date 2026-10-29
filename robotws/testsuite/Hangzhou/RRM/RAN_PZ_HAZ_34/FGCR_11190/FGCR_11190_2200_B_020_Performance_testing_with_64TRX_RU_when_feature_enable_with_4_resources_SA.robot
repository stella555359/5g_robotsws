# # #*** Settings ***
# # #Documentation
# # #...    author: Bella chen
# # #...    contact:bella.chen@nokia-sbell.com
# # #...    squad group: SG_03
# # #...    feature : FGCR11190
# # #
# # #Force Tags    CA_5G_RRM
# # #...    PY36
# # #
# # #
# # #Suite Setup    Run Keywords
# # #...    Run Keyword And Ignore Error    Common Suite Setup for COAM    AND
# # #...                            ASKEY UE parameter setup
# # #
# # #Suite Teardown      Run Keyword And Ignore Error     Common Suite Teardown for COAM
# # #
# # ##Resource       Resources/5GC001190_coam_common_keywords.robot
# # ##Resource       Resources/HAOJIN_MCS_common_keywords.robot
# # #
# # #Resource       ../5GC002200/Resources/5GC002200_coam_common_keywords.robot
# # #Resource       ../5GC002200/Resources/HAOJIN_MCS_common_keywords.robot
# # #
# # #*** Variables ***
# # #${TL381_scf_disable2200}          TL381_2200disable.xml
# # #${TL381_scf_enable2200}           11190_TL381.xml
# # #${swconfig}                 /opt/workspace/SCF/11190/swconfig/swconfig.txt
# # #${2200_B_nglog}           2200_B_wireshark_enable.pcap
# # #${Send_Tput_DL}              1200M
# # #${att_middle}    65
# # #${att_good}    39
# # #${Expect_Peak}      900
# # #${csv_file}             2200_B020_result_TL381.csv
# # #${dlexpect}     0
# # #
# # #
# # #*** Test Cases ***
# # #[1]FGCR_11190_2200_B_020_Performance_testing_with_64TRX_RU_when_feature_enable_with_4_resources_SA
# # #    [Documentation]
# # #    ...    this case is to test performance with 64TRX(4*8) RU when 2200 feature enabled with N1N2 default in SA mode.
# # #    [Tags]      classical
# # #    [Setup]
# # #    Prepare testline to cell onair for SA    localFilePath=${swconfig}    tl_scf_filename=${TL381_scf_enable2200}
# # #    Set nrcellid suit varaible    cellid=${1}
# # #    HAOJIN MCS SET    att_value=${att_good}
# # #    power_ue.Prepare UE    ue_index=${0}    ue_type=${UE_TYPE}
# # #    Power UE Attach And Verify Attach For Askey    4g_check=False
# # #    Start DL date transfer on appserver     traffic=${Send_Tput_DL}
# # #    Log to console   check iperf
# # #    Wait Until Keyword Succeeds   8m   10s   power_ue.Check throughput   ue_type=${UE_TYPE}   direction=dl   throughput=${Expect_Peak}
# # #    HAOJIN TEST with one ATT    att=${att_middle}    begin_θ_v=90    end_θ_v=91
# # #    ...    begin_θ_h=-60    end_θ_h=60    B1_port=1    B4_port=4    B2_port=2    B3_port=3    csv_path=${epc_log_path}/${csv_file}
# # #    ...    vertical_distance=${1.47}    horizontal_distance=${0.52}
# # #    ${ave}=    HAOJIN_MCS_common_keywords.Caculate average tput_HJ
# # #    should be true    ${ave} >= 500
# # #    [Teardown]    Run Keyword And Ignore Error     Tests Recover
# # #
# # #*** Keywords ***
# # #HAOJIN MCS SET
# # #    [Arguments]    ${att_value}
# # #    HAOJIN MCS Prepare    ip=${haojin_ip_365}
# # #    Set HAOJIN horizontal and vertical Phases by output_port    begin_output_port=${1}    end_output_port=${2}    input_group_id=${0}
# # #    ...    vertical_angle=${90}    horizontal_angle=${-31}    vertical_distance=${1.47}    horizontal_distance=${0.52}    mcs_alias=HJ
# # #    Set HAOJIN horizontal and vertical Phases by output_port    begin_output_port=${3}    end_output_port=${4}    input_group_id=${0}
# # #    ...    vertical_angle=${90}    horizontal_angle=${-43}    vertical_distance=${1.47}    horizontal_distance=${0.52}    mcs_alias=HJ
# # #    Set HAOJIN ATT_90    att_value=${att_value}
# # #
# # #Tests Recover
# # #    MCS teardown    mcs_alias=HJ
# # #    gNB connections    asik_addr=${asik_addr}    asik_username=${asik_username}    asik_password=${asik_password}
# # #    csn.send command    command=killall tcpdump     connection=gnb
# # #    Askey UE stop dl traffic on appserver and detach
# # #    disconect all connections
