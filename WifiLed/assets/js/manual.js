var canvasList=new Array();
var sliderList=new Array();
var levels={};
var sConfig={
    color:config.color||'#ffffff',
    totalLevel:config.totalLevel||100,
    padding:config.padding||0,
    baseValue:config.baseValue||10,
    baseLineBorder:config.baseLineBorder||4,
    backGroundColor:config.backgroundAttachment||'#25bb9c',
    buttonDiam:config.buttonDiam||10
}
init();
draw();

function init(){

    $('.canvas_container').each(function(k,v){
        //var canvasWrap= v;
        var sWidth= v.clientWidth;
        var sHeight= v.clientHeight;
        var left = v.getBoundingClientRect().left;
        var top = v.getBoundingClientRect().top;
        var sSlider;
        var id='canvas'+k;
        $(v).append('<canvas id="'+id+'" style="position: absolute"></canvas>')
        var sCanvas=$('#'+id).get(0);
        sCanvas.width=sWidth*2;
        sCanvas.height=sHeight*2;
        canvasList.push(sCanvas);
        sSlider=new Slider(sCanvas,k,sConfig.color,left,top,$(v).next('div'));
        sliderList.push(sSlider);
        levels[k]=0;
        sCanvas.addEventListener('touchstart',sSlider.touchStart,false);
        sCanvas.addEventListener("touchmove",sSlider.touchMove,false);
        sCanvas.addEventListener('touchend',sSlider.touchEnd,false);
        $('#'+id).css('width',sWidth+'px');
        $('#'+id).css('height',sHeight+'px');

    })
}
function draw(){
    $.each(canvasList,function(k,v){
        v.width= v.width;
        sliderList[k].drawSelf();
    })
    requestAnimationFrame(draw);
}

function Slider(canvas,index, color,left,top,displayer) {

    var _=this;
    _.choosen=false;
    _.canvas=
    _.left=left;
    _.top=top;
    _.mContext = canvas.getContext("2d");
    _.index = index;
    _.color = color;
    _.valueRange = canvas.width-sConfig.padding*2-sConfig.baseValue-sConfig.buttonDiam;
    _.drawTop=canvas.height/2;
    _.top=0;
    _.value=0;
    _.level=0;
    _.setValue=function(value){
        _.value=value;
        _.level=parseInt(value * sConfig.totalLevel / _.valueRange);
        displayer.text(_.level+'%');
    }
    _.setLevel=function(level){
        _.level=parseInt(level);
        _.value=parseInt(level* _.valueRange / sConfig.totalLevel);
        displayer.text(_.level+'%');

    }

    _.drawSelf=function() {
        var drawTop= _.drawTop;
        _.mContext.beginPath();
        _.mContext.lineWidth=sConfig.baseLineBorder;
        _.mContext.strokeStyle='#CCCCCC';
        _.mContext.moveTo(sConfig.baseValue,drawTop);
        _.mContext.lineTo(sConfig.baseValue+ _.valueRange,drawTop);
        _.mContext.stroke();
        _.mContext.strokeStyle = _.color;
        _.mContext.fillStyle=_.color;
        _.mContext.lineWidth = 6;
        _.mContext.beginPath();
        _.mContext.moveTo(sConfig.baseValue,drawTop);
        _.mContext.lineTo(sConfig.baseValue+_.value,drawTop);
        _.mContext.stroke();
        _.mContext.closePath();
        _.mContext.fillStyle=sConfig.color;
        _.mContext.arc(sConfig.baseValue+_.value,drawTop,sConfig.buttonDiam, 0, Math.PI * 2, true);
        _.mContext.fill();
        _.mContext.beginPath();
        _.mContext.fillStyle=sConfig.backGroundColor;
        _.mContext.lineWidth =2;
        _.mContext.arc(sConfig.baseValue+_.value,drawTop, sConfig.buttonDiam/2, 0, Math.PI * 2,true);
        _.mContext.fill();
        _.mContext.closePath();
    }
    _.touchStart=function(e){
        _.choosen=true;
        var x = (e.touches[0].clientX - _.left-sConfig.baseValue)*2;
        if(x>_.valueRange)x=_.valueRange;
        if(x<sConfig.baseValue)x=0;
        //var y = (e.touches[0].clientY - _.top)*2;
        //console.log("index:"+ _.index+": "+x);
        _.setValue(x);
    }
    _.touchMove=function(e){
        if(_.choosen){
            var x = (e.touches[0].clientX - _.left)*2;
            if(x>_.valueRange)x=_.valueRange;
            if(x<sConfig.baseValue)x=0;
                _.setValue(x)
            //console.log(_.level);
        }
    }
    _.touchEnd=function(e){
        _.choosen=false;
       //var x = (e.changedTouches[0].clientX - _.left)*2;
       // if(x>sConfig.baseValue&&x< _.valueRange){
       //     _.setValue(x)
       // }else if(_.level<0)_.level=0;
       // else if(_.level>sConfig.totalLevel)_.level=sConfig.totalLevel;
       // console.log(_.level);
        levels[_.index]= _.level;
        createCode(_.index);
    }

}
function initStatus(data){
    $.each(data,function(k,v){
        sliderList[k].setLevel(v);
    });
}