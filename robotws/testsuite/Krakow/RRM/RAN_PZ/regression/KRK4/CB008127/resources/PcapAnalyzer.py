import json
import logging
import os
import re

from moler.device import DeviceFactory
from taf.analyzer.pcap.interface import pcap
from taf.rfrl.utilities.robot.general import get_builtin_value
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl


class BasePcapKeywords(object):
    """
    Class for analyzing pcap files.
    """

    def __init__(self):
        """
        Initializes the PcapAnalyzer object.
        """
        self.log_path = get_builtin_value('LOG_PATH')
        self.pcap_parser = pcap()
        self.processed_file_path = None

    def get_field_value_from_pcap(self, pcap_path, filter_expression, field_name, value_format="showname"):
        """
        Retrieves the value of a specified field from a pcap file.

        Args:
            pcap_path (str): The path to the pcap file.
            filter_expression (str): The filter expression to apply to the pcap file.
            field_name (str): The name of the field to retrieve the value from.
            value_format (str, optional): The format of the value to return. Defaults to "showname".

        Returns:
            str: The value of the specified field.

        """
        self.pcap_parser.setup(infile=pcap_path)
        return self.pcap_parser.get_field_value(field_name=field_name, fmt=value_format, filter=filter_expression)

    @load_moler_configuration_from_tl()
    def convert_filtered_pcap_to_json(self, pcap_path, display_filter, output_path, gnb_id):
        """
        Converts a filtered pcap file to JSON format.

        Args:
            pcap_path (str): The path to the pcap file.
            display_filter (str): The display filter to apply.
            output_path (str): The path to save the output JSON file.
            gnb_id (int): The ID of the GNB.

        Returns:
            str: The path to the generated output JSON file.

        Raises:
            PcapProcessingException: If the output file is empty.
        """
        tshark_device = DeviceFactory.get_cloned_device(source_device=f"GNB{gnb_id}", new_name=f"GNB{gnb_id}_tshark",
                                                        initial_state="PROXY_PC")
        tshark_cmd_string = f'-r {pcap_path} -Y "{display_filter}" -T json > {output_path}'
        tshark_cmd = tshark_device.get_cmd(cmd_name="tshark", cmd_params={"options": tshark_cmd_string})
        tshark_cmd(timeout=300)
        if os.path.getsize(output_path) > 5:
            logging.info(f"Output file '{output_path}' generated successfully!")
            self.processed_file_path = output_path
            return output_path
        else:
            raise PcapProcessingException(f"Error: Output file '{output_path}' is empty. No packet was matched "
                                          f"to applied display filter '{display_filter}' in pcap '{pcap_path}'")

    def _get_meas_config_element(self, msg_json_path, msg_display_filter):
        """
        Retrieves the 'nr-rrc.measConfig_element' from the specified JSON file.

        Args:
            msg_json_path (str): The path to the JSON file.
            msg_display_filter (str): The display filter for the message.

        Returns:
            dict: The 'nr-rrc.measConfig_element' from the JSON file.

        Raises:
            PcapProcessingException: If the 'nr-rrc.measConfig_element' cannot be extracted from the JSON file.
        """
        self.processed_file_path = msg_json_path
        with open(msg_json_path) as msg:
            json_raw_data = json.load(msg)
            msg_with_meas_config = self._get_msg_containing_meas_config(
                json_raw_data if isinstance(json_raw_data, list) else [json_raw_data])
            container_id = self._get_item_identifier_from_pcap(item_name="SgNBtoMeNBContainer",
                                                               pcap_msg=str(msg_with_meas_config))
            try:
                meas_config_tree = msg_with_meas_config["_source"]["layers"]["x2ap"]["x2ap.X2AP_PDU_tree"][
                    "x2ap.successfulOutcome_element"]["x2ap.value_element"][f"{msg_display_filter}"][
                    "x2ap.protocolIEs_tree"][f"Item {container_id}: id-SgNBtoMeNBContainer"][
                    "x2ap.ProtocolIE_Field_element"]["x2ap.value_element"]["x2ap.SgNBtoMeNBContainer_tree"][
                    "nr-rrc.CG_Config_element"]["nr-rrc.criticalExtensions_tree"]["nr-rrc.c1_tree"][
                    "nr-rrc.cg_Config_element"]["nr-rrc.scg_CellGroupConfig_tree"]["nr-rrc.RRCReconfiguration_element"][
                    "nr-rrc.criticalExtensions_tree"]["nr-rrc.rrcReconfiguration_element"]["nr-rrc.measConfig_element"]
            except KeyError as e:
                raise PcapProcessingException(f"Error: Unable to extract 'nr-rrc.measConfig_element' from "
                                              f"'{self.processed_file_path}'. '{e}'")
            else:
                return meas_config_tree

    def _get_msg_containing_meas_config(self, pcap_msg):
        """
        Retrieves the message containing 'nr-rrc.measConfig_element' from the pcap message.

        Args:
            pcap_msg (list): A list of pcap messages.

        Returns:
            dict: The message containing 'nr-rrc.measConfig_element'.

        Raises:
            PcapProcessingException: If no message containing 'nr-rrc.measConfig_element' is found.
        """
        re_meas_config = re.compile(r"nr-rrc\.measConfig_element")
        msg_with_meas_config = next((msg for msg in pcap_msg if re.search(re_meas_config, str(msg))), None)

        if msg_with_meas_config is None:
            raise PcapProcessingException(
                f"Error: Not found msg containing measConfig_element in '{self.processed_file_path}'")

        return msg_with_meas_config

    def _get_item_identifier_from_pcap(self, item_name, pcap_msg):
        """
        Get the item identifier from the pcap message.

        Args:
            item_name (str): The name of the item.
            pcap_msg (str): The pcap message to search in.

        Returns:
            str: The item identifier.

        Raises:
            PcapProcessingException: If the item identifier is not found in the pcap message.
        """
        re_item_id = re.compile(r"Item\s(?P<item_id>\d+):\sid-{}".format(item_name))
        match = re.search(re_item_id, pcap_msg)
        if match:
            return match.group("item_id")
        else:
            raise PcapProcessingException(f"Error: Not found Item id of '{item_name}' in '{self.processed_file_path}'")

    def _get_report_config_to_add_mod(self, meas_config_element):
        """
        Retrieves the reportConfigToAddModList from the given measurement configuration element.

        Args:
            meas_config_element (dict): The measurement configuration element.

        Returns:
            dict: reportConfigToAddModList
        """
        try:
            report_config_tree = meas_config_element["nr-rrc.reportConfigToAddModList_tree"]
        except KeyError as e:
            raise PcapProcessingException(f"Error: Unable to extract 'nr-rrc.reportConfigToAddModList_tree' from 'nr-"
                                          f"rrc.measConfig_element'. Source file: '{self.processed_file_path}'. '{e}'")
        else:
            return report_config_tree

    def _get_meas_id_to_add_mod(self, meas_config_element):
        """
        Retrieves the 'nr-rrc.measIdToAddModList_tree' from the 'meas_config_element'.

        Args:
            meas_config_element (dict): The measurement configuration element.

        Returns:
            dict: The 'nr-rrc.measIdToAddModList_tree' from the 'meas_config_element'.

        Raises:
            PcapProcessingException: If 'nr-rrc.measIdToAddModList_tree' cannot be extracted from 'meas_config_element'.
        """
        try:
            meas_id_tree = meas_config_element["nr-rrc.measIdToAddModList_tree"]
        except KeyError as e:
            raise PcapProcessingException(f"Error: Unable to extract 'nr-rrc.measIdToAddModList_tree' from 'nr-rrc."
                                          f"measConfig_element'. Source file: '{self.processed_file_path}. '{e}'")
        else:
            return meas_id_tree

    def _get_meas_id_to_remove(self, meas_config_element):
        """
        Get the measurement IDs to remove from the measurement configuration element.

        Args:
            meas_config_element (dict): The measurement configuration element.

        Returns:
            list: The measurement IDs to remove.

        Raises:
            PcapProcessingException: If 'nr-rrc.measIdToRemoveList_tree' is not found in 'meas_config_element'.
        """
        try:
            removed_meas = meas_config_element["nr-rrc.measIdToRemoveList_tree"]
        except KeyError as e:
            raise PcapProcessingException(f"Error: Unable to extract 'nr-rrc.measIdToRemoveList_tree' from 'nr-rrc."
                                          f"measConfig_element'. Source file: '{self.processed_file_path}. '{e}'")
        else:
            return removed_meas

    def _get_event_report_config_id(self, event_name, report_config_to_add_mod_tree):
        """
        Retrieves the report configuration ID for a given event name from the report_config_to_add_mod_tree.

        Args:
            event_name (str): The name of the event.
            report_config_to_add_mod_tree (dict): The report configuration tree.

        Returns:
            str: The report configuration ID for the specified event.

        Raises:
            PcapProcessingException: If the report configuration ID for the event is not found.
        """
        report_config_ids = {}

        for item in report_config_to_add_mod_tree:
            item_content = report_config_to_add_mod_tree[item]["nr-rrc.ReportConfigToAddMod_element"]
            report_config_id = item_content["nr-rrc.reportConfigId"]
            event_tree = item_content["nr-rrc.reportConfig_tree"]["nr-rrc.reportConfigNR_element"][
                "nr-rrc.reportType_tree"]["nr-rrc.eventTriggered_element"]["nr-rrc.eventId_tree"]
            event_type = list(event_tree.keys())[0]
            report_config_ids[event_type] = report_config_id
        logging.info(f"Found report_config_ids: '{report_config_ids}' in 'nr-rrc.ReportConfigToAddMod_element'")

        if f"nr-rrc.{event_name}_element" in report_config_ids.keys():
            return report_config_ids[f"nr-rrc.{event_name}_element"]
        else:
            raise PcapProcessingException(
                f"Error: Not found 'nr-rrc.{event_name}_element' in 'nr-rrc.ReportConfigToAddMod_element': "
                f"Source file: '{self.processed_file_path}.")

    def _get_event_meas_id_based_on_report_config_id(self, event_name, event_report_config_id, meas_config):
        """
        Retrieves the measurement ID based on the given event name, event report configuration ID,
        and measurement configuration.

        Args:
            event_name (str): The name of the event.
            event_report_config_id (str): The report configuration ID of the event.
            meas_config (dict): The measurement configuration.

        Returns:
            int: The measurement ID corresponding to the given event report configuration ID.

        Raises:
            PcapProcessingException: If the measurement ID corresponding to the event report configuration ID
            is not found.
        """
        meas_ids_tree = self._get_meas_id_to_add_mod(meas_config_element=meas_config)
        meas_ids = {}
        for item in meas_ids_tree:
            item_content = meas_ids_tree[item]['nr-rrc.MeasIdToAddMod_element']
            report_config_id = item_content['nr-rrc.reportConfigId']
            meas_id = item_content['nr-rrc.measId']
            meas_ids[report_config_id] = meas_id

        if event_report_config_id in meas_ids.keys():
            event_meas_id = meas_ids[event_report_config_id]
            logging.info(f"Found measId: '{event_meas_id}' corresponding to reportConfigId '{event_report_config_id}' "
                         f"of {event_name} in 'nr-rrc.MeasIdToAddMod_element'")
            return event_meas_id
        else:
            raise PcapProcessingException(
                f"Error: Not found measId corresponding to reportConfigId '{event_report_config_id}' "
                f"of {event_name} in 'nr-rrc.MeasIdToAddMod_element'. Source file: '{self.processed_file_path}.")


class SgNBAddReqAckAnalyzer(BasePcapKeywords):
    """
    Class for analyzing SgNBAdditionRequestAcknowledge messages in a pcap file.
    """

    def __init__(self):
        super().__init__()
        self.json_path_addition_req_ack = None
        self.display_filter_addition_req_ack = "x2ap.SgNBAdditionRequestAcknowledge_element"

    def get_meas_id_of_event_from_add_req_ack(self, event_name, pcap_name, pcap_dir=None):
        """
        Retrieves the measurement ID of a specific event from the SgNBAdditionRequestAcknowledge messages
        in the specified pcap file.

        Args:
            event_name (str): The name of the event.
            pcap_name (str): The name of the pcap file.
            pcap_dir (str, optional): The directory path of the pcap file. Defaults to None.

        Returns:
            int: The measurement ID of the event.
        """
        meas_config = self._get_meas_config_element(
            msg_json_path=self._get_json_path_addition_req_ack(pcap_name=pcap_name, pcap_dir=pcap_dir),
            msg_display_filter=self.display_filter_addition_req_ack)
        report_config_id = self._get_event_report_config_id(
            event_name=event_name,
            report_config_to_add_mod_tree=self._get_report_config_to_add_mod(
                meas_config_element=meas_config))
        return self._get_event_meas_id_based_on_report_config_id(event_name=event_name,
                                                                 event_report_config_id=report_config_id,
                                                                 meas_config=meas_config)

    def _get_json_path_addition_req_ack(self, pcap_name, pcap_dir=None, gnb_id=0):
        """
        Retrieves the JSON path of the SgNBAdditionRequestAcknowledge messages in the pcap file.

        Args:
            pcap_name (str): The name of the pcap file.
            pcap_dir (str, optional): The directory path of the pcap file. Defaults to None.
            gnb_id (int, optional): The GNB ID. Defaults to 0.

        Returns:
            str: The JSON path of the SgNBAdditionRequestAcknowledge messages.
        """
        pcap_path = os.path.join(pcap_dir if pcap_dir else self.log_path, pcap_name)
        self.json_path_addition_req_ack = self.convert_filtered_pcap_to_json(
            pcap_path=pcap_path,
            display_filter=self.display_filter_addition_req_ack,
            output_path=os.path.join(self.log_path,
                                     re.sub(r".pcap", "", f"{pcap_name}_SgNBAdditionRequestAcknowledge.json")),
            gnb_id=gnb_id)
        return self.json_path_addition_req_ack


class SgNBModReqAckAnalyzer(BasePcapKeywords):
    """
    Class for analyzing SgNBModificationRequestAcknowledge messages in a pcap file.
    """

    def __init__(self):
        """
        Initializes the SgNBModReqAckAnalyzer object.
        """
        super().__init__()
        self.json_path_modification_req_ack = None
        self.display_filter_modification_req_ack = "x2ap.SgNBModificationRequestAcknowledge_element"

    def check_event_meas_id_in_remove_list(self, event_name, event_meas_id, pcap_name=None, pcap_dir=None,
                                           json_path=None):
        """
        Check if the given MeasId of event is present in the list of removed measurement IDs
        of SgNBModificationRequestAcknowledge.

        Args:
            event_name (str): The name of the event.
            event_meas_id (str): The measurement ID to check.
            pcap_name (str, optional): The name of the pcap file. Defaults to None.
            pcap_dir (str, optional): The directory path of the pcap file. Defaults to None.
            json_path (str, optional): The path to the JSON file. Defaults to None.

        Raises:
            PcapProcessingException: If the event_meas_id is not found in the list of removed measurement IDs.
        """
        removed_meas_ids = []
        removed_meas_tree = self._get_meas_id_to_remove(
            meas_config_element=self._get_meas_config_element(
                msg_json_path=json_path if json_path else self._get_json_path_modification_req_ack(pcap_name=pcap_name,
                                                                                                   pcap_dir=pcap_dir),
                msg_display_filter=self.display_filter_modification_req_ack))
        for item in removed_meas_tree:
            item_content = removed_meas_tree[item]
            removed_meas_ids.append(item_content.get("nr-rrc.MeasId"))
        logging.info(f"Found measIdToRemove: '{removed_meas_ids}'")
        if event_meas_id in removed_meas_ids:
            logging.info(f"Passed. '{event_name}' MeasId '{event_meas_id}' was found "
                         f"in nr-rrc.measIdToRemoveList_tree: '{self.processed_file_path}'")
        else:
            raise PcapProcessingException(f"Error: '{event_name}' MeasId '{event_meas_id}' not found in nr-rrc."
                                          f"measIdToRemoveList_tree: '{self.processed_file_path}'")

    def check_if_event_measurement_id_added(self, event_name, event_meas_id, pcap_name=None, pcap_dir=None,
                                            json_path=None):
        """
        Checks if a given event measurement ID is present in the list of added measurement IDs
        of SgNBModificationRequestAcknowledge.

        Args:
            event_name (str): The name of the event.
            event_meas_id (str): The measurement ID to check.
            pcap_name (str, optional): The name of the pcap file. Defaults to None.
            pcap_dir (str, optional): The directory path of the pcap file. Defaults to None.
            json_path (str, optional): The path to the JSON file. Defaults to None.

        Raises:
            PcapProcessingException: If the event measurement ID is not found in the list of added measurement IDs

        Returns:
            None
        """
        added_meas_ids = []
        meas_ids_tree = self._get_meas_id_to_add_mod(
            meas_config_element=self._get_meas_config_element(
                msg_json_path=json_path if json_path else self._get_json_path_modification_req_ack(pcap_name=pcap_name,
                                                                                                   pcap_dir=pcap_dir),
                msg_display_filter=self.display_filter_modification_req_ack))
        for item in meas_ids_tree:
            item_content = meas_ids_tree[item].get('nr-rrc.MeasIdToAddMod_element')
            added_meas_ids.append(item_content.get('nr-rrc.measId'))
        logging.info(f"Found measIdToAddMod: '{added_meas_ids}'")
        if event_meas_id in added_meas_ids:
            logging.info(f"Passed. '{event_name}' MeasId '{event_meas_id}' was found in "
                         f"nr-rrc.measIdToAddModList_tree: '{self.processed_file_path}'")
        else:
            raise PcapProcessingException(f"Error: '{event_name}' MeasId '{event_meas_id}' not found in nr-rrc."
                                          f"measIdToAddModList_tree: '{self.processed_file_path}'")

    def get_meas_id_of_event_from_mod_req_ack(self, event_name, pcap_name=None, pcap_dir=None, json_path=None):
        """
        Retrieves the measurement ID of an event from the SgNBModificationRequestAcknowledge.

        Args:
            event_name (str): The name of the event.
            pcap_name (str, optional): The name of the pcap file. Defaults to None.
            pcap_dir (str, optional): The directory of the pcap file. Defaults to None.
            json_path (str, optional): The path to the JSON file. Defaults to None.

        Returns:
            str: The measurement ID of the event.
        """
        meas_config = self._get_meas_config_element(
            msg_json_path=json_path if json_path else self._get_json_path_modification_req_ack(pcap_name=pcap_name,
                                                                                               pcap_dir=pcap_dir),
            msg_display_filter=self.display_filter_modification_req_ack)
        report_config_id = self._get_event_report_config_id(
            event_name=event_name,
            report_config_to_add_mod_tree=self._get_report_config_to_add_mod(
                meas_config_element=meas_config))
        return self._get_event_meas_id_based_on_report_config_id(event_name=event_name,
                                                                 event_report_config_id=report_config_id,
                                                                 meas_config=meas_config)

    def check_events_in_mod_req_ack(self, pcap_name, pcap_dir=None, events_name=("eventA1", "eventA3", "eventA5")):
        """
        Check if the specified events are present in the SgNBModificationRequestAcknowledge.

        Args:
            pcap_name (str): The name of the pcap file.
            pcap_dir (str, optional): The directory where the pcap file is located. If not provided,
            the log_path attribute will be used.
            events_name (tuple, optional): The names of the events to check.
            Defaults to ("eventA1", "eventA3", "eventA5").

        Raises:
            PcapProcessingException: If any of the events are not found in the SgNBModificationRequestAcknowledge.

        """
        pcap_path = os.path.join(pcap_dir if pcap_dir else self.log_path, pcap_name)
        all_events = self._get_events_from_modification_req_ack(pcap_path=pcap_path)
        for event in events_name:
            if event in str(all_events):
                logging.info(f"Found '{event}' in '{self.display_filter_modification_req_ack}'")
            else:
                raise PcapProcessingException(f"Error: Not found '{event}' in "
                                              f"'{self.display_filter_modification_req_ack}'. File path: '{pcap_path}'")

    def get_from_pcap_measurement_quantities_ssb_for_ho(self, event_name, pcap_name, configuration="rsrp",
                                                        pcap_dir=None, json_path=None):
        """
        Retrieves measurement quantities of events for handover from a pcap file.

        Args:
            event_name (str): The name of the event.
            pcap_name (str): The name of the pcap file.
            configuration (str, optional): The configuration to retrieve (default is "rsrp").
            pcap_dir (str, optional): The directory where the pcap file is located.
            json_path (str, optional): The path to the JSON file.

        Returns:
            dict: A dictionary containing the measurement quantities for the specified event and configuration.
        """
        event_tree = self._get_event_from_report_config_to_add_mod(
            event_name=event_name,
            report_config_to_add_mod_tree=self._get_report_config_to_add_mod(
                meas_config_element=self._get_meas_config_element(
                    msg_json_path=json_path if json_path else self._get_json_path_modification_req_ack(
                        pcap_name=pcap_name, pcap_dir=pcap_dir),
                    msg_display_filter=self.display_filter_modification_req_ack)))
        return self._get_event_measurement_quantities_ssb(event_name=event_name, configuration=configuration,
                                                          event_tree=event_tree)

    def save_message_pairs_to_separate_files(self, msg_pairs, predecessor_name="MEAS_A4_ACTIVATION",
                                             successor_name="MEAS_A4_REMOVAL"):
        """
        Saves the message pairs to separate files.

        Args:
            msg_pairs (zip): A zip object containing pairs of messages.
            predecessor_name (str, optional): Name of the predecessor message. Defaults to "MEAS_A4_ACTIVATION".
            successor_name (str, optional): Name of the successor message. Defaults to "MEAS_A4_REMOVAL".

        Returns:
            dict: A dictionary containing the output file paths for each interval and message name.
        """
        output_files = dict()
        for pair_count, paired_msg in enumerate(msg_pairs):
            interval_name = f'INTERVAL_{pair_count}'
            output_files[interval_name] = dict()
            for msg_count, msg in enumerate(paired_msg):
                msg_name = predecessor_name if msg_count == 0 else successor_name
                filepath = os.path.join(self.log_path, f"{interval_name}_{msg_name}.json")
                output_files[interval_name][msg_name] = filepath
                with open(filepath, 'w') as output_file:
                    json.dump(msg, output_file, indent=4)
        return output_files

    def check_number_of_messages_in_pcap(self, expected_num, pcap_name, pcap_dir=None):
        """
        Check the number of messages in a pcap file and raise an exception if the number is not as expected.

        Args:
            expected_num (int): The expected number of messages.
            pcap_name (str): The name of the pcap file.
            pcap_dir (str, optional): The directory where the pcap file is located. Defaults to None.

        Raises:
            PcapProcessingException: If the number of messages in the pcap file is not equal to the expected number.

        """
        with open(self._get_json_path_modification_req_ack(pcap_name=pcap_name, pcap_dir=pcap_dir)) as all_msg:
            all_msg_list = json.load(all_msg)
            found_num = len(all_msg_list)
            if found_num != int(expected_num):
                raise PcapProcessingException(
                    f"Error: Not found expected number of {self.display_filter_modification_req_ack} in pcap "
                    f"{self.json_path_modification_req_ack}. Found: {found_num}, expected: {expected_num}.")

    def group_messages_in_pairs(self, pcap_name, pcap_dir=None):
        """
        Groups the messages in pairs from the given pcap file.

        Args:
            pcap_name (str): The name of the pcap file.
            pcap_dir (str, optional): The directory where the pcap file is located. Defaults to None.

        Returns:
            zip: A zip object containing pairs of messages.
        """
        with open(self._get_json_path_modification_req_ack(pcap_name=pcap_name, pcap_dir=pcap_dir)) as all_msg:
            all_msg_list = json.load(all_msg)
            return zip(*(iter(all_msg_list),) * 2)

    def _get_event_measurement_quantities_ssb(self, event_tree, event_name="eventA1", configuration="rsrp"):
        """
        Get the measurement quantities for a specific event and SSB configuration.

        Args:
            event_tree (EventTree): The event tree object.
            event_name (str, optional): The name of the event. Defaults to "eventA1".
            configuration (str, optional): The SSB configuration. Defaults to "rsrp".

        Returns:
            list: The measurement quantities associated with the event and SSB configuration.

        Raises:
            PcapProcessingException: If a measurement quantity is not found in the event tree.
            NotImplementedError: If the method to gather associated parameters is not implemented.
        """
        name = f"_get_{event_name.lower()}_measurement_quantities_ssb_{configuration.lower()}"
        if hasattr(self, name):
            get_parameters = getattr(self, name)
            if callable(get_parameters):
                try:
                    meas_quantities = get_parameters(event_tree)
                except KeyError as e:
                    raise PcapProcessingException(f"Error: Not found measurement quantity: '{e}' "
                                                  f"in pcap: '{self.processed_file_path}'")
                else:
                    return meas_quantities
        else:
            raise NotImplementedError(f"Error: Unable to gather associated parameters used to characterize "
                                      f"'{event_name}' measurement for SSB '{configuration.upper()}'. "
                                      f"'{name}' not implemented.")

    def _get_eventa1_measurement_quantities_ssb_rsrp(self, event_tree):
        """
        Get the measurement quantities for event A1 related to SSB RSRP.

        Args:
            event_tree (dict): The event tree containing the relevant information.

        Returns:
            dict: A dictionary containing the measurement quantities for event A1.
                - a1HysteresishoSsbRsrp: The hysteresis value for event A1.
                - a1TimeToTriggerhoSsbRsrp: The time to trigger value for event A1.
                - a1ThresholdhoSsbRsrp: The threshold value for event A1.

        """
        meas_a1 = dict()
        meas_a1["a1HysteresishoSsbRsrp"] = event_tree.get("nr-rrc.hysteresis")
        meas_a1["a1TimeToTriggerhoSsbRsrp"] = self._map_time_to_trigger(event_tree=event_tree)
        meas_a1["a1ThresholdhoSsbRsrp"] = event_tree["nr-rrc.a1_Threshold_tree"][
            "nr-rrc.measTriggerQuantity.rsrp"]
        return meas_a1

    def _get_eventa2_measurement_quantities_ssb_rsrp(self, event_tree):
        """
        Retrieves the measurement quantities related to SSB RSRP for event A2.

        Args:
            event_tree (dict): The event tree containing the relevant information.

        Returns:
            dict: A dictionary containing the measurement quantities for event A2.
                - a2HysteresishoSsbRsrp: The hysteresis value for event A2.
                - a2TimeToTriggerhoSsbRsrp: The time to trigger value for event A2.
                - a2ThresholdhoSsbRsrp: The threshold value for event A2.
        """
        meas_a2 = dict()
        meas_a2["a2HysteresishoSsbRsrp"] = event_tree.get("nr-rrc.hysteresis")
        meas_a2["a2TimeToTriggerhoSsbRsrp"] = self._map_time_to_trigger(event_tree=event_tree)
        meas_a2["a2ThresholdhoSsbRsrp"] = event_tree["nr-rrc.a2_Threshold_tree"][
            "nr-rrc.measTriggerQuantity.rsrp"]
        return meas_a2

    def _get_eventa3_measurement_quantities_ssb_rsrp(self, event_tree):
        """
        Get the measurement quantities for A3 event related to SSB RSRP.

        Args:
            event_tree (dict): The event tree containing the A3 event information.

        Returns:
            dict: A dictionary containing the measurement quantities for A3 event related to SSB RSRP.
                - a3HysteresisSsbRsrp: The hysteresis value for A3 event related to SSB RSRP.
                - a3TimeToTriggerSsbRsrp: The time to trigger value for A3 event related to SSB RSRP.
                - a3OffsetSsbRsrp: The offset value for A3 event related to SSB RSRP.
        """
        meas_a3 = dict()
        meas_a3["a3HysteresisSsbRsrp"] = event_tree.get("nr-rrc.hysteresis")
        meas_a3["a3TimeToTriggerSsbRsrp"] = self._map_time_to_trigger(event_tree=event_tree)
        meas_a3["a3OffsetSsbRsrp"] = event_tree["nr-rrc.a3_Offset_tree"][
            "nr-rrc.measTriggerQuantityOffset.rsrp"]
        return meas_a3

    def _get_eventa5_measurement_quantities_ssb_rsrp(self, event_tree):
        """
        Get the measurement quantities related to SSB RSRP for event A5.

        Args:
            event_tree (dict): The event tree containing the relevant information.

        Returns:
            dict: A dictionary containing the measurement quantities for SSB RSRP.

        """
        meas_a5 = dict()
        meas_a5["a5HysteresisSsbRsrp"] = event_tree.get("nr-rrc.hysteresis")
        meas_a5["a5TimeToTriggerSsbRsrp"] = self._map_time_to_trigger(event_tree=event_tree)
        meas_a5["a5Threshold1SsbRsrp"] = event_tree["nr-rrc.a5_Threshold1_tree"][
            "nr-rrc.measTriggerQuantity.rsrp"]
        meas_a5["a5Threshold2SsbRsrp"] = event_tree["nr-rrc.a5_Threshold2_tree"][
            "nr-rrc.measTriggerQuantity.rsrp"]
        return meas_a5

    def _get_eventa3_measurement_quantities_ssb_rsrq(self, event_tree):
        """
        Get the measurement quantities for event A3 related to SSB RSRQ.

        Args:
            event_tree (dict): The event tree containing the relevant information.

        Returns:
            dict: A dictionary containing the measurement quantities for event A3 related to SSB RSRQ.
                - a3HysteresisSsbRsrq: The hysteresis value for event A3.
                - a3TimeToTriggerSsbRsrq: The time to trigger value for event A3.
                - a3OffsetSsbRsrq: The offset value for event A3 related to SSB RSRQ.
        """
        meas_a3 = dict()
        meas_a3["a3HysteresisSsbRsrq"] = event_tree.get("nr-rrc.hysteresis")
        meas_a3["a3TimeToTriggerSsbRsrq"] = self._map_time_to_trigger(event_tree=event_tree)
        meas_a3["a3OffsetSsbRsrq"] = event_tree["nr-rrc.a3_Offset_tree"][
            "nr-rrc.measTriggerQuantityOffset.rsrq"]
        return meas_a3

    def _get_eventa4_measurement_quantities_ssb_rsrq(self, event_tree):
        """
        Get the measurement quantities related to SSB RSRQ for event A4.

        Args:
            event_tree (dict): The event tree containing the relevant information.

        Returns:
            dict: A dictionary containing the measurement quantities for SSB RSRQ.

        """
        meas_a4 = dict()
        meas_a4["a4HysteresisSsbRsrq"] = event_tree.get("nr-rrc.hysteresis")
        meas_a4["a4TimeToTriggerSsbRsrq"] = self._map_time_to_trigger(event_tree=event_tree)
        meas_a4["a4ThresholdSsbRsrq"] = event_tree["nr-rrc.a4_Threshold_tree"][
            "nr-rrc.measTriggerQuantity.rsrq"]
        return meas_a4

    @staticmethod
    def _map_time_to_trigger(event_tree):
        """
        Perform a mapping operation on the "nr-rrc.timeToTrigger" pcap value into milliseconds format.
        :param event_tree: A dictionary containing the event tree.
        :return: A mapped value.
        """
        mapping_dict = {
            "0": "ms0", "1": "ms40", "2": "ms64", "3": "ms80",
            "4": "ms100", "5": "ms128", "6": "ms160", "7": "ms256",
            "8": "ms320", "9": "ms480", "10": "ms512", "11": "ms640",
            "12": "ms1024", "13": "ms1280", "14": "ms2560", "15": "ms5120",
        }
        return mapping_dict.get(event_tree.get("nr-rrc.timeToTrigger"))

    def _get_event_from_report_config_to_add_mod(self, event_name, report_config_to_add_mod_tree):
        """
        Retrieves the event tree from the nr-rrc.ReportConfigToAddMod_element based on the event name.

        Args:
            event_name (str): The name of the event to search for.
            report_config_to_add_mod_tree (dict): The report configuration to add or modify tree.

        Returns:
            dict: The event tree if found.

        Raises:
            PcapProcessingException: If the event is not found in the nr-rrc.ReportConfigToAddMod_element.
        """
        found_event_tree = None
        for item in report_config_to_add_mod_tree:
            item_content = report_config_to_add_mod_tree[item]["nr-rrc.ReportConfigToAddMod_element"]
            event_tree = item_content["nr-rrc.reportConfig_tree"]["nr-rrc.reportConfigNR_element"][
                "nr-rrc.reportType_tree"]["nr-rrc.eventTriggered_element"]["nr-rrc.eventId_tree"]
            element_name = list(event_tree.keys())[0]
            if event_name in element_name:
                found_event_tree = event_tree[element_name]
                return found_event_tree
        if not found_event_tree:
            raise PcapProcessingException(f"Error: Not found {event_name} in 'nr-rrc.reportConfigToAddModList_tree': "
                                          f"{self.json_path_modification_req_ack}")

    def _get_events_from_modification_req_ack(self, pcap_path):
        """
        Get the nr-rrc.eventId values from the pcap file using the specified display filter.

        Args:
            pcap_path (str): The path to the pcap file.

        Returns:
            str: The nr-rrc.eventId values found in the pcap file.

        Raises:
            PcapProcessingException: If no nr-rrc.eventId values are found in the pcap file.
        """
        events = self.get_field_value_from_pcap(pcap_path=pcap_path,
                                                filter_expression=self.display_filter_modification_req_ack,
                                                field_name="nr-rrc.eventId",
                                                value_format="showname")
        if events:
            logging.info(f"Found nr-rrc.eventId in '{self.display_filter_modification_req_ack}': '{events}'")
            return events
        else:
            raise PcapProcessingException(
                f"Error: Not found any nr-rrc.eventId in '{self.display_filter_modification_req_ack}':"
                f" '{pcap_path}'")

    def _get_json_path_modification_req_ack(self, pcap_name, pcap_dir=None, gnb_id=0):
        """
        Get the path of the JSON file containing the SgNBModificationRequestAcknowledge.

        Args:
            pcap_name (str): The name of the pcap file.
            pcap_dir (str, optional): The directory where the pcap file is located. Defaults to None.
            gnb_id (int, optional): The ID of the gNB. Defaults to 0.

        Returns:
            str: The path of the JSON file containing the SgNBModificationRequestAcknowledge.
        """
        pcap_path = os.path.join(pcap_dir if pcap_dir else self.log_path, pcap_name)
        self.json_path_modification_req_ack = self.convert_filtered_pcap_to_json(
            pcap_path=pcap_path,
            display_filter=self.display_filter_modification_req_ack,
            output_path=os.path.join(self.log_path,
                                     re.sub(r".pcap", "", f"{pcap_name}_SgNBModificationRequestAcknowledge.json")),
            gnb_id=gnb_id)
        return self.json_path_modification_req_ack


class MeasReportAnalyzer(BasePcapKeywords):
    """
    This class represents a MeasReportAnalyzer object that is used to analyze measurement reports in a pcap file.
    """

    def __init__(self):
        super().__init__()
        self.display_filter_meas_report = "nr-rrc.measurementReport_element"

    def get_meas_ids_from_measurement_report(self, pcap_path):
        """
        Retrieves the measurement IDs from the measurement report in the specified pcap file.

        Args:
            pcap_path (str): The path to the pcap file.

        Returns:
            list: A list of measurement IDs extracted from the measurement report.
        """
        return self.get_field_value_from_pcap(pcap_path=pcap_path,
                                              filter_expression=self.display_filter_meas_report,
                                              field_name="nr-rrc.measId",
                                              value_format="showname")


class PcapAnalyzer(SgNBAddReqAckAnalyzer, SgNBModReqAckAnalyzer, MeasReportAnalyzer):
    """
    PcapAnalyzer is a class that provides methods for analyzing pcap files and checking measurement reports.
    """

    def __init__(self):
        super().__init__()

    def check_if_received_measurement_report(self, event_name, pcap_meas_report, pcap_assigned_meas_id, pcap_dir=None,
                                             msg_assigned_meas_id="SgNBModificationRequestAcknowledge"):
        """
        Checks if a measurement report is received for a given event.

        Args:
            event_name (str): The name of the event.
            pcap_meas_report (str): The name of the pcap file containing the measurement report.
            pcap_assigned_meas_id (str): The name of the pcap file containing the assigned measurement ID.
            pcap_dir (str, optional): The directory path of the pcap files. Defaults to None.
            msg_assigned_meas_id (str, optional): The message type for the assigned measurement ID.
            Defaults to "SgNBModificationRequestAcknowledge".

        Returns:
            None
        """
        assigned_meas_id = self.get_assigned_meas_id(event_name=event_name, pcap_name=pcap_assigned_meas_id,
                                                     pcap_dir=pcap_dir, message_type=msg_assigned_meas_id)
        self.check_event_meas_id_in_measurement_report(event_meas_id=assigned_meas_id, event_name=event_name,
                                                       pcap_name=pcap_meas_report, pcap_dir=pcap_dir)

    def check_if_removed_measurement_id(self, event_name, pcap_removed_meas_id, pcap_assigned_meas_id, pcap_dir=None,
                                        msg_assigned_meas_id="SgNBModificationRequestAcknowledge"):
        """
        Checks if a measurement ID is removed for a given event.

        Args:
            event_name (str): The name of the event.
            pcap_removed_meas_id (str): The name of the pcap file containing the removed measurement ID.
            pcap_assigned_meas_id (str): The name of the pcap file containing the assigned measurement ID.
            pcap_dir (str, optional): The directory path of the pcap files. Defaults to None.
            msg_assigned_meas_id (str, optional): The message type for the assigned measurement ID.
            Defaults to "SgNBModificationRequestAcknowledge".

        Returns:
            None
        """
        assigned_meas_id = self.get_assigned_meas_id(event_name=event_name, pcap_name=pcap_assigned_meas_id,
                                                     pcap_dir=pcap_dir, message_type=msg_assigned_meas_id)
        self.check_event_meas_id_in_remove_list(event_name=event_name, event_meas_id=assigned_meas_id,
                                                pcap_name=pcap_removed_meas_id, pcap_dir=pcap_dir)

    def get_assigned_meas_id(self, event_name, pcap_name, message_type, pcap_dir=None):
        """
        Gets the assigned measurement ID for a given event and message type.

        Args:
            event_name (str): The name of the event.
            pcap_name (str): The name of the pcap file containing the assigned measurement ID.
            message_type (str): The message type for the assigned measurement ID.
            pcap_dir (str, optional): The directory path of the pcap file. Defaults to None.

        Returns:
            assigned_meas_id (str): The assigned measurement ID.
        """
        if message_type == "SgNBModificationRequestAcknowledge":
            assigned_meas_id = self.get_meas_id_of_event_from_mod_req_ack(
                event_name=event_name, pcap_name=pcap_name, pcap_dir=pcap_dir)
        elif message_type == "SgNBAdditionRequestAcknowledge":
            assigned_meas_id = self.get_meas_id_of_event_from_add_req_ack(
                event_name=event_name, pcap_name=pcap_name, pcap_dir=pcap_dir)
        else:
            raise PcapProcessingException(f"Error: Given unsupported message_type: {message_type}. Supported only: "
                                          f"'SgNBModificationRequestAcknowledge' and 'SgNBAdditionRequestAcknowledge'")
        return assigned_meas_id

    def check_event_meas_id_in_measurement_report(self, event_meas_id, event_name, pcap_name, pcap_dir=None):
        """
        Checks if the event's measurement ID is present in the measurement report.

        Args:
            event_meas_id (str): The measurement ID of the event.
            event_name (str): The name of the event.
            pcap_name (str): The name of the pcap file containing the measurement report.
            pcap_dir (str, optional): The directory path of the pcap file. Defaults to None.

        Returns:
            None
        """
        pcap_path = os.path.join(pcap_dir if pcap_dir else self.log_path, pcap_name)
        meas_id_from_report = self.get_meas_ids_from_measurement_report(pcap_path=pcap_path)
        if event_meas_id in str(meas_id_from_report):
            logging.info(f"Expected nr-rrc.measId '{event_meas_id}' of {event_name} matched with nr-rrc.measId "
                         f"from nr-rrc.measurementReport_element: '{meas_id_from_report}'")
        else:
            raise PcapProcessingException(f"Error: Not found nr-rrc.measId: '{event_meas_id}' of {event_name} "
                                          f"in nr-rrc.measurementReport_element '{meas_id_from_report}'. "
                                          f"Source file: '{pcap_path}'")


class PcapProcessingException(Exception):
    """
    Exception raised for errors that occur during pcap processing.
    """
    pass
