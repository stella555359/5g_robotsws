*** Settings ***
Documentation   This is a keyword file for CB008146-E, part commissioning
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

Resource        ${CURDIR}/CB008146-E-TMO-commissioning-objects.robot
Resource        ${CURDIR}/CB008146-E-TMO-commissioning-lists.robot


*** Variables ***

${measurement_period_in_min}          5


*** Keywords ***

Set SW Release Version
    [Documentation]    [PRIVATE]    set sw release version from gnb sw version
    ...       :Autor: Sylvia Schneider
    @{gnb_sw_version_parts}   String.Split String    ${gnb_swVersion}    _
    Set Suite Variable    ${RELEASE}   ${gnb_sw_version_parts}[0]


Update SCF Common Part
    [Documentation]    [PRIVATE]    Update SCF common part
    ...       :Autor: Sylvia Schneider
    Set SW Release Version
    Log To Console    \nupdate SCF and store in ${resultBaseDir}/SCFC_CB008146E_common.xml

    ${scf_xml}    Parse XML    ${resultBaseDir}/SCFC_start.xml
    Set Suite Variable    ${SCF_XML}

    Update Single Parameter Values
    Update List Values
    Add And Remove Parameter Values In NRCELL Object
    Create New Objects
    Update SNSSAI And TRACKINGAREA
    Save XML     ${scf_xml}    ${resultBaseDir}/SCFC_CB008146E_common.xml


Update SCF With TC Specific Parameters
    [Documentation]    [PRIVATE]    Update common SCF with tc specific parameters
    ...       :Autor: Sylvia Schneider
    ${scf_xml}    Parse XML    ${resultBaseDir}/SCFC_CB008146E_common.xml
    Set Suite Variable    ${SCF_XML}
    Log To Console    set in NRBTS param actRfspIndex to value "${actRfspIndex}"
    Set Element Text   ${scf_xml}    text=${actRfspIndex}       xpath=.//p[@name="actRfspIndex"]
    Save XML     ${scf_xml}    ${resultDir}/SCFC_CB008146E_tc_specific.xml
    Log To Console    SCF saved ${resultDir}/SCFC_CB008146E_tc_specific.xml


TC Specific Update And Activate SCF And Bring TL onAir With ${wtsfile}
    [Documentation]    [PRIVATE]    tc specific update and activate SCF and bring tl onAir
    ...       :Autor: Sylvia Schneider
    Kill WTS services
    Update SCF With TC Specific Parameters

    IF    '${wtsfile}' == 'plmn2'    Update Plmns

    Load WTS File    ${wtsfile}
    ${oam_alias}    connect.Setup OAM HTTP Session    node_type=gnb  node_id=${0}
    Log To Console    activate ${resultDir}/SCFC_CB008146E_tc_specific.xml started
    admin.Perform Commissioning
    ...    scf_file=${resultDir}/SCFC_CB008146E_tc_specific.xml
    ...    skip_parameter_relation_errors=False
    ...    timeout=660
    ...    connection=${oam_alias}
    Log To Console    activate ${resultDir}/SCFC_CB008146E_tc_specific.xml finished
    Run Keyword And Ignore Error    connect.Teardown OAM HTTP Session    node_type=gnb  node_id=${0}
    Wait Until All DUs Up
    Check All Radio Units Online
    Start Wireshark Trace
    Log To Console    start to bring tl on air without reboot
    Bring Airphone TL To On Air Status Without Reboot
    Stop Wireshark Trace And Verify Successful Xn Setup
    Log To Console    save final scf ${resultDir}/SCF_final.xml
    Get SCF COAM   ${resultDir}    SCF_final.xml


Update Plmns
    [Documentation]    [PRIVATE]    Update Plmns
    ...       :Autor: Sylvia Schneider
    Log To Console    updating plmn values in NRADJGNB-1, NRADJNRCELL-2 upto 5, all NRREL of NRCELL-10
    Log To Console    set mcc to 311, set mnc to 490
    ${scf_xml}    Parse XML    ${resultDir}/SCFC_CB008146E_tc_specific.xml
    FOR   ${object}   IN
    ...   NRADJGNB-1
    ...   NRADJNRCELL-2
    ...   NRADJNRCELL-3
    ...   NRADJNRCELL-4
    ...   NRADJNRCELL-5
    ...   NRCELL-10/NRREL-1
    ...   NRCELL-10/NRREL-2
    ...   NRCELL-10/NRREL-3
    ...   NRCELL-10/NRREL-4
       ${xpath}   Set Variable   managedObject[@distName="MRBTS-1/NRBTS-1/${object}"]/list[@name="gnbPlmn"]/item
       Set Elements Text   ${scf_xml}    text=311   xpath=.//${xpath}/p[@name="mcc"]
       Set Elements Text   ${scf_xml}    text=490   xpath=.//${xpath}/p[@name="mnc"]
    END
    Save XML     ${scf_xml}    ${resultDir}/SCFC_CB008146E_tc_specific.xml


Update Single Parameter Values
    [Documentation]    [PRIVATE]    update single parameter values in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    updating single parameter values - started

    FOR       ${param}    IN
       ...    reportingIntervalPm
       ...    miNrNRMOP
       ...    miNrRelReportCu
       Log To Console    set parameter "${param}" to value "${measurement_period_in_min}min"
       Set Element Text   ${scf_xml}    text=${measurement_period_in_min}min      xpath=.//p[@name="${param}"]
    END

    FOR      ${param}                           ${value}   IN
       ...   actInterFreqHoSA                   true
       ...   actIntraFreqHoSA                   true
       ...   actMobilityProfile                 true
       ...   actRedirect                        true
       ...   actIncXn                           true
       ...   actSliceNumExt                     false
       ...   actSliceAwareScheduler             false
       ...   actSliceAwareSchedulerUlAndEnh     false
       ...   actA2SgnbRelease                   false
       ...   actFullPlmnList                    false
       ...   actInterMeNBMobility               false
       ...   actInterRatHoSA                    false
       ...   actMobilityRetryToSecondBestCell   false
       ...   rrcReestabTypeSA                   deactivated
       ...   actInterGnbRREPreparedCell         false
       ...   actInternalTrace                   true
       Log To Console    set parameter "${param}" to value "${value}"
       Set Element Text   ${scf_xml}    text=${value}         xpath=.//p[@name="${param}"]
    END

    ${xpath_nrcell10}    Set Variable   managedObject[@distName="${bts_distName}/NRCELL-10"]
    FOR      ${param}                        ${value}   IN
       ...   a1MeashoEnabledSA               rsrp
       ...   a2MeashoEnabledSA               rsrp
       ...   a2MeasRedirectEnabled           rsrp
       ...   actEnhancedVoNR                 true
       ...   actVoNR                         true
       ...   actVoNrMobilityThresholds       VoNrMobilityThresholds
       ...   measGapSelection                balancedChoice
       ...   actVoNR                 true
       Log To Console    ${xpath_nrcell10} - set parameter "${param}" to value "${value}"
       Set Element Text   ${scf_xml}    text=${value}         xpath=.//${xpath_nrcell10}/p[@name="${param}"]
    END

    Set Element Text   ${scf_xml}    text=t32      xpath=.//managedObject[@distName="${bts_distName}/NRDRB_RLC_AM-1"]/p[@name="ulMaxRetxThreshold"]
    Log To Console    updating single parameter values - finished


Add And Remove Parameter Values In NRCELL Object
    [Documentation]    [PRIVATE]    add parameter values in NRCELL object in SCF
    ...       :Autor: Sylvia Schneider

    ${NRPLMNSET_SA-1_plmn}     Set Variable    <p>${bts_distName}/NRPLMN-2</p>
    ${nrDefMoPrNsaDN}          Set Variable    <p name="nrDefMoPrNsaDN">${bts_distName}/NRMOPR_NSA-1</p>
    ${nrDefMoPrSaDN}  Set Variable  <p name="nrDefMoPrSaDN">${bts_distName}/NRMOPR_SA-32</p>
    Log To Console    adding "${NRPLMNSET_SA-1_plmn}" to all cell objects
    Log To Console    adding "${nrDefMoPrNsaDN}" to all cell objects
    Log To Console    adding "${nrDefMoPrSaDN}" to all cell objects
    FOR   ${cell}   IN RANGE   1  13
       ${xpath}  set variable  managedObject[@distName="${bts_distName}/NRCELL-${cell}/NRPLMNSET_SA-1"]
       Add Element     ${scf_xml}     ${NRPLMNSET_SA-1_plmn}   xpath=.//${xpath}/list[@name="nrPlmnDNList"]
       Add Element     ${scf_xml}     ${nrDefMoPrNsaDN}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${cell}"]
       Add Element     ${scf_xml}     ${nrDefMoPrSaDN}    xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${cell}"]
    END

    ${xpath_NRCELL-10}  Set Variable   managedObject[@distName="${bts_distName}/NRCELL-10"]

    ${absThreshSsbRsrqConsolidation}    set variable    <p name="absThreshSsbRsrqConsolidation">2</p>
    Add Element     ${scf_xml}     ${absThreshSsbRsrqConsolidation}   xpath=.//${xpath_NRCELL-10}
    Set Element Text    ${scf_xml}   text=balancedChoice   xpath=.//${xpath_NRCELL-10}/p[@name="measGapSelectionSA"]
    Set Element Text    ${scf_xml}   text=ms0              xpath=.//${xpath_NRCELL-10}/p[@name="mgta"]

