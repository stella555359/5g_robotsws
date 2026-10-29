*** Settings ***
Documentation       Test suite for basic CSV4ALL Tests in loop
...                 Author: Damian Pietrzyk
...                 Contact: damian.pietrzyk@nokia.com

Library             taf/rfrl/csv4all/CSV4AllTestCases.py

*** Variables ***
${RP_CA}   		    VRF_RRM
${RP_LOCATION}    	    VRF_BLR1
${RP_ORGANIZATION}    	    VRF_BLR1_T03
${EMAIL_RECIPIENTS}         shaheena.parveen@nokia.com
${INITIAL_SW}               SBTS00_ENB_9999_251209_000006
${TARGET_SW}                SBTS00_ENB_9999_251209_000006
@{CUSTOM_ALLOWED}           4655  4654  61524  61652  6261  6150  6202  4297  61649  6322  4548  4291  4681  4420  4459  6328  6331
@{TEMP_ALLOW_ALARMS}        6331
@{CRITICAL_FAULTS}	    @{EMPTY}
&{NODE2}                    node_vm=10.43.54.232
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...			    temporary_allowed_alarms=${TEMP_ALLOW_ALARMS}
...			    custom_allowed_alarms=${CUSTOM_ALLOWED}
${SHOULD_BE_REPORTED}		True
${RESTORE_TARGET_SW}		True
@{CUSTOMERS_LIST}			TMO US
${QC_DOMAIN}				MN_RAN
${QC_PROJECT}				RAN_VRF
${testline_name}=               1_2_CLOUD480
${TEST_QC_ID_1}=                236565
${ONLINE_PARAMETER_DELTA}    ${CURDIR}/delta_online.json
# List of nodes passed to test keywords
@{NODES}                    ${NODE2}

*** Test Cases ***

E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Timeout]   24h
    Set Tags    QC_${TEST_QC_ID_1}
    Set Tags    QCP_${QC_PROJECT}
    Set Tags    QCD_${QC_DOMAIN}
    Set suite Variable    ${TEST_QC_ID}    ${TEST_QC_ID_1}
    Set suite Variable    ${QC_PROJECT}    ${QC_PROJECT}
    Set suite Variable    ${QC_DOMAIN}    ${QC_DOMAIN}
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION    ${NODES}  ${NODE2}  2
    ...          customers_list=${CUSTOMERS_LIST}
    ...          delta=${ONLINE_PARAMETER_DELTA}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=236565  #trunk
    ...          qc_project=${QC_PROJECT}