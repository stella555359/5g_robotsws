** Settings ***
Documentation   This is a keyword file for 5GC000480-D-J, part setting expected counter values and parameters
...             Team: 'MN 5G&SC SW Eng ULM L2PS 60 SG'
...             Email: 'I_ECE_RD_ULM_SQD_60_GMS@internal.nsn.com'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------


*** Keywords ***

prepare counters and expected values successful PSCell
    set test variable    @{M55114C00001}    SGNB_NSA_ADMISSION_REQ          1    ${cell_distName}   RACCU
    set test variable    @{M55114C00002}    SGNB_NSA_ADMISSION_SUCC         1    ${cell_distName}   RACCU
    set test variable    @{M55114C00003}    SGNB_NSA_NGBR_DRB_REQ           1    ${cell_distName}   RACCU
    set test variable    @{M55114C00004}    SGNB_NSA_NGBR_DRB_SUCC          1    ${cell_distName}   RACCU
    set test variable    @{M55114C00006}    SGNB_NSA_RAC_REJ_DUE_TO_NSA     0    ${cell_distName}   RACCU
    set test variable    @{M55114C00007}    SGNB_NSA_RAC_REJ_DUE_TO_NGBR    0    ${cell_distName}   RACCU
    set test variable    @{M55114C00016}    SGNB_NSA_HO_ADMISSION_REQ       1    ${cell_distName}   RACCU
    set test variable    @{M55114C00017}    SGNB_NSA_NGBR_DRB_HO_REQ        1    ${cell_distName}   RACCU
    set test variable    @{M55114C00018}    SGNB_NSA_HO_ADMISSION_SUCC      1    ${cell_distName}   RACCU
    set test variable    @{M55114C00019}    SGNB_NSA_NGBR_DRB_HO_SUCC       1    ${cell_distName}   RACCU
    set test variable    @{M55114C00020}    SGNB_CU_NSA_ADMISSION_UNSUCC    0    ${cell_distName}   RACCU
    set test variable    @{M55115C00002}    SGNB_DU_NSA_ADMISSION_REQ       2    ${cell_distName}   RACDU
    set test variable    @{M55115C00003}    SGNB_DU_NSA_ADMISSION_SUCC      2    ${cell_distName}   RACDU
    set test variable    ${addNumOfHoUsers}             0
    set test variable    ${addNumOfNonGBRBearersHo}     0
    set test variable    ${maxNumOfUsers}               550
    set test variable    ${maxNumOfNonGBRBearers}       550
    set test variable    ${maxNumOfUsersPerCell}        275
    set test variable    ${maxNumOfSCellAlloc}          250
    set test variable    ${actMultiDrbNSA}              false

prepare counters and expected values successful release
    set test variable    @{M55114C00001}    SGNB_NSA_ADMISSION_REQ          2    ${cell_distName}   RACCU
    set test variable    @{M55114C00002}    SGNB_NSA_ADMISSION_SUCC         2    ${cell_distName}   RACCU
    set test variable    @{M55114C00003}    SGNB_NSA_NGBR_DRB_REQ           2    ${cell_distName}   RACCU
    set test variable    @{M55114C00004}    SGNB_NSA_NGBR_DRB_SUCC          2    ${cell_distName}   RACCU
    set test variable    @{M55114C00006}    SGNB_NSA_RAC_REJ_DUE_TO_NSA     0    ${cell_distName}   RACCU
    set test variable    @{M55114C00007}    SGNB_NSA_RAC_REJ_DUE_TO_NGBR    0    ${cell_distName}   RACCU
    set test variable    @{M55114C00016}    SGNB_NSA_HO_ADMISSION_REQ       0    ${cell_distName}   RACCU
    set test variable    @{M55114C00017}    SGNB_NSA_NGBR_DRB_HO_REQ        0    ${cell_distName}   RACCU
    set test variable    @{M55114C00018}    SGNB_NSA_HO_ADMISSION_SUCC      0    ${cell_distName}   RACCU
    set test variable    @{M55114C00019}    SGNB_NSA_NGBR_DRB_HO_SUCC       0    ${cell_distName}   RACCU
    set test variable    @{M55114C00020}    SGNB_CU_NSA_ADMISSION_UNSUCC    0    ${cell_distName}   RACCU
    set test variable    @{M55115C00002}    SGNB_DU_NSA_ADMISSION_REQ       2    ${cell_distName}   RACDU
    set test variable    @{M55115C00003}    SGNB_DU_NSA_ADMISSION_SUCC      2    ${cell_distName}   RACDU
    set test variable    ${addNumOfHoUsers}             0
    set test variable    ${addNumOfNonGBRBearersHo}     0
    set test variable    ${maxNumOfUsers}               550
    set test variable    ${maxNumOfNonGBRBearers}       550
    set test variable    ${maxNumOfUsersPerCell}        1
    set test variable    ${maxNumOfSCellAlloc}          1
    set test variable    ${actMultiDrbNSA}              false

prepare counters and expected values multiple handovers
    set test variable    @{M55114C00001}    SGNB_NSA_ADMISSION_REQ          1    ${cell_distName}   RACCU
    set test variable    @{M55114C00002}    SGNB_NSA_ADMISSION_SUCC         1    ${cell_distName}   RACCU
    set test variable    @{M55114C00003}    SGNB_NSA_NGBR_DRB_REQ           1    ${cell_distName}   RACCU
    set test variable    @{M55114C00004}    SGNB_NSA_NGBR_DRB_SUCC          1    ${cell_distName}   RACCU
    set test variable    @{M55114C00006}    SGNB_NSA_RAC_REJ_DUE_TO_NSA     0    ${cell_distName}   RACCU
    set test variable    @{M55114C00007}    SGNB_NSA_RAC_REJ_DUE_TO_NGBR    0    ${cell_distName}   RACCU
    set test variable    @{M55114C00016}    SGNB_NSA_HO_ADMISSION_REQ       5    ${cell_distName}   RACCU
    set test variable    @{M55114C00017}    SGNB_NSA_NGBR_DRB_HO_REQ        5    ${cell_distName}   RACCU
    set test variable    @{M55114C00018}    SGNB_NSA_HO_ADMISSION_SUCC      5    ${cell_distName}   RACCU
    set test variable    @{M55114C00019}    SGNB_NSA_NGBR_DRB_HO_SUCC       5    ${cell_distName}   RACCU
    set test variable    @{M55114C00020}    SGNB_CU_NSA_ADMISSION_UNSUCC    0    ${cell_distName}   RACCU
    set test variable    @{M55115C00002}    SGNB_DU_NSA_ADMISSION_REQ       6    ${cell_distName}   RACDU
    set test variable    @{M55115C00003}    SGNB_DU_NSA_ADMISSION_SUCC      6    ${cell_distName}   RACDU
    set test variable    ${addNumOfHoUsers}             0
    set test variable    ${addNumOfNonGBRBearersHo}     0
    set test variable    ${maxNumOfUsers}               550
    set test variable    ${maxNumOfNonGBRBearers}       550
    set test variable    ${maxNumOfUsersPerCell}        1
    set test variable    ${maxNumOfSCellAlloc}          1
    set test variable    ${actMultiDrbNSA}              false

prepare counters and expected values RacFailure
    set test variable    @{M55114C00001}    SGNB_NSA_ADMISSION_REQ          0    ${cell_distName}   RACCU
    set test variable    @{M55114C00002}    SGNB_NSA_ADMISSION_SUCC         0    ${cell_distName}   RACCU
    set test variable    @{M55114C00003}    SGNB_NSA_NGBR_DRB_REQ           0    ${cell_distName}   RACCU
    set test variable    @{M55114C00004}    SGNB_NSA_NGBR_DRB_SUCC          0    ${cell_distName}   RACCU
    set test variable    @{M55114C00006}    SGNB_NSA_RAC_REJ_DUE_TO_NSA     1    ${cell_distName}   RACCU
    set test variable    @{M55114C00007}    SGNB_NSA_RAC_REJ_DUE_TO_NGBR    0    ${cell_distName}   RACCU
    set test variable    @{M55114C00016}    SGNB_NSA_HO_ADMISSION_REQ       2    ${cell_distName}   RACCU
    set test variable    @{M55114C00017}    SGNB_NSA_NGBR_DRB_HO_REQ        2    ${cell_distName}   RACCU
    set test variable    @{M55114C00018}    SGNB_NSA_HO_ADMISSION_SUCC      1    ${cell_distName}   RACCU
    set test variable    @{M55114C00019}    SGNB_NSA_NGBR_DRB_HO_SUCC       1    ${cell_distName}   RACCU
    set test variable    @{M55114C00020}    SGNB_CU_NSA_ADMISSION_UNSUCC    1    ${cell_distName}   RACCU
    set test variable    @{M55115C00002}    SGNB_DU_NSA_ADMISSION_REQ       1    ${cell_distName}   RACDU
    set test variable    @{M55115C00003}    SGNB_DU_NSA_ADMISSION_SUCC      1    ${cell_distName}   RACDU
    set test variable    ${addNumOfHoUsers}             0
    set test variable    ${addNumOfNonGBRBearersHo}     0
    set test variable    ${maxNumOfUsers}               550
    set test variable    ${maxNumOfNonGBRBearers}       550
    set test variable    ${maxNumOfUsersPerCell}        1
    set test variable    ${maxNumOfSCellAlloc}          1
    set test variable    ${actMultiDrbNSA}              false

prepare counters and expected values RacBearerFailure
    set test variable    @{M55114C00001}    SGNB_NSA_ADMISSION_REQ          0    ${cell_distName}   RACCU
    set test variable    @{M55114C00002}    SGNB_NSA_ADMISSION_SUCC         0    ${cell_distName}   RACCU
    set test variable    @{M55114C00003}    SGNB_NSA_NGBR_DRB_REQ           0    ${cell_distName}   RACCU
    set test variable    @{M55114C00004}    SGNB_NSA_NGBR_DRB_SUCC          0    ${cell_distName}   RACCU
    set test variable    @{M55114C00006}    SGNB_NSA_RAC_REJ_DUE_TO_NSA     0    ${cell_distName}   RACCU
    set test variable    @{M55114C00007}    SGNB_NSA_RAC_REJ_DUE_TO_NGBR    1    ${cell_distName}   RACCU
    set test variable    @{M55114C00016}    SGNB_NSA_HO_ADMISSION_REQ       2    ${cell_distName}   RACCU
    set test variable    @{M55114C00017}    SGNB_NSA_NGBR_DRB_HO_REQ        4    ${cell_distName}   RACCU
    set test variable    @{M55114C00018}    SGNB_NSA_HO_ADMISSION_SUCC      1    ${cell_distName}   RACCU
    set test variable    @{M55114C00019}    SGNB_NSA_NGBR_DRB_HO_SUCC       3    ${cell_distName}   RACCU
    set test variable    @{M55114C00020}    SGNB_CU_NSA_ADMISSION_UNSUCC    1    ${cell_distName}   RACCU
    set test variable    @{M55115C00002}    SGNB_DU_NSA_ADMISSION_REQ       1    ${cell_distName}   RACDU
    set test variable    @{M55115C00003}    SGNB_DU_NSA_ADMISSION_SUCC      1    ${cell_distName}   RACDU
    set test variable    ${addNumOfHoUsers}             0
    set test variable    ${addNumOfNonGBRBearersHo}     0
    set test variable    ${maxNumOfUsers}               2
    set test variable    ${maxNumOfNonGBRBearers}       3
    set test variable    ${maxNumOfUsersPerCell}        275
    set test variable    ${maxNumOfSCellAlloc}          250
    set test variable    ${actMultiDrbNSA}              true

prepare counters and expected values RACaddHO
    set test variable    @{M55114C00001}    SGNB_NSA_ADMISSION_REQ          2    ${cell_distName}   RACCU
    set test variable    @{M55114C00002}    SGNB_NSA_ADMISSION_SUCC         1    ${cell_distName}   RACCU
    set test variable    @{M55114C00003}    SGNB_NSA_NGBR_DRB_REQ           2    ${cell_distName}   RACCU
    set test variable    @{M55114C00004}    SGNB_NSA_NGBR_DRB_SUCC          1    ${cell_distName}   RACCU
    set test variable    @{M55114C00006}    SGNB_NSA_RAC_REJ_DUE_TO_NSA     1    ${cell_distName}   RACCU
    set test variable    @{M55114C00007}    SGNB_NSA_RAC_REJ_DUE_TO_NGBR    0    ${cell_distName}   RACCU
    set test variable    @{M55114C00016}    SGNB_NSA_HO_ADMISSION_REQ       1    ${cell_distName}   RACCU
    set test variable    @{M55114C00017}    SGNB_NSA_NGBR_DRB_HO_REQ        1    ${cell_distName}   RACCU
    set test variable    @{M55114C00018}    SGNB_NSA_HO_ADMISSION_SUCC      1    ${cell_distName}   RACCU
    set test variable    @{M55114C00019}    SGNB_NSA_NGBR_DRB_HO_SUCC       1    ${cell_distName}   RACCU
    set test variable    @{M55114C00020}    SGNB_CU_NSA_ADMISSION_UNSUCC    1    ${cell_distName}   RACCU
    set test variable    @{M55115C00002}    SGNB_DU_NSA_ADMISSION_REQ       2    ${cell_distName}   RACDU
    set test variable    @{M55115C00003}    SGNB_DU_NSA_ADMISSION_SUCC      2    ${cell_distName}   RACDU
    set test variable    ${addNumOfHoUsers}             1
    set test variable    ${addNumOfNonGBRBearersHo}     1
    set test variable    ${maxNumOfUsers}               1
    set test variable    ${maxNumOfNonGBRBearers}       1
    set test variable    ${maxNumOfUsersPerCell}        275
    set test variable    ${maxNumOfSCellAlloc}          250
    set test variable    ${actMultiDrbNSA}              false

