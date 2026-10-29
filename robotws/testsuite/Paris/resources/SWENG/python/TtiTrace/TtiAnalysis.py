import logging
import os
import warnings
import traceback
from functools import wraps

# ET or Feature Specific Libraries:
from helper_functions import display_df_as_html
import tti_dataframe

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn
from robot.utils import DotDict

# ====================================================================================================[120 characters]
#   Global Variables
# ====================================================================================================[120 characters]

rbi = BuiltIn()


def ensure_pandas_imported(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        global pd, np
        pd, np = tti_dataframe.import_pandas()
        return func(*args, **kwargs)
    return wrapper


def log_begin_end_func_name(fn):
    def inner(*args, **kwargs):
        logging.info("============================== Begin Function {0}".format(fn.__name__))
        func_return = fn(*args, **kwargs)
        logging.info("============================== End Function {0}".format(fn.__name__))
        return func_return
    return inner


def visualization(func):
    @wraps(func)
    @ensure_pandas_imported
    def wrapper(*args, **kwargs):
        pd.set_option('display.max_columns', None)
        pd.set_option('display.expand_frame_repr', False)
        return func(*args, **kwargs)
    return wrapper


def deep_dict_to_str(value):
    if isinstance(value, dict):
        return str({k: deep_dict_to_str(v) for k, v in value.items()})
    elif isinstance(value, list):
        return tuple(deep_dict_to_str(v) for v in value)
    else:
        return value


def convert_to_plain(value):
    if isinstance(value, DotDict):
        return {k: convert_to_plain(v) for k, v in value.items()}
    elif isinstance(value, list):
        return [convert_to_plain(item) for item in value]
    return value


def convert_dataframe_columns_to_int(df):
    for column in df.columns:
        if df[column].apply(lambda x: isinstance(x, list)).any():
            logging.debug(f"Column {column} contains lists and will not be converted to integers.")
        elif df[column].dtype != 'float64':
            logging.debug(f"Column {column} is not of type float64 and will not be converted to integers.")
        else:
            df[column] = df[column].astype(int)
    return df


def convert_filter_values_to_int(filter_dict):
    def convert_value(value):
        if isinstance(value, list):
            return [convert_value(v) for v in value]
        elif isinstance(value, dict):
            return convert_dict(value)
        elif isinstance(value, (int, float)):
            return int(value) if isinstance(value, float) and value.is_integer() else value
        else:
            try:
                float_value = float(value)
                return int(float_value) if float_value.is_integer() else value
            except (ValueError, TypeError):
                return value

    def convert_dict(d):
        for key, values in d.items():
            if values is None:
                d[key] = None
            elif isinstance(values, dict):
                d[key] = convert_dict(values)
            elif isinstance(values, list):
                d[key] = [convert_value(v) for v in values]
            else:
                d[key] = convert_value(values)
        return d

    if isinstance(filter_dict, dict):
        return convert_dict(filter_dict)
    elif isinstance(filter_dict, list):
        return [convert_value(value) for value in filter_dict]
    elif isinstance(filter_dict, int):
        return filter_dict
    elif isinstance(filter_dict, float):
        try:
            float_value = float(filter_dict)
            return int(float_value) if float_value.is_integer() else filter_dict
        except (ValueError, TypeError):
            return filter_dict
    else:
        return filter_dict


def Make_myClass(path_to_json, events_list=None):
    """
    Used to create an instance of the TtiAnalysis class in RobotFramework interfaces to this mdoule.
    """
    myinstance = TtiAnalysis(path_to_json, events_list)
    return myinstance


def handle_none_args(func):
    """ Decorator to handle None values in arguments.
    Useful to handle values from Robot Framework that are passed as strings.
    """
    @wraps(func)
    def wrapper(*args, **kwargs):
        args = tuple(None if isinstance(arg, str) and arg == 'None' else arg for arg in args)
        kwargs = {k: None if isinstance(v, str) and v == 'None' else v for k, v in kwargs.items()}
        return func(*args, **kwargs)
    return wrapper


class TtiAnalysis:
    """
    This class represents a TTI analysis tool.

    Attributes:
        jsonfile (str): The path to the JSON file containing the TTI data.
        df (pandas.DataFrame): The DataFrame containing the TTI data.

    Methods:
        verify_distribution_table_of: Counts the number of occurrences and percentage of the given event per RNTI.
        check_target_bler_is_less_than_percentage_with_df: Checks if the target BLER is less than a given percentage.
        check_min_max_doesnt_exceed: Provides different statistical analysis for a series such as mean, max, min,
                                     count etc.
        check_min_for_column: Check and return the minimum value of a column for a given dataframe.
        check_max_for_column: Check and return the maximum value of a column for a given dataframe.
        get_columns_with_same_values: Get the list of columns in a dataframe where all the values are the same.
        get_columns_with_long_names: Get the list of columns in a dataframe where name contains at least 2 dots.
        check_unique_value_for_column: Check if a given column has a unique value and return the result and the
                                       value.
        get_column_values: Get the list of values of a column in the dataframe.
        get_first_column_value: Get the first valid index and value of a column in the dataframe.
        get_columns_names_containing_substring: Get the list of columns in the dataframe where name contains
                                                col_substring.
        check_substrings_in_columns: Check if a list of substrings exists in the dataframe columns and return a
                                     dictionary.
        check_multi_columns_values: Check a dictionary of column names and values to see if they are the same in the
                                    dataframe.
        check_value_inrange_for_column: Check if a given column has all values within a given range.
        check_value_inrange_for_column_dict: Check if columns given in the dict has all values within a given range.
        get_dict_from_dataframe_column: Get the dictionary of values from a column in a dataframe.
        get_list_from_dataframe_column: Get the list of values from a column in a dataframe.
        get_list_of_dict_from_dataframe_column: Get the list of dictionaries from a column in a dataframe.
        get_first_dict_value_from_dataframe_column: Get the first dictionary value from a column in a dataframe.
        get_first_list_value_from_dataframe_column: Get the first list value from a column in a dataframe.
        get_first_list_of_dict_value_from_dataframe_column: Get the first list of dictionaries value from a column in
                                                            a dataframe.
        export_dataframe_to_csv: Export the dataframe to a CSV file.
        export_dataframe_to_json: Export the dataframe to a JSON file.
        export_specific_parameters: Export the dataframe content to a CSV file for each event.parameter in parameters
    """

    def __init__(self, jsonfile=None, events_list=None, load_the_stuff=False):
        self.jsonfile = jsonfile
        self.df = None
        self.events_list = events_list
        self._is_float = None
        print("Creating instance of TtiAnalysis with parameters:")
        print(f"Events list: {events_list}")
        print(f"Load the stuff: {load_the_stuff}")
        print(f"Json file: {jsonfile}")
        logging.basicConfig(level=logging.INFO)
        if load_the_stuff:
            self._load_dataframe()

    @ensure_pandas_imported
    def _load_dataframe(self):
        """
        The `_load_dataframe` method is called at the start of each keyword.
        This method checks if the DataFrame has already been loaded, if not,
        it loads the DataFrame from the JSON file. This way, the JSON file
        does not need to exist until the first keyword of the library is
        called.

        This allows the instantiation via a robotframework keyword without
        the need to provide the JSON file path.
        """
        if self.jsonfile is None:
            raise ValueError(
                "jsonfile path is required. Either provide it during "
                "TtiAnalysis instantiation or pass it to the export method."
            )
        if self.df is None or self._is_float:
            self.df = (
                tti_dataframe.load_tti_trace_as_pandas_dataframe(
                    self.jsonfile, self.events_list
                )
            )
            self._is_float = False
        for column in self.df.columns:
            if self.df[column].apply(
                    lambda x: isinstance(x, list)
            ).any():
                logging.debug(
                    f"Column {column} contains lists and will not be "
                    f"converted to integers."
                )
            elif self.df[column].dtype != 'float64':
                logging.debug(
                    f"Column {column} is not of type float64 and will not "
                    f"be converted to integers."
                )
            else:
                # Replace non-finite values with NaN
                self.df[column] = self.df[column].replace(
                    [np.inf, -np.inf], np.nan
                )
                # Replace NaN values with a default value (e.g., 0)
                self.df[column] = self.df[column].fillna(0)
                # Convert the column to integers
                self.df[column] = self.df[column].astype(int)

    def _load_dataframe_float(self):
        """
        The `_load_dataframe_float` method is called at the start of each
        keyword manipulating float values. This method checks if the
        DataFrame has already been loaded, if not, it loads the DataFrame
        from the JSON file. This way, the JSON file does not need to exist
        until the first keyword of the library is called.

        This allows the instantiation via a robotframework keyword without
        the need to provide the JSON file path.

        :return: None
        """
        if self.jsonfile is None:
            raise ValueError(
                "jsonfile path is required. Either provide it during "
                "TtiAnalysis instantiation or pass it to the export method."
            )
        if self.df is None or not self._is_float:
            self.df = (
                tti_dataframe.load_tti_trace_as_pandas_dataframe(
                    self.jsonfile, self.events_list
                )
            )
            self._is_float = True

    def _ensure_jsonfile_is_set(self):
        """
        Helper method to verify that jsonfile is set.
        Raises ValueError if jsonfile is None.
        """
        if self.jsonfile is None:
            raise ValueError(
                "jsonfile path is required. Either provide it during "
                "TtiAnalysis instantiation or set it explicitly."
            )

    @visualization
    @log_begin_end_func_name
    @handle_none_args
    def verify_distribution_table_of(self, column_name, plot=None, validate=None, need_return=False):
        """ This function counts the number of occurence and percentage
            of the given event per rnti

            Suggested  file:  file with dlharq matcher WITHOUT High reliability filters
            The function also allows generation of graph and validation of certain value and threshold

            :param column_name: event name
            :param plot: use "Scatter" to generate a scatter graph of column_name against timeStamp
            :param validate: dictionary of values and threshold you want to validate
            :param need_return: return the dataframe of the distribution table

            :returns df: dataframe of distributed table
        """
        self._load_dataframe_float()
        print(f"Column name: {column_name}")
        print(f"Plot type: {plot}")
        if 'rnti' not in self.df.columns:
            print(f"rnti not in df columns:\n{self.df.columns}")
            raise KeyError("'rnti' column does not exist in the DataFrame.")
        else:
            counted_df = (self.df.groupby(['rnti', column_name]).size().reset_index(name='Count').set_index(
                ['rnti', column_name]).assign(
                    Percentage=lambda x: (x['Count']) * 100 / (x.groupby(['rnti'])['Count'].transform('sum'))))
            display_df_as_html(counted_df)
            # Option to plot the graph
            if plot == 'Scatter':
                # Drop column where event (column_name) is empty e.g by default, plot will filter BR and HR
                # using dlFdscheddata.lamode but if column_name is in a different row then graph will filter
                # empty values
                fil_df = self.df.dropna(subset=[column_name]).dropna(how='all', axis=1)
                self._plot_df_with_scatter(fil_df, column_name,
                                           os.path.dirname(self.jsonfile), 'distribution_table', 'timeStamp')
            elif plot == 'Bar':
                self._plot_df_with_bar(counted_df.reset_index(), column_name, "Count", os.path.dirname(self.jsonfile))
            # Option to validate
            if not validate:
                rbi.log("No validation requested... keyword pass!")
            else:
                rbi.log("Values and percentage and threshold required:")
                val_df = pd.DataFrame.from_dict(validate)
                display_df_as_html(val_df)
                rbi.log("Checking if percentage meets validation thresholds..")
                val_df['Threshold'] = val_df['Threshold'].astype('float64')
                reset_df = counted_df.reset_index()
                reset_df[column_name] = reset_df[column_name].astype('object')
                crossed_df = pd.merge(reset_df, val_df, left_on=column_name, right_on='Value')
                crossed_df = crossed_df.drop(columns=['Count', 'Value'])
                crossed_df['Verdict'] = np.where(crossed_df['Percentage'] < crossed_df['Threshold'], 'Passed',
                                                 'Failed')
                if len(crossed_df) == 0:
                    rbi.log("Values indicated on validation not found on the dataframe. Passing test case..")
                else:
                    display_df_as_html(crossed_df)
                    if len(crossed_df[crossed_df['Verdict'] == 'Failed']) == 0:
                        rbi.log("Percentage within threshold! Passing test case!")
                    else:
                        rbi.log(f"Percentage did not reach required threshold for {column_name}", 'ERROR')
                        rbi.fail("Failing test case!")
            if need_return:
                return counted_df

    @log_begin_end_func_name
    @handle_none_args
    def _plot_df_with_scatter(self, df, yaxis_column, base_location, postfix="",
                              xaxis_column="normalized_sfn", title="", group_by='rnti',
                              second_yaxis_col=None, third_yaxis_col=None, fourth_yaxis_col=None):
        """ This function generates .html plot using yaxis_column and xaxis_column columns.
            It is recomended to use 'normalized_sfn' for xaxis_column.
        """
        self._load_dataframe_float()
        try:
            with warnings.catch_warnings():
                warnings.simplefilter("ignore", category=FutureWarning)
                import plotly.graph_objects as go
                from plotly.subplots import make_subplots
                fig = go.Figure()
                fig = make_subplots(rows=1, cols=len(df[group_by].unique()),
                                    subplot_titles=(df[group_by].unique()))
                for i, grouped in enumerate(df[group_by].unique()):
                    print(f"Grouped: {grouped}")
                    grouped_df = df[df[group_by] == grouped]
                    # Check if xaxis_column exists in grouped_df
                    if xaxis_column in grouped_df.columns:
                        print(f"Xaxis column exists: {xaxis_column}")
                        # Filter all rows with xaxis_column
                        filtered_df = grouped_df.dropna(subset=[xaxis_column])
                    else:
                        print(f"Xaxis column does not exist: {xaxis_column}")
                        filtered_df = grouped_df
                    dir = 'dl' if 'dlFdSchedData.laMode' in df.columns else 'ul'
                    # Check if lamode still present
                    if not df.columns.isin(['dlFdSchedData.laMode', 'ulFdSchedData.laMode']).any() or \
                            len(filtered_df[f"{dir}FdSchedData.laMode"]) == 0:
                        fig.add_trace(go.Scatter(x=grouped_df[xaxis_column], y=grouped_df[yaxis_column],
                                                 mode='markers', marker=dict(size=3),
                                                 name=f"{yaxis_column}_{group_by}_{grouped}"), row=1, col=i+1)
                    else:
                        lamode_br_df = grouped_df[grouped_df[f"{dir}FdSchedData.laMode"] == 'BASICRELIABILITY']
                        fig.add_trace(go.Scatter(x=lamode_br_df[xaxis_column], y=lamode_br_df[yaxis_column],
                                                 mode='markers', marker=dict(size=3),
                                                 name=f"{yaxis_column}_BR_{grouped}"), row=1, col=i+1)
                        lamode_hr_df = grouped_df[grouped_df[f"{dir}FdSchedData.laMode"] == 'HIGHRELIABILITY']
                        fig.add_trace(go.Scatter(x=lamode_hr_df[xaxis_column], y=lamode_hr_df[yaxis_column],
                                                 mode='markers', marker=dict(size=3),
                                                 name=f"{yaxis_column}_HR_{grouped}"), row=1, col=i+1)
                    if second_yaxis_col is not None:
                        fig.add_trace(go.Scatter(x=grouped_df[xaxis_column], y=grouped_df[second_yaxis_col],
                                                 mode='markers', marker=dict(size=3),
                                                 name=f"{second_yaxis_col}_{group_by}_{grouped}"),
                                      row=1, col=i+1)
                    if third_yaxis_col is not None:
                        fig.add_trace(go.Scatter(x=grouped_df[xaxis_column], y=grouped_df[third_yaxis_col],
                                                 mode='markers', marker=dict(size=3),
                                                 name=f"{third_yaxis_col}_{group_by}_{grouped}"), row=1, col=i+1)
                    if fourth_yaxis_col is not None:
                        fig.add_trace(go.Scatter(x=grouped_df[xaxis_column], y=grouped_df[fourth_yaxis_col],
                                                 mode='markers', marker=dict(size=3),
                                                 name=f"{fourth_yaxis_col}_{group_by}_{grouped}"), row=1, col=i+1)
                fig.update_layout(title=title, xaxis_title=xaxis_column, yaxis_title=yaxis_column)
                if not title:
                    title = yaxis_column.replace(".", "_")
                fixed_title = title.replace(' ', '_')
                file_name = f"/{fixed_title}_{postfix}.html" if postfix else f"/{fixed_title}.html"
                fig.write_html(base_location+file_name, auto_open=False)
        except ModuleNotFoundError:
            logging.warning("plotly is not installed therefore plot will not be saved, please install plotly using"
                            "the command: pip install plotly")
        except Exception as e:
            logging.basicConfig(level=logging.DEBUG)
            logging.error(f"Error:\n{e}")
            logging.error(traceback.format_exc())

    @log_begin_end_func_name
    def _plot_df_with_bar(self, df,
                          xaxis_column="timeStamp",
                          yaxis_column="",
                          base_location="",
                          postfix="bar_graph",
                          title="",
                          group_by='rnti'):
        """ This function generates bar graph .html plot using yaxis_column and xaxis_column columns.
            It is recomended to use the df generated by verify_distribution_table_of function
        """
        self._load_dataframe_float()
        try:
            import plotly.graph_objects as go
            from plotly.subplots import make_subplots
            fig = go.Figure()
            fig = make_subplots(rows=1, cols=len(df[group_by].unique()), subplot_titles=(df[group_by].unique()))
            for index, grouped in enumerate(df[group_by].unique()):
                grouped_df = df[df[group_by] == grouped]
                if df.columns.isin(['dlFdSchedData.laMode', 'ulFdSchedData.laMode']).any():
                    dir = 'dl' if 'dlFdSchedData.laMode' in df.columns else 'ul'
                    lamode_br_df = grouped_df[grouped_df['{}FdSchedData.laMode'.format(dir)] == 'BASICRELIABILITY']
                    fig.add_trace(go.Bar(x=lamode_br_df[xaxis_column], y=lamode_br_df[yaxis_column],
                                  name=f"{xaxis_column}_{group_by}_{grouped}_BR"),
                                  row=1, col=index+1)
                    lamode_hr_df = grouped_df[grouped_df['{}FdSchedData.laMode'.format(dir)] == 'HIGHRELIABILITY']
                    fig.add_trace(go.Bar(
                        x=lamode_hr_df[xaxis_column], y=lamode_hr_df[yaxis_column],
                        name=f"{xaxis_column}_{group_by}_{grouped}_HR"), row=1, col=index+1)
                else:
                    fig.add_trace(go.Bar(
                        x=df[xaxis_column], y=grouped_df[yaxis_column],
                        name=f"{xaxis_column}_{group_by}_{grouped}"), row=1, col=index+1)
            fig.update_layout(title=title, xaxis_title=xaxis_column, yaxis_title=yaxis_column)
            if not title:
                title = xaxis_column.replace(".", "_")
            file_name = f"/{title.replace(' ', '_')}{'_%s.html' % postfix if postfix else '.html'}"
            fig.write_html(base_location+file_name, auto_open=False)
        except ModuleNotFoundError:
            logging.warning("plotly is not installed therefore plot will not be saved, please install plotly using "
                            "the command: pip install plotly")

    @log_begin_end_func_name
    def check_target_bler_is_less_than_percentage_with_df(self, filtered_df,
                                                          txNumber_event,
                                                          laMode_event_value,
                                                          tolerance,
                                                          threshold=1):
        """ This function checks if the target BLER is less than a given percentage.

        Args:
            filtered_df (pandas.DataFrame): The DataFrame containing the filtered data.
            txNumber_event (str): The event name for the transmission number.
            laMode_event_value (str): The event value for the laMode.
            tolerance (int): The tolerance value.
            threshold (int): The threshold value.

        Returns:
            :return: The result of the check.
        """
        self._load_dataframe_float()
        # Calculate value counts and percentage for txNumber in BR/HR modes seprately
        counted_df = (filtered_df
                      .groupby(['rnti', txNumber_event])
                      .size()
                      .reset_index(name='Count')
                      .set_index(['rnti', txNumber_event])
                      .assign(Percentage=lambda x: (x['Count']) * 100 / (
                          x.groupby(['rnti'])['Count'].transform('sum')))
                      .reset_index())
        display_df_as_html(counted_df)
        rnti_group = {}
        for rnti, df_group in counted_df.groupby('rnti'):
            percentage_2_values = df_group[df_group[txNumber_event] == 2][[
                "Percentage"]].values
            percentage_1_values = df_group[df_group[txNumber_event] == 1][[
                "Percentage"]].values
            if len(percentage_2_values) == 0:
                target_bler_reached = True
                rbi.log("There is no txNumber=2 transmission i.e BLER is 0%.\
                        Setting BLER check pass for rnti {} and {}".format(rnti, laMode_event_value))
                break
            target_bler = 100 * (percentage_2_values / percentage_1_values)
            rbi.log("Checking if Computed target BLER({}) on RNTI {} with {} mode is less than \
                    threshold:({}%)+tolerance({}%)".format(
                        target_bler, rnti, laMode_event_value, threshold, tolerance))
            target_bler_reached = True if target_bler <= (
                threshold + tolerance) else False
            rnti_group[rnti] = target_bler_reached
        for rnti, correlation_passed in rnti_group.items():
            if target_bler_reached:
                rbi.log(f"target bler on RNTI {rnti} is less than {(threshold + tolerance)} with " +
                        f"{laMode_event_value} mode. Check PASSED")
                result = "Passed"
            else:
                rbi.fail(f"target bler on RNTI {rnti} is not less than {(threshold + tolerance)} with " +
                         f"{laMode_event_value} mode", 'ERROR')
                result = "Failed"
        return result

    @visualization
    @log_begin_end_func_name
    def check_min_max_doesnt_exceed(self, column_name):
        """ Provides different statistical analysis for a series such as mean, max, min, count etc.
            Then it checks if min and max doesn't exceed the threshold

            Suggested  file:  file WITHOUT High reliability filters

            :param  column_name: event that you want to describe
            :return: result of the check
        """
        self._load_dataframe_float()
        max_threshold = 15
        min_threshold = -15
        rbi.log("Checking if max and min doesn't exceed defined thresholds..")
        rbi.log('MAX threshold: {} MIN threshold: {}'.format(max_threshold, min_threshold))
        display_df_as_html(pd.DataFrame(self.df[column_name].describe()))

        if (self.df[column_name].describe()['max'] > max_threshold) or \
                (self.df[column_name].describe()['min'] < min_threshold):
            rbi.log("Max or min did not reach required threshold for {}".format(column_name), 'ERROR')
            rbi.fail("Failing test case!")
            result = "Failed"
        else:
            rbi.log('Threshold reached. Test case passing!')
            result = "Passed"
        return result

    @log_begin_end_func_name
    def check_min_for_column(self, column_name):
        """ Check and return the minimum value of a column for a given dataframe
            :param  column_name: event that you want to describe
            :return: the minimum value of the specified column
        """
        self._load_dataframe_float()
        min_value = self.df[column_name].min()
        return min_value

    @log_begin_end_func_name
    def check_max_for_column(self, column_name):
        """ Check and return the maximum value of a column for a given dataframe
            :param  column_name: event that you want to describe
            :return the maximum value of the specified column
        """
        self._load_dataframe_float()
        max_value = self.df[column_name].max()
        return max_value

    @log_begin_end_func_name
    def get_columns_with_same_values(self):
        """ Get the list of columns in a dataframe where all the values are the same
            :return: List of columns with the same values
        """
        self._load_dataframe_float()
        columns_with_same_values = []
        for column in self.df.columns:
            self.df[column] = self.df[column].apply(deep_dict_to_str)
            if self.df[column].nunique() == 1:
                columns_with_same_values.append(column)
        return columns_with_same_values

    @log_begin_end_func_name
    def get_columns_with_long_names(self):
        """ Get the list of columns in a dataframe where name contains at least 2 . (dots)
            :return: List of columns with long names"""
        self._load_dataframe_float()
        columns_with_long_names = [column for column in self.df.columns if column.count('.') >= 2]
        return columns_with_long_names

    @log_begin_end_func_name
    def check_unique_value_for_column(self, column_name):
        """ Check if a given column has a unique value and return the result and the value
            :param  column_name: Column name to check
            :return: True if the column has a unique value, False otherwise
        """
        self._load_dataframe_float()
        self.df[column_name] = self.df[column_name].apply(deep_dict_to_str)
        has_unique_value = self.df[column_name].nunique() == 1
        value = self.df[column_name].iloc[0] if has_unique_value else None
        return has_unique_value, value

    @log_begin_end_func_name
    def get_column_values(self, column_name):
        """ Get the list of values of a column in the dataframe

        Args:
            :param  column_name: column to search for values

        Returns:
            :return: List of values of the column
        """
        self._load_dataframe_float()
        self.df[column_name] = self.df[column_name].apply(deep_dict_to_str)
        return self.df[column_name].tolist()

    @log_begin_end_func_name
    def get_first_column_value(self, column_name):
        """ Get the first valid index and value of a column in the dataframe

        Args:
            :param  column_name: column to search for value

        Returns:
            :return: Index and value of the first valid index
        """
        self._load_dataframe_float()
        df = self.df
        df[column_name] = df[column_name].apply(deep_dict_to_str)
        index = df[column_name].first_valid_index()
        value = df[column_name].loc[index]
        return index, value

    @log_begin_end_func_name
    def get_columns_names_containing_substring(self, col_substring):
        """ Get the list of columns in the dataframe where name contains col_substring

        Args:
            :param  col_substring: Substring to search for in column names

        Returns:
            :return: List of columns containing the substring
        """
        self._load_dataframe_float()
        df = self.df
        columns_with_substring = [column for column in df.columns if col_substring in column]
        return columns_with_substring

    @log_begin_end_func_name
    def check_substrings_in_columns(self, substrings):
        """ Check if a list of substrings exists in the dataframe columns and return a dictionary.
        The dictionary keys are the list elements and the values are lists of columns containing the key substring.

        Args:
            :param  substrings: List of substrings to search for in column names

        Returns:
            :return: Dictionary with substrings as keys and lists of columns containing the substring as values
        """
        self._load_dataframe_float()
        result_dict = {}
        for substring in substrings:
            columns_with_substring = self.get_columns_names_containing_substring(substring)
            result_dict[substring] = columns_with_substring
        return result_dict

    @log_begin_end_func_name
    def check_multi_columns_values(self, column_values_dict):
        """ Check a dictionary of column names and values to see if they are the same in the dataframe

        Args:
            :param  column_values_dict: Dictionary of column names and values to check

        Returns:
            :return: True if all values are the same, False otherwise
        """
        self._load_dataframe_float()
        result = True
        for column_name, value in column_values_dict.items():
            for column in self.df.columns:
                if column_name == column:
                    self.df[column_name] = self.df[column_name].apply(deep_dict_to_str)
                    has_unique_value = self.df[column_name].nunique() == 1
                    if not has_unique_value or self.df[column_name].iloc[0] != value:
                        print(f"Column {column_name} has different value: {self.df[column_name].iloc[0]}")
                        result = False
                        break
                break
        return result

    @log_begin_end_func_name
    def check_value_inrange_for_column(self, column_name, value_range):
        """ Check if a given column has all values within a given range

        Args:
            :param  column_name: Column name to check
            :param  value_range: Tuple of min and max values for the range

        Returns:
            :return: True if all values are within the range, False otherwise
        """
        self._load_dataframe_float()
        try:
            value_range = tuple(map(float, value_range))
        except ValueError:
            raise ValueError("Invalid value range. Please provide a valid range")
        if len(value_range) != 2:
            raise ValueError("Invalid value range. Please provide a valid range")
        if value_range[0] > value_range[1]:
            raise ValueError("Invalid value range. Please provide a valid range")
        self.df[column_name] = self.df[column_name].apply(deep_dict_to_str)
        result = self.df[column_name].between(value_range[0], value_range[1]).all()
        return result

    @log_begin_end_func_name
    def check_value_inrange_for_column_dict(self, columns_ranges_dict):
        """ Check if columns given in the dict has all values within a given range

        Args:
            :param  columns_ranges_dict: Dictionary of column names and ranges (Tuple of min and
                max values) to check

        Returns:
            :return: True if all values for all the dict items are within the range, False otherwise
        """
        self._load_dataframe_float()
        for column_name, value_range in columns_ranges_dict.items():
            print(f"Checking column {column_name} with range {value_range}")
            try:
                value_range = tuple(map(float, value_range))
            except ValueError:
                raise ValueError("Invalid value range. Please provide a valid range")
            if len(value_range) != 2:
                raise ValueError("Invalid value range. Please provide a valid range")
            if value_range[0] > value_range[1]:
                raise ValueError("Invalid value range. Please provide a valid range")
            self.df[column_name] = self.df[column_name].apply(deep_dict_to_str)
            result = self.df[column_name].between(value_range[0], value_range[1]).all()
            print(f"Checked column: {result}")
            if not result:
                return False
        return True

    def get_dict_from_dataframe_column(self, column_name):
        """ Get the dictionary of values from a column in a dataframe

        Args:
            :param  column_name: Column name to get the dictionary from

        Returns:
            :return: Dictionary of values from the column
        """
        self._load_dataframe_float()
        column_values = self.df[column_name]
        dict_values = [value for value in column_values if isinstance(value, dict)]

        return dict_values, len(dict_values)

    def get_list_from_dataframe_column(self, column_name):
        """ Get the list of values from a column in a dataframe

        Args:
            :param  column_name: Column name to get the list from

        Returns:
            :return: List of values from the column
        """
        self._load_dataframe_float()
        column_values = self.df[column_name].tolist()
        list_values = [value for value in column_values if isinstance(value, list)]

        return list_values, len(list_values)

    def get_list_of_dict_from_dataframe_column(self, column_name):
        """ Get the list of dictionaries from a column in a dataframe

        Args:
            :param  column_name: Column name to get the list of dictionaries from

        Returns:
            :return: List of dictionaries from the column
        """
        self._load_dataframe_float()
        column_values = self.df[column_name].tolist()
        list_of_dict_values = [value for value in column_values if isinstance(
            value, list) and all(isinstance(v, dict) for v in value)]
        return list_of_dict_values, len(list_of_dict_values)

    @log_begin_end_func_name
    def get_first_dict_value_from_dataframe_column(self, column_name):
        """ Get the first dictionary value from a column in a dataframe

        Args:
            :param  column_name: Column name to get the dictionary value from

        Returns:
            :return: First value as a dataframe from the column or None if not found
        """
        self._load_dataframe()
        dict_values, _ = self.get_dict_from_dataframe_column(column_name)
        return pd.DataFrame.from_dict(dict_values[0]) if dict_values else None

    @ensure_pandas_imported
    @log_begin_end_func_name
    def get_first_list_value_from_dataframe_column(self, column_name):
        """ Get the first list value from a column in a dataframe

        Args:
            :param  column_name: Column name to get the list value from

        Returns:
            :return: First value as a dataframe from the column or None if not found
        """
        self._load_dataframe()
        list_values, _ = self.get_list_from_dataframe_column(column_name)
        return pd.DataFramee(list_values[0]) if list_values else None

    @ensure_pandas_imported
    @log_begin_end_func_name
    def get_first_list_of_dict_value_from_dataframe_column(self, column_name):
        """ Get the first list of dictionaries value from a column in a dataframe

        Args:
            :param  column_name: Column name to get the list of dictionaries value from

        Returns:
            :return: First value as a dataframe from the column or None if not found
        """
        self._load_dataframe()
        list_of_dict_values, _ = self.get_list_of_dict_from_dataframe_column(column_name)
        return pd.DataFrame(list_of_dict_values[0]) if list_of_dict_values else None

    @log_begin_end_func_name
    def export_dataframe_to_csv(self, file_path, use_float=True,
                                path_to_json=None):
        """ Export the dataframe to a CSV file

        Args:
            file_path: The path to the CSV file to export the dataframe to
            use_float: Whether to use float values or not
            path_to_json: Optional path to the JSON file. If provided, it
                          will be used instead of self.jsonfile.
        """
        if path_to_json is not None:
            self.jsonfile = path_to_json
        self._load_dataframe_float() if use_float else self._load_dataframe()
        self.df.to_csv(file_path, index=False, header=True)

    @log_begin_end_func_name
    def export_dataframe_to_json(self, file_path, use_float=True,
                                 path_to_json=None):
        """ Export the dataframe to a JSON file

        Args:
            file_path: The path to the JSON file to export the dataframe to
            use_float: Whether to use float values or not
            path_to_json: Optional path to the JSON file. If provided, it
                          will be used instead of self.jsonfile.
        """
        if path_to_json is not None:
            self.jsonfile = path_to_json
        self._load_dataframe_float() if use_float else self._load_dataframe()
        self.df.to_json(file_path, orient='records', indent=4)

    @log_begin_end_func_name
    def export_specific_parameters(self, path_to_csv, parameters,
                                   common_parameters_filter=None,
                                   specific_parameters_filter=None, use_float=True,
                                   path_to_json=None):
        """
        Export the dataframe content to a CSV file for each event.parameter
        in parameters list. The file is saved in the same directory as the
        input JSON file.
        Export specific parameters of one or more events:
        manage a dynamic list of the concerned parameters [event_name_1.param_1
        , event_name_2.param_x, etc.] into a dataframe and related CSV file,
        but in such a way that the parameters are when possible correlated
        with each other based on common parameters values.

        Args:
            path_to_csv: The path to the CSV file to be created.
            parameters: The list of parameters to be exported. They are in the
                        format 'event_name.parameter' for the event specific
                        parameters. Common parameters name are the same.
            common_parameters_filter: a dict containing common parameters as
                                      keys and for values a list of accepted
                                      values or None. If None, they will be
                                      kept as they are.
            specific_parameters_filter: A dict of filters to apply to the
                         dataframe. The parameters names have to be
                         set without the event name as dict keys. The will be
                         filtered for all the dataframe events.
                         Values will be a list of accepted values, a dict, or
                         None. If None, they will be kept as they are.
                         if it is a dict, the value must be a list of values
                         to check in the dict key.
            path_to_json: Optional path to the JSON file. If provided, it will
                          be used instead of self.jsonfile.

        Returns:
            A dataframe containing the exported data.

        Example usage:
        # Assuming df is your DataFrame
        analysis = TtiAnalysis(df)
        analysis.export_specific_parameters('output.csv',
                                            ['event1.param1',
                                             'event2.param2'],
                                            {'common_param': ['value1']},
                                            {'param1': ['value2']})
        """

        if path_to_json is not None:
            self.jsonfile = path_to_json
        elif self.jsonfile is None:
            raise ValueError(
                "jsonfile path is required. Either pass path_to_json "
                "parameter or initialize TtiAnalysis with a jsonfile path."
            )

        self._load_dataframe_float() if use_float else self._load_dataframe()
        logging.info(f"Common Parameters Filter: {common_parameters_filter}")
        logging.info(f"Specific Parameters Filter: {specific_parameters_filter}")
        logging.info(f"Parameters: {parameters}")
        logging.info(f"DataFrame columns: {self.df.columns}")

        # Convert filter values to integers where applicable
        common_parameters_filter = convert_filter_values_to_int(common_parameters_filter)
        specific_parameters_filter = convert_filter_values_to_int(specific_parameters_filter)

        # Apply common parameters filter
        for param, values in common_parameters_filter.items():
            logging.info(f"Common Values: {values}")
            if param in self.df.columns:
                logging.info(f"Types of values to filter by {param}: {[type(value) for value in values]}")
                self.df = self.df[self.df[param].isin(values)]
            else:
                logging.error(f"Common parameter '{param}' not found in DataFrame columns")

        # Apply specific parameters filter
        if specific_parameters_filter:
            for param, values in specific_parameters_filter.items():
                if param not in self.df.columns:
                    logging.error(f"Specific parameter '{param}' not found in DataFrame columns")
                    continue
                if values is not None:
                    values = convert_filter_values_to_int(values)
                    if isinstance(values, dict):
                        key = next(iter(values))
                        logging.info(f"Specific Values: {values}, type: {type(values)}")
                        vals_to_check = list(values[key])

                        def check_row(row):
                            logging.info(f"Checking param {param} in row: {row}; Values to check: {vals_to_check}")
                            if isinstance(row, list):
                                result = any(d.get(key) in vals_to_check for d in row if isinstance(d, dict))
                            elif isinstance(row, dict):
                                result = row.get(key) in vals_to_check
                            else:
                                result = row in vals_to_check
                            logging.info(f"Result for row {row}: {result}")
                            return result

                        self.df = self.df[self.df[param].apply(check_row)]
                    else:
                        self.df = self.df[self.df[param].isin(values)]
        # Check if the parameters exist in the DataFrame columns
        for param in parameters:
            if param not in self.df.columns:
                logging.error(f"Parameter '{param}' not found in DataFrame columns")

        # Create the export DataFrame
        export_df = self.df[parameters]
        # Export the filtered DataFrame to CSV
        export_df.to_csv(path_to_csv, index=False)
        logging.info(f"Exporting DataFrame to CSV file: {path_to_csv}")

        return export_df
