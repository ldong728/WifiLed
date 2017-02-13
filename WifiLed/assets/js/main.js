//function sendautoCode(json){
//    var
//
//}
//var debug=true;
var debug=false;

function getJsonString(json){
    var str=JSON.stringify(json);
    return str;
}
function headerTo(url){
    window.location.href=url;
}
function l(data){
    console.log(data);
}
function getUserList(){
    if(!debug)return window.w
    return  '{U_ID:"1",U_NAME:"张三",U_EMAIL:"god@163.com",U_PHONE:"13566603735",U_DEFAULT:1},{U_ID:"9527",U_NAME:"test",U_EMAIL:"abc@abc.com",U_PHONE:"123456789",U_DEFAULT:"0"}'
}
function signIn(data){

}
function getUserInf(){
    //alert("get user inf");
    if(!debug){
//        return window.webkit.messageHandlers.light.postMessage('{method:"getGroupList",type:data}');
    }else{
        return '{U_ID:"9527",U_NAME:"test",U_EMAIL:"abc@abc.com",U_PHONE:"123456789",U_DEFAULT:1}'
    }

}
function searchLight(){
    if(!debug)window.webkit.messageHandlers.light.postMessage(getJsonString({method:"searchDevice"}))
    else lightStandby('1234231212');
}
function getUserInfOnline(){

}
function addGroup(gName){
    if(!debug){
        window.webkit.messageHandlers.light.postMessage(getJsonString({method:"addGroup",data:gName}));
    }
}
function getGroupList(data){
    if(!debug){
        window.webkit.messageHandlers.light.postMessage(getJsonString({method:"getGroupList",data:data}));
    }
    //return '[{"G_NAME":"abc","G_INF":"","U_ID":"1","G_TYPE":"local","G_ID":"1"}]';
}
function getCode(codeType){
    if(!debug)window.webkit.messageHandlers.light.postMessage(getJsonString({method:"getCode",data:codeType}))
}
function sendManualCode(currentColor,level){
    if(!debug){
        window.webkit.messageHandlers.light.postMessage(getJsonString({method:"setManualCode",data:"none",color:currentColor,level:level}))
//        window.light.setManualCode(JSON.stringify({color:currentColor,level:level}));
//        saveCode('TYPE_MANUAL');
    }
}
function sendAutoCode(color,time,level,mode){
    var modeData=mode?"confirm":"not";
    if(!debug){
        window.webkit.messageHandlers.light.postMessage(getJsonString({method:"setAutoCode",data:"none",color:color,time:time,level:level}))
        //window.light.sendAutoCode(JSON.stringify({color:color,time:time,level:level,mode:modeData}))
        //saveCode('TYPE_AUTO');
    }else{
        //l(mode);
    }
    
}
function getGroupInf(){
    if(!debug){
        return window.light.getGroupInf();
    }
    return '{G_SSID:"abcd",G_SSID_PASD:"abcd"}'
}


function sendCloudCode(stu,prob,mask){
    if(!debug) window.light.setCloudCode(getJsonString({stu:stu,prob:prob,mask:mask}));
    saveCode("TYPE_CLOUD");
}
function sendFlashCode(stu,prob,level){
    if(!debug) window.light.setFlashCode(getJsonString({stu:stu,prob:prob,level:level}));
    saveCode("TYPE_FLASH");
}
function sendMoonCode(stu,startH,startM,endH,endM){
    if(!debug) window.light.setFlashCode(getJsonString({stu:stu,startH:startH,startM:startM,endH:endH,endM:endM}));
    saveCode("TYPE_MOON");
}
function changeGroupType(ssid,pasd,merge){
    if(!debug){
        if(!merge){
            window.light.changeGroupType(getJsonString({ssid:ssid,pasd:pasd}));
        }else{
            window.light.mergenGroup();
        }

    }else{

    }

}


function getCurrentSSID(){
    if(!debug)return window.wifi.getCurrentSSID();
    else return "abc";
}


function addDeviceToGroup(jsonData){
    if(!debug)window.light.addDevice(getJsonString(jsonData))
}
function initGroup(){
    if(!debug) {
        //alert('hahahaha');
        //alert("info");
        return window.light.initGroup();
    }
    else return '{"device":{"0":{"D_MAC":"C4BE8474EE31","D_SSID":"USR-C322","G_ID":"1","D_TYPE":"light","D_NAME":"light"}},"inf":{"G_ID":"1","G_NAME":"高性能","U_ID":"1","G_INF":"inf","G_TYPE":"online","G_SSID":"TL-WVR450G","G_SSID_PASD":"gooduo.net"},"type":"online","ssid":"TL-WVR450G"}'
}
function ap2sta(ssid,pasd){
    if(!debug)window.wifi.ap2sta(getJsonString({ssid:ssid,pasd:pasd}))
}

function saveCode(codeType){
    if(!debug)window.light.saveCodeToDb(codeType);
}
function deviceCodeSave(){
    //alert("save");
    if(!debug)window.light.saveCode();
}
function chooseGroup(groupId){
    if(!debug)window.light.chooseGroup(groupId);
}
function scanWifi(){
    if(!debug)window.wifi.scanWifi();
    else setTimeout(function(){
        onGetWifiList('["ssid1","ssid2"]');
    },5000)
}
function linkWifi(ssid){
    if(!debug)window.wifi.linkWifi(getJsonString({ssid:ssid}));
}
function goBack(){
    headerTo('equip_index.html');
}




