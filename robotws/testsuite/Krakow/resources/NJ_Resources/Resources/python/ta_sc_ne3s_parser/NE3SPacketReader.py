"""
:copyright: Nokia Networks
:author: Sebastian Zarebski
:contact: sebastian.zarebski@nokia.com

[Documentation] LIBRARY:ta_sc_ne3s_parser

Metadata:
| Version | Status  | Date | Author  | Change Notification |
| 0.1 | DRAFT | 15.06.2018| Sebastian Zarebski | Initial version |
| 0.2 | DRAFT | 05.09.2018| Sebastian Zarebski | Additional changes |
| 0.3 | DRAFT | 23.01.2019| Sebastian Zarebski | Additional changes |
End of Metadata

As an output we should consider JSON file with NE3S-valuable packets data processed for further use.
"""
import random
import string
from scapy.all import *
import os
import collections
import xml.etree.ElementTree as ET
import json
import io
from datetime import datetime as dt
from robot.api import logger


class Ne3SPacketReader(object):
    """ Loads tcpdump data from pcap file and checks for NE3S messages (by iterating frame by frame), to get packet
        information and consisting XML files inside them. Creates JSON files as the output.

    Attributes:
        :param file_path: A string representing path to the pcap file
        :param run: A boolean describing decision if processing should be run just after a class object creation
    """

    def __init__(self, input_file_path, output_files_directory):
        """ Return a new PacketReader object
        Check preconditions, create output directory if needed, initialize variables and run processing
        """

        # check if file_path argument is provided and points to a file
        if not len(input_file_path):
            logger.error('Path to file cannot be empty')
        try:
            if not input_file_path.endswith(('pcap', 'pcapng')):
                logger.error('File type not supported - use pcap or pcapng files only')
        except Exception as e:
            if not input_file_path.endswith(('pcap'.encode('utf-8'), 'pcapng'.encode('utf-8'))):
                logger.error('File type not supported - use pcap or pcapng files only')

        if not os.path.exists(input_file_path):
            logger.error('File {} does not exist'.format(input_file_path))

        # initialize variables
        self.input_file_path = input_file_path
        self.output_files_directory = output_files_directory
        self.timestamp = dt.now().strftime("%y%m%d_%H%M")
        self.path_to_json_file_with_results = ''
        self.output_file_name = "NE3S_parser_results_" + self.timestamp + ".json"
        self.bonding_map = {}

        self.raw_data = {}
        self.tmp_packet_data = collections.OrderedDict()
        self.clean_packet_data = collections.OrderedDict()

        # make sure output_files directory exist, if not - then create it
        if not os.path.exists(self.output_files_directory):
            os.makedirs(self.output_files_directory)

        # read provided file into memory
        logger.info('NE3SPacketReader initialization done, collecting data')
        # sniff(prn=self.collect_frames, offline=self.input_file_path) # old method - high memory consumption!
        with PcapReader(self.input_file_path) as pr:
            for p_no, pkt in enumerate(pr):
                self.tmp_packet_data.setdefault(p_no, collections.OrderedDict())
                if pkt.haslayer(Raw):  # check if packet contains with raw data layer
                    self.collect_frames(p_no, pkt)

        logger.info('Processing collected frames')
        self.process_collected_frames()
        self.save_output_json()
        logger.info('Finished! Reader: {} packets saved'.format(str(len(self.clean_packet_data.keys()))))

    def collect_frames(self, pkt_no, pkt):
        """
        Change history:
        Change raw_body = str(pkt.getlayer(Raw).load) to raw_body = pkt.getlayer(Raw).load when do python2->3 migration
        Change data_lines = raw_body.splitlines() to data_lines = raw_body.decode(errors='ignore').splitlines() when do
        python2->3 migration

        :param pkt_no:
        :param pkt:
        :return:
        """
        try:
            ack_value_link = int(pkt.getlayer(TCP).ack)
        except AttributeError:
            logger.debug('Packet {} has ACK value equal to None!'.format(pkt_no))
            ack_value_link = 0
            pass

        # get and clean data from a packet body
        clean_body_data = []
        raw_body = pkt.getlayer(Raw).load
        data_lines = raw_body.decode(errors='ignore').splitlines()

        # process frame data type
        http_types = list(filter(re.compile(r"(HTTP)+(\/1\.1)+.*\d{3}").match, data_lines))
        post_types = list(filter(re.compile("(POST)+.*(HTTP/1.1)+").match, data_lines))
        mime_form_types = list(filter(re.compile("(--==)+(.*)(==)+(--)*").match, data_lines))

        data_type = 'NOT_SET'

        if len(mime_form_types):
            # BOLD GENERALIZATION
            # double equality sign is connected with MIME form, which actually and USUALLY holds
            # data of notifications - below line SHOULD be IMPROVED
            data_type = 'POST /axis2/services/NE3SOperationNotificationService HTTP/1.1'
        if len(post_types):
            data_type = re.sub(r'[^\x00-\x7f]', r'', post_types[0])  # for non-ascii characters
        if len(http_types):
            data_type = re.sub(r'[^\x00-\x7f]', r'', http_types[0])  # for non-ascii characters

        # get packet time in UTC format
        utc_arrival_time = dt.utcfromtimestamp(pkt.time).strftime("%Y-%m-%d %H:%M:%S.%f")

        # check if string contains hexadecimal values and if values are printable:
        for line in data_lines:
            printable = set(string.printable) - set("\x0b\x0c")
            is_hex = any(char not in printable for char in line)

            if 'application/octet-stream' in line or is_hex:
                pass
            else:
                line = line.replace("\t", "")
                if len(line) > 0 and not line.startswith('Content-'):
                    left_rule = r'<+\/?[A-aZ-z\:\"\_\.]*'
                    right_rule = r'[A-aZ-z\:\"\_\.]*\"?\/?>+'
                    drop_rule = r'[^[\+\&\#\%\(\)\{\}\*\;\,\~\?]]'
                    if (re.search(left_rule, line) or re.search(right_rule, line)) and not re.search(drop_rule, line):
                        clean_body_data.append(line)

        if len(clean_body_data) > 0 or data_type != 'NOT_SET':
            if ack_value_link in self.bonding_map.values():  # check for parents and bond data to them
                bond_to_frame = [parent for parent, link in self.bonding_map.items() if link == ack_value_link][0]
                # bond to parent frame values
                self.tmp_packet_data[bond_to_frame]['bonded_frames'].append(pkt_no)
                self.tmp_packet_data[bond_to_frame]['xml_data'].extend(clean_body_data)
            else:
                self.bonding_map[pkt_no] = ack_value_link
                # save packet details
                self.tmp_packet_data[pkt_no]['ack'] = ack_value_link
                self.tmp_packet_data[pkt_no]['sequence'] = str(pkt.getlayer(TCP).seq)
                self.tmp_packet_data[pkt_no]['time_UTC'] = utc_arrival_time
                self.tmp_packet_data[pkt_no]['source'] = str(pkt.getlayer(IP).src)
                self.tmp_packet_data[pkt_no]['source_port'] = pkt.getlayer(TCP).sport
                self.tmp_packet_data[pkt_no]['destination'] = str(pkt.getlayer(IP).dst)
                self.tmp_packet_data[pkt_no]['destination_port'] = pkt.getlayer(TCP).dport
                self.tmp_packet_data[pkt_no]['data_type'] = data_type
                self.tmp_packet_data[pkt_no]['xml_data'] = clean_body_data
                self.tmp_packet_data[pkt_no]['bonded_frames'] = []

    def process_collected_frames(self):
        for p_no, p_data in self.tmp_packet_data.items():
            # drop the frame that is not HTTP or POST
            if 'data_type' in p_data.keys() and p_data['data_type'].startswith(('HTTP', 'POST')):
                clean_xml_data, xml_files = self.generate_xml_data(p_data['xml_data'])
                self.clean_packet_data[p_no] = p_data  # append and save post-processed data
                self.clean_packet_data[p_no]['xml_data'] = clean_xml_data
                # save raw XML data to external files
                for file_no, output_data in enumerate(xml_files):
                    output_xml_tree = ET.XML(output_data)
                    output_file = ET.tostring(output_xml_tree)
                    output_xml_file_name = 'frame_' + str(p_no) + '_' + str(file_no) + '.xml'
                    if not os.path.exists(self.output_files_directory + '/NE3S_parser_frames/'):
                        os.makedirs(self.output_files_directory + '/NE3S_parser_frames/')
                    with open(self.output_files_directory + '/NE3S_parser_frames/' + output_xml_file_name, "w") as f:
                        f.write(output_file.decode())
                        logger.debug('Packet no {0}, saving XML to {1}'.format(p_no, output_xml_file_name))

        logger.info('Finishing postprocessing of packets data')

    def generate_xml_data(self, raw_xml_data):
        """ Parse collected XML files into flattened key-value pairs for output JSON file.

        :param raw_xml_data: A list with XML files taken from packets
        :return: list with flattened data that can be printed directly into output JSON file.
        """

        def elementtree_to_dict(element_tree_obj):
            """ Transform ElementTree object into dictionary

            :param element: ElementTree object
            :return: dictionary
            """
            dict_nodes = dict()
            text = getattr(element_tree_obj, 'text', None)
            if text is not None:
                dict_nodes['text'] = text
                dict_nodes.update(element_tree_obj.items())  # element's attributes

            child_nodes = {}
            for element in element_tree_obj:  # element's children
                child_key = str(re.sub(r"\s*{.*}\s*", "", element.tag.strip()))  # remove namespace
                child_nodes.setdefault(child_key, []).append(elementtree_to_dict(element))

            # convert all single-element lists into non-lists
            for key, value in child_nodes.items():
                if len(value) == 1:
                    child_nodes[key] = value[0]
            dict_nodes.update(child_nodes.items())

            return dict_nodes

        def make_dict_flatten(d, parent_key='', sep='--'):
            """ Make the provided dictionary flattened by joining all parent tags into one string.

            :param d: A dictionary that has to be flattened
            :param parent_key: A string that describes a parent (preceding) key
            :param sep: A string used for separating joined keys
            :return: dictionary with flattened items
            """
            items = []
            bag_of_used_keys = {}
            for k, v in d.items():
                new_key = parent_key + sep + k if parent_key else k
                new_key = new_key.replace('Body' + sep, '').replace(sep + 'text', '')
                if k == 'text' and v.startswith('<message'):
                    to_be_flat = []
                    v_root = ET.fromstring('<top>' + v + '</top>')
                    for child in v_root.iter('p'):
                        if child.attrib['name'] == 'details':
                            to_be_flat.append(child.text)
                    v = [to_be_flat]
                # if object can be flattened (is a dict, not string or list)
                if isinstance(v, collections.MutableMapping):
                    items.extend(make_dict_flatten(v, new_key, sep=sep).items())
                elif isinstance(v, list) and len(v) > 1:  # list of dicts, for example - CM parameters
                    for parameter in v:
                        for param_k, param_data in parameter.items():
                            if isinstance(param_data, str):
                                if param_k == "text" or param_k == "name":
                                    new_key = parent_key + sep + k if parent_key else k
                                    new_key = new_key.replace('Body' + sep, '').replace(sep + 'text', '')

                                    last_part = new_key.split(sep)[-1]
                                    to_add = "p"
                                    if param_k == "name":
                                        to_add += "--name"
                                    new_key = new_key.replace(sep + last_part, '') + sep + to_add
                                    bag_of_used_keys.setdefault(new_key, 0)

                                    if any(new_key.startswith(k) for k in bag_of_used_keys.keys()):
                                        bag_of_used_keys[new_key] += 1
                                        new_key += sep + str(bag_of_used_keys[new_key])

                                    items.append((new_key, param_data))
                                continue

                            if isinstance(param_data, dict):
                                if param_k in ['extension', 'item']:
                                    if param_data.keys():
                                        lift_key = list(param_data.keys())[0]
                                        param_data = param_data[lift_key]
                                param_data = [param_data] if isinstance(param_data, dict) else param_data

                            for p_values in param_data:
                                if any(key in p_values for key in ['text', 'name']):
                                    new_key = parent_key + sep + k if parent_key else k
                                    new_key = new_key.replace('Body' + sep, '').replace(sep + 'text', '')

                                    last_part = new_key.split(sep)[-1]
                                    try:
                                        to_add = p_values['name']
                                    except KeyError:
                                        to_add = param_k

                                    #########################################################
                                    # Exception to reregister operation
                                    #########################################################
                                    if new_key == "reregister--extensions" and param_k == "attributes":
                                        new_key += "--attributes"
                                        bag_of_used_keys.setdefault(new_key+"--name", 0)
                                        bag_of_used_keys[new_key+"--name"] += 1
                                        bag_of_used_keys.setdefault(new_key + "--value", 0)
                                        bag_of_used_keys[new_key + "--value"] += 1

                                        items.append((new_key+"--name"+("" if bag_of_used_keys[new_key+"--name"] == 1
                                                                        else
                                                                        "--"+str(bag_of_used_keys[new_key+"--name"])),
                                                      p_values['name']['text']))
                                        items.append((new_key+"--value"+("" if bag_of_used_keys[new_key+"--value"] == 1
                                                                         else "--"+str(bag_of_used_keys
                                                                                       [new_key+"--value"])),
                                                      p_values['value']['text']))
                                        continue

                                    if new_key == "reregister--extensions" and param_k == "type":
                                        new_key += "--type"
                                        bag_of_used_keys.setdefault(new_key, 0)
                                        bag_of_used_keys[new_key] += 1

                                        items.append((new_key+("" if bag_of_used_keys[new_key] == 1
                                                               else "--"+str(bag_of_used_keys[new_key])),
                                                      p_values['text']))
                                        continue

                                    #########################################################

                                    new_key = new_key.replace(sep + last_part, '') + sep + to_add
                                    bag_of_used_keys.setdefault(new_key, 0)  # set first ID for key as 1

                                    if any(new_key.startswith(k) for k in bag_of_used_keys.keys()):
                                        bag_of_used_keys[new_key] += 1
                                        new_key += sep + str(bag_of_used_keys[new_key])

                                    items.append((new_key, p_values['text']))
                else:
                    items.append((new_key, v))

            if not d:
                items.append((parent_key, 'value_not_set'))

            return collections.OrderedDict(items)

        xml_lists = {}
        key = 0
        for item in raw_xml_data:
            xml_lists.setdefault(key, '')
            xml_lists[key] += re.sub(r'\t', '', item.strip())
            if re.match(r'(.*)envelope>', item, re.IGNORECASE):
                key += 1

        xml_files = []
        flat_xml_dicts = []
        # Change xml_lists.iteritems() to xml_lists.items() when do python2->3 migration
        for xml_no, xml_value in xml_lists.items():
            try:
                # enforce that tags are consistent - hot fix for adding blank spaces before tag attributes
                xml_value_orig = xml_value
                xml_value = re.sub(r"(\w|\")(name|version|distName|class|operation|create)", r"\1 \2", xml_value)
                xml_value = '<' + ''.join(re.findall(r'<(.*)>', xml_value)) + '>'  # remove unclosed tags
                xml_tree = ET.fromstring(xml_value)
                flat_xml_dicts.append(make_dict_flatten(elementtree_to_dict(xml_tree)))
                xml_files.append(xml_value)
            except ET.ParseError:
                logger.warn('Parsing failed on content:\n{}'.format(xml_value_orig))
                pass
        return flat_xml_dicts, xml_files

    def save_output_json(self):
        """ Save provided data into output JSON (we force it to be formatted as unicode!)

        :param xml_data: dictionary with processed data that we want to be saved
        :return: nothing
        """

        self.path_to_json_file_with_results = self.output_files_directory + self.output_file_name

        with io.open(self.path_to_json_file_with_results, 'w') as outfile:
            str_ = json.dumps(self.clean_packet_data, indent=4, separators=(',', ': '), ensure_ascii=False)
            outfile.write(str(str_))

        logger.info('Output file saved as: {}'.format(self.output_files_directory + 'data.json'))

    def get_path_to_json_file_with_results(self):
        return self.path_to_json_file_with_results
