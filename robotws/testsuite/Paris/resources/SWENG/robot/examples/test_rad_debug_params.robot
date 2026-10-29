*** Settings ***
Documentation    Example test suite demonstrating RAD debug parameter configuration on Cloud RAN VDU.
...
...              This example shows how to configure RAD debug parameters for the L2PS domain
...              using the OAM Update RAD Debug Parameters keyword.
...
...              **Prerequisites:**
...              - Cloud AIC DU architecture
...              - VDU connection available
...              - Proper credentials configured in test line config
...
...              **RAD Parameter Examples:**
...              - L2PS/rdFeatureFlagBitmapLevel: Debug level (0-4, where 4=DEBUG)
...              - L2PS/rdFeatureFlagBitmap4: Feature bitmap for RIM (Radio Interface Module)
...                  Bit 0: RIM.COMMON
...                  Bit 1: RIM.RI
...                  Bit 2: RIM.RI_SELECTOR
...                  Bit 3: RIM.RS_DL
...                  Bit 6: RIM.RS_UL
...                  Example: 1001111b = 79d = 0x4F
...
...              **Verification:**
...              - Check WebEM interface for applied parameters
...              - Monitor container cprt syslog for trace output

Resource         ../Oam.robot
Library          Collections

*** Variables ***
${RAD_DOMAIN}    L2PS

*** Test Cases ***
Configure L2PS RAD Debug Parameters for RIM Feature
    [Documentation]    Configure L2PS domain RAD debug parameters to enable RIM feature debugging.
    ...
    ...                This test configures:
    ...                1. rdFeatureFlagBitmapLevel = 4 (DEBUG level)
    ...                2. rdFeatureFlagBitmap4 = 79 (Enable RIM.COMMON, RIM.RI, RIM.RI_SELECTOR, RIM.RS_DL, RIM.RS_UL)
    [Tags]    RAD    L2PS    RIM    CloudRAN

    # Connect to VDU OAM
    OAM Connect    ${GNB_DU.oam}

    # Prepare RAD parameters list
    @{rad_params}=    Create List
    ...    ${{ {'name': 'rdFeatureFlagBitmapLevel', 'value': '4'} }}
    ...    ${{ {'name': 'rdFeatureFlagBitmap4', 'value': '79'} }}

    # Configure RAD debug parameters
    ${result}=    OAM Update RAD Debug Parameters
    ...    domain_name=${RAD_DOMAIN}
    ...    parameters=${rad_params}
    ...    oam=${GNB_DU.oam}
    ...    persistency=persistent
    ...    timeout=300

    # Verify operation succeeded
    Log    RAD debug parameter configuration result: ${result}
    Should Be Equal    ${result['status']}    succeeded
    Should Not Be Empty    ${result['operation_id']}

    # Disconnect from VDU OAM
    OAM Disconnect    ${GNB_DU.oam}

    [Teardown]    Run Keyword If Test Failed    OAM Disconnect    ${GNB_DU.oam}


Configure Custom RAD Parameters
    [Documentation]    Example of configuring custom RAD parameters for different domain.
    ...
    ...                Modify this test to configure parameters for other RAD domains
    ...                like RLC, MAC, PDCP, etc.
    [Tags]    RAD    Custom    CloudRAN

    # Example: Configure RLC domain parameters
    # Uncomment and modify as needed:
    #
    # OAM Connect    ${GNB_DU.oam}
    #
    # @{rlc_params}=    Create List
    # ...    ${{ {'name': 'parameterName1', 'value': 'value1'} }}
    # ...    ${{ {'name': 'parameterName2', 'value': 'value2'} }}
    #
    # ${result}=    OAM Update RAD Debug Parameters
    # ...    domain_name=RLC
    # ...    parameters=${rlc_params}
    # ...    oam=${GNB_DU.oam}
    #
    # Should Be Equal    ${result['status']}    succeeded
    #
    # OAM Disconnect    ${GNB_DU.oam}

    Log    This is a template test case. Uncomment and modify as needed.
    Pass Execution    Template test case - modify for your use case


Configure Non-Persistent RAD Parameters
    [Documentation]    Example of configuring non-persistent RAD parameters.
    ...
    ...                Non-persistent parameters will be lost after VDU reboot.
    [Tags]    RAD    NonPersistent    CloudRAN

    OAM Connect    ${GNB_DU.oam}

    @{temp_params}=    Create List
    ...    ${{ {'name': 'rdFeatureFlagBitmapLevel', 'value': '3'} }}

    ${result}=    OAM Update RAD Debug Parameters
    ...    domain_name=${RAD_DOMAIN}
    ...    parameters=${temp_params}
    ...    oam=${GNB_DU.oam}
    ...    persistency=non-persistent
    ...    timeout=300

    Should Be Equal    ${result['status']}    succeeded
    Log    Non-persistent RAD parameters configured successfully

    OAM Disconnect    ${GNB_DU.oam}

    [Teardown]    Run Keyword If Test Failed    OAM Disconnect    ${GNB_DU.oam}
