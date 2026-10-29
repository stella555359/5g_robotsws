*** Settings ***
Documentation	[Procedure]   "IPSEC_VCU"
...         	[QC_Path]   "QC_Path in Test Plan"
...         	[QC_ID]     "QC_ID in Test Lab for reporting"
...         [	Validation_status]     "Passed"


Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        ${CURDIR}/resources/CB010265_A_common_keyword_vDU.robot

Suite Setup     Setup Oamops    dut=vdu_user    alias=vdu
Suite Teardown  Run Keywords    Setup Oamops    dut=vdu_user      alias=vdu   AND     Collect Snapshot
...     dut=vdu_user  operation_timeout=300   alias=vdu   AND     Run Keyword And Ignore Error    Teardown Oamops
...      dut=vdu_user     alias=vdu


*** Test Cases ***
[1]CB010265_CB005999_Verification of all Alarms for ECDSA certificate_vDU
    Perform Commissioning      scf_file=${vdu_CB010265_base_scf_1}      timeout=300      dut=vdu_user    alias=vdu
    Sleep   250
    Triger CMP IR to install certificates on vDU    RSA     ECDSA
    Verify cmp about to expire alarms should not exist in vDU
    Perform Recommissioning with necertificateupdatetime to morethan cert validity time
    Verify cmp necert about to expire alarms should exist in vDU after changing necert parameter
    Perform Recommissioning with cacertificateupdatetime to morethan cert validity time
    Verify cmp cacert about to expire alarms should exist in vDu after changing cacert parameter
    Restore default certificates
    Verify cmp about to expire alarms should not exist in vDU
    Revert cacert and necert values to lessthan cert validity time
    Triger CMP IR to install certificates on vDU    RSA     ECDSA
    Perform Recommissioning of cacert and necert update time
    Verify cmp necert and cacert about to expire alarms should exist in vDu after changing cacert and necert parameter
    Perform vDU reset
    Sleep   300
    Verify cmp about to expiry alarms should exist in vDU after reboot
    Teardown Oamops    dut=vcu_user     alias=default
    [Teardown]     Teardown Oamops     dut=vcu_user     alias=vcu
