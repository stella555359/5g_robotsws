*** Settings ***
Documentation
    ...     [Procedure]             "The test case is to verify the functionality of individual R&D debug parameter
    ...     by enabling through BTS CLI "
    ...     [Date]                  "13-09-22"
    ...     [Author]                "Sushma R"

variables       ta_e2e_bts_trs_fw
Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot

*** Keywords ***
Split parameter names from list
    ${split_names}=     Split String    ${name_of_all_params}   ,
    ${count_of_paramnames}=     Get Length   ${split_names}
    Log     ${count_of_paramnames}
    Set Suite Variable  ${split_names}  ${split_names}
    Set Suite Variable  ${count_of_paramnames}  ${count_of_paramnames}

Set All parameters under ERadSwDomain_OamTas domain to non-default
    [Arguments]     ${split_names}  ${count_of_paramnames}
    FOR    ${i}    IN RANGE     ${count_of_paramnames}
       Log     ${split_names}[${i}]
       Set Rad Debug Parameters    domain=ERadSwDomain_OamTas      name=${split_names}[${i}]   value=true
    ...     timeout=60   detailed_output=True    persistency=Persistent
       Run Keyword If  '${split_names}[${i}]'=='${PrintTas}'   Set Rad Debug Parameters    domain=ERadSwDomain_OamTas
    ...     name=PrintTas   value=false     timeout=60   detailed_output=True    persistency=Persistent
       Run Keyword If  '${split_names}[${i}]'=='${PrintTemSupervisor}'     Set Rad Debug Parameters
    ...     domain=ERadSwDomain_OamTas    name=PrintTemSupervisor   value=false     timeout=60   detailed_output=True
    ...     persistency=Persistent
    END

Set all parameter to non-default with Persistency type
    [Arguments]     ${split_names}  ${count_of_paramnames}  ${persistency_type}
    FOR    ${i}    IN RANGE     ${count_of_paramnames}
       Log     ${split_names}[${i}]
       Set Rad Debug Parameters    domain=ERadSwDomain_OamTas      name=${split_names}[${i}]   value=true
    ...     timeout=60   detailed_output=True    persistency=${persistency_type}
       Run Keyword If  '${split_names}[${i}]'=='${PrintTas}'   Set Rad Debug Parameters    domain=ERadSwDomain_OamTas
    ...     name=PrintTas   value=false     timeout=60   detailed_output=True    persistency=${persistency_type}
       Run Keyword If  '${split_names}[${i}]'=='${PrintTemSupervisor}'     Set Rad Debug Parameters
    ...     domain=ERadSwDomain_OamTas    name=PrintTemSupervisor   value=false     timeout=60   detailed_output=True
    ...     persistency=${persistency_type}
    END

Check Parameter Values
    [Arguments]     ${values}
    ${output}=    Get Rad Debug Parameters       domain=ERadSwDomain_OamTas  detailed_output=True   timeout=100
    ${new_string}=      Convert To String    ${output}
    Log     ${new_string}
    Should Contain Any      ${new_string}       ${values}

Set each parameter to non-default individually and check swconfig entry
    [Arguments]     ${name}     ${value}    ${swconfig_value}   ${revert_value}
    Set Rad Debug Parameters    domain=ERadSwDomain_OamTas      name=${name}   value=${value}     timeout=60
    ...     detailed_output=True    persistency=Persistent
    Setup Remote Access     remote_device=bts       alias=default
    ${swconfig_file}=   Execute Interactive Remote Command      command=cat /ffs/run/swconfig.txt |grep 0x52
    ...     alias=default
    Should Contain  ${swconfig_file}    ${swconfig_value}
    Teardown Remote Access      alias=default
    Set Rad Debug Parameters    domain=ERadSwDomain_OamTas      name=${name}   value=${revert_value}    timeout=60
    ...     detailed_output=True    persistency=Persistent

Check swconfig entry
#####Set each parameter to non default individually to check swconfig entry
    Set each parameter to non-default individually and check swconfig entry     PrintTas    false
    ...     ${swconfig_for_printtas}    true
    Set each parameter to non-default individually and check swconfig entry     PrintLimModule  true
    ...     ${swconfig_for_limmodule}   false
    Set each parameter to non-default individually and check swconfig entry     PrintCore   true
    ...     ${swconfig_for_core}    false
    Set each parameter to non-default individually and check swconfig entry     PrintEthernetConfigurationService
    ...     true    ${swconfig_for_ethsvc}  false
    Set each parameter to non-default individually and check swconfig entry     PrintTemSupervisor  false
    ...     ${swconfig_for_temsup}  true
    Set each parameter to non-default individually and check swconfig entry     PrintRuntimeTreeBuilder
    ...     true    ${swconfig_for_tree}    false
    Set each parameter to non-default individually and check swconfig entry     PrintTemController  true
    ...     ${swconfig_for_temcont}     false
    Set each parameter to non-default individually and check swconfig entry     PrintLocalIncomingReqGateway
    ...     true    ${swconfig_for_reqgw}   false
    Set each parameter to non-default individually and check swconfig entry     Twamp   true    ${swconfig_for_twamp}
    ...     false

Preconditions for CB007041
#########Restore all to default value##########
    Reset   operation=reset_rad_debug_parameters    name=ALL
########Reset BTS#######
#    Reset Bts        verify_bts=False    req_rat=5g        should_be_onair=False    wait_for=300
#    Sleep   600
###COnfigure scf
#    Perform Commissioning   scf_file=${Full_Configuration}   verify_bts_status=False     timeout=400     alias=default

Get All Rad Debug Parameter for ERadSwDomain_OamTas domain set to non-default
    [Arguments]     ${split_names}  ${count_of_paramnames}
    FOR    ${i}    IN RANGE     ${count_of_paramnames}
       Log     ${split_names}[${i}]
       Get Rad Debug Parameter Details    domain=ERadSwDomain_OamTas      parameter_name=${split_names}[${i}]
    ...     value=true      timeout=60   detailed_output=True    persistency=Persistent
       Run Keyword If  '${split_names}[${i}]'=='${PrintTas}'   Get Rad Debug Parameter Details
    ...     domain=ERadSwDomain_OamTas   parameter_name=PrintTas   value=false     timeout=60   detailed_output=True
    ...     persistency=Persistent
       Run Keyword If  '${split_names}[${i}]'=='${PrintTemSupervisor}'     Get Rad Debug Parameter Details
    ...     domain=ERadSwDomain_OamTas     parameter_name=PrintTemSupervisor   value=false     timeout=60
    ...     detailed_output=True    persistency=Persistent
    END

Set few parameter to default
    ${few_params}=     Split String    ${name_of_few_params}   ,
    ${count_of_few_params}=     Get Length   ${few_params}
    FOR    ${i}    IN RANGE     ${count_of_few_params}
       Log     ${few_params}[${i}]
       Set Rad Debug Parameters    domain=ERadSwDomain_OamTas      name=${few_params}[${i}]   value=false
    ...     timeout=60   detailed_output=True    persistency=Persistent
       Run Keyword If  '${few_params}[${i}]'=='${PrintTas}'   Set Rad Debug Parameters    domain=ERadSwDomain_OamTas
    ...     name=PrintTas   value=true   timeout=60   detailed_output=True    persistency=Persistent
    END

Restore all values individually to default
    ${remaining_params}=    Split String    ${name_of_rem_params}   ,
    ${count_of_rem_params}=     Get Length  ${remaining_params}
    FOR    ${i}    IN RANGE    ${count_of_rem_params}
       Reset   operation=reset_rad_debug_parameters    domain=ERadSwDomain_OamTas      name=${remaining_params}[${i}]
    END