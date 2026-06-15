package b4a.example;


import anywheresoftware.b4a.BA;
import anywheresoftware.b4a.B4AClass;
import anywheresoftware.b4a.BALayout;
import anywheresoftware.b4a.debug.*;

public class uilabel extends B4AClass.ImplB4AClass implements BA.SubDelegator{
    private static java.util.HashMap<String, java.lang.reflect.Method> htSubs;
    private void innerInitialize(BA _ba) throws Exception {
        if (ba == null) {
            ba = new BA(_ba, this, htSubs, "b4a.example.uilabel");
            if (htSubs == null) {
                ba.loadHtSubs(this.getClass());
                htSubs = ba.htSubs;
            }
            
        }
        if (BA.isShellModeRuntimeCheck(ba)) 
			   this.getClass().getMethod("_class_globals", b4a.example.uilabel.class).invoke(this, new Object[] {null});
        else
            ba.raiseEvent2(null, true, "class_globals", false);
    }

 public anywheresoftware.b4a.keywords.Common __c = null;
public String _mtext = "";
public float _mtextsize = 0f;
public int _mtextcolor = 0;
public int _mgravity = 0;
public anywheresoftware.b4a.objects.B4XViewWrapper _mbaseview = null;
public b4a.example.main _main = null;
public b4a.example.starter _starter = null;
public b4a.example.uilabel  _alignleft() throws Exception{
 //BA.debugLineNum = 33;BA.debugLine="Public Sub AlignLeft As UILabel";
 //BA.debugLineNum = 34;BA.debugLine="mGravity = Bit.Or(Gravity.LEFT, Gravity.CENTER_VE";
_mgravity = __c.Bit.Or(__c.Gravity.LEFT,__c.Gravity.CENTER_VERTICAL);
 //BA.debugLineNum = 35;BA.debugLine="Return Me";
if (true) return (b4a.example.uilabel)(this);
 //BA.debugLineNum = 36;BA.debugLine="End Sub";
return null;
}
public String  _class_globals() throws Exception{
 //BA.debugLineNum = 2;BA.debugLine="Sub Class_Globals";
 //BA.debugLineNum = 3;BA.debugLine="Private mText As String";
_mtext = "";
 //BA.debugLineNum = 4;BA.debugLine="Private mTextSize As Float";
_mtextsize = 0f;
 //BA.debugLineNum = 5;BA.debugLine="Private mTextColor As Int";
_mtextcolor = 0;
 //BA.debugLineNum = 6;BA.debugLine="Private mGravity As Int";
_mgravity = 0;
 //BA.debugLineNum = 7;BA.debugLine="Private mBaseView As B4XView";
_mbaseview = new anywheresoftware.b4a.objects.B4XViewWrapper();
 //BA.debugLineNum = 8;BA.debugLine="End Sub";
return "";
}
public b4a.example.uilabel  _color(int _c) throws Exception{
 //BA.debugLineNum = 28;BA.debugLine="Public Sub Color(c As Int) As UILabel";
 //BA.debugLineNum = 29;BA.debugLine="mTextColor = c";
_mtextcolor = _c;
 //BA.debugLineNum = 30;BA.debugLine="Return Me";
if (true) return (b4a.example.uilabel)(this);
 //BA.debugLineNum = 31;BA.debugLine="End Sub";
return null;
}
public b4a.example.uilabel  _initialize(anywheresoftware.b4a.BA _ba) throws Exception{
innerInitialize(_ba);
 //BA.debugLineNum = 10;BA.debugLine="Public Sub Initialize As UILabel";
 //BA.debugLineNum = 11;BA.debugLine="mText = \"\"";
_mtext = "";
 //BA.debugLineNum = 12;BA.debugLine="mTextSize = 16";
_mtextsize = (float) (16);
 //BA.debugLineNum = 13;BA.debugLine="mTextColor = Colors.Black";
_mtextcolor = __c.Colors.Black;
 //BA.debugLineNum = 14;BA.debugLine="mGravity = Bit.Or(Gravity.CENTER_HORIZONTAL, Grav";
_mgravity = __c.Bit.Or(__c.Gravity.CENTER_HORIZONTAL,__c.Gravity.CENTER_VERTICAL);
 //BA.debugLineNum = 15;BA.debugLine="Return Me";
if (true) return (b4a.example.uilabel)(this);
 //BA.debugLineNum = 16;BA.debugLine="End Sub";
return null;
}
public String  _render(anywheresoftware.b4a.objects.B4XViewWrapper _parent,int _left,int _top,int _width,int _height) throws Exception{
anywheresoftware.b4a.objects.LabelWrapper _lbl = null;
anywheresoftware.b4a.objects.LabelWrapper _nativelabel = null;
 //BA.debugLineNum = 38;BA.debugLine="Public Sub Render(Parent As B4XView, Left As Int,";
 //BA.debugLineNum = 39;BA.debugLine="If mBaseView.IsInitialized = False Then";
if (_mbaseview.IsInitialized()==__c.False) { 
 //BA.debugLineNum = 40;BA.debugLine="Dim lbl As Label";
_lbl = new anywheresoftware.b4a.objects.LabelWrapper();
 //BA.debugLineNum = 41;BA.debugLine="lbl.Initialize(\"\")";
_lbl.Initialize(ba,"");
 //BA.debugLineNum = 42;BA.debugLine="mBaseView = lbl";
_mbaseview = (anywheresoftware.b4a.objects.B4XViewWrapper) anywheresoftware.b4a.AbsObjectWrapper.ConvertToWrapper(new anywheresoftware.b4a.objects.B4XViewWrapper(), (java.lang.Object)(_lbl.getObject()));
 //BA.debugLineNum = 43;BA.debugLine="Parent.AddView(mBaseView, Left, Top, Width, Heig";
_parent.AddView((android.view.View)(_mbaseview.getObject()),_left,_top,_width,_height);
 };
 //BA.debugLineNum = 46;BA.debugLine="mBaseView.SetLayoutAnimated(0, Left, Top, Width,";
_mbaseview.SetLayoutAnimated((int) (0),_left,_top,_width,_height);
 //BA.debugLineNum = 48;BA.debugLine="If mBaseView.Text <> mText Then mBaseView.Text =";
if ((_mbaseview.getText()).equals(_mtext) == false) { 
_mbaseview.setText(BA.ObjectToCharSequence(_mtext));};
 //BA.debugLineNum = 51;BA.debugLine="Dim nativeLabel As Label = mBaseView";
_nativelabel = new anywheresoftware.b4a.objects.LabelWrapper();
_nativelabel = (anywheresoftware.b4a.objects.LabelWrapper) anywheresoftware.b4a.AbsObjectWrapper.ConvertToWrapper(new anywheresoftware.b4a.objects.LabelWrapper(), (android.widget.TextView)(_mbaseview.getObject()));
 //BA.debugLineNum = 52;BA.debugLine="nativeLabel.Gravity = mGravity";
_nativelabel.setGravity(_mgravity);
 //BA.debugLineNum = 54;BA.debugLine="If nativeLabel.TextSize <> mTextSize Then nativeL";
if (_nativelabel.getTextSize()!=_mtextsize) { 
_nativelabel.setTextSize(_mtextsize);};
 //BA.debugLineNum = 55;BA.debugLine="If nativeLabel.TextColor <> mTextColor Then nativ";
if (_nativelabel.getTextColor()!=_mtextcolor) { 
_nativelabel.setTextColor(_mtextcolor);};
 //BA.debugLineNum = 56;BA.debugLine="End Sub";
return "";
}
public String  _renderbridge(Object[] _args) throws Exception{
 //BA.debugLineNum = 59;BA.debugLine="Public Sub RenderBridge(Args() As Object)";
 //BA.debugLineNum = 60;BA.debugLine="Render(Args(0), Args(1), Args(2), Args(3), Args(4";
_render((anywheresoftware.b4a.objects.B4XViewWrapper) anywheresoftware.b4a.AbsObjectWrapper.ConvertToWrapper(new anywheresoftware.b4a.objects.B4XViewWrapper(), (java.lang.Object)(_args[(int) (0)])),(int)(BA.ObjectToNumber(_args[(int) (1)])),(int)(BA.ObjectToNumber(_args[(int) (2)])),(int)(BA.ObjectToNumber(_args[(int) (3)])),(int)(BA.ObjectToNumber(_args[(int) (4)])));
 //BA.debugLineNum = 61;BA.debugLine="End Sub";
return "";
}
public b4a.example.uilabel  _size(float _s) throws Exception{
 //BA.debugLineNum = 23;BA.debugLine="Public Sub Size(s As Float) As UILabel";
 //BA.debugLineNum = 24;BA.debugLine="mTextSize = s";
_mtextsize = _s;
 //BA.debugLineNum = 25;BA.debugLine="Return Me";
if (true) return (b4a.example.uilabel)(this);
 //BA.debugLineNum = 26;BA.debugLine="End Sub";
return null;
}
public b4a.example.uilabel  _text(String _t) throws Exception{
 //BA.debugLineNum = 18;BA.debugLine="Public Sub Text(t As String) As UILabel";
 //BA.debugLineNum = 19;BA.debugLine="mText = t";
_mtext = _t;
 //BA.debugLineNum = 20;BA.debugLine="Return Me";
if (true) return (b4a.example.uilabel)(this);
 //BA.debugLineNum = 21;BA.debugLine="End Sub";
return null;
}
public Object callSub(String sub, Object sender, Object[] args) throws Exception {
BA.senderHolder.set(sender);
if (BA.fastSubCompare(sub, "RENDERBRIDGE"))
	return _renderbridge((Object[]) args[0]);
return BA.SubDelegator.SubNotFound;
}
}
