unit Forms.Main;

{$mode objfpc}{$H+}

interface

uses
  Classes
, SysUtils
, memds
, DB
, Forms
, Controls
, Graphics
, Dialogs
, Menus
, ActnList
, StdActns
, ExtCtrls
, StdCtrls
, DBCtrls
, DBGrids
, ComCtrls
;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    actAccountsClearData: TAction;
    actAccountsAddData: TAction;
    actAccountsFilterClear: TAction;
    alMain: TActionList;
    actFileExit: TFileExit;
    btnAccountsClearData: TButton;
    btnAccountsAddData: TButton;
    dbgAccounts: TDBGrid;
    dsAccounts: TDataSource;
    edtAccountsFilterByAlias: TEdit;
    gbAccountsFilter: TGroupBox;
    ilMain: TImageList;
    imgAccountsFilterClear: TImage;
    lblAccountsFilterAlias: TLabel;
    mdsAccounts: TMemDataset;
    mdsAccountsBalance: TCurrencyField;
    mdsAccountsHASH: TStringField;
    mdsAccountsAlias: TStringField;
    mdsAccountsLabel: TStringField;
    mdsAccountsPending: TCurrencyField;
    mnuFile: TMenuItem;
    mnuFileExit: TMenuItem;
    mmMain: TMainMenu;
    panButtons: TPanel;
    sbMain: TStatusBar;
    procedure actAccountsAddDataExecute(Sender: TObject);
    procedure actAccountsClearDataExecute(Sender: TObject);
    procedure actAccountsFilterClearExecute(Sender: TObject);
    procedure alMainUpdate(AAction: TBasicAction; var Handled: Boolean);
    procedure edtAccountsFilterByAliasChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure mdsAccountsFilterRecord(DataSet: TDataSet; var Accept: Boolean);
  private
    procedure InitShortcuts;
    procedure DisplayHint(Sender: TObject);
  public

  end;

var
  frmMain: TfrmMain;

implementation

uses
  LCLType
;

const
  cVersion = '0.1.0';

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  Caption:= Format('%s v%s', [ Application.Title, cVersion ]);
  Application.OnHint:= @DisplayHint;
  InitShortcuts;
  imgAccountsFilterClear.ImageIndex:= 0;
  mdsAccounts.Active:= True;
end;

procedure TfrmMain.DisplayHint(Sender: TObject);
begin
  sbMain.SimpleText:= GetShortHint(Application.Hint);
end;

procedure TfrmMain.InitShortcuts;
begin
  {$IFDEF UNIX}
    actFileExit.ShortCut := KeyToShortCut(VK_Q, [ssCtrl]);
  {$ENDIF}
  {$IFDEF WINDOWS}
    actFileExit.ShortCut := KeyToShortCut(VK_X, [ssAlt]);
  {$ENDIF}
end;

procedure TfrmMain.alMainUpdate(AAction: TBasicAction; var Handled: Boolean);
begin
  // Clear Data
  actAccountsClearData.Enabled:= mdsAccounts.RecordCount > 0;

  // Filter Clear
  edtAccountsFilterByAlias.Enabled := mdsAccounts.RecordCount > 0;
  actAccountsFilterClear.Enabled:= (Length(edtAccountsFilterByAlias.Text) > 0)
                               and (mdsAccounts.RecordCount > 0);
  imgAccountsFilterClear.Enabled:= actAccountsFilterClear.Enabled;
  case actAccountsFilterClear.Enabled of
    False: imgAccountsFilterClear.ImageIndex:= 0;
    True: imgAccountsFilterClear.ImageIndex:= 1;
  end;

  Handled:= True;
end;

procedure TfrmMain.edtAccountsFilterByAliasChange(Sender: TObject);
begin
  if mdsAccounts.RecordCount < 1 then exit;

  dbgAccounts.BeginUpdate;
  if Length(Trim(edtAccountsFilterByAlias.Text)) > 0 then
  begin
    mdsAccounts.FilterOptions:= [foCaseInsensitive];
    mdsAccounts.Filter:= Format('Alias="*%s*"', [
    Trim(edtAccountsFilterByAlias.Text)
    ]);
    mdsAccounts.Filtered:= True;
    mdsAccounts.Refresh;
  end
  else
  begin
    mdsAccounts.Filtered:= False;
    mdsAccounts.Refresh;
  end;
  dbgAccounts.EndUpdate;
end;

procedure TfrmMain.mdsAccountsFilterRecord(DataSet: TDataSet;
  var Accept: Boolean);
begin
  Accept := Pos(UpperCase(edtAccountsFilterByAlias.Text), UpperCase(DataSet.FieldByName('Alias').AsString)) > 0;
end;

procedure TfrmMain.actAccountsClearDataExecute(Sender: TObject);
begin
  actAccountsClearData.Enabled:= False;
  Application.ProcessMessages;

  dbgAccounts.BeginUpdate;

  mdsAccounts.Clear(False);
  edtAccountsFilterByAlias.Clear;

  dbgAccounts.AutoAdjustColumns;
  dbgAccounts.EndUpdate;

  Application.ProcessMessages;
  actAccountsClearData.Enabled:= True;
end;

procedure TfrmMain.actAccountsFilterClearExecute(Sender: TObject);
begin
  actAccountsFilterClear.Enabled:= False;
  Application.ProcessMessages;

  edtAccountsFilterByAlias.Clear;
  edtAccountsFilterByAlias.SetFocus;

  Application.ProcessMessages;
  actAccountsFilterClear.Enabled:= True;
end;

procedure TfrmMain.actAccountsAddDataExecute(Sender: TObject);
begin
  actAccountsAddData.Enabled:= False;
  Application.ProcessMessages;

  dbgAccounts.BeginUpdate;

  mdsAccounts.Append;
  mdsAccounts.FieldByName('HASH').AsString:= 'N198726AFD876387612';
  mdsAccounts.FieldByName('Alias').AsString:= 'Some Alias 1';
  mdsAccounts.FieldByName('Label').AsString:= 'Some Label 1';
  mdsAccounts.FieldByName('Pending').AsCurrency:= 0.0;
  mdsAccounts.FieldByName('Balance').AsCurrency:= 7000.09368;
  mdsAccounts.Post;

  mdsAccounts.Append;
  mdsAccounts.FieldByName('HASH').AsString:= 'N198726696876387612';
  mdsAccounts.FieldByName('Alias').AsString:= 'Some Alias 2';
  mdsAccounts.FieldByName('Label').AsString:= 'Some Label 2';
  mdsAccounts.FieldByName('Pending').AsCurrency:= 100.0;
  mdsAccounts.FieldByName('Balance').AsCurrency:= 80.08276;
  mdsAccounts.Post;

  mdsAccounts.Append;
  mdsAccounts.FieldByName('HASH').AsString:= 'N198726696876387612';
  mdsAccounts.FieldByName('Alias').AsString:= 'Some Alias 3';
  mdsAccounts.FieldByName('Label').AsString:= 'Some Label 3';
  mdsAccounts.FieldByName('Pending').AsCurrency:= 101.0;
  mdsAccounts.FieldByName('Balance').AsCurrency:= 80000.004597;
  mdsAccounts.Post;

  dbgAccounts.AutoAdjustColumns;
  dbgAccounts.EndUpdate;

  Application.ProcessMessages;
  actAccountsAddData.Enabled:= True;
end;

end.

