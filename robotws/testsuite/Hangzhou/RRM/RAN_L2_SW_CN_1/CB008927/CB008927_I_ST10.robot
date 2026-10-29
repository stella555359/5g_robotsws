*** Settings ***
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF}    iphy_file=${IPHY_FILE}
#...               swconfig_param=${RD}       AND    Suite Setup Copy WTS Config Files From Local
#...               local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG}
Suite Teardown    Common Suite Teardown 2
Test Teardown     Common Test Teardown 2
Force Tags        CLOUD_5G_I_LO_AP_LO
...               SBTS00    SBTS24R3    Pz4_12    CB008927   RAN_5G    RAN_5G_TDD    #CRT
Resource          ./../CUDU_L2/common_setup_teardown.robot
Resource          ./Resources/CB008927_resource.robot
Resource          ./../CUDU_L2/common_setup_teardown.robot
Resource          ./../CUDU_L2/common_log_capture.robot

*** Variables ***
${SCF_PATH}          ${CURDIR}/Config
${WTS_LOCAL}      ${CURDIR}/Config
${FULL_SCF_10}                    CB008927_10_ST_scfc.xml
${IPHY_FILE_10}                   ${WTS_LOCAL}/iphy_10_ST.xml
${WTS_CFG_10}                     basic_setup_8927_I_ST10.cfg
${RD}                             0x580839=1;0x580345=1;0x58090b=1;0x580954=1
${ttiPath1}          ttitrace1
${ttiPath2}          ttitrace2
${ttitraceFilter}    generate_ttitrace_profile_CB008927.txt
#${filter15}          dldata_pdschsendreq||dldata_pdcchsendreq
#@{column_name15}     3gpp.sfn    3gpp.slot    3gpp.rnti    3gpp.subcellid
                     #...    DlData_DciInfo.startSymbolNumber   DlData_DciInfo.dciSize
                     #...    DlData_PdschGrant.startSymbol    DlData_PdschGrant.numOfPdschSymbols
                     #...    DlData_PdschGrant.startPrb    DlData_PdschGrant.numOfPrb
${bip_csv}           bip_gnb.csv
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}


*** Test Cases ***
CB008927_10_TDD_with_CSI-RS_refine_beam_SA
    [Tags]    case_I_ST10    Manual_MikeMa    TA_lilidong
    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_10}
    ...        AND    Suite Setup Update GNB    scf_file=${FULL_SCF_10}    iphy_file=${IPHY_FILE_10}    swconfig_param=${RD}
    ...        AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
    ...        AND    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is Configured
    ...        AND    Suite Setup Start WTS And Check OnAir    log=${False}
    ...        AND    Common Test Setup 2

    Set egate rrc log 'off'
    UE '1'-'1' Attach to Cell '1' and setup PDU Session '1' with slice '1'
    Start dl Trafficon on UE '1'-'1' PDU ID '1' TRF ID '1' QFI ID '1' with '900'mbps
    Start ul Trafficon on UE '1'-'1' PDU ID '1' TRF ID '1' QFI ID '1' with '150'mbps
    ${Tp_DL}    Get SA UE'1' 'dl' tput on on PDU '1' QFI '1'
    ${Tp_UL}    Get SA UE'1' 'ul' tput on on PDU '1' QFI '1'
    Run Keyword And Continue On Failure    Wait 'dl' TPut get Target of '700'mbps on UE '1' of PDU ID '1'
    Run Keyword And Continue On Failure    Wait 'ul' TPut get Target of '130'mbps on UE '1' of PDU ID '1'    
    [Teardown]    run keywords      run keyword and ignore error    SA 5G UE '1'-'1' Detach
    ...      AND    Common Test Teardown    debug


*** Keywords ***
Check UE Tput
    #ute_wtssim.Execute Egate Command    cmd=ue_stats_nr id=1-6 type=pusch,pdsch scell=0-31    pass_regexp=EGATE>
    ute_wtssim.Execute Egate Command    cmd=ue_stats_nr id=1 type=pusch,pdsch scell=0

SA Attach
    [Arguments]    ${ue_id}    ${pdu_id}=1    ${trf_type}='internal'
    # Set UEC Reordering Timer
    SA 5G Attach    ue_id=${ue_id}
    Sleep    1s
    Run Keyword If    ${trf_type}=='internal'    SA Set Traffic Type To internal    ue_id=${ue_id}    pdu_id=${pdu_id}
    Run keyword Unless    ${trf_type}=='internal'    SA Set Traffic Type To external    ue_id=${ue_id}    pdu_id=${pdu_id}
    Sleep    1s
    ${output}    SA 5G PDU Session Setup    ${ue_id}    pdu_id=${pdu_id}
    Sleep    1s
