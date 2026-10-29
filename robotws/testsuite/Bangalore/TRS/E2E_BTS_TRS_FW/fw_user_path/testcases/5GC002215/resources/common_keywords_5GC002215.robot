*** Settings ***
Documentation
...     [Author]        "pooja"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"



*** Keywords ***
Check Ipsec Tunnel Status For Vdu And Vcu

    Setup Oamops    dut=vdu_1             alias=vdu
    Perform Commissioning           dut=vdu_1        scf_file=${vdu_ipsec_scf}          alias=vdu
    BuiltIn.Sleep         200

    Setup Oamops    dut=vcu_1             alias=vcu
    Perform Commissioning        dut=vcu_1           scf_file=${vcu_ipsec_scf}        alias=vcu
    BuiltIn.Sleep         200

    ${Status}=   Get Ipsec Associations     policy_id=${policy_id}      tnl_pod_hostname=${pod_hostname_vdu}
    ...    dut=vdu_1    timeout=60    alias=vdu
    ${Values}=   Get Dictionary Values   ${Status}
    ${string}=  Convert To String   ${Values}
    Should Contain Any  ${string}   Established

   ${Status}=   Get Ipsec Associations     policy_id=${policy_id}     tnl_pod_hostname=${pod_hostname_vcu}    dut=vcu_1
    ...    timeout=60    alias=vcu
   ${Values}=   Get Dictionary Values   ${Status}
   ${string}=  Convert To String   ${Values}
   Should Contain Any  ${string}   Established

Modify Ike Encrypted For Vdu

        Setup Oamops    dut=vdu_1        timeout=100      alias=vdu
       Perform Recommissioning    dut=vdu_1    type=delta    delta_file=${Modify_iKeEncrytionMethod_VDU}
       ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
       ...     alias=vdu
       Wait Until Keyword Succeeds    5 min    30      Verify Alarm            dut=vdu_1         faultid=61645
       ...    occurrences=1      should_exist=${True}       alias=vdu

Recover Ike Encrypted For Vdu

       Perform Recommissioning    dut=vdu_1    type=delta    delta_file=${Recover_iKeEncrytionMethod_VDU}
       ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
       ...     alias=vdu
        Wait Until Keyword Succeeds    5 min    30      Verify Alarm        dut=vdu_1       faultid=61645
        ...    occurrences=1      should_exist=${False}       alias=vdu

     ${Status}=   Get Ipsec Associations     policy_id=${policy_id}      tnl_pod_hostname=${pod_hostname_vdu}
     ...     dut=vdu_1    timeout=60    alias=vdu
     ${Values}=   Get Dictionary Values   ${Status}
     ${string}=  Convert To String   ${Values}
     Should Contain Any  ${string}   Established

Modify Ike Authentication Algorithm For Vdu

        Setup Oamops    dut=vdu_1        timeout=100      alias=default
       Perform Recommissioning    dut=vdu_1    type=delta    delta_file=${Modify_iKeAuthenticationMethod_VDU}
       ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
       ...     alias=default
       Wait Until Keyword Succeeds    5 min    30      Verify Alarm         dut=vdu_1         faultid=61645
       ...    occurrences=1      should_exist=${True}          alias=vdu

Recover Ike Authentication Algorithm For Vdu

       Perform Recommissioning    dut=vdu_1    type=delta    delta_file=${Recover_iKeAuthenticatiobnMethod_VDU}
       ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
       ...     alias=default
        Wait Until Keyword Succeeds    5 min    30      Verify Alarm        dut=vdu_1       faultid=61645
        ...    occurrences=1      should_exist=${False}        alias=default

     ${Status}=   Get Ipsec Associations     policy_id=${policy_id}     tnl_pod_hostname=${pod_hostname_vdu}   dut=vdu_1
     ...    timeout=60    alias=default
     ${Values}=   Get Dictionary Values   ${Status}
     ${string}=  Convert To String   ${Values}
     Should Contain Any  ${string}   Established

##vdu reset
      Reset    operation=reset_bts    rat=5g    dut=vdu_1    alias=default    should_be_onair=${False}
      BuiltIn.Sleep   100
      Wait Until Keyword Succeeds    5 min    30      Verify Alarm        dut=vdu_1       faultid=61645
        ...    occurrences=1      should_exist=${False}       alias=vdu

Modify Ike Encrypted For Vcu
###Make vCU Initiator and responder. Make vDU as responder
        Setup Oamops    dut=vcu_1        timeout=100      alias=vcu
       Perform Recommissioning    dut=vcu_1    type=delta    delta_file=${Modify_iKeEncrytionMethod_VCU}
       ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
       ...     alias=vcu
       BuiltIn.Sleep      20
       Perform Recommissioning    dut=vdu_1    type=delta    delta_file=${VDU_Responder}
       ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
       ...     alias=vdu
       BuiltIn.Sleep        20
       Wait Until Keyword Succeeds    5 min    30      Verify Alarm         dut=vcu_1         faultid=61645
       ...     occurrences=1      should_exist=${True}          alias=vcu


Recover Ike Encrypted For Vcu
     Setup Oamops    dut=vcu_1        timeout=100      alias=vcu
      Perform Recommissioning    dut=vcu_1    type=delta    delta_file=${Recover_iKeEncrytionMethod_VCU}        alias=vcu
       ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
       ...     alias=vcu
       BuiltIn.Sleep      20
       Perform Recommissioning    dut=vdu_1    type=delta    delta_file=${VDU_Recover}
       ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
       ...     alias=vdu
       BuiltIn.Sleep        20

        Wait Until Keyword Succeeds    5 min    30      Verify Alarm        dut=vcu_1     faultid=61645    occurrences=1
        ...    should_exist=${False}      alias=vcu


     ${Status}=   Get Ipsec Associations     policy_id=${policy_id}     tnl_pod_hostname=${pod_hostname_vcu}   dut=vcu_1
     ...     timeout=60    alias=vcu
     ${Values}=   Get Dictionary Values   ${Status}
     ${string}=  Convert To String   ${Values}
     Should Contain Any  ${string}   Established

Modify Ike Authentication Algorithm For Vcu

        Setup Oamops    dut=vcu_1        timeout=100      alias=vcu
       Perform Recommissioning    dut=vcu_1    type=delta    delta_file=${Modify_iKeAuthenticationMethod_VCU}
       ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
       ...     alias=vcu
       BuiltIn.Sleep      20
       Perform Recommissioning    dut=vdu_1    type=delta    delta_file=${VDU_Responder}
       ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
       ...     alias=vdu
       BuiltIn.Sleep        20

       Wait Until Keyword Succeeds    5 min    30      Verify Alarm         dut=vcu_1       faultid=61645
       ...    occurrences=1      should_exist=${True}       alias=vcu


Recover Ike Authentication Algorithm For Vcu
       Setup Oamops    dut=vcu_1        timeout=100      alias=vcu
       Perform Recommissioning    dut=vcu_1    type=delta    delta_file=${Recover_iKeAuthenticatiobnMethod_VCU}
       ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
       ...     alias=vcu

       BuiltIn.Sleep      20
       Perform Recommissioning    dut=vdu_1    type=delta    delta_file=${VDU_Recover}
       ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
       ...     alias=vdu
       BuiltIn.Sleep        20

        Wait Until Keyword Succeeds    5 min    30      Verify Alarm        dut=vcu_1        faultid=61645
        ...    occurrences=1      should_exist=${False}        alias=vcu

     ${Status}=   Get Ipsec Associations     policy_id=${policy_id}     tnl_pod_hostname=${pod_hostname_vcu}   dut=vcu_1
     ...     timeout=60    alias=vcu
     ${Values}=   Get Dictionary Values   ${Status}
     ${string}=  Convert To String   ${Values}
     Should Contain Any  ${string}   Established

