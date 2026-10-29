from taf.sbts.oam.coam.admin import admin


def get_sw_version():
    api = admin()
    connection = api.connect_to()
    swv = connection.get_sw_version()
    return swv


def get_sw_release():
    api = admin()
    connection = api.connect_to()
    swv = connection.get_sw_release_name()
    return swv
