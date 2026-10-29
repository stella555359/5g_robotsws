*** Settings ***
Documentation   This is a keyword file for CB008146-E, part egate verification for t3
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Variables ***

@{t3_pdu_measIdToAddModList}    measId 1,measObjectId 1,reportConfigId 1    measId 2,measObjectId 1,reportConfigId 2
...                             measId 3,measObjectId 1,reportConfigId 3    measId 4,measObjectId 1,reportConfigId 4
@{t3_pdu_reportConfigId}        reportConfigId 1    reportConfigId 2    reportConfigId 3    reportConfigId 4
@{t3_pdu_eventId}               eventId eventA2     eventId eventA2     eventId eventA3     eventId eventA5

@{t3_A2_measIdToRemoveList}    1
@{t3_A2_measIdToAddModList}    measId 5,measObjectId 1,reportConfigId 5    measId 6,measObjectId 2,reportConfigId 6
@{t3_A2_reportConfigId}        reportConfigId 5          reportConfigId 6
@{t3_A2_eventId}               eventId eventA1           eventId eventA3

@{t3_A1_measIdToRemoveList}    5   6
@{t3_A1_measIdToAddModList}    measId 7,measObjectId 1,reportConfigId 7
@{t3_A1_reportConfigId}        reportConfigId 7
@{t3_A1_eventId}               eventId eventA2


*** Keywords ***

Verify Egate Log t3
    [Documentation]    [PRIVATE]    verify egate log for t3
    ...       :Autor: Sylvia Schneider

    Log To Console    \nVerify pdu session
    Prepare Egate File For Verification      ${resultDir}/egate_log1.txt
    Verify measIdToAddModList From Egate Log      ${t3_pdu_measIdToAddModList}
    Verify reportConfigToAddModList From Egate Log For Test t3_pdu

    Log To Console    \nVerify A2 measurement
    Prepare egate file for verification      ${resultDir}/egate_log2.txt
    Verify measIdToRemoveList From Egate Log      ${t3_A2_measIdToRemoveList}
    Verify measIdToAddModList From Egate Log      ${t3_A2_measIdToAddModList}
    Verify reportConfigToAddModList From Egate Log reportConfigId eventId For t3_A2
    Verify Not Present In Egate Log     gapUE setup

    ${scf_xml}    Parse Xml    ${resultDir}/SCF_final.xml
    ${xpath_NRCELL-10}  Set Variable   managedObject[@distName="${bts_distName}/NRCELL-10"]
    ${rsrp_HoSA}    Get Element Text   ${scf_xml}
    ...   xpath=.//${xpath_NRCELL-10}/list[@name="a2MeashoSsbRsrpSA"]/item/p[@name="a2ThresholdhoSsbRsrpSA"]
    ${t3_A1_a2-Threshold_rsrp}     Create List   a2-Threshold rsrp : ${rsrp_HoSA}
    Set Test Variable    ${t3_A1_a2-Threshold_rsrp}

    Log To Console    \nVerify A1 measurement
    Prepare Egate File For Verification      ${resultDir}/egate_log4.txt
    Verify measIdToRemoveList From Egate Log      ${t3_A1_measIdToRemoveList}
    Verify measIdToAddModList From Egate Log      ${t3_A1_measIdToAddModList}
    Verify reportConfigToAddModList From Egate Log For Test t3_A1

