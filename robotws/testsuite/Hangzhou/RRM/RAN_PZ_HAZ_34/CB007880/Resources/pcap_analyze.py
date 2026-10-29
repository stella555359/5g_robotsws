from taf.analyzer.pcap import pcap

pcap = pcap()


def get_field_value_by_xpath_for_specific_packets(
        log_file_path, dict_field_xpath, pcap_parser=None, filter_for_package=None, attribute="show"):
    """ Author: Ding Binmei
        Description: Get field value by xpath for specific packets in pcap file,
        support for multiple fields with it's xpaths provided
        :param log_file_path: The path of pcap file
        :param dict_field_xpath: A dictionary, key is field name, value is xpath of the field
        :param pcap_parser: The pcap parser
        :param filter_for_package: The filter for specific packets
        :param attribute: The attribute of the field, default is "show". Supported values: show, showname, value
        :return: A list of dictionary, each dictionary contains field name and its value for one packet
    """
    pcap.setup(infile=log_file_path, display_filter=None, alias=pcap_parser)
    packets = pcap.get_packets(filter=filter_for_package, override_original_expression=True, pcap_parser=pcap_parser)
    field_values = []
    for packet in packets:
        dict_field_value_for_packet = {}
        for field_name in dict_field_xpath.keys():
            field_name = field_name.strip()
            try:
                field_value = packet.get_field_value_by_xpath(dict_field_xpath[field_name], attribute)
            except KeyError:
                field_value = None
            dict_field_value_for_packet[field_name] = field_value
        field_values.append(dict_field_value_for_packet)
    return field_values
