unit Unit2;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  System.Math.Vectors, REST.Types, REST.Client, Data.Bind.Components, System.JSON,
  Data.Bind.ObjectScope, FMX.Objects, FMX.Controls3D, FMX.Layers3D, FMX.Layouts,
  FMX.ListBox, FMX.Edit, FMX.StdCtrls, FMX.Controls.Presentation, FMX.TabControl;

type
  TForm2 = class(TForm)
    MaterialOxfordBlueSB: TStyleBook;
    WedgewoodLightSB: TStyleBook;
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
    Rectangle2: TRectangle;
    Edit1: TEdit;
    SearchEditButton1: TSearchEditButton;
    Layout25: TLayout;
    Label17: TLabel;
    ListBox13: TListBox;
    Layout3D1: TLayout3D;
    Rectangle1: TRectangle;
    Image1: TImage;
    Image2: TImage;
    Label10: TLabel;
    Label11: TLabel;
    edtPAT: TEdit;
    RESTClient1: TRESTClient;
    RESTRequest1: TRESTRequest;
    procedure DoTrashButtonClick(Sender: TObject);
    procedure DoRebootButtonClick(Sender: TObject);
    procedure DoStartButtonClick(Sender: TObject);
    procedure DoReinstallButtonClick(Sender: TObject);
    procedure edtPATKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure Button1Click(Sender: TObject);
  private
   FPersonalAccessToken: string;
    { Private declarations }
    function CreateInstance(): String;
    procedure DeleteInstance(AnInstanceID: string;  AItemIndex: integer);
    function GetAllInstance(APage: integer): TJSONObject;

    function InstanceCommand(AnInstanceID: string; ACommand: string; AData: TJSONObject = nil): boolean;

    function CreateListBoxItem(AIndex: integer; AId: string; AName: string): TListBoxItem;
  public
    { Public declarations }
    property PersonalAccessToken: string read FPersonalAccessToken write FPersonalAccessToken;
  end;

const
  VULTR_API_BASE_PATH = 'https://api.vultr.com/v2';
var
  Form2: TForm2;

implementation

{$R *.fmx}
{$R *.Macintosh.fmx MACOS}
{$R *.Windows.fmx MSWINDOWS}

{ TForm2 }

procedure TForm2.Button1Click(Sender: TObject);
begin
  CreateInstance;
end;

function TForm2.CreateInstance: String;
var
  LRestClient: TRESTClient;
  LRestRequest: TRESTRequest;
  LReqBody, LResp: TJSONObject;
  LItemLB: TListBoxItem;
begin
  LRestClient := TRESTClient.Create(VULTR_API_BASE_PATH + '/instances');
  LRestRequest:= TRESTRequest.Create(nil);
  LReqBody :=  TJSONObject.Create;
  try
    // creating new instance req body
    LReqBody.AddPair('region','ewr');
    LReqBody.AddPair('plan',PUT YOUR PLAN HERE);
    LReqBody.AddPair('label','VULTR.Delphi'+ListBox13.Count.ToString+'.Instance');
    LReqBody.AddPair('os_id', TJSONNumber.Create(215));
    LReqBody.AddPair('user_data', PUT_A_UNIQUE_NAME_HERE);
    LReqBody.AddPair('backups','enabled');

    LRestRequest.Method := rmPOST;
    LRestRequest.AddParameter('Authorization', 'Bearer ' + PersonalAccessToken, TRESTRequestParameterKind.pkHTTPHEADER, [poDoNotEncode]);
    LRestRequest.AddBody(LReqBody.ToJSON, TRESTContentType.ctAPPLICATION_JSON);
    LRestRequest.Client := LRestClient;
    LRestRequest.Execute;
    LResp := (LRestRequest.Response.JSONValue as TJSONObject).GetValue('instance') as TJSONObject;
    LItemLB := CreateListBoxItem(ListBox13.Count, LResp.GetValue('id').Value, LResp.GetValue('label').Value);
    ListBox13.AddObject(LItemLB);
    Result := LRestRequest.Response.JSONText;
  finally
    LRestRequest.Free;
    LRestClient.Free;
    LReqBody.Free;
  end;
end;

function TForm2.CreateListBoxItem(AIndex: integer; AId: string; AName: string): TListBoxItem;
var
  LLayout: TLayout;
  LBtnTrash, LBtnReboot, LBtnStart, LBtnReinstall: TButton;
  LDroplLabel: TLabel;
begin
  Result := TListBoxItem.Create(ListBox13);
  Result.Height := 40;
  LLayout := TLayout.Create(nil);
  LLayout.Align := TAlignLayout.Top;
  LLayout.Size.Height := 40;
  LLayout.Size.PlatformDefault := False;
  LLayout.Size.Width := 636;
  // delete instance
  LBtnTrash:= TButton.Create(LLayout);
  LBtnTrash.StyleLookup := 'trashtoolbutton';
  LBtnTrash.Anchors := [TAnchorKind.akTop, TAnchorKind.akRight, TAnchorKind.akBottom];
  LBtnTrash.Align := TAlignLayout.Right;
  LBtnTrash.ControlType := TControlType.Styled;
  LBtnTrash.Size.Height := 35;
  LBtnTrash.Size.PlatformDefault := False;
  LBtnTrash.Size.Width := 35;
  LBtnTrash.OnClick := DoTrashButtonClick;
  LBtnTrash.Tag := index;
  LBtnTrash.TagString := AId;
  LLayout.AddObject(LBtnTrash);
  // reboot instance
  LBtnReboot:= TButton.Create(LLayout);
  LBtnReboot.StyleLookup := 'refreshtoolbutton';
  LBtnReboot.Anchors := [TAnchorKind.akTop, TAnchorKind.akRight, TAnchorKind.akBottom];
  LBtnReboot.Align := TAlignLayout.Right;
  LBtnReboot.ControlType := TControlType.Styled;
  LBtnReboot.Size.Height := 35;
  LBtnReboot.Size.PlatformDefault := False;
  LBtnReboot.Size.Width := 35;
  LBtnReboot.OnClick := DoRebootButtonClick;
  LBtnReboot.Tag := index;
  LBtnReboot.TagString := AId;
  LLayout.AddObject(LBtnReboot);
  // start instance
  LBtnStart:= TButton.Create(LLayout);
  LBtnStart.StyleLookup := 'playtoolbutton';
  LBtnStart.Anchors := [TAnchorKind.akTop, TAnchorKind.akRight, TAnchorKind.akBottom];
  LBtnStart.Align := TAlignLayout.Right;
  LBtnStart.ControlType := TControlType.Styled;
  LBtnStart.Size.Height := 35;
  LBtnStart.Size.PlatformDefault := False;
  LBtnStart.Size.Width := 35;
  LBtnStart.OnClick := DoStartButtonClick;
  LBtnStart.Tag := index;
  LBtnStart.TagString := AId;
  LLayout.AddObject(LBtnStart);
  // reinstall instance
  LBtnReinstall:= TButton.Create(LLayout);
  LBtnReinstall.StyleLookup := 'replytoolbutton';
  LBtnReinstall.Anchors := [TAnchorKind.akTop, TAnchorKind.akRight, TAnchorKind.akBottom];
  LBtnReinstall.Align := TAlignLayout.Right;
  LBtnReinstall.ControlType := TControlType.Styled;
  LBtnReinstall.Size.Height := 35;
  LBtnReinstall.Size.PlatformDefault := False;
  LBtnReinstall.Size.Width := 35;
  LBtnReinstall.OnClick := DoReinstallButtonClick;
  LBtnReinstall.Tag := index;
  LBtnReinstall.TagString := AId;
  LLayout.AddObject(LBtnReinstall);
  LDroplLabel := TLabel.Create(LLayout);
  LDroplLabel.Align := TAlignLayout.Client;
  LDroplLabel.Text := AName;
  LLayout.AddObject(LDroplLabel);
  Result.AddObject(LLayout);
end;

procedure TForm2.DeleteInstance(AnInstanceID: string; AItemIndex: integer);
var
  LRestClient: TRESTClient;
  LRestRequest: TRESTRequest;
begin
  LRestClient := TRESTClient.Create(VULTR_API_BASE_PATH + '/instances/' + AnInstanceID);
  LRestRequest:= TRESTRequest.Create(nil);
  try
    try
      LRestRequest.Method := rmDELETE;
      LRestRequest.AddParameter('Authorization', 'Bearer ' + PersonalAccessToken, TRESTRequestParameterKind.pkHTTPHEADER, [poDoNotEncode]);
      LRestRequest.Client := LRestClient;
      LRestRequest.Execute;
      ListBox13.Items.Delete(AItemIndex);
    except
      on E:Exception do
        ShowMessage('Delete instance failed');
    end;
  finally
    LRestRequest.Free;
    LRestClient.Free;
  end;
end;

procedure TForm2.DoRebootButtonClick(Sender: TObject);
begin
  InstanceCommand((Sender as TButton).TagString, 'reboot');
end;

procedure TForm2.DoReinstallButtonClick(Sender: TObject);
begin
  InstanceCommand((Sender as TButton).TagString, 'reinstall');
end;

procedure TForm2.DoStartButtonClick(Sender: TObject);
begin
  InstanceCommand((Sender as TButton).TagString, 'start');
end;

procedure TForm2.DoTrashButtonClick(Sender: TObject);
begin
  DeleteInstance((Sender as TButton).TagString, (Sender as TButton).Tag);
end;

procedure TForm2.edtPATKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  case Key of
    vkReturn: GetAllInstance(1);
  end;
end;

function TForm2.GetAllInstance(APage: integer): TJSONObject;
var
  LRestClient: TRESTClient;
  LRestRequest: TRESTRequest;
  LDroplets: TJSONArray;
  I: Integer;
  LLBInstance: TListBoxItem;
  LLayout: TLayout;
  LBtnTrash: TButton;
  LDroplLabel: TLabel;
begin
  LRestClient := TRESTClient.Create(VULTR_API_BASE_PATH + '/instances');
  LRestRequest:= TRESTRequest.Create(nil);
  try
    LRestRequest.Method := rmGET;
    LRestRequest.AddParameter('Authorization', 'Bearer ' + edtPAT.Text, TRESTRequestParameterKind.pkHTTPHEADER, [poDoNotEncode]);
    LRestRequest.Client := LRestClient;
    LRestRequest.Execute;
    Result := LRestRequest.Response.JSONValue as TJSONObject;
    LDroplets := Result.GetValue('instances') as TJSONArray;
    I := 0;
    for I := 0 to LDroplets.Count - 1 do begin
      LLBInstance := CreateListBoxItem(I,
        (LDroplets.Items[I] as TJSONObject).GetValue('id').Value,
        (LDroplets.Items[I] as TJSONObject).GetValue('label').Value);
      ListBox13.AddObject(LLBInstance);
    end;
    PersonalAccessToken := edtPAT.Text;
    edtPAT.Visible := False;
  finally
    LRestRequest.Free;
    LRestClient.Free;
  end;
end;

function TForm2.InstanceCommand(AnInstanceID, ACommand: string; AData: TJSONObject = nil): boolean;
var
  LRestClient: TRESTClient;
  LRestRequest: TRESTRequest;
begin
  Result := False;
  LRestClient := TRESTClient.Create(VULTR_API_BASE_PATH + '/instances/'+AnInstanceID+'/'+ACommand);
  LRestRequest:= TRESTRequest.Create(nil);
  try
    LRestRequest.Method := rmPOST;
    LRestRequest.AddParameter('Authorization', 'Bearer ' + PersonalAccessToken, TRESTRequestParameterKind.pkHTTPHEADER, [poDoNotEncode]);
    if AData <> nil then
      LRestRequest.AddBody(AData.ToJSON, TRESTContentType.ctAPPLICATION_JSON);
    LRestRequest.Client := LRestClient;
    LRestRequest.Execute;
    Result := True;
  finally
    LRestRequest.Free;
    LRestClient.Free;
  end;
end;

end.
