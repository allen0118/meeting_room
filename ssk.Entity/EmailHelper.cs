using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net.Mail;

namespace ssk.Entity
{
    public class EmailHelper
    {
         /// <summary>
        /// 发送邮件
        /// </summary>
        /// <param name="mailTo">要发送的邮箱</param>
        /// <param name="mailSubject">邮箱主题</param>
        /// <param name="mailContent">邮箱内容</param>
        /// <returns>返回发送邮箱的结果</returns>
        public static bool SendEmail(string IP,string SendID,string SendPwd,string mailTo,
            string mailSubject, string mailContent, out Exception exceptions)
        {
            exceptions = null;
            // 发送方的邮件信息
            string smtpServer = IP;
            string mailFrom = SendID; //登陆用户名
            string userPassword = SendPwd;//登陆密码,这里的密码要注意用客户端授权码.
             
            SmtpClient smtpClient = new SmtpClient();
            smtpClient.DeliveryMethod = SmtpDeliveryMethod.Network;
            smtpClient.Host = smtpServer;  
            smtpClient.Credentials = new System.Net.NetworkCredential(mailFrom, userPassword);//创建凭据

            // 发送邮件设置       
            MailMessage mailMessage = new MailMessage(mailFrom, mailTo);

            //如果有多个收件人，则将不同的收件人地址用英文逗号隔开.
            string[] ToList = mailTo.Split('|');
            foreach (var item in ToList)
            {
                mailMessage.To.Add(item);
            }

            mailMessage.Subject = mailSubject;
            mailMessage.Body = mailContent;
            mailMessage.BodyEncoding = Encoding.UTF8;
            mailMessage.IsBodyHtml = true;
            mailMessage.Priority = MailPriority.High;//优先级

            try
            {
                smtpClient.Send(mailMessage); // 发送
                return true;
            }
            catch (SmtpException ex)
            {
                exceptions = ex;
                return false;
            }
        }
    }
}
