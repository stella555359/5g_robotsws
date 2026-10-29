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


Create NRCONNECTMODE_PROFILE
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


Create NRCELL-1 NRHOIF-1
    [Documentation]    [PRIVATE]    create NRCELL-1 NRHOIF object in SCF
    ...       :Autor: Sylvia Schneider

    Log To Console    Building object ${bts_distName}/NRCELL-1/NRHOIF-1
    ${new_MO}   Set Variable   <managedObject class="NRHOIF" distName="${bts_distName}/NRCELL-1/NRHOIF-1"
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
    ...    <p name="deriveSsbIndexFromCell">true</p>
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
    ...    <p name="a3HysteresisSsbRsrpVoNr">0</p>
    ...    <p name="a3OffsetSsbRsrp">0</p>
    ...    <p name="a3OffsetSsbRsrpVoNr">10</p>
    ...    <p name="a3TimeToTriggerSsbRsrp">ms0</p>
    ...    <p name="a3TimeToTriggerSsbRsrpVoNr">ms0</p>
    ...    </item>
    ...    </list>
    ...    <list name="a3MeasSsbRsrq">
    ...    <item>
    ...    <p name="a3HysteresisSsbRsrq">2</p>
    ...    <p name="a3HysteresisSsbRsrqVoNr">0</p>
    ...    <p name="a3OffsetSsbRsrq">10</p>
    ...    <p name="a3OffsetSsbRsrqVoNr">15</p>
    ...    <p name="a3TimeToTriggerSsbRsrq">ms40</p>
    ...    <p name="a3TimeToTriggerSsbRsrqVoNr">ms40</p>
    ...    </item>
    ...    </list>
    ...    <list name="a5MeasSsbRsrp">
    ...    <item>
    ...    <p name="a5HysteresisSsbRsrp">0</p>
    ...    <p name="a5HysteresisSsbRsrpVoNr">0</p>
    ...    <p name="a5Threshold1SsbRsrp">102</p>
    ...    <p name="a5Threshold1SsbRsrpVoNr">105</p>
    ...    <p name="a5Threshold2SsbRsrp">92</p>
    ...    <p name="a5Threshold2SsbRsrpVoNr">95</p>
    ...    <p name="a5TimeToTriggerSsbRsrp">ms480</p>
    ...    <p name="a5TimeToTriggerSsbRsrpVoNr">ms480</p>
    ...    </item>
    ...    </list>
    ...    <list name="a5MeasSsbRsrq">
    ...    <item>
    ...    <p name="a5HysteresisSsbRsrq">0</p>
    ...    <p name="a5HysteresisSsbRsrqVoNr">0</p>
    ...    <p name="a5Threshold1SsbRsrq">40</p>
    ...    <p name="a5Threshold1SsbRsrqVoNr">45</p>
    ...    <p name="a5Threshold2SsbRsrq">30</p>
    ...    <p name="a5Threshold2SsbRsrqVoNr">35</p>
    ...    <p name="a5TimeToTriggerSsbRsrq">ms480</p>
    ...    <p name="a5TimeToTriggerSsbRsrqVoNr">ms480</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRCELL-2 NRHOIF-1
    [Documentation]    [PRIVATE]    create NRCELL-2 NRHOIF object in SCF
    ...       :Autor: Sylvia Schneider

    Log To Console    Building object ${bts_distName}/NRCELL-2/NRHOIF-1
    ${new_MO}   Set Variable   <managedObject class="NRHOIF" distName="${bts_distName}/NRCELL-2/NRHOIF-1"
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

Create NRHOIR
    [Documentation]    [PRIVATE]    create NRHOIR object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRHOIR-1
    ${new_MO}   Set Variable   <managedObject class="NRHOIR" distName="${bts_distName}/NRHOIR-1"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="allowedMeasBandwidth">mbw50</p>
    ...    <p name="b1MeasRedirectEnabled">none</p>
    ...    <p name="b2MeashoEnabled">rsrp</p>
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


Create single NRREL
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


Create NRMEASCFG_IF
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


Create NRMEAS_PROFILE
    [Documentation]    [PRIVATE]    create NRMEAS_PROFILE object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMEAS_PROFILE-1
    ${new_MO}   Set Variable   <managedObject class="NRMEAS_PROFILE" distName="${bts_distName}/NRMEAS_PROFILE-1"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create"/>
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create single NRMEASPR_IAF
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
    ...    <p name="a1ThresholdhoSsbRsrp">${IAF_a1MeashoPrefNRLayerSsbRsrp_a1ThresholdhoSsb}[${NRMEASPR_IAF_id}]</p>
    ...    <p name="a1TimeToTriggerhoSsbRsrp">ms40</p>
    ...    </item>
    ...    </list>
    ...    <list name="a1MeashoPrefNRLayerSsbRsrq">
    ...    <item>
    ...    <p name="a1HysteresisSsbRsrq">0</p>
    ...    <p name="a1ThresholdhoSsbRsrq">${IAF_a1MeashoPrefNRLayerSsbRsrp_a1ThresholdhoSsb}[${NRMEASPR_IAF_id}]</p>
    ...    <p name="a1TimeToTriggerhoSsbRsrq">ms40</p>
    ...    </item>
    ...    </list>
    ...    <list name="a1MeashoSsbRsrp">
    ...    <item>
    ...    <p name="a1HysteresishoSsbRsrp">0</p>
    ...    <p name="a1ThresholdhoSsbRsrp">${IAF_a1MeashoSsbRsrp_a1ThresholdhoSsb}[${NRMEASPR_IAF_id}]</p>
    ...    <p name="a1TimeToTriggerhoSsbRsrp">ms480</p>
    ...    </item>
    ...    </list>
    ...    <list name="a1MeashoSsbRsrq">
    ...    <item>
    ...    <p name="a1HysteresishoSsbRsrq">0</p>
    ...    <p name="a1ThresholdhoSsbRsrq">${IAF_a1MeashoSsbRsrp_a1ThresholdhoSsb}[${NRMEASPR_IAF_id}]</p>
    ...    <p name="a1TimeToTriggerhoSsbRsrq">ms480</p>
    ...    </item>
    ...    </list>
    ...    <list name="a2MeasRedirectSsbRsrp">
    ...    <item>
    ...    <p name="a2HysteresisRedirectSsbRsrp">0</p>
    ...    <p name="a2ThresholdRedirectSsbRsrp">${IAF_a2MeasRedirectSsbRsrp_a2ThresholdRedirectSsb}[${NRMEASPR_IAF_id}]</p>
    ...    <p name="a2TimeToTriggerRedirectSsbRsrp">ms480</p>
    ...    </item>
    ...    </list>
    ...       <list name="a2MeasRedirectSsbRsrq">
    ...    <item>
    ...    <p name="a2HysteresisRedirectSsbRsrq">0</p>
    ...    <p name="a2ThresholdRedirectSsbRsrq">${IAF_a2MeasRedirectSsbRsrp_a2ThresholdRedirectSsb}[${NRMEASPR_IAF_id}]</p>
    ...    <p name="a2TimeToTriggerRedirectSsbRsrq">ms480</p>
    ...    </item>
    ...    </list>
    ...    <list name="a2MeasReleaseSsbRsrp">
    ...    <item>
    ...    <p name="a2HysteresisReleaseSsbRsrp">0</p>
    ...    <p name="a2ThresholdReleaseSsbRsrp">${IAF_a2MeasReleaseSsbRsrp_a2ThresholdReleaseSsb}[${NRMEASPR_IAF_id}]</p>
    ...    <p name="a2TimeToTriggerReleaseSsbRsrp">ms480</p>
    ...    </item>
    ...    </list>
    ...    <list name="a2MeasReleaseSsbRsrq">
    ...    <item>
    ...    <p name="a2HysteresisReleaseSsbRsrq">0</p>
    ...    <p name="a2ThresholdReleaseSsbRsrq">${IAF_a2MeasReleaseSsbRsrp_a2ThresholdReleaseSsb}[${NRMEASPR_IAF_id}]</p>
    ...    <p name="a2TimeToTriggerReleaseSsbRsrq">ms480</p>
    ...    </item>
    ...    </list>
    ...    <list name="a2MeashoSsbRsrp">
    ...    <item>
    ...    <p name="a2HysteresishoSsbRsrp">0</p>
    ...    <p name="a2ThresholdhoSsbRsrp">${IAF_a2MeashoSsbRsrp_a2ThresholdhoSsb}[${NRMEASPR_IAF_id}]</p>
    ...    <p name="a2TimeToTriggerhoSsbRsrp">ms480</p>
    ...    </item>
    ...    </list>
    ...    <list name="a2MeashoSsbRsrq">
    ...    <item>
    ...    <p name="a2HysteresishoSsbRsrq">0</p>
    ...    <p name="a2ThresholdhoSsbRsrq">${IAF_a2MeashoSsbRsrp_a2ThresholdhoSsb}[${NRMEASPR_IAF_id}]</p>
    ...    <p name="a2TimeToTriggerhoSsbRsrq">ms480</p>
    ...    </item>
    ...    </list>
    ...    <list name="a3MeasSsbRsrp">
    ...    <item>
    ...    <p name="a3HysteresisSsbRsrp">0</p>
    ...    <p name="a3OffsetSsbRsrp">${IAF_a3MeasSsbRsrp_a3OffsetSsb}[${NRMEASPR_IAF_id}]</p>
    ...    <p name="a3TimeToTriggerSsbRsrp">ms320</p>
    ...    </item>
    ...    </list>
    ...    <list name="a3MeasSsbRsrq">
    ...    <item>
    ...    <p name="a3HysteresisSsbRsrq">0</p>
    ...    <p name="a3OffsetSsbRsrq">${IAF_a3MeasSsbRsrp_a3OffsetSsb}[${NRMEASPR_IAF_id}]</p>
    ...    <p name="a3TimeToTriggerSsbRsrq">ms320</p>
    ...    </item>
    ...    </list>
    ...    <list name="a5MeasSsbRsrp">
    ...    <item>
    ...    <p name="a5HysteresisSsbRsrp">0</p>
    ...    <p name="a5Threshold1SsbRsrp">${IAF_a5MeasSsbRsrp_a5Threshold1Ssb}[${NRMEASPR_IAF_id}]</p>
    ...    <p name="a5Threshold2SsbRsrp">${IAF_a5MeasSsbRsrp_a5Threshold2Ssb}[${NRMEASPR_IAF_id}]</p>
    ...    <p name="a5TimeToTriggerSsbRsrp">ms320</p>
    ...    </item>
    ...    </list>
    ...    <list name="a5MeasSsbRsrq">
    ...    <item>
    ...    <p name="a5HysteresisSsbRsrq">0</p>
    ...    <p name="a5Threshold1SsbRsrq">${IAF_a5MeasSsbRsrp_a5Threshold1Ssb}[${NRMEASPR_IAF_id}]</p>
    ...    <p name="a5Threshold2SsbRsrq">${IAF_a5MeasSsbRsrp_a5Threshold2Ssb}[${NRMEASPR_IAF_id}]</p>
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


Create single NRMEASPR_IEF
    [Documentation]    [PRIVATE]    create single NRMEASPR_IEF object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${NRMEASPR_IEF_id}

    Log To Console    Building object ${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IEF-${NRMEASPR_IEF_id}
    ${new_MO}   Set Variable   <managedObject class="NRMEASPR_IEF" distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IEF-${NRMEASPR_IEF_id}"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
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
    ...    <p name="a4TimeToTriggerSsbRsrp">${IEF_a4TimeToTriggerSsbRsrp}[${NRMEASPR_IEF_id}]</p>
    ...    </item>
    ...    </list>
    ...    <list name="a4MeasHigherPrioFreqSsbRsrq">
    ...    <item>
    ...    <p name="a4HysteresisSsbRsrq">0</p>
    ...    <p name="a4ThresholdSsbRsrq">${IEF_a4ThresholdSsbRsrq}[${NRMEASPR_IEF_id}]</p>
    ...    <p name="a4TimeToTriggerSsbRsrq">${IEF_a4TimeToTriggerSsbRsrp}[${NRMEASPR_IEF_id}]</p>
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
    ...    </list>
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
    [Documentation]    [PRIVATE]    create NRMEASPR_IEF-3 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IEF-3
    ${new_MO}   Set Variable   <managedObject class="NRMEASPR_IEF" distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IEF-3"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <list name="a3MeasSsbRsrp">
    ...    <item>
    ...    <p name="a3HysteresisSsbRsrp">0</p>
    ...    <p name="a3OffsetSsbRsrp">${IEF_a3OffsetSsbRsrp}[3]</p>
    ...    <p name="a3TimeToTriggerSsbRsrp">ms480</p>
    ...    </item>
    ...    </list>
    ...    <list name="a3MeasSsbRsrq">
    ...    <item>
    ...    <p name="a3HysteresisSsbRsrq">0</p>
    ...    <p name="a3OffsetSsbRsrq">${IEF_a3OffsetSsbRsrq}[3]</p>
    ...    <p name="a3TimeToTriggerSsbRsrq">ms480</p>
    ...    </item>
    ...    </list>
    ...    <list name="a5MeasSsbRsrp">
    ...    <item>
    ...    <p name="a5HysteresisSsbRsrp">0</p>
    ...    <p name="a5Threshold1SsbRsrp">${IEF_a5Threshold1SsbRsrp}[3]</p>
    ...    <p name="a5Threshold2SsbRsrp">${IEF_a5Threshold2SsbRsrp}[3]</p>
    ...    <p name="a5TimeToTriggerSsbRsrp">ms320</p>
    ...    </item>
    ...    </list>
    ...    <list name="a5MeasSsbRsrq">
    ...    <item>
    ...    <p name="a5HysteresisSsbRsrq">0</p>
    ...    <p name="a5Threshold1SsbRsrq">${IEF_a5Threshold1SsbRsrq}[3]</p>
    ...    <p name="a5Threshold2SsbRsrq">${IEF_a5Threshold2SsbRsrq}[3]</p>
    ...    <p name="a5TimeToTriggerSsbRsrq">ms320</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRMEASPR_IAF-3
    [Documentation]    [PRIVATE]    create NRMEASPR_IAF-3 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-3
    ${new_MO}   Set Variable   <managedObject class="NRMEASPR_IAF" distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-3"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <list name="a1MeashoPrefNRLayerSsbRsrp">
    ...    <item>
    ...    <p name="a1HysteresisSsbRsrp">0</p>
    ...    <p name="a1ThresholdhoSsbRsrp">${IAF_a1MeashoPrefNRLayerSsbRsrp_a1ThresholdhoSsb}[3]</p>
    ...    <p name="a1TimeToTriggerhoSsbRsrp">ms40</p>
    ...    </item>
    ...    </list>
    ...    <list name="a1MeashoPrefNRLayerSsbRsrq">
    ...    <item>
    ...    <p name="a1HysteresisSsbRsrq">0</p>
    ...    <p name="a1ThresholdhoSsbRsrq">${IAF_a1MeashoPrefNRLayerSsbRsrp_a1ThresholdhoSsb}[3]</p>
    ...    <p name="a1TimeToTriggerhoSsbRsrq">ms40</p>
    ...    </item>
    ...    </list>
    ...    <list name="a1MeashoSsbRsrp">
    ...    <item>
    ...    <p name="a1HysteresishoSsbRsrp">0</p>
    ...    <p name="a1ThresholdhoSsbRsrp">${IAF_a1MeashoSsbRsrp_a1ThresholdhoSsb}[3]</p>
    ...    <p name="a1TimeToTriggerhoSsbRsrp">ms480</p>
    ...    </item>
    ...    </list>
    ...    <list name="a1MeashoSsbRsrq">
    ...    <item>
    ...    <p name="a1HysteresishoSsbRsrq">0</p>
    ...    <p name="a1ThresholdhoSsbRsrq">${IAF_a1MeashoSsbRsrp_a1ThresholdhoSsb}[3]</p>
    ...    <p name="a1TimeToTriggerhoSsbRsrq">ms480</p>
    ...    </item>
    ...    </list>
    ...    <list name="a2MeasRedirectSsbRsrp">
    ...    <item>
    ...    <p name="a2HysteresisRedirectSsbRsrp">0</p>
    ...    <p name="a2ThresholdRedirectSsbRsrp">${IAF_a2MeasRedirectSsbRsrp_a2ThresholdRedirectSsb}[3]</p>
    ...    <p name="a2TimeToTriggerRedirectSsbRsrp">ms480</p>
    ...    </item>
    ...    </list>
    ...    <list name="a2MeasRedirectSsbRsrq">
    ...    <item>
    ...    <p name="a2HysteresisRedirectSsbRsrq">0</p>
    ...    <p name="a2ThresholdRedirectSsbRsrq">${IAF_a2MeasRedirectSsbRsrp_a2ThresholdRedirectSsb}[3]</p>
    ...    <p name="a2TimeToTriggerRedirectSsbRsrq">ms480</p>
    ...    </item>
    ...    </list>
    ...    <list name="a2MeashoSsbRsrp">
    ...    <item>
    ...    <p name="a2HysteresishoSsbRsrp">0</p>
    ...    <p name="a2ThresholdhoSsbRsrp">${IAF_a2MeashoSsbRsrp_a2ThresholdhoSsb}[3]</p>
    ...    <p name="a2TimeToTriggerhoSsbRsrp">ms480</p>
    ...    </item>
    ...    </list>
    ...    <list name="a2MeashoSsbRsrq">
    ...    <item>
    ...    <p name="a2HysteresishoSsbRsrq">0</p>
    ...    <p name="a2ThresholdhoSsbRsrq">${IAF_a2MeashoSsbRsrp_a2ThresholdhoSsb}[3]</p>
    ...    <p name="a2TimeToTriggerhoSsbRsrq">ms480</p>
    ...    </item>
    ...    </list>
    ...    <list name="a3MeasSsbRsrp">
    ...    <item>
    ...    <p name="a3HysteresisSsbRsrp">0</p>
    ...    <p name="a3OffsetSsbRsrp">${IAF_a3MeasSsbRsrp_a3OffsetSsb}[3]</p>
    ...    <p name="a3TimeToTriggerSsbRsrp">ms320</p>
    ...    </item>
    ...    </list>
    ...    <list name="a3MeasSsbRsrq">
    ...    <item>
    ...    <p name="a3HysteresisSsbRsrq">0</p>
    ...    <p name="a3OffsetSsbRsrq">${IAF_a3MeasSsbRsrp_a3OffsetSsb}[3]</p>
    ...    <p name="a3TimeToTriggerSsbRsrq">ms320</p>
    ...    </item>
    ...    </list>
    ...    <list name="a5MeasSsbRsrp">
    ...    <item>
    ...    <p name="a5HysteresisSsbRsrp">0</p>
    ...    <p name="a5Threshold1SsbRsrp">${IAF_a5MeasSsbRsrp_a5Threshold1Ssb}[3]</p>
    ...    <p name="a5Threshold2SsbRsrp">${IAF_a5MeasSsbRsrp_a5Threshold2Ssb}[3]</p>
    ...    <p name="a5TimeToTriggerSsbRsrp">ms320</p>
    ...    </item>
    ...    </list>
    ...    <list name="a5MeasSsbRsrq">
    ...    <item>
    ...    <p name="a5HysteresisSsbRsrq">0</p>
    ...    <p name="a5Threshold1SsbRsrq">${IAF_a5MeasSsbRsrp_a5Threshold1Ssb}[3]</p>
    ...    <p name="a5Threshold2SsbRsrq">${IAF_a5MeasSsbRsrp_a5Threshold2Ssb}[3]</p>
    ...    <p name="a5TimeToTriggerSsbRsrq">ms320</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRMEASPR_IAF-4
    [Documentation]    [PRIVATE]    create NRMEASPR_IAF-4 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-4
    Create single NRMEASPR_IAF    NRMEASPR_IAF_id=4


Create single NRMEASPR_IRF
    [Documentation]    [PRIVATE]    create NRMEASPR_IRF object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${NRMEASPR_IRF_id}
    Log To Console    Building object ${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IRF-${NRMEASPR_IRF_id}
    ${new_MO}   Set Variable   <managedObject class="NRMEASPR_IRF" distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IRF-${NRMEASPR_IRF_id}"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="b2Threshold1hoRsrp">${IRF_b2Threshold1hoRsrp_b2Threshold1hoRsrq}[${NRMEASPR_IRF_id}]</p>
    ...    <p name="b2Threshold1hoRsrq">${IRF_b2Threshold1hoRsrp_b2Threshold1hoRsrq}[${NRMEASPR_IRF_id}]</p>
    ...    <list name="eutraB2MeashoRsrp">
    ...    <item>
    ...    <p name="b2HysteresishoRsrp">0</p>
    ...    <p name="b2Threshold2hoRsrp">${IRF_b2Threshold2hoRsrp_b2Threshold2hoRsrq}[${NRMEASPR_IRF_id}]</p>
    ...    <p name="b2TimeToTriggerhoRsrp">ms480</p>
    ...    </item>
    ...    </list>
    ...    <list name="eutraB2MeashoRsrq">
    ...    <item>
    ...    <p name="b2HysteresishoRsrq">0</p>
    ...    <p name="b2Threshold2hoRsrq">${IRF_b2Threshold2hoRsrp_b2Threshold2hoRsrq}[${NRMEASPR_IRF_id}]</p>
    ...    <p name="b2TimeToTriggerhoRsrq">ms480</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRMEASPR_IRF
    [Documentation]    [PRIVATE]    create NRMEASPR_IRF object in SCF
    ...       :Autor: Sylvia Schneider
    FOR    ${id}   IN  1  2
       Create single NRMEASPR_IRF    NRMEASPR_IRF_id=${id}
    END


Create NRMEASPR_IRF-3
    [Documentation]    [PRIVATE]    create NRMEASPR_IRF-3 object in SCF
    ...       :Autor: Sylvia Schneider
    Create single NRMEASPR_IRF    NRMEASPR_IRF_id=3


Create NRMEASPR_MA_SA-1
    [Documentation]    [PRIVATE]    create single NRMEASPR_MA_SA object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-1
    ${new_MO}   Set Variable   <managedObject class="NRMEASPR_MA_SA" distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-1"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="nrMeasPrIafDN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1</p>
    ...    <list name="nrMeasPrIefList">
    ...    <item>
    ...    <p name="nrMeasPrIefDN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IEF-1</p>
    ...    <p name="ssbFrequency01">633408</p>
    ...    </item>
    ...    </list>
    ...    <p name="nrMeasPrIrfDN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IRF-1</p>
    ...    <list name="pcCapabilityList">
    ...    <item>
    ...    <p name="freqBandIndicatorNR">78</p>
    ...    <p name="uePowerClass">ue-PowerClass2</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRMEASPR_MA_SA-2
    [Documentation]    [PRIVATE]    create single NRMEASPR_MA_SA object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-2
    ${new_MO}   Set Variable   <managedObject class="NRMEASPR_MA_SA" distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-2"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="nrMeasPrIafDN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-2</p>
    ...    <list name="nrMeasPrIefList">
    ...    <item>
    ...    <p name="nrMeasPrIefDN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IEF-2</p>
    ...    <p name="ssbFrequency01">633408</p>
    ...    </item>
    ...    </list>
    ...    <p name="nrMeasPrIrfDN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IRF-2</p>
    ...    <list name="fiveqiValueList">
    ...    <p>1</p>
    ...    </list>
    ...    <list name="pcCapabilityList">
    ...    <item>
    ...    <p name="freqBandIndicatorNR">78</p>
    ...    <p name="uePowerClass">ue-PowerClass2</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRMEASPR_MA_SA-3
    [Documentation]    [PRIVATE]    create single NRMEASPR_MA_SA object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-3
    ${new_MO}   Set Variable   <managedObject class="NRMEASPR_MA_SA" distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-3"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="nrMeasPrIafDN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-3</p>
    ...    <list name="nrMeasPrIefList">
    ...    <item>
    ...    <p name="nrMeasPrIefDN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IEF-3</p>
    ...    <p name="ssbFrequency01">633408</p>
    ...    </item>
    ...    </list>
    ...    <p name="nrMeasPrIrfDN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IRF-3</p>
    ...    <list name="fiveqiValueList">
    ...    <p>1</p>
    ...    </list>
    ...    <list name="nrCaClassDNList">
    ...    <p>${bts_distName}/NRMEAS_PROFILE-1/NRCACLASS-24</p>
    ...    </list>
    ...    <list name="pcCapabilityList">
    ...    <item>
    ...    <p name="freqBandIndicatorNR">78</p>
    ...    <p name="uePowerClass">ue-PowerClass2</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRMEASPR_MA_SA-4
    [Documentation]    [PRIVATE]    create single NRMEASPR_MA_SA object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-4
    ${new_MO}   Set Variable   <managedObject class="NRMEASPR_MA_SA" distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-4"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <list name="fiveqiValueList">
    ...    <p>1</p>
    ...    </list>
    ...    <list name="pcCapabilityList">
    ...    <item>
    ...    <p name="freqBandIndicatorNR">78</p>
    ...    <p name="uePowerClass">ue-PowerClass7</p>
    ...    </item>
    ...    </list>
    ...    <p name="nrMeasPrIafDN">${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-4</p>
    ...    <p name="redCap">1RX</p>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRCACLASS-24
    [Documentation]    [PRIVATE]    create NRCACLASS-24 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMEAS_PROFILE-1/NRCACLASS-24
    ${new_MO}   Set Variable   <managedObject class="NRCACLASS" distName="${bts_distName}/NRMEAS_PROFILE-1/NRCACLASS-24"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <list name="caBandList">
    ...    <p>41</p>
    ...    <p>78</p>
    ...    </list>
    ...    <list name="excludedBandList">
    ...    <p>28</p>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRMOPR_NSA
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


Create NRMOPR_SA
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


Create NRMOPRMA_NSA
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


Create NRMOPRMA_SA
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
    ${new_MO}   catenate       SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="mcc">311</p>
    ...    <p name="mnc">388</p>
    ...    <p name="mncLength">3</p>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Recreate NRREDRT
    [Documentation]    [PRIVATE]    Recreate NRREDRT object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    re-create object ${bts_distName}/NRCELL-1/NRREDRT-0
    ${new_MO}   Set Variable   <managedObject class="NRREDRT" distName="${bts_distName}/NRCELL-1/NRREDRT-0"
    ${new_MO}   catenate       SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="redirFreqNr">633364</p>
    ...    <p name="redirPrio">1</p>
    ...    <p name="redirPrioBadUlRadio">1</p>
    ...    <p name="redirRat">nr</p>
    ...    <p name="redirSsbScs">15KHz</p>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create SNSSAI
    [Documentation]    [PRIVATE]    create SNSSAI object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/SNSSAI-2
    ${new_MO}   Set Variable   <managedObject class="com.nokia.srbts.nrbts:SNSSAI" distName="${bts_distName}/SNSSAI-2"
    ${new_MO}   catenate       SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
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
    ${new_MO}   catenate       SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
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
    ${new_MO}   catenate       SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="cPlaneIpAddr">10.0.1.6</p>
    ...    <p name="cPlaneIpAddrCtrl">oamControlled</p>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData
