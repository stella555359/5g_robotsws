*** Settings ***
Documentation   This is a keyword file for CB008699, part commissioning, new objects
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
           ...    <p name="gNbIdLength">22</p>
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
           ...    <p name="gNbIdLength">22</p>
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


Create FR2-NRADJNRCELL
    [Documentation]    [PRIVATE]    create NRADJNRCELL object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRADJNRCELL-1
    ${NRADJNRCELL}    Set Variable  <managedObject class="NRADJNRCELL" distName="${bts_distName}/NRADJNRCELL-1"
    ${NRADJNRCELL}   Catenate     SEPARATOR=${SPACE}   ${NRADJNRCELL}    version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="cellDepType">SA</p>
    ...    <p name="cellReservedForOperatorUse">notReserved</p>
    ...    <p name="fiveGsTac">0</p>
    ...    <p name="freqBandIndicatorNR">257</p>
    ...    <p name="gNbId">3</p>
    ...    <p name="gNbIdLength">22</p>
    ...    <p name="lcrId">1</p>
    ...    <p name="nrarfcn">2077819</p>
    ...    <p name="physCellId">48</p>
    ...    <p name="ssbFrequency">2077723</p>
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


Create NRADJNRCELL-2
    [Documentation]    [PRIVATE]    create NRADJNRCELL object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRADJNRCELL-2
    ${NRADJNRCELL}    Set Variable  <managedObject class="NRADJNRCELL" distName="${bts_distName}/NRADJNRCELL-2"
    ${NRADJNRCELL}   Catenate     SEPARATOR=${SPACE}   ${NRADJNRCELL}    version="${SCF.version}" operation="create">
    FOR     ${line}   IN
           ...    <p name="cellDepType">SA</p>
           ...    <p name="cellReservedForOperatorUse">notReserved</p>
           ...    <p name="fiveGsTac">200</p>
           ...    <p name="freqBandIndicatorNR">78</p>
           ...    <p name="gNbId">3</p>
           ...    <p name="gNbIdLength">22</p>
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

Create NRHOIF
    [Documentation]    [PRIVATE]    create NRHOIF object in SCF
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
           ...    <p name="a5MeasEnabled">none</p>
           ...    <p name="cellDepType">SA</p>
           ...        <p name="deriveSsbIndexFromCell">true</p>
           ...    <p name="freqBandIndicatorNR">78</p>
           ...    <p name="ifhoSsbScs">30 KHz</p>
           ...    <p name="ifhoSsbSmtcDuration">sf4</p>
           ...    <p name="ifhoSsbSmtcPeriodicity">sf40</p>
           ...    <p name="numberOfTransmittedSsBlocks">1 beam</p>
           ...    <p name="ssBurstSetPeriod">20</p>
           ...    <p name="ssbFrequency">635676</p>
           ...    <list name="a3MeasSsbRsrp">
           ...    <item>
           ...    <p name="a3HysteresisSsbRsrp">0</p>
           ...    <p name="a3OffsetSsbRsrp">15</p>
           ...    <p name="a3TimeToTriggerSsbRsrp">ms480</p>
           ...    </item>
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
    ...    <p name="actCplaneCounters">true</p>
    ...    <p name="actUPlaneGroup1Counters">true</p>
    ...    <p name="actUPlaneGroup2Counters">true</p>
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
    ...    <p name="actCplaneCounters">true</p>
    ...    <p name="actUPlaneGroup1Counters">true</p>
    ...    <p name="actUPlaneGroup2Counters">true</p>
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


Create FR2-NRREL
    [Documentation]    [PRIVATE]    Create FR2-NRREL
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRCELL-1/NRREL-1
    ${new_MO}   Set Variable  <managedObject class="NRREL" distName="${bts_distName}/NRCELL-1/NRREL-1"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}    version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="cellIndividualSsbRsrpOffset">-2dB</p>
    ...    <p name="cellIndividualSsbRsrqOffset">-2dB</p>
    ...    <p name="gNbId">3</p>
    ...    <p name="gNbIdLength">22</p>
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


Create FR2-NRMEAS_PROFILE
    [Documentation]    [PRIVATE]    Create FR2-NRMEAS_PROFILE
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMEAS_PROFILE-1
    ${new_MO}   Set Variable  <managedObject class="NRMEAS_PROFILE" distName="${bts_distName}/NRMEAS_PROFILE-1"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}    version="${SCF.version}" operation="create"/>
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create FR2-NRMEASPR_IAF
    [Documentation]    [PRIVATE]    Create FR2-NRMEASPR_IAF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1
    ${new_MO}   Set Variable  <managedObject class="NRMEASPR_IAF" distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}    version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <list name="a1MeashoPrefNRLayerSsbRsrp">
    ...    <item>
    ...    <p name="a1HysteresisSsbRsrp">0</p>
    ...    <p name="a1ThresholdhoSsbRsrp">88</p>
    ...    <p name="a1TimeToTriggerhoSsbRsrp">ms40</p>
    ...    </item>
    ...    </list>
    ...    <list name="a1MeashoPrefNRLayerSsbRsrq">
    ...    <item>
    ...    <p name="a1HysteresisSsbRsrq">0</p>
    ...    <p name="a1ThresholdhoSsbRsrq">88</p>
    ...    <p name="a1TimeToTriggerhoSsbRsrq">ms40</p>
    ...    </item>
    ...    </list>
    ...    <list name="a1MeashoSsbRsrp">
    ...    <item>
    ...    <p name="a1HysteresishoSsbRsrp">0</p>
    ...    <p name="a1ThresholdhoSsbRsrp">96</p>
    ...    <p name="a1TimeToTriggerhoSsbRsrp">ms480</p>
    ...    </item>
    ...    </list>
    ...    <list name="a1MeashoSsbRsrq">
    ...    <item>
    ...    <p name="a1HysteresishoSsbRsrq">0</p>
    ...    <p name="a1ThresholdhoSsbRsrq">96</p>
    ...    <p name="a1TimeToTriggerhoSsbRsrq">ms480</p>
    ...    </item>
    ...    </list>
    ...    <list name="a2MeasRedirectSsbRsrp">
    ...    <item>
    ...    <p name="a2HysteresisRedirectSsbRsrp">0</p>
    ...    <p name="a2ThresholdRedirectSsbRsrp">84</p>
    ...    <p name="a2TimeToTriggerRedirectSsbRsrp">ms480</p>
    ...    </item>
    ...    </list>
    ...    <list name="a2MeasRedirectSsbRsrq">
    ...    <item>
    ...    <p name="a2HysteresisRedirectSsbRsrq">0</p>
    ...    <p name="a2ThresholdRedirectSsbRsrq">84</p>
    ...    <p name="a2TimeToTriggerRedirectSsbRsrq">ms480</p>
    ...    </item>
    ...    </list>
    ...    <list name="a2MeasReleaseSsbRsrp">
    ...    <item>
    ...    <p name="a2HysteresisReleaseSsbRsrp">0</p>
    ...    <p name="a2ThresholdReleaseSsbRsrp">80</p>
    ...    <p name="a2TimeToTriggerReleaseSsbRsrp">ms480</p>
    ...    </item>
    ...    </list>
    ...    <list name="a2MeasReleaseSsbRsrq">
    ...    <item>
    ...    <p name="a2HysteresisReleaseSsbRsrq">0</p>
    ...    <p name="a2ThresholdReleaseSsbRsrq">80</p>
    ...    <p name="a2TimeToTriggerReleaseSsbRsrq">ms480</p>
    ...    </item>
    ...    </list>
    ...    <list name="a2MeashoSsbRsrp">
    ...    <item>
    ...    <p name="a2HysteresishoSsbRsrp">0</p>
    ...    <p name="a2ThresholdhoSsbRsrp">92</p>
    ...    <p name="a2TimeToTriggerhoSsbRsrp">ms480</p>
    ...    </item>
    ...    </list>
    ...    <list name="a2MeashoSsbRsrq">
    ...    <item>
    ...    <p name="a2HysteresishoSsbRsrq">0</p>
    ...    <p name="a2ThresholdhoSsbRsrq">92</p>
    ...    <p name="a2TimeToTriggerhoSsbRsrq">ms480</p>
    ...    </item>
    ...    </list>
    ...    <list name="a3MeasSsbRsrp">
    ...    <item>
    ...    <p name="a3HysteresisSsbRsrp">0</p>
    ...    <p name="a3OffsetSsbRsrp">4</p>
    ...    <p name="a3TimeToTriggerSsbRsrp">ms320</p>
    ...    </item>
    ...    </list>
    ...    <list name="a3MeasSsbRsrq">
    ...    <item>
    ...    <p name="a3HysteresisSsbRsrq">0</p>
    ...    <p name="a3OffsetSsbRsrq">4</p>
    ...    <p name="a3TimeToTriggerSsbRsrq">ms320</p>
    ...    </item>
    ...    </list>
    ...    <list name="a5MeasSsbRsrp">
    ...    <item>
    ...    <p name="a5HysteresisSsbRsrp">0</p>
    ...    <p name="a5Threshold1SsbRsrp">78</p>
    ...    <p name="a5Threshold2SsbRsrp">83</p>
    ...    <p name="a5TimeToTriggerSsbRsrp">ms320</p>
    ...    </item>
    ...    </list>
    ...    <list name="a5MeasSsbRsrq">
    ...    <item>
    ...    <p name="a5HysteresisSsbRsrq">0</p>
    ...    <p name="a5Threshold1SsbRsrq">78</p>
    ...    <p name="a5Threshold2SsbRsrq">83</p>
    ...    <p name="a5TimeToTriggerSsbRsrq">ms320</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create FR2-NRMEASPR_MA_SA
    [Documentation]    [PRIVATE]    Create FR2-NRMEASPR_MA_SA
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-1
    ${new_MO}   Set Variable  <managedObject class="NRMEASPR_MA_SA" distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-1"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}    version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="nrMeasPrIafDN">MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_IAF-1</p>
    ...    <p name="rfspIndex">1</p>
    ...    <p name="rfspIndexLast">100</p>
    ...    <list name="pcCapabilityList">
    ...    <item>
    ...    <p name="freqBandIndicatorNR">257</p>
    ...    <p name="uePowerClass">ue-PowerClass2</p>
    ...    </item>
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


Add List a3MeasSsbRsrp
    [Documentation]    [PRIVATE]    create List a3MeasSsbRsrp in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building list a3MeasSsbRsrp for object ${bts_distName}/NRCELL-1
    ${a3MeasSsbRsrp}    Set Variable    <list name="a3MeasSsbRsrp">
    FOR     ${line}   IN
           ...    <item>
           ...    <p name="a3HysteresisSsbRsrp">0</p>
           ...    <p name="a3OffsetSsbRsrp">15</p>
           ...    <p name="a3TimeToTriggerSsbRsrp">ms480</p>
           ...    </item>
           ...    </list>
           ${a3MeasSsbRsrp}   Catenate     SEPARATOR=\n         ${a3MeasSsbRsrp}   ${line}
    END
    Add Element     ${scf_xml}     ${a3MeasSsbRsrp}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]


Add RF2-Lists a3MeasSsbRsrp a3MeasSsbRsrq a5MeasSsbRsrp a5MeasSsbRsrq measPrMaSAList
    [Documentation]    [PRIVATE]    create List a3MeasSsbRsrp in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building list a3MeasSsbRsrp for object ${bts_distName}/NRCELL-1
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


    Log To Console    Building list a5MeasSsbRsrp for object ${bts_distName}/NRCELL-1
    ${new_list}    Set Variable    <list name="a5MeasSsbRsrp">
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
    Add Element     ${scf_xml}     ${new_list}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]


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


    Log To Console    Building list measPrMaSAList for object ${bts_distName}/NRCELL-1
    ${new_list}    Set Variable    <list name="measPrMaSAList">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="measPrPriority">8</p>
    ...    <p name="nrMeasPrMaSADN">MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-1</p>
    ...    </item>
    ...    </list>
          ${new_list}   Catenate     SEPARATOR=\n         ${new_list}   ${line}
    END
    Add Element     ${scf_xml}     ${new_list}           xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]
