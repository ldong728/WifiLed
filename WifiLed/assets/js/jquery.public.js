// 2016-08-01
$(function() {
    
    // 加载初始化函数
    app_func.initBind();
    
    // 其它函数
    
    
    
});

var app_func = {
    // 初始化调用
    initBind: function() {
        var win_h = $(window).height();
        if($('body').height() < win_h) {
            $('body').height(win_h);
        }
    }
}

// 用户
var app_form = {
    // 验证用户表单
    checkform: function(){
        if ($('input[name=email]').val() === '') {
            app_msg.alert('邮箱不能为空！', function(){
                $('input[name=email]').focus();
            });
            return false;
        } else if ($('input[name=pass]').val() === '') {
            app_msg.alert('密码不能为空！', function(){
                $('input[name=pass]').focus();
            });
            return false;
        } else if ($('input[name=pass2]').val() === '') {
            app_msg.alert('重复密码不能为空！', function(){
                $('input[name=pass2]').focus();
            });
            return false;
        } else if ($('input[name=pass]').val() !== $('input[name=pass2]').val() && $('input[name=pass2]').length > 0) {
            app_msg.alert('两次密码不一致！');
            return false;
        }
        return true;
    },
    // 表单提交
    checkit: function(from) {
        if (app_form.checkform()) {
            if (from == 'login') {
                app_tool.loading(function() {

                    // 执行脚本
                    location.href = 'equip_index.html';
                });
            } else if (from == 'reg') {
                app_tool.loading(function() {
                    // 执行脚本
                     var mail=$('#email').val();
                     var pasd=$('#pass').val();
                     var data=JSON.stringify({name:'',email:mail,phone:'',pasd:pasd})
                     var id=window.light.addUser(data);
                     if(id>-1){
                         alert("id ok");
                        location.href="equip_index.html"
                     }
                    setTimeout(function() {
                        app_tool.loaded();
                    }, 3000);
                });
            } else if (from == 'forget') {
                app_tool.loading(function() {
                    // 执行脚本
                    setTimeout(function() {
                        app_tool.loaded();
                    }, 3000);
                });
            }
        }
    }
}

// 消息提示
var app_msg = {
    // 文本
    alert: function(str, func) {
        app_tool.loaded();
        if (!$('.app-msg').length) {
            $('body').append('<div class="app-msg slideInUp"><div class="txt">' + str + '</div></div>');
            setTimeout(function() {
                app_msg.animation(func);
            },
            2000);
        }
    },
    // 是否选择
    confirm: function(str, func1, func2) {
        app_tool.loaded();
        if (!$('.app-msg').length) {
            $('body').append('<div class="app-msg slideInUp"><div class="txt">' + str + '</div><div class="confirm"><span class="no">取消</span><span class="yes">确认</span></div></div>');
            $('.no', '.app-msg').click(function() {
                app_msg.animation(func1);
            });
            $('.yes', '.app-msg').click(function() {
                app_msg.animation(func2);
            });
        }
    },
    // 密码提示
    wifi: function(str, func) {
        app_tool.loaded();
        if (!$('.app-msg').length) {
            $('body').append('<div class="app-msg slideInUp"><div class="txt">' + str + '</div><div class="wifi"><input type="text" name="wifipass" placeholder="密码" class="noset" /></div><div class="confirm"><span class="no">取消</span><span class="yes">连接</span></div></div>');
            $('.no', '.app-msg').click(function() {
                app_msg.animation();
            });
            $('.yes', '.app-msg').click(function() {
                app_msg.animation(func);
            });
        }
    },
    // 关闭提示
    animation: function(func) {
        var animationEnd = 'webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend';
        $('.app-msg').removeClass('slideInUp').addClass('slideOutDown').one(animationEnd, function() {
            $('.app-msg').remove();
            app_tool.callback(func);
        });
    }
}

// 工具
var app_tool = {
    // 复选框
    checkbox: function(e) {
        e.toggleClass('checked').find('input[type=hidden]');
        var ep = e.find('input[type=hidden]');
        ep.val() == 0 ? ep.val(1) : ep.val(0);
    },
    // 返回上页
    goback: function() {
        history.back();
    },
    // 载入动画
    loading: function(func) {
        if (!$('.app-load').length) {
            $('body').append('<div class="app-load"></div>');
            app_tool.callback(func);
        }
    },
    // 删除动画
    loaded: function() {
        if ($('.app-load').length) {
            $('.app-load').remove();
        }
    },
    // 回调函数
    callback: function(func) {
        if (typeof(func) === 'function') {
            func();
        }
    }
}

// 侧边
var app_slide = {
    show: function() {
        var animationEnd = 'webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend';
        $('.app-slide-bg').fadeIn(300);
        $('.app-slide').show().addClass(' animated slideInLeft').one(animationEnd, function() {
            $('.app-slide-bg').click(function() {
                $(this).fadeOut(300);
                $('.app-slide').removeClass('slideInLeft').addClass('slideOutLeft').one(animationEnd, function() {
                    $('.app-slide').hide().removeClass(' animated slideOutLeft');
                });
            });
        });
    }
}

//alert(navigator.userAgent);