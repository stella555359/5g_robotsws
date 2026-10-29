from lxml import etree as ET
import taf.sw.scout
import re
import logging
import subprocess as sp

parser = ET.XMLParser(encoding="utf-8")
log = logging.getLogger()


# Python file WIP


def check_counter_conditions(log_file, *conditions):
    logs = ET.parse(log_file)
    for condition in conditions:
        condition_left, condition_sign, condition_right = re.split('([=<>!]{1,})', condition)
        counter, counter_value = find_counter_value(logs, condition_left)
        log.info(f'counter value: {counter_value}')
        if condition_sign == '=':
            expression = counter_value + condition_sign + condition_sign + condition_right
        else:
            expression = counter_value + condition_sign + condition_right
        if eval(expression):
            log.info(f'expression passed, counter value: {counter_value}')
            log.info(condition)
        else:
            raise CounterValueNotExpected(counter, counter_value, condition_sign, condition_right)


def find_counter_value(logs, condition_left):
    counter, from_element = re.split('/', condition_left)
    element = logs.xpath(f'//PMMOResult[./*/{counter}]//ancestor::DN')[0].text.rsplit('/', 1)[0]
    counter_value = \
        logs.xpath(f'//PMMOResult[.//DN[starts-with(normalize-space(text()),"{element}/{from_element}")]]//{counter}')[
            0].text
    return counter, counter_value


class CounterValueNotExpected(Exception):
    def __init__(self, counter, counter_value, condition_sign, expected_value):
        self.counter = counter
        self.counter_value = counter_value
        self.condition_sign = condition_sign
        self.expected_value = expected_value

    def __str__(self):
        return f'Counter {self.counter} value: {self.counter_value} is not as expected: {self.condition_sign} ' \
               f'{self.expected_value}'


def mount_burak():
    create_burak_dir()
    # unmount_burak()

    log.info('create command')
    cmd1 = "sudo mount -t cifs -o noperm,auto,rw,vers=3.0,username=wro5gsiso,password=oZPS0POrRieRtu,"
    cmd = cmd1 + "domain=noklab,users,nounix "
    cmd = cmd + "//eseefsn50.emea.nsn-net.net/rotta4internal/5G_2/wroclaw/klein /home/ute/rotta/5G_2/wroclaw/klein"
    log.info('split command')
    cmd = cmd.split()
    log.info(cmd)
    log.info('start mount burak')
    try:
        sp.run(cmd, timeout=30)
        # log.info(stdout)
        # log.info(stderr)
    except sp.CalledProcessError as e:
        log.info(e)


def create_burak_dir():
    log.info("create burak if not exist")
    # os.system("mkdir /home/ute/burak")
    # result = os.system("ls /home/ute/burak1")
    try:
        log.info('ls burak')
        opt = sp.check_output(["find", "/home/ute/rotta/5G_2/wroclaw/klein"])  # , text=True)
        log.info(f'ls return: {opt}')
        mounted = sp.check_output(["findmnt", "-o", "SOURCE", "/home/ute/rotta/5G_2/wroclaw/klein"])
        log.info(f'is mounted" {mounted}')

    except sp.CalledProcessError as e:
        log.info(e)
        log.info('create burak dir exception')
        sp.run(["mkdir", "-p", "/home/ute/rotta/5G_2/wroclaw/klein"])
    finally:
        log.info('burak created')
