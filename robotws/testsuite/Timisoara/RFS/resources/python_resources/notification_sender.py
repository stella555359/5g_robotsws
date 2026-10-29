import os
import subprocess
import json
from robot.libraries.BuiltIn import BuiltIn
from taf.ul.sc.perf.messenger.messenger import Messenger, Message


def _send_teams_channel_notification(cm_execution_id=None):
    try:
        command = r'echo "put /opt/ute/execution.context.json %s.json"' % cm_execution_id \
              + r' | cadaver http://webdav.ute.nsn-rdnet.net/tmp/stop_and_fix/'
        if cm_execution_id is not None:
            subprocess.call(command, shell=True)
        else:
            BuiltIn().log_to_console("Teams channel notification could not be sent!"
                                     "CM_EXECUTION_ID variable not available.\nEntering stop&fix anyway")
    except Exception as e:
        BuiltIn().log_to_console("Teams channel notification could not be sent! {}\nEntering stop&fix anyway".format(e))


def _send_email_notification(receivers='i_mn_ran_vrf_rfs_all@internal.nsn.com',
                             sender='i_btsauto_dev_tsr@internal.nsn.com', cc=None, files=None, execution_link='NA',
                             tl_execution_owner='NA'):
    testline = BuiltIn().get_variable_value('${TESTLINE_NAME}', 'NA')
    test_case = BuiltIn().get_variable_value("${TEST_NAME}", "NA")
    suite_name = BuiltIn().get_variable_value("${SUITE SOURCE}", "NA")
    cc = sender if not cc else cc
    subject = "[Action Required] Potential Truck Roll"
    msg_content = r"""
    <html>
    <body>
    <p>Hi,</p>
    <p>Please ignore this notification if it refers to TA team testlines used for script validation: MTNRL23, MTNRL43,
    MTNRL44, MTNRL76, MTNRL81, MTNRL82</p>
    <p>Potential Truck Roll was detected. If you or your team member are owners of testline please check execution:</p>
    <ul>
      <li>TEST_SUITE: {}</li>
      <li>TEST_NAME: {}</li>
      <li>TESTLINE: {}</li>
      <li>TESTLINE_EXECUTION_OWNER: {}</li>""".format(suite_name, test_case, testline, tl_execution_owner)

    if execution_link != 'NA':
        msg_content = msg_content + "<li>EXECUTION: {}</li>".format(execution_link)
    msg_content = msg_content + "</ul>"
    if execution_link != 'NA':
        msg_content = msg_content + "Please set TestLine in maintenance mode ASAP <br>"
    msg_content = msg_content + """More details about next steps in Stop&Fix implementation in RFSharing Tribe
    under <a href='https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1496385553'>link</a>
    <p>Regards,<br> TA Team </p>
    </body>
    </html>
    """

    message = Message(
        From=sender,
        To=receivers,
        CC=cc,
        Subject=subject,
        Html=msg_content,
        Body=None,
        attachments=files,
        charset="utf-8")

    try:
        Messenger.send_message(message)
    except Exception as e:
        BuiltIn().log_to_console("Email could not be sent! {} \nEntering stop&fix anyway".format(e))


def send_stop_and_fix_notification():
    cm_run_env = BuiltIn().get_variable_value('${CM_RUN_ENV}', 'NA')
    if cm_run_env in ['NA', False]:
        BuiltIn().log_to_console("Teams channel notification will not be sent, execution was not performed "
                                 "from Cloud Manager")
        BuiltIn().log_to_console("Trying to send email notification due to potential Truck Roll detection")
        jenkins_execution_link = os.environ.get('BUILD_URL', 'NA')
        tl_execution_owner = os.environ.get('BUILD_USER_EMAIL', 'NA')
        _send_email_notification(execution_link=jenkins_execution_link, tl_execution_owner=tl_execution_owner)
    else:
        with open('/opt/ute/execution.context.json') as json_file:
            result = json.load(json_file)
            cm_execution_id = result['CM_EXECUTION_ID']
            cm_execution_link = result['CM_EXECUTION_LINK']
            tl_execution_owner = result['CM_USERNAME']
            BuiltIn().log_to_console("Trying to send teams channel notification due to potential Truck Roll detection")
            _send_teams_channel_notification(cm_execution_id=cm_execution_id)
            BuiltIn().log_to_console("Trying to send email notification due to potential Truck Roll detection")
            _send_email_notification(execution_link=cm_execution_link, tl_execution_owner=tl_execution_owner)
