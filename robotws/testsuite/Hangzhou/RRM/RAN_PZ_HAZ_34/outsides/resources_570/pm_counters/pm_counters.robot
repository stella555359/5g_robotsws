*** Settings ***
Library  taf.collectors.pmcounters  WITH NAME   pm
Library  taf.analyzer.pmcounter
Library  testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/outsides/resources_570/rrm_fixture.py
Library  pm_counters_backend.py
Library  OperatingSystem


*** Keywords ***
Collect counters
    [Arguments]  ${n_last}=8
    &{webservice}=   Create dictionary
    ...                 host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...                 user=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...                 password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...                 port=443
    ${oam_type}=  Get Oam Type
    ${oam_type}=  pm_counters_backend.Resolve oam type name   ${oam_type}
    pm.Create PM collector   name=collector   webservice=&{webservice}   oam_type=${oam_type}
    pm.setup collectors      names=collector
    pm.collect collectors    names=collector
    pm.teardown collectors    names=collector
    Remove counter files except for last   ${n_last}

Get last counter values
    [Documentation]  This keyword returns dictionary with the structure given below:
    ...              { counter_id : { cell_id : counter_value }}
    ...              counter_id ->  in example   M55316C05001
    ...              cell_id    ->  global cell id, typically  1 or 2 and so on
    ...              counter_value -> in example  0
    [Arguments]   @{counter_ids}
    ${counters_count}=  Get Length  ${counter_ids}
    ${pi_dict}=  get_pi_value
    ...  pi_list=@{counter_ids}
    ...  pi_dir=${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/collector
    ...  pi_file_pattern=*PM*
    ${value_dict}=  Extract last values from pi dict   ${pi_dict}   ${counters_count}   1
    Log   Returned counter values dict: ${value_dict}
    [Return]  ${value_dict}

Get sum of n last counter values
    [Documentation]  This keyword returns dictionary with the structure given below:
    ...              { counter_id : { cell_id : counter_value }}
    ...              counter_id ->  in example   M55316C05001
    ...              cell_id    ->  global cell id, typically  1 or 2 and so on
    ...              counter_value -> in example  0
    [Arguments]   ${n_last}   @{counter_ids}
    ${counters_count}=  Get Length  ${counter_ids}
    ${pi_dict}=  get_pi_value
    ...  pi_list=@{counter_ids}
    ...  pi_dir=${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/collector
    ...  pi_file_pattern=*PM*
    ${value_dict}=  Extract last values from pi dict   ${pi_dict}   ${counters_count}   ${n_last}
    Log   Returned counter values dict: ${value_dict}
    [Return]  ${value_dict}

Cleanup all downloaded counter files
    ${dir_name}=  set variable   ${OUTPUTDIR}/${SUITENAME}
    Remove Directory   ${dir_name}   ${TRUE}

Remove counter files except for last
    [Arguments]  ${n_last}
    @{files}=   OperatingSystem.List Files in Directory   ${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/collector   *.xml   absolute
    Remove Files    @{files[:-${n_last}]}
