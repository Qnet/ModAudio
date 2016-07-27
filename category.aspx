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
    Public catid, catname, catmetaurl, catdesc, catlargeimage, catpgconfig As String
    Public catitemcount, subcatitemcount, catpagetype As Int32

    Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)

        If IsNothing(pd) = False Then pd.PDShopError()

    End Sub

    Sub Page_Load(ByVal Sender As Object, ByVal E As EventArgs)

        pd = New PDshopFunctions()
        pd.LoadPDshop()
         
        'Checks your Shop Access/Checkout settings.
        pd.VerifyShopAccess()

        catid = pd.getrequest("catid")
        
        'Not Used
        If Not (Page.IsPostBack) Then
        End If

        'Get Category
        If pd.checkInt(catid) = True Then
            pd.OpenDataReader("SELECT * FROM category WHERE id=" & pd.FormatSqlText(catid))
        ElseIf pd.shoprewriteSql <> "" Then
            'Find record based on a friendly Url name instead of id
            pd.OpenDataReader("SELECT * FROM category WHERE " & pd.shoprewriteSql)
        Else
            pd.pdRedirect(pd.shopurl)
        End If
        
        If pd.ReadDataItem.Read Then
            catid = pd.ReadData("id")
            catname = pd.ReadData("name")
            catdesc = pd.ReadData("description")
            catsubof = pd.ReadDataN("subof")
            catactive = pd.ReadData("active")
            catshortdesc = pd.ReadData("shortdesc")
            catmetatitle = pd.ReadData("metatitle")
            catmetakeyw = pd.ReadData("metakeyw")
            catmetadesc = pd.ReadData("metadesc")
            catmetaurl = pd.ReadData("metaurl")
            catpagemax = pd.ReadDataN("pagemax")
            catpagetype = pd.ReadDataN("pagetype")
            catmaxcols = pd.ReadDataN("maxcols")
            catsortdir = pd.ReadDataN("sortdir")
            catpgconfig = pd.ReadData("pgconfig")
            catlargeimage = pd.ReadData("largeimage")
        Else
            pd.pdRedirect(pd.shopurl & "listcats.aspx")
        End If
        pd.CloseData()
        
        'Fix Urls in Description Html, Change Relative to Virtual
        catdesc = pd.makeurlsrelative(catdesc)
         
        'If Category is not active, redirect
        If catactive = "No" Then pd.pdRedirect("listcats.aspx")
         
        'Determine List View or Grid View
        pd.pageviewby = pd.getcookie("viewby")
        If pd.pageviewby = "" Then
            If catpagetype = 2 Then
                pd.pageviewby = "grid"
            End If
        ElseIf pd.pageviewby = "grid" Then
            catpagetype = 2
        ElseIf pd.pageviewby = "list" Then
            catpagetype = 1
        End If
        
        'Handle default data
        If catpagetype = 1 Or catpagetype = 0 Then catmaxcols = 1
        If catpagemax = 0 Then catpagemax = 10
        If catmaxcols = 0 Then catmaxcols = 2

        'Set Search engine meta tags.
        If catmetatitle <> "" Then
            pd.pagetitle = catmetatitle
        End If
        If catmetakeyw <> "" Then
            pd.keywords = catmetakeyw
        End If
        If catmetadesc <> "" Then
            pd.sitedesc = catmetadesc
        End If
        

        'Get this Category tree (one-line horizontally)
        categorytreerepeater.DataSource = pd.bindsinglecategorytree(catid, catsubof)
        categorytreerepeater.DataBind()

        'Get Sub Categories
        subcategoryrepeater.DataSource = pd.bindsubcategories(catid)
        subcatitemcount = subcategoryrepeater.DataSource.Count
        subcategoryrepeater.RepeatColumns = pd.submaxcols
        subcategoryrepeater.RepeatDirection = RepeatDirection.Vertical
        subcategoryrepeater.RepeatLayout = RepeatLayout.Table
        subcategoryrepeater.GridLines = GridLines.None
        subcategoryrepeater.DataBind()
        
        'Override Column width defaults
        'pd.colwidth1 = 20
        'pd.colwidth2 = 50
        'pd.colwidth3 = 10
        'pd.colwidth4 = 15
        pd.currentpgconfig = catpgconfig
        
        'Get Category Items
        columnrepeater.DataSource = pd.bindcategoryitems(catid, catpagemax)
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
<%=pd.getTopHtml(pd.pg5)%>
<%= pd.startSection("hdcat")%>
<div>
    <div class="catname">
        <asp:repeater id="categorytreerepeater" runat="server">    
        <itemtemplate>
        <%# Container.DataItem("categoryname") %><span class="catdelim">&nbsp; &gt;&nbsp; </span>
        </itemtemplate>
    
    </asp:repeater>
        <%=pd.DoHtmlEncode(catname)%></div>
    <%  If Trim(catlargeimage) <> "" Then%>
    <div>
        <img src="<%=pd.imagesurl %><%=catlargeimage%>" <%=pd.getcatimgsizehtmlL()%> alt="<%=pd.DoHtmlEncode(catname)%>"
            border="0" /></div>
    <%  End If%>
    <%  If Trim(catdesc) <> "" Then%>
    <div class="catdescdiv">
        <%=catdesc%></div>
    <%  End If%>
</div>
<% = pd.EndSection()%>
<%  If subcatitemcount > 0 Then%>
<%= pd.startSection("heads12")%>
<div>
    <asp:datalist width="100%" style="table-layout: fixed;" itemstyle-verticalalign="Top"
        id="subcategoryrepeater" runat="server">
        <itemtemplate>
        <div class="subcatlist_div">
            <div class="subcats"><%# Container.DataItem("subcategory") %></div>
            <div><img border="0" width="5" height="3" src="<% =pd.pdimgurl %>pixel.gif" alt="<%# Container.DataItem("name") %>" /></div>
            <div class="catimg"><%# Container.DataItem("subimage") %></div>
            <div class="catdesc"><%# Container.DataItem("shortdesc") %></div>
        </div>
        </itemtemplate>
    </asp:datalist>
</div>
<% = pd.endSection()%>
<%  End If%>
<%  If catitemcount > 0 Then%>
<%= pd.startSection("hdcatitems")%>
<div>
    <div class="messages">
        <%=pd.getFormError()%></div>
    <asp:datalist id="columnrepeater" runat="server" style="width: 100%; table-layout: fixed;"
        itemstyle-verticalalign="Top">
    <itemtemplate>

        <% If catpagetype = 1 Or catpagetype = 0 Then%>

           <div class="catitemlist_div">
               <div class="catitemlist_column1" style="width: <%=pd.colwidth1 %>%;"><div class="listimage"><%# Container.DataItem("itemimage") %></div></div>
                <div class="catitemlist_column2" style="width: <%=pd.colwidth2 %>%;">
                    <div class="listname"><%# Container.DataItem("itemname") %></div>
                    <div class="listdesc"><%# Container.DataItem("shortdesc") %></div>
                   <div class="cartbuttons_container">
                        <%# Container.DataItem("buybutton") %>
                        <%# Container.DataItem("morebutton") %>
                    </div>
               </div>
               <div class="catitemlist_column3" style="width: <%=pd.colwidth3 %>%;">
                    <div class="listitemno"><%# Container.DataItem("itemno") %></div>
               </div>
                <div class="catitemlist_column4" style="width: <%=pd.colwidth4 %>%;">                    
                    <div class="listprice"><%# Container.DataItem("itemprice") %></div>
                    <div class="messages"><%# Container.DataItem("stockmessage") %></div>
               </div>
                <div style="clear: both;"></div>
          </div>

        <% Else%>

        <div class="catitem_div">
           <div class="listimage"><%# Container.DataItem("itemgridimage")%></div>           
           <div class="listname"><%# Container.DataItem("itemname") %></div>           
           <div class="listdesc"><%# Container.DataItem("shortdesc") %></div>
           <div class="cartbuttons_container">
                <%# Container.DataItem("buybutton") %>
                <%# Container.DataItem("morebutton") %>
            </div>
          <div class="listitemno"><%# Container.DataItem("itemno") %></div>
          <div class="listprice"><%# Container.DataItem("itemprice") %></div>
          <div class="messages"><%# Container.DataItem("stockmessage") %></div>         
          </div>

      <% End If%>

    </itemtemplate>
    </asp:datalist>
    <div>
        <%=pd.paginglinks%></div>
</div>
<% =pd.endSection() %>
<%  End If%>
<%=pd.getBottomHtml(pd.pg5)%>
