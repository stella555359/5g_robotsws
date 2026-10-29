from taf.internal.aashell.factory import AaShellFactory
import time
import re
from deepdiff import DeepDiff


def start_testcase():
    global ram, rom, alloc_details
    aashell = AaShellFactory().create_aashell()
    aashell.setup()
    mm = aashell.execute(b"sysinfo -s")
    mm = str(mm).split(";")
    ram = int((re.findall(r'\d+', mm[3]))[0])
    rom = int((re.findall(r'\d+', mm[4]))[0])
    # print(ram,rom,"a2222")
    proca = str(aashell.execute(b"proc"))
    procs = str(proca.split("\n"))
    procs = procs.split("\\n")
    alloc_details = {}
    for item in procs:
        # print(item,"sssss")
        item = str.encode(item)
        alloc = aashell.execute(b"sysinfo -p "+item)
        # print(item,"-----",alloc)
        alloc = alloc.split(b";")
        item = str(item)
        item = item.split("\\")
        alloc_details[item[0]] = alloc[9]
    # aashell.execute(b"log -a -z aashell.zip", timeout=60)
    time.sleep(10)
    # print(alloc_details)
    aashell.teardown()
    # print(ram, rom,type(alloc_details),alloc_details)
    return ram, rom, alloc_details


def stop_testcase():
    ram2, rom2, alloc2 = start_testcase()
    diff = DeepDiff(alloc_details, alloc2)
    ramdiff = ram2-ram
    romdiff = rom2-rom
    return ramdiff, romdiff, diff


if __name__ == "__main__":
    print("####### Testcase Start ######")
    kl, kk, alloc = start_testcase()
    time.sleep(10)
    print("####### Testcase End ######")
    ab, cd, rf = stop_testcase()
    print(ab, cd, rf)
