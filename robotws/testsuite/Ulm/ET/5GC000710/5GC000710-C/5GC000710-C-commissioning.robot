*** Settings ***
Documentation   This is a keyword file for 5GC000710-C, part commissioning
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
*** Variables ***

${measurement_period_in_min}          5
${cell_distName}                      NRCELL-3


*** Keywords ***

set sw release version
    [Documentation]    [PRIVATE]    set sw release version from gnb sw version
    ...       :Autor: Sylvia Schneider
    @{gnb_sw_version_parts}   split string    ${gnb_swVersion}    _
    set suite variable    ${release}   ${gnb_sw_version_parts}[0]


Update SCF common part
    [Documentation]    [PRIVATE]    Update SCF common part
    ...       :Autor: Sylvia Schneider
    set sw release version
    Log To Console    \nupdate SCF and store in ${resultBaseDir}/SCFC_710C_common.xml
    ${scf_xml}    parse xml    ${resultBaseDir}/SCFC_start.xml
    set suite variable    ${scf_xml}

    FOR   ${nrcell_id}    IN   1   2   3   4
      remove element  ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${nrcell_id}/NRREDRT-0"]/p[@name="redirFreqEutra"]
    END
    remove element  ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}/TRACKINGAREA-200"]

    update single parameter values
    add parameter values in NRCELL object
    update object NRREDRT-0
    create new objects
    create and update SNSSAI object
    FOR   ${object}      ${param}                         ${value}   IN
    ...   /NRMOPR_SA-1   voiceFBMode                      disabled
    ...   ${EMPTY}       actSliceAwareAdmissionCtrl       false
    ...   ${EMPTY}       actSliceAwareScheduler           false
    ...   ${EMPTY}       actSliceAwareSchedulerUlAndEnh   false
    ...   /NRCELL-1      actDtxOptimizedScheduler         false
    ...   /NRCELL-1      actEnhDtxOptimizedScheduler      false
    ...   /NRCELL-2      actDtxOptimizedScheduler         false
    ...   /NRCELL-2      actEnhDtxOptimizedScheduler      false
    ...   /NRCELL-3      actDtxOptimizedScheduler         false
    ...   /NRCELL-3      actEnhDtxOptimizedScheduler      false
    ...   /NRCELL-4      actDtxOptimizedScheduler         false
    ...   /NRCELL-4      actEnhDtxOptimizedScheduler      false
      Log To Console    set in NRBTS-1${object} param ${param} to value "${value}"
      Set Element Text   ${scf_xml}    text=${value}       xpath=.//managedObject[@distName="${bts_distName}${object}"]/p[@name="${param}"]
    END
    Save xml     ${scf_xml}    ${resultBaseDir}/SCFC_710C_common.xml



Update SCF with tc specific parameters
    [Documentation]    [PRIVATE]    Update common SCF with tc specific parameters
    ...       :Autor: Sylvia Schneider
    ${scf_xml}    parse xml    ${resultBaseDir}/SCFC_710C_common.xml
    set suite variable    ${scf_xml}
    Log To Console    set in all gnbPlmn lists param mnc to value "${used_mnc}"
    Set Elements Text   ${scf_xml}    text=${used_mnc}       xpath=.//list[@name="gnbPlmn"]/item/p[@name="mnc"]
    Log To Console    set in NRBTS param actRfspIndex to value "${actRfspIndex}"
    Set Element Text   ${scf_xml}    text=${actRfspIndex}       xpath=.//p[@name="actRfspIndex"]
    Save xml     ${scf_xml}    ${resultDir}/SCFC_710C_tc_specific.xml
    Log To Console    SCF saved ${resultDir}/SCFC_710C_tc_specific.xml


tc specific update and activate SCF and bring tl onAir with ${wtsfile}
    [Documentation]    [PRIVATE]    tc specific update and activate SCF and bring tl onAir
    ...       :Autor: Sylvia Schneider
    Kill WTS services
    Update SCF with tc specific parameters
    Load wts file ${wtsfile}
    ${oam_alias}    connect.Setup OAM http session    node_type=gnb  node_id=${0}
    Log To Console    activate ${resultDir}/SCFC_710C_tc_specific.xml started
    admin.Perform Commissioning
    ...    scf_file=${resultDir}/SCFC_710C_tc_specific.xml
    ...    skip_parameter_relation_errors=False
    ...    timeout=660
    ...    connection=${oam_alias}
    Log To Console    activate ${resultDir}/SCFC_710C_tc_specific.xml finished
    Run Keyword and Ignore Error    connect.Teardown OAM http session    node_type=gnb  node_id=${0}
    Wait until all DUs up
    check all radio units online
    start wireshark trace
    Log To Console    start to bring tl on air without reboot
    Bring Airphone TL to on Air status without reboot
    stop wireshark trace and verify successful xn setup
    Log To Console    save final scf ${resultDir}/SCF_final.xml
    get scf coam   ${resultDir}    SCF_final.xml


update object NRREDRT-0
    [Documentation]    [PRIVATE]    update parameter values of object NRREDRT-0 in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    updating object NRREDRT-0 in all cells
    ${NRREDRT-0_redirFreqNr}     Set Variable    <p name="redirFreqNr">${redirFreqNr-0}</p>
    ${NRREDRT-0_redirSsbScs}     Set Variable    <p name="redirSsbScs">15KHz</p>
    Log To Console    --- adding "${NRREDRT-0_redirFreqNr}"
    Log To Console    --- adding "${NRREDRT-0_redirSsbScs}"
    Log To Console    --- removing parameter redirFreqEutra in object NRREDRT-0
    Log To Console    --- updating parameter redirRat in object NRREDRT-0 with value "nr"

    FOR   ${nrcell_id}    IN   1   2   3   4
       ${xpath_nrcell}   Set Variable   ${bts_distName}/NRCELL-${nrcell_id}
       Add Element     ${scf_xml}    ${NRREDRT-0_redirFreqNr}    xpath=.//managedObject[@distName="${xpath_nrcell}/NRREDRT-0"]
       Add Element     ${scf_xml}    ${NRREDRT-0_redirSsbScs}    xpath=.//managedObject[@distName="${xpath_nrcell}/NRREDRT-0"]
       Set Element Text   ${scf_xml}    text=nr   xpath=.//managedObject[@distName="${xpath_nrcell}/NRREDRT-0"]/p[@name="redirRat"]
    END


update single parameter values
    [Documentation]    [PRIVATE]    update single parameter values in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    updating single parameter values - started

    FOR       ${param}    IN
       ...    reportingIntervalPm
       ...    miNrNRMOP
       ...    miNrRRCC
       ...    miNrRelReportCu
       Log To Console    update parameter "${param}" with value "${measurement_period_in_min}min"
       Set Element Text   ${scf_xml}    text=${measurement_period_in_min}min      xpath=.//p[@name="${param}"]
    END

    FOR      ${param}             ${value}   IN
       ...   actIntraFreqHoSA     true
       ...   actMobilityProfile   true
       ...   actRedirect          true
       ...   actIncXn             true
       Log To Console    update parameter "${param}" with value "${value}"
       Set Element Text   ${scf_xml}    text=${value}         xpath=.//p[@name="${param}"]
    END

    FOR      ${param}                  ${value}                       ${cell_instance}   IN
       ...   a2MeasRedirectEnabled     rsrp                           3
       ...   nrDefMoPrSaDN             ${bts_distName}/NRMOPR_SA-32   3
       ...   nrDefMoPrSaDN             ${bts_distName}/NRMOPR_SA-32   4
       Log To Console    NRCELL-${cell_instance}: update parameter "${param}" with value "${value}"
       Set Element Text  ${scf_xml}  text=${value}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${cell_instance}"]/p[@name="${param}"]
    END

    ${timerXnDataFwdGuard}    Set Variable    <p name="timerXnDataFwdGuard">250</p>
    Log To Console    adding "${timerXnDataFwdGuard}" to object ${bts_distName}
    Add Element        ${scf_xml}     ${timerXnDataFwdGuard}   xpath=.//managedObject[@distName="${bts_distName}"]
    Log To Console    updating single parameter values - finished


add parameter values in NRCELL object
    [Documentation]    [PRIVATE]    add parameter values in NRCELL object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    adding parameter values in NRCELL object - started
    ${absThreshSsbRsrqConsolidation}    Set Variable    <p name="absThreshSsbRsrqConsolidation">2</p>
    Log To Console    adding "${absThreshSsbRsrqConsolidation}" to object ${bts_distName}/NRCELL-3
    Add Element     ${scf_xml}     ${absThreshSsbRsrqConsolidation}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-3"]

    ${nrDefMoPrNsaDN}          Set Variable    <p name="nrDefMoPrNsaDN">${bts_distName}/NRMOPR_NSA-1</p>
    Log To Console    adding "${nrDefMoPrNsaDN}" to all NRCELL objects
    FOR   ${cell_id}   IN   1   2   3   4
        Add Element     ${scf_xml}     ${nrDefMoPrNsaDN}      xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${cell_id}"]
    END

    ${NRPLMNSET_SA-1_plmn}     Set Variable    <p>${bts_distName}/NRPLMN-2</p>
    Log To Console    adding "${NRPLMNSET_SA-1_plmn}" to list "nrPlmnDNList2 of all NRCELL/NRPLMNSET_SA-1 objects
    FOR   ${cell_id}   IN   1   2   3   4
       ${xpath}  Set Variable   managedObject[@distName="${bts_distName}/NRCELL-${cell_id}/NRPLMNSET_SA-1"]/list[@name="nrPlmnDNList"]
       Add Element     ${scf_xml}     ${NRPLMNSET_SA-1_plmn}    xpath=.//${xpath}
    END
    Log To Console    adding parameter values in NRCELL object - finished


create new objects
    [Documentation]    [PRIVATE]    create objects in SCF
    ...       :Autor: Sylvia Schneider
    Create NRREL
    Create NRADJGNB
    Create NRADJNRCELL

    FOR   ${nrcell}  ${nrredrt}  ${redirFreqNr}      ${redirPrio}   IN
    ...   1          1           ${redirFreqNr-1}    2
    ...   2          1           ${redirFreqNr-1}    2
    ...   3          1           ${redirFreqNr-1}    2
    ...   4          1           ${redirFreqNr-1}    2
    ...   1          2           ${redirFreqNr-2}    3
    ...   2          2           ${redirFreqNr-2}    3
    ...   3          2           ${redirFreqNr-2}    3
    ...   4          2           ${redirFreqNr-2}    3
       Create Single NRREDRT Nr   ${nrcell}  ${nrredrt}  ${redirFreqNr}      ${redirPrio}
    END

    FOR   ${nrcell}  ${nrredrt}  ${redirFreqEutra}      ${redirPrio}   IN
    ...   1          3           2000                   4
    ...   2          3           2000                   4
    ...   3          3           2000                   4
    ...   4          3           2000                   4
    ...   1          4           1800                   5
    ...   2          4           1800                   5
    ...   3          4           1800                   5
    ...   4          4           1800                   5
       Create Single NRREDRT Eutra   ${nrcell}  ${nrredrt}  ${redirFreqEutra}      ${redirPrio}
    END

    FOR   ${nrcell}  ${nrredrt}  ${redirFreqNr}      ${redirPrio}   IN
    ...   1          5           126380              6
    ...   2          5           126380              6
       Create Single NRREDRT Nr   ${nrcell}  ${nrredrt}  ${redirFreqNr}      ${redirPrio}
    END

    FOR   ${instance}   IN  1   2   3   4   5   6
       run keyword    Create NRMOPRMA_SA-${instance}
    END

    FOR   ${nrmored}   ${redirFreqNr}      ${redirPrio}   IN
    ...   1            ${redirFreqNr-2}    1
    ...   2            ${SCF.nrarfcnDl}    2
    ...   3            ${redirFreqNr-1}    3
    ...   4            ${redirFreqNr-0}    4
       Create single NRMORED nr    ${nrmored}   ${redirFreqNr}      ${redirPrio}
    END

    FOR   ${nrmored}   ${redirFreqEutra}      ${redirPrio}   IN
    ...   5            2000                   5
    ...   6            1800                   6
       Create single NRMORED eutra    ${nrmored}   ${redirFreqEutra}      ${redirPrio}
    END

    Update NRMOPR_SA-1
    FOR   ${instance}   IN   2   3   32   4   5   6
       run keyword    Create NRMOPR_SA-${instance}
    END

    Create NRMOPR_NSA
    Create NRPLMN-2
    Create XNLINK


Create NRREL
    [Documentation]    [PRIVATE]    create NRREL object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    \nBuilding object ${bts_distName}/NRCELL-3/NRREL-1
    ${NRREL}   Set Variable   <managedObject class="NRREL" distName="${bts_distName}/NRCELL-3/NRREL-1"
    ${NRREL}   Catenate     SEPARATOR=${SPACE}   ${NRREL}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
           ...    <p name="cellIndividualSsbRsrpOffset">-2dB</p>
           ...    <p name="cellIndividualSsbRsrqOffset">-2dB</p>
           ...    <p name="gNbId">38</p>
           ...    <p name="gNbIdLength">28</p>
           ...    <p name="handoverAllowedSA">allowed</p>
           ...    <p name="handoverAllowedSARedCap">forbidden</p>
           ...    <p name="isRplCellForPSCell">false</p>
           ...    <p name="lcrId">1</p>
           ...    <p name="nrDcAllowed">false</p>
           ...    <p name="removeNotAllowed">false</p>
           ...    <list name="gnbPlmn">
           ...    <item>
           ...    <p name="mcc">${SCF.mcc}</p>
           ...    <p name="mnc">${SCF.mnc}</p>
           ...    <p name="mncLength">${SCF.mncLength}</p>
           ...    </item>
           ...    </list>
           ...    </managedObject>
           ${NRREL}   Catenate     SEPARATOR=\n         ${NRREL}   ${line}
    END
    Add Element     ${scf_xml}     ${NRREL}           xpath=.//cmData


Create NRADJGNB
    [Documentation]    [PRIVATE]    create NRADJGNB object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRADJGNB-1
    ${NRADJGNB}    Set Variable  <managedObject class="NRADJGNB" distName="${bts_distName}/NRADJGNB-1"
    ${NRADJGNB}   Catenate     SEPARATOR=${SPACE}   ${NRADJGNB}    version="${SCF.version}" operation="create">
    FOR     ${line}   IN
           ...    <p name="administrativeState">Unlocked</p>
           ...    <p name="gNbIdLength">28</p>
           ...    <p name="gNodeBId">38</p>
           ...    <p name="gNodeBIdCtrl">oamControlled</p>
           ...    <p name="xnLinkRef">1</p>
           ...    <list name="gnbPlmn">
           ...    <item>
           ...    <p name="mcc">${SCF.mcc}</p>
           ...    <p name="mnc">${SCF.mnc}</p>
           ...    <p name="mncLength">${SCF.mncLength}</p>
           ...    </item>
           ...    </list>
           ...    </managedObject>
           ${NRADJGNB}   Catenate     SEPARATOR=\n         ${NRADJGNB}   ${line}
    END
    Add Element     ${scf_xml}     ${NRADJGNB}           xpath=.//cmData


Create NRADJNRCELL
    [Documentation]    [PRIVATE]    create NRADJNRCELL object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRADJNRCELL-1
    ${NRADJNRCELL}    Set Variable   <managedObject class="NRADJNRCELL" distName="${bts_distName}/NRADJNRCELL-1"
    ${NRADJNRCELL}   Catenate     SEPARATOR=${SPACE}   ${NRADJNRCELL}    version="${SCF.version}" operation="create">
    FOR     ${line}   IN
           ...    <p name="cellDepType">SA</p>
           ...    <p name="cellReservedForOperatorUse">notReserved</p>
           ...    <p name="fiveGsTac">${SCF.fiveGsTac}</p>
           ...    <p name="freqBandIndicatorNR">71</p>
           ...    <p name="gNbId">38</p>
           ...    <p name="gNbIdLength">28</p>
           ...    <p name="lcrId">1</p>
           ...    <p name="nrarfcn">${SCF.nrarfcnDl}</p>
           ...    <p name="physCellId">48</p>
           ...    <p name="ssbFrequency">126530</p>
           ...    <list name="gnbPlmn">
           ...    <item>
           ...    <p name="mcc">${SCF.mcc}</p>
           ...    <p name="mnc">${SCF.mnc}</p>
           ...    <p name="mncLength">${SCF.mncLength}</p>
           ...    </item>
           ...    </list>
           ...    </managedObject>
           ${NRADJNRCELL}   Catenate     SEPARATOR=\n         ${NRADJNRCELL}   ${line}
    END
    Add Element     ${scf_xml}     ${NRADJNRCELL}           xpath=.//cmData


Create Single NRREDRT Nr
    [Documentation]    [PRIVATE]    Create Single NRREDRT Nr
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${nrcell}  ${nrredrt}  ${redirFreqNr}      ${redirPrio}
    Log To Console    Building object ${bts_distName}/NRCELL-${nrcell}/NRREDRT-${nrredrt}
    ${new_mo}   Set Variable   <managedObject class="NRREDRT" distName="${bts_distName}/NRCELL-${nrcell}/NRREDRT-${nrredrt}"
    ${new_mo}   Catenate     SEPARATOR=${SPACE}   ${new_mo}         version="${SCF.version}" operation="create">
    FOR     ${line}   IN
           ...    <p name="redirFreqNr">${redirFreqNr}</p>
           ...    <p name="redirPrio">${redirPrio}</p>
           ...    <p name="redirRat">nr</p>
           ...    <p name="redirSsbScs">15KHz</p>
           ...    </managedObject>
           ${new_mo}   Catenate     SEPARATOR=\n         ${new_mo}   ${line}
    END
    Add Element     ${scf_xml}     ${new_mo}           xpath=.//cmData


Create Single NRREDRT Eutra
    [Documentation]    [PRIVATE]    Create Single NRREDRT Eutra
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${nrcell}  ${nrredrt}  ${redirFreqEutra}      ${redirPrio}
    Log To Console    Building object ${bts_distName}/NRCELL-${nrcell}/NRREDRT-${nrredrt}
    ${new_mo}   Set Variable   <managedObject class="NRREDRT" distName="${bts_distName}/NRCELL-${nrcell}/NRREDRT-${nrredrt}"
    ${new_mo}   Catenate     SEPARATOR=${SPACE}   ${new_mo}         version="${SCF.version}" operation="create">
    FOR     ${line}   IN
           ...    <p name="redirFreqEutra">${redirFreqEutra}</p>
           ...    <p name="redirPrio">${redirPrio}</p>
           ...    <p name="redirRat">eutra</p>
           ...    </managedObject>
           ${new_mo}   Catenate     SEPARATOR=\n         ${new_mo}   ${line}
    END
    Add Element     ${scf_xml}     ${new_mo}           xpath=.//cmData


Create NRMOPRMA_SA-1
    [Documentation]    [PRIVATE]    create NRMOPRMA_SA-1 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPRMA_SA-1
    ${NRMOPRMA_SA-1}   Set Variable   <managedObject class="NRMOPRMA_SA" distName="${bts_distName}/NRMOPRMA_SA-1"
    ${NRMOPRMA_SA-1}   Catenate     SEPARATOR=${SPACE}   ${NRMOPRMA_SA-1}         version="${SCF.version}" operation="create">
    FOR     ${line}   IN
           ...    <p name="mobilityProfilePriority">1</p>
           ...    <p name="nrMoPrSaDN">${bts_distName}/NRMOPR_SA-1</p>
           ...    <p name="rfspIndex">1</p>
           ...    <p name="rfspIndexLast">100</p>
           ...    <list name="nrPlmnDNList">
           ...    <p>${bts_distName}/NRPLMN-2</p>
           ...    </list>
           ...    </managedObject>
           ${NRMOPRMA_SA-1}   Catenate     SEPARATOR=\n         ${NRMOPRMA_SA-1}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMOPRMA_SA-1}           xpath=.//cmData


Create NRMOPRMA_SA-2
    [Documentation]    [PRIVATE]    create NRMOPRMA_SA-2 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPRMA_SA-2
    ${NRMOPRMA_SA-2}   Set Variable   <managedObject class="NRMOPRMA_SA" distName="${bts_distName}/NRMOPRMA_SA-2"
    ${NRMOPRMA_SA-2}   Catenate     SEPARATOR=${SPACE}   ${NRMOPRMA_SA-2}         version="${SCF.version}" operation="create">
    FOR     ${line}   IN
           ...    <p name="mobilityProfilePriority">2</p>
           ...    <p name="nrMoPrSaDN">${bts_distName}/NRMOPR_SA-2</p>
           ...    <list name="snssaiList">
           ...    <item>
           ...    <p name="snssaiDN">${bts_distName}/SNSSAI-2</p>
           ...    </item>
           ...    </list>
           ...    </managedObject>
           ${NRMOPRMA_SA-2}   Catenate     SEPARATOR=\n         ${NRMOPRMA_SA-2}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMOPRMA_SA-2}           xpath=.//cmData


Create NRMOPRMA_SA-3
    [Documentation]    [PRIVATE]    create NRMOPRMA_SA-3 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPRMA_SA-3
    ${NRMOPRMA_SA-3}   Set Variable   <managedObject class="NRMOPRMA_SA" distName="${bts_distName}/NRMOPRMA_SA-3"
    ${NRMOPRMA_SA-3}   Catenate     SEPARATOR=${SPACE}   ${NRMOPRMA_SA-3}         version="${SCF.version}" operation="create">
    FOR     ${line}   IN
           ...    <p name="mobilityProfilePriority">3</p>
           ...    <p name="nrMoPrSaDN">${bts_distName}/NRMOPR_SA-3</p>
           ...    <p name="rfspIndex">77</p>
           ...    <p name="rfspIndexLast">88</p>
           ...    <list name="nrPlmnDNList">
           ...    <p>${bts_distName}/NRPLMN-1</p>
           ...    </list>
           ...    <list name="snssaiList">
           ...    <item>
           ...    <p name="snssaiDN">${bts_distName}/SNSSAI-1</p>
           ...    </item>
           ...    </list>
           ...    </managedObject>
           ${NRMOPRMA_SA-3}   Catenate     SEPARATOR=\n         ${NRMOPRMA_SA-3}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMOPRMA_SA-3}           xpath=.//cmData


Create NRMOPRMA_SA-4
    [Documentation]    [PRIVATE]    create NRMOPRMA_SA-4 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPRMA_SA-4
    ${NRMOPRMA_SA-4}   Set Variable   <managedObject class="NRMOPRMA_SA" distName="${bts_distName}/NRMOPRMA_SA-4"
    ${NRMOPRMA_SA-4}   Catenate     SEPARATOR=${SPACE}   ${NRMOPRMA_SA-4}         version="${SCF.version}" operation="create">
    FOR     ${line}   IN
           ...    <p name="mobilityProfilePriority">4</p>
           ...    <p name="nrMoPrSaDN">${bts_distName}/NRMOPR_SA-4</p>
           ...    <p name="rfspIndex">99</p>
           ...    <list name="nrPlmnDNList">
           ...    <p>${bts_distName}/NRPLMN-1</p>
           ...    </list>
           ...    <list name="snssaiList">
           ...    <item>
           ...    <p name="snssaiDN">${bts_distName}/SNSSAI-1</p>
           ...    </item>
           ...    </list>
           ...    </managedObject>
           ${NRMOPRMA_SA-4}   Catenate     SEPARATOR=\n         ${NRMOPRMA_SA-4}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMOPRMA_SA-4}           xpath=.//cmData


Create NRMOPRMA_SA-5
    [Documentation]    [PRIVATE]    create NRMOPRMA_SA-5 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPRMA_SA-5
    ${NRMOPRMA_SA-5}   Set Variable   <managedObject class="NRMOPRMA_SA" distName="${bts_distName}/NRMOPRMA_SA-5"
    ${NRMOPRMA_SA-5}   Catenate     SEPARATOR=${SPACE}   ${NRMOPRMA_SA-5}         version="${SCF.version}" operation="create">
    FOR     ${line}   IN
           ...    <p name="mobilityProfilePriority">5</p>
           ...    <p name="nrMoPrSaDN">${bts_distName}/NRMOPR_SA-5</p>
           ...    <list name="nrPlmnDNList">
           ...    <p>${bts_distName}/NRPLMN-2</p>
           ...    </list>
          ...    </managedObject>
           ${NRMOPRMA_SA-5}   Catenate     SEPARATOR=\n         ${NRMOPRMA_SA-5}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMOPRMA_SA-5}           xpath=.//cmData


Create NRMOPRMA_SA-6
    [Documentation]    [PRIVATE]    create NRMOPRMA_SA-6 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPRMA_SA-6
    ${NRMOPRMA_SA-6}   Set Variable   <managedObject class="NRMOPRMA_SA" distName="${bts_distName}/NRMOPRMA_SA-6"
    ${NRMOPRMA_SA-6}   Catenate     SEPARATOR=${SPACE}   ${NRMOPRMA_SA-6}         version="${SCF.version}" operation="create">
    FOR     ${line}   IN
           ...    <p name="mobilityProfilePriority">6</p>
           ...    <p name="nrMoPrSaDN">${bts_distName}/NRMOPR_SA-6</p>
           ...    <p name="rfspIndex">100</p>
           ...    <list name="nrPlmnDNList">
           ...    <p>${bts_distName}/NRPLMN-1</p>
           ...    </list>
           ...    <list name="snssaiList">
           ...    <item>
           ...    <p name="snssaiDN">${bts_distName}/SNSSAI-1</p>
           ...    </item>
           ...    </list>
          ...    </managedObject>
           ${NRMOPRMA_SA-6}   Catenate     SEPARATOR=\n         ${NRMOPRMA_SA-6}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMOPRMA_SA-6}           xpath=.//cmData


Create single NRMORED nr
    [Documentation]    [PRIVATE]    create NRMOPRMA_SA-6 object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${nrmored}   ${redirFreqNr}      ${redirPrio}
    Log To Console    Building object ${bts_distName}/NRMORED-${nrmored}
    ${new_mo}   Set Variable   <managedObject class="NRMORED" distName="${bts_distName}/NRMORED-${nrmored}"
    ${new_mo}   Catenate     SEPARATOR=${SPACE}   ${new_mo}         version="${SCF.version}" operation="create">
    FOR     ${line}   IN
           ...    <p name="redirFreqNr">${redirFreqNr}</p>
           ...    <p name="redirPrio">${redirPrio}</p>
           ...    <p name="redirRat">nr</p>
           ...    </managedObject>
           ${new_mo}   Catenate     SEPARATOR=\n         ${new_mo}   ${line}
    END
    Add Element     ${scf_xml}     ${new_mo}           xpath=.//cmData


Create single NRMORED eutra
    [Documentation]    [PRIVATE]    create NRMOPRMA_SA-6 object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${nrmored}   ${redirFreqEutra}      ${redirPrio}
    Log To Console    Building object ${bts_distName}/NRMORED-${nrmored}
    ${new_mo}   Set Variable   <managedObject class="NRMORED" distName="${bts_distName}/NRMORED-${nrmored}"
    ${new_mo}   Catenate     SEPARATOR=${SPACE}   ${new_mo}         version="${SCF.version}" operation="create">
    FOR     ${line}   IN
           ...    <p name="redirFreqEutra">${redirFreqEutra}</p>
           ...    <p name="redirPrio">${redirPrio}</p>
           ...    <p name="redirRat">eutra</p>
           ...    </managedObject>
           ${new_mo}   Catenate     SEPARATOR=\n         ${new_mo}   ${line}
    END
    Add Element     ${scf_xml}     ${new_mo}           xpath=.//cmData


Update NRMOPR_SA-1
    [Documentation]    [PRIVATE]    update NRMOPR_SA-1 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Update object ${bts_distName}/NRMOPR_SA-1
    Set Element Text   ${scf_xml}    text=rsrp      xpath=.//managedObject[@distName="${bts_distName}/NRMOPR_SA-1"]/p[@name="a2MeasRedirectEnabled"]
    ${nrMoRedDNList}    Set Variable     <list name="nrMoRedDNList">
    FOR    ${line}   IN
           ...    <p>${bts_distName}/NRMORED-1</p>
           ...    <p>${bts_distName}/NRMORED-2</p>
           ...    <p>${bts_distName}/NRMORED-3</p>
           ...    <p>${bts_distName}/NRMORED-4</p>
           ...    </list>
           ${nrMoRedDNList}    Catenate     SEPARATOR=\n   ${nrMoRedDNList}   ${line}
    END
    Add Element     ${scf_xml}     ${nrMoRedDNList}   xpath=.//managedObject[@distName="${bts_distName}/NRMOPR_SA-1"]


Create NRMOPR_SA-2
    [Documentation]    [PRIVATE]    create NRMOPR_SA-2 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPR_SA-2
    ${NRMOPR_SA}   Set Variable   <managedObject class="NRMOPR_SA" distName="${bts_distName}/NRMOPR_SA-2"
    ${NRMOPR_SA}   Catenate     SEPARATOR=${SPACE}   ${NRMOPR_SA}         version="${SCF.version}" operation="create">
    FOR     ${line}   IN
           ...    <p name="a2MeasRedirectEnabled">rsrpCombined</p>
           ...    <p name="emergencyCallFails">disabled</p>
           ...    <p name="emergencyFBMode">disabled</p>
           ...    <p name="voiceFBMode">disabled</p>
           ...    <list name="nrMoRedDNList">
           ...    <p>${bts_distName}/NRMORED-4</p>
           ...    </list>
           ...    </managedObject>
           ${NRMOPR_SA}   Catenate     SEPARATOR=\n         ${NRMOPR_SA}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMOPR_SA}           xpath=.//cmData


Create NRMOPR_SA-3
    [Documentation]    [PRIVATE]    create NRMOPR_SA-3 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPR_SA-3
    ${NRMOPR_SA}   Set Variable   <managedObject class="NRMOPR_SA" distName="${bts_distName}/NRMOPR_SA-3"
    ${NRMOPR_SA}   Catenate     SEPARATOR=${SPACE}   ${NRMOPR_SA}         version="${SCF.version}" operation="create">
    FOR     ${line}   IN
           ...    <p name="a2MeasRedirectEnabled">rsrp</p>
           ...    <p name="emergencyCallFails">disabled</p>
           ...    <p name="emergencyFBMode">disabled</p>
           ...    <p name="voiceFBMode">disabled</p>
           ...    <list name="nrMoRedDNList">
           ...    <p>${bts_distName}/NRMORED-1</p>
           ...    </list>
           ...    </managedObject>
           ${NRMOPR_SA}   Catenate     SEPARATOR=\n         ${NRMOPR_SA}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMOPR_SA}           xpath=.//cmData


Create NRMOPR_SA-32
    [Documentation]    [PRIVATE]    create NRMOPR_SA-32 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPR_SA-32
    ${NRMOPR_SA}   Set Variable   <managedObject class="NRMOPR_SA" distName="${bts_distName}/NRMOPR_SA-32"
    ${NRMOPR_SA}   Catenate     SEPARATOR=${SPACE}   ${NRMOPR_SA}         version="${SCF.version}" operation="create">
    FOR     ${line}   IN
           ...    <p name="a2MeasRedirectEnabled">none</p>
           ...    <p name="emergencyCallFails">disabled</p>
           ...    <p name="emergencyFBMode">disabled</p>
           ...    <p name="voiceFBMode">disabled</p>
           ...    </managedObject>
           ${NRMOPR_SA}   Catenate     SEPARATOR=\n         ${NRMOPR_SA}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMOPR_SA}           xpath=.//cmData


Create NRMOPR_SA-4
    [Documentation]    [PRIVATE]    create NRMOPR_SA-4 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPR_SA-4
    ${NRMOPR_SA}   Set Variable   <managedObject class="NRMOPR_SA" distName="${bts_distName}/NRMOPR_SA-4"
    ${NRMOPR_SA}   Catenate     SEPARATOR=${SPACE}   ${NRMOPR_SA}         version="${SCF.version}" operation="create">
    FOR     ${line}   IN
           ...    <p name="a2MeasRedirectEnabled">rsrp</p>
           ...    <p name="emergencyCallFails">disabled</p>
           ...    <p name="emergencyFBMode">disabled</p>
           ...    <p name="voiceFBMode">disabled</p>
           ...    <list name="nrMoRedDNList">
           ...    <p>${bts_distName}/NRMORED-1</p>
           ...    <p>${bts_distName}/NRMORED-2</p>
           ...    <p>${bts_distName}/NRMORED-3</p>
           ...    <p>${bts_distName}/NRMORED-4</p>
           ...    </list>
           ...    </managedObject>
           ${NRMOPR_SA}   Catenate     SEPARATOR=\n         ${NRMOPR_SA}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMOPR_SA}           xpath=.//cmData


Create NRMOPR_SA-5
    [Documentation]    [PRIVATE]    create NRMOPR_SA-5 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPR_SA-5
    ${NRMOPR_SA}   Set Variable   <managedObject class="NRMOPR_SA" distName="${bts_distName}/NRMOPR_SA-5"
    ${NRMOPR_SA}   Catenate     SEPARATOR=${SPACE}   ${NRMOPR_SA}         version="${SCF.version}" operation="create">
    FOR     ${line}   IN
           ...    <p name="a2MeasRedirectEnabled">rsrp</p>
           ...    <p name="emergencyCallFails">disabled</p>
           ...    <p name="emergencyFBMode">disabled</p>
           ...    <p name="voiceFBMode">disabled</p>
           ...    <list name="nrMoRedDNList">
           ...    <p>${bts_distName}/NRMORED-1</p>
           ...    </list>
           ...    </managedObject>
           ${NRMOPR_SA}   Catenate     SEPARATOR=\n         ${NRMOPR_SA}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMOPR_SA}           xpath=.//cmData


Create NRMOPR_SA-6
    [Documentation]    [PRIVATE]    create NRMOPR_SA-6 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPR_SA-6
    ${NRMOPR_SA}   Set Variable   <managedObject class="NRMOPR_SA" distName="${bts_distName}/NRMOPR_SA-6"
    ${NRMOPR_SA}   Catenate     SEPARATOR=${SPACE}   ${NRMOPR_SA}         version="${SCF.version}" operation="create">
    FOR     ${line}   IN
           ...    <p name="a2MeasRedirectEnabled">rsrp</p>
           ...    <p name="emergencyCallFails">disabled</p>
           ...    <p name="emergencyFBMode">disabled</p>
           ...    <p name="voiceFBMode">disabled</p>
           ...    <list name="nrMoRedDNList">
           ...    <p>${bts_distName}/NRMORED-5</p>
           ...    <p>${bts_distName}/NRMORED-6</p>
           ...    </list>
           ...    </managedObject>
           ${NRMOPR_SA}   Catenate     SEPARATOR=\n         ${NRMOPR_SA}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMOPR_SA}           xpath=.//cmData


Create NRMOPR_NSA
    [Documentation]    [PRIVATE]    create NRMOPR_NSA-1 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPR_NSA-1
    ${NRMOPR_NSA-1}   Set Variable   <managedObject class="NRMOPR_NSA" distName="${bts_distName}/NRMOPR_NSA-1"
    ${NRMOPR_NSA-1}   Catenate     SEPARATOR=${SPACE}   ${NRMOPR_NSA-1}         version="${SCF.version}" operation="create">
    FOR     ${line}   IN
           ...    <p name="a1MeashoEnabled">none</p>
           ...    <p name="a2MeashoEnabled">none</p>
           ...    </managedObject>
           ${NRMOPR_NSA-1}   Catenate     SEPARATOR=\n         ${NRMOPR_NSA-1}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMOPR_NSA-1}           xpath=.//cmData


Create NRPLMN-2
    [Documentation]    [PRIVATE]    create NRPLMN-2 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRPLMN-2
    ${NRPLMN-2}   Set Variable   <managedObject class="NRPLMN" distName="${bts_distName}/NRPLMN-2"
    ${NRPLMN-2}   Catenate     SEPARATOR=${SPACE}   ${NRPLMN-2}         version="${SCF.version}" operation="create">
    FOR     ${line}   IN
           ...    <p name="mcc">${SCF.mcc}</p>
           ...    <p name="mnc">388</p>
           ...    <p name="mncLength">${SCF.mncLength}</p>
           ...    </managedObject>
           ${NRPLMN-2}   Catenate     SEPARATOR=\n         ${NRPLMN-2}   ${line}
    END
    Add Element     ${scf_xml}     ${NRPLMN-2}           xpath=.//cmData


create and update SNSSAI object
    [Documentation]    [PRIVATE]    update SNSSAI-1 and create SNSSAI-2 object in SCF
    ...       :Autor: Sylvia Schneider
    Add Element     ${scf_xml}     <p>${bts_distName}/NRPLMN-2</p>
    ...   xpath=.//managedObject[@distName="${bts_distName}/SNSSAI-1"]/list[@name="nrPlmnDNList"]

    ${TRACKINGAREA}   Set Variable   <managedObject class="TRACKINGAREA" distName="${bts_distName}/TRACKINGAREA-200"
    ${TRACKINGAREA}   Catenate     SEPARATOR=${SPACE}   ${TRACKINGAREA}         version="${SCF.version}" operation="create">
    FOR     ${line}   IN
           ...    <p name="fiveGsTac">200</p>
           ...    <list name="snssaiList">
           ...    <item>
           ...    <p name="snssaiDN">MRBTS-1/NRBTS-1/SNSSAI-1</p>
           ...    </item>
           ...    <item>
           ...    <p name="snssaiDN">MRBTS-1/NRBTS-1/SNSSAI-2</p>
           ...    </item>
           ...    </list>
           ...    </managedObject>
           ${TRACKINGAREA}   Catenate     SEPARATOR=\n         ${TRACKINGAREA}   ${line}
    END
    Add Element     ${scf_xml}     ${TRACKINGAREA}           xpath=.//cmData

    ${SNSSAI-2}   Set Variable   <managedObject class="SNSSAI" distName="${bts_distName}/SNSSAI-2"
    ${SNSSAI-2}   Catenate     SEPARATOR=${SPACE}   ${SNSSAI-2}         version="${SCF.version}" operation="create">
    FOR     ${line}   IN
           ...    <p name="administrativeState">Unlocked</p>
           ...    <p name="sd">13714342</p>
           ...    <p name="sst">1</p>
           ...    <list name="nrPlmnDNList">
           ...    <p>${bts_distName}/NRPLMN-1</p>
           ...    <p>${bts_distName}/NRPLMN-2</p>
           ...    </list>
           ...    </managedObject>
           ${SNSSAI-2}   Catenate     SEPARATOR=\n         ${SNSSAI-2}   ${line}
    END
    Add Element     ${scf_xml}     ${SNSSAI-2}           xpath=.//cmData


Create XNLINK
    [Documentation]    [PRIVATE]    create XNLINK object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/XNLINK-1
    ${new_obj}    Set Variable   <managedObject class="XNLINK" distName="${bts_distName}/XNLINK-1"
    ${new_obj}   Catenate     SEPARATOR=${SPACE}   ${new_obj}    version="${SCF.version}" operation="create">
    FOR     ${line}   IN
           ...    <p name="cPlaneIpAddr">${wts_GNB3_XN_ADDR}</p>
           ...    <p name="cPlaneIpAddrCtrl">oamControlled</p>
           ...    </managedObject>
           ${new_obj}   Catenate     SEPARATOR=\n         ${new_obj}   ${line}
    END
    Add Element     ${scf_xml}     ${new_obj}   xpath=.//cmData
