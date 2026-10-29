*** Settings ***
Documentation  Maintainers: @I_SRAN_PROD_SISO_WRO_CRTDEV_GMS

...  Test Suite Author: Anna Plecha
...  Test Suite Owner: Anna Plecha
...  Team: T07


Resource  ../../Resources/Setup/setup_and_teardown.robot
Resource  ../../robotlte_legacy/tc_scenarios.robot
Resource   ../../robotlte_legacy/hran_ta/SiSo_SM_RU_Primary_link_break.robot
Resource   ../../robotlte_legacy/hran_ta/SiSo_SM_RU_Secondary_link_break.robot
Resource  ../../robotlte_legacy/hran_ta/SiSo_SM_RU_Secondary_link_break_with_changed_time_delay.robot
Resource   ../../robotlte_legacy/hran_ta/SiSo_SM_RU_Primary_link_break_without_recovery.robot
Resource  ../../robotlte_legacy/hran_ta/SiSo_REC_Hot_remove_insert_RU_primary_link_with_time_delay_change_fault_4685.robot
Resource  ../../robotlte_legacy/hran_ta/SiSo_REC_Hot_remove_insert_RU_secondary_link_with_time_delay_change_fault_4685.robot
Resource  ../../TestCases/SWM/SiSo_SWM_RU_and_BTS_SW_activate_triggered_by_WebEM.robot


Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition


*** Variables ***
${CUSTOM_SWITCH_PERFORM_SNAPSHOT}=            Failed      # possible settings : Failed, Always, None
${CUSTOM_SWITCH_PERFORM_HW_SETUP}=            True     # to disable hardware reconfiguration ( PDU and Optical part ) set value False
#${ENABLE_TRUCK_ROLL_FLAG}    ${False}
${SKIP_TRUCK_ROLL}     ${True}
@{additional_common_fault_list}=
#...  faultId=1815, severity=Major
#...  faultId=6450
&{CUSTOM_ADDITIONAL_ALLOWED_FAULTS}=   common=@{additional_common_fault_list}

&{ahegc_tested_cablinks}=   CABLINK-14=134  CABLINK-15=137
&{azrb_tested_cablinks}=    CABLINK-12=10.42.201.20_102
&{ahfii_tested_cablinks}=   CABLINK-7=10.42.201.20_103    CABLINK-8=10.42.201.20_104
&{ahloa_tested_cablinks}=   CABLINK-4=10.42.201.20_107
&{ahegha_tested_cablinks}=  CABLINK-5=10.42.201.20_105    CABLINK-6=10.42.201.20_106
#&{TESTED_CABLINKS_AAIB}=    CABLINK-11=189  CABLINK-10=132
#&{TESTED_CABLINKS_AAFB}=    CABLINK-4=142    CABLINK-9=133
${LONG_FIBER}=  240-288
${IP_SWITCH}=  10.42.201.20

*** Test Cases ***

###CB007447
[AHEGC][1.0] Automated_SiSo_SM_RU_Secondary_link_break_with_changed_time_delay
    [Setup]  Run Keywords
    ...  Configuration Precondition  CN=REF_10_16_UTESRANSISO129_DEFAULT  AND
    ...  Set Test Variable  ${IP_SWITCH}    10.42.201.20  AND
    ...  Set Test Variable  ${TESTED_CABLINKS_OS_PORT}  ${ahegc_tested_cablinks}  AND
    ...  Set Test Variable  ${LONG_FIBER}    240-288
    TC_SiSo_SM_RU_Secondary_link_break_with_changed_time_delay
    [Teardown]    Configuration Postcondition

[AZRB][1.0] Automated_SiSo_SM_RU_Primary_link_break
    [Setup]  Run Keywords
    ...  Configuration Precondition  CN=REF_10_16_UTESRANSISO129_DEFAULT  AND
    ...  Set Test Variable  ${TESTED_CABLINKS_OS_PORT}  ${azrb_tested_cablinks}
    TC_SiSo_SM_RU_Primary_link_break
    [Teardown]  Configuration Postcondition

[AHFII][1.0] Automated_SiSo_SM_RU_Primary_link_break
    [Setup]  Run Keywords
    ...  Configuration Precondition  CN=REF_10_16_UTESRANSISO129_DEFAULT  AND
    ...  Set Test Variable  ${TESTED_CABLINKS_OS_PORT}  ${ahfii_tested_cablinks}
    TC_SiSo_SM_RU_Primary_link_break
    [Teardown]  Configuration Postcondition

[AHFII][1.0] Automated_SiSo_SM_RU_Secondary_link_break
    [Setup]  Run Keywords
    ...  Configuration Precondition  CN=REF_10_16_UTESRANSISO129_DEFAULT  AND
    ...  Set Test Variable  ${TESTED_CABLINKS_OS_PORT}  ${ahfii_tested_cablinks}
    TC_SiSo_SM_RU_Secondary_link_break
    [Teardown]  Configuration Postcondition

[AHLOA][1.0] Automated_SiSo_SM_RU_Primary_link_break
    [Setup]  Run Keywords
    ...  Configuration Precondition  CN=REF_10_16_UTESRANSISO129_DEFAULT  AND
    ...  Set Test Variable  ${TESTED_CABLINKS_OS_PORT}  ${ahloa_tested_cablinks}
    TC_SiSo_SM_RU_Primary_link_break
    [Teardown]  Configuration Postcondition

[AHLOA][1.0] Automated_SiSo_SM_RU_Primary_link_break_without_recovery
    [Setup]  Run Keywords
    ...  Configuration Precondition  CN=REF_10_16_UTESRANSISO129_NORECOVERY  AND
    ...  Set Test Variable  ${TESTED_CABLINKS_OS_PORT}  ${ahloa_tested_cablinks}
    TC_SiSo_SM_RU_Primary_link_break_without_recovery
    [Teardown]  Configuration Postcondition

[AHEGHA][1.0] Automated_SiSo_SM_RU_Primary_link_break
    [Setup]  Run Keywords
    ...  Configuration Precondition  CN=REF_10_16_UTESRANSISO129_DEFAULT  AND
    ...  Set Test Variable  ${TESTED_CABLINKS_OS_PORT}  ${ahegha_tested_cablinks}
    TC_SiSo_SM_RU_Primary_link_break
    [Teardown]  Configuration Postcondition

[AHEGHA][1.0] Automated_SiSo_SM_RU_Secondary_link_break
    [Setup]  Run Keywords
    ...  Configuration Precondition  CN=REF_10_16_UTESRANSISO129_DEFAULT  AND
    ...  Set Test Variable  ${TESTED_CABLINKS_OS_PORT}  ${ahegha_tested_cablinks}
    TC_SiSo_SM_RU_Secondary_link_break
    [Teardown]    Configuration Postcondition


###CB013082
[AAFB][1.0] Automated_SiSo_REC_Hot_remove_insert_RU_primary_link_with_time_delay_change_fault_4685
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO129_13082
    ...  AND  Set Test Variable  &{TESTED_CABLINKS_OS_PORT}  &{TESTED_CABLINKS_AAFB}
    ...  AND  Set Test Variable  ${LONG_FIBER}  ${LONG_FIBER}
    ...  AND  Set Test Variable  ${IP_SWITCH}  ${IP_SWITCH}
    Primary Link Break 7447 Not Supported
    [Teardown]  Configuration Postcondition


[AAFB][1.0] Automated_SiSo_REC_Hot_remove_insert_RU_secondary_link_with_time_delay_change_fault_4685
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO129_13082
    ...  AND  Set Test Variable  &{TESTED_CABLINKS_OS_PORT}  &{TESTED_CABLINKS_AAFB}
    ...  AND  Set Test Variable  ${LONG_FIBER}  ${LONG_FIBER}
    ...  AND  Set Test Variable  ${IP_SWITCH}  ${IP_SWITCH}
    Secondary Link Break 7447 Not Supported
    [Teardown]  Configuration Postcondition


[AAIB][1.0] Automated_SiSo_REC_Hot_remove_insert_RU_primary_link_with_time_delay_change_fault_4685
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO129_13082
    ...  AND  Set Test Variable  &{TESTED_CABLINKS_OS_PORT}  &{TESTED_CABLINKS_AAIB}
    ...  AND  Set Test Variable  ${LONG_FIBER}  ${LONG_FIBER}
    ...  AND  Set Test Variable  ${IP_SWITCH}  ${IP_SWITCH}
    Primary Link Break 7447 Not Supported
    [Teardown]  Configuration Postcondition


[AAIB][1.0] Automated_SiSo_REC_Hot_remove_insert_RU_secondary_link_with_time_delay_change_fault_4685
    [Setup]  Run Keywords
    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO129_13082
    ...  AND  Set Test Variable  &{TESTED_CABLINKS_OS_PORT}  &{TESTED_CABLINKS_AAIB}
    ...  AND  Set Test Variable  ${LONG_FIBER}  ${LONG_FIBER}
    ...  AND  Set Test Variable  ${IP_SWITCH}  ${IP_SWITCH}
    Secondary Link Break 7447 Not Supported
    [Teardown]  Configuration Postcondition


###CB010780
[1][1.0] General_SiSo_Auto_RU_and_BTS_Software_activate_triggered_by_WebEM
  [Setup]  Run Keywords
  ...  Configuration Precondition  CN=REF_10_16_UTESRANSISO129_DEFAULT  N=1
  ...  AND  Set Test Variable  ${CUSTOM_EXPECTED_SITE_RESET_TIME}  350
  ...  AND  Set Test Variable  @{TESTING_RMOD_SN}  BL2351H69VK    BL2339N49U8
  ...  AND  Set Test Variable  ${OLD_BTS_SW_PACKAGE}  SBTS00_ENB_9999_241018_000005
  Execute Test In Loop  TC__SiSo_SWM_RU_and_BTS_SW_activate_triggered_by_WebEM
  [Teardown]  Configuration Postcondition