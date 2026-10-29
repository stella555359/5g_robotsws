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
Setup Precondition on vdu
    Run Keywords    Setup Oamops    dut=vdu_98335      alias=vdu1   AND     Run Keyword And Ignore Error
    ...     Teardown Oamops     dut=vdu_98335     alias=vdu1

Setup Postcondition on vdu
    Run Keywords    Setup Oamops    dut=vdu_98335      alias=default    AND     Collect Snapshot
    ...     dut=vdu_98335    operation_timeout=300   alias=default   AND     Run Keyword And Ignore Error
    ...     Teardown Oamops     dut=vdu_98335     alias=default


Loading SCF
    Login vDU
    taf.ul.trs_e2e_fw.lib.oam.oam_interface.Perform Commissioning    dut=vdu_98335    scf_file=${vdu_5562_base_scf}      timeout=300    alias=default
    Logout vDU

Login vDU
    Setup Oamops    dut=vdu_98335        timeout=100      alias=default

Logout vDU
    Teardown Oamops    dut=vdu_98335      timeout=100      alias=default

Verify vDU goes for reset
    Setup Remote Access    remote_device=vm_140     alias=24
    Execute Interactive Remote Command     command=${dest_IP}     alias=conn24
    Teardown Remote Access     alias=24

Verify pod status before reset
    Setup Remote Access    remote_device=vdu_98335.ocp
    ${pod_status}=   Remote Command Execute     command=${vDU_podStatusOnReset}     alias=default
    Log     ${pod_status}
    Set Suite Variable    ${before_reset}    ${pod_status}
    Teardown Remote Access

Read the pods name
    Setup Remote Access    remote_device=vdu_98335.ocp
    ${output}=      Remote Command Execute     command=${vdu_getPodStatus}     continue_on_failure=${False}
    ...     alias=default
    @{pods}=     Split String     ${output}
    Set Suite Variable    @{pods}
    Teardown Remote Access

Verify the pods status
    Login vDU
    FOR    ${pod}    IN     @{pods}
        ${output1}=   taf.ul.trs_e2e_fw.lib.oam.oam_interface.Get Vnfcs States    dut=vdu_98335    pod_name=${pod}
        ...     alias=default
        ${expected_key}    Set Variable    availability_status
        ${expected_value}    Set Variable    on line
        ${actual_value}    Get From Dictionary    ${output1}[${pod}]    ${expected_key}
        Should Be Equal    ${actual_value}    ${expected_value}
    END
    Logout vDU

Check with process kill option
    Setup Remote Access    remote_device=vdu_98335.ocp     alias=default
    ${output}=     Remote Command Execute     command=${vdu_command_to_kill_process}    exit_prompt=$   alias=default
    @{config_variable}=   Create List     vdu_killProcess
    ${kill_command_on_vdu}=     Get Config Variable     ${config_variable}
    Remote Command Execute     command=${kill_command_on_vdu}   exit_prompt=[core@master0 ~]$    alias=default
    Teardown Remote Access  alias=default
    Sleep   10

Verify pod status during reset
    Setup Remote Access    remote_device=vdu_98335.ocp
    ${kubectl_l2nrt}=   Remote Command Execute     command=${l2nrt pod status}      alias=default
    ${kubectl_l2nrt}=   Split String   ${kubectl_l2nrt}
    Should Contain     ${kubectl_l2nrt}     Terminating
    Teardown Remote Access

Verify pod status after reset
    Setup Remote Access    remote_device=vdu_98335.ocp
    ${after_reset}=   Remote Command Execute     command=${vDU_podStatusOnReset}      alias=default
    Should Be Equal     ${after_reset}     ${before_reset}
    Teardown Remote Access

Check process terminate
    Login vDU
        ${output1}=   taf.ul.trs_e2e_fw.lib.oam.oam_interface.Get Vnfcs States    dut=vdu_98335
        ...     pod_name=${vdu_pod_name}    alias=default
        ${expected_key}    Set Variable    availability_status
        ${expected_value}    Set Variable    degraded
        ${actual_value}    Get From Dictionary    ${output1}[${vdu_pod_name}]    ${expected_key}
        Should Be Equal    ${actual_value}    ${expected_value}
    Logout vDU

Perform warm reset from WebEM
    Login vDU
    Reset    operation=reset_bts    rat=5g    dut=vdu_98335    alias=default    should_be_onair=${False}
    ...     verify_bts=${True}
    Logout vDU
