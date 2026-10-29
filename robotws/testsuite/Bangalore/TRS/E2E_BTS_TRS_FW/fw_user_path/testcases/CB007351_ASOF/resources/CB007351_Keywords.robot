*** Settings ***
Documentation
...     [Procedure]             "The testcase verify's installation of RSA and ECDSA installation"
...     [Date]                  "10-02-2023"
...     [Author]                "Abhishek Baburaj"
...     [Maintenance]           "TRS"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"
...     [Funtion_Hash_Tags]     "CMP"
...     [Domain_Hash_Tags]      "certificate"
...     [Feature_ID]            "CB007351"
...     [Validation_status]     "Validated and Passed"
...     [Validated_TestLine]    "SBTS-7351"
...     [Config_Comments]       "NA"
...     [RunTime Parameters]    ""

*** Keywords ***
Preconditions
      Perform Commissioning       scf_file=${Master_SCF}    timeout=600     alias=default       wait_for_bts_to_be_ready=300
      Setup Ems  config_device=netact2005       alias=lab2005
      Cm Upload   config_device=netact2005      alias=lab2005

Verify actsync Flag is enbaled
    ${Cert_Parameter_Validation}=      Configuration Get    config_device=netact2005    dist_name=${dist}    alias=lab2005
    ${Status}=        Get From Dictionary     dictionary=${Cert_Parameter_Validation}      key=actCertPartitionSynch
    should contain        ${Status}     true

Flag verification after enabling the feature
    ${flag_enabled} =     Get Parameter       rat=common      param_path=${flag_enabled_path}
    Should Contain    str{${flag_enabled}}   ${flag_enable_check}

Rollback BTS Software
	Rollback Software       timeout=300 	is_config_reset=True	alias=default
	BuiltIn.Sleep    450

Triger CMP IR to install certificates
    Certificate Configure    operation=install_cmp_certificate
    BuiltIn.Sleep    80

Verification of certificate details in BTS Active partition
    Setup Remote Access   remote_device=bts     alias=session
    ${stdout_1}          Execute Interactive Remote Command    command=cd ${PATH};find . -type f -name "cert.pem" | wc -l   alias=session
    Should Contain   '${stdout_1}'      1          alias=session
    ${stdout_2}          Execute Interactive Remote Command    command=openssl x509 -in ${PATH}/cert.pem -text | head -5 | tail -1   alias=session
    Set Suite Variable     ${serial_number_Active}     ${stdout_2}
    ${stdout_3}          Execute Interactive Remote Command    command=openssl x509 -fingerprint -noout -in ${PATH}/cert.pem   alias=session
    Set Suite Variable     ${finger_print_Active}      ${stdout_3}

Verify cert details in BTS Active partition
    Setup Remote Access   remote_device=bts     alias=session
    ${stdout_1}          Execute Interactive Remote Command    command=cd ${cert_path}   alias=session
    ${stdout_1}          Execute Interactive Remote Command    command=${cer_cmd} | grep -i "CN = AUTOCONN_TLS_TA"   alias=session
    Should Contain      ${stdout_1}      ${Subjectname}

Verify cert details in BTS Active partition-1
    Setup Remote Access   remote_device=bts     alias=session4
    ${stdout_1}          Execute Interactive Remote Command    command=cd ${cert_path}   alias=session4
    ${stdout_1}          Execute Interactive Remote Command    command=${cer_cmd} | grep -i "CN = AUTOCONN_TLS_TA"   alias=session4
    Should Contain      ${stdout_1}      ${Subjectname}

Verify cert details in BTS Passive partition
    Setup Remote Access   remote_device=bts     alias=session1
    ${stdout_1}          Execute Interactive Remote Command    command=cd ${cert_path}   alias=session1
    ${stdout_1}          Execute Interactive Remote Command    command=${cer_cmd} | grep -i "CN = AUTOCONN_TLS_TA"   alias=session1
    Should Contain      ${stdout_1}      ${Subjectname}

Verify cert details in BTS Passive partition-1
    Setup Remote Access   remote_device=bts     alias=session5
    ${stdout_1}          Execute Interactive Remote Command    command=cd ${cert_path}   alias=session5
    ${stdout_1}          Execute Interactive Remote Command    command=${cer_cmd} | grep -i "CN = AUTOCONN_TLS_TA"   alias=session5
    Should Contain      ${stdout_1}      ${Subjectname}

Verification of certificate details in BTS Active partition1
    Setup Remote Access   remote_device=bts     alias=session2
    ${stdout_1}          Execute Interactive Remote Command    command=cd ${PATH};find . -type f -name "cert.pem" | wc -l   alias=session2
    Should Contain   '${stdout_1}'      1          alias=session2
    ${stdout_2}          Execute Interactive Remote Command    command=openssl x509 -in ${PATH}/cert.pem -text | head -5 | tail -1   alias=session2
    Set Suite Variable     ${serial_number_Active}     ${stdout_2}
    ${stdout_3}          Execute Interactive Remote Command    command=openssl x509 -fingerprint -noout -in ${PATH}/cert.pem   alias=session2
    Set Suite Variable     ${finger_print_Active}      ${stdout_3}

Verification of certificate details in BTS Passive partition
    Setup Remote Access   remote_device=bts     alias=session
    ${stdout_1}          Execute Interactive Remote Command
    ...     command=encfs --public --crakey "/etc/keys.d/private/sok.crk&enc.crk" ${cmd1} ${cmd2} -o nonempty,allow_other    alias=session
    ${stdout_2}          Execute Interactive Remote Command    command=cd ${PATH};find . -type f -name "cert.pem" | wc -l   alias=session
    Should Contain   '${stdout_2}'      1          alias=session
    ${stdout_3}          Execute Interactive Remote Command    command=openssl x509 -in ${PATH}/cert.pem -text | head -5 | tail -1   alias=session
    Set Suite Variable     ${serial_number_Passive}     ${stdout_3}
    ${stdout_4}          Execute Interactive Remote Command    command=openssl x509 -fingerprint -noout -in ${PATH}/cert.pem   alias=session
    Set Suite Variable     ${finger_print_Passive}      ${stdout_4}

Verification of certificate details in BTS Passive partition2
    Setup Remote Access   remote_device=bts     alias=session3
    ${stdout_1}          Execute Interactive Remote Command
    ...     command=encfs --public --crakey "/etc/keys.d/private/sok.crk&enc.crk" ${cmd1} ${cmd2} -o nonempty,allow_other    alias=session3
    ${stdout_2}          Execute Interactive Remote Command    command=cd ${PATH};find . -type f -name "cert.pem" | wc -l   alias=session3
    Should Contain   '${stdout_2}'      1          alias=session3
    ${stdout_3}          Execute Interactive Remote Command    command=openssl x509 -in ${PATH}/cert.pem -text | head -5 | tail -1   alias=session3
    Set Suite Variable     ${serial_number_Passive}     ${stdout_3}
    ${stdout_4}          Execute Interactive Remote Command    command=openssl x509 -fingerprint -noout -in ${PATH}/cert.pem   alias=session3
    Set Suite Variable     ${finger_print_Passive}      ${stdout_4}

Comparision of details between Active and passive partition
    Should Be Equal    ${serial_number_Active}   ${serial_number_Passive}
    Should Be Equal    ${finger_print_Active}    ${finger_print_Passive}
