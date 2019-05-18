<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Users.aspx.cs" Inherits="ssk.web.BaseInfo.Users" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>用户管理</title>
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
            $("#datagrid_user").datagrid({
                singleSelect: true,
                nowrap: true,
                autoRowHeight: false,
                striped: true,
                url: "Users.aspx?Oper=load_all_data"
            });
        }

        var add = function () {
            _ExecType = "0";          
            $("#txtUserID").val("");
            $("#txtUserName").val("");
            $("#txtUserPwd").val("");
            $("#txtUserPwd2").val("");
            $("#txtPhone").val("");
            $("#txtEmail").val("");
            $("#txtDep").val("");

            $("#dialog_user").dialog("open");
        }


        var edit = function () { 
            var row = GetSelected();
            if (row == null) {
                return;
            }

            _ExecType = "1";

            $("#txtUserID").val(row.USR_ID);
            $("#txtUserName").val(row.USR_NAME);
            $("#txtUserPwd").val(row.USR_PWD);
            $("#txtUserPwd2").val(row.USR_PWD);
            $("#txtDep").val(row.DEP_NAME);
            $("#txtPhone").val(row.PHONE);
            $("#txtEmail").val(row.EMAIL);
            $("#dialog_user").dialog("open");
        }


        var save = function () {

            var _user_id = $.trim($("#txtUserID").val());
            var _user_name = $.trim($("#txtUserName").val());
            var _user_pwd = $.trim($("#txtUserPwd").val());
            var _user_pwd2 = $.trim($("#txtUserPwd2").val());
            var _user_phone = $.trim($("#txtPhone").val());
            var _user_email = $.trim($("#txtEmail").val());
            var _user_dep = $.trim($("#txtDep").val());

          
            if (_user_id.length == 0) {
                $.messager.alert("系统提示", "用户ID不可为空！", "error");
                return;
            }

            if (_user_pwd != _user_pwd2) {
                $.messager.alert("系统提示", "两次密码输入不一致！", "error");
                return;
            }

            if (_user_phone.length == 0) {
                $.messager.alert("系统提示", "联系电话不可为空！", "error");
                return;
            }


            $.ajax({
                type: "post",
                url: "Users.aspx?Oper=save",
                data: { ExecType: _ExecType, Name: _user_name, UID: _user_id, Pwd: _user_pwd, Phone: _user_phone, Email: _user_email, Dep: _user_dep },
                dataType: "json",
                cache: false,
                success: function (data) {
                    if (data.error == 1) {
                        $.messager.alert("系统提示", data.msg, "error");
                    }
                    initData();
                    $("#dialog_user").dialog("close");
                }
            });
        }


        var del = function () {
            var row = GetSelected();
            if (row == null) {
                return;
            }
            var _uid = row.USR_ID;

            $.messager.confirm('系统提示', '确定需要删除选中的数据吗？',
             function (isok) {
                 if (isok) {
                     $.ajax({
                         type: "post",
                         url: "Users.aspx?Oper=del",
                         data: { UID: _uid },
                         cache:false,
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
            var row = $("#datagrid_user").datagrid("getSelected");
            if (row == null) {
                $.messager.alert("系统提示", "请先选中您要操作的行！", "warning");
                return null;
            }
            return row;
        }

         

        function doSearch(value, name) {
            $("#datagrid_user").datagrid("load", "Users.aspx?Oper=load_all_data&no=" + value);
        }

        //////////////////////////////////////////////////////////////////////////////////////////////////////


        //导入文件 弹窗导入窗口
        function sys_frmprojectdocs_showexport() {
            $('#dialog_frmprojectdocs_showexport').dialog("open");
            $('#dialog_frmprojectdocs_showexport').find("iframe")[0].src = "upload_users.aspx?t=" + Math.random();
        }


        function sys_showloadingmsg() {
            $.messager.progress({
                title: "系统提示",
                msg: "请稍后，正在上传文件..."
            });
        }

        //关闭进度提示
        function sys_closeloadingmsg() {
            $.messager.progress("close");
        }
         

    </script>
</head>
<body>
    <table id="datagrid_user" class="easyui-datagrid" data-options="rownumbers:true,fit:true,border:true,
singleSelect:false,toolbar:'#toolbar_user',showHeader:true,pagination:true">
        <thead>
            <tr>
                <th data-options="field:'USR_ID',width:120">
                    用户ID
                </th>
                <th data-options="field:'USR_NAME', width:110">
                    用户名
                </th>
                <th data-options="field:'DEP_NAME', width:100">
                    部门
                </th>
                <th data-options="field:'PHONE',width:130">
                    电话
                </th>
                <th data-options="field:'EMAIL',width:230">
                    邮件
                </th>
                <th data-options="field:'CREATE_TIME', width:230,formatter: formatDatebox">
                    创建时间
                </th>
            </tr>
        </thead>
        <tbody>
        </tbody>
    </table>
    <div id="toolbar_user" style="padding: 4px">
        <a href="javascript:add()" class="easyui-linkbutton" iconcls="icon-add" plain="true">
            增加</a> <a href="javascript:edit()" class="easyui-linkbutton" iconcls="icon-edit"
                plain="true">修改</a><a href="javascript:del()" class="easyui-linkbutton" iconcls="icon-remove"
                    plain="true">删除 </a>

                    <a href="javascript:sys_frmprojectdocs_showexport()" class="easyui-linkbutton" iconcls="icon-excel"
                    plain="true">导入 </a>

        <div style="float: right; padding-top: 2px">
            <input class="easyui-searchbox" id="txtSearch" data-options="prompt:'输入搜索的内容，按Enter执行',menu:'#mm',searcher:doSearch"
                style="width: 350px"></input>
            <div id="mm">
                <div data-options="iconCls:'icon-ok'">
                    用户ID/用户名</div>
            </div>
        </div>
    </div>
    <div id="dialog_user" class="easyui-dialog" title="增加/修改" style="width: 400px; overflow: hidden;
        height: 500px; padding: 5px" data-options="	modal: true,	closed: true, 		
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
						$('#dialog_user').dialog('close');
					}
				}]
			">
        <table style="height: 100px; width: 425px">
            <tr>
                <td style="font-weight: bold; width: 80px">
                    用户ID
                </td>
            </tr>
            <tr>
                <td>
                    <input type="text" id="txtUserID" style="width: 300px; height: 25px;" /><span style="color: red">*</span>
                </td>
            </tr>
            <tr>
                <td style="font-weight: bold; width: 80px">
                    用户名
                </td>
            </tr>
            <tr>
                <td>
                    <input type="text" id="txtUserName" style="width: 300px; height: 23px;" /><span style="color: red">*</span>
                </td>
            </tr>
            <tr>
                <td style="font-weight: bold; width: 80px">
                    登录密码
                </td>
            </tr>
            <tr>
                <td>
                    <input type="password" id="txtUserPwd" style="width: 300px; height: 23px;" /><span
                        style="color: red">*</span>
                </td>
            </tr>
            <tr>
                <td style="font-weight: bold; width: 80px">
                    确认密码
                </td>
            </tr>
            <tr>
                <td>
                    <input type="password" id="txtUserPwd2" style="width: 300px; height: 23px;" /><span
                        style="color: red">*</span>
                </td>
            </tr>
            <tr>
                <td style="font-weight: bold; width: 80px">
                    部门
                </td>
            </tr>
            <tr>
                <td>
                    <input type="text" id="txtDep" style="width: 300px; height: 23px;" /><span style="color: red">*</span>
                </td>
            </tr>
            <tr>
                <td style="font-weight: bold; width: 80px">
                    电话
                </td>
            </tr>
            <tr>
                <td>
                    <input type="text" id="txtPhone" style="width: 300px; height: 23px;" /><span style="color: red">*</span>
                </td>
            </tr>
            <tr>
                <td style="font-weight: bold; width: 80px">
                    邮件
                </td>
            </tr>
            <tr>
                <td>
                    <input type="text" id="txtEmail" style="width: 300px; height: 23px;" /><span style="color: red">*</span>
                </td>
            </tr>
        </table>
    </div>


    <div id="dialog_frmprojectdocs_showexport" class="easyui-dialog" title="导入模板文件" style="width: 400px; height: 300px; overflow: hidden"
                data-options="	modal: true,	closed: true">
                <iframe frameborder="0" style="width: 400px; height: 300px;"></iframe>
</body>
</html>
