# *** Settings ***
# Force Tags    PY36
# Resource    ../5GC001911-CA/resource/5GC001911-CA_keywords.robot
# Resource    ../5GC000721/Resource/5GC000721_keyword.robot
# Resource    ../FGCR-7660/Resources/FGCR-7660_keywords.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Documentation
# ...   author: zheyuan chen
# ...   contact: zheyuan.chen@nokia-sbell.com
# ...   squad group: MMW_SG4
# 
# 
# Suite Setup     Run keywords    Suite preparation    AND    robot_common_operations.Common Suite Setup
# Suite Teardown  Run keywords    suite teardown for 721    AND    robot_common_operations.Common Suite Teardown
# 
# 
# *** Variable ***
# ${SCF_SBTS00_default}    ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/SCF_SBTS00_721.xml
# ${SCF_BRANCH_default}    ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/SCF_SBTS22R1_721.xml
# @{all_cell_info}    ${0}    ${1}
# ${IPERF_portlist}    ${tl.appserver.iperf_details.ports}
# ${UE_TYPE}    ${tl.ues[0].capabilities[1]}
# ${4G_IP}                  ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
# ${4G_MR_BTS}              ${tl.enbs[0].global_bts_id}
# ${4G_NR_BTS}              ${tl.enbs[0].instance_id}
# ${gNB_username}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${gNB_password}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
# 
# *** Test Cases ***
# [1]CB007403-E_5GC000721_TC02_Cell2 selected as pScell in the SgNB addition when cell1 is exceed ccLoadThreshold
#     [Documentation]
#     ...    This user scenario describes successful SgNB addition procedure with radio admission control (5GC000480)
#     ...    and PSCell load balancing(5GC000721).
#     [Tags]     CRT_22R1   CRT_TRUNK    CRT_22R2    CRT_22R3
#     [Timeout]    1 hour
#     [Setup]    case setup for 721
# #    UE1 Attach check
#     Start X2 log capture from eNB    log_name=X2_tcpdump
#     Single UE Attach    ue_type=${ue_type}    ue_index=${1}
#     UE Start Traffic And Check Throughput    ue_index=${1}
#     ${X2tcpdump_log}    Stop X2 log capture from eNB    log_name=X2_tcpdump
#     SISO_Pre.Close iperf progress
#     Run keyword and continue on failure    check physCellId    x2ap_log=${X2tcpdump_log}      physCellId_exp=229
# 
#     #UE2 attach and check
#     Start X2 log capture from eNB    log_name=X2_tcpdump_UE1
#     Single UE Attach    ue_type=${ue_type}    ue_index=${0}
#     UE Start Traffic And Check Throughput    ue_index=${0}
#     ${X2tcpdump_log}    Stop X2 log capture from eNB    log_name=X2_tcpdump_UE1
#     Run keyword and continue on failure    check physCellId    x2ap_log=${X2tcpdump_log}      physCellId_exp=230
#     SISO_Pre.Close iperf progress
#     [Teardown]   run keyword and ignore error     case teardown for 721
# 
# *** Keywords ***
# get correct scf path
#     Connect to gnb coam via ssl    bts_host=${tl.gnbs[1].dus[0].airscale.common_units[0].lmp_connection.addr}
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
#     Connect to gnb coam via ssl    bts_host=${tl.gnbs[1].dus[0].airscale.common_units[0].lmp_connection.addr}
#     COAM Commission with scf file    scf_file_path=${default_scf}    connection=GNB_OAM
#     [Teardown]    Run keyword and ignore error    coam.teardown      connection=GNB_OAM
# 
# Suite preparation
#     [Timeout]    20 min
#     Set variables for UTE cloud
#     get correct scf path
#     Commission Default SCF    default_scf=${default_scf}
#     Check BTS Should Be Normal
#     change LTE configuration
# #    ${UE_TYPE}    translate_power_ue_type_from_testline
# #    Set suite variable    ${UE_TYPE}
# 
# case setup for 721
#     robot_common_operations.Common case Setup   
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
#     power_ue.UE Detach    ue_type=${ue_type}     ue_index=${0}
#     Common case teardown
#     CI_interface.Common Case Teardown
#     robot_common_operations.Common Case Teardown
#     
# Check BTS Should Be Normal
#     Log To Console  Check BTS Should Be Normal
#     Connect to gnb coam via ssl    bts_host=${tl.gnbs[1].dus[0].airscale.common_units[0].lmp_connection.addr}     connection=default
#     Wait Until BTS Should Be Normal
#     [Teardown]   coam.Teardown    connection=default
# 
# Wait Until BTS Should Be Normal
#     [Arguments]   ${retry}=1200s    ${retry_interval}=10s
#     [Documentation]   Wait Until CBTS Status Should Be Normal, if CBTS status is abnormal during retry time,
#     Wait Until Keyword Succeeds   ${retry}     ${retry_interval}    Verify all cells should be onair    connection=default
# 
# Gnb Cell Should Be Onair
#     [Arguments]    ${alias}=default   ${cell_type }=nr
#     [Documentation]  Gnb Cell Should Be Onair, check method is via REST
#     ${status}      coam.Get_Bts_Statuses   connection=${alias}
#     ${operationalState}    Get From Dictionary    ${status}    operationalState
#     should be equal as strings    ${operationalState}    Enabled    ignore_case=${True}
#     ${blockingState}   Get From Dictionary    ${status}    blockingState
#     should be equal as strings    ${blockingState}    Unblocked    ignore_case=${True}
#     ${proceduralState}   Get From Dictionary    ${status}   proceduralState
#     should be equal as strings    ${proceduralState}    OnAir    ignore_case=${True}
#     #cell info
#     ${cell_status}     coam.Get_Cells_Info   cell_type=${cell_type}    connection=${alias}
#     FOR    ${item}    IN    @{all_cell_info}
#         ${Status}    Get From Dictionary    ${cell_status[${item}]}    status
#         ${tmp}   Get From Dictionary    ${status}    operationalState
#         should be equal as strings    ${tmp}    Enabled    ignore_case=${True}
#         ${tmp}   Get From Dictionary    ${status}  administrativeState
#         should be equal as strings    ${tmp}    Unlocked    ignore_case=${True}
#         ${tmp}   Get From Dictionary    ${status}  blockingState
#         should be equal as strings    ${tmp}    Unblocked    ignore_case=${True}
#         ${tmp}   Get From Dictionary    ${status}  usageState
#         should be equal as strings    ${tmp}    Active    ignore_case=${True}
#     END
# 
# Single UE Attach
#     [Arguments]    ${ue_type}=${ue_type}    ${ue_index}=${1}
#     Log To Console    Single UE Attach
#     power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
#     Log To Console    UE Attach
#     ${5Grach_ed_0}    power_ue.UE Attach    ue_type=${ue_type}    attach_mode=5G_NSA    ue_index=${ue_index}
#     Log To Console    Verify attach
#     Wait Until Keyword Succeeds    8min    20s    power_ue.Verify attach    ue_type=${ue_type}    ue_index=${ue_index}
#     ...    5Grach_ed=${5Grach_ed_0}    4G_check=False
# 
# UE Start Traffic And Check Throughput
#     [Arguments]    ${ue_index}=${0}    ${port}=${0}
#     Log To Console    UE Start Traffic And Check Throughput
#     power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=100MKbits/sec    ue_index=${ue_index}
#     ...    duration=600    ue_mode=NSA    iperf_port=${IPERF_portlist}[${port}]    iperf_type=via_command    process_num=${1}
#     power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=400MKbits/sec    ue_index=${ue_index}
#     ...    duration=600    ue_mode=NSA    iperf_port=${IPERF_portlist}[${port}]    iperf_type=via_command    process_num=${1}
#     sleep    30s
#     Log To Console    Check Throughput
#     run keyword and continue on failure    power_ue.Check throughput    ue_type=${ue_type}    direction=ul
#     ...    throughput=1  ue_index=${ue_index}
#     run keyword and continue on failure    power_ue.Check throughput    ue_type=${ue_type}    direction=dl
#     ...    throughput=1    ue_index=${ue_index}
# 
# change LTE configuration
#     [Arguments]      ${value}=${8}
#     Connect to gnb coam via ssl    bts_host=${4G_IP}    username=${gNB_username}    password=${gNB_password}    connection=4G_admin
#     coam.Perform Parameter Recommissioning
#     ...    dist_name=MRBTS-${4G_MR_BTS}/LNBTS-${4G_NR_BTS}/LNCEL-1
#     ...    parameter=defaultLnRelGnbCellId
#     ...    value=${value}
#     ...    operation=update
#     ...    connection=4G_admin
#     ...    should_activate=${True}
#     COAM Teardown gnb connections     connection=4G_admin