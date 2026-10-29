*** Settings ***
Documentation   This is a keyword file for 5GC000711-A, part commissioning voice
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
*** Variables ***

${measurement_period_in_min}          5
${class_NRCELL}                       class="com.nokia.srbts.nrbts:NRCELL"
${cell_distName}                      NRCELL-1


*** Keywords ***

Update SCF voice common part
    [Documentation]    [PRIVATE]    Update SCF voice common part
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate SCF and store in ${resultBaseDir}/SCFC_711A_voice.xml
    ${scf_xml}    parse xml    ${resultBaseDir}/SCFC_start.xml
    set suite variable    ${scf_xml}
    Log To Console    remove in all cells object "NRPLMNSET_NSA-1"
    FOR   ${cell_id}   IN   1   2   3  4
       remove element   ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${cell_id}/NRPLMNSET_NSA-1"]
    END

    Log To Console    set actSib1ForNsaCell to false in all cells
    Set Elements Text   ${scf_xml}    text=false      xpath=.//p[@name="actSib1ForNsaCell"]

    FOR   ${param}                          ${value}   IN
    ...   actNrAutSgnbAddCplSlCellDetRec    false
    ...   actNrAutUeCtxStpRtSlCellDetRec    false
    ...   actNrAutDegAdmCtrlSlCellDetRec    false
    ...   actA2SgnbRelease                  false
    ...   actInterMeNBMobility              false
    ...   actIntraMeNBMobility              false
    ...   actMobilityRetryToSecondBestCell  false
    ...   actMultiDrbNSA                    false
    ...   periodicalDataUsageReportTimer    0
       Log To Console    set parameter ${param} to ${value}
       Set Element Text   ${scf_xml}    text=${value}      xpath=.//p[@name="${param}"]
    END

    Log To Console    \nset actDynUlDataSplitMode to false in all cells
    Set Elements Text   ${scf_xml}    text=false           xpath=.//p[@name="actDynUlDataSplitMode"]

    Log To Console    set actVoiceFallbackDuringHOPrep to disabled
    remove element   ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}"]/list[@name="actVoiceFallbackDuringHOPrep"]
    ${new_list}  set variable  <list name="actVoiceFallbackDuringHOPrep">\n<p>disabled</p>\n</list>
    Add Element     ${scf_xml}     ${new_list}           xpath=.//managedObject[@distName="${bts_distName}"]

    FOR   ${param}                        ${value}     IN
    ...   actVoNRIncCodingGain            false
    ...   actTargetBlerVoNR               false
    ...   actMaxInitDeltaCqiClampVoNR     false
    ...   actDataForwardingForVoNr        deactivated
       Log To Console    set parameter ${param} to ${value}
       Set Element Text   ${scf_xml}    text=${value}      xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]/p[@name="${param}"]
    END

    update single parameter values
    Update NRCELL parameters
    create new objects
    Add Lists voice
    Save xml     ${scf_xml}    ${resultBaseDir}/SCFC_711A_voice.xml


Add Lists voice
    [Documentation]    [PRIVATE]    Update SCF voice with lists
    ...       :Autor: Sylvia Schneider
    FOR    ${list}   IN
    ...    a1MeashoSsbRsrpSA
    ...    a1MeashoSsbRsrqSA
    ...    a2MeashoSsbRsrpSA
    ...    a2MeashoSsbRsrqSA
    ...    nrhoirDNList
    ...    emergencyCallRestrictions
        run keyword      Create List ${list}
    END


Update SCF voice with tc specific parameters
    [Documentation]    [PRIVATE]    Update SCF voice with tc specific parameters
    ...       :Autor: Sylvia Schneider
    Log To Console    \nstart update SCF with tc specific parameter
    ${scf_xml}    parse xml    ${resultBaseDir}/SCFC_711A_voice.xml
    set suite variable    ${scf_xml}
    FOR    ${param}    IN
    ...    nonContentRachAcFullConfigHo
    ...    actNormVCFallback
    ...    actRedirect
    ...    actVoFallBackLteB1MeaBaRedir
        Log To Console    ${param} set to value ${${param}}
        Set Element Text   ${scf_xml}    text=${${param}}    xpath=.//p[@name="${param}"]
    END

    ${xpath_NRCELL-1}   set Variable    managedObject[@distName="${bts_distName}/NRCELL-1"]
    FOR    ${param}    IN
    ...    maxNumOfCaUsersNRCell
    ...    maxNumOfRrcSA
    ...    maxNumOfSCellAlloc
    ...    maxNumOfUsersPerNRCell
    ...    maxNumOfNrDcSnUsers
    ...    maxNumOfUsersPerCell
    ...    voiceFBMode
    ...    actEnhancedVoNR
    ...    actVoNR
    ...    actVoNrMobilityThresholds
    ...    actEmergencyCall
    ...    emergencyCallLimServ
    ...    numOfRadioResReservForEmergency
        Log To Console    ${param} set to value ${${param}}
        Set Element Text   ${scf_xml}    text=${${param}}    xpath=.//${xpath_NRCELL-1}/p[@name="${param}"]
    END

    ${xpath_NRDU-1}   set Variable    managedObject[@distName="${bts_distName}/NRDU-1"]
    Set Element Text   ${scf_xml}    text=${numOfDrbsReservForEmergency}      xpath=.//${xpath_NRDU-1}/p[@name="numOfDrbsReservForEmergency"]
    Save xml     ${scf_xml}    ${resultDir}/SCFC_711A_voice_tc_specific.xml
    Log To Console    SCF saved ${resultDir}/SCFC_711A_voice_tc_specific.xml


activate voice SCF and bring tl onAir
    [Documentation]    [PRIVATE]    activate SCF and bring tl onAir
    ...       :Autor: Sylvia Schneider
    Kill WTS services
    Update SCF voice with tc specific parameters
    Load wts file    basic_wts_711A_voice
    start wireshark trace
    ${oam_alias}    connect.Setup OAM http session    node_type=gnb  node_id=${0}
    Log To Console    activate ${resultDir}/SCFC_711A_voice_tc_specific.xml started
    admin.Perform Commissioning
    ...    scf_file=${resultDir}/SCFC_711A_voice_tc_specific.xml
    ...    skip_parameter_relation_errors=False
    ...    timeout=660
    ...    connection=${oam_alias}
    Log To Console    activate ${resultDir}/SCFC_711A_voice_tc_specific.xml finished
    Run Keyword and Ignore Error    connect.Teardown OAM http session    node_type=gnb  node_id=${0}
    check all radio units online
    Log To Console    start to bring tl on air without reboot
    Bring Airphone TL to on Air status without reboot
    stop wireshark trace for setup
    check wts in active state
    Log To Console    save final scf ${resultDir}/SCF_voice_final.xml
    get scf coam   ${resultDir}    SCF_voice_final.xml
    [Teardown]    Run Keyword and Ignore Error    connect.Teardown OAM http session    node_type=gnb  node_id=${0}


Create List emergencyCallRestrictions
    [Documentation]    [PRIVATE]    create List emergencyCallRestrictions in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building list emergencyCallRestrictions for object ${bts_distName}/NRCELL-1
    ${emergencyCallRestrictions}    set variable    <list name="emergencyCallRestrictions">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="emergencyCallMrListIgnore">true</p>
    ...    <p name="emergencyCallPlmnHoAllowed">true</p>
    ...    </item>
    ...    </list>
           ${emergencyCallRestrictions}   Catenate     SEPARATOR=\n         ${emergencyCallRestrictions}   ${line}
    END
    Add Element     ${scf_xml}     ${emergencyCallRestrictions}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]
