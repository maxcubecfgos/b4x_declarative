package b4a.example;


import anywheresoftware.b4a.BA;
import anywheresoftware.b4a.B4AClass;
import anywheresoftware.b4a.BALayout;
import anywheresoftware.b4a.debug.*;

public class uirow extends B4AClass.ImplB4AClass implements BA.SubDelegator{
    private static java.util.HashMap<String, java.lang.reflect.Method> htSubs;
    private void innerInitialize(BA _ba) throws Exception {
        if (ba == null) {
            ba = new BA(_ba, this, htSubs, "b4a.example.uirow");
            if (htSubs == null) {
                ba.loadHtSubs(this.getClass());
                htSubs = ba.htSubs;
            }
            
        }
        if (BA.isShellModeRuntimeCheck(ba)) 
			   this.getClass().getMethod("_class_globals", b4a.example.uirow.class).invoke(this, new Object[] {null});
        else
            ba.raiseEvent2(null, true, "class_globals", false);
    }

 public anywheresoftware.b4a.keywords.Common __c = null;
public anywheresoftware.b4a.objects.collections.List _mchildren = null;
public anywheresoftware.b4a.objects.B4XViewWrapper _mbaseview = null;
public b4a.example.main _main = null;
public b4a.example.starter _starter = null;
public b4a.example.uirow  _addchild(Object _component) throws Exception{
 //BA.debugLineNum = 12;BA.debugLine="Public Sub AddChild(Component As Object) As UIRow";
 //BA.debugLineNum = 13;BA.debugLine="mChildren.Add(Component)";
_mchildren.Add(_component);
 //BA.debugLineNum = 14;BA.debugLine="Return Me";
if (true) return (b4a.example.uirow)(this);
 //BA.debugLineNum = 15;BA.debugLine="End Sub";
return null;
}
public String  _class_globals() throws Exception{
 //BA.debugLineNum = 2;BA.debugLine="Sub Class_Globals";
 //BA.debugLineNum = 3;BA.debugLine="Private mChildren As List";
_mchildren = new anywheresoftware.b4a.objects.collections.List();
 //BA.debugLineNum = 4;BA.debugLine="Private mBaseView As B4XView";
_mbaseview = new anywheresoftware.b4a.objects.B4XViewWrapper();
 //BA.debugLineNum = 5;BA.debugLine="End Sub";
return "";
}
public b4a.example.uirow  _initialize(anywheresoftware.b4a.BA _ba) throws Exception{
innerInitialize(_ba);
 //BA.debugLineNum = 7;BA.debugLine="Public Sub Initialize As UIRow";
 //BA.debugLineNum = 8;BA.debugLine="mChildren.Initialize";
_mchildren.Initialize();
 //BA.debugLineNum = 9;BA.debugLine="Return Me";
if (true) return (b4a.example.uirow)(this);
 //BA.debugLineNum = 10;BA.debugLine="End Sub";
return null;
}
public String  _render(anywheresoftware.b4a.objects.B4XViewWrapper _parent,int _left,int _top,int _width,int _height) throws Exception{
anywheresoftware.b4a.objects.PanelWrapper _pnl = null;
int _currentleft = 0;
int _childwidth = 0;
Object _child = null;
Object[] _dimensions = null;
 //BA.debugLineNum = 17;BA.debugLine="Public Sub Render(Parent As B4XView, Left As Int,";
 //BA.debugLineNum = 18;BA.debugLine="If mBaseView.IsInitialized = False Then";
if (_mbaseview.IsInitialized()==__c.False) { 
 //BA.debugLineNum = 19;BA.debugLine="Dim pnl As Panel";
_pnl = new anywheresoftware.b4a.objects.PanelWrapper();
 //BA.debugLineNum = 20;BA.debugLine="pnl.Initialize(\"\")";
_pnl.Initialize(ba,"");
 //BA.debugLineNum = 21;BA.debugLine="mBaseView = pnl";
_mbaseview = (anywheresoftware.b4a.objects.B4XViewWrapper) anywheresoftware.b4a.AbsObjectWrapper.ConvertToWrapper(new anywheresoftware.b4a.objects.B4XViewWrapper(), (java.lang.Object)(_pnl.getObject()));
 //BA.debugLineNum = 22;BA.debugLine="Parent.AddView(mBaseView, Left, Top, Width, Heig";
_parent.AddView((android.view.View)(_mbaseview.getObject()),_left,_top,_width,_height);
 };
 //BA.debugLineNum = 25;BA.debugLine="mBaseView.SetLayoutAnimated(0, Left, Top, Width,";
_mbaseview.SetLayoutAnimated((int) (0),_left,_top,_width,_height);
 //BA.debugLineNum = 27;BA.debugLine="If mChildren.Size = 0 Then Return";
if (_mchildren.getSize()==0) { 
if (true) return "";};
 //BA.debugLineNum = 29;BA.debugLine="Dim currentLeft As Int = 0";
_currentleft = (int) (0);
 //BA.debugLineNum = 30;BA.debugLine="Dim childWidth As Int = Width / mChildren.Size";
_childwidth = (int) (_width/(double)_mchildren.getSize());
 //BA.debugLineNum = 32;BA.debugLine="For Each child As Object In mChildren";
{
final anywheresoftware.b4a.BA.IterableList group11 = _mchildren;
final int groupLen11 = group11.getSize()
;int index11 = 0;
;
for (; index11 < groupLen11;index11++){
_child = group11.Get(index11);
 //BA.debugLineNum = 33;BA.debugLine="Dim dimensions(5) As Object";
_dimensions = new Object[(int) (5)];
{
int d0 = _dimensions.length;
for (int i0 = 0;i0 < d0;i0++) {
_dimensions[i0] = new Object();
}
}
;
 //BA.debugLineNum = 34;BA.debugLine="dimensions(0) = mBaseView";
_dimensions[(int) (0)] = (Object)(_mbaseview.getObject());
 //BA.debugLineNum = 35;BA.debugLine="dimensions(1) = currentLeft";
_dimensions[(int) (1)] = (Object)(_currentleft);
 //BA.debugLineNum = 36;BA.debugLine="dimensions(2) = 0";
_dimensions[(int) (2)] = (Object)(0);
 //BA.debugLineNum = 37;BA.debugLine="dimensions(3) = childWidth";
_dimensions[(int) (3)] = (Object)(_childwidth);
 //BA.debugLineNum = 38;BA.debugLine="dimensions(4) = Height";
_dimensions[(int) (4)] = (Object)(_height);
 //BA.debugLineNum = 41;BA.debugLine="If SubExists(child, \"RenderBridge\") Then";
if (__c.SubExists(ba,_child,"RenderBridge")) { 
 //BA.debugLineNum = 42;BA.debugLine="CallSub3(child, \"RenderBridge\", dimensions, Nul";
__c.CallSubNew3(ba,_child,"RenderBridge",(Object)(_dimensions),__c.Null);
 }else {
 //BA.debugLineNum = 44;BA.debugLine="Log(\"Error crítico: El objeto \" & GetType(child";
__c.LogImpl("52228251","Error crítico: El objeto "+__c.GetType(_child)+" no tiene implementado RenderBridge",0);
 };
 //BA.debugLineNum = 47;BA.debugLine="currentLeft = currentLeft + childWidth";
_currentleft = (int) (_currentleft+_childwidth);
 }
};
 //BA.debugLineNum = 49;BA.debugLine="End Sub";
return "";
}
public String  _renderbridge(Object[] _args) throws Exception{
 //BA.debugLineNum = 51;BA.debugLine="Public Sub RenderBridge(Args() As Object)";
 //BA.debugLineNum = 52;BA.debugLine="Render(Args(0), Args(1), Args(2), Args(3), Args(4";
_render((anywheresoftware.b4a.objects.B4XViewWrapper) anywheresoftware.b4a.AbsObjectWrapper.ConvertToWrapper(new anywheresoftware.b4a.objects.B4XViewWrapper(), (java.lang.Object)(_args[(int) (0)])),(int)(BA.ObjectToNumber(_args[(int) (1)])),(int)(BA.ObjectToNumber(_args[(int) (2)])),(int)(BA.ObjectToNumber(_args[(int) (3)])),(int)(BA.ObjectToNumber(_args[(int) (4)])));
 //BA.debugLineNum = 53;BA.debugLine="End Sub";
return "";
}
public Object callSub(String sub, Object sender, Object[] args) throws Exception {
BA.senderHolder.set(sender);
if (BA.fastSubCompare(sub, "RENDERBRIDGE"))
	return _renderbridge((Object[]) args[0]);
return BA.SubDelegator.SubNotFound;
}
}
