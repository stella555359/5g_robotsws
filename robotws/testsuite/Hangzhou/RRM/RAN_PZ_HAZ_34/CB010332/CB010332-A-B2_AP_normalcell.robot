*** Settings ***
Documentation
...    author: Xiang Kang
...    contact: kang.xiang@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_08
Suite Setup       Common Suite Setup And Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/10cells_ecpri_100M/2_AEQE_4_AWHQN
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS25R2    tl-CLOUD_5G_I_MP_AP_LOOO
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ET.robot

*** Variables ***
${SYSCOM_FLAG}    True

# iphy.xml setting for SRS beamforming
@{PARAMS_IN_IPHY_XML}
...    vcell:ulFeatures=advancedSRS|cell=2.1
...    vcell:ulFeatures=advancedSRS|cell=2.2

*** Test Cases ***
CB010332-A-B2_ET_01_01_multi cells setup with NDM SRS configuration with srs pooling disable and check fault
    [Documentation]    todo
    [Tags]    c1
    log to console    step: diable UL-TDOA in all cells, set frame structure 1116 0ms
    delta commission parameters and wait cells onair    ${DISABLE_10332_IN_ALL_CELLS}
    delta commission parameters and wait cells onair    ${Frame_1106_0ms}
    Print BBPool Cells list

    log to console    step: enable 10332 in all non-BF cells(3~10)
    start to capture bts udplogs    tag=2_enable_10332
    FOR    ${cell_id}    IN RANGE    3    11
        log to console    step: enable UL-TDOA in cell${cell_id}, nrcellid=${16384+${cell_id}}
        delta commission parameters and wait cells onair    ${ENABLE_10332_NRCELL${cell_id}}
        Print BBPool Cells list
    END
    stop capture bts udplogs    tag=2_enable_10332

    log to console    step: lock all cells, unlock cell1-cell2, unlock cell3-cell10
    start to capture bts udplogs    tag=3_lock_unlock_s1
    delta commission parameters    ${LOCK_ALL_NRCELLS}
    Print BBPool Cells list
    delta commission parameters    ${UNLOCK_NRCELL1_2}
#    below two step not need due to CNN PR789665
#    cells should be onair    cell_id=1
#    cells should be onair    cell_id=2
    Print BBPool Cells list
    delta commission parameters    ${UNLOCK_NRCELL3_10}
    FOR    ${cell_id}    IN RANGE    3    11
        cells should be onair    cell_id=${cell_id}
    END
    Print BBPool Cells list
    stop capture bts udplogs    tag=3_lock_unlock_s1

#    log to console    step: lock all cells, unlock celll1, cell3-10, unlock cell2
#    start to capture bts udplogs    tag=4_lock_unlock_s2
#    delta commission parameters    ${LOCK_ALL_NRCELLS}
#    Print BBPool Cells list
#    unlock nrcell1
#    Print BBPool Cells list
#    delta commission parameters    ${UNLOCK_NRCELL3_10}
#    FOR    ${cell_id}    IN RANGE    3    11
#        cells should be onair    cell_id=${cell_id}
#    END
#    Print BBPool Cells list
#    unlock nrcell2
#    Print BBPool Cells list
#    stop capture bts udplogs    tag=4_lock_unlock_s2
#
#    log to console    step: lock all cells, unlock cell3-10, unlock cell1-cell2
#    start to capture bts udplogs    tag=5_lock_unlock_s3
#    delta commission parameters    ${LOCK_ALL_NRCELLS}
#    Print BBPool Cells list
#    delta commission parameters    ${UNLOCK_NRCELL3_10}
#    FOR    ${cell_id}    IN RANGE    3    11
#        cells should be onair    cell_id=${cell_id}
#    END
#    Print BBPool Cells list
#    delta commission parameters    ${UNLOCK_NRCELL1_2}
#    cells should be onair    cell_id=1
#    cells should be onair    cell_id=2
#    Print BBPool Cells list
#    stop capture bts udplogs    tag=5_lock_unlock_s3

    # delta will cause no mibsib due to AP limit.
#    log to console    step: diable UL-TDOA in all cells, set frame structure 1116 3ms
#    delta commission parameters and wait cells onair    ${DISABLE_10332_IN_ALL_CELLS}
#    delta commission parameters and wait cells onair    ${Frame_1106_3ms}
#    Print BBPool Cells list
#
#    log to console    step: enable 10332 in all non-BF cells(3~10)
#    start to capture bts udplogs    tag=2_enable_10332
#    FOR    ${cell_id}    IN RANGE    3    11
#        log to console    step: enable UL-TDOA in cell${cell_id}, nrcellid=${16384+${cell_id}}
#        delta commission parameters and wait cells onair    ${ENABLE_10332_NRCELL${cell_id}}
#        Print BBPool Cells list
#    END
#    stop capture bts udplogs    tag=2_enable_10332
#
#    log to console    step: lock all cells, unlock cell1-cell2, unlock cell3-cell10
#    start to capture bts udplogs    tag=3_lock_unlock_s1
#    delta commission parameters    ${LOCK_ALL_NRCELLS}
#    Print BBPool Cells list
#    delta commission parameters    ${UNLOCK_NRCELL1_2}
#    cells should be onair    cell_id=1
#    cells should be onair    cell_id=2
#    Print BBPool Cells list
#    delta commission parameters    ${UNLOCK_NRCELL3_10}
#    FOR    ${cell_id}    IN RANGE    3    11
#        cells should be onair    cell_id=${cell_id}
#    END
#    Print BBPool Cells list
#    stop capture bts udplogs    tag=3_lock_unlock_s1



*** Keywords ***
Modify Cfg
    Update Cfg    set_lmf id=1 daemon=$SERVER_IP:$DAEMON_PORT nfId=abcdef01234567gh
    Update Cfg    set_lmf id=2 daemon=$SERVER_IP:$DAEMON_PORT nfId=abcdef12345678gh

Perform Steps Before Setup Airphone Env
    Install BSR Package via WEBEM    ${AEQE_BSR_NAME}.zip

Print BBPool Cells list
    ${bbpool1_cells}    get scf parameter value    MRBTS-1/MNL-1/MNLENT-1/BBADM-1/BBPOOL-11:bbPoolCellsList
    ${bbpool2_cells}    get scf parameter value    MRBTS-1/MNL-1/MNLENT-1/BBADM-1/BBPOOL-12:bbPoolCellsList
    log to console    bbpool1_cells:${bbpool1_cells}
    log to console    bbpool2_cells:${bbpool2_cells}
