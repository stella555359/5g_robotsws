*** Settings ***
Documentation   This is a keyword file for CB013954, part commissioning
...             Team: 'MN RAN RD VRF ULM4'
...             Author: Shruthi Shivaprasad and Anja Becher
#-------------------------------------------------------------------------------------------------------------

Resource        CB013954-keywords.robot

Resource        ../../resources/Common/ute_workarounds.robot
#Resource        ../resources/SQD65/sqd65_commissioning.robot
Library         taf.config.scf                  WITH NAME    scf
Library         iphy_edditing.py
Library         OperatingSystem


*** Variables ***

${MEASUREMENT_PERIOD_IN_MIN}   5

${scf_file_name}               SCFC_start.xml
${mo_version}                  NONE
${distName_vlan}               MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1

*** Keywords ***

Activate SCF And Bring Tl OnAir ${tc}
    [Documentation]    [PRIVATE]    activate SCF and bring tl onAir
    ...       :Autor: Shruthi Shivaprasad  and Anja Becher

    Kill WTS Services

    Prepare IPHY
    Prepare SCF For TC1
    Prepare WTS Config

    ${oam_alias}    connect.Setup OAM Http Session    node_type=gnb  node_id=${0}
    Log To Console    activate ${resultBaseDir}/scf_CB013954_TC01.xml started
    admin.Perform Commissioning
    ...    scf_file=${resultBaseDir}/scf_CB013954_TC01.xml
    ...    skip_parameter_relation_errors=True
    ...    timeout=660
    ...    connection=${oam_alias}
    Log To Console    activate ${resultBaseDir}/scf_CB013954_TC01.xml finished

    CB013954-keywords.Check All Radio Units Online
    Log To Console    start to bring tl on air
    ute_workarounds.Bring Airphone TL To On Air Status
    Log To Console    save final scf ${resultDir}/SCF_final_${tc}.xml
    keywordbook-480.Get Scf Coam  ${resultDir}    SCF_final_${tc}.xml
    gnb.Get SCF From GNB With COAM   gnbScfName=SCF_final_${tc}.xml   resultConfigDir=${resultDir}


Prepare SCF For TC1
        [Documentation]    [PRIVATE]    change SCF for CB013954 TC1
    ...       :Autor: Anja Becher

    scf.Load Scf     ${resultBaseDir}/SCFC_start.xml
    ${vlan_value}=   scf.Get Value From Scf  dist_name=${distName_vlan}   p_name=vlanId

    scf.Load Scf    ${CURDIR}/scf_CB013954_TC01.xml
    scf.Modify Scf Element    value=${vlan_value}   dist_name=${distName_vlan}    p_name=vlanId
    scf.Save Scf    ${resultBaseDir}/scf_CB013954_TC01.xml


Prepare IPHY
    [Documentation]      Reconfigure iphy.xml file
    Log To Console       start reconfiguration of iphy.xml

    ${ap_alias}          connect.Connect To Airphone Common Unit
    ssh.Execute          cp /ffs/run/simmode/new_iphy.xml /ffs/run/simmode/new_iphy_ori.xml    connection=${ap_alias}
    ssh.Download File    /rom/simmode/new_iphy.xml        ${resultBaseDir}/new_iphy.xml         connection=${ap_alias}

    ${iphy_ori}          OperatingSystem.Get File    ${resultBaseDir}/new_iphy.xml
    ${iphy_CB013954}     OperatingSystem.Get File    ${CURDIR}/iphy_CB013954.xml
    OperatingSystem.Create File      ${resultBaseDir}/iphy_CB013954_old.xml    ${iphy_CB013954}

    ${new contents}      iphy_edditing.Update Iphy    ${iphy_ori}  ${iphy_CB013954}

    Log To Console    load final iphy_xml ${resultBaseDir}/iphy_CB013954.xml
    OperatingSystem.Create File      ${resultBaseDir}/iphy_CB013954_new.xml      ${new contents}
    ssh.Upload File    ${resultBaseDir}/iphy_CB013954_new.xml     /ffs/run/simmode/new_iphy.xml   connection=${ap_alias}