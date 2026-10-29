*** Settings ***
Documentation   This is a keyword file for CB013511, part commissioning objects
...             Team: 'MI MN RAN RD VRF ULM 4'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
Library   XML

*** Keywords ***

Add Objects For Common_A_SE_TC02_TC03
    [Documentation]    [PRIVATE]    Add Objects For Common_A_SE_TC02_TC03
    ...       :Author: Sylvia Schneider
    FOR   ${object}   IN
    ...   NRPLMNSET_NSA
    ...   NRREL
    ...   NRMEAS_PROFILE
    ...   NRCACLASS
    ...   NRMEASPR_IAF
    ...   NRMEASPR_MA_NSA
    ...   NRMEASPR_SCELL
       Run Keyword   Add ${object} Object
    END


Add Objects For Common_A_SE_TC05
    [Documentation]    [PRIVATE]    Add Objects For Common_A_SE_TC05
    ...       :Author: Sylvia Schneider
    Add NRPLMNSET_NSA Object
    Add NRREL Object TC05
    Add NRMEAS_PROFILE Object
    Add NRCACLASS_TC05 Object
    Add NRMEASPR_IAF-1 And IAF-2 Objects
    Add NRMEASPR_MA_NSA TC05 Objects
    Add NRMEASPR_SCELL Object TC05
    Add NRMOPRMA_NSA Objects TC05
    Add NRMOPR_NSA-3


Add Objects For Common_A_SE_TC04
    [Documentation]    [PRIVATE]    Add Objects For Common_A_SE_TC04
    ...       :Author: Sylvia Schneider
    Add NRREL Object
    Add NRPLMNSET_NSA Object
    Add NRMEAS_PROFILE Object
    Add Single NRCACLASS-1 Object
    Add Single NRCACLASS-2 Object
    Add NRCACLASS-3 Object With caBandList And caBandList2 TC04
    Add NRMEASPR_IAF Object TC04
    Update NRMEASPR_IAF Object TC05
    Add NRMEASPR_MA_NSA TC04 Objects
    Add NRMEASPR_SCELL Object TC04


Add NRMEASPR_IAF-1 And IAF-2 Objects
    [Documentation]    [PRIVATE]    Add NRMEASPR_IAF-1 Object
    ...       :Author: Sylvia Schneider
    Create Single Add NRMEASPR_IAF Object   1
    Create Single Add NRMEASPR_IAF Object   2


Create List a1MeasSCellAddSsbRsrp For NRMEASPR_IAF
    [Documentation]    [PRIVATE]    Create List a1MeasSCellAddSsbRsrp For NRMEASPR_IAF
    ...       :Author: Sylvia Schneider
    [Arguments]   ${a1ThresholdSCellAddSsbRsrpFDD}   ${a1ThresholdSCellAddSsbRsrpTDD}   ${a1TimeToTriggerSCellAddSsbRsrp}
    ${a1MeasSCellAddSsbRsrp}  Catenate      SEPARATOR=\n
    ...    <list name="a1MeasSCellAddSsbRsrp">
    ...    <item>
    ...    <p name="a1HysteresisSCellAddSsbRsrp">2</p>
    ...    <p name="a1ThresholdSCellAddSsbRsrpFDD">${a1ThresholdSCellAddSsbRsrpFDD}</p>
    ...    <p name="a1ThresholdSCellAddSsbRsrpTDD">${a1ThresholdSCellAddSsbRsrpTDD}</p>
    ...    <p name="a1TimeToTriggerSCellAddSsbRsrp">${a1TimeToTriggerSCellAddSsbRsrp}</p>
    ...    </item>
    ...    </list>
    RETURN   ${a1MeasSCellAddSsbRsrp}


Create List a1MeashoSsbRsrp For NRMEASPR_IAF
    [Documentation]    [PRIVATE]    Create List a1MeashoSsbRsrp For NRMEASPR_IAF
    ...       :Author: Sylvia Schneider
    [Arguments]   ${a1ThresholdhoSsbRsrp}   ${a1TimeToTriggerhoSsbRsrp}
    ${a1MeashoSsbRsrp}  Catenate      SEPARATOR=\n
    ...    <list name="a1MeashoSsbRsrp">
    ...    <item>
    ...    <p name="a1HysteresishoSsbRsrp">4</p>
    ...    <p name="a1ThresholdhoSsbRsrp">${a1ThresholdhoSsbRsrp}</p>
    ...    <p name="a1TimeToTriggerhoSsbRsrp">${a1TimeToTriggerhoSsbRsrp}</p>
    ...    </item>
    ...    </list>
    RETURN   ${a1MeashoSsbRsrp}


Create List a2MeasRedirectSsbRsrp For NRMEASPR_IAF
    [Documentation]    [PRIVATE]    Create List a2MeasRedirectSsbRsrp For NRMEASPR_IAF
    ...       :Author: Sylvia Schneider
    [Arguments]   ${a2ThresholdRedirectSsbRsrp}   ${a2TimeToTriggerRedirectSsbRsrp}
    ${a2MeasRedirectSsbRsrp}  Catenate      SEPARATOR=\n
    ...    <list name="a2MeasRedirectSsbRsrp">
    ...    <item>
    ...    <p name="a2HysteresisRedirectSsbRsrp">2</p>
    ...    <p name="a2ThresholdRedirectSsbRsrp">${a2ThresholdRedirectSsbRsrp}</p>
    ...    <p name="a2TimeToTriggerRedirectSsbRsrp">${a2TimeToTriggerRedirectSsbRsrp}</p>
    ...    </item>
    ...    </list>
    RETURN   ${a2MeasRedirectSsbRsrp}


Create List a2MeasReleaseSsbRsrp For NRMEASPR_IAF
    [Documentation]    [PRIVATE]    Create List a2MeasReleaseSsbRsrp For NRMEASPR_IAF
    ...       :Author: Sylvia Schneider
    [Arguments]   ${a2ThresholdReleaseSsbRsrp}   ${a2TimeToTriggerReleaseSsbRsrp}
    ${a2MeasReleaseSsbRsrp}  Catenate      SEPARATOR=\n
    ...    <list name="a2MeasReleaseSsbRsrp">
    ...    <item>
    ...    <p name="a2HysteresisReleaseSsbRsrp">2</p>
    ...    <p name="a2ThresholdReleaseSsbRsrp">${a2ThresholdReleaseSsbRsrp}</p>
    ...    <p name="a2TimeToTriggerReleaseSsbRsrp">${a2TimeToTriggerReleaseSsbRsrp}</p>
    ...    </item>
    ...    </list>
    RETURN   ${a2MeasReleaseSsbRsrp}


Create List a2MeashoSsbRsrp For NRMEASPR_IAF
    [Documentation]    [PRIVATE]    Create List a2MeashoSsbRsrp For NRMEASPR_IAF
    ...       :Author: Sylvia Schneider
    [Arguments]    ${a2ThresholdhoSsbRsrp}   ${a2TimeToTriggerhoSsbRsrp}
    ${a2MeashoSsbRsrp}  Catenate      SEPARATOR=\n
    ...    <list name="a2MeashoSsbRsrp">
    ...    <item>
    ...    <p name="a2HysteresishoSsbRsrp">2</p>
    ...    <p name="a2ThresholdhoSsbRsrp">${a2ThresholdhoSsbRsrp}</p>
    ...    <p name="a2TimeToTriggerhoSsbRsrp">${a2TimeToTriggerhoSsbRsrp}</p>
    ...    </item>
    ...    </list>
    RETURN   ${a2MeashoSsbRsrp}


Create List a3MeasSsbRsrp For NRMEASPR_IAF
    [Documentation]    [PRIVATE]    Create List a3MeasSsbRsrp For NRMEASPR_IAF
    ...       :Author: Sylvia Schneider
    [Arguments]    ${a3OffsetSsbRsrp}   ${a3TimeToTriggerSsbRsrp}
    ${a3MeasSsbRsrp}  Catenate      SEPARATOR=\n
    ...    <list name="a3MeasSsbRsrp">
    ...    <item>
    ...    <p name="a3HysteresisSsbRsrp">2</p>
    ...    <p name="a3OffsetSsbRsrp">${a3OffsetSsbRsrp}</p>
    ...    <p name="a3TimeToTriggerSsbRsrp">${a3TimeToTriggerSsbRsrp}</p>
    ...    </item>
    ...    </list>
    RETURN   ${a3MeasSsbRsrp}


Create List a5MeasSsbRsrp For NRMEASPR_IAF
    [Documentation]    [PRIVATE]    Create List a5MeasSsbRsrp For NRMEASPR_IAF
    ...       :Author: Sylvia Schneider
    [Arguments]    ${a5Threshold1SsbRsrp}   ${a5Threshold2SsbRsrp}   ${a5TimeToTriggerSsbRsrp}
    ${a5MeasSsbRsrp}  Catenate      SEPARATOR=\n
    ...    <list name="a5MeasSsbRsrp">
    ...    <item>
    ...    <p name="a5HysteresisSsbRsrp">2</p>
    ...    <p name="a5Threshold1SsbRsrp">${a5Threshold1SsbRsrp}</p>
    ...    <p name="a5Threshold2SsbRsrp">${a5Threshold2SsbRsrp}</p>
    ...    <p name="a5TimeToTriggerSsbRsrp">${a5TimeToTriggerSsbRsrp}</p>
    ...    </item>
    ...    </list>
    RETURN   ${a5MeasSsbRsrp}


Create Single Add NRMEASPR_IAF Object
    [Documentation]    [PRIVATE]    Create Single Add NRMEASPR_IAF Object
    ...       :Author: Sylvia Schneider
    [Arguments]   ${id}
    Log To Console   Add NRMEASPR_IAF-${id} Object

    ${a1ThresholdSCellAddSsbRsrpFDD}     Create List   ${EMPTY}   38       41
    ${a1ThresholdSCellAddSsbRsrpTDD}     Create List   ${EMPTY}   38       41
    ${a1TimeToTriggerSCellAddSsbRsrp}    Create List   ${EMPTY}   160ms    480ms
    ${a1MeasSCellAddSsbRsrp}             Create List a1MeasSCellAddSsbRsrp For NRMEASPR_IAF
    ...   ${a1ThresholdSCellAddSsbRsrpFDD}[${id}]   ${a1ThresholdSCellAddSsbRsrpTDD}[${id}]   ${a1TimeToTriggerSCellAddSsbRsrp}[${id}]

    ${a2ThresholdRedirectSsbRsrp}        Create List   ${EMPTY}   46       47
    ${a2TimeToTriggerRedirectSsbRsrp}    Create List   ${EMPTY}   ms320    ms512
    ${a2MeasRedirectSsbRsrp}             Create List a2MeasRedirectSsbRsrp For NRMEASPR_IAF
    ...   ${a2ThresholdRedirectSsbRsrp}[${id}]   ${a2TimeToTriggerRedirectSsbRsrp}[${id}]

    ${a2ThresholdReleaseSsbRsrp}         Create List   ${EMPTY}   40       43
    ${a2TimeToTriggerReleaseSsbRsrp}     Create List   ${EMPTY}   ms480    ms320
    ${a2MeasReleaseSsbRsrp}              Create List a2MeasReleaseSsbRsrp For NRMEASPR_IAF
    ...   ${a2ThresholdReleaseSsbRsrp}[${id}]   ${a2TimeToTriggerReleaseSsbRsrp}[${id}]

    ${a2ThresholdhoSsbRsrp}              Create List   ${EMPTY}   46       49
    ${a2TimeToTriggerhoSsbRsrp}          Create List   ${EMPTY}   ms320    ms512
    ${a2MeashoSsbRsrp}                   Create List a2MeashoSsbRsrp For NRMEASPR_IAF
    ...   ${a2ThresholdhoSsbRsrp}[${id}]   ${a2TimeToTriggerhoSsbRsrp}[${id}]

    ${a3OffsetSsbRsrp}                   Create List   ${EMPTY}   10       11
    ${a3TimeToTriggerSsbRsrp}            Create List   ${EMPTY}   ms480    ms256
    ${a3MeasSsbRsrp}                     Create List a3MeasSsbRsrp For NRMEASPR_IAF
    ...   ${a3OffsetSsbRsrp}[${id}]   ${a3TimeToTriggerSsbRsrp}[${id}]

    ${a5Threshold1SsbRsrp}               Create List   ${EMPTY}   68       65
    ${a5Threshold2SsbRsrp}               Create List   ${EMPTY}   63       60
    ${a5TimeToTriggerSsbRsrp}            Create List   ${EMPTY}   ms160    ms480
    ${a5MeasSsbRsrp}                     Create List a5MeasSsbRsrp For NRMEASPR_IAF
    ...   ${a5Threshold1SsbRsrp}[${id}]   ${a5Threshold2SsbRsrp}[${id}]   ${a5TimeToTriggerSsbRsrp}[${id}]

    ${header}   Catenate
    ...   <managedObject class="com.nokia.srbts.nrbts:NRMEASPR_IAF" distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-${id}"
    ...   version="${SCF.version}" operation="create">
    ${new_MO}  Catenate      SEPARATOR=\n
    ...   ${header}
    ...    ${a1MeasSCellAddSsbRsrp}
    ...    ${a2MeasRedirectSsbRsrp}
    ...    ${a2MeasReleaseSsbRsrp}
    ...    ${a2MeashoSsbRsrp}
    ...    ${a3MeasSsbRsrp}
    ...    ${a5MeasSsbRsrp}
    ...    </managedObject>
    XML.Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create Single NRMEASPR_IAF Object TC04
    [Documentation]    [PRIVATE]    Create Single NRMEASPR_IAF Object
    ...       :Author: Sylvia Schneider
    [Arguments]   ${id}
    Log To Console   Add NRMEASPR_IAF-${id} Object

    ${a1ThresholdSCellAddSsbRsrpFDD}     Create List   ${EMPTY}   38       39       42
    ${a1ThresholdSCellAddSsbRsrpTDD}     Create List   ${EMPTY}   38       39       42
    ${a1TimeToTriggerSCellAddSsbRsrp}    Create List   ${EMPTY}   160ms    480ms    512ms
    ${a1MeasSCellAddSsbRsrp}             Create List a1MeasSCellAddSsbRsrp For NRMEASPR_IAF
    ...   ${a1ThresholdSCellAddSsbRsrpFDD}[${id}]   ${a1ThresholdSCellAddSsbRsrpTDD}[${id}]   ${a1TimeToTriggerSCellAddSsbRsrp}[${id}]

    ${a1ThresholdhoSsbRsrp}              Create List   ${EMPTY}   78       78       80
    ${a1TimeToTriggerhoSsbRsrp}          Create List   ${EMPTY}   ms512    ms512    ms480
    ${a1MeashoSsbRsrp}                   Create List a1MeashoSsbRsrp For NRMEASPR_IAF
    ...   ${a1ThresholdhoSsbRsrp}[${id}]   ${a1TimeToTriggerhoSsbRsrp}[${id}]

    ${a2ThresholdRedirectSsbRsrp}        Create List   ${EMPTY}   46       47       48
    ${a2TimeToTriggerRedirectSsbRsrp}    Create List   ${EMPTY}   ms320    ms640    ms256
    ${a2MeasRedirectSsbRsrp}             Create List a2MeasRedirectSsbRsrp For NRMEASPR_IAF
    ...   ${a2ThresholdRedirectSsbRsrp}[${id}]   ${a2TimeToTriggerRedirectSsbRsrp}[${id}]

    ${a2ThresholdReleaseSsbRsrp}         Create List   ${EMPTY}   40       43       44
    ${a2TimeToTriggerReleaseSsbRsrp}     Create List   ${EMPTY}   ms480    ms320    ms256
    ${a2MeasReleaseSsbRsrp}              Create List a2MeasReleaseSsbRsrp For NRMEASPR_IAF
    ...   ${a2ThresholdReleaseSsbRsrp}[${id}]   ${a2TimeToTriggerReleaseSsbRsrp}[${id}]

    ${a2ThresholdhoSsbRsrp}              Create List   ${EMPTY}   76       78       80
    ${a2TimeToTriggerhoSsbRsrp}          Create List   ${EMPTY}   ms512    ms640    ms480
    ${a2MeashoSsbRsrp}                   Create List a2MeashoSsbRsrp For NRMEASPR_IAF
    ...   ${a2ThresholdhoSsbRsrp}[${id}]   ${a2TimeToTriggerhoSsbRsrp}[${id}]

    ${a3OffsetSsbRsrp}                   Create List   ${EMPTY}   6        8        4
    ${a3TimeToTriggerSsbRsrp}            Create List   ${EMPTY}   ms1024   ms1280   ms640
    ${a3MeasSsbRsrp}                     Create List a3MeasSsbRsrp For NRMEASPR_IAF
    ...   ${a3OffsetSsbRsrp}[${id}]   ${a3TimeToTriggerSsbRsrp}[${id}]

    ${a5Threshold1SsbRsrp}               Create List   ${EMPTY}   68       69       67
    ${a5Threshold2SsbRsrp}               Create List   ${EMPTY}   63       64       62
    ${a5TimeToTriggerSsbRsrp}            Create List   ${EMPTY}   ms480    ms640    ms512
    ${a5MeasSsbRsrp}                     Create List a5MeasSsbRsrp For NRMEASPR_IAF
    ...   ${a5Threshold1SsbRsrp}[${id}]   ${a5Threshold2SsbRsrp}[${id}]   ${a5TimeToTriggerSsbRsrp}[${id}]

    ${header}   Catenate
    ...   <managedObject class="com.nokia.srbts.nrbts:NRMEASPR_IAF" distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-${id}"
    ...   version="${SCF.version}" operation="create">
    ${new_MO}  Catenate      SEPARATOR=\n
    ...   ${header}
    ...    ${a1MeasSCellAddSsbRsrp}
    ...    ${a1MeashoSsbRsrp}
    ...    ${a2MeasRedirectSsbRsrp}
    ...    ${a2MeasReleaseSsbRsrp}
    ...    ${a2MeashoSsbRsrp}
    ...    ${a3MeasSsbRsrp}
    ...    ${a5MeasSsbRsrp}
    ...    </managedObject>
    XML.Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Add NRMEASPR_IAF Object TC04
    [Documentation]    [PRIVATE]    Add NRMEASPR_IAF Object TC04
    ...       :Author: Sylvia Schneider
    FOR   ${id}  IN  1   2   3
       Create Single NRMEASPR_IAF Object TC04    ${id}
    END


Update NRMEASPR_IAF Object TC05
    [Documentation]    [PRIVATE]    Update NRMEASPR_IAF Object TC05
    ...       :Author: Sylvia Schneider
    Log To Console   Set NRMEASPR_IAF-1, 2, 3 lists a2MeashoSsbRsrp, a3MeasSsbRsrp, a5MeasSsbRsrp hysteresis to value 4
    FOR   ${id}   IN   1   2   3
         FOR   ${list}            ${param}   IN
         ...   a2MeashoSsbRsrp    a2HysteresishoSsbRsrp
         ...   a3MeasSsbRsrp      a3HysteresisSsbRsrp
         ...   a5MeasSsbRsrp      a5HysteresisSsbRsrp
            ${xpath}  Set Variable   managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-${id}"]
            XML.Set Element Text   ${scf_xml}   text=4    xpath=.//${xpath}/list[@name="${list}"]/item/p[@name="${param}"]
         END
    END


Create Single NRMEASPR_MA_NSA Object TC05
    [Documentation]    [PRIVATE]    Create Single NRMEASPR_MA_NSA Object TC05
    ...       :Author: Sylvia Schneider
    [Arguments]   ${id}
    Log To Console   Add NRMEASPR_MA_NSA-${id} Object
    ${header}   Catenate
    ...   <managedObject class="com.nokia.srbts.nrbts:NRMEASPR_MA_NSA" distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-${id}"
    ...   version="${SCF.version}" operation="create">
    ${new_MO}  Catenate      SEPARATOR=\n
    ...   ${header}
    ...   <list name="nrCaClassDNList">
    ...   <p>NRCACLASS-${id}</p>
    ...   </list>
    ...   <p name="nrMeasPrIafDN">NRMEASPR_IAF-${id}</p>
    ...   <p name="nrMeasPrSCellDefaultDN">NRMEASPR_SCELL-${id}</p>
    ...    </managedObject>
    XML.Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Add NRMEASPR_MA_NSA TC05 Objects
    [Documentation]    [PRIVATE]    Add NRMEASPR_MA_NSA TC05 Objects
    ...       :Author: Sylvia Schneider
    FOR   ${id}  IN  1   2
       Create Single NRMEASPR_MA_NSA Object TC05    ${id}
    END


Create Single NRMEASPR_MA_NSA Object TC04
    [Documentation]    [PRIVATE]    Create Single NRMEASPR_MA_NSA Object TC04
    ...       :Author: Sylvia Schneider
    [Arguments]   ${id}
    Log To Console   Add NRMEASPR_MA_NSA-${id} Object
    ${header}   Catenate
    ...   <managedObject class="com.nokia.srbts.nrbts:NRMEASPR_MA_NSA" distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-${id}"
    ...   version="${SCF.version}" operation="create">
    ${new_MO}  Catenate      SEPARATOR=\n
    ...   ${header}
    ...   <list name="nrCaClassDNList">
    ...   <p>${bts_distName}/NRMEAS_PROFILE-1/NRCACLASS-${id}</p>
    ...   </list>
    ...   <list name="nrMeasPrSCellList">
    ...   <item>
    ...   <p name="nrMeasPrSCellDN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_SCELL-${id}</p>
    ...   <p name="ssbFrequency01">502110</p>
    ...   </item>
    ...   </list>
    ...   <p name="nrMeasPrIafDN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-${id}</p>
    ...    </managedObject>
    XML.Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Add NRMEASPR_MA_NSA TC04 Objects
    [Documentation]    [PRIVATE]    Add NRMEASPR_MA_NSA TC04 Objects
    ...       :Author: Sylvia Schneider
    FOR   ${id}   IN   1   2    3
       Create Single NRMEASPR_MA_NSA Object TC04    ${id}
    END


Create Single NRMOPRMA_NSA Object TC05
    [Documentation]    [PRIVATE]    Create Single NRMOPRMA_NSA Object TC05
    ...       :Author: Sylvia Schneider
    [Arguments]   ${id}   ${spid}
    Log To Console   Add NRMOPRMA_NSA-${id} Object
    ${header}   Catenate
    ...   <managedObject class="com.nokia.srbts.nrbts:NRMOPRMA_NSA" distName="${bts_distName}/NRMOPRMA_NSA-${id}"
    ...   version="${SCF.version}" operation="create">
    ${new_MO}  Catenate      SEPARATOR=\n
    ...   ${header}
    ...   <p name="mobilityProfilePriority">${id}</p>
    ...   <p name="nrMoPrNsaDN">NRMOPR_NSA-${id}</p>
    ...   <p name="spid">${spid}</p>
    ...    </managedObject>
    XML.Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Add NRMOPRMA_NSA Objects TC05
    [Documentation]    [PRIVATE]    Add NRMOPRMA_NSA Objects TC05
    ...       :Author: Sylvia Schneider
    FOR    ${id}    ${spid}    IN
    ...    1        99
    ...    2        98
       Create Single NRMOPRMA_NSA Object TC05    ${id}  ${spid}
    END


Add NRMOPR_NSA-3
    [Documentation]    [PRIVATE]    Add NRMOPR_NSA-3
    ...       :Author: Sylvia Schneider
    ${new_MO}   Catenate
    ...   <managedObject class="com.nokia.srbts.nrbts:NRMOPR_NSA" distName="${bts_distName}/NRMOPR_NSA-3"
    ...   version="${SCF.version}" operation="create"/>
    XML.Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Add Single NRPLMNSET_NSA Object
    [Documentation]    [PRIVATE]    Add Single NRPLMNSET_NSA Object
    ...       :Author: Sylvia Schneider
    [Arguments]    ${nrcell}

    Log To Console    add object ${bts_distName}/NRCELL-${nrcell}/NRPLMNSET_NSA-1
    ${header}   Catenate
    ...   <managedObject class="com.nokia.srbts.nrbts:NRPLMNSET_NSA" distName="${bts_distName}/NRCELL-${nrcell}/NRPLMNSET_NSA-1"
    ...   version="${SCF.version}" operation="create">
    ${new_MO}  Catenate      SEPARATOR=\n
    ...   ${header}
    ...   <p name="cellReservedForOperatorUse">notReserved</p>
    ...   <p name="configuredEpsTac">7151</p>
    ...   <list name="nrPlmnDNList">
    ...   <p>${bts_distName}/NRPLMN-1</p>
    ...   </list>
    ...   </managedObject>
    XML.Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Add NRPLMNSET_NSA Object
    [Documentation]    [PRIVATE]    Add NRPLMNSET_NSA Object
    ...       :Author: Sylvia Schneider
    FOR   ${nrcell}    IN   10   11   13   14
        Add Single NRPLMNSET_NSA Object    ${nrcell}
    END


Add Single NRREL Object
    [Documentation]    [PRIVATE]    Add Single NRREL Object
    ...       :Author: Sylvia Schneider
    [Arguments]   ${nrcell}   ${nrrel}  ${lcrId}   ${sCellPrio}
    Log To Console   add object ${bts_distName}/NRBTS-1/NRCELL-${nrcell}/NRREL-${nrrel}
    ${header}   Catenate
    ...   <managedObject class="com.nokia.srbts.nrbts:NRREL" distName="${bts_distName}/NRCELL-${nrcell}/NRREL-${nrrel}"
    ...   version="${SCF.version}" operation="create">
    ${new_MO}  Catenate      SEPARATOR=\n
    ...   ${header}
    ...   <p name="cellIndividualSsbRsrpOffset">0dB</p>
    ...   <p name="cellIndividualSsbRsrqOffset">0dB</p>
    ...   <p name="gNbId">1</p>
    ...   <p name="gNbIdLength">22</p>
    ...   <p name="handoverAllowedSA">allowed</p>
    ...   <p name="handoverAllowedSARedCap">forbidden</p>
    ...   <p name="isRplCellForPSCell">false</p>
    ...   <p name="lcrId">${lcrId}</p>
    ...   <p name="nrDcAllowed">false</p>
    ...   <p name="removeNotAllowed">false</p>
    ...   <p name="sCellAdditionMethod">covBasedA1</p>
    ...   <p name="sCellOperationalMode">dlOnly</p>
    ...   <p name="sTagRequired">false</p>
    IF   '${sCellPrio}' != '${EMPTY}'
        ${new_MO}  Catenate      SEPARATOR=\n
        ...   ${new_MO}
        ...   <p name="sCellPrio">${sCellPrio}</p>
    END
    ${new_MO}  Catenate      SEPARATOR=\n
    ...   ${new_MO}
    ...   <list name="gnbPlmn">
    ...   <item>
    ...   <p name="mcc">310</p>
    ...   <p name="mnc">260</p>
    ...   <p name="mncLength">3</p>
    ...   </item>
    ...   </list>
    ...   </managedObject>
    XML.Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Add NRREL Object
    [Documentation]    [PRIVATE]    Add NRREL Object
    ...       :Author: Sylvia Schneider
    FOR   ${nrcell}   ${nrrel}  ${lcrId}   ${sCellPrio}   IN
    ...   1           1         6          ${EMPTY}
    ...   1           2         7          10
    ...   1           7         13         ${EMPTY}
    ...   1           8         14         ${EMPTY}
    ...   7           1         1          ${EMPTY}
    ...   7           2         10         ${EMPTY}
    ...   7           3         11         ${EMPTY}
    ...   10          1         1          ${EMPTY}
    ...   11          1         1          ${EMPTY}
        Add Single NRREL Object    ${nrcell}   ${nrrel}  ${lcrId}   ${sCellPrio}
    END


Add NRREL Object TC05
    [Documentation]    [PRIVATE]    Add NRREL Object TC05
    ...       :Author: Sylvia Schneider
    FOR   ${nrcell}   ${nrrel}  ${lcrId}   ${sCellPrio}   IN
    ...   1           1         6          2
    ...   1           2         7          10
    ...   1           4         3          ${EMPTY}
    ...   1           7         13         ${EMPTY}
    ...   1           8         14         ${EMPTY}
    ...   7           1         1          ${EMPTY}
    ...   7           2         10         ${EMPTY}
    ...   7           3         11         ${EMPTY}
    ...   10          1         1          ${EMPTY}
    ...   11          1         1          ${EMPTY}
        Add Single NRREL Object    ${nrcell}   ${nrrel}  ${lcrId}   ${sCellPrio}
    END
    XML.Remove Element    ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1/NRREL-4"]/p[@name="sCellAdditionMethod"]
    XML.Remove Element    ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1/NRREL-4"]/p[@name="sCellOperationalMode"]


Add NRMEAS_PROFILE Object
    [Documentation]    [PRIVATE]    Add NRMEAS_PROFILE Object
    ...       :Author: Sylvia Schneider
    Log To Console   add object ${bts_distName}/NRMEAS_PROFILE-1
    ${new_MO}   Catenate
    ...   <managedObject class="com.nokia.srbts.nrbts:NRMEAS_PROFILE" distName="${bts_distName}/NRMEAS_PROFILE-1"
    ...   version="${SCF.version}" operation="create"/>
    XML.Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Add Single NRCACLASS-1 Object
    [Documentation]    [PRIVATE]    Add Single NRCACLASS-1 Object
    ...       :Author: Sylvia Schneider
    Log To Console   add object ${bts_distName}/NRMEAS_PROFILE-1/NRCACLASS-1
    ${header}   Catenate
    ...   <managedObject class="com.nokia.srbts.nrbts:NRCACLASS" distName="${bts_distName}/NRMEAS_PROFILE-1/NRCACLASS-1"
    ...   version="${SCF.version}" operation="create">
    ${new_MO}  Catenate      SEPARATOR=\n
    ...   ${header}
    ...   <list name="caBandList">
    ...   <p>41</p>
    ...   <p>41</p>
    ...   </list>
    ...   <list name="pCellBandList">
    ...   <p>41</p>
    ...   </list>
    ...   </managedObject>
    XML.Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Add Single NRCACLASS-2 Object
    [Documentation]    [PRIVATE]    Add Single NRCACLASS-2 Object
    ...       :Author: Sylvia Schneider
    Log To Console   add object ${bts_distName}/NRMEAS_PROFILE-1/NRCACLASS-2
    ${header}   Catenate
    ...   <managedObject class="com.nokia.srbts.nrbts:NRCACLASS" distName="${bts_distName}/NRMEAS_PROFILE-1/NRCACLASS-2"
    ...   version="${SCF.version}" operation="create">
    ${new_MO}  Catenate      SEPARATOR=\n
    ...   ${header}
    ...   <list name="caBandList">
    ...   <p>66</p>
    ...   <p>71</p>
    ...   </list>
    ...   <list name="pCellBandList">
    ...   <p>41</p>
    ...   </list>
    ...   </managedObject>
    XML.Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Add Single NRCACLASS-2 TC05 Object
    [Documentation]    [PRIVATE]    Add Single NRCACLASS-2 TC05 Object
    ...       :Author: Sylvia Schneider
    Log To Console   add object ${bts_distName}/NRMEAS_PROFILE-1/NRCACLASS-2
    ${header}   Catenate
    ...   <managedObject class="com.nokia.srbts.nrbts:NRCACLASS" distName="${bts_distName}/NRMEAS_PROFILE-1/NRCACLASS-2"
    ...   version="${SCF.version}" operation="create">
    ${new_MO}  Catenate      SEPARATOR=\n
    ...   ${header}
    ...   <list name="caBandList">
    ...   <p>41</p>
    ...   <p>41</p>
    ...   </list>
    ...   <list name="pCellBandList">
    ...   <p>41</p>
    ...   </list>
    ...   </managedObject>
    XML.Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRCACLASS-3 Object With caBandList And caBandList2
    [Documentation]    [PRIVATE]    Create NRCACLASS-3 Object With caBandList And caBandList2
    ...       :Author: Sylvia Schneider
    Log To Console   add object ${bts_distName}/NRMEAS_PROFILE-1/NRCACLASS-3 With caBandList And caBandList2
    ${header}   Catenate
    ...   <managedObject class="com.nokia.srbts.nrbts:NRCACLASS" distName="${bts_distName}/NRMEAS_PROFILE-1/NRCACLASS-3"
    ...   version="${SCF.version}" operation="create">
    ${new_MO}  Catenate      SEPARATOR=\n
    ...   ${header}
    ...   <list name="caBandList">
    ...   <p>71</p>
    ...   <p>25</p>
    ...   </list>
    ...   <list name="caBandList2">
    ...   <p>41</p>
    ...   <p>41</p>
    ...   </list>
    ...   </managedObject>
    RETURN    ${new_MO}

Add NRCACLASS-3 Object With caBandList And caBandList2
    [Documentation]    [PRIVATE]    Add NRCACLASS-3 Object With caBandList And caBandList2
    ...       :Author: Sylvia Schneider
    ${new_MO}         Create NRCACLASS-3 Object With caBandList And caBandList2
    ${scf_xml_upd}      XML.Parse Xml      ${resultBaseDir}/CB013511_common_A_SE_TC02_TC03.xml
    XML.Add Element     ${scf_xml_upd}     ${new_MO}           xpath=.//cmData
    XML.Save Xml        ${scf_xml_upd}     ${resultDir}/CB013511_TC02.xml


Add NRCACLASS-3 Object With caBandList And caBandList2 TC04
    [Documentation]    [PRIVATE]    Add NRCACLASS-3 Object With caBandList And caBandList2 TC04
    ...       :Author: Sylvia Schneider
    ${new_MO}         Create NRCACLASS-3 Object With caBandList And caBandList2
    XML.Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Add NRCACLASS-3 Object With caBandList
    [Documentation]    [PRIVATE]    Add NRCACLASS-3 Object With caBandList
    ...       :Author: Sylvia Schneider
    Log To Console   add object ${bts_distName}/NRMEAS_PROFILE-1/NRCACLASS-3 With caBandList
    ${header}   Catenate
    ...   <managedObject class="com.nokia.srbts.nrbts:NRCACLASS" distName="${bts_distName}/NRMEAS_PROFILE-1/NRCACLASS-3"
    ...   version="${SCF.version}" operation="create">
    ${new_MO}  Catenate      SEPARATOR=\n
    ...   ${header}
    ...   <list name="caBandList">
    ...   <p>71</p>
    ...   <p>25</p>
    ...   </list>
    ...   </managedObject>
    ${scf_xml_upd}      XML.Parse Xml      ${resultBaseDir}/CB013511_common_A_SE_TC02_TC03.xml
    XML.Add Element     ${scf_xml_upd}     ${new_MO}           xpath=.//cmData
    XML.Save Xml        ${scf_xml_upd}     ${resultDir}/CB013511_TC03.xml


Add NRCACLASS Object
    [Documentation]    [PRIVATE]    Add NRCACLASS Object
    ...       :Author: Sylvia Schneider
    Add Single NRCACLASS-1 Object
    Add Single NRCACLASS-2 Object


Add NRCACLASS_TC05 Object
    [Documentation]    [PRIVATE]    Add NRCACLASS_TC05 Object
    ...       :Author: Sylvia Schneider
    Add Single NRCACLASS-1 Object
    Add Single NRCACLASS-2 TC05 Object


Add Single NRMEASPR_IAF Object
    [Documentation]    [PRIVATE]    Add Single NRMEASPR_IAF Object
    ...       :Author: Sylvia Schneider
    [Arguments]   ${id}

    ${a1ThresholdhoSsbRsrp}        Create List   ${EMPTY}   78       78       80
    ${a1TimeToTriggerhoSsbRsrp}    Create List   ${EMPTY}   ms512    ms512    ms480
    ${a2ThresholdhoSsbRsrp}        Create List   ${EMPTY}   76       76       78
    ${a2TimeToTriggerhoSsbRsrp}    Create List   ${EMPTY}   ms512    ms512    ms480
    ${a3OffsetSsbRsrp}             Create List   ${EMPTY}   6        6        4
    ${a3TimeToTriggerSsbRsrp}      Create List   ${EMPTY}   ms1024   ms1024   ms640
    ${a5Threshold1SsbRsrp}         Create List   ${EMPTY}   68       68       67
    ${a5Threshold2SsbRsrp}         Create List   ${EMPTY}   63       63       62
    ${a5TimeToTriggerSsbRsrp}      Create List   ${EMPTY}   ms480    ms480    ms512

    Log To Console   add object ${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-${id}
    ${header}   Catenate
    ...   <managedObject class="com.nokia.srbts.nrbts:NRMEASPR_IAF" distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-${id}"
    ...   version="${SCF.version}" operation="create">
    ${new_MO}  Catenate      SEPARATOR=\n
    ...   ${header}
    ...   <list name="a1MeashoSsbRsrp">
    ...   <item>
    ...   <p name="a1HysteresishoSsbRsrp">4</p>
    ...   <p name="a1ThresholdhoSsbRsrp">${a1ThresholdhoSsbRsrp}[${id}]</p>
    ...   <p name="a1TimeToTriggerhoSsbRsrp">${a1TimeToTriggerhoSsbRsrp}[${id}]</p>
    ...   </item>
    ...   </list>
    ...   <list name="a2MeashoSsbRsrp">
    ...   <item>
    ...   <p name="a2HysteresishoSsbRsrp">4</p>
    ...   <p name="a2ThresholdhoSsbRsrp">${a2ThresholdhoSsbRsrp}[${id}]</p>
    ...   <p name="a2TimeToTriggerhoSsbRsrp">${a2TimeToTriggerhoSsbRsrp}[${id}]</p>
    ...   </item>
    ...   </list>
    ...   <list name="a3MeasSsbRsrp">
    ...   <item>
    ...   <p name="a3HysteresisSsbRsrp">4</p>
    ...   <p name="a3OffsetSsbRsrp">${a3OffsetSsbRsrp}[${id}]</p>
    ...   <p name="a3TimeToTriggerSsbRsrp">${a3TimeToTriggerSsbRsrp}[${id}]</p>
    ...   </item>
    ...   </list>
    ...   <list name="a5MeasSsbRsrp">
    ...   <item>
    ...   <p name="a5HysteresisSsbRsrp">4</p>
    ...   <p name="a5Threshold1SsbRsrp">${a5Threshold1SsbRsrp}[${id}]</p>
    ...   <p name="a5Threshold2SsbRsrp">${a5Threshold2SsbRsrp}[${id}]</p>
    ...   <p name="a5TimeToTriggerSsbRsrp">${a5TimeToTriggerSsbRsrp}[${id}]</p>
    ...   </item>
    ...   </list>
    ...   </managedObject>
    XML.Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Add NRMEASPR_IAF Object
    [Documentation]    [PRIVATE]    Add NRMEASPR_IAF Object
    ...       :Author: Sylvia Schneider
    FOR   ${id}    IN   1   2   3
        Add Single NRMEASPR_IAF Object    ${id}
    END


Add Single NRMEASPR_MA_NSA Object
    [Documentation]    [PRIVATE]    Add Single NRMEASPR_MA_NSA Object
    ...       :Author: Sylvia Schneider
    [Arguments]   ${id}
    Log To Console   add object ${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-${id}
    ${header}   Catenate
    ...   <managedObject class="com.nokia.srbts.nrbts:NRMEASPR_MA_NSA" distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-${id}"
    ...   version="${SCF.version}" operation="create">
    ${new_MO}  Catenate      SEPARATOR=\n
    ...   ${header}
    ...   <list name="nrCaClassDNList">
    ...   <p>${bts_distName}/NRMEAS_PROFILE-1/NRCACLASS-${id}</p>
    ...   </list>
    ...   <list name="nrMeasPrSCellList">
    ...   <item>
    ...   <p name="nrMeasPrSCellDN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_SCELL-${id}</p>
    ...   <p name="ssbFrequency01">502110</p>
    ...   </item>
    ...   </list>
    ...   <p name="nrMeasPrIafDN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-${id}</p>
    ...   </managedObject>
    XML.Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Add NRMEASPR_MA_NSA Object
    [Documentation]    [PRIVATE]    Add NRMEASPR_MA_NSA Object
    ...       :Author: Sylvia Schneider
    FOR   ${id}    IN   1   2   3
        Add Single NRMEASPR_MA_NSA Object    ${id}
    END


Add Single NRMEASPR_SCELL Object
    [Documentation]    [PRIVATE]    Add NRMEASPR_SCELL To NRMEAS_PROFILE-1 Objects
    ...       :Author: Sylvia Schneider
    [Arguments]   ${id}   ${tc}

    ${a1ThresholdPCellSwitchSsbRsrp}           Create List   ${EMPTY}   68       68      66
    ${a2ThresholdSCellRelSsbRsrp_TC0203}       Create List   ${EMPTY}   62       62      64
    ${a2ThresholdSCellRelSsbRsrp_TC04}         Create List   ${EMPTY}   62       63      64
    ${a2TimeToTriggerSCellRelSsbRsrp_TC0203}   Create List   ${EMPTY}   512ms  512ms  480ms
    ${a2TimeToTriggerSCellRelSsbRsrp_TC04}     Create List   ${EMPTY}   512ms  320ms  640ms

    Log To Console   add object ${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_SCELL-${id}
    ${header}   Catenate
    ...   <managedObject class="com.nokia.srbts.nrbts:NRMEASPR_SCELL" distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_SCELL-${id}"
    ...   version="${SCF.version}" operation="create">
    ${new_MO}  Catenate      SEPARATOR=\n
    ...   ${header}
    ...   <list name="a1MeasPCellSwitchSsbRsrp">
    ...   <item>
    ...   <p name="a1HysteresisPCellSwitchSsbRsrp">4</p>
    ...   <p name="a1ThresholdPCellSwitchSsbRsrp">${a1ThresholdPCellSwitchSsbRsrp}[${id}]</p>
    ...   <p name="a1TimeToTriggerPCellSwitchSsbRsrp">320ms</p>
    ...   </item>
    ...   </list>
    ...   <list name="a2MeasSCellRelSsbRsrp">
    ...   <item>
    ...   <p name="a2HysteresisSCellRelSsbRsrp">4</p>
    ...   <p name="a2ThresholdSCellRelSsbRsrp">${a2ThresholdSCellRelSsbRsrp_${tc}}[${id}]</p>
    ...   <p name="a2TimeToTriggerSCellRelSsbRsrp">${a2TimeToTriggerSCellRelSsbRsrp_${tc}}[${id}]</p>
    ...   </item>
    ...   </list>
    ...   </managedObject>
    XML.Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Add NRMEASPR_SCELL Object
    [Documentation]    [PRIVATE]    Add NRMEASPR_SCELL To NRMEAS_PROFILE-1 Objects
    ...       :Author: Sylvia Schneider
    FOR   ${id}   IN   1   2   3
        Add Single NRMEASPR_SCELL Object   id=${id}    tc=TC0203
    END


Add NRMEASPR_SCELL Object TC04
    [Documentation]    [PRIVATE]    Add NRMEASPR_SCELL To NRMEAS_PROFILE-1 Objects TC04
    ...       :Author: Sylvia Schneider
    FOR   ${id}   IN  1  2  3
        Add Single NRMEASPR_SCELL Object   id=${id}    tc=TC04
    END


Create Single NRMEASPR_SCELL Object TC05
    [Documentation]    [PRIVATE]    Add NRMEASPR_SCELL To NRMEAS_PROFILE-1 Objects
    ...       :Author: Sylvia Schneider
    [Arguments]  ${id}

    ${a2ThresholdSCellRelSsbRsrp}        Create List   ${EMPTY}   1        3
    ${a2TimeToTriggerSCellRelSsbRsrp}    Create List   ${EMPTY}   320ms    512ms
    ${a2ThresholdSCellRelSsbRsrq}        Create List   ${EMPTY}   50       52
    ${a2TimeToTriggerSCellRelSsbRsrq}    Create List   ${EMPTY}   320ms    640ms

    Log To Console   add object ${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_SCELL-${id}
    ${header}   Catenate
    ...   <managedObject class="com.nokia.srbts.nrbts:NRMEASPR_SCELL" distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_SCELL-${id}"
    ...   version="${SCF.version}" operation="create">
    ${new_MO}  Catenate      SEPARATOR=\n
    ...   ${header}
    ...   <list name="a2MeasSCellRelSsbRsrp">
    ...   <item>
    ...   <p name="a2HysteresisSCellRelSsbRsrp">0</p>
    ...   <p name="a2ThresholdSCellRelSsbRsrp">${a2ThresholdSCellRelSsbRsrp}[${id}]</p>
    ...   <p name="a2TimeToTriggerSCellRelSsbRsrp">${a2TimeToTriggerSCellRelSsbRsrp}[${id}]</p>
    ...   </item>
    ...   </list>
    ...   <list name="a2MeasSCellRelSsbRsrq">
    ...   <item>
    ...   <p name="a2HysteresisSCellRelSsbRsrq">0</p>
    ...   <p name="a2ThresholdSCellRelSsbRsrq">${a2ThresholdSCellRelSsbRsrq}[${id}]</p>
    ...   <p name="a2TimeToTriggerSCellRelSsbRsrq">${a2TimeToTriggerSCellRelSsbRsrq}[${id}]</p>
    ...   </item>
    ...   </list>
    ...   </managedObject>
    XML.Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Add NRMEASPR_SCELL Object TC05
    [Documentation]    [PRIVATE]    Add NRMEASPR_SCELL Object TC05
    ...       :Author: Sylvia Schneider
    FOR  ${id}    IN   1   2
       Create Single NRMEASPR_SCELL Object TC05   ${id}
    END
