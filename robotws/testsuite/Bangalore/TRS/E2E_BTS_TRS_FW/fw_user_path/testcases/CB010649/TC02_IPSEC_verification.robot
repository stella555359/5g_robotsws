*** Settings ***
Documentation
...         [Procedure]   "IPSEC_VCU"
...         [QC_Path]   "QC_Path in Test Plan"
...         [QC_ID]     "QC_ID in Test Lab for reporting"
...         [Validation_status]     "Passed"


Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        ${CURDIR}/resources/CB010649_common_keyword.robot


Suite Setup     Run Keywords    Setup Oamops    dut=vdu_user    alias=vdu
...     AND     Setup Oamops    dut=vcu_user    alias=vcu
Suite Teardown  Run Keywords    Setup Oamops    dut=vdu_user      alias=vdu   AND   Setup Oamops    dut=vcu_user
...     alias=vcu   AND     Collect Snapshot    dut=vdu_user    operation_timeout=300   alias=vdu
...     AND     Run Keyword And Ignore Error    Teardown Oamops     dut=vdu_user    alias=vdu
...     AND     Run Keyword And Ignore Error    Teardown Oamops     dut=vcu_user    alias=vcu


*** Test Cases ***
[1]CB010649-CR-DC-B1_IPSec based traffic encryption
    Perform Commissioning      scf_file=${vdu_ipsec_scf}      timeout=300      dut=vdu_user    alias=vdu
    Perform Commissioning      scf_file=${vcu_ipsec_scf}      timeout=300      dut=vcu_user    alias=vcu
    Sleep   600
    Check Ipsec tunnel status in vDU for Cplane
    Check Ipsec tunnel status in vDU for Uplane
    Verify Alarm    alias=vcu    faultid=61030    should_exist=${False}    dut=vcu_user
    Verify Alarm    alias=vdu    faultid=61030    should_exist=${False}    dut=vdu_user
    Sleep    30
    Restore default certificates
    Sleep   60
    Verify Alarm    alias=vdu    faultid=61644    should_exist=${True}    dut=vdu_user      occurrences=2
    Verify Alarm    alias=vcu    faultid=61644    should_exist=${True}    dut=vcu_user      occurrences=2
    Triger CMP IR to install certificates on vDU    RSA
    Sleep   60
    Check Ipsec tunnel status in vDU for Cplane
    Check Ipsec tunnel status in vDU for Uplane
    Verify Alarm    alias=vcu    faultid=61030    should_exist=${False}    dut=vcu_user
    Verify Alarm    alias=vdu    faultid=61030    should_exist=${False}    dut=vdu_user
