unit uTools;

interface

uses sysutils, classes, Types, uGlobalDef, math, msginisupp, windows;

function StrGetToken (const SourceStr, StringSep: String; TokenNum: Integer): String;
function CountTokens(const SourceStr,StringSep: String): integer;
procedure ConvertCoordPixelToWorld(pixel,windowcenter: TPoint; offset: TDoublePoint; zoom: double; var world: TDoublePoint);
procedure ConvertCoordWorldToPixel(world: TDoublepoint; windowcenter: TPoint; offset: TdoublePoint; zoom: double; var pixel: TPoint);
procedure ReplacePlaceholder(sl: TStringlist; placeholder: string; stringstoinsert: TStringlist);
function DoublePointToPoint(db: TDoublePoint):TPoint;
function floattostrPoint(a: double; maxcommadigits: integer=10): string;
function StripQuotes(const str: string): string;
function Distance(const p1,p2: TDoublePoint): double;
function IntDistance(const p1,p2: TPoint): integer;
function Intersection(const a1,a2,b1,b2: TDoublePoint;var p: TDoublePoint; infinite: boolean=false): boolean;
procedure Perpendicular(const a1,a2: TDoublePoint;  f: double; var p: TDoublePoint);
function PlatformPosChar(t: integer): char;
function DoublePoint(x,y: double): TDoublePoint;
function Triangle(a,p1,p2: TDoublePoint): double;
function angle(p1,p2: TDoublePoint): double;
function strtofloat1(const s: string): double;
function IsPointInSegment(p1,p2,p3: TDoublePoint; l: double; var a,b: double): boolean;
function sgn(a: double): integer;
function strtobooldef(const s: string; def: boolean): boolean;
function booltoint(b: boolean): integer;
function inttobool(i: integer): boolean;
function FindInStringlist(sl: TStringlist; const str: string): integer;
function IsDoublePointInRect(p,r1,r2: TDoublePoint): boolean;
function AddDoublePoints(dp1,dp2: TDoublePoint): TDoublePoint;
function SubDoublePoints(dp1,dp2: TDoublePoint): TDoublePoint;
procedure ParseCommaSeparated(const s: string; start,count: integer; var dest: Array of double);
procedure Turn(basepoint: TDoublePoint; var point: TDoublePoint; angle: double);
function GetCurrentUserName : string;
function ConcatIfNotOneEmpty(const a,b: string): string;
procedure Quicksort(var A: array of double);

var lngmsg: TMsgINISupp;
    _last_intersection_i: double; // Hinweis: Diese Variable ist nicht threadsafe!

implementation


procedure QuickSort(var A: array of double);

 procedure QuickSort(var A: array of double; iLo, iHi: Integer);
 var
   Lo, Hi: Integer;
   Mid, T: double;
 begin
   Lo := iLo;
   Hi := iHi;
   Mid := A[(Lo + Hi) div 2];
   repeat
     while A[Lo] < Mid do Inc(Lo);
     while A[Hi] > Mid do Dec(Hi);
     if Lo <= Hi then
     begin
       T := A[Lo];
       A[Lo] := A[Hi];
       A[Hi] := T;
       Inc(Lo);
       Dec(Hi);
     end;
   until Lo > Hi;
   if Hi > iLo then QuickSort(A, iLo, Hi);
   if Lo < iHi then QuickSort(A, Lo, iHi);
 end;

begin
 QuickSort(A, Low(A), High(A));
end;




function GetToken (const SourceStr, StringSep: PChar; Token: PChar; TokenNum: Integer): PChar;
var
   TokensFound: Word;
   SourcePos: PChar;
   TargetPos: PChar;
   escaped: boolean;
begin
   TokensFound := 0;
   escaped := false;
   if (StrLen (SourceStr) > 0) then
   begin
      Inc (TokensFound);
      SourcePos := SourceStr;
      TargetPos := Token;
      while ((TokensFound <= TokenNum) and (SourcePos^ <> #0)) do
      begin
         if SourcePos^='"' then escaped := not escaped;
         if (StrScan (StringSep, SourcePos^) <> Nil)and not escaped then
            Inc (TokensFound)
         else
         begin
            if (TokensFound = TokenNum) then
            begin
               TargetPos^ := SourcePos^;
               Inc (TargetPos);
            end;
         end;
         Inc (SourcePos);
      end;
      TargetPos^ := #0;
   end
   else
      Token^ := #0;
   Result := Token;
end;

function StrGetToken (const SourceStr, StringSep: String; TokenNum: Integer): String;
begin
   SetLength (Result, Length (SourceStr) + 1);
   GetToken (PChar (SourceStr), PChar (StringSep), PChar (Result), TokenNum);
   SetLength (Result, StrLen (PChar (Result)));
end;

function CountTokens(const SourceStr,StringSep: String): integer;
var i: integer;
begin
  i := 0;
  repeat
    inc(i);
  until StrGetToken(SourceStr,StringSep,i)='';
  result := i-1;
end;

function StripQuotes(const str: string): string;
var i: integer;
    str_: string;
begin
  if length(str)<1 then begin result :=str; exit; end;
  str_ := str;
  i := 1;
  while (length(str_)>0) and(str_[1]='"') do
    str_ := copy(str_,2,maxint);
  if length(str_)<1 then begin result :=str_; exit; end;
  while str_[length(str_)]='"' do
    str_ := copy(str_,1,length(str_)-1);
  result := str_;
end;


// konvertiere Weltkoordinaten zu Pixelkoordinaten im Editorfenster
procedure ConvertCoordWorldToPixel(world: TDoublepoint; windowcenter: TPoint; offset: TdoublePoint; zoom: double; var pixel: TPoint);
begin
  pixel.X := round((world.x-offset.x) * zoom) + windowcenter.x;
  pixel.Y := round((-world.y+offset.y) * zoom) + windowcenter.y;
end;

procedure ConvertCoordPixelToWorld(pixel,windowcenter: TPoint; offset: TDoublePoint; zoom: double; var world: TDoublePoint);
begin
  world.x := (pixel.x-windowcenter.x)/zoom+offset.x;
  world.y := -((pixel.y-windowcenter.y)/zoom-offset.y);
end;

function DoublePointToPoint(db: TDoublePoint):TPoint;
begin
  result.x := round(db.x);
  result.y := round(db.y);
end;


function Distance(const p1,p2: TDoublePoint): double;
begin
  result := sqrt( sqr(p1.X-p2.x) + sqr(p1.y-p2.y) );
end;

function IntDistance(const p1,p2: TPoint): integer;
begin
  result := round(sqrt( sqr(p1.X-p2.x) + sqr(p1.y-p2.y) ));
end;

function PlatformPosChar(t: integer): char;
begin
  case t of
  0: result := '0';
  1: result := 'R';
  2: result := 'L';
  end;
end;

function DoublePoint(x,y: double): TDoublePoint;
begin
  result.x := x;
  Result.y := y;
end;

function floattostrPoint(a: double; maxcommadigits: integer): string;
var OldDecimalSeparator: char;
begin
  OldDecimalSeparator := DecimalSeparator;
  DecimalSeparator := '.';
  result := floattostrF(a,ffFixed,10,maxcommadigits);
  DecimalSeparator := OldDecimalSeparator;
  // 0en hinten abschneiden
  if(pos('.',result)>0) then
  begin
    while (result[length(result)]='0') do
      result := copy(result,1,length(result)-1);
  end;
  if (result[length(result)]='.') then
      result := copy(result,1,length(result)-1);
end;

// berechne den Winkel zwischen |ap1| und |ap2|
function Triangle(a,p1,p2: TDoublePoint): double;
begin
  result := angle(a,p2)-angle(a,p1);
end;

// berechne den Winkel von |p1p2|
function angle(p1,p2: TDoublePoint): double;
var dx,dy: double;
begin
  dy := p2.Y-p1.y;
  dx := p2.x-p1.x;
  if dx=0 then
  begin
    if dy>0 then
      result := 90
    else
      result := -90;
  end
  else //if dx>0 then
    result := round(180*arctan2(dy,dx)/pi)
{  else // dx<0
  begin
      result := round(180*arctan2(dy,dx)/pi)
    else
      result := round(180*arctan2(dy,dx)/pi);
  end;}
end;

function strtofloat1(const s: string): double;
var OldDecimalSeparator: char;
begin
  if pos('.',s)>0 then
  begin
    OldDecimalSeparator := DecimalSeparator;
    DecimalSeparator := '.';
    try
    result := strtofloat(s);
    except
    result := 0;
    end;
    DecimalSeparator := OldDecimalSeparator;
  end
  else
    result := strtointdef(s,0);
end;

function strtofloatpoint(const s: string): double;
var j,k,d,start,fak: integer;
    nachkomma: string;
begin
  j := pos('.',s);
  fak := 1;
  start := 1;
  if j > 0 then
  begin
    start := pos('-',s);
    if start<=0 then
      start := 1
    else
    begin
      fak := -1;
      inc(start);
    end;
    result    := strtointdef(copy(s,start,j-start),0);
    d := 10;
    for k := j+1 to length(s) do
    begin
      result := result + ( ord(s[k])-48 )/d;
      d:=d*10;
    end;
    result := result * fak;
  end
  else
    result := strtointdef(s,0);
end;

// Funktion: IsPointInSegment
// Autor   : up
// Datum   : 11.2002
// Beschr. : ermittelt, ob p3 im Abstand l von der Strecke p1p2 liegt oder n�her.
// gibt in a und b folgendes zur�ck:
// a: Abstand der Senkrechten von p1 von 0 bis 1 (mit l�nge p1p2 multiplizieren, um wirkliche L�nge zu erhalten)
// b: L�nge der Senkrechten (d.h. Abstand von p1p2) von 0 bis 1 (mit l multiplizieren)
function IsPointInSegment(p1,p2,p3: TDoublePoint; l: double; var a,b: double): boolean;
var r,x1,x2,x3,y1,y2,y3,xv,yv: double;
begin
  result := false;
  r := Distance(p1,p2);
  if r=0 then exit;

  // Hilfsvariable
  x1 := p1.x;
  x2 := p2.x;
  x3 := p3.x;
  y1 := p1.y;
  y2 := p2.y;
  y3 := p3.y;

  xv :=   (y2-y1)*l/r; // vertikalvektor x-komp
  yv :=  -(x2-x1)*l/r; // vertikalvektor y-komp.

  // division by zero vermeiden durch sehr simplen workaround
  if xv=0 then xv := 0.00001;
  if yv=0 then yv := 0.00001;

  // Abstand in Richtung P1P2 (Bruchteil der L�nge P1P2, also r)
  a := (yv*(x3-x1) - xv*(y3-y1))
     / (yv*(x2-x1) - xv*(y2-y1));

  // Abstand vertikal zu P1P2 (Bruchteil von l)
  b := (x3-x1-a*(x2-x1))/xv;

  result := (a>=0)and(a<=1.01)and(b>=-1)and(b<=1);

end;

function sgn(a: double): integer;
begin
  if a<0 then
    result := -1
  else
  if a>0 then
    result := 1
  else
    result := 0;
end;


function booltoint(b: boolean): integer;
begin
  if b then
    result :=1
  else                                               
    result :=0;
end;

function inttobool(i: integer): boolean;
begin
  result := (i>0);
end;

function strtobooldef(const s: string; def: boolean): boolean;
begin
  result := inttobool( strtointdef(s,booltoint(def)) );
end;

// Funktion: ReplacePlaceholder
// Autor   : up
// Datum   : 11.1.03
// Beschr. : ersetzt Zeile "placeholder" in sl durch stringstoinsert
procedure ReplacePlaceholder(sl: TStringlist; placeholder: string; stringstoinsert: TStringlist);
var i,j: integer;
begin
  i := sl.IndexOf(placeholder);
  if i>=0 then
  begin
    for j := 0 to stringstoinsert.count-1 do
    sl.insert(i+j,stringstoinsert[j]);
  end; // sonst schlecht!
  // entferne Platzhalter
  i := sl.IndexOf(placeholder);
  if i>=0 then
    sl.Delete(i);
end;

// berechne Schnittpunkt zwischen Strecken a1a2 und b1b2. Wenn infinite=true, dann werden Geraden angenommen
function Intersection(const a1,a2,b1,b2: TDoublePoint;var p: TDoublePoint; infinite: boolean): boolean;
var i,j,n1,n2,z1,z2: double;
begin
  result := false;

  n1 := (b2.x-b1.x)*(b2.y-b1.y);
  n2 := (a2.x-a1.x)*(b2.y-b1.y)-(a2.y-a1.y)*(b2.x-b1.x);

  if n1*n2=0 then
  begin // b1b2 ist Horizontale. Spezialbehandlung.
    if (b1.y=b2.y) then
    begin
      if (a1.y>b1.y)and(a2.y>b1.y) then exit;
      if (a1.y<b1.y)and(a2.y<b1.y) then exit;
      if a2.y=a1.y then
      begin
        // auch a1a2 ist Horizontale.
        if a1.y<>b1.y then exit;
        // Die Horizontalen liegen auf einer Geraden.
        if (max(a1.x,a2.x)<b1.x)and(max(a1.x,a2.x)<b2.x) then exit;
        if (min(a1.x,a2.x)>b1.x)and(min(a1.x,a2.x)>b2.x) then exit;
        // Die Horizontalen �berschneiden sich.
        p.y := a1.y;
        // nimm Schwerpunkt (was besseres f�llt mir nicht ein, eigentlich m�sste man
        // hier unendlich viele Punkte zur�ckgeben)
        p.x := (a1.x+a2.x+b1.x+b2.x)/4;
        result := true;
      end
      else
      begin
        i := (b1.y-a1.y)/(a2.y-a1.y);
        j := a1.x+i*(a2.x-a1.x);
        if (j>=b1.x)and(j<=b2.x) then
        begin
          p.x := j;
          p.y := b1.y;
          result := true;
        end;
      end;
    end
    else
    if (b1.x=b2.x) then
    begin
      // b1b2 ist Vertikale.Sonderbehandlung.
      if (a1.x>b1.x)and(a2.x>b1.x) then exit;
      if (a1.x<b1.x)and(a2.x<b1.x) then exit;
      if a2.x=a1.x then
      begin
        // auch a1a2 ist Vertikale
        if a1.x<>b1.x then exit;
        // Die Vertikalen liegen auf einer Geraden.
        if (max(a1.y,a2.y)<b1.y)and(max(a1.y,a2.y)<b2.y) then exit;
        if (min(a1.y,a2.y)>b1.y)and(min(a1.y,a2.y)>b2.y) then exit;
        // Die Vertikalen �berschneiden sich.
        p.x := a1.x;
        // nimm Schwerpunkt (was besseres f�llt mir nicht ein, eigentlich m�sste man
        // hier unendlich viele Punkte zur�ckgeben)
        p.y := (a1.y+a2.y+b1.y+b2.y)/4;
        result := true;
      end
      else
      begin
        i := (b1.x-a1.x)/(a2.x-a1.x);
        j := a1.y+i*(a2.y-a1.y);
        if (j>=b1.y)and(j<=b2.y) then
        begin
          p.x := b1.x;
          p.y := j;
          result := true;
        end;
      end;
    end;

    exit;
  end;

  z1 := (b1.x-a1.x)*(b2.y-b1.y)-(b2.x-b1.x)*(b1.y-a1.y);
  z2 := (b2.x-b1.x)*(b2.y-b1.y);

  i := z1*z2/(n1*n2);
  _last_intersection_i := i;

  if b2.x-b1.x<>0 then
    j := (i*(a2.x-a1.x)-(b1.x-a1.x))/(b2.x-b1.x)
  else if b2.y-b1.y<>0 then
    j := (i*(a2.y-a1.y)-(b1.y-a1.y))/(b2.y-b1.y)
  else
  begin
    //
    exit;
  end;

  if infinite then
  begin
    p.x := a1.x+i*(a2.x-a1.x);
    p.y := a1.y+i*(a2.y-a1.y);
    result := true
  end
  else
  begin
    if (i>=0)and(i<=1)and(j>=0)and(j<=1) then
    begin
      p.x := a1.x+i*(a2.x-a1.x);
      p.y := a1.y+i*(a2.y-a1.y);
      result := true;
    end;
  end;

end;

procedure Perpendicular(const a1,a2: TDoublePoint; f: double; var p: TDoublePoint);
begin
  p.x := a1.x- (a2.y-a1.y)*f;
  p.y := a1.y+ (a2.x-a1.x)*f;
end;

// Funktion: FindInStringlist
// Autor   : up
// Datum   : 12.1.03
// Beschr. : suche in Stringlist nach String, wobei nur bis zu dessen L�nge �berpr�ft wird
function FindInStringlist(sl: TStringlist; const str: string): integer;
var i: integer;
begin
  result := -1;
  for i:=0 to sl.count-1 do
  begin
    if copy(sl[i],1,length(str))=str then
    begin
      result := i;
      break;
    end;
  end;
end;

function IsDoublePointInRect(p,r1,r2: TDoublePoint): boolean;
begin
  result := (p.x >= min(r1.x,r2.x)) and (p.x<= max(r1.x,r2.x))
        and (p.y >= min(r1.y,r2.y)) and (p.y<= max(r1.y,r2.y));
end;

function AddDoublePoints(dp1,dp2: TDoublePoint): TDoublePoint;
begin
  result.x := dp1.x + dp2.x;
  result.y := dp1.y + dp2.y;
end;

function SubDoublePoints(dp1,dp2: TDoublePoint): TDoublePoint;
begin
  result.x := dp1.x - dp2.x;
  result.y := dp1.y - dp2.y;
end;


procedure ParseCommaSeparated(const s: string; start,count: integer; var dest: Array of double);
var j,i,k: integer;
begin
  i:=0;
  k:=start;
  for j:=start to length(s) do
  begin
    if s[j]=',' then
    begin
      dest[i] := strtofloatpoint(copy(s,k,j-k));
      k := j+1;
      inc(i);
      if i>=3 then exit;
    end;
  end;
  if i>=3 then exit;
  dest[i] := strtofloatpoint(copy(s,k,j-k));
end;


procedure Turn(basepoint: TDoublePoint; var point: TDoublePoint; angle: double);
var cosa,sina,px,py,px2,py2: double;
begin
  cosa := cos(angle*pi/180);
  sina := sin(angle*pi/180);
  px := point.x-basepoint.x;
  py := point.y-basepoint.y;
  px2 := +cosa*px+sina*py;
  py2 := -sina*px+cosa*py;
  point.x := px2+basepoint.x;
  point.y := py2+basepoint.y;
end;

function GetCurrentUserName : string;
const
  cnMaxUserNameLen = 254;
var
  sUserName     : string;
  dwUserNameLen : DWord;
begin
  dwUserNameLen := cnMaxUserNameLen-1;
  SetLength( sUserName, cnMaxUserNameLen );
  GetUserName(
    PChar( sUserName ),
    dwUserNameLen );
  SetLength( sUserName, dwUserNameLen );
  Result := sUserName;
end;

function ConcatIfNotOneEmpty(const a,b: string): string;
begin
  if (a='') or (b='') then result := ''
  else result := a+b;
end;

end.
