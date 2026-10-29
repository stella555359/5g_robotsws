***Settings***
Documentation
...            [Author]         "Asha P"
...            [Maintenance]    "TRS I & V Tools Bangalore Team"

Force Tags        CLOUD_F   CA_E2ET_BTSTRSPZ        SBTS00        SBTS23R2     RAN_4G    RAN_4G_FDD       QCD_MN_RAN        QCP_RAN_VRF        CRT


variables               ta_e2e_bts_trs_fw
Resource                ${CURDIR}/../resources/Admin_Common_Library.robot
Resource		        ${CURDIR}/../resources/common_keywords.robot

Suite Setup        Run Keywords    Suite Setup Preconditions
...        AND     Setup Oamops
Suite Teardown     Run Keywords        Suite Teardown Postconditions
...        AND     Teardown Oamops


***Variables***
${default_alarm}        User Account has Default Password


*** Test Cases ***
[1][1.0] [5.0]LTE3455_Enable_disable_Default Password Alarm feature.
#Step 0:
    Perform Recommissioning     type=param  param_path=MRBTS-3737/MNL-1/AMGR-1:enableDefaultPasswdAlarm    operation=update    value=true timeout=300

#Step 1:
     Verify Alarm        faultid=4459     rat=lte     should_exist=True   occurrences=1     check_unexpected_alarms=${false}
     sleep      60
     Reset Bts         req_rat=lte     should_be_onair=${False}      wait_for=300
     sleep      60
     Verify Alarm        faultid=4459     rat=lte     should_exist=True   occurrences=1     check_unexpected_alarms=${false}

#Step 2:
     Perform Recommissioning     type=param  param_path=MRBTS-3737/MNL-1/AMGR-1:enableDefaultPasswdAlarm    operation=update    value=${false}
     ...     timeout=300
     Verify Alarm        faultid=4459     rat=lte     should_exist=${false}  occurrences=1     check_unexpected_alarms=${false}

***Keywords***
Verify alarm should exist
    Download Alarm File from eNB
    List Should Contain Value    ${SEM_alarms}    ${default_alarm}

Verify alarm should not exist
    Download Alarm File from eNB
    List Should Not Contain Value    ${SEM_alarms}    ${default_alarm}