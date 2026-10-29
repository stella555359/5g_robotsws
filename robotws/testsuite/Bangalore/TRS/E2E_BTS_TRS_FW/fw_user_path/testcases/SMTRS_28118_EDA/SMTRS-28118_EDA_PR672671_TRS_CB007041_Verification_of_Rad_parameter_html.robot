*** Settings ***
Documentation
    ...     [Procedure]             "The testcase verifies PR672671 where RadParameter.html file is checked for
    ...     Tas Parameters"
    ...     [Date]                  "25-11-22"
    ...     [Author]                "Sushma R"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Funtion_Hash_Tags]     "RAD BTS logs"
    ...     [Feature_ID]            "CB007041"
    ...     [Validation_status]     "Validated and Passed"
    ...     [Validated_TestLine]    "5G-3907"
	...     [Config]    			"Check that the RAD parameters are updated in the html file"

Suite Setup		Setup Oamops
Suite Teardown	Teardown Oamops

Variables         ta_e2e_bts_trs_fw
Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot

*** Test Cases ***
[1]CB007041_Verification of R&D debug parameters with single parameter reset in BTS_CLI
    [Documentation]	    This testcase verifes that the RAD parameterhtml file coming from build and the s/w are in sync
######Download build#########
    ${rc}   ${output}=  Run And Return Rc And Output
    ...     command=wget http://lterel.es-si-s3-z2.eecloud.nsn-net.net/build/${release}/${build}_RadParameters.zip
    ${copied_path}=   Move file      ${radfile_path}     ${tmp_rad_file_path}
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
