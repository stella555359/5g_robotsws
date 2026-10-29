*** Settings ***
Documentation   This is a keyword file for CB006139-AA, part commissioning
...             Team: 'MN RAN RD VRF ULM 2'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------


*** Keywords ***

Update SCF AA t1
    [Documentation]    [PRIVATE]    update SCF AA t1
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate SCF and store in ${resultDir}/CB006139-AA_t1.xml
    ${scf_xml}    Parse Xml    ${resultBaseDir}/SCFC_start.xml
    Log To Console    set param actBufferBasedSCellAddition to oneShot_stepWise_Dl_Fr1
    Set Element Text   ${scf_xml}    text=oneShot_stepWise_Dl_Fr1    xpath=.//p[@name="actBufferBasedSCellAddition"]
    Save Xml     ${scf_xml}    ${resultDir}/CB006139-AA_t1.xml


Update SCF AA t2
    [Documentation]    [PRIVATE]    update SCF AA t2
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate SCF and store in ${resultDir}/CB006139-AA_t2.xml
    ${scf_xml}    Parse Xml    ${resultBaseDir}/SCFC_start.xml
    Log To Console    set param actBufferBasedSCellAddition to oneShot_Dl_Fr1
    Set Element Text   ${scf_xml}    text=oneShot_Dl_Fr1    xpath=.//p[@name="actBufferBasedSCellAddition"]
    Log To Console    NRCELL-1 set param maxNumScellsDlFr1 to 3
    Set Element Text   ${scf_xml}    text=3    xpath=.//managedObject[@distName="MRBTS-1/NRBTS-1/NRCELL-1"]/p[@name="maxNumScellsDlFr1"]
    Save Xml     ${scf_xml}    ${resultDir}/CB006139-AA_t2.xml


Update SCF AA t3
    [Documentation]    [PRIVATE]    update SCF AA t3
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate SCF and store in ${resultDir}/CB006139-AA_t3.xml
    ${scf_xml}    Parse Xml    ${resultBaseDir}/SCFC_start.xml

    FOR   ${param}                          ${value}    IN
    ...   actBufferBasedSCellAddition       oneShot_stepWise_Dl_Fr1
    ...   actSCellReleaseForInactiveSCell   timer_based_Fr1
       Log To Console    NRBTS: set param ${param} to value ${value}
       Set Element Text   ${scf_xml}    text=${value}    xpath=.//p[@name="${param}"]
    END

    ${xpath_NRDU}   Set Variable  managedObject[@distName="MRBTS-1/NRBTS-1/NRDU-1"]
    Log To Console    NRDU-1: set param dlToUlContributionRatio to value 50
    Set Element Text   ${scf_xml}    text=50    xpath=.//${xpath_NRDU}/p[@name="dlToUlContributionRatio"]
    Log To Console    NRDU-1: add param fr1UlCaPreferred with value dataRatePreferred
    Add Element   ${scf_xml}   <p name="fr1UlCaPreferred">dataRatePreferred</p>   xpath=.//managedObject[@distName="MRBTS-1/NRBTS-1/NRDU-1"]

    Log To Console    NRDU-1: upate list ulTxSwitchingSupportList with value ca_Fr1T_F_Sa_switchedUl
    Remove Element  ${scf_xml}  xpath=.//managedObject[@distName="MRBTS-1/NRBTS-1/NRDU-1"]/list[@name="ulTxSwitchingSupportList"]
    ${ulTxSwitchingSupportList}   Catenate     SEPARATOR=\n
    ...   <list name="ulTxSwitchingSupportList">
    ...   <p>ca_Fr1T_F_Sa_switchedUl</p>
    ...   </list>
    Add Element   ${scf_xml}  ${ulTxSwitchingSupportList}   xpath=.//managedObject[@distName="MRBTS-1/NRBTS-1/NRDU-1"]

    Log To Console    NRCELL-1,2,3,4,6: set param sCellInactivityReleaseTimer to value 0
    FOR   ${index}   IN   1  2  3  4  6
       ${xpath_cell}  Set Variable  managedObject[@distName="MRBTS-1/NRBTS-1/NRCELL-${index}"]
       Set Element Text   ${scf_xml}    text=0    xpath=.//${xpath_cell}/p[@name="sCellInactivityReleaseTimer"]
    END
    Log To Console    NRCELL-5: set param maxNumOfSCellAlloc to value 1
    Set Element Text   ${scf_xml}    text=1    xpath=.//managedObject[@distName="MRBTS-1/NRBTS-1/NRCELL-5"]/p[@name="maxNumOfSCellAlloc"]

    Log To Console     for counter verification set actCarAgPmCount to true
    Set Element Text   ${scf_xml}    text=true    xpath=.//p[@name="actCarAgPmCount"]
    Log To Console     for counter verification set miNrCaDuCp to 5min
    Set Element Text   ${scf_xml}    text=5min    xpath=.//p[@name="miNrCaDuCp"]

    Save Xml     ${scf_xml}    ${resultDir}/CB006139-AA_t3.xml


Update SCF AA B7
    [Documentation]    [PRIVATE]    Update SCF AA-B7
    ...       :Autor: Yasir Mehmood
    Log To Console    \nupdate SCF and store in ${resultDir}/CB006139-AA_B7.xml
    ${scf_xml}    Parse Xml    ${resultBaseDir}/SCFC_start.xml
    Log To Console    set param actBufferBasedSCellAddition to oneShot_stepWise_Dl_Fr1
    Set Element Text   ${scf_xml}    text=oneShot_stepWise_Dl_Fr1    xpath=.//p[@name="actBufferBasedSCellAddition"]
    Log To Console    NRBTS-1 set param sCellDeactivationBadRlqCount to 5
    Set Element Text   ${scf_xml}    text=5    xpath=.//managedObject[@distName="MRBTS-1/NRBTS-1"]/p[@name="sCellDeactivationBadRlqCount"]
    Log To Console    NRBTS-1 set param sCellExcludelistTimerFr1 to 300
    Set Element Text   ${scf_xml}    text=300    xpath=.//managedObject[@distName="MRBTS-1/NRBTS-1"]/p[@name="sCellExcludelistTimerFr1"]
    Log To Console    NRCELL-6 set param maxNumOfSCellAlloc to 0
    Set Element Text   ${scf_xml}    text=0    xpath=.//managedObject[@distName="MRBTS-1/NRBTS-1/NRCELL-6"]/p[@name="maxNumOfSCellAlloc"]
    Log To Console     for counter verification set actCarAgPmCount to true
    Set Element Text   ${scf_xml}    text=true    xpath=.//p[@name="actCarAgPmCount"]
    Log To Console     for counter verification set miNrCaDuCp to 5min
    Set Element Text   ${scf_xml}    text=5min    xpath=.//p[@name="miNrCaDuCp"]
    Save Xml     ${scf_xml}    ${resultDir}/CB006139-AA_B7_SCF_Start.xml


Update SCF DA B3
    [Documentation]    [PRIVATE]    update SCF DA B3
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate SCF and store in ${resultDir}/CB006139-DA_B3.xml
    ${scf_xml}    Parse Xml    ${resultBaseDir}/SCFC_start.xml
    Log To Console    NRCELL-5 set param maxNumOfSCellAlloc to 1
    Set Element Text   ${scf_xml}    text=1    xpath=.//managedObject[@distName="MRBTS-1/NRBTS-1/NRCELL-5"]/p[@name="maxNumOfSCellAlloc"]
    Save Xml     ${scf_xml}    ${resultDir}/CB006139-DA_B3.xml


Update SCF DA B12
    [Documentation]    [PRIVATE]    update SCF DA B12
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate SCF and store in ${resultDir}/CB006139-DA_B12.xml
    ${scf_xml}    Parse Xml    ${resultBaseDir}/SCFC_start.xml
    Log To Console    set param actBufferBasedSCellAddition to oneShot_stepWise_Dl_Fr1
    Set Element Text   ${scf_xml}    text=oneShot_stepWise_Dl_Fr1    xpath=.//p[@name="actBufferBasedSCellAddition"]
    Log To Console    set param sCellDeactivationBadRlqCount to 20
    Set Element Text   ${scf_xml}    text=20    xpath=.//p[@name="sCellDeactivationBadRlqCount"]
    Log To Console    NRDU-1: upate list ulTxSwitchingSupportList with value ca_Fr1T_F_Sa_switchedUl
    Remove Element  ${scf_xml}  xpath=.//managedObject[@distName="MRBTS-1/NRBTS-1/NRDU-1"]/list[@name="ulTxSwitchingSupportList"]
    ${ulTxSwitchingSupportList}   Catenate     SEPARATOR=\n
    ...   <list name="ulTxSwitchingSupportList">
    ...   <p>ca_Fr1T_F_Sa_switchedUl</p>
    ...   </list>
    Add Element   ${scf_xml}  ${ulTxSwitchingSupportList}   xpath=.//managedObject[@distName="MRBTS-1/NRBTS-1/NRDU-1"]
    Log To Console    NRCELL-5 set param maxNumOfSCellAlloc to 0
    Set Element Text   ${scf_xml}    text=0    xpath=.//managedObject[@distName="MRBTS-1/NRBTS-1/NRCELL-5"]/p[@name="maxNumOfSCellAlloc"]

    Log To Console     for counter verification set actCarAgPmCount to true
    Set Element Text   ${scf_xml}    text=true    xpath=.//p[@name="actCarAgPmCount"]
    Log To Console     for counter verification set miNrCaDuCp to 5min
    Set Element Text   ${scf_xml}    text=5min    xpath=.//p[@name="miNrCaDuCp"]

    Save Xml     ${scf_xml}    ${resultDir}/CB006139-DA_B12.xml


Update SCF DA B1
    [Documentation]    [PRIVATE]    update SCF DA B1
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate SCF and store in ${resultDir}/CB006139-DA_B1.xml
    ${scf_xml}    Parse Xml    ${resultBaseDir}/SCFC_start.xml
    Log To Console    set param actBufferBasedSCellAddition to oneShot_stepWise_Dl_Fr1
    Set Element Text   ${scf_xml}    text=oneShot_stepWise_Dl_Fr1    xpath=.//p[@name="actBufferBasedSCellAddition"]
    Log To Console    set param sCellDeactivationBadRlqCount to 5
    Set Element Text   ${scf_xml}    text=5    xpath=.//p[@name="sCellDeactivationBadRlqCount"]
    Log To Console    NRBTS-1 set param sCellExcludelistTimerFr1 to 30
    Set Element Text   ${scf_xml}    text=30    xpath=.//managedObject[@distName="MRBTS-1/NRBTS-1"]/p[@name="sCellExcludelistTimerFr1"]
    Log To Console    NRBTS-1 set list duOvlHa param ovlSaRrcRej to false
    Set Element Text   ${scf_xml}    text=false
    ...    xpath=.//managedObject[@distName="MRBTS-1/NRBTS-1"]/list[@name="duOvlHa"]/item/p[@name="ovlSaRrcRej"]
    ${xpath_NRDU}   Set Variable  managedObject[@distName="MRBTS-1/NRBTS-1/NRDU-1"]
    Log To Console    NRDU-1: set param dlToUlContributionRatio to value 50
    Set Element Text   ${scf_xml}    text=50    xpath=.//${xpath_NRDU}/p[@name="dlToUlContributionRatio"]
    Log To Console    NRDU-1: add param fr1UlCaPreferred with value ulCaPreferred
    Add Element   ${scf_xml}   <p name="fr1UlCaPreferred">ulCaPreferred</p>   xpath=.//managedObject[@distName="MRBTS-1/NRBTS-1/NRDU-1"]
    Save Xml     ${scf_xml}    ${resultDir}/CB006139-DA_B1.xml




activate SCF and bring tl onAir
    [Documentation]    [PRIVATE]    activate SCF and bring tl onAir
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${scf_file}
    Kill WTS services
    start wireshark trace
    Open Http Session For Commissioning
    Log To Console    activate ${resultDir}/${scf_file}.xml
    admin.Perform Commissioning
    ...    scf_file=${resultDir}/${scf_file}.xml
    ...    skip_parameter_relation_errors=False
    ...    timeout=660
    ...    connection=${oam_alias}
    Log To Console    activate ${resultDir}/${scf_file}.xml finished
    Run Keyword and Ignore Error    connect.Teardown OAM http session    node_type=gnb  node_id=${0}
    check all radio units online
    Log To Console    start to bring tl on air without reboot
    Bring Airphone TL to on Air status without reboot
    stop wireshark trace for setup
    check wts in active state
    Log To Console    save final scf ${resultDir}/SCF_final.xml
    get scf coam   ${resultDir}    SCF_final.xml
    [Teardown]    Run Keyword and Ignore Error    Close Http Session For Commissioning


Open Http Session For Commissioning
    [Documentation]    [PRIVATE]    Open Http Session For Commissioning
    ...       :Autor: Sylvia Schneider
    ${oam_alias}    connect.Setup OAM http session    node_type=gnb  node_id=${0}
    set test variable   ${oam_alias}


Close Http Session For Commissioning
    [Documentation]    [PRIVATE]    Close Http Session For Commissioning
    ...       :Autor: Sylvia Schneider
    connect.Teardown OAM http session    node_type=gnb  node_id=${0}


Set actBufferBasedSCellAddition To oneShot_Dl_Fr1
    [Documentation]    [PRIVATE]    delta commissioning to set actBufferBasedSCellAddition to oneShot_Dl_Fr1
    ...       :Autor: Sylvia Schneider
    Log To Console    \ndelta commissioning set actBufferBasedSCellAddition to oneShot_Dl_Fr1
    Open Http Session For Commissioning
    admin.Perform Delta Recommissioning
    ...    ${CURDIR}/actBufferBasedSCellAddition_oneShot_Dl_Fr1.json
    ...    should_activate=True
    ...    timeout=300
    ...    connection=${oam_alias}
    Close Http Session For Commissioning


Set actBufferBasedSCellAddition To oneShot_stepWise_Dl_Fr1
    [Documentation]    [PRIVATE]    delta commissioning to set actBufferBasedSCellAddition to oneShot_stepWise_Dl_Fr1
    ...       :Autor: Sylvia Schneider
    Log To Console    \ndelta commissioning set actBufferBasedSCellAddition to oneShot_stepWise_Dl_Fr1
    Open Http Session For Commissioning
    admin.Perform Delta Recommissioning
    ...    ${CURDIR}/actBufferBasedSCellAddition_oneShot_stepWise_Dl_Fr1.json
    ...    should_activate=True
    ...    timeout=300
    ...    connection=${oam_alias}
    Close Http Session For Commissioning


Set fr1UlCaPreferred To ulCaPreferred
    [Documentation]    [PRIVATE]    delta commissioning to set fr1UlCaPreferred to ulCaPreferred
    ...       :Autor: Sylvia Schneider
    Log To Console    \ndelta commissioning set fr1UlCaPreferred to ulCaPreferred
    Open Http Session For Commissioning
    admin.Perform Delta Recommissioning
    ...    ${CURDIR}/fr1UlCaPreferred_ulCaPreferred.json
    ...    should_activate=True
    ...    timeout=300
    ...    connection=${oam_alias}
    Close Http Session For Commissioning


Set Nrcell_6 maxNumOfSCellAlloc To 250
    [Documentation]    [PRIVATE]    delta commissioning to set maxNumOfSCellAlloc to 250
    ...       :Autor: Yasir Mehmood
    Log To Console    \ndelta commissioning set nrcell_6 maxNumOfSCellAlloc to 250
    Open Http Session For Commissioning
    admin.Perform Delta Recommissioning
    ...    ${CURDIR}/scell6_maxnumofscellalloc.json
    ...    should_activate=True
    ...    timeout=300
    ...    connection=${oam_alias}
    Close Http Session For Commissioning


Set NRCELL_5 maxNumOfSCellAlloc To 20
    [Documentation]    [PRIVATE]    set NRCELL_5 maxNumOfSCellAlloc to 20
    ...       :Autor: Sylvia Schneider
    Log To Console    \ndelta commissioning set NRCELL_5 maxNumOfSCellAlloc to 20
    Open Http Session For Commissioning
    admin.Perform Delta Recommissioning
    ...    ${CURDIR}/cell5_maxNumOfSCellAlloc_20.json
    ...    should_activate=True
    ...    timeout=300
    ...    connection=${oam_alias}
    Close Http Session For Commissioning


Set NRCELL-4 And NRCELL-6 maxNumOfSCellAlloc To 0
    [Documentation]    [PRIVATE]    set NRCELL-4 and NRCELL-6 maxNumOfSCellAlloc to 0
    ...       :Autor: Sylvia Schneider
    Log To Console    \ndelta commissioning set NRCELL-4 and NRCELL-6 maxNumOfSCellAlloc to 0
    Open Http Session For Commissioning
    admin.Perform Delta Recommissioning
    ...    ${CURDIR}/cell4_cell6_maxNumOfSCellAlloc_0.json
    ...    should_activate=True
    ...    timeout=300
    ...    connection=${oam_alias}
