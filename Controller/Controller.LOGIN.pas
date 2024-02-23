unit Controller.LOGIN;

interface

procedure Registry;

implementation

uses Horse, Provider.AUTHORIZATION, JOSE.Core.JWT, System.JSON, System.SysUtils,
     System.DateUtils, JOSE.Core.Builder, Model.Usuario;

procedure Auth(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
//  Usuario: TUsuario;
  LToken : TJWT;
  Obj    : TJSONObject;
begin
  LToken := TJWT.Create;
  Obj := TJSONObject.Create;
  try
    LToken.Claims.Issuer     := 'ServerAuthentication'; //nome da aplicação
    LToken.Claims.Subject    := mUsuario;               //usuario que quer logar
    LToken.Claims.Expiration := IncDay(Now);            //tempo de autenticação  (1 dia)

    Obj.AddPair('nome', mUsuario);
    Obj.AddPair('token',TJOSE.SHA256CompactToken('DELPHIREACT',LToken));

    Res.Status(200).Send<TJSONObject>(Obj);
    //Res.Status(200).Send<TJsonObject>(TJsonObject.Create.AddPair('token',TJOSE.SHA256CompactToken('DELPHIREACT',LToken)));
  finally
    LToken.Free;
  end;
end;

procedure Registry;
begin
  //thorse.Use( BasicAuthorization());
  THorse.Get('/login', Auth);
end;

end.
