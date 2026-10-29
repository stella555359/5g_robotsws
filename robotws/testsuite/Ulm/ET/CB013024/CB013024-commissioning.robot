*** Settings ***
Documentation   This is a keyword file for CB013024, part commissioning
...             Team: 'MN RAN RD VRF ULM4'
...             Author: Shruthi Shivaprasad
#-------------------------------------------------------------------------------------------------------------

Resource        CB013024-keywords.robot
Resource        ../../resources/Common/ute_workarounds.robot
Resource        ../resources/SQD65/sqd65_commissioning.robot
Library         taf.config.scf                  WITH NAME    scf

*** Variables ***

${MEASUREMENT_PERIOD_IN_MIN}   5
${distName_dlOnly}             MRBTS-1/NRBTS-1/NRCELL-6/NRREL-2
${distName_cell1}              MRBTS-1/NRBTS-1/NRCELL-1
${distName_cell2}              MRBTS-1/NRBTS-1/NRCELL-2
${distName_NRREL2}             MRBTS-1/NRBTS-1/NRCELL-8/NRREL-2
${distName_NRREL1}             MRBTS-1/NRBTS-1/NRCELL-8/NRREL-1

${scf_file_name}               SCFC_start.xml
${mo_version}                  NONE

*** Keywords ***

activate SCF and bring tl onAir ${tc}
    [Documentation]    [PRIVATE]    activate SCF and bring tl onAir
    ...       :Autor: Shruthi Shivaprasad  and Anja Becher

    Kill WTS services
    IF    '${tc}'=='TC1'
           Prepare SCF For CB013024 TC1
           Prepare WTS Config For TC1
    ELSE IF    '${tc}'=='TMO'
           Prepare SCF For CB013024 TMO
           Prepare WTS Config For TMO
    END

    ${oam_alias}    connect.Setup OAM http session    node_type=gnb  node_id=${0}
    Log To Console    activate ${resultBaseDir}/${scf_file_name} started
    admin.perform commissioning
    ...    scf_file=${resultBaseDir}/${scf_file_name}
    ...    skip_parameter_relation_errors=True
    ...    timeout=660
    ...    connection=${oam_alias}
    Log To Console    activate ${resultBaseDir}/${scf_file_name} finished

    CB013024-keywords.Check All Radio Units Online
    Log To Console    start to bring tl on air
    ute_workarounds.Bring Airphone TL to on Air status
    Log To Console    save final scf ${resultDir}/SCF_final_${tc}.xml
    get scf coam   ${resultDir}    SCF_final_${tc}.xml


prepare SCF for CB013024 TC1
        [Documentation]    [PRIVATE]    change SCF for CB013024 TC1
    ...       :Autor: Anja Becher

    Set Suite Variable      ${scf_file_name}    SCFC_CB013024_TC1.xml

    scf.load_scf    ${resultBaseDir}/SCFC_start.xml
    sqd65_commissioning.Remove Element  dist_name=MRBTS-1/NRBTS-1/NRCELL-6/NRREL-1/   p_name=${None}
    scf.modify scf element    value=dlOnly  dist_name=${distName_dlOnly}  p_name=sCellOperationalMode
    scf.modify scf element    value=false  dist_name=${distName_cell2}  p_name=increasePUSCHPrepTimeULCA
    scf.save_scf    ${resultBaseDir}/${scf_file_name}


prepare SCF for CB013024 TMO
        [Documentation]    [PRIVATE]    change SCF for CB013024 TMO
    ...       :Autor: Anja Becher

    Set Suite Variable      ${scf_file_name}    SCFC_CB013024_TMO.xml

    scf.Load SCF    ${resultBaseDir}/SCFC_start.xml
    Add NRREL MOC To NRCELL   cell_id=8  moc_id=2  lcrId=3
    scf.Modify SCF Element    value=blind  dist_name=${distName_NRREL1}  p_name=sCellAdditionMethod
    scf.Modify SCF Element    value=5min  dist_name=MRBTS-1/MNL-1/MNLENT-1/PMCADM-1  p_name=reportingIntervalPm
    sqd65_commissioning.Set Element    value=22  dist_name=${distName_NRREL1}  p_name=gNbIdLength
    sqd65_commissioning.Set Element    value=22  dist_name=${distName_NRREL2}  p_name=gNbIdLength
    sqd65_commissioning.Set Element    value=5min  dist_name=MRBTS-1/NRBTS-1/NRPMRNL-1  p_name=miNrRSADU
    sqd65_commissioning.Set Element    value=5min  dist_name=MRBTS-1/NRBTS-1/NRPMRNL-1  p_name=miNrCaCu

    scf.Save SCF    ${resultBaseDir}/${scf_file_name}