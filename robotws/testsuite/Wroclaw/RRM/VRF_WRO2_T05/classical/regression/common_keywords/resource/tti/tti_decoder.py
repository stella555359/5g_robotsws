from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.common.csv_verification import \
    process_needed_messages
import pandas as pd
import argparse


def tti_decoder(tti_path, relevant_messages=None):
    blog('Start decoding TTI...')
    tti_messages = process_needed_messages(tti_path, relevant_messages)
    blog('Finished reading TTI messages into a dictionary.')
    columns, rows = prepare_rows_and_cols(tti_messages)
    blog('Finished preparing Excel rows and columns.')
    prepare_dataframe(columns, rows, tti_path)
    blog('TTI decoding finished!')


def prepare_rows_and_cols(tti_messages):
    columns = prepare_columns(tti_messages)
    rows = prepare_rows(columns, tti_messages)
    return columns, rows


def prepare_rows(columns, tti_messages):
    return [[message.get(col, '') for col in columns] for message in tti_messages]


def prepare_columns(tti_messages):
    return {
        param
        for message in tti_messages
        for param in message.keys()
        # if message['message_name'] != 'utcTimestampData'
    }


def prepare_dataframe(columns, rows, tti_path):
    blog('Start preparing pandas Dataframe.')
    df = pd.DataFrame(rows, columns=list(columns))
    message_name_col = df.pop('message_name')
    df.insert(0, 'message_name', message_name_col)
    blog('pandas Dataframe created successfully.')
    blog('Start writing data to CSV.')
    df.to_csv(tti_path.split('.csv')[0] + '_decoded.csv', index=False)
    blog('CSV file created successfully.')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Decode TTI legacyCsv file.')
    parser.add_argument('output_file', type=str, help='filepath to the TTI file.')
    parser.add_argument('-f', '--filter', dest='relevant_events', nargs='+', type=str, default=None, required=False,
                        help='list of relevant TTI events')
    args = parser.parse_args()

    tti_decoder(args.output_file, args.relevant_events)
