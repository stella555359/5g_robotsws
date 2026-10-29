from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
BTS_ID = str(tl.gnbs[0].instance_id)
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
X2AP_COMMAND_SA_254 = BuiltIn().get_variable_value('${X2AP_COMMAND_SA_254}')
X2AP_COMMAND_SA_49 = BuiltIn().get_variable_value('${X2AP_COMMAND_SA_49}')
X2AP_COMMAND_SA_255 = BuiltIn().get_variable_value('${X2AP_COMMAND_SA_255}')

if BTS_ID == "1170":
    X2AP_COMMAND_SA = X2AP_COMMAND_SA_254
    bb_slot_1 = "true"
    bb_slot_2 = "true"
    # TL254 left: FDD 255, TDD 254; Right: FDD 252, TDD 253
    INIT_PA_1349 = {0: [0, 127, 127, 127]}
    INIT_PA_RECOV = {0: [15, 0, 127, 127]}
    BIP_FILTER = 'dldata_pdschpayloadtbsendreq && (nr-rrc.hoppingId == 254)'

elif BTS_ID == "10152":
    X2AP_COMMAND_SA = X2AP_COMMAND_SA_49
    bb_slot_1 = "true"
    bb_slot_2 = "false"
    # TL049 Left: TDD 491, FDD 492, FDD 493, FDD 494; Right: FDD 495, TDD 496
    INIT_PA_1349 = {0: [0, 127], 1: [127, 127]}
    INIT_PA_RECOV = {0: [15, 0], 1: [127, 127]}
    BIP_FILTER = 'dldata_pdschpayloadtbsendreq && (nr-rrc.hoppingId == 191)'

elif BTS_ID == "255":
    X2AP_COMMAND_SA = X2AP_COMMAND_SA_255
    bb_slot_1 = "true"
    bb_slot_2 = "true"
    # TL255 Left: TDD 936, FDD 937; Right: FDD 938, TDD 939
    INIT_PA_1349 = {0: [0, 127, 127, 127]}
    INIT_PA_RECOV = {0: [0, 10, 127, 127]}
    BIP_FILTER = 'dldata_pdschpayloadtbsendreq && (nr-rrc.hoppingId == 936)'

else:
    X2AP_COMMAND_SA = X2AP_COMMAND_SA_255
    bb_slot_1 = "true"
    bb_slot_2 = "true"
    INIT_PA_1349 = {0: [0, 127], 1: [127, 127]}
    INIT_PA_RECOV = {0: [0, 10], 1: [127, 127]}
    BIP_FILTER = 'dldata_pdschpayloadtbsendreq'
