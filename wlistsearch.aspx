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
    Public listtype, catname, catdesc, catpgconfig, wlistemail, wlistname As String
    Public catitemcount, subcatitemcount As Integer

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

        'Check if viewing 'My WishList'
        If pd.getrequest("mylist") = "Y" Or pd.getrequest("listtype") = "MW" Then
            listtype = "MW"

            'Verify User
            If pd.isSignedIn() = "No" Then pd.pdRedirect(pd.shopsslurl & "signin.aspx?refer=wlistsearch.aspx?mylist=Y")
            customerid = pd.getcookie("customerid")

            pd.OpenDataReader("SELECT * FROM customer WHERE id=" & customerid)
            If pd.ReadDataItem.Read Then
                wlistname = pd.ReadData("name")
                wlistemail = pd.ReadData("email")
            Else
                pd.formerror = pd.geterrtext("err50")
            End If
            pd.CloseData()

        ElseIf pd.getcookie("wlistemail") <> "" Then
            listtype = "W"
            wlistemail = pd.getcookie("wlistemail")
            pd.OpenDataReader("SELECT * FROM customer WHERE email='" & pd.FormatSqlText(wlistemail) & "'")
            If pd.ReadDataItem.Read Then
                wlistname = pd.ReadData("name")
            Else
                pd.formerror = pd.geterrtext("err50")
            End If
            pd.CloseData()
        Else
            pd.pdRedirect("wlistlookup.aspx")
        End If
        
        'Default
        catpagemax = 5
        catmaxcols = 1
        catpgconfig = pd.ficonfig
        catpagetype = 1
        catsortdir = 1
        
        'Set Initial Column widths
        pd.colwidth1 = 20
        pd.colwidth2 = 50
        pd.colwidth3 = 15
        pd.colwidth4 = 14
        pd.currentpgconfig = catpgconfig
        
        columnrepeater.DataSource = pd.bindcategoryitems(listtype, catpagemax)
        catitemcount = columnrepeater.DataSource.Count
        columnrepeater.RepeatColumns = catmaxcols
        columnrepeater.RepeatDirection = catsortdir
            
        columnrepeater.RepeatLayout = RepeatLayout.Table
        columnrepeater.GridLines = GridLines.None
        columnrepeater.DataBind()

    End Sub

    Sub Page_UnLoad(ByVal Sender As Object, ByVal E As EventArgs)

        If IsNothing(pd) = False Then pd.UnLoadPDshop()

    End Sub

</script>
<%=pd.getTopHtml(pd.pg11)%>
<%  If listtype = "W" Then%>
<%= pd.startSection("heads28")%>
<div>
    <div class="formheadings">
        <%=pd.getsystext("sys26")%>
        <span class="cartdata">
            <%=wlistname%></span><br />
        <%=pd.getsystext("sys23")%>
        <span class="cartdata">
            <%=wlistemail%></span></div>
</div>
<%  Else%>
<%= pd.startSection("heads25")%>
<div>
    <% End If%>
    <%  If catitemcount > 0 Then%>
    <div class="messages">
        <%=pd.getFormError()%></div>
    <asp:datalist id="columnrepeater" runat="server" style="table-layout: fixed;" itemstyle-verticalalign="Top">
    <itemtemplate>

        <% If catpagetype = 1 Or catpagetype = 0 Then%>

           <div style="width:100%; overflow: hidden;">
               <div style="width: <%=pd.colwidth1 %>%; float: left; overflow: hidden;"><%# Container.DataItem("itemimage") %></div>
                <div style="width:<%=pd.colwidth2 %>%; float: left; overflow: hidden;">
                    <div class="listname"><%# Container.DataItem("itemname") %></div>
                    <div class="listdesc"><%# Container.DataItem("shortdesc") %></div>
                   <div class="cartbuttons_container">
                        <%# Container.DataItem("buybutton") %>
                        <%# Container.DataItem("morebutton") %>
                        <%# Container.DataItem("editbutton") %>
                        <%# Container.DataItem("removebutton") %>
                    </div>
               </div>
               <div class="listitemno" style="width:<%=pd.colwidth3 %>%; float: left; overflow: hidden;"><%# Container.DataItem("itemno") %></div>
                <div style="width:<%=pd.colwidth4 %>%; float: left; overflow: hidden;">                    
                    <div class="listprice"><%# Container.DataItem("itemprice") %></div>
                    <div class="messages" style="float: left;"><%# Container.DataItem("stockmessage") %></div>
               </div>
                <div style="clear: both;"></div>
          </div>

        <% Else%>

           <div class="listname"><%# Container.DataItem("itemname") %></div>
           <div><%# Container.DataItem("itemimage") %></div>
           <div class="listdesc"><%# Container.DataItem("shortdesc") %></div>
           <div class="cartbuttons_container">
                <%# Container.DataItem("buybutton") %>
                <%# Container.DataItem("morebutton") %>
                <%# Container.DataItem("editbutton") %>
                <%# Container.DataItem("removebutton") %>
            </div>
          <div class="listitemno"><%# Container.DataItem("itemno") %></div>
          <div class="listprice"><%# Container.DataItem("itemprice") %></div>
          <div class="messages"><%# Container.DataItem("stockmessage") %></div>         

      <% End If%>

    </itemtemplate>
    </asp:datalist>
    <div>
        <%=pd.paginglinks%></div>
    <%  End If%>
</div>
<%= pd.endSection()%>
<%=pd.getBottomHtml(pd.pg11)%>
