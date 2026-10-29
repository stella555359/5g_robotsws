*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CLOUD_R4LAPO_CUS
...               release-SBTS24R1    team-CN3ET    owner-lixia.zhou
Resource          ../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    LNBTS:actUeBasedAnrIntraFreqLte=true
...    LNBTS:actUeBasedAnrInterFreqLte=false
...    LNBTS:actUeBasedAnrUtran=false
...    LNBTS:anrOmExtEnable=false
...    LNBTS/ANRPRL-0:actAlsoForUeBasedANR=true
...    LNBTS:actLTES1Ho=false
...    LNBTS:actIfHo=disabled
...    LNCEL-1:phyCellId=1
...    LNCEL-1:drxProfile101:drxInactivityT=10
...    LNCEL-1:drxProfile102:drxInactivityT=2560
...    LNCEL-1:drxProfile103:drxInactivityT=20
...    LNCEL-1/LNCEL_TDD-0:earfcn=38000
...    LNCEL-1:inactivityTimer=3000
...    LNCEL:a2TimeToTriggerActInterFreqMeas=${EMPTY}
...    LNCEL-1:threshold2aHpue=${EMPTY}
...    LNBTS/ANR-0:actX2IpV4Prioritization=true
...    @{IPV6}

@{IPV6}
...    MRBTS-1/LNBTS-1/TRSNW-1:cPlane:ipV6AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1
...    MRBTS-1/LNBTS-1/TRSNW-1:uPlane:ipV6AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1
...    MRBTS-1/MNL-1/MNLENT-1/FEATCADM-1/FEATLADM-1:actDualStackIpV4V6ForS1X2=true
...    MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1:localIpAddr=2a00:8a00:4000:4101:4000:1:1:201
...    MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1:localIpPrefixLength=64

@{LNADJ-255_ipv4}    LNBTS/LNADJ-255:cPlaneIpAddr=10.0.1.30  
...     LNBTS/LNADJ-255:x2LinkStatus=available
...     LNBTS/LNADJ-255:cPlaneIpAddrCtrl=enbControlled
...     LNBTS/LNADJ-255:plmnId:mcc=262
...     LNBTS/LNADJ-255:plmnId:mnc=3
...     LNBTS/LNADJ-255:plmnId:mncLength=2
...     LNBTS/LNADJ-255:adjEnbId=2

@{LNADJ-254_ipv6}    LNBTS/LNADJ-254:cPlaneIpAddr=2a00:8a00:4000:4101:4000:1:1:203   
...     LNBTS/LNADJ-254:x2LinkStatus=available
...     LNBTS/LNADJ-254:cPlaneIpAddrCtrl=enbControlled
...     LNBTS/LNADJ-254:plmnId:mcc=262
...     LNBTS/LNADJ-254:plmnId:mnc=3
...     LNBTS/LNADJ-254:plmnId:mncLength=2
...     LNBTS/LNADJ-254:adjEnbId=3

@{LNADJ-253_ipv4}    LNBTS/LNADJ-253:cPlaneIpAddr=10.0.1.34
...     LNBTS/LNADJ-253:x2LinkStatus=available
...     LNBTS/LNADJ-253:cPlaneIpAddrCtrl=enbControlled
...     LNBTS/LNADJ-253:plmnId:mcc=262
...     LNBTS/LNADJ-253:plmnId:mnc=3
...     LNBTS/LNADJ-253:plmnId:mncLength=2
...     LNBTS/LNADJ-253:adjEnbId=4

${ue_eutra_capabilities}    CD9FF419B2C10381FFFFFFFFF2022082008295050060B3FFFFFFFE011FFFFFFFF1608000

*** Test Cases ***
CB012471-SR-A-B1_ET_01_01_Feature_activation_and_online_change_then_X2_setup_with_local_LTE1048_off_and_remote_12471_off
    Attach UE and trigger anr to create LNADJ    ue_id=1    cell_id=1    cgi=262:03|0x204
    Check LNADJ-255 with ipv4 should exist and x2 availble
    Online change to disable CB012471
    Attach UE and trigger anr to create LNADJ    ue_id=2    cell_id=1    cgi=262:03|0x304
    Check LNADJ-254 with ipv6 should exist and x2 availble
    Online change to enable CB012471
    Attach UE and trigger anr to create LNADJ    ue_id=3    cell_id=1    cgi=262:03|0x404
    Check LNADJ-253 with ipv4 should exist and x2 availble    
    Check LNADJ-254 with ipv6 should exist and x2 availble

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs
    execute egate command    trace_sim on mme=1 protocol=s1
    execute egate command    ue_mme_param id=1-10 spid=20
    FOR    ${ue_id}    IN RANGE    1    21
        Create UE Alias    UE_${ue_id}    ue_id=${ue_id}    id_type=cus
    END
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    ENB_2    enb_id=2    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts

Modify Yaml
    Update Yaml    BASE_STATIONS/1    x2: 2a00:8a00:4000:4101:4000:1:1:201
    Add Yaml    BASE_STATIONS
    ...    - id: 2
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1: 10.0.1.31
    ...      x2: 10.0.1.30/2a00:8a00:4000:4101:4000:1:1:202/64
    ...      x2_peers: 'none'
    ...      cells:      
    ...        - {id: 22, technology: lte, tdd_cell: yes, duplex_mode: TDD, tac: 33, pci: '3:1', earfcn: '38000:38000', bw: 20}

    Add Yaml    BASE_STATIONS
    ...    - id: 3
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1: 10.0.1.33
    ...      x2: 10.0.1.32/2a00:8a00:4000:4101:4000:1:1:203/64
    ...      x2_peers: 'none'
    ...      cells:      
    ...        - {id: 23, technology: lte, tdd_cell: yes, duplex_mode: TDD, tac: 33, pci: '3:2', earfcn: '38000:38000', bw: 20}
 
    Add Yaml    BASE_STATIONS
    ...    - id: 4
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1: 10.0.1.35
    ...      x2: 10.0.1.34/2a00:8a00:4000:4101:4000:1:1:204/64
    ...      x2_peers: 'none'
    ...      cells:      
    ...        - {id: 24, technology: lte, tdd_cell: yes, duplex_mode: TDD, tac: 33, pci: '3:0', earfcn: '38000:38000', bw: 20}

Online change to disable CB012471
    Delta Commission Parameters    LNBTS/ANR-0:actX2IpV4Prioritization=false

Online change to enable CB012471
    Delta Commission Parameters    LNBTS/ANR-0:actX2IpV4Prioritization=true

Attach UE
    [Arguments]    ${ue_id}    ${enb_id}    ${cell_id}
    ${V_1}    catenate
    ...    ue_attach id=${ue_id} enb=${enb_id} cell=${cell_id} ue_eutra_capabilities=${ue_eutra_capabilities}
    execute uex command    ${V_1}

Report Intra-freq A3 report
    [Arguments]    ${wait_string}    ${ue}=1    ${pci}=22
    Execute Uex Command    ue_measurement_send id=${ue} event=A3 srsrp=60 srsrq=15 phycell_id=${pci} nrsrp=90 nrsrq=34    

set RSC CGI auto report 
    [Arguments]    ${ue_id}=1    ${cgi}=262:03|0x204
    ${cmd}    catenate
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=purpose with_value=reportStrongestCells action=measurement_send 
    ...    phycell_id=22 nrsrp=97 nrsrq=34 earfcn=38000 strongest=eutra son=true
    ...    ecgi=${cgi} tac=33 
    Execute Uex Command    ${cmd}

Attach UE and trigger anr to create LNADJ
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${cgi}=262:03|0x204
    set RSC CGI auto report    ue_id=${ue_id}    cgi=${cgi}
    Attach UE    ue_id=${ue_id}    enb_id=1    cell_id=${cell_id}
    Report Intra-freq A3 report    wait_string=drx-Config release    ue=${ue_id}    pci=22
    Report Intra-freq A3 report    wait_string=X2AP Link with ENB-1 .* is up    ue=${ue_id}    pci=22


Check LNADJ-255 with ipv4 should exist and x2 availble
    Object Should Exist    ${LNADJ-255_ipv4}

Check LNADJ-254 with ipv6 should exist and x2 availble
    Object Should Exist    ${LNADJ-254_ipv6}

Check LNADJ-253 with ipv4 should exist and x2 availble
    Object Should Exist    ${LNADJ-253_ipv4}
