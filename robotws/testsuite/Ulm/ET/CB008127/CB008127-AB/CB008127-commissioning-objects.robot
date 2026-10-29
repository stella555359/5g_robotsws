*** Settings ***
Documentation   This is a keyword file for CB008127, part commissioning, new objects
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Keywords ***

Create NRADJGNB
    [Documentation]    [PRIVATE]    create NRADJGNB object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRADJGNB-1
    ${new_MO}    Set Variable  <managedObject class="NRADJGNB" distName="${bts_distName}/NRADJGNB-1"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}    version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="administrativeState">Unlocked</p>
    ...    <p name="gNbIdLength">28</p>
    ...    <p name="gNodeBId">3</p>
    ...    <p name="gNodeBIdCtrl">oamControlled</p>
    ...    <p name="weightForIgnbCaSelection">1</p>
    ...    <p name="xnLinkRef">1</p>
    ...    <list name="gnbPlmn">
    ...    <item>
    ...    <p name="mcc">${SCF.mcc}</p>
    ...    <p name="mnc">${SCF.mnc}</p>
    ...    <p name="mncLength">3</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRADJGNB-2
    [Documentation]    [PRIVATE]    create NRADJGNB-2 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRADJGNB-2
    ${new_MO}    Set Variable  <managedObject class="NRADJGNB" distName="${bts_distName}/NRADJGNB-2"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}    version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="administrativeState">Unlocked</p>
    ...    <p name="gNbIdLength">28</p>
    ...    <p name="gNodeBId">18</p>
    ...    <p name="gNodeBIdCtrl">oamControlled</p>
    ...    <p name="xnLinkRef">2</p>
    ...    <list name="gnbPlmn">
    ...    <item>
    ...    <p name="mcc">${SCF.mcc}</p>
    ...    <p name="mnc">${SCF.mnc}</p>
    ...    <p name="mncLength">3</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRADJNRCELL
    [Documentation]    [PRIVATE]    create NRADJNRCELL object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRADJNRCELL-1
    ${NRADJNRCELL}    Set Variable  <managedObject class="NRADJNRCELL" distName="${bts_distName}/NRADJNRCELL-1"
    ${NRADJNRCELL}   Catenate     SEPARATOR=${SPACE}   ${NRADJNRCELL}    version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="cellDepType">SA</p>
    ...    <p name="cellReservedForOperatorUse">notReserved</p>
    ...    <p name="fiveGsTac">0</p>
    ...    <p name="freqBandIndicatorNR">78</p>
    ...    <p name="gNbId">3</p>
    ...    <p name="gNbIdLength">28</p>
    ...    <p name="lcrId">1</p>
    ...    <p name="nrarfcn">633364</p>
    ...    <p name="physCellId">48</p>
    ...    <p name="ssbFrequency">633408</p>
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

    Log To Console    Building object ${bts_distName}/NRADJNRCELL-2
    ${NRADJNRCELL}    Set Variable  <managedObject class="NRADJNRCELL" distName="${bts_distName}/NRADJNRCELL-2"
    ${NRADJNRCELL}   Catenate     SEPARATOR=${SPACE}   ${NRADJNRCELL}    version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="cellDepType">SA</p>
    ...    <p name="cellReservedForOperatorUse">notReserved</p>
    ...    <p name="fiveGsTac">200</p>
    ...    <p name="freqBandIndicatorNR">78</p>
    ...    <p name="gNbId">3</p>
    ...    <p name="gNbIdLength">28</p>
    ...    <p name="lcrId">2</p>
    ...    <p name="nrarfcn">636666</p>
    ...    <p name="physCellId">49</p>
    ...    <p name="ssbFrequency">636576</p>
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


Create NRADJECELL
    [Documentation]    [PRIVATE]    create NRADJECELL object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRADJECELL-1
    ${new_MO}    Set Variable  <managedObject class="NRADJECELL" distName="${bts_distName}/NRADJECELL-1"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}    version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="eNodeBId">18</p>
    ...    <p name="ePSTrackingAreaCode">222</p>
    ...    <p name="earfcnValue">1</p>
    ...    <p name="iRatDataForwardingMethod">indirectDataFwd</p>
    ...    <p name="lcrId">1</p>
    ...    <p name="physCellId">11</p>
    ...    <list name="ecgiPlmn">
    ...    <item>
    ...    <p name="mcc">${SCF.mcc}</p>
    ...    <p name="mnc">${SCF.mnc}</p>
    ...    <p name="mncLength">3</p>
    ...    </item>
    ...    </list>
    ...    <list name="enbPlmn">
    ...    <item>
    ...    <p name="mcc">${SCF.mcc}</p>
    ...    <p name="mnc">${SCF.mnc}</p>
    ...    <p name="mncLength">3</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRCONNECTMODE PROFILE
    [Documentation]    [PRIVATE]    create NRCONNECTMODE_PROFILE object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${profile_id}=1    ${FreqBandIndicator}=77
    Log To Console    Building object ${bts_distName}/NRCONNECTMODE_PROFILE-${profile_id}
    ${new_MO}    Set Variable  <managedObject class="NRCONNECTMODE_PROFILE" distName="${bts_distName}/NRCONNECTMODE_PROFILE-${profile_id}"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}    version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <list name="multiFreqBandIndicatorNR">
    ...    <p>${FreqBandIndicator}</p>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create Single NRHOIF
    [Documentation]    [PRIVATE]    create single NRHOIF object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${nrcell_id}
    @{param1}   Create List
    ...   ${EMPTY}
    ...   <p name="deriveSsbIndexFromCell">true</p>
    ...   ${EMPTY}
    ...   <p name="deriveSsbIndexFromCell">true</p>
    ...   <p name="deriveSsbIndexFromCell">true</p>
    @{param2}   Create List
    ...   ${EMPTY}
    ...   <p name="a3OffsetSsbRsrp">0</p>
    ...   <p name="a3OffsetSsbRsrp">10</p>
    ...   <p name="a3OffsetSsbRsrp">0</p>
    ...   <p name="a3OffsetSsbRsrp">0</p>

    Log To Console    Building object ${bts_distName}/NRCELL-${nrcell_id}/NRHOIF-1
    ${new_MO}   Set Variable   <managedObject class="NRHOIF" distName="${bts_distName}/NRCELL-${nrcell_id}/NRHOIF-1"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="a1BasedPCellSwitchEnabled">false</p>
    ...    <p name="a2BasedPCellSwitchEnabled">false</p>
    ...    <p name="a3MeasEnabled">rsrp</p>
    ...    <p name="a4MeasEnDcSteeringEnabled">none</p>
    ...    <p name="a4MeasHigherPrioFreqEnabled">none</p>
    ...    <p name="a4MeasNrDcEnabled">none</p>
    ...    <p name="a4MeasSCellAddEnabled">none</p>
    ...    <p name="a5MeasEnabled">rsrp</p>
    ...    <p name="cellDepType">SA</p>
    ...    ${param1}[${nrcell_id}]
    ...    <p name="freqBandIndicatorNR">78</p>
    ...    <p name="ifhoSsbScs">30 KHz</p>
    ...    <p name="ifhoSsbSmtcDuration">sf5</p>
    ...    <p name="ifhoSsbSmtcPeriodicity">sf20</p>
    ...    <p name="numberOfTransmittedSsBlocks">1 beam</p>
    ...    <p name="scs">30 KHz</p>
    ...    <p name="ssBurstSetPeriod">10</p>
    ...    <p name="ssbFrequency">633408</p>
    ...    <list name="a3MeasSsbRsrp">
    ...    <item>
    ...    <p name="a3HysteresisSsbRsrp">1</p>
    ...    ${param2}[${nrcell_id}]
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


Create NRHOIF
    [Documentation]    [PRIVATE]    create NRHOIF object in SCF
    ...       :Autor: Sylvia Schneider
    Create Single NRHOIF   nrcell_id=1
    Create Single NRHOIF   nrcell_id=2


Create NRHOIR
    [Documentation]    [PRIVATE]    create NRHOIR object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRHOIR-1
    ${new_MO}   Set Variable   <managedObject class="NRHOIR" distName="${bts_distName}/NRHOIR-1"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="allowedMeasBandwidth">mbw50</p>
    ...    <p name="b1MeasRedirectEnabled">none</p>
    ...    <p name="b2MeashoEnabled">rsrqCombined</p>
    ...    <p name="b2Threshold1hoRsrp">72</p>
    ...    <p name="b2Threshold1hoRsrpVoNr">75</p>
    ...    <p name="b2Threshold1hoRsrq">72</p>
    ...    <p name="b2Threshold1hoRsrqVoNr">75</p>
    ...    <p name="earfcnValue">1</p>
    ...    <p name="eutraFreqQOffsetRange">0dB</p>
    ...    <p name="presenceAntennaPort1">false</p>
    ...    <p name="reportAmount">r8</p>
    ...    <p name="reportInterval">ms240</p>
    ...    <p name="widebandRsrqMeas">true</p>
    ...    <list name="eutraB2MeashoRsrp">
    ...    <item>
    ...    <p name="b2HysteresishoRsrp">0</p>
    ...    <p name="b2HysteresishoRsrpVoNr">0</p>
    ...    <p name="b2Threshold2hoRsrp">18</p>
    ...    <p name="b2Threshold2hoRsrpVoNr">22</p>
    ...    <p name="b2TimeToTriggerhoRsrp">ms480</p>
    ...    <p name="b2TimeToTriggerhoRsrpVoNr">ms480</p>
    ...    </item>
    ...    </list>
    ...    <list name="eutraB2MeashoRsrq">
    ...    <item>
    ...    <p name="b2HysteresishoRsrq">0</p>
    ...    <p name="b2HysteresishoRsrqVoNr">0</p>
    ...    <p name="b2Threshold2hoRsrq">18</p>
    ...    <p name="b2Threshold2hoRsrqVoNr">22</p>
    ...    <p name="b2TimeToTriggerhoRsrq">ms480</p>
    ...    <p name="b2TimeToTriggerhoRsrqVoNr">ms480</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRCELL-1 NRHOIF-2 T5 T6
    [Documentation]    [PRIVATE]    Create NRCELL-1 NRHOIF-2 t5_t6 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRCELL-1/NRHOIF-2
    ${new_MO}   Set Variable   <managedObject class="NRHOIF" distName="${bts_distName}/NRCELL-1/NRHOIF-2"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="a1BasedPCellSwitchEnabled">false</p>
    ...    <p name="a2BasedPCellSwitchEnabled">false</p>
    ...    <p name="a3MeasEnabled">rsrp</p>
    ...    <p name="a4MeasEnDcSteeringEnabled">none</p>
    ...    <p name="a4MeasHigherPrioFreqEnabled">rsrp</p>
    ...    <p name="a4MeasNrDcEnabled">none</p>
    ...    <p name="a4MeasSCellAddEnabled">none</p>
    ...    <p name="a4PriorityForHigherPrioFreqHo">10</p>
    ...    <p name="a5MeasEnabled">none</p>
    ...    <p name="cellDepType">SA</p>
    ...    <p name="deriveSsbIndexFromCell">true</p>
    ...    <p name="freqBandIndicatorNR">78</p>
    ...    <p name="ifhoSsbScs">30 KHz</p>
    ...    <p name="ifhoSsbSmtcDuration">sf5</p>
    ...    <p name="ifhoSsbSmtcPeriodicity">sf20</p>
    ...    <p name="numberOfTransmittedSsBlocks">1 beam</p>
    ...    <p name="scs">30 KHz</p>
    ...    <p name="ssBurstSetPeriod">10</p>
    ...    <p name="ssbFrequency">647616</p>
    ...    <list name="a3MeasSsbRsrp">
    ...    <item>
    ...    <p name="a3HysteresisSsbRsrp">0</p>
    ...    <p name="a3OffsetSsbRsrp">0</p>
    ...    <p name="a3TimeToTriggerSsbRsrp">ms64</p>
    ...    </item>
    ...    </list>
    ...    <list name="a3MeasSsbRsrq">
    ...    <item>
    ...    <p name="a3HysteresisSsbRsrq">0</p>
    ...    <p name="a3OffsetSsbRsrq">0</p>
    ...    <p name="a3TimeToTriggerSsbRsrq">ms480</p>
    ...    <p name="a3TimeToTriggerSsbRsrqVoNr">ms64</p>
    ...    </item>
    ...    </list>
    ...    <list name="a4MeasEnDcSteeringSsbRsrp">
    ...    <item>
    ...    <p name="a4HysteresisEnDcSteeringSsbRsrp">0</p>
    ...    <p name="a4ThresholdEnDcSteeringSsbRsrp">35</p>
    ...    <p name="a4TimeToTriggerEnDcSteeringSsbRsrp">ms64</p>
    ...    </item>
    ...    </list>
    ...    <list name="a4MeasEnDcSteeringSsbRsrq">
    ...    <item>
    ...    <p name="a4HysteresisEnDcSteeringSsbRsrq">0</p>
    ...    <p name="a4ThresholdEnDcSteeringSsbRsrq">35</p>
    ...    <p name="a4TimeToTriggerEnDcSteeringSsbRsrq">ms64</p>
    ...    </item>
    ...    </list>
    ...    <list name="a4MeasSsbRsrp">
    ...    <item>
    ...    <p name="a4HysteresisSsbRsrp">2</p>
    ...    <p name="a4ThresholdSsbRsrp">35</p>
    ...    <p name="a4TimeToTriggerSsbRsrp">ms64</p>
    ...    </item>
    ...    </list>
    ...    <list name="a4MeasSsbRsrq">
    ...    <item>
    ...    <p name="a4HysteresisSsbRsrq">2</p>
    ...    <p name="a4ThresholdSsbRsrq">35</p>
    ...    <p name="a4TimeToTriggerSsbRsrq">ms64</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRHOIF 2bands
    [Documentation]    [PRIVATE]    Create NRCELL-1 NRHOIF-1 2bands object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRCELL-1/NRHOIF-2
    ${new_MO}   Set Variable   <managedObject class="NRHOIF" distName="${bts_distName}/NRCELL-1/NRHOIF-1"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="a1BasedPCellSwitchEnabled">false</p>
    ...    <p name="a2BasedPCellSwitchEnabled">false</p>
    ...    <p name="a3MeasEnabled">rsrp</p>
    ...    <p name="a4MeasEnDcSteeringEnabled">none</p>
    ...    <p name="a4MeasHigherPrioFreqEnabled">rsrp</p>
    ...    <p name="a4MeasNrDcEnabled">none</p>
    ...    <p name="a4MeasSCellAddEnabled">none</p>
    ...    <p name="a4PriorityForHigherPrioFreqHo">10</p>
    ...    <p name="a5MeasEnabled">none</p>
    ...    <p name="cellDepType">SA</p>
    ...    <p name="deriveSsbIndexFromCell">true</p>
    ...    <p name="freqBandIndicatorNR">41</p>
    ...    <p name="ifhoSsbScs">30 KHz</p>
    ...    <p name="ifhoSsbSmtcDuration">sf5</p>
    ...    <p name="ifhoSsbSmtcPeriodicity">sf20</p>
    ...    <p name="numberOfTransmittedSsBlocks">1 beam</p>
    ...    <p name="scs">30 KHz</p>
    ...    <p name="ssBurstSetPeriod">10</p>
    ...    <p name="ssbFrequency">508110</p>
    ...    <list name="a3MeasSsbRsrp">
    ...    <item>
    ...    <p name="a3HysteresisSsbRsrp">0</p>
    ...    <p name="a3OffsetSsbRsrp">0</p>
    ...    <p name="a3TimeToTriggerSsbRsrp">ms64</p>
    ...    </item>
    ...    </list>
    ...    <list name="a3MeasSsbRsrq">
    ...    <item>
    ...    <p name="a3HysteresisSsbRsrq">0</p>
    ...    <p name="a3OffsetSsbRsrq">0</p>
    ...    <p name="a3TimeToTriggerSsbRsrq">ms480</p>
    ...    <p name="a3TimeToTriggerSsbRsrqVoNr">ms64</p>
    ...    </item>
    ...    </list>
    ...    <list name="a4MeasEnDcSteeringSsbRsrp">
    ...    <item>
    ...    <p name="a4HysteresisEnDcSteeringSsbRsrp">0</p>
    ...    <p name="a4ThresholdEnDcSteeringSsbRsrp">35</p>
    ...    <p name="a4TimeToTriggerEnDcSteeringSsbRsrp">ms64</p>
    ...    </item>
    ...    </list>
    ...    <list name="a4MeasEnDcSteeringSsbRsrq">
    ...    <item>
    ...    <p name="a4HysteresisEnDcSteeringSsbRsrq">0</p>
    ...    <p name="a4ThresholdEnDcSteeringSsbRsrq">35</p>
    ...    <p name="a4TimeToTriggerEnDcSteeringSsbRsrq">ms64</p>
    ...    </item>
    ...    </list>
    ...    <list name="a4MeasSsbRsrp">
    ...    <item>
    ...    <p name="a4HysteresisSsbRsrp">2</p>
    ...    <p name="a4ThresholdSsbRsrp">35</p>
    ...    <p name="a4TimeToTriggerSsbRsrp">ms64</p>
    ...    </item>
    ...    </list>
    ...    <list name="a4MeasSsbRsrq">
    ...    <item>
    ...    <p name="a4HysteresisSsbRsrq">2</p>
    ...    <p name="a4ThresholdSsbRsrq">35</p>
    ...    <p name="a4TimeToTriggerSsbRsrq">ms64</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData
    Create Single NRHOIF   nrcell_id=2


Create Single NRREL
    [Documentation]    [PRIVATE]    create single NRREL object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${nrcell_id}   ${nrrel_id}    ${gNbId}   ${lcrId}   ${gNbIdLength}
    Log To Console    Building object ${bts_distName}/NRCELL-${nrcell_id}/NRREL-${nrrel_id}
    ${new_MO}   Set Variable   <managedObject class="NRREL" distName="${bts_distName}/NRCELL-${nrcell_id}/NRREL-${nrrel_id}"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="cellIndividualSsbRsrpOffset">-2dB</p>
    ...    <p name="cellIndividualSsbRsrqOffset">-2dB</p>
    ...    <p name="gNbId">${gNbId}</p>
    ...    <p name="gNbIdLength">${gNbIdLength}</p>
    ...    <p name="handoverAllowedSA">allowed</p>
    ...    <p name="handoverAllowedSARedCap">forbidden</p>
    ...    <p name="isRplCellForPSCell">false</p>
    ...    <p name="lcrId">${lcrId}</p>
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


Create NRREL
    [Documentation]    [PRIVATE]    create NRREL object
    ...       :Autor: Sylvia Schneider
    FOR     ${nrcell_id}    ${nrrel_id}    ${gNbId}   ${lcrId}   ${gNbIdLength}   IN
    ...     1               1              3          1          28
    ...     1               2              3          2          28
    ...     1               3              1          2          22
    ...     2               1              1          1          22
      Create Single NRREL   ${nrcell_id}    ${nrrel_id}    ${gNbId}   ${lcrId}   ${gNbIdLength}
    END


Create NRRELE
    [Documentation]    [PRIVATE]    create NRRELE object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRCELL-1/NRRELE-1
    ${new_MO}   Set Variable   <managedObject class="NRRELE" distName="${bts_distName}/NRCELL-1/NRRELE-1"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="cellIndividualOffset">0dB</p>
    ...    <p name="eNodeBId">18</p>
    ...    <p name="eutranCellExcluded">false</p>
    ...    <p name="lcrId">1</p>
    ...    <p name="removeNotAllowed">false</p>
    ...    <list name="ecgiPlmn">
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


Create NRMEASCFG IF
    [Documentation]    [PRIVATE]    create NRMEASCFG_IF object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMEASCFG_IF-1
    ${new_MO}   Set Variable   <managedObject class="NRMEASCFG_IF" distName="${bts_distName}/NRMEASCFG_IF-1"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="a3MeasEnabled">rsrpAndRsrq</p>
    ...    <p name="a5MeasEnabled">rsrpAndRsrq</p>
    ...    <p name="freqBandIndicatorNR">78</p>
    ...    <p name="ssbFrequency">633408</p>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRMEAS PROFILE
    [Documentation]    [PRIVATE]    create NRMEAS_PROFILE object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMEAS_PROFILE-1
    ${new_MO}   Set Variable   <managedObject class="NRMEAS_PROFILE" distName="${bts_distName}/NRMEAS_PROFILE-1"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create"/>
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create Single NRMEASPR IAF
    [Documentation]    [PRIVATE]    create NRMEASPR_IAF object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${NRMEASPR_IAF_id}
    Log To Console    Building object ${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-${NRMEASPR_IAF_id}
    ${new_MO}   Set Variable   <managedObject class="NRMEASPR_IAF" distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-${NRMEASPR_IAF_id}"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
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
    ...    <p name="a1ThresholdhoSsbRsrq">${a1MeashoPrefNRLayerSsbRsrp_a1ThresholdhoSsb}[${NRMEASPR_IAF_id}]</p>
    ...    <p name="a1TimeToTriggerhoSsbRsrq">ms40</p>
    ...    </item>
    ...    </list>
    ...    <list name="a1MeashoSsbRsrp">
    ...    <item>
    ...    <p name="a1HysteresishoSsbRsrp">0</p>
    ...    <p name="a1ThresholdhoSsbRsrp">${a1MeashoSsbRsrq_a1ThresholdhoSsb}[${NRMEASPR_IAF_id}]</p>
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
    ...    <list name="a2MeasRedirectSsbRsrp">
    ...    <item>
    ...    <p name="a2HysteresisRedirectSsbRsrp">0</p>
    ...    <p name="a2ThresholdRedirectSsbRsrp">${a2MeasRedirectSsbRsrp_a2ThresholdRedirectSsb}[${NRMEASPR_IAF_id}]</p>
    ...    <p name="a2TimeToTriggerRedirectSsbRsrp">ms480</p>
    ...    </item>
    ...    </list>
    ...       <list name="a2MeasRedirectSsbRsrq">
    ...    <item>
    ...    <p name="a2HysteresisRedirectSsbRsrq">0</p>
    ...    <p name="a2ThresholdRedirectSsbRsrq">${a2MeasRedirectSsbRsrp_a2ThresholdRedirectSsb}[${NRMEASPR_IAF_id}]</p>
    ...    <p name="a2TimeToTriggerRedirectSsbRsrq">ms480</p>
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
    ...    <p name="a2ThresholdReleaseSsbRsrq">${a2MeasReleaseSsbRsrp_a2ThresholdReleaseSsb}[${NRMEASPR_IAF_id}]</p>
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
    ...    <p name="a2ThresholdhoSsbRsrq">${a2MeashoSsbRsrp_a2ThresholdhoSsb}[${NRMEASPR_IAF_id}]</p>
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
    ...    <p name="a3OffsetSsbRsrq">${a3MeasSsbRsrp_a3OffsetSsb}[${NRMEASPR_IAF_id}]</p>
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
    ...    <p name="a5Threshold1SsbRsrq">${a5MeasSsbRsrp_a5Threshold1Ssb}[${NRMEASPR_IAF_id}]</p>
    ...    <p name="a5Threshold2SsbRsrq">${a5MeasSsbRsrp_a5Threshold2Ssb}[${NRMEASPR_IAF_id}]</p>
    ...    <p name="a5TimeToTriggerSsbRsrq">ms320</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRMEASPR IAF
    [Documentation]    [PRIVATE]    create NRMEASPR_IAF object in SCF
    ...       :Autor: Sylvia Schneider
    FOR    ${id}   IN  1  2  3  4  5  6  7  8
       Create Single NRMEASPR IAF    NRMEASPR_IAF_id=${id}
    END


Create NRMEASPR IEF T19
    [Documentation]    [PRIVATE]    create single NRMEASPR_IEF object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IEF-1
    ${new_MO}   Set Variable   <managedObject class="NRMEASPR_IEF" distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IEF-1"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <list name="a3MeasSsbRsrp">
    ...    <item>
    ...    <p name="a3HysteresisSsbRsrp">0</p>
    ...    <p name="a3OffsetSsbRsrp">2</p>
    ...    <p name="a3TimeToTriggerSsbRsrp">ms480</p>
    ...    </item>
    ...    </list>
    ...    <list name="a3MeasSsbRsrq">
    ...    <item>
    ...    <p name="a3HysteresisSsbRsrq">0</p>
    ...    <p name="a3OffsetSsbRsrq">3</p>
    ...    <p name="a3TimeToTriggerSsbRsrq">ms480</p>
    ...    </item>
    ...    </list>
    ...    <list name="a4MeasHigherPrioFreqSsbRsrp">
    ...    <item>
    ...    <p name="a4HysteresisSsbRsrp">0</p>
    ...    <p name="a4ThresholdSsbRsrp">30</p>
    ...    <p name="a4TimeToTriggerSsbRsrp">ms64</p>
    ...    </item>
    ...    </list>
    ...       <list name="a4MeasHigherPrioFreqSsbRsrq">
    ...    <item>
    ...    <p name="a4HysteresisSsbRsrq">0</p>
    ...    <p name="a4ThresholdSsbRsrq">31</p>
    ...    <p name="a4TimeToTriggerSsbRsrq">ms64</p>
    ...    </item>
    ...    </list>
    ...    <list name="a5MeasSsbRsrp">
    ...    <item>
    ...    <p name="a5HysteresisSsbRsrp">0</p>
    ...    <p name="a5Threshold1SsbRsrp">64</p>
    ...    <p name="a5Threshold2SsbRsrp">69</p>
    ...    <p name="a5TimeToTriggerSsbRsrp">ms320</p>
    ...    </item>
    ...    </list>
    ...    <list name="a5MeasSsbRsrq">
    ...    <item>
    ...    <p name="a5HysteresisSsbRsrq">0</p>
    ...    <p name="a5Threshold1SsbRsrq">65</p>
    ...    <p name="a5Threshold2SsbRsrq">70</p>
    ...    <p name="a5TimeToTriggerSsbRsrq">ms320</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create Single NRMEASPR IEF
    [Documentation]    [PRIVATE]    create single NRMEASPR_IEF object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${NRMEASPR_IEF_id}
    @{a3OffsetSsbRsrp}       Create List     ${EMPTY}     2    3
    @{a3OffsetSsbRsrq}       Create List     ${EMPTY}     2    4
    @{a5Threshold1SsbRsrp}   Create List     ${EMPTY}     64   65
    @{a5Threshold2SsbRsrp}   Create List     ${EMPTY}     69   70
    @{a5Threshold1SsbRsrq}   Create List     ${EMPTY}     64   66
    @{a5Threshold2SsbRsrq}   Create List     ${EMPTY}     69   71

    Log To Console    Building object ${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IEF-${NRMEASPR_IEF_id}
    ${new_MO}   Set Variable   <managedObject class="NRMEASPR_IEF" distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IEF-${NRMEASPR_IEF_id}"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <list name="a3MeasSsbRsrp">
    ...    <item>
    ...    <p name="a3HysteresisSsbRsrp">0</p>
    ...    <p name="a3OffsetSsbRsrp">${a3OffsetSsbRsrp}[${NRMEASPR_IEF_id}]</p>
    ...    <p name="a3TimeToTriggerSsbRsrp">ms480</p>
    ...    </item>
    ...    </list>
    ...    <list name="a3MeasSsbRsrq">
    ...    <item>
    ...    <p name="a3HysteresisSsbRsrq">0</p>
    ...    <p name="a3OffsetSsbRsrq">${a3OffsetSsbRsrq}[${NRMEASPR_IEF_id}]</p>
    ...    <p name="a3TimeToTriggerSsbRsrq">ms480</p>
    ...    </item>
    ...    </list>
    ...    <list name="a5MeasSsbRsrp">
    ...    <item>
    ...    <p name="a5HysteresisSsbRsrp">0</p>
    ...    <p name="a5Threshold1SsbRsrp">${a5Threshold1SsbRsrp}[${NRMEASPR_IEF_id}]</p>
    ...    <p name="a5Threshold2SsbRsrp">${a5Threshold2SsbRsrp}[${NRMEASPR_IEF_id}]</p>
    ...    <p name="a5TimeToTriggerSsbRsrp">ms320</p>
    ...    </item>
    ...    </list>
    ...    <list name="a5MeasSsbRsrq">
    ...    <item>
    ...    <p name="a5HysteresisSsbRsrq">0</p>
    ...    <p name="a5Threshold1SsbRsrq">${a5Threshold1SsbRsrq}[${NRMEASPR_IEF_id}]</p>
    ...    <p name="a5Threshold2SsbRsrq">${a5Threshold2SsbRsrq}[${NRMEASPR_IEF_id}]</p>
    ...    <p name="a5TimeToTriggerSsbRsrq">ms320</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRMEASPR IEF
    [Documentation]    [PRIVATE]    create NRMEASPR_IEF object in SCF
    ...       :Autor: Sylvia Schneider
    FOR    ${id}   IN  1  2
       Create Single NRMEASPR IEF    NRMEASPR_IEF_id=${id}
    END


Create Single NRMEASPR IRF
    [Documentation]    [PRIVATE]    create NRMEASPR_IRF object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${NRMEASPR_IRF_id}
    Log To Console    Building object ${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IRF-${NRMEASPR_IRF_id}
    ${new_MO}   Set Variable   <managedObject class="NRMEASPR_IRF" distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IRF-${NRMEASPR_IRF_id}"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="b2Threshold1hoRsrp">${b2Threshold1hoRsrp_b2Threshold1hoRsrq}[${NRMEASPR_IRF_id}]</p>
    ...    <p name="b2Threshold1hoRsrq">${b2Threshold1hoRsrp_b2Threshold1hoRsrq}[${NRMEASPR_IRF_id}]</p>
    ...    <list name="eutraB2MeashoRsrp">
    ...    <item>
    ...    <p name="b2HysteresishoRsrp">0</p>
    ...    <p name="b2Threshold2hoRsrp">${b2Threshold2hoRsrp_b2Threshold2hoRsrq}[${NRMEASPR_IRF_id}]</p>
    ...    <p name="b2TimeToTriggerhoRsrp">ms480</p>
    ...    </item>
    ...    </list>
    ...    <list name="eutraB2MeashoRsrq">
    ...    <item>
    ...    <p name="b2HysteresishoRsrq">0</p>
    ...    <p name="b2Threshold2hoRsrq">${b2Threshold2hoRsrp_b2Threshold2hoRsrq}[${NRMEASPR_IRF_id}]</p>
    ...    <p name="b2TimeToTriggerhoRsrq">ms480</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRMEASPR IRF
    [Documentation]    [PRIVATE]    create NRMEASPR_IRF object in SCF
    ...       :Autor: Sylvia Schneider
    FOR    ${id}   IN  1  2  3  4  5  6  7  8
       Create Single NRMEASPR IRF    NRMEASPR_IRF_id=${id}
    END


Create Single NRMEASPR MA SA
    [Documentation]    [PRIVATE]    create single NRMEASPR_MA_SA object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]  ${id}  ${freqBandIndicatorNR_1}  ${uePowerClass_1}  ${uePowerClass_2}
    Log To Console    Building object ${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-${id}
    ${new_MO}   Set Variable   <managedObject class="NRMEASPR_MA_SA" distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-${id}"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="nrMeasPrIafDN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-${id}</p>
    ...    <list name="pcCapabilityList">
    ...    <item>
    ...    <p name="freqBandIndicatorNR">${freqBandIndicatorNR_1}</p>
    ...    <p name="uePowerClass">${uePowerClass_1}</p>
    ...    </item>
    ...    <item>
    ...    <p name="freqBandIndicatorNR">78</p>
    ...    <p name="uePowerClass">${uePowerClass_2}</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRMEASPR MA SA
    [Documentation]    [PRIVATE]    create NRMEASPR_MA_SA object
    ...       :Autor: Sylvia Schneider
    FOR    ${id}  ${freqBandIndicatorNR_1}  ${uePowerClass_1}    ${uePowerClass_2}  IN
    ...    1      41                        ue-PowerClass1Dot5   ue-PowerClass1
    ...    2      41                        ue-PowerClass5       ue-PowerClass1Dot5
    ...    3      79                        ue-PowerClass1Dot5   ue-PowerClass2
    ...    4      41                        ue-PowerClass1Dot5   ue-PowerClass3
    ...    5      41                        ue-PowerClass1Dot5   ue-PowerClass4
    ...    6      41                        ue-PowerClass1Dot5   ue-PowerClass5
    ...    7      41                        ue-PowerClass1Dot5   ue-PowerClass6
    ...    8      41                        ue-PowerClass1Dot5   ue-PowerClass7
       Create Single NRMEASPR MA SA   ${id}   ${freqBandIndicatorNR_1}  ${uePowerClass_1}    ${uePowerClass_2}
    END


Recreate NRMEASPR MA SA-3 And NRMEASPR MA SA-4
    [Documentation]    [PRIVATE]    Recreate NRMEASPR_MA_SA-3 and NRMEASPR_MA_SA-4 objects
    ...       :Autor: Sylvia Schneider
    FOR    ${id}  ${ief_snssai_id}  IN
    ...    3      1
    ...    4      2
       Recreate Single NRMEASPR MA SA-3 And NRMEASPR MA SA-4   ${id}   ${ief_snssai_id}
    END


Recreate Single NRMEASPR MA SA-3 And NRMEASPR MA SA-4
    [Documentation]    [PRIVATE]    Recreate single NRMEASPR_MA_SA-3 and NRMEASPR_MA_SA-4
    ...       :Autor: Sylvia Schneider
    [Arguments]  ${id}  ${ief_snssai_id}
    Log To Console    Building object ${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-${id}
    ${new_MO}   Set Variable   <managedObject class="NRMEASPR_MA_SA" distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-${id}"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="nrMeasPrIafDN">MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_IAF-${id}</p>
    ...    <p name="nrMeasPrIrfDN">MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_IRF-${id}</p>
    ...    <list name="nrMeasPrIefList">
    ...    <item>
    ...    <p name="nrMeasPrIefDN">MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_IEF-${ief_snssai_id}</p>
    ...    <p name="ssbFrequency01">508110</p>
    ...    </item>
    ...    </list>
    ...    <list name="pcCapabilityList">
    ...    <item>
    ...    <p name="freqBandIndicatorNR">41</p>
    ...    <p name="uePowerClass">ue-PowerClass2</p>
    ...    </item>
    ...    <item>
    ...    <p name="freqBandIndicatorNR">78</p>
    ...    <p name="uePowerClass">ue-PowerClass3</p>
    ...    </item>
    ...    </list>
    ...    <list name="snssaiList">
    ...    <item>
    ...    <p name="snssaiDN">MRBTS-1/NRBTS-1/SNSSAI-${ief_snssai_id}</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Update NRMEASPR MA SA-2
    [Documentation]    [PRIVATE]    update NRMEASPR_MA_SA-2 object
    ...       :Autor: Sylvia Schneider
    Update Single NRMEASPR MA SA   freqBandIndicatorNR=77      uePowerClass=ue-PowerClass2    NRMEASPR_MA_SA_id=2


Update 2bands NRMEASPR MA SA-5 And NRMEASPR MA SA-7
    [Documentation]    [PRIVATE]    update 2bands NRMEASPR_MA_SA-5 and NRMEASPR_MA_SA-7
    ...       :Autor: Sylvia Schneider
    FOR    ${freqBandIndicatorNR}      ${uePowerClass}    ${NRMEASPR_MA_SA_id}   IN
    ...    77                          ue-PowerClass5     5
    ...    90                          ue-PowerClass5     7
       Update Single NRMEASPR MA SA   ${freqBandIndicatorNR}      ${uePowerClass}    ${NRMEASPR_MA_SA_id}
    END


Update Single NRMEASPR MA SA
    [Documentation]    [PRIVATE]    update single NRMEASPR_MA_SA
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${freqBandIndicatorNR}      ${uePowerClass}    ${NRMEASPR_MA_SA_id}
    ${new_item}   Set Variable   ${EMPTY}
    FOR     ${line}   IN
    ...     <item>
    ...     <p name="freqBandIndicatorNR">${freqBandIndicatorNR}</p>
    ...     <p name="uePowerClass">${uePowerClass}</p>
    ...     </item>
           ${new_item}   Catenate     SEPARATOR=\n         ${new_item}   ${line}
    END
    Add Element   ${scf_xml}     ${new_item}
    ...      xpath=.//managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-${NRMEASPR_MA_SA_id}"]/list[@name="pcCapabilityList"]


Recreate NRMEASPR MA SA-5 And NRMEASPR MA SA-6
    [Documentation]    [PRIVATE]    update single NRMEASPR_MA_SA
    ...       :Autor: Sylvia Schneider
    FOR    ${id}    IN   5   6
       Remove Element   ${scf_xml}     xpath=.//managedObject[@distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-${id}"]
       Recreate Single NRMEASPR MA SA-5 And NRMEASPR MA SA-6   id=${id}
    END


Recreate Single NRMEASPR MA SA-5 And NRMEASPR MA SA-6
    [Documentation]    [PRIVATE]    Recreate single NRMEASPR_MA_SA-5 and NRMEASPR_MA_SA-6 t19
    ...       :Autor: Sylvia Schneider
    [Arguments]  ${id}
    Log To Console    Building object ${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-${id}
    ${uePowerClass_41_id5}   Set Variable   ue-PowerClass2
    ${uePowerClass_78_id5}   Set Variable   ue-PowerClass4
    ${uePowerClass_41_id6}   Set Variable   ue-PowerClass1Dot5
    ${uePowerClass_78_id6}   Set Variable   ue-PowerClass5
    ${new_MO}   Set Variable   <managedObject class="NRMEASPR_MA_SA" distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-${id}"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="nrMeasPrIafDN">MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_IAF-${id}</p>
    ...    <list name="nrMeasPrIefList">
    ...    <item>
    ...    <p name="nrMeasPrIefDN">MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_IEF-1</p>
    ...    <p name="ssbFrequency01">508110</p>
    ...    </item>
    ...    </list>
    ...    <list name="pcCapabilityList">
    ...    <item>
    ...    <p name="freqBandIndicatorNR">41</p>
    ...    <p name="uePowerClass">${uePowerClass_41_id${id}}</p>
    ...    </item>
    ...    <item>
    ...    <p name="freqBandIndicatorNR">78</p>
    ...    <p name="uePowerClass">${uePowerClass_78_id${id}}</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRMOPR NSA
    [Documentation]    [PRIVATE]    create NRMOPR_NSA object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPR_NSA-1
    ${new_MO}   Set Variable   <managedObject class="NRMOPR_NSA" distName="${bts_distName}/NRMOPR_NSA-1"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="a1MeashoEnabled">none</p>
    ...    <p name="a2MeashoEnabled">none</p>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRMOPR SA
    [Documentation]    [PRIVATE]    create NRMOPR_SA object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPR_SA-1
    ${new_MO}   Set Variable   <managedObject class="NRMOPR_SA" distName="${bts_distName}/NRMOPR_SA-1"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="a1MeashoEnabledSA">rsrpAndRsrq</p>
    ...    <p name="a2MeashoEnabledSA">rsrpAndRsrq</p>
    ...    <p name="emergencyCallFails">disabled</p>
    ...    <p name="emergencyFBMode">disabled</p>
    ...    <p name="voiceFBMode">disabled</p>
    ...    <list name="nrMeasCfgIfDNList">
    ...    <p>${bts_distName}/NRMEASCFG_IF-1</p>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRMOPRMA NSA
    [Documentation]    [PRIVATE]    create NRMOPRMA_NSA object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPRMA_NSA-1
    ${new_MO}   Set Variable   <managedObject class="NRMOPRMA_NSA" distName="${bts_distName}/NRMOPRMA_NSA-1"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="mobilityProfilePriority">1</p>
    ...    <p name="nrMoPrNsaDN">${bts_distName}/NRMOPR_NSA-1</p>
    ...    <list name="nrPlmnDNList">
    ...    <p>${bts_distName}/NRPLMN-1</p>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRMOPRMA SA
    [Documentation]    [PRIVATE]    create NRMOPRMA_SA object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPRMA_SA-1
    ${new_MO}   Set Variable   <managedObject class="NRMOPRMA_SA" distName="${bts_distName}/NRMOPRMA_SA-1"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="mobilityProfilePriority">1</p>
    ...    <p name="nrMoPrSaDN">${bts_distName}/NRMOPR_SA-1</p>
    ...    <list name="nrPlmnDNList">
    ...    <p>${bts_distName}/NRPLMN-1</p>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRPMQAP
    [Documentation]    [PRIVATE]    create NRPMQAP object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRPMQAP-1
    ${new_MO}   Set Variable  <managedObject class="NRPMQAP" distName="${SCF.NRPMRNL_distName}/NRPMQAP-1"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}    version="${SCF.NRPMRNL_version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="actCplaneCounters">false</p>
    ...    <p name="actUPlaneGroup1Counters">false</p>
    ...    <p name="actUPlaneGroup2Counters">false</p>
    ...    <p name="cfg5qiRange">1-9</p>
    ...    <p name="cfgArpRange">1-15</p>
    ...    <p name="cfgProfType">both</p>
    ...    <p name="cfgUECategoryFR1">All UEs</p>
    ...    <p name="cfgUECategoryFR2">All UEs</p>
    ...    <list name="cfgPlmnId">
    ...    <item>
    ...    <p name="mcc">${SCF.mcc}</p>
    ...    <p name="mnc">${SCF.mnc}</p>
    ...    <p name="mncLength">3</p>
    ...    </item>
    ...    </list>
    ...    <list name="cfgSliceId">
    ...    <item>
    ...    <p name="sd">13714341</p>
    ...    <p name="sst">1</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRPMQAP_25R
    [Documentation]    [PRIVATE]    create NRPMQAP object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRPMQAP-1
    ${new_MO}   Set Variable  <managedObject class="NRPMQAP" distName="${SCF.NRPMRNL_distName}/NRPMQAP-1"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}    version="${SCF.NRPMRNL_version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="actCplaneCounters">false</p>
    ...    <p name="actUPlaneGroup1Counters">false</p>
    ...    <p name="actUPlaneGroup2Counters">false</p>
    ...    <p name="cfg5qiRange">1-9</p>
    ...    <p name="cfgArpRange">1-15</p>
    ...    <p name="cfgProfType">both</p>
    ...    <list name="cfgPlmnId">
    ...    <item>
    ...    <p name="mcc">${SCF.mcc}</p>
    ...    <p name="mnc">${SCF.mnc}</p>
    ...    <p name="mncLength">3</p>
    ...    </item>
    ...    </list>
    ...    <list name="cfgSliceId">
    ...    <item>
    ...    <p name="sd">13714341</p>
    ...    <p name="sst">1</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRPLMN
    [Documentation]    [PRIVATE]    create NRPLMN object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRPLMN-2
    ${new_MO}   Set Variable   <managedObject class="com.nokia.srbts.nrbts:NRPLMN" distName="${bts_distName}/NRPLMN-2"
    ${new_MO}   Catenate       SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="mcc">311</p>
    ...    <p name="mnc">388</p>
    ...    <p name="mncLength">3</p>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Remove NRREDRT-0
    [Documentation]    [PRIVATE]    Recreate NRREDRT object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${scf_file_in}      ${scf_file_out}
    Log To Console    remove element "${bts_distName}/NRCELL-1/NRREDRT-0"
    scf.Load Scf    ${scf_file_in}
    scf.Remove Mo With Descendant Mos        dist_name=${bts_distName}/NRCELL-1/NRREDRT-0
    scf.Save Scf    ${scf_file_out}


Recreate NRREDRT
    [Documentation]    [PRIVATE]    Recreate NRREDRT object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    re-create object ${bts_distName}/NRCELL-1/NRREDRT-0
    ${new_MO}   Set Variable   <managedObject class="NRREDRT" distName="${bts_distName}/NRCELL-1/NRREDRT-0"
    ${new_MO}   Catenate       SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="redirFreqNr">633364</p>
    ...    <p name="redirPrio">1</p>
    ...    <p name="redirRat">nr</p>
    ...    <p name="redirSsbScs">15KHz</p>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Recreate 2bands NRREDRT
    [Documentation]    [PRIVATE]    Recreate NRREDRT object in SCF 2bands
    ...       :Autor: Sylvia Schneider
    Log To Console    re-create object ${bts_distName}/NRCELL-1/NRREDRT-0
    ${new_MO}   Set Variable   <managedObject class="NRREDRT" distName="${bts_distName}/NRCELL-1/NRREDRT-0"
    ${new_MO}   Catenate       SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="redirFreqNr">508020</p>
    ...    <p name="redirPrio">1</p>
    ...    <p name="redirRat">nr</p>
    ...    <p name="redirSsbScs">30 KHz</p>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create SNSSAI
    [Documentation]    [PRIVATE]    create SNSSAI object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/SNSSAI-2
    ${new_MO}   Set Variable   <managedObject class="com.nokia.srbts.nrbts:SNSSAI" distName="${bts_distName}/SNSSAI-2"
    ${new_MO}   Catenate       SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="administrativeState">Unlocked</p>
    ...    <p name="sd">13714342</p>
    ...    <p name="sst">1</p>
    ...    <list name="nrPlmnDNList">
    ...    <p>${bts_distName}/NRPLMN-1</p>
    ...    <p>${bts_distName}/NRPLMN-2</p>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create XNLINK
    [Documentation]    [PRIVATE]    create XNLINK object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/XNLINK-1
    ${new_MO}   Set Variable   <managedObject class="com.nokia.srbts.nrbts:XNLINK" distName="${bts_distName}/XNLINK-1"
    ${new_MO}   Catenate       SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="cPlaneIpAddr">10.0.1.3</p>
    ...    <p name="cPlaneIpAddrCtrl">oamControlled</p>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create XNLINK-2
    [Documentation]    [PRIVATE]    create XNLINK-2 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/XNLINK-1
    ${new_MO}   Set Variable   <managedObject class="com.nokia.srbts.nrbts:XNLINK" distName="${bts_distName}/XNLINK-2"
    ${new_MO}   Catenate       SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="cPlaneIpAddr">10.0.1.6</p>
    ...    <p name="cPlaneIpAddrCtrl">oamControlled</p>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData
