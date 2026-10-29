*** Settings ***
Documentation   This is a keyword file for CB008146-E, part egate verification for t6
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Variables ***

@{t6_pdu_measIdToAddModList}    measId 1,measObjectId 1,reportConfigId 1    measId 2,measObjectId 1,reportConfigId 2
...                             measId 3,measObjectId 1,reportConfigId 3    measId 4,measObjectId 1,reportConfigId 4
@{t6_pdu_reportConfigId}        reportConfigId 1     reportConfigId 2     reportConfigId 3     reportConfigId 4
@{t6_pdu_eventId}               eventId eventA2      eventId eventA2      eventId eventA3      eventId eventA5

@{t6_A3_measIdToRemoveList}         1   2   3   4   5   6
@{t6_A3_measIdToAddModList}     measId 7,measObjectId 4,reportConfigId 7    measId 8,measObjectId 4,reportConfigId 8
...                             measId 9,measObjectId 4,reportConfigId 9    measId 10,measObjectId 4,reportConfigId 10
@{t6_A3_reportConfigId}         reportConfigId 7          reportConfigId 8     reportConfigId 9     reportConfigId 10
@{t6_A3_eventId}                eventId eventA2           eventId eventA2      eventId eventA3      eventId eventA5


*** Keywords ***

Verify Egate Log t6
    [Documentation]    [PRIVATE]    verify egate log for t6
    ...       :Autor: Sylvia Schneider

    ${scf_xml}    Parse XML    ${resultDir}/SCF_final.xml
    ${xpath_NRCELL-10}  Set Variable   managedObject[@distName="${bts_distName}/NRCELL-10"]
    ${rsrp_redir}    Get Element Text   ${scf_xml}
    ...   xpath=.//${xpath_NRCELL-10}/list[@name="a2MeasRedirectSsbRsrp"]/item/p[@name="a2ThresholdRedirectSsbRsrp"]
    ${rsrp_HoSA}    Get Element Text   ${scf_xml}
    ...   xpath=.//${xpath_NRCELL-10}/list[@name="a2MeashoSsbRsrpSA"]/item/p[@name="a2ThresholdhoSsbRsrpSA"]
    ${t6_pdu_a2-Threshold_rsrp}     Create List   a2-Threshold rsrp : ${rsrp_HoSA}    a2-Threshold rsrp : ${rsrp_redir}
    Set Test Variable   ${t6_pdu_a2-Threshold_rsrp}
    ${t6_A3_a2-Threshold_rsrp}      Create List   a2-Threshold rsrp : ${rsrp_HoSA}    a2-Threshold rsrp : ${rsrp_redir}
    Set Test Variable   ${t6_A3_a2-Threshold_rsrp}

    Log To Console    \nVerify pdu session
    Prepare Egate File For Verification      ${resultDir}/egate_log1.txt
    Verify measIdToAddModList From Egate Log      ${t6_pdu_measIdToAddModList}
    Verify reportConfigToAddModList From Egate Log With a2-Threshold For t6_pdu

    Log To Console    \nVerify A3 measurement with phycell_id=48
    Prepare Egate File For Verification      ${resultDir}/egate_log2.txt
    Verify Inter-eNB handover Present In Egate Log    search_text=Inter-eNB handover from EXT_ENB-2.10 to ENB-3.1 performed

    Log To Console    \nVerify A3 measurement with phycell_id=60
    Prepare Egate File For Verification      ${resultDir}/egate_log3.txt
    Verify measIdToRemoveList From Egate Log      ${t6_A3_measIdToRemoveList}
    Verify measIdToAddModList From Egate Log      ${t6_A3_measIdToAddModList}
    Verify reportConfigToAddModList From Egate Log With a2-Threshold For t6_A3
    Verify Inter-eNB handover present in Egate Log    search_text=Inter-eNB handover from ENB-3.1 to EXT_ENB-2.10 performed

