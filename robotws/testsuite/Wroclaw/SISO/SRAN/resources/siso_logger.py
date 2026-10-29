"""
:copyright: Nokia
:author: mateusz.kawka@nokia.com
:maintainer: mateusz.kawka@nokia.com
:modified: 13.05.2024

This module provides a logging function with timestamp for Robot Framework.

The `logging_with_timestamp` function allows logging messages with a timestamp,
and optionally with color-coded output and frame.
It supports logging to Robot Framework's log file, console, and HTML log. Additionally,
it can append the logs to a specified directory and output file.

Usage:
    logging_with_timestamp(message, message_2=None, level='INFO', html=False, console=True, frame=None,
                           style='', logs_dir=None, output_file='terminal_output')

Parameters:
    - message (str, list, dict): The message to be logged.
                                 If a dictionary or list is provided, it will be formatted for better readability.
    - message_2 (str, list, dict): An additional message to be logged. Defaults to None.
                                 If a dictionary or list is provided, it will be formatted for better readability.
    - level (str): The log level (default: 'INFO'). Supported levels: 'INFO', 'DEBUG', 'WARN', 'ERROR', and 'FAIL'.
    - html (bool): If True, log messages will be included in the HTML log (default: False).
    - console (bool): If True, log messages will be printed to the console (default: True).
    - frame (bool): If True, a frame will be added around the message. The frame style depends on the style parameter.
    - style (str): A style tag to apply color-coding to the log message.
                   Supported styles are 'PASS', 'DONE', 'WARNING', 'ONGOING', 'FAIL', 'ERROR', 'TC' and 'STEP'.
    - logs_dir (str): Custom directory path to store log files. If None, the default suite logs directory will be used.
    - output_file (str): The name of the output file with extension to which the log will be written.
                         Defaults to 'terminal_output.txt'.

Color Styles:
    - 'PASS':    Green color for successful actions.
    - 'DONE':    Green color for completed actions.
    - 'WARNING': Yellow color for warning messages.
    - 'ONGOING': Magenta color for ongoing actions.
    - 'FAIL':    Red color for failed actions.
    - 'ERROR':   Red color for erroneous actions.
    - 'STEP':    Cyan color for steps name.
    - 'TC':      Cyan color for test case name.

Frame Styles:
    - If the style is not 'TC', the frame style will be 'rounded_grid'.
      ╭───────────────────────╮
      │                       │
      ╰───────────────────────╯
    - If the style is 'TC', the frame style will be 'double_grid'.
      ╔═══════════════════════╗
      ║                       ║
      ╚═══════════════════════╝

Raises:
    ValueError: If the specified log level is not supported.

Functions:
    - _get_color_for_style(style, color_dict): Internal func. to determine color based on the style value.
    - _prepare_message_with_frame(title, frame_style='rounded_grid'): Internal func. to prepare a message with a frame.

Examples - Python:
    logging_with_timestamp("This is an INFO message.")
    logging_with_timestamp("This is a WARNING message.", level='WARN', style='WARNING', html=True)
    logging_with_timestamp({"key": "value"}, style='FAIL', logs_dir='/custom/logs/directory')
    logging_with_timestamp("This is a message with a frame.", frame=True)

Examples - Robot Framework:
    Logging With Timestamp  message=This is an info message
    Logging With Timestamp  message=Printing dictionary below:  message_2=${my_dictionary}
    Logging With Timestamp  message=${my_list}
    Logging With Timestamp  message=This is a warning message  message_2=ACHTUNG!  level=WARN
    Logging With Timestamp  message=TC Passed  style=PASS
    Logging With Timestamp  message=Step1. Preconditions  style=STEP  logs_dir=/home/ute/logs
    Logging With Timestamp  message=This is a message with a frame  frame=True  style=TC
"""
from robot.api import logger
from datetime import datetime
from robot.libraries.BuiltIn import BuiltIn
from robot.api.deco import keyword
from tabulate import tabulate


@keyword(name="Logging With Timestamp")
def logging_with_timestamp(message, message_2=None, level='INFO', html=False, console=True, style='',
                           frame=None, logs_dir=None, output_file='terminal_output.txt'):
    """
    Logs a message with a timestamp and optional color-coding and frame to the Robot Framework log.
    """

    color_dict = {'\033[31m': ['FAIL', 'ERROR'],        # red
                  '\033[32m': ['PASS', 'DONE'],         # green
                  '\033[33m': ['WARNING'],              # yellow
                  '\033[35m': ['ONGOING'],              # magenta
                  '\033[36m': ['STEP', 'TC']}           # cyan
    reset_color = '\033[0m'                             # color reset

    color = _get_color_for_style(style, color_dict)

    if frame:
        frame_style = 'rounded_grid' if style != 'TC' else 'double_grid'
        message = f"\n{_prepare_message_with_frame(message, frame_style=frame_style)}"

    if isinstance(message, dict):
        message = '\n'.join([f"{key}: {value}" for key, value in message.items()])
        message = f"\n{message}"
    elif isinstance(message, list):
        message = ", ".join(map(str, message))

    if message_2 is not None:
        if isinstance(message_2, dict):
            message_2 = '\n'.join([f"{key}: {value}" for key, value in message_2.items()])
            message_2 = f"\n{message_2}"
        elif isinstance(message_2, list):
            message_2 = ", ".join(map(str, message_2))
            message_2 = f"\n{message_2}"
        else:
            message_2 = f"\n{message_2}"
    else:
        message_2 = ''

    current_time = datetime.now().time().strftime("%H:%M:%S.%f")[:-3]

    log_level = level.lower()
    if hasattr(logger, log_level):
        log = getattr(logger, log_level)
        if log_level == 'info':
            if color is not None:
                log(f'[{current_time}] {color}[{style}] '
                    f'{message}{message_2}{reset_color}', also_console=console, html=html)
            else:
                log(f'[{current_time}] {message}{message_2}', also_console=console, html=html)
        else:
            log(f'[{current_time}] {message}{message_2}', html=html)
    else:
        raise ValueError(f"Log level: {level} not supported")

    terminal_output_path = BuiltIn().get_variable_value("${SUITE_LOGS_DIR_PATH}") if logs_dir is None else logs_dir

    if terminal_output_path is not None:
        result_path = f'{terminal_output_path}/{output_file}'
        with open(result_path, 'a') as file:
            if style == '':
                file.write(f"[{current_time}] {message}{message_2}\n")
            else:
                file.write(f"[{current_time}] [{style}] {message}{message_2}\n")


def _get_color_for_style(style, color_dict):
    """
    Determines the color based on the style value.

    Args:
        style (str): The style value.
        color_dict (dict): Dictionary mapping color codes to style values.

    Returns:
        str: The color code associated with the style, or None if not found.
    """
    for color, values in color_dict.items():
        if style in values:
            return color
    return None


def _prepare_message_with_frame(title, frame_style='rounded_grid'):
    """
    This function prepares a message with a frame.

    Args:
        title (str): The title to be displayed in the frame.
        frame_style (str, optional): The style of the frame. Defaults to 'rounded_grid'.

    Returns:
        str: The title formatted with the specified frame style.
    """
    title_list = [[title]]
    return tabulate(title_list, headers="", tablefmt=frame_style)
