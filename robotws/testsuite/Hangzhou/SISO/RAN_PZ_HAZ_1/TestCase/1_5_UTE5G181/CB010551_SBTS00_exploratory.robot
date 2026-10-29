*** Settings ***
#Force Tags
Documentation    Suite description
...    Author:        bibo.lei@nokia-sbell.com
...    Maintainer:    blei

Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/affa.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_model.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/variables.robot
Variables   ./env.py

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
${5AHEGC_3AHEGB_18cell_20M_40M}=    {"530":[190,30],"531":[380,30],"532":[190,30],"533":[380,30],"534":[190,30],
...    "535":[380,30],"536":[190,30],"537":[190,30],"538":[190,30],"539":[190,30],"540":[380,30],"541":[190,30],
...    "542":[380,30],"543":[190,30],"544":[380,30],"545":[190,30],"546":[190,30],"547":[190,30]}
&{CB010551_ASIM_ABIQ_5AHEGC_3AHEGB_18cell_20M_40M}    HW_ID=AHEGC   site_mode=5G    ONAIR_TIME=15 min
...	  peak_rate_config=${5AHEGC_3AHEGB_18cell_20M_40M}
${5AHEGC_3AHEGB_24cell_20M}=    {"530":[190,30],"531":[380,30],"532":[190,30],"533":[380,30],"534":[190,30],
...    "535":[380,30],"536":[190,30],"537":[190,30],"538":[190,30],"539":[190,30],"540":[380,30],"541":[190,30],
...    "542":[380,30],"543":[190,30],"544":[380,30],"545":[190,30],"546":[190,30],"547":[190,30],"548":[190,30],
...    "549":[190,30],"550":[190,30],"551":[190,30],"552":[190,30],"553":[190,30]}
&{CB010551_ASIM_ABIQ_5AHEGC_3AHEGB_24cell_20M}    HW_ID=AHEGC   site_mode=5G    ONAIR_TIME=15 min
...	  peak_rate_config=${5AHEGC_3AHEGB_24cell_20M}
${5AHEGC_3AHEGB_test_model}=    {"530":[190,30],"532":[190,30],"534":[190,30],
...    "536":[190,30],"539":[190,30],"541":[190,30],
...    "543":[190,30],"545":[190,30]}
&{CB010551_ASIM_ABIQ_5AHEGC_3AHEGB_test_model}    HW_ID=AHEGC   site_mode=5G    ONAIR_TIME=15 min
...	  peak_rate_config=${5AHEGC_3AHEGB_test_model}
${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
#${ru_password_user}=    KRG3dFggxxHw+s0z64U0AR22VyjfnXdHrAVdSv5jpc4=
${GLO_PERFORM_SAVE_LOG}    FAIL
@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}    NgGnbInitFullReset    NgGnbInitPartialReset    Cooling fan broken

*** Test Cases ***
test
    [Tags]    QC_50048     QCD_MN_RAN      QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=test    config_id=CB010551_ASIM_ABIQ_5AHEGC_3AHEGB_24cell_20M
    FOR    ${num}    IN RANGE    ${10}
        log to console    \n************************${num}**********************\n
        Common_SiSo_Recovery_RF module reset_Then_BBMOD_reset        required_cells=536
        #RF lock And Unlock with BTS Reset
        Common_SiSo_State Management_RF Lock_Then_resetBBMOD_Then_RF unlock        required_cells=536
        #Stability Site Reset
        Common_SiSo_Recovery_RF_module_reset_Then_RAT_reset        required_cells=536
    END
    [Teardown]    Testcase Basic Postcondition
