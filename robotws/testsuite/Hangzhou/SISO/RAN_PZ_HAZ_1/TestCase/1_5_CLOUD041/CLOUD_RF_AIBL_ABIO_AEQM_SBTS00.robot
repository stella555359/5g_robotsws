*** Settings ***
Documentation    Suite description
...    Author:        len.lin@nokia-sbell.com
...    Maintainer:    lin len

Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot
Variables   ./env.py


Force Tags    CLOUD_RF_AIBL_ABIO_AEQM_CA  CA_RAN_PZ_HAZ_1  SBTS00  RAN_5G  RAN_5G_TDD  CIT

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
&{CLOUD_RF_AIBL_ABIO_AEQM_SBTS00_T4_20M}=        HW_ID=T4_20M        ONAIR_TIME=20 min        site_mode=4G

&{CLOUD_RF_AIBL_ABIO_AEQM_SBTS00_T4_20_20_10_10}=        HW_ID=T4_20M        ONAIR_TIME=20 min
...    site_mode=4G

&{CLOUD_RF_AIBL_ABIO_AEQM_SBTS00_T4_20_20_20_10}=        HW_ID=T4_20M        ONAIR_TIME=20 min
...    site_mode=4G

&{CLOUD_RF_AIBL_ABIO_AEQM_SBTS00_T3_20_10_10}=        HW_ID=T3_20M        ONAIR_TIME=20 min        site_mode=4G
...    peak_rate_config={"301":[111.81,9.99],"302":[55.91,4.99],"303":[55.91,4.99]}

#${INIT_CONFIG_ID}
${GLO_SAS_FILE_PATH}=    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/SISO/RAN_PZ_HAZ_1/TestCase/1_5_CLOUD041/sas/
${EARFCN_CONFIG}    {'301': {'NSAS': {'Dl':'56641'}, 'OutRange': {'Dl':'56641'}}}

@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}    Unit power reset

&{ADDITIONAL_FLAGS}    2449=0x45000B=1



*** Test Cases ***

#Switch_RRU_AEQM
#    SAS For AEQM
#    sleep    5 min

[2][1.0] Operational_RF block & unblock(New Feature)
    [Timeout]    2h
    [Tags]      QC_33194    QCD_MN_RAN  QCP_RAN_VRF
    [Setup]    SAS For AEQM
    sleep    10 min
    Testcase Basic Precondition    case_name=RF_Block_And_Unblock
    ...    config_id=CLOUD_RF_AIBL_ABIO_AEQM_SBTS00_T4_20M
    Create Node Parameters From Current SCF
    Ru lock And Unlock All
    [Teardown]    Testcase Basic Postcondition
[2][1.0] Operational_Cell block & unblock
    [Timeout]    1h
    [Tags]      QC_33195    QCD_MN_RAN  QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Cell_Block_And_Unblock
    ...    config_id=CLOUD_RF_AIBL_ABIO_AEQM_SBTS00_T4_20M
    Create Node Parameters From Current SCF
    Cell Block And Unblock All
    [Teardown]    Testcase Basic Postcondition
[2][1.1] Operational_RF power off then on
    [Timeout]    1h
    [Tags]      QC_33197    QCD_MN_RAN  QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=RU_module_reset
    ...    config_id=CLOUD_RF_AIBL_ABIO_AEQM_SBTS00_T4_20_20_10_10
    Create Node Parameters From Current SCF
    SISO_RF module power reset
    [Teardown]    Testcase Basic Postcondition
[1][1.0] BS_FV_TX and RX antenna Calibration TA
    [Timeout]    2h
    [Tags]      QC_33196    QCD_MN_RAN  QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=calibration
    ...    config_id=CLOUD_RF_AIBL_ABIO_AEQM_SBTS00_T4_20_20_20_10
    Create Node Parameters From Current SCF
    SISO Antenna Calibration Check AEQP         1M211503036
    [Teardown]    Testcase Basic Postcondition
[1][1.0] BS_FV_Carrier Frequency and supported EARFCN
    [Timeout]    2h
    [Tags]      QC_33193    QCD_MN_RAN  QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Earfcn_check
    ...    config_id=CLOUD_RF_AIBL_ABIO_AEQM_SBTS00_T3_20_10_10
    Create Node Parameters From Current SCF
    Earfcn Update And Check    earfcn_config=${EARFCN_CONFIG}
    [Teardown]    Testcase Basic Postcondition
[2][1.0] CP_UP_Throughput Measurement_UDP_BW20M
    [Timeout]    1h
    [Tags]      QC_33198    QCD_MN_RAN  QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=L3call
    ...    config_id=CLOUD_RF_AIBL_ABIO_AEQM_SBTS00_T3_20_10_10
    Create Node Parameters From Current SCF
    test_fv.Data Transfer
    [Teardown]    Testcase Basic Postcondition
