# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn
from tabulate import tabulate
import os

rbi = BuiltIn()


""" Helper Common Function for Pandas """


def display_df_as_html(df, log_level='TRACE'):
    """ This function transforms the data frame into an HTML table

        :param df: Pandas dataframe
        :param log_level: What log level to show the data frame
    """

    def highlight_row(row):
        if any(float(val) >= 1 for val in row if
               isinstance(val, (int, float, str)) and str(val).replace('.', '', 1).isdigit()):
            return ['background-color: yellow'] * len(row)
        return [''] * len(row)

    df_style = df.style.set_properties(**{'border-left': '1px solid green',
                                          'border-top': '1px solid green',
                                          'color': 'black'})
    # Apply the highlight function to each row
    df_style = df_style.apply(highlight_row, axis=1)
    html_formatted_df = df_style.to_html()
    rbi.log(html_formatted_df, log_level, html=True)


def normalize_sfn_values(df):
    """ SFN rolls over at 1023 to 0 instead continue the SFN count i.e. 1024, 1025 etc.
        This makes each SFN unique and can be grouped for analysis

        :param df: Pandas dataframe
    """

    df['normalized_sfn'] = (df['sfn'] + df['sfn'].diff().lt(0).cumsum() * 1024).astype(int)
    return df


def display_df_as_table(df, log_level='TRACE', headers='keys', base_location="", filename="", both=False,
                        title="", postfix="", w_console=False):
    """ This function transforms the data frame into a table

        :param df: Pandas dataframe
        :param log_level: What log level to show the data frame
        :param headers: tabulate headers
        :param base_location:
        :param filename:
        :param both:
        :param title:
        :param postfix:
        :param w_console:
    """
    if not title:
        title = 'display_df_as_table'
    if not filename:
        filename = "/" +\
                   title.replace(" ", "_") + ("_%s.txt" %
                                              postfix if postfix else ".txt")
    # Create the directory if it doesn't exist
    if base_location:
        rbi.log("base_location OK", log_level, console=w_console)
        os.makedirs(base_location, exist_ok=True)

    table_formatted_df_str = tabulate(df, headers=headers, tablefmt='psql')
    lines = len(table_formatted_df_str.split('\n'))
    if base_location:
        file_path = base_location + '/' + filename
        rbi.log('Instrum: base_location={} both={}'.format(base_location, both), 'INFO', console=w_console)
    if lines < 40:
        rbi.log(table_formatted_df_str, log_level, console=True)
        if base_location and both:
            try:
                with open(file_path, 'a') as f:
                    f.write(table_formatted_df_str)
                rbi.log("File write successful", log_level, console=w_console)
            except Exception as e:
                rbi.log(f"File write failed: {e}", log_level, console=True)
    else:
        if base_location:
            try:
                with open(file_path, 'a') as f:
                    f.write(table_formatted_df_str)
                rbi.log("File write successful", log_level, console=True)
            except Exception as e:
                rbi.log(f"File write failed: {e}", log_level, console=True)
        else:
            rbi.log(table_formatted_df_str, log_level, console=True)


def save_df_as_html(df, base_location="", title="", postfix=""):
    """ This function transforms the data frame into an HTML table

        :param df: Pandas dataframe
        :param base_location:
        :param title:
        :param postfix:
    """
    if not title:
        title = 'save_df_as_html'
    file_name = "/" + \
                title.replace(" ", "_") + ("_%s.html" %
                                           postfix if postfix else ".html")
    # Create the directory if it doesn't exist
    os.makedirs(base_location, exist_ok=True)

    # Construct the full file path
    full_file_path = os.path.join(base_location, file_name)

    try:
        def highlight_non_zero(val):
            color = 'yellow' if val != 0 else ''
            return f'background-color: {color}'

        def highlight_greater_than_one(val):
            try:
                if float(val) >= 1.0:
                    return 'background-color: yellow'
            except ValueError:
                pass
            return ''

        def highlight_row(row):
            if any(float(val) >= 1 for val in row if
                   isinstance(val, (int, float, str)) and str(val).replace('.', '', 1).isdigit()):
                return ['background-color: yellow'] * len(row)
            return [''] * len(row)

        # df_style = df.style.map(highlight_greater_than_one).set_properties(**{'border-left': '1px solid green',
        #                                                                       'border-top': '1px solid green',
        #                                                                       'color': 'black'})
        df = df.fillna('')
        df_style = df.style.set_properties(**{'border-left': '1px solid green',
                                              'border-top': '1px solid green',
                                              'color': 'black'})
        # Apply the highlight function to each row
        df_style = df_style.apply(highlight_row, axis=1)
        # Open the file for writing (create if it doesn't exist)
        # Convert DataFrame to HTML with scientific notation
        with open(base_location + file_name, 'w') as f:
            # df_style.data.to_html(f, na_rep='', float_format='{:.5e}'.format)
            df_style.data.to_html(f, na_rep='')
    except PermissionError as e:
        print(f"Error saving file: {e}")
        print(f"base_location: {base_location}")
        print(f"file_name: {file_name}")
        print(f"full_file_path: {full_file_path}")
        print("Check file permissions and ensure you have write access.")
