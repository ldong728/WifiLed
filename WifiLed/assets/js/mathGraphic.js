/**
 * Created by godlee on 2016/7/5.
 */

var pNumber = 48;//控制点数组长度
var colorList = ['#00d4ff', '#F7F7F7', '#EE2C2C', '#4B0082', '#7D26CD', '#00008B', '#66CD00'];//颜色列表
var edgeL = 0;
var edgeR = pNumber - 1;
var drawList = new Array(7);
var myCanvas;
var myContext;
var bufferCanvas;
var bufferContext;
var canvasWidth;
var canvasHeight;
var pOffset;
var currentColor = 6;
var canvasLeft, canvasTop;
var marginH = 10;
var marginV = 10;
var edgeIndex = -1;
$(document).ready(function () {
    initCanvas();
    window.requestAnimationFrame(draw);
});
function initCanvas() {
    var sCanvas = $('.canvas_wrap').get(0);
    canvasWidth = sCanvas.clientWidth;
    canvasHeight = sCanvas.clientHeight;
    canvasLeft = sCanvas.getBoundingClientRect().left;
    canvasTop = sCanvas.getBoundingClientRect().top;
    pOffset = (canvasWidth - marginH * 2) / pNumber;
    myCanvas = $('#drawing').get(0);
    myCanvas.width = canvasWidth;
    myCanvas.height = canvasHeight;
    myContext = myCanvas.getContext('2d');
    bufferCanvas = document.createElement('canvas');
    bufferContext = bufferCanvas.getContext('2d');
    bufferCanvas.width = canvasWidth;
    bufferCanvas.height = canvasHeight;
    myCanvas.addEventListener('touchstart', touchStart, false);
    myCanvas.addEventListener('touchmove', touchMove, false);
    myCanvas.addEventListener('touchend', touchEnd, false);
    $('.colorSelect').click(function () {
        var id = $(this).attr('id');
        currentColor = id;
        drawBuffer();
    });
    for (var i = 0; i < 7; i++) {
        drawList[i] = new color(i, colorList[i]);
    }
    drawBuffer();
}
function drawBuffer() {
    //bufferContext.clearRect(0,0,canvasWidth,canvasHeight);
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
    var p = getTouchP(e);
    var x = p.x;
    var y = p.y;
    var index = getIndex(x);
    if (0 == index || pNumber - 1 == index) {
        edgeIndex = index;
    } else {
        edgeIndex = -1;
    }
    edgeL = index;
    edgeR = index;
    if (index == pNumber - 1)edgeR = index - 1;
    while (index > 0 && !drawList[currentColor].controlPoints[--edgeL]) {
        continue;
    }
    while (index < pNumber - 1 && !drawList[currentColor].controlPoints[++edgeR]) {
        continue;
    }
    drawList[currentColor].add(new point(x, y));
    //window.wifi.sendCode(JSON.stringify({manualColor:currentColor,time:index,level:105}))//必须代码
}
function touchMove(e) {
    if (edgeIndex < 0) {
        var x = e.touches[0].clientX - canvasLeft;
        var y = e.touches[0].clientY - canvasTop;
        var index = getIndex(x);
        if (index > edgeL && index < edgeR) {
            drawList[currentColor].clearRange(edgeL, edgeR);
            drawList[currentColor].add(new point(x, y));
        }
    } else {
        var index = edgeIndex;
        var x = index * pOffset + marginH;
        var y = e.touches[0].clientY - canvasTop;
        drawList[currentColor].clearRange(edgeL, edgeR);
        drawList[currentColor].add(new point(x, y));
    }


}
function touchEnd(e) {
    var y = e.changedTouches[0].clientY - canvasTop;
    //var level = parseInt((canvasHeight - marginV - y) / (canvasHeight - marginV * 2) * 100);
    if (edgeIndex < 0) {
        var x = e.changedTouches[0].clientX - canvasLeft;
        var index = getIndex(x);
        if (index <=edgeL || index >= edgeR|| y<0) {
            drawList[currentColor].clearRange(edgeL, edgeR);
            return;
        }else{
            if(y<marginV)y=marginV;
            if(y>canvasHeight-marginV)y=canvasHeight-marginV;
            //if(x<marginH)x=marginH;
            //if(x>canvasWidth-marginH)x=canvasWidth-marginH;
            var level=parseInt((canvasHeight - marginV - y) / (canvasHeight - marginV * 2) * 100);
            drawList[currentColor].add(new point(x, y));
            sendCode(currentColor,index,level);
        }

    } else {
        var index=edgeIndex;
        if(y<marginV)y=marginV;
        if(y>canvasHeight-marginV)y=canvasHeight-marginV;
        var level=parseInt((canvasHeight - marginV - y) / (canvasHeight - marginV * 2) * 100);
        var x = index * pOffset + marginH;
        drawList[currentColor].add(new point(x, y));
        sendCode(currentColor,index,level);
    }



}
function getIndex(x) {
    var index = ((x - marginH) / pOffset + 0.5) | 0;
    if (index > pNumber - 1)index = pNumber - 1;
    if (index < 0)index = 0;
    return index;
}

function color(index, color) {
    this.index = index;
    this.color = color;
    this.controlPoints = new Array(pNumber);
    this.drawPoints = new Array();
    this.add = add;
    this.drawSelf = drawSelf;
    this.clearRange = clearRange;
    this.add(new point(marginH, canvasHeight - marginV));
    this.add(new point(canvasWidth - marginH, canvasHeight - marginV));
    function add(p) {
        var index = getIndex(p.x);
        this.controlPoints[index] = p;
    }

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
}

function point(x, y) {
    this.x = x;
    this.y = y;
}

function line(p1, p2, type) {
    this.p1 = p1;
    this.p2 = p2;
    this.type = type;
    this.enable = true;
    this.drawSelf = function () {
        this.isEnable();
        if (this.enable) {
            switch (this.type) {
                case 0:
                {
                    drawLine(this.p1, this.p2);
                    break;
                }
                case 1:
                {
                    drawDotedLine(this.p1, this.p2);
                    break;
                }
            }
        } else {
        }
    }
    this.isEnable = function () {
        if (!this.p1.enable || !this.p2.enable) {
            this.enable = false;
        } else {
            this.enable = true;
        }
    }
}

/**
 *坐标偏移量计算（暂未用到）
 */
function getTouchP(e) {
    //var x=e.touches[0].clientX;
    //var y= e.touches[0].clientY;
    var x = e.touches[0].clientX - canvasLeft;
    var y = e.touches[0].clientY - canvasTop;
    if (x < 0)x = 0;
    if (x > canvasWidth)x = canvasWidth;
    if (y < 0)y = 0;
    if (y > canvasHeight)y = canvasHeight;
    return new point(x, y);
}

//function realP(x,y) {
//    var bbox =myCanvas.getBoundingClientRect();
//    var x= x-bbox.left *(myCanvas.width / bbox.width);
//    var y= y-bbox.top *(myCanvas.height / bbox.height);
//    return new point(x,y);
//}
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
    myContext.beginPath();
    myContext.moveTo(p1.x, p1.y);

    while (Math.abs(a - Dx) > 5 || Math.abs(b - Dy) > 5) {
        Dx += dx;
        Dy += dy;
        if (!isEmpty) {
            myContext.lineTo(p1.x + Dx, p1.y + Dy);
            myContext.stroke();
//                    test('线');
            isEmpty = true;
        } else {
            myContext.moveTo(p1.x + Dx, p1.y + Dy);
            myContext.stroke();
//                    test('空');
            isEmpty = false;
        }
    }
//                test('结束');
    if (!isEmpty) {
        myContext.lineTo(p2.x, p2.y);
        myContext.stroke();
    } else {
        myContext.moveTo(p2.x, p2.y);
        myContext.stroke();
    }


//            myContext.stroke();
    myContext.closePath();
//            test('closePath');
}
function sendCode(color,time,level){
    //alert("manualColor:"+currentColor+",index:"+time+",level:"+level);
}

function initCode(data){
    var json=eval("("+data+")");
    $.each(json,function(color,stu){
        $.each(stu,function(time,level){
            var x = index * pOffset + marginH;
            //parseInt((canvasHeight - marginV - y) / (canvasHeight - marginV * 2) * 100);
            var y= parseInt(canvas-marginV-level*(canvasHeight-marginV *2 )/100)
            drawList[color].add(new point(x,y));
        })
    });

}



