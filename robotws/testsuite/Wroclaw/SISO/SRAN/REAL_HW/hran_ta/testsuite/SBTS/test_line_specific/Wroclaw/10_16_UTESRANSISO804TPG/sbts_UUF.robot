*** Settings ***
Documentation
...                 author: Michal Kornacki
...                 contact: michal.kornacki@nokia.com
...                 Test suite for basic CSV4ALL Tests in loop:

Library             taf/rfrl/csv4all/CSV4AllTestCases.py

Force Tags          CA_VRF_SISO                     #Competence Area [trunk]

*** Variables ***
${RP_CA}                    VRF_SiSo
${RP_LOCATION}              VRF_WRO3
${RP_ORGANIZATION}          VRF_WRO3_T07
${QC_DOMAIN}=               MN_RAN
${QC_PROJECT}=              RAN_VRF
@{CUSTOMERS_LIST}=          TPG Telecom
${INITIAL_SW}               SBTS00_ENB_9999_260303_000014
${TARGET_SW}                SBTS00_ENB_9999_260304_000006
${ITERATIONS}               ${None}
@{ALLOWED}                  6327    6322    4681    1838    7300    4655    7319    62003    7300     4476
&{NODE1}                    testline_object=${tl.enbs[0]}
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${ALLOWED}
@{NODES}                    ${NODE1}
${SKIP_TRUCK_ROLL}=         ${True}
#${REPORT}                   ${FALSE}

*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]   24h
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI    ${NODES}  ${NODE1}
    ...         iterations_per_node=1
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${53534}     #Trunk
    ...         restore_to_target_sw=${True}
#    ...         qc_id=${310458}   #26R2
#    ...         qc_id=${261479}   #26R1
#E2E_TL_Activation_reset_with_OAM_KPI
#    [Timeout]   24h
#    E2E TL ACTIVATION RESET TEST    ${NODES}  ${NODES}
#    ...         iterations_per_node=5
#    ...         customers_list=@{CUSTOMERS_LIST}
#    ...         qc_domain=${QC_DOMAIN}
#    ...         qc_project=${QC_PROJECT}
#    ...         qc_id=${184856}    #Trunk
#    ...         qc_id=${261475}   #26R1
#     ...         qc_id=${310455}   #26R2
#
#E2E_TL_Site_Reset_with_OAM_KPI
#    [Timeout]   24h
#    E2E TL SITE RESET WITH OAM KPI    ${NODES}  ${NODE1}
#    ...         iterations_per_node=20
#    ...         customers_list=@{CUSTOMERS_LIST}
#    ...         qc_domain=${QC_DOMAIN}
#    ...         qc_project=${QC_PROJECT
#    ...         qc_id=${177901}    #Trunk
#     ...         qc_id=${310456}   #26R2
#     ...         qc_id=${261476}   #26R1

#E2E_TL_RU_Reset_with_OAM_KPI
#    [Timeout]   24h
#    E2E TL RU RESET WITH OAM KPI    ${NODES}    ${NODE1}
#    ...         iterations_per_node=8
#    ...         customers_list=@{CUSTOMERS_LIST}
#    ...         qc_domain=${QC_DOMAIN}
#    ...         qc_project=${QC_PROJECT}
#    ...         qc_id=${53535}    #Trunk
#     ...         qc_id=${310457}   #26R2
#     ...         qc_id=${261478}   #26R2
#E2E_TL_Capacity_Module_Reset_with_OAM_KPI
#    [Timeout]   24h
#    E2E TL CAPACITY MODULE RESET WITH OAM KPI    ${NODES}    ${NODE1}
#    ...         iterations_per_node=10
#    ...         customers_list=@{CUSTOMERS_LIST}
#    ...         qc_domain=${QC_DOMAIN}
#    ...         qc_project=${QC_PROJECT}
#    ...         qc_id=${53537}    #Trunk
#     ...         qc_id=${310458}   #26R2
#     ...         qc_id=${261477}   #26R1

