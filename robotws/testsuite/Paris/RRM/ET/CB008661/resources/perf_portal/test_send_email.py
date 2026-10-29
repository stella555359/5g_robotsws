import smtplib
import unittest
from unittest.mock import patch

import send_email


class TestSendEmail(unittest.TestCase):
    def setUp(self):
        self.email = "christophe.sauge@nokia.com"
        self.subject = "My subject"
        self.body = "My message body<br/>On different lines"
        self.mock_stdout = patch("sys.stdout.write").start()
        self.mock_smtp = patch("smtplib.SMTP", autospec=True).start().return_value
        self.addCleanup(patch.stopall)

    def test_given_text_when_sends_email_then_email_is_sent_with_message(self):
        send_email.Email().send(self.email, self.subject, self.body)

        message = self.mock_smtp.send_message.call_args[0][0]
        self.assertEqual(self.subject, message["Subject"])
        self.assertEqual(self.email, message["From"])
        self.assertEqual(self.email, message["To"])
        parts = list(message.walk())
        self.assertEqual(len(parts), 2)
        part = parts.pop(0)
        self.assertEqual("multipart/mixed", part.get_content_type())
        part = parts.pop(0)
        self.assertEqual("text/html", part.get_content_type())
        self.assertEqual(self.body, part.get_payload())
        self.assertIsNone(part.get_filename())
        self.mock_stdout.assert_not_called()

    def test_given_text_and_attach_when_sends_email_then_email_is_sent_with_message_and_attachement(
        self,
    ):
        send_email.Email().send(self.email, self.subject, self.body, __file__)

        message = self.mock_smtp.send_message.call_args[0][0]
        self.assertEqual(self.subject, message["Subject"])
        self.assertEqual(self.email, message["From"])
        self.assertEqual(self.email, message["To"])
        parts = list(message.walk())
        self.assertEqual(len(parts), 3)
        part = parts.pop(0)
        self.assertEqual("multipart/mixed", part.get_content_type())
        part = parts.pop(0)
        self.assertEqual("text/html", part.get_content_type())
        self.assertEqual(self.body, part.get_payload())
        self.assertIsNone(part.get_filename())
        part = parts.pop(0)
        self.assertEqual("text/plain", part.get_content_type())
        self.assertEqual(__file__, part.get_filename())
        self.mock_stdout.assert_not_called()

    def test_given_not_valid_email_when_sends_email_then_smtplib_raises_exception(self):
        with self.assertRaises(smtplib.SMTPRecipientsRefused):
            email = "dummy"
            self.mock_smtp.send_message.side_effect = smtplib.SMTPRecipientsRefused(email)
            send_email.Email().send(email, self.subject, self.body)
        self.mock_stdout.assert_not_called()

    def test_long_text_when_sends_email_then_email_is_sent_with_br_and_ret_message(self):
        digits = "1234567890"
        longbody = (digits * 40 + "\n") * 4
        expected_body = (digits * 40 + "<br/>\n") * 4

        send_email.Email().send(self.email, self.subject, longbody)

        message = self.mock_smtp.send_message.call_args[0][0]
        self.assertEqual(self.subject, message["Subject"])
        self.assertEqual(self.email, message["From"])
        self.assertEqual(self.email, message["To"])
        parts = list(message.walk())
        self.assertEqual(len(parts), 2)
        part = parts.pop(0)
        self.assertEqual("multipart/mixed", part.get_content_type())
        part = parts.pop(0)
        self.assertEqual("text/html", part.get_content_type())
        self.assertEqual(expected_body, part.get_payload())
        self.assertIsNone(part.get_filename())
        self.mock_stdout.assert_not_called()
