*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4P    owner-chao.3.zhang
...               team-DevHZ5_SG8    release-SBTS18SP
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...  @{PARAMS_FOR_MME2}
...  @{Delete Neighbour Relation}
...  @{Delete_RELATION_ERROR}
...  @{PARAMS_FOR_ENB2}
@{Delete Neighbour Relation}
...  delete:LNREL.*
...  delete:LNADJW.*
...  delete:LNRELW.*
...  delete:LNADJG.*
...  delete:LNADJX.*
@{Delete_RELATION_ERROR}
...  delete:LNCEL.*:defaultLnRelGnbCellId
@{PARAMS_FOR_MME2}
...  LNBTS/LNMME-1:administrativeState=unlocked
...  LNBTS/LNMME-1:ipAddrPrim=10.0.1.4
...  LNBTS/LNMME-1:mmeRatSupport=Wideband-LTE
...  LNBTS/LNMME-1:transportNwId=0
@{PARAMS_FOR_ENB2}
...  MRBTS-1/LNBTS-1/LNADJ-1:rlfBasedRCRsupported=false
...  MRBTS-1/LNBTS-1/LNADJ-1:cPlaneIpAddrCtrl=oamControlled
...  MRBTS-1/LNBTS-1/LNADJ-1:adjEnbId=2
...  MRBTS-1/LNBTS-1/LNADJ-1:cPlaneIpAddr=10.0.1.31
...  MRBTS-1/LNBTS-1/LNADJ-1:plmnId:mcc=262
...  MRBTS-1/LNBTS-1/LNADJ-1:plmnId:mnc=3
...  MRBTS-1/LNBTS-1/LNADJ-1:plmnId:mncLength=2
...  LNADJ-1/LNADJL-1:ecgiLcrId=1
...  LNADJ-1/LNADJL-1:fDlEarfcn=1450
...  LNADJ-1/LNADJL-1:phyCellId=1
...  LNADJ-1/LNADJL-1:tac=33
...  LNADJ-1/LNADJL-1:bcPlmnIdList:mcc=262
...  LNADJ-1/LNADJL-1:bcPlmnIdList:mnc=3
...  LNADJ-1/LNADJL-1:bcPlmnIdList:mncLength=2
@{PARAMS_FOR_cPlaneIpAddrCtrl_enbControlled}
...  MRBTS-1/LNBTS-1/LNADJ-1:cPlaneIpAddrCtrl=enbControlled
@{PARAMS_FOR_cPlaneIpAddrCtrl_oamControlled}
...  MRBTS-1/LNBTS-1/LNADJ-1:cPlaneIpAddrCtrl=oamControlled
${S1_CONNECTIVITY_FAULT_ID}    6202
${X2_CONNECTIVITY_FAULT_ID}    6203
${simulated_enb}    eth3:simeNB1
${wait_no_expected_output}    EGATE>

*** Test Cases ***
LBT2445_Automated_BTS_Startup_Reset_With_OamControlled_X2_Link
    [Tags]    RAN_4G    RAN_4G_FDD    CDRT
    Egate Stopped And Then Started To Check No Transport Connection Failure Alarm For X2
    [Teardown]    Common Test Teardown and Recover Env

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD

Modify Yaml
    Add Yaml    EPC/MME_POOL_AREA
    ...    - id: 2
    ...    plmn: '777:10'
    ...    mmegi: 2
    ...    tac_list: 33,1,2,3
    Add Yaml    EPC/MME_POOL_AREA
    ...    - id: 3
    ...    plmn: '262:04'
    ...    mmegi: 3
    ...    tac_list: 33,1,2,3
   Add Yaml      EPC/RNC
    ...    - id: 1
    ...    host_enb: 5
    ...    rnc_id: 1
    ...    lac: 1
    ...    plmn: '262:03'
    Add Yaml      EPC/RNC
    ...    - id: 2
    ...    host_enb: 6
    ...    rnc_id: 2
    ...    lac: 3
    ...    plmn: '777:10'
    Add Yaml      EPC/RNC
    ...    - id: 3
    ...    host_enb: 7
    ...    rnc_id: 3
    ...    lac: 2
    ...    plmn: '262:04'
    Update Yaml    EPC/MME_POOL_AREA/1    tac_list: 33
    # origin case include 2 MME pool
    Update Yaml    EPC/MME/1    pool: ['1:1', '2:1']

    Add Yaml    BASE_STATIONS
    ...    - id: 2
    ...    type: simulated
    ...    plmn: '262:03'
    ...    s1: 10.0.1.31
    ...    cells:
    ...        - {id: 21, technology: lte, tac: 33, pci: '3:0', earfcn: '1450:19450', bw: 20}

Egate Stopped And Then Started To Check No Transport Connection Failure Alarm For X2
    Stop Egate And Simulated Enb Interface
    Wait Until Keyword Succeeds    120s    10s    Check Enb Status Should Be    Configured
    Start Simulated Enb Interface And Egate
    Fm Fault Should Be Cleared    fault_id=${X2_CONNECTIVITY_FAULT_ID}    timeout=60s
	Execute Uex Command    ue_attach id=1 cell=1

Stop Egate And Simulated Enb Interface
    [Documentation]    In suitesetup, sudo ifconfig eth3:simeNB1 10.0.1.31/24 up
    Execute Egate Command    sim_stop    pass_regexp=SM: CHANGE STATE: CONFIGURED
    Execute Cmd On Pc    sudo ifconfig ${simulated_enb} down
    ${cmd_result}    Execute Cmd On Pc    sudo ifconfig
    Should Not Contain    ${cmd_result}    ${simulated_enb}:

Start Simulated Enb Interface And Egate
    Delta Commission Parameters    ${PARAMS_FOR_cPlaneIpAddrCtrl_oamControlled}
    Execute Cmd On Pc    sudo ifconfig ${simulated_enb} 10.0.1.31/24 up
    ${cmd_result}    Execute Cmd On Pc    sudo ifconfig
    Should Contain    ${cmd_result}    ${simulated_enb}:
    Execute Egate Command    start version_check=off
    Cells Should Be OnAir

Common Test Teardown and Recover Env
    Start Simulated Enb Interface And Egate
    Execute Egate Command    link_unlock link=s1 at=mme:2 to=enb:1    pass_regexp=${wait_no_expected_output}
    Execute Egate Command    link_unlock link=x2 at=enb:2 to=enb:1    pass_regexp=${wait_no_expected_output}
    Common Test Teardown And Stop Capture Logs

Check Enb Status Should Be
    [Arguments]    ${enb_status}
    ${ENB_starus}    Get Mrbts State
    Should Be Equal    "${ENB_starus}"    "${enb_status}"
