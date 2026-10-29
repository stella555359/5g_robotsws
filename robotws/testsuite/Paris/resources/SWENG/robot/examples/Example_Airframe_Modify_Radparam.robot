*** Settings ***
Documentation
...          Example demonstrating how to modify and retrieve RAD parameters on Cloud RAN using Airframes library.
...
...          This example shows:
...          - How to set RAD parameters using AaShell commands
...          - How to retrieve all non-zero RAD parameters
...          - How to extract specific parameter values from the result

Resource                            ../Tools.robot
Resource                            ../Setup.robot
Resource                            ../Airframes.robot
Library                             ../../python/StringTool.py
Library                             ../../python/OsTool.py

Suite Setup                         Suite Setup From scratch

*** Keywords ***
Example Set And Get RAD Parameters
    [Documentation]
    ...    Set RAD parameters and retrieve their values using AaShell on Cloud RAN.
    ...
    ...    This keyword demonstrates:
    ...    1. Setting rdRiDataTrimThreshold (0x58061c) to 15
    ...    2. Setting rdAutoRiThresBaseCalcInterval (0x58061d) to 15
    ...    3. Retrieving all non-zero RAD parameters
    ...    4. Extracting specific parameter values
    ...
    ...    | gnb         | GNB instance (${GNB_DU} or ${GNB_CU})               |
    ...    | domain_nom  | Domain name (e.g., 'cprt', 'L2PS')                  |
    ...    | domain_elem | Domain element/pod suffix (e.g., 'cprt-0')          |
    ...
    [Arguments]    ${gnb}=${GNB_DU}    ${domain_nom}=cprt    ${domain_elem}=cprt-0

    # Step 1: Set rdRiDataTrimThreshold to default value (15)
    Dated Log    Setting rdRiDataTrimThreshold (0x58061c) to 15
    Set Rad Parameter Using Aashell
    ...    rad_param_value=15
    ...    rad_param=0x58061c
    ...    gnb=${gnb}
    ...    domain_nom=${domain_nom}
    ...    domain_elem=${domain_elem}

    # Step 2: Set rdAutoRiThresBaseCalcInterval to 15 minutes
    Dated Log    Setting rdAutoRiThresBaseCalcInterval (0x58061d) to 15
    Set Rad Parameter Using Aashell
    ...    rad_param_value=15
    ...    rad_param=0x58061d
    ...    gnb=${gnb}
    ...    domain_nom=${domain_nom}
    ...    domain_elem=${domain_elem}

    # Step 3: Retrieve all non-zero RAD parameters
    Dated Log    Retrieving all non-zero RAD parameters
    ${rad_master_nonzero_values}=    Get Rad Value Using Aashell3
    ...    gnb=${gnb}
    ...    domain_nom=${domain_nom}
    ...    domain_elem=${domain_elem}

    # Step 4: Extract specific parameter value (0x58061c)
    ${0x58061c_val}=    Get Rad Parameter Dictionary
    ...    rad_params_list=${rad_master_nonzero_values}
    ...    rad_param_identifier=0x58061c
    Dated Log    rdRiDataTrimThreshold (0x58061c) value: ${0x58061c_val}

    # Step 5: Extract specific parameter value (0x58061d)
    ${0x58061d_val}=    Get Rad Parameter Dictionary
    ...    rad_params_list=${rad_master_nonzero_values}
    ...    rad_param_identifier=0x58061d
    Dated Log    rdAutoRiThresBaseCalcInterval (0x58061d) value: ${0x58061d_val}
