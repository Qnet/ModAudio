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

    Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)

        If IsNothing(pd) = False Then pd.PDShopError()

    End Sub

    Sub Page_Load(ByVal Sender As Object, ByVal E As EventArgs)


        pd = New PDshopFunctions()
        pd.LoadPDshop()
         
        'Checks your Shop Access/Checkout settings.
        pd.VerifyShopAccess()

        'Not Used
        If Not (Page.IsPostBack) Then
        End If

        'Get Category List
        listcategories.DataSource = pd.bindlistcats()
        listcategories.DataBind()
        
    End Sub

    Sub Page_UnLoad(ByVal Sender As Object, ByVal E As EventArgs)

        If IsNothing(pd) = False Then pd.UnLoadPDshop()

    End Sub

</script>
<%=pd.getTopHtml(pd.pg2)%>
<%= pd.startSection("hdcatsP")%>
<div>
  <asp:repeater id="listcategories" runat="server">
  <itemtemplate>
   
    <div class="catlist_div" style="clear: both;">
        <div class="catname"><%# Container.DataItem("categoryname") %></div>
        <div class="catdesc"><%# Container.DataItem("categoryshortdesc") %></div>
        <div><%# Container.DataItem("subimage") %></div>  
        <div class="subcats">
            <asp:datalist width="90%" itemstyle-width="50%" style="display:block;margin-bottom: 20px;" RepeatLayout="Table" RepeatColumns="2" RepeatDirection="Vertical" HorizontalAlign="Left"
         id="listsubs" runat="server" datasource='<%# Container.DataItem.Row.GetChildRows("subcategories") %>'>
            
            <itemtemplate>
             <%# Container.DataItem("categoryname") %>         
            </itemtemplate>

            </asp:datalist>
        </div>
        
    </div>

  </itemtemplate>
  </asp:repeater>
</div>
<%= pd.endSection()%>
<%=pd.getBottomHtml(pd.pg2)%>
