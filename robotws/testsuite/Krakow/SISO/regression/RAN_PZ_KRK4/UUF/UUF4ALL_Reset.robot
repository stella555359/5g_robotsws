*** Settings ***
Documentation
...   author: Jakub Kupiec
...   contact: jakub.kupiec@nokia.com, tomasz.kacza@nokia.com
...   UFF4ALL reset test suite

Resource     taf/rfrl/uuf4all/uuf4all_test_cases.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Force Tags    STATE_SW_UPLOADED    RAN_5G    RAN_5G_MP    CA_RAN_PZ_KRK
...           RAN_5G_TDD_MP  RAN_5G_FDD_MP_CUSTOMER
...           SBTS00__WITH__CLOUD_5G_CLASSICAL_ASIBL_ABILB1B2B3_3xAEQC__WITH__CDRT
...           SBTS23R1__WITH__CLOUD_5G_CLASSICAL_ASIBL_ABILB1B2B3_3xAEQC__WITH__CDRT
...           SBTS22R4__WITH__CLOUD_5G_CLASSICAL_ASIBL_ABILB1B2B3_3xAEQC__WITH__CDRT
...           SBTS22R3__WITH__CLOUD_5G_CLASSICAL_ASIBL_ABILB1B2B3_3xAEQC__WITH__CDRT

Suite Setup       Run Keywords    Common Suite Setup    AND    Perform Full Commissioning On Classical Gnb    update_timeout=1200
Suite Teardown    Common Suite Teardown
Test Setup        Common Preconditions
Test Teardown     Common Postconditions


*** Variables ***
@{CUSTOM_ALARMS}         7115     4298
@{CRITICAL_FAULTS}=     0010  0016  1806  1868  4341  4352  4383
@{CUSTOMERS_LIST}=        Telia-Sonera Finland
@{customers}=             Telia-Sonera Finland
@{additional_allowed_alarms} =  ToP reference missing

*** Test Cases ***
UUF4ALL_RESET_TEST
    [Tags]    uuf
    UUF4ALL_SITE_RESET_TEST    test_iteration=20
    ...                        custom_alarms=${CUSTOM_ALARMS}
    ...                        critical_faults=${CRITICAL_FAULTS}
    ...                        customers_list=${customers}
