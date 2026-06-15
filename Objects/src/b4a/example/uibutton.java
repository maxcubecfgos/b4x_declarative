package b4a.example;


import anywheresoftware.b4a.BA;
import anywheresoftware.b4a.B4AClass;
import anywheresoftware.b4a.BALayout;
import anywheresoftware.b4a.debug.*;

public class uibutton extends B4AClass.ImplB4AClass implements BA.SubDelegator{
    private static java.util.HashMap<String, java.lang.reflect.Method> htSubs;
    private void innerInitialize(BA _ba) throws Exception {
        if (ba == null) {
            ba = new BA(_ba, this, htSubs, "b4a.example.uibutton");
            if (htSubs == null) {
                ba.loadHtSubs(this.getClass());
                htSubs = ba.htSubs;
            }
            
        }
        if (BA.isShellModeRuntimeCheck(ba)) 
			   this.getClass().getMethod("_class_globals", b4a.example.uibutton.class).invoke(this, new Object[] {null});
        else
            ba.raiseEvent2(null, true, "class_globals", false);
    }

 public anywheresoftware.b4a.keywords.Common __c = null;
public String _mtext = "";
public int _mcolor = 0;
public Object _mtarget = null;
public String _meventname = "";
public anywheresoftware.b4a.objects.B4XViewWrapper _mbaseview = null;
public b4a.example.main _main = null;
public b4a.example.starter _starter = null;
public b4a.example.uibutton  _backgroundcolor(int _c) throws Exception{
 //BA.debugLineNum = 21;BA.debugLine="Public Sub BackgroundColor(c As Int) As UIButton";
 //BA.debugLineNum = 22;BA.debugLine="mColor = c";
_mcolor = _c;
 //BA.debugLineNum = 23;BA.debugLine="Return Me";
if (true) return (b4a.example.uibutton)(this);
 //BA.debugLineNum = 24;BA.debugLine="End Sub";
return null;
}
public String  _class_globals() throws Exception{
 //BA.debugLineNum = 2;BA.debugLine="Sub Class_Globals";
 //BA.debugLineNum = 3;BA.debugLine="Private mText As String";
_mtext = "";
 //BA.debugLineNum = 4;BA.debugLine="Private mColor As Int";
_mcolor = 0;
 //BA.debugLineNum = 5;BA.debugLine="Private mTarget As Object";
_mtarget = new Object();
 //BA.debugLineNum = 6;BA.debugLine="Private mEventName As String";
_meventname = "";
 //BA.debugLineNum = 7;BA.debugLine="Private mBaseView As B4XView";
_mbaseview = new anywheresoftware.b4a.objects.B4XViewWrapper();
 //BA.debugLineNum = 8;BA.debugLine="End Sub";
return "";
}
public b4a.example.uibutton  _initialize(anywheresoftware.b4a.BA _ba) throws Exception{
innerInitialize(_ba);
 //BA.debugLineNum = 10;BA.debugLine="Public Sub Initialize As UIButton";
 //BA.debugLineNum = 11;BA.debugLine="mText = \"\"";
_mtext = "";
 //BA.debugLineNum = 12;BA.debugLine="mColor = Colors.LightGray";
_mcolor = __c.Colors.LightGray;
 //BA.debugLineNum = 13;BA.debugLine="Return Me";
if (true) return (b4a.example.uibutton)(this);
 //BA.debugLineNum = 14;BA.debugLine="End Sub";
return null;
}
public String  _nativebtn_click() throws Exception{
anywheresoftware.b4a.objects.ButtonWrapper _btn = null;
b4a.example.uibutton _instance = null;
 //BA.debugLineNum = 48;BA.debugLine="Private Sub NativeBtn_Click";
 //BA.debugLineNum = 49;BA.debugLine="Dim btn As Button = Sender";
_btn = new anywheresoftware.b4a.objects.ButtonWrapper();
_btn = (anywheresoftware.b4a.objects.ButtonWrapper) anywheresoftware.b4a.AbsObjectWrapper.ConvertToWrapper(new anywheresoftware.b4a.objects.ButtonWrapper(), (android.widget.Button)(__c.Sender(ba)));
 //BA.debugLineNum = 50;BA.debugLine="Dim instance As UIButton = btn.Tag";
_instance = (b4a.example.uibutton)(_btn.getTag());
 //BA.debugLineNum = 51;BA.debugLine="instance.TriggerClick";
_instance._triggerclick /*String*/ ();
 //BA.debugLineNum = 52;BA.debugLine="End Sub";
return "";
}
public b4a.example.uibutton  _onclick(Object _target,String _eventname) throws Exception{
 //BA.debugLineNum = 26;BA.debugLine="Public Sub OnClick(Target As Object, EventName As";
 //BA.debugLineNum = 27;BA.debugLine="mTarget = Target";
_mtarget = _target;
 //BA.debugLineNum = 28;BA.debugLine="mEventName = EventName";
_meventname = _eventname;
 //BA.debugLineNum = 29;BA.debugLine="Return Me";
if (true) return (b4a.example.uibutton)(this);
 //BA.debugLineNum = 30;BA.debugLine="End Sub";
return null;
}
public String  _render(anywheresoftware.b4a.objects.B4XViewWrapper _parent,int _left,int _top,int _width,int _height) throws Exception{
anywheresoftware.b4a.objects.ButtonWrapper _btn = null;
 //BA.debugLineNum = 33;BA.debugLine="Public Sub Render(Parent As B4XView, Left As Int,";
 //BA.debugLineNum = 34;BA.debugLine="If mBaseView.IsInitialized = False Then";
if (_mbaseview.IsInitialized()==__c.False) { 
 //BA.debugLineNum = 35;BA.debugLine="Dim btn As Button";
_btn = new anywheresoftware.b4a.objects.ButtonWrapper();
 //BA.debugLineNum = 36;BA.debugLine="btn.Initialize(\"NativeBtn\")";
_btn.Initialize(ba,"NativeBtn");
 //BA.debugLineNum = 37;BA.debugLine="mBaseView = btn";
_mbaseview = (anywheresoftware.b4a.objects.B4XViewWrapper) anywheresoftware.b4a.AbsObjectWrapper.ConvertToWrapper(new anywheresoftware.b4a.objects.B4XViewWrapper(), (java.lang.Object)(_btn.getObject()));
 //BA.debugLineNum = 38;BA.debugLine="mBaseView.Tag = Me ' Inyección de la instancia e";
_mbaseview.setTag(this);
 //BA.debugLineNum = 39;BA.debugLine="Parent.AddView(mBaseView, Left, Top, Width, Heig";
_parent.AddView((android.view.View)(_mbaseview.getObject()),_left,_top,_width,_height);
 };
 //BA.debugLineNum = 42;BA.debugLine="mBaseView.SetLayoutAnimated(0, Left, Top, Width,";
_mbaseview.SetLayoutAnimated((int) (0),_left,_top,_width,_height);
 //BA.debugLineNum = 44;BA.debugLine="If mBaseView.Text <> mText Then mBaseView.Text =";
if ((_mbaseview.getText()).equals(_mtext) == false) { 
_mbaseview.setText(BA.ObjectToCharSequence(_mtext));};
 //BA.debugLineNum = 45;BA.debugLine="If mBaseView.Color <> mColor Then mBaseView.Color";
if (_mbaseview.getColor()!=_mcolor) { 
_mbaseview.setColor(_mcolor);};
 //BA.debugLineNum = 46;BA.debugLine="End Sub";
return "";
}
public String  _renderbridge(Object[] _args) throws Exception{
 //BA.debugLineNum = 61;BA.debugLine="Public Sub RenderBridge(Args() As Object)";
 //BA.debugLineNum = 62;BA.debugLine="Render(Args(0), Args(1), Args(2), Args(3), Args(4";
_render((anywheresoftware.b4a.objects.B4XViewWrapper) anywheresoftware.b4a.AbsObjectWrapper.ConvertToWrapper(new anywheresoftware.b4a.objects.B4XViewWrapper(), (java.lang.Object)(_args[(int) (0)])),(int)(BA.ObjectToNumber(_args[(int) (1)])),(int)(BA.ObjectToNumber(_args[(int) (2)])),(int)(BA.ObjectToNumber(_args[(int) (3)])),(int)(BA.ObjectToNumber(_args[(int) (4)])));
 //BA.debugLineNum = 63;BA.debugLine="End Sub";
return "";
}
public b4a.example.uibutton  _text(String _t) throws Exception{
 //BA.debugLineNum = 16;BA.debugLine="Public Sub Text(t As String) As UIButton";
 //BA.debugLineNum = 17;BA.debugLine="mText = t";
_mtext = _t;
 //BA.debugLineNum = 18;BA.debugLine="Return Me";
if (true) return (b4a.example.uibutton)(this);
 //BA.debugLineNum = 19;BA.debugLine="End Sub";
return null;
}
public String  _triggerclick() throws Exception{
 //BA.debugLineNum = 54;BA.debugLine="Public Sub TriggerClick";
 //BA.debugLineNum = 55;BA.debugLine="If mTarget <> Null And mEventName <> \"\" Then";
if (_mtarget!= null && (_meventname).equals("") == false) { 
 //BA.debugLineNum = 56;BA.debugLine="CallSub(mTarget, mEventName)";
__c.CallSubNew(ba,_mtarget,_meventname);
 };
 //BA.debugLineNum = 58;BA.debugLine="End Sub";
return "";
}
public Object callSub(String sub, Object sender, Object[] args) throws Exception {
BA.senderHolder.set(sender);
if (BA.fastSubCompare(sub, "RENDERBRIDGE"))
	return _renderbridge((Object[]) args[0]);
return BA.SubDelegator.SubNotFound;
}
}
