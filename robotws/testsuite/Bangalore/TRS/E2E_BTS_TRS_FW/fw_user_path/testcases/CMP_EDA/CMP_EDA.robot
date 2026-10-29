*** Settings ***
Documentation     [Procedure] "[PR662026] CMP primary and secondary CMP server_ EDA"
...               [Date] "Date of creation 25:09:18"
...               [Author] "Pooja"
...               [QC_Path] "QC_Path in Test Plan"
...               [QC_ID] "QC_ID in Test Lab for reporting"
...               [Feature_ID] "RP000833"
...               [Funtion_Hash_Tags] "HAND OVER"
...               [Validation_status] “Validated and Passed|Not Validated”
...               [Validated_TestLine] “2011”
...               [Validation Date] “13-09-18”
...               [Config]      "SCF should contain CMP MO with primary and secondary CMP server configurations"


variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/../resources/Common_IPSEC_Operations.robot

Suite Setup     Run Keywords        Suite Setup Preconditions        AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions       AND     Teardown Oamops

Library           Collections
#Library           /home/ute/fw_user_path/testcases/resources/cmp.py
Library           ute_fsmaccess


*** Test Cases ***
[1][1.0] SMTRS-27490-Cover all possible negative scenarios for Primary and secondary CMP server configurations

    Perform Commissioning      scf_file=${Full_Config}     skip_parameter_relation_errors=${True}
    ...     verify_bts_status=${False}      timeout=400
    Sleep   300
    Perform Recommissioning     type=delta      delta_file=${RSA_secondaryIP_remove}
    ...     skip_parameter_relation_errors=${true}      timeout=300
    Sleep   80
    Certificate Configure    operation=restore_vendor_certificate

    Run Keyword And Expect Error for RSA
  	Certificate Configure    operation=install_cmp_certificate     key_pool_type=ECDSA   timeout=400

    Perform Recommissioning     type=delta      delta_file=${ECDSA_secondaryIP_remove}
    ...     skip_parameter_relation_errors=${true}      timeout=300
  	Certificate Configure    operation=restore_vendor_certificate

   	Run Keyword And Expect Error for RSA
  	Run Keyword And Expect Error for ECDSA

    Perform Recommissioning     type=delta      delta_file=${RSA_secondaryIP_adding}
    ...     skip_parameter_relation_errors=${true}      timeout=300
	Certificate Configure    operation=install_cmp_certificate     key_pool_type=RSA   timeout=400
	Run Keyword And Expect Error for ECDSA

    Perform Recommissioning     type=delta      delta_file=${ECDSA_secondaryIP_adding}
    ...     skip_parameter_relation_errors=${true}      timeout=300
	Certificate Configure    operation=restore_vendor_certificate
	Certificate Configure    operation=install_cmp_certificate     key_pool_type=RSA   timeout=300
	Certificate Configure    operation=install_cmp_certificate     key_pool_type=ECDSA   timeout=400


***keywords***

Run Keyword And Expect Error for RSA
    BuiltIn.Fail       CMP server not reachable/timeout        Certificate Configure
    ...     operation=install_cmp_certificate        key_pool_type=RSA      timeout=400
    Certificate Configure      operation=install_cmp_certificate     key_pool_type=RSA      timeout=400

Run Keyword And Expect Error for ECDSA
    BuiltIn.Fail        CMP server not reachable         Certificate Configure
    ...     operation=install_cmp_certificate     key_pool_type=ECDSA        timeout=400
    Certificate Configure      operation=install_cmp_certificate     key_pool_type=ECDSA      timeout=400
