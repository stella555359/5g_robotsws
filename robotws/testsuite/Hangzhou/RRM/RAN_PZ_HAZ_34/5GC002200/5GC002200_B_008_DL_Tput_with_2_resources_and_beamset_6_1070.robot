# # #*** Settings ***
# # #Force Tags    PY36
# # #Documentation
# # #...    author: liujia
# # #...    contact:jia-rebecca.liu@nokia-sbell.com
# # #...    squad group: SG_03
# # #...    feature : 5GC002200
# # #
# # #
# # #Suite Setup         Run keywords
# # #...    robot_common_operations.Common Suite Setup    AND
# # #...    Run Keyword And Ignore Error       Common Suite Setup for COAM 2200
# # #
# # #Suite Teardown      Run keywords
# # #...    robot_common_operations.Common Suite Teardown    AND
# # #...    Run Keyword And Ignore Error       Common Suite Teardown for COAM
# # #
# # #
# # #Resource       Resources/5GC002200_coam_common_keywords.robot
# # #
# # #
# # #*** Variables ***
# # #@{DL_expect_22R2}           1200
# # #@{DL_expect_Trunk}          660
# # #@{DL_expect_22R3}           1050
# # #${2200_B_wireshark}         2200_B_wireshark
# # #${ASKEY_DL_PORT}            ${ue_param['data_transfer']['iperf_options']['qci'][5]}
# # #${ASKEY_UL_PORT}            ${ue_param['data_transfer']['iperf_options']['qci'][6]}
# # #@{att_value_22R2}           25    55    75    127
# # #@{att_value_Trunk}          0     55    75    127
# # #@{att_value_22R3}           28    50    70    127
# # #${ue_num}                   1
# # #
# # ###22R2 test on TL362##
# # ###TRUNK test on TL365##
# # ###22R3 test on TL374##
# # #
# # #*** Test Cases ***
# # #[1]5GC002200_B_008_max_DL_Tput_with_2_resources_and_beamset_6_good_condition_1070_Frametype_SA
# # #    [Documentation]
# # #    ...    this test case is to verify 32TRX(2*8*2) RU can test DL data transfer successfully when 2200 feature enable in good air
# # #    ...    condition(around -60dbm). DL tput can achieve to peak throughput and compare with DL tput when 1856 enabled, There should
# # #    ...    be a little more or equal for the cell throughput with the same radio condition(good radio condition), if there is a bler,
# # #    ...    it should be a little less or equal to the bler of 1856 enabled . It can be no need be better(better will be good), but it
# # #    ...    should be commit no aggravate.
# # #    ...    AEHC with frametype 1208/1070 performance not well,so only cover 1116.
# # #    ...    add CNI74278_A_04_SA_max_DL_Tput_with_2CSI-RS_4x1_#2_0_BW_100M_1208 case check points
# # #    ...    keep origin frame 1070;
# # #    ...    UE can get peak with the right beamweight. beamset=(2+1)x(4+16))=60;
# # #    ...    n1:n2 will use extend 4x1, PA port 3and5, 4and6, 7and9, 8and10.
# # #    ...    Trunk csirsResourceSetConfig2CRI = 4x1-2_0;
# # #    [Tags]      classical    CRT_22R2    CRT_TRUNK     CRT_22R3    CRT_22R4
# # #    [Timeout]    1 hour
# # #    [Setup]    robot_common_operations.Common Case Setup
# # #    Case variable set for 2200_B_008
# # #    Common Case TestLine Setup    ModifySCF_Beforecommission=True    Is_Swconfig=True     Lock_ENB_Need=True    is_x2
# ..._check_from_gnb_needed=${True
# # }
# # #    ...                           swconfig_file=${swconfig}    golden_scf_name=${${golden_scf_name}}
# # #    ...                           ParameterToDelete=${${ParameterToDelete}}
# # #    ...                           ListToAdd=${${ListToAdd}}
# # #    ...                           ParamterToModify=${${ParamterToModify}}
# # #    ...                           ListParamterToModify=${${ListParamterToModify}}
# # #    ...                           enb_dist_name=${ENB_cell1_dist}
# # #    ...                           enb_parameter=${enb_cell_admin}
# # #    ...                           enb_value=locked
# # #    sleep    10s
# # #    Common Case TestLine Setup    ModifySCF_Aftercommission=True
# # #    ...                           Modify_Para_Online=${UNLOCK_GNB_AMF}
# # #    Set nrcellid suit varaible    cellid=${${cellid}}
# # #    UE precondition with uetype
# # #    MCS SETUP AND SET ATT         att_value=${@{${att_value}}[0]}
# # #    ${cpif_log_01}=        attach UE with uetype and capture wiresharklog    wiresharklog=${2200_B_wireshark}    ue_num=${ue_num}
# # #    BuiltIn.Set Test Variable    ${cpif_log_01}
# # #    ${2200_B008_BIP}=      Start DL Traffic And Capture Biplog        script_path=${bipscript_path}
# # #    ...                                                               dlexpect_tp=${@{${dlexpect_tp}}[0]}
# # #    UE stop traffic and detach with uetype
# # #    Analysis 2200 enable
# # #    Check beamweight for CNI74278    beamweight_name=${${beamweight_name}}    connection=gnb    beamset_num=60
# # #    MCS Teardown with mcs_type       mcs_type=${mcs_type}
# # #    run keyword if    '${MRBTS_ID}' == '10318'
# # #    ...                Modify the COAM parameter with admin API    parameters=${UNLOCK_GNB1_CELL2}
# # #    [Teardown]    Run Keywords
# # #    ...    robot_common_operations.Common Case Teardown    AND
# # #    ...    Run Keyword And Ignore Error     Tests Recover
# # #
# # #*** Keywords ***
# # #
# # #MCS SETUP AND SET ATT
# # #    [Arguments]    ${att_value}
# # #    ${mcs_type}=    mcs_common.Get MCS Type
# # #    set suite variable      ${mcs_type}
# # #    Run keyword if    '${mcs_type}'=='haojin'    HAOJIN MCS SETUP AND SET ATT for ONE UE   mcs_type=${mcs_type}
# # #    ...    att_value_1=${att_value}    att_value_2=${att_value}
# # #    ...    P1_out=${13}    P2_out=${14}    vertical_1=${96}    horizontal_1=${13}
# # #    ...    P3_out=${15}    P4_out=${16}    vertical_2=${96}    horizontal_2=${27}
# # #    Run keyword if    '${mcs_type}'=='topyoung'    TOPYOUNG MCS SETUP Phases AND SET ATT    mcs_type=${mcs_type}
# # #    ...    att_value1=${att_value}    att_value2=${att_value}    vertical_angle=${-6}
# # #    ...    first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${-5}
# # #    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${5}
# # #    Run keyword if    '${mcs_type}'=='hbte'    HBTE MCS SETUP Phases AND SET ATT    mcs_type=${mcs_type}
# # #    ...    att_value1=${att_value}    att_value2=${att_value}    vertical_angle=${96}
# # #    ...    first_beam_begin_output_port=${5}     first_beam_end_output_port=${6}     first_beam_horizontal_angle=${5}
# # #    ...    second_beam_begin_output_port=${7}    second_beam_end_output_port=${8}    second_beam_horizontal_angle=${15}
# # #
# # #
# # #Analysis 2200 enable
# # #    ${nrofPorts}=    Get CSIRS_nrofPorts from CPIF    file_path=${cpif_log_01}
# # #    should contain x times    ${nrofPorts}    p8    2
# # #    ${cdm_Type}=     Get CSIRS_cdm_Type from CPIF     file_path=${cpif_log_01}
# # #    should contain    ${cdm_Type}    2
# # #    ${density}=      Get CSIRS_density from CPIF      file_path=${cpif_log_01}
# # #    should contain    ${density}     1
# # #    ${n1-n2}=        Get CSIRS_n1_n2 from CPIF        file_path=${cpif_log_01}
# # #    should contain    ${n1-n2}       2
# # #
# # #
# # #Tests Recover
# # #    Run Keyword And Ignore Error     Common Case TestLine Setup     Lock_ENB_Need=True     enb_dist_name=${ENB_cell1_dist}
# # #    ...                                                             enb_parameter=${enb_cell_admin}
# # #    ...                                                             enb_value=unlocked
# # #    Run Keyword And Ignore Error    gNB connections    asik_addr=${asik_addr}    asik_username=${asik_username}    as
# ...ik_password=${asik_password}
# # #    Run Keyword And Ignore Error    csn.send command    command=killall tcpdump     connection=gnb
# # #    Run Keyword And Ignore Error    Connect to TestPc    alias=ute
# # #    Run Keyword And Ignore Error    csn.send command
# # #    ...                   command=ps -ef | grep cli |grep ute_common_admin | grep -v grep |awk '{print $2}' |xargs kill -9    connection=ute
# # #    Run Keyword And Ignore Error    UE stop traffic and detach with uetype
# # #    Run Keyword And Ignore Error    MCS Teardown with mcs_type    mcs_type=${mcs_type}
# # #    Run Keyword And Ignore Error    clear cli process
# # #    Run Keyword And Ignore Error    disconect all connections
