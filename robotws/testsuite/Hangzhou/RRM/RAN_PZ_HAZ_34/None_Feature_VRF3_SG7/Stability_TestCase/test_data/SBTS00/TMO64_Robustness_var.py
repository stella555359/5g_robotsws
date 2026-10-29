from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")
gNbId = tl.gnbs[0].instance_id

PARAMS_IN_SCF = [
  "NRBTS:drbInactivityTimerSA=600",
  "NRBTS:drbInactivityTimerSA5qi1=600",
  "NRBTS:drbInactivityTimerSA5qi5=600",
  "NRBTS:nsaInactivityTimer=600",
]

DELTA_PARAS_Lock_Cell = [
    "NRCELL:administrativeState=Locked",
]

DELTA_PARAS_UnLock_Cell = [
    "NRCELL:administrativeState=Unlocked",
]

DELTA_PARAS_Lock_NG_link = [
    "SERVEDAMF-1:administrativeState=Locked",
    "SERVEDAMF-2:administrativeState=Locked",
    "SERVEDAMF-3:administrativeState=Locked",
]

DELTA_PARAS_UnLock_NG_link = [
    "SERVEDAMF-1:administrativeState=Unlocked",
    "SERVEDAMF-2:administrativeState=Unlocked",
    "SERVEDAMF-3:administrativeState=Unlocked",
]

DELTA_PARAS_RMOD_Lock = [
    "RMOD-1:administrativeState=Locked",
    "RMOD-4:administrativeState=Locked",
    "RMOD-5:administrativeState=Locked",
    "RMOD-6:administrativeState=Locked",
]

DELTA_PARAS_RMOD_unlock = [
    "RMOD-1:administrativeState=Unlocked",
    "RMOD-4:administrativeState=Unlocked",
    "RMOD-5:administrativeState=Unlocked",
    "RMOD-6:administrativeState=Unlocked",
]
