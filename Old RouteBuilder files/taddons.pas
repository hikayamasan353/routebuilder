unit taddons;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Inifiles, shellapi, Registry,uAddonFunc,RBAddonInterface;

type
  TFormAddons = class(TForm)
    AddonList: TListBox;
    AddonInformations: TButton;
    AddonListGrpBox: TGroupBox;
    AddonInformationsGrpBox: TGroupBox;
    Addon_Inf_Name: TLabel;
    Addon_Inf_Author: TLabel;
    Addon_Inf_Version: TLabel;
    Addon_Inf_Website: TLabel;
    Addon_inf_email: TLabel;
    AddonStart: TButton;
    Addon_Inf_Copyright: TLabel;
    Addon_Inf_Description: TLabel;
    
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure AddonListClick(Sender: TObject);
    procedure AddonInformationsClick(Sender: TObject);
    procedure AddonStartClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormActivate(Sender: TObject);
    function KillDll(aDllName: string): Boolean;
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

type DllInit = function(addonin: PRbAddonIn; addonout: PRbAddonOut): boolean; stdcall;
     pDllInit=^Dllinit;
     DllRun  = function(): boolean; stdcall;

     TRBAddon = record
                  name: string;
                  author: string;
                  description: string;
                  homepage: string;
                  version: string;
                  email: string;
                  copyright: string;
                  RunProc: DllRun;
                  Dllhandle: THandle;
                end;

var
  FormAddons: TFormAddons;
  Einblenden: Boolean;
  //iniAddon: TIniFile;
  ka: string;
  //iniAddonUninstall: TIniFile;
  addons: array of TRBAddon;
  //ItemIndex01:string;

implementation

uses tmain, toptions;

{$R *.dfm}

procedure TFormAddons.FormCreate(Sender: TObject);
var sr:TSearchRec;
  DllHandle: THandle;
  AddonIn:RBAddonIn;
  AddonOut:RBAddonOut;
  pAddonIn:pRBAddonIn;
  pAddonOut:pRBAddonOut;
  ProcDllInit: DllInit;
  DllReturn:Pointer;
  i: integer;
begin
//KeyPreview:=True;
    uAddonFunc.InitRBAddonInRecord(AddonIn);
    AddonList.Items.clear();
    i:=0;
    if FindFirst(FormOptions.AktVZ+'\addons\*.dll', faAnyFile, sr) = 0 then
    begin
      repeat
        if (sr.Name<>'.') and (sr.Name<>'..') and (sr.Attr<>faDirectory) then
        begin
          DllHandle:=LoadLibrary(PChar(FormOptions.AktVz+'addons\'+sr.Name));
          if DllHandle <> 0 then
          begin
            ProcDllInit:=GetProcAddress(DLLHandle,'RBAddonInit');
            if(@ProcDllInit<>nil)then
            begin
              // AddonOut l�schen
              Fillchar(AddonOut,sizeof(AddonOut),0);
              if ProcDllInit(@AddonIn,@AddonOut) then
              begin
                AddonList.Items.add(AddonOut.AddonName);
                setlength(addons,i+1);
                addons[i].RunProc := GetProcAddress(DLLHandle,'RBAddonRun');
                addons[i].Dllhandle := DllHandle;
                { ---HIER KOMMT DIE ERSTE FEHLERMELDUNG (Fomart %s....)--- }
                if (AddonOut.AddonName<>nil) then
                  addons[i].name := AddonOut.AddonName;
                if (AddonOut.AddonAuthor<>nil) then
                  addons[i].author := AddonOut.AddonAuthor;
                if (AddonOut.AddonDescription<>nil) then
                  addons[i].description := AddonOut.AddonDescription;
                if (AddonOut.AddonWebsite<>nil) then
                  addons[i].homepage := AddonOut.AddonWebsite;
                if (AddonOut.AddonVersion<>nil) then
                  addons[i].version := AddonOut.AddonVersion;
                if (AddonOut.AddonEmail<>nil) then
                  addons[i].email := AddonOut.AddonEmail;
                if (AddonOut.AddonCopyright<>nil) then
                  addons[i].copyright := AddonOut.AddonCopyright;
                inc(i);
              end;
            end;
           //FreeLibrary(DllHandle);
          end;
        end;
      until FindNext(sr) <> 0;
      FindClose(sr);
    end;

//AddonList.Items.LoadFromFile(FormOptions.AktVZ+'\Addons\list.rbf');  //Ladet Liste der Addons aus Datei
Einblenden:=True;  //Einblenden der Details, am Anfang auf False
end;

procedure TFormAddons.FormClose(Sender: TObject; var Action: TCloseAction);
begin
//AddonList.Items.SaveToFile(FormOptions.AktVZ+'\Addons\list.rbf'); //Speichert bei Beenden Liste der Addons in Datei
end;

procedure TFormAddons.AddonListClick(Sender: TObject);
var SelItem:Integer;
begin
//if Einblenden then begin
//Wenn in Liste geklickt dann
 // Aufruf von Registry Infos zu Addon, wird vielleicht noch einmal auf Ini`s umgestellt
  SelItem:=AddonList.Itemindex;
  { ---HIER WIRD NUR DER ADDONNAME IN DIE GANZEN INFORMATIONSLABELS EINGETRAGEN---
   }
  Addon_Inf_Name.Caption:='Name: '+addons[SelItem].name;
  Addon_Inf_Author.Caption:='Author: '+addons[SelItem].author;
  Addon_Inf_Version.Caption:='Version: '+addons[SelItem].version;
  Addon_Inf_Website.Caption:='Website: '+addons[SelItem].homepage;
  Addon_Inf_email.Caption:='E-mail adress: '+addons[SelItem].email;
  Addon_Inf_Description.Caption:='Description: '+addons[SelItem].description;
  Addon_Inf_Copyright.Caption:='Copyright: '+addons[SelItem].copyright;

  Update;
  //end;
  AddonStart.Enabled:=True;
  AddonInformations.Enabled:=True;
end;

procedure TFormAddons.AddonInformationsClick(Sender: TObject);
begin
if Einblenden=True then begin    // Wenn Showdetails/Einblenden = True dann Fenster vergr��ern
Height:=372;
AddonInformations.Caption:='Hide info';
Einblenden:=False;
end
else begin              //sonst normalisieren
Height:=202;
AddonInformations.Caption:='Info';
Einblenden:=True;
end;
end;

procedure TFormAddons.AddonStartClick(Sender: TObject);
begin
  //Started ausf�hrbare Addondatei
  addons[Addonlist.itemindex].RunProc();

end;

procedure TFormAddons.FormDestroy(Sender: TObject);
var i: integer;
begin
  for i:=0 to length(addons)-1 do
    FreeLibrary( addons[i].Dllhandle);
end;

procedure TFormAddons.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
if Key=VK_Escape then Close;
//Notiz: Dll muss selbst KeyDown besitzten
//In sp�terer Version: Systemweites abfangen der Taste und schliessen der Dll (vielleicht mit Hooks)
end;

procedure TFormAddons.FormActivate(Sender: TObject);
begin
if Einblenden=True then begin    // Wenn Showdetails/Einblenden = True dann Fenster vergr��ern
Height:=372;
AddonInformations.Caption:='Hide info';
Einblenden:=False;
end
else begin              //sonst normalisieren
Height:=202;
AddonInformations.Caption:='Info';
Einblenden:=True;
end;
end;

function TFormAddons.KillDll(aDllName: string): Boolean;
var 
  hDLL: THandle; 
  aName: array[0..10] of char; 
  FoundDLL: Boolean; 
begin 
  StrPCopy(aName, aDllName); 
  FoundDLL := False; 
  repeat 
    hDLL := GetModuleHandle(aName); 
    if hDLL = 0 then 
      Break; 
    FoundDLL := True; 
    FreeLibrary(hDLL); 
  until False; 
  if FoundDLL then 
    MessageDlg('Success!', mtInformation, [mbOK], 0) 
  else 
    MessageDlg('DLL not found!', mtInformation, [mbOK], 0); 
end;

end.

