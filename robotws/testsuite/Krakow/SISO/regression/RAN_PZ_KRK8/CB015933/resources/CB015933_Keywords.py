from taf.rfrl.utilities.robot.general import get_builtin_value

tl = get_builtin_value(param_name="tl")
ue_config = tl.ue_config["UE_POOLS"]["TafUeAndroidPool"]["inline_config"]
ue_pc_address = ue_config["Samsung_S22"]["CONSTRUCTOR_PARAMETERS"]["configuration"][
    "ue_pc_address"
]
ue_pc_login = ue_config["Samsung_S22"]["CONSTRUCTOR_PARAMETERS"]["configuration"][
    "ue_pc_login"
]
ue_pc_password = ue_config["Samsung_S22"]["CONSTRUCTOR_PARAMETERS"]["configuration"][
    "ue_pc_password"
]
capabilities = ue_config["Samsung_S22"]["CAPABILITIES"]
