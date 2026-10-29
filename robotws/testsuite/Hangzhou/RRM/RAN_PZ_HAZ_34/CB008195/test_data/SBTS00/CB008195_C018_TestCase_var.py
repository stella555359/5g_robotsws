from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")
gNbId = tl.gnbs[0].instance_id

PARAMS_IN_VENDOR = [
    "bbPoolCapacity:maxNumOfUserL2Pool=3|bbHwVariant=ABIO",
    "bbPoolCapacity:maxNumPucchF1SRPerSlotL1Pool=30|bbHwVariant=ABIO",
    "bbPoolCapacity:maxNumPucchF3PCSIPerSlotL1Pool=30|bbHwVariant=ABIO",
]
