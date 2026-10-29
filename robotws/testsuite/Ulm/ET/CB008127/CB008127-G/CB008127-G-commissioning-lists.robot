*** Settings ***
Documentation   This is a keyword file for CB008127-G, part commissioning, new lists
...             Team: 'MN RAN RD VRF ULM6'
...             Author: Shruthi Shivaprasad
#-------------------------------------------------------------------------------------------------------------


*** Keywords ***


Add List a1MeashoPrefNRLayerSsbRsrp
    [Documentation]    [PRIVATE]    create List a1MeashoPrefNRLayerSsbRsrp in SCF
    ...       :Autor: Shruthi Shivaprasad
    ${a1MeashoPrefNRLayerSsbRsrp}    set variable    <list name="a1MeashoPrefNRLayerSsbRsrp">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="a1HysteresisSsbRsrp">0</p>
    ...    <p name="a1ThresholdhoSsbRsrp">108</p>
    ...    <p name="a1TimeToTriggerhoSsbRsrp">ms40</p>
    ...    </item>
    ...    </list>
           ${a1MeashoPrefNRLayerSsbRsrp}   Catenate     SEPARATOR=\n         ${a1MeashoPrefNRLayerSsbRsrp}   ${line}
    END
    Log To Console    Building list a1MeashoPrefNRLayerSsbRsrp for object ${bts_distName}/NRCELL-1
    Add Element     ${scf_xml}     ${a1MeashoPrefNRLayerSsbRsrp}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]


Add List a1MeashoPrefNRLayerSsbRsrq
    [Documentation]    [PRIVATE]    create List a1MeashoPrefNRLayerSsbRsrq in SCF
    ...       :Autor: Shruthi Shivaprasad
    ${a1MeashoPrefNRLayerSsbRsrq}    set variable    <list name="a1MeashoPrefNRLayerSsbRsrq">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="a1HysteresisSsbRsrq">0</p>
    ...    <p name="a1ThresholdhoSsbRsrq">107</p>
    ...    <p name="a1TimeToTriggerhoSsbRsrq">ms40</p>
    ...    </item>
    ...    </list>
           ${a1MeashoPrefNRLayerSsbRsrq}   Catenate     SEPARATOR=\n         ${a1MeashoPrefNRLayerSsbRsrq}   ${line}
    END
    Log To Console    Building list a1MeashoPrefNRLayerSsbRsrq for object ${bts_distName}/NRCELL-1
    Add Element     ${scf_xml}     ${a1MeashoPrefNRLayerSsbRsrq}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]



Add List a2MeasReleaseSsbRsrp
    [Documentation]    [PRIVATE]    create List a2MeasReleaseSsbRsrp in SCF
    ...       :Autor: Shruthi Shivaprasad
    ${a2MeasReleaseSsbRsrp}    set variable    <list name="a2MeasReleaseSsbRsrp">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="a2HysteresisReleaseSsbRsrp">0</p>
    ...    <p name="a2ThresholdReleaseSsbRsrp">24</p>
    ...    <p name="a2TimeToTriggerReleaseSsbRsrp">ms480</p>
    ...    </item>
    ...    </list>
           ${a2MeasReleaseSsbRsrp}   Catenate     SEPARATOR=\n         ${a2MeasReleaseSsbRsrp}   ${line}
    END
    Log To Console    Building list a2MeasReleaseSsbRsrp for object ${bts_distName}/NRCELL-1
    Add Element     ${scf_xml}     ${a2MeasReleaseSsbRsrp}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]
    Log To Console    Building list a2MeasReleaseSsbRsrp for object ${bts_distName}/NRCELL-2
    Add Element     ${scf_xml}     ${a2MeasReleaseSsbRsrp}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]


Add List a2MeasReleaseSsbRsrq
    [Documentation]    [PRIVATE]    create List a2MeasReleaseSsbRsrq in SCF
    ...       :Autor: Shruthi Shivaprasad
    ${a2MeasReleaseSsbRsrq}    set variable    <list name="a2MeasReleaseSsbRsrq">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="a2HysteresisReleaseSsbRsrq">0</p>
    ...    <p name="a2ThresholdReleaseSsbRsrq">23</p>
    ...    <p name="a2TimeToTriggerReleaseSsbRsrq">ms480</p>
    ...    </item>
    ...    </list>
           ${a2MeasReleaseSsbRsrq}   Catenate     SEPARATOR=\n         ${a2MeasReleaseSsbRsrq}   ${line}
    END
    Log To Console    Building list a2MeasReleaseSsbRsrq for object ${bts_distName}/NRCELL-1
    Add Element     ${scf_xml}     ${a2MeasReleaseSsbRsrq}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]
    Log To Console    Building list a2MeasReleaseSsbRsrq for object ${bts_distName}/NRCELL-2
    Add Element     ${scf_xml}     ${a2MeasReleaseSsbRsrq}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]


Add List a3MeasSsbRsrp
    [Documentation]    [PRIVATE]    create List a3MeasSsbRsrp for NRCELL objects in SCF
    ...       :Autor: Shruthi Shivaprasad
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
    Log To Console    Building list a3MeasSsbRsrp for object ${bts_distName}/NRCELL-1
    Add Element     ${scf_xml}     ${new_list}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]
    Log To Console    Building list a3MeasSsbRsrp for object ${bts_distName}/NRCELL-2
    Add Element     ${scf_xml}     ${new_list}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]


Add List a3MeasSsbRsrq
    [Documentation]    [PRIVATE]    create List a3MeasSsbRsrq in SCF
    ...       :Autor: Shruthi Shivaprasad
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
    Log To Console    Building list a3MeasSsbRsrq for object ${bts_distName}/NRCELL-1
    Add Element     ${scf_xml}     ${new_list}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]
    Log To Console    Building list a3MeasSsbRsrq for object ${bts_distName}/NRCELL-2
    Add Element     ${scf_xml}     ${new_list}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]


Add single List a4PeriodicMeasControlNSA
    [Documentation]    [PRIVATE]    create single List a4PeriodicMeasControlNSA for NRCELL objects in SCF
    ...       :Autor: Shruthi Shivaprasad
    [Arguments]   ${a4Fr1SupervisionTimer}   ${NRCELL-id}
    ${new_list}    set variable    <list name="a4PeriodicMeasControlNSA">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="a4Fr1SupervisionTimer">${a4Fr1SupervisionTimer}</p>
    ...    <p name="a4Fr2SupervisionTimer">6000</p>
    ...    <p name="a4MeasMaxNumber">5</p>
    ...    <p name="a4RetryTimer">10</p>
    ...    </item>
    ...    </list>
           ${new_list}   Catenate     SEPARATOR=\n         ${new_list}   ${line}
    END
    Log To Console    Building list a3MeasSsbRsrq for object ${bts_distName}/NRCELL-${NRCELL-id}
    Add Element     ${scf_xml}     ${new_list}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${NRCELL-id}"]


Add List a4PeriodicMeasControlNSA
    [Documentation]    [PRIVATE]    create List a4PeriodicMeasControlNSA for NRCELL objects in SCF
    ...       :Autor: Shruthi Shivaprasad
    FOR    ${cell_id}   ${a4Fr1SupervisionTimer}    IN
    ...    1            10000
    ...    2            4000
    ...    3            4000
    ...    4            4000
       Add single List a4PeriodicMeasControlNSA    a4Fr1SupervisionTimer=${a4Fr1SupervisionTimer}   NRCELL-id=${cell_id}
    END


Add List a4MeasSsbRsrp
    [Documentation]    [PRIVATE]    create List a4MeasSsbRsrp for NRHOIF objects in SCF
    ...       :Autor: Shruthi Shivaprasad
    ${new_list}    set variable    <list name="a4MeasSsbRsrp">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="a4HysteresisSsbRsrp">2</p>
    ...    <p name="a4ThresholdSsbRsrp">35</p>
    ...    <p name="a4TimeToTriggerSsbRsrp">ms64</p>
    ...    </item>
    ...    </list>
           ${new_list}   Catenate     SEPARATOR=\n         ${new_list}   ${line}
    END
    Log To Console    Building list a4MeasSsbRsrp for object ${bts_distName}/NRCELL-1/NRHOIF-1
    Add Element     ${scf_xml}     ${new_list}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1/NRHOIF-1"]


Add List a4MeasSsbRsrq
    [Documentation]    [PRIVATE]    create List a4MeasSsbRsrq for NRHOIF objects in SCF
    ...       :Autor: Shruthi Shivaprasad
    ${new_list}    set variable    <list name="a4MeasSsbRsrq">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="a4HysteresisSsbRsrq">2</p>
    ...    <p name="a4ThresholdSsbRsrq">35</p>
    ...    <p name="a4TimeToTriggerSsbRsrq">ms64</p>
    ...    </item>
    ...    </list>
           ${new_list}   Catenate     SEPARATOR=\n         ${new_list}   ${line}
    END
    Log To Console    Building list a4MeasSsbRsrq for object ${bts_distName}/NRCELL-1/NRHOIF-1
    Add Element     ${scf_xml}     ${new_list}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1/NRHOIF-1"]


Add List a5MeasSsbRsrp
    [Documentation]    [PRIVATE]    create List a5MeasSsbRsrp for NRCELL objects in SCF
    ...       :Autor: Shruthi Shivaprasad
    ${new_list}    set variable    <list name="a5MeasSsbRsrp">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="a5HysteresisSsbRsrp">0</p>
    ...    <p name="a5Threshold1SsbRsrp">82</p>
    ...    <p name="a5Threshold2SsbRsrp">87</p>
    ...    <p name="a5TimeToTriggerSsbRsrp">ms100</p>
    ...    </item>
    ...    </list>
           ${new_list}   Catenate     SEPARATOR=\n         ${new_list}   ${line}
    END
    Log To Console    Building list a5MeasSsbRsrp for object ${bts_distName}/NRCELL-1
    Add Element     ${scf_xml}     ${new_list}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]
    Log To Console    Building list a5MeasSsbRsrp for object ${bts_distName}/NRCELL-2
    Add Element     ${scf_xml}     ${new_list}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]


Add List a5MeasSsbRsrq
    [Documentation]    [PRIVATE]    create List a5MeasSsbRsrq in SCF
    ...       :Autor: Shruthi Shivaprasad
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
    Log To Console    Building list a5MeasSsbRsrq for object ${bts_distName}/NRCELL-1
    Add Element     ${scf_xml}     ${new_list}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]
    Log To Console    Building list a5MeasSsbRsrq for object ${bts_distName}/NRCELL-2
    Add Element     ${scf_xml}     ${new_list}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]


Add List measPrMaNSAList to NRCELL-${nrcell_id}
    [Documentation]    [PRIVATE]    create List measPrMaSAList for NRCELL in SCF
    ...       :Autor: Shruthi Shivaprasad
    Log To Console    Building list measPrMaSAList for object ${bts_distName}/NRCELL-${nrcell_id}
    ${new_list}    set variable    <list name="measPrMaNSAList">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="measPrPriority">8</p>
    ...    <p name="nrMeasPrMaNSADN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-1</p>
    ...    </item>
    ...    <item>
    ...    <p name="measPrPriority">6</p>
    ...    <p name="nrMeasPrMaNSADN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-2</p>
    ...    </item>
    ...    <item>
    ...    <p name="measPrPriority">7</p>
    ...    <p name="nrMeasPrMaNSADN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-3</p>
    ...    </item>
    ...    </list>
           ${new_list}   Catenate     SEPARATOR=\n         ${new_list}   ${line}
    END
    Add Element     ${scf_xml}     ${new_list}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${nrcell_id}"]


update measPrMaNSAList for NRCELL-${id}
    [Documentation]    [PRIVATE]    update measPrMaNSAList for single NRCELL
    ...       :Autor: Shruthi Shivaprasad
    Log To Console    update list measPrMaSAList for object ${bts_distName}/NRCELL-${id}
    ${item}   set variable   ${EMPTY}
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="measPrPriority">6</p>
    ...    <p name="nrMeasPrMaNSADN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-3</p>
    ...    </item>
           ${item}   Catenate     SEPARATOR=\n         ${item}   ${line}
    END
    Add Element     ${scf_xml}     ${item}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-${id}"]list[@name="measPrMaNSAList"]


Add single List nrMeasPrIefList
    [Documentation]    [PRIVATE]    add single List nrMeasPrIefList in SCF
    ...       :Autor: Shruthi Shivaprasad
    [Arguments]   ${NRMEASPR_IEF_id}
    ${new_list}    set variable    <list name="nrMeasPrIefList">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="nrMeasPrIefDN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IEF-${NRMEASPR_IEF_id}</p>
    ...    <p name="ssbFrequency01">636576</p>
    ...    </item>
    ...    </list>
           ${new_list}   Catenate     SEPARATOR=\n         ${new_list}   ${line}
    END
    Log To Console    Building list nrMeasPrIefList for object ${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-1
    Add Element    ${scf_xml}   ${new_list}   xpath=.//managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-${NRMEASPR_IEF_id}"]


Add List nrMeasPrIefList
    [Documentation]    [PRIVATE]    add List nrMeasPrIefList in SCF
    ...       :Autor: Shruthi Shivaprasad
    FOR   ${id}   IN   1
      Add single List nrMeasPrIefList    NRMEASPR_IEF_id=${id}
    END


Add single List nrMeasPrIefList t4
    [Documentation]    [PRIVATE]    add single List nrMeasPrIefList in SCF
    ...       :Autor: Shruthi Shivaprasad
    [Arguments]   ${NRMEASPR_IEF_id}
    ${new_list}    set variable    <list name="nrMeasPrIefList">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="nrMeasPrIefDN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IEF-${NRMEASPR_IEF_id}</p>
    ...    <p name="ssbFrequency01">636576</p>
    ...    </item>
    ...    </list>
           ${new_list}   Catenate     SEPARATOR=\n         ${new_list}   ${line}
    END
    Log To Console    Building list nrMeasPrIefList for object ${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-3
    Add Element    ${scf_xml}   ${new_list}   xpath=.//managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-3"]


Add List nrMeasPrIefList t4
    [Documentation]    [PRIVATE]    add List nrMeasPrIefList in SCF
    ...       :Autor: Shruthi Shivaprasad
    FOR   ${id}   IN   1
      Add single List nrMeasPrIefList t4  NRMEASPR_IEF_id=${id}
    END

