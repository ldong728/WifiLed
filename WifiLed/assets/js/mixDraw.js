/**
 * Created by godlee on 2016/7/5.
 */

var pNumber = 48;//控制点数组长度
var colorNumber=7;
var colorList = ['#0D308E','#B1D0E2', '#B7080A','#A61583','#571785', '#0085C8', '#43AF37'];
var colorNameList=[ '深蓝','白色', '深红', 'U V', '紫色', '蓝色', '绿色'];
var edgeL = 0;
var edgeR = pNumber - 1;
var drawList = new Array(7);
var palette = new Array(7);
var aCanvas;
var aContext;
var aBufferCanvas;
var aBufferContext;
var aCanvasWidth;
var aCanvasHeight;
var bCanvas;
var bContext;
var bBufferCanvas;
var bBufferContext;
var valueRange;
var colorHeight;
var colorWidth;
var innerPaddingV;
var innerPaddingH;
var bCanvasWidth;
var bCanvasHeight;
var tempLevel;
var margin=20;
var bPadding=10;
var textSize=14;
var baseLineBorder=1;
var baseValue=bPadding+textSize*3;
var pOffset;
var currentColor = 6;
var aCanvasLeft, aCanvasTop;
var bCanvasLeft,bCanvasTop;
var marginH = 10;
var marginV = 10;
var paddingBottom;
var edgeIndex = -1;//标记点，如果触摸发生在最边缘，则让此变量保存所在边缘点的index
var bgImg;
var currentX=0;
var colorControlable=false;
//var ratio;
$(document).ready(function () {
    l("mix draw")
    initCanvas();
    window.requestAnimationFrame(draw);
});

function initCanvas() {
    var aCanvasWrap=$('.wrapA').get(0);
    var bCanvasWrap=$('.wrapB').get(0);
    aCanvas = $('#aCanvas').get(0);
    aContext = aCanvas.getContext('2d');
    bCanvas = $('#bCanvas').get(0);
    bContext = bCanvas.getContext('2d');
    bgImg=$('#timeImg').get(0);
    aCanvasWidth = aCanvasWrap.clientWidth*2;
    aCanvasHeight = aCanvasWrap.clientHeight*2;
    aCanvasLeft = aCanvasWrap.getBoundingClientRect().left;
    aCanvasTop = aCanvasWrap.getBoundingClientRect().top;
    pOffset = (aCanvasWidth - marginH * 2) / pNumber;
    aCanvas.width = aCanvasWidth;
    aCanvas.height = aCanvasHeight;
    aBufferCanvas = document.createElement('canvas');
    aBufferContext = aBufferCanvas.getContext('2d');
    aBufferCanvas.width = aCanvasWidth;
    aBufferCanvas.height = aCanvasHeight;
    $('#aCanvas').css('width',aCanvasWidth/2+'px');
    $('#aCanvas').css('height',aCanvasHeight/2+'px');
    paddingBottom=parseInt((aCanvasHeight-marginV)*30/230)
    bCanvasWidth = bCanvasWrap.clientWidth*2;
    bCanvasHeight = bCanvasWrap.clientHeight*2;
    bCanvasLeft = bCanvasWrap.getBoundingClientRect().left;
    bCanvasTop = bCanvasWrap.getBoundingClientRect().top;
    bCanvas.width = bCanvasWidth;
    bCanvas.height = bCanvasHeight;

    bBufferCanvas = document.createElement('canvas');
    bBufferContext = bBufferCanvas.getContext('2d');
    bBufferCanvas.width = bCanvasWidth;
    bBufferCanvas.height = bCanvasHeight;
    colorWidth=bCanvasWidth/colorNumber;
    colorHeight=bCanvasHeight-marginV*2;
    innerPaddingV=parseInt(colorHeight*0.05);
    innerPaddingH=parseInt(colorWidth*0.05);
    textSize=parseInt(colorHeight*0.1);
    valueRange=colorHeight*0.60;

    aCanvas.addEventListener('touchstart', touchStart, false);
    aCanvas.addEventListener('touchmove', touchMove, true);
    aCanvas.addEventListener('touchend', touchEnd, false);
    bCanvas.addEventListener('touchstart',colorSelectTouch,false);
    bCanvas.addEventListener("touchmove",colorSelectMove,false);
    bCanvas.addEventListener('touchend',colorSelectEnd,false);


    for (var i = 0; i < 7; i++) {
        drawList[i] = new color(i, colorList[i]);
        palette[i]= new manualColor(i,colorList[i]);
    }

    $('#bCanvas').css('width',bCanvasWidth/2+'px');
    $('#bCanvas').css('height',bCanvasHeight/2+'px');
    initCode(getCode("TYPE_AUTO"));
    drawBuffer();
    l("init Canvas ok")
}
function drawBuffer() {
    aBufferCanvas.width = aBufferCanvas.width;
    aBufferContext.drawImage(bgImg,0,marginV,aCanvasWidth,(aCanvasHeight-marginV));
    for(var i=0;i<colorNumber;i++){
        if(i!=currentColor){
            drawList[i].drawSelf(aBufferContext);
        }
    }

}
function draw() {
    aCanvas.width = aCanvas.width;
    bCanvas.width = bCanvas.width;
    aContext.drawImage(bgImg,0,marginV,aCanvasWidth,(aCanvasHeight-marginV));
    aContext.drawImage(aBufferCanvas, 0, 0,aCanvasWidth,aCanvasHeight);
    bContext.drawImage(bBufferCanvas,0,0,bCanvasWidth,bCanvasHeight);
    drawList[currentColor].drawSelf(aContext);
    for(var i=0;i<colorNumber;i++){
            palette[i].drawSelf(bContext);
    }
    l("draw")
    requestAnimationFrame(draw);
}
function touchStart(e) {
    var x = (e.touches[0].clientX - aCanvasLeft)*2;
    var y = (e.touches[0].clientY - aCanvasTop)*2;
    var index = getCtrIndex(x);
    if (0 == index || pNumber - 1 == index) {
        edgeIndex = index;
    } else {
        edgeIndex = -1;
    }
    if(drawList[currentColor].controlPoints[index-1])index-=1;
    if(drawList[currentColor].controlPoints[index+1])index+=1;
    getEdge(index);
    drawList[currentColor].add(new point(x, y));
    //window.light.sendAutoCode(JSON.stringify({color:currentColor,time:index,level:105,mode:'not'}))//必须代码
    sendAutoCode(currentColor,index,105,false);
}
function touchMove(e) {
    var level;
    var index;
    if (edgeIndex < 0) {
        var x = (e.touches[0].clientX - aCanvasLeft)*2;
        var y = (e.touches[0].clientY - aCanvasTop)*2;
        index = getCtrIndex(x);
        if (index > edgeL && index < edgeR) {
            drawList[currentColor].clearRange(edgeL, edgeR);
            drawList[currentColor].add(new point(x, y));
            //level=parseInt((aCanvasHeight -paddingBottom - y) / (aCanvasHeight - marginV-paddingBottom) * 100);
            //palette[currentColor].setLevel(level);
            culculateLevel(index);

        }
    } else {
        index = edgeIndex;
        var x = (index * pOffset + marginH);
        var y = (e.touches[0].clientY - aCanvasTop)*2;
        drawList[currentColor].clearRange(edgeL, edgeR);
        drawList[currentColor].add(new point(x, y));
        culculateLevel(index)
    }

    level=parseInt((aCanvasHeight -paddingBottom - y) / (aCanvasHeight - marginV-paddingBottom) * 100);
    if(level<0)level=0;
    if(level>100&&level<105)level=100;
    if(level>=105)level=0;
    //console.log(level);
    palette[currentColor].setLevel(level);


}
/**
 * 线图内触摸结束时调用的方法
 * @param e触摸事件
 */
function touchEnd(e) {
    var level=0;
    var x=0;
    var index;
    var y = (e.changedTouches[0].clientY - aCanvasTop)*2;
    //var level = parseInt((aCanvasHeight - marginV - y) / (aCanvasHeight - marginV * 2) * 100);
    if (edgeIndex < 0) {//触摸点不是在边缘的情况
        x = (e.changedTouches[0].clientX - aCanvasLeft)*2;
        index = getCtrIndex(x);
        if (index <=edgeL || index >= edgeR|| y<0) {
            drawList[currentColor].clearRange(edgeL, edgeR);
            drawList[currentColor].fillLevelList(edgeL,edgeR);
            //window.light.sendAutoCode(JSON.stringify({color:currentColor,time:edgeL+1,level:110,mode:'confirm'}))
            sendAutoCode(currentColor,edgeR-1,110,true);
            palette[currentColor].setLevel(0);
            currentX=-1;
            return;
        }else{
            if(y<(marginV))y=(marginV);
            if(y>(aCanvasHeight-paddingBottom))y=(aCanvasHeight-paddingBottom);
            level=parseInt((aCanvasHeight -paddingBottom - y) / (aCanvasHeight - marginV-paddingBottom) * 100);
            drawList[currentColor].add(new point(x, y));
            drawList[currentColor].fillLevelList(edgeL,index);
            drawList[currentColor].fillLevelList(index,edgeR);
            currentX=x;
        }

    } else {
        index=edgeIndex;
        var edge=index;
        if(y<(marginV))y=(marginV);
        if(y>(aCanvasHeight-paddingBottom))y=(aCanvasHeight-paddingBottom);
        level=parseInt((aCanvasHeight - paddingBottom - y) / (aCanvasHeight - marginV-paddingBottom) * 100);
        x = (index * pOffset + marginH);
        drawList[currentColor].add(new point(x, y));
        if(0==index){
            while (!drawList[currentColor].controlPoints[++edge]) {
                continue;
            }
            drawList[currentColor].fillLevelList(index,edge);
        }else if(pNumber-1==index){
            while (!drawList[currentColor].controlPoints[--edge]) {
                continue;
            }
            drawList[currentColor].fillLevelList(edge,index);
        }
        currentX=x;
    }

        //console.log("level:"+drawList[currentColor].getLevel(index));
        //window.light.sendAutoCode(JSON.stringify({color:currentColor,time:index,level:level,mode:'confirm'}))
        sendAutoCode(currentColor,index,level,true);

}
function colorSelectTouch(e){
    var x = (e.touches[0].clientX - bCanvasLeft)*2;
    var colorIndex=getColorIndex(x);
    console.log(colorIndex);
    if(colorIndex!=currentColor){
        currentColor = colorIndex;
        drawBuffer();
    }
    if(currentX>-1){
        var index=getCtrIndex(currentX);
        getEdge(index);
        var y = (e.touches[0].clientY - bCanvasTop)*2;
        var level=parseInt((colorHeight-innerPaddingV*2-textSize-y)*100/valueRange);
        if(level>-1&&level<101){
            colorControlable=true;
        }else{
            colorControlable=false;
        }
    }

}
function colorSelectMove(e){
    if(colorControlable){
        var y = (e.touches[0].clientY - bCanvasTop)*2;
        var level=parseInt((colorHeight-innerPaddingV*2-textSize-y)*100/valueRange);
        if(level<0)level=0;
        if(level>100)level=100;
        palette[currentColor].setLevel(level);
        if(currentX>-1){
            var y=parseInt((aCanvasHeight -paddingBottom)- level * (aCanvasHeight - marginV-paddingBottom) / 100);
            drawList[currentColor].clearRange(edgeL, edgeR);
            drawList[currentColor].add(new point(currentX, y));
        }
    }
}
function colorSelectEnd(e){
    if(colorControlable){
        var y = (e.changedTouches[0].clientY - bCanvasTop)*2;
        var level=parseInt((colorHeight-innerPaddingV*2-textSize-y)*100/valueRange);
        if(level<0)level=0;
        if(level>100)level=100;
        palette[currentColor].setLevel(level);
        if(currentX>-1){
            var y=parseInt((aCanvasHeight -paddingBottom)- level * (aCanvasHeight - marginV-paddingBottom) / 100);
            drawList[currentColor].clearRange(edgeL, edgeR);
            var sIndex=drawList[currentColor].add(new point(currentX, y));
            drawList[currentColor].fillLevelList(edgeL,sIndex);
            drawList[currentColor].fillLevelList(sIndex,edgeR);
            //window.light.sendAutoCode(JSON.stringify({color:currentColor,time:sIndex,level:level,mode:'confirm'}));
            sendAutoCode(currentColor,sIndex,level,true);
        }
    }

}
function getCtrIndex(x) {
    var index = ((x - marginH) / pOffset + 0.5) | 0;
    if (index > pNumber - 1)index = pNumber - 1;
    if (index < 0)index = 0;
    return index;
}
function getColorIndex(x){
    var index = ((x - marginH) / colorWidth + 0.5) | 0;
    if (index > colorNumber-1)index =  colorNumber-1;
    if (index < 0)index =-1;
    return index;
}
function culculateLevel(index){
    for(var i=0; i<colorNumber;i++){
        if(i!=currentColor){
            palette[i].setLevel(drawList[i].levelList[index]||0)
        }
    }
}
function getEdge(index){
    edgeL = index;
    edgeR = index;
    if (index == pNumber - 1)edgeR = index - 1;
    while (index > 0 && !drawList[currentColor].controlPoints[--edgeL]) {
        continue;
    }
    while (index < pNumber - 1 && !drawList[currentColor].controlPoints[++edgeR]) {
        continue;
    }
}

function color(index, colorIndex) {
    var _=this;
    this.index = index;
    this.color = colorIndex;
    this.controlPoints = new Array(pNumber);
    this.levelList= new Array(pNumber);

    this.fillLevelList=fillLevelList;
    //this.drawPoints = new Array();
    this.add = add;
    this.drawSelf = drawSelf;
    this.clearRange = clearRange;
    this.add(new point(marginH, (aCanvasHeight - paddingBottom)));
    this.add(new point((aCanvasWidth - marginH), (aCanvasHeight - paddingBottom)));

    function add(p) {

        var index1 = getCtrIndex(p.x);
        this.controlPoints[index1] = p;
        var y= p.y
        this.levelList[index1]=getLevel(index1);
        return index1;
    }
    this.getLevel=getLevel;

    function drawSelf(context) {
        var cu = this.index == currentColor ? true : false;
        context.beginPath();
        context.strokeStyle = this.color;
        context.fillStyle=this.color;
        context.lineWidth = 2;
        context.moveTo(this.controlPoints[0].x, this.controlPoints[0].y);
        $.each(this.controlPoints, function (k, v) {
            if (k > 0 && v) {
                context.lineTo(v.x, v.y);
                context.moveTo(v.x, v.y);
            }
        });
        context.stroke();
        context.closePath();
        if (cu) {
            $.each(this.controlPoints, function (k, v) {
                if (k > -1 && v) {
                    context.beginPath();
                    //context.lineWidth = 10;
                    context.arc(v.x, v.y, 5, 0, Math.PI * 2);
                    context.fill();
                }

            })

        }

    }

    function clearRange(l, r) {
        for (var i = l + 1; i < r; i++) {
            this.controlPoints[i] = null;
        }
    }
    function fillLevelList(l,r){
        l=parseInt(l);
        r=parseInt(r);
        var le=getLevel(l)
        var tValue=getLevel(r)-le;
        var tIndex=r-l;
        var offset=tValue/tIndex;
        for(var i=l+1;i<r;i++){
            _.levelList[i]=le+(i-l)*offset;
            //console.log(i+': '+ _.levelList[i]||0);
        }


    }

    function getLevel(ctrIndex){
        var p=_.controlPoints[ctrIndex];
        var y= p.y;
        return parseInt((aCanvasHeight - paddingBottom - y) / (aCanvasHeight - marginV-paddingBottom) * 100)
    }
}
function manualColor(index, color) {
    this.index = index;
    this.color = color;
    this.top=marginV;
    this.left=index*colorWidth+marginH;
    this.lineWidth=colorWidth/4
    this.value=0;
    this.level=0;

    this.setValue=function(value){
        this.value=value;
        this.level=parseInt(value * 100 / valueRange)
    }
    this.setLevel=function(level){
        //if()
        this.level=parseInt(level);
        this.value=parseInt(level*valueRange / 100);
    }

    this.drawSelf=function(context) {
        //var drawTop=this.top+bPadding;
        context.strokeStyle = this.color;
        context.fillStyle=this.color;
        context.font='bold '+textSize+"px 'Helvetica,Arial'";
        context.lineWidth=this.lineWidth;
        context.fillText(colorNameList[this.index],this.left+innerPaddingH,colorHeight-innerPaddingV);
        context.fillText(this.level+'%',this.left+innerPaddingH,textSize+innerPaddingV);
        context.beginPath();
        context.moveTo(this.left+this.lineWidth,colorHeight-innerPaddingV*2-textSize);
        context.lineTo(this.left+this.lineWidth,colorHeight-innerPaddingV*2-textSize-(valueRange/100*this.level));
        context.stroke();
        context.closePath();

    }

}

function point(x, y) {
    this.x = x;
    this.y = y;
}



/**
 *坐标偏移量计算（暂未用到）
 */
function getTouchP(e) {
    //var x=e.touches[0].clientX;
    //var y= e.touches[0].clientY;
    var x = e.touches[0].clientX - aCanvasLeft;
    var y = e.touches[0].clientY - aCanvasTop;
    if (x < 0)x = 0;
    if (x > aCanvasWidth)x = aCanvasWidth;
    if (y < 0)y = 0;
    if (y > aCanvasHeight)y = aCanvasHeight;
    return new point(x, y);
}

function drawDotedLine(p1, p2) {
//            test('indraw');
    var a = p2.x - p1.x;
//            test('a='+a);
    var b = p2.y - p1.y;
//            test('b='+b);
    var c = Math.sqrt(Math.pow(a, 2) + Math.pow(b, 2));
//            test('c='+c)
    var dotCount = c / 5;
//            test('dotCount='+dotCount);
    var dx = a / dotCount;
//            test('dx='+dx);
    var dy = b / dotCount;
//            test('dy='+dy);
    var Dx = 0;
    var Dy = 0;
    var isEmpty = false;
    aContext.beginPath();
    aContext.moveTo(p1.x, p1.y);

    while (Math.abs(a - Dx) > 5 || Math.abs(b - Dy) > 5) {
        Dx += dx;
        Dy += dy;
        if (!isEmpty) {
            aContext.lineTo(p1.x + Dx, p1.y + Dy);
            aContext.stroke();
//                    test('线');
            isEmpty = true;
        } else {
            aContext.moveTo(p1.x + Dx, p1.y + Dy);
            aContext.stroke();
//                    test('空');
            isEmpty = false;
        }
    }
//                test('结束');
    if (!isEmpty) {
        aContext.lineTo(p2.x, p2.y);
        aContext.stroke();
    } else {
        aContext.moveTo(p2.x, p2.y);
        aContext.stroke();
    }


//            aContext.stroke();
    aContext.closePath();
//            test('closePath');
}
//function sendCode(color,time,level){
    //alert("manualColor:"+currentColor+",index:"+time+",level:"+level);
//}

function initCode(data){
    var json=eval("("+data+")");
    $.each(json,function(color,stu){
        var startIndex=0;
        drawList[color].add(new point(marginH, (aCanvasHeight - paddingBottom)));
        drawList[color].add(new point((aCanvasWidth - marginH), (aCanvasHeight - paddingBottom)));
        $.each(stu,function(time,level){
            var x = time * pOffset + marginH;
            //parseInt((aCanvasHeight - marginV - y) / (aCanvasHeight - marginV * 2) * 100);
            var y= parseInt(aCanvasHeight-paddingBottom-level*(aCanvasHeight-marginV -paddingBottom )/100)
            drawList[color].add(new point(x,y));
            drawList[color].fillLevelList(startIndex,time);
            startIndex=time;
        });
        drawList[color].fillLevelList(startIndex,pNumber-1);
    });
}



