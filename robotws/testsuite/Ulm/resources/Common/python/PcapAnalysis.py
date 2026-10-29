import os
import subprocess
import csv
import logging


logger = logging.getLogger()

CONFIG = {"tshark":  "/usr/bin/tshark"}


def setup_logging(root_path):
    root_logger = logging.getLogger()
    root_logger.setLevel(logging.DEBUG)
    log_formatter = logging.Formatter(
        "%(asctime)s [%(threadName)-12.12s] [%(levelname)-5.5s] %(message)s")

    file_handler = logging.FileHandler(root_path + '/analyse.log', mode="w")
    file_handler.setFormatter(log_formatter)
    root_logger.addHandler(file_handler)

    console_handler = logging.StreamHandler()
    console_handler.setFormatter(log_formatter)
    root_logger.addHandler(console_handler)


class Tshark:
    """
    A Library wrapping around tshark for reading, filtering pcap files, as
    well as extracting fields from the pcap for further analysis.
    """

    def __init__(self, tshark):
        """
        Create thark instance.
        :param tshark: path to the tshark executable
        """
        self.tshark = tshark
        self.cmd = [self.tshark]
        self.fields = None

    def exec_cmd(self, cmd):
        """
        Executes the given tshark command.
        :param cmd: The command argument string for tshark.
        """
        ws_dir, _ = os.path.split(self.tshark)
        command_to_execute = self.cmd + cmd
        logger.info('Executing command: {}'.format(
            " ".join(command_to_execute)))

        stdout, stderr = subprocess.Popen(command_to_execute,
                                          stdout=subprocess.PIPE,
                                          stderr=subprocess.PIPE).communicate()
        data = stdout
        error_data = stderr

        if stderr:
            logger.error(error_data)

        return data, error_data

    def filter(self, input_pcap, display_filter, output_pcap=None):
        """
        Filters the input_pcap by the given display filter string.
        IF the output_pcap is not given, the result will be written to "filtered.pcap"
        in the same directory of the original pcap file.
        :param input_pcap: The path to the pcap to filter
        :param display_filter: The display filter, as used in wireshark
        :param output_pcap: (optional) the path to the pcap to write the filtered data to
        """
        logger.info("Filtering file [{}] using display filter [{}]".format(
            input_pcap, display_filter))
        """Adds a display filter to the tshark call"""
        if not output_pcap:
            pcap_dir, _ = os.path.split(input_pcap)
            output_pcap = os.path.join(pcap_dir, "filtered.pcap")

        cmd = ["-Y", display_filter]
        cmd += ["-r", input_pcap]
        cmd += ["-w", output_pcap]
        self.exec_cmd(cmd)
        return output_pcap

    def extract_fields(self, input_pcap, fields, output_file=None):
        """
        Extracts given fields from the pcap file and writes the result
        to a csv file. The field names must be given in the form like i.e.:
        UlData_PucchReceiveRespPs.PucchReceiveRespPs.slot

        :param input_pcap: the pcap to process
        :param fields: the field names to extract
        """
        self.fields = fields

        if not output_file:
            pcap_dir, _ = os.path.split(input_pcap)
            output_file = os.path.join(pcap_dir, "pcap_fields.csv")

        cmd = ["-r", input_pcap]
        cmd += ["-T", "fields"]
        cmd += ["-E", "separator=,"]
        cmd += ["-E", "header=y"]
        cmd += ["-E", "quote=d"]

        for field in fields:
            cmd += ["-e", field]

        data, error_data = self.exec_cmd(cmd)

        # write stdout to file
        with open(output_file, mode='wb') as out_fp:
            out_fp.write(data)

        return output_file


class PcapAnalysis():
    """
    Module for analysing pcap data. It Translates the data of a pcap file to
    be easier processable. The result is a CSV file.
    In case of the following test data:

    td = {'uldata_pucchreceiverespps':
             {'sfn':              'UlData_PucchReceiveRespPs.PucchReceiveRespPs.sfn',
              'slot':             'UlData_PucchReceiveRespPs.PucchReceiveRespPs.slot',
              'rnti':             'UlData_PucchReceiveRespPs.pucchResources_item_0.rnti',
              'startPrb':         'UlData_PucchReceiveRespPs.pucchResources_item_0.startPrb',
              'pucchFormat':      'UlData_PucchReceiveRespPs.pucchResources_item_0.pucchFormat'},
          'uldata_pucchreceivereq':
             {'sfn':                       'UlData_PucchReceiveReq.PucchReceiveReq.sfn',
              'slot':                      'UlData_PucchReceiveReq.PucchReceiveReq.slot',
              'rnti':                      'UlData_PucchReceiveReq.pucchResources_item_0.rnti',
              'pucchFormat':               'UlData_PucchReceiveReq.pucchResources_item_0.pucchFormat',
              'frequencyHopping':          'UlData_PucchReceiveReq.pucchResources_item_0.frequencyHopping',
              'startPrb':                  'UlData_PucchReceiveReq.pucchResources_item_0.startPrb',
              'numOfPrb':                  'UlData_PucchReceiveReq.pucchResources_item_0.numOfPrb',
              'modulationType':            'UlData_PucchReceiveReq.pucchResources_item_0.modulationType'}}

    A result table will be generated in the form

    message | sfn | slot | rnti | startPrb | pucchFormat | frequencyHopping | startPrb | numOfPrb | modulationType
    --------+-----+------+------+----------+-------------+------------------+----------+----------+---------------
            |     |      |      |          |             |                  |          |          |

    """

    def __init__(self):
        self.pcap_file = None
        self.test_data = None
        self.csv_file = None
        self.filtered = None
        self.extracted_fields_csv = None

    def create_analysis_data(self, pcap_file, test_data):
        """
        The main call to translate a pcap to the table representation with the given
        test_data
        :param pcap_file: The pcap file to process
        :test_data: Dictionary holding the messages and field names needed for later analysis
        """
        self.pcap_file = pcap_file
        self.test_data = test_data
        self.filter_capture_file()
        extracted_csv = self.extract_tshark_fields()
        self.analysis_data = self.translate_tshark_data(extracted_csv)
        self.write_result_file()
        return self.analysis_data

    def read_pcap(self, packet_filter='', output_type='pdml', pcap_file_path=None):
        """Read pcap file and return it as string.

        :param string packet_filter:    Deep packet filter definition       (tshark -Y equivalent).
        :param string output_type:      Output form e.g pdml/text/lines     (tshark -T equivalent).
        :param string pcap_file_path:   Pcap file path.

        :return:                        Packets matched with packet filter rules.
        :rtype:                         string
        """
        tshark_exec = Tshark(CONFIG['tshark'])
        cmd = ["-Y", packet_filter]
        cmd += ["-T", output_type]
        cmd += ["-r", pcap_file_path]
        pdml = tshark_exec.exec_cmd(cmd)
        return pdml

    def read_pcap_and_save_to_file(self, pcap_file_path, packet_filter='', output_type='pdml', output_file=None):
        """Read pcap file and save it to file

        :param string output_file:      Output file name
        :param string packet_filter:    Deep packet filter definition       (tshark -Y equivalent).
        :param string output_type:      Output form e.g pdml/text/lines     (tshark -T equivalent).
        :param string pcap_file_path:   Pcap file path.
        """
        if not output_file:
            base_name, _ = os.path.splitext(pcap_file_path)
            output_file = base_name + ".pdml"
        pcap_decoded = self.read_pcap(packet_filter, output_type, pcap_file_path)
        with open(output_file, 'wb') as f:
            f.write(pcap_decoded[0])
        return pcap_decoded

    def filter_capture_file(self):
        """
        Filter the pcap file for only containing data/messages relevant to test_data
        """
        tshark_analysis = Tshark('/usr/bin/tshark')

        display_filter = "||".join(self.test_data.keys())
        pcap_base_file_name, _ = os.path.splitext(self.pcap_file)
        self.filtered = pcap_base_file_name + "_filtered.pcap"
        tshark_analysis.filter(self.pcap_file,
                               display_filter,
                               output_pcap=self.filtered)
        logger.info("Created Filtered pcap file: {}".format(self.filtered))
        return self.filtered

    def extract_tshark_fields(self):
        """
        Extract the relevant fields of the messages.
        """
        tshark_analysis = Tshark('/usr/bin/tshark')

        fields_to_collect = list()
        for message, fields in self.test_data.items():
            fields_to_collect += [field_path for _,
                                  field_path in fields.items()]

        self.extracted_fields_csv = tshark_analysis.extract_fields(
            self.filtered, fields_to_collect)
        logger.info("Extracted pcap field data to CSV: {}".format(
            self.extracted_fields_csv))

    def read_csv_file(self, csv_filename):
        """
        Read in the intermediatly generated csv file. (helper method)
        :param csv_filename: The filename of the csv file to read
        :returns: The csv data in for of a list of dictionaries.
        """
        csv_data = list()
        with open(csv_filename) as csvfile:
            data_reader = csv.DictReader(csvfile)
            for row in data_reader:
                csv_data.append(row)
        return csv_data

    def translate_tshark_data(self, extracted_csv_file):
        """
        The csv file from pcap gets translated, so the column names are reduced by
        the "place holders" given with the test_data container. The table will include
        the message names in a separate column.
        """
        pcap_csv = self.read_csv_file(self.extracted_fields_csv)

        field_dict = dict()
        for message, fields in self.test_data.items():
            for key, field_names in fields.items():
                field_dict[field_names] = (message, key)

        analysis_data = list()
        for csv_item in pcap_csv:
            message = dict()
            msg = ''
            for csv_key, csv_value in [(csv_key, csv_value) for csv_key, csv_value in csv_item.items() if csv_value]:
                msg, key = field_dict[csv_key]
                message[key] = csv_value
            message['message'] = msg
            analysis_data.append(message)
        return analysis_data

    def write_result_file(self, result_file=None):
        """
        Writes the resulting table to a csv file.
        :param result_file: optional path to the result file. Default is the name of the original pcap
        with a csv extension.
        """

        if not result_file:
            base_name, _ = os.path.splitext(self.pcap_file)
            result_file = base_name + ".csv"

        csv_field_names = ['message']
        for message_field_description in self.test_data.values():
            for field_name in message_field_description:
                csv_field_names.append(field_name)

        with open(result_file, "w") as csvfile:
            writer = csv.DictWriter(
                csvfile, fieldnames=csv_field_names, extrasaction='ignore')
            writer.writeheader()
            for analysis_item in self.analysis_data:
                writer.writerow(analysis_item)
        logger.info(
            "Filtered Result data written to file {}".format(result_file))
        return result_file
