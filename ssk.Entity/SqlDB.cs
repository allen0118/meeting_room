using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using SqlSugar;

namespace ssk.Entity
{
    public class SqlDB
    {
        public static SqlSugarClient GetInstance()
        {
            string ConnectionString = System.Configuration.ConfigurationManager.ConnectionStrings["sqlconn"].ConnectionString;
            SqlSugarClient db = new SqlSugarClient(new ConnectionConfig() { ConnectionString = ConnectionString, DbType = DbType.SqlServer, IsAutoCloseConnection = true });
            db.Ado.IsEnableLogEvent = true;
            db.Ado.LogEventStarting = (sql, pars) =>
            {
                Console.WriteLine(sql + "\r\n" + db.RewritableMethods.SerializeObject(pars));
                Console.WriteLine();
            };
            return db;
        }

        public static SqlSugarClient GetInstance(string sqlconnName)
        {
            string ConnectionString = System.Configuration.ConfigurationManager.ConnectionStrings[sqlconnName].ConnectionString;
            SqlSugarClient db = new SqlSugarClient(new ConnectionConfig() { ConnectionString = ConnectionString, DbType = DbType.SqlServer, IsAutoCloseConnection = true });
            db.Ado.IsEnableLogEvent = true;
            db.Ado.LogEventStarting = (sql, pars) =>
            {
                Console.WriteLine(sql + "\r\n" + db.RewritableMethods.SerializeObject(pars));
                Console.WriteLine();
            };
            return db;
        }


        public static SqlSugar.SqlSugarClient db
        {
            get
            {
                return SqlDB.GetInstance();
            }
        }
    }
}
