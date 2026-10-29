*** Settings ***
Documentation   This is a keyword file for CB008146-E, part commissioning objects
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Keywords ***


Create New Objects
    [Documentation]    [PRIVATE]    create objects in SCF
    ...       :Autor: Sylvia Schneider

   Update redirPrio And redirPrioBadUlRadio

    FOR   ${obj}    IN
    ...   NRADJGNB
    ...   NRADJNRCELL
    ...   NRHOIF
    ...   NRREDRT-5 FDD
    ...   NRREDRT-0
    ...   NRREL
    ...   NRMEASCFG_IF
    ...   NRMOPRMA_SA-1
    ...   NRMOPRMA_SA-2
    ...   NRMOPRMA_SA-3
    ...   NRMOPRMA_SA-4
    ...   NRMOPRMA_SA-5
    ...   NRMORED-1
    ...   NRMORED-2
    ...   NRMOPR_SA-2
    ...   NRMOPR_SA-3
    ...   NRMOPR_SA-32
    ...   NRMOPR_SA-4
    ...   NRMOPR_SA-5
    ...   XNLINK
    ...   5QI-6
    ...   NRDRB-15
    ...   NRDRB_RLC_UM
    ...   NRDRB_MAC-3
    ...   NRDRB_PDCP-2
       Run Keyword    Create ${obj}
    END
    Update NRMOPR_SA-1
    Update NRMOPR_NSA



Create 5QI-6
    [Documentation]    [PRIVATE]    create 5QI-6 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRDRB_5QI-6
    ${5QI}   Set Variable   <managedObject class="NRDRB_5QI" distName="${bts_distName}/NRDRB_5QI-6"
    ${5QI}   Catenate     SEPARATOR=${SPACE}   ${5QI}   version="${version_SCF}" operation="create">
    FOR     ${line}   IN
    ...    <p name="dataForwarding">IRATDataFwd</p>
    ...    <p name="nrDrbDN">${bts_distName}/NRDRB-15</p>
    ...    <list name="fiveqiValueList">
    ...    <p>1</p>
    ...    </list>
    ...    </managedObject>
           ${5QI}   Catenate     SEPARATOR=\n         ${5QI}   ${line}
    END
    Add Element     ${scf_xml}     ${5QI}           xpath=.//cmData


Create NRDRB-15
    [Documentation]    [PRIVATE]    create NRDRB-15 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRDRB-15
    ${NRDRB}   Set Variable   <managedObject class="NRDRB" distName="${bts_distName}/NRDRB-15"
    ${NRDRB}   Catenate     SEPARATOR=${SPACE}   ${NRDRB}   version="${version_SCF}" operation="create">
    FOR     ${line}   IN
    ...    <p name="actDddsReduction">false</p>
    ...    <p name="actDlTxResumeOnPdcpStatRep">false</p>
    ...    <p name="actLostPduFastRetx">false</p>
    ...    <p name="actOptDataFlowRateEst">false</p>
    ...    <p name="allowedPdcchPowerBoostALDueCce">none</p>
    ...    <p name="allowedPdcchPowerBoostALDueCfg">None</p>
    ...    <p name="caPduReSendingDelayMargin">2</p>
    ...    <p name="discardTimer">100ms</p>
    ...    <p name="dlAllowMinDelayLinkXxCalib">false</p>
    ...    <p name="dlFlowControlAlgo">none</p>
    ...    <p name="dscp">46</p>
    ...    <p name="durationThresDiscardDl">40</p>
    ...    <p name="durationThresDiscardDlMacSdu">40</p>
    ...    <p name="durationThresDiscardDlPdcpPdu5GLeg">40</p>
    ...    <p name="durationThresDiscardDlPdcpPduLteLeg">40</p>
    ...    <p name="durationThresDiscardUl">20</p>
    ...    <p name="endMarkerTimer">2000</p>
    ...    <p name="maxDataRateGbrDl">1000</p>
    ...    <p name="maxDataRateGbrUl">1000</p>
    ...    <p name="maxDddsPeriodCpuOvld">40</p>
    ...    <p name="maxForwardTimeLimitXx">50</p>
    ...    <p name="maxRlcQueueingDelayGbr">20</p>
    ...    <p name="maxTransferDelayGbr">20</p>
    ...    <p name="minForwardTputXx">100</p>
    ...    <p name="nrDrbMacDN">${bts_distName}/NRDRB_MAC-3</p>
    ...    <p name="nrDrbPdcpDN">${bts_distName}/NRDRB_PDCP-2</p>
    ...    <p name="nrDrbRlcUmDN">${bts_distName}/NRDRB_RLC_UM-1</p>
    ...    <p name="nrDrxDN">${bts_distName}/NRDRX-2</p>
    ...    <p name="numSduDiscard">1</p>
    ...    <p name="queuingDelayDiscardStart">5</p>
    ...    <p name="queuingDelayDiscarding">Disabled</p>
    ...    <p name="queuingDelaySduDiscardThreshold">750</p>
    ...    <p name="resType">GBR</p>
    ...    <p name="rlcMode">RLC_UM</p>
    ...    <p name="rlcPduDelayThCa">30</p>
    ...    <p name="schedulWeight">1</p>
    ...    <p name="sduDiscardIntervalTmr">500</p>
    ...    <p name="srsStaticUeDoublePeriodicity">false</p>
    ...    <p name="volThresDiscardDl">8000</p>
    ...    <p name="volThresDiscardDlMacSdu">8000</p>
    ...    <p name="volThresDiscardDlPdcpPdu5GLeg">8000</p>
    ...    <p name="volThresDiscardDlPdcpPduLteLeg">8000</p>
    ...    <p name="volThresDiscardUl">800</p>
    ...    <list name="cellAggrLevel">
    ...    <p>Not FR1 CA eligible</p>
    ...    </list>
    ...    </managedObject>
           ${NRDRB}   Catenate     SEPARATOR=\n         ${NRDRB}   ${line}
    END
    Add Element     ${scf_xml}     ${NRDRB}           xpath=.//cmData


Create NRDRB_RLC_UM
    [Documentation]    [PRIVATE]    create NRDRB_RLC_UM object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRDRB_RLC_UM-1
    ${NRDRB_RLC_UM}   Set Variable   <managedObject class="NRDRB_RLC_UM" distName="${bts_distName}/NRDRB_RLC_UM-1"
    ${NRDRB_RLC_UM}   Catenate     SEPARATOR=${SPACE}   ${NRDRB_RLC_UM}   version="${version_SCF}" operation="create">
    FOR     ${line}   IN
    ...    <p name="dlTReassemblyUm">ms50</p>
    ...    <p name="rlcUMDrbSNLength">rlcUm12bitSN</p>
    ...    <p name="ulTReassemblyUm">ms50</p>
    ...    </managedObject>
           ${NRDRB_RLC_UM}   Catenate     SEPARATOR=\n         ${NRDRB_RLC_UM}   ${line}
    END
    Add Element     ${scf_xml}     ${NRDRB_RLC_UM}           xpath=.//cmData


Create NRDRB_MAC-3
    [Documentation]    [PRIVATE]    create NRDRB_MAC-3 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRDRB_MAC-3
    ${NRDRB_MAC-3}   Set Variable   <managedObject class="NRDRB_MAC" distName="${bts_distName}/NRDRB_MAC-3"
    ${NRDRB_MAC-3}   Catenate     SEPARATOR=${SPACE}   ${NRDRB_MAC-3}   version="${version_SCF}" operation="create">
    FOR     ${line}   IN
    ...    <p name="lcgid">4</p>
    ...    <p name="prioritisedBitRate">16kBps</p>
    ...    <p name="schedulBSD">100ms</p>
    ...    <p name="schedulPrio">5</p>
    ...    </managedObject>
           ${NRDRB_MAC-3}   Catenate     SEPARATOR=\n         ${NRDRB_MAC-3}   ${line}
    END
    Add Element     ${scf_xml}     ${NRDRB_MAC-3}           xpath=.//cmData


Create NRDRB_PDCP-2
    [Documentation]    [PRIVATE]    create NRDRB_PDCP-2 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRDRB_PDCP-2
    ${NRDRB_PDCP}   Set Variable   <managedObject class="NRDRB_PDCP" distName="${bts_distName}/NRDRB_PDCP-2"
    ${NRDRB_PDCP}   Catenate     SEPARATOR=${SPACE}   ${NRDRB_PDCP}   version="${version_SCF}" operation="create">
    FOR     ${line}   IN
    ...    <p name="cuFlowControlProfId">1</p>
    ...    <p name="pdcpBufDiscardEnabled">false</p>
    ...    <p name="pdcpBufDiscardThreshold">20000</p>
    ...    <p name="pdcpDelayThreshRetxMode">disabled</p>
    ...    <p name="tReorderingDl">ms300</p>
    ...    <p name="tReorderingUl">ms100</p>
    ...    <p name="xxFlowControlProfForCuIdx">1</p>
    ...    </managedObject>
           ${NRDRB_PDCP}   Catenate     SEPARATOR=\n         ${NRDRB_PDCP}   ${line}
    END
    Add Element     ${scf_xml}     ${NRDRB_PDCP}           xpath=.//cmData


Create NRREL
    [Documentation]    [PRIVATE]    create NRREL object in SCF
    ...       :Autor: Sylvia Schneider
    FOR    ${lcrId}   IN   1    2    3    4
       Create Single NRREL   ${lcrId}
    END


Create single NRREL
    [Documentation]    [PRIVATE]    create NRREL object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${lcrId}
    Log To Console    \nBuilding object ${bts_distName}/NRCELL-10/NRREL-${lcrId}
    ${NRREL}   Set Variable   <managedObject class="NRREL" distName="${bts_distName}/NRCELL-10/NRREL-${lcrId}"
    ${NRREL}   Catenate     SEPARATOR=${SPACE}   ${NRREL}   version="${version_SCF}" operation="create">
    FOR     ${line}   IN
           ...    <p name="cellIndividualSsbRsrpOffset">-2dB</p>
           ...    <p name="cellIndividualSsbRsrqOffset">-2dB</p>
           ...    <p name="gNbId">38</p>
           ...    <p name="gNbIdLength">22</p>
           ...    <p name="handoverAllowedSA">allowed</p>
           ...    <p name="handoverAllowedSARedCap">forbidden</p>
           ...    <p name="isRplCellForPSCell">false</p>
           ...    <p name="lcrId">${lcrId}</p>
           ...    <p name="nrDcAllowed">false</p>
           ...    <p name="removeNotAllowed">false</p>
           ...    <list name="gnbPlmn">
           ...    <item>
           ...    <p name="mcc">${mcc_SCF}</p>
           ...    <p name="mnc">${mnc_SCF}</p>
           ...    <p name="mncLength">3</p>
           ...    </item>
           ...    </list>
           ...    </managedObject>
           ${NRREL}   Catenate     SEPARATOR=\n         ${NRREL}   ${line}
    END
    Add Element     ${scf_xml}     ${NRREL}           xpath=.//cmData


Create NRADJGNB
    [Documentation]    [PRIVATE]    create NRADJGNB object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRADJGNB-1
    ${NRADJGNB}    Set Variable  <managedObject class="NRADJGNB" distName="${bts_distName}/NRADJGNB-1"
    ${NRADJGNB}   Catenate     SEPARATOR=${SPACE}   ${NRADJGNB}    version="${version_SCF}" operation="create">
    FOR     ${line}   IN
           ...    <p name="administrativeState">Unlocked</p>
           ...    <p name="gNbIdLength">22</p>
           ...    <p name="gNodeBId">38</p>
           ...    <p name="gNodeBIdCtrl">oamControlled</p>
           ...    <p name="xnLinkRef">2</p>
           ...    <list name="gnbPlmn">
           ...    <item>
           ...    <p name="mcc">${mcc_SCF}</p>
           ...    <p name="mnc">${mnc_SCF}</p>
           ...    <p name="mncLength">3</p>
           ...    </item>
           ...    </list>
           ...    </managedObject>
           ${NRADJGNB}   Catenate     SEPARATOR=\n         ${NRADJGNB}   ${line}
    END
    Add Element     ${scf_xml}     ${NRADJGNB}           xpath=.//cmData


Create NRADJNRCELL
    [Documentation]    [PRIVATE]    create NRADJNRCELL object in SCF
    ...       :Autor: Sylvia Schneider

    FOR    ${object_instance}   ${freqBandIndicatorNR}   ${lcrId}    ${nrarfcn}    ${physCellId}   ${ssbFrequency}   IN
    ...    2                    71                       1           126400        48              125290
    ...    3                    71                       2           128000        46              127970
    ...    4                    5                        3           176500        47              176410
    ...    5                    257                      4           2071591       49              2071387
       Create Single NRADJNRCELL   ${object_instance}   ${freqBandIndicatorNR}   ${lcrId}    ${nrarfcn}    ${physCellId}   ${ssbFrequency}
    END


Create Single NRADJNRCELL
    [Documentation]    [PRIVATE]    create NRADJNRCELL object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${object_instance}   ${freqBandIndicatorNR}   ${lcrId}    ${nrarfcn}    ${physCellId}  ${ssbFrequency}
    Log To Console    Building object ${bts_distName}/NRADJNRCELL-${object_instance}
    ${NRADJNRCELL}    Set Variable   <managedObject class="NRADJNRCELL" distName="${bts_distName}/NRADJNRCELL-${object_instance}"
    ${NRADJNRCELL}   Catenate     SEPARATOR=${SPACE}   ${NRADJNRCELL}    version="${version_SCF}" operation="create">
    FOR     ${line}   IN
           ...    <p name="cellDepType">SA</p>
           ...    <p name="cellReservedForOperatorUse">notReserved</p>
           ...    <p name="fiveGsTac">${fiveGsTac_SCF}</p>
           ...    <p name="freqBandIndicatorNR">${freqBandIndicatorNR}</p>
           ...    <p name="gNbId">38</p>
           ...    <p name="gNbIdLength">22</p>
           ...    <p name="lcrId">${lcrId}</p>
           ...    <p name="nrarfcn">${nrarfcn}</p>
           ...    <p name="physCellId">${physCellId}</p>
           ...    <p name="ssbFrequency">${ssbFrequency}</p>
           ...    <list name="gnbPlmn">
           ...    <item>
           ...    <p name="mcc">${mcc_SCF}</p>
           ...    <p name="mnc">${mnc_SCF}</p>
           ...    <p name="mncLength">${mnclenght_SCF}</p>
           ...    </item>
           ...    </list>
           ...    </managedObject>
           ${NRADJNRCELL}   Catenate     SEPARATOR=\n         ${NRADJNRCELL}   ${line}
    END
    Add Element     ${scf_xml}     ${NRADJNRCELL}           xpath=.//cmData


Create NRHOIF
    [Documentation]    [PRIVATE]    create NRHOIF object in SCF
    ...       :Autor: Sylvia Schneider

    FOR  ${inst}  ${freqBandIndNR}  ${ifhoSsbScs}  ${scs}  ${ssbFrequency}  ${a3HysteresisSsbRsrp}  ${a3OffsetSsbRsrp}  ${a3TimeToTriggerSsbRsrp}  IN
    ...    4      71                15KHz          15 KHz    127970             1                         10                   ms0
    ...    5      5                 15KHz          15 KHz    176410             0                         3                    ms480
    ...    6      257               240 KHz        120 KHz   2071387            1                         10                   ms0
       Create Single NRHOIF
       ...   ${inst}  ${freqBandIndNR}  ${ifhoSsbScs}  ${scs}  ${ssbFrequency}  ${a3HysteresisSsbRsrp}  ${a3OffsetSsbRsrp}  ${a3TimeToTriggerSsbRsrp}
    END


Create Single NRHOIF
    [Documentation]    [PRIVATE]    create NRHOIF object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]  ${inst}  ${freqBandIndNR}  ${ifhoSsbScs}  ${scs}  ${ssbFrequency}
    ...          ${a3HysteresisSsbRsrp}  ${a3OffsetSsbRsrp}  ${a3TimeToTriggerSsbRsrp}
    Log To Console    Building object ${bts_distName}/NRCELL-10/NRHOIF-${inst}
    ${NRHOIF}    Set Variable   <managedObject class="NRHOIF" distName="${bts_distName}/NRCELL-10/NRHOIF-${inst}"
    ${NRHOIF}   Catenate     SEPARATOR=${SPACE}   ${NRHOIF}    version="${version_SCF}" operation="create">
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
           ...    <p name="freqBandIndicatorNR">${freqBandIndNR}</p>
           ...    <p name="ifhoSsbScs">${ifhoSsbScs}</p>
           ...    <p name="ifhoSsbSmtcDuration">sf5</p>
           ...    <p name="ifhoSsbSmtcPeriodicity">sf20</p>
           ...    <p name="numberOfTransmittedSsBlocks">1 beam</p>
           ...    <p name="scs">${scs}</p>
           ...    <p name="ssBurstSetPeriod">10</p>
           ...    <p name="ssbFrequency">${ssbFrequency}</p>
           ...    <list name="a3MeasSsbRsrp">
           ...    <item>
           ...    <p name="a3HysteresisSsbRsrp">${a3HysteresisSsbRsrp}</p>
           ...    <p name="a3HysteresisSsbRsrpVoNr">0</p>
           ...    <p name="a3OffsetSsbRsrp">${a3OffsetSsbRsrp}</p>
           ...    <p name="a3OffsetSsbRsrpVoNr">15</p>
           ...    <p name="a3TimeToTriggerSsbRsrp">${a3TimeToTriggerSsbRsrp}</p>
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
           ${NRHOIF}   Catenate     SEPARATOR=\n         ${NRHOIF}   ${line}
    END
    Add Element     ${scf_xml}     ${NRHOIF}           xpath=.//cmData


Update redirPrio And redirPrioBadUlRadio
    [Documentation]    [PRIVATE]    Update redirPrio and redirPrioBadUlRadio
    ...       :Autor: Sylvia Schneider
    FOR   ${cell_id}   IN RANGE   7  13
      ${xpath_NRREDRT-3}  Set Variable   managedObject[@distName="${bts_distName}/NRCELL-${cell_id}/NRREDRT-3"]
      Set Element Text    ${scf_xml}  text=5  xpath=.//${xpath_NRREDRT-3}/p[@name="redirPrio"]
      Set Element Text    ${scf_xml}  text=5  xpath=.//${xpath_NRREDRT-3}/p[@name="redirPrioBadUlRadio"]
      ${xpath_NRREDRT-4}  Set Variable   managedObject[@distName="${bts_distName}/NRCELL-${cell_id}/NRREDRT-4"]
      Set Element Text    ${scf_xml}  text=6  xpath=.//${xpath_NRREDRT-4}/p[@name="redirPrio"]
      Set Element Text    ${scf_xml}  text=6  xpath=.//${xpath_NRREDRT-4}/p[@name="redirPrioBadUlRadio"]
    END

    FOR   ${cell_id}   IN RANGE   7  10
      ${xpath_NRREDRT-1}  Set Variable   managedObject[@distName="${bts_distName}/NRCELL-${cell_id}/NRREDRT-1"]
      Set Element Text    ${scf_xml}  text=3  xpath=.//${xpath_NRREDRT-1}/p[@name="redirPrio"]
      Set Element Text    ${scf_xml}  text=3  xpath=.//${xpath_NRREDRT-1}/p[@name="redirPrioBadUlRadio"]
      ${xpath_NRREDRT-2}  Set Variable   managedObject[@distName="${bts_distName}/NRCELL-${cell_id}/NRREDRT-2"]
      Set Element Text    ${scf_xml}  text=4  xpath=.//${xpath_NRREDRT-2}/p[@name="redirPrio"]
      Set Element Text    ${scf_xml}  text=4  xpath=.//${xpath_NRREDRT-2}/p[@name="redirPrioBadUlRadio"]
    END



Create Single NRREDRT-5 FDD
    [Documentation]    [PRIVATE]    create single NRREDRT-0 object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${cell_id}
    Log To Console    Building object ${bts_distName}/NRCELL-${cell_id}/NRREDRT-5
    ${NRREDRT}   Set Variable   <managedObject class="NRREDRT" distName="${bts_distName}/NRCELL-${cell_id}/NRREDRT-5"
    ${NRREDRT}   Catenate     SEPARATOR=${SPACE}   ${NRREDRT}         version="${version_SCF}" operation="create">
    FOR     ${line}   IN
    ...          <p name="redirPrio">1</p>
    ...          <p name="redirPrioBadUlRadio">1</p>
    ...          <p name="redirRat">nr</p>
    ...          <p name="redirFreqNr">128000</p>
    ...          <p name="redirSsbScs">15KHz</p>
    ...    </managedObject>
           ${NRREDRT}   Catenate     SEPARATOR=\n         ${NRREDRT}   ${line}
    END
    Add Element     ${scf_xml}     ${NRREDRT}           xpath=.//cmData


Create NRREDRT-5 FDD
    [Documentation]    [PRIVATE]    create NRREDRT-5 object in SCF
    ...       :Autor: Sylvia Schneider
    FOR   ${cell_id}   IN RANGE   7  13
        Create Single NRREDRT-5 FDD   ${cell_id}
    END


Create NRREDRT-0
    [Documentation]    [PRIVATE]    create NRREDRT-0 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRCELL-10/NRREDRT-0
    ${NRREDRT}   Set Variable   <managedObject class="NRREDRT" distName="${bts_distName}/NRCELL-10/NRREDRT-0"
    ${NRREDRT}   Catenate     SEPARATOR=${SPACE}   ${NRREDRT}         version="${version_SCF}" operation="create">
    FOR     ${line}   IN
           ...    <p name="redirFreqNr">176500</p>
           ...    <p name="redirPrio">2</p>
           ...    <p name="redirRat">nr</p>
           ...    <p name="redirSsbScs">15KHz</p>
           ...    </managedObject>
           ${NRREDRT}   Catenate     SEPARATOR=\n         ${NRREDRT}   ${line}
    END
    Add Element     ${scf_xml}     ${NRREDRT}           xpath=.//cmData


Create NRMEASCFG_IF
    [Documentation]    [PRIVATE]    create NRMEASCFG_IF object in SCF
    ...       :Autor: Sylvia Schneider

    Remove Element   ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}/NRMEASCFG_IF-1"]
    Remove Element   ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}/NRMEASCFG_IF-2"]
    FOR    ${instance}   ${a3MeasEnabled}   ${a5MeasEnabled}   ${freqBandIndicatorNR}   ${ssbFrequency}  IN
    ...    1             rsrpCombined       none               71                       127970
    ...    2             rsrpCombined       none               5                        176410
    ...    3             rsrp               none               257                      2071387
       Create Single NRMEASCFG_IF   ${instance}   ${a3MeasEnabled}   ${a5MeasEnabled}   ${freqBandIndicatorNR}   ${ssbFrequency}
    END


Create Single NRMEASCFG_IF
    [Documentation]    [PRIVATE]    create NRMEASCFG_IF object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${instance}   ${a3MeasEnabled}   ${a5MeasEnabled}   ${freqBandIndicatorNR}   ${ssbFrequency}
    Log To Console    Building object ${bts_distName}/NRMEASCFG_IF-${instance}
    ${NRMEASCFG_IF}   Set Variable   <managedObject class="NRMEASCFG_IF" distName="${bts_distName}/NRMEASCFG_IF-${instance}"
    ${NRMEASCFG_IF}   Catenate     SEPARATOR=${SPACE}   ${NRMEASCFG_IF}         version="${version_SCF}" operation="create">
    FOR     ${line}   IN
           ...    <p name="a3MeasEnabled">${a3MeasEnabled}</p>
           ...    <p name="a5MeasEnabled">${a5MeasEnabled}</p>
           ...    <p name="freqBandIndicatorNR">${freqBandIndicatorNR}</p>
           ...    <p name="ssbFrequency">${ssbFrequency}</p>
           ...    </managedObject>
           ${NRMEASCFG_IF}   Catenate     SEPARATOR=\n         ${NRMEASCFG_IF}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMEASCFG_IF}           xpath=.//cmData


Create NRMOPRMA_SA-1
    [Documentation]    [PRIVATE]    create NRMOPRMA_SA-1 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPRMA_SA-1
    ${NRMOPRMA_SA-1}   Set Variable   <managedObject class="NRMOPRMA_SA" distName="${bts_distName}/NRMOPRMA_SA-1"
    ${NRMOPRMA_SA-1}   Catenate     SEPARATOR=${SPACE}   ${NRMOPRMA_SA-1}         version="${version_SCF}" operation="create">
    FOR     ${line}   IN
           ...    <p name="mobilityProfilePriority">1</p>
           ...    <p name="nrMoPrSaDN">${bts_distName}/NRMOPR_SA-1</p>
           ...    <p name="rfspIndex">1</p>
           ...    <p name="rfspIndexLast">100</p>
           ...    <list name="nrPlmnDNList">
           ...    <p>${bts_distName}/NRPLMN-2</p>
           ...    </list>
           ...    </managedObject>
           ${NRMOPRMA_SA-1}   Catenate     SEPARATOR=\n         ${NRMOPRMA_SA-1}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMOPRMA_SA-1}           xpath=.//cmData


Create NRMOPRMA_SA-2
    [Documentation]    [PRIVATE]    create NRMOPRMA_SA-2 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPRMA_SA-2
    ${NRMOPRMA_SA-2}   Set Variable   <managedObject class="NRMOPRMA_SA" distName="${bts_distName}/NRMOPRMA_SA-2"
    ${NRMOPRMA_SA-2}   Catenate     SEPARATOR=${SPACE}   ${NRMOPRMA_SA-2}         version="${version_SCF}" operation="create">
    FOR     ${line}   IN
           ...    <p name="mobilityProfilePriority">2</p>
           ...    <p name="nrMoPrSaDN">${bts_distName}/NRMOPR_SA-2</p>
           ...    <p name="rfspIndex">1</p>
           ...    <p name="rfspIndexLast">50</p>
           ...    <list name="snssaiList">
           ...    <item>
           ...    <p name="snssaiDN">${bts_distName}/SNSSAI-2</p>
           ...    </item>
           ...    </list>
           ...    </managedObject>
           ${NRMOPRMA_SA-2}   Catenate     SEPARATOR=\n         ${NRMOPRMA_SA-2}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMOPRMA_SA-2}           xpath=.//cmData


Create NRMOPRMA_SA-3
    [Documentation]    [PRIVATE]    create NRMOPRMA_SA-3 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPRMA_SA-3
    ${NRMOPRMA_SA-3}   Set Variable   <managedObject class="NRMOPRMA_SA" distName="${bts_distName}/NRMOPRMA_SA-3"
    ${NRMOPRMA_SA-3}   Catenate     SEPARATOR=${SPACE}   ${NRMOPRMA_SA-3}         version="${version_SCF}" operation="create">
    FOR     ${line}   IN
           ...    <p name="mobilityProfilePriority">3</p>
           ...    <p name="nrMoPrSaDN">${bts_distName}/NRMOPR_SA-3</p>
           ...    <p name="rfspIndex">51</p>
           ...    <p name="rfspIndexLast">98</p>
           ...    <list name="nrPlmnDNList">
           ...    <p>${bts_distName}/NRPLMN-1</p>
           ...    </list>
           ...    <list name="snssaiList">
           ...    <item>
           ...    <p name="snssaiDN">${bts_distName}/SNSSAI-1</p>
           ...    </item>
           ...    </list>
           ...    </managedObject>
           ${NRMOPRMA_SA-3}   Catenate     SEPARATOR=\n         ${NRMOPRMA_SA-3}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMOPRMA_SA-3}           xpath=.//cmData


Create NRMOPRMA_SA-4
    [Documentation]    [PRIVATE]    create NRMOPRMA_SA-4 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPRMA_SA-4
    ${NRMOPRMA_SA-4}   Set Variable   <managedObject class="NRMOPRMA_SA" distName="${bts_distName}/NRMOPRMA_SA-4"
    ${NRMOPRMA_SA-4}   Catenate     SEPARATOR=${SPACE}   ${NRMOPRMA_SA-4}         version="${version_SCF}" operation="create">
    FOR     ${line}   IN
           ...    <p name="mobilityProfilePriority">4</p>
           ...    <p name="nrMoPrSaDN">${bts_distName}/NRMOPR_SA-4</p>
           ...    <p name="rfspIndex">99</p>
           ...    <list name="nrPlmnDNList">
           ...    <p>${bts_distName}/NRPLMN-1</p>
           ...    </list>
           ...    <list name="snssaiList">
           ...    <item>
           ...    <p name="snssaiDN">${bts_distName}/SNSSAI-1</p>
           ...    </item>
           ...    </list>
           ...    </managedObject>
           ${NRMOPRMA_SA-4}   Catenate     SEPARATOR=\n         ${NRMOPRMA_SA-4}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMOPRMA_SA-4}           xpath=.//cmData


Create NRMOPRMA_SA-5
    [Documentation]    [PRIVATE]    create NRMOPRMA_SA-5 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPRMA_SA-5
    ${NRMOPRMA_SA-5}   Set Variable   <managedObject class="NRMOPRMA_SA" distName="${bts_distName}/NRMOPRMA_SA-5"
    ${NRMOPRMA_SA-5}   Catenate     SEPARATOR=${SPACE}   ${NRMOPRMA_SA-5}         version="${version_SCF}" operation="create">
    FOR     ${line}   IN
           ...    <p name="mobilityProfilePriority">5</p>
           ...    <p name="nrMoPrSaDN">${bts_distName}/NRMOPR_SA-5</p>
           ...    <list name="nrPlmnDNList">
           ...    <p>${bts_distName}/NRPLMN-2</p>
           ...    </list>
           ...    </managedObject>
           ${NRMOPRMA_SA-5}   Catenate     SEPARATOR=\n         ${NRMOPRMA_SA-5}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMOPRMA_SA-5}           xpath=.//cmData


Update NRMOPR_NSA
    Remove Element   ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}/NRMOPR_NSA-1"]/list[@name="nrMeasCfgIfDNList"]
    Remove Element   ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}/NRMOPR_NSA-2"]


Create NRMORED-1
    [Documentation]    [PRIVATE]    create NRMORED-1 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMORED-1
    ${NRMORED}   Set Variable   <managedObject class="NRMORED" distName="${bts_distName}/NRMORED-1"
    ${NRMORED}   Catenate     SEPARATOR=${SPACE}   ${NRMORED}         version="${version_SCF}" operation="create">
    FOR     ${line}   IN
           ...    <p name="redirFreqNr">176500</p>
           ...    <p name="redirPrio">1</p>
           ...    <p name="redirRat">nr</p>
           ...    </managedObject>
           ${NRMORED}   Catenate     SEPARATOR=\n         ${NRMORED}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMORED}           xpath=.//cmData


Create NRMORED-2
    [Documentation]    [PRIVATE]    create NRMORED-2 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMORED-2
    ${NRMORED}   Set Variable   <managedObject class="NRMORED" distName="${bts_distName}/NRMORED-2"
    ${NRMORED}   Catenate     SEPARATOR=${SPACE}   ${NRMORED}         version="${version_SCF}" operation="create">
    FOR     ${line}   IN
           ...    <p name="redirFreqNr">128000</p>
           ...    <p name="redirPrio">2</p>
           ...    <p name="redirRat">nr</p>
           ...    </managedObject>
           ${NRMORED}   Catenate     SEPARATOR=\n         ${NRMORED}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMORED}           xpath=.//cmData


Update NRMOPR_SA-1
    [Documentation]    [PRIVATE]    update NRMOPR_SA-1 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Update object ${bts_distName}/NRMOPR_SA-1
    ${a2MeashoEnabledSA}    set Variable     <p name="a2MeashoEnabledSA">rsrp</p>
    ${a2MeasRedirectEnabled}   Set Variable  <p name="a2MeasRedirectEnabled">rsrp</p>
    Set Element Text   ${scf_xml}    text=rsrp     xpath=.//managedObject[@distName="${bts_distName}/NRMOPR_SA-1"]/p[@name="a1MeashoEnabledSA"]
    Add Element     ${scf_xml}     ${a2MeashoEnabledSA}         xpath=.//managedObject[@distName="${bts_distName}/NRMOPR_SA-1"]
    Add Element     ${scf_xml}     ${a2MeasRedirectEnabled}     xpath=.//managedObject[@distName="${bts_distName}/NRMOPR_SA-1"]
    ${nrMeasCfgIfDNList}    Set Variable     <list name="nrMeasCfgIfDNList">
    FOR    ${line}   IN
           ...    <p>${bts_distName}/NRMEASCFG_IF-1</p>
           ...    </list>
           ${nrMeasCfgIfDNList}    Catenate     SEPARATOR=\n   ${nrMeasCfgIfDNList}   ${line}
    END
    Add Element     ${scf_xml}     ${nrMeasCfgIfDNList}   xpath=.//managedObject[@distName="${bts_distName}/NRMOPR_SA-1"]
    ${nrMoRedDNList}    Set Variable     <list name="nrMoRedDNList">
    FOR    ${line}   IN
           ...    <p>${bts_distName}/NRMORED-1</p>
           ...    <p>${bts_distName}/NRMORED-2</p>
           ...    </list>
           ${nrMoRedDNList}    Catenate     SEPARATOR=\n   ${nrMoRedDNList}   ${line}
    END
    Add Element     ${scf_xml}     ${nrMoRedDNList}   xpath=.//managedObject[@distName="${bts_distName}/NRMOPR_SA-1"]


Create NRMOPR_SA-2
    [Documentation]    [PRIVATE]    create NRMOPR_SA-2 object in SCF
    ...       :Autor: Sylvia Schneider

    Remove Element    ${scf_xml}  xpath=.//managedObject[@distName="${bts_distName}/NRMOPR_SA-2"]
    Log To Console    Building object ${bts_distName}/NRMOPR_SA-2
    ${NRMOPR_SA}   Set Variable   <managedObject class="NRMOPR_SA" distName="${bts_distName}/NRMOPR_SA-2"
    ${NRMOPR_SA}   Catenate     SEPARATOR=${SPACE}   ${NRMOPR_SA}         version="${version_SCF}" operation="create">
    FOR     ${line}   IN
           ...    <p name="a1MeashoEnabledSA">rsrpCombined</p>
           ...    <p name="a2MeasRedirectEnabled">rsrpCombined</p>
           ...    <p name="a2MeashoEnabledSA">rsrpCombined</p>
           ...    <p name="emergencyCallFails">disabled</p>
           ...    <p name="emergencyFBMode">disabled</p>
           ...    <p name="voiceFBMode">disabled</p>
           ...    <list name="nrMeasCfgIfDNList">
           ...    <p>${bts_distName}/NRMEASCFG_IF-1</p>
           ...    </list>
           ...    <list name="nrMoRedDNList">
           ...    <p>${bts_distName}/NRMORED-1</p>
           ...    <p>${bts_distName}/NRMORED-2</p>
           ...    </list>
           ...    </managedObject>
           ${NRMOPR_SA}   Catenate     SEPARATOR=\n         ${NRMOPR_SA}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMOPR_SA}           xpath=.//cmData


Create NRMOPR_SA-3
    [Documentation]    [PRIVATE]    create NRMOPR_SA-3 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPR_SA-3
    ${NRMOPR_SA}   Set Variable   <managedObject class="NRMOPR_SA" distName="${bts_distName}/NRMOPR_SA-3"
    ${NRMOPR_SA}   Catenate     SEPARATOR=${SPACE}   ${NRMOPR_SA}         version="${version_SCF}" operation="create">
    FOR     ${line}   IN
           ...    <p name="a1MeashoEnabledSA">rsrpCombined</p>
           ...    <p name="a2MeasRedirectEnabled">rsrp</p>
           ...    <p name="a2MeashoEnabledSA">rsrpCombined</p>
           ...    <p name="emergencyCallFails">disabled</p>
           ...    <p name="emergencyFBMode">disabled</p>
           ...    <p name="voiceFBMode">disabled</p>
           ...    <list name="nrMeasCfgIfDNList">
           ...    <p>${bts_distName}/NRMEASCFG_IF-2</p>
           ...    <p>${bts_distName}/NRMEASCFG_IF-3</p>
           ...    </list>
           ...    <list name="nrMoRedDNList">
           ...    <p>${bts_distName}/NRMORED-1</p>
           ...    </list>
           ...    </managedObject>
           ${NRMOPR_SA}   Catenate     SEPARATOR=\n         ${NRMOPR_SA}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMOPR_SA}           xpath=.//cmData


Create NRMOPR_SA-32
    [Documentation]    [PRIVATE]    create NRMOPR_SA-32 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPR_SA-32
    ${NRMOPR_SA}   Set Variable   <managedObject class="NRMOPR_SA" distName="${bts_distName}/NRMOPR_SA-32"
    ${NRMOPR_SA}   Catenate     SEPARATOR=${SPACE}   ${NRMOPR_SA}         version="${version_SCF}" operation="create">
    FOR     ${line}   IN
           ...    <p name="a1MeashoEnabledSA">none</p>
           ...    <p name="a2MeasRedirectEnabled">none</p>
           ...    <p name="a2MeashoEnabledSA">none</p>
           ...    <p name="emergencyCallFails">disabled</p>
           ...    <p name="emergencyFBMode">disabled</p>
           ...    <p name="voiceFBMode">disabled</p>
           ...    </managedObject>
           ${NRMOPR_SA}   Catenate     SEPARATOR=\n         ${NRMOPR_SA}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMOPR_SA}           xpath=.//cmData


Create NRMOPR_SA-4
    [Documentation]    [PRIVATE]    create NRMOPR_SA-4 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPR_SA-4
    ${NRMOPR_SA}   Set Variable   <managedObject class="NRMOPR_SA" distName="${bts_distName}/NRMOPR_SA-4"
    ${NRMOPR_SA}   Catenate     SEPARATOR=${SPACE}   ${NRMOPR_SA}         version="${version_SCF}" operation="create">
    FOR     ${line}   IN
           ...    <p name="a1MeashoEnabledSA">rsrpCombined</p>
           ...    <p name="a2MeasRedirectEnabled">rsrp</p>
           ...    <p name="a2MeashoEnabledSA">rsrpCombined</p>
           ...    <p name="emergencyCallFails">disabled</p>
           ...    <p name="emergencyFBMode">disabled</p>
           ...    <p name="voiceFBMode">disabled</p>
           ...    <list name="nrMeasCfgIfDNList">
           ...    <p>${bts_distName}/NRMEASCFG_IF-1</p>
           ...    <p>${bts_distName}/NRMEASCFG_IF-2</p>
           ...    </list>
           ...    <list name="nrMoRedDNList">
           ...    <p>${bts_distName}/NRMORED-1</p>
           ...    <p>${bts_distName}/NRMORED-2</p>
           ...    </list>
           ...    </managedObject>
           ${NRMOPR_SA}   Catenate     SEPARATOR=\n         ${NRMOPR_SA}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMOPR_SA}           xpath=.//cmData


Create NRMOPR_SA-5
    [Documentation]    [PRIVATE]    create NRMOPR_SA-5 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPR_SA-5
    ${NRMOPR_SA}   Set Variable   <managedObject class="NRMOPR_SA" distName="${bts_distName}/NRMOPR_SA-5"
    ${NRMOPR_SA}   Catenate     SEPARATOR=${SPACE}   ${NRMOPR_SA}         version="${version_SCF}" operation="create">
    FOR     ${line}   IN
           ...    <p name="a1MeashoEnabledSA">rsrp</p>
           ...    <p name="a2MeasRedirectEnabled">rsrp</p>
           ...    <p name="a2MeashoEnabledSA">rsrp</p>
           ...    <p name="emergencyCallFails">disabled</p>
           ...    <p name="emergencyFBMode">disabled</p>
           ...    <p name="voiceFBMode">disabled</p>
           ...    <list name="nrMeasCfgIfDNList">
           ...    <p>${bts_distName}/NRMEASCFG_IF-1</p>
           ...    </list>
           ...    <list name="nrMoRedDNList">
           ...    <p>${bts_distName}/NRMORED-1</p>
           ...    <p>${bts_distName}/NRMORED-2</p>
           ...    </list>
           ...    </managedObject>
           ${NRMOPR_SA}   Catenate     SEPARATOR=\n         ${NRMOPR_SA}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMOPR_SA}           xpath=.//cmData


Update SNSSAI and TRACKINGAREA
    [Documentation]    [PRIVATE]    Update SNSSAI and TRACKINGAREA
    ...       :Autor: Sylvia Schneider
    Add Element     ${scf_xml}     <p>${bts_distName}/NRPLMN-2</p>
    ...   xpath=.//managedObject[@distName="${bts_distName}/SNSSAI-1"]/list[@name="nrPlmnDNList"]
    Set Element Text     ${scf_xml}   text=13714342  xpath=.//managedObject[@distName="${bts_distName}/SNSSAI-2"]/p[@name="sd"]
    Add Element     ${scf_xml}     <p>${bts_distName}/NRPLMN-2</p>
    ...   xpath=.//managedObject[@distName="${bts_distName}/SNSSAI-2"]/list[@name="nrPlmnDNList"]

    FOR  ${id}  IN RANGE  21   29
       Remove Element   ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}/SNSSAI-${id}"]
    END

    Remove Element  ${scf_xml}   xpath=.//managedObject[@distName="${bts_distName}/TRACKINGAREA-200"]

    ${TRACKINGAREA}   Set Variable   <managedObject class="TRACKINGAREA" distName="${bts_distName}/TRACKINGAREA-200"
    ${TRACKINGAREA}   Catenate     SEPARATOR=${SPACE}   ${TRACKINGAREA}         version="${version_SCF}" operation="create">
    FOR     ${line}   IN
           ...    <p name="fiveGsTac">200</p>
           ...    <list name="snssaiList">
           ...    <item>
           ...    <p name="snssaiDN">${bts_distName}/SNSSAI-1</p>
           ...    </item>
           ...    <item>
           ...    <p name="snssaiDN">${bts_distName}/SNSSAI-2</p>
           ...    </item>
           ...    </list>
           ...    </managedObject>
           ${TRACKINGAREA}   Catenate     SEPARATOR=\n         ${TRACKINGAREA}   ${line}
    END
    Add Element     ${scf_xml}     ${TRACKINGAREA}           xpath=.//cmData



Create XNLINK
    [Documentation]    [PRIVATE]    create XNLINK object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/XNLINK-2
    ${new_mo}   Set Variable   <managedObject class="XNLINK" distName="${bts_distName}/XNLINK-2"
    ${new_mo}   Catenate     SEPARATOR=${SPACE}   ${new_mo}         version="${version_SCF}" operation="create">
    FOR     ${line}   IN
           ...    <p name="cPlaneIpAddr">10.0.1.3</p>
           ...    <p name="cPlaneIpAddrCtrl">oamControlled</p>
           ...    </managedObject>
           ${new_mo}   Catenate     SEPARATOR=\n         ${new_mo}   ${line}
    END
    Add Element     ${scf_xml}     ${new_mo}           xpath=.//cmData

