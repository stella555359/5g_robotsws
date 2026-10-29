*** Settings ***
Documentation
...     [Author]            "Punith K"
...     [Maintenance]       "TRS I & V Tools Bangalore Team"
...     [Procedure]         "The test case covers IP traffic capturing with ipsec configuration"
...     [Date]              "21-10-2024"
...     [QC_Path]           "QC_Path in Test Plan"
...     [QC_ID]             "--"
...     [Funtion_Hash_Tags]     "TRS - Security"
...     [Feature_ID]            "CB009923"
...     [Requirement ID]        ""
...     [Validation_Status] "Validated"
...     [Validated_TestLine]    "TL006"
...     [Config]            "This testcase needs basic scf with ipsec configuration"

Resource        ${CURDIR}/resources/CB009923_Common_Keywords.robot

Force Tags      CA_E2ET_BTSTRSPZ        vCUCNF00      vCUCNF25R3     4G_FDD       QCD_MN_RAN        QCP_RAN_VRF        CRT

*** Test Cases ***
[1]TRS_CB009923_vCU_IP Traffic Capturing_PointA_PointB_with_without_password_Encryption_with_IPSEC
    Setup Oamops    dut=dbts    alias=vdu
    Setup Oamops    dut=cbts    alias=vcu
    Perform ipsec configuration on vcu and vdu
    Perform PSK Configuration on vcu and vdu
    Perform ipsec configuration for PSK on VM
    Sleep   60
##PointA capture without password##
    traffic_capture_start   capture_device=vCU     capture_type=plane    plane_type=['cplane','uplane','mplane']
    ...     pod_names=['po-cpif-0','po-upue-0','po-oamext-0']    measurement_point=NE_Terminated    timeout=180    alias=vcu
    Call Setup    5g=5g_basic_setup_cfg:data      parallel=${False}      verify_attach=${False}    attach=${False}     timeout=120
    Attach UE and send ul dl traffic
    Sleep   60
    Run     ping ${mplane_ip_vcu} -c 100
    Stop traffic and detach UE
    Call Teardown      5g=5g_basic_setup_cfg:data
    traffic_capture_stop   capture_device=vCU      timeout=180  alias=vcu   keep_alias=True
    Sleep   30
    generate_capture_files     capture_device=vCU        timeout=180    alias=vcu
    Sleep   60
    Run     rm -r ${pcaps_dir}/*
    Upload Traffic Capture File     capture_device=vCU      capture_type=plane      plane_type=['cplane','uplane','mplane']
    ...     local_path=${pcaps_dir}    timeout=180  alias=vcu
    Get downloaded pcaps of vCU
    Analyse downloaded pcaps of vCU

##PointA capture with password##
    traffic_capture_start  capture_device=vCU     capture_type=pod    plane_type=['cplane','uplane','mplane']
    ...     pod_names=['po-cpif-0','po-upue-0','po-oamext-0']    measurement_point=NE_Terminated    timeout=180      alias=vcu
    Call Setup    5g=5g_basic_setup_cfg:data      parallel=${False}      verify_attach=${False}    attach=${False}     timeout=120
    Attach UE and send ul dl traffic
    Sleep   60
    Run     ping ${mplane_ip_vcu} -c 100
    Stop traffic and detach UE
    Call Teardown      5g=5g_basic_setup_cfg:data
    Sleep   10
    traffic_capture_stop   capture_device=vCU      timeout=180     alias=vcu    keep_alias=True
    Sleep   60
    generate_capture_files     capture_device=vCU   password=${encrypt_password}    timeout=180   alias=vcu
    Sleep   120
    Run     rm ${pcaps_dir}/*
    Upload Traffic Capture File     capture_device=vCU      capture_type=plane      plane_type=['uplane','cplane','mplane']
    ...   local_path=${pcaps_dir}    timeout=180  alias=vcu
	Get downloaded enc_pcaps of vCU
    Decrypt downloaded pcaps
    Analyse downloaded pcaps of vCU

##PointB capture without password##
    traffic_capture_start  capture_device=vCU     capture_type=pod    plane_type=['cplane','uplane','mplane']
    ...    pod_names=['po-cpif-0','po-upue-0','po-oamext-0']    measurement_point=Transport_Interface    timeout=180    alias=vcu
    Sleep   10
    Call Setup    5g=5g_basic_setup_cfg:data      parallel=${False}      verify_attach=${False}    attach=${False}     timeout=120
    Attach UE and send ul dl traffic
    Sleep   60
    Run     ping ${mplane_ip_vcu} -c 100
    Stop traffic and detach UE
    Call Teardown      5g=5g_basic_setup_cfg:data
    traffic_capture_stop   capture_device=vCU      timeout=180     alias=vcu    keep_alias=True
    Sleep   20
    generate_capture_files     capture_device=vCU        timeout=180   alias=vcu
    Sleep   60
    Run     rm ${pcaps_dir}/*
    Upload Traffic Capture File     capture_device=vCU      capture_type=plane      plane_type=['uplane','cplane','mplane']
    ...     local_path=${pcaps_dir}    timeout=180      alias=vcu
    Get downloaded pcaps of vCU
	Analyse downloaded pcaps at PointB of vCU

##PointB capture with password##
    traffic_capture_start  capture_device=vCU     capture_type=pod    plane_type=['cplane','uplane','mplane']
    ...   pod_names=['po-cpif-0','po-upue-0','po-oamext-0']    measurement_point=Transport_Interface    timeout=180    alias=vcu
    Call Setup    5g=5g_basic_setup_cfg:data      parallel=${False}      verify_attach=${False}    attach=${False}     timeout=120
    Attach UE and send ul dl traffic
    Sleep   5
    Run     ping ${mplane_ip_vcu} -c 100
    Stop traffic and detach UE
    Call Teardown      5g=5g_basic_setup_cfg:data
    Sleep   10
    traffic_capture_stop   capture_device=vCU      timeout=180     alias=vcu    keep_alias=True
    Sleep   60
    generate_capture_files     capture_device=vCU   password=${encrypt_password}    timeout=180   alias=vcu
    Sleep   120
    Run     rm ${pcaps_dir}/*
    Upload Traffic Capture File     capture_device=vCU      capture_type=plane      plane_type=['uplane','cplane','mplane']
    ...     local_path=${pcaps_dir}    timeout=180  alias=vcu
	Get downloaded enc_pcaps of vCU
	Decrypt downloaded pcaps
	Analyse downloaded pcaps at PointB of vCU