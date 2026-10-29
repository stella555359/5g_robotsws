*** Settings ***
Documentation	[Procedure]   "IPSEC_VCU"
...         	[QC_Path]   "QC_Path in Test Plan"
...         	[QC_ID]     "QC_ID in Test Lab for reporting"
...         	[Validation_status]     "Passed"

Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        ${CURDIR}/resources/CB010265_A_common_keyword_vCU.robot

Suite Setup     Setup Oamops    dut=vcu_user    alias=vcu
Suite Teardown  Run Keywords    Setup Oamops    dut=vcu_user      alias=vcu   AND     Collect Snapshot
...     dut=vcu_user  operation_timeout=300   alias=vcu   AND     Run Keyword And Ignore Error    Teardown Oamops
...      dut=vcu_user     alias=vcu

*** Test Cases ***
[1]CB010265_CB005999_Verification of all Alarms for ECDSA certificate_vCU
    Perform Commissioning      scf_file=${vcu_CB010265_base_scf}      timeout=300      dut=vcu_user    alias=vcu
    Sleep   120
    Triger CMP IR to install certificates on vCU    RSA     ECDSA
    Verify cmp about to expire alarms should not exist in vCU
    Perform Recommissioning with necertificateupdatetime to morethan cert validity time
    Verify cmp necert about to expire alarms should exist in vCU after changing necert parameter
    Perform Recommissioning with cacertificateupdatetime to morethan cert validity time
    Verify cmp cacert about to expire alarms should exist in vCu after changing cacert parameter
    Restore default certificates
    Verify cmp about to expire alarms should not exist in vCU
    Revert cacert and necert values to lessthan cert validity time
    Triger CMP IR to install certificates on vCU    RSA     ECDSA
    Perform Recommissioning of cacert and necert update time
    Verify cmp necert and cacert about to expire alarms should exist in vCu after changing cacert and necert parameter
    Perform vCU reset
    Sleep   300
    Verify cmp about to expiry alarms should exist in vCU after reboot
    Teardown Oamops    dut=vcu_user     alias=default
    [Teardown]     Teardown Oamops     dut=vcu_user     alias=vcu
