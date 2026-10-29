*** Settings ***
Documentation
...     [Author]             "Chethan R Prasad"
...     [Maintenance]        "TRS I & V Tools Bangalore Team"
...     [Procedure]          "The test case is planned to check the authentication through operator certificate"
...     [Date]               "10-06-21"
...     [QC_Path]            "QC_Path in Test Plan"
...     [QC_ID]              "TRS_5GC001539_VerifyCombinedModeEAPProcedure"
...     [Funtion_Hash_Tags]  "802.1X Authentication, EAP"
...     [Feature_ID]         "5GC001539"
...     [Requirement ID]     "WBTS_SEC_58748, WBTS_SEC_58749, WBTS_SEC_58754, WBTS_SEC_58948, WBTS_SEC_58949, WBTS_SEC_58702 "
...     [Validation_Status]  "Validated"
...     [Validated_TestLine] "0"
...     [Config]             "This testscript expects 802.1X profile to be present on xe 0/1/2 port of Juniper switch"
...     [scf_file]           "[CombinedAuto.xml]"

variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/Common_IPSEC_Operations.robot
Resource        ${CURDIR}/../resources/common_keywords.robot

Suite Setup     Run Keywords        Suite Setup Preconditions        AND     Setup Oamops
Suite Teardown  Teardown Oamops

***Test Cases***
[1][1.0] TRS_RP002630_VerifyCombinedModeEAPProcedure
#       Perform commisioning
        Perform Commissioning       scf_file=${rp2630_combined_trunk}   verify_bts_status=False     timeout=400     alias=default
        BuiltIn.Sleep    600
        Start Radius Server

#        Check EAP status on interface is Deactivated and EAP is Combined Mode
         Perform Recommissioning     type=param  param_path=${ethlk_path}        value=${ethlk_state_lock}    operation=update
         BuiltIn.Sleep    60
         ${status}=            Query Admin Infomodel     query=get param ${EAP_Status}
         Should be equal     ${status}        Deactivated
         ${status}=     Get Parameter           param_path=${EAP_Mode}
         Should Be True      '${status}'=='Combined Authenticator initiated mode and Supplicant initiated mode'

#       Enable EAP on the switch and confirm EAP state is passed
        Certificate Configure     key_pool_type=RSA    operation=install_certificate    cert_file=${juniper_certificate}
...     cert_type=${btsTrustChain}    cert_format=${p12}     password=${pswd}
        Traffic Capture Start        capture_device=bts_tapeif1          alias=eap_packets
        Configure switch        device=l3switch      command_profile=eap_enable
        Perform Recommissioning     type=param  param_path=${ethlk_path}        value=${ethlk_state_lock}    operation=update
        BuiltIn.Sleep    120
        Perform Recommissioning     type=param  param_path=${ethlk_path}        value=${ethlk_state_unlock}    operation=update
        BuiltIn.Sleep    120
        ${status}=            Query Admin Infomodel     query=get param ${EAP_Status}
        Should be equal     ${status}        Passed
        ${file}=                Traffic Capture Stop   alias=eap_packets
        Set Suite Variable              ${file}
        Get Pcap Details

#       Change EAP mode as Disabled Mode and should go for reboot
        Perform Recommissioning       type=param       param_path=FEATCADM-1:actEAPMode       value=EAP disabled       operation=update
...     timeout=600
        BuiltIn.Sleep    600

#       Check EAP status as deactivated and is in Disabled Mode
        ${status}=            Query Admin Infomodel     query=get param ${EAP_Status}
        Should Be True      '${status}'=='Deactivated'
        ${status}=     Get Parameter           param_path=${EAP_Mode}       timeout=600
        Should Be True      '${status}'=='EAP disabled'

#       Change EAP mode as Authenticator initiated mode and bts should go for reboot
        Perform Commissioning       scf_file=${rp2630_basic_trunk}   verify_bts_status=False     timeout=600     alias=default
        BuiltIn.Sleep    600
        Perform Recommissioning    type=param      param_path=${ethlk_path}        value=${ethlk_state_lock}    operation=update
        BuiltIn.Sleep    60
        ${status}=            Query Admin Infomodel     query=get param ${EAP_Status}
        Should be equal     ${status}        Deactivated
        ${status}=     Get Parameter           param_path=${EAP_Mode}
        Should Be True      '${status}'=='Authenticator initiated mode'

#       verify eap status and packet capture
        Traffic Capture Start        capture_device=bts_tapeif1          alias=eap_packets
        Perform Recommissioning     type=param  param_path=${ethlk_path}        value=${ethlk_state_lock}    operation=update
        BuiltIn.Sleep    120
        Perform Recommissioning     type=param  param_path=${ethlk_path}        value=${ethlk_state_unlock}    operation=update
        BuiltIn.Sleep    120
        ${status}=            Query Admin Infomodel     query=get param ${EAP_Status}
        Should be equal     ${status}        Passed
        ${file}=                Traffic Capture Stop   alias=eap_packets
        Set Suite Variable              ${file}

#       lock the interface and change mode to eap disabled
        Perform Recommissioning     type=param        param_path=FEATCADM-1:actEAPMode       value=EAP disabled       operation=update
...     timeout=600
        BuiltIn.Sleep    600
        ${status}=            Query Admin Infomodel     query=get param ${EAP_Status}
        Should be equal     ${status}        Deactivated
        Configure Switch        device=l3switch       command_profile=eap_disable
        Perform Recommissioning     type=param  param_path=${ethlk_path}        value=${ethlk_state_lock}    operation=update

*** Keywords ***

Get Pcap Details
        Analyse Pcap        pcap_filename=${file}        analysis=verify_success_message       filter_file_name=${traffic_filter_file_name}
        Analyse Pcap        pcap_filename=${file}        analysis=verify_request_message       filter_file_name=${traffic_filter_file_name}
        Analyse Pcap        pcap_filename=${file}        analysis=verify_response_message       filter_file_name=${traffic_filter_file_name}
        Analyse Pcap        pcap_filename=${file}        analysis=verify_client_hello_message       filter_file_name=${traffic_filter_file_name}
        Analyse Pcap        pcap_filename=${file}        analysis=verify_server_hello_message       filter_file_name=${traffic_filter_file_name}
        Analyse Pcap        pcap_filename=${file}        analysis=verify_eap_request_message       filter_file_name=${traffic_filter_file_name}
        Analyse Pcap        pcap_filename=${file}        analysis=verify_eap_response_message       filter_file_name=${traffic_filter_file_name}

Start Radius Server
    Setup Remote Access     remote_device=radius_server     alias=radius_server
    Execute Interactive Remote Command      command=sudo killall radiusd    exit_prompt=      return_rc=${False}      alias=radius_server
    Execute Interactive Remote Command      command=sudo radiusd -Xxx &     exit_prompt=      return_rc=${False}      alias=radius_server
    Teardown Remote Access      alias=radius_server

