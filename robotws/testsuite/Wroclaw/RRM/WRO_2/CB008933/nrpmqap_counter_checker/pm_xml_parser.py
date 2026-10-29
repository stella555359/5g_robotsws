"""
:copyright: Nokia Networks
:author: 'Mikolaj Kasian'
:maintainer: 'Mikolaj Kasian'
:contact: 'mikolaj.kasian@nokia.com'
:version: 0.1
"""

import xmltodict
from pprint import pprint


class NRPMQAPCountersXMLParser:
    """ This class gets counters data from PM file"""

    def __init__(self, nrpmqap_number, xml_path):
        self.nrpmqap_number = nrpmqap_number
        self.xml_path = xml_path

    def get_counters_values(self, cell_id, data_keeper):
        cell_data = self._get_cell_data(cell_id)
        nrpmqap_counters = self._get_nrpmqap_counters_list(cell_data)
        for counter in data_keeper.counters:
            counter.actual_values = self._get_counter_values(counter.id_name, nrpmqap_counters)

    def _get_counter_values(self, counter_name, nrpmqap_counters):
        return [self._get_counter_value(nrpmqap_with_idx, counter_name) for nrpmqap_with_idx in nrpmqap_counters]

    def _get_counter_value(self, nrpmqap_with_idx, counter_name):
        try:
            return int(nrpmqap_with_idx.get(counter_name))
        except (ValueError, TypeError):
            return None

    def _get_nrpmqap_counters_list(self, cell_data):
        return [self.get_nrpmqap_counters(cell_data, idx) for idx in range(1, self.nrpmqap_number + 1)]

    def _get_cell_data(self, cell_id):
        cell_data = []
        for period in self._periods(self._get_dict_from_xml()):
            cell_data += self._get_period_cell_data(period, cell_id)
        return cell_data

    def _periods(self, data):
        pm_setup = data['OMeS']['PMSetup']
        if isinstance(pm_setup, list):
            return data['OMeS']['PMSetup']
        return [data['OMeS']['PMSetup']]

    def _get_dict_from_xml(self):
        with open(self.xml_path) as f:
            return xmltodict.parse(f.read())

    def _get_period_cell_data(self, period, cell_id):
        print(f"Parse period with {period.get('@startTime')} start time "
              f"and {period.get('@interval')}min interval")

        return self._cell_counters(period, cell_id)

    def _period_counters_data(self, period):
        return period.get('PMMOResult')

    def _cell_counters(self, period, cell_id):
        return [element for element in self._mo_data_generator(self._period_counters_data(period), cell_id)]

    def _mo_data_generator(self, period_data, cell_id):
        moid = f"NRCELL-{cell_id}"
        for mo in period_data:
            if isinstance(mo['MO'], list):
                if moid in mo['MO'][0]['DN']:
                    yield mo
            elif isinstance(mo['MO'], dict):
                if moid in mo['MO']['DN']:
                    yield mo

    def get_nrpmqap_counters(self, cell_counters, idx):
        nrpmqap_counters = {}
        for mo in self.nrpmqap_counters_generator(cell_counters, idx):
            nrpmqap_counters.update(self.fetch_counters(mo))
        return nrpmqap_counters

    def fetch_counters(self, mo):
        counters = mo.get('NE-WBTS_1.0')
        del counters['@measurementType']
        return counters

    def nrpmqap_counters_generator(self, cell_counters, idx):
        for mo in cell_counters:
            if isinstance(mo['MO'], list):
                if self.manage_object_destination_name(mo).endswith(f'NRPMQAP-{idx}'):
                    yield mo

    def manage_object_destination_name(self, mo):
        return mo['MO'][1]['DN']
