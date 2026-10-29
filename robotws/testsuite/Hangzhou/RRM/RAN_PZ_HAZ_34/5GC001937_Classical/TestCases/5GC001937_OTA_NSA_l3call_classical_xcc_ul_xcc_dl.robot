# *** Settings ***
# Resource          ../Resources/5GC001937_classical_keywords.robot
# 
# Documentation    Suite description
# ...   author: Ren Biyao
# ...   contact: biyao.ren@nokia-sbell.com
# ...   squad group: MMW_SG1
# ...   if need to run on ute cloud, need add tag in suite: CLOUD_5G_CLASSICAL_ASIBL_ABILB1_AEWB_ENB    STATE_SW_UPLOADED
# ...   add tags in case: master_classicalbts_all   CIT
# 
# Force Tags    5G_RAN_TDD      5G_RAN
# ...    PY36
# Suite Setup   5GC001937_classical_keywords.Pre Condition
# Suite Teardown  Run keyword and ignore error    Post conditions
# 
# *** Test Cases ***
# #[1]5GC001937_OTA_8111_NSA_L3_Call_UL_UDP_Classical_8CC_1DRB_AEWB_Contiguous
# #    [Timeout]    4h
# #    [Documentation]    Author: Ren Biyao
# #    ...    Description: The purpose of this test is to verify basic configuration of RU RAU OAM configures RU,
# #    ...                  configuration not related to synchronization, transport and U-plane.
# #    ...                  TCP tput is required.
# #    [Tags]     CIT_20B    CRT_21B    CRT_22R1
# #    [Setup]    Case preparation    scf_template_path=${tl_scf_process_path}    act_xcc_cell_number=${8}
# #    Step 1: ue attach
# #    Step 2: start traffic
# #    ...    act_dl_tput=${0}
# #    ...    act_ul_tput=${ACT_UL_TPUT}
# #    ...    protocol=udp
# #    ...    data_transfer_direction=ul
# #    ${tput_log}    Step 3: collect aasyslog
# #    Step 4: stop traffic   protocol=udp
# #    Step 5: Check tput
# #    ...    log=${tput_log}
# #    ...    exp_ul_tput=${UL_EXPECT_TPUT_UDP}
# #    ...    exp_dl_tput=${0}
# #    ...    data_transfer_direction=ul
# #    ...    protocol=udp
# #    [Teardown]    Run keyword and ignore error    5GC001937_classical_keywords.Case Teardown
# 
# #[1]5GC001937_OTA_8111_NSA_L3_Call_DL_UDP_Classical_8CC_1DRB_AEWB_Contiguous
# #    [Tags]     CIT_20B    CRT_21B    CRT_22R1
# #    [Setup]    Case preparation    scf_template_path=${tl_scf_process_path}    act_xcc_cell_number=${8}
# #    ${8CC_ACT_DL_TPUT_VAR}    set variable if     ${BTS_ID}==245     ${8CC_ACT_DL_2_THREAD_TPUT}
# #    ...    ${BTS_ID}==256    ${8CC_ACT_DL_2_THREAD_TPUT}
# #    Step 1: ue attach
# #    Step 2: start traffic
# #    ...    act_dl_tput=${8CC_ACT_DL_TPUT_VAR}
# #    ...    act_ul_tput=${0}
# #    ...    protocol=udp
# #    ...    data_transfer_direction=dl
# #    ${tput_log}    Step 3: collect aasyslog
# #    Step 4: stop traffic   protocol=udp
# #    Step 5: Check tput
# #    ...    log=${tput_log}
# #    ...    exp_ul_tput=${0}
# #    ...    exp_dl_tput=${8CC_8DL_2UL_DL_EXPECT_UDP}
# #    ...    data_transfer_direction=dl
# #    ...    protocol=udp
# #    [Teardown]    Run keyword and ignore error    5GC001937_classical_keywords.Case Teardown
# 
# [1]5GC001937_OTA_8113_NSA_L3_Call_ULDL_TCP_Classical_8CC_1DRB_AEWB_Contiguous
#     [Documentation]    Author: Ren Biyao
#     ...    Description: The purpose of this test is to verify basic configuration of RU RAU OAM configures RU,
#     ...                  configuration not related to synchronization, transport and U-plane.
#     ...                  TCP tput is required.
#     ...                  both ul and dl : 5min
#     [Tags]     CIT_20B    CIT_21B    CIT_22R1    CIT_22R2    CDRT_22R1    CIT_22R3    CDRT_22R2    CDRT_22R3    CRT_22R4    CRT_23R2
#     [Setup]    Case preparation    scf_template_path=${tl_scf_process_path}    act_xcc_cell_number=${8}
#     Step 1: ue attach
#     Step 2: start traffic
#     ...    act_dl_tput=${8CC_ACT_DL_TPUT}
#     ...    act_ul_tput=${ACT_UL_TPUT}
#     ...    protocol=tcp
#     ...    data_transfer_direction=both
#     ${tput_log}    Step 3: collect aasyslog
#     Step 4: stop traffic   protocol=tcp
#     Step 5: Check tput
#     ...    log=${tput_log}
#     ...    exp_ul_tput=${UL_EXPECT_TPUT_TCP}
#     ...    exp_dl_tput=${8CC_8DL_2UL_DL_EXPECT_TCP}
#     ...    data_transfer_direction=both
#     ...    protocol=tcp
#     [Teardown]    Run keyword and ignore error    5GC001937_classical_keywords.Case Teardown
# 
# [1]5GC001937_OTA_8113_NSA_L3_Call_UL_TCP_Classical_8CC_1DRB_AEWB_Contiguous
#     [Documentation]    Author: Ren Biyao
#     ...    Description: The purpose of this test is to verify basic configuration of RU RAU OAM configures RU,
#     ...                  configuration not related to synchronization, transport and U-plane.
#     ...                  TCP tput is required.
#     ...                  both ul and dl : 5min
#     [Tags]     CIT_20B    CIT_21B    CIT_22R1    CIT_22R2    CDRT_22R1    CIT_22R3    CDRT_22R2    CDRT_22R3    CRT_22R4    CRT_23R2
#     [Setup]    Case preparation    scf_template_path=${tl_scf_process_path}    act_xcc_cell_number=${8}
#     Step 1: ue attach
#     Step 2: start traffic
#     ...    act_dl_tput=${0}
#     ...    act_ul_tput=${ACT_UL_TPUT}
#     ...    protocol=tcp
#     ...    data_transfer_direction=ul
#     ${tput_log}    Step 3: collect aasyslog
#     Step 4: stop traffic   protocol=tcp
#     Step 5: Check tput
#     ...    log=${tput_log}
#     ...    exp_ul_tput=${UL_EXPECT_TPUT_TCP}
#     ...    exp_dl_tput=${0}
#     ...    data_transfer_direction=ul
#     ...    protocol=tcp
#     [Teardown]    Run keyword and ignore error    5GC001937_classical_keywords.Case Teardown
# 
# [1]5GC001937_OTA_8113_NSA_L3_Call_DL_TCP_Classical_8CC_1DRB_AEWB_Contiguous
#     [Tags]     CIT_20B    CIT_21B    CIT_22R1    CIT_22R2    CDRT_22R1    CIT_22R3    CDRT_22R2    CDRT_22R3    CRT_22R4    CRT_23R2
#     [Setup]    Case preparation    scf_template_path=${tl_scf_process_path}    act_xcc_cell_number=${8}
#     Step 1: ue attach
#     Step 2: start traffic
#     ...    act_dl_tput=${8CC_ACT_DL_TPUT}
#     ...    act_ul_tput=${0}
#     ...    protocol=tcp
#     ...    data_transfer_direction=dl
#     ${tput_log}    Step 3: collect aasyslog
#     Step 4: stop traffic   protocol=tcp
#     Step 5: Check tput
#     ...    log=${tput_log}
#     ...    exp_ul_tput=${0}
#     ...    exp_dl_tput=${8CC_8DL_2UL_DL_EXPECT_TCP}
#     ...    data_transfer_direction=dl
#     ...    protocol=tcp
#     [Teardown]    Run keyword and ignore error    5GC001937_classical_keywords.Case Teardown
# 
# [1]5GC001937_OTA_8111_NSA_L3_Call_ULDL_UDP_Classical_8CC_1DRB_AEWB_Contiguous
#     [Timeout]    4h
#     [Documentation]    Author: Ren Biyao
#     ...    Description: The purpose of this test is to verify basic configuration of RU RAU OAM configures RU,
#     ...                  configuration not related to synchronization, transport and U-plane.
#     ...                  TCP tput is required.
#     [Tags]     CIT_20B    CIT_21B    CIT_22R1    CIT_22R2    CDRT_22R1    CIT_22R3    CDRT_22R2    CDRT_22R3    CRT_22R4    CRT_23R2
#     [Setup]    run keywords   TL256 4UL check   AND   Case preparation    scf_template_path=${tl_scf_process_path}    act_xcc_cell_number=${8}
#     ${8CC_ACT_DL_TPUT_VAR}    set variable if     ${BTS_ID}==245     ${8CC_ACT_DL_2_THREAD_TPUT}
#     ...    ${BTS_ID}==256    ${8CC_ACT_DL_2_THREAD_TPUT}
#     ${ACT_UL_TPUT}    set variable if     ${BTS_ID}==245     ${ACT_UL_TPUT}
#     ...    ${BTS_ID}==256    ${ACT_UL_TPUT_256_UDP}
#     ${UL_EXPECT_TPUT_UDP}    set variable if     ${BTS_ID}==245     ${UL_EXPECT_TPUT}
#     ...    ${BTS_ID}==256    ${UL_EXPECT_TPUT_256_UDP}
#     Step 1: ue attach
#     Step 2: start traffic
#     ...    act_dl_tput=${8CC_ACT_DL_TPUT_VAR}
#     ...    act_ul_tput=${ACT_UL_TPUT}
#     ...    protocol=udp
#     ${tput_log}    Step 3: collect aasyslog
#     Step 4: stop traffic   protocol=udp
#     Step 5: Check tput
#     ...    log=${tput_log}
#     ...    exp_ul_tput=${UL_EXPECT_TPUT_UDP}
#     ...    exp_dl_tput=${8CC_8DL_2UL_DL_EXPECT_UDP}
#     ...    protocol=udp
#     [Teardown]    Run keyword and ignore error    5GC001937_classical_keywords.Case Teardown
# 
# #[1]5GC001937_OTA_4111_NSA_L3_Call_ULDL_UDP_Classical_4CC_1DRB_AEWB_Contiguous
# #    [Tags]    CIT_20B    CRT_21B    CRT_22R1
# #    [Documentation]    Author: Ren Biyao
# #    ...    Description: The purpose of this test is to verify basic configuration of RU RAU OAM configures RU,
# #    ...                  configuration not related to synchronization, transport and U-plane.
# #    ...                  UDP tput is required.
# #    [Setup]    Case preparation    scf_template_path=${GOLDEN_FULL_SCF_4CC}
# #    ...    act_xcc_cell_number=${4}    scf_modify=${MODIFY_SCF_FOR_4CC_CELL_PARAMETERS}
# #    Step 1: ue attach
# #    Step 2: start traffic
# #    ...    act_dl_tput=${4CC_ACT_DL_TPUT}
# #    ...    act_ul_tput=${ACT_UL_TPUT}
# #    ...    protocol=udp
# #    ${tput_log}    Step 3: collect aasyslog
# #    Step 4: stop traffic   protocol=udp
# #    Step 5: Check tput
# #    ...    log=${tput_log}
# #    ...    exp_ul_tput=${UL_EXPECT_TPUT_UDP}
# #    ...    exp_dl_tput=${4CC_4DL_2UL_DL_EXPECT_UDP}
# #    [Teardown]    Run keyword and ignore error    5GC001937_classical_keywords.Case Teardown
# 
# #[1]5GC001937_OTA_4111_NSA_L3_Call_UL_UDP_Classical_4CC_1DRB_AEWB_Contiguous
# #    [Tags]    CIT_20B
# #    [Documentation]    Author: Ren Biyao
# #    ...    Description: The purpose of this test is to verify basic configuration of RU RAU OAM configures RU,
# #    ...                  configuration not related to synchronization, transport and U-plane.
# #    ...                  UDP tput is required.
# #    [Setup]    Case preparation    scf_template_path=${GOLDEN_FULL_SCF_4CC}
# #    ...    act_xcc_cell_number=${4}    scf_modify=${MODIFY_SCF_FOR_4CC_CELL_PARAMETERS}
# #    Step 1: ue attach
# #    Step 2: start traffic
# #    ...    act_dl_tput=${0}
# #    ...    act_ul_tput=${ACT_UL_TPUT}
# #    ...    protocol=udp
# #    ...    data_transfer_direction=ul
# #    ${tput_log}    Step 3: collect aasyslog
# #    Step 4: stop traffic   protocol=udp
# #    Step 5: Check tput
# #    ...    log=${tput_log}
# #    ...    exp_ul_tput=${UL_EXPECT_TPUT_UDP}
# #    ...    exp_dl_tput=${0}
# #    ...    data_transfer_direction=ul
# #    ...    protocol=udp
# #    [Teardown]    Run keyword and ignore error    5GC001937_classical_keywords.Case Teardown
# 
# #[1]5GC001937_OTA_4111_NSA_L3_Call_DL_UDP_Classical_4CC_1DRB_AEWB_Contiguous
# #    [Tags]    CIT_20B
# #    [Documentation]    Author: Ren Biyao
# #    ...    Description: The purpose of this test is to verify basic configuration of RU RAU OAM configures RU,
# #    ...                  configuration not related to synchronization, transport and U-plane.
# #    ...                  UDP tput is required.
# #    [Setup]    Case preparation    scf_template_path=${GOLDEN_FULL_SCF_4CC}
# #    ...    act_xcc_cell_number=${4}    scf_modify=${MODIFY_SCF_FOR_4CC_CELL_PARAMETERS}
# #    Step 1: ue attach
# #    Step 2: start traffic
# #    ...    act_dl_tput=${4CC_ACT_DL_TPUT}
# #    ...    act_ul_tput=${0}
# #    ...    protocol=udp
# #    ...    data_transfer_direction=dl
# #    ${tput_log}    Step 3: collect aasyslog
# #    Step 4: stop traffic   protocol=udp
# #    Step 5: Check tput
# #    ...    log=${tput_log}
# #    ...    exp_ul_tput=${0}
# #    ...    exp_dl_tput=${4CC_4DL_2UL_DL_EXPECT_UDP}
# #    ...    data_transfer_direction=dl
# #    [Teardown]    Run keyword and ignore error    5GC001937_classical_keywords.Case Teardown
# 
# #[1]5GC001937_OTA_4113_NSA_L3_Call_ULDL_TCP_Classical_4CC_1DRB_AEWB_Contiguous
# #    [Tags]    CIT_20B    CRT_21B    CRT_22R1
# #    [Documentation]    Author: Ren Biyao
# #    ...    Description: The purpose of this test is to verify basic configuration of RU RAU OAM configures RU,
# #    ...                  configuration not related to synchronization, transport and U-plane.
# #    ...                  TCP tput is required.
# #    ...                  both ul and dl : 5min
# #    [Setup]    Case preparation    scf_template_path=${GOLDEN_FULL_SCF_4CC}
# #    ...    act_xcc_cell_number=${4}    scf_modify=${MODIFY_SCF_FOR_4CC_CELL_PARAMETERS}
# #    Step 1: ue attach
# #    Step 2: start traffic
# #    ...    act_dl_tput=${4CC_ACT_DL_TPUT}
# #    ...    act_ul_tput=${ACT_UL_TPUT}
# #    ...    protocol=tcp
# #    ...    data_transfer_direction=both
# #    ${tput_log}    Step 3: collect aasyslog
# #    Step 4: stop traffic   protocol=tcp
# #    Step 5: Check tput
# #    ...    log=${tput_log}
# #    ...    exp_ul_tput=${UL_EXPECT_TPUT_TCP}
# #    ...    exp_dl_tput=${4CC_4DL_2UL_DL_EXPECT_TCP}
# #    ...    data_transfer_direction=both
# #    ...    protocol=tcp
# #    [Teardown]    Run keyword and ignore error    5GC001937_classical_keywords.Case Teardown    protocol=tcp
# 
# #[1]5GC001937_OTA_4114_NSA_L3_Call_UL_TCP_Classical_4CC_1DRB_AEWB_Contiguous
# #    [Tags]    CIT_20B    CRT_21B    CRT_22R1
# #    [Documentation]    Author: Ren Biyao
# #    ...    Description: The purpose of this test is to verify basic configuration of RU RAU OAM configures RU,
# #    ...                  configuration not related to synchronization, transport and U-plane.
# #    ...                  TCP tput is required.
# #    ...                  only ul : 5min
# #    [Setup]    Case preparation    scf_template_path=${GOLDEN_FULL_SCF_4CC}    act_xcc_cell_number=${4}
# #    Step 1: ue attach
# #    Step 2: start traffic
# #    ...    act_dl_tput=${0}
# #    ...    act_ul_tput=${ACT_UL_TPUT}
# #    ...    protocol=tcp
# #    ...    data_transfer_direction=ul
# #    ${tput_log}    Step 3: collect aasyslog
# #    Step 4: stop traffic   protocol=tcp
# #    Step 5: Check tput
# #    ...    log=${tput_log}
# #    ...    exp_ul_tput=${UL_EXPECT_TPUT_TCP}
# #    ...    exp_dl_tput=${0}
# #    ...    data_transfer_direction=ul
# #    ...    protocol=tcp
# #    [Teardown]    Run keyword and ignore error    5GC001937_classical_keywords.Case Teardown    protocol=tcp
# 
# #[1]5GC001937_OTA_4115_NSA_L3_Call_DL_TCP_Classical_4CC_1DRB_AEWB_Contiguous
# #    [Tags]    CIT_20B    CRT_21B    CRT_22R1
# #    [Documentation]    Author: Ren Biyao
# #    ...    Description: The purpose of this test is to verify basic configuration of RU RAU OAM configures RU,
# #    ...                  configuration not related to synchronization, transport and U-plane.
# #    ...                  TCP tput is required.
# #    ...                  only dl : 5min
# #    [Setup]    Case preparation    scf_template_path=${GOLDEN_FULL_SCF_4CC}
# #    ...    act_xcc_cell_number=${4}    scf_modify=${MODIFY_SCF_FOR_4CC_CELL_PARAMETERS}
# #    Step 1: ue attach
# #    Step 2: start traffic
# #    ...    act_dl_tput=${4CC_ACT_DL_TPUT}
# #    ...    act_ul_tput=${0}
# #    ...    protocol=tcp
# #    ...    data_transfer_direction=dl
# #    ${tput_log}    Step 3: collect aasyslog
# #    Step 4: stop traffic   protocol=tcp
# #    Step 5: Check tput
# #    ...    log=${tput_log}
# #    ...    exp_ul_tput=${0}
# #    ...    exp_dl_tput=${4CC_4DL_2UL_DL_EXPECT_TCP}
# #    ...    data_transfer_direction=dl
# #    ...    protocol=tcp
# #    [Teardown]    Run keyword and ignore error    5GC001937_classical_keywords.Case Teardown    protocol=tcp
# 
# #[1]5GC001937_OTA_4019_NSA_L3_Call_UDP_TCP_Classical_4CCDL_1CCUL_1DRB_AEWB_Contiguous
# #    [Documentation]    Author: Ren Biyao
# #    ...    Description: The purpose of this test is to verify basic configuration of RU RAU OAM configures RU,
# #    ...                  configuration not related to synchronization, transport and U-plane.
# #    ...                  TCP and UDP tput is required: 5min
# #    [Tags]     CRT_20B    CRT_21B
# #    [Setup]    Case preparation    scf_template_path=${GOLDEN_FULL_SCF_4CC}
# #    ...    act_xcc_cell_number=${4}    scf_modify=${MODIFY_SCF_FOR_4CC_CELL_PARAMETERS}
# #    Step 1: ue attach
# #    Step 2: start traffic
# #    ...    act_dl_tput=${4CC_ACT_DL_TPUT}
# #    ...    act_ul_tput=${ACT_UL_TPUT}
# #    ...    protocol=udp
# #    ${tput_log}    Step 3: collect aasyslog
# #    Step 4: stop traffic   protocol=udp
# #    Step 5: Check tput
# #    ...    log=${tput_log}
# #    ...    exp_ul_tput=${UL_EXPECT_TPUT_UDP}
# #    ...    exp_dl_tput=${4CC_4DL_2UL_DL_EXPECT_UDP}
# #    [Teardown]    Run keyword and ignore error    5GC001937_classical_keywords.Case Teardown
