unit Controller.Produto;

interface

uses Horse, System.JSON, System.SysUtils, FireDAC.Comp.Client,
     Data.DB, DataSet.Serialize, Model.Produto, Provider.AUTHORIZATION;

procedure Registry;

implementation

procedure ListarProdutos(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    Prod : TProduto;
    qry : TFDQuery;
    erro : string;
    arrayProdutos : TJSONArray;
begin
    try
        Prod := TProduto.Create;
    except
        res.Send('Erro ao conectar com o banco').Status(500);
        exit;
    end;

    try
        qry := Prod.ListarProduto('', erro);

        arrayProdutos := qry.ToJSONArray();

        res.Send<TJSONArray>(arrayProdutos);

    finally
        qry.Free;
        Prod.Free;
    end;
end;

procedure ListarProdutoID(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    Prod : TProduto;
    objProdutos: TJSONObject;
    qry : TFDQuery;
    erro : string;
begin
    try
        Prod := TProduto.Create;
        Prod.ID := Req.Params['id'].ToInteger;
    except
        res.Send('Erro ao conectar com o banco').Status(500);
        exit;
    end;

    try
        qry := Prod.ListarProduto('', erro);

        if qry.RecordCount > 0 then
        begin
            objProdutos := qry.ToJSONObject;
            res.Send<TJSONObject>(objProdutos)
        end
        else
            res.Send('Produto não encontrado').Status(404);
    finally
        qry.Free;
        Prod.Free;
    end;
end;

procedure AddProduto(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    Prod : TProduto;
    objProduto: TJSONObject;
    erro : string;
    body  : TJsonValue;
begin
    // Conexao com o banco...
    try
        Prod := TProduto.Create;
    except
        res.Send('Erro ao conectar com o banco').Status(500);
        exit;
    end;


    try
        try
            body := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(req.Body), 0) as TJsonValue;

            Prod.DESCRICAO := body.GetValue<string>('descricao', '');
            Prod.CATEGORIA := body.GetValue<Integer>('categoria', 0);
            Prod.PRECO     := body.GetValue<Integer>('preco', 0);
            Prod.Inserir(erro);

            body.Free;

            if erro <> '' then
                raise Exception.Create(erro);

        except on ex:exception do
            begin
                res.Send(ex.Message).Status(400);
                exit;
            end;
        end;


        objProduto := TJSONObject.Create;
        objProduto.AddPair('id', Prod.ID.ToString);

        res.Send<TJSONObject>(objProduto).Status(201);
    finally
        Prod.Free;
    end;
end;

procedure DeleteProduto(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    Prod : TProduto;
    objProduto: TJSONObject;
    erro : string;
begin
    // Conexao com o banco...
    try
        Prod := TProduto.Create;
    except
        res.Send('Erro ao conectar com o banco').Status(500);
        exit;
    end;

    try
        try
            Prod.ID := Req.Params['id'].ToInteger;

            if NOT Prod.Excluir(erro) then
                raise Exception.Create(erro);

        except on ex:exception do
            begin
                res.Send(ex.Message).Status(400);
                exit;
            end;
        end;

    finally
        Prod.Free;
    end;
end;

procedure EditarProduto(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
    Prod : TProduto;
    objProduto: TJSONObject;
    erro : string;
    body : TJsonValue;
begin
    // Conexao com o banco...
    try
        Prod := TProduto.Create;
    except
        res.Send('Erro ao conectar com o banco').Status(500);
        exit;
    end;

    try
        try
            body := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(req.Body), 0) as TJsonValue;

            Prod.ID        := body.GetValue<integer>('id', 0);
            Prod.DESCRICAO := body.GetValue<string>('descricao', '');
            Prod.CATEGORIA := body.GetValue<Integer>('categoria', 0);
            Prod.PRECO     := body.GetValue<Integer>('preco', 0);
            Prod.Editar(erro);

            body.Free;

            if erro <> '' then
                raise Exception.Create(erro);

        except on ex:exception do
            begin
                res.Send(ex.Message).Status(400);
                exit;
            end;
        end;


        objProduto := TJSONObject.Create;
        objProduto.AddPair('id', Prod.ID.ToString);

        res.Send<TJSONObject>(objProduto).Status(200);
    finally
        Prod.Free;
    end;
end;

procedure Registry;
begin
    THorse.Get('/produtos'       , Authorization, ListarProdutos);
    THorse.Get('/produtos/:id'   , Authorization, ListarProdutoID);
    THorse.Post('/produtos'      , Authorization, AddProduto);
    THorse.Put('/produtos'       , Authorization, EditarProduto);
    THorse.Delete('/produtos/:id', Authorization, DeleteProduto);
end;

end.
