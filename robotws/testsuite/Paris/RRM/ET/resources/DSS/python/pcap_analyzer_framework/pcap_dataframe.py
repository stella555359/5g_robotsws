import statistics
from testsuite.Paris.RRM.ET.resources.DSS.python.pcap_analyzer_framework.pandas_gate import \
    install_and_import_pandas

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

rbi = BuiltIn()

pd = None
variance = 0.0


def import_pandas():
    global pd
    pd = install_and_import_pandas()


def _calculate_timestamps(df, threshold=1, direction='DL'):
    global pd
    if direction == 'DL':
        xp_dss_EnDssQosLoadMeasurement = 'xp_dss_EnDssDlQosLoadMeasurement.measuredNgbrNnbrLoad'
        # name_col = 'DL_measuredNgbrNnbrLoad'
        allocationSequenceNumber = 'xp_dss_messages_EnDssDlQosLoadInd_t.allocationSequenceNumber'
        name_col_measuredGbrLoad = 'xp_dss_EnDssDlQosLoadMeasurement.measuredGbrLoad'
    else:
        xp_dss_EnDssQosLoadMeasurement = 'xp_dss_EnDssUlQosLoadMeasurement.MeasuredNgbrNnbrLoad'
        # name_col = 'UL_measuredNgbrNnbrLoad'
        allocationSequenceNumber = 'xp_dss_messages_EnDssUlQosLoadInd_t.allocationSequenceNumber'
        name_col_measuredGbrLoad = 'xp_dss_EnDssUlQosLoadMeasurement.measuredGbrLoad'
    df.rename(columns={
        '_ws.col.Info': 'Info',
        'frame.time': 'time',
        'frame.time_epoch': 'time_epoch',
        allocationSequenceNumber: 'allocationSequenceNumber',
        xp_dss_EnDssQosLoadMeasurement: 'measuredNgbrNnbrLoad',
        name_col_measuredGbrLoad: 'measuredGbrLoad'
    }, inplace=True)
    rbi.log('Instrument1: {}'.format(df),
            'INFO')
    rbi.log('Instrument2: {}'.format(df['time_epoch'].notnull()),
            'INFO')

    df['deltaTIME'] = abs(df['time_epoch'].diff().dropna())
    df['deltaTIME_ms'] = 1000 * df['deltaTIME']
    # df['deltaTIME_ms'] = pd.to_numeric(df['deltaTIME_ms'])
    df['deltaTIME_ms'] = df['deltaTIME_ms'].dropna().round(3).astype(float)
    df['measuredLoadAll'] = df['measuredGbrLoad'].dropna() + df['measuredNgbrNnbrLoad'].dropna()
    df['deltaMeasLoad_nGBR'] = abs(df['measuredNgbrNnbrLoad'].diff().dropna())
    df['deltaMeasLoad_GBR'] = abs(df['measuredGbrLoad'].diff().dropna())
    # uncomment if you need percentage change
    # df['percentChangeMeasLoad'] = df['measuredLoad'].pct_change().dropna() * 100
    if threshold != 0:
        df['criteria1_nGBR'] = abs(df['deltaMeasLoad_nGBR']) >= threshold
        df['criteria1_GBR'] = abs(df['deltaMeasLoad_GBR']) >= threshold

        # Step 1: Create a new column for the previous measuredLoad value
        df['previous_value'] = df['measuredNgbrNnbrLoad'].shift(1)

        # Step 2: Classify the transitions based on the threshold_2
        threshold_2 = 90.0  # Set your threshold value

        def classify_transition(row):
            if row['measuredNgbrNnbrLoad'] >= threshold_2 > row['previous_value']:
                return 'up'
            elif row['measuredNgbrNnbrLoad'] < threshold_2 <= row['previous_value']:
                return 'down'
            else:
                return 'no change'

        # apply classification function to each row
        df['transition_type_nGBR'] = df.apply(classify_transition, axis=1)

        df['criteria2_nGBR'] = df['transition_type_nGBR']

        # Move column 'criteria2' after column 'criteria1'
        col_to_move = df.pop('criteria2_nGBR')
        insert_position = df.columns.get_loc('criteria1_nGBR') + 1
        df.insert(insert_position, 'criteria2_nGBR', col_to_move)

        df['criteria_nGBR'] = df['criteria1_nGBR'] | (df['criteria2_nGBR'] == 'up') | (df['criteria2_nGBR'] == 'down')

        # Move column 'criteria' after column 'criteria2'
        col_to_move = df.pop('criteria_nGBR')
        insert_position = df.columns.get_loc('criteria2_nGBR') + 1
        df.insert(insert_position, 'criteria_nGBR', col_to_move)

        df['previous_value_GBR'] = df['measuredGbrLoad'].shift(1)

        def classify_transition_GBR(row):
            if row['measuredGbrLoad'] >= threshold_2 > row['previous_value_GBR']:
                return 'up'
            elif row['measuredGbrLoad'] < threshold_2 <= row['previous_value_GBR']:
                return 'down'
            else:
                return 'no change'

        # apply classification function to each row
        df['transition_type_GBR'] = df.apply(classify_transition_GBR, axis=1)

        df['criteria2_GBR'] = df['transition_type_GBR']

        # Move column 'criteria2' after column 'criteria1'
        col_to_move = df.pop('criteria2_GBR')
        insert_position = df.columns.get_loc('criteria1_GBR') + 1
        df.insert(insert_position, 'criteria2_GBR', col_to_move)

        df['criteria_GBR'] = df['criteria1_GBR'] | (df['criteria2_GBR'] == 'up') | (df['criteria2_GBR'] == 'down')

        # Move column 'criteria' after column 'criteria2'
        col_to_move = df.pop('criteria_GBR')
        insert_position = df.columns.get_loc('criteria2_GBR') + 1
        df.insert(insert_position, 'criteria_GBR', col_to_move)

    else:
        df['criteria_nGBR'] = False
        df['criteria_GBR'] = False
        df['criteria'] = 'Disabled'

    return df


def load_csv(csv_file_name, folder_path="", csv_file_name_analysis="analysis.csv", threshold=1, direction='DL'):
    global pd
    import_pandas()
    df = pd.read_csv(folder_path + '/' + csv_file_name, sep=';')
    df = _calculate_timestamps(df, threshold=threshold, direction=direction)
    save_df_to_csv(df, csv_file_name=csv_file_name_analysis, folder_path=folder_path)
    return df


def save_df_to_csv(df, csv_file_name="analysis.csv", folder_path=""):
    df.to_csv(folder_path + '/' + csv_file_name, sep=';', index=False)


def calculate_tolerance(value, tolerance_percent):
    tolerance = value * (tolerance_percent / 100)
    lower_bound = value - tolerance
    upper_bound = value + tolerance
    return lower_bound, upper_bound, tolerance


def check_CNI100590(df, threshold_period_min=10, threshold_period_max=100, tolerance_percent=3,
                    folder_path="", csv_file_name_analysis="analysis.csv", result_file="result_file.txt"):
    tolerance_false_alarm = 0.1
    global variance
    # Calculate max and min deltaTIME_ms
    max_deltaTIME_ms = df['deltaTIME_ms'].max()
    min_deltaTIME_ms = df['deltaTIME_ms'].min()

    threshold_period_max_lower_bound, threshold_period_max_upper_bound, threshold_period_max_tolerance =\
        calculate_tolerance(threshold_period_max, tolerance_percent)
    threshold_period_min_lower_bound, threshold_period_min_upper_bound, threshold_period_min_tolerance =\
        calculate_tolerance(threshold_period_min, tolerance_percent)
    # Initialize the bounds for threshold_period_min
    minDeltaTime_lower_bound = threshold_period_min_lower_bound
    minDeltaTime_upper_bound = threshold_period_min_upper_bound

    rbi.log('threshold_period_max_lower_bound: {}'.format(threshold_period_max_lower_bound), 'INFO')
    rbi.log('threshold_period_max_upper_bound: {}'.format(threshold_period_max_upper_bound), 'INFO')
    rbi.log('threshold_period_max_tolerance: {} [{}%]'.format(threshold_period_max_tolerance, tolerance_percent),
            'INFO')
    rbi.log('threshold_period_min_lower_bound: {}'.format(threshold_period_min_lower_bound), 'INFO')
    rbi.log('threshold_period_min_upper_bound: {}'.format(threshold_period_min_upper_bound), 'INFO')
    rbi.log('threshold_period_min_tolerance: {} [{}%]'.format(threshold_period_min_tolerance, tolerance_percent),
            'INFO')

    rbi.log('max_deltaTIME_ms: {}'.format(max_deltaTIME_ms), 'INFO')
    rbi.log('min_deltaTIME_ms: {}'.format(min_deltaTIME_ms), 'INFO')
    threshold_period_max_test = threshold_period_max_upper_bound
    threshold_period_min_test = threshold_period_min_lower_bound
    rbi.log('threshold_period_max_test: {}'.format(threshold_period_max_test), 'INFO')
    rbi.log('threshold_period_min_test: {}'.format(threshold_period_min_test), 'INFO')

    # Calculate variance
    df_filtered = df[(df['deltaTIME_ms'] >= threshold_period_min_lower_bound) &
                     (df['deltaTIME_ms'] <= threshold_period_min_upper_bound)].dropna()
    rbi.log('df_filtered: {}'.format(df_filtered), 'INFO')
    nb_elt_outside_tolerance = 0
    nb_elt_all_df = df['deltaTIME_ms'].size
    if not df_filtered.empty:
        variance = df_filtered['deltaTIME_ms'].var()
        nb_elt_df = df_filtered['deltaTIME_ms'].size
        print("Variance on min deltaTIME_ms using statistics module:", variance)
        rbi.log('Variance on min deltaTIME_ms: {}'.format(variance), 'INFO')
        print("nb_elt_all_df for min deltaTIME_ms:", nb_elt_all_df)
        rbi.log('nb_elt_all_df for min deltaTIME_ms: {}'.format(nb_elt_all_df), 'INFO')
        print("nb_elt_filtered_df in min deltaTIME_ms:", nb_elt_df)
        rbi.log('nb_elt_filtered_df in min deltaTIME_ms: {}'.format(nb_elt_df), 'INFO')
        nb_elt_outside_tolerance = nb_elt_all_df - nb_elt_df
        print("nb_elt_outside_tolerance for min deltaTIME_ms:", nb_elt_outside_tolerance)
        rbi.log('nb_elt_outside_tolerance for min deltaTIME_ms: {}'.format(nb_elt_outside_tolerance), 'INFO')
    else:
        variance = df['deltaTIME_ms'].var()
        nb_elt_df = df['deltaTIME_ms'].size
        print("Variance on deltaTIME_ms using statistics module:", variance)
        rbi.log('Variance on deltaTIME_ms: {}'.format(variance), 'INFO')
        print("nb_elt_df in deltaTIME_ms:", nb_elt_df)
        rbi.log('nb_elt_df in deltaTIME_ms: {}'.format(nb_elt_df), 'INFO')

    # Check if the values are within the threshold period with tolerance
    false_alarm_rate_min_delta_time_ms = nb_elt_outside_tolerance / nb_elt_df
    result_check1 = (max_deltaTIME_ms <= threshold_period_max_upper_bound)
    rbi.log('Check1 result_check1: {}'.format(result_check1), 'INFO')
    rbi.log('Check1 result_check1: {}'.format(result_check1), 'INFO')

    df_max_upper_period_filtered = df[(df['deltaTIME_ms'] >= threshold_period_max_upper_bound)].dropna()
    rbi.log('df_max_upper_period_filtered: {}'.format(df_max_upper_period_filtered), 'INFO')
    nb_elt_df_max_upper_period_filtered = df_max_upper_period_filtered.size

    if nb_elt_df_max_upper_period_filtered != 0:
        msg = "max_deltaTIME_ms > threshold_period_max_upper_bound present [nb_elt_outside_tolerance_max/nb_elt={}/{}]"
        rbi.log(msg.format(nb_elt_df_max_upper_period_filtered, nb_elt_all_df), 'ERROR')

    def return_min_deltaTIME_ms(row, lower_bound, upper_bound):
        return row if lower_bound <= row <= upper_bound else None

    # Check each value in the DataFrame min_deltaTIME_ms
    df['min_deltaTIME_ms'] = df['deltaTIME_ms'].dropna().apply(
        lambda x: return_min_deltaTIME_ms(x, minDeltaTime_lower_bound, minDeltaTime_upper_bound)
    )

    df['result_check2'] = df['min_deltaTIME_ms'].dropna().apply(
        lambda x: minDeltaTime_lower_bound <= x <= minDeltaTime_upper_bound
    )

    # Count the number of false alarms
    false_alarm_count = df['result_check2'].value_counts().get(False, 0)
    rbi.log('count of false Alarm: {} with tolerance: {}'.format(false_alarm_count, tolerance_false_alarm), 'INFO')

    # Calculate the false alarm rate
    false_alarm_rate = false_alarm_count / len(df)
    rbi.log('Check3 false_alarm_rate: {}'.format(false_alarm_rate), 'INFO')

    # Check if the false alarm rate is within the tolerance
    result_check3 = (false_alarm_rate <= tolerance_false_alarm)
    rbi.log('Check3 result_check3: {} with tolerance {}'.format(result_check3, tolerance_false_alarm), 'INFO')

    def check_conditions(row, _threshold_period_max, _tolerance):
        if pd.isna(row['deltaTIME_ms']):
            return True
        if row['criteria_GBR']:
            return True if row['deltaTIME_ms'] < _threshold_period_max + _tolerance else False
        elif row['criteria_nGBR']:
            return True if row['deltaTIME_ms'] < _threshold_period_max + _tolerance else False
        else:
            if (_threshold_period_max - _tolerance) <= row['deltaTIME_ms'] <= (_threshold_period_max + _tolerance):
                return True
            else:
                return False

    df['check'] = df.apply(lambda row: check_conditions(row, threshold_period_max, threshold_period_max_tolerance),
                           axis=1)

    print(df)
    # Combine all checks
    final_result = df['check'].all() and result_check1 and result_check3
    rbi.log('Check Result: {}'.format(df), 'INFO')
    rbi.log('=====> FinalResult: {}'.format(final_result), 'INFO')

    save_df_to_csv(df, csv_file_name=csv_file_name_analysis, folder_path=folder_path)

    with open(result_file, 'a') as result_file_fd:
        # Write results to the result file
        result_file_fd.write("\n\tcheck_CNI100590 Results\n")
        result_file_fd.write("\t\tthreshold_period_max_lower_bound {}\n".format(threshold_period_max_lower_bound))
        result_file_fd.write("\t\tthreshold_period_max_upper_bound {}\n".format(threshold_period_max_upper_bound))
        result_file_fd.write("\t\tthreshold_period_max_tolerance {}\n".format(threshold_period_max_tolerance))
        result_file_fd.write("\t\tthreshold_period_min_lower_bound {}\n".format(threshold_period_min_lower_bound))
        result_file_fd.write("\t\tthreshold_period_min_upper_bound {}\n".format(threshold_period_min_upper_bound))
        result_file_fd.write("\t\tthreshold_period_min_tolerance {}\n".format(threshold_period_min_tolerance))
        result_file_fd.write("\t\tmax_deltaTIME_ms {}\n".format(max_deltaTIME_ms))
        result_file_fd.write("\t\tmin_deltaTIME_ms {}\n".format(min_deltaTIME_ms))
        result_file_fd.write("\t\tvariance min deltaTIME {}\n".format(variance))
        result_file_fd.write("\t\tnb_elt_outside_tolerance for min deltaTIME_ms {}\n".format(nb_elt_outside_tolerance))
        text = "\t\tfalse_alarm_rate_min_delta_time_ms for min deltaTIME_ms {}\n"
        result_file_fd.write(text.format(false_alarm_rate_min_delta_time_ms))
        text = "\t\tnb_elt_df_max_upper_period_filtered for min deltaTIME_ms {}\n"
        result_file_fd.write(text.format(nb_elt_df_max_upper_period_filtered))
        if nb_elt_df_max_upper_period_filtered != 0:
            msg = "max_deltaTIME_ms > threshold_period_max_upper_bound present" +\
                  " [nb_elt_outside_tolerance_max/nb_elt={}/{}]"
            result_file_fd.write(msg.format(nb_elt_df_max_upper_period_filtered, nb_elt_all_df))

    return final_result
