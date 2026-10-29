import os

__team__ = "MN 5G RAN I&V 4 Pz HZG SG1"
__email__ = "I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com"


# modify CB008698_D9 SCF
# UE2 From cell1(phycellid=60) HO to cell2(phycellid=80)

# CU
PARAMS_TO_DELETE_CU_8698_D9 = []

MOs_TO_ADD_CU_8698_D9 = []

PARAMS_TO_MODIFY_CU_8698_D9 = [
    dict(value="true", dist_name="MRBTS-10550/NRBTS-10550", p_name="actDrbPreemption"),
    dict(value="2", dist_name="MRBTS-10550/NRBTS-10550", p_name="maxNumOfPreemptions"),
    dict(
        value="1",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1",
        p_name="maxNumOfCaUsersNRCell",
    ),
    dict(
        value="1",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1",
        p_name="maxNumOfSCellAlloc",
    ),
    dict(
        value="1",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1",
        p_name="maxNumOfUsersPerCell",
    ),
    dict(
        value="true",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1",
        p_name="preferNsaPreemption",
    ),
    dict(
        value="1",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2",
        p_name="maxNumOfCaUsersNRCell",
    ),
    dict(
        value="1",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2",
        p_name="maxNumOfNonGBRBearersSA",
    ),
    dict(
        value="1",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2",
        p_name="maxNumOfSCellAlloc",
    ),
    dict(
        value="1",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2",
        p_name="maxNumOfUsersPerCell",
    ),
    dict(
        value="true",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2",
        p_name="preferNsaPreemption",
    ),
    dict(value="true", dist_name="MRBTS-10550/NRBTS-10550", p_name="actIntraFreqHoSA"),
    dict(
        value="rsrp",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1",
        p_name="a3MeasEnabled",
    ),
    dict(
        value="15min", dist_name="MRBTS-10550/NRBTS-10550/NRPMRNL-1", p_name="miNrNGCC"
    ),
]


LIST_PARAMS_TO_MODIFY_CU_8698_D9 = [
    dict(
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1",
        list_name="a3MeasSsbRsrp",
        elements=[
            dict(p_name="a3HysteresisSsbRsrp", value="0", index=0),
            dict(p_name="a3OffsetSsbRsrp", value="-30", index=0),
            dict(p_name="a3TimeToTriggerSsbRsrp", value="ms256", index=0),
        ],
    ),
]


LIST_TO_ADD_CU_8698_D9 = []

# DU

PARAMS_TO_DELETE_DU_8698_D9 = []

MOs_TO_ADD_DU_8698_D9 = []

PARAMS_TO_MODIFY_DU_8698_D9 = [
    dict(value="true", dist_name="MRBTS-10550/NRBTS-10550", p_name="actDrbPreemption"),
    dict(value="2", dist_name="MRBTS-10550/NRBTS-10550", p_name="maxNumOfPreemptions"),
    dict(
        value="true",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-1",
        p_name="preferNsaPreemption",
    ),
    dict(
        value="1",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2",
        p_name="maxNumOfCaUsersNRCell",
    ),
    dict(
        value="1",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2",
        p_name="maxNumOfNonGBRBearersSA",
    ),
    dict(
        value="true",
        dist_name="MRBTS-10550/NRBTS-10550/NRCELL-2",
        p_name="preferNsaPreemption",
    ),
]

LIST_PARAMS_TO_MODIFY_DU_8698_D9 = []

LIST_TO_ADD_DU_8698_D9 = []
