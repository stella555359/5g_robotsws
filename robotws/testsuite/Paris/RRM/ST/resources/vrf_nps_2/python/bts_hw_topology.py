"""
Author: [Your Name]
Email: [Your Email]
"""


class btsHwTopology:
    def __init__(self, bts_hw_info):
        self.bts_hw_info = bts_hw_info
        self.topoloy = self._build_testline_topology(self.bts_hw_info)

    def get_topology_name(self):
        return self.topoloy

    def _build_testline_topology(self):
        """
        Returns a hardware configuration string based on the provided BTS hardware information.
        Example: NSA_2xASIB_6xABIO_10xAHCA_8xAHFIB_18xAHEH_20xCells_n5_FDD_36xCells_n3_FDD_16xCells_n25_FDD
        @return: Hardware configuration string.
        """
        radio_modules_info = self.get_radio_modules_info()
        baseband_modules_info = self.get_baseband_modules_info()
        system_modules_info = self.get_system_modules_info()
        cells_info = self.get_cells_info()

        hw_conf = f"{self.bts_hw_info['gNbCuType']}_"

        for sm, lst in system_modules_info.items():
            hw_conf += f"{len(lst)}x{sm.split()[0]}_"

        basebands = sorted(f"{len(lst)}x{bb.split()[0]}" for bb, lst in baseband_modules_info.items())
        for bb in basebands:
            hw_conf += f"{bb}_"

        radios = sorted(f"{len(lst)}x{ru}" for ru, lst in radio_modules_info.items())
        for ru in radios:
            hw_conf += f"{ru}_"

        cells = sorted(f"{len(lst)}xCells_{id}" for id, lst in cells_info.items())
        for cell in cells:
            hw_conf += f"{cell}_"

        return hw_conf.rstrip('_')

    def get_gnb_software_version(self):
        return self.bts_hw_info['swInfo']['swVersion']

    def get_radio_modules_info(self):
        radio_modules_info = {}
        for radio_module in self.bts_hw_info['radioModules']['rmod']:
            product_name = radio_module['productName']
            module_info = {
                'productCode': radio_module['productCode'],
                'serialNumber': radio_module['serialNumber']
            }
            radio_modules_info.setdefault(product_name, []).append(module_info)
        return radio_modules_info

    def get_baseband_modules_info(self):
        baseband_modules_info = {}
        for baseband_module in self.bts_hw_info['basebandModules']:
            product_name = baseband_module['productName']
            module_info = {
                'productCode': baseband_module['productCode'],
                'serialNumber': baseband_module['serialNumber']
            }
            baseband_modules_info.setdefault(product_name, []).append(module_info)
        return baseband_modules_info

    def get_system_modules_info(self):
        system_modules_info = {}
        for system_module in self.bts_hw_info['systemModules']:
            product_name = system_module['productName']
            module_info = {
                'productCode': system_module['productCode'],
                'serialNumber': system_module['serialNumber']
            }
            system_modules_info.setdefault(product_name, []).append(module_info)
        return system_modules_info

    def get_cells_info(self):
        cells_info = {}
        for cell in self.bts_hw_info['cells']['nr']:
            cell_id = f"{cell['band']}_{cell['technology']}"
            cell_info = {'nrcell': cell['id']['configuration']}
            cells_info.setdefault(cell_id, []).append(cell_info)
        return cells_info
