import datetime
import os
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
MR_BTS_NAME = "MRBTS-" + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + "/NRBTS-" + str(tl.gnbs[0].global_bts_id)
NR_NAME = "NRBTS-" + str(tl.gnbs[0].global_bts_id)
X2_NAME = MR_NR_BTS_NAME + "/LTEENB-0"
NG_NAME = MR_NR_BTS_NAME + "/SERVEDAMF-1"
NR_CELL1_NAME = MR_NR_BTS_NAME + "/NRCELL-1"
NR_CELL2_NAME = MR_NR_BTS_NAME + "/NRCELL-2"

X2_LOCK = {X2_NAME: {"x2LinkLock": "locked"}}

X2_UNLOCK = {X2_NAME: {"x2LinkLock": "unlocked"}}

NG_LOCK = {NG_NAME: {"administrativeState": "Locked"}}

NG_UNLOCK = {NG_NAME: {"administrativeState": "Unlocked"}}

NSA_SA_CELL_ACT = {
    MR_NR_BTS_NAME: {
        "saCellActivationAlarmTimer": "20",
        "nsaCellActivationAlarmTimer": "150",
    }
}

CELL1_LOCK = {NR_CELL1_NAME: {"administrativeState": "Locked"}}

CELL2_LOCK = {NR_CELL2_NAME: {"administrativeState": "Locked"}}

CELL1_UNLOCK = {NR_CELL1_NAME: {"administrativeState": "Unlocked"}}

CELL2_UNLOCK = {NR_CELL2_NAME: {"administrativeState": "Unlocked"}}

NSA_SA_CELL_REC = {
    MR_NR_BTS_NAME: {
        "saCellActivationAlarmTimer": "600",
        "nsaCellActivationAlarmTimer": "600",
    }
}
