MODULE CelsiusConverter;

FROM SYSTEM  IMPORT ADR;
FROM Windows IMPORT CreateWindowEx, CS_SAVEBITS, CW_USEDEFAULT, DefWindowProc, DestroyWindow, DispatchMessage, GetMessage, HWND, IDC_ARROW,
                    IDI_APPLICATION, LoadCursor, LoadIcon, LPARAM, LRESULT, MB_ICONEXCLAMATION, MB_OK, MessageBox, MSG, MyInstance, PostQuitMessage,
                    RegisterClass, TranslateMessage, UINT, WM_CLOSE, WM_DESTROY, WNDCLASS, WPARAM, WS_EX_CLIENTEDGE, WS_OVERLAPPEDWINDOW;

CONST
     g_szClassName = "myWindowClass";

PROCEDURE ["StdCall"] WndProc(hwnd : HWND; msg : UINT; wParam : WPARAM;  lParam : LPARAM): LRESULT;
BEGIN
    CASE msg OF
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
    Msg             : MSG;
    wc              : WNDCLASS;

BEGIN
    (* Register the Window Class *)
    wc.style         := CS_SAVEBITS;
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
    hwnd := CreateWindowEx(WS_EX_CLIENTEDGE, g_szClassName, "Chaos", WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, CW_USEDEFAULT, 240, 120, NIL,
			   NIL, MyInstance(), NIL);
    IF hwnd = NIL THEN
       MessageBox(NIL, "Window Creation failed!", "Error!", MB_ICONEXCLAMATION + MB_OK);
       RETURN ;
    END;
            
    (* The Message Loop *)
    WHILE GetMessage( Msg, NIL, 0, 0) DO
       TranslateMessage(Msg);
       DispatchMessage(Msg);
    END;
END CelsiusConverter.
