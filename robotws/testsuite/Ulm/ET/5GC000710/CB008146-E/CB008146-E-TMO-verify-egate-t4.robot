*** Settings ***
Documentation   This is a keyword file for CB008146-E, part egate verification for t4
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Variables ***
@{t4_pdu_measIdToAddModList}    measId 1,measObjectId 1,reportConfigId 1    measId 2,measObjectId 1,reportConfigId 2
...                             measId 3,measObjectId 1,reportConfigId 3    measId 4,measObjectId 1,reportConfigId 4

@{t4_pdu_modify_measIdToRemoveList}        1
@{t4_pdu_modify_measIdToAddModList}       measId 5,measObjectId 1,reportConfigId 5

@{t4_A2_measIdToRemoveList}         5
@{t4_A2_measIdToAddModList}     measId 6,measObjectId 1,reportConfigId 6    measId 7,measObjectId 2,reportConfigId 7
@{t4_A2_reportConfigId}         reportConfigId 6          reportConfigId 7
@{t4_A2_eventId}                eventId eventA1           eventId eventA3
@{t4_A2_measGapConfig}             gapUE setup    gapOffset   mgta ms0

@{t4_A1_measIdToRemoveList}         6      7
@{t4_A1measIdToAddModList}     measId 8,measObjectId 1,reportConfigId 8


*** Keywords ***


Verify Egate Log t4
    [Documentation]    [PRIVATE]    verify egate log for t4
    ...       :Autor: Sylvia Schneider
    Log To Console    \nVerify pdu session
    Prepare Egate File For Verification      ${resultDir}/egate_log1.txt
    Verify measIdToAddModList From Egate Log      ${t4_pdu_measIdToAddModList}
    Verify reportConfigToAddModList From Egate Log For Test t4_pdu

    Log To Console    \nVerify pdu modify session
    Prepare Egate File For Verification      ${resultDir}/egate_log2.txt
    Verify measIdToRemoveList From Egate Log      ${t4_pdu_modify_measIdToRemoveList}
    Verify measIdToAddModList From Egate Log      ${t4_pdu_modify_measIdToAddModList}
    Verify reportConfigToAddModList From Egate Log For Test t4 pdu modify

    ${scf_xml}    Parse XML    ${resultDir}/SCF_final.xml
    ${xpath_NRCELL-10}  Set Variable   managedObject[@distName="${bts_distName}/NRCELL-10"]
    ${rsrp_a1_VoNr}    Get Element Text   ${scf_xml}
    ...   xpath=.//${xpath_NRCELL-10}/list[@name="a1MeashoSsbRsrpSA"]/item/p[@name="a1ThresholdHoSsbRsrpVoNr"]
    ${xpath_NRCELL-10_NRHOIF-5}  Set Variable   managedObject[@distName="${bts_distName}/NRCELL-10/NRHOIF-5"]
    ${NRHOIF_a3_VoNr}    Get Element Text   ${scf_xml}
    ...   xpath=.//${xpath_NRCELL-10_NRHOIF-5}/list[@name="a3MeasSsbRsrp"]/item/p[@name="a3OffsetSsbRsrpVoNr"]
    ${t4_A2_a1_a3_rsrp}     Create List   a1-Threshold rsrp : ${rsrp_a1_VoNr}    a3-Offset rsrp : ${NRHOIF_a3_VoNr}
    Set Test Variable    ${t4_A2_a1_a3_rsrp}

    Log To Console    \nVerify A2 measurement
    Prepare Egate File For Verification      ${resultDir}/egate_log3.txt
    Verify measIdToRemoveList From Egate Log      ${t4_A2_measIdToRemoveList}
    Verify measIdToAddModList From Egate Log      ${t4_A2_measIdToAddModList}
    Verify reportConfigToAddModList From Egate Log For A2 t4
    Verify measGapConfig From Egate Log    ${t4_A2_measGapConfig}

    Log To Console    \nVerify A1 measurement
    Prepare Egate File For Verification      ${resultDir}/egate_log5.txt
    Verify measIdToRemoveList From Egate Log      ${t4_A1_measIdToRemoveList}
    Verify measIdToAddModList From Egate Log      ${t4_A1_measIdToAddModList}
    Verify reportConfigToAddModList From Egate Log For Test t4_A1
    Verify gapUE release Present In Egate log

