import testsuite.Oulu.PERF.CommonKeywords.PythonKeywords.RTC_handler as rtc_handler
from unittest import TestCase


class TestRtcHandler(TestCase):

    def test_get_campaign_name_from_path(self):
        campaign = ("C:\\5G NR\\Test Mobile Application\\NLA4.51.2 Rev1\\"
                    "MyCampaigns\\Capacity_ASIK_UE_Amount.xml")
        name = rtc_handler.get_campaign_name_from_path(campaign)
        self.assertEqual(name, "Capacity_ASIK_UE_Amount")
