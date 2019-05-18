using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using Newtonsoft.Json;
using SqlSugar;
using System.Data.SqlClient;

namespace ssk.web.BaseInfo
{
    public partial class ConferenceRoom : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Request.QueryString["Oper"] != null)
            {
                switch (Request.QueryString["Oper"].ToLower())
                {
                    case "load_times":
                        CreateTimes();
                        break;
                    case "search_room":
                        SearchRooms();
                        break;
                    case "search_user":
                        SearchUsers();
                        break;
                    case "save":
                        BookRoom();
                        break;
                }
                Response.End();
            }

        }



        public void CreateTimes()
        {
            List<object> list = new List<object>();
            for (int i = 0; i <= 23; i++)
            {
                list.Add(new { id = System.Guid.NewGuid().ToString(), name = i.ToString("00") + ":00" });
                list.Add(new { id = System.Guid.NewGuid().ToString(), name = i.ToString("00") + ":30" });
            }
            Response.Write(JsonConvert.SerializeObject(list));
            Response.End();

        }


        public void SearchRooms()
        {
            ////int PageIndex = Convert.ToInt32(Context.Request["page"].ToString().Trim());
            ////int PageSize = Convert.ToInt32(Context.Request["rows"].ToString().Trim()); 

            string Date = Request["Date"] != null ? Request["Date"] : "";
            string Start_Time = Request["Stime"] != null ? Request["Stime"] : "";
            string End_Time = Request["Etime"] != null ? Request["Etime"] : "";

            string strSql = "usp_Get_Rooms";
            SqlParameter[] sp = new SqlParameter[] 
            {
                new SqlParameter("@DATE",SqlDbType.VarChar),
                new SqlParameter("@START_TIME",SqlDbType.VarChar),
                new SqlParameter("@END_TIME",SqlDbType.VarChar),
                new SqlParameter("@INDEX",SqlDbType.VarChar),
                new SqlParameter("@SIZE",SqlDbType.VarChar),
            };

            sp[0].Value = Date;
            sp[1].Value = Start_Time;
            sp[2].Value = End_Time;

            //sp[0].Value = "2018-06-14";
            //sp[1].Value = "20:00";
            //sp[2].Value = "22:00";

            sp[3].Value = 1;
            sp[4].Value = 100;

            DataSet ds = ssk.Entity.SQLHelper.GetDataSet(CommandType.StoredProcedure, strSql, sp);

            var json = ssk.Entity.JsonLib.DataTableToJson(ds.Tables[0]); //JsonHelper.JsonHelper.ConvertDataTable(ds.Tables[0]);
            var totalCount = ds.Tables[1].Rows[0][0].ToString();
            json = "{\"total\":\"" + totalCount + "\",\"rows\":" + json + "}";
            Response.Write(json);
            Response.End();

        }


        public void SearchUsers()
        {
            try
            {
                var db = ssk.Entity.SqlDB.GetInstance("sqlconn");

                int PageIndex = Convert.ToInt32(Context.Request["page"].ToString().Trim());
                int PageSize = Convert.ToInt32(Context.Request["rows"].ToString().Trim());

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
                    MesLog.Logs.AddHourLog(ex.Message + " 出错页[ConferenceRoom.aspx]");
                }
            }
        }


        public void BookRoom()
        {
            string Result = "";
            int i = 0;
            string _Subject = Request["subject"] != null ? Request["subject"] : "";
            string _RoomNo = Request["room"] != null ? Request["room"] : "";
            string _ReqUser = Request["req_user"] != null ? Request["req_user"] : "";
            string _User_name_list = Request["u_name_list"] != null ? Request["u_name_list"] : "";
            string _SDate = Request["sdate"] != null ? Request["sdate"] : "";
            string _STime = Request["stime"] != null ? Request["stime"] : "";
            string _ETime = Request["etime"] != null ? Request["etime"] : "";
            string _User_no_list = Request["u_no_list"] != null ? Request["u_no_list"] : "";
            string _ReqDesc = Request["req_desc"] != null ? Request["req_desc"] : "";

            ssk.Model.ROOM_USE_INFO rui = new Model.ROOM_USE_INFO();

            rui.ROOM_NO = _RoomNo;
            rui.REQ_USER = _ReqUser;
            rui.MEMBER_LIST = _User_name_list;
            rui.START_DATE = _SDate;
            rui.END_DATE = _SDate;
            rui.START_TIME = _STime;
            rui.END_TIME = _ETime;
            rui.SUBJECT = _Subject;
            rui.REMARK = "";
            rui.STATUS = "0";
            rui.CREATE_USER = _ReqUser;
            rui.CREATE_TIME = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
            rui.APP_TIME = null;
            rui.REQ_REMARK = _ReqDesc;
            rui.MEMBER_NO_LIST = _User_no_list;
            var db = ssk.Entity.SqlDB.GetInstance("sqlconn");


            i = db.Insertable(rui).ExecuteCommand();

            if (i > 0)
            {
                Result = "{\"error\":0,\"msg\":\"会议室[" + _RoomNo + "]预约成功！\"}";
            }
            else
            {
                Result = "{\"error\":1,\"msg\":\"预约会议室失败！\"}";
            }
             
            try
            {
                //***************************************
                //解析收件人邮件地址

                string[] _ArrList = _User_no_list.Split(',');
                string _EmailList = "";
                string strSql = @"SELECT EMAIL FROM USR_INFO(NOLOCK) WHERE USR_ID IN('{0}')";
                strSql = string.Format(strSql, string.Join("','", _ArrList.ToArray()));

                SqlSugar.SugarParameter[] parameters = { };
                DataTable dt_email_list = db.Ado.GetDataTable(strSql, parameters);
                //*************************************** 

                //***************************************
                //获取会议室位置，用于发邮件
                DataTable dt = db.Queryable<ssk.Model.ROOMS>().Where(it => it.ROOM_NO == _RoomNo).ToDataTable();
                string Location = "";
                if (dt.Rows.Count > 0)
                {
                    Location = dt.Rows[0]["LOCATION"].ToString();
                }
                else
                {
                    Location = "*";
                }
                //***************************************


                //***************************************
                //整理邮件内容并发送
                string Concent = "";
                Concent = "Dear All, " +
                          "You have a meeting on " + Location + " , details as below. " +
                          "Meeting Subject: " + _Subject + " " +
                          "Meeting Room: " + _RoomNo + " " +
                          "Meeting Date: " + _SDate + " " +
                          "Meeting Time: " + _STime + " to " + _ETime + "";

                if (dt_email_list.Rows.Count > 0)
                {
                    for (int m = 0; m < dt_email_list.Rows.Count; m++)
                    {
                        _EmailList += dt_email_list.Rows[m][0].ToString() + ",";

                    }
                    MailToUsers(_Subject, _EmailList.Substring(0, _EmailList.Length - 1), Concent);
                }
                //***************************************
            }
            catch (Exception ex)
            {
                MesLog.Logs.AddHourLog("发送会议通知邮件失败,错误信息如下："+ex.Message);
            }

            Response.Write(Result);
            Response.End();
        }




        public void MailToUsers(string Title, string ToList, string Concent)
        {
            var db = ssk.Entity.SqlDB.GetInstance("sqlconn");
            DataTable dt = db.Queryable<ssk.Model.SYS_EMAIL>().ToDataTable();

            if (dt.Rows.Count > 0)
            {
                string _Smtp = dt.Rows[0]["SMTP_SERVER"].ToString();
                string _Email = dt.Rows[0]["EMAIL"].ToString();
                string _Pwd = dt.Rows[0]["PWD"].ToString();
                Exception ex = null;
                ssk.Entity.EmailHelper.SendEmail(_Smtp, _Email, _Pwd, ToList, Title, "", out  ex);
            }
        }


    }
}