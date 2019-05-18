<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EmailConfig.aspx.cs" Inherits="ssk.web.BaseInfo.EmailConfig" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link rel="stylesheet" type="text/css" href="../jquery-easyui-1.5.5.2/themes/metro/easyui.css" />
    <link rel="stylesheet" type="text/css" href="../jquery-easyui-1.5.5.2/themes/icon.css" />
    <link rel="stylesheet" type="text/css" href="../jquery-easyui-1.5.5.2/themes/color.css" />
    <script type="text/javascript" src="../jquery-easyui-1.5.5.2/jquery.min.js"></script>
    <script type="text/javascript" src="../jquery-easyui-1.5.5.2/jquery.easyui.min.js"></script>
    <script type="text/javascript" src="../JsControl/DateTimeFormat/DateFormat.js"></script>
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
            $("#datagrid_email").datagrid({
                singleSelect: true,
                nowrap: true,
                autoRowHeight: false,
                striped: true,
                url: "EmailConfig.aspx?Oper=load_all_data"
            });
        }


        var add = function () {
            _ExecType = "0";
            $("#txtType").val("");
            $("#txtEmailAddress").val("");
            $("#txtPassword").val("");
            $("#txtSmtp").val("");

            $("#dialog_email").dialog("open");
        }


        var edit = function () {
            var row = GetSelected();
            if (row == null) {
                return;
            }

            _ExecType = "1";

            $("#txtType").val(row.FTYPE);
            $("#txtEmailAddress").val(row.EMAIL);
            $("#txtPassword").val(row.PWD);
            $("#txtSmtp").val(row.SMTP_SERVER);
            $("#dialog_email").dialog("open");
        }


        var save = function () {

            var _type = $.trim($("#txtType").val());
            var _email = $.trim($("#txtEmailAddress").val());
            var _pwd = $.trim($("#txtPassword").val());
            var _smtp = $.trim($("#txtSmtp").val());

            if (_type.length == 0) {
                $.messager.alert("系统提示", "邮件类型不可为空", "error");
                return;
            }

            if (_smtp.length == 0) {
                $.messager.alert("系统提示", "Smtp服务器地址不可为空", "error");
                return;
            }


            if (_email.length == 0) {
                $.messager.alert("系统提示", "发件人地址不可为空！", "error");
                return;
            }

            if (_pwd.length == 0) {
                $.messager.alert("系统提示", "客户端授权码不可为空！", "error");
                return;
            }


            $.ajax({
                type: "post",
                url: "EmailConfig.aspx?Oper=save",
                data: { ExecType: _ExecType, type: _type, email: _email, Pwd: _pwd,smtp:_smtp },
                dataType: "json",
                cache: false,
                success: function (data) {
                    if (data.error == 1) {
                        $.messager.alert("系统提示", data.msg, "error");
                    }
                    initData();
                    $("#dialog_email").dialog("close");
                }
            });
        }



        var del = function () {
            var row = GetSelected();
            if (row == null) {
                return;
            }
            var _fid = row.FID;

            $.messager.confirm('系统提示', '确定需要删除选中的数据吗？',
             function (isok) {
                 if (isok) {
                     $.ajax({
                         type: "post",
                         url: "EmailConfig.aspx?Oper=del",
                         data: { fid: _fid },
                         cache: false,
                         dataType: "json",
                         success: function (data) {
                             if (data.error == 1) {
                                 $.messager.alert("系统提示", data.msg, "error");
                             }
                             initData();
                         }
                     });
                 }
             });
        }


        function GetSelected() {
            var row = $("#datagrid_email").datagrid("getSelected");
            if (row == null) {
                $.messager.alert("系统提示", "请先选中您要操作的行！", "warning");
                return null;
            }
            return row;
        }

         

    </script>
</head>
<body>
    <table id="datagrid_email" class="easyui-datagrid" data-options="rownumbers:true,fit:true,border:true,
singleSelect:false,toolbar:'#toolbar_email',showHeader:true,pagination:true">
        <thead>
            <tr>
                <th data-options="field:'FID',width:80">
                    编号
                </th>
                <th data-options="field:'FTYPE',width:160">
                    邮件类型
                </th>
                <th data-options="field:'SMTP_SERVER',width:160">
                    SMTP服务器
                </th>
                <th data-options="field:'EMAIL', width:240">
                    发件人地址
                </th>
                <th data-options="field:'PWD', width:200">
                    客户端授权码
                </th>
                <th data-options="field:'CREATE_TIME', width:230,formatter: formatDatebox">
                    创建时间
                </th>
            </tr>
        </thead>
        <tbody>
        </tbody>
    </table>
    <div id="toolbar_email" style="padding: 4px">
        <a href="javascript:add()" class="easyui-linkbutton" iconcls="icon-add" plain="true">
            增加</a> <a href="javascript:edit()" class="easyui-linkbutton" iconcls="icon-edit"
                plain="true">修改</a><a href="javascript:del()" class="easyui-linkbutton" iconcls="icon-remove"
                    plain="true">删除 </a>
    </div>
    <div id="dialog_email" class="easyui-dialog" title="增加/修改" style="width: 400px; overflow: hidden;
        height: 330px; padding: 5px" data-options="	modal: true,	closed: true, 		
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
						$('#dialog_email').dialog('close');
					}
				}]
			">
        <table style="height: 100px; width: 425px">
            <tr>
                <td style="font-weight: bold; width: 80px">
                    类型
                </td>
            </tr>
            <tr>
                <td>
                    <input type="text" id="txtType" style="width: 300px; height: 23px;" placeholder="会议通知" /><span
                        style="color: red">*</span>
                </td>
            </tr>

             <tr>
                <td style="font-weight: bold; width: 80px">
                    SMTP地址
                </td>
            </tr>
            <tr>
                <td>
                    <input type="text" id="txtSmtp" style="width: 300px; height: 25px;" /><span
                        style="color: red">*</span>
                </td>
            </tr>

            <tr>
                <td style="font-weight: bold; width: 80px">
                    发件人地址
                </td>
            </tr>
            <tr>
                <td>
                    <input type="text" id="txtEmailAddress" style="width: 300px; height: 25px;" /><span
                        style="color: red">*</span>
                </td>
            </tr>
            <tr>
                <td style="font-weight: bold; width: 80px">
                    客户端授权码
                </td>
            </tr>
            <tr>
                <td>
                    <input type="text" id="txtPassword" style="width: 300px; height: 23px;" /><span style="color: red">*</span>
                </td>
            </tr>
        </table>
    </div>
</body>
</html>
