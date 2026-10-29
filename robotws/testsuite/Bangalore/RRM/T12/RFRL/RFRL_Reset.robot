*** Settings ***
Documentation       Test suite for basic CSV4ALL Tests in loop
...                 Author: Damian Pietrzyk
...                 Contact: damian.pietrzyk@nokia.com
Library             taf/rfrl/csv4all/CSV4AllTestCases.py


*** Variables ***
${QC_DOMAIN}        MN_RAN
${QC_PROJECT}       RAN_VRF
@{CUSTOMERS}      	Reliance India
${INITIAL_SW}    	SBTS00_ENB_9999_250203_000003
${TARGET_SW}       	SBTS00_ENB_9999_250223_000005
@{CUSTOM_ALLOWED}   1811    2412    4003    4297    4406    4654    4655    4681
...     6150    6202    6261    6322    6328    7525    61524   61649
&{VM_DICT}  host=10.53.164.17
...         user=ute
...         password=BT5l@bus3rl0g1n
&{NODE3}    node_vm=${VM_DICT}
...         source_sw=${INITIAL_SW}
...         target_sw=${TARGET_SW}
...         custom_allowed_alarms=${CUSTOM_ALLOWED}
@{NODES}    ${NODE3}


*** Test Cases ***
E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
    [Documentation]   Perform site reset without HWF while monitoring OAM KPI metrics.
    [Timeout]   24h
    Set Test Variable       &{OAM_KPI_TARGETS_RESET}    kp1a=500    kpi1b=600   kpi1c=415
    E2E TL SITE RESET WITHOUT HWF WITH OAM KPI
    ...     ${NODES}
    ...     ${NODE3}
    ...     iterations_per_node=20
    ...     customers_list=${CUSTOMERS}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_id=107648
    ...     qc_project=${QC_PROJECT}
