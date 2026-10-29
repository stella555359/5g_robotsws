*** Settings ***
#Force Tags
Documentation    Suite description
...    Author:        wei.ren@nokia-sbell.com
...    Maintainer:    weren

Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot
Variables   ./env.py

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
${peak1}    "660":[120,20],"661":[120,20],"662":[120,20],"663":[120,20],"675":[120,20],"665":[120,20]
${peak2}    "666":[120,20],"667":[120,20],"668":[120,20],"669":[120,20],"670":[120,20],"671":[120,20]
${peak3}    "676":[120,20],"690":[120,20],"610":[120,20]
${peak4}    "170":[140,20],"171":[140,20],"172":[140,20],"173":[140,20],"174":[140,20],"175":[140,20]
${peak5}    "186":[70,20],"187":[70,20],"188":[70,20],"179":[140,20],"180":[140,20],"181":[140,20]
${peak6}    "182":[70,20],"183":[70,20],"184":[70,20],"185":[70,20]
&{CB010746_B2}    HW_ID=ABIP   site_mode=5G    ONAIR_TIME=20 min
...	  peak_rate_config={${peak1},${peak2},${peak3},${peak4},${peak5},${peak6}}

${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
${INIT_CONFIG_ID}     CB010746_B2
@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}    NgGnbInitPartialReset    NgGnbInitFullReset    Transmission path failure
...    No module fan detected

${online_commissioning}    [['MRBTS-37039/LNBTS-37039/LNCEL-1/LNCEL_FDD-0',['dlChBw','10 MHz']],
...                         ['MRBTS-37039/LNBTS-37039/LNCEL-1/LNCEL_FDD-0',['ulChBw','10 MHz']],
...                         ['MRBTS-37039/LNBTS-37039/LNCEL-1',['actDownSampling','false']]]

${prach_parameters}    [['MRBTS-37039/NRBTS-37039',['actAutoPrachConfigIndexFdd','true']],
...                     ['MRBTS-37039/NRBTS-37039',['actAutoPrachConfigIndexFddEnh','true']],
...                     ['MRBTS-37039/NRBTS-37039/NRDU-1',['crntiAllocationOption','max72cellsEnh']]]
${GLO_PERFORM_SAVE_LOG}    FAIL

*** Test Cases ***
test
    [Tags]    QC_98107     QCD_MN_RAN      QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=test    config_id=CB010746_B2
    FOR    ${num}    IN RANGE    ${2}
        log to console    \n************************${num}**********************\n
        Common_SiSo_Recovery_RF module reset_Then_BBMOD_reset
        #RF lock And Unlock with BTS Reset
        Common_SiSo_State Management_RF Lock_Then_resetBBMOD_Then_RF unlock
        #Stability Site Reset
        Common_SiSo_Recovery_RF_module_reset_Then_RAT_reset
    END
    [Teardown]    Testcase Basic Postcondition


