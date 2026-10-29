*** Settings ***
Documentation   This is a keyword file for CB008731_force_HO, part commissioning TMO
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

Resource        CB008731-commissioning_objects.robot
Resource        CB008731-commissioning_lists.robot
Resource        CB008731-commissioning_parameter.robot

*** Variables ***

${measurement_period_in_min}     15


*** Keywords ***



Update SCF File For CB008731 Force HO TMO
    [Documentation]    [PRIVATE]    Update SCF file for CB008731 force HO TMO
    ...       :Autor: Sylvia Schneider
    Log To Console    \nstart update SCF force HO
    ${scf_xml}    Parse Xml    ${resultBaseDir}/SCFC_start.xml
    Set Suite Variable    ${scf_xml}

    update single nrbts parameter   actInterRatHoFromEutraToSA   true
    Add NRHOIR-30 For Nrcell-1 And 2

    Create NRADJECELL 2 TMO
    Create NRADJGNB force_HO TMO
    Create NRRELE   nrcell_id=1  #in description nrcell-4/nrrele-1, im scf nrcell-1 und 2   ?????????
    Create NRRELE   nrcell_id=2  #in description nrcell-4/nrrele-1, im scf nrcell-1 und 2   ?????????
    Create XNLINK force_HO TMO
    Create NRHOIR force_HO   nrhoir_id=30

    Save Xml     ${scf_xml}    ${resultBaseDir}/SCFC_CB8731_force_HO_TMO.xml
    Log To Console    \nupdate SCF and store in ${resultBaseDir}/SCFC_CB8731_force_HO_TMO.xml


Activate SCF And Bring Tl onAir Force HO TMO
    [Documentation]    [PRIVATE]    activate SCF and bring tl onAir
    ...       :Autor: Sylvia Schneider
    Kill WTS services
    ${oam_alias}    connect.Setup OAM http session    node_type=gnb  node_id=${0}
    Log To Console    activate ${resultBaseDir}/SCFC_CB8731_force_HO_TMO.xml started
    admin.Perform Commissioning
    ...    scf_file=${resultBaseDir}/SCFC_CB8731_force_HO_TMO.xml
    ...    skip_parameter_relation_errors=False
    ...    timeout=660
    ...    connection=${oam_alias}
    Log To Console    activate ${resultBaseDir}/SCFC_CB8731_force_HO_TMO.xml finished
    Run Keyword and Ignore Error    connect.Teardown OAM http session    node_type=gnb  node_id=${0}
    Check All Radio Units Online
    Log To Console    start to bring tl on air without reboot
    Bring Airphone TL to on Air status without reboot
    Log To Console    save final scf ${resultDir}/SCF_final_force_HO_TMO.xml
    Get Scf Coam   ${resultDir}    SCF_final_force_HO_TMO.xml
    [Teardown]    Run Keyword and Ignore Error    connect.Teardown OAM http session    node_type=gnb  node_id=${0}


Add NRHOIR-30 For Nrcell-1 And 2
    [Documentation]    [PRIVATE]    Add NRHOIR-30 For Nrcell-1 And 2
    ...       :Autor: Sylvia Schneider
    Log To Console    Add NRHOIR-30 For Nrcell-1 And 2

    ${nrhoir-30}   Set Variable   <p>MRBTS-1/NRBTS-1/NRHOIR-30</p>
    Add Element        ${scf_xml}     ${nrhoir-30}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-1"]/list[@name="nrhoirDNList"]
    Add Element        ${scf_xml}     ${nrhoir-30}   xpath=.//managedObject[@distName="${bts_distName}/NRCELL-2"]/list[@name="nrhoirDNList"]


Set actForceHoInsuffUeCap To True
    [Documentation]    [PRIVATE]    set actForceHoInsuffUeCap to true delta commissioning
    ...       :Autor: Sylvia Schneider
    Log To Console    \ndelta commissioning actForceHoInsuffUeCap is set to true
    ${oam_alias}    connect.Setup OAM http session    node_type=gnb  node_id=${0}
    admin.perform delta recommissioning
    ...    ${CURDIR}/delta_actForceHoInsuffUeCap.json
    ...    should_activate=True
    ...    timeout=300
    ...    connection=${oam_alias}
    connect.Teardown OAM http session    node_type=gnb  node_id=${0}
    Log To Console    delta commissioning finished


Save Last SCF
    [Documentation]    [PRIVATE]    save last SCF
    ...       :Autor: Sylvia Schneider
    Get Scf Coam    ${resultDir}    SCFC_CB008731_actForceHoInsuffUeCap.xml
    Log To Console    last SCF saved ${resultDir}/SCFC_CB008731_actForceHoInsuffUeCap.xml
