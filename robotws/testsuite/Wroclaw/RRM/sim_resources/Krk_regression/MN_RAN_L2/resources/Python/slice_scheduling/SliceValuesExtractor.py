import re
from dataclasses import dataclass, field


@dataclass
class SliceSupportItem:
    sst: str = "----Empty SST----"
    sd: str = "----Empty SD----"


@dataclass
class PlmnIdentity:
    identity: str = ""
    mcc: str = ""
    mnc: str = ""
    ExtendedSliceSupportList: str = ""
    sliceSupportList: list[SliceSupportItem] = field(default_factory=lambda: list())


class SliceValuesExtractor:

    def __init__(self, pcap_file_content):
        self.pcap_to_txt_line_by_line = pcap_file_content
        self.plmnidentities = []
        self.pcap_file_index_plmn_support_list = 0

    def get_values_from_pcap_slices(self):
        self._create_empty_plmn_support_items()
        index = -1
        plmnidentity = None
        for line in self.pcap_to_txt_line_by_line[self.pcap_file_index_plmn_support_list:]:
            if line.startswith("pLMNIdentity"):
                index += 1
                plmnidentity = self.plmnidentities[index]
                plmnidentity.identity = line.split(":")[1].strip()
            if line.startswith("Mobile Country Code"):
                plmnidentity.mcc = line.split(":")[1].strip()
            if line.startswith("Mobile Network Code"):
                plmnidentity.mnc = line.split(":")[1].strip()
            if line.startswith("sST"):
                slice_supp_item = SliceSupportItem()
                slice_supp_item.sst = int(line.split(":")[1].strip(), 16)
                plmnidentity.sliceSupportList.append(slice_supp_item)
            if line.startswith("sD"):
                plmnidentity.sliceSupportList[-1].sd = int(line.split(":")[1].strip(), 16)
            if line.startswith("ExtendedSliceSupportList"):
                items = re.match(r"^ExtendedSliceSupportList:.(\d+)", line)
                plmnidentity.ExtendedSliceSupportList = items.group(1)
                break

    def _create_empty_plmn_support_items(self):
        for index, line in enumerate(self.pcap_to_txt_line_by_line):
            if "PLMNSupportList" not in line.strip():
                continue
            else:
                items = re.match(r"^PLMNSupportList:.(\d+)", line)
                if items:
                    self.pcap_file_index_plmn_support_list = index
                    nr_of_items = items.group(1)
                    for i in range(int(nr_of_items)):
                        self.plmnidentities.append(PlmnIdentity())
                    break
