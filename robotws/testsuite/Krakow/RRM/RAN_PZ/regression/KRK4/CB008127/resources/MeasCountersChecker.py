import logging
import re

from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning
from taf.rfrl.bts.devices.dist_name_patterns import GnbDistNamePatterns
from taf.rfrl.bts.devices.du.pm_counters import GnbPmCounter, PmCounterOutputGetter


class MeasCountersChecker(object):
    """
    Class representing operations on measurement profile counters.

    Attributes:
        meas_counters (dict): A dictionary containing some of the measurement profile counters and their attributes.
    """
    meas_counters = {
        "M55191C00001": {"NAME": "SELECTIONS OF MEAS PROFILE MAPPINGS FOR NSA",
                         "EXPECTED_VALUE": "{}",
                         "COUNTER_OBJECT_TYPE": "MNSA",
                         "COUNTER_OBJECT_ID": "NRMNSA-{}"},
        "M55187C00001": {"NAME": "UE CONFIGURATION ATTEMPTS FOR IAF MEAS PROFILES",
                         "EXPECTED_VALUE": "{}",
                         "COUNTER_OBJECT_TYPE": "MIAF",
                         "COUNTER_OBJECT_ID": "NRMIAF-{}"},
        "M55188C00001": {"NAME": "UE CONFIGURATION ATTEMPTS FOR IEF MEAS PROFILES",
                         "EXPECTED_VALUE": "{}",
                         "COUNTER_OBJECT_TYPE": "MIEF",
                         "COUNTER_OBJECT_ID": "NRMIEF-{}"}}

    def __init__(self):
        """
        Initializes a new instance of the MeasCountersChecker class.
        """
        self._recent_interval_id = None
        self._pm_counters = None
        self._gnb_scf = None
        self._counter_objects_of_selected_meas_profiles = []
        self._gnb_distname = GnbDistNamePatterns()

    @property
    def pm_counters(self):
        """
        Returns the GnbPmCounter object.
        If the instance doesn't exist, it creates a new one and returns it.

        Returns:
            GnbPmCounter: The GnbPmCounter object.
        """
        if self._pm_counters is None:
            self._pm_counters = GnbPmCounter()
        return self._pm_counters

    @property
    def gnb_scf(self):
        """
        Returns the GnbCommissioning instance.
        If the instance doesn't exist, it creates a new one and returns it.
        Returns:
            GnbCommissioning: The GnbCommissioning object for GNB SCF operations.
        """
        if self._gnb_scf is None:
            self._gnb_scf = GnbCommissioning()
        return self._gnb_scf

    def enable_measurement_profile_counters_nsa(self, nrpmrnl_id="1", interval="5min", bts_id=0, du_id=0):
        """
        Sets the interval for NSA counters.

        Parameters:
            nrpmrnl_id (str): The ID of the NRPMRNL. Default is "1".
            interval (str): The interval for the counters. Default is "5min".
            bts_id (int): The ID of the BTS. Default is 0.
            du_id (int): The ID of the DU. Default is 0.

        Returns:
            None
        """
        params = ["miNrMeasProfileMappingNSA", "miNrMeasProfileInterFreq", "miNrMeasProfileIntraFreq"]
        params_delta = []
        commissioning_delta = [{
            "distName": f"{self._gnb_distname.bts_dist_name}/NRPMRNL-{nrpmrnl_id}",
            "operation": "update",
            "parameters": params_delta}]
        for param in params:
            param_delta = {"operation": "update",
                           "parameterName": param,
                           "value": interval}
            params_delta.append(param_delta)
        self.gnb_scf.perform_bts_delta_commissioning(delta=commissioning_delta, bts_id=bts_id, du_id=du_id)

    def wait_for_next_counter_period(self, interval="5min", delay=30):
        """
        Waits for the start of a next counter period.

        Args:
            interval (str, optional): The interval of the counter period. Defaults to "5min".
            delay (int, optional): The delay in seconds after the start of a new period. Defaults to 30.
        """
        self.pm_counters.wait_for_next_pm_period(interval=interval, delay=delay)

    def verify_inter_and_intra_freq_measurement_profile_counters(self, cell_id, mapping_profile_id, ief_meas_profile_id,
                                                                 iaf_meas_profile_id, ief_meas_cfg_attempts="1",
                                                                 iaf_meas_cfg_attempts="2",
                                                                 meas_profile_mappings_selections="3", interval="5min",
                                                                 successful_sgnb_additions=None, bts_id=0, du_id=0):
        """
        Verifies the inter and intra frequency measurement profile counters for a given cell and profile id.

        Args:
            cell_id (str): The cell ID.
            mapping_profile_id (str): The measurement mapping profile ID.
            ief_meas_profile_id (str): The inter-frequency measurement profile ID.
            iaf_meas_profile_id (str): The intra-frequency measurement profile ID.
            ief_meas_cfg_attempts (str, optional): Expected value of the M55188C00001 counter. Defaults to "1".
            iaf_meas_cfg_attempts (str, optional): Expected value of the M55187C00001 counter. Defaults to "1".
            meas_profile_mappings_selections (str, optional): Expected value of M55191C00001 counter. Defaults to "1".
            interval (str, optional): The measurement interval. Defaults to "5min".
            successful_sgnb_additions (int, optional): The number of successful SgNbAdditionResult. Defaults to None if
            not provided.
            bts_id (int, optional): The BTS ID. Defaults to 0.
            du_id (int, optional): The DU ID. Defaults to 0.
        """
        counters = self._get_meas_profile_counters(cell_id=cell_id, interval=interval, bts_id=bts_id, du_id=du_id)
        self._check_selected_meas_profile_counter(counters_dict=counters, counter_id="M55191C00001",
                                                  counter_value=meas_profile_mappings_selections,
                                                  meas_profile_id=mapping_profile_id,
                                                  successful_sgnb_additions=successful_sgnb_additions)
        self._check_selected_meas_profile_counter(counters_dict=counters, counter_id="M55187C00001",
                                                  counter_value=iaf_meas_cfg_attempts,
                                                  meas_profile_id=iaf_meas_profile_id,
                                                  successful_sgnb_additions=successful_sgnb_additions)
        self._check_selected_meas_profile_counter(counters_dict=counters, counter_id="M55188C00001",
                                                  counter_value=ief_meas_cfg_attempts,
                                                  meas_profile_id=ief_meas_profile_id)
        self._check_unused_meas_profile_counters(counters_dict=counters)

    def verify_intra_freq_measurement_profile_counters(self, cell_id, mapping_profile_id, iaf_meas_profile_id,
                                                       iaf_meas_cfg_attempts="1", meas_profile_mappings_selections="1",
                                                       interval="5min", successful_sgnb_additions=None, bts_id=0,
                                                       du_id=0):
        """
        Verify the intra-frequency measurement profile counters for a given cell and profile id.

        Args:
            cell_id (str): The ID of the cell.
            mapping_profile_id (str): The ID of the measurement mapping profile.
            iaf_meas_profile_id (str): The ID of the intra-frequency measurement profile.
            iaf_meas_cfg_attempts (str, optional): Expected value of the M55187C00001 counter. Defaults to "1".
            meas_profile_mappings_selections (str, optional): Expected value of M55191C00001 counter. Defaults to "1".
            interval (str, optional): The interval for which to retrieve the counters. Defaults to "5min".
            successful_sgnb_additions (int, optional): The number of successful SgNbAdditionResult. Defaults to None if
            not provided.
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
        """
        counters = self._get_meas_profile_counters(cell_id=cell_id, interval=interval, bts_id=bts_id, du_id=du_id)
        self._check_selected_meas_profile_counter(counters_dict=counters, counter_id="M55191C00001",
                                                  counter_value=meas_profile_mappings_selections,
                                                  meas_profile_id=mapping_profile_id,
                                                  successful_sgnb_additions=successful_sgnb_additions)
        self._check_selected_meas_profile_counter(counters_dict=counters, counter_id="M55187C00001",
                                                  counter_value=iaf_meas_cfg_attempts,
                                                  meas_profile_id=iaf_meas_profile_id,
                                                  successful_sgnb_additions=successful_sgnb_additions)
        self._check_unused_meas_profile_counters(counters_dict=counters)

    def _get_meas_profile_counters(self, cell_id, interval="5min", delay=90, timeout=180, bts_id=0, du_id=0):
        """
        Retrieves the measurement profile counters for a specific cell.

        Parameters:
            cell_id (str): The ID of the cell.
            interval (str): The interval for the counters. Default is "5min".
            delay (int): The delay after start of the new counter interval . Default is 90.
            timeout (int): The timeout for retrieving the counters. Default is 180.
            bts_id (int): The ID of the BTS. Default is 0.
            du_id (int): The ID of the DU. Default is 0.

        Returns:
            dict: A dictionary containing the measurement profile counters for the specified cell.
        """
        self.pm_counters.wait_for_next_pm_period(interval=interval, delay=delay)
        meas_counters = self.pm_counters.get_counter(
            counter_ids=",".join([counter_id for counter_id in self.meas_counters.keys()]), bts_id=bts_id, du_id=du_id,
            timeout=timeout)
        return PmCounterOutputGetter(pm_counter_output=meas_counters).get_cell_counters(cell_id=cell_id, cell_type='NR',
                                                                                        bts_id=bts_id, du_id=du_id)

    def _check_selected_meas_profile_counter(self, counters_dict, counter_id="M55191C00001", counter_value="3",
                                             meas_profile_id="11", successful_sgnb_additions=None):
        """
        Checks the selected measurement profile counter value.

        Parameters:
            counters_dict (dict): A dictionary containing the counters.
            counter_id (str): The ID of the counter. Default is "M55191C00001".
            counter_value (str): The expected value of the counter. Default is "3".
            meas_profile_id (str): The ID of the measurement profile. Default is "11".
            successful_sgnb_additions (int, optional): The number of successful SgNbAdditionResult.
            Defaults to None if not provided.

        Returns:
            None

        Raises:
            IncorrectMeasurementCounterValueException: If the counter value does not match the expected value.
            NotFoundCountersException: If the counters for the measurement profile are not found.
        """
        if successful_sgnb_additions and counter_id in ["M55191C00001", "M55187C00001"]:
            counter_value = str(int(counter_value) + int(successful_sgnb_additions))
        counter_attributes = self.meas_counters.get(counter_id)
        self._update_counter_attributes(attributes=counter_attributes, counter_value=counter_value,
                                        counter_object_id=meas_profile_id)
        counters = self._extract_counters(counters_dict=counters_dict, counter_id=counter_id,
                                          counter_attributes=counter_attributes)
        self._get_recent_interval_id(counters=counters)
        counter_value = str(counters.get(self._recent_interval_id))
        self._validate_counter_value(counter_id=counter_id, counter_value=counter_value,
                                     counter_attributes=counter_attributes, counter_of_selected_meas_profile=True)

    def _check_unused_meas_profile_counters(self, counters_dict):
        """
        Checks the unused measurement profile counters.

        Parameters:
            counters_dict (dict): A dictionary containing the counters.

        Returns:
            None

        Raises:
            IncorrectMeasurementCounterValueException: If the counter value is not 0 for an unused measurement profile.
            NotFoundCountersException: If the counters for the measurement profile are not found.
        """
        for counter_id, attributes in self.meas_counters.items():
            related_objects = self._get_related_counter_objects_of_unused_meas_profiles(
                counters_dict=counters_dict, counter_object_type=attributes.get("COUNTER_OBJECT_TYPE"))
            logging.info(f"\nFound '{counter_id}: {attributes.get('NAME')}' counter objects "
                         f"for unused measurement profiles: '{related_objects}'")
            for counter_object in related_objects:
                counter_attributes = attributes
                self._update_counter_attributes(attributes=counter_attributes, counter_value="0",
                                                counter_object_id=counter_object.split("-")[-1])
                counters = self._extract_counters(counters_dict=counters_dict, counter_id=counter_id,
                                                  counter_attributes=counter_attributes)
                self._get_recent_interval_id(counters=counters)
                counter_value = str(counters.get(self._recent_interval_id))
                self._validate_counter_value(counter_id=counter_id, counter_value=counter_value,
                                             counter_attributes=counter_attributes,
                                             counter_of_selected_meas_profile=False)

    def _get_recent_interval_id(self, counters):
        """
        Gets the most recent interval ID from the counters.

        Parameters:
            counters (dict): A dictionary containing the counters.

        Returns:
            None
        """
        if not self._recent_interval_id:
            interval_ids = list(counters.keys())
            interval_ids.sort(reverse=True)
            self._recent_interval_id = interval_ids[0]

    def _validate_counter_value(self, counter_id, counter_value, counter_attributes,
                                counter_of_selected_meas_profile=True):
        """
        Validates counter value for selected measurement profile.

        Parameters:
            counter_id (str): The ID of the counter.
            counter_value (str): The value of the counter.
            counter_attributes (dict): A dictionary containing the attributes of the counter.

        Returns:
            None

        Raises:
            IncorrectMeasurementCounterValueException: If the counter value does not match the expected value.
        """
        object_id, name, expected_value = counter_attributes.get("COUNTER_OBJECT_ID"), counter_attributes.get(
            "NAME"), counter_attributes.get("EXPECTED_VALUE")
        if counter_value == expected_value:
            self._log_counter_status(counter_id=counter_id, counter_value=expected_value, name=name,
                                     object_id=object_id)
            if counter_of_selected_meas_profile:
                self._counter_objects_of_selected_meas_profiles.append(object_id)
        else:
            self._raise_incorrect_counter_value_exception(counter_id=counter_id, counter_value=counter_value, name=name,
                                                          object_id=object_id, expected_value=expected_value)

    def _get_related_counter_objects_of_unused_meas_profiles(self, counters_dict, counter_object_type):
        """
        This method is used to get the related counter objects of unused measurement profiles.

        It filters the counters dictionary to get the object IDs that are related to the specified counter object type
        and are not in the list of selected measurement profile counters.

        Parameters:
            counters_dict (dict): A dictionary containing counters as keys and their corresponding object IDs as values.
            counter_object_type (str): The type of counter object to filter by.

        Returns:
            list: A list of object IDs that are related to the specified counter object type and are not in the list
            of selected measurement profile counters.

        Raises:
            NotFoundCountersException: If no counter object of unused measurement profile is found with the specified
            counter object type.
        """
        related_objects = [object_id for object_id in counters_dict.keys() if counter_object_type in object_id]
        unused_meas_profile_objects = [object_id for object_id in related_objects if
                                       object_id not in self._counter_objects_of_selected_meas_profiles]
        if unused_meas_profile_objects:
            return unused_meas_profile_objects
        else:
            raise NotFoundCountersException(
                f"Not found any counter object of unused measurement profile with type: '{counter_object_type}'")

    def _extract_counters(self, counters_dict, counter_id, counter_attributes):
        """
        Extracts the specified counter from the counter's dictionary.

        Args:
            counters_dict (dict): A dictionary containing the counters.
            counter_id (str): The ID of the counter to extract.
            counter_attributes (dict): A dictionary containing the attributes of the counter.

        Returns:
            The extracted counter.

        Raises:
            NotFoundCountersException: If the specified counter is not found in the dictionary.

        """
        counters = counters_dict.get(counter_attributes.get("COUNTER_OBJECT_ID")).get(
            counter_attributes.get("COUNTER_OBJECT_TYPE")).get(counter_id)
        if counters:
            return counters
        else:
            self._raise_not_found_counters_exception(counter_id=counter_id, counter_attributes=counter_attributes)

    def _update_counter_attributes(self, attributes, counter_value, counter_object_id):
        """
        Update the attributes dictionary with the counter value and counter object ID.

        Args:
            attributes (dict): The dictionary of attributes to update.
            counter_value (str): The value of the counter.
            counter_object_id (str): The ID of the counter object.

        Returns:
            None
        """
        self._clear_counter_attributes(attributes=attributes)
        attributes.update({'EXPECTED_VALUE': counter_value})
        attributes.update({"COUNTER_OBJECT_ID": attributes.get("COUNTER_OBJECT_ID").format(counter_object_id)})

    def _log_counter_status(self, counter_id, counter_value, name, object_id):
        """
        Logs the status of a counter.

        Parameters:
            counter_id (str): The ID of the counter.
            counter_value (str): The value of the counter.
            name (str): The name of the counter.
            object_id (str): The ID of the object associated with the counter.

        Returns:
            None
        """
        logging.info(f"OK: '{counter_id}: {name}' counter for measurement profile '{object_id}' "
                     f"has expected value: '{counter_value}' in interval '{self._recent_interval_id}'.")

    def _raise_not_found_counters_exception(self, counter_id, counter_attributes):
        """
        Raises an exception when the counters for the measurement profile are not found.

        Parameters:
            counter_id (str): The ID of the counter.
            counter_attributes (dict): A dictionary containing the attributes of the counter.

        Returns:
            None

        Raises:
            NotFoundCountersException: If the counters for the measurement profile are not found.
        """
        raise NotFoundCountersException(
            f"Error: Not found '{counter_id}: {counter_attributes.get('NAME')}' counters for measurement profile "
            f"'{counter_attributes.get('COUNTER_OBJECT_ID')}'.")

    def _raise_incorrect_counter_value_exception(self, counter_id, counter_value, name, object_id, expected_value):
        """
        Raises an exception when an incorrect counter value is encountered.

        Args:
            counter_id (str): The ID of the counter.
            counter_value (str): The actual value of the counter.
            name (str): The name of the counter.
            object_id (str): The ID of the measurement profile.
            expected_value (str): The expected value of the counter.

        Returns:
            None

        Raises:
            IncorrectMeasurementCounterValueException: If the counter value does not match the expected value.
        """
        raise IncorrectMeasurementCounterValueException(
            f"Error: '{counter_id}: {name}' counter value for measurement profile '{object_id}' has incorrect value"
            f" in interval '{self._recent_interval_id}'. Expected value: '{expected_value}' but got: "
            f"'{counter_value}'.")

    @staticmethod
    def _clear_counter_attributes(attributes):
        """
        This method is used to reset the counter attributes.
        It updates the 'EXPECTED_VALUE' attribute to "{}" and
        the 'COUNTER_OBJECT_ID' attribute to its default format
        by replacing the digits after the hyphen with "{}".

        Args:
            attributes (dict): The dictionary of attributes to update.

        Returns:
            None
        """
        attributes.update({'EXPECTED_VALUE': "{}"})
        attributes.update({"COUNTER_OBJECT_ID": re.sub(pattern=r"-\d+", repl="-{}",
                                                       string=attributes.get("COUNTER_OBJECT_ID"))})


class IncorrectMeasurementCounterValueException(Exception):
    """
    Exception raised when an incorrect measurement counter value is encountered.
    """
    pass


class NotFoundCountersException(Exception):
    """
    Exception raised when the required counters are not found.
    """
    pass
