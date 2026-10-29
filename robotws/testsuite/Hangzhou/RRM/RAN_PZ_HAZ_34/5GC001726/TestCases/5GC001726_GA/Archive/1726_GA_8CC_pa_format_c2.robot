# # #*** Settings ***
# # #Resource          ../../Resources/5GC001726_keywords_GA.robot
# # #
# # #Documentation    Suite description
# # #...   author: Ren Biyao
# # #...   contact: biyao.ren@nokia-sbell.com
# # #...   squad group: MMW_SG1
# # #...   Feature 5GC001726-GA in 5G19B program
# # #
# # #Force Tags    5G_RRM        7.1816  1726-GA
# # #Suite Setup    Suite preparation for c2 format
# # #Suite Teardown  Run keyword and ignore error    5GC001726_Keywords.Common Suite Teardown
# # #
# # #*** Test Cases ***
# # #[1]5GC001726_GA_161_GNB-8CCDL_2CCUL_maxScell7DL1UL_contiguous_freq_IWK_5GC001300_preamble_format_C2_120 kHz_prachConfigurationIndex_196
# # #    [Tags]    CIT_20B   CIT_TRUNK    CIT_21A
# # #    [Documentation]    Author: Ren Biyao
# # #    ...    Verify the 8CC DL and 2CC UL CA configuration can be enable on GNB with contiguous frequency when activate 5GC001300 Preamble
# # #    ...     format C2 - 120 kHz.
# # #    [Setup]    coam_gnb_classical.COAM Create log directory
# # #    FOR    ${pcell_index}    IN    @{PCELL_INDEX}
# # #      Attach to pcells and do verification for configured IE    cell_index_for_attach=${pcell_index}    log_prefix=1726_GA161
# # #    END
# # #    [Teardown]    Run keyword and ignore error    Test Case Teardown
# # #
# # #[1]5GC001726_GA_162_GNB-8CCDL_2CCUL_maxScell7DL1UL_non_contiguous_freq_IWK_5GC001300_preamble_format_C2_120 kHz_prachConfigurationIndex_187
# # #    [Tags]    CRT_20B   CRT_TRUNK    CRT_21A
# # #    [Documentation]    Author: Ren Biyao
# # #    ...    Verify the 8CC DL and 2CC UL CA configuration can be enable on GNB with non_contiguous frequency  when activate 5GC001300 Preamble
# # #    ...    format C2 - 120 kHz.
# # #    [Setup]    coam_gnb_classical.COAM Create log directory
# # #    FOR    ${pcell_index}    IN    @{PCELL_INDEX}
# # #      Attach to pcells and do verification for configured IE    cell_index_for_attach=${pcell_index}    log_prefix=1726_GA162
# # #    END
# # #    [Teardown]    Run keyword and ignore error    Test Case Teardown
# # #
# # #*** Keywords ***
# # #Suite preparation for c2 format
# # #   [Documentation]    Author: Ren Biyao
# # #   ...    The preamble change will cause the reset of bts, therefore, it will be configured during commission process.
# # #   ...    c2 format is a kind of preamble format, which is scope of 5GC001300 feature.
# # #   ${1726_SCF_PARA}    combine lists     ${SCF_MODIFY_COMMON}    ${MODIFY_SCF_FOR_C2_FORMAT}
# # #   Suite Preparation    1726_scf_parameter=${1726_SCF_PARA}
