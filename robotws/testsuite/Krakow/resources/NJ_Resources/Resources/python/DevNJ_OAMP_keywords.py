import time
from pprint import pprint
from robot.api import logger
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait as Wait
from collections import OrderedDict
from DevNJ_ASIR_Selenium import DevNJ_ASIR_Selenium
from selenium.common.exceptions import NoSuchElementException, TimeoutException, ElementClickInterceptedException


def bulk_add_prrh_to_full_configuration(outer_asir_sel=None, asir_webem_online=True, return_time_cost={}):
    """
    keyword bulk_add_prrh_to_full_configuration, to fill all empty ant port on all HUBMOD,
    using the 1st configured Ant Port pRRH as the template
    :param outer_asir_sel: DevNJ_ASIR_Selenium object, if None, will create a new one
    :param returned_time_cost: dictionary of time cost for each pRRH adding
    :return: None

    Examples:
    | ${asir_sel} | get_self |
    | bulk_add_prrh_to_full_configuration | outer_asir_sel=${asir_sel} |
    """

    asir_sel = outer_asir_sel
    if not asir_sel:
        asir_sel = DevNJ_ASIR_Selenium()
        asir_sel.clean_browser()
        asir_sel.login()
    if asir_webem_online:
        asir_sel.enter_config_man(overwrite=True)
    else:
        asir_sel.switch_to_dedicated_tab('pRRHs')

    logger.info('Get all pRRHs info', also_console=True)
    dict_all_prrhs_info = asir_sel.bulk_get_hubmod_prrh_info()
    pprint(dict_all_prrhs_info)
    logger.info('dict_all_prrhs_info={}'.format(dict_all_prrhs_info), also_console=True)

    dict_ant_port_head_and_team = OrderedDict()
    logger.info('Fill all blank prrhs on hubmods', also_console=True)
    for hubmod_id, prrh_info_list in dict_all_prrhs_info.items():
        logger.info('Fill blank prrhs on {}'.format(hubmod_id), also_console=True)
        ant_port_list_to_fill = []
        head_prrh_info = None
        for prrh_info in prrh_info_list:
            if not prrh_info['configure']:
                ant_port_list_to_fill.append(prrh_info['ant_port_id'])
            elif prrh_info.get('configure') and not head_prrh_info:
                head_prrh_info = prrh_info
        assert head_prrh_info is not None, '{} has no prrh configured'.format(hubmod_id)
        if not ant_port_list_to_fill:
            logger.info('{} has no empty ant port', also_console=True)
            continue

        dict_ant_port_head_and_team[hubmod_id] = {}
        dict_ant_port_head_and_team[hubmod_id][head_prrh_info['ant_port_id']] = []
        return_time_cost['hubmod_id'] = {}
        prrh_infos_to_fill = []
        for ant_port_id in ant_port_list_to_fill:
            prrh_info = head_prrh_info.copy()
            prrh_info['ant_port_id'] = ant_port_id
            prrh_infos_to_fill.append(prrh_info)
            dict_ant_port_head_and_team[hubmod_id][head_prrh_info['ant_port_id']].append(prrh_info['ant_port_id'])
        asir_sel.batch_add_prrhs_to_hub(hubmod_id.split('-')[-1], prrh_infos_to_fill)

    logger.info('Get all profiles info', also_console=True)
    dict_all_profiles_info = asir_sel.bulk_get_profile_info()
    pprint(dict_all_profiles_info)
    logger.info('dict_all_profiles_info={}'.format(dict_all_profiles_info), also_console=True)
    xpath_prrh_row = "//app-antenna-profile-assignment//tbody/tr"
    xpath_table_profile_id = "//div[@id='antenna-profile-list-content']//div[contains(@class,'profileId')]//span"
    xpath_div_spinner_container = "//div[@class='spinner-container']"
    xpath_div_scroll = "//cdk-virtual-scroll-viewport"
    div_scrolls = asir_sel.wd.find_elements(By.XPATH, xpath_div_scroll)
    if div_scrolls:
        logger.info("scroll {} to 0".format(xpath_div_scroll), also_console=True)
        asir_sel.wd.execute_script("arguments[0].scrollTop=0", div_scrolls[0])
        time.sleep(1)
    for profile_id, profile_info in dict_all_profiles_info.items():
        asir_sel.wd\
            .find_element(By.XPATH, xpath_table_profile_id + "[normalize-space(text())='{}']".format(profile_id))\
            .click()
        wait = Wait(asir_sel.wd, 1)
        try:
            loading_spinner = wait.until(
                EC.visibility_of_element_located((By.XPATH, xpath_div_spinner_container)))
        except TimeoutException:
            loading_spinner = None
        if loading_spinner:
            wait = Wait(asir_sel.wd, 10)
            wait.until(EC.invisibility_of_element_located((By.XPATH, xpath_div_spinner_container)))
        list_assigned_ant_port_id = [prrh['ant_port_id'] for prrh in profile_info.get('assigned_prrhs')]
        hubmod_id = profile_info.get('hubmod').split()[0].split('/')[-1]
        logger.info('profile-{} assigned ant ports:[{}]'.format(profile_id, ' '.join(list_assigned_ant_port_id)))
        dict_hubmod_ant_ports = dict_ant_port_head_and_team.get(hubmod_id)
        if not dict_hubmod_ant_ports:
            continue
        for head_ant_port, team_ant_ports in dict_ant_port_head_and_team.get(hubmod_id).items():
            if head_ant_port in list_assigned_ant_port_id:
                retry_times = 0
                while retry_times < 5:
                    try:
                        prrh_rows = asir_sel.wd.find_elements(By.XPATH, xpath_prrh_row)
                        for prrh_row in prrh_rows:
                            span_txt = prrh_row.find_element(By.XPATH,
                                                             ".//td//div[contains(@class,'portChain')]//span")
                            prrh_checkbox = prrh_row.find_element(By.XPATH, ".//td//input[@type='checkbox']")
                            prrh_checkbox_outer = prrh_row.find_element(By.XPATH,
                                                                        ".//td//mat-checkbox[@type='checkbox']")
                            prrh_checkbox_aria_checked = prrh_checkbox.get_attribute('aria-checked')
                            span_ant_port = span_txt.get_attribute("textContent").strip().split()[-1].split('-')[0]
                            wait = Wait(asir_sel.wd, 1)
                            try:
                                loading_spinner = wait.until(
                                    EC.visibility_of_element_located((By.XPATH, xpath_div_spinner_container)))
                            except TimeoutException:
                                loading_spinner = None
                            if loading_spinner:
                                wait = Wait(asir_sel.wd, 10)
                                wait.until(EC.invisibility_of_element_located((By.XPATH, xpath_div_spinner_container)))
                            if span_ant_port in team_ant_ports and prrh_checkbox_aria_checked.lower() != 'true':
                                prrh_checkbox_outer.click()
                        break
                    except Exception as e:
                        logger.info("assign team ant port retry times {}: {}".format(retry_times, str(e)))
                        retry_times += 1
                        if retry_times >= 3:
                            raise e
