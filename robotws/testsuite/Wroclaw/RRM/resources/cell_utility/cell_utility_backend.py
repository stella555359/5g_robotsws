import testsuite.Wroclaw.RRM.resources.rrm_fixture as fixture
from testsuite.Wroclaw.RRM.resources.pcap_verification.tsharkWithLuaVerifier import \
    get_log_line_number_from_output, get_filtered_tshark_output_as_frames
from testsuite.Wroclaw.RRM.resources.log.helper import LogHelper
from testsuite.Wroclaw.RRM.resources.log.matchers import PcapMessageMatcher
import xml.etree.ElementTree as ET
from testsuite.Wroclaw.RRM.resources.webUI_operations import WebUIOperations


class CellInfo(object):
    def __init__(self, global_id=None, nr_identity=None, physical_id=None):
        self._ids = {'global_id': global_id, 'nr_identity': nr_identity, 'physical_id': physical_id}

    def __getitem__(self, item):
        if self._ids[item] is None:
            raise CellIdNotSet("{} not set".format(item))
        return self._ids[item]

    def __setitem__(self, key, value):
        self._ids[key] = value

    def __str__(self):
        return str(self._ids)


class CellIdNotSet(Exception):
    pass


@fixture.logged_keyword
def get_cell_ids_from_cell_setup_pcap(pcap_path=None):
    pcap_file = pcap_path if pcap_path is not None else \
        "{dir}/{testname}__asik_cell_setup.pcap".format(dir=fixture.get_robot_variable('${LOG_PATH}'),
                                                        testname=fixture.get_robot_variable('${test_name}'))
    cells = []
    nr_identities = []
    phys_ids = []
    output = get_filtered_tshark_output_as_frames(pcap_file, "x2ap.ENDCX2SetupResponse_element")
    assert len(output) == 1, "Error: found {} ENDCX2SetupResponse messages".format(len(output))
    for line_idx in sorted(get_log_line_number_from_output(output[0], "nRcellIdentifier:")):
        nr_identities.append(output[0][line_idx].strip().split(" ")[-1].strip()[:-1])
    for line_idx in sorted(get_log_line_number_from_output(output[0], "physCellId:")):
        phys_ids.append(output[0][line_idx].split(":")[-1].strip())
    assert len(nr_identities) == len(phys_ids), "Number of found nrcell_identities is not equal to found phys_cell_ids"
    for i in range(len(nr_identities)):
        cells.append(CellInfo(nr_identity=nr_identities[i], physical_id=phys_ids[i]))
    return cells


def find_global_cell_ids_given_physical_cell_ids(cells):
    if not isinstance(cells, list):
        cells = [cells]
    with WebUIOperations() as webui:
        msg = webui.get_current_scf_content()
    root = ET.fromstring(msg)
    cell_info = root.findall(".//*[@class='com.nokia.srbts.nrbts:NRCELL']")
    for idx, element in enumerate(cell_info):
        phys_id = element.find("./*[@name='physCellId']").text
        lcr_id = element.find("./*[@name='lcrId']").text
        for cell in cells:
            if cell['physical_id'] == phys_id:
                cell['global_id'] = lcr_id


@fixture.logged_keyword
def get_primary_and_secondary_physcellids_from_attach_pcap(pcap_path=None):
    prim_id = None
    sec_ids = []
    with LogHelper() as lh:
        finder = lh.add_pcap(pcap_file_path=pcap_path)
        sgnb_add_req_ack = finder.find_exactly(1, PcapMessageMatcher('SgNBAdditionRequestAcknowledge',
                                                                     name_line_pattern='empty'))[0]
        phys_id_paths = sgnb_add_req_ack.find('*physCellId*')
    for path in phys_id_paths:
        if "spCellConfig" in path['path']:
            prim_id = path['val']
        if any(["sCellToAddModList: " in x for x in path['path']]):
            sec_ids.append(path['val'])
    assert prim_id, "Has not found 'physCellId' in 'SgNBAdditionRequestAcknowledge' from attach pcap"
    return prim_id, sec_ids


@fixture.logged_keyword
def determine_prim_and_sec_cells(known_cells, attach_phy_ids):
    prim_cells = [cell for cell in known_cells if cell['physical_id'] == attach_phy_ids[0]]
    assert len(prim_cells) == 1,  "UE attached to primary cell not known from cell setup, or to more than 1"
    sec_cells = [cell for cell in known_cells if cell['physical_id'] in attach_phy_ids[1]]
    return prim_cells[0], sec_cells


def log_cell_structs(cells):
    for idx, cell in enumerate(cells):
        fixture.log_message(message="Cell struct nr {}, data = {}".format(idx, cell))


def get_new_cell_struct(global_id=None, nr_identity=None, physical_id=None):
    return CellInfo(global_id=global_id, nr_identity=nr_identity, physical_id=physical_id)
