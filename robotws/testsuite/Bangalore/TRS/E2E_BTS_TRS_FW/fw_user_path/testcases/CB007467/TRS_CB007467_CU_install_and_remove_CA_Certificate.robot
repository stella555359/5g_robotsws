*** Settings ***
Documentation
...     [Procedure]             "The testcase is to install,restore of certificate with reset operation and Update CMP key"
...     [Date]                  "13-01-2022"
...     [Author]                "Aishwarya Gade"
...     [Maintenance]           "TRS ET Bangalore Team"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"
...     [Funtion_Hash_Tags]     "CMP"
...     [Domain_Hash_Tags]      "certificate"
...     [Feature_ID]            "CB007467"
...     [Validation_status]     "Validated and Passed"
...     [Validated_TestLine]    "SBTS-7467"
...     [Config_Comments]       "NA"
...     [RunTime Parameters]    "bts_id used is 7467"

Variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot

*** Test Cases ***
[1]TRS_CB007467_CU_install_and_remove_CA_Certificate.robot

    Load SCF

    Trigger Automatic Management

    Read CMP Server IP

    CMP Key Update

    Verify CMP Key Update

    CU Reset

    Restore Default Certificate

    Install And Delete Pem Format Certificate

*** Keywords ***

Load SCF

    Setup Oamops    dut=cbts    alias=conn24

    Perform Commissioning    dut=cbts    scf_file=${config_file}    timeout=400     alias=conn24

    Teardown Oamops    dut=cbts    alias=conn24

Trigger Automatic Management

    Setup Oamops     dut=cbts  alias=conn24

    Certificate Configure    dut=cbts   operation=set_certificate_automatic_managment   reference_number=${ref_number}
    ...     preshared_key=${presharedkey}  timeout=60  alias=conn24

    Certificate Configure    dut=cbts   operation=install_cmp_certificate   timeout=60   alias=conn24

    Verify CMP Status

    Teardown Oamops   dut=cbts   alias=conn24

Verify CMP Status

    ${cmp_certificate} =  Get Parameter  param_path=${cmp_certificate_path}  timeout=300  dut=cbts  alias=conn24
    ...     str_format=True

    Should Contain   ${cmp_certificate}  ${ca_certificate_status}

CU Reset

    Setup Oamops     dut=cbts  alias=conn24

    Reset   dut=cbts  alias=conn24

    Sleep  180

    Teardown Oamops   dut=cbts   alias=conn24

CMP Key Update

    Setup Oamops     dut=cbts  alias=conn24

    Setup Remote Access    remote_device=cbts.ncir  alias=conn26

    Execute Interactive Remote Command   command=${kubec_bash_cmd}  alias=conn26

    Execute Interactive Remote Command   command=${temp_path}  alias=conn26

    Execute Interactive Remote Command   command=${start_capture1}  alias=conn26

    Certificate Configure   dut=cbts  operation=cmp_update_key   timeout=60  alias=conn24

    Sleep  60

    Execute Interactive Remote Command   command=${exit_cmd}  alias=conn26

    Execute Interactive Remote Command   command=${copy_capture1}  alias=conn26

    Execute Interactive Remote Command   command=${debug_pc_path1}  alias=conn26

    Execute Interactive Remote Command   command=${ute_password}  alias=conn26

    Verify Packet Capture

    Teardown Remote Access    alias=conn26

    Teardown Oamops   dut=cbts   alias=conn24

Read CMP Server IP

    Setup Oamops    dut=cbts  alias=conn24

    ${Primary_cmp} =  Get Parameter     param_path=${cmp_ip_moc_path}  dut=cbts  timeout=300  alias=conn24
    ...     str_format=True

    Set Suite Variable   ${Primary_cmp}

    Teardown Oamops    dut=cbts  alias=conn24

Verify Packet Capture

    Analyse Pcap   pcap_filename=${pcap_file_location1}  analysis=verify_cmp_key_ir
    ...     filter_file_name=${traffic_filter_file_name}

    Analyse Pcap   pcap_filename=${pcap_file_location1}  analysis=verify_cmp_key_accept
    ...     filter_file_name=${traffic_filter_file_name}

    Analyse Pcap   pcap_filename=${pcap_file_location1}  analysis=verify_cmp_key_certconf
    ...     filter_file_name=${traffic_filter_file_name}

    Analyse Pcap   pcap_filename=${pcap_file_location1}  analysis=verify_cmp_key_pkiconf
    ...     filter_file_name=${traffic_filter_file_name}

Verify CMP Key Update

    Setup Oamops     dut=cbts  alias=conn24

    ${cmp_key_update} =  Get Parameter  param_path=${cmp_certificate_path}  timeout=300  dut=cbts  alias=conn24
    ...     str_format=True

    Should Contain   ${cmp_key_update}  ${ca_key_update_status}

    Teardown Oamops   dut=cbts   alias=conn24

Restore Default Certificate

    Setup Oamops  dut=cbts  alias=conn24

    ${cmp_issuer} =   Get Parameter   param_path=${cmp_issuer_path}  timeout=300  dut=cbts  alias=conn24
	...     str_format=True

    Should Contain   ${cmp_issuer}  ${ca_issuer_name}

    Certificate Configure   dut=cbts   operation=restore_vendor_certificate  timeout=60  alias=conn24

    Sleep  10

    ${cmp_issuer_default} =   Get Parameter   param_path=${cmp_issuer_default_path}  timeout=300  dut=cbts  alias=conn24
	...     str_format=True

    Should Contain   ${cmp_issuer_default}  ${ca_issuer_default_name}

    Teardown Oamops   dut=cbts   alias=conn24

Install And Delete Pem Format Certificate

    Setup Oamops     dut=cbts  alias=conn24

    Certificate Configure   dut=cbts   operation=install_certificate    cert_file=${tapem}   cert_type=${additionalCa}
    ...     timeout=60   alias=conn24

    ${pem_issuer} =   Get Parameter  param_path=${pem_issuer_path}  timeout=300  dut=cbts  alias=conn24  str_format=True

    Should Contain   ${pem_issuer}  ${pem_issuer_name}

    Certificate Configure   dut=cbts   operation=delete_cert    certificate_id=${cert_id}  timeout=60  alias=conn24

    ${cmp_issuer_default} =   Get Parameter  param_path=${cmp_issuer_default_path}  timeout=300  dut=cbts  alias=conn24
    ...     str_format=True

    Should Contain   ${cmp_issuer_default}  ${ca_issuer_default_name}

    Teardown Oamops   dut=cbts   alias=conn24
