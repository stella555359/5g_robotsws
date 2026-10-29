# *** Settings ***
# Force Tags    PY36
# Resource    ../5GC001911-CA/resource/5GC001911-CA_keywords.robot
# Resource    ../5GC000721/Resource/5GC000721_keyword.robot
# Resource    ../FGCR-7660/Resources/FGCR-7660_keywords.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Documentation
# ...   author: zheyuan chen
# ...   contact: zheyuan.chen@nokia-sbell.com
# ...   squad group: MMW_SG4
# 
# Suite Setup    Run keywords    Suite preparation    AND    robot_common_operations.Common Suite Setup
# Suite Teardown    Run keywords    suite teardown for 721    AND    robot_common_operations.Common Suite Teardown
# 
# *** Variable ***
# ${SCF_SBTS00_default}    ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/SCF_SBTS00_721.xml
# ${SCF_BRANCH_default}    ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/SCF_SBTS22R1_721.xml
# ${UE_TYPE}    ${tl.ues[0].capabilities[1]}
# 
# *** Test Cases ***
# [1]CB007608-A_5GC000721_TC02_Cell2 selected as pScell in the SgNB addition when cell1 is exceed ccLoadThreshold
#     [Documentation]
#     ...    This user scenario describes successful SgNB addition procedure with radio admission control (5GC000480)
#     ...    and PSCell load balancing(5GC000721).
#     [Tags]     CRT_22R1   CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4
#     [Timeout]    1 hour
#     [Setup]    case setup for 721
# #    UE1 Attach check
#     Start X2 log capture from eNB    log_name=X2_tcpdump
#     Retry commercial ue attach if failed    retry_time=${retry_time}    ue_type=${ue_type}    ue_index=${0}
#     Start traffic uldl    ue_index=${0}
#     Verify peak tput of each cell for 721   dl_cell=${dl_cell}    ul_cell=${ul_cell}   expected_dl_tput_max=${expected_dl_tput_max}
#     ...     expected_dl_tput_min=${expected_dl_tput_min}      expected_ul_tput=${expected_ul_tput}
#     ...     dl_num_exp=${CC_num}    ul_num_exp=${ul_num_exp}
#     ${X2tcpdump_log}    Stop X2 log capture from eNB    log_name=X2_tcpdump
#     SISO_Pre.Close iperf progress
#     Run keyword and continue on failure    check physCellId    x2ap_log=${X2tcpdump_log}      physCellId_exp=50
# #    UE2 attach and check
#     Start X2 log capture from eNB    log_name=X2_tcpdump_UE1
#     Retry commercial ue attach if failed    retry_time=${retry_time}    ue_type=${ue_type}    ue_index=${2}
#     Start traffic uldl    ue_index=${2}
#     Verify peak tput of each cell for 721   dl_cell=${dl_cell}    ul_cell=${ul_cell}   expected_dl_tput_max=${expected_dl_tput_max}
#     ...     expected_dl_tput_min=${expected_dl_tput_min}      expected_ul_tput=${expected_ul_tput}
#     ...     dl_num_exp=${CC_num}    ul_num_exp=${ul_num_exp}
#     ${X2tcpdump_log}    Stop X2 log capture from eNB    log_name=X2_tcpdump_UE1
#     Run keyword and continue on failure    check physCellId    x2ap_log=${X2tcpdump_log}      physCellId_exp=51
#     Verify peak tput of each cell for 721   dl_cell=${dl_cell}    ul_cell=${ul_cell}   expected_dl_tput_max=${expected_dl_tput_max}
#     ...     expected_dl_tput_min=${expected_dl_tput_min}      expected_ul_tput=${expected_ul_tput}
#     ...     dl_num_exp=${CC_num}    ul_num_exp=${ul_num_exp}
#     SISO_Pre.Close iperf progress
#     [Teardown]   run keyword and ignore error     case teardown for 721
# 
# *** Keywords ***
# get correct scf path
#     Connect to gnb coam via ssl    bts_host=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
#     ${version}    coam.get_sw_version    connection=GNB_OAM
#     ${version_list}    split string    ${version}    _
#     ${if_common_load}     run keyword and return status    should contain    ${version_list[2]}    9999
#     ${default_scf}    set variable if    ${if_common_load}    ${SCF_SBTS00_default}
#     ...    ${SCF_BRANCH_default}
#     set suite variable    ${default_scf}
#     [Teardown]    Run keyword and ignore error    coam.teardown      connection=GNB_OAM
# 
# Commission Default SCF
#     [Arguments]    ${default_scf}
#     Log To Console    Commission Default SCF
#     Connect to gnb coam via ssl    bts_host=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
#     COAM Commission with scf file    scf_file_path=${default_scf}    connection=GNB_OAM
#     [Teardown]    Run keyword and ignore error    coam.teardown      connection=GNB_OAM
# 
# Suite preparation
#     [Timeout]    20 min
#     Set variables for UTE cloud
#     get correct scf path
#     Commission Default SCF    default_scf=${default_scf}
#     Wait until cluster is on cell on air status    timeout=${RECOVERY_TIMEOUT}
#     wait until keyword succeeds    5 min    10 sec    Verify all cells should be onair
# #    ${rus_connect_success}    run keyword and return status  Connect to all rus with allocated IP
# #    should be equal as strings  ${rus_connect_success}    True
# #    ${UE_TYPE}    translate_power_ue_type_from_testline
# #    Set suite variable    ${UE_TYPE}
# 
# case setup for 721
#     Common case setup    is_log_required=${False}    is_btslog_required=${False}
#     coam create log directory
#     Connect to gnb coam via ssl
#     &{NR_CELL_ID_MAPPING}    get_relation_mapping_between_cell_index_and_other_ids
#     Set test variable    ${NR_CELL_ID_MAPPING}
# 
# suite teardown for 721
#     Common suite recovery    swconfig_template_path=${SWCONFIG_DEFAULT_FILE_PATH_709}
# 
# case teardown for 721
#     power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
#     power_ue.UE Detach    ue_type=${ue_type}     ue_index=${2}
#     Common case teardown
#     CI_interface.Common Case Teardown
#     
