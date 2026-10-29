*** Settings ***
Documentation   This is a keyword file for CB008699-FR2, part commissioning
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

Resource        CB008699-commissioning_objects_lists.robot
Resource        CB008699-commissioning_parameter.robot

*** Variables ***
${measurement_period_in_min}     5

*** Keywords ***

activate SCF and bring tl onAir FR2
    [Documentation]    [PRIVATE]    activate SCF and bring tl onAir
    ...       :Autor: Sylvia Schneider
    Kill WTS services
    ${oam_alias}    connect.Setup OAM http session    node_type=gnb  node_id=${0}
    Log To Console    activate ${resultBaseDir}/SCFC_CB8699_FR2.xml started
    admin.Perform Commissioning
    ...    scf_file=${resultBaseDir}/SCFC_CB8699_FR2.xml
    ...    skip_parameter_relation_errors=False
    ...    timeout=660
    ...    connection=${oam_alias}
    Log To Console    activate ${resultBaseDir}/SCFC_CB8699_FR2.xml finished
    Run Keyword and Ignore Error    connect.Teardown OAM http session    node_type=gnb  node_id=${0}
    check all radio units online
    Log To Console    start to bring tl on air without reboot
    Bring Airphone TL to on Air status without reboot
    Log To Console    save final scf ${resultDir}/SCF_final_FR2.xml
    get scf coam   ${resultDir}    SCF_final_FR2.xml


Update SCF file for TC CB008699-FR2
    [Documentation]    [PRIVATE]    update SCF for common part
    ...       :Autor: Sylvia Schneider
    Log To Console    \nstart update SCF common part
    ${scf_xml}    parse xml    ${resultBaseDir}/SCFC_start.xml
    set suite variable    ${scf_xml}

    FOR   ${param}   ${value}  IN
    ...    actForceFullRRCConfigurationSaHo          enabled
    ...    actFullRRCConfigurationSaHo               enabled
    ...    actInterFreqHoSA                    false
    ...    actIntraFreqHoSA                    true
     ...    actMeasurementProfile               SA
    ...    actRfspIndex                        true
        update single nrbts parameter   ${param}   ${value}
    END

    Create NRADJGNB
    Create FR2-NRADJNRCELL
    Create FR2-NRREL
    Create FR2-NRMEAS_PROFILE
    Create FR2-NRMEASPR_IAF
    Create FR2-NRMEASPR_MA_SA
    Create XNLINK

    Add RF2-Lists a3MeasSsbRsrp a3MeasSsbRsrq a5MeasSsbRsrp a5MeasSsbRsrq measPrMaSAList

    FOR    ${param}                    ${value}  IN
    ...    a3MeasEnabled               rsrp
    ...    a5MeasEnabled               rsrp
    ...    maxNumOfNonGBRBearersSA     4
       update single nrcell-1 parameter   ${param}   ${value}
    END

    FOR   ${param}                       ${value}  IN
    ...    miNrMeasProfileIntraFreq      ${measurement_period_in_min}min
    ...    miNrMeasProfileMappingSA      ${measurement_period_in_min}min
    ...    miNrRelReportCu               ${measurement_period_in_min}min
       update single nrpmnrl parameter       ${param}   ${value}
    END

    ${timerXnDataFwdGuard}    set variable    <p name="timerXnDataFwdGuard">250</p>
    Add Element        ${scf_xml}     ${timerXnDataFwdGuard}   xpath=.//managedObject[@distName="${bts_distName}"]

    ${xpath_NRCELL-1}   set Variable    managedObject[@distName="${bts_distName}/NRCELL-1"]
    FOR   ${element}   IN
    ...   <p name\="absThreshSsbRsrpConsolidation">0</p>
    ...   <p name\="absThreshSsbRsrqConsolidation">0</p>
    ...   <p name\="filterCoeffSsbRsrp">fc4</p>
    ...   <p name\="filterCoeffSsbRsrq">fc4</p>
    ...   <p name\="sMeasConfigSsbRsrp">0</p>
       Add Element        ${scf_xml}    ${element}   xpath=.//${xpath_NRCELL-1}
    END

    Save xml     ${scf_xml}    ${resultBaseDir}/SCFC_CB8699_FR2.xml
    Log To Console    \nsave updated SCF common part ${resultBaseDir}/SCFC_CB8699_FR2.xml


allow handoverset by setting actARPBasedAC to value handovers
    [Documentation]    [PRIVATE]    delta commissioning to allow handoverset by setting actARPBasedAC to value handovers
    ...       :Autor: Sylvia Schneider
    Log To Console    \ndelta commissioning to allow handoverset by setting actARPBasedAC to value handovers

    ${oam_alias}    connect.Setup OAM http session    node_type=gnb  node_id=${0}
    admin.perform delta recommissioning
    ...    ${CURDIR}/actARPBasedAC_allow_handover.json
    ...    should_activate=True
    ...    timeout=300
    ...    connection=${oam_alias}
    connect.Teardown OAM http session    node_type=gnb  node_id=${0}

    Log To Console    delta commissioning finished
    get scf coam    ${resultDir}    SCFC_delta_modify_IAF-3_values.xml
    Log To Console    SCF after delta commissioning saved ${resultDir}/SCFC_delta_modify_IAF-3_values.xml
