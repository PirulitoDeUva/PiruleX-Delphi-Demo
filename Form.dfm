object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 101
  ClientWidth = 288
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 38
    Width = 31
    Height = 13
    Caption = 'Label1'
  end
  object Label2: TLabel
    Left = 161
    Top = 38
    Width = 31
    Height = 13
    Caption = 'Label2'
  end
  object Button1: TButton
    Left = 216
    Top = 62
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 135
    Top = 62
    Width = 75
    Height = 25
    Caption = 'Button2'
    TabOrder = 1
    OnClick = Button2Click
  end
  object ComboBox1: TComboBox
    Left = 8
    Top = 8
    Width = 283
    Height = 21
    TabOrder = 2
    Text = 'ComboBox1'
    OnDropDown = ComboBox1DropDown
  end
  object Edit1: TEdit
    Left = 57
    Top = 35
    Width = 94
    Height = 21
    TabOrder = 3
    Text = 'Edit1'
  end
  object ComboBox2: TComboBox
    Left = 8
    Top = 64
    Width = 121
    Height = 21
    TabOrder = 4
    Text = 'ComboBox2'
  end
  object Edit2: TEdit
    Left = 197
    Top = 35
    Width = 94
    Height = 21
    TabOrder = 5
    Text = 'Edit2'
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 82
    Width = 288
    Height = 19
    Panels = <>
  end
end
