"""
        Keywords Purpose:
            Keywords to build ZIP used by pyairmosaic to launch scenario Prisma

        AUTHOR (I&V-1):
            Pascal Lecuyer          pascal.lecuyer@nokia.com
"""

import os.path
from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger

__version__ = '1.1.4'
__date__ = '11/05/2020'


class yamlPrisma(object):

    def generate_yaml_for_airmosaic(self, custom, yaml_filename, scenario_filename, config_name=''):
        """
        From parameters to define TL in dictionary 'custom' in __init__.py, generate yaml file. This yaml file is
        used to execute the airmosaic's Prisma via the prisma taf library.
        This keyword needs of following parameters from __init__.py:
          # Prisma TAF (yaml parameters)
          # LSU S1
          'prisma_S1_present': True,
          'prisma_S1_start_script': 'start_epc',
          'prisma_S1_init_script': 'init_epc',
          # LSU UU
          'prisma_UU_create_5G_cell': 'start_nr5g',
          'prisma_ppu_cell_5G': ['p0-2'],
          'prisma_ppu_cell_4G': 'p0-18',
          'prisma_ppu_rach': 'p0-5',
          # TSTM X2
          'prisma_tstm_X2_present': True,
          'prisma_tstm_X2_start_script': 'start_nr5g_X2',
          # TSTM UU
          'prisma_UU_start_script': 'start_nr5g_Uu_ms_gui',
          # AIRMOSAIC
          'prisma_cli_path': '/opt/Prisma/airmosaic_lteuu/bin/airmosaic_lteuu',
          'prisma_enable_amm': 'false',
          'prisma_clock_timer': '900',
          # ----------------
        :param custom:            Testsuite variable custom which is a dictionary containing the complemantary
                                  TL config from custom.yaml
        :param yaml_filename:     File name in yaml format whitch will contain Prisma configuration of this TL
        :param scenario_filename: File name prisma scenario
        :param config_name:       Configuration name in case of several possible configuration of Prisma
                                  as in case of carrier aggregation (multi CC)
        :return:
        """
        with open(yaml_filename, 'w') as f:
            if custom['prisma_S1_present']:
                # section: lsu_s1
                # ---------------
                f.writelines('lsu_s1:\n')
                f.writelines('    type: ue.prisma.lsu\n')
                f.writelines('    executor: tl.core.lsu_s1_ssh_connection_details\n')
                f.writelines('    script_paths:\n')
                f.writelines('        start_epc: ^cd /home/user/S1_script/; ./%s\n' % custom['prisma_S1_start_script'])
                f.writelines('        init_epc: cd /home/user/S1_script/; ./%s\n' % custom['prisma_S1_init_script'])
                f.writelines(
                    '        get_epc_log: cd /home/user/S1_config/epc_sim/log; tail -n 1000 -f ./epc.log._00\n')
                s1 = '        clean_epc_log: cd /home/user/S1_config/epc_sim/log;'
                s2 = ' cat /dev/null > ./epc.log._00'
                f.writelines(s1 + s2 + '\n')
                f.writelines(
                    '        stop_epc: pidin | egrep "bin/s1_tm" | awk \'{print $1}\' |xargs lsusuid kill -9\n')
                f.writelines('        start_lsu: lsustop;lsuclean;lsustart\n')
                f.writelines('        clean_lsu: lsuclean\n')
                f.writelines('        stop_lsu: lsustop\n')
                # section: tstm_s1
                # ----------------
                f.writelines('\n')
                f.writelines('tstm_s1:\n')
                f.writelines('    type: ue.prisma.tstm\n')
                f.writelines('    executor: tl.core.tstm_s1_ssh_connection_details\n')
                f.writelines('    script_paths:\n')
                s1 = '        start_tstm: cd /usr/local/S1_Tm-CI_QNX6.5_t7_C-qnx6_Sep17/bin/ ;'
                s2 = './s1_tm sched/MultiSchedule.tsm -r M -n 2 -c 1 -p 9001 -l ../log/epc.log -y 4 -m 1000'
                f.writelines(s1 + s2 + '\n')
                s1 = '        stop_tstm: echo '
                s2 = "`pidin|grep tm|grep -v 'grep'|awk '{print $1}'`|xargs -I {} kill -9 {}"
                f.writelines(s1 + s2 + '\n')
            # section: lsu_uu
            # ---------------
            f.writelines('\n')
            f.writelines('lsu_uu:\n')
            f.writelines('    type: ue.prisma.lsu\n')
            f.writelines('    executor: tl.ues[0].lsu_uu_ssh_connection_details\n')
            f.writelines('    script_paths:\n')
            # create_5g_cell management via custom['prisma_UU_create_5G_cell']
            if type(custom['prisma_UU_create_5G_cell']) is dict:
                if config_name == '':
                    f.writelines('        create_5g_cell: cd /home/user/lsu_scripts/; ./%s\n'
                                 % custom['prisma_UU_create_5G_cell']['DEFAULT'])
                else:
                    f.writelines('        create_5g_cell: cd /home/user/lsu_scripts/; ./%s\n'
                                 % custom['prisma_UU_create_5G_cell'][config_name])
            else:
                f.writelines('        create_5g_cell: cd /home/user/lsu_scripts/; ./%s\n'
                             % custom['prisma_UU_create_5G_cell'])
            # get_5g_cell_id management via custom['prisma_ppu_cell_5G']
            if type(custom['prisma_ppu_cell_5G']) is dict:
                if config_name == '':
                    ppu_list = custom['prisma_ppu_cell_5G']['DEFAULT']
                else:
                    ppu_list = custom['prisma_ppu_cell_5G'][config_name]
            else:
                ppu_list = custom['prisma_ppu_cell_5G']
            if len(ppu_list) > 1:
                i = 0
                for ppu in ppu_list:
                    f.writelines('        get_5g_cell_%d: trcinfo -%s | grep -i cellid\n' % (i, ppu))
                    i += 1
            else:
                f.writelines('        get_5g_cell_id: trcinfo -%s | grep -i cellid\n' % ppu_list[0])
            # --------------------------------------
            f.writelines('        get_4g_cell_id: trcinfo -%s | grep -i cellid\n' % custom['prisma_ppu_cell_4G'])
            f.writelines('        get_ra_status: trcinfo -%s | grep -i contention\n' % custom['prisma_ppu_rach'])
            f.writelines('        start_lsu: lsustop;lsuclean;lsustart\n')
            f.writelines('        clean_lsu: lsuclean\n')
            f.writelines('        stop_lsu: lsustop\n')
            if custom['prisma_tstm_X2_present']:
                # section: tstm_x2
                # ----------------
                f.writelines('\n')
                f.writelines('tstm_x2:\n')
                f.writelines('    type: ue.prisma.tstm\n')
                f.writelines('    executor: tl.enbs[0].tstm_x2_ssh_connection_details\n')
                f.writelines('    script_paths:\n')
                f.writelines(
                    '        start_tstm: ^cd /home/user/tstm_scripts/; ./%s >./nohup_tstmx2.out 2>&1 &\n' %
                    custom['prisma_tstm_X2_start_script'])
                f.writelines('        get_tstm_log: cd /home/user/tstm_scripts/; tail -n 3000 -f ./nohup_tstmx2.out\n')
                f.writelines(
                    '        clean_tstm_log: cd /home/user/tstm_scripts/; cat /dev/null > ./nohup_tstmx2.out\n')
                s1 = "        stop_tstm: pidin | grep enb_tm_server | grep -v 'grep' |"
                s2 = " awk '{print $1}' |xargs kill -9"
                f.writelines(s1 + s2 + '\n')
            # section: tstm_uu
            # ----------------
            f.writelines('\n')
            f.writelines('tstm_uu:\n')
            f.writelines('    type: ue.prisma.tstm\n')
            f.writelines('    executor: tl.ues[0].tstm_uu_ssh_connection_details\n')
            f.writelines('    script_paths:\n')
            f.writelines('        start_tstm: ^cd /home/user/tstm_scripts/ ; ./%s >./nohup_tstmuu.out 2>&1 &\n' %
                         custom['prisma_UU_start_script'])
            f.writelines('        get_tstm_log: cd /home/user/tstm_scripts/;tail -n 1000 -f ./nohup_tstmuu.out\n')
            f.writelines('        clean_tstm_log: cd /home/user/tstm_scripts/;cat /dev/null > ./nohup_uu.out\n')
            s1 = "        stop_tstm: pidin | grep lte_tm_server | grep -v 'grep' |"
            s2 = " awk '{print $1}' | xargs kill -9"
            f.writelines(s1 + s2 + '\n')
            # section: airmosaic
            # ------------------
            f.writelines('\n')
            f.writelines('airmosaic:\n')
            f.writelines('    type: ue.prisma.airmosaic\n')
            f.writelines('    executor: tl.ues[0].airmosaic_ssh_connection_details\n')
            f.writelines('    harness: tl.ues[0].airmosaic_harness_connection_details\n')
            f.writelines('    cygwin_path:\n')
            f.writelines('    cli_path: %s\n' % custom['prisma_cli_path'])
            f.writelines('    preferences_file_path:\n')
            f.writelines('    duration:\n')
            f.writelines('    suddenshutdown:\n')
            f.writelines('    bugreport_folder: /tmp/log\n')
            f.writelines('    script_paths:\n')
            f.writelines(
                '        start_mosaic: ^cd %s/; ./%s --nogui --nosplash -J-Dcli.mode=true --enable-harness\n' %
                (os.path.dirname(custom['prisma_cli_path']),
                 os.path.basename(custom['prisma_cli_path'])))
            f.writelines('    scenario_paths:\n')
            f.writelines('        attach: None\n')
            f.writelines('        detach: None\n')
            f.writelines('        start_traffic: %s\n' % scenario_filename)
            f.writelines('        stop_traffic: None\n')
            f.writelines('    parameters:\n')
            f.writelines('        enable_amm: %s\n' % custom['prisma_enable_amm'])
            f.writelines('        clock_timer: %s\n' % custom['prisma_clock_timer'])
            f.writelines('        counters:\n')
            f.writelines('        log_counters_to_file:\n')
            f.writelines('        global_vars:\n')
            # section: prisma
            # ---------------
            f.writelines('\n')
            f.writelines('prisma:\n')
            f.writelines('   type: ue.prisma\n')
            f.writelines('   components:\n')
            if custom['prisma_S1_present']:
                f.writelines('     - lsu_s1\n')
                f.writelines('     - tstm_s1\n')
            f.writelines('     - lsu_uu\n')
            if custom['prisma_tstm_X2_present']:
                f.writelines('     - tstm_x2\n')
            f.writelines('     - tstm_uu\n')
            f.writelines('     - airmosaic\n')

    def get_sid_filename(self, config_name=''):
        """
        Define the file name of Prisma sid file
        :param config_name: Configuration name in case of several possible configuration of Prisma
                            as in case of carrier aggregation (multi CC)
        :return:            File name of Prisma sid file
        """
        raw_value_of_sid_filename = BuiltIn().get_variable_value("${sid_file_name}")
        if raw_value_of_sid_filename is None:
            raw_value_of_sid_filename = BuiltIn().get_variable_value("${custom['sid_filename']}")
        if type(raw_value_of_sid_filename) is dict:
            if (config_name == '') or (config_name == '""'):
                return raw_value_of_sid_filename['DEFAULT']
            return raw_value_of_sid_filename[config_name]
        elif (type(raw_value_of_sid_filename) is str) or (type(raw_value_of_sid_filename) is unicode):
            return raw_value_of_sid_filename
        else:
            raise NameError("Test suite variables ${'sid_file_name'} and ${custom['sid_filename']} are not defined")
        return None
