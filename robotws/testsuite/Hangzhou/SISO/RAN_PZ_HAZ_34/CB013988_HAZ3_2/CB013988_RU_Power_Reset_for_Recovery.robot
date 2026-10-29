*** Settings ***
Documentation     author: Zhang Yu
...               contact: yu.8.zhang@nokia-sbell.com
...               squad group: VRF HAZ3 2
...               feature: CB013988-A
Suite Setup       SISO Coam Suite Setup
Suite Teardown    SISO Coam Suite Teardown
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB013988_HAZ3_2/Resource/CB013988_resource.robot


*** Variables ***
${if_commissioning}   True

*** Test Cases ***
[1]CB013988_A_002_A#B001_RU_power_reset_escalation_for_missing_M-Plane_connection_ALT2
    # ru_type=AVHA
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    RU_power_reset_escalation_for_missing_M-Plane_connection
    ...       ru_index=4    hw_name=BBMOD-2    sfp_port1=RF3    sfp_port2=RF4
    [Teardown]    SISO Coam Test Teardown

[2]CB013988_A_002_A#B001_RU_power_reset_escalation_for_missing_M-Plane_connection_ALT2
    # ru_type=AVQQA
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    RU_power_reset_escalation_for_missing_M-Plane_connection
    ...       ru_index=5    hw_name=BBMOD-2    sfp_port1=RF1    sfp_port2=RF2
    [Teardown]    SISO Coam Test Teardown


[3]CB013988_A_002_A#B001_RU_power_reset_escalation_for_missing_M-Plane_connection_ALT2
    # ru_type=AQQJ
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    RU_power_reset_escalation_for_missing_M-Plane_connection
    ...       ru_index=3    hw_name=BBMOD-1    sfp_port1=RF5    sfp_port2=RF6
    [Teardown]    SISO Coam Test Teardown

[4]CB013988_A_002_A#B001_RU_power_reset_escalation_for_missing_M-Plane_connection_ALT2
    # ru_type=AQQK
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    RU_power_reset_escalation_for_missing_M-Plane_connection
    ...       ru_index=2    hw_name=BBMOD-1    sfp_port1=RF3    sfp_port2=RF4
    [Teardown]    SISO Coam Test Teardown

[1]CB013988_A_004_A#B002_RU_power_reset_escalation_for_internal_radio_recovery_ALT2
    # ru_type=AVHA
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    RU_power_reset_escalation_for_internal_radio_recovery    ru_index=4
    [Teardown]    SISO Coam Test Teardown

[2]CB013988_A_004_A#B002_RU_power_reset_escalation_for_internal_radio_recovery_ALT2
    # ru_type=AVQQA
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    RU_power_reset_escalation_for_internal_radio_recovery    ru_index=5
    [Teardown]    SISO Coam Test Teardown

[3]CB013988_A_004_A#B002_RU_power_reset_escalation_for_internal_radio_recovery_ALT2
    # ru_type=AQQJ
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    RU_power_reset_escalation_for_internal_radio_recovery    ru_index=3
    [Teardown]    SISO Coam Test Teardown

[4]CB013988_A_004_A#B002_RU_power_reset_escalation_for_internal_radio_recovery_ALT2
    # ru_type=AQQK
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    RU_power_reset_escalation_for_internal_radio_recovery    ru_index=2
    [Teardown]    SISO Coam Test Teardown