package b4a.example;


import anywheresoftware.b4a.B4AMenuItem;
import android.app.Activity;
import android.os.Bundle;
import anywheresoftware.b4a.BA;
import anywheresoftware.b4a.BALayout;
import anywheresoftware.b4a.B4AActivity;
import anywheresoftware.b4a.ObjectWrapper;
import anywheresoftware.b4a.objects.ActivityWrapper;
import java.lang.reflect.InvocationTargetException;
import anywheresoftware.b4a.B4AUncaughtException;
import anywheresoftware.b4a.debug.*;
import java.lang.ref.WeakReference;

public class main extends Activity implements B4AActivity{
	public static main mostCurrent;
	static boolean afterFirstLayout;
	static boolean isFirst = true;
    private static boolean processGlobalsRun = false;
	BALayout layout;
	public static BA processBA;
	BA activityBA;
    ActivityWrapper _activity;
    java.util.ArrayList<B4AMenuItem> menuItems;
	public static final boolean fullScreen = false;
	public static final boolean includeTitle = false;
    public static WeakReference<Activity> previousOne;
    public static boolean dontPause;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
        mostCurrent = this;
		if (processBA == null) {
			processBA = new BA(this.getApplicationContext(), null, null, "b4a.example", "b4a.example.main");
			processBA.loadHtSubs(this.getClass());
	        float deviceScale = getApplicationContext().getResources().getDisplayMetrics().density;
	        BALayout.setDeviceScale(deviceScale);
            
		}
		else if (previousOne != null) {
			Activity p = previousOne.get();
			if (p != null && p != this) {
                BA.LogInfo("Killing previous instance (main).");
				p.finish();
			}
		}
        processBA.setActivityPaused(true);
        processBA.runHook("oncreate", this, null);
		if (!includeTitle) {
        	this.getWindow().requestFeature(android.view.Window.FEATURE_NO_TITLE);
        }
        if (fullScreen) {
        	getWindow().setFlags(android.view.WindowManager.LayoutParams.FLAG_FULLSCREEN,   
        			android.view.WindowManager.LayoutParams.FLAG_FULLSCREEN);
        }
		
        processBA.sharedProcessBA.activityBA = null;
		layout = new BALayout(this);
		setContentView(layout);
		afterFirstLayout = false;
        WaitForLayout wl = new WaitForLayout();
        if (anywheresoftware.b4a.objects.ServiceHelper.StarterHelper.startFromActivity(this, processBA, wl, false))
		    BA.handler.postDelayed(wl, 5);

	}
	static class WaitForLayout implements Runnable {
		public void run() {
			if (afterFirstLayout)
				return;
			if (mostCurrent == null)
				return;
            
			if (mostCurrent.layout.getWidth() == 0) {
				BA.handler.postDelayed(this, 5);
				return;
			}
			mostCurrent.layout.getLayoutParams().height = mostCurrent.layout.getHeight();
			mostCurrent.layout.getLayoutParams().width = mostCurrent.layout.getWidth();
			afterFirstLayout = true;
			mostCurrent.afterFirstLayout();
		}
	}
	private void afterFirstLayout() {
        if (this != mostCurrent)
			return;
		activityBA = new BA(this, layout, processBA, "b4a.example", "b4a.example.main");
        
        processBA.sharedProcessBA.activityBA = new java.lang.ref.WeakReference<BA>(activityBA);
        anywheresoftware.b4a.objects.ViewWrapper.lastId = 0;
        _activity = new ActivityWrapper(activityBA, "activity");
        anywheresoftware.b4a.Msgbox.isDismissing = false;
        if (BA.isShellModeRuntimeCheck(processBA)) {
			if (isFirst)
				processBA.raiseEvent2(null, true, "SHELL", false);
			processBA.raiseEvent2(null, true, "CREATE", true, "b4a.example.main", processBA, activityBA, _activity, anywheresoftware.b4a.keywords.Common.Density, mostCurrent);
			_activity.reinitializeForShell(activityBA, "activity");
		}
        initializeProcessGlobals();		
        initializeGlobals();
        
        BA.LogInfo("** Activity (main) Create " + (isFirst ? "(first time)" : "") + " **");
        processBA.raiseEvent2(null, true, "activity_create", false, isFirst);
		isFirst = false;
		if (this != mostCurrent)
			return;
        processBA.setActivityPaused(false);
        BA.LogInfo("** Activity (main) Resume **");
        processBA.raiseEvent(null, "activity_resume");
        if (android.os.Build.VERSION.SDK_INT >= 11) {
			try {
				android.app.Activity.class.getMethod("invalidateOptionsMenu").invoke(this,(Object[]) null);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}

	}
	public void addMenuItem(B4AMenuItem item) {
		if (menuItems == null)
			menuItems = new java.util.ArrayList<B4AMenuItem>();
		menuItems.add(item);
	}
	@Override
	public boolean onCreateOptionsMenu(android.view.Menu menu) {
		super.onCreateOptionsMenu(menu);
        try {
            if (processBA.subExists("activity_actionbarhomeclick")) {
                Class.forName("android.app.ActionBar").getMethod("setHomeButtonEnabled", boolean.class).invoke(
                    getClass().getMethod("getActionBar").invoke(this), true);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        if (processBA.runHook("oncreateoptionsmenu", this, new Object[] {menu}))
            return true;
		if (menuItems == null)
			return false;
		for (B4AMenuItem bmi : menuItems) {
			android.view.MenuItem mi = menu.add(bmi.title);
			if (bmi.drawable != null)
				mi.setIcon(bmi.drawable);
            if (android.os.Build.VERSION.SDK_INT >= 11) {
				try {
                    if (bmi.addToBar) {
				        android.view.MenuItem.class.getMethod("setShowAsAction", int.class).invoke(mi, 1);
                    }
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
			mi.setOnMenuItemClickListener(new B4AMenuItemsClickListener(bmi.eventName.toLowerCase(BA.cul)));
		}
        
		return true;
	}   
 @Override
 public boolean onOptionsItemSelected(android.view.MenuItem item) {
    if (item.getItemId() == 16908332) {
        processBA.raiseEvent(null, "activity_actionbarhomeclick");
        return true;
    }
    else
        return super.onOptionsItemSelected(item); 
}
@Override
 public boolean onPrepareOptionsMenu(android.view.Menu menu) {
    super.onPrepareOptionsMenu(menu);
    processBA.runHook("onprepareoptionsmenu", this, new Object[] {menu});
    return true;
    
 }
 protected void onStart() {
    super.onStart();
    processBA.runHook("onstart", this, null);
}
 protected void onStop() {
    super.onStop();
    processBA.runHook("onstop", this, null);
}
    public void onWindowFocusChanged(boolean hasFocus) {
       super.onWindowFocusChanged(hasFocus);
       if (processBA.subExists("activity_windowfocuschanged"))
           processBA.raiseEvent2(null, true, "activity_windowfocuschanged", false, hasFocus);
    }
	private class B4AMenuItemsClickListener implements android.view.MenuItem.OnMenuItemClickListener {
		private final String eventName;
		public B4AMenuItemsClickListener(String eventName) {
			this.eventName = eventName;
		}
		public boolean onMenuItemClick(android.view.MenuItem item) {
			processBA.raiseEventFromUI(item.getTitle(), eventName + "_click");
			return true;
		}
	}
    public static Class<?> getObject() {
		return main.class;
	}
    private Boolean onKeySubExist = null;
    private Boolean onKeyUpSubExist = null;
	@Override
	public boolean onKeyDown(int keyCode, android.view.KeyEvent event) {
        if (processBA.runHook("onkeydown", this, new Object[] {keyCode, event}))
            return true;
		if (onKeySubExist == null)
			onKeySubExist = processBA.subExists("activity_keypress");
		if (onKeySubExist) {
			if (keyCode == anywheresoftware.b4a.keywords.constants.KeyCodes.KEYCODE_BACK &&
					android.os.Build.VERSION.SDK_INT >= 18) {
				HandleKeyDelayed hk = new HandleKeyDelayed();
				hk.kc = keyCode;
				BA.handler.post(hk);
				return true;
			}
			else {
				boolean res = new HandleKeyDelayed().runDirectly(keyCode);
				if (res)
					return true;
			}
		}
		return super.onKeyDown(keyCode, event);
	}
	private class HandleKeyDelayed implements Runnable {
		int kc;
		public void run() {
			runDirectly(kc);
		}
		public boolean runDirectly(int keyCode) {
			Boolean res =  (Boolean)processBA.raiseEvent2(_activity, false, "activity_keypress", false, keyCode);
			if (res == null || res == true) {
                return true;
            }
            else if (keyCode == anywheresoftware.b4a.keywords.constants.KeyCodes.KEYCODE_BACK) {
				finish();
				return true;
			}
            return false;
		}
		
	}
    @Override
	public boolean onKeyUp(int keyCode, android.view.KeyEvent event) {
        if (processBA.runHook("onkeyup", this, new Object[] {keyCode, event}))
            return true;
		if (onKeyUpSubExist == null)
			onKeyUpSubExist = processBA.subExists("activity_keyup");
		if (onKeyUpSubExist) {
			Boolean res =  (Boolean)processBA.raiseEvent2(_activity, false, "activity_keyup", false, keyCode);
			if (res == null || res == true)
				return true;
		}
		return super.onKeyUp(keyCode, event);
	}
	@Override
	public void onNewIntent(android.content.Intent intent) {
        super.onNewIntent(intent);
		this.setIntent(intent);
        processBA.runHook("onnewintent", this, new Object[] {intent});
	}
    @Override 
	public void onPause() {
		super.onPause();
        if (_activity == null)
            return;
        if (this != mostCurrent)
			return;
		anywheresoftware.b4a.Msgbox.dismiss(true);
        if (!dontPause)
            BA.LogInfo("** Activity (main) Pause, UserClosed = " + activityBA.activity.isFinishing() + " **");
        else
            BA.LogInfo("** Activity (main) Pause event (activity is not paused). **");
        if (mostCurrent != null)
            processBA.raiseEvent2(_activity, true, "activity_pause", false, activityBA.activity.isFinishing());		
        if (!dontPause) {
            processBA.setActivityPaused(true);
            mostCurrent = null;
        }

        if (!activityBA.activity.isFinishing())
			previousOne = new WeakReference<Activity>(this);
        anywheresoftware.b4a.Msgbox.isDismissing = false;
        processBA.runHook("onpause", this, null);
	}

	@Override
	public void onDestroy() {
        super.onDestroy();
		previousOne = null;
        processBA.runHook("ondestroy", this, null);
	}
    @Override 
	public void onResume() {
		super.onResume();
        mostCurrent = this;
        anywheresoftware.b4a.Msgbox.isDismissing = false;
        if (activityBA != null) { //will be null during activity create (which waits for AfterLayout).
        	ResumeMessage rm = new ResumeMessage(mostCurrent);
        	BA.handler.post(rm);
        }
        processBA.runHook("onresume", this, null);
	}
    private static class ResumeMessage implements Runnable {
    	private final WeakReference<Activity> activity;
    	public ResumeMessage(Activity activity) {
    		this.activity = new WeakReference<Activity>(activity);
    	}
		public void run() {
            main mc = mostCurrent;
			if (mc == null || mc != activity.get())
				return;
			processBA.setActivityPaused(false);
            BA.LogInfo("** Activity (main) Resume **");
            if (mc != mostCurrent)
                return;
		    processBA.raiseEvent(mc._activity, "activity_resume", (Object[])null);
		}
    }
	@Override
	protected void onActivityResult(int requestCode, int resultCode,
	      android.content.Intent data) {
		processBA.onActivityResult(requestCode, resultCode, data);
        processBA.runHook("onactivityresult", this, new Object[] {requestCode, resultCode});
	}
	private static void initializeGlobals() {
		processBA.raiseEvent2(null, true, "globals", false, (Object[])null);
	}
    public void onRequestPermissionsResult(int requestCode,
        String permissions[], int[] grantResults) {
        for (int i = 0;i < permissions.length;i++) {
            Object[] o = new Object[] {permissions[i], grantResults[i] == 0};
            processBA.raiseEventFromDifferentThread(null,null, 0, "activity_permissionresult", true, o);
        }
            
    }

public anywheresoftware.b4a.keywords.Common __c = null;
public static int _counter = 0;
public anywheresoftware.b4a.objects.B4XViewWrapper _rootcontainer = null;
public b4a.example.uiappbar _miappbar = null;
public b4a.example.uilabel _lbltitulo = null;
public b4a.example.uilabel _lblvalor = null;
public b4a.example.uibutton _btnrestar = null;
public b4a.example.uibutton _btnsumar = null;
public b4a.example.uispace _spaceboton = null;
public b4a.example.uispace _spacecol = null;
public b4a.example.uispace _spaceseccion = null;
public b4a.example.uirow _filabotones = null;
public b4a.example.uicenter _centrobotones = null;
public b4a.example.uicolumn _cuerpocard = null;
public b4a.example.uipadding _paddingcard = null;
public b4a.example.uicard _targetacontenedor = null;
public b4a.example.uicolumn _layoutcontenido = null;
public b4a.example.uicenter _centradorgeneral = null;
public b4a.example.uipadding _paddingpantalla = null;
public b4a.example.uiscaffold _pantallaprincipal = null;
public b4a.example.starter _starter = null;

public static boolean isAnyActivityVisible() {
    boolean vis = false;
vis = vis | (main.mostCurrent != null);
return vis;}
public static String  _activity_create(boolean _firsttime) throws Exception{
 //BA.debugLineNum = 42;BA.debugLine="Sub Activity_Create(FirstTime As Boolean)";
 //BA.debugLineNum = 43;BA.debugLine="RootContainer = Activity";
mostCurrent._rootcontainer = (anywheresoftware.b4a.objects.B4XViewWrapper) anywheresoftware.b4a.AbsObjectWrapper.ConvertToWrapper(new anywheresoftware.b4a.objects.B4XViewWrapper(), (java.lang.Object)(mostCurrent._activity.getObject()));
 //BA.debugLineNum = 44;BA.debugLine="RootContainer.Color = 0xF5F5F5";
mostCurrent._rootcontainer.setColor(((int)0xf5f5f5));
 //BA.debugLineNum = 47;BA.debugLine="MiAppBar.Initialize _         .Title(\"B4A Declara";
mostCurrent._miappbar._initialize /*b4a.example.uiappbar*/ (mostCurrent.activityBA)._title /*b4a.example.uiappbar*/ ("B4A Declarativo")._backgroundcolor /*b4a.example.uiappbar*/ (((int)0xff1976d2));
 //BA.debugLineNum = 51;BA.debugLine="lblTitulo.Initialize.Text(\"MONITOR DE ESTADO\").Si";
mostCurrent._lbltitulo._initialize /*b4a.example.uilabel*/ (mostCurrent.activityBA)._text /*b4a.example.uilabel*/ ("MONITOR DE ESTADO")._size /*b4a.example.uilabel*/ ((float) (14))._color /*b4a.example.uilabel*/ (((int)0xff757575));
 //BA.debugLineNum = 52;BA.debugLine="lblValor.Initialize.Size(64).Color(0xFF1976D2)";
mostCurrent._lblvalor._initialize /*b4a.example.uilabel*/ (mostCurrent.activityBA)._size /*b4a.example.uilabel*/ ((float) (64))._color /*b4a.example.uilabel*/ (((int)0xff1976d2));
 //BA.debugLineNum = 55;BA.debugLine="btnRestar.Initialize.Text(\"DECREMENTAR\").Backgrou";
mostCurrent._btnrestar._initialize /*b4a.example.uibutton*/ (mostCurrent.activityBA)._text /*b4a.example.uibutton*/ ("DECREMENTAR")._backgroundcolor /*b4a.example.uibutton*/ (((int)0xffe0e0e0))._onclick /*b4a.example.uibutton*/ (main.getObject(),"Decrement_Click");
 //BA.debugLineNum = 56;BA.debugLine="btnSumar.Initialize.Text(\"INCREMENTAR\").Backgroun";
mostCurrent._btnsumar._initialize /*b4a.example.uibutton*/ (mostCurrent.activityBA)._text /*b4a.example.uibutton*/ ("INCREMENTAR")._backgroundcolor /*b4a.example.uibutton*/ (((int)0xff2196f3))._onclick /*b4a.example.uibutton*/ (main.getObject(),"Increment_Click");
 //BA.debugLineNum = 59;BA.debugLine="SpaceBoton.Initialize : SpaceCol.Initialize : Spa";
mostCurrent._spaceboton._initialize /*b4a.example.uispace*/ (mostCurrent.activityBA);
 //BA.debugLineNum = 59;BA.debugLine="SpaceBoton.Initialize : SpaceCol.Initialize : Spa";
mostCurrent._spacecol._initialize /*b4a.example.uispace*/ (mostCurrent.activityBA);
 //BA.debugLineNum = 59;BA.debugLine="SpaceBoton.Initialize : SpaceCol.Initialize : Spa";
mostCurrent._spaceseccion._initialize /*b4a.example.uispace*/ (mostCurrent.activityBA);
 //BA.debugLineNum = 63;BA.debugLine="FilaBotones.Initialize _         .AddChild(btnRes";
mostCurrent._filabotones._initialize /*b4a.example.uirow*/ (mostCurrent.activityBA)._addchild /*b4a.example.uirow*/ ((Object)(mostCurrent._btnrestar))._addchild /*b4a.example.uirow*/ ((Object)(mostCurrent._spaceboton))._addchild /*b4a.example.uirow*/ ((Object)(mostCurrent._btnsumar));
 //BA.debugLineNum = 68;BA.debugLine="CentroBotones.Initialize.Child(FilaBotones)";
mostCurrent._centrobotones._initialize /*b4a.example.uicenter*/ (mostCurrent.activityBA)._child /*b4a.example.uicenter*/ ((Object)(mostCurrent._filabotones));
 //BA.debugLineNum = 71;BA.debugLine="CuerpoCard.Initialize _         .AddChild(lblTitu";
mostCurrent._cuerpocard._initialize /*b4a.example.uicolumn*/ (mostCurrent.activityBA)._addchild /*b4a.example.uicolumn*/ ((Object)(mostCurrent._lbltitulo))._addchild /*b4a.example.uicolumn*/ ((Object)(mostCurrent._lblvalor))._addchild /*b4a.example.uicolumn*/ ((Object)(mostCurrent._spacecol))._addchild /*b4a.example.uicolumn*/ ((Object)(mostCurrent._centrobotones));
 //BA.debugLineNum = 77;BA.debugLine="PaddingCard.Initialize.All(24dip).Child(CuerpoCar";
mostCurrent._paddingcard._initialize /*b4a.example.uipadding*/ (mostCurrent.activityBA)._all /*b4a.example.uipadding*/ (anywheresoftware.b4a.keywords.Common.DipToCurrent((int) (24)))._child /*b4a.example.uipadding*/ ((Object)(mostCurrent._cuerpocard));
 //BA.debugLineNum = 79;BA.debugLine="TargetaContenedor.Initialize _         .Backgroun";
mostCurrent._targetacontenedor._initialize /*b4a.example.uicard*/ (mostCurrent.activityBA)._backgroundcolor /*b4a.example.uicard*/ (anywheresoftware.b4a.keywords.Common.Colors.White)._cornerradius /*b4a.example.uicard*/ (anywheresoftware.b4a.keywords.Common.DipToCurrent((int) (12)))._child /*b4a.example.uicard*/ ((Object)(mostCurrent._paddingcard));
 //BA.debugLineNum = 85;BA.debugLine="LayoutContenido.Initialize _         .AddChild(Ta";
mostCurrent._layoutcontenido._initialize /*b4a.example.uicolumn*/ (mostCurrent.activityBA)._addchild /*b4a.example.uicolumn*/ ((Object)(mostCurrent._targetacontenedor));
 //BA.debugLineNum = 89;BA.debugLine="CentradorGeneral.Initialize.Child(LayoutContenido";
mostCurrent._centradorgeneral._initialize /*b4a.example.uicenter*/ (mostCurrent.activityBA)._child /*b4a.example.uicenter*/ ((Object)(mostCurrent._layoutcontenido));
 //BA.debugLineNum = 90;BA.debugLine="PaddingPantalla.Initialize.All(16dip).Child(Centr";
mostCurrent._paddingpantalla._initialize /*b4a.example.uipadding*/ (mostCurrent.activityBA)._all /*b4a.example.uipadding*/ (anywheresoftware.b4a.keywords.Common.DipToCurrent((int) (16)))._child /*b4a.example.uipadding*/ ((Object)(mostCurrent._centradorgeneral));
 //BA.debugLineNum = 93;BA.debugLine="PantallaPrincipal.Initialize _         .AppBar(Mi";
mostCurrent._pantallaprincipal._initialize /*b4a.example.uiscaffold*/ (mostCurrent.activityBA)._appbar /*b4a.example.uiscaffold*/ ((Object)(mostCurrent._miappbar))._body /*b4a.example.uiscaffold*/ ((Object)(mostCurrent._paddingpantalla));
 //BA.debugLineNum = 97;BA.debugLine="BuildUI";
_buildui();
 //BA.debugLineNum = 98;BA.debugLine="End Sub";
return "";
}
public static String  _buildui() throws Exception{
 //BA.debugLineNum = 105;BA.debugLine="Private Sub BuildUI";
 //BA.debugLineNum = 106;BA.debugLine="lblValor.Text(\"\" & Counter)";
mostCurrent._lblvalor._text /*b4a.example.uilabel*/ (""+BA.NumberToString(_counter));
 //BA.debugLineNum = 109;BA.debugLine="If Counter < 0 Then";
if (_counter<0) { 
 //BA.debugLineNum = 110;BA.debugLine="lblValor.Color(Colors.Red)";
mostCurrent._lblvalor._color /*b4a.example.uilabel*/ (anywheresoftware.b4a.keywords.Common.Colors.Red);
 }else {
 //BA.debugLineNum = 112;BA.debugLine="lblValor.Color(0xFF1976D2)";
mostCurrent._lblvalor._color /*b4a.example.uilabel*/ (((int)0xff1976d2));
 };
 //BA.debugLineNum = 116;BA.debugLine="PantallaPrincipal.Render(RootContainer, 0, 0, Roo";
mostCurrent._pantallaprincipal._render /*String*/ (mostCurrent._rootcontainer,(int) (0),(int) (0),mostCurrent._rootcontainer.getWidth(),mostCurrent._rootcontainer.getHeight());
 //BA.debugLineNum = 117;BA.debugLine="End Sub";
return "";
}
public static String  _decrement_click() throws Exception{
 //BA.debugLineNum = 124;BA.debugLine="Sub Decrement_Click";
 //BA.debugLineNum = 125;BA.debugLine="SetState(Counter - 1)";
_setstate((int) (_counter-1));
 //BA.debugLineNum = 126;BA.debugLine="End Sub";
return "";
}
public static String  _globals() throws Exception{
 //BA.debugLineNum = 19;BA.debugLine="Sub Globals";
 //BA.debugLineNum = 20;BA.debugLine="Private RootContainer As B4XView";
mostCurrent._rootcontainer = new anywheresoftware.b4a.objects.B4XViewWrapper();
 //BA.debugLineNum = 23;BA.debugLine="Private MiAppBar As UIAppBar";
mostCurrent._miappbar = new b4a.example.uiappbar();
 //BA.debugLineNum = 24;BA.debugLine="Private lblTitulo As UILabel";
mostCurrent._lbltitulo = new b4a.example.uilabel();
 //BA.debugLineNum = 25;BA.debugLine="Private lblValor As UILabel";
mostCurrent._lblvalor = new b4a.example.uilabel();
 //BA.debugLineNum = 26;BA.debugLine="Private btnRestar As UIButton";
mostCurrent._btnrestar = new b4a.example.uibutton();
 //BA.debugLineNum = 27;BA.debugLine="Private btnSumar As UIButton";
mostCurrent._btnsumar = new b4a.example.uibutton();
 //BA.debugLineNum = 29;BA.debugLine="Private SpaceBoton, SpaceCol, SpaceSeccion As UIS";
mostCurrent._spaceboton = new b4a.example.uispace();
mostCurrent._spacecol = new b4a.example.uispace();
mostCurrent._spaceseccion = new b4a.example.uispace();
 //BA.debugLineNum = 30;BA.debugLine="Private FilaBotones As UIRow";
mostCurrent._filabotones = new b4a.example.uirow();
 //BA.debugLineNum = 31;BA.debugLine="Private CentroBotones As UICenter";
mostCurrent._centrobotones = new b4a.example.uicenter();
 //BA.debugLineNum = 32;BA.debugLine="Private CuerpoCard As UIColumn";
mostCurrent._cuerpocard = new b4a.example.uicolumn();
 //BA.debugLineNum = 33;BA.debugLine="Private PaddingCard As UIPadding";
mostCurrent._paddingcard = new b4a.example.uipadding();
 //BA.debugLineNum = 34;BA.debugLine="Private TargetaContenedor As UICard";
mostCurrent._targetacontenedor = new b4a.example.uicard();
 //BA.debugLineNum = 36;BA.debugLine="Private LayoutContenido As UIColumn";
mostCurrent._layoutcontenido = new b4a.example.uicolumn();
 //BA.debugLineNum = 37;BA.debugLine="Private CentradorGeneral As UICenter";
mostCurrent._centradorgeneral = new b4a.example.uicenter();
 //BA.debugLineNum = 38;BA.debugLine="Private PaddingPantalla As UIPadding";
mostCurrent._paddingpantalla = new b4a.example.uipadding();
 //BA.debugLineNum = 39;BA.debugLine="Private PantallaPrincipal As UIScaffold";
mostCurrent._pantallaprincipal = new b4a.example.uiscaffold();
 //BA.debugLineNum = 40;BA.debugLine="End Sub";
return "";
}
public static String  _increment_click() throws Exception{
 //BA.debugLineNum = 120;BA.debugLine="Sub Increment_Click";
 //BA.debugLineNum = 121;BA.debugLine="SetState(Counter + 1)";
_setstate((int) (_counter+1));
 //BA.debugLineNum = 122;BA.debugLine="End Sub";
return "";
}

public static void initializeProcessGlobals() {
    
    if (main.processGlobalsRun == false) {
	    main.processGlobalsRun = true;
		try {
		        main._process_globals();
starter._process_globals();
		
        } catch (Exception e) {
			throw new RuntimeException(e);
		}
    }
}public static String  _process_globals() throws Exception{
 //BA.debugLineNum = 15;BA.debugLine="Sub Process_Globals";
 //BA.debugLineNum = 16;BA.debugLine="Private Counter As Int = 0";
_counter = (int) (0);
 //BA.debugLineNum = 17;BA.debugLine="End Sub";
return "";
}
public static String  _setstate(int _newcountervalue) throws Exception{
 //BA.debugLineNum = 100;BA.debugLine="Private Sub SetState(NewCounterValue As Int)";
 //BA.debugLineNum = 101;BA.debugLine="Counter = NewCounterValue";
_counter = _newcountervalue;
 //BA.debugLineNum = 102;BA.debugLine="BuildUI";
_buildui();
 //BA.debugLineNum = 103;BA.debugLine="End Sub";
return "";
}
}
