package b4a.example;


import anywheresoftware.b4a.BA;
import anywheresoftware.b4a.B4AClass;
import anywheresoftware.b4a.BALayout;
import anywheresoftware.b4a.debug.*;

public class uiscaffold extends B4AClass.ImplB4AClass implements BA.SubDelegator{
    private static java.util.HashMap<String, java.lang.reflect.Method> htSubs;
    private void innerInitialize(BA _ba) throws Exception {
        if (ba == null) {
            ba = new BA(_ba, this, htSubs, "b4a.example.uiscaffold");
            if (htSubs == null) {
                ba.loadHtSubs(this.getClass());
                htSubs = ba.htSubs;
            }
            
        }
        if (BA.isShellModeRuntimeCheck(ba)) 
			   this.getClass().getMethod("_class_globals", b4a.example.uiscaffold.class).invoke(this, new Object[] {null});
        else
            ba.raiseEvent2(null, true, "class_globals", false);
    }

 public anywheresoftware.b4a.keywords.Common __c = null;
public Object _mappbar = null;
public Object _mbody = null;
public anywheresoftware.b4a.objects.B4XViewWrapper _mbaseview = null;
public b4a.example.main _main = null;
public b4a.example.starter _starter = null;
public b4a.example.uiscaffold  _appbar(Object _bar) throws Exception{
 //BA.debugLineNum = 14;BA.debugLine="Public Sub AppBar(bar As Object) As UIScaffold";
 //BA.debugLineNum = 15;BA.debugLine="mAppBar = bar";
_mappbar = _bar;
 //BA.debugLineNum = 16;BA.debugLine="Return Me";
if (true) return (b4a.example.uiscaffold)(this);
 //BA.debugLineNum = 17;BA.debugLine="End Sub";
return null;
}
public b4a.example.uiscaffold  _body(Object _b) throws Exception{
 //BA.debugLineNum = 19;BA.debugLine="Public Sub Body(b As Object) As UIScaffold";
 //BA.debugLineNum = 20;BA.debugLine="mBody = b";
_mbody = _b;
 //BA.debugLineNum = 21;BA.debugLine="Return Me";
if (true) return (b4a.example.uiscaffold)(this);
 //BA.debugLineNum = 22;BA.debugLine="End Sub";
return null;
}
public String  _class_globals() throws Exception{
 //BA.debugLineNum = 2;BA.debugLine="Sub Class_Globals";
 //BA.debugLineNum = 3;BA.debugLine="Private mAppBar As Object";
_mappbar = new Object();
 //BA.debugLineNum = 4;BA.debugLine="Private mBody As Object";
_mbody = new Object();
 //BA.debugLineNum = 5;BA.debugLine="Private mBaseView As B4XView";
_mbaseview = new anywheresoftware.b4a.objects.B4XViewWrapper();
 //BA.debugLineNum = 6;BA.debugLine="End Sub";
return "";
}
public b4a.example.uiscaffold  _initialize(anywheresoftware.b4a.BA _ba) throws Exception{
innerInitialize(_ba);
 //BA.debugLineNum = 8;BA.debugLine="Public Sub Initialize As UIScaffold";
 //BA.debugLineNum = 9;BA.debugLine="mAppBar = Null";
_mappbar = __c.Null;
 //BA.debugLineNum = 10;BA.debugLine="mBody = Null";
_mbody = __c.Null;
 //BA.debugLineNum = 11;BA.debugLine="Return Me";
if (true) return (b4a.example.uiscaffold)(this);
 //BA.debugLineNum = 12;BA.debugLine="End Sub";
return null;
}
public String  _render(anywheresoftware.b4a.objects.B4XViewWrapper _parent,int _left,int _top,int _width,int _height) throws Exception{
anywheresoftware.b4a.objects.PanelWrapper _pnl = null;
int _appbarheight = 0;
Object[] _bardims = null;
Object[] _bodydims = null;
 //BA.debugLineNum = 24;BA.debugLine="Public Sub Render(Parent As B4XView, Left As Int,";
 //BA.debugLineNum = 25;BA.debugLine="If mBaseView.IsInitialized = False Then";
if (_mbaseview.IsInitialized()==__c.False) { 
 //BA.debugLineNum = 26;BA.debugLine="Dim pnl As Panel";
_pnl = new anywheresoftware.b4a.objects.PanelWrapper();
 //BA.debugLineNum = 27;BA.debugLine="pnl.Initialize(\"\")";
_pnl.Initialize(ba,"");
 //BA.debugLineNum = 28;BA.debugLine="mBaseView = pnl";
_mbaseview = (anywheresoftware.b4a.objects.B4XViewWrapper) anywheresoftware.b4a.AbsObjectWrapper.ConvertToWrapper(new anywheresoftware.b4a.objects.B4XViewWrapper(), (java.lang.Object)(_pnl.getObject()));
 //BA.debugLineNum = 29;BA.debugLine="mBaseView.Color = Colors.Transparent";
_mbaseview.setColor(__c.Colors.Transparent);
 //BA.debugLineNum = 30;BA.debugLine="Parent.AddView(mBaseView, Left, Top, Width, Heig";
_parent.AddView((android.view.View)(_mbaseview.getObject()),_left,_top,_width,_height);
 };
 //BA.debugLineNum = 33;BA.debugLine="mBaseView.SetLayoutAnimated(0, Left, Top, Width,";
_mbaseview.SetLayoutAnimated((int) (0),_left,_top,_width,_height);
 //BA.debugLineNum = 35;BA.debugLine="Dim appBarHeight As Int = 0";
_appbarheight = (int) (0);
 //BA.debugLineNum = 38;BA.debugLine="If mAppBar <> Null And SubExists(mAppBar, \"Render";
if (_mappbar!= null && __c.SubExists(ba,_mappbar,"RenderBridge")) { 
 //BA.debugLineNum = 39;BA.debugLine="appBarHeight = 56dip";
_appbarheight = __c.DipToCurrent((int) (56));
 //BA.debugLineNum = 40;BA.debugLine="Dim barDims(5) As Object";
_bardims = new Object[(int) (5)];
{
int d0 = _bardims.length;
for (int i0 = 0;i0 < d0;i0++) {
_bardims[i0] = new Object();
}
}
;
 //BA.debugLineNum = 41;BA.debugLine="barDims(0) = mBaseView";
_bardims[(int) (0)] = (Object)(_mbaseview.getObject());
 //BA.debugLineNum = 42;BA.debugLine="barDims(1) = 0";
_bardims[(int) (1)] = (Object)(0);
 //BA.debugLineNum = 43;BA.debugLine="barDims(2) = 0";
_bardims[(int) (2)] = (Object)(0);
 //BA.debugLineNum = 44;BA.debugLine="barDims(3) = Width";
_bardims[(int) (3)] = (Object)(_width);
 //BA.debugLineNum = 45;BA.debugLine="barDims(4) = appBarHeight";
_bardims[(int) (4)] = (Object)(_appbarheight);
 //BA.debugLineNum = 46;BA.debugLine="CallSub3(mAppBar, \"RenderBridge\", barDims, Null)";
__c.CallSubNew3(ba,_mappbar,"RenderBridge",(Object)(_bardims),__c.Null);
 };
 //BA.debugLineNum = 50;BA.debugLine="If mBody <> Null And SubExists(mBody, \"RenderBrid";
if (_mbody!= null && __c.SubExists(ba,_mbody,"RenderBridge")) { 
 //BA.debugLineNum = 51;BA.debugLine="Dim bodyDims(5) As Object";
_bodydims = new Object[(int) (5)];
{
int d0 = _bodydims.length;
for (int i0 = 0;i0 < d0;i0++) {
_bodydims[i0] = new Object();
}
}
;
 //BA.debugLineNum = 52;BA.debugLine="bodyDims(0) = mBaseView";
_bodydims[(int) (0)] = (Object)(_mbaseview.getObject());
 //BA.debugLineNum = 53;BA.debugLine="bodyDims(1) = 0";
_bodydims[(int) (1)] = (Object)(0);
 //BA.debugLineNum = 54;BA.debugLine="bodyDims(2) = appBarHeight";
_bodydims[(int) (2)] = (Object)(_appbarheight);
 //BA.debugLineNum = 55;BA.debugLine="bodyDims(3) = Width";
_bodydims[(int) (3)] = (Object)(_width);
 //BA.debugLineNum = 56;BA.debugLine="bodyDims(4) = Height - appBarHeight";
_bodydims[(int) (4)] = (Object)(_height-_appbarheight);
 //BA.debugLineNum = 57;BA.debugLine="CallSub3(mBody, \"RenderBridge\", bodyDims, Null)";
__c.CallSubNew3(ba,_mbody,"RenderBridge",(Object)(_bodydims),__c.Null);
 };
 //BA.debugLineNum = 59;BA.debugLine="End Sub";
return "";
}
public String  _renderbridge(Object[] _args) throws Exception{
 //BA.debugLineNum = 61;BA.debugLine="Public Sub RenderBridge(Args() As Object)";
 //BA.debugLineNum = 62;BA.debugLine="Render(Args(0), Args(1), Args(2), Args(3), Args(4";
_render((anywheresoftware.b4a.objects.B4XViewWrapper) anywheresoftware.b4a.AbsObjectWrapper.ConvertToWrapper(new anywheresoftware.b4a.objects.B4XViewWrapper(), (java.lang.Object)(_args[(int) (0)])),(int)(BA.ObjectToNumber(_args[(int) (1)])),(int)(BA.ObjectToNumber(_args[(int) (2)])),(int)(BA.ObjectToNumber(_args[(int) (3)])),(int)(BA.ObjectToNumber(_args[(int) (4)])));
 //BA.debugLineNum = 63;BA.debugLine="End Sub";
return "";
}
public Object callSub(String sub, Object sender, Object[] args) throws Exception {
BA.senderHolder.set(sender);
if (BA.fastSubCompare(sub, "RENDERBRIDGE"))
	return _renderbridge((Object[]) args[0]);
return BA.SubDelegator.SubNotFound;
}
}
