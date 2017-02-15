/**
 * Created by godlee on 2016/7/5.
 */

var colorNumber = 7;//控制点数组长度
//var colorList = ['#A61583', '#571785', '#0D308E', '#0085C8', '#43AF37', '#B7080A', '#B1D0E2'];//颜色列表
var colorList = ['#0D308E','#B1D0E2', '#B7080A','#A61583','#571785', '#0085C8', '#43AF37']
var colorNameList=[ '深蓝','白色', '深红', 'UV', '紫色', '蓝色', '绿色'];
var drawList = new Array(colorNumber);
var tempLevel;
var margin=20;
var padding=10;
var marginH = 10;
var marginV = 10;
var textSize=14*2;
var baseLineBorder=1;
var baseValue=padding+textSize*3;
var valueRange;
var colorHeight;
var myCanvas;
var myContext;
var bufferCanvas;
var bufferContext;
var canvasWidth;
var canvasHeight;
var pOffset;
var currentColor = 6;
var canvasLeft, canvasTop;
var edgeIndex = -1;
$(document).ready(function () {
    initCanvas();
    window.requestAnimationFrame(draw);
});
function initCanvas() {
    var sCanvas = $('.manual_canvas_wrap').get(0);
    canvasWidth = sCanvas.clientWidth*2;
    canvasHeight = sCanvas.clientHeight*2;
    canvasLeft = sCanvas.getBoundingClientRect().left;
    canvasTop = sCanvas.getBoundingClientRect().top;
    //pOffset = (canvasWidth - marginV * 2) / colorNumber;
    myCanvas = $('#manual_canvas').get(0);
    myCanvas.width = canvasWidth;
    myCanvas.height = canvasHeight;
    valueRange=canvasWidth-marginH*2-padding*3-textSize*4.5;
    colorHeight=(canvasHeight-marginV*2)/colorNumber
    myContext = myCanvas.getContext('2d');
    bufferCanvas = document.createElement('canvas');
    bufferContext = bufferCanvas.getContext('2d');
    bufferCanvas.width = canvasWidth;
    bufferCanvas.height = canvasHeight;
    myCanvas.addEventListener('touchstart', touchStart, false);
    myCanvas.addEventListener('touchmove', touchMove, false);
    myCanvas.addEventListener('touchend', touchEnd, false);
    for (var i = 0; i < 7; i++) {
        drawList[i] = new manualColor(i, colorList[i]);
    }
    $('#manual_canvas').css('width',canvasWidth/2+'px');
    $('#manual_canvas').css('height',canvasHeight/2+'px');
//    initCode(getCode('TYPE_MANUAL'));
    getCode('TYPE_MANUAL');
    drawBuffer();
}
function getCodeReply(data){
    initCode(data)
}
function drawBuffer() {
    bufferCanvas.width = bufferCanvas.width;
    $.each(drawList, function (k, v) {
        if (k != currentColor) {
            //alert(v.manualColor);
            v.drawSelf(bufferContext);
        }
    });
}
function draw() {
    myCanvas.width = myCanvas.width;
    myContext.drawImage(bufferCanvas, 0, 0);
    drawList[currentColor].drawSelf(myContext);
    requestAnimationFrame(draw);
}
function touchStart(e) {
    var y = (e.touches[0].clientY - canvasTop)*2;
    var index = getIndex(y);
    if(index>-1){
        currentColor=index;
        drawBuffer();
        //alert(currentColor);
    }

}
function touchMove(e) {
        var x = (e.touches[0].clientX - canvasLeft)*2;
        var value = x - baseValue;

    if(value>=0&&value<=valueRange){
        drawList[currentColor].setValue(value);
    }else if(value<0){
        drawList[currentColor].setValue(0);
    }else if(value>valueRange){
        drawList[currentColor].setValue(valueRange);
    }
    if(tempLevel!=drawList[currentColor].level){
        //window.light.setManualCode(JSON.stringify({color:currentColor,level:drawList[currentColor].level}));
        sendManualCode(currentColor,drawList[currentColor].level);
        tempLevel=drawList[currentColor].level;
    }

}
function touchEnd(e) {
    var x= (e.changedTouches[0].clientX - canvasLeft)*2;
    var y = (e.changedTouches[0].clientY - canvasTop)*2;
}
function getIndex(y) {
    var index = ((y - marginV) / colorHeight + 0.5) | 0;
    if (index > colorNumber-1)index =  -1;
    if (index < 0)index =-1;
    return index;
}
function manualColor(index, color) {
                this.index = index;
                this.color = color;
                colorHeight=canvasHeight/7;
                this.top=index*colorHeight;
                this.value=0;
                this.level=0;

                this.setValue=function(value){
                    this.value=value;
                    this.level=parseInt(value * 100 / valueRange)
                }
                this.setLevel=function(level){
        this.level=level;
        this.value= parseInt(valueRange*level/100)
    }

                this.drawSelf=function(context) {
                    var drawTop=this.top+padding*2;
                    context.beginPath();
                    context.lineWidth=baseLineBorder*2;
                    context.strokeStyle='#CCCCCC';
                    context.moveTo(baseValue,this.top+padding*2+5);
                    context.lineTo(baseValue+valueRange,this.top+padding*2+5);
                    context.stroke();
                    context.strokeStyle = this.color;
                    context.fillStyle=this.color;
                    context.lineWidth = 3*2;
                    context.beginPath();
                    context.moveTo(baseValue,drawTop+5)
                    context.lineTo(baseValue+this.value,this.top+padding*2+5);
                    context.stroke();
                    context.closePath();
                    context.arc(baseValue+this.value,this.top+padding*2+5,6*2, 0, Math.PI * 2, true);
                    context.fill();
                    context.font='bold '+textSize+"px 'Helvetica,Arial'";
                    context.fillText(colorNameList[this.index],padding,drawTop+textSize/2);
                    context.fillText(this.level+'%',baseValue+valueRange+padding*1.5,drawTop+textSize/2);
                    context.beginPath();
                    context.fillStyle='#ffffff';
                    context.lineWidth =2;
                    context.arc(baseValue+this.value,this.top+padding*2+5, 2*2, 0, Math.PI * 2,true);
                    context.fill();
                    context.closePath();
                }
            }
function initCode(data){
    var ve=eval('('+data+')');
    $.each(ve,function(k,v){
        drawList[k].setLevel(v||0);
    })
}





