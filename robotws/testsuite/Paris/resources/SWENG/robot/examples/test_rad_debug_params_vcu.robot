*** Settings ***
Documentation    Example test suite demonstrating RAD debug parameter configuration on Cloud RAN VCU.
...
...              This example shows how to configure RAD debug parameters for various domains
...              on VCU using the OAM Update RAD Debug Parameters keyword.
...
...              **Prerequisites:**
...              - Cloud AIC CU architecture
...              - VCU connection available
...              - Proper credentials configured in test line config
...
...              **RAD Parameter Examples:**
...              - RLC/LoggingLevel: Logging verbosity (0=Off, 1=Debug, 2=Info, 3=Warning, 4=Error)
...              - PDCP/rdFeatureFlagBitmapLevel: Debug level (0-4, where 4=DEBUG)
...              - MAC/rdTRSSloti: TRS slot configuration
...
...              **Verification:**
...              - Check WebEM interface for applied parameters
...              - Monitor VCU container syslog for trace output

Resource         ../Oam.robot
Library          Collections

*** Variables ***
${RAD_DOMAIN_RLC}     RLC
${RAD_DOMAIN_PDCP}    PDCP
${RAD_DOMAIN_MAC}     MAC

*** Test Cases ***
Configure RLC RAD Debug Parameters on VCU
    [Documentation]    Configure RLC domain RAD debug parameters to enable debug logging on VCU.
    ...
    ...                This test configures:
    ...                1. LoggingLevel = 1 - Debug
    [Tags]    RAD    RLC    VCU    CloudRAN

    # Connect to VCU OAM
    OAM Connect    ${GNB_CU.oam}

    # Prepare RAD parameters list
    @{rad_params}=    Create List
    ...    ${{ {'name': 'LoggingLevel', 'value': '1 - Debug'} }}

    # Configure RAD debug parameters
    ${result}=    OAM Update RAD Debug Parameters
    ...    domain_name=${RAD_DOMAIN_RLC}
    ...    parameters=${rad_params}
    ...    oam=${GNB_CU.oam}
    ...    persistency=persistent
    ...    timeout=300

    # Verify operation succeeded
    Log    RAD debug parameter configuration result: ${result}
    Should Be Equal    ${result['status']}    succeeded
    Should Not Be Empty    ${result['operation_id']}

    # Disconnect from VCU OAM
    OAM Disconnect    ${GNB_CU.oam}

    [Teardown]    Run Keyword If Test Failed    OAM Disconnect    ${GNB_CU.oam}

Configure PDCP RAD Debug Parameters on VCU
    [Documentation]    Configure PDCP domain RAD debug parameters to enable feature debugging on VCU.
    ...
    ...                This test configures:
    ...                1. rdFeatureFlagBitmapLevel = 4 (DEBUG level)
    [Tags]    RAD    PDCP    VCU    CloudRAN

    # Connect to VCU OAM
    OAM Connect    ${GNB_CU.oam}

    # Prepare RAD parameters list
    @{rad_params}=    Create List
    ...    ${{ {'name': 'rdFeatureFlagBitmapLevel', 'value': '4'} }}

    # Configure RAD debug parameters
    ${result}=    OAM Update RAD Debug Parameters
    ...    domain_name=${RAD_DOMAIN_PDCP}
    ...    parameters=${rad_params}
    ...    oam=${GNB_CU.oam}
    ...    persistency=persistent
    ...    timeout=300

    # Verify operation succeeded
    Log    RAD debug parameter configuration result: ${result}
    Should Be Equal    ${result['status']}    succeeded
    Should Not Be Empty    ${result['operation_id']}

    # Disconnect from VCU OAM
    OAM Disconnect    ${GNB_CU.oam}

    [Teardown]    Run Keyword If Test Failed    OAM Disconnect    ${GNB_CU.oam}

Configure Non-Persistent RAD Parameters on VCU
    [Documentation]    Configure RAD debug parameters with non-persistent mode on VCU.
    ...
    ...                Non-persistent parameters will be reset after VCU reboot.
    ...                This test configures:
    ...                1. rdTRSSloti = 20 (non-persistent)
    [Tags]    RAD    MAC    VCU    CloudRAN    NonPersistent

    # Connect to VCU OAM
    OAM Connect    ${GNB_CU.oam}

    # Prepare RAD parameters list
    @{rad_params}=    Create List
    ...    ${{ {'name': 'rdTRSSloti', 'value': 20} }}

    # Configure RAD debug parameters (non-persistent)
    ${result}=    OAM Update RAD Debug Parameters
    ...    domain_name=${RAD_DOMAIN_MAC}
    ...    parameters=${rad_params}
    ...    oam=${GNB_CU.oam}
    ...    persistency=non-persistent
    ...    timeout=300

    # Verify operation succeeded
    Log    RAD debug parameter configuration result: ${result}
    Should Be Equal    ${result['status']}    succeeded
    Should Not Be Empty    ${result['operation_id']}

    # Disconnect from VCU OAM
    OAM Disconnect    ${GNB_CU.oam}

    [Teardown]    Run Keyword If Test Failed    OAM Disconnect    ${GNB_CU.oam}
