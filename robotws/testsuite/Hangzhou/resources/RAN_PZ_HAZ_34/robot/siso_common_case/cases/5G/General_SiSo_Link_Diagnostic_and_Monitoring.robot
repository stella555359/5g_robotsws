*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/simple_keyword.robot
*** Variables ***

*** Keywords ***
General_SiSo_Link_Diagnostic_and_Monitoring
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] Purpose of this case is to Check SFP/QSFP data on the Nokia controlled links are displayed
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 01.20.2021 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    ${links}    ${SMOD}    ${BBMOD}    ${RMOD}    Get Information about SFP links
    Check if static data SFP QSFP have a valid value for ports for SMOD  ${links}     ${SMOD}
    ${physicalPort}    Check if QSFP or SFP  ${links}    ${BBMOD}
    Check if Tx parameters have a valid value for ports for BBMOD    ${links}    ${BBMOD}    ${physicalPort}
    Check if temperature parameters have a valid value for ports for SMOD   ${links}    ${SMOD}
    Check if static parameters have a valid value for ports    ${links}    ${RMOD}
    #${parsed_files}    Get snapshot and return parsed RD files
    #${RMOD_SFP_dict}    Get RMODs info
    #Check counters from SFP monitoring- file iteration    ${parsed_files}    ${RMOD_SFP_dict}    SFPRM
    #[Teardown]    Remove Directory    ${unzipped}    recursive=True
