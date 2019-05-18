<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="upload_users.aspx.cs" Inherits="ssk.web.BaseInfo.upload_users" %>

 

<link href="../jquery-easyui-1.5.5.2/themes/metro/easyui.css" rel="stylesheet" type="text/css" />
<link href="../jquery-easyui-1.5.5.2/themes/icon.css" rel="stylesheet" type="text/css" />
<link href="../jquery-easyui-1.5.5.2/themes/color.css" rel="stylesheet" type="text/css" />
<script src="../jquery-easyui-1.5.5.2/jquery.min.js" type="text/javascript"></script>
<script src="../jquery-easyui-1.5.5.2/jquery.easyui.min.js" type="text/javascript"></script>

<div style="padding: 20px; height: auto; font-size: 13px;">
    <form name="form2" enctype="multipart/form-data" method="post" style="margin:0;padding:0;">
        
        <input name="upload_file" class="easyui-filebox" label="请选择文件:" labelposition="top" data-options="prompt:'选择...'" style="width: 100%">
        <input name="labelid" type="hidden" value="<%=Request["lid"] == null ? "" : Request["lid"] %>" />
        <input name="pid" type="hidden" value="<%=Request["pid"] == null ? "" : Request["pid"] %>" />
        <input name="version" type="hidden" value="<%=Request["version"] == null ? "0" : Request["version"] %>" />
        <input class="upload_filename" name="upload_filename" type="hidden" value="" />
        <input class="upload_submitkey" name="submitkey" type="hidden" value="0" />
    </form>    
    <span  style="color:red">注意：文件大小不能超过20M。</span>
</div>
<div style="margin: 10px 20px; text-align: right;">
    <a href="javascript:upload(this)" class="easyui-linkbutton" data-options="iconCls:'icon-ok'">上传</a>    
</div>
<script type="text/javascript"> 

    //关闭弹窗
    function close() {
        window.parent.sys_frmprojectlabels_showexport_close();
    }

    function upload(obj) { 
        try { 
            window.parent.sys_showloadingmsg(); 
           
        } catch (e) {
            alert(e.message);
        }
               
        $(".upload_submitkey").val(1);
        var file = $(".easyui-filebox").textbox("getValue");
        $(".upload_filename").val(file);
        $(document.getElementsByTagName("form")).submit();
        $(obj).linkbutton("disabled");
    }
</script>
<% 
    if (this.resutl[1] == "") return;
    Response.Write("<script>window.parent.sys_closeloadingmsg();window.parent.sys_frmprojectdocs_showexport_alert('" + resutl[0] + "'," + resutl[1] + ")</script>");
%>