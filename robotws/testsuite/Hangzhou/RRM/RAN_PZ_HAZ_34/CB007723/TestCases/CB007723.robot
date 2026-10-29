# *** Settings ***
# Resource          ./../Resources/CB007723_keywords.robot
# 
# 
# Documentation    Suite description
# ...   author: wang liya
# ...   contact: liya.wang@nokia-sbell.com
# ...   squad group: MMW_SG1
# ...   Feature CB007723
# 
# Force Tags    5G_RRM
# ...    PY36
# 
# #Suite Setup     Suite common setup preparation
# #...     scf_modify_parameters=${MODIFY_DEFAULT_SCF}    prepare_ue=${True}
# #...     enb_default_scf_file=${ENB_SCF_DEFAULT_FILE_PATH}
# #...     is_pdl_checking_needed=${True}
# 
# Suite Setup      Suite setup 7723
# 
# Suite Teardown    run keyword and ignore error    Common suite recovery
# 
# 
# *** Variables ***
# ${GP}    6Symbols
# ${log_name}    enb_x2_cell2
# @{GNB_PS_CELL_INDEX_LIST}    11
# 
# *** Test Cases ***
# CB007723-A-0101-PRACH_format_B4_4cc_2GPSymbols_regularCellOnly
#     [Tags]   CIT_TRUNK     CIT_22R2    CRT_22R3    CDRT_22R2    CIT_22R4
#     [Documentation]    Author: wang liya
#     ...    check prach format B4 in regular and extend cell
#     ...    immediatel without any alarm or service interruption.
#     [Setup]    Common case setup    is_log_required=${True}
#     run keyword and continue on failure    Should be true    ${PDL_VALIDATION_RESULT}!=${False}
#     ...    msg=Commissioned with error exists, pdl validation result is not in OK status.
#     Modify all B4 configuration index and L3 Call
#     [Teardown]    run keyword and ignore error    Common case teardown    is_log_required=${True}    detach_ue=${True}
# 
# CB007723-B-0110-4CC-Random_Access_by_UE_to_multiple_cells_configuration_with_mixed_GP_symbols
#     [Tags]   CIT_TRUNK     CIT_22R2    CIT_22R3    CDRT_22R2    CIT_22R4    CDRT_22R3
#     [Documentation]    Author: wang liya
#     ...    check different GP attach for B4 format
#     ...    immediatel without any alarm or service interruption.
#     [Setup]    Common case setup    is_log_required=${True}
#     Modify GP parameter via rest api and wait onair and L3call
#     Modify GP parameter via rest api and wait onair and L3call    cell_index_for_attach=${12}    GP=${GP}    log_name=${log_name}
#     [Teardown]    run keyword and ignore error    Common case teardown    is_log_required=${True}    detach_ue=${True}
# 
# CB007723-C-0105-4CC-Cells_configurations_with_mixed_range_and_different_GP_symbols
#     [Tags]   CIT_TRUNK     CIT_22R2    CIT_22R3    CDRT_22R2    CIT_22R4    CDRT_22R3
#     [Documentation]    Author: wang liya
#     ...    check different GP adn different range attach for B4 format
#     ...    immediatel without any alarm or service interruption.
#     [Setup]    Common case setup    is_log_required=${True}
#     Modify Mixed and RANGE parameter via rest api and wait onair and L3call
#     Modify Mixed and RANGE parameter via rest api and wait onair and L3call    cell_index_for_attach=${12}    log_name=${log_name}
#     [Teardown]    run keyword and ignore error    Common case teardown    is_log_required=${True}    detach_ue=${True}
# 
# 
# *** Keywords ***
# Suite setup 7723
#       set suite variable     ${PARAMS_TO_DELETE}    ${ABIO_4CC_ABIL_0CC_DEL}
#       Suite common setup preparation
#         ...  scf_modify_parameters=${MODIFY_DEFAULT_SCF}    prepare_ue=${True}
#         ...  enb_default_scf_file=${ENB_SCF_DEFAULT_FILE_PATH}
#         ...  is_pdl_checking_needed=${True}
