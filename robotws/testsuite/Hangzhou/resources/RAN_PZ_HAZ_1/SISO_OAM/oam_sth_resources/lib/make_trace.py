import xml.etree.ElementTree as ET


def replace_xml(cell_id, trace_id, dcap_ip, dcap_port):
    with open(r"after.xml", 'r') as xml_trace:
        trace = xml_trace.read()

    template = ET.parse(r"after.xml")

    trace = trace.replace('%MTRACE_ID%', trace_id)
    trace = trace.replace('%DCAP_IP%', dcap_ip)
    trace = trace.replace('%LNCELL_ID%', cell_id)
    trace = trace.replace('%DCAP_PORT%', dcap_port)
    return trace


def insert_traces(original, sample, output_scf):
    template = ET.parse(original)
    # template2 = ET.parse(sample)
    root = template.getroot()
    # after = template2.getroot()
    for child in root:
        child.append(sample)
    tree = ET.ElementTree(root)
    ET.register_namespace('', "raml21.xsd")
    return tree.write(output_scf, xml_declaration=True, encoding='utf-8', method='xml')


def generate_trace_scf(trace_number):
    text = []
    for trace in range(0, trace_number):
        modifyed = replace_xml(str(int(trace / 6)), str(trace), '10.97.92.238', '49151')
        text.append(modifyed)
    insert_traces("original_sample_2.xml", ET.fromstring(text[0]), "test.xml")
    for item in text[1:]:
        print(item)
        insert_traces("test.xml", ET.fromstring(item), "test.xml")


def generate_trace_scf_forgivenRmod():
    text = []
    cell_list = [1, 2, 3, 4, 5]
    each_cell_trace = 1
    trace_num = 0
    for trace in range(0, len(cell_list)):
        while each_cell_trace >= 1:
            modifyed = replace_xml(cell_list[trace], str(trace_num), '10.97.92.238', '49151')
            text.append(modifyed)
            trace_num = trace_num + 1
            each_cell_trace = each_cell_trace - 1
    insert_traces("original_sample_2.xml", ET.fromstring(text[0]), "test.xml")
    for item in text[1:]:
        print(item)
        insert_traces("test.xml", ET.fromstring(item), "test.xml")


if __name__ == '__main__':
    pass
