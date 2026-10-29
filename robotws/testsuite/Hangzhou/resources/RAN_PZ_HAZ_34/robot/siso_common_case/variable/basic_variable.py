"""
Usage example:
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown
Test Timeout         100 min

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_power_reset.robot

"""
SISO_COMMON_BASIC_PATH = 'testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/'
BASIC_PATH_5G = SISO_COMMON_BASIC_PATH + '5G'
BASIC_PATH_LTE = SISO_COMMON_BASIC_PATH + 'LTE'
BASIC_PATH_COMMON = SISO_COMMON_BASIC_PATH + 'Common'
BASIC_PATH_CLOUD = SISO_COMMON_BASIC_PATH + 'Cloud'

# HangZhou artifactory
arti = "https://artifactory-espoo1.int.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release/"
arti_hz = "https://artifactory-hz1.ext.net.nokia.com/artifactory/mnp5g-central-public-remote/System_Release/"
arti_hz_sbts = "https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local/"
arti_hz_bsr = "https://10.57.169.252/build/bsr/"
arti_hz_ald = "https://10.57.169.252/build/ald/"
