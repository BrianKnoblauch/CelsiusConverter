MODULE CelsiusConverter;

FROM RealStr IMPORT RealToStr;
FROM SYSTEM  IMPORT ADR, CAST;
FROM Windows IMPORT BeginPaint, BOOL, CreateSolidBrush, CreateWindowEx, CS_SET, CW_USEDEFAULT, DefWindowProc, DestroyWindow, DispatchMessage, EndPaint,
                    FillRect, GetBkColor, GetDlgItemInt, GetMessage, HDC, HWND, IDC_ARROW, IDI_APPLICATION, InvalidateRect, LoadCursor, LoadIcon, LPARAM,
                    LRESULT, MB_ICONEXCLAMATION, MB_OK, MessageBox, MSG, MyInstance, PAINTSTRUCT, PostQuitMessage, RECT, RegisterClass, ShowWindow,
		    SW_SHOWNORMAL, TextOut, TranslateMessage, UINT, WM_CLOSE, WM_COMMAND, WM_DESTROY, WM_PAINT, WNDCLASS, WPARAM, WS_CHILD,
		    WS_EX_CLIENTEDGE, WS_SYSMENU, WS_VISIBLE;

CONST
     g_szClassName = "myWindowClass";

VAR
     fahrenheit     : ARRAY [0..10] OF CHAR;
     invalidaterect : RECT;

PROCEDURE ["StdCall"] WndProc(hwnd : HWND; msg : UINT; wParam : WPARAM;  lParam : LPARAM): LRESULT;
VAR
     hdc            : HDC;
     input          : INTEGER;
     ps             : PAINTSTRUCT;
     success        : BOOL;

BEGIN
    CASE msg OF
    | WM_COMMAND :
      (* TODO - Crashes on negative values *)
      input := GetDlgItemInt(hwnd, 0, success, TRUE);
      IF success THEN
	   RealToStr(FLOAT(input) * 1.8 + 32.0, fahrenheit);
      ELSE
	   fahrenheit := "          ";	   
      END; (* IF *)
      InvalidateRect(hwnd, invalidaterect, FALSE);
      RETURN 0;
    | WM_PAINT   :      
      hdc := BeginPaint(hwnd, ps);
      TextOut(hdc, 5, 5, "Celsius", 7);
      TextOut(hdc, 90, 5, ":", 1);
      TextOut(hdc, 5, 45, "Fahrenheit", 10);
      TextOut(hdc, 90, 45, ":", 1);
      FillRect(hdc, invalidaterect, CreateSolidBrush(GetBkColor(hdc)));
      TextOut(hdc, 110, 45, fahrenheit, 10);
      EndPaint(hwnd, ps);
      RETURN 0;
    | WM_CLOSE   :
      DestroyWindow(hwnd);
    | WM_DESTROY :
      PostQuitMessage(0);
    ELSE RETURN DefWindowProc(hwnd, msg, wParam, lParam);
    END; (* CASE *)
    RETURN 0;    
END WndProc;

VAR
    className       : ARRAY [0..14] OF CHAR;
    hwnd            : HWND;
    inputhwnd       : HWND;
    Msg             : MSG;
    wc              : WNDCLASS;

BEGIN
    (* Register the Window Class *)
    wc.style         := CAST(CS_SET, NIL);
    wc.lpfnWndProc   := WndProc;
    wc.cbClsExtra    := 0;
    wc.cbWndExtra    := 0;
    wc.hInstance     := MyInstance();
    wc.hIcon         := LoadIcon(NIL, IDI_APPLICATION);
    wc.hCursor       := LoadCursor(NIL, IDC_ARROW);
    wc.lpszMenuName  := NIL;
    className        := g_szClassName;
    wc.lpszClassName := ADR(className);

    IF RegisterClass(wc)=0 THEN
       MessageBox(NIL, "Window Class registration failed!", "Error!", MB_ICONEXCLAMATION + MB_OK);
       RETURN ;
    END;
               
    (* Create the Window *)
    hwnd := CreateWindowEx(WS_EX_CLIENTEDGE, g_szClassName, "Celsius Converter", WS_VISIBLE + WS_SYSMENU, CW_USEDEFAULT, CW_USEDEFAULT,
			   240, 120, NIL, NIL, MyInstance(), NIL);
    IF hwnd = NIL THEN
       MessageBox(NIL, "Window Creation failed!", "Error!", MB_ICONEXCLAMATION + MB_OK);
       RETURN ;
    END;

    invalidaterect.left := 110;
    invalidaterect.top := 45;
    invalidaterect.right := 190;
    invalidaterect.bottom := 65;					    
    inputhwnd := CreateWindowEx(WS_EX_CLIENTEDGE, "Edit", "", WS_CHILD, 110, 5, 80, 20, hwnd, NIL, MyInstance(), NIL);    
    ShowWindow(hwnd, SW_SHOWNORMAL);
    ShowWindow(inputhwnd, SW_SHOWNORMAL);
            
    (* The Message Loop *)
    WHILE GetMessage( Msg, NIL, 0, 0) DO
       TranslateMessage(Msg);
       DispatchMessage(Msg);
    END;
END CelsiusConverter.
