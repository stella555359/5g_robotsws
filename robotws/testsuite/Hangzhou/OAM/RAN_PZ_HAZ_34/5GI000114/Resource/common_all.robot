*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource   ./NetAct_Fast_Pass_common.robot

*** Variables ***
# ${file_name}   old_commission.xml

*** Keywords ***
All Get All Suite Variables
    Run Keyword If   '${gnb_type}'=='classical'   COAM Get All Suite Variables
    ...   ELSE IF    '${gnb_type}'=='cloud'   Megazone Get All Suite Variables
    ...   ELSE IF    '${gnb_type}'=='coamcu'   Log To Console   //TODO:
    ...   ELSE IF    '${gnb_type}'=='coamdu'   Log To Console   //TODO:

All Get All Suite Variables NetAct Only
    @{package_str}   Split String   ${SOFTWARE_VERSION}   .
    ${package_header}   Set Variable   ${package_str[0]}.
    ${oib_param}   Set Variable   ${SW_RELEASE_MAP["${package_header}"]}
    Set Suite Variable   ${NIDD_RELEASE}   ${oib_param["NIDD_RELEASE"]}
    Set Suite Variable   ${ProductName}   ${oib_param["ProductName"]}
    Set Suite Variable   ${ProductRelName}   ${oib_param["ProductRelName"]}
    Set Suite Variable   ${PackageName}   ${oib_param["PackageName"]}
    Set Suite Variable   ${DomainName}   ${oib_param["DomainName"]}

All Wait GNB Startup
    Run Keyword If   '${gnb_type}'=='classical'   COAM Wait GNB Startup
    ...   ELSE IF    '${gnb_type}'=='cloud'   Megazone Wait GNB Startup
    ...   ELSE IF    '${gnb_type}'=='coamcu'   Log To Console   //TODO:
    ...   ELSE IF    '${gnb_type}'=='coamdu'   Log To Console   //TODO:

All Check Cell Status Expected
    [Arguments]    ${cell_target_status}
    Run Keyword If   '${gnb_type}'=='classical'   COAM Check Cell Status Expected   cell_target_status=${cell_target_status}
    ...   ELSE IF    '${gnb_type}'=='cloud'   Megazone Check Cell Status Expected   cell_target_status=${cell_target_status}
    ...   ELSE IF    '${gnb_type}'=='coamcu'   Log To Console   //TODO:
    ...   ELSE IF    '${gnb_type}'=='coamdu'   Log To Console   //TODO:
    
All Check Snssai Status Expected
    [Arguments]    ${snssai_target_status}
    Run Keyword If   '${gnb_type}'=='classical'   COAM Check Snssai Status Expected   snssai_target_status=${snssai_target_status}
    ...   ELSE IF    '${gnb_type}'=='cloud'   Megazone Check Cell Status Expected   cell_target_status=${cell_target_status}
    ...   ELSE IF    '${gnb_type}'=='coamcu'   Log To Console   //TODO:
    ...   ELSE IF    '${gnb_type}'=='coamdu'   Log To Console   //TODO:

All Check Configuration Values
    [Arguments]   ${dist_name}   ${parameter}   ${expect_value}
    Run Keyword If   '${gnb_type}'=='classical'
    ...   COAM Login And Check Parameter Value   dist_name=${dist_name}   parameter=${parameter}   expect_value=${expect_value}
    ...   ELSE IF    '${gnb_type}'=='cloud'
    ...   Megazone Login And Check Parameter Value   dist_name=${dist_name}   parameter=${parameter}   expect_value=${expect_value}
    ...   ELSE IF    '${gnb_type}'=='coamcu'   Log To Console   //TODO:
    ...   ELSE IF    '${gnb_type}'=='coamdu'   Log To Console   //TODO:

All Modify Configuration Values
    [Arguments]   ${dist_name}   ${parameter}   ${value}
    Run Keyword If   '${gnb_type}'=='classical'
    ...   COAM Update Parameter ON COAM ADMIN   dist_name=${dist_name}   parameter=${parameter}   value=${value}
    ...   ELSE IF    '${gnb_type}'=='cloud'   Log To Console   //TODO:
    ...   ELSE IF    '${gnb_type}'=='coamcu'   Log To Console   //TODO:
    ...   ELSE IF    '${gnb_type}'=='coamdu'   Log To Console   //TODO:

All Backup SCF
    [Arguments]   ${local_dir}=${OUTPUT_DIR}   ${file_name}=old_commission.xml
    Run Keyword If   '${gnb_type}'=='classical'   COAM Login And Backup SCF   local_dir=${local_dir}   file_name=${file_name}
    ...   ELSE IF    '${gnb_type}'=='cloud'   Megazone Login And Backup SCF   local_dir=${local_dir}   file_name=${file_name}
    ...   ELSE IF    '${gnb_type}'=='coamcu'   Log To Console   //TODO:
    ...   ELSE IF    '${gnb_type}'=='coamdu'   Log To Console   //TODO:

All Load SCF
    [Arguments]   ${filepath}=${OUTPUT_DIR}/old_commission.xml
    Run Keyword If   '${gnb_type}'=='classical'   COAM Login And Load SCF   filepath=${filepath}
    ...   ELSE IF    '${gnb_type}'=='cloud'   Megazone Login And Load SCF   filepath=${filepath}
    ...   ELSE IF    '${gnb_type}'=='coamcu'   Log To Console   //TODO:
    ...   ELSE IF    '${gnb_type}'=='coamdu'   Log To Console   //TODO:

