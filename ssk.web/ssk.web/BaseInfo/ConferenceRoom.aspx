<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ConferenceRoom.aspx.cs"
    Inherits="ssk.web.BaseInfo.ConferenceRoom" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <style>
        .mydiv
        {
            position: fixed;
            top: 50%;
            left: 50%;
            width: 65%;
            height: 55%;
            -webkit-transform: translateX(-50%) translateY(-50%);
            -moz-transform: translateX(-50%) translateY(-50%);
            -ms-transform: translateX(-50%) translateY(-50%);
            transform: translateX(-50%) translateY(-50%);
        }
    </style>
    <link rel="stylesheet" type="text/css" href="../Styles/button.css" />
    <link rel="stylesheet" type="text/css" href="../jquery-easyui-1.5.5.2/themes/metro/easyui.css" />
    <link rel="stylesheet" type="text/css" href="../jquery-easyui-1.5.5.2/themes/icon.css" />
    <link rel="stylesheet" type="text/css" href="../jquery-easyui-1.5.5.2/themes/color.css" />
    <script type="text/javascript" src="../jquery-easyui-1.5.5.2/jquery.min.js"></script>
    <script type="text/javascript" src="../jquery-easyui-1.5.5.2/jquery.easyui.min.js"></script>
    <script type="text/javascript" src="../JsControl/Calendar/laydate/laydate.js"></script>
    <script type="text/javascript" language="javascript">

        var _UserID = "";
        $(document).ready(function () {
            //initData();

            _UserID = '<%=Session["UserID"] %>';

            if (_UserID.length == 0) {
                var login_url = "http://" + window.location.host + "/Login.aspx";
                window.top.location.href = login_url;
                return false;
            }

            $("#datagrid_find_room").datagrid({
                //双击事件
                onDblClickRow: function (rowIndex, rowData) {
                    _select_room();
                }
            });

        });

        var _user_id_list = "";

        function initData() {
            $("#datagrid_find_room").datagrid({
                singleSelect: true,
                nowrap: true,
                autoRowHeight: false,
                striped: true,
                url: "ConferenceRoom.aspx?Oper=search_room"
            });
        }

        function chkDate(meeting_date) {

            var d = new Date;
            var today = new Date(d.getFullYear(), d.getMonth(), d.getDate());
            var reg = /\d+/g;
            var temp = meeting_date.match(reg);
            var foday = new Date(temp[0], parseInt(temp[1]) - 1, temp[2]);

            if (foday >= today) {
                return "ok";
            }
            else {
                return "ng";
            }

        }

        //打开会议室列表对话框
        var _show_room = function () {


            var _date = $("#txtDate").val();
            var _stime = $("#cmb_Start_Time").combobox("getText");
            var _etime = $("#cmb_End_Time").combobox("getText");

            if (_date.length == 0 || _stime.length == 0 || _etime.length == 0) {
                return;
            }



            if (chkDate(_date) == "ng") {
                $.messager.alert("系统提示", "不可选择小于今天的日期!", "warning");
                return;
            }

            if (_stime.substring(0, 2) > _etime.substring(0, 2)) {
                $.messager.alert("系统提示", "开始时间与结束时间错误,请重新选择!", "warning");
                return;
            }

            $.ajax({
                type: "get",
                cache: false,
                url: "ConferenceRoom.aspx?Oper=search_room",
                data: { Date: _date, Stime: _stime, Etime: _etime },
                dataType: "json",
                success: function (data) {
                    $("#datagrid_find_room").datagrid("loadData", data);
                }
            });


            $("#dialog_find").dialog("open");
        }

        //选择会议室
        var _select_room = function () {
            var row = GetSelected();
            if (row == null) {
                return;
            }
            $("#txtRoomNo").textbox("setValue", row.ROOM_NO);

            $("#txtMemberQty").textbox("setValue", row.MEMBER_QTY);
            $("#dialog_find").dialog("close");
        }

        //打开用户列表对话框
        var _show_user = function () {
            $("#datagrid_find_user").datagrid({
                singleSelect: true,
                nowrap: true,
                autoRowHeight: false,
                striped: true,
                url: "ConferenceRoom.aspx?Oper=search_user"
            });
            $("#dialog_find_user").dialog("open");
        }

        //选择用户
        var _select_user = function () {
            var checkedItems = $("#datagrid_find_user").datagrid("getChecked");
            var uids = [];
            var names = [];
            $.each(checkedItems, function (index, item) {
                uids.push(item.USR_ID);
                names.push(item.USR_NAME + "(" + item.DEP_NAME + ")");
            });
            _user_id_list = uids.join(",");

            _user_id_list = _user_id_list + "," + _UserID;
             
            var _user_name_list = names.join(",");





            //            if (_user_id_list.length == 0) {
            //                $.messager.alert("系统提示", "请选择参加会议的用户~~", "error");
            //                return;
            //            }
            $("#txtUserList").textbox("setText", _user_name_list);
            $("#dialog_find_user").dialog("close");
        }


        var book_room = function () {
            var _room = $("#txtRoomNo").textbox("getText");
            var _subject = $("#txtTitle").textbox("getText");
            var _sdate = $("#txtDate").val();
            var _stime = $("#cmb_Start_Time").combobox("getText");
            var _etime = $("#cmb_End_Time").combobox("getText");
            var _user_name_list = $("#txtUserList").textbox("getText");

            var _remrk = "";

            if ($("#ckbCF").is(":checked")) {
                _remrk = _remrk + "咖啡,";
            }
            if ($("#ckbSG").is(":checked")) {
                _remrk = _remrk + "水果,";
            }
            if ($("#ckbXH").is(":checked")) {
                _remrk = _remrk + "鲜花,";
            }
            if ($("#ckbPen").is(":checked")) {
                _remrk = _remrk + "激光笔,";
            }
            if ($("#ckbYu").is(":checked")) {
                _remrk = _remrk + "八爪鱼,";
            }


            if (_room.length == 0) {
                $.messager.alert("系统提示", "请选择会议室.", "error");
                return;
            }
            if (_subject.length == 0) {
                $.messager.alert("系统提示", "请输入会议主题.", "error");
                return;
            }
            if (_sdate.length == 0) {
                $.messager.alert("系统提示", "请选择会议日期.", "error");
                return;
            }
            if (_stime.length == 0) {
                $.messager.alert("系统提示", "请选择开始时间.", "error");
                return;
            }
            if (_etime.length == 0) {
                $.messager.alert("系统提示", "请选择结束时间.", "error");
                return;
            }
            var _req_desc = $("#txtReqDesc").textbox("getText");

            var options = $("#dialog_call").dialog("options");
            //options.buttons[0].disabled = "disabled";
            options.buttons[0].linkbutton("disable");

             

            $.ajax({
                type: "post",
                url: "ConferenceRoom.aspx?Oper=save",
                cache: false,
                data: { room: _room, req_user: _UserID, u_name_list: _user_name_list, sdate: _sdate, stime: _stime, etime: _etime, u_no_list: _user_id_list, req_desc: _req_desc, subject: _subject },
                dataType: "json",
                success: function (data) {
                    if (data.error == 1) {
                        $.messager.alert("系统提示", data.msg, "error");
                    }
                    else {
                        $.messager.alert("系统提示", data.msg, "info");
                        window.location.reload();
                        $("#txtTitle").textbox("setValue", "");
                        $("#txtDate").val("");
                        $("#cmb_Start_Time").val("");
                        $("#cmb_End_Time").val("");
                        $("#txtRoomNo").textbox("setValue", "");
                        $("#txtMemberQty").textbox("setValue", "");
                        $("#txtUserList").textbox("setValue", "");
                        $("#txtReqDesc").textbox("setValue", "");
                    }
                }
            });


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


        function GetSelected() {
            var row = $("#datagrid_find_room").datagrid("getSelected");
            if (row == null) {
                return null;
            }
            return row;
        }


    </script>
</head>
<body>
    <div id="dialog_call" class="easyui-dialog" title="预定" style="width: 70%; overflow: hidden;
        height: 500px; padding: 5px" data-options="	modal: true,	closed: false, 		
				buttons: [
                  {
					text:'OK',
					iconCls:'icon-ok',
					handler:function(){
						book_room();
					}
				} ,{
					text:'Cancel',
                    iconCls:'icon-cancel',
					handler:function(){
						$('#dialog_call').dialog('close');
					}
				}]
			">
        <table>
            <tr>
                <td style="width: 150px;">
                    <span style="font-weight: bold">主题</span>
                </td>
                <td colspan="3" style="width: 90%">
                    <input type="text" id="txtTitle" class="easyui-textbox" style="width: 100%; height: 31px;" />
                </td>
            </tr>
            <tr>
                <td style="height: 15px;">
                </td>
            </tr>
            <tr>
                <td style="width: 150px;">
                    <span style="font-weight: bold">日期</span>
                </td>
                <td colspan="3" style="width: 90%">
                    <input type="text" id="txtDate" style="width: 100%; height: 31px; font-size: medium;"
                        class="laydate-icon" onclick="laydate()" /><br />
                </td>
            </tr>
            <tr>
                <td style="height: 15px;">
                </td>
            </tr>
            <tr>
                <td style="width: 150px;">
                    <span style="font-weight: bold">开始时间</span>
                </td>
                <td class="style1">
                    <select id="cmb_Start_Time" class="easyui-combobox" name="dept" style="width: 277px;
                        height: 31px;" data-options="valueField:'id',textField:'name',url:'ConferenceRoom.aspx?Oper=load_times',editable: false,multiple:false,">
                    </select>
                </td>
                <td>
                    <span style="font-weight: bold">结束时间</span>
                </td>
                <td>
                    <select id="cmb_End_Time" class="easyui-combobox" name="dept" style="width: 277px;
                        height: 31px;" data-options="valueField:'id',textField:'name',url:'ConferenceRoom.aspx?Oper=load_times',editable: false,multiple:false,">
                    </select>
                </td>
            </tr>
            <tr>
                <td style="height: 15px;">
                </td>
            </tr>
            <tr>
                <td style="width: 150px;">
                    <span style="font-weight: bold">会议室编号</span>
                </td>
                <td class="style1">
                    <input type="text" id="txtRoomNo" class="easyui-textbox" style="width: 275px; height: 31px;"
                        data-options="disabled:true" />
                    <span>
                        <input type="button" id="btn" onclick="_show_room();" style="width: 69px;" class="button bg-main text-big input-big"
                            value="选择" />
                    </span>
                </td>
                <td>
                    <span style="font-weight: bold">容纳人数</span>
                </td>
                <td>
                    <input type="text" id="txtMemberQty" class="easyui-textbox" style="width: 275px;
                        height: 31px;" data-options="disabled:true" />
                </td>
            </tr>
            <tr>
                <td style="height: 15px;">
                </td>
            </tr>
            <tr>
                <td style="width: 150px;">
                    <span style="font-weight: bold">与会人员</span>
                </td>
                <td colspan="3">
                    <input type="text" class="easyui-textbox" data-options="multiline:true" id="txtUserList"
                        style="width: 90%; height: 60px;" />
                    <span>
                        <input type="button" id="btn_show_user" onclick="_show_user();" style="width: 69px;"
                            class="button bg-main text-big input-big" value="选择" />
                    </span>
                </td>
            </tr>
            <tr>
                <td style="height: 15px;">
                </td>
            </tr>
            <tr>
                <td style="width: 150px;">
                    <span style="font-weight: bold">会议资源</span>
                </td>
                <td colspan="3">
                    <span>
                        <input id="ckbCF" type="checkbox" />咖啡</span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <span>
                        <input id="ckbSG" type="checkbox" />水果</span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <span>
                        <input id="ckbXH" type="checkbox" />鲜花</span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <span>
                        <input id="ckbPen" type="checkbox" />激光笔</span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <span>
                        <input id="ckbYu" type="checkbox" />八爪鱼</span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    </span>
                    <input id="Checkbox1" type="checkbox" />矿泉水</span>
                </td>
            </tr>
            <tr>
                <td style="height: 15px;">
                </td>
            </tr>
            <tr>
                <td style="width: 150px;">
                    <span style="font-weight: bold">特别需求</span>
                </td>
                <td colspan="3">
                    <input type="text" id="txtReqDesc" class="easyui-textbox" data-options="multiline:true"
                        style="width: 100%; height: 80px;" />
                </td>
            </tr>
        </table>
    </div>
    <div id="dialog_find" class="easyui-dialog" title="选择会议室[可双击并选择]" style="width: 75%;
        overflow: hidden; height: 510px; padding: 5px" data-options="	modal: true,	closed: true, 		
				buttons: [
                  {
					text:'OK',
					iconCls:'icon-ok',
					handler:function(){
						_select_room();
					}
				},
                
                {
					text:'Cancel',
                    iconCls:'icon-cancel',
					handler:function(){
						$('#dialog_find').dialog('close');
					}
				}]
			">
        <table id="datagrid_find_room" class="easyui-datagrid" data-options="rownumbers:true,fit:true,border:true,
singleSelect:true,showHeader:true,pagination:false">
            <thead>
                <tr>
                    <th data-options="field:'ROOM_NO',width:120">
                        编号
                    </th>
                    <th data-options="field:'LOCATION', width:110">
                        位置(厂区)
                    </th>
                    <th data-options="field:'MEMBER_QTY', width:120">
                        容纳人数
                    </th>
                    <th data-options="field:'TYY',width:120,align:'center',
                        formatter:showImg">
                        投影仪
                    </th>
                    <th data-options="field:'VIDEO',width:120,align:'center',
                        formatter:showImg">
                        视频电话
                    </th>
                    <th data-options="field:'PHONE',width:120,align:'center',
                        formatter:showImg">
                        电话
                    </th>
                    <th data-options="field:'PRINTER',width:120,align:'center',
                        formatter:showImg">
                        打印机
                    </th>
                </tr>
            </thead>
            <tbody>
            </tbody>
        </table>
    </div>
    <div id="dialog_find_user" class="easyui-dialog" title="选择参与用户" style="width: 75%;
        overflow: hidden; height: 510px; padding: 5px" data-options="	modal: true,	closed: true, 		
				buttons: [
                  {
					text:'OK',
					iconCls:'icon-ok',
					handler:function(){
						_select_user();
					}
				},
                
                {
					text:'Cancel',
                    iconCls:'icon-cancel',
					handler:function(){
						$('#dialog_find_user').dialog('close');
					}
				}]
			">
        <table id="datagrid_find_user" class="easyui-datagrid" data-options="rownumbers:true,fit:true,border:true,
singleSelect:false,idField:'USR_ID',pagination:true,showHeader:true,checkOnSelect: true, selectOnCheck: false,columns: [[ 
				 {field:'ck',checkbox:true,title:'选择',width:100 },
				{field:'USR_ID',title:'用户ID',width:100,halign:'center'},
                {field:'USR_NAME',title:'用户名',width:150,halign:'center'},
                 {field:'DEP_NAME',title:'部门',width:140,halign:'center'},
                  {field:'PHONE',title:'联系电话',width:150,halign:'center'},
                  {field:'EMAIL',title:'电子邮件',width:220,halign:'center'}
                 
                  ]],">
        </table>
    </div>
</body>
</html>
