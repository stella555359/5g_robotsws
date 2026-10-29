*** Settings ***
Documentation
...     [Author]        "Kiruthika"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [Function_Hash_Tags]            "Backplane"

Force Tags      CLOUD_F    CA_VRF_BLR2        SBTS00        SBTS24R2    SBTS24R3      QCD_MN_RAN       QCP_RAN_VRF        CRT

variables       ta_e2e_bts_trs_fw
Library         OperatingSystem
Library         SSHLibrary
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
#Resource        ${CURDIR}/../resources/Common_IPSEC_Operations.robot
Resource        ${CURDIR}/../resources/Common_LTE4623_Operations.robot
Resource        ${CURDIR}/../resources/common_keywords.robot
#Resource        setup/framework.robot

Suite Setup                 Pre-conditions for testsuite
Suite Teardown              Post-conditions for testteardown

*** Variables ***
${filter_file_name}         LTE4623_traffic_filters.json

*** Test Cases ***
[1][1.0] TRS_lte4623_verify_left_rack_BEIF1_port_enable_disable
    Setup Oamops    dut=xn_mesh_target_gnb      alias=remote
    Download BTS_TRS File from eNB
    Download BTS_TRS File from eNB      alias=remote
    Perform Recommissioning     type=param  param_path=${Change_QOS_Classification_criteria}    operation=update    value=DSCP     timeout=300
    Perform Recommissioning     type=param      param_path=MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-2:administrativeState      operation=update
...   value=unlocked
    Perform Commissioning       scf_file=${secondary_159_scf}    verify_bts_status=False     timeout=1200        alias=remote
    Sleep       300
    Verify ping test success    ${CORE_ENB1_IP}    ${UPLANE_ENB1_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${CPLANE_ENB1_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${MPLANE_ENB1_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${UPLANE_ENB2_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${CPLANE_ENB2_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${MPLANE_ENB2_IP}

    Traffic Capture Start   capture_device=vm_eth3_interface     alias=Cplane_heartbeat
    Call Setup      5g=device_5g:data  parallel=${False}  verify_attach=${False}     attach=${False}  ipv4_or_6=ipv4     timeout=60
    Sleep   90
    Verify Bts Status   should_be_onair=${True}
    ${CPlane_Heartbeat}=   Traffic Capture Stop     alias=Cplane_heartbeat
    Verify wireshark for SCTP messages of enB        ${CPlane_Heartbeat}     ${CPLANE_ENB1_IP}       ${CORE_ENB1_IP}
    Traffic Capture Start   capture_device=vm_eth3_interface     alias=UPlane_GTP
    Configure UE    5g=device_1:data    command=set_pdu_param      ue=1     pdu=1   trf_type=internal
    Sleep   5
    Configure UE    5g=device_1:data    command=ue_register    id=1    profile=1
    Sleep   2
    Configure UE    5g=device_1:data    command=ue_pdu_session_setup       pdu=1   gw=1    ue=1     nwslice=1
    Sleep   3
    Configure UE    5g=device_1:data    command=trf_data_start     ue=1     pdu=1   qfi=1   dir=dl  trf_id=1    protocol=udp    mbps=75
    Sleep   3
    Configure UE    5g=device_1:data    command=trf_data_start     ue=1     pdu=1   qfi=1   dir=ul  trf_id=1    protocol=udp    mbps=75
    Sleep   30
    Configure UE    5g=device_1:data    command=ue_pdu_session_release  ue=1    pdu=1
    Sleep   30
    Configure UE    5g=device_1:data    command=ue_deregister   id=1    ue_deregister_type=switch_off
    ${UPlane_GTP}=   Traffic Capture Stop   alias=UPlane_GTP

#STEP2: Lock and unlock BEIF port on Secondary module
    Perform Recommissioning     type=param      param_path=MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-3:administrativeState
...      operation=update    value=locked        alias=remote
    Sleep   10
    BEIF LOS Alarm should Exist
    Verify ping test success    ${CORE_ENB1_IP}    ${UPLANE_ENB1_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${CPLANE_ENB1_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${MPLANE_ENB1_IP}
    Verify ping test failure    ${CORE_ENB1_IP}    ${UPLANE_ENB2_IP}
    Verify ping test failure    ${CORE_ENB1_IP}    ${CPLANE_ENB2_IP}
    Verify ping test failure    ${CORE_ENB1_IP}    ${MPLANE_ENB2_IP}
    Perform Recommissioning     type=param      param_path=MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-3:administrativeState
...      operation=update    value=unlocked        alias=remote
    Sleep   10
    Verify ping test success    ${CORE_ENB1_IP}    ${UPLANE_ENB1_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${CPLANE_ENB1_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${MPLANE_ENB1_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${UPLANE_ENB2_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${CPLANE_ENB2_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${MPLANE_ENB2_IP}

#STEP3: Lock and unlock BEIF port on Primary module
    Run Keyword And Ignore Error        Perform Recommissioning     type=param
...      param_path=MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-2:administrativeState      operation=update    value=locked
    Sleep   10
    BEIF LOS Alarm should Exist     alias=remote
    Verify ping test success    ${CORE_ENB1_IP}    ${UPLANE_ENB1_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${CPLANE_ENB1_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${MPLANE_ENB1_IP}
    Verify ping test failure    ${CORE_ENB1_IP}    ${UPLANE_ENB2_IP}
    Verify ping test failure    ${CORE_ENB1_IP}    ${CPLANE_ENB2_IP}
    Verify ping test failure    ${CORE_ENB1_IP}    ${MPLANE_ENB2_IP}

    Run Keyword And Ignore Error        Perform Recommissioning     type=param
...      param_path=MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-2:administrativeState      operation=update    value=unlocked
    Sleep   30
    Verify ping test success    ${CORE_ENB1_IP}    ${UPLANE_ENB1_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${CPLANE_ENB1_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${MPLANE_ENB1_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${UPLANE_ENB2_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${CPLANE_ENB2_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${MPLANE_ENB2_IP}

#STEP4: Lock and unlock EIF1 port on Primary module
    Run Keyword And Ignore Error        Perform Recommissioning     type=param
...      param_path=MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-1:administrativeState      operation=update    value=locked
    Sleep   30
    Verify ping test failure    ${CORE_ENB1_IP}    ${UPLANE_ENB1_IP}
    Verify ping test failure    ${CORE_ENB1_IP}    ${CPLANE_ENB1_IP}
    Verify ping test failure    ${CORE_ENB1_IP}    ${MPLANE_ENB1_IP}
    Verify ping test failure    ${CORE_ENB1_IP}    ${UPLANE_ENB2_IP}
    Verify ping test failure    ${CORE_ENB1_IP}    ${CPLANE_ENB2_IP}
    Verify ping test failure    ${CORE_ENB1_IP}    ${MPLANE_ENB2_IP}

    Run Keyword And Ignore Error        Perform Recommissioning     type=param
...      param_path=MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-1:administrativeState      operation=update    value=unlocked
    Sleep   30
    Verify ping test success    ${CORE_ENB1_IP}    ${UPLANE_ENB1_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${CPLANE_ENB1_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${MPLANE_ENB1_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${UPLANE_ENB2_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${CPLANE_ENB2_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${MPLANE_ENB2_IP}

    Reset Bts       should_be_onair=False       verify_bts_status=False
    BEIF LOS Alarm should Exist     alias=remote
    Sleep   100
    Reset Bts       should_be_onair=False       verify_bts_status=False         alias=remote
    BEIF LOS Alarm should Exist
    Sleep   100