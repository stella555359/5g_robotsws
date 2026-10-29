import time
import taf.transport.ssh as ssh
import logging
from taf.config.wts import wts
import xmltodict
from testsuite.Ulm.ET.L2.libraries.ScfChanges import ScfChanges
import subprocess
import re
import json
import os

logging.basicConfig(level=logging.INFO)

IPHY_PATH = '/rom/simmode/new_iphy.xml'
IPHY_COPY = '/home/ute/iphy.xml'
MOD_IPHY_PATH = '/home/ute/modified_iphy.xml'


def ping_ip(ip_address):
    """
    Ping the specified IP address until it responds.
    """
    while True:
        response = subprocess.call(['ping', '-c', '1', ip_address])
        if response == 0:
            print(f"{ip_address} is reachable!")
            break
        else:
            print(f"{ip_address} is unreachable. Retrying...")


def get_iphy_xml(ssh_connection: ssh.ssh):
    ssh_connection.download_file(IPHY_PATH, IPHY_COPY)
    logging.info('Successfully downloaded iphy.xml from AP.\nVM Path:\t%s', IPHY_COPY)
    with open(IPHY_COPY, 'r') as f:
        iphy_content = f.read()
        logging.debug(iphy_content)
        return iphy_content


def upload_new_iphy_xml(ssh_connection: ssh.ssh, new_file_path):
    ssh_connection.upload_file(new_file_path, IPHY_PATH)
    logging.info('Successfully uploaded new iphy.xml to AP.')


def modify_iphy(orig_iphy):
    cell_parts = orig_iphy.split('<RE>')
    patterns = {
        "gscn": re.compile(r'GSCN>.*<\/GSCN>')
    }
    target_gscn = [
        '6481',  # tdd cell_1 | actual cell id: 1
        '7880',  # tdd cell_2 | actual cell id: 2
        '4872',  # fdd cell_1 | actual cell id: 3
        '4872',  # fdd cell_2 | actual cell id: 4
    ]
    for index, cell in enumerate(cell_parts[1:]):
        cell_parts[index + 1] = re.sub(patterns['gscn'], f'GSCN>{target_gscn[index]}</GSCN>', cell)
    return '<RE>'.join(cell_parts)


def change_frequency_config_in_scf(fdd_cells='3,4'):
    from taf.sbts.oam.coam.admin import admin
    api = admin()
    con = api.connect_to()
    api.get_current_scf_file('/home/ute/Downloads/', 'current_scf.xml', 10, con)
    with open('/home/ute/Downloads/current_scf.xml', 'r') as f:
        file_content = f.read()
    scf_changes = ScfChanges(file_content)
    scf_changes.add_change({'p_name': 'actPrachMultiplexing', 'value': 'false',
                            'regex': f'MRBTS-1/NRBTS-1/NRCELL-[{fdd_cells}]'})
    scf_changes.add_change({'p_name': 'freqBandIndicatorNR', 'value': 25,
                            'regex': f'MRBTS-1/NRBTS-1/NRCELL-[{fdd_cells}]'})
    scf_changes.add_change({'p_name': 'gscnOrSsPbchArfcn', 'value': 4872,
                            'regex': f'MRBTS-1/NRBTS-1/NRCELL-[{fdd_cells}]'})
    scf_changes.add_change({'p_name': 'nrarfcnDl', 'value': 390000,
                            'regex': f'MRBTS-1/NRBTS-1/NRCELL-[{fdd_cells}]/NRCELL_FDD-1'})
    scf_changes.add_change({'p_name': 'nrarfcnUl', 'value': 380000,
                            'regex': f'MRBTS-1/NRBTS-1/NRCELL-[{fdd_cells}]/NRCELL_FDD-1'})
    json_file_path = '/tmp/commissioning.json'
    with open(json_file_path, 'w') as f:
        commissioning_instructions = scf_changes.get_modifications_for_commissioning()
        logging.info('changing the following parameters in scf: %s', commissioning_instructions)
        json.dump(commissioning_instructions, f, indent=4)
    api.perform_delta_recommissioning(delta_file=json_file_path,
                                      skip_parameter_relation_errors=True,
                                      connection=con)
    logging.info('commissioning complete.')


def change_gscn_in_basic_config(basic_setup_path='/opt/iphy/latest/basic_setup.cfg'):
    """
    set_cell id=3 gnb=2 nr_arfcn=380000:390000 gscn=4872 eci=0x000021f pci=17:1 tac=200
    proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nrci=0x03 tdd_cell=off  mandatory_for_activation=off
    set_cell id=4 gnb=2 nr_arfcn=380000:390000 gscn=4872 eci=0x000021f pci=17:2 tac=200
    proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nrci=0x04 tdd_cell=off  mandatory_for_activation=off
    """
    logging.info('modifying basic setup to reflect new cell config.')
    wts_object = wts()
    wts_object.load_wts_cfg(basic_setup_path)
    wts_object.modify(command='set_cell id=3', modification='nr_arfcn=380000:390000')
    wts_object.modify(command='set_cell id=4', modification='nr_arfcn=380000:390000')
    wts_object.modify(command='set_cell id=3', modification='gscn=4872')
    wts_object.modify(command='set_cell id=4', modification='gscn=4872')
    wts_object.save_wts_cfg(file_path=basic_setup_path)
    logging.info('basic_setup modification complete.')


class CellFrequencyModifier():
    def __init__(self, cell_configuration_json_filepath=""):
        from taf.sbts.oam.coam.admin import admin
        api = admin()
        con = api.connect_to()
        api.get_current_scf_file('/home/ute/', 'current_scf.xml', 100, con)
        self.orig_scf = '/home/ute/current_scf.xml'
        self.ssh_iphy = ssh.ssh()
        self.ssh_iphy.connect_to(hostname='192.168.200.1', username='toor4nsn', password='oZPS0POrRieRtu')
        self.iphy_dict = xmltodict.parse(get_iphy_xml(self.ssh_iphy), encoding='utf-8')
        self.orig_basic_setup = '/opt/wts/latest/basic_setup.cfg'
        # ---------------------------------------------------------------------------------------------[120 characters]
        if cell_configuration_json_filepath:
            self.config_file = cell_configuration_json_filepath
        else:
            self.config_file = os.sep.join(__file__.split(os.sep)[:-2]) + '/configurations/cell_configuration.json'
        logging.info('self.config_file = %s' % self.config_file)
        if not os.path.exists(self.config_file):
            raise FileNotFoundError(f"The file at path {self.config_file} does not exist.")
        # ---------------------------------------------------------------------------------------------[120 characters]
        with open(self.orig_scf, 'r') as orig_scf:
            self.scf_changes = ScfChanges(orig_scf.read())
        self.wts_object = wts()
        self.wts_object.load_wts_cfg(self.orig_basic_setup)

    def modify_cell(self, band: str, target: int):
        with open(self.config_file, 'r') as config:
            cfg = json.load(config)
        if scf_data := cfg[band].get('scf'):
            self.update_scf(scf_data)
        if iphy_data := cfg[band].get('iphy'):
            self.update_iphy_cell(iphy_data, target)
        if egate_data := cfg[band].get('egate'):
            self.update_egate(egate_data, target)

    def execute_modifications(self):
        self.execute_commissioning()
        self.execute_iphy_changes()
        self.execute_egate_changes()
        logging.info('now waiting for Cplane to get ready.')
        time.sleep(180)

    def execute_commissioning(self):
        from taf.sbts.oam.coam.admin import admin
        api = admin()
        con = api.connect_to()
        json_file_path = '/tmp/commissioning.json'
        with open(json_file_path, 'w') as f:
            commissioning_instructions = self.scf_changes.get_modifications_for_commissioning()
            logging.info('changing the following parameters in scf: %s', commissioning_instructions)
            json.dump(commissioning_instructions, f, indent=4)
        api.perform_delta_recommissioning(delta_file=json_file_path,
                                          skip_parameter_relation_errors=False,
                                          connection=con)
        logging.info('commissioning complete.')

    def execute_iphy_changes(self):
        with open('/tmp/updated_iphy.xml', 'w') as xml:
            xmltodict.unparse(self.iphy_dict, xml, pretty=True, indent='  ', encoding='utf-8')
        upload_new_iphy_xml(self.ssh_iphy, '/tmp/updated_iphy.xml')
        logging.info('updated iphy.xml uploaded.')
        logging.info('trying to reboot AP...')
        self.ssh_iphy.execute(command='reboot')
        ping_ip('192.168.200.1')
        logging.info('reboot executed.')

    def execute_egate_changes(self):
        self.wts_object.save_wts_cfg(file_path=self.orig_basic_setup)
        logging.info('basic_setup modification complete.')

    def update_scf(self, changes):
        for change in changes:
            self.scf_changes.add_change(change)

    def update_iphy_cell(self, value_update, target):
        cells = self.iphy_dict['IPHY-Config']['CPRI-Config']['CPRI-RP1-RE_List']['RE']
        target_cell = f"{target}"
        for cell in cells:
            vcell_obj = cell['hardware']['vcellList']['vcell']
            if type(vcell_obj) is list:
                for v_idx, vcell in enumerate(vcell_obj):
                    if vcell['cell'].split('.')[-1] == target_cell:
                        logging.info('currently looking at target cell (%s).', target_cell)
                        for key, value in value_update.items():
                            vcell[key] = value
            else:
                if vcell_obj['cell'].split('.')[-1] == target_cell:
                    logging.info('currently looking at target cell (%s).', target_cell)
                    for key, value in value_update.items():
                        vcell_obj[key] = value

    def update_egate(self, changes, target):
        logging.info('modifying basic setup to reflect new cell config.')
        for key, value in changes.items():
            logging.info(f'Updating {key} to {value} for target {target}')
            self.wts_object.modify(command=f'set_cell id={target} gnb=2', modification=f'{key}={value}')


if __name__ == '__main__':
    # change_cell_settings_for_8127_MN_B01()
    change_cell_settings_for_CB013392_A_B3()
    # modify_frequency_with_config_file('../configurations/cell_configurations.json', 'n38', 1)
    # modify_frequency_with_config_file('../configurations/cell_configurations.json', 'n41', 2)
    # ssh_connection = ssh.ssh()
    # ssh_connection.connect_to(hostname='192.168.200.1', username='toor4nsn', password='oZPS0POrRieRtu')
    # iphy = get_iphy_xml(ssh_connection)
    # with open(MOD_IPHY_PATH, 'w') as f:
    #     f.write(modify_iphy(iphy))
    # upload_new_iphy_xml(ssh_connection, MOD_IPHY_PATH)
    # logging.info('trying to reboot AP...')
    # ssh_connection.execute(command='reboot')
    # logging.info('reboot executed.')
    # change_frequency_config_in_scf()
    # change_gscn_in_basic_config()
