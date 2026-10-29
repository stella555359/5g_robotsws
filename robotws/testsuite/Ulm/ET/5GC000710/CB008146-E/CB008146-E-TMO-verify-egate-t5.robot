*** Settings ***
Documentation   This is a keyword file for CB008146-E, part egate verification for t5
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Variables ***

@{t5_pdu_measIdToAddModList}    measId 1,measObjectId 1,reportConfigId 1    measId 2,measObjectId 1,reportConfigId 2
...                             measId 3,measObjectId 1,reportConfigId 3    measId 4,measObjectId 1,reportConfigId 4
@{t5_pdu_reportConfigId}        reportConfigId 1     reportConfigId 2     reportConfigId 3     reportConfigId 4
@{t5_pdu_eventId}               eventId eventA2      eventId eventA2      eventId eventA3      eventId eventA5


@{t5_A2_measIdToRemoveList}        1
@{t5_A2_measIdToAddModList}     measId 5,measObjectId 1,reportConfigId 5    measId 6,measObjectId 2,reportConfigId 6
@{t5_A2_reportConfigId}         reportConfigId 5     reportConfigId 6
@{t5_A2_eventId}                eventId eventA1     eventId eventA3
@{t5_A2_measGapConfig}          gapUE setup    gapOffset   mgta ms0


@{t5_A3_measIdToRemoveList}         1   2   3   4   5   6
@{t5_A3_measIdToAddModList}     measId 7,measObjectId 4,reportConfigId 7    measId 8,measObjectId 4,reportConfigId 8
...                             measId 9,measObjectId 4,reportConfigId 9    measId 10,measObjectId 4,reportConfigId 10
@{t5_A3_measIdToAddModList_25R2}   measId 7,measObjectId 6,reportConfigId 7    measId 8,measObjectId 6,reportConfigId 8
...                             measId 9,measObjectId 6,reportConfigId 9    measId 10,measObjectId 6,reportConfigId 10


@{t5_A3_reportConfigId}        reportConfigId 7          reportConfigId 8     reportConfigId 9     reportConfigId 10
@{t5_A3_eventId}              eventId eventA2           eventId eventA2      eventId eventA3      eventId eventA5



*** Keywords ***

Verify Egate Log t5
    [Documentation]    [PRIVATE]    verify egate log for t5
    ...       :Autor: Sylvia Schneider
    Set SW Release Version

    ${scf_xml}    Parse XML    ${resultDir}/SCF_final.xml
    ${xpath_NRCELL-10}  Set Variable   managedObject[@distName="${bts_distName}/NRCELL-10"]
    ${rsrp_redir}    Get Element Text   ${scf_xml}
    ...   xpath=.//${xpath_NRCELL-10}/list[@name="a2MeasRedirectSsbRsrp"]/item/p[@name="a2ThresholdRedirectSsbRsrp"]
    ${rsrp_HoSA}    Get Element Text   ${scf_xml}
    ...   xpath=.//${xpath_NRCELL-10}/list[@name="a2MeashoSsbRsrpSA"]/item/p[@name="a2ThresholdhoSsbRsrpSA"]
    ${t5_pdu_a2-Threshold_rsrp}     Create List   a2-Threshold rsrp : ${rsrp_HoSA}    a2-Threshold rsrp : ${rsrp_redir}
    Set Test Variable    ${t5_pdu_a2-Threshold_rsrp}
    ${t5_A3_a2-Threshold_rsrp}      Create List   a2-Threshold rsrp : ${rsrp_HoSA}    a2-Threshold rsrp : ${rsrp_redir}
    Set Test Variable    ${t5_A3_a2-Threshold_rsrp}

    Log To Console    \nVerify pdu session
    Prepare Egate File For Verification      ${resultDir}/egate_log1.txt
    Verify measIdToAddModList From Egate Log      ${t5_pdu_measIdToAddModList}
    Verify reportConfigToAddModList From Egate Log With a2-Threshold For t5_pdu

    Log To Console    \nVerify A2 measurement
    Prepare Egate File For Verification      ${resultDir}/egate_log2.txt
    Verify measIdToRemoveList From Egate Log      ${t5_A2_measIdToRemoveList}
    Verify measIdToAddModList From Egate Log      ${t5_A2_measIdToAddModList}
    Verify reportConfigToAddModList From Egate Log reportConfigId eventId For t5_A2
    Verify measGapConfig From Egate Log    ${t5_A2_measGapConfig}

    Log To Console    \nVerify A3 measurement with nrsrq_nr=45
    Prepare Egate File For Verification      ${resultDir}/egate_log4.txt
    Verify Inter-eNB handover Present In Egate Log    search_text=Inter-eNB handover from EXT_ENB-2.10 to ENB-3.2 performed

    Log To Console    \nVerify A3 measurement with nrsrq_nr=50
    Prepare Egate File For Verification      ${resultDir}/egate_log6.txt
    Verify measIdToRemoveList From Egate Log      ${t5_A3_measIdToRemoveList}
    IF    $release in ['SBTS00', 'SBTS25R3', 'SBTS26R1']
          Verify measIdToAddModList From Egate Log   ${t5_A3_measIdToAddModList}
    ELSE
          Verify measIdToAddModList From Egate Log   ${t5_A3_measIdToAddModList_25R2}
    END
    Verify reportConfigToAddModList From Egate Log With a2-Threshold For t5_A3
    Verify Inter-eNB handover Present In Egate Log    search_text=Inter-eNB handover from ENB-3.2 to EXT_ENB-2.10 performed
