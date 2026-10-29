import taf.rfrl.csv4all.resources.notifications.notifications as notification
from robot.libraries.BuiltIn import BuiltIn


def send_suite_summary_email() -> None:
    """
    Sends an email to a list of recipients. The email contains the overall testsuite result and details about
    the performed test cases and their results.
    """
    suite_status = BuiltIn().get_variable_value("${SUITE_STATUS}")
    test_cases = BuiltIn().get_variable_value("@{TEST_CASES}")
    test_results = BuiltIn().get_variable_value("@{TEST_RESULTS}")
    test_info = BuiltIn().get_variable_value("@{TEST_INFO}")
    email_recipients = BuiltIn().get_variable_value("${EMAIL_RECIPIENTS}")
    suite_name = BuiltIn().get_variable_value("${SUITE_NAME}")
    hostname = BuiltIn().get_variable_value("${HOSTNAME}")
    details = '<br><br>'
    status = f'Overall result of the suite: <font color="{_set_color(suite_status)}">{suite_status}</font>'
    for index in range(1, len(test_cases)):
        details = details + '<br>--------------------------------------------------------------------------------<br>' \
                  + f'{test_cases[index]}: <font color="{_set_color(test_results[index])}">{test_results[index]}' \
                    f'</font>' + (f'<br>Test fail message: {test_info[index]}<br>Have a fruitful analysis!'
                                  if test_results[index] == 'FAIL' else '')
    body = f'{status} {details}'
    mailer = notification.Notifications(email_recipients)
    mailer.send_email(subject=f'{suite_name.upper()} testsuite ENDED on {hostname}', body=body)


def _set_color(result: str) -> str:
    """
    Sets the font color for test result string for html formatting
    :param result: test execution result passed from robot global variable
    :return: html fonc color setting
    """
    return 'green' if result == 'PASS' else 'red'


def add_data_to_testsuite_summary() -> None:
    """
    Fills robot global variables with info about performed tests and their execution results
    """
    BuiltIn().get_variable_value("${TEST_CASES}").append(BuiltIn().get_variable_value("${TEST_NAME}"))
    BuiltIn().get_variable_value("${TEST_RESULTS}").append(BuiltIn().get_variable_value("${TEST_STATUS}"))
    BuiltIn().get_variable_value("${TEST_INFO}").append(BuiltIn().get_variable_value("${TEST_MESSAGE}"))
