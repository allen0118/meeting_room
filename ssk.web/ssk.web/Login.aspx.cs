using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

namespace ssk.web
{
    public partial class Login : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Request.QueryString["Oper"] != null)
            {
                switch (Request.QueryString["Oper"].ToLower())
                {
                    case "user_login":
                        UserLogin();
                        break;
                }

                Response.End();
            }
           
        }


        private void UserLogin()
        {
            string Result = "";

            string UserID = Request["UserID"] != null ? Request["UserID"] : "";
            string UserPwd = Request["UserPwd"] != null ? Request["UserPwd"] : "";

           // UserPwd = MtsTool.Encrypt16Bit(UserPwd);


            if (!CheckExists(UserID,UserPwd))
            {
                Result = "{\"error\":1,\"msg\":\"用户名或密码错误,请重新输入！\"}";
                Response.Write(Result);
                return;
            }
         
            Session["UserID"] = UserID;

            Result = "{\"error\":0,\"msg\":\"登录成功！\"}";
            Response.Write(Result);
            Response.End();

        }




        public bool CheckExists(string _UsrID,string _Pwd)
        {
            var db = ssk.Entity.SqlDB.GetInstance("sqlconn");
            var result = db.Queryable<ssk.Model.USR_INFO>().Where(it => it.USR_ID == _UsrID && it.USR_PWD==_Pwd).Any();
            return result;
        }
    }
}