"""

Set of KW convert files to other formats

:copyright: Nokia Networks
:author: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com
:maintainer: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com
"""

import csv
import re
import os
import logging
from moler.device import DeviceFactory
from moler.exceptions import CommandFailure, CommandTimeout
from testsuite.Bangalore.ORAN.resources.python.\
    Macro.Python.converters import convert_pcap_by_luascript_to_csv
from testsuite.Bangalore.ORAN.resources.python.\
    Macro.Python.utilities import load_moler_configuration_from_tl


class L1L2TracesKPIParser(object):
    _re_index_file_name = re.compile(r'pcap(?P<INDEX>\d+)')

    def convert_all_pcap_files(self, pcap_dir, direction='DL'):
        bip_pcap_files = self._get_all_pcap_files(pcap_dir)

        convert_pcap_by_luashark_to_csv = self._get_luashark_converter(
            direction)

        converted_csv_files = []
        for pcap_file in bip_pcap_files:
            csv_file = convert_pcap_by_luashark_to_csv(pcap_file)
            converted_csv_file = self.convert_all_hex_values_to_dec(
                source_file=csv_file)
            converted_csv_files.append(converted_csv_file)

        return converted_csv_files

    def convert_dl_pcap_by_luascript_to_csv(self, pcap_file):
        fields = (
            '_ws.col.Info',
            'DlData_PdschSendReq.PdschSendReq.sfn',
            'DlData_PdschSendReq.PdschSendReq.slot',
            # 'DlData_PdschSendReq.PdschSendReq.rnti',
            'DlData_PdschSendReq.grants_item_15.rnti',
            # 'DlData_PdschSendReq.PdschSendReq.spatialMode',
            'DlData_PdschSendReq.grants_item_15.spatialMode',
            # 'DlData_PdschSendReq.PdschSendReq.numOfLayers',
            'DlData_PdschSendReq.grants_item_15.numOfLayers',
            # 'DlData_PdschSendReq.PdschSendReq.codebookIndex',
            'DlData_PdschSendReq.grants_item_15.codebookIndex',
            # 'DlData_PdschSendReq.PdschSendReq.tbSize_bits',
            'DlData_PdschSendReq.grants_item_15.tbSize_bits',
            # 'DlData_PdschSendReq.PdschSendReq.numOfPrb',
            'DlData_PdschSendReq.grants_item_15.numOfPrb',
            # 'DlData_PdschSendReq.PdschSendReq.mcs',
            'DlData_PdschSendReq.grants_item_15.mcs',
            # 'DlData_PdschSendReq.PdschSendReq.modulationOrder',
            'DlData_PdschSendReq.grants_item_15.modulationOrder',
            # 'DlData_PdschSendReq.PdschSendReq.numOfPdschSymbols',
            'DlData_PdschSendReq.grants_item_15.numOfPdschSymbols',
            # 'DlData_PdschSendReq.PdschSendReq.dlPtrsFlag',
            'DlData_PdschSendReq.grants_item_15.dlPtrsFlag',
            'DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.sfn',
            'DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.slot',
            'DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.rnti',
            'DlData_PdschPayloadTbSendReq.payload-Length',
            'UlData_PucchReceiveRespHarqD.PucchReceiveRespHarqD.sfn',
            'UlData_PucchReceiveRespHarqD.PucchReceiveRespHarqD.slot',
            'UlData_PucchReceiveRespHarqD.pucchResources_item_15.rnti',
            # 'UlData_PucchReceiveRespHarqD.ackNack.ackNack',
            'UlData_PucchReceiveRespHarqD.ackNack.ackNack_item_0',
            'UlData_PucchReceiveRespHarqD.pucchResources_item_15.dtx',
            'UlData_PucchReceiveReq.PucchReceiveReq.sfn',
            'UlData_PucchReceiveReq.PucchReceiveReq.slot',
            'UlData_PucchReceiveReq.pucchResources_item_15.rnti',
            # 'UlData_PucchReceiveReq.pucchResources_item_15.nANPucch',
            'UlData_PucchReceiveReq.pucchResources_item_85.nANPucch',
            'DlData_PdcchSendReq.PdcchSendReq.sfn',
            'DlData_PdcchSendReq.PdcchSendReq.slot',
            'DlData_PdcchSendReq.PdcchSendReq.beamId',
            '_ws.col.Time',
        )
        filters = ['dldata_pdschsendreq', 'dldata_pdcchsendreq',
                   'dldata_pdschpayloadtbsendreq',
                   'uldata_pucchreceiverespharqd', 'uldata_pucchreceivereq']

        file_name, extension = os.path.splitext(pcap_file)
        csv_file = "{}_{}_dl.csv".format(file_name, extension.lstrip('.'))

        parsed_file = convert_pcap_by_luascript_to_csv(
            pcap_file=pcap_file, csv_file=csv_file,
            fields=fields, filters=filters)
        return parsed_file

    def convert_ul_pcap_by_luascript_to_csv(self, pcap_file):
        fields = (
            '_ws.col.Info',
            'UlData_PuschReceiveReq.PuschReceiveReq.sfn',
            'UlData_PuschReceiveReq.PuschReceiveReq.slot',
            'UlData_PuschReceiveReq.grants_item_15.rnti',
            'UlData_PuschReceiveReq.grants_item_15.spatialMode',
            'UlData_PuschReceiveReq.grants_item_15.numOfLayers',
            'UlData_PuschReceiveReq.grants_item_15.codebookIndex',
            'UlData_PuschReceiveReq.grants_item_15.tbSize_bits',
            'UlData_PuschReceiveReq.grants_item_15.numOfPrb',
            'UlData_PuschReceiveReq.grants_item_15.mcs',
            'UlData_PuschReceiveReq.grants_item_15.mcsTable',
            'UlData_PuschReceiveReq.grants_item_15.numOfPuschSymbols',
            'UlData_PuschReceiveReq.grants_item_15.ulPtrsFlag',
            'UlData_PuschReceiveRespLo.PuschReceiveRespLo.sfn',
            'UlData_PuschReceiveRespLo.PuschReceiveRespLo.slot',
            'UlData_PuschReceiveRespLo.PuschReceiveRespLo.rnti',
            'UlData_PuschReceiveRespLo.data-Length',
            'DlData_PdcchSendReq.PdcchSendReq.sfn',
            'DlData_PdcchSendReq.PdcchSendReq.slot',
            'DlData_PdcchSendReq.PdcchSendReq.beamId',
            '_ws.col.Time'
        )

        filters = ['dldata_pdcchsendreq', 'uldata_puschreceivereq',
                   'uldata_puschreceiveresplo']

        file_name, extension = os.path.splitext(pcap_file)
        csv_file = "{}_{}_ul.csv".format(file_name, extension.lstrip('.'))

        parsed_file = convert_pcap_by_luascript_to_csv(
            pcap_file=pcap_file, csv_file=csv_file,
            fields=fields, filters=filters)
        return parsed_file

    def convert_all_hex_values_to_dec(self, source_file, output_file=None):
        """
        Convert all hex to dec number in source_file and save to output_file
        :param source_file:  path to csv file
        :param output_file:  path to output file -
        :return:
        """
        if not output_file:
            file_name, extension = os.path.splitext(source_file)
            output_file = "{}_converted{}".format(file_name, extension)
        lcells = []
        llines = []
        with open(source_file, 'rb') as f:
            reader = csv.reader(f, delimiter=',')
            for row in reader:
                for cell in row:
                    if re.match(r"(0x[0-9a-fA-F]{8})", cell):
                        cell = int(cell, 16)
                    lcells.append(cell)
                llines.append(lcells)
                lcells = []

        with open(output_file, 'ab') as new_f:
            writer = csv.writer(new_f, delimiter=',')
            writer.writerows(llines)

        return output_file

    @load_moler_configuration_from_tl()
    def _get_filtered_values(self, csv_file, msg, column):
        filtered_values = []
        local_pc = DeviceFactory.get_device(name='UnixLocal')
        get_values = local_pc.get_cmd(
            cmd_name="cat",
            cmd_params={'path': csv_file,
                        'options': "| grep '{}' ".
                        format(msg) + "| awk -F',' '{print $" +
                        str(column) + "}'"})
        try:
            filtered_values = get_values()['LINES']
        except (CommandFailure, CommandTimeout) as e:
            logging.warn("Cannot 'cat' content of file: {} -- {}".
                         format(csv_file, repr(e)))
        if not filtered_values:
            logging.warn("Cannot collect any data for msg={} and "
                         "column={}".format(msg, column))

        return filtered_values

    @staticmethod
    def _calculate_standard_set_of_kpi(data):
        values = [int(_value) for _value in data]
        min_value = min(values)
        sum_values = sum(values)
        count_of_values = len(values)
        avg_value = round(sum_values/count_of_values, 2)
        max_value = min(values)

        return {'min': min_value, 'avg': avg_value, 'max': max_value,
                'sum': sum_values, 'count': count_of_values}

    def get_beam_id_for_dl(self, csv_file):
        filtered_values = self._get_filtered_values(
            csv_file, msg='ICOM_5G/DlData_PdcchSendReq,', column=29)
        if filtered_values:
            return ",".join(set(filtered_values))

    def get_beam_id_for_ul(self, csv_file):
        filtered_values = self._get_filtered_values(
            csv_file, msg='ICOM_5G/DlData_PdcchSendReq,', column=20)
        if filtered_values:
            return ",".join(set(filtered_values))

    def get_mcs_for_dl(self, csv_file):
        filtered_values = self._get_filtered_values(
            csv_file, msg='ICOM_5G/DlData_PdschSendReq,', column=10)
        if filtered_values:
            return self._calculate_standard_set_of_kpi(filtered_values)

    def get_mcs_for_ul(self, csv_file):
        filtered_values = self._get_filtered_values(
            csv_file, msg='ICOM_5G/UlData_PuschReceiveReq,', column=10)
        if filtered_values:
            return self._calculate_standard_set_of_kpi(filtered_values)

    def get_bler_for_dl(self, csv_file):
        filtered_req_values = self._get_filtered_values(
            csv_file, msg='ICOM_5G/UlData_PucchReceiveReq,',
            column=26)
        filtered_resp_values = self._get_filtered_values(
            csv_file, msg='ICOM_5G/UlData_PucchReceiveRespHarqD',
            column=21)
        if filtered_req_values and filtered_resp_values:
            req = self._calculate_standard_set_of_kpi(filtered_req_values)
            count_ack_nack = self._count_number_of_bits(
                list_num=filtered_resp_values)
            resp = self._calculate_standard_set_of_kpi(count_ack_nack)
            bler = round(100 * (req['sum'] - resp['sum'])/req['sum'], 2)

            return bler

    def get_bler_for_ul(self, csv_file):
        filtered_req_values = self._get_filtered_values(
            csv_file, msg='ICOM_5G/UlData_PuschReceiveReq,', column=2)
        filtered_rec_values = self._get_filtered_values(
            csv_file,
            msg='ICOM_5G/UlData_PuschReceiveRespLo,', column=14)
        if filtered_req_values and filtered_rec_values:
            req = self._calculate_standard_set_of_kpi(filtered_req_values)
            count_ack_nack = self._count_number_of_bits(
                list_num=filtered_rec_values)
            resp = self._calculate_standard_set_of_kpi(count_ack_nack)
            bler = round(100 * (req['count'] - resp['count'])/req['count'], 2)

            return bler

    def _count_number_of_bits(self, list_num=None, bin_lengh=56,
                              bit_pattern='1'):
        counts_of_bits = []
        for x in list_num:
            counts_of_bits.append(bin(int(x, 16))[2:].
                                  zfill(int(bin_lengh)).
                                  count(bit_pattern))
        return counts_of_bits

    def _get_rf_kpi_for_ul(self, pcap_dir):
        parser = L1L2TracesKPIParser()
        bip_pcap_files = self._get_all_pcap_files(pcap_dir)

        converted_csv_files = []
        for pcap_file in bip_pcap_files:
            csv_file = parser.convert_ul_pcap_by_luascript_to_csv(pcap_file)
            converted_csv_file = parser.convert_all_hex_values_to_dec(
                source_file=csv_file)
            converted_csv_files.append(converted_csv_file)

        files_for_parsing = " ".join(converted_csv_files)

        beam_id = parser.get_beam_id_for_ul(csv_file=files_for_parsing)
        mcs = parser.get_mcs_for_ul(csv_file=files_for_parsing)
        bler = parser.get_bler_for_ul(csv_file=files_for_parsing)

        return beam_id, mcs, bler

    def _get_luashark_converter(self, direction):
        if direction == 'DL':
            return self.convert_dl_pcap_by_luascript_to_csv
        elif direction == 'UL':
            return self.convert_ul_pcap_by_luascript_to_csv
        else:
            logging.warning("Direction '{}' not supported".format(direction))

    def _get_all_pcap_files(self, pcap_dir):
        pcap_dir = re.escape(pcap_dir)
        return self._get_files_list(path=os.path.join(pcap_dir, '*.pcap*'))

    @load_moler_configuration_from_tl()
    def _get_files_list(self, path):
        local_pc = DeviceFactory.get_device(name='UnixLocal')

        cmd_ls = local_pc.get_cmd(cmd_name="ls",
                                  cmd_params={"path": path,
                                              "options": '-ltr'})
        try:
            ls_output = cmd_ls()
        except CommandFailure:
            logging.warning("File {} doesn't exists on {} device".
                            format(path, 'UnixLocal'))
            return []

        files = [_file.strip("'") for _file in ls_output['files'].keys()]
        sorted_files = sorted(files, key=self._get_index_from_file)
        logging.debug("Selected files: {}".format(sorted_files))
        return sorted_files

    def _get_index_from_file(self, file_name):
        match = self._re_index_file_name.search(file_name)
        if match:
            return int(match.group('INDEX'))
