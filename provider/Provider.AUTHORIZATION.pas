unit Provider.AUTHORIZATION;

interface

uses Horse, Horse.JWT, Horse.BasicAuthentication;

function Authorization: THorseCallback;
function BasicAuthorization: THorseCallback;

var mUsuario, mID: String;

implementation

uses Model.Usuario;

function DoBasicAuthentication(const Username, Password: string): Boolean;
var
  Users: TUsuario;
begin
  Users := TUsuario.Create;
  try
    Result := Users.Auth(USERNAME, PASSWORD);
  finally
    Users.Free;
  end;
end;

function BasicAuthorization: THorseCallback;
begin
  Result := HorseBasicAuthentication(DoBasicAuthentication);
end;

function Authorization: THorseCallback;
begin
  Result := HorseJWT('DELPHIREACT');
end;

end.
