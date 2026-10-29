import os

from taf.analyzer.pdml import PdmlReader, pdml


def convert_pcap_to_pdml(pcap_file):
    os.system("tshark -T pdml -r {} > {}.xml".format(pcap_file, pcap_file.split(".pcap")[0]))
    pdml_file = "{}.xml".format(pcap_file.split(".pcap")[0])
    return pdml_file


def verify_proper_pci_attach(pci, pdml_file):
    pdml_entries = PdmlReader.from_file(pdml_file)
    for entry in pdml_entries:
        if "SgNBAdditionRequest" in entry.packet:
            attach_pci = entry.packet["nr-rrc.physCellId"].show
            assert attach_pci == pci
        elif "UEContextModificationResponse" in entry.packet:
            if "nr-rrc.physCellId" in entry.packet:
                attach_pci = entry.packet["nr-rrc.physCellId"].show
                assert attach_pci == pci
