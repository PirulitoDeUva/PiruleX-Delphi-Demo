unit Form;

interface

uses
  Winapi.Windows, Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, Vcl.ComCtrls,
  System.Classes, System.SysUtils, Process;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Button1: TButton;
    Button2: TButton;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    ComboBox2: TComboBox;
    Edit2: TEdit;
    StatusBar1: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure ComboBox1DropDown(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  Id: Cardinal;
begin
  if ComboBox1.ItemIndex <> -1 then
  begin
    Id := Cardinal(ComboBox1.Items.Objects[ComboBox1.ItemIndex]);
    if Id > 0 then
    begin
      case ComboBox2.ItemIndex of
        0:
          Edit2.Text := '$' + IntToHex(Process.ReadProcessByte(Id,
            Ptr(StrToInt(Edit1.Text))), 2);
        1:
          Edit2.Text := '$' + IntToHex(Process.ReadProcessWord(Id,
            Ptr(StrToInt(Edit1.Text))), 4);
        2:
          Edit2.Text := '$' + IntToHex(Process.ReadProcessDWord(Id,
            Ptr(StrToInt(Edit1.Text))), 8);
        3:
          Edit2.Text := FloatToStr(Process.ReadProcessFloat(Id,
            Ptr(StrToInt(Edit1.Text))));
      end;
      StatusBar1.Panels[0].Text := formatdatetime('hh:mm:ss', now);
      StatusBar1.Panels[1].Text := '$' + IntToHex(StrToInt(Edit1.Text),
        sizeof(Pointer) * 2) + ' = ' + Edit2.Text;
    end;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  Id: Cardinal;
begin
  if ComboBox1.ItemIndex <> -1 then
  begin
    Id := Cardinal(ComboBox1.Items.Objects[ComboBox1.ItemIndex]);
    if Id > 0 then
    begin
      case ComboBox2.ItemIndex of
        0:
          Process.WriteProcessByte(Id, Ptr(StrToInt(Edit1.Text)),
            StrToInt(Edit2.Text));
        1:
          Process.WriteProcessWord(Id, Ptr(StrToInt(Edit1.Text)),
            StrToInt(Edit2.Text));
        2:
          Process.WriteProcessDWord(Id, Ptr(StrToInt(Edit1.Text)),
            StrToInt(Edit2.Text));
        3:
          Process.WriteProcessFloat(Id, Ptr(StrToInt(Edit1.Text)),
            StrToFloat(Edit2.Text));
      end;
      StatusBar1.Panels[0].Text := formatdatetime('hh:mm:ss', now);
      StatusBar1.Panels[1].Text := '$' + IntToHex(StrToInt(Edit1.Text),
        sizeof(Pointer) * 2) + ' := ' + Edit2.Text;
    end;
  end;
end;

procedure TForm1.ComboBox1DropDown(Sender: TObject);
var
  ProcList: Process.TProcessList;
  Proc: Process.TProcessInfo;
  List: TStrings;
begin
  ProcList := Process.ListProcessWindows;
  List := TStringList.Create;
  List.AddObject(ComboBox1.Items.Strings[0], ComboBox1.Items.Objects[0]);
  for Proc in ProcList do
  begin
    List.AddObject('(' + UIntToStr(Proc.Key) + ')' + Proc.Value,
      TObject(Proc.Key));
  end;
  ComboBox1.Clear;
  ComboBox1.Items.AddStrings(List);
  ComboBox1.ItemIndex := 0;
  FreeAndNil(List);
  FreeAndNil(ProcList);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  LoadLibrary('PiruleX');

  Form1.Caption := 'Test';
  Form1.BorderIcons := Form1.BorderIcons - [biMaximize];
  Form1.BorderStyle := bsSingle;

  Label1.Caption := 'Address:';
  Label2.Caption := 'Value:';

  Button1.Caption := 'Read';
  Button2.Caption := 'Write';

  ComboBox1.Style := csDropDownList;
  ComboBox1.DoubleBuffered := True;
  ComboBox2.Style := csDropDownList;
  ComboBox2.DoubleBuffered := True;
  ComboBox1.Clear;
  ComboBox2.Clear;
  ComboBox1.AddItem('Process', TObject(0));
  ComboBox1.ItemIndex := 0;
  ComboBox2.AddItem('Byte', Nil);
  ComboBox2.AddItem('Word', Nil);
  ComboBox2.AddItem('DWord', Nil);
  ComboBox2.AddItem('Float', Nil);
  ComboBox2.ItemIndex := 0;

  Edit1.Text := '$400000';
  Edit2.Text := '';

  StatusBar1.Panels.Add;
  StatusBar1.Panels.Add;
  StatusBar1.Panels[0].Alignment := taCenter;
  StatusBar1.Panels[0].Width := 55;
end;

end.
