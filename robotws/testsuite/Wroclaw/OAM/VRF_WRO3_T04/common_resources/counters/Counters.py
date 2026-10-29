from taf.sbts.oam.coam.admin.interface import admin
from robot.api.logger import console


class Counters:

    def __init__(self):
        self.coam_admin = admin()

    @staticmethod
    def check_if_counter_have_non_zero_values(dict_with_counter_values):
        values = dict_with_counter_values.values()
        assert any(values), console("All counters have 0 value")

    def get_counter_values(self, dist_name, counter_id, connection=None, timeout=60, radio=False):
        full_path = dist_name + "/" + counter_id
        formatted_dist_name = self._format_dist_name(full_path, connection=connection, radio=radio)
        counter = self.coam_admin.get_counters_info(formatted_dist_name, timeout, connection=connection)
        counter_values = self._get_measurements(counter)
        return counter_values

    def get_counter_values_quantity(self, dist_name, counter_id, connection, timeout=60):
        return len(self.get_counter_values(dist_name=dist_name, counter_id=counter_id, connection=connection,
                   timeout=timeout))

    def _format_dist_name(self, dist_name, connection=None, radio=None):
        sw_version = self.coam_admin.get_sw_version(connection=connection)
        if "BTS" in dist_name:
            return "BTS/" + dist_name
        elif "5G19A" in sw_version or radio:
            return 'TRS/' + dist_name
        else:
            return 'TRS/TNL-1/' + dist_name

    def _get_measurements(self, dictionary):
        if type(list(dictionary.values())[0]) is not dict:
            return dictionary
        return self._get_measurements(list(dictionary.values())[0])
