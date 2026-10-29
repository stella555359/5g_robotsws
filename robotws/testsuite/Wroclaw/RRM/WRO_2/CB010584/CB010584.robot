*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Documentation    :copyright: Nokia
...              :authors: Lukasz Klimowicz
...              :contact: lukasz.klimowicz@nokia.com


Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Resource     ../keywords/messaging.robot
Resource     feature_keywords.robot
Library      ta_messaging
Library      taf.ul.ettf.setups
Library      ta5g_testline_management
Library      ta5g_pm_counters
Variables    logging_policy.py
Variables    CB010584_messaging_filters.py

Suite Setup     Configure simulated interfaces


*** Variables ***
${LOGS_COMPRESSION}=    ${True}
${LOGGING_POLICY}=    FULL_POLICY_WO_SOS_REPORT
${BASIC_SETUP_NO_NEW_IE}=        ${CURDIR}/config/egate_config_2_sim_enb_include_nokia_endc_challenge_OFF.cfg
${BASIC_SETUP_WITH_NEW_IE}=        ${CURDIR}/config/egate_config_2_sim_enb_include_nokia_endc_challenge_ON.cfg
${REBOOT}=    ${True}

*** Test Cases ***

[1]CB010584_01__ENDC_X2_SETUP_REQUEST_received_by_gNB_without_NokiaENDCChallengeIE
    [Setup]    Run Keywords    Log To Console	Simulator configuration started
    ...        AND    With Simulator Configuration    config=${BASIC_SETUP_NO_NEW_IE}
    ...        AND    Create gNB Alias
    ...        AND    Create ENB device with alias 'ENB3' identified by ip=10.0.1.122
    ...        AND    Wait For Next Full Pm Interval


    Expect ENDC X2 Setup flow    flow_id=0    gNB_id=2
    Trigger ENDC Connection
    Check ENDC X2 Setup flow occured    flow_id=0
    Verify ENDC X2 Setup contents when NokiaENDCChallenge not included    flow_id=0
    Verify ENDC X2 Setup Response Sent counter    expected_value=1

    [Teardown]    Add Scout Data Info To Testcase

CB010584_02__ENDC_X2_SETUP_REQUEST_received_by_gNB_with_NokiaENDCChallenge_IE_with_payload_size_exactly_32_bytes
    [Setup]    Run Keywords    Reboot Testline    reboot=${REBOOT}
    ...        AND    Log To Console	Simulator configuration started
    ...        AND    With Simulator Configuration    config=${BASIC_SETUP_WITH_NEW_IE}
    ...        AND    Create gNB Alias
    ...        AND    Create ENB device with alias 'ENB3' identified by ip=10.0.1.122
    ...        AND    Wait For Next Full Pm Interval

    FOR    ${index}    IN RANGE    10
        Expect ENDC X2 Setup flow    flow_id=${index}    gNB_id=2
        Trigger ENDC Connection    flow_id=${index}
        Check ENDC X2 Setup flow occured    flow_id=${index}
        Verify ENDC X2 Setup contents when NokiaENDCChallenge included    flow_id=${index}
        Verify NokiaENDCChallengeResponse content matching expected contentB    flow_id=${index}

        Expect X2 Reset flow    flow_id=${index}    gNB_id=2
        Trigger X2 Reset    flow_id=${index}
        Check X2 Reset flow occured    flow_id=${index}
    END

    Verify ENDC X2 Setup Response Sent counter    expected_value=10
