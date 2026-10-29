*** Settings ***
Resource    Resources/CB012971_common_keyword.robot
Variables    Resources/CB014465_variable.py

Documentation
...   author: Chen Tong
...   contact: tong.chen@nokia-sbell.com
...   squad group: SG_02

Suite Setup    SG2_Common_setup_teardown.Common Suite setup    if_commissioning=${False}

*** Variables ***
${tl_scf_dir_path}     ${CURDIR}/../../../../../commissionings/HGZ/

${DL_THROUGHPUT}    1000M
${UL_THROUGHPUT}    300M
${DL_THROUGHPUT_503}    1005
${DL_THROUGHPUT_601}    2890

*** Test Cases ***
[1]CB012971-E_4_DL pairing using SVD-RZF with up to 4 moving UEs_with_HARQ_ReTx
    [Setup]    SG2_Common_setup_teardown.Common Case setup    scf_path=${tl_scf_dir_path}/${testline_name}/${ENB_BRANCH}_CB012971.xml
    ...                                                       need_Btslog=${True}
    CB012971 Prepare Multi UEs
    CB012971 Start Multi UEs attach
    Sleep    30s
    ${cpif_log}    ${tti_log}    ${bip_log}    CB012971 Start Multi UEs Traffic And Get CP-IF BIP TTI log
    UE Check traffic after all UEs traffic start    dl_target=${DL_THROUGHPUT_503}
    UE Check traffic after all UEs traffic start    cellid=2    start_ue_index=4    dl_target=${DL_THROUGHPUT_601}
    Check Bip log for CB012971    bip_log=${bip_log}
    [Teardown]    Run keyword and ignore error    SG2_Common_setup_teardown.Common Case teardown    need_Btslog=${True}