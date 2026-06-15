package b4a.example;


import anywheresoftware.b4a.BA;
import anywheresoftware.b4a.B4AClass;
import anywheresoftware.b4a.BALayout;
import anywheresoftware.b4a.debug.*;

public class uiappbar extends B4AClass.ImplB4AClass implements BA.SubDelegator{
    private static java.util.HashMap<String, java.lang.reflect.Method> htSubs;
    private void innerInitialize(BA _ba) throws Exception {
        if (ba == null) {
            ba = new BA(_ba, this, htSubs, "b4a.example.uiappbar");
            if (htSubs == null) {
                ba.loadHtSubs(this.getClass());
                htSubs = ba.htSubs;
            }
            
        }
        if (BA.isShellModeRuntimeCheck(ba)) 
			   this.getClass().getMethod("_class_globals", b4a.example.uiappbar.class).invoke(this, new Object[] {null});
        else
            ba.raiseEvent2(null, true, "class_globals", false);
    }

 public anywheresoftware.b4a.keywords.Common __c = null;
public String _mtitle = "";
public int _mbgcolor = 0;
public int _mtextcolor = 0;
public anywheresoftware.b4a.objects.B4XViewWrapper _mbaseview = null;
public b4a.example.main _main = null;
public b4a.example.starter _starter = null;
public b4a.example.uiappbar  _backgroundcolor(int _c) throws Exception{
 //BA.debugLineNum = 21;BA.debugLine="Public Sub BackgroundColor(c As Int) As UIAppBar";
 //BA.debugLineNum = 22;BA.debugLine="mBgColor = c";
_mbgcolor = _c;
 //BA.debugLineNum = 23;BA.debugLine="Return Me";
if (true) return (b4a.example.uiappbar)(this);
 //BA.debugLineNum = 24;BA.debugLine="End Sub";
return null;
}
public String  _class_globals() throws Exception{
 //BA.debugLineNum = 2;BA.debugLine="Sub Class_Globals";
 //BA.debugLineNum = 3;BA.debugLine="Private mTitle As String";
_mtitle = "";
 //BA.debugLineNum = 4;BA.debugLine="Private mBgColor As Int";
_mbgcolor = 0;
 //BA.debugLineNum = 5;BA.debugLine="Private mTextColor As Int";
_mtextcolor = 0;
 //BA.debugLineNum = 6;BA.debugLine="Private mBaseView As B4XView";
_mbaseview = new anywheresoftware.b4a.objects.B4XViewWrapper();
 //BA.debugLineNum = 7;BA.debugLine="End Sub";
return "";
}
public b4a.example.uiappbar  _initialize(anywheresoftware.b4a.BA _ba) throws Exception{
innerInitialize(_ba);
 //BA.debugLineNum = 9;BA.debugLine="Public Sub Initialize As UIAppBar";
 //BA.debugLineNum = 10;BA.debugLine="mTitle = \"\"";
_mtitle = "";
 //BA.debugLineNum = 11;BA.debugLine="mBgColor = 0xFF1976D2 ' Azul Material estándar";
_mbgcolor = ((int)0xff1976d2);
 //BA.debugLineNum = 12;BA.debugLine="mTextColor = Colors.White";
_mtextcolor = __c.Colors.White;
 //BA.debugLineNum = 13;BA.debugLine="Return Me";
if (true) return (b4a.example.uiappbar)(this);
 //BA.debugLineNum = 14;BA.debugLine="End Sub";
return null;
}
public String  _render(anywheresoftware.b4a.objects.B4XViewWrapper _parent,int _left,int _top,int _width,int _height) throws Exception{
anywheresoftware.b4a.objects.PanelWrapper _pnl = null;
anywheresoftware.b4a.objects.LabelWrapper _lbl = null;
anywheresoftware.b4a.objects.B4XViewWrapper _xlbl = null;
 //BA.debugLineNum = 31;BA.debugLine="Public Sub Render(Parent As B4XView, Left As Int,";
 //BA.debugLineNum = 32;BA.debugLine="If mBaseView.IsInitialized = False Then";
if (_mbaseview.IsInitialized()==__c.False) { 
 //BA.debugLineNum = 33;BA.debugLine="Dim pnl As Panel";
_pnl = new anywheresoftware.b4a.objects.PanelWrapper();
 //BA.debugLineNum = 34;BA.debugLine="pnl.Initialize(\"\")";
_pnl.Initialize(ba,"");
 //BA.debugLineNum = 35;BA.debugLine="mBaseView = pnl";
_mbaseview = (anywheresoftware.b4a.objects.B4XViewWrapper) anywheresoftware.b4a.AbsObjectWrapper.ConvertToWrapper(new anywheresoftware.b4a.objects.B4XViewWrapper(), (java.lang.Object)(_pnl.getObject()));
 //BA.debugLineNum = 36;BA.debugLine="Parent.AddView(mBaseView, Left, Top, Width, Heig";
_parent.AddView((android.view.View)(_mbaseview.getObject()),_left,_top,_width,_height);
 };
 //BA.debugLineNum = 39;BA.debugLine="mBaseView.SetLayoutAnimated(0, Left, Top, Width,";
_mbaseview.SetLayoutAnimated((int) (0),_left,_top,_width,_height);
 //BA.debugLineNum = 40;BA.debugLine="mBaseView.Color = mBgColor";
_mbaseview.setColor(_mbgcolor);
 //BA.debugLineNum = 43;BA.debugLine="Dim lbl As Label";
_lbl = new anywheresoftware.b4a.objects.LabelWrapper();
 //BA.debugLineNum = 44;BA.debugLine="If mBaseView.NumberOfViews = 0 Then";
if (_mbaseview.getNumberOfViews()==0) { 
 //BA.debugLineNum = 45;BA.debugLine="lbl.Initialize(\"\")";
_lbl.Initialize(ba,"");
 //BA.debugLineNum = 46;BA.debugLine="Dim xLbl As B4XView = lbl";
_xlbl = new anywheresoftware.b4a.objects.B4XViewWrapper();
_xlbl = (anywheresoftware.b4a.objects.B4XViewWrapper) anywheresoftware.b4a.AbsObjectWrapper.ConvertToWrapper(new anywheresoftware.b4a.objects.B4XViewWrapper(), (java.lang.Object)(_lbl.getObject()));
 //BA.debugLineNum = 47;BA.debugLine="mBaseView.AddView(xLbl, 16dip, 0, Width - 32dip,";
_mbaseview.AddView((android.view.View)(_xlbl.getObject()),__c.DipToCurrent((int) (16)),(int) (0),(int) (_width-__c.DipToCurrent((int) (32))),_height);
 }else {
 //BA.debugLineNum = 49;BA.debugLine="Dim xLbl As B4XView = mBaseView.GetView(0)";
_xlbl = new anywheresoftware.b4a.objects.B4XViewWrapper();
_xlbl = _mbaseview.GetView((int) (0));
 //BA.debugLineNum = 50;BA.debugLine="lbl = xLbl";
_lbl = (anywheresoftware.b4a.objects.LabelWrapper) anywheresoftware.b4a.AbsObjectWrapper.ConvertToWrapper(new anywheresoftware.b4a.objects.LabelWrapper(), (android.widget.TextView)(_xlbl.getObject()));
 };
 //BA.debugLineNum = 53;BA.debugLine="lbl.Text = mTitle";
_lbl.setText(BA.ObjectToCharSequence(_mtitle));
 //BA.debugLineNum = 54;BA.debugLine="lbl.TextColor = mTextColor";
_lbl.setTextColor(_mtextcolor);
 //BA.debugLineNum = 55;BA.debugLine="lbl.TextSize = 20";
_lbl.setTextSize((float) (20));
 //BA.debugLineNum = 56;BA.debugLine="lbl.Gravity = Bit.Or(Gravity.LEFT, Gravity.CENTER";
_lbl.setGravity(__c.Bit.Or(__c.Gravity.LEFT,__c.Gravity.CENTER_VERTICAL));
 //BA.debugLineNum = 57;BA.debugLine="End Sub";
return "";
}
public String  _renderbridge(Object[] _args) throws Exception{
 //BA.debugLineNum = 59;BA.debugLine="Public Sub RenderBridge(Args() As Object)";
 //BA.debugLineNum = 60;BA.debugLine="Render(Args(0), Args(1), Args(2), Args(3), Args(4";
_render((anywheresoftware.b4a.objects.B4XViewWrapper) anywheresoftware.b4a.AbsObjectWrapper.ConvertToWrapper(new anywheresoftware.b4a.objects.B4XViewWrapper(), (java.lang.Object)(_args[(int) (0)])),(int)(BA.ObjectToNumber(_args[(int) (1)])),(int)(BA.ObjectToNumber(_args[(int) (2)])),(int)(BA.ObjectToNumber(_args[(int) (3)])),(int)(BA.ObjectToNumber(_args[(int) (4)])));
 //BA.debugLineNum = 61;BA.debugLine="End Sub";
return "";
}
public b4a.example.uiappbar  _textcolor(int _c) throws Exception{
 //BA.debugLineNum = 26;BA.debugLine="Public Sub TextColor(c As Int) As UIAppBar";
 //BA.debugLineNum = 27;BA.debugLine="mTextColor = c";
_mtextcolor = _c;
 //BA.debugLineNum = 28;BA.debugLine="Return Me";
if (true) return (b4a.example.uiappbar)(this);
 //BA.debugLineNum = 29;BA.debugLine="End Sub";
return null;
}
public b4a.example.uiappbar  _title(String _t) throws Exception{
 //BA.debugLineNum = 16;BA.debugLine="Public Sub Title(t As String) As UIAppBar";
 //BA.debugLineNum = 17;BA.debugLine="mTitle = t";
_mtitle = _t;
 //BA.debugLineNum = 18;BA.debugLine="Return Me";
if (true) return (b4a.example.uiappbar)(this);
 //BA.debugLineNum = 19;BA.debugLine="End Sub";
return null;
}
public Object callSub(String sub, Object sender, Object[] args) throws Exception {
BA.senderHolder.set(sender);
if (BA.fastSubCompare(sub, "RENDERBRIDGE"))
	return _renderbridge((Object[]) args[0]);
return BA.SubDelegator.SubNotFound;
}
}
