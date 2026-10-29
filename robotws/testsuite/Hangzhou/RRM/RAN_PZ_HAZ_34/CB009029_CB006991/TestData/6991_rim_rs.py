from robot.libraries.BuiltIn import BuiltIn

SPECIAL_SLOT_LIST_1116_0 = BuiltIn().get_variable_value("${SPECIAL_SLOT_LIST_1116_0}")
SPECIAL_SLOT_LIST_1116_3 = BuiltIn().get_variable_value("${SPECIAL_SLOT_LIST_1116_3}")
SPECIAL_SLOT_LIST_1208 = BuiltIn().get_variable_value("${SPECIAL_SLOT_LIST_1208}")
SPECIAL_SLOT_LIST_1070 = BuiltIn().get_variable_value("${SPECIAL_SLOT_LIST_1070}")

NEAR_ONLY = BuiltIn().get_variable_value("${NEAR_ONLY}")
NEAR_FAR_1 = BuiltIn().get_variable_value("${NEAR_FAR_1}")
NEAR_FAR_2 = BuiltIn().get_variable_value("${NEAR_FAR_2}")

START_SYMBOL_FOR_DL = 12
START_SYMBOL_FOR_SPECIAL_1116_4GP = 4
START_SYMBOL_FOR_SPECIAL_1116_6GP = 2
START_SYMBOL_FOR_SPECIAL_1070_1208 = 8


def get_rim_rs_sent_config_list(frame_structure_bw, near_far, repetition):
    """
    Author: catherine.cheng
    Description:
    get the rim-rs sender config for dldata_rimrssendreq, including sfn_offset(to current sfn), slot, symbol info
        1. for near only, dldata_rimrssendreq only sent on the N special slots
        2. for near-far config1(N>1), former N/2 dldata_rimrssendreq sent on special slots,
            and later N/2 sent on DL(1 preceding slot)
        3. for near-far config2(N>1), former N/2 dldata_rimrssendreq sent on special slots,
            and later N/2 sent on DL(2 preceding slot)
    check start symbol on special slot or DL slot is correct
        1. check start symbol on special slot is 8, for DL slot is 12 during one SFN for 1070 or 1208
        2. check start symbol on special slot is 4, for DL slot is 12 during one SFN for 1116 4GP
        3. check start symbol on special slot is 2, for DL slot is 12 during one SFN for 1116 6GP

    : param frame_structure_bw: 1116_3MS_4GP_100MHZ, 1116_0MS_6GP_60MHZ, 1208_2gp_40mhz, 1070_2gp_80mhz
    : param near_far: "near only", "near-far config1" or "near-far config2"
    : param repetition: rim-rs send repetition, r1, r2, r4, r8
    : return rim_rs_sent_config_list: rim-rs sender config for dldata_rimrssendreq
        e.g.
            rim_rs_sent_config_list = [
                dict(
                    sfn_offset=0,
                    slot=3,
                    start_symbol=4),
                dict(
                    sfn_offset=0,
                    slot=13,
                    start_symbol=4),
            ]
    """
    sfn_offset = 0
    special_slot_list = []
    rim_rs_sent_config_list = []
    start_symbol_on_special_slot = -1

    if "1116_3" in frame_structure_bw:
        special_slot_list = SPECIAL_SLOT_LIST_1116_3
    elif "1116_0" in frame_structure_bw:
        special_slot_list = SPECIAL_SLOT_LIST_1116_0
    elif "1208" in frame_structure_bw:
        special_slot_list = SPECIAL_SLOT_LIST_1208
    elif "1070" in frame_structure_bw:
        special_slot_list = SPECIAL_SLOT_LIST_1070

    if "4gp" in frame_structure_bw:
        start_symbol_on_special_slot = START_SYMBOL_FOR_SPECIAL_1116_4GP
    elif "6gp" in frame_structure_bw:
        start_symbol_on_special_slot = START_SYMBOL_FOR_SPECIAL_1116_6GP
    elif "2gp" in frame_structure_bw:
        start_symbol_on_special_slot = START_SYMBOL_FOR_SPECIAL_1070_1208

    if near_far == NEAR_FAR_1:
        sfn_offset = 1
    elif near_far == NEAR_FAR_2:
        sfn_offset = 2

    if repetition == "r1":
        if near_far == NEAR_ONLY:
            print("=======r1 NEAR_ONLY")
            rim_rs_sent_config_list = [
                dict(
                    sfn_offset=0,
                    slot=special_slot_list[0],
                    start_symbol=start_symbol_on_special_slot,
                ),
            ]
        else:
            raise AssertionError("only support near only when repetition = r1!!!")
    elif repetition == "r2":
        if near_far == NEAR_ONLY:
            print("=r2======NEAR_ONLY")
            rim_rs_sent_config_list = [
                dict(
                    sfn_offset=0,
                    slot=special_slot_list[0],
                    start_symbol=start_symbol_on_special_slot,
                ),
                dict(
                    sfn_offset=0,
                    slot=special_slot_list[1],
                    start_symbol=start_symbol_on_special_slot,
                ),
            ]
        elif near_far == NEAR_FAR_1 or near_far == NEAR_FAR_2:
            print("=r2======NEAR_FAR")
            rim_rs_sent_config_list = [
                dict(
                    sfn_offset=0,
                    slot=special_slot_list[0],
                    start_symbol=start_symbol_on_special_slot,
                ),
                dict(
                    sfn_offset=0,
                    slot=special_slot_list[1] - sfn_offset,
                    start_symbol=START_SYMBOL_FOR_DL,
                ),
            ]
    elif repetition == "r4":
        if "1116" in frame_structure_bw:
            if near_far == NEAR_ONLY:
                print("=r4======1116 NEAR_ONLY")
                rim_rs_sent_config_list = [
                    dict(
                        sfn_offset=0,
                        slot=special_slot_list[0],
                        start_symbol=start_symbol_on_special_slot,
                    ),
                    dict(
                        sfn_offset=0,
                        slot=special_slot_list[1],
                        start_symbol=start_symbol_on_special_slot,
                    ),
                    dict(
                        sfn_offset=1,
                        slot=special_slot_list[0],
                        start_symbol=start_symbol_on_special_slot,
                    ),
                    dict(
                        sfn_offset=1,
                        slot=special_slot_list[1],
                        start_symbol=start_symbol_on_special_slot,
                    ),
                ]
            elif near_far == NEAR_FAR_1 or near_far == NEAR_FAR_2:
                print("=r4======1116 NEAR_far")
                rim_rs_sent_config_list = [
                    dict(
                        sfn_offset=0,
                        slot=special_slot_list[0],
                        start_symbol=start_symbol_on_special_slot,
                    ),
                    dict(
                        sfn_offset=0,
                        slot=special_slot_list[1],
                        start_symbol=start_symbol_on_special_slot,
                    ),
                    dict(
                        sfn_offset=1,
                        slot=special_slot_list[0] - sfn_offset,
                        start_symbol=START_SYMBOL_FOR_DL,
                    ),
                    dict(
                        sfn_offset=1,
                        slot=special_slot_list[1] - sfn_offset,
                        start_symbol=START_SYMBOL_FOR_DL,
                    ),
                ]
        elif "1070" or "1208" in frame_structure_bw:
            if near_far == NEAR_ONLY:
                print("=r4======1070 NEAR_ONLY")
                rim_rs_sent_config_list = [
                    dict(
                        sfn_offset=0,
                        slot=special_slot_list[0],
                        start_symbol=start_symbol_on_special_slot,
                    ),
                    dict(
                        sfn_offset=0,
                        slot=special_slot_list[1],
                        start_symbol=start_symbol_on_special_slot,
                    ),
                    dict(
                        sfn_offset=0,
                        slot=special_slot_list[2],
                        start_symbol=start_symbol_on_special_slot,
                    ),
                    dict(
                        sfn_offset=0,
                        slot=special_slot_list[3],
                        start_symbol=start_symbol_on_special_slot,
                    ),
                ]
            elif near_far == NEAR_FAR_1 or near_far == NEAR_FAR_2:
                print("=r4======1070 NEAR_far")
                rim_rs_sent_config_list = [
                    dict(
                        sfn_offset=0,
                        slot=special_slot_list[0],
                        start_symbol=start_symbol_on_special_slot,
                    ),
                    dict(
                        sfn_offset=0,
                        slot=special_slot_list[1],
                        start_symbol=start_symbol_on_special_slot,
                    ),
                    dict(
                        sfn_offset=0,
                        slot=special_slot_list[2] - sfn_offset,
                        start_symbol=START_SYMBOL_FOR_DL,
                    ),
                    dict(
                        sfn_offset=0,
                        slot=special_slot_list[3] - sfn_offset,
                        start_symbol=START_SYMBOL_FOR_DL,
                    ),
                ]
    elif repetition == "r8":
        if "1116" in frame_structure_bw:
            if near_far == NEAR_ONLY:
                print("=r8======1116 NEAR_ONLY")
                rim_rs_sent_config_list = [
                    dict(
                        sfn_offset=0,
                        slot=special_slot_list[0],
                        start_symbol=start_symbol_on_special_slot,
                    ),
                    dict(
                        sfn_offset=0,
                        slot=special_slot_list[1],
                        start_symbol=start_symbol_on_special_slot,
                    ),
                    dict(
                        sfn_offset=1,
                        slot=special_slot_list[0],
                        start_symbol=start_symbol_on_special_slot,
                    ),
                    dict(
                        sfn_offset=1,
                        slot=special_slot_list[1],
                        start_symbol=start_symbol_on_special_slot,
                    ),
                    dict(
                        sfn_offset=2,
                        slot=special_slot_list[0],
                        start_symbol=start_symbol_on_special_slot,
                    ),
                    dict(
                        sfn_offset=2,
                        slot=special_slot_list[1],
                        start_symbol=start_symbol_on_special_slot,
                    ),
                    dict(
                        sfn_offset=3,
                        slot=special_slot_list[0],
                        start_symbol=start_symbol_on_special_slot,
                    ),
                    dict(
                        sfn_offset=3,
                        slot=special_slot_list[1],
                        start_symbol=start_symbol_on_special_slot,
                    ),
                ]
            elif near_far == NEAR_FAR_1 or near_far == NEAR_FAR_2:
                print("r8 1116=======NEAR_FAR")
                rim_rs_sent_config_list = [
                    dict(
                        sfn_offset=0,
                        slot=special_slot_list[0],
                        start_symbol=start_symbol_on_special_slot,
                    ),
                    dict(
                        sfn_offset=0,
                        slot=special_slot_list[1],
                        start_symbol=start_symbol_on_special_slot,
                    ),
                    dict(
                        sfn_offset=1,
                        slot=special_slot_list[0],
                        start_symbol=start_symbol_on_special_slot,
                    ),
                    dict(
                        sfn_offset=1,
                        slot=special_slot_list[1],
                        start_symbol=start_symbol_on_special_slot,
                    ),
                    dict(
                        sfn_offset=2,
                        slot=special_slot_list[0] - sfn_offset,
                        start_symbol=START_SYMBOL_FOR_DL,
                    ),
                    dict(
                        sfn_offset=2,
                        slot=special_slot_list[1] - sfn_offset,
                        start_symbol=START_SYMBOL_FOR_DL,
                    ),
                    dict(
                        sfn_offset=3,
                        slot=special_slot_list[0] - sfn_offset,
                        start_symbol=START_SYMBOL_FOR_DL,
                    ),
                    dict(
                        sfn_offset=3,
                        slot=special_slot_list[1] - sfn_offset,
                        start_symbol=START_SYMBOL_FOR_DL,
                    ),
                ]
        elif "1070" or "1208" in frame_structure_bw:
            if near_far == NEAR_ONLY:
                print("=======r8 1070 1208 near only")
                rim_rs_sent_config_list = [
                    dict(
                        sfn_offset=0,
                        slot=special_slot_list[0],
                        start_symbol=start_symbol_on_special_slot,
                    ),
                    dict(
                        sfn_offset=0,
                        slot=special_slot_list[1],
                        start_symbol=start_symbol_on_special_slot,
                    ),
                    dict(
                        sfn_offset=0,
                        slot=special_slot_list[2],
                        start_symbol=start_symbol_on_special_slot,
                    ),
                    dict(
                        sfn_offset=0,
                        slot=special_slot_list[3],
                        start_symbol=start_symbol_on_special_slot,
                    ),
                    dict(
                        sfn_offset=1,
                        slot=special_slot_list[0],
                        start_symbol=start_symbol_on_special_slot,
                    ),
                    dict(
                        sfn_offset=1,
                        slot=special_slot_list[1],
                        start_symbol=start_symbol_on_special_slot,
                    ),
                    dict(
                        sfn_offset=1,
                        slot=special_slot_list[2],
                        start_symbol=start_symbol_on_special_slot,
                    ),
                    dict(
                        sfn_offset=1,
                        slot=special_slot_list[3],
                        start_symbol=start_symbol_on_special_slot,
                    ),
                ]
            elif near_far == NEAR_FAR_1 or near_far == NEAR_FAR_2:
                print("r8 =======1070 1208 near far")
                rim_rs_sent_config_list = [
                    dict(
                        sfn_offset=0,
                        slot=special_slot_list[0],
                        start_symbol=start_symbol_on_special_slot,
                    ),
                    dict(
                        sfn_offset=0,
                        slot=special_slot_list[1],
                        start_symbol=start_symbol_on_special_slot,
                    ),
                    dict(
                        sfn_offset=0,
                        slot=special_slot_list[2],
                        start_symbol=start_symbol_on_special_slot,
                    ),
                    dict(
                        sfn_offset=0,
                        slot=special_slot_list[3],
                        start_symbol=start_symbol_on_special_slot,
                    ),
                    dict(
                        sfn_offset=1,
                        slot=special_slot_list[0] - sfn_offset,
                        start_symbol=START_SYMBOL_FOR_DL,
                    ),
                    dict(
                        sfn_offset=1,
                        slot=special_slot_list[1] - sfn_offset,
                        start_symbol=START_SYMBOL_FOR_DL,
                    ),
                    dict(
                        sfn_offset=1,
                        slot=special_slot_list[2] - sfn_offset,
                        start_symbol=START_SYMBOL_FOR_DL,
                    ),
                    dict(
                        sfn_offset=1,
                        slot=special_slot_list[3] - sfn_offset,
                        start_symbol=START_SYMBOL_FOR_DL,
                    ),
                ]

    return rim_rs_sent_config_list
