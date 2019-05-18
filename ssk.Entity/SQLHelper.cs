using System;
using System.Collections.Generic;
using System.Text;
using System.Configuration;
using System.Data.SqlClient;
using System.Data;
using System.Collections;

namespace ssk.Entity
{
    public static class SQLHelper
    {
        public static string connectionstring = (ConfigurationManager.ConnectionStrings["sqlconn"] == null) ? "server=.;database=DB;uid=sa;pwd=allenchen;" : ConfigurationManager.ConnectionStrings["sqlconn"].ConnectionString;

        /// <summary>
        /// 准备一个SqlCommand ,设置cmd的相关参数
        /// </summary>
        /// <param name="cmd">SqlCommand</param>
        /// <param name="type">cmd的类型，普通sql or proc</param>
        /// <param name="trans">事务</param>
        /// <param name="parameters">参数</param>
        /// <param name="cmdtext">sql or proc name</param>
        /// <param name="conn">SqlConnection</param>
        private static void PrepareCommd(SqlCommand cmd, CommandType type, SqlTransaction trans, SqlParameter[] parameters, string cmdtext, SqlConnection conn)
        {
            if (conn.State != ConnectionState.Open)
            {
                conn.Open();
            }

            cmd.CommandText = cmdtext;
            cmd.CommandType = type;
            cmd.Connection = conn;
            cmd.CommandTimeout = 90;

            if (trans != null)
            {
                cmd.Transaction = trans;
            }

            if (parameters != null)
            {
                foreach (SqlParameter param in parameters)
                {
                    if (param != null)
                    {
                        cmd.Parameters.Add(param);
                    }
                }
            }
        }
        

        #region 返回一个SqlDataReader

        /// <summary>
        /// 返回一个SqlDataReader
        /// </summary>
        /// <param name="type">cmd类型(普通sql or proc)</param>
        /// <param name="cmdtext">sql语句 or proc name</param>
        /// <param name="parameters">sql 参数 可以为null</param>
        /// <param name="key">连接字符串的键值</param>
        /// <returns>return sqldatareader</returns>
        public static SqlDataReader ExcuteReader(CommandType type, string cmdtext, SqlParameter[] parameters)
        {
            SqlConnection conn = new SqlConnection(connectionstring);
            return ExcuteReader(conn, type, cmdtext, parameters);
           
        }

        /// <summary>
        /// 带connectionstring 参数的查询
        /// </summary>
        /// <param name="strConn"></param>
        /// <param name="type"></param>
        /// <param name="cmdtext"></param>
        /// <param name="parameters"></param>
        /// <returns></returns>
        public static SqlDataReader ExcuteReader(string strConn, CommandType type, string cmdtext, SqlParameter[] parameters)
        {
            SqlConnection conn = new SqlConnection(strConn);
            return ExcuteReader(conn, type, cmdtext, parameters);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="conn"></param>
        /// <param name="type"></param>
        /// <param name="cmdtext"></param>
        /// <param name="parameters"></param>
        /// <returns></returns>
        public static SqlDataReader ExcuteReader(SqlConnection conn, CommandType type, string cmdtext, SqlParameter[] parameters)
        {
            using (SqlCommand cmd = new SqlCommand())
            {
                cmd.CommandTimeout = 90;
                PrepareCommd(cmd, type, null, parameters, cmdtext, conn);

                SqlDataReader dr = cmd.ExecuteReader(CommandBehavior.CloseConnection);
                cmd.Parameters.Clear();
                return dr;
            }
        }

        #endregion


        #region 执行cmd，返回查询结果的第一行的第一列

        /// <summary>
        /// 执行cmd，返回查询结果的第一行的第一列
        /// </summary>
        /// <param name="type">cmd类型 sql or proc</param>
        /// <param name="cmdtext">sql 语句 or proc name</param>
        /// <param name="parameters">sql 参数 可null</param>
        /// <returns>return object</returns>
        public static object ExecuteScalar(CommandType type, string cmdtext, SqlParameter[] parameters)
        {
            using (SqlConnection conn = new SqlConnection(connectionstring))
            {
                return ExecuteScalar(conn, type, cmdtext, parameters);               
            }
        }

        /// <summary>
        /// 执行自定义SqlConnection参数的ExecuteScalar
        /// </summary>
        /// <param name="strConn"></param>
        /// <param name="type"></param>
        /// <param name="cmdtext"></param>
        /// <param name="parameters"></param>
        /// <returns></returns>
        public static object ExecuteScalar(string strConn, CommandType type, string cmdtext, SqlParameter[] parameters)
        {
            using (SqlConnection conn = new SqlConnection(strConn))
            {
                return ExecuteScalar(conn, type, cmdtext, parameters);
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="conn"></param>
        /// <param name="type"></param>
        /// <param name="cmdtext"></param>
        /// <param name="parameters"></param>
        /// <returns></returns>
        public static object ExecuteScalar(SqlConnection conn, CommandType type, string cmdtext, SqlParameter[] parameters)
        {
            using (SqlCommand cmd = new SqlCommand())
            {
                cmd.CommandTimeout = 90;
                PrepareCommd(cmd, type, null, parameters, cmdtext, conn);
                try
                {
                    object o = cmd.ExecuteScalar();
                    cmd.Parameters.Clear();
                    return o;
                }
                catch (Exception ex)
                {
                    MesLog.Logs.AddLog(" [ExecuteScalar] [" + cmdtext + "]" + "[" + ex.Message + "]"); 
                    
                    return null;
                }
            }
        }

        #endregion

        #region ExecuteNonQuery  执行cmd,返回受影响的行数

        /// <summary>
        /// 执行cmd,返回受影响的行数
        /// </summary>
        /// <param name="type">cmd类型 sql 语句 or proc</param>
        /// <param name="cmdtext">sql or proc name</param>
        /// <param name="parameters">sql 参数 可null</param>
        /// <returns>return 受影响的行数</returns>
        public static int ExecuteNonQuery(CommandType type, string cmdtext, SqlParameter[] parameters)
        {
            using (SqlConnection conn = new SqlConnection(connectionstring))
            {
                return ExecuteNonQuery(conn, type, cmdtext, parameters);
              
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="strConn"></param>
        /// <param name="type"></param>
        /// <param name="cmdtext"></param>
        /// <param name="parameters"></param>
        /// <returns></returns>
        public static int ExecuteNonQuery(string strConn, CommandType type, string cmdtext, SqlParameter[] parameters)
        {
            using (SqlConnection conn = new SqlConnection(strConn))
            {
                return ExecuteNonQuery(conn, type, cmdtext, parameters);
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="conn"></param>
        /// <param name="type"></param>
        /// <param name="cmdtext"></param>
        /// <param name="parameters"></param>
        /// <returns></returns>
        public static int ExecuteNonQuery(SqlConnection conn, CommandType type, string cmdtext, SqlParameter[] parameters)
        {
            using (SqlCommand cmd = new SqlCommand())
            {
                cmd.CommandTimeout = 90;
                PrepareCommd(cmd, type, null, parameters, cmdtext, conn);

                try
                {
                    int n = cmd.ExecuteNonQuery();
                    cmd.Parameters.Clear();
                    return n;
                }
                catch (Exception ex)
                {
                    MesLog.Logs.AddLog(" [ExecuteNonQuery] [" + cmdtext + "]" + "[" + ex.Message + "]");
                    return 0;
                }
            }
        }

        #endregion

        
        #region 执行cmd,返回受影响的行数 事物模式

        /// <summary>
        /// 执行cmd,返回受影响的行数
        /// </summary>
        /// <param name="type">cmd类型 sql 语句 or proc</param>
        /// <param name="cmdtext">sql or proc name</param>
        /// <param name="parameters">sql 参数 可null</param>
        /// <returns>return 受影响的行数</returns>
        public static int transExecuteNonQuery(CommandType type, string cmdtext, SqlParameter[] parameters)
        {
            using (SqlConnection conn = new SqlConnection(connectionstring))
            {
                conn.Open();

                return transExecuteNonQuery(conn, type, cmdtext, parameters);
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="strConn"></param>
        /// <param name="type"></param>
        /// <param name="cmdtext"></param>
        /// <param name="parameters"></param>
        /// <returns></returns>
        public static int transExecuteNonQuery(string strConn, CommandType type, string cmdtext, SqlParameter[] parameters)
        {
            using (SqlConnection conn = new SqlConnection(strConn))
            {
                conn.Open();

                return transExecuteNonQuery(conn, type, cmdtext, parameters);
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="conn"></param>
        /// <param name="type"></param>
        /// <param name="cmdtext"></param>
        /// <param name="parameters"></param>
        /// <returns></returns>
        public static int transExecuteNonQuery(SqlConnection conn, CommandType type, string cmdtext, SqlParameter[] parameters)
        {
            using (SqlCommand cmd = new SqlCommand())
            {
                cmd.CommandTimeout = 90;
                SqlTransaction trans = conn.BeginTransaction();
                PrepareCommd(cmd, type, trans, parameters, cmdtext, conn);

                try
                {
                    int n = cmd.ExecuteNonQuery();
                    trans.Commit();//提交事务
                    cmd.Parameters.Clear();
                    return n;
                }
                catch (Exception ex)
                {
                    MesLog.Logs.AddLog(" [transExecuteNonQuery][" + cmdtext + "]" + "[" + ex.Message + "]");
                    return 0;
                }
            }
        }

        #endregion


        #region 执行事务，返回hashtable  key(row):受影响的行数，报错时返回0,key(message):报错的message,正常时为空

        /// <summary>
        /// 执行事务，返回hashtable  key(row):受影响的行数，报错时返回0,key(message):报错的message,正常时为空
        /// </summary>
        /// <param name="type">cmd类型，sql语句 or proc</param>
        /// <param name="cmdtext">sql 语句 or proc name</param>
        /// <param name="parameters">sql 参数</param>
        /// <returns>返回hashtable</returns>
        public static Hashtable T_ExecuteNonQuery(CommandType type, string cmdtext, SqlParameter[] parameters)
        {
            using (SqlConnection conn = new SqlConnection(connectionstring))
            {
                conn.Open();
                return T_ExecuteNonQuery(conn, type, cmdtext, parameters);              
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="strConn"></param>
        /// <param name="type"></param>
        /// <param name="cmdtext"></param>
        /// <param name="parameters"></param>
        /// <returns></returns>
        public static Hashtable T_ExecuteNonQuery(string strConn, CommandType type, string cmdtext, SqlParameter[] parameters)
        {
            using (SqlConnection conn = new SqlConnection(strConn))
            {
                conn.Open();
                return T_ExecuteNonQuery(conn, type, cmdtext, parameters);
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="conn"></param>
        /// <param name="type"></param>
        /// <param name="cmdtext"></param>
        /// <param name="parameters"></param>
        /// <returns></returns>
        public static Hashtable T_ExecuteNonQuery(SqlConnection conn, CommandType type, string cmdtext, SqlParameter[] parameters)
        {
            using (SqlCommand cmd = new SqlCommand())
            {
                cmd.CommandTimeout = 90;
                SqlTransaction trans = conn.BeginTransaction();
                PrepareCommd(cmd, type, trans, parameters, cmdtext, conn);
                Hashtable ht = new Hashtable();
                try
                {
                    ht.Add("row", cmd.ExecuteNonQuery());//影响的行数
                    ht.Add("message", "");//信息
                    trans.Commit();//提交事务
                    cmd.Parameters.Clear();
                    return ht;
                }
                catch (Exception ex)
                {
                    MesLog.Logs.AddLog(" [T_ExecuteNonQuery] [" + cmdtext + "]" + "[" + ex.Message + "]");
                    cmd.Parameters.Clear();
                    trans.Rollback();
                    ht.Add("row", 0);
                    ht.Add("message", ex.Message.ToString());
                    return ht;
                }
            }
        }

        #endregion



        #region 执行cmd，返回dataset

        /// <summary>
        /// 执行cmd，返回dataset
        /// </summary>
        /// <param name="type">cmd 类型 sql语句 or proc</param>
        /// <param name="cmdtext">sql or proc name</param>
        /// <param name="parameters">sql 参数</param>
        /// <returns> return dataset</returns>
        public static DataSet GetDataSet(CommandType type, string cmdtext, SqlParameter[] parameters)
        {
            using (SqlConnection conn = new SqlConnection(connectionstring))
            {
                return GetDataSet(conn, type, cmdtext, parameters);
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="strConn"></param>
        /// <param name="type"></param>
        /// <param name="cmdtext"></param>
        /// <param name="parameters"></param>
        /// <returns></returns>
        public static DataSet GetDataSet(string strConn, CommandType type, string cmdtext, SqlParameter[] parameters)
        {
            using (SqlConnection conn = new SqlConnection(strConn))
            {
                return GetDataSet(conn, type, cmdtext, parameters);
            }
        }


        /// <summary>
        /// 
        /// </summary>
        /// <param name="conn"></param>
        /// <param name="type"></param>
        /// <param name="cmdtext"></param>
        /// <param name="parameters"></param>
        /// <returns></returns>
        public static DataSet GetDataSet(SqlConnection conn, CommandType type, string cmdtext, SqlParameter[] parameters)
        {
            using (SqlCommand cmd = new SqlCommand())
            {
                cmd.CommandTimeout = 90;
                PrepareCommd(cmd, type, null, parameters, cmdtext, conn);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataSet ds = new DataSet();
                da.Fill(ds);
                cmd.Parameters.Clear();
                return ds;
            }
        }

        #endregion


        #region 执行带参数的多条SQL语句，采用事物

        /// <summary>
        /// 不带事物执行多条语句
        /// </summary>
        /// <param name="type"></param>
        /// <param name="cmdtexts"></param>
        /// <param name="parameters"></param>
        /// <returns></returns>
        public static int noTransExecuteNonQuery(CommandType type, List<String> cmdtexts, List<SqlParameter[]> parameters)
        {
            using (SqlConnection conn = new SqlConnection(connectionstring))
            {
                conn.Open();
                return noTransExecuteNonQuery(conn, type, cmdtexts, parameters);
            }
        }

        /// <summary>
        /// 不带事物执行多条语句
        /// </summary>
        /// <param name="strConn"></param>
        /// <param name="type"></param>
        /// <param name="cmdtexts"></param>
        /// <param name="parameters"></param>
        /// <returns></returns>
        public static int noTransExecuteNonQuery(string strConn, CommandType type, List<String> cmdtexts, List<SqlParameter[]> parameters)
        {
            using (SqlConnection conn = new SqlConnection(strConn))
            {
                conn.Open();
                return noTransExecuteNonQuery(conn, type, cmdtexts, parameters);
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="conn"></param>
        /// <param name="type"></param>
        /// <param name="cmdtexts"></param>
        /// <param name="parameters"></param>
        /// <returns></returns>
        public static int noTransExecuteNonQuery(SqlConnection conn, CommandType type, List<string> cmdtexts, List<SqlParameter[]> parameters)
        {
            using (SqlCommand cmd = new SqlCommand())
            {
                cmd.CommandTimeout = 90;
                int i = 0;
                int n = 0;
                //循环执行
                foreach (string cmdtext in cmdtexts)
                {
                    if (cmdtext.Length == 0)
                    {
                        continue;
                    }
                    try
                    {
                        PrepareCommd(cmd, type, null, (parameters == null ? null : parameters[i]), cmdtext, conn);
                        n += cmd.ExecuteNonQuery();
                    }
                    catch
                    {
                    }
                    i++;
                }

                cmd.Parameters.Clear();

                return n;
            }
        }

        /// <summary>
        /// 执行带参数的多条SQL语句，采用事物
        /// </summary>
        /// <param name="type"></param>
        /// <param name="cmdtexts">多条SQL语句集合</param>
        /// <param name="parameters">参数数组</param>
        /// <returns>HASH[ROW:影响的记录条数，ERROR：记录条数为0时 可获取详细错误信息]</returns>
        public static int transExecuteNonQuery(CommandType type, string[] cmdtexts, List<object> parameters)
        {
            using (SqlConnection conn = new SqlConnection(connectionstring))
            {
                conn.Open();
                return transExecuteNonQuery(conn, type, cmdtexts, parameters);
            }
        }

        /// <summary>
        /// 执行带参数的多条SQL语句，采用事物
        /// </summary>
        /// <param name="type"></param>
        /// <param name="cmdtexts">多条SQL语句集合</param>
        /// <param name="parameters">参数数组</param>
        /// <returns>HASH[ROW:影响的记录条数，ERROR：记录条数为0时 可获取详细错误信息]</returns>
        public static int transExecuteNonQuery2(CommandType type, List<string> cmdtexts, List<object> parameters)
        {
            using (SqlConnection conn = new SqlConnection(connectionstring))
            {
                conn.Open();
                return transExecuteNonQuery2(conn, type, cmdtexts, parameters);
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="strConn"></param>
        /// <param name="type"></param>
        /// <param name="cmdtexts"></param>
        /// <param name="parameters"></param>
        /// <returns></returns>
        public static int transExecuteNonQuery(string strConn, CommandType type, string[] cmdtexts, List<object> parameters)
        {
            using (SqlConnection conn = new SqlConnection(strConn))
            {
                conn.Open();
                return transExecuteNonQuery(conn, type, cmdtexts, parameters);
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="strConn"></param>
        /// <param name="type"></param>
        /// <param name="cmdtexts"></param>
        /// <param name="parameters"></param>
        /// <returns></returns>
        public static int transExecuteNonQuery2(string strConn, CommandType type, List<string> cmdtexts, List<object> parameters)
        {
            using (SqlConnection conn = new SqlConnection(strConn))
            {
                conn.Open();
                return transExecuteNonQuery2(conn, type, cmdtexts, parameters);
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="conn"></param>
        /// <param name="type"></param>
        /// <param name="cmdtexts"></param>
        /// <param name="parameters"></param>
        /// <returns></returns>
        public static int transExecuteNonQuery(SqlConnection conn, CommandType type, string[] cmdtexts, List<object> parameters)
        {
            using (SqlCommand cmd = new SqlCommand())
            {
                cmd.CommandTimeout = 90;

                SqlTransaction trans = conn.BeginTransaction();
                try
                {
                    int i = 0;
                    int n = 0;
                    //循环执行
                    foreach (string cmdtext in cmdtexts)
                    {
                        if (cmdtext.Length == 0)
                        {
                            continue;
                        }
                        PrepareCommd(cmd, type, trans, (parameters == null ? null : parameters[i] as SqlParameter[]), cmdtext, conn);
                        n += cmd.ExecuteNonQuery();
                        i++;
                    }
                    trans.Commit();//提交事务

                    cmd.Parameters.Clear();

                    return n;
                }
                catch (Exception ex)
                {
                    MesLog.Logs.AddLog(DateTime.Now.ToString() + " [T_ExecuteNonQuery] " + "[" + ex.Message + "]");
                    cmd.Parameters.Clear();
                    trans.Rollback();
                    return 0;
                }
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="conn"></param>
        /// <param name="type"></param>
        /// <param name="cmdtexts"></param>
        /// <param name="parameters"></param>
        /// <returns></returns>
        public static int transExecuteNonQuery2(SqlConnection conn, CommandType type, List<string> cmdtexts, List<object> parameters)
        {
            using (SqlCommand cmd = new SqlCommand())
            {
                cmd.CommandTimeout = 90;

                SqlTransaction trans = conn.BeginTransaction();
                try
                {
                    int i = 0;
                    int n = 0;
                    //循环执行
                    foreach (string cmdtext in cmdtexts)
                    {
                        if (cmdtext.Length == 0)
                        {
                            continue;
                        }
                        PrepareCommd(cmd, type, trans, (parameters == null ? null : parameters[i] as SqlParameter[]), cmdtext, conn);
                        n += cmd.ExecuteNonQuery();
                        i++;
                    }
                    trans.Commit();//提交事务

                    cmd.Parameters.Clear();

                    return n;
                }
                catch (Exception ex)
                {
                    MesLog.Logs.AddLog(DateTime.Now.ToString() + " [T_ExecuteNonQuery] " + "[" + ex.Message + "]");
                    cmd.Parameters.Clear();
                    trans.Rollback();
                    return 0;
                }
            }
        }

        #endregion


        /// <summary>
        /// 执行带事物的SQL语句
        /// </summary>
        /// <param name="trans"></param>
        /// <param name="type"></param>
        /// <param name="cmdtext"></param>
        /// <param name="parameters"></param>
        /// <returns></returns>
        public static int ExecuteNonQueryNew(IDbTransaction trans, CommandType type, string cmdtext, SqlParameter[] parameters)
        {
            if (trans != null)
            {
                SqlTransaction tran = trans as SqlTransaction;
                SqlConnection conn = tran.Connection;

                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandTimeout = 90;
                    PrepareCommd(cmd, type, tran, parameters, cmdtext, conn);
                    try
                    {
                        int n = cmd.ExecuteNonQuery();
                        cmd.Parameters.Clear();
                        return n;
                    }
                    catch (Exception ex)
                    {                   
                        //回滚
                        //tran.Rollback();
                        throw ex;
                    }
                }
            }
            else
            {
                return ExecuteNonQuery(type, cmdtext, parameters);
            }
        } 

    }
}
