import time
import os
import robot
import shutil
import pip
import glob


def launcher(feature, core, gnodeb, ue, nbLoop, excludedTags):
    while nbLoop > 0:
        nbLoop -= 1

        print(
            "\nWill launch campaign %s with excluded tags: " %
            (feature), excludedTags)
        time.sleep(3)
        datetimef = time.strftime("%Y-%m-%d-%Hh%Mm%Ss")
        tracedir = "/home/ute/traces/Cockpit/"
        outdir = tracedir + feature + "-" + datetimef + "/"
        curlog = tracedir + "robot.log"
        campaign = "Robot/" + feature + "/" + feature + ".robot"
        try:
            os.makedirs(outdir)
        except OSError:
            pass

        robot.run(
            campaign,
            outputdir=outdir,
            debugfile=curlog,
            variable=(
                "CAMPAIGN_NAME:" +
                feature +
                "-" +
                datetimef,
                "CORE:" +
                core,
                "GNODEB:" +
                gnodeb,
                "UE:" +
                ue),
            exclude=excludedTags)

        shutil.copyfile(campaign, outdir + feature + ".robot")
        shutil.copyfile(curlog, outdir + "robot.log")
        shutil.copyfile(tracedir + "cockpit.log", outdir + "cockpit.log")
        try:
            shutil.copyfile(tracedir + "snapshot.zip", outdir + "snapshot.zip")
        except IOError:
            print("\nCan not find snapshot.zip, ignoring...")

        print("\n\nGetting pip installed packages\n")
        packages = os.system(
            "pip list --format=columns > " +
            outdir +
            "pipList.log")
