"""
:author: Michal Obszarny
:maintainer: Michal Obszarny
:owner_email: michal.obszarny@nokia.com
:team: MN RAN RD VRF KRK 11
:email: I_VRF_KRK_11@internal.nsn.com
"""

from testsuite.Krakow.RRM.Airphone.resources.Python.utilities import logger_info, logger_console_info


class CellParam:
    """
    Store Cells parameters in variables.
    Provides getter for Cell parameters per test case.
    """

    def __init__(self):
        self.cell_parameters = {
            'a_a1_01': {
                1: {'nr_arfcn': '505020:505020'},
                2: {'nr_arfcn': '517800:517800'},
                3: {'nr_arfcn': '529002:529002'},
                4: {'nr_arfcn': '528000:528000'},
                11: {'nr_arfcn': '344000:424000', 'gscn': '5300'},
                12: {'nr_arfcn': '377260:387980', 'gscn': '4849'},
                13: {'nr_arfcn': '350000:430000', 'gscn': '5372'},
                14: {'nr_arfcn': '353000:433000', 'gscn': '5411'},
            },
            'a_b103_01': {
                1: {'nr_arfcn': '518598:518598', 'gscn': '6483'},
                2: {'nr_arfcn': '518598:518598', 'gscn': '6483'},
                3: {'nr_arfcn': '132600:123400', 'gscn': '1532'},
                4: {'nr_arfcn': '137600:128400', 'gscn': '1593'},
            },
            'a_b104_01': {
                1: {'nr_arfcn': '505020:505020'},
                2: {'nr_arfcn': '517800:517800'},
                3: {'nr_arfcn': '529002:529002'},
                4: {'nr_arfcn': '528000:528000'},
                11: {'nr_arfcn': '344000:424000', 'gscn': '5300'},
                12: {'nr_arfcn': '377260:387980', 'gscn': '4849'},
                13: {'nr_arfcn': '350000:430000', 'gscn': '5372'},
                14: {'nr_arfcn': '353000:433000', 'gscn': '5411'},
            },
            'a_b201_01': {
                1: {'nr_arfcn': '145000:156000', 'gscn': '1947'},
                2: {'nr_arfcn': '343100:362080', 'gscn': '4523'},
                3: {'nr_arfcn': '630000:630000', 'gscn': '7811'},
                4: {'nr_arfcn': '645000:645000', 'gscn': '7967'},
                5: {'nr_arfcn': '145000:156000', 'gscn': '1950', 'gnb': '3'},
                6: {'nr_arfcn': '349500:368500', 'gscn': '4604', 'gnb': '3'},
                7: {'nr_arfcn': '640000:640000', 'gscn': '7915', 'gnb': '3'},
                8: {'nr_arfcn': '632000:632000', 'gscn': '7832', 'gnb': '3'},
            },
            'a_b202_01': {
                1: {'nr_arfcn': '518598:518598', 'gscn': '6483'},
                2: {'nr_arfcn': '518598:518598', 'gscn': '6483'},
                3: {'nr_arfcn': '132600:123400', 'gscn': '1532'},
                4: {'nr_arfcn': '137600:128400', 'gscn': '1593'},
            },
            'a_b202_03': {
                1: {'nr_arfcn': '518598:518598', 'gscn': '6483'},
                2: {'nr_arfcn': '518598:518598', 'gscn': '6483'},
                3: {'nr_arfcn': '132600:123400', 'gscn': '1532'},
                4: {'nr_arfcn': '137600:128400', 'gscn': '1593'},
            },
            'b_b102_01': {
                1: {'nr_arfcn': '518598:518598', 'gscn': '6483'},
                2: {'nr_arfcn': '518598:518598', 'gscn': '6483'},
                3: {'nr_arfcn': '132600:123400', 'gscn': '1532'},
                4: {'nr_arfcn': '137600:128400', 'gscn': '1593'},
            },
            'b_b301_03': {
                1: {'nr_arfcn': '505020:505020'},
                2: {'nr_arfcn': '517800:517800'},
                3: {'nr_arfcn': '529002:529002'},
                4: {'nr_arfcn': '528000:528000'},
                11: {'nr_arfcn': '344000:424000', 'gscn': '5300'},
                12: {'nr_arfcn': '377260:387980', 'gscn': '4849'},
                13: {'nr_arfcn': '350000:430000', 'gscn': '5372'},
                14: {'nr_arfcn': '353000:433000', 'gscn': '5411'},
            },
            'c_b103_004': {
                11: {'nr_arfcn': '344000:424000', 'gscn': '5300'},
                12: {'nr_arfcn': '346000:426000', 'gscn': '5322'},
                13: {'nr_arfcn': '136100:126900', 'gscn': '1584'},
                14: {'nr_arfcn': '134100:124900', 'gscn': '1559'},
            },
            'c_b103_007': {
                11: {'nr_arfcn': '344000:424000', 'gscn': '5300'},
                12: {'nr_arfcn': '346000:426000', 'gscn': '5322'},
                13: {'nr_arfcn': '136100:126900', 'gscn': '1584'},
                14: {'nr_arfcn': '134100:124900', 'gscn': '1559'},
            },
            'c_b201_008': {
                1: {'nr_arfcn': '505020:505020'},
                2: {'nr_arfcn': '517800:517900'},
                3: {'nr_arfcn': '529002:529002'},
                4: {'nr_arfcn': '528000:528000'},
                11: {'nr_arfcn': '344000:424000', 'gscn': '5300'},
                12: {'nr_arfcn': '347000:427000', 'gscn': '5336'},
                13: {'nr_arfcn': '350000:430000', 'gscn': '5372'},
                14: {'nr_arfcn': '353000:433000', 'gscn': '5411'},
            },
            'c_b201_010': {
                2: {'nr_arfcn': '348800:428540', 'gscn': '5356'},
                5: {'delete': True},
            },
            'c_b201_011': {
                7: {'nr_arfcn': '518598:518598', 'gscn': '6480', 'pci': '18:2', 'nrci': '0x07'},
            },
            'c_b202_014': {
                1: {'nr_arfcn': '2071591:2071591', 'gscn': '22446', 'pci': '17:0', 'tdd_cell': 'on'},
                2: {'nr_arfcn': '2073257:2073257', 'gscn': '22452', 'pci': '17:1', 'tdd_cell': 'on'},
                3: {'nr_arfcn': '2074923:2074923', 'gscn': '22458', 'pci': '17:2', 'tdd_cell': 'on'},
                4: {'nr_arfcn': '2076589:2076589', 'gscn': '22464', 'pci': '18:0', 'tdd_cell': 'on'},
                5: {'nr_arfcn': '2078255:2078255', 'gscn': '22470', 'pci': '18:1', 'tdd_cell': 'on'},
                6: {'nr_arfcn': '2079921:2079921', 'gscn': '22476', 'pci': '18:2', 'tdd_cell': 'on'},
                7: {'nr_arfcn': '2081587:2081587', 'gscn': '22482', 'pci': '19:0', 'nrci': '0x07', 'tdd_cell': 'on'},
                8: {'nr_arfcn': '2083253:2083253', 'gscn': '22488', 'pci': '19:1', 'nrci': '0x08', 'tdd_cell': 'on'},
            },
            'c_6cc_022': {
                1: {'nr_arfcn': '517800:517800'},
                2: {'nr_arfcn': '623954:623954'},
                3: {'nr_arfcn': '646188:646188'},
                4: {'nr_arfcn': '528000:528000'},
                11: {'nr_arfcn': '344000:424000', 'gscn': '5300'},
                12: {'nr_arfcn': '346000:426000', 'gscn': '5322'},
                13: {'nr_arfcn': '136100:126900', 'gscn': '1584'},
                14: {'nr_arfcn': '134100:124900', 'gscn': '1559'},
            },
            'c_6cc_016': {
                1: {'nr_arfcn': '517800:517800'},
                2: {'nr_arfcn': '623954:623954'},
                3: {'nr_arfcn': '646188:646188'},
                4: {'nr_arfcn': '528000:528000'},
                11: {'nr_arfcn': '344000:424000', 'gscn': '5300'},
                12: {'nr_arfcn': '346000:426000', 'gscn': '5322'},
                13: {'nr_arfcn': '136100:126900', 'gscn': '1584'},
                14: {'nr_arfcn': '134100:124900', 'gscn': '1559'},
            },
            'c_6cc_019': {
                1: {'nr_arfcn': '517800:517800'},
                2: {'nr_arfcn': '623954:623954'},
                3: {'nr_arfcn': '646188:646188'},
                4: {'nr_arfcn': '528000:528000'},
                11: {'nr_arfcn': '344000:424000', 'gscn': '5300'},
                12: {'nr_arfcn': '346000:426000', 'gscn': '5322'},
                13: {'nr_arfcn': '136100:126900', 'gscn': '1584'},
                14: {'nr_arfcn': '134100:124900', 'gscn': '1559'},
            },
            'c_6cc_020': {
                1: {'nr_arfcn': '517800:517800'},
                2: {'nr_arfcn': '623954:623954'},
                3: {'nr_arfcn': '646188:646188'},
                4: {'nr_arfcn': '528000:528000'},
                11: {'nr_arfcn': '344000:424000', 'gscn': '5300'},
                12: {'nr_arfcn': '346000:426000', 'gscn': '5322'},
                13: {'nr_arfcn': '136100:126900', 'gscn': '1584'},
                14: {'nr_arfcn': '134100:124900', 'gscn': '1559'},
            },
            'd_b104_01': {                      # TO DO: currently d_b104 uses full wts config file
                1: {'nr_arfcn': '505020:505020'},
                2: {'nr_arfcn': '517800:517800'},
                3: {'nr_arfcn': '529002:529002'},
                4: {'nr_arfcn': '517800:517800'},
                11: {'nr_arfcn': '344000:424000', 'gscn': '5300'},
                12: {'nr_arfcn': '377260:387980', 'gscn': '4849'},
                13: {'nr_arfcn': '350000:430000', 'gscn': '5372'},
                14: {'nr_arfcn': '353000:433000', 'gscn': '5411'},
            },
            'd_b104_03': {
                1: {'nr_arfcn': '636666:636666'},
                2: {'nr_arfcn': '650000:650000', 'gscn': '8019'},
                3: {'nr_arfcn': '134600:125400', 'gscn': '1566'},
                4: {'nr_arfcn': '347380:425040', 'gscn': '5313'},
            },
            # Add more test cases and their cell parameters here
        }

    def get_cell_parameters_by_test_name(self, test_prefix):
        """
        Get Cell parameters based on given test case name.
        If Cell parameters for test case are not defined get Cell parameters for test suite.

        Getter functions should be defined as follows:
        def _get_cell_param_for_<test_prefix or suite_prefix>(self):
            return {
                <cell_id>: {'nr_arfcn': <nr_arfcn_value>, 'gscn': <gscn_value>},
            }
        """
        try:
            return self.cell_parameters[test_prefix]
        except KeyError:
            logger_info('Cell parameters for given test case are not defined, '
                        'trying to get Cell parameters for test suite')
            suite_prefix, _ = test_prefix.rsplit('_', 1)
            try:
                return self.cell_parameters[suite_prefix]
            except KeyError:
                logger_console_info(f'Could not obtain Cell parameters. Reconfiguration will be skipped')
        return {}
