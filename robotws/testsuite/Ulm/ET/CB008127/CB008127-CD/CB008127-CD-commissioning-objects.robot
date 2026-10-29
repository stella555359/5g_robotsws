*** Settings ***
Documentation   This is a keyword file for CB008127-CD, part commissioning, new objects
...             Team: 'MN RAN RD VRF ULM6'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Keywords ***



Create NRADJNRCELL
    [Documentation]    [PRIVATE]    create NRADJNRCELL object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRADJNRCELL-1
    ${NRADJNRCELL}    set variable  <managedObject class="NRADJNRCELL" distName="${bts_distName}/NRADJNRCELL-1"
    ${NRADJNRCELL}   Catenate     SEPARATOR=${SPACE}   ${NRADJNRCELL}    version="${SCF.version}" operation="create">
    FOR    ${line}   IN
    ...    <p name="cellDepType">NSA</p>
    ...    <p name="cellReservedForOperatorUse">notReserved</p>
    ...    <p name="fiveGsTac">200</p>
    ...    <p name="freqBandIndicatorNR">78</p>
    ...    <p name="gNbId">38</p>
    ...    <p name="gNbIdLength">28</p>
    ...    <p name="lcrId">1</p>
    ...    <p name="nrarfcn">636666</p>
    ...    <p name="physCellId">48</p>
    ...    <list name="gnbPlmn">
    ...    <item>
    ...    <p name="mcc">${SCF.mcc}</p>
    ...    <p name="mnc">${SCF.mnc}</p>
    ...    <p name="mncLength">3</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${NRADJNRCELL}   Catenate     SEPARATOR=\n         ${NRADJNRCELL}   ${line}
    END
    Add Element     ${scf_xml}     ${NRADJNRCELL}           xpath=.//cmData


Create NRCONNECTMODE_PROFILE
    [Documentation]    [PRIVATE]    create NRCONNECTMODE_PROFILE object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRCONNECTMODE_PROFILE-1
    ${new_MO}    set variable  <managedObject class="NRCONNECTMODE_PROFILE" distName="${bts_distName}/NRCONNECTMODE_PROFILE-1"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}    version="${SCF.version}" operation="create">
    FOR    ${line}   IN
    ...    <list name="multiFreqBandIndicatorNR">
    ...    <p>77</p>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRHOIF_NRCELL-${id}
    [Documentation]    [PRIVATE]    create NRHOIF object in SCF
    ...       :Autor: Sylvia Schneider
    ${ssbFrequency_nrcell_1}   set variable    647616
    ${ssbFrequency_nrcell_2}   set variable    636576

    Log To Console    Building object ${bts_distName}/NRCELL-${id}/NRHOIF-1
    ${new_MO}   set variable   <managedObject class="NRHOIF" distName="${bts_distName}/NRCELL-${id}/NRHOIF-1"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR    ${line}   IN
    ...    <p name="a1BasedPCellSwitchEnabled">false</p>
    ...    <p name="a2BasedPCellSwitchEnabled">false</p>
    ...    <p name="a3MeasEnabled">rsrp</p>
    ...    <p name="a4MeasEnDcSteeringEnabled">none</p>
    ...    <p name="a4MeasHigherPrioFreqEnabled">none</p>
    ...    <p name="a4MeasNrDcEnabled">none</p>
    ...    <p name="a4MeasSCellAddEnabled">none</p>
    ...    <p name="a5MeasEnabled">rsrp</p>
    ...    <p name="cellDepType">SA+NSA</p>
    ...    <p name="deriveSsbIndexFromCell">true</p>
    ...    <p name="freqBandIndicatorNR">78</p>
    ...    <p name="ifhoSsbScs">30 KHz</p>
    ...    <p name="ifhoSsbSmtcDuration">sf5</p>
    ...    <p name="ifhoSsbSmtcPeriodicity">sf20</p>
    ...    <p name="numberOfTransmittedSsBlocks">1 beam</p>
    ...    <p name="scs">30 KHz</p>
    ...    <p name="ssBurstSetPeriod">10</p>
    ...    <p name="ssbFrequency">${ssbFrequency_nrcell_${id}}</p>
    ...    <list name="a3MeasSsbRsrp">
    ...    <item>
    ...    <p name="a3HysteresisSsbRsrp">1</p>
    ...    <p name="a3OffsetSsbRsrp">10</p>
    ...    <p name="a3TimeToTriggerSsbRsrp">ms0</p>
    ...    </item>
    ...    </list>
    ...    <list name="a3MeasSsbRsrq">
    ...    <item>
    ...    <p name="a3HysteresisSsbRsrq">2</p>
    ...    <p name="a3OffsetSsbRsrq">10</p>
    ...    <p name="a3TimeToTriggerSsbRsrq">ms40</p>
    ...    </item>
    ...    </list>
    ...    <list name="a5MeasSsbRsrp">
    ...    <item>
    ...    <p name="a5HysteresisSsbRsrp">0</p>
    ...    <p name="a5Threshold1SsbRsrp">102</p>
    ...    <p name="a5Threshold2SsbRsrp">92</p>
    ...    <p name="a5TimeToTriggerSsbRsrp">ms480</p>
    ...    </item>
    ...    </list>
    ...    <list name="a5MeasSsbRsrq">
    ...    <item>
    ...    <p name="a5HysteresisSsbRsrq">0</p>
    ...    <p name="a5Threshold1SsbRsrq">40</p>
    ...    <p name="a5Threshold2SsbRsrq">30</p>
    ...    <p name="a5TimeToTriggerSsbRsrq">ms480</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create single NRMEASCFG_IF
    [Documentation]    [PRIVATE]    Create single NRMEASCFG_IF
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${NRMEASCFG_IF_id}   ${ssbFrequency}
    Log To Console    Building object ${bts_distName}/NRMEASCFG_IF-${NRMEASCFG_IF_id}
    ${new_MO}   set variable   <managedObject class="NRMEASCFG_IF" distName="${bts_distName}/NRMEASCFG_IF-${NRMEASCFG_IF_id}"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR    ${line}   IN
    ...    <p name="a3MeasEnabled">rsrqCombined</p>
    ...    <p name="a5MeasEnabled">rsrqCombined</p>
    ...    <p name="freqBandIndicatorNR">78</p>
    ...    <p name="ssbFrequency">${ssbFrequency}</p>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRMEASCFG_IF
    [Documentation]    [PRIVATE]    Create NRMEASCFG_IF
    ...       :Autor: Sylvia Schneider
    FOR   ${NRMEASCFG_IF_id}   ${ssbFrequency}   IN
    ...   1                    647616
    ...   2                    636576
       Create single NRMEASCFG_IF   NRMEASCFG_IF_id=${NRMEASCFG_IF_id}   ssbFrequency=${ssbFrequency}
    END


Create NRMOPRMA_NSA
    [Documentation]    [PRIVATE]    Create NRMOPRMA_NSA
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NNRMOPRMA_NSA-1
    ${new_MO}   set variable   <managedObject class="NRMOPRMA_NSA" distName="${bts_distName}/NRMOPRMA_NSA-1"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR    ${line}   IN
    ...    <p name="mobilityProfilePriority">1</p>
    ...    <p name="nrMoPrNsaDN">${bts_distName}/NRMOPR_NSA-1</p>
    ...    <list name="nrPlmnDNList">
    ...    <p>MRBTS-1/NRBTS-1/NRPLMN-1</p>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRMOPR_NSA-1 and NRMOPR_NSA-32
    [Documentation]    [PRIVATE]    Create NRMOPR_NSA-1 and NRMOPR_NSA-32
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPR_NSA-1
    ${new_MO}   set variable   <managedObject class="NRMOPR_NSA" distName="${bts_distName}/NRMOPR_NSA-1"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR    ${line}   IN
    ...    <p name="a1MeashoEnabled">rsrqCombined</p>
    ...    <p name="a2MeashoEnabled">rsrqCombined</p>
    ...    <list name="nrMeasCfgIfDNList">
    ...    <p>${bts_distName}/NRMEASCFG_IF-1</p>
    ...    <p>${bts_distName}/NRMEASCFG_IF-2</p>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData

    Log To Console    Building object ${bts_distName}/NRMOPR_NSA-32
    ${new_MO}   set variable   <managedObject class="NRMOPR_NSA" distName="${bts_distName}/NRMOPR_NSA-32"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR    ${line}   IN
    ...    <p name="a1MeashoEnabled">none</p>
    ...    <p name="a2MeashoEnabled">none</p>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRMOPRMA_SA
    [Documentation]    [PRIVATE]    Create NRMOPRMA_SA
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPRMA_SA
    ${new_MO}   set variable   <managedObject class="NRMOPRMA_SA" distName="${bts_distName}/NRMOPRMA_SA-1"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR    ${line}   IN
    ...    <p name="mobilityProfilePriority">1</p>
    ...    <p name="nrMoPrSaDN">MRBTS-1/NRBTS-1/NRMOPR_SA-1</p>
    ...    <list name="nrPlmnDNList">
    ...    <p>${bts_distName}/NRPLMN-1</p>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRREL-1 for NRCELL-${id}
    [Documentation]    [PRIVATE]    create single NRREL object in SCF
    ...       :Autor: Sylvia Schneider
    ${lcrId}     create list   ${EMPTY}    2    1
    Log To Console    Building object ${bts_distName}/NRCELL-${id}/NRREL-1
    ${new_MO}   set variable   <managedObject class="NRREL" distName="${bts_distName}/NRCELL-${id}/NRREL-1"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR    ${line}   IN
    ...    <p name="cellIndividualSsbRsrpOffset">0dB</p>
    ...    <p name="cellIndividualSsbRsrqOffset">0dB</p>
    ...    <p name="gNbId">1</p>
    ...    <p name="gNbIdLength">22</p>
    ...    <p name="handoverAllowedSA">allowed</p>
    ...    <p name="handoverAllowedSARedCap">forbidden</p>
    ...    <p name="isRplCellForPSCell">true</p>
    ...    <p name="lcrId">${lcrId}[${id}]</p>
    ...    <p name="nrDcAllowed">false</p>
    ...    <p name="removeNotAllowed">false</p>
    ...    <p name="rsrpOffsetRplCellForPSCell">0dB</p>
    ...    <p name="rsrqOffsetRplCellForPSCell">0dB</p>
    ...    <list name="gnbPlmn">
    ...    <item>
    ...    <p name="mcc">311</p>
    ...    <p name="mnc">489</p>
    ...    <p name="mncLength">3</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRREL-2
    [Documentation]    [PRIVATE]    create single NRREL object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRCELL-1/NRREL-2
    ${new_MO}   set variable   <managedObject class="NRREL" distName="${bts_distName}/NRCELL-1/NRREL-2"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR    ${line}   IN
    ...    <p name="cellIndividualSsbRsrpOffset">0dB</p>
    ...    <p name="cellIndividualSsbRsrqOffset">0dB</p>
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
    ...    <p name="mcc">311</p>
    ...    <p name="mnc">489</p>
    ...    <p name="mncLength">3</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRMEAS_PROFILE
    [Documentation]    [PRIVATE]    create NRMEAS_PROFILE object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMEAS_PROFILE-1
    ${new_MO}   set variable   <managedObject class="NRMEAS_PROFILE" distName="${bts_distName}/NRMEAS_PROFILE-1"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create"/>
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create single NRMEASPR_IAF
    [Documentation]    [PRIVATE]    create NRMEASPR_IAF object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${NRMEASPR_IAF_id}
    Log To Console    Building object ${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-${NRMEASPR_IAF_id}
    ${new_MO}   set variable   <managedObject class="NRMEASPR_IAF" distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-${NRMEASPR_IAF_id}"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR    ${line}   IN
    ...    <list name="a1MeashoPrefNRLayerSsbRsrp">
    ...    <item>
    ...    <p name="a1HysteresisSsbRsrp">0</p>
    ...    <p name="a1ThresholdhoSsbRsrp">${a1MeashoPrefNRLayerSsbRsrp_a1ThresholdhoSsb}[${NRMEASPR_IAF_id}]</p>
    ...    <p name="a1TimeToTriggerhoSsbRsrp">ms40</p>
    ...    </item>
    ...    </list>
    ...    <list name="a1MeashoPrefNRLayerSsbRsrq">
    ...    <item>
    ...    <p name="a1HysteresisSsbRsrq">0</p>
    ...    <p name="a1ThresholdhoSsbRsrq">${a1MeashoPrefNRLayerSsbRsrq_a1ThresholdhoSsb}[${NRMEASPR_IAF_id}]</p>
    ...    <p name="a1TimeToTriggerhoSsbRsrq">ms40</p>
    ...    </item>
    ...    </list>
    ...    <list name="a1MeashoSsbRsrp">
    ...    <item>
    ...    <p name="a1HysteresishoSsbRsrp">0</p>
    ...    <p name="a1ThresholdhoSsbRsrp">${a1MeashoSsbRsrp_a1ThresholdhoSsb}[${NRMEASPR_IAF_id}]</p>
    ...    <p name="a1TimeToTriggerhoSsbRsrp">ms480</p>
    ...    </item>
    ...    </list>
    ...    <list name="a1MeashoSsbRsrq">
    ...    <item>
    ...    <p name="a1HysteresishoSsbRsrq">0</p>
    ...    <p name="a1ThresholdhoSsbRsrq">${a1MeashoSsbRsrq_a1ThresholdhoSsb}[${NRMEASPR_IAF_id}]</p>
    ...    <p name="a1TimeToTriggerhoSsbRsrq">ms480</p>
    ...    </item>
    ...    </list>
    ...    <list name="a2MeasReleaseSsbRsrp">
    ...    <item>
    ...    <p name="a2HysteresisReleaseSsbRsrp">0</p>
    ...    <p name="a2ThresholdReleaseSsbRsrp">${a2MeasReleaseSsbRsrp_a2ThresholdReleaseSsb}[${NRMEASPR_IAF_id}]</p>
    ...    <p name="a2TimeToTriggerReleaseSsbRsrp">ms480</p>
    ...    </item>
    ...    </list>
    ...    <list name="a2MeasReleaseSsbRsrq">
    ...    <item>
    ...    <p name="a2HysteresisReleaseSsbRsrq">0</p>
    ...    <p name="a2ThresholdReleaseSsbRsrq">${a2MeasReleaseSsbRsrq_a2ThresholdReleaseSsb}[${NRMEASPR_IAF_id}]</p>
    ...    <p name="a2TimeToTriggerReleaseSsbRsrq">ms480</p>
    ...    </item>
    ...    </list>
    ...    <list name="a2MeashoSsbRsrp">
    ...    <item>
    ...    <p name="a2HysteresishoSsbRsrp">0</p>
    ...    <p name="a2ThresholdhoSsbRsrp">${a2MeashoSsbRsrp_a2ThresholdhoSsb}[${NRMEASPR_IAF_id}]</p>
    ...    <p name="a2TimeToTriggerhoSsbRsrp">ms480</p>
    ...    </item>
    ...    </list>
    ...    <list name="a2MeashoSsbRsrq">
    ...    <item>
    ...    <p name="a2HysteresishoSsbRsrq">0</p>
    ...    <p name="a2ThresholdhoSsbRsrq">${a2MeashoSsbRsrq_a2ThresholdhoSsb}[${NRMEASPR_IAF_id}]</p>
    ...    <p name="a2TimeToTriggerhoSsbRsrq">ms480</p>
    ...    </item>
    ...    </list>
    ...    <list name="a3MeasSsbRsrp">
    ...    <item>
    ...    <p name="a3HysteresisSsbRsrp">0</p>
    ...    <p name="a3OffsetSsbRsrp">${a3MeasSsbRsrp_a3OffsetSsb}[${NRMEASPR_IAF_id}]</p>
    ...    <p name="a3TimeToTriggerSsbRsrp">ms320</p>
    ...    </item>
    ...    </list>
    ...    <list name="a3MeasSsbRsrq">
    ...    <item>
    ...    <p name="a3HysteresisSsbRsrq">0</p>
    ...    <p name="a3OffsetSsbRsrq">${a3MeasSsbRsrq_a3OffsetSsb}[${NRMEASPR_IAF_id}]</p>
    ...    <p name="a3TimeToTriggerSsbRsrq">ms320</p>
    ...    </item>
    ...    </list>
    ...    <list name="a5MeasSsbRsrp">
    ...    <item>
    ...    <p name="a5HysteresisSsbRsrp">0</p>
    ...    <p name="a5Threshold1SsbRsrp">${a5MeasSsbRsrp_a5Threshold1Ssb}[${NRMEASPR_IAF_id}]</p>
    ...    <p name="a5Threshold2SsbRsrp">${a5MeasSsbRsrp_a5Threshold2Ssb}[${NRMEASPR_IAF_id}]</p>
    ...    <p name="a5TimeToTriggerSsbRsrp">ms320</p>
    ...    </item>
    ...    </list>
    ...    <list name="a5MeasSsbRsrq">
    ...    <item>
    ...    <p name="a5HysteresisSsbRsrq">0</p>
    ...    <p name="a5Threshold1SsbRsrq">${a5MeasSsbRsrq_a5Threshold1Ssb}[${NRMEASPR_IAF_id}]</p>
    ...    <p name="a5Threshold2SsbRsrq">${a5MeasSsbRsrq_a5Threshold2Ssb}[${NRMEASPR_IAF_id}]</p>
    ...    <p name="a5TimeToTriggerSsbRsrq">ms320</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRMEASPR_IAF
    [Documentation]    [PRIVATE]    create NRMEASPR_IAF object in SCF
    ...       :Autor: Sylvia Schneider
    FOR    ${id}   IN  1  2
       Create single NRMEASPR_IAF    NRMEASPR_IAF_id=${id}
    END


Create NRMEASPR_IAF-3 t${id}
    [Documentation]    [PRIVATE]    Create NRMEASPR_IAF-3 t6 and t8
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-3
    ${index}  set variable if
    ...       ${id}==6   1
    ...       ${id}==8   3
    ${new_MO}   set variable   <managedObject class="NRMEASPR_IAF" distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-3"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR    ${line}   IN
    ...    <list name="a1MeashoPrefNRLayerSsbRsrp">
    ...    <item>
    ...    <p name="a1HysteresisSsbRsrp">0</p>
    ...    <p name="a1ThresholdhoSsbRsrp">${a1MeashoPrefNRLayerSsbRsrp_a1ThresholdhoSsb}[${index}]</p>
    ...    <p name="a1TimeToTriggerhoSsbRsrp">ms40</p>
    ...    </item>
    ...    </list>
    ...    <list name="a1MeashoSsbRsrp">
    ...    <item>
    ...    <p name="a1HysteresishoSsbRsrp">0</p>
    ...    <p name="a1ThresholdhoSsbRsrp">${a1MeashoSsbRsrp_a1ThresholdhoSsb}[${index}]</p>
    ...    <p name="a1TimeToTriggerhoSsbRsrp">ms480</p>
    ...    </item>
    ...    </list>
    ...    <list name="a2MeasReleaseSsbRsrp">
    ...    <item>
    ...    <p name="a2HysteresisReleaseSsbRsrp">0</p>
    ...    <p name="a2ThresholdReleaseSsbRsrp">${a2MeasReleaseSsbRsrp_a2ThresholdReleaseSsb}[${index}]</p>
    ...    <p name="a2TimeToTriggerReleaseSsbRsrp">ms480</p>
    ...    </item>
    ...    </list>
    ...    <list name="a2MeashoSsbRsrp">
    ...    <item>
    ...    <p name="a2HysteresishoSsbRsrp">0</p>
    ...    <p name="a2ThresholdhoSsbRsrp">${a2MeashoSsbRsrp_a2ThresholdhoSsb}[${index}]</p>
    ...    <p name="a2TimeToTriggerhoSsbRsrp">ms480</p>
    ...    </item>
    ...    </list>
    ...    <list name="a3MeasSsbRsrp">
    ...    <item>
    ...    <p name="a3HysteresisSsbRsrp">0</p>
    ...    <p name="a3OffsetSsbRsrp">${a3MeasSsbRsrp_a3OffsetSsb}[${index}]</p>
    ...    <p name="a3TimeToTriggerSsbRsrp">ms320</p>
    ...    </item>
    ...    </list>
    ...    <list name="a5MeasSsbRsrp">
    ...    <item>
    ...    <p name="a5HysteresisSsbRsrp">0</p>
    ...    <p name="a5Threshold1SsbRsrp">${a5MeasSsbRsrp_a5Threshold1Ssb}[${index}]</p>
    ...    <p name="a5Threshold2SsbRsrp">${a5MeasSsbRsrp_a5Threshold2Ssb}[${index}]</p>
    ...    <p name="a5TimeToTriggerSsbRsrp">ms320</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create single NRMEASPR_IEF
    [Documentation]    [PRIVATE]    create NRMEASPR_IEF object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${NRMEASPR_IEF_id}
    Log To Console    Building object ${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IEF-${NRMEASPR_IEF_id}
    ${new_MO}   set variable   <managedObject class="NRMEASPR_IEF" distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IEF-${NRMEASPR_IEF_id}"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR    ${line}   IN
    ...    <list name="a3MeasSsbRsrp">
    ...    <item>
    ...    <p name="a3HysteresisSsbRsrp">0</p>
    ...    <p name="a3OffsetSsbRsrp">${IEF_a3OffsetSsbRsrp}[${NRMEASPR_IEF_id}]</p>
    ...    <p name="a3TimeToTriggerSsbRsrp">ms480</p>
    ...    </item>
    ...    </list>
    ...    <list name="a3MeasSsbRsrq">
    ...    <item>
    ...    <p name="a3HysteresisSsbRsrq">0</p>
    ...    <p name="a3OffsetSsbRsrq">${IEF_a3OffsetSsbRsrq}[${NRMEASPR_IEF_id}]</p>
    ...    <p name="a3TimeToTriggerSsbRsrq">ms480</p>
    ...    </item>
    ...    </list>
    ...    <list name="a4MeasHigherPrioFreqSsbRsrp">
    ...    <item>
    ...    <p name="a4HysteresisSsbRsrp">0</p>
    ...    <p name="a4ThresholdSsbRsrp">${IEF_a4ThresholdSsbRsrp}[${NRMEASPR_IEF_id}]</p>
    ...    <p name="a4TimeToTriggerSsbRsrp">${IEF_a4TimeToTriggerSsbRsrp_Rsrq}[${NRMEASPR_IEF_id}]</p>
    ...    </item>
    ...    </list>
    ...    <list name="a4MeasHigherPrioFreqSsbRsrq">
    ...    <item>
    ...    <p name="a4HysteresisSsbRsrq">0</p>
    ...    <p name="a4ThresholdSsbRsrq">${IEF_a4ThresholdSsbRsrq}[${NRMEASPR_IEF_id}]</p>
    ...    <p name="a4TimeToTriggerSsbRsrq">${IEF_a4TimeToTriggerSsbRsrp_Rsrq}[${NRMEASPR_IEF_id}]</p>
    ...    </item>
    ...    </list>
    ...    <list name="a5MeasSsbRsrp">
    ...    <item>
    ...    <p name="a5HysteresisSsbRsrp">0</p>
    ...    <p name="a5Threshold1SsbRsrp">${IEF_a5Threshold1SsbRsrp}[${NRMEASPR_IEF_id}]</p>
    ...    <p name="a5Threshold2SsbRsrp">${IEF_a5Threshold2SsbRsrp}[${NRMEASPR_IEF_id}]</p>
    ...    <p name="a5TimeToTriggerSsbRsrp">ms320</p>
    ...    </item>
    ...    </list>
    ...    <list name="a5MeasSsbRsrq">
    ...    <item>
    ...    <p name="a5HysteresisSsbRsrq">0</p>
    ...    <p name="a5Threshold1SsbRsrq">${IEF_a5Threshold1SsbRsrq}[${NRMEASPR_IEF_id}]</p>
    ...    <p name="a5Threshold2SsbRsrq">${IEF_a5Threshold2SsbRsrq}[${NRMEASPR_IEF_id}]</p>
    ...    <p name="a5TimeToTriggerSsbRsrq">ms320</p>
    ...    </item>
    ...        </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRMEASPR_IEF
    [Documentation]    [PRIVATE]    create NRMEASPR_IEF object in SCF
    ...       :Autor: Sylvia Schneider
    FOR    ${id}   IN  1  2
       Create single NRMEASPR_IEF    NRMEASPR_IEF_id=${id}
    END


Create NRMEASPR_IEF-3
    [Documentation]    [PRIVATE]    Create NRMEASPR_IEF-3
    ...       :Autor: Sylvia Schneider
    Create single NRMEASPR_IEF    NRMEASPR_IEF_id=3


Create single NRMEASPR_MA_NSA
    [Documentation]    [PRIVATE]    create NRMEASPR_MA_NSA object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${NRMEASPR_MA_NSA_id}
    Log To Console    Building object ${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-${NRMEASPR_MA_NSA_id}
    ${new_MO}   set variable
    ...   <managedObject class="NRMEASPR_MA_NSA" distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-${NRMEASPR_MA_NSA_id}"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR    ${line}   IN
    ...    <p name="nrMeasPrIafDN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-${NRMEASPR_MA_NSA_id}</p>
    ...    <list name="pcCapabilityList">
    ...    <item>
    ...    <p name="freqBandIndicatorNR">78</p>
    ...    <p name="uePowerClass">${uePowerClass_item1}[${NRMEASPR_MA_NSA_id}]</p>
    ...    </item>
    ...    <item>
    ...    <p name="freqBandIndicatorNR">41</p>
    ...    <p name="uePowerClass">${uePowerClass_item2}[${NRMEASPR_MA_NSA_id}]</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRMEASPR_MA_NSA
    [Documentation]    [PRIVATE]    create NRMEASPR_MA_NSA object in SCF
    ...       :Autor: Sylvia Schneider
    FOR    ${id}   IN  1  2
       Create single NRMEASPR_MA_NSA    NRMEASPR_MA_NSA_id=${id}
    END


Create NRMEASPR_MA_NSA-3 with IAF-${iaf_id}
    [Documentation]    [PRIVATE]    Create NRMEASPR_MA_NSA-3 with IAF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-3
    ${new_MO}   set variable
    ...   <managedObject class="NRMEASPR_MA_NSA" distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-3"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR    ${line}   IN
    ...    <p name="nrMeasPrIafDN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-${iaf_id}</p>
    ...    <list name="pcCapabilityList">
    ...    <item>
    ...    <p name="freqBandIndicatorNR">77</p>
    ...    <p name="uePowerClass">ue-PowerClass2</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


recreate NRMEASPR_MA_NSA ${tc}
    [Documentation]    [PRIVATE]    recreate NRMEASPR_MA_NSA
    ...       :Autor: Sylvia Schneider
    FOR   ${id}   IN   1   2
       remove element  ${scf_xml}    xpath=.//managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-${id}"]
    END
    FOR   ${object}   IN
    ...   NRMEASPR_MA_NSA-1
    ...   NRMEASPR_MA_NSA-2 ${tc}
    ...   NRMEASPR_MA_NSA-3
       run keyword    recreate ${object}
    END


recreate NRMEASPR_MA_NSA-1
    [Documentation]    [PRIVATE]    recreate NRMEASPR_MA_NSA-1
    ...       :Autor: Sylvia Schneider
    Log To Console    recreate NRMEASPR_MA_NSA-1
    ${new_MO}   set variable
    ...   <managedObject class="NRMEASPR_MA_NSA" distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-1"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR    ${line}   IN
    ...    <p name="nrMeasPrIafDN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1</p>
    ...    <list name="nrMeasPrIefList">
    ...    <item>
    ...    <p name="nrMeasPrIefDN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IEF-1</p>
    ...    <p name="ssbFrequency01">647616</p>
    ...    </item>
    ...    </list>
    ...    <list name="pcCapabilityList">
    ...    <item>
    ...    <p name="freqBandIndicatorNR">78</p>
    ...    <p name="uePowerClass">ue-PowerClass2</p>
    ...    </item>
    ...    <item>
    ...    <p name="freqBandIndicatorNR">41</p>
    ...    <p name="uePowerClass">ue-PowerClass5</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


recreate NRMEASPR_MA_NSA-2 t8
    [Documentation]    [PRIVATE]    recreate NRMEASPR_MA_NSA-2 t8
    ...       :Autor: Sylvia Schneider
    Log To Console    recreate NRMEASPR_MA_NSA-2
    ${new_MO}   set variable
    ...   <managedObject class="NRMEASPR_MA_NSA" distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-2"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR    ${line}   IN
    ...             <p name="nrMeasPrIafDN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-2</p>
    ...             <list name="nrMeasPrIefList">
    ...             <item>
    ...             <p name="nrMeasPrIefDN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IEF-2</p>
    ...             <p name="ssbFrequency01">647616</p>
    ...             </item>
    ...             </list>
    ...             <list name="pcCapabilityList">
    ...             <item>
    ...             <p name="uePowerClass">ue-PowerClass3</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


recreate NRMEASPR_MA_NSA-2 t9
    [Documentation]    [PRIVATE]    recreate NRMEASPR_MA_NSA-2 t9
    ...       :Autor: Sylvia Schneider
    Log To Console    recreate NRMEASPR_MA_NSA-2
    ${new_MO}   set variable
    ...   <managedObject class="NRMEASPR_MA_NSA" distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-2"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR    ${line}   IN
    ...    <p name="nrMeasPrIafDN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-2</p>
    ...    <list name="nrMeasPrIefList">
    ...    <item>
    ...    <p name="nrMeasPrIefDN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IEF-2</p>
    ...    <p name="ssbFrequency01">647616</p>
    ...    </item>
    ...    </list>
    ...    <list name="pcCapabilityList">
    ...    <item>
    ...    <p name="freqBandIndicatorNR">78</p>
    ...    <p name="uePowerClass">ue-PowerClass3</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


recreate NRMEASPR_MA_NSA-3
    [Documentation]    [PRIVATE]    recreate NRMEASPR_MA_NSA-3
    ...       :Autor: Sylvia Schneider
    Log To Console    recreate NRMEASPR_MA_NSA-3
    ${new_MO}   set variable
    ...   <managedObject class="NRMEASPR_MA_NSA" distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-3"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR    ${line}   IN
    ...    <p name="nrMeasPrIafDN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-3</p>
    ...    <list name="nrMeasPrIefList">
    ...    <item>
    ...    <p name="nrMeasPrIefDN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IEF-3</p>
    ...    <p name="ssbFrequency01">647616</p>
    ...    </item>
    ...    </list>
    ...    <list name="pcCapabilityList">
    ...    <item>
    ...    <p name="uePowerClass">ue-PowerClass1Dot5</p>
    ...    </item>
    ...    <item>
    ...    <p name="freqBandIndicatorNR">77</p>
    ...    <p name="uePowerClass">ue-PowerClass2</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData
