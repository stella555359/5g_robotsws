*** Settings ***
Documentation
...    author: Ulm SQD 65
...    Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...    Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
...    Description:

*** Variables ***
${NRCELL-1.nrarfcn_gscn}         636576   # gscn: 7880

#TCE-1
${TCE_PORT_NUMBER}          49151

&{PLMN}=                mcc=311
...                     mnc=489
...                     mncLength=3

#NRMTRACECU-1
&{nrRanTraceReference}      &{PLMN}  traceId=1
@{tracePCMDSetting}     all


#NRHOIF-1
${freqBandIndicatorNR}=      to be fetched in suite setup
&{A3MEASSSBRSRP}=      a3HysteresisSsbRsrp=0
...                    a3OffsetSsbRsrp=3
...                    a3TimeToTriggerSsbRsrp=ms64
&{A5MEASSSBRSRP}=      a5HysteresisSsbRsrp=10
...                    a5Threshold1SsbRsrp=70
...                    a5Threshold2SsbRsrp=40
...                    a5TimeToTriggerSsbRsrp=ms5120
&{NRHOIF_1}=
...                    a1BasedPCellSwitchEnabled=false
...                    a2BasedPCellSwitchEnabled=false
...                    a3MeasEnabled=rsrp
...                    a4MeasEnDcSteeringEnabled=none
...                    a4MeasHigherPrioFreqEnabled=none
...                    a5MeasEnabled=rsrp
...                    cellDepType=SA
...                    freqBandIndicatorNR=${freqBandIndicatorNR}
...                    ifhoSsbScs=30 KHz
...                    ifhoSsbSmtcDuration=sf3
...                    ifhoSsbSmtcPeriodicity=sf10
...                    numberOfTransmittedSsBlocks=1 beam
...                    scs=30 KHz
...                    ssBurstSetPeriod=20
...                    ssbFrequency=633408
...                    a4MeasNrDcEnabled=none

*** Keywords ***

Set Element
    [Documentation]    modify parameter if exists, otherwise add it
    [Arguments]      ${dist_name}   ${p_name}   ${value}
    ${element_exist}=         scf.Is Element In Object  dist_name=${dist_name}    p_name=${p_name}
    IF            ${element_exist}
    ...                       scf.Modify Scf Element    dist_name=${dist_name}    p_name=${p_name}     value=${value}
    ...         ELSE
    ...                       scf.Add Element To Scf    dist_name=${dist_name}    p_name=${p_name}     value=${value}

Remove Element
    [Documentation]   removes element if exists
    [Arguments]      ${dist_name}   ${p_name}
    ${element_exist}=         scf.Is Element In Object       dist_name=${dist_name}    p_name=${p_name}
    IF            ${element_exist}
    ...                       scf.Remove Element From Scf    dist_name=${dist_name}    p_name=${p_name}

Set New List
    [Documentation]     if exists, otherwise add it
    [Arguments]      ${dist_name}   ${list_name}
    ${list_exist}=            scf.Is List In Object  dist_name=${dist_name}     list_name=${list_name}
    IF            ${list_exist}==True    scf.Remove List From Scf  dist_name=${dist_name}   list_name=${list_name}
    scf.Add List To Scf       dist_name=${dist_name}    list_name=${list_name}

Set Object
    [Arguments]      ${class_name}   ${dist_name}   ${version}=${NIDD_VERSION}
    ${mo_exist}=              scf.Is Object In Scf      dist_name=${dist_name}
    IF            ${mo_exist}               scf.Remove Mo With Descendant Mos  dist_name=${dist_name}
    scf.Add Object To Scf     class_name=${class_name}  dist_name=${dist_name}             version=${version}

Remove Object
    [Arguments]               ${dist_name}
    ${mo_exist}=              scf.Is Object In Scf      dist_name=${dist_name}
    IF            ${mo_exist}               scf.Remove Mo With Descendant Mos  dist_name=${dist_name}


Add NRHOIF
    [Arguments]      ${cell_id}=1  ${id}=1
    ${dist_name}=    Set Variable    NRBTS-1/NRCELL-${cell_id}/NRHOIF-${id}
    ${mo_exist}=    scf.Is Object In Scf    dist_name=${dist_name}
    IF    ${mo_exist}   RETURN
    Set Object     dist_name=${dist_name}   class_name=NRHOIF                   version=${NIDD_VERSION}

    FOR   ${p_name}                         ${value}      IN
    ...   a1BasedPCellSwitchEnabled         false
    ...   a2BasedPCellSwitchEnabled         false
    ...   a3MeasEnabled                     rsrp
    ...   a4MeasEnDcSteeringEnabled         none
    ...   a4MeasHigherPrioFreqEnabled       none
    ...   a5MeasEnabled                     rsrp
    ...   cellDepType                       SA
    ...   freqBandIndicatorNR               ${freqBandIndicatorNR}
    ...   ifhoSsbScs                        30 KHz
    ...   ifhoSsbSmtcDuration               sf3
    ...   ifhoSsbSmtcPeriodicity            sf10
    ...   numberOfTransmittedSsBlocks       1 beam
    ...   scs                               30 KHz
    ...   ssBurstSetPeriod                  20
    ...   ssbFrequency                      633408
    ...   a4MeasNrDcEnabled                 none
    ...   a4MeasSCellAddEnabled             none
          Set Element   ${dist_name}  ${p_name}  ${value}
    END

    Set New List       dist_name=${dist_name}   list_name=a3MeasSsbRsrp
    scf.Add Item To List      dist_name=${dist_name}   list_name=a3MeasSsbRsrp   elements=${a3MeasSsbRsrp}
    Set New List       dist_name=${dist_name}   list_name=a5MeasSsbRsrp
    scf.Add Item To List      dist_name=${dist_name}   list_name=a5MeasSsbRsrp   elements=${a5MeasSsbRsrp}


Add A1MeashoSsbRsrp To Cell
    [Arguments]      ${dist_name}
    ${list_elements}=         Create Dictionary         a1HysteresishoSsbRsrp         0
    ...                                                 a1ThresholdhoSsbRsrp          60
    ...                                                 a1TimeToTriggerhoSsbRsrp      ms480
    Set New List       dist_name=${dist_name}    list_name=a1MeashoSsbRsrp
    scf.Add Item To List      dist_name=${dist_name}    list_name=a1MeashoSsbRsrp     elements=${list_elements}

Add A1MeashoSsbRsrq To Cell
    [Arguments]      ${dist_name}
    ${list_elements}=         Create Dictionary         a1HysteresishoSsbRsrq         0
    ...                                                 a1ThresholdhoSsbRsrq          63
    ...                                                 a1TimeToTriggerhoSsbRsrq      ms480
    Set New List       dist_name=${dist_name}    list_name=a1MeashoSsbRsrq
    scf.Add Item To List      dist_name=${dist_name}    list_name=a1MeashoSsbRsrq     elements=${list_elements}

Add A2MeashoSsbRsrp To Cell
    [Arguments]      ${dist_name}
    ${list_elements}=         Create Dictionary         a2HysteresishoSsbRsrp         0
    ...                                                 a2ThresholdhoSsbRsrp          34
    ...                                                 a2TimeToTriggerhoSsbRsrp      ms480
    Set New List       dist_name=${dist_name}    list_name=a2MeashoSsbRsrp
    scf.Add Item To List      dist_name=${dist_name}    list_name=a2MeashoSsbRsrp     elements=${list_elements}

Add A2MeashoSsbRsrq To Cell
    [Arguments]      ${dist_name}
    ${list_elements}=         Create Dictionary         a2HysteresishoSsbRsrq         0
    ...                                                 a2ThresholdhoSsbRsrq          49
    ...                                                 a2TimeToTriggerhoSsbRsrq      ms480
    Set New List       dist_name=${dist_name}    list_name=a2MeashoSsbRsrq
    scf.Add Item To List      dist_name=${dist_name}    list_name=a2MeashoSsbRsrq     elements=${list_elements}

Add A2MeasRedirectSsbRsrp To Cell
    [Arguments]      ${dist_name}
    ${list_elements}=         Create Dictionary         a2HysteresisRedirectSsbRsrp     0
    ...                                                 a2ThresholdRedirectSsbRsrp      34
    ...                                                 a2TimeToTriggerRedirectSsbRsrp  ms480
    Set New List       dist_name=${dist_name}    list_name=a2MeasRedirectSsbRsrp
    scf.Add Item To List      dist_name=${dist_name}    list_name=a2MeasRedirectSsbRsrp   elements=${list_elements}

Add A2MeasRedirectSsbRsrq To Cell
    [Arguments]      ${dist_name}
    ${list_elements}=         Create Dictionary         a2HysteresisRedirectSsbRsrq     0
    ...                                                 a2ThresholdRedirectSsbRsrq      49
    ...                                                 a2TimeToTriggerRedirectSsbRsrq  ms480
    Set New List       dist_name=${dist_name}    list_name=a2MeasRedirectSsbRsrq
    scf.Add Item To List      dist_name=${dist_name}    list_name=a2MeasRedirectSsbRsrq   elements=${list_elements}

Add NRPLMNSET SA To Cell
    [Arguments]      ${dist_name}  ${trackingAreaDN}  ${nrPlmnDNList}
    Set Object       class_name=NRPLMNSET_SA      dist_name=${dist_name}
    Set Element      dist_name=${dist_name}       p_name=trackingAreaDN                   value=${trackingAreaDN}
    Set Element      dist_name=${dist_name}       p_name=cellReservedForOperatorUse       value=notReserved
    Set Element      dist_name=${dist_name}       p_name=cellReservedForOperatorUseUacAutoMax       value=notReserved
    Set New List     dist_name=${dist_name}       list_name=nrPlmnDNList
    scf.Add Elements To List     dist_name=${dist_name}         list_name=nrPlmnDNList    elements=${nrPlmnDNList}

Add NRPLMNSET NSA To Cell
    [Arguments]      ${dist_name}  ${configuredEpsTac}  ${nrPlmnDNList}
    Set Object       class_name=NRPLMNSET_NSA      dist_name=${dist_name}
    Set Element      dist_name=${dist_name}       p_name=configuredEpsTac                 value=${configuredEpsTac}
    Set Element      dist_name=${dist_name}       p_name=cellReservedForOperatorUse       value=notReserved
    Set New List     dist_name=${dist_name}       list_name=nrPlmnDNList
    scf.Add Elements To List     dist_name=${dist_name}         list_name=nrPlmnDNList    elements=${nrPlmnDNList}

# Cell trace & PCMD
Add Trace Control Entity
    [Arguments]    ${ip}=10.0.1.1   ${tceIdentifier}=1
    ${dist_name}=             Set Variable              MRBTS-1/MNL-1/TCEADM-1
    ${mo_exist}=              scf.Is Object In Scf      dist_name=${dist_name}
    IF            ${mo_exist}               scf.Remove Mo With Descendant Mos  dist_name=${dist_name}
#    ${class_name}=             Set Variable              TCEADM
    Set Object     class_name=TCEADM         dist_name=${dist_name}             version=${NIDD_VERSION}

    ${dist_name}=             Set Variable              MRBTS-1/MNL-1/TCEADM-1/TCE-1
    Set Object     class_name=TCE            dist_name=${dist_name}             version=${NIDD_VERSION}

    FOR   ${p_name}                         ${value}      IN
    ...   tceIdentifier                     ${tceIdentifier}
    ...   tceIpAddress                      ${ip}
    ...   tcePortNumber                     ${TCE_PORT_NUMBER}
    ...   tlsEnabled                        false
    ...   certTypeForTlsAuth                RSA
          Set Element   ${dist_name}  ${p_name}  ${value}
    END

Add Radio CU Trace Session
    [Arguments]    ${jobType}=TraceOnly  ${nrBtsId}=1
    ${dist_name}=     Set Variable              MRBTS-1/NRBTS-${nrBtsId}/NRCTRLTS-1
    ${mo_exist}=      scf.Is Object In Scf      dist_name=${dist_name}
    IF                ${mo_exist}               scf.Remove Mo With Descendant Mos  dist_name=${dist_name}
    Set Object        class_name=NRCTRLTS       dist_name=${dist_name}             version=${NIDD_VERSION}
    Add NRMTRACECU    jobType=${jobType}        nrBtsId=${nrBtsId}

Add NRMTRACECU
    [Arguments]    ${jobType}=TraceOnly  ${nrBtsId}=1
    ${dist_name}=  Set Variable              MRBTS-1/NRBTS-${nrBtsId}/NRCTRLTS-1/NRMTRACECU-1
    Set Object     class_name=NRMTRACECU     dist_name=${dist_name}             version=${NIDD_VERSION}

    FOR   ${p_name}                         ${value}      IN
    ...   actCellTraceReportingCU           true
    ...   actPCMDReporting                  true
    ...   cellMaxActiveUEsTraced            100
    ...   jobType                           ${jobType}
    ...   nrTceIdentifier                   ${nrBtsId}
    ...   scope                             allResources
    ...   traceNGAPSetting                  all
    ...   traceNRRRCSetting                 all
    ...   traceX2Setting                    all
    ...   traceXNSetting                    all
    ...   traceE1Setting                    all
    ...   traceF1Setting                    all
          Set Element   ${dist_name}  ${p_name}  ${value}
    END
    Set New List              dist_name=${dist_name}    list_name=nrRanTraceReference
    scf.Add Item To List      dist_name=${dist_name}    list_name=nrRanTraceReference   elements=${nrRanTraceReference}
    Set New List              dist_name=${dist_name}    list_name=tracePCMDSetting
    scf.Add Elements To List  dist_name=${dist_name}    list_name=tracePCMDSetting      elements=${tracePCMDSetting}
