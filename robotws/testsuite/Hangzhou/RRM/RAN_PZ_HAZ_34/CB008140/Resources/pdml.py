from taf.analyzer.pdml import PdmlReader


def pdml11():
    """
    start vonr call by AT command
    :param ue_alias: <str> store ue by ue_alias
    :return <list>
    """
    with open("/opt/workspace/CRT/Master/Case_Logs/debug.pdml", "rb") as fh:
        pdml_reader = PdmlReader(file_obj=fh)
        packets = []
        for pdml_entry in pdml_reader:
            packets.append(pdml_entry)
    packet = packets[0]
    print(packet.packet.keys())
    print(packet.packet.paths())
