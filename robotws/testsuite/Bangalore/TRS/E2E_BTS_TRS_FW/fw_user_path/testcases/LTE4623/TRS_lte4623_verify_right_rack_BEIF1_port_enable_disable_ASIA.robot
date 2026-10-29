*** Settings ***
Documentation
...     [Author]        "Kiruthika"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"

Force Tags       CA_E2ET_BTSTRSPZ        SBTS00       SBTS22R1    RAN_4G    RAN_4G_FDD       QCD_MN_RAN        QCP_RAN_VRF        CRT

variables       ta_e2e_bts_trs_fw
Library         OperatingSystem
Library         SSHLibrary

Resource        ${CURDIR}/../resources/Common_LTE4623_Operations.robot
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot

Suite Setup                 Pre-conditions for testsuite
Suite Teardown              Post-conditions for testteardown

*** Variables ***
${filter_file_name}         LTE4623_traffic_filters.json

*** Test Cases ***
[1][1.0] TRS_lte4623_verify_right_rack_BEIF1_port_enable_disable
    Setup Oamops    dut=chained_bts1      alias=remote5
    Download BTS_TRS File from eNB
    Download BTS_TRS File from eNB      alias=remote5
    Perform Recommissioning     type=param  param_path=${Change_QOS_Classification_criteria}    operation=update    value=DSCP     timeout=300
    Perform Recommissioning        type=delta      delta_file=${Enable_BEIF_Primary}     timeout=400     skip_parameter_relation_errors=${True}
    BuiltIn.Sleep       30
    Perform Commissioning       scf_file=${secondary_16_scf}    verify_bts_status=False     timeout=1200        alias=remote5
    BuiltIn.Sleep       300
    Verify ping test success    ${CORE_ENB1_IP}    ${UPLANE_ENB1_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${CPLANE_ENB1_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${MPLANE_ENB1_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${UPLANE_ENB2_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${CPLANE_ENB2_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${MPLANE_ENB2_IP}

    Traffic Capture Start   capture_device=vm_eth3_interface     alias=Cplane_heartbeat
    Call Setup  lte=4623_ue_simulator:data  parallel=${False}   verify_attach=${False}      attach=${False}      timeout=30
    BuiltIn.Sleep   40
    Verify Bts Status   should_be_onair=${True}
    ${CPlane_Heartbeat}=   Traffic Capture Stop     alias=Cplane_heartbeat

#STEP2: Lock and unlock BEIF port on Secondary module
    Run Keyword And Ignore Error        Perform Recommissioning     type=param
...      param_path=MRBTS-2/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-2:administrativeState      operation=update    value=locked    alias=remote5
    BuiltIn.Sleep       10
    Verify ping test success    ${CORE_ENB1_IP}    ${UPLANE_ENB1_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${CPLANE_ENB1_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${MPLANE_ENB1_IP}
    Verify ping test failure    ${CORE_ENB1_IP}    ${UPLANE_ENB2_IP}
    Verify ping test failure    ${CORE_ENB1_IP}    ${CPLANE_ENB2_IP}
    Verify ping test failure    ${CORE_ENB1_IP}    ${MPLANE_ENB2_IP}
    Run Keyword And Ignore Error        Perform Recommissioning     type=param
...      param_path=MRBTS-2/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-2:administrativeState      operation=update    value=unlocked      alias=remote5
    BuiltIn.Sleep       10
    Verify ping test success    ${CORE_ENB1_IP}    ${UPLANE_ENB1_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${CPLANE_ENB1_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${MPLANE_ENB1_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${UPLANE_ENB2_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${CPLANE_ENB2_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${MPLANE_ENB2_IP}

#STEP3: Lock and unlock BEIF port on Primary module
    Run Keyword And Ignore Error        Perform Recommissioning     type=param
...      param_path=MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-1:administrativeState      operation=update    value=locked
    BuiltIn.Sleep       10
    Verify ping test success    ${CORE_ENB1_IP}    ${UPLANE_ENB1_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${CPLANE_ENB1_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${MPLANE_ENB1_IP}
    Verify ping test failure    ${CORE_ENB1_IP}    ${UPLANE_ENB2_IP}
    Verify ping test failure    ${CORE_ENB1_IP}    ${CPLANE_ENB2_IP}
    Verify ping test failure    ${CORE_ENB1_IP}    ${MPLANE_ENB2_IP}
    Run Keyword And Ignore Error        Perform Recommissioning     type=param
...      param_path=MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-1:administrativeState      operation=update    value=unlocked
    BuiltIn.Sleep       30
    Verify ping test success    ${CORE_ENB1_IP}    ${UPLANE_ENB1_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${CPLANE_ENB1_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${MPLANE_ENB1_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${UPLANE_ENB2_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${CPLANE_ENB2_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${MPLANE_ENB2_IP}

#STEP4: Lock and unlock EIF1 port on Primary module
    Run Keyword And Ignore Error        Perform Recommissioning     type=param
...      param_path=MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-5:administrativeState      operation=update    value=locked
    BuiltIn.Sleep       30
    Verify ping test failure    ${CORE_ENB1_IP}    ${UPLANE_ENB1_IP}
    Verify ping test failure    ${CORE_ENB1_IP}    ${CPLANE_ENB1_IP}
    Verify ping test failure    ${CORE_ENB1_IP}    ${MPLANE_ENB1_IP}
    Verify ping test failure    ${CORE_ENB1_IP}    ${UPLANE_ENB2_IP}
    Verify ping test failure    ${CORE_ENB1_IP}    ${CPLANE_ENB2_IP}
    Verify ping test failure    ${CORE_ENB1_IP}    ${MPLANE_ENB2_IP}

    Run Keyword And Ignore Error        Perform Recommissioning     type=param
...      param_path=MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-5:administrativeState      operation=update    value=unlocked
    BuiltIn.Sleep       30
    Verify ping test success    ${CORE_ENB1_IP}    ${UPLANE_ENB1_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${CPLANE_ENB1_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${MPLANE_ENB1_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${UPLANE_ENB2_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${CPLANE_ENB2_IP}
    Verify ping test success    ${CORE_ENB1_IP}    ${MPLANE_ENB2_IP}

    Execute command on ENodeB   reboot
    BuiltIn.Sleep   45
    BEIF LOS Alarm should Exist     alias=remote5
    BuiltIn.Sleep   100
    Execute command on ENodeB   reboot      enb_ip=${MPLANE_ENB2_IP}
    BuiltIn.Sleep   45
    BEIF LOS Alarm should Exist
    BuiltIn.Sleep   100