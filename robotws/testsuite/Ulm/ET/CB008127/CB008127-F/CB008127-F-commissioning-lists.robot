*** Settings ***
Documentation   This is a keyword file for CB008127, part commissioning, new lists
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------


*** Keywords ***

Add List a1MeashoPrefNRLayerSsbRsrpSA to NRCELL-1
    [Documentation]    [PRIVATE]    create List a1MeashoPrefNRLayerSsbRsrpSA for NRCELL-1 in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building list a1MeashoPrefNRLayerSsbRsrpSA for object ${bts_distName}/NRCELL-1
    ${a1MeashoPrefNRLayerSsbRsrpSA}    set variable    <list name="a1MeashoPrefNRLayerSsbRsrpSA">
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


Add List a1MeashoPrefNRLayerSsbRsrqSA to NRCELL-1
    [Documentation]    [PRIVATE]    create List a1MeashoPrefNRLayerSsbRsrqSA for NRCELL-1 in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building list a1MeashoPrefNRLayerSsbRsrqSA for object ${bts_distName}/NRCELL-1
    ${a1MeashoPrefNRLayerSsbRsrqSA}    set variable    <list name="a1MeashoPrefNRLayerSsbRsrqSA">
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


Create single list a1MeashoSsbRsrpSA
    [Documentation]    [PRIVATE]    create List a1MeashoSsbRsrpSA for NRCELL object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${nrcell_id}
    Log To Console    Building list a1MeashoSsbRsrpSA for object ${bts_distName}/NRCELL-${nrcell_id}
    ${new_list}    set variable    <list name="a1MeashoSsbRsrpSA">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="a1HysteresishoSsbRsrpSA">0</p>
    ...    <p name="a1HysteresisHoSsbRsrpVoNr">0</p>
    ...    <p name="a1ThresholdhoSsbRsrpSA">104</p>
    ...    <p name="a1ThresholdHoSsbRsrpVoNr">100</p>
    ...    <p name="a1TimeToTriggerhoSsbRsrpSA">ms480</p>
    ...    <p name="a1TimeToTriggerHoSsbRsrpVoNr">ms480</p>
    ...    </item>
    ...    </list>
           ${new_list}   Catenate     SEPARATOR=\n         ${new_list}   ${line}
    END
    Add Element     ${scf_xml}     ${new_list}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${nrcell_id}"]


Add List a1MeashoSsbRsrpSA
    [Documentation]    [PRIVATE]    create List a1MeashoSsbRsrpSA
    ...       :Autor: Sylvia Schneider
    FOR    ${nrcell_id}     IN   1   2   3   4
       Create single list a1MeashoSsbRsrpSA   nrcell_id=${nrcell_id}
    END


Add List a1MeashoSsbRsrqSA
    [Documentation]    [PRIVATE]    create List a1MeashoSsbRsrqSA for NRCELL objects in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building list a1MeashoSsbRsrqSA for object ${bts_distName}/NRCELL objects
    ${a1MeashoSsbRsrqSA}    set variable    <list name="a1MeashoSsbRsrqSA">
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


Add List a2MeasReleaseSsbRsrp to NRCELL-1
    [Documentation]    [PRIVATE]    create List a2MeasReleaseSsbRsrp for NRCELL-1 in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building list a2MeasReleaseSsbRsrp for object ${bts_distName}/NRCELL-1
    ${a2MeasReleaseSsbRsrp}    set variable    <list name="a2MeasReleaseSsbRsrp">
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


Update List a2MeasReleaseSsbRsrp for NRCELL-1
    [Documentation]    [PRIVATE]    update List a2MeasReleaseSsbRsrp for NRCELL-1 in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    ${bts_distName}/NRCELL-1, list a2MeasReleaseSsbRsrp, set a2ThresholdReleaseSsbRsrp to 88
    Set Element Text   ${scf_xml}    text=88
    ...   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]/list[@name="a2MeasReleaseSsbRsrp"]/item/p[@name="a2ThresholdReleaseSsbRsrp"]


Add List a2MeasReleaseSsbRsrq to NRCELL-1
    [Documentation]    [PRIVATE]    create List a2MeasReleaseSsbRsrq for NRCELL-1 in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building list a2MeasReleaseSsbRsrq for object ${bts_distName}/NRCELL-1
    ${a2MeasReleaseSsbRsrq}    set variable    <list name="a2MeasReleaseSsbRsrq">
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


Create single list a2MeashoSsbRsrpSA
    [Documentation]    [PRIVATE]    create List a2MeashoSsbRsrpSA for NRCELL object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${nrcell_id}
    Log To Console    Building list a2MeashoSsbRsrpSA for object ${bts_distName}/NRCELL-${nrcell_id}
    ${new_list}    set variable    <list name="a2MeashoSsbRsrpSA">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="a2HysteresishoSsbRsrpSA">0</p>
    ...    <p name="a2HysteresisHoSsbRsrpVoNr">0</p>
    ...    <p name="a2ThresholdhoSsbRsrpSA">100</p>
    ...    <p name="a2ThresholdHoSsbRsrpVoNr">96</p>
    ...    <p name="a2TimeToTriggerhoSsbRsrpSA">ms480</p>
    ...    <p name="a2TimeToTriggerHoSsbRsrpVoNr">ms480</p>
    ...    </item>
    ...    </list>
           ${new_list}   Catenate     SEPARATOR=\n         ${new_list}   ${line}
    END
    Add Element     ${scf_xml}     ${new_list}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${nrcell_id}"]


Add List a2MeashoSsbRsrpSA
    [Documentation]    [PRIVATE]    create List a2MeashoSsbRsrpSA for NRCELL object in SCF
    FOR   ${nrcell_id}     IN   1   2   3   4
       Create single list a2MeashoSsbRsrpSA   nrcell_id=${nrcell_id}
    END


Create single list a2MeashoSsbRsrqSA
    [Documentation]    [PRIVATE]    create List a2MeashoSsbRsrqSA for NRCELL object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${nrcell_id}
    Log To Console    Building list a2MeashoSsbRsrqSA for object ${bts_distName}/NRCELL-${nrcell_id}
    ${new_list}    set variable    <list name="a2MeashoSsbRsrqSA">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="a2HysteresishoSsbRsrqSA">0</p>
    ...    <p name="a2HysteresisHoSsbRsrqVoNr">0</p>
    ...    <p name="a2ThresholdhoSsbRsrqSA">100</p>
    ...    <p name="a2ThresholdHoSsbRsrqVoNr">96</p>
    ...    <p name="a2TimeToTriggerhoSsbRsrqSA">ms480</p>
    ...    <p name="a2TimeToTriggerHoSsbRsrqVoNr">ms480</p>
    ...    </item>
    ...    </list>
           ${new_list}   Catenate     SEPARATOR=\n         ${new_list}   ${line}
    END
    Add Element     ${scf_xml}     ${new_list}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${nrcell_id}"]


Add List a2MeashoSsbRsrqSA
    [Documentation]    [PRIVATE]    create List a2MeashoSsbRsrqSA for NRCELL object in SCF
    ...       :Autor: Sylvia Schneider
    FOR   ${nrcell_id}    IN   1   2   3   4
       Create single list a2MeashoSsbRsrqSA   nrcell_id=${nrcell_id}
    END


Add List a3MeasSsbRsrp
    [Documentation]    [PRIVATE]    create List a3MeasSsbRsrp for NRCELL objects in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building list a3MeasSsbRsrp for object ${bts_distName}/NRCELL objects
    ${new_list}    set variable    <list name="a3MeasSsbRsrp">
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


Add List a3MeasSsbRsrq to NRCELL-1
    [Documentation]    [PRIVATE]    create List a3MeasSsbRsrq for NRCELL-1 in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building list a3MeasSsbRsrq for object ${bts_distName}/NRCELL-1
    ${new_list}    set variable    <list name="a3MeasSsbRsrq">
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


Create single list a5MeasSsbRsrp
    [Documentation]    [PRIVATE]    create List a5MeasSsbRsrp for NRCELL objects in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${nrcell_id}   ${a5Threshold1SsbRsrp}   ${a5Threshold2SsbRsrp}
    Log To Console    Building list a5MeasSsbRsrp for object ${bts_distName}/NRCELL-${nrcell_id}
    ${new_list}    set variable    <list name="a5MeasSsbRsrp">
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


Add List a5MeasSsbRsrp
    [Documentation]    [PRIVATE]    create List a5MeasSsbRsrp for NRCELL object in SCF
    ...       :Autor: Sylvia Schneider
    Create single list a5MeasSsbRsrp   nrcell_id=1   a5Threshold1SsbRsrp=82    a5Threshold2SsbRsrp=87
    Create single list a5MeasSsbRsrp   nrcell_id=2   a5Threshold1SsbRsrp=52    a5Threshold2SsbRsrp=54


Add List a5MeasSsbRsrq to NRCELL-1
    [Documentation]    [PRIVATE]    create List a5MeasSsbRsrq for NRCELL-1 in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building list a5MeasSsbRsrq for object ${bts_distName}/NRCELL-1
    ${new_list}    set variable    <list name="a5MeasSsbRsrq">
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


Add List measPrMaSAList to NRCELL-${id}
    [Documentation]    [PRIVATE]    create List measPrMaSAList for NRCELL in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building list measPrMaSAList for object ${bts_distName}/NRCELL-${id}
    ${new_list}    set variable    <list name="measPrMaSAList">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="measPrPriority">7</p>
    ...    <p name="nrMeasPrMaSADN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-1</p>
    ...    </item>
    ...    <item>
    ...    <p name="measPrPriority">6</p>
    ...    <p name="nrMeasPrMaSADN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-2</p>
    ...    </item>
    ...    </list>
           ${new_list}   Catenate     SEPARATOR=\n         ${new_list}   ${line}
    END
    Add Element     ${scf_xml}     ${new_list}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${id}"]


update measPrMaSAList from NRCELL-1
    [Documentation]    [PRIVATE]    update measPrMaSAList from NRCELL-1
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${measPrPriority}       ${NRMEASPR_MA_SA_id}
    Log To Console
    ...   update list measPrMaSAList object ${bts_distName}/NRCELL-1, add measPrPriority ${measPrPriority} and NRMEASPR_MA_SA-${NRMEASPR_MA_SA_id}
    ${upd_list}    set variable    <item>
    FOR     ${line}   IN
    ...    <p name="measPrPriority">${measPrPriority}</p>
    ...    <p name="nrMeasPrMaSADN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-${NRMEASPR_MA_SA_id}</p>
    ...    </item>
           ${upd_list}   Catenate     SEPARATOR=\n         ${upd_list}   ${line}
    END
    Add Element     ${scf_xml}     ${upd_list}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]/list[@name="measPrMaSAList"]


Create single List a4PeriodicMeasControlSA to NRCELL
    [Documentation]    [PRIVATE]    create single List a4PeriodicMeasControlSA for NRCELL in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${NRCELL_id}   ${a4Fr1SupervisionTimer}
    Log To Console    Building list a4PeriodicMeasControlSA for object ${bts_distName}/NRCELL-${NRCELL_id}
    ${new_list}    set variable    <list name="a4PeriodicMeasControlSA">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="a4Fr1SupervisionTimer">${a4Fr1SupervisionTimer}</p>
    ...    <p name="a4Fr2SupervisionTimer">6000</p>
    ...    <p name="a4MeasActBlockTimer">60</p>
    ...    <p name="a4MeasMaxNumber">5</p>
    ...    <p name="a4RetryTimer">10</p>
    ...    </item>
    ...    </list>
           ${new_list}   Catenate     SEPARATOR=\n         ${new_list}   ${line}
    END
    Add Element     ${scf_xml}     ${new_list}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${NRCELL_id}"]


Add List a4PeriodicMeasControlSA to NRCELL
    [Documentation]    [PRIVATE]    add List a4PeriodicMeasControlSA for NRCELL in SCF
    ...       :Autor: Sylvia Schneider
    ${a4Fr1SupervisionTimer}  create list   ${EMPTY}  10000   4000   4000   4000
    FOR   ${NRCELL_id}    IN   1   2   3   4
       Create single List a4PeriodicMeasControlSA to NRCELL    NRCELL_id=${NRCELL_id}   a4Fr1SupervisionTimer=${a4Fr1SupervisionTimer}[${NRCELL_id}]
    END


Add List nrhoirDNList to NRCELL-1
    [Documentation]    [PRIVATE]    create List nrhoirDNList for NRCELL-1 in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building list nrhoirDNList for object ${bts_distName}/NRCELL-1
    ${new_list}    set variable    <list name="nrhoirDNList">
    FOR     ${line}   IN
    ...    <p>${bts_distName}/NRHOIR-1</p>
    ...    </list>
           ${new_list}   Catenate     SEPARATOR=\n         ${new_list}   ${line}
    END
    Add Element     ${scf_xml}     ${new_list}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]
