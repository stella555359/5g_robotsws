*** Settings ***
Documentation
    ...     [Procedure]             "The test case is to verify the functionality of individual R&D debug parameter by
    ...     enabling through BTS CLI "
    ...     [Date]                  "13-09-22"
    ...     [Author]                "Sushma R"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Funtion_Hash_Tags]     "RAD BTS logs"
    ...     [Feature_ID]            "CB007041"
    ...     [Validation_status]     "Validated and Passed"
    ...     [Validated_TestLine]    "5G-3907"
	...     [Config]    			"All RAD parameters for domain ERadSwDomain_OamTas are set to default"


Variables         ta_e2e_bts_trs_fw
Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        ${CURDIR}/../resources/common_keywords.robot
Resource        ${CURDIR}/resources/common_keywords_7041.robot

Suite Setup     Run Keywords    Suite Setup Preconditions
...             AND     Setup Oamops
Suite Teardown  Run Keywords    Suite Teardown Postconditions
...             AND     Teardown Oamops

*** Test Cases ***
[1][1.0] CB007041_Verification of R&D debug parameters with single parameter reset in BTS_CLI
###    [Documentation]	    This testcase verifies the functionality of individual R&D debug parameter by enabling
###    ...     through BTS CLI
    Preconditions for CB007041
####check for domains: getRADSWDomains##########################
    Get Rad Sw Domains    timeout=30  detailed_output=True
#######Check for parameters under domain:# ERadSwDomain_OamTas and check for its default value###############
    Check Parameter Values      ${default_op}
##########Set all parameters to non-default###########
    Split parameter names from list
    Set All parameters under ERadSwDomain_OamTas domain to non-default  ${split_names}  ${count_of_paramnames}
    Check Parameter Values  ${nondefault_op}
#####Get parameters after setting to non  default#####
    &{non_default}=      Get Rad Debug Parameters   domain=ERadSwDomain_OamTas  detailed_output=True   timeout=100
    Run Keyword If      '${non_default}[requestStatus]'=='completed'    Log To Console  Status OK
    Run Keyword If      '${non_default}[errorCode]'=='0'    Log To Console   Values set to non-default
##########Perform Reboot##########
    Reset Bts        verify_bts=False    req_rat=5g        should_be_onair=False    wait_for=300
########Verify that values are persistent after reboot. ALl still set to non-default######
    Get All Rad Debug Parameter for ERadSwDomain_OamTas domain set to non-default   ${split_names}
    ...     ${count_of_paramnames}
    Check Parameter Values  ${nondefault_op}
#####Snapshot collection: To be updated once SMTRS-27687 is fixed#############
    Collect Snapshot     coverage=Full
###I#########Set few parameters to default and few stay in non-default#########
    Set few parameter to default
########Get parameters ###########
    &{param_changes}=     Get Rad Debug Parameters      domain=ERadSwDomain_OamTas  detailed_output=True   timeout=100
    Run Keyword If      '${param_changes}[requestStatus]'=='completed'    Log To Console  Status OK
    Run Keyword If      '${param_changes}[errorCode]'=='0'
    ...     Log To Console   Few values set to default and few in non-default
############Reboot unit###########
    Reset Bts        verify_bts=False    req_rat=5g        should_be_onair=False    wait_for=300
#############Collect Snapshot and verify the parameters####SMTRS-27687
    Collect Snapshot   coverage=Full
########Restore all the value individually to default####
    Restore all values individually to default
#################Collect snapshot add below##########SMTRS-27687
    Collect Snapshot   coverage=Full

[1]CB007041_Verification of R&D debug parameters during sw upgrade and rollback
############Check this testcase once id=163985 firewall jira is fixed###########
    Setup Remote Access     remote_device=bts       alias=default
    Execute Interactive Remote Command  command=ls /ffs/run/ |awk '/TargetBD/' |cut -d'_' -f2 |head -1     alias=default
    ${enb_status}=      Run Keyword and return status        Should Contain      ${stdout}     SBTS23R1
    Set Suite variable    ${enb_status}
    Teardown Remote Access      alias=default
    ${profile}=     Run Keyword IF     '${enb_status}'=='True'          Set variable        sbtstrunk_00
    ...     ELSE        Set variable    5G_branch
    Rollback Software   timeout=300      alias=default
    Sleep   100
    Check Parameter Values      ${default_op}
    Perform Software Download And Update    wft_profile=${profile}   package=${build}     activate_sw=True
    ...     update_timeout=1800   wait_for_bts_to_be_ready=600      alias=default
########Check values are restored to default######
    Check Parameter Values      ${default_op}
    &{default}=     Get Rad Debug Parameters    domain=ERadSwDomain_OamTas      detailed_output=True   timeout=100
    Run Keyword If      '&{default}[requestStatus]'=='completed'    Log To Console  Status OK
    Run Keyword If      '&{default}[errorCode]'=='0'    Log To Console   Values set to default