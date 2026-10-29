import subprocess
import importlib
import sys
import warnings
import time


def install(package):
    subprocess.check_call([sys.executable, "-m", "pip", "install", package])


def import_with_auto_install(packages):
    results = []
    for package in packages:
        try:
            results.append(importlib.import_module(package))
        except ImportError:
            install(package)
            results.append(importlib.import_module(package))
            print("\n\ninstalling: {}\nfinal result = {}".format(package, results))
    return results


class CB008367(object):
    df = None

    def __init__(self):
        self.pandas_numpy_libs = None

    def get_pandas_numpy_libs(self):
        if self.pandas_numpy_libs is None:
            self.pandas_numpy_libs = import_with_auto_install(["pandas", "numpy"])
        return self.pandas_numpy_libs

    def avg_prb_alloc_for_cell_dl(self, file_path, cell_id):
        """
        Function calculates average allocated PRBs value in DL for cell by filtering TTI file by desired cell and
        calculating the average of "ulAllocatedPooledResourcesData.numAllocCellPrbUl" column. PRBs average value has
        to be lower than 273 (max) because then it would mean that PRBs are not being dynamically shared.

        :param file_path: pPath to TTI DL file without file extension
        :param cell_id: Desired cellId in TTI in DL
        :return: Average value of PRBs allocated to cell in DL
        """
        df = self.get_pandas_numpy_libs()[0].read_csv(f'{file_path}.csv', sep=',')
        df['dlTdSchedSubcellData.numAllocCellPrbDl'] = self.get_pandas_numpy_libs()[0].to_numeric(
            df['dlTdSchedSubcellData.numAllocCellPrbDl'],
            errors='coerce'
        )
        df = df[df['dlTdSchedSubcellData.numAllocCellPrbDl'].notna()]
        df['dlTdSchedSubcellData.numAllocCellPrbDl'] = df['dlTdSchedSubcellData.numAllocCellPrbDl'].astype(int)
        filtered_df = df[df['physCellId'] == int(cell_id)]

        filtered_df.to_csv(f'{file_path}_cellid_{cell_id}.csv', sep=';', index=False)

        average_value = filtered_df['dlTdSchedSubcellData.numAllocCellPrbDl'].mean(skipna=True)

        if average_value == 273:
            raise ValueError("Average PRB allocated is equal to max")

        return average_value

    def avg_prb_alloc_for_cell_ul(self, file_path, cell_id):
        """
        Function calculates average allocated PRBs value in UL for cell by filtering TTI file by desired cell and
        calculating the average of "ulAllocatedPooledResourcesData.numAllocCellPrbUl" column. PRBs average value has
        to be lower than 273 (max) because then it would mean that PRBs are not being dynamically shared.

        :param file_path: Path to TTI UL file without file extension
        :param cell_id: Desired cellId in TTI in UL
        :return: Average value of PRBs allocated to cell in UL
        """
        df = self.get_pandas_numpy_libs()[0].read_csv(f'{file_path}.csv', sep=',')
        df['ulAllocatedPooledResourcesData.numAllocCellPrbUl'] = self.get_pandas_numpy_libs()[0].to_numeric(
            df['ulAllocatedPooledResourcesData.numAllocCellPrbUl'],
            errors='coerce'
        )
        df = df[df['ulAllocatedPooledResourcesData.numAllocCellPrbUl'].notna()]
        df['ulAllocatedPooledResourcesData.numAllocCellPrbUl'] = \
            df['ulAllocatedPooledResourcesData.numAllocCellPrbUl'].astype(int)
        filtered_df = df[df['physCellId'] == int(cell_id)]

        filtered_df.to_csv(
            f'{file_path}_cellid_{cell_id}.csv', sep=';', index=False)

        average_prbs = filtered_df['ulAllocatedPooledResourcesData.numAllocCellPrbUl'].mean(skipna=True)

        if average_prbs == 273:
            raise ValueError("Average PRB allocated is equal to max")

        return average_prbs

    def check_pdsch_correctness(self, filtered_tti, bwp_id, coreset_size, num_of_pdsch_symbols):
        """
        Function checks if filtered TTI is not empty and then perform checks depending on num_of_pdsch_symbols.

        For num_of_pdsch_symbols == 1:
        If SLIV (num_of_pdsch_symbols) is not 1 then value of "dlTdSchedSubcellData.numAllocCellPrbDl" has to lower than
        size of BWP corset + "dlFdSchedData.numOfPrb" because these allocations would exceed number of available PRBs.

        For num_of_pdsch_symbols == 2:
        If SLIV (num_of_pdsch_symbols) is not 2 then value of "dlFdSchedData.startPrb" "dlFdSchedData.numOfPrb" + has to
        be lower than 48.

        :param filtered_tti: Filtered TTI data frame
        :param bwp_id: desired cellBwpId in TTI
        :param coreset_size: BWP coreset size
        :param num_of_pdsch_symbols: PDSCH start symbol - 1 or 2
        """
        if filtered_tti['dlFdSchedData.cellBwpId'].isnull().all():
            raise ValueError("Fail - filtered_tti is empty")
        filtered_tti = filtered_tti[
            (filtered_tti['dlFdSchedData.cellBwpId'] == bwp_id) & (filtered_tti['physCellId'] == 50)]
        if num_of_pdsch_symbols == 1:
            for index, row in filtered_tti.iterrows():
                sliv = self.get_start_symbol_and_length_from_sliv(row['dlFdSchedData.SLIV'])
                if not sliv == 1:
                    if not coreset_size + row['dlFdSchedData.numOfPrb'] > row['dlTdSchedSubcellData.numAllocCellPrbDl']:
                        print(f'Row {index + 1}')
                        raise ValueError("Fail - Conditions are not met")
        else:
            for index, row in filtered_tti.iterrows():
                sliv = self.get_start_symbol_and_length_from_sliv(
                    row['dlFdSchedData.SLIV'])
                if not sliv == 2:
                    if not (row['dlFdSchedData.startPrb'] + row['dlFdSchedData.numOfPrb'] <= 48):
                        print(f'Row {index + 1}')
                        raise ValueError("Fail - Conditions are not met")

    def get_start_symbol_and_length_from_sliv(self, sliv):
        """
        Function where SLIV value get interpreted to start symbol and length.
        https://www.sharetechnote.com/html/5G/5G_SLIV.html

        :param sliv: SLIV value in TTI
        :return: PDSCH start symbol
        """
        length = sliv // 14 + 1
        start_symbol = sliv - (14 * (length - 1))
        if start_symbol < 14 and 0 < length < 14 - start_symbol:
            return start_symbol
        length = 15 - sliv // 14
        start_symbol = (14 * (15 - length)) + 13 - sliv
        return start_symbol

    def filter_and_check_pdcch_pattern_for_large_and_small(self, csv_path, filename, search_space_large,
                                                           search_space_small, pdcch_start_symbol_large,
                                                           pdcch_start_symbol_small):
        """
        Function checks every record of column "dlPdcchPatternData.perBwpPdcchResources" in TTI and filter only those
        which contain correct pairs of searchSpaceId and number of PDCCH symbols for Large and Small BWP.

        :param csv_path: Path to TTI file
        :param search_space_large: searchSpaceId of Large BWP
        :param search_space_small: searchSpaceId of Small BWP
        :param pdcch_start_symbol_large: Value of PDCCH start symbol in TTI for Large BWP - (1 means 1 PDCCH symbol,
               17 means 2 PDCCH symbols)
        :param pdcch_start_symbol_small: Value of PDCCH start symbol in TTI for Small BWP - (1 means 1 PDCCH symbol,
               17 means 2 PDCCH symbols)
        :return: Filtered data frame which contains correct searchSpaceId and number of PDCCH symbols pairs without
                 common channels (search_space_id == 40)
        """
        df = self.get_pandas_numpy_libs()[0].read_csv(csv_path+filename)

        filtered_rows = []

        for index, row in df.iterrows():
            if isinstance(row['dlPdcchPatternData.perBwpPdcchResources'], str):
                pdcch_list = eval(
                    row['dlPdcchPatternData.perBwpPdcchResources'])
                found_pair_1 = False
                found_pair_2 = False

                for item in pdcch_list:
                    pdcch_resource_list = item['pdcchResourceList']

                    for resource in pdcch_resource_list:
                        search_space_id = resource['searchSpaceId']
                        pdcch_start_symbol_and_length = resource['pdcchStartSymbolAndLength']

                        if search_space_id == 40:
                            break
                        elif search_space_id == int(search_space_large):
                            if pdcch_start_symbol_and_length == int(pdcch_start_symbol_large):
                                found_pair_1 = True
                            else:
                                found_pair_1 = False
                        elif search_space_id == int(search_space_small):
                            if pdcch_start_symbol_and_length == int(pdcch_start_symbol_small):
                                found_pair_2 = True
                            else:
                                found_pair_2 = False
                    else:
                        continue
                    break
                if found_pair_1 and found_pair_2:
                    filtered_row = row.copy()
                    filtered_row['dlPdcchPatternData.perBwpPdcchResources'] = pdcch_list
                    filtered_rows.append(filtered_row)

        filtered_df = self.get_pandas_numpy_libs()[0].DataFrame(filtered_rows)
        name = 'filtered_pattern_large_small'
        filtered_df.to_csv(f'{csv_path}{name}_{pdcch_start_symbol_large}_{pdcch_start_symbol_small}.csv', index=False)

        return filtered_df

    def filter_and_check_pdcch_pattern_for_large_small_ps(self, csv_path, filename, search_space_large,
                                                          search_space_small, search_space_ps,
                                                          pdcch_start_symbol_large, pdcch_start_symbol_small,
                                                          pdcch_start_symbol_ps):
        """
        Function checks every record of column "dlPdcchPatternData.perBwpPdcchResources" in TTI and filter only those
        which contain correct pairs of searchSpaceId and number of PDCCH symbols for Large and Small BWP.

        :param csv_path: Path to TTI file
        :param search_space_large: searchSpaceId of Large BWP
        :param search_space_ps: searchSpaceId of Power Saving BWP
        :param search_space_small: searchSpaceId of Small BWP
        :param pdcch_start_symbol_large: Value of PDCCH start symbol in TTI for Large BWP - (1 means 1 PDCCH symbol,
               17 means 2 PDCCH symbols)
        :param pdcch_start_symbol_small: Value of PDCCH start symbol in TTI for Small BWP - (1 means 1 PDCCH symbol,
               17 means 2 PDCCH symbols)
        :param pdcch_start_symbol_ps: Value of PDCCH start symbol in TTI for PowerSaving BWP - (1 means 1 PDCCH symbol,
               17 means 2 PDCCH symbols)
        :return: Filtered data frame which contains correct searchSpaceId and number of PDCCH symbols pairs without
                 common channels (search_space_id == 40)
        """
        df = self.get_pandas_numpy_libs()[0].read_csv(csv_path+filename)

        filtered_rows = []
        counter_not_expected = 0
        counter_expected = 0

        for index, row in df.iterrows():
            if isinstance(row['dlPdcchPatternData.perBwpPdcchResources'], str):
                pdcch_list = eval(
                    row['dlPdcchPatternData.perBwpPdcchResources'])
                found_pair_1 = False
                found_pair_2 = False
                found_pair_3 = False

                for item in pdcch_list:
                    pdcch_resource_list = item['pdcchResourceList']

                    for resource in pdcch_resource_list:
                        search_space_id = resource['searchSpaceId']
                        pdcch_start_symbol_and_length = resource['pdcchStartSymbolAndLength']

                        if search_space_id == 40:
                            break
                        elif search_space_id == int(search_space_large):
                            if pdcch_start_symbol_and_length == int(pdcch_start_symbol_large):
                                found_pair_1 = True
                            else:
                                found_pair_1 = False
                        elif search_space_id == int(search_space_small):
                            if pdcch_start_symbol_and_length == int(pdcch_start_symbol_small):
                                found_pair_2 = True
                            else:
                                found_pair_2 = False
                        elif search_space_id == int(search_space_ps):
                            if pdcch_start_symbol_and_length == int(pdcch_start_symbol_ps):
                                found_pair_3 = True
                            else:
                                found_pair_3 = False
                    else:
                        continue
                    break
                if found_pair_1 and found_pair_2 and found_pair_3:
                    counter_expected += 1
                    filtered_row = row.copy()
                    filtered_row['dlPdcchPatternData.perBwpPdcchResources'] = pdcch_list
                    filtered_rows.append(filtered_row)
        filtered_df = self.get_pandas_numpy_libs()[0].DataFrame(filtered_rows)
        name = 'filtered_pattern_large_small'
        pdcch_values = f'{pdcch_start_symbol_large}_{pdcch_start_symbol_small}_{pdcch_start_symbol_ps}'
        filtered_df.to_csv(f'{csv_path}{name}_{pdcch_values}.csv', index=False)

        return filtered_df

    def check_avg_num_of_pdcch_symbols(self, csv_path, filename, search_space_id, num_of_symbols=2):
        """
        Function calculates average number of PDCCH symbols (1 or 2) by searching for search_space_id and
        pdcch_start_symbol_and_length pairs in "dlPdcchPatternData.perBwpPdcchResources".

        pdcch_start_symbol_and_length == 1 means 1 PDCCH symbol
        pdcch_start_symbol_and_length == 17 means 2 PDCCH symbols
        search_space_id == 40 means common channel

        :param csv_path: Path to TTI file folder
        :param filename: Full CSV file name
        :param search_space_id: searchSpaceId of desired BWP
        :param num_of_symbols: Number of PDCCH symbols - 1 or 2 (default value is 2)
        :return: True if average number of PDCCH symbols is above exceptions
        """
        df = self.get_pandas_numpy_libs()[0].read_csv(csv_path + filename)

        num_of_records = 0
        every_num_of_symbols = 0

        for index, row in df.iterrows():
            if isinstance(row['dlPdcchPatternData.perBwpPdcchResources'], str):
                pdcch_list = eval(
                    row['dlPdcchPatternData.perBwpPdcchResources'])

                for item in pdcch_list:
                    pdcch_resource_list = item['pdcchResourceList']

                    for resource in pdcch_resource_list:
                        search_space = resource['searchSpaceId']
                        pdcch_start_symbol_and_length = resource['pdcchStartSymbolAndLength']

                        if search_space == 40:
                            break
                        elif search_space == int(search_space_id) and pdcch_start_symbol_and_length == 1:
                            num_of_records = num_of_records + 1
                            every_num_of_symbols = every_num_of_symbols + pdcch_start_symbol_and_length
                        elif search_space == int(search_space_id) and pdcch_start_symbol_and_length == 17:
                            every_num_of_symbols = every_num_of_symbols + pdcch_start_symbol_and_length - 1
                    else:
                        continue
                    break

        avg_num_of_symbols = every_num_of_symbols / num_of_records
        print(avg_num_of_symbols)
        if (num_of_symbols == 2 and avg_num_of_symbols >= 2) or (num_of_symbols == 1 and avg_num_of_symbols <= 2):
            return True
        else:
            raise ValueError("Average number of symbols is too low")

    def check_pdsch_correctness_for_large_and_small(self, filename, csv_path, search_space_id_large,
                                                    search_space_id_small, pdcch_start_symbol_large,
                                                    pdcch_start_symbol_small, coreset_size_large,
                                                    coreset_size_small, pdsch_num_of_symbols_large,
                                                    pdsch_num_of_symbols_small):
        """
        Performs PDSCH correctness checks for Large and Small BWPs.
        :param csv_path: Path to TTI file folder
        :param filename: CSV filename
        :param search_space_id_large: searchSpaceId of Large BWP
        :param search_space_id_small: searchSpaceId of Small BWP
        :param pdcch_start_symbol_large: Value of PDCCH start symbol in TTI for Large BWP - (1 means 1 PDCCH symbol,
               17 means 2 PDCCH symbols)
        :param pdcch_start_symbol_small: Value of PDCCH start symbol in TTI for Small BWP - (1 means 1 PDCCH symbol,
               17 means 2 PDCCH symbols)
        :param coreset_size_large: Large BWP coreset size
        :param coreset_size_small: Small BWP coreset size
        :param pdsch_num_of_symbols_large: PDSCH start symbol for Large BWP - 1 or 2
        :param pdsch_num_of_symbols_small: PDSCH start symbol for Small BWP - 1 or 2
        """
        filtered_results = self.filter_and_check_pdcch_pattern_for_large_and_small(csv_path, filename,
                                                                                   search_space_id_large,
                                                                                   search_space_id_small,
                                                                                   pdcch_start_symbol_large,
                                                                                   pdcch_start_symbol_small)
        unique_sfn_slot = set(
            zip(filtered_results['sfn'], filtered_results['slot']))
        df = self.get_pandas_numpy_libs()[0].read_csv(csv_path + filename)
        merged_df = df[df.apply(lambda row: (
            row['sfn'], row['slot']) in unique_sfn_slot, axis=1)]
        merged_df.to_csv(
            csv_path + 'filtered_pattern_large_small_with_sfn_and_slot.csv', index=False)

        self.check_pdsch_correctness(
            merged_df, 1, coreset_size_large, pdsch_num_of_symbols_large)
        self.check_pdsch_correctness(
            merged_df, 2, coreset_size_small, pdsch_num_of_symbols_small)

    def check_if_any_of_prb_in_range(self, range_a, range_b):
        for i in range_a:
            if i in range_b:
                return True
        return False

    def check_pdsch_correctness_a_b2(self, csv_path, filtered_tti, bwp_id, pdcch_start_symbol_large,
                                     pdcch_start_symbol_small):
        """
        Function performs PDSCH allocation checks for Large and Small BWP for scenario A_B2.
        Single empty TTI is ignored with warning, because it depends how PDCCH is allocated and it's not an error.

        Those checks are especially for scenario CB008367_A_B2.
        For faster analysis in case of bugs, some fields are copied.
        pdcch_start_symbol_large/small can be 1 or 17 (17 is treated as 2)
        For PDCCH_Large == 1 and PDCCH_Small == 17 we expect:
        LARGE BWP:
           PDSCH_Start == Symbol 2 where sum of PRBs in slot for large BWP UEs >= 102 PRBs
           PDSCH_Start == Symbol 2 where sum of PRBs in slot for large BWP UEs < 102 PRB
                                   and minimum one PRB of UE is between PRBs: 48-144
           PDSCH_Start == Symbol 1 where full PRB allocation of UE is between PRBs: 144-245 or 0-48
        SMALL BWP:
           PDSCH_Start == Symbol 2 where minimum one PRB of UE is between PRBs: 48-144
           PDSCH_Start == Symbol 1 where full PRB allocation of UE is between PRBs: 144-217 or 0-48

        For PDCCH_Large == 17 and PDCCH_Small == 17 we expect:
        LARGE BWP:
           PDSCH_Start == Symbol 2 where minimum one PRB of UE is between PRBs: 48-240
           PDSCH_Start == Symbol 1 where full PRB allocation of UE is between PRBs: 240-245 or 0-48
        SMALL BWP:
           PDSCH_Start == Symbol 2 where minimum one PRB of UE is between PRBs: 48-217
           PDSCH_Start == Symbol 1 where full PRB allocation of UE is between PRBs: 0-48

        :param csv_path: Path where CSV is and will be stored
        :param filtered_tti: Filtered TTI data frame
        :param bwp_id: desired cellBwpId in TTI
        :param pdcch_start_symbol_large: pdcch used to filter for large bwp
        :param pdcch_start_symbol_small: pdcch used to filter for small bwp
        """
        if filtered_tti[(filtered_tti['dlFdSchedData.cellBwpId'] == bwp_id)].empty:
            warnings.warn("Warning...........TTI is empty!")
            return True
        filtered_tti = filtered_tti[
            (filtered_tti['dlFdSchedData.cellBwpId'] == bwp_id) & (filtered_tti['physCellId'] == 50)]
        filtered_tti.loc[:, ['dlFdSchedData.SLIV']] = filtered_tti.loc[:, ['dlFdSchedData.SLIV']].astype('int')
        filtered_tti['PRB_Start'] = filtered_tti.loc[:, ['dlFdSchedData.startPrb']]
        for index, row in filtered_tti.iterrows():
            filtered_tti.loc[index, 'PRB_End'] = row['PRB_Start'] + \
                row['dlFdSchedData.numOfPrb']
            filtered_tti.loc[index, 'PRB_size'] = row['dlFdSchedData.numOfPrb']
            filtered_tti.loc[index, 'Possible_faster_pdsch_for_slot'] = 'FALSE'
            sliv = self.get_start_symbol_and_length_from_sliv(row['dlFdSchedData.SLIV'])
            filtered_tti.loc[index, 'PDSCH_Start_Symbol'] = sliv
        if bwp_id == 1 and int(pdcch_start_symbol_large) == 1 and int(pdcch_start_symbol_small) == 17:
            filtered_tti.loc[:, 'allocated_prbs_in_slot'] = 0
            for index, row in filtered_tti.iterrows():
                actual_ues_base = filtered_tti[(filtered_tti['slot'] == row['slot']) &
                                               (filtered_tti['sfn'] == row['sfn'])]
                prb_sum = actual_ues_base['dlFdSchedData.numOfPrb'].sum()
                filtered_tti.loc[
                    ((filtered_tti.sfn == row['sfn']) & (filtered_tti.slot == row['slot'])),
                    'allocated_prbs_in_slot'] = prb_sum
                if ((row['PRB_Start'] >= 144 and row['PRB_End'] <= 245) or
                   (row['PRB_Start'] >= 0 and row['PRB_End'] <= 47)):
                    filtered_tti.loc[((filtered_tti.sfn == row['sfn']) & (filtered_tti.slot == row['slot'])),
                                     'Possible_faster_pdsch_for_slot'] = 'TRUE'
            for index, row in filtered_tti.iterrows():
                if (row['PDSCH_Start_Symbol'] == 2) and (row['allocated_prbs_in_slot'] >= 102):
                    filtered_tti.loc[index, 'STATUS'] = "PASSED"
                elif (row['PDSCH_Start_Symbol'] == 2) and (row['allocated_prbs_in_slot'] < 102):
                    if self.check_if_any_of_prb_in_range(range(int(row['PRB_Start']),
                                                         int(row['PRB_End'])), range(48, 143)):
                        filtered_tti.loc[index, 'STATUS'] = "PASSED"
                    else:
                        filtered_tti.loc[index, 'STATUS'] = "FAILED"
                elif (row['PDSCH_Start_Symbol'] == 1) and (row['Possible_faster_pdsch_for_slot'] == 'TRUE'):
                    filtered_tti.loc[index, 'STATUS'] = "PASSED"
                else:
                    filtered_tti.loc[index, 'STATUS'] = "FAILED"

        elif bwp_id == 2 and int(pdcch_start_symbol_large) == 1 and int(pdcch_start_symbol_small) == 17:
            for index, row in filtered_tti.iterrows():
                if ((row['PDSCH_Start_Symbol'] == 2) and self.check_if_any_of_prb_in_range(range(
                     int(row['PRB_Start']), int(row['PRB_End'])), range(48, 144))):
                    filtered_tti.loc[index, 'STATUS'] = "PASSED"
                elif (row['PDSCH_Start_Symbol'] == 1) and ((row['PRB_Start'] >= 0) and (
                        row['PRB_End'] <= 48) or ((row['PRB_Start'] >= 144) and (
                        row['PRB_End'] <= 217))):
                    filtered_tti.loc[index, 'STATUS'] = "PASSED"
                else:
                    filtered_tti.loc[index, 'STATUS'] = "FAILED"

        elif bwp_id == 1 and int(pdcch_start_symbol_large) == 17 and int(pdcch_start_symbol_small) == 17:
            for index, row in filtered_tti.iterrows():
                if ((row['PDSCH_Start_Symbol'] == 2) and self.check_if_any_of_prb_in_range(
                        range(int(row['PRB_Start']), int(row['PRB_End'])), range(48, 240))):
                    filtered_tti.loc[index, 'STATUS'] = "PASSED"
                elif (row['PDSCH_Start_Symbol'] == 1) and ((row['PRB_Start'] >= 0) and (row['PRB_End'] <= 48) or (
                        (row['PRB_Start'] >= 240) and (row['PRB_End'] <= 245))):
                    filtered_tti.loc[index, 'STATUS'] = "PASSED"
                else:
                    filtered_tti.loc[index, 'STATUS'] = "FAILED"

        elif bwp_id == 2 and int(pdcch_start_symbol_large) == 17 and int(pdcch_start_symbol_small) == 17:
            for index, row in filtered_tti.iterrows():
                if ((row['PDSCH_Start_Symbol'] == 2) and self.check_if_any_of_prb_in_range(
                        range(int(row['PRB_Start']), int(row['PRB_End'])), range(48, 217))):
                    filtered_tti.loc[index, 'STATUS'] = "PASSED"
                elif (row['PDSCH_Start_Symbol'] == 1) and ((row['PRB_Start'] >= 0) and (row['PRB_End'] <= 48)):
                    filtered_tti.loc[index, 'STATUS'] = "PASSED"
                else:
                    filtered_tti.loc[index, 'STATUS'] = "FAILED"

        filtered_tti.to_csv(csv_path + 'filtered_bwp' + str(bwp_id) + '_' + pdcch_start_symbol_large + '_' +
                            pdcch_start_symbol_small + '.csv', index=False)
        if not filtered_tti[(filtered_tti['STATUS'] == 'FAILED')].empty:
            raise ValueError("Fail - Some of traces has FAILED status")

    def check_pdsch_correctness_a_b8(self, csv_path, filtered_tti, bwp_id, pdcch_start_symbol_large,
                                     pdcch_start_symbol_small, pdcch_start_symbol_ps):
        """
        Function checks PDSCH allocation for scenario A_B8 for Large, Small and Power Saving BWP.
        Single empty TTI is ignored with warning, because it depends how PDCCH is allocated and it's not an error.

        Those checks are especially for scenario CB008367_A_B8.
        pdcch_start_symbol_large/small can be 1 or 17 (17 is treated as 2)
        After filtration of PDCCH combinations 2/2/2 and:
        For PDCCH_Large == 17 and PDCCH_Small == 17 and PDCCH_PS == 17 we expect:
        LARGE BWP:
           PDSCH_Start == Symbol 1 where PRB is fully allocated above Large BWP coreset, means that
                          PRB is between 240-273 PRB range
           PDSCH_Start == Symbol 2 where minimum one PRB of UE is between PRBs: 0-240
        SMALL BWP:
           PDSCH_Start == Symbol 2 in every case

        POWER_SAVING BWP:
           PDSCH_Start == Symbol 2 in every case

        :param csv_path: Path where CSV is and will be stored
        :param filtered_tti: Filtered TTI data frame
        :param bwp_id: desired cellBwpId in TTI
        :param pdcch_start_symbol_large: pdcch used to filter for large bwp
        :param pdcch_start_symbol_small: pdcch used to filter for small bwp
        :param pdcch_start_symbol_ps: pdcch used to filter for power saving bwp
        """
        if filtered_tti[(filtered_tti['dlFdSchedData.cellBwpId'] == bwp_id)].empty:
            warnings.warn("Warning...........TTI is empty!")
            return True
        filtered_tti = filtered_tti[
            (filtered_tti['dlFdSchedData.cellBwpId'] == bwp_id) & (filtered_tti['physCellId'] == 50)]
        filtered_tti.loc[:, ['dlFdSchedData.SLIV']] = filtered_tti.loc[:, ['dlFdSchedData.SLIV']].astype('int')
        filtered_tti['PRB_Start'] = filtered_tti.loc[:, ['dlFdSchedData.startPrb']]
        for index, row in filtered_tti.iterrows():
            filtered_tti.loc[index, 'PRB_End'] = row['PRB_Start'] + \
                row['dlFdSchedData.numOfPrb']
            filtered_tti.loc[index, 'PRB_size'] = row['dlFdSchedData.numOfPrb']
            filtered_tti.loc[index, 'Possible_faster_pdsch_for_slot'] = 'FALSE'
            sliv = self.get_start_symbol_and_length_from_sliv(row['dlFdSchedData.SLIV'])
            filtered_tti.loc[index, 'PDSCH_Start_Symbol'] = sliv
        if bwp_id == 1:
            filtered_tti.loc[:, 'allocated_prbs_in_slot'] = 0
            for index, row in filtered_tti.iterrows():
                actual_ues_base = filtered_tti[(filtered_tti['slot'] == row['slot']) &
                                               (filtered_tti['sfn'] == row['sfn'])]
                prb_sum = actual_ues_base['dlFdSchedData.numOfPrb'].sum()
                filtered_tti.loc[
                    ((filtered_tti.sfn == row['sfn']) & (filtered_tti.slot == row['slot'])),
                    'allocated_prbs_in_slot'] = prb_sum
                if ((row['PRB_Start'] >= 240 and row['PRB_End'] <= 273)):
                    filtered_tti.loc[((filtered_tti.sfn == row['sfn']) & (filtered_tti.slot == row['slot'])),
                                     'Possible_faster_pdsch_for_slot'] = 'TRUE'
            for index, row in filtered_tti.iterrows():
                if (row['PDSCH_Start_Symbol'] == 2) and self.check_if_any_of_prb_in_range(
                        range(int(row['PRB_Start']), int(row['PRB_End'])), range(0, 240)):
                    filtered_tti.loc[index, 'STATUS'] = "PASSED"
                elif (row['PDSCH_Start_Symbol'] == 1) and (row['Possible_faster_pdsch_for_slot'] == 'TRUE'):
                    filtered_tti.loc[index, 'STATUS'] = "PASSED"
                else:
                    filtered_tti.loc[index, 'STATUS'] = "FAILED"
        elif bwp_id == 2 or bwp_id == 3:
            for index, row in filtered_tti.iterrows():
                if (row['PDSCH_Start_Symbol'] == 2):
                    filtered_tti.loc[index, 'STATUS'] = "PASSED"
                else:
                    filtered_tti.loc[index, 'STATUS'] = "FAILED"

        filtered_tti.to_csv(csv_path + 'filtered_bwp' + str(bwp_id) + '_' + pdcch_start_symbol_large + '_' +
                            pdcch_start_symbol_small + '.csv', index=False)
        if not filtered_tti[(filtered_tti['STATUS'] == 'FAILED')].empty:
            raise ValueError("Fail - Some of traces has FAILED status")

    def check_pdsch_correctness_for_large_and_small_A_B2(self, filename, csv_path, search_space_id_large,
                                                         search_space_id_small, pdcch_start_symbol_large,
                                                         pdcch_start_symbol_small):
        """
        Performs PDSCH correctness checks for Large and Small BWPs.
        :param filename: filename of TTI trace like "output_dl.csv"
        :param csv_path: Path to TTI file folder
        :param search_space_id_large: searchSpaceId of Large BWP
        :param search_space_id_small: searchSpaceId of Small BWP
        :param pdcch_start_symbol_large: Value of PDCCH start symbol in TTI for Large BWP - (1 means 1 PDCCH symbol,
               17 means 2 PDCCH symbols)
        :param pdcch_start_symbol_small: Value of PDCCH start symbol in TTI for Small BWP - (1 means 1 PDCCH symbol,
               17 means 2 PDCCH symbols)
        """
        filtered_results = self.filter_and_check_pdcch_pattern_for_large_and_small(csv_path, filename,
                                                                                   search_space_id_large,
                                                                                   search_space_id_small,
                                                                                   pdcch_start_symbol_large,
                                                                                   pdcch_start_symbol_small)
        unique_sfn_slot = set(zip(filtered_results['sfn'], filtered_results['slot']))
        df = self.get_pandas_numpy_libs()[0].read_csv(csv_path + filename)
        merged_df = df[df.apply(lambda row: (row['sfn'], row['slot']) in unique_sfn_slot, axis=1)]
        merged_df.to_csv(csv_path + 'filtered_pattern_large_small_with_sfn_and_slot' + pdcch_start_symbol_large + '_' +
                         pdcch_start_symbol_small + '.csv', index=False)

        self.check_pdsch_correctness_a_b2(csv_path, merged_df, 1, pdcch_start_symbol_large, pdcch_start_symbol_small)
        self.check_pdsch_correctness_a_b2(csv_path, merged_df, 2, pdcch_start_symbol_large, pdcch_start_symbol_small)

    def check_pdsch_correctness_for_large_small_ps_A_B8(self, filename, csv_path, search_space_id_large,
                                                        search_space_id_small, search_space_id_ps,
                                                        pdcch_start_symbol_large, pdcch_start_symbol_small,
                                                        pdcch_start_symbol_ps):
        """
        Performs PDSCH correctness checks for Large and Small BWPs.
        :param filename: filename of TTI trace like "output_dl.csv"
        :param csv_path: Path to TTI file folder
        :param search_space_id_large: searchSpaceId of Large BWP
        :param search_space_id_small: searchSpaceId of Small BWP
        :param search_space_id_ps: searchSpaceId of Power Saving BWP
        :param pdcch_start_symbol_large: Value of PDCCH start symbol in TTI for Large BWP - (1 means 1 PDCCH symbol,
               17 means 2 PDCCH symbols)
        :param pdcch_start_symbol_small: Value of PDCCH start symbol in TTI for Small BWP - (1 means 1 PDCCH symbol,
               17 means 2 PDCCH symbols)
        :param pdcch_start_symbol_ps:  Value of PDCCH start symbol in TTI for Power Saving BWP
               (1 means 1 PDCCH symbol, 17 means 2 PDCCH symbols)
        """
        filtered_results = self.filter_and_check_pdcch_pattern_for_large_small_ps(csv_path, filename,
                                                                                  search_space_id_large,
                                                                                  search_space_id_small,
                                                                                  search_space_id_ps,
                                                                                  pdcch_start_symbol_large,
                                                                                  pdcch_start_symbol_small,
                                                                                  pdcch_start_symbol_ps)
        unique_sfn_slot = set(zip(filtered_results['sfn'], filtered_results['slot']))
        df = self.get_pandas_numpy_libs()[0].read_csv(csv_path + filename)
        merged_df = df[df.apply(lambda row: (row['sfn'], row['slot']) in unique_sfn_slot, axis=1)]
        merged_df.to_csv(csv_path + 'filtered_pattern_large_small_with_sfn_and_slot' + pdcch_start_symbol_large + '_' +
                         pdcch_start_symbol_small + pdcch_start_symbol_ps + '.csv', index=False)

        self.check_pdsch_correctness_a_b8(csv_path, merged_df, 1, pdcch_start_symbol_large, pdcch_start_symbol_small,
                                          pdcch_start_symbol_ps)
        self.check_pdsch_correctness_a_b8(csv_path, merged_df, 2, pdcch_start_symbol_large, pdcch_start_symbol_small,
                                          pdcch_start_symbol_ps)
        self.check_pdsch_correctness_a_b8(csv_path, merged_df, 3, pdcch_start_symbol_large, pdcch_start_symbol_small,
                                          pdcch_start_symbol_ps)
