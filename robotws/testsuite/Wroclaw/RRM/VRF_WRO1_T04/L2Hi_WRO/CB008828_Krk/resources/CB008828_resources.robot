*** Settings ***
Documentation
...        Maintainers:
...           Michal Gorski, michal.gorski@nokia.com
...           Jakub Grela, jakub.grela@nokia.com
...           Magdalena Hebda, magdalena.hebda@nokia.com
...           Kamil Krawiec, kamil.krawiec@nokia.com
...           Arkadiusz Sobejko, arkadiusz.sobejko@nokia.com
...           Aleksandra Wilczynska, aleksandra.wilczynska@nokia.com
...        Authors:
...           Michal Gorski, michal.gorski@nokia.com
...           Jakub Grela, jakub.grela@nokia.com
...           Magdalena Hebda, magdalena.hebda@nokia.com
...           Kamil Krawiec, kamil.krawiec@nokia.com
...           Arkadiusz Sobejko, arkadiusz.sobejko@nokia.com
...           Aleksandra Wilczynska, aleksandra.wilczynska@nokia.com
...
...        Description:  Common keywords for CB008828

Library     ../../resources_kr/python/traffic_handling.py
Library     CB008828_resources.py
Library     ute_fsmaccess
Library     ta5g_pm_counters
Library     OperatingSystem
Library     Collections
Resource    ../../resources_kr/robot/common_keywords.robot
Resource    ../../resources_kr/robot/collectors.robot
Library     ute_wtssim
Library     ta_emss
Library     ta_messaging
Library     ta5g_egate
Library     taf.ul.ue.sim.env_setup

Library     ../../resources_kr/python/common_keywords.py

*** Keywords ***
Set feature flag ${MOC}-${ID}/${parameter} to ${value}
    Log to console  Set feature flag ${MOC}-${ID}/${parameter} to ${value}
    Configure    {'MOC': '${MOC}', 'ID': '${ID}', '${parameter}': '${value}'}

Start TTI trace collection
    Start TTI trace

Stop and convert TTI trace collection
    [Arguments]  ${directory_name}=${TESTNAME}/TtiTraces  ${conversion_filter}=None  ${format}=excelCsv  ${delay}=0
    ${parent_directory}  Set variable  ${directory_name}
    Set Test Variable  ${parent_directory}
    Stop TTI trace  target_dir=${OUTPUTDIR}/${parent_directory}  delay=${delay}
    Convert TTI trace pcap
    ...  input=${OUTPUTDIR}/${parent_directory}/l2stream3/tcpdump/tcpdump.pcap
    ...  output=${OUTPUTDIR}/${parent_directory}/output
    ...  conversion_filter=${conversion_filter}
    ...  format=${format}

Get C-RNTI for UE
    [Arguments]  ${UE_ID}
    Get Ue C-RNTI  UE_ID=${UE_ID}
    ${rnti}=  Convert To String  ${${crnti}${UE_ID}}
    Set To Dictionary    ${ues_rnti}    ${rnti}=${UE_ID}

Get C-RNTI-2 for UE
    [Arguments]  ${UE_ID}
    Get Ue C-RNTI  UE_ID=${UE_ID}
    ${rnti}=  Convert To String  ${${crnti}${UE_ID}}
    Set To Dictionary    ${ue_rnti}    ${rnti}=${UE_ID}

Modify LTE-NR dual connectivity
    [Arguments]  ${UE_ID}  ${BEARER_ID}
    Sleep  2s    reason=wait for stabilization
    Execute egate command
    ...    cmd=bearer_add ue=${UE_ID} id=${BEARER_ID} filter=1 precedence=1
    Sleep  1s    reason=wait for stabilization
    Execute egate command
    ...    cmd=enb_ue_dc_modify ue=${UE_ID} bearer_to_add=${BEARER_ID} by=enb cause=RN_CauseRadioNetwork_unspecified type=split_scg
    Sleep  1s    reason=wait for stabilization

Modify pdu session
    [Arguments]  ${UE_ID}  ${QOS}  ${PDU_ID}=${UE_ID}
    Execute egate command
    ...    cmd=ue_pdu_session_modify ue=${UE_ID} pdu=${PDU_ID} qosflows_to_add=${QOS}
    Sleep    2s

Register UE-${UE_ID} and establish ${PDU_ID} pdu sessions on ${SLICE} slice on ${CELL_ID} cell
    Set pdu param for internal traffic  UE_ID=${UE_ID}  PDU_ID=${PDU_ID}
    Register UE  UE_ID=${UE_ID}  CELL_ID=${CELL_ID}
    Establish PDU session  UE_ID=${UE_ID}  PDU_ID=${PDU_ID}    SLICE_ID=${SLICE}    RRC_CHECK=True
    Get C-RNTI for UE    UE_ID=${UE_ID}

Change eNB ENDC selected PLMN
    [Arguments]  ${PLMN}
    Execute egate command
    ...    cmd=enb_endc_param id=1 selected_plmn=${PLMN}
    Sleep  2s

Start ${dl_tput}Mbps DL traffic for UE-${UE_ID} for ${PDU}pdu
    Start SA traffic  ue=${UE_ID}  dir=dl  pdu=${PDU}  traffic_rate=${dl_tput}Mbps

Start ${ul_tput}Mbps UL traffic for UE-${UE_ID} for ${PDU}pdu
    Start SA traffic  ue=${UE_ID}  dir=ul  pdu=${PDU}  traffic_rate=${ul_tput}Mbps

Create ues dictionary
    ${ues_rnti}    Create Dictionary
    Set Suite Variable  ${ues_rnti}

Wait ${duration} for ${reason}
    Sleep    ${duration}    ${reason}
