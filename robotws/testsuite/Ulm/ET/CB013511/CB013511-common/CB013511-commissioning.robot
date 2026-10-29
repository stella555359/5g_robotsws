*** Settings ***
Documentation   This is a keyword file for CB013511, part commissioning
...             Team: 'MI MN RAN RD VRF ULM 4'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
Library   XML

Library   taf.sbts.oam.coam.admin          WITH NAME   admin

Resource         ../../../resources/Common/connect.robot
Resource         ../../../resources/Common/gnb.robot
Resource         ../../../resources/Common/ute_workarounds.robot
Resource         ../../../resources/Common/wts_ue.robot

Resource        CB013511-keywords.robot
Resource        CB013511-commissioning-objects.robot
Resource        CB013511-commissioning-lists.robot
Resource        CB013511-commissioning-parameter.robot


*** Keywords ***


Activate SCF And Bring Tl OnAir
    [Documentation]    [PRIVATE]    activate SCF and bring tl onAir
    ...       :Author: Sylvia Schneider
    [Arguments]    ${tc}
    wts_ue.Kill WTS Services
    ${oam_alias}    connect.Setup OAM Http Session    node_type=gnb  node_id=${0}
    Log To Console    activate ${resultDir}/CB013511_${tc}.xml started
    admin.Perform Commissioning
    ...    scf_file=${resultDir}/CB013511_${tc}.xml
    ...    skip_parameter_relation_errors=False
    ...    timeout=660
    ...    connection=${oam_alias}
    Log To Console    activate ${resultDir}/CB013511_${tc}.xml finished
    Run Keyword And Ignore Error    connect.Teardown OAM Http Session    node_type=gnb  node_id=${0}
    CB013511-keywords.Check All Radio Units Online
    Log To Console    start to bring tl on air without reboot
    ute_workarounds.Bring Airphone TL To On Air Status Without Reboot
    Log To Console    save final scf ${resultDir}/SCF_final.xml
    gnb.Get SCF From GNB With COAM      resultConfigDir=${resultDir}    gnbScfName=SCF_final.xml


Update SCF Common A_SE_TC02_TC03
    [Documentation]    [PRIVATE]    Update SCF common A_SE_TC02_TC03
    ...       :Author: Sylvia Schneider
    Log To Console    \nupdate SCF and store in ${resultBaseDir}/CB013511_common_A_SE_TC02_TC03.xml
    ${scf_xml}    XML.Parse Xml    ${resultBaseDir}/SCFC_start.xml
    Set Suite Variable   ${scf_xml}
    CB013511-commissioning-objects.Add Objects For Common_A_SE_TC02_TC03
    CB013511-commissioning-lists.Add Lists For Common_A_SE_TC02_TC03
    CB013511-commissioning-parameter.Add And Update Parameters For Common_A_SE_TC02_TC03

    XML.Save Xml     ${scf_xml}    ${resultBaseDir}/CB013511_common_A_SE_TC02_TC03.xml


Update SCF A_SE_TC05
    [Documentation]    [PRIVATE]    Update SCF A_SE_TC05
    ...       :Author: Sylvia Schneider
    Log To Console    \nupdate SCF and store in ${resultDir}/CB013511_TC05.xml
    ${scf_xml}    XML.Parse Xml    ${resultBaseDir}/SCFC_start.xml
    Set Suite Variable   ${scf_xml}
    CB013511-commissioning-objects.Add Objects For Common_A_SE_TC05
    CB013511-commissioning-lists.Add Lists For Common_A_SE_TC05
    CB013511-commissioning-parameter.Add And Update Parameters For Common_A_SE_TC05

    XML.Save Xml     ${scf_xml}    ${resultDir}/CB013511_TC05.xml


Update SCF A_SE_TC04
    [Documentation]    [PRIVATE]    Update SCF A_SE_TC04
    ...       :Author: Sylvia Schneider
    Log To Console    \nupdate SCF and store in ${resultDir}/CB013511_TC04.xml
    ${scf_xml}    XML.Parse Xml    ${resultBaseDir}/SCFC_start.xml
    Set Suite Variable   ${scf_xml}
    CB013511-commissioning-objects.Add Objects For Common_A_SE_TC04
    CB013511-commissioning-lists.Add Lists For Common_A_SE_TC04
    CB013511-commissioning-parameter.Add And Update Parameters For Common_A_SE_TC04

    XML.Save Xml     ${scf_xml}    ${resultDir}/CB013511_TC04.xml
