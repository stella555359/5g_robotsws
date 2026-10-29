*** Settings ***
Documentation    Suite description
...    Author:    Nie Sue

Library    taf/rfrl/csv4all/CSV4AllTestCases.py
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/l3call.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/bts_common_interface.robot
Variables   ./env.py

Force Tags    CLOUD_5G_CLASSICAL_SA_ASIML_ABIPB1_4xAREA_3xAHEGC    CA_VRF_HAZ1

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
&{CB010746_B2}    HW_ID=ABIP   site_mode=5G    ONAIR_TIME=20 min
${LABEL}                      CLOUD_5G_CLASSICAL_SA_ASIML_ABIPB1_4xAREA_3xAHEGC
${HOSTNAME}                   1_5_UTE5G180
${SHOULD_BE_REPORTED}         ${False}
${REPORT_COMMENT}=            ${None}
${QC_DOMAIN}=                 MN_RAN
${QC_PROJECT}=                RAN_VRF
${DOWNLOAD_PATH}=     /home/ute
${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
${SHOULD_BE_REPORT}=          ${False}
${RP_CA}   VRF_SiSo
${RP_LOCATION}    VRF_HAZ1
${RP_ORGANIZATION}    VRF_HAZ1_T04
${EMAIL_RECIPIENTS}         None
${INITIAL_SW}               None
${TARGET_SW}                None
${ITERATIONS}               1
@{CUSTOM_ALLOWED}    4655  61524    4654    61652    1932    61649
&{NODE1}                    testline_object=${tl.gnbs[0]}
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALLOWED}
@{NODES}                    ${NODE1}
${customers_list}           Generic
@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}    NgGnbInitPartialReset    NgGnbInitFullReset    No module fan detected
*** Test Cases ***
Onair_Switch Configuration
    [Setup]    Testcase Basic Precondition    case_name=Onair    config_id=CB010746_B2
    Verify All Cells OnAir
    [Teardown]    Testcase Basic Postcondition

E2E_TL_Site_Reset_without_HWF_with_OAM_KPI

    [Timeout]   24h

    E2E TL SITE RESET WITHOUT HWF WITH OAM KPI    ${NODES}  ${NODE1}   ${ITERATIONS}    customers_list=${customers_list}
    ...    qc_domain=${QC_DOMAIN}    qc_id=58880    qc_project=${QC_PROJECT}


