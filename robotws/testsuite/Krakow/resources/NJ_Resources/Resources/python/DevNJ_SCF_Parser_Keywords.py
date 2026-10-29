from testsuite.Krakow.resources.NJ_Resources.Resources.python.DevNJ_SCF_Filter import *
from taf.rfrl.procedures.resources.python.logger import log_warning


class DevNJ_SCF_Parser_Keywords(object):
    """  DevNJ_SCF_Parser_Keywords
    This DevNJ_SCF_Parser_Keywords provides keywords:
    1. loads and load
    2. kw_get_asir_xmod_r_xmod_mapping
    3. kw_get_asir_cell_relative_info
    4. kw_get_asir_hub_relative_info
    5. kw_get_asir_ant_relative_info
    6. kw_get_asir_celllist_xmod_mapping
    7. kw_get_antmod_antport_mapping
    """

    def __init__(self):
        self.scf_filter = DevNJ_SCF_Filter()

    def loads(self, scf_text):
        self.scf_filter.loads(scf_text)

    def load(self, scf_path):
        self.scf_filter.load(scf_path)

    def kw_get_asir_xmod_r_xmod_mapping(self, mo_r_class):
        """
        Main Function:
            From a SCF XML, Calculate the mapping dictionary from XMOD_R to XMOD

        Arguments:
            :param mo_r_class: XMOD class name

        Return Value:
            Dict of Mapping

        Examples:
            Example 1: Get mapping of ANTMOD_R to ANTMOD
            | load | ./Configuration_asir_MRBTS-68203_SBTS22R3_ENB_9999_220406_000006_20220407-1838.xml |
            | kw_get_asir_xmod_r_xmod_mapping | ANTMOD_R |
            Return:
            {
                "ANTMOD_R-1": "ANTMOD-1",
                "ANTMOD_R-2": "ANTMOD-2",
                "ANTMOD_R-3": "ANTMOD-3",
                "ANTMOD_R-4": "ANTMOD-4"
            }

        Version:
            | Author | Version | Delivery Date | Comments |
            | fuzengz | 0.0.1 | 2022/04/26 | First draft version |
            | fuzengz | 1.0.0 | 2022/05/07 | Approve Version |

        """
        if not mo_r_class.endswith('_R'):
            raise Exception("parameter mo_r_class '{}' doesn't end with '_R'".format(mo_r_class))
        mo_r_list = self.scf_filter.filter({'class': ':{}$'.format(mo_r_class)}).project(
            display_keys=['distName', 'configDN'])
        return dict(
            [(mo['distName'].split('/')[-1], mo.get('configDN', '').split('/')[-1] or None) for mo in mo_r_list])

    def kw_get_asir_cell_relative_info(self):
        """
        Main Function:
            From a SCF XML, Calculate the CELL_R relative info

        Arguments:
            :None

        Return Value:
            Dict of CELL_R relative info
            Example:
            {
                "ASI-1/ASI_R-1/BTS_R-1/CELL_R-1": {
                    "cell_info": {
                        ...
                    },
                    "bts_info": {
                        ...
                    },
                    "channel_info": {
                        ...
                    },
                    "hubmod_info": {
                        ...
                    },
                    "antport_info": {
                        ...
                    },
                    "cablink_info": {
                        ...
                    },
                    "bbmod_info": {
                        ...
                    },
                }
                "ASI-1/ASI_R-1/BTS_R-1/RFCCELL_R-2": {
                    ...
                }
            }

        Examples:
            Example 1: Get asir cell relative info
            | kw_get_asir_cell_relative_info |
        Version:
            | Author | Version | Delivery Date | Comments |
            | fuzengz | 0.0.1 | 2022/04/26 | First draft version |
            | fuzengz | 1.0.0 | 2022/05/07 | Approve Version |

        """
        dict_res = {}
        for cell_r in self.scf_filter.filter({'class': ':(CELL_R|RFCCELL_R)$'}):
            # if RFCCELL_R, locate its RFCHUBGROUP_R and then locate RFCCELL thru configDN
            if cell_r['class'].endswith(':RFCCELL_R'):  # get rfc hubgroup_r
                rfc_cell = self.scf_filter.filter({'distName': "^{}$".format(cell_r['configDN'])})[0]
                cell_r = {**rfc_cell, **cell_r}

            dict_res[cell_r['distName']] = {'cell_info': cell_r}
            # get bts info
            if cell_r['class'].endswith(':CELL_R'):
                bts_r_list = self.scf_filter.filter(
                    {'class': ':BTS_R$', 'distName': '/'.join(cell_r['distName'].split('/')[0:-1])})
                dict_res[cell_r['distName']]['bts_info'] = bts_r_list.mo_dict()

            # add asirCellId
            if cell_r['class'].endswith(':CELL_R'):
                cell_r['asirCellId'] = "{}.{}".format(bts_r_list[0]['targetBtsId'], cell_r['lnCelId'])
            elif cell_r['class'].endswith(':RFCCELL_R'):
                re_match = re.search(r'/RFC-(\d+)/RFCCELL-(\d+)', cell_r['configDN'])
                cell_r['asirCellId'] = '{}.{}'.format(re_match.group(1), re_match.group(2))

            # get channels
            channel_r_list = self.scf_filter.filter(
                {'class': ':(CHANNEL_R|RFCCHANNEL_R)$', 'distName': '^{}/'.format(cell_r["distName"])})
            if channel_r_list:
                dict_res[cell_r['distName']]['channel_info'] = channel_r_list.mo_dict()

            # get hubmod for CELL_R
            hubmod_r_list = []
            if cell_r['class'].endswith(':CELL_R'):
                hubmod_r_distName_list = ['/'.join(channel_r['hubAntlRDN'].split('/')[0:-1]) for channel_r in
                                          channel_r_list]
                hubmod_r_list = self.scf_filter.filter({'distName': {'$in': hubmod_r_distName_list}})

            elif cell_r['class'].endswith(':RFCCELL_R'):
                rfc_hub_group_r = self.scf_filter.filter(
                    {'class': ':RFCHUBGROUP_R', 'distName': '^{}/'.format(cell_r["distName"])})[0]
                rfc_port_r_list = self.scf_filter.filter(
                    {'class': ':RFCPORT_R$', 'distName': '/RFCPORT_R-{}$'.format(rfc_hub_group_r["rfcPortRId"])})
                hubmod_r_distName_list = ['/'.join(rfc_port_r['sfpPortRDN'].split('/')[0:-1]) for rfc_port_r in
                                          rfc_port_r_list]
                hubmod_r_list = self.scf_filter.filter({'distName': {'$in': hubmod_r_distName_list}})
            else:
                raise ("unexpected cell")

            if hubmod_r_list:
                dict_res[cell_r['distName']]['hubmod_info'] = hubmod_r_list.mo_dict()

            # get antmod info
            # extract Antmod distnames
            antmod_r_distNames = [re.match(r'(.+/ANTMOD_R-\d+)/', antRes['antAntlRDN']).group(1) for channel_r in
                                  channel_r_list for antRes in channel_r['antResources']]
            antmod_r_list = self.scf_filter.filter({'distName': {'$in': antmod_r_distNames}})
            if antmod_r_list:
                dict_res[cell_r['distName']]['antmod_info'] = antmod_r_list.mo_dict()

            # get antport info
            antport_r_distNames = [antmod_r['antPortRDN'] for antmod_r in antmod_r_list]
            antport_r_list = self.scf_filter.filter({'distName': {'$in': antport_r_distNames}})
            if antport_r_list:
                dict_res[cell_r['distName']]['antport_info'] = antport_r_list.mo_dict()

            if cell_r['class'].endswith(':CELL_R'):
                # get cablink info
                cablink_r_list = self.scf_filter.filter(
                    {'class': ':CABLINK_R$', 'firstEndPointDN': '^{}/'.format(bts_r_list[0]["distName"]),
                     'secondEndPointDN': {'$in': [hubmod_r['distName'] for hubmod_r in hubmod_r_list]}})
                if cablink_r_list:
                    dict_res[cell_r['distName']]['cablink_info'] = cablink_r_list.mo_dict()

                # get bbmod info
                bbmod_r_list = self.scf_filter.filter({'class': ':BBMOD_R$', 'distName': {
                    '$in': [cablink_r['firstEndPointDN'] for cablink_r in cablink_r_list]}})
                if bbmod_r_list:
                    dict_res[cell_r['distName']]['bbmod_info'] = bbmod_r_list.mo_dict()
        return dict_res

    def kw_get_asir_hub_relative_info(self):
        """
        Main Function:
            From a SCF XML, Calculate the HUBMOD_R relative info

        Arguments:
            :None

        Return Value:
            Dict of HUBMOD_R relative info
            Example:
            {
                "ASI-1/ASI_R-1/HUBMOD_R-1": {
                    "hub_info": {
                        ...
                    },
                    "bts_info": {
                        ...
                    },
                    "antmod_info": {
                        ...
                    },
                    "antport_info": {
                        ...
                    },
                    "channel_info": {
                        ...
                    },
                    "cell_info": {
                        ...
                    },
                    "cablink_info": {
                        ...
                    },
                    "bbmod_info": {
                        ...
                    },
                },
                "ASI-1/ASI_R-1/HUBMOD_R-2": {
                    ...
                }
            }

        Examples:
            Example 1: Get asir hub relative info
            | kw_get_asir_hub_relative_info |
        Version:
            | Author | Version | Delivery Date | Comments |
            | fuzengz | 0.0.1 | 2022/04/26 | First draft version |
            | fuzengz | 1.0.0 | 2022/05/07 | Approve Version |

        """
        dict_res = {}
        for hubmod_r in self.scf_filter.filter({'class': ':HUBMOD_R$'}):
            dict_res[hubmod_r['distName']] = {'hub_info': hubmod_r}
            # get bts info
            # get btsRIds from externalRIds and then accquire bts_r
            bts_distName_regexes = ["/BTS_R-{}$".format(externalRId.get('btsRId')) for externalRId in
                                    hubmod_r.get('externalRIds', [])]
            bts_r_list = self.scf_filter.filter({'class': ':BTS_R$', 'distName': {'$in_regex': bts_distName_regexes}})
            if bts_r_list:
                dict_res[hubmod_r['distName']]['bts_info'] = bts_r_list.mo_dict()

            # get antmod info
            antmod_r_list = self.scf_filter.filter(
                {'class': ':ANTMOD_R$', 'antPortRDN': "^{}/".format(hubmod_r['distName'])})
            if antmod_r_list:
                dict_res[hubmod_r['distName']]['antmod_info'] = antmod_r_list.mo_dict()

            # get antport info
            antport_r_distNames = [antmod_r['antPortRDN'] for antmod_r in antmod_r_list]
            antport_r_list = self.scf_filter.filter({'distName': {'$in': antport_r_distNames}})
            if antport_r_list:
                dict_res[hubmod_r['distName']]['antport_info'] = antport_r_list.mo_dict()

            # get channel info
            channel_r_list = self.scf_filter.filter(
                {'class': ':CHANNEL_R$', 'hubAntlRDN': "^{}/".format(hubmod_r['distName'])})

            # get cell_r list
            cell_r_distNames = [re.match(r'(.+/CELL_R-\d+)/', channel_distName).group(1) for channel_distName in
                                channel_r_list['distName']]
            # get cell_r info from channel info
            cell_r_list = self.scf_filter.filter({'class': ':CELL_R$', 'distName': {'$in': cell_r_distNames}})

            # get rfccell_r list
            rfcport_r_list = self.scf_filter.filter(
                {'class': ':RFCPORT_R$', 'sfpPortRDN': "^{}/".format(hubmod_r['distName'])})
            rfcport_id_list = [rfcport_r['distName'].split('-')[-1] for rfcport_r in rfcport_r_list]
            rfchubgroup_r_list = self.scf_filter.filter(
                {'class': ':RFCHUBGROUP_R$', 'rfcPortRId': {'$in': rfcport_id_list}})
            rfccell_r_distNames = \
                [re.match(r'(.+/RFCCELL_R-\d+)/', rfchubgroup_r['distName']).group(1)
                 for rfchubgroup_r in rfchubgroup_r_list]
            rfccell_r_list = self.scf_filter.filter({'class': ':RFCCELL_R$', 'distName': {'$in': rfccell_r_distNames}})

            for rfccell_r in rfccell_r_list:
                rfccell = self.scf_filter.filter({'distName': "^{}$".format(rfccell_r['configDN'])})[0]
                rfccell_r.update({**rfccell, **rfccell_r})

            cell_r_list += rfccell_r_list

            # append asirCellId
            for cell_r in cell_r_list:
                if cell_r['class'].endswith(':CELL_R'):
                    bts_r_list = self.scf_filter.filter(
                        {'class': ':BTS_R$', 'distName': '/'.join(cell_r['distName'].split('/')[0:-1])})
                    cell_r['asirCellId'] = "{}.{}".format(bts_r_list[0]['targetBtsId'], cell_r['lnCelId'])
                elif cell_r['class'].endswith(':RFCCELL_R'):
                    re_match = re.search(r'/RFC-(\d+)/RFCCELL-(\d+)', cell_r['configDN'])
                    cell_r['asirCellId'] = '{}.{}'.format(re_match.group(1), re_match.group(2))

            # get rfc channel info:
            rfcchannel_r_distName_regexes = ["{}/".format(rfchubgroup_r['distName']) for rfchubgroup_r in
                                             rfchubgroup_r_list]
            rfcchannel_r_list = self.scf_filter.filter(
                {'class': ':RFCCHANNEL_R$', 'distName': {'$in_regex': rfcchannel_r_distName_regexes}})
            if channel_r_list or rfcchannel_r_list:
                dict_res[hubmod_r['distName']]['channel_info'] = (channel_r_list + rfcchannel_r_list).mo_dict()

            if cell_r_list:
                dict_res[hubmod_r['distName']]['cell_info'] = cell_r_list.mo_dict()

            # get cablink info
            cablink_r_list = self.scf_filter.filter({'class': ':CABLINK_R$', 'secondEndPointDN': hubmod_r['distName']})
            if cablink_r_list:
                dict_res[hubmod_r['distName']]['cablink_info'] = cablink_r_list.mo_dict()

            # get bbmod info
            bbmod_r_list = self.scf_filter.filter({'class': ':BBMOD_R$', 'distName': {
                '$in': [cablink_r['firstEndPointDN'] for cablink_r in cablink_r_list]}})
            if bbmod_r_list:
                dict_res[hubmod_r['distName']]['bbmod_info'] = bbmod_r_list.mo_dict()
        return dict_res

    def kw_get_asir_ant_relative_info(self):
        """
        Main Function:
            From a SCF XML, Calculate the ANTMOD_R relative info

        Arguments:
            :None

        Return Value:
            Dict of ANTMOD_R relative info
            Example:
            {
                "ASI-1/ASI_R-1/ANTMOD_R-1": {
                    "antmod_info": {
                        ...
                    },
                    "antport_info": {
                        ...
                    },
                    "hubmod_info": {
                        ...
                    },
                    "cablink_info": {
                        ...
                    },
                    "bbmod_info": {
                        ...
                    },
                    "channel_info": {
                        ...
                    },
                    "cell_info": {
                        ...
                    },
                    "bts_info": {
                        ...
                    },
                },
                "ASI-1/ASI_R-1/ANTMOD_R-2": {
                    ...
                }
            }

        Examples:
            Example 1: Get asir ant relative info
            | kw_get_asir_ant_relative_info |
        Version:
            | Author | Version | Delivery Date | Comments |
            | fuzengz | 0.0.1 | 2022/04/26 | First draft version |
            | fuzengz | 1.0.0 | 2022/05/07 | Approve Version |

        """
        dict_res = {}
        for antmod_r in self.scf_filter.filter({'class': ':ANTMOD_R$'}):
            dict_res[antmod_r['distName']] = {'antmod_info': antmod_r}
            antport_r_list = self.scf_filter.filter(
                {'class': ':ANTPORT_R$', 'distName': "{}$".format(antmod_r['antPortRDN'])})
            if antport_r_list:
                dict_res[antmod_r['distName']]['antport_info'] = antport_r_list.mo_dict()

            # get hubmod info
            hubmod_r_list = self.scf_filter.filter(
                {'class': ':HUBMOD_R$', 'distName': "{}$".format('/'.join(antmod_r['antPortRDN'].split('/')[0:-1]))})
            if hubmod_r_list:
                dict_res[antmod_r['distName']]['hubmod_info'] = hubmod_r_list.mo_dict()

            # get cablink info
            cablink_r_list = self.scf_filter.filter({'class': ':CABLINK_R$', 'secondEndPointDN': {
                '$in': [hubmod_r['distName'] for hubmod_r in hubmod_r_list]}})
            if cablink_r_list:
                dict_res[antmod_r['distName']]['cablink_info'] = cablink_r_list.mo_dict()

            # get bbmod info
            bbmod_r_list = self.scf_filter.filter({'class': ':BBMOD_R$', 'distName': {
                '$in': [cablink_r['firstEndPointDN'] for cablink_r in cablink_r_list]}})
            if bbmod_r_list:
                dict_res[antmod_r['distName']]['bbmod_info'] = bbmod_r_list.mo_dict()

            # get channel info

            hubmod_r_distNames_regexes = ["^{}/".format(hubmod_r['distName']) for hubmod_r in hubmod_r_list]
            channel_r_list = self.scf_filter.filter(
                {'class': ':CHANNEL_R$', 'hubAntlRDN': {'$in_regex': hubmod_r_distNames_regexes}})

            # get rfc channel info:

            rfcchannel_r_list = self.scf_filter.filter({'class': ':RFCCHANNEL_R$'})
            filtered_rfcchannel_r_list = [rfcchannel_r for rfcchannel_r in rfcchannel_r_list if
                                          len(DevNJ_SCF_Filter(mo_object=rfcchannel_r['antResources']).filter(
                                              {'antAntlRDN': '^{}/'.format(antmod_r["distName"])}))]
            rfcchannel_r_list = DevNJ_SCF_Filter(mo_object=filtered_rfcchannel_r_list)

            filtered_channel_r_list = [channel_r for channel_r in channel_r_list if
                                       len(DevNJ_SCF_Filter(mo_object=channel_r['antResources']).filter(
                                           {'antAntlRDN': '^{}/'.format(antmod_r["distName"])}))]
            channel_r_list = DevNJ_SCF_Filter(mo_object=filtered_channel_r_list)
            if channel_r_list or rfcchannel_r_list:
                dict_res[antmod_r['distName']]['channel_info'] = (channel_r_list + rfcchannel_r_list).mo_dict()

            # get cell_r list
            cell_r_distNames = [re.match(r'(.+/CELL_R-\d+)/', channel_distName).group(1) for channel_distName in
                                channel_r_list['distName']]
            # get cell_r info from channel info
            cell_r_list = self.scf_filter.filter({'class': ':CELL_R$', 'distName': {'$in': cell_r_distNames}})

            # get rfccell_r list
            rfccell_r_distNames = [re.match(r'(.+/RFCCELL_R-\d+)/', rfcchannel_r['distName']).group(1) for rfcchannel_r
                                   in rfcchannel_r_list]
            rfccell_r_list = self.scf_filter.filter({'class': ':RFCCELL_R$', 'distName': {'$in': rfccell_r_distNames}})
            # for rfccell_r, need to get its rfccell info and append to it

            for rfccell_r in rfccell_r_list:
                rfccell = self.scf_filter.filter({'distName': "^{}$".format(rfccell_r['configDN'])})[0]
                rfccell_r.update({**rfccell, **rfccell_r})

            cell_r_list += rfccell_r_list

            # append asirCellId
            for cell_r in cell_r_list:
                if cell_r['class'].endswith(':CELL_R'):
                    bts_r_list = self.scf_filter.filter(
                        {'class': ':BTS_R$', 'distName': '/'.join(cell_r['distName'].split('/')[0:-1])})
                    cell_r['asirCellId'] = "{}.{}".format(bts_r_list[0]['targetBtsId'], cell_r['lnCelId'])
                elif cell_r['class'].endswith(':RFCCELL_R'):
                    re_match = re.search(r'/RFC-(\d+)/RFCCELL-(\d+)', cell_r['configDN'])
                    cell_r['asirCellId'] = '{}.{}'.format(re_match.group(1), re_match.group(2))

            if cell_r_list:
                dict_res[antmod_r['distName']]['cell_info'] = cell_r_list.mo_dict()

            # append bts info
            btsRId_list = [externalRId['btsRId'] for hubmod_r in hubmod_r_list for externalRId in
                           hubmod_r.get('externalRIds')]
            bts_r_distName_regexes = ['/BTS_R-{}$'.format(bts_r_id) for bts_r_id in btsRId_list]
            bts_r_list = self.scf_filter \
                .filter({'class': ':BTS_R$', 'distName': {'$in_regex': bts_r_distName_regexes}})
            if bts_r_list:
                dict_res[antmod_r['distName']]['bts_info'] = bts_r_list.mo_dict()
        return dict_res

    def kw_get_asir_celllist_xmod_mapping(self, scf_file, mo_class, config_id_list=[], cell_type='ALL',
                                          data_type='runtime', map_reverse=False):
        """
        Main Function:
            From a SCF XML, Calculate the mapping between Cell list and xmod

        Arguments:
            :param scf_file: SCF XML Path
            :param mo_class: 1 of 'ANTMOD', 'ANTMOD_R', 'HUBMOD', 'HUBMOD_R', 'CABLINK_R'
            :param config_id_list: list of XMOD ID (eg. [1,2,3,4]), can also be a str like "1 2 3 4"
            :param cell_type: cell type, 1 of 'ALL', 'BTS', 'RFC'
            :param data_type: 1 of 'runtime','configuration'
            :param map_reverse: if revert the mapping

        Return Value:
            Dict of mapping

        Examples:
            Example 1: get mapping of ALL ANTMOD_R to BTS Cell runtime
            | ${scf_xml_file} | set variable | exmaple_scf.xml |
            Example 2: get reverse mapping of ANTMOD_R-1 and ANTMOD_R-2 to BTS Cell runtime
            | ${res} | kw_get_asir_celllist_xmod_mapping | ${scf_xml_file} | ANTMOD_R | 1 2 | BTS | runtime | ${True} |

        Version:
            | Author | Version | Delivery Date | Comments |
            | fuzengz | 0.0.1 | 2022/04/26 | First draft version |
            | fuzengz | 1.0.0 | 2022/05/07 | Approve Version |

        """
        mo_class = mo_class.upper()
        cell_type = cell_type.upper()
        data_type = data_type.lower()
        available_mo_class_list = ['ANTMOD', 'ANTMOD_R', 'HUBMOD', 'HUBMOD_R', 'CABLINK_R']
        if mo_class not in available_mo_class_list:
            raise Exception("mo_class should be 1 of {}".format(available_mo_class_list))

        available_cell_type_list = ['ALL', 'BTS', 'RFC']
        if cell_type and cell_type not in available_cell_type_list:
            raise Exception("cell_type should be None or 1 of {}".format(available_cell_type_list))

        available_data_type_list = ['runtime', 'configuration']
        if data_type and data_type not in available_data_type_list:
            raise Exception("data_type should be None or 1 of {}".format(available_data_type_list))

        cell_type = cell_type or 'ALL'
        if type(config_id_list) is str:
            config_id_list = config_id_list.split()
        config_id_list = [str(config_id) for config_id in config_id_list]
        new_kw = DevNJ_SCF_Parser_Keywords()  # avoid impact other keyword
        new_kw.load(scf_file)
        flag_mo_r = mo_class.endswith('_R')
        mo_r_class = mo_class if flag_mo_r else '{}_R'.format(mo_class)

        if mo_r_class == 'ANTMOD_R':
            dict_mo_cell = new_kw.kw_get_asir_ant_relative_info()
        elif mo_r_class == 'HUBMOD_R':
            dict_mo_cell = new_kw.kw_get_asir_hub_relative_info()
        elif mo_r_class == "CABLINK_R":
            dict_mo_cell = {}
            dict_cell = new_kw.kw_get_asir_cell_relative_info()
            for cell in dict_cell.values():
                for cablink in cell.get('cablink_info', {}).values():
                    if not dict_mo_cell.get(cablink['distName']):
                        dict_mo_cell[cablink['distName']] = {'cell_info': {}}

                    dict_mo_cell[cablink['distName']]['cell_info'][cell['cell_info']['distName']] = cell['cell_info']

        mapping_mo_r_to_mo = new_kw.kw_get_asir_xmod_r_xmod_mapping(mo_r_class)
        mo_abbrs = ['{}-{}'.format(mo_class, cfg_id) for cfg_id in config_id_list]  # ANTMOD_1 ANTMOD-R-1

        dict_res = {}
        for k, v in dict_mo_cell.items():
            mo_r_abbr = k.split('/')[-1]
            mo_abbr = mo_r_abbr if flag_mo_r else mapping_mo_r_to_mo.get(mo_r_abbr)
            if not mo_abbrs or mo_abbr in mo_abbrs:
                mo_abbr_output = mo_r_abbr if data_type.lower() == 'runtime' else mapping_mo_r_to_mo.get(
                    mo_r_abbr) or mo_r_abbr
                dict_res[mo_abbr_output] = {}
                if cell_type in ["ALL", "BTS"]:
                    bts_cell_id_list = DevNJ_SCF_Filter(mo_object=v.get('cell_info'))[''] \
                        .filter({'class': ':CELL_R$'})['asirCellId'].MO_List
                    if bts_cell_id_list:
                        dict_res[mo_abbr_output]['asir_cell_id_list'] = bts_cell_id_list
                        dict_res[mo_abbr_output]['macro_cell_id_list'] = [
                            {'targetBtsId': cell_id.split('.')[0], 'lnCelId': cell_id.split('.')[1]} for cell_id in
                            bts_cell_id_list]

                if cell_type in ["ALL", "RFC"]:
                    bts_cell_id_list = DevNJ_SCF_Filter(
                        mo_object=v.get('cell_info'))[''].filter({'class': ':RFCCELL_R$'})['asirCellId'].MO_List
                    if bts_cell_id_list:
                        dict_res[mo_abbr_output]['rfc_cell_id_list'] = bts_cell_id_list

        if map_reverse:
            dict_res_reversed = {}
            for mo_abbr, cell_info in dict_res.items():
                cell_ids = set(cell_info.get('asir_cell_id_list', []) + cell_info.get('rfc_cell_id_list', []))
                for cell_id in cell_ids:
                    if not dict_res_reversed.get(cell_id):
                        dict_res_reversed[cell_id] = []
                    if mo_abbr not in dict_res_reversed[cell_id]:
                        dict_res_reversed[cell_id].append(mo_abbr)
            return dict_res_reversed

        return dict_res

    def kw_get_antmod_antport_mapping(self, scf_file, config_id_list=[]):
        """
        Main Function:
            From a SCF XML, Calculate the mapping from ANTMOD to ANTPORT & HUBMOD

        Arguments:
            :param scf_file: SCF XML Path
            :param config_id_list: list of XMOD ID (eg. [1,2,3,4]), can also be a str like "1 2 3 4"

        Return Value:
            Dict of mapping

        Examples:
            Example 1: get mapping of ALL ANTMOD to ANTPORT & HUBMOD
            | ${scf_xml_file} | set variable | exmaple_scf.xml |
            | ${res} | kw_get_antmod_antport_mapping | ${scf_xml_file} |
            Example 2:  get mapping of ANTMOD-1 ANTMOD-2 to ANTPORT & HUBMOD
            | ${res} | kw_get_antmod_antport_mapping | ${scf_xml_file} | 1 2 |

        Version:
            | Author | Version | Delivery Date | Comments |
            | fuzengz | 0.0.1 | 2022/04/26 | First draft version |
            | fuzengz | 1.0.0 | 2022/05/07 | Approve Version |

        """
        new_kw = DevNJ_SCF_Parser_Keywords()  # avoid impact other keyword
        new_kw.load(scf_file)
        if type(config_id_list) is str:
            config_id_list = config_id_list.split()
        config_id_list = [str(config_id) for config_id in config_id_list]
        dict_res = {}
        if config_id_list:
            antmod_r_list = new_kw.scf_filter.filter(
                {'class': ':ANTMOD_R$',
                 'configDN': {'$in_regex': ['/ANTMOD-{}$'.format(id) for id in config_id_list]}})
        else:
            antmod_r_list = new_kw.scf_filter.filter({'class': ':ANTMOD_R$'})

        for antmod_r in antmod_r_list:
            antport_r_distName = re.search(r'.+/HUBMOD_R-\d+/ANTPORT_R-\d+$', antmod_r['antPortRDN']).group(0)
            antport_r_configDN = new_kw.scf_filter \
                .filter({'distName': "{}$".format(antport_r_distName)})['configDN'][0]
            re_search = re.search(r'.+/(HUBMOD)-(\d+)/(ANTPORT)-(\d+)$', antport_r_configDN)
            dict_res[antmod_r['configDN'].split('/')[-1]] = {re_search.group(1): re_search.group(2),
                                                             re_search.group(3): re_search.group(4)}
        return dict_res

    def kw_get_asir_xmod_by_rat(self, scf_file, rat='ALL', mo_class='HUBMOD'):
        """
        Main Function:
            From a SCF XML, Calculate the xmod id list base on rat, currenly is only support HUBMOD

        Arguments:
            :param scf_file: SCF XML Path
            :param mo_class: currently it only support HUBMOD
            :param rat: it can be 5g/5G, lte/LTE, mix/MIX, all/ALL, by default it's ALL

        Return Value:
            Dict of xmod and rat mapping

        Examples:
            | ${result} | KW Get Asir Xmod By RAT | scf_file=${complex_scf_path} | mo_class=HUBmod |
            | ${result} | KW Get Asir Xmod By RAT | scf_file=${complex_scf_path} | rat=5g |
            | ${result} | KW Get Asir Xmod By RAT | scf_file=${complex_scf_path} | mo_class=HUBmod | rat=LTE |
            | ${result} | KW Get Asir Xmod By RAT | scf_file=${complex_scf_path} | mo_class=HUBmod | rat=Mix |

        Version:
            | Author | Version | Delivery Date | Comments |
            | cuicuiw | 0.0.1 | 2022/05/07 | First draft version |
            | cuicuiw | 1.0.0 | 2022/05/07 | Approve Version |
        """
        available_mo_class_list = ['HUBMOD', 'HUBMOD_R']
        if mo_class.upper() not in available_mo_class_list:
            raise Exception("mo_class should be 1 of {}".format(available_mo_class_list))

        new_obj = DevNJ_SCF_Parser_Keywords()
        new_obj.load(scf_file)
        dict_res = {}

        for tech in ['5g', 'lte', 'mix']:
            if not dict_res.get(tech.lower()):
                dict_res[tech.lower()] = []

        # HUBMOD
        mo_class = mo_class if not mo_class.endswith('_R') else mo_class.split('_')[0]
        tech_list = [tech for tech in new_obj.scf_filter.filter({'class': ':BTS$'})['technology']]
        for tech in tech_list:
            bts_id_list = [bts_id.split('-')[-1] for bts_id in
                           new_obj.scf_filter.filter({'class': ':BTS$', 'technology': tech})['distName']]
            hubmod_distName_list = new_obj.scf_filter.filter({'class': ':{}$'.format(mo_class.upper()),
                                                              '$../btsId': {'$in': bts_id_list}})['distName']
            dict_res[tech.lower()] = [distName.split('-')[-1] for distName in hubmod_distName_list]

        if dict_res.get('5g') and dict_res.get('lte'):
            dict_res['mix'] = [xmod for xmod in set(dict_res.get('5g')).intersection(set(dict_res.get('lte')))]

        return {rat.lower(): dict_res.get(rat.lower(), [])} if rat.lower() != 'all' else dict_res

    def kw_get_cellid_list_by_rat(self, scf_file, rat='ALL'):
        """
        Main Function:
            From a SCF XML, Calculate the cell id list base on rat

        Arguments:
            :param scf_file: SCF XML Path
            :param rat: it can be 5g/5G, lte/LTE, all/ALL, by default it's ALL

        Return Value:
            Dict rat and cellid list pair

        Examples:
            | ${result} | KW Get Cellid List By RAT | scf_file=${complex_scf_path} |
            | ${result} | KW Get Cellid List By RAT | scf_file=${complex_scf_path} | rat=5g |
            | ${result} | KW Get Cellid List By RAT | scf_file=${complex_scf_path} | rat=LTE |

        Version:
            | Author | Version | Delivery Date | Comments |
            | cuicuiw | 0.0.1 | 2022/05/27 | First draft version |
            | cuicuiw | 1.0.0 | 2022/05/27 | Approve Version |
        """

        new_obj = DevNJ_SCF_Parser_Keywords()
        new_obj.load(scf_file)

        dict_res = {}

        for tech in ['5g', 'lte']:
            if not dict_res.get(tech.lower()):
                dict_res[tech.lower()] = []

        for cell in new_obj.scf_filter.filter({'class': ':CELL$'}):
            bts_list = new_obj.scf_filter.filter({'class': ':BTS$',
                                                  'distName': '/'.join(cell['distName'].split('/')[0:-1])})
            dict_res[bts_list[0]['technology'].lower()].append('{}.{}'.
                                                               format(bts_list[0]['targetBtsId'], cell['lnCelId']))

        return {rat.lower(): dict_res.get(rat.lower())} if rat.lower() != 'all' else dict_res

    def kw_get_xmod_list_by_cell_id(self, scf_file, mo_class='HUBMOD', cell_id={}):
        """
        Main Function:
            From a SCF XML, Calculate xmod id list base on cell id

        Arguments:
            :param scf_file: SCF XML Path
            :param mo_class: it can support HUBMOD and ANTMOD
            :param cell_id: it is a dictionary that can support BTS cell and RFC cell

        Return Value:
            Dict cell id and xmod list pair

        Examples:
        Example 1: Get humod id by BTS cell id=1.1
            | ${cell_id} | Create Dictionary | Cell=1.1 |
            | ${result} | KW Get Xmod List By Cell Id | scf_file=${file_path} | mo_class=hubmod |
            ...                                       | cell_id=${cell_id}|
        Example 2: Get antmod id by BTS cell id=1.1  1.2  2.3
            | ${cell_list} | Create List | 1.1  1.2  2.3 |
            | ${cell_id} | Create Dictionary | Cell=${cell_list}|
            | ${result} | KW Get Xmod List By Cell Id | scf_file=${file_path} | mo_class=antmod |
            ...                                       | cell_id=${cell_id}|
        Example 3: Get humod id by RFC cell id=2.2
            | ${cell_id} | Create Dictionary | RFCCell=2.2 |
            | ${result} | KW Get Xmod List By Cell Id | scf_file=${file_path} | mo_class=hubmod |
            ...                                       | cell_id=${cell_id}|
        Example 4: Get antmod id by RFC cell id=1.1  1.2  1.3
            | ${cell_list} | Create List | 1.1  1.2  1.3 |
            | ${cell_id} | Create Dictionary | RFCCell=${cell_list}|
            | ${result} | KW Get Xmod List By Cell Id | scf_file=${file_path} | mo_class=antmod |
            ...                                       | cell_id=${cell_id}|
        Example 5: Get hubmod id by RFC cell id=1.1  1.2 and BTS cell id =1.3  1.4
            | ${cell_list_1} | Create List | 1.1  1.2  |
            | ${cell_list_2} | Create List | 1.3  1.4 |
            | ${cell_id} | Create Dictionary | RFCCell=${cell_list_1} | Cell=${cell_list_2}
            | ${result} | KW Get Xmod List By Cell Id | scf_file=${file_path} | mo_class=hubmod |
            ...                                       | cell_id=${cell_id}|

        Version:
            | Author | Version | Delivery Date | Comments |
            | Zhao Longmei | 0.0.1 | 2022/07/8 | First draft version |
            | Zhao Longmei | 1.0.0 | 2022/07/11 | Approve version |
        """

        new_obj = DevNJ_SCF_Parser_Keywords()
        new_obj.load(scf_file)

        cell_id_convert = {}
        xmod_res = {}

        for k, v in cell_id.items():
            cell_id_convert[k] = v if type(v) is list else [v]

        for cell_type, cell_v in cell_id_convert.items():
            if cell_type.lower() == 'cell':
                for cell_r in new_obj.scf_filter.filter({'class': ':CELL_R$'}):
                    channel_r_list = new_obj.scf_filter.filter(
                        {'class': ':CHANNEL_R$', 'distName': '^{}/'.format(cell_r["distName"])})
                    bts_list = new_obj.scf_filter.filter({'class': ':BTS_R$',
                                                          'distName': '/'.join(cell_r['distName'].split('/')[0:-1])})
                    cell_id_asir = '{}.{}'.format(bts_list[0]['targetBtsId'], cell_r['lnCelId'])
                    if cell_id_asir in cell_v:
                        if mo_class.lower() == 'hubmod':
                            hubmod_r_distName_list = ['/'.join(channel_r['hubAntlRDN'].split('/')[0:-1]) for channel_r
                                                      in channel_r_list]
                            hubmod_r_list = new_obj.scf_filter.filter({'distName': {'$in': hubmod_r_distName_list}})
                            xmod_res[cell_id_asir] = [hubmod['configDN'].split('/')[-1] for hubmod in hubmod_r_list]
                        elif mo_class.lower() == 'antmod':
                            antmod_r_distNames = [re.match(r'(.+/ANTMOD_R-\d+)/', antRes['antAntlRDN']).group(1) for
                                                  channel_r in channel_r_list for antRes in channel_r['antResources']]
                            antmod_r_list = new_obj.scf_filter.filter({'distName': {'$in': antmod_r_distNames}})
                            xmod_res[cell_id_asir] = [antmod['configDN'].split('/')[-1] for antmod in antmod_r_list]
                        else:
                            raise ("unexpected moclass")
            elif cell_type.lower() == 'rfccell':
                for cell_r in new_obj.scf_filter.filter({'class': ':RFCCELL_R$'}):
                    channel_r_list = new_obj.scf_filter.filter(
                        {'class': 'RFCCHANNEL_R$', 'distName': '^{}/'.format(cell_r["distName"])})
                    re_match = re.search(r'/RFC-(\d+)/RFCCELL-(\d+)', cell_r['configDN'])
                    rfccell_id_asir = '{}.{}'.format(re_match.group(1), re_match.group(2))
                    if rfccell_id_asir in cell_v:
                        if mo_class.lower() == 'hubmod':
                            rfc_hub_group_r = new_obj.scf_filter.filter(
                                {'class': ':RFCHUBGROUP_R', 'distName': '^{}/'.format(cell_r["distName"])})[0]
                            rfc_port_r_list = new_obj.scf_filter.filter(
                                {'class': ':RFCPORT_R$', 'distName': '/RFCPORT_R-{}$'.
                                    format(rfc_hub_group_r["rfcPortRId"])})
                            hubmod_r_distName_list = ['/'.join(rfc_port_r['sfpPortRDN'].split('/')[0:-1]) for
                                                      rfc_port_r in rfc_port_r_list]
                            hubmod_r_list = new_obj.scf_filter.filter({'distName': {'$in': hubmod_r_distName_list}})
                            xmod_res[rfccell_id_asir] = [hubmod['configDN'].split('/')[-1] for hubmod in hubmod_r_list]
                        elif mo_class.lower() == 'antmod':
                            antmod_r_distNames = [re.match(r'(.+/ANTMOD_R-\d+)/', antRes['antAntlRDN']).group(1) for
                                                  channel_r in channel_r_list for antRes in channel_r['antResources']]
                            antmod_r_list = new_obj.scf_filter.filter({'distName': {'$in': antmod_r_distNames}})
                            xmod_res[rfccell_id_asir] = [antmod['configDN'].split('/')[-1] for antmod in antmod_r_list]
                        else:
                            raise ("unexpected moclass")
        return xmod_res

    def kw_get_antmod_list_by_hubmod_id(self, scf_file, hubmod_id=None, poeStatus=None):
        """
        Main Function:
            From a SCF XML, Calculate antmod id list base on hubmod id

        Arguments:
            :param scf_file: SCF XML Path
            :param hubmod_id: hubmod id
            :param poeStatus: antport status. If only wants to get enabled antport related antmod id, you can set
            ...               parameter of poeStatus='enabled'.

        Return Value:
            Dict hubmod id and antmod id list pair

        Examples:
        Example 1: Get all related antmod id by all hubmod id
            | ${result} | KW Get Antmod List By Hubmod Id | scf_file=${file_path} |
        Example 2: Get antmod id by hubmod id=1
            | ${result} | KW Get Antmod List By Hubmod Id | scf_file=${file_path} | hubmod_id=1 |
        Example 3: Get antmod id by hubmod id=1 2
            | ${result} | KW Get Antmod List By Hubmod Id | scf_file=${file_path} | hubmod_id=1 2|
        Example 4: Get enabled antport related antmod id by hubmod id=1
            | ${result} | KW Get Antmod List By Hubmod Id | scf_file=${file_path} | hubmod_id=1 | poeStatus=enabled |

        Version:
            | Author | Version | Delivery Date | Comments |
            | Zhao Longmei | 0.0.1 | 2022/07/12 | First draft version |
            | Zhao Longmei | 1.0.0 | 2022/07/12 | Approve version |
        """

        if not hubmod_id:
            hubmod_id = []

        if isinstance(hubmod_id, str):
            hubmod_id = hubmod_id.split()

        new_obj = DevNJ_SCF_Parser_Keywords()
        new_obj.load(scf_file)

        dict_res = {}

        for hubmod_r in new_obj.scf_filter.filter({'class': ':HUBMOD_R$'}):
            antmod_r_list = new_obj.scf_filter.filter(
                {'class': ':ANTMOD_R$', 'antPortRDN': "^{}/".format(hubmod_r['distName'])})
            if not hubmod_id or str(hubmod_r['configDN'].split('-')[-1]) in [str(hubmod_id_each) for
                                                                             hubmod_id_each in hubmod_id]:
                if poeStatus:
                    dict_res[hubmod_r['configDN'].split('/')[-1]] = []
                    for antmod_r in antmod_r_list:
                        antport_r = new_obj.scf_filter.filter({'class': ':ANTPORT_R$', 'distName': '{}$'.
                                                              format(antmod_r['antPortRDN'])})
                        if antport_r[0]['poeStatus'] == poeStatus.lower():
                            dict_res[hubmod_r['configDN'].split('/')[-1]].append(antmod_r['configDN'].split('/')[-1])
                else:
                    dict_res[hubmod_r['configDN'].split('/')[-1]] = [antmod['configDN'].split('/')[-1] for antmod in
                                                                     antmod_r_list]
        return dict_res

    def kw_get_active_cell_id_list_by_ru_id(self, scf_file, ru_id_list=[], mo_class="ASIRMOD"):
        """
        Main Function:
            From a SCF XML, Calculate cell list base on asirmod/rmod id

        Arguments:
            :param scf_file: SCF XML Path, scf should have runtime object, when save scf please use parameter
            export_type=configurationAndRuntimeObjects
            :param ru_id_list: list or str of asirmod/rmod id
            :param mo_class, ma class in scf, currently support "ASIRMOD", "ASIRMOD_R", "RMOD", "RMOD_R" 4 values

        Return Value:
            Dict asirmod/rmod id and nr/lte cell list pair

        Examples:
        Example 1: Get all asirmod id's cell list
            | ${result} | KW Get Active Cell Id List By RU Id | scf_file=${file_path} | mo_class=ASIRMOD |
        Example 2: Get cell list by asirmod id=1
            | ${result} | KW Get Active Cell Id List By RU Id | scf_file=${file_path} | ru_id_list=1 | mo_class=RMOD |
        Example 3: Get cell list by asirmod id=1 2
            | ${result} | KW Get Active Cell Id List By RU Id | scf_file=${file_path} | ru_id_list=1 2 | mo_class=RMOD |

        Version:
            | Author | Version | Delivery Date | Comments |
            | Zhao Longmei | 0.0.1 | 2022/07/13 | First draft version |
            | Zhao Longmei | 1.0.0 | 2022/07/13 | Approve version |
            | Wang Cuicui | 1.0.1 | 2023/01/12 | Change to support both ASIRMOD and RMOD |
        """

        available_mo_class_list = ["ASIRMOD", "ASIRMOD_R", "RMOD", "RMOD_R"]
        if mo_class.upper() not in available_mo_class_list:
            raise Exception("mo_class should be 1 of {}".format(available_mo_class_list))

        mo_class_r = mo_class.upper() if mo_class.upper().endswith("_R") else mo_class.upper() + "_R"
        ru_id_list = ru_id_list if type(ru_id_list) is list else ru_id_list.split()

        new_obj = DevNJ_SCF_Parser_Keywords()
        new_obj.load(scf_file)
        new_obj.scf_filter.dump("/home/ute/xml_to_dict.json")

        dict_res = {}

        rmod_r_list = new_obj.scf_filter.filter({"class": ":{}$".format(mo_class_r)})
        if not rmod_r_list:
            raise Exception("Please use full commision file to get {} object or give the right mo_class: {}".
                            format(rmod_r_list, available_mo_class_list))

        for rmod_r in rmod_r_list:
            if not ru_id_list or str(rmod_r["configDN"].split("-")[-1]) in [str(rmod_id_each) for
                                                                            rmod_id_each in ru_id_list]:
                if not dict_res.get(rmod_r["configDN"].split("/")[-1]):
                    dict_res[rmod_r["configDN"].split("/")[-1]] = {}

                for tech in ["Nr", "Lte"]:
                    if rmod_r.get("active{}CellsList".format(tech)):
                        if not dict_res[rmod_r["configDN"].split("/")[-1]].get(tech.lower()):
                            dict_res[rmod_r["configDN"].split("/")[-1]][tech.lower()] = []
                        if type(rmod_r.get("active{}CellsList".format(tech))) is list:
                            dict_res[rmod_r["configDN"].split("/")[-1]][tech.lower()] += \
                                rmod_r["active{}CellsList".format(tech)]
                        else:
                            dict_res[rmod_r["configDN"].split("/")[-1]][tech.lower()]. \
                                append(rmod_r["active{}CellsList".format(tech)])
        return dict_res

    def kw_get_active_cell_id_list_by_ru_variant(self, scf_file, ru_variant_list=[]):
        """
        Main Function:
            From a SCF XML, Calculate cell list base on variant

        Arguments:
            :param scf_file: SCF XML Path, scf should have runtime object, when save scf please use parameter
            export_type=configurationAndRuntimeObjects
            :param ru_variant_list: list or str of variant type

        Return Value:
            Dict variant type and lte/nr cell list pair

        Examples:
        Example 1: Get all asirmod id's cell list
            | ${result} | KW Get Active Cell Id List By RU Variant | scf_file=${file_path} |
        Example 2: Get cell list by asirmod id=1
            | ${result} | KW Get Active Cell Id List By RU Variant | scf_file=${file_path} | ru_variant_list=APHG |

        Version:
            | Author | Version | Delivery Date | Comments |
            | Wang Cuicui | 1.0.0 | 2023/01/12 | First Approved version by VA |

        """

        available_mo_class_list = ["ASIRMOD_R", "RMOD_R"]

        ru_variant_list = ru_variant_list if type(ru_variant_list) is list else ru_variant_list.split()

        new_obj = DevNJ_SCF_Parser_Keywords()
        new_obj.load(scf_file)
        new_obj.scf_filter.dump("/home/ute/xml_to_dict.json")

        dict_res = {}

        for mo_class in available_mo_class_list:
            rmod_r_list = new_obj.scf_filter.filter({"class": ":{}$".format(mo_class)})
            if not rmod_r_list:
                continue

            for rmod_r in rmod_r_list:
                if not ru_variant_list or str(rmod_r["productName"]) in [str(rmod_variant_each) for
                                                                         rmod_variant_each in ru_variant_list]:
                    if not dict_res.get(rmod_r["productName"]):
                        dict_res[rmod_r["productName"]] = {}

                    for tech in ["Nr", "Lte"]:
                        if rmod_r.get("active{}CellsList".format(tech)):
                            if not dict_res[rmod_r["productName"]].get(tech.lower()):
                                dict_res[rmod_r["productName"]][tech.lower()] = []
                            if type(rmod_r.get("active{}CellsList".format(tech))) is list:
                                dict_res[rmod_r["productName"]][tech.lower()] += \
                                    rmod_r["active{}CellsList".format(tech)]
                            else:
                                dict_res[rmod_r["productName"]][tech.lower()]. \
                                    append(rmod_r["active{}CellsList".format(tech)])
        return dict_res

    def kw_get_cell_id_list_by_ru_id(self, scf_file, ru_id_list=[], mo_class="ASIRMOD"):
        """
        Main Function:
            From a SCF XML, Calculate cell list base on asirmod/rmod id

        Arguments:
            :param scf_file: SCF XML Path, scf should have runtime object, when save scf please use parameter
            export_type=configurationAndRuntimeObjects
            :param ru_id_list: list or str of asirmod/rmod id
            :param mo_class, ma class in scf, currently support "ASIRMOD",  "RMOD" two values

        Return Value:
            Dict asirmod/rmod id and nr/lte cell list pair

        Examples:
        Example 1: Get all asirmod id's cell list
            | ${result} | KW Get Cell Id List By RU Id | scf_file=${file_path} | mo_class=ASIRMOD |
        Example 2: Get cell list by asirmod id=1
            | ${result} | KW Get Cell Id List By RU Id | scf_file=${file_path} | ru_id_list=1 | mo_class=RMOD |
        Example 3: Get cell list by asirmod id=1 2
            | ${result} | KW Get Cell Id List By RU Id | scf_file=${file_path} | ru_id_list=1 2 | mo_class=RMOD |

        Version:
            | Author | Version | Delivery Date | Comments |
            | Wang Cuicui | 1.0.0 | 2023/01/12 | First approved version by VA |
        """

        available_mo_class_list = ["ASIRMOD", "RMOD"]
        if mo_class.upper() not in available_mo_class_list:
            raise Exception("mo_class should be 1 of {}".format(available_mo_class_list))

        ru_id_list = ru_id_list if type(ru_id_list) is list else ru_id_list.split()

        new_obj = DevNJ_SCF_Parser_Keywords()
        new_obj.load(scf_file)
        new_obj.scf_filter.dump("/home/ute/xml_to_dict.json")

        dict_res = {}

        channel_list = new_obj.scf_filter.filter({"class": ":CHANNEL$"})
        if not channel_list:
            raise Exception("Please use full commision file with channel info like: com.nokia.srbts.mnl:CHANNEL")

        for channel_each in channel_list:
            if channel_each.get("antlDN"):
                rmod = re.search(r"/({}-(\d+))/".format(mo_class.upper()), channel_each.get("antlDN"))
                if rmod:
                    if not ru_id_list or rmod.group(2) in ru_id_list:
                        if not dict_res.get(rmod.group(1)):
                            dict_res[rmod.group(1)] = {}
                        cell = re.search(r"/(LCEL(\w*)-(\d+))/", channel_each.get("distName"), re.I)
                        if "nr" in cell.group(1).lower():
                            if not dict_res[rmod.group(1)].get("nr"):
                                dict_res[rmod.group(1)]["nr"] = []
                            if cell.group(3) not in dict_res[rmod.group(1)]["nr"]:
                                dict_res[rmod.group(1)]["nr"].append(cell.group(3))
                        else:
                            if not dict_res[rmod.group(1)].get("lte"):
                                dict_res[rmod.group(1)]["lte"] = []
                            if cell.group(3) not in dict_res[rmod.group(1)]["lte"]:
                                dict_res[rmod.group(1)]["lte"].append(cell.group(3))
            else:
                log_warning("Can't find antlDN info in channel: {}".format(channel_each))
        return dict_res

    def kw_get_cell_id_list_by_ru_variant(self, scf_file, ru_variant_list=[]):
        """
        Main Function:
            From a SCF XML, Calculate cell list base on variant

        Arguments:
            :param scf_file: SCF XML Path, scf should have runtime object, when save scf please use parameter
            export_type=configurationAndRuntimeObjects
            :param ru_variant_list: list or str of variant type

        Return Value:
            Dict variant type and lte/nr cell list pair

        Examples:
        Example 1: Get all asirmod id's cell list
            | ${result} | KW Get Cell Id List By RU Variant | scf_file=${file_path} |
        Example 2: Get cell list by asirmod id=1
            | ${result} | KW Get Cell Id List By RU Variant | scf_file=${file_path} | ru_variant_list=APHG |

        Version:
            | Author | Version | Delivery Date | Comments |
            | Wang Cuicui | 1.0.0 | 2023/01/13 | First Approved version by VA |

        """

        ru_variant_list = ru_variant_list if type(ru_variant_list) is list else ru_variant_list.split()

        new_obj = DevNJ_SCF_Parser_Keywords()
        new_obj.load(scf_file)
        new_obj.scf_filter.dump("/home/ute/xml_to_dict.json")

        dict_res = {}
        dict_variant_rmod_id_mapping = {}
        rmod_r_list = new_obj.scf_filter.filter({"class": ":(RMOD_R|ASIRMOD_R)$"})
        if rmod_r_list:
            for rmod_r_each in rmod_r_list:
                if not ru_variant_list or rmod_r_each.get("productName") in ru_variant_list:
                    dict_res[rmod_r_each.get("productName")] = {}
                    if not dict_variant_rmod_id_mapping.get(rmod_r_each.get("productName")):
                        dict_variant_rmod_id_mapping[rmod_r_each.get("productName")] = []
                    if rmod_r_each["configDN"].split("/")[-1] not in \
                            dict_variant_rmod_id_mapping[rmod_r_each.get("productName")]:
                        dict_variant_rmod_id_mapping[rmod_r_each.get("productName")].append(
                            rmod_r_each["configDN"].split("/")[-1])

        # print(dict_variant_rmod_id_mapping)
        # print(dict_res)

        channel_list = new_obj.scf_filter.filter({"class": ":CHANNEL$"})
        if not channel_list:
            raise Exception("Please use full commision file with channel info like: com.nokia.srbts.mnl:CHANNEL")

        for variant, rmod_list in dict_variant_rmod_id_mapping.items():
            for rmod_each in rmod_list:
                for channel_each in channel_list:
                    if channel_each.get("antlDN"):
                        if re.search(r"/{}/".format(rmod_each), channel_each.get("antlDN")):
                            cell = re.search(r"/(LCEL(\w*)-(\d+))/", channel_each.get("distName"))
                            if "nr" in cell.group(2).lower():
                                if not dict_res[variant].get("nr"):
                                    dict_res[variant]["nr"] = []
                                if cell.group(3) not in dict_res[variant].get("nr"):
                                    dict_res[variant]["nr"].append(cell.group(3))
                            else:
                                if not dict_res[variant].get("lte"):
                                    dict_res[variant]["lte"] = []
                                if cell.group(3) not in dict_res[variant].get("lte"):
                                    dict_res[variant]["lte"].append(cell.group(3))
                    else:
                        log_warning("Can't find antlDN info in channel: {}".format(channel_each))

        return dict_res

    def kw_get_hubmod_id_by_asirmod_id(self, scf_file, asirmod_id=None):
        """
        Main Function:
            From a SCF XML, Calculate hubmod id base on asirmod id

        Arguments:
            :param scf_file: SCF XML Path
            :param asirmod_id: asirmod id

        Return Value:
            Dict asirmod id and hubmod id pair

        Examples:
        Example 1: Get all asirmod id's hubmod id
            | ${result} | KW Get Hubmod Id By Asirmod Id | scf_file=${file_path} |
        Example 2: Get hubmod id  by asirmod id=1
            | ${result} | KW Get Hubmod Id By Asirmod Id | scf_file=${file_path} | asirmod_id=1 |
        Example 3: Get cell list by hubmod id=1 2
            | ${result} | KW Get Hubmod Id By Asirmod Id | scf_file=${file_path} | asirmod_id=1 2 |
        Example 4: Get cell list by hubmod id=1 2
            | ${asirmod_id} | Create list | 1  2 |
            | ${result} | KW Get Hubmod Id By Asirmod Id | scf_file=${file_path} | asirmod_id=${asirmod_id} |

        Version:
            | Author | Version | Delivery Date | Comments |
            | Zhao Longmei | 0.0.1 | 2022/08/05 | First draft version |
            | Zhao Longmei | 1.0.0 | 2022/08/05 | Approve version |
        """

        new_obj = DevNJ_SCF_Parser_Keywords()
        new_obj.load(scf_file)

        if not asirmod_id:
            asirmod_id = []

        if isinstance(asirmod_id, str):
            asirmod_id = asirmod_id.split()

        dict_res = {}

        for hubmod in new_obj.scf_filter.filter({'class': ':HUBMOD$'}):
            for asirmod_bts_id in hubmod['externalIds']:
                asirmod = asirmod_bts_id['asiRmodId']
                if not asirmod_id or asirmod in asirmod_id:
                    dict_res[asirmod] = hubmod['distName'].split('-')[-1]

        return dict_res


if __name__ == '__main__':
    """
       Examples
    """
    # scf_xml_file = "/home/ute/Runtime_Configuration_scf_MRBTS-66196_CB008271_US5_FDD+TDD_1_20221213-0715.xml"
    scf_xml_file = "/home/ute/Full_Configuration_scf_MRBTS-67198_7_21_UTE5G067TL198_20230113-0404.xml"
    kw = DevNJ_SCF_Parser_Keywords()
    dict_res = kw.kw_get_active_cell_id_list_by_ru_id(scf_xml_file, mo_class="ASIRMOD")
    print(dict_res)
    with open("/home/ute/kw_get_cell_list_by_radio_mod.json", "w+") as f:
        json.dump(dict_res, f)
    dict_res = kw.kw_get_active_cell_id_list_by_ru_variant(scf_xml_file)
    print(dict_res)
    dict_res = kw.kw_get_cell_id_list_by_ru_id(scf_xml_file, mo_class="ASIRMOD")
    print(dict_res)

    dict_res = kw.kw_get_cell_id_list_by_ru_id(scf_xml_file, ru_id_list=["4"], mo_class="ASIRMOD")
    print(dict_res)

    dict_res = kw.kw_get_cell_id_list_by_ru_variant(scf_xml_file)
    print(dict_res)

    dict_res = kw.kw_get_cell_id_list_by_ru_variant(scf_xml_file, ru_variant_list="APHA APHG AWHQX AHFB")
    print(dict_res)

    scf_xml_file = './Configuration_asir_MRBTS-68203_SBTS22R3_ENB_9999_220406_000006_20220407-1838.xml'
    kw = DevNJ_SCF_Parser_Keywords()
    kw.load(scf_xml_file)
    kw.scf_filter.dump("./test/xml_to_dict.json")
    dict_res = kw.kw_get_asir_cell_relative_info()
    with open("./test/kw_asir_cell_relative_info.json", "w+") as f:
        json.dump(dict_res, f)

    dict_res = kw.kw_get_asir_hub_relative_info()
    with open("./test/kw_asir_hub_relative_info.json", "w+") as f:
        json.dump(dict_res, f)

    dict_res = kw.kw_get_asir_ant_relative_info()
    with open("./test/kw_asir_ant_relative_info.json", "w+") as f:
        json.dump(dict_res, f)

    dict_res = kw.kw_get_asir_xmod_r_xmod_mapping('ANTMOD_R')
    with open("./test/kw_get_asir_xmod_r_xmod_mapping.json", "w+") as f:
        json.dump(dict_res, f)

    scf_xml_file = "./Configuration_asir_MRBTS-68203_SBTS22R3_ENB_9999_220406_000006_20220407-1838.xml"

    test_mo_classes = ['ANTMOD_R', 'HUBMOD_R', 'ANTMOD', 'HUBMOD']
    config_id_lists = [[], [1, 2], ['2', 3, '4'], [1, 2, 3, 4]]
    for test_mo_class in test_mo_classes:
        for config_id_list in config_id_lists:
            for cell_type in ['ALL', 'BTS', 'RFC']:
                for data_type in ['runtime', 'configuration']:
                    for map_reverse in [True, False]:
                        dict_res = kw.kw_get_asir_celllist_xmod_mapping(scf_file=scf_xml_file, mo_class=test_mo_class,
                                                                        config_id_list=config_id_list,
                                                                        cell_type=cell_type, data_type=data_type,
                                                                        map_reverse=map_reverse)
                        str_config_id_lists = '_'.join(
                            [str(config_id) for config_id in config_id_list]) if config_id_list else 'all'
                        file_name = "./test/kw_get_asir_celllist_from_xmod_{}_{}_cell_{}_{}_{}.json".format(
                            test_mo_class, str_config_id_lists, cell_type, data_type, 'reverse' if map_reverse else '')
                        with open(file_name, "w+") as f:
                            json.dump(dict_res, f)

    test_mo_classes = ['CABLINK_R']
    config_id_lists = [[2, 5, 9]]
    for test_mo_class in test_mo_classes:
        for config_id_list in config_id_lists:
            for cell_type in ['ALL', 'BTS', 'RFC']:
                for data_type in ['runtime', 'configuration']:
                    for map_reverse in [True]:
                        dict_res = kw.kw_get_asir_celllist_xmod_mapping(scf_file=scf_xml_file, mo_class=test_mo_class,
                                                                        config_id_list=config_id_list,
                                                                        cell_type=cell_type, data_type=data_type,
                                                                        map_reverse=map_reverse)
                        str_config_id_lists = '_'.join(
                            [str(config_id) for config_id in config_id_list]) if config_id_list else 'all'
                        file_name = "./test/kw_get_asir_celllist_from_xmod_{}_{}_cell_{}_{}_{}.json".format(
                            test_mo_class, str_config_id_lists, cell_type, data_type, 'reverse' if map_reverse else '')
                        with open(file_name, "w+") as f:
                            json.dump(dict_res, f)

    config_id_lists = [[], [1, '2', '4']]
    for config_id_list in config_id_lists:
        dict_res = kw.kw_get_antmod_antport_mapping(scf_file=scf_xml_file, config_id_list=config_id_list)
        str_config_id_lists = '_'.join([str(config_id) for config_id in config_id_list]) if config_id_list else 'all'
        file_name = "./test/kw_get_antmod_antport_mapping_{}.json".format(str_config_id_lists)
        with open(file_name, "w+") as f:
            json.dump(dict_res, f)
