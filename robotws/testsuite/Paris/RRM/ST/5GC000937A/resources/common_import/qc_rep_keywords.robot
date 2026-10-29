*** Settings ***
Documentation
...  author:    SVenkata Rajesh
...  contact:   venkata.rajesh@nokia.com
...  Description:   Command line to set results to QC

Library    OperatingSystem
Library    Collections
Library    String
Library    taf.gnb.oam.coam.admin                WITH NAME      coam

Library    ./python/qc_reporting_portal.py
Library    taf.gnb.oam.megazone_client  WITH NAME    megazone_client
Library    taf.sw.reporting_portal    WITH NAME    ute_reporting_portal

*** Keywords ***
Report Result To Rp
    [Arguments]    ${reporting_dict}   ${test_instance_name}=${TEST NAME}
     ...           ${result_of_test}=${None}      ${counter_results}=${None}     ${kpi_results}=${None}
    [Documentation]  reports TC result to reporting portal and QC without qc_id
    ...    Use TAG name 'SKIP_REPORT' to skip the sending Report result to REP
    ...    Variable:
    ...  reporting_dict:  contains below parameters with example.
    ...  {'qc_project': '5G', 'qc_domain': 'MN_5G', 'squad': '5G_SW_IND-Bangalore', 'username': 'owner',
    ...   'suite_path': '/robotws5g/tree/master/testsuite/RRM/ECE/UE_Call_Setup/5GC000341/5GC000341.robot',
    ...   'qc_test_set_name': '5GC000341_5gNB_Reconfiguration_with_Site_Outage',
    ...    'features_covered': ["5GC000341-A", "5GC000341-B"],
    ...     'qc_testlab_paths': ['Root\\Test_Sets\\Trunk\\0.135\\5G_SW\UE_Call_Setup',
    ...                          'Root\\Test_Sets\\Trunk\\0.835\\5G_SW\UE_Call_Setup']}
    ...    test_instance_name:  name should be same as test case instance name in QC.
    ...    result_of_test: TC status, Passed or Failed. Default None, then status will read it from ${TEST STATUS}
    ...    counter_results and kpi_results to set counter and kpi results for TC.
    ...    ute_testline - run time variable is mandatory to send result to REP.
    ...  author:        venkata.rajesh@nokia.com
    ...  modified by:   <25-APR-2019>, <verajesh>
    ${sw_version}=        Get gNB information for QC REP
    qc_reporting_portal.send_report_to_rep      tc_name=${test_instance_name}
    ...   report=${reporting_dict}
    ...   sw_version=${sw_version}
    ...   tc_status=${result_of_test}
    ...   tc_counters=${counter_results}
    ...   tc_kpi=${kpi_results}

Get cOAM gNB information
    coam.connect to    bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...               bts_port=${tl.gnbs[0].cu.oam_http_connection_details.port}     name=qc_cOAM
    ${software_info}=    coam.get_software_info     connection=qc_cOAM
    ${sw_version}=       set variable    ${software_info['Active SW version']}
    #Convert to WFT SW version(from 5G19_FSMK_0000_018351_000364 to 5G_0.18351.364
    ${str_list}=   Split String    ${sw_version}   _
    ${sw_1}  Convert to Integer  ${str_list[2]}
    ${sw_bracnh}   Convert to Integer  ${str_list[3]}
    ${sw_load}   Convert to Integer  ${str_list[4]}
    ${sw_version}  set variable   5G_${sw_1}.${sw_bracnh}.${sw_load}
    [Teardown]  coam.teardown          connection=qc_cOAM
    [Return]     ${sw_version}

Get MZ oam gNB information
    megazone_client.create_session    base_url=https://${tl.gnbs[0].cu.oam_http_connection_details.addr}    alias=megazone_oam
    ${sw_version}=      megazone_client.get sw version     session=megazone_oam
    [Teardown]   megazone_client.teardown_session     session=megazone_oam
    [Return]     ${sw_version}

Get gNB information for QC REP
    ${IS_COAM}    Get Variable Value     ${IS_COAM}     True
    ${sw_version}=      run keyword if   '${IS_COAM}'=='False'   Get MZ oam gNB information
    ...   ELSE    Get cOAM gNB information
    [Return]     ${sw_version}
