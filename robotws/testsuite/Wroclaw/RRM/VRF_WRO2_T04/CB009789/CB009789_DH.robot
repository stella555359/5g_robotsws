*** Settings ***
Force Tags    CLOUD_5GC_dRNIC_2vDU_O_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD    CONFIGURED    RAN_5G    PY310    CRT    RF50
...           NoResUsage


Documentation    :copyright: Nokia
...              :authors: Piotr Pondel
...              :contact: piotr.pondel@nokia.com

Resource    ../../resources/airphone/5G_SW_WRO_Keywords.robot
Resource    ./resources/CB009789_Keywords.robot
Resource    ./resources/CB009789_variables.robot
Library    ./resources/CB009789.py
Library    ta5g_ue_measurements
Library    ta5g_iphy
Library    ta5g_enb
Library    ta5g_testline_management
Library    ta5g_cell_operations
Library    ta5g_admin_operations

Suite Setup    Run Keywords    Enable Cloud
...            AND             Get Scfc File Aic    output_filepath=${OUTPUT_DIR}/initial_commissioning_cu.xml
...            AND             Get Scfc File Du Aic    path=${OUTPUT_DIR}
...            AND             Get Iphy Xml File
...            AND             Run Keyword If    ${SETUP_TL}    Deploy Multi Cpcell
...            AND             Run Keyword If    ${SETUP_TL}    Sleep    20s    reason=Waiting f1 link drop
...            AND             Run Keyword If    ${SETUP_TL}    Wait For F1 Links To Be Available Aic
...                                                                 timeout=600
...            AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/SetupLogs
...            AND             Start Additional Vm Ethernet Interfaces
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_4c_tdd_sansa_default_aic.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/SetupLogs

Suite Teardown    Run Keywords    Stop Additional Vm Ethernet Interfaces
...               AND             Stop Default Processes And Gather Logs And Compress Logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}


*** Test Cases ***
CB009789_DH_B1_1_Successful_5g_Cp_Cell_Service_Recovery_With_2n_Redundant_Cpcl_Pod_Failover
    [Documentation]    This user scenario describes vCU CNF behavior for successful recovery of 2N redundant
    ...                and resilient 5G-CP-CELL service hosted on a container of cpcl Pod. The cpcl Pod is non-CNF critical,
    ...                and deployed in 2N redundant mode. The 5G-CP-CELL service outage, which can't be recovered locally
    ...                (by container restart) are recovered by cpcl Pod failover by Node K8S failure.
    ...                The goal of recovery by 2N failover is to ensure that service downtime remains transparent for
    ...                other peer services.

    [Setup]    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

    ta5g_ue_mobility.Attach Ue    ue_id=${SA_UE1_CELL1}
    Establish Pdu Session    ue_id=${SA_UE1_CELL1}    pdu_id=1    gw_id=${SA_UE1_CELL1}

    ${ACTIVE_CPCL_BEFORE_CRASH} =    Get Active Subcomponent    subcomponent=cpcl
    Lock Single Cell    cell_id=1    timeout=120
    Send Eth Down To Active Subcomponent     subcomponent=cpcl
    ${ACTIVE_CPCL_AFTER_1ST_CRASH} =    Get Active Subcomponent    subcomponent=cpcl
    Should Not Be Equal    ${ACTIVE_CPCL_BEFORE_CRASH}    ${ACTIVE_CPCL_AFTER_1ST_CRASH}
    ...                    msg=Active CPCL is still ta same as before crash.

    Unlock Single Cell    cell_id=1    timeout=120
    sleep    300s    reason=NRBTS.x2EnDcCfUpNbInfoBackOffTmr set 300s
    ta5g_ue_mobility.Attach Ue    ue_id=${SA_UE2_CELL1}
    Establish Pdu Session    ue_id=${SA_UE2_CELL1}    pdu_id=1    gw_id=${SA_UE2_CELL1}
    Lock Single Cell    cell_id=1    timeout=120
    Send Eth Down To Active Subcomponent    subcomponent=cpcl
    ${ACTIVE_CPCL_AFTER_2ND_CRASH} =    Get Active Subcomponent    subcomponent=cpcl
    Should Not Be Equal    ${ACTIVE_CPCL_AFTER_1ST_CRASH}    ${ACTIVE_CPCL_AFTER_2ND_CRASH}
    ...                    msg=Active CPCL is still ta same as before crash.

    Unlock Single Cell    cell_id=1    timeout=120
    sleep    300s    reason=NRBTS.x2EnDcCfUpNbInfoBackOffTmr set 300s
    ta5g_ue_mobility.Attach Ue    ue_id=${SA_UE3_CELL1}
    Establish Pdu Session    ue_id=${SA_UE3_CELL1}    pdu_id=1    gw_id=${SA_UE3_CELL1}

    [Teardown]    Run Keywords    ta5g_ue_mobility.Deregister Ue Without Confirmation    ue_id=${SA_UE1_CELL1}
    ...           AND             ta5g_ue_mobility.Deregister Ue Without Confirmation    ue_id=${SA_UE2_CELL1}
    ...           AND             ta5g_ue_mobility.Deregister Ue Without Confirmation    ue_id=${SA_UE3_CELL1}
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}


CB009789_DH_B4_1_Successful_5g_Cp_If_Service_Recovery_With_2n_Redundant_Cpif_Pod_Failover
    [Documentation]    This user scenario describes vCU CNF behavior for successful recovery of 2N redundant
    ...                and resilient 5G-CP-IF service hosted on a container of cpif Pod. The cpif Pod is non-CNF critical,
    ...                and deployed in 2N redundant mode. The 5G-CP-IF service outage, which can't be recovered locally
    ...                (by container restart) are recovered by cpif Pod failover.

    [Setup]    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

    ta5g_ue_mobility.Attach Ue    ue_id=${SA_UE4_CELL1}
    Establish Pdu Session    ue_id=${SA_UE4_CELL1}    pdu_id=1    gw_id=${SA_UE4_CELL1}

    ${ACTIVE_CPIF_BEFORE_CRASH} =    Get Active Subcomponent    subcomponent=cpif
    Send Eth Down To Active Subcomponent    subcomponent=cpif
    ${ACTIVE_CPIF_AFTER_1ST_CRASH} =    Get Active Subcomponent    subcomponent=cpif
    Should Not Be Equal    ${ACTIVE_CPIF_BEFORE_CRASH}    ${ACTIVE_CPIF_AFTER_1ST_CRASH}
    ...                    msg=Active CPIF is still ta same as before crash.

    Sleep    10s    reason=Waiting f1 link drop
    Wait For F1 Links To Be Available Aic   timeout=600
    Wait For All Cells To Be Enabled
    ta5g_ue_mobility.Attach Ue    ue_id=${SA_UE5_CELL1}
    Establish Pdu Session    ue_id=${SA_UE5_CELL1}    pdu_id=1   gw_id=${SA_UE5_CELL1}
    Send Eth Down To Active Subcomponent    subcomponent=cpif
    ${ACTIVE_CPIF_AFTER_2ND_CRASH} =    Get Active Subcomponent    subcomponent=cpif
    Should Not Be Equal    ${ACTIVE_CPIF_AFTER_1ST_CRASH}    ${ACTIVE_CPIF_AFTER_2ND_CRASH}
    ...                    msg=Active CPIF is still ta same as before crash.

    Sleep    10s    reason=Waiting f1 link drop
    Wait For F1 Links To Be Available Aic   timeout=600
    Wait For All Cells To Be Enabled
    ta5g_ue_mobility.Attach Ue    ue_id=${SA_UE6_CELL1}
    Establish Pdu Session    ue_id=${SA_UE6_CELL1}    pdu_id=1   gw_id=${SA_UE6_CELL1}

    [Teardown]    Run Keywords    ta5g_ue_mobility.Deregister Ue Without Confirmation    ue_id=${SA_UE4_CELL1}
    ...           AND             ta5g_ue_mobility.Deregister Ue Without Confirmation    ue_id=${SA_UE5_CELL1}
    ...           AND             ta5g_ue_mobility.Deregister Ue Without Confirmation    ue_id=${SA_UE6_CELL1}
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
