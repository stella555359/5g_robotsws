from taf.rfrl.utilities.robot.general import get_builtin_value

tl = get_builtin_value(param_name="tl")
ue_config = tl.ue_config["UE_POOLS"]["TafUeAtPool"]["inline_config"]
ue_pc_address = ue_config["dongle_B66_n41"]["CONSTRUCTOR_PARAMETERS"]["configuration"][
    "ue_pc_address"
]
ue_pc_login = ue_config["dongle_B66_n41"]["CONSTRUCTOR_PARAMETERS"]["configuration"][
    "ue_pc_login"
]
ue_pc_password = ue_config["dongle_B66_n41"]["CONSTRUCTOR_PARAMETERS"]["configuration"][
    "ue_pc_password"
]
capabilities1 = ue_config["dongle_B66_n41"]["CAPABILITIES"]
capabilities2 = ue_config["dongle_n77_n78"]["CAPABILITIES"]
