*** Settings ***
Documentation
...  Reporting portal related keywords
...
...  author/contact: rafal.skrok@nokia.com

Library         taf.rfrl.common_resources.reporting_portal.bts_metadata

Library         testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsState
Library         testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsAdminApi    alias=admin_gNB
Library         testsuite.Wroclaw.SyVe.RRM.resources.VmOs
Library         testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData
Library         taf.sw.reporting_portal


*** Keywords ***
Add Enb NSA Build data to the reporting portal
    ${ENB_NSA_BUILD}=    Get LTE Running SW version
    Add to test data     data={"enb_nsa_build": "${ENB_NSA_BUILD}"}

Add scout external execution id to the reporting portal
    admin_api_connect_to
    ${tl_name_scout}=    testline_name_in_scout
    &{bts_params}=       Create dictionary
    ...                  admin_connection=admin_gNB
    ...                  scout_bts_name=${tl_name_scout}
    Run Keyword and Ignore Error     add_bts_metadata_to_report   bts_params=${bts_params}
    [Teardown]           admin_api_teardown    connection=admin_gNB
