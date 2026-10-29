*** Settings ***
Documentation   This is a keyword file for CB006139-CG, part commissioning
...             Team: 'MN RAN RD VRF ULM 2'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------


*** Keywords ***

Bring NRBTS-1 And NRBTS-2 To onAir
    [Documentation]    [PRIVATE]    Bring NRBTS-1 And NRBTS-2 To onAir
    ...       :Autor: Sylvia Schneider
    wts_ue.Kill WTS Services
    CB006139-keywords-wireshark.Start Wireshark Trace
    CB006139-keywords.Check All Radio Units Online
    Log To Console    start to bring tl on air without reboot
    ute_workarounds.Bring Airphone TL To On Air Status Without Reboot
    CB006139-keywords-wireshark.Stop Wireshark Trace For Setup
    CB006139-keywords-wts.Check WTS In Active State
    Setup 2nd X2link
    Wait Until All GNBs To Be Onair State


Setup 2nd X2link
    [Documentation]    [PRIVATE]    setup 2nd X2link
    ...       :Autor: Sylvia Schneider
    ute_wtssim.execute egate command and wait for data
    ...    cmd=enb_x2_link_up enb=1 target=3    pass_regexp=X2AP Link with GNB-3 .* is up     alias=ap_egate


Update SCF CG Prime gNB
    [Documentation]    [PRIVATE]    Update SCF CG Prime gNB
    ...       :Autor: Sylvia Schneider
    Log To Console    \nupdate SCF and store in ${resultDir}/CB006139-CG-prime-gNB.xml
    ${scf_xml}    Parse Xml    ${resultBaseDir}/SCFC_start_1st.xml
    Set Suite Variable    ${scf_xml}
    Log To Console    set param actHigherPrioFreqHo to SA
    Set Element Text   ${scf_xml}    text=SA    xpath=.//p[@name="actHigherPrioFreqHo"]

    FOR    ${param}                                          ${object}  IN
    ...    <p name="actHigherPrioFreqHoForCA">SA</p>         ${EMPTY}
    ...    <p name="sCellExcludelistTimerA2Fr1">10</p>       ${EMPTY}
    ...    <p>A4-based</p>                                   /list[@name="actMeasBasedSCellAdditionSa"]
       Log To Console    NRBTS-1${object}: add param a${param}
       Add Element   ${scf_xml}   ${param}   xpath=.//managedObject[@distName="MRBTS-1/NRBTS-1"]${object}
    END

    Add List a4PeriodicMeasControlSA to NRCELL-1 And NRCELL-2 And NRCELL-4
    Add List a4MeasSsbRsrp to NRCELL-4 NRHOIF-1

    FOR   ${nrhoif_id}    ${param}      IN
    ...   1               a4MeasHigherPrioFreqEnabled
    ...   1               a4MeasSCellAddEnabled
    ...   2               a4MeasSCellAddEnabled
       Log To Console    NRCELL-4/NRHOIF-${nrhoif_id}: set param ${param} to rsrp
       ${object}  Set Variable   managedObject[@distName="MRBTS-1/NRBTS-1/NRCELL-4/NRHOIF-${nrhoif_id}"]/p[@name="${param}"]
       Set Element Text   ${scf_xml}    text=rsrp    xpath=.//${object}
    END

    FOR   ${nrrel_id}    ${value}    IN
    ...   1              covBasedA1
    ...   2              covBasedA1
    ...   4              covBasedA4
    ...   5              covBasedA4
    ...   6              covBasedA1
    ...   7              covBasedA1
       Log To Console    NRCELL-4/NRREL-${nrrel_id}: set param sCellAdditionMethod to ${value}
       ${object}  Set Variable   managedObject[@distName="MRBTS-1/NRBTS-1/NRCELL-4/NRREL-${nrrel_id}"]/p[@name="sCellAdditionMethod"]
       Set Element Text   ${scf_xml}    text=${value}    xpath=.//${object}
    END

    FOR   ${object}   ${param}     IN
    ...   NRHOIF-1     <p name="a4PriorityForHigherPrioFreqHo">10</p>
    ...   NRREL-4      <p name="actA4ToA1BasedSCellFallbackNsa">false</p>
    ...   NRREL-5      <p name="actA4ToA1BasedSCellFallbackNsa">false</p>
       Log To Console    NRCELL-4/${object}: set param sCellAdditionMethod to ${value}
       Add Element   ${scf_xml}   ${param}   xpath=.//managedObject[@distName="MRBTS-1/NRBTS-1/NRCELL-4/${object}"]
    END

    Save Xml     ${scf_xml}    ${resultDir}/CB006139-CG-prime-gNB.xml

    ${oam_alias}    connect.Setup OAM http session    node_type=gnb  node_id=${0}
    Log To Console    activate ${resultDir}/CB006139-CG-prime-gNB.xml started
    admin.Perform Commissioning
    ...    scf_file=${resultDir}/CB006139-CG-prime-gNB.xml
    ...    skip_parameter_relation_errors=False
    ...    timeout=660
    ...    connection=${oam_alias}
    Log To Console    activate ${resultDir}/CB006139-CG-prime-gNB.xml finished
    [Teardown]    Run Keyword and Ignore Error    connect.Teardown OAM http session    node_type=gnb  node_id=${0}


Add List a4PeriodicMeasControlSA to NRCELL-1 And NRCELL-2 And NRCELL-4
    [Documentation]    [PRIVATE]    Add List a4PeriodicMeasControlSA to NRCELL-1 And NRCELL-2 And NRCELL-4
    ...       :Autor: Sylvia Schneider
    ${a4PeriodicMeasControlSA}    set variable    <list name="a4PeriodicMeasControlSA">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="a4Fr1SupervisionTimer">10000</p>
    ...    <p name="a4Fr2SupervisionTimer">6000</p>
    ...    <p name="a4MeasActBlockTimer">0</p>
    ...    <p name="a4MeasMaxNumber">5</p>
    ...    <p name="a4RetryTimer">10</p>
    ...    <p name="a4RetryTimerMultCa">2</p>
    ...    </item>
    ...    </list>
           ${a4PeriodicMeasControlSA}   Catenate     SEPARATOR=\n         ${a4PeriodicMeasControlSA}   ${line}
    END
    FOR   ${cell_id}   IN   1   2   4
       Log To Console    Building list a4PeriodicMeasControlSA for object NRCELL-${cell_id}
       Add Element     ${scf_xml}     ${a4PeriodicMeasControlSA}           xpath=.//managedObject[@distName="MRBTS-1/NRBTS-1/NRCELL-${cell_id}"]
    END


Add List a4MeasSsbRsrp to NRCELL-4 NRHOIF-1
    [Documentation]    [PRIVATE]    Add List a4MeasSsbRsrp to NRCELL-4 NRHOIF-1
    ...       :Autor: Sylvia Schneider
    ${a4MeasSsbRsrp}    set variable    <list name="a4MeasSsbRsrp">
    FOR     ${line}   IN
    ...    <item>
    ...    <p name="a4HysteresisSsbRsrp">0</p>
    ...    <p name="a4ThresholdSsbRsrp">44</p>
    ...    <p name="a4TimeToTriggerSsbRsrp">ms40</p>
    ...    </item>
    ...    </list>
           ${a4MeasSsbRsrp}   Catenate     SEPARATOR=\n         ${a4MeasSsbRsrp}   ${line}
    END
    Log To Console    Building list a4PeriodicMea4MeasSsbRsrpasControlSA for object NRCELL-4/NRHOIF-1
    Add Element     ${scf_xml}     ${a4MeasSsbRsrp}           xpath=.//managedObject[@distName="MRBTS-1/NRBTS-1/NRCELL-4/NRHOIF-1"]


Get vlanId From VLANIF For BR Interface
    [Documentation]    [PRIVATE]    Get vlanId From VLANIF For BR Interface
    ...       :Autor: Sylvia Schneider
    ${vlanId}   Get Element Text   ${scf_xml}
    ...    xpath=.//managedObject[@distName="MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1"]/p[@name="vlanId"]
    Set Test Variable    ${vlanId}
    Log To Console    vlanId for br interface is "${vlanId}"
