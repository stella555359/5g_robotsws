*** Settings ***
Documentation
...    Testsuite for regression testing of feature CB009512-B part 2: TC20.
...    author: Lukasz Wlosowicz, lukasz.wlosowicz@nokia.com
...    maintainer: Lukasz Wlosowicz, lukasz.wlosowicz@nokia.com
...
...    Architecture of this suite:
...    Since TC20 has a Test Step with rollback to release N-1 (and later also another rollback back to N build),
...    it requires having the N-1 build on passive partition).
...    Thus I propose to utilize UPDATE_PATH tag with n1 param - just the same as its done with regular UUF suites.
...    (or alternatively tag UUF_BUILD for specific N-1 SBTS build).
...    Thanks to this UTE_CLOUD (Common Agent) will load build from N-1 release, and after test it will report the test run on N build to Rep-Portal.
...
...    Note: normally the upgrade keyword would be placed in Suite Setup but it doesn't work, because of taf.rfrl.csv4all lib constraint;
...        (keywords from taf.rfrl.csv4all (e.g. E2E TL UPGRADE TEST) can be launched only inside a testcase - and not in suite setup).
...
...    If you run test locally on VM you need to specify \${N-1_RELEASE_SW} and \${N_RELEASE_SW} variables and have N-1 build on active partition.

Resource    ./resources/keywords-B.robot

Suite Setup       Common suite setup with OnAir test line preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...               increase_timeout_for_update_sw=900
...               increase_time_for_checking_cells=600
...               prefix_tag=CB010652-C
Suite Teardown    Common suite teardown


*** Test Cases ***
[1][1.0] CB009512-B-SR-20-Verifying_synchronization_parameters_behavior_on_ASIR_after_rollback-Exploratory_Test
    [Setup]    Setup for TC20 with upgrade from N-1 to N
    asirHubOp.Verify only allowed alarms are active    allowed_alarms=${ASIR_ALLOWED_ALARMS}
    Verify actlogincredpartitionsync is set to true
    ${SECPRM_AFTER_UPGRADE}=    Get current SECPRM params values from ASiR
    Modify SECPRM parameters on ASiR    ${SECPRM_BEFORE_FIRST_ROLLBACK}    ${SECPRM_AFTER_UPGRADE}
    Rollback from N to N-1
    asirHubOp.Verify only allowed alarms are active    allowed_alarms=${ASIR_ALLOWED_ALARMS}
    Validate SECPRM values on ASiR    ${SECPRM_BEFORE_FIRST_ROLLBACK}
    Modify SECPRM parameters on ASiR    ${SECPRM_BEFORE_SECOND_ROLLBACK}    ${SECPRM_BEFORE_FIRST_ROLLBACK}
    Verify actlogincredpartitionsync is set to true
    Rollback from N-1 to N
    asirHubOp.Verify only allowed alarms are active    allowed_alarms=${ASIR_ALLOWED_ALARMS}
    Validate SECPRM values on ASiR    ${SECPRM_BEFORE_SECOND_ROLLBACK}
    [Teardown]    Teardown for TC20
