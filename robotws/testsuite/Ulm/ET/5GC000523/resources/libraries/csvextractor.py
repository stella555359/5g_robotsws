""" This function extracts required events from a TTI Trace csv file and outputs event related Information elements
in the form of Dictionary

For example : if event_extract = CsiSrReportData the output will be as follows:
{'utc': '4:17:4.728404', ' cqi': ' 0x0f', ' sr': ' 0', ' rxPucchSfn': ' 0x024e', ' pmiRank2': ' 0x00',
' physCellId': ' 0x0032', ' dtx': ' 0x00', ' reportType': ' 0x00', ' rxPucchSlot': ' 0x12', ' rnti': ' 0xc22f',
' pmiRank1': ' 0x00', ' ri': ' 0x01', 'Event': 'csiSrReportData', ' isReportSaved': ' 0x01'}

The output of the tti_extractor method will be a list of dictionaries, where each element of the list corresponds to
 an event"""


import csv


def tti_extractor(path, event_extract):
    file_tti = open(path)
    reader = csv.reader(file_tti, delimiter=';')
    header = next(reader)
    data = [row for row in reader]
    data_extract = []

    """ Finding the column representing events """
    header_extract = 'Event'
    col_num = header.index(header_extract)
    ignore_cols = []
    read_rows = []

    """ Excluding the column having null values for events"""
    for item in data:
        consider_item = item
        if item[col_num] == event_extract:
            for itr in range(len(item)):
                if item[itr] == '':
                    ignore_cols.append(itr)
            break

    for item_itr in range(len(data)):
        if data[item_itr][col_num] == event_extract:
            read_rows.append(item_itr)

    """ Extract the relevant columns """
    extract_cols = set(range(len(consider_item))) - set(ignore_cols)

    for row in read_rows:
        extracted_data = {}
        for col in extract_cols:
            extracted_data[header[col]] = data[row][col]
        data_extract.append(extracted_data)

    return data_extract


""" Test Function """

if __name__ == "__main__":
    path = 'R:/logs/automation/UL_ttiTrace.csv'
    event_extract = 'csiSrReportData'
    data = tti_extractor(path, event_extract)
    for entry in data:
        print(entry)
