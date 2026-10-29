*** Settings ***
Documentation   This is a keyword file for CB008731, part commissioning, new objects
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Keywords ***

Create NRADJECELL
    [Documentation]    [PRIVATE]    create NRADJECELL object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRADJECELL-1
    ${new_MO}   Set Variable   <managedObject class="NRADJECELL" distName="${bts_distName}/NRADJECELL-1"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
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


Create NRADJECELL 2 TMO
    [Documentation]    [PRIVATE]    Create NRADJECELL 2 TMO
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRADJECELL-2
    ${new_MO}   Set Variable   <managedObject class="NRADJECELL" distName="${bts_distName}/NRADJECELL-2"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="eNodeBId">18</p>
    ...    <p name="ePSTrackingAreaCode">222</p>
    ...    <p name="earfcnValue">1</p>
    ...    <p name="iRatDataForwardingMethod">indirectDataFwd</p>
    ...    <p name="lcrId">1</p>
    ...    <p name="physCellId">11</p>
    ...    <list name="ecgiPlmn">
    ...    <item>
    ...    <p name="mcc">310</p>
    ...    <p name="mnc">260</p>
    ...    <p name="mncLength">3</p>
    ...    </item>
    ...    </list>
    ...    <list name="enbPlmn">
    ...    <item>
    ...    <p name="mcc">310</p>
    ...    <p name="mnc">260</p>
    ...    <p name="mncLength">3</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRADJNRCELL 2gnb
    [Documentation]    [PRIVATE]    create NRADJNRCELL object in SCF
    ...       :Autor: Sylvia Schneider
    FOR     ${instance}   ${fiveGsTac}    ${lcrId}    ${physCellId}   IN
    ...        1            100          1           48
    ...        2            788          2           49
           Create Single NRADJNRCELL 2gnb    ${instance}   ${fiveGsTac}    ${lcrId}    ${physCellId}
    END


Create Single NRADJNRCELL 2gnb
    [Documentation]    [PRIVATE]    create NRADJNRCELL object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${instance}    ${fiveGsTac}    ${lcrId}    ${physCellId}
    Log To Console    Building object ${bts_distName}/NRADJNRCELL-${instance}
    ${NRADJNRCELL}    Set Variable  <managedObject class="NRADJNRCELL" distName="${bts_distName}/NRADJNRCELL-${instance}"
    ${NRADJNRCELL}   Catenate     SEPARATOR=${SPACE}   ${NRADJNRCELL}    version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="cellDepType">SA</p>
    ...    <p name="cellReservedForOperatorUse">notReserved</p>
    ...    <p name="fiveGsTac">${fiveGsTac}</p>
    ...    <p name="freqBandIndicatorNR">78</p>
    ...    <p name="gNbId">38</p>
    ...    <p name="gNbIdLength">22</p>
    ...    <p name="lcrId">${lcrId}</p>
    ...    <p name="nrarfcn">636666</p>
    ...    <p name="ssbFrequency">636576</p>
    ...    <p name="physCellId">${physCellId}</p>
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


Create NRADJNRCELL force_HO
    [Documentation]    [PRIVATE]    create NRADJNRCELL force_HO object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRADJNRCELL-1
    ${new_MO}    Set Variable  <managedObject class="NRADJNRCELL" distName="${bts_distName}/NRADJNRCELL-1"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}    version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="cellDepType">SA</p>
    ...    <p name="cellReservedForOperatorUse">notReserved</p>
    ...    <p name="fiveGsTac">0</p>
    ...    <p name="freqBandIndicatorNR">78</p>
    ...    <p name="gNbId">3</p>
    ...    <p name="gNbIdLength">22</p>
    ...    <p name="lcrId">1</p>
    ...    <p name="nrarfcn">636666</p>
    ...    <p name="physCellId">48</p>
    ...    <p name="ssbFrequency">636576</p>
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

    Log To Console    Building object ${bts_distName}/NRADJNRCELL-2
    ${new_MO}    Set Variable  <managedObject class="NRADJNRCELL" distName="${bts_distName}/NRADJNRCELL-2"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}    version="${SCF.version}" operation="create">
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
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRADJGNB
    [Documentation]    [PRIVATE]    create NRADJGNB object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRADJGNB-1
    ${new_MO}    Set Variable  <managedObject class="NRADJGNB" distName="${bts_distName}/NRADJGNB-1"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}    version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="administrativeState">Unlocked</p>
    ...    <p name="gNbIdLength">28</p>
    ...    <p name="gNodeBId">18</p>
    ...    <p name="gNodeBIdCtrl">oamControlled</p>
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


Create NRADJGNB 2gnb
    [Documentation]    [PRIVATE]    create NRADJGNB object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRADJGNB-2
    ${NRADJGNB}    Set Variable  <managedObject class="NRADJGNB" distName="${bts_distName}/NRADJGNB-2"
    ${NRADJGNB}   Catenate     SEPARATOR=${SPACE}   ${NRADJGNB}    version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="administrativeState">Unlocked</p>
    ...    <p name="gNbIdLength">28</p>
    ...    <p name="gNodeBId">38</p>
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
           ${NRADJGNB}   Catenate     SEPARATOR=\n         ${NRADJGNB}   ${line}
    END
    Add Element     ${scf_xml}     ${NRADJGNB}           xpath=.//cmData


Create NRADJGNB force_HO
    [Documentation]    [PRIVATE]    create NRADJGNB force_HO object in SCF
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
    ...    <p name="mcc">311</p>
    ...    <p name="mnc">489</p>
    ...    <p name="mncLength">3</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


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
    ...    <p name="mcc">311</p>
    ...    <p name="mnc">489</p>
    ...    <p name="mncLength">3</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRADJGNB force_HO TMO
    [Documentation]    [PRIVATE]    create NRADJGNB force_HO object in SCF TMO
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRADJGNB-1
    ${new_MO}    Set Variable  <managedObject class="NRADJGNB" distName="${bts_distName}/NRADJGNB-1"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}    version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="administrativeState">Unlocked</p>
    ...    <p name="gNbIdLength">22</p>
    ...    <p name="gNodeBId">3</p>
    ...    <p name="gNodeBIdCtrl">oamControlled</p>
    ...    <p name="xnLinkRef">2</p>
    ...    <list name="gnbPlmn">
    ...    <item>
    ...    <p name="mcc">310</p>
    ...    <p name="mnc">260</p>
    ...    <p name="mncLength">3</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


    Log To Console    Building object ${bts_distName}/NRADJGNB-2
    ${new_MO}    Set Variable  <managedObject class="NRADJGNB" distName="${bts_distName}/NRADJGNB-2"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}    version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="administrativeState">Unlocked</p>
    ...    <p name="gNbIdLength">28</p>
    ...    <p name="gNodeBId">18</p>
    ...    <p name="gNodeBIdCtrl">gnbControlled</p>
    ...    <p name="xnLinkRef">3</p>
    ...    <list name="gnbPlmn">
    ...    <item>
    ...    <p name="mcc">310</p>
    ...    <p name="mnc">260</p>
    ...    <p name="mncLength">3</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create Single NRCONNECTMODE_PROFILE force_HO
    [Documentation]    [PRIVATE]    create single NRCONNECTMODE_PROFILE force_HO object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${profile_id}   ${multiFreqBandIndicatorNR}
    Log To Console    Building object ${bts_distName}/NRCONNECTMODE_PROFILE-${profile_id}
    ${new_MO}    Set Variable  <managedObject class="NRCONNECTMODE_PROFILE" distName="${bts_distName}/NRCONNECTMODE_PROFILE-${profile_id}"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}    version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <list name="multiFreqBandIndicatorNR">
    ...    <p>${multiFreqBandIndicatorNR}</p>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRCONNECTMODE_PROFILE
    [Documentation]    [PRIVATE]    create NRCONNECTMODE_PROFILE object in SCF
    ...       :Autor: Sylvia Schneider
    FOR   ${profile_id}   ${multiFreqBandIndicatorNR}    IN
    ...   1               77
    ...   2               90
       Create Single NRCONNECTMODE_PROFILE force_HO    ${profile_id}   ${multiFreqBandIndicatorNR}
    END


Create NRCTRLTS
    [Documentation]    [PRIVATE]    create NRCTRLTS object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRCTRLTS-1
    ${new_MO}   Set Variable   <managedObject class="NRCTRLTS" distName="${bts_distName}/NRCTRLTS-1"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create"/>
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData



Create NRDRB_16_17
    [Documentation]    [PRIVATE]    create NRDRB-16 and 17 objects in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRDRB-16
    ${new_MO}   Set Variable   <managedObject class="NRDRB" distName="${bts_distName}/NRDRB-16"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="actDddsReduction">false</p>
    ...    <p name="actDlTxResumeOnPdcpStatRep">false</p>
    ...    <p name="actLostPduFastRetx">false</p>
    ...    <p name="actOptDataFlowRateEst">false</p>
    ...    <p name="allowedPdcchPowerBoostALDueCce">none</p>
    ...    <p name="allowedPdcchPowerBoostALDueCfg">None</p>
    ...    <p name="caPduReSendingDelayMargin">2</p>
    ...    <p name="discardTimer">1500ms</p>
    ...    <p name="dlAllowMinDelayLinkXxCalib">false</p>
    ...    <p name="discardTimerUl">infinity</p>
    ...    <p name="dlFlowControlAlgo">3gppFlowControl</p>
    ...    <p name="dscp">26</p>
    ...    <p name="durationThresDiscardDl">40</p>
    ...    <p name="durationThresDiscardDlMacSdu">40</p>
    ...    <p name="durationThresDiscardDlPdcpPdu5GLeg">40</p>
    ...    <p name="durationThresDiscardDlPdcpPduLteLeg">40</p>
    ...    <p name="durationThresDiscardUl">20</p>
    ...    <p name="endMarkerTimer">2000</p>
    ...    <p name="l2OHFactorDl">16</p>
    ...    <p name="l2OHFactorUl">35</p>
    ...    <p name="maxDataRateGbrDl">30000</p>
    ...    <p name="maxDataRateGbrUl">30000</p>
    ...    <p name="maxDddsPeriodCpuOvld">40</p>
    ...    <p name="maxForwardTimeLimitXx">50</p>
    ...    <p name="maxRlcQueueingDelayGbr">20</p>
    ...    <p name="maxTransferDelayGbr">20</p>
    ...    <p name="minForwardTputXx">100</p>
    ...    <p name="nrDrbMacDN">${bts_distName}/NRDRB_MAC-5</p>
    ...    <p name="nrDrbPdcpDN">${bts_distName}/NRDRB_PDCP-3</p>
    ...    <p name="nrDrbRlcUmDN">${bts_distName}/NRDRB_RLC_UM-1</p>
    ...    <p name="nrDrxDN">${bts_distName}/NRDRX-1</p>
    ...    <p name="numSduDiscard">1</p>
    ...    <p name="queuingDelayDiscardStart">5</p>
    ...    <p name="queuingDelayDiscarding">Disabled</p>
    ...    <p name="queuingDelaySduDiscardThreshold">750</p>
    ...    <p name="resType">GBR</p>
    ...    <p name="rlcMode">RLC_UM</p>
    ...    <p name="rlcPduDelayThCa">30</p>
    ...    <p name="sduDiscardIntervalTmr">500</p>
    ...    <p name="volThresDiscardDl">8000</p>
    ...    <p name="volThresDiscardDlMacSdu">8000</p>
    ...    <p name="volThresDiscardDlPdcpPdu5GLeg">8000</p>
    ...    <p name="volThresDiscardDlPdcpPduLteLeg">8000</p>
    ...    <p name="volThresDiscardUl">800</p>
    ...    <list name="cellAggrLevel">
    ...    <p>Not FR1 CA eligible</p>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData

    Log To Console    Building object ${bts_distName}/NRDRB-17
    ${new_MO}   Set Variable   <managedObject class="NRDRB" distName="${bts_distName}/NRDRB-17"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="actDddsReduction">false</p>
    ...    <p name="actDlTxResumeOnPdcpStatRep">false</p>
    ...    <p name="actLostPduFastRetx">false</p>
    ...    <p name="actOptDataFlowRateEst">false</p>
    ...    <p name="allowedPdcchPowerBoostALDueCce">none</p>
    ...    <p name="allowedPdcchPowerBoostALDueCfg">None</p>
    ...    <p name="caPduReSendingDelayMargin">2</p>
    ...    <p name="discardTimer">1500ms</p>
    ...    <p name="dlAllowMinDelayLinkXxCalib">false</p>
    ...    <p name="discardTimerUl">infinity</p>
    ...    <p name="dlFlowControlAlgo">3gppFlowControl</p>
    ...    <p name="dscp">34</p>
    ...    <p name="durationThresDiscardDl">40</p>
    ...    <p name="durationThresDiscardDlMacSdu">40</p>
    ...    <p name="durationThresDiscardDlPdcpPdu5GLeg">40</p>
    ...    <p name="durationThresDiscardDlPdcpPduLteLeg">40</p>
    ...    <p name="durationThresDiscardUl">20</p>
    ...    <p name="endMarkerTimer">2000</p>
    ...    <p name="l2OHFactorDl">16</p>
    ...    <p name="l2OHFactorUl">35</p>
    ...    <p name="maxDataRateGbrDl">10000</p>
    ...    <p name="maxDataRateGbrUl">10000</p>
    ...    <p name="maxDddsPeriodCpuOvld">40</p>
    ...    <p name="maxForwardTimeLimitXx">50</p>
    ...    <p name="maxRlcQueueingDelayGbr">20</p>
    ...    <p name="maxTransferDelayGbr">20</p>
    ...    <p name="minForwardTputXx">100</p>
    ...    <p name="nrDrbMacDN">${bts_distName}/NRDRB_MAC-6</p>
    ...    <p name="nrDrbPdcpDN">${bts_distName}/NRDRB_PDCP-3</p>
    ...    <p name="nrDrbRlcAmDN">${bts_distName}/NRDRB_RLC_AM-1</p>
    ...    <p name="nrDrxDN">${bts_distName}/NRDRX-1</p>
    ...    <p name="numSduDiscard">1</p>
    ...    <p name="queuingDelayDiscardStart">5</p>
    ...    <p name="queuingDelayDiscarding">Disabled</p>
    ...    <p name="queuingDelaySduDiscardThreshold">750</p>
    ...    <p name="resType">GBR</p>
    ...    <p name="rlcMode">RLC_AM</p>
    ...    <p name="rlcPduDelayThCa">30</p>
    ...    <p name="sduDiscardIntervalTmr">500</p>
    ...    <p name="volThresDiscardDl">8000</p>
    ...    <p name="volThresDiscardDlMacSdu">8000</p>
    ...    <p name="volThresDiscardDlPdcpPdu5GLeg">8000</p>
    ...    <p name="volThresDiscardDlPdcpPduLteLeg">8000</p>
    ...    <p name="volThresDiscardUl">800</p>
    ...    <list name="cellAggrLevel">
    ...    <p>Not FR1 CA eligible</p>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRDRB_5QI-7_8
    [Documentation]    [PRIVATE]    create NRDRB_5QI-7 and 8 objects in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRDRB_5QI-7
    ${new_MO}   Set Variable   <managedObject class="NRDRB_5QI" distName="${bts_distName}/NRDRB_5QI-7"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="dataForwarding">IRATDataFwd</p>
    ...    <list name="fiveqiValueList">
    ...    <p>2</p>
    ...    </list>
    ...    <p name="nrDrbDN">${bts_distName}/NRDRB-16</p>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData

    Log To Console    Building object ${bts_distName}/NRDRB_5QI-8
    ${new_MO}   Set Variable   <managedObject class="NRDRB_5QI" distName="${bts_distName}/NRDRB_5QI-8"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="dataForwarding">IRATDataFwd</p>
    ...    <list name="fiveqiValueList">
    ...    <p>71</p>
    ...    </list>
    ...    <p name="nrDrbDN">${bts_distName}/NRDRB-17</p>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRDRB_MAC-5_6
    [Documentation]    [PRIVATE]    create NRDRB_MAC-5 and 6 objects in SCF
    ...       :Autor: Sylvia Schneider
    FOR        ${id}    ${schedulPrio}   IN
         ...   5   7
         ...   6   8
         Create Single NRDRB_MAC    ${id}    ${schedulPrio}
    END


Create Single NRDRB_MAC
    [Documentation]    [PRIVATE]    create single NRDRB_MAC object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${id}    ${schedulPrio}
    Log To Console    Building object ${bts_distName}/NRDRB_MAC-${id}
    ${new_MO}   Set Variable   <managedObject class="NRDRB_MAC" distName="${bts_distName}/NRDRB_MAC-${id}"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="delayTarget">50</p>
    ...    <p name="lcgid">5</p>
    ...    <p name="prioritisedBitRate">16kBps</p>
    ...    <p name="schedulBSD">100ms</p>
    ...    <p name="schedulPrio">${schedulPrio}</p>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


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
    ...    <p name="a4MeasHigherPrioFreqEnabled">rsrp</p>
    ...    <p name="a4MeasNrDcEnabled">none</p>
    ...    <p name="a4PriorityForHigherPrioFreqHo">10</p>
    ...    <p name="a4MeasSCellAddEnabled">none</p>
    ...    <p name="a5MeasEnabled">rsrp</p>
    ...    <p name="cellDepType">SA</p>
    ...    <p name="freqBandIndicatorNR">78</p>
    ...    <p name="ifhoSsbScs">30 KHz</p>
    ...    <p name="ifhoSsbSmtcDuration">sf3</p>
    ...    <p name="ifhoSsbSmtcPeriodicity">sf10</p>
    ...    <p name="numberOfTransmittedSsBlocks">1 beam</p>
    ...    <p name="scs">30 KHz</p>
    ...    <p name="ssBurstSetPeriod">20</p>
    ...    <p name="ssbFrequency">647616</p>
    ...    <list name="a3MeasSsbRsrp">
    ...    <item>
    ...    <p name="a3HysteresisSsbRsrp">0</p>
    ...    <p name="a3OffsetSsbRsrp">3</p>
    ...    <p name="a3TimeToTriggerSsbRsrp">ms64</p>
    ...    </item>
    ...    </list>
    ...    <list name="a4MeasSsbRsrp">
    ...    <item>
    ...    <p name="a4HysteresisSsbRsrp">1</p>
    ...    <p name="a4ThresholdSsbRsrp">35</p>
    ...    <p name="a4TimeToTriggerSsbRsrp">ms64</p>
    ...    </item>
    ...    </list>
    ...    <list name="a5MeasSsbRsrp">
    ...    <item>
    ...    <p name="a5HysteresisSsbRsrp">10</p>
    ...    <p name="a5Threshold1SsbRsrp">70</p>
    ...    <p name="a5Threshold2SsbRsrp">40</p>
    ...    <p name="a5TimeToTriggerSsbRsrp">ms5120</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRHOIF NRCELL-1 force_HO
    [Documentation]    [PRIVATE]    create NRHOIF NRCELL-1 force_HO object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRCELL-1/NRHOIF-1
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
    ...    <p name="nrConnectModeProfileDN">${bts_distName}/NRCONNECTMODE_PROFILE-2</p>
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


Create NRHOIF NRCELL-2 force_HO
    [Documentation]    [PRIVATE]    create NRHOIF NRCELL-1 force_HO object in SCF
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
    ...    <p name="nrConnectModeProfileDN">${bts_distName}/NRCONNECTMODE_PROFILE-1</p>
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


Create NRREDRT
    [Documentation]    [PRIVATE]    Recreate NRREDRT object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    re-create object ${bts_distName}/NRCELL-1/NRREDRT-0
    ${new_MO}   Set Variable   <managedObject class="NRREDRT" distName="${bts_distName}/NRCELL-1/NRREDRT-0"
    ${new_MO}   Catenate       SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="redirFreqNr">508020</p>
    ...    <p name="redirPrio">2</p>
    ...    <p name="redirPrioBadUlRadio">2</p>
    ...    <p name="redirRat">nr</p>
    ...    <p name="redirSsbScs">30 KHz</p>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData

    Log To Console    re-create object ${bts_distName}/NRCELL-1/NRREDRT-1
    ${new_MO}   Set Variable   <managedObject class="NRREDRT" distName="${bts_distName}/NRCELL-1/NRREDRT-1"
    ${new_MO}   Catenate       SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="redirFreqEutra">2000</p>
    ...    <p name="redirPrio">1</p>
    ...    <p name="redirPrioBadUlRadio">1</p>
    ...    <p name="redirRat">eutra</p>
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
    ...    <p name="b2MeashoEnabled">rsrq</p>
    ...    <p name="b2Threshold1hoRsrp">35</p>
    ...    <p name="b2Threshold1hoRsrpVoNr">45</p>
    ...    <p name="b2Threshold1hoRsrq">50</p>
    ...    <p name="b2Threshold1hoRsrqVoNr">60</p>
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
    ...    <p name="b2Threshold2hoRsrpVoNr">28</p>
    ...    <p name="b2TimeToTriggerhoRsrp">ms480</p>
    ...    <p name="b2TimeToTriggerhoRsrpVoNr">ms480</p>
    ...    </item>
    ...    </list>
    ...    <list name="eutraB2MeashoRsrq">
    ...    <item>
    ...    <p name="b2HysteresishoRsrq">0</p>
    ...    <p name="b2HysteresishoRsrqVoNr">0</p>
    ...    <p name="b2Threshold2hoRsrq">2</p>
    ...    <p name="b2Threshold2hoRsrqVoNr">12</p>
    ...    <p name="b2TimeToTriggerhoRsrq">ms480</p>
    ...    <p name="b2TimeToTriggerhoRsrqVoNr">ms480</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRHOIR force_HO
    [Documentation]    [PRIVATE]    create NRHOIR force_HO object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${nrhoir_id}=1
    Log To Console    Building object ${bts_distName}/NRHOIR-${nrhoir_id}
    ${new_MO}   Set Variable   <managedObject class="NRHOIR" distName="${bts_distName}/NRHOIR-${nrhoir_id}"
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


Create NRMEAS_PROFILE
    [Documentation]    [PRIVATE]    create NRMEAS_PROFILE object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMEAS_PROFILE-1
    ${new_MO}   Set Variable   <managedObject class="NRMEAS_PROFILE" distName="${bts_distName}/NRMEAS_PROFILE-1"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create"/>
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRMEASPR_IAF
    [Documentation]    [PRIVATE]    create NRMEASPR_IAF object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1
    ${new_MO}   Set Variable   <managedObject class="NRMEASPR_IAF" distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IAF-1"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
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


Create NRMEASPR_IEF
    [Documentation]    [PRIVATE]    create NRMEASPR_IEF object in SCF
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
    ...    <list name="a4MeasHigherPrioFreqSsbRsrq">
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


Create NRMEASPR_IRF
    [Documentation]    [PRIVATE]    create NRMEASPR_IRF object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IRF-1
    ${new_MO}   Set Variable   <managedObject class="NRMEASPR_IRF" distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_IRF-1"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="b2Threshold1hoRsrp">68</p>
    ...      <p name="b2Threshold1hoRsrq">68</p>
    ...    <list name="eutraB2MeashoRsrp">
    ...    <item>
    ...    <p name="b2HysteresishoRsrp">0</p>
    ...    <p name="b2Threshold2hoRsrp">26</p>
    ...    <p name="b2TimeToTriggerhoRsrp">ms480</p>
    ...    </item>
    ...    </list>
    ...    <list name="eutraB2MeashoRsrq">
    ...    <item>
    ...    <p name="b2HysteresishoRsrq">0</p>
    ...    <p name="b2Threshold2hoRsrq">26</p>
    ...    <p name="b2TimeToTriggerhoRsrq">ms480</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRMEASPR_MA_SA
    [Documentation]    [PRIVATE]    create NRMEASPR_MA_SA object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-1
    ${new_MO}   Set Variable   <managedObject class="NRMEASPR_MA_SA" distName="${bts_distName}/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-1"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <list name="fiveqiValueList">
    ...    <p>1</p>
    ...    </list>
    ...    <list name="nrMeasPrIefList">
    ...    <item>
    ...    <p name="nrMeasPrIefDN">MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_IEF-1</p>
    ...    <p name="ssbFrequency01">508110</p>
    ...    </item>
    ...    </list>
    ...    <list name="pcCapabilityList">
    ...    <item>
    ...    <p name="freqBandIndicatorNR">78</p>
    ...    <p name="uePowerClass">ue-PowerClass3</p>
    ...    </item>
    ...    <item>
    ...    <p name="freqBandIndicatorNR">41</p>
    ...    <p name="uePowerClass">ue-PowerClass3</p>
    ...    </item>
    ...    </list>
    ...    <p name="nrMeasPrIafDN">MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_IAF-1</p>
    ...    <p name="nrMeasPrIrfDN">MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_IRF-1</p>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRMOPRMA_SA-1 2gnb
    [Documentation]    [PRIVATE]    create NRMOPRMA_SA-1 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPRMA_SA-1
    ${NRMOPRMA_SA}    Set Variable  <managedObject class="NRMOPRMA_SA" distName="${bts_distName}/NRMOPRMA_SA-1"
    ${NRMOPRMA_SA}   Catenate     SEPARATOR=${SPACE}   ${NRMOPRMA_SA}    version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="mobilityProfilePriority">1</p>
    ...    <p name="nrMoPrSaDN">${bts_distName}/NRMOPR_SA-2</p>
    ...    <p name="rfspIndex">12</p>
    ...    <list name="nrPlmnDNList">
    ...    <p>${bts_distName}/NRPLMN-1</p>
    ...    </list>
    ...    </managedObject>
           ${NRMOPRMA_SA}   Catenate     SEPARATOR=\n         ${NRMOPRMA_SA}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMOPRMA_SA}           xpath=.//cmData


Create NRMOPR_SA-2 2gnb
    [Documentation]    [PRIVATE]    create NRMOPRMA_SA-1 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMOPR_SA-2
    ${NRMOPR_SA}    Set Variable  <managedObject class="NRMOPR_SA" distName="${bts_distName}/NRMOPR_SA-2"
    ${NRMOPR_SA}   Catenate     SEPARATOR=${SPACE}   ${NRMOPR_SA}    version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="a2MeasRedirectEnabled">none</p>
    ...    <p name="emergencyCallFails">disabled</p>
    ...    <p name="emergencyFBMode">disabled</p>
    ...    <p name="voiceFBMode">disabled</p>
    ...    </managedObject>
           ${NRMOPR_SA}   Catenate     SEPARATOR=\n         ${NRMOPR_SA}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMOPR_SA}           xpath=.//cmData


Create NRMTRACECU
    [Documentation]    [PRIVATE]    create NRMTRACECU object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRCTRLTS-1/NRMTRACECU-1
    ${new_MO}   Set Variable   <managedObject class="NRMTRACECU" distName="${bts_distName}/NRCTRLTS-1/NRMTRACECU-1"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="actCellTraceReportingCU">${NRMTRACECU_actCellTraceReportingCU}</p>
    ...    <p name="actPCMDReporting">${NRMTRACECU_actPCMDReporting}</p>
    ...    <p name="cellMaxActiveUEsTraced">100</p>
    ...    <p name="jobType">TraceOnly</p>
    ...    <p name="nrTceIdentifier">1</p>
    ...    <p name="scope">allResources</p>
    ...    <p name="traceE1Setting">none</p>
    ...    <p name="traceF1Setting">none</p>
    ...    <p name="traceNGAPSetting">${NRMTRACECU_traceNGAPSetting}</p>
    ...    <p name="traceNRRRCSetting">none</p>
    ...    <p name="traceX2Setting">none</p>
    ...    <p name="traceXNSetting">none</p>
    ...    <list name="nrRanTraceReference">
    ...    <item>
    ...    <p name="mcc">${SCF.mcc}</p>
    ...    <p name="mnc">${SCF.mnc}</p>
    ...    <p name="mncLength">3</p>
    ...    <p name="traceId">1</p>
    ...    </item>
    ...    </list>
    ...    <list name="tracePCMDSetting">
    ...    <p>all</p>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRPLMNSET_SA
    Create Single NRPLMNSET_SA    NRCELL=1
    Create Single NRPLMNSET_SA    NRCELL=2


Create Single NRPLMNSET_SA
    [Documentation]    [PRIVATE]    create NRPLMNSET_SA object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${NRCELL}
    Log To Console    Building object ${bts_distName}/NRCELL-${NRCELL}/NRPLMNSET_SA-1
    ${new_MO}
    ...    Set Variable  <managedObject class="com.nokia.srbts.nrbts:NRPLMNSET_SA" distName="${bts_distName}/NRCELL-${NRCELL}/NRPLMNSET_SA-1"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}    version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <list name="nrPlmnDNList">
    ...    <p>${bts_distName}/NRPLMN-1</p>
    ...    </list>
    ...    <p name="trackingAreaDN">${bts_distName}/TRACKINGAREA-200</p>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRPLMN
    [Documentation]    [PRIVATE]    create NRPLMN object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRPLMN-2
    ${new_MO}   Set Variable  <managedObject class="NRPLMN" distName="${bts_distName}/NRPLMN-2"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}    version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="mcc">311</p>
    ...    <p name="mnc">388</p>
    ...    <p name="mncLength">3</p>
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


Create NRPRIOACC_PROFILE-1
    [Documentation]    [PRIVATE]    create NRPRIOACC_PROFILE-1 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRPRIOACC_PROFILE-1
    ${new_MO}   Set Variable  <managedObject class="NRPRIOACC_PROFILE" distName="${bts_distName}/NRPRIOACC_PROFILE-1"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}    version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="arpPrioLevelHpaMax">4</p>
    ...    <p name="arpPrioLevelHpaMin">1</p>
    ...    <p name="arpPrioLevelMpsMax">8</p>
    ...    <p name="arpPrioLevelMpsMin">6</p>
    ...    <p name="nrPlmnIdx">1</p>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create NRREL base
    FOR    ${NRCELL}    ${lcrId}   IN
       ...    1            2
       ...    2            1
       Log To Console    Building object ${bts_distName}/NRCELL-${NRCELL}/NRREL-1 with lcrId=${lcrId}
       Create single NRREL   NRCELL=${NRCELL}    lcrId=${lcrId}    tc_type=base
    END


Create NRREL 2gnb
    [Documentation]    [PRIVATE]    create NRREL object in SCF
    ...       :Autor: Sylvia Schneider
    FOR     ${instance}   ${lcrId}   IN
    ...        2       1
    ...        3       2
           Create Single NRREL 2gnb    ${instance}   ${lcrId}   tc_type=2gnb
    END



Create Single NRREL
    [Documentation]    [PRIVATE]    create NRREL object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${NRCELL}    ${lcrId}  ${tc_type}

    ${cellIndividualSsbRsrpOffset_base}      Set Variable    0dB
    ${cellIndividualSsbRsrqOffset_base}      Set Variable    0dB
    ${cellIndividualSsbRsrpOffset_2gnb}      Set Variable    -2dB
    ${cellIndividualSsbRsrqOffset_2gnb}      Set Variable    -2dB

    ${new_MO}   Set Variable   <managedObject class="NRREL" distName="${bts_distName}/NRCELL-${NRCELL}/NRREL-1"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="cellIndividualSsbRsrpOffset">${cellIndividualSsbRsrpOffset_${tc_type}}</p>
    ...    <p name="cellIndividualSsbRsrqOffset">${cellIndividualSsbRsrqOffset_${tc_type}}</p>
    ...    <p name="gNbId">1</p>
    ...    <p name="gNbIdLength">22</p>
    ...    <p name="handoverAllowedSA">allowed</p>
    ...    <p name="handoverAllowedSARedCap">forbidden</p>
    ...    <p name="isRplCellForPSCell">false</p>
    ...    <p name="lcrId">${lcrId}</p>
    ...    <p name="nrDcAllowed">false</p>
    ...    <p name="removeNotAllowed">false</p>
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


Create Single NRREL force_HO
    [Documentation]    [PRIVATE]    create single NRREL force_HO object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${NRCELL_id}    ${NRREL_id}    ${gNbId}     ${lcrId}

    Log To Console    Building object ${bts_distName}/NRCELL-${NRCELL_id}/NRREL-${NRREL_id}
    ${new_MO}   Set Variable   <managedObject class="NRREL" distName="${bts_distName}/NRCELL-${NRCELL_id}/NRREL-${NRREL_id}"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="cellIndividualSsbRsrpOffset">-2dB</p>
    ...    <p name="cellIndividualSsbRsrqOffset">-2dB</p>
    ...    <p name="gNbId">${gNbId}</p>
    ...    <p name="gNbIdLength">22</p>
    ...    <p name="handoverAllowedSA">allowed</p>
    ...    <p name="handoverAllowedSARedCap">forbidden</p>
    ...    <p name="isRplCellForPSCell">false</p>
    ...    <p name="lcrId">${lcrId}</p>
    ...    <p name="nrDcAllowed">false</p>
    ...    <p name="removeNotAllowed">false</p>
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


Create NRREL force_HO
    [Documentation]    [PRIVATE]    create NRREL force_HO object in SCF
    ...       :Autor: Sylvia Schneider
    FOR    ${NRCELL_id}   ${NRREL_id}    ${gNbId}     ${lcrId}    IN
    ...    1              1              3            1
    ...    1              2              3            2
    ...    1              3              1            2
    ...    2              1              1            1
       Create Single NRREL force_HO     ${NRCELL_id}   ${NRREL_id}    ${gNbId}     ${lcrId}
    END


Create NRRELE
    [Documentation]    [PRIVATE]    create NRRELE object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${nrcell_id}=1
    Log To Console    Building object ${bts_distName}/NRCELL-${nrcell_id}/NRRELE-1
    ${new_MO}   Set Variable   <managedObject class="NRRELE" distName="${bts_distName}/NRCELL-${nrcell_id}/NRRELE-1"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="cellIndividualOffset">0dB</p>
    ...    <p name="eNodeBId">18</p>
    ...    <p name="eutranCellExcluded">false</p>
    ...    <p name="lcrId">1</p>
    ...    <p name="removeNotAllowed">false</p>
    ...    <list name="ecgiPlmn">
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


Create SNSSAI
    [Documentation]    [PRIVATE]    create SNSSAI object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/SNSSAI-2
    ${new_MO}   Set Variable   <managedObject class="SNSSAI" distName="${bts_distName}/SNSSAI-2"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="administrativeState">Unlocked</p>
    ...    <p name="sd">13714342</p>
    ...    <p name="sst">1</p>
    ...    <list name="nrPlmnDNList">
    ...    <p>MRBTS-1/NRBTS-1/NRPLMN-1</p>
    ...    <p>MRBTS-1/NRBTS-1/NRPLMN-2</p>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create TCE
    [Documentation]    [PRIVATE]    create TCE object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object MRBTS-1/MNL-1/TCEADM-1/TCE-1
    ${new_MO}   Set Variable   <managedObject class="TCE" distName="MRBTS-1/MNL-1/TCEADM-1/TCE-1"
    ${new_MO}   Catenate       SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.MNL_version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="certTypeForTlsAuth">RSA</p>
    ...    <p name="tceIdentifier">1</p>
    ...    <p name="tceIpAddress">${ip_trace}</p>
    ...    <p name="tcePortNumber">${port_trace}</p>
    ...    <p name="tlsEnabled">false</p>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create TCEADM
    [Documentation]    [PRIVATE]    create TCEADM object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object MRBTS-1/MNL-1/TCEADM-1
    ${new_MO}   Set Variable   <managedObject class="TCEADM" distName="MRBTS-1/MNL-1/TCEADM-1"
    ${new_MO}   Catenate     SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.MNL_version}" operation="create"/>
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create TRACKINGAREA
    [Documentation]    [PRIVATE]    create TRACKINGAREA object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object MRBTS-1/MNL-1/TCEADM-1/TCE-1
    ${new_MO}   Set Variable   <managedObject class="TRACKINGAREA" distName="${bts_distName}/TRACKINGAREA-200"
    ${new_MO}   Catenate       SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...   <p name="fiveGsTac">200</p>
    ...    <list name="snssaiList">
    ...    <item>
    ...    <p name="snssaiDN">${bts_distName}/SNSSAI-1</p>
    ...    </item>
    ...    <item>
    ...    <p name="snssaiDN">${bts_distName}/SNSSAI-2</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create Single XNLINK
    [Documentation]    [PRIVATE]    create single XNLINK object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${XNLINK_id}   ${cPlaneIpAddr}
    Log To Console    Building object ${bts_distName}/XNLINK-${XNLINK_id}
    ${new_MO}   Set Variable   <managedObject class="com.nokia.srbts.nrbts:XNLINK" distName="${bts_distName}/XNLINK-${XNLINK_id}"
    ${new_MO}   Catenate       SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="cPlaneIpAddr">${cPlaneIpAddr}</p>
    ...    <p name="cPlaneIpAddrCtrl">oamControlled</p>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData


Create Single XNLINK TMO
    [Documentation]    [PRIVATE]    create single XNLINK object in SCF TMO
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${XNLINK_id}   ${cPlaneIpAddr}
    Log To Console    Building object ${bts_distName}/XNLINK-${XNLINK_id}
    ${new_MO}   Set Variable   <managedObject class="com.nokia.srbts.nrbts:XNLINK" distName="${bts_distName}/XNLINK-${XNLINK_id}"
    ${new_MO}   Catenate       SEPARATOR=${SPACE}   ${new_MO}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="cPlaneIpAddr">${cPlaneIpAddr}</p>
    ...    <p name="cPlaneIpAddrCtrl">oamControlled</p>
    ...    <p name="localCuIpAddr">10.0.1.2</p>
    ...    </managedObject>
           ${new_MO}   Catenate     SEPARATOR=\n         ${new_MO}   ${line}
    END
    Add Element     ${scf_xml}     ${new_MO}           xpath=.//cmData



Create XNLINK
    [Documentation]    [PRIVATE]    create XNLINK object in SCF
    ...       :Autor: Sylvia Schneider
    Create Single XNLINK    XNLINK_id=1   cPlaneIpAddr=10.0.1.5


Create XNLINK 2gnb
    [Documentation]    [PRIVATE]    create XNLINK object in SCF
    ...       :Autor: Sylvia Schneider
    Create Single XNLINK    XNLINK_id=2   cPlaneIpAddr=10.0.1.6


Create XNLINK force_HO
    [Documentation]    [PRIVATE]    create XNLINK object in SCF
    ...       :Autor: Sylvia Schneider
    Create Single XNLINK    XNLINK_id=1   cPlaneIpAddr=10.0.1.3
    Create Single XNLINK    XNLINK_id=2   cPlaneIpAddr=10.0.1.6


Create XNLINK force_HO TMO
    [Documentation]    [PRIVATE]    create XNLINK object in SCF TMO
    ...       :Autor: Sylvia Schneider
    Create Single XNLINK TMO    XNLINK_id=2   cPlaneIpAddr=10.0.1.3
    Create Single XNLINK TMO    XNLINK_id=3   cPlaneIpAddr=10.0.1.6
