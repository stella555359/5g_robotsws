*** Settings ***
Documentation
...   author: GAO ZHUO
...   contact: zhuo.1.gao@nokia-sbell.com
...   this is a robot case about CB012299_D

Resource          ../Resources/common_resource.robot
Force Tags        CRT    RAN_5G    STATE_SKIP_AGENT
...               SBTS00   CA_RAN_PZ_HAZ_1    RAN_PZ_HAZ1_SG07_ST_RRM    TA_LEVEL_22
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown      Common MutliBTS Suite Teardown For RRM
Test Setup    Run keywords    Common MultiBTS Test Setup For RRM    AND    Case Setup
Test Teardown     Run keywords    Case Teardown    AND    Common MultiBTS Test Teardown For RRM

*** Variables ***
${DEBUG_MODE}            ${TRUE}
# @{mo_list}               MRBTS-6090/NRBTS-10738/NRCELL-31    MRBTS-6090/NRBTS-10738/NRCELL-31    MRBTS-6090/NRBTS-10738/NRCELL-31
# ...                      MRBTS-6090/NRBTS-10738/NRCELL-31    MRBTS-6090/NRBTS-10738/NRCELL-31
# ${TTI_cell}              NRCELL_R-31
# &{fault_4655}            faultId=${4655}
# &{fault_4654}            faultId=${4654}
# &{fault_61524}           faultId=${61524}
# &{fault_61652}           faultId=${61652}
# &{fault_2002}            faultId=${2002}
# &{fault_7300}            faultId=${7300}
# &{fault_61649}           faultId=${61649}
# &{fault_4592}            faultId=${4592}
# @{Ohter_Allow_Alarms}    &{fault_4655}    &{fault_4654}    &{fault_2002}    &{fault_61524}    &{fault_61652}
# &{dcap_info}    host=10.56.218.4    port=443    username=utfuser    password=utfadmin!
# ${tti_path}      /home/ute/test_results/

*** Test Cases ***

CB014730-SR-A_01_support of CB014730 RND flag and sync of this RND information to relative components
    [Documentation]
    ...    n3(AHEGB) is PCELL,N40(AKNB) is scell
    # [Setup]    Case Precondition
    # sleep      60s
    block_other_gnb_cells_1078_4001
    sleep      3s
    unblock_all_6210_cells

*** Keywords ***

detach_QC8450
   AT Operation    detach    ue_index=0

attach_QC8450
   AT Operation    attach    ue_index=0

8450_DLstart
    AT Operation    start_traffic    ue_index=0    ueip=172.252.50.184    IperfOptions=-u -t 3600 -l 1400B -i 1 -b 200M -p 5504    direction=dl
    ...  remote_hostname=10.56.198.159    remote_username=ute    remote_password=UTE.debian12
8450_DLstop
    AT Operation    stop_traffic  direction=dl
set_testline_cell-33_status_onair
    BTS Operation    operation=verify    product_type=gnb    bts_index=0    verify_status=CELL_ONAIR    distname_id=NRCELL-33

Case Setup
    Log To Console    Case Setup

Case Teardown
    Log To Console    Case Teardown
    # Run Keyword And Ignore Error    AT.UE Detach
    Run Keyword And Ignore Error    Disconnect All VM

Change AKNB to nominalBandwidth
    @{para_list}      Create List    semiDynamicBwSize
    @{mo_list}        Create List    MRBTS-6210/NRBTS-6210/NRCELL-1001
    @{value_list}     Create List    nominalBandwidth
    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                      para_list=@{para_list}        value_list=@{value_list}    mo_list=@{mo_list}
    Log To Console    paramter update result: ${out}

Change AKNB to limitedBandwidth
    @{para_list}      Create List    semiDynamicBwSize
    @{mo_list}        Create List    MRBTS-6210/NRBTS-6210/NRCELL-1001
    @{value_list}     Create List    limitedBandwidth
    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                      para_list=@{para_list}        value_list=@{value_list}    mo_list=@{mo_list}
    Log To Console    paramter update result: ${out}

Start TTI trace for specific cell
    [Tags]    tti
    Log To Console    start to capture tti with DCAP
    ${dcap_argument}   Create Dictionary   nrCells=${TTI_cell}
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}    argument=${dcap_argument}
    Log Collection    start    tti    product_type=gnb    bts_index=${0}    dict_argument=${dict_argument}

Stop TTI trace for specific cell
    Log To Console    stopping tti with DCAP
    ${local_file_path}    Log Collection    stop_and_download    tti    product_type=gnb    bts_index=${0}
    Set Test Variable    ${tti_path}     ${local_file_path}
    Log To Console    \nTTI log: ${local_file_path}

Change CB009849_C_actDlForceRankDowng_to_dlVoNRCtrlOnly
    &{staged_dict}    create dictionary   maxMcsForDlSrb=${19}  maxMcsForDlVoNRCtrl=${19}
    @{staged_param_list}     Create List   ${staged_dict}
    @{value_list}     Create List   ${staged_param_list}    dlVoNRCtrlOnly
    @{para_list}      Create List   dlForceRankDowngCtl    actDlForceRankDowng
    @{mo_list}        Create List   MRBTS-37421/NRBTS-37421/NRCELL-21    MRBTS-37421/NRBTS-37421/NRCELL-21
    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                      para_list=${para_list}        value_list=${value_list}    mo_list=${mo_list}
    Log To Console    paramter update result: ${out}


Analyze TTI log
    [Tags]    tti
    Log To Console    \nStart Log Analysis for ${tti_path}
    ${result}=    Log Analysis    check    tti    ${tti_path}    ${tti_analysis_dict}
    Log To Console    \nAnalyze TTI log: ${result}
    ${status}    check_rules     ${tti_path}    ${mcs_setting[0]}    ${mcs_setting[1]}    ${mcs_setting[2]}
    Log To Console    \nCheck rule log: ${status}
    should be true    ${status}

block_other_gnb_cells_1078_4001
    BTS Operation    operation=cell_block           product_type=gnb    bts_index=0    distname_id=NRCELL-1078     need_verify=True

block_other_enb_cells_88_3
    BTS Operation    operation=cell_block           product_type=enb    bts_index=0    distname_id=LNCELL-88     need_verify=True
    BTS Operation    operation=cell_block           product_type=enb    bts_index=0    distname_id=LNCELL-3     need_verify=True

unblock_all_6210_cells
    BTS Operation    operation=cell_unblock           product_type=gnb    bts_index=0    distname_id=NRCELL-1078     need_verify=True
