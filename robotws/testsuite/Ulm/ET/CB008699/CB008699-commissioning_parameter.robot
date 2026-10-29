*** Settings ***
Documentation   This is a keyword file for CB008699, part commissioning, update and add parameters
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

Library    taf.config.scf            WITH NAME    scf

*** Keywords ***

update single nrbts parameter
    [Arguments]   ${param}   ${value}
    Log To Console    set single nrbts parameter "${param}" to value "${value}"
    Set Element Text   ${scf_xml}    text=${value}       xpath=.//p[@name="${param}"]


add nonContentRachAcFullConfigHo tNgRelocExecDeltL timerXnDataFwdGuard to mrbts object
    ${nonContentRachAcFullConfigHo}    set variable    <p name="nonContentRachAcFullConfigHo">true</p>
    Add Element        ${scf_xml}     ${nonContentRachAcFullConfigHo}   xpath=.//managedObject[@distName="${bts_distName}"]
    ${tNgRelocExecDeltL}    set variable    <p name="tNgRelocExecDeltL">5000</p>
    Add Element        ${scf_xml}     ${tNgRelocExecDeltL}   xpath=.//managedObject[@distName="${bts_distName}"]
    ${timerXnDataFwdGuard}    set variable    <p name="timerXnDataFwdGuard">20</p>
    Add Element        ${scf_xml}     ${timerXnDataFwdGuard}   xpath=.//managedObject[@distName="${bts_distName}"]


add measGapSelectionSA absThreshSsbRsrpConsolidation sMeasConfigSsbRsrp to nrcell-1
    ${xpath_NRCELL-1}   set Variable    managedObject[@distName="${bts_distName}/NRCELL-1"]
    ${absThreshSsbRsrpConsolidation}    set variable    <p name="absThreshSsbRsrpConsolidation">10</p>
    Add Element        ${scf_xml}    ${absThreshSsbRsrpConsolidation}   xpath=.//${xpath_NRCELL-1}
    ${measGapSelectionSA}    set variable    <p name="measGapSelectionSA">favourUeThroughput</p>
    Add Element        ${scf_xml}    ${measGapSelectionSA}   xpath=.//${xpath_NRCELL-1}
    ${sMeasConfigSsbRsrp}    set variable    <p name="sMeasConfigSsbRsrp">10</p>
    Add Element        ${scf_xml}     ${sMeasConfigSsbRsrp}   xpath=.//${xpath_NRCELL-1}


update single nrcell-1 parameter
    [Arguments]   ${param}   ${value}
    Log To Console    set in NRCELL-1 single parameter "${param}" to value "${value}"
    Set Element Text   ${scf_xml}    text=${value}       xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]/p[@name="${param}"]


update single nrpmnrl parameter
    [Arguments]   ${param}   ${value}
    Log To Console    set single nrplmrnl parameter "${param}" to value "${value}"
    Set Element Text   ${scf_xml}    text=${value}       xpath=.//managedObject[@distName="${bts_distName}/NRPMRNL-1"]/p[@name="${param}"]


set parameter actFullRRCConfigurationSaHo to ${value}
    [Documentation]    [PRIVATE]    set parameter actFullRRCConfigurationSaHo
    ...       :Autor: Sylvia Schneider
    Log To Console    \ndelta commissioning of parameter started
    Log To Console    actFullRRCConfigurationSaHo set to value ${value}
    ${delta_SCF_template}    Get File       ${CURDIR}/delta_actFullRRCConfigurationSaHo.xml
    ${delta_SCF_update}      Replace Variables     ${delta_SCF_template}
    Create File    ${resultDir}/delta_actFullRRCConfigurationSaHo.xml    ${delta_SCF_update}
    Execute delta commissioning    delta_scf_template=${resultDir}/delta_actFullRRCConfigurationSaHo.xml
    ...    resultDir=${resultDir}    timeout=360
    Log To Console    delta commissioning of parameter finished


set parameter actForceFullRRCConfigurationSaHo to ${value}
    [Documentation]    [PRIVATE]    set parameter actForceFullRRCConfigurationSaHo
    ...       :Autor: Sylvia Schneider
    Log To Console    \ndelta commissioning of parameter started
    Log To Console    actForceFullRRCConfigurationSaHo set to value ${value}
    ${delta_SCF_template}    Get File       ${CURDIR}/delta_actForceFullRRCConfigurationSaHo.xml
    ${delta_SCF_update}      Replace Variables     ${delta_SCF_template}
    Create File    ${resultDir}/delta_actForceFullRRCConfigurationSaHo.xml    ${delta_SCF_update}
    Execute delta commissioning    delta_scf_template=${resultDir}/delta_actForceFullRRCConfigurationSaHo.xml
    ...    resultDir=${resultDir}    timeout=360
    Log To Console    delta commissioning of parameter finished


remove nrbts parameter nonContentRachAcFullConfigHo
    [Documentation]    [PRIVATE]    remove nrbts parameter nonContentRachAcFullConfigHo
    ...       :Autor: Sylvia Schneider
    Log To Console    remove nrbts parameter nonContentRachAcFullConfigHo
#    remove element   ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}"]/p[@name="nonContentRachAcFullConfigHo"]
    scf.load_scf      ${resultBaseDir}/SCFC_CB8699_common.xml
    scf.remove_element_from_scf    dist_name=${bts_distName}       p_name=nonContentRachAcFullConfigHo
    scf.save_scf      ${resultDir}/SCFC_CB8699_after_remove.xml
