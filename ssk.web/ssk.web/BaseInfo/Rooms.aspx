<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Rooms.aspx.cs" Inherits="ssk.web.BaseInfo.Rooms" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>会议室管理</title>
    <link rel="stylesheet" type="text/css" href="../jquery-easyui-1.5.5.2/themes/metro/easyui.css" />
    <link rel="stylesheet" type="text/css" href="../jquery-easyui-1.5.5.2/themes/icon.css" />
    <link rel="stylesheet" type="text/css" href="../jquery-easyui-1.5.5.2/themes/color.css" />
    <script type="text/javascript" src="../jquery-easyui-1.5.5.2/jquery.min.js"></script>
    <script type="text/javascript" src="../jquery-easyui-1.5.5.2/jquery.easyui.min.js"></script>
    <script src="../JsControl/DateTimeFormat/DateFormat.js" type="text/javascript"></script>
    <script type="text/javascript" language="javascript">

        var _ExecType = "0";

        $(document).ready(function () {



            var _UserID = '<%=Session["UserID"] %>';

            if (_UserID.length == 0) {
                var login_url = "http://" + window.location.host + "/Login.aspx";
                window.top.location.href = login_url;
                return false;
            }

            initData();

        });

        function initData() {
            $("#datagrid_room").datagrid({
                singleSelect: true,
                nowrap: true,
                autoRowHeight: false,
                striped: true,
                url: "Rooms.aspx?Oper=load_all_data"
            });
        }

        function doSearch(value, name) {
            $("#datagrid_room").datagrid("load", "Rooms.aspx?Oper=load_all_data&no=" + value);
        }

        var add = function () {

            $("#ckbTY").removeAttr("checked");
            $("#ckbVideo").removeAttr("checked");
            $("#ckbPrinter").removeAttr("checked");
            $("#ckbPhone").removeAttr("checked");
            $("#ckbBB").removeAttr("checked");

            _ExecType = "0";
            $("#txtRoomName").val("");
            $("#txtLocation").val(""); 
            $("#txtMemberQty").val("");
            $("#dialog_room").dialog("open");
        }


        var edit = function () {
            _ExecType = "1";

            $("#ckbTY").removeAttr("checked");
            $("#ckbVideo").removeAttr("checked");
            $("#ckbPrinter").removeAttr("checked");
            $("#ckbPhone").removeAttr("checked");
            $("#ckbBB").removeAttr("checked");

            var row = GetSelected();
            if (row == null) {
                return;
            }


            if (row.TYY == "1") {
                $("#ckbTY").prop("checked", true);
            } 

            if (row.VIDEO == "1") {
                $("#ckbVideo").prop("checked", true);
            }

            if (row.PRINTER == "1") {
                $("#ckbPrinter").prop("checked", true);
            }

            if (row.PHONE == "1") {
                $("#ckbPhone").prop("checked", true);
            }

            if (row.BB == "1") {
                $("#ckbBB").prop("checked", true);
            }

            $("#txtRoomName").val(row.ROOM_NO);
            $("#txtLocation").val(row.LOCATION);
            $("#txtMemberQty").val(row.MEMBER_QTY);
            $("#dialog_room").dialog("open");
        }

        var save = function () {
            var _no = $.trim($("#txtRoomName").val());
            var _location = $.trim($("#txtLocation").val());

            var _touying = "0";
            var _video = "0";
            var _printer = "0";
            var _phone = "0";
            var _bb = "0";

            if ($("#ckbTY").is(":checked")) {
                _touying = "1";
            }
            if ($("#ckbVideo").is(":checked")) {
                _video = "1";
            }
            if ($("#ckbPrinter").is(":checked")) {
                _printer = "1";
            }
            if ($("#ckbPhone").is(":checked")) {
                _phone = "1";
            }
            if ($("#ckbBB").is(":checked")) {
                _bb = "1";
            }

            var _qty = $.trim($("#txtMemberQty").val());

            if (_no.length == 0) {
                $.messager.alert("系统提示", "请输入会议室编号！", "error");
                return;
            }

            if (_location.length == 0) {
                $.messager.alert("系统提示", "请输入会议室所处位置！", "error");
                return;
            }

            if (_qty.length == 0) {
                $.messager.alert("系统提示", "请输入有效的会议室可容纳人数！", "error");
                return;
            }
            
            $.ajax({
                type: "post",
                url: "Rooms.aspx?Oper=save",
                data: { ExecType: _ExecType, Name: _no, Location: _location, TYY: _touying, BB: _bb, Phone: _phone, Video: _video, Printer: _printer, Qty: _qty },
                dataType: "json",
                cache: false,
                success: function (data) {
                    if (data.error == 1) {
                        $.messager.alert("系统提示", data.msg, "error");
                    }

                    initData();
                    $("#dialog_room").dialog("close");
                }
            });


        }


        var del = function () {
            var row = GetSelected();
            if (row == null) {
                return;
            }
            var _no = row.ROOM_NO;

            $.messager.confirm('系统提示', '确定需要删除选中的数据吗？',
             function (isok) {
                 if (isok) {
                     $.ajax({
                         type: "post",
                         url: "Rooms.aspx?Oper=del",
                         data: { Name: _no },
                         cache: false,
                         dataType: "json",
                         success: function (data) {
                             if (data.error == 1) {
                                 $.messager.alert("系统提示", data.msg, "error");
                             }

                             initData();
                             $("#dialog_room").dialog("close");
                         }
                     });
                 }
             });
        }



        function GetSelected() {
            var row = $("#datagrid_room").datagrid("getSelected");
            if (row == null) {
                $.messager.alert("系统提示", "请先选中您要操作的行！", "warning");
                return null;
            }
            return row;
        }


        //-----------------状态图标------------------
        function showImg(value, row) {
            var str = '';
            if (value == '1') {
                str = '<img src="../Images/drop-yes.gif" alt="Pass"/>';
            } else {
                str = '<img src="../Images/no.png" alt="Fail"/>';
            }
            return str;
        }

    </script>
</head>
<body>
    <table id="datagrid_room" class="easyui-datagrid" data-options="rownumbers:true,fit:true,border:true,
singleSelect:false,toolbar:'#toolbar_room',showHeader:true,pagination:true">
        <thead>
            <tr>
                <th data-options="field:'ROOM_NO',width:120">
                    编号
                </th>
                <th data-options="field:'LOCATION', width:110">
                    位置(厂区)
                </th>
                <th data-options="field:'MEMBER_QTY', width:100">
                    容纳人数
                </th>
                <th data-options="field:'TYY',width:80,align:'center',
                        formatter:showImg">
                    投影仪
                </th>
                <th data-options="field:'VIDEO',width:80,align:'center',
                        formatter:showImg">
                    视频电话
                </th>
                <th data-options="field:'PHONE',width:80,align:'center',
                        formatter:showImg">
                    国内外电话
                </th>
                <th data-options="field:'PRINTER',width:80,align:'center',
                        formatter:showImg">
                    打印机
                </th>
                 <th data-options="field:'BB',width:80,align:'center',
                        formatter:showImg">
                    电子白板
                </th>
                <th data-options="field:'CREATE_TIME', width:200,formatter: formatDatebox">
                    创建时间
                </th>
                <%-- <th data-options="field:'STATUS',width:80,align:'center',
                        formatter:showImg">
                    状态
                </th>--%>
            </tr>
        </thead>
        <tbody>
        </tbody>
    </table>
    <div id="toolbar_room" style="padding: 4px">
        <a href="javascript:add()" class="easyui-linkbutton" iconcls="icon-add" plain="true">
            增加</a> <a href="javascript:edit()" class="easyui-linkbutton" iconcls="icon-edit"
                plain="true">修改</a><a href="javascript:del()" class="easyui-linkbutton" iconcls="icon-remove"
                    plain="true">删除 </a>
        <div style="float: right; padding-top: 2px">
            <input class="easyui-searchbox" id="txtSearch" data-options="prompt:'输入搜索的内容，按Enter执行',menu:'#mm',searcher:doSearch"
                style="width: 350px"></input>
            <div id="mm">
                <div data-options="iconCls:'icon-ok'">
                    编号</div>
            </div>
        </div>
    </div>
    <div id="dialog_room" class="easyui-dialog" title="增加/修改" style="width: 400px; overflow: hidden;
        height: 380px; padding: 5px" data-options="	modal: true,	closed: true, 		
				buttons: [{
					text:'Ok',
					iconCls:'icon-ok',
					handler:function(){
						save();
					}
				},{
					text:'Cancel',
                    iconCls:'icon-cancel',
					handler:function(){
						$('#dialog_room').dialog('close');
					}
				}]
			">
        <table style="height: 100px; width: 425px">
            <tr>
                <td style="font-weight: bold; width: 80px">
                    名称
                </td>
            </tr>
            <tr>
                <td>
                    <input type="text" id="txtRoomName" style="width: 300px;" /><span style="color: red">*</span>
                </td>
            </tr>
            <tr>
                <td style="font-weight: bold; width: 80px">
                    位置
                </td>
            </tr>
            <tr>
                <td>
                    <input type="text" id="txtLocation" style="width: 300px;" /><span style="color: red">*</span>
                </td>
            </tr>
            <tr>
                <td style="font-weight: bold; width: 80px">
                    容纳人数
                </td>
            </tr>
            <tr>
                <td>
                    <input type="text" id="txtMemberQty" style="width: 300px;" /><span style="color: red">*</span>
                </td>
            </tr>
            <tr>
                <td style="font-weight: bold; width: 80px">
                    资源
                </td>
            </tr>
            <tr>
                <td>
                    <span>
                        <input id="ckbTY" type="checkbox" />投影仪</span>&nbsp;&nbsp;&nbsp; <span>
                            <input id="ckbVideo" type="checkbox" />视频电话</span>&nbsp;&nbsp;&nbsp; <span>
                                <input id="ckbPrinter" type="checkbox" />打印机</span>&nbsp;&nbsp;&nbsp;
                    <span>
                        <input id="ckbPhone" type="checkbox" />国内外电话</span>&nbsp;&nbsp;&nbsp;  
                             
                </td>
            </tr>
              <tr>
                <td>
                    <span>
                        <input id="ckbBB" type="checkbox" />电子白板</span>&nbsp;&nbsp;&nbsp;
                </td>
            </tr>
            
        </table>
    </div>
    <%--编辑对话框：结束 --%>
</body>
</html>
