


*** Settings ***
Documentation
...   Author: zhuo.1.gao@nokia-sbell.com
...   Contact: zhuo.1.gao@nokia-sbell.com
...   Description: This user scenario describes


Resource           ../Resources/vran_resource.robot
Suite Setup       Common Suite Setup For AIC
# Test Setup        Common Test Setup For AIC
Test Setup        Run Keywords    Common Test Setup For AIC    AND
...     AIC Case Setup    airphone_config_tag=SA_Cloud_DC
...    base_path=${CURDIR}/Airphone
Test Teardown     Common Test Teardown For AIC
Suite Teardown    Common Suite Teardown For AIC


Test Timeout    120 minutes

*** Variables ***
${PA_MaxValue}           ${60}
${PA_NormalValue}        ${30}
# ${DEBUG_MODE}        ${TRUE}
${test_repeat}    0
*** Test Cases ***
CB013233_CASE1_scf

   SCFUPload

# FOR    ${test_repeat}    IN    @{PA_signal_point}
#         Change PA settings    ${PA_info.PA_points_ini}    ${test_repeat}
#         Sleep    ${traffic_duration}
#     END

*** Keywords ***
SCFUPload
    ${out}    Parameter Operation    operation=full_commission   product_type=vdu
    ...    scf_path=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T03/25R2_CB013233CR_GZ/vdu_scf_gz.xml
    Log To Console    VDU full commission result: ${out}


# check_testline_cell_status
#    BTS Operation    operation=cell_block           product_type=vdu    bts_index=0    distname_id=NRCELL-1       need_verify=yes
#    BTS Operation    operation=cell_block           product_type=vdu    bts_index=0    distname_id=NRCELL-2       need_verify=yes
#    BTS Operation    operation=verify    product_type=vdu    distname_id=NRCELL-3    verify_status=CELL_ONAIR

# detach_QC8450
#    AT Operation    detach    ue_index=0

# attach_QC8450
#    AT Operation    attach    ue_index=0

# 8450_DLstart
#     AT Operation    start_traffic    ue_index=0  IperfOptions=-u -i 1 -t 300 -b 10M -p 50001  direction=dl
#     ...  remote_hostname=10.56.198.159    remote_username=ute    remote_password=UTE.debian12
# 8450_DLstop
#     AT Operation    stop_traffic  direction=dl
# Start_Collect_Wireshark_For_Cloud
#    Log Collection    start    wireshark_cp    product_type=vcu    bts_index=${0}    cudu_index=${0}
#    Log Collection    start    wireshark_cp    product_type=vdu    bts_index=${0}    cudu_index=${0}

# Stop_Collect_Wireshark_For_Cloud
#    ${local_file_pathcu}    Log Collection    stop_and_download    wireshark_cp    product_type=vcu    bts_index=${0}    cudu_index=${0}
#    ${local_file_pathdu}    Log Collection    stop_and_download    wireshark_cp    product_type=vdu    bts_index=${0}    cudu_index=${0}
#    Log To Console        \nWireshark log of VCU: ${local_file_pathcu}
#    Log To Console        \nWireshark log of VDU: ${local_file_pathdu}

# Snapshot for vdu
#     ${local_file_pathdu}    Log Collection    start    snapshot    product_type=vdu    bts_index=${0}    cudu_index=${0}
#     Log To Console    \nSnapshot of VDU: ${local_file_pathdu}

# Snapshot for vcu
#     ${local_file_pathcu}    Log Collection    start    snapshot    product_type=vcu    bts_index=${0}    cudu_index=${0}
#     Log To Console    \nSnapshot of VCU: ${local_file_pathcu}