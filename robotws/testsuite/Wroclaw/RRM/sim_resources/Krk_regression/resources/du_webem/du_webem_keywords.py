from taf.selenium.gnb.oam.coam.classical.interface import classical as du_selenium
from taf.sbts.oam.coam.admin import admin as du_admin
from taf.internal.sbts.admin.exceptions import AdminApiProcedureTimeoutException
from robot.libraries.BuiltIn import BuiltIn
from functools import wraps
from taf.rfrl.bts.devices.du.pm_counters import GenericPmCounter
from moler.util.moler_test import MolerTest
from taf.rfrl.bts.devices.du.commissioning import GenericCommissioning
import operator as ops


def selenium_connect(web_fun):
    @wraps(web_fun)
    def wrapper(self, *args, **kwargs):
        self.du_selenium_connection.login('https://{}/'.format(self.du_address), "Nemuadmin", "nemuuser")
        try:
            result = web_fun(self, *args, **kwargs)
            return result
        finally:
            pass

    return wrapper


def admin_connect(web_fun):
    @wraps(web_fun)
    def wrapper(self, *args, **kwargs):
        self.du_admin_connection.connect_to()
        try:
            result = web_fun(self, *args, **kwargs)
            return result
        finally:
            self.du_admin_connection.teardown_admin()

    return wrapper


class DuWebem(object):
    def __init__(self):
        tl = BuiltIn().get_variable_value('${{{}}}'.format("tl"), None)
        self.du_address = tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr
        self.du_selenium_connection = du_selenium()
        self.du_admin_connection = du_admin()

    @admin_connect
    def install_bts_certificate(self, path, certificate_password):
        """
        Install certificates on CU.

        :param path: path to .p12 file
        :param certificate_password: certificate file password
        :return: None
        """
        self.du_admin_connection.install_certificate(cert_file=path, cert_type="BtsTrustChain", cert_format="P12",
                                                     password=certificate_password)

    @admin_connect
    def restore_vendor_certificates(self):
        """
        Restore default certificates on DU.

        :return: None
        """
        self.du_admin_connection.restore_vendor_certificate()

    @staticmethod
    def get_du_counter(counter_id):
        """
        From GenericCounter
        Take counter identifier as input and return dict composed of counter path (dist name) and key - value pairs.
        Keys are capturing start time/interval identifiers and values are counter values for that interval.

        :param counter_id: str, counter identifier e.g. "M51321C0"
        :return: dict, e.g. {"TRS":
                            {"TNL-1":
                            {"IPIF":
                            {"IPIF-3":
                            {"IPIF_stats":
                            {"M51321C0":
                            {"1620621300": 96, "1620589200": 96, "1620606600": 96}}}}}}}
        """
        try:
            counter_dict = GenericPmCounter(bts_type='GNB').get_counter(counter_ids=counter_id, timeout=600)
        except AdminApiProcedureTimeoutException:
            MolerTest.info("AdminApiProcedureTimeoutException occurred\n"
                           "Second attempt to get counter {} values was triggered".format(counter_id))
            counter_dict = GenericPmCounter(bts_type='GNB').get_counter(counter_ids=counter_id)
        return counter_dict

    def extract_counter(self, counter_id, path, bts_counter=False):
        """
        Invoke get_du_counter method (see docstring) and extract counters from aggregated_dict for given path.
        extract_counter is designed for BTS and Transport Counters only.

        :param counter_id: str, e.g. "M51321C0"
        :param path: str, reduced full path (full path without last element) e.g. "TNL-1/IPIF/IPIF-3/IPIF_stats"
        :param bts_counter: bool, True if counter given in counter_id is BTS counter, False if TRS counter
        :return: dict, e.g. {"1620621300": 96, "1620589200": 96, "1620606600": 96}
        """
        extracted_dict = None
        aggregated_dict = self.get_du_counter(counter_id)
        path = path.split('/')
        if bts_counter is True:
            path.insert(0, 'BTS')
        else:
            path.insert(0, 'TRS')
        path.append(counter_id)
        for index in range(len(path)):  # iterative unpacking of aggregated_dict
            extracted_dict = ops.getitem(aggregated_dict, path[index])
            aggregated_dict = extracted_dict
        return extracted_dict

    def get_interval_id(self, counter_id, path, interval, bts_counter=False):
        """
        Invoke extract_counter method (see docstring) and
        return capturing start time/interval identifier for given interval.

        :param counter_id: str, e.g. "M51321C0"
        :param path: str, e.g "TNL-1/IPIF/IPIF-3/IPIF_stats"
        :param interval: int, index pointing to a interval in index notation e.g. -1 is last element of a
        keys_list corresponding to the most recent capturing start time/interval identifier.
        :param bts_counter: bool, True if counter given in counter_id is BTS counter, False if TRS counter
        :return: str, identifier of counter capturing start time e.g.
        """
        counter_dict = self.extract_counter(counter_id, path, bts_counter)
        keys_list = sorted([int(key) for key in counter_dict])  # Sort from the oldest to the most recent interval
        MolerTest.info("Interval identifier list: {}".format(keys_list))
        interval_id = str(keys_list[interval])
        return interval_id

    @MolerTest.raise_background_exceptions()
    def get_counter_for_interval(self, counter_id, path, interval_id, bts_counter=False):
        """
        Invoke extract counter method (see docstring) and return counter value for given counter_id,
        path, and interval_id.
        interval_id input variable designed to be output from get_interval_id method.

        :param counter_id: str, e.g. "M51321C0"
        :param path: str, e.g "TNL-1/IPIF/IPIF-3/IPIF_stats"
        :param interval_id: str, e.g."1620606600"
        :param bts_counter: bool, True if counter given in counter_id is BTS counter, False if TRS counter
        :return: int, value of desired counter e.g. 96
        """
        counter_value = None
        counter_dict = self.extract_counter(counter_id, path, bts_counter)
        try:
            counter_value = counter_dict[str(interval_id)]
        except KeyError:
            MolerTest.error('Improper interval identifier.\n '
                            'Available identifier list:{}'.format(sorted([int(key) for key in counter_dict])),
                            raise_exception=True)
        MolerTest.info("Counter start time id: {} ", interval_id)
        return [counter_value, interval_id]

    def get_many_counters(self, counter_ids, path, interval_id, bts_counter=False):
        """
        Take list of counter identifiers (all counter identifiers from counter_ids list should come from the same
        path/dist name), invoke get_counter_for_interval (see docstring) and return nested list composed of elements
        [counter_id, counter_value, interval_id] for each counter.

        :param counter_ids, lst, list fo counter identifiers e.g. ["M51321C0", "M51321C1"]
        :param path: str, e.g "TNL-1/IPIF/IPIF-3/IPIF_stats"
        :param interval_id: str, e.g."1620606600"
        :param bts_counter: bool, True if counter given in counter_ids is BTS counter, False if TRS counter
        :return: lst, e.g. [[counter_id0, counter_value0, interval_id0],[counter_id1, counter_value1, interval_id1]]
        """
        counter_data = []
        for counter in counter_ids:
            value = self.get_counter_for_interval(counter_id=counter, path=path,
                                                  interval_id=interval_id, bts_counter=bts_counter)
            counter_data.append([counter, value[0], value[1]])
        return counter_data

    @MolerTest.raise_background_exceptions()
    def validate_counter_values(self, counter_ids, path, interval_id, required_values, tolerance, bts_counter=False):
        """
        Take list of counter identifiers and list of required counter values (first element from counter_ids list
        should correspond to first element of required_values list), invoke get_many_counters method (see docstring)
        and validate observed counter value for given interval_id. Raise exception if not all counter passed.

        :param counter_ids: lst, list of counter identifiers e.g. ["M51321C0", "M51321C1"]
        :param path: str, reduced full path (full path without last element) e.g. "TNL-1/IPIF/IPIF-3/IPIF_stats"
        :param interval_id: str, e.g."1620606600", designed to be output from get_interval_id method
        :param required_values: lst, e.g. [100, 200] or ["100", "200"]
        :param tolerance: int, tolerance of required value e.g. 20 for a tolerance of 20% of observed value in relation
        :param bts_counter: bool, True if counter given in counter_ids is BTS counter, False if TRS counter
        to required value
        :return: None
        """
        lower_factor = None
        upper_factor = None

        if len(required_values) != len(counter_ids):
            MolerTest.error("Length of counter_ids list differs from length of required_values list. "
                            "They should be the same.", raise_exception=True)
        else:
            validation_result = []
            observed_values = self.get_many_counters(counter_ids, path, interval_id, bts_counter)
            try:
                lower_factor = 1 - (float(tolerance) / 100)
                upper_factor = 1 + (float(tolerance) / 100)
            except TypeError:
                MolerTest.error("tolerance input variable should be numeric", raise_exception=True)

            for observed_value, required_value in zip(observed_values, required_values):
                # Set boundary conditions for counter value
                lower_limit = round(lower_factor * float(required_value))
                upper_limit = round(upper_factor * float(required_value))
                if lower_limit <= float(observed_value[1]) <= upper_limit:
                    verdict = 'Passed'
                else:
                    verdict = 'Failed'
                sub_result = [verdict, 'CounterID: {}'.format(observed_value[0]),
                              'Counter Path: {}'.format(path),
                              'Observed value: {}'.format(observed_value[1]),
                              'Required value: {}'.format(required_value),
                              'Lower limit: {}, Upper limit: {}'.format(lower_limit, upper_limit),
                              'Counter start time identifier: {}'.format(observed_value[2])]
                validation_result.append(sub_result)

            MolerTest.info("Validation result: ", validation_result)
            summary = [verdict[0] for verdict in validation_result]  # verdict means 'Passed' or 'Failed'
            if not all(verdict == 'Passed' for verdict in summary):
                MolerTest.error("Validation Failed. Some observed counter values does not match to required values",
                                raise_exception=True,
                                dump=[sub_result for sub_result in validation_result if sub_result[0] == "Failed"])

    @MolerTest.raise_background_exceptions()
    def validate_counter_expect_zero(self, counter_ids, path, interval_id, bts_counter=False, expect_zero=True):
        """
        Take list of counter identifiers, invoke get_many_counters method (see docstring) and
        validate observed counter value for given interval_id. Raise exception if unexpected result appeared.

        :param counter_ids: lst, list of counter identifiers e.g. ["M51321C0", "M51321C1"]
        :param path: str, reduced full path (full path without last element) e.g. "TNL-1/IPIF/IPIF-3/IPIF_stats"
        :param interval_id: str, e.g."1620606600", designed to be output from get_interval_id method
        :param bts_counter: bool, True if counter given in counter_ids is BTS counter, False if TRS counter
        :param expect_zero: bool, True if all counter value should be zero,False if at least one non-zero val required
        :return: None
        """
        validation_result = []
        observed_values = self.get_many_counters(counter_ids, path, interval_id, bts_counter)

        for observed_value in observed_values:
            if observed_value[1] in [0, "0"]:
                verdict = 'zero_value'
            else:
                verdict = 'nonzero_value'
            sub_result = [verdict,
                          'CounterID: {}'.format(observed_value[0]),
                          'Counter Path: {}'.format(path),
                          'Observed value: {}'.format(observed_value[1]),
                          'Counter start time identifier: {}'.format(observed_value[2])]
            validation_result.append(sub_result)
        MolerTest.info("Validation result: ", validation_result)
        summary = [verdict[0] for verdict in validation_result]

        if expect_zero is True:
            expected_value = 'zero_value'
            if not all(verdict == expected_value for verdict in summary):
                MolerTest.error("Validation Failed. Nonzero counter value observed, all zero required",
                                raise_exception=True,
                                dump=[sub_result for sub_result in validation_result if
                                      sub_result[0] != expected_value])
        else:
            expected_value = 'nonzero_value'
            if expected_value not in summary:
                MolerTest.error("Validation Failed. Observed counter values are all zero. "
                                "At least one non-zero value is required",
                                raise_exception=True,
                                dump=[sub_result for sub_result in validation_result if
                                      sub_result[0] != expected_value])

    @staticmethod
    def wait_for_next_interval(interval):
        """
        Wait for next counter interval.

        :param interval: str, interval e.g. "5" to wait for the start of next 5min interval
        :return: None
        """
        counter_object = GenericPmCounter(bts_type='GNB')
        counter_object.wait_for_next_pm_period(int(interval))

    @staticmethod
    def update_parameter(dist_name, parameter_name, value):
        """
        Update value of SCF parameter.

        :param dist_name: str, distname e.g. "MRBTS-{}/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1"
        :param parameter_name: str, parameter name
        :param value: str, new parameter value
        :return: None
        """
        du = GenericCommissioning()
        bts_id = du.get_global_bts_id()
        du.perform_object_recommissioning(
            dist_name=dist_name.format(bts_id),
            parameter=[{"parameterName": parameter_name, "operation": "update", "value": value}],
            operation="update", skip_parameter_relation_errors=True, should_activate=True)
