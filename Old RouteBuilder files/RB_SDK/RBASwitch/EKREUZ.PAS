unit ekreuz;

interface

uses ek,mirror;

var lingo:char;

procedure createek;

implementation


procedure createek;
begin
sprech:=lingo;
kreuzung1;
gleisbett;
infos;
kreuzung2;
gleisbett2;

if xoffchk<0 then
begin
assign(datei1,'temp.txt');
reset(datei1);
assign(datei2,dateiname);
rewrite(datei2);

while not eof(datei1) do
begin
readln(datei1,inhalt1);
face[1]:='';
face[2]:='';
face[3]:='';
face[4]:='';
spiegeln(inhalt1);
writeln(datei2,inhalt1);
end;
close(datei1);
close(datei2);
erase(datei1);
end;
end;
end.