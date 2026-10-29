"""
:author: Min Dai
:contact: min.b.dai@nokia-sbell.com
"""
import subprocess
from taf.config.scf import scf
from taf.transport.ssh import ssh
import taf.ul.sc.tl_config as tl_config
from testsuite.Krakow.resources.NJ_Resources.Resources.python.DevNJ_sbts_keywords import *
from robot.libraries.BuiltIn import BuiltIn


class CellInfo(object):
    def __init__(self):
        """
        Class for getting UE connected cell information.
        """
        self.bts_mode = self.get_bts_mode()
        self.sshManager = ssh()
        self.admin = admin()
        logger.info(self.bts_mode)

    def get_bts_mode(self):
        """
        This method used to get BTS running mode:
               LTE  for 4G LTE only
               NSA   for 5G NR NSA mode
               SA    for 5G NR SA mode
        """
        if tl_config.tl.gnbs is None and tl_config.tl.enbs is not None:
            bts_mode = 'LTE'
        else:
            bts_mode = '5G'

        if bts_mode != 'LTE':
            bts_mode = self.get_nr_mode_from_scf()
        return bts_mode

    @staticmethod
    def get_nr_mode_from_scf():
        """
        return value could be NSA/SA/SA+NSA...
        """
        scf_path = download_sbts_commissioning()
        time.sleep(2)
        scf_obj = scf()
        scf_obj.load_scf(file_path=scf_path)
        param_value = scf_obj.get_value_from_scf(p_name='gNbCuType')
        return param_value

    @staticmethod
    def check_ipaddr_type():
        """
        This method used to check anchor eNB IP address type under NSA mode

        :return ip_addr_flag
        """
        assert tl_config.tl, "TL configuration file {0} is empty!".format(tl_config)
        ip_addr_flag = None
        if tl_config.tl.gnbs is not None and tl_config.tl.enbs is not None:
            if tl_config.tl.enbs[0].x2_link_addr:
                ip_addr_flag = 'X2'
            elif tl_config.tl.enbs[0].oam_ip:
                ip_addr_flag = 'OAM'
            else:
                logger.info("unsupported IP address type!")
        return ip_addr_flag

    def get_anchor_enb_info(self):
        """
        Get anchor eNB information for NSA mode
        """
        try:
            if self.bts_mode != 'NSA':
                return
            ip_addr_type = self.check_ipaddr_type()
            if ip_addr_type == 'X2':
                enb_x2ip = tl_config.tl.enbs[0].x2_link_addr.v4
            elif ip_addr_type == 'OAM':
                enb_x2ip = tl_config.tl.enbs[0].oam_ip.v4
            else:
                raise Exception("The eNB IP address in TL configuration file is not supported, please check!")

            i = 0
            while i < 5:
                try:
                    i += 1
                    self.sshManager.connect_to(hostname=enb_x2ip,
                                               username='toor4nsn',
                                               password='oZPS0POrRieRtu',
                                               alias='enb')
                    break
                except Exception as e:
                    ex = e
                    time.sleep(20)
            else:
                raise Exception("Connect to eNB failed, the last error is: {}".format(ex))

            enb_type = self.get_enb_type()
            if enb_type == 'fzm':
                self.get_fzm_enb_scf()
                cell_dict = self.get_anchor_fzm_cell_info()
            else:
                cell_dict = self.get_anchor_cell_info()
            logger.info("\n---enb cell_dict---:{}".format(cell_dict))
            return cell_dict

        except Exception as e:
            logger.info("\nThe error msg in get_anchor_enb_info is:{}".format(e))

        finally:
            self.sshManager.disconnect(connection='enb')

    def get_enb_type(self):
        """
        Get eNB type, it can be fzm/fct...
        """
        self.sshManager.send_command(command="hostname", connection='enb')
        time.sleep(1)
        result = self.sshManager.read_output(connection='enb')
        enb_type = result[0:3]
        return enb_type

    def get_fzm_enb_scf(self):
        """
        Get scf of FZM eNB
        """
        self.sshManager.send_command(
            command="ls -tr /ffs/run/btsom/config/active/SCF*.xml|tail -1 > /user/toor4nsn/SCFlist.txt",
            connection='enb',
            timeout=5)
        self.sshManager.send_command(command="cp /ffs/run/btsom/config/active/SCF*.xml /user/toor4nsn",
                                     connection='enb', timeout=5)
        self.sshManager.send_command(command="chmod 777 /user/toor4nsn/SCF*.xml", connection='enb', timeout=5)
        self.sshManager.send_command(command="chmod 777 /user/toor4nsn/SCFlist.txt", connection='enb', timeout=5)
        self.sshManager.send_command(command="cat /user/toor4nsn/SCFlist.txt", connection='enb', timeout=5)
        scf_file = self.sshManager.read_output(connection='enb')
        target_file = scf_file[0:-1]
        logger.info("\ntarget_file={}".format(target_file), also_console=True)
        scf_local_path = BuiltIn().replace_variables('${OUTPUT_DIR}') + '/enb_scf.xml'
        self.sshManager.download_file(remote_path=target_file,
                                      local_path=scf_local_path,
                                      connection='enb')
        self.sshManager.send_command(command="rm /user/toor4nsn/SCF*", connection='enb', timeout=5)

    def get_anchor_fzm_cell_info(self):
        """
        This method used to get anchor FZM cell info
        """
        cmd1 = "cat " + BuiltIn().replace_variables('${OUTPUT_DIR}') + \
               "/enb_scf.xml|grep 'NOKLTE:LNCEL'|grep -v 'LNCEL_'|awk -F '[-\"]' '{{print $7}}'"
        result_cell_lines = (subprocess.check_output(cmd1, shell=True)).decode('utf-8').splitlines()
        cell_num = len(result_cell_lines)
        cmd2 = "cat " + BuiltIn().replace_variables('${OUTPUT_DIR}') + \
               "/enb_scf.xml|grep periodicCqiFeedbackType -A 1|grep phyCellId|awk -F '[<>]' '{{print $3}}'"
        result_pci_lines = (subprocess.check_output(cmd2, shell=True)).decode('utf-8').splitlines()
        cmd3 = "cat " + BuiltIn().replace_variables('${OUTPUT_DIR}') + \
               "/enb_scf.xml|grep earfcn|grep -v UL|awk -F '[<>]' '{{print $3}}'"
        result_earfcn_lines = (subprocess.check_output(cmd3, shell=True)).decode('utf-8').splitlines()
        lte_cell_dict = {}
        for i in range(cell_num):
            cell_id = result_cell_lines[i]
            pci = result_pci_lines[i]
            earfcn = result_earfcn_lines[i]
            lte_cell_info = {str(cell_id): {'pci': pci, 'earfcn': earfcn}}
            lte_cell_dict.update(lte_cell_info)
        return lte_cell_dict

    @staticmethod
    def parse_anchor_lte_cell_info(cell_info_list):
        """
        Main Function:
        This method used to parse anchor lte cell info for NSA configuration

        Arguments:
            :param cell_info_list: list of anchor lte testline detailed cell info

        Return Value:
            list of anchor lte cell info

        Examples:
           ${LTE_Cell_Dict_List}  Parse Anchor Lte Cell Info  cell_info_list=${LTE_Cells_Info['cells']['lte']}

        Version:
            | Author | Version | Delivery Date | Comments |
            | Sun Jingang | 1.0.0 | 2022/2/22 | First approved version by VA |
        """
        assert cell_info_list, "Empty list of anchor lte cell info!"
        logger.info("Start to parse anchor lte cell info")

        parsed_cell_dict = {}
        for iter_item in cell_info_list:
            if iter_item.get('technology') not in ['FDD', 'TDD']:
                logger.info("unsupported cell technology - {0}".format(iter_item.get('technology')))
                continue

            tmp_dict = {str(iter_item.get('globalCellId')):
                        {'pci': iter_item.get('physicalCellId'),
                            'earfcn': iter_item.get('earfcnDownlink') if iter_item.get('technology') == 'FDD'
                            else iter_item.get('earfcn')}}
            parsed_cell_dict.update(tmp_dict)

        return parsed_cell_dict

    def get_anchor_cell_info(self):
        """
        This method used to get anchor None FZM cell info
        """
        try:
            self.admin.setup_admin(bts_host=tl_config.tl.enbs[0].x2_link_addr.v4)
            lte_cells_info = self.admin.get_cell_list()
            lte_cell_dict = self.parse_anchor_lte_cell_info(cell_info_list=lte_cells_info['cells']['lte'])
            return lte_cell_dict

        finally:
            self.admin.teardown_admin()

    def get_gnb_cell_info(self):
        """
        This method used to get gNB cell related info for attached result verification under SA mode.
        """
        try:
            self.admin.setup_admin()
            gnb_cells_info = self.admin.get_cell_list()
            gnb_pci_list = []
            gnb_cell_dict = {}
            for cell_info in gnb_cells_info['cells']['nr']:
                cell_id = cell_info['globalCellId']
                pci = cell_info['physicalCellId']
                earfcn = cell_info['nrarfcn']
                gnb_cell_info = {str(cell_id): {'pci': pci, 'nrarfcn': earfcn}}
                gnb_pci_list.append(pci)
                gnb_cell_dict.update(gnb_cell_info)
            logger.info("\n---gnb_pci_list---:{}".format(gnb_pci_list))
            logger.info("\n---gnb_cell_dict---:{}".format(gnb_cell_dict))
            return gnb_pci_list, gnb_cell_dict

        finally:
            self.admin.teardown_admin()
