unit Controller.Usuario;

interface

uses Horse, BCrypt, System.JSON, System.SysUtils, Model.Usuario, FireDAC.Comp.Client,
     Data.DB, DataSet.Serialize, JOSE.Core.JWT, JOSE.Core.Builder, JOSE.Types.JSON,
     Provider.AUTHORIZATION;

procedure Registry;

implementation

procedure ListarUsuarios(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    Usu : TUsuario;
    arrayUsuarios: TJSONArray;
    qry : TFDQuery;
    erro : string;
begin
    try
        Usu := TUsuario.Create;
    except
        res.Send('Erro ao conectar com o banco').Status(500);
        exit;
    end;

    try
        qry := Usu.ListarUsuario('', erro);

        if qry.RecordCount > 0 then
        begin
            arrayUsuarios := qry.ToJSONArray();
            res.Send<TJSONArray>(arrayUsuarios);
        end
        else
            res.Send('Usuario não encontrado').Status(404);
    finally
        qry.Free;
        Usu.Free;
    end;
end;

procedure ListarUsuariosID(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    Usu : TUsuario;
    objUsuarios: TJSONObject;
    qry : TFDQuery;
    erro : string;
begin
    try
        Usu := TUsuario.Create;
        Usu.ID := Req.Params['id'].ToInteger;
    except
        res.Send('Erro ao conectar com o banco').Status(500);
        exit;
    end;

    try
        qry := Usu.ListarUsuario('', erro);

        if qry.RecordCount > 0 then
        begin
            objUsuarios := qry.ToJSONObject;
            res.Send<TJSONObject>(objUsuarios)
        end
        else
            res.Send('Usuario não encontrado').Status(404);
    finally
        qry.Free;
        Usu.Free;
    end;
end;

procedure AddUsuario(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    cli : TUsuario;
    objUsuario: TJSONObject;
    erro : string;
    body  : TJsonValue;
begin
    // Conexao com o banco...
    try
        cli := TUsuario.Create;
    except
        res.Send('Erro ao conectar com o banco').Status(500);
        exit;
    end;


    try
        try
            body := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(req.Body), 0) as TJsonValue;

            cli.USERNAME := body.GetValue<string>('username', '');
            cli.PASSWORD := body.GetValue<string>('password', '');
            cli.STATUS   := body.GetValue<Integer>('status', 1);
            cli.Inserir(erro);

            body.Free;

            if erro <> '' then
                raise Exception.Create(erro);

        except on ex:exception do
            begin
                res.Send(ex.Message).Status(400);
                exit;
            end;
        end;


        objUsuario := TJSONObject.Create;
        objUsuario.AddPair('id', cli.ID.ToString);

        res.Send<TJSONObject>(objUsuario).Status(201);
    finally
        cli.Free;
    end;
end;

procedure DeleteUsuario(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    Usu : TUsuario;
    objUsuario: TJSONObject;
    erro : string;
begin
    // Conexao com o banco...
    try
        Usu := TUsuario.Create;
    except
        res.Send('Erro ao conectar com o banco').Status(500);
        exit;
    end;

    try
        try
            Usu.ID := Req.Params['id'].ToInteger;

            if NOT Usu.Excluir(erro) then
                raise Exception.Create(erro);

        except on ex:exception do
            begin
                res.Send(ex.Message).Status(400);
                exit;
            end;
        end;

    finally
        Usu.Free;
    end;
end;

procedure EditarUsuario(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    Usu : TUsuario;
    objUsuario: TJSONObject;
    erro : string;
    body : TJsonValue;
begin
    // Conexao com o banco...
    try
        Usu := TUsuario.Create;
    except
        res.Send('Erro ao conectar com o banco').Status(500);
        exit;
    end;

    try
        try
            body := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(req.Body), 0) as TJsonValue;

            Usu.ID       := body.GetValue<integer>('id', 0);
            Usu.USERNAME := body.GetValue<string>('username', '');
            Usu.PASSWORD := body.GetValue<string>('password', '');
            Usu.STATUS   := body.GetValue<Integer>('status', 1);
            Usu.Editar(erro);

            body.Free;

            if erro <> '' then
                raise Exception.Create(erro);

        except on ex:exception do
            begin
                res.Send(ex.Message).Status(400);
                exit;
            end;
        end;


        objUsuario := TJSONObject.Create;
        objUsuario.AddPair('id', Usu.ID.ToString);

        res.Send<TJSONObject>(objUsuario).Status(200);
    finally
        Usu.Free;
    end;
end;

procedure Registry;
begin
    THorse.Get('/usuarios'       , Authorization, ListarUsuarios);
    THorse.Get('/usuarios/:id'   , Authorization, ListarUsuariosID);
    THorse.Post('/usuarios'      , AddUsuario);
    THorse.Put('/usuarios'       , Authorization, EditarUsuario);
    THorse.Delete('/usuarios/:id', Authorization, DeleteUsuario);
end;

end.
