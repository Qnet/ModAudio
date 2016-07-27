<%@ Page Language="VB" Explicit="False" %>

<%@ Import Namespace="PDshop9" %>
<script runat="server">

    '************************************************************
    '*         TERMS & CONDITIONS / COPYRIGHT NOTICE            *
    '************************************************************
    '*   By Downloading or using this software, you agree to    *
    '*   the terms and conditions as stated in the Software     *
    '*   License Agreement.  An updated copy of this agreement  *
    '*   can be seen at http://www.pagedowntech.com/terms.      *
    '*                                                          *
    '*   NOTICE: We do not recommend changing the code below    *
    '*   as it may interfere with future updates/upgrades.      *
    '*                                                          *
    '*        PageDown Technology, LLC., Copyright 2011.        *
    '*             pagedowntech.com / pdshop.com                *
    '*                                                          *
    '*  (this copyright notice must not be altered or removed)  *
    '************************************************************

    Public pd As PDshopFunctions
    Public nextposturl As String

    Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)

        If IsNothing(pd) = False Then pd.PDShopError()

    End Sub
   
    Sub Page_Load(ByVal Sender As Object, ByVal E As EventArgs)

        pd = New PDshopFunctions()
        pd.LoadPDshop()
         
        'Checks your Shop Access/Checkout settings.
        pd.VerifyShopAccess()

        If Not (Page.IsPostBack) Then
                  
            'Process Alert Messages
            showalert = pd.getrequest("showalert")
            If showalert = "reviewed" Then
                pd.alertmessage = pd.geterrtext("err66")
            End If
            If showalert = "emailed" Then
                pd.alertmessage = pd.geterrtext("err49")
            End If
         
        End If

        'Get Task
        task = pd.getrequest("task")

        'Get Item Contents
        itemdetail.DataSource = pd.binditemdetail()
        itemdetail.DataBind()
         

        'Handle Error (if retunring from cart with data entry error)
        adderror = pd.getrequest("error")
        If adderror = "y" Then
            pd.formerror = pd.geterrtext("err47")
            edititemid = pd.getrequest("edititemid")
            If pd.checkInt(edititemid) = True Then
                pd.deletecartitem(edititemid)
            End If
        End If

        'Determine Next Posting URL
        If pd.getrequest("wlist") = "Edit" Then
            nextposturl = pd.shopurl & "wlistcart.aspx"
        Else
            nextposturl = pd.shopsslurl & "showcart.aspx"
        End If

    End Sub


    Sub Page_UnLoad(ByVal Sender As Object, ByVal E As EventArgs)

        If IsNothing(pd) = False Then pd.UnLoadPDshop()

    End Sub

</script>
<%=pd.getTopHtml(pd.pg6)%>
<%=pd.startSection("hditem")%>
<div>
    <div class="messages">
        <%=pd.getFormError()%></div>
    <asp:repeater id="itemdetail" runat="server">
        <itemtemplate>
            <form method="post" action="<%=nextposturl%>" name="pageform" id="pageform">   
              <%# Container.DataItem("hiddeninput") %> 
              <div>
                <% If pd.hideitemheading = "" Then%>
                    <%# Container.DataItem("imagewrap") %>
                    <div class="messages"><%# Container.DataItem("nameheading") %></div>
                    <div class="itemname"><%# Container.DataItem("name") %></div>
                    <div class="messages"><%# Container.DataItem("itemnoheading") %></div>
                    <div class="itemname"><%# Container.DataItem("itemno") %></div>
                    <div class="messages"><%# Container.DataItem("custom1heading") %></div>
                    <div class="itemname"><%# Container.DataItem("custom1text") %></div>
                    <div class="messages"><%# Container.DataItem("custom2heading") %></div>
                    <div class="itemname"><%# Container.DataItem("custom2text") %></div>
                    <div class="messages"><%# Container.DataItem("custom3heading") %></div>
                    <div class="itemname"><%# Container.DataItem("custom3text") %></div>

                    <% If pd.hideitemprice <> "ON" Then%>
                        <div class="messages"><%=pd.getsystext("sys16")%></div>
                        <div class="price"><%# Container.DataItem("baseprice") %></div>
                        <div class="price"><%# Container.DataItem("qtydiscounts") %></div>
                    <% End If%>       
                 
                    <div class="messages"><%# Container.DataItem("avgreviewheading") %></div>
                    <div><%# Container.DataItem("avgreviewicon") %></div>                    
                     
                <% End If%>
                <%# Container.DataItem("imagegallery")%>
                <div class="itemdescription"><%# Container.DataItem("description") %></div>        
            </div>    
   
            <% If pd.hideitemheading <> "ON" Then%>
                <div><%# Container.DataItem("imagenowrap") %></div>
       
                  <!-- ITEM OPTIONS BELOW -->
    
                    <div style="clear: both;">
                        <%# Container.DataItem("optionheader") %>
                        <asp:repeater runat="server" datasource='<%# Container.DataItem.Row.GetChildRows("OptionCats") %>'>
                        <itemtemplate>
                        <div class="itemoptions_container">
                            <div class="itemoptionsgroup"><%# Container.DataItem("groupname") %></div>
                            <div class="itemoptions"><%# Container.DataItem("groupoptions") %></div>
                        </div>
                        </itemtemplate>
                        </asp:Repeater>
                        <%# Container.DataItem("optionfooter") %>
                    </div>    
                    <% If pd.hideitemprice <> "ON" Then%>    
                    <div>
                        <%# Container.DataItem("optionheader2") %>        
                        <div class="messages"><%# Container.DataItem("finalpriceheading") %></div>
                        <div class="price"><%# Container.DataItem("finalprice") %></div>        
                        <%# Container.DataItem("optionfooter2") %> 
                    </div>    
                    <% End If%>

                    <!-- ITEM OPTIONS ABOVE -->
    
                  <div class="itemstockmessage"><%# Container.DataItem("stockmessage") %></div>
    
                    <% If pd.inventoryerror = "No" Then%>

                        <% If pd.hideitemprice = "" Then%>
        
                            <div class="messages"><%=pd.getsystext("sys15")%></div>
                            <div><input class="itemqtyinput" type="text" name="qty" value="<%# Container.DataItem("addqty") %>" size="3" /></div>
                            <div class="messages">&nbsp;</div>
                            <div class="cartbuttons_container">
                                <%# Container.DataItem("updatebutton") %>
                                <%# Container.DataItem("savebutton") %>
                                <%# Container.DataItem("buybutton") %>
                            </div>
                        <%End If%>
    
                       <div class="cartbuttons_container">  
                          <%# Container.DataItem("emailbutton") %>
                          <%# Container.DataItem("wishbutton") %>
                          <%# Container.DataItem("readreviewbutton")%>
                      </div>
    
                    <% End If%>    
                       <div>  
                          <div class="twitter_share"><%# Container.DataItem("twitter")%></div>
                          <div class="facebook_like"><%# Container.DataItem("facebook")%></div>
                          <div style="clear: both;"></div>
                      </div>
  
            <%End If%>
            
          </form>
        </itemtemplate>
    </asp:repeater>
</div>
<% = pd.endSection() %>
<%=pd.getBottomHtml(pd.pg6)%>
