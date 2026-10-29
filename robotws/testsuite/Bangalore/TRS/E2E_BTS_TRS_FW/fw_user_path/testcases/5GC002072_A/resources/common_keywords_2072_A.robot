*** Settings ***
Documentation
...     [Author]        "pooja"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"

Resource        ${CURDIR}/../../resources/common_keywords.robot



***Keywords***

Load scf
      Setup Oamops    dut=vdu_1        timeout=100      alias=vdu
      Perform Commissioning         dut=vdu_1        scf_file=${CMP_scf}          alias=vdu
      BuiltIn.Sleep         200

Configure CMP parameters, PSK and Ref#, and enroll operator certificate

            Setup Oamops         dut=vdu_1          alias=vdu
            Certificate Configure   dut=vdu_1     operation=set_certificate_automatic_management        alias=vdu
            ...    reference_number=${ref_num}  preshared_key=${psk}   key_pool_type=RSA

           Certificate Configure    dut=vdu_1   operation=install_cmp_certificate   timeout=60   alias=vdu
           BuiltIn.Sleep      120

            Certificate Configure   dut=vdu_1     operation=set_certificate_automatic_management        alias=vdu
             ...    reference_number=${ref_num}  preshared_key=${psk}   key_pool_type=ECDSA

            Certificate Configure    dut=vdu_1   operation=install_cmp_certificate   timeout=60          alias=vdu

Trigger KeyUpdateRequest

        Setup Oamops         dut=vdu_1          alias=vdu
        [Arguments]     ${keypoolType}           ${keypoolType2}
        Certificate Configure   dut=vdu_1     operation=restore_vendor_certificate      alias=vdu
        BuiltIn.Sleep   60
        Certificate Configure   dut=vdu_1     operation=set_certificate_automatic_management
        ...     reference_number=${ref_num}  preshared_key=${psk}  key_pool_type=${keypoolType}   alias=vdu
        BuiltIn.Sleep   60
        Certificate Configure   dut=vdu_1    operation=install_cmp_certificate     timeout=120
        ...     key_pool_type=${keypoolType}  alias=vdu
        BuiltIn.Sleep   80
         Certificate Configure   dut=vdu_1     operation=set_certificate_automatic_management
         ...    reference_number=${ref_num}  preshared_key=${psk}   key_pool_type=${keypoolType2}   alias=vdu
        BuiltIn.Sleep   60
        Certificate Configure   dut=vdu_1    operation=install_cmp_certificate     timeout=120
        ...     key_pool_type=${keypoolType2}  alias=vdu
        BuiltIn.Sleep   60
