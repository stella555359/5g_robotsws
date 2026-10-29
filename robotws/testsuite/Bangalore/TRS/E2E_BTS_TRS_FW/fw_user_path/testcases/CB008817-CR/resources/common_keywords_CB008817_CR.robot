*** Settings ***
Documentation
...     [Author]        "Sahana TC"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"

variables       ta_e2e_bts_trs_fw
Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        ${CURDIR}/../../resources/common_Cloud_keywords.robot

*** Keywords ***
Perform warm reset from WebEM
    Setup Oamops    dut=vdu_1    alias=default
    Reset    operation=reset_bts    rat=5g    dut=vdu_1    alias=default    should_be_onair=${False}
    ...     verify_bts=${False}
    Teardown Oamops     dut=vdu_1     alias=default

Load base scf
    [ARGUMENTS]     ${base_config}
    Setup Oamops    dut=vdu_1    alias=default
    Perform Commissioning    dut=vdu_1    scf_file=${base_config}    timeout=300    alias=default
    Sleep   300
    Teardown Oamops     dut=vdu_1     alias=default

Load base scf non ipsec capable
    Setup Oamops    dut=vdu_9857    alias=default
    Perform Commissioning    dut=vdu_9857    scf_file=${base_scf_nopipsec}    timeout=300    alias=default
    Sleep   300
    Teardown Oamops     dut=vdu_9857     alias=default

Modify actEcpriRuMPlaneSecurity flag
    [ARGUMENTS]   ${delta_config}
    Setup Oamops    dut=vdu_1    alias=default
    Perform Recommissioning    dut=vdu_1    type=delta    delta_file=${delta_config}
    ...     skip_parameter_relation_errors=${True}  timeout=300   force_reset=${True}   auto_lock_cells=${True}
    ...     alias=default
    Sleep     100
    Teardown Oamops     dut=vdu_1     alias=default

Modify actEcpriRuMPlaneSecurity flag to Enabled_noipsec
    Setup Oamops    dut=vdu_9857    alias=default
    Perform Recommissioning    dut=vdu_9857    type=delta    delta_file=${FHIpsecEnabled_no_sw}
    ...     skip_parameter_relation_errors=${True}  timeout=300   force_reset=${True}   auto_lock_cells=${True}
    ...     alias=default
    Sleep     100
    Teardown Oamops     dut=vdu_9857     alias=default

Disable FH ipsec
    [ARGUMENTS]   ${delta_config}
    Setup Oamops    dut=vdu_1    alias=default
    Run keyword and Ignore Error    Perform Recommissioning    dut=vdu_1    type=delta    delta_file=${delta_config}
    ...     skip_parameter_relation_errors=${True}  timeout=300   force_reset=${True}   auto_lock_cells=${True}
    ...     alias=default
    Sleep     300
    Teardown Oamops     dut=vdu_1     alias=default

Modify actEcpriRuMPlaneSecurity flag to Disabled
    Setup Oamops    dut=vdu_1    alias=default
    Perform Recommissioning    dut=vdu_1    type=delta    delta_file=${FHIpsecDisabled}
    ...     skip_parameter_relation_errors=${True}  timeout=300   force_reset=${True}   auto_lock_cells=${True}
    ...     alias=default
    Sleep     100
    Teardown Oamops     dut=vdu_1     alias=default

Modify actEcpriRuMPlaneSecurity flag to Disabled_noipsec
    Setup Oamops    dut=vdu_9857    alias=default
    Perform Recommissioning    dut=vdu_9857    type=delta    delta_file=${FHIpsecDisabled_no_sw}
    ...     skip_parameter_relation_errors=${True}  timeout=300   force_reset=${True}   auto_lock_cells=${True}
    ...     alias=default
    Sleep     100
    Teardown Oamops     dut=vdu_9857     alias=default

Modify PlainText to False
    Setup Oamops    dut=vdu_9857    alias=default
    Run keyword And Ignore Error     Perform Recommissioning    dut=vdu_9857    type=delta    delta_file=${PlainTextFalse_sw}
    ...     skip_parameter_relation_errors=${True}  timeout=300   force_reset=${True}   auto_lock_cells=${True}
    ...     alias=default
    Sleep     100
    Teardown Oamops     dut=vdu_9857     alias=default

Modify PlainText to True
    Setup Oamops    dut=vdu_9857    alias=default
    Run keyword and Ignore Error     Perform Recommissioning    dut=vdu_9857    type=delta    delta_file=${PlainTextTrue_sw}
    ...     skip_parameter_relation_errors=${True}  timeout=300   force_reset=${True}   auto_lock_cells=${True}
    ...     alias=default
    Sleep     100
    Teardown Oamops     dut=vdu_9857     alias=default

Modify actEcpriRuMPlaneSecurity flag to Optional
    Setup Oamops    dut=vdu_1    alias=default
    Perform Recommissioning    dut=vdu_1    type=delta    delta_file=${FHIpsecOptional}
    ...     skip_parameter_relation_errors=${True}  timeout=300   force_reset=${True}   auto_lock_cells=${True}
    ...     alias=default
    Sleep     100
    Teardown Oamops     dut=vdu_1     alias=default

Modify actEcpriRuMPlaneSecurity flag to Optional_noipsec
    Setup Oamops    dut=vdu_9857    alias=default
    Perform Recommissioning    dut=vdu_9857    type=delta    delta_file=${FHIpsecOptional_no_sw}
    ...     skip_parameter_relation_errors=${True}  timeout=300   force_reset=${True}   auto_lock_cells=${True}
    ...     alias=default
    Sleep     100
    Teardown Oamops     dut=vdu_9857     alias=default

Modify actEcpriRuMPlaneSecurity flag to Optional_noipsec1
    Setup Oamops    dut=vdu_9857    alias=default
    Perform Recommissioning    dut=vdu_9857    type=delta    delta_file=${FHIpsecOptional_no1_sw}
    ...     skip_parameter_relation_errors=${True}  timeout=300   force_reset=${True}   auto_lock_cells=${True}
    ...     alias=default
    Sleep     100
    Teardown Oamops     dut=vdu_9857     alias=default

Enable ssh access from rannic
    Setup Oamops    dut=vdu_1    alias=default
    [Documentation]        This test case keyword is to activate the ssh tunnel
    @{config_variable}=   Create List     RANNIC_MOC
    ${RANNIC_MOC}=     Get Config Variable     ${config_variable}
    Config Ssh Tunnel      dist_name=${RANNIC_MOC}     operation=enable     timeout=500
    ...     dut=vdu_1    alias=default
    Sleep     30
    Teardown Oamops     dut=vdu_1     alias=default

Login to oamfh and verify ipsec tunnels
    Setup Remote Access    remote_device=vdu_1.ocp     alias=default
    ${oamfh_ipsec1}=           Execute Interactive Remote Command     command=${oamfh_ipsec}      alias=default
    ${oamfh_ipsec2}=           Execute Interactive Remote Command     command=${ipsec_status}      alias=default
    Log     ${oamfh_ipsec1}
    Log     ${oamfh_ipsec2}
    Should Contain  ${oamfh_ipsec2}  ESTABLISHED
    Should Contain  ${oamfh_ipsec2}  INSTALLED
    Should Contain  ${oamfh_ipsec2}  ${DROP}
    Should Contain  ${oamfh_ipsec2}  icmp
    Teardown Remote Access      alias=default

Reset RANNIC
    Setup Oamops    dut=vdu_1        timeout=100      alias=default
    Reset    operation=reset_rannic     rannic_dn=${RANNIC_MOC}    dut=vdu_1    timeout=100    alias=default
    Sleep    400

Login to oamfh and verify ipsec tunnels for non ipsec capable
    Setup Remote Access    remote_device=vdu_9857.ocp     alias=default
    ${oamfh_ipsec1}=           Execute Interactive Remote Command     command=${oamfh_ipsec}      alias=default
    ${oamfh_ipsec2}=           Execute Interactive Remote Command     command=${ipsec_status}      alias=default
    Log     ${oamfh_ipsec1}
    Log     ${oamfh_ipsec2}
    Should Not Contain  ${oamfh_ipsec2}  ESTABLISHED
    Teardown Remote Access      alias=default

Login to oamfh and verify ipsec tunnels for optional
    Setup Remote Access    remote_device=vdu_1.ocp     alias=default
    ${oamfh_ipsec1}=           Execute Interactive Remote Command     command=${oamfh_ipsec}      alias=default
    ${oamfh_ipsec2}=           Execute Interactive Remote Command     command=${ipsec_status}      alias=default
    Log     ${oamfh_ipsec1}
    Log     ${oamfh_ipsec2}
    Should Contain  ${oamfh_ipsec2}  ESTABLISHED
    Should Contain  ${oamfh_ipsec2}  INSTALLED
    Should Not Contain  ${oamfh_ipsec2}  ${DROP}
    Should Contain  ${oamfh_ipsec2}  icmp
    Teardown Remote Access      alias=default

FH IPsec tunnel clear
    Setup Remote Access    remote_device=vdu_1.ocp     alias=default
    ${oamfh_ipsec1}=           Execute Interactive Remote Command     command=${oamfh_ipsec}      alias=default
    ${oamfh_ipsec2}=           Execute Interactive Remote Command     command=${ipsec_status}      alias=default
    Log     ${oamfh_ipsec1}
    Log     ${oamfh_ipsec2}
    Should Contain  ${oamfh_ipsec2}  ${CLEAR}

FH IPsec tunnel clear for non ipsec radio
    Setup Remote Access    remote_device=vdu_9857.ocp     alias=default
    ${oamfh_ipsec1}=           Execute Interactive Remote Command     command=${oamfh_ipsec}      alias=default
    ${oamfh_ipsec2}=           Execute Interactive Remote Command     command=${ipsec_status}      alias=default
    Log     ${oamfh_ipsec1}
    Log     ${oamfh_ipsec2}
    Should Contain  ${oamfh_ipsec2}  ${CLEAR}
    Teardown Remote Access      alias=default
