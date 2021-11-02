program ServerHorse;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.JSON,
  Horse,
  Horse.Jhonson,
  Horse.CORS,
  Horse.JWT,
  Horse.BasicAuthentication,
  Model.Connection in 'Model\Model.Connection.pas',
  Controller.Usuario in 'Controller\Controller.Usuario.pas',
  Model.Usuario in 'Model\Model.Usuario.pas',
  Controller.Categoria in 'Controller\Controller.Categoria.pas',
  Model.Categoria in 'Model\Model.Categoria.pas',
  Controller.Produto in 'Controller\Controller.Produto.pas',
  Model.Produto in 'Model\Model.Produto.pas',
  Controller.LOGIN in 'Controller\Controller.LOGIN.pas',
  Provider.AUTHORIZATION in 'provider\Provider.AUTHORIZATION.pas';

Var
  App: THorse;

  begin
  try
    if THorse.IsRunning then
      THorse.StopListen;

    App:= THorse.create(9000);
  Except
    THorse.StopListen;
  end;

  App.Use(Jhonson());
  App.Use(CORS);

  App.Get('/',
  procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
  begin
    Model.Connection.Connect;
    Res.Send('<h1> CONECTADÃO!!! </h1>');
  end);

  //Controllers
  Controller.Login.Registry;
  Controller.usuario.Registry;
  Controller.categoria.Registry;
  Controller.produto.Registry;

    App.start;
end.
