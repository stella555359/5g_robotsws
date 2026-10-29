*** Settings ***
Documentation    Suite description
...    Author:    Nie Sue


Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/l3call.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/bts_common_interface.robot
Variables   ./env.py
Library     taf/rfrl/csv4all/CSV4AllTestCases.py


Force Tags    CLOUD_5G_CLASSICAL_SA_ASIM_ABIP_5xAHEGC_3xAHEGB    CA_VRF_HAZ1

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
&{CB010551_ASIM_ABIQ_5AHEGC_3AHEGB_24cell_20M}    HW_ID=AHEGC   site_mode=5G    ONAIR_TIME=15 min
${LABEL}                      CLOUD_5G_CLASSICAL_SA_ASIM_ABIP_5xAHEGC_3xAHEGB
${HOSTNAME}                   1_5_UTE5G181
${DISABLE_SYSLOG_CHECK}       ${False}
@{USER_SUSPICIOUS_PRINTS}     @{EMPTY}
${REMOTE_VM_IP}               ${None}
${REMOTE_MPLANE}              ${None}
${USE_REMOTE_NODE}            ${False}
@{CUSTOM_ALARMS}              @{EMPTY}
@{CRITICAL_FAULTS}            @{EMPTY}
${SHOULD_BE_REPORTED}         ${False}
${REPORT_COMMENT}=            ${None}
${QC_DOMAIN}=                 MN_RAN
${QC_PROJECT}=                RAN_VRF
${RP_CA}   VRF_SiSo
${RP_LOCATION}    VRF_HAZ1
${RP_ORGANIZATION}    VRF_HAZ1_T04
${EMAIL_RECIPIENTS}         None
${INITIAL_SW}               None
${TARGET_SW}                SBTS25R1_ENB_0000_000800_000000
${ITERATIONS}               1
@{CUSTOM_ALLOWED}    4655  61524    4654    61652    1932    61649
&{NODE1}                    testline_object=${tl.gnbs[0]}
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALLOWED}
@{NODES}                    ${NODE1}
${customers_list}           Generic

#upgrade
${5G_SOURCE_SW}=                SBTS00_ENB_9999_240409_000004
${5G_TARGET_SW}=                SBTS00_ENB_9999_240410_000005
${5G_TARGET_SW_PATH}=           ${None}
${4G_SOURCE_SW}=                SBTS00_ENB_9999_240409_000004
${4G_TARGET_SW}=                SBTS00_ENB_9999_240410_000005
${4G_TARGET_SW_PATH}=           ${None}
${USE_BUILDS_STORAGE}=          ${False}
${RESTORE_TARGET_SW}=           ${True}
${PERFORM_UBOOT_DOWNGRADE}=     ${True}
${REMOTE_NODE_UPDATE}=      @{EMPTY}
${DOWNLOAD_PATH}=     /home/ute
# Delta Commissioning Parameters
${TEST_ITERATION}=              1
${SHOULD_BE_REPORT}=          ${True}
${TEST_QC_ID}=                  ${None}  # SHOULD BE DIFFERENT FOR EACH TEST CASE ACCORDING TO QC_ID OF EACH TEST
${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}    NgGnbInitFullReset    NgGnbInitPartialReset    Cooling fan broken
*** Test Cases ***
Onair_Switch Configuration
    [Setup]    Testcase Basic Precondition    case_name=Onair    config_id=CB010551_ASIM_ABIQ_5AHEGC_3AHEGB_24cell_20M
    Verify All Cells OnAir
    [Teardown]    Testcase Basic Postcondition

#E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
#    [Timeout]   24h
#    [Tags]    QC_83315    QCD_MN_RAN   QCP_RAN_VRF
#    UUF4ALL_SITE_RESET_TEST
E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
    [Timeout]   24h
    E2E TL SITE RESET WITHOUT HWF WITH OAM KPI    ${NODES}  ${NODE1}   ${ITERATIONS}    customers_list=${customers_list}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=83315
    ...          qc_project=${QC_PROJECT}

