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
    Public itemid, saveditemid, customerid, reviewposted, itemname, itemno, maxchar As String

    Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)

        If IsNothing(pd) = False Then pd.PDShopError()

    End Sub

    Sub Page_Load(ByVal Sender As Object, ByVal E As EventArgs)

        pd = New PDshopFunctions()
        pd.LoadPDshop()
    
        'Set Maximum number of characters for Review
        maxchar = pd.reviewmax

        'Get email info
        pd.OpenSetupDataReader("otherxml", "email")

        'emailfrom = pd.ReadData("emailfrom5")
        'emailfromname = pd.ReadData("emailfromname5")
        'emailsubject = pd.ReadData("emailsubject5")
        'emailbody = pd.ReadData("emailbody5")

        pd.CloseData()

        'Check if returning after registering or signing in.
        itemid = pd.getrequest("itemid")
        If IsNumeric(itemid) Then pd.saveCookie("writeanid", itemid, 0)
        If itemid = "" Then itemid = pd.getcookie("writeanid")
        If Not IsNumeric(itemid) Then pd.pdRedirect(pd.shopurl & "default.aspx")

        'See if customer is signed-in
        If pd.isSignedIn() = "No" Then pd.pdRedirect(pd.shopsslurl & "signin.aspx?refer=writeareview.aspx")
        customerid = pd.getcookie("customerid")

        'Get Item details
        pd.OpenDataReader("SELECT * FROM items WHERE active='Yes' AND id=" & itemid)
        If pd.ReadDataItem.Read Then
            itemname = pd.ReadData("name")
            itemdesc = pd.ReadData("shortdesc")
            itemno = pd.ReadData("itemno")
            itemreviewen = pd.ReadData("reviews")
        
            'Make sure Item Review is enabled
            If pd.reviewen = "A" Or (pd.reviewen = "I" And itemreviewen = "ON") Then
            Else
                pd.pdRedirect(pd.shopurl & "item.aspx?itemid=" & itemid)
            End If
        
        Else
            pd.pdRedirect(pd.shopurl & "default.aspx")
        End If
        pd.CloseData()


        'Check if customer already reviewed
        pd.OpenDataReader("SELECT id FROM reviews WHERE itemid=" & itemid & " AND customerid=" & customerid)
        If pd.ReadDataItem.Read Then
            pd.formerror = pd.geterrtext("err67")
        End If
        pd.CloseData()


        If Not (Page.IsPostBack) Then

        End If


        If Page.IsPostBack And task.Value <> "edit" Then

            'Check form for errors
            If pd.formerror = "" Then
            
                pd.OpenDataWriter("reviews")
                pd.AddData("itemid", itemid, "N")
                pd.AddData("customerid", customerid, "N")
                pd.AddData("reviewdate", pd.showdate(DateTime.Now.ToShortDateString), "D")
                pd.AddData("status", 0, "N")

                If task.Value = "" Then
            
                    pd.AddFormData("rating", rating.SelectedItem.Value, "", "N", 0, 0)
                    pd.AddFormData("title", title.Text, pd.getsystext("sys125"), "T", 5, 50)
                    pd.AddFormData("comments", comments.Text, pd.getsystext("sys122"), "T", 5, maxchar)
               
                    If anonymous.Checked = True Then
                        pd.AddData("anonymous", 1, "N")
                        anonymous2.Value = "1"
                        anonliteral.Text = pd.getsystext("sys123")
                    Else
                        pd.AddData("anonymous", 0, "N")
                        anonymous2.Value = "0"
                        anonliteral.Text = ""
                    End If
                
                    'Pass variables into Hidden form (for next Postback)
                    title2.Value = title.Text
                    titleliteral.Text = title.Text
                    rating2.Value = rating.SelectedItem.Value
                    ratingliteral.Text = "<img border=0 src=""img/ratingstar" & rating.SelectedItem.Value & ".gif"">"
                    comments2.Value = comments.Text
                    commentsliteral.Text = comments2.Value
       
            
                Else
            
                    'Get data from hidden form fields
                    pd.AddFormData("rating", rating2.Value, "", "N", 0, 0)
                    pd.AddFormData("title", title2.Value, "", "T", 0, 50)
                    pd.AddFormData("comments", comments2.Value, "", "T", 0, maxchar)
                    pd.AddFormData("anonymous", anonymous2.Value, "", "N", 0, 0)
            
                End If

                If pd.formerror = "" And task.Value = "confirm" Then
                    pd.SaveData()
                    reviewposted = "Yes"
                    pd.formerror = pd.geterrtext("err66")
                    pd.pdRedirect(pd.shopurl & "item.aspx?showalert=reviewed&itemid=" & itemid)
                ElseIf pd.formerror = "" And task.Value <> "confirm" Then
                    task.Value = "confirm"
                End If
            
            
            End If


        End If

        'Re-populate fields/selection from hidden form if editing                
        If task.Value = "edit" Then
            
            title.Text = title2.Value
            comments.Text = comments2.Value
            rating.SelectedIndex = rating.Items.IndexOf(rating.Items.FindByValue(rating2.Value))
            If anonymous2.Value = "1" Then anonymous.Checked = True
        
            task.Value = ""
        
        End If


    End Sub

    Sub Page_UnLoad(ByVal Sender As Object, ByVal E As EventArgs)

        If IsNothing(pd) = False Then pd.UnLoadPDshop()

    End Sub

</script>
<%=pd.getTopHtml(pd.pg12)%>
<script language="JavaScript">

    var lcount = "<%=maxchar%>";
    function textinputcounter() {
        var reviewtext = document.getElementById('comments').value;
        var tlen = reviewtext.length;
        if (tlen > lcount) {
            reviewtext = reviewtext.substring(0, lcount);
            document.getElementById('comments').value = reviewtext;
            return false;
        }
        document.getElementById('limit').value = lcount - tlen;
    }

</script>
<script language="JavaScript">

    function editreview() {

        document.getElementById('task').value = 'edit';
        document.getElementById('pageform').submit();
    }

</script>
<%= pd.startSection("heads32")%>
<div class="form_container">
    <form method="POST" id="pageform" name="pageform" runat="server">
    <input type="hidden" id="task" runat="server" />
    <input type="hidden" id="title2" runat="server" />
    <input type="hidden" id="comments2" runat="server" />
    <input type="hidden" id="rating2" runat="server" />
    <input type="hidden" id="anonymous2" runat="server" />
    <div class="messages">
        <%=pd.getFormError()%></div>
    <div class="messages">
        <%=pd.getsystext("sys1")%></div>
    <div class="cartdata">
        <%=itemname%></div>
    <div class="messages">
        <%=pd.getsystext("sys2")%></div>
    <div class="cartdata">
        <%=itemno%></div>
    <% If task.Value = "confirm" Then%>
    <div class="messages">
        <%=pd.getsystext("sys121")%></div>
    <div class="cartdata">
        <asp:literal id="ratingliteral" text="" runat="server" />
    </div>
    <div class="messages">
        <%=pd.getsystext("sys125")%></div>
    <div class="cartdata">
        <asp:literal id="titleliteral" text="" runat="server" />
    </div>
    <div class="messages">
       <br> <%=pd.getsystext("sys122")%></div>
    <div class="cartdata">
        <asp:literal id="commentsliteral" runat="server" />
    </div>
    <div class="formheadings">
        <asp:literal id="anonliteral" text="" runat="server" />
    </div>
    <div class="formbuttons_container">
        <%=pd.getButton("butts14","","","pageform")%><%=pd.getButton("butts15","","javascript: editreview()","")%></div>
    <% Else%>
    <div class="formheadings">
       <br> <%=pd.getsystext("sys121")%></div>
    <div class="formheadings">
        <asp:dropdownlist id="rating" runat="server">
                      <asp:ListItem Value="1" Text="1 Star" />
                      <asp:ListItem Value="2" Text="2 Stars" />
                      <asp:ListItem Value="3" Text="3 Stars" />
                      <asp:ListItem Value="4" Text="4 Stars" />
                      <asp:ListItem Value="5" Text="5 Stars" />
            </asp:dropdownlist>
    </div>
    <div class="formheadings">
        <%=pd.getsystext("sys125")%></div>
    <div>
        <asp:textbox class="formfield4" id="title" runat="server" />
    </div>
    <div class="formheadings">
        <%=pd.getsystext("sys122")%></div>
    <div>
        <asp:textbox class="formfield4" onkeyup="textinputcounter()" id="comments" width="300px"
            height="100px" wrap="true" textmode="MultiLine" runat="server" />
    </div>
    <div class="messages">
        <%=pd.getsystext("sys124")%><script language="javascript">
                                        document.write("<input type=text class=formfield5 id=limit name=limit size=4 readonly value=" + lcount + ">");
        </script>
    </div>
    <div class="checkboxes_container">
        <asp:checkbox id="anonymous" runat="server" />
        <%=pd.getsystext("sys123")%>
    </div>
    <div class="formbuttons_container">
        <%=pd.getButton("butts14","","","pageform")%></div>
    <% End If%>
    </form>
</div>
<%= pd.endSection()%>
<%=pd.getBottomHtml(pd.pg12)%>