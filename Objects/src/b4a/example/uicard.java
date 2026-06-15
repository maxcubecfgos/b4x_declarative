package b4a.example;


import anywheresoftware.b4a.BA;
import anywheresoftware.b4a.B4AClass;
import anywheresoftware.b4a.BALayout;
import anywheresoftware.b4a.debug.*;

public class uicard extends B4AClass.ImplB4AClass implements BA.SubDelegator{
    private static java.util.HashMap<String, java.lang.reflect.Method> htSubs;
    private void innerInitialize(BA _ba) throws Exception {
        if (ba == null) {
            ba = new BA(_ba, this, htSubs, "b4a.example.uicard");
            if (htSubs == null) {
                ba.loadHtSubs(this.getClass());
                htSubs = ba.htSubs;
            }
            
        }
        if (BA.isShellModeRuntimeCheck(ba)) 
			   this.getClass().getMethod("_class_globals", b4a.example.uicard.class).invoke(this, new Object[] {null});
        else
            ba.raiseEvent2(null, true, "class_globals", false);
    }

 public anywheresoftware.b4a.keywords.Common __c = null;
public Object _mchild = null;
public anywheresoftware.b4a.objects.B4XViewWrapper _mbaseview = null;
public int _mbgcolor = 0;
public int _mradius = 0;
public b4a.example.main _main = null;
public b4a.example.starter _starter = null;
public b4a.example.uicard  _backgroundcolor(int _c) throws Exception{
 //BA.debugLineNum = 16;BA.debugLine="Public Sub BackgroundColor(c As Int) As UICard";
 //BA.debugLineNum = 17;BA.debugLine="mBgColor = c";
_mbgcolor = _c;
 //BA.debugLineNum = 18;BA.debugLine="Return Me";
if (true) return (b4a.example.uicard)(this);
 //BA.debugLineNum = 19;BA.debugLine="End Sub";
return null;
}
public b4a.example.uicard  _child(Object _c) throws Exception{
 //BA.debugLineNum = 26;BA.debugLine="Public Sub Child(c As Object) As UICard";
 //BA.debugLineNum = 27;BA.debugLine="mChild = c";
_mchild = _c;
 //BA.debugLineNum = 28;BA.debugLine="Return Me";
if (true) return (b4a.example.uicard)(this);
 //BA.debugLineNum = 29;BA.debugLine="End Sub";
return null;
}
public String  _class_globals() throws Exception{
 //BA.debugLineNum = 2;BA.debugLine="Sub Class_Globals";
 //BA.debugLineNum = 3;BA.debugLine="Private mChild As Object";
_mchild = new Object();
 //BA.debugLineNum = 4;BA.debugLine="Private mBaseView As B4XView";
_mbaseview = new anywheresoftware.b4a.objects.B4XViewWrapper();
 //BA.debugLineNum = 5;BA.debugLine="Private mBgColor As Int";
_mbgcolor = 0;
 //BA.debugLineNum = 6;BA.debugLine="Private mRadius As Int";
_mradius = 0;
 //BA.debugLineNum = 7;BA.debugLine="End Sub";
return "";
}
public b4a.example.uicard  _cornerradius(int _r) throws Exception{
 //BA.debugLineNum = 21;BA.debugLine="Public Sub CornerRadius(r As Int) As UICard";
 //BA.debugLineNum = 22;BA.debugLine="mRadius = r";
_mradius = _r;
 //BA.debugLineNum = 23;BA.debugLine="Return Me";
if (true) return (b4a.example.uicard)(this);
 //BA.debugLineNum = 24;BA.debugLine="End Sub";
return null;
}
public b4a.example.uicard  _initialize(anywheresoftware.b4a.BA _ba) throws Exception{
innerInitialize(_ba);
 //BA.debugLineNum = 9;BA.debugLine="Public Sub Initialize As UICard";
 //BA.debugLineNum = 10;BA.debugLine="mBgColor = Colors.White";
_mbgcolor = __c.Colors.White;
 //BA.debugLineNum = 11;BA.debugLine="mRadius = 12dip ' Ajustado a 12dip para que haga";
_mradius = __c.DipToCurrent((int) (12));
 //BA.debugLineNum = 12;BA.debugLine="mChild = Null";
_mchild = __c.Null;
 //BA.debugLineNum = 13;BA.debugLine="Return Me";
if (true) return (b4a.example.uicard)(this);
 //BA.debugLineNum = 14;BA.debugLine="End Sub";
return null;
}
public String  _render(anywheresoftware.b4a.objects.B4XViewWrapper _parent,int _left,int _top,int _width,int _height) throws Exception{
anywheresoftware.b4a.objects.PanelWrapper _pnl = null;
anywheresoftware.b4a.objects.PanelWrapper _nativepanel = null;
anywheresoftware.b4a.objects.drawable.ColorDrawable _cd = null;
Object[] _dimensions = null;
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
 //BA.debugLineNum = 42;BA.debugLine="Dim NativePanel As Panel = mBaseView";
_nativepanel = new anywheresoftware.b4a.objects.PanelWrapper();
_nativepanel = (anywheresoftware.b4a.objects.PanelWrapper) anywheresoftware.b4a.AbsObjectWrapper.ConvertToWrapper(new anywheresoftware.b4a.objects.PanelWrapper(), (android.view.ViewGroup)(_mbaseview.getObject()));
 //BA.debugLineNum = 43;BA.debugLine="Dim cd As ColorDrawable";
_cd = new anywheresoftware.b4a.objects.drawable.ColorDrawable();
 //BA.debugLineNum = 44;BA.debugLine="cd.Initialize2(mBgColor, mRadius, 1dip, 0xFFE0E0E";
_cd.Initialize2(_mbgcolor,_mradius,__c.DipToCurrent((int) (1)),((int)0xffe0e0e0));
 //BA.debugLineNum = 45;BA.debugLine="NativePanel.Background = cd";
_nativepanel.setBackground((android.graphics.drawable.Drawable)(_cd.getObject()));
 //BA.debugLineNum = 48;BA.debugLine="If mChild <> Null And SubExists(mChild, \"RenderBr";
if (_mchild!= null && __c.SubExists(ba,_mchild,"RenderBridge")) { 
 //BA.debugLineNum = 49;BA.debugLine="Dim dimensions(5) As Object";
_dimensions = new Object[(int) (5)];
{
int d0 = _dimensions.length;
for (int i0 = 0;i0 < d0;i0++) {
_dimensions[i0] = new Object();
}
}
;
 //BA.debugLineNum = 50;BA.debugLine="dimensions(0) = mBaseView";
_dimensions[(int) (0)] = (Object)(_mbaseview.getObject());
 //BA.debugLineNum = 51;BA.debugLine="dimensions(1) = 0";
_dimensions[(int) (1)] = (Object)(0);
 //BA.debugLineNum = 52;BA.debugLine="dimensions(2) = 0";
_dimensions[(int) (2)] = (Object)(0);
 //BA.debugLineNum = 53;BA.debugLine="dimensions(3) = Width";
_dimensions[(int) (3)] = (Object)(_width);
 //BA.debugLineNum = 54;BA.debugLine="dimensions(4) = Height";
_dimensions[(int) (4)] = (Object)(_height);
 //BA.debugLineNum = 55;BA.debugLine="CallSub3(mChild, \"RenderBridge\", dimensions, Nul";
__c.CallSubNew3(ba,_mchild,"RenderBridge",(Object)(_dimensions),__c.Null);
 };
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
public Object callSub(String sub, Object sender, Object[] args) throws Exception {
BA.senderHolder.set(sender);
if (BA.fastSubCompare(sub, "RENDERBRIDGE"))
	return _renderbridge((Object[]) args[0]);
return BA.SubDelegator.SubNotFound;
}
}
