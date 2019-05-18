using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

namespace ssk.web
{
    public partial class Main : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        { 
            if (Request.QueryString["Oper"] != null)
            {
                switch (Request.QueryString["Oper"].ToLower())
                {
                    case "get_menus":
                        Get_Menus();
                        break;
                    case "clear_session":
                        ClearSession();
                        break;
                }
            }
        }

        public void Get_Menus()
        {
            #region Table
            DataTable dt = new DataTable();
            dt.Columns.Add("MENU_GROUP_NAME");
            dt.Columns.Add("MENU_ID");
            dt.Columns.Add("MENU_NAME");
            dt.Columns.Add("MENU_URL");
            dt.Columns.Add("SEQ");
            dt.Columns.Add("MENU_ICO");
            dt.Columns.Add("GROUP_ICO");

            DataRow _dr1 = dt.NewRow();
            _dr1["MENU_GROUP_NAME"] = "预约管理";
            _dr1["MENU_ID"] = "1";
            _dr1["MENU_NAME"] = "预约会议室";
            _dr1["MENU_URL"] = "BaseInfo/ConferenceRoom.aspx";
            _dr1["SEQ"] = "1";
            _dr1["MENU_ICO"] = "icon-line";
            _dr1["GROUP_ICO"] = "icon-line";
            dt.Rows.Add(_dr1);

            DataRow _dr2 = dt.NewRow();
            _dr2["MENU_GROUP_NAME"] = "后台管理";
            _dr2["MENU_ID"] = "2";
            _dr2["MENU_NAME"] = "会议室管理";
            _dr2["MENU_URL"] = "BaseInfo/Rooms.aspx";
            _dr2["SEQ"] = "2";
            _dr2["MENU_ICO"] = "icon-home";
            _dr2["GROUP_ICO"] = "icon-setting";
            dt.Rows.Add(_dr2);

            DataRow _dr3 = dt.NewRow();
            _dr3["MENU_GROUP_NAME"] = "后台管理";
            _dr3["MENU_ID"] = "3";
            _dr3["MENU_NAME"] = "用户管理";
            _dr3["MENU_URL"] = "BaseInfo/Users.aspx";
            _dr3["SEQ"] = "3";
            _dr3["MENU_ICO"] = "icon-users";
            _dr3["GROUP_ICO"] = "icon-setting";
            dt.Rows.Add(_dr3);


            DataRow _dr5 = dt.NewRow();
            _dr5["MENU_GROUP_NAME"] = "后台管理";
            _dr5["MENU_ID"] = "5";
            _dr5["MENU_NAME"] = "邮件配置";
            _dr5["MENU_URL"] = "BaseInfo/EmailConfig.aspx";
            _dr5["SEQ"] = "5";
            _dr5["MENU_ICO"] = "icon-email";
            _dr5["GROUP_ICO"] = "icon-setting";
            dt.Rows.Add(_dr5);



            DataRow _dr4 = dt.NewRow();
            _dr4["MENU_GROUP_NAME"] = "报表中心";
            _dr4["MENU_ID"] = "4";
            _dr4["MENU_NAME"] = "报表中心";
            _dr4["MENU_URL"] = "BaseInfo/Users.aspx";
            _dr4["SEQ"] = "4";
            _dr4["MENU_ICO"] = "icon-ok";
            _dr4["GROUP_ICO"] = "icon-ok";
            dt.Rows.Add(_dr4);  
            #endregion

            var json = "";
            string parentName = "";

            json += "[";
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                DataRow dr = dt.Rows[i];
                string tparentName = dr["MENU_GROUP_NAME"].ToString();
                if (tparentName == parentName) { continue; }
                parentName = tparentName;
                if (i > 0)
                {
                    json += "}";
                    json += ",";
                }

                json += "{\"MENU_GROUP_ID\":\"" + i.ToString() + "\",\"ICON\":\"" + dt.Rows[i]["GROUP_ICO"].ToString() + "\",\"MENU_GROUP_NAME\":\"" + dt.Rows[i]["MENU_GROUP_NAME"].ToString() + "\","; //这里增加父节点

                DataRow[] rows = dt.Select("  MENU_GROUP_NAME='" + parentName + "'");
                int k = 0;
                json += "\"MENUS\":[";
                foreach (DataRow cdr in rows)
                {
                    if (k > 0)
                    {
                        json += ",";
                    }
                    k++;
                    json += "{\"MENU_ID\":\"" + cdr[1].ToString() + "\",\"ICON\":\"" + cdr[5].ToString() + "\",\"MENU_NAME\":\"" + cdr[2].ToString() + "\",\"URL\":\"" + cdr[3].ToString() + "\"}";
                }
                json += "]";
            }
            json += "}";
            json += "]";


            Response.Write(json);
            Response.End();
        }

        public void ClearSession()
        {
            Session.Abandon();//清除全部Session

        }

    }
}