*** Settings ***
Documentation
...  Test Suite Author: Karol Bielenny
...  Test Suite Owner: Karol Bielenny

Library           XML  use_lxml=True
Resource          ../../../../../resources/ca_4G_RRM_carrier_aggregation.robot
Resource          ../../../test_resources/4G_RRM/Automated__SiSo_PM_LTE_uDTX.robot


*** Variables ***
${SCF_ID}         01
${HW_LOCATION_CODE}      Wroclaw
${COMMISSIONING_PATH}  SEPARATOR=  /home/ute/MN/UTE/robotws/testsuite/Wroclaw/SISO/SRAN/REAL_HW/hran_ta/testsuite/SBTS/test_line_specific/Wroclaw/
...  SBTS_1371_UTESRANSISO114/commissioning/FULL1_114.xml
${TESTLINE_NAME}    10_16_UTESRANSISO114


*** Test Cases ***
[uDTX][1.0] Automated__SiSo_PM_LTE_uDTX
    [Setup]  Run Keywords  Set Test Variable  ${TEST_CELL_ID}   10,1,2,3,4,5,6,7,18,19
    ...  AND  Automated__SiSo_PM_LTE_uDTX.TC Setup
    ...  AND  Set Library Search Order  SiSo_PM_LTE_uDTX
    [Timeout]   14400
    TC__SiSo_PM_LTE_uDTX
    [Teardown]   Automated__SiSo_PM_LTE_uDTX.TC Teardown


