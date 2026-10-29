*** Settings ***
Documentation
...     [Author]        "pooja"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"

Resource        ${CURDIR}/../../resources/common_Cloud_keywords.robot

*** Keywords ***
Load scf
        Setup Oamops    dut=vdu_1        timeout=100      alias=vdu
        Perform Commissioning          dut=vdu_1        scf_file=${CMP_scf}         alias=vdu
        BuiltIn.Sleep         200

Configure the parameter certTypeForResthttpsTLSAuth to default value

          Setup Oamops    dut=vdu_1        timeout=100      alias=vdu
         Perform Recommissioning    dut=vdu_1    type=delta    delta_file=${9373-RSA}           alias=vdu
         ...     skip_parameter_relation_errors=${True}   force_reset=${True}    auto_lock_cells=${True}     timeout=300
         ...     alias=vdu
        Teardown Oamops    dut=vdu_1      timeout=100      alias=vdu


install ECDSA certificate only on vDU

          Setup Oamops    dut=vdu_1        timeout=100      alias=vdu
         Perform Recommissioning     dut=vdu_1      type=delta      delta_file=${ECDSA_Mandatory_paramters}
          ...     alias=vdu
         ...   skip_parameter_relation_errors=${True}     force_reset=${True}     auto_lock_cells=${True}     timeout=300

         Certificate Configure   dut=vdu_1    operation=install_cmp_certificate     timeout=120
       ...       alias=vdu
        Teardown Oamops    dut=vdu_1      timeout=100      alias=vdu


Configure the parameter certTypeForResthttpsTLSAuth to ECDSA

         Setup Oamops    dut=vdu_1        timeout=100      alias=vdu
       Perform Recommissioning    dut=vdu_1    type=delta    delta_file=${9373-ECDSA}       alias=vdu
         ...     skip_parameter_relation_errors=${True}   force_reset=${True}    auto_lock_cells=${True}     timeout=300
         ...     alias=vdu
       Teardown Oamops    dut=vdu_1      timeout=100      alias=vdu


install RSA certificate

        Setup Oamops    dut=vdu_1        timeout=100      alias=vdu
         Perform Recommissioning     dut=vdu_1      type=delta      delta_file=${RSA_Mandatory_paramters}
         ...    alias=vdu
         ...   skip_parameter_relation_errors=${True}     force_reset=${True}    auto_lock_cells=${True}     timeout=300

         Certificate Configure   dut=vdu_1    operation=install_cmp_certificate     timeout=120
         ...     key_pool_type=${RSA}  alias=vdu
        ...       alias=vdu
        Teardown Oamops    dut=vdu_1      timeout=100      alias=vdu

Restore Cerficate to default

          Setup Oamops    dut=vdu_1        timeout=100      alias=vdu
          Certificate Configure   dut=vdu_1     operation=restore_vendor_certificate      alias=vdu
          BuiltIn.Sleep   30

Get Operator Certificates

    ${Certificate_list}=      Certificate Configure     operation=get_certificate_list      dut=vdu_1
    ...    type=TA      timeout=120
    Log     ${Certificate_list}
    @{operator_certs}=     Create List
    FOR   ${Certificate}  IN   @{Certificate_list}
          Log        ${Certificate}
          ${cert_name}=    Get From Dictionary      ${Certificate['details']}     issued_to
            ${Result}=    Remove String    ${cert_name}    /
            Append To List    ${operator_certs}    ${Result}
    END
    Set Suite Variable      ${operator_certs}         ${operator_certs}

