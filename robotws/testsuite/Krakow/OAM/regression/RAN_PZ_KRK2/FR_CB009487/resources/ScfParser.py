import re
from testsuite.Krakow.OAM.regression.RAN_PZ_KRK2.FR_CB008325_CB008827_CB009180.resources.ScfFilter import ScfFilter


class ScfParser(object):
    def __init__(self):
        self.scf_filter = ScfFilter()

    def loads(self, scf_text):
        self.scf_filter.loads(scf_text)

    def load(self, scf_path):
        self.scf_filter.load(scf_path)

    def kw_get_asir_xmod_r_xmod_mapping(self, mo_r_class):
        if not mo_r_class.endswith('_R'):
            raise Exception("parameter mo_r_class '{}' doesn't end with '_R'".format(mo_r_class))
        mo_r_list = self.scf_filter.filter({'class': ':{}$'.format(mo_r_class)}).project(
            display_keys=['distName', 'configDN'])
        return dict(
            [(mo['distName'].split('/')[-1], mo.get('configDN', '').split('/')[-1] or None) for mo in mo_r_list])

    def kw_get_asir_cell_relative_info(self):
        dict_res = {}
        for cell_r in self.scf_filter.filter({'class': ':(CELL_R|RFCCELL_R)$'}):
            if cell_r['class'].endswith(':RFCCELL_R'):
                rfc_cell = self.scf_filter.filter({'distName': "^{}$".format(cell_r['configDN'])})[0]
                cell_r = {**rfc_cell, **cell_r}

            dict_res[cell_r['distName']] = {'cell_info': cell_r}
            if cell_r['class'].endswith(':CELL_R'):
                bts_r_list = self.scf_filter.filter(
                    {'class': ':BTS_R$', 'distName': '/'.join(cell_r['distName'].split('/')[0:-1])})
                dict_res[cell_r['distName']]['bts_info'] = bts_r_list.mo_dict()

            if cell_r['class'].endswith(':CELL_R'):
                cell_r['asirCellId'] = "{}.{}".format(bts_r_list[0]['targetBtsId'], cell_r['lnCelId'])
            elif cell_r['class'].endswith(':RFCCELL_R'):
                re_match = re.search(r'/RFC-(\d+)/RFCCELL-(\d+)', cell_r['configDN'])
                cell_r['asirCellId'] = '{}.{}'.format(re_match.group(1), re_match.group(2))

            channel_r_list = self.scf_filter.filter(
                {'class': ':(CHANNEL_R|RFCCHANNEL_R)$', 'distName': '^{}/'.format(cell_r["distName"])})
            if channel_r_list:
                dict_res[cell_r['distName']]['channel_info'] = channel_r_list.mo_dict()

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
                raise AttributeError("unexpected cell")

            if hubmod_r_list:
                dict_res[cell_r['distName']]['hubmod_info'] = hubmod_r_list.mo_dict()

            antmod_r_distNames = [re.match(r'(.+/ANTMOD_R-\d+)/', antRes['antAntlRDN']).group(1) for channel_r in
                                  channel_r_list for antRes in channel_r['antResources']]
            antmod_r_list = self.scf_filter.filter({'distName': {'$in': antmod_r_distNames}})
            if antmod_r_list:
                dict_res[cell_r['distName']]['antmod_info'] = antmod_r_list.mo_dict()

            antport_r_distNames = [antmod_r['antPortRDN'] for antmod_r in antmod_r_list]
            antport_r_list = self.scf_filter.filter({'distName': {'$in': antport_r_distNames}})
            if antport_r_list:
                dict_res[cell_r['distName']]['antport_info'] = antport_r_list.mo_dict()

            if cell_r['class'].endswith(':CELL_R'):
                cablink_r_list = self.scf_filter.filter(
                    {'class': ':CABLINK_R$', 'firstEndPointDN': '^{}/'.format(bts_r_list[0]["distName"]),
                     'secondEndPointDN': {'$in': [hubmod_r['distName'] for hubmod_r in hubmod_r_list]}})
                if cablink_r_list:
                    dict_res[cell_r['distName']]['cablink_info'] = cablink_r_list.mo_dict()

                bbmod_r_list = self.scf_filter.filter({'class': ':BBMOD_R$', 'distName': {
                    '$in': [cablink_r['firstEndPointDN'] for cablink_r in cablink_r_list]}})
                if bbmod_r_list:
                    dict_res[cell_r['distName']]['bbmod_info'] = bbmod_r_list.mo_dict()
        return dict_res

    def kw_get_asir_hub_relative_info(self):
        dict_res = {}
        for hubmod_r in self.scf_filter.filter({'class': ':HUBMOD_R$'}):
            dict_res[hubmod_r['distName']] = {'hub_info': hubmod_r}
            bts_distName_regexes = ["/BTS_R-{}$".format(externalRId.get('btsRId')) for externalRId in
                                    hubmod_r.get('externalRIds', [])]
            bts_r_list = self.scf_filter.filter({'class': ':BTS_R$', 'distName': {'$in_regex': bts_distName_regexes}})
            if bts_r_list:
                dict_res[hubmod_r['distName']]['bts_info'] = bts_r_list.mo_dict()

            antmod_r_list = self.scf_filter.filter(
                {'class': ':ANTMOD_R$', 'antPortRDN': "^{}/".format(hubmod_r['distName'])})
            if antmod_r_list:
                dict_res[hubmod_r['distName']]['antmod_info'] = antmod_r_list.mo_dict()

            antport_r_distNames = [antmod_r['antPortRDN'] for antmod_r in antmod_r_list]
            antport_r_list = self.scf_filter.filter({'distName': {'$in': antport_r_distNames}})
            if antport_r_list:
                dict_res[hubmod_r['distName']]['antport_info'] = antport_r_list.mo_dict()

            channel_r_list = self.scf_filter.filter(
                {'class': ':CHANNEL_R$', 'hubAntlRDN': "^{}/".format(hubmod_r['distName'])})

            cell_r_distNames = [re.match(r'(.+/CELL_R-\d+)/', channel_distName).group(1) for channel_distName in
                                channel_r_list['distName']]
            cell_r_list = self.scf_filter.filter({'class': ':CELL_R$', 'distName': {'$in': cell_r_distNames}})

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

            for cell_r in cell_r_list:
                if cell_r['class'].endswith(':CELL_R'):
                    bts_r_list = self.scf_filter.filter(
                        {'class': ':BTS_R$', 'distName': '/'.join(cell_r['distName'].split('/')[0:-1])})
                    cell_r['asirCellId'] = "{}.{}".format(bts_r_list[0]['targetBtsId'], cell_r['lnCelId'])
                elif cell_r['class'].endswith(':RFCCELL_R'):
                    re_match = re.search(r'/RFC-(\d+)/RFCCELL-(\d+)', cell_r['configDN'])
                    cell_r['asirCellId'] = '{}.{}'.format(re_match.group(1), re_match.group(2))

            rfcchannel_r_distName_regexes = ["{}/".format(rfchubgroup_r['distName']) for rfchubgroup_r in
                                             rfchubgroup_r_list]
            rfcchannel_r_list = self.scf_filter.filter(
                {'class': ':RFCCHANNEL_R$', 'distName': {'$in_regex': rfcchannel_r_distName_regexes}})
            if channel_r_list or rfcchannel_r_list:
                dict_res[hubmod_r['distName']]['channel_info'] = (channel_r_list + rfcchannel_r_list).mo_dict()

            if cell_r_list:
                dict_res[hubmod_r['distName']]['cell_info'] = cell_r_list.mo_dict()

            cablink_r_list = self.scf_filter.filter({'class': ':CABLINK_R$', 'secondEndPointDN': hubmod_r['distName']})
            if cablink_r_list:
                dict_res[hubmod_r['distName']]['cablink_info'] = cablink_r_list.mo_dict()

            bbmod_r_list = self.scf_filter.filter({'class': ':BBMOD_R$', 'distName': {
                '$in': [cablink_r['firstEndPointDN'] for cablink_r in cablink_r_list]}})
            if bbmod_r_list:
                dict_res[hubmod_r['distName']]['bbmod_info'] = bbmod_r_list.mo_dict()
        return dict_res

    def kw_get_asir_ant_relative_info(self):
        dict_res = {}
        for antmod_r in self.scf_filter.filter({'class': ':ANTMOD_R$'}):
            dict_res[antmod_r['distName']] = {'antmod_info': antmod_r}
            antport_r_list = self.scf_filter.filter(
                {'class': ':ANTPORT_R$', 'distName': "{}$".format(antmod_r['antPortRDN'])})
            if antport_r_list:
                dict_res[antmod_r['distName']]['antport_info'] = antport_r_list.mo_dict()

            hubmod_r_list = self.scf_filter.filter(
                {'class': ':HUBMOD_R$', 'distName': "{}$".format('/'.join(antmod_r['antPortRDN'].split('/')[0:-1]))})
            if hubmod_r_list:
                dict_res[antmod_r['distName']]['hubmod_info'] = hubmod_r_list.mo_dict()

            cablink_r_list = self.scf_filter.filter({'class': ':CABLINK_R$', 'secondEndPointDN': {
                '$in': [hubmod_r['distName'] for hubmod_r in hubmod_r_list]}})
            if cablink_r_list:
                dict_res[antmod_r['distName']]['cablink_info'] = cablink_r_list.mo_dict()

            bbmod_r_list = self.scf_filter.filter({'class': ':BBMOD_R$', 'distName': {
                '$in': [cablink_r['firstEndPointDN'] for cablink_r in cablink_r_list]}})
            if bbmod_r_list:
                dict_res[antmod_r['distName']]['bbmod_info'] = bbmod_r_list.mo_dict()

            hubmod_r_distNames_regexes = ["^{}/".format(hubmod_r['distName']) for hubmod_r in hubmod_r_list]
            channel_r_list = self.scf_filter.filter(
                {'class': ':CHANNEL_R$', 'hubAntlRDN': {'$in_regex': hubmod_r_distNames_regexes}})

            rfcchannel_r_list = self.scf_filter.filter({'class': ':RFCCHANNEL_R$'})
            filtered_rfcchannel_r_list = [rfcchannel_r for rfcchannel_r in rfcchannel_r_list if
                                          len(ScfFilter(mo_object=rfcchannel_r['antResources']).filter(
                                              {'antAntlRDN': '^{}/'.format(antmod_r["distName"])}))]
            rfcchannel_r_list = ScfFilter(mo_object=filtered_rfcchannel_r_list)

            filtered_channel_r_list = [channel_r for channel_r in channel_r_list if
                                       len(ScfFilter(mo_object=channel_r['antResources']).filter(
                                           {'antAntlRDN': '^{}/'.format(antmod_r["distName"])}))]
            channel_r_list = ScfFilter(mo_object=filtered_channel_r_list)
            if channel_r_list or rfcchannel_r_list:
                dict_res[antmod_r['distName']]['channel_info'] = (channel_r_list + rfcchannel_r_list).mo_dict()

            cell_r_distNames = [re.match(r'(.+/CELL_R-\d+)/', channel_distName).group(1) for channel_distName in
                                channel_r_list['distName']]
            cell_r_list = self.scf_filter.filter({'class': ':CELL_R$', 'distName': {'$in': cell_r_distNames}})

            rfccell_r_distNames = [re.match(r'(.+/RFCCELL_R-\d+)/', rfcchannel_r['distName']).group(1) for rfcchannel_r
                                   in rfcchannel_r_list]
            rfccell_r_list = self.scf_filter.filter({'class': ':RFCCELL_R$', 'distName': {'$in': rfccell_r_distNames}})

            for rfccell_r in rfccell_r_list:
                rfccell = self.scf_filter.filter({'distName': "^{}$".format(rfccell_r['configDN'])})[0]
                rfccell_r.update({**rfccell, **rfccell_r})

            cell_r_list += rfccell_r_list

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

            btsRId_list = [externalRId['btsRId'] for hubmod_r in hubmod_r_list for externalRId in
                           hubmod_r.get('externalRIds')]
            bts_r_distName_regexes = ['/BTS_R-{}$'.format(bts_r_id) for bts_r_id in btsRId_list]
            bts_r_list = self.scf_filter \
                .filter({'class': ':BTS_R$', 'distName': {'$in_regex': bts_r_distName_regexes}})
            if bts_r_list:
                dict_res[antmod_r['distName']]['bts_info'] = bts_r_list.mo_dict()
        return dict_res

    @staticmethod
    def kw_get_asir_celllist_xmod_mapping(scf_file, mo_class, config_id_list=[], cell_type='ALL',
                                          data_type='runtime', map_reverse=False):
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
        new_kw = ScfParser()
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
        mo_abbrs = ['{}-{}'.format(mo_class, cfg_id) for cfg_id in config_id_list]

        dict_res = {}
        for k, v in dict_mo_cell.items():
            mo_r_abbr = k.split('/')[-1]
            mo_abbr = mo_r_abbr if flag_mo_r else mapping_mo_r_to_mo.get(mo_r_abbr)
            if not mo_abbrs or mo_abbr in mo_abbrs:
                mo_abbr_output = mo_r_abbr if data_type.lower() == 'runtime' else mapping_mo_r_to_mo.get(
                    mo_r_abbr) or mo_r_abbr
                dict_res[mo_abbr_output] = {}
                if cell_type in ["ALL", "BTS"]:
                    bts_cell_id_list = ScfFilter(mo_object=v.get('cell_info'))[''] \
                        .filter({'class': ':CELL_R$'})['asirCellId'].MO_List
                    if bts_cell_id_list:
                        dict_res[mo_abbr_output]['asir_cell_id_list'] = bts_cell_id_list
                        dict_res[mo_abbr_output]['macro_cell_id_list'] = [
                            {'targetBtsId': cell_id.split('.')[0], 'lnCelId': cell_id.split('.')[1]} for cell_id in
                            bts_cell_id_list]

                if cell_type in ["ALL", "RFC"]:
                    bts_cell_id_list = ScfFilter(
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

    @staticmethod
    def kw_get_cellid_list_by_rat(scf_file, rat='ALL'):
        new_obj = ScfParser()
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

    @staticmethod
    def kw_get_hubmod_id_by_asirmod_id(scf_file, asirmod_id=None):

        new_obj = ScfParser()
        new_obj.load(scf_file)

        if not asirmod_id:
            asirmod_id = []

        if type(asirmod_id) is str:
            asirmod_id = asirmod_id.split()

        dict_res = {}

        for hubmod in new_obj.scf_filter.filter({'class': ':HUBMOD$'}):
            for asirmod_bts_id in hubmod['externalIds']:
                asirmod = asirmod_bts_id['asiRmodId']
                if not asirmod_id or asirmod in asirmod_id:
                    dict_res[asirmod] = hubmod['distName'].split('-')[-1]

        return dict_res
