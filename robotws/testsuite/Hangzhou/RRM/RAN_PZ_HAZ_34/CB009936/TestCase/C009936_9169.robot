*** Settings ***
Force Tags    PY36
Documentation     author: qingqing zhang
...                 contact: qingqing.zhang@nokia-sbell.com
...                 squad group: SG_03
...                 feature : CB008140-AB

Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB009936/Resources/CB009936_Common_Keywords.robot
Variables    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB009936/Resources/CB009936_variables.py

Suite Setup    Run Keywords
...            robot_common_operations.Common Suite Setup
...            AND    Run Keyword And Ignore Error    Common Suite Setup for COAM
...            AND    Common Case TestLine Setup for gnb1

Suite Teardown    Run Keywords
...               robot_common_operations.Common Suite Teardown    AND
...               Run Keyword And Ignore Error    Common Suite Teardown for COAM   AND
...               Run Keyword And Ignore Error    COAM Teardown gnb connections


*** Variables ***
${gnb_path}    /tmp
${scf_path}    /opt/workspace/SCF/
${expected_tput_ul_100M}    114
${expected_tput_ul_20M}    80
${expected_tput_dl_100M}    1400
${expected_tput_dl_20M}    120
${Send_Tput_DL}      400M
${Send_Tput_UL}     300M
${logname_9169_BC_attach_2TX}    CB009936_9169_BC_attach_2TX_attach1.pcap
${logname1_9169_BC_attach_2TX}    CB009936_9169_BC_attach_2TX_attach2.pcap
@{allow_fault_list}    4098    62003    7311    7307    4282

*** Test Cases ***
[1]CB009936_CB009169-BB#2_TC10_IWK_between_UL_CA_and_Dynamic_UL_Resources_Allocation_in_TDD_Cell_BeamRefinement_and_5GC002200_are_enable
    [Documentation]
    ...    This case is check UL throughput with Intra gnb CA 2CC by T+F
    [Tags]    classical    CRT_TRUNK
    [Setup]    robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    MCS SETUP AND SET ATT for MTK80    gnb_cell1_PA_value_MTK80=${10}
    Adjust the HBTE attenuation value for MTK80
    Prepare UE For MTK80
    #####diaable actDlSrsBm and actUlSrsBm then check DL and UL#####
    Attach UE and Capture wireshark for MTK80    logname=${logname_9169_BC_attach_2TX}
    Check wireshark log for 2CC    logname=${logname_9169_BC_attach_2TX}    scell_index=${37402}    pcell_index=${37401}
    ...    scell_gnb_index=${0}
    Adjust the HBTE attenuation value for MTK80    gnb_cell2_value=${0}
    Start DLUL traffic and check throughput for MTK80   logname=${logname_9169_BC_attach_2TX}
    ...    scellid=4    pcellid=2    tput_dl_pcell=${expected_tput_dl_100M}    tput_dl_scell=${expected_tput_dl_20M}
    ...    tput_ul_pcell=${expected_tput_ul_100M}    tput_ul_scell=${expected_tput_ul_20M}    duration=30s
    Stop DLUL traffic and detech for MTK80
    Adjust the HBTE attenuation value for MTK80
    ###enable actDlSrsBm and actUlSrsBm then check DL and UL#####
    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_9169_enable_SRS}
    Attach UE and Capture wireshark for MTK80    logname=${logname1_9169_BC_attach_2TX}
    Check wireshark log for 2CC    logname=${logname1_9169_BC_attach_2TX}    scell_index=${37402}    pcell_index=${37401}
    ...    scell_gnb_index=${0}
    Adjust the HBTE attenuation value for MTK80    gnb_cell2_value=${0}
    Start DLUL traffic and check throughput for MTK80   logname=${logname1_9169_BC_attach_2TX}
    ...    scellid=4    pcellid=2    tput_dl_pcell=${expected_tput_dl_100M}    tput_dl_scell=${expected_tput_dl_20M}
    ...    tput_ul_pcell=${expected_tput_ul_100M}    tput_ul_scell=${expected_tput_ul_20M}    duration=30s
    [Teardown]    run keywords
    ...    Stop DLUL traffic and detech for MTK80
    ...    AND    Run Keyword And Ignore Error    Common Case Teardown for COAM

*** Keywords ***
Common Case TestLine Setup for gnb1
    ${release_info}    Get sagnb release
    Run Keyword And Ignore Error    Common Case TestLine Setup
    ...     ModifySCF_Beforecommission=True    golden_scf_name=MRBTS-${MRBTS1_ID}_${release_info}.xml
    ...     ParamterToModify=${PARAMETERS_TO_MODIFY_9169}
    ...     ParameterToDelete=${PARAMS_TO_delete_9169}
    ...     ListToAdd=${LIST_TO_ADD_9169}
    Modify Parameters for Cases   gnb_index=${0}    Add_Para_Online=${PARAMETERS_TO_ONLINE_ADD_9169}
    ...    Modify_Para_Online=${PARAMETERS_TO_ONLINE_MODIFY_9169}
    MCS SETUP AND SET ATT for MTK80    gnb_cell1_PA_value_MTK80=${10}
    Adjust the HBTE attenuation value for MTK80

Online close 72a pooling
    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${PARAMETERS_TO_UPDATE_pooling_72a}
    Sleep    180s
