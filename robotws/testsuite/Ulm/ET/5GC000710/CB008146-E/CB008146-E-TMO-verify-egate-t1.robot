*** Settings ***
Documentation   This is a keyword file for CB008146-E, part egate verification for t1
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Variables ***
@{t1_UE81_measIdToAddModList}    measId 1,measObjectId 1,reportConfigId 1    measId 2,measObjectId 1,reportConfigId 2
@{t1 UE81_reportConfigId}        reportConfigId 1     reportConfigId 2
@{t1 UE81_eventId}               eventId eventA3     eventId eventA5

@{t1_UE82_measIdToAddModList}    measId 1,measObjectId 1,reportConfigId 1    measId 2,measObjectId 1,reportConfigId 2
...                             measId 3,measObjectId 1,reportConfigId 3    measId 4,measObjectId 1,reportConfigId 4
@{t1_UE82_reportConfigId}        reportConfigId 1     reportConfigId 2     reportConfigId 3     reportConfigId 4
@{t1_UE82_eventId}               eventId eventA2      eventId eventA2      eventId eventA3      eventId eventA5


*** Keywords ***

Verify Egate Log t1
    [Documentation]    [PRIVATE]    verify egate log for t1
    ...       :Autor: Sylvia Schneider
    Log To Console    \nVerify pdu session from UE81
    Prepare Egate File For Verification      ${resultDir}/egate_log1.txt
    Verify Not Present In Egate Log     Event A2
    Verify measIdToAddModList From Egate Log      ${t1_UE81_measIdToAddModList}
    Verify reportConfigToAddModList From Egate Log reportConfigId eventId For t1_UE81

    ${scf_xml}    Parse Xml    ${resultDir}/SCF_final.xml
    ${xpath_NRCELL-10}  Set Variable   managedObject[@distName="${bts_distName}/NRCELL-10"]
    ${rsrp_redir}    Get Element Text   ${scf_xml}
    ...   xpath=.//${xpath_NRCELL-10}/list[@name="a2MeasRedirectSsbRsrp"]/item/p[@name="a2ThresholdRedirectSsbRsrp"]
    ${rsrp_HoSA}    Get Element Text   ${scf_xml}
    ...   xpath=.//${xpath_NRCELL-10}/list[@name="a2MeashoSsbRsrpSA"]/item/p[@name="a2ThresholdhoSsbRsrpSA"]
    ${t1_UE82_a2-Threshold_rsrp}     Create List   a2-Threshold rsrp : ${rsrp_HoSA}    a2-Threshold rsrp : ${rsrp_redir}
    Set Test Variable    @{t1_UE82_a2-Threshold_rsrp}

    Log To Console    \nVerify pdu session from UE82
    Prepare Egate File For Verification      ${resultDir}/egate_log2.txt
    Verify measIdToAddModList From Egate Log      ${t1_UE82_measIdToAddModList}
    Verify reportConfigToAddModList From Egate Log With a2-Threshold For t1_UE82
