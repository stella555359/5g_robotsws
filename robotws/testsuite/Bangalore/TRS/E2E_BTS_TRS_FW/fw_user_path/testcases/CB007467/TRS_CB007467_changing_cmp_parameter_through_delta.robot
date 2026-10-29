*** Settings ***
Documentation
...     [Procedure]             "The testcase verify's certificate installation and CMP parameter validation"
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
[1]CB007467_changing_cmp_parameter_through_delta.robot

    Load SCF

    Certificate Installation With Wrong CMP Values

    Modify CMP Parameter

    Verify CMP Parameter

    Read CMP Server IP

    Trigger Automatic Management

    Verify CMP Status

*** Keywords ***

Load SCF

    Setup Oamops    dut=cbts    alias=conn24

    Perform Commissioning    dut=cbts    scf_file=${comm_file}    timeout=400     alias=conn24

    Teardown Oamops    dut=cbts    alias=conn24

Certificate Installation With Wrong CMP Values

    Setup Oamops     dut=cbts  alias=conn24

    Certificate Configure    dut=cbts   operation=set_certificate_automatic_managment   reference_number=${ref_number}
    ...     preshared_key=${presharedkey}  timeout=60  alias=conn24

    Certificate Configure    dut=cbts   operation=install_cmp_certificate  timeout=60  alias=conn24

    Sleep  60

    ${cmp_certificate_check} =  Get Parameter  param_path=${cmp_certificate_path}  timeout=300  dut=cbts  alias=conn24
    ...     str_format=True

    Should Contain   ${cmp_certificate_check}  ${ca_certificate_status_failed}

    Teardown Oamops    dut=cbts  alias=conn24

Modify CMP Parameter

    Setup Oamops    dut=cbts  alias=conn24

    Perform Recommissioning    dut=cbts  type=delta  delta_file=${modify_cmp_port}  alias=conn24

    Teardown Oamops    dut=cbts  alias=conn24

Verify CMP Parameter

    Setup Oamops     dut=cbts  alias=conn24

    ${cmp_path_verify} =  Get Parameter   param_path=${cmp_port_path}  dut=cbts  timeout=300  alias=conn24
    ...     str_format=True

    Should Contain   ${cmp_path_verify}  ${ca_port}

    ${cmp_dir_verify} =  Get Parameter   param_path=${cmp_ser_dir}  dut=cbts  timeout=300  alias=conn24
    ...     str_format=True

    Should Contain   ${cmp_dir_verify}  ${ca_dir}

    ${cmp_sub_name_verify} =  Get Parameter   param_path=${cmp_path}  dut=cbts  timeout=300  alias=conn24
    ...     str_format=True

    Should Contain   ${cmp_sub_name_verify}  ${ca_sub_name}

    Teardown Oamops    dut=cbts  alias=conn24

Read CMP Server IP

    Setup Oamops    dut=cbts  alias=conn24

    ${Primary_cmp} =  Get Parameter     param_path=${cmp_ip_moc_path}  dut=cbts  timeout=300  alias=conn24
    ...     str_format=True

    Set Suite Variable   ${Primary_cmp}

    Teardown Oamops    dut=cbts  alias=conn24

Trigger Automatic Management

    Setup Oamops     dut=cbts  alias=conn24

    Setup Remote Access    remote_device=cbts.ncir  alias=conn26

    Certificate Configure    dut=cbts   operation=set_certificate_automatic_managment   reference_number=${ref_number}
    ...     preshared_key=${presharedkey}  alias=conn24

    Triger CMP IR To Install Certificates

    Teardown Remote Access    alias=conn26

    Teardown Oamops   dut=cbts   alias=conn24

Triger CMP IR To Install Certificates

    Execute Interactive Remote Command   command=${kubec_bash_cmd}  alias=conn26

    Execute Interactive Remote Command   command=${temp_path}  alias=conn26

    Execute Interactive Remote Command   command=${start_capture}  alias=conn26

    Certificate Configure   dut=cbts  operation=install_cmp_certificate  timeout=60  alias=conn24

    Sleep  150

    Execute Interactive Remote Command   command=${exit_cmd}  alias=conn26

    Execute Interactive Remote Command   command=${copy_capture}  alias=conn26

    Execute Interactive Remote Command   command=${debug_pc_path}  alias=conn26

    Execute Interactive Remote Command   command=${ute_password}  alias=conn26

    Check Traffic Capture

Check Traffic Capture

    Analyse Pcap   pcap_filename=${pcap_file_location}  analysis=verify_cmp_ir
    ...     filter_file_name=${traffic_filter_file_name}

    Analyse Pcap   pcap_filename=${pcap_file_location}  analysis=verify_cmp_accept
    ...     filter_file_name=${traffic_filter_file_name}

    Analyse Pcap   pcap_filename=${pcap_file_location}  analysis=verify_cmp_certconf
    ...     filter_file_name=${traffic_filter_file_name}

    Analyse Pcap   pcap_filename=${pcap_file_location}  analysis=verify_cmp_pkiconf
    ...     filter_file_name=${traffic_filter_file_name}

Verify CMP Status

    Setup Oamops   dut=cbts  alias=conn24

    ${cmp_issuer} =   Get Parameter   param_path=${cmp_issuer_path}  timeout=300  dut=cbts  alias=conn24
    ...     str_format=True

    Should Contain   ${cmp_issuer}  ${ca_issuer_name}

    ${cmp_certificate} =  Get Parameter  param_path=${cmp_certificate_path}  timeout=300  dut=cbts  alias=conn24
    ...     str_format=True

    Should Contain   ${cmp_certificate}  ${ca_certificate_status}

    Teardown Oamops    dut=cbts  alias=conn24
