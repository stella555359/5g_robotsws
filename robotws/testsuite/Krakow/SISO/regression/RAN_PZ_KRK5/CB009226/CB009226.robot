*** Settings ***
Documentation
...   Test suite for regression testing of feature CB009226
...   author: Mateusz Bugaj
...   contact: mateusz.bugaj@nokia.com


Resource     taf/rfrl/bts/robot/gnb.robot
Resource     ./resources/common_keywords.robot

Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    ./resources/common_variables.py

Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=testsuite/Krakow/SISO/regression/RAN_PZ_KRK5/CB009226/resources/swconfig.txt
...               increase_timeout_for_update_sw=3600
...               prefix_tag=CB009226
Suite Teardown     Common Suite Teardown

*** Test Cases ***
CB009226_AEQE_testability_testing
    [Setup]     Actions before test        alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Clock_Link_and_QSFP]
    Verify SFP Data     expected_items_sfp=${expected_items_sfp}
    Verify Temperature Data     rfsw_credentials=${AEQE_credentials}
    [Teardown]      Actions after test

CB009226_AEQE_Manual_SiSo_FM_FID_4698_to_4701
    [Setup]     Actions before test        alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[FID_4698_to_4701]
    FOR     ${port_id_on_ru}    IN      1       2
        Trigger Faults With Temperature         rfsw_credentials=${AEQE_credentials}      port_id_on_ru=${port_id_on_ru}
        ...                                     monitoring_params=${alarm_monitoring_params}
    END
    [Teardown]      Actions after test

CB009226_AEQE_Manual_SiSo_Clock_Link_and_[Q]SFP_Monitoring_on_RU
    [Setup]     Actions before test        alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Clock_Link_and_QSFP]
    Prepare RU link order                   rfsw_credentials=${AEQE_credentials}
    Trigger Faults On Secondary Link        rfsw_credentials=${AEQE_credentials}        alarms_on_ru=${alarms_on_ru}
    Trigger Faults On Primary Link          rfsw_credentials=${AEQE_credentials}
    [Teardown]      Actions after test
