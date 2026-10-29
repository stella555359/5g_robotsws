*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_TDD    RAN_4G    RAN_4G_TDD    CIT
...               CLOUD_R4LAPO_CUS    OAM2    release-TL16A    old_owner-min.2.jiang    owner-kang.xiang
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...  ${BTS_INFO.LNBTS}:actUeBasedAnrIntraFreqLte=true
...  ${BTS_INFO.LNBTS}:actUeBasedAnrInterFreqLte=false
...  ${BTS_INFO.LNBTS}:actUeBasedAnrUtran=false
...  ${BTS_INFO.LNBTS}:anrOmExtEnable=false
...  ${BTS_INFO.LNBTS}/ANRPRL-0:actAlsoForUeBasedANR=true
...  ${BTS_INFO.LNBTS}:actLTES1Ho=false
...  ${BTS_INFO.LNBTS}:actIfHo=disabled
...  ${CELL1_INFO.LNCELL}:phyCellId=${CELL1_INFO.PCI}
...  ${CELL1_INFO.LNCELL}:drxProfile101:drxInactivityT=10
...  ${CELL1_INFO.LNCELL}:drxProfile102:drxInactivityT=2560
...  ${CELL1_INFO.LNCELL}:drxProfile103:drxInactivityT=20
...  ${CELL1_INFO.LNCELL}/LNCEL_TDD-0:earfcn=${SIM_ENB1_CELL1_INFO.EARFCN}
...  ${CELL1_INFO.LNCELL}:inactivityTimer=3000
...  @{Delete_Neighbour_MO}
@{PARAMS_IN_VENDOR}
...  LNBTS:anrLTEIntraRscReportAmount=16
@{Delete_Neighbour_MO}
...  delete:LNADJ.*
...  delete:LNREL.*
${BTS_INFO.LNBTS}    LNBTS-1
${CELL1_INFO.PCI}    1
${SIM_ENB1_CELL1_INFO.EARFCN}    38000
${CELL1_INFO.LNCELL}    LNCEL-1

*** Test Cases ***
LTE782-b2 ANR successful in passive Mode
    [Tags]
    Cus UE attach to eNB1 and trigger CGI Report
    Cus Report Intra-freq A3
    Release All Ues
    Check LNADJ And LNREL

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc on
    Create Alias

Create Alias
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create mme alias    MME_1    mme_id=1    id_type=wts
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    ENB_2    enb_id=2    id_type=wts

Modify Yaml
    # add sim enb2
    Add Yaml    BASE_STATIONS
    ...    - id: 2
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1: 10.0.1.31
    ...      x2_peers: none
    ...      cells:
    ...        - {id: 1, technology: lte, tac: 33, pci: '10:1', earfcn: '38000:38000', duplex_mode: 'TDD'}

Check LNADJ And LNREL
    Object Should Exist    LNADJ:adjEnbId=2
    Object Should Exist    LNCEL-1\/LNREL-388:ecgiAdjEnbId=2

Cus UE attach to eNB1 and trigger CGI Report
    ${reportStrongestCells_message}    catenate
    ...    purpose contains ('reportStrongestCells')
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionReconfiguration ( ${reportStrongestCells_message} )
    ...    UE_1:RRC_RRCConnectionReconfiguration ( cellForWhichToReportCGI eq 31 )
    ...    alias=LTE782_b2_flow1    overall_timeout=30
    ${cgi_report_command}=    Catenate
    ...    ue_rrc_reconf_param id=1 if_contains=purpose with_value=reportStrongestCells
    ...    action=measurement_send id=1 phycell_id=31 nrsrp=90 nrsrq=34 srsrp=60 srsrq=15
    ...    ecgi=262:03|0x201 strongest=eutra son=true tac=33 earfcn=38000
    Execute Uex Command    ${cgi_report_command}
    Cus UE attach to eNB1    ue_eutra_capabilities=CD9FF419B2C10381FFFFFFFFF2022082008295050060B3FFFFFFFE011FFFFFFFF1608000
    Flow Occurred As Expected    LTE782_b2_flow1

Cus UE attach to eNB1
    [Arguments]    ${ueid}=1    ${cellid}=1    ${ue_eutra_capabilities}=${ue_eutra_capabilities}    ${sleeptime}=0
    Execute Uex Command    ue_param id=${ueid} csfb_rat=utran_geran voice_domain_preference=lte_preferred
    Execute Uex Command    ue_param id=${ueid} ue_eutra_capabilities=${ue_eutra_capabilities}
    Execute Uex Command    ue_attach id=${ueid} cell=${cellid} selected_plmn=262:03
    sleep    ${sleeptime}

Cus Report Intra-freq A3
    Expect Message Flow
    ...    MME_1:S1AP_ENBConfigurationTransfer
    ...    MME_1:S1AP_MMEConfigurationTransfer
    ...    ENB_1:X2AP_X2SetupRequest
    ...    ENB_2:X2AP_X2SetupResponse
    ...    alias=LTE782_b2_flow2    overall_timeout=30
    Execute Uex Command    ue_measurement_send id=1 srsrp=60 srsrq=15 phycell_id=31 nrsrp=90 nrsrq=34 event=A3
    Flow Occurred As Expected    LTE782_b2_flow2
    Wait Until Keyword Succeeds    20s    5s    Check Ue Enb Location    ueid=1    wait_string=2

Check Ue Enb Location
    [Arguments]    ${ueid}    ${wait_string}
    ${ue_info}    Execute UEx Command    get_enb_id ue=${ueid}
    ${enb_id}=      Convert To String     ${ue_info}
    should be equal    ${enb_id}    ${wait_string}