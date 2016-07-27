<%@ WebService Language="C#" Class="modaudio_ws" %>
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;

using System.Data.SqlClient;
using System.Collections;
using System.Data;
using System.Web.Script.Services;
using System.Net.Mail;
using System.Text;

using System.Web.Security;
using PDshop9;



public class GetUploadFiles
{
        public String  customerid;
		public String name;
        public String topic;
        public String theme;
        public String filename;
        public String filename2;
        public String filename3;
        public String filename4;
        public String location;
        public String uploaddate;
        public String filesortorder;
        public String url;
        public String size;   
        public String Message;
	public String price;
}

public class InsertMessage
{
    public string Message;
}


public class OrderedItems{
       public String  customerid;
       public String    itemno;
       public String  qty;
       public String  price;
       public String  orderid;
       public String  billemail;
	 

       public String  name;

       public String  description;
       public String  smallimage;
       public String  largeimage;
       public String shortdesc;
       public String digfile;
}


public class NewCustomer {
    public String email;
    public String password;

}




[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
[System.Web.Script.Services.ScriptService]

public class modaudio_ws : System.Web.Services.WebService
{
    public modaudio_ws () {

        //Uncomment the following line if using designed components 
        //InitializeComponent(); 
    }


    

    [WebMethod]
    public string HelloWorld() {
        return "Hello World";
    }


    [WebMethod]
    public List<GetUploadFiles> GetUploadFiles(int customerid)
    {
        List<GetUploadFiles> GetUploadFiles = new List<GetUploadFiles> { };





        string Message = "";

        //            SqlConnection cn;
        //            cn = new SqlConnection("Server=67.105.97.108schedsqlvm.int.swapa.org;Database=CrewWebAccessDM;user=smart;password=trams99");
        //SqlConnection cn = new SqlConnection("Server=67.105.97.108;Database=CrewWebAccessDM;uid=smart;pwd=trams99;connection timeout=300;");
        //            cn = new SqlConnection("Server=67.105.97.108;Database=CrewWebAccessDM;user=smart;password=trams99;connection timeout=300;");

        SqlConnection cn = new SqlConnection(@"Server=mssql0818.wc2\inst2;Database=632394_modaudio;uid=632394_modaudio_Store;pwd=^^017Aud!o;connection timeout=3000;");        
        cn.Open();

        SqlCommand cmd = cn.CreateCommand();
        SqlDataAdapter da;
        SqlDataReader reader = null;
        DataSet ds = new DataSet();



        cmd.CommandText = "sp_Get_UploadFiles";
        cmd.CommandTimeout = 300;
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Parameters.Add("@customerid", SqlDbType.Int);
        cmd.Parameters["@customerid"].Value = customerid;



        da = new SqlDataAdapter(cmd);

        da.Fill(ds);

        cn.Close();


        try
        {


            try
            {

            }
            catch (Exception ex)
            {
                // LogException("GetActivitybyPilotid", ex.ToString());

            }
            finally
            {
                if (cn.State == ConnectionState.Open)
                {
                    cn.Close();
                    cmd = null;
                }

            }

            DataTable dt = new DataTable();
            dt = ds.Tables[0];
            foreach (DataRow dr in dt.Rows)
            {
 
                GetUploadFiles i = new GetUploadFiles();
                i.customerid = dr[0].ToString();
                i.name = dr[1].ToString();
                i.topic = dr[2].ToString();
                i.theme = dr[3].ToString();
                i.filename = dr[4].ToString();
                i.filename2 = dr[5].ToString();
                i.filename3 = dr[6].ToString();
                i.filename4 = dr[7].ToString();
                i.location = dr[8].ToString();
                i.uploaddate = dr[9].ToString();
                i.filesortorder = dr[10].ToString();
                i.url = dr[11].ToString();
                i.size = dr[12].ToString();
                i.price = dr[13].ToString();
                
                GetUploadFiles.Add(i);
            }


            //EmailGrievance(intEmpNum, EventDate, TimeofEvent, ContractSection, DetailDescription, RemedyRequested);
            //Message = "Adjustment Sucessfully Inserted";  //get from reader before reader.Close
            //GetLogbook i = new GetLogbook();
            //i.Message = Message;
            //ValidationMessage.Add(i);
            //return ValidationMessage;

        }
        catch (Exception ex)
        {


            GetUploadFiles i = new GetUploadFiles();
            i.Message = ex.ToString();
            //ValidationMessage.Add(i);
            return GetUploadFiles;
            //return "Unsucessful Activity Insert " + ex.ToString();
        }

        finally
        {
            if (cn.State == ConnectionState.Open)
            {
                cn.Close();
                cmd = null;
            }

        }




        return GetUploadFiles;
    }






    [WebMethod]
    public List<OrderedItems> GetOrderedItems(string email)
    {
        List<OrderedItems> OrderedItems = new List<OrderedItems> { };





        string Message = "";

        //            SqlConnection cn;
        //            cn = new SqlConnection("Server=67.105.97.108schedsqlvm.int.swapa.org;Database=CrewWebAccessDM;user=smart;password=trams99");
        //SqlConnection cn = new SqlConnection("Server=67.105.97.108;Database=CrewWebAccessDM;uid=smart;pwd=trams99;connection timeout=300;");
        //            cn = new SqlConnection("Server=67.105.97.108;Database=CrewWebAccessDM;user=smart;password=trams99;connection timeout=300;");

        SqlConnection cn = new SqlConnection(@"Server=mssql0818.wc2\inst2;Database=632394_modaudio_Store;uid=632394_modaudio_Store;pwd=^^017Aud!o;connection timeout=3000;");
        cn.Open();

        SqlCommand cmd = cn.CreateCommand();
        SqlDataAdapter da;
        SqlDataReader reader = null;
        DataSet ds = new DataSet();



        cmd.CommandText = "sp_Get_Ordered_Items_by_email";
        cmd.CommandTimeout = 300;
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Parameters.Add("@billemail", SqlDbType.VarChar);
        cmd.Parameters["@billemail"].Value = email;



        da = new SqlDataAdapter(cmd);

        da.Fill(ds);

        cn.Close();


        try
        {


            try
            {

            }
            catch (Exception ex)
            {
                // LogException("GetActivitybyPilotid", ex.ToString());

            }
            finally
            {
                if (cn.State == ConnectionState.Open)
                {
                    cn.Close();
                    cmd = null;
                }

            }

            DataTable dt = new DataTable();
            dt = ds.Tables[0];
            foreach (DataRow dr in dt.Rows)
            {

                OrderedItems i = new OrderedItems();
                i.customerid = dr[0].ToString();
                i.itemno = dr[1].ToString();
                i.qty = dr[2].ToString();
                i.price = dr[3].ToString();
                i.orderid = dr[4].ToString();
                i.billemail = dr[5].ToString();
                i.name = dr[6].ToString();
                i.description = dr[7].ToString();
                i.smallimage = dr[8].ToString();
                i.largeimage = dr[9].ToString();
                i.shortdesc = dr[10].ToString();
                i.digfile = dr[11].ToString();

                OrderedItems.Add(i);
            }


            //EmailGrievance(intEmpNum, EventDate, TimeofEvent, ContractSection, DetailDescription, RemedyRequested);
            //Message = "Adjustment Sucessfully Inserted";  //get from reader before reader.Close
            //GetLogbook i = new GetLogbook();
            //i.Message = Message;
            //ValidationMessage.Add(i);
            //return ValidationMessage;

        }
        catch (Exception ex)
        {


            OrderedItems i = new OrderedItems();
            i.description = ex.ToString();
            //ValidationMessage.Add(i);
            return OrderedItems;
            //return "Unsucessful Activity Insert " + ex.ToString();
        }

        finally
        {
            if (cn.State == ConnectionState.Open)
            {
                cn.Close();
                cmd = null;
            }

        }




        return OrderedItems;
    }

    
    
    [WebMethod]
    public List<NewCustomer> NewCustomer2(string email, string password, string name, string company, string phone,
                                        string street1, string street2, string state, string city, string country,
                                        string zip)
    {
        List<NewCustomer> newcust = new List<NewCustomer> { };
        
        newcust = NewCustomer2(email, password, name, company, phone, street1, street2, state, city, country, zip);

        return newcust;
        
    }
    
    
    
    [WebMethod]
    public List<NewCustomer> NewCustomer(string email, string password, string name, string company, string phone, 
                                         string street1, string street2, string state, string city, string country,
                                         string zip )
    {

        
        List<NewCustomer> NewCustomer = new List<NewCustomer> { };
        PDshopFunctions pd = new PDshopFunctions();
       // pd.browserNoCache();
        pd.LoadPDshop();
  
        string Message = "";
        
        try
        {

            //Prepare Database - Argument (database tablename)
            pd.OpenDataWriter("customer");

            //Function Arguments (column name, form id.text, Name of Field, Field Type, Min Characters, Max Characters)
            pd.AddFormData("email", email, pd.getsystext("sys23"), "E", 5, 50);
            pd.AddFormData("password", password, pd.getsystext("sys24"), "X", 5, 50);
            pd.AddFormData("name", name, pd.getsystext("sys26"), "T", 5, 50);
            
                pd.AddFormData("company", company, pd.getsystext("sys147"), "T", 0, 50);
            
            pd.AddFormData("phone", phone, pd.getsystext("sys27"), "T", 7, 50);
            pd.AddFormData("street1", street1, pd.getsystext("sys28"), "T", 3, 50);
            pd.AddFormData("street2", street2, pd.getsystext("sys28"), "T", 0, 50);
            pd.AddFormData("state", state, pd.getsystext("sys30"), "T", 0, 50);
            pd.AddFormData("city", city, pd.getsystext("sys29"), "T", 2, 50);
            pd.AddFormData("country", country, pd.getsystext("sys32"), "T", 0, 50);
            pd.AddFormData("zip", zip, pd.getsystext("sys31"), "T", 0, 50);



/*
            pd.AddData("email", email, "E");
            pd.AddData("password", password, "X");
            pd.AddData("name", name, "T");

            pd.AddData("company", company, "T");

            pd.AddData("phone", phone, "T");
            pd.AddData("street1", street1, "T");
            pd.AddData("street2", street2, "T");
            pd.AddData("state", state, "T");
            pd.AddData("city", city, "T" );
            pd.AddData("country", country, "T");
            pd.AddData("zip", zip, "T");            
*/            //Default Price Level
            pd.AddData("pricelevel", 0, "N");
            pd.AddData("taxexempt", 0, "N");

                pd.AddData("optin", 0, "N");

                //pd.CloseData();
                string customerid;
                customerid = pd.SaveData();


             //   pd.LogShopEvent(206, customerid, "");

        
                NewCustomer i = new NewCustomer();
                i.email = email + pd.formerror;
                i.password = "";

                NewCustomer.Add(i);
         


            //EmailGrievance(intEmpNum, EventDate, TimeofEvent, ContractSection, DetailDescription, RemedyRequested);
            //Message = "Adjustment Sucessfully Inserted";  //get from reader before reader.Close
            //GetLogbook i = new GetLogbook();
            //i.Message = Message;
            //ValidationMessage.Add(i);
            //return ValidationMessage;

        }
        catch (Exception ex)
        {


            NewCustomer i = new NewCustomer();
            i.email = ex.ToString();// +"pd" + pd.formerror.ToString();
            NewCustomer.Add(i);
            
            return NewCustomer;
            //return "Unsucessful Activity Insert " + ex.ToString();
        }

        finally
        {


        }




        return NewCustomer;
    }




    [WebMethod]
    public string validate_login2(string email, string password)
    {
        string valid;

        valid = validate_login(email, password);
        
        
        if (valid == "False Not a User")
        { 
        return "False Not a User";
        
        }
        else if (valid == "True Valid User")
        {
            return "True Valid User";
        }
        return "False Not a User";
    }


    [WebMethod]
    public string validate_login(string email, string password)
    {
        
        PDshopFunctions pd = new PDshopFunctions();
      //  pd.browserNoCache();
        pd.LoadPDshop();

        //semail = email;
        //spassword = password;
        string customerid = "";
        string Message = "";
       // return "true";
        
        
        //custom

        SqlConnection cn = new SqlConnection(@"Server=mssql0818.wc2\inst2;Database=632394_modaudio_Store;uid=632394_modaudio_Store;pwd=^^017Aud!o;connection timeout=3000;");
        cn.Open();

        SqlCommand cmd = cn.CreateCommand();
        SqlDataAdapter da;
        SqlDataReader reader = null;
        DataSet ds = new DataSet();



        cmd.CommandText = "sp_Get_Customerid";
        cmd.CommandTimeout = 300;
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Parameters.Add("@email", SqlDbType.VarChar);
        cmd.Parameters["@email"].Value = email;



        da = new SqlDataAdapter(cmd);

        da.Fill(ds);

        cn.Close();


        try
        {        
                    DataTable dt = new DataTable();
            dt = ds.Tables[0];
            foreach (DataRow dr in dt.Rows)
            {

              
                customerid = dr[0].ToString();
            }
        


            //Check email for invalid characters
            //pd.formerror = pd.checkchr(email, pd.getsystext("sys23"));
            
            Message = "SELECT * FROM customer WHERE email='" + pd.FormatSqlText(email) + "'";
            pd.OpenDataReader("SELECT * FROM customer WHERE email='" + pd.FormatSqlText(email) + "'");

           
//                 if (pd.ReadDataItem.Read != false)
//                  {
               // if (pd.recordcount > 0)
//fj                           if(pd.ReadDataItem.Read)
//fj            {

      //fj 7 21 breakthru      customerid = "12";   //fj 7 21           customerid = pd.ReadData("id");
                    /* string clockout = pd.ReadDataN("lockout");

                      //If customer is locked out
                      if (clockout == "1")
                      {
                          pd.formerror = pd.geterrtext("err69");
                          pd.LogShopEvent(203, customerid, "");
                      }

                      else
                      {
                          pd.formerror = pd.geterrtext("err50");
                          pd.LogShopEvent(202, "0", email);
                      }
             */
                      pd.CloseData();
                     
                    //Verify Password
                    // if (pd.formerror == "")
                    // {
                    if (pd.passwordverified("customer", customerid, password) == false)
                    {
                        //      pd.formerror = pd.geterrtext("err51");
                        //      pd.LogShopEvent(202, customerid, "");
                        return "False Not a User";
                    }
                    else
                    {
                        return "True Valid User";
                    }
                    //}

  /*fj              }
                else
                {

                    return "no read pd  " + Message;
                }
*/
           // }
        }
        catch (Exception ex)
        {


            Message = Message + ex.ToString();
            return "Exception: " + Message;
        }

        finally
        {
            if (cn.State == ConnectionState.Open)
            {
                cn.Close();
                cmd = null;
            }

        }




   //     return "fj it is false out of loop FalseUser";
    }
    
    
    
    
    
}
