
radio_username_password = {
    "default": {
        "user_name": "toor4nsn",
        "password": "oZPS0POrRieRtu",
        "connection": "from_smod",
        "test_rmod_faults": "telnet_sendfault"
    },
    "default_alu": {
        "user_name": "asb",
        "password": "asb#1234",
        "connection": "from_smod",
        "test_rmod_faults": "telnet_sendfault"
    },
    # works at least on ARGA
    "default_nahka": {
        "user_name": "root",
        "password": "",
        "connection": "from_smod",
        "test_rmod_faults": "Unknown"
    },
    "default_made": {
        "user_name": "serviceuser",
        "password": "wcdjLlTpqEY3cAmOe11u6aELwGI3rDvpGJQvCkcyHZc=",
        "connection": "from_smod",
        "test_rmod_faults": "made_method"
    },
    "aeq_made": {
        "user_name": "serviceuser",
        "password": "bobuWrUHk7Xq7WPpY9ZcjEi8zNdX3plZ+/y420RZ7W4=",
        "connection": "from_smod",
        "test_rmod_faults": "made_method"
    },
    "AEHC": {
        "user_name": "serviceuser",
        "password": "7B+6yyInfX0uES/FP60uEyhjZHUxB2MoRWvZqUMW42g=",
        "connection": "from_smod",
        "test_rmod_faults": "Unknown"
    },
    "AZQP": {
        "user_name": "serviceuser",
        "password": "wcdjLlTpqEY3cAmOe11u6aELwGI3rDvpGJQvCkcyHZc=",
        "connection": "from_smod",
        "test_rmod_faults": "made_method"
    },
    "AEQN": {
        "user_name": "rfsw",
        "password": "HfBKgqIOogKY3BlGtiniuCI9bs76C8jYsAY6vw8f/Tw=",
        "connection": "from_smod",
        "test_rmod_faults": "Unknown"
    },
    "AHEGHA": {
        "user_name": "rfsw",
        "password": "0q/7SXKjF2AlAba+yisrCxQiKz1PRJJ0IVDZuh/sOaA=",
        "connection": "from_smod",
        "test_rmod_faults": "Unknown"
    },
    "FZFI": {
        "user_name": "root",
        "password": "",
        "connection": "from_smod",
        "test_rmod_faults": "telnet_sendfault"
    },
    "AV_AX": {
        "user_name": "serviceuser",
        "password": "kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og=",
        "connection": "from_smod",
        "test_rmod_faults": "mars_thor_rautu_method"
    },
    # "avq": {
    #     "user_name": "rfsw",
    #     "password": "f6gh0K2nXq0O8XqVFkUuMtJnzuKm0U3box0QcYgugn0=",
    #     "connection": "from_smod",
    #     "test_rmod_faults": "made_method"
    # },
    "zodiac": {
        "user_name": "serviceuser",
        "password": "WAH26M0DHuXSxpqpUSLmklXrKUfF4iPrXQ+8YULFNuM=",
        "connection": "from_smod",
        "test_rmod_faults": "made_method"
    },
    "AQ": {
        "user_name": "serviceuser",
        "password": "oBrd1RgbOasUtYAeVfxrW9yGHb6ONl0w+MJUoKrBMGE=",
        "connection": "from_smod",
        "test_rmod_faults": "kill_application_method"
    },
    "cybertron": {
        "user_name": "serviceuser",
        "password": "v160rWp/6qpX/RQjmnaupqP+FBV2/f7bgiwMI8+cpEY=",
        "connection": "from_smod",
        "test_rmod_faults": "kill_application_method"
    }
}


made_radios = ["AEQB", "AEQV", "AEQE", "AZQP", "AZQO", "AZQW", "AZHM", "AZHL", "AZQS", "AZQU", "AZQI", "AZQJ", "AZHN",
               "AEQP", "AEQK", "AEQH", "AEQJ", "AEQY", "AEQZ", "AEQQ", "AEQC", "AEQI", "AHEGHA", "AHFII", "AQQE",
               "AQQL", "AQQK", "AHPF", "AENB", "AEHE", "AEQM", "AZTA", "AQQY", "AQQA", "AQQC", "AQQQ", "AKQJ", "AKQI",
               "AKNB", "AKQZ", "AWHQN", "AEQU", "AWHHF", "AWHHI", "AWHQM", "AWHQV", "AWHQE", "AWHQF", "AWHKA", "AWHKB",
               "AWHHG", "AWHQW", "AWHQX", "AQQN", "AHLOB", "AQQJ", "AWHTA", "AQQS", "AQQH", "AHFIHA", "AQNA", "AWGQA",
               "AWGQB", "AQQQA", "AQHA", "AQHC", "AVQR", "AKNA", "AEQW", "AWHQU"]


def get_rmod(rmod_name):
    rname = rmod_name.split("(")[0]
    print("User given radio is {}, splitted {}".format(rmod_name, rname))
    if rname in radio_username_password:
        return radio_username_password[rname]
    elif "A" == rmod_name[0] and rname in made_radios and "AEQ" == rname[:3]:
        return radio_username_password["aeq_made"]
    # elif "A" == rmod_name[0] and "AVQ" == rname[:3]:
    #     return radio_username_password["avq"]
    elif rname[:2] in ("AV", "AX"):
        return radio_username_password["AV_AX"]
    elif "AQQL" in rname:
        return radio_username_password["cybertron"]
    elif rname[:2] == "AQ":
        return radio_username_password["AQ"]
    elif "A" == rmod_name[0] and "AHFI" == rname[:4]:
        return radio_username_password["zodiac"]
    elif "A" == rmod_name[0] and rname in made_radios:
        return radio_username_password["default_made"]
    elif "A" == rmod_name[0]:
        return radio_username_password["default_nahka"]
    elif "U" == rmod_name[0]:
        return radio_username_password["default_alu"]
    else:
        return radio_username_password["default"]


def made_radio(rmod_object):
    if isinstance(rmod_object, str):
        print("User has offered radio as a string not as a radio object.")
        rmod_name = rmod_object
    else:
        rmod_name = rmod_object.name
    rname = rmod_name.split("(")[0]
    print("Given radio is {}, {}, splitted {}".format(rmod_object, rmod_name, rname))
    if "A" == rmod_name[0] and rname in made_radios:
        print("Radio is Made radio")
        return True
    else:
        print("Radio is not Made radio")
        return False


def made_maverick_radio(rmod_object):
    if isinstance(rmod_object, str):
        print("User has offered radio as a string not as a radio object.")
        rmod_name = rmod_object
    else:
        rmod_name = rmod_object.name
    rname = rmod_name.split("(")[0]
    print("Given radio is {}, {}, splitted {}".format(rmod_object, rmod_name, rname))
    if "AK" == rmod_name[:2]:
        print("Radio is Maverick Made radio")
        return True
    else:
        print("Radio is not Maverick Made radio")
        return False


def select_telnet_port(rmod_object):
    if isinstance(rmod_object, str):
        print("User has offered radio as a string not as a radio object.")
        rmod_name = rmod_object
    else:
        rmod_name = rmod_object.name
    rname = rmod_name.split("(")[0]
    print("Given radio is {}, {}, splitted {}".format(rmod_object, rmod_name, rname))
    if "U" == rmod_name[0] or "FHCA" in rmod_name or "FZFI" in rmod_name:
        print(f"Radio {rmod_name} has 23 as telnet port.")
        return "23"
    else:
        print(f"Radio {rmod_name} has 2323 as telnet port.")
        return "2323"
