from taf.ul.oam.selenium_coam.pages.login_management import LogoutPage


def force_close_coam_webdriver():
    LogoutPage().close_browser()
