*** Settings ***

Documentation
...     [Author]        "pooja"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"

Resource        ${CURDIR}/../../resources/common_keywords.robot


***Keywords***

Login_vDU
   Setup Oamops    dut=vdu_1        timeout=100      alias=default

Load scf
     Setup Oamops    dut=vdu_1        timeout=100      alias=vdu
     Perform Commissioning         dut=vdu_1       scf_file=${scf}        alias=vdu
     BuiltIn.Sleep         200

Lock Cell And Unlock Cell In WebEM
        Setup Oamops    dut=vdu_1        timeout=100      alias=default
       Perform Recommissioning    dut=vdu_1    type=delta    delta_file=${path}
       ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
       ...     alias=default

        BuiltIn.Sleep    30
       Perform Recommissioning    dut=vdu_1    type=delta    delta_file=${path_unlocked}
       ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
       ...     alias=default


Lock RU And Unlock RU In WebEM
        Setup Oamops    dut=vdu_1        timeout=100      alias=default
       Perform Recommissioning    dut=vdu_1    type=delta    delta_file=${rmod_lock}
       ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=500
       ...     alias=default

        BuiltIn.Sleep    30
       Perform Recommissioning    dut=vdu_1    type=delta    delta_file=${rmod_unlock}
       ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=500
       ...     alias=default


Reset RU In WebEM
    Setup Oamops    dut=vdu_1        timeout=100      alias=default
    ${rmods}=    Create List    1
    Reset    operation=reset_rmods    rmods_list=${rmods}    reset_reason=user    dut=vdu_1    reset_type=Hard
    ...    timeout=300    alias=default
    Teardown Oamops     dut=vdu_1     alias=default


Reset VDU In WebEM
    Login_vDU
    Reset    operation=reset_bts    rat=5g    dut=vdu_1    alias=default    should_be_onair=${False}
    ...    verify_bts=${False}
    BuiltIn.Sleep   100


