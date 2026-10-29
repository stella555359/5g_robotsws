*** Settings ***
Documentation   This is a keyword file for 5GC000480-D, part commissioning 4 cell
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG'
#-------------------------------------------------------------------------------------------------------------
Library    ../../L2/libraries/tools.py    WITH NAME    tools
*** Keywords ***

Set Sw Release Version
    [Documentation]    [PRIVATE]    set sw release version from gnb sw version
    ...       :Autor: Sylvia Schneider
    @{gnb_sw_version_parts}   Split String    ${gnb_swVersion}    _
    Set Suite Variable    ${release}   ${gnb_sw_version_parts}[0]


Bring Tl onAir
    [Documentation]    [PRIVATE]    bring tl onAir
    ...       :Autor: Sylvia Schneider
    wts_ue.Kill WTS services
    gnb.Wait Until All DUs Up
    5GC000480DJ-keywords.Check All Radio Units Online
    Log To Console    start to bring tl on air without reboot
    ute_workarounds.Bring Airphone TL To On Air Status Without Reboot
    5GC000480DJ-wts.Setup 2nd X2link


Update And Activate SCF
    [Documentation]    [PRIVATE]    update SCF and activate on gNB
    ...       :Autor: Sylvia Schneider
    Set Sw Release Version
    Log To Console    \nupdate SCF and store in ${resultBaseDir}/SCFC_480D_strongCell.xml
    ${scf_xml}    Parse Xml    ${resultBaseDir}/SCFC_start.xml
    Set Suite Variable    ${scf_xml}
    Update Single Parameter Values
    Add Lists
    Update List a3MeasSsbRsrp NRCELL-1
    Create New Objects
    Save Xml     ${scf_xml}    ${resultBaseDir}/SCFC_480D_strongCell.xml
    ${oam_alias}    connect.Setup OAM Http Session    node_type=gnb  node_id=${0}
    Log To Console    activate ${resultBaseDir}/SCFC_480D_strongCell.xml started
    admin.Perform Commissioning
    ...    scf_file=${resultBaseDir}/SCFC_480D_strongCell.xml
    ...    skip_parameter_relation_errors=False
    ...    timeout=660
    ...    connection=${oam_alias}
    Log To Console    activate ${resultBaseDir}/SCFC_480D_strongCell.xml finished
    [Teardown]    Run Keyword And Ignore Error    connect.Teardown OAM Http Session    node_type=gnb  node_id=${0}


Update Single Parameter Values
    [Documentation]    [PRIVATE]    update single parameter values in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    updating single parameter values - started
    FOR    ${param}                             ${value}     IN
    ...    actIntraFreqInterGnbMobilityNSA3x    true
    ...    actIntraFreqIntraGnbMobilityNSA      true
    ...    srb3SupportEnabled                   false
    ...    nsaInactivityTimer                   7200
        Log To Console    set ${param}to value ${value}
        Set Element Text   ${scf_xml}    text=${value}    xpath=.//p[@name="${param}"]
    END

    FOR   ${NRCELL}   IN
    ...    managedObject[@distName\="${bts_distName}/NRCELL-1"]
    ...    managedObject[@distName\="${bts_distName}/NRCELL-2"]
    ...    managedObject[@distName\="${bts_distName}/NRCELL-3"]
    ...    managedObject[@distName\="${bts_distName}/NRCELL-4"]
        Log To Console    for ${NRCELL} set a3MeasEnabled to value rsrp, gscnOrSsPbchArfcn to value 7916, nrarfcn to value 640000
        Set Element Text   ${scf_xml}   text=rsrp      xpath=.//${NRCELL}/p[@name="a3MeasEnabled"]
        Set Element Text   ${scf_xml}   text=7916      xpath=.//${NRCELL}/p[@name="gscnOrSsPbchArfcn"]
        Set Element Text   ${scf_xml}   text=640000    xpath=.//${NRCELL}/p[@name="nrarfcn"]
    END

    Log To Console    set a3MeasEnabled to rsrp for NRCELL-11 and NRCELL-12
    Set Element Text   ${scf_xml}   text=rsrp      xpath=.//managedObject[@distName="${bts_distName}/NRCELL-11"]/p[@name="a3MeasEnabled"]
    Set Element Text   ${scf_xml}   text=rsrp      xpath=.//managedObject[@distName="${bts_distName}/NRCELL-12"]/p[@name="a3MeasEnabled"]

    Log To Console    set maxNumOfUsersPerCell to 1 for NRCELL-2 and NRCELL-3
    Set Element Text   ${scf_xml}   text=1  xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]/p[@name="maxNumOfUsersPerCell"]
    Set Element Text   ${scf_xml}   text=1  xpath=.//managedObject[@distName="${bts_distName}/NRCELL-3"]/p[@name="maxNumOfUsersPerCell"]

   FOR    ${param}    IN
   ...    reportingIntervalPm
   ...    miNrRacCu
   ...    miNrRacDu
       Log To Console    for counter set ${param} to value ${measurement_period_in_min}min
       Set Element Text   ${scf_xml}    text=${measurement_period_in_min}min      xpath=.//p[@name="${param}"]
    END

    ${sMeasConfigSsbRsrp}    Set Variable    <p name="sMeasConfigSsbRsrp">10</p>
    Log To Console    add "${sMeasConfigSsbRsrp}" to NRCELL-2 and NRCELL-4
    Add Element        ${scf_xml}     ${sMeasConfigSsbRsrp}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]
    Add Element        ${scf_xml}     ${sMeasConfigSsbRsrp}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-4"]


    FOR   ${NRIRFIM}   IN
    ...    managedObject[@distName\="${bts_distName}/NRSYSINFO_PROFILE-1/NRIRFIM-1"]
    ...    managedObject[@distName\="${bts_distName}/NRSYSINFO_PROFILE-2/NRIRFIM-1"]
    ...    managedObject[@distName\="${bts_distName}/NRSYSINFO_PROFILE-3/NRIRFIM-1"]
    ...    managedObject[@distName\="${bts_distName}/NRSYSINFO_PROFILE-4/NRIRFIM-1"]
       Log To Console    Set dlCarrierFreq in ${NRIRFIM} to value 640000
       Set Element Text   ${scf_xml}    text=640000    xpath=.//${NRIRFIM}/p[@name="dlCarrierFreq"]
    END

    FOR   ${object}    IN
    ...   ${bts_distName}/NRSYSINFO_PROFILE-3/NRIRFIM-1"]/p[@name\="freqBandIndicatorNR
    ...   ${bts_distName}/NRSYSINFO_PROFILE-4/NRIRFIM-1"]/p[@name\="freqBandIndicatorNR
    ...   ${bts_distName}/NRCELL-3"]/p[@name\="freqBandIndicatorNR
    ...   ${bts_distName}/NRCELL-4"]/p[@name\="freqBandIndicatorNR
        Log To Console    Set "${object}" to value 78
        Set Element Text   ${scf_xml}    text=78      xpath=.//managedObject[@distName="${object}"]
    END

    Log To Console    updating single parameter values - finished


Add Lists
    FOR   ${NRCELL}   IN
       ...    managedObject[@distName\="${bts_distName}/NRCELL-2"]
       ...    managedObject[@distName\="${bts_distName}/NRCELL-3"]
       ...    managedObject[@distName\="${bts_distName}/NRCELL-4"]
       ...    managedObject[@distName\="${bts_distName}/NRCELL-11"]
       ...    managedObject[@distName\="${bts_distName}/NRCELL-12"]
       Create List a3MeasSsbRsrp     ${NRCELL}
    END


Create List a3MeasSsbRsrp
    [Documentation]    [PRIVATE]    create List a3MeasSsbRsrp in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]      ${NRCELL}
    Log To Console    Building list a3MeasSsbRsrp for object ${NRCELL}
    ${a3MeasSsbRsrp}    Set Variable    <list name="a3MeasSsbRsrp">
    FOR     ${line}   IN
           ...    <item>
           ...    <p name="a3HysteresisSsbRsrp">1</p>
           ...    <p name="a3OffsetSsbRsrp">10</p>
           ...    <p name="a3TimeToTriggerSsbRsrp">ms0</p>
           ...    </item>
           ...    </list>
           ${a3MeasSsbRsrp}   Catenate     SEPARATOR=\n         ${a3MeasSsbRsrp}   ${line}
    END
    Add Element     ${scf_xml}     ${a3MeasSsbRsrp}           xpath=.//${NRCELL}


Update List a3MeasSsbRsrp NRCELL-1
    [Documentation]    [PRIVATE]    Update list a3MeasSsbRsrp NRCELL-1
    ...       :Autor: Sylvia Schneider
    ${xpath_NRCELL_a3MeasSsbRsrp}  Set Variable   managedObject[@distName="${bts_distName}/NRCELL-1"]/list[@name="a3MeasSsbRsrp"]/item
    FOR   ${param}                ${value}   IN
    ...   a3HysteresisSsbRsrp     1
    ...   a3OffsetSsbRsrp         10
       Log To Console     update list a3MeasSsbRsrp NRCELL-1, param ${param} value ${value}
       Set Element Text   ${scf_xml}    text=${value}   xpath=.//${xpath_NRCELL_a3MeasSsbRsrp}/p[@name="${param}"]
    END


Create New Objects
    [Documentation]    [PRIVATE]    create objects in SCF
    ...       :Autor: Sylvia Schneider
    Create NRADJNRCELL
    Create NRREL


Create NRREL
    FOR   ${NRCELL_id}   ${NRREL_id}   ${lcrId}   ${gNbId}   IN
    ...   1              1             2          1
    ...   1              2             3          1
    ...   1              3             4          1
    ...   1              4             1          38
    ...   2              1             1          1
    ...   2              2             3          1
    ...   2              3             4          1
    ...   2              4             1          38
    ...   3              1             4          1
    ...   3              2             1          1
    ...   3              3             2          1
    ...   3              4             1          38
    ...   4              1             3          1
    ...   4              2             1          1
    ...   4              3             2          1
    ...   4              4             1          38
       Create Single NRREL   ${NRCELL_id}   ${NRREL_id}   ${lcrId}    ${gNbId}
    END


Create Single NRREL
    [Documentation]    [PRIVATE]    create NRREL object in SCF
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${NRCELL_id}   ${NRREL_id}   ${lcrId}   ${gNbId}
    Log To Console    Building object ${bts_distName}/NRCELL-${NRCELL_id}/NRREL-${NRREL_id}
    ${NRREL}   Set Variable   <managedObject class="NRREL" distName="${bts_distName}/NRCELL-${NRCELL_id}/NRREL-${NRREL_id}"
    ${NRREL}   Catenate     SEPARATOR=${SPACE}   ${NRREL}   version="${version_SCF}" operation="create">
    FOR     ${line}   IN
    ...    <p name="cellIndividualSsbRsrpOffset">0dB</p>
    ...    <p name="cellIndividualSsbRsrqOffset">0dB</p>
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
    ...    <p name="mcc">311</p>
    ...    <p name="mnc">489</p>
    ...    <p name="mncLength">3</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${NRREL}   Catenate     SEPARATOR=\n         ${NRREL}   ${line}
    END
    Add Element     ${scf_xml}     ${NRREL}           xpath=.//cmData


Create NRADJNRCELL
    [Documentation]    [PRIVATE]    create NRADJNRCELL object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    Building object ${bts_distName}/NRADJNRCELL-1
    ${NRADJNRCELL}    Set Variable   <managedObject class="NRADJNRCELL" distName="${bts_distName}/NRADJNRCELL-1"
    ${NRADJNRCELL}   Catenate     SEPARATOR=${SPACE}   ${NRADJNRCELL}    version="${version_SCF}" operation="create">
    FOR     ${line}   IN
    ...    <p name="cellDepType">NSA</p>
    ...    <p name="cellReservedForOperatorUse">notReserved</p>
    ...    <p name="fiveGsTac">200</p>
    ...    <p name="freqBandIndicatorNR">78</p>
    ...    <p name="gNbId">38</p>
    ...    <p name="gNbIdLength">22</p>
    ...    <p name="lcrId">1</p>
    ...    <p name="nrarfcn">640000</p>
    ...    <p name="physCellId">48</p>
    ...    <p name="ssbFrequency">640032</p>
    ...    <list name="gnbPlmn">
    ...    <item>
    ...    <p name="mcc">311</p>
    ...    <p name="mnc">489</p>
    ...    <p name="mncLength">3</p>
    ...    </item>
    ...    </list>
    ...    </managedObject>
           ${NRADJNRCELL}   Catenate     SEPARATOR=\n         ${NRADJNRCELL}   ${line}
    END
    Add Element     ${scf_xml}     ${NRADJNRCELL}           xpath=.//cmData

