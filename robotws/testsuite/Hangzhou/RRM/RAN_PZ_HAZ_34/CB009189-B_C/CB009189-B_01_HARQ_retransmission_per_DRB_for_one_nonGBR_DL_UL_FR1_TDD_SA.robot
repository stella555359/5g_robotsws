# *** Settings ***
# 
# Documentation
# ...   author: y6lu
# ...   contact: lu.yu@nokia-sbell.com
# ...   squad group: MMW_SG3
# ...   Feature CB009189-B in 5G23R1 program
# 
# Force Tags    CRT_TRUNK    CRT_23R1
# ...   PY36
# 
# Suite Setup    robot_common_operations.Common Suite Setup
# #Suite Teardown    robot_common_operations.Common Suite Teardown
# Suite Teardown     Run keywords    robot_common_operations.Common Suite Teardown    AND    Suite Teardown with SCF
# Test Timeout    60 min
# 
# Resource    Resources/CB009189_keyword.robot
# 
# *** Variables ***
# ${UE_TYPE}    samsung
# ###5QI 7 -- NRDRB12 -- NRDRB_MAC-2 -- NRDRB_PDCP-2 -- NRDRB_RLC_UM-5
# ${cell_id}    1
# ${alias}    gnb_902
# *** Test Cases ***
# [1]CB009189-B_01_HARQ_retransmission_per_DRB_for_one_nonGBR_DL_UL_FR1_TDD_SA
#     [Documentation]    *****************
#     ...    This user scenario describes the number of H-ARQ repetitions can be configured per DRB profile for DL. For DL,
#     ...    the highest HARQ retransmission number among the DRBs multiplexed in thi MAC TB; for UL, it's related to buffer
#     ...    status of LCGs, the highest number of LCGs with non-zero BSR or highest HARQ retransmission number of all DRBs
#     ...    when there is no valid BSR of LCGs.
#     ...    *******************
#     [Tags]
#     [Setup]    Precondition
#     [Teardown]    Teardown
#     Step1: Configure MaxHarqNum Of 5QI
#     Step2: Make UE Attach And Start Traffic
#     Step3: Check Counters
#     Step4: Modify MaxHarqNum Online
#     Step5: Collect TTI Trace And Stop Call
#     Step6: Check MaxHarqNum
# 
# 
# *** Keywords ***
# Step1: Configure MaxHarqNum Of 5QI
#     #wait until keyword succeeds     2min    1s
#     #...      admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
#     #...      username=Nemuadmin
#     #...      password=nemuuser
#     #...      name=COAM
#     run keyword and ignore error    admin_cli.perform_parameter_recommissioning    dist_name=MRBTS-${btsid}/NRBTS-${btsid}/NRDRB_MAC-2
#     ...    parameter=maxUlHarqTxDrb    operation=update    value=4    connection=COAM
#     run keyword and ignore error    admin_cli.perform_parameter_recommissioning    dist_name=MRBTS-${btsid}/NRBTS-${btsid}/NRDRB_MAC-2
#     ...    parameter=maxDlHarqTxDrb    operation=update    value=3    connection=COAM
#    	#[Teardown]     run keyword and ignore error      admin_cli.teardown    connection=COAM
# 
# Step2: Make UE Attach And Start Traffic
#     L3 call setup    ue_index=${0}    UE_TYPE=${UE_TYPE}    ul_throughput=130M    dl_throughput=400M    reset_sol=ue_reboot
# 	...    data_transfer_direction=both
# 
# Step3: Check Counters
#     ${RELEASE}=   Get program version
#     run keyword if    '${RELEASE}'=='24R2'    Check Counters for 24R2 or newer
#     ...    ELSE    Check Counters for 24R1 or older
# 
# Check Counters for 24R1 or older
# 	${counter_list}    Create Dictionary    #M55300C12002=BTS/CELLS/NRCELL-${cell_id}/NDLHQ
#     ...    M55300C12003=BTS/CELLS/NRCELL-${cell_id}/NDLHQ
#     #...    M55300C12004=BTS/CELLS/NRCELL-${cell_id}/NDLHQ
#     ...    M55300C12005=BTS/CELLS/NRCELL-${cell_id}/NDLHQ
#     #...    M55302C12005=BTS/CELLS/NRCELL-${cell_id}/NULHQ
#     #...    M55302C15001=BTS/CELLS/NRCELL-${cell_id}/NULHQ
#     ...    M55302C15002=BTS/CELLS/NRCELL-${cell_id}/NULHQ
#     #...    M55302C15003=BTS/CELLS/NRCELL-${cell_id}/NULHQ
#     ...    M55302C15004=BTS/CELLS/NRCELL-${cell_id}/NULHQ
#     Check Counters    counter_list=${counter_list}
# 
# Check Counters for 24R2 or newer
# 	${counter_list}    Create Dictionary    #M55300C12002=BTS/CELLS/NRCELL-${cell_id}/NDLHQ
#     ...    M55300C12003=BTS/MRBTS-10459/NRBTS-10459/NRCELL-${cell_id}/NDLHQ
#     ...    M55300C12005=BTS/MRBTS-10459/NRBTS-10459/NRCELL-${cell_id}/NDLHQ
#     ...    M55302C15002=BTS/MRBTS-10459/NRBTS-10459/NRCELL-${cell_id}/NULHQ
#     ...    M55302C15004=BTS/MRBTS-10459/NRBTS-10459/NRCELL-${cell_id}/NULHQ
#     Check Counters    counter_list=${counter_list}
# 
# Step4: Modify MaxHarqNum Online
#    log to console    Step4 Modify MaxHarqNum Online
#     #wait until keyword succeeds     2min    1s
#     #...      admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
#     #...      username=Nemuadmin
#     #...      password=nemuuser
#     #...      name=COAM
#     admin_cli.perform_parameter_recommissioning    dist_name=MRBTS-${btsid}/NRBTS-${btsid}/NRDRB_MAC-2
#     ...    parameter=maxDlHarqTxDrb    operation=update    value=6    connection=COAM
#  	#[Teardown]     run keyword and ignore error      admin_cli.teardown    connection=COAM
# 
# Step5: Collect TTI Trace And Stop Call
#     log to console    Step5 Collect TTI Trace And Stop Call
#     log to console    connect to DCAP
#     Connect To DCAP
#     log to console    Get the log from DCAP
#     Capture Log From DCAP
#     ${result_id}    Get Dictionary Values    ${output}
#     log to console    Get the result from DCAP
#     ${downloaded_tti_file_path}    wait until keyword succeeds    20 times    1min
#     ...    DCAP.get_results    result_id=${result_id}[0]    target_dir=${TEST_LOG_DIRECTORY}
#     log to console    stop UE call
#     L3 call stop    ue_index=${0}    UE_TYPE=${UE_TYPE}
#     log to console     Extract files
#     Extract Specific File From DCAP Log    original_file_path=${downloaded_tti_file_path}
#     Decode Log File And Convet File Format
# 
# Step6: Check MaxHarqNum
#     log to console    Step6 Check MaxHarqNum
#     Check MaxHarqNum    num_MO=2
#     Check MaxHarqNum    tti_dire=dl    num_MO=2    equal=false
# 
