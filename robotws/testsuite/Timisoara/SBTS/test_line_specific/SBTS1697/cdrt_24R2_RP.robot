*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  CLOUD_SRAN_LWG_1ASIA_3ABIA_1ASIA_3ABIA_3FRIJ_1FRPA_2FXCB_2FXFC  STATE_COMMISSIONED
...    SBTS00
Library           XML  use_lxml=True


Resource    ../../FM/test_resources/FM__GSM_DSP_crash_RAT_recovery_reset.robot
Resource    ../../FM/test_resources/FM__RAT_reset_counter_exceeded__multi_RAT.robot
Resource    ../../FM/test_resources/FM__LTE_DSP_reset_actForceUnitAutoReset_false_faulty_cells_6709.robot
Resource    ../../FM/test_resources/FM__SC_late_startup_actForceAutoReset_false.robot
Resource    ../../FM/test_resources/FM__BBPOOL_reset_allowBbPoolRecoveryReset_true_faulty_cell.robot
Resource    ../../FM/test_resources/FM__Primary_core_power_off_on.robot


*** Variables ***
${SCF_ID}    01
${Switch_IP}          10.255.10.109
${Switch_type}        Nokia_Nuage
${INTERFACE_TYPE}     GigabitEthernet
${INTERFACE_ID}       1
${Switch_USER}        AutoUser
${Switch_PASSWORD}    AutoPass123$
${HW_LOCATION_CODE}      Timisoara
${ENB_BUILD}    SBTS00_ENB_9999_211207_000006
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1767
${SKIP_RU_POWER_CHECK}    ${TRUE}


*** Test Cases ***
[1]Automated__FM__GSM_DSP_crash_RAT_recovery_reset
    [Tags]  QC_784849
    Setup Scout  10_18_UTESRANCLOUD1767
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API



[1]Automated__FM__RAT_reset_counter_exceeded__multi_RAT
    [Tags]  QC_784850
    Setup Scout  10_18_UTESRANCLOUD1767
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API



[1]FM__LTE_DSP_reset_actForceUnitAutoReset_false_faulty_cells_6709
    [Tags]  QC_784848
    Setup Scout  10_18_UTESRANCLOUD1767
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API



[1]FM__BBPOOL_reset_allowBbPoolRecoveryReset_true_faulty_cell
    [Tags]  QC_784851
    Setup Scout  10_18_UTESRANCLOUD1767
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API




[1]FM__SC_late_startup_actForceAutoReset_false
    [Tags]  QC_784847
    Setup Scout  10_18_UTESRANCLOUD1767
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API



[1]FM__Primary_Core_power_off_on
    [Tags]  QC_784846
    Setup Scout  10_18_UTESRANCLOUD1767
    Request SCF  use_scout_internal_id=True
    Log Variables
    Teardown Scout API

    
