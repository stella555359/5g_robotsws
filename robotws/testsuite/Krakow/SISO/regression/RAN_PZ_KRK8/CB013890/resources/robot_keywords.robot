*** Settings ***
Documentation
...   Keywords for regression testing of CB013890
...   author: Przemyslaw Herian
...   contact: przemyslaw.herian@nokia.com

Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/procedures/SISO/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Library     testsuite/Krakow/resources/random_oam_procedure_runner.py
Library     testsuite.Krakow.SISO.resources.sassim.SASSim    WITH NAME   sas
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables       variables.py

*** Variables ***
${OPERATION_KWARGS}  {'bts_power_on': {'temp_allowed_alarms': [
...    {'alarm_id': '7116', 'fault_id': '6823', 'fault_name': 'SAS Grant Termination Revocation Failure'},
...    {'alarm_id': '7116', 'fault_id': '6825', 'fault_name': 'SAS Grant Suspension Failure'}]},
...    'site_reset': {'temp_allowed_alarms': [
...    {'alarm_id': '7116', 'fault_id': '6823', 'fault_name': 'SAS Grant Termination Revocation Failure'},
...    {'alarm_id': '7116', 'fault_id': '6825', 'fault_name': 'SAS Grant Suspension Failure'}]},
...    'power_reset_rmod': {'temp_allowed_alarms': [
...    {'alarm_id': '7116', 'fault_id': '6823', 'fault_name': 'SAS Grant Termination Revocation Failure'},
...    {'alarm_id': '7116', 'fault_id': '6825', 'fault_name': 'SAS Grant Suspension Failure'}],
...    'calculate_kpi': False}}

@{CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}  7107  7107  7220  61649  4655  4654  61524  7116  6823
@{ALLOWED_ALARMS_DURING_TL_PREPARATION}
...    SAS Grant Termination Revocation Failure
...    SAS Server Communication Failure
...    LMP access via port 443
...    Service account root access is enabled,
...    Ethernet port security is disabled
...    SSH enabled
${IS_ASIR_CONFIGURATION}=                       ${False}
${OPERATIONS} =
...    ['bts_power_on', 'cell_block_unblock', 'cell_lock_unlock',
...     'power_reset_rmod', 'rat_reset', 'reset_bbmod',
...     'reset_rmod', 'site_reset']
${TOTAL_TIMEOUT}                                ${18000}
${EMAIL_NOTIFICATION_WHEN_FAIL}                 ${False}
${RANDOM_SEED}                                  ${None}
${L3_CALL}                                      ${False}
${L3_CALL_KEYWORDS}                             ${None}

*** Keywords ***
Suite Setup
    Perform Full Commissioning On Classical gnb     update_timeout=1200
    Perform Full Commissioning on gNB ASIR hub
    Common Suite Setup
    sas.Prepare Sas Sim    port_number=4431    reset_iptables=${True}
    gnbcell.Wait For All Cells To Be Onair    timeout=600

Suite Teardown
    sas.Stop Sas Sim Server
    Common Suite Teardown
