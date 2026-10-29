*** Settings ***
Documentation    Suite description
...     Author:     xxx.yyy@nokia-sbell.com
...     Maintainer:   Author

Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot
Variables   ./env.py

Force Tags      CA_RAN_PZ_HAZ_1    SBTS00

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition


*** Variables ***
#&{SCFC_SBTS00}         HW_ID=AZNA     site_mode=4G5G    ONAIR_TIME=18 min
&{SCFC_SBTS00_New}         HW_ID=AZNA     site_mode=4G5G    ONAIR_TIME=18 min
${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
#${INIT_CONFIG_ID}                SCFC_SBTS00
${INIT_CONFIG_ID}                SCFC_SBTS00_New
@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}=  Unit power reset
...                         NgGnbInitFullReset
...                         System information broadcast parameters overflow
#...                         No module fan detected
...                         NgGnbInitPartialReset
...                         Xn SCTP setup fail
#...                         Cooling fan broken

*** Test Cases ***
[0]Site Reset
    [Tags]    QCD_MN_SRN    QCP_TDD_ST
    [Setup]    Testcase Basic Precondition    case_name=BTS_site_reset
    Site Reset
    [Teardown]    Testcase Basic Postcondition
