*** Settings ***
Documentation   This is a keyword file for 5GC000480-D-J, part commissioning
...             Team: 'MN 5G&SC SW Eng ULM L2PS 60 SG'
...             Email: 'I_ECE_RD_ULM_SQD_60_GMS@internal.nsn.com'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Keywords ***

set sw release version
    [Documentation]    [PRIVATE]    set sw release version from gnb sw version
    ...       :Autor: Sylvia Schneider
    @{gnb_sw_version_parts}   split string    ${gnb_swVersion}    _
    set suite variable    ${release}   ${gnb_sw_version_parts}[0]


Update SCF with tc specific parameters
    [Documentation]    [PRIVATE]    Update common SCF with tc specific parameters
    ...       :Autor: Sylvia Schneider
    ${scf_xml}    parse xml    ${resultBaseDir}/SCFC_480DJ_common.xml
    set suite variable    ${scf_xml}

    Log To Console    NRBTS: actMultiDrbNSA set to value ${actMultiDrbNSA}
    Set Element Text   ${scf_xml}    text=${actMultiDrbNSA}       xpath=.//p[@name="actMultiDrbNSA"]
    ${xpath_NRCELLGRP-2}   set Variable    managedObject[@distName="${bts_distName}/NRCELLGRP-2"]
    FOR     ${param}    IN
    ...     addNumOfHoUsers
    ...     addNumOfNonGBRBearersHo
    ...     maxNumOfUsers
    ...     maxNumOfNonGBRBearers
       Log To Console     NRCELLGRP-2: ${param} set to value ${${param}}
       Set Element Text   ${scf_xml}    text=${${param}}               xpath=.//${xpath_NRCELLGRP-2}/p[@name="${param}"]
    END
    ${xpath_NRCELL}   set Variable    managedObject[@distName="${bts_distName}/${cell_distName}"]
    FOR     ${param}    IN
    ...     maxNumOfUsersPerCell
    ...     maxNumOfSCellAlloc
       Log To Console     ${cell_distName}: ${param} set to value ${${param}}
       Set Element Text   ${scf_xml}    text=${${param}}               xpath=.//${xpath_NRCELL}/p[@name="${param}"]
    END
    Save xml     ${scf_xml}    ${resultDir}/SCFC_480DJ_tc_specific.xml
    Log To Console    SCF saved ${resultDir}/SCFC_480DJ_tc_specific.xml


tc specific update and activate SCF and bring tl onAir
    [Documentation]    [PRIVATE]    tc specific update and activate SCF and bring tl onAir
    ...       :Autor: Sylvia Schneider
    Kill WTS services
    Update SCF with tc specific parameters
    ${oam_alias}    connect.Setup OAM http session    node_type=gnb  node_id=${0}
    Log To Console    activate ${resultDir}/SCFC_480DJ_tc_specific.xml started
    admin.Perform Commissioning
    ...    scf_file=${resultDir}/SCFC_480DJ_tc_specific.xml
    ...    skip_parameter_relation_errors=False
    ...    timeout=660
    ...    connection=${oam_alias}
    Log To Console    activate ${resultDir}/SCFC_480DJ_tc_specific.xml finished
    Run Keyword and Ignore Error    connect.Teardown OAM http session    node_type=gnb  node_id=${0}
    check all radio units online
    Log To Console    start to bring tl on air without reboot
    Bring Airphone TL to on Air status without reboot
    Setup 2nd X2link
    Log To Console    save final scf ${resultDir}/SCF_final.xml
    get scf coam   ${resultDir}    SCF_final.xml
    [Teardown]    Run Keyword and Ignore Error    connect.Teardown OAM http session    node_type=gnb  node_id=${0}


Update SCF common part
    [Documentation]    [PRIVATE]    uUpdate SCF common part
    ...       :Autor: Sylvia Schneider
    set sw release version
    ${scf_xml}    parse xml    ${resultBaseDir}/SCFC_start.xml
    set suite variable    ${scf_xml}
    update single parameter values
    create new objects
    Save xml     ${scf_xml}    ${resultBaseDir}/SCFC_480DJ_common.xml
    Log To Console    \nupdate SCF and store in ${resultBaseDir}/SCFC_480DJ_common.xml


update single parameter values
    [Documentation]    [PRIVATE]    update single parameter values in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    updating single parameter values - started
    FOR    ${value}     ${param}   IN
    ...    ${measurement_period_in_min}min     reportingIntervalPm
    ...    ${measurement_period_in_min}min     miNrNRMOP
    ...    ${measurement_period_in_min}min     miNrRRCC
    ...    7200                                nsaInactivityTimer
    ...    true                                actIntraFreqInterGnbMobilityNSA3x
       Log To Console    set parameter ${param} to value ${value}
       Set Element Text   ${scf_xml}    text=${value}      xpath=.//p[@name="${param}"]
    END
    Log To Console    updating single parameter values - finished


create new objects
    [Documentation]    [PRIVATE]    create objects in SCF
    ...       :Autor: Sylvia Schneider
    Create NRREL
    Create NRADJNRCELL


Create NRREL
    [Documentation]    [PRIVATE]    create NRREL object in SCF
    ...       :Autor: Sylvia Schneider
    Log To Console    \nBuilding object ${bts_distName}/${cell_distName}/NRREL-1
    ${NRREL}   set variable   <managedObject class="NRREL" distName="${bts_distName}/${cell_distName}/NRREL-1"
    ${NRREL}   Catenate     SEPARATOR=${SPACE}   ${NRREL}   version="${version_SCF}" operation="create">
    FOR     ${line}   IN
           ...    <p name="cellIndividualSsbRsrpOffset">-2dB</p>
           ...    <p name="cellIndividualSsbRsrqOffset">-2dB</p>
           ...    <p name="gNbId">38</p>
           ...    <p name="gNbIdLength">22</p>
           ...    <p name="handoverAllowedSA">allowed</p>
           ...    <p name="handoverAllowedSARedCap">forbidden</p>
           ...    <p name="isRplCellForPSCell">false</p>
           ...    <p name="lcrId">3</p>
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
    ${NRADJNRCELL}    set variable   <managedObject class="NRADJNRCELL" distName="${bts_distName}/NRADJNRCELL-1"
    ${NRADJNRCELL}   Catenate     SEPARATOR=${SPACE}   ${NRADJNRCELL}    version="${version_SCF}" operation="create">
    FOR     ${line}   IN
           ...    <p name="cellDepType">NSA</p>
           ...    <p name="cellReservedForOperatorUse">notReserved</p>
           ...    <p name="fiveGsTac">200</p>
           ...    <p name="freqBandIndicatorNR">71</p>
           ...    <p name="gNbId">38</p>
           ...    <p name="gNbIdLength">22</p>
           ...    <p name="lcrId">3</p>
           ...    <p name="nrarfcn">126380</p>
           ...    <p name="physCellId">48</p>
           ...    <p name="ssbFrequency">126530</p>
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

