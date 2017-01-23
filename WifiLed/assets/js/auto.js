
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
        var index = getCtrIndex(p.x);
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