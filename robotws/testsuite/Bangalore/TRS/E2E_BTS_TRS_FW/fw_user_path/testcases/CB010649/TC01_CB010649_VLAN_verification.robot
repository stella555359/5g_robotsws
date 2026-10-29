*** Settings ***
Documentation
...         [Procedure]   "IPSEC_VCU"
...         [QC_Path]   "QC_Path in Test Plan"
...         [QC_ID]     "QC_ID in Test Lab for reporting"
...         [Validation_status]     "Passed"


Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        ${CURDIR}/resources/CB010649_common_keyword.robot

Suite Setup     Setup Oamops    dut=vdu_user    alias=vdu
Suite Teardown  Run Keywords    Setup Oamops    dut=vdu_user      alias=vdu   AND     Collect Snapshot
...     dut=vdu_user  operation_timeout=300   alias=vdu   AND     Run Keyword And Ignore Error    Teardown Oamops
...      dut=vdu_user     alias=vdu

*** Test Cases ***
[1]CB010649-CR-DC-B1_IP_or_VLAN Logical Connectivity
    Perform Commissioning      scf_file=${vdu_CB010649_base_Scf}      timeout=300      dut=vdu_user    alias=vdu

    Sleep   250

    Verify Alarm    alias=vdu    faultid=61653    should_exist=${False}    dut=vdu_user

    Verify Alarm    alias=vdu    faultid=61661    should_exist=${False}    dut=vdu_user

    Verify Alarm    alias=vdu    faultid=61672    should_exist=${False}    dut=vdu_user

    Setup Oamops    dut=vdu_user    alias=vdu1

    Perform Recommissioning     dut=vdu_user     type=delta      delta_file=${ip_address_delta}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    ...     alias=vdu1

    Verify Alarm    alias=vdu    faultid=61653    should_exist=${True}  occurrences=1   dut=vdu_user

    Perform Recommissioning     dut=vdu_user     type=delta      delta_file=${vlan_address_delta}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    ...     alias=vdu

    Verify Alarm    alias=vdu    faultid=61661    should_exist=${True}  occurrences=1   dut=vdu_user

    Perform Recommissioning     dut=vdu_user     type=delta      delta_file=${correct_address_vlan_delta}
    ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
    ...     alias=vdu

    Verify Alarm    alias=vdu    faultid=61653    should_exist=${False}    dut=vdu_user

    Verify Alarm    alias=vdu    faultid=61661    should_exist=${False}    dut=vdu_user