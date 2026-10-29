*** Settings ***
Documentation     UC:LNADJ exchange in case max LNADJ limit is reached and reportCGI is received
...               I.LTE1685.020 \ \ LNADJ exchange in case max LNADJ limit is reached and reportCGI is received \ \ \ \ \ \ \ \ Default frequency/pci
...               distribution over testline cells if not otherwise mentioned in test instance description in rows below \ \ \ \ \ \ tObserve set to
...               5 min via swConfig flag \ cell frequency band frequency pci \ idleTimeThresLteNR set to 96 \ eNB A cell 1 fb1 f1 pci1 \ idleTimeTh
...               resX2 set to 96 \ \ \ eNB A cell 2 fb1 f1 pci2 \ idleTimeThresNbeNB set to 96 \ eNB B cell 1 fb1 f1 pci3 \ eNB C cell 1 a3offset se
...               t to 0 dB \ eNB B cell 2 fb1 f1 pci4 \ \ \ LNADJ/LNADJL/LNREL objects for eNB E, F, G, H, I present in local eNB C as described wit
...               hout any pci/frequency collisions and without any HO or user traffic \ eNB B cell 3 fb1 f2 pci5 \ \ \ \ \ eNB C cell 1 fb1 f1 pci6
...               \ \ \ eNB D cell 1,2,3 fb2 f3 pci7,pci8,pci9 \ number of inter-RAT neighbor related objects eNB C (WCDMA + GERAN +1XRTT) in default
...               configuration: 40+36+1+0+0+0=77(This case only set 9) \
Suite Setup       Common Suite Setup And Setup Cus Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_TDD    RAN_4G    RAN_4G_TDD    CIT
...               CLOUD_R4LAPO_CUS    release-TL16A    ulm    owner-kang.xiang
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
${BTS_INFO.LNBTS}    LNBTS-1
${SIM_ENB1_BTS_INFO.ID}    2
${CELL1_INFO.LNCELL}    LNCEL-1
${SIM_ENB1_BTS_INFO.IP}    10.0.1.31
${Enable_LTE1685}    ${BTS_INFO.LNBTS}/ANR-0:actAutoLteNeighRemoval=true
@{delete_neighbour_local}
...  delete:LNADJ.*
...  delete:LNREL.*
@{PARAMS_IN_SWCONFIG}
...  0x0012000B=${tObserv}
${tObserv}        5
${idleTimeThresNbEnbExch}    1
${SIM_ENB2_CELL1_PCI}    101
@{Transient_6265_RAISED}
...  Reported alarm.*6265
# Maximum number of neighbor eNBs/cells exceeded
${LNADJ-18}       LNADJ-18:adjEnbId=18
${LNADJ-17}       LNADJ-17:adjEnbId=5
${LNADJ-16}       LNADJ-16:adjEnbId=${SIM_ENB1_BTS_INFO.ID}
${LNADJ-15}       LNADJ-15:adjEnbId=15
${LNADJ-14}       LNADJ-14:adjEnbId=14
${LNADJ-255}      LNADJ-255:adjEnbId=255
${LNADJ-12}       LNADJ-12:adjEnbId=12
${LNADJ-254_Nonexist}    LNADJ-254:adjEnbId=3
@{PARAMS_IN_SCF}
...  ${BTS_INFO.LNBTS}/ANR-0:actAutoLteNeighRemoval=false
...  ${BTS_INFO.LNBTS}/ANR-0:anrIdleTimeThresLte:idleTimeThresNbEnbExch=${idleTimeThresNbEnbExch}
...  ${BTS_INFO.LNBTS}:maxNumOfLnadjLimit=7
...  ${BTS_INFO.LNBTS}/ANR-0:anrIdleTimeThresLte:nbEnbExchWaitTmr=1
...  ${BTS_INFO.LNBTS}/ANR-0:anrIdleTimeThresLte:idleTimeThresLteNR=72
...  ${BTS_INFO.LNBTS}/ANR-0:anrIdleTimeThresLte:idleTimeThresX2=80
...  ${BTS_INFO.LNBTS}/ANR-0:anrIdleTimeThresLte:idleTimeThresNbeNB=48
...  ${BTS_INFO.LNBTS}:actUeBasedAnrIntraFreqLte=true
...  @{delete_neighbour_local}

${ue_eutra_capabilities}    SEPARATOR=
...    CD9FF4F9B2E7500010610102912464D0312040E07FFFFFFFFCA18800182008295020022A0060B3FFFFFFFE014FFFFFFFFC

*** Test Cases ***
I.LTE1685.020_Instance_03
    [Documentation]    "oamControlled LNADJ-18 for eNB E present, link status unavailable, no LNADJL/LNREL objects configured (no set),
    ...    oamControlled LNADJ-17 \ for eNB D present, link status available, LNADJL objects present, LNREL objects present, removeAllowed set to tru
    ...  e
    ...    (no set),
    ...    oamControlled LNADJ-16 for eNB B present, link status available, LNADJL objects present, no LNREL objects present (no set),
    ...    enbControlled LNADJ-15 for eNB F present, link status unavailable, LNADJL objects present, LNREL objects present, removeAllowed set to fal
    ...  se
    ...    (no set),
    ...    oamControlled LNADJ-14 for eNB G present, link status unavailable, LNADJL objects present, LNREL objects present, removeAllowed set to tru
    ...  e
    ...    (no set),
    ...    oamControlled LNADJ-255 for eNB H present, link status unavailable, LNADJL objects present, no LNREL objects present (no set),
    ...    oamControlled LNADJ-12 for eNB I present, link status unavailable, no LNADJL/LNREL objects present (no set)
    ...    "
    [Tags]
    Create Neighbour Relation With Sim Neighbour eNBs
    Delta Commission Parameters    ${Enable_LTE1685}
    Wait idleTimeThresNbEnbExch Expiry
    Cus UE attach to eNB1 and trigger CGI Report
    Cus Report Intra-freq A3
    Check No LANDJ Exchange Happen
    Check Alarm 6265 Raised

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup Cus Env    tl_type=3CELLs    ue_count=10
    #Debug Enter Into Egate
    Create Alias

Create Alias
    Create UE Alias    UE_1    ue_id=1    id_type=cus

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
    ...        - {id: 2, technology: lte, tac: 33, pci: '10:2', earfcn: '38000:38000', duplex_mode: 'TDD'}
    ...        - {id: 3, technology: lte, tac: 33, pci: '11:0', earfcn: '38100:38100', duplex_mode: 'TDD'}
    Add Yaml    BASE_STATIONS
    ...    - id: 3
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1: 10.0.1.32
    ...      x2_peers: none
    ...      cells:
    ...        - {id: 1, technology: lte, tac: 33, pci: '33:2', earfcn: '38000:38000', duplex_mode: 'TDD'}
    Add Yaml    BASE_STATIONS
    ...    - id: 5
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1: 10.0.1.33
    ...      x2_peers: none
    ...      cells:
    ...        - {id: 1, technology: lte, tac: 33, pci: '67:0', earfcn: '39750:39750', duplex_mode: 'TDD'}
    ...        - {id: 2, technology: lte, tac: 33, pci: '67:1', earfcn: '39750:39750', duplex_mode: 'TDD'}
    ...        - {id: 3, technology: lte, tac: 33, pci: '67:2', earfcn: '39750:39750', duplex_mode: 'TDD'}

Cus UE attach to eNB1
    [Arguments]    ${ueid}=1    ${cellid}=1    ${ue_eutra_capabilities}=${ue_eutra_capabilities}    ${sleeptime}=0
    Execute Uex Command    ue_param id=${ueid} csfb_rat=utran_geran voice_domain_preference=lte_preferred
    Execute Uex Command    ue_param id=${ueid} ue_eutra_capabilities=${ue_eutra_capabilities}
    Execute Uex Command    ue_attach id=${ueid} cell=${cellid} selected_plmn=262:03
    sleep    ${sleeptime}

Cus UE attach to eNB1 and trigger CGI Report
    ${reportStrongestCells_message}    catenate
    ...    purpose contains ('reportStrongestCells')
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionReconfiguration ( ${reportStrongestCells_message} )
    ...    UE_1:RRC_RRCConnectionReconfiguration ( cellForWhichToReportCGI eq 101 )
    ...    alias=LTE1685_020_flow1    overall_timeout=30
    ${cgi_report_command}=    Catenate
    ...    ue_rrc_reconf_param id=1 if_contains=purpose with_value=reportStrongestCells
    ...    action=measurement_send id=1 phycell_id=101 nrsrp=97 nrsrq=34 srsrp=60 srsrq=15
    ...    ecgi=262:03|0x301 strongest=eutra son=true tac=33 earfcn=38000
    Execute Uex Command    ${cgi_report_command}
    Cus UE attach to eNB1
    Flow Occurred As Expected    LTE1685_020_flow1

Cus Report Intra-freq A3
    Execute Uex Command    ue_measurement_send id=1 srsrp=60 srsrq=15 phycell_id=101 nrsrp=90 nrsrq=34 event=A3
    Check Ue Location    ueid=1    wait_string=1

Wait idleTimeThresNbEnbExch Expiry
    sleep    ${${idleTimeThresNbEnbExch}*${tObserv}*60}s

Iphy Report Intra-freq RSC
    [Arguments]    ${wait_string}    ${ue}=${UE1}    ${pci}=${SIM_ENB2_CELL1_INFO.PCI}
    Execute Uex Command
    ...  ue_measurement_send meas_id=${MEASID_INTRAF_RSC} id=${ue} srsrp=60 srsrq=15 phycell_id=${pci} nrsrp=90 nrsrq=34  ${wait_string}

Check Ue Location
    [Arguments]    ${ueid}    ${wait_string}
    ${ue_info}    Execute UEx Command    get_ue_info id=${ueid}
    ${cell_id}=      Convert To String     ${ue_info["cell"]}
    should be equal    ${cell_id}    ${wait_string}

Create Neighbour Relation With Sim Neighbour eNBs
    ${delta_parameters_Inter_RAT}  Create List  LNADJW-1:uTargetCid=1  LNADJW-1:uTargetFreq=1  LNADJW-1:uTargetScFdd=1  LNADJG-1:gTargetCi=1
    ...  ${CELL1_INFO.LNCELL}/LNRELG-1:ci=1
    ...  LNADJG-2:gTargetCi=2  ${CELL1_INFO.LNCELL}/LNRELG-2:ci=2  LNADJX-1:arfcn=1  ${CELL1_INFO.LNCELL}/LNRELX-1:cellId=1  LNADJX-2:arfcn=2
    ...  ${CELL1_INFO.LNCELL}/LNRELX-2:cellId=2
    Delta Commission Parameters    ${delta_parameters_Inter_RAT}
    ${delta_parameters_LNADJ_LNADJL}  Create List  LNADJ-18:cPlaneIpAddr=1.1.1.18  LNADJ-18:adjEnbId=18  LNADJ-18:cPlaneIpAddrCtrl=oamControlled
    ...  LNADJ-17:cPlaneIpAddr=10.0.1.33  LNADJ-17:adjEnbId=5
    ...  LNADJ-17:cPlaneIpAddrCtrl=oamControlled  LNADJ-16:cPlaneIpAddr=${SIM_ENB1_BTS_INFO.IP}  LNADJ-16:adjEnbId=${SIM_ENB1_BTS_INFO.ID}
    ...  LNADJ-16:cPlaneIpAddrCtrl=oamControlled  LNADJ-15:cPlaneIpAddr=1.1.1.15  LNADJ-15:adjEnbId=15
    ...  LNADJ-15:cPlaneIpAddrCtrl=enbControlled  LNADJ-15/LNADJL-15:ecgiLcrId=1  LNADJ-15/LNADJL-15:phyCellId=15  LNADJ-14:cPlaneIpAddr=1.1.1.14
    ...  LNADJ-14:adjEnbId=14  LNADJ-14:cPlaneIpAddrCtrl=oamControlled
    ...  LNADJ-14/LNADJL-14:ecgiLcrId=1  LNADJ-14/LNADJL-14:phyCellId=14  LNADJ-255:cPlaneIpAddr=1.1.1.155  LNADJ-255:adjEnbId=255
    ...  LNADJ-255:cPlaneIpAddrCtrl=oamControlled  LNADJ-255/LNADJL-255:ecgiLcrId=1
    ...    LNADJ-255/LNADJL-255:phyCellId=254    LNADJ-12:cPlaneIpAddr=1.1.1.12    LNADJ-12:adjEnbId=12    LNADJ-12:cPlaneIpAddrCtrl=oamControlled
    Delta Commission Parameters    ${delta_parameters_LNADJ_LNADJL}
    ${delta_parameters_del_unused_LNADJL}    Create List    delete:LNADJ-18/LNADJL.*    delete:LNADJ-12/LNADJL.*
    Delta Commission Parameters    ${delta_parameters_del_unused_LNADJL}
    ${delta_parameters_LNREL}  Create List  ${CELL1_INFO.LNCELL}\/LNREL-17:ecgiAdjEnbId=5  ${CELL1_INFO.LNCELL}\/LNREL-17:ecgiLcrId=1
    ...  ${CELL1_INFO.LNCELL}\/LNREL-17:removeAllowed=true  ${CELL1_INFO.LNCELL}\/LNREL-17:ecgiAdjEnbId=5  ${CELL1_INFO.LNCELL}\/LNREL-17:ecgiLcrId=2
    ...  ${CELL1_INFO.LNCELL}\/LNREL-17:removeAllowed=true  ${CELL1_INFO.LNCELL}\/LNREL-17:ecgiAdjEnbId=5  ${CELL1_INFO.LNCELL}\/LNREL-17:ecgiLcrId=3
    ...  ${CELL1_INFO.LNCELL}\/LNREL-17:removeAllowed=true  ${CELL1_INFO.LNCELL}\/LNREL-15:ecgiAdjEnbId=15
    ...  ${CELL1_INFO.LNCELL}\/LNREL-15:ecgiLcrId=1
    ...  ${CELL1_INFO.LNCELL}\/LNREL-15:removeAllowed=false  ${CELL1_INFO.LNCELL}\/LNREL-14:ecgiAdjEnbId=14
    ...  ${CELL1_INFO.LNCELL}\/LNREL-14:ecgiLcrId=1  ${CELL1_INFO.LNCELL}\/LNREL-14:removeAllowed=true
    Delta Commission Parameters    ${delta_parameters_LNREL}

Check No LANDJ Exchange Happen
    Object Should Exist    ${LNADJ-18}
    Object Should Exist    ${LNADJ-17}
    Object Should Exist    ${LNADJ-16}
    Object Should Exist    ${LNADJ-15}
    Object Should Exist    ${LNADJ-14}
    Object Should Exist    ${LNADJ-255}
    Object Should Exist    ${LNADJ-12}
    Object Should Not Exist    ${LNADJ-254_Nonexist}

Check Alarm 6265 Raised
    ${fault6265}    create list    fault_id=6265    severity=transient
    fm fault should be raised    ${fault6265}
