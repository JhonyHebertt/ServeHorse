unit Model.Produto;

interface

uses FireDAC.Comp.Client, Data.DB, System.SysUtils, Model.Connection;

type
    TProduto = class
    private
    FID: Integer;
    FDESCRICAO: String;
    FCATEGORIA: Integer;
    FPRECO: Double;
    public
        constructor Create;
        destructor Destroy; override;

        property ID : Integer read FID write FID;
        property DESCRICAO : String read FDESCRICAO write FDESCRICAO;
        property CATEGORIA : Integer read FCATEGORIA write FCATEGORIA;
        property PRECO : Double read FPRECO write FPRECO;

        function ListarProduto(order_by: string; out erro: string): TFDQuery;
        function Inserir(out erro: string): Boolean;
        function Excluir(out erro: string): Boolean;
        function Editar(out erro: string): Boolean;
end;

implementation

{ TProduto }

constructor TProduto.Create;
begin
    Model.Connection.Connect;
end;

destructor TProduto.Destroy;
begin
    Model.Connection.Disconect;
end;

function TProduto.Excluir(out erro: string): Boolean;
var
    qry : TFDQuery;
begin
    try
        qry := TFDQuery.Create(nil);
        qry.Connection := Model.Connection.FConnection;

        with qry do
        begin
            Active := false;
            sql.Clear;
            SQL.Add('DELETE FROM produtos WHERE ID=:ID');
            ParamByName('ID').Value := ID;
            ExecSQL;
        end;

        qry.Free;
        erro := '';
        result := true;

    except on ex:exception do
        begin
            erro := 'Erro ao excluir produto: ' + ex.Message;
            Result := false;
        end;
    end;
end;

function TProduto.Editar(out erro: string): Boolean;
var
    qry : TFDQuery;
begin
    // Validacoes...
    if ID <= 0 then
    begin
        Result := false;
        erro := 'Informe o id. produto';
        exit;
    end;

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := Model.Connection.FConnection;

        with qry do
        begin
            Active := false;
            sql.Clear;
            SQL.Add('UPDATE produtos SET DESCRICAO=:DESCRICAO, CATEGORIA=:CATEGORIA, PRECO=:PRECO');
            SQL.Add('WHERE ID=:ID');
            ParamByName('DESCRICAO').Value := DESCRICAO;
            ParamByName('CATEGORIA').Value := CATEGORIA;
            ParamByName('PRECO')    .Value := PRECO;
            ParamByName('ID')       .Value := ID;
            ExecSQL;
        end;

        qry.Free;
        erro := '';
        result := true;

    except on ex:exception do
        begin
            erro := 'Erro ao alterar produto: ' + ex.Message;
            Result := false;
        end;
    end;
end;

function TProduto.Inserir(out erro: string): Boolean;
var
    qry : TFDQuery;
begin
    // Validacoes...
    if DESCRICAO.IsEmpty then
    begin
        Result := false;
        erro := 'Informe o nome do produto';
        exit;
    end;

    try
        qry := TFDQuery.Create(nil);
        qry.Connection := Model.Connection.FConnection;

        with qry do
        begin
            Active := false;
            sql.Clear;
            SQL.Add('INSERT INTO produtos (DESCRICAO, CATEGORIA, PRECO)');
            SQL.Add('               VALUES(:DESCRICAO,:CATEGORIA, :PRECO)');

            ParamByName('DESCRICAO').Value := DESCRICAO;
            ParamByName('CATEGORIA').Value := CATEGORIA;
            ParamByName('PRECO')    .Value := PRECO;

            ExecSQL;

            // Busca ID inserido...
            Params.Clear;
            SQL.Clear;
            SQL.Add('SELECT MAX(ID) AS ID FROM produtos');
            SQL.Add('WHERE DESCRICAO=:DESCRICAO');
            ParamByName('DESCRICAO').Value := DESCRICAO;
            active := true;

            ID := FieldByName('ID').AsInteger;
        end;

        qry.Free;
        erro := '';
        result := true;

    except on ex:exception do
        begin
            erro := 'Erro ao cadastrar produto: ' + ex.Message;
            Result := false;
        end;
    end;
end;

function TProduto.ListarProduto(order_by: string; out erro: string): TFDQuery;
var
    qry : TFDQuery;
begin
    try
        qry := TFDQuery.Create(nil);
        qry.Connection := Model.Connection.FConnection;

        with qry do
        begin
            Close;
            SQL.Clear;
            SQL.Add('SELECT PD.*, CA.DESCRICAO AS CATEGORIA_DESCRICAO           ');
            SQL.Add('  FROM produtos PD                                         ');
            SQL.Add('  LEFT JOIN categorias AS CA ON PD.CATEGORIA = CA.ID       ');
            SQL.Add(' WHERE 1 = 1                                               ');

            if ID > 0 then
            begin
                SQL.Add('AND PD.ID = :ID');
                ParamByName('ID').Value := ID;
            end;

            if CATEGORIA > 0 then
            begin
                SQL.Add('AND CA.ID = :IDCA');
                ParamByName('IDCA').Value := ID;
            end;

            if order_by = '' then
                SQL.Add('ORDER BY 1')
            else
                SQL.Add('ORDER BY ' + order_by);

            Open;
        end;

        erro := '';
        Result := qry;
    except on ex:exception do
        begin
            erro := 'Erro ao consultar produtos: ' + ex.Message;
            Result := nil;
        end;
    end;
end;

end.
