*** Settings ***
Documentation   This is a keyword file for CB012121-B, part commissioning-lists
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Keywords ***

Add and Update Lists B-B8
    [Documentation]    [PRIVATE]    Add and Update Lists B-B8
    ...       :Autor: Sylvia Schneider
    FOR   ${list}   IN
    ...   a1MeashoSsbRsrqSA_VoNr
    ...   a2MeashoSsbRsrpSA_VoNr
    ...   a2MeashoSsbRsrpSA_B-B8
    ...   a2MeashoSsbRsrqSA_VoNr
    ...   a3MeasSsbRsrp_B-B8
    ...   a5MeasSsbRsrp_B-B8
    ...   nrhoirDNList
       run keyword   Create List ${list}
    END

    FOR   ${list}   IN
    ...   a1MeashoSsbRsrpSA_VoNr
       run keyword   Update List ${list}
    END


Update List a1MeashoSsbRsrpSA_VoNr
    [Documentation]    [PRIVATE]    update List a1MeashoSsbRsrpSA VoNr in SCF AEQE GMC
    ...       :Autor: Sylvia Schneider
    Log To Console    Updating list a1MeashoSsbRsrpSA for object ${bts_distName}/NRCELL-1
    ${xpath_list}   set variable
    ...   managedObject[@distName="${bts_distName}/NRCELL-1"]/list[@name="a1MeashoSsbRsrpSA"]/item
    FOR   ${element}   IN
    ...    <p name\="a1HysteresisHoSsbRsrpVoNr">0</p>
    ...    <p name\="a1ThresholdHoSsbRsrpVoNr">49</p>
    ...    <p name\="a1TimeToTriggerHoSsbRsrpVoNr">ms480</p>
       Add Element    ${scf_xml}    ${element}      xpath=.//${xpath_list}
    END


Create List a1MeashoSsbRsrqSA_VoNr
    [Documentation]    [PRIVATE]    create List a1MeashoSsbRsrqSA VoNr in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building list a1MeashoSsbRsrqSA for object ${bts_distName}/NRCELL-1
    ${a1MeashoSsbRsrqSA}    set variable    <list name="a1MeashoSsbRsrqSA">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="a1HysteresishoSsbRsrqSA">0</p>
    ...    <p name="a1HysteresisHoSsbRsrqVoNr">0</p>
    ...    <p name="a1ThresholdhoSsbRsrqSA">36</p>
    ...    <p name="a1ThresholdHoSsbRsrqVoNr">46</p>
    ...    <p name="a1TimeToTriggerhoSsbRsrqSA">ms480</p>
    ...    <p name="a1TimeToTriggerHoSsbRsrqVoNr">ms480</p>
    ...    </item>
    ...    </list>
           ${a1MeashoSsbRsrqSA}   Catenate     SEPARATOR=\n         ${a1MeashoSsbRsrqSA}   ${line}
    END
    Add Element     ${scf_xml}     ${a1MeashoSsbRsrqSA}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]


Create single List a2MeashoSsbRsrpSA
    [Documentation]    [PRIVATE]    create single List a2MeashoSsbRsrpSA in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${NRCELL_id}
    Log To Console    Building list a2MeashoSsbRsrpSA for object ${bts_distName}/NRCELL-${NRCELL_id}
    ${a2MeashoSsbRsrpSA}    set variable    <list name="a2MeashoSsbRsrpSA">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="a2HysteresishoSsbRsrpSA">0</p>
    ...    <p name="a2ThresholdhoSsbRsrpSA">38</p>
    ...    <p name="a2TimeToTriggerhoSsbRsrpSA">ms480</p>
    ...    </item>
    ...    </list>
           ${a2MeashoSsbRsrpSA}   Catenate     SEPARATOR=\n         ${a2MeashoSsbRsrpSA}   ${line}
    END
    Add Element     ${scf_xml}     ${a2MeashoSsbRsrpSA}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${NRCELL_id}"]


Create List a2MeashoSsbRsrpSA_B-B8
    [Documentation]    [PRIVATE]    create List a2MeashoSsbRsrpSA in SCF
    ...       :Autor: Sylvia Schneider
    Create single List a2MeashoSsbRsrpSA    NRCELL_id=2


Create List a2MeashoSsbRsrpSA_VoNr
    [Documentation]    [PRIVATE]    create List a2MeashoSsbRsrpSA VoNR in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building list a2MeashoSsbRsrpSA for object ${bts_distName}/NRCELL-1
    ${a2MeashoSsbRsrpSA}    set variable    <list name="a2MeashoSsbRsrpSA">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="a2HysteresishoSsbRsrpSA">0</p>
    ...    <p name="a2HysteresisHoSsbRsrpVoNr">0</p>
    ...    <p name="a2ThresholdhoSsbRsrpSA">38</p>
    ...    <p name="a2ThresholdHoSsbRsrpVoNr">44</p>
    ...    <p name="a2TimeToTriggerhoSsbRsrpSA">ms480</p>
    ...    <p name="a2TimeToTriggerHoSsbRsrpVoNr">ms480</p>
    ...    </item>
    ...    </list>
           ${a2MeashoSsbRsrpSA}   Catenate     SEPARATOR=\n         ${a2MeashoSsbRsrpSA}   ${line}
    END
    Add Element     ${scf_xml}     ${a2MeashoSsbRsrpSA}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]


Create List a2MeashoSsbRsrqSA_VoNr
    [Documentation]    [PRIVATE]    create List a2MeashoSsbRsrqSA VoNr in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building list a2MeashoSsbRsrqSA for object ${bts_distName}/NRCELL-1
    ${a2MeashoSsbRsrqSA}    set variable    <list name="a2MeashoSsbRsrqSA">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="a2HysteresishoSsbRsrqSA">0</p>
    ...    <p name="a2HysteresisHoSsbRsrqVoNr">0</p>
    ...    <p name="a2ThresholdhoSsbRsrqSA">35</p>
    ...    <p name="a2ThresholdHoSsbRsrqVoNr">41</p>
    ...    <p name="a2TimeToTriggerhoSsbRsrqSA">ms480</p>
    ...    <p name="a2TimeToTriggerHoSsbRsrqVoNr">ms480</p>
    ...    </item>
    ...    </list>
           ${a2MeashoSsbRsrqSA}   Catenate     SEPARATOR=\n         ${a2MeashoSsbRsrqSA}   ${line}
    END
    Add Element     ${scf_xml}     ${a2MeashoSsbRsrqSA}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]


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


Create List a3MeasSsbRsrp
    [Documentation]    [PRIVATE]    create List a3MeasSsbRsrp in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${NRCELL_id}=1   ${a3TimeToTriggerSsbRsrp}=ms320
    Log To Console    Building list a3MeasSsbRsrp for object ${bts_distName}/NRCELL-${NRCELL_id}
    ${a3MeasSsbRsrp}    set variable    <list name="a3MeasSsbRsrp">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="a3HysteresisSsbRsrp">0</p>
    ...    <p name="a3OffsetSsbRsrp">6</p>
    ...    <p name="a3TimeToTriggerSsbRsrp">${a3TimeToTriggerSsbRsrp}</p>
    ...    </item>
    ...    </list>
           ${a3MeasSsbRsrp}   Catenate     SEPARATOR=\n         ${a3MeasSsbRsrp}   ${line}
    END
    Add Element     ${scf_xml}     ${a3MeasSsbRsrp}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${NRCELL_id}"]


Create List a3MeasSsbRsrp_B-B8
    [Documentation]    [PRIVATE]    create List a3MeasSsbRsrp in SCF for NRCELL-1 and NRCELL-2
    ...       :Autor: Sylvia Schneider
    Create List a3MeasSsbRsrp     NRCELL_id=1    a3TimeToTriggerSsbRsrp=ms320
    Create List a3MeasSsbRsrp     NRCELL_id=2    a3TimeToTriggerSsbRsrp=ms100


Create List a3MeasSsbRsrq
    [Documentation]    [PRIVATE]    create List a3MeasSsbRsrq in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building list a3MeasSsbRsrq for object ${bts_distName}/NRCELL-1
    ${a3MeasSsbRsrq}    set variable    <list name="a3MeasSsbRsrq">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="a3HysteresisSsbRsrq">0</p>
    ...    <p name="a3OffsetSsbRsrq">6</p>
    ...    <p name="a3TimeToTriggerSsbRsrq">ms320</p>
    ...    </item>
    ...    </list>
           ${a3MeasSsbRsrq}   Catenate     SEPARATOR=\n         ${a3MeasSsbRsrq}   ${line}
    END
    Add Element     ${scf_xml}     ${a3MeasSsbRsrq}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]


Create List a5MeasSsbRsrp
    [Documentation]    [PRIVATE]    create List a5MeasSsbRsrp in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${NRCELL_id}=1   ${a5Threshold1SsbRsrp}=70   ${a5Threshold2SsbRsrp}=75
    Log To Console    Building list a5MeasSsbRsrp for object ${bts_distName}/NRCELL-1
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


Create List a5MeasSsbRsrp_B-B8
    [Documentation]    [PRIVATE]    create List a5MeasSsbRsrp in SCF
    ...       :Autor: Sylvia Schneider
    FOR   ${NRCELL_id}   IN  1   2
      Create List a5MeasSsbRsrp     NRCELL_id=${NRCELL_id}   a5Threshold1SsbRsrp=52   a5Threshold2SsbRsrp=54
    END


Update List a5MeasSsbRsrp
    [Documentation]    [PRIVATE]    create List a5MeasSsbRsrp in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Update list a5MeasSsbRsrp for object ${bts_distName}/NRCELL-3 and NRCELL-4
    FOR   ${NRCELL_id}   IN   3   4
       Set Element Text   ${scf_xml}   text=70
       ...   xpath=.//managedObject[@distName\="${bts_distName}/NRCELL-${NRCELL_id}"]/list[@name="a5MeasSsbRsrp"]/item/p[@name="a5Threshold1SsbRsrp"]
       Set Element Text   ${scf_xml}   text=75
       ...   xpath=.//managedObject[@distName\="${bts_distName}/NRCELL-${NRCELL_id}"]/list[@name="a5MeasSsbRsrp"]/item/p[@name="a5Threshold2SsbRsrp"]
    END
