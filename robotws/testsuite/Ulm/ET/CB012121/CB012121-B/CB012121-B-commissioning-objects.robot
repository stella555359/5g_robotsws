*** Settings ***
Documentation   This is a keyword file for CB012121-B, part commissioning-objects
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Keywords ***


create new objects B-B8
    [Documentation]    [PRIVATE]    create objects B-B8 in SCF
    ...       :Autor: Sylvia Schneider
    FOR    ${obj}    IN
    ...    NRADJECELL
    ...    NRADJGNB
    ...    NRFSOPGRP
    ...    NRREL_B-B8
    ...    NRRELE
    ...    NRHOIF_B-B8
    ...    NRHOIR_B-B8
    ...    NRMOPRMA_SA_B-B8
    ...    NRMOPR_SA_B-B8
    ...    NRADJNRCELL
    ...    XNLINK
       run keyword   Create ${obj}
    END


create new objects B-B17
    [Documentation]    [PRIVATE]    create objects B-B17 in SCF
    ...       :Autor: Sylvia Schneider
    FOR    ${obj}    IN
    ...    NRADJECELL
    ...    NRADJGNB
    ...    NRFSOPGRP
    ...    NRREL_B-B8
    ...    NRRELE
    ...    NRHOIF_B-B17
    ...    NRHOIR_B-B17
    ...    NRMOPRMA_SA_B-B8
    ...    NRMOPR_SA_B-B8
    ...    NRADJNRCELL
    ...    NRCTRLTS
    ...    NRMTRACECU
    ...    TCEADM
    ...    TCE
    ...    XNLINK
       run keyword   Create ${obj}
    END


Create NRADJECELL
    [Documentation]    [PRIVATE]    create NRADJECELL object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRADJECELL-1
    ${NRADJECELL}   set variable   <managedObject class="NRADJECELL" distName="${bts_distName}/NRADJECELL-1"
    ${NRADJECELL}   Catenate     SEPARATOR=${SPACE}   ${NRADJECELL}   version="${SCF.version}" operation="create">
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
           ${NRADJECELL}   Catenate     SEPARATOR=\n         ${NRADJECELL}   ${line}
    END
    Add Element     ${scf_xml}     ${NRADJECELL}           xpath=.//cmData


Create NRADJGNB
    [Documentation]    [PRIVATE]    create NRADJGNB object in SCF
    ...       :Autor: Sylvia Schneider
    FOR   ${NRADJGNB_id}     ${gNodeBId}   ${xnLinkRef}   IN
    ...   1                  18            1
    ...   2                  38            2
    ...   3                  39            3
       Create single NRADJGNB    ${NRADJGNB_id}     ${gNodeBId}   ${xnLinkRef}
    END


Create single NRADJGNB
    [Documentation]    [PRIVATE]    create single NRADJGNB object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]      ${NRADJGNB_id}     ${gNodeBId}   ${xnLinkRef}
    Log To Console    Building object ${bts_distName}/NRADJGNB-${NRADJGNB_id}
    ${NRADJGNB}    set variable  <managedObject class="NRADJGNB" distName="${bts_distName}/NRADJGNB-${NRADJGNB_id}"
    ${NRADJGNB}   Catenate     SEPARATOR=${SPACE}   ${NRADJGNB}    version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="administrativeState">Unlocked</p>
    ...    <p name="gNbIdLength">28</p>
    ...    <p name="gNodeBId">${gNodeBId}</p>
    ...    <p name="gNodeBIdCtrl">oamControlled</p>
    ...    <p name="xnLinkRef">${xnLinkRef}</p>
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


Create NRFSOPGRP
    [Documentation]    [PRIVATE]    create NRFSOPGRP object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRFSOPGRP-1
    ${new_obj}    set variable  <managedObject class="NRFSOPGRP" distName="${bts_distName}/NRFSOPGRP-1"
    ${new_obj}   Catenate     SEPARATOR=${SPACE}   ${new_obj}    version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="cellSwitchOffType">TimeWindow</p>
    ...    <list name="timeWindowCellSwitchOffList">
    ...    <item>
    ...    <p name="fsoDayOfWeek">Sun</p>
    ...    <p name="fsoDuration">1</p>
    ...    <p name="fsoStartHour">3</p>
    ...    <p name="fsoStartMinute">0</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${new_obj}   Catenate     SEPARATOR=\n         ${new_obj}   ${line}
    END
    Add Element     ${scf_xml}     ${new_obj}           xpath=.//cmData


Create NRMEASCFG_IF
    [Documentation]    [PRIVATE]    create NRMEASCFG_IF object in SCF
    ...       :Autor: Sylvia Schneider
    FOR   ${NRMEASCFG_IF_id}    ${freqBandIndicatorNR}   ${ssbFrequency}    IN
    ...   1                     78                       648864
    ...   2                     41                       511470
    ...   3                     41                       529470
       Create single NRMEASCFG_IF    ${NRMEASCFG_IF_id}    ${freqBandIndicatorNR}   ${ssbFrequency}
    END


Create single NRMEASCFG_IF
    [Documentation]    [PRIVATE]    create single NRMEASCFG_IF object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${NRMEASCFG_IF_id}    ${freqBandIndicatorNR}   ${ssbFrequency}
    Log To Console    Building object ${bts_distName}/NRMEASCFG_IF-${NRMEASCFG_IF_id}
    ${new_obj}    set variable  <managedObject class="NRMEASCFG_IF" distName="${bts_distName}/NRMEASCFG_IF-${NRMEASCFG_IF_id}"
    ${new_obj}   Catenate     SEPARATOR=${SPACE}   ${new_obj}    version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="a3MeasEnabled">rsrpCombined</p>
    ...    <p name="a5MeasEnabled">rsrpCombined</p>
    ...    <p name="freqBandIndicatorNR">${freqBandIndicatorNR}</p>
    ...    <p name="ssbFrequency">${ssbFrequency}</p>
    ...    </managedObject>
           ${new_obj}   Catenate     SEPARATOR=\n         ${new_obj}   ${line}
    END
    Add Element     ${scf_xml}     ${new_obj}           xpath=.//cmData


Create NRMEASCFG_IR
    [Documentation]    [PRIVATE]    create NRMEASCFG_IR object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRMEASCFG_IR-1
    ${new_obj}    set variable  <managedObject class="NRMEASCFG_IR" distName="${bts_distName}/NRMEASCFG_IR-1"
    ${new_obj}   Catenate     SEPARATOR=${SPACE}   ${new_obj}    version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="b1MeasRedirectEnabled">none</p>
    ...    <p name="b2MeashoEnabled">rsrpCombined</p>
    ...    <p name="earfcnValue">1</p>
    ...    </managedObject>
           ${new_obj}   Catenate     SEPARATOR=\n         ${new_obj}   ${line}
    END
    Add Element     ${scf_xml}     ${new_obj}           xpath=.//cmData


Create NRREL_B-B8
    [Documentation]    [PRIVATE]    create NRREL object in SCF
    ...       :Autor: Sylvia Schneider
    FOR    ${NRCELL_id}    ${NRREL_id}   ${cellIndividualSsbOffset}   ${gNbId}   ${lcrId}  ${gNbIdLength}   IN
       ...    1            1             0dB                          1          2         22
       ...    1            2             -2dB                         38         1         28
       ...    1            3             -2dB                         38         2         28
       ...    1            4             -2dB                         39         1         28
       ...    1            5             -2dB                         39         2         28
       ...    1            6             0dB                          1          3         22
       ...    1            7             0dB                          1          4         22
       ...    2            1             0dB                          1          1         22
       ...    2            2             0dB                          1          3         22
       ...    2            3             0dB                          1          4         22
       ...    2            4             -2dB                         38         1         28
       Create single NRREL   ${NRCELL_id}    ${NRREL_id}   ${cellIndividualSsbOffset}   ${gNbId}   ${lcrId}  ${gNbIdLength}
    END


Create single NRREL
    [Documentation]    [PRIVATE]    create NRREL object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${NRCELL_id}    ${NRREL_id}   ${cellIndividualSsbOffset}   ${gNbId}   ${lcrId}     ${gNbIdLength}
    Log To Console    Building object ${bts_distName}/NRCELL-${NRCELL_id}/NRREL-${NRREL_id}
    ${NRREL}   set variable   <managedObject class="NRREL" distName="${bts_distName}/NRCELL-${NRCELL_id}/NRREL-${NRREL_id}"
    ${NRREL}   Catenate     SEPARATOR=${SPACE}   ${NRREL}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="cellIndividualSsbRsrpOffset">${cellIndividualSsbOffset}</p>
    ...    <p name="cellIndividualSsbRsrqOffset">${cellIndividualSsbOffset}</p>
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
    ...    <p name="mcc">${SCF.mcc}</p>
    ...    <p name="mnc">${SCF.mnc}</p>
    ...    <p name="mncLength">3</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${NRREL}   Catenate     SEPARATOR=\n         ${NRREL}   ${line}
    END
    Add Element     ${scf_xml}     ${NRREL}           xpath=.//cmData


Create NRRELE
    [Documentation]    [PRIVATE]    create NRRELE object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRCELL-1/NRRELE-1
    ${NRRELE}   set variable   <managedObject class="NRRELE" distName="${bts_distName}/NRCELL-1/NRRELE-1"
    ${NRRELE}   Catenate     SEPARATOR=${SPACE}   ${NRRELE}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="cellIndividualOffset">0dB</p>
    ...    <p name="eNodeBId">18</p>
    ...    <p name="removeNotAllowed">false</p>
    ...    <p name="eutranCellExcluded">false</p>
    ...    <p name="lcrId">1</p>
    ...    <list name="ecgiPlmn">
    ...    <item>
    ...    <p name="mcc">${SCF.mcc}</p>
    ...    <p name="mnc">${SCF.mnc}</p>
    ...    <p name="mncLength">3</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${NRRELE}   Catenate     SEPARATOR=\n         ${NRRELE}   ${line}
    END
    Add Element     ${scf_xml}     ${NRRELE}           xpath=.//cmData


Create NRHOIR_B-B8
    [Documentation]    [PRIVATE]    create NRHOIR object with b2Priority in SCF
    ...       :Autor: Sylvia Schneider
    Create single NRHOIR    b2Priority=88


Create NRHOIR_B-B17
    [Documentation]    [PRIVATE]    create NRHOIR object with b2Priority in SCF
    ...       :Autor: Sylvia Schneider
    Create single NRHOIR    b2Priority=4


Create single NRHOIR
    [Documentation]    [PRIVATE]    create single NRHOIR object with b2Priority in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${b2Priority}
    Log To Console    Building object ${bts_distName}/NRHOIR-1
    ${NRHOIR}   set variable   <managedObject class="NRHOIR" distName="${bts_distName}/NRHOIR-1"
    ${NRHOIR}   Catenate     SEPARATOR=${SPACE}   ${NRHOIR}   version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="allowedMeasBandwidth">mbw50</p>
    ...    <p name="b1MeasRedirectEnabled">none</p>
    ...    <p name="b2MeashoEnabled">rsrq</p>
    ...    <p name="b2Priority">${b2Priority}</p>
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
           ${NRHOIR}   Catenate     SEPARATOR=\n         ${NRHOIR}   ${line}
    END
    Add Element     ${scf_xml}     ${NRHOIR}           xpath=.//cmData


Create NRPLMNSET_SA
    Create single NRPLMNSET_SA    NRCELL=1
    Create single NRPLMNSET_SA    NRCELL=2


Create single NRPLMNSET_SA
    [Documentation]    [PRIVATE]    create NRPLMNSET_SA object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${NRCELL}
    Log To Console    Building object ${bts_distName}/NRCELL-${NRCELL}/NRPLMNSET_SA-1
    ${NRPLMNSET_SA}
    ...    set variable  <managedObject class="com.nokia.srbts.nrbts:NRPLMNSET_SA" distName="${bts_distName}/NRCELL-${NRCELL}/NRPLMNSET_SA-1"
    ${NRPLMNSET_SA}   Catenate     SEPARATOR=${SPACE}   ${NRPLMNSET_SA}    version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <list name="nrPlmnDNList">
    ...    <p>${bts_distName}/NRPLMN-1</p>
    ...    </list>
    ...    <p name="trackingAreaDN">${bts_distName}/TRACKINGAREA-200</p>
    ...    </managedObject>
           ${NRPLMNSET_SA}   Catenate     SEPARATOR=\n         ${NRPLMNSET_SA}   ${line}
    END
    Add Element     ${scf_xml}     ${NRPLMNSET_SA}           xpath=.//cmData


Create single NRMOPRMA_SA
    [Documentation]    [PRIVATE]    create single NRMOPRMA_SA-1 object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${NRMOPRMA_SA_id}   ${mobilityProfilePriority}   ${nrMoPrSaDN}    ${rfspIndex}
    Log To Console    Building object ${bts_distName}/NRMOPRMA_SA-${NRMOPRMA_SA_id}
    ${NRMOPRMA_SA}    set variable  <managedObject class="NRMOPRMA_SA" distName="${bts_distName}/NRMOPRMA_SA-${NRMOPRMA_SA_id}"
    ${NRMOPRMA_SA}   Catenate     SEPARATOR=${SPACE}   ${NRMOPRMA_SA}    version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="mobilityProfilePriority">${mobilityProfilePriority}</p>
    ...    <p name="nrMoPrSaDN">${bts_distName}/NRMOPR_SA-${nrMoPrSaDN}</p>
    ...    <p name="rfspIndex">${rfspIndex}</p>
    ...    <list name="nrPlmnDNList">
    ...    <p>${bts_distName}/NRPLMN-1</p>
    ...    </list>
    ...    </managedObject>
           ${NRMOPRMA_SA}   Catenate     SEPARATOR=\n         ${NRMOPRMA_SA}   ${line}
    END
    Add Element     ${scf_xml}     ${NRMOPRMA_SA}           xpath=.//cmData


Create NRMOPRMA_SA_B-B8
    [Documentation]    [PRIVATE]    create NRMOPRMA_SA object in SCF
    ...       :Autor: Sylvia Schneider
    Create single NRMOPRMA_SA   NRMOPRMA_SA_id=1   mobilityProfilePriority=1   nrMoPrSaDN=2    rfspIndex=12


Create NRMOPR_SA_B-B8
    [Documentation]    [PRIVATE]    re-create NRMOPRMA_SA-2 object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Update object ${bts_distName}/NRMOPR_SA-2
    ${NRMOPR_SA}    set variable  <managedObject class="NRMOPR_SA" distName="${bts_distName}/NRMOPR_SA-2"
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


Create NRADJNRCELL
    [Documentation]    [PRIVATE]    create NRADJNRCELL object in SCF
    ...       :Autor: Sylvia Schneider
    FOR     ${instance}   ${fiveGsTac}   ${freqBandIndicatorNR}   ${gNbId}   ${lcrId}    ${nrarfcn}   ${physCellId}  ${ssbFreq}  IN
    ...        1            100          78                       38         1           636666       48             636576
    ...        2            788          78                       38         2           648000       49             648864
    ...        3            100          41                       39         1           510000       54             511470
    ...        4            100          41                       39         2           527000       55             529470
        Create single NRADJNRCELL  ${instance}  ${fiveGsTac}  ${freqBandIndicatorNR}  ${gNbId}  ${lcrId}  ${nrarfcn}  ${physCellId}  ${ssbFreq}
    END


Create single NRADJNRCELL
    [Documentation]    [PRIVATE]    create single NRADJNRCELL object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${instance}   ${fiveGsTac}   ${freqBandIndicatorNR}   ${gNbId}   ${lcrId}   ${nrarfcn}   ${physCellId}   ${ssbFreq}
    Log To Console    Building object ${bts_distName}/NRADJNRCELL-${instance}
    ${NRADJNRCELL}    set variable  <managedObject class="NRADJNRCELL" distName="${bts_distName}/NRADJNRCELL-${instance}"
    ${NRADJNRCELL}   Catenate     SEPARATOR=${SPACE}   ${NRADJNRCELL}    version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="cellDepType">SA</p>
    ...    <p name="cellReservedForOperatorUse">notReserved</p>
    ...    <p name="fiveGsTac">${fiveGsTac}</p>
    ...    <p name="freqBandIndicatorNR">${freqBandIndicatorNR}</p>
    ...    <p name="gNbId">${gNbId}</p>
    ...    <p name="gNbIdLength">28</p>
    ...    <p name="lcrId">${lcrId}</p>
    ...    <p name="nrarfcn">${nrarfcn}</p>
    ...    <p name="physCellId">${physCellId}</p>
    ...    <p name="ssbFrequency">${ssbFreq}</p>
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


Create NRHOIF_B-B8
    [Documentation]    [PRIVATE]    create NRHOIF object in SCF
    ...       :Autor: Sylvia Schneider

    FOR     ${cell_id}   ${NRHOIF_id}   ${a3MeasEnabled}  ${a3a5Priority}   ${freqBandIndicatorNR}   ${ssbFrequency}   IN
    ...     1            1              rsrp              40                78                       648864
    ...     1            2              rsrp              30                41                       511470
    ...     1            3              rsrp              20                41                       529470
    ...     2            1              rsrp              51                78                       648864
    ...     2            2              rsrp              4                 41                       511470
    ...     2            3              rsrp              100               41                       529470
      Create single NRHOIF_B    ${cell_id}  ${NRHOIF_id}  ${a3MeasEnabled}  ${a3a5Priority}   ${freqBandIndicatorNR}   ${ssbFrequency}
    END


Create NRHOIF_B-B17
    [Documentation]    [PRIVATE]    create NRHOIF object in SCF
    ...       :Autor: Sylvia Schneider

    FOR     ${cell_id}   ${NRHOIF_id}   ${a3MeasEnabled}  ${a3a5Priority}   ${freqBandIndicatorNR}   ${ssbFrequency}   IN
    ...     1            1              rsrpCombined      1                 78                       648864
    ...     1            2              rsrpCombined      2                 41                       511470
    ...     1            3              rsrpCombined      3                 41                       529470
    ...     2            1              rsrpCombined      5                 78                       648864
    ...     2            2              rsrpCombined      6                 41                       511470
    ...     2            3              rsrpCombined      7                 41                       529470
      Create single NRHOIF_B    ${cell_id}  ${NRHOIF_id}  ${a3MeasEnabled}  ${a3a5Priority}   ${freqBandIndicatorNR}   ${ssbFrequency}
    END


Create single NRHOIF_B
    [Documentation]    [PRIVATE]    create single NRHOIF object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]  ${cell_id}  ${NRHOIF_id}  ${a3MeasEnabled}   ${a3a5Priority}  ${freqBandIndicatorNR}  ${ssbFrequency}
    Log To Console    Building object ${bts_distName}/NRCELL-${cell_id}/NRHOIF-${NRHOIF_id}
    ${new_obj}    set variable  <managedObject class="NRHOIF" distName="${bts_distName}/NRCELL-${cell_id}/NRHOIF-${NRHOIF_id}"
    ${new_obj}   Catenate     SEPARATOR=${SPACE}   ${new_obj}    version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="a1BasedPCellSwitchEnabled">false</p>
    ...    <p name="a2BasedPCellSwitchEnabled">false</p>
    ...    <p name="a3MeasEnabled">${a3MeasEnabled}</p>
    ...    <p name="a3a5Priority">${a3a5Priority}</p>
    ...    <p name="a4MeasEnDcSteeringEnabled">none</p>
    ...    <p name="a4MeasHigherPrioFreqEnabled">none</p>
    ...    <p name="a4MeasNrDcEnabled">none</p>
    ...    <p name="a4MeasSCellAddEnabled">none</p>
    ...    <p name="a5MeasEnabled">rsrpCombined</p>
    ...    <p name="cellDepType">SA</p>
    ...    <p name="deriveSsbIndexFromCell">true</p>
    ...    <p name="freqBandIndicatorNR">${freqBandIndicatorNR}</p>
    ...    <p name="ifhoSsbScs">30 KHz</p>
    ...    <p name="ifhoSsbSmtcDuration">sf5</p>
    ...    <p name="ifhoSsbSmtcPeriodicity">sf20</p>
    ...    <p name="numberOfTransmittedSsBlocks">1 beam</p>
    ...    <p name="scs">30 KHz</p>
    ...    <p name="ssBurstSetPeriod">20</p>
    ...    <p name="ssbFrequency">${ssbFrequency}</p>
    ...    <list name="a3MeasSsbRsrp">
    ...    <item>
    ...    <p name="a3HysteresisSsbRsrp">0</p>
    ...    <p name="a3OffsetSsbRsrp">6</p>
    ...    <p name="a3TimeToTriggerSsbRsrp">ms100</p>
    ...    </item>
    ...    </list>
    ...    <list name="a3MeasSsbRsrq">
    ...    <item>
    ...    <p name="a3HysteresisSsbRsrq">0</p>
    ...    <p name="a3OffsetSsbRsrq">6</p>
    ...    <p name="a3TimeToTriggerSsbRsrq">ms100</p>
    ...    </item>
    ...    </list>
    ...    <list name="a5MeasSsbRsrp">
    ...    <item>
    ...    <p name="a5HysteresisSsbRsrp">0</p>
    ...    <p name="a5Threshold1SsbRsrp">70</p>
    ...    <p name="a5Threshold2SsbRsrp">60</p>
    ...    <p name="a5TimeToTriggerSsbRsrp">ms100</p>
    ...    </item>
    ...    </list>
    ...    <list name="a5MeasSsbRsrq">
    ...    <item>
    ...    <p name="a5HysteresisSsbRsrq">0</p>
    ...    <p name="a5Threshold1SsbRsrq">70</p>
    ...    <p name="a5Threshold2SsbRsrq">67</p>
    ...    <p name="a5TimeToTriggerSsbRsrq">ms100</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${new_obj}   Catenate     SEPARATOR=\n         ${new_obj}   ${line}
    END
    Add Element     ${scf_xml}     ${new_obj}           xpath=.//cmData


Create NRCTRLTS
    [Documentation]    [PRIVATE]    Create NRCTRLTS object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object MRBTS-1/NRBTS-1/NRCTRLTS-1
    ${new_obj}    set variable
    ...    <managedObject class="com.nokia.srbts.mnl:NRCTRLTS" distName="${bts_distName}/NRCTRLTS-1" version="${SCF.version}" operation="create"/>
    Add Element     ${scf_xml}     ${new_obj}           xpath=.//cmData


Create NRMTRACECU
    [Documentation]    [PRIVATE]    create NRMTRACECU object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRCTRLTS-1/NRMTRACECU-1
    ${new_obj}    set variable  <managedObject class="NRMTRACECU" distName="${bts_distName}/NRCTRLTS-1/NRMTRACECU-1"
    ${new_obj}   Catenate     SEPARATOR=${SPACE}   ${new_obj}    version="${SCF.version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="actCellTraceReportingCU">false</p>
    ...    <p name="actPCMDReporting">true</p>
    ...    <p name="cellMaxActiveUEsTraced">100</p>
    ...    <p name="jobType">TraceOnly</p>
    ...    <p name="nrTceIdentifier">1</p>
    ...    <p name="scope">allResources</p>
    ...    <p name="traceE1Setting">none</p>
    ...    <p name="traceF1Setting">none</p>
    ...    <p name="traceNGAPSetting">none</p>
    ...    <p name="traceNRRRCSetting">none</p>
    ...    <p name="traceX2Setting">none</p>
    ...    <p name="traceXNSetting">none</p>
    ...    <list name="nrRanTraceReference">
    ...    <item>
    ...    <p name="mcc">311</p>
    ...    <p name="mnc">489</p>
    ...    <p name="mncLength">3</p>
    ...    <p name="traceId">0</p>
    ...    </item>
    ...    </list>
    ...    <list name="tracePCMDSetting">
    ...    <p>all</p>
    ...    </list>
    ...    </managedObject>
           ${new_obj}   Catenate     SEPARATOR=\n         ${new_obj}   ${line}
    END
    Add Element     ${scf_xml}     ${new_obj}           xpath=.//cmData


Create TCEADM
    [Documentation]    [PRIVATE]    Create TCEADM object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object MRBTS-1/MNL-1/TCEADM-1
    ${new_obj}    set variable
    ...    <managedObject class="TCEADM" distName="MRBTS-1/MNL-1/TCEADM-1" version="${SCF.MNL_version}" operation="create"/>
    Add Element     ${scf_xml}     ${new_obj}           xpath=.//cmData


Create TCE
    [Documentation]    [PRIVATE]    Create TCE object in SCF
    ...       :Autor: Sylvia Schneider
    ${new_obj}    set variable  <managedObject class="TCE" distName="MRBTS-1/MNL-1/TCEADM-1/TCE-1"
    ${new_obj}   Catenate     SEPARATOR=${SPACE}   ${new_obj}    version="${SCF.MNL_version}" operation="create">
    FOR     ${line}   IN
    ...    <p name="certTypeForTlsAuth">RSA</p>
    ...    <p name="tceIdentifier">1</p>
    ...    <p name="tceIpAddress">10.0.1.1</p>
    ...    <p name="tcePortNumber">49151</p>
    ...    <p name="tlsEnabled">false</p>
    ...    </managedObject>
           ${new_obj}   Catenate     SEPARATOR=\n         ${new_obj}   ${line}
    END
    Add Element     ${scf_xml}     ${new_obj}           xpath=.//cmData


Create XNLINK
    [Documentation]    [PRIVATE]    create XNLINK object in SCF
    ...       :Autor: Sylvia Schneider
    FOR    ${xnlink_id}    ${cPlaneIpAddr}    IN
    ...    1               10.0.1.5
    ...    2               10.0.1.6
    ...    3               10.0.1.8
       Log To Console    Building object ${bts_distName}/XNLINK-${xnlink_id}
       ${XNLINK}   set variable   <managedObject class="com.nokia.srbts.nrbts:XNLINK" distName="${bts_distName}/XNLINK-${xnlink_id}"
       ${XNLINK}   catenate       SEPARATOR=${SPACE}   ${XNLINK}   version="${SCF.version}" operation="create">
       ${XNLINK}   catenate       SEPARATOR=\n         ${XNLINK}    <p name="cPlaneIpAddr">${cPlaneIpAddr}</p>
       ${XNLINK}   catenate       SEPARATOR=\n         ${XNLINK}    <p name="cPlaneIpAddrCtrl">oamControlled</p>
       ${XNLINK}   catenate       SEPARATOR=\n         ${XNLINK}    </managedObject>
       Add Element     ${scf_xml}     ${XNLINK}           xpath=.//cmData
    END
