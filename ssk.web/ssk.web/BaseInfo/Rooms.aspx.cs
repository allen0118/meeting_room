using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ssk.web.BaseInfo
{
    public partial class Rooms : System.Web.UI.Page
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
                var json = db.Queryable<ssk.Model.ROOMS>().ToJsonPage(PageIndex, PageSize, ref totalCount);
                json = "{\"total\":\"" + totalCount + "\",\"rows\":" + json + "}";
                Response.Write(json);
                Response.End();
            }
            catch (Exception ex)
            {
                if (!(ex is System.Threading.ThreadAbortException))
                {
                    MesLog.Logs.AddHourLog(ex.Message + " 出错页[Rooms.aspx]");
                }
            }
        }

        public void Save() 
        {
            string Result = "";
            int i = 0;
            string _ExecType = Request["ExecType"] != null ? Request["ExecType"] : "";
            string _RoomName = Request["Name"] != null ? Request["Name"] : "";
            string _Location = Request["Location"] != null ? Request["Location"] : "";

            string _Tyy = Request["TYY"] != null ? Request["TYY"] : "";
            string _BB = Request["BB"] != null ? Request["BB"] : "";
            string _Phone = Request["Phone"] != null ? Request["Phone"] : "";
            string _Video = Request["Video"] != null ? Request["Video"] : "";
            string _Printer = Request["Printer"] != null ? Request["Printer"] : "";


            string _MemberQty = Request["Qty"] != null ? Request["Qty"] : "";
            ssk.Model.ROOMS rm = new Model.ROOMS();
            rm.ROOM_NO = _RoomName; 
            rm.LOCATION = _Location;
            rm.MEMBER_QTY = _MemberQty;
            rm.TYY = _Tyy;
            rm.BB = _BB;
            rm.PHONE = _Phone;
            rm.VIDEO = _Video;
            rm.PRINTER = _Printer;
            rm.STATUS = "0";
            rm.CREATE_TIME = DateTime.Now; 

            var db = ssk.Entity.SqlDB.GetInstance("sqlconn");

            if (_ExecType == "0") 
            {
                if (CheckExists(_RoomName)) 
                {
                    Result = "{\"error\":1,\"msg\":\"当前会议室编号 已经存在！\"}";
                    Response.Write(Result);
                    Response.End();
                    return;
                }

                i = db.Insertable(rm).ExecuteCommand();
            }
            if (_ExecType == "1")
            {
                i = db.Updateable(rm).ExecuteCommand();
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

        public void Del() 
        {
            string Result = "";
            string _RoomName = Request["Name"] != null ? Request["Name"] : ""; 
            var db = ssk.Entity.SqlDB.GetInstance("sqlconn");

            var i = db.Deleteable<ssk.Model.ROOMS>().Where(it => it.ROOM_NO == _RoomName).ExecuteCommand();
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

        public bool CheckExists(string _RoomName)
        {
            var db = ssk.Entity.SqlDB.GetInstance("sqlconn");            
            var result= db.Queryable<ssk.Model.ROOMS>().Where(it => it.ROOM_NO == _RoomName).Any();
            return result;
        }
    }
}