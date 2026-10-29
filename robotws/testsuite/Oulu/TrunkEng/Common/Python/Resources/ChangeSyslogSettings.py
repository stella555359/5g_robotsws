"""
:author:  Terhi Talvitie
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
"""
import configparser
import os
from traceback import format_exception
from robot.libraries.BuiltIn import BuiltIn

# config_file_path = '/home/ute/btslog2/btslog.ini'
# Original syslog path values in /home/ute/btslog2/btslog.ini are:
# {
#     "CONFIGURATION": {"TemporaryDir": "/tmp/btslog2"},
#     "EXECUTION_LOG": {"LogFileTemplate": "/tmp/btslog2/executionlog%1.txt"},
#     "LOG_CONFIGURATION": {"TraceFileTemplate": "/tmp/btslog2/BTSLOG_TRACE_%1.bin",
#                           "SysLogFileTemplate": "/tmp/btslog2/SYSLOG_%1.LOG"},
#     "RAW_DATA": {"LogFileTemplate": "/tmp/btslog2/raw_data%1.txt"},
#     "ARCHIVING": {"ArchiveName": "/tmp/btslog2/BTSLogZip_%1.zip"}
# }


def change_syslog_file_path(new_path="", config_file_path="/home/ute/btslog2/btslog.ini"):
    """
    Change syslog file path in the configuration file. Path will be changed in /home/ute/btslog2/btslog.ini file.

    This function reads the existing configuration file, updates the syslog file path to the new path provided,
    and writes the changes back to the configuration file. Affected paths in the configuration file are:
    - CONFIGURATION -> TemporaryDir
    - EXECUTION_LOG -> LogFileTemplate
    - LOG_CONFIGURATION -> SysLogFileTemplate
                        -> TraceFileTemplate
    - RAW_DATA -> LogFileTemplate
    - ARCHIVING -> ArchiveName

    :param str new_path: New syslog file path to be set. Can also be empty if path is given as suite variable
                         SYSLOG_FILE_PATH.
    :param str config_file_path: Path to the btslog configuration file. Default is '/home/ute/btslog2/btslog.ini'.
    :raise Exception: If there is an error reading or writing the configuration file.
    """
    try:
        if not new_path:
            new_path = BuiltIn().get_variable_value("${SYSLOG_FILE_PATH}", default="")
            if not new_path:
                print("New syslog file path is not provided as argument or suite variable SYSLOG_FILE_PATH. No changes"
                      " will be made.")
                return None
            print(f"Changing syslog file path to: {new_path}")
        if not os.path.isdir(new_path):
            os.makedirs(new_path, exist_ok=True)
            print(f"Created syslog directory at: {new_path}")
        syslog_path_config_param_value = {
            "CONFIGURATION": {"TemporaryDir": new_path},
            "EXECUTION_LOG": {"LogFileTemplate": f"{new_path}/executionlog%1.txt", "MaxIndex": "300"},
            "LOG_CONFIGURATION": {"TraceFileTemplate": f"{new_path}/BTSLOG_TRACE_%1.bin",
                                  "SysLogFileTemplate": f"{new_path}/SYSLOG_%1.LOG",
                                  "MaxIndex": "300"},
            "RAW_DATA": {"LogFileTemplate": f"{new_path}/raw_data%1.txt", "MaxIndex": "300"},
            "ARCHIVING": {"ArchiveName": f"{new_path}/BTSLogZip_%1.zip"}
        }
        ok = change_settings_of_btslog(syslog_path_config_param_value, config_file_path=config_file_path)
        if ok:
            print("Syslog file path change completed.")
            return new_path
        else:
            print("Syslog file path change was not completed.")
            return None
    except Exception as e:
        print(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
        raise Exception(f"Failed to change syslog file path: {e.__class__.__name__}:{e}")


def change_settings_of_btslog(configuration_parameter_value, config_file_path='/home/ute/btslog2/btslog.ini'):
    """
    Change settings of btslog in the configuration file.
    This function reads the existing configuration file, updates the settings provided in the dictionary,
    and writes the changes back to the configuration file. Affected settings in the configuration file are specified
    in the input dictionary.

    :param dict configuration_parameter_value: Dictionary containing configuration sections as keys and another
                                               dictionary as values. The inner dictionary contains parameter names as
                                               keys and their corresponding new values.
    :param str config_file_path: Path to the btslog configuration file. Default is '/home/ute/btslog2/btslog.ini'.

    Parameter configuration_parameter_value can have E.g. content:
    {
    "LOG_CONFIGURATION": {'MaxTraceFileSize': '20',
                          'MaxSysLogFileSize': '100',
                          'MaxIndex': '300'}
    }
    :raise Exception: If there is an error reading or writing the configuration file.
    """
    config = configparser.ConfigParser(strict=False, delimiters=('=',), interpolation=None)
    config.optionxform = str  # preserve case
    if not os.path.isfile(config_file_path):
        print(f"Configuration file '{config_file_path}' does not exist. No changes will be made.")
        return False
    try:
        with open(config_file_path, encoding='utf-8') as f:
            config.read_file(f)
        for section in config.sections():
            for key, value in config.items(section):
                if (section.strip() in configuration_parameter_value and
                        key.strip() in configuration_parameter_value[section.strip()]):
                    config[section.strip()][key.strip()] = configuration_parameter_value[section.strip()][key.strip()]
                    print(f"Current '{section}':'{key}'='{value}' will be updated to "
                          f"'{configuration_parameter_value[section.strip()][key.strip()]}'.")
                else:
                    config[section.strip()][key.strip()] = value.strip()
        with open(config_file_path, 'w', encoding='utf-8') as ff:
            config.write(ff)
        print(f"BtsLog settings change completed.")
        print(f"Removing extra whitespaces around '=' in the config file '{config_file_path}'.")
        with open(config_file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        content = content.replace(' = ', '=')
        with open(config_file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        return True
    except Exception as e:
        print(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
        raise Exception(f"Failed to change btslog settings: {e.__class__.__name__}:{e}")
