# *** Settings ***
# Resource    ./../Resources/CB007459_keywords.robot
# Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/lib/NIDD_modify_merge_scf.py
# Variables   testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB005887/TestData/CB005887_SCF_modify.py
# 
# Documentation    Suite description
# ...   author: Wang Yixiang
# ...   contact: yixiang.x.wang@nokia-sbell.com
# ...   squad group: MMW_SG1
# ...   Feature CB007459
# 
# Force Tags    5G_RRM
# ...    PY36
# Suite Setup     CB007459 suite setup    prepare_ue=${True}
# ...     scf_modify_parameters=${MODIFY_SCF_DEAFULT}
# Suite Teardown    run keyword and ignore error    Common suite recovery
# 
# 
# *** Test Cases ***
# [1]CB007459-A-7_Proactive_UL_scheduling_for_a_selected_UE_performing_ping_request
#     [Tags]    CRT_22R1    CIT_22R3    CIT_22R4    CDRT_22R3
#     [Documentation]    Author: Wang Yixiang
#     ...    This Test Case shall validate the response time for a selected UE performing ping requests.
#     ...    The 5G-UE shall be periodically given opportunities to report a ping request to the 5G-NB and
#     ...    receive the response in a timely manner.
#     ...    Specific UEs to which specific setting applies are identified based on information received from
#     ...    MeNB over X2 during SgNB Addition/Modification procedure:
#     ...    PLMN ID, SPID. If the received couple (PLMN ID, SPID) matches with the configured R&D parameters
#     ...    rdSktPlmnId and rdSktSpId then the UE is identified as a specific UE and obtains parameters equal to
#     ...    R&D ones from gNB (see Enabling R&D Parameters for CB007459 ).
#     [Setup]    Common case setup
#     Make SgNBAddition on specific cell    gnb_ps_cell_index=${1}
#     Start X2 log capture from gNB
#     Retry commercial ue attach if failed    ue_type=${UE_TYPE}     prepare_ue_needed=${False}
#     Connect to Common Unit Master    alias=ASIK Master
#     ${x2_log_path}     Stop X2 log capture from gNB
#     Check specific UE configuration take effect    tcpdump_log=${x2_log_path}
#     run keyword and ignore error    Perform UL ping and check latency with retry
#     [Teardown]    run keyword and ignore error    CB007459 case teardown    detach_ue=${True}
# 
