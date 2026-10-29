from taf.sbts.oam.coam.admin import admin
from robot.api import logger
from functools import wraps


class AdminHelper(admin):
    def __init__(self, admin_ip='192.168.255.129'):
        super(AdminHelper, self).__init__()
        self.set_admin_ip(admin_ip)
        assert self.admin_ip, 'Admin IP should be passed either as argument or from TL'

    def set_admin_ip(self, admin_ip):
        self.admin_ip = admin_ip if admin_ip else get_admin_ip_from_tl()

    def login_logout(admin_func):
        @wraps(admin_func)
        def wrapper(self, *args, **kwargs):
            self.create_admin_session()
            try:
                result = admin_func(self, *args, **kwargs)
                return result
            finally:
                self.disconnect()
        return wrapper

    def create_admin_session(self):
        self.connect_to(self.admin_ip)

    def disconnect(self):
        self.teardown()

    @login_logout
    def get_bts_status_from_admin(self):
        bts_info = self.get_bts_statuses(timeout=30)
        return bts_info

    @login_logout
    def get_nr_cells_info(self):
        cells_info = self.get_cells_info(cell_type='nr', timeout=30)
        return cells_info

    @login_logout
    def recommission_with_delta_from_admin(self, delta_json, should_activate=True):
        if delta_json == '[]':
            logger.info('No new parameter added to perform delta commissioning')
            return
        logger.debug('Performing delta commissioning with delta json %s' % (delta_json,))
        self.perform_delta_recommissioning(delta_file=delta_json,
                                           skip_parameter_relation_errors=True,
                                           should_activate=should_activate)

    def verify_all_cells_are_onair_with_admin(self):
        expected_cell_state = {'operationalState': 'Enabled', 'proceduralStatus': 'configured',
                               'blockingState': 'Unblocked', 'availabilityStatus': 'Online',
                               'administrativeState': 'Unlocked', 'usageState': 'Active'}
        expected_bts_status = {'operationalState': 'Enabled', 'proceduralState': 'OnAir',
                               'blockingState': 'Unblocked'}
        cells_info = self.get_nr_cells_info()
        for cell in cells_info:
            if cell['status'] != expected_cell_state:
                raise Exception("The cell status is not as expected. Current cell status : {} "
                                "and Expected Cell Status : {}".format(cell['status'], expected_cell_state))
        bts_status = self.get_bts_status_from_admin()
        if bts_status != expected_bts_status:
            raise Exception("The BTS status is not as expected. Current BTS status : {} and Expected BTS status : {}"
                            .format(bts_status, expected_bts_status))

    def get_number_of_cells(self):
        cells_info = self.get_nr_cells_info()
        return len(cells_info)


def get_admin_ip_from_tl():
    from robot.libraries.BuiltIn import BuiltIn
    return BuiltIn().get_variable_value(r'${tl.gnbs[0].cu.oam_http_connection_details.addr}')
