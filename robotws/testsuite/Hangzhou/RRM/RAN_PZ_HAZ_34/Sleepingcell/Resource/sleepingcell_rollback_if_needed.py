import time
from taf.sbts.oam.coam.admin import admin

__all__ = ['rollback_if_needed', 'get_all_sw_package', 'get_active_higher_than_passive_flag']

coam = admin()


class PackageAdmin(object):
    def __init__(self, connection='GNB_OAM'):
        self.connection = connection

    def get_active_and_passive_package(self):
        software_infos = coam.get_software_info(connection=self.connection)
        if isinstance(software_infos, dict):
            active_sw = software_infos.get('Active SW version')
            passive_sw = software_infos.get('Passive SW version')
            print('**********************\nactive :{}\npassive:{}'.format(active_sw, passive_sw))
            return active_sw, passive_sw
        else:
            return None, None

    def active_higher_than_passive(self):
        active_sw, passive_sw = self.get_active_and_passive_package()
        if active_sw is not None and passive_sw is not None:
            active_stream = active_sw.split("_")[0]
            passive_stream = passive_sw.split("_")[0]
            return active_stream > passive_stream
        else:
            return False

    def rollback_if_active_higher_than_passive(self):
        if self.active_higher_than_passive():
            print('WARN: Rollback')
            coam.rollback_software(timeout=900, connection=self.connection)
            time.sleep(30)
            print('**********************')
            return True
        else:
            return False


def rollback_if_needed(connection='GNB_OAM'):
    object = PackageAdmin(connection=connection)
    flag = object.rollback_if_active_higher_than_passive()
    return flag


def get_all_sw_package(connection='GNB_OAM'):
    object = PackageAdmin(connection=connection)
    active_stream, passive_stream = object.get_active_and_passive_package()
    return active_stream, passive_stream


def get_active_higher_than_passive_flag(connection='GNB_OAM'):
    object = PackageAdmin(connection=connection)
    flag = object.active_higher_than_passive()
    return flag
