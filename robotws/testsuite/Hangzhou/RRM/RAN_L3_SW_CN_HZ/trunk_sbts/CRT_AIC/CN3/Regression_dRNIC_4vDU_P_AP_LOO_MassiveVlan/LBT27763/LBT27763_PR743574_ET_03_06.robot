*** Settings ***
Documentation
...    author: kang.xiang
Suite Setup    Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    QCD_MN_RAN    QCP_RAN_ET    vDUCNF00    RAN_Aic    RAN_5G    CRT    CLOUD_5GC_dRNIC_4vDU_P_AP_LOO_DC_MassiveVlan
...    VARIANT_SANSA_FS_ECPRI_CMWV_TDD_4CPIF_HA    team-CN3ET    owner-xiujuan.sun    release-SBTS24R3
Resource    ../../../../../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/4du/2cells
@{PARAMS_IN_SCF_CU}    @{Three_ServedAMF}    @{SMALLER_SCTP_TIMER}    @{Smaller_xnSetup_Timer}

@{PARAMS_IN_SCF_DU1}
...    MRBTS-1/NRBTS-1/NRDU-1:remotef1CplaneIpAddr=172.16.1.101

@{PARAMS_IN_SCF_DU2}
...    MRBTS-1/NRBTS-1/NRDU-2:remotef1CplaneIpAddr=172.16.1.102

@{PARAMS_IN_SCF_DU3}
...    MRBTS-1/NRBTS-1/NRDU-3:remotef1CplaneIpAddr=172.16.1.103

@{PARAMS_IN_SCF_DU4}
...    MRBTS-1/NRBTS-1/NRDU-4:remotef1CplaneIpAddr=172.16.1.104
${MULTI_CPIF_FLAG}    True
${REDUNDANT_MODE_CU_FLAG}    True

@{Three_ServedAMF}
...    NRBTS/SERVEDAMF-2:amfIPAddress=10.0.11.2
...    NRBTS/SERVEDAMF-3:amfIPAddress=10.0.11.3
...    NRBTS/SERVEDAMF-4:amfIPAddress=10.0.11.4
...    MRBTS-1/NRBTS-1:actIncXn=true

@{Del_XNLINK_AND_NRADJGNB}    delete:NRADJGNB.*    delete:XNLINK.*

@{SMALLER_SCTP_TIMER}
...    NRBTS/NRSCTP-1:sctpProfile:sctpAssocMaxRetrans=2
...    NRBTS/NRSCTP-1:sctpProfile:sctpHeartbeatInterval=3
...    NRBTS/NRSCTP-1:sctpProfile:sctpPathMaxRetrans=1

@{fault7306}    fault_id=7306    alarming_object=MRBTS-1/NRBTS-1/NRADJGNB-1    fault_name=Xn SCTP endpoint broken
@{fault7307}    fault_id=7307    alarming_object=MRBTS-1/NRBTS-1/NRADJGNB-1    fault_name=Xn SCTP setup fail
@{fault7311}    fault_id=7311    alarming_object=MRBTS-1/NRBTS-1/NRADJGNB-1    fault_name=No Xn link available
@{fault_of_7306testcase}    @{fault7306}    @{fault7311}
@{fault_of_7307testcase}    @{fault7307}    @{fault7311}

@{XNLINK_1}
...    NRBTS/XNLINK-1:cPlaneIpAddr=10.0.12.1
...    NRBTS/XNLINK-1:cPlaneIpAddrCtrl=oamControlled

@{NRADJGNB_1}
...    NRBTS/NRADJGNB-1:gNodeBId=36
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJGNB-1:xnLinkRef=1

# below time frozen to 60, can not modify by pdl limit
@{Smaller_xnSetup_Timer}
...    NRBTS-1:retryXnSetupTmr=60
...    NRBTS-1:xnSetupReqTmr=60
...    NRBTS-1:xnSetupRespTmr=60
${XN_SHUTDOWN_DETECTED}    M55126C00002
${XN_SETUP_REQUEST_SENT}    M55126C00035
${XN_SETUP_RESPONSE_RECEIVED}    M55126C00005
${XN_SETUP_REQUEST_RECEIVED}    M55126C00003
${XN_SETUP_RESPONSE_SENT}    M55126C00004

@{FAULTS_EXCLUDED_CHECKING}
...    7504

@{7306_COUNTER}
...    NRBTS-1:NXNCB:${XN_SHUTDOWN_DETECTED}=1
...    NRBTS-1:NXNCB:${XN_SETUP_REQUEST_RECEIVED}=1
...    NRBTS-1:NXNCB:${XN_SETUP_RESPONSE_SENT}=1
@{7307_COUNTER}
...    NRBTS-1:NXNCB:${XN_SHUTDOWN_DETECTED}=1

*** Test Cases ***
LBT27763-PR743574_ET_03 7306 fault can be raised and cancelled by CPIFs which are belongs to different CPIF group
    [Tags]
    [Documentation]
    ...    This testcase is used to verify: 7306 XnSctpEndpointBrokenAl fault is raised by cpifa and should be cancelled by cpifb
    ...    preconditon:
    ...      the xnlink between cpifa1 and peergnb is available
    ...      the x2link between realgnb and perrgnb is avaiable
    ...    teststeps:
    ...      1. 7306 and 7311 fault are raised by cpifa because of the remote GNB's IP is removed from peergnb
    ...      2. 7306 fault will be cancelled by cpifb after peergnb send xnsetup reques to localGNB and xn link status
    ...         goto avialble and add peergnb's address back
    ...    Checkpoint:
    ...      1. 7303 fault can be cancelled by cpifb.
    ...      2. Counter XN_SHUTDOWN_DETECTED,XN_SETUP_REQUEST_SENT, XN_SETUP_RESPONSE_RECEIVED should increase one.
    [Setup]    testCase_Setup
    [Teardown]    7306_teardown    ${login_to_nwmgment}
    7306_and_7311_fault_should_be_raised_when_xnc_interface_is_down
    7306_and_7311_fault_should_be_cancelled_when_peergnb_send_xnsetupreq_to_another_cpif
    Check Counters Cu Aic    ${7306_COUNTER}

LBT27763-PR743574_ET_06 7307 fault can be raised and cancelled by active CPIF of one CPIF group and can be cancelled after HA
    [Tags]
    [Setup]    testCase_Setup
    [Teardown]    7306_teardown    ${login_to_nwmgment}
    [Documentation]
    ...    7306 XnSctpEndpointBrokenAl fault is raised by cpifa and should be cancelled by cpifb
    ...    preconditon:
    ...      the xnlink between cpifa1 and peergnb is available
    ...    teststeps:
    ...      1. create SA and NSA
    ...      1. 7306 and 7311 fault are raised by cpifa because of the remote GNB's IP is removed from peergnb
    ...      3. 7307 fault will be raised by cpif and 7306 fault will be cancelled after maxxnsetupretry failure.
    ...      2. 7306 fault will be cancelled by cpifb after peergnb send xnsetup reques to localGNB and xn link status
    ...         goto avialble and add peergnb's address back
    ...    Checkpoint:
    ...      1. 7307 fault can be cancelled by cpifb.
    ...      2. Counter
    Execute Cmd On Vcu Container    ip link set xnc down    ${login_to_nwmgment}
    Execute Cmd On Vcu Container    ip link show xnc    ${login_to_nwmgment}

    7306_and_7311_fault_should_be_raised_when_xnc_interface_is_down

    FM Fault Should Be Raised Cu    ${fault7307}    timeout=420
    FM Fault Should Be Cleared Cu    ${fault7306}

    Execute Cmd On Vcu    oc delete pod -n ${VCU_NAMESPACE} ${active_cpif}
    Object Should Exist In Cu    params=XNLINK-1:xnLinkStatus=available    timeout=40
    Fm Fault Should Be Cleared Cu    ${fault_of_7307testcase}
    Check Counters Cu Aic    ${7307_COUNTER}


*** Keywords ***
7306_teardown
    [Arguments]    ${login_to_nwmgment}
    Delta Commission Parameters Cu     ${Del_XNLINK_AND_NRADJGNB}
    Execute Cmd On Vcu Container    ip link show xnc    ${login_to_nwmgment}
    Execute Cmd On Vcu Container    ip link set xnc up    ${login_to_nwmgment}
    Execute Egate Command    xn_gnb_setup_param id=3 reset
    Execute Egate Command    gnb_param id=3 xn_listening_socket=on send_xn_setup=off
    Common Test Teardown And Stop Capture Logs Aic

testCase_Setup
    Common Test Setup And Start To Capture Logs Aic
    Set Precontidion for TestCase and Check XN Available
    Construct_CPIF_List_and_Set_as_Test_Varaible

Set Precontidion for TestCase and Check XN Available
    ${xnparam}    Combine Lists    ${NRADJGNB_1}    ${XNLINK_1}    ${Smaller_xnSetup_Timer}
    Delta Commission Parameters Cu     ${xnparam}
    Object Should Exist In CU    XNLINK-1:xnLinkStatus=available
    Clear Counter Files Cu Aic

Construct_CPIF_List_and_Set_as_Test_Varaible
    [Arguments]
    [Return]
    ${v1}    catenate    oc get pods -n ${VCU_NAMESPACE} --selector='healing-controller.rcpha/service-selector' |grep -E "cpif"| awk '{print $1}'
    ${active_cpifs}    Execute Cmd On Vcu    ${v1}
    ${all_cpifs}    Execute Cmd On Vcu    oc get pods -n ${VCU_NAMESPACE} |grep -E "cpif"| awk '{print $1}'
    Set Test Variable    \${TEST_ACTIVE_CPIF_LIST}    ${active_cpifs.split('\n')}
    Set Test Variable    \${TEST_ALL_CPIF_LIST}    ${all_cpifs.split('\n')}
    Set Test Variable    \${active_cpif}    ${TEST_ACTIVE_CPIF_LIST[1]}
    ${login_to_nwmgment}    Set Variable    oc exec -it -n ${VCU_NAMESPACE} ${active_cpif} -c ctr-nwmgmt -- execwithcaps -q -- bash

    Set Test Variable    \${login_to_nwmgment}

7306_and_7311_fault_should_be_raised_when_xnc_interface_is_down
    Execute Cmd On Vcu Container    ip link set xnc down    ${login_to_nwmgment}
    sleep    60s
    Fm Fault Should Be Raised Cu    ${fault_of_7306testcase}
    Object Should Exist In Cu    XNLINK-1:xnLinkStatus=unavailable

7306_and_7311_fault_should_be_cancelled_when_peergnb_send_xnsetupreq_to_another_cpif
    ${new_active_cpif}    Select Random Value Without Specific Item    ${TEST_ACTIVE_CPIF_LIST}    ${active_cpif}
    ${new_cpifip}    Get From Dictionary    ${CPIF_XN_IP_DIC}    ${new_active_cpif}
    Execute Egate Command    gnb_param id=3 xn_listening_socket=on send_xn_setup=on
    log    this command is used to let the link status of simgnb as broken, no message o realgnb because of realgnb's interface had been broken.
    Execute Egate Command    link_drop link=xn by=gnb:3 to=gnb:2
    Execute Egate Command    gnb_xn_link_up gnb=3 target=2 xn_link_addr=${new_cpifip}    is up
    object Should Exist In CU    XNLINK-1:xnLinkStatus=available
    Fm Fault Should Be Cleared Cu    ${fault_of_7306testcase}


Select Random Value Without Specific Item
    [Arguments]    ${list}    ${specific_item}=${EMPTY}
    [Return]    ${item}
    Remove Values From List    ${list}    ${specific_item}
    ${item}    Evaluate    random.choice(${list})    random


Suite Setup
    Common Suite Setup And Setup Airphone Env Aic 4Du
    ${CPIF_XN_IP_DIC}    Create Dictionary    ute-cpif-0=10.0.12.10    ute-cpifa1-0=10.0.12.11
    ...    ute-cpifa2-0=10.0.12.12    ute-cpifa3-0=10.0.12.13    ute-cpif-1=10.0.12.10    ute-cpifa1-1=10.0.12.11
    ...    ute-cpifa2-1=10.0.12.12    ute-cpifa3-1=10.0.12.13
    Set Suite Variable    \${CPIF_XN_IP_DIC}

Modify Cfg Aic
    ${v1}    catenate    set_enb id=100 plmn=311:489 s1=10.0.1.150 enb_id_macro=0x00013 daemon=$SERVER_IP:$EDAEMON_PORT
    ...    x2=10.0.1.150 x2u=10.0.1.150 type=simulated x2_peers=none
    ${v2}    catenate    set_cell id=1 enb=100 eci=0x0001301 pci=3:2 tac=222 proxy=10.0.2.90:12219|10.0.2.90:8889
    ...    earfcn=2000:20000 mapped_earfcn=4200:22200
    Update Cfg Aic    ${v1}
    Update Cfg Aic    enb_param id=100 drb_id_begin=3 endc_capable_qci=all
    Update Cfg Aic    ${v2}
    Update Cfg Aic    enb_endc_param id=100 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=1:7

    ${v3}    catenate    set_enb id=101 plmn=311:489 s1=10.0.1.149 enb_id_macro=0x00014 daemon=$SERVER_IP:$EDAEMON_PORT x2=10.0.1.149
    ...    x2u=10.0.1.149 type=simulated x2_peers=none
    ${v4}    catenate    set_cell id=1 enb=101 eci=0x0001401 pci=3:2 tac=222 proxy=10.0.2.91:12219|10.0.2.91:8889
    ...    earfcn=2000:20000 mapped_earfcn=4200:22200
    Update Cfg Aic    ${v3}
    Update Cfg Aic    enb_param id=101 drb_id_begin=3 endc_capable_qci=all
    Update Cfg Aic    ${v4}
    Update Cfg Aic    enb_endc_param id=101 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=1:7

    ${v5}    catenate    set_enb id=102 plmn=311:489 s1=10.0.1.148 enb_id_macro=0x00015 daemon=$SERVER_IP:$EDAEMON_PORT
    ...    x2=10.0.1.148 x2u=10.0.1.148 type=simulated x2_peers=none
    ${v6}    catenate    set_cell id=1 enb=102 eci=0x0001501 pci=3:2 tac=222 proxy=10.0.2.92:12219|10.0.2.92:8889
    ...    earfcn=2000:20000 mapped_earfcn=4200:22200
    Update Cfg Aic    ${v5}
    Update Cfg Aic    enb_param id=102 drb_id_begin=3 endc_capable_qci=all
    Update Cfg Aic    ${v6}
    Update Cfg Aic    enb_endc_param id=102 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=1:7

    ${v7}    catenate    set_gnb id=2 type=external plmn=311:489 ng=10.0.11.10,10.0.11.11,10.0.11.12,10.0.11.13 gnb_id=0x01:22
    ...    daemon=$SERVER_IP:$EDAEMON_PORT xn=10.0.12.10,10.0.12.11,10.0.12.12,10.0.12.13 s1u=$GNB_S1U_ADDR
    ...    x2=10.0.1.10,10.0.1.11,10.0.1.12,10.0.1.13 x2u=$GNB_X2U_ADDR x2_peers=none amf=1,20,21,22
    Update Cfg Aic    ${v7}

    ${v8}    catenate    amf_param id=20 reg_procedure_sequence=parallel_init_ctx_setup_req_and_reg_accept
    ...    full_nas_auth=on nia=null+zuc+aes+snow3g nea=null
    ${v9}    catenate    set_upf id=20 daemon=$SERVER_IP:$EDAEMON_PORT ngu=10.0.11.2 dnn=wap2.nokia.com
    ...    devtype=tun devname=tunUPF7 addr=10.12.8.1/24
    Update Cfg Aic    set_amf_region id=20 tac_list=200,280,300,400,500,600 plmn=311:489
    Update Cfg Aic    set_amf id=20 daemon=$SERVER_IP:$EDAEMON_PORT ng=10.0.11.2:38412 region=20 set_id=20 pointer=1
    Update Cfg Aic    ${v8}
    Update Cfg Aic    ${v9}

    ${v10}    catenate    amf_param id=21 reg_procedure_sequence=parallel_init_ctx_setup_req_and_reg_accept
    ...    full_nas_auth=on nia=null+zuc+aes+snow3g nea=null
    ${v11}    catenate    set_upf id=21 daemon=$SERVER_IP:$EDAEMON_PORT ngu=10.0.11.3 dnn=wap2.nokia.com
    ...    devtype=tun devname=tunUPF8 addr=10.12.9.1/24

    Update Cfg Aic    set_amf_region id=21 tac_list=200,280,300,400,500,600 plmn=311:489
    Update Cfg Aic    set_amf id=21 daemon=$SERVER_IP:$EDAEMON_PORT ng=10.0.11.3:38412 region=21 set_id=21 pointer=1
    Update Cfg Aic    ${v10}
    Update Cfg Aic    ${v11}

    ${v12}    catenate    amf_param id=22 reg_procedure_sequence=parallel_init_ctx_setup_req_and_reg_accept
    ...    full_nas_auth=on nia=null+zuc+aes+snow3g nea=null
    ${v13}    catenate    set_upf id=22 daemon=$SERVER_IP:$EDAEMON_PORT ngu=10.0.11.4 dnn=wap2.nokia.com
    ...    devtype=tun devname=tunUPF9 addr=10.12.10.1/24
    Update Cfg Aic    set_amf_region id=22 tac_list=200,280,300,400,500,600 plmn=311:489
    Update Cfg Aic    set_amf id=22 daemon=$SERVER_IP:$EDAEMON_PORT ng=10.0.11.4:38412 region=22 set_id=22 pointer=1
    Update Cfg Aic    ${v12}
    Update Cfg Aic    ${v13}

    ${v14}    catenate    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.11.14 gnb_id=0x24:22 daemon=$SERVER_IP:$EDAEMON_PORT
    ...    x2_peers=none xn=10.0.12.1 nssai=0x1:0xd143a5,0x1:0xd143a6 amf=1
    Update Cfg Aic    ${v14}
    Update Cfg Aic    gnb_param id=3 xn_listening_socket=1 send_xn_setup=off sib1_period=3000
    Update Cfg Aic    set_cell id=1 gnb=3 pci=16:0 tac=280 nrci=0x01 tdd_cell=on proxy=10.0.2.1:9999

    Update Cfg Aic    sim_trace enb=1 protocol=x2 on
    Update Cfg Aic    sim_trace enb=100 protocol=x2 on
    Update Cfg Aic    sim_trace enb=101 protocol=x2 on
    Update Cfg Aic    sim_trace enb=102 protocol=x2 on

    Update Cfg Aic    set_nwslice id=1 snssai=0x01:13714341 amf=1,20,21,22 default=on ue=all
