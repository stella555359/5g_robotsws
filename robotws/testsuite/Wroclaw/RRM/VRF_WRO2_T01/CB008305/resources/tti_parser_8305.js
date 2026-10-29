'use strict';
const inArgs = process.argv.slice(2);
const fs = require('fs');
const jsonPath = inArgs[0]
const checkPair = (ue1, ue2) => {
    var res1 = false
    var res2 = false
    for(let ue1Log of ue1){
        if(ue1Log.dlFdSchedData.body.muStatus === "MUPAIR" &&
           ue1Log.dlFdSchedData.body.numOfLayers === "RANK4" &&
           ue1Log.dlFdSchedData.body.numOfPrb > 200){
           res1 = true;
           break;
        }
    }
    for(let ue2Log of ue2){
        if(ue2Log.dlFdSchedData.body.muStatus === "MUPAIR" &&
           ue2Log.dlFdSchedData.body.numOfLayers === "RANK4" &&
           ue2Log.dlFdSchedData.body.numOfPrb > 200){
           res2=true;
           break
        }
    }
    if(res1 && res2){
       console.log('PASS');
       return 0;
    }else{
       console.log("Fail! One of UE doesn't each specified muStatus/numOfLayers/numOfPrb");
       return -1;
    }
}

const checkNonPair = (ue1, ue2) => {
    var res1 = false
    var res2 = false
    for(let ue1Log of ue1){
        if(ue1Log.dlFdSchedData.body.muStatus === "NOPAIR_LAYERANDSTREAMNOTOK" &&
           ue1Log.dlFdSchedData.body.numOfLayers === "RANK4" &&
           ue1Log.dlFdSchedData.body.numOfPrb < 273){
           res1 = true;
           break;
        }
    }
    for(let ue2Log of ue2){
        if(ue2Log.dlFdSchedData.body.muStatus === "NOPAIR_LAYERANDSTREAMNOTOK" &&
           ue2Log.dlFdSchedData.body.numOfLayers === "RANK4" &&
           ue2Log.dlFdSchedData.body.numOfPrb < 273){
           res2=true;
           break
        }
    }
    if(res1 && res2){
        console.log('PASS')
        return 0;
    }else{
       console.log("Fail! One of UE doesn't each specified muStatus/numOfLayers/numOfPrb");
       return -1;
    }
}

fs.readFile(jsonPath, (err, data) => {
    if (err) throw err;
    let ttiLogs = JSON.parse(data);
    let ue1 = [];
    let ue2 = [];
    let rememberRNTI = 0;
    let selected_ue = false;
    //grouping ttiLogs to two separate table for each ue
    for(const log of ttiLogs.events){
        if(Object.keys(log)[0] === 'dlFdSchedData'){
            if(rememberRNTI !== log.dlFdSchedData.body.eventHeader.rnti){
                selected_ue = !selected_ue
            }
            rememberRNTI = log.dlFdSchedData.body.eventHeader.rnti
            selected_ue ? ue1.push(log) : ue2.push(log)
        }
    }

    inArgs[1] === 'PAIR' ? checkPair(ue1, ue2) : checkNonPair(ue1, ue2)

});
