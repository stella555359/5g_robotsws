*** Settings ***
Documentation   This is a keyword file for CB008731, part commissioning, new lists
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Keywords ***

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


Add List a3MeasSsbRsrp 2gnb
    [Documentation]    [PRIVATE]    create List a3MeasSsbRsrp in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building list a3MeasSsbRsrp for object ${bts_distName}/NRCELL-1
    ${a3MeasSsbRsrp}    set variable    <list name="a3MeasSsbRsrp">
    FOR     ${line}   IN
           ...    <item>
           ...    <p name="a3HysteresisSsbRsrp">0</p>
           ...    <p name="a3OffsetSsbRsrp">6</p>
           ...    <p name="a3TimeToTriggerSsbRsrp">ms320</p>
           ...    </item>
           ...    </list>
           ${a3MeasSsbRsrp}   Catenate     SEPARATOR=\n         ${a3MeasSsbRsrp}   ${line}
    END
    Add Element     ${scf_xml}     ${a3MeasSsbRsrp}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]


Create List a3MeasSsbRsrp force_HO
    [Documentation]    [PRIVATE]    create List a3MeasSsbRsrp force_HO in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building list a3MeasSsbRsrp for object ${bts_distName}/NRCELL-1 and NRCELL-2
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


Create List a1MeashoSsbRsrpSA
    [Documentation]    [PRIVATE]    create List a1MeashoSsbRsrpSA in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${a1ThresholdhoSsbRsrpSA}=39    ${a1ThresholdHoSsbRsrpVoNr}=49   ${NRCELL_id}=1
    Log To Console    Building list a1MeashoSsbRsrpSA for object ${bts_distName}/NRCELL-${NRCELL_id}
    ${a1MeashoSsbRsrpSA}    set variable    <list name="a1MeashoSsbRsrpSA">
    FOR     ${line}   IN
           ...    <item>
           ...    <p name="a1HysteresishoSsbRsrpSA">0</p>
           ...    <p name="a1HysteresisHoSsbRsrpVoNr">0</p>
           ...    <p name="a1ThresholdhoSsbRsrpSA">${a1ThresholdhoSsbRsrpSA}</p>
           ...    <p name="a1ThresholdHoSsbRsrpVoNr">${a1ThresholdHoSsbRsrpVoNr}</p>
           ...    <p name="a1TimeToTriggerhoSsbRsrpSA">ms480</p>
           ...    <p name="a1TimeToTriggerHoSsbRsrpVoNr">ms480</p>
           ...    </item>
           ...    </list>
           ${a1MeashoSsbRsrpSA}   Catenate     SEPARATOR=\n         ${a1MeashoSsbRsrpSA}   ${line}
    END
    Add Element     ${scf_xml}     ${a1MeashoSsbRsrpSA}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${NRCELL_id}"]


Create List a1MeashoSsbRsrqSA
    [Documentation]    [PRIVATE]    create List a1MeashoSsbRsrqSA in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${a1ThresholdhoSsbRsrqSA}=36    ${a1ThresholdHoSsbRsrqVoNr}=46   ${NRCELL_id}=1
    Log To Console    Building list a1MeashoSsbRsrqSA for object ${bts_distName}/NRCELL-${NRCELL_id}
    ${a1MeashoSsbRsrqSA}    set variable    <list name="a1MeashoSsbRsrqSA">
    FOR     ${line}   IN
           ...    <item>
           ...    <p name="a1HysteresishoSsbRsrqSA">0</p>
           ...    <p name="a1HysteresisHoSsbRsrqVoNr">0</p>
           ...    <p name="a1ThresholdhoSsbRsrqSA">${a1ThresholdhoSsbRsrqSA}</p>
           ...    <p name="a1ThresholdHoSsbRsrqVoNr">${a1ThresholdHoSsbRsrqVoNr}</p>
           ...    <p name="a1TimeToTriggerhoSsbRsrqSA">ms480</p>
           ...    <p name="a1TimeToTriggerHoSsbRsrqVoNr">ms480</p>
           ...    </item>
           ...    </list>
           ${a1MeashoSsbRsrqSA}   Catenate     SEPARATOR=\n         ${a1MeashoSsbRsrqSA}   ${line}
    END
    Add Element     ${scf_xml}     ${a1MeashoSsbRsrqSA}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${NRCELL_id}"]


Create List a1MeashoPrefNRLayerSsbRsrpSA
    [Documentation]    [PRIVATE]    create List a1MeashoPrefNRLayerSsbRsrpSA in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${a1ThresholdhoSsbRsrp}=60     ${NRCELL_id}=1
    Log To Console    Building list a1MeashoPrefNRLayerSsbRsrpSA for object ${bts_distName}/NRCELL-${NRCELL_id}
    ${a1MeashoPrefNRLayerSsbRsrpSA}    set variable    <list name="a1MeashoPrefNRLayerSsbRsrpSA">
    FOR     ${line}   IN
           ...    <item>
           ...    <p name="a1HysteresisSsbRsrp">0</p>
           ...    <p name="a1ThresholdhoSsbRsrp">${a1ThresholdhoSsbRsrp}</p>
           ...    <p name="a1TimeToTriggerhoSsbRsrp">ms40</p>
           ...    </item>
           ...    </list>
           ${a1MeashoPrefNRLayerSsbRsrpSA}   Catenate     SEPARATOR=\n         ${a1MeashoPrefNRLayerSsbRsrpSA}   ${line}
    END
    Add Element     ${scf_xml}     ${a1MeashoPrefNRLayerSsbRsrpSA}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${NRCELL_id}"]


Create List a1MeashoPrefNRLayerSsbRsrqSA
    [Documentation]    [PRIVATE]    create List a1MeashoPrefNRLayerSsbRsrqSA in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${a1ThresholdhoSsbRsrq}=63    ${NRCELL_id}=1
    Log To Console    Building list a1MeashoPrefNRLayerSsbRsrqSA for object ${bts_distName}/NRCELL-${NRCELL_id}
    ${a1MeashoPrefNRLayerSsbRsrqSA}    set variable    <list name="a1MeashoPrefNRLayerSsbRsrqSA">
    FOR     ${line}   IN
           ...    <item>
           ...    <p name="a1HysteresisSsbRsrq">0</p>
           ...    <p name="a1ThresholdhoSsbRsrq">${a1ThresholdhoSsbRsrq}</p>
           ...    <p name="a1TimeToTriggerhoSsbRsrq">ms40</p>
           ...    </item>
           ...    </list>
           ${a1MeashoPrefNRLayerSsbRsrqSA}   Catenate     SEPARATOR=\n         ${a1MeashoPrefNRLayerSsbRsrqSA}   ${line}
    END
    Add Element     ${scf_xml}     ${a1MeashoPrefNRLayerSsbRsrqSA}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${NRCELL_id}"]


Create List a2MeashoSsbRsrpSA
    [Documentation]    [PRIVATE]    create List a2MeashoSsbRsrpSA in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${a2ThresholdhoSsbRsrpSA}=35   ${a2ThresholdHoSsbRsrpVoNr}=44   ${NRCELL_id}=1
    Log To Console    Building list a2MeashoSsbRsrpSA for object ${bts_distName}/NRCELL-${NRCELL_id}
    ${a2MeashoSsbRsrpSA}    set variable    <list name="a2MeashoSsbRsrpSA">
    FOR     ${line}   IN
           ...    <item>
           ...    <p name="a2HysteresishoSsbRsrpSA">0</p>
           ...    <p name="a2HysteresisHoSsbRsrpVoNr">0</p>
           ...    <p name="a2ThresholdhoSsbRsrpSA">${a2ThresholdhoSsbRsrpSA}</p>
           ...    <p name="a2ThresholdHoSsbRsrpVoNr">${a2ThresholdHoSsbRsrpVoNr}</p>
           ...    <p name="a2TimeToTriggerhoSsbRsrpSA">ms480</p>
           ...    <p name="a2TimeToTriggerHoSsbRsrpVoNr">ms480</p>
           ...    </item>
           ...    </list>
           ${a2MeashoSsbRsrpSA}   Catenate     SEPARATOR=\n         ${a2MeashoSsbRsrpSA}   ${line}
    END
    Add Element     ${scf_xml}     ${a2MeashoSsbRsrpSA}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${NRCELL_id}"]


Create List a2MeashoSsbRsrqSA
    [Documentation]    [PRIVATE]    create List a2MeashoSsbRsrqSA in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${a2ThresholdhoSsbRsrqSA}=32   ${a2ThresholdHoSsbRsrqVoNr}=41   ${NRCELL_id}=1
    Log To Console    Building list a2MeashoSsbRsrqSA for object ${bts_distName}/NRCELL-${NRCELL_id}
    ${a2MeashoSsbRsrqSA}    set variable    <list name="a2MeashoSsbRsrqSA">
    FOR     ${line}   IN
           ...    <item>
           ...    <p name="a2HysteresishoSsbRsrqSA">0</p>
           ...    <p name="a2HysteresisHoSsbRsrqVoNr">0</p>
           ...    <p name="a2ThresholdhoSsbRsrqSA">${a2ThresholdhoSsbRsrqSA}</p>
           ...    <p name="a2ThresholdHoSsbRsrqVoNr">${a2ThresholdHoSsbRsrqVoNr}</p>
           ...    <p name="a2TimeToTriggerhoSsbRsrqSA">ms480</p>
           ...    <p name="a2TimeToTriggerHoSsbRsrqVoNr">ms480</p>
           ...    </item>
           ...    </list>
           ${a2MeashoSsbRsrqSA}   Catenate     SEPARATOR=\n         ${a2MeashoSsbRsrqSA}   ${line}
    END
    Add Element     ${scf_xml}     ${a2MeashoSsbRsrqSA}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${NRCELL_id}"]


Create List a2MeasReleaseSsbRsrp
    [Documentation]    [PRIVATE]    create List a2MeasReleaseSsbRsrp in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building list a2MeasReleaseSsbRsrp for object ${bts_distName}/NRCELL-1
    ${new_list}    set variable    <list name="a2MeasReleaseSsbRsrp">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="a2HysteresisReleaseSsbRsrp">0</p>
    ...    <p name="a2ThresholdReleaseSsbRsrp">88</p>
    ...    <p name="a2TimeToTriggerReleaseSsbRsrp">ms480</p>
    ...    </item>
    ...    </list>
           ${new_list}   Catenate     SEPARATOR=\n         ${new_list}   ${line}
    END
    Add Element     ${scf_xml}     ${new_list}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]


Create List a2MeasReleaseSsbRsrq
    [Documentation]    [PRIVATE]    create List a2MeasReleaseSsbRsrq in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building list a2MeasReleaseSsbRsrq for object ${bts_distName}/NRCELL-1
    ${new_list}    set variable    <list name="a2MeasReleaseSsbRsrq">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="a2HysteresisReleaseSsbRsrq">0</p>
    ...    <p name="a2ThresholdReleaseSsbRsrq">88</p>
    ...    <p name="a2TimeToTriggerReleaseSsbRsrq">ms480</p>
    ...    </item>
    ...    </list>
           ${new_list}   Catenate     SEPARATOR=\n         ${new_list}   ${line}
    END
    Add Element     ${scf_xml}     ${new_list}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]


Create List a4PeriodicMeasControlSA
    [Documentation]    [PRIVATE]    create List a4PeriodicMeasControlSA
    ...       :Autor: Sylvia Schneider
    Log To Console    Building list a4PeriodicMeasControlSA for nrcell objects
    FOR      ${nrcell}     ${a4Fr1SupervisionTimer}    IN
    ...      NRCELL-1      10000
    ...      NRCELL-2      4000
    ...      NRCELL-3      10000
    ...      NRCELL-4      10000
       create single List a4PeriodicMeasControlSA   ${nrcell}     ${a4Fr1SupervisionTimer}
    END


create single List a4PeriodicMeasControlSA
    [Documentation]    [PRIVATE]    create single List a4PeriodicMeasControlSA in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${nrcell}     ${a4Fr1SupervisionTimer}
    Log To Console    Building list a4PeriodicMeasControlSA for nrcell ${nrcell}
    ${a4PeriodicMeasControlSA}    set variable    <list name="a4PeriodicMeasControlSA">
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
           ${a4PeriodicMeasControlSA}   Catenate     SEPARATOR=\n         ${a4PeriodicMeasControlSA}   ${line}
    END
    Add Element     ${scf_xml}     ${a4PeriodicMeasControlSA}           xpath=.//managedObject[@distName="${bts_distName}/${nrcell}"]


Create List a5MeasSsbRsrp
    [Documentation]    [PRIVATE]    create List a5MeasSsbRsrp in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${a5Threshold1SsbRsrp}=82   ${a5Threshold2SsbRsrp}=87    ${NRCELL_id}=1
    Log To Console    Building list a5MeasSsbRsrp for object ${bts_distName}/NRCELL-${NRCELL_id}
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
    Add Element     ${scf_xml}     ${new_list}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${NRCELL_id}"]


Create List a5MeasSsbRsrq
    [Documentation]    [PRIVATE]    create List a5MeasSsbRsrq in SCF
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


Create List measPrMaSAList
    [Documentation]    [PRIVATE]    create List measPrMaSAList in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building list measPrMaSAList for object ${bts_distName}/NRCELL-1
    ${new_list}    set variable    <list name="measPrMaSAList">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="measPrPriority">8</p>
    ...    <p name="nrMeasPrMaSADN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-1</p>
    ...    </item>
    ...    </list>
           ${new_list}   Catenate     SEPARATOR=\n         ${new_list}   ${line}
    END
    Add Element     ${scf_xml}     ${new_list}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]


Create List nrhoirDNList
    [Documentation]    [PRIVATE]    create List nrhoirDNList in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building list nrhoirDNList for object ${bts_distName}/NRCELL-1
    ${nrhoirDNList}    set variable    <list name="nrhoirDNList">
    FOR     ${line}   IN
           ...    <p>${bts_distName}/NRHOIR-1</p>
           ...    </list>
           ${nrhoirDNList}   Catenate     SEPARATOR=\n         ${nrhoirDNList}   ${line}
    END
    Add Element     ${scf_xml}     ${nrhoirDNList}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]
