#!/bin/bash
#./to_be_run_enb_test.sh  --enbbuild:SBTS00_ENB_9999_240223_000005  --gnbbuild:SBTS00_ENB_9999_240227_000006

runner_dir=`dirname "$(realpath $0)"`

enbbuild=""
gnbbuild=""
for build in $@
do
    if [[ "$build"  =~ "enb" ]]; then
        enbbuild=`echo "$build" | cut -d: -f2`
    fi
    if [[ "$build"  =~ "gnb" ]]; then
        gnbbuild=`echo "$build" | cut -d: -f2`
    fi
done

if [[ -z "$gnbbuild"  ]]; then
    gnbbuild=$1
fi

python ${runner_dir}/../python/tc_runner.py\
 --conf-dir ~/testline_configuration/7_20_UTE5GCLASSSV045/\
 --gnb-builds $gnbbuild\
 --gnb-target-directory /5gswload/SBTS24R3/\
 --enb-builds $enbbuild\
 --enb-target-directory /5gswload/SBTS24R3/\
 --tc-files-or-dirs\
   ../../../CB009051/TestCases/\
 --tc-log-dir ~/test_results\
 --qc-report\
 --qc-file ../../../CB009051/TestCases/CB009051.qc\
 --username ncaudy

 #--gnb-dl-only\
 #--enb-force-update
 #--tc-robot-opts "\-\-dryrun"\
