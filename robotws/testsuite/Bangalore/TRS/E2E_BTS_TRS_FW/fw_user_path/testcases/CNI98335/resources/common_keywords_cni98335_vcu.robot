*** Settings ***
Documentation
...     [Author]        "Shivani Patil"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [Procedure] "The test case covers basic check for cold reset on vCU"
...     [Date]      "10-08-2023"
...     [QC_Path]   "QC_Path in Test Plan"
...     [QC_ID]     "302523"
...     [Funtion_Hash_Tags] "TRS - Solution"
...     [Feature_ID]            "CNI93885"
...     [Requirement ID]    "OAM_REQ_TRSSEC_919"
...     [Validation_Status]    "Validated"
...     [Validated_TestLine]    "5562"
...     [Config]    "This testcase needs basic scf to check reset"
...     [scf_file]  "Actual_configuration_scf_MRBTS-5562_5GvCU-TL5562.xml"

Library         taf.gnb.oam.coam.cu
Variables       ta_e2e_bts_trs_fw
Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot

*** Keywords ***
Setup Preconditions for vcu
    Run Keywords    Setup Oamops    dut=vcu_98335      alias=vcu   AND     Run Keyword And Ignore Error
    ...     Teardown Oamops     dut=vcu_98335     alias=vcu

Setup Postconditions for vcu
    Run Keywords    Setup Oamops    dut=vcu_98335      alias=default    AND     Collect Snapshot
    ...     dut=vcu_98335    operation_timeout=300     alias=default   AND     Run Keyword And Ignore Error
    ...     Teardown Oamops     dut=vcu_98335     alias=default


Loading SCF
    Login vCU
    taf.ul.trs_e2e_fw.lib.oam.oam_interface.Perform Commissioning    dut=vcu_98335    scf_file=${vcu_5562_base_scf}    timeout=300    alias=default
    Logout vCU

Login vCU
    Setup Oamops     dut=vcu_98335        timeout=100      alias=default

Logout vCU
    Teardown Oamops     dut=vcu_98335      timeout=100      alias=default

Read the pods name
    Setup Remote Access    remote_device=vcu_98335.ocp
    ${output}=      Remote Command Execute     command=${vcu_getPodStatus}     continue_on_failure=${False}
    ...     alias=default
    @{pods}=     Split String     ${output}
    Set Suite Variable    @{pods}
    Teardown Remote Access

Verify the pods status
    Login vCU
    FOR    ${pod}    IN     @{pods}
        ${output1}=   taf.ul.trs_e2e_fw.lib.oam.oam_interface.Get Vnfcs States    dut=vcu_98335    pod_name=${pod}
        ...     alias=default
        ${expected_key}    Set Variable    availability_status
        ${expected_value}    Set Variable    on line
        ${actual_value}    Get From Dictionary    ${output1}[${pod}]    ${expected_key}
        Should Be Equal    ${actual_value}    ${expected_value}
    END
    Logout vCU

Check with process kill option
    Setup Remote Access    remote_device=vcu_98335.ocp     alias=default
    ${output}=  Remote Command Execute      command=${vcu_command_to_kill_process}     exit_prompt=$   alias=default
    @{config_variable}=   Create List     vcu_killProcess
    ${kill_command_on_vcu}=     Get Config Variable     ${config_variable}
    Remote Command Execute     command=${kill_command_on_vcu}   exit_prompt=[core@master1 ~]$    alias=default
    Teardown Remote Access    alias=default
    Sleep   20
    Check process terminate

Check process terminate
    Login vCU
        ${output1}=   taf.ul.trs_e2e_fw.lib.oam.oam_interface.Get Vnfcs States    dut=vcu_98335
        ...     pod_name=${vcu_pod_name}    alias=default
        ${expected_key}    Set Variable    availability_status
        ${expected_value}    Set Variable    degraded
        ${actual_value}    Get From Dictionary    ${output1}[${vcu_pod_name}]    ${expected_key}
        Should Be Equal    ${actual_value}    ${expected_value}
    Logout vCU

Perform warm reset from WebEM
    Login vCU
    Reset     operation=reset_bts    rat=5g     dut=vcu_98335     alias=default     should_be_onair=${False}
    ...     verify_bts=${True}
    Logout vCU
