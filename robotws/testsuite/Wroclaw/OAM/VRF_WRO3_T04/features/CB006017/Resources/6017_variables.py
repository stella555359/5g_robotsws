from robot.libraries.BuiltIn import BuiltIn


def get_variables():
    ru_type = BuiltIn().get_variable_value("${tl.gnbs[0].dus[0].rus[0].ru_hw_group}")
    ru_root_password = "w@=EIj7P6R0bVy85OjCVa^ho&8" if ru_type.lower() == "aeqn" \
        else "ZCS81C3RIAZegZtvIn43EaAdA4oMSNFkSBrj4iMwTuI="
    data = {"RU_TYPE": ru_type,
            "RU_ROOT_PASSWORD": ru_root_password,
            "SERVICEUSER_DEFAULT_PASSWORD": "Pl(FzaYj5~c5;q",
            "SERVICEUSER_NEW_PASSWORD": "Pl(FzaYj5~c5;q12"}

    return data
