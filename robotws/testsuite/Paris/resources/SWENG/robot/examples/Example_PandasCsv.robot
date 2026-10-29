*** Settings ***
Documentation
...
...            == Description ==
...            The method extract_cvs_files_forcolumn does the job splitting the TEXT column
...            The method generate_cvs_file_with_splitted_column is used to treat AIR TTI column content
...
...            It is mandatory to import the PandasCsv Library as shown here below giving the
...            File pathname as parameter; WITH NAME is just optional, "PandasCsv." prefix can be used instead
...
...            All the parameters of the method extract_cvs_files_forcolumn are optional. Here are the default values:
...            - select_columns="TIME,`SHERPA TTI`,`AIR TTI`,MSGID,TEXT"
...            - filter_column='TEXT'
...            - by_value='MSGID'
...            - list_grp=None
...            - filter='PrbPollingAllocationReport'
...            - csv_sep=None
...            select_columns parameter indicates the columns for the SELECT command issued on the source file
...            the filter_column parameter is the name of the colums to be extracted and saved in csv files (usually TEXT)
...            by_value indicated the column where values to generates different files are located (usually MSGID)
...            list_grp gives a list of values present in by_value column to obtain a partial generation
...            filter is used in WHERE LIKE part of the SELECT command to filter the content
...            csv_sep is the separator for the destination csv file
...
...            Calling the KW       Extract cvs files forcolumn     can be done without parameters if defaults are ok
...            If not, named parameters values described above have to be added after the KW,
...            example:     by_value='FOO'
...
...            All the parameters of the method generate_cvs_file_with_splitted_column are optional
...            - column_tosplit='AIR TTI'
...            - separator='.'
...            - new_names=['AIR TTI SFN', 'AIR TTI SLOT']
...            - csv_sep=None
...            column_tosplit parameter indicates the column to be splitted
...            separator gives the separator to split the column_tosplit column
...            new_names is the list of the column names for the new columns
...            csv_sep is the separator for the destination csv file

Library                             OperatingSystem
Library                             ../../python/PandasCsv.py     WITH NAME    Pandas_lib
Resource                            ../Tools.robot

*** Variables ***

${file_path}        testsuite/Paris/resources/SWENG/python/pytest/SherpaCsvFiles/micro__l1l2Trace.csv

*** Test Cases ***
Get Text Columns Content
    # Simply generates the files for available MSGIDs, see documentation above section for more details
    Pandas_lib.Setup Reader            ${file_path}
    ${saved_files}          Pandas_lib.Extract Cvs Files Forcolumn
    DatedLog                Extracted files:\n ${saved_files}

    # This part does the cleanup, files will NOT be there!!
    # Comment this FOR loop to check them, but remember to delete them after usage
    # and set this file as it was
    FOR    ${item}    IN    @{saved_files}
        Remove File                           ${item}
    END

Get Splitted Airtti File
    # Split AIR TTI column and generate a new file
    Pandas_lib.Setup Reader            ${file_path}
    ${saved_air_tti}                   Pandas_lib.Generate cvs File With Splitted Column
    Set Suite Variable                 ${saved_air_tti}
    DatedLog                           Generated files:\n ${saved_air_tti}

Apply both Operations on Content
    # Load the result of split AIR TTI to apply Text colum operation on it
    Pandas_lib.Setup Reader            ${saved_air_tti}    delimiter=,
    Pandas_lib.read sql df             select_stuff=SELECT TIME,`AIR TTI SFN`,`AIR TTI SLOT`,MSGID,TEXT FROM l1l2Traces
    ...                                where_stuff=WHERE MSGID LIKE '%PrbPollingAllocationReport%'
    ${saved_files}                     Pandas_lib.Extract Cvs Files Forcolumn
    ...                                select_columns=TIME,`AIR TTI SFN`,`AIR TTI SLOT`,MSGID,TEXT
    ...                                csv_sep=;
    Set Suite Variable                 ${saved_files}
    DatedLog                           Extracted files:\n ${saved_files}

Clean it Now
    # This part does the cleanup, file will NOT be there!!
    # Comment this part to check the files, the set it back and run again to clean up
    # Please *****  DO NOT commit  ***** generated files!!!
    FOR    ${item}    IN    @{saved_files}
        Remove File                           ${item}
    END
    Remove File             ${saved_air_tti}