*** Settings ***
Documentation   This is a keyword file for CB008146-E, part egate verification for t2
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------


*** Variables ***

@{t2_pdu_measIdToAddModList}    measId 1,measObjectId 1,reportConfigId 1    measId 2,measObjectId 1,reportConfigId 2
...                             measId 3,measObjectId 1,reportConfigId 3    measId 4,measObjectId 1,reportConfigId 4
@{t2_pdu_reportConfigId}        reportConfigId 1     reportConfigId 2     reportConfigId 3     reportConfigId 4
@{t2_pdu_eventId}               eventId eventA2      eventId eventA2      eventId eventA3      eventId eventA5

@{t2_A2_measIdToRemoveList}     1
@{t2_A2_measIdToAddModList}     measId 5,measObjectId 1,reportConfigId 5    measId 6,measObjectId 2,reportConfigId 6
@{t2_A2_reportConfigId}         reportConfigId 5          reportConfigId 6
@{t2_A2_eventId}                eventId eventA1           eventId eventA3
@{t2_A2_measGapConfig}          gapUE setup    gapOffset   mgta ms0


*** Keywords ***

Verify Egate Log t2
    [Documentation]    [PRIVATE]    verify egate log for t2
    ...       :Autor: Sylvia Schneider

    ${scf_xml}    Parse Xml    ${resultDir}/SCF_final.xml
    ${xpath_NRCELL-10}  Set Variable   managedObject[@distName="${bts_distName}/NRCELL-10"]
    ${xpath_NRCELL-10_NRHOIF-5}  Set Variable   managedObject[@distName="${bts_distName}/NRCELL-10/NRHOIF-5"]

    ${rsrp_redir}    Get Element Text   ${scf_xml}
    ...   xpath=.//${xpath_NRCELL-10}/list[@name="a2MeasRedirectSsbRsrp"]/item/p[@name="a2ThresholdRedirectSsbRsrp"]
    ${rsrp_HoSA}    Get Element Text   ${scf_xml}
    ...   xpath=.//${xpath_NRCELL-10}/list[@name="a2MeashoSsbRsrpSA"]/item/p[@name="a2ThresholdhoSsbRsrpSA"]
    ${t2_pdu_a2-Threshold_rsrp}     Create List   a2-Threshold rsrp : ${rsrp_HoSA}    a2-Threshold rsrp : ${rsrp_redir}
    Set Test Variable   ${t2_pdu_a2-Threshold_rsrp}

    Log To Console    \nVerify pdu session
    Prepare Egate File For Verification      ${resultDir}/egate_log1.txt
    Verify measIdToAddModList From Egate Log      ${t2_pdu_measIdToAddModList}
    Verify reportConfigToAddModList From Egate Log With a2-Threshold For t2_pdu

    ${rsrp_a1}    Get Element Text   ${scf_xml}
    ...   xpath=.//${xpath_NRCELL-10}/list[@name="a1MeashoSsbRsrpSA"]/item/p[@name="a1ThresholdhoSsbRsrpSA"]
    ${rsrp_a3}    Get Element Text   ${scf_xml}
    ...   xpath=.//${xpath_NRCELL-10_NRHOIF-5}/list[@name="a3MeasSsbRsrp"]/item/p[@name="a3OffsetSsbRsrp"]
    ${t2_A2_a1_a3_rsrp}     Create List   a1-Threshold rsrp : ${rsrp_a1}    a3-Offset rsrp : ${rsrp_a3}
    Set Test Variable   ${t2_A2_a1_a3_rsrp}

    Log To Console    \nVerify A2 measurement
    Prepare Egate File For Verification      ${resultDir}/egate_log3.txt
    Verify measIdToRemoveList From Egate Log      ${t2_A2_measIdToRemoveList}
    Verify measIdToAddModList From Egate Log      ${t2_A2_measIdToAddModList}
    Verify reportConfigToAddModList From Egate Log For A2 t2
    Verify measGapConfig From Egate Log    ${t2_A2_measGapConfig}
