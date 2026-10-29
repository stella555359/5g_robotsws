from mock_robot import robot_builtin

from ...python.csv_report import CsvReport
from ...python.csv_report import PropsimCsvReport, SummaryCsvReport


def test_create_csv_file():
    file_path = './sample_csv_file.csv'
    headers = ['name', 'surname', 'age']
    data = [['Robert', 'Lewandowski', 15], ['Adam', 'Malysz', 25]]
    CsvReport.create_csv_file(csv_file_path=file_path, data=data, headers=headers)


def test_create_csv_file_dict():
    file_path = './sample_csv_file_dict.csv'
    headers = ['name', 'surname', 'age']
    data = [{'name': 'Robert', 'surname': 'Lewandowski', 'age': 15}, {'name': 'Adam', 'surname': 'Malysz', 'age': 25}]
    CsvReport.create_csv_file(csv_file_path=file_path, data=data, headers=headers)


def test_get_headers_and_data():
    file_path = './sample_csv_file.csv'
    headers = ['name', 'surname', 'age']
    data = [['Robert', 'Lewandowski', '15'], ['Adam', 'Malysz', '25']]
    got_header, got_data = CsvReport.get_headers_and_data(csv_file_path=file_path)
    assert headers == got_header and data == got_data


def test_prepare_propsim_data_for_single_iteration():
    data = {
        'Downlink': {
            'gain': -4.9,
            'outputs': {
                '5G MS 1-RX1': 15.2,
                '5G MS 1-RX2': 13.1
            },
            'inputs': {
                '5G BS 1-TX1': -2.4,
                '5G BS 1-TX2': 2.3,
                '5G BS 1-TX3': -2.5,
                '5G BS 1-TX4': -1.8
            },
            'channels': [14, 14.2, 13.8, 14.1]
        },
        'Uplink': {
            'gain': 2.8,
            'outputs': {
                '5G BS 1-RX1': -29.8,
                '5G BS 1-RX2': -29.7,
                '5G BS 1-RX3': -29.6,
                '5G BS 1-RX4': -29.9,
            },
            'inputs': {
                '5G MS 1-TX1': 15.5,
            },
            'channels': [12.3, 14.2, 13.8, 14.1]
        }
    }
    propsim_headers = ['Downlink gain', '5G MS 1-RX1', '5G MS 1-RX2', '5G BS 1-TX1', '5G BS 1-TX2', '5G BS 1-TX3',
                       '5G BS 1-TX4', 'Downlink Pathloss Max', 'Downlink Pathloss Min', 'Uplink gain', '5G BS 1-RX1',
                       '5G BS 1-RX2', '5G BS 1-RX3', '5G BS 1-RX4', '5G MS 1-TX1', 'Uplink Pathloss Max',
                       'Uplink Pathloss Min']
    propsim_data = {'Uplink Pathloss Min': 12.3,
                    '5G BS 1-RX1': -29.8,
                    'Downlink Pathloss Min': 13.8,
                    '5G BS 1-RX2': -29.7,
                    '5G BS 1-RX3': -29.6,
                    'Downlink Pathloss Max': 14.2,
                    '5G BS 1-RX4': -29.9,
                    '5G BS 1-TX1': -2.4,
                    'Downlink gain': -4.9,
                    '5G MS 1-TX1': 15.5,
                    '5G MS 1-RX1': 15.2,
                    '5G BS 1-TX4': -1.8,
                    'Uplink gain': 2.8,
                    'Uplink Pathloss Max': 14.2,
                    '5G MS 1-RX2': 13.1,
                    '5G BS 1-TX2': 2.3,
                    '5G BS 1-TX3': -2.5}
    prepared_propsim_headers, prepared_propsim_data = PropsimCsvReport()._prepare_data(propsim_values=data)
    assert propsim_headers == prepared_propsim_headers
    assert propsim_data == prepared_propsim_data


def test_propsim_procedure():
    log_dir = './rfp_logs/'
    data1 = {
        'Downlink': {
            'gain': -4.9,
            'outputs': {
                '5G MS 1-RX1': 15.2,
                '5G MS 1-RX2': 13.1
            },
            'inputs': {
                '5G BS 1-TX1': -2.4,
                '5G BS 1-TX2': 2.3,
                '5G BS 1-TX3': -2.5,
                '5G BS 1-TX4': -1.8
            },
            'channels': [14, 14.2, 13.8, 14.1]
        },
        'Uplink': {
            'gain': 2.8,
            'outputs': {
                '5G BS 1-RX1': -29.8,
                '5G BS 1-RX2': -29.7,
                '5G BS 1-RX3': -29.6,
                '5G BS 1-RX4': -29.9,
            },
            'inputs': {
                '5G MS 1-TX1': 15.5,
            },
            'channels': [12.3, 14.2, 13.8, 14.1]
        }
    }
    data2 = {
        'Downlink': {
            'gain': -3.9,
            'outputs': {
                '5G MS 1-RX1': 16.2,
                '5G MS 1-RX2': 14.1
            },
            'inputs': {
                '5G BS 1-TX1': -1.4,
                '5G BS 1-TX2': 3.3,
                '5G BS 1-TX3': -1.5,
                '5G BS 1-TX4': -0.8
            },
            'channels': [14, 14.3, 13.8, 14.1]
        },
        'Uplink': {
            'gain': 1.8,
            'outputs': {
                '5G BS 1-RX1': -28.8,
                '5G BS 1-RX2': -28.7,
                '5G BS 1-RX3': -28.6,
                '5G BS 1-RX4': -28.9,
            },
            'inputs': {
                '5G MS 1-TX1': 14.5,
            },
            'channels': [12.3, 14.2, 13.8, 14.7]
        }
    }
    PropsimCsvReport().create_propsim_csv_report_for_single_iteration(data=data1, log_dir=log_dir + '1')
    PropsimCsvReport().create_propsim_csv_report_for_single_iteration(data=data2, log_dir=log_dir + '2')
    SummaryCsvReport().create_summary_csv_report(logs_dir=log_dir)
