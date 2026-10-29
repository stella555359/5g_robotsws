from lxml import etree as ET
from taf.analyzer.pdml.packet import Packet
from taf.analyzer.pdml import PdmlReader
from taf.analyzer.pdml.pdml_log_entry import PdmlLogEntry
import re


def compare_slots(slot1, slot2):
    """
    Check if slot1 and slot2 have different elements

    :param list slot1
    :param list slot2

    :return:    True if elements in slot1 are different from elements in slot2. False otherwise.

    """
    common_elements = set(slot1) & set(slot2)
    return not common_elements


def get_max_slot_from_slot_list(slot_list):
    """
    Extract slot numbers from list containing slot messages and returns the max number

    :param list slot_list: list with string elements (messages from pcap)

    :return: max slot number
    """
    slots = [re.search("([0-9]+)$", mess).group(0) for mess in slot_list]
    slots_int = [int(x) for x in slots]
    return max(slots_int)


def get_min_slot_from_slot_list(slot_list):
    """
    Extract slot numbers from list containing slot messages and returns the max number

    :param list slot_list: list with string elements (messages from pcap)

    :return: max slot number
    """
    slots = [re.search("([0-9]+)$", mess).group(0) for mess in slot_list]
    slots_int = [int(x) for x in slots]
    return min(slots_int)


def change_slots_to_messages(nr_slots, slot_parameter):
    """
    Convert variable nr_slots to list of slot messages with these numbers

    :param list nr_slots: list of integers
    :param str slot_parameter: string that will be before integer (eg: 'slots320')

    :return: list with slot messages
    """
    return [slot_parameter+': '+str(x) for x in nr_slots]


def unique(seq):
    """
    Returns unique elements of given list without sorting
    """
    seen = set()
    seen_add = seen.add
    return [x for x in seq if not (x in seen or seen_add(x))]


def pop_from_list(list_):
    return list_.pop()


def get_frame_info(xml):
    """
    Returns frame info of given xml packet
    """
    in_frame = False
    for line in xml:
        if "<frame showname" in line:
            line = line + "\n"
            frame = [line]
            in_frame = True
            continue
        if in_frame:
            line = line + "\n"
            frame.append(line)
            if "</frame" in line:
                return frame


class pdml(object):
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    @staticmethod
    def get_pdml_entries(file_name, field_name=None, attrib_name=None, attrib_value=None, timezone="utc"):
        """ Returns PDML entries which matches`attribute_value` of an attribute in `field_name`

        Usage example:

            get_pdml_entries("LteS1apConextSetupWithDedBearer.pdml","frame.number","show","26")

        :param str file_name: pdml file path
        :param str field_name: field name inside packet Eg: "MME_UE_S1AP_ID" or also in regex like: "(?i)mme.*s1ap"
        :param str attrib_name: attribute name inside field
        :param str attrib_value: value of attribute
        :param str timezone: timezone offset

        :return: list of pdml entries
        """
        pdml_log_entries = []
        with open(file_name, 'rb') as file_obj:
            for pdml_entry in PdmlReader(timezone=timezone, file_obj=file_obj):
                for field_value in pdml_entry.packet.findall(field_name):
                    if getattr(field_value, attrib_name) == attrib_value:
                        if pdml_entry not in pdml_log_entries:
                            pdml_log_entries.append(pdml_entry)
        return pdml_log_entries

    @staticmethod
    def get_specific_entries_from_pdml_entries(pdml_entries, field_name=None, timezone="utc"):
        """ Returns objects with its content from given PDML entries which matches `field_name`

        :param pdml_entries: list of PdmlEntry objects
        :param str field_name: field name inside packet Eg: "MME_UE_S1AP_ID" or also in regex like: "(?i)mme.*s1ap"
        :param str attrib_name: attribute name inside field
        :param str attrib_value: value of attribute
        :param str timezone: timezone offset

        :return: list of pdml entries
        """
        packets = []
        for pdml_entry in pdml_entries:
            string = str(pdml_entry.packet).splitlines()
            in_field = False
            frame = get_frame_info(string)
            for line in string:
                if "<"+field_name in line:
                    line = line+"\n"
                    in_field = True
                    packet_lines = ["<packet>\n"] + frame + [line]
                    continue
                if in_field:
                    line = line + "\n"
                    packet_lines.append(line)
                    if "</"+field_name in line:
                        in_field = False
                        packet_lines.append("</packet>")
                        packet = ET.fromstring("".join(packet_lines))
                        pkt = Packet(xml_packet=packet)
                        entry = PdmlLogEntry.parse(timezone=timezone, packet=pkt)
                        packets.append(entry)
        return packets

    @staticmethod
    def get_attrib_value_from_pdml_entries(pdml_entries, field_names, attrib_name, use_set=True):
        """ Returns attribute values of PDML entries for specified field name

        Usage example:
         - Collect PDML entries using `**get_pdml_entries()**`
         - then use pdml entries collected in 1st step with this function to get attribite value.

            pdml_entries = get_pdml_entries("LteS1apConextSetupWithDedBearer.pdml","frame.number","show","26")
            attrib_values = get_attrib_value_from_pdml_entries(pdml_entries, "frame.number", "showname")

        :param pdml_entries: list of PdmlEntry objects
        :param str/list field_names: field name of a packet
        :param str attrib_name: attribute name of a field
        :param bool use_set: apply 'set' on returning list

        :return: list of attribute values.
        """
        if not isinstance(field_names, list):
            field_names = [field_names]
        attrib = [
            getattr(element, attrib_name)
            for pdml_entry in pdml_entries for field in field_names for element in pdml_entry.packet.findall(field)
            ]
        if use_set:
            return unique(attrib)
        return attrib

    @staticmethod
    def get_separately_attrib_value_from_pdml_entries(pdml_entries, field_names, attrib_name):
        """ Similar to the function above but each element of returning list is a list of all
            attribute values of PDML entry for specified field names

        :param pdml_entries: list of PdmlEntry objects
        :param str/list field_names: field name of a packet
        :param str attrib_name: attribute name of a field

        :return: list of attribute values.
        """
        if not isinstance(field_names, list):
            field_names = [field_names]
        attrib = []
        for pdml_entry in pdml_entries:
            new_attrib = [
                getattr(element, attrib_name)
                for field in field_names for element in pdml_entry.packet.findall(field)
                ]
            if len(new_attrib) > 1:
                attrib.append(new_attrib)
            else:
                attrib.extend(new_attrib)
        return attrib

    @staticmethod
    def get_msg(file_name, field_name_list, use_set=True):
        """ Returns messages of pdml file for specified field names.

        :param str file_name: PDML file name
        :param list field_name_list: field name inside packet
        :param bool use_set: apply 'set' on returning list

        :return: list of messages from given field types

        """
        with open(file_name, 'rb') as file_obj:
            actual_msc_list = []
            for pdml_entry in (PdmlReader(file_obj=file_obj)):
                for field_name in field_name_list:
                    for value in pdml_entry.packet.findall(field_name):
                        actual_msc_list.append(value.showname)
            if use_set:
                return sorted(list(set(actual_msc_list)))
            else:
                return sorted(list(actual_msc_list))

    @staticmethod
    def get_entry_time(pdml_entry):
        """
        Returns relative time of the given packet with 2 digits precision
        """
        string = str(pdml_entry.packet).splitlines()
        frame = get_frame_info(string)
        regex = re.compile(".*frame.time_relative.*")
        time_line = list(filter(regex.match, frame))
        time = re.search(r'(?<=show=")[0-9]+\.[0-9]{2}', time_line[0])
        return float(time.group(0))
