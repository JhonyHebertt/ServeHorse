unit Controller.Categoria;

interface

uses Horse, System.JSON, System.SysUtils, Model.Categoria, FireDAC.Comp.Client,
     Data.DB, DataSet.Serialize;

procedure Registry;

implementation

uses Provider.AUTHORIZATION;

procedure ListarCategorias(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    Cat : TCategoria;
    qry : TFDQuery;
    erro : string;
    arrayCategorias : TJSONArray;
begin
    try
        Cat := TCategoria.Create;
    except
        res.Send('Erro ao conectar com o banco').Status(500);
        exit;
    end;

    try
        qry := Cat.ListarCategoria('', erro);

        arrayCategorias := qry.ToJSONArray();
        res.Send<TJSONArray>(arrayCategorias);

    finally
        qry.Free;
        Cat.Free;
    end;
end;

procedure ListarCategoriaID(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    Cat : TCategoria;
    objCategorias: TJSONObject;
    qry : TFDQuery;
    erro : string;
begin
    try
        Cat := TCategoria.Create;
        Cat.ID := Req.Params['id'].ToInteger;
    except
        res.Send('Erro ao conectar com o banco').Status(500);
        exit;
    end;

    try
        qry := Cat.ListarCategoria('', erro);

        if qry.RecordCount > 0 then
        begin
            objCategorias := qry.ToJSONObject;
            res.Send<TJSONObject>(objCategorias)
        end
        else
            res.Send('Categoria não encontrado').Status(404);
    finally
        qry.Free;
        Cat.Free;
    end;
end;

procedure AddCategoria(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    cli : TCategoria;
    objCategoria: TJSONObject;
    erro : string;
    body  : TJsonValue;
begin
    // Conexao com o banco...
    try
        cli := TCategoria.Create;
    except
        res.Send('Erro ao conectar com o banco').Status(500);
        exit;
    end;


    try
        try
            body := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(req.Body), 0) as TJsonValue;

            cli.DESCRICAO := body.GetValue<string>('descricao', '');
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


        objCategoria := TJSONObject.Create;
        objCategoria.AddPair('id', cli.ID.ToString);

        res.Send<TJSONObject>(objCategoria).Status(201);
    finally
        cli.Free;
    end;
end;

procedure DeleteCategoria(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    Cat : TCategoria;
    objCategoria: TJSONObject;
    erro : string;
begin
    // Conexao com o banco...
    try
        Cat := TCategoria.Create;
    except
        res.Send('Erro ao conectar com o banco').Status(500);
        exit;
    end;

    try
        try
            Cat.ID := Req.Params['id'].ToInteger;

            if NOT Cat.Excluir(erro) then
                raise Exception.Create(erro);

        except on ex:exception do
            begin
                res.Send(ex.Message).Status(400);
                exit;
            end;
        end;

    finally
        Cat.Free;
    end;
end;

procedure EditarCategoria(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    Cat : TCategoria;
    objCategoria: TJSONObject;
    erro : string;
    body : TJsonValue;
begin
    // Conexao com o banco...
    try
        Cat := TCategoria.Create;
    except
        res.Send('Erro ao conectar com o banco').Status(500);
        exit;
    end;

    try
        try
            body := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(req.Body), 0) as TJsonValue;

            Cat.ID       := body.GetValue<integer>('id', 0);
            Cat.DESCRICAO:= body.GetValue<string>('descricao', '');
            Cat.Editar(erro);

            body.Free;

            if erro <> '' then
                raise Exception.Create(erro);

        except on ex:exception do
            begin
                res.Send(ex.Message).Status(400);
                exit;
            end;
        end;


        objCategoria := TJSONObject.Create;
        objCategoria.AddPair('id', Cat.ID.ToString);

        res.Send<TJSONObject>(objCategoria).Status(200);
    finally
        Cat.Free;
    end;
end;

procedure Registry;
begin
    THorse.Get('/categorias'       , Authorization, ListarCategorias);
    THorse.Get('/categorias/:id'   , Authorization, ListarCategoriaID);
    THorse.Post('/categorias'      , Authorization, AddCategoria);
    THorse.Put('/categorias'       , Authorization, EditarCategoria);
    THorse.Delete('/categorias/:id', Authorization, DeleteCategoria);
end;

end.
