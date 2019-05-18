<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="ssk.web.Login" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <link rel="stylesheet" type="text/css" href="Styles/login_base.css" />
    <link rel="stylesheet" type="text/css" href="jquery-easyui-1.5.5.2/themes/metro/easyui.css" />
    <link rel="stylesheet" type="text/css" href="jquery-easyui-1.5.5.2/themes/icon.css" />
    <link rel="stylesheet" type="text/css" href="jquery-easyui-1.5.5.2/themes/color.css" />
    <script type="text/javascript" src="jquery-easyui-1.5.5.2/jquery.min.js"></script>
    <script type="text/javascript" src="jquery-easyui-1.5.5.2/jquery.easyui.min.js"></script>
    <style type="text/css">
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
        
        .img
        {
            max-width: 50%;
            max-height: 80%;
        }
        .style1
        {
            width: 60%;
        }
    </style>
    <script language="javascript" type="text/javascript">
        $(document).ready(function () {
            $("#btnLogin").click(function () {
                var _UserID = $.trim($("#txtUserID").val());
                var _UserPwd = $.trim($("#txtUserPwd").val());

                if (_UserID.length == 0 || _UserPwd.length == 0) {
                    return;
                }
                 

                $("#lblmessage").text("");
                $.ajax({
                    type: "post",
                    url: "Login.aspx?Oper=user_login",
                    dataType: "json",
                    data: { UserID: _UserID, UserPwd: _UserPwd },
                    success: function (data) {

                        //alert(data);

                        if (data.error == "1") {
                            $("#lblmessage").text(data.msg);
                        }
                        else {
                            window.location.href = "main.aspx";
                        }
                    }
                });

            });

            $("#txtUserID").keydown(function (e) {
                if (e.keyCode == 13) {
                    var _uid = $.trim($("#txtUserID").val());
                    if (_uid.length > 0) {
                        $("#txtUserPwd").select();
                    }
                }
            }); 

            $("#txtUserPwd").keydown(function (e) {
                if (e.keyCode == 13) {
                    var _pwd = $.trim($("#txtUserPwd").val());
                    if (_pwd.length > 0) {
                        $("#btnLogin").click();
                    }
                }
            });

        });
    </script>
</head>
<body>
    <div id="mydiv" class="mydiv">
        <table class="mydiv" border="1">
            <tr>
                <td>
                    <div class="panel loginbox">
                        <div class="text-center margin-big padding-big-top">
                            <h1>
                                CRBS-会议室预约管理系统</h1>
                        </div>
                        <div class="panel-body" style="padding: 30px; padding-bottom: 10px; padding-top: 10px;">
                            <div class="form-group">
                                <div class="field field-icon-right">
                                    <input type="text" class="input input-big" name="name" id="txtUserID" placeholder="登录账号"
                                        value="N0001" />
                                    <span class="icon icon-user margin-small"></span>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="field field-icon-right">
                                    <input type="password" class="input input-big" name="password" id="txtUserPwd" placeholder="登录密码"
                                        value="123456" />
                                    <span class="icon icon-key margin-small"></span>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="msg">
                                    <label id="lblmessage" style="color: #FF0000">
                                    </label>
                                </div>
                            </div>
                        </div>
                        <div style="padding: 30px;">
                            <input type="button" id="btnLogin" class="button button-block bg-main text-big input-big"
                                value="登录">
                        </div>
                    </div>
                </td>
            </tr>
        </table>
    </div>
</body>
</html>
