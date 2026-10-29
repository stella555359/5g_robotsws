*** Settings ***
Documentation
...                 author: Michal Kornacki
...                 contact: michal.kornacki@nokia.com
...                 Test suite for basic CSV4ALL Tests in loop:

Library             taf/rfrl/csv4all/CSV4AllTestCases.py
Force Tags          CA_VRF_SISO     #Trunk
#Force Tags          CA_VRF_WRO4        #branch 24R3
*** Variables ***
${RP_CA}                    VRF_SiSo
${RP_LOCATION}              VRF_WRO3
${RP_ORGANIZATION}          VRF_WRO3_T07
${QC_DOMAIN}=               MN_RAN
${QC_PROJECT}=              RAN_VRF    #Trunk
#${QC_PROJECT}=              RAN_ST    #Branch 24R3
#${COLLECT_SNAPSHOT_FLAG}    always     # possible values: failed_verdict / always
@{CUSTOMERS_LIST}=          TPG Telecom
${INITIAL_SW}               SBTS00_ENB_9999_260310_000005
${TARGET_SW}                SBTS00_ENB_9999_260310_000005

${ITERATIONS}               ${None}
&{NODE1}                    testline_object=${tl.enbs[0]}
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=6327 6322 4681 1838 7300 4655 7319 62003 1932
@{NODES}                    ${NODE1}
${SKIP_TRUCK_ROLL}=         ${True}
${BTS_info}                 taf_admin.Get Bts Info          timeout=30

${REPORT}                   ${False}

*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]   24h
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI    ${NODES}  ${NODE1}
    ...         iterations_per_node=2
    ...         report=${True}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${50430}     #Trunk
    ...         restore_to_target_sw=${True}
     ...         qc_id=${261471}    #26R1
     ...         qc_id=${310462}    #26R2
[1.0] E2E_TL_Activation_reset_with_OAM_KPI
    [Timeout]   24h
    E2E TL ACTIVATION RESET TEST    ${NODES}  ${NODES}
    ...         iterations_per_node=5
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${184859}    #Trunk
#    ...         qc_id=${261469}    #26R1
     ...         qc_id=${310460}    #26R2
[1.0] E2E_TL_Site_Reset_with_OAM_KPI
    [Timeout]   24h
    E2E TL SITE RESET WITH OAM KPI    ${NODES}  ${NODE1}
    ...         iterations_per_node=1
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${177825}    #Trunk
     ...         qc_id=${261470}    #26R1
     ...         qc_id=${310461}    #26R2
[1.0] E2E_TL_RU_Reset_with_OAM_KPI
    [Timeout]   24h
    E2E TL RU RESET WITH OAM KPI    ${NODES}    ${NODE1}
    ...         iterations_per_node=100
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${40097}    #Trunk
     ...         qc_id=${261472}    #26R1
     ...         qc_id=${310463}    #26R2

[1.0] E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Timeout]   24h
    E2E TL CAPACITY MODULE RESET WITH OAM KPI    ${NODES}    ${NODE1}
    ...         iterations_per_node=1
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${40095}    #Trunk
     ...         qc_id=${261473}    #26R1
     ...         qc_id=${310464}    #26R2
