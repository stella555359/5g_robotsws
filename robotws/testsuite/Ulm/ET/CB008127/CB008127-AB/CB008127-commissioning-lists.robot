*** Settings ***
Documentation   This is a keyword file for CB008127, part commissioning, new lists
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------


*** Keywords ***

Add List A1MeashoPrefNRLayerSsbRsrpSA To NRCELL-1
    [Documentation]    [PRIVATE]    create List a1MeashoPrefNRLayerSsbRsrpSA for NRCELL-1 in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building list a1MeashoPrefNRLayerSsbRsrpSA for object ${bts_distName}/NRCELL-1
    ${a1MeashoPrefNRLayerSsbRsrpSA}    Set Variable    <list name="a1MeashoPrefNRLayerSsbRsrpSA">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="a1HysteresisSsbRsrp">0</p>
    ...    <p name="a1ThresholdhoSsbRsrp">96</p>
    ...    <p name="a1TimeToTriggerhoSsbRsrp">ms40</p>
    ...    </item>
    ...    </list>
           ${a1MeashoPrefNRLayerSsbRsrpSA}   Catenate     SEPARATOR=\n         ${a1MeashoPrefNRLayerSsbRsrpSA}   ${line}
    END
    Add Element     ${scf_xml}     ${a1MeashoPrefNRLayerSsbRsrpSA}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]
    Add Element     ${scf_xml}     ${a1MeashoPrefNRLayerSsbRsrpSA}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]


Add List A1MeashoPrefNRLayerSsbRsrqSA To NRCELL-1
    [Documentation]    [PRIVATE]    create List a1MeashoPrefNRLayerSsbRsrqSA for NRCELL-1 in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building list a1MeashoPrefNRLayerSsbRsrqSA for object ${bts_distName}/NRCELL-1
    ${a1MeashoPrefNRLayerSsbRsrqSA}    Set Variable    <list name="a1MeashoPrefNRLayerSsbRsrqSA">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="a1HysteresisSsbRsrq">0</p>
    ...    <p name="a1ThresholdhoSsbRsrq">104</p>
    ...    <p name="a1TimeToTriggerhoSsbRsrq">ms40</p>
    ...    </item>
    ...    </list>
           ${a1MeashoPrefNRLayerSsbRsrqSA}   Catenate     SEPARATOR=\n         ${a1MeashoPrefNRLayerSsbRsrqSA}   ${line}
    END
    Add Element     ${scf_xml}     ${a1MeashoPrefNRLayerSsbRsrqSA}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]
    Add Element     ${scf_xml}     ${a1MeashoPrefNRLayerSsbRsrqSA}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]


Create Single List A1MeashoSsbRsrpSA
    [Documentation]    [PRIVATE]    create List a1MeashoSsbRsrpSA for NRCELL object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${nrcell_id}   ${a1ThresholdHoSsbRsrpVoNr}
    Log To Console    Building list a1MeashoSsbRsrpSA for object ${bts_distName}/NRCELL-${nrcell_id}
    ${new_list}    Set Variable    <list name="a1MeashoSsbRsrpSA">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="a1HysteresishoSsbRsrpSA">0</p>
    ...    <p name="a1HysteresisHoSsbRsrpVoNr">0</p>
    ...    <p name="a1ThresholdhoSsbRsrpSA">104</p>
    ...    <p name="a1ThresholdHoSsbRsrpVoNr">${a1ThresholdHoSsbRsrpVoNr}</p>
    ...    <p name="a1TimeToTriggerhoSsbRsrpSA">ms480</p>
    ...    <p name="a1TimeToTriggerHoSsbRsrpVoNr">ms480</p>
    ...    </item>
    ...    </list>
           ${new_list}   Catenate     SEPARATOR=\n         ${new_list}   ${line}
    END
    Add Element     ${scf_xml}     ${new_list}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${nrcell_id}"]


Add List A1MeashoSsbRsrpSA
    [Documentation]    [PRIVATE]    create List a1MeashoSsbRsrpSA
    ...       :Autor: Sylvia Schneider
    FOR    ${nrcell_id}     ${a1ThresholdHoSsbRsrpVoNr}    IN
    ...    1                100
    ...    2                100
    ...    3                100
    ...    4                100
       Create Single List A1MeashoSsbRsrpSA   nrcell_id=${nrcell_id}   a1ThresholdHoSsbRsrpVoNr=${a1ThresholdHoSsbRsrpVoNr}
    END


Update Single List A1MeashoSsbRsrpSA VoNr
    [Documentation]    [PRIVATE]    update single list a1MeashoSsbRsrpSA_VoNr
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${nrcell_id}
    ${xpath_list}  Set Variable   managedObject[@distName="${bts_distName}/NRCELL-${nrcell_id}"]/list[@name="a1MeashoSsbRsrpSA"]/item
    Set Element Text   ${scf_xml}    text=104    xpath=.//${xpath_list}/p[@name="a1ThresholdhoSsbRsrpSA"]
    FOR    ${param}    IN
    ...    <p name\="a1HysteresisHoSsbRsrpVoNr">0</p>
    ...    <p name\="a1ThresholdHoSsbRsrpVoNr">100</p>
    ...    <p name\="a1TimeToTriggerHoSsbRsrpVoNr">ms480</p>
       Add Element     ${scf_xml}     ${param}           xpath=.//${xpath_list}
    END


Update List A1MeashoSsbRsrpSA VoNr
    [Documentation]    [PRIVATE]    update list a1MeashoSsbRsrpSA_VoNr
    ...       :Autor: Sylvia Schneider
    Log To Console    update NRCELL 1,2,3,4 list a1MeashoSsbRsrpSA param a1ThresholdhoSsbRsrpSA value 104
    Log To Console
    ...    update NRCELL 1,2,3,4 list a1MeashoSsbRsrpSA add params a1HysteresisHoSsbRsrpVoNr, a1ThresholdHoSsbRsrpVoNr, a1TimeToTriggerHoSsbRsrpVoNr
    FOR   ${nrcell_id}   IN   1  2  3  4
       Update Single List A1MeashoSsbRsrpSA VoNr     ${nrcell_id}
    END


Add List A1MeashoSsbRsrqSA
    [Documentation]    [PRIVATE]    create List a1MeashoSsbRsrqSA for NRCELL objects in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building list a1MeashoSsbRsrqSA for object ${bts_distName}/NRCELL objects
    ${a1MeashoSsbRsrqSA}    Set Variable    <list name="a1MeashoSsbRsrqSA">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="a1HysteresishoSsbRsrqSA">0</p>
    ...    <p name="a1HysteresisHoSsbRsrqVoNr">0</p>
    ...    <p name="a1ThresholdhoSsbRsrqSA">104</p>
    ...    <p name="a1ThresholdHoSsbRsrqVoNr">100</p>
    ...    <p name="a1TimeToTriggerhoSsbRsrqSA">ms480</p>
    ...    <p name="a1TimeToTriggerHoSsbRsrqVoNr">ms480</p>
    ...    </item>
    ...    </list>
           ${a1MeashoSsbRsrqSA}   Catenate     SEPARATOR=\n         ${a1MeashoSsbRsrqSA}   ${line}
    END
    FOR     ${NRCELL_id}    IN   1   2   3   4
       Add Element     ${scf_xml}     ${a1MeashoSsbRsrqSA}    xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${NRCELL_id}"]
    END


Add List A2MeasReleaseSsbRsrp To NRCELL-1
    [Documentation]    [PRIVATE]    create List a2MeasReleaseSsbRsrp for NRCELL-1 in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building list a2MeasReleaseSsbRsrp for object ${bts_distName}/NRCELL-1
    ${a2MeasReleaseSsbRsrp}    Set Variable    <list name="a2MeasReleaseSsbRsrp">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="a2HysteresisReleaseSsbRsrp">0</p>
    ...    <p name="a2ThresholdReleaseSsbRsrp">88</p>
    ...    <p name="a2TimeToTriggerReleaseSsbRsrp">ms480</p>
    ...    </item>
    ...    </list>
           ${a2MeasReleaseSsbRsrp}   Catenate     SEPARATOR=\n         ${a2MeasReleaseSsbRsrp}   ${line}
    END
    Add Element     ${scf_xml}     ${a2MeasReleaseSsbRsrp}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]


Update List A2MeasReleaseSsbRsrp NRCELL-1 A2ThresholdReleaseSsbRsrp Value 88
    [Documentation]    [PRIVATE]    create List a2MeasReleaseSsbRsrq for NRCELL-1 in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    update list a2MeasReleaseSsbRsrp NRCELL-1 param a2ThresholdReleaseSsbRsrp value 88
    Set Element Text   ${scf_xml}    text=88
    ...  xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]/list[@name="a2MeasReleaseSsbRsrp"]/item/p[@name="a2ThresholdReleaseSsbRsrp"]



Add List A2MeasReleaseSsbRsrq To NRCELL-1
    [Documentation]    [PRIVATE]    create List a2MeasReleaseSsbRsrq for NRCELL-1 in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building list a2MeasReleaseSsbRsrq for object ${bts_distName}/NRCELL-1
    ${a2MeasReleaseSsbRsrq}    Set Variable    <list name="a2MeasReleaseSsbRsrq">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="a2HysteresisReleaseSsbRsrq">0</p>
    ...    <p name="a2ThresholdReleaseSsbRsrq">88</p>
    ...    <p name="a2TimeToTriggerReleaseSsbRsrq">ms480</p>
    ...    </item>
    ...    </list>
           ${a2MeasReleaseSsbRsrq}   Catenate     SEPARATOR=\n         ${a2MeasReleaseSsbRsrq}   ${line}
    END
    Add Element     ${scf_xml}     ${a2MeasReleaseSsbRsrq}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]


Create Single List A2MeashoSsbRsrpSA
    [Documentation]    [PRIVATE]    create List a2MeashoSsbRsrpSA for NRCELL object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${nrcell_id}   ${a2ThresholdHoSsbRsrpVoNr}
    Log To Console    Building list a2MeashoSsbRsrpSA for object ${bts_distName}/NRCELL-${nrcell_id}
    ${new_list}    Set Variable    <list name="a2MeashoSsbRsrpSA">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="a2HysteresishoSsbRsrpSA">0</p>
    ...    <p name="a2HysteresisHoSsbRsrpVoNr">0</p>
    ...    <p name="a2ThresholdhoSsbRsrpSA">100</p>
    ...    <p name="a2ThresholdHoSsbRsrpVoNr">${a2ThresholdHoSsbRsrpVoNr}</p>
    ...    <p name="a2TimeToTriggerhoSsbRsrpSA">ms480</p>
    ...    <p name="a2TimeToTriggerHoSsbRsrpVoNr">ms480</p>
    ...    </item>
    ...    </list>
           ${new_list}   Catenate     SEPARATOR=\n         ${new_list}   ${line}
    END
    Add Element     ${scf_xml}     ${new_list}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${nrcell_id}"]


Add List A2MeashoSsbRsrpSA
    [Documentation]    [PRIVATE]    create List a2MeashoSsbRsrpSA for NRCELL object in SCF
    FOR   ${nrcell_id}    ${a2ThresholdHoSsbRsrpVoNr}   IN
    ...   1               96
    ...   2               96
    ...   3               96
    ...   4               96
       Create Single List A2MeashoSsbRsrpSA   nrcell_id=${nrcell_id}   a2ThresholdHoSsbRsrpVoNr=${a2ThresholdHoSsbRsrpVoNr}
    END


Create Single List A2MeashoSsbRsrqSA
    [Documentation]    [PRIVATE]    create List a2MeashoSsbRsrqSA for NRCELL object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${nrcell_id}   ${a2ThresholdHoSsbRsrqVoNr}
    Log To Console    Building list a2MeashoSsbRsrqSA for object ${bts_distName}/NRCELL-${nrcell_id}
    ${new_list}    Set Variable    <list name="a2MeashoSsbRsrqSA">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="a2HysteresishoSsbRsrqSA">0</p>
    ...    <p name="a2HysteresisHoSsbRsrqVoNr">0</p>
    ...    <p name="a2ThresholdhoSsbRsrqSA">100</p>
    ...    <p name="a2ThresholdHoSsbRsrqVoNr">${a2ThresholdHoSsbRsrqVoNr}</p>
    ...    <p name="a2TimeToTriggerhoSsbRsrqSA">ms480</p>
    ...    <p name="a2TimeToTriggerHoSsbRsrqVoNr">ms480</p>
    ...    </item>
    ...    </list>
           ${new_list}   Catenate     SEPARATOR=\n         ${new_list}   ${line}
    END
    Add Element     ${scf_xml}     ${new_list}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${nrcell_id}"]


Add List A2MeashoSsbRsrqSA
    [Documentation]    [PRIVATE]    create List a2MeashoSsbRsrqSA for NRCELL object in SCF
    ...       :Autor: Sylvia Schneider
    FOR   ${nrcell_id}    ${a2ThresholdHoSsbRsrqVoNr}   IN
    ...   1               96
    ...   2               96
    ...   3               96
    ...   4               96
       Create Single List A2MeashoSsbRsrqSA   nrcell_id=${nrcell_id}   a2ThresholdHoSsbRsrqVoNr=${a2ThresholdHoSsbRsrqVoNr}
    END


Add List A3MeasSsbRsrp
    [Documentation]    [PRIVATE]    create List a3MeasSsbRsrp for NRCELL objects in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building list a3MeasSsbRsrp for object ${bts_distName}/NRCELL objects
    ${new_list}    Set Variable    <list name="a3MeasSsbRsrp">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="a3HysteresisSsbRsrp">0</p>
    ...    <p name="a3OffsetSsbRsrp">0</p>
    ...    <p name="a3TimeToTriggerSsbRsrp">ms320</p>
    ...    </item>
    ...    </list>
           ${new_list}   Catenate     SEPARATOR=\n         ${new_list}   ${line}
    END
    Add Element     ${scf_xml}     ${new_list}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]
    Add Element     ${scf_xml}     ${new_list}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]


Add List A3MeasSsbRsrq To NRCELL-1
    [Documentation]    [PRIVATE]    create List a3MeasSsbRsrq for NRCELL-1 in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building list a3MeasSsbRsrq for object ${bts_distName}/NRCELL-1
    ${new_list}    Set Variable    <list name="a3MeasSsbRsrq">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="a3HysteresisSsbRsrq">0</p>
    ...    <p name="a3OffsetSsbRsrq">0</p>
    ...    <p name="a3TimeToTriggerSsbRsrq">ms320</p>
    ...    </item>
    ...    </list>
           ${new_list}   Catenate     SEPARATOR=\n         ${new_list}   ${line}
    END
    Add Element     ${scf_xml}     ${new_list}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]


Create Single List A5MeasSsbRsrp
    [Documentation]    [PRIVATE]    create List a5MeasSsbRsrp for NRCELL objects in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${nrcell_id}   ${a5Threshold1SsbRsrp}   ${a5Threshold2SsbRsrp}
    Log To Console    Building list a5MeasSsbRsrp for object ${bts_distName}/NRCELL-${nrcell_id}
    ${new_list}    Set Variable    <list name="a5MeasSsbRsrp">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="a5HysteresisSsbRsrp">0</p>
    ...    <p name="a5Threshold1SsbRsrp">${a5Threshold1SsbRsrp}</p>
    ...    <p name="a5Threshold2SsbRsrp">${a5Threshold2SsbRsrp}</p>
    ...    <p name="a5TimeToTriggerSsbRsrp">ms100</p>
    ...    </item>
    ...    </list>
           ${new_list}   Catenate     SEPARATOR=\n         ${new_list}   ${line}
    END
    Add Element     ${scf_xml}     ${new_list}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${nrcell_id}"]


Add List A5MeasSsbRsrp
    [Documentation]    [PRIVATE]    create List a5MeasSsbRsrp for NRCELL object in SCF
    ...       :Autor: Sylvia Schneider
    Create Single List A5MeasSsbRsrp   nrcell_id=1   a5Threshold1SsbRsrp=82    a5Threshold2SsbRsrp=87
    Create Single List A5MeasSsbRsrp   nrcell_id=2   a5Threshold1SsbRsrp=52    a5Threshold2SsbRsrp=54


Add List A5MeasSsbRsrq To NRCELL-1
    [Documentation]    [PRIVATE]    create List a5MeasSsbRsrq for NRCELL-1 in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building list a5MeasSsbRsrq for object ${bts_distName}/NRCELL-1
    ${new_list}    Set Variable    <list name="a5MeasSsbRsrq">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="a5HysteresisSsbRsrq">0</p>
    ...    <p name="a5Threshold1SsbRsrq">82</p>
    ...    <p name="a5Threshold2SsbRsrq">87</p>
    ...    <p name="a5TimeToTriggerSsbRsrq">ms100</p>
    ...    </item>
    ...    </list>
           ${new_list}   Catenate     SEPARATOR=\n         ${new_list}   ${line}
    END
    Add Element     ${scf_xml}     ${new_list}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]


Add List A5MeasSsbRsrp A5MeasSsbRsrq To NRCELL-1 NRHOIF-1
    [Documentation]    [PRIVATE]    Add List a5MeasSsbRsrp a5MeasSsbRsrq to NRCELL-1 NRHOIF-1
    ...       :Autor: Sylvia Schneider
    Log To Console    Building list a5MeasSsbRsrp for object ${bts_distName}/NRCELL-1/NRHOIF-1
    ${new_list}    Set Variable    <list name="a5MeasSsbRsrp">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="a5HysteresisSsbRsrp">0</p>
    ...    <p name="a5Threshold1SsbRsrp">102</p>
    ...    <p name="a5Threshold2SsbRsrp">92</p>
    ...    <p name="a5TimeToTriggerSsbRsrp">ms480</p>
    ...    </item>
    ...    </list>
           ${new_list}   Catenate     SEPARATOR=\n         ${new_list}   ${line}
    END
    Add Element     ${scf_xml}     ${new_list}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1/NRHOIF-1"]

    Log To Console    Building list a5MeasSsbRsrq for object ${bts_distName}/NRCELL-1
    ${new_list}    Set Variable    <list name="a5MeasSsbRsrq">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="a5HysteresisSsbRsrq">0</p>
    ...    <p name="a5Threshold1SsbRsrq">40</p>
    ...    <p name="a5Threshold2SsbRsrq">30</p>
    ...    <p name="a5TimeToTriggerSsbRsrq">ms480</p>
    ...    </item>
    ...    </list>
           ${new_list}   Catenate     SEPARATOR=\n         ${new_list}   ${line}
    END
    Add Element     ${scf_xml}     ${new_list}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1/NRHOIF-1"]


Add List MeasPrMaSAList To NRCELL-${id}
    [Documentation]    [PRIVATE]    create List measPrMaSAList for NRCELL in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building list measPrMaSAList for object ${bts_distName}/NRCELL-${id}
    ${new_list}    Set Variable    <list name="measPrMaSAList">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="measPrPriority">8</p>
    ...    <p name="nrMeasPrMaSADN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-1</p>
    ...    </item>
    ...    <item>
    ...    <p name="measPrPriority">7</p>
    ...    <p name="nrMeasPrMaSADN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-2</p>
    ...    </item>
    ...    <item>
    ...    <p name="measPrPriority">6</p>
    ...    <p name="nrMeasPrMaSADN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-3</p>
    ...    </item>
    ...    <item>
    ...    <p name="measPrPriority">5</p>
    ...    <p name="nrMeasPrMaSADN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-4</p>
    ...    </item>
    ...    <item>
    ...    <p name="measPrPriority">4</p>
    ...    <p name="nrMeasPrMaSADN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-5</p>
    ...    </item>
    ...    <item>
    ...    <p name="measPrPriority">3</p>
    ...    <p name="nrMeasPrMaSADN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-6</p>
    ...    </item>
    ...    <item>
    ...    <p name="measPrPriority">2</p>
    ...    <p name="nrMeasPrMaSADN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-7</p>
    ...    </item>
    ...    <item>
    ...    <p name="measPrPriority">1</p>
    ...    <p name="nrMeasPrMaSADN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-8</p>
    ...    </item>
    ...    </list>
           ${new_list}   Catenate     SEPARATOR=\n         ${new_list}   ${line}
    END
    Add Element     ${scf_xml}     ${new_list}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${id}"]


Create Single List A4PeriodicMeasControlSA To NRCELL
    [Documentation]    [PRIVATE]    create single List a4PeriodicMeasControlSA for NRCELL in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${NRCELL_id}   ${a4Fr1SupervisionTimer}
    Log To Console    Building list a4PeriodicMeasControlSA for object ${bts_distName}/NRCELL-${NRCELL_id}
    ${new_list}    Set Variable    <list name="a4PeriodicMeasControlSA">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="a4Fr1SupervisionTimer">${a4Fr1SupervisionTimer}</p>
    ...    <p name="a4Fr2SupervisionTimer">6000</p>
    ...    <p name="a4MeasActBlockTimer">60</p>
    ...    <p name="a4MeasMaxNumber">5</p>
    ...    <p name="a4RetryTimer">10</p>
    ...    <p name="a4RetryTimerMultCa">5</p>
    ...    </item>
    ...    </list>
           ${new_list}   Catenate     SEPARATOR=\n         ${new_list}   ${line}
    END
    Add Element     ${scf_xml}     ${new_list}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${NRCELL_id}"]


Add List A4PeriodicMeasControlSA To NRCELL
    [Documentation]    [PRIVATE]    add List a4PeriodicMeasControlSA for NRCELL in SCF
    ...       :Autor: Sylvia Schneider
    ${a4Fr1SupervisionTimer}  Create List   ${EMPTY}  10000   4000   4000   4000
    FOR   ${NRCELL_id}    IN   1   2   3   4
       Create Single List A4PeriodicMeasControlSA To NRCELL    NRCELL_id=${NRCELL_id}   a4Fr1SupervisionTimer=${a4Fr1SupervisionTimer}[${NRCELL_id}]
    END


Add List NrhoirDNList To NRCELL-1
    [Documentation]    [PRIVATE]    create List nrhoirDNList for NRCELL-1 in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building list nrhoirDNList for object ${bts_distName}/NRCELL-1
    ${new_list}    Set Variable    <list name="nrhoirDNList">
    FOR     ${line}   IN
    ...    <p>${bts_distName}/NRHOIR-1</p>
    ...    </list>
           ${new_list}   Catenate     SEPARATOR=\n         ${new_list}   ${line}
    END
    Add Element     ${scf_xml}     ${new_list}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]
