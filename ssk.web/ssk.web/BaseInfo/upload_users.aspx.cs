using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.IO;
using NPOI.SS.UserModel;
using NPOI.HSSF.UserModel;
using NPOI.XSSF.UserModel;
using System.Data.OleDb;
using System.Text;

namespace ssk.web.BaseInfo
{
    public partial class upload_users : System.Web.UI.Page
    {
        public string[] resutl = { "", "" };

        private IWorkbook workbook = null;
        private FileStream fs = null;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Request.Form["submitkey"] != null)
            {
                int submitkey = int.Parse(Request.Form["submitkey"]);
                if (submitkey == 0) return;
                try
                {
                    saveDoc();
                }
                catch (Exception ex)
                {
                    resutl[0] = ex.Message;
                    resutl[1] = "3";
                }
            }
        }

        void saveDoc()
        {
            string fileName = Request.Form["upload_filename"].Trim();

            //读取文件
            if (Request.Files.Count <= 0 || fileName.Length <= 0)
            {
                resutl[0] = "请选择一个文件！";
                resutl[1] = "3";
                return;
            }

            var arr = fileName.Split('\\');
            fileName = arr[arr.Length - 1];


            //判断文件类型
            if (!fileName.EndsWith(".xls") && !fileName.EndsWith(".xlsx"))
            {
                resutl[0] = "文件格式错误，必须为excel文件！";
                resutl[1] = "3";
                return;
            }

            //保存文件
            string path = AppDomain.CurrentDomain.BaseDirectory + "upload";
            //SSK.ser.LogException.AddHourLog(path);

            if (!System.IO.Directory.Exists(path))
            {
                System.IO.Directory.CreateDirectory(path);
            }

            if (fileName.EndsWith(".xls"))
            {
                fileName = Guid.NewGuid().ToString() + ".xls";
            }
            else
            {
                fileName = Guid.NewGuid().ToString() + ".xlsx";
            }

            string filepath = path + "\\" + fileName;
            if (System.IO.File.Exists(filepath))
            {
                resutl[0] = "文件“" + fileName + "”已经存在，请更换文件名！";
                resutl[1] = "3";
                return;
            }
              
            var file = Request.Files[0];
            file.SaveAs(filepath);

            System.Threading.Thread.Sleep(1000);


            DataTable dt = new ssk.Entity.ExcelHelper(filepath).ExcelToDataTable("", true);
             
            var db = ssk.Entity.SqlDB.GetInstance("sqlconn");

            for (int i = 0; i < dt.Rows.Count; i++)
            {
                ssk.Model.USR_INFO ui = new ssk.Model.USR_INFO();
                ui.USR_ID = dt.Rows[i][0].ToString();
                ui.USR_NAME = dt.Rows[i][1].ToString();
                ui.USR_PWD = "123456";
                ui.DEP_NAME = dt.Rows[i][2].ToString();
                ui.PHONE = dt.Rows[i][3].ToString();
                ui.EMAIL = dt.Rows[i][4].ToString();
                ui.CREATE_TIME = DateTime.Now;

                //导入用户的时候，先把已经存在的用户删除，始终保持最新的数据
                db.Deleteable<ssk.Model.USR_INFO>().Where(a => a.USR_ID == dt.Rows[i][0].ToString()).ExecuteCommand();

                db.Insertable<ssk.Model.USR_INFO>(ui).ExecuteCommand();
            }

            resutl[0] = "上传成功！";
            resutl[1] = "0";

        }


        public DataSet ExcelToDS(string Path)
        {
            string strConn = "Provider=Microsoft.Jet.OLEDB.4.0;" + "Data Source=" + Path + ";" + "Extended Properties=Excel 8.0;";
            OleDbConnection conn = new OleDbConnection(strConn);
            conn.Open();
            string strExcel = "";
            OleDbDataAdapter myCommand = null;
            DataSet ds = null;
            strExcel = "select * from [sheet1$]";
            myCommand = new OleDbDataAdapter(strExcel, strConn);
            ds = new DataSet();
            myCommand.Fill(ds, "table1");
            return ds;
        }


 
    }
}