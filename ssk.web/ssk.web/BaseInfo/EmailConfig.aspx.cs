using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ssk.web.BaseInfo
{
    public partial class EmailConfig : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Request.QueryString["Oper"] != null)
            {
                switch (Request.QueryString["Oper"].ToLower())
                {
                    case "load_all_data":
                        LoadData();
                        break;
                    case "save":
                        Save();
                        break;
                    case "del":
                        Del();
                        break;
                }
                Response.End();
            }
        }



        public void LoadData()
        {
            try
            {
                int PageIndex = Convert.ToInt32(Context.Request["page"].ToString().Trim());
                int PageSize = Convert.ToInt32(Context.Request["rows"].ToString().Trim());
                var db = ssk.Entity.SqlDB.GetInstance("sqlconn");
                var totalCount = 0;
                var json = db.Queryable<ssk.Model.SYS_EMAIL>().ToJsonPage(PageIndex, PageSize, ref totalCount);
                json = "{\"total\":\"" + totalCount + "\",\"rows\":" + json + "}";
                Response.Write(json);
                Response.End();
            }
            catch (Exception ex)
            {
                if (!(ex is System.Threading.ThreadAbortException))
                {
                    MesLog.Logs.AddHourLog(ex.Message + " 出错页[EmailConfig.aspx]");
                }
            }
        }


        public void Save()
        {
            string Result = "";
            int i = 0;
            string _ExecType = Request["ExecType"] != null ? Request["ExecType"] : "";
            string _Type = Request["type"] != null ? Request["type"] : "";
            string _Smtp = Request["smtp"] != null ? Request["smtp"] : "";
            string _Email_address = Request["email"] != null ? Request["email"] : "";
            string _Pwd = Request["Pwd"] != null ? Request["Pwd"] : "";

            ssk.Model.SYS_EMAIL se = new Model.SYS_EMAIL();
            se.FTYPE = _Type;
            se.SMTP_SERVER = _Smtp;
            se.EMAIL = _Email_address;
            se.PWD = _Pwd;
            se.CREATE_TIME = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");

            var db = ssk.Entity.SqlDB.GetInstance("sqlconn");

            if (_ExecType == "0")
            {
                if (CheckExists(_Type))
                {
                    Result = "{\"error\":1,\"msg\":\"" + _Type + "已经存在！\"}";
                    Response.Write(Result);
                    Response.End();
                    return;
                }

                i = db.Insertable(se).ExecuteCommand();
            }
            if (_ExecType == "1")
            {
                i = db.Updateable(se).ExecuteCommand();
            }

            if (i > 0)
            {
                Result = "{\"error\":0,\"msg\":\"操作成功！\"}";
            }
            else
            {
                Result = "{\"error\":1,\"msg\":\"操作失败！\"}";
            }

            Response.Write(Result);
            Response.End();
        }


        public bool CheckExists(string _Type)
        {
            var db = ssk.Entity.SqlDB.GetInstance("sqlconn");
            var result = db.Queryable<ssk.Model.SYS_EMAIL>().Where(it => it.FTYPE == _Type).Any();
            return result;
        }

        public void Del()
        {
            string Result = "";
            string _fid = Request["fid"] != null ? Request["fid"] : "";
            var db = ssk.Entity.SqlDB.GetInstance("sqlconn");

            var i = db.Deleteable<ssk.Model.SYS_EMAIL>().Where(it => it.FID == _fid).ExecuteCommand();
            if (i > 0)
            {
                Result = "{\"error\":0,\"msg\":\"数据删除成功！\"}";
            }
            else
            {
                Result = "{\"error\":1,\"msg\":\"数据删除失败！\"}";
            }

            Response.Write(Result);
            Response.End();
        }

    }
}