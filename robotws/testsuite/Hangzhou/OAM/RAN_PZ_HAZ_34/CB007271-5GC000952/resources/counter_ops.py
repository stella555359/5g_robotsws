from taf.sbts.oam.coam.admin import admin

admin_cli = admin()


def _get_smod_parameters(alias):
    return admin_cli.get_parameters(dist_name="/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/SMOD_L-1", connection=alias)


def get_restartCounter_from_smod(alias):
    return _get_smod_parameters(alias)["restartCounter"]


def assert_restartCounter_value(expected, alias):
    actual = get_restartCounter_from_smod(alias)
    assert int(actual) == int(expected), "Expected {} but got {}".format(expected, actual)


def set_key(dictionary, key, value):
    if key not in dictionary:
        dictionary[key] = value
    elif type(dictionary[key]) == list:
        dictionary[key].append(value[0])
    else:
        dictionary[key] = [dictionary[key], value[0]]
