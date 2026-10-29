*** Settings ***
Documentation
...     [Author]                "Santosh Nayak"
...     [Maintenance]           "TRS I & V Tools Bangalore Team"
...     [Date]                  "21:06:2024"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"
...     [Feature_ID]            "CB012442"
...     [Funtion_Hash_Tags]     "BTS shall autonomously trigger the CMP key update sequence before the certificate expiry"
...     [Procedure]             "BTS shall autonomously trigger the CMP key update sequence before the certificate expiry"

Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/../resources/common_keywords.robot

Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops

*** Test cases ***

[1][1.0] CB012442_BTS shall autonomously trigger the CMP key update sequence before the certificate expiry

    Perform Commissioning    scf_file=${ASIK_scf}    skip_parameter_relation_errors=${True}      verify_bts_status=${False}     timeout=800
    sleep      300
    Enable_Vendor_expiry_flag
    Reset Bts     verify_bts=${False}
    Sleep    300
    Restore Vendor Certificates
	Traffic Capture Start	 capture_device=oam_device	  mode=file	   uplane_capturing=True
    ...     measurement_point=NE_Terminated	    timeout=300	    alias=TLS_2
    Sleep      30
    Mplane_Login
    sleep       60
    Verification_Of_cmpInitializeCertificate
    sleep      120
    Verify_Vendor_Cert_is_Expired
    Verify_NewNokiaBTSSW_Cert_is_not_Expired
    ${filemode_capture}=    Traffic Capture Stop      mode=file     timeout=120      alias=TLS_2
    Verify Captured File   ${filemode_capture}
    Traffic Capture Start	capture_device=oam_device	mode=file	uplane_capturing=True
    ... 	measurement_point=NE_Terminated	    timeout=300	    alias=TLS_op2
    Sleep      30
    Mplane_Login
    sleep    60
    Verification_Of_cmpInitializeCertificate
    sleep      120
    ${filemode_capture}=    Traffic Capture Stop      mode=file     timeout=120      alias=TLS_op2
    Verify Captured File for operator certificate  ${filemode_capture}
    Disable_Vendor_expiry_flag
    Reset Bts        verify_bts=${False}
    Sleep    300
    Restore Vendor Certificates
    Sleep    30
    Traffic Capture Start	capture_device=oam_device	mode=file	uplane_capturing=True
    ...    measurement_point=NE_Terminated	 timeout=300	alias=D2
    Sleep      30
    Mplane_Login
    sleep    60
    Verification_Of_cmpInitializeCertificate
    sleep    60
    Verify_Vendor_Cert_is_Not_Expired
    ${filemode_capture}=    Traffic Capture Stop      mode=file     timeout=120      alias=D2
    Verify Captured File without flag   ${filemode_capture}

*** keywords ***

Restore Vendor Certificates
    Certificate Configure      operation=restore_vendor_certificate       alias=default

Verify Captured File
    [Arguments]     ${pcap_filename}
    Analyse Pcap    pcap_filename=${pcap_filename}    analysis=Verify_client_hello_Request_ASIK
    Analyse Pcap    pcap_filename=${pcap_filename}    analysis=Verify_server_hello_Response_ASIK
    Analyse Pcap    analysis=Verify_tshark_ASIK    pcap_filename=${pcap_filename}
    ${rc}   ${stdout}   Run And Return Rc And Output    tshark -r ${pcap_filename} -Y "${cmd2}" -T pdml | grep commonName=W6242200001
    Analyse Pcap    analysis=Verify_tshark1_ASIK     pcap_filename=${pcap_filename}
    ${rc}   ${stdout}   Run And Return Rc And Output    tshark -r ${pcap_filename} -Y "${cmd3}" -T pdml | grep commonName=W6242200001

Verify Captured File without flag

    [Arguments]     ${pcap_filename}
    Analyse Pcap    pcap_filename=${pcap_filename}    analysis=Verify_client_hello_Request_ASIK
    Analyse Pcap    pcap_filename=${pcap_filename}    analysis=Verify_server_hello_Response_ASIK
    Analyse Pcap    analysis=Verify_tshark_ASIK     pcap_filename=${pcap_filename}
    ${rc}   ${stdout}   Run And Return Rc And Output    tshark -r ${pcap_filename} -Y "${cmd2}" -T pdml | grep commonName=DH210676692
    Analyse Pcap    analysis=Verify_tshark1_ASIK     pcap_filename=${pcap_filename}
    ${rc}   ${stdout}   Run And Return Rc And Output    tshark -r ${pcap_filename} -Y "${cmd3}" -T pdml | grep commonName=DH210676692

Verify Captured File for operator certificate
    [Arguments]     ${pcap_filename}
    Analyse Pcap    pcap_filename=${pcap_filename}    analysis=Verify_client_hello_Request_ASIK
    Analyse Pcap    pcap_filename=${pcap_filename}    analysis=Verify_server_hello_Response_ASIK
    Analyse Pcap    analysis=Verify_tshark3_ASIK     pcap_filename=${pcap_filename}
    ${rc}   ${stdout}   Run And Return Rc And Output	tshark -r ${pcap_filename} -Y "${cmd2}" -T pdml | grep commonName=TA_DEMO_14_10
    Analyse Pcap    analysis=Verify_tshark2_ASIK     pcap_filename=${pcap_filename}
    ${rc}   ${stdout}   Run And Return Rc And Output    tshark -r ${pcap_filename} -Y "${cmd3}" -T pdml | grep commonName=TA_DEMO_14_10

Verification_Of_cmpInitializeCertificate
    Certificate Configure     operation=install_cmp_certificate       timeout=120

Mplane_Login

    Setup Oamops            bts_host=${ASIK_Mplane_Ip}         alias=MplaneLogin
    sleep   60
    [Teardown]     Teardown Oamops     alias=MplaneLogin

Verify_Vendor_Cert_is_Expired
    Setup Remote Access      remote_device=bts      alias=default
    ${Actual_output}=    Remote Command Execute       command= cat /ram/cache/certfetcher/vendor/eecertificate-details.json        alias=default
    Should Match Regexp     '${Actual_output}'      "expired" : true
    [Teardown]      Teardown Remote Access      alias=default

Verify_Vendor_Cert_is_Not_Expired
    Setup Remote Access      remote_device=bts      alias=default
    ${Actual_output}=    Remote Command Execute       command= cat /ram/cache/certfetcher/vendor/eecertificate-details.json    alias=default
    Should Match Regexp     '${Actual_output}'      "expired" : false
    [Teardown]      Teardown Remote Access      alias=default

Verify_NewNokiaBTSSW_Cert_is_not_Expired
    Setup Remote Access      remote_device=bts      alias=default
    ${Actual_output1}=    Remote Command Execute    command= cat /ram/cache/certfetcher/conf/rsa-default/eecertificate-details.json	  alias=default
    Should Match Regexp     '${Actual_output1}'      "expired" : false
    [Teardown]      Teardown Remote Access      alias=default

Enable_Vendor_expiry_flag
    Setup Remote Access      remote_device=bts      alias=enable
    Remote Command Execute       command= echo "0x12442=1" >> /ffs/run/swconfig.txt      alias=enable
    [Teardown]      Teardown Remote Access      alias=enable

Disable_Vendor_expiry_flag
    Setup Remote Access      remote_device=bts      alias=disable
    Remote Command Execute       command= sed -i 's/0x12442=1//g' /ffs/run/swconfig.txt      alias=disable
    [Teardown]      Teardown Remote Access      alias=disable