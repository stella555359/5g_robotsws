*** Settings ***
Documentation
...                 author:  Liu AnAn

Resource    ./Resources_ST_Stability.robot
Library     ../../../../resources/RAN_PZ_HAZ_1/Module/Commercial_UE_Operation.py

Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    5G_CLASSICAL_Android_ASOE_2xAHPB_3xAVQA_RJIO

*** Variables ***
${mrbts_id}    37753
${nrbts_id}    37753
@{nrcell_id}   1  2  3  4  5  6

${repeat_num}  100

*** Test Cases ***
EAR_OAM_Stability_All
    FOR  ${i}  IN RANGE  0  1  1
        Log to Console  Start to round ${i}
        Log to Console  Start to Cell Operation
        BTS Operation    operation=cell_lock    product_type=gnb    bts_index=0
        ...    distname_id=NRCELL-ALL    need_verify=yes
        BTS Operation    operation=cell_unlock    product_type=gnb    bts_index=0
        ...    distname_id=NRCELL-ALL    need_verify=yes
        BTS Operation    operation=cell_block    product_type=gnb    bts_index=0
        ...    distname_id=NRCELL-ALL    need_verify=yes
        BTS Operation    operation=cell_unblock    product_type=gnb    bts_index=0
        ...    distname_id=NRCELL-ALL    need_verify=yes
        BTS Operation    operation=cell_reset    product_type=gnb    bts_index=0
        ...    distname_id=NRCELL-ALL    need_verify=yes

        Log to Console  Start to BTS Operation
        BTS Operation    operation=bts_lock    product_type=gnb    bts_index=0    need_verify=yes
        BTS Operation    operation=bts_unlock    product_type=gnb    bts_index=0    need_verify=yes
        BTS Operation    operation=bts_block    product_type=gnb    bts_index=0    need_verify=yes
        BTS Operation    operation=bts_unblock    product_type=gnb    bts_index=0    need_verify=yes
        BTS Operation    operation=bts_reset    product_type=gnb    bts_index=0    need_verify=yes

        Log to Console  Start to RAT Operation
        BTS Operation    operation=rat_block    product_type=gnb    bts_index=0    distname_id=NRCELL-ALL    need_verify=yes
        BTS Operation    operation=rat_unblock    product_type=gnb    bts_index=0    distname_id=NRCELL-ALL    need_verify=yes
        BTS Operation    operation=rat_reset    product_type=gnb    bts_index=0    distname_id=NRCELL-ALL    need_verify=yes

        Log to Console  Start to RRU Operation
        BTS Operation    operation=ru_lock    product_type=gnb    bts_index=0    distname_id=RMOD-1    need_verify=yes
        BTS Operation    operation=ru_unlock    product_type=gnb    bts_index=0    distname_id=RMOD-1    need_verify=yes
        BTS Operation    operation=ru_reset    product_type=gnb    bts_index=0    distname_id=RMOD-1    need_verify=yes
    END

EAR_OAM_Stability_Cell
    FOR  ${i}  IN RANGE  0  100  1
        Log to Console  Start to round ${i}
        BTS Operation    operation=cell_lock    product_type=gnb    bts_index=0
        ...    distname_id=NRCELL-ALL    need_verify=yes
        BTS Operation    operation=cell_unlock    product_type=gnb    bts_index=0
        ...    distname_id=NRCELL-ALL    need_verify=yes
    END

EAR_OAM_Stability_BTS
    FOR  ${i}  IN RANGE  0  ${repeat_num}  1
        Log to Console  Start to round ${i}
        BTS Operation    operation=bts_lock    product_type=gnb    bts_index=0    need_verify=yes
        BTS Operation    operation=bts_unlock    product_type=gnb    bts_index=0    need_verify=yes
        # BTS Operation    operation=bts_block    product_type=gnb    bts_index=0    need_verify=yes
        # BTS Operation    operation=bts_unblock    product_type=gnb    bts_index=0    need_verify=yes
        # BTS Operation    operation=bts_reset    product_type=gnb    bts_index=0    need_verify=yes
    END

EAR_OAM_Stability_RAT
    FOR  ${i}  IN RANGE  0  ${repeat_num}  1
        Log to Console  Start to round ${i}
        BTS Operation    operation=rat_block    product_type=gnb    bts_index=0    need_verify=yes
        BTS Operation    operation=rat_unblock    product_type=gnb    bts_index=0    need_verify=yes
        # BTS Operation    operation=rat_reset    product_type=gnb    bts_index=0    need_verify=yes
    END

EAR_OAM_Stability_BBMOD
    FOR  ${i}  IN RANGE  0  ${repeat_num}  1
        Log to Console  Start to round ${i}
        BTS Operation    operation=bbmod_lock    product_type=gnb    bts_index=0    distname_id=BBMOD-1    need_verify=yes
        BTS Operation    operation=bbmod_unlock    product_type=gnb    bts_index=0    distname_id=BBMOD-1    need_verify=yes
        # BTS Operation    operation=bbmod_reset    product_type=gnb    bts_index=0    distname_id=BBMOD-1    need_verify=yes
    END

EAR_OAM_Stability_RRU
    FOR  ${i}  IN RANGE  0  ${repeat_num}  1
        Log to Console  Start to round ${i}
        BTS Operation    operation=ru_lock    product_type=gnb    bts_index=0    distname_id=RMOD-1    need_verify=yes
        BTS Operation    operation=ru_unlock    product_type=gnb    bts_index=0    distname_id=RMOD-1    need_verify=yes
        # BTS Operation    operation=ru_reset    product_type=gnb    bts_index=0    distname_id=RMOD-1    need_verify=yes
    END

EAR_Test_Stability_Para_Modify_Case1
    [Documentation]
    ...    author:
    [Tags]    QC_****

    Log to Console  \nTesting Started....

    FOR  ${i}  IN RANGE  1  ${repeat_num}  1
        Log to Console  \nStart to round ${i} ==========================================================
        @{gnb_para_list}          Create List    actRat1Alloc    percRedSEDlRat1VoNR
        @{gnb_mo_list}            Create List    MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
        ...                                      MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
        @{gnb_value_list}         Create List    false    0
        Modify_SCF_Parameters  product_type=gnb  para_list=@{gnb_para_list}
        ...    mo_list=@{gnb_mo_list}  value_list=@{gnb_value_list}
        BTS Operation    operation=cell_lock    product_type=gnb    bts_index=0
        ...    distname_id=NRCELL-ALL    need_verify=yes

        @{gnb_para_list}          Create List    actRat1Alloc    percRedSEDlRat1VoNR
        @{gnb_mo_list}            Create List    MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
        ...                                      MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
        @{gnb_value_list}         Create List    true    99
        Modify_SCF_Parameters  product_type=gnb  para_list=@{gnb_para_list}
        ...    mo_list=@{gnb_mo_list}  value_list=@{gnb_value_list}
        BTS Operation    operation=cell_unlock    product_type=gnb    bts_index=0
        ...    distname_id=NRCELL-ALL    need_verify=yes

        BTS Operation    operation=ru_lock    product_type=gnb    bts_index=0    distname_id=RMOD-1    need_verify=yes
        BTS Operation    operation=ru_unlock    product_type=gnb    bts_index=0    distname_id=RMOD-1    need_verify=yes
    END

EAR_Test_Stability_OAM_Case2
    [Documentation]
    ...    author:
    [Tags]    QC_****

    Log to Console  \nTesting Started....
    Log to Console  \nStart BTS Reset
    BTS Operation    operation=bts_reset  product_type=gnb  bts_index=0  need_verify=yes

    FOR  ${i}  IN RANGE  1  ${repeat_num}+1  1
        Log to Console  \nStart to round ${i} ======================================================================

        Log to Console  \nStart RRU lock/unlock
        BTS Operation    operation=ru_lock  product_type=gnb  bts_index=0  distname_id=RMOD-1  need_verify=yes
        BTS Operation    operation=ru_unlock  product_type=gnb  bts_index=0  distname_id=RMOD-1  need_verify=yes
        Log to Console  \nStart BBMOD-1 reset
        BTS Operation    operation=bbmod_reset  product_type=gnb  bts_index=0  distname_id=BBMOD-1  need_verify=yes
        Log to Console  \nStart BBMOD-2 reset
        BTS Operation    operation=bbmod_reset  product_type=gnb  bts_index=0  distname_id=BBMOD-2  need_verify=yes
        Log to Console  \nStart BBMOD-1 lock/unlock
        BTS Operation    operation=bbmod_lock  product_type=gnb  bts_index=0  distname_id=BBMOD-1  need_verify=yes
        BTS Operation    operation=bbmod_unlock  product_type=gnb  bts_index=0  distname_id=BBMOD-1  need_verify=yes
        Log to Console  \nStart RRU reset
        BTS Operation    operation=ru_reset  product_type=gnb  bts_index=0  distname_id=RMOD-1  need_verify=yes
        Log to Console  \nStart Cell lock/unlock
        BTS Operation    operation=cell_lock  product_type=gnb  bts_index=0  distname_id=NRCELL-ALL  need_verify=yes
        BTS Operation    operation=cell_unlock  product_type=gnb  bts_index=0  distname_id=NRCELL-ALL  need_verify=yes
    END

EAR_Test_Stability_OAM_Case3
    [Documentation]
    ...    author:
    [Tags]    QC_****

    Log to Console  \nTesting Started....
    Log to Console  \nStart BTS Reset

    FOR  ${i}  IN RANGE  1  ${repeat_num}+1  1
        Log to Console  \nStart to round ${i} ======================================================================

        Log to Console  \nStart Cell-${nrcell_id}[0] lock
        BTS Operation    operation=cell_lock  product_type=gnb  bts_index=0  distname_id=NRCELL-${nrcell_id}[0]  need_verify=yes

        Log to Console  \nStart RRU lock/unlock
        BTS Operation    operation=ru_lock  product_type=gnb  bts_index=0  distname_id=RMOD-1  need_verify=yes
        BTS Operation    operation=ru_unlock  product_type=gnb  bts_index=0  distname_id=RMOD-1  need_verify=yes

        Log to Console  \nStart Cell-${nrcell_id}[0] unlock
        BTS Operation    operation=cell_unlock  product_type=gnb  bts_index=0  distname_id=NRCELL-${nrcell_id}[0]  need_verify=yes

        Log to Console  \nStart BBMOD-1 reset
        BTS Operation    operation=bbmod_reset  product_type=gnb  bts_index=0  distname_id=BBMOD-1  need_verify=yes

        Log to Console  \nStart BBMOD-2 reset
        BTS Operation    operation=bbmod_reset  product_type=gnb  bts_index=0  distname_id=BBMOD-2  need_verify=yes

        Log to Console  \nStart BBMOD-1 lock/unlock
        BTS Operation    operation=bbmod_lock  product_type=gnb  bts_index=0  distname_id=BBMOD-1  need_verify=yes
        BTS Operation    operation=bbmod_unlock  product_type=gnb  bts_index=0  distname_id=BBMOD-1  need_verify=yes

        Log to Console  \nStart Cell-${nrcell_id}[1] lock/unlock
        BTS Operation    operation=cell_lock  product_type=gnb  bts_index=0  distname_id=NRCELL-${nrcell_id}[1]  need_verify=yes

        Log to Console  \nStart RRU reset
        BTS Operation    operation=ru_reset  product_type=gnb  bts_index=0  distname_id=RMOD-1  need_verify=yes

        Log to Console  \nStart Cell-${nrcell_id}[1] unlock
        BTS Operation    operation=cell_unlock  product_type=gnb  bts_index=0  distname_id=NRCELL-${nrcell_id}[1]  need_verify=yes

        Log to Console  \nStart BTS reset
        BTS Operation    operation=bts_reset  product_type=gnb  bts_index=0  need_verify=yes
    END