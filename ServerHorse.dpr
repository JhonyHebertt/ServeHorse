program ServerHorse;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Horse,
  Horse.Jhonson,
  Controller.Cliente in 'Controller\Controller.Cliente.pas',
  Model.Connection in 'Model\Model.Connection.pas',
  Model.Cliente in 'Model\Model.Cliente.pas';

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

    //Controllers
    Controller.Cliente.Registry;

    App.start;
end.
