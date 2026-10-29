import numpy as np
import pandas as pd
import xlsxwriter
import os

pd.set_option('display.max_rows', None)
pd.set_option('display.max_columns', None)

rows_to_delete_beggining = 50
num_of_split = 20  # num of runs in the test - attenuation split
rows_to_delete_end = 120

file_name_DL = "C:\\Users\\wolczyns\\Desktop\\P&C24R3\\DR03143302-M1.xlsx"
file_name_UL = "C:\\Users\\wolczyns\\Desktop\\P&C24R3\\DR03143302-M2.xlsx"
worksheet = "User Defined KPI"
test_type = "fading"  # type of data "fading", "interferences", "handover"
direction = "DL and UL"  # for fading test to chose in which direction it was done
name_file = "ABIP_DL_EPA5_VoLTE.xlsx"
technology = "LTE"


def open_file(file_path, sheet_name):
    assert os.path.isfile(file_path), f"File {file_path} does not exist."
    df = pd.read_excel(file_path, sheet_name=sheet_name)
    return df


def delete_rows(file_content_DL, rows_to_delete_beggining, rows_to_delete_end):
    first_rows = file_content_DL.head(rows_to_delete_beggining).index
    last_rows = file_content_DL.tail(rows_to_delete_end).index
    file_content = file_content_DL.drop(last_rows)
    file_content = file_content_DL.drop(first_rows)
    return file_content


def data_analysis_PnC(rows_to_delete_beggining, rows_to_delete_end, file_name, worksheet, num_of_split, test_type,
                      technology):
    file_content_DL = open_file(file_name, worksheet)
    file_content = delete_rows(file_content_DL, rows_to_delete_beggining, rows_to_delete_end)
    if technology == '5G':
        selected_columns = file_content[
            ['5GNR-Q_NR_Serv Filtered BRSRP(Searcher)(P)', 'MOS', 'Packet Loss Rate(Rx)', '5GNR-Q_NR_PDSCH R-BLER(P)',
             '5GNR-Q_NR_PDSCH Init BLER(P)', 'Delay(Rx)']].copy()  # Utwórz kopi? DataFrame
    if technology == 'LTE':
        selected_columns = file_content[
            ['LTE(Adv)-Q_Serv RSRP(PCell)', 'MOS', 'Packet Loss Rate(Rx)']].copy()  # Utwórz kopi? DataFrame
    selected_columns['group'] = (selected_columns.index // (file_content.shape[0] / num_of_split)) + 1
    mean_values = selected_columns.groupby('group').mean()
    print(mean_values)
    create_file(mean_values, file_name_DL, test_type, name_file)


def data_analysis_PnC_UL_DL(rows_to_delete_beggining, rows_to_delete_end, file_name_DL, worksheet,
                            num_of_split, test_type, technology, file_name_UL):
    file_content_DL = open_file(file_name_DL, worksheet)
    file_content_UL = open_file(file_name_UL, worksheet)
    file_content_DL = delete_rows(file_content_DL, rows_to_delete_beggining, rows_to_delete_end)
    file_content_UL = delete_rows(file_content_UL, rows_to_delete_beggining, rows_to_delete_end)
    if technology == '5G':
        selected_columns_DL = file_content_DL[
            ['5GNR-Q_NR_Serv Filtered BRSRP(Searcher)(P)', '5GNR-Q_NR_PDSCH R-BLER(P)',
             '5GNR-Q_NR_PDSCH Init BLER(P)']].copy()
    if technology == 'LTE':
        selected_columns_DL = file_content_DL[
            ['LTE(Adv)-Q_Serv RSRP(PCell)']].copy()

    selected_columns_DL['group'] = (selected_columns_DL.index // (file_content_DL.shape[0] / num_of_split)) + 1
    selected_columns_UL = file_content_UL[['MOS', 'Packet Loss Rate(Rx)']].copy()
    selected_columns_UL['group'] = (selected_columns_UL.index // (file_content_UL.shape[0] / num_of_split)) + 1
    mean_values_DL = selected_columns_DL.groupby('group').mean()
    mean_values_UL = selected_columns_UL.groupby('group').mean()
    mean_values = pd.concat([mean_values_DL, mean_values_UL], axis=1)
    print(mean_values)
    create_file(mean_values, file_name_DL, test_type, name_file)


def interference_analysis(rows_to_delete_beggining, rows_to_delete_end, file_name_DL, worksheet, num_of_split,
                          test_type):
    file_content = open_file(file_name_DL, worksheet)
    file_content = delete_rows(file_content, rows_to_delete_beggining, rows_to_delete_end)
    print("Liczba wierszy: ", file_content.shape[0])
    if technology == "5G":
        selected_columns = file_content[
            ['5GNR-Q_NR_Serv Filtered BRSRP(Searcher)(P)', '5GNR-Q_NR_Top1 Neig Filtered BRSRP(Searcher)(P)',
             'MOS', 'Packet Loss Rate(Rx)']].copy()
        selected_columns['group'] = (selected_columns.index // (file_content.shape[0] / num_of_split)) + 1
        selected_columns['SiNR'] = selected_columns['5GNR-Q_NR_Serv Filtered BRSRP(Searcher)(P)'] - selected_columns[
            '5GNR-Q_NR_Top1 Neig Filtered BRSRP(Searcher)(P)']
    if technology == "LTE":
        selected_columns = file_content[
            ['LTE(Adv)-Q_Serv RSRP(PCell)', 'LTE(Adv)-Q_Best 1 Neig. RSRP(PCell)',
             'MOS', 'Packet Loss Rate(Rx)']].copy()
        selected_columns['group'] = (selected_columns.index // (file_content.shape[0] / num_of_split)) + 1
        selected_columns['SiNR'] = selected_columns['LTE(Adv)-Q_Serv RSRP(PCell)'] - selected_columns[
            'LTE(Adv)-Q_Best 1 Neig. RSRP(PCell)']
    mean_values = selected_columns.groupby('group').mean()
    create_file(mean_values, file_name_DL, test_type, name_file)
    print(mean_values)


def Handover_analysis(rows_to_delete_beggining, rows_to_delete_end, file_name_DL, file_name_UL, worksheet, num_of_split,
                      test_type, direction):
    if direction == "DL":
        file_content = open_file(file_name_DL, worksheet)
        file_content = delete_rows(file_content, rows_to_delete_beggining, rows_to_delete_end)
        print("Liczba wierszy: ", file_content.shape[0])
        if technology == '5G':
            selected_columns = file_content[
                ['5GNR-Q_NR_Serv PCI(Searcher)(P)', 'MOS', 'Packet Loss Rate(Rx)']].copy()
            selected_columns['group'] = (selected_columns.index // (file_content.shape[0] / num_of_split)) + 1
            selected_columns['Handover'] = (
                    selected_columns['5GNR-Q_NR_Serv PCI(Searcher)(P)'].shift() != selected_columns[
                        '5GNR-Q_NR_Serv PCI(Searcher)(P)']).astype(int)
            print("jestem w 5G")
        if technology == 'LTE':
            selected_columns = file_content[
                ['LTE(Adv)-Q_Serv PCI(PCell)', 'MOS', 'Packet Loss Rate(Rx)']].copy()
            selected_columns['group'] = (selected_columns.index // (file_content.shape[0] / num_of_split)) + 1
            selected_columns['Handover'] = (selected_columns['LTE(Adv)-Q_Serv PCI(PCell)'].shift() != selected_columns[
                'LTE(Adv)-Q_Serv PCI(PCell)']).astype(int)

        mean_values = selected_columns.groupby('group').apply(lambda x: x, include_groups=False)

        create_file(mean_values, file_name_DL, test_type, name_file)
    if direction == "UL":
        file_content_DL = open_file(file_name_DL, worksheet)
        file_content_UL = open_file(file_name_UL, worksheet)

        file_content_DL = delete_rows(file_content_DL, rows_to_delete_beggining, rows_to_delete_end)
        file_content_UL = delete_rows(file_content_UL, rows_to_delete_beggining, rows_to_delete_end)
        selected_columns_DL = file_content_DL[
            ['5GNR-Q_NR_Serv PCI(Searcher)(P)',
             ]].copy()
        selected_columns_DL['group'] = (selected_columns_DL.index // (file_content_DL.shape[0] / num_of_split)) + 1
        selected_columns_UL = file_content_UL[
            ['MOS', 'Packet Loss Rate(Rx)']].copy()
        selected_columns_DL['Handover'] = (
                selected_columns_DL['5GNR-Q_NR_Serv PCI(Searcher)(P)'].shift() !=
                selected_columns_DL['5GNR-Q_NR_Serv PCI(Searcher)(P)']
        ).astype(int)
        combined_columns = pd.concat([selected_columns_DL, selected_columns_UL], axis=1)
        combined_columns['MOS'] = combined_columns['MOS'].replace('#NUM!', float('NaN'))
        combined_columns['MOS'] = combined_columns['MOS'].ffill()
        mean_values = combined_columns.groupby('group').apply(lambda x: x, include_groups=False)
        create_file(mean_values, file_name_DL, test_type, name_file)
        print(mean_values)


def create_file(mean_values, file_name_DL, test_type, name_file="results.xlsx"):
    output_dir = os.path.dirname(file_name_DL)
    output_file = os.path.join(output_dir, name_file)
    with xlsxwriter.Workbook(output_file, {'nan_inf_to_errors': True}) as workbook:
        worksheet = workbook.add_worksheet()
        for i, col_name in enumerate(mean_values.columns):
            worksheet.write(0, i, col_name)
        for i, col in enumerate(mean_values.columns):
            worksheet.write_column(1, i, mean_values[col])
        if test_type == "fading" or "handover":
            for i in range(1, len(mean_values.columns)):
                # Create a new chart for each series
                chart = workbook.add_chart({'type': 'line'})
                chart.add_series({
                    'categories': ['Sheet1', 1, 0, len(mean_values) + 1, 0],
                    'values': ['Sheet1', 1, i, len(mean_values) + 1, i],
                    'name': ['Sheet1', 0, i],
                })
                worksheet.insert_chart('E{}'.format(i), chart)

        if test_type == "interferences":
            mos_index = list(mean_values.columns).index('MOS')
            sinr_index = list(mean_values.columns).index('SiNR')
            chart = workbook.add_chart({'type': 'line'})
            chart.add_series({
                'categories': ['Sheet1', 1, sinr_index, len(mean_values) + 1, sinr_index],
                'values': ['Sheet1', 1, mos_index, len(mean_values) + 1, mos_index],
                'name': 'MOS vs SiNR',
            })
            worksheet.insert_chart('E1', chart)


def direction_of_test(direction):
    if direction == "DL" or direction == "UL":
        data_analysis_PnC(rows_to_delete_beggining, rows_to_delete_end, file_name_DL, worksheet, num_of_split,
                          test_type, technology)

    if direction == "DL and UL":
        data_analysis_PnC_UL_DL(rows_to_delete_beggining, rows_to_delete_end, file_name_DL, worksheet,
                                num_of_split, test_type, technology, file_name_UL)
        print("Test result UL i DL")


def type_to_analyse(test_type, direction):
    if test_type == "fading":
        direction_of_test(direction)
        print("Test result in", direction)
    elif test_type == "interferences":
        interference_analysis(rows_to_delete_beggining, rows_to_delete_end, file_name_DL, worksheet, num_of_split,
                              test_type)
        print("Test result in", direction)
    elif test_type == "handover":
        Handover_analysis(rows_to_delete_beggining, rows_to_delete_end, file_name_DL, file_name_UL, worksheet,
                          num_of_split, test_type, direction)
        print("Test result in", direction)
    else:
        assert False, f"Invalid test_type: {test_type}. Expected 'fading', 'interferences', or 'handover'."


type_to_analyse(test_type, direction)
