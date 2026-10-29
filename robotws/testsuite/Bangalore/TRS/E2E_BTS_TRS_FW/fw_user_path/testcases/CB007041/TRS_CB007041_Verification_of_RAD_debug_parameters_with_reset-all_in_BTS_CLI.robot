***Settings***
Documentation
    ...     [Procedure]             "The test case is to verify the functionality of individual R&D debug parameter
    ...     by enabling through BTS CLI "
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

Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops


*** Test Cases ***
[1]CB007041_Verification of R&D debug parameters with reset-all in BTS_CLI
    [Documentation]	   This testcase is to verify the functionality of R&D debug parameters  by enabling through BTS CLI
    Reset   operation=reset_rad_debug_parameters    name=ALL
    Perform Commissioning   scf_file=${Full_Configuration}   verify_bts_status=False     timeout=400     alias=default
    Sleep   100
#########Check for parameters under domain:ERadSwDomain_OamTas and check for its default value###############
    Check Parameter Values      ${default_op}
#########Set all parameters to non-default###########
    Split parameter names from list
    Set All parameters under ERadSwDomain_OamTas domain to non-default  ${split_names}  ${count_of_paramnames}
    Reset   operation=reset_rad_debug_parameters    name=ALL
    Set All parameters under ERadSwDomain_OamTas domain to non-default  ${split_names}  ${count_of_paramnames}
    Check Parameter Values  ${nondefault_op}
######Get parameters after setting to non  default#####
    &{non_default}=     Get Rad Debug Parameters    domain=ERadSwDomain_OamTas  detailed_output=True   timeout=100
    Run Keyword If      '${non_default}[requestStatus]'=='completed'    Log To Console  Status OK
    Run Keyword If      '${non_default}[errorCode]'=='0'    Log To Console   Values set to non-default
##############Check the swconfig.txt file for RAD flags set to non-default ############ working######
    Setup Remote Access     remote_device=bts       alias=default
    ${swconfig_file}=   Execute Interactive Remote Command  command=cat /ffs/run/swconfig.txt |grep 0x52   alias=default
    Should Contain      ${swconfig_file}    ${rad_non_default_swconfig}
    Teardown Remote Access      alias=default
#########Restore all to default value##########
    Reset   operation=reset_rad_debug_parameters    name=ALL
    Check Parameter Values      ${default_op}
#######Check values are in default######
    &{default}=     Get Rad Debug Parameters    domain=ERadSwDomain_OamTas  detailed_output=True   timeout=100
    Run Keyword If      '${default}[requestStatus]'=='completed'    Log To Console  Status OK
    Run Keyword If      '${default}[errorCode]'=='0'    Log To Console   Values set to default
#####Check swconfig.txt after setting to default####ś
    Setup Remote Access     remote_device=bts       alias=default
    ${swconfig_file}=   Execute Interactive Remote Command  command=cat /ffs/run/swconfig.txt |grep 0x52   alias=default
    Should Contain      ${swconfig_file}    ${swconfig_norad}
    Teardown Remote Access      alias=default
####Check for swconfig entry for each parameter
    Check swconfig entry
###Section to cover SMTRS-28118 EDA
    ${rc}   ${output}=  Run And Return Rc And Output
    ...     command=command=wget http://lterel.es-si-s3-z2.eecloud.nsn-net.net/build/${release}/${build}_RadParameters.zip
    Log     ${radfile_path}
    @{config_variable}=     Create List     radfile_path
    ${radfile_path_value}=  Get Config Variable  ${config_variable}
    Log     ${radfile_path_value}
    ${copied_path}=   Move file      ${radfile_path_value}     ${tmp_rad_file_path}
    ${output_file_present}=     Run     command=unzip ${copied_path} -d ${tmp_rad_file_path}
    File Should Exist   ${tmp_rad_file_path}/RadParameters.xml
    File Should Exist   ${tmp_rad_file_path}/RadParameters.html
    ${contents}=    Get File    ${tmp_rad_file_path}/RadParameters.html
    ${created_list_of_values}=  Convert To String   ${value_list}
    ${split_string}=    Split String    ${value_list}   ,
    ${list_length}=     Get Length  ${split_string}
    Log     ${list_length}
    FOR    ${iter}    IN RANGE    ${list_length}
        Log     ${split_string}[${iter}]
        ${parameter_contents}=  Get File    ${${split_string}[${iter}]}
        Should Contain Any     ${contents}     ${parameter_contents}
    END
    ${status}=      Get Regexp Matches     ${contents}     0x52[0-9a-fA-F]+
    ${new_status}=  Remove Duplicates   ${status}
    ${status_length}=   Get Length  ${new_status}
    Run Keyword If  '${list_length}' != '${status_length}'    Fail    New Parameter Added.


[1]CB007041_Verification of R&D debug parameters check with persistency value
##########Persistency type=non persistent and all parameters are set to non-default
    Suite Setup Preconditions
    Split parameter names from list
    Set all parameter to non-default with Persistency type   ${split_names}  ${count_of_paramnames}  ${non-persistent}
    Check Parameter Values  ${nondefault_op}
#########Reset BTS
    Reset Bts        verify_bts=False    req_rat=5g        should_be_onair=False    wait_for=300
    Sleep      300
    Check Parameter Values      ${default_op}
##############Check values are restored to default after reboot
    &{not_persistent}=     Get Rad Debug Parameters     domain=ERadSwDomain_OamTas  detailed_output=True   timeout=100
    Run Keyword If      '${not_persistent}[requestStatus]'=='completed'    Log To Console  Status OK
    Run Keyword If      '${not_persistent}[errorCode]'=='0'    Log To Console   Values set to default
###########Check swconfig file after setting to default#######
    Setup Remote Access     remote_device=bts       alias=default
    ${swconfig_file}=   Execute Interactive Remote Command  command=cat /ffs/run/swconfig.txt |grep 0x52   alias=default
    Should Contain      ${swconfig_file}    ${swconfig_norad}
    Teardown Remote Access      alias=default
#################Persistency type=one-reset and all parameters are set to non-default
    Split parameter names from list
    Set all parameter to non-default with Persistency type  ${split_names}  ${count_of_paramnames}  ${one_reset}
    Check Parameter Values  ${nondefault_op}
#########Check values in swconfig_oneshot.txt file are in non-default
    Setup Remote Access     remote_device=bts       alias=default
    ${swconfig_file}=   Execute Interactive Remote Command  command=cat /ffs/run/swconfig_oneshot.txt |grep 0x52
    ...     alias=default
    Should Contain      ${swconfig_file}    ${rad_non_default_swconfig}
    Teardown Remote Access      alias=default
##########Reset Bts###
    Reset Bts        verify_bts=False    req_rat=5g        should_be_onair=False    wait_for=300
    Sleep      300
    Check Parameter Values  ${nondefault_op}
############Check values are not stored to default after reboot
    &{one_reset}=     Get Rad Debug Parameters  domain=ERadSwDomain_OamTas  detailed_output=True   timeout=100
    Run Keyword If      '${one_reset}[requestStatus]'=='completed'    Log To Console  Status OK
    Run Keyword If      '${one_reset}[errorCode]'=='0'    Log To Console   Values set to non-default
##########Check values in swconfig_oneshot.txt_tmp are still in non-default after reboot
    Setup Remote Access     remote_device=bts       alias=default
    ${swconfig_file}=   Execute Interactive Remote Command
    ...     command=cat /ffs/run/swconfig_oneshot.txt_tmp |grep 0x52   alias=default
    Should Contain      ${swconfig_file}    ${rad_non_default_swconfig}
    Teardown Remote Access      alias=default
#########Reset Bts again to verify one-reset persistency type
    Reset Bts        verify_bts=False    req_rat=5g        should_be_onair=False    wait_for=300
    Sleep      300
    Check Parameter Values      ${default_op}
###########Check values are stored to default after reboot
    &{one_reset}=     Get Rad Debug Parameters  domain=ERadSwDomain_OamTas  detailed_output=True   timeout=100
    Run Keyword If      '${one_reset}[requestStatus]'=='completed'    Log To Console  Status OK
    Run Keyword If      '${one_reset}[errorCode]'=='0'    Log To Console   Values set to non-default
#########Check that swconfig.txt has no entries of rad as they are stored to default values after one reset.
    Setup Remote Access     remote_device=bts       alias=default
    ${swconfig_file}=   Execute Interactive Remote Command
    ...     command=cat /ffs/run/swconfig.txt |grep 0x52   alias=default
    Should Contain      ${swconfig_file}    ${swconfig_norad}
    Teardown Remote Access      alias=default