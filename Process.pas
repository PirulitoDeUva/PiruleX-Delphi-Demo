unit Process;

interface

uses Windows, Classes, SysUtils, Generics.Defaults, Generics.Collections;

type
  TProcessInfo = TPair<Cardinal, String>;
  TProcessList = TList<TProcessInfo>;

function ListProcessWindows: TProcessList;
function GetModuleInfo(Id: Cardinal; Module: String; Base: PPointer; Size: PCardinal): Boolean;
function ReadProcessByte(Id: Cardinal; Addr: Pointer): Byte;
function ReadProcessWord(Id: Cardinal; Addr: Pointer): Word;
function ReadProcessDWord(Id: Cardinal; Addr: Pointer): DWord;
function ReadProcessFloat(Id: Cardinal; Addr: Pointer): Single;
procedure WriteProcessByte(Id: Cardinal; Addr: Pointer; Value: Byte);
procedure WriteProcessWord(Id: Cardinal; Addr: Pointer; Value: Word);
procedure WriteProcessDWord(Id: Cardinal; Addr: Pointer; Value: DWord);
procedure WriteProcessFloat(Id: Cardinal; Addr: Pointer; Value: Single);
procedure SendPacket(Id: Cardinal; Func: Pointer; Pkt: PByte; PktSz: Cardinal);

implementation

function QueryFullProcessImageName(hProcess: THandle; dwFlags: Cardinal;
  lpExeName: PChar; lpdwSize: PCardinal): Boolean; stdcall;
  external 'Kernel32' name 'QueryFullProcessImageNameW';

function GetProcessName(Id: Cardinal): String;
var
  hProc: THandle;
  szName: array of Char;
  dwSize: Cardinal;
begin
  Result := '';
  hProc := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, False, Id);
  if hProc > 0 then
  begin
    dwSize := MAX_PATH;
    SetLength(szName, dwSize);
    if QueryFullProcessImageName(hProc, 0, PChar(szName), @dwSize) then
      Result := ExtractFileName(String(PChar(szName)));
    CloseHandle(hProc);
  end;
end;

function EnumWindowsProc(hWnd: THandle; List: TDictionary<Cardinal, String>)
  : Boolean; stdcall;
var
  Id: Cardinal;
  Proc: String;
begin
  if IsWindow(hWnd) and IsWindowVisible(hWnd) and (GetWindow(hWnd, GW_OWNER) = 0)
  then
  begin
    GetWindowThreadProcessId(hWnd, Id);
    Proc := GetProcessName(Id);
    if Proc <> '' then
      List.AddOrSetValue(Id, Proc);
  end;
  Result := True;
end;

function ListProcessWindows: TProcessList;
var
  UniqueList: TDictionary<Cardinal, String>;
  List: TProcessList;
begin
  UniqueList := TDictionary<Cardinal, String>.Create;
  EnumWindows(@EnumWindowsProc, LParam(UniqueList));
  List := TProcessList.Create(UniqueList);
  List.Sort(TComparer<TProcessInfo>.Construct(
    function(const L, R: TProcessInfo): Integer
    begin
      Result := CompareText(L.Value, R.Value);
      if Result = 0 then
        Result := L.Key - R.Key;
    end));
  Result := List;
  FreeAndNil(UniqueList);
end;

function GetModuleInfo(Id: Cardinal; Module: String; Base: PPointer; Size: PCardinal): Boolean;
var
  hProc: THandle;
  hMods: Array [0 .. 1024] of HMODULE;
  ModName: Array [0 .. MAX_PATH] of Char;
  ModInfo: TModuleInfo;
  i, cbNeeded: Cardinal;
begin
  Result := False;
  hProc := OpenProcess(PROCESS_ALL_ACCESS, False, Id);
  if hProc > 0 then
  begin
    if EnumProcessModules(hProc, @hMods, sizeof(hMods), cbNeeded) then
    begin
      for i := 0 to cbNeeded div sizeof(HMODULE) do
      begin
        if (Module = '') or ((GetModuleBaseName(hProc, hMods[i], ModName, sizeof(ModName)) > 0) and (CompareText(Module, ModName) = 0)) then
        begin
          GetModuleInformation(hProc, hMods[i], @ModInfo, sizeof(ModInfo));
          if Base <> Nil then
            Base^ := ModInfo.lpBaseOfDll;
          if Size <> Nil then
            Size^ := ModInfo.SizeOfImage;
          Result := True;
          Break;
        end;
      end;
    end;
    CloseHandle(hProc);
  end;
end;

function ReadProcessByte(Id: Cardinal; Addr: Pointer): Byte;
var
  hProc: THandle;
begin
  Result := 0;
  hProc := OpenProcess(PROCESS_ALL_ACCESS, False, Id);
  if hProc > 0 then
  begin
    ReadProcessMemory(hProc, Addr, @Result, sizeof(Result), SIZE_T(Nil^));
    CloseHandle(hProc);
  end;
end;

function ReadProcessWord(Id: Cardinal; Addr: Pointer): Word;
var
  hProc: THandle;
begin
  Result := 0;
  hProc := OpenProcess(PROCESS_ALL_ACCESS, False, Id);
  if hProc > 0 then
  begin
    ReadProcessMemory(hProc, Addr, @Result, sizeof(Result), SIZE_T(Nil^));
    CloseHandle(hProc);
  end;
end;

function ReadProcessDWord(Id: Cardinal; Addr: Pointer): DWord;
var
  hProc: THandle;
begin
  Result := 0;
  hProc := OpenProcess(PROCESS_ALL_ACCESS, False, Id);
  if hProc > 0 then
  begin
    ReadProcessMemory(hProc, Addr, @Result, sizeof(Result), SIZE_T(Nil^));
    CloseHandle(hProc);
  end;
end;

function ReadProcessFloat(Id: Cardinal; Addr: Pointer): Single;
var
  hProc: THandle;
begin
  Result := 0;
  hProc := OpenProcess(PROCESS_ALL_ACCESS, False, Id);
  if hProc > 0 then
  begin
    ReadProcessMemory(hProc, Addr, @Result, sizeof(Result), SIZE_T(Nil^));
    CloseHandle(hProc);
  end;
end;

procedure WriteProcessByte(Id: Cardinal; Addr: Pointer; Value: Byte);
var
  hProc: THandle;
  Aux: Cardinal;
begin
  hProc := OpenProcess(PROCESS_ALL_ACCESS, False, Id);
  if hProc > 0 then
  begin
    VirtualProtectEx(hProc, Addr, sizeof(Value), PAGE_EXECUTE_READWRITE, Aux);
    WriteProcessMemory(hProc, Addr, @Value, sizeof(Value), SIZE_T(Nil^));
    VirtualProtectEx(hProc, Addr, sizeof(Value), Aux, Aux);
    CloseHandle(hProc);
  end;
end;

procedure WriteProcessWord(Id: Cardinal; Addr: Pointer; Value: Word);
var
  hProc: THandle;
  Aux: Cardinal;
begin
  hProc := OpenProcess(PROCESS_ALL_ACCESS, False, Id);
  if hProc > 0 then
  begin
    VirtualProtectEx(hProc, Addr, sizeof(Value), PAGE_EXECUTE_READWRITE, Aux);
    WriteProcessMemory(hProc, Addr, @Value, sizeof(Value), SIZE_T(Nil^));
    VirtualProtectEx(hProc, Addr, sizeof(Value), Aux, Aux);
    CloseHandle(hProc);
  end;
end;

procedure WriteProcessDWord(Id: Cardinal; Addr: Pointer; Value: DWord);
var
  hProc: THandle;
  Aux: Cardinal;
begin
  hProc := OpenProcess(PROCESS_ALL_ACCESS, False, Id);
  if hProc > 0 then
  begin
    VirtualProtectEx(hProc, Addr, sizeof(Value), PAGE_EXECUTE_READWRITE, Aux);
    WriteProcessMemory(hProc, Addr, @Value, sizeof(Value), SIZE_T(Nil^));
    VirtualProtectEx(hProc, Addr, sizeof(Value), Aux, Aux);
    CloseHandle(hProc);
  end;
end;

procedure WriteProcessFloat(Id: Cardinal; Addr: Pointer; Value: Single);
var
  hProc: THandle;
  Aux: Cardinal;
begin
  hProc := OpenProcess(PROCESS_ALL_ACCESS, False, Id);
  if hProc > 0 then
  begin
    VirtualProtectEx(hProc, Addr, sizeof(Value), PAGE_EXECUTE_READWRITE, Aux);
    WriteProcessMemory(hProc, Addr, @Value, sizeof(Value), SIZE_T(Nil^));
    VirtualProtectEx(hProc, Addr, sizeof(Value), Aux, Aux);
    CloseHandle(hProc);
  end;
end;

procedure SendPacket(Id: Cardinal; Func: Pointer; Pkt: PByte; PktSz: Cardinal);
var
  hProc, hThrd: THandle;
  ShellAddr, PktAddr: Pointer;
  ShellCode: Array of Byte;
  ShellCodeSz: Cardinal;
begin
  hProc := OpenProcess(PROCESS_ALL_ACCESS, False, Id);
  if hProc > 0 then
  begin
    PktAddr := VirtualAllocEx(hProc, Nil, PktSz, MEM_COMMIT, PAGE_EXECUTE_READWRITE);
    if PktAddr <> Nil then
    begin
      ShellCode := [$68, $00, $00, $00, $00, $68, $00, $00, $00, $00, $B8, $00, $00, $00, $00, $FF, $D0, $C2, $04, $00];
      ShellCodeSz := Length(ShellCode);
      ShellAddr := VirtualAllocEx(hProc, Nil, ShellCodeSz, MEM_COMMIT, PAGE_EXECUTE_READWRITE);
      if ShellAddr <> Nil then
      begin
        PCardinal(@ShellCode[1 + 5 * 0])^ := PktSz;
        PPointer(@ShellCode[1 + 5 * 1])^ := PktAddr;
        PPointer(@ShellCode[1 + 5 * 2])^ := Func;
        WriteProcessMemory(hProc, PktAddr, Pkt, PktSz, SIZE_T(Nil^));
        WriteProcessMemory(hProc, ShellAddr, Pointer(ShellCode), ShellCodeSz, SIZE_T(Nil^));
        hThrd := CreateRemoteThread(hProc, Nil, 0, ShellAddr, Nil, 0, Cardinal(Nil^));
        if hThrd > 0 then
        begin
          if WaitForSingleObject(hThrd, 3000) = WAIT_TIMEOUT then
            TerminateThread(hThrd, 0);
          CloseHandle(hThrd);
        end;
        VirtualFreeEx(hProc, ShellAddr, 0, MEM_RELEASE);
      end;
      VirtualFreeEx(hProc, PktAddr, 0, MEM_RELEASE);
    end;
    CloseHandle(hProc);
  end;
end;

end.
