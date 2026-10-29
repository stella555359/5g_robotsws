*** Settings ***
Documentation
...    author: Marcin Szlapa
...    contact: marcin.szlapa@nokia.com
...    Description: Test Cases CB009800-5G KPI triggered alarm and log collection in gNB

Library       testsuite.Krakow.OAM.regression.RAN_PZ_KRK4.CB007257.resources.keywords.SeleniumKeywords
Library       testsuite.Krakow.resources.alarm.Alarm
Library       ./resources/keywords.py
Resource      taf/rfrl/ue/robot/REAL_UE.robot
Resource      taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource      taf/rfrl/bts/robot/logs_collecting.robot
Variables     taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables     ./delta/delta.py


Test Timeout  24 hours

Suite Setup         Suite Setup
Suite Teardown      Common Suite Teardown
Test Setup          Common Preconditions
Test Teardown       Common Postconditions

*** Variables ***
${global_bts_id} =  ${tl.gnbs[0].global_bts_id}

*** Test Cases ***
CB007257-5G_11_EDA_for_03210145
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...  param_name=actNrAutSgnbAddCplSlCellDetRec
    ...  param_value=true
    ...  skip_parameter_relation_errors=${true}
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1
    ...  param_name=nrSgnbAddCplSlCellRecPhAct
    ...  param_value=Phase 1
    ...  skip_parameter_relation_errors=${true}
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1
    ...  param_name=nrSgnbAddCplSlCellDetHChFrq
    ...  param_value=840
    ...  skip_parameter_relation_errors=${true}
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1
    ...  param_name=nrSgnbAddCplSlCellRecPh1Tmr
    ...  param_value=900
    ...  skip_parameter_relation_errors=${true}
    Perform Delta Commissioning On gNB    ${tc_11_EDA_delta}
    ue.Require UE  UE  capabilities=REAL_ANDROID_UE
    ue.reboot ue  UE
    ue.Attach UE    UE
    Wait Until Alarm Is Active On Gnb
    ...  fault_name=The following KPI formula X2_SGNB_ADD_REQ_ACK_SENT >= 1 has been evaluated to true: description
    ...  timeout=900
    ue.Detach UE    UE
    ue.Attach UE    UE
    Wait Until Alarm Is Not Active On Gnb
    ...  fault_name=The following KPI formula X2_SGNB_ADD_REQ_ACK_SENT >= 1 has been evaluated to true: description
    ...  timeout=120
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...  param_name=actKpiAlarms
    ...  param_value=false
    Run Keyword And Expect Error
    ...  ExecutionException*Alarm*is not active*
    ...  Wait Until Alarm Is Active On Gnb
    ...  fault_name=SleepingCellDetectionDueToLowSgNbAdditionCompletionRateAl
    ...  timeout=900

*** Keywords ***
Suite Setup
	gnbbbu.upload_swconfig    sw_config_path=commissionings/${CONFIGURATION.replace('.', '/')}/swconfig.txt
	Common Suite Setup With Commissioning
