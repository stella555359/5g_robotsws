***Settings ***
Documentation
    ...     [Author]                "Abeer"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Funtion_Hash_Tags]     ""
    ...     [Validation_status]     "Validated and Passed"
    ...     [Validated_TestLine]    "TL-071"


variables       ta_e2e_bts_trs_fw
#Resource    /home/ute/fw_user_path/testcases/resources/common_keywords.robot
Resource        ${CURDIR}/../resources/common_keywords.robot

Suite Setup     Run Keywords        Suite Setup Preconditions        AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions       AND     Teardown Oamops


*** Test Cases ***
[1][SMTRS-31953]LSS IP modification

   Perform Commissioning       scf_file=${base_scf}      verify_bts_status=True      timeout=500      alias=default

#modifying LSS IP
    Perform Commissioning       scf_file=${Lss_ip_modification}      verify_bts_status=True      timeout=500      alias=default


#Checking Login to BTS after LSS IP modification
   Setup Remote Access     remote_device=bts     alias=co
   Sleep   10

#Checking ping to Mplane after LSS IP modification
    ${ping}=       Execute Interactive Remote Command      command=ping -c 10 ${IP}     alias=co
     Sleep    10
     Should Contain      ${ping}       ${packet_loss}
     Teardown Remote Access   alias=co

    ${ping}=       Execute Interactive Remote Command      command=ping -c 10 ${v6_IP}     alias=co
     Sleep    10
     Should Contain      ${ping}       ${packet_loss}
     Teardown Remote Access   alias=co


