using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ssk.web.BaseInfo
{
    public partial class Users : System.Web.UI.Page
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
                var json = db.Queryable<ssk.Model.USR_INFO>().ToJsonPage(PageIndex, PageSize, ref totalCount);
                json = "{\"total\":\"" + totalCount + "\",\"rows\":" + json + "}";
                Response.Write(json);
                Response.End();
            }
            catch (Exception ex)
            {
                if (!(ex is System.Threading.ThreadAbortException))
                {
                    MesLog.Logs.AddHourLog(ex.Message + " 出错页[Users.aspx]");
                }
            }
        }


        public void Save()
        {
            string Result = "";
            int i = 0;
            string _ExecType = Request["ExecType"] != null ? Request["ExecType"] : "";
            string _UsrID = Request["UID"] != null ? Request["UID"] : "";
            string _UsrName = Request["Name"] != null ? Request["Name"] : "";
            string _UerPwd = Request["Pwd"] != null ? Request["Pwd"] : "";
           

            string _UerPwd2 = Request["Pwd2"] != null ? Request["Pwd2"] : ""; 
            string _Phone = Request["Phone"] != null ? Request["Phone"] : "";
            string _Email = Request["Email"] != null ? Request["Email"] : "";
            string _DepName = Request["Dep"] != null ? Request["Dep"] : ""; 

            ssk.Model.USR_INFO ui = new Model.USR_INFO();
            ui.USR_ID = _UsrID;
            ui.USR_NAME = _UsrName;
            ui.USR_PWD = _UerPwd;
            ui.PHONE = _Phone;
            ui.EMAIL = _Email;
            ui.PHONE = _Phone;
            ui.CREATE_TIME = DateTime.Now;
            ui.DEP_NAME = _DepName; 

            var db = ssk.Entity.SqlDB.GetInstance("sqlconn");

            if (_ExecType == "0")
            {
                if (CheckExists(_UsrID))
                {
                    Result = "{\"error\":1,\"msg\":\"当前用户已经存在！\"}";
                    Response.Write(Result);
                    Response.End();
                    return;
                }

                i = db.Insertable(ui).ExecuteCommand();
            }
            if (_ExecType == "1")
            {
                i = db.Updateable(ui).ExecuteCommand();
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


        public bool CheckExists(string _UsrID)
        {
            var db = ssk.Entity.SqlDB.GetInstance("sqlconn");
            var result = db.Queryable<ssk.Model.USR_INFO>().Where(it => it.USR_ID == _UsrID).Any();
            return result;
        }


        public void Del()
        {
            string Result = "";             
            string _UsrID = Request["UID"] != null ? Request["UID"] : "";
            var db = ssk.Entity.SqlDB.GetInstance("sqlconn");

            var i = db.Deleteable<ssk.Model.USR_INFO>().Where(it => it.USR_ID == _UsrID).ExecuteCommand();
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