*** Settings ***
Documentation
...        Maintainers:
...           Michal Gorski, michal.gorski@nokia.com
...           Kamil Krawiec, kamil.krawiec@nokia.com
...           Arkadiusz Sobejko, arkadiusz.sobejko@nokia.com
...           Patryk Wójcik, patryk.wojcik@nokia.com
...        Authors:
...           Michal Gorski, michal.gorski@nokia.com
...           Kamil Krawiec, kamil.krawiec@nokia.com
...           Arkadiusz Sobejko, arkadiusz.sobejko@nokia.com
...           Patryk Wójcik, patryk.wojcik@nokia.com
...        Description:  Common keywords for CB008158

Library     ute_fsmaccess
Library     ta5g_pm_counters
Library     CB008158_resources.py
Library     ../../resources_kr/python/traffic_handling.py
Library     ../../resources_kr/python/ue_handling.py
Resource    ../../resources_kr/robot/common_keywords.robot
Resource    ../../resources_kr/robot/collectors.robot

*** Keywords ***
Verify in UeContextModificationResponse that DRX is configured for UE_${UE_ID}
    Log to console  Verifying UeContextModificationResponse that DRX is configured for ${UE_ID}
    Expect message flow
    ...    gNB2:F1AP_UEContextModificationResponse (drx-Config is present)
    ...    alias=UeContextModification   overall_timeout=10
    Flow occurred as expected  alias=UeContextModification

Configure NSA PMQAP Profiles
    Log to console  Configuring NSA PMQAP Profiles
    Configure    ${CURDIR}/../config/activating_NSA_PMQAP_profiles.yaml

Configure SA PMQAP Profiles
    Log to console  Configuring SA PMQAP Profiles
    Configure    ${CURDIR}/../config/activating_SA_PMQAP_profiles.yaml

Set feature flag ${MOC}-${ID}/${parameter} to ${value}
    Log to console  Set feature flag ${MOC}-${ID}/${parameter} to ${value}
    Configure    {'MOC': '${MOC}', 'ID': '${ID}', '${parameter}': '${value}'}

Set parameter ${MOC}-${ID}/${parameter} to ${value}
    Log to console  Set feature flag ${MOC}-${ID}/${parameter} to ${value}
    Configure    {'MOC': '${MOC}', 'ID': '${ID}', '${parameter}': '${value}'}

Start TTI trace collection
    Start TTI trace

Stop and convert TTI trace collection
    [Arguments]  ${directory_name}=TtiTraces    ${conversion_filter}=None
    ${parent_directory}  Set variable  ${directory_name}
    Set Test Variable  ${parent_directory}
    Stop TTI trace    target_dir=${OUTPUTDIR}/${TESTNAME}/${parent_directory}
    Convert TTI trace pcap
    ...  input=${OUTPUTDIR}/${TESTNAME}/${parent_directory}/l2stream3/tcpdump/tcpdump.pcap
    ...  output=${OUTPUTDIR}/${TESTNAME}/${parent_directory}/output
    ...  conversion_filter=${conversion_filter}

Modify pdu session
    [Arguments]  ${UE_ID}  ${QOS}  ${PDU_ID}=${UE_ID}
    Execute egate command
    ...    cmd=ue_pdu_session_modify ue=${UE_ID} pdu=${PDU_ID} qosflows_to_add=${QOS}

Modify LTE-NR dual connectivity
    [Arguments]  ${UE_ID}  ${BEARER_ID}
    Sleep  2s    reason=wait for stabilization
    Execute egate command
    ...    cmd=bearer_add ue=${UE_ID} id=${BEARER_ID} filter=1 precedence=1
    Sleep  1s    reason=wait for stabilization
    Execute egate command
    ...    cmd=enb_ue_dc_modify ue=${UE_ID} bearer_to_add=${BEARER_ID} by=enb cause=RN_CauseRadioNetwork_unspecified type=split_scg
    Sleep  1s    reason=wait for stabilization

Start sending 100 short bursts from UE-${ue_id} on QFI-${qfi}
    Execute egate command    cmd=trf_data_start ue=${ue_id} pdu=${ue_id} qfi=${qfi} dir=ul size=1350 burst=1 period_ms=100 packets=100

Start sending 100 short bursts from UE-${ue_id} on bearer-${bearer_id}
    Execute egate command    cmd=trf_data_start ue=${ue_id} id=${bearer_id} dir=ul size=1350 burst=1 period_ms=100 packets=100
