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
...     [Validation_Status]     "Validated"
...     [Validated_TestLine]    "TL006"
...     [Config]            "This testcase needs basic scf with ipsec configuration"

Resource        ${CURDIR}/resources/CB009923_Common_Keywords.robot

Force Tags      CA_E2ET_BTSTRSPZ        vDUCNF00      vDUCNF25R3     4G_FDD       QCD_MN_RAN        QCP_RAN_VRF        CRT

*** Test Cases ***
[1]TRS_CB009923_vDU_IP Traffic Capturing_PointA_PointB_with_without_password_Encryption_with_IPSEC
    Setup Oamops    dut=dbts    alias=vdu
    Setup Oamops    dut=cbts    alias=vcu
    Perform ipsec configuration on vcu and vdu
    Perform PSK Configuration on vcu and vdu
    Perform ipsec configuration for PSK on VM
    Sleep   60
##PointA capture without password##
    traffic_capture_start   capture_device=vDU     capture_type=plane    plane_type=['cplane','uplane','mplane']
    ...     pod_names=['po-trs-cran32-cprt-0']    measurement_point=NE_Terminated    timeout=180    alias=vdu
    Call Setup    5g=5g_basic_setup_cfg:data      parallel=${False}      verify_attach=${False}    attach=${False}     timeout=120
    Attach UE and send ul dl traffic
    Sleep   60
    Run     ping ${mplane_ip} -c 100
    Stop traffic and detach UE
    traffic_capture_stop   capture_device=vDU      timeout=180  alias=vdu   keep_alias=True
    Sleep   30
    generate_capture_files     capture_device=vDU        timeout=180    alias=vdu
    Sleep   60
    Run     rm -r ${pcaps_dir}/*
    Upload Traffic Capture File     capture_device=vDU      capture_type=plane      plane_type=['cplane','uplane','mplane']
    ...     local_path=${pcaps_dir}    timeout=180  alias=vdu
    Get downloaded pcaps of vDU
    Analyse downloaded pcaps of vDU

##PointA capture with password##
    traffic_capture_start  capture_device=vDU     capture_type=plane    plane_type=['cplane','uplane','mplane']
    ...     pod_names=['po-trs-cran32-cprt-0']    measurement_point=NE_Terminated    timeout=180      alias=vdu
    Call Setup    5g=5g_basic_setup_cfg:data      parallel=${False}      verify_attach=${False}    attach=${False}     timeout=120
    Attach UE and send ul dl traffic
    Sleep   60
    Run     ping ${mplane_ip} -c 100
    Stop traffic and detach UE
    Sleep   10
    traffic_capture_stop   capture_device=vDU      timeout=180     alias=vdu    keep_alias=True
    Sleep   60
    generate_capture_files     capture_device=vDU   password=${encrypt_password}    timeout=180   alias=vdu
    Sleep   120
    Run     rm ${pcaps_dir}/*
    Upload Traffic Capture File     capture_device=vDU      capture_type=plane      plane_type=['uplane','cplane','mplane']
    ...   local_path=${pcaps_dir}    timeout=180  alias=vdu
	Get downloaded enc_pcaps of vDU
    Decrypt downloaded pcaps
    Analyse downloaded pcaps of vDU

##PointB capture without password##
    traffic_capture_start  capture_device=vDU     capture_type=plane    plane_type=['cplane','uplane','mplane']
    ...    pod_names=['po-trs-cran32-cprt-0']    measurement_point=Transport_Interface    timeout=180    alias=vdu
    Sleep   10
    Call Setup    5g=5g_basic_setup_cfg:data      parallel=${False}      verify_attach=${False}    attach=${False}     timeout=120
    Attach UE and send ul dl traffic
    Sleep   60
    Run     ping ${mplane_ip} -c 100
    Stop traffic and detach UE
    traffic_capture_stop   capture_device=vDU      timeout=180     alias=vdu    keep_alias=True
    Sleep   60
    generate_capture_files     capture_device=vDU        timeout=180   alias=vdu
    Sleep   60
    Run     rm ${pcaps_dir}/*
    Upload Traffic Capture File     capture_device=vDU      capture_type=plane      plane_type=['uplane','cplane','mplane']
    ...     local_path=${pcaps_dir}    timeout=180      alias=vdu
    Get downloaded pcaps of vDU
	Analyse downloaded pcaps at PointB of vDU

##PointB capture with password##
    traffic_capture_start  capture_device=vDU     capture_type=plane    plane_type=['cplane','uplane','mplane']
    ...    pod_names=['po-trs-cran32-cprt-0']    measurement_point=Transport_Interface    timeout=180    alias=vdu
    Call Setup    5g=5g_basic_setup_cfg:data      parallel=${False}      verify_attach=${False}    attach=${False}     timeout=120
    Attach UE and send ul dl traffic
    Sleep   5
    Run     ping ${mplane_ip} -c 100
    Stop traffic and detach UE
    Sleep   10
    traffic_capture_stop   capture_device=vDU      timeout=180     alias=vdu    keep_alias=True
    Sleep   60
    generate_capture_files     capture_device=vDU   password=${encrypt_password}    timeout=180   alias=vdu
    Sleep   120
    Run     rm ${pcaps_dir}/*
    Upload Traffic Capture File     capture_device=vDU      capture_type=plane      plane_type=['uplane','cplane','mplane']
    ...   local_path=${pcaps_dir}    timeout=180  alias=vdu
	Get downloaded enc_pcaps of vDU
	Decrypt downloaded pcaps
	Analyse downloaded pcaps at PointB of vDU