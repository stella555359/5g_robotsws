*** Settings ***
Documentation
...         [Procedure]   "IPSEC_VCU"
...         [QC_Path]   "QC_Path in Test Plan"
...         [QC_ID]     "QC_ID in Test Lab for reporting"
...         [Validation_status]     "Passed"


Library           OperatingSystem

Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../CB007127_E/resources/common_keywords_7127.robot


Suite Setup         Setup Oamops        dut=vcu_1       alias=vcu
Suite Teardown      Teardown Oamops       dut=vcu_1         alias=vcu

*** Variables ***
${keypoolType2}     RSA
${CRL_cert}     CN=CB008154_TA1

*** Test Cases ***
[1][1.0] CB007127_E_SEC_CRL_Operations_vCU

            Setup Oamops        dut=vcu_1       alias=vcu

            Basic commissioning

            Triger CMP IR to install certificates on vCU

            Configure CRL Source To Certificate Extention

            Configure CRL Source To To Manual Configuration And CRL DP

            Remove one incorrect CRLDP configuration,Check alarm

