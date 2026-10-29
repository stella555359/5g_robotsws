"""
:copyright: Nokia Networks
:author: Paulina Karpf Matoga  <paulina.karpf_matoga@nokia.com>
:author: Mateusz Matusik  <mateusz.matusik@nokia.com>
"""

import xml.etree.ElementTree as et


def verify_capability_segment_message_in_cell_trace(message_name, source_file, num_of_exp_occur):
    f = open(source_file, "r")
    captured_message = f.read()
    pdml = et.fromstring(captured_message)
    messages = []
    for packet in pdml.findall('packet'):
        message = packet.findall(".//field[@showname='asn1-MsgId: 216']")
        if len(message) > 0:
            for item in message:
                messages.append(item)

    # display_path_to_node(captured_message, message_name)
    assert int(len(messages)) == int(num_of_exp_occur), "Message {} expected to be present {} times in trace was " \
                                                        "present {} times".format(message_name, num_of_exp_occur,
                                                                                  len(messages))


def verify_reassembled_capabilities_message_in_cell_trace(message_name, source_file, num_of_exp_occur):
    f = open(source_file, "r")
    captured_message = f.read()
    pdml = et.fromstring(captured_message)
    messages = []
    for packet in pdml.findall('packet'):
        message = packet.findall(".//field[@showname='ProtocolIE-Field']//"
                                 "field[@name='nr-rrc.ULDedicatedMessageSegment.reassembled_data']")
        if len(message) > 0:
            for item in message:
                messages.append(item)

    assert int(len(messages)) == int(num_of_exp_occur), "Message {} expected to be present {} times in trace was " \
                                                        "present {} times".format(message_name, num_of_exp_occur,
                                                                                  len(messages))


def verify_ue_capabilities_in_cell_trace(message_name, source_file, num_of_exp_occur):
    f = open(source_file, "r")
    captured_message = f.read()
    pdml = et.fromstring(captured_message)
    messages = []
    for packet in pdml.findall('packet'):
        message = packet.findall(".//field[@showname='asn1-MsgId: 44']")
        if len(message) > 0:
            for item in message:
                messages.append(item)

    assert int(len(messages)) == int(num_of_exp_occur), "Message {} expected to be present {} times in trace was " \
                                                        "present {} times".format(message_name, num_of_exp_occur,
                                                                                  len(messages))


def verify_ue_capabilites_in_f1ap_from_pdml_pcap(message_name, source_file, num_of_exp_occur):
    f = open(source_file, "r")
    captured_message = f.read()
    pdml = et.fromstring(captured_message)
    messages = []
    for packet in pdml.findall('packet'):
        message = packet.findall(".//field[@showname='ProtocolIE-Field']//field[@name='nr-rrc.c1']/"
                                 "field[@showname='"+message_name+"']")
        if len(message) > 0:
            for item in message:
                messages.append(item)

    assert int(len(messages)) == int(num_of_exp_occur), "Message {} expected to be present {} times in trace was " \
                                                        "present {} times".format(message_name, num_of_exp_occur,
                                                                                  len(messages))


def display_path_to_node(source_file, message_name):
    pdml = et.ElementTree(et.fromstring(source_file))
    for node in pdml.findall(".//field[@showname='"+message_name+"']"):
        for node_path, n in node_walk(pdml.getroot()):
            if n is node:
                attrib_path = "/".join(["."] + [n.tag + ":" + n.attrib['showname'] if 'showname' in n.attrib else n.tag
                                                for n in node_path[1:]] + [n.attrib['showname']])
                print(attrib_path, node)


def node_walk(pdml_bis: et.Element):
    path_to_node = []
    node_stack = [pdml_bis]
    while node_stack:
        node = node_stack[-1]
        if path_to_node and node is path_to_node[-1]:
            path_to_node.pop()
            node_stack.pop()
            yield path_to_node, node
        else:
            path_to_node.append(node)
            for child in reversed(node):
                node_stack.append(child)
