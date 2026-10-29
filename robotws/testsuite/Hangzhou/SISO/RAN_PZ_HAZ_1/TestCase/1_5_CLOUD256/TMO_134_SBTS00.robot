*** Settings ***
Documentation    Suite description
...    Author:        xiaohong.h.chen@nokia-sbell.com
...    Maintainer:    chen xiaohong

#Resource    ../../resources/common_setup.robot
#Resource    ../../resources/test_fv.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot
Variables    ./env.py

Force Tags    CLOUD_5G_CLASSICAL_SA_ASILR_ABIOB4_ABINB3_3xAHFII_4xAEHGC    CA_RAN_PZ_HAZ_1    SBTS00    RAN_5G
...    RAN_5G_FDD    PY36

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
${pk_cb009390_T3T2}    "201":[60,17],"202":[60,17],"203":[60,17],"204":[60,17],"205":[60,17]


&{TMO_134}=
#peak_rate_config={${pk_cb009390_T3T2}}
...   HW_ID=AQQL
...   site_mode=NSA
...   ONAIR_TIME=10min
#...   peak_rate_config={"201":[60,17],"202":[60,17],"203":[60,17],"204":[60,17],"205":[60,17]}

${GLO_PERFORM_SAVE_LOG}    ALWAYS
${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
#${SW_CONFIG_PATH}     /home/ute/robotlte/config/Hangzhou/1_5_UTE4G153/swconfig.txt
@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}=    NG SCTP endpoint broken    NgGnbInitFullReset      NgGnbInitPartialReset
...   System information broadcast parameters overflow      Transport layer connection lost in XP interface
...   EN DSS Setup Failure - Max EN DSS Counter Value reached - No answer from CRM
...   FIFO buffer over/underflow      High memory consumption
...    ToP master service RU eCPRI port #4 unusable      ToP master service RU eCPRI port #3 unusable
...    ToP master service RU eCPRI port #2 unusable      ToP master service RU eCPRI port #1 unusable
...    Receiving failure in Optical Interface    No X2 link available for a specific LTEENB
...    Inter-Site CA X2 link unavailability    No X2 link available
...    User Account has Default Password    CNUM client settings lost in BTS
...    Automatic BTS Operator Certificate retrieval unsuccessful
...    Remote interference detecte
...    High interference to UL subframe
${online_commissioning}    [['MRBTS-10855/LNBTS-10855/LNCEL-101/LNCEL_TDD-0',['chBw','10 MHz']]]

${related_paras}  []
${CELL_DIST_NAME}  MRBTS-10855/EQM-1/HWTOP-1/CABLINK-6
${parameters}    [{'dist_name':'${CELL_DIST_NAME}','para_name':'Link speed','para_value':'Auto',
...   "require_reset":True,'related_paras':${related_paras}}]


${INIT_CONFIG_ID}=    TMO_134

#${appserver_log_path}    /home/tdlte-tester/UDP
*** Test Cases ***
#Test
#    spark.Require Ue    ue_alias=UE_0    index=0    reset_sol=${None}    reset_app=${False}
##

[1][1.0] Onair_CONF
    [Tags]    QC_3574    QCD_MN_RAN    QCP_RAN_ST
    [Setup]    Testcase Basic Precondition    case_name=Onair2    config_id=TMO_134
    FOR     ${num}      IN RANGE    ${1}
    LOG TO CONSOLE   ${num}
    Site Reset
#    sleep   10min
    END
    [Teardown]    Testcase Basic Postcondition

[1][1.0] General_SiSo_BB_sub-unit_reset
    [Setup]    Testcase Basic Precondition    case_name=BBMOD_Reset
 #   Site Reset
    FOR     ${num}      IN RANGE    ${1}
    LOG TO CONSOLE   ${num}
    Set Test Variable  ${IS_SUPPORTED_CALL}    False
    BBMOD Reset    bbmod_id_list=L1233704799
    END
    [Teardown]    Testcase Basic Postcondition


[1][1.0] General_SiSo_BB_sub-unit_reset2
    [Setup]    Testcase Basic Precondition    case_name=BBMOD_Reset
 #   Site Reset
    FOR     ${num}      IN RANGE    ${1}
    LOG TO CONSOLE   ${num}
    Set Test Variable  ${IS_SUPPORTED_CALL}    False
    BBMOD Reset    bbmod_id_list=L1233704799
    END
    [Teardown]    Testcase Basic Postcondition





