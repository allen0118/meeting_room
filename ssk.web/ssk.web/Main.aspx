<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Main.aspx.cs" Inherits="ssk.web.Main" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <link rel="stylesheet" type="text/css" href="../Styles/button.css" />

    <link href="Styles/left_menu.css" rel="stylesheet" type="text/css" />
    <link rel="stylesheet" type="text/css" href="jquery-easyui-1.5.5.2/themes/metro/easyui.css" />
    <link rel="stylesheet" type="text/css" href="jquery-easyui-1.5.5.2/themes/icon.css" />
    <link rel="stylesheet" type="text/css" href="jquery-easyui-1.5.5.2/themes/color.css" />
    <script type="text/javascript" src="jquery-easyui-1.5.5.2/jquery.min.js"></script>
    <script type="text/javascript" src="jquery-easyui-1.5.5.2/jquery.easyui.min.js"></script>
    <script type="text/javascript" language="javascript">

        var _menus = "";
        $(document).ready(function () {


            var _UserID = '<%=Session["UserID"] %>';

            if (_UserID.length == 0) {
                window.location.href = "Login.aspx";
                return false;
            }

            $.ajax({
                type: "GET",
                url: "Main.aspx?Oper=get_menus",
                dataType: "json",
                data: { UserID: _UserID },
                async: false,
                success: function (data) {
                    _menus = data;
                }
            });

            addNav(_menus);
            InitLeftMenu();

            tabClose();
            tabCloseEven();


            $("#menu_box").accordion({
                animate: false
            });
        });


        //采用正则表达式获取地址栏参数
        function GetQueryString(name) {
            var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
            var r = window.location.search.substr(1).match(reg);
            if (r != null) return unescape(r[2]); return null;
        }






        //创建左侧的菜单栏
        function addNav(data) {
            $.each(data, function (i, sm) {
                var menulist = "";
                menulist += '<ul>';
                $.each(sm.MENUS, function (j, o) {
                    menulist += '<li><div><a myico="' + o.ICON + '" ref="' + o.MENU_ID + '" href="#" rel="'
					+ o.URL + '" ><span  class="icon ' + o.ICON
					+ '" >&nbsp;</span><span class="nav">' + o.MENU_NAME
					+ '</span></a></div></li> ';
                });
                menulist += '</ul>';

                $("#menu_box").accordion("add", {
                    title: sm.MENU_GROUP_NAME,
                    content: menulist,
                    iconCls: 'icon ' + sm.ICON
                });

            });

            var pp = $("#menu_box").accordion("panels");
            var t = pp[0].panel("options").title;
            $("#menu_box").accordion("select", t);

        }

        //初始化左侧菜单栏
        function InitLeftMenu() {
            hoverMenuItem();
            $("#menu_box li a").click("click", function () {
                //$('#abc12').click('click', function () {
                var tabTitle = $(this).children(".nav").text();
                var url = $(this).attr("rel");
                var menuid = $(this).attr("ref"); //这个菜单ID传入URL中.

                //var icon = getIcon(menuid, icon);
                var icon = $(this).attr("myico");
                //                addTab(tabTitle, url, icon, menuid);
                addTab(tabTitle, url + "?mid=" + menuid, icon);
                $("#menu_box li div").removeClass("selected");
                $(this).parent().addClass("selected");
            });
        }

        //菜单项鼠标Hover         
        function hoverMenuItem() {
            $(".easyui-accordion").find("a").hover(function () {
                $(this).parent().addClass("hover");
            }, function () {
                $(this).parent().removeClass("hover");
            });
        }

        // 获取左侧导航的图标
        function getIcon(menuid) {
            var icon = "icon";
            $.each(_menus, function (i, n) {
                $.each(n, function (j, o) {
                    $.each(o.menus, function (k, m) {
                        if (m.menuid == menuid) {
                            icon += m.icon;
                            return false;
                        }
                    });
                });
            });
            return icon;
        }

        function Clearnav() {
            var pp = $("#menu_box").accordion("panels");

            $.each(pp, function (i, n) {
                if (n) {
                    var t = n.panel("options").title;
                    $("#menu_box").accordion("remove", t);
                }
            });

            pp = $("#menu_box").accordion("getSelected");
            if (pp) {
                var title = pp.panel("options").title;
                $("#menu_box").accordion("remove", title);
            }
        }

    

        function addTab(subtitle, url, icon) {
            if (!$("#tabs").tabs("exists", subtitle)) {
                $("#tabs").tabs("add", {
                    title: subtitle,
                    content: createFrame(url),
                    closable: true,
                    icon: icon
                });
            } else {
                $("#tabs").tabs("select", subtitle);
                $("#mm-tabupdate").click();
            }
            tabClose();
        }

        function createFrame(url) {
            var s = '<iframe scrolling="auto" frameborder="0"  src="' + url + '" style="width:100%;height:100%;"></iframe>';
            return s;
        }

        function tabClose() {
            /* 双击关闭TAB选项卡 */
            $(".tabs-inner").dblclick(function () {
                var subtitle = $(this).children(".tabs-closable").text();
                $("#tabs").tabs("close", subtitle);
            });
            /* 为选项卡绑定右键 */
            $(".tabs-inner").bind("contextmenu", function (e) {
                $("#mm").menu("show", {
                    left: e.pageX,
                    top: e.pageY
                });

                var subtitle = $(this).children(".tabs-closable").text();

                $("#mm").data("currtab", subtitle);
                $("#tabs").tabs("select", subtitle);
                return false;
            });
        }

        // 绑定右键菜单事件
        function tabCloseEven() {
            // 刷新
            $("#mm-tabupdate").click(function () {
                var currTab = $("#tabs").tabs("getSelected");
                var url = $(currTab.panel("options").content).attr("src");
                $("#tabs").tabs("update", {
                    tab: currTab,
                    options: {
                        content: createFrame(url)
                    }
                });
            });
            // 关闭当前
            $("#mm-tabclose").click(function () {
                var currtab_title = $("#mm").data("currtab");
                $("#tabs").tabs("close", currtab_title);
            });
            // 全部关闭
            $("#mm-tabcloseall").click(function () {
                $(".tabs-inner span").each(function (i, n) {
                    var t = $(n).text();
                    $("#tabs").tabs("close", t);
                });
            });
            // 关闭除当前之外的TAB
            $("#mm-tabcloseother").click(function () {
                $("#mm-tabcloseright").click();
                $("#mm-tabcloseleft").click();
            });
            // 关闭当前右侧的TAB
            $("#mm-tabcloseright").click(function () {

                var nextall = $(".tabs-selected").nextAll();
                if (nextall.length == 0) {
                    alert("后边没有啦~~");
                    return false;
                }
                nextall.each(function (i, n) {
                    var t = $("a:eq(0) span", $(n)).text();
                    $("#tabs").tabs("close", t);
                });
                return false;
            });
            // 关闭当前左侧的TAB
            $("#mm-tabcloseleft").click(function () {
                var prevall = $(".tabs-selected").prevAll();
                if (prevall.length == 0) {
                    alert("到头了，前边没有啦~~");
                    return false;
                }
                prevall.each(function (i, n) {
                    var t = $("a:eq(0) span", $(n)).text();
                    $("#tabs").tabs("close", t);
                });
                return false;
            });
        }

        function _loginOut() {

            $.messager.confirm('系统提示', '确定需要退出系统吗？',
             function (isok) {
                 if (isok) {

                     $.ajax({
                         type: "post",
                         async: false,
                         url: "Main.aspx?Oper=clear_session&key=" + Math.random(),
                         success: function (data) { }
                     });

                     var login_url = "http://" + window.location.host + "/Login.aspx";
                     window.top.location.href = login_url;
                     return false;
                 }
             });
        }

 

    </script>
</head>
<body class="easyui-layout" style="overflow-y: hidden" fit="true" scroll="no">
    <noscript>
        <div style="position: absolute; z-index: 100000; height: 2046px; top: 0px; left: 0px;
            width: 100%; background: white; text-align: center;">
            <img src="images/noscript.gif" alt='抱歉，请开启脚本支持！' />
        </div>
    </noscript>
    
    <div data-options="region:'north',border:false" style="height: 60px; background-color: #005086;
        font-size: 24px; padding-left: 10px; line-height: 60px; color: #fff; font-family: 微软雅黑;
        overflow: hidden">

        <span>CRBS-会议室预约管理系统</span> <span style="float: right; margin-right: 20px; font-size: 13px;">
            <a data-options="iconCls:'icon-user'" class="easyui-linkbutton">欢迎
                <%=Session["UserID"] == null ? "" : Session["UserID"].ToString()%></a> <a href="javascript:void(0)"
                    onclick="_loginOut()" data-options="iconCls:'icon-cancel'" class="easyui-linkbutton">
                    退出系统</a> </span>
    </div>
    <div region="south" split="true" style="height: 30px; background: #D2E0F2;">
        <div class="footer">
            allen0717@163.com</div>
    </div>
    <div region="west" split="true" title="导航菜单" style="width: 180px;" id="west">
        <div id="menu_box" class="easyui-accordion" fit="true" border="false">
            <!--  导航内容 -->
        </div>
    </div>
    <div id="mainPanle" region="center" style="background: #eee; overflow-y: hidden">
        <div id="tabs" class="easyui-tabs" fit="true" border="false">
            <div title="欢迎使用" style="padding: 20px; overflow: hidden; color: red;">
            </div>
        </div>
    </div>
    <div id="mm" class="easyui-menu" style="width: 150px;">
        <div id="mm-tabupdate">
            刷新</div>
        <div class="menu-sep">
        </div>
        <div id="mm-tabclose">
            关闭</div>
        <div id="mm-tabcloseall">
            全部关闭</div>
        <div id="mm-tabcloseother">
            除此之外全部关闭</div>
        <div class="menu-sep">
        </div>
        <div id="mm-tabcloseright">
            当前页右侧全部关闭</div>
        <div id="mm-tabcloseleft">
            当前页左侧全部关闭</div>
        <div class="menu-sep">
        </div>
        <div id="mm-exit">
            退出</div>
    </div>
</body>
</html>
