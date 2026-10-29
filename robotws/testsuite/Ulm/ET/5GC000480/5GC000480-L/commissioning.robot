*** Settings ***
Documentation   This is a keyword file for 480-L, part commissioning
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

Resource        commissioning_delete.robot
Resource        commissioning_objects.robot
Resource        commissioning_parameter.robot

*** Variables ***
${measurement_period_in_min}        5

${nrcell2_gscn_contiguous}          22452
${nrcell2_gscn_noncontiguous}       22426
${nrcell2_nrarfcn_contiguous}       2073339
${nrcell2_nrarfcn_noncontiguous}    2065705


*** Keywords ***

Update SCF Common Part ${mode}
    [Documentation]    [PRIVATE]    update SCF common part
    ...       :Autor: Sylvia Schneider
    Log To Console    \nstart update SCF ${mode}
    ${scf_xml}    Parse XML    ${resultBaseDir}/SCFC_start.xml
    Set Suite Variable    ${scf_xml}

    commissioning_delete.Delete Element

    ${xpath_sync2}   Set Variable   managedObject[@distName="MRBTS-1/MNL-1/MNLENT-1/SYNC-2"]
    Add Element     ${scf_xml}    <list name="targetDNList"/>           xpath=.//${xpath_sync2}
    Add Element     ${scf_xml}    <p>MRBTS-1/EQM-1/APEQM-1/RMOD-1</p>   xpath=.//${xpath_sync2}/list[@name="targetDNList"]
    ${xpath_NRDU}   Set Variable   managedObject[@distName="${bts_distName}/NRDU-1"]
    Add Element     ${scf_xml}   <list name="refNrCellGroup"/>         xpath=.//${xpath_NRDU}
    Add Element     ${scf_xml}   <p>0</p>                              xpath=.//${xpath_NRDU}/list[@name="refNrCellGroup"]

    commissioning_parameter.Update RMOD Parameter For All LCELNR-2 Objects
    commissioning_objects.Create LCELNR CHANNELGROUP CHANNEL    LCELNR=3
    commissioning_objects.Create LCELNR CHANNELGROUP CHANNEL    LCELNR=4

    commissioning_parameter.Update Single Nrbts Parameter     param=actCarrierAggregation    value=true
    commissioning_parameter.Update Single Nrbts Parameter     param=caConfigurationSupport   value=4CCDL_2CCUL

    commissioning_parameter.Add Single Nrbts Parameter        param=<p name="sCellActivationMethod">blind</p>
    commissioning_parameter.Add Single Nrbts Parameter        param=<p name="maxNumScellsUl">1</p>

    commissioning_objects.Create nrcell-3 And nrcell-4

    commissioning_parameter.Update Single Nrcell Parameter    nrcell=1   param=gscnOrSsPbchArfcn   value=22446
    commissioning_parameter.Update Single Nrcell Parameter    nrcell=1   param=nrarfcn             value=2071675
    commissioning_parameter.Update Single Nrcell Parameter    nrcell=2   param=gscnOrSsPbchArfcn   value=${nrcell2_gscn_${mode}}
    commissioning_parameter.Update Single Nrcell Parameter    nrcell=2   param=nrarfcn             value=${nrcell2_nrarfcn_${mode}}
    commissioning_parameter.Update Single Nrcell Parameter    nrcell=3   param=gscnOrSsPbchArfcn   value=22458
    commissioning_parameter.Update Single Nrcell Parameter    nrcell=3   param=nrarfcn             value=2075003
    commissioning_parameter.Update Single Nrcell Parameter    nrcell=3   param=lcrId               value=3
    commissioning_parameter.Update Single Nrcell Parameter    nrcell=3   param=physCellId          value=52
    commissioning_parameter.Update Single Nrcell Parameter    nrcell=4   param=gscnOrSsPbchArfcn   value=22464
    commissioning_parameter.Update Single Nrcell Parameter    nrcell=4   param=nrarfcn             value=2076667
    commissioning_parameter.Update Single Nrcell Parameter    nrcell=4   param=lcrId               value=4
    commissioning_parameter.Update Single Nrcell Parameter    nrcell=4   param=physCellId          value=53
    commissioning_parameter.Update Parameter For All Nrcell Objects   param=sCellDeactivationTimerGNB   value=infinity
    commissioning_parameter.Update Parameter For All Nrcell Objects   param=caSupportEnabled            value=true

    commissioning_parameter.Update Nrcellgrp-1 nrCellList

    Save Xml     ${scf_xml}    ${resultBaseDir}/SCFC_480L_common.xml
    Log To Console    save updated SCF common part ${resultBaseDir}/SCFC_480L_common.xml


Update TC Specific Parameters
    [Documentation]    [PRIVATE]    update SCF tc specific part
    ...       :Autor: Sylvia Schneider
    Log To Console    \nstart update SCF tc specific part
    ${scf_xml}    Parse Xml    ${resultBaseDir}/SCFC_480L_common.xml
    Set Suite Variable    ${scf_xml}
    Add Single Nrbts Parameter        param=<p name="maxNumScellsDl">${maxNumScellsDl}</p>
    commissioning_parameter.Update Single Nrcell Parameter    nrcell=1   param=maxNumOfSCellAlloc      value=${maxNumOfSCellAlloc_1}
    commissioning_parameter.Update Single Nrcell Parameter    nrcell=3   param=maxNumOfSCellAlloc      value=${maxNumOfSCellAlloc_3}
    commissioning_parameter.Update Single Nrcell Parameter    nrcell=1   param=maxNumOfUsersPerCell    value=${maxNumOfUsersPerCell}
    commissioning_parameter.Update Parameter For All Nrcell Objects   param=ccLoadThreshold   value=${ccLoadThreshold}

    Save Xml     ${scf_xml}    ${resultDir}/SCFC_480L_tc_specific.xml
    Log To Console    save updated SCF testcase specifif ${resultDir}/SCFC_480L_tc_specific.xml


Activate SCF And Bring TL onAir
    [Documentation]    [PRIVATE]    activate SCF and bring tl onAir
    ...       :Autor: Sylvia Schneider
    Kill WTS services
    ${oam_alias}    connect.Setup OAM HTTP Session    node_type=gnb  node_id=${0}
    Log To Console    activate ${resultDir}/SCFC_480L_tc_specific.xml started
    admin.Perform Commissioning
    ...    scf_file=${resultDir}/SCFC_480L_tc_specific.xml
    ...    skip_parameter_relation_errors=False
    ...    timeout=660
    ...    connection=${oam_alias}
    Log To Console    activate ${resultDir}/${resultDir}/SCFC_480L_tc_specific.xml finished
    Run Keyword And Ignore Error    connect.Teardown OAM HTTP Session    node_type=gnb  node_id=${0}
    keywords.Check All Radio Units Online
    Log To Console    start to bring tl on air without reboot
    ute_workarounds.Bring Airphone TL To On Air Status Without Reboot
    Log To Console    save final scf ${resultDir}/SCF_final.xml
    keywordbook-480.Get Scf Coam   ${resultDir}    SCF_final.xml
    [Teardown]    Run Keyword And Ignore Error    connect.Teardown OAM HTTP Session    node_type=gnb  node_id=${0}

